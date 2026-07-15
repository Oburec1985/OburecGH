unit uMc032Device;

{
  Независимый класс крейт-контроллера MC-031/MC-032 для тестов протокола.

  Класс намеренно не использует рабочие устройства RecorderLnx. Он оборачивает
  старый Ethernet81 MDP-клиент и дает действия уровня контроллера: поиск, тест,
  поиск модулей, connect, disconnect, reset, config и play с callback данных.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uMc201LegacyMdpClient, uMc201ProtocolTypes;

type
  EMc032Device = class(Exception);

  TMc032Device = class;
  TMc032ProgressCallback = procedure(Sender: TObject; const AText: string) of object;

  TMc032QueuedPacket = class
  private
    fCallback: TMc032DataCallback;
    fPacket: TMc032DataPacket;
    fSender: TObject;
  public
    constructor Create(ASender: TObject; ACallback: TMc032DataCallback;
      const APacket: TMc032DataPacket);
    procedure Deliver;
  end;

  TMc032ReadThread = class(TThread)
  private
    fOwner: TMc032Device;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TMc032Device);
  end;

  TMc032Device = class
  private
    fBios: TMc201ControllerBios;
    fClient: TMc201LegacyMdpClient;
    fConfig: TMc032Config;
    fHost: string;
    fLastModules: TMc201SlotInfoArray;
    fOnData: TMc032DataCallback;
    fPacketIndex: Int64;
    fPort: Word;
    fOnProgress: TMc032ProgressCallback;
    fReadThread: TMc032ReadThread;
    fState: TMc032DeviceState;
    fStreamBuffer: TMc201WordArray;
    fTimeoutMs: Cardinal;
    fProgramInfo: TMc201ModuleProgramInfoArray;
    fReceivedPacketCount: Int64;
    procedure EnsureConnected;
    function FreqToIndex(AFreqHz: Double): Word;
    function FreqIndexToFreq(AIndex: Word): Double;
    function FreqToFreqCode(AFreqHz: Double): Word;
    function FreqToGridCode(AFreqHz: Double): Word;
    procedure HandleThreadPacket(APort: Word; const AWords: TMc201WordArray);
    function TryExtractStreamMessage(out AWords: TMc201WordArray): Boolean;
    procedure QueueStreamMessage(APort: Word; const AWords: TMc201WordArray);
    function ProgramMc201Scan(const AConfig: TMc032Config;
      out AErrorMessage: string): Boolean;
    procedure Progress(const AText: string);
    function ReadSlotInfo(ASlot: Word; out AInfo: TMc201SlotInfo;
      out AErrorMessage: string): Boolean;
    procedure StopReadThread;
  public
    constructor Create;
    destructor Destroy; override;
    function Search(out AFoundHost: string; out AErrorMessage: string): Boolean;
    function TestConnection(out AErrorMessage: string): Boolean;
    function SearchModules(AMaxSlots: Word; out AModules: TMc201SlotInfoArray;
      out AErrorMessage: string): Boolean;
    procedure Connect;
    function TryConnect(out AErrorMessage: string): Boolean;
    procedure Disconnect;
    function Reset(out AErrorMessage: string): Boolean;
    function Config(const AConfig: TMc032Config; out AErrorMessage: string): Boolean;
    procedure ForceDisconnect(AClearProgram: Boolean);
    function Play(AOnData: TMc032DataCallback; out AErrorMessage: string): Boolean;
    function ReadRawPacket(out APort: Word; out AWords: TMc201WordArray): Boolean;
    function ReadRawMessage(out APort: Word; out AWords: TMc201WordArray): Boolean;
    function StartRawScan(out AErrorMessage: string): Boolean;
    function Stop(out AErrorMessage: string): Boolean;
    property Bios: TMc201ControllerBios read fBios;
    property ConfigValue: TMc032Config read fConfig;
    property Host: string read fHost write fHost;
    property LastModules: TMc201SlotInfoArray read fLastModules;
    property OnProgress: TMc032ProgressCallback read fOnProgress write fOnProgress;
    property ProgramInfo: TMc201ModuleProgramInfoArray read fProgramInfo;
    property Port: Word read fPort write fPort;
    property State: TMc032DeviceState read fState;
    property TimeoutMs: Cardinal read fTimeoutMs write fTimeoutMs;
  end;

function Mc032StateToString(AState: TMc032DeviceState): string;

implementation

uses
  Math;

constructor TMc032QueuedPacket.Create(ASender: TObject;
  ACallback: TMc032DataCallback; const APacket: TMc032DataPacket);
