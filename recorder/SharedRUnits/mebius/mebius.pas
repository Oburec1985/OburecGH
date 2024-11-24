unit mebius;

interface

uses Windows;
//#include "MebiusDAQ/Iface/idevice.h"

function MAKE_TASKID (core : ULONG; classid : ULONG; index : ULONG; spec : ULONG) : ULONG;

const
//    BCTRL_BALANCEALLCHANS = $FFFFFFFF;
    IID_IMebiusDeviceLink : TGUID = '{79649C0B-33BB-4cfb-9B53-E794B604A24B}';

    UNLIMIT_SIZE        = 1;
    MAX_ADDRESS_SIZE    = 128;
    MAX_BITS_FIELD_SIZE = MAX_ADDRESS_SIZE;

    TYPEIO_MEAS_TASK         = $00001;
    TYPEIO_CALL_COMMAND      = $00002;
    TYPEIO_DATA              = $00003;
    TYPEIO_CYCLOGRAM_COMMAND = $00004;

	  IOCTL_BASE = 0;
	  IOCTL_BASE_MR = 1;

    CLASSID_BASE_TASKS = 200;
    CLASSID_BASE_USER_TASKS = 1000;
    CLASSID_BASE_HOSTS = 1200;
    CLASSID_BASE_SYSLINK_TASKS = 1400;

    // класс задачи управления объектами
    MANAGER_TASK_CLASSID = CLASSID_BASE_TASKS + 4;
    // идентификатор задачи управления объектами
    MANAGER_TASK_ID = (0 shl 30) or (MANAGER_TASK_CLASSID shl 20) or (1 shl 14) or (0);
    // класс комманд используемых для обращения к объектам
    TYPEIO_MANAGER_COMMAND = $00010;

    // Идентификатор класса задачи измерения
    // имеет фиксированное значение для всех типов контроллеров
    MEASUREMENT_TASK_CLASSID = CLASSID_BASE_TASKS + 1;

    // Идентификатор класса задачи передачи данных
    // имеет фиксированное значение для всех типов контроллеров
    DATA_TRANMITER_TASK_CLASSID = CLASSID_BASE_TASKS + 2;

    // Идентификатор класса задачи циклограм
    // имеет фиксированное значение для всех типов контроллеров
    CYCLOGRAM_TASK_CLASSID = CLASSID_BASE_TASKS + 3;

    //MAKE_TASKID
    MEASUREMENT_TASK_ID =   (0 shl 30) or (MEASUREMENT_TASK_CLASSID shl 20)    or (1 shl 14) or (0);
	  DATA_TRANSMIT_TASK_ID	= (0 shl 30) or (DATA_TRANMITER_TASK_CLASSID shl 20) or (1 shl 14) or (0);
 	  CYCLOGRAM_TASK_ID	=     (0 shl 30) or (CYCLOGRAM_TASK_CLASSID shl 20)      or (1 shl 14) or (0);

    // Код ответа на неподдерживаемую команду // CTL_CODE
    IOCTL_MEASTASK_NULL                = (TYPEIO_MEAS_TASK shl 16) or ($0000 shl 14);
    IOCTL_MEASTASK_QUERY_SESSION_STATE = (TYPEIO_MEAS_TASK shl 16) or ($0001 shl 14);
    IOCTL_MEASTASK_DO_CLEANUP          = (TYPEIO_MEAS_TASK shl 16) or ($0002 shl 14);
    IOCTL_MEASTASK_CREATE_DEVICE       = (TYPEIO_MEAS_TASK shl 16) or ($0003 shl 14);

    IOCTL_MEASTASK_INIT_DEVICE         = (TYPEIO_MEAS_TASK shl 16) or ($0004 shl 14);
    IOCTL_MEASTASK_CONNECT_DEVICE      = (TYPEIO_MEAS_TASK shl 16) or ($0005 shl 14);
    IOCTL_MEASTASK_PROGRAMM_DEVICE     = (TYPEIO_MEAS_TASK shl 16) or ($0006 shl 14);

    IOCTL_MEASTASK_CREATE_CHAN         = (TYPEIO_MEAS_TASK shl 16) or ($0007 shl 14);
    IOCTL_MEASTASK_CREATE_CHANNELS     = (TYPEIO_MEAS_TASK shl 16) or ($0008 shl 14);
    IOCTL_MEASTASK_SET_SESSION_ID      = (TYPEIO_MEAS_TASK shl 16) or ($0009 shl 14);

    IOCTL_MEASTASK_PROGRAMM_DEVICE_BIN = (TYPEIO_MEAS_TASK shl 16) or ($000A shl 14);

    IOCTL_MEASTASK_START               = (TYPEIO_MEAS_TASK shl 16) or ($000B shl 14);
    IOCTL_MEASTASK_STOP                = (TYPEIO_MEAS_TASK shl 16) or ($000C shl 14);

    IOCTL_MEASTASK_CALL_COMMAND        = (TYPEIO_MEAS_TASK shl 16) or ($000D shl 14);
    // Программирование задачи измерения.
    // Выполняется после задания и установки всех параметров
    IOCTL_MEASTASK_PROGRAM             = (TYPEIO_MEAS_TASK shl 16) or ($0010 shl 14);
    // Запуск FTP сервера
    IOCTL_MEASTASK_START_FTP           = (TYPEIO_MEAS_TASK shl 16) or ($0011 shl 14);
    // считать положение манифолда.  Только для MIC-170
      IOCTL_CMD_MANIFOLD_POS             = (TYPEIO_MEAS_TASK shl 16) or ($0011 shl 14);
    IOCTL_MEASTASK_ZBALANCE            = (TYPEIO_MEAS_TASK shl 16) or ($0012 shl 14);
    // считать счетчик циклов перемещений манифолда. Только для MIC-170
      IOCTL_CMD_MANIFOLD_COUNTER         = (TYPEIO_MEAS_TASK shl 16) or ($0012 shl 14);
    // загрузка Bios
    IOCTL_MEASTASK_LOAD_BIOS           = (TYPEIO_MEAS_TASK shl 16) or ($0013 shl 14);
    // получить номинал внутреннего сопротивления. Только для MIC-183
      IOCTL_CMD_GET_IN_RESIST            = (TYPEIO_MEAS_TASK shl 16) or ($0013 shl 14);
    IOCTL_MEASTASK_SET_NET_CONFIG      = (TYPEIO_MEAS_TASK shl 16) or ($0014 shl 14);
    IOCTL_MEASTASK_GET_NET_CONFIG      = (TYPEIO_MEAS_TASK shl 16) or ($0015 shl 14);
    // Чтение из i/o ресурса произвольного доступа
    IOCTL_MEASTASK_READ_RAM_RESOURCE   = (TYPEIO_MEAS_TASK shl 16) or ($0016 shl 14);
    // Запись в i/o ресурс произвольного доступа
    IOCTL_MEASTASK_WRITE_RAM_RESOURCE  = (TYPEIO_MEAS_TASK shl 16) or ($0017 shl 14);
    // Получение состояния ресурса i/o
    IOCTL_MEASTASK_QUERY_RAM_RES_STATUS = (TYPEIO_MEAS_TASK shl 16) or ($0018 shl 14);
    // запуск поиска модулей в устройстве
    IOCTL_CMD_SEARCH_DEVICE_INIT = (TYPEIO_MEAS_TASK shl 16) or ($0019 shl 14);
    // получить статус состояния поиска модулей
    IOCTL_CMD_GET_SEARCH_DEVICE_STATE = (TYPEIO_MEAS_TASK shl 16) or ($001A shl 14);
    // возврат списка найденных устройств
    IOCTL_CMD_SEARCH_DEVICE_FINALIZE = (TYPEIO_MEAS_TASK shl 16) or ($001B shl 14);

    // Запрос информации о версии
    IOCTL_MEASTASK_REQUEST_VERSION_INFO = (TYPEIO_MEAS_TASK shl 16) or ($001C shl 14);
    // Настройка виртуальных каналов
    IOCTL_MEASTASK_PROGRAM_VIRTCHANS = (TYPEIO_MEAS_TASK shl 16) or ($001D shl 14);
    // Запуск PTP сервера
    IOCTL_MEASTASK_START_PTP           = (TYPEIO_MEAS_TASK shl 16) or ($001E shl 14);
    // форматирование NAND
    IOCTL_MEASTASK_FORMAT_NAND           = (TYPEIO_MEAS_TASK shl 16) or ($001F shl 14);


    //// CTL_CODE
    CMD_MEASTASK_TEST_NAND        = (TYPEIO_MEAS_TASK shl 16) or ($0001 shl 14) or 1;
    CMD_MEASTASK_TEST_SPI         = (TYPEIO_MEAS_TASK shl 16) or ($0002 shl 14) or 1;
    CMD_MEASTASK_MEASURE_CHAN     = (TYPEIO_MEAS_TASK shl 16) or ($0003 shl 14) or 1;
    CMD_MEASTASK_START_FTP_SERVER = (TYPEIO_MEAS_TASK shl 16) or ($0004 shl 14) or 1;
    CMD_MOTOR                     = (TYPEIO_MEAS_TASK shl 16) or ($0005 shl 14) or 1;
    CMD_ZBALANCE                  = (TYPEIO_MEAS_TASK shl 16) or ($0006 shl 14) or 1;
    CMD_READ_FLASH                = (TYPEIO_MEAS_TASK shl 16) or ($0007 shl 14) or 1;
    CMD_WRITE_FLASH               = (TYPEIO_MEAS_TASK shl 16) or ($0008 shl 14) or 1;
    CMD_MODE_MANIFOLD             = (TYPEIO_MEAS_TASK shl 16) or ($0009 shl 14) or 1;
    CMD_WRITE_DEVEEP              = (TYPEIO_MEAS_TASK shl 16) or ($000A shl 14) or 1;
    CMD_READ_DEVEEP               = (TYPEIO_MEAS_TASK shl 16) or ($000B shl 14) or 1;
    CMD_CLOSE_DEVEEP              = (TYPEIO_MEAS_TASK shl 16) or ($000C shl 14) or 1;
    CMD_OPENREAD_DEVEEP           = (TYPEIO_MEAS_TASK shl 16) or ($000D shl 14) or 1;
    CMD_OPENWRITE_DEVEEP          = (TYPEIO_MEAS_TASK shl 16) or ($000E shl 14) or 1;
    CMD_GET_CALIBR_KOEF           = (TYPEIO_MEAS_TASK shl 16) or ($000F shl 14) or 1;
    CMD_SELFTEST		          = (TYPEIO_MEAS_TASK shl 16) or ($0010 shl 14) or 1;
      //// Заради ДЗ (уже куча миков прошито) но так делать больше нельзя. Только для MIC-170
      IOCTL_CMD_PUT_GAUGE           = (TYPEIO_MEAS_TASK shl 16) or ($0010 shl 14) or 1;

    //// Надо так!!! а не TYPEIO_MEAS_TASK сразу не заметил...
    IOCTL_CMD_GET_CALIBR_KOEF     = (TYPEIO_CALL_COMMAND shl 16) or ($0001 shl 14) or IOCTL_BASE;
    // получение версии ПО из Omap
    IOCTL_CMD_GET_SOFT_VERSION    = (TYPEIO_CALL_COMMAND shl 16) or ($0002 shl 14) or IOCTL_BASE;

    { получить значение с АЦП
    Пример использования
    MIC-183:
    используется в режиме диагностики устройства (на этапе отладки)
    прогружается конфиг, коммутируется канал и вычитывается значение АЦП
    MIC-xxx:
    */}
    IOCTL_CMD_GET_ADC_VALUE       = (TYPEIO_CALL_COMMAND shl 16) or ($0003 shl 14) or IOCTL_BASE;
    // прогрузить блок данных файла метрологии в Omap
    IOCTL_CMD_LOAD_BLOCK_CALIBR   = (TYPEIO_CALL_COMMAND shl 16) or ($0004 shl 14) or IOCTL_BASE;
    // записать файл метрологии в память Flash
    IOCTL_CMD_WRITE_CALIBR_USER   = (TYPEIO_CALL_COMMAND shl 16) or ($0005 shl 14) or IOCTL_BASE;
    // получить блок данных файла метрологии из Omap
    IOCTL_CMD_GET_BLOCK_CALIBR   = (TYPEIO_CALL_COMMAND shl 16) or ($0006 shl 14) or IOCTL_BASE;
    // вычитать файл метрологии из flash памяти
    IOCTL_CMD_READ_CALIBR_USER   = (TYPEIO_CALL_COMMAND shl 16) or ($0007 shl 14) or IOCTL_BASE;
    // вычитать из Flash калибровки во внутреннюю память Omap
    IOCTL_CMD_RELOAD_CALIBR   = (TYPEIO_CALL_COMMAND shl 16) or ($0008 shl 14) or IOCTL_BASE;
    // записать настройки устройства в ini файл на Flash
    IOCTL_CMD_WRITE_DEV_SETTINGS = (TYPEIO_CALL_COMMAND shl 16) or ($0009 shl 14) or IOCTL_BASE;
    // считать настройки устройства в ini файл из Flash
    IOCTL_CMD_READ_DEV_SETTINGS = (TYPEIO_CALL_COMMAND shl 16) or ($000A shl 14) or IOCTL_BASE;
    // считать темп калибровки модулей
    IOCTL_CMD_READ_CLB_MOD_TEMP = (TYPEIO_CALL_COMMAND shl 16) or ($000B shl 14) or IOCTL_BASE;
    // Передача общих настроек контроллера
    IOCTL_CMD_SET_CONTROLLER_PARAMS = (TYPEIO_CALL_COMMAND shl 16) or ($000C shl 14) or IOCTL_BASE;
    // записать регистр управления
    IOCTL_CMD_WRITE_AREG= (TYPEIO_CALL_COMMAND shl 16) or ($0014 shl 14) or IOCTL_BASE;
    // читать датчик температуры
    IOCTL_CMD_READ_TEMP_SENSOR= (TYPEIO_CALL_COMMAND shl 16) or ($0015 shl 14) or IOCTL_BASE;
    // передать параметры манифолда
    IOCTL_CMD_PUT_MANIFOLD = (TYPEIO_CALL_COMMAND shl 16) or ($0016 shl 14) or IOCTL_BASE;
    // получить параметры манифолда
    IOCTL_CMD_GET_MANIFOLD = (TYPEIO_CALL_COMMAND shl 16) or ($0017 shl 14) or IOCTL_BASE;
    // сохранить параметры манифолда
    IOCTL_CMD_SAVE_MANIFOLD = (TYPEIO_CALL_COMMAND shl 16) or ($0018 shl 14) or IOCTL_BASE;
    // восстановить параметры манифолда
    IOCTL_CMD_RESTORE_MANIFOLD = (TYPEIO_CALL_COMMAND shl 16) or ($0019 shl 14) or IOCTL_BASE;
    // ZBalance
    IOCTL_CMD_ZBALANCE_FINISH= (TYPEIO_CALL_COMMAND shl 16) or ($001A shl 14) or IOCTL_BASE;
    IOCTL_CMD_ZBALANCE_GETSTATE= (TYPEIO_CALL_COMMAND shl 16) or ($001B shl 14) or IOCTL_BASE;
    // информация
    IOCTL_CMD_INFO= (TYPEIO_CALL_COMMAND shl 16) or ($001C shl 14) or IOCTL_BASE;
    // передача данных между шинами
    IOCTL_CMD_CROSSBUS_CONVERT = (TYPEIO_CALL_COMMAND shl 16) or ($001D shl 14) or IOCTL_BASE;

    // Синхронная вычитка данных вспомогательных каналов устройства
    // Параметры блока зависят от конкретного устройства
    IOCTL_CMD_READ_AUX_CHANS = (TYPEIO_CALL_COMMAND shl 16) or ($001E shl 14) or IOCTL_BASE;

    IOCTL_CMD_WRITE_COMMUTREG= (TYPEIO_CALL_COMMAND shl 16) or ($001F shl 14) or IOCTL_BASE;
    // запросить дату сборки прошивки
    IOCTL_CMD_READ_FIRMWARE_DATE = (TYPEIO_CALL_COMMAND shl 16) or ($0020 shl 14) or IOCTL_BASE;
  // передать сообщение с данными ModBusTCP в задачу
    IOCTL_CMD_SEND_MBTCP_DATA_REF= (TYPEIO_CALL_COMMAND shl 16) or ($0021 shl 14) or IOCTL_BASE;
  // передать параметры манифолда
    IOCTL_CMD_PUT_MANIFOLD_MOTOR = (TYPEIO_CALL_COMMAND shl 16) or ($0022 shl 14) or IOCTL_BASE;
  // получить параметры манифолда
    IOCTL_CMD_GET_MANIFOLD_MOTOR = (TYPEIO_CALL_COMMAND shl 16) or ($0023 shl 14) or IOCTL_BASE;
  // сохранить параметры манифолда
    IOCTL_CMD_SAVE_MANIFOLD_MOTOR= (TYPEIO_CALL_COMMAND shl 16) or ($0024 shl 14) or IOCTL_BASE;
  // восстановить параметры манифолда
    IOCTL_CMD_RESTORE_MANIFOLD_MOTOR = (TYPEIO_CALL_COMMAND shl 16) or ($0025 shl 14) or IOCTL_BASE;
  // передать сообщение с параметрами ЭДСУ в задачу
    IOCTL_CMD_SEND_EDSU_DATA_REF= (TYPEIO_CALL_COMMAND shl 16) or ($0026 shl 14) or IOCTL_BASE;
  // Считать калибровку тока
    IOCTL_CMD_GET_CALIBR_CURRENT = (TYPEIO_CALL_COMMAND shl 16) or ($0027 shl 14) or IOCTL_BASE;
  // Считать температурные коэф-ты тока
    IOCTL_CMD_GET_CALIBR_TEMP_COEF_CURRENT= (TYPEIO_CALL_COMMAND shl 16) or ($0028 shl 14) or IOCTL_BASE;
  //
    IOCTL_CMD_DIGITAL_INPUT = (TYPEIO_CALL_COMMAND shl 16) or ($0029 shl 14) or IOCTL_BASE;
  //
    IOCTL_CMD_DIGITAL_OUTPUT = (TYPEIO_CALL_COMMAND shl 16) or ($002A shl 14) or IOCTL_BASE;
  //
    IOCTL_CMD_DIGITAL_OUTPUT_MIRROR = (TYPEIO_CALL_COMMAND shl 16) or ($002B shl 14) or IOCTL_BASE;
    IOCTL_CMD_I2C_WRITE= (TYPEIO_CALL_COMMAND shl 16) or ($002C shl 14) or IOCTL_BASE;
    IOCTL_CMD_I2C_READ= (TYPEIO_CALL_COMMAND shl 16) or ($002D shl 14) or IOCTL_BASE;
    IOCTL_CMD_I2C_CONFIG_ALL= (TYPEIO_CALL_COMMAND shl 16) or ($002E shl 14) or IOCTL_BASE;
    IOCTL_CMD_I2C_GET_STATE_ALL= (TYPEIO_CALL_COMMAND shl 16) or ($002F shl 14) or IOCTL_BASE;
    IOCTL_CMD_AK5578_I2C_WRITE= (TYPEIO_CALL_COMMAND shl 16) or ($0030 shl 14) or IOCTL_BASE;
  // Считать калибровку TC
    IOCTL_CMD_GET_CALIBR_TC = (TYPEIO_CALL_COMMAND shl 16) or ($0031 shl 14) or IOCTL_BASE;

  // Циклограмма
    IOCTL_CMD_CYCLOGRAM_SETSTATE = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0000 shl 14);
    IOCTL_CMD_CYCLOGRAM_STARTUPLOAD = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0001 shl 14);
    IOCTL_CMD_CYCLOGRAM_UPLOAD = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0002 shl 14);
    IOCTL_CMD_CYCLOGRAM_STOPUPLOAD = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0003 shl 14);
    IOCTL_CMD_CYCLOGRAM_GETPROPERTY = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0004 shl 14);
    IOCTL_CMD_CYCLOGRAM_STARTDEBUG = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0005 shl 14);
    IOCTL_CMD_CYCLOGRAM_STEPDEBUG = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0006 shl 14);
    IOCTL_CMD_CYCLOGRAM_STOPDEBUG = (TYPEIO_CYCLOGRAM_COMMAND shl 16) or ($0006 shl 14);

    // TYPEIO_DATA используется для передачи данных между шинами // CTL_CODE
    // передача данных
    IOCTL_DATA_PUT = (TYPEIO_DATA shl 16) or ($0001 shl 14);
    // прием данных
    IOCTL_DATA_GET = (TYPEIO_DATA shl 16) or ($0002 shl 14);

