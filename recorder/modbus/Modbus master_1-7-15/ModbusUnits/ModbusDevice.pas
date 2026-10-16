unit ModbusDevice;

//Для обмена по com-порту используется LazSerial библиотека.
//Для работы в потоках она должна быть модифицирована
//Необходимо закоментарить строку Synchronize(@CallEvent) и вместо этого просто сделать CallEvent
//иначе данные не будут приниматься.

// //Synchronize(@CallEvent);
//      CallEvent;

interface

uses Forms, Classes, WinSock, SysUtils, Windows, SyncObjs, math, ComCtrls, fgl,
  ExtCtrls, UQueue,
  //TimerThread,
  UCommon, UConnection, UTCPClient, LazSerial,
  ThreadedTimerCallback,
  LazUTF8, ULogger;

const
  LENGADR = 1;
  LENGCMDCODE = 1;

  MAX_COMMAND_LENG = 128; //Максимальная длина команды в байтах
  MAX_COMMANDS = 512; //Максимальное число команд в пуле
  LOG_DIR = 'C:\Mera Files'; //Папка записи логов

type
  TModbusDevice = class;
  TModbusTag = class;
  TRTUPollThread = class;
  TTCPPollThread = class;
  TModbusCommand = class;

  //Для борьбы с фрагментацией памяти сделан специальный класс.
  //Команды не создаются/уничтожаются а беруться из пула, затем в него возвращаются
  TCommandPool = class;

  TCmdType = (ctRead, ctWrite); // Тип команды (чтение или запись)
  TAccessType = (atRead, atWrite, atReadWrite); // Тип доступа (чтение, запись, чтение и запись)
  TBusDataEvent = procedure (Sender: TObject; Device: TModbusDevice; data: TBytes; leng: integer) of object;


  RCommand = record
    Tag: TModbusTag;
    CmdType: TCmdType;
  end;

  TDeviceList = specialize TFPGObjectList<TModbusDevice>;
  TCommandList = specialize TFPGList<TModbusCommand>;

  PCommand = ^RCommand;

  TMemRegion = (mrHolding, mrInput, mrCoils);
  TDataType = (dtBool, dtInt16, dtInt32, dtUInt16, dtUInt32, dtSingle,
    dtDouble);
  TByteOrder = (boGrandByte, boGrandWord, boGrandDoubleWord, boReverse, boNoCorrection); // Варианты перестановки байт (старшим байтом вперед,
                                                              //старшим словом вперед, старшим двойным словом вперед, обратная последовательность, без корректировки)
                                                              //Последовательность байт
  TModbusTags = specialize TFPGList <TModbusTag>;
  TListOfModbusTags = specialize TFPGList <TModbusTags>;
  TCommandQueue = specialize TMyQueue<TModbusCommand>;


  // Тип протокола RTU или TCP
  TProtocolType = (ptRTU, ptTCP);


  { TCommandPool }

  TCommandPool = class
  private
    fPool: TCommandList;
    fPoolSize: Integer;
    function getPoolSize: integer;
  public
    function GetFreeCommand: TModbusCommand;
    property PoolSize: integer read getPoolSize;
    constructor Create(pool_size: integer = MAX_COMMANDS);
    destructor Destroy; override;
  end;

  { TBus }

  TBus = class(TObject)
  private
    fDevices: TDeviceList;
    fType: TProtocolType;
    fName: string;
    fDescr: string;
    fOnMessage: TMessageNotify;
    fDataSent: TBusDataEvent;
    fDataRcv: TBusDataEvent;
    fCS: TCriticalSection;
    fCommandPool: TCommandPool;


    //Некоторые устройства не успевают обрабатывать быстро поступающие команды и требуют задержки между запросами
    fDelay: integer; //Задержка на опрос одного устройства

    fInterchangeFlag: boolean; //Если флаг установлен, то на вкладке "обмен" основного окна будет отображаться обмен по шине
    function GetType: TProtocolType;
    function GetWriteLog: boolean;
    procedure SetType(const Value: TProtocolType);
    function GetActive: boolean;
    procedure SetActive(const Value: boolean); virtual;
    function GetDescription: string;
    function GetName: string;
    procedure SetDescription(const Value: string);
    procedure SetName(const Value: string);
    function GetDevices: TDeviceList;
    procedure SetInterChangeFlag(const Value: boolean);
    function GetInterchangeFlag: boolean;

    function CheckBusHasActiveDevices: boolean;

    procedure DoDataSent(Device: TModbusDevice; data: TBytes; leng: integer);
    procedure DoDataRcv(Device: TModbusDevice; const data: TBytes; leng: integer);
    function GetDelay: integer;
    procedure SetDelay(const Value: integer);
    procedure SetWriteLog(AValue: boolean);
  protected
    fActive: boolean; // Запущен опрос шины
    fWriteLog: boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure WriteTag(tag: TModbusTag); virtual; abstract;
    procedure ForceTag(tag: TModbusTag); virtual; abstract;
    function GetDeviceByAdress(adr: byte): TModbusDevice;
    function GetMaxAdress: integer;
    property ProtocolType: TProtocolType read GetType write SetType;
    property Items: TDeviceList read GetDevices;
    property Active: boolean read GetActive write SetActive;
    property Name: string read GetName write SetName;
    property Description: string read GetDescription write SetDescription;
    property OnMessage: TMessageNotify read fOnMessage write fOnMessage;
    property OnDataSend: TBusDataEvent read fDataSent write fDataSent;
    property OnDataRcv: TBusDataEvent read fDataRcv write fDataRcv;
    property PauseDelay: integer read GetDelay write SetDelay;
    property WriteLogFlag: boolean read GetWriteLog write SetWriteLog;
    property InterchangeFlag: boolean read GetInterchangeFlag write SetInterChangeFlag;
  end;

  TBusRTU = class(TBus)
  private
    fPort: TLazSerial;
    fPollThread: TRTUPollThread;

    procedure SetActive(const Value: boolean); override;
    procedure DoMessage(Sender: TObject; Msg: string);
    procedure PortDataRx(Sender: TObject; device: TModbusDevice; data: TBytes; leng: integer);
    procedure PortDataTx(Sender: TObject; device: TModbusDevice; data: TBytes; leng: integer);
  public
    constructor Create(bus: TBus); overload;
    constructor Create(bus: TBusRTU); overload;
    constructor Create(bus: TBusRTU; node: TTreeNode); overload;
    constructor Create; overload; override;
    destructor Destroy; override;
    procedure WriteTag(tag: TModbusTag); override;
    procedure ForceTag(tag: TModbusTag); override;

    property Port: TLazSerial read fPort;
  end;

  TBusTCP = class(TBus)
  private
    fPort: Integer;
    fPollThread: TTCPPollThread;
    fConnection: TTCPClient;
    fConnected: TNotifyEvent;
    fDisconnected: TNotifyEvent;
    fConnectionFailed: TNotifyEvent;
    fTryReconnect: boolean;

    function GetPort: integer;
    function GetConnection: TTCPClient;
    procedure SetActive(const Value: boolean); override;
    procedure DoMessage(Sender: TObject; Msg: string);
    //procedure DataRx(Sender: TObject; device: TModbusDevice; data: TBytes);
    //procedure DataTx(Sender: TObject; device: TModbusDevice; data: TBytes);
    procedure TCPClientDataRx(Sender: TObject; device: TModbusDevice; data: TBytes; leng: integer);
    procedure TCPClientDataTx(Sender: TObject; device: TModbusDevice; data: TBytes; leng: integer);
    procedure TCPClientConnected(Sender: TObject);
    procedure TCPClientDisconnected(Sender: TObject);
    procedure TCPClientConnectionFailed(Sender: TObject);

    procedure DoConnected;
    procedure DoDisconnected;
    procedure DoConnectionFailed;
  public
    constructor Create(bus: TBus); overload;
    constructor Create(bus: TBusTCP); overload;
    constructor Create(bus: TBusTCP; node: TTreeNode); overload;
    constructor Create; overload; override;
    destructor Destroy; override;
    procedure WriteTag(tag: TModbusTag); override;
    procedure ForceTag(tag: TModbusTag); override;
    property Connection: TTCPClient read GetConnection;
    property OnConnected: TNotifyEvent read fConnected write fConnected;
    property OnDisconnected: TNotifyEvent read fDisconnected write fDisconnected;
    property OnConnectionFailed: TNotifyEvent read fConnectionFailed write fConnectionFailed;
  end;

  { TModbusTag }

  TModbusTag = class(TObject)
  private
    fAddress: Word; // Адрес устройства
    fRegion: TMemRegion; // Область памяти тэга (регистры ввода или хранения)
    fParent: TModbusDevice; // Устройство которому принадлежит тэг
    fDataType: TDataType; // Тип данных тэга
    fByteOrder: TByteOrder; // Различные устройства могут иметь различные варианты порядка байт в значении
    fRawValue: TBytes;   //Сырое значение в виде массива байтов
    fName: AnsiString; // Наименование тэга
    fDescr: AnsiString; // Описание тэга
    fCmdType: TCmdType; //Команда (читать или писать)
    fNameChanged: TNotifyEvent;
    fDescrChanged: TNotifyEvent;
    fValueChanged: TNotifyEvent;
    fCS: TCriticalSection;
    fAccessType: TAccessType; //Тип доступа
    fContiniousWrite: boolean; //Постоянная запись
    fImidiateWrite: boolean; //Немедленная запись по изменению тэга в Recorder-е
    fLastValue: TBytes;
    fAllowGroupWorking: boolean; //Разрешить групповую обработку
    //fWritingFlag: boolean; //Флаг того что идет процесс записи. Не проводить чтение тэга, если флаг выстален

    function CompareByteArrays(A, B: TBytes): boolean;
    function GetAllowGroupWorking: boolean;
    function GetByteOrder: TByteOrder;
    function GetDataType: TDataType;
    function GetModbusDevice: TModbusDevice;
    function GetRawValue: TBytes;
    function GetRegion: TMemRegion;
    procedure SetAllowGroupWorking(AValue: boolean);
    procedure SetByteOrder(const Value: TByteOrder);
    procedure SetDataType(const Value: TDataType);
    procedure SetModbusDevice(const Value: TModbusDevice);
    procedure SetRawValue(const Value: TBytes);
    procedure SetRegion(const Value: TMemRegion);
    function GetAddress: Word;
    procedure SetAddress(const Value: Word);
    function GetName: AnsiString;
    procedure SetName(const Value: AnsiString);
    function GetDescription: AnsiString;
    procedure SetDescription(const Value: AnsiString);
    // Значение тэга в виде массива байт
    procedure DoNameChanged;
    procedure DoValueChanged;
    procedure DoDescrChanged;

    function GetCmdType: TCmdType;
    procedure SetCmdType(const Value: TCmdType);
    function GetAccessType: TAccessType;
    procedure SetAccessType(const Value: TAccessType);
    function GetContiniousWrite: boolean;
    procedure SetContiniousWrite(const Value: boolean);
    function getImidiateWrite: boolean;
    procedure setImidiateWrite(const Value: boolean);
    function GetLastValue: TBytes;

   // function getWritingFlag: boolean;
   // procedure setWritingFlag(const Value: boolean);

  public
    constructor Create(Tag: TModbusTag); overload; virtual;
    constructor Create(Tag: TModbusTag; parent: TModbusDevice; node: TTreeNode); overload;
    constructor Create(Parent: TModbusDevice; Name: AnsiString;
     Region: TMemRegion = mrHolding; Address: Word = 0;
     DataType: TDataType = dtSingle; ByteOrder: TByteOrder = boGrandDoubleWord;
     AllowGroupWorking: boolean = false);  overload; virtual;
    destructor Destroy; override;

    function GetLength: integer; // Функция возвращает длину данных в регистрах
    function GetLengthBytes: integer; // Функция возвращает длину данных в байтах

    // Форматирование сырых данных тэга в заданный вид
    function ValueBool: boolean;
    function ValueInt16: SmallInt;
    function ValueInt32: integer;
    function ValueUInt16: Word;
    function ValueUInt32: Cardinal;
    function ValueSingle: Single;
    function ValueDouble: Double;

    procedure GetFlags(var byte_flag, flag_reg, flag_dword: boolean);
    procedure SetRawValueWithoutEvent(value: TBytes);

    property Name: AnsiString read GetName write SetName;
    property Description: AnsiString read GetDescription write SetDescription;
    property Addres: Word read GetAddress write SetAddress;
    property MemRegion: TMemRegion read GetRegion write SetRegion;
    property Parent: TModbusDevice read GetModbusDevice write SetModbusDevice;
    property ByteOrder: TByteOrder read GetByteOrder write SetByteOrder;
    property RawValue: TBytes read GetRawValue write SetRawValue;
    property LastValue: TBytes read GetLastValue;
    property DataType: TDataType read GetDataType write SetDataType;
    property CmdType: TCmdType read GetCmdType write SetCmdType;
    property ContiniousWrite: boolean read GetContiniousWrite write SetContiniousWrite;
    property ImidiateWrite: boolean read getImidiateWrite write setImidiateWrite;
    //property WritingFlag: boolean read getWritingFlag write setWritingFlag;
    property AccessType: TAccessType read GetAccessType write SetAccessType;
    property OnNameChanged: TNotifyEvent read fNameChanged write fNameChanged;
    property OnDescrChanged: TNotifyEvent read fDescrChanged write fDescrChanged;
    property OnValueChanged: TNotifyEvent read fValueChanged write fValueChanged;
    property AllowGroupWorking: boolean read GetAllowGroupWorking write SetAllowGroupWorking;
  end;

  { TModbusCommand }

  TModbusCommand = class(TObject)
  private
    fTyp: TCmdType;
    fUsed: boolean;
    fActualLength: integer;
    fParent: TModbusDevice;
    //fCommand: TBytes;
    fCommand: array [0 .. MAX_COMMAND_LENG] of byte;
    fLeng: integer;
    fCommandType: TCmdType;
    fTags: TModbusTags;
    fProt: TProtocolType;
    fCS: TCriticalSection;
    function GetCommand: TBytes;
    function GetTags: TModbusTags;
    procedure ReadMultipleHolding;
    procedure ReadMultipleInput;
    procedure WriteMultipleHolding;
    procedure ReadCoils;
    procedure WriteSingleCoil;   //5 (0x05) — запись значения одного флага (Force Single Coil)

    //Следует придумать как использовать эту команду на числах
    procedure WriteMultipleCoils; //15 (0x0F) — запись значений в несколько регистров флагов (Force Multiple Coils)
    function GetTotalLeng(tags: TModbusTags): Word;

    function GetData(tags: TModbusTags): TBytes;
   // function InverseData(input: TBytes; leng: integer;
   //   flag_byte, flag_reg: boolean): TBytes;
    function GetCmdType: TCmdType;
    procedure SetCmdType(const Value: TCmdType);
    procedure WriteSingleHolding;
    function GetModbusDevice: TModbusDevice;
    function GetUsed: boolean;
    procedure SetUsed(Value: boolean);
  public
    constructor Create;
    constructor Create(tgs: TModbusTags;  protocol: TProtocolType; typ: TCmdType = ctRead);
    destructor Destroy; override;
    property ActualLength: integer read fActualLength write fActualLength;
    property Protocol: TProtocolType read fProt write fProt;
    property Command: TBytes read GetCommand;
    property tags: TModbusTags read GetTags;
    property Parent: TModbusDevice read GetModbusDevice;
    property CmdType: TCmdType read GetCmdType write SetCmdType;
    //property Typ: TCmdType read fTyp write fTyp;
    procedure AssignTags(tgs: TModbusTags);
    procedure GenerateCommand;
    property Used: boolean read getUsed write setUsed;
  end;

  TModbusCommands = specialize TFPGList<TModbusCommand>;

  // На основе списка тегов формирует список команд

  { TModbusCommandConstructor }

  TModbusCommandConstructor = class(TObject)
  private
    fModbusTags: TModbusTags;
    fProt: TProtocolType;

    fOutput: TModbusCommands;

    fCommandPool: TCommandPool;
    procedure Injection(var A: TModbusTags; min, max: integer);
    procedure SortByAdr(var unsorted: TListOfModbusTags);
    function SortTagsByMem(unsorted: TModbusTags): TListOfModbusTags;
    function CheckMemRegion(MemRegion: TMemRegion;
      lst: TListOfModbusTags): integer;
    function IsSequenced(tag1, tag2: TModbusTag): boolean;
    function MakeCommands(sortedtags: TListOfModbusTags; typ: TCmdType = ctRead; continiousWrite: boolean = false): TModbusCommands;
  public
    constructor Create(tags: TModbusTags; protocol: TProtocolType);
    function Make_Commands: TModbusCommands;
    function MakeWriteCommands: TModbusCommands;
    function MakeContiniousWriteCommands: TModbusCommands;
    procedure AssignTags(tags: TModbusTags);
    destructor Destroy; override;
  end;

  TModbusDevice = class(TObject)
  private
    fName: string; // Наименование устройства
    fDescription: string; // Описание устройства

    fEnabled: boolean; // Флаг того что устройство включенов в опрос. Используеся в том случае если с устройством
    // потеряна связь и есть необходимость выключить его из опроса чтобы не вызывать задержки
    fAddress: Byte;
    fParent: TBus;
    fTags: TModbusTags;
    fCSTags: TCriticalSection; // Критическая секция для доступа к тэгам устройства из разных потоков
    fCS: TCriticalSection; //Критическая секция доступа к свойствам
    fInterchangeFlag: boolean;
    fBreakOnTimeout: boolean; //Флаг того, что устройство будет отключено от опроса по истечении попыток
    fTries: integer; //Число попыток перезапроса
    fTimerTimeout: integer; //Время ожидания ответа, мс
    fTemporalDisabled: boolean; //Флаг временного отключения по полному таймауту
    fEnabledChanged: TNotifyEvent;
    procedure SetInterChangeFlag(const Value: boolean);
    function GetInterchangeFlag: boolean;
    function GetTags: TModbusTags;
    function GetAddress: Byte;
    procedure SetAddress(const Value: Byte);
    function GetEnabled: boolean;
    procedure SetEnabled(const Value: boolean);
    function GetName: string;
    procedure SetName(const Value: string);
    function GetDescription: string;
    procedure SetDescription(const Value: string);
    function GetParent: TBus;
    procedure SetParent(const Value: TBus);
    function GetBreakOnTimeout: boolean;
    function GetTimerTimeout: integer;
    function GetTries: integer;
    procedure SetBreakOnTimeout(const Value: boolean);
    procedure SetTimerTimeout(const Value: integer);
    procedure SetTries(const Value: integer);
    function GetTemporalDisabled: boolean;
    procedure SetTemporalDisabled(const Value: boolean);
    procedure DoEnabledChanged;
    procedure SetEnbledChanged(const Value: TNotifyEvent);

  public
    constructor Create(Parent: TBus; Address: Byte = 1); overload; virtual;
    constructor Create(device: TModbusDevice); overload; virtual;
    constructor Create(device: TModbusDevice; node: TTreeNode); overload;
    constructor Create(Parent: TBus; device: TModbusDevice); overload; virtual;
    destructor Destroy; override;
    procedure WriteTag(tag: TModbusTag);
    procedure ForceTag(tag: TModbusTag);
    property Name: string read GetName write SetName;
    property Parent: TBus read GetParent write SetParent;
    property Description: string read GetDescription write SetDescription;
    property Address: Byte read GetAddress write SetAddress;
    property tags: TModbusTags read GetTags;
    property InterchangeFlag: boolean read GetInterchangeFlag write SetInterChangeFlag;
    property Enabled: boolean read GetEnabled write SetEnabled;
    property BreakOnTimeout: boolean read GetBreakOnTimeout write SetBreakOnTimeout;
    property Tries: integer read GetTries write SetTries;
    property TimerTimeout: integer read GetTimerTimeout write SetTimerTimeout;
    property TemporalDisabled: boolean read GetTemporalDisabled write SetTemporalDisabled;
    property OnEnbledChanged: TNotifyEvent read fEnabledChanged write SetEnbledChanged;
  end;

  //Общий класс для потоков опроса TPollThreadRTU и TPollThreadTCP

  { TPollThread }

  TPollThread = class(TThread)
    private
    fParent: TBus;
    fWriteLog: boolean;
    fCS: TCriticalSection;
    fFullTimeout: TNotifyEvent;
    fCommandQueue: TCommandQueue;
    fCurrentCommand: TModbusCommand;
    fTimeoutValue: integer; //Таймаут в мс
    fDataRx: TBusDataEvent; //Событие, приняты данные
    fDataTx: TBusDataEvent; //Событие, отправлены данные
    fWaitingResponse: boolean; // Ожидается ответ
    fDequeueOnTimeout: boolean; // Флаг того что при наступлении полного таймаута опрашиваемый канал должен быть удален из очереди
    //fTimeoutTimer: TTimerThread;
    fTimeoutTimer: TThreadedTimer;
    fCurrent_retry: integer; // Текущая попытка перезапроса
    fRetry_cnt: integer; // Максимальное число попыток перезапроса
    fTimeout: boolean;
    fTimeoutFlag: boolean;
    //fResponse: TBytes;
    fResponse: array [0..BUFFER_MAX_LENG] of byte;
    fResponseLeng: Cardinal;
    fSendComplete: boolean;
    fReadComplete: boolean;
    fCommandConstructor: TModbusCommandConstructor;
    fLastAdr: integer; //Адрес последнего устройства, которому посылалась команда
    fDir: string;
    fTagLst: TModbusTags; //Реиспользуемый тэглист. Пока применяется для записи

    function GetResponseLeng: Cardinal;
    procedure ProcessTimeout;
    procedure PollDevice(device: TModbusDevice);
    procedure DataRX(Sender: TObject); virtual; abstract;
    procedure EnterNextState(retry: boolean);
    procedure SendCommand;
    procedure Clean(typ: TCmdType);
    //procedure onTimeoutTimerTick(Sender: TObject);
    procedure onTimeoutTimerTick(Data: Pointer);
    procedure DoFullTimeout;
    function FindTagByAddress(dev_address, tag_address: Byte): TModbusTag;
    function FindDeviceByAddress(dev_address: Byte): TModbusDevice;
    procedure DecodeResponse(const data: TBytes; leng: Cardinal); overload; virtual; abstract;
    procedure DecodeResponse; overload; virtual; abstract;
    function GetParent: TBus;
    procedure DoDataRx(device: TModbusDevice; data: TBytes; leng: Cardinal);
    procedure DoDataTx(device: TModbusDevice; data: TBytes; leng: Cardinal);
    procedure WriteLog(s: string);
    function GetDir: string;
    procedure SetDir(const Value: string);
    function getWriteLog: boolean;
    procedure setWriteLog(const Value: boolean);
    procedure DecodeReadCoils(const data: TBytes);
  protected
    fSync: TCriticalSection; //Секция синхронизации с таймером таймаута
    procedure DropTimeout;
  public
    constructor Create(ParentBus: TBus); virtual;
    destructor Destroy; override;

    procedure WriteTag(tag: TModbusTag); //Поставить тэг в очередь
    procedure ForceTag(tag: TModbusTag); //Записать немедленно

    procedure ProcessReadComplete; virtual; //abstract;
    procedure ProcessSendComplete; virtual;
    property Parent: TBus read GetParent;
    property ResponseLeng: Cardinal read GetResponseLeng; //Актуальная длина ответа
    property OnDataRx: TBusDataEvent read fDataRx write fDataRx;
    property OnDataTx: TBusDataEvent read fDataTx write fDataTx;
    property LogDir: string read GetDir write SetDir;
    property Write_Log: boolean read getWriteLog write setWriteLog;
  end;

  TRTUPollThread = class(TPollThread) //Поток опроса шины Modbus RTU
  private
    procedure Execute; override;
    procedure DataRX(Sender: TObject); override;
    procedure DecodeResponse(const data: TBytes; leng: Cardinal); overload; override;
    procedure DecodeResponse; overload; override;
    //Процедура обработки пришедшего ответа, необходима чтобы организовать выполнение
    // обработки в потоке опроса, а не в потоке чтения
    procedure ProcessReadComplete; override;
    procedure ProcessSendComplete; override;
  public
    constructor Create(ParentBus: TBus); override;
  end;

  { TTCPPollThread }

  TTCPPollThread = class(TPollThread) //Поток опроса шины TCP
  private
    procedure Execute; override;
    procedure DataRX(Sender: TObject); override;
    procedure DecodeResponse(const data: TBytes; leng: Cardinal); overload; override;
    procedure DecodeResponse; overload; override;
    procedure ProcessReadComplete; override;
    procedure ProcessSendComplete; override;
  public
    constructor Create(ParentBus: TBus); override;
  end;

