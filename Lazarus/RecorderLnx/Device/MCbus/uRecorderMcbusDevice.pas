unit uRecorderMcbusDevice;

{
  Production-адаптер шины MC к архитектуре устройств RecorderLnx.

  Важно:
  - MC-032 управляет крейтом, MC-201 даёт по четыре измерительных канала;
  - MIC-200 является названием конструктива и не образует отдельный слой кода;
  - наружу устройство предоставляет стандартный жизненный цикл TRecorderDevice;
  - входной MDP-пакет может содержать несколько BIOS-сообщений: AcceptPacket
    раскладывает их по полной паре slot/final flag, удаляет 10 слов заголовка и
    накапливает 11 520 отсчётов на канал за блок 200 мс при 57,6 кГц;
  - размер ADSP FIFO 256 относится к каждому каналу, делить его на 16 нельзя.

  Runtime-обёртка находится в uRecorderMcbusDataSource.pas.
  Полная карта: Docs/devices/mc/recorderlnx-integration.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Types, Variants,
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes, uRecorderDataSources,
  uMc032Device, uMc201ProtocolTypes;

type
  { Адаптер MC-032 + MC-201 к стандартному TRecorderDevice. }
  TRecorderMcbusDevice = class(TRecorderDevice)
  private
    fController: TMc032Device;
    fConfig: TMc032Config;
    fModules: TMc201SlotInfoArray;
    fProgramInfo: TMc201ModuleProgramInfoArray;
    fPending: array of array of Double;
    fPendingCount: array of Integer;
    fReadBlock: TRecorderAcquisitionBlock;
    fBalanceDac: array of Word;
    fSampleIndices: array of Int64;
    fLastError: string;
    fReceivedSinceStart: Boolean;
    fHardwareInitialized: Boolean;
    fConfigurationAppliedByInit: Boolean;
    procedure ControllerProgress(Sender: TObject; const AText: string);
    procedure ApplySpecificConfigText(const AText: string);
    procedure AllocateBuffers;
    procedure ResetPending;
    function ChannelIndex(ASlot, AFlag: Word): Integer;
    function AcceptPacket(const AWords: TMc201WordArray): Boolean;
    function PendingComplete: Boolean;
    function ChannelSampleRate(AChannel: Integer): Double;
    function CollectChannelMean(AChannel, ASampleCount: Integer;
      out AMean: Double; out AErrorText: string): Boolean;
    function CollectChannelsMean(const AChannels: array of Integer;
      const ASampleCounts: array of Integer; out AMeans: TDoubleDynArray;
      out AOk: TBooleanDynArray; out AErrorText: string): Boolean;
    function BalanceChannelsHardware(const AChannels: array of Integer;
      out AMeans: TDoubleDynArray; out AErrorText: string): Boolean;
    function BalanceChannelHardware(AChannel: Integer; out AFinalMean: Double;
      out AErrorText: string): Boolean;
    function TargetSampleCount(AChannel: Integer = -1): Integer;
  protected
    function BuildChannelName(AIndex: Integer): string; override;
    function BuildChannelAddress(AIndex: Integer): string; override;
  public
    constructor Create(const ADeviceId, AName: string); override;
    destructor Destroy; override;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant; override;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer = -1): Boolean; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure InitializeDevice; override;
    procedure ConfigureDevice; override;
    procedure ProgramDevice; override;
    procedure Start; override;
    procedure Stop; override;
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean; override;
    function TestLink(out AErrorText: string): Boolean; override;
    function SupportsDeviceAction(AAction: TRecorderDeviceAction): Boolean; override;
    // для MC поддерживает пока только балансировку
    function ExecuteDeviceAction(AAction: TRecorderDeviceAction;
      const AChannelIndices: array of Integer; out AValues: TRecorderDeviceActionValues;
      out AErrorText: string): Boolean; override;
    procedure SetSpecificConfigText(const AText: string);
    procedure SetSlotSampleRate(ASlot: Integer; AFrequencyHz: Double);
    function GetChannelBalanceDac(AChannel: Integer): Word;
    function GetSlotBalanceDac(ASlot1Based, AChannel, ARange: Integer): Word;
    procedure MergeSlotBalanceDacsIntoConfigText(var AConfigText: string;
      ASlot1Based: Integer);
    procedure ApplySavedBalanceDac;
    function TryApplySavedBalanceDac(out AErrorText: string): Boolean;
    { Сервис: сдвиг балансировочного ЦАП на известное V → K [В/код] для ГХ. }
    function CalibrateScaleByBalanceDacShift(AChannel: Integer;
      out AScaleVoltPerCode: Double; out AErrorText: string): Boolean;
  end;

function CreateRecorderMcbusDevice: IRecorderDevice;
procedure RecorderMcbusSetBalanceTrace(AHandler: TRecorderZeroBalanceTraceEvent);

implementation

uses
  Math, StrUtils, uRecorderHardwareTree, uRecorderDebugLog;

var
  gBalanceTrace: TRecorderZeroBalanceTraceEvent;

procedure RecorderMcbusSetBalanceTrace(AHandler: TRecorderZeroBalanceTraceEvent);
begin
  gBalanceTrace := AHandler;
end;

procedure BalanceTrace(const AText: string);
begin
  RecorderDebugLog('[MCBUS][BALANCE] ' + AText);
  if Assigned(gBalanceTrace) then
    gBalanceTrace(AText);
end;

procedure TRecorderMcbusDevice.ControllerProgress(Sender: TObject;
  const AText: string);
begin
  RecorderDebugLog('[MCBUS][PROTOCOL] ' + AText);
end;

function TRecorderMcbusDevice.CalibrateScaleByBalanceDacShift(AChannel: Integer;
  out AScaleVoltPerCode: Double; out AErrorText: string): Boolean;
const
  CLoOff = 20;
  CHiOff = 20;
var
  lOldCode, lCodeB: Word;
  lMeanA, lMeanB, lVA, lVB, lDMean: Double;
  lSamples: Integer;
  lSlot, lChInSlot: Integer;
  lWasStarted: Boolean;
