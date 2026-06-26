unit uRecorderMic140MebiusConstants;

{
  Размеры конфигурации Mebius MIC-140 (не legacy scan).
}

{$mode objfpc}{$H+}

interface

const
  CMic140MebiusChannelCount = 16;
  CMic140MebiusTemperatureSettingsCount = 5;
  CMic140MebiusModuleCount = 4;
  CMic140MaxAinChannels96 = 96;
  CMic140MaxAinChannels48 = 48;
  CMic140MaxTinChannels96 = 3;
  CMic140SensorSchemeTenzo = 0;
  CMic140DefaultCorrectorId = 2;
  CMic140RangeCountMic140 = 3;

implementation

end.
