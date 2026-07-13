unit uMic185Constants;

{
  Константы MIC185V2 из mic185v2base / computephysical.h (windev-v3.9).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

const
  { Количество логических каналов MIC183/185 в потоке:
    64 измерительных, 5 температурных LM74 и 1 служебный UTS. }
  CMic185ChannelCountMax = 64;
  CMic185ChannelsPerModule = 16;
  CMic185TempChannelCount = 5;
  CMic185UtsChannelCount = 1;
  CMic185TotalLogicalChannelCount =
    CMic185ChannelCountMax + CMic185TempChannelCount + CMic185UtsChannelCount;
  CMic185ModuleCount = 4;
  CMic185SettingsChannelSlots = CMic185ChannelCountMax + CMic185TempChannelCount;

  { Частоты и служебный флаг задачи по умолчанию, совпадающие с базовой
    настройкой original/Mebius MIC185V2. }
  CMic185DefaultMeasFrequencyHz = 100.0;
  CMic185DefaultTempFrequencyHz = 1.0;
  CMic185TaskSevEnFlag = 1;

  { Индексы входных диапазонов в ProgramDeviceBin. Порядок важен:
    его ожидает прошивка прибора и исходный MIC185V2 Recorder. }
  CMic185Range500mV = 0;
  CMic185Range50mV = 1;
  CMic185Range5mV = 2;
  CMic185Range05mV = 3;

  { Коммутация измерительного канала: вход, земля, калибровочный источник. }
  CMic185CommutInput = 0;
  CMic185CommutGround = 1;
  CMic185CommutCalibr = 2;

  { Схема включения датчика для пересчета тензоканала в физические единицы. }
  CMic185SensorSchemeTenzo = 0;
  CMic185SensorSchemeHalf = 1;
  CMic185SensorSchemeBridge = 2;

  { Модульные настройки по умолчанию для программирования MIC185V2. }
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

  { IOCTL-коды Mebius для команд прибора: программирование и чтение версии. }
  CMic185IoCtlTypeCallCommand = 2;
  CMic185IoCtlCmdGetCalibrKoef =
    (CMic185IoCtlTypeCallCommand shl 16) or ($0001 shl 2);
  CMic185IoCtlCmdSetControllerParams =
    (CMic185IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic185IoCtlCmdGetSoftVersion =
    (CMic185IoCtlTypeCallCommand shl 16) or ($0002 shl 2);
  CMic185IoCtlCmdReloadCalibr =
    (CMic185IoCtlTypeCallCommand shl 16) or ($0008 shl 2);
  CMic185CalibrTypeDefault = 0;
  CMic185CalibrTypeInner = 1;

  CMic185HardDeviceInfoSize = 64;
  CMic185DeviceTypeCode = $442A;

  { Идентификаторы устройств внутри пакетов DATA_TRANSMIT_TASK_ID. }
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
