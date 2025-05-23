// ����� ������� ��������� �� ����������� �������� ������ � ���������� delphi
unit uBldCompProc;

interface
uses classes, ubtnListView, uBldObj, StdCtrls, Controls, ComCtrls,
     usensor, sysutils, uBaseObj, uBldEng,uBaseObjTypes, upair, ustage, uChan,
     uCommonMath, uturbina, uBaseObjService, mathfunction, uBldGlobalStrings;


  procedure AddPairToLV(lv:tbtnlistview;pair:cpair);
  // ���������� �������� ���� ������� � LV
  procedure showChildPairsInLV(lv:tbtnlistview;obj:cbaseobj);
  // ����������� ������ �� lv (������ ��� ������� index) � sensor
  procedure getSensorFromLV(lv:tbtnlistview;index:integer;sensor:cSensor);
  // ���������� ������ �������� � lv � ����������� ���������� �� ����
  procedure ShowEngInLV_typeSort(lv:tbtnlistview;eng:cbldEng);
  // �������� ������
  procedure ShowEngChansInLV(lv:tbtnlistview;eng:cbldEng);
  // ���������� ������� ������ � ������
  procedure ShowEngInTreeView(tv:ttreeview;eng:cbldEng);
  // �������� ������ �� ListView
  function GetEngObj(lv:tbtnlistview;eng:cbldEng;li:tlistitem):cbldobj;
  // ���������� ������ ������� � ListView
  procedure showBladesInLV(lv:tbtnlistview;stage:cstage);
  procedure showShapeInLV(lv:tbtnlistview; stage:cstage);
  // ���������� ���� ������� � ����� �����
  procedure ShowTahoInCB(e:cBldEng; CB:TComboBox);overload;
  procedure ShowTahoInCB(e:cBldEng; stage:cstage; CB:TComboBox);overload;
  // ���������� ������� � ����� �����
  procedure ShowStageInCB(e:cBldEng; CB:TComboBox);overload;
  procedure ShowStageInCB(e:cBldEng; turbine:cturbine; CB:TComboBox);overload;
  // ���������� ������
  procedure ShowChanInCB(e:cBldEng; CB:TComboBox);
  // ���������� ������� � LV
  procedure AddSensorToLV(lv:tbtnlistview;sensor:cSensor);
  procedure ShowEngSensorsInLV(lv:tbtnlistview; eng:cbldeng);
  // �������� �������� �������
  procedure ShowSensorsInLV(lv:tbtnlistview;obj:cBldObj);overload;
  procedure ShowSensorsInLV(lv:tbtnlistview;obj:cbaseObjList);overload;
  procedure InitDigitsLV(lv:tbtnListView);
  // ����������� listView ��� ����������� ���� ������� �������( ��������� ������� �������)
  procedure initBladesLV(lv:tlistview);
  procedure initSensorsLV(lv:tbtnlistview);
  procedure initPairsLV(lv:tbtnlistview);


implementation

procedure InitDigitsLV(lv:tbtnListView);
var
  col:tlistcolumn;
begin
  lv.Columns.Clear;
  col:=lv.Columns.Add;
  col.Caption:=v_ColNum;
  col.width:=100;
  // ��������� ������� � ������������ �������
  col:=lv.Columns.Add;
  col.Caption:=v_ColName;
  col.width:=100;
  // ��������� ������� ���
  col:=lv.Columns.Add;
  col.Caption:=v_ColType;
  col.width:=100;
  // ��������� ������� �������� �������
  col:=lv.Columns.Add;
  col.Caption:=v_ColAdress;
  col.width:=100;
  // ��������� ������� ��������
  col:=lv.Columns.Add;
  col.Caption:=v_ColValue;
  col.width:=100;
end;

procedure initBladesLV(lv:tlistview);
var
  col:tlistcolumn;
begin
  lv.Columns.Clear;
  col:=lv.Columns.Add;
  col.Caption:=v_ColNum;
  // ��������� ������� � ������������ �������
  col:=lv.Columns.Add;
  col.Caption:=v_ColSensorPos;
end;

procedure showBladesInLV(lv:tbtnlistview; stage:cstage);
var
  i:integer;
  li:tlistitem;
