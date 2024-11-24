unit DevAPI_const;
//////////////////////////////////////////////////////////////////////
//  Файл: Const.h PlgSDK-v3.3 (03.10.2018)
//  Компилятор: MVC++6.0
//
//  Зарезервированные диапазоны PROP:
//  0x3200-0x33ff Злобин,
//  0x3400-0x35ff Каринский,
//  0x3600-0x36ff Мельников,
//  0x3700-0x38ff Кротких,
//  0x3900-0x3aff Кравцов,
//  0x5000-0x51ff Кубасов
//  (c) НПП "Мера" 2001-2011г.
//////////////////////////////////////////////////////////////////////

interface

// Ошибки
type errors = (
      ERROR_NOERROR= 0,
    // Global Errors
      ERROR_ANY_ERROR= 1,										// Error without description (yet)
      ERROR_MEMORY_ALLOC= 2,
      ERROR_TOO_MANY_SELECTORS= 3,
      ERROR_METHOD_NOT_INHERITED= 4,							// Function not implemented yet
      ERROR_REENTERING_IRQ= 5,
    // Devices/Modules Errors
      ERROR_DEVICE_NOT_FOUND= 9,
      ERROR_DEVICE_UNKNOWN= 10,								// При создании ошибочный тип устройства
      ERROR_INCORRECT_DEVICE_ID= 11,
      ERROR_DEVICE_NOT_PRESENT= 12,
      ERROR_MODULE_NOT_PRESENT= 13,
      ERROR_BIOS_CODE_NOT_FOUND= 14,
      ERROR_FLEX_CODE_NOT_FOUND= 15,
      ERROR_BAD_FLEX_CODE= 16,
      ERROR_TOO_MANY_DEVICES= 17,
      ERROR_BIOS_NOT_LOADED= 18,
      ERROR_FLEX_NOT_LOADED= 19,
      ERROR_DEVICE_NOT_INITIALISED= 20,
      ERROR_DEVICE_NOT_PROGRAMMED= 21,
      ERROR_DEVICE_NOT_ACTIVATED= 22,
      ERROR_DEVICE_NOT_INTERFACE= 23,
      ERROR_DEVICE_NOT_TRANSFER= 24,
      ERROR_DEVICE_NOT_RESPOND= 25,
      ERROR_DEVICE_ALREADY_ACTIVATED= 26,
      ERROR_DEVICE_ALREADY_PROGRAMMED= 27,
      ERROR_DEVICE_ALREADY_INITIALISED= 28,
      ERROR_BIOS_ALREADY_LOADED= 29,
      ERROR_WINDRIVER_HANDLE= 30,
      ERROR_WINDRIVER_INCORRECT_VERSION= 31,
      ERROR_CREATE_EVENT= 32,
      ERROR_OVERLAPPED= 33,
      ERROR_KPOPEN= 34,
      ERROR_DMALOCK= 35,
      ERROR_IFACE= 36,
      ERROR_INI_FILE= 37,
      ERROR_CC_NULL= 38,
      ERROR_MODULE_NULL= 39,
      ERROR_HANDLE_NULL= 40,
      ERROR_FLAG_BIOS_LOAD= 41,
      ERROR_MODULE_BIOS_CODE_NULL= 42,
      ERROR_DEVICE_NULL= 43,
      ERROR_ENABLE_IRQ= 44,
      ERROR_MAX_SIZE= 45,
      ERROR_SINGLE_RUNNING= 46,								// Задача синхронного ввода продолжается
      ERROR_WAIT_RDY= 47,
      ERROR_TIMEOUT_MANAGE= 48,
      ERROR_MEASURE_FREQ_MODULE= 49,
    // Scan Errors
      ERROR_INCORRECT_SCAN_ID= 50,
      ERROR_UNKNOWN_SCAN_TYPE= 51,
      ERROR_CANT_CREATE_SCAN= 52,
      ERROR_SCAN_NULL= 53,
    // Channel Errors
      ERROR_CHAN_NOT_EXIST= 58,
      ERROR_INCORRECT_CHAN_ID= 59,
      ERROR_READBUFFER_OVERFLOW= 60,
      ERROR_BAD_BUFFER_PTR= 61,
      ERROR_TRIGGER_NOT_DEFINED= 62,
      ERROR_CHAN_NULL= 63,
    // TEST TMI
      ERROR_TEST_DM= 64,
      ERROR_TEST_PM= 65,
      ERROR_TEST_DM_PCI= 66,
      ERROR_TEST_PM_PCI= 67,
      ERROR_TEST_IRQ= 68,
      ERROR_TEST_IO= 69,
      ERROR_CLSID_NULL= 70,
      ERROR_PTRANSFORMER_NULL= 71,
      ERROR_TEST_ERROR= 72,
      ERROR_TRANSFER= 73,
      ERROR_ILLEGAL_MODULE_TYPE= 74,
      ERROR_CANT_READ_MODULE_FLASH= 75,
      ERROR_CALLCOMMAND_TIMEOUT_USER= 76,
      ERROR_GETINTERNALMEM= 77,
      ERROR_GETINTERNALMEMHEAP= 78,
      ERROR_TRIGGER_FAULT= 79,
      ERROR_CMD_TIMEOUT= 80,
    // Common errors
      ERROR_DB_EMPTY= $2001,
      ERROR_UNKOWN_FORMAT= $2002,
      ERROR_STORAGE_FULL= $2003,
      ERROR_INSUFFICIENT_SPACE= $2004,
      ERROR_WD_CARDREG= $2005,
      ERROR_LCR_READ_WRITE= $2006,
      ERROR_ITEM_NOT_PRESENT= $2007,
      ERROR_BIOS_START_UPLOAD= $2008,
      ERROR_BIOS_STOP_UPLOAD= $2009,
      ERROR_FLEX_START_UPLOAD= $2010,
      ERROR_FLEX_STOP_UPLOAD= $2011,
      ERROR_INVALID_ARGUMENT= $2100,
    // Properties Errors
      ERROR_BAD_PROPERTY_ID= $FFF0,							// Неверный тип свойства нет в устройстве
      ERROR_BAD_PROPERTY= $FFF1,								// Неверное значение устанавливаемого свойства
      ERROR_R_ONLY_PROPERTY= $FFF2,							// Свойство только для чтения
      ERROR_W_ONLY_PROPERTY= $FFF3,							// Свойство только для записи
    // Неверно отконфигурирован ресурс PCI Plug-n-Play, требуется перепрошить м/с PCI интерфейса
      ERROR_BAD_PCI_RESOURCE= $FFF4,
      ERROR_DEVICE_BUSY= $FFF5,
      ERROR_REGISTER_CARD= $FFF6,
      ERROR_EXTERNAL_DEVICE= $FFF7,
      ERROR_LAST_ERROR= $FFF8
   );

// Команды, посылаемые плате
type VIBRO_CC = (
    // Общие команды
      TEST_CC= 0,												// Testing on BIOS loaded
      FLEX_START_LOADING_CC= 1,
      FLEX_OUT_BUFFER_CC=	2,
      FLEX_STOP_LOADING_CC= 3,
      START_SCAN_MAIN_CC= 4,									// Старт назначенной группы каналов
      STOP_SCAN_MAIN_CC= 5,									// Стоп назначенной группы каналов
      RESET_FIFO_CC= 6,										// Инициализация FIFO
      OUT_START_FLAG_CC= 8,									// Формирование строба группового запуска
      GET_PROPERTY_CC= 9,										// Получить свойство
      SET_PROPERTY_CC= 10,									// Задать свойство
      READ_BOOT_EEPROM= 11,
      WRITE_BOOT_EEPROM= 12,
      LOCK_BOOT_EEPROM= 13,
      ERASE_BOOT_EEPROM= 14,
      TEST_IRQ= 15,
    // Команды для устройства
      TEST_IRQ_CC= 20,										// Тестирования прерываний от ADSP к PC
      INIT_CC= 21,									// Инициализация устройства. Команда выполняется сразу после загрузки BIOS
      SEND_2_CONT_REG_CC= 22,									// Передать значения на управляющий регистр
      NEW_CONFIG_WORD_CC= 23,									// Предназначена для посылки слова в регистр RG3 платы
      PAUSE_TIMER_CC= 24,			// Приостанавливает задачу вывода на ЦАП. Необходимо для программирования АЦП т.к. запись в
                                    // АЦП и в ЦАП производится через один порт
      RESTORE_TIMER_CC= 25,									// Восстанавливает задачу вывода на ЦАП
      ENA_EXT_ADC_CC= 26,										// Разрешить внешний сброс АЦП
      RESET_ADC_CC= 27,										// Сброс АЦП (для восстановления межэтажной синхронизации)
      RESET_DAC_CC= 27,										// Сброс ЦАП
    // Команды для скана
      RESET_CHAN_LIST_CC= 40,
      SET_CHAN_LIST_CC= 41,									// Задать группу каналов
      RESET_TRIGGER_CC= 42,									// Сброс триггера
      CONFIG_TRIGGER_CC= 43,									// Конфигурация триггера
      DIS_FLOOR_SYNC_CC= 44,									// Запретить синхронизацию этажей
    // Команды для канала
      SET_GRID_CC= 50,										// Установить сетку частот
      SET_FREQ_CC= 51,										// Программирует частоту ввода
      SET_SYNTHEZ_CC= 52,										// Установка синтезатора частот
      SET_RANGE_CC= 52,										// Амплитудного диапазона
      SEND_BALANCE_CC= 53,									// Передать значения на балансировочный ЦАП
      CONFIG_RAW_CC= 58,										// Задать параметры канала
      CONFIG_DBL_CC= 59,										// Установить задачу удвоения амплитуды
      CONFIG_MIX_CC= 60,										// Установить задачу обработки перегруза
      CONFIG_TIMING_CC= 61,									// Установить задачу обработки перегруза
      CONFIG_IRQPC_CC= 62,									// Установить задачу выдачи прерываний в PC
      GET_FINAL_FLAG_CC= 63,									// Получить адрес готовности блока данных
      PROGRAM_MARK_CC= 64,									// Установить задачу обработки служебной информации
      CONFIG_AOUT_CC= 66,										// Установить задачу выдачи прерываний в PC
      GET_AOUT_DESC_CC= 67,									// Получить адрес готовности блока данных
      DAC_REPLY_CC= 68,										// Назначить сквозные каналы
      STOP_DAC_REPLY_CC= 69,									// Снять задачу сквозных каналов
      D_IN_CC= 70,											// Цифровой ввод
      D_OUT_CC= 71,											// Цифровой вывод
      SEND_CALIBR_CC= 72,										// Передать значения на калибровочный ЦАП
      INIT_DAC_TASK_CC= 73,									// Инициализирует задачу вывода данных на ЦАП
      START_DAC_TASK_CC= 74,									// Запускает задачу вывода данных на ЦАП
      STOP_DAC_TASK_CC= 75,									// Останавливает задачу вывода данных на ЦАП
      ASSIGN_TAR_CC= 80,
      SET_K_CALIBR_CC= 81,
      SET_CALIBR_DAC_CC= 82,
      CONFIG_STAT_CC= 83,
      SET_K_BALANCE_CC= 84,
      SET_ZR_OFFSET_CC= 85,
      GET_ZR_OFFSET_CC= 86,
      GET_K_CALIBR_CC= 87,
      GET_HARM_CC= 88,
      GET_MAX_MIN_CC= 89,
      APPLY_SEV_TASK= 99
    );

const
    // Расширение типов каналов
    CHEXT_AIN    = 0;
    CHEXT_AOUT   = 1;
    CHEXT_DIN    = 2;
    CHEXT_DOUT   = 3;
    CHEXT_UTSIN  = 4;
    CHEXT_UTSOUT = 5;
    CHEXT_TECHIN = 6;

