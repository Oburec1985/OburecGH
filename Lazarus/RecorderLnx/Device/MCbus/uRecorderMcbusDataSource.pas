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
    IRecorderZeroBalanceSupport, IRecorderZeroBalanceTraceSupport)
  private
    fDevice: IRecorderDevice;
    fHost: string;
    fPort: Word;
    fPollFrequencyHz: Double;
    fSpecificConfigText: string;
    fTagNames: TStringList;
    fChannelTags: array of TRecorderTag;
    fTimes: array of Double;
    fEmptyReadCount: Cardinal;
    fHardwarePrepareAttempted: Boolean;
    fIoLock: TRTLCriticalSection;
    procedure BuildChannelMap;
    procedure PublishBlock(const ABlock: TRecorderAcquisitionBlock);
    procedure StoreBalanceDac(ASlot, AChannel: Integer; ACode: Word;
      AApplyRuntime: Boolean = True);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      APollFrequencyHz: Double; AUpdateTimeMs: Cardinal; ATagNames: TStrings;
      const ASpecificConfigText: string = '');
    destructor Destroy; override;
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
    function ZeroBalanceTags(AOwner: TComponent; ATags: TList;
      AMessages: TStrings): Boolean;
    procedure SetZeroBalanceTrace(AHandler: TRecorderZeroBalanceTraceEvent);
  end;

implementation

uses
  uRecorderMcbusDevice, uRecorderDebugLog, uRecorderHardwareLiveDevices,
  uRecorderConfiguredDataSources, uRecorderMc201Calibration;

procedure TRecorderMcbusDataSource.SetZeroBalanceTrace(
  AHandler: TRecorderZeroBalanceTraceEvent);
begin
  RecorderMcbusSetBalanceTrace(AHandler);
end;

procedure TRecorderMcbusDataSource.StoreBalanceDac(ASlot, AChannel: Integer;
  ACode: Word; AApplyRuntime: Boolean);
var
  I, J, lRange: Integer;
  lConfigured: TRecorderConfiguredDataSource;
  lFields, lLines: TStringList;
  lPrefix: string;
  lNative: TRecorderMcbusDevice;
