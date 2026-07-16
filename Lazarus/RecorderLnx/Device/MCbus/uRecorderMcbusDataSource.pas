unit uRecorderMcbusDataSource;

{
  Рабочий источник данных Preview для MC-032/MC-201.

  Создаётся фабрикой главной формы для выбранных MCbus-тегов. В рабочем потоке
  выполняет Connect/ProgramDevice/Start/ReadBlock/Stop, сопоставляет нативный
  адрес slot-channel с адресом тега <индекс устройства>-<слот>-<канал> и
  публикует готовые блоки в TRecorderTagRegistry. Сетевой обмен из UI запрещён.

  DoCreateTags пуст намеренно: теги создаются аппаратными настройками, а этот
  класс только привязывает выбранные теги к каналам уже запрограммированного
  устройства. Жизненный цикл отмечается в LogWindows.log префиксом [MCBUS].
  Полная карта: Docs/devices/mc/recorderlnx-integration.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Variants,
  uRecorderDataSources, uRecorderTags, uRecorderDeviceInterfaces,
  uRecorderAcquisitionTypes;

type
  TRecorderMcbusDataSource = class(TRecorderDataSourceBase,
    IRecorderZeroBalanceSupport)
  private
    fDevice: IRecorderDevice;
    fHost: string;
    fPort: Word;
    fPollFrequencyHz: Double;
    fTagNames: TStringList;
    fChannelTags: array of TRecorderTag;
    fTimes: array of Double;
    fEmptyReadCount: Cardinal;
    fHardwarePrepareAttempted: Boolean;
    procedure BuildChannelMap;
    procedure PublishBlock(const ABlock: TRecorderAcquisitionBlock);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      APollFrequencyHz: Double; AUpdateTimeMs: Cardinal; ATagNames: TStrings);
    destructor Destroy; override;
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
    function ZeroBalanceTags(AOwner: TComponent; ATags: TList;
      AMessages: TStrings): Boolean;
  end;

implementation

uses
  uRecorderMcbusDevice, uRecorderDebugLog, uRecorderHardwareLiveDevices;

function AddressSlotChannel(const AAddress: string; out ASlot,
  AChannel: Integer): Boolean;
var
  lParts: TStringList;
begin
  Result := False;
  ASlot := 0;
  AChannel := 0;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := '-';
    lParts.DelimitedText := Trim(AAddress);
    if lParts.Count < 2 then Exit;
    Result := TryStrToInt(lParts[lParts.Count - 2], ASlot) and
      TryStrToInt(lParts[lParts.Count - 1], AChannel);
  finally
    lParts.Free;
  end;
end;

constructor TRecorderMcbusDataSource.Create(const ASourceId, AHost: string;
  APort: Word; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ATagNames: TStrings);
begin
  inherited Create(ASourceId, 'MC-032 / MC-201', AUpdateTimeMs);
  fHost := AHost;
  fPort := APort;
  fPollFrequencyHz := APollFrequencyHz;
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  if ATagNames <> nil then fTagNames.Assign(ATagNames);
  fDevice := CreateRecorderMcbusDevice;
end;

destructor TRecorderMcbusDataSource.Destroy;
begin
  RecorderHardwareUnregisterLiveDevice(Self);
  fDevice := nil;
  fTagNames.Free;
  inherited Destroy;
end;

procedure TRecorderMcbusDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
begin
  { Tags are selected and created by the settings dialog. The runtime source
    only binds them to device channel indices after hardware programming. }
end;

procedure TRecorderMcbusDataSource.PrepareHardware;
const
  CConnectAttempts = 5;
  CConnectRetryMs = 1000;
var
  I: Integer;
  lTestError: string;