procedure ConvertBus(var bus: TBus; const typ: TProtocolType);

implementation

// Преобразовать шину в заданный тип
procedure ConvertBus(var bus: TBus; const typ: TProtocolType);
var
  buf_bus: TBus;
begin
  if bus.ProtocolType = typ then
    Exit;

  case typ of
    ptRTU:
      buf_bus := TBusRTU.Create(bus);
    ptTCP:
      buf_bus := TBusTCP.Create(bus);
  end;

 // FreeAndNil(bus);
  bus := buf_bus;
end;



// Вычисление контрольной суммы Modbus RTU
function GetCRC(Command: TBytes; leng: integer): Word;
var
  n: Word;
  i, m: Word;
begin
  n := $FFFF;
  for m := 0 to leng - 1 do
  begin
    n := Command[m] xor n;
    for i := 0 to 7 do
    begin
      if (n and $0001) = 1 then
        n := (n shr 1) xor $A001
      else
        n := (n shr 1);
    end;
  end;
  result := n;
end;

function FormatSingle(Value: Single; ByteOrder: TByteOrder): TBytes;
var
  outbuf: TBytes;
begin
  SetLength(outbuf, 4);

  case ByteOrder of
    boGrandByte:
      begin
        outbuf[0] := PByte(PByte(@Value) + 3)^;
        outbuf[1] := PByte(PByte(@Value) + 2)^;
        outbuf[2] := PByte(PByte(@Value) + 1)^;
        outbuf[3] := PByte(@Value)^;
      end;

    boGrandWord:
      begin
        outbuf[0] := PByte(PByte(@Value) + 1)^;
        outbuf[1] := PByte(@Value)^;
        outbuf[2] := PByte(PByte(@Value) + 3)^;
        outbuf[3] := PByte(PByte(@Value) + 2)^;
      end;

    boGrandDoubleWord:
      begin
        outbuf[0] := PByte(PByte(@Value) + 1)^;
        outbuf[1] := PByte(@Value)^;
        outbuf[2] := PByte(PByte(@Value) + 3)^;
        outbuf[3] := PByte(PByte(@Value) + 2)^;
      end;
  end;

  result := outbuf;
end;

// На вход передается указатель на число single с порядком байт ByteOrder
function FormatSingleBack(Value: TBytes; ByteOrder: TByteOrder): Single;
var
  outbuf: TBytes;
  output: Single;
  leng: integer;
begin
  SetLength(outbuf, 4);
  case ByteOrder of

    boGrandByte:
      begin
        outbuf[0] := Value[3];
        outbuf[1] := Value[2];
        outbuf[2] := Value[1];
        outbuf[3] := Value[0];
      end;

    boGrandWord:
      begin
        outbuf[0] := Value[1];
        outbuf[1] := Value[0];
        outbuf[2] := Value[3];
        outbuf[3] := Value[2];
      end;

    boGrandDoubleWord:
      begin
        outbuf[0] := Value[1];
        outbuf[1] := Value[0];
        outbuf[2] := Value[3];
        outbuf[3] := Value[2];
      end;
  end;

  leng := SizeOf(Single);
  move(outbuf[0], output, leng);
  result := output;
end;

{ TModbusTag }

constructor TModbusTag.Create(Parent: TModbusDevice; Name: AnsiString;
  Region: TMemRegion = mrHolding; Address: Word = 0;
  DataType: TDataType = dtSingle; ByteOrder: TByteOrder = boGrandDoubleWord; AllowGroupWorking: boolean = false);
begin
  inherited Create;
  fContiniousWrite := false;
  fCS := TCriticalSection.Create;
  self.fName := Name;
  self.fAllowGroupWorking := AllowGroupWorking;
  self.fAddress := Address;
  self.fRegion := Region;
  self.fParent := Parent;
  self.fDataType := DataType; // Тип данных тэга
  self.fByteOrder := ByteOrder;

  case DataType of
    dtBool: setlength(fRawValue, 2);
    dtDouble: setlength(fRawValue, 8);
    dtSingle: setlength(fRawValue, 4);
    dtUInt16: setlength(fRawValue, 2);
    dtInt16: setlength(fRawValue, 2);
    dtInt32: setlength(fRawValue, 4);
    dtUInt32: setlength(fRawValue, 4);
  end;
  SetLength(fLastValue, length(fRawValue));

  ImidiateWrite := true;
end;

constructor TModbusTag.Create(Tag: TModbusTag);
begin
  //Create(Tag.Parent, Tag.Name, Tag.MemRegion, Tag.Addres, Tag.DataType, Tag.ByteOrder);
  fContiniousWrite := false;
  fCS := TCriticalSection.Create;
  self.AllowGroupWorking := Tag.AllowGroupWorking;
  self.fName := Tag.Name;
  self.fAddress := Tag.Addres;
  self.fRegion := Tag.GetRegion;
  self.fParent := Tag.Parent;
  self.fImidiateWrite := Tag.ImidiateWrite;
  self.fContiniousWrite := Tag.ContiniousWrite;
  self.fDescr := Tag.Description;
  {self.OnValueChanged := Tag.OnValueChanged;
  self.OnNameChanged := Tag.OnNameChanged;
  self.OnDescrChanged := Tag.OnDescrChanged;}
  self.fDataType := Tag.DataType; // Тип данных тэга
  self.fByteOrder := Tag.ByteOrder;
  setlength(fRawValue, 0);

  case DataType of
    dtBool: setlength(fRawValue, 2);
    dtDouble: setlength(fRawValue, 8);
    dtSingle: setlength(fRawValue, 4);
    dtUInt16: setlength(fRawValue, 2);
    dtInt16: setlength(fRawValue, 2);
    dtInt32: setlength(fRawValue, 4);
    dtUInt32: setlength(fRawValue, 4);
  end;

  fRegion := Tag.MemRegion;
  self.RawValue := Tag.RawValue;
  self.AccessType := Tag.AccessType;
  self.ContiniousWrite := Tag.ContiniousWrite;
  Description := Tag.Description;
  ImidiateWrite := Tag.ImidiateWrite;
end;

constructor TModbusTag.Create(Tag: TModbusTag; parent: TModbusDevice; node: TTreeNode);
begin
  fContiniousWrite := false;
  fCS := TCriticalSection.Create;
  self.AllowGroupWorking := Tag.AllowGroupWorking;
  self.fName := node.Text;
  self.fAddress := Tag.Addres;
  self.fRegion := Tag.GetRegion;
  self.fParent := parent; //!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  self.fDataType := Tag.DataType; // Тип данных тэга
  self.fByteOrder := Tag.ByteOrder;
  self.fImidiateWrite := Tag.ImidiateWrite;
  self.fContiniousWrite := Tag.ContiniousWrite;
  self.fDescr := Tag.Description;
  setlength(fRawValue, 0);

  case DataType of
    dtBool: setlength(fRawValue, 2);
    dtDouble: setlength(fRawValue, 8);
    dtSingle: setlength(fRawValue, 4);
    dtUInt16: setlength(fRawValue, 2);
    dtInt16: setlength(fRawValue, 2);
    dtInt32: setlength(fRawValue, 4);
    dtUInt32: setlength(fRawValue, 4);
  end;

  fRegion := Tag.MemRegion;
  self.RawValue := Tag.RawValue;
  self.AccessType := Tag.AccessType;
  self.ContiniousWrite := Tag.ContiniousWrite;
  Description := Tag.Description;
  ImidiateWrite := Tag.ImidiateWrite;
end;

destructor TModbusTag.Destroy;
begin
  FreeAndNil(fCS);
  inherited;
end;

procedure TModbusTag.DoNameChanged;
begin
  if Assigned(fNameChanged) then
    fNameChanged(self);
end;

procedure TModbusTag.DoDescrChanged;
begin
  if Assigned(fDescrChanged) then
    fDescrChanged(self);
end;

procedure TModbusTag.DoValueChanged;
begin
  if Assigned(fValueChanged) then
    fValueChanged(self);
end;

function TModbusTag.GetAccessType: TAccessType;
begin
  fCS.Enter;
  result := fAccessType;
  fCS.Leave;
end;

function TModbusTag.GetAddress: Word;
begin
  fCS.Enter;
  result := fAddress;
  fCS.Leave;
end;

function TModbusTag.GetByteOrder: TByteOrder;
begin
  fCS.Enter;
  result := fByteOrder;
  fCS.Leave;
end;

function TModbusTag.GetAllowGroupWorking: boolean;
begin
  fCS.Enter;
  result := fAllowGroupWorking;
  fCS.Leave;
end;

