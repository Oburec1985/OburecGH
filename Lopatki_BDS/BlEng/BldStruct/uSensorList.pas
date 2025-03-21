unit uSensorList;

interface
uses
   uSetList, uVectorList, sysutils, usensor, ubldobj, uBldObjList, uErrorProc;

type

  cAlgSensorList = class(cbldObjList)
  protected
    fsort:integer;
  public
    procedure setSortType(i:integer);override;
    procedure Removesensor(obj:cbldobj);
    function GetSensor(i:integer):csensor;overload;
    function GetSensor(name:string):csensor;overload;
    function stage:cbldobj;
  end;

  const
    c_namesort = 0;
    c_PosSort = 1;

implementation

function NameSort(p1,p2:pointer):integer;
begin
  result:=AnsiCompareText(csensor(p1).name,csensor(p2).name);
end;

function PosSort(p1,p2:pointer):integer;
begin
  if csensor(p1).pos>csensor(p2).pos then
    result:=1
  else
  begin
    if csensor(p1).pos<csensor(p2).pos then
      result:=-1
    else
      result:=0;
  end;
end;

function cAlgSensorList.GetSensor(i:integer):csensor;
begin
  if i<Count then
  begin
    result:=csensor(items[i]);
  end
  else
    result:=nil;
end;

function cAlgSensorList.GetSensor(name:string):csensor;
var
  i:integer;
  s:csensor;
begin
  result:=csensor(getobj(name));
end;

procedure cAlgSensorList.setSortType(i:integer);
begin
  case i of
    c_PosSort:setComparator(PosSort);
    else
      inherited;
  end;
  fsort:=i;
end;

function cAlgSensorList.stage:cbldobj;
var
  I: Integer;
  s:csensor;
  st:cbldobj;
begin
  result:=nil;
  st:=nil;
  for I := 0 to Count - 1 do
  begin
    s:=getsensor(i);
    if s.stage<>nil then
    begin
      if st=nil then
        st:=s.stage
      else
      begin
        if st<>s.stage then
        begin
          errorSensorList_DifStage(st.eng,st.eng.flags);
        end;
      end;
    end;
  end;
  result:=st;  
end;

procedure cAlgSensorList.Removesensor(obj:cbldobj);
var
  i:integer;
begin
  i:=GetIndex(obj);
  if i<>-1 then
  begin
    deletechild(i);
  end;
end;

end.
