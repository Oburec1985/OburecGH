unit uRestoreVibrationAlg;

interface
uses
  uBldMath, uCommonMath, uCommonTypes, uErrorProc, uBldObj, uTickdata, usensor, uchart,
  uGistogram, uTrend, ubldeng, uBaseBldAlg, ustage, uBaseObj, uAxis,
  uRestoreAlgForm, controls, usensorlist, uTag;

// ������� ��������� ������� ������������ ��  �������������� ����������� ����� ������
// (stage.shape.blades[i]) ���� useBladesPos=true � stage.shape.offsets[i] -
// ���� useBladesPos=false
type

  cRestoreAlg = class(cBaseBldAlg)
  protected
    trend:ctrend;
    useBladesPos:boolean;
    m_ArrayTag:c2VectorTag;
    m_DTag,m_MTag:cScalarTag;
  protected
    procedure getBladesPos;
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function TurnSensorProc(s:csensor):integer;override;
    procedure CommonSensorProc(taho:csensor;sensors:calgsensorlist);override;
    function ProcessErrors(taho:csensor;sensors:calgsensorlist):boolean;override;
    // ������� ����
    procedure createTags;override;
    procedure setTagsBuffers(data:cbaseopts);override;
    procedure GetNewData(turncount:integer);override;    
  public
    procedure getOpts(opts:cBaseOpts);override;
    function AlgID:integer;override;
  end;

  function RestoreSignal(t:csensor;sensors:calgsensorlist;tr:tobject):integer;

implementation

function cRestoreAlg.AlgID:integer;
begin
  result:=c_RestoreSignal;
end;

function cRestoreAlg.TurnSensorProc(s:csensor):integer;
var
  i,j:integer;
begin
  // ������������ ����� ��������� �������������� � ������ ������� �����������
  result:=0;
  for I := sensorind to (sensorind+BladeCount - 1)  do
  begin
    EvalTurnCluster(s,i);
    m_ArrayTag.Add(turnCluster.p2);
  end;
end;

procedure cRestoreAlg.getBladesPos;
var
  i:integer;
begin
  if (stage.Shape.blades[bladecount-1]=0) and (useBladesPos) then
  begin
    stage.Shape.blades[0]:=0;
    for I := 1 to BladeCount - 1 do
    begin
      stage.Shape.blades[i]:=stage.Shape.blades[i-1]+stage.Shape.offset[i-1];
    end;
  end;
end;

procedure cRestoreAlg.getOpts(opts:cBaseOpts);
begin
  inherited;
end;

procedure cRestoreAlg.CommonSensorProc(taho:csensor;sensors:calgsensorlist);
begin
  // �������� ��������� �������� ��������� �������
  getBladesPos;
  if m_ArrayTag.active then
  begin
    if m_MTag.active then
      m_MTag.Value:=m_ArrayTag.M;
    if m_DTag.active then
      m_DTag.Value:=m_ArrayTag.D;
  end;
  inherited;
end;

function cRestoreAlg.ProcessErrors(taho:csensor;sensors:calgsensorlist):boolean;
var
  s:csensor;
begin
  result:=inherited ProcessErrors(taho,sensors);
  if result then
  begin
   result:=ProcClusterError(taho,sensors);
  end;
end;

procedure cRestoreAlg.GetNewData(turncount:integer);
begin
  inherited;
  m_ArrayTag.length:=turncount*BladeCount;
end;

procedure cRestoreAlg.setTagsBuffers(data:cbaseopts);
begin
  inherited;
  m_ArrayTag.length:=(EndInd-beginInd);
end;

procedure cRestoreAlg.createTags;
var
  tag:cBaseTag;
  i:integer;
begin
  if tags.Count<>0 then exit;
  tag:=c2VectorTag.create;
  tag.active:=true;
  tag.name:='XYArray';
  tag.dsc:='������ ���������� �� ��������';
  tags.addobj(tag);
  m_ArrayTag:=c2vectortag(tag);

  tag:=cScalarTag.create;
  tag.active:=true;
  tag.name:='D';
  tag.dsc:='������ ��������� �� ������ ��������';
  tags.addobj(tag);
  m_DTag:=cscalartag(tag);

  tag:=cScalarTag.create;
  tag.active:=true;
  tag.name:='M';
  tag.dsc:='������ ���. �������� �� ������ ��������';
  tags.addobj(tag);
  m_MTag:=cscalartag(tag);

  for i := 0 to tags.Count - 1 do
  begin
    tag:=cBaseTag(tags.getobj(i));
    // ��������� ������� ������ ��������� �����, �.�. ����
    // ��������� � ��������� ����������
    tag.blocked:=true;
  end;
end;

function RestoreSignal(t:csensor;sensors:calgsensorlist;tr:tobject):integer;
var
  opts:cBaseOpts;
  stage:cstage;
  form:TrestoreAlgForm;
  alg:cRestoreAlg;
  s:csensor;
  tag:cbasetag;
begin
  opts:=cBaseOpts.create;
  if tr is ctrend then
  begin
    opts.trend:=ctrend(tr);
    opts.chart:=cchart(ctrend(tr).chart);
  end
  else
    opts.chart:=cchart(tr);
  opts.useBladesPos:=true;
  s:=sensors.GetSensor(0);
  stage:=cstage(s.eng.GetObjDlg(s,c_Stage));
  opts.stage:=stage;
  opts.eng:=t.eng;
  form:=TrestoreAlgForm.Create(nil);
  if form.ShowModal(t,sensors,opts)=mrok then
  begin
    alg:=cRestoreAlg.create;
    alg.getOpts(opts);
    tag:=cbasetag(alg.tags.getobj('XYArray'));
    tag.active:=true;
    tag.DrawObj:=opts.trend;
    alg.apply(t,sensors,opts);
    alg.Destroy;
  end;
  form.Destroy;
  opts.Destroy;
end;

end.