begin
  inherited Create;
  fSender := ASender;
  fCallback := ACallback;
  fPacket.StreamPort := APacket.StreamPort;
  fPacket.PacketIndex := APacket.PacketIndex;
  fPacket.Words := Copy(APacket.Words, 0, Length(APacket.Words));
end;

procedure TMc032QueuedPacket.Deliver;
begin
  try
    if Assigned(fCallback) then
      fCallback(fSender, fPacket);
  finally
    Free;
  end;
end;

function Mc032StateToString(AState: TMc032DeviceState): string;
begin
  case AState of
    mcsDisconnected: Result := 'Disconnected';
    mcsConnected: Result := 'Connected';
    mcsPlay: Result := 'Play';
  else
    Result := 'Unknown';
  end;
end;

procedure TMc032Device.Progress(const AText: string);
begin
  if Assigned(fOnProgress) then
    fOnProgress(Self, AText);
end;

constructor TMc032ReadThread.Create(AOwner: TMc032Device);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  Start;
end;

procedure TMc032ReadThread.Execute;
var
  lPort: Word;
  lWords: TMc201WordArray;
begin
  while not Terminated do
  begin
    try
      if (fOwner = nil) or (fOwner.fClient = nil) then
        Exit;
      if fOwner.fClient.ReadRawPacket(lPort, lWords) then
      begin
        if Length(lWords) >= CMc201BiosMessageHeaderWords then
          fOwner.Progress(Format(
            'RX packet port=%d words=%d head=[%u %u %u %u 0x%s %u %u %u %u 0x%s]',
            [lPort, Length(lWords), lWords[0], lWords[1], lWords[2],
             lWords[3], IntToHex(lWords[4], 4), lWords[5], lWords[6],
             lWords[7], lWords[8], IntToHex(lWords[9], 4)]))
        else
          fOwner.Progress(Format('RX packet port=%d words=%d',
            [lPort, Length(lWords)]));
        fOwner.HandleThreadPacket(lPort, lWords);
      end
      else
        fOwner.Progress('RX read timeout/no packet');
    except
      on E: Exception do
      begin
        if fOwner <> nil then
          fOwner.Progress('RX read exception: ' + E.Message);
        Exit;
      end;
    end;
  end;
end;

constructor TMc032Device.Create;
begin
  inherited Create;
  fHost := CMc201DefaultHost;
  fPort := CMc201DefaultPort;
  fTimeoutMs := CMc201DefaultTimeoutMs;
  fState := mcsDisconnected;
  fConfig.SampleRateHz := CMc201DefaultSampleRateHz;
  fConfig.MaxSlots := CMc201DefaultMaxSlots;
  fConfig.ReadTimeoutMs := CMc201DefaultTimeoutMs;
end;

destructor TMc032Device.Destroy;
begin
  ForceDisconnect(False);
  inherited Destroy;
end;

function TMc032Device.FreqIndexToFreq(AIndex: Word): Double;
begin
  Result := 16384000.0 / 256.0 / Power(2.0, 7.0) *
    Power(2.0, AIndex div 2);
  if (AIndex mod 2) = 0 then
    Result := Result / 1.5;
end;

function TMc032Device.FreqToFreqCode(AFreqHz: Double): Word;
var
  I: Integer;
  lBest: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  lBest := 0;
  lBestDelta := Abs(FreqIndexToFreq(0) - AFreqHz);
  for I := 1 to 15 do
  begin
    lDelta := Abs(FreqIndexToFreq(I) - AFreqHz);
    if lDelta < lBestDelta then
    begin
      lBest := I;
      lBestDelta := lDelta;
    end;
  end;
  Result := 7 - (lBest div 2);
end;

function TMc032Device.FreqToGridCode(AFreqHz: Double): Word;
var
  I: Integer;
  lBest: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  lBest := 0;
  lBestDelta := Abs(FreqIndexToFreq(0) - AFreqHz);
  for I := 1 to 15 do
  begin
    lDelta := Abs(FreqIndexToFreq(I) - AFreqHz);
    if lDelta < lBestDelta then
    begin
      lBest := I;
      lBestDelta := lDelta;
    end;
  end;
  if (lBest mod 2) <> 0 then
    Result := 0
  else
    Result := 1;
end;

function TMc032Device.FreqToIndex(AFreqHz: Double): Word;
begin
  Result := 2 * (7 - FreqToFreqCode(AFreqHz)) + (1 - FreqToGridCode(AFreqHz));
