unit uRecorderTagDeviceServices;

{
  Маршрутизация операций тега к UI и возможностям конкретного устройства.
  Универсальные формы вызывают только эти функции и не разбирают SourceId.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Controls, ImgList, uRecorder, uRecorderTags;

type
  TRecorderDeviceServiceLogEvent = procedure(const AMessage: string) of object;
  TRecorderDeviceTestPreviewEvent = procedure of object;
  TRecorderDeviceTestRunningEvent = function: Boolean of object;

function RecorderEditTagDevice(AOwner: TComponent; ARecorder: TRecorder;
  ATag: TRecorderTag; ACommandImages, ATagImages: TCustomImageList;
  ALog: TRecorderDeviceServiceLogEvent = nil): Boolean;
function RecorderBalanceTagDevices(AOwner: TComponent; ARecorder: TRecorder;
  ARegistry: TRecorderTagRegistry; ATags: TList): Boolean;
procedure RecorderScheduleCommandLineDeviceTests(AOwner: TComponent;
  ARecorder: TRecorder; ADeviceImages, ATagImages: TCustomImageList;
  AStartPreview: TRecorderDeviceTestPreviewEvent;
  ADataSourcesRunning: TRecorderDeviceTestRunningEvent;
  ALog: TRecorderDeviceServiceLogEvent; AOnFinished: TNotifyEvent);
procedure RecorderReleaseDeviceTest(ASender: TObject);

implementation

uses
  SysUtils, Dialogs, uRecorderConfiguredDataSources,
  uRecorderMc201SlotSettingsDialog, uRecorderMic140SettingsDialog,
  uRecorderMic185SettingsDialog, uRecorderMc032SettingsDialog,
  uRecorderSettingsDialog, uRecorderTagBalance,
  uRecorderMic185SettingsSelfTest, uRecorderMic140DataSource,
  uRecorderMic140Utils, uRecorderMic185DataSource;

procedure Log(ALog: TRecorderDeviceServiceLogEvent; const AText: string);
begin
  if Assigned(ALog) then
    ALog(AText);
end;

function RecorderEditTagDevice(AOwner: TComponent; ARecorder: TRecorder;
  ATag: TRecorderTag; ACommandImages, ATagImages: TCustomImageList;
  ALog: TRecorderDeviceServiceLogEvent): Boolean;
var
  I, lSlot: Integer;
  lConfig: TRecorderConfiguredDataSource;
  lConfigText: string;
  lConfigs: TStringList;
  lDialog: TOpenDialog;
  lHost: string;
  lNewSourceId: string;
  lPath: string;
  lPort: Word;
  lLines: TStringList;
  lCaption: string;
const
  CMeraSourcePrefix = 'Mera file: ';
begin
  Result := False;
  if (ARecorder = nil) or (ATag = nil) then
    Exit;
  if TryParseRecorderMc032SourceId(ATag.SourceId, lHost, lPort) then
  begin
    lConfig := RecorderConfiguredDataSourcesFind(ARecorder.TagRegistry,
      ATag.SourceId);
    if lConfig = nil then
      Exit;
    lLines := TStringList.Create;
    try
      lLines.StrictDelimiter := True;
      lLines.Delimiter := '-';
      lLines.DelimitedText := ATag.Address;
      if (lLines.Count < 2) or
        not TryStrToInt(lLines[lLines.Count - 2], lSlot) then
        Exit;
      lLines.Text := lConfig.SpecificConfigText;
      lCaption := '';
      for I := 0 to lLines.Count - 1 do
        if Pos('Слот ' + IntToStr(lSlot) + ':', Trim(lLines[I])) = 1 then
        begin
          lCaption := Trim(lLines[I]);
          Break;
        end;
      if lCaption = '' then
        Exit;
      lConfigText := lConfig.SpecificConfigText;
      Result := ShowRecorderMc201SlotSettingsDialog(
        AOwner, lCaption, lConfigText, ATag.SourceId,
        ARecorder.DataSources, ARecorder.TagRegistry);
      if Result then
      begin
        lConfig.SpecificConfigText := lConfigText;
        Log(ALog, Format('MC-201 slot %d settings updated.', [lSlot]));
      end;
    finally
      lLines.Free;
    end;
    Exit;
  end;
  if TryParseRecorderMic140SourceId(ATag.SourceId, lHost, lPort) then
  begin
    lConfigs := TStringList.Create;
    try
      lConfigs.OwnsObjects := True;
      Result := ApplyRecorderMic140SourceDialog(AOwner, ARecorder.TagRegistry,
        lConfigs, ATag.SourceId, lNewSourceId);
      if Result then
        Log(ALog, 'MIC-140 hardware settings updated.');
    finally
      lConfigs.Free;
    end;
    Exit;
  end;
  if TryParseRecorderMic185SourceId(ATag.SourceId, lHost, lPort) then
  begin
    Result := ApplyRecorderMic185SourceDialog(AOwner, ARecorder.TagRegistry,
      ATag.SourceId, lNewSourceId);
    if Result then
      Log(ALog, 'MIC183/185 hardware settings updated.');
    Exit;
  end;
  if Pos(CMeraSourcePrefix, ATag.SourceId) = 1 then
  begin
    lPath := Trim(Copy(ATag.SourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
    lDialog := TOpenDialog.Create(AOwner);
    try
      lDialog.Title := 'Файл Mera';
      lDialog.Filter := 'Mera files (*.mera)|*.mera|All files (*.*)|*.*';
      lDialog.FileName := lPath;
      if lDialog.Execute then
      begin
        ShowRecorderSettingsDialog(AOwner, ARecorder, ACommandImages,
          ATagImages);
        Result := True;
      end;
    finally
      lDialog.Free;
    end;
  end;
end;

function RecorderBalanceTagDevices(AOwner: TComponent; ARecorder: TRecorder;
  ARegistry: TRecorderTagRegistry; ATags: TList): Boolean;
begin
  Result := (ARecorder <> nil) and RecorderTryZeroBalanceTags(AOwner,
    ARegistry, ATags, ARecorder.DataSources);
end;

procedure RecorderScheduleCommandLineDeviceTests(AOwner: TComponent;
  ARecorder: TRecorder; ADeviceImages, ATagImages: TCustomImageList;
  AStartPreview: TRecorderDeviceTestPreviewEvent;
  ADataSourcesRunning: TRecorderDeviceTestRunningEvent;
  ALog: TRecorderDeviceServiceLogEvent; AOnFinished: TNotifyEvent);
var
  I: Integer;
begin
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), '--selftest-mic185-settings') then
    begin
      ScheduleRecorderMic185SettingsSelfTest(AOwner, ARecorder, ADeviceImages,
        ATagImages, TRecorderMic185SelfTestPreviewProc(AStartPreview),
        TRecorderMic185SelfTestRunningFunc(ADataSourcesRunning),
        TRecorderMic185SelfTestLogProc(ALog), AOnFinished);
      Exit;
    end;
end;

procedure RecorderReleaseDeviceTest(ASender: TObject);
begin
  ReleaseRecorderMic185SelfTestHost(ASender);
end;

end.