function TModbusTag.GetCmdType: TCmdType;
begin
  fCS.Enter;
  result := fCmdType;
  fCS.Leave;
end;

function TModbusTag.GetContiniousWrite: boolean;
begin
  fCS.Enter;
  result := fContiniousWrite;
  fCS.Leave;
end;

function TModbusTag.GetDataType: TDataType;
begin
  result := fDataType;
end;

function TModbusTag.GetDescription: AnsiString;
begin
  result := fDescr;
end;

function TModbusTag.GetLastValue: TBytes;
begin
  fCS.Enter;
  result := fLastValue;
  fCS.Leave;
end;

function TModbusTag.GetLength: integer;
begin
  case DataType of
    dtBool:
      result := 1;
    dtInt16:
      result := 1;
    dtInt32:
      result := 2;
    dtUInt16:
      result := 1;
    dtUInt32:
      result := 2;
    dtSingle:
      result := 2;
    dtDouble:
      result := 4;
  end;
end;

function TModbusTag.GetLengthBytes: integer;
begin
  result := GetLength * 2;
end;

function TModbusTag.GetModbusDevice: TModbusDevice;
begin
  fCS.Enter;
  result := fParent;
  fCS.Leave;
end;

function TModbusTag.GetName: AnsiString;
begin
  fCS.Enter;
  result := fName;
  fCS.Leave;
end;

function TModbusTag.GetRawValue: TBytes;
begin
  fCS.Enter;
  result := fRawValue;
  fCS.Leave;
end;

function TModbusTag.GetRegion: TMemRegion;
begin
  fCS.Enter;
  result := fRegion;
  fCS.Leave;
end;

procedure TModbusTag.SetAllowGroupWorking(AValue: boolean);
begin
  fCS.Enter;
  fAllowGroupWorking := AValue;
  fCS.Leave;
end;

{function TModbusTag.getWritingFlag: boolean;
begin
  fCS.Enter;
  result := fWritingFlag;
  fCS.Leave;
end;}

procedure TModbusTag.SetAccessType(const Value: TAccessType);
begin
  fCS.Enter;
  fAccessType := Value;
  fCS.Leave;
end;

procedure TModbusTag.SetAddress(const Value: Word);
begin
  fCS.Enter;
  fAddress := Value;
  fCS.Leave;
end;

procedure TModbusTag.SetByteOrder(const Value: TByteOrder);
begin
  fCS.Enter;
  fByteOrder := Value;
  fCS.Leave;
end;

procedure TModbusTag.SetCmdType(const Value: TCmdType);
begin
  fCS.Enter;
  fCmdType := Value;
  fCS.Leave;
end;

procedure TModbusTag.SetContiniousWrite(const Value: boolean);
begin
  fCS.Enter;
  fContiniousWrite := Value;
  fCS.Leave;
end;

procedure TModbusTag.SetDataType(const Value: TDataType);
begin
  fCS.Enter;
  fDataType := Value;
  fCS.Leave;
end;

procedure TModbusTag.SetDescription(const Value: AnsiString);
var
  different: boolean;
begin
  different := fDescr <> Value;

  fCS.Enter;
  fDescr := Value;
  fCS.Leave;

  if different then DoDescrChanged;
end;

procedure TModbusTag.setImidiateWrite(const Value: boolean);
begin
  fImidiateWrite := Value;
end;

procedure TModbusTag.SetModbusDevice(const Value: TModbusDevice);
begin
  fCS.Enter;
  fParent := Value;
  fCS.Leave;
end;

procedure TModbusTag.SetName(const Value: AnsiString);
var
  different: boolean;
begin
  different := fName <> Value;
  fCS.Enter;
  fName := Value;
  fCS.Leave;

  if different then
    DoNameChanged;
end;


function TModbusTag.CompareByteArrays(A, B: TBytes): boolean;
var
  i: integer;
begin
  result := false; //По умолчанию равны

  if length(A) <> length(B) then
   begin
   result := true;
   Exit;
   end;

  for i := 0 to high(A) do
      begin
      if A[i] <> B[i] then
         begin
         result := true;
         break;
         end;
      end;
end;

procedure TModbusTag.SetRawValue(const Value: TBytes);
var
  Different: boolean;
begin
  fCS.Enter;
  try
  Different := CompareByteArrays(fRawValue, Value);
  //if Different then
     begin
     if length(fRawValue) > 0 then
      //begin
      {//setlength(fLastValue, length(fRawValue));
      move(fRawValue[0], fLastValue[0], length(fRawValue));
      end else
      //setlength(fLastValue, 0);
      //setlength(fRawValue, length(Value));}
      move(Value[0], fRawValue[0], length(fRawValue));
     end;
  finally
  fCS.Leave;
  end;

  //if Different then
    DoValueChanged;
end;

procedure TModbusTag.SetRawValueWithoutEvent(value: TBytes);
begin
  fCS.Enter;
  try
  //setlength(fRawValue, length(Value));
  move(Value[0], fRawValue[0], length(fRawValue));
  finally
  fCS.Leave;
  end;
end;

procedure TModbusTag.SetRegion(const Value: TMemRegion);
begin
  fCS.Enter;
  fRegion := Value;
  fCS.Leave;
end;

{procedure TModbusTag.setWritingFlag(const Value: boolean);
begin
  fCS.Enter;
  fWritingFlag := Value;
  fCS.Leave;
end;}

function TModbusTag.ValueBool: boolean;
var
  val: Word;
  data: TBytes;
  s: integer;
  reg_flag, byte_flag, flag_dword: boolean;
begin
  //GetFlags(byte_flag, reg_flag, flag_dword);
  //data := InverseData(RawValue[0], length(RawValue), byte_flag, reg_flag, flag_dword);
  s := SizeOf(val);
  val := 0;
  fCS.Enter;
  move(fRawValue[0], val, s);
  fCS.Leave;
  result := Boolean(val and 1);
end;

function TModbusTag.ValueDouble: Double;
var
  val: Double;
  data: TBytes;
  s: integer;
  reg_flag, byte_flag, flag_dword: boolean;
begin
  val := 0;
  //GetFlags(byte_flag, reg_flag, flag_dword);
  //data := InverseData(RawValue[0], length(RawValue), byte_flag, reg_flag, flag_dword);
  //move(data[0], val, length(data));
  s := SizeOf(val);
  val := 0;
  fCS.Enter;
  move(fRawValue[0], val, s);
  fCS.Leave;
  result := val;
end;

function TModbusTag.ValueInt16: SmallInt;
var
  val: SmallInt;
  data: TBytes;
  s: integer;
  reg_flag, byte_flag, flag_dword: boolean;
begin
  val := 0;
  //GetFlags(byte_flag, reg_flag, flag_dword);
  //data := InverseData(RawValue[0], length(RawValue), byte_flag, reg_flag, flag_dword);
  //move(data[0], val, length(data));
  s := SizeOf(val);
  val := 0;
  fCS.Enter;
  move(fRawValue[0], val, s);
  fCS.Leave;
  result := val;
end;

function TModbusTag.ValueInt32: integer;
var
  val: Integer;
  data: TBytes;
  s: integer;
  reg_flag, byte_flag, flag_dword: boolean;
begin
  val := 0;
  //GetFlags(byte_flag, reg_flag, flag_dword);
  //data := InverseData(RawValue[0], length(RawValue), byte_flag, reg_flag, flag_dword);
  //move(data[0], val, length(data));
  s := SizeOf(val);
  val := 0;
  fCS.Enter;
  move(fRawValue[0], val, s);
  fCS.Leave;
  result := val;
end;

procedure TModbusTag.GetFlags(var byte_flag, flag_reg, flag_dword: boolean);
begin
 case ByteOrder of
    boGrandByte: begin
                 byte_flag := true;
                 flag_reg := false;
                 flag_dword := false;
                 end;

    boGrandWord: begin
                 byte_flag := false;
                 flag_reg := true;
                 flag_dword := false;
                 end;

    boGrandDoubleWord: begin
                       byte_flag := false;
                       flag_reg := true;
                       flag_dword := true;
                       end;

    boReverse: begin
                       byte_flag := true;
                       flag_reg := true;
                       flag_dword := true;
                       end;

    boNoCorrection: begin
                       byte_flag := false;
                       flag_reg := false;
                       flag_dword := false;
                       end;
    end;
end;

function TModbusTag.getImidiateWrite: boolean;
begin
  result := fImidiateWrite;
end;

function TModbusTag.ValueSingle: Single;
var
  val: Single;
  data: TBytes;
  reg_flag, byte_flag, flag_dword: boolean;
  s: integer;
begin
{if Length(RawValue) < 4 then
  begin
    result := 0;
    exit;
  end; }

  //val := FormatSingleBack(RawValue, ByteOrder);

  //GetFlags(byte_flag, reg_flag, flag_dword);
  //data := InverseData(RawValue[0], length(RawValue), byte_flag, reg_flag, flag_dword);
  s := SizeOf(val);
  val := 0;
  fCS.Enter;
  move(fRawValue[0], val, s);
  fCS.Leave;
  result := val;
end;

function TModbusTag.ValueUInt16: Word;
var
  val: Word;
  data: TBytes;
  s: integer;
  reg_flag, byte_flag, flag_dword: boolean;
begin
  //GetFlags(byte_flag, reg_flag, flag_dword);
  //if length(RawValue) > 0 then
  //   data := InverseData(RawValue[0], length(RawValue), byte_flag, reg_flag, flag_dword);
  //if length(data) > 0 then
  s := SizeOf(val);
  val := 0;
  fCS.Enter;
  move(fRawValue[0], val, s);
  fCS.Leave;
  result := val;
end;

function TModbusTag.ValueUInt32: Cardinal;
var
  val: Cardinal;
  data: TBytes;
  s: integer;
  reg_flag, byte_flag, flag_dword: boolean;
begin
  //GetFlags(byte_flag, reg_flag, flag_dword);
  //data := InverseData(RawValue[0], length(RawValue), byte_flag, reg_flag, flag_dword);
  s := SizeOf(val);
  val := 0;
  fCS.Enter;
  move(fRawValue[0], val, s);
  fCS.Leave;
  result := val;
end;

{ TBus }

function TBus.CheckBusHasActiveDevices: boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to fDevices.Count - 1 do
    begin
      if fDevices.Items[i].Enabled then
        begin
          result := true;
          break;
        end;
    end;
end;

constructor TBus.Create;
begin
  inherited Create;
  fCS := TCriticalSection.Create;
  fInterchangeFlag := true;
  fDevices := TDeviceList.Create;
  fDelay := 50;
end;

destructor TBus.Destroy;
begin
  FreeAndNil(fDevices);
  FreeAndNil(fCS);
  inherited;
end;

procedure TBus.DoDataRcv(Device: TModbusDevice; const data: TBytes; leng: integer);
begin
  if Assigned(fDataRcv) then
    begin
    fDataRcv(self, Device, data, leng);
    end;
end;

procedure TBus.DoDataSent(Device: TModbusDevice; data: TBytes; leng: integer);
begin
 if Assigned(fDataSent) then
    begin
    fDataSent(self, Device, data, leng);
    end;
end;

function TBus.GetActive: boolean;
begin
  result := fActive;
end;

function TBus.GetDescription: string;
begin
  result := fDescr;
end;

function TBus.GetDeviceByAdress(adr: byte): TModbusDevice;
var
  i: integer;
begin
  for i := 0 to fDevices.Count - 1 do
    begin
      if fDevices.Items[i].Address = adr then
        begin
          Result := fDevices.Items[i];
          break;
        end;
    end;
end;

function TBus.GetDevices: TDeviceList;
begin
  result := fDevices;
end;

function TBus.GetName: string;
begin
  result := fName;
end;

function TBus.GetType: TProtocolType;
begin
  result := fType;
end;

function TBus.GetWriteLog: boolean;
begin
  result := fWriteLog;
end;

procedure TBus.SetActive(const Value: boolean);
begin
  fActive := Value;
end;

procedure TBus.SetDescription(const Value: string);
begin
  fDescr := Value;
end;

procedure TBus.SetName(const Value: string);
begin
  fName := Value;
end;

procedure TBus.SetType(const Value: TProtocolType);
begin
  fType := Value;
end;

procedure TBus.SetInterChangeFlag(const Value: boolean);
begin
  fInterchangeFlag := Value;
end;

function TBus.GetInterchangeFlag: boolean;
begin
  result := fInterchangeFlag;
end;

function TBus.GetMaxAdress: integer;
var
  i: integer;
  max: integer;
begin
  max := 0;

  for i := 0 to Items.Count - 1 do
    begin
      if Items.Items[i].Address > max then
         max := Items.Items[i].Address;
    end;
  result := max;
end;

function TBus.GetDelay: integer;
begin
  result := fDelay;
end;

procedure TBus.SetDelay(const Value: integer);
begin
  fCS.Enter;
  fDelay := Value;
  fCS.Leave;
end;

procedure TBus.SetWriteLog(AValue: boolean);
begin
 if fWriteLog <> AValue then
  fWriteLog := AValue;
end;

{ TModbusDevice }

constructor TModbusDevice.Create(Parent: TBus; Address: Byte);
begin
  fInterchangeFlag := true;
  fEnabled := true;
  fParent := Parent;
  fAddress := Address;
  fTags := TModbusTags.Create;
  fCSTags := TCriticalSection.Create;
  fCS := TCriticalSection.Create;
  fTimerTimeout := 500;
  fTries := 3;
  fBreakOnTimeout := false;

end;

constructor TModbusDevice.Create(device: TModbusDevice);
var
  i: integer;
begin
  fInterchangeFlag := true;
  //Create(device.Parent, device.Address);
  fInterchangeFlag := true;
  fEnabled := device.Enabled;
  fTimerTimeout := device.TimerTimeout;
  fTries := device.Tries;
  fBreakOnTimeout := device.BreakOnTimeout;
  fParent := device.Parent;
  fAddress := device.Address;
  fTags := TModbusTags.Create;
  fCSTags := TCriticalSection.Create;
  fCS := TCriticalSection.Create;


  Name := device.Name;
  Description := device.Description;

  // Копируем тэги из переданного на вход устройства с помощью копирующего конструктора
  for i := 0 to device.tags.Count - 1 do
  begin
    self.tags.Add(TModbusTag.Create(device.tags[i]));
    self.tags.Last.OnValueChanged := device.tags[i].OnValueChanged;
  end;
end;

constructor TModbusDevice.Create(device: TModbusDevice; node: TTreeNode);
var
  i: integer;
  child: TTreeNode;
begin
  fInterchangeFlag := true;
  fEnabled := device.Enabled;
  fTimerTimeout := device.TimerTimeout;
  fTries := device.Tries;
  fBreakOnTimeout := device.BreakOnTimeout;
  fParent := device.Parent;
  fAddress := device.Address;
  fTags := TModbusTags.Create;
  fCSTags := TCriticalSection.Create;
  fCS := TCriticalSection.Create;


  self.Name := node.Text;
  Description := device.Description;

  // Копируем тэги из переданного на вход устройства с помощью копирующего конструктора
  child := node.getFirstChild;
  for i := 0 to device.tags.Count - 1 do
  begin
    if not Assigned(child) then break;

    self.tags.Add(TModbusTag.Create(device.tags[i], self, child));
    self.tags.Last.OnValueChanged := device.tags[i].OnValueChanged;
    child := node.getNextChild(child);
  end;
end;

constructor TModbusDevice.Create(Parent: TBus; device: TModbusDevice);
var
  i: integer;
begin
  fInterchangeFlag := true;
  //Create(Parent, device.Address);
  fInterchangeFlag := true;
  fEnabled := true;
  fParent := Parent;
  fAddress := device.Address;
  fTags := TModbusTags.Create;
  fCSTags := TCriticalSection.Create;
  fCS := TCriticalSection.Create;
  fTimerTimeout := 500;
  fTries := 3;
  fBreakOnTimeout := false;


  Name := device.Name;
  Description := device.Description;

  // Копируем тэги из переданного на вход устройства с помощью копирующего конструктора
  for i := 0 to device.tags.Count - 1 do
  begin
    fCSTags.Enter;
    try
    self.tags.Add(TModbusTag.Create(device.tags[i]));
    self.tags.Last.OnValueChanged := device.tags[i].OnValueChanged;
    finally
    fCSTags.Leave;
    end;
  end;
end;

destructor TModbusDevice.Destroy;
var
  i: integer;
begin
  for i := 0 to fTags.Count - 1 do
    fTags[i].Free;

  FreeAndNil(fTags);
  FreeAndNil(fCSTags);
  FreeAndNil(fCS);
  inherited;
end;

procedure TModbusDevice.DoEnabledChanged;
begin
  if Assigned(fEnabledChanged) then
    fEnabledChanged(Self);
end;

procedure TModbusDevice.SetInterChangeFlag(const Value: boolean);
begin
  fInterchangeFlag := Value;
end;

function TModbusDevice.GetInterchangeFlag: boolean;
begin
  result := fInterchangeFlag;
end;

procedure TModbusDevice.ForceTag(tag: TModbusTag);
begin
  fParent.ForceTag(tag);
end;

function TModbusDevice.GetAddress: Byte;
begin
  result := fAddress;
end;

function TModbusDevice.GetBreakOnTimeout: boolean;
begin
  result := fBreakOnTimeout;
end;

function TModbusDevice.GetDescription: string;
begin
  result := fDescription;
end;

function TModbusDevice.GetEnabled: boolean;
begin
  result := fEnabled;
end;

function TModbusDevice.GetName: string;
begin
  result := fName;
end;

function TModbusDevice.GetParent: TBus;
begin
  result := fParent;
end;

function TModbusDevice.GetTags: TModbusTags;
begin
  fCSTags.Enter;
  try
  result := fTags;
  finally
  fCSTags.Leave;
  end;
end;

function TModbusDevice.GetTemporalDisabled: boolean;
begin
  fCS.Enter;
  try
  result := fTemporalDisabled;
  finally
  fCS.Leave;
  end;
end;

function TModbusDevice.GetTimerTimeout: integer;
begin
  fCS.Enter;
  try
  result := fTimerTimeout;
  finally
  fCS.Leave;
  end;
end;

function TModbusDevice.GetTries: integer;
begin
  fCS.Enter;
  try
  result := fTries;
  finally
  fCS.Leave;
  end;
end;


procedure TModbusDevice.SetAddress(const Value: Byte);
begin
  fCS.Enter;
  try
  fAddress := Value;
  finally
  fCS.Leave;
  end;
end;

procedure TModbusDevice.SetBreakOnTimeout(const Value: boolean);
begin
  fCS.Enter;
  try
  fBreakOnTimeout := Value;
  finally
  fCS.Leave;
  end;
end;

procedure TModbusDevice.SetDescription(const Value: string);
begin
  fDescription := Value;
end;

procedure TModbusDevice.SetEnabled(const Value: boolean);
begin
  if Value <> fEnabled then
    begin
    fEnabled := Value;
    DoEnabledChanged;
    end;
end;

procedure TModbusDevice.SetEnbledChanged(const Value: TNotifyEvent);
begin
  fEnabledChanged := Value;
end;

procedure TModbusDevice.SetName(const Value: string);
begin
  fName := Value;
end;

procedure TModbusDevice.SetParent(const Value: TBus);
begin
  fParent := Value;
end;

procedure TModbusDevice.SetTemporalDisabled(const Value: boolean);
begin
  fCS.Enter;
  try
  fTemporalDisabled := Value;
  finally
  fCS.Leave;
  end;
end;

procedure TModbusDevice.SetTimerTimeout(const Value: integer);
begin
  fCS.Enter;
  try
  fTimerTimeout := Value;
  finally
  fCS.Leave;
  end;
end;

procedure TModbusDevice.SetTries(const Value: integer);
begin
  fCS.Enter;
  try
  fTries := Value;
  finally
  fCS.Leave;
  end;
end;

procedure TModbusDevice.WriteTag(tag: TModbusTag);
begin
  //tag.WritingFlag := true;
  fCS.Enter;
  //t := TModbusTag.Create(tag);
  fParent.WriteTag(tag);
  //fParent.WriteTag(t);
  fCS.Leave;
end;

{ TBusRTU }

constructor TBusRTU.Create;
begin
  inherited;

  fType := ptRTU;
  fPort := TLazSerial.Create(nil);
  fPort.BaudRate := br_19200;
  fPort.DataBits := db8bits;
  fPort.StopBits := sbOne;
  //fPort.FlowControl := fcNone;  //Под вопросом
  fPort.Parity := pNone;
  fPort.Device := 'COM1';
end;

// Конструктор шины RTU на основе обобщенной шины (копируется список устройств)
constructor TBusRTU.Create(bus: TBus);
var
  i: integer;
begin
  inherited Create;

  fType := ptRTU;

  fPort := TLazSerial.Create(nil);
  fPort.BaudRate := br_19200;
  fPort.DataBits := db8bits;
  fPort.StopBits := sbOne;
  //fPort.FlowControl := fcNone;
  fPort.Parity := pNone;
  fPort.Device := 'COM1';

  Name := bus.Name;
  Description := bus.Description;

  for i := 0 to bus.Items.Count - 1 do
  begin
    Items.Add(TModbusDevice.Create(self, bus.Items[i]));
  end;
end;

constructor TBusRTU.Create(bus: TBusRTU);
var
  i: integer;
begin
  inherited Create;

  fType := ptRTU;

  fPort := TLazSerial.Create(nil);
  fPort.BaudRate := br_19200;
  fPort.DataBits := db8bits;
  fPort.StopBits := sbOne;
  //fPort.FlowControl := fcNone;
  fPort.Parity := pNone;
  fPort.Device := 'COM1';

  Name := bus.Name;
  Description := bus.Description;

  for i := 0 to bus.Items.Count - 1 do
  begin
    Items.Add(TModbusDevice.Create(self, bus.Items[i]));
  end;

  Port.Device := bus.Port.Device;
end;

//Конструктор на основе образца и узла дерева TTreeNode отвечающего за отображение шины
//Нужен в случае копирования узла дерева для обеспечения уникальности имен узлов (при копировании узла она обеспечивается)
constructor TBusRTU.Create(bus: TBusRTU; node: TTreeNode);
var
  i: integer;
  child: TTreeNode;
begin
  inherited Create;

  fType := ptRTU;

  fPort := TLazSerial.Create(nil);
  fPort.BaudRate := br_19200;
  fPort.DataBits := db8bits;
  fPort.StopBits := sbOne;
  fPort.Parity := pNone;
  fPort.Device := 'COM1';
  Name := node.Text; //bus.Name;
  Description := bus.Description;

  OnMessage := bus.OnMessage;
  OnDataSend := bus.OnDataSend;
  OnDataRcv := bus.OnDataRcv;

  child := node.getFirstChild;

  for i := 0 to bus.Items.Count - 1 do
  begin
    if not Assigned(child) then break;
    Items.Add(TModbusDevice.Create(bus.Items[i], child));
    child := node.GetNextChild(child);
  end;

  Port.Device := bus.Port.Device;
end;


destructor TBusRTU.Destroy;
begin
  FreeAndNil(fPort);

  inherited;
end;

procedure TBusRTU.PortDataRx(Sender: TObject; device: TModbusDevice; data: TBytes; leng: integer);
begin
  DoDataRcv(device, data, leng);
end;

procedure TBusRTU.PortDataTx(Sender: TObject; device: TModbusDevice; data: TBytes;  leng: integer);
begin
  DoDataSent(device, data, leng);
end;

procedure TBusRTU.DoMessage(Sender: TObject; Msg: string);
begin
  if Assigned(fOnMessage) then
    fOnMessage(self, Msg);
end;

procedure TBusRTU.ForceTag(tag: TModbusTag);
begin
  if not Active then Exit;

  fPollThread.ForceTag(tag);
end;

procedure TBusRTU.SetActive(const Value: boolean);
var
 i: integer;
 msg_text: string;
begin
  if fActive = Value then exit;

  //inherited;

  if Value then
  begin
    try
    if not CheckBusHasActiveDevices then
      begin
      fActive := false;
      Exit;
      end;

     // fPort.Open;
      //fPort.SynSer.EnableRTSToggle(true);
      fPort.Active := true;
      msg_text := WinCPToUTF8(format('Окрыт порт %s', [self.Port.Device]));
      DoMessage(self, msg_text);
      if WriteLogFlag then
         TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format(' Port %s opened!', [self.Port.Device]));
    except
      msg_text := WinCPToUTF8(format('Ошибка открытия порта %s!', [self.Port.Device]));
      DoMessage(self, msg_text);
      if WriteLogFlag then
        TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format(' Error open port %s!', [self.Port.Device]));
      Exit;
    end;

    for i := 0 to fDevices.Count - 1 do
        fDevices.Items[i].TemporalDisabled := false;

    if fPort.Active then
    begin
      fPollThread := TRTUPollThread.Create(self);
      fPollThread.Write_Log := WriteLogFlag;
      fPollThread.LogDir := LOG_DIR;
      fPollThread.OnDataRx := @PortDataRx;
      fPollThread.OnDataTx := @PortDataTx;
      fPollThread.Start;
    end;
  end
  else
  begin
    if Assigned(fPollThread) then
    begin
      fPollThread.Terminate;
      fPollThread.WaitFor;
      FreeAndNil(fPollThread);
    end;
   // fPort.Close;
    fPort.Active := false;
    DoMessage(self, WinCPToUTF8(format('Закрыт порт %s', [self.Port.Device])));
    if WriteLogFlag then
         TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format(' Port %s closed!', [self.Port.Device]));
  end;

   fActive := Value;
