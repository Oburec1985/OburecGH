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
  Classes, SysUtils, Variants,
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
    procedure ApplySpecificConfigText(const AText: string);
    procedure AllocateBuffers;
    procedure ResetPending;
    function ChannelIndex(ASlot, AFlag: Word): Integer;
    function AcceptPacket(const AWords: TMc201WordArray): Boolean;
    function PendingComplete: Boolean;
    function ChannelSampleRate(AChannel: Integer): Double;
    function CollectChannelMean(AChannel, ASampleCount: Integer;
      out AMean: Double; out AErrorText: string): Boolean;
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
end;

procedure TRecorderMcbusDevice.SetSlotSampleRate(ASlot: Integer;
  AFrequencyHz: Double);
begin
  if (ASlot < 1) or (ASlot > Length(fConfig.Slots)) then
    Exit;
  fConfig.Slots[ASlot - 1].SampleRateHz := Word(EnsureRange(
    Round(AFrequencyHz), 1, 65535));
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
  if not fController.SearchModules(fConfig.MaxSlots, fModules, fLastError) then
  begin
    fController.Disconnect;
    raise ERecorderDeviceError.Create('MC-032 module search: ' + fLastError);
  end;
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
  fState := rdsDisconnected;
end;

procedure TRecorderMcbusDevice.ProgramDevice;
begin
  if fState = rdsDisconnected then
    Connect;
  fConfig.SampleRateHz := Word(EnsureRange(Round(fPollFrequencyHz), 1, 65535));
  if not fController.Config(fConfig, fLastError) then
    raise ERecorderDeviceError.Create('MC-032 programming: ' + fLastError);
  fProgramInfo := Copy(fController.ProgramInfo, 0,
    Length(fController.ProgramInfo));
  fChannelCount := Length(fProgramInfo) * CMc201MaxModuleChannels;
  if fChannelCount = 0 then
    raise ERecorderDeviceError.Create('MC-032 programming: no MC-201 channels');
  AllocateBuffers;
  fState := rdsProgrammed;
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
  { Модульные команды нельзя вклинивать после STARTSCANMAIN: они конкурируют с
    потоком измерительных пакетов. Восстанавливаем регистры до запуска потока. }
  ApplySavedBalanceDac;
  if not fController.StartRawScan(fLastError) then
    raise ERecorderDeviceError.Create('MC-032 start: ' + fLastError);
  for I := 0 to High(fSampleIndices) do
    fSampleIndices[I] := 0;
  ResetPending;
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
  if not fController.Stop(fLastError) then
  begin
    { STOPSCANMAIN is best-effort during teardown. The controller may keep
      streaming long enough for its command reply to be lost among data
      packets. TMc032Device already closes that ambiguous TCP session; do not
      turn an idempotent Recorder stop into an application exception. }
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

function TRecorderMcbusDevice.BalanceChannelHardware(AChannel: Integer;
  out AFinalMean: Double; out AErrorText: string): Boolean;
const
  { В MC-201 используются два отдельных 8-битных балансировочных ЦАП в
    смещённом формате: 0=-128, 128=0, 255=+127. Это не половины одного
    16-битного слова. Стенд подтвердил мультипликативную характеристику:
    поправка АЦП ~= 2,8*(lo-128)*(hi-128). Как в оригинальном Recorder,
    выбираем минимальную достаточную грубую ступень lo, чтобы сохранить
    максимальное разрешение тонкой ступени hi. }
  CMc201AdcCodesPerDacProduct = 2.8;
var
  lChannelInSlot, lHi, lHiOffset, lLo, lLoOffset: Integer;
  lModuleIndex, lSamples, lVerifySamples: Integer;
  lTargetProduct: Double;
  lVerifyMean: Double;
  lNewCode: Word;
  lOldCode: Word;
  lSlot: Word;
