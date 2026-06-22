unit uRecorderSdbStore;

{
  Native, cross-platform reader for the Mera Scales DataBase (SDB).

  Original Recorder accesses SDB through Windows COM interfaces. The on-disk
  contract is portable: a root descriptor (sdb.xml), folder descriptors and a
  pair of XML metadata plus CSV points per scale. This unit is read-only.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uBaseObjLaz, uRecorderSdbTypes, uRecorderTags;

type
  { One native SDB tree node. Folders have children; scale nodes carry the
    metadata that identifies their CSV point table. }
  TRecorderSdbNode = class(TBaseObj)
  private
    fItemKind: TSdbItemKind;
    fScaleInfo: TSdbScaleInfo;
  public
    property ItemKind: TSdbItemKind read fItemKind write fItemKind;
    property ScaleInfo: TSdbScaleInfo read fScaleInfo write fScaleInfo;
  end;

  { Read-only in-memory view of the disk SDB. It uses the shared hierarchy
    object, so future picker/tree UI can bind to the same model. }
  TRecorderSdbTree = class
  private
    fRoot: TRecorderSdbNode;
    function EnsureFolder(AParent: TRecorderSdbNode;
      const AName: string): TRecorderSdbNode;
    procedure CollectScaleKeys(ANode: TRecorderSdbNode;
      const AFolderKey: string; AKeys: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load;
    procedure ListScaleKeys(const AFolderKey: string; AKeys: TStrings);
    property Root: TRecorderSdbNode read fRoot;
  end;

function RecorderSdbRootDir: string;
function RecorderSdbNormalizeKey(const AKey: string): string;
function RecorderSdbScaleXmlPath(const AKey: string): string;
function RecorderSdbScaleCsvPath(const AKey: string): string;
procedure RecorderSdbListScaleKeys(const AFolderKey: string; AKeys: TStrings);
function RecorderSdbTryLoadScale(const AKey: string; out AInfo: TSdbScaleInfo): Boolean;
function RecorderSdbLoadScaleCalibration(const AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderSdbImportCalibration(AList: TRecorderCalibrationList;
  const AKey: string; out ACalibrationName: string): Boolean;

implementation

uses
  DOM, XMLRead, FileUtil, StrUtils, Math, uRecorderMeraPaths;

function RecorderSdbRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'sdb' + PathDelim;
end;

function RecorderSdbNormalizeKey(const AKey: string): string;
begin
  Result := Trim(AKey);
  Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  while (Length(Result) > 0) and (Result[1] = '\') do
    Delete(Result, 1, 1);
  Result := ChangeFileExt(Result, '');
end;

function SdbKeyFileName(const AKey, AExtension: string): string;
var
  lRoot: string;
  lKey: string;
  lFileName: string;
begin
  Result := '';
  lKey := RecorderSdbNormalizeKey(AKey);
  if lKey = '' then
    Exit;
  lRoot := ExpandFileName(RecorderSdbRootDir);
  lFileName := ExpandFileName(IncludeTrailingPathDelimiter(lRoot) +
    StringReplace(lKey, '\', PathDelim, [rfReplaceAll]) + AExtension);
  // SDB keys are relative paths. Reject traversal outside the SDB root.
  if not StartsText(IncludeTrailingPathDelimiter(lRoot),
    IncludeTrailingPathDelimiter(ExtractFileDir(lFileName))) then
    Exit;
  Result := lFileName;
end;

function RecorderSdbScaleXmlPath(const AKey: string): string;
begin
  Result := SdbKeyFileName(AKey, '.xml');
end;

function RecorderSdbScaleCsvPath(const AKey: string): string;
begin
  Result := SdbKeyFileName(AKey, '.csv');
end;

function SdbNodeText(ANode: TDOMNode): string;
var
  lChild: TDOMNode;
begin
  Result := '';
  if ANode = nil then
    Exit;
  lChild := ANode.FirstChild;
  while lChild <> nil do
  begin
    if lChild.NodeType in [TEXT_NODE, CDATA_SECTION_NODE] then
      Result := Result + lChild.NodeValue
    else
      Result := Result + SdbNodeText(lChild);
    lChild := lChild.NextSibling;
  end;
  Result := Trim(Result);
end;

function SdbProperty(ADocument: TXMLDocument; const AName: string): string;
var
  lNode: TDOMNode;
  lNameNode: TDOMNode;
begin
  Result := '';
  if (ADocument = nil) or (ADocument.DocumentElement = nil) then
    Exit;
  lNode := ADocument.DocumentElement.FirstChild;
  while lNode <> nil do
  begin
    if SameText(lNode.NodeName, 'pty') then
    begin
      lNameNode := lNode.Attributes.GetNamedItem('n');
      if (lNameNode <> nil) and SameText(lNameNode.NodeValue, AName) then
        Exit(SdbNodeText(lNode));
    end;
    lNode := lNode.NextSibling;
  end;
end;

function SdbFloat(const AText: string; ADefault: Double): Double;
var
  lFormat: TFormatSettings;
  lValue: string;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  lValue := StringReplace(Trim(AText), ',', '.', [rfReplaceAll]);
  if not TryStrToFloat(lValue, Result, lFormat) then
    Result := ADefault;
end;

function RecorderSdbTryLoadScale(const AKey: string; out AInfo: TSdbScaleInfo): Boolean;
var
  lDocument: TXMLDocument;
  lXmlPath: string;
begin
  AInfo := Default(TSdbScaleInfo);
  Result := False;
  lXmlPath := RecorderSdbScaleXmlPath(AKey);
  if (lXmlPath = '') or not FileExists(lXmlPath) then
    Exit;
  lDocument := nil;
  try
    ReadXMLFile(lDocument, lXmlPath);
    AInfo.Key := RecorderSdbNormalizeKey(AKey);
    AInfo.Name := SdbProperty(lDocument, 'name');
    AInfo.Description := SdbProperty(lDocument, 'dsc');
    AInfo.SrcFrom := SdbFloat(SdbProperty(lDocument, 'src from'), 0);
    AInfo.SrcTo := SdbFloat(SdbProperty(lDocument, 'src to'), 0);
    AInfo.DstFrom := SdbFloat(SdbProperty(lDocument, 'dst from'), 0);
    AInfo.DstTo := SdbFloat(SdbProperty(lDocument, 'dst to'), 0);
    AInfo.SrcUnits := SdbProperty(lDocument, 'src units');
    AInfo.DstUnits := SdbProperty(lDocument, 'dst units');
    AInfo.ModuleId := SdbProperty(lDocument, 'module id');
    AInfo.State := Round(SdbFloat(SdbProperty(lDocument, 'state'), 0));
    AInfo.ModTime := SdbProperty(lDocument, 'mod time');
    AInfo.XmlPath := lXmlPath;
    AInfo.CsvPath := RecorderSdbScaleCsvPath(AInfo.Key);
    Result := FileExists(AInfo.CsvPath) and (AInfo.ModuleId <> '');
  except
    Result := False;
  end;
  lDocument.Free;
end;

constructor TRecorderSdbTree.Create;
begin
  inherited Create;
  fRoot := TRecorderSdbNode.Create;
  fRoot.Name := 'sdb';
  fRoot.Caption := 'SDB';
  fRoot.ItemKind := sikRoot;
end;

destructor TRecorderSdbTree.Destroy;
begin
  fRoot.Free;
  inherited Destroy;
end;

function TRecorderSdbTree.EnsureFolder(AParent: TRecorderSdbNode;
  const AName: string): TRecorderSdbNode;
var
  I: Integer;
begin
  for I := 0 to AParent.GetChildCount - 1 do
    if (AParent.GetChild(I) is TRecorderSdbNode) and
      SameText(AParent.GetChild(I).Name, AName) then
      Exit(TRecorderSdbNode(AParent.GetChild(I)));
  Result := TRecorderSdbNode.Create;
  Result.Name := AName;
  Result.Caption := AName;
  Result.ItemKind := sikFolder;
  AParent.AddChild(Result);
end;

procedure TRecorderSdbTree.Load;
var
  I: Integer;
  J: Integer;
  lFiles: TStringList;
  lInfo: TSdbScaleInfo;
  lKey: string;
  lParts: TStringList;
  lRoot: string;
  lNode: TRecorderSdbNode;
  lScale: TRecorderSdbNode;
begin
  fRoot.ClearChildren;
  lRoot := IncludeTrailingPathDelimiter(ExpandFileName(RecorderSdbRootDir));
  if not DirectoryExists(lRoot) then
    Exit;
  lFiles := TStringList.Create;
  lParts := TStringList.Create;
  try
    lFiles.Sorted := True;
    FindAllFiles(lFiles, lRoot, '*.xml', True);
    lParts.StrictDelimiter := True;
    lParts.Delimiter := '\';
    for I := 0 to lFiles.Count - 1 do
    begin
      lKey := ChangeFileExt(Copy(lFiles[I], Length(lRoot) + 1, MaxInt), '');
      lKey := StringReplace(lKey, PathDelim, '\', [rfReplaceAll]);
      if SameText(lKey, ChangeFileExt(CSdbDescriptorFile, '')) or
        not RecorderSdbTryLoadScale(lKey, lInfo) then
        Continue;
      lParts.DelimitedText := lInfo.Key;
      if lParts.Count = 0 then
        Continue;
      lNode := fRoot;
      for J := 0 to lParts.Count - 2 do
        lNode := EnsureFolder(lNode, lParts[J]);
      lScale := TRecorderSdbNode.Create;
      lScale.Name := lParts[lParts.Count - 1];
      lScale.Caption := lInfo.Name;
      if lScale.Caption = '' then
        lScale.Caption := lScale.Name;
      lScale.ItemKind := sikScale;
      lScale.ScaleInfo := lInfo;
      lNode.AddChild(lScale);
    end;
  finally
    lParts.Free;
    lFiles.Free;
  end;
end;

procedure TRecorderSdbTree.CollectScaleKeys(ANode: TRecorderSdbNode;
  const AFolderKey: string; AKeys: TStrings);
var
  I: Integer;
  lChild: TRecorderSdbNode;
  lPrefix: string;
begin
  if ANode = nil then
    Exit;
  lPrefix := RecorderSdbNormalizeKey(AFolderKey);
  if lPrefix <> '' then
    lPrefix := lPrefix + '\';
  for I := 0 to ANode.GetChildCount - 1 do
  begin
    if not (ANode.GetChild(I) is TRecorderSdbNode) then
      Continue;
    lChild := TRecorderSdbNode(ANode.GetChild(I));
    if lChild.ItemKind = sikScale then
    begin
      if (lPrefix = '') or StartsText(lPrefix, lChild.ScaleInfo.Key) then
        AKeys.Add(lChild.ScaleInfo.Key);
    end
    else
      CollectScaleKeys(lChild, AFolderKey, AKeys);
  end;
end;

procedure TRecorderSdbTree.ListScaleKeys(const AFolderKey: string;
  AKeys: TStrings);
begin
  if AKeys = nil then
    Exit;
  AKeys.Clear;
  CollectScaleKeys(fRoot, AFolderKey, AKeys);
  if AKeys is TStringList then
    TStringList(AKeys).Sort;
end;

procedure RecorderSdbListScaleKeys(const AFolderKey: string; AKeys: TStrings);
var
  lTree: TRecorderSdbTree;
begin
  if AKeys = nil then
    Exit;
  lTree := TRecorderSdbTree.Create;
  try
    lTree.Load;
    lTree.ListScaleKeys(AFolderKey, AKeys);
  finally
    lTree.Free;
  end;
end;

function SdbTryParseNumber(const AText: string; out AValue: Double): Boolean;
var
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  Result := TryStrToFloat(StringReplace(Trim(AText), ',', '.', [rfReplaceAll]),
    AValue, lFormat);
end;

function RecorderSdbLoadScaleCalibration(const AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  I: Integer;
  lInfo: TSdbScaleInfo;
  lLines: TStringList;
  lParts: TStringList;
  lX: Double;
  lY: Double;
begin
  Result := False;
  if (ACalibration = nil) or not RecorderSdbTryLoadScale(AKey, lInfo) then
    Exit;
  lLines := TStringList.Create;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ',';
    lLines.LoadFromFile(lInfo.CsvPath);
    ACalibration.ClearPoints;
    for I := 0 to lLines.Count - 1 do
    begin
      lParts.DelimitedText := Trim(lLines[I]);
      if (lParts.Count < 2) or not SdbTryParseNumber(lParts[0], lX) or
        not SdbTryParseNumber(lParts[1], lY) then
        Continue;
      ACalibration.AddPoint(lX, lY);
    end;
    if ACalibration.PointCount = 0 then
      Exit;
    ACalibration.Kind := rckPiecewiseLinear;
    ACalibration.Description := lInfo.Key;
    ACalibration.UnitIn := lInfo.SrcUnits;
    ACalibration.UnitOut := lInfo.DstUnits;
    ACalibration.Extrapolation := True;
    Result := True;
  finally
    lParts.Free;
    lLines.Free;
  end;
end;

function RecorderSdbImportCalibration(AList: TRecorderCalibrationList;
  const AKey: string; out ACalibrationName: string): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lName: string;
begin
  Result := False;
  ACalibrationName := '';
  if AList = nil then
    Exit;
  lName := 'SDB ' + RecorderSdbNormalizeKey(AKey);
  if lName = 'SDB ' then
    Exit;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibration(AKey, lCalibration) then
      Exit;
    lCalibration.Name := lName;
    for I := 0 to AList.Count - 1 do
      if SameText(AList[I].Name, lName) then
      begin
        AList[I].Assign(lCalibration);
        AList[I].Name := lName;
        ACalibrationName := lName;
        Exit(True);
      end;
    AList.Add(lCalibration);
    lCalibration := nil;
    ACalibrationName := lName;
    Result := True;
  finally
    lCalibration.Free;
  end;
end;

end.