begin
  lConfigured := RecorderConfiguredDataSourcesEnsure(Registry, SourceId,
    'MC-032', fPollFrequencyHz);
  if lConfigured = nil then
  begin
    RecorderDebugLog(Format(
      '[MCBUS][BALANCE] DAC persistence failed: registry=nil source=%s',
      [SourceId]));
    Exit;
  end;
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  try
    { Всегда ';': иначе DelimitedText даёт c0=1,c1=1 и ApplySpecificConfigText
      не видит dXrY → при пересоздании источника ЦАП снова . }
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ';';
    lFields.NameValueSeparator := '=';
    lLines.Text := lConfigured.SpecificConfigText;
    lPrefix := 'CFG slot=' + IntToStr(ASlot) + ';';
    for I := 0 to lLines.Count - 1 do
      if Pos(lPrefix, lLines[I]) = 1 then
      begin
        { Нормализуем старые CFG с запятыми в поля через ';'. }
        lFields.DelimitedText := StringReplace(
          Copy(lLines[I], Length(lPrefix) + 1, MaxInt), ',', ';',
          [rfReplaceAll]);
        lRange := EnsureRange(StrToIntDef(lFields.Values['c' +
          IntToStr(AChannel)], 1), 0, 5);
        lFields.Values['d' + IntToStr(AChannel) + 'r' + IntToStr(lRange)] :=
          IntToStr(ACode);
        lLines[I] := lPrefix + lFields.DelimitedText;
        lConfigured.SpecificConfigText := lLines.Text;
        fSpecificConfigText := lConfigured.SpecificConfigText;
        RecorderDebugLog(Format(
          '[MCBUS][BALANCE] DAC persisted source=%s slot=%d channel=%d range=%d code=$%.4x cfg=%s',
          [SourceId, ASlot, AChannel + 1, lRange, ACode, lLines[I]]));
        if AApplyRuntime and (fDevice <> nil) and
          (fDevice.GetNativeObject is TRecorderMcbusDevice) then
        begin
          lNative := TRecorderMcbusDevice(fDevice.GetNativeObject);
          lNative.SetSpecificConfigText(fSpecificConfigText);
          RecorderDebugLog('[MCBUS][BALANCE] runtime fConfig reloaded from CFG');
        end;
        Exit;
      end;
    { Старые проекты могут содержать только строки описания найденных модулей.
      В этом случае код ЦАП нельзя молча терять: создаём строку штатных настроек
      слота с теми же значениями по умолчанию, с которыми создан драйвер. }
    lFields.Clear;
    for J := 0 to 3 do
      lFields.Values['c' + IntToStr(J)] := '1';
    for J := 4 to 7 do
      lFields.Values['c' + IntToStr(J)] := '0';
    for J := 0 to 11 do
      lFields.Values['b' + IntToStr(J)] := '0';
    lFields.Values['comm'] := '0';
    lFields.Values['sub'] := '1';
    lFields.Values['rev'] := '0';
    lRange := 1;
    lFields.Values['d' + IntToStr(AChannel) + 'r' + IntToStr(lRange)] :=
      IntToStr(ACode);
    lLines.Add(lPrefix + lFields.DelimitedText);
    lConfigured.SpecificConfigText := lLines.Text;
    fSpecificConfigText := lConfigured.SpecificConfigText;
    RecorderDebugLog(Format(
      '[MCBUS][BALANCE] DAC config created source=%s slot=%d channel=%d range=%d code=$%.4x cfg=%s',
      [SourceId, ASlot, AChannel + 1, lRange, ACode,
       lLines[lLines.Count - 1]]));
    if AApplyRuntime and (fDevice <> nil) and
      (fDevice.GetNativeObject is TRecorderMcbusDevice) then
    begin
      lNative := TRecorderMcbusDevice(fDevice.GetNativeObject);
      lNative.SetSpecificConfigText(fSpecificConfigText);
      RecorderDebugLog('[MCBUS][BALANCE] runtime fConfig reloaded from new CFG');
    end;
  finally
    lFields.Free;
    lLines.Free;
  end;
end;

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
  ATagNames: TStrings; const ASpecificConfigText: string);
begin
  inherited Create(ASourceId, 'MC-032 / MC-201', AUpdateTimeMs);
  fHost := AHost;
  fPort := APort;
  fPollFrequencyHz := APollFrequencyHz;
  fSpecificConfigText := ASpecificConfigText;
  fTagNames := TStringList.Create;
  InitCriticalSection(fIoLock);
  fTagNames.CaseSensitive := False;
  if ATagNames <> nil then fTagNames.Assign(ATagNames);
  fDevice := CreateRecorderMcbusDevice;
  { Аппаратные настройки принадлежат конфигурации источника. Передаём их
    драйверу до первого ProgramDevice, а не читаем из UI во время старта. }
  if (fDevice <> nil) and
    (fDevice.GetNativeObject is TRecorderMcbusDevice) then
    TRecorderMcbusDevice(fDevice.GetNativeObject).SetSpecificConfigText(
      fSpecificConfigText);
end;

destructor TRecorderMcbusDataSource.Destroy;
begin
  RecorderHardwareUnregisterLiveDevice(Self);
  fDevice := nil;
  fTagNames.Free;
  DoneCriticalSection(fIoLock);
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
  I, lChannel, lSlot: Integer;
  lTestError: string;
  lTag: TRecorderTag;
  lNative: TRecorderMcbusDevice;
