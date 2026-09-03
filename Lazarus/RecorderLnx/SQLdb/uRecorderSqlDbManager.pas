unit uRecorderSqlDbManager;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, uRecorderCoreServices, uRecorderSqlDbTypes,
  uRecorderSqlDbRuntime, uRecorderTimeSystem;

type
  TRecorderSqlDbManager = class
  private
    fEventBus: TRecorderEventBus;
    fSubscription: Integer;
    fConfig: TRecorderSqlDbConfig;
    fRuntime: TRecorderSqlDbRuntime;
    fLastSamples: TStringList;
    fSampleLock: TRTLCriticalSection;
    fStateLock: TRTLCriticalSection;
    fConfigFileName: string;
    fTimeSystem: TRecorderTimeSystem;
    fRecordingEnabled: Boolean;
    procedure EnsureRuntime;
    procedure SetRecordingActive(AValue: Boolean; const AReason: string);
    function GetRecordingEnabled: Boolean;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
  public
    constructor Create(AEventBus: TRecorderEventBus;
      ATimeSystem: TRecorderTimeSystem);
    destructor Destroy; override;
    procedure Configure(const AFileName: string);
    procedure Reload;
    procedure DisableRuntimeAfterConfigurationError;
    procedure SaveConfig;
    procedure StartRegistration(const AReason: string = 'manual');
    procedure StopRegistration;
    procedure SetRecordingEnabled(AValue: Boolean);
    function StoreDataFile(const AFileName, ADataType: string;
      AAnchorUtc: Double): Boolean;
    property Config: TRecorderSqlDbConfig read fConfig;
    property Runtime: TRecorderSqlDbRuntime read fRuntime;
    property RecordingEnabled: Boolean read GetRecordingEnabled;
  end;

implementation

uses
  uRecorderTags, uRecorderAlarms, uRecorderDebugLog;

constructor TRecorderSqlDbManager.Create(AEventBus: TRecorderEventBus;
  ATimeSystem: TRecorderTimeSystem);
begin
  inherited Create;
  fEventBus := AEventBus;
  fTimeSystem := ATimeSystem;
  InitCriticalSection(fSampleLock);
  InitCriticalSection(fStateLock);
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
  DoneCriticalSection(fSampleLock);
  DoneCriticalSection(fStateLock);
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
  SetRecordingActive(False, 'SQLdb settings reload');
  FreeAndNil(fRuntime);
  fConfig.LoadFromFile(fConfigFileName);
  if fConfig.Enabled and (fConfig.Backend = rsbFirebird) and
     ((Trim(fConfig.UserName) = '') or (fConfig.Password = '')) then
  begin
    { Не вызываем TIBConnection.Open с пустыми credentials: в Lazarus debugger
      даже обработанная ошибка Firebird показывается как first-chance exception. }
    fConfig.Enabled := False;
    RecorderDebugLog('SQL database disabled: Firebird login is not configured');
    Exit;
  end;
  if fConfig.Enabled then
    SetRecordingActive(True, 'SQLdb enabled');
end;

procedure TRecorderSqlDbManager.DisableRuntimeAfterConfigurationError;
begin
  SetRecordingActive(False, 'SQLdb configuration error');
  FreeAndNil(fRuntime);
  { Отключаем только рабочую копию: ошибочный runtime не должен повторно
    запускаться управляющим тегом. Файл настроек не перезаписываем. }
  fConfig.Enabled := False;
  EnterCriticalSection(fSampleLock);
  try
    fLastSamples.Clear;
  finally
    LeaveCriticalSection(fSampleLock);
  end;
end;

procedure TRecorderSqlDbManager.SaveConfig;
begin
  if Trim(fConfigFileName) = '' then
    Exit;
  fConfig.SaveToFile(fConfigFileName);
end;

procedure TRecorderSqlDbManager.EnsureRuntime;
var
  lRuntimeConfig: TRecorderSqlDbConfig;
begin
  if fRuntime <> nil then Exit;
  lRuntimeConfig := TRecorderSqlDbConfig.Create;
  try
    lRuntimeConfig.Assign(fConfig);
    lRuntimeConfig.Enabled := True;
    lRuntimeConfig.RequireValid;
    fRuntime := TRecorderSqlDbRuntime.Create(lRuntimeConfig);
    fRuntime.Start;
  finally
    lRuntimeConfig.Free;
  end;
end;

procedure TRecorderSqlDbManager.SetRecordingActive(AValue: Boolean;
  const AReason: string);
begin
  if AValue and not fConfig.Enabled then
    Exit;
  EnterCriticalSection(fStateLock);
  try
    if fRecordingEnabled = AValue then Exit;
    if AValue then
    begin
      EnsureRuntime;
      EnterCriticalSection(fSampleLock);
      try
        fLastSamples.Clear;
      finally
        LeaveCriticalSection(fSampleLock);
      end;
      StartRegistration(AReason);
      fRecordingEnabled := True;
    end
    else
    begin
      StopRegistration;
      fRecordingEnabled := False;
    end;
  finally
    LeaveCriticalSection(fStateLock);
  end;
