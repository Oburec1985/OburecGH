unit uRecorderMdbManager;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderSqlDbTypes, uRecorderSqlDbManager,
  uRecorderMdbTypes, uRecorderMdbRepository;

type
  { Owns the operator's current product/test selection and publishes only a
    validated immutable context to the SQL recording manager. }
  TRecorderMdbManager = class
  private
    fRepository: TRecorderMdbRepository;
    fSqlDbManager: TRecorderSqlDbManager;
    fContext: TMdbMeasurementContext;
    procedure RestoreContext(AConfig: TRecorderSqlDbConfig);
  public
    constructor Create(AConfig: TRecorderSqlDbConfig;
      ASqlDbManager: TRecorderSqlDbManager);
    destructor Destroy; override;
    procedure SelectContext(const AObject: TMdbObjectInfo;
      const ATest: TMdbTestInfo);
    procedure ClearContext;
    property Context: TMdbMeasurementContext read fContext;
    property Repository: TRecorderMdbRepository read fRepository;
  end;

implementation

constructor TRecorderMdbManager.Create(AConfig: TRecorderSqlDbConfig;
  ASqlDbManager: TRecorderSqlDbManager);
begin
  inherited Create;
  fSqlDbManager := ASqlDbManager;
  fRepository := TRecorderMdbRepository.Create(AConfig);
  RestoreContext(AConfig);
end;

procedure TRecorderMdbManager.RestoreContext(AConfig: TRecorderSqlDbConfig);
var
  lObjects: TMdbObjectInfos;
  lTests: TMdbTestInfos;
  I, J: Integer;
begin
  fContext := Default(TMdbMeasurementContext);
  if (AConfig = nil) or (Trim(AConfig.MdbObjectId) = '') or
    (Trim(AConfig.MdbTestId) = '') then Exit;
  fRepository.ListObjects(lObjects);
  for I := 0 to High(lObjects) do
    if lObjects[I].Id = AConfig.MdbObjectId then
    begin
      fRepository.ListTests(lObjects[I].Id, lTests);
      for J := 0 to High(lTests) do
        if lTests[J].Id = AConfig.MdbTestId then
        begin
          fContext.ObjectId := lObjects[I].Id;
          fContext.ObjectName := lObjects[I].Name;
          fContext.TestId := lTests[J].Id;
          fContext.TestName := lTests[J].Name;
          Exit;
        end;
      Exit;
    end;
end;

destructor TRecorderMdbManager.Destroy;
begin
  fRepository.Free;
  inherited Destroy;
end;

procedure TRecorderMdbManager.SelectContext(const AObject: TMdbObjectInfo;
  const ATest: TMdbTestInfo);
var
  lContext: TMdbMeasurementContext;
begin
  lContext.ObjectId := AObject.Id;
  lContext.TestId := ATest.Id;
  lContext.ObjectName := AObject.Name;
  lContext.TestName := ATest.Name;
  lContext.RequireValid;
  if ATest.ObjectId <> AObject.Id then
    raise EMdbError.Create('Selected test belongs to another object');
  if not fRepository.ContextExists(lContext.ObjectId, lContext.TestId) then
    raise EMdbError.Create('Selected measurement context no longer exists');
  if fSqlDbManager <> nil then
    fSqlDbManager.PersistMeasurementContext(lContext.ObjectId,
      lContext.TestId);
  fContext := lContext;
end;

procedure TRecorderMdbManager.ClearContext;
begin
  if fSqlDbManager <> nil then
    fSqlDbManager.PersistMeasurementContext('', '');
  fContext := Default(TMdbMeasurementContext);
end;

end.
