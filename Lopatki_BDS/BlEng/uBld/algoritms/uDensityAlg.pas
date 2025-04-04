// ������� ���� ������������ ���������� ��������� � �������
// ����� ����������� ������� ����������� �� ������ ���������� skipBlade
unit uDensityAlg;

interface
uses
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uchart,
  uGistogram, uTrend, ubldeng, uBaseBldAlg,  uBaseObj, uAxis, usensorlist,
  uTextLabel, uCommonTypes, sysutils, uMyMath;

type
  cDensityOpts = class(cBaseOpts)
    chart:cchart;
    step:single;
    WriteText:boolean;
    // ����������� �������� �� ��������
    Normalise:boolean;
    UseStageInfo:boolean;
  public
    constructor create;override;
  end;


  cDensityAlg = class(cBaseBldAlg)
  protected
    step:single;
    gist:cGistogram;
    gistItem:cGistogramItem;
    // ������� �� �������
    WriteText:boolean;
    // ����������� �������� �� ��������
    Normalise:boolean;
    // ������������ ���� �������
    UseStageInfo:boolean;
  protected
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function TurnSensorProc(s:csensor):integer;override;
    procedure CommonSensorProc(taho:csensor;sensors:cAlgSensorList);override;
    procedure writeGistText;
    // ��������� ��� ��������� ��������������� �����
    // i - ������ �������� ��������
    function BadTicksProc(s:csensor;i:integer):integer;override;
  public
    procedure getOpts(opts:cBaseOpts);override;
  end;

  // ��������� ���������� ��������� ������ ������� ��� ������������������ �����
  procedure EvalDensity(const Taxo:csensor; sensors:cAlgSensorList; chart:cchart; step:single; normalise, drawText, UseStageInfo:boolean);


implementation
uses
  upage;
const
  c_thereshold = 1.5;

function getGistogram(c:cchart):cGistogram;
var
  i:integer;
  obj:cbaseobj;
  axis:caxis;
begin
  axis:=cpage(c.activepage).activeAxis;
  for I := 0 to Axis.ChildCount - 1 do
  begin
    obj:=axis.getChild(i);
    if obj is cgistogram then
    begin
      result:=cgistogram(obj);
      result.clear;
      exit;
    end;
  end;
  result:=axis.AddGistogram;
end;

procedure cDensityAlg.getOpts(opts:cBaseOpts);
begin
  inherited;
  gist:=getgistogram(cDensityOpts(opts).chart);
  gist.width:=cDensityOpts(opts).step;
  // ����������� �������� �� ��������
  Normalise:=cDensityOpts(opts).Normalise;
  WriteText:=cDensityOpts(opts).WriteText;
  // ���� �� �������� ��������� ���-� �� ������� � ��� ����� � ������� ��������
  callBadTicksProc:=not needevalBladeCount;
end;

procedure cDensityAlg.CommonSensorProc(taho:csensor;sensors:cAlgSensorList);
var
  division,i,j, order, turnindex:integer;
  pos:single;
  t1,t2:sTickData;
begin
  inherited;
  //if usestageinfo then
  begin
    // �������� � �������
    if gist<>nil then
    begin
      if Normalise then
      begin
        if usestageinfo then
        begin
          division:=sstruct[0].validturns;
        end
        else
        begin
          division:=sstruct[0].validturns+sstruct[0].dropedturn;
        end;
        gist.devide(division);
      end;
      if (usestageinfo or needevalBladeCount) then
      begin
        if WriteText then
          writeGistText;
      end;
    end;
  end
  {else
  begin
    for I := 0 to List.Count - 1 do

    t1:=taho.chan.ticks.gettick(turnind);
    // ����� �������
    t2:=taho.chan.ticks.gettick(turnind+1);
  end;}
end;

function cDensityAlg.BadTicksProc(s:csensor;i:integer):integer;
var
  j:integer;
  pos:single;
begin
  // ������������ ����� ��������� �������������� � ������ ������� �����������
  result:=0;
  if (sensorind>-1) and (lastSensorInd>-1) then
  begin
    for j:=sensorind to lastSensorInd do
    begin
      // ���� pos>360 �� ��� ��� �������
      pos:=EvalTickPos(t1,t2,s.chan.ticks.gettick(j));
      gist.addValue(pos,1);
    end;
  end;
end;

function cDensityAlg.TurnSensorProc(s:csensor):integer;
var
  j:integer;
  pos:single;
begin
  // ������������ ����� ��������� �������������� � ������ ������� �����������
  result:=0;
  for j:=sensorind to (sensorind+BladeCount - 1) do
  begin
    pos:=EvalTickPos(t1,t2,s.chan.ticks.gettick(j));
    gist.addValue(pos,1);
  end;
end;

procedure cDensityAlg.writeGistText;
var
  bl, realbl, firstforblade,lastforblade,
  // ����� �������������� �������
  ind,
  i:integer;
  x,prevx:single;
  txtLbl:ctextlabel;
  h,h1,h2:single;
  rect:frect;
begin
  bl:=-1;
  prevx:=-3;
  firstforblade:=0;
  gist.events.active:=false;
  rect:=gist.GetBound;
  h2:=rect.TopRight.y-rect.BottomLeft.y;
  h1:=h2*0.2;
  h2:=h2*0.05;
  for I := 0 to gist.count - 1 do
  begin
    gistitem:=cGistogramItem(gist.Items.getObj(i));
    x:=gistItem.getX;
    if i=0 then
      prevx:=x;
    if (x-prevx)>=c_thereshold then
    begin
      lastforblade:=i-1;
      inc(bl);
      txtlbl:=ctextlabel.create;
      realbl:=uBldMath.getBladeNumber(sensorsList.GetSensor(CurSensorInd).skipblade,bl,bladecount);
      txtlbl.text:=inttostr(realbl);
      gistitem:=cGistogramItem(gist.Items.getObj(firstforblade));
      x:=gistitem.getx;
      gistitem:=cGistogramItem(gist.Items.getObj(lastforblade));
      prevx:=gistitem.getx;
      x:=(x+prevx)/2;

      if mod2(bl) then
        h:=h1
      else
        h:=h2;
      txtlbl.Position:=p2(x,h);
      if bl=bladecount - 2 then
      begin
        gist.events.active:=true;
      end;
      gist.AddChild(txtlbl);
      firstforblade:=i;
      gistitem:=cGistogramItem(gist.Items.getObj(firstforblade));
      x:=gistitem.getx;
    end;
    prevx:=x;
  end;
end;

// ��������� ��������� ������������� �����������
procedure EvalDensity(const Taxo:csensor;sensors:cAlgSensorList;chart:cchart; step:single; normalise, drawText, usestageinfo:boolean);
var
  alg:cDensityAlg;
  opts:cDensityOpts;
begin
  opts:=cDensityOpts.create;
  opts.needevalBladeCount:=usestageinfo;
  opts.UseStageInfo:=usestageinfo;
  opts.chart:=chart;
  opts.step:=step;
  opts.Normalise:=normalise;
  opts.WriteText:=drawText;

  alg:=cDensityAlg.create;
  alg.eng:=taxo.eng;
  alg.apply(Taxo,Sensors,opts);
  alg.destroy;
  opts.destroy;
end;

constructor cDensityOpts.create;
begin
  inherited;
  usestageinfo:=false;
end;

end.
