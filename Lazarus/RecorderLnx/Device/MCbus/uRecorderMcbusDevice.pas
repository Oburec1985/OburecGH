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
    fSampleIndex: Int64;
    fLastError: string;
    procedure AllocateBuffers;
    procedure ResetPending;
    function ChannelIndex(ASlot, AFlag: Word): Integer;
    function AcceptPacket(const AWords: TMc201WordArray): Boolean;
    function PendingComplete: Boolean;
    function TargetSampleCount: Integer;
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
begin
  inherited Create(ADeviceId, AName);
  fHost := CMc201DefaultHost;
  fPort := CMc201DefaultPort;
  fPollFrequencyHz := CMc201DefaultSampleRateHz;
  fUpdateTimeMs := CMc201DefaultUpdateMs;
  fChannelCount := 0;
  FillChar(fConfig, SizeOf(fConfig), 0);
  fConfig.SampleRateHz := CMc201DefaultSampleRateHz;
  fConfig.MaxSlots := CMc201DefaultMaxSlots;
  fConfig.ReadTimeoutMs := CMc201DefaultTimeoutMs;
  fController := TMc032Device.Create;
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
  lCapacity := Max(1, TargetSampleCount * 2);
  for I := 0 to fChannelCount - 1 do
  begin
    SetLength(fPending[I], lCapacity);
    fPendingCount[I] := 0;
  end;
  SetLength(fReadBlock.Values, fChannelCount);
  for I := 0 to fChannelCount - 1 do
    SetLength(fReadBlock.Values[I], TargetSampleCount);
end;

procedure TRecorderMcbusDevice.ResetPending;
var
  I: Integer;
begin
  { Start/Stop только сбрасывают счётчики, не меняя ёмкость массивов. }
  for I := 0 to High(fPendingCount) do
    fPendingCount[I] := 0;
end;

function TRecorderMcbusDevice.TargetSampleCount: Integer;
begin
  Result := Max(1, Round(fPollFrequencyHz * fUpdateTimeMs / 1000.0));
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
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsConnected then
    ProgramDevice;
  if fState = rdsStarted then
    Exit;
  if not fController.StartRawScan(fLastError) then
    raise ERecorderDeviceError.Create('MC-032 start: ' + fLastError);
  fSampleIndex := 0;
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
    if fPendingCount[I] < TargetSampleCount then
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

  lCount := TargetSampleCount;
  fReadBlock.ChannelCount := fChannelCount;
  fReadBlock.SampleCount := lCount;
  fReadBlock.SampleRateHz := fPollFrequencyHz;
  fReadBlock.FirstTimeSec := fSampleIndex / fPollFrequencyHz;
  for I := 0 to fChannelCount - 1 do
  begin
    for J := 0 to lCount - 1 do
      fReadBlock.Values[I][J] := fPending[I][J];
  end;
  Inc(fSampleIndex, lCount);
  for I := 0 to fChannelCount - 1 do
  begin
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
  if not Result then
    fLastError := AErrorText;
end;

initialization
  RecorderRegisterHardwareSourceLinkProbe(@RecorderMc032HardwareLinkProbe);

end.
