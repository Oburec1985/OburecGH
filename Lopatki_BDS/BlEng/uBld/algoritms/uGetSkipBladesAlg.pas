unit uGetSkipBladesAlg;

interface
uses
  classes, sysutils,Graphics,  controls, stdctrls,
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uProgressDlg,
  ubldeng, uBaseBldAlg, ustage, uBaseObj, RepODS, uturbina, PathUtils,
  usensorlist, uMyMath, uEvalSkipBladesForm, uchart;

type
  cGetSkipBladesOpts = class(cbaseopts)
    // ��������� ������� �������
    firstskip:integer;
    // ����� �������� ������� ��� ������ ����������� ������� �����
    lastskip:integer;
  public
    constructor create;override;
  end;

  cGetSkipBladesAlg = class(cBaseBldAlg)
  protected
    // ��������� ������� �������
    firstskip:integer;
    // ����� �������� ������� ��� ������ ����������� ������� �����
    lastskip:integer;
    // ����� ��� �������� ��������� ����� ���������
    offsets:array of single;
    ResOffsets:array of single;
  protected
    function ProcessErrors(taho:csensor;sensors:cAlgSensorList):boolean;override;
    procedure getOpts(opts:cBaseOpts);override;
    function TurnSensorProc(s:csensor):integer;override;
    procedure CommonSensorProc(taho:csensor;sensors:cAlgsensorList);override;
    procedure ReEvalOffsetsWithSkiplastskip(SkipInd:integer);
  public
  end;

  function GetSkipBlades(taho:csensor;list:cAlgSensorList; chart:cchart):boolean;

implementation
uses ubldtypes;

constructor cGetSkipBladesOpts.create;
begin
  INHERITED;
  useStageInfo:=false;
  evalSkipBladesInTurn:=false;
  lastskip:=2;
  firstskip:=0;
end;

procedure cGetSkipBladesAlg.CommonSensorProc(taho:csensor;sensors:cAlgsensorList);
var
  i,
  // ������ �������� ������� ��� ������� ����������� ���������� ����������
  maxind:integer;
  // �������� ����������
  kmax,k:single;
  s:csensor;
begin
  if sensors.Count>1 then
    exit;
  bladecount:=stage.Shape.bladecount;
  if bladecount<3 then
  begin
    errorStage_noBlades(stage, stage.eng.flags);
    exit;
  end;
  setlength(offsets,bladecount);
  setlength(Resoffsets,bladecount);
  // ���������� � ��������� ��������
  inherited;
  // ��������� ���������� ���������
  for I := 0 to bladecount - 1 do
  begin
    Resoffsets[i]:=Resoffsets[i]/(sstruct[0].validturns);
  end;
  kmax:=0;
  for i := firstskip to lastskip do
  begin
    if i<>0 then
    begin
      ReEvalOffsetsWithSkiplastskip(i);
      // ���������� i �� 1 �������� ����� ������
      k:=getCorr(stage.Shape.offset, offsets);
    end
    else
      k:=getCorr(stage.Shape.offset, resoffsets);
    if k>kmax then
    begin
      maxind:=i;
      kmax:=k;
    end;
  end;
  s:=sensors.GetSensor(0);
  s.skipBlade:=maxind;
end;

function cGetSkipBladesAlg.TurnSensorProc(s:csensor):integer;
var
  j,
  blade:integer;
  tick:stickdata;
  offset:single;
begin
  result:=0;
  // ������� �����, ��� �������� ������� 0
  for j:=sensorind to (sensorind+BladeCount - 1) do
  begin
    blade:=uBldMath.getBladeNumber(0,j-sensorind,bladecount);
    tick:=s.chan.ticks.gettick(j);
    offset:=EvalTickPos(t1,t2,tick);
    offsets[blade]:=offset;
  end;
  // ����������� ��������� �� ������������ ����������
  for j := 0 to BladeCount - 1 do
  begin
    if j<>0 then
    begin
      if j<>(bladecount-1) then
        Resoffsets[j]:=Resoffsets[j]+abs(offsets[j+1]-offsets[j])
      else
        Resoffsets[j]:=Resoffsets[j]+abs(offsets[j]-offsets[0]);
    end
    else
      Resoffsets[j]:=Resoffsets[j]+(360-abs(offsets[j]-offsets[j+1]));
  end;
end;

// ���������� �������� ������� �� 1 ������ ������� ������ �����
procedure cGetSkipBladesAlg.ReEvalOffsetsWithSkiplastskip(SkipInd:integer);
var
  newInd,i:integer;
begin
  for I := 0 to bladecount - 1 do
  begin
    if i+skipind<bladecount then
      newind:=i+skipind
    else
      newind:=skipind+i- bladecount;
    offsets[newind]:=Resoffsets[i];
  end;
end;

procedure cGetSkipBladesAlg.getOpts(opts:cBaseOpts);
begin
  inherited;
  firstskip:=cGetSkipBladesOpts(opts).firstskip;
  lastskip:=cGetSkipBladesOpts(opts).lastskip;
  if bladecount=-1 then
  begin
    if stage<>nil then
      bladecount:=stage.BladeCount;
  end;
  if lastskip>bladecount then
  begin
    lastskip:=bladecount;
  end;
end;

function GetSkipBlades(taho:csensor;list:cAlgSensorList; chart:cchart):boolean;
var
  o:cGetSkipBladesOpts;
  a:cGetSkipBladesAlg;
  form:tEvalSkipBladesForm;
  buflist:cAlgSensorList;
  I: Integer;
begin
  buflist:=nil;
  o:=cGetSkipBladesOpts.create;
  o.chart:=chart;
  form:=tEvalSkipBladesForm.Create(nil);
  if list.Count>1 then
  begin
    buflist:=cAlgSensorList.create;
    buflist.destroydata:=false;
    buflist.add(list.getsensor(0));
  end
  else
  begin
    exit;
  end;
  o.stage:=cstage(list.stage);
  o.useStageInfo:=false;
  o.firstskip:=0;
  o.lastskip:=o.stage.BladeCount-1;
  o.eng:=cstage(list.stage).eng;
  result:=true;
  if form.ShowModal(taho, list, o)=mrok then
  begin
    a:=cGetSkipBladesAlg.create;
    //a.stage:=o.stage;
    a.getopts(o);
    for I := 0 to list.Count - 1 do
    begin
      if i<>0 then
        buflist.Items[0]:=list.GetSensor(i);
      a.sensorsList:=buflist;
      a.apply(taho, buflist, o);
    end;
    a.destroy;
  end
  else
    result:=false;
  if buflist<>nil then
    buflist.destroy;
  form.destroy;
  o.Destroy
end;


function cGetSkipBladesAlg.ProcessErrors(taho:csensor;sensors:cAlgSensorList):boolean;
var
  s:csensor;
begin
  // ���� ��������� ������ ���������� false
  result:=inherited ProcessErrors(taho,sensors);
  if not result then
    exit;
  s:=sensors.GetSensor(0);
  if s.stage=nil then
  begin
    errorObj_noStage(s, s.eng.flags);
    result:=false;
    exit;
  end;
  if not GetOffsetsInit(stage.Shape.offset) then
  begin
    errorStage_noBladesPos(stage, s.eng.flags);
    result:=false;
    exit;
  end;
end;


end.