type
  // Тип - стандартное возвращаемое значение интерфейсного метода
  MEBRESULT = LONGWORD;

  // Идентификатор класса
  CLASSID = ULONG;

  // Идентификатор задачи, с учетом ее классида и номера объекта
  // всего 32 бита
  //  2 бита, номер ядра
  // 10 бит, CLASSID
  //  6 бит, номер задачи
  // 14 бит, резерв
  TASKID = ULONG;

type
    MebiusIDevice = interface;

    IMebiusDeviceLink = interface
    ['{79649C0B-33BB-4cfb-9B53-E794B604A24B}']
      // @interface IMebiusDeviceLink враппер для переноски IDevice формата мебиус в DevAPI-1 и обратно
      // временная мера
        //  class IMebiusDeviceLink : public IUnknown
        //  {
        //    public:
	      //      virtual HRESULT STDMETHODCALLTYPE GetDevice(mebius_daq::IDevice** ppDev)=0;
        //  };

      function GetDevice(out ppDev : IUnknown) : HRESULT; stdcall;
    end;

  MebiusIDevice = interface
  ['']
{
	/// Инициализация устройства
	virtual MEBRESULT MEBCALLTYPE MEBCALLTYPE Init(
			IChangeDeviceStateCallback* pChangeDeviceStateCallback = 0 ///<[in] коллбэк на изменение состояния устройства
		) = 0;

	/// Деинициализация
	virtual MEBRESULT MEBCALLTYPE Uninit() = 0;

	/// Привязка логического устройства к аппаратному \n
	/// Например, установка сетевого адреса ip для ethernet устройства
	virtual MEBRESULT MEBCALLTYPE Attach(IDeviceInfo * const pLink) = 0;

	/// Сброс привязки логического устройства к аппаратному
	virtual MEBRESULT MEBCALLTYPE Unattach() = 0;

	///  Установка связи с устройством
	virtual MEBRESULT MEBCALLTYPE Connect(
			bool fAsync=false ///< [in] Асинхронный или синхронный вызов функции. true - Синхронный вызов
		)=0;

	///  Отключение от устройства
	virtual MEBRESULT MEBCALLTYPE Disconnect()=0;

	/// Блокирующая функция ожидания подключения устройства
	virtual MEBRESULT MEBCALLTYPE WaitConnecting()=0;

	/// Программирование устройства. \n
	/// Возможен запуск в асинхронном режиме.
	virtual MEBRESULT MEBCALLTYPE Program(
			bool fAsync=true ///< [in] Асинхронный или синхронный вызов функции. true - Синхронный вызов
		)=0;


	/// Блокирующая функция ожидания программирования устройства
	virtual MEBRESULT MEBCALLTYPE WaitProgramming()=0;

	/// @todo
	/// Функция обратная программированию
	/// выполняет сброс целевого устройства
	/// переводит дряйвер в состояние Connected
	///	virtual MEBRESULT MEBCALLTYPE Reset() = 0;




	/// Старт устройства на оцифровку или выдачу данных. /n
	/// Возможен синхронный старт нескольких устройств по едином утриггеру
	virtual MEBRESULT MEBCALLTYPE Start(
			ITrigger* pTrigger=0 ///< [in] Триггер синхронизации старта. При значении параметра 0, старт
													 ///< происходит без применения триггера
		)=0;

	/// Остановка устройства. \n
	/// Возможен запуск в асинхронном режиме.
	virtual MEBRESULT MEBCALLTYPE Stop(
			bool fAsync=false ///< [in] Асинхронный или синхронный вызов функции. true - Синхронный вызов
		)=0;

	/// Блокирующая функция ожидания остановки устройства
	virtual MEBRESULT MEBCALLTYPE WaitStopping()=0;


	/// Получить список каналов устройства
	/// @todo Сделать ссылку на флаги
	virtual MEBRESULT MEBCALLTYPE GetChannels(IChansList** ppChannels, const mebase::ULONG a_nFlags)=0;

	///  Получить список сканов устройства
	virtual MEBRESULT MEBCALLTYPE GetScans(IScansList** ppScans)=0;

	/// Подключение бинарного RAW потока вывода к устройству
	virtual MEBRESULT MEBCALLTYPE LinkOutputStream(
			IPipeOut* pStream,  ///<[in] Ссылка на поток
			mebase::ULONG nReserved     ///<[in] Reserved, например если вдруг потоков много понадобится можно что-то замутить
		)=0;

	/// Получение потока для ввода информации в устройсвто
	virtual MEBRESULT MEBCALLTYPE GetInputStream(
			IPipeOut** ppStream,					///<[in] Ссылка на поток
			mebase::ULONG nReserved=0     ///<[in] Reserved, например если вдруг потоков много понадобится можно что-то замутить
		)=0;

	/// Получить список шин
	virtual MEBRESULT MEBCALLTYPE GetBusList(IBusList** ppBusList) = 0;

	/// Получить шину конкретного типа для которой устройство является хостом
	/// Для получения хостовой шины устройства используйте идентификатор BUSID_HOST (аналогичен BUSID_NULL, аналогичен 0)
	virtual MEBRESULT MEBCALLTYPE GetBus(IBus** pBus,	const mebase::ULONG id) = 0;

	virtual MEBRESULT MEBCALLTYPE GetBusByName(IBus** pBus, mebase::system::mestring& bus_name)=0;

	// По хорошему эти функции запихать бы в XDevice
	// но непонятно как их оттуда доставать...
	///
	virtual MEBRESULT MEBCALLTYPE SetParent(IDevice* pDevice)=0;

	///
	virtual MEBRESULT MEBCALLTYPE LinkChild(IDevice* pDevice)=0;

	virtual MEBRESULT MEBCALLTYPE LinkChangeDeviceStateCallback(IChangeDeviceStateCallback* pCallback)=0;


}
	// Получение адреса устройства
	//virtual MEBRESULT MEBCALLTYPE GetAddress(mestring& msAddress) = 0;
  function GetAddress(msAddress : LPCSTR): HRESULT;

  function GetId(): ULONG;
{
	virtual mebase::ULONG MEBCALLTYPE GetId() const = 0;
/*
	/// Проверить состояние, 0 не установлено, не 0 - установлено
	virtual mebase::ULONG MEBCALLTYPE CheckState(DEVICESTATE state) = 0;
*/
	/// Получить состаояние усройства
	virtual mebase::DEVICESTATE MEBCALLTYPE GetState() const = 0;


	///  Сохранить настройки в хранилище
	virtual MEBRESULT MEBCALLTYPE StoreSettings(mebase::system::IPropStorageOut* pStorage)=0;

	///  Загрузить настройки из хранилища
	virtual MEBRESULT MEBCALLTYPE RestoreSettings(mebase::system::IPropStorageIn* pStorage)=0;

	virtual MEBRESULT MEBCALLTYPE CallCommand(mebase::ULONG a_cmd, mebase::BYTE* pBufIn=NULL, mebase::USHORT a_szIn = 0, mebase::BYTE* pBufOut=NULL, mebase::USHORT a_szOut=0) = 0;

	virtual MEBRESULT MEBCALLTYPE ZBalanceMulti(IChansList* chans, IValueList** vals, IZBalanceCallback* callback = 0) = 0;

	/// Расширенный интерфейс балансировки канлов
	virtual MEBRESULT MEBCALLTYPE ZBalanceMultiEx(
			IChansList* chans,
			IValueList** vals,
			IValueList** status,
			IZBalanceCallback* callback = 0,
			mebase::ULONG reserved = 0
		) = 0;

	/// Трансляция IoControl в хостовую шину
	/// Технически возможна сомостоятельная обработка
	virtual MEBRESULT MEBCALLTYPE IoControl(
		mebase::ULONG nIoControlCode,
		const void* pInBuffer,
		mebase::ULONG nInBufferSize,
		void* pOutBuffer,
		mebase::ULONG nOutBufferSize,
		mebase::ULONG* pnBytesReturned,
		void* reserved = 0
		) = 0;
}

