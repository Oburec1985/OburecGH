unit uRecorderMic140DataSource;

{
  MIC-140 core data source.

  The source uses the same RecorderLnx data-source contract as virtual/MERA
  playback sources. Transport/protocol code is isolated in
  uRecorderMebiusTcpProtocol, so the UI and storage layers do not depend on
  MIC-140 details.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140LegacyProtocol,
  uRecorderTags;

const
  MIC140DefaultHost = '192.168.14.155';
  MIC140DefaultPort = 4000;
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 5;
  MIC140DefaultPollFrequencyHz = 100.0;
  MIC140DefaultDiscoverySubnet = '192.168.14.';

type
  TRecorderMic140Timing = record
    FrequencyHz: Double;
    GroundCommutationUs: Cardinal;
    ChannelCommutationUs: Cardinal;
    AveragePower: Word;
  end;

  TRecorderMic140Device = class(TInterfacedObject, IRecorderDevice)
  private
    fChannelCount: Integer;
    fChannels: TRecorderDeviceChannelArray;
    fClient: TRecorderMebiusTcpClient;
    fDeviceId: string;
    fHost: string;
    fLegacyClient: TRecorderMic140LegacyClient;
    fLegacyFirmware: TRecorderMic140LegacyFirmware;
    fUseLegacyProtocol: Boolean;
    fPollFrequencyHz: Double;
    fPort: Word;
    fSampleIndex: Int64;
    fState: TRecorderDeviceState;
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    procedure BuildChannels;
  public
    constructor Create(const ADeviceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure ProgramDevice;
    procedure Start;
    procedure Stop;
    function ReadBlock(ATimeoutMs: Cardinal; out ABlock: TRecorderDeviceSampleBlock): Boolean;

    property Host: string read fHost;
    property Port: Word read fPort;
    property ChannelCount: Integer read fChannelCount;
  end;

  TRecorderMic140DataSource = class(TRecorderDataSourceBase)
  private
    fChannelTagNames: TStringList;
    fDevice: IRecorderDevice;
    fTagNames: TStringList;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ATagNames: TStrings = nil);
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

function RecorderMic140SourceId(const AHost: string; APort: Word): string;
function TryParseRecorderMic140SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
function RecorderMic140TestConnection(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal = 250): Boolean;
procedure RecorderMic140Discover(AFoundHosts: TStrings;
  const ASubnetPrefix: string = MIC140DefaultDiscoverySubnet;
  APort: Word = MIC140DefaultPort; ATimeoutMs: Cardinal = 180);
function RecorderMic140FrequencyCount: Integer;
function RecorderMic140Frequency(AIndex: Integer): Double;
function RecorderMic140NormalizeFrequency(AFrequencyHz: Double): Double;
function RecorderMic140TimingForFrequency(AFrequencyHz: Double): TRecorderMic140Timing;
procedure RecorderMic140ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);

implementation

uses
  Math, StrUtils, uSharedFileLogger
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, CTypes, Sockets{$ENDIF};

