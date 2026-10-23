program RecorderMdbTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses Classes, SysUtils, DateUtils, uRecorderXmlDatabase, uRecorderMdbTypes,
  uRecorderMdbRepository, uRecorderMdbManager;

type
  TContextObserver = class
    Count: Integer;
    procedure Changed(Sender: TObject);
  end;

  { Proof that the core is not tied to Object/Test/Registration. }
  TBladeLikeDatabase = class(TRecorderXmlDatabase)
  protected
    function CreateNode(const AKind: string): TRecorderXmlDbNode; override;
    function AcceptParent(const AKind, AParentKind: string): Boolean; override;
  end;

procedure TContextObserver.Changed(Sender: TObject);
begin
  Inc(Count);
end;

function TBladeLikeDatabase.CreateNode(const AKind: string): TRecorderXmlDbNode;
begin
  if (AKind = 'Turbine') or (AKind = 'Stage') or (AKind = 'Blade') then
    Result := TRecorderXmlDbNode.Create(AKind) else Result := nil;
end;

function TBladeLikeDatabase.AcceptParent(const AKind,
  AParentKind: string): Boolean;
begin
  Result := ((AKind = 'Turbine') and (AParentKind = '')) or
    ((AKind = 'Stage') and (AParentKind = 'Turbine')) or
    ((AKind = 'Blade') and (AParentKind = 'Stage'));
end;

procedure Check(AValue: Boolean; const AMessage: string);
begin if not AValue then raise Exception.Create('CHECK FAILED: ' + AMessage); end;

procedure Run;
var
  lRoot, lBladeRoot: string;
  lRepository: TRecorderMdbRepository;
  lBladeDb: TBladeLikeDatabase;
  lObjects: TMdbObjectInfos;
  lTests: TMdbTestInfos;
  lMeasurements: TMdbMeasurementInfos;
  lObjectId, lTestId, lRegistrationId: string;
  lTurbine, lStage, lBlade: TRecorderXmlDbNode;
begin
  lRoot := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorderlnx-mdb-xml-' + IntToStr(GetProcessID);
  lBladeRoot := lRoot + '-blade';
  lRepository := TRecorderMdbRepository.Create(lRoot);
  try
    lRepository.Open;
    lObjectId := lRepository.CreateObject('Изделие 01', 'Редуктор', 'SN-01');
    lTestId := lRepository.CreateTest(lObjectId, 'Испытание 01',
      'TestType01', LocalTimeToUniversal(Now));
    lRegistrationId := lRepository.CreateRegistration(lObjectId, lTestId,
      'Reg_0001', 'host-a\measure-001', LocalTimeToUniversal(Now));
    Check(lRegistrationId <> '', 'registration id');
    Check(lRepository.FindNode(lObjectId).RelativePath = 'Изделие 01',
      'object directory matches entered name');
    Check(lRepository.FindNode(lRegistrationId).RelativePath =
      'Изделие 01' + PathDelim + 'Испытание 01' + PathDelim + 'Reg_0001',
      'registration directory preserves all entered names');
  finally lRepository.Free; end;

  lRepository := TRecorderMdbRepository.Create(lRoot);
  try
    lRepository.Open;
    lRepository.ListObjects(lObjects);
    Check((Length(lObjects) = 1) and (lObjects[0].SerialNumber = 'SN-01'),
      'object XML roundtrip');
    lRepository.ListTests(lObjectId, lTests);
    Check((Length(lTests) = 1) and (lTests[0].Id = lTestId), 'test XML roundtrip');
    lRepository.ListMeasurements(lObjectId, lTestId, lMeasurements);
    Check((Length(lMeasurements) = 1) and
      (lMeasurements[0].DataPath = 'host-a\measure-001'),
      'registration path roundtrip');
  finally lRepository.Free; end;

  lBladeDb := TBladeLikeDatabase.Create(lBladeRoot);
  try
    lBladeDb.Open;
    lTurbine := lBladeDb.AddNode('Turbine', '', '', 'Turbine', 'T-01');
    lStage := lBladeDb.AddNode('Stage', lTurbine.Id,
      IncludeTrailingPathDelimiter(lTurbine.RelativePath), 'Stage', 'Stage-1');
    lBlade := lBladeDb.AddNode('Blade', lStage.Id,
      IncludeTrailingPathDelimiter(lStage.RelativePath), 'Blade', 'Blade-1');
    lBlade.Properties.Values['Frequency'] := '123.4';
    lBladeDb.SaveNode(lBlade);
  finally lBladeDb.Free; end;
  lBladeDb := TBladeLikeDatabase.Create(lBladeRoot);
  try
    lBladeDb.Open;
    Check((lBladeDb.NodeCount = 3) and
      (lBladeDb.Nodes(2).Properties.Values['Frequency'] = '123.4'),
      'alternative hierarchy uses common XML base');
  finally lBladeDb.Free; end;
end;

procedure TestTypeCatalog;
var lRepository: TRecorderMdbRepository; lFields, lTypes: TStringList;
  lPath, lFirst, lSecond: string; lNode: TRecorderXmlDbNode;