begin
  lv.Clear;
  for I := 0 to stage.BladeCount - 1 do
  begin
    li:=lv.Items.Add;
    lv.SetSubItemByColumnName(v_ColNum,inttostr(i),li);
    lv.SetSubItemByColumnName(v_ColSensorPos,floattostr(stage.shape.Blades[i]),li);
  end;
end;

procedure showShapeInLV(lv:tbtnlistview; stage:cstage);
var
  i:integer;
  li:tlistitem;
begin
  if length(stage.Shape.offset)<>0 then
  begin
    lv.Clear;
    for I := 0 to length(stage.Shape.offset) - 1 do
    begin
      li:=lv.Items.Add;
      lv.SetSubItemByColumnName(v_ColNum,inttostr(i),li);
      lv.SetSubItemByColumnName(v_ColSensorPos,formatstr(stage.Shape.offset[i],3),li);
    end;
  end;
end;




procedure AddPairToLV(lv:tbtnlistview;pair:cpair);
var
  li:tlistitem;
  sensor:csensor;
  I: Integer;
begin
  li:=lv.items.add;
  lv.SetSubItemByColumnName
     (v_Stage,pair.stagename,li);
  lv.SetSubItemByColumnName(v_ColNum,inttostr(li.index),li);
  lv.SetSubItemByColumnName(v_ColName,pair.Name,li);
  for I := 0 to pair.SensorsCount - 1 do
  begin
    sensor:=pair.GetSensor(i);
    case i of
      0: lv.SetSubItemByColumnName(v_ColEdgeSensor, sensor.name, li);
      1: lv.SetSubItemByColumnName(v_ColRootSensor, sensor.name, li);
    end;
  end;
end;

function ShowPairLV(obj:cBaseObj; data:pointer):boolean;
var i:integer;
begin
  result:=true;
  if obj is cpair then
    AddPairToLV(tbtnlistview(data),cpair(obj));
  if obj is csensor then
  begin
    for i:= 0 to csensor(obj).pairsCount - 1 do
    begin
      AddPairToLV(tbtnlistview(data),cpair(csensor(obj).getpair(i)));
    end;
  end;
end;

procedure showChildPairsInLV(lv:tbtnlistview;obj:cbaseobj);
begin
  lv.Clear;
  obj.EnumGroupMembers(ShowPairLV,lv);
end;

procedure getSensorFromLV(lv:tbtnlistview;index:integer;sensor:csensor);
var
  li:tlistitem;
  str:string;
begin
  li:=lv.Items[index];
  lv.GetSubItemByColumnName(v_Stage,li,str);
  sensor.stagename:=str;
  // ��� �������
  lv.GetSubItemByColumnName(v_ColName,li,str);
  sensor.name:=str;
  // ��� �������
  lv.GetSubItemByColumnName(v_ColType,li,str);
  sensor.sensortype:=sensorstringToInt(str);
  // ����� ������ �������
  lv.GetSubItemByColumnName(v_ColNum,li,str);
  sensor.ChanNumber:=strtoint(str);
  // ������� �������
  lv.GetSubItemByColumnName(v_ColSensorPos,li,str);
  if str<>'' then
  begin
    sensor.pos:=strtofloat(str);
  end;
end;

function ShowInLV(obj:cBaseObj; data:pointer):boolean;
begin
  result:=true;
  if obj is csensor then
    AddSensorToLV(tbtnlistview(data),csensor(obj));
end;

procedure ShowSensorsInLV(lv:tbtnlistview;obj:cBldObj);
begin
  lv.Clear;
  obj.EnumGroupMembers(ShowInLV, lv);
end;

procedure ShowSensorsInLV(lv:tbtnlistview;obj:cbaseObjList);
var
  I: Integer;
  sensor:cbldobj;
begin
  lv.Clear;
  for I := 0 to obj.Count - 1 do
  begin
    sensor:=cbldobj(obj.getobj(i));
    if sensor is csensor then
      AddSensorToLV(lv,csensor(sensor));
  end;
end;

procedure ShowEngChansInLV(lv:tbtnlistview;eng:cbldEng);
var
  obj:cbldobj;
  i:integer;
