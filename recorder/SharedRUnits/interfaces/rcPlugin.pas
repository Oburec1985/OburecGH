unit rcPlugin;

interface
uses
  windows, recorder, tags;

// ��������� Plugin.pas �� ����� �����. �������� ������!!!

type
/// ��������� ���������� �������/��������� ������ ������.
/// ��������� �� ��� ���������� ��� ��������� ����������� PN_BEFORE_START
  tagSTARTCTRL = record
    /// ������ ��������� � ������, ��������� ��� �������� ������
    dwSize:Longint;
    /// �����
    /// ��������� ������ ��������, ������...
    dwFlags:DWORD;
    /// ���� ����������, ���� ���� �� �������� ������� ��� ����� ����� �������
    /// � ��� ������� ������� ����������� PN_ABORT_RCSTART
    bContinueAction:BOOL;
    /// � ���������� PN_ABORT_RCSTART ����� ����� ������ �� ������ ����������� �������� ������
    pObject:IUnknown;
  end;
  ACTIONCTRL = tagSTARTCTRL;
  PACTIONCTRL = ^tagSTARTCTRL;
  STARTCTRL = tagSTARTCTRL;
  PSTARTCTRL = ^tagSTARTCTRL;

/// ��������� ���������� ������ ��������� ��� ������ ������.
/// ��� �� ����������� ��� ����������� � ����� �������� �������� ������
 tagDATAPLACEMENT = record
	/// ������� ������� // wchar - olechar
	bstrDataFolder:array of ansichar;
	/// ��� �����
	bstrFrame:array of ansichar;
 end;
 RCDATAPLACEMENT = tagDATAPLACEMENT;
 PRCDATAPLACEMENT = ^tagDATAPLACEMENT;

 //�������� ��������� ��� �������� ������ � ��������
 //PN_SYNCHRO_READ_DATA_BLOCK � �������� PN_EDIT_VIRTUAL_TAG_PROPS
 tagRCNOTIFY = record
    pSender: IUnknown;    //������ �� �������� �������
    nSubCommand: UINT;    //��� �������
    lParam: longint;      //��������� ���������
    dblParam: double;
    pvParam: pointer;
 end;
 RCNOTIFY = tagRCNOTIFY;
 LPRCNOTIFY = ^RCNOTIFY;

 //��������� ��� ������� �������� plug-in`�
 //������ ��������� ������� �� �������� �� ���������� � C++.
 //������� �������� �������� �������� � ������� C++, �� ����
 //������ �������������� ����������� ������ 0.
 tagPLUGININFO = record
    name:       array [0..100] of AnsiChar;  //������������
    describe:   array [0..200] of AnsiChar;  //��������
    vendor:     array [0..200] of AnsiChar;  //������������ ����� ������������
    version:    word; //����� ������
    subversion: word; //����� ���������
 end;
 PLUGININFO = tagPLUGININFO;
 LPPLUGININFO = ^PLUGININFO;


 // ��������� plug-in`� � ���������
 IRecorderPlugin = interface
 ['{5967D621-0C3B-11d7-9243-00E029288A7F}']
     // �������� �������
     function _Create(pOwner: IRecorder): boolean; stdcall;
     // ����������������
     function Config: boolean; stdcall;
     // ����� ���� ���������
     function Edit: boolean; stdcall;
     // ������
     function Execute: boolean; stdcall;
     // ������������ ������
     function Suspend: boolean; stdcall;
     // ������������� ������
     function Resume: boolean; stdcall;
     // ����������� � ������� ��������
     function Notify(const dwCommand: DWORD;
                     const dwData: DWORD): boolean; stdcall;
     // ��������� �����
     function Getname: LPCSTR; stdcall;
     // �������� ��������
     function GetProperty(const dwPropertyID: DWORD;
                          var Value: OleVariant): boolean; stdcall;
     // ������ ��������
     function SetProperty(const dwPropertyID: DWORD;
                          {const} Value: OleVariant): boolean; stdcall;

     // ������ ����� �� ��������� ������ �������
     function CanClose: boolean; stdcall;
     // ��������� ������ �������
     function Close:  boolean; stdcall;
 end;


const

