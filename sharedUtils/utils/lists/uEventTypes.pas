unit uEventTypes;

interface

const
  // ���������� ��� ����� ����� �������
  E_CHANGENAME = $00000001;
  // ���������� ��� �������� �������. � �������� ��������� Sender ���������� ��������� ������
  E_OnDestroyObject = $00000002;
  // ���������� ��� ����������� ������� � ������ ������� addchild (� �������� ���������� newchild)
  E_OnAddChild = $00000004;
  // ���������� ��� ����������� ������� � ������ (� �������� ���������� ������)
  // ���������� ��� ����� ���� ��� ��� ������� (������� ��������) ����� ������������ � �����
  E_OnAddObj = $00000008;
  // ���������� ��� ���������� ������ ��������
  E_OnEngUpdateList=E_OnDestroyObject+E_OnAddObj;
  // ���������� ��� �������������� �������
  E_OnRenameObj = $00000010;
  // ���������� ��� �������������� �������
  E_OnLoadObjMng = $00000020;
  // ���������� ��� ���������� ������� � ������ (���� ���� �������� ��� ��������)
  // ������ ���� �������� m_EnableAddObjInstanceEvent!!!
  E_OnAddObjInstance = $00000040;
  // ���������� ��� ������������ ������ �� ����. ������ ���������� ���
  e_OnTagAlarm = $00001000;

implementation

end.
