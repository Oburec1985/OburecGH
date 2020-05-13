unit uBldService;

interface
uses uBtnListView,
     uBldFile,
     umyTypes_,
     utickdata,
     comctrls,
     SysUtils,
     classes,
     uMyMath,
     upair;
  // ���������� ������� � LV
  procedure showSensorsInLV(lv:tbtnlistview;bldfile:cbldfilegen);
  function getSensorFromLV(lv:tbtnlistview;index:integer):cSensor;
  // ���������� ������ �� array of sbldstages
  function getStagesFromListView(lv:tbtnlistview):pointer;
  // �������� ������ ��������
  function GetStagesFromLV(lv:tbtnlistview):cStageList;

  const ColSensorName = '���';
  const ColType = '���';
  const ColChanNumber = '�';
  const ColImpulsNum = '����� ���������';
  const ColStage = '�������';
  const ColSensorPos = '���������';
  const ColBladeNum = '� �������';

implementation

function getSensorFromLV(lv:tbtnlistview;index:integer):cSensor;
var s:cSensor;
    li:tlistitem;
    str:string;
begin
  s:=csensor.create;
  li:=lv.Items[index];
  lv.GetSubItemByColumnName(ColStage,li,str);
  s.stagename:=str;
  lv.GetSubItemByColumnName(ColSensorName,li,str);
  s.mChanName:=str;
  lv.GetSubItemByColumnName(ColType,li,str);
  if str<>'' then
  begin
    if str[1]='�' then
     s.mChanType:=c_root;
    if str[1]='�' then
     s.mChanType:=c_edge;
    if str[1]='�' then
     s.mChanType:=c_rot;
  end;
  lv.GetSubItemByColumnName(ColChanNumber,li,str);
  s.mChanNumber:=strtoint(str);
  lv.GetSubItemByColumnName(ColSensorPos,li,str);
  if str<>'' then
  begin
    s.pos:=strtofloat(str);
  end;
  result:=s;
end;

procedure showSensorsInLV(lv:tbtnlistview;bldfile:cbldfilegen);
var impulscount,i:integer;
    li:tlistitem;
    str:string;
begin
  for I := 0 to bldfile.ChunCount - 1 do
  begin
    lv.items.add;
    li:=lv.items[i];
    impulscount:=length(bldfile.trends[i].ticks.ticks);
    if bldfile.sensors.sensors[i].stagename<>'' then
    begin
      lv.SetSubItemByColumnName
         (ColStage,bldfile.sensors.sensors[i].stagename,li);
    end
    else
    // ���� ������� ����� ����, �� �������� ������� �� ������������, �� �������
    // ��� ������� � ����� �������
    begin
      if bldfile.stages.Count=1 then
      begin
        lv.SetSubItemByColumnName
           (ColStage,bldfile.stages.stages[0].name,li);
      end;
    end;
    lv.SetSubItemByColumnName
       (ColChanNumber,inttostr(bldfile.sensors.sensors[i].mChanNumber),li);
    lv.SetSubItemByColumnName
       (ColImpulsNum,inttostr(impulsCount),li);
    lv.SetSubItemByColumnName
       (ColSensorName,bldfile.sensors.sensors[i].mChanName,li);
    lv.SetSubItemByColumnName
      (ColSensorPos,floattostr(bldfile.sensors.sensors[i].pos),li);
    // ������� ��� �������
    case bldfile.sensors.sensors[i].mChanType of
      c_rot: str:='����';
      c_root:str:='��������';
      c_edge:str:='������������';
    end;
    lv.SetSubItemByColumnName
       (ColType,str,li);
  end;
end;

function getStagesFromListView(lv:tbtnlistview):pointer;
var li:tlistitem;
    i:integer;
    str:string;
    stage:cstage;
    stages:tstringlist;
begin
  stages:=tstringlist.Create;
  stages.Sorted:=true;
  stages.Duplicates:=dupIgnore;
  for I := 0 to lv.Items.Count - 1 do
  begin
    li:=lv.items[i];
    // ������ ��� ������� � ������� ������
    lv.GetSubItemByColumnName(colstage,li,str);
    // ���� ���� �� ��� ������� ������� � ����� ������
    if not stages.Find(str,i) then
    begin
      // ���� ������� � ����� ������ �����, �� ������� ��
      stage:=cstage.Create;
      // ��������� ������� � ������ ��������
      stages.AddObject(str,stage);
    end;

  end;
  stages.Destroy;
end;

function GetStagesFromLV(lv:tbtnlistview):cStageList;
var i,index:integer;
    stage:cstage;
    sensor:csensor;
begin
  result:=cStageList.create;
  for I := 0 to lv.Items.Count-1 do
  begin
    sensor:=getSensorFromLV(lv,i);
    if not result.find(sensor.stagename,index) then
    begin
      stage:=cstage.create;
      stage.name:=sensor.stagename;
      result.AddObject(stage.name,stage);
    end;
  end;
end;

end.
