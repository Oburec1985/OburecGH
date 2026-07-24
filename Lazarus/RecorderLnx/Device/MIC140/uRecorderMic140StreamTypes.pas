unit uRecorderMic140StreamTypes;

{
  Базовые типы потока данных MIC-140 (Lazarus/RecorderLnx).
  Сделан полностью независимым от legacy-модулей.
}

{$mode objfpc}{$H+}

interface

const
  CMic140LegacyMaxScanDataWords = 2048;
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 10.0;

type
  TRecorderMic140OutputMode = (
    momMillivolts,
    momTemperatureC
  );

  TRecorderMic140ChannelSettings = record
    ChannelAddress: string;
    RangeIndex: Integer;
    CommutIndex: Integer;
    DefaultCjc: Boolean;
    CjcChannel: Integer;
    ThermocoupleScalePath: string;
    ThermocoupleScaleName: string;
    SoftBalance: Double;
    OutputMode: string;
    ChannelCalibrationEnabled: Boolean;
    HardwareCalibrationEnabled: Boolean;
    HardwareCalibrationName: string;
    CjcTemperOffsetC: Double;
  end;

  TRecorderMic140LegacyFirmware = record
    Signature: Word;
    MdpType: Word;
    DevType: Word;
    DevRevNo: Word;
    DevSerNo: Word;
    CCType: Word;
    CCSerNo: Word;
    EepromManufactId: Word;
    EepromDeviceId: Word;
    BiosFunction: Word;
    BiosVersion: Word;
  end;

  IMic140LegacyClient = interface
    ['{8A9B1C2D-3E4F-5A6B-7C8D-9E0F1A2B3C4D}']
    function ReadFirmware(out AFirmware: TRecorderMic140LegacyFirmware; out AErrorMessage: string): Boolean;
    function ReadFlashStorage(AAddress: LongWord; var ABuffer; AByteCount: Integer; out AErrorMessage: string): Boolean;
    function StopScan(out AErrorMessage: string): Boolean;
  end;

  TMic140AuxTemperatureBlock = record
    ChannelCount: Integer;
    SampleCount: Integer;
    Values: array of array of Double;
    Valid: array of array of Boolean;
  end;

  TMic140LegacyRawBlock = record
    Header: array[0..9] of Word;
    Data: array[0..CMic140LegacyMaxScanDataWords - 1] of Word;
    DataWordCount: Word;
    PayloadStrideWords: Word;
    FirstSampleIndex: Int64;
    ReadSerial: Int64;
  end;

  TRecorderMic140Timing = record
    FrequencyHz: Double;
    GroundCommutationUs: Double;
    ChannelCommutationUs: Double;
    AveragePeriodUs: Double;
    AverageSampleCount: Word;
    AveragePower: Word;
    LegacyGroundDelaySport: Word;
    LegacyChannelDelaySport: Word;
    LegacyAverageDelaySport: Word;
  end;

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);

implementation

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);
begin
  ABlock.ChannelCount := 0;
  ABlock.SampleCount := 0;
  SetLength(ABlock.Values, 0);
  SetLength(ABlock.Valid, 0);
end;

end.