end;

{ Программирует слои скана в порядке оригинального Recorder: сброс/настройка
  скана контроллера, BIOS и IDMA-дескрипторы модулей, цепочки каналов MC-201 и
  final flags, дескрипторы скана контроллера, стартовый триггер ADC. Команда
  STARTSCANMAIN остается для Play. }
function TMc032Device.ProgramMc201Scan(const AConfig: TMc032Config;
  out AErrorMessage: string): Boolean;
var
  C: Integer;
  I: Integer;
  J: Integer;
  lAddr: Word;
  lArgs: TMc201WordArray;
  lChanAddr: Word;
  lChanPage: Word;
  lFifoPerChan: Word;
  lFreqCode: Word;
  lGridCode: Word;
  lInfo: TMc201SlotInfo;
  lInternalDivider: Word;
  lModuleCount: Integer;
  lPage: Word;
  lReply: TMc201WordArray;
  lScanAddr: Word;
  lScanPage: Word;
  lWords: TMc201WordArray;

  function ModuleTimeoutCycle(ATimeoutSec: Double): Word;
  var
    lCycle: Integer;
  begin
    lCycle := Trunc(ATimeoutSec * 2.0 * 16384000.0);
    if lCycle = 0 then
      lCycle := 1;
    if lCycle > $3FFF then
      lCycle := $3FFF;
    Result := Word(lCycle);
  end;

  function CallCC(ACommand: Word; const AArgs: TMc201WordArray;
    const AName: string): Boolean;
  begin
    Progress(AName);
    Result := fClient.CallCommand(ACommand, AArgs, 0, lReply, AErrorMessage);
    if not Result then
      AErrorMessage := AName + ' failed: ' + AErrorMessage;
  end;

  function CallMod(ASlot, ACommand: Word; const AArgs: TMc201WordArray;
    ARetCount: Integer; out ARet: TMc201WordArray; const AName: string): Boolean;
  begin
    Progress(Format('slot %d %s', [ASlot, AName]));
    Result := fClient.CallCommandModuleIdmaActivated(ASlot, ACommand, AArgs,
      ARetCount, ARet, AErrorMessage);
    if not Result then
      AErrorMessage := Format('%s failed slot=%d: %s',
        [AName, ASlot, AErrorMessage]);
  end;

