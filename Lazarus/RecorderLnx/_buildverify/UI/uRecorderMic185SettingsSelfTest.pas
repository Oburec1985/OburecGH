unit uRecorderMic185SettingsSelfTest;

{
  Reproduces MIC185 settings open while preview/data sources are running.
  CLI: RecorderLnx.exe --selftest-mic185-settings
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Controls, ExtCtrls, Forms, ImgList, SysUtils,
  uRecorderRunControlSettings, uRecorderTags;

type
  TRecorderMic185SelfTestLogProc = procedure(const AMessage: string) of object;
  TRecorderMic185SelfTestPreviewProc = procedure of object;
  TRecorderMic185SelfTestRunningFunc = function: Boolean of object;

function ExecuteRecorderMic185SettingsSelfTest(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry;
  ADeviceImageList, ATagDialogImageList: TCustomImageList;
  AStartPreview: TRecorderMic185SelfTestPreviewProc;
  ADataSourcesRunning: TRecorderMic185SelfTestRunningFunc;
  ALog: TRecorderMic185SelfTestLogProc): Boolean;

procedure ScheduleRecorderMic185SettingsSelfTest(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry;
  ADeviceImageList, ATagDialogImageList: TCustomImageList;
  AStartPreview: TRecorderMic185SelfTestPreviewProc;
  ADataSourcesRunning: TRecorderMic185SelfTestRunningFunc;
  ALog: TRecorderMic185SelfTestLogProc;
  AOnFinished: TNotifyEvent);

procedure ReleaseRecorderMic185SelfTestHost(ASender: TObject);

implementation

uses
  uRecorderMic185DataSource, uRecorderMic185Runtime, uRecorderMic185SettingsDialog,
  uRecorderSettingsDialog, uRecorderHardwareLiveDevices;

type
  TRecorderMic185SelfTestHost = class
  public
    Owner: TComponent;
    RunSettings: TRecorderRunControlSettings;
    TagRegistry: TRecorderTagRegistry;
    DeviceImages: TCustomImageList;
    TagImages: TCustomImageList;
    StartPreview: TRecorderMic185SelfTestPreviewProc;
    DataSourcesRunning: TRecorderMic185SelfTestRunningFunc;
    Log: TRecorderMic185SelfTestLogProc;
    OnFinished: TNotifyEvent;
    SourceId: string;
    Phase: Integer;
    WaitTicks: Integer;
    Timer: TTimer;
    procedure TimerTick(Sender: TObject);
  end;

function FindMic185SourceId(ATagRegistry: TRecorderTagRegistry): string;
var
  I: Integer;
  lHost: string;
  lPort: Word;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  Result := '';
  if ATagRegistry = nil then
    Exit;
  for I := 0 to ATagRegistry.TagCount - 1 do
  begin
    lTag := ATagRegistry.Tags[I];
    lSourceId := RecorderNormalizeTagSourceId(lTag.SourceId);
    if TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
      Exit(lSourceId);
  end;
  for I := 0 to ATagRegistry.ActiveSourceCount - 1 do
  begin
    lSourceId := ATagRegistry.ActiveSourceIds[I];
    if TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
      Exit(lSourceId);
  end;
end;

function ExecuteRecorderMic185SettingsSelfTest(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry;
  ADeviceImageList, ATagDialogImageList: TCustomImageList;
  AStartPreview: TRecorderMic185SelfTestPreviewProc;
  ADataSourcesRunning: TRecorderMic185SelfTestRunningFunc;
  ALog: TRecorderMic185SelfTestLogProc): Boolean;
var
  lHost: string;
  lPort: Word;
  lSourceId: string;
begin
  Result := False;
  lSourceId := FindMic185SourceId(ATagRegistry);
  if lSourceId = '' then
  begin
    if Assigned(ALog) then
      ALog('MIC185 self-test: no MIC-185 source in tag registry.');
    Exit;
  end;

  if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
  begin
    if Assigned(ALog) then
      ALog('MIC185 self-test: cannot parse source id.');
    Exit;
  end;

  if Assigned(ALog) then
    ALog('MIC185 self-test: source ' + lSourceId);

  if Assigned(AStartPreview) then
  begin
    if Assigned(ALog) then
      ALog('MIC185 self-test: starting preview / data sources.');
    AStartPreview;
  end;

  if Assigned(ADataSourcesRunning) and (not ADataSourcesRunning()) then
  begin
    if Assigned(ALog) then
      ALog('MIC185 self-test: data sources are not running after preview start.');
    Exit;
  end;

  if not RecorderHardwareIsSourceLinkOk(lSourceId) then
  begin
    if Assigned(ALog) then
      ALog('MIC185 self-test: TestLink failed before edit.');
    Exit;
  end;

  SetRecorderMic185SettingsSelfTestActive(True);
  try
    if Assigned(ALog) then
      ALog('MIC185 self-test: invoking settings MIC185 edit (dblClick path).');
    RecorderSettingsDialogDebugEditMic185(AOwner, ARunSettings, ATagRegistry,
      ADeviceImageList, ATagDialogImageList, lSourceId);
    Result := RecorderHardwareIsSourceLinkOk(lSourceId);
    if Assigned(ALog) then
    begin
      if Result then
        ALog('MIC185 self-test: PASS — TestLink on live device session.')
      else
        ALog('MIC185 self-test: FAIL — TestLink after edit.');
    end;
  finally
    SetRecorderMic185SettingsSelfTestActive(False);
  end;
end;

procedure ScheduleRecorderMic185SettingsSelfTest(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry;
  ADeviceImageList, ATagDialogImageList: TCustomImageList;
  AStartPreview: TRecorderMic185SelfTestPreviewProc;
  ADataSourcesRunning: TRecorderMic185SelfTestRunningFunc;
  ALog: TRecorderMic185SelfTestLogProc;
  AOnFinished: TNotifyEvent);
var
  lHost: TRecorderMic185SelfTestHost;
begin
  lHost := TRecorderMic185SelfTestHost.Create;
  lHost.Owner := AOwner;
  lHost.RunSettings := ARunSettings;
  lHost.TagRegistry := ATagRegistry;
  lHost.DeviceImages := ADeviceImageList;
  lHost.TagImages := ATagDialogImageList;
  lHost.StartPreview := AStartPreview;
  lHost.DataSourcesRunning := ADataSourcesRunning;
  lHost.Log := ALog;
  lHost.OnFinished := AOnFinished;
  lHost.SourceId := FindMic185SourceId(ATagRegistry);
  lHost.Phase := 0;
  lHost.WaitTicks := 0;
  lHost.Timer := TTimer.Create(AOwner);
  lHost.Timer.Interval := 500;
  lHost.Timer.OnTimer := @lHost.TimerTick;
  lHost.Timer.Enabled := True;
  if Assigned(ALog) then
    ALog('MIC185 self-test scheduled.');
end;

procedure TRecorderMic185SelfTestHost.TimerTick(Sender: TObject);
var
  lOk: Boolean;
begin
  Inc(WaitTicks);
  case Phase of
    0:
      begin
        if SourceId = '' then
        begin
          if Assigned(Log) then
            Log('MIC185 self-test: no MIC-185 source, abort.');
          Timer.Enabled := False;
          if Assigned(OnFinished) then
            OnFinished(Self);
          Exit;
        end;
        if Assigned(Log) then
          Log('MIC185 self-test: phase 0 — start preview.');
        if Assigned(StartPreview) then
          StartPreview;
        Phase := 1;
        WaitTicks := 0;
      end;
    1:
      begin
        if Assigned(DataSourcesRunning) and DataSourcesRunning() then
        begin
          Phase := 2;
          WaitTicks := 0;
          if Assigned(Log) then
            Log('MIC185 self-test: data sources running, opening MIC185 edit.');
          lOk := ExecuteRecorderMic185SettingsSelfTest(Owner, RunSettings,
            TagRegistry, DeviceImages, TagImages, nil, DataSourcesRunning, Log);
          if Assigned(Log) then
          begin
            if lOk then
              Log('MIC185 self-test finished: PASS')
            else
              Log('MIC185 self-test finished: FAIL');
          end;
          Timer.Enabled := False;
          if Assigned(OnFinished) then
            OnFinished(Self);
          Exit;
        end;
        if WaitTicks >= 20 then
        begin
          if Assigned(Log) then
            Log('MIC185 self-test: timeout waiting for data sources.');
          Timer.Enabled := False;
          if Assigned(OnFinished) then
            OnFinished(Self);
        end;
      end;
  end;
end;

procedure ReleaseRecorderMic185SelfTestHost(ASender: TObject);
var
  lHost: TRecorderMic185SelfTestHost;
begin
  if not (ASender is TRecorderMic185SelfTestHost) then
    Exit;
  lHost := TRecorderMic185SelfTestHost(ASender);
  if lHost.Timer <> nil then
  begin
    lHost.Timer.Enabled := False;
    lHost.Timer.Free;
    lHost.Timer := nil;
  end;
  lHost.Free;
end;

end.
