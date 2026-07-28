unit uRecorderMic140Consts;

{
  BIOS scan: ╨║╨╛╨╝╨░╨╜╨┤╤Л, ╨░╨┤╤А╨╡╤Б╨░ DM, ╤А╨░╨╖╨╝╨╡╤А╤Л ╨┤╨╡╤Б╨║╤А╨╕╨┐╤В╨╛╤А╨╛╨▓.

  ╨Ь╨╡╤В╨║╨╕:
    [ORIG]  тАФ ╨╡╤Б╤В╤М ╨▓ ╨╕╤Б╤Е╨╛╨┤╨╜╨╕╨║╨░╤Е Recorder (windev-v3.9), ╤Б╨╝. ╤Д╨░╨╣╨╗ ╨▓ ╨║╨╛╨╝╨╝╨╡╨╜╤В╨░╤А╨╕╨╕.
    [LNX]   тАФ ╨┤╨╛╨▒╨░╨▓╨╗╨╡╨╜╨╛ ╨▓ RecorderLnx (TCP-╤А╨╕╨┤╨╡╤А, ╤В╨░╨╣╨╝╨░╤Г╤В╤Л, ╨▓╨╛╤Б╤Б╤В╨░╨╜╨╛╨▓╨╗╨╡╨╜╨╕╨╡).
}

{$mode objfpc}{$H+}

interface

const
  { --- scan_id / type [ORIG: mtc/Ccdevice.h TYPE_MIC140, scan_id=0 ╨▓ Modscn] --- }
  { RecorderLnx и автономный тест используют единственную главную
    циклограмму scan_id=0. scan_id=1 из дампа оригинального Recorder
    принадлежит его многоскановому диспетчеру и без него неприменим. }
  CMic140LegacyScanId = 1;
  CMic140LegacyTypeMic140 = 12;  { TYPE_MIC140 }

  { --- BIOS CallCommand [ORIG: mtc/Ccdevice.h] --- }
  CMic140LegacyCmdTestLoad = 7;
  CMic140LegacyCmdReset = 10;
  CMic140LegacyCmdConfigSyncStart = 79;
  CMic140LegacyCmdAppendScanMain = 82;
  CMic140LegacyCmdResetScanMain = 83;
  CMic140LegacyCmdConfigScanMain = 84;
  CMic140LegacyCmdStartTriggerAdc = 85;
  CMic140LegacyCmdSetStateScan = 87;
  CMic140LegacyCmdConfigMessage = 90;
  CMic140LegacyCmdSetTimeoutStartTimer = 98;
  CMic140LegacyCmdScanSetChans = 132;
  CMic140LegacyCmdScanSetBuff = 133;
  CMic140LegacyCmdAddChannelModule = 152;

  { --- DM ╨║╨░╤А╤В╨░ [ORIG: cc81ifc.h heap 0x800..0x2BFF;
       ╨▒╤Г╤Д╨╡╤А MC031 ╤Б 0x0522: mtcEthernet81/Mc031ethernetifc.cpp DM_ADDR_BEGIN_BUFFER_MC031] --- }
  CMic140LegacyDmBufferBegin = $0522;
  CMic140LegacyDmBufferEnd = $07FF;   { ORIG: cc81ifc.h DM_ADDR_END_BUFFER }
  CMic140LegacyDmHeapBegin = $0800;
  CMic140LegacyDmHeapEnd = $2BFF;

  { --- ╤А╨░╨╖╨╝╨╡╤А╤Л ╤Б╤В╤А╤Г╨║╤В╤Г╤А BIOS [ORIG: Modscn.cpp SIZE_BIOS_DESCSCANBUFF=10,
       SIZE_BIOSSCANCONTEXT=6; MIC140_48mod TDescChanBios_MIC140_96=5 words;
       mic140_96mod.h SIZE_START_DESC_CHAN_BIOS=3; header scan message 10 words] --- }
  CMic140LegacyBiosScanContextWords = 6;
  CMic140LegacyBiosScanBufferDescWords = 10;
  { [ORIG: mic140_96scn.cpp SIZE_DESC_CHAN] ╨┤╨╡╤Б╨║╤А╨╕╨┐╤В╨╛╤А ╨╝╨╛╨┤╤Г╨╗╤П ╤Б╨║╨░╨╜╨░,
    ╨║╨╛╤В╨╛╤А╤Л╨╣ BIOS ╨╖╨░╨┐╨╛╨╗╨╜╤П╨╡╤В ╨┐╨╛ CMD_ADDCHANNELMODULE. }
  CMic140LegacyModuleScanDescWords = 5;
  CMic140LegacyBiosHeaderWords = 10;
  CMic140LegacyDescChanWords = 5;
  CMic140LegacyStartDescChanWords = 3;
  CMic140LegacyMaskGroundChannel = $4000;  { ORIG: MIC140_48mod MASK_CHAN_GR }

  { --- ╨┤╨╕╨░╨┐╨░╨╖╨╛╨╜╤Л ╨Р╨ж╨Я [ORIG: mic140_96mod.cpp HARD_AMPLIF / CMic140Range*] --- }
  CMic140Range100mV = 0;
  CMic140RangeCount = 3;
  CMic140ChannelCommutIn = 0;
  CMic140ChannelCommutGround = 1;

  { --- ╤В╨░╨╣╨╝╨░╤Г╤В╤Л ╨╕ ╨┐╨╛╨▓╤В╨╛╤А╤Л [LNX: ╨┐╤А╤П╨╝╨╛╨╣ TCP/MDP ╨▒╨╡╨╖ MFC; ╨╜╨╡ ╨▓ Ccdevice] --- }
  CMic140LegacyCommandTimeoutMs = 1500;
  { mdpEthernet81::CheckInitialized перед первой штатной командой передаёт
    максимальный массив из 32 нулевых WORD. Это прочищает командный автомат
    контроллера после холодного запуска. }
  CMic140LegacyTestLoadArgWords = 32;
  CMic140LegacyTestLoadReplyWords = 2;
  { После аппаратного CMD_RESET оригинальный Recorder дважды сбрасывает scan:
    второй RESETSCANMAIN идёт примерно через пять секунд, когда BIOS готов. }
  CMic140LegacyBiosResetFirstDelayMs = 50;
  CMic140LegacyBiosResetSettleMs = 5000;
  CMic140LegacyAdcStartSettleMs = 4200;
  CMic140LegacyMessageBufferWords = 7183;
  CMic140LegacyInitialStartTimer = 1;
  CMic140LegacyRunStartTimer = $4801;
  CMic140LegacyStartCommandTimeoutMs = 12000;
  CMic140LegacyStartProbeTimeoutMs = 3000;
  CMic140LegacyStartAttempts = 2;
  CMic140LegacySoftRestartCorruptThreshold = 5;
  CMic140LegacySoftRestartMaxAttempts = 0;  { LNX: soft-restart ╨╛╤В╨║╨╗╤О╤З╤С╨╜ (0 ╨┐╨╛╨┐╤Л╤В╨╛╨║) }
  CMic140LegacyReadStallRestartMaxAttempts = 2;
  CMic140LegacyDrainMaxPacketsPerTick = 2;
  CMic140ConnectAttempts = 3;
  CMic140StopReadTimeoutMs = 50;          { LNX: ╨║╨╛╤А╨╛╤В╨║╨╕╨╣ recv ╨┐╤А╨╕ Stop + read thread }
  CMic140NoDataFailThreshold = 10;

implementation

end.