begin
  Result := False;
  AErrorMessage := '';
  SetLength(fProgramInfo, 0);

  if Length(fLastModules) = 0 then
  begin
    Progress('SearchModules');
    if not SearchModules(AConfig.MaxSlots, fLastModules, AErrorMessage) then
      Exit;
  end;

  lModuleCount := 0;
  for I := 0 to High(fLastModules) do
    if fLastModules[I].IsMc201 then
      Inc(lModuleCount);
  if lModuleCount = 0 then
  begin
    AErrorMessage := 'No MC-201 modules are available for scan programming';
    Exit;
  end;

  fClient.ResetLocalMemoryHeap;
  Progress('RESETSCANMAIN');
  if not fClient.CallCommand(CMc201CmdResetScanMain, nil, 0, lReply,
    AErrorMessage) then
  begin
    AErrorMessage := 'RESETSCANMAIN failed: ' + AErrorMessage;
    Exit;
  end;

  SetLength(lArgs, 2);
  lArgs[0] := CMc201Cc81TimerScale - 1;
  lArgs[1] := CMc201Cc81TimerPeriod - 1;
  if not CallCC(CMc201CmdConfigScanMain, lArgs, 'CONFIGSCANMAIN') then
    Exit;

  lFifoPerChan := CMc201AdspFifoSamplesPerChannel;
  lGridCode := FreqToGridCode(AConfig.SampleRateHz);
  lFreqCode := FreqToFreqCode(AConfig.SampleRateHz);
  lInternalDivider := Trunc(lFifoPerChan * 5.0 / 100.0 /
    (AConfig.SampleRateHz *
     (CMc201Cc81TimerScale * CMc201Cc81TimerPeriod / 32000000.0)));
  if lInternalDivider < 1 then
    lInternalDivider := 1;

  SetLength(fProgramInfo, lModuleCount);
  C := 0;
  for I := 0 to High(fLastModules) do
  begin
    lInfo := fLastModules[I];
    if not lInfo.IsMc201 then
      Continue;

    fProgramInfo[C].Slot := lInfo.Slot;
    fProgramInfo[C].MaskChan := $000F;
    fProgramInfo[C].FifoSize := lFifoPerChan;
    fProgramInfo[C].FreqIndex := FreqToIndex(AConfig.SampleRateHz);
    fProgramInfo[C].GridCode := lGridCode;
    fProgramInfo[C].DividerCode := lFreqCode or (lFreqCode shl 4);

    Progress(Format('slot %d LOAD_MC201_BIOS', [lInfo.Slot]));
    if not fClient.LoadMc201BiosIdma(lInfo.Slot, CMc201DefaultBiosPath,
      AErrorMessage) then
    begin
      AErrorMessage := Format('LOAD_MC201_BIOS failed slot=%d: %s',
        [lInfo.Slot, AErrorMessage]);
      Exit;
    end;

    if not fClient.GetInternalMemHeap(CMc201DescModuleWords, lPage, lAddr,
      AErrorMessage) then
      Exit;
    SetLength(lArgs, 6);
    lArgs[0] := lInfo.Slot;
    lArgs[1] := fClient.GetAddrModuleReg(lInfo.Slot, CMc201ModuleDataReg);
    lArgs[2] := fClient.GetAddrModuleReg(lInfo.Slot, CMc201ModuleIdmaReg);
    lArgs[3] := fClient.GetAddrModuleReg(lInfo.Slot, CMc201ModuleIrqReg);
    lArgs[4] := lAddr;
    lArgs[5] := lPage;
    if not CallCC(CMc201CmdConfigModuleIdma, lArgs, 'CONFIG_MODULE_IDMA') then
      Exit;

    if not CallMod(lInfo.Slot, CMc201ModuleCmdStopScan, nil, 0, lReply,
      'module STOP_SCAN') then
      Exit;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdResetScan, nil, 0, lReply,
      'module RESET_SCAN') then
      Exit;

    for J := 0 to CMc201MaxModuleChannels - 1 do
    begin
      SetLength(lArgs, 2);
      lArgs[0] := J;
      lArgs[1] := lFifoPerChan;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdConfigRaw, lArgs, 0, lReply,
        'CONFIG_RAW_CC') then
        Exit;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdConfigDbl, lArgs, 0, lReply,
        'CONFIG_DBL_CC') then
        Exit;
      lArgs[1] := J;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdConfigMix, lArgs, 0, lReply,
        'CONFIG_MIX_CC') then
        Exit;
    end;

    SetLength(lWords, 33);
    lWords[0] := 32;
    for J := 0 to 31 do
      lWords[J + 1] := 0;
    lWords[6] := 1;
    lWords[14] := 1;
    lWords[22] := 1;
    lWords[30] := 1;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSendControlRegister, lWords, 0,
      lReply, 'SEND_2_CONT_REG_CC') then
      Exit;

    SetLength(lArgs, 1);
    lArgs[0] := lGridCode;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSetGrid, lArgs, 0, lReply,
      'SET_GRID_CC') then
      Exit;
    lArgs[0] := lFreqCode or (lFreqCode shl 4);
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSetFreq, lArgs, 0, lReply,
      'SET_FREQ_CC') then
      Exit;
    lArgs[0] := $000F;
    if not CallMod(lInfo.Slot, CMc201ModuleCmdSetChanList, lArgs, 0, lReply,
      'SET_CHAN_LIST_CC') then
      Exit;

    for J := 0 to CMc201MaxModuleChannels - 1 do
    begin
      SetLength(lArgs, 1);
      lArgs[0] := J;
      if not CallMod(lInfo.Slot, CMc201ModuleCmdGetFinalFlag, lArgs, 1,
        lReply, 'GET_FINAL_FLAG_CC') then
        Exit;
      if Length(lReply) > 0 then
        fProgramInfo[C].FinalFlags[J] := lReply[0] or CMc201IsDm;
    end;
    Inc(C);
  end;

  if not fClient.GetInternalMemHeap(CMc201BiosScanContextWords, lScanPage,
    lScanAddr, AErrorMessage) then
    Exit;
  SetLength(lArgs, 5);
  lArgs[0] := CMc201ScanTypeMc201;
  lArgs[1] := CMc201ScanIdDefault;
  lArgs[2] := lInternalDivider;
  lArgs[3] := lScanAddr;
  lArgs[4] := lScanPage;
  if not CallCC(CMc201CmdAppendScanMain, lArgs, 'APPENDSCANMAIN') then
    Exit;

  if not fClient.GetInternalMemHeap(lModuleCount * CMc201MaxModuleChannels *
    CMc201DescChanWords, lChanPage, lChanAddr, AErrorMessage) then
    Exit;
  C := 0;
  for I := 0 to High(fProgramInfo) do
    for J := 0 to CMc201MaxModuleChannels - 1 do
    begin
      SetLength(lArgs, 6);
      lArgs[0] := CMc201ScanIdDefault;
      lArgs[1] := fProgramInfo[I].Slot;
      lArgs[2] := fProgramInfo[I].FinalFlags[J] and $7FFF;
      lArgs[3] := lFifoPerChan;
      lArgs[4] := lChanAddr + C * CMc201DescChanWords;
      lArgs[5] := lChanPage;
      if not CallCC(CMc201CmdAddChannelModule, lArgs, 'ADDCHANNELMODULE') then
        Exit;
      Inc(C);
    end;

  SetLength(lArgs, 4);
  lArgs[0] := CMc201ScanIdDefault;
  lArgs[1] := lModuleCount * CMc201MaxModuleChannels;
  lArgs[2] := lChanAddr;
  lArgs[3] := lChanPage;
  if not CallCC(CMc201CmdScanSetChans, lArgs, 'SCAN_SET_CHANS') then
    Exit;

  for I := 0 to High(fProgramInfo) do
  begin
    SetLength(lArgs, 1);
    lArgs[0] := fProgramInfo[I].Slot;
    if not CallCC(CMc201CmdAddListStartAdcModuleIdma, lArgs,
      'ADD_LISTSTARTADCMODULEIDMA') then
      Exit;
  end;

  for I := High(fProgramInfo) downto 0 do
  begin
    SetLength(lArgs, 1);
    lArgs[0] := ModuleTimeoutCycle((High(fProgramInfo) - I) *
      ((23 + 11 + 2 + 1) / 32000000.0));
    if not CallMod(fProgramInfo[I].Slot, CMc201ModuleCmdSetTimeoutStartAdc,
      lArgs, 0, lReply, 'SET_TIMEOUTSTARTADC_201') then
      Exit;
  end;

  SetLength(lArgs, 3);
  lArgs[0] := 0;
  lArgs[1] := 0;
  lArgs[2] := 1;
  if not CallCC(CMc201CmdConfigSyncStart, lArgs, 'CONFIG_SYNC_START') then
    Exit;

  for I := 0 to CMc201CrateMaxStartSlots - Length(fProgramInfo) - 1 do
  begin
    SetLength(lArgs, 2);
    lArgs[0] := 0;
    lArgs[1] := I;
    if not CallCC(CMc201CmdAddListStartModuleIdma, lArgs,
      'ADD_LISTSTARTMODULEIDMA empty') then
      Exit;
  end;

  for I := 0 to High(fProgramInfo) do
  begin
    SetLength(lArgs, 2);
    lArgs[0] := 1;
    lArgs[1] := fProgramInfo[I].Slot;
    if not CallCC(CMc201CmdAddListStartModuleIdma, lArgs,
      'ADD_LISTSTARTMODULEIDMA') then
      Exit;
  end;

  SetLength(lArgs, 1);
  lArgs[0] := Trunc((((25 + 9 + 2 + 11) / (2.0 * 16384000.0)) -
    (5 / 32000000.0) - ((2 + 2) / 32000000.0)) * 32000000.0 + 1);
  if lArgs[0] < 1 then
    lArgs[0] := 1;
  if not CallCC(CMc201CmdSetTimeoutStartTimer, lArgs,
    'SET_TIMEOUTSTARTTIMER') then
    Exit;

  for I := High(fProgramInfo) downto 0 do
  begin
    SetLength(lArgs, 1);
    lArgs[0] := ModuleTimeoutCycle((High(fProgramInfo) - I) *
      ((28 + 11 + 2 + 2) / 32000000.0));
    if not CallMod(fProgramInfo[I].Slot, CMc201ModuleCmdSetTimeoutStart,
      lArgs, 0, lReply, 'SET_TIMEOUTSTART_201') then
      Exit;
  end;

  if not CallCC(CMc201CmdStartTriggerStartAdc, nil,
    'START_TRIGGERSTARTADC') then
    Exit;
  Sleep(350);

  Result := True;
