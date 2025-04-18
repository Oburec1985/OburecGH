unit uTrendAlg;

interface
uses
  uBldMath, uCommonMath, uCommonTypes, uErrorProc, uBldObj, uTickdata, usensor, uchart,
  uGistogram, uTrend, ubldeng, uBaseBldAlg, ustage, uBaseObj, uAxis, usensorlist,
  sysutils, uTag, uEventList, ubldEngEventTypes, NativeXML, uBldGlobalStrings;


// ������� ��������� ������� ������������ ��  �������������� ����������� ����� ������
// (stage.shape.blades[i]) ���� useBladesPos=true � stage.shape.offsets[i] -
// ���� useBladesPos=false
type
  cTrendAlgOpts = class(cBaseOpts)
    // ������ �������� � ��������. ���� <0, �� ������
    // ����������� � ������� �� ����������
    T:single;
  end;

  cTrendAlg = class(cBaseBldAlg)
  protected
    trend:ctrend;
    useBladesPos:boolean;
    // ������ �������� � ��������. ���� <0, �� ������
    // ����������� � ������� �� ����������
    period:single;
    m_XYArTag:array of c2vectortag;
    m_MTag,m_DTag:array of cscalartag;
  protected
    function getBladePos(s:csensor;bladeindex:integer):single;
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function TurnSensorProc(s:csensor):integer;override;
    function CollapsTime(t:single):single;
    procedure GetNewData(turncount:integer);override;
    procedure CommonSensorProc(taho:csensor;sensors:calgsensorlist);override;
    function ProcessErrors(taho:csensor;sensors:calgsensorlist):boolean;override;
    // ������� ����
    procedure createTags;override;
    procedure setTagsBuffers(data:cbaseopts);override;
    procedure OnChangeStageInFrame(sender:tobject);
  public
    procedure InitTags(blCount:integer);
    function AlgID:integer;override;
    function CreateOpts:cbaseopts;override;
    procedure getOpts(opts:cBaseOpts);override;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
  end;

  function generateTrend(t:csensor;sensors:calgsensorlist;tr:tobject):integer;

implementation
uses
  uXYTrendPos, commonoptsframe, uUTSSensor, uBldTimeProc;

function cTrendAlg.AlgID:integer;
begin
  result:=c_BladeTrend;
end;

procedure cTrendAlg.OnChangeStageInFrame(sender:tobject);
begin
  if TBaseAlgOptsFrame(sender).StageCB.Items.count<>0 then
  begin
    stage:=cstage(TBaseAlgOptsFrame(sender).StageCB.Items.Objects[0]);
    if stage<>nil then
    begin
      initTags(stage.BladeCount);
    end;
    //TBaseAlgOptsFrame(sender).AlgTagList1.getAlg(tags);
  end;
end;

function cTrendAlg.getBladePos(s:csensor;bladeindex:integer):single;
begin
  result:=GetSensorBladePos(s,bladeindex);
end;

function cTrendAlg.CollapsTime(t:single):single;
begin
  if period<=0 then
  begin
    result:=t;
  end
  else
  begin
    result:=frac(t/period);
  end;
end;

function cTrendAlg.ProcessErrors(taho:csensor;sensors:calgsensorlist):boolean;
var
  s:csensor;
begin
  s:=sensors.GetSensor(0);
  result:=inherited ProcessErrors(taho,sensors);
  if result then
  begin
    result:=ProcClusterError(taho,sensors);
  end;
end;

procedure cTrendAlg.getOpts(opts:cBaseOpts);
var
  s:csensor;
begin
  inherited;
  s:=sensorslist.GetSensor(0);
  period:=cTrendAlgOpts(opts).t;
  trend:=cTrendAlgOpts(opts).trend;
  if trend<>nil then
  begin
    //trend.name:=trend.name+'_Bl'+inttostr(blade);
    trend.Clear;
  end;
  useBladesPos:=cTrendAlgOpts(opts).useBladesPos;
end;

procedure cTrendAlg.CommonSensorProc(taho:csensor;sensors:calgsensorlist);
var
  i:integer;
begin
  inherited;
  for I := 0 to bladecount - 1 do
  begin
    if m_XYArTag[i].active then
    begin
      if m_MTag[i].active then
        m_MTag[i].Value:=m_XYArTag[i].M;
      if m_DTag[i].active then
        m_DTag[i].Value:=m_XYArTag[i].D;
    end;
  end;
end;

function cTrendAlg.TurnSensorProc(s:csensor):integer;
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
      m_XYArTag[blade].add(p2);
    end;
  end;
end;



procedure cTrendAlg.InitTags(blCount:integer);
begin
  bladecount:=blCount;
  createTags;
end;

function cTrendAlg.CreateOpts:cbaseopts;
begin
  result:=cTrendAlgOpts.create;
  setopts(result);
end;

procedure cTrendAlg.GetNewData(turncount:integer);
var
  i:integer;
begin
  inherited;
  for I := 0 to bladecount - 1 do
  begin
    if m_XYArTag[i].active then
    begin
      if turncount>m_XYArTag[i].length then
        m_XYArTag[i].length:=turncount;
    end;
  end;
end;

procedure cTrendAlg.setTagsBuffers(data:cbaseopts);
begin
  inherited;
end;

procedure cTrendAlg.createTags;
var
  tag:cBaseTag;
  i:integer;
begin
  if tags.Count<>0 then exit;
  if bladecount>0 then
  begin
    setlength(m_XYArTag,bladecount);
    setlength(m_DTag,bladecount);
    setlength(m_MTag,bladecount);
    for I := 0 to bladecount - 1 do
    begin
      tag:=c2VectorTag.create;
      tag.active:=true;
      tag.name:='XYArray_'+inttostr(i);
      tag.dsc:='������ ���������� �� ������� '+inttostr(i);
      tags.addobj(tag);
      m_XYArTag[i]:=c2VectorTag(tag);

      tag:=cScalarTag.create;
      tag.active:=true;
      tag.name:='D_'+inttostr(i);
      tag.dsc:='������ ��������� �� ������ �������� ' +inttostr(i);
      tags.addobj(tag);
      m_DTag[i]:=cScalarTag(tag);

      tag:=cScalarTag.create;
      tag.active:=true;
      tag.name:='M_'+inttostr(i);
      tag.dsc:='������ ���. �������� �� ������ �������� ' +inttostr(i);
      tags.addobj(tag);
      m_MTag[i]:=cScalarTag(tag);

    end;
    for i := 0 to tags.Count - 1 do
    begin
      tag:=cBaseTag(tags.getobj(i));
      // ��������� ������� ������ ��������� �����, �.�. ����
      // ��������� � ��������� ����������
      tag.blocked:=true;
      tag.active:=false;
    end;
  end;
end;

procedure cTrendAlg.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
begin
  inherited;
  InitTags(stage.BladeCount);
end;


function generateTrend(t:csensor;sensors:calgsensorlist;tr:tobject):integer;
var
  opts:ctrendalgopts;
  s:csensor;
begin
  opts:=ctrendalgopts.create;
  if tr is ctrend then
    opts.trend:=ctrend(tr)
  else
    opts.chart:=cchart(tr);
  // ����� ���������
  s:=sensors.GetSensor(0);
  opts.testname:=v_ShortDscTrend+'_'+s.name;
  opts.T:=0;
  opts.eng:=t.eng;
  opts.stage:=cstage(s.eng.GetObjDlg(s,c_Stage));
  XYTrendForm.showmodal(t,sensors,opts);
  opts.Destroy;
end;



end.