begin
  Result := False;
  AScaleVoltPerCode := 0;
  AErrorText := '';
  if (AChannel < 0) or (AChannel >= fChannelCount) then
  begin
    AErrorText := Format('MC-201 calibrate: bad channel %d', [AChannel]);
    Exit;
  end;
  if fState = rdsDisconnected then
  begin
    try
      Connect;
    except
      on E: Exception do
      begin
        AErrorText := 'MC-201 calibrate Connect: ' + E.Message;
        Exit;
      end;
    end;
  end;
  if fState = rdsConnected then
  begin
    try
      ProgramDevice;
    except
      on E: Exception do
      begin
        AErrorText := 'MC-201 calibrate ProgramDevice: ' + E.Message;
        Exit;
      end;
    end;
  end;

  lSlot := fProgramInfo[AChannel div CMc201MaxModuleChannels].Slot;
  lChInSlot := AChannel mod CMc201MaxModuleChannels;
  lOldCode := GetChannelBalanceDac(AChannel);
  lCodeB := Word(((CMc201BalanceDacMidCode + CHiOff) shl 8) or
    (CMc201BalanceDacMidCode + CLoOff));
  lVA := 0;
  lVB := RecorderMc201BalanceVoltFromSigned(CLoOff, CHiOff);
  lSamples := Max(64, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  lWasStarted := fState = rdsStarted;

  { SEND только на остановленной шине (см. multi-balance docs). }
  if fState = rdsStarted then
    Stop;
  if not fController.SendBalanceDac(lSlot, lChInSlot, $80, $80, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate SEND A: ' + AErrorText;
    Exit;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate Start A: ' + AErrorText;
    Exit;
  end;
  fState := rdsStarted;
  if not CollectChannelMean(AChannel, lSamples, lMeanA, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate mean A: ' + AErrorText;
    Exit;
  end;

  Stop;
  if not fController.SendBalanceDac(lSlot, lChInSlot,
    lCodeB and $ff, lCodeB shr 8, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate SEND B: ' + AErrorText;
    Exit;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate Start B: ' + AErrorText;
    Exit;
  end;
  fState := rdsStarted;
  if not CollectChannelMean(AChannel, lSamples, lMeanB, AErrorText) then
  begin
    AErrorText := 'MC-201 calibrate mean B: ' + AErrorText;
    Exit;
  end;

  Stop;
  if not fController.SendBalanceDac(lSlot, lChInSlot,
    lOldCode and $ff, lOldCode shr 8, AErrorText) then
    BalanceTrace('calibrate restore DAC: ' + AErrorText);
  if lWasStarted then
  begin
    if fController.StartRawScan(AErrorText) then
      fState := rdsStarted
    else
      BalanceTrace('calibrate restart: ' + AErrorText);
  end
  else
    fState := rdsProgrammed;

  lDMean := lMeanB - lMeanA;
  if Abs(lDMean) < 1.0 then
  begin
    AErrorText := Format(
      'MC-201 calibrate: Δcode too small (%.3f), meanA=%.3f meanB=%.3f',
      [lDMean, lMeanA, lMeanB]);
    Exit;
  end;
  { Знак: V>0 при сдвиге ЦАП; берём согласованный знак ΔV/Δcode. }
  AScaleVoltPerCode := (lVB - lVA) / lDMean;
  BalanceTrace(Format(
    'calibrate ch=%d meanA=%.3f meanB=%.3f Vb=%.6g K=%.9g V/code',
    [AChannel, lMeanA, lMeanB, lVB, AScaleVoltPerCode]));
  Result := True;
end;


function RecorderMc032HardwareLinkProbe(const ASourceId: string): Boolean;
const
  CPrefix = 'MC-032: ';
var
  lController: TMc032Device;
  lError: string;
  lHost: string;
  lPort: Integer;
  lPos: SizeInt;
  lText: string;
begin
  Result := False;
  if Pos(CPrefix, ASourceId) <> 1 then
    Exit;
  lText := Trim(Copy(ASourceId, Length(CPrefix) + 1, MaxInt));
  lPos := RPos(':', lText);
  if (lPos <= 1) or not TryStrToInt(Copy(lText, lPos + 1, MaxInt), lPort) or
    (lPort < 1) or (lPort > 65535) then
    Exit;
  lHost := Trim(Copy(lText, 1, lPos - 1));
  lController := TMc032Device.Create;
  try
    lController.Host := lHost;
    lController.Port := Word(lPort);
    lController.TimeoutMs := 250;
    Result := lController.TestConnection(lError);
  finally
    lController.Free;
  end;
end;

function CreateRecorderMcbusDevice: IRecorderDevice;
begin
  Result := TRecorderMcbusDevice.Create('mc032', 'MC-032 / MC-201');
end;

constructor TRecorderMcbusDevice.Create(const ADeviceId, AName: string);
var
  I, J, K: Integer;
begin
  inherited Create(ADeviceId, AName);
  fHost := CMc201DefaultHost;
  fPort := CMc201DefaultPort;
  fPollFrequencyHz := CMc201DefaultSampleRateHz;
  fUpdateTimeMs := CMc201DefaultUpdateMs;
  fChannelCount := 0;
  FillChar(fConfig, SizeOf(fConfig), 0);
  fConfig.SampleRateHz := CMc201DefaultSampleRateHz;
  fConfig.BackplaneFrequencyHz := Round(CMc201BackplaneFrequencyHz);
  fConfig.MaxSlots := CMc201DefaultMaxSlots;
  fConfig.ReadTimeoutMs := CMc201DefaultTimeoutMs;
  for I := 0 to High(fConfig.Slots) do
  begin
    fConfig.Slots[I].SampleRateHz := CMc201DefaultSampleRateHz;
    for J := 0 to High(fConfig.Slots[I].Channels) do
    begin
      fConfig.Slots[I].Channels[J].RangeIndex := 1;
      for K := 0 to High(fConfig.Slots[I].Channels[J].BalanceDac) do
        fConfig.Slots[I].Channels[J].BalanceDac[K] := $8080;
    end;
  end;
  fController := TMc032Device.Create;
  fController.OnProgress := @ControllerProgress;
end;

procedure TRecorderMcbusDevice.ApplySpecificConfigText(const AText: string);
var
  I, J, K, lSlot: Integer;
  lFields: TStringList;
  lLines: TStringList;
  lPrefix: string;
begin
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  try
    lLines.Text := AText;
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ';';
    for I := 0 to lLines.Count - 1 do
    begin
      if Pos('CFG backplane=', Trim(lLines[I])) = 1 then
      begin
        fConfig.BackplaneFrequencyHz := Round(
          RecorderMc201BackplaneFromConfig(lLines[I]));
        Continue;
      end;
      lPrefix := 'CFG slot=';
      if Pos(lPrefix, Trim(lLines[I])) <> 1 then
        Continue;
      { Поля CFG должны разделяться ';'. Старые записи с ',' тоже читаем. }
      lFields.DelimitedText := StringReplace(
        Copy(Trim(lLines[I]), Length(lPrefix) + 1, MaxInt), ',', ';',
        [rfReplaceAll]);
      lSlot := StrToIntDef(lFields[0], 0) - 1;
      if (lSlot < 0) or (lSlot > High(fConfig.Slots)) then
        Continue;
      for J := 0 to High(fConfig.Slots[lSlot].Channels) do
      begin
        fConfig.Slots[lSlot].Channels[J].RangeIndex := Word(EnsureRange(
          StrToIntDef(lFields.Values['c' + IntToStr(J)], 1), 0, 5));
        fConfig.Slots[lSlot].Channels[J].Hpf := Ord(
          lFields.Values['b' + IntToStr(J)] = '1');
        fConfig.Slots[lSlot].Channels[J].Lpf := Ord(
          lFields.Values['b' + IntToStr(J + 4)] = '1');
        fConfig.Slots[lSlot].Channels[J].IcpOn := Ord(
          lFields.Values['b' + IntToStr(J + 8)] = '1');
        for K := 0 to High(fConfig.Slots[lSlot].Channels[J].BalanceDac) do
          fConfig.Slots[lSlot].Channels[J].BalanceDac[K] := Word(
            EnsureRange(StrToIntDef(lFields.Values['d' + IntToStr(J) +
              'r' + IntToStr(K)], $8080), 0, $ffff));
        { В оригинале режим ICP одновременно включает ФВЧ субмодуля и
          переводит его вход в недифференциальный режим. }
        fConfig.Slots[lSlot].Channels[J].IcpHpf :=
          fConfig.Slots[lSlot].Channels[J].IcpOn;
        if fConfig.Slots[lSlot].Channels[J].IcpOn <> 0 then
          fConfig.Slots[lSlot].Channels[J].IcpSingle := 1
        else
          fConfig.Slots[lSlot].Channels[J].IcpSingle := Word(EnsureRange(
            StrToIntDef(lFields.Values['c' + IntToStr(J + 4)], 0), 0, 1));
      end;
      fConfig.Slots[lSlot].Commutator := Word(EnsureRange(
        StrToIntDef(lFields.Values['comm'], 0), 0, 3));
      fConfig.Slots[lSlot].SubmoduleType := Word(EnsureRange(
        StrToIntDef(lFields.Values['sub'], 1), 0, 1));
    end;
  finally
    lFields.Free;
    lLines.Free;
  end;
end;

function TRecorderMcbusDevice.GetChannelBalanceDac(AChannel: Integer): Word;
var
  lChannel, lRange, lSlot: Integer;
begin
  Result := $8080;
  if (AChannel < 0) or (AChannel >= fChannelCount) then Exit;
  lSlot := fProgramInfo[AChannel div CMc201MaxModuleChannels].Slot;
  lChannel := AChannel mod CMc201MaxModuleChannels;
  lRange := EnsureRange(fConfig.Slots[lSlot].Channels[lChannel].RangeIndex,
    0, High(fConfig.Slots[lSlot].Channels[lChannel].BalanceDac));
  Result := fConfig.Slots[lSlot].Channels[lChannel].BalanceDac[lRange];
end;

function TRecorderMcbusDevice.GetSlotBalanceDac(ASlot1Based, AChannel,
  ARange: Integer): Word;
var
  lSlot: Integer;
begin
  Result := $8080;
  lSlot := ASlot1Based - 1;
  if (lSlot < 0) or (lSlot > High(fConfig.Slots)) then
    Exit;
  if (AChannel < 0) or (AChannel > High(fConfig.Slots[lSlot].Channels)) then
    Exit;
  ARange := EnsureRange(ARange, 0,
    High(fConfig.Slots[lSlot].Channels[AChannel].BalanceDac));
  Result := fConfig.Slots[lSlot].Channels[AChannel].BalanceDac[ARange];
end;

procedure TRecorderMcbusDevice.MergeSlotBalanceDacsIntoConfigText(
  var AConfigText: string; ASlot1Based: Integer);
var
  I, J, K, lRange: Integer;
  lFields, lLines: TStringList;
  lPrefix, lLine: string;
  lSlot: Integer;
  lCode: Word;
begin
  { Диалог свойств читает CFG-текст. После балансировки актуальные коды живут
    в runtime fConfig (их же шлёт ApplySavedBalanceDac). Подмешиваем их в CFG,
    иначе UI показывает нейтраль 0/0 при живом $E182. }
  lSlot := ASlot1Based - 1;
  if (lSlot < 0) or (lSlot > High(fConfig.Slots)) then
    Exit;
  lPrefix := 'CFG slot=' + IntToStr(ASlot1Based) + ';';
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  try
    lLines.Text := AConfigText;
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ';';
    lFields.NameValueSeparator := '=';
    for I := lLines.Count - 1 downto 0 do
      if Pos(lPrefix, lLines[I]) = 1 then
      begin
        lFields.DelimitedText := StringReplace(
          Copy(lLines[I], Length(lPrefix) + 1, MaxInt), ',', ';',
          [rfReplaceAll]);
        lLines.Delete(I);
      end;
    if lFields.Count = 0 then
    begin
      for J := 0 to 3 do
        lFields.Values['c' + IntToStr(J)] := '1';
      for J := 4 to 7 do
        lFields.Values['c' + IntToStr(J)] := '0';
      for J := 0 to 11 do
        lFields.Values['b' + IntToStr(J)] := '0';
      lFields.Values['comm'] := '0';
      lFields.Values['sub'] := '1';
      lFields.Values['rev'] := '0';
    end;
    for J := 0 to High(fConfig.Slots[lSlot].Channels) do
    begin
      lRange := EnsureRange(fConfig.Slots[lSlot].Channels[J].RangeIndex, 0, 5);
      lFields.Values['c' + IntToStr(J)] := IntToStr(lRange);
      for K := 0 to High(fConfig.Slots[lSlot].Channels[J].BalanceDac) do
      begin
        lCode := fConfig.Slots[lSlot].Channels[J].BalanceDac[K];
        lFields.Values['d' + IntToStr(J) + 'r' + IntToStr(K)] := IntToStr(lCode);
      end;
    end;
    lLine := lPrefix + lFields.DelimitedText;
    lLines.Add(lLine);
    AConfigText := lLines.Text;
  finally
    lFields.Free;
    lLines.Free;
  end;
end;

procedure TRecorderMcbusDevice.SetSpecificConfigText(const AText: string);
begin
  ApplySpecificConfigText(AText);
  if fHardwareInitialized then
    fConfigurationAppliedByInit := False;
end;

procedure TRecorderMcbusDevice.SetSlotSampleRate(ASlot: Integer;
  AFrequencyHz: Double);
begin
  if (ASlot < 1) or (ASlot > Length(fConfig.Slots)) then
    Exit;
  fConfig.Slots[ASlot - 1].SampleRateHz := Word(EnsureRange(
    Round(AFrequencyHz), 1, 65535));
  if fHardwareInitialized then
    fConfigurationAppliedByInit := False;
end;

destructor TRecorderMcbusDevice.Destroy;
begin
  try
    Disconnect;
  except
  end;
  fController.Free;
  inherited Destroy;
end;

procedure TRecorderMcbusDevice.AllocateBuffers;
var
  I, lCapacity: Integer;
begin
  SetLength(fPending, fChannelCount);
  SetLength(fPendingCount, fChannelCount);
  lCapacity := 1;
  for I := 0 to fChannelCount - 1 do
    lCapacity := Max(lCapacity, TargetSampleCount(I) * 2);
  for I := 0 to fChannelCount - 1 do
  begin
    SetLength(fPending[I], lCapacity);
    fPendingCount[I] := 0;
  end;
  SetLength(fReadBlock.Values, fChannelCount);
  SetLength(fReadBlock.ChannelSampleCounts, fChannelCount);
  SetLength(fReadBlock.ChannelFirstTimesSec, fChannelCount);
  SetLength(fReadBlock.ChannelSampleRatesHz, fChannelCount);
  SetLength(fSampleIndices, fChannelCount);
  SetLength(fBalanceDac, fChannelCount);
  for I := 0 to fChannelCount - 1 do
  begin
    SetLength(fReadBlock.Values[I], lCapacity);
    fBalanceDac[I] := $8080;
  end;
end;

procedure TRecorderMcbusDevice.ResetPending;
var
  I: Integer;
begin
  { Start/Stop только сбрасывают счётчики, не меняя ёмкость массивов. }
  for I := 0 to High(fPendingCount) do
    fPendingCount[I] := 0;
end;

function TRecorderMcbusDevice.ChannelSampleRate(AChannel: Integer): Double;
var
  lModule: Integer;
begin
  Result := fPollFrequencyHz;
  lModule := AChannel div CMc201MaxModuleChannels;
  if (lModule >= 0) and (lModule <= High(fProgramInfo)) and
    (fProgramInfo[lModule].SampleRateHz > 0) then
    Result := fProgramInfo[lModule].SampleRateHz;
end;

function TRecorderMcbusDevice.TargetSampleCount(AChannel: Integer): Integer;
begin
  if AChannel < 0 then
    Result := Max(1, Round(fPollFrequencyHz * fUpdateTimeMs / 1000.0))
  else
    Result := Max(1, Round(ChannelSampleRate(AChannel) *
      fUpdateTimeMs / 1000.0));
end;

function TRecorderMcbusDevice.BuildChannelName(AIndex: Integer): string;
begin
  Result := Format('MC201-%d-%d',
    [fProgramInfo[AIndex div CMc201MaxModuleChannels].Slot + 1,
     (AIndex mod CMc201MaxModuleChannels) + 1]);
end;

function TRecorderMcbusDevice.BuildChannelAddress(AIndex: Integer): string;
begin
  Result := Format('%d-%02d',
    [fProgramInfo[AIndex div CMc201MaxModuleChannels].Slot + 1,
     (AIndex mod CMc201MaxModuleChannels) + 1]);
end;

function TRecorderMcbusDevice.GetDeviceProperty(
  AProperty: TRecorderDeviceProperty; AIndex: Integer): Variant;
begin
  case AProperty of
    rdpDeviceSerial: Result := fController.Bios.DevSerNo;
    rdpErrorText: Result := fLastError;
  else
    Result := inherited GetDeviceProperty(AProperty, AIndex);
  end;
end;

function TRecorderMcbusDevice.TrySetDeviceProperty(
  AProperty: TRecorderDeviceProperty; const AValue: Variant;
  AIndex: Integer): Boolean;
begin
  Result := inherited TrySetDeviceProperty(AProperty, AValue, AIndex);
  if not Result then
    Exit;
  if fHardwareInitialized and (AProperty in
    [rdpPollFrequencyHz, rdpUpdateTimeMs]) then
    fConfigurationAppliedByInit := False;
  case AProperty of
    rdpPollFrequencyHz:
      begin
        fConfig.SampleRateHz := Word(EnsureRange(Round(fPollFrequencyHz), 1, 65535));
        fPollFrequencyHz := fConfig.SampleRateHz;
      end;
    rdpUpdateTimeMs:
      fUpdateTimeMs := Max(1, fUpdateTimeMs);
  end;
end;

procedure TRecorderMcbusDevice.Connect;
begin
  if fState <> rdsDisconnected then
    Exit;
  fController.Host := Trim(fHost);
  fController.Port := Word(fPort);
  fController.TimeoutMs := fConfig.ReadTimeoutMs;
  if not fController.TryConnect(fLastError) then
    raise ERecorderDeviceError.Create('MC-032 connect: ' + fLastError);
  { Connect только открывает и проверяет транспорт. Состав крейта читается в Init
    после RESET: предварительный поиск здесь дублировал тот же обход слотов и
    замедлял каждый холодный запуск примерно на 1,5 секунды. }
  fState := rdsConnected;
end;

procedure TRecorderMcbusDevice.Disconnect;
begin
  if fState = rdsStarted then
    Stop;
  fController.Disconnect;
  SetLength(fModules, 0);
  SetLength(fProgramInfo, 0);
  fChannelCount := 0;
  ResetPending;
  fHardwareInitialized := False;
  fConfigurationAppliedByInit := False;
  fState := rdsDisconnected;
end;

procedure TRecorderMcbusDevice.InitializeDevice;
begin
  if fState = rdsDisconnected then
    Connect;
  if fHardwareInitialized then
    Exit;
  fConfig.SampleRateHz := Word(EnsureRange(Round(fPollFrequencyHz), 1, 65535));
  { Первый проход после включения прибора включает RESET, загрузку BIOS MC-201,
    создание IDMA и начальную конфигурацию. Повторять его при Apply нельзя. }
  if not fController.Config(fConfig, fLastError) then
    raise ERecorderDeviceError.Create('MC-032 initialization: ' + fLastError);
  fModules := Copy(fController.LastModules, 0,
    Length(fController.LastModules));
  fHardwareInitialized := True;
  fConfigurationAppliedByInit := True;
  fState := rdsConnected;
end;

procedure TRecorderMcbusDevice.ConfigureDevice;
begin
  InitializeDevice;
  fConfig.SampleRateHz := Word(EnsureRange(Round(fPollFrequencyHz), 1, 65535));
  if not fConfigurationAppliedByInit then
    if not fController.ConfigKeepSession(fConfig, fLastError) then
      raise ERecorderDeviceError.Create('MC-032 configuration: ' + fLastError);
  fProgramInfo := Copy(fController.ProgramInfo, 0,
    Length(fController.ProgramInfo));
  fChannelCount := Length(fProgramInfo) * CMc201MaxModuleChannels;
  if fChannelCount = 0 then
    raise ERecorderDeviceError.Create('MC-032 programming: no MC-201 channels');
  AllocateBuffers;
  fConfigurationAppliedByInit := False;
  fState := rdsProgrammed;
end;

procedure TRecorderMcbusDevice.ProgramDevice;
begin
  InitializeDevice;
  ConfigureDevice;
end;

procedure TRecorderMcbusDevice.Start;
var
  I: Integer;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsConnected then
    ProgramDevice;
  if fState = rdsStarted then
    Exit;
  { Коды ЦАП уже переданы внутри ProgramMc201Scan в том же месте, что и в
    ModuleMC201::Programming оригинального Recorder: сразу после RESET_SCAN.
    Здесь модульные команды посылать нельзя — стартовые триггеры уже собраны. }
  if not fController.StartRawScan(fLastError) then
    raise ERecorderDeviceError.Create('MC-032 start: ' + fLastError);
  for I := 0 to High(fSampleIndices) do
    fSampleIndices[I] := 0;
  ResetPending;
  fReceivedSinceStart := False;
  fState := rdsStarted;
end;

procedure TRecorderMcbusDevice.ApplySavedBalanceDac;
var
  lError: string;
begin
  if not TryApplySavedBalanceDac(lError) then
    raise ERecorderDeviceError.Create(lError);
end;

function TRecorderMcbusDevice.TryApplySavedBalanceDac(
  out AErrorText: string): Boolean;
var
  I, lChannelInSlot: Integer;
  lCode: Word;
  lSlot: Word;
begin
  Result := False;
  AErrorText := '';
  if fState = rdsDisconnected then
  begin
    AErrorText := 'MC-032 is not connected';
    Exit;
  end;
  for I := 0 to fChannelCount - 1 do
  begin
    lSlot := fProgramInfo[I div CMc201MaxModuleChannels].Slot;
    lChannelInSlot := I mod CMc201MaxModuleChannels;
    lCode := GetChannelBalanceDac(I);
    if lCode <> $8080 then
      BalanceTrace(Format(
        'ApplySavedBalanceDac ch=%d slot=%d idx=%d code=$%.4x',
        [I, lSlot + 1, lChannelInSlot, lCode]));
    if not fController.SendBalanceDac(lSlot, lChannelInSlot,
      lCode and $ff, lCode shr 8, fLastError) then
    begin
      AErrorText := Format('MC-032 restore balance slot=%d channel=%d: %s',
        [lSlot + 1, lChannelInSlot + 1, fLastError]);
      BalanceTrace(AErrorText);
      Exit;
    end;
  end;
  Result := True;
end;

procedure TRecorderMcbusDevice.Stop;
begin
  if fState <> rdsStarted then
    Exit;
  if not fReceivedSinceStart then
  begin
    { После START не пришло ни одного корректного сообщения: не пишем STOP в
      уже сомнительный TCP и не провоцируем EMc201MdpProtocol в отладчике. }
    RecorderDebugLog('[MCBUS] stop without RX: local disconnect, no STOP write');
    fController.ForceDisconnect(False);
    ResetPending;
    fState := rdsDisconnected;
    Exit;
  end;
  if not fController.Stop(fLastError) then
  begin
    { STOPSCANMAIN is best-effort during teardown. Reply may be lost in
      stream noise; TMc032Device soft-stops and keeps TCP when possible.
      If session was still closed, mark disconnected — do not raise. }
    ResetPending;
    fState := rdsDisconnected;
    Exit;
  end;
  ResetPending;
  fState := rdsProgrammed;
end;

function TRecorderMcbusDevice.ChannelIndex(ASlot, AFlag: Word): Integer;
var
  I, J: Integer;
begin
  Result := -1;
  for I := 0 to High(fProgramInfo) do
    if fProgramInfo[I].Slot = ASlot then
      for J := 0 to CMc201MaxModuleChannels - 1 do
        if fProgramInfo[I].FinalFlags[J] = AFlag then
          Exit(I * CMc201MaxModuleChannels + J);
end;

function TRecorderMcbusDevice.AcceptPacket(
  const AWords: TMc201WordArray): Boolean;
var
  I, lChannel, lNeeded: Integer;
begin
  Result := False;
  if Length(AWords) <= CMc201BiosMessageHeaderWords then
    Exit;
  if AWords[1] <> Length(AWords) then
    Exit;
  lChannel := ChannelIndex(AWords[3], AWords[4]);
  if lChannel < 0 then
    Exit;
  fReceivedSinceStart := True;
  lNeeded := fPendingCount[lChannel] + Length(AWords) -
    CMc201BiosMessageHeaderWords;
  if Length(fPending[lChannel]) < lNeeded then
  begin
    fLastError := Format('MC-201 pending overflow channel=%d need=%d capacity=%d',
      [lChannel, lNeeded, Length(fPending[lChannel])]);
    Exit;
  end;
  for I := CMc201BiosMessageHeaderWords to High(AWords) do
  begin
    fPending[lChannel][fPendingCount[lChannel]] := SmallInt(AWords[I]);
    Inc(fPendingCount[lChannel]);
  end;
  Result := True;
end;

function TRecorderMcbusDevice.PendingComplete: Boolean;
var
  I: Integer;
begin
  Result := fChannelCount > 0;
  for I := 0 to fChannelCount - 1 do
    if fPendingCount[I] < TargetSampleCount(I) then
      Exit(False);
end;

function TRecorderMcbusDevice.CollectChannelMean(AChannel,
  ASampleCount: Integer; out AMean: Double; out AErrorText: string): Boolean;
var
  I, lCount, lPacketChannel, lMsgTotal, lMsgMatch, lMsgSkip: Integer;
  lSum: Double;
  lDeadline, lStartedAt: QWord;
  lPort: Word;
  lTimeoutMs: Cardinal;
  lWords: TMc201WordArray;
begin
  Result := False;
  AMean := 0;
  AErrorText := '';
  lCount := 0;
  lSum := 0;
  lMsgTotal := 0;
  lMsgMatch := 0;
  lMsgSkip := 0;
  { Таймаут: время на нужное число отсчётов канала + запас на прогрев потока. }
  lTimeoutMs := Max(Cardinal(3000), fConfig.ReadTimeoutMs);
  if ChannelSampleRate(AChannel) > 0 then
    lTimeoutMs := Max(lTimeoutMs, Cardinal(Round(
      ASampleCount / ChannelSampleRate(AChannel) * 1000.0) + 1500));
  lStartedAt := GetTickCount64;
  lDeadline := lStartedAt + lTimeoutMs;
  BalanceTrace(Format(
    'CollectChannelMean: ch=%d need=%d timeoutMs=%d state=%d ctrlState=%s',
    [AChannel, ASampleCount, lTimeoutMs, Ord(fState),
     Mc032StateToString(fController.State)]));
  repeat
    if fController.ReadRawMessage(lPort, lWords) and
      (Length(lWords) > CMc201BiosMessageHeaderWords) and
      (lWords[1] = Length(lWords)) then
    begin
      Inc(lMsgTotal);
      lPacketChannel := ChannelIndex(lWords[3], lWords[4]);
      if lPacketChannel = AChannel then
      begin
        Inc(lMsgMatch);
        for I := CMc201BiosMessageHeaderWords to High(lWords) do
        begin
          lSum := lSum + SmallInt(lWords[I]);
          Inc(lCount);
          if lCount >= ASampleCount then
            Break;
        end;
      end
      else
        Inc(lMsgSkip);
    end;
    if lCount >= ASampleCount then Break;
  until GetTickCount64 >= lDeadline;
  BalanceTrace(Format(
    'CollectChannelMean done: got=%d/%d msgs=%d match=%d skip=%d elapsedMs=%d',
    [lCount, ASampleCount, lMsgTotal, lMsgMatch, lMsgSkip,
     GetTickCount64 - lStartedAt]));
  if lCount < ASampleCount then
  begin
    AErrorText := Format('MC-201 balance sample timeout: %d/%d (msgs=%d match=%d)',
      [lCount, ASampleCount, lMsgTotal, lMsgMatch]);
    BalanceTrace(AErrorText);
    Exit;
  end;
  AMean := lSum / lCount;
  BalanceTrace(Format('собрано %d отсчётов, среднее=%.3f',
    [lCount, AMean]));
  Result := True;
end;

function TRecorderMcbusDevice.CollectChannelsMean(
  const AChannels: array of Integer; const ASampleCounts: array of Integer;
  out AMeans: TDoubleDynArray; out AOk: TBooleanDynArray;
  out AErrorText: string): Boolean;
var
  I, J, lPacketChannel, lDone, lMsgTotal, lOkCount: Integer;
  lCounts: array of Integer;
  lSums: array of Double;
  lDeadline, lStartedAt: QWord;
  lPort: Word;
  lTimeoutMs: Cardinal;
  lWords: TMc201WordArray;
  lFs: Double;
begin
  Result := False;
  AErrorText := '';
  SetLength(AMeans, Length(AChannels));
  SetLength(AOk, Length(AChannels));
  SetLength(lCounts, Length(AChannels));
  SetLength(lSums, Length(AChannels));
  if Length(AChannels) = 0 then
  begin
    Result := True;
    Exit;
  end;
  if Length(ASampleCounts) <> Length(AChannels) then
  begin
    AErrorText := 'CollectChannelsMean: размер sampleCounts не совпадает';
    Exit;
  end;
  for I := 0 to High(AChannels) do
  begin
    lCounts[I] := 0;
    lSums[I] := 0;
    AMeans[I] := 0;
    AOk[I] := False;
  end;
  lTimeoutMs := Max(Cardinal(3000), fConfig.ReadTimeoutMs);
  for I := 0 to High(AChannels) do
  begin
    lFs := ChannelSampleRate(AChannels[I]);
    if (ASampleCounts[I] > 0) and (lFs > 0) then
      lTimeoutMs := Max(lTimeoutMs,
        Cardinal(Round(ASampleCounts[I] / lFs * 1000.0) + 2000));
  end;
  lStartedAt := GetTickCount64;
  lDeadline := lStartedAt + lTimeoutMs;
  lMsgTotal := 0;
  BalanceTrace(Format(
    'CollectChannelsMean: n=%d timeoutMs=%d',
    [Length(AChannels), lTimeoutMs]));
  for I := 0 to High(AChannels) do
    BalanceTrace(Format('  need[%d] ch=%d samples=%d fs=%.1f',
      [I, AChannels[I], ASampleCounts[I], ChannelSampleRate(AChannels[I])]));
  repeat
    if fController.ReadRawMessage(lPort, lWords) and
      (Length(lWords) > CMc201BiosMessageHeaderWords) and
      (lWords[1] = Length(lWords)) then
    begin
      Inc(lMsgTotal);
      lPacketChannel := ChannelIndex(lWords[3], lWords[4]);
      for J := 0 to High(AChannels) do
        if (AChannels[J] = lPacketChannel) and
          (lCounts[J] < ASampleCounts[J]) then
        begin
          for I := CMc201BiosMessageHeaderWords to High(lWords) do
          begin
            lSums[J] := lSums[J] + SmallInt(lWords[I]);
            Inc(lCounts[J]);
            if lCounts[J] >= ASampleCounts[J] then
              Break;
          end;
          Break;
        end;
    end;
    lDone := 0;
    for J := 0 to High(AChannels) do
      if lCounts[J] >= ASampleCounts[J] then
        Inc(lDone);
    if lDone >= Length(AChannels) then
      Break;
  until GetTickCount64 >= lDeadline;
  lOkCount := 0;
  for J := 0 to High(AChannels) do
  begin
    if (ASampleCounts[J] > 0) and (lCounts[J] >= ASampleCounts[J]) then
    begin
      AMeans[J] := lSums[J] / lCounts[J];
      AOk[J] := True;
      Inc(lOkCount);
    end
    else
      BalanceTrace(Format('  skip ch=%d: got=%d/%d',
        [AChannels[J], lCounts[J], ASampleCounts[J]]));
  end;
  BalanceTrace(Format(
    'CollectChannelsMean done: ok=%d/%d msgs=%d elapsedMs=%d',
    [lOkCount, Length(AChannels), lMsgTotal, GetTickCount64 - lStartedAt]));
  for J := 0 to High(AChannels) do
    if AOk[J] then
      BalanceTrace(Format('  mean[%d] ch=%d = %.3f',
        [J, AChannels[J], AMeans[J]]));
  if lOkCount = 0 then
  begin
    AErrorText := Format(
      'MC-201 multi balance: нет данных ни по одному каналу (msgs=%d)',
      [lMsgTotal]);
    Exit;
  end;
  Result := True;
end;

function TRecorderMcbusDevice.BalanceChannelsHardware(
  const AChannels: array of Integer; out AMeans: TDoubleDynArray;
  out AErrorText: string): Boolean;
const
  CMc201AdcCodesPerDacProduct = 2.8;
var
  I, lChannelInSlot, lHi, lHiOffset, lLo, lLoOffset, lProgCount: Integer;
  lSlot: Word;
  lCodes, lOldCodes: array of Word;
  lNeeds: array of Integer;
  lOk: TBooleanDynArray;
  lPort: Word;
  lWords: TMc201WordArray;
  lWarmDeadline: QWord;
  lFs, lTargetProduct: Double;
  lOldTimeout: Cardinal;
begin
  Result := False;
  AErrorText := '';
  SetLength(AMeans, 0);
  if Length(AChannels) = 0 then
  begin
    Result := True;
    Exit;
  end;
  for I := 0 to High(AChannels) do
    if (AChannels[I] < 0) or (AChannels[I] >= fChannelCount) then
    begin
      AErrorText := Format('Канал MC-201 с индексом %d не найден',
        [AChannels[I]]);
      Exit;
    end;

  SetLength(lNeeds, Length(AChannels));
  SetLength(lOldCodes, Length(AChannels));
  SetLength(lCodes, Length(AChannels));
  for I := 0 to High(AChannels) do
  begin
    lFs := ChannelSampleRate(AChannels[I]);
    lNeeds[I] := Max(3, Min(2048, Round(lFs * 0.06)));
    lOldCodes[I] := GetChannelBalanceDac(AChannels[I]);
    lCodes[I] := lOldCodes[I];
  end;
  BalanceTrace(Format(
    'BalanceChannelsHardware: n=%d (prepare → settle 1s → collect → apply)',
    [Length(AChannels)]));

  { 1) Подготовка всем сразу: Stop → SEND $8080 → Start. }
  BalanceTrace('phase prepare: Stop + SEND $8080 all + Start');
  for I := 0 to High(AChannels) do
  begin
    lSlot := fProgramInfo[AChannels[I] div CMc201MaxModuleChannels].Slot;
    lChannelInSlot := AChannels[I] mod CMc201MaxModuleChannels;
    if Length(fBalanceDac) > AChannels[I] then
      fBalanceDac[AChannels[I]] := $8080;
    fConfig.Slots[lSlot].Channels[lChannelInSlot].BalanceDac[
      EnsureRange(fConfig.Slots[lSlot].Channels[lChannelInSlot].RangeIndex,
        0, 5)] := $8080;
  end;
  if not fController.Stop(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 multi balance prepare stop: ' + AErrorText;
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;
  for I := 0 to High(AChannels) do
  begin
    lSlot := fProgramInfo[AChannels[I] div CMc201MaxModuleChannels].Slot;
    lChannelInSlot := AChannels[I] mod CMc201MaxModuleChannels;
    if not fController.SendBalanceDac(lSlot, lChannelInSlot, $80, $80,
      AErrorText) then
    begin
      BalanceTrace('neutral SEND failed: ' + AErrorText);
      Exit;
    end;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 multi balance prepare start: ' + AErrorText;
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;

  { 2) Секунда прогрева — читаем и отбрасываем, TCP не забиваем. }
  BalanceTrace('phase settle: 1000 ms warmup discard');
  lWarmDeadline := GetTickCount64 + 1000;
  while GetTickCount64 < lWarmDeadline do
    fController.ReadRawMessage(lPort, lWords);

  { 3) Одновременный сбор; без квоты — канал пропускаем. }
  BalanceTrace('phase collect');
  if not CollectChannelsMean(AChannels, lNeeds, AMeans, lOk, AErrorText) then
    Exit;

  { 4) Сразу Stop — до compute/логов, иначе RX копится и CallCommand(STOP)
    не успевает найти reply (15с). quiet без ACK допустим. }
  BalanceTrace('phase stop-before-compute: StopAfterHeavyStream');
  if not fController.StopAfterHeavyStream(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 multi balance stop: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;

  { 5) Расчёт на тихой шине. }
  BalanceTrace('phase compute');
  lProgCount := 0;
  for I := 0 to High(AChannels) do
  begin
    if not lOk[I] then
    begin
      lCodes[I] := lOldCodes[I];
      AMeans[I] := 0;
      BalanceTrace(Format('  ch=%d SKIP keep $%.4x',
        [AChannels[I], lCodes[I]]));
      Continue;
    end;
    lTargetProduct := Abs(AMeans[I]) / CMc201AdcCodesPerDacProduct;
    lLoOffset := EnsureRange(Ceil(lTargetProduct / 127.0), 1, 127);
    lHiOffset := EnsureRange(Round(lTargetProduct / lLoOffset), 0, 127);
    lLo := 128 + lLoOffset;
    if AMeans[I] >= 0 then
      lHi := 128 + lHiOffset
    else
      lHi := 128 - lHiOffset;
    lHi := EnsureRange(lHi, 0, 255);
    lCodes[I] := Word((lHi shl 8) or lLo);
    Inc(lProgCount);
    BalanceTrace(Format('  ch=%d mean=%.3f code=$%.4x',
      [AChannels[I], AMeans[I], lCodes[I]]));
  end;
  if lProgCount = 0 then
  begin
    AErrorText := 'MC-201 multi balance: нечего программировать';
    Exit;
  end;

  { 6) SEND + StartRawScan на уже остановленной шине. }
  BalanceTrace(Format('phase apply: SEND + StartRawScan (%d new)',
    [lProgCount]));
  for I := 0 to High(AChannels) do
  begin
    lSlot := fProgramInfo[AChannels[I] div CMc201MaxModuleChannels].Slot;
    lChannelInSlot := AChannels[I] mod CMc201MaxModuleChannels;
    if Length(fBalanceDac) > AChannels[I] then
      fBalanceDac[AChannels[I]] := lCodes[I];
    fConfig.Slots[lSlot].Channels[lChannelInSlot].BalanceDac[
      EnsureRange(fConfig.Slots[lSlot].Channels[lChannelInSlot].RangeIndex,
        0, 5)] := lCodes[I];
  end;

  lOldTimeout := fController.TimeoutMs;
  try
    if fController.TimeoutMs < CRecorderDeviceCommandTimeoutMs then
      fController.TimeoutMs := CRecorderDeviceCommandTimeoutMs;
    BalanceTrace('apply: TryApplySavedBalanceDac');
    if not TryApplySavedBalanceDac(AErrorText) then
    begin
      BalanceTrace(AErrorText);
      Exit;
    end;
    BalanceTrace('apply: StartRawScan');
    if not fController.StartRawScan(AErrorText) then
    begin
      fState := rdsDisconnected;
      AErrorText := 'MC-201 multi balance apply start: ' + AErrorText;
      BalanceTrace(AErrorText);
      Exit;
    end;
  finally
    fController.TimeoutMs := lOldTimeout;
  end;
  ResetPending;
  fState := rdsStarted;

  Result := True;
  BalanceTrace(Format('BalanceChannelsHardware OK programmed=%d/%d',
    [lProgCount, Length(AChannels)]));
