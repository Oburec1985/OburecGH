unit MxxxxTypes;
{$OPTIMIZATION OFF}
interface

const
  // --------------------------- Propery -----------------------------------------
  REVISION_PROPERTY       = 262;
  PROP_BIOS_PATH          = $1009;
  PROP_FLEX_PATH          = $100C;
	PROP_SN                 = $5000;
	PROP_TASK               = $5001;
	PROP_IMASK              = $5002;
	PROP_NWORD              = $5003;
	PROP_CNT_FRAME          = $5004;
	PROP_CNT_PART_FIFO      = $5005;
	PROP_PARAM_INPUT        = $5006;
	PROP_INT_HANDLER        = $5007;
	PROP_DATA_HANDLER       = $5008;
	PROP_CONTEXT            = $5009;
	PROP_DIRECTION          = $500A;
	PROP_FREQ_IN            = $500B;
	PROP_FREQ_OUT           = $500C;
	PROP_DSTN_PATH          = $500D;
	PROP_SOUR_PATH          = $500E;
  // Bios Param
	PROP_POS_FRONT_0        = $500F;
	PROP_POS_FRONT_1        = $5010;
	PROP_NEG_FRONT_0        = $5011;
	PROP_NEG_FRONT_1        = $5012;
	PROP_SYN_0              = $5013;
	PROP_SYN_1              = $5014;
	PROP_TIME_0             = $5015;
	PROP_TIME_1             = $5016;
	PROP_FRAME_0            = $5017;
	PROP_FRAME_1            = $5018;
	PROP_LENGTH_FRAME       = $5019;
	PROP_LENGTH_SYN         = $501A;
	PROP_LENGTH_DBL_SYN     = $501B;
	PROP_LENGTH_TROUBLE     = $501C;
	PROP_FREQ_TIMER         = $501D;
	PROP_FREQ_SPORT         = $501E;
	PROP_NUM_COUNT          = $501F;
	PROP_MAX_COUNT          = $5020;
	PROP_PRECISION_SPORT    = $5021;
	PROP_SCALE_TIMER        = $5022;
	PROP_TYPE_FLOW          = $5023;
	PROP_TIMER_FLOW_0       = $5024;
	PROP_TIMER_FLOW_1       = $5025;
	PROP_CMD_REG_0          = $5026;
	PROP_CMD_REG_1          = $5027;
	PROP_OUT_DAC            = $5028;
	PROP_RECOVERY           = $5029;
	PROP_ONLINE             = $502A;
	PROP_MERA_TIME          = $502B;
        PROP_VERSION            = $502C;
  // M2181 M1181
	PROP_SW1                = $502D;
	PROP_SW2                = $502E;
	PROP_SW2_DUMMY          = $502F;
	PROP_FLAG_REG           = $5030;
        PROP_LEVEL              = $5031;
	PROP_MIN_LEVEL          = $5032;
	PROP_MAX_LEVEL          = $5033;
	PROP_STEP_LEVEL         = $5034;
  //M2501
	PROP_FREQ_GTR1          = $5035;
	PROP_FREQ_GTR2          = $5036;
	PROP_SCIC2              = $5037;
	PROP_SCIC5              = $5038;
	PROP_RCF                = $5039;
	PROP_PLL_COUNT          = $503A;
	PROP_PLL_STEP           = $503B;
	PROP_PLL_THR            = $503C;
	PROP_N_POINT            = $503D;
	PROP_FREQ_RCF           = $503E;
	PROP_DEC_SCIC2          = $503F;
	PROP_DEC_SCIC5          = $5040;
	PROP_DEC_RCF            = $5041;
	PROP_SAMP_FREQ          = $5042;
	PROP_PLL_BORDER         = $5043;
	PROP_FREQ_SPORT1        = $5044;
	PROP_FREQ_TIMER1        = $5045;
	PROP_FREQ_GTR11         = $5046;
	PROP_FREQ_GTR21         = $5047;
	PROP_SCIC21             = $5048;
	PROP_SCIC51             = $5049;
	PROP_N_POINT1           = $504A;
	PROP_DEC_SCIC21         = $504B;
	PROP_DEC_SCIC51         = $504C;
	PROP_PORT_MASK          = $504D;
	PROP_LENGTH_FRAME1      = $504E;
	PROP_PLL_COUNT1         = $504F;
	PROP_PLL_STEP1          = $5050;
	PROP_PLL_THR1           = $5051;
	PROP_PLL_BORDER1        = $5052;
	PROP_FLAG_REG1          = $5053;
	PROP_LTCMD_REG          = $5054;
	PROP_LTCMD_REG1         = $5055;
	PROP_VI_LOOPDIVIDER     = $5056;
	PROP_VI_LOOPDIVIDER1    = $5057;
	PROP_NTAPS              = $5058;
// -------------------------- Type Card ----------------------------------------
// ISA
	M1081_TYPE              = $5000;
	M1181_TYPE              = $5001;
	M1070_TYPE              = $5002;
