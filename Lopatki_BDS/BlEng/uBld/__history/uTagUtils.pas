unit uTagUtils;

interface
uses
  uDrawObj, uTag, uCommonTypes, uCommonMath;
// отрисовать объект в DrawObj; Data -
// дополнительные опции которые могут понадобиться при отрисовке
procedure TagToDrawObj(drawObj:cDrawObj; Tag:cBaseTag; data:pointer);


implementation
uses
  upage,uTrend, uGistogram, uMarkers, uchart;
   
procedure TagToTrend(trend:ctrend; Tag:cBaseTag; data:pointer);
var
  i:integer;
  p:point2;
  page:cpage;
begin
   trend.clear;
  if tag is c2VectorTag then
  begin
    trend.addpoints(c2VectorTag(tag).fValue);
    page:=cpage(trend.GetParentByClassName('cPage'));
    page.NormaliseX;
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
    gist.SetValue(i*gist.width*2,p);
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
      // добавляем маркер minVal к лопатке
      m.AddMarker(p2(p,c2VectorTag(tag).value[i].x));
      // добавляем маркер maxVal к лопатке
      m.AddMarker(p2(p,c2VectorTag(tag).value[i].y));
    end;
    if tag is cVectorTag then
    begin
      // добавляем маркер minVal к лопатке
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
    if drawobj is ctrend then
    begin
      drawobj.entercs;
      TagToTrend(ctrend(drawobj),tag,data);
      drawobj.exitcs;
    end;
  end;
end;


end.
