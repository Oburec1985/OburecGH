program RecorderMdbTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses Classes, SysUtils, DateUtils, uRecorderXmlDatabase, uRecorderMdbTypes,
  uRecorderMdbRepository;

type
  { Proof that the core is not tied to Object/Test/Registration. }
  TBladeLikeDatabase = class(TRecorderXmlDatabase)
  protected
    function CreateNode(const AKind: string): TRecorderXmlDbNode; override;
    function AcceptParent(const AKind, AParentKind: string): Boolean; override;
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

begin
  try Run; TestTypeCatalog; WriteLn('RESULT recorder-mdb passed');
  except on E: Exception do begin WriteLn(StdErr, E.ClassName, ': ', E.Message); Halt(1); end; end;
end.