// PCI
	M2081_TYPE              = $6081;
	M2181_TYPE              = $6082;
	M2070_TYPE              = $6083;
        M2501_TYPE              = $6087;
        M2502_TYPE              = $6111;
	PLX9050_TYPE            = $9050;
  // ---------------------------- Errors -----------------------------------------

	ERROR_NOERROR           = 0;

	// Global Errors
	ERROR_ANY_ERROR                         = 1;   // Error without description (yet)
	ERROR_MEMORY_ALLOC                      = 2;
	ERROR_TOO_MANY_SELECTORS                = 3;
	ERROR_METHOD_NOT_INHERITED              = 4;   // Function not implemented yet
	ERROR_REENTERING_IRQ                    = 5;
  // Devices/Modules Errors
	ERROR_DEVICE_UNKNOWN                    = 10;  // ��� �������� ��������� ��� ����������
	ERROR_INCORRECT_DEVICE_ID               = 11;
	ERROR_DEVICE_NOT_PRESENT                = 12;
    ERROR_MODULE_NOT_PRESENT                    = 13;
	ERROR_BIOS_CODE_NOT_FOUND               = 14;
	ERROR_FLEX_CODE_NOT_FOUND               = 15;
	ERROR_BAD_FLEX_CODE                     = 16;
    ERROR_TOO_MANY_DEVICES                      = 17;
	ERROR_BIOS_NOT_LOADED                   = 18;
	ERROR_FLEX_NOT_LOADED                   = 19;
	ERROR_DEVICE_NOT_INITIALISED            = 20;
	ERROR_DEVICE_NOT_PROGRAMMED             = 21;
	ERROR_DEVICE_NOT_ACTIVATED              = 22;
	ERROR_DEVICE_NOT_INTERFACE              = 23;
	ERROR_DEVICE_NOT_TRANSFER               = 24;
	ERROR_DEVICE_NOT_RESPOND                = 25;
	ERROR_DEVICE_ALREADY_ACTIVATED          = 26;
	ERROR_DEVICE_ALREADY_PROGRAMMED         = 27;
	ERROR_DEVICE_ALREADY_INITIALISED        = 28;
	ERROR_BIOS_ALREADY_LOADED               = 29;
	ERROR_WINDRIVER_HANDLE                  = 30;
	ERROR_WINDRIVER_INCORRECT_VERSION       = 31;
	ERROR_CREATE_EVENT                      = 32;
	ERROR_OVERLAPPED                        = 33;
	ERROR_KPOPEN                            = 34;
	ERROR_DMALOCK                           = 35;
	ERROR_IFACE                             = 36;
	ERROR_INI_FILE                          = 37;
	ERROR_CC_NULL                           = 38;
	ERROR_MODULE_NULL                       = 39;
	ERROR_HANDLE_NULL                       = 40;
	ERROR_FLAG_BIOS_LOAD                    = 41;
	ERROR_MODULE_BIOS_CODE_NULL             = 42;
	ERROR_DEVICE_NULL                       = 43;
	ERROR_ENABLE_IRQ                        = 44;
	ERROR_MAX_SIZE                          = 45;
  // TEST TMI
	ERROR_TEST_DM                           = 64;
	ERROR_TEST_PM                           = 65;
	ERROR_TEST_DM_PCI                       = 66;
	ERROR_TEST_PM_PCI                       = 67;
	ERROR_TEST_IRQ                          = 68;
	ERROR_TEST_IO                           = 69;
  // Properties Errors
	ERROR_BAD_PROPERTY_ID                   = $fff0;  // �������� ��� �������� ��� � ����������
	ERROR_BAD_PROPERTY                      = $fff1;  // �������� �������� ���������������� ��������
	ERROR_R_ONLY_PROPERTY                   = $fff2;  // �������� ������ ��� ������
	ERROR_W_ONLY_PROPERTY                   = $fff3;  // �������� ������ ��� ������



type TDeviceRoute = record
        BusType         : Longint;
        Location        : array [0..2] of Longint;
end;

type TDevice = record
        DeviceType      : Longint;
        ObjectType      : Longint;
        Route           : TDeviceRoute;
        DeviceName      : array [0..255] of ansiChar;
        RevString       : array [0..255] of ansiChar;
        Description     : array [0..255] of ansiChar;
        RevisionNo      : Word;
        SerialNo        : Word;
        DLLName         : array [0..259] of ansiChar;
        Creator         : Pointer;
        pFinder         : Pointer;
        HWProtocol      : Word;
end;

type TDeviceEnum = record
        nFoundDevs      : Integer;
        DevInfo         : array[0..55] of TDevice;
end;

type PDeviceEnum = ^TDeviceEnum;
type PLongint = ^Longint;
type pPointer = ^Pointer;
type   PWord         = ^Word;

implementation

end.