// Типы устройств (в т.ч. модулей)
type TType = (
      UNDEF_TYPE= 0,
    // Channel
      UNDEF_CHTYPE= 1,
    // Крейт-контроллеры
      CRATE_CC_CHTYPE= 2,
      CRATE_EPP_CHTYPE= 3,
      CRATE_USB_CHTYPE= 4,
      CRATE_E1_CHTYPE= 5,
      CRATE_PCI_CHTYPE= 6,
    // Каналы модулей
      MOD_MC114_CHTYPE= 7,
      MOD_MC201_CHTYPE= 8,
      MOD_MC212_CHTYPE= 9,
      MOD_MC227_CHTYPE= $a,
      MOD_MC451_CHTYPE= $b,
      MOD_LC10X_CHTYPE= $c,
      M2408_AIN_CHTYPE= $0d,									// Каналы типа "аналоговый ввод М2408"
      M2408_AOUT_CHTYPE= $0e,								// Каналы типа "аналоговый вывод М2408"
      M2408_DIN_CHTYPE= $0f,									// Каналы типа "цифровой ввод М2408"
      M2408_DOUT_CHTYPE= $10,								// Каналы типа "цифровой вывод М2408"
      MAC_AIN_CHTYPE= $11,
      M21156_AOUT_CHTYPE= $12,								// Каналы типа "аналоговый вывод М21156"
      M2081_CHTYPE= $13,
      FILE_CHTYPE= $14,										// Файловый канал
      MOD_MC40X_CHTYPE= $15,
      CC_DIGIN_CHTYPE= $16,
      MOD_MC402_CHTYPE= $17,									// MC-402
      MOD_MC402_DIN_CHTYPE= $18,								// Цифровые входные каналы 402
      MOD_LC302_CHTYPE= $19,									// LC302
      MOD_MC118_CHTYPE= $1a,									// MC118
      NI6143_AIN_CHTYPE= $1b,								// Каналы типа "аналоговый ввод"
      M3408_AIN_CHTYPE= $1c,
      MX208_CHTYPE= M3408_AIN_CHTYPE,
      M2428_CHTYPE= $1d,
      BK269X_AIN_P1_L_CHTYPE= $1e,							// Microphone Input, Low Noise
      MOD_MC4003_CHTYPE= $1f,								// MC-4003
      MC118_TIN_CHTYPE= $20,
      MIC0185_AIN_CHTYPE= $21,
      MIC0185_TIN_CHTYPE= $22,
      SMBINCC_CHTYPE= $23,
      MOD_MB232_CHTYPE= $24,
      MOD_MB464_CHTYPE= $25,
      MOD_MB132_CHTYPE= $26,
      MIC140_AIN_CHTYPE= $27,
      MIC140_TIN_CHTYPE= $28,
      MOD_MR2081H_CHTYPE= $29,
      ME808_DIG_CHTYPE= $2A,
      ME808_UIN_CHTYPE= $2B,
      ME808_IIN_CHTYPE= $2C,
      ME808_RISOLATIN_CHTYPE= $2D,
      ME808_RLOADIN_CHTYPE= $2E,
      ME808_OVERLOADIN_CHTYPE= $2F,
      MEBIUS_CHTYPE= $30,
      MOD_MB2081_CHTYPE= $31,
      MB045_CHTYPE= $32,
      MB132_CHTYPE= $33,
      MB2081_CHTYPE= $34,
      MB232_CHTYPE= $35,
      MB464_CHTYPE= $36,
      MB2082_CHTYPE= $37,
      MR045_CHTYPE = $38,
      MOD_MR405_CHTYPE= $39,
      MEBIUS_MIC170_CHTYPE= $3A,
      MEBIUS_MIC183_CHTYPE = $3B,
      MR405_CHTYPE= $40,
      MBCRATE_CHTYPE= $41,
      MRCRATE_CHTYPE= $42,
      SMBSPI_CHTYPE= $44,
      MO_CHTYPE= $70,
      RMS_CHTYPE= $71,
      PIKPIK_CHTYPE= $72,
      FREQ_CHTYPE= $73,
      HARM_CHTYPE= $74,
      AHARM_CHTYPE= HARM_CHTYPE,
      PHARM_CHTYPE= $75,
      IRIGB_CHTYPE= $76,
      MI170_AIN_CHTYPE= $77,
      MI170_TIN_CHTYPE= $78,
      ME033_CHTYPE= $79,
      ME033_SINGLE_CHTYPE= $7A,
      MEBIUS_MIC304_CHTYPE = $7B,
      SEVRS_CHTYPE= $7C,
      SEVRSME_CHTYPE= $7D,
      MEBIUS_MT185_CHTYPE = $7E,
      MOD_MR452_CHTYPE= $7F,
    // Обобщенные типы
      SEV_CHTYPE= $80,
      M2408RCE_SEV_CHTYPE= $81,
      MOD_MC302_CHTYPE= $82,									// MC-302
      MOD_MC110_CHTYPE= $83,									// MC-110
      PID_CHTYPE=	$84,										// PID
      MOD_ME320_CHTYPE= $85,									// ME-320
      CC_PWR_CHTYPE= $86,									// CC PWR
      GNOM_CHTYPE= $87,
      MOD_ME330_CHTYPE= $88,									// ME-330
      MOD_ME230_CHTYPE= $89,									// ME-230
      MOD_ME340_CHTYPE= $8A,									// ME-340
      MOD_ME325_CHTYPE= $8B,                                 // ME-325
      DSOUNDIN_CHTYPE= $90,
      ME908_1_AIN_CHTYPE= $92,
      N2690_AIN_CHTYPE= $93,
      MR_300_CHTYPE= $94,									// Системный канал MR-300
      MR_300_LCH_CHTYPE= $95,								// Узел обработки в логическом канале
      MX132_CHTYPE= $96,										// MX-132
      OPC_CHTYPE= $97,										// OPC Output/Input Channel
      MX224_CHTYPE= $98,								        // MX-224
      MX240_CHTYPE= $99,									    // MX-240
      MX240AMP_CHTYPE= $9A,									// MX-240 Amplifier
      MX340_CHTYPE= $9B,                                     // MX-340
      MX340AMP_CHTYPE= $9C,                                  // MX-240 Amplifier
      MR202_CHTYPE= $9D,                                     // MR-202
      MX310_CHTYPE= $9E,                                     // MX-310
      MX310AMP_CHTYPE= $9F,                                  // MX-210 Amplifier
      MX020_CHTYPE= $a0,                                     // MX-020
      MX228_CHTYPE= $a1,                                     // MX-228
      GAUGE_CMN_AIN_CHTYPE= $c0,								// Датчики
      GAUGE_TEDS_AIN_CHTYPE= $c1,

      ME812_DIG_CHTYPE= $C2,
      ME812_U_CHTYPE= $C3,
      ME812_I_CHTYPE= $C4,
      ME812_RISOL_CHTYPE= $C5,
      ME812_RLOAD_CHTYPE= $C6,
      ME812_OVER_CHTYPE= $C7,
      GAUGE_STRAIN_CHTYPE= $C8,
      SERV_CHTYPE= $C9,

      // NI_ National Instruments
      NI_AI_CHTYPE = $CA, // Аналоговый ввод

    // -----------  Всех предыдущих типов каналов д.б. не более 255 -------------
      AIN_CHTYPE= $0100,										// Каналы аналогового ввода всех типов модулей и плат
      AOUT_CHTYPE= $0200,									// Каналы аналогового вывода всех типов модулей и плат
      DIN_CHTYPE= $0400,										// Каналы цифрового ввода всех типов модулей и плат
      DOUT_CHTYPE= $0800,									// Каналы цифрового вывода всех типов модулей и плат
      TECH_CHTYPE= $1000,									// Технологические каналы всех типов модулей и плат
      UTS_CHTYPE= $1100,										// Канал привязки к глобальному времени
    // Типы по состоянию каналов.
    // Использовать по лог. "или" с предыдущими.
    // Если не указан тип занятости, то по умолчанию трактуется как ALL_CHTYPE
      AVL_CHTYPE= $2000,										// Незадействованные каналы указанного типа
      USED_CHTYPE= $4000,									// Задействованные каналы указанного типа (прописанные в Device)
      ALL_CHTYPE= LongWord(AVL_CHTYPE) or LongWord(USED_CHTYPE),					// Все каналы указанного типа
    // Устройство
      CRATE_TYPE= $4001,
    // Крейт-контроллеры
      CRATE_ISA_TYPE= $4002,
      CRATE_EPP_TYPE= $4003,
      CRATE_USB_TYPE= $4004,
      CRATE_E1_TYPE= $4005,
      CRATE_E1_2_TYPE= $4006,
      CRATE_PCI_TYPE= $4007,
      CRATE_COMM_TYPE= $4008,
      COMM_TYPE= $4009,
      M2408_IFACE_TYPE= $400A,
      MC011_IFACE_TYPE= $400B,
      MC011PC_IFACE_TYPE= $400C,
      MC011ITE_IFACE_TYPE= $400D,
      E1_M20100_PLX9052_IFACE_TYPE= $400E,
      E1_2_M20100_PLX9052_IFACE_TYPE= $400F,
    // Модули
      MOD_MC114_TYPE= $4010,
      MOD_MC201_TYPE= $4011,
      MOD_MC212_TYPE= $4012,
      MOD_MC227_TYPE= $4013,
      MOD_LC301_TYPE= $4014,
      MOD_MC451_TYPE= $4015,
      MOD_MC451V1_TYPE= $4016,
      MOD_MC451GV1_TYPE= $4017,
      MOD_LC101_TYPE= $4018,
      MOD_LC102H_TYPE= $4019,
      MOD_LC102HT_TYPE= $401A,
      MOD_LC102C_TYPE= $401B,
      MOD_MC227C_TYPE= $401C,
      MOD_MC227K_TYPE= $401D,
      MOD_MC227U_TYPE= $401E,
      MOD_MC227T_TYPE= $401F,
      MOD_MC227W_TYPE= $4020,
      MOD_MC227R_TYPE= $4021,
      MOD_MC201A_TYPE= $4022,
      MOD_LC302_TYPE= $4023,
      MOD_MC401_TYPE= $4024,
      MOD_MC402_TYPE= $4025,
      MOD_MC403_TYPE= $4026,
      MOD_MC801_TYPE= $4027,
      MOD_MAC_TYPE= $4028,
      MOD_MC114W31_TYPE= $4029,
      MOD_MC212W60_TYPE= $402A,
      MOD_LC227C_TYPE= $402B,								// LC-227
      MOD_LC227K_TYPE= $402C,
      MOD_LC227U_TYPE= $402D,
      MOD_LC227T_TYPE= $402E,
      MOD_LC227W_TYPE= $402F,
      MOD_LC227R_TYPE= $4030,
      MOD_MC227UP_TYPE= $4031,
      MOD_MC114W40_TYPE= $4032,
      MOD_DIGINCC_TYPE= $4033,
      MOD_MC227U_8_TYPE= $4034,
      MOD_MC4003_TYPE= $4035,
      MOD_SEV_TYPE= $4036,
      MOD_LC451F_TYPE= $4037,								// LC-451
      MOD_LC451S_TYPE= $4038,
      MOD_MC118_TYPE= $4039,									// MC-118
      MOD_MC118W50_TYPE= $403A,
      MOD_MC227S_TYPE= $403B,								// MC-227S
      MOD_MC212V10_TYPE= $403C,								// MC-212 v10
      MOD_MC302_TYPE= $403D,									// MC-302V1
      MOD_MC110V1_TYPE= $403E,								// MC-110V1
      MOD_MC114V40C1_TYPE= $403F,							// MC-114V40 C1
      MOD_MC114V40C2_TYPE= $4040,							// MC-114V40 C2
      MOD_PID_TYPE= $4041,									// PID
      MOD_PWRCC_TYPE= $4042,									// CC PWR
      MOD_MC116V10_TYPE= $4043,
      MOD_MC405_TYPE= $4044,
      MOD_MC302V4_0_TYPE= $4045,
      MOD_MC110V2_0_TYPE= $4046,								// MC-110V2
      MOD_MC406_TYPE= $4047,									// MC-406
      MOD_GNOM_TYPE= $4048,
      MOD_MC408_TYPE= $4049,
      MOD_MC114V5_TYPE= $404A,
      MOD_MIC0183_TYPE= $404B,
      MOD_MIC0184_TYPE= $404C,
      MOD_MC114V6_TYPE= $404D,
      MOD_MIC0185_TYPE= $404E,
      MOD_MIC0185V2_TYPE= $404F,
      MOD_MR114_TYPE= $4050,
      MOD_MC114V9_TYPE= $4051,
      MOD_SMBINCC_TYPE= $4052,
      MOD_MR405_TYPE= $4053,
      MOD_MR404_TYPE= $4054,
      MOD_MC212V20_TYPE= $4055,
      MOD_MB132_TYPE = $4056,
      MOD_MB232_TYPE= $4057,
      MOD_MB464_TYPE= $4058,
      MOD_MR406_TYPE= $4059,
      MOD_MIC140_96_TYPE= $405A,
      MOD_MR2081H_TYPE= $405B,
      MOD_ME808_TYPE= $405C,
      MOD_MC114V9C2_TYPE= $405D,
      MOD_MR114V2_TYPE= $405E,
      MOD_MC114UP_TYPE= $405F,
      MOD_SCALAR_TYPE= $4060,
      MOD_MR451_TYPE= $4061,
      MOD_MT132_TYPE= $4062,
      MOD_MT232_TYPE= $4063,
      MOD_IRIGB_TYPE= $4064,
      MOD_MR114V3_TYPE= $4065,
      MOD_MR114V3_1_TYPE= $4066,
      MOD_ME808V3_TYPE= $4067,
      MOD_MT464_TYPE= $4068,
      MOD_MR114V4_1_TYPE= $4069,
      MOD_MT230_TYPE= $406A,
      MOD_MT320_TYPE= $406B,
      MOD_MB2081_TYPE = $406C,
      MOD_MR114V4_TYPE= $406D,
      MOD_MT224_TYPE= $406E,
      MOD_MR2087_TYPE= $406F,
      MOD_MB132_MEB_TYPE= $4070,
      MOD_MB2081_MEB_TYPE= $4071,
      MOD_MB232_MEB_TYPE= $4072,
      MOD_MB464_MEB_TYPE= $4073,
      MOD_MB2082_MEB_TYPE= $4074,
      MOD_MB2355_MEB_TYPE= $4075,
      MOD_MR212_TYPE= $4076,
      MOD_MI170_TYPE= $4077,
      MOD_ME033_TYPE= $4078,
      MOD_ME053_TYPE= $4079,
      MOD_MR114V4C1_TYPE= $407A,
      MOD_MR405_MEB_TYPE = $407B,
      MOD_MR114_MEB_TYPE = $407C,
      MOD_MR302_TYPE= $407D,
      MOD_MR451_MEB_TYPE = $407E,
      MOD_MB132_SPW_MEB_TYPE = $407F,
      MOD_MB232_SPW_MEB_TYPE = $4080,
      MOD_MB464_SPW_MEB_TYPE = $4081,
      MOD_ME812_TYPE= $4082,
      MOD_MT320V2_TYPE= $4083,
      MOD_MT212_TYPE= $4084,
      MOD_ME812V2_TYPE= $4085,
      MOD_MR401_TYPE= $4086,
      MOD_MT240_TYPE= $4087,
      MOD_MT310_TYPE= $4088,
      MOD_MT183_TYPE= $4089,
      MOD_MT464v5_TYPE = $408A,
      MOD_MT132V6_TYPE = $408B,
      MOD_MT232V7_TYPE= $408C,
      MOD_MR2355_TYPE= $408D,
      MOD_SMBSPI_TYPE= $408E,
      MOD_MR402_TYPE= $408F,
      MOD_MR406_MEB_TYPE= $4090,
      MOD_MR114V2_MEB_TYPE = $4091,
      MOD_MR401_MEB_TYPE = $4092,
      MOD_MR114V5_TYPE= $4093,
      MOD_MB142_MEB_TYPE= $4094,
      MOD_MR202_TYPE= $4095,
      MOD_MB152_MEB_TYPE= $4096,
      MOD_MB405_MEB_TYPE= $4097,
      MOD_MR227_TYPE= $4098,
      MOD_MR212V4_TYPE= $4099,
      MOD_MR114V5_1_TYPE= $409A,
      MOD_MS304_MEB_TYPE= $409B,
      MOD_MT224V4_TYPE= $409C,
      MOD_MT181_TYPE= $409D,
      MOD_MC227R1_TYPE= $409E,
      MOD_MC227R2_TYPE= $409F,
      MOD_MC227R3_TYPE= $40A0,
      MOD_MC227R4_TYPE= $40A1,
      MOD_MC227R5_TYPE= $40A2,
      MOD_MC227K1_TYPE= $40A3,
      MOD_MC227K2_TYPE= $40A4,
      MOD_MC227K3_TYPE= $40A5,
      MOD_MC227K11_TYPE= $40A6,
      MOD_MC227K21_TYPE= $40A7,
      MOD_MC227K31_TYPE= $40A8,
      MOD_MC227U1_TYPE= $40A9,
      MOD_MC227U2_TYPE= $40AA,
      MOD_MC227U3_TYPE= $40AB,
      MOD_MC227S1_TYPE= $40AC,
      MOD_MC227C1_TYPE= $40AD,
      MOD_MC227C2_TYPE= $40AE,
      MOD_MS142_MEB_TYPE= $40AF,
      MOD_MR820_MEB_TYPE = $40B0,
      MOD_MT212V3_TYPE= $40B1,
      MOD_MB629_MEB_TYPE= $40B2,
      MOD_MT227R_TYPE= $40B3,
      MOD_MS685_MEB_TYPE= $40B4,
      MOD_MIC1170_MEB_TYPE= $40B5,
      MOD_MT227UP_TYPE= $40B6,
      MOD_MIC140_48_TYPE= $40B7,
      MOD_MR2355_MEB_TYPE = $40B8,
      MOD_MS202_MEB_TYPE = $40B9,
      MOD_MS405_MEB_TYPE = $40BA,
      MOD_MS451_MEB_TYPE = $40BB,
      MOD_MB628_MEB_TYPE = $40BC,
      MOD_MB2087v2_MEB_TYPE = $40BD,
      MOD_MR114V4_MEB_TYPE = $40BE,
      MOD_MR402_MEB_TYPE = $40BF,
      MOD_MS340_MEB_TYPE = $40C0,
      MOD_MS152_MEB_TYPE = $40C1,
      MOD_MR227R2_TYPE= $40C2,
      MOD_MT1500_TYPE = $40C3,
      MOD_SEVRS_TYPE= $40C4,
      MOD_MIC140_48V2_TYPE= $40C5,
      MOD_ME415_TYPE= $40C6,
      MOD_MT212V4_TYPE= $40C7,
      MOD_MR404_MEB_TYPE= $40C8,
      MOD_ME808_MEB_TYPE= $40C9,
      MOD_ME812V2_1_TYPE= $40CA,
      MOD_MR227R3_TYPE= $40CB,
      MOD_MR227R4_TYPE= $40CD,
      MOD_MR227R1_TYPE= $40CE,
      MOD_MR227R5_TYPE= $40CF,
      MOD_MR227R6_TYPE= $40D0,
      MOD_MR227U1_TYPE= $40D1,
      MOD_MR227U2_TYPE= $40D2,
      MOD_MR227U3_TYPE= $40D3,
      MOD_MR227UP_TYPE= $40D4,
      MOD_MR227C1_TYPE= $40D5,
      MOD_MR227C2_TYPE= $40D6,
      MOD_MR227S1_TYPE= $40D7,
      MOD_MR227K1_TYPE= $40D8,
      MOD_MT232V8_TYPE= $40D9,
      MOD_ME105_MEB_TYPE= $40DA,
      MOD_ME819_MEB_TYPE= $40DB,
      MOD_ME825_MEB_TYPE= $40DC,
      MOD_MR114V4C1_MEB_TYPE= $40DD,
      MOD_ME415_MEB_TYPE= $40DE,
      MOD_MB234_MEB_TYPE= $40DF,
      MOD_MR114V5_MEB_TYPE= $40E0,
      MOD_MB236_MEB_TYPE= $40E1,
      MOD_MB632_MEB_TYPE= $40E2,
      MOD_MIC140_96V2_TYPE= $40E3,
      MOD_MT224V5_TYPE= $40E4,
      MOD_MR202_MEB_TYPE= $40E5,
      MOD_MR629_MEB_TYPE= $40E6,
      MOD_MR302_MEB_TYPE= $40E7,
      MOD_MR227K1_MEB_TYPE= $40E8,
      MOD_MR227R6_MEB_TYPE= $40E9,
      MOD_MR452_MEB_TYPE = $40EA,
      MOD_ME824_MEB_TYPE = $40EB,
      MOD_ME330_MEB_TYPE = $40EC,
      MOD_MS632_MEB_TYPE = $40ED,
      MOD_MS402_MEB_TYPE = $40EE,
      MOD_MR114V4C2_TYPE= $40EF,
      MOD_MR114V4C2_MEB_TYPE= $40F0,
      MOD_MR604_MEB_TYPE = $40F1,
      MOD_ME504_MEB_TYPE = $40F2,
      MOD_MT340_TYPE= $40F3,
      MOD_MR452_TYPE= $40F4,
      MOD_MC227R7_TYPE= $40F5,
      MOD_SERV_TYPE= $40F6,
      MOD_MS682_MEB_TYPE = $40F7,
      MOD_MR2355V2_TYPE= $40F8,
      MOD_MR2355V2_MEB_TYPE= $40F9,
      MOD_MR2087_MEB_TYPE = $40FA,
    // Сканы
      SCAN_201_TYPE= $4100,
      SCAN_212_TYPE= $4101,
      SCAN_451_TYPE= $4102,
      SCAN_114_TYPE= $4103,
      SCAN_227_TYPE= $4104,
      SCAN_301_TYPE= $4105,
      SCAN_40X_TYPE= $4106,
      SCAN_CLOCK_TYPE= $4107,
      SCAN_MAC_TYPE= $4108,
      SCAN_DIGINCC_TYPE= $4109,
      SCAN_SEV_TYPE= $410A,
      SCAN_118_TYPE= $410B,
      SCAN_DIGITIN402_TYPE= $410C,
      SCAN_GNOM_TYPE= $410D,
      SCAN_SMBINCC_TYPE= $410E,
      SCAN_PID_TYPE= $410F,
      SCAN_MB132_TYPE= $4110,
      SCAN_MB232_TYPE= $4111,
      SCAN_MB464_TYPE= $4112,
      SCAN_MIC140_TYPE= $4113,
      SCAN_MR2081H_TYPE= $4114,
      SCAN_ME808_TYPE= $4115,
      SCAN_SCALAR_TYPE= $4116,
      SCAN_DOUT_TYPE= $4117,
      SCAN_IRIGB_TYPE= $4118,
      SCAN_MEBIUS_TYPE= $4119,
      SCAN_MB045_TYPE= $411A,
      SCAN_MI170_TYPE= $411B,
      SCAN_ME033_TYPE= $411C,
      SCAN_MR045_TYPE= $411D,
      SCAN_MR405_TYPE= $411E,
      SCAN_MR114_TYPE= $411F,
      SCAN_MR451_TYPE= $413B,
      SCAN_MR212_TYPE= $413C,
      SCAN_ME812RLOAD_TYPE= $413D,
      SCAN_ME812OVER_TYPE= $413E,
      SCAN_SMBSPI_TYPE= $413F,
      SCAN_MR202_TYPE= $4140,
      SCAN_SEVRS_TYPE= $4141,
      SCAN_SERV_TYPE= $4142,
    // Доп. кк
      MC012COM_IFACE_TYPE= $4120,							// КК MC-012
      MC012USB_IFACE_TYPE= $4121,
      USB_FTDI_TYPE= $4122,
      USB_FTDI_81_TYPE= $4123,
      MC021USB_IFACE_TYPE= $4124,
      MIC0183_TYPE= $4125,
      MIC0184_TYPE= $4126,
      ETHERNET_81_TYPE= $4127,
      MC031ETHERNET_IFACE_TYPE= $4128,
      MIC0185_TYPE= $4129,
      MR031ETHERNET_IFACE_TYPE= $412A,
      MC032ETHERNET_IFACE_TYPE= $412B,
      MR032ETHERNET_IFACE_TYPE= $412C,
      MIC140_96_TYPE= $412D,
      MIC140_96ETHERNET_IFACE_TYPE= $412E,

      MEBIUS_DEVICE_ETHERNET_IFACE_TYPE= $412F,
      ETHERNET_MEBIUS_TYPE= $4130,
      MR035ETHERNET_IFACE_TYPE= $4131,
      MB045ETHERNET_IFACE_TYPE= $4132,
      SCAN_MB2081_TYPE= $4133,
      MB045_TYPE= $4134,
      MB045_DEVICE_ETHERNET_IFACE_TYPE= $4135,
      MIC170_TYPE= $4136,
      MIC1200_TYPE= $4137,
      ME033_ETHERNET_IFACE_TYPE= $4138,
      MR045_TYPE = $4139,
      MR045_DEVICE_ETHERNET_IFACE_TYPE = $413A,
      MR032V4ETHERNET_IFACE_TYPE= $413B,
      MIC140_48_TYPE= $413C,
      MIC140_48ETHERNET_IFACE_TYPE= $413D,
      MIC140_48V2_TYPE= $413E,
      MIC140_48V2ETHERNET_IFACE_TYPE= $413F,

      MEBIUS_BASED_DEVICE_TYPE= $4400,
      MEBIUS_BASED_ETHERNET_IFACE_TYPE= $4401,

      MB045_DEVICE_TYPE= $4402,
      MB045_ETHERNET_IFACE_TYPE= $4403,
      MB023_DEVICE_TYPE= $4404,
      MIC170_DEVICE_TYPE= $4405,
      MR045_DEVICE_TYPE = $4406,
      MR045_ETHERNET_IFACE_TYPE = $4407,
      MIC1100_DEVICE_TYPE= $4408,
      MBCRATE_DEVICE_TYPE= $4409,
      MRCRATE_DEVICE_TYPE= $440A,
      MIC170V3_DEVICE_TYPE= $440B,
      MIC140_DEVICE_TYPE= $440C,
      MIC200M_TYPE = $440D,
      MIC183_DEVICE_TYPE = $440E,
      MRCRATEV2_DEVICE_TYPE= $440F,
      MIC1150_DEVICE_TYPE= $4410,
      MIC304_DEVICE_TYPE= $4411,
      MR2507_DEVICE_TYPE= $4412,
      MIC170V4_DEVICE_TYPE= $4413,
      MIC224_DEVICE_TYPE= $4414,
      MIC236_DEVICE_TYPE= $4415,
      MIC170V4_1_DEVICE_TYPE= $4416,
      MIC140_96V2_TYPE= $4417,
      MIC140_96V2ETHERNET_IFACE_TYPE= $4418,
      MIC170V4_2_DEVICE_TYPE= $4419,
      MIC170V5_DEVICE_TYPE= $441A,
      MR2083_DEVICE_TYPE= $441B,
      MIC850_DEVICE_TYPE= $441C,
      MT185_DEVICE_TYPE= $441D,
      MIC170V4_3_DEVICE_TYPE= $441E,

      NI6375_DEVICE_TYPE = $441F,
      NI4353_DEVICE_TYPE = $4420,
      NI6358_DEVICE_TYPE = $4421,
      NI4357_DEVICE_TYPE = $4422,
      NI4497_DEVICE_TYPE = $4423,
      NI4330_DEVICE_TYPE = $4424,
      NI6255_DEVICE_TYPE = $4425,
      NI6363_DEVICE_TYPE = $4426,

    // Платы ISA
      M1081_TYPE=	$5000,
      M1181_TYPE=	$5001,
      M1070_TYPE=	$5002,
    // Платы PCI/PXI
      M3408_TYPE=	$800,
      MX208_TYPE=	M3408_TYPE,
      M2408_TYPE=	$6080,
      M2081_TYPE=	$6081,
      M2181_TYPE=	$6082,
      M2091_TYPE=	$6100,
      M2070_TYPE=	$6083,
      M20100_TYPE= $6084,
      M21156_TYPE= $6085,
      MB_CPCI_TYPE= $6086,
      M2501_TYPE= $6087,
      M20100_PLX9052_TYPE= $6089,
      MAC300_TYPE= $608a,
      MR012_TYPE= $608b,
      MC012_TYPE= $608c,
      MR015_TYPE= $608d,
      MC021USB_TYPE= $608E,
      M2408_02_TYPE= $608F,
      DX_AUDIO_TYPE= $6090,
      M2428_TYPE= $6110,
      M2502_TYPE= $6111,
      MR2081_TYPE= $6114,
      MX132_TYPE= $6120,
      OPCDEV_TYPE= $6121,
      MX224_TYPE = $6130,
      MX240_TYPE = $6131,
      MX340_TYPE = $6132,
      MX310_TYPE = $6133,
      MX020_TYPE = $6134,
      ME918_HUB_TYPE = $6137,   // Контроллер усилителей ME918 на шине RS-485
      MX228_TYPE = $6138,
      MC_MDP_TYPE= $6180,
      M2081COMMUT_TYPE= $6182,
      WX753_TYPE= $6183,
      CYPRESS_TYPE= $3042,
      PLX9050_TYPE= $9050,
      ME_SPI_MDP_TYPE= $7001, // Тип MDP (MERA SPI)
      ME_485_MDP_TYPE= $7002, // Тип MDP (ME-918 - RS-485)
      ME_HUB_MDP_TYPE= $7003, // Тип MDP (RS-485 - SPI - HUB)
    // Внешние устройства с RS/USB-интерфейсом
      MAC_TYPE,
    // Пассивные внешние устройства (диапазон номеров 0x7000 ... 0x7fff)
      MP07_TYPE= $7000,
      ME908_TYPE= $7001,
      MM202_TYPE= $7010,										// Субмодуль для MC201
      NI6143_TYPE= $70c0,									// Плата NI
    // Пассивные внешние устройства с панелью управления
      BK2690_TYPE= $7200,									// Bruel&Kjaer Nexus Conditioning Amplifier Type 2690-2693
    // Пассивные внешние устройства крейтового типа
      MOD_ME320F_TYPE= $7400,								// ME-320F
      MOD_ME320L_TYPE= $7401,								// ME-320L
      MOD_ME320LLU_TYPE= $7402,								// ME-320LLU
      MOD_ME320LLI_TYPE= $7403,								// ME-320LLI
      MOD_ME320V8F_TYPE= $7404,								// ME-320v8(F)
      MOD_ME320V8L_TYPE= $7405,								// ME-320v8(L)
      MOD_ME320V9F_TYPE= $7406,								// ME-320v9(F)
      MOD_ME320V9L_TYPE= $7407,								// ME-320v9(L)
      MOD_ME320L10_TYPE= $7408,								// ME-320(L10)
      MOD_ME320L16_TYPE= $7409,								// ME-320(L16)
      ME320_TYPE=	$740F,										// ME-320
      MOD_ME330_TYPE=	$7410,									// ME-330
      MOD_ME230_TYPE=	$7411,									// ME-230
      MOD_ME340_TYPE=	$7412,									// ME-340
      MOD_ME230V3_TYPE= $7413,								// ME-230v3
      MOD_ME320F2_TYPE= $7414,								// ME-320F
      MOD_ME230V5_TYPE= $7415,                               // ME-230v5
      MOD_ME230V6_TYPE= $7416,                               // ME-230v6
      MOD_ME230V4_TYPE= $7417,                               // ME-230v4
      MOD_ME230V7_1_TYPE= $7418,                             // ME-230v7_1
      MOD_ME325_TYPE= $7419,                                 // ME-325v1
      MOD_ME325V2_TYPE= $741A,                               // ME-325v2
      MOD_ME230V10_TYPE= $741B,                              // ME-230v10
      MOD_ME340V5_TYPE= $741C,                               // ME-340v5
    // Датчики (диапазон номеров 0x8000 ... 0x8fff)
      GAUGE_COMMON_TYPE= $8000,
      GAUGE_UNI_TYPE= $8001,
      GAUGE_TEDS_TYPE= $8002,
    // Крейт RXI (диапазон номеров 0x9000-0x9fff)
      CRATE_RXI1_TYPE= $9000,								// Полная версия: служ.слот+16слотов
      CRATE_RXI2_TYPE= $9001,								// Укороченная версия: 16слотов
      CRATE_MIC017_2_TYPE= $9002,
      CRATE_MIC254_TYPE= $9003,
      MIC800_TYPE= $9004,
      MIC850_TYPE= $9005,
      CRATE_PXI_TYPE= $9006,
      MBP804_TYPE= $9007,

      MR012COM_IFACE_TYPE= $9010,							// KK MR-012 COM
      MR012USB_IFACE_TYPE= $9011,							// KK MR-012 USB
      MR015USB_IFACE_TYPE= $9012,							// KK MR-015 USB
      MR015COM_IFACE_TYPE= $9013,
    //
      TYPE_TEMP,												// device, with cleared FLASH (new device)
    // HUBs
      TYPE_HUB= $1000,
      TYPE_MC_HUB= $1001,
      TYPE_ROOT= $2000,
      TYPE_ROOT_ISA= LongWord(TYPE_HUB) or LongWord(TYPE_ROOT),
      TYPE_ROOT_PCI,
      TYPE_ROOT_EPP,
      TYPE_ROOT_COM,
      TYPE_ROOT_ETHERNET,
      TYPE_ROOT_USB,
      LAST_TYPE= $7FFFFFFF);

    // Проверка на принадлежность устройства классу внешних пассивных модулей
    //#define IS_EXT_AMPLIF(_Type) ((_Type&0xf000) == 0x7000 && (_Type!=NI6143_TYPE))
    // Проверка на принадлежность устройства классу первичных преобразователей
    //#define IS_GAUGE(_Type) ((_Type&0xf000) == 0x8000)
    // Проверка на принадлежность устройства классу плат/модулей ввода/вывода
    //#define IS_DAQ_DEVICE(_Type) (!IS_EXT_AMPLIF(_Type) && !IS_GAUGE(_Type))

