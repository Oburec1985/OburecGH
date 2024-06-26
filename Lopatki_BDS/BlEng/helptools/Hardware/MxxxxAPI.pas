// ����� ������� ��������� � ������������� �� ���� � ������� ������� ���������� mxxxx.dll
// 1.	�������������� ����� �� ������� PCI � ������� ������� SearchDevices.
// ��� ������������� ������ � ISA ��������, ����� �� �������� � ��������� TDeviceEnum
// ������� ������� AddISADevice. ��� 1 ���������� ��������� ���� ��� �����
// �������������� ��������� ��������.
// 2.	��������� ������������� �� ������, � ������� �������������� ����������
// � ������� ������� CreateDevice.
// 3.	��������� ��������� ������ �� INI ����� � ������� ������� ReadPropertyEx.
// 4.	������������� ����� ������� � ����������� ���������� � ������� �������
// setInterrupt.
// 5.	������������� �� ������ � ������� ������� Config
// 6.	��������� � �� ������ ��� ���� � ����� � ������� ������� Load.
// 8.	�������������� ����� ��� ������/�������� ������. ������ ������ ����������
// ������� ������� GetMaxBufSize.
// 7.	�������������� � ��������� ������������������ ������ � ������� ������� Start.
// 8.	����� ��������� ������ � �� ���������, ����������� ������ ����������� ����������,
// ������������� ������ ������ � ������� ������� Stop.
// ���� 3-8 ����� ����������� � �������� ������������������ ��������� ���.
// 9.	����������� �������, ������� ������� ������� � ������� ������� CloseDevice.

unit MxxxxAPI;
{$OPTIMIZATION OFF}
interface
uses
  MxxxxTypes;

