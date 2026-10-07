unit uRecorderDacTypes;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  TRecorderDacState = (rdsClosed, rdsConnected, rdsInitialized,
    rdsConfigured, rdsRunning, rdsStopping, rdsOffline);

  TRecorderDacStage = (rdsgNone, rdsgDiscover, rdsgConnect, rdsgInitialize,
    rdsgReadProperties, rdsgConfigure, rdsgStart, rdsgWrite, rdsgStop,
    rdsgDisconnect);

  TRecorderDacError = (rdeNone, rdeInvalidState, rdeInvalidConfig,
    rdeUnsupported, rdeNoData, rdeBufferTooSmall, rdeDriver,
    rdeFeedbackLoop);

  TRecorderDacUnderrunPolicy = (rdupZero, rdupHoldLast, rdupStop);

  TRecorderDacResult = record
    Error: TRecorderDacError;
    Stage: TRecorderDacStage;
    NativeCode: Integer;
    Text: string;
  end;

  TRecorderDacConfig = record
    SampleRateHz: Double;
    ChannelCount: Integer;
    FramesPerBlock: Integer;
    MinimumValue: Double;
    MaximumValue: Double;
    SafeValue: Double;
    UnderrunPolicy: TRecorderDacUnderrunPolicy;
  end;

  TRecorderDacCounters = record
    RequestedFrames: QWord;
    SubmittedFrames: QWord;
    MirroredFrames: QWord;
    Underruns: QWord;
    DroppedMirrorBlocks: QWord;
  end;

function RecorderDacOk: TRecorderDacResult;
function RecorderDacFailed(AError: TRecorderDacError;
  AStage: TRecorderDacStage; const AText: string;
  ANativeCode: Integer = 0): TRecorderDacResult;
function RecorderDacSucceeded(const AResult: TRecorderDacResult): Boolean;
function RecorderDacValidateConfig(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;

implementation

function RecorderDacOk: TRecorderDacResult;
begin
  Result.Error := rdeNone;
  Result.Stage := rdsgNone;
  Result.NativeCode := 0;
  Result.Text := '';
end;

function RecorderDacFailed(AError: TRecorderDacError;
  AStage: TRecorderDacStage; const AText: string;
  ANativeCode: Integer): TRecorderDacResult;
begin
  Result.Error := AError;
  Result.Stage := AStage;
  Result.NativeCode := ANativeCode;
  Result.Text := AText;
end;

function RecorderDacSucceeded(const AResult: TRecorderDacResult): Boolean;
begin
  Result := AResult.Error = rdeNone;
end;

function RecorderDacValidateConfig(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := (AConfig.SampleRateHz > 0) and (AConfig.ChannelCount > 0) and
    (AConfig.FramesPerBlock > 0) and
    (AConfig.MinimumValue < AConfig.MaximumValue) and
    (AConfig.SafeValue >= AConfig.MinimumValue) and
    (AConfig.SafeValue <= AConfig.MaximumValue);
  if Result then
    AResult := RecorderDacOk
  else
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Invalid DAC sample rate, channel count, block size or output range');
end;

end.