const
    TYPE_EXT_NONE = 0;
    TYPE_EXT_AMPLIF = 1;
    TYPE_ME918 = 2;
    TYPE_ME908_1 = 3;
    // Состояния каналов, устройств
    STATE_PRESENT = $00000001;							// Present, but may by offline
    STATE_ONLINE = $00000002;								// with active connection
    STATE_INITIALIZED = $00000004;						// loaded with task-specific BIOS
    STATE_PROGRAMMED = $00000100;
    STATE_RUN = $00000200;
    STATE_BIOS_CHANGED = $00010000;						// Сменился биос - требуется перегрузить
    STATE_FLEX_CHANGED = $00020000;						// Сменился flex - требуется перегрузить
    STATE_CHAN_CHANGED = $00040000;						// Сменился состав каналов
    STATE_FS_CHANGED = $00080000;							// Сменилась частота дискретизации
    STATE_BUF_CHANGED  = $00100000;						// Сменились параметры буфера - требуется перевыделить
    STATE_CONNECTING   = $00200000;						// Процесс соединения

    // Свойства
    type TProperty = (
      PROP_NAME= $1000,							// R/W Имя объекта (напр. "M2408")
      PROP_INFO= $1001,									// Информация об объекте (например, lpf-ON, hpf- OFF)
    // ----------------------   Свойства устройств  ------------------------
      DEVICE_DESC_PRP= $1002,					// Описание устройства
      REV_DEV= $1003,							// Номер версии устройства
      PROP_REV= REV_DEV,					        // Номер версии устройства
      SN_DEV= $1004,								// Серийный номер устройства (рекомендуется исп. PROP_SN)
      PROP_TYPE= $1005,							// Тип устройства. Для канала тип модуля
      PROP_TYPE_EXT= $1006,						// Классификация типов (см. например константу CHEXT_AIN)
      CHAN_CNT_DEV= $1007,						// Количество каналов данного типа на устройстве (тип указан в поле Index)
      PROP_CHAN_CNT= CHAN_CNT_DEV,
      PROP_HADC_SRC= $1008,						// Источник тактовой частоты измерительной части
      PROP_BIOS_PATH= $1009,						// Путь к файлу BIOS устройства
      PROP_CALIBR_DIR= $100A,					// Путь к Calibr  устройства
      PROP_BIOS_SIZE= $100B,						// Размер BIOS устройства
      PROP_FLEX_PATH= $100C,						// Путь к файлу FLEX устройства
      PROP_FLEX_SIZE= $100D,						// Размер файла FLEX устройства
      PROP_BIOS_DIR= $100E,						// Диррекория BIOS
      PROP_TRIGGER= $100F,						// R/W; Триггерный запуск 0-нет, 1-TTL IN, 2-Analog IN
      PROP_TRIG_SRC= $1010,						// R/W; Управляющий канал
      PROP_TRIG_LEVEL= $1011,					// R/W; Уровень срабатывания (для TTL - 0/1, для аналог. в вольтах
      PROP_INPUT_MODE= $1012,					// R/W; Режим подключения входных каналов (диф/недиф/icp), индекс с 0
      PROP_INPUT_MODE_STR= $1013,                // R;   Строковое значение предыдущего свойства
      PROP_ROUTE= $1014,							// R/W; Адрес устройства. Cсылка на TDeviceRoute структуры TDevice
      PROP_ME_SPI_CTRL= $1015,					// R; Устройство поддерживает шину ME-SPI (Me908, Me908-1), TRUE/FALSE
      MODULE_CNT_DEV= $1016,						// Тип устройства
      IRQ_DEV= $1017,							// Номер прерывания
      PROP_IRQ_COUNTER= $1018,					// Число прерываний от платы
      IRQ_CUR_INDEX_DEV= $1019,					// Текущий индекс прерываний
      PORT_DEV= $101A,
      PORT_CUR_INDEX_DEV= $101B,
      PROP_SLOT= $101C,
      PROP_ADDRESS= $101D,
      TIMER_PERIOD_DEV= $101E,
      IRQ_SCAN_DEV= $101F,						// Номер прерывания по индексу
      IRQ_SCAN_COUNT_DEV= $1020,					// Кол-во прерываний
      PORT_SCAN_DEV= $1021,
      PORT_SCAN_COUNT_DEV= $1022,
      ARG_C_PRP= $1023,							// Число слов в буфере переменных ADSP
      ARG_PTR_PRP= $1024,						// Адрес буфера переменных в ADSP
      FS_DEV= $1025,
      SWITCH_PRP= $1026,
      PROP_MAX_MODULE_COUNT= $1027,
      PROP_MODULE= $1028,
      PROP_CHAN_SERNO= $1029,
      PROP_CHAN_TYPE_SIGNAL= $102A,
      PROP_CHAN_ISOUTPUT= $102B,
      PROP_OWNER_NAME= $102C,                     // Имя владельца
      PROP_IFACE_DEVICE_NUM= $102D,
      PROP_DEV_FREQ_BACKPLANE= $102E,
      PROP_DEV_DEFAULT_FREQ_BACKPLANE= $102F,
      PROP_DEVICE_NUM= $1030,
      PROP_DEV_SYNC_CLK= $1031,
      PROP_DEV_IFACE= $1032,
      PROP_SEV_CHAN_ENABLE= $1033,
      PROP_DIGIN_CHAN_ENABLE= $1034,
      PROP_SYNC_START= $1035,                      // Старт по уровню
      PROP_SYNC_START_LEVEL= $1036,
      PROP_SYNC_START_ENABLED= $1037,
      PROP_IFACE_FREQ_CLK= $1038,
      PROP_IFACE_ISREADBUFINIRQ= $1039,
      PROP_DEVICE_ALIAS= $103A,
      PROP_DEV_VARS_RING0= $103B,
      PROP_DEV_VARS_RING0_SIZE= $103C,
      PROP_MODE_LPT= $103D,
      PROP_DELAY_LPT= $103E,
      PROP_DEV_NAME_SLOT= $103F,
      PROP_PWR_CHAN_ENABLE= $1040,
      PROP_START_ENABLE= $1041,
      PROP_STOP_ENABLE= $1042,
      PROP_CHAN_BUFF_LOST= $1043,
      PROP_CHAN_BUFF_LOST_COUNT= $1044,
      PROP_CHAN_BUFF_HEADER= $1045,
      PROP_GNOM_CHAN_ENABLE= $1046,
      PROP_DEVICE_CHANNEL= $1047,
      PROP_TEDS_SUPPORT= $1048,                   // поддерживает ли устройство датчики TEDS
      PROP_TEDS_OWNER= $1049,
      PROP_TEDS_INTF= $104A,                      // получить интерфейс для работы с датчиком
                        // возвращает ITEDSChan, который работает через MDP девайса (номер выхода указывается в индексе)
    // MODULE
      PROP_MOD212_FILTER= $104B,
      PROP_MOD212_MODE= $104C,
      PROP_MOD212_REFMODE= $104D,
      PROP_MOD212_CALIBRCHAN= $104E,
      PROP_MOD212_CALIBRTYPE= $104F,
      PROP_MOD212_DECIMAT= $1050,
      PROP_MOD212_CONNECTION= $1051,
      PROP_MOD212_OFFSET= $1052,
      PROP_MOD212_DAC= $1053,
      PROP_MOD212_TESTLINE= $1054,
    // PID
      PROP_PID_X= $1055,
      PROP_PID_Y= $1056,
      PROP_PID_E= $1057,
    // COMM Device
      PROP_COMM_BAUD= $1058,
      PROP_COMM_DATA= $1059,
      PROP_COMM_STOP= $105A,
      PROP_COMM_PARITY= $105B,
      PROP_COMM_INQUEUE= $105C,
      PROP_COMM_OUTQUEUE= $105D,
      PROP_ITEM_SIZE= $105E,
    // Common
      PROP_DESC= $105F,							// Описание объекта (например, модуль для тензоизмерений)
      PROP_EXPL_PARAM_NAME= $1060,				// R/W, Имя эксплуатационного параметра, BSTR
      PROP_EXPL_PARAM= $1061,                    // R/W, Значение эксплуатационного параметра, BSTR
      PROP_RTSI_SEV= $1062,
      PROP_RTSI_CLK= $1063,
      PROP_RTSI_SYNC= $1064,
      PROP_BALANCE_NSAMPL= $1065,				// R/W Кол-во отсчетов для балансировки
      PROP_FIRMWARE= $1066,
      PROP_STOR_BATT_STAT= $1067,
      PROP_IS_PRESENT_STOR_BATT= $1068,
      PROP_UTS_TYPE= $1069,
    // PID
      PROP_PID_MODE_DSTY= $106A,
      PROP_PID_LEVEL_DSTY= $106B,
    //
      PROP_MOD212_CONNECTION_STR= $106C,
      PROP_MOD212_RANGE_STR= $106D,
      PROP_MOD212_SENS4= $106E,
    // -----------------------    Свойства каналов  ------------------------
      ID_CHAN= $3000,							// R; ChanID
      PROP_ID= ID_CHAN,
      INDEX_CHAN= $3001,                         // R; Номер в модуле/плате; 0-based;
      PROP_INDEX= INDEX_CHAN,
    // *** ACQUISITION ***
      CONTINOUS_CHAN= $3002,						// R/W; Признак непрерывного ввода (default TRUE)
      ASYNC_CHAN= $3003,							// R/W; Асинхронная работа (default TRUE)
      PROP_ASYNC= ASYNC_CHAN,
      DATA_TYPE_CHAN= $3004,						// R/W; Тип входной/выходной величины
      PROP_DATA_TYPE= DATA_TYPE_CHAN,
      PROP_DATA_TYPE_STR= $3005,					// R; Тип входной/выходной величины, строка
      PROP_CHAN_WORDLENGTH= $3006,				// R; разрядность канала
      PROP_CHAN_ON= $3007,						// R/W; (long) Активность канала 0=выкл, 1=вкл
      PROP_CHAN_TICK_COUNT= $3008,				// R/W; (long) Число отсчетов на канал при усреднении
    // Events/timing
      ASYNCHRO_PRP= $3009,
    // Частотный диапазон измерений
      PROP_FREQ_UNITS= $300A,				// R/W; (long) Перечисление испльзуемых единиц измерения частоты дискретизации
                          // и частотного диапазона, индекс от 0.
      PROP_FREQ_UNITS_STR= $300B,			// R; (строка) Единицы измерения частоты дискретизации и частотного диапазона
      PROP_CHAN_FREQ= $300C,					// R/W; Частота дискретизации, Гц
      PROP_CHAN_FREQ_COUNT= $300D,					// R; (long) Количество частот дискретизации
      PROP_FREQ_INDEX= $300E,
      PROP_CHAN_FREQ_STR= $300F,						// R; (строка) Информация о частотах дискретизации в единицах PROP_FREQ_UNITS
      PROP_FREQ_RANGE_MIN= $3010,         // R; (double) Нижняя граница частотного диапазона измерений в единицах PROP_FREQ_UNITS
      PROP_FREQ_RANGE_MIN_STR= $3011,     // R; (строка) Нижняя граница частотного диапазона измерений в единицах PROP_FREQ_UNITS
      PROP_FREQ_RANGE_MAX= $3012,		 // R; (double) Верхняя граница частотного диапазона измерений в единицах PROP_FREQ_UNITS
      PROP_FREQ_RANGE_MAX_STR= $3013,     // R; (строка) Верхняя граница частотного диапазона измерений в единицах PROP_FREQ_UNITS
      PROP_CHAN_T_OVER= $3014,            // R/W; Период перетирки данных, в отсчетах.
      PROP_T_OVER= PROP_CHAN_T_OVER,
      PROP_CHAN_T_BLOCK= $3015,           // R/W; Время развертки (период поступления новых порций данных), в отсчетах.
      PROP_T_EVENT= PROP_CHAN_T_BLOCK,
      PROP_ADSP_FIFO_SIZE= $3016,                // R/W; Размер FIFO канала в ADSP
      PROP_CHAN_HANDLER= $3017,                  // R/W; Обработчик сообщений
      PROP_CHAN_HANDLER_DATA= $3018,				// R/W; Данные юзера для обработчика сообщений
      PROP_HANDLER_PARAM= $3019,
      PROP_CHAN_HANDLER_ALTERN= $301A,					// R/W; 1 - Признак работы в MR-300
      PROP_CHAN_INFO= $301B,								// RO;  Получение информации о аппаратных настройках канала
      PROP_MARK= $301C,									// R/W; Внесение отметки "Начало отсчета" по цифровому вводу
      PROP_IRQ_COUNT= $301D,								// R; Число буферов, пришедших на 0 кольцо из ADSP (long)
      PROP_BLOCKS_TO_CLIENT= $301E,						// R; Число буферов, отправленных клиенту (long)
      PROP_BLOCKS_FROM_ADSP_LONG= $301F,					// пришедших на 0 кольцо из ADSP (long)
    // Raw buffer access
      RAWBUF_BEGIN_CHAN= $3020,							// Указатель на буфер "сырых" данных
      RAWBUFTX_BEGIN_CHAN= $3021,						// Указатель на буфер "сырых" данных
      RAWBUF_SIZE_CHAN= $3022,							// Размер буфера "сырых" данных (не меньше, чем MIN_BUFFER_PRP)
      RAWBUF_TAIL_CHAN= $3023,							// Индекс новой порции данных в буфере
      RAWBUF_HEAD_CHAN= $3024,							// Текущий индекс в буфере
      RAWBUF_PREC_CHAN= $3025,							// Разрядность буфера "сырых" данных
      PROP_ADSP_LATENCY= $3026,							// Задержка от момента готовности блока до вычитки его в ХОСТ
      PROP_START_OFFSET= $3027,							// R; Время нулевого отсчета по отношению к общему старту измерений
                                              // В сигма-дельта АЦП соотв. размеру вн. буфера т.е. для M2408 значение = (-33/Fs)
                                              // double, сек
    // *** ANALOG INPUT/OUTPUT PROPERTY ***
      PROP_CHAN_TRANSFORMER= $3028,
      PROP_CHAN_SWITCH= $3029,							// R/W; Состояние входного/выходного коммутатора
      PROP_CHAN_SWITCH_STR= $302A,						// R; Строковый вариант предыдущего свойства
      PROP_INPUT_VALID= $302B,        // R; Признак того, что вход канала подключен к внешнему сигналу и подключение корректно
                                       // S_OK = подключение корректно, S_FALSE = предупреждение, E_FAIL = ошибка
      PROP_INPUT_INVALID_STR= $302C,  // R; Строка с сообщением об ошибке/предупреждении
      PROP_SUBCHAN_ON= $302D,         // R/W; long; Активировать встроенный усилитель заряда/тензо/др.
    /////////////////// Свойства входного амплитудного диапазона измерительного канала ////////////////////
      RANGE_COUNT_CHAN= $302E,        // R; Количество вх. амплитудных диапазонов
      RANGE_CHAN= $302F,            // R/W; Номинальный амплитудный диапазон канала в номинальных единицах измерения (см. ниже)
                                     // ПРИМЕР:
                                     // "10.0", "0.01", "0.00001"
      PROP_RANGE=RANGE_CHAN,
      PROP_RANGE_EXACT= $3030,      // Реальный входной амплитудный диапазон в номинальных единицах измерения (см. ниже)
      INDEX_RANGE_CHAN= $3031,      // R/W; текущий амплитудный диапазон, индекс
      PROP_RANGE_INDEX=INDEX_RANGE_CHAN,
      RANGE_CHAN_STR= $3032,                     // R; амплитудный диапазон канала в произвольных единицах измерения, строки
                            // Для перечисления всех значений используем a_lSubPropertyIndex (или Index)
                            // Считывать диапазоны пока не вернет VT_EMPTY
                            // ПРИМЕР:
                            // "10.0 В", "10.0 мВ", "10.0 мкВ"
      RANGE_CHAN_MIN= $3033,						// R; верхняя граница амплитудного диапазона канала
      RANGE_CHAN_MAX= $3034,						// R; нижняя граница амплитудного диапазона канала
      RANGE_CHAN_UNITS= $3035,					// R; (LPSTR) единицы измерения для диапазона (устаревший вариант)
      PROP_Y_UNITS= $3036,						// R/W; (long) Размерность по оси ординат, текущее значение, индекс от 0
      PROP_RANGE_UNITS= PROP_Y_UNITS,			    // R/W; (long) Текущие единицы измерения входного ампл. диапазона, индекс от 0
      PROP_Y_UNITS_STR= $3037,                   // R; Размерность по оси ординат, строка
      PROP_RANGE_UNITS_STR= PROP_Y_UNITS_STR,		// R; Список единиц измерения входного амплитудного диапазона, строка
                            // Для перечисления всех значений используем a_lSubPropertyIndex (или Index)
                            // Считывать строки пока не вернет VT_EMPTY
                            // ПРИМЕР:
                            // "кВ", "В", "мВ", "мкВ"
      PROP_RANGE_UNITS_MULT= $3038,              // R; Множитель единицы измерения (по отношению к номинальной), double
                            // Номинальная единица измерения имеет множитель = 1.0
                          // Для перечисления всех значений используем a_lSubPropertyIndex (или Index)
                          // Количество значений совпадает с к-вом значений свойства PROP_RANGE_UNITS_STR
                          // Индексы соответсвтуют индексам в свойстве PROP_RANGE_UNITS_STR
                          // ПРИМЕР:
                          // 0.001, 1.0, 1000.0, 1000000.0
                          // Если пользователь выбрал единицей измерения мВ (В - номинальная единица),
                          // то значение ампл. диапазона 10.0 В (от свойства RANGE_CHAN) умножаем на
                          // 1000.0 (множитель ед. измерения "мВ"), получаем 10000.0 мВ
      PROP_LSB_WEIGHT= $3039,				// R; Цена младшего разряда канала (В/код) (УСТАРЕЛО)
      PROP_SENS_NOMINAL= $303A,				// R/W; Номинальное значение коэффициента чувствительности
      PROP_SENS= $303B,						// R/W; Точный коэффициент чувствительности/передачи/усиления) измерительного
                          // тракта канала в текущих входных/выходных единицах измерений, double
                          // ВАЖНО: Фактическое значение чувствительности (уникальное для каждого канала)
                          // k=y/x, где x - воздействие на входе тракта, y - отклик на выходе тракта
                          // Рассчитывается при калибровке чувствительности канала.
                          // ПРИМЕЧАНИЕ:
                          // Номинальная чувствительность (одинаковая для каналов одного типа)
                          // k_ном=RangeOut/RangeIn (к примеру в паспорте это "типовая чувствительность")
                          // Если канал является каналом ввода информации, то номинальный входной
                          // диапазон канала обычно имеет запас 5% и округлен в меньшую сторону.
                          // С этими значениями работает пользователь.
                          // При этом номинальный выходной диапазон этого канала будет:
                          // RangeOut = k_ном * RangeIn
                          // значения RangeOut будут при этом иметь "корявый" вид (не округлены)
                          // и пользовательские диалоги их выводить не требуется.
                          // К каналам вывода информации применяется аналогичная логика, но
                          // RangeOut и RangeIn меняются местами.
                          // ПРИМЕР:
                          // k_ном   =  3.3;  0.77;  0.3; 0.07 мВ/пКл  (по данным аппаратчиков)
                          // RangeIn =  2.3;   7.1; 17.0; 52.0 нКл     (нормированная х-ка)
                          // RangeOut= 7.59; 5.467;  5.1; 3.64 В       (для вычислений)

      PROP_SENS_NOM_STR= $303C,				// R/W; Номинальное значение коэффициента чувствительности (строка)

      PROP_ZR_OFFSET= $303D,					// R; Смещение нуля (в текущих входных физических единицах), double
                            // PROP_SENS и PROP_ZR_OFFSET исп. только в случае линейной калибровочной функции.
      PROP_AMPLIF_INDEX= $303E,              // R/W; Номер коэффициента усиления
      PROP_ATTEN_INDEX= $303F,               // R/W; Код аттенюатора
    // Если полный коэффициент усиления канала задается общей и индивидуальной компонентами, то использовать следующее:
      PROP_BASE_AMPLIF= $3040,				// R/W; Коэффициент усиления, общий для всех каналов устройства, double
      PROP_CHAN_AMPLIF= $3041,				// R/W; Коэффициент усиления, индивидуальный для каждого канала устройства, double
      PROP_BALANCE_DAC= $3042,				// R/W; Код балансировочного ЦАПа
      PROP_BALANCE_VAL= $3043,               // R/W; Значение на входе преобразующего узла (DAQ-модуля, усилителя и т.д.) в
                            // текущих входных единицах измерений, которое нужно убрать (например с
                            // помощью балансировочного ЦАПа)
      PROP_BALANCE_TYPE= $3044,					// R/W Тип балансировки 0- внутренняя балансировка, 1- внешняя
      PROP_BALANCE_ZOFFSET= $3045,				// R/W; Остаточное смешение канала в кодах после балансировки
      PROP_CALIBRATION= $3046,					// R/W; Включение режима калибровки
      PROP_CALIBR_FREQ= $3047,                   // R/W; Частота калибровочной гармоники, Гц (double)
        PROP_CALIBR_MAG= $3048,					// R/W; Амплитуда калибровочной гармоники, (double)

      PROP_IMITATOR= $3049,                      // R/W; Включение внутреннего имитатора датчика (200 Ohm), (BOOL)
      PROP_IMITATOR_VAL= $304A,                  // R/W; Сопротивление имитатора, (double)


    // ************** Управление датчиком через измерительный модуль ************
      PROP_SENSOR_CIRCUIT= $304B,                // R/W; Схема включения датчика (для тензо - мост/полумост/четвертьмост)
      PROP_SENSOR_SPL= $304C,                    // R/W; Переключатель питания датчика
      PROP_SENSOR_SPL_STR= $304D,                // R;   Строковый вариант предыдущего свойства
      PROP_SENSOR_SPL_ON= $304E,                 // R/W; Питание датчика включить
      PROP_SENSOR_SPL_UNITS= $304F,              // R/W; Тип питания датчика (напр. током/напряжением)
      PROP_SENSOR_SPL_I= $3050,                  // R/W; Величина тока питания датчика (double, А)
      PROP_SENSOR_SPL_U= $3051,                  // R/W; Величина напряжения питания датчика (double, В)
      PROP_SENSOR_SPL_RESTRICTION= $3052,		// R/W; Ограничение питания датчика (0=выкл, 1=вкл)
      PROP_SENSOR_SPL_I_MIN= $3053,				// R/W; Ограничение питания датчика (А)
      PROP_SENSOR_SPL_I_MAX= $3054,				// R/W; Ограничение питания датчика (А)
      PROP_SENSOR_SPL_U_MIN= $3055,				// R/W; Ограничение питания датчика (В)
      PROP_SENSOR_SPL_U_MAX= $3056,				// R/W; Ограничение питания датчика (В)
      PROP_SENSOR_SPL_CLB_ON= $3057,				// R/W; Использование калибровок ЦАПа питания датчика
      PROP_SENSOR_SPL_KU= $3058,					// R/W; Чувствительность ЦАПа питания по напряжению (В/код)
      PROP_SENSOR_SPL_ZU= $3059,					// R/W; Смещение нуля ЦАПа питания по напряжению (В)
      PROP_SENSOR_SPL_KI= $305A,					// R/W; Чувствительность ЦАПа питания по току (А/код)
      PROP_SENSOR_SPL_ZI= $305B,					// R/W; Смещение нуля ЦАПа питания по току (А)
      PROP_SENSOR_CALIBR= $305C,					// R/W; Включение шунта для калибровки датчика
      PROP_SENSOR_SHUNT_R= $305D,				// R; Сопротивление шунта, Ом
      PROP_SENSOR_1_4_BRIDGE_COMPL_R= $305E,		// R; Сопротивление дополнения 1/4 моста, Ом
      PROP_SENSOR_1_4_BRIDGE_R= $305F,			// R; Сопротивление 1/4 моста датчика (номинал), Ом
    // *** DIGITAL INPUT PROPERTY ***
      PROP_PORT= $3060,							// R/W; Входной порт (long)
      PROP_MASK= $3061,							// R/W; Маска входного цифрового слова
      PROP_SHIFT= $3062,							// R/W; Сдвиг битов (выполняется после маскирования)
    ////////////////////// Выходной амплитудный диапазон измерительного канала  ////////////////////
      PROP_OUT_RANGE= $3063,								// R/W; Номинальный выходной амплитудный диапазон канала, double
                            // ВНИМАНИЕ: Число входных амплитудных диапазонов, выходных амплитудных
                            // диапазонов и коэффициентов чувствительности одинаково!
      PROP_OUT_RANGE_EXACT= $3064,        // Реальный выходной амплитудный диапазон в номинальных единицах измерения (см. ниже)
      PROP_OUT_RANGE_STR= $3065,					// R; Список выходных амплитудных диапазонов, строки
      PROP_OUT_RANGE_UNITS= $3066,				// R/W; Текущие единицы измерения выходного ампл. диапазона, индекс от 0
      PROP_OUT_RANGE_UNITS_STR= $3067,			// Список единиц измерения выходного амплитудного диапазона, строка
      PROP_OUT_RANGE_UNITS_MULT= $3068,			// Множитель единиц измерения (по отношению к номинальной), double
      PROP_OUT_LOCK= $3069,			            // R/W; Блокировка выходного диапазона (при изменении чувствительности меняется
                                  // только входной диапазон)
      PROP_RANGE_MAX= $306A,						// R; верхняя граница амплитудного диапазона канала
      PROP_RANGE_MIN= $306B,						// R; нижняя граница амплитудного диапазона канала
      PROP_INDEX_OUT_RANGE= $306C,
      PROP_LPF_CNT= $306D,						// R; Количество фильтров ФНЧ
      PROP_LPF_CHAN= $306E,						// R/W; Состояние ФНЧ
      PROP_LPF_STR= $306F,						// R; Строка
      PROP_HPF_CNT= $3070,						// R; Количество фильтров ФВЧ
      PROP_HPF_CHAN= $3071,						// R/W; Состояние ФВЧ
      PROP_HPF_STR= $3072,						// R; Строка

      OVERLOAD_CHAN= $3073,						// Конфигурирование флагов перегрузки
      PROP_CHAN_SCAN_TYPE= $3074,
      PROP_WARNING_LEVEL= $3075,					// R/W; Уровень срабатывания предупреждающей сигнализации
      PROP_CRASH_LEVEL= $3076,					// R/W; Уровень срабатывания аварийной сигнализации
      PROP_X_UNITS= $3077,						// R/W; Размерность по оси абсцисс
      PROP_X_UNITS_STR= $3078,					// R/W; Размерность по оси абсцисс, строка
      PROP_GAUGE_TYPE= $3079,					// R/W; Тип датчика
    // Chan M2408/MC201
      CODE_LO_CHAN= $307A,
      CODE_HI_CHAN= $307B,
      PROP_CHAN2408_SRC_ID= $307C,				// R/W; ChanID канала аналогового ввода для "сквозняка"
    // Chan MX132
      PROP_RANGES= $307D,
      PROP_ADSP_CHAN_COUNT= $307E,
      PROP_1ST_CHAN_INPUT= $307F,		// R/W; Дополнительный коммутатор входа первого канала (0=напряжение, 1=температура)
    //Chan212
      PROP_CHAN212_CONNECTIONTYPE= $3080,
      PROP_CHAN212_SENSE= $3081,
      PROP_CHAN212_RANGE= $3082,
      PROP_CHAN212_OFFSET= $3083,
      PROP_CHAN212_DAC= $3084,
    // Scan
      PROP_SCAN_HANDLER= $3085,
      PROP_SCAN_HANDLER_DATA= $3086,
      PROP_SCAN_DIVIDER= $3087,
      PROP_SCAN_FIFO_SIZE= $3088,
      PROP_SCAN_TYPE= $3089,
      PROP_N_REFS= $308A,						// R; Количество источников опорного напряжения
      PROP_U_REF_RANGE= $308B,					// R; Диапазон опорных напряжений калибратора, Index - номер ИОН
      PROP_U_REF= $308C,							// R/W; Текущее опорное напряжение калибратора, Index - номер ИОН
      PROP_REF_RESOLUTION= $308D,				// R; Разрядность источника опорного напряжения калибратора     (если 0,
                            // то источник одного фиксированного напряжения), Index - номер ИОН
      PROP_ICP= $308E,							// R/W; 1=ICP включет, 0=ICP выключен
      PROP_DIN= $308F,
      PROP_WARN= $3090,
      PROP_CRASH= $3091,
      PROP_WARN_COLOR= $3092,
      PROP_CRASH_COLOR= $3093,
      PROP_ALIAS= $3094,                          // Юзерское имя сущности
    // Для платы National Instruments NI-6143
      PROP_NI6143_CHAN_NAME= $3095,				// R/W; Имя канала при обращении к функциям NI-DAQmx
      PROP_NI6143_AI_FREQ= $3096,				// R/W: Частота дискретизации каналов аналогового ввода (единая для платы)
      STAT_AI_NTF_WAIT_TIMEOUTS= $3097,			// R: Количество тайм-аутов в потоке сообщения о получении порции данных
      STAT_AI_NTF_WAIT_FAILURES= $3098,		    // R: Количество ошибок ожидания в потоке сообщения о получении порции данных
      STAT_AI_READ_ERRORS= $3099,				// R: Количество ошибок чтения из устройства
      STAT_SAMPLES_RECEIVED= $309A,				// R: Количество полученных сэмплов
      STAT_SAMPLES_OVERRAN= $309B,				// R: Количество перезаписанных сэмплов при переполнении буфера
      PROP_DBL_OFF= $309C,
      PROP_CHAN_INVERSION= $309D,
      PROP_CHAN_CALIBR_STR= $309E,				// R; Строковый вариант cостояния калибратора
      PROP_CHAN_DAC_ENABLED= $309F,				// R/W; ЦАП канала разрешено использовать
      PROP_CHAN_CALIBR_SHUNT= $30A0,				// R/W; калибровочный  шунт, long
      PROP_CHAN_CALIBR_LEVEL= $30A1,				// R/W; Калибровочный уровень +2.5 В, long
      PROP_CHAN_SUPPLY_TYPE= $30A2,				// R/W. Тип питания датчика, long 0- U, 1-I
      PROP_CHAN_SUPPLY_U= $30A3,					// Прочитать/изменить U пит. Датчика, double
      PROP_CHAN_SUPPLY_I= $30A4,					// Прочитать/изменить I пит. Датчика, double
      PROP_CHAN_OUTPUT_U= $30A5,					// Прочитать/изменить U вых., double
      PROP_CHAN_HPF= $30A6,						// R/W; ФВЧ, long
      PROP_CHAN_LPF= $30A7,						// R/W; ФНЧ, long
      PROP_CHAN_BALANCE_DAC_VOLT= $30A8,			// Прочитать/изменить балансировочное напряжение, double
      PROP_CHAN_BRIDGE= $30A9,					// Прочитать/изменить режим подключения датчика Мост, полумост мост четверть мост, long
      PROP_CHAN_CERTIF_AMPLIF= $30AA,			// R/W; Паспортный коэффициент усиления, индивидуальный для каждого канала
                            // устройства, double
      PROP_CHAN_CERTIF_OFFSET_U= $30AB,			// R/W; Паспортное калибровочное значение питания напряжением, double
      PROP_CHAN_CERTIF_OFFSET_I= $30AC,			// R/W; Паспортное калибровочное значение питания током, double
      PROP_CHAN_CERTIF_MINMAX_U= $30AD,			// R/W; Паспортное значение макс., мин. питания напряжением, double
      PROP_CHAN_CERTIF_MINMAX_I= $30AE,			// R/W; Паспортное значение макс., мин. питания током, double
      PROP_CHAN_FLAG_CERTIF_OFFSET_EXCEED= $30AF,// R/W; применить паспортное значение питания, long
      PROP_CHAN_FLAG_CERTIF_MINMAX_EXCEED= $30B0,// R/W; применить паспортное значение мин.макс. питания, long
      PROP_CHAN_NAME_NOMINAL_OFFSET_U= $30B1,	// R; Строка номинального значения питания напряжением, str
      PROP_CHAN_NAME_NOMINAL_OFFSET_I= $30B2,	// R; Строка номинального значения питания током, str
      PROP_SMBINCC_CHAN_ENABLE= $30B3,			// R/W; Признак разрешения работы с батарейкой, long
      PROP_CHAN_VALUE_CMD= $30B4,				// R/W; Читать, заисать канал, double
      PROP_CHAN_MODE_CMD= $30B5,					// R/W; Читать, записать, запрограммировать режим канала, long
      PROP_CHAN_CERTIF_LPF= $30B6,			    // R/W; Паспортное значение ФНЧ, double
      PROP_CHAN_CERTIF_HPF= $30B7,			    // R/W; Паспортное значение ФВЧ, double
      PROP_RMS_FREQ_BAND= $30B8,                 // R/W; Выход СКЗ в полосе, Гц
      PROP_CHAN_FLAG_CAL_AMPL= $30B9,            // R/W; Применить калибровку аттенюатора, long
      PROP_CHAN_FLAG_CAL_BAL= $30BA,				// R/W; Применить калибровку балансировочного напряжения, long
      PROP_CHAN_CAL_BAL_U= $30BB,                // R/W; Калибровочное паспортное значение балансировочного напряжения при питании напряжением, double
      PROP_CHAN_CAL_BAL_I= $30BC,                // R/W; Калибровочное паспортное значение балансировочного напряжения при питании током, double
      PROP_CHAN_1_4_BRIDGE_R= $30BD,
      PROP_CHAN_SHUNT_R= $30BE,
      PROP_CHAN_SET_1_4_BRIDGE_R= $30BF,			// R/W; Номер набора 1/4 дополнений, Ом, long
      PROP_CHAN_SET_SHUNT_R= $30C0,				// R/W; Номер набора шунтов, Ом, long
      PROP_CHAN_NOMINAL_AMPLIF= $30C1,			// R/W; Номинальный коэффициент усиления, double
      PROP_CHAN_NOMINAL_OFFSET_U= $30C2,			// R/W; Номинальное калибровочное значение питания напряжением, double
      PROP_CHAN_NOMINAL_OFFSET_I= $30C3,			// R/W; Номинальное калибровочное значение питания током, double
      PROP_CHAN_NOMINAL_CAL_BAL_U= $30C4,        // R/W; Номинальное калибровочное значение балансировочного напряжения при питании напряжением, double
      PROP_CHAN_NOMINAL_CAL_BAL_I= $30C5,        // R/W; Номинальное калибровочное значение балансировочного напряжения при питании током, double
      PROP_CHAN_EXCEED_CAL_BAL_U= $30C6,         // R/W; Напряжение для калибровки балансировочного ЦАПа при питании напряжением, double
      PROP_CHAN_EXCEED_CAL_BAL_I= $30C7,         // R/W; Ток для калибровки балансировочного ЦАПа при питании током, double
      PROP_OUT_TYPE= $30C8,                      // R/W; Тип выхода, long
      PROP_OUT_TYPE_STR= $30C9,                  // R/W; Тип выхода, строка
      PROP_CHAN_NOMINAL_RMS_FREQ_BAND= $30CA,    // R/W; Номинальное значение выхода RMS в полосе, Гц во flash
      PROP_CHAN_NOMINAL_LPF= $30CB,			    // R/W; Номинальное значение ФНЧ, double
      PROP_SENSOR_CIRCUIT_STR= $30CC,
      PROP_CHAN_AMPLIF_STR= $30CD,
      PROP_CHAN_CERTIF_SUPPLY_U= $30CE,			// Прочитать/изменить паспортное U пит. Датчика, double
      PROP_CHAN_CERTIF_SUPPLY_I= $30CF,			// Прочитать/изменить паспортное I пит. Датчика, double
      PROP_CHAN_SUPPLY= $30D0,
      PROP_CHAN_CERTIF_SUPPLY= $30D1,
      PROP_CHAN_SUPPLY_STR= $30D2,
      PROP_CHAN_STEP_SUPPLY= $30D3,
      PROP_CHAN_CERTIF_SUPPLY_STR= $30D4,
      PROP_CHAN_SUPPLY_TYPE_STR= $30D5,
      PROP_SENSOR_BAL_ON= $30D6,
      PROP_CHAN_BALANCE_STR= $30D7,
      PROP_CHAN_STEP_BALANCE= $30D8,
      PROP_CHAN_BALOUT= $30D9,
      PROP_CHAN_BALOUT_STR= $30DA,
      PROP_CHAN_BAL_UNIT_STR= $30DB,
      PROP_CHAN_HPF_ON= $30DC,
      PROP_CHAN_HPF_STR= $30DD,
      PROP_CHAN_HPF_UNIT_STR= $30DE,
      PROP_CHAN_LPF_ON= $30DF,
      PROP_CHAN_LPF_STR= $30E0,
      PROP_CHAN_LPF_UNIT_STR= $30E1,
      PROP_CHAN_LPF_INDEX= $30E2,
      PROP_CHAN_CALSHUNT_ON= $30E3,
      PROP_CHAN_CALSHUNT= $30E4,
      PROP_CHAN_CALSHUNT_STR= $30E5,
      PROP_CHAN_CALLEVEL_ON= $30E6,
      PROP_CHAN_CALLEVEL= $30E7,
      PROP_CHAN_CALLEVEL_STR= $30E8,
      PROP_CHAN_SIMULATORR_ON= $30E9,
      PROP_CHAN_SIMULATORR= $30EA,
      PROP_CHAN_SIMULATORR_STR= $30EB,
      PROP_CHAN_SIMULATORI_ON= $30EC,
      PROP_CHAN_SIMULATORI= $30ED,
      PROP_CHAN_SIMULATORI_STR= $30EE,
      PROP_CHAN_CALCHAN= $30F0,
      PROP_ATTEN_STR= $30F1,
      PROP_CHAN_SUPPLY_U_STR= $30F2,					// Прочитать/изменить U пит. Датчика, str
      PROP_CHAN_CERTIF_SUPPLY_U_STR= $30F3,			// Прочитать/изменить U пит. Датчика, str
      PROP_CHAN_STEP_SUPPLY_U= $30F4,
      PROP_CHAN_SUPPLY_I_STR= $30F5,					// Прочитать/изменить I пит. Датчика, str
      PROP_CHAN_CERTIF_SUPPLY_I_STR= $30F6,			// Прочитать/изменить I пит. Датчика, str
      PROP_CHAN_STEP_SUPPLY_I= $30F7,
      PROP_CHAN_NOMINAL_HPF= $30F8,			        // R/W; Номинальное значение ФВЧ, double
      PROP_FLASH_SET_DEFAULT= $30F9,
      PROP_CAPACITY= $30FA,
      PROP_CALIBRATION_STR= $30FB,
      PROP_EXCIT_OUTPUT= $30FC,                      // R/W; long, Направление выдачи тока питания датчика (нагрузка)
      PROP_EXCIT_OUTPUT_STR= $30FD,                  // R/W; Строковый вариант предыдущего свойства
      PROP_EXCIT_OUTPUT_BLOCK= $30FE,                // R/W; long, свойство PROP_EXCIT_OUTPUT заблокировано для пользователя
      PROP_CHAN_FLOAT= $30FF,		                // Прочитать/изменить режим FLOAT
    // Злобин
      PROP_MASK_CHAN= $3200,                         // R/W; Маска каналов, long
      PROP_FLAG_TEST= $3201,                         // R/W; Флаг теста, long
      PROP_READ_ADC= $3202,                          // R/W;
      PROP_WRITE_CTRL= $3203,
      PROP_FLAG_ANALOG= $3204,
      PROP_CHAN_ANALOG= $3205,
      PROP_CHAN_TEST= $3206,
      PROP_CHAN_KU= $3207,
      PROP_CHAN_KV= $3208,
      PROP_FEED_WATCHDOG= $3209,
      PROP_CHAN_DIGIT= $320A,
      PROP_ENABLE_WATCHDOG= $320B,
      PROP_SENSOR_1_2_BRIDGE_COMPL_R= $320C,	  // R; Сопротивление дополнения 1/2 моста, Ом

      PROP_CHAN_ACOM=$320D,                    //R/W вывод канала на ACOM MT-183 Хрулев
      PROP_CHAN_SHUNT_R_200_1=$320E,           //MT183 1-е сопротивление 200 Ом Хрулев
      PROP_CHAN_SHUNT_R_100=$320F,             //MT183 сопротивления 100 Ом Хрулев
      PROP_CHAN_SHUNT_R_200_2=$3210,           //MT183 2-е сопротивления 200 Ом Хрулев

      PROP_CHAN_COMMUT=$3211,                  //Коммутатор MC114(MR114)

    // Мельников
      PROP_CHAN_ATARE = $3601, /// символьная ссылка на ГХ (для MIC140 имя в БДГХ)

      // National Instruments
      PROP_NI_DEV_NAME = $3602, // Имя устройства
      PROP_NI_CHAN_NAME = $3603, // Имя канала NI
      PROP_NI_CHAN_AI_MODE = $3604, // Режим измерения (по требованию, интервал, скольжение)
      PROP_NI_CHAN_AI_INPUT_CONFIG = $3605, // Конфигурация аналогового входа (differential, RSE, NRSE, pseudodifferential)
      PROP_NI_CHAN_AI_FREQ = $3606, // частота канала (Герц)
      PROP_NI_CHAN_TYPE = $3607, // тип канала (Analog Input, Counter, etc.)
      PROP_NI_DEV_AI_COUNT = $3608, // количество каналов аналогового входа
      PROP_NI_DEV_AI_COUNT_MAX = $3609,
      //
      //
      //
      PROP_NI_DEV_CH_RESERVED_LAST_ID = $3617, // зарезервировано от PROP_NI_DEV_AI_COUNT_MAX для всех типов каналов (основные 6 + i/o счетчики + максимальное количество)

      PROP_NI_CHAN_SETTINGS = $3618, // Настройки канала
      PROP_NI_CHAN_EXT_TYPE = $3619, // Подробный тип канала (аналоговый, термопара и т.д.)
      NI_EPROP_RESISTANCE_CONFIG = $361A,
      NI_EPROP_CURRENT_EXCIT_SOURCE = $361B,
      NI_EPROP_CURRENT_EXCIT_VALUE = $361C,
      NI_EPROP_BRIDGE_TYPE = $361D,
      NI_EPROP_VEXCIT_SOURCE = $361E,
      NI_EPROP_VEXCIT_VALUE = $361F,
      NI_EPROP_COUPLING = $3620,
      NI_EPROP_IEPE_ENABLED = $3621,
      NI_EPROP_SENSITIVITY_UNITS = $3622,
      NI_EPROP_SENSITIVITY_VALUE = $3623,

    // Кротких
      PROP_SENSOR_CALIBR_STR = $3700, // R; Включение шунта для калибровки датчика (строка)
    // Кравцов 0x3900-0x3aff
      PROP_CHAN_BUS_RATE = $3900, // R/W частота шины MR-2355
      PROP_CHAN_LINK_START_TYPE = $3901, // R/W тип старта линка
      PROP_SENSOR_BRIDGE_R1= $3902,  // R; Сопротивление 1/4 моста датчика (номинал), Ом
      PROP_SENSOR_BRIDGE_R2= $3903,  // R; Сопротивление дополнения 1/2 моста, Ом
      PROP_SENSOR_BRIDGE_R3= $3904,  // R; Сопротивление дополнения 1/2 моста, Ом
      PROP_SENSOR_BRIDGE_R4= $3905,  // R; Сопротивление дополнения 1/4 моста, Ом
      PROP_SENSOR_CIRC_NUM= $3906,
      PROP_SENSOR_CIRC_STR= $3907,
      PROP_TENZO_GAGE= $3908,
      PROP_SENSOR_POISSON= $3909,
      PROP_SENSOR_SENS_TYPE= $390A,
      PROP_TRANS_CHAN= $390B,		// R/W передающий канал MR-2355v2
      PROP_REC_CHAN= $390C,			// R/W приемный канал MR-2355v2

    // ------------------------------- TMI PROPERTY ----------------------------------------
      PROP_SN= $5000,
      PROP_TASK,
      PROP_IMASK,
      PROP_NWORD,
      PROP_CNT_FRAME,
      PROP_CNT_PART_FIFO,
      PROP_PARAM_INPUT,
      PROP_INT_HANDLER,
      PROP_DATA_HANDLER,
      PROP_CONTEXT,
      PROP_DIRECTION,
      PROP_FREQ_IN,
      PROP_FREQ_OUT,
    // пути
      PROP_DSTN_PATH,
      PROP_SOUR_PATH,
    // Bios Param
      PROP_POS_FRONT_0,
      PROP_POS_FRONT_1,
      PROP_NEG_FRONT_0,
      PROP_NEG_FRONT_1,
      PROP_SYN_0,
      PROP_SYN_1,
      PROP_TIME_0,
      PROP_TIME_1,
      PROP_FRAME_0,
      PROP_FRAME_1,
      PROP_LENGTH_FRAME,
      PROP_LENGTH_SYN,
      PROP_LENGTH_DBL_SYN,
      PROP_LENGTH_TROUBLE,
      PROP_FREQ_TIMER,
      PROP_FREQ_SPORT,
      PROP_NUM_COUNT,
      PROP_MAX_COUNT,
      PROP_PRECISION_SPORT,
      PROP_SCALE_TIMER,
      PROP_TYPE_FLOW,
      PROP_TIMER_FLOW_0,
      PROP_TIMER_FLOW_1,
      PROP_CMD_REG_0,
      PROP_CMD_REG_1,
      PROP_OUT_DAC,
      PROP_RECOVERY,
      PROP_ONLINE,
      PROP_MERA_TIME,
      PROP_VERSION,
    // M2181 M1181
      PROP_SW1,
      PROP_SW2,
      PROP_SW2_DUMMY,
      PROP_FLAG_REG,
      PROP_LEVEL,
      PROP_MIN_LEVEL,
      PROP_MAX_LEVEL,
      PROP_STEP_LEVEL,
    // M2501
      PROP_FREQ_GTR1,
      PROP_FREQ_GTR2,
      PROP_SCIC2,
      PROP_SCIC5,
      PROP_RCF,
      PROP_PLL_COUNT,
      PROP_PLL_STEP,
      PROP_PLL_THR,
      PROP_N_POINT,
      PROP_FREQ_RCF,
      PROP_DEC_SCIC2,
      PROP_DEC_SCIC5,
      PROP_DEC_RCF,
      PROP_SAMP_FREQ,
      PROP_PLL_BORDER,
    // M2502
      PROP_FREQ_SPORT1,
      PROP_FREQ_TIMER1,
      PROP_FREQ_GTR11,
      PROP_FREQ_GTR21,
      PROP_SCIC21,
      PROP_SCIC51,
      PROP_N_POINT1,
      PROP_DEC_SCIC21,
      PROP_DEC_SCIC51,
      PROP_PORT_MASK,
      PROP_LENGTH_FRAME1,
      PROP_PLL_COUNT1,
      PROP_PLL_STEP1,
      PROP_PLL_THR1,
      PROP_PLL_BORDER1,
    // Filters & pins
      PROP_INPIN_ID,
      PROP_RUN,
      PROP_MDP_INITIALISED,
      PROP_DEBUG_STATE,
      PROP_BUFFER_FILL, // from mr300 mx224
      PROP_AMPLIFIER,
      PROP_SAVECALIBRTOFACTORY,
      PROP_IMPORTCALIBRTOFACTORY,
    // *** DIGITAL INPUT/OUTPUT PROPERTY ***
      PROP_LAST= $7FFFFFFF);

