unit uEvalFirstBladeOffset;

interface
uses
  classes, sysutils,Graphics,  controls, stdctrls, uchart, uaxis,
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uProgressDlg,
  ubldeng, uBaseBldAlg, ustage, uBaseObj, uturbina, PathUtils,
  usensorlist, uCommonTypes, uGistogram, uBldTypes, upair, uBasealgForm;

type

  cEvalFirstBladeOffset = class(cBaseBldAlg)
  protected
    res:array of single;
  protected
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function TurnSensorProc(s:csensor):integer;override;
    procedure CommonSensorProc(taho:csensor;sensors:calgsensorlist);override;
    function ProcessErrors(taho:csensor;sensors:calgsensorlist):boolean;override;
  public
    constructor create;override;
  end;

  function EvalFirstBladeOffset(t:csensor;sensors:calgsensorlist; chart:cchart):integer;

implementation

constructor cEvalFirstBladeOffset.create;
begin
  inherited;
end;

function cEvalFirstBladeOffset.ProcessErrors(taho:csensor;sensors:calgsensorlist):boolean;
begin
  // � ������� ��������� �������� ������ �� ����� �����
  result:=inherited ProcessErrors(taho,sensors);
  // �������� ������� ��������� ����
  // if result then
  // begin
  //  result:=ProcClusterError(taho,sensors,data);
  // end;
end;

procedure cEvalFirstBladeOffset.CommonSensorProc(taho:csensor;sensors:calgsensorlist);
var
  s:csensor;
  i:integer;
begin
  setlength(res,sensors.Count);
  inherited;
  for I := 0 to sensors.Count - 1 do
  begin
    if sstruct[i].validturns<>0 then
    begin
      // ��������� �� ����� ���������� ��������
      res[i]:=res[i]/sstruct[i].validturns;
      s:=sensors.GetSensor(i);
      s.firstBladeOffset:=res[i];
    end
    else
    begin
      s:=sensors.GetSensor(i);
      s.firstBladeOffset:=-1;
    end;
  end;
end;

function cEvalFirstBladeOffset.TurnSensorProc(s:csensor):integer;
begin
  result:=inherited TurnSensorProc(s);
  EvalTurnCluster(s,sensorind);
  res[CurSensorInd]:=res[CurSensorInd]+turnCluster.p;
end;

function EvalFirstBladeOffset(t:csensor;sensors:calgsensorlist; chart:cchart):integer;
var
  opts:cbaseopts;
  alg:cEvalFirstBladeOffset;
  s:csensor;
  f:TBaseAlgForm;
begin
  opts:=cbaseopts.create;
  s:=sensors.GetSensor(0);
  opts.eng:=t.eng;
  opts.stage:=cstage(s.eng.GetObjDlg(s,c_Stage));
  opts.useStageInfo:=false;
  opts.evalSkipBladesInTurn:=false;
  opts.chart:=chart;
  opts.eng:=t.eng;
  //opts.showFrm:=false;
  f:=TBaseAlgForm.Create(nil);
  f.Caption:='������ ���������� �� �������� �� ������ �������';
  if f.ShowModal(t,sensors,opts)=mrok then
  begin
    alg:=cEvalFirstBladeOffset.create;
    alg.getopts(opts);
    alg.apply(t,sensors,opts);
    alg.Destroy;
  end;
  f.Destroy;
  opts.Destroy;
end;

end.

