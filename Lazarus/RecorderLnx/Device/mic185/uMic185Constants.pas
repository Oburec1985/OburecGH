unit uMic185Constants;

{
  Константы MIC185V2 из mic185v2base / computephysical.h (windev-v3.9).
}

{$mode objfpc}{$H+}

interface

const
  CMic185ChannelCountMax = 64;
  CMic185TempChannelCount = 5;
  CMic185UtsChannelCount = 1;
  CMic185TotalLogicalChannelCount =
    CMic185ChannelCountMax + CMic185TempChannelCount + CMic185UtsChannelCount;
  CMic185ModuleCount = 4;
  CMic185SettingsChannelSlots = CMic185ChannelCountMax + CMic185TempChannelCount;

  CMic185DefaultMeasFrequencyHz = 100.0;
  CMic185DefaultTempFrequencyHz = 1.0;
  CMic185TaskSevEnFlag = 1;

  CMic185Range500mV = 0;
  CMic185Range50mV = 1;
  CMic185Range5mV = 2;
  CMic185Range05mV = 3;

  CMic185CommutInput = 0;
  CMic185CommutGround = 1;
  CMic185CommutCalibr = 2;

  CMic185SensorSchemeTenzo = 0;
  CMic185SensorSchemeHalf = 1;
  CMic185SensorSchemeBridge = 2;

  CMic185DefaultGndCommutUs = 100;
  CMic185DefaultChnCommutUs = 150;
  CMic185DefaultBlnPortionLength = 30;
  CMic185DefaultHardBalance = 8192;
  CMic185DefaultAveragePointCount = 7;
  CMic185DefaultPowerMaCode = 10813;
  CMic185DefaultCalibrShuntIndex = 3;

  { ModAdditions (computephysical.h) — дополнение четвертьмоста. }
  CMic185ModAdd1 = 0;
  CMic185ModAdd2 = 1;
  CMic185ModAdd3 = 2;
  CMic185ModAdd4 = 3;
  CMic185ModAddOff = 4;

  { INTERNAL_PACKET_HEADER (MSVC): USHORT type_ + pad + ULONG sampl_count_ = 8 байт. }
  CMic185PacketDeviceIdSize = 4;
  CMic185PacketInternalHeaderSize = 8;
  CMic185PacketDataOffset = CMic185PacketDeviceIdSize + CMic185PacketInternalHeaderSize;

  CMic185IoCtlTypeCallCommand = 2;
  CMic185IoCtlCmdSetControllerParams =
    (CMic185IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic185IoCtlCmdGetSoftVersion =
    (CMic185IoCtlTypeCallCommand shl 16) or ($0002 shl 2);

  CMic185HardDeviceInfoSize = 64;
  CMic185DeviceTypeCode = $442A;

  CMic185DevIdUts = 0;
  CMic185DevIdMeasChannels = 1;
  CMic185DevIdTempChannels = 2;

  { LM74: mic185v2base.h / mic185v2scan.h — не ГХ, а физика цифрового датчика. }
  CMic185TempNegValueMask = $1000;
  CMic185TempCodesToValueCoeff = 0.0625;
  CMic185TempMinRangeC = -50.0;
  CMic185TempMaxRangeC = 100.0;
  CMic185BrokenSensorTempC = 200.0;

implementation

end.
