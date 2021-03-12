{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ���������� ��� ���������� ���������� �������������  }
{ �����������                                                         }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}
unit device;

interface

uses Windows, modules;

const
   //�������� ���������
   DEVPROP_NAME =                0; // �������� ����������
   DEVPROP_DESC =                1; // �������� ����������
   DEVPROP_IFACENAME =           2; // �������� ����������
   DEVPROP_IFACEDESC =           3; // �������� ����������
   DEVPROP_SERNUM =              4; // �������� ����� ����������
   DEVPROP_IFACESERNUM =         5; // �������� ����� ����������
   DEVPROP_MAX_MODULE_COUNT =    6; // ����������� ��������� ����� ������� � ����������
   DEVPROP_MODULE_BY_SLOT =      7; // �������� ������ �� ��������� ������ �� ������ �����
   DEVPROP_MODULE_BY_INDEX =     8; // �������� ������ �� ��������� ������ �� �������
   DEVPROP_INITIALIZED =         9; // ������ ��������� - "�������������������"
   DEVPROP_TYPE =               10; // ��� ����������
   DEVPROP_SYNC_START_ENABLED = 11; // ���������� ����� ��������
   DEVPROP_ERROR_CODE =         12; // ��� ������ �������� �������������
   DEVPROP_ALIAS =              13; // �������� ��� �������
   DEVPROP_IFACE =              14; // ���������
   DEVPROP_SLOT_NAME =          15; // �������� �����
   DEVPROP_CONTEXT =            16;
   DEVPROP_INT =                17;
   DEVPROP_INT_DATA =           18;
   DEVPROP_STATE =              19;
   DEVPROP_DEBUG_STATE =        20;
   DEVPROP_STATE_WORD =         21; // ����� ������������������� ��������� ����������
                                    // ������������� ������� �� ����������� ����������
                                    // ��� CCMC012COMWDInterface, CCMR032v4EthernetInterface
                                    // �������� ���������� �����������

type
   IDevice = interface
   ['{B167658E-567C-4766-AA4D-00F74BF02BEB}']
      {�������� �������� �������� �� ��������������}
      function GetDeviceProperty( const a_dwPropertyID: DWORD;
                                  var Value: OleVariant;
                                  const lSubPropertyIndex: longint;
                                  const dwReserved: DWORD): HRESULT; stdcall;
      {���������� �������� �������� �� ��������������}
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