end;

function TRecorderMcbusDevice.BalanceChannelHardware(AChannel: Integer;
  out AFinalMean: Double; out AErrorText: string): Boolean;
var
  lChans: array of Integer;
  lMeans: TDoubleDynArray;
begin
  SetLength(lChans, 1);
  lChans[0] := AChannel;
  Result := BalanceChannelsHardware(lChans, lMeans, AErrorText);
  if Result and (Length(lMeans) > 0) then
    AFinalMean := lMeans[0]
  else
    AFinalMean := 0;
end;

function TRecorderMcbusDevice.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderAcquisitionBlock): Boolean;
var
  I, J, lCount, lRemaining: Integer;
  lDeadline: QWord;
  lPort: Word;
  lWords: TMc201WordArray;
begin
  ABlock.ChannelCount := 0;
  ABlock.SampleCount := 0;
  Result := False;
  if fState <> rdsStarted then
    Exit;
  lDeadline := GetTickCount64 + ATimeoutMs;
  repeat
    if fController.ReadRawMessage(lPort, lWords) then
      AcceptPacket(lWords);
    if PendingComplete then
      Break;
  until GetTickCount64 >= lDeadline;
  if not PendingComplete then
    Exit;

  lCount := 0;
  for I := 0 to fChannelCount - 1 do
    lCount := Max(lCount, TargetSampleCount(I));
  fReadBlock.ChannelCount := fChannelCount;
  fReadBlock.SampleCount := lCount;
  fReadBlock.SampleRateHz := fPollFrequencyHz;
  fReadBlock.FirstTimeSec := 0;
  for I := 0 to fChannelCount - 1 do
  begin
    fReadBlock.ChannelSampleCounts[I] := TargetSampleCount(I);
    fReadBlock.ChannelSampleRatesHz[I] := ChannelSampleRate(I);
    fReadBlock.ChannelFirstTimesSec[I] :=
      fSampleIndices[I] / ChannelSampleRate(I);
    for J := 0 to TargetSampleCount(I) - 1 do
      fReadBlock.Values[I][J] := fPending[I][J];
    Inc(fSampleIndices[I], TargetSampleCount(I));
  end;
  for I := 0 to fChannelCount - 1 do
  begin
    lCount := TargetSampleCount(I);
    lRemaining := fPendingCount[I] - lCount;
    if lRemaining > 0 then
      Move(fPending[I][lCount], fPending[I][0], lRemaining * SizeOf(Double));
    fPendingCount[I] := lRemaining;
  end;
  { Блок передаётся по ссылке на заранее выделенные массивы устройства. }
  ABlock := fReadBlock;
  Result := True;