{
	virtual MEBRESULT MEBCALLTYPE IoControlEx(
		mebase::TASKID nReceiverId,  //< id задачи получателя пакета
		mebase::ULONG nIoControlCode,
		const void* pInBuffer,
		mebase::ULONG nInBufferSize,
		void* pOutBuffer,
		mebase::ULONG nOutBufferSize,
		mebase::ULONG* pnBytesReturned,
		void* reserved = 0
		) = 0;
}
  function IoControlEx(nReceiverId : TASKID;  //< id задачи получателя пакета
		                   nIoControlCode : ULONG;
		                   var pInBuffer : pointer;
		                   nInBufferSize : ULONG;
		                   pOutBuffer : pointer;
		                   nOutBufferSize : ULONG;
                       var pnBytesReturned : ULONG;
		                   reserved : Integer = 0): HRESULT; stdcall;

{
	/// Подключение дополнительного потока ввода к устройству
	/// Используется для организации передачи данных к устройствам второго уровня или ниже
	virtual MEBRESULT MEBCALLTYPE LinkInputDevice(
		IDevice* pDevice,  ///<[in] Указатель на дочернее устройство
		mebase::ULONG nReserved     ///<[in] Reserved, например если вдруг потоков много понадобится можно что-то замутить
		)=0;
	/// Отключение дополнительного потока ввода от устройства
	virtual MEBRESULT MEBCALLTYPE UnlinkInputDevice(
		IDevice* pDevice  ///<[in] Указатель на дочернее устройство
		)=0;

	virtual MEBRESULT MEBCALLTYPE GetParent(IDevice** pDevice) const = 0;
}
end;
function CTL_CODE(iType : Smallint;     // Type - Задача, 16 бит
                  iFunction : Smallint; // Function - Номер функции, 12 бит
                  iAccess : Byte;       // Access - 2 бита
                  iMethod : Byte        // Method - 2 бита
                  ): ULONG;

