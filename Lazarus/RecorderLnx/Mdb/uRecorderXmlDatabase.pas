unit uRecorderXmlDatabase;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, Contnrs;

type
  ERecorderXmlDatabase = class(Exception);

  { Backend-neutral XML node. Domain units define hierarchy and meaning. }
  TRecorderXmlDbNode = class
  private
    fId, fName, fKind, fParentId, fRelativePath: string;
    fProperties: TStringList;
  public
    constructor Create(const AKind: string); virtual;
    destructor Destroy; override;
    property Id: string read fId write fId;
    property Name: string read fName write fName;
    property Kind: string read fKind;
    property ParentId: string read fParentId write fParentId;
    property RelativePath: string read fRelativePath write fRelativePath;
    property Properties: TStringList read fProperties;
  end;

  { Common filesystem/XML lifecycle. A descriptor is stored beside its
    same-named data directory, as in the legacy cDB/cXmlFolder design. }
  TRecorderXmlDatabase = class
  private
    fBasePath: string;
    fNodes: TObjectList;
    procedure ScanDirectory(const ADirectory, AParentId: string);
  protected
    function CreateNode(const AKind: string): TRecorderXmlDbNode; virtual; abstract;
    function AcceptParent(const AKind, AParentKind: string): Boolean; virtual; abstract;
    function UniqueRelativePath(const AParentPath, APrefix: string): string;
  public
    constructor Create(const ABasePath: string);
    destructor Destroy; override;
    procedure Open;
    procedure Reload;
    function AddNode(const AKind, AParentId, AParentPath, APrefix,
      AName: string): TRecorderXmlDbNode;
    procedure SaveNode(ANode: TRecorderXmlDbNode);
    function FindNode(const AId: string): TRecorderXmlDbNode;
    function NodeCount: Integer;
    function Nodes(AIndex: Integer): TRecorderXmlDbNode;
    property BasePath: string read fBasePath;
  end;

implementation

uses DOM, XMLRead, XMLWrite;

constructor TRecorderXmlDbNode.Create(const AKind: string);
begin
  inherited Create;
  fKind := AKind;
  fProperties := TStringList.Create;
  fProperties.NameValueSeparator := '=';
end;

destructor TRecorderXmlDbNode.Destroy;
begin
  fProperties.Free;
  inherited Destroy;
end;

constructor TRecorderXmlDatabase.Create(const ABasePath: string);
begin
  inherited Create;
  fBasePath := IncludeTrailingPathDelimiter(ExpandFileName(ABasePath));
  fNodes := TObjectList.Create(True);
end;

destructor TRecorderXmlDatabase.Destroy;
begin
  fNodes.Free;
  inherited Destroy;
end;

function NewXmlId: string;
var lGuid: TGuid;
begin
  CreateGUID(lGuid);
  Result := GUIDToString(lGuid);
end;

function TRecorderXmlDatabase.UniqueRelativePath(const AParentPath,
  APrefix: string): string;
var I: Integer;
begin
  I := 1;
  repeat
    Result := AParentPath + Format('%s_%.4d', [APrefix, I]);
    Inc(I);
  until not FileExists(fBasePath + Result + '.xml') and
    not DirectoryExists(fBasePath + Result);
end;

procedure TRecorderXmlDatabase.SaveNode(ANode: TRecorderXmlDbNode);
var
  lDocument: TXMLDocument;
  lRoot, lProperty: TDOMElement;
  lFileName: string;
  I: Integer;
begin
  if ANode = nil then raise ERecorderXmlDatabase.Create('XML node is nil');
  lFileName := fBasePath + ANode.RelativePath + '.xml';
  ForceDirectories(ExtractFileDir(lFileName));
  ForceDirectories(fBasePath + ANode.RelativePath);
  lDocument := TXMLDocument.Create;
  try
    lRoot := lDocument.CreateElement('MeraDbNode');
    lRoot.SetAttribute('Class', ANode.Kind);
    lRoot.SetAttribute('Id', ANode.Id);
    lRoot.SetAttribute('Name', ANode.Name);
    lRoot.SetAttribute('ParentId', ANode.ParentId);
    lRoot.SetAttribute('Path', ANode.RelativePath);
    lDocument.AppendChild(lRoot);
    for I := 0 to ANode.Properties.Count - 1 do
    begin
      lProperty := lDocument.CreateElement('Property');
      lProperty.SetAttribute('Name', ANode.Properties.Names[I]);
      lProperty.SetAttribute('Value', ANode.Properties.ValueFromIndex[I]);
      lRoot.AppendChild(lProperty);
    end;
    WriteXMLFile(lDocument, lFileName);
  finally
    lDocument.Free;
  end;
