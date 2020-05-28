unit uQueue;

interface
uses
  ucommontypes;

type
  cP2dQueue = class
  protected
    data: array of point2d;
  public
    // �������� (��������) � ������ ���� ����� �������
    procedure push_front

    push_back
    �������� (��������) � ����� ���� ����� �������
    pop_front
    ������� �� ���� ������ �������
    pop_back
    ������� �� ���� ��������� �������
    front
    ������ �������� ������� �������� (�� ������ ���)
    back
    ������ �������� ���������� �������� (�� ������ ���)
    size
    ������ ���������� ��������� � ����
    clear
    �������� ��� (������� �� ���� ��� ��������)
  end;

implementation

end.
