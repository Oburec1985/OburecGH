{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ���������� ��� ���������� Recorder`�� � ����������  }
{ ������������������ ������� (����) ����������� ���������� ���������� }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}
unit recorder;
interface
uses Windows, tags, modules, device, ActiveX;
{$ALIGN 8}

const

  MAX_PATH=260;
  // ���� ������ ���������
  RCERROR_NOERROR =              0;
  RCERROR_UNKNOWNERROR =         1;
  RCERROR_NOTIMPLEMENT =         2;
  RCERROR_PLUGINNOTCREATED =     3;
  RCERROR_OUTOFRANGE =           4;
  RCERROR_NOTFOUND =             5;
  RCERROR_DLLNOTFOUND =          6;
  RCERROR_FUNCTIONNOTFOUND =     7;
  RCERROR_CANTOPEN =             8;
  RCERROR_CANTCREATE =           9;
  RCERROR_SYSTEMBUSY =          10;
  RCERROR_FILENOTFOUND =        11;
  RCERROR_INVALIDARGUMENT =     12;
  RCERROR_INVALIDTYPECAST =     13;
  RCERROR_ALREADYEXIST =        14;
  RCERROR_ABNORMALTERMINATION = 15;
  RCERROR_NOTSUPPORTED =        16;
  RCERROR_ACCESSVIOLATION =     17;
  RCERROR_USERABORT =           18;
  RCERROR_ACCESSDENIED =        19;
  LAST_ERROR_INDEX     = RCERROR_ACCESSDENIED;
  //��������� ��������� Recorder`� enum RECORDER_STATE
  RS_STOP              = $0001;     // ��������� �����������
  RS_VIEW              = $0002;     // ��������� � ��������
  RS_REC               = $0004;     // ��������� � ���������� � �����
  RS_PLAY              = $0008;     // ����� ���������������, ������������ �� ������
  RS_PLAYING           = $0008;     // ������������ �� ������
  RS_BASESTATE         = RS_REC + RS_VIEW + RS_STOP + RS_PLAYING;
  RS_HARDWAREFAULT     = $0010;     // ������������� ������� �� ������ �������
  RS_INITFAULT         = $0020;     // ������������� ������� �� ������ �������
  RS_NEEDDEVICERESET   = $0040;     // ��������� Reset ��������
  RS_NEEDHARDWARERESET = $0040;     // ��������� Reset ��������
  RS_NEEDSOFTWARERESET = $0080;     // ��������� Reset ���������� ����� ��������
  RS_NEEDLINKSREFRESH  = $0100;     // ��������� ���������� ������
  RS_FAULT             = RS_HARDWAREFAULT + RS_INITFAULT;

  RS_PLAYMODE          = $0200;     // ��������� � ������ � ������ ���������������
  RS_SIGNALLOADED      = $0400;     // ���������������� ������ �������
  RS_CONFIGCHANGED     = $0800;     // �������� ������������, ��������� ����������
  RS_CONFIGMODE        = $1000;     // ����� ����������������
  RS_PAUSE             = $2000;     // ����� �����

  RS_WAIT_REC_FINISH   = $00004000; // ����� �������� ��������� ������
	RS_CALIBRATE_MODE    = $00008000; // ����� ����������

  RS_PACKETLOST        = $00010000; // ������ �� ����� ������
  RS_RECEIVEERROR      = $00020000; // ������ ���� ������
  RS_PLAYMODE_ENABLED  = $00040000; // �������� ����� ���������������
	RS_ZBALANCE_PROC     = $00080000; // ��������� � �������� ������������ ����
  RS_ERROR_CONDITION   = $00100000; // ��������� � ��������� ������
	RS_WARNING_CONDITION = $00200000; // ��������� � ��������� ��������������
	RS_ENABLEDPAUSE      = $40000000;

  RS_TERMINATION       = $80000000; // ��������� ���������� ������
  RS_FULLMASK          = $FFFFFFFF;

   // ����������� ���������
  RCN_RECONFIG =          0; // ���������������������
  RCN_VIEW =              1; // ����� ������ ��������
  RCN_REC =               2; // ����� ������
  RCN_STOP =              3; // ��������� ���������
  RCN_SHOW =              4; // ������� ������� ���� �������
  RCN_HIDE =              5; // ������ ������� ����
  RCN_CLOSE =             6; // ��������� ������ ���������
  RCN_SETCURFORM =        7; // ������� ��������
  RCN_ENABLESETUP =       8; // ��������� / ��������� ���������
  RCN_CLOSEPLUGIN =       9; // ��������� ������ �������
  RCN_SETCURTAG =        10; // ���������� ������� �����   a_dwParam = ����� ������
  RCN_CHANGECURTAG =     11; // ���������� ������� ����� = ������ ����� + a_dwParam
  RCN_CHANGETAGRANGE =   12; // �������� ������� ����������� ��� ���� use TAGRANGEDATA
  RCN_RESORTTAGS =       13; // ��������������� ����
  RCN_LAUNCHWINPOS =     14; // ��������� ����� ��������� ������������������ ����������
  RCN_TEST =             15; // ��������� ��������� ����������������
  RCN_SAVECONFIG =       16; // ��������� ������������
  RCN_CLOSEALLPLUGINS =  17; // ������� ��� ���������� �������
  RCN_OPENPLUGIN =       18; // �������� � ������ �������

  RCN_REG_DF_CHANGER =    19; // ���������������� ������, ��������� ������� �����
	RCN_PLAY =              20; // ����� ������ ���������������
	RCN_ON_PLAY_MODE =      21; // ����������� � ������������ � ����� ���������������
	RCN_ON_REC_MODE =       22; // ����������� � ������������ � ����� ������
	RCN_SUBSCRALARMSEVENT = 23; // ����������� �� ����������� � ������������ �������
	                            // ������ ������ ������������ IAlarmEventHandler
	RCN_UNSUBSCRALARMSEVENT = 24; // ����������� �� ����������� � ������������ �������
	RCN_PLAY_SOUND_NOTIFY =   25; // ��������� �������� �����������, ������ @ref RCSNDNOTIFY
	RCN_ADD_SOUND_NOTIFY =    26; // �������� �������� ����������� � �������, ������ @ref ALARMSOUNDINFO
	RCN_REMOVE_SOUND_NOTIFY = 27; // ������� �������� ����������� �� �������, ������ @ref ALARMSOUNDINFO

	RCN_INTERNAL_BASE            = $8000;
	RCN_UPDATEGROUPSLINKS        = $8001; // ������� ������ ������� �� ������ dwParam == ByNames:BOOL
	RCN_DRIVERSRESET             = $8002; // ������� ����� �������� @ref RCNDRIVERSRESETFLAGS
	RCN_DRIVERSCONFIG            = $8003; // ������� ������ �������� @ref RCNDRIVERSCONFIGFLAGS
	RCN_CHECKTAGSNAMES           = $8004; // ��������� ����� ����� �� ������������
	RCN_BROADCAST                = $8005; // ��������� ���� �����������
	RCN_SWITCH_CALIBR_MODE       = $8006; // ������������� � ����� ����������

	RCN_DEACTIVATE_DEVICES       = $8007; // ��������� ����� ������ �� ���� ��������� ���
	                                     // ����� ��� ��������������� TRUE/FALSE
	RCN_RUN_IN_RC_THREAD         = $8008; // ����� ������ ������� � ����� ��������� � ����������� RCTRCOMMAND
	                                     // ���� RCTRCOMMAND.pPlgDest==0 �� ����������� ����
	RCN_ACTION_POPUP_SETUP       = $8009; // ��������� ������� � ������� ������������� ����� ���� ��������� ���������
	RCN_ACTION_POPUP_SEL_FRAME   = $800A; // ��������� ������� � ������� ������������� ����� ���� ������ ����� ������

	RCN_ACTION_SAVE_CFG          = $800B; // ��������� ������� � ������� ������������� ���������� ������������ rc
	RCN_ACTION_SAVE_CFG_AS       = $800C; // ��������� ������� � ������� ������������� ���������� ������������ rc
	RCN_ACTION_LOAD_CFG          = $800D; // ��������� ������� � ������� ������������� ������� ������������ rc
	RCN_DRIVER_RESET_EX          = $800E; // ����������� ����� ��������, � ��������� ���������� ����� ����������
	RCN_DRIVER_CONFIG_EX         = $800F; // ����������� ������ ��������, � ��������� ���������� ����� ����������
	RCN_MARK_DEVICE_FOR_RESET    = $8010; // ���������� �������, ���� �� ����� ����������� ���������� �� ������ �� ���������
	RCN_RESET_CONFIG             = $8011; // �������� ������������
	RCN_ACTION_CLOSE_APP         = $8012; // ��������� ������� � ������� ������������� ���������� ���������
	RCN_FORCE_CLOSE              = $8013; // ��������� � �� ���������� ������ � ������
	RCN_RESET_DFT_INDEX          = $8014; // ������� ����������� ����� ��������� � ��������� �������� ����������� ������
	RCN_ON_BEFORE_CLOSE_UISERVER = $8015;


   //����������������� �����������
  RCBC_PLUGINSLISTUPDATED = 0;

   //�������� ���������
  RCPROP_HOSTDEVICE =            0;  // [in] ����� ���������� ����� [out] ��������� �����
  RCPROP_DATAFOLDER =            1;  // ������� ������� [in] [out]
  RCPROP_STARTRECLEVCTRLPROPS =  2;  // �������� ������ ������ �� ������ RCLEVELCONTROLPROPS [out]
  RCPROP_STARTTIME =             3;  // ����� ������ ���������/����������� VT_FILETIME [out]
  RCPROP_CALIBRDBNAME =          4;  // ��� �������� � ������������� ���������������� [out] VT_BST
  RCPROP_REFRESHPERIOD =         5;  // ������ ����������/������ ����� ������ � ��������   [in][out] VT_R8
  RCPROP_VIEWTIME =              6;  // ����� �����������/������ ������� ������ � ��������   [in][out] VT_R8
  RCPROP_VERSION =               7;  // ������ ���������                                           [out] VT_I4
  RCPROP_TAGSSORTMODE =          8;  // ����� ���������� �����                                 [in][out] VT_I4
  RCPROP_TIMERTICPERIOD =        9;  // �������� ������� ��� �����������
  RCPROP_MODIFYFRAMENAME =       10; // ������������� �������������� ��� ����� ��� ������
  RCPROP_CONVERTTOUSML =         11; // ��������������� � ���� �� ��������� ������
  RCPROP_ENABLEDLEVELSTARTREC =  12; // �������� ����� ������ �� ������
  RCPROP_TRIGGERSTART =          13; // ��������� ���������� ������
  RCPROP_ENABLEDAUTOSTOPTIME =   14; // �������������� ������� ������ �� �������
  RCPROP_AUTOSTOPTIME =          15; // ������ ��� ��������������� �������� ������ �� �������
  RCPROP_CONFIGNAME =            16; // ��� ����� ������������
  RCPROP_UISERVERLINK =          17; // ����� �� UI ������
  RCPROP_SUMMARYDATAFLOW =       18; // ��������� ����� ������
  RCPROP_PROJECTNAME =           19;
  RCPROP_CURRENTTAGNAME =        20; // ��� �������� ���� [in, out] VT_BSTR
  RCPROP_CHANGEDSETTINGS =       21; // ���������� ��������� SCF_XXX [in, out] U32
  RCPROP_ENABLEDLEVELSTOPREC =   22; // �������� ���� ������ �� ������
  RCPROP_STOPRECLEVCTRLPROPS =   23; // �������� ����� ������ �� ������ RCLEVELCONTROLPROPS        [out]
  RCPROP_PREHISTORY_ENABLED =    24; // ��������� ����������                                       [in, out] VT_BOOL
  RCPROP_PREHISTORY_TIME =       25; // ����� ���������� � ��������                                [in, out] VT_I4
  RCPROP_RESET_TIME_AT_START   = 26; // ������ ����� ��������� ������� ��� ������ ���������/������ [in, out] VT_BOOL
  RCPROP_TRIGGER_START_MODE    = 27; // ����� ��� ����������� ������ 1 - "1", 0 - "0"
  RCPROP_CALIBRATOR            = 28; // ������ �� ������ ���������� [out] VT_UNK
	RCPROP_ENABLE_SPACE_RESERVE  = 29; // ��������� ��������������� �������������� ����� �� ����� [in, out] VT_BOOL
	                                   // ��� ������. "�������� ������"
	RCPROP_SPACE_RESERVE_TIME    = 30; // ����� ������� ��� �������������� � �������� [in, out] VT_R8
	RCPROP_SECURITY_STATE        = 31; // ����� ��������� ������ �������������/������� [out]VT_UI4
	RCPROP_SYS_LOG               = 32; // ��� ��������� ������� [out] VT_UNK
	RCPROP_PUT_CFG_FILE_TO_DATA  = 33; // ���� ������������� ���������� ����� ������������
	                                   // ��������� � ������� [in, out] VT_BOOL
	RCPROP_FRAME_NAME            = 34; // ��� ����� ������, ��� ���� [in, out] VT_BSTR
	RCPROP_LAST_DATA_LOCATION    = 35; // ����������������� ��������� ���������� ������ [out] VT_BSTR
	RCPROP_USER_LOG              = 36; // ������ (��������) ��������� ���� [out]VT_UNK
	                                   // ��� ������� � ��������� ������ ���� ���� � ����
	                                   // ���� ����� ��� ��� ���� �������� ����� ������
	RCPROP_BATTERY_INFO          = 37; // ���������� � ��������� ������� [out] VT_BSTR
	RCPROP_MAIN_TAGS_TABLE       = 38; // ������� ������� ImeTagsTable [out] VT_UNK
	RCPROP_FLUSH_BEFORE_CLOSE    = 39; // ������ ����� ������� ����� ��������� ������ [in, out] VT_BOOL {v: 3.0.4.53}
	RCPROP_WRITE_CODES           = 40; // ����� ������ � ����� ���������� ��� ��������
	                                   // ����� [out] VT_BOOL {v: 3.0.4.65, 3.0.5.2}
	RCPROP_ALARM_GISTER_BY_RANGE = 41; // ����� ���������� ����������� ������� -
	                                   // �� �������� ��� �� ���������  [out] VT_BOOL {v: 3.0.6.15, 3.0.5.16}
	RCPROP_PREVIEW_ENABLED       = 42; // ������ ������ [out] VT_BOOL {v: 3.0.7.21}
	RCPROP_SAVE_CONFIG_DIALOG_AT_EXIT = 43; // ���������� ���� ���������� ������������ ��� ������, ���� ���� ���������
	                                        // ������������ ��� �������� ������� [out] VT_BOOL {v: 3.0.7.40}
	RCPROP_VIEW_AT_STOP          = 44; // ������� � ����� ��������� ��� ��������� ������ �� ������� [in, out] VT_BOOL {v: 3.0.9.24}
	RCPROP_DATAF_TEMPLATE_MANAGER = 45; // �������� �������� �������� �������� [out] VT_UNK {v: 3.3.0.37
	RCPROP_DATAF_TEMPLATE_ENABLED = 46; // ��������� ��������� �������� ��������� ������ [in, out] VT_BOOL {v: 3.3.0.39,

  RCPROP_INTERNAL_BASE             = $8000;
  RCPROP_USERMODE                  = $8001; // ����� ������������ Simple/Advanced/More [out] VT_I4
  RCPROP_SHOWDISBALANCE            = $8002; // ���������� ��������� ����� ������������ [out] VT_BOOL
  RCPROP_ENABLEDRECPAUSE           = $8003; // ��������� ����� �� ����� ������ [out] VT_BOOL
  RCPROP_LOST_SRC_TG_CNT           = $8004; // ������� ������� ������������ �� ���������� [out] VT_UI4
	RCPROP_PLAYMODE_ENABLED          = $8005; // ���������� ��������� ������ ��������������� [in, out] VT_BOOL
	RCPROP_TIME                      = $8006; // ��������� ����� ��������
	                                          // �������������� ��������� ������ �� ������� ���������������,
	                                          // ������, ��� �������� (���� ���� ������� ���������� ��������) [in, out] VT_R8
	RCPROP_INCLUDE_DEV_NAME_IN_TAG   = $8007; // ������������ ������������ ��������� � ����� ������
	                                          // ��-�������� [out] VT_BOOL
	RCPROP_AUTO_STORE_VISUAL_CHANGES = $8008; // ��������� �� ������������� ��������� � ����������� �����
	RCPROP_TIME_MASHINE_PROPS        = $8009; // ������ �� ��������� ������ ������� [in, out] IUnknown
	RCPROP_FLUSH_SCALAR_TAGS         = $800A; // ���� ��������������� ������ (�����) ������ ��������� ����� [out] VT_BOOL
	RCPROP_FLUSH_SCALAR_PERIOD       = $800B; // ������ ��� ��������������� ������ (�����) ������ ��������� ����� [out] VT_I4 [��]
	RCPROP_TIMESTAMP_AT_RECORD_START = $800C; // ����������� ����� ������ ����������� � .mera ����� ��� ������ ������
	                                          // ������ ��� �������� � ����� ��� �������� ������.
	                                          // ��������� ����� ������������ ����� �������� � ���������� ��� �������  [out] VT_BOOL
	RCPROP_USE_NEW_TRENDS            = $800D; // ����������� ���������� ����� ����������� ��� ����������� ���������� ����������������� ������� ������� [in,out] VT_BOOL
	RCPROP_WRITE_TARED               = $800E; // ������ ������ � ������������� ���� ���� ��������� ����� �� � ��  [in,out] VT_BOOL
	RCPROP_DATA_FOLDER_TEMPLATE      = $800F; // ������ ������������� �������� ��������[out] VT_UNK {v: 3.3.0.37,
	RCPROP_DATA_FRAME_TEMPLATE       = $8010; // ������ ������������� ����� ����� ������ [out] VT_UNK {v: 3.3.0.37,

	RCPROP_GUICONFIGNAME             = $8011; // ��� ����� ������������ ���� (.guis). ����������� ��� ������� �� �������� �����/���� [out] VT_BSTR
	RCPROP_ALWAYS_SAVE_CONFIG        = $8012; // �������������� ���������� ������������ �� ������ �� ���������/�������� [out] VT_BOOL {v: 3.3.1.10}
	RCPROP_ENABLE_FORCED_FLUSH       = $8013; // �������������� ����� ������� ������ �� ���� [out] VT_BOOL {since v: 3.3.2.34}
	                                          // ������ ������������� ����� ������� ������������ ����� ������� ������ ������ �� ���� (FlushFileBuffers)
	                                          // ��� �������� � �������� ���������� ������ � ������������� ����� ��������� �������
	RCPROP_DATA_FLOW_CHECK_BY_TIME_ENABLED = $8014; // ���� ����������� �������� ������� ������ �� ������ ������� �����. �������� ��������� � �������������� ������ � �.�. (v:3.3.3.4)
	                                                // �� ��������� VARIANT_TRUE, [in/out] VT_BOOL recorder.cfg::DataFlowCheckByTime=Enabled
	XRCPROP_SUPPRESS_CRASH_AT_EXIT   = $8015; // "���������" �������� ��������������� ��� ������� ������ ������ ������� ���������
                                            // [in/out] VT_BOOL recorder.cfg::SuppressCrashAtExit=Disabled
                                            // � ��������� ���������� ���������
                                            // �� ��������� VARIANT_FALSE
                                            // ���������� ����������� ��� ������� ����
                                            // � ������ 3.3.4.26a


  // ������ ���������� ����� ��� �������� RCPROP_TAGSSORTMODE
  SRTMD_BY_NAME =         0; // ����������� �� �����
  SRTMD_BY_ADDRESS =      1; //             �� ����������� ������
  SRTMD_BY_DEVICENAME =   2; //             �� ����� ���������� ���������

   //����� ��� ������� DriverReset (RCN_DRIVERSRESET)
  DRF_SHOWPROCINDICATOR = 1; // ������������ ������� ������ ��������
  DRF_ONLYHOST =          2; // ������ ����� ������ �����

  // ����� ��� ������� DriverConfig (@ref RCN_DRIVERSCONFIG)
	DCF_SHOWPROCINDICATOR = $0001; // ������������ ������� ������� ��������
	DCF_ONLYHOST          = $0002; // ������ ������ ������ �����

   //����� ������� ���������� ������� ������������
   //Config mode sharing flags
  CMSF_CONFIGCHANGED   = $0001; //�������������� ��������� ����� �������� ������������
  //����� ������� �������� ������� ��������
  IESF_DEFAULTSETTINGS = $0001; //������� �������������/�������������� ���������
                                //������������ �� ���������
  IESF_LOCAL_MODE =      $0002;

   //���� ��������� �������� � ��������� ���������
  //���������� ������ � ������������ PN_LEAVERCCONFIG
  SCF_NOTING      = $0000;
  SCF_TAGSLIST    = $0001;
  SCF_TAGSCONTENT = $0002;

   //����������� ������ ������
  STDSTRSIZE = 256;

   //����������� ���������� - ����� ����������� � ���������
  VSN_ENTERRCCONFIG = 0;  //�������� ������� � ����� ���������
  VSN_LEAVERCCONFIG = 1;  //�������� ����� �� ������ ���������
  VSN_CHANGECURTAG  = 2;  //�������� ������� ���, � ��������� dwData
                           // ����� ����, ������� ���������� ���������.

  VSN_RCSAVECONFIG  = 8;  //�������� �������� ������������
  VSN_RCLOADCONFIG  = 9;  //�������� �������� ������������

  VSN_RCSTART       = 3;  //�������� ������� � ����� ���������
  VSN_RCPLAY        = 4;  //�������� ������� � ����� ���������������
  VSN_RCSTOP        = 5;  //�������� ����������
  VSN_BEFORE_RCSTART= 14; //�������� ��������� � ����� ���������
  VSN_BEFORE_RCSTOP = 15; //�������� ���������������
  VSN_ABORT_RCSTART = 16; //�������� ������ ���� ��������

   // �������������� �����������
  VSN_SPECIFIED =      $4000; //
  VSN_RESIZE =         $4001; //������� �� ��������� ������� ���� ���������,
                               //  ��������� dwData �������� ����� ���������
                               //  ���� TRect.
  VSN_CHANGEVIEWTIME = $4002; //����� ��������� �����������
  VSN_CHANGETIMESHIFT= $4003; //����� �������� ��������� �����������
  VSN_CHANGERCSTATE  = $4004; //���������� ��������� Recorder �
                               //  dwData ����� ���������.
  VSN_EditIFrm  = $4008;  // �������������� ������������� ��������???
  VSN_USER =           $7000; //�������� ����������� VFN_USER+XXXX

  /// ����� ���������������� �������
	UPROPFLAG_PERMANENT = $0001; //< ���������� ��������, ����������� � ����������� �������
	UPROPFLAG_MERA_FILE = $0002;  //< �������� ����������� � ������� � .mera






type

   //��� ������ �� ���������� ������ - ���������
   HARDLINK = DWORD;
   //������������ ����
   LEVEL = (
      LV_EQUAL,
      LV_ABOVE,
      LV_BELOW
   );

  //typedef struct tagRCLEVELCONTROLPROPS{
  //	ITag*     pTag;
  //	char      pchTagName[STDSTRSIZE];
  //	double    dblLevel;
  //	LEVEL     level;
  //}RCLEVELCONTROLPROPS,*PRCLEVELCONTROLPROPS;
   tagRCLEVELCONTROLPROPS = record
     pTag: ITag;
     pchTagName: array[0 .. STDSTRSIZE - 1] of ansichar;
     dblLevel: double;
     level: LEVEL;
   end;

  RCLEVELCONTROLPROPS = tagRCLEVELCONTROLPROPS;
  PRCLEVELCONTROLPROPS = ^RCLEVELCONTROLPROPS;


  //��������� ��� ���������
  //RCN_CHANGETAGRANGE  -  �������� ������� ����������� ��� ����
  tagTAGRANGEDATA = record
    pTag: ITag;       {������ �� ��������� ����}
    dblBX: double;    {������� �����}
    dblBY: double;    {������� ������}
    dblEX: double;    {������� ������}
    dblEY: double;    {������� �����}
  end;
  TAGRANGEDATA = tagTAGRANGEDATA;
  PTAGRANGEDATA = ^TAGRANGEDATA;

  //��������� ��� ��������� Recorder`�
  RECORDERSTATE = DWORD;
  //��������� ��������� �����������
  IVForm = interface;
   //��������� ��� ���������� ����� �������������� ��
   IRecorder = interface
   ['{EE880620-53EF-11d7-9244-00E029288A7F}']
      // ���������������� �������� �����������
      function RegisterIForm(const pIVForm: IVForm;
                            const lParam: longint): boolean; stdcall;
      // ��������� �������� ����������� �� ������������������ ��������
      function UnregisterIForm(const pIVForm: IVForm): boolean; stdcall;

      // �������� �������� ����������� �� �����
      function GetIFormByName(const pchName: LPCSTR): pointer{IVForm}; stdcall;
      // �������� �������� ����������� �� �������
      function GetIFormByIndex(const nIndex: ULONG): pointer{IVForm}; stdcall;

      //�������� ��� �� �����
      function GetTagByName(const pchName: LPCSTR): pointer{ITag}; stdcall;
      //�������� ��� �� �������
      function GetTagByIndex(const nIndex: ULONG): pointer{ITag}; stdcall;
      //�������� ����� �����
      function GetTagsCount: ULONG; stdcall;

      //�������� ������ �� �������
      function GetModuleByIndex(const nHostDeviceNum: ULONG;
                                const nIndex: ULONG): pointer{IModule}; stdcall;
      //�������� ����� �������
      function GetModulesCount(const nHostDeviceNum: ULONG): ULONG; stdcall;

      //�������� ������ �� �������
      function GetGroupByIndex(const nIndex: ULONG): pointer{ITagsGroup}; stdcall;
      //�������� ����� ����� �����
      function GetGroupsCount: ULONG; stdcall;

      //�������� ��������� ���������
      function GetState(const rsMask: RECORDERSTATE): RECORDERSTATE; stdcall;
      //��������� ��������� ���������
      function CheckState(const rsState: RECORDERSTATE): boolean; stdcall;

      //�������� ��� ����� ��� ���������� �������
      function GetSignalFrameName: LPCSTR; stdcall;
      //�������� ��� ����� ��� ���������� �������
      function GetSignalFolderName: LPCSTR; stdcall;

      //������� ����� ���
      function CreateTag(const pchName: LPCSTR; const ls: LINKSTATE;
                         const a_pParams: pointer): pointer{ITag}; stdcall;
      //���������� ����� ���
      function CloseTag(const piTag: ITag): boolean; stdcall;

      //��������� �������� � ����� �������
      function Notify(const dwCommand: DWORD; const dwParam: DWORD): boolean; stdcall;

      {��������� ���� ��������� ������}
      procedure SetLastError(const dwErrorCode: DWORD); stdcall;
      {��������� ���� ��������� ������}
      function GetLastError: DWORD; stdcall;
      {������������ ������ �������� ������ �� ����}
      function ConvertErrorCodeToString(const dwErrorCode: DWORD): LPCSTR; stdcall;

      // �������� ��������
      function GetProperty(const dwPropertyID: DWORD;
                          var Value: OleVariant): HRESULT; stdcall;
      // ������ ��������
      function SetProperty(const dwPropertyID: DWORD;
                           {const} Value: OleVariant): HRESULT; stdcall;

      //���������� ���������
      //������ ������� ������� ���������� ���������
      function SetEnvironmentCurDir(const pchDir: LPCSTR): boolean; stdcall;
      //�������� ������� ������� ���������� ���������
      function GetEnvironmentCurDir(const pchDir: LPCSTR;
                                   const nLength: integer): boolean; stdcall;

      //�������� �������� ���������� ��������� � ���� ��������
      function GetEnvironmentVar(const pchVarID: LPCSTR;
                                var varVal: OleVariant): boolean; stdcall;
      //���������� �������� ���������� ��������� � ���� ��������
      function SetEnvironmentVar(const pchVarID: LPCSTR;
                                var varVal: OleVariant): boolean; stdcall;

      //�������� �������� ���������� ��������� � ���� long
      function GetEnvironmentLong(const pchVarID: LPCSTR;
                                 var lVal: longint): boolean; stdcall;
      //���������� �������� ���������� ��������� � ���� long
      function SetEnvironmentLong(const pchVarID: LPCSTR;
                                 const lVal: longint): boolean; stdcall;

      //�������� �������� ���������� ��������� � ���� double
      function GetEnvironmentDouble(const pchVarID: LPCSTR;
                                   var dblVal: double): boolean; stdcall;
      //���������� �������� ���������� ��������� � ���� double
      function SetEnvironmentDouble(const pchVarID: LPCSTR;
                                   const dblVal: double): boolean; stdcall;

      //�������� �������� ���������� ��������� � ���� char*
      function GetEnvironmentString(const pchVarID: LPCSTR; const pchVal: LPCSTR;
                                   var pnLength: integer): boolean; stdcall;

      //���������� �������� ���������� ��������� � ���� char*
      function SetEnvironmentString(const pchVarID: LPCSTR;
                                   const pchlVal: LPCSTR): boolean; stdcall;

      //�������� � ��� ������ � ��������� �������
      function LogMessage(const pchMessage: LPCSTR): boolean; stdcall;
      //�������� ����������� (handle) �������� ���� ���������� 
      function GetHWND: HWND; stdcall;
      //�������� ������ �� ��������� ���������� � ������ ������ ����
      function GetCurrentTag: pointer{ITag}; stdcall;
      //������� ���
      function SetCurrentTag(const nIndex: ULONG): HRESULT; stdcall;

      //�������� ������ ���� �� ���������
      // v1.06.2+
      function GetTagIndexByPointer(const pTag: ITag): integer; stdcall;

      //�������� ����� ���������
      // v1.09
      function GetDevicesCount: integer; stdcall;

      //�������� ��� ����� ������� *.cfg
      // v1.09.2.3
      function GetProjectName: LPCSTR; stdcall;

      //�������� ������ ����
      // v1.10
      function GetRcBasePath: LPCSTR; stdcall;

      //���������� �������� �����
      //�������� ������ �� �����
      // v1.10.1
      function GetGroupByName(const pchName: LPCSTR): pointer{ITagsGroup}; stdcall;
      //������� ������
      function DeleteTagsGroup(const pGrp: ITagsGroup): HRESULT; stdcall;
      //�������� ������
      function CreateTagsGroup(const a_pchName: LPCSTR): pointer{ITagsGroup}; stdcall;

      //������������� ���������
    	// IESF_DEFAULTSETTINGS = 0x0001,  ///< ������� �������������/�������������� ��������� ///< ������������ �� ���������
    	// IESF_LOCAL_MODE = 0x0002		///< ����� ���������� ������� / ��������. ���� ������� ���������, ��� �������� ������������ � ������ ������� �������
			// ��� ��� ���������� �������� ���������� ����������� ����������� �� �������� �������� �� ����������� ������
      // ������� ��������/���������� ��� IESF_DEFAULTSETTINGS+IESF_LOCAL_MODE
      function ImportSettings(const pchName: LPCSTR;
                             const dwFlags: DWORD): HRESULT; stdcall;
      //�������������� ���������
      function ExportSettings(const pchName: LPCSTR;
                             const dwFlags: DWORD): HRESULT; stdcall;

      //������ ������������� ������� � ���������� ���������
      //����� ������������ ������������� ������������ ��� ����������������

      //����� � ����� ���������
      function EnterConfigMode(const pInitiator: IUnknown;
                              const dwFlags: DWORD): HRESULT; stdcall;

      //����� �� ������ ���������
      function LeaveConfigMode(const pInitiator: IUnknown;
                              const dwFlags: DWORD): HRESULT; stdcall;

      //�������� ������ ��������� ������ ���������
      function GetConfigModeState(var dwFlags: DWORD): ULONG; stdcall;

      //�������� ���������� ������ ���������
      function GetConfigModeInitiator: pointer{IUnknown}; stdcall;

      //���������� ��� ������ � ����������� ��������

      //�������� ������ ��������� �������
      function dvchGetAvailableChansCount: ULONG; stdcall;
      //�������� ������������� ����������� ������ �� �������
      function dvchGetChansList(var pIDList: HARDLINK): HRESULT; stdcall;
      //�������� ����� ����������� ������ �� ��������������
      function dvchGetAddress(const hlID: HARDLINK; const pchAddress: LPCSTR;
                             var nBuffLen: integer): HRESULT; stdcall;
      //�������� �������� ���������� ��������� ����������� ������ �� ��������������
      function dvchGetDeviceName(const hlID: HARDLINK; const pchDeviceName: LPCSTR;
                                var nBuffLen: integer): HRESULT; stdcall;
      //�������� �������� ���������� ��������� ����������� ������ �� ��������������
      function dvchGetDeviceInfo(const hlID: HARDLINK; const pchDeviceInfo: LPCSTR;
                                var nBuffLen: integer): HRESULT; stdcall;

      function MultiTagSynchroReadDataBlock(const dwCount: DWORD;
           var pTag: ITag; const dwPortionLen: DWORD; var pdblFreq: double;
           var ppdblData; const boolViaTransformer: BOOL): HRESULT; stdcall;

    // since v 1.19

    //������������ ������ ���� � ����� ������������ ���������
    function MakeFullPath(const pchLocalPath: LPCSTR): LPCSTR; stdcall;

    //������� ���� ��������� ���������
    procedure PushState( const rsState: integer); stdcall;
    //�������� ���� ��������� ���������
    procedure PopState( const rsState: integer); stdcall;

    //�������� ������ �� ���������� �� �������
    function GetDeviceByIndex( var pDevice: IDevice;
                               const ulIndex: ULONG): HRESULT; stdcall;

    //�������� ��� ������������� ���������� �� �������
    function GetDeviceInitStateByIndex(const ulIndex: ULONG): ULONG; stdcall;



    //�������� ���������� � ������ ���������
    function AddDevice( pDevice: IDevice; const ulIndex: ULONG): HRESULT; stdcall;
    //������� ���������� �� ������ ���������
    function RemoveDevice( const ulIndex: ULONG): HRESULT; stdcall;

    function GetDeviceControlClassObject( var ppv): HRESULT; stdcall;
    function GetPluginsControlClassObject( var ppv): HRESULT; stdcall;

    function CreateInfoFile( const pchPath: LPCSTR;
                             pGroup: ITagsGroup): HRESULT; stdcall;

    //������ ��� ������ ��� ���������� �������
    function SetSignalFrameName( const pcFrameName: LPCSTR): HRESULT; stdcall;
    
    //������� ������� � �������� � ������� ������� ���������/������
    function GetTimeCounter: double; stdcall;

    //�������� ���������� ������� �������� �������,
    //����� ����������� ������������ ��������� ������
    function GetSummaryReceivedPacketsCount: ULONG; stdcall;

    //�������� ������� �������� ������� �� � ����� �������� ResetReceivedPacketsCount
    //����� ����������� ������������ ��������� ������
    function GetReceivedPacketsCount: ULONG; stdcall;
    function GetSummaryCounter: ULONG; stdcall;
    function ResetReceivedPacketsCount: ULONG; stdcall;

    function IncSummaryTime( const liVal: LONGLONG): ULONG; stdcall;

    function GetWorkTime( var dblTime: double): HRESULT; stdcall;

    function ResetWorkTime: HRESULT; stdcall;

    //�������� ������� �������� ���������� �� ������ ����������� IRQ
    function GetPerformanceTimeIRQ( var dblTime: double): HRESULT; stdcall;

    function ResetPerformanceTimeIRQ: HRESULT; stdcall;

    //�������� ������� �������� ���������� �� ������ ���� ��������
    function GetPerformanceTimeDriver( var dblTime: double): HRESULT; stdcall;

    function ResetPerformanceTimeDriver: HRESULT; stdcall;

    //�������� ������� �������� ����������
    function GetCPUUsage( var pdblCPU: double): HRESULT; stdcall;

    //�������� �������� ����� ���������� �� ��������������
    function dvchGetDeviceSerialNumber( const hlID: HARDLINK;
             pchDeviceSerialNumber: LPCSTR;
             var nBuffLen: integer): HRESULT; stdcall;
    /// since v 2.7.0.9
    /// �������� ����� ���������� ������ �� ����������
    /// ������������ ��� ����������� ����� � �����������
    //virtual HRESULT     STDMETHODCALLTYPE GetDeviceLastActivityTime(ULONG a_ulIndex, double* a_pdblTime)=0;
    function GetDeviceLastActivityTime( a_ulIndex: ULONG; var a_pdblTime: double): HRESULT; stdcall;

    /// since v 2.7.0.15
    ///�������� �������� ����������� ������ �� ���������
    //virtual HRESULT     STDMETHODCALLTYPE dvchGetChanInfo(HARDLINK a_hlID, char* a_pchChanInfo, int* p_nBuffLen)=0;
    function dvchGetChanInfo( a_hlID: HARDLINK; var a_pchChanInfo: double; pchName: LPCSTR; var p_nBuffLen:integer): HRESULT; stdcall;

    /// since v 2.7.1.0
    /// ���������/��������� ��� ���������� ����� �����
    //virtual HRESULT     STDMETHODCALLTYPE EnableCommonStartForDevice(IDevice* a_pDevice, VARIANT_BOOL a_vbEnable)=0;
     function EnableCommonStartForDevice( a_pDevice: IDevice; a_vbEnable: VARIANT_BOOL): HRESULT; stdcall;

    /// ���������/��������� ��� ���������� ����� ����
    //virtual HRESULT     STDMETHODCALLTYPE EnableCommonStopForDevice(IDevice* a_pDevice, VARIANT_BOOL a_vbEnable)=0;
    function EnableCommonStopForDevice(a_pDevice: IDevice; a_vbEnable: VARIANT_BOOL): HRESULT; stdcall;
    /// since v 2.7.5.0
    ///������� ������� � �������� � ������� ������� ���������/������ � ����� ���
    //virtual double  STDMETHODCALLTYPE GetUTSTimeCounter() = 0;
    function GetUTSTimeCounter(): double; stdcall;
    /// �������� ��� �� ����� �� ����
    //virtual HRESULT			STDMETHODCALLTYPE RunFn(void* a_fn,void* a_param) = 0;
    function RunFn(a_fn:pointer; a_param:pointer): HRESULT; stdcall;
    /// ����������� ������� ����
    /// ��� ������� ���������� ��� ���� ������
    //virtual HRESULT			STDMETHODCALLTYPE Destroy() = 0;
    function Destroy(): HRESULT; stdcall;
    /// ��������� ������ ��� ���������� ��������� ������ ��������
    //virtual HRESULT			STDMETHODCALLTYPE GetPropertyAccess(IPropertyAccess** ppAccess, HANDLE h)=0;
    function GetPropertyAccess(ppAccess:pointer; g:cardinal): HRESULT; stdcall;

    ///������������ ������ ���� � ����� ������������ �������� ����� (data) sd:/Mera Files/Recorder
    //virtual const char* STDMETHODCALLTYPE MakeFullPathData(const char* a_pchLocalPath)=0;
    function MakeFullPathData(a_pchLocalPath:LPCSTR): HRESULT; stdcall;

    /// since v 3.0.6.16
    ///�������� �������� ����������� ������ �� ���������
    //virtual HRESULT     STDMETHODCALLTYPE dvchGetChanProperty(HARDLINK a_hlID, ULONG a_nPropID, VARIANT& a_varProp) = 0;
    function dvchGetChanProperty (a_hlID:HARDLINK;a_nPropID:ULONG; var a_varProp: OleVariant): HRESULT; stdcall;
    /// since v 3.0.7.71
    /// ����� ��� �� TAGID
    //virtual HRESULT     STDMETHODCALLTYPE GetTagByTagId(TAGID id, ITag** ppTag) = 0;
    function GetTagByTagId (id: TAGID; var ppTag: ITag): HRESULT; stdcall;
   end;

   //��� ��� ������ � �������� ������ �� ����
   TagsArray = array[0..0] of ITag;

   //��������� ��� ���������� ������������������� ����������� �����������
   IVForm = interface
   ['{95001263-E83C-11d6-9243-00E029288A7F}']
      //�������� ��� ����� ������ ���� ����������, ������������ ��� �����������
      function GetName: LPCSTR; stdcall;
      //������������� �����
      function Init(pParent: IRecorder; hParent: HWND; lParam: longint): boolean; stdcall;
      //�������� HWND �����
      function GetHWnd: HWND; stdcall;
      //���������� ��� �������� �����
      function Close: boolean; stdcall;
      function Prepare: boolean; stdcall;
      function Update: boolean; stdcall;
      //����������� �����
      function Repaint: boolean; stdcall;
      //�������� � ����� ���������
      function LinkTags( var pTagsList: TagsArray;
                         var nTagsCount: ULONG): boolean; stdcall;
      //����������� �����
      function Activate: boolean; stdcall;
      //������������� �����
      function Deactivate: boolean; stdcall;
      //����� ���� ��������������
      function Edit: boolean; stdcall;
      //�������, �����������, �������
      function Notify(const dwCommand: DWORD; const dwData: DWORD): boolean; stdcall;
   end;

  ISettingsINI = interface
	['{4D6850A1-FED3-490c-A277-BC9AEA2C146F}']
		function WriteSettings(const pchPath:LPCSTR; const pchSection: LPCSTR):HRESULT;stdcall;
		// ��������� ���������
		function ReadSettings(const pchPath:LPCSTR; const pchSection:LPCSTR):HRESULT;stdcall;
  end;

/// @interface IUserProperties ��������� ����������������� ������ ������� � �������
///

  IUserProperties = interface
  ['{382A1241-052A-4bb6-8E71-DB0508E510B7}']
    //	const BSTR ,const VARIANT& , const ULONG  = 0
    function SetUserProperty(const a_pPropId:widestring; var a_varValue:OleVariant;const a_nFlags:ULONG):HRESULT;stdcall;
    /// ��������� �������� ��������
    /// ���� ������ �������� ����� �� ������������� ����� ����������
    /// S_FALSE
    function GetUserProperty(const a_pPropId:widestring; var a_varValue:OleVariant):HRESULT;stdcall;
    /// ��������� ����� ������������� �������
    function GetUserPropertiesCount(var a_pnCount:ULONG):HRESULT;stdcall;
    /// ��������� �������� �� �������
    /// ������������ ���� �������� ��� � �������� ��������
		// ULONG a_pnIndex,BSTR* const a_pbstrPropId,VARIANT& a_varValue
    function GetUserPropertyByIndex(a_pnIndex:ULONG; var a_pbstrPropId:TBStr; var a_varValue:OleVariant):HRESULT;stdcall;
  end;

const
  // {382A1241-052A-4bb6-8E71-DB0508E510B7}
  IID_IUserProperties: TGUID = (
    D1:$382A1241;D2:$052A;D3:$4bb6;D4:($8E,$71,$DB,$05,$08,$E5,$10,$B7));

  IID_IVForm: TGUID = (
    D1:$95001263;D2:$E83C;D3:$11d6;D4:($92,$43,$00,$E0,$29,$28,$8A,$7F));

  IID_ISettingsINI: TGUID = (
    D1:$4D6850A1;D2:$FED3;D3:$490c;D4:($A2,$77,$BC,$9A,$EA,$2C,$14,$6F));




implementation


end.