const
  CMic140SourcePrefix = 'MIC-140:';
  CMic140ConnectAttempts = 3;
  CMic140MebiusChannelCount = 16;
  CMic140MebiusTemperatureSettingsCount = 5;
  CMic140MebiusModuleCount = 4;
  CMic140FrequencyCount = 12;
  CMic140Frequencies: array[0..CMic140FrequencyCount - 1] of Double =
    (1.0, 10.0, 25.0, 50.0, 100.0, 150.0, 200.0, 250.0, 400.0,
     10000.0, 20000.0, 35000.0);
  CMic140IoCtlTypeCallCommand = 2;
  CMic140IoCtlCmdSetControllerParams =
    (CMic140IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic140ChannelCommutIn = 0;
  CMic140Range5mV = 2;
  CMic140SensorSchemeTenzo = 0;
  CMic140DefaultCorrectorId = 2;

type
{$packrecords 8}
  TMic140BaseChanSettings = record
    FrequencyHz: Single;
    Connected: Boolean;
  end;

  TMic140BaseDeviceChanSettings = record
    FrequencyHz: Single;
    Connected: Boolean;
    Corrector: LongWord;
    TareName: array[0..127] of AnsiChar;
    DefaultCorrector: Boolean;
    SoftBalance: Single;
    BlockSize: Word;
    MeasRangeIndex: LongWord;
    CommutIndex: LongInt;
    ShuntOn: LongWord;
    EvalType: LongWord;
    TensoSensitivity: Double;
    Resistance: Double;
    SensorScheme: LongWord;
  end;

  TMic140BaseSettings = record
    Channels: array[0..CMic140MebiusChannelCount + CMic140MebiusTemperatureSettingsCount - 1] of TMic140BaseDeviceChanSettings;
    TemperatureChannels: array[0..CMic140MebiusTemperatureSettingsCount - 1] of TMic140BaseChanSettings;
    SerialNumber: LongWord;
    GroundEnabled: Boolean;
    GroundCommutationUs: LongWord;
    ChannelCommutationUs: LongWord;
    BalancePortionLength: LongWord;
    HardBalance: LongWord;
    AveragePointCount: Word;
    PowerMaCode: LongWord;
    Reserved: LongWord;
    MaxFreqMode: LongWord;
    CalibrShuntIndex: LongWord;
    GroupAddition: array[0..CMic140MebiusModuleCount - 1] of LongWord;
    DetermineBreak: Boolean;
    HardwareBalanceOn: Boolean;
    TemperatureCompensation: Boolean;
    SoftVersion: LongWord;
  end;
{$packrecords default}

procedure Mic140LogWarning(const AMessage: string);
begin
  SharedLogger.Enabled := True;
  SharedLogger.Warning(AMessage);
end;

function RecorderMic140SourceId(const AHost: string; APort: Word): string;
begin
  Result := CMic140SourcePrefix + ' ' + Trim(AHost) + ':' + IntToStr(APort);
end;

function TryParseRecorderMic140SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
var
  lHostPort: string;
  lPos: Integer;
  lPort: Integer;
begin
  Result := False;
  AHost := '';
  APort := MIC140DefaultPort;
  if Pos(CMic140SourcePrefix, ASourceId) <> 1 then
    Exit;

  lHostPort := Trim(Copy(ASourceId, Length(CMic140SourcePrefix) + 1, MaxInt));
  if lHostPort = '' then
    lHostPort := MIC140DefaultHost + ':' + IntToStr(MIC140DefaultPort);

  lPos := RPos(':', lHostPort);
  if lPos > 0 then
  begin
    AHost := Trim(Copy(lHostPort, 1, lPos - 1));
    if not TryStrToInt(Trim(Copy(lHostPort, lPos + 1, MaxInt)), lPort) then
      Exit;
    if (lPort <= 0) or (lPort > High(Word)) then
      Exit;
    APort := Word(lPort);
  end
  else
    AHost := lHostPort;

  Result := AHost <> '';
end;

function RecorderMic140FrequencyCount: Integer;
begin
  Result := CMic140FrequencyCount;
end;

function RecorderMic140Frequency(AIndex: Integer): Double;
begin
  if (AIndex < 0) or (AIndex >= CMic140FrequencyCount) then
    raise ERecorderDeviceError.CreateFmt('MIC-140 frequency index is invalid: %d',
      [AIndex]);
  Result := CMic140Frequencies[AIndex];
end;

function RecorderMic140NormalizeFrequency(AFrequencyHz: Double): Double;
var
  I: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  Result := MIC140DefaultPollFrequencyHz;
  lBestDelta := MaxDouble;
  for I := 0 to High(CMic140Frequencies) do
  begin
    lDelta := Abs(CMic140Frequencies[I] - AFrequencyHz);
    if lDelta < lBestDelta then
    begin
      lBestDelta := lDelta;
      Result := CMic140Frequencies[I];
    end;
  end;
end;

function RecorderMic140TimingForFrequency(AFrequencyHz: Double): TRecorderMic140Timing;
begin
  Result.FrequencyHz := RecorderMic140NormalizeFrequency(AFrequencyHz);
  Result.GroundCommutationUs := 100;
  Result.ChannelCommutationUs := 150;
  Result.AveragePower := 7;

  if Result.FrequencyHz >= 10000.0 then
    Result.AveragePower := 0
  else if Result.FrequencyHz >= 400.0 then
    Result.AveragePower := 4
  else if Result.FrequencyHz >= 250.0 then
    Result.AveragePower := 5
  else if Result.FrequencyHz >= 150.0 then
    Result.AveragePower := 6;
end;

procedure RecorderMic140ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
var
  I: Integer;
  lCapacity: Integer;
  lFrequencyHz: Double;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (ASourceId = '') then
    Exit;

  lFrequencyHz := RecorderMic140NormalizeFrequency(AFrequencyHz);
  lCapacity := Ceil(Max(4096, lFrequencyHz));
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) then
    begin
      lTag.PollFrequencyHz := lFrequencyHz;
      lTag.EnsureBufferCapacity(lCapacity);
    end;
  end;
