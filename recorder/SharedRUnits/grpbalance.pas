unit grpbalance;

interface

uses Windows, tags;

const
  IID_IGroupBalance : TGUID = '{68596AD1-5ECD-4f62-92C2-22BE142DA1F6}';

type
  IGroupBalance = interface
   ['{68596AD1-5ECD-4f62-92C2-22BE142DA1F6}']
      // ���������������� ������� ������������
      function Init : HRESULT; stdcall;

      // �������� ����� � ������
      function Add(a_pTag : ITag) : HRESULT; stdcall;

      // ��������� ��������� ������������
      function Run : HRESULT; stdcall;

      // ���������� ������ ������� ���������� ��������
      function Finish : HRESULT; stdcall;
   end;

implementation

end.