begin
  inherited PrepareHardware;
  if (fDevice.State = rdsProgrammed) or fHardwarePrepareAttempted then
    Exit;
  fHardwarePrepareAttempted := True;
  fDevice.TrySetDeviceProperty(rdpHost, fHost);
  fDevice.TrySetDeviceProperty(rdpPort, Integer(fPort));
  fDevice.TrySetDeviceProperty(rdpPollFrequencyHz, fPollFrequencyHz);
  fDevice.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(UpdateTimeMs));
  if fDevice.GetNativeObject is TRecorderMcbusDevice then
  begin
    lNative := TRecorderMcbusDevice(fDevice.GetNativeObject);
    for I := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[I];
      if SameText(lTag.SourceId, SourceId) and
        AddressSlotChannel(lTag.Address, lSlot, lChannel) and
        (lTag.PollFrequencyHz > 0) then
        lNative.SetSlotSampleRate(lSlot, lTag.PollFrequencyHz);
    end;
  end;
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
  { Lifecycle задаётся явно: Init выполняется один раз после подключения,
    Configure может безопасно повторяться при Apply без перезагрузки BIOS. }
  fDevice.InitializeDevice;
  fDevice.ConfigureDevice;
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
  { Если на диске уже есть ГХ для SN+диапазона и галочка не снята — в реестр. }
  RecorderMc201ApplyHardwareCalibrations(Registry, SourceId, fSpecificConfigText);
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
        RecorderMc201SyncTagUnitFromHardwareGx(Registry, lTag);
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
  lCodes: array of Word;
  lValues: TRecorderDeviceActionValues;
  lChannels: TRecorderDeviceChannelArray;
  lError: string;
  lTag: TRecorderTag;
  lStartedHere: Boolean;
  lMapped: Integer;
  lNative: TRecorderMcbusDevice;
begin
  Result := False;
  if (ATags = nil) or (fDevice = nil) then
  begin
    RecorderDebugLog('[MCBUS][BALANCE] ZeroBalanceTags: no tags/device');
    Exit;
  end;
  RecorderDebugLog(Format(
    '[MCBUS][BALANCE] ZeroBalanceTags enter source=%s tags=%d state=%d',
    [SourceId, ATags.Count, Ord(fDevice.State)]));
  if fDevice.State = rdsDisconnected then
  begin
    RecorderDebugLog('[MCBUS][BALANCE] PrepareHardware before balance');
    PrepareHardware;
    RecorderDebugLog(Format('[MCBUS][BALANCE] after PrepareHardware state=%d',
      [Ord(fDevice.State)]));
  end;
  lChannels := fDevice.GetChannels;
  SetLength(lIndices, ATags.Count);
  lMapped := 0;
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
        Inc(lMapped);
        Break;
      end;
    RecorderDebugLog(Format(
      '[MCBUS][BALANCE] map tag=%s addr=%s -> idx=%d',
      [lTag.Name, lTag.Address, lIndices[I]]));
  end;
  RecorderDebugLog(Format(
    '[MCBUS][BALANCE] mapped=%d/%d deviceChannels=%d',
    [lMapped, ATags.Count, Length(lChannels)]));
  EnterCriticalSection(fIoLock);
  lStartedHere := False;
  try
    { После изменения аппаратных параметров устройство может быть оставлено в
      rdsConnected: следующий Start сначала перепрограммирует его. Служебная
      балансировка обязана запускать устройство из любого состояния, кроме уже
      запущенного, иначе повторный вызов остаётся без активного скана. }
    if fDevice.State <> rdsStarted then
    begin
      RecorderDebugLog('[MCBUS][BALANCE] DataSource Start for balance');
      fDevice.Start;
      lStartedHere := True;
      RecorderDebugLog(Format('[MCBUS][BALANCE] DataSource Start done state=%d',
        [Ord(fDevice.State)]));
    end;
    Result := fDevice.ExecuteDeviceAction(rdaZeroBalance, lIndices, lValues,
      lError);
    RecorderDebugLog(Format(
      '[MCBUS][BALANCE] ExecuteDeviceAction result=%s err=%s',
      [BoolToStr(Result, True), lError]));
  finally
    if lStartedHere then
    begin
      RecorderDebugLog('[MCBUS][BALANCE] DataSource Stop after balance');
      fDevice.Stop;
    end;
    LeaveCriticalSection(fIoLock);
  end;
  if not Result then
  begin
    if AMessages <> nil then
      AMessages.Add('MC-201: ' + lError);
    Exit;
  end;
  Result := True;
  { Сначала снимаем все коды с soft-config. StoreBalanceDac с ApplyRuntime
    перечитывает CFG и затирал бы ещё не сохранённые каналы обратно в $8080
    (мульти-баланс: первый Store убивал 2..N). }
  if fDevice.GetNativeObject is TRecorderMcbusDevice then
  begin
    lNative := TRecorderMcbusDevice(fDevice.GetNativeObject);
    SetLength(lCodes, Length(lIndices));
    for I := 0 to High(lIndices) do
      if lIndices[I] >= 0 then
        lCodes[I] := lNative.GetChannelBalanceDac(lIndices[I])
      else
        lCodes[I] := $8080;
    for I := 0 to High(lIndices) do
      if (lIndices[I] >= 0) and AddressSlotChannel(
        TRecorderTag(ATags[I]).Address, lTagSlot, lTagChannel) then
        StoreBalanceDac(lTagSlot, lTagChannel - 1, lCodes[I], False);
    lNative.SetSpecificConfigText(fSpecificConfigText);
    RecorderDebugLog('[MCBUS][BALANCE] runtime fConfig reloaded once after all DAC stores');
  end;
  if AMessages <> nil then
    for I := 0 to High(lValues) do
      if (I <= High(lIndices)) and (lIndices[I] >= 0) then
        AMessages.Add(Format('%s: среднее до коррекции %.3f кода, ЦАП=$%.4x',
          [TRecorderTag(ATags[I]).Name, lValues[I],
           TRecorderMcbusDevice(fDevice.GetNativeObject).
             GetChannelBalanceDac(lIndices[I])]));