end;

function RecorderMic140TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
{$IFDEF MSWINDOWS}
var
  lAddr: TSockAddrIn;
  lBlockMode: u_long;
  lError: LongInt;
  lErrorLen: LongInt;
  lHost: string;
  lIp: u_long;
  lSocket: TSocket;
  lTimeVal: TTimeVal;
  lWriteSet: TFDSet;
  lWsaData: TWSAData;
begin
  Result := False;
  lHost := Trim(AHost);
  if lHost = '' then
    Exit;

  if WSAStartup($0202, lWsaData) <> 0 then
    Exit;
  try
    lIp := inet_addr(PChar(AnsiString(lHost)));
    if lIp = INADDR_NONE then
      Exit;

    lSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if lSocket = INVALID_SOCKET then
      Exit;
    try
      FillChar(lAddr, SizeOf(lAddr), 0);
      lAddr.sin_family := AF_INET;
      lAddr.sin_port := htons(APort);
      lAddr.sin_addr.S_addr := lIp;

      lBlockMode := 1;
      if ioctlsocket(lSocket, LongInt(FIONBIO), lBlockMode) <> 0 then
        Exit;

      if WinSock2.connect(lSocket, @lAddr, SizeOf(lAddr)) = 0 then
        Exit(True);
      lError := WSAGetLastError;
      if lError <> WSAEWOULDBLOCK then
        Exit;

      FillChar(lTimeVal, SizeOf(lTimeVal), 0);
      lTimeVal.tv_sec := ATimeoutMs div 1000;
      lTimeVal.tv_usec := (ATimeoutMs mod 1000) * 1000;
      FD_ZERO(lWriteSet);
      FD_SET(lSocket, lWriteSet);
      if WinSock2.select(0, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
        Exit;
      if not FD_ISSET(lSocket, lWriteSet) then
        Exit;

      lError := -1;
      lErrorLen := SizeOf(lError);
      if getsockopt(lSocket, SOL_SOCKET, SO_ERROR, lError, lErrorLen) <> 0 then
        Exit;
      Result := lError = 0;
    finally
      closesocket(lSocket);
    end;
  finally
    WSACleanup;
  end;
end;
{$ELSE}
const
  CWouldBlockError = ESysEINPROGRESS;
var
  lAddr: TInetSockAddr;
  lBlockMode: LongInt;
  lError: LongInt;
  lErrorLen: LongInt;
  lHost: string;
  lHostAddr: in_addr;
  lSocket: cint;
  lTimeVal: TTimeVal;
  lWriteSet: TFDSet;
begin
  Result := False;
  lHost := Trim(AHost);
  if lHost = '' then
    Exit;

  if not TryStrToHostAddr(AnsiString(lHost), lHostAddr) then
    Exit;

  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket < 0 then
    Exit;
  try
    FillChar(lAddr, SizeOf(lAddr), 0);
    lAddr.sin_family := AF_INET;
    lAddr.sin_port := ShortHostToNet(APort);
    lAddr.sin_addr.s_addr := HostToNet(lHostAddr.s_addr);

    lBlockMode := 1;
    {$IFDEF UNIX}
    if FpFcntl(lSocket, F_SetFl, FpFcntl(lSocket, F_GetFl, 0) or O_NONBLOCK) <> 0 then
      Exit;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    if ioctlsocket(lSocket, LongInt(FIONBIO), @lBlockMode) <> 0 then
      Exit;
    {$ENDIF}

    if fpConnect(lSocket, @lAddr, SizeOf(lAddr)) = 0 then
      Exit(True);
    lError := SocketError;
    if lError <> CWouldBlockError then
      Exit;

    FillChar(lTimeVal, SizeOf(lTimeVal), 0);
    lTimeVal.tv_sec := ATimeoutMs div 1000;
    lTimeVal.tv_usec := (ATimeoutMs mod 1000) * 1000;
    FillChar(lWriteSet, SizeOf(lWriteSet), 0);
    {$IFDEF UNIX}
    fpFD_ZERO(lWriteSet);
    fpFD_SET(lSocket, lWriteSet);
    if fpSelect(lSocket + 1, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
      Exit;
    if fpFD_ISSET(lSocket, lWriteSet) <> 1 then
      Exit;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    FD_ZERO(lWriteSet);
    FD_SET(lSocket, lWriteSet);
    if select(lSocket + 1, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
      Exit;
    if not FD_ISSET(lSocket, lWriteSet) then
      Exit;
    {$ENDIF}

    lError := -1;
    lErrorLen := SizeOf(lError);
    if fpGetSockOpt(lSocket, SOL_SOCKET, SO_ERROR, @lError, @lErrorLen) <> 0 then
      Exit;
    Result := lError = 0;
  finally
    CloseSocket(lSocket);
  end;
end;
{$ENDIF}

function RecorderMic140TestConnection(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
begin
  Result := RecorderMic140TcpProbe(AHost, APort, ATimeoutMs);
end;

type
  TMic140DiscoveryThread = class(TThread)
  private
    fFound: Boolean;
    fHost: string;
    fPort: Word;
    fTimeoutMs: Cardinal;
  protected
    procedure Execute; override;
  public
    constructor Create(const AHost: string; APort: Word; ATimeoutMs: Cardinal);
    property Found: Boolean read fFound;
    property Host: string read fHost;
  end;

constructor TMic140DiscoveryThread.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  Start;
end;

procedure TMic140DiscoveryThread.Execute;
begin
  fFound := RecorderMic140TestConnection(fHost, fPort, fTimeoutMs);
end;

procedure RecorderMic140Discover(AFoundHosts: TStrings;
  const ASubnetPrefix: string; APort: Word; ATimeoutMs: Cardinal);
var
  I: Integer;
  lThreads: TList;
  lThread: TMic140DiscoveryThread;
begin
  if AFoundHosts = nil then
    Exit;
  AFoundHosts.Clear;
  lThreads := TList.Create;
  try
    lThread := TMic140DiscoveryThread.Create(MIC140DefaultHost, APort, ATimeoutMs);
    lThreads.Add(lThread);
    for I := 1 to 254 do
    begin
      if SameText(ASubnetPrefix + IntToStr(I), MIC140DefaultHost) then
        Continue;
      lThread := TMic140DiscoveryThread.Create(ASubnetPrefix + IntToStr(I),
        APort, ATimeoutMs);
      lThreads.Add(lThread);
    end;

    for I := 0 to lThreads.Count - 1 do
    begin
      lThread := TMic140DiscoveryThread(lThreads[I]);
      lThread.WaitFor;
      if lThread.Found and (AFoundHosts.IndexOf(lThread.Host) < 0) then
        AFoundHosts.Add(lThread.Host);
      lThread.Free;
    end;
  finally
    lThreads.Free;
  end;
end;

{ TRecorderMic140Device }

constructor TRecorderMic140Device.Create(const ADeviceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double);
begin
  inherited Create;
  if ADeviceId = '' then
    raise ERecorderDeviceError.Create('MIC-140 device id cannot be empty');
  if AHost = '' then
    raise ERecorderDeviceError.Create('MIC-140 host cannot be empty');
  if not (AChannelCount in [1..MIC140MaxChannelCount]) then
    raise ERecorderDeviceError.CreateFmt('MIC-140 channel count is invalid: %d',
      [AChannelCount]);
  if APollFrequencyHz <= 0 then
    APollFrequencyHz := MIC140DefaultPollFrequencyHz;
  APollFrequencyHz := RecorderMic140NormalizeFrequency(APollFrequencyHz);

  fDeviceId := ADeviceId;
  fHost := AHost;
  fPort := APort;
  fChannelCount := AChannelCount;
  fPollFrequencyHz := APollFrequencyHz;
  fState := rdsDisconnected;
  BuildChannels;
end;

destructor TRecorderMic140Device.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

function TRecorderMic140Device.GetDeviceId: string;
begin
  Result := fDeviceId;
end;

function TRecorderMic140Device.GetName: string;
begin
  Result := Format('MIC-140 %s:%d', [fHost, fPort]);
end;

function TRecorderMic140Device.GetState: TRecorderDeviceState;
begin
  Result := fState;
end;

function TRecorderMic140Device.GetChannels: TRecorderDeviceChannelArray;
begin
  Result := Copy(fChannels, 0, Length(fChannels));
end;

procedure TRecorderMic140Device.BuildChannels;
var
  I: Integer;
begin
  SetLength(fChannels, fChannelCount);
  for I := 0 to fChannelCount - 1 do
  begin
    fChannels[I].Name := Format('MIC140_%2.2d', [I + 1]);
    fChannels[I].Address := IntToStr(I + 1);
    fChannels[I].UnitName := '';
    fChannels[I].ModuleType := 'MIC-140';
    fChannels[I].PollFrequencyHz := fPollFrequencyHz;
    fChannels[I].Enabled := True;
  end;
end;

procedure TRecorderMic140Device.Connect;
var
  lAttempt: Integer;
  lErrorMessage: string;
begin
  if fState <> rdsDisconnected then
    Exit;

  FreeAndNil(fLegacyClient);
  fUseLegacyProtocol := False;
  fLegacyClient := TRecorderMic140LegacyClient.Create(fHost, fPort, 5000);
  try
    fLegacyClient.Connect;
    if fLegacyClient.ReadFirmware(fLegacyFirmware, lErrorMessage) then
    begin
      fUseLegacyProtocol := True;
      fState := rdsConnected;
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy Ethernet protocol detected: device=%d.%d serial=%d controller=%d serial=%d BIOS=%d.%d',
        [fHost, fPort, fLegacyFirmware.DeviceType, fLegacyFirmware.DeviceRevision,
         fLegacyFirmware.DeviceSerial, fLegacyFirmware.ControllerType,
         fLegacyFirmware.ControllerSerial, fLegacyFirmware.BiosFunction,
         fLegacyFirmware.BiosRevision]));
      Exit;
    end;
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy probe failed: %s',
      [fHost, fPort, lErrorMessage]));
  except
    on E: Exception do
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy connect failed: %s: %s',
        [fHost, fPort, E.ClassName, E.Message]));
  end;
  FreeAndNil(fLegacyClient);

  for lAttempt := 1 to CMic140ConnectAttempts do
  begin
    FreeAndNil(fClient);
    fClient := TRecorderMebiusTcpClient.Create(fHost, fPort, 5000);
    try
      fClient.Connect;
      fState := rdsConnected;
      Exit;
    except
      on E: Exception do
      begin
        Mic140LogWarning(Format('[MIC-140:%s:%d] Connect attempt %d/%d failed: %s: %s',
          [fHost, fPort, lAttempt, CMic140ConnectAttempts, E.ClassName, E.Message]));
        FreeAndNil(fClient);
        fState := rdsDisconnected;
        if lAttempt < CMic140ConnectAttempts then
          Sleep(250);
      end;
    end;
  end;