begin
  inherited PrepareHardware;
  if (fDevice.State = rdsProgrammed) or fHardwarePrepareAttempted then
    Exit;
  fHardwarePrepareAttempted := True;
  fDevice.TrySetDeviceProperty(rdpHost, fHost);
  fDevice.TrySetDeviceProperty(rdpPort, Integer(fPort));
  fDevice.TrySetDeviceProperty(rdpPollFrequencyHz, fPollFrequencyHz);
  fDevice.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(UpdateTimeMs));
  RecorderDebugLog(Format('[MCBUS] connect %s:%d fs=%.0f tags=%d',
    [fHost, fPort, fPollFrequencyHz, fTagNames.Count]));
  { TEST не бросает исключение. Если контроллер недоступен, не вызываем
    Connect/ProgramDevice, которые предназначены уже для подтверждённой связи. }
  if not fDevice.TestLink(lTestError) then
  begin
    RecorderHardwareMarkSourceOffline(SourceId, lTestError);
    RecorderDebugLog('[MCBUS] link test failed, source skipped: ' + lTestError);
    Exit;
  end;
  RecorderHardwareClearSourceOffline(SourceId);
  { Контроллер после предыдущего TCP-сеанса не всегда принимает первое SYN.
    Повторяем соединение так же, как проверенный Mc201ProtocolDebug. Важно
    повторять только Connect: программирование модуля выполняется один раз. }
  for I := 1 to CConnectAttempts do
  begin
    try
      RecorderDebugLog(Format('[MCBUS] connect attempt %d/%d',
        [I, CConnectAttempts]));
      fDevice.Connect;
      Break;
    except
      on E: Exception do
      begin
        RecorderDebugLog(Format('[MCBUS] connect attempt %d failed: %s',
          [I, E.Message]));
        if I = CConnectAttempts then
          raise;
        Sleep(CConnectRetryMs);
      end;
    end;
  end;
  fDevice.ProgramDevice;
  BuildChannelMap;
  SetLength(fTimes, Round(fPollFrequencyHz * UpdateTimeMs / 1000.0));
  RecorderHardwareRegisterLiveDevice(Self, SourceId, fDevice);
end;

procedure TRecorderMcbusDataSource.BuildChannelMap;
var
  I, J, lChannel, lSlot, lTagChannel, lTagSlot: Integer;
  lChannels: TRecorderDeviceChannelArray;
  lTag: TRecorderTag;
begin
  lChannels := fDevice.GetChannels;
  SetLength(fChannelTags, Length(lChannels));
  for I := 0 to High(lChannels) do
  begin
    fChannelTags[I] := nil;
    if not AddressSlotChannel(lChannels[I].Address, lSlot, lChannel) then Continue;
    for J := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[J];
      if not SameText(lTag.SourceId, SourceId) then Continue;
      if not AddressSlotChannel(lTag.Address, lTagSlot, lTagChannel) then Continue;
      if (lTagSlot = lSlot) and (lTagChannel = lChannel) then
      begin
        fChannelTags[I] := lTag;
        Break;
      end;
    end;
  end;
  RecorderDebugLog(Format('[MCBUS] programmed channels=%d', [Length(lChannels)]));
end;

procedure TRecorderMcbusDataSource.Start;
begin
  { Базовый Start нужен даже пропущенному источнику: runner затем вызывает
    Tick, который должен спокойно завершиться, а не ругаться на dssStopped. }
  inherited Start;
  if RecorderHardwareIsSourceOffline(SourceId) or
    (fDevice.State <> rdsProgrammed) then
    Exit;
  fDevice.Start;
  { После каждого успешного Start подтверждаем живую сессию в общем реестре.
    Это обязательно после повторного Preview: дерево оборудования не должно
    переходить к отдельному TCP-probe, пока рабочий сокет уже занят потоком. }
  RecorderHardwareRegisterLiveDevice(Self, SourceId, fDevice);
  fEmptyReadCount := 0;
  RecorderDebugLog('[MCBUS] scan started; live device registered: ' + SourceId);
end;

procedure TRecorderMcbusDataSource.Stop;
var
  lStopError: string;
begin
  if fDevice <> nil then
  begin
    if fDevice.State = rdsDisconnected then
    begin
      RecorderHardwareUnregisterLiveDevice(Self);
      RecorderDebugLog('[MCBUS] stopped (source was offline)');
      inherited Stop;
      Exit;
    end;
    try
      fDevice.Stop;
      if fDevice.State = rdsDisconnected then
      begin
        lStopError := VarToStr(fDevice.GetDeviceProperty(rdpErrorText));
        RecorderDebugLog('[MCBUS] stop forced disconnect: ' + lStopError);
      end;
    except on E: Exception do
      RecorderDebugLog('[MCBUS] stop error: ' + E.Message); end;
    { Подключение и программирование сохраняются между остановками Preview.
      Полное отключение выполняет деструктор при загрузке/переконфигурации. }
  end;
  { При штатном Stop устройство остается запрограммированным и подключенным,
    поэтому оставляем его в live-реестре. Иначе дерево выполнит второй TEST по
    отдельному сокету и ошибочно покажет занятый контроллер неактивным. }
  if (fDevice = nil) or (fDevice.State = rdsDisconnected) then
    RecorderHardwareUnregisterLiveDevice(Self);
  RecorderDebugLog('[MCBUS] stopped; live state=' +
    IntToStr(Ord(fDevice.State)) + ' source=' + SourceId);
  inherited Stop;
