unit uMultiSensor;

interface
uses
  classes, sysutils,Graphics,  controls, stdctrls,
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uProgressDlg,
  ubldeng, uBaseBldAlg, ustage, uBaseObj,  uturbina, PathUtils,
  usensorlist, uCommonTypes, utrend, uTag, uBldGlobalStrings;

type
  tFloatArray = array of point2;

  cMultiSensorOpts = class(cbaseopts)
  public
    constructor create;override;
  end;
  // �������� ��������������� ������ �������� �� ����� ������
  cMultiSensor = class(cBaseBldAlg)
  protected
    // ����� ������ ��� 1-� �������
    SensorsBuffer:array of tFloatArray;
    // ����� ������������ �� ������� ��������
    ValidSensors:integer;
    m_XYArTag:array of c2vectortag;
  protected
    procedure GetNewData(turncount:integer);override;
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function TurnSensorProc(s:csensor):integer;override;
    procedure AfterTurnProc;override;
    procedure CommonSensorProc(taho:csensor;sensors:cAlgSensorList);override;
    // ��������� ������. ���� ��������� ������ ���������� false
    function ProcessErrors(taho:csensor; sensors:cAlgSensorList):boolean;override;
    // ������� ����
    procedure createTags;override;
    function BeforeCommonSensorProc:boolean;override;
    // ������������ �� ������� ����� ���������� �� �������� �� ������
    // ������ ������ - ����� ������� , ������ ����� �������
    // �� ������ ������� ��������� �� ����������� �������� �� validsensors (�� x)
    procedure sortframe;
    function FindMin(blade:integer;beginInd:integer):integer;
  public
  end;

  procedure BuildMultiSensor(taho:csensor; sensors:cAlgSensorList; data:pointer);

implementation
uses
  uMultiSensorForm;


constructor cMultiSensorOpts.create;
begin
  inherited;
end;


function cMultiSensor.TurnSensorProc(s:csensor):integer;
var
  j:integer;
  // ��������� ����� ������� �� �������
  t0:stickdata;
  // ��� �� ������ ������� �� ��������� �������
  tick:stickdata;
  // ���������� ������� �� ���������� ��������� � �����
  i,
  dt,
  blade,
  bladeindex:integer;
  // ����� ������. ������ ���������� ������� �� �������� ��������� � ����� �����
  p2:point2;
  path:single;
begin
  // ������������ ����� ��������� �������������� � ������ ������� �����������
  result:=0;
  for I := 0 to bladecount - 1 do
  begin
    blade:=i;
    if m_XYArTag[blade].active then
    begin
      bladeindex:=GetBladeImpulsIndex(s, blade);
      path:=GetSensorBladePos(s, blade);
      // ��������� ����� ������� �� �������
      t0:=EvSensorTickInTurn(t1,t2,path);
      // �������� ����� �������� �� ������ ������� �� ��������� �������
      tick:=s.chan.ticks.gettick(sensorind+bladeindex);
      // ���������� ��������� ������� �� ���������� � �����
      dt:=evDecTicks(t0,tick);
      // ���������� ��������� ������� �� ���������� � ��������
      p2.y:=EvalTickDPos(t1,t2,dt);
      // ����� � �������� ������� �������� �� �������
      p2.x:=TickToSec(tick);
      SensorsBuffer[validsensors,blade]:=p2;
    end;
  end;
  Inc(validsensors);
end;

procedure cMultiSensor.AfterTurnProc;
var
  i, blade:integer;
  tag:c2vectortag;
begin
  sortframe;
  for blade := 0 to bladeCount - 1 do
  begin
    tag:=m_XYArTag[blade];
    for I := 0 to validsensors - 1 do
    begin
      tag.Add(sensorsbuffer[i,blade]);
    end;
  end;
  validsensors:=0;
end;

procedure cMultiSensor.CommonSensorProc(taho:csensor;sensors:cAlgSensorList);
begin
  inherited;