end;

procedure TBusRTU.WriteTag(tag: TModbusTag);
begin
  if not Active then Exit;

  fPollThread.WriteTag(tag);
end;

{ TRTUPollThread }

procedure TPollThread.DecodeReadCoils(const data: TBytes);
var
  n, i: integer;
  bytecount: integer;
  tag: TModbusTag;
  raw_value: TBytes;
  val: byte;

  offs: word; //смещение в зависимости от типа протокола
begin
 if self.Parent.ProtocolType = ptRTU then
    offs := 0 else
    offs := 6;

 bytecount := data[2 + offs];
 n := 0;
 for i := 0 to fCurrentCommand.tags.Count - 1 do
    begin
      Tag := fCurrentCommand.tags.Items[i];
      if Assigned(Tag) and (Tag.AccessType <> atWrite) then
        begin
          setlength(raw_value, tag.GetLengthBytes);
          n := i div 8;

          val := (data[n] shr (i - n * 8)) and 1;
          if (val > 0) then
             raw_value[length(raw_value) - 1] := 1 else
             raw_value[length(raw_value) - 1] := 0;

             tag.RawValue := raw_value;
        end;
    end;
end;

procedure TPollThread.DropTimeout;
begin
  fCS.Enter;
  fTimeoutTimer.Active := false;
  fTimeoutFlag := false;
  fTimeout := false;
  fCS.Leave;
end;

procedure TRTUPollThread.DecodeResponse(const data: TBytes; leng: Cardinal);
var
  device: TModbusDevice;
  Tag: TModbusTag;
  tag_adr: Word;
  raw_value: TBytes;
  i: integer;
  offset: integer;
  flag_byte, flag_word, flag_dword: boolean;
begin
offset := 0;

WriteLog('Bus: ' + Parent.Name + ' DecodeResponse: fResponse = ' + DataToStr(fResponse, fResponseLeng) + ' fWaitingResponse = ' + BoolToStr(fWaitingResponse, true));

if (leng > 0) then
  device := FindDeviceByAddress(data[0]);
if Assigned(device) then
   DoDataRx(device, data, leng) else Exit;

if (length(data) >= 4) then
  begin
  try
  if not ((data[1] = $03) or (data[1] = $04) or (data[1] = $01)) then exit; //Если команда не является запросом на чтение выйти
    for i := 0 to fCurrentCommand.tags.Count - 1 do
    begin
      Tag := fCurrentCommand.tags.Items[i];
      if ((data[1] = $03) or (data[1] = $04)) then
        begin
        if Assigned(Tag) and (Tag.AccessType <> atWrite) then
            begin
              SetLength(raw_value, Tag.GetLengthBytes);
              if length(data) > 3 + offset then
                 move(data[3 + offset], raw_value[0], length(raw_value));

              tag.GetFlags(flag_byte, flag_word, flag_dword);
              raw_value := InverseData(raw_value[0], length(raw_value), flag_byte, flag_word, flag_dword);
              Tag.RawValue := raw_value;
              offset := offset + Tag.GetLengthBytes;
            end;
        end else
      if (data[1] = $01) then
        begin
          DecodeReadCoils(data);
        end;
    end;

  except
  on e: exception do
     WriteLog('Bus: ' + Parent.Name + ' DecodeResponse error msg = ' + e.Message);
  end;

  end;
end;

procedure TRTUPollThread.DecodeResponse;
var
  device: TModbusDevice;
  Tag: TModbusTag;
  tag_adr: Word;
  raw_value: TBytes;
  i: integer;
  offset: integer;
  flag_byte, flag_word, flag_dword: boolean;
begin
offset := 0;

WriteLog('Bus: ' + Parent.Name + ' DecodeResponse no params: fResponse = ' + DataToStr(fResponse, fResponseLeng) + ' fWaitingResponse = ' + BoolToStr(fWaitingResponse, true));

if (length(fResponse) > 0) then
  device := FindDeviceByAddress(fResponse[0]);

if Assigned(device) then
   DoDataRx(device, fResponse, fResponseLeng);

if (length(fResponse) > 2) then
  begin
  try
  if not ((fResponse[1] = $03) or (fResponse[1] = $04) or (fResponse[1] = $01)) or ((fResponse[2] <> length(fResponse) - 5)) then exit; //Если команда не является запросом на чтение выйти


    for i := 0 to fCurrentCommand.tags.Count - 1 do
    begin
      Tag := fCurrentCommand.tags.Items[i];
      Tag := fCurrentCommand.tags.Items[i];
      if ((fResponse[1] = $03) or (fResponse[1] = $04)) then
        begin
          if Assigned(Tag) and (Tag.AccessType <> atWrite) then
          begin
            SetLength(raw_value, Tag.GetLengthBytes);
            move(fResponse[3 + offset], raw_value[0], length(raw_value));

            tag.GetFlags(flag_byte, flag_word, flag_dword);
            raw_value := InverseData(raw_value[0], length(raw_value), flag_byte, flag_word, flag_dword);
            Tag.RawValue := raw_value;

            offset := offset + Tag.GetLengthBytes;
          end;
        end else
       if (fResponse[1] = $01) then
        begin
          DecodeReadCoils(fResponse);
        end;
    end;

  except
  on e: exception do
     WriteLog('Bus: ' + Parent.Name + ' DecodeResponse error msg = ' + e.Message);
  end;

  end;

end;


procedure TRTUPollThread.ProcessReadComplete;
begin
  inherited;
  fCS.Enter;
  DecodeResponse(fResponse, fResponseLeng);
  //FreeAndNil(fCurrentCommand);

  fWaitingResponse := false;

  fReadComplete := false;
  fCS.Leave;
end;

procedure TRTUPollThread.ProcessSendComplete;
begin
  inherited;
 // fTimeoutTimer.Active := false;


  fCS.Enter;
  fSendComplete := false;
  fCS.Leave;
end;


constructor TRTUPollThread.Create(ParentBus: TBus);
begin
  inherited;
  fParent := ParentBus;
  fCommandConstructor := TModbusCommandConstructor.Create(nil, ptRTU);
  //Write_Log := true;
  WriteLog('Bus: ' + Parent.Name + ' RTU poll thread Created');
end;

procedure TRTUPollThread.DataRX(Sender: TObject);
begin
WriteLog('DataRx: fWaitingResponse = ' + BoolToStr(fWaitingResponse, true));
if not fWaitingResponse or Terminated then Exit;

  // Обработка полученных данных
  fCS.Enter;
  //Событие может сработать пока не все сообщение получено, ждем прихода буфера полностью
  sleep(5);

  //setlength(fResponse, TBusRTU(fParent).Port.SynSer.WaitingData);
  fResponseLeng := TBusRTU(fParent).Port.SynSer.WaitingData;
  TBusRTU(fParent).Port.SynSer.RecvBuffer(@fResponse[0], fResponseLeng);
  TBusRTU(fParent).Port.SynSer.Flush;
  WriteLog('Bus: ' + Parent.Name + ' DataRx: fResponse = ' + DataToStr(fResponse, fResponseLeng));
  //fTimeoutTimer.Active := false;
  fReadComplete := true;
  fCS.Leave;
end;

procedure TRTUPollThread.Execute;
var
  b: byte;
begin
  while not Terminated do
  begin
    if fReadComplete then
      begin
        fSync.Enter;
        ProcessReadComplete;
        fSync.Leave;
        continue;
      end;

    if fTimeoutFlag then
      begin
        fSync.Enter;
        ProcessTimeout;
        fSync.Leave;
        continue;
      end;

    if fSendComplete then
      begin
        fSync.Enter;
        ProcessSendComplete;
        fSync.Leave;
        continue;
      end;

    if (not fWaitingResponse and not fReadComplete and not fSendComplete and not fTimeoutFlag and not fTimeoutTimer.Active) then
    begin
      if not Terminated then
          begin
          fSync.Enter;
          if Assigned(fCurrentCommand) and (length(fCurrentCommand.Command) > 1) then
             b := fCurrentCommand.Command[1];
          EnterNextState(fTimeout);
          fSync.Leave;
          end;
    end else
    sleep(1);
  end;

