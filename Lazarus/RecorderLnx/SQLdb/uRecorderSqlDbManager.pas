unit uRecorderSqlDbManager;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderCoreServices, uRecorderSqlDbTypes,
  uRecorderSqlDbRuntime;

type
  TRecorderSqlDbManager = class
  private
    fEventBus: TRecorderEventBus;
    fSubscription: Integer;
    fConfig: TRecorderSqlDbConfig;
    fRuntime: TRecorderSqlDbRuntime;
    fLastSamples: TStringList;
    fConfigFileName: string;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
  public
    constructor Create(AEventBus: TRecorderEventBus);
    destructor Destroy; override;
    procedure Configure(const AFileName: string);
    procedure Reload;
    procedure StartRegistration(const AReason: string = 'manual');
    procedure StopRegistration;
    function StoreDataFile(const AFileName, ADataType: string;
      AAnchorUtc: Double): Boolean;
    property Config: TRecorderSqlDbConfig read fConfig;
    property Runtime: TRecorderSqlDbRuntime read fRuntime;
  end;

implementation

uses
  uRecorderTags;

constructor TRecorderSqlDbManager.Create(AEventBus: TRecorderEventBus);
begin
  inherited Create;
  fEventBus := AEventBus;
  fConfig := TRecorderSqlDbConfig.Create;
  fLastSamples := TStringList.Create;
  fLastSamples.CaseSensitive := False;
  fLastSamples.NameValueSeparator := '=';
  if fEventBus <> nil then fSubscription := fEventBus.Subscribe(@HandleEvent);
end;

destructor TRecorderSqlDbManager.Destroy;
begin
  if (fEventBus <> nil) and (fSubscription <> 0) then
    fEventBus.Unsubscribe(fSubscription);
  FreeAndNil(fRuntime);
  fLastSamples.Free;
  fConfig.Free;
  inherited Destroy;
end;

procedure TRecorderSqlDbManager.Configure(const AFileName: string);
begin
  fConfigFileName := ExpandFileName(AFileName);
  Reload;
end;

procedure TRecorderSqlDbManager.Reload;
begin
  FreeAndNil(fRuntime);
  fConfig.LoadFromFile(fConfigFileName);
  fRuntime := TRecorderSqlDbRuntime.Create(fConfig);
  fRuntime.Start;
end;

procedure TRecorderSqlDbManager.StartRegistration(const AReason: string);
begin
  if fRuntime <> nil then fRuntime.BeginRegistration(AReason);
end;

procedure TRecorderSqlDbManager.StopRegistration;
begin
  if fRuntime <> nil then fRuntime.EndRegistration;
end;

function TRecorderSqlDbManager.StoreDataFile(const AFileName, ADataType: string;
  AAnchorUtc: Double): Boolean;
begin
  Result := (fRuntime <> nil) and
    fRuntime.SubmitFile(AFileName, ADataType, AAnchorUtc);
end;

procedure TRecorderSqlDbManager.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
var
  D: TRecorderTagUpdateEventData;
  lNowMs, lLastMs: Int64;
begin
  if (fRuntime = nil) or not fConfig.Enabled then Exit;
  if (AEvent.Kind = rceDataUpdated) and
     (AEvent.Data is TRecorderTagUpdateEventData) then
  begin
    D := TRecorderTagUpdateEventData(AEvent.Data);
    if (D.Tag = nil) or (D.SampleCount <> 1) then Exit;
    if not fConfig.SignalEnabled(D.Tag.Name) then Exit;
    lNowMs := GetTickCount64;
    lLastMs := StrToInt64Def(fLastSamples.Values[D.Tag.Name], 0);
    if (lLastMs <> 0) and (lNowMs - lLastMs < fConfig.RecordPeriodMs) then Exit;
    fLastSamples.Values[D.Tag.Name] := IntToStr(lNowMs);
    fRuntime.SubmitValue(D.Tag.Name, Now, D.Value, 0);
  end
  else if AEvent.Kind = rceAlarmChanged then
    fRuntime.SubmitEvent('alarm', AEvent.Text, Now, AEvent.IntValue);
end;

end.