end;

function TRecorderMcbusDevice.TestLink(out AErrorText: string): Boolean;
begin
  { Во время сканирования сам поток корректных данных уже подтверждает связь.
    Посылать служебный TEST в занятую потоковую MDP-сессию нельзя: ответ может
    смешаться с пакетами данных и дать ложный offline-статус. }
  if fState = rdsStarted then
  begin
    AErrorText := '';
    fLastError := '';
    Exit(True);
  end;
  { TEST обязан работать до Connect: источник вызывает его как безопасный
    предикат перед операциями, которые используют исключения. }
  fController.Host := Trim(fHost);
  fController.Port := Word(fPort);
  fController.TimeoutMs := fConfig.ReadTimeoutMs;
  if not fController.TryConnect(AErrorText) then
  begin
    fLastError := AErrorText;
    Exit(False);
  end;
  { TEST — только предикат доступности, а не начало рабочего жизненного цикла.
    Контроллер может закрыть TCP-сеанс после TEST_LOAD. Если оставить такой
    сокет внутри TMc032Device, следующий Connect увидит mcsConnected и первая
    команда Init/Config попадёт в уже закрытое соединение. Поэтому рабочий
    Connect всегда открывает отдельный свежий сеанс после проверки. }
  Result := fController.TestConnection(AErrorText);
  fController.ForceDisconnect(False);
  if Result then
    fLastError := ''
  else
    fLastError := AErrorText;
