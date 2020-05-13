unit uBuffTrend;

interface
uses uPoint, uvectorlist, uCommonTypes, classes, opengl,
     uOglExpFunc, uCommonMath, u2DMath, uBaseObj, uDrawObj,
     uEventList, types, NativeXML, uChartEvents, uBasicTrend;

type
  cBuffTrend1d = class(cBasicTrend)
  public
    // толщина линии
    weight:double;
    // цвет вершины
    pointcolor:point3;
  protected
    //получить установить число вершин
    function GetCount:integer;override;
    procedure SetCount(i:integer);override;
    // получить вершину по индексу
    function GetP2(i:integer):point2;virtual;abstract;
    // если точка p выходит за границу boundrect то обновляется boundrect
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