end;

function Mic140GenerateSessionId: LongWord;
begin
  Result := LongWord(GetTickCount64 and $00000FFF) or
    ((LongWord(Random($1000)) shl 12) and $00FFF000) or $14000000;
end;

function Mic140BuildSettings(AChannelCount: Integer;
  APollFrequencyHz: Double): TRecorderByteArray;
var
  I: Integer;
  lSettings: TMic140BaseSettings;
  lTiming: TRecorderMic140Timing;
begin
  FillChar(lSettings, SizeOf(lSettings), 0);
  lTiming := RecorderMic140TimingForFrequency(APollFrequencyHz);

  for I := 0 to High(lSettings.Channels) do
  begin
    lSettings.Channels[I].FrequencyHz := lTiming.FrequencyHz;
    lSettings.Channels[I].Connected :=
      I < Min(AChannelCount, CMic140MebiusChannelCount);
    lSettings.Channels[I].Corrector := CMic140DefaultCorrectorId;
    lSettings.Channels[I].DefaultCorrector := False;
    lSettings.Channels[I].SoftBalance := 0;
    lSettings.Channels[I].BlockSize := 1;
    lSettings.Channels[I].MeasRangeIndex := CMic140Range5mV;
    lSettings.Channels[I].CommutIndex := CMic140ChannelCommutIn;
    lSettings.Channels[I].ShuntOn := 0;
    lSettings.Channels[I].EvalType := 0;
    lSettings.Channels[I].TensoSensitivity := 2;
    lSettings.Channels[I].Resistance := 200;
    lSettings.Channels[I].SensorScheme := CMic140SensorSchemeTenzo;
  end;

  for I := 0 to High(lSettings.TemperatureChannels) do
  begin
    lSettings.TemperatureChannels[I].FrequencyHz := lTiming.FrequencyHz;
    lSettings.TemperatureChannels[I].Connected := False;
  end;

  lSettings.SerialNumber := 0;
  lSettings.GroundEnabled := True;
  lSettings.GroundCommutationUs := lTiming.GroundCommutationUs;
  lSettings.ChannelCommutationUs := lTiming.ChannelCommutationUs;
  lSettings.BalancePortionLength := 30;
  lSettings.HardBalance := 8192;
  lSettings.AveragePointCount := lTiming.AveragePower;
  lSettings.PowerMaCode := 10813;
  lSettings.Reserved := 0;
  lSettings.MaxFreqMode := 0;
  lSettings.CalibrShuntIndex := 3;
  lSettings.DetermineBreak := False;
  lSettings.HardwareBalanceOn := False;
  lSettings.TemperatureCompensation := False;
  lSettings.SoftVersion := 0;

  SetLength(Result, SizeOf(lSettings));
  Move(lSettings, Result[0], SizeOf(lSettings));