end;

procedure TRecorderXmlDatabase.ScanDirectory(const ADirectory,
  AParentId: string);
var
  lSearch: TSearchRec;
  lDocument: TXMLDocument;
  lRoot: TDOMElement;
  lChild: TDOMNode;
  lNode, lParent: TRecorderXmlDbNode;
  lKind, lParentKind, lFileName: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(ADirectory) + '*.xml', faAnyFile,
    lSearch) <> 0 then Exit;
  try
    repeat
      lFileName := IncludeTrailingPathDelimiter(ADirectory) + lSearch.Name;
      lDocument := nil;
      try
        ReadXMLFile(lDocument, lFileName);
        lRoot := lDocument.DocumentElement;
        if (lRoot = nil) or (lRoot.TagName <> 'MeraDbNode') then Continue;
        lKind := lRoot.GetAttribute('Class');
        lParent := FindNode(AParentId);
        if lParent = nil then lParentKind := '' else lParentKind := lParent.Kind;
        if not AcceptParent(lKind, lParentKind) then Continue;
        lNode := CreateNode(lKind);
        if lNode = nil then Continue;
        lNode.Id := lRoot.GetAttribute('Id');
        lNode.Name := lRoot.GetAttribute('Name');
        lNode.ParentId := AParentId;
        lNode.RelativePath := lRoot.GetAttribute('Path');
        lChild := lRoot.FirstChild;
        while lChild <> nil do
        begin
          if (lChild is TDOMElement) and
            (TDOMElement(lChild).TagName = 'Property') then
            lNode.Properties.Values[TDOMElement(lChild).GetAttribute('Name')] :=
              TDOMElement(lChild).GetAttribute('Value');
          lChild := lChild.NextSibling;
        end;
        fNodes.Add(lNode);
        if DirectoryExists(fBasePath + lNode.RelativePath) then
          ScanDirectory(fBasePath + lNode.RelativePath, lNode.Id);
      finally
        lDocument.Free;
      end;
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

procedure TRecorderXmlDatabase.Open;
begin
  if Trim(fBasePath) = '' then
    raise ERecorderXmlDatabase.Create('XML database path is empty');
  ForceDirectories(fBasePath);
  Reload;
end;

procedure TRecorderXmlDatabase.Reload;
begin
  fNodes.Clear;
  if DirectoryExists(fBasePath) then ScanDirectory(fBasePath, '');
end;

function TRecorderXmlDatabase.AddNode(const AKind, AParentId, AParentPath,
  APrefix, AName: string): TRecorderXmlDbNode;
var lParent: TRecorderXmlDbNode; lParentKind: string;
begin
  if Trim(AName) = '' then raise ERecorderXmlDatabase.Create('Node name is empty');
  lParent := FindNode(AParentId);
  if lParent = nil then lParentKind := '' else lParentKind := lParent.Kind;
  if (AParentId <> '') and (lParent = nil) then
    raise ERecorderXmlDatabase.CreateFmt('Parent not found: %s', [AParentId]);
  if not AcceptParent(AKind, lParentKind) then
    raise ERecorderXmlDatabase.CreateFmt('Invalid %s parent: %s', [AKind, lParentKind]);
  Result := CreateNode(AKind);
  if Result = nil then raise ERecorderXmlDatabase.CreateFmt('Unknown node: %s', [AKind]);
  Result.Id := NewXmlId;
  Result.Name := Trim(AName);
  Result.ParentId := AParentId;
  Result.RelativePath := UniqueRelativePath(AParentPath, APrefix);
  fNodes.Add(Result);
  SaveNode(Result);
end;

function TRecorderXmlDatabase.FindNode(const AId: string): TRecorderXmlDbNode;
var I: Integer;
begin
  for I := 0 to fNodes.Count - 1 do
    if SameText(TRecorderXmlDbNode(fNodes[I]).Id, AId) then
      Exit(TRecorderXmlDbNode(fNodes[I]));
  Result := nil;
end;

function TRecorderXmlDatabase.NodeCount: Integer;
begin Result := fNodes.Count; end;

function TRecorderXmlDatabase.Nodes(AIndex: Integer): TRecorderXmlDbNode;
begin Result := TRecorderXmlDbNode(fNodes[AIndex]); end;

end.