end;

function TRecorderMcbusDataSource.ZeroBalanceTags(AOwner: TComponent;
  ATags: TList; AMessages: TStrings): Boolean;
var
  I, J, lChannel, lTagChannel, lTagSlot, lSlot: Integer;
  lIndices: array of Integer;
  lValues: TRecorderDeviceActionValues;
  lChannels: TRecorderDeviceChannelArray;
  lError: string;
  lTag: TRecorderTag;
begin
  Result := False;
  if (ATags = nil) or (fDevice = nil) then
    Exit;
  lChannels := fDevice.GetChannels;
  SetLength(lIndices, ATags.Count);
  for I := 0 to ATags.Count - 1 do
  begin
    lIndices[I] := -1;
    lTag := TRecorderTag(ATags[I]);
    if (lTag = nil) or not SameText(lTag.SourceId, SourceId) or
      not AddressSlotChannel(lTag.Address, lTagSlot, lTagChannel) then
      Continue;
    for J := 0 to High(lChannels) do
      if AddressSlotChannel(lChannels[J].Address, lSlot, lChannel) and
        (lSlot = lTagSlot) and (lChannel = lTagChannel) then
      begin
        lIndices[I] := J;
        Break;
      end;
  end;
  if not fDevice.ExecuteDeviceAction(rdaZeroBalance, lIndices, lValues,
    lError) then
  begin
    if AMessages <> nil then
      AMessages.Add('MC-201: ' + lError);
    Exit;
  end;
  Result := True;
  if AMessages <> nil then
    for I := 0 to High(lValues) do
      AMessages.Add(Format('%s: ноль скорректирован на %.3f',
        [TRecorderTag(ATags[I]).Name, lValues[I]]));
end;

procedure TRecorderMcbusDataSource.PublishBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  I, J: Integer;
begin
  if (ABlock.SampleCount <= 0) or (ABlock.SampleRateHz <= 0) then Exit;
  if Length(fTimes) < ABlock.SampleCount then
    raise ERecorderDataSourceError.CreateFmt(
      'MCbus time buffer too small: need=%d capacity=%d',
      [ABlock.SampleCount, Length(fTimes)]);
  for J := 0 to ABlock.SampleCount - 1 do
    fTimes[J] := ABlock.FirstTimeSec + J / ABlock.SampleRateHz;
  for I := 0 to Min(High(fChannelTags), High(ABlock.Values)) do
    if (fChannelTags[I] <> nil) and
      (Length(ABlock.Values[I]) >= ABlock.SampleCount) then
    begin
      Registry.PublishBlock(fChannelTags[I].Name, fTimes, ABlock.Values[I],
        ABlock.SampleCount, True);
    end;
end;

procedure TRecorderMcbusDataSource.DoTick;
var
  lBlock: TRecorderAcquisitionBlock;
begin
  if RecorderHardwareIsSourceOffline(SourceId) then
    Exit;
  if fDevice.State <> rdsStarted then fDevice.Start;
  if fDevice.ReadBlock(Max(Cardinal(1000), UpdateTimeMs * 4), lBlock) then
  begin
    fEmptyReadCount := 0;
    RecorderDebugLog(Format('[MCBUS] block channels=%d samples=%d',
      [lBlock.ChannelCount, lBlock.SampleCount]));
    PublishBlock(lBlock);
  end
  else
  begin
    Inc(fEmptyReadCount);
    if (fEmptyReadCount = 1) or ((fEmptyReadCount mod 20) = 0) then
      RecorderDebugLog(Format('[MCBUS] no complete block reads=%d state=%d',
        [fEmptyReadCount, Ord(fDevice.State)]));
  end;
end;

end.