end;

procedure TMc032Device.EnsureConnected;
begin
  if fState = mcsDisconnected then
    Connect;
  if (fClient = nil) or (fState = mcsDisconnected) then
    raise EMc032Device.Create('MC032 is not connected');
end;

procedure TMc032Device.StopReadThread;
begin
  if fReadThread <> nil then
  begin
    fReadThread.Terminate;
    fReadThread.WaitFor;
    FreeAndNil(fReadThread);
  end;
end;

procedure TMc032Device.Connect;
var
  lError: string;
begin
  if not TryConnect(lError) then
    raise EMc032Device.Create(lError);
end;

{ Путь подключения для GUI. Обычные timeout/refused возвращаются текстом и
  оставляют устройство отключенным; Connect оборачивает этот метод там, где для
  CLI/внутреннего кода удобнее исключение. }
function TMc032Device.TryConnect(out AErrorMessage: string): Boolean;
var
  lError: string;
begin
  Result := False;
  AErrorMessage := '';
  if fState <> mcsDisconnected then
    Exit(True);
  FreeAndNil(fClient);
  SetLength(fStreamBuffer, 0);
  fClient := TMc201LegacyMdpClient.Create(fHost, fPort, fTimeoutMs);
  try
    if not fClient.TryConnect(AErrorMessage) then
    begin
      FreeAndNil(fClient);
      fState := mcsDisconnected;
      Exit;
    end;
    if not fClient.ReadControllerBios(fBios, lError) then
    begin
      AErrorMessage := 'CMD_REPLY failed: ' + lError;
      FreeAndNil(fClient);
      fState := mcsDisconnected;
      Exit;
    end;
    fState := mcsConnected;
    Result := True;
  except
    on E: Exception do
    begin
      AErrorMessage := E.Message;
      FreeAndNil(fClient);
      fState := mcsDisconnected;
    end;
  end;