begin
  lPath := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-mdb-types-' + IntToStr(GetProcessID);
  lFields := TStringList.Create;
  lTypes := TStringList.Create;
  lRepository := TRecorderMdbRepository.Create(lPath);
  try
    lRepository.Open;
    lFirst := lRepository.CreateObject('First', 'Motor', 'A');
    lSecond := lRepository.CreateObject('Second', 'Other', 'B');
    lFields.Add('Power'); lFields.Add('Speed'); lFields.Add('Power');
    lRepository.SaveTypeProperties('Motor', lFields);
    lNode := lRepository.FindNode(lFirst);
    lNode.Properties.Values['User.Power'] := '100';
    lNode.Properties.Values['PrivateMetadata'] := 'keep';
    lRepository.SaveNode(lNode);
    lRepository.UpdateObject(lSecond, 'Second', 'Motor', 'B');
    Check(lRepository.FindNode(lSecond).Properties.IndexOfName('User.Power') >= 0,
      'assigned type imports fields');
    lRepository.FindNode(lSecond).Properties.Values['User.Power'] := '200';
    lFields.Clear; lFields.Add('Power'); lFields.Add('Torque');
    lRepository.SaveTypeProperties('motor', lFields);
    Check(lNode.Properties.Values['User.Power'] = '100', 'first value retained');
    Check(lRepository.FindNode(lSecond).Properties.Values['User.Power'] = '200',
      'second independent value retained');
    Check(lNode.Properties.IndexOfName('User.Speed') < 0, 'removed field synced');
    Check(lNode.Properties.Values['PrivateMetadata'] = 'keep', 'metadata retained');
    lRepository.ListObjectTypes(lTypes);
    Check(lTypes.Count = 2, 'case insensitive unique types');
    lRepository.Reload;
    lRepository.LoadTypeProperties('MOTOR', lFields);
    Check((lFields.Count = 2) and (lFields[1] = 'Torque'), 'schema persisted');
    Check(lRepository.FindNode(lFirst).Properties.Values['User.Power'] = '100',
      'object values persisted');
    lFields.Clear; lFields.Add('Мощность');
    lRepository.SaveTypeProperties('Редуктор', lFields);
    lRepository.LoadTypeProperties('Редуктор', lFields);
    Check((lFields.Count = 1) and (lFields[0] = 'Мощность'),
      'UTF8 catalog names roundtrip');
  finally lRepository.Free; lTypes.Free; lFields.Free; end;
end;

procedure TestContextNotifications;
var
  lManager: TRecorderMdbManager;
  lObserver: TContextObserver;
  lPath, lObject, lTest: string;
  lObjects: TMdbObjectInfos;
  lTests: TMdbTestInfos;
  lRevision: QWord;
begin
  lPath := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-mdb-context-' + IntToStr(GetProcessID);
  lManager := TRecorderMdbManager.Create(lPath, '', '');
  lObserver := TContextObserver.Create;
  try
    lObject := lManager.Repository.CreateObject('Context', '', '');
    lTest := lManager.Repository.CreateTest(lObject, 'Test', '', Now);
    lManager.Repository.ListObjects(lObjects);
    lManager.Repository.ListTests(lObject, lTests);
    SubscribeRecorderMdbContextChanged(@lObserver.Changed);
    SubscribeRecorderMdbContextChanged(@lObserver.Changed);
    lRevision := RecorderMdbContextRevision;
    lManager.SelectContext(lObjects[0], lTests[0]);
    Check(lObserver.Count = 1, 'context notification deduplicates subscribers');
    Check(RecorderMdbContextRevision > lRevision, 'context revision advances');
    Check(Pos('Context', RecorderMdbActiveObjectDirectory) > 0,
      'committed context visible before notification processing');
    lManager.ClearContext;
    Check(lObserver.Count = 2, 'clear context notification');
    lManager.SelectContext(lObjects[0], lTests[0]);
    lManager.ChangeBasePath(lPath + '-new');
    Check((lObserver.Count = 4) and
      (RecorderMdbActiveObjectDirectory = ''), 'base path invalidates context');
    UnsubscribeRecorderMdbContextChanged(@lObserver.Changed);
    NotifyRecorderMdbContextChanged;
    Check(lObserver.Count = 4, 'unsubscribed owner no longer called');
  finally
    UnsubscribeRecorderMdbContextChanged(@lObserver.Changed);
    lObserver.Free;
    lManager.Free;
  end;
end;

procedure CheckLegacyBase;
var lDb: TRecorderMdbRepository; lObjects: TMdbObjectInfos;
  lTests: TMdbTestInfos; lRegs: TMdbMeasurementInfos; I: Integer; lFound: Boolean;
begin
  if ParamCount = 0 then Exit;
  lDb := TRecorderMdbRepository.Create(ParamStr(1));
  try
    lDb.Open;
    lDb.ListObjects(lObjects);
    lFound := False;
    for I := 0 to High(lObjects) do
      if lObjects[I].Name = 'Object_001' then
      begin
        Check(lDb.FindNode(lObjects[I].Id).RelativePath = 'Object_001', 'legacy object path');
        lDb.ListTests(lObjects[I].Id, lTests);
        Check((Length(lTests) = 1) and (lTests[0].Name = 'Test_001'), 'legacy test');
        lDb.ListMeasurements(lObjects[I].Id, lTests[0].Id, lRegs);
        Check((Length(lRegs) = 1) and (lRegs[0].Reason = 'Reg_001'), 'legacy registration');
        lFound := True;
      end;
    Check(lFound, 'legacy object visible');
  finally
    lDb.Free;
  end;
end;

begin
  try Run; TestTypeCatalog; TestContextNotifications; CheckLegacyBase;
    WriteLn('RESULT recorder-mdb passed');
  except on E: Exception do begin WriteLn(StdErr, E.ClassName, ': ', E.Message); Halt(1); end; end;
end.
