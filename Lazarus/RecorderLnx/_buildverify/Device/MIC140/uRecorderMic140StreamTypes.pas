unit uRecorderMic140StreamTypes;

{
  Совместимость: типы перенесены в uRecorderMic140v2WireTypes.
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140v2WireTypes;

const
  CMic140LegacyMaxScanDataWords = uRecorderMic140v2WireTypes.CMic140LegacyMaxScanDataWords;
  MIC140DefaultChannelCount = uRecorderMic140v2WireTypes.MIC140DefaultChannelCount;
  MIC140MaxChannelCount = uRecorderMic140v2WireTypes.MIC140MaxChannelCount;
  MIC140TemperatureChannelCount = uRecorderMic140v2WireTypes.MIC140TemperatureChannelCount;
  MIC140DefaultPollFrequencyHz = uRecorderMic140v2WireTypes.MIC140DefaultPollFrequencyHz;

type
  TMic140LegacyRawBlock = uRecorderMic140v2WireTypes.TMic140LegacyRawBlock;
  TRecorderMic140Timing = uRecorderMic140v2WireTypes.TRecorderMic140Timing;
  TMic140AuxTemperatureBlock = uRecorderMic140v2WireTypes.TMic140AuxTemperatureBlock;

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);

implementation

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);
begin
  uRecorderMic140v2WireTypes.ClearMic140AuxTemperatureBlock(ABlock);
end;

end.