end;

procedure TRecorderMic140Device.ProgramDevice;
var
  lCommandIn: TRecorderByteArray;
  lCommandOut: TRecorderByteArray;
  lErrorMessage: string;
  lSessionId: LongWord;
  lSettings: TRecorderByteArray;
  lStatusFlags: LongWord;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsDisconnected then
    Exit;
  if fUseLegacyProtocol then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy MIC-140 command protocol is connected; scan programming is not implemented yet',
      [fHost, fPort]));
    Exit;
  end;
  if fClient = nil then
    Exit;

  SetLength(lCommandIn, SizeOf(LongWord));
  lStatusFlags := 0;
  Move(lStatusFlags, lCommandIn[0], SizeOf(lStatusFlags));
  if not fClient.TryCallCommand(CMic140IoCtlCmdSetControllerParams, lCommandIn,
    0, lCommandOut, lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] SetControllerParams failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  lSettings := Mic140BuildSettings(fChannelCount, fPollFrequencyHz);
  if not fClient.TryProgramDeviceBin(lSettings, lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] ProgramDeviceBin failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  lSessionId := Mic140GenerateSessionId;
  if not fClient.TrySetSessionId(lSessionId, lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] SetSessionId failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  if not fClient.TryProgramMeasurement(lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] ProgramMeasurement failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  fState := rdsProgrammed;
