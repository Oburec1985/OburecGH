unit uRecorderMic140v2Consts;

{
  BIOS scan: команды, адреса DM, размеры дескрипторов.

  Метки:
    [ORIG]  — есть в исходниках Recorder (windev-v3.9), см. файл в комментарии.
    [LNX]   — добавлено в RecorderLnx (TCP-ридер, таймауты, восстановление).
}

{$mode objfpc}{$H+}

interface

const
  { --- scan_id / type [ORIG: mtc/Ccdevice.h TYPE_MIC140, scan_id=0 в Modscn] --- }
  { В подтверждённом дампе Recorder для MIC-140-48v3 используется scan_id=1.
    Этот идентификатор должен совпадать во всех командах и входных блоках. }
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

  { --- DM карта [ORIG: cc81ifc.h heap 0x800..0x2BFF;
       буфер MC031 с 0x0522: mtcEthernet81/Mc031ethernetifc.cpp DM_ADDR_BEGIN_BUFFER_MC031] --- }
  CMic140LegacyDmBufferBegin = $0522;
  CMic140LegacyDmBufferEnd = $07FF;   { ORIG: cc81ifc.h DM_ADDR_END_BUFFER }
  CMic140LegacyDmHeapBegin = $0800;
  CMic140LegacyDmHeapEnd = $2BFF;

  { --- размеры структур BIOS [ORIG: Modscn.cpp SIZE_BIOS_DESCSCANBUFF=10,
       SIZE_BIOSSCANCONTEXT=6; MIC140_48mod TDescChanBios_MIC140_96=5 words;
       mic140_96mod.h SIZE_START_DESC_CHAN_BIOS=3; header scan message 10 words] --- }
  CMic140LegacyBiosScanContextWords = 6;
  CMic140LegacyModuleScanDescWords = 5;
  CMic140LegacyBiosScanBufferDescWords = 10;
  CMic140LegacyBiosHeaderWords = 10;
  CMic140LegacyDescChanWords = 5;
  CMic140LegacyStartDescChanWords = 3;
  CMic140LegacyMaskGroundChannel = $4000;  { ORIG: MIC140_48mod MASK_CHAN_GR }

  { --- диапазоны АЦП [ORIG: mic140_96mod.cpp HARD_AMPLIF / CMic140Range*] --- }
  CMic140Range100mV = 0;
  CMic140RangeCount = 3;
  CMic140ChannelCommutIn = 0;
  CMic140ChannelCommutGround = 1;

  { --- таймауты и повторы [LNX: прямой TCP/MDP без MFC; не в Ccdevice] --- }
  { Обычные команды Recorder получают ответ за единицы миллисекунд.
    Короткий таймаут позволяет быстро восстановить TCP, не замораживая GUI
    на 5+5 секунд при потерянном ответе одного DM-фрагмента. }
  CMic140LegacyCommandTimeoutMs = 1500;
  { mdpEthernet81::CheckInitialized отправляет максимальный массив из
    32 нулевых WORD. Это обязательная первая команда холодного сеанса. }
  CMic140LegacyTestLoadArgWords = 32;
  CMic140LegacyTestLoadReplyWords = 2;
  { В эталонном дампе после CMD_RESET два RESETSCANMAIN разделены
    ожиданием загрузки BIOS около пяти секунд. }
  CMic140LegacyBiosResetFirstDelayMs = 50;
  CMic140LegacyBiosResetSettleMs = 5000;
  { Пауза между окончанием arm-последовательности и STARTSCANMAIN в дампе
    Recorder равна примерно 4,19 с. В это время запускается и калибруется АЦП. }
  CMic140LegacyAdcStartSettleMs = 4200;
  CMic140LegacyMessageBufferWords = 7183;
  CMic140LegacyInitialStartTimer = 1;
  CMic140LegacyRunStartTimer = $4801;
  CMic140LegacyStartCommandTimeoutMs = 12000;
  CMic140LegacyStartProbeTimeoutMs = 3000;
  CMic140LegacyStartAttempts = 2;
  CMic140LegacySoftRestartCorruptThreshold = 5;
  CMic140LegacySoftRestartMaxAttempts = 0;  { LNX: soft-restart отключён (0 попыток) }
  CMic140LegacyReadStallRestartMaxAttempts = 2;
  CMic140LegacyDrainMaxPacketsPerTick = 2;
  CMic140ConnectAttempts = 3;
  CMic140StopReadTimeoutMs = 50;          { LNX: короткий recv при Stop + read thread }
  CMic140NoDataFailThreshold = 10;

implementation

end.
