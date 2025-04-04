unit uTagUtils;

interface
uses
  uDrawObj, uTag, uCommonTypes, uCommonMath;
// ���������� ������ � DrawObj; Data -
// �������������� ����� ������� ����� ������������ ��� ���������
procedure TagToDrawObj(drawObj:cDrawObj; Tag:cBaseTag; data:pointer);


implementation
uses
  upage,uTrend, uGistogram, uMarkers, uchart, uBuffTrend2d, uBasicTrend, uBuffTrend1d;

procedure TagToTrend(trend:cbasictrend; Tag:cBaseTag; data:pointer);
var
  i:integer;
  p:point2;
  page:cpage;
begin
  if tag is c2VectorTag then
  begin
    trend.clear;
    trend.Position:=p2(-c2VectorTag(tag).fValue[0].x,0);
    trend.addpoints(c2VectorTag(tag).fValue, c2VectorTag(tag).used);
    page:=cpage(trend.GetParentByClassName('cPage'));
    cchart(trend.chart).redraw;
    //page.NormaliseX;
  end;
  if tag is cVectorTag then
  begin
    cBuffTrend1d(trend).dx:=cVectorTag(tag).dx;
    cBuffTrend1d(trend).AddPoints(cVectorTag(tag).fValue);
    cchart(trend.chart).redraw;
  end;
end;

procedure TagToGist(gist:cGistogram; Tag:cBaseTag; data:pointer);
var
  i:integer;
  p:single;
begin
  gist.clear;
  for i := 0 to cArrayTag(tag).used - 1 do
  begin
    p:=cVectorTag(tag).Value[i];
    gist.SetValue(i*2,p);
  end;
end;

procedure TagToGistMarkers(m:cmarkerlist; Tag:cBaseTag; data:pointer);
var
  i:integer;
  p:single;
  gist:cgistogram;
begin
  gist:=cgistogram(m.GetParentByClassName('cGistogram'));
  for I := 0 to cArrayTag(tag).used - 1 do
  begin
    p:=i*gist.width*2;
    if tag is c2VectorTag then
    begin
      // ��������� ������ minVal � �������
      m.AddMarker(p2(p,c2VectorTag(tag).value[i].x));
      // ��������� ������ maxVal � �������
      m.AddMarker(p2(p,c2VectorTag(tag).value[i].y));
    end;
    if tag is cVectorTag then
    begin
      // ��������� ������ minVal � �������
      m.AddMarker(p2(p,cVectorTag(tag).value[i]));
    end
  end;
end;

procedure TagToDrawObj(drawObj:cDrawObj; Tag:cBaseTag; data:pointer);
var
  chart:cchart;
begin
  if drawobj<>nil then
  begin
    if not drawobj.visible then exit;
    chart:=cchart(drawobj.chart);
    if drawobj is cGistogram then
    begin
      drawobj.entercs;
      TagToGist(cGistogram(drawObj),tag,data);
      drawobj.exitcs;
    end;
    if drawobj is cMarkerList then
    begin
      drawobj.entercs;
      TagToGistMarkers(cMarkerList(drawObj),Tag,data);
      drawobj.exitcs;
    end;
    if drawobj is cbasictrend then
    begin
      // ����� deadlock
      //drawobj.entercs;
      TagToTrend(ctrend(drawobj),tag,data);
      //drawobj.exitcs;
    end;
  end;
end;


end.
