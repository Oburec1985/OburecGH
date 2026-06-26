unit uRecorderMic140StreamTypes;

{
  Shared MIC-140 stream types used by protocol drivers, double buffer, and
  the data source. Keeps transport records out of the 6k-line datasource unit.
}

{$mode objfpc}{$H+}

interface

const
  CMic140LegacyMaxScanDataWords = 102;
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;

type
  TMic140LegacyRawBlock = record
    Header: array[0..9] of Word;
    Data: array[0..CMic140LegacyMaxScanDataWords - 1] of Word;
    DataWordCount: Word;
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

  { Вспомогательные TIn-отсчёты после декоммутации (только MIC-140, не Core). }
  TMic140AuxTemperatureBlock = record
    ChannelCount: Integer;
    SampleCount: Integer;
    Values: array of array of Double;
    Valid: array of array of Boolean;
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