end;

function TRecorderMcbusDevice.SupportsDeviceAction(
  AAction: TRecorderDeviceAction): Boolean;
begin
  Result := AAction in [rdaZeroBalance, rdaHardwareSetup,
    rdaReadHardwareCalibration];
end;

function TRecorderMcbusDevice.ExecuteDeviceAction(
  AAction: TRecorderDeviceAction; const AChannelIndices: array of Integer;
  out AValues: TRecorderDeviceActionValues; out AErrorText: string): Boolean;
var
  I: Integer;
  lMeans: TDoubleDynArray;
  lStartedHere: Boolean;
begin
  SetLength(AValues, 0);
  AErrorText := '';
  if AAction <> rdaZeroBalance then
    Exit(inherited ExecuteDeviceAction(AAction, AChannelIndices, AValues,
      AErrorText));
  { Балансировка из диалога тега часто вызывается без Preview. Нужен активный
    скан (STARTSCANMAIN) для сбора среднего; поднимаем его здесь, если ещё не
    запущен. Остановленный сами — только если старт был служебным. }
  BalanceTrace(Format(
    'ExecuteDeviceAction ZeroBalance: channels=%d state=%d ctrl=%s',
    [Length(AChannelIndices), Ord(fState), Mc032StateToString(fController.State)]));
  lStartedHere := False;
  if fState <> rdsStarted then
  begin
    try
      BalanceTrace('Start before balance...');
      Start;
      lStartedHere := True;
      BalanceTrace(Format('служебный скан запущен; state=%d ctrl=%s',
        [Ord(fState), Mc032StateToString(fController.State)]));
    except
      on E: Exception do
      begin
        AErrorText := 'Не удалось запустить скан для балансировки MC-201: ' +
          E.Message;
        BalanceTrace(AErrorText);
        Exit(False);
      end;
    end;
  end;
  if fState <> rdsStarted then
  begin
    AErrorText := 'Скан MC-201 не активен, балансировка невозможна';
    BalanceTrace(AErrorText);
    Exit(False);
  end;
  fController.PauseStreamingReader;
  BalanceTrace('фоновое чтение просмотра приостановлено');
  try
    { Пакетный путь: общая подготовка/сбор/программирование. }
    if not BalanceChannelsHardware(AChannelIndices, lMeans, AErrorText) then
    begin
      BalanceTrace(Format('BalanceChannelsHardware failed: %s', [AErrorText]));
      Exit(False);
    end;
    SetLength(AValues, Length(lMeans));
    for I := 0 to High(lMeans) do
      AValues[I] := lMeans[I];
    Result := True;
    BalanceTrace('ExecuteDeviceAction ZeroBalance OK');
  finally
    fController.ResumeStreamingReader;
    BalanceTrace('фоновое чтение просмотра восстановлено');
    if lStartedHere and (fState = rdsStarted) then
    begin
      Stop;
      BalanceTrace('служебный скан после балансировки остановлен');
    end;
  end;
end;

initialization
  RecorderRegisterHardwareSourceLinkProbe(@RecorderMc032HardwareLinkProbe);

end.
