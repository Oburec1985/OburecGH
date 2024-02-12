{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ���������� ��� COM ������ plug-in`�                 }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}
unit plugin;
interface
{$ALIGN 8}
uses Windows, recorder, tags;
const
  //��������� ��������������� ����� plug-in`��
  PLUGIN_CLASS =  0;  //������ plug-in - �������� ���
  PLUGIN_HANDLE = 1;  //�� ������������

   //���� ��������������� ������� ��� plug-in`��
   PN_ENTERRCCONFIG =            0; // �������� ������� � ����� ���������
   PN_LEAVERCCONFIG =            1; // �������� ����� �� ������ ���������
   PN_CHANGECURTAG =             2; // �������� ������� ���, � ��������� dwData
                                    //    ����� ����, ������� ���������� ���������.
   PN_RCSTART =                  3; // �������� ������� � ����� ���������/������� ������
   PN_RCPLAY =                   4; // �������� ������� � ����� ��������������� ������
   PN_RCSTOP =                   5; // �������� ����������
   PN_UPDATEDATA =               6; // ��������� ���������� ������ �����, � data ���������� �����
   PN_SHOWINFO =                 7; // �������� ���� ���������� � �������
   PN_RCSAVECONFIG =             8; // �������� �������� ������������
   PN_RCLOADCONFIG =             9; // �������� �������� ������������
   PN_SYNCHRO_READ_DATA_BLOCK = 10; // ���������� ������
                                    //  RCNOTIFY rcn;
                                    //  rcn.pSender=dynamic_cast<IUnknown*>(ITAG);
                                    //  rcn.lParam=(long)a_dwPortionLen;
                                    //  rcn.pvParam=a_pdblBuffer;
   PN_EDIT_VIRTUAL_TAG_PROPS =  11; // �������������� ����������� �������
                                    // ������������ ����
                                    //  RCNOTIFY rcn;
                                    //  rcn.pSender=dynamic_cast<IUnknown*>(ITAG);
   PN_IMPORTSETTINGS =          12; // ������ ��������� ��� ����� �������
   PN_EXPORTSETTINGS =          13; // ������� ��������� ��� ����� ��������
   PN_BEFORE_RCSTART =          14; // �������� ��������� � ����� ���������/������� ������
   PN_BEFORE_RCSTOP =           15; // �������� ���������������
   PN_ABORT_RCSTART =           16; // �������� ������ ���� ��������
   PN_BROADCAST =               17; // �������� ������������������ ���������
   PN_CUSTOM_BUTTON_CLICK =     18;
   PN_CUSTOM_BUTTON_QUERY_STATE = 19;
   PN_ENABLE_VTAG_SETUP_DLG =   20; // ������ �� ���������� ������� �������
    	                              // �� �������������� ������� ������������ ����
	                                  // � data ������ �� IEnumUnknown �� ������� �������
   PN_EDIT_MULTI_VTAG_PROPS =   21; // ������ PN_EDIT_VIRTUAL_TAG_PROPS �� ��� �������� 21
     	                              // RCNOTIFY rcn;
	                                  // rcn.punkParam=IEnumUnknown �� ������� �������
	PN_QUERY_VTAG_INFO =          22; // ������ ���������� �� ������������ ������ 22
                                    //  RCNOTIFY rcn;
                                    //  rcn.punkParam=ITag ������ �� ��� �� �������� �������������
                                    //  ����������
                                    //  � rcn.bstrParam ������ ����� �������� ����������
                                    //  ������ ���������� �� ����������� COM
	PN_REMOVE_VTAGS =             23; // ����������� �� ������������ �� �������� 23
	                                  // ����������� ������� ������������� �������
	                                  //  RCNOTIFY rcn;
	                                  //  rcn.punkParam=IEnumUnknown �� ������� �������
	PN_RCINITIALIZED =            24; // ������������� ��������� ���������, ��� ������� ���������
	PN_ON_CHANGE_DATAPLACEMENT =  25; // ����������� � ����� �������� �������� � ����� ������
	                                  // ���������� ������ �� DATAPLACEMENT
	PN_ON_BEFORE_FRAME_REMOVING = 26; // ����������� ����� �������� ������� ������
	                                  // ���� ������� ���-�� ����������� ������ ���� ������� � �������
	PN_ON_AFTER_FRAME_REMOVING =  27; // ����� �������� ������ - ���� ���� �� ��� ������������
	PN_FILE_PROCESSING_COMPLETED= 28; // �������� � ������ ������ ���������
	PN_ON_DESTROY_UI_SRV =        29; // ����������� � �������� ������� ���������� ������������
	                                  // �� ������ ����������� ������ ��� ���, ������� ����
	                                  // ����������������� �����, ������ � ��. ���������� �������
	PN_ON_SWITCH_TO_UI_THREAD =   30; // ������������ ��������� � ������� ����, ����� ������ ���
	                                  // ��� ������������� ������� � ��� ����
	                                  // ���������� ���������� ��� �������� ������� � �� ������� �������
	PN_ON_CONFIG_MODE_COMPLETED = 31; // ����� ��������� �������� ��� �������, ���� ��������� ���������
                                    // �� ����� ��������� ����������� ������� � ����� ���������
                                    // ���� ����� ���������� ����������� ������
	PN_ON_SWITCH_CALIBR_MODE =    32; // ����������� � ������������ ������ ����������
	PN_ON_RC_PROGRAMMING =        33; // ��������� � ��� ��� Recorder ��������� � ������ "�����" �������
	                                  // ����� ������������������� ���� ��������� � ���� ����� ����������
	PN_ABORT_RC_PROGRAMMING =     34; // �������� ���������� � ������ ��������� ���� ��������
	PN_ON_UPDATE_SECURITY_STATE = 35; // ����� �������� ������ ������������
	                                  // ������ ������ �� ������� DWORD ����� ��������
	PN_ON_UPDATE_MF_TITLE =       36; // ���������� ���������� �������� ����
	                                  // � ������ BSTR ������ �� ������ � ����������, ����� ���������
	PN_ON_REC_MODE =              37; // ����������� � ������������ � ����� ������
	PN_ON_PLAY_MODE =             38; // ����������� � ������������ � ����� ���������������
	PN_ON_POPUP_SETUP_DIALOG =    39; // �������� ��������� �������� ���� ���������
	                                  // ��������� ������������ � ��������� ��������� (ACTIONCTRL) �����
    	                              // �������� �������� � �������� �������� ���� ���� ���������
	PN_ON_POPUP_SEL_FRAME_DIALOG =40; // �������� ��������� �������� ���� ������ ����� ������
	                                  // ��������� ������������ � ��������� ��������� (ACTIONCTRL) �����
    	                              // �������� �������� � �������� �������� ���� ���� ���������
	PN_ON_ACTION_SAVE_CFG =       41; // �������� ��������� ��������� ������������
	PN_ON_ACTION_SAVE_CFG_AS =    42; // �������� ��������� ��������� ������������
	PN_ON_ACTION_LOAD_CFG =       43; // �������� ��������� ��������� ������������
	PN_ON_CHANGE_FORMS =          44; // ����� ��������� ����������:
	                                  //  - ����� ��������
	                                  //  - ������������/�����������
	PN_ABORT_RCSTOP =             45; // �������� �������� ��������� ���� ��������
	PN_ON_ACTION_CLOSE_APP =      46; // �������� ��������� ��������� ������
	PN_ON_ZBALANCE_VTAG =         47; // ������� �� ������������ ���� ������������ ������
  PN_USER                 =  $7000; //�������� ����������� PN_USER+XXXX

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

type
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
      version:    word;                    //����� ������
      subversion: word;                    //����� ���������
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

implementation
end.









