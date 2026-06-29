unit uRecorderMic140v2WireTypes;

{
  Wire-типы кадра скана и прошивки MC031.

  [ORIG] MIC140_48mod / TBiosInfoMC031 — layout полей firmware.
  [ORIG] Modscn / ScanMIC140 — заголовок BIOS-сообщения 10 WORD, data до ~102 WORD.
  [LNX]  ReadSerial, FirstSampleIndex — нумерация на стороне PC, не в BIOS.
}

{$mode objfpc}{$H+}

interface

const
  CMic140LegacyMaxScanDataWords = 512;  { LNX: room for MIC140v2 60-slot half-FIFO frames }
  MIC140DefaultChannelCount = 48;       { ORIG: MIC140_48mod MAX_COUNT_CHAN_AIN_48 }
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;      { ORIG: MAX_COUNT_CHAN_TIN_48 }
  MIC140v2InternalTemperatureChannelCount = 12; { ORIG: MIC140_48v2mod MAX_COUNT_CHAN_TIN_48V2 }
  MIC140DefaultPollFrequencyHz = 100.0;
  CMic140LegacyBiosNumBuffIdx = 8;      { ORIG: num_buff в header BIOS scan message }

type
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

  TMic140LegacyRawBlock = record
    Header: array[0..9] of Word;
    Data: array[0..CMic140LegacyMaxScanDataWords - 1] of Word;
    DataWordCount: Word;
    PayloadStrideWords: Word; { LNX: AIn(+TIn) words per sample row }
    FirstSampleIndex: Int64;  { LNX }
    ReadSerial: Int64;        { LNX }
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

  TMic140AuxTemperatureBlock = record
    ChannelCount: Integer;
    SampleCount: Integer;
    Values: array of array of Double;
    Valid: array of array of Boolean;
  end;  { LNX: TIn после декоммутации, не в payload BIOS }

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
