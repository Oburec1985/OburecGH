unit uBldTypes;

interface
uses
  uTickData, usensor, uErrorProc, ubldobj, uSensorList;

type

  // ����� ��������� ����� ������. ������ ��� ��������� ����� ��������� � ��������
  cShape = class
  protected
    // ������ �� �������� ��������� �����
    sensor:csensor;
    // ����
    taho:csensor;
  public
    // ������� � ��� ��� ����� ���������
    init:boolean;
    // ������ ��������� �������
    blades:array of single;
    // ������ ��������� ����� ���������. ������ �������: �������1 - �������0,
    // ���������: 360-�������(n-1)+�������0,
    // ������ ��������
    offset:array of single;
    firstimpulse:single;
  public
    procedure Eval(taho:csensor; sensor:csensor; stage:cbldobj;showForm:boolean;
                   t1,t2:integer);
    constructor create;
  protected
    procedure setBladeNumber(count:integer);
    function getBladeNumber:integer;
  public
    procedure PrepareBladePos(offset:array of single);
    procedure PrepareOffsetsFromBladePos(BladePos:array of single);
    property bladeCount:integer read getBladeNumber write setBladeNumber;
  end;

implementation
uses uBldMath, ushapealg, ubaseBldAlg, ustage, uStageShapeForm, controls;

constructor cShape.create;
begin
  init:=false;
end;

procedure cShape.PrepareOffsetsFromBladePos(BladePos:array of single);
var
  I, bladecount: Integer;
  p:single;
begin
  bladecount:=length(BladePos);
  setlength(offset, bladecount);
  for I := 0 to bladecount - 2 do
  begin
    offset[i]:=bladepos[i+1]-bladepos[i];
  end;
  offset[bladecount - 1]:=360-bladepos[bladecount - 1]+bladepos[0];
end;

procedure cShape.PrepareBladePos(offset:array of single);
var
  I, bladecount: Integer;
  p:single;
begin
  bladecount:=length(offset)+1;
  setlength(blades, bladecount);
  p:=0;
  for I := 0 to bladecount - 2 do
  begin
    blades[i]:=offset[i] + p;
    p:=blades[i];
  end;
end;

procedure cShape.setBladeNumber(count:integer);
begin
  setlength(offset,count);
  setlength(blades,count);
end;

function cShape.getBladeNumber:integer;
begin
  result:=length(blades);
end;
// t1, t2 - ������ � ���������� ������� � ����
procedure cShape.Eval(taho:csensor; Sensor:cSensor; stage:cbldobj;showForm:boolean; t1,t2:integer);
var
  alg:cshapealg;
  opts:cBaseOpts;
  slist:cAlgsensorList;
begin
  if sensor=nil then Exit;
  alg:=cshapealg.create;
  opts:=cBaseOpts.Create;
  opts.stage:=cstage(stage);
  opts.showFrm:=showForm;
  opts.eng:=taho.eng;
  opts.stage:=cstage(stage);
  opts.useNearest:=false;
  opts.evalSkipBladesInTurn:=false;
  slist:=cAlgsensorList.create;
  slist.destroydata:=false;
  slist.add(sensor);
  if StageShapeForm.ShowModal(taho,slist,opts) = mrok then
  begin
    if not showform then
    begin
      opts.startind:=t1;
      opts.endind:=t2;
    end;
    alg.getOpts(opts);
    alg.apply(taho, slist, opts);
  end;
  slist.destroy;
  alg.destroy;
  opts.Destroy;
  init:=true;
end;

end.