end;

procedure TRecorderMic140Device.Disconnect;
begin
  if fState = rdsStarted then
    Stop;
  FreeAndNil(fClient);
  FreeAndNil(fLegacyClient);
  fUseLegacyProtocol := False;
  fState := rdsDisconnected;
end;

procedure TRecorderMic140Device.Start;
var
  lAttempt: Integer;
  lErrorMessage: string;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsDisconnected then
    Exit;
  if fState = rdsConnected then
    ProgramDevice;
  if fState <> rdsProgrammed then
    Exit;
  if fClient = nil then
    Exit;

  for lAttempt := 1 to CMic140ConnectAttempts do
  begin
    if fClient.TryStartMeasurement(lErrorMessage) then
    begin
      fSampleIndex := 0;
      fState := rdsStarted;
      Exit;
    end;
    Mic140LogWarning(Format('[MIC-140:%s:%d] StartMeasurement attempt %d/%d failed: %s',
      [fHost, fPort, lAttempt, CMic140ConnectAttempts, lErrorMessage]));
    if lAttempt < CMic140ConnectAttempts then
      Sleep(250);
  end;
  fState := rdsConnected;
end;

procedure TRecorderMic140Device.Stop;
var
  lErrorMessage: string;
begin
  if (fState = rdsStarted) and (fClient <> nil) then
  begin
    if not fClient.TryStopMeasurement(lErrorMessage) then
      Mic140LogWarning(Format('[MIC-140:%s:%d] StopMeasurement failed: %s',
        [fHost, fPort, lErrorMessage]));
  end;
  if fState <> rdsDisconnected then
    fState := rdsConnected;