implementation

//    CTL_CODE( Type, Function, Method, Access ) (
//    ((Type) << 16) | ((Access) << 14) | ((Function) << 2) | (Method)  )
function CTL_CODE(iType : Smallint;     // Type - Задача, 16 бит
                  iFunction : Smallint; // Function - Номер функции, 12 бит
                  iAccess : Byte;       // Access - 2 бита
                  iMethod : Byte        // Method - 2 бита
                  ): ULONG;
begin
  Result := (iType shl 16) or (iFunction shl 14) or (iAccess shl 2) or (iMethod);
end;

//#define MAKE_TASKID(core, classid, index, spec) \
//    ((mebase::TASKID) (\
//			((mebase::ULONG)(core) << 30) | \
//			((mebase::ULONG)(classid) << 20) | \
//			((mebase::ULONG)(index) << 14) | \
//			((mebase::ULONG)(spec)) \
//		))
function MAKE_TASKID (core : ULONG; classid : ULONG; index : ULONG; spec : ULONG) : ULONG;
begin
  Result := (core shl 30) or (classid shl 20) or (index shl 14) or (spec);
end;

//#define TASKID_GET_CLASS(taskid) (mebase::ULONG)((0x03FF00000&(taskid))>>20)
function TASKID_GET_CLASS (taskid : ULONG) : ULONG;
begin
  Result := ($03FF00000 and taskid) shr 20;
end;

//#define TASKID_GET_CORE(taskid) (mebase::ULONG)((0xC0000000&(taskid))>>30)
function TASKID_GET_CORE (taskid : ULONG) : ULONG;
begin
  Result := ($C0000000 and taskid) shr 30;
end;

end.