end;

{ TModbusCommand }

//Пустой конструктор для пула команд
//требуется вручную добавлять тэги, протокол и тип команды
constructor TModbusCommand.Create;
var
  i: integer;
begin
  fCS := TCriticalSection.Create;
  fTags := TModbusTags.Create;
end;

constructor TModbusCommand.Create(tgs: TModbusTags; protocol: TProtocolType; typ: TCmdType = ctRead);
var
  i: integer;
begin
  fProt := protocol;
  fCS := TCriticalSection.Create;
  fTags := TModbusTags.Create;
  for i := 0 to tgs.Count - 1 do
  begin
    fCS.Enter;
    try
    //fTags.Add(TModbusTag.Create(tgs.Items[i]));
    //fTags.Last.OnValueChanged := tgs.Items[i].OnValueChanged;
    fTags.Add(tgs.Items[i]);
    fTags.Last.OnValueChanged := tgs.Items[i].OnValueChanged;
    finally
    fCS.Leave;
    end;
  end;

  fCS.Enter;
  try
  fParent := fTags.Items[0].fParent;
  finally
  fCS.Leave;
  end;

  self.CmdType := typ;
  GenerateCommand;
end;

//Специальный деструктор
//Не уничтожаем тэги так как они при работе с пулом работают по ссылкам
{destructor TModbusCommand.PoolDestroy;
begin
  FreeAndNil(fCS);
  FreeAndNil(fTags);
  setlength(fCommand, 0);
  inherited;
end;}


destructor TModbusCommand.Destroy;
//var
//  i: integer;
begin
//Тэги не удаляем, так как после перехода к пулам работаем по ссылкам.
//Воизбежание сегментации памяти
  {for i := 0 to fTags.Count - 1 do
     begin
       fTags.Items[i].Free;
     end; }
  FreeAndNil(fCS);
  FreeAndNil(fTags);
  //setlength(fCommand, 0);
  inherited;
end;

procedure TModbusCommand.AssignTags(tgs: TModbusTags);
var
  i: integer;
begin
  fTags.Clear;

  for i := 0 to tgs.Count - 1 do
  begin
    fCS.Enter;
    try
    //fTags.Add(TModbusTag.Create(tgs.Items[i]));
    //fTags.Last.OnValueChanged := tgs.Items[i].OnValueChanged;
    fTags.Add(tgs.Items[i]);
    fTags.Last.OnValueChanged := tgs.Items[i].OnValueChanged;
    finally
    fCS.Leave;
    end;
  end;

  if fTags.Count > 0 then
     begin
       fCS.Enter;
       try
       fParent := fTags.Items[0].fParent;
       finally
       fCS.Leave;
       end;
     end;
end;

procedure TModbusCommand.GenerateCommand;
var
  leng: integer;
begin
  // Создать команду на основе входящих тегов.
  case Tags.Items[0].MemRegion of
    mrInput:
      if CmdType = ctRead then ReadMultipleInput;

    mrHolding:
      if CmdType = ctRead then ReadMultipleHolding else
         begin
         if ((Tags.Items[0].fDataType = dtUInt16) or (Tags.Items[0].fDataType = dtInt16)) and (Tags.Count < 2) then
          WriteSingleHolding
          else
          WriteMultipleHolding;
         end;
    mrCoils:
    if CmdType = ctRead then
      ReadCoils else
      if (Tags.Count < 2) then
         WriteSingleCoil else
         WriteMultipleCoils;
  end;
end;

// Получить суммарную длину в регистрах
function TModbusCommand.GetTotalLeng(tags: TModbusTags): Word;
var
  i: integer;
begin
  result := 0;
  for i := 0 to tags.Count - 1 do
  begin
    result := result + tags.Items[i].GetLength;
  end;
end;

procedure TModbusCommand.ReadMultipleHolding;
var
  regcnt: Word; // число запрашиваемых регистров
  adr: Word;
  Crc: Word;
  leng: Word;
  totalleng: Word;
