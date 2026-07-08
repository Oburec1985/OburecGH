unit uMic185Device;

{
  Драйвер MIC183/185 для автономного стенда.
  В Recorder прибор отображается как «MIC183/185»; в Mebius — medaq_mic185v2.
  Каналы: 64 тензо + 5 температурных + 1 СЕВ (UTS).
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants,
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uMic185MebiusTcpProtocol, uMic185MebiusTypes, uMic185Constants;

type
  TRecorderMic185Device = class(TRecorderDevice)
  private
    fClient: TRecorderMebiusTcpClient;
    fDeviceSerial: LongWord;
    fSoftVersion: LongWord;
    fSampleIndex: Int64;
    fSessionId: LongWord;
    fMeasChannelCount: Integer;
    fTempChannelCount: Integer;
    fUtsEnabled: Boolean;
    fMeasFrequencyHz: Double;
    fTempFrequencyHz: Double;
    fRecorderDeviceIndex: Integer;
    fLastTempValues: array of Double;
    fLastUtsValue: Double;
    fHasLastTemp: Boolean;
    fHasLastUts: Boolean;
    procedure QueryDeviceInfo;
    function TotalLogicalChannelCount: Integer;
    function BuildLogicalChannelName(AIndex: Integer): string;
    function BuildLogicalChannelAddress(AIndex: Integer): string;
    function BuildLogicalChannelUnit(AIndex: Integer): string;
    function BuildLogicalChannelFrequency(AIndex: Integer): Double;
  protected
    procedure ReadDeviceParameters; override;
  public
    constructor Create(const ADeviceId, AName: string); override;
    destructor Destroy; override;
    function GetChannels: TRecorderDeviceChannelArray; override;
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
    property SoftVersion: LongWord read fSoftVersion;
    property DeviceSerial: LongWord read fDeviceSerial;
    property MeasChannelCount: Integer read fMeasChannelCount;
    property TempChannelCount: Integer read fTempChannelCount;
    property UtsEnabled: Boolean read fUtsEnabled;
    function LastTempValue(AIndex: Integer): Double;
    function LastUts: Double;
    function HasTempData: Boolean;
    function HasUtsData: Boolean;
    function TestLink(out AErrorText: string): Boolean; override;
    function SniffPackets(APacketCount: Integer; ATimeoutMs: Cardinal): Integer;
    function RxDataPacketCount: Int64;
  end;

function CreateRecorderMic185Device: IRecorderDevice;

implementation

uses
  uRecorderMic185Runtime;

const
  CMic185ConnectAttempts = 3;
  CMic185ConnectTimeoutMs = 5000;

constructor TRecorderMic185Device.Create(const ADeviceId, AName: string);
begin
  inherited Create(ADeviceId, AName);
  fPort := 4000;
  fMeasChannelCount := CMic185ChannelCountMax;
  fTempChannelCount := CMic185TempChannelCount;
  fUtsEnabled := True;
  fChannelCount := CMic185TotalLogicalChannelCount;
  fMeasFrequencyHz := CMic185DefaultMeasFrequencyHz;
  fTempFrequencyHz := CMic185DefaultTempFrequencyHz;
  fPollFrequencyHz := fMeasFrequencyHz;
  fUpdateTimeMs := 100;
  fRecorderDeviceIndex := 3;
end;

destructor TRecorderMic185Device.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

function TRecorderMic185Device.TotalLogicalChannelCount: Integer;
begin
  Result := fMeasChannelCount + fTempChannelCount;
  if fUtsEnabled then
    Inc(Result, CMic185UtsChannelCount);
end;

function TRecorderMic185Device.BuildLogicalChannelName(AIndex: Integer): string;
begin
  if AIndex < fMeasChannelCount then
    Result := Format('MIC183_185-{%d-%d}', [fRecorderDeviceIndex, AIndex + 1])
  else if AIndex < fMeasChannelCount + fTempChannelCount then
    Result := Format('MIC183_185-{%d-t%d}', [fRecorderDeviceIndex,
      AIndex - fMeasChannelCount + 1])
  else
    Result := Format('MIC183_185-{%d-uts}', [fRecorderDeviceIndex]);
end;

function TRecorderMic185Device.BuildLogicalChannelAddress(AIndex: Integer): string;
begin
  Result := BuildLogicalChannelName(AIndex);
end;

function TRecorderMic185Device.BuildLogicalChannelUnit(AIndex: Integer): string;
begin
  if AIndex < fMeasChannelCount then
    Result := 'mV'
  else if AIndex < fMeasChannelCount + fTempChannelCount then
    Result := 'C'
  else
    Result := 's';
end;

function TRecorderMic185Device.BuildLogicalChannelFrequency(AIndex: Integer): Double;
begin
  if AIndex < fMeasChannelCount then
    Result := fMeasFrequencyHz
  else
    Result := fTempFrequencyHz;
end;

procedure TRecorderMic185Device.ReadDeviceParameters;
begin
  inherited ReadDeviceParameters;
  fChannelCount := TotalLogicalChannelCount;
end;

function TRecorderMic185Device.GetChannels: TRecorderDeviceChannelArray;
var
  I: Integer;
begin
  SetLength(Result, TotalLogicalChannelCount);
  for I := 0 to TotalLogicalChannelCount - 1 do
  begin
    Result[I].Name := BuildLogicalChannelName(I);
    Result[I].Address := BuildLogicalChannelAddress(I);
    Result[I].UnitName := BuildLogicalChannelUnit(I);
    Result[I].ModuleType := fName;
    Result[I].PollFrequencyHz := BuildLogicalChannelFrequency(I);
    Result[I].Enabled := True;
  end;
end;

function TRecorderMic185Device.GetDeviceProperty(
  AProperty: TRecorderDeviceProperty; AIndex: Integer): Variant;
begin
  case AProperty of
    rdpDeviceSerial: Result := fDeviceSerial;
    rdpChannelCount: Result := TotalLogicalChannelCount;
    rdpPollFrequencyHz: Result := fMeasFrequencyHz;
  else
    Result := inherited GetDeviceProperty(AProperty, AIndex);
  end;
end;

function TRecorderMic185Device.TrySetDeviceProperty(
  AProperty: TRecorderDeviceProperty; const AValue: Variant;
  AIndex: Integer): Boolean;
begin
  Result := True;
  case AProperty of
    rdpPollFrequencyHz:
      begin
        fMeasFrequencyHz := Double(AValue);
        fPollFrequencyHz := fMeasFrequencyHz;
      end;
    rdpChannelCount:
      begin
        { Ожидаемая конфигурация Recorder: 64 + 5 + 1. }
        if Integer(AValue) <> CMic185TotalLogicalChannelCount then
          Exit(False);
        fMeasChannelCount := CMic185ChannelCountMax;
        fTempChannelCount := CMic185TempChannelCount;
        fUtsEnabled := True;
        fChannelCount := TotalLogicalChannelCount;
      end;
  else
    Result := inherited TrySetDeviceProperty(AProperty, AValue, AIndex);
  end;
end;

procedure TRecorderMic185Device.QueryDeviceInfo;
var
  lOut: TRecorderByteArray;
  lInfo: TMic185HardDeviceInfo;
  lError: string;
begin
  fDeviceSerial := 0;
  fSoftVersion := 0;
  if fClient = nil then
    Exit;
  if fClient.TryCallCommand(CMic185IoCtlCmdGetSoftVersion, nil,
    CMic185HardDeviceInfoSize, lOut, lError) and
    (Length(lOut) >= CMic185HardDeviceInfoSize) then
  begin
    Move(lOut[0], lInfo, SizeOf(lInfo));
    fDeviceSerial := lInfo.SerialNumber;
    fSoftVersion := lInfo.SoftVersion;
    RecorderMic185RuntimeUpdateInfo(fHost, Word(fPort), fDeviceSerial, fSoftVersion);
  end;
end;

procedure TRecorderMic185Device.Connect;
var
  lAttempt: Integer;
begin
  if fState <> rdsDisconnected then
    Exit;
  if Trim(fHost) = '' then
    raise ERecorderDeviceError.Create('MIC183/185 host is not set');

  for lAttempt := 1 to CMic185ConnectAttempts do
  begin
    FreeAndNil(fClient);
    fClient := TRecorderMebiusTcpClient.Create(fHost, Word(fPort), CMic185ConnectTimeoutMs);
    try
      fClient.Connect;
      QueryDeviceInfo;
      fState := rdsConnected;
      RecorderMic185RuntimeAttach(fHost, Word(fPort), fDeviceSerial, fSoftVersion,
        False);
      Exit;
    except
      on E: Exception do
      begin
        FreeAndNil(fClient);
        if lAttempt = CMic185ConnectAttempts then
          raise ERecorderDeviceError.CreateFmt('MIC183/185 connect failed: %s', [E.Message]);
      end;
    end;
  end;
end;

procedure TRecorderMic185Device.Disconnect;
begin
  if fState = rdsStarted then
    Stop;
  FreeAndNil(fClient);
  RecorderMic185RuntimeDetach(fHost, Word(fPort));
  fState := rdsDisconnected;
end;

procedure TRecorderMic185Device.ProgramDevice;
var
  lCommandIn: TRecorderByteArray;
  lCommandOut: TRecorderByteArray;
  lErrorMessage: string;
  lSettings: TRecorderByteArray;
  lStatusFlags: LongWord;
begin
  if fState = rdsDisconnected then
    Connect;
  if (fState = rdsDisconnected) or (fClient = nil) then
    Exit;

  lStatusFlags := 0;
  if fUtsEnabled then
    lStatusFlags := lStatusFlags or CMic185TaskSevEnFlag;
  SetLength(lCommandIn, SizeOf(lStatusFlags));
  Move(lStatusFlags, lCommandIn[0], SizeOf(lStatusFlags));
  if not fClient.TryCallCommand(CMic185IoCtlCmdSetControllerParams, lCommandIn,
    0, lCommandOut, lErrorMessage) then
    raise ERecorderDeviceError.CreateFmt('SetControllerParams: %s', [lErrorMessage]);

  lSettings := Mic185BuildSettings(fMeasFrequencyHz, fTempFrequencyHz, fUtsEnabled,
    fDeviceSerial, fSoftVersion);
  if not fClient.TryProgramDeviceBin(lSettings, lErrorMessage) then
    raise ERecorderDeviceError.CreateFmt('ProgramDeviceBin: %s', [lErrorMessage]);

  fSessionId := Mic185GenerateSessionId(fDeviceSerial);
  if not fClient.TrySetSessionId(fSessionId, lErrorMessage) then
    raise ERecorderDeviceError.CreateFmt('SetSessionId: %s', [lErrorMessage]);

  if not fClient.TryProgramMeasurement(lErrorMessage) then
    raise ERecorderDeviceError.CreateFmt('ProgramMeasurement: %s', [lErrorMessage]);

  fState := rdsProgrammed;
end;

procedure TRecorderMic185Device.Start;
var
  lErrorMessage: string;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsConnected then
    ProgramDevice;
  if (fState <> rdsProgrammed) or (fClient = nil) then
    Exit;

  if not fClient.TryStartMeasurement(lErrorMessage) then
    raise ERecorderDeviceError.CreateFmt('StartMeasurement: %s', [lErrorMessage]);
  fSampleIndex := 0;
  fState := rdsStarted;
  RecorderMic185RuntimeSetAcquiring(fHost, Word(fPort), True);
end;

procedure TRecorderMic185Device.Stop;
var
  lErrorMessage: string;
begin
  if (fClient <> nil) and (fState = rdsStarted) then
    fClient.TryStopMeasurement(lErrorMessage);
  if fState = rdsStarted then
  begin
    fState := rdsProgrammed;
    RecorderMic185RuntimeSetAcquiring(fHost, Word(fPort), False);
  end;
end;

function TRecorderMic185Device.LastTempValue(AIndex: Integer): Double;
begin
  if (AIndex >= 0) and (AIndex < Length(fLastTempValues)) then
    Result := fLastTempValues[AIndex]
  else
    Result := 0;
end;

function TRecorderMic185Device.LastUts: Double;
begin
  Result := fLastUtsValue;
end;

function TRecorderMic185Device.HasTempData: Boolean;
begin
  Result := fHasLastTemp;
end;

function TRecorderMic185Device.HasUtsData: Boolean;
begin
  Result := fHasLastUts;
end;

function TRecorderMic185Device.SniffPackets(APacketCount: Integer;
  ATimeoutMs: Cardinal): Integer;
begin
  Result := 0;
  if fClient <> nil then
    Result := fClient.SniffPackets(APacketCount, ATimeoutMs);
end;

function TRecorderMic185Device.RxDataPacketCount: Int64;
begin
  Result := 0;
  if fClient <> nil then
    Result := fClient.RxDataPacketCount;
end;

function TRecorderMic185Device.TestLink(out AErrorText: string): Boolean;
var
  lInfo: TMic185HardDeviceInfo;
  lOut: TRecorderByteArray;
begin
  Result := False;
  AErrorText := '';
  if (fState = rdsDisconnected) or (fClient = nil) then
  begin
    AErrorText := 'MIC183/185 is not connected';
    Exit;
  end;
  if fState = rdsStarted then
    Exit(True);
  if not fClient.TryCallCommand(CMic185IoCtlCmdGetSoftVersion, nil,
    CMic185HardDeviceInfoSize, lOut, AErrorText) then
    Exit;
  if Length(lOut) < CMic185HardDeviceInfoSize then
  begin
    AErrorText := Format('MIC183/185 info response is too short: %d bytes',
      [Length(lOut)]);
    Exit;
  end;
  Move(lOut[0], lInfo, SizeOf(lInfo));
  fDeviceSerial := lInfo.SerialNumber;
  fSoftVersion := lInfo.SoftVersion;
  RecorderMic185RuntimeUpdateInfo(fHost, Word(fPort), fDeviceSerial, fSoftVersion);
  Result := True;
end;

function TRecorderMic185Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderAcquisitionBlock): Boolean;
var
  I, J: Integer;
  lRaw: TRecorderMebiusFloatBlock;
  lTemp: TRecorderSingleArray;
  lHasTemp, lHasUts: Boolean;
  lUts: Single;
begin
  ClearRecorderAcquisitionBlock(ABlock);
  Result := False;
  if (fState <> rdsStarted) or (fClient = nil) then
    Exit;

  fClient.TimeoutMs := ATimeoutMs;
  if not fClient.ReadMeasDataBlock(fMeasChannelCount, lRaw, lTemp, lHasTemp,
    lUts, lHasUts) then
    Exit;

  if lHasTemp then
  begin
    SetLength(fLastTempValues, Length(lTemp));
    for I := 0 to High(lTemp) do
      fLastTempValues[I] := lTemp[I];
    fHasLastTemp := True;
  end;
  if lHasUts then
  begin
    fLastUtsValue := lUts;
    fHasLastUts := True;
  end;

  ABlock.ChannelCount := lRaw.ChannelCount;
  ABlock.SampleCount := lRaw.SampleCount;
  ABlock.SampleRateHz := fMeasFrequencyHz;
  ABlock.FirstTimeSec := fSampleIndex / fMeasFrequencyHz;
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

function CreateRecorderMic185Device: IRecorderDevice;
begin
  Result := TRecorderMic185Device.Create('MIC183/185', 'MIC183/185');
end;

end.