const
    PROP_OK = 0;										 //	/* Successful return */
    PROP_UNKNOWN = 1;								 //		/* Unknown Property */
    PROP_UNDEFINED = 2;							 //		/* Known, but undefined yet (retry later) */
    PROP_TIMEOUT_ERROR = 3;					 //			/* Timeout error */
    // /* Events */
    PROP_TRANSFER_CTX = 8010;				 //				/* Context of transfer task */
    PROP_MO = 4100;
    PROP_MAX_MIN = 4101;
    PROP_SKZ = 4102;
    PROP_SKO = 4103;
    PROP_F = 4104;									 //		/* frequency estimation of channel  */
    PROP_M_F = 4110;
    PROP_A_F = 4111;
    PROP_SKZ_F = 4112;
    PROP_SKO_F = 4113;
    PROP_P_F = 4114;
    PROP_M_F_SUM = 4120;
    PROP_A_F_SUM = 4121;
    PROP_SKZ_F_SUM = 4122;
    PROP_SKO_F_SUM = 4123;
    PROP_HARM = PROP_A_F; // ??????
    PROP_TAR_POLE = 4130;
    PROP_ADC_CALIBR = 4351;

    // Команды нотификации
    NOTIFY_REMOVE_CHAN = 0;
    NOTIFY_GET_MAX_FIFOADSP_SIZE = 1;

    // flags
    FLAG_BIOS_LOAD = $A5A5;
    FLAG_COMMAND_FINISH = $A5A5;
    FLAG_TEST_LOAD = $A5A5;

    // Тип сигнала
type DEVSIGNALTYPE = (
    TYPE_SIGNAL_CODE= 0,
    TYPE_SIGNAL_ELECTR= 1,
    TYPE_SIGNAL_TECH= 2);

const
    VendorID_MERA = $1945;
    VendorID_PLX = $10b5;
    VendorID_NI = $1093;									// National Instruments
    // RTSI
    RTSI_SLAVE = 0;
    RTSI_LINE_MASTER = 1;
    // UTS
    UTS_TYPE_MERA = 0;
    UTS_TYPE_IRIGB_LOCALTIME = 1;
    UTS_TYPE_IRIGB_UTCTIME = 2;
    UTS_TYPE_SEVRS_LOCALTIME = 3;
    UTS_TYPE_SEVRS_UTCTIME = 4;
    UTS_TYPE_IRIGBNOYEAR_LOCALTIME = 101;
    UTS_TYPE_IRIGBNOYEAR_UTCTIME = 102;

    IDX_CHANDLG_MAIN = 0;
    IDX_CHANDLG_SECOND = 1;
    IDX_CHANDLG_SM = 10;
    IDX_CHANDLG_SEC_SM = 11;

implementation

end.
