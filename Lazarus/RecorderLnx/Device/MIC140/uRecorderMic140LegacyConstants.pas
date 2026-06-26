unit uRecorderMic140LegacyConstants;

{
  Инварианты legacy-протокола MIC-140: команды BIOS scan, адреса DM, размеры
  дескрипторов. Не зависят от частоты/каналов — вычисляемые параметры в
  uRecorderMic140LegacyTiming и uRecorderMic140ScanConfig.
}

{$mode objfpc}{$H+}

interface

const
  CMic140LegacyScanId = 0;
  CMic140LegacyTypeMic140 = 12;
  CMic140LegacyCmdAppendScanMain = 82;
  CMic140LegacyCmdResetScanMain = 83;
  CMic140LegacyCmdConfigScanMain = 84;
  CMic140LegacyCmdSetStateScan = 87;
  CMic140LegacyCmdScanSetChans = 132;
  CMic140LegacyCmdScanSetBuff = 133;
  CMic140LegacyCmdAddChannelModule = 152;

  CMic140LegacyDmBufferBegin = $0522;
  CMic140LegacyDmBufferEnd = $07FF;
  CMic140LegacyDmHeapBegin = $0800;
  CMic140LegacyDmHeapEnd = $2BFF;

  CMic140LegacyBiosScanContextWords = 6;
  CMic140LegacyBiosScanBufferDescWords = 10;
  CMic140LegacyBiosHeaderWords = 10;
  CMic140LegacyDescChanWords = 5;
  CMic140LegacyStartDescChanWords = 3;
  CMic140LegacyMaskGroundChannel = $4000;

  CMic140Range100mV = 0;
  CMic140RangeCount = 3;
  CMic140ChannelCommutIn = 0;
  CMic140ChannelCommutGround = 1;

  CMic140LegacyCommandTimeoutMs = 5000;
  CMic140LegacyStartCommandTimeoutMs = 12000;
  CMic140LegacyStartProbeTimeoutMs = 3000;
  CMic140LegacyStartAttempts = 2;
  CMic140LegacySoftRestartCorruptThreshold = 5;
  CMic140LegacySoftRestartMaxAttempts = 0;
  CMic140LegacyReadStallRestartMaxAttempts = 2;
  CMic140LegacyDrainMaxPacketsPerTick = 2;
  CMic140ConnectAttempts = 3;
  CMic140StopReadTimeoutMs = 50;
  CMic140NoDataFailThreshold = 10;

implementation

end.