end;

procedure TRecorderMcbusDataSource.PublishBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  I, J, lCount: Integer;
  lFirstTime, lSampleRate: Double;
begin
  if (ABlock.SampleCount <= 0) or (ABlock.SampleRateHz <= 0) then Exit;
  if Length(fTimes) < ABlock.SampleCount then
    raise ERecorderDataSourceError.CreateFmt(
      'MCbus time buffer too small: need=%d capacity=%d',
      [ABlock.SampleCount, Length(fTimes)]);
  for I := 0 to Min(High(fChannelTags), High(ABlock.Values)) do
    if fChannelTags[I] <> nil then
    begin
      lCount := ABlock.SampleCount;
      lFirstTime := ABlock.FirstTimeSec;
      lSampleRate := ABlock.SampleRateHz;
      if I <= High(ABlock.ChannelSampleCounts) then
        lCount := ABlock.ChannelSampleCounts[I];
      if I <= High(ABlock.ChannelFirstTimesSec) then
        lFirstTime := ABlock.ChannelFirstTimesSec[I];
      if I <= High(ABlock.ChannelSampleRatesHz) then
        lSampleRate := ABlock.ChannelSampleRatesHz[I];
      if (lCount <= 0) or (lSampleRate <= 0) or
        (Length(ABlock.Values[I]) < lCount) then Continue;
      for J := 0 to lCount - 1 do
        fTimes[J] := lFirstTime + J / lSampleRate;
      Registry.PublishBlock(fChannelTags[I].Name, fTimes, ABlock.Values[I],
        lCount, False);
    end;
end;

procedure TRecorderMcbusDataSource.DoTick;
var
  lBlock: TRecorderAcquisitionBlock;
  lHasBlock: Boolean;
begin
  if RecorderHardwareIsSourceOffline(SourceId) then
    Exit;
  if fDevice.State <> rdsStarted then fDevice.Start;
  EnterCriticalSection(fIoLock);
  try
    lHasBlock := fDevice.ReadBlock(Max(Cardinal(1000), UpdateTimeMs * 4), lBlock);
  finally
    LeaveCriticalSection(fIoLock);
  end;
  if lHasBlock then
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