end;

function TRecorderMic140Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  I: Integer;
  J: Integer;
  lRaw: TRecorderMebiusFloatBlock;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  Result := False;
  if fState <> rdsStarted then
    Exit;
  if fClient = nil then
    Exit;

  fClient.TimeoutMs := ATimeoutMs;
  if not fClient.ReadDataBlock(fChannelCount, lRaw) then
    Exit;

  ABlock.ChannelCount := lRaw.ChannelCount;
  ABlock.SampleCount := lRaw.SampleCount;
  ABlock.SampleRateHz := fPollFrequencyHz;
  ABlock.FirstTimeSec := fSampleIndex / fPollFrequencyHz;
  SetLength(ABlock.Values, ABlock.ChannelCount);
  for I := 0 to ABlock.ChannelCount - 1 do
  begin
    SetLength(ABlock.Values[I], ABlock.SampleCount);
    for J := 0 to ABlock.SampleCount - 1 do
      ABlock.Values[I][J] := lRaw.Values[I][J];
  end;
  Inc(fSampleIndex, ABlock.SampleCount);
  Result := True;
end;

{ TRecorderMic140DataSource }

constructor TRecorderMic140DataSource.Create(const ASourceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ATagNames: TStrings);
begin
  inherited Create(ASourceId, 'MIC-140', AUpdateTimeMs);
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fChannelTagNames.Sorted := False;
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  fTagNames.Sorted := False;
  if ATagNames <> nil then
    fTagNames.Assign(ATagNames);
  fDevice := TRecorderMic140Device.Create(ASourceId, AHost, APort,
    AChannelCount, APollFrequencyHz);
end;

destructor TRecorderMic140DataSource.Destroy;
begin
  Stop;
  fTagNames.Free;
  fChannelTagNames.Free;
  inherited Destroy;