end;

procedure TMc032Device.Disconnect;
var
  lError: string;
begin
  Stop(lError);
  ForceDisconnect(False);
end;

procedure TMc032Device.ForceDisconnect(AClearProgram: Boolean);
begin
  fOnData := nil;
  StopReadThread;
  SetLength(fStreamBuffer, 0);
  FreeAndNil(fClient);
  fState := mcsDisconnected;
  if AClearProgram then
  begin
    SetLength(fProgramInfo, 0);
    SetLength(fLastModules, 0);
  end;
end;

function TMc032Device.Search(out AFoundHost: string;
  out AErrorMessage: string): Boolean;
begin
  AFoundHost := '';
  Result := TestConnection(AErrorMessage);
  if Result then
    AFoundHost := fHost;
end;

function TMc032Device.TestConnection(out AErrorMessage: string): Boolean;
var
  lOwnClient: Boolean;
  lReply: TMc201WordArray;
  lTestData: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  lOwnClient := fClient = nil;
  try
    try
      if lOwnClient then
      begin
        fClient := TMc201LegacyMdpClient.Create(fHost, fPort, fTimeoutMs);
        if not fClient.TryConnect(AErrorMessage) then
          Exit;
      end;
      SetLength(lTestData, 32);
      Result := fClient.CallCommand(CMc201CmdTestLoad, lTestData, 2, lReply,
        AErrorMessage) and (Length(lReply) > 0) and (lReply[0] = 1);
      if (not Result) and (AErrorMessage = '') then
        AErrorMessage := 'TEST_LOAD returned unexpected reply';
    except
      on E: Exception do
      begin
        AErrorMessage := E.Message;
        Result := False;
      end;
    end;
  finally
    if lOwnClient then
      FreeAndNil(fClient);
  end;
end;

function TMc032Device.ReadSlotInfo(ASlot: Word; out AInfo: TMc201SlotInfo;
  out AErrorMessage: string): Boolean;
var
  lHi: Word;
  lLo: Word;
begin
  FillChar(AInfo, SizeOf(AInfo), 0);
  AInfo.Slot := ASlot;
  Result := fClient.ReadFlashWord(ASlot, CMc201FlashTypeOffset,
    AInfo.TypeId, AErrorMessage);
  if not Result then
    Exit;
  if (AInfo.TypeId = 0) or (AInfo.TypeId = $FFFF) then
    Exit(True);
  Result := fClient.ReadFlashWord(ASlot, CMc201FlashVersionOffset,
    AInfo.VersionCode, AErrorMessage);
  if not Result then
    Exit;
  lLo := 0;
  lHi := 0;
  if not fClient.ReadFlashWord(ASlot, CMc201FlashSerialLoOffset, lLo,
    AErrorMessage) then
    Exit(False);
  if not fClient.ReadFlashWord(ASlot, CMc201FlashSerialHiOffset, lHi,
    AErrorMessage) then
    Exit(False);
  AInfo.SerialLo := lLo;
  AInfo.SerialHi := lHi;
  AInfo.Serial := Word((lHi shl 8) or lLo);
  AInfo.IsMc201 := (AInfo.TypeId = CMc201FlashTypeId) and
    Mc201IsKnownVersionCode(AInfo.VersionCode);
  AInfo.IsMc201A := AInfo.IsMc201 and (AInfo.VersionCode = CMc201AVersionCode);
  Result := True;
