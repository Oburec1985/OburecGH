unit uGraphObj;

interface
uses
  windows, uBaseObj, uCommonTypes, ueventlist, uChartEvents, types,
  comctrls, classes, uDrawObjMng, NativeXML, uBaseObjMng, dglopengl,
  umatrix, udrawobj,
  MathFunction;

type
  // объ
  cGraphObj = class(cMoveObj)
  public

  protected
    //получить установить число вершин
    function GetCount:integer;virtual;abstract;
    procedure SetCount(i:integer);virtual;abstract;
    function FindHiBound(x:single;fromInd,toind:integer):integer;
    function FindLoBound(x:single;fromInd,toind:integer):integer;
  public
    procedure DoOnClick(p:point2);override;
    // получить вершину по индексу
    function GetP2(i:integer):point2;virtual;abstract;
    function GetY(x:single):single;virtual;ABSTRACT;
  public
    property Count:integer read getCount write SetCount;
    constructor create;override;
  end;

implementation
uses
  uaxis, upage;


procedure cGraphObj.DoOnClick(p: point2);
var
  ax:caxis;
  page:cpage;
begin
  inherited;
  page:=cPage(getparentbyclassname('cPage'));
  if page<>nil then
  begin
    ax:=caxis(getparentbyclassname('cAxis'));
    if ax<>nil then
    begin
      page.activeAxis:=ax;
    end;
  end;
end;

function cGraphObj.FindHiBound(x:single;fromInd,toind:integer):integer;
var b:boolean;
    len,range,curind,
    left,right:integer;
    frac_:boolean;
    function _div(a,b:integer;var frac_:boolean):integer;
    var res:integer;
    begin
       if a=1 then
       begin
        result:=0;
        exit;
       end;
       res:= trunc(a/b);
       frac_:=((a mod b)<>0);
       result:=res;
    end;
begin
  if toind>=count then
    len:=count
  else
    len:=toind;
  // Определяем границы поиска в массиве
  left:=fromInd;
  right:=len-1;
  // Проверка граничных результатов
  if getp2(len-1).x<x then
  begin
    result:=len-1;
    exit;
  end;
  if getp2(0).x>x then
  begin
    result:=0;
    exit;
  end;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if getp2(curind).x>x then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if getp2(curind).x>x then
    result:=curind
  else
  begin
    result:=curind+1;
  end;
end;

function cGraphObj.FindLoBound(x:single;fromInd,toind:integer):integer;
var b:boolean;
    len,range,curind,
    left,right:integer;
    frac_:boolean;
    function _div(a,b:integer;var frac_:boolean):integer;
    var res:integer;
    begin
       if a=1 then
       begin
        result:=0;
        exit;
       end;
       res:= trunc(a/b);
       frac_:=((a mod b)<>0);
       result:=res;
    end;
begin
  if toind>=count then
    len:=count
  else
    len:=toind;
  // Определяем границы поиска в массиве
  left:=fromind;
  right:=len-1;
  // Проверка граничных результатов
  if getp2(len-1).x<x then
  begin
    result:=len-1;
    exit;
  end;
  if getp2(0).x>x then
  begin
    result:=0;
    exit;
  end;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if getp2(curind).x>x then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if getp2(curind).x>x then
    result:=curind-1
  else
    result:=curind;
end;

constructor cGraphObj.create;
begin
  inherited;
  selectable:=true;
end;

end.
