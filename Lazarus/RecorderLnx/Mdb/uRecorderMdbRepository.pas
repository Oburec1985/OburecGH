unit uRecorderMdbRepository;

{ MDB domain repository over the shared XML tree. ObjectTypes.xml in the
  database root owns reusable schemas; User.* values belong to each object.
  Applying a schema changes only user property names, not identity/metadata. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, DOM, uRecorderXmlDatabase, uRecorderMdbTypes;

const
  CMdbObjectKind = 'MdbObject';
  CMdbTestKind = 'MdbTest';
  CMdbRegistrationKind = 'MdbRegistration';

type
  { Object/Test/Registration is one specialization, not the XML base itself. }
  TRecorderMdbRepository = class(TRecorderXmlDatabase)
  private
    function ReadTypeCatalog: TXMLDocument;
    function FindType(ADocument: TXMLDocument; const AName: string): TDOMElement;
    procedure ApplyTypeProperties(ANode: TRecorderXmlDbNode; AFields: TStrings);
    procedure EnsureObjectType(ANode: TRecorderXmlDbNode);
  protected
    function CreateNode(const AKind: string): TRecorderXmlDbNode; override;
    function AcceptParent(const AKind, AParentKind: string): Boolean; override;
  public
    procedure ListObjectTypes(AItems: TStrings);
    procedure LoadTypeProperties(const AType: string; AFields: TStrings);
    { Synchronizes property names for every object of this type, never values. }
    procedure SaveTypeProperties(const AType: string; AFields: TStrings);
    function CreateObject(const AName, AObjectType,
      ASerialNumber: string): string;
    procedure UpdateObject(const AId, AName, AObjectType,
      ASerialNumber: string);
    procedure ListObjects(out AItems: TMdbObjectInfos);
    function CreateTest(const AObjectId, AName, AMetadataJson: string;
      AStartedAtUtc: Double): string;
    procedure FinishTest(const ATestId: string; AFinishedAtUtc: Double);
    procedure ListTests(const AObjectId: string; out AItems: TMdbTestInfos);
    function ContextExists(const AObjectId, ATestId: string): Boolean;
    function CreateRegistration(const AObjectId, ATestId, AName,
      ADataPath: string; AStartedAtUtc: Double): string;
    procedure ListMeasurements(const AObjectId, ATestId: string;
      out AItems: TMdbMeasurementInfos);
  end;

implementation

uses XMLRead, XMLWrite;

function TRecorderMdbRepository.ReadTypeCatalog: TXMLDocument;
begin
  Result := nil;
  if FileExists(BasePath + 'ObjectTypes.xml') then
    ReadXMLFile(Result, BasePath + 'ObjectTypes.xml')
  else
  begin
    Result := TXMLDocument.Create;
    Result.AppendChild(Result.CreateElement('ObjectTypes'));
  end;
end;

function TRecorderMdbRepository.FindType(ADocument: TXMLDocument;
  const AName: string): TDOMElement;
var lNode: TDOMNode;
begin
  Result := nil;
  lNode := ADocument.DocumentElement.FirstChild;
  while lNode <> nil do
  begin
    if (lNode is TDOMElement) and (lNode.NodeName = 'Type') and
      SameText(UTF8Encode(TDOMElement(lNode).GetAttribute('Name')), Trim(AName)) then
      Exit(TDOMElement(lNode));
    lNode := lNode.NextSibling;
  end;
end;

procedure TRecorderMdbRepository.ListObjectTypes(AItems: TStrings);
var lDocument: TXMLDocument; lNode: TDOMNode; I: Integer; lName: string;
begin
  AItems.Clear;
  lDocument := ReadTypeCatalog;
  try
    lNode := lDocument.DocumentElement.FirstChild;
    while lNode <> nil do
    begin
      if (lNode is TDOMElement) and (lNode.NodeName = 'Type') then
        AItems.Add(UTF8Encode(TDOMElement(lNode).GetAttribute('Name')));
      lNode := lNode.NextSibling;
    end;
    // Existing databases may contain typed objects before a catalog existed.
    for I := 0 to NodeCount - 1 do
      if SameText(Nodes(I).Kind, CMdbObjectKind) then
      begin
        lName := Trim(Nodes(I).Properties.Values['ObjectType']);
        if (lName <> '') and (AItems.IndexOf(lName) < 0) then AItems.Add(lName);
      end;
  finally lDocument.Free; end;
end;

procedure TRecorderMdbRepository.LoadTypeProperties(const AType: string;
  AFields: TStrings);
var lDocument: TXMLDocument; lType: TDOMElement; lNode: TDOMNode;
begin
  AFields.Clear;
  lDocument := ReadTypeCatalog;
  try
    lType := FindType(lDocument, AType);
    if lType = nil then Exit;
    lNode := lType.FirstChild;
    while lNode <> nil do
    begin
      if (lNode is TDOMElement) and (lNode.NodeName = 'Property') then
        AFields.Add(UTF8Encode(TDOMElement(lNode).GetAttribute('Name')));
      lNode := lNode.NextSibling;
    end;
  finally lDocument.Free; end;
end;

procedure TRecorderMdbRepository.ApplyTypeProperties(ANode: TRecorderXmlDbNode;
  AFields: TStrings);
var I: Integer; lName: string;
begin
  for I := ANode.Properties.Count - 1 downto 0 do
  begin
    lName := ANode.Properties.Names[I];
    if (Copy(lName, 1, 5) = 'User.') and
      (AFields.IndexOf(Copy(lName, 6, MaxInt)) < 0) then
      ANode.Properties.Delete(I);
  end;
  for I := 0 to AFields.Count - 1 do
  begin
    lName := 'User.' + AFields[I];
    // Add explicitly: TStringList.Values removes a key assigned an empty value.
    if ANode.Properties.IndexOfName(lName) < 0 then
      ANode.Properties.Add(lName + '=');
  end;
end;

procedure TRecorderMdbRepository.SaveTypeProperties(const AType: string;
  AFields: TStrings);
var lDocument: TXMLDocument; lType, lProperty: TDOMElement;
  lFields: TStringList; I: Integer; lName: string; lObject: TRecorderXmlDbNode;
begin
  if Trim(AType) = '' then Exit;
  lDocument := ReadTypeCatalog;
  lFields := TStringList.Create;
  try
    for I := 0 to AFields.Count - 1 do
    begin
      lName := Trim(AFields[I]);
      if (lName <> '') and (lFields.IndexOf(lName) < 0) then lFields.Add(lName);
    end;
    lType := FindType(lDocument, AType);
    if lType = nil then
    begin
      lType := lDocument.CreateElement('Type');
      lType.SetAttribute('Name', UTF8Decode(Trim(AType)));
      lDocument.DocumentElement.AppendChild(lType);
    end;
    while lType.FirstChild <> nil do lType.RemoveChild(lType.FirstChild).Free;
    for I := 0 to lFields.Count - 1 do
    begin
      lProperty := lDocument.CreateElement('Property');
      lProperty.SetAttribute('Name', UTF8Decode(lFields[I]));
      lType.AppendChild(lProperty);
    end;
    WriteXMLFile(lDocument, BasePath + 'ObjectTypes.xml');
    for I := 0 to NodeCount - 1 do
    begin
      lObject := Nodes(I);
      if SameText(lObject.Kind, CMdbObjectKind) and
        SameText(lObject.Properties.Values['ObjectType'], Trim(AType)) then
      begin
        ApplyTypeProperties(lObject, lFields);
        SaveNode(lObject);
      end;
    end;
  finally lFields.Free; lDocument.Free; end;
end;

procedure TRecorderMdbRepository.EnsureObjectType(ANode: TRecorderXmlDbNode);
var lDocument: TXMLDocument; lFields: TStringList; lType: string;
  lExists: Boolean;
begin
  lType := Trim(ANode.Properties.Values['ObjectType']);
  if lType = '' then Exit;
  lDocument := ReadTypeCatalog;
  try lExists := FindType(lDocument, lType) <> nil;
  finally lDocument.Free; end;
  lFields := TStringList.Create;
  try
    if lExists then LoadTypeProperties(lType, lFields)
    else SaveTypeProperties(lType, lFields);
    ApplyTypeProperties(ANode, lFields);
  finally lFields.Free; end;
end;

function FloatText(AValue: Double): string;
begin Result := FloatToStr(AValue, DefaultFormatSettings); end;

function TextFloat(const AValue: string): Double;
begin Result := StrToFloatDef(AValue, 0, DefaultFormatSettings); end;

function TRecorderMdbRepository.CreateNode(const AKind: string): TRecorderXmlDbNode;
begin
  if SameText(AKind, CMdbObjectKind) or SameText(AKind, CMdbTestKind) or
    SameText(AKind, CMdbRegistrationKind) then
    Result := TRecorderXmlDbNode.Create(AKind)
  else Result := nil;
end;

function TRecorderMdbRepository.AcceptParent(const AKind,
  AParentKind: string): Boolean;
begin
  Result := (SameText(AKind, CMdbObjectKind) and (AParentKind = '')) or
    (SameText(AKind, CMdbTestKind) and SameText(AParentKind, CMdbObjectKind)) or
    (SameText(AKind, CMdbRegistrationKind) and SameText(AParentKind, CMdbTestKind));
end;

function TRecorderMdbRepository.CreateObject(const AName, AObjectType,
  ASerialNumber: string): string;
var lNode: TRecorderXmlDbNode;
begin
  lNode := AddNode(CMdbObjectKind, '', '', 'Object', AName);
  lNode.Properties.Values['ObjectType'] := Trim(AObjectType);
  lNode.Properties.Values['SerialNumber'] := Trim(ASerialNumber);
  EnsureObjectType(lNode);
  SaveNode(lNode); Result := lNode.Id;
end;

procedure TRecorderMdbRepository.UpdateObject(const AId, AName, AObjectType,
  ASerialNumber: string);
var lNode: TRecorderXmlDbNode;
begin
  lNode := FindNode(AId);
  if (lNode = nil) or not SameText(lNode.Kind, CMdbObjectKind) then
    raise EMdbError.CreateFmt('Object not found: %s', [AId]);
  lNode.Name := Trim(AName);
  lNode.Properties.Values['ObjectType'] := Trim(AObjectType);
  lNode.Properties.Values['SerialNumber'] := Trim(ASerialNumber);
  EnsureObjectType(lNode);
  SaveNode(lNode);
end;

procedure TRecorderMdbRepository.ListObjects(out AItems: TMdbObjectInfos);
var I, J: Integer; lNode: TRecorderXmlDbNode;
begin
  SetLength(AItems, 0); J := 0;
  for I := 0 to NodeCount - 1 do
  begin
    lNode := Nodes(I);
    if not SameText(lNode.Kind, CMdbObjectKind) then Continue;
    SetLength(AItems, J + 1);
    AItems[J].Id := lNode.Id; AItems[J].Name := lNode.Name;
    AItems[J].ObjectType := lNode.Properties.Values['ObjectType'];
    AItems[J].SerialNumber := lNode.Properties.Values['SerialNumber']; Inc(J);
  end;
end;

function TRecorderMdbRepository.CreateTest(const AObjectId, AName,
  AMetadataJson: string; AStartedAtUtc: Double): string;
var lParent, lNode: TRecorderXmlDbNode;
begin
  lParent := FindNode(AObjectId);
  if (lParent = nil) or not SameText(lParent.Kind, CMdbObjectKind) then
    raise EMdbError.CreateFmt('Test object not found: %s', [AObjectId]);
  lNode := AddNode(CMdbTestKind, AObjectId,
    IncludeTrailingPathDelimiter(lParent.RelativePath), 'Test', AName);
  lNode.Properties.Values['Metadata'] := AMetadataJson;
  lNode.Properties.Values['StartedAtUtc'] := FloatText(AStartedAtUtc);
  SaveNode(lNode); Result := lNode.Id;
end;

procedure TRecorderMdbRepository.FinishTest(const ATestId: string;
  AFinishedAtUtc: Double);
var lNode: TRecorderXmlDbNode;
begin
  lNode := FindNode(ATestId);
  if (lNode = nil) or not SameText(lNode.Kind, CMdbTestKind) then
    raise EMdbError.CreateFmt('Test not found: %s', [ATestId]);
  lNode.Properties.Values['FinishedAtUtc'] := FloatText(AFinishedAtUtc);
  SaveNode(lNode);
end;

procedure TRecorderMdbRepository.ListTests(const AObjectId: string;
  out AItems: TMdbTestInfos);
var I, J: Integer; lNode: TRecorderXmlDbNode;
begin
  SetLength(AItems, 0); J := 0;
  for I := 0 to NodeCount - 1 do
  begin
    lNode := Nodes(I);
    if not SameText(lNode.Kind, CMdbTestKind) or
      not SameText(lNode.ParentId, AObjectId) then Continue;
    SetLength(AItems, J + 1);
    AItems[J].Id := lNode.Id; AItems[J].ObjectId := AObjectId;
    AItems[J].Name := lNode.Name;
    AItems[J].StartedAtUtc := TextFloat(lNode.Properties.Values['StartedAtUtc']);
    AItems[J].FinishedAtUtc := TextFloat(lNode.Properties.Values['FinishedAtUtc']);
    AItems[J].MetadataJson := lNode.Properties.Values['Metadata']; Inc(J);
  end;
end;

function TRecorderMdbRepository.ContextExists(const AObjectId,
  ATestId: string): Boolean;
var lTest: TRecorderXmlDbNode;
begin
  lTest := FindNode(ATestId);
  Result := (lTest <> nil) and SameText(lTest.Kind, CMdbTestKind) and
    SameText(lTest.ParentId, AObjectId);
end;

function TRecorderMdbRepository.CreateRegistration(const AObjectId, ATestId,
  AName, ADataPath: string; AStartedAtUtc: Double): string;
var lTest, lNode: TRecorderXmlDbNode;
begin
  if not ContextExists(AObjectId, ATestId) then
    raise EMdbError.Create('Registration context does not exist');
  lTest := FindNode(ATestId);
  lNode := AddNode(CMdbRegistrationKind, ATestId,
    IncludeTrailingPathDelimiter(lTest.RelativePath), 'Reg', AName);
  lNode.Properties.Values['ObjectId'] := AObjectId;
  lNode.Properties.Values['DataPath'] := ADataPath;
  lNode.Properties.Values['StartedAtUtc'] := FloatText(AStartedAtUtc);
  lNode.Properties.Values['Status'] := 'created';
  SaveNode(lNode); Result := lNode.Id;
end;

procedure TRecorderMdbRepository.ListMeasurements(const AObjectId,
  ATestId: string; out AItems: TMdbMeasurementInfos);
var I, J: Integer; lNode: TRecorderXmlDbNode;
begin
  SetLength(AItems, 0); J := 0;
  for I := 0 to NodeCount - 1 do
  begin
    lNode := Nodes(I);
    if not SameText(lNode.Kind, CMdbRegistrationKind) or
      not SameText(lNode.ParentId, ATestId) or
      not SameText(lNode.Properties.Values['ObjectId'], AObjectId) then Continue;
    SetLength(AItems, J + 1);
    AItems[J].RegistrationId := lNode.Id; AItems[J].ObjectId := AObjectId;
    AItems[J].TestId := ATestId;
    AItems[J].StartedAtUtc := TextFloat(lNode.Properties.Values['StartedAtUtc']);
    AItems[J].FinishedAtUtc := TextFloat(lNode.Properties.Values['FinishedAtUtc']);
    AItems[J].Status := lNode.Properties.Values['Status'];
    AItems[J].Reason := lNode.Name;
    AItems[J].DataPath := lNode.Properties.Values['DataPath']; Inc(J);
  end;
end;

end.
