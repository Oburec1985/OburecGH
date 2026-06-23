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
    fFolderInfo: TSdbFolderInfo;
  public
    property ItemKind: TSdbItemKind read fItemKind write fItemKind;
    property ScaleInfo: TSdbScaleInfo read fScaleInfo write fScaleInfo;
    property FolderInfo: TSdbFolderInfo read fFolderInfo write fFolderInfo;
  end;

  { Read-only in-memory view of the disk SDB. It uses the shared hierarchy
    object, so future picker/tree UI can bind to the same model. }
  TRecorderSdbTree = class
  private
    fRoot: TRecorderSdbNode;
    function EnsureFolder(AParent: TRecorderSdbNode;
      const AName, AKey: string): TRecorderSdbNode;
    procedure LoadDirectory(AParent: TRecorderSdbNode;
      const ADiskDir, AKey: string);
    procedure LoadScalePairs(AParent: TRecorderSdbNode;
      const ADiskDir, AKey: string);
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
function RecorderSdbLoadScaleCalibrationFromInfo(const AInfo: TSdbScaleInfo;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderSdbLoadScaleCalibration(const AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderSdbLoadScaleCalibrationFromCsv(const ACsvPath, AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderSdbImportCalibration(AList: TRecorderCalibrationList;
  const AKey: string; out ACalibrationName: string): Boolean;

function RecorderSdbNodeDisplayName(ANode: TRecorderSdbNode): string;
function RecorderSdbNodeDisplayDescription(ANode: TRecorderSdbNode): string;
procedure RecorderSdbReloadNodeMetadata(ANode: TRecorderSdbNode);

implementation

uses
  FileUtil, LazFileUtils, StrUtils, uRecorderMeraPaths, uRecorderSdbPropBag,
  uSharedStringEncoding;

function RecorderSdbRootDir: string;
var
  lBase: string;
begin
  lBase := IncludeTrailingPathDelimiter(RecorderMeraFilesPath);
  if DirectoryExists(lBase + 'SDB') then
    Result := lBase + 'SDB' + PathDelim
  else
    Result := lBase + 'sdb' + PathDelim;
end;

function RecorderSdbNormalizeKey(const AKey: string): string;
var
  lExt: string;
begin
  Result := Trim(AKey);
  Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  while (Length(Result) > 0) and (Result[1] = '\') do
    Delete(Result, 1, 1);
  { Имена шкал вроде K_ГОСТ Р 8.585-2001 содержат точку, но это не .csv/.xml. }
  lExt := LowerCase(ExtractFileExt(Result));
  if (lExt = '.xml') or (lExt = '.csv') then
    Result := ChangeFileExt(Result, '');
end;

function SdbKeyFileName(const AKey, AExtension: string): string;
var
  lRoot: string;
  lKey: string;
  lRel: string;
begin
  Result := '';
  lKey := RecorderSdbNormalizeKey(AKey);
  if lKey = '' then
    Exit;
  lRoot := ExcludeTrailingPathDelimiter(ExpandFileName(RecorderSdbRootDir));
  lRel := StringReplace(lKey, '\', PathDelim, [rfReplaceAll]) + AExtension;
  Result := IncludeTrailingPathDelimiter(lRoot) + lRel;
  // SDB keys are relative paths. Reject traversal outside the SDB root.
  if not StartsText(IncludeTrailingPathDelimiter(lRoot),
    IncludeTrailingPathDelimiter(ExtractFileDir(Result))) then
    Result := '';
end;

procedure SdbCollectFileBasenames(const ADiskDir, AExtension: string;
  ABasenames: TStrings);
var
  SR: TSearchRec;
  lDiskDir: string;
begin
  if ABasenames = nil then
    Exit;
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  if FindFirst(lDiskDir + '*' + AExtension, faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Attr and faDirectory) <> 0 then
        Continue;
      ABasenames.Add(ChangeFileExt(SR.Name, ''));
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function RecorderSdbScaleXmlPath(const AKey: string): string;
begin
  Result := SdbKeyFileName(AKey, '.xml');
end;

function RecorderSdbScaleCsvPath(const AKey: string): string;
begin
  Result := SdbKeyFileName(AKey, '.csv');
end;

function RecorderSdbTryLoadScaleFromPaths(const AKey, AXmlPath, ACsvPath: string;
  out AInfo: TSdbScaleInfo): Boolean;
var
  lBag: TSdbPropBag;
begin
  AInfo := Default(TSdbScaleInfo);
  Result := False;
  if (AXmlPath = '') or (ACsvPath = '') then
    Exit;
  if not FileExistsUTF8(AXmlPath) or not FileExistsUTF8(ACsvPath) then
    Exit;
  lBag := TSdbPropBag.Create;
  try
    lBag.LoadFromFile(AXmlPath);
    AInfo.Key := RecorderSdbNormalizeKey(AKey);
    AInfo.Name := lBag.GetProp('name');
    AInfo.Description := lBag.GetProp('dsc');
    AInfo.SrcFrom := lBag.GetPropFloat('src from', 0);
    AInfo.SrcTo := lBag.GetPropFloat('src to', 0);
    AInfo.DstFrom := lBag.GetPropFloat('dst from', 0);
    AInfo.DstTo := lBag.GetPropFloat('dst to', 0);
    AInfo.SrcUnits := lBag.GetProp('src units');
    AInfo.DstUnits := lBag.GetProp('dst units');
    AInfo.ModuleId := lBag.GetProp('module id');
    AInfo.State := Round(lBag.GetPropFloat('state', 0));
    AInfo.ModTime := lBag.GetProp('mod time');
    AInfo.XmlPath := AXmlPath;
    AInfo.CsvPath := ACsvPath;
    if Trim(AInfo.ModuleId) = '' then
      AInfo.ModuleId := CSdbInterpolateModuleId;
    Result := True;
  finally
    lBag.Free;
  end;
end;

function RecorderSdbTryLoadFolder(const AKey: string;
  out AInfo: TSdbFolderInfo): Boolean;
var
  lBag: TSdbPropBag;
  lFolderPath: string;
  lXmlPath: string;
begin
  AInfo := Default(TSdbFolderInfo);
  Result := False;
  if RecorderSdbNormalizeKey(AKey) = '' then
  begin
    lFolderPath := ExpandFileName(RecorderSdbRootDir);
    lXmlPath := IncludeTrailingPathDelimiter(lFolderPath) + CSdbDescriptorFile;
  end
  else
  begin
    lFolderPath := ExpandFileName(IncludeTrailingPathDelimiter(RecorderSdbRootDir) +
      StringReplace(RecorderSdbNormalizeKey(AKey), '\', PathDelim, [rfReplaceAll]));
    lXmlPath := IncludeTrailingPathDelimiter(lFolderPath) +
      ExtractFileName(lFolderPath) + '.xml';
  end;
  if not FileExistsUTF8(lXmlPath) then
    Exit;
  lBag := TSdbPropBag.Create;
  try
    lBag.LoadFromFile(lXmlPath);
    AInfo.Key := RecorderSdbNormalizeKey(AKey);
    AInfo.Name := lBag.GetProp('name');
    AInfo.Description := lBag.GetProp('dsc');
    AInfo.XmlPath := lXmlPath;
    Result := True;
  finally
    lBag.Free;
  end;
end;

function RecorderSdbTryLoadScale(const AKey: string; out AInfo: TSdbScaleInfo): Boolean;
begin
  Result := RecorderSdbTryLoadScaleFromPaths(AKey, RecorderSdbScaleXmlPath(AKey),
    RecorderSdbScaleCsvPath(AKey), AInfo);
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
  const AName, AKey: string): TRecorderSdbNode;
var
  I: Integer;
  lFolderInfo: TSdbFolderInfo;
begin
  for I := 0 to AParent.GetChildCount - 1 do
    if (AParent.GetChild(I) is TRecorderSdbNode) and
      SameText(AParent.GetChild(I).Name, AName) then
      Exit(TRecorderSdbNode(AParent.GetChild(I)));
  Result := TRecorderSdbNode.Create;
  Result.Name := AName;
  Result.Caption := AName;
  Result.ItemKind := sikFolder;
  if RecorderSdbTryLoadFolder(AKey, lFolderInfo) then
    Result.FolderInfo := lFolderInfo;
  // Caption = имя каталога на диске (как в оригинальном SDB viewer).
  AParent.AddChild(Result);
end;

procedure TRecorderSdbTree.LoadScalePairs(AParent: TRecorderSdbNode;
  const ADiskDir, AKey: string);
var
  I: Integer;
  lBasenames: TStringList;
  lBase: string;
  lChildKey: string;
  lCsvPath: string;
  lDirName: string;
  lDiskDir: string;
  lScaleInfo: TSdbScaleInfo;
  lScaleNode: TRecorderSdbNode;
  lXmlPath: string;
begin
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  lDirName := ExtractFileName(ExcludeTrailingPathDelimiter(lDiskDir));
  lBasenames := TStringList.Create;
  try
    lBasenames.Sorted := True;
    lBasenames.Duplicates := dupIgnore;
    SdbCollectFileBasenames(lDiskDir, '.xml', lBasenames);
    SdbCollectFileBasenames(lDiskDir, '.csv', lBasenames);
    for I := 0 to lBasenames.Count - 1 do
    begin
      lBase := lBasenames[I];
      if SameText(lBase, ChangeFileExt(CSdbDescriptorFile, '')) then
        Continue;
      if SameText(lBase, lDirName) then
        Continue;
      lXmlPath := lDiskDir + lBase + '.xml';
      lCsvPath := lDiskDir + lBase + '.csv';
      if not FileExistsUTF8(lXmlPath) or not FileExistsUTF8(lCsvPath) then
        Continue;
      if AKey <> '' then
        lChildKey := AKey + '\' + lBase
      else
        lChildKey := lBase;
      if not RecorderSdbTryLoadScaleFromPaths(lChildKey, lXmlPath, lCsvPath,
        lScaleInfo) then
        Continue;
      lScaleNode := TRecorderSdbNode.Create;
      lScaleNode.Name := lBase;
      lScaleNode.Caption := SharedPreferredDisplayText(lScaleInfo.Name, lBase);
      lScaleNode.ItemKind := sikScale;
      lScaleNode.ScaleInfo := lScaleInfo;
      AParent.AddChild(lScaleNode);
    end;
  finally
    lBasenames.Free;
  end;
end;

procedure TRecorderSdbTree.LoadDirectory(AParent: TRecorderSdbNode;
  const ADiskDir, AKey: string);
var
  SR: TSearchRec;
  lDiskDir: string;
  lChildKey: string;
  lFolderNode: TRecorderSdbNode;
  lSubDir: string;
  lXmlPath: string;
begin
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  LoadScalePairs(AParent, ADiskDir, AKey);

  if FindFirst(lDiskDir + '*', faDirectory, SR) = 0 then
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then
        Continue;
      if (SR.Attr and faDirectory) = 0 then
        Continue;
      lSubDir := lDiskDir + SR.Name;
      lXmlPath := IncludeTrailingPathDelimiter(lSubDir) + SR.Name + '.xml';
      if not FileExistsUTF8(lXmlPath) then
        Continue;
      if AKey <> '' then
        lChildKey := AKey + '\' + SR.Name
      else
        lChildKey := SR.Name;
      lFolderNode := EnsureFolder(AParent, SR.Name, lChildKey);
      LoadDirectory(lFolderNode, lSubDir, lChildKey);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

procedure TRecorderSdbTree.Load;
var
  lRoot: string;
  lFolderInfo: TSdbFolderInfo;
begin
  fRoot.ClearChildren;
  lRoot := IncludeTrailingPathDelimiter(ExpandFileName(RecorderSdbRootDir));
  if not DirectoryExists(lRoot) then
    Exit;
  fRoot.FolderInfo := Default(TSdbFolderInfo);
  fRoot.Caption := 'SDB';
  if RecorderSdbTryLoadFolder('', lFolderInfo) then
  begin
    fRoot.FolderInfo := lFolderInfo;
    fRoot.Caption := SharedPreferredDisplayText(lFolderInfo.Name, fRoot.Caption);
  end;
  LoadDirectory(fRoot, lRoot, '');
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

function SdbTryParseCsvLine(const ALine: string; out AX, AY: Double): Boolean;
var
  lLeft: string;
  lLine: string;
  lPos: Integer;
  lRight: string;

  function TrySplit(ADelim: Char): Boolean;
  begin
    lPos := Pos(ADelim, lLine);
    if lPos <= 0 then
      Exit(False);
    lLeft := Trim(Copy(lLine, 1, lPos - 1));
    lRight := Trim(Copy(lLine, lPos + 1, MaxInt));
    Result := SdbTryParseNumber(lLeft, AX) and SdbTryParseNumber(lRight, AY);
  end;

begin
  lLine := Trim(ALine);
  if lLine = '' then
    Exit(False);
  if Pos(';', lLine) > 0 then
    Result := TrySplit(';')
  else
    Result := TrySplit(',') or TrySplit(#9);
end;

function RecorderSdbLoadScaleCalibrationFromInfo(const AInfo: TSdbScaleInfo;
  ACalibration: TRecorderCalibration): Boolean;
var
  I: Integer;
  lLines: TStringList;
  lX: Double;
  lY: Double;
begin
  Result := False;
  if (ACalibration = nil) or (Trim(AInfo.CsvPath) = '') or
    not FileExistsUTF8(AInfo.CsvPath) then
    Exit;
  lLines := TStringList.Create;
  try
    SharedLoadLegacyTextLines(lLines, AInfo.CsvPath);
    ACalibration.ClearPoints;
    for I := 0 to lLines.Count - 1 do
    begin
      if not SdbTryParseCsvLine(lLines[I], lX, lY) then
        Continue;
      ACalibration.AddPoint(lX, lY);
    end;
    if ACalibration.PointCount = 0 then
      Exit;
    ACalibration.Kind := rckPiecewiseLinear;
    ACalibration.Description := AInfo.Key;
    ACalibration.UnitIn := AInfo.SrcUnits;
    ACalibration.UnitOut := AInfo.DstUnits;
    ACalibration.Extrapolation := True;
    Result := True;
  finally
    lLines.Free;
  end;
end;

function RecorderSdbLoadScaleCalibration(const AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  lInfo: TSdbScaleInfo;
begin
  Result := False;
  if (ACalibration = nil) or not RecorderSdbTryLoadScale(AKey, lInfo) then
    Exit;
  Result := RecorderSdbLoadScaleCalibrationFromInfo(lInfo, ACalibration);
end;

function RecorderSdbLoadScaleCalibrationFromCsv(const ACsvPath, AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  lInfo: TSdbScaleInfo;
begin
  Result := False;
  if (ACalibration = nil) or (Trim(ACsvPath) = '') or not FileExistsUTF8(ACsvPath) then
    Exit;
  lInfo.Key := RecorderSdbNormalizeKey(AKey);
  lInfo.CsvPath := ACsvPath;
  if Trim(lInfo.SrcUnits) = '' then
    lInfo.SrcUnits := 'mV';
  if Trim(lInfo.DstUnits) = '' then
    lInfo.DstUnits := 'degC';
  Result := RecorderSdbLoadScaleCalibrationFromInfo(lInfo, ACalibration);
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

function RecorderSdbNodeDisplayName(ANode: TRecorderSdbNode): string;
begin
  Result := '';
  if ANode = nil then
    Exit;
  case ANode.ItemKind of
    sikScale:
      Result := SharedPreferredDisplayText(ANode.ScaleInfo.Name, ANode.Caption);
    sikFolder, sikRoot:
      Result := SharedPreferredDisplayText(ANode.FolderInfo.Name, ANode.Caption);
  end;
end;

function RecorderSdbNodeDisplayDescription(ANode: TRecorderSdbNode): string;
begin
  Result := '';
  if ANode = nil then
    Exit;
  case ANode.ItemKind of
    sikScale:
      Result := ANode.ScaleInfo.Description;
    sikFolder, sikRoot:
      Result := ANode.FolderInfo.Description;
  end;
  if not SharedIsGoodDisplayText(Result) then
    Result := '';
end;

procedure RecorderSdbReloadNodeMetadata(ANode: TRecorderSdbNode);
var
  lFolder: TSdbFolderInfo;
  lScale: TSdbScaleInfo;
begin
  if ANode = nil then
    Exit;
  case ANode.ItemKind of
    sikScale:
      if (ANode.ScaleInfo.XmlPath <> '') and (ANode.ScaleInfo.CsvPath <> '') then
        if RecorderSdbTryLoadScaleFromPaths(ANode.ScaleInfo.Key,
          ANode.ScaleInfo.XmlPath, ANode.ScaleInfo.CsvPath, lScale) then
          ANode.ScaleInfo := lScale;
    sikFolder, sikRoot:
      if RecorderSdbTryLoadFolder(ANode.FolderInfo.Key, lFolder) then
        ANode.FolderInfo := lFolder;
  end;
end;

end.