end;

function TMc032Device.SearchModules(AMaxSlots: Word;
  out AModules: TMc201SlotInfoArray; out AErrorMessage: string): Boolean;
var
  I: Word;
  lInfo: TMc201SlotInfo;
  lUsedCount: Integer;
begin
  Result := False;
  SetLength(AModules, 0);
  AErrorMessage := '';
  try
    EnsureConnected;
    lUsedCount := 0;
    for I := 0 to AMaxSlots - 1 do
    begin
      if not ReadSlotInfo(I, lInfo, AErrorMessage) then
        Exit;
      if (lInfo.TypeId = 0) or (lInfo.TypeId = $FFFF) then
        Continue;
      SetLength(AModules, lUsedCount + 1);
      AModules[lUsedCount] := lInfo;
      Inc(lUsedCount);
    end;
    fLastModules := Copy(AModules, 0, Length(AModules));
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.Reset(out AErrorMessage: string): Boolean;
var
  lReply: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    Result := fClient.CallCommand(CMc201CmdReset, nil, 0, lReply, AErrorMessage);
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

{ Config сделан повторяемым для GUI. Если после прошлого неудачного запуска
  модуль отвергает программирование скана, устройство делает один
  reset/reconnect и повторяет последовательность, близкую к оригинальному
  Recorder. }
function TMc032Device.Config(const AConfig: TMc032Config;
  out AErrorMessage: string): Boolean;
var
  lReply: TMc201WordArray;
  lRetryError: string;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    fConfig := AConfig;
    fClient.TimeoutMs := AConfig.ReadTimeoutMs;
    Result := ProgramMc201Scan(AConfig, AErrorMessage);
    if (not Result) and (fState = mcsConnected) then
    begin
      lRetryError := AErrorMessage;
      if Reset(AErrorMessage) then
      begin
        Disconnect;
        Sleep(1500);
        Connect;
        SetLength(fLastModules, 0);
        Result := ProgramMc201Scan(AConfig, AErrorMessage);
      end
      else
        AErrorMessage := lRetryError + '; reset failed: ' + AErrorMessage;
    end;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.Play(AOnData: TMc032DataCallback;
  out AErrorMessage: string): Boolean;
var
  lDrained: Integer;
  lReply: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    if fState = mcsPlay then
      Exit(True);
    fOnData := AOnData;
    fPacketIndex := 0;
    fReceivedPacketCount := 0;
    SetLength(fStreamBuffer, 0);
    if fClient.DrainPackets(20, lDrained, AErrorMessage) and
      (lDrained > 0) then
      Progress(Format('RX drained before STARTSCANMAIN: %d packets',
        [lDrained]));
    if not fClient.CallCommand(CMc201CmdStartScanMain, nil, 0, lReply,
      AErrorMessage) then
      Exit;
    fState := mcsPlay;
    fReadThread := TMc032ReadThread.Create(Self);
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.StartRawScan(out AErrorMessage: string): Boolean;
var
  lDrained: Integer;
  lReply: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  try
    EnsureConnected;
    if fState = mcsPlay then
      Exit(True);
    fOnData := nil;
    fPacketIndex := 0;
    if fClient.DrainPackets(20, lDrained, AErrorMessage) and
      (lDrained > 0) then
      Progress(Format('RX drained before STARTSCANMAIN: %d packets',
        [lDrained]));
    if not fClient.CallCommand(CMc201CmdStartScanMain, nil, 0, lReply,
      AErrorMessage) then
      Exit;
    fState := mcsPlay;
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc032Device.ReadRawPacket(out APort: Word;
  out AWords: TMc201WordArray): Boolean;
begin
  EnsureConnected;
  Result := fClient.ReadRawPacket(APort, AWords);
end;

function TMc032Device.TryExtractStreamMessage(
  out AWords: TMc201WordArray): Boolean;
var
  I: Integer;
  lSizeWords: Word;
