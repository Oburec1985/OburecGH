unit uListMath;

interface
uses classes;

type
  // 1 если p1>p2, 0 если равны и -1 если p1<p2 
  fcomparator = function (p1,p2:pointer):integer;


  function FindInListLowBound(a:TList;obj:pointer;sortfunction:fcomparator):integer;
  function FindInListHiBound(a:TList;obj:pointer;sortfunction:fcomparator):integer;


implementation

 // находит в массиве элемент слева от элемента с заданным x
function FindInListLowBound(a:TList;obj:pointer;sortfunction:fcomparator):integer;
var b:boolean;
    res,len,range,curind,
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
  len:=a.Count;
  // Проверка граничных результатов
  if len=0 then
  begin
    result:=0;
    exit;
  end;
  curind:=sortfunction(a.Items[len-1],obj);
  // если obj больше или равен a.Items[len-1]
  if (curind=-1) or (curind=0) then
  begin
    result:=len-1;
    exit;
  end;
  curind:=sortfunction(a.Items[0],obj);
  if (curind=1) or (curind=0) then
  begin
    result:=0;
    exit;
  end;
  // Определяем границы поиска в массиве
  left:=0;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    res:=sortfunction(a.Items[curind],obj);
    if res=1 then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      // если элементы равны
      if res=0 then
      begin
        if curind>0 then
        begin
          // ищем элемент слева
          if sortfunction(a.Items[curind-1],obj)=-1 then
          begin
            result:=curind-1;
            exit;
          end;
        end;
      end;
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if sortfunction(a.Items[curind],obj)=1 then
    result:=curind-1
  else
    result:=curind;
end;

// находит в массиве элемент справа от элемента с заданным x
function FindInListHiBound(a:TList;obj:pointer;sortfunction:fcomparator):integer;
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
  len:=a.Count;
  if len=0 then
  begin
    result:=0;
    exit;
  end;  
  // Проверка граничных результатов
  if sortfunction(a.Items[len-1],obj)<=0 then
  begin
    result:=len-1;
    exit;
  end;
  if sortfunction(a.Items[0],obj)=1 then
  begin
    result:=0;
    exit;
  end;
  // Определяем границы поиска в массиве
  left:=0;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if sortfunction(a.Items[curind],obj)=1 then
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
  if sortfunction(a.Items[curind],obj)=1 then
    result:=curind
  else
    result:=curind+1;
end;

end.