end;

function TRecorderMic140DataSource.FindTagBySourceAddress(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, SourceId) and
      SameText(ARegistry.Tags[I].Address, AAddress) then
      Exit(ARegistry.Tags[I]);
end;

procedure TRecorderMic140DataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lChannel: TRecorderDeviceChannel;
  lChannels: TRecorderDeviceChannelArray;
  lTag: TRecorderTag;
  lTagName: string;
begin
  lChannels := fDevice.GetChannels;
  fChannelTagNames.Clear;
  for I := 0 to High(lChannels) do
  begin
    fChannelTagNames.Add('');
    lChannel := lChannels[I];
    if not lChannel.Enabled then
      Continue;
    if (fTagNames.Count > 0) and (fTagNames.IndexOf(lChannel.Name) < 0) and
      (fTagNames.IndexOf(lChannel.Address) < 0) then
      Continue;

    lTagName := lChannel.Name;
    lTag := FindTagBySourceAddress(ARegistry, lChannel.Address);
    if lTag <> nil then
      lTagName := lTag.Name
    else
      lTag := ARegistry.FindByName(lTagName);
    if lTag = nil then
      lTag := ARegistry.CreateTag(lTagName, Ceil(Max(4096, lChannel.PollFrequencyHz)));
    lTag.Address := lChannel.Address;
    lTag.UnitName := lChannel.UnitName;
    lTag.ModuleType := lChannel.ModuleType;
    lTag.PollFrequencyHz := lChannel.PollFrequencyHz;
    lTag.SourceId := SourceId;
    lTag.Description := Format('MIC-140 channel %s; freq=%s Hz',
      [lChannel.Address, FormatFloat('0.######', lChannel.PollFrequencyHz)]);
    fChannelTagNames[I] := lTag.Name;
  end;
end;

procedure TRecorderMic140DataSource.Start;
begin
  inherited Start;
  fDevice.Connect;
  fDevice.ProgramDevice;
  fDevice.Start;
  if fDevice.State <> rdsStarted then
    Mic140LogWarning(Format('[DataSource:%s] MIC-140 source is not started; preview will continue without device samples',
      [SourceId]));
end;

procedure TRecorderMic140DataSource.Stop;
begin
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
      fDevice.Disconnect;
    except
    end;
  end;
  inherited Stop;
end;

procedure TRecorderMic140DataSource.DoTick;
var
  I: Integer;
  J: Integer;
  lBlock: TRecorderDeviceSampleBlock;
  lChannels: TRecorderDeviceChannelArray;
  lCount: Integer;
  lTag: TRecorderTag;
  lTimes: TRecorderDoubleArray;
  lValues: TRecorderDoubleArray;
begin
  try
    if (fDevice = nil) or (fDevice.State <> rdsStarted) then
      Exit;
    if not fDevice.ReadBlock(UpdateTimeMs, lBlock) then
      Exit;
  except
    on E: Exception do
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 read failed: %s: %s',
        [SourceId, E.ClassName, E.Message]));
      fDevice.Stop;
      Exit;
    end;
  end;
  lChannels := fDevice.GetChannels;
  lCount := Min(lBlock.ChannelCount, Length(lChannels));
  if lCount <= 0 then
    Exit;

  SetLength(lTimes, lBlock.SampleCount);
  for J := 0 to lBlock.SampleCount - 1 do
    lTimes[J] := lBlock.FirstTimeSec + (J / lBlock.SampleRateHz);

  SetLength(lValues, lBlock.SampleCount);
  for I := 0 to lCount - 1 do
  begin
    if I >= fChannelTagNames.Count then
      Continue;
    lTag := Registry.FindByName(fChannelTagNames[I]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;

    for J := 0 to lBlock.SampleCount - 1 do
      lValues[J] := lBlock.Values[I][J];
    Registry.PublishBlock(lTag.Name, lTimes, lValues, lBlock.SampleCount);
  end;
end;

end.