begin
  Result := False;
  SetLength(AWords, 0);
  while Length(fStreamBuffer) >= CMc201BiosMessageHeaderWords do
  begin
    lSizeWords := fStreamBuffer[1];
    if (fStreamBuffer[0] <> 0) or
      (lSizeWords < CMc201BiosMessageHeaderWords) or
      (lSizeWords > CMc201BiosMessageMaxWords) then
    begin
      for I := 1 to High(fStreamBuffer) do
        fStreamBuffer[I - 1] := fStreamBuffer[I];
      SetLength(fStreamBuffer, Length(fStreamBuffer) - 1);
      Continue;
    end;
    if Length(fStreamBuffer) < lSizeWords then
      Exit;
    SetLength(AWords, lSizeWords);
    Move(fStreamBuffer[0], AWords[0], lSizeWords * SizeOf(Word));
    for I := lSizeWords to High(fStreamBuffer) do
      fStreamBuffer[I - lSizeWords] := fStreamBuffer[I];
    SetLength(fStreamBuffer, Length(fStreamBuffer) - lSizeWords);
    Exit(True);
  end;
end;

function TMc032Device.ReadRawMessage(out APort: Word;
  out AWords: TMc201WordArray): Boolean;
var
  I, lOldLength: Integer;
  lPacket: TMc201WordArray;
begin
  EnsureConnected;
  if TryExtractStreamMessage(AWords) then
    Exit(True);
  repeat
    if not fClient.ReadRawPacket(APort, lPacket) then
      Exit(False);
    if APort = CMc201MdpStreamCommand then
      Continue;
    lOldLength := Length(fStreamBuffer);
    SetLength(fStreamBuffer, lOldLength + Length(lPacket));
    for I := 0 to High(lPacket) do
      fStreamBuffer[lOldLength + I] := lPacket[I];
  until TryExtractStreamMessage(AWords);
  Result := True;
end;

function TMc032Device.Stop(out AErrorMessage: string): Boolean;
var
  lReply: TMc201WordArray;
begin
  Result := True;
  AErrorMessage := '';
  if (fClient = nil) or (fState <> mcsPlay) then
    Exit;
  StopReadThread;
  Result := fClient.CallCommand(CMc201CmdStopScanMain, nil, 0, lReply,
    AErrorMessage);
  if Result then
    fState := mcsConnected
  else
    ForceDisconnect(False);
end;

procedure TMc032Device.HandleThreadPacket(APort: Word;
  const AWords: TMc201WordArray);
var
  I: Integer;
  lMessage: TMc201WordArray;
  lOldLength: Integer;
  lSizeWords: Word;
begin
  if not Assigned(fOnData) then
    Exit;
  if APort = CMc201MdpStreamCommand then
    Exit;

  lOldLength := Length(fStreamBuffer);
  SetLength(fStreamBuffer, lOldLength + Length(AWords));
  for I := 0 to High(AWords) do
    fStreamBuffer[lOldLength + I] := AWords[I];

  while Length(fStreamBuffer) >= CMc201BiosMessageHeaderWords do
  begin
    lSizeWords := fStreamBuffer[1];
    if (fStreamBuffer[0] <> 0) or
      (lSizeWords < CMc201BiosMessageHeaderWords) or
      (lSizeWords > CMc201BiosMessageMaxWords) then
    begin
      for I := 1 to High(fStreamBuffer) do
        fStreamBuffer[I - 1] := fStreamBuffer[I];
      SetLength(fStreamBuffer, Length(fStreamBuffer) - 1);
      Continue;
    end;
    if Length(fStreamBuffer) < lSizeWords then
      Break;

    SetLength(lMessage, lSizeWords);
    for I := 0 to lSizeWords - 1 do
      lMessage[I] := fStreamBuffer[I];
    QueueStreamMessage(APort, lMessage);

    for I := lSizeWords to High(fStreamBuffer) do
      fStreamBuffer[I - lSizeWords] := fStreamBuffer[I];
    SetLength(fStreamBuffer, Length(fStreamBuffer) - lSizeWords);
  end;
end;

procedure TMc032Device.QueueStreamMessage(APort: Word;
  const AWords: TMc201WordArray);
var
  lPacket: TMc032DataPacket;
  lQueued: TMc032QueuedPacket;
begin
  Inc(fReceivedPacketCount);
  lPacket.StreamPort := APort;
  lPacket.PacketIndex := fReceivedPacketCount;
  lPacket.Words := Copy(AWords, 0, Length(AWords));
  Inc(fPacketIndex);
  lQueued := TMc032QueuedPacket.Create(Self, fOnData, lPacket);
  TThread.Queue(nil, @lQueued.Deliver);
end;

end.
