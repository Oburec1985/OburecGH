{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для управления аппаратным измерительным  }
{ устройством                                                         }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}
unit device;

interface

uses Windows, modules;

const
   //Свойства устройств
   DEVPROP_NAME =                0; // Название устройства
   DEVPROP_DESC =                1; // Описание устройства
   DEVPROP_IFACENAME =           2; // Название интерфейса
   DEVPROP_IFACEDESC =           3; // Описание интерфейса
   DEVPROP_SERNUM =              4; // Серийный номер устройства
   DEVPROP_IFACESERNUM =         5; // Серийный номер интерфейса
   DEVPROP_MAX_MODULE_COUNT =    6; // Максимально возможное число модулей в устройстве
   DEVPROP_MODULE_BY_SLOT =      7; // Получить ссылку на созданный модуль по номеру слота
   DEVPROP_MODULE_BY_INDEX =     8; // Получить ссылку на созданный модуль по индексу
   DEVPROP_INITIALIZED =         9; // Статус устройста - "проинициализировано"
   DEVPROP_TYPE =               10; // Тип устройства
   DEVPROP_SYNC_START_ENABLED = 11; // Триггерный старт разрешен
   DEVPROP_ERROR_CODE =         12; // Код ошибки операций инициализации
   DEVPROP_ALIAS =              13; // Юзерское имя девайса
   DEVPROP_IFACE =              14; // Интерфейс
   DEVPROP_SLOT_NAME =          15; // Название слота
   DEVPROP_CONTEXT =            16;
   DEVPROP_INT =                17;
   DEVPROP_INT_DATA =           18;
   DEVPROP_STATE =              19;
   DEVPROP_DEBUG_STATE =        20;
   DEVPROP_STATE_WORD =         21; // Слово специализированного состояния устройства
                                    // Использование зависит от конкретного устройства
                                    // Для CCMC012COMWDInterface, CCMR032v4EthernetInterface
                                    // является состоянием циклограммы

type
   IDevice = interface
   ['{B167658E-567C-4766-AA4D-00F74BF02BEB}']
      {Получить значение свойства по идентификатору}
      function GetDeviceProperty( const a_dwPropertyID: DWORD;
                                  var Value: OleVariant;
                                  const lSubPropertyIndex: longint;
                                  const dwReserved: DWORD): HRESULT; stdcall;
      {Установить значение свойства по идентификатору}
      function SetDeviceProperty( const a_dwPropertyID: DWORD;
                                  var Value: OleVariant;
                                  const lSubPropertyIndex: longint;
                                  const dwReserved: DWORD): HRESULT; stdcall;
   end;

  ICrateDevice = interface (IDevice)
  ['{81E13778-781B-4538-8CF1-A651DFDAC344}']
      function _PutModule(pModule: IModule; const nSlot: integer): HRESULT; stdcall;
      function iReadFlash( const nSlot: Integer; nAddr: Integer; nSize: Integer; var pData: PChar {byte* pData}): HRESULT; stdcall;
      function iWriteFlash(const nSlot: Integer; nAddr: Integer; nSize: Integer; var pData: PChar {byte* pData}): HRESULT; stdcall;
      function iResetDSP(const nSlot: Integer): HRESULT; stdcall;
      function iWriteModuleReg(const nSlot: Integer; nAddr: Integer; var pData: PChar {byte* pData}): HRESULT; stdcall;
      function iReadModuleReg( const nSlot: Integer; nAddr: Integer; var pData: PChar {byte* pData}): HRESULT; stdcall;
      //virtual HRESULT STDMETHODCALLTYPE iCallCommandModule(int a_nSlot, int a_nCommand, int a_nSizeIn, byte* pBufIn, int a_nSizeOut, byte* pBufOut)=0;
      function iCallCommandModule(const a_nSlot: Integer; a_nCommand: Integer; a_nSizeIn: Integer;
                                  var pBufIn: PChar; a_nSizeOut: Integer; var pBufOut: PChar): HRESULT; stdcall;
  end;

  IEntity = interface
  ['{D403A886-504D-4510-9F84-33DE74359A2A}']
  end;

implementation

end.
