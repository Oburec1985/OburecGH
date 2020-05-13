{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ���������� ��� �������� ������� � ���������� ������ }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}

unit blaccess;
interface
   uses Windows;
{$ALIGN 8}
type
   {��������� ��� �������� ������ �������}
   tagUTSPAIR = record
      dblUTSTime: double;      {����� ���}
      dblDeviceTime: double;   {����� ����������� ��������}
   end;
   UTSPAIR = tagUTSPAIR;

   {��������� ��� �������� ����������� �������� �� ������� �������}
   tagI2PAIR = record
      dblTime: double;          {����� �������}
      nValue: word;             {���������� �������� ���� WORD - �����}
   end;
   I2PAIR = tagI2PAIR;

   {��������� ��� �������� ����������� �������� �� ������� �������}
   tagR8PAIR = record
      dblTime: double;          {����� �������}
      dblValue: double;         {���������� �������� ���� DOUBLE - ��������������}
   end;
   R8PAIR = tagR8PAIR;

   {������� ������ ������� ������ ����}
   {������ ��������� ������ ���� ���������� ����� ���`��}
   IBlockAccess = interface
   ['{c2535841-49b1-11d7-9244-00e029288a7f}']

      //�������� ����� ������������ ������
      function GetReadyBlocksCount: DWORD; stdcall;
      //�������� ����� �������
      function GetBlocksCount: ULONG; stdcall;
      //�������� ������ �����
      function GetBlocksSize: DWORD; stdcall;
      //�������� ������ �������
      function GetVectorSize: DWORD;  stdcall;
      //�������� ������������ ������� �������
      function GetVectorCapacity: DWORD; stdcall;

      //������������ ������
      function LockVector: DWORD; stdcall;
      //������������� ������
      function UnlockVector: DWORD; stdcall;
      //�������� ����� �����
      function GetLockCount: DWORD; stdcall;


      //�������� ����� � ���� floa�'��
      {������ �������� Block - ������ ������ ���� SINGLE}
      function GetVectorR4(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;

      //�������� ����� � ���� int'��
      {������ �������� Block - ������ ������ ���� WORD}
      function GetVectorI2(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;

      //�������� ����� � ���� unsigned int'��
      {������ �������� Block - ������ ������ ���� WORD}
      function GetVectorU2(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;

      //�������� ����� � ���� double'��
      {������ �������� Block - ������ ������ ���� DOUBLE}
      function GetVectorR8(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;


      //������������ �� ������ ������ XY
      function isContainTimes: boolean; stdcall;
      //�������� �� �������� ���
      function isUTSVector: boolean; stdcall;
      //�������� ����� � ���� ��� ������ ���
      {������ �������� Block - ������ �������� UTSPAIR}
      function GetVectorUTS(var Block; const Index: longint; const Size: longint;
                            const Tare: boolean): HRESULT; stdcall;

      //�������� ����� � ���� ��� (�������, ��������)
      {������ �������� Block - ������ �������� R8PAIR}
      function GetVectorPairR8(var Block; const Index: longint; const Size: longint;
                               const Tare: boolean): HRESULT; stdcall;
      {������ �������� Block - ������ �������� I2PAIR}
      function GetVectorPairI2(var Block; const Index: longint; const Size: longint;
                               const Tare: boolean): HRESULT; stdcall;
      //�������� ������ ������
      {������ �������� Block - ������ ����� ���� DOUBLE}
      function GetVectorTimes(var Block; const Index: longint; const Size: longint;
                              const Tare: boolean): HRESULT; stdcall;

      //�������� ����� ������� ����� � �������� ���
      function GetBlockUTSTime(const Index: longint): double; stdcall;

      //�������� ����� ������� ����� � �������� ����� ����������
      function GetBlockDeviceTime(const Index: longint): double; stdcall;
   end;
implementation
end.
