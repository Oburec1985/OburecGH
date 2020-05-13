unit uShapeAlg;

interface
uses
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uchart,
  uGistogram, uTrend, ubldeng, uBaseBldAlg, ustage, uSensorList;

type

  cShapeAlg = class(cBaseBldAlg)
  protected
    // буфер для хранения растояний между лопатками
    offsets:array of single;
  protected
    procedure initOpts;override;
    function TurnSensorProc(s:csensor):integer;override;
    procedure CommonSensorProc(taho:csensor;sensors:cAlgsensorList);override;
  public
  end;

implementation
uses ubldtypes;

procedure cShapeAlg.CommonSensorProc(taho:csensor;sensors:cAlgsensorList);
var
  i:integer;
begin
  bladecount:=stage.Shape.bladecount;
  if bladecount<3 then
  begin
    errorStage_noBlades(stage, stage.eng.flags);
    exit;
  end;
  setlength(offsets,bladecount);
  // очищаем массив расстояний между лопатками
  for i:= 0 to bladecount - 2 do
  begin
    stage.Shape.offset[i]:=0;
  end;
  stage.shape.firstimpulse:=0;
  // фильтрация и обработка оборотов
  inherited;
  // усредняем полученный результат
  for I := 0 to bladecount - 1 do
  begin
    stage.shape.offset[i]:=stage.shape.offset[i]/(sstruct[0].validturns);
  end;
  stage.shape.firstimpulse:=stage.shape.firstimpulse/(sstruct[0].validturns);
end;

function cShapeAlg.TurnSensorProc(s:csensor):integer;
var
  j,
  blade:integer;
  tick:stickdata;
begin
  result:=0;
  for j:=sensorind to (sensorind+BladeCount - 1) do
  begin
    blade:=getBladeNumber(s,j-sensorind);
    tick:=s.chan.ticks.gettick(j);
    offsets[blade]:=EvalTickPos(t1,t2,tick);
    if j=sensorind then
      stage.shape.firstimpulse:=stage.shape.firstimpulse+offsets[blade];
  end;
  // накапливаем результат до последующего усреднения
  for j := 0 to BladeCount - 1 do
  begin
    if j<>s.skipblade then
    begin
      if j<>(bladecount-1) then
        stage.shape.offset[j]:=stage.Shape.offset[j]+abs(offsets[j+1]-offsets[j])
      else
        stage.shape.offset[j]:=stage.Shape.offset[j]+abs(offsets[j]-offsets[0]);
    end
    else
      stage.shape.offset[j]:=stage.Shape.offset[j]+(360-abs(offsets[j]-offsets[j+1]));
  end;
end;

procedure cShapeAlg.initOpts;
begin
  inherited;
end;


end.