begin
  lv.clear;
  lv.SmallImages:=eng.images_16;
  for I := 0 to eng.chancount - 1 do
  begin
    obj:=cbldobj(eng.getchan(i));
    ShowBaseObjInLV(lv,obj);
  end;
end;

procedure ShowEngInLV_typeobj(lv:tbtnlistview;eng:cBldEng; objtype:integer);
var
  obj:cbldobj;
  i:integer;
begin
  for I := 0 to eng.count - 1 do
  begin
    obj:=cbldobj(eng.getobj(i));
    if objtype=obj.objtype then
    begin
      ShowBaseObjInLV(lv,obj);
    end;
  end;
end;

procedure ShowEngInLV_typeSort(lv:tbtnlistview;eng:cbldEng);
begin
  lv.Clear;
  lv.SmallImages:=eng.images_16;
  ShowEngInLV_typeobj(lv,eng,c_turbine);
  ShowEngInLV_typeobj(lv,eng,c_stage);
  ShowEngInLV_typeobj(lv,eng,c_pair);
  ShowEngInLV_typeobj(lv,eng,c_sensor);
end;

function GetEngObj(lv:tbtnlistview;eng:cbldEng;li:tlistitem):cbldobj;
var str:string;
begin
  lv.GetSubItemByColumnName(v_ColName,li,str);
  result:=cbldobj(eng.getobj(str));
end;

procedure ShowEngInTreeView(tv:ttreeview;eng:cbldEng);
var
  i:integer;
  obj:cbldobj;
  root:boolean;
  sensorsNode:ttreenode;
begin
  obj:=nil;
  tv.Items.Clear;
  tv.Images:=eng.images_16;
  for i := 0 to eng.count - 1 do
  begin
    obj:=cbldobj(eng.getobj(i));
    root:=obj.root;
    if root then
      ShowInTreeViwe(obj,tv);
  end;
  // ���������� ������ �������
  if eng.ChanCount<>0 then
  begin
    sensorsNode:=tv.Items.AddChildObject (nil,v_channels,nil);
    sensorsNode.ImageIndex:=c_Hardware_img;
    sensorsNode.SelectedIndex:=c_Hardware_img;
    for I := 0 to eng.chancount - 1 do
    begin
      obj:=cbldobj(eng.getchan(i));
      ShowBaseObjectInTreeView(obj,tv,sensorsNode);
    end;
  end;
  if eng.HardWare.count<>0 then
  begin
    sensorsNode:=tv.Items.AddChildObject (nil,v_plats,nil);
    sensorsNode.ImageIndex:=c_Hardware_img;
    sensorsNode.SelectedIndex:=c_Hardware_img;
    for I := 0 to eng.HardWare.count - 1 do
    begin
      obj:=cbldobj(eng.HardWare.getobj(i));
      ShowBaseObjectInTreeView(obj,tv,sensorsNode);
    end;
  end;
end;

procedure ShowTahoInCB(e:cBldEng; CB:TComboBox);
var
  i:integer;
  s:cbldobj;
begin
  CB.Clear;
  if e<>nil then
  begin
    for I := 0 to e.count - 1 do
    begin
      s:=cbldobj(e.getobj(i));
      if s is csensor then
      begin
        if csensor(s).sensortype=c_rot then
          cb.AddItem(s.name,s);
      end;
      cb.ItemIndex:=0;
    end;
  end;
end;

procedure ShowTahoInCB(e:cBldEng; stage:cstage; CB:TComboBox);
var
  i:integer;
  s:csensor;
begin
  CB.Clear;
  for I := 0 to stage.SensorsCount - 1 do
  begin
    s:=stage.GetSensor(i);
    if s.sensortype=c_rot then
      cb.AddItem(s.name,s);
  end;
  cb.ItemIndex:=0;
end;

procedure ShowChanInCB(e:cBldEng; CB:TComboBox);
var
  i:integer;
  c:cchan;
begin
  CB.Clear;
  if e<>nil then
  begin
    for I := 0 to e.channels.childCount - 1 do
    begin
      c:=cchan(e.channels.getchild(i));
      CB.AddItem(c.name,c);
      cb.ItemIndex:=0;
    end;
  end;
end;

procedure ShowStageInCB(e:cBldEng; CB:TComboBox);
var
  i:integer;
  s:cbldobj;