end;


function cMultiSensor.ProcessErrors(taho:csensor;sensors:cAlgsensorList):boolean;
var
  l:integer;
  sensor:csensor;
begin
  if inherited ProcessErrors(taho,sensors)=false then
  begin
    result:=false;
    exit;
  end;
  result:=ProcClusterError(taho,sensors);
end;

procedure BuildMultiSensor(taho:csensor; sensors:cAlgSensorList; data:pointer);
var
  alg: cMultiSensor;
  // ����� ��������� ����
  PairShapeForm: TMultiSensorForm;
  // ����� ���������
  opts:cMultiSensorOpts;
  str:string;
  I: Integer;
begin
  opts:=cMultiSensorOpts.Create;
  opts.eng:=taho.eng;
  opts.stage:=cstage(sensors.stage);
  opts.useBladesPos:=true;
  opts.callBadTicksProc:=true;
  for I := 0 to sensors.count - 1 do
  begin
    str:=str+sensors.GetSensor(i).name;
    if i<>sensors.count-1 then
    begin
      str:=str+'_';
    end;
  end;
  opts.testname:= v_ShortDscMultiSensor+'_'+str;
  PairShapeForm:=TMultiSensorForm.Create(nil);
  if PairShapeForm.ShowModal(taho,sensors,opts)=mrok then
  begin
    alg:=cMultiSensor.create;
    alg.getOpts(opts);
    alg.apply(taho,sensors,opts);
    alg.Destroy;
  end;
  PairShapeForm.Destroy;
  opts.Destroy;
end;

procedure cMultiSensor.createTags;
var
  tag:cBaseTag;
  i:integer;
begin
  tags.cleardata;
  if bladecount>0 then
  begin
    setlength(m_XYArTag,bladecount);
    for I := 0 to bladecount - 1 do
    begin
      tag:=c2VectorTag.create;
      tag.active:=true;
      tag.name:='XYArray_'+inttostr(i);
      tag.dsc:='������ ���������� �� �������� �_'+inttostr(i);
      tags.addobj(tag);
      m_XYArTag[i]:=c2VectorTag(tag);
    end;
    for i := 0 to tags.Count - 1 do
    begin
      tag:=cBaseTag(tags.getobj(i));
      // ��������� ������� ������ ��������� �����
      tag.blocked:=true;
    end;
  end;
end;

function cMultiSensor.BeforeCommonSensorProc:boolean;
var
  i, j:integer;
begin
  result:=inherited;
  setlength(SensorsBuffer,sensorsList.Count);
  for j := 0 to sensorsList.Count - 1 do
  begin
    setlength(SensorsBuffer[j],bladecount);
  end;
end;

function cMultiSensor.FindMin(blade:integer;beginInd:integer):integer;
var
  min:single;
  i, imin:integer;
begin
  min:=SensorsBuffer[beginind,blade].x;
  imin:=beginind;
  for i:=beginind+1 to validsensors-1 do
  begin
    if SensorsBuffer[i,blade].x<min then
    begin
      min:=SensorsBuffer[i,blade].x;
      imin:=i;
    end;
  end;
  result:=imin;
end;

procedure cMultiSensor.sortframe;
var
  i,j, blade:integer;
  v:point2;
begin
  for blade := 0 to bladeCount - 1 do
  begin
    for I := 0 to validsensors-1 do
    begin
      j:=FindMin(blade,i);
      if i<>j then
      begin
        v:=SensorsBuffer[i, blade];
        SensorsBuffer[i, blade]:=SensorsBuffer[j, blade];
        SensorsBuffer[j, blade]:=v;
      end;
    end;
  end;
end;

procedure cMultiSensor.GetNewData(turncount:integer);
var
  i:integer;
begin
  for I := 0 to bladeCount - 1 do
  begin
    m_XYArTag[i].length:=(EndInd-beginind)*sensorslist.count;
  end;
end;


end.
