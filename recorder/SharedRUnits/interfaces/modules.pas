{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ���������� ��� ���������� ���������� �������������  }
{ �����������                                                         }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}
unit modules;
interface
uses Windows;
const
   IID_IModule : TGUID = '{EBD857C1-DF75-11d6-9243-00E029288A7F}';

   //�������� ������
   MDPROP_SLOT           =  0; // ����
   MDPROP_TYPE           =  1; // ���
   MDPROP_SERIALNUMBER   =  2; // �������� �����
   MDPROP_VERSIONMAJOR   =  3; // ������� ����� ������
   MDPROP_VERSIONMINOR   =  4; // ������� ����� ������
   MDPROP_NAME           =  5; // ��������
   MDPROP_INFO           =  6; // �������������� ����������
   MDPROP_INITIALIZED    =  7; // ��������� ������ "������������������"
   MDPROP_MAX_CHAN_COUNT =  8; // ���������� ��������� ����� ������� ������
   MDPROP_HOST_DEVICE    =  9; // ���� ������ [out] VT_UNKNOWN
   MDPROP_LINK_DEVICE    = 10;

type
   IModule = interface
   ['{EBD857C1-DF75-11d6-9243-00E029288A7F}']
      {�������� ��� ������������� ���� ������}
      function GetType: WORD; stdcall;
      {�������� �������� �������� �� ��������������}
      function _GetProperty(const dwPropertyID: DWORD;
                            var Value: OleVariant): HRESULT; stdcall;
      {���������� �������� �������� �� ��������������}
      function _SetProperty(const dwPropertyID: DWORD;
                            {const} Value: OleVariant): HRESULT; stdcall;
      function _Reset: ULONG; stdcall;
	    function iCallCommand(const a_nCommand: Integer; const a_nSizeIn: Integer;
                            var pBufIn: PChar; const a_nSizeOut: Integer; var pBufOut: PChar): HRESULT; stdcall;
      //virtual HRESULT STDMETHODCALLTYPE iCallCommand(int a_nCommand, int a_nSizeIn, byte* pBufIn, int a_nSizeOut, byte* pBufOut)= 0;
   end;

implementation

end.