begin
  CB.Clear;
  if e<>nil then
  begin
    for I := 0 to e.count - 1 do
    begin
      s:=cbldobj(e.getobj(i));
      if s is cstage then
      begin
        CB.AddItem(s.name,s);
      end;
      cb.ItemIndex:=0;
    end;
  end;
end;


procedure ShowStageInCB(e:cBldEng; turbine:cturbine; CB:TComboBox);
var
  i:integer;
  s:cstage;
begin
  CB.Clear;
  for I := 0 to turbine.StageCount - 1 do
  begin
    s:=turbine.GetStage(i);
    cb.AddItem(s.name,s);
  end;
  cb.ItemIndex:=0;
end;

procedure initPairsLV(lv:tbtnlistview);
var
  col:tlistcolumn;
begin
  lv.Columns.Clear;
  col:=lv.Columns.Add;
  col.Caption:=v_ColNum;
  // ������� ���
  col:=lv.Columns.Add;
  col.Caption:=v_ColName;
  col.Width:=70;
  // ������� ���
  col:=lv.Columns.Add;
  col.Caption:=v_Stage;
  col.Width:=70;
  // ������� ���������
  col:=lv.Columns.Add;
  col.Caption:=v_ColEdgeSensor;
  col.Width:=70;
  // ������� ������� �������
  col:=lv.Columns.Add;
  col.Caption:=v_ColRootSensor;
  col.Width:=70;
end;

procedure initSensorsLV(lv:tbtnlistview);
var
  col:tlistcolumn;
begin
  lv.Columns.Clear;
  col:=lv.Columns.Add;
  col.Caption:=v_ColNum;
  // ������� ���
  col:=lv.Columns.Add;
  col.Caption:=v_ColName;
  col.Width:=70;
  // ������� ���
  col:=lv.Columns.Add;
  col.Caption:=v_ColType;
  col.Width:=70;
  // ������� ���������
  col:=lv.Columns.Add;
  col.Caption:=v_ColSensorPos;
  col.Width:=70;
  // ������� ������� �������
  col:=lv.Columns.Add;
  col.Caption:=v_ColSkipBlades;
  col.Width:=70;
  // ������� ��������� �� ������ �������
  col:=lv.Columns.Add;
  col.Caption:=v_ColFirstOffset;
  col.Width:=70;
  // ������� ����� ���������
  col:=lv.Columns.Add;
  col.Caption:=v_ColImpulsNum;
  col.Width:=70;
  // ������� ������� ���������
  col:=lv.Columns.Add;
  col.Caption:=v_Stage;
  col.Width:=70;
end;

procedure AddSensorToLV(lv:tbtnlistview;sensor:cSensor);
var li:tlistitem;
begin
  li:=lv.items.add;
  li.data:=sensor;
  lv.SetSubItemByColumnName(v_Stage,sensor.stagename,li);
  // ���� ������� ����� ����, �� �������� ������� �� ������������, �� �������
  // ��� ������� � ����� �������
  lv.SetSubItemByColumnName(v_ColNum,inttostr(sensor.ChanNumber),li);
  lv.SetSubItemByColumnName(v_ColImpulsNum,inttostr(sensor.ticksCount),li);
  lv.SetSubItemByColumnName(v_ColName,sensor.Name,li);
  lv.SetSubItemByColumnName(v_ColSensorPos,floattostr(sensor.pos),li);
  // ������� ��� �������
  lv.SetSubItemByColumnName(v_ColType,sensor.sensorstring,li);
  lv.SetSubItemByColumnName(v_ColSkipBlades,inttostr(sensor.skipBlade),li);
  lv.SetSubItemByColumnName(v_ColFirstOffset,floattostr(sensor.firstBladeOffset),li);
end;

procedure ShowEngSensorsInLV(lv:tbtnlistview; eng:cbldeng);
var
  I: Integer;
  obj:cbldobj;
begin
  lv.Clear;
  for I := 0 to eng.Count - 1 do
  begin
    obj:=cbldobj(eng.getobj(i));
    if obj is csensor then
    begin
      AddSensorToLV(lv,csensor(obj));
    end;
  end;
end;

end.