begin
  regcnt := GetTotalLeng(Tags);
  adr := Tags.Items[0].Addres;
  fCS.Enter;
  if fProt = ptRTU then
  begin
  //SetLength(fCommand, 6);
  fActualLength := 6;
  fCommand[0] := Tags.Items[0].Parent.Address;
  fCommand[1] := $03; // Multiple holding
  {fCommand[2] := adr shr 8; // Старший байт адреса
  fCommand[3] := adr; // Младший байт адреса
  fCommand[4] := regcnt shr 8; // Старший байт числа регистров
  fCommand[5] := regcnt; // Младший байт числа регистров}

  fCommand[2] := Hi(adr); // Старший байт адреса
  fCommand[3] := Lo(adr); // Младший байт адреса
  fCommand[4] := Hi(regcnt); // Старший байт числа регистров
  fCommand[5] := Lo(regcnt); // Младший байт числа регистров

  Crc := GetCRC(fCommand, fActualLength);

  //SetLength(fCommand, 8);
  fActualLength := 8;
  move(Crc, fCommand[6], 2);
  end else
  if fProt = ptTCP then
  begin
  //SetLength(fCommand, 12);
  fActualLength := 12;
  fCommand[0] := 0;
  fCommand[1] := 0;
  fCommand[2] := 0;
  fCommand[3] := 0;

  leng := 6;
  fCommand[4] := leng shr 8;
  fCommand[5] := leng;

  //move(leng, fCommand[4], 2);

  fCommand[6] := Tags.Items[0].Parent.Address;
  fCommand[7] := $03; // Multiple holding
  {fCommand[8] := adr shr 8; // Старший байт адреса
  fCommand[9] := adr; // Младший байт адреса
  fCommand[10] := regcnt shr 8; // Старший байт числа регистров
  fCommand[11] := regcnt; // Младший байт числа регистров }
  fCommand[8] := Hi(adr); // Старший байт адреса
  fCommand[9] := Lo(adr); // Младший байт адреса
  fCommand[10] := Hi(regcnt); // Старший байт числа регистров
  fCommand[11] := Lo(regcnt); // Младший байт числа регистров

  end;
  fCS.Leave;
end;

procedure TModbusCommand.ReadMultipleInput;
var
  regcnt: Word; // число запрашиваемых регистров
  adr: Word;
  Crc: Word;
  leng: Word;
begin
  regcnt := GetTotalLeng(fTags);

  if Tags.Count > 0 then
     adr := Tags.Items[0].Addres;

  fCS.Enter;
  if fProt = ptRTU then
  begin
  //SetLength(fCommand, 6);
  fActualLength := 6;
  fCommand[0] := Tags.Items[0].Parent.Address;
  fCommand[1] := $04; // Multiple input
  {fCommand[2] := adr shr 8; // Старший байт адреса
  fCommand[3] := adr; // Младший байт адреса
  fCommand[4] := regcnt shr 8; // Старший байт числа регистров
  fCommand[5] := regcnt; // Младший байт числа регистров}
  fCommand[2] := Hi(adr); // Старший байт адреса
  fCommand[3] := Lo(adr); // Младший байт адреса
  fCommand[4] := Hi(regcnt); // Старший байт числа регистров
  fCommand[5] := Lo(regcnt); // Младший байт числа регистров

  Crc := GetCRC(fCommand, fActualLength);

  //SetLength(fCommand, 8);
  fActualLength := 8;
  move(Crc, fCommand[6], 2);
  end else
  if fProt = ptTCP then
  begin
  //SetLength(fCommand, 12);
  fActualLength := 12;
  fCommand[0] := 0;
  fCommand[1] := 0;
  fCommand[2] := 0;
  fCommand[3] := 0;

  leng := 6;
  fCommand[4] := leng shr 8;
  fCommand[5] := leng;

  fCommand[6] := Tags.Items[0].Parent.Address;
  fCommand[7] := $04; // Multiple input
  {fCommand[8] := adr shr 8; // Старший байт адреса
  fCommand[9] := adr; // Младший байт адреса
  fCommand[10] := regcnt shr 8; // Старший байт числа регистров
  fCommand[11] := regcnt; // Младший байт числа регистров}
  fCommand[8] := Hi(adr); // Старший байт адреса
  fCommand[9] := Lo(adr); // Младший байт адреса
  fCommand[10] := Hi(regcnt); // Старший байт числа регистров
  fCommand[11] := Lo(regcnt); // Младший байт числа регистров
  end;
  fCS.Leave;
end;

procedure TModbusCommand.ReadCoils;
var
  adr: Word;
  Crc: Word;
  leng: Word;
  buf: TBytes;
begin
  adr := Tags.Items[0].Addres;
  fCS.Enter;
  if fProt = ptRTU then
  begin
  //SetLength(fCommand, 6);
  fActualLength := 6;
  fCommand[0] := Tags.Items[0].Parent.Address;
  fCommand[1] := $01; // Force single coil  код команды
  fCommand[2] := Hi(adr); // Старший байт адреса
  fCommand[3] := Lo(adr); // Младший байт адреса
  fCommand[4] := Hi(tags.Count); // Старший байт числа тэгов
  fCommand[5] := Lo(tags.Count); // Младший байт числа тэгов


  Crc := GetCRC(fCommand, fActualLength);
  fActualLength := 8;
  //SetLength(fCommand, 8);
  move(Crc, fCommand[6], 2);
  end else
  if fProt = ptTCP then   //Для ModBus TCP
  begin
  //SetLength(fCommand, 12);
  fActualLength := 12;

  fCommand[0] := 0;
  fCommand[1] := 0;
  fCommand[2] := 0;
  fCommand[3] := 0;

  leng := 6;
  fCommand[4] := leng shr 6;
  fCommand[5] := leng;

  fCommand[6] := Tags.Items[0].Parent.Address;
  fCommand[7] := $05; // Force single coil  код команды
  fCommand[8] := Hi(adr); // Старший байт адреса
  fCommand[9] := Lo(adr); // Младший байт адреса

  if Tags.Items[0].ValueInt16 > 0 then
  fCommand[10] := $FF else
  fCommand[10] := $00;

  fCommand[11] := 0;
  end;
  fCS.Leave;
end;

procedure TModbusCommand.SetCmdType(const Value: TCmdType);
begin
  fCommandType := Value;
end;

// Перестановка байт и регистров для передачи в линию. Параметр flag_byte означает перестановку байт
//Параметр flag_reg означает перестановку регистров
{function TModbusCommand.InverseData(input: TBytes; leng: integer;
  flag_byte: boolean; flag_reg: boolean): TBytes;
var
  output: TBytes;
  i: integer;

  reg_count: integer; //Число регистров
  num_reg: integer; //Индекс текущего регистра

  buf: Byte;
  buf_reg: TBytes;
begin
  SetLength(output, leng);
  move(input[0], output[0], leng);
  SetLength(buf_reg, 2);

  reg_count := leng div 2;
  // меняем местами регистры
  if flag_reg and (reg_count > 1) then
  begin
  num_reg := 1;
  while num_reg < reg_count do
     begin
     move(output[(num_reg - 1) * 2], buf_reg[0], 2);
     move(output[num_reg * 2], output[(num_reg - 1) * 2], 2);
     move(buf_reg[0], output[num_reg * 2], 2);
     inc(num_reg);
     end;
  end;

  // меняем местами байты
  if flag_byte and (leng > 1) then       , 2);
     inc(num_reg);
     end;
  end;

  // меняем местами байты
  if flag_byte and (leng > 1) then
   begin
   num_reg := 0;
   while num_reg < reg_count do
      begin
      buf := output[num_reg * 2];
      output[num_reg * 2] := output[num_reg * 2 + 1];
      output[num_reg * 2 + 1] := buf;

      inc(num_reg);
      end;
   end;
   result := output;
end;   }

function TModbusCommand.GetData(tags: TModbusTags): TBytes;
var
  i,j, leng: integer;
  inv_buf, buf: TBytes;
  flag_byte, flag_reg, flag_dword: boolean;
  rawvalue: TBytes;
  output: TBytes;
  tag: TModbusTag;
begin
  setlength(output, 0);
  for i := 0 to tags.Count - 1 do
  begin
   // SetLength(buf, length(buf) + tags.Items[i].GetLengthBytes);
   // leng := sizeof(tags.Items[i].GetLengthBytes);
   // leng := tags.Items[i].GetLengthBytes;
   // setlength(buf, leng);
   // buf := tags.Items[i].RawValue;
    tags.Items[i].GetFlags(flag_byte, flag_reg, flag_dword);

    //Отладка
    //====
    {setlength(buf, 4);
    for j := 0 to 3 do
    buf[j] := j;
    //0 1 2 3 4 5 6 7
    //buf := InverseData(buf[0], length(buf), true, true, true);}
    //====
    tag := tags.Items[i];
    buf := InverseData(tag.RawValue[0], length(tag.RawValue), flag_byte, flag_reg, flag_dword);

    setlength(output, length(output) + length(buf));
    if (length(output) > 0) then
       move(buf[0], output[length(output) - length(buf)], length(buf));
  end;
  result := output;
end;

function TModbusCommand.GetModbusDevice: TModbusDevice;
begin
  fCS.Enter;
  try
  result := fParent;
  finally
  fCS.Leave;
  end;
end;

function TModbusCommand.GetUsed: boolean;
begin
  fCS.Enter;
  result := fUsed;
  fCS.Leave;
end;

procedure TModbusCommand.SetUsed(Value: boolean);
begin
 fCS.Enter;
 fUsed := Value;
 fCS.Leave;
end;



procedure TModbusCommand.WriteSingleCoil;
var
  adr: Word;
  Crc: Word;
  leng: Word;
  buf: TBytes;
begin
  adr := Tags.Items[0].Addres;
  fCS.Enter;
  if fProt = ptRTU then
  begin
  //SetLength(fCommand, 6);
  fActualLength := 6;
  fCommand[0] := Tags.Items[0].Parent.Address;
  fCommand[1] := $05; // Force single coil  код команды
  fCommand[2] := Hi(adr); // Старший байт адреса
  fCommand[3] := Lo(adr); // Младший байт адреса

  if Tags.Items[0].ValueInt16 > 0 then
  fCommand[4] := $FF else
  fCommand[4] := $00;

  fCommand[5] := 0;

  Crc := GetCRC(fCommand, fActualLength);
  //SetLength(fCommand, 8);
  fActualLength := 8;
  move(Crc, fCommand[6], 2);
  end else
  if fProt = ptTCP then   //Для ModBus TCP
  begin
  //SetLength(fCommand, 12);
  fActualLength := 12;
  fCommand[0] := 0;
  fCommand[1] := 0;
  fCommand[2] := 0;
  fCommand[3] := 0;

  leng := 6;
  fCommand[4] := leng shr 6;
  fCommand[5] := leng;

  fCommand[6] := Tags.Items[0].Parent.Address;
  fCommand[7] := $05; // Force single coil  код команды
  fCommand[8] := Hi(adr); // Старший байт адреса
  fCommand[9] := Lo(adr); // Младший байт адреса

  if Tags.Items[0].ValueInt16 > 0 then
  fCommand[10] := $FF else
  fCommand[10] := $00;

  fCommand[11] := 0;
  end;
  fCS.Leave;
end;

procedure TModbusCommand.WriteSingleHolding;
var
  adr: Word;
  Crc: Word;
  leng: Word;
  buf: TBytes;
begin
  adr := Tags.Items[0].Addres;
  fCS.Enter;
  if fProt = ptRTU then
  begin
  //SetLength(fCommand, 4);
  fActualLength := 6;
  fCommand[0] := Tags.Items[0].Parent.Address;
  fCommand[1] := $06; // Single input  код команды
  {fCommand[2] := adr shr 8; // Старший байт адреса
  fCommand[3] := adr; // Младший байт адреса}
  fCommand[2] := Hi(adr); // Старший байт адреса
  fCommand[3] := Lo(adr); // Младший байт адреса

  buf := GetData(fTags);
  //SetLength(fCommand, length(fCommand) + 2);
  if length(buf) > 0 then
    move(buf[0], fCommand[4], 2);

  Crc := GetCRC(fCommand, fActualLength);
  fActualLength := fActualLength + 2;
  //SetLength(fCommand, 8);
  move(Crc, fCommand[6], 2);
  end else
  if fProt = ptTCP then   //Для ModBus TCP
  begin
  //SetLength(fCommand, 10);
  //fActualLength := 10;
  fCommand[0] := 0;
  fCommand[1] := 0;
  fCommand[2] := 0;
  fCommand[3] := 0;

  leng := 6;
  fCommand[4] := leng shr 6;
  fCommand[5] := leng;

  fCommand[6] := Tags.Items[0].Parent.Address;
  fCommand[7] := $06; // Single input  код команды
  {fCommand[8] := adr shr 8; // Старший байт адреса
  fCommand[9] := adr; // Младший байт адреса}
  fCommand[8] := Hi(adr); // Старший байт адреса
  fCommand[9] := Lo(adr); // Младший байт адреса

  buf := GetData(fTags);
  fActualLength := 12;
  //SetLength(fCommand, length(fCommand) + 2);
  if length(buf) > 0 then
     move(buf[0], fCommand[10], 2);
  end;
  fCS.Leave;
end;

procedure TModbusCommand.WriteMultipleCoils;
var
  adr: Word;
  Crc: Word;
  leng: Word;
  buf: TBytes;
  n, i: word;
  bytecount: Word;
begin
  adr := Tags.Items[0].Addres;
  bytecount := Ceil(tags.Count/8);
  fCS.Enter;
  if fProt = ptRTU then
  begin
  //SetLength(fCommand, 7 + bytecount);
  fActualLength := 7 + bytecount;
  fCommand[0] := Tags.Items[0].Parent.Address;
  fCommand[1] := $0F; // Force multiple coils код команды
  fCommand[2] := Hi(adr); // Старший байт адреса
  fCommand[3] := Lo(adr); // Младший байт адреса

  fCommand[4] := Hi(tags.Count);
  fCommand[5] := Lo(tags.Count);
  fCommand[6] := bytecount;

  n := 0;
  setlength(buf, bytecount);
  ZeroMemory(@buf[0], bytecount);

  for i := 0 to tags.Count - 1 do
    begin
    n := i div 8;
      if tags.Items[i].ValueInt16 > 0 then
        buf[n] := buf[n] or (1 shl (i - (n div 8))) else
        buf[n] := buf[n] and ($FF - Trunc(Power(2, i - (n div 8))));
    end;
  move(buf[0], fCommand[7], bytecount);

  Crc := GetCRC(fCommand, fActualLength);
  //SetLength(fCommand, 8);
  move(Crc, fCommand[6], 2);
  end else
  if fProt = ptTCP then   //Для ModBus TCP
  begin
  //SetLength(fCommand, 13 + bytecount);
  fActualLength := 13 + bytecount;
  fCommand[0] := 0;
  fCommand[1] := 0;
  fCommand[2] := 0;
  fCommand[3] := 0;

  leng := 6;
  fCommand[4] := leng shr 6;
  fCommand[5] := leng;

  fCommand[6] := Tags.Items[0].Parent.Address;
  fCommand[7] := $0F; // Force multiple coils код команды
  fCommand[8] := Hi(adr); // Старший байт адреса
  fCommand[9] := Lo(adr); // Младший байт адреса
  fCommand[10] := Hi(tags.Count);
  fCommand[11] := Lo(tags.Count);
  fCommand[12] := bytecount;

  n := 0;
  setlength(buf, bytecount);
  ZeroMemory(@buf[0], bytecount);

  for i := 0 to tags.Count - 1 do
    begin
    n := i div 8;
      if tags.Items[i].ValueInt16 > 0 then
        buf[n] := buf[n] or (1 shl (i - (n div 8))) else
        buf[n] := buf[n] and ($FF - Trunc(Power(2, i - (n div 8))));
    end;
  move(buf[0], fCommand[13], bytecount);
  end;
  fCS.Leave;
end;

procedure TModbusCommand.WriteMultipleHolding;
var
  regcnt: Word; // число записываемых регистров
  adr: Word;
  leng: Word;
  Crc: Word;
  buf: TBytes;
begin
  regcnt := GetTotalLeng(Tags);
  adr := Tags.Items[0].Addres;

  fCS.Enter;
  if fProt = ptRTU then
  begin
  buf := GetData(fTags);
  //SetLength(fCommand, 7 + length(buf));

  fActualLength := 7 + length(buf);
  fCommand[0] := fTags.Items[0].Parent.Address;
  fCommand[1] := $10; // Multiple input
  {fCommand[2] := adr shr 8; // Старший байт адреса
  fCommand[3] := adr; // Младший байт адреса
  fCommand[4] := regcnt shr 8; // Старший байт числа регистров
  fCommand[5] := regcnt; // Младший байт числа регистров}
  fCommand[2] := Hi(adr); // Старший байт адреса
  fCommand[3] := Lo(adr); // Младший байт адреса
  fCommand[4] := Hi(regcnt); // Старший байт числа регистров
  fCommand[5] := Lo(regcnt); // Младший байт числа регистров

  fCommand[6] := length(buf); // Длина буфера в байтах
  move(buf[0], fCommand[7], length(buf));

  Crc := GetCRC(fCommand, fActualLength);
  fActualLength := fActualLength + 2;
  //SetLength(fCommand, length(fCommand) + 2);
  move(Crc, fCommand[fActualLength - 2], 2);
  end else
  if fProt = ptTCP then
  begin
  buf := GetData(fTags);
  //SetLength(fCommand, 13);
  fActualLength := 13;
  fCommand[0] := 0;
  fCommand[1] := 0;
  fCommand[2] := 0;
  fCommand[3] := 0;

  leng := 7 + length(buf);
  fCommand[4] := leng shr 8;
  fCommand[5] := leng;

  fCommand[6] := fTags.Items[0].Parent.Address;
  fCommand[7] := $10; // Multiple input
  {fCommand[8] := adr shr 8; // Старший байт адреса
  fCommand[9] := adr; // Младший байт адреса
  fCommand[10] := regcnt shr 8; // Старший байт числа регистров
  fCommand[11] := regcnt; // Младший байт числа регистров}
  fCommand[8] := Hi(adr); // Старший байт адреса
  fCommand[9] := Lo(adr); // Младший байт адреса
  fCommand[10] := Hi(regcnt); // Старший байт числа регистров
  fCommand[11] := Lo(regcnt); // Младший байт числа регистров

  fCommand[12] := length(buf); // Длина буфера в байтах
  //SetLength(fCommand, 13 + length(buf));
  fActualLength := 13 + length(buf);
  if length(buf) > 0 then
     move(buf[0], fCommand[13], length(buf));
  end;
  fCS.Leave;
end;

function TModbusCommand.GetCmdType: TCmdType;
begin
  result := fCommandType;
end;

function TModbusCommand.GetCommand: TBytes;
begin
  result := fCommand;
end;

function TModbusCommand.GetTags: TModbusTags;
begin
  fCS.Enter;
  result := fTags;
  fCS.Leave;
end;

{ TCommandPool }

function TCommandPool.getPoolSize: integer;
begin
  result := fPoolSize;
end;

function TCommandPool.GetFreeCommand: TModbusCommand;
var
  i: integer;
begin
for i := 0 to fPool.Count - 1 do
 begin
 if not fPool.Items[i].Used then
    begin
    fPool.Items[i].Used := true;
    result := fPool.Items[i];
    break;
    end;
 end;
end;

constructor TCommandPool.Create(pool_size: integer);
var
  i: integer;
begin
  fPool := TCommandList.Create;
  fPoolSize := pool_size;

  for i := 0 to fPoolSize - 1 do
   begin
   fPool.Add(TModbusCommand.Create);
   end;
end;

destructor TCommandPool.Destroy;
var
  i: integer;
begin
  for i := 0 to fPool.Count - 1 do
   begin
   fPool.Items[i].Free;
   end;
  FreeAndNil(fPool);
  inherited Destroy;
end;

{ TModbusCommandConstructor }

constructor TModbusCommandConstructor.Create(tags: TModbusTags; protocol: TProtocolType);
var
  i: integer;
begin
  inherited Create;
  fCommandPool := TCommandPool.Create(MAX_COMMANDS);
  fProt := protocol;

  fModbusTags := TModbusTags.Create;
  fOutput := TModbusCommands.Create;

  if Assigned(tags) then
  begin

  {for i := 0 to tags.Count - 1 do
    begin
    fModbusTags.Add(TModbusTag.Create(tags.Items[i]));
    fModbusTags.Last.OnValueChanged := tags.Items[i].OnValueChanged;
    end;}
  AssignTags(tags);
  end;
end;


destructor TModbusCommandConstructor.Destroy;
var
  i: integer;
begin
  {for i := 0 to fModbusTags.Count - 1 do
  begin
    fModbusTags.Items[i].Free;
  end;}

  FreeAndNil(fCommandPool);
  FreeAndNil(fModbusTags);
  FreeAndNil(fOutput);
  inherited;
end;

procedure TModbusCommandConstructor.AssignTags(tags: TModbusTags);
var
  i: integer;
begin
  fModbusTags.Clear;
  for i := 0 to tags.Count - 1 do
    begin
    fModbusTags.Add(tags.Items[i]);
    end;
end;


// Сортировка листа тегов по адресу вставками
procedure TModbusCommandConstructor.Injection(var A: TModbusTags;
  min, max: integer);
var
  i, j, k: integer;
  tmp: TModbusTag;

  function seek(min, max, n: integer): integer;
  begin
    result := min + Round((max - min) / 2);
    if max - min <= 1 then
      result := result + 1
    else if n < A[result].Addres then
      result := seek(min, result, n)
    else
      result := seek(result, max, n)
  end;

begin
  for i := min + 1 to max do
  begin
    if A.Items[i].Addres >= A.Items[i - 1].Addres then
      continue;
    if A.Items[i].Addres < A.Items[min].Addres then
      j := min
    else
      j := seek(min, i - 1, A.Items[i].Addres);

    tmp := A.Items[i];
    for k := i downto j + 1 do
      A[k] := A.Items[k - 1];
    A.Items[j] := tmp;
  end;
end;

// Функция возвращает индекс листа с заданным типом региона памяти. Если регион памяти не найден то возвращается -1
function TModbusCommandConstructor.CheckMemRegion(MemRegion: TMemRegion;
  lst: TListOfModbusTags): integer;
var
  i: integer;
begin
  result := -1;

  for i := 0 to lst.Count - 1 do
  begin
    if lst.Items[i].First.MemRegion = MemRegion then
    begin
      result := i;
      break;
    end;
  end;
end;

// Функция принимает на вход лист тэгов модбас и сортирует их по разделам памяти
// В результате на выходе имеем несколько листов с тегами. В каждом листе теги только одной области памяти
function TModbusCommandConstructor.SortTagsByMem(unsorted: TModbusTags): TListOfModbusTags;
var
  i, j: integer;
  output: TListOfModbusTags;
  Region: TMemRegion;
  lst_index: integer;
  buf: TModbusTags;
begin
  output := TListOfModbusTags.Create;

  for i := 0 to unsorted.Count - 1 do
  begin
    Region := unsorted.Items[i].MemRegion;
    lst_index := CheckMemRegion(Region, output);

    if (output.Count = 0) or (lst_index = -1) then
    begin
      output.Add(TModbusTags.Create);
      lst_index := output.Count - 1;
    end;

    output.Items[lst_index].Add(unsorted.Items[i]);
  end;
  result := output;
end;

// Функция проверяет последовательно ли расположены два переданных на вход тега
// Последовательными считаются теги у которы адрес первого + длина первого = адрес второго,
// при этом обязательным условием считается совпадение регионов памяти
function TModbusCommandConstructor.IsSequenced(tag1, tag2: TModbusTag): boolean;
begin
  //Дополнительным условием последовательности является то что оба регистра разрешается обрабатывать групповой командой.
  result := (tag1.MemRegion = tag2.MemRegion) and
    (tag1.Addres + tag1.GetLength = tag2.Addres) and tag1.AllowGroupWorking and tag2.AllowGroupWorking;
end;

// На вход подаем список сортированных тегов
// На выходе список модбас команд сформированный на основе списка тэгов. Часть команд может быть групповыми,
// т.е. за один запрос может быть запрошено множество последовательных регистров. Полученные данные
// раскладываются по входящим в команду тегам
function TModbusCommandConstructor.MakeCommands(sortedtags: TListOfModbusTags; typ: TCmdType = ctRead; continiousWrite: boolean = false): TModbusCommands;
var
  i: integer;
  Command: TModbusCommand;
  tags: TModbusTags;
  tag: TModbusTag;
  ct: TCmdType;
  //output: TModbusCommands;
begin
  //output := TModbusCommands.Create;
  //tags := TModbusTags.Create;
  tags := nil;
  fOutput.Clear;

  for i := 0 to sortedtags.Count - 1 do
  begin
      while (sortedtags.Items[i].Count > 0) do
      begin
        if not Assigned(tags) then
        tags := TModbusTags.Create;

        if (tags.Count = 0) then
        begin
          tag := sortedtags.Items[i].Items[0];
          if ((tag.AccessType = atWrite) and (typ = ctWrite) and
             (tag.ContiniousWrite = continiousWrite))
          or ((typ = ctRead) and (tag.AccessType = atRead)) then
                tags.Add(tag);

          sortedtags.Items[i].Remove(tag);
          continue;
        end;

          if IsSequenced(tags.Last, sortedtags.Items[i].First) and sortedtags.Items[i].First.AllowGroupWorking then
          begin
            tags.Add(sortedtags.Items[i].First);
            sortedtags.Items[i].Remove(sortedtags.Items[i].First);
          end else
          begin
            //Не создаем, а берем из пула
            //Command := TModbusCommand.Create(tags, fProt, typ);
            if tags.Count > 0 then
            begin
            Command := fCommandPool.GetFreeCommand;
            Command.CmdType := typ;
            Command.Protocol := fProt;
            Command.AssignTags(tags);
            Command.GenerateCommand;
            fOutput.Add(Command);
            end;
            FreeAndNil(tags);
          end;
      end;
  end;

  if Assigned(tags) then
     begin
       //Command := TModbusCommand.Create(tags, fProt, typ);
     if tags.Count > 0 then
       begin
       Command := fCommandPool.GetFreeCommand;
       Command.AssignTags(tags);
       Command.CmdType := typ;
       Command.Protocol := fProt;
       Command.GenerateCommand;
       fOutput.Add(Command);
       end;
       FreeAndNil(tags);
     end;

  result := fOutput;
end;

function TModbusCommandConstructor.MakeWriteCommands: TModbusCommands;
var
  lst: TListOfModbusTags;
  //output: TModbusCommands;
  i, j: integer;
  tag: TModbusTag;
begin
  lst := SortTagsByMem(fModbusTags);
  SortByAdr(lst);

    {i := 0;
    while i < lst.Count do
      begin
        j := 0;
        while j < lst.Items[i].Count do
          begin
          tag := lst.items[i].Items[j];
          if (tag.AccessType = atRead) then
                begin
                //lst.items[i].Items[j].Free;
                lst.items[i].Remove(tag);
                end else
                inc(j);
          end;
          if lst.Items[i].Count = 0  then
             begin
             lst.Items[i].Free;
             lst.Delete(i);
             end else inc(i);
      end; }

  fOutput := MakeCommands(lst, ctWrite, false);
  for i := 0 to lst.Count - 1 do
  begin
      lst.Items[i].Free;
  end;
  FreeAndNil(lst);

  result := fOutput;
end;

function TModbusCommandConstructor.MakeContiniousWriteCommands: TModbusCommands;
var
  lst: TListOfModbusTags;
  //output: TModbusCommands;
  i, j: integer;
  tag: TModbusTag;
begin
  lst := SortTagsByMem(fModbusTags);
  SortByAdr(lst);

   { i := 0;
    while i < lst.Count do
      begin
        j := 0;
        while j < lst.Items[i].Count do
          begin
          tag := lst.items[i].Items[j];
          if (tag.AccessType = atRead) or (tag.ContiniousWrite = false) then
                begin
                //lst.items[i].Items[j].Free;
                lst.items[i].Remove(tag);
                end else
                inc(j);
          end;
          if lst.Items[i].Count = 0  then
             begin
             //lst.Items[i].Free;
             lst.Delete(i);
             end else inc(i);
      end;}

  fOutput := MakeCommands(lst, ctWrite, true);
  for i := 0 to lst.Count - 1 do
  begin
    lst.Items[i].Free;
  end;
  FreeAndNil(lst);

  result := fOutput;
end;

function TModbusCommandConstructor.Make_Commands: TModbusCommands;
var
  lst: TListOfModbusTags;
  //output: TModbusCommands;
  i, j: integer;
  tag: TModbusTag;
begin
  lst := SortTagsByMem(fModbusTags);
  SortByAdr(lst);
  {i := 0;
  while i < lst.Count do
      begin
        j := 0;
        while j < lst.Items[i].Count do
          begin
          tag := lst.items[i].Items[j];
          if (tag.AccessType = atWrite) then
                begin
                lst.items[i].Remove(tag);
                end else
                inc(j);
          end;
          if lst.Items[i].Count = 0  then
             begin
             lst.Items[i].Free;
             lst.Delete(i);
             end else inc(i);
      end; }

  fOutput.Clear;
  if lst.Count > 0 then
     fOutput := MakeCommands(lst, ctRead, false); //else
     //output := nil;


  for i := 0 to lst.Count - 1 do
  begin
      lst.Items[i].Free;
  end;
  FreeAndNil(lst);

  result := fOutput;
end;

// Функция принимает на вход листы (TList<TModbusTag>) тэгов модбас в которых теги сгруппированы по регионам памяти
// (результат работы SortTagsByMem) и сортирует их по возрастанию адресов.
// В результате все входные листы выходят с отсортированными тегами по возрастанию
procedure TModbusCommandConstructor.SortByAdr(var unsorted: TListOfModbusTags);
var
  i: integer;
  lst: TModbusTags;
begin
  for i := 0 to unsorted.Count - 1 do
  begin
    if unsorted.Items[i].Count > 1 then
    begin
      lst := unsorted.Items[i];
      Injection(lst, 0, unsorted.Items[i].Count - 1);
    end;
  end;
end;

{ TBusTCP }

constructor TBusTCP.Create;
begin
  inherited Create;

  fName := '';
  fDescr := '';
  fTryReconnect := true;
  fType := ptTCP;
  fConnection := TTCPClient.Create;
  fConnection.OnConnected := @TCPClientConnected;
  fConnection.OnDisconnected := @TCPClientDisconnected;
  fConnection.OnConnectionFail := @TCPClientConnectionFailed;

end;

constructor TBusTCP.Create(bus: TBus);
var
  i: integer;
begin
  inherited Create;

  fName := bus.Name;
  fDescr := bus.Description;
  fTryReconnect := true;
  fType := ptTCP;
  fConnection := TTCPClient.Create;
  fConnection.OnConnected := @TCPClientConnected;
  fConnection.OnDisconnected := @TCPClientDisconnected;
  fConnection.OnConnectionFail := @TCPClientConnectionFailed;

  OnMessage := bus.OnMessage;
  OnDataSend := bus.OnDataSend;
  OnDataRcv := bus.OnDataRcv;

  for i := 0 to bus.Items.Count - 1 do
  begin
    Items.Add(TModbusDevice.Create(self, bus.Items[i]));
  end;
end;

constructor TBusTCP.Create(bus: TBusTCP);
var
  i: integer;
begin
  inherited Create;

  fName := bus.Name;
  fDescr := bus.Description;
  fTryReconnect := true;
  fType := ptTCP;
  fConnection := TTCPClient.Create;
  fConnection.OnConnected := @TCPClientConnected;
  fConnection.OnDisconnected := @TCPClientDisconnected;
  fConnection.OnConnectionFail := @TCPClientConnectionFailed;

  OnMessage := bus.OnMessage;
  OnDataSend := bus.OnDataSend;
  OnDataRcv := bus.OnDataRcv;

  for i := 0 to bus.Items.Count - 1 do
  begin
    Items.Add(TModbusDevice.Create(self, bus.Items[i]));
  end;

  self.Connection.Port := bus.Connection.Port;
  self.Connection.Host := bus.Connection.Host;
end;

constructor TBusTCP.Create(bus: TBusTCP; node: TTreeNode);
var
  i: integer;
  child: TTreeNode;
begin
  inherited Create;

  fName := node.Text;
  fDescr := bus.Description;
  fTryReconnect := true;
  fType := ptTCP;
  fConnection := TTCPClient.Create;
  fConnection.OnConnected := @TCPClientConnected;
  fConnection.OnDisconnected := @TCPClientDisconnected;
  fConnection.OnConnectionFail := @TCPClientConnectionFailed;

  child := node.getFirstChild;

  OnMessage := bus.OnMessage;
  OnDataSend := bus.OnDataSend;
  OnDataRcv := bus.OnDataRcv;

  for i := 0 to bus.Items.Count - 1 do
  begin
    if not Assigned(child) then break;
    Items.Add(TModbusDevice.Create(bus.Items[i], child));
    child := node.GetNextChild(child);
  end;

  self.Connection.Port := bus.Connection.Port;
  self.Connection.Host := bus.Connection.Host;
end;

procedure TBusTCP.DoConnected;
begin
  if Assigned(fConnected) then
    fConnected(self);
end;

procedure TBusTCP.DoDisconnected;
begin
  if Assigned(fDisconnected) then
    fDisconnected(self);
end;

procedure TBusTCP.DoConnectionFailed;
begin
  if Assigned(fConnectionFailed) then
     fConnectionFailed(Self);
end;


destructor TBusTCP.Destroy;
begin

  inherited;
end;

procedure TBusTCP.TCPClientConnectionFailed(Sender: TObject);
begin
  DoConnectionFailed;

  DoMessage(self, WinCPToUTF8(format('Подключение к узлу %s:%s завершилось с ошибкой!',[fConnection.Host, IntToStr(fConnection.Port)])));
  if WriteLogFlag then
         TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format('Connection error! Try to reconnect node %s:%s...',[fConnection.Host, IntToStr(fConnection.Port)]));
  if Active and fTryReconnect then
    begin
      DoMessage(self, WinCPToUTF8(format('Попытка восстановить подключение к узлу %s:%s',[fConnection.Host, IntToStr(fConnection.Port)])));
      if WriteLogFlag then
         TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format('Try to reconnect node %s:%s...',[fConnection.Host, IntToStr(fConnection.Port)]));
      fConnection.Connect;
    end;
end;

procedure TBusTCP.DoMessage(Sender: TObject; Msg: string);
begin
  if Assigned(fOnMessage) then
    fOnMessage(self, Msg);
end;

procedure TBusTCP.ForceTag(tag: TModbusTag);
begin
  if (not Active) or (not Connection.Connected) then Exit;
  fPollThread.ForceTag(tag);
end;

function TBusTCP.GetConnection: TTCPClient;
begin
  result := fConnection;
end;

function TBusTCP.GetPort: integer;
begin
 result := fPort;
end;

procedure TBusTCP.TCPClientDataRx(Sender: TObject; device: TModbusDevice; data: TBytes; leng: integer);
begin
  DoDataRcv(device, data, leng);
end;

procedure TBusTCP.TCPClientDataTx(Sender: TObject; device: TModbusDevice; data: TBytes; leng: integer);
begin
  DoDataSent(device, data, leng);
end;

procedure TBusTCP.TCPClientConnected(Sender: TObject);
begin
  fPollThread := TTCPPollThread.Create(self);
  fPollThread.Write_Log := WriteLogFlag;
  fPollThread.LogDir := LOG_DIR;
  fPollThread.OnDataRx := @TCPClientDataRx;
  fPollThread.OnDataTx := @TCPClientDataTx;
  fPollThread.Start;
  DoConnected;
  DoMessage(self, WinCPToUTF8(format('Подключен узел %s:%s',[fConnection.Host, IntToStr(fConnection.Port)])));
  if WriteLogFlag then
         TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format(' Node %s:%s connection established!',[fConnection.Host, IntToStr(fConnection.Port)]));
end;

procedure TBusTCP.TCPClientDisconnected(Sender: TObject);
begin
  if Assigned(fPollThread) then
    begin
      fPollThread.Terminate;
      fPollThread.WaitFor;
      FreeAndNil(fPollThread);

      fConnection.Disconnect;
    end;
    DoMessage(self, WinCPToUTF8(format('Подключение к узлу %s:%s разорвано',[fConnection.Host, IntToStr(fConnection.Port)])));
    if WriteLogFlag then
         TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format(' Node %s:%s disconnected',[fConnection.Host, IntToStr(fConnection.Port)]));
    if Active and fTryReconnect then
       begin
       if WriteLogFlag then
         TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg('Bus: ' + Self.Name + format(' Try to reconnect node %s:%s...',[fConnection.Host, IntToStr(fConnection.Port)]));
       DoMessage(self, WinCPToUTF8(format('Попытка восстановить подключение к узлу %s:%s',[fConnection.Host, IntToStr(fConnection.Port)])));
       fConnection.Connect;
       end;
end;

procedure TBusTCP.SetActive(const Value: boolean);
var
  i: integer;
begin
  //inherited;
  if fActive = Value then exit;
  fActive := Value;

  if Value then
  begin
    try
      fConnection.Connect; //Асинхронная операция, результат определяется событием
    except

    end;
    for i := 0 to fDevices.Count - 1 do
        fDevices.Items[i].TemporalDisabled := false;
  end else
    begin
    if Assigned(fPollThread) then
      begin
      fPollThread.Terminate;
      fPollThread.WaitFor;
      FreeAndNil(fPollThread);
      end;
    fConnection.Disconnect;
    end;

end;

procedure TBusTCP.WriteTag(tag: TModbusTag);
begin
  if (not Active) or (not Connection.Connected) then Exit;
  fPollThread.WriteTag(tag);
end;

{ TPollThread }

procedure TPollThread.Clean(typ: TCmdType);
var
  i, n: integer;

begin
  n := fCommandQueue.Count;

  While i < n do
    begin
    n := fCommandQueue.Count;

    if fCommandQueue.Items[i].GetCmdType = typ then
       fCommandQueue.Remove(i) else
       inc(i);
    end;
end;

constructor TPollThread.Create(ParentBus: TBus);
begin
  inherited Create(true);
  fCS := TCriticalSection.Create;
  fSync := TCriticalSection.Create;
  fTimeout := false;
  fWaitingResponse := false;
  fParent := ParentBus;
  fRetry_cnt := 3;
  fCurrent_retry := 0;
  fWriteLog := false;



  if fParent is TBusRTU then
     TBusRTU(fParent).Port.OnRxData := @DataRX;
  if fParent is TBusTCP then
     TBusTCP(fParent).Connection.OnRx := @DataRX;
  fTagLst := TModbusTags.Create;
  fCommandQueue := TCommandQueue.Create;

  fTimeoutTimer := TThreadedTimer.Create(@onTimeoutTimerTick, self);
  fTimeoutTimer.Interval := 500;
  //fTimeoutTimer := TTimerThread.Create(500, fSync);
  //fTimeoutTimer.OnTick := @onTimeoutTimerTick;
end;

procedure TPollThread.DoDataRx(device: TModbusDevice; data: TBytes; leng: Cardinal);
begin
  if Assigned(fDataRx) then
     fDataRx(self, device, data, leng);
end;

procedure TPollThread.DoDataTx(device: TModbusDevice; data: TBytes; leng: Cardinal);
begin
  if Assigned(fDataTx) then
     fDataTx(self, device, data, leng);
end;

procedure TPollThread.WriteLog(s: string);
var
  fs: TFileStream;
  str: string;
begin
if not Write_Log then Exit;
  TLogger.getInstance(LOG_DIR + '\log.txt').LogMsg(s);
  {try
  if not fileexists(fDir + '\log.txt') then
    fs := TFileStream.Create(fDir + '\log.txt', fmCreate) else
    fs := TFileStream.Create(fDir + '\log.txt', fmShareDenyNone or fmOpenWrite);

    fs.Seek(0, soFromEnd);
    str := timetostr(now) + ' ' + s + #13;
    fs.WriteBuffer(str[1], length(str) * sizeof(char));
  finally
    fs.Free;
  end;  }

end;

procedure TPollThread.WriteTag(tag: TModbusTag);  //запись тэга (команда ставится в общую очередь)
var
  //CommandConstructor: TModbusCommandConstructor;
  //lst: TModbusTags;
  commands: TModbusCommands;
  i: integer;
begin
  WriteLog('Bus: ' + Parent.Name + ' Enter WriteTag');

  fCS.Enter;
  fTagLst.Clear;
  fTagLst.Add(tag);


  fCommandConstructor.AssignTags(fTagLst);

  commands := fCommandConstructor.MakeWriteCommands;
  if Assigned(commands) then
  begin
  for i := 0 to commands.Count - 1 do
     fCommandQueue.Enqueue(commands[i]);
  fCS.Leave;

  WriteLog('Bus: ' + Parent.Name + ' Exit WriteTag');
  end;
end;



//Посылка команды потоком опроса в порт шины
procedure TPollThread.SendCommand;
var
  cmd: TBytes;
  device: TModbusDevice;
  leng: integer;
begin
  WriteLog('Bus: ' + Parent.Name + ' Enter SendCommand');

  fCS.Enter;
  fCurrentCommand.GenerateCommand;
  cmd := fCurrentCommand.GetCommand;
  leng := fCurrentCommand.ActualLength;
  fWaitingResponse := true;
  fCS.Leave;

  WriteLog('Bus: ' + Parent.Name +' SendCommand: fWaitingResponse = ' + BoolToStr(fWaitingResponse, true) + ' data = ' + DataToStr(cmd, leng));

  fCS.Enter;
  if fParent is TBusRTU then
     TBusRTU(fParent).Port.WriteBuffer(cmd[0], fCurrentCommand.ActualLength)
  else
  if fParent is TBusTCP then
     TBusTCP(fParent).Connection.SendData(cmd, fCurrentCommand.ActualLength);
  fCS.Leave;

  if (length(cmd) > 0) then
  begin
    if fParent is TBusRTU then
      device := FindDeviceByAddress(cmd[0]);
    if (fParent is TBusTCP) and (length(cmd) > 6)  then
      device := FindDeviceByAddress(cmd[6]);
  end;

  if Assigned(device) then
    DoDataTx(device, cmd, fCurrentCommand.ActualLength);

  fCS.Enter;
  fTimeoutTimer.Active := true;
  fCS.Leave;

  WriteLog('Bus: ' + Parent.Name + ' Exit SendCommand');
end;

procedure TPollThread.SetDir(const Value: string);
begin
  fDir := Value;
end;

procedure TPollThread.setWriteLog(const Value: boolean);
begin
  fWriteLog := Value;
end;

//Поиск тэга по адресу устройства и тэга
function TPollThread.FindTagByAddress(dev_address, tag_address: Byte): TModbusTag;
var
  dev: TModbusDevice;
  i: integer;
begin
  result := nil;
  dev := FindDeviceByAddress(dev_address);
  if Assigned(dev) then
  begin
    for i := 0 to dev.tags.Count - 1 do
    begin
      if dev.tags[i].Addres = tag_address then
      begin
        result := dev.tags[i];
        break;
      end;
    end;
  end;
end;

//Переделать на WriteTag
procedure TPollThread.ForceTag(tag: TModbusTag); //Принудительная (без очереди) запись тэга
var
  CommandConstructor: TModbusCommandConstructor;
  lst: TModbusTags;
  commands: TModbusCommands;
  i: integer;
begin
{WriteLog('Bus: ' + Parent.Name + ' Enter WriteTag');

  fCS.Enter;
  fTagLst.Clear;
  fTagLst.Add(tag);


  fCommandConstructor.AssignTags(fTagLst);

  commands := fCommandConstructor.MakeWriteCommands;
  if Assigned(commands) then
  begin
  for i := 0 to commands.Count - 1 do
     fCommandQueue.Enqueue(commands[i]);
  fCS.Leave;

  WriteLog('Bus: ' + Parent.Name + ' Exit WriteTag');}

{WriteLog('Bus: ' + Parent.Name + ' Enter ForceTag');
  lst := TModbusTags.Create;
  lst.Add(tag);

  if self is TTCPPollThread then
     CommandConstructor := TModbusCommandConstructor.Create(lst, ptTCP)
  else
  if self is TRTUPollThread then
     CommandConstructor := TModbusCommandConstructor.Create(lst, ptRTU);

  Clean(ctWrite); //Очистка старых команд записи

  commands := CommandConstructor.MakeWriteCommands;
  for i := 0 to commands.Count - 1 do
     fCommandQueue.Push(commands[i]);

  FreeAndNil(lst);
  FreeAndNil(CommandConstructor);
  WriteLog('Bus: ' + Parent.Name + ' Exit ForceTag');}

  WriteLog('Bus: ' + Parent.Name + ' Enter ForceTag');
  fCS.Enter;
  fTagLst.Clear;
  fTagLst.Add(tag);


  fCommandConstructor.AssignTags(fTagLst);

  commands := fCommandConstructor.MakeWriteCommands;
  if Assigned(commands) then
  begin
  for i := 0 to commands.Count - 1 do
     fCommandQueue.Push(commands[i]);
  end;
  fCS.Leave;
  WriteLog('Bus: ' + Parent.Name + ' Exit ForceTag');
end;

function TPollThread.FindDeviceByAddress(dev_address: Byte): TModbusDevice;
var
  i: integer;
begin
  WriteLog('Bus: ' + Parent.Name + ' Enter FindDeviceByAddress');
  result := nil;

  for i := 0 to fParent.Items.Count - 1 do
  begin
    if Parent.Items[i].Address = dev_address then
    begin
      result := fParent.Items[i];
      break;
    end;
  end;
  WriteLog('Bus: ' + Parent.Name + ' Exit FindDeviceByAddress');
end;

function TPollThread.GetDir: string;
begin
   result := fDir;
end;

function TPollThread.GetParent: TBus;
begin
  result := fParent;
end;


function TPollThread.getWriteLog: boolean;
begin
  result := fWriteLog;
end;


function TPollThread.GetResponseLeng: Cardinal;
begin
  fCS.Enter;
  result := fResponseLeng;
  fCS.Leave;
end;


procedure TPollThread.PollDevice(device: TModbusDevice);
var
  i: integer;
  //CommandConstructor: TModbusCommandConstructor;
  commands: TModbusCommands;
  write_commands: TModbusCommands;
  cmd: TModbusCommand;
begin
  WriteLog('Bus: ' + Parent.Name + ' Enter PollDevice');
  WriteLog('Bus: ' + Parent.Name + ' PollDevice: fWaitingResponse = ' + BoolToStr(fWaitingResponse, true) + ' device = ' + IntToStr(device.Address));
  try
  fCS.Enter;
  fCommandConstructor.AssignTags(device.tags);

  commands := fCommandConstructor.Make_Commands;
  if Assigned(commands) then
  begin
    for i := 0 to commands.Count - 1 do
      begin
        cmd := commands.Items[i];
        fCommandQueue.Push(cmd);
      end;
  end;

  write_commands := fCommandConstructor.MakeContiniousWriteCommands;
  if Assigned(write_commands) then
  begin
    for i := 0 to write_commands.Count - 1 do
      begin
        fCommandQueue.Push(write_commands.Items[i]);
      end;
  end;
  fCS.Leave;



  finally
  //FreeAndNil(CommandConstructor);
  end;
  WriteLog('Bus: ' + Parent.Name + ' Exit PollDevice');
end;

// Процедура перехода на следующее состояние
procedure TPollThread.EnterNextState(retry: boolean);
var
  i: integer;
  b: byte;
begin
  WriteLog('Bus: ' + Parent.Name + ' Enter EnterNextState');
  WriteLog('Bus: ' + Parent.Name + ' EnterNextState: fWaitingResponse = ' + BoolToStr(fWaitingResponse, true) + ' retry = ' + BoolToStr(retry, true));

  fCS.Enter;
  if not retry or (not Assigned(fCurrentCommand)) then // Если не выставлен флаг повторения, то вызываем следующее состояние из очереди
  begin
  //Вместо уничтожения команды, возвращаем ее в пул и обнуляем текущую
  if Assigned(fCurrentCommand) then
   begin
   fCurrentCommand.Used := false; //FreeAndNil(fCurrentCommand);
   fCurrentCommand := nil;
   end;
  fCS.Leave;

  fCurrent_retry := 0;

    if fCommandQueue.Count > 0 then // Если на момент вызова очередь не пуста
    begin
      WriteLog('Bus: ' + Parent.Name + ' EnterNextState Before ExtractCommand');
      fCS.Enter;
      fCurrentCommand := fCommandQueue.Extract;
      fCS.Leave;
    end
    else
    begin // Если очередь пуста, то заполняем ее командами чтения и записи тегов устройств на шине
      for i := 0 to fParent.Items.Count - 1 do
      begin
      if fParent.Items[i].Enabled and (not fParent.Items[i].TemporalDisabled) then
        begin
        WriteLog('Bus: ' + Parent.Name + ' EnterNextState Before PollDevice');
        PollDevice(fParent.Items[i]); //Заполнить очередь опроса если устройство включено
        end;
        if Terminated then
          break;
      end;
       // if fCommandQueue.Count > 0 then // Если на момент вызова очередь не пуста
       //   fCurrentCommand := fCommandQueue.Extract;

    end;
  end;

  if Assigned(fCurrentCommand) and Assigned(fCurrentCommand.Tags) and (fCurrentCommand.tags.Count > 0) then
     begin
     fCS.Enter;
     b := fCurrentCommand.Command[1];
     if fLastAdr = fCurrentCommand.Tags[0].Parent.Address then
      sleep(Parent.PauseDelay);
      WriteLog('Bus: ' + Parent.Name + ' EnterNextState Before SendCommand');
     fCS.Leave;
      SendCommand;
     end;


     if Assigned(fCurrentCommand) and Assigned(fCurrentCommand.Tags) and (fCurrentCommand.Tags.Count > 0) then
      fLastAdr := fCurrentCommand.Tags[0].Parent.Address;



   WriteLog('Bus: ' + Parent.Name + ' Exit EnterNextState');
end;


destructor TPollThread.Destroy;
var
i: integer;
begin
{
  if not fTimeoutTimer.CheckTerminated then
   begin
   fTimeoutTimer.Terminate;
   fTimeoutTimer.WaitFor;
   end;     }

  FreeAndNil(fTimeoutTimer);
  FreeAndNil(fCS);
  FreeAndNil(fSync);
  FreeAndNil(fCommandConstructor);
  FreeAndNil(fTagLst);

  //Разрушение перенесено в пул
  //if Assigned(fCurrentCommand) then FreeAndNil(fCurrentCommand);

  //for I := 0 to fCommandQueue.Count - 1 do
  //  fCommandQueue.Items[i].Free;
  FreeAndNil(fCommandQueue);
  inherited;
end;

procedure TPollThread.DoFullTimeout;
begin
  if Assigned(fFullTimeout) then
    fFullTimeout(self);
end;

procedure TPollThread.ProcessReadComplete;
begin
  WriteLog('Bus: ' + Parent.Name + ' ProcessReadComplete: fResponse = ' + DataToStr(fResponse, fResponseLeng) +
  ' fWaitingResponse = ' + BoolToStr(fWaitingResponse, true) +
  ' fTimeout = ' + BoolToStr(fTimeout, true) );

  fCS.Enter;
  fCurrent_retry := 0;
  fCS.Leave;

  DropTimeout;
end;

procedure TPollThread.ProcessSendComplete;
begin
  WriteLog('Bus: ' + Parent.Name + ' ProcessSendComplete: fCurrentCommand = ' + DataToStr(fCurrentCommand.Command, fCurrentCommand.ActualLength) +
  ' fWaitingResponse = ' + BoolToStr(fWaitingResponse, true) +
  ' fTimeout = ' + BoolToStr(fTimeout, true));

  DropTimeout;
end;

procedure TPollThread.ProcessTimeout;
var
  i: integer;
begin
  WriteLog('Bus: ' + Parent.Name + ' Enter ProcessTimeout');
  WriteLog('Bus: ' + Parent.Name + ' ProcessTimeout: fWaitingResponse = ' + BoolToStr(fWaitingResponse, true) + ' fCurrent_retry = ' + IntToStr(fCurrent_retry));

  fCS.Enter;
  fWaitingResponse := false; // Снимаем флаг ожидания ответа
  fTimeoutFlag := false;
  //fTimeoutTimer.Active := false;
  fCS.Leave;


  if Terminated then
    begin
    Exit; // Выход из процедуры если поток остановлен
    end;



  // Если номер текущей попытки меньше заданного числа попыток перезапроса
  //if (fCurrent_retry < fRetry_cnt) then
  if (fCurrent_retry < fCurrentCommand.Parent.Tries) then
  begin
    fCS.Enter;
    inc(fCurrent_retry);
    fTimeout := true; // Устанавливаем флаг таймаута. Последнюю команду следует повторить
    fCS.Leave;
  end
  else
  begin // Произошел полный таймаут (выбраны все попытки перезапроса)
    fCS.Enter;
    fCurrent_retry := 0;
    fTimeout := false; // Снимаем флаг таймаута (вход в следующее состояние перейдет на следующую команду из очереди)

    // Если наступил полный таймаут, то не продолжаем опрос данного канала
    // (должен быть установлен соответствующий флаг)
    if fCurrentCommand.Parent.BreakOnTimeout then
    begin
      i := 0;
      //fCS.Enter;
      fCurrentCommand.tags.Items[0].Parent.TemporalDisabled := true;

      while i < fCommandQueue.Count do
      begin
        if (fCommandQueue.Items[i].tags.Items[0].Parent = fCurrentCommand.tags.Items[0].Parent) then
          fCommandQueue.Remove(i)
        else
          inc(i);
      end;
    end;
    fCS.Leave;
    DoFullTimeout; //Выполняется в потоке! возможна проблема, но Synchronize зависает
  end;

  WriteLog('Bus: ' + Parent.Name + ' Exit ProcessTimeout');
end;

procedure TPollThread.onTimeoutTimerTick(Data: Pointer);
var
  i: integer;
  this: TPollThread;
begin
  this := TPollThread(Data);
  //Сработал таймер таймаута
  WriteLog('Bus: ' + this.Parent.Name + ' Enter TimeoutTimerTick');
  WriteLog('Bus: ' + this.Parent.Name + ' TimeoutTimerTick');

  this.fTimeoutTimer.Active := false; // Останавливаем таймер опроса
  this.fTimeoutFlag := true;   //Выставленный флаг будет подхвачен в суперцикле потока
  WriteLog('Bus: ' + this.Parent.Name + ' Exit TimeoutTimerTick');
end;

{ TTCPPollThread }


procedure TTCPPollThread.DecodeResponse(const data: TBytes; leng: Cardinal);
var
  device: TModbusDevice;
  Tag: TModbusTag;
  tag_adr: Word;
  raw_value: TBytes;
  i: integer;
  offset: integer;
  flag_byte, flag_word, flag_dword: boolean;
begin
WriteLog('Bus: ' + Parent.Name + ' Enter DecodeResponse');
offset := 0;
WriteLog('Bus: ' + Parent.Name +  ' DecodeResponse data = ' + DataToStr(data, leng) + ' leng = ' + IntToStr(leng));
if (length(data) > 0) then
  begin
  try
  if (length(data) > 5) then
  device := FindDeviceByAddress(data[6]);

  if Assigned(device) then
    DoDataRx(device, data, leng);

  if not ((data[7] = $03) or (data[7] = $04)) then exit; //Если команда не является запросом на чтение выйти
    if (data[7] = $03) or (data[7] = $04) then
    begin
    fCS.Enter;
    for i := 0 to fCurrentCommand.tags.Count - 1 do
        begin
          Tag := fCurrentCommand.tags.Items[i];
          if Assigned(Tag) and (Tag.AccessType <> atWrite) then
          begin
            SetLength(raw_value, Tag.GetLengthBytes);
            move(data[9 + offset], raw_value[0], length(raw_value));

            tag.GetFlags(flag_byte, flag_word, flag_dword);
            raw_value := InverseData(raw_value[0], length(raw_value), flag_byte, flag_word, flag_dword);
            Tag.RawValue := raw_value;
            offset := offset + Tag.GetLengthBytes;
          end;
        end;
    fCS.Leave;
    end else
    if (data[7] = $01) then
        begin
          DecodeReadCoils(data);
        end;
  except
  on e: exception do
     WriteLog('Bus: ' + Parent.Name + ' DecodeResponse error msg = ' + e.Message);
  end;
  end;
  WriteLog('Bus: ' + Parent.Name + ' Exit DecodeResponse');
end;

procedure TTCPPollThread.ProcessSendComplete;
begin
 inherited;

 fCS.Enter;
  fSendComplete := false;
 fCS.Leave;
end;

constructor TTCPPollThread.Create(ParentBus: TBus);
begin
  inherited Create(ParentBus);
  fCommandConstructor := TModbusCommandConstructor.Create(nil, ptTCP);
end;

procedure TTCPPollThread.ProcessReadComplete;
var
  buf: TBytes;
begin
  inherited;

  DecodeResponse(fResponse, fResponseLeng);

  fCS.Enter;
  fWaitingResponse := false;
  fReadComplete := false;
  fCS.Leave;
end;


procedure TTCPPollThread.DecodeResponse;
var
  device: TModbusDevice;
  Tag: TModbusTag;
  tag_adr: Word;
  raw_value: TBytes;
  i: integer;
  offset: integer;
  flag_byte, flag_word, flag_dword: boolean;
begin
WriteLog('Bus: ' + Parent.Name + ' Enter DecodeResponse (no params)');
offset := 0;
WriteLog('Bus: ' + Parent.Name + ' DecodeResponse (no params)');
if (TBusTCP(fParent).Connection.RcvBufLeng > 6) then
  begin
  try
  if (TBusTCP(fParent).Connection.RcvBufLeng > 5) then
  device := FindDeviceByAddress(TBusTCP(fParent).Connection.RcvBuf[6]);

  if Assigned(device) then
   DoDataRx(device, TBusTCP(fParent).Connection.RcvBuf, TBusTCP(fParent).Connection.RcvBufLeng);

  //Пришел ответ на команду записи
  if (TBusTCP(fParent).Connection.RcvBuf[7] = $06) or (TBusTCP(fParent).Connection.RcvBuf[7] = $10) then
  begin
    fSendComplete := true;
  end;

  if not ((TBusTCP(fParent).Connection.RcvBuf[7] = $03) or (TBusTCP(fParent).Connection.RcvBuf[7] = $04)) then exit; //Если команда не является запросом на чтение выйти

    if (TBusTCP(fParent).Connection.RcvBuf[7] = $03) or (TBusTCP(fParent).Connection.RcvBuf[7] = $04) then
    begin
        for i := 0 to fCurrentCommand.tags.Count - 1 do
        begin
          Tag := fCurrentCommand.tags.Items[i];
          if Assigned(Tag) and (Tag.AccessType <> atWrite) then
          begin
            SetLength(raw_value, Tag.GetLengthBytes);
            move(TBusTCP(fParent).Connection.RcvBuf[9 + offset], raw_value[0], length(raw_value));

            tag.GetFlags(flag_byte, flag_word, flag_dword);
            raw_value := InverseData(raw_value[0], length(raw_value), flag_byte, flag_word, flag_dword);
            Tag.RawValue := raw_value;

            offset := offset + Tag.GetLengthBytes;
          end;
        end;
    end else
    if (TBusTCP(fParent).Connection.RcvBuf[7] = $01) then
        begin
          DecodeReadCoils(TBusTCP(fParent).Connection.RcvBuf);
        end;

  except
  on e: exception do
     WriteLog('Bus: ' + Parent.Name + ' DecodeResponse error msg = ' + e.Message);
  end;
  end;
WriteLog('Bus: ' + Parent.Name + ' Exit DecodeResponse (no params)');
end;

procedure TTCPPollThread.DataRX(Sender: TObject);
begin
WriteLog('Bus: ' + Parent.Name + ' Enter DataRX');
if not fWaitingResponse then Exit;

  // Обработка полученных данных
  fCS.Enter;
  fResponseLeng := TBusTCP(fParent).Connection.RcvBufLeng;
  move(TBusTCP(fParent).Connection.RcvBuf[0], fResponse[0], fResponseLeng);
  fReadComplete := true;
  fCS.Leave;

  WriteLog('Bus: ' + Parent.Name + ' DataRx: fResponse = ' + DataToStr(fResponse, fResponseLeng));
  WriteLog('Bus: ' + Parent.Name + ' Exit DataRX');
end;

procedure TTCPPollThread.Execute;
begin
//Суперцикл потока TCP
while not Terminated do
  begin

  //Система в состоянии таймаута
  if fTimeoutFlag then
    begin
      fSync.Enter;
      ProcessTimeout;
      fSync.Leave;
      continue;
    end;

  //Система закончила чтение
    if fReadComplete then
    begin
      fSync.Enter;
      ProcessReadComplete;
      fSync.Leave;
      continue;
    end;

  //Закончена отправка
    if fSendComplete then
    begin
      fSync.Enter;
      ProcessSendComplete;
      fSync.Leave;
      continue;
    end;


    //Если система не ожидает ответ, не закончила чтение,
    //не завершила отправку и не в состоянии таймаута и при этом не запущен таймер таймаута, то перейти в новое состояние
    if (not fWaitingResponse and not fReadComplete and not fSendComplete and not fTimeoutFlag and not fTimeoutTimer.Active) then
        begin
          if not Terminated then
              begin
              fSync.Enter;
              //fTimeout - флаг означающий, что команду следует повторить, если взведен
              //Значит на прошлую команду не пришел ответ
              EnterNextState(fTimeout);
              fSync.Leave;
              //continue;
              end;
        end;

    sleep(1);
  end;
end;



end.