Type
  PLongWord=^LongWord;
  PWord         = ^Word;
  PIRQEvent=^TIRQEvent;
  TIRQEvent=Record
      scan_id       : LongWord;       // Id �����
      event_id      : LongWord;       // Id ������ �������
      time          : LongWord;       // ������
      local_number  : LongWord;       // ...���. ���������...
      global_number : LongWord;       // ...���. ���������...
  end;
  THandler=Function(Device:Pointer;Event:PIRQEvent;Data:Pointer):Integer;cdecl;


  // ������ � 2070. �������� ������ DeviceEnum ��������� � ������� �������
  function SearchDevicesEx(DeviceEnum : PDeviceEnum) : cardinal;  stdcall;
  // �������� ������ �� ���������� device
  function CreateDevice(DevInfo : TDevice; device : ppointer) : cardinal; stdcall;
  // ����������� ������ �� ���������� device
  function CloseDevice(device : ppointer)  : cardinal;  stdcall;
  // ��������� Bios � �������� Flex � �� ������ (���� � ��� ������ �������
  // � ����� *.ini).
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0) � ������
  // ��� ���� ������: ERROR_BIOS_CODE_NOT_FOUND=14, ERROR_FLEX_CODE_NOT_FOUND=15
  // ������ ���� ��������������� ����� �� �������, ���� ERROR_BIOS_NOT_LOADED=18,
  // RROR_FLEX_NOT_LOADED=19 � ������ ����������� ������ ��������, ����
  // ERROR_DEVICE_NOT_RESPOND=25 ���� ���������� �� �������� ����� �������� Flex.
  function Load(device : ppointer) : cardinal; stdcall;
  function LoadBios(device : ppointer) : cardinal; stdcall;
  function LoadFlex(device : ppointer) : cardinal; stdcall;
  // ������������� �� ������.
  // � �������� ��������� ������� ���������� ����� ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0) � ������ ������
  // ��� ������ ERROR_DMALOCK=35 ���� �� ������� ��������������� ������
  function Config(device : ppointer) : cardinal;  stdcall;
  function ConfigDevice(device : ppointer) : cardinal;  stdcall;
  // function ConfigurePort(device : ppointer;lpFileName : pointer;lpAppName : pointer; Port : word; Task : word) : cardinal;  stdcall;
  // ������� ���������� ��������� �� ������ �����������, ���������� �� *.ini �
  // ������ �� ���������� ������������������ ������.
  // � �������� ��������� ������� ���������� ����� ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0) � ������
  // ��� ��� ������ ERROR_DEVICE_NOT_RESPOND=25, ���� ���������� �� ��������.
  function Start(device : ppointer) : cardinal;  stdcall;
  // ������������� ���������� ������� ������.
  // � �������� ��������� ������� ���������� ����� ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0) � ������ ������ ��� ��� ������ ERROR_DEVICE_NOT_RESPOND=25, ���� ���������� �� ��������.
  function Stop(device : ppointer) : cardinal;  stdcall;
  // ������� ����� �������� direction ���������� ������� ����������� ������. ��������� � ������� ����� ����� ������ ����������� ����������.
  // � �������� ������� ��������� ������� ���������� ����� ������.
  // Direction ��������� �������� 0 ���� �������� ������ ������, 1- ���� �������� ������ ��������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function GetDirection(device : ppointer;direction : PWord): cardinal;  stdcall;
  function WritePropertyEx(device : ppointer;lpFileName : pointer;lpAppName : pointer): cardinal;  stdcall;
  // ������� ��������� �� *.ini �����, ���� � ��� �������� ����������� ����������
  // pFileName, ��������� ������ ��� �� ������, ��� ����������� ���������� lpAppName.
  // � �������� ��������� ������� ���������� ����� ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0) � ������ ������
  // ��� ������ ERROR_INI_FILE=37 ���� ���� ���
  // ������ �� �������, ���� ��������� ������ �����������.
  function ReadPropertyEx(device : ppointer;lpFileName : pointer;lpAppName : pointer): cardinal;  stdcall;
  // ������� ����� ��������� �������� ���������� � ������� �������� ������, ������� ����� ��������� �� ������, � ���������� ��������.
  // ��������� �������:
  // device � ����� �� ������
  // dSizeBuf � ����� ����������, � ������� ����� ������� ������ �������� ������ � ������.
  // dwSizeLost � ����� ����������, ������� ����� �������� ����� ����������� ����.
  // dwSizeOverflow � ����� ����������, � ������� ����� ������� ������ ������������ � ������.
  function GetReadBufSize(device : ppointer; pSizeBuf : PLongint; pSizeLost : PLongint; pSizeOverflow : PLongint) : cardinal;  stdcall;
  // ������� ����� ��������� �������� ���������� � ������� �������� ������, ������� ����� �������� � ������ � ���������� ��������.
  // ��������� �������:
  // device � ����� �� ������
  // dSizeBuf � ����� ����������, � ������� ����� ������� ������ ������ ��� ������ � ������.
  // dwSizeLost � ����� ����������, ������� ����� �������� ����� ����������� ����.
  // dwSizeOverflow � ����� ����������, � ������� ����� ������� ������ ������������ � ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function GetWriteBufSize(device : ppointer; pSizeBuf : PLongint; pSizeLost :PLongint;
                           pSizeOverflow : PLongint): cardinal;  stdcall;
  // ������� ��������� ������� ����� �� �� ������
  // � �������� ���������� ������� ����������:
  // device � ����� �� ������
  // SizeBuf � ����� ����������, � ������� �������� ������ ������ � ������. �������� ���� ���������� ���������� ������� GetReadBufSize.
  // pBuf � ����� ������, � ������� ����� �������� ����������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function ReadBuf(device : ppointer; pBuf : PWord; dSizeBuf : PLongint): cardinal;  stdcall;
  // ������� ���������� ����� � �� ������.
  // � �������� ���������� ������� ����������:
  // device � ����� �� ������
  // SizeBuf � ����� ����������, � ������� �������� ������ ������������� ������ � ������.
  // pBuf � ����� ������ �� �������� ����� ������������ ����������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function WriteBuf(device : ppointer; pBuf : PWord; dSizeBuf : PLongint): cardinal;  stdcall;
  // ������������� ���������� ����������, ������������ �� �� ������ ����� ������� ������. ���������� ��������� ��� ������������� ������ ��� �������� ��������� ������ ������. �������-���������� ���������� ������ ���� ����������� (����� ������������� �����).
  // � �������� ���������� ������� ����������:
  // device � ������� �� ������
  // DataHandler � ��������� �� ������, ������� ���������� � �������� ��������� ����������.
  // IntHandler � ����� ������� - ����������� ����������
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function SetInterrupt(device : ppointer; DataHandler : pointer; IntHandler : pointer): cardinal;  stdcall;
  // ������� ������������ ����� ����������. ���������� ��������� ��������, ������������ ���������� (� ��� ����� - ����� ���������� ����, ����� ���������� ����  � �������� ������������).
  // � �������� ��������� ������� ���������� ����� ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function ResetCount(device : ppointer): cardinal;  stdcall;
  // ������� ���������� ������ ����������� ���������� ������ � ������ � ����������
  // � ����������, ������� ���������� � �������� ��������� dwMaxBufSize
  function GetMaxBufSize(device : ppointer;dwMaxBufSize : PLongint): cardinal;  stdcall;
  // ������� ��������� ������� �������� ��������� ��������� �� ������ � ���������������, ������������ � ������� ��������� Prop, � �������� Variant. �������� Variant ����� ����� ���������, ������������ ��� ����� ��� � ����������� �� �������������� ���������.
  // �������������� ���������� ��������� ������� � ����� const.h (�++) ��� MxxxxTypes.pas (Object Pascal). ������ ����������, ��������������� ��������� ��������� �� �������, ���������� � ����� Plat_prm.h (C++) ��� Plat_prm.pas (Object Pascal).
  // � �������� ������� ��������� ������� ���������� ����� ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function GetProperty(device : ppointer; TypeProp:Longint;var VarProp: Variant): cardinal; stdcall;
  // ������� ������������� �������� ��������� �� ������ � ���������������, ������������ � ������� ��������� Prop, � ��������, ������������ � ������� ��������� Variant. �������� Variant ������ ����� ���������, ������������ ��� ����� ��� � ����������� �� �������������� ���������.
  // �������������� ���������� ��������� ������� � ����� const.h (�++) ��� MxxxxTypes.pas (Object Pascal). ������ ����������, ��������������� ��������� ��������� �� �������, ���������� � ����� Plat_prm.h (C++) ��� Plat_prm.pas (Object Pascal).
  // � �������� ������� ��������� ������� ���������� ����� ������.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0).
  function SetProperty(device : ppointer; TypeProp:Longint;var VarProp: Variant): cardinal; stdcall;
  function AddISADevice(pDeviceEnum :PDeviceEnum; TypeCard: longint;  Port: longint; Irq: longint; SN: longint) : cardinal; stdcall;
  // ������������ �� ������. ����� ������ ���������� � �������� ������� ���������. lpFileName � ���� � ��� INI-����� �� �������� ����� ������� ������������ ��� ������������, ��� ������� �������� ���������� lpAppName.
  // ������� ���������� ��� ��������� ���������� (ERROR_NOERROR = 0) � ������ ���� ������ ��� ������������ �� ����������. � ��������� ������ ������� ���������� ���� ������. ��� ������ ERROR_INI_FILE=37 ���� ���� INI ��� ��������� ������ �� �������, ���� ��������� ������ �����������. ��� ������ ERROR_TEST_PM=65 ���� ��������� ������ ������/������ ������ ��������� �� ������ ����� ������ �����/������. ��� ������ ERROR_TEST_DM=64 ���� ��������� ������ ������/������ ������ ������ �� ������ ����� ������ �����/������. ��� ������ ERROR_TEST_PM_PCI=67 ���� ��������� ������ ������/������ ������ ��������� �� ������ ����� ������ �����/������ PCI. ��� ������ ERROR_TEST_DM_PCI=66 ���� ��������� ������ ������/������ ������ ������ �� ������ ����� ������ �����/������ PCI.
  // � �������� ���������� ������������ ����������� ������� Load � Config, ��������� ����. ������� ������� ������������ ����� ���������� ���� ������, ����������� ��� ���� �������. ������ ERROR_TEST_IO=69 � ������ ������������� �������������� �������������� �����������, ������������ � �������� dwTest. ��� ���������� ���������� ��� ��������� ����� �� �������:
  // - M2081 � M1081 -  ������ ������ ������ 1 ������������� ������������ ������� �� ����� ��� �� ������.
  // - M2181 � M1181 �������� ��������� ����� ������������� ������� ������, ��������� ������.
  // - M2070 � M1070 � ��� ���� ������� ������ ������ �� ������������, dwTest=0.
  function Test(device : ppointer; lpFileName : pointer; lpAppName : pointer; dwTest : PLongint): cardinal;  stdcall;
  function CallCommand(device : ppointer;command : word; wLengthInParam : word; pInParam : pword; wLengthOutParam : word; pOutParam : pword) : cardinal; stdcall;
  // �������� ������ (���������� �������������������)
  // ������������������� � ����� M2070
  // � ������� pBuf - ������������������ 32-��������� ����. ������ 20 ��� ������ ���������� � ���������
  // �������. ������ ������ ��� - ��������� ������� ������, 2����� - ������� � �.�.
  function LpOscil(device : pPointer; freq:double; Vars:PWord; vSize:word; pBuf:PWord; var BufSize:word): cardinal;  stdcall;
  function LpProgramME052(device : ppointer; channel:word; VeryLongWord:PWord): cardinal;  stdcall;
  function LpSetAnalogChan(device : ppointer; chan:word): cardinal;  stdcall;

  // �������� ���������� M2081:
  // ����� device_id - ���������� ������������� ���������� (�����),
  //       vendor_num - ����� ������������,
  //       device_num - ����� ����������,
  //       num - �������������� �����
  //       _bios_size - ����� _bios_code
  //       _bios_code - ��� bios, ����������� �� ����� *.bio
  //       _flex_size - ����� _flex_code
  //       _flex_code - ��� flex, ����������� �� ����� *.rbf
  //   _NWord, _CntFrame, _CntPartFifo - ������� ������ (_CntPartFifo ������ ��
  //                                         _CntFrame ������� �� _NWord ����),
  //       _name - ���� WD_CARD_REGISTER: name of card (NB: ���� �� ������������ - ������)
  //       _description - ���� WD_CARD_REGISTER: description (NB: ���� �� ������������ - ������)
  function  CreateM2081Device(pIdDevice:System.PLongWord;Vendor:LongWord;Device:LongWord;Num:LongWord;SizeBios:LongWord;Bios:Pointer;SizeFlex:LongWord;Flex:Pointer;
                                NWord:LongWord;CntFrame:LongWord;CntPartFifo:LongWord;const Name:PansiChar;const Description:PansiChar):Integer;stdcall;
  function Close2081Device(IdDevice:LongWord):Integer;stdcall;
  function  Load2081BIOS(const IdDevice:LongWord;const BiosModule:Integer):Integer;stdcall;
  function  LoadFlexM2081(const IdDevice:LongWord):Integer;stdcall;
  // �������� callback �� ����������� �������
  function  CreateScan(IdDevice:LongWord;IdScan:System.PLongWord;IdScanType:LongWord;
                          Prior:LongWord;Handler:THandler;Data:Pointer):Integer;stdcall;
  function  FreeScan(IdDevice,IdScan:LongWord):Integer;stdcall;
  function  StartScanMain(IdDevice:LongWord):Integer;stdcall;
  function  StopScanMain(IdDevice:LongWord):Integer;stdcall;
  function  ResetScanMain(IdDevice:LongWord):Integer;stdcall;
  function  Read2081Buf(IdDevice:LongWord;IdScanL:LongWord;Buf:Pointer;Bufsize:PWord):Integer;stdcall;
  function  ProgrammingComp(IdDevice:LongWord;NumChan:LongWord;Data:LongWord):Integer;stdcall;
  // ���������������� ������ MC052V5 size- ������ ������� � �����  data - ������
  function ProgrammingMC052V5(IDdevice, num, size: LongWord; Buf:Pointer):Cardinal;stdcall;
  //--------------------------------------------------------------------
  // ����� ������ "�������" ���������� �����
  // size_out - ������ ������ channel_out � ������ (���� = 2720)
  // channel_out - ��������� �� ������ �������, ������ - ����� 16�
  // buf - ������ ������, ������ - ������� ����� 32 �
  // timeout -  ��
  //--------------------------------------------------------------------
  function  Read_Blade(IdDevice:LongWord;const InSize:LongWord;InChannel:Pointer;const OutSize:LongWord;OutChannel:Pointer;Buf:Pointer;Timeout:LongWord):Integer;stdcall;
  procedure Config_Blade(IdDevice:LongWord;InSize:LongWord;InChannel:Pointer;Datasize:LongWord);stdcall;
  // ������� ��� ������ ����� ����� �� ��������� ������� � �������������� ����������� �������
  // mode =
  //     0-2 ��� - ����� ������
  //        0 - ������ ����
  //        1 - ������ ����
  //        2 - ��� �����
  //    3 ��� = 0 - ������� ����
  //             1 - �� �������
  //     4 ��� = 0 - ��� �������������
  //             1 - �������������
  // syncchan - �����������
  //      0-31 - ����� ������
  //      15 ��� - ����� = 0 - �������������
  //                       1 - �������������
  // freq = 3 ... 300000 ��
  // size_out = 1... 8192
  // �����. (8.25 ��� - ���� ����, 5.5 ��� - ��� �����)
  // �� ������� (2 �� ... 3 ��� - ���� ����, 2 ��...2.5 ��� - ���)
  procedure DigBlIn(IdDevice:LongWord;Mode:LongWord;SyncChan:LongWord;Freq:LongWord;BufSize:LongWord;Buf:Pointer);stdcall;
  //Function ReadRemoteWordPCI(Adress:Word):Word;stdcall;


