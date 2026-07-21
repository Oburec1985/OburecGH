unit uMc201ProtocolTypes;

{
  Автономные константы протокола MC-031/MC-032 + MC-201.

  Источники:
    - windev-v3.9/examples/mebius.daq/tests/medaq_mc_test/src/medaq_mc_test.cpp
    - windev-v3.9/mtcEthernet81/Mc031ethernetifc.cpp
    - windev-v3.9/mtc/CCDEVAPI.CPP
    - windev-v3.9/mtc/Ccdevice.h
    - windev-v3.9/mtc/Module.cpp

  Модуль намеренно независим от рабочих классов устройств RecorderLnx.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  TMc201WordArray = array of Word;

  TMc201ControllerBios = packed record
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

  TMc201SlotInfo = record
    Slot: Word;
    TypeId: Word;
    VersionCode: Word;
    SerialLo: Word;
    SerialHi: Word;
    Serial: Word;
    IsMc201: Boolean;
    IsMc201A: Boolean;
  end;

  TMc201SlotInfoArray = array of TMc201SlotInfo;

  TMc032DeviceState = (mcsDisconnected, mcsConnected, mcsPlay);

  TMc032Config = packed record
    SampleRateHz: Word;
    MaxSlots: Word;
    ReadTimeoutMs: Word;
    Reserved: Word;
  end;

  TMc201ModuleProgramInfo = record
    Slot: Word;
    MaskChan: Word;
    FifoSize: Word;
    FreqIndex: Word;
    GridCode: Word;
    DividerCode: Word;
    FinalFlags: array[0..3] of Word;
  end;

  TMc201ModuleProgramInfoArray = array of TMc201ModuleProgramInfo;

  TMc032DataPacket = record
    StreamPort: Word;
    PacketIndex: Int64;
    Words: TMc201WordArray;
  end;

  TMc032DataCallback = procedure(Sender: TObject;
    const APacket: TMc032DataPacket) of object;

const
  { Значения по умолчанию соответствуют текущему четырехслотовому стенду MC-201.
    Это настройки теста, а не глобальная политика устройств RecorderLnx. }
  CMc201DefaultHost = '192.169.12.87';
  CMc201DefaultPort = 4000;
  CMc201DefaultTimeoutMs = 1200;
  CMc201DefaultMaxSlots = 4;
  CMc201CrateMaxStartSlots = 16;
  CMc201DefaultSampleRateHz = 57600;
  CMc201DefaultUpdateMs = 200;
  CMc201DefaultAcceptanceMs = 5000;
  CMc201DefaultBiosPath = 'devices/mc201/mc_201a.bio';
  CMc201Cc81TimerScale = 1;
  CMc201Cc81TimerPeriod = 640;

  { Исходный слой mdpEthernet81: поток 1 используется для команд/ответов.
    Пакет может нести 1024 слова, но массив аргументов команды в оригинальном
    Ethernet81 меньше; см. CMc201CommandMaxArgWords. }
  CMc201MdpSyncWord = Word($12B8);
  CMc201MdpStreamCommand = Word(1);
  CMc201MdpMaxPacketWords = 1024;
  CMc201MdpCommandHeaderWords = 3;
  CMc201MdpHeaderBytes = 8;
  { В mdpEthernet81.cpp для аргументов команд используется
    MAX_TX/SIZE_TX_ARRAY = 32. Увеличение CallCommand-пакета выглядит заманчиво,
    но на живом MC-201 приводит к timeout загрузки BIOS. }
  CMc201CommandMaxArgWords = 32;
  { Команды IDMA-массивов тратят пять слов аргументов до данных: slot, dataReg,
    idmaReg, address, count. Адрес PM-памяти идет как count div 2, поэтому кусок
    данных оставлен четным. Проверка на стенде: 27 ломает PM, 26 работает. }
  CMc201IdmaArrayHeaderWords = 5;
  CMc201IdmaArrayMaxDataWords =
    ((CMc201CommandMaxArgWords - CMc201IdmaArrayHeaderWords) div 2) * 2;

  { Команды BIOS крейт-контроллера из оригинального Recorder. }
  CMc201CmdPutRemote = Word(2);
  CMc201CmdReadFlash = Word(3);
  CMc201CmdTestLoad = Word(7);
  CMc201CmdReset = Word(10);
  CMc201CmdIdmaCallCommand = Word(74);
  CMc201CmdIdmaGetArray = Word(77);
  CMc201CmdIdmaPutArray = Word(78);
  CMc201CmdConfigSyncStart = Word(79);
  CMc201CmdStartScanMain = Word(80);
  CMc201CmdStopScanMain = Word(81);
  CMc201CmdAppendScanMain = Word(82);
  CMc201CmdResetScanMain = Word(83);
  CMc201CmdConfigScanMain = Word(84);
  CMc201CmdStartTriggerStartAdc = Word(85);
  CMc201CmdSetTimeoutStartTimer = Word(98);
  CMc201CmdWriteDm = Word(111);
  CMc201CmdReply = Word(113);
  CMc201CmdReadMemDm = Word(114);
  CMc201CmdAddListStartModuleIdma = Word(129);
  CMc201CmdAddListStartAdcModuleIdma = Word(130);
  CMc201CmdScanSetChans = Word(132);
  CMc201CmdConfigModuleIdma = Word(146);
  CMc201CmdAddChannelModule = Word(152);

  { Команды BIOS модуля MC-201 из devapi/Const.h и Module.h. }
  CMc201ModuleCmdSendControlRegister = Word(22);
  CMc201ModuleCmdSetTimeoutStart = Word(28);
  CMc201ModuleCmdSetTimeoutStartAdc = Word(29);
  CMc201ModuleCmdInit = Word(21);
  CMc201ModuleCmdStopScan = Word($8005);
  CMc201ModuleCmdResetScan = Word($8006);
  CMc201ModuleCmdSetChanList = Word(41);
  CMc201ModuleCmdSetGrid = Word(50);
  CMc201ModuleCmdSetFreq = Word(51);
  CMc201ModuleCmdConfigRaw = Word(58);
  CMc201ModuleCmdConfigDbl = Word(59);
  CMc201ModuleCmdConfigMix = Word(60);
  CMc201ModuleCmdGetFinalFlag = Word(63);

  { Адресные константы MC-201/CC81, используемые ScanMC201::Programming. }
  CMc201IsDm = Word($4000);
  CMc201ModuleDataReg = Word(0);
  CMc201ModuleIdmaReg = Word(1);
  CMc201ModuleIrqReg = Word(3);
  CMc201ModuleResetReg = Word(3);
  CMc201ModuleBiosLoadVarSpace = Word($4000 or $3800);
  CMc201ModuleBiosLoadTMode = Word($4000 or $3F00);
  CMc201ModuleBiosLoadFlag = Word($A5A5);
  CMc201ModuleVarVars = Word($4000 or $3F02);
  CMc201ModuleVarCommand = Word($4000 or $3F01);
  CMc201FlagCommandFinish = Word($A5A5);
  CMc201DmHeapBegin = Word($0800);
  CMc201DmHeapEnd = Word($2BFF);
  CMc201BiosScanContextWords = Word(6);
  CMc201BiosMessageHeaderWords = 10;
  CMc201BiosMessageMaxWords = CMc201BiosMessageHeaderWords + 1024;
  CMc201DescModuleWords = Word(4);
  CMc201DescChanWords = Word(5);
  CMc201ScanIdDefault = Word(0);
  CMc201ScanTypeMc201 = Word(10);
  CMc201MaxModuleChannels = 4;

  { Смещения flash модуля из Ccdevice.h / Module.cpp. }
  CMc201FlashTypeOffset = Word(0);
  CMc201FlashVersionOffset = Word(1);
  CMc201FlashSerialHiOffset = Word(61);
  CMc201FlashSerialLoOffset = Word(62);

  { Сигнатуры MC-201 для AutoSearchModule из mtc/Main.cpp. }
  CMc201FlashTypeId = Word(201);
  CMc201VersionCount = 9;
  CMc201VersionCodes: array[0..CMc201VersionCount - 1] of Word =
    (128, 129, 2170, 2171, 2176, 2177, 2178, 2179, 2180);
  CMc201AVersionCode = Word(2180);

function Mc201IsKnownVersionCode(AValue: Word): Boolean;
function Mc201FormatBios(const ABios: TMc201ControllerBios): string;
function Mc201FormatProgramInfo(const AInfo: TMc201ModuleProgramInfo): string;

implementation

uses
  SysUtils;

function Mc201IsKnownVersionCode(AValue: Word): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(CMc201VersionCodes) to High(CMc201VersionCodes) do
    if CMc201VersionCodes[I] = AValue then
      Exit(True);
end;

function Mc201FormatBios(const ABios: TMc201ControllerBios): string;
begin
  Result := Format(
    'signature=%u mdpType=%u devType=%u devRev=%u devSer=%u ccType=%u ccSer=%u bios=%u.%u',
    [ABios.Signature, ABios.MdpType, ABios.DevType, ABios.DevRevNo,
     ABios.DevSerNo, ABios.CCType, ABios.CCSerNo,
     ABios.BiosVersion, ABios.BiosFunction]);
end;

function Mc201FormatProgramInfo(const AInfo: TMc201ModuleProgramInfo): string;
begin
  Result := Format(
    'slot=%u mask=0x%s fifo=%u freqIndex=%u grid=%u divider=0x%s final=[0x%s 0x%s 0x%s 0x%s]',
    [AInfo.Slot, IntToHex(AInfo.MaskChan, 4), AInfo.FifoSize,
     AInfo.FreqIndex, AInfo.GridCode, IntToHex(AInfo.DividerCode, 4),
     IntToHex(AInfo.FinalFlags[0], 4), IntToHex(AInfo.FinalFlags[1], 4),
     IntToHex(AInfo.FinalFlags[2], 4), IntToHex(AInfo.FinalFlags[3], 4)]);
end;

end.
