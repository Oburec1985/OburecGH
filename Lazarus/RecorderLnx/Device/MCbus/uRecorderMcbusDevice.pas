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
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
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
    fSoftBalance: array of Double;
    fSampleIndices: array of Int64;
    fLastError: string;
    procedure ApplySpecificConfigText(const AText: string);
    procedure AllocateBuffers;
    procedure ResetPending;
    function ChannelIndex(ASlot, AFlag: Word): Integer;
    function AcceptPacket(const AWords: TMc201WordArray): Boolean;
    function PendingComplete: Boolean;
    function ChannelSampleRate(AChannel: Integer): Double;
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
    function ExecuteDeviceAction(AAction: TRecorderDeviceAction;
      const AChannelIndices: array of Integer; out AValues: TRecorderDeviceActionValues;
      out AErrorText: string): Boolean; override;
    procedure SetSpecificConfigText(const AText: string);
    procedure SetSlotSampleRate(ASlot: Integer; AFrequencyHz: Double);
  end;

function CreateRecorderMcbusDevice: IRecorderDevice;

implementation

uses
  Math, StrUtils, uRecorderHardwareTree;

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
  I, J: Integer;
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
      fConfig.Slots[I].Channels[J].RangeIndex := 1;
  end;
  fController := TMc032Device.Create;
end;

procedure TRecorderMcbusDevice.ApplySpecificConfigText(const AText: string);
var
  I, J, lSlot: Integer;
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
      lFields.DelimitedText := Copy(Trim(lLines[I]), Length(lPrefix) + 1,
        MaxInt);
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
  SetLength(fSoftBalance, fChannelCount);
  for I := 0 to fChannelCount - 1 do
    SetLength(fReadBlock.Values[I], lCapacity);
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
  if not fController.StartRawScan(fLastError) then
    raise ERecorderDeviceError.Create('MC-032 start: ' + fLastError);
  for I := 0 to High(fSampleIndices) do
    fSampleIndices[I] := 0;
  ResetPending;
  fState := rdsStarted;
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
      fReadBlock.Values[I][J] := fPending[I][J] - fSoftBalance[I];
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
  I, J, lChannel, lCount: Integer;
  lMean: Double;
begin
  SetLength(AValues, 0);
  AErrorText := '';
  if AAction <> rdaZeroBalance then
    Exit(inherited ExecuteDeviceAction(AAction, AChannelIndices, AValues,
      AErrorText));
  if fState <> rdsStarted then
  begin
    AErrorText := 'Для балансировки MC-201 требуется запущенный просмотр';
    Exit(False);
  end;
  SetLength(AValues, Length(AChannelIndices));
  for I := 0 to High(AChannelIndices) do
  begin
    lChannel := AChannelIndices[I];
    if (lChannel < 0) or (lChannel >= fChannelCount) then
    begin
      AErrorText := Format('Канал MC-201 с индексом %d не найден', [lChannel]);
      Exit(False);
    end;
    lCount := fReadBlock.SampleCount;
    if lCount <= 0 then
    begin
      AErrorText := 'Нет текущего блока данных MC-201 для балансировки';
      Exit(False);
    end;
    lMean := 0;
    for J := 0 to lCount - 1 do
      lMean := lMean + fReadBlock.Values[lChannel][J];
    lMean := lMean / lCount;
    fSoftBalance[lChannel] := fSoftBalance[lChannel] + lMean;
    AValues[I] := lMean;
  end;
  Result := True;
end;

initialization
  RecorderRegisterHardwareSourceLinkProbe(@RecorderMc032HardwareLinkProbe);

end.