Const
  LO_TIMER      = $4;             //  ������ �� �������
  LO_SYNC       = $8;             //  ������������� �� ������
  LO_NEG_FRONT  = $8000;          //  �� ����������� ������

implementation

  function  CreateM2081Device(pIdDevice:System.PLongWord;Vendor:LongWord;Device:LongWord;Num:LongWord;SizeBios:LongWord;Bios:Pointer;SizeFlex:LongWord;Flex:Pointer;
                                  NWord:LongWord;CntFrame:LongWord;CntPartFifo:LongWord;const Name:PansiChar;const Description:PansiChar):Integer;External 'M2081LOP.DLL' name '_CreateM2081Device@52';
  function Close2081Device(IdDevice:LongWord):Integer; External 'DevApi81.dll' name '_CloseDevice@4';
  function  Load2081BIOS(const IdDevice:LongWord;const BiosModule:Integer):Integer; External 'DevApi81.dll' name '_LoadBIOS@8';
  function  LoadFlexM2081(const IdDevice:LongWord):Integer; External 'M2081LOP.DLL' name '_LoadFlexM2081@4';
  function  CreateScan(IdDevice:LongWord;IdScan:System.PLongWord;IdScanType:LongWord;
                             Prior:LongWord;Handler:THandler;Data:Pointer):Integer;External 'DevApi81.dll' name '_CreateScan@24';
  function  FreeScan(IdDevice,IdScan:LongWord):Integer;External 'DevApi81.dll' name '_DeleteScan@8';
  function  StartScanMain(IdDevice:LongWord):Integer;External 'DevApi81.dll' name '_StartScanMain@4';
  function  StopScanMain(IdDevice:LongWord):Integer;External 'DevApi81.dll' name '_StopScanMain@4';
  function  ResetScanMain(IdDevice:LongWord):Integer;External 'DevApi81.dll' name '_ResetScanMain@4';
  function  Read2081Buf(IdDevice:LongWord;IdScanL:LongWord;buf:Pointer;Bufsize:PWord):Integer;External 'DevApi81.dll' name '_ReadBuf@16';
  function  ProgrammingComp(IdDevice:LongWord;NumChan:LongWord;Data:LongWord):Integer;External 'M2081LOP.DLL' name '_ProgrammingComp@12';
  function ProgrammingMC052V5(IDdevice, num, size: LongWord; Buf:Pointer):Cardinal;External 'M2081LOP.DLL' name '_ProgrammingMC052V5@16';
  function  Read_Blade(IdDevice:LongWord;const InSize:LongWord;InChannel:Pointer;const OutSize:LongWord;
                            OutChannel:Pointer;Buf:Pointer;Timeout:LongWord):Integer; External 'M2081LOP.DLL' name '_COMP@28';
  procedure Config_Blade(IdDevice:LongWord;InSize:LongWord;InChannel:Pointer;Datasize:LongWord);External 'M2081LOP.DLL' name '_CONFIG_COMP@16';
  procedure DigBlIn(IdDevice:LongWord;Mode:LongWord;SyncChan:LongWord;Freq:LongWord;BufSize:LongWord;Buf:Pointer);External 'M2081LOP.DLL' name '_DigBlIn@24';
  //Function  ReadRemoteWordPCI(Adress:Word):Word;external 'M1XXX.DLL';

   function SearchDevicesEx(DeviceEnum : PDeviceEnum) : cardinal;  External 'Mxxxx.dll' name 'SearchDevicesEx' ;
   function CreateDevice(DevInfo : TDevice; device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'CreateDevice';
   function CloseDevice(device : ppointer)  : cardinal;  External 'Mxxxx.dll' name 'CloseDevice';
   function Load(device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'Load';
   function LoadBios(device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'LoadBios' ;
   function LoadFlex(device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'LoadFlex'  ;
   function Config(device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'Config'       ;
   function ConfigDevice(device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'ConfigDevice'  ;
//   function ConfigurePort(device : ppointer;lpFileName : pointer;lpAppName : pointer; Port : word; Task : word) : cardinal;  External 'Mxxxx.dll' name 'ConfigurePort'
   function Start(device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'Start';
   function Stop(device : ppointer) : cardinal;  External 'Mxxxx.dll' name 'Stop'   ;
   function GetDirection(device : ppointer;direction : PWord): cardinal;  External 'Mxxxx.dll' name 'GetDirection';
   function WritePropertyEx(device : ppointer;lpFileName : pointer;lpAppName : pointer): cardinal;  External 'Mxxxx.dll' name 'WritePropertyEx';
   function ReadPropertyEx(device : ppointer;lpFileName : pointer;lpAppName : pointer): cardinal;  External 'Mxxxx.dll' name 'ReadPropertyEx';
   function GetReadBufSize(device : ppointer; pSizeBuf : PLongint; pSizeLost : PLongint; pSizeOverflow : PLongint) : cardinal;  External 'Mxxxx.dll' name 'GetReadBufSize';
   function GetWriteBufSize(device : ppointer; pSizeBuf : PLongint; pSizeLost : PLongint; pSizeOverflow : PLongint): cardinal;  External 'Mxxxx.dll' name 'GetWriteBufSize';
   function ReadBuf(device : ppointer; pBuf : PWord; dSizeBuf : PLongint): cardinal;  External 'Mxxxx.dll' name 'ReadBuf';
   function WriteBuf(device : ppointer; pBuf : PWord; dSizeBuf : PLongint): cardinal;  External 'Mxxxx.dll' name 'WriteBuf';
//   function ReadProperty(device : ppointer; lpFileName : pointer; wMode : word) : cardinal;  External 'Mxxxx.dll' name 'ReadProperty'
//   function WriteProperty(device : ppointer; lpFileName : pointer; wMode : word): cardinal;  External 'Mxxxx.dll' name 'WriteProperty'
   function SetInterrupt(device : ppointer; DataHandler : pointer; IntHandler : pointer): cardinal;  External 'Mxxxx.dll' name 'SetInterrupt';
   function ResetCount(device : ppointer): cardinal;  External 'Mxxxx.dll' name 'ResetCount';
   function GetMaxBufSize(device : ppointer;dwMaxBufSize : PLongint): cardinal; External 'Mxxxx.dll' name 'GetMaxBufSize';
   function GetProperty(device : ppointer; TypeProp:Longint; var VarProp: Variant): cardinal;  External 'Mxxxx.dll' name 'GetProperty';
   function SetProperty(device : ppointer; TypeProp:Longint; var VarProp: Variant): cardinal;  External 'Mxxxx.dll' name 'SetProperty' ;
   function AddISADevice(pDeviceEnum :PDeviceEnum; TypeCard: longint;  Port: longint; Irq: longint; SN: longint) : cardinal; External 'Mxxxx.dll' name 'AddISADevice';
   function Test(device : ppointer; lpFileName : pointer; lpAppName : pointer; dwTest : PLongint): cardinal;  External 'Mxxxx.dll' name 'Test';
   function CallCommand(device : ppointer;command : word; wLengthInParam : word; pInParam : pword; wLengthOutParam : word; pOutParam : pword) : cardinal;  External 'Mxxxx.dll' name 'CallCommand';
   function LpOscil(device : ppointer; freq:double; Vars:PWord; vSize:word; pBuf:PWord; var BufSize:word): cardinal;  External 'M2070.dll' name 'LpOscil';
   function LpProgramME052(device : ppointer; channel:word; VeryLongWord:PWord): cardinal;  External 'M2070.dll' name 'LpProgramME052';
   function LpSetAnalogChan(device : ppointer; chan:word): cardinal;  External 'M2070.dll' name 'LpSetAnalogChan';
end.

