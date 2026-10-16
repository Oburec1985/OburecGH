unit uRecorderMdbManager;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses SysUtils, uRecorderMdbTypes, uRecorderMdbRepository;

type
  { Owns one XML measurement-base session. Recorder/RcPan paths are attached
    through repository registrations, not discovered through SQL. }
  TRecorderMdbManager = class
  private
    fRepository: TRecorderMdbRepository;
    fContext: TMdbMeasurementContext;
  public
    constructor Create(const ABasePath, AObjectId, ATestId: string);
    destructor Destroy; override;
    procedure SelectContext(const AObject: TMdbObjectInfo;
      const ATest: TMdbTestInfo);
    procedure ClearContext;
    procedure ChangeBasePath(const APath: string);
    property Context: TMdbMeasurementContext read fContext;
    property Repository: TRecorderMdbRepository read fRepository;
  end;

{ UI-thread context shared by consumers on other mnemonic pages. The last
  successfully selected database context wins; its manager retains ownership. }
function RecorderMdbActiveObjectDirectory: string;

implementation

uses uRecorderXmlDatabase;

var ActiveManager: TRecorderMdbManager = nil;

function RecorderMdbActiveObjectDirectory: string;
var Node: TRecorderXmlDbNode;
begin
  Result := '';
  if ActiveManager = nil then Exit;
  Node := ActiveManager.Repository.FindNode(ActiveManager.Context.ObjectId);
  if Node <> nil then
    Result := IncludeTrailingPathDelimiter(ActiveManager.Repository.BasePath + Node.RelativePath);
end;

procedure TRecorderMdbManager.ChangeBasePath(const APath: string);
var lRepository: TRecorderMdbRepository;
begin
  if Trim(APath) = '' then raise EMdbError.Create('Укажите каталог базы');
  lRepository := TRecorderMdbRepository.Create(APath);
  try
    lRepository.Open;
  except
    lRepository.Free;
    raise;
  end;
  fRepository.Free;
  fRepository := lRepository;
  ClearContext;
end;

constructor TRecorderMdbManager.Create(const ABasePath, AObjectId,
  ATestId: string);
var lObjects: TMdbObjectInfos; lTests: TMdbTestInfos; I, J: Integer;
begin
  inherited Create;
  fRepository := TRecorderMdbRepository.Create(ABasePath);
  fRepository.Open;
  fContext := Default(TMdbMeasurementContext);
  if (AObjectId = '') or (ATestId = '') then Exit;
  fRepository.ListObjects(lObjects);
  for I := 0 to High(lObjects) do
    if lObjects[I].Id = AObjectId then
    begin
      fRepository.ListTests(AObjectId, lTests);
      for J := 0 to High(lTests) do
        if lTests[J].Id = ATestId then
        begin
          SelectContext(lObjects[I], lTests[J]);
          Exit;
        end;
    end;
end;

destructor TRecorderMdbManager.Destroy;
begin
  if ActiveManager = Self then ActiveManager := nil;
  fRepository.Free;
  inherited Destroy;
end;

procedure TRecorderMdbManager.SelectContext(const AObject: TMdbObjectInfo;
  const ATest: TMdbTestInfo);
begin
  if ATest.ObjectId <> AObject.Id then
    raise EMdbError.Create('Selected test belongs to another object');
  if not fRepository.ContextExists(AObject.Id, ATest.Id) then
    raise EMdbError.Create('Selected context no longer exists');
  fContext.ObjectId := AObject.Id; fContext.ObjectName := AObject.Name;
  fContext.TestId := ATest.Id; fContext.TestName := ATest.Name;
  fContext.RequireValid;
  ActiveManager := Self;
end;

procedure TRecorderMdbManager.ClearContext;
begin
  if ActiveManager = Self then ActiveManager := nil;
  fContext := Default(TMdbMeasurementContext);
end;

end.
