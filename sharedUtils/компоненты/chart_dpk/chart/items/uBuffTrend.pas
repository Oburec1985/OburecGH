unit uBuffTrend;

interface
uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
     uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
     uEventList, types, NativeXML, uChartEvents, uBasicTrend;

type
  cBuffTrend1d = class(cBasicTrend)
  public
    // ������� �����
    weight:double;
    // ���� �������
    pointcolor:point3;
  protected
    //�������� ���������� ����� ������
    function GetCount:integer;override;
    procedure SetCount(i:integer);override;
    // �������� ������� �� �������
    function GetP2(i:integer):point2;virtual;abstract;
    // ���� ����� p ������� �� ������� boundrect �� ����������� boundrect
    procedure updateBound(p:point2);
  public
    property Count:integer read getCount write SetCount;
  end;


implementation

function cBuffTrend1d.GetCount:integer;
begin
  result:=0;
end;


procedure cBuffTrend1d.SetCount(i: integer);
begin
  inherited;

end;

procedure cBuffTrend1d.updateBound(p: point2);
begin

end;

end.