begin
  Result := False;
  AFinalMean := 0;
  AErrorText := '';
  lModuleIndex := AChannel div CMc201MaxModuleChannels;
  lSlot := fProgramInfo[lModuleIndex].Slot;
  lChannelInSlot := AChannel mod CMc201MaxModuleChannels;
  { Оценка среднего: окно как у оригинала (~0.06*Fs), но не больше одной
    завершённой MDP-порции (2048). Запрос на целую секунду при Fs=57600
    давал timeout 2048/57600 и требовал несколько повторных нажатий. }
  lSamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  lOldCode := GetChannelBalanceDac(AChannel);
  BalanceTrace(Format(
    'начало: индекс=%d, слот=%d, канал=%d, Fs=%.3f, проба=%d, старый ЦАП=$%.4x, devState=%d',
    [AChannel, lSlot + 1, lChannelInSlot + 1, ChannelSampleRate(AChannel),
     lSamples, lOldCode, Ord(fState)]));
  { Open-loop считает поправку только от нейтрали ($8080). Сначала всегда
    гасим ЦАП через Stop → SEND $8080 → Start, иначе повтор меряет уже
    скорректированный вход и ломает рабочий код. }
  BalanceTrace(Format('сброс ЦАП в нейтраль $8080 (было $%.4x)', [lOldCode]));
  fBalanceDac[AChannel] := $8080;
  fConfig.Slots[lSlot].Channels[AChannel mod CMc201MaxModuleChannels].
    BalanceDac[EnsureRange(fConfig.Slots[lSlot].Channels[AChannel mod
      CMc201MaxModuleChannels].RangeIndex, 0, 5)] := $8080;
  if not fController.Stop(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance neutral stop: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;
  if not fController.SendBalanceDac(lSlot, lChannelInSlot, $80, $80,
    AErrorText) then
  begin
    BalanceTrace('neutral SEND_BALANCE failed: ' + AErrorText);
    Exit;
  end;
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance neutral start: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;
  if not CollectChannelMean(AChannel, lSamples, AFinalMean, AErrorText) then
    Exit;
  lTargetProduct := Abs(AFinalMean) / CMc201AdcCodesPerDacProduct;
  lLoOffset := EnsureRange(Ceil(lTargetProduct / 127.0), 1, 127);
  lHiOffset := EnsureRange(Round(lTargetProduct / lLoOffset), 0, 127);
  lLo := 128 + lLoOffset;
  if AFinalMean >= 0 then
    lHi := 128 + lHiOffset
  else
    lHi := 128 - lHiOffset;
  lHi := EnsureRange(lHi, 0, 255);
  lNewCode := Word((lHi shl 8) or lLo);
  BalanceTrace(Format(
    'расчёт от нейтрали: среднее=%.3f, произведение=%.3f, lo=%d hi=%d ($%.4x)',
    [AFinalMean, lTargetProduct, lLo, lHi, lNewCode]));
  { Soft + Stop → SEND новый код → Start → verify. STOPSCANMAIN сбрасывает
    регистр ЦАП, поэтому SEND до STARTSCANMAIN обязателен. }
  fBalanceDac[AChannel] := lNewCode;
  fConfig.Slots[lSlot].Channels[AChannel mod CMc201MaxModuleChannels].
    BalanceDac[EnsureRange(fConfig.Slots[lSlot].Channels[AChannel mod
      CMc201MaxModuleChannels].RangeIndex, 0, 5)] := lNewCode;
  BalanceTrace(Format('SEND_BALANCE_CC slot=%d ch=%d lo=%d hi=%d',
    [lSlot, lChannelInSlot, lLo, lHi]));
  if not fController.Stop(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance apply stop: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  if fState = rdsStarted then
    fState := rdsProgrammed;
  if not fController.SendBalanceDac(lSlot, lChannelInSlot, lLo, lHi,
    AErrorText) then
  begin
    BalanceTrace('SEND_BALANCE_CC failed: ' + AErrorText);
    Exit;
  end;
  BalanceTrace('DAC set after Stop; StartRawScan + verify');
  if not fController.StartRawScan(AErrorText) then
  begin
    fState := rdsDisconnected;
    AErrorText := 'MC-201 balance apply start: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  fState := rdsStarted;
  ResetPending;
  lVerifySamples := Max(3, Min(2048, Round(ChannelSampleRate(AChannel) * 0.06)));
  BalanceTrace(Format('verify samples=%d', [lVerifySamples]));
  if not CollectChannelMean(AChannel, lVerifySamples, lVerifyMean,
    AErrorText) then
  begin
    AErrorText := 'MC-201 balance apply sample: ' + AErrorText;
    BalanceTrace(AErrorText);
    Exit;
  end;
  BalanceTrace(Format(
    'apply cycle done: verifyMean=%.3f code=$%.4x (было $%.4x)',
    [lVerifyMean, lNewCode, lOldCode]));
  RecorderDebugLog(Format(
    '[MCBUS] balance DAC applied slot=%d channel=%d code=$%.4x mean=%.3f verify=%.3f',
    [lSlot + 1, lChannelInSlot + 1, lNewCode, AFinalMean, lVerifyMean]));
  ResetPending;
  Result := True;
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
  { TEST выполняется в том же TCP-сеансе, который затем использует Connect.
    Не закрываем успешную проверку: старый контроллер может не принять
    немедленное повторное соединение после отдельного probe-сеанса. }
  Result := fController.TestConnection(AErrorText);
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
  I, lChannel: Integer;
  lMean: Double;
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
    SetLength(AValues, Length(AChannelIndices));
    for I := 0 to High(AChannelIndices) do
    begin
      lChannel := AChannelIndices[I];
      BalanceTrace(Format('channel[%d]=%d', [I, lChannel]));
      if (lChannel < 0) or (lChannel >= fChannelCount) then
      begin
        AErrorText := Format('Канал MC-201 с индексом %d не найден', [lChannel]);
        BalanceTrace(AErrorText);
        Exit(False);
      end;
      if not BalanceChannelHardware(lChannel, lMean, AErrorText) then
      begin
        BalanceTrace(Format('BalanceChannelHardware failed: %s', [AErrorText]));
        Exit(False);
      end;
      AValues[I] := lMean;
      BalanceTrace(Format('channel[%d] ok mean=%.3f', [I, lMean]));
    end;
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