end;

function TRecorderSqlDbManager.GetRecordingEnabled: Boolean;
begin
  EnterCriticalSection(fStateLock);
  try
    Result := fRecordingEnabled;
  finally
    LeaveCriticalSection(fStateLock);
  end;
end;

procedure TRecorderSqlDbManager.SetRecordingEnabled(AValue: Boolean);
var
  lOldValue: Boolean;
begin
  lOldValue := fConfig.Enabled;
  fConfig.Enabled := AValue;
  try
    fConfig.SaveToFile(fConfigFileName);
    SetRecordingActive(AValue, 'SQLdb main switch');
  except
    fConfig.Enabled := lOldValue;
    raise;
  end;
end;

procedure TRecorderSqlDbManager.StartRegistration(const AReason: string);
begin
  if fRuntime = nil then Exit;
  if fTimeSystem <> nil then
    fRuntime.BeginRegistration(AReason, fTimeSystem.CurrentUtc)
  else
    fRuntime.BeginRegistration(AReason, LocalTimeToUniversal(Now));
end;

procedure TRecorderSqlDbManager.StopRegistration;
begin
  if fRuntime = nil then Exit;
  if fTimeSystem <> nil then
    fRuntime.EndRegistration(fTimeSystem.CurrentUtc)
  else
    fRuntime.EndRegistration(LocalTimeToUniversal(Now));
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
  lAlarmData: TRecorderAlarmEventData;
  lNowMs, lLastMs: Int64;
  lTimeUtc: TDateTime;
  lEstimate: TRecorderTagEstimate;
  lEstimateKind: TRecorderTagEstimateKind;
  lTimeSec, lValue: Double;
begin
  if (AEvent.Kind = rceDataUpdated) and
     (AEvent.Data is TRecorderTagUpdateEventData) then
  begin
    D := TRecorderTagUpdateEventData(AEvent.Data);
    if (D.Tag = nil) or (D.SampleCount <> 1) then Exit;
    if (Trim(fConfig.ControlTagName) <> '') and
       SameText(D.Tag.Name, fConfig.ControlTagName) then
    begin
      if D.Value > 0.5 then
        SetRecordingActive(True, 'SQLdb control tag: ' + D.Tag.Name)
      else if D.Value < 0.5 then
        SetRecordingActive(False, 'SQLdb control tag: ' + D.Tag.Name);
    end;
    if not GetRecordingEnabled or (fRuntime = nil) then Exit;
    if not fConfig.SignalEnabled(D.Tag.Name) then Exit;
    lTimeSec := D.TimeSec;
    lValue := D.Value;
    if D.BlockTailNotify then
    begin
      lEstimateKind := fConfig.SignalEstimate(D.Tag.Name);
      lEstimate := D.Tag.Estimate(lEstimateKind);
      if not lEstimate.Valid then Exit;
      lTimeSec := lEstimate.EndTimeSec;
      lValue := lEstimate.Value;
    end;
    lNowMs := GetTickCount64;
    EnterCriticalSection(fSampleLock);
    try
      lLastMs := StrToInt64Def(fLastSamples.Values[D.Tag.Name], 0);
      if (lLastMs <> 0) and
         (lNowMs - lLastMs < fConfig.RecordPeriodMs) then
        Exit;
      fLastSamples.Values[D.Tag.Name] := IntToStr(lNowMs);
    finally
      LeaveCriticalSection(fSampleLock);
    end;
    if fTimeSystem <> nil then
      lTimeUtc := fTimeSystem.ChannelTimeToUtc(lTimeSec)
    else
      lTimeUtc := LocalTimeToUniversal(Now);
    fRuntime.SubmitValue(D.Tag.Name, lTimeUtc, lValue, 0,
      D.Tag.SourceId, D.Tag.Address, D.Tag.UnitName);
  end
  else if AEvent.Kind = rceAlarmChanged then
  begin
    if not GetRecordingEnabled or (fRuntime = nil) then Exit;
    if (AEvent.Data is TRecorderAlarmEventData) and (fTimeSystem <> nil) then
    begin
      lAlarmData := TRecorderAlarmEventData(AEvent.Data);
      lTimeUtc := fTimeSystem.ChannelTimeToUtc(lAlarmData.TimeSec);
    end
    else if fTimeSystem <> nil then
      lTimeUtc := fTimeSystem.CurrentUtc
    else
      lTimeUtc := LocalTimeToUniversal(Now);
    fRuntime.SubmitEvent('alarm', AEvent.Text, lTimeUtc, AEvent.IntValue);
  end;
end;

end.
