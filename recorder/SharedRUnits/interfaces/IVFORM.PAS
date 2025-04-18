unit IVFORM;

interface
uses
  Windows,
  Wintypes,
  WinProcs,
  rcPlugin;

//type
// {95001263-E83C-11d6-9243-00E029288A7F}
//extern GUID IID_IVForm;


//����������� ���������� � ������� ������������
// Visualization server notifications
const
	// ����� ����������� � ���������
	VSN_ENTERRCCONFIG = PN_ENTERRCCONFIG; // �������� ������� � ����� ��������� 1
	VSN_LEAVERCCONFIG = PN_LEAVERCCONFIG;             // �������� ����� �� ������ ��������� 2
	VSN_CHANGECURTAG  = PN_CHANGECURTAG;              // �������� ������� ���, data=ITag* 3

	VSN_RCSAVECONFIG  = PN_RCSAVECONFIG;              // �������� �������� ������������
	VSN_RCLOADCONFIG  = PN_RCLOADCONFIG;              // �������� �������� ������������

	VSN_RCSTART       = PN_RCSTART;                   // �������� ������� � ����� ���������/������� ������
	VSN_RCPLAY        = PN_RCPLAY;                    // �������� ������� � ����� ��������������� ������
	VSN_RCSTOP        = PN_RCSTOP;                    // �������� ����������
	VSN_BEFORE_RCSTART= PN_BEFORE_RCSTART;            // �������� ��������� � ����� ���������/������� ������
	VSN_BEFORE_RCSTOP = PN_BEFORE_RCSTOP ;            // �������� ���������������
	VSN_ABORT_RCSTART = PN_ABORT_RCSTART;             // �������� ������ ���� ��������
	VSN_UPDATE_DATA		= PN_UPDATEDATA;		            // ���������� ������ � rc

	// �������������� �����������
	VSN_SPECIFIED=$4000;       //
	//VSN_RESIZE;                 // �������� ������ ���� ���������
	//VSN_CHANGEVIEWTIME;         // ����� ��������� �����������
	//VSN_CHANGETIMESHIFT;        // ����� �������� ��������� �����������
	//VSN_CHANGERCSTATE;          // ���������� ��������� Recorder � dwData ����� ���������
	//VSN_SET_PARENT;             // ���������� ������ ������� (dwData)
	//VSN_QUERY_ALARMS_STATE;     // ��������� ��������� �������
	//VSN_QUERY_ALARMS_COLOR;     // ��������� ���� ������� �������
	//VSN_GET_TRANSPARENT;        // ��������� ���� ������������
	//VSN_ON_CHANGE_TAGS_FILTER;  // ��������� ������ �������
	//VSN_ON_DBLCLK_TAGS_LIST;    // ���� ���� �� ������ ����� � ������ ���������
	//VSN_ON_ADD_SELECTED_TAGS;		// ������� �� ���������� ���������� �����, ��������� �� ��� �� ������ �������
	//VSN_QUERY_DROP_ACCEPT;			// ����� ��������� DnD ������
	//VSN_USER=0x7000;             // �������� ����������� VFN_USER+XXXX

/// ������������� ��������� �� ��������� ������� ����������
/// ����������� �������� ����<br>
/// wParam ������ �� IVForm ����������<br>
/// lParam ����� ������� ����������<br>
///  ��� ������������ lParam ����� ������������ ������� MAKELPARAM(x,y)<br>
/// ��� ��������� ��������� �������� ��������� ������������ �������
/// RegisterWindowMessage
//#define ID_WM_ON_CHANGE_CHILD_SIZE "Mera.Recorder.IVForm.WM_ON_CHANGE_CHILD_SIZE"
type
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

implementation

end.
