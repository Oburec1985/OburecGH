unit uChartEvents;

interface
uses classes;

type
  TDoubleDataEvent = procedure (data:tobject; subdata:tobject) of object;

const
  // ���������� ��� �������� �������. � �������� ��������� Sender ���������� ��������� ������
  E_OnDestroyObject = $00000040;
  // ���������� ��� �������������
  E_OnZoom = $00000080;
  // ���������� ��� �������� ����
  E_OnMouseMove = $00000100;
  // ���������� ��� ����������� ��������
  e_onDraw = $00000200;
  // ���������� ��� ����������� ��������
  e_onAddPoint = $00000400;
  // ���������� ��� ����������� ��������
  e_onSelectPoint = $00000800;
  // ���������� ��� ����������� ��������
  e_onResize = $00001000;
  // ���������� ��� �������� ���������� � ������ ��������, � ��� ����� � nil
  e_onLincParent = $00002000;
  // ���������� ��� ���������� ������. � �������� sensder ��� �����
  e_onUpdateBound = $00004000;
  // ���������� ��� ��������� �������� ���
  e_OnChangeAxisScale = $00008000;
  // ���������� ��� ��������� ����� ������� ������� ���������� � �������� sender
  e_OnChangeName = $00010000;
  // ���������� ��� ��������� ����� ������� ������� ���������� � �������� sender
  e_OnChangeColor = $00020000;
  e_OnChartResize = $00040000;
  // �������� ������� ����
  e_OnMoveCursor = $00080000;
  // �������� ������ ������
  e_OnMoveCursor2 = $00100000;
  // �������� ������ Y
  e_OnMoveCursorY = $00200000;

implementation

end.