/// ����� ��� @ref tagSTARTCTRL
//enum STARTCTRLFAGS {
	SCF_VIEW        = $0001;
	SCF_REC         = $0002;
	SCF_PLAY        = $0004;
	SCF_ABORT       = $0008;
	SCF_PROGRAMMING = $0010;
	SCF_STOP        = $0020;


//enum PLUGINTYPE{
  PLUGIN_CLASS = 0;
  PLUGIN_HANDLE = 1;

///����������� ��������
//enum PLUGIN_NOTIFY{
	PN_ENTERRCCONFIG =1; // �������� ������� � ����� ���������
	PN_LEAVERCCONFIG =2; // �������� ����� �� ������ ���������
	PN_CHANGECURTAG =3; // �������� ������� ���, data=ITag*
	PN_RCSTART =4; // �������� ������� � ����� ���������/������� ������
	PN_RCPLAY = 5; // �������� ������� � ����� ��������������� ������
	PN_RCSTOP = 6; // �������� ����������
	PN_UPDATEDATA = 7; // ��������� ���������� ������ �����, � data ���������� �����
	PN_SHOWINFO = 8; // �������� ���� ���������� � ������� � data HWND �������� ��� ���� ����������
	PN_RCSAVECONFIG =9; // �������� �������� ������������ (bool)data ������� �� �� �������
	PN_RCLOADCONFIG =10; // �������� �������� ������������
	PN_SYNCHRO_READ_DATA_BLOCK =11; // ���������� ������
	                              // RCNOTIFY rcn;
	                              // rcn.pSender = dynamic_cast<IUnknown*>(ITAG);
	                              // rcn.lParam = (long)a_dwPortionLen;
	                              // rcn.pvParam = a_pdblBuffer;
  // �������������� ����������� ������� ������������ ����
  // RCNOTIFY rcnrcn.pvParam=dynamic_cast<IUnknown*>(ITAG);
	PN_EDIT_VIRTUAL_TAG_PROPS =12;
	PN_IMPORTSETTINGS=13;// ������ ��������� ��� ����� �������
	PN_EXPORTSETTINGS=14;// ������� ��������� ��� ����� ��������
	PN_BEFORE_RCSTART=15;// �������� ��������� � ����� ���������/������� ������
	PN_BEFORE_RCSTOP=16; // �������� ���������������
	PN_ABORT_RCSTART=17; // �������� ������ ���� ��������
	PN_BROADCAST=18; // �������� ������������������ ���������
	PN_CUSTOM_BUTTON_CLICK=19; // ���� �� ������ ������������������ ��������
	                           // data==��������� �� ��������� CB_MESSAGE
	PN_CUSTOM_BUTTON_QUERY_STATE=20;
	PN_ENABLE_VTAG_SETUP_DLG =21; // ������ �� ���������� ������� �������
	                              // �� �������������� ������� ������������ ����
	                              // � data ������ �� IEnumUnknown �� ������� �������

	PN_EDIT_MULTI_VTAG_PROPS=22;     // ������ PN_EDIT_VIRTUAL_TAG_PROPS �� ��� ��������
	                              //  RCNOTIFY rcn;
	                              //  rcn.punkParam=IEnumUnknown �� ������� �������
	PN_QUERY_VTAG_INFO=23;           // ������ ���������� �� ������������ ������
	                              //  RCNOTIFY rcn;
	                              //  rcn.punkParam=ITag ������ �� ��� �� �������� �������������
	                              //  ����������
	                              //  � rcn.bstrParam ������ ����� �������� ����������
	                              //  ������ ���������� �� ����������� COM
	PN_REMOVE_VTAGS=24;              // ����������� �� ������������ �� ��������
	                              // ����������� ������� ������������� �������
	                              //  RCNOTIFY rcn;
	                              //  rcn.punkParam=IEnumUnknown �� ������� �������
	PN_RCINITIALIZED=25;             // ������������� ��������� ���������
	PN_ON_CHANGE_DATAPLACEMENT=26;   // ����������� � ����� �������� �������� � ����� ������
	                              // ���������� ������ �� DATAPLACEMENT
	PN_ON_BEFORE_FRAME_REMOVING=27;// ����������� ����� �������� ������� ������
	                              // ���� ������� ���-�� ����������� ������ ���� ������� � �������
	PN_ON_AFTER_FRAME_REMOVING=28; // ����� �������� ������ - ���� ���� �� ��� ������������
	PN_FILE_PROCESSING_COMPLETED=29; // �������� � ������ ������ ���������
	PN_ON_DESTROY_UI_SRV=30;      // ����������� � �������� ������� ���������� ������������
	                              // �� ������ ����������� ������ ��� ���, ������� ����
	                              // ����������������� �����, ������ � ��. ���������� �������
	PN_ON_SWITCH_TO_UI_THREAD=31; // ������������ ��������� � ������� ����, ����� ������ ���
	                              // ��� ������������� ������� � ��� ����
	                              // ���������� ���������� ��� �������� ������� � �� ������� �������
	PN_ON_CONFIG_MODE_COMPLETED=32; // ����� ��������� �������� ��� �������, ���� ��������� ���������
	                              // �� ����� ��������� ����������� ������� � ����� ���������
	                              // ���� ����� ���������� ����������� ������
	PN_ON_SWITCH_CALIBR_MODE=33;  // ����������� � ������������ ������ ����������
	PN_ON_RC_PROGRAMMING=34;      // ��������� � ��� ��� Recorder ��������� � ������ "�����" �������
	                              // ����� ������������������� ���� ��������� � ���� ����� ����������
	PN_ABORT_RC_PROGRAMMING=35;   // �������� ���������� � ������ ��������� ���� ��������
	PN_ON_UPDATE_SECURITY_STATE=36; // ����� �������� ������ ������������
	                              // ������ ������ �� ������� DWORD ����� ��������
	PN_ON_UPDATE_MF_TITLE=37;     // ���������� ���������� �������� ����
	                              // � ������ BSTR ������ �� ������ � ����������, ����� ���������
	PN_ON_REC_MODE=38;            // ����������� � ������������ � ����� ������
	PN_ON_PLAY_MODE=39;           // ����������� � ������������ � ����� ���������������
	PN_ON_POPUP_SETUP_DIALOG=40;  // �������� ��������� �������� ���� ���������
	                              // ��������� ������������ � ��������� ��������� (ACTIONCTRL) �����
	                              // �������� �������� � �������� �������� ���� ���� ���������
	PN_ON_POPUP_SEL_FRAME_DIALOG=41; // �������� ��������� �������� ���� ������ ����� ������
	                          // ��������� ������������ � ��������� ��������� (ACTIONCTRL) �����
	                          // �������� �������� � �������� �������� ���� ���� ���������
	PN_ON_ACTION_SAVE_CFG=42; // �������� ��������� ��������� ������������
	PN_ON_ACTION_SAVE_CFG_AS=43; // �������� ��������� ��������� ������������
	PN_ON_ACTION_LOAD_CFG=44; // �������� ��������� ��������� ������������
	PN_ON_CHANGE_FORMS=45; // ����� ��������� ����������:
	                    // - ����� ��������
	                    // - ������������/�����������
	PN_ABORT_RCSTOP=46; // �������� �������� ��������� ���� ��������
	PN_ON_ACTION_CLOSE_APP=47; // �������� ��������� ��������� ������
	PN_ON_ZBALANCE_VTAG=48; // ������� �� ������������ ���� ������������ ������
	PN_USER = $7000 ; // �������� ����������� PN_USER+XXXX


  //���� ���������������� ���������
  RCCT_FULLRESET =     0;
  RCCT_DEVICERESET =   1;
  RCCT_SOFTWARERESET = 2;
  RCCT_LINKSREFRESH =  3;

  //�������� ��������
  PLGPROP_STATUSSTRING = 0; // ������ ������� �������. �������������
                            // ���������� ��� ������������
  PLGPROP_INFOSTRING =   1; // ����������� ���������� � �������
  PLGPROP_STATE =        2; // ��������� �������
  PLGPROP_USER =         $7000; // �������� �������� PLGPROP_USER+XXXX

  //��������� �������
  PLGSTATE_SUSPENDED = 1; // ������ ������� �������������� �����

implementation

end.

