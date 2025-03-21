unit uMeasureTest;

interface

uses
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uchart,
  uGistogram, uTrend, ubldeng, uBaseBldAlg,  uBaseObj, uAxis, usensorlist,
  uTextLabel, uCommonTypes, sysutils, uMyMath, uTag, classes;

type

  cMeasureTestAlg = class(cBaseBldAlg)
  protected
    // ������ ����� ���������� ����
    m_XYArTag:array of c2vectortag;
  protected
    //procedure CommonSensorProc(taho:csensor;sensors:cAlgSensorList);override;
    //procedure CreateTags;override;
    //procedure OnSetDrObj(sender:tobject);
  public
    //function CreateOpts:cbaseopts;override;
    //function AlgID:integer;override;
  end;

implementation
uses
  upage, uUTSSensor;

{procedure cTahoAlg.OnSetDrObj(sender:tobject);
begin
  if sender<>nil then
  begin
    if sender is ctrend then
      ctrend(sender).drawpoint:=false;
  end;
end;

procedure cTahoAlg.CreateTags;
var
  tag:cBaseTag;
begin
  if tags.Count<>0 then exit;

  tag:=c2VectorTag.create;
  tag.active:=true;
  tag.name:='Taho';
  tag.dsc:='�������� ������ ��������� ���� �� �������';
  tags.AddObj(tag);
  m_TahoTag:=c2Vectortag(tag);
  m_tahoTag.OnSetDrawObj:=OnSetDrObj;

  tag:=c2ScalarTag.create;
  tag.active:=true;
  tag.name:='MinMaxTaho';
  tag.dsc:='������� � �������� ���� �������';
  tags.AddObj(tag);
  m_MinMaxTag:=c2ScalarTag(tag);

  tag:=cScalarTag.create;
  tag.active:=true;
  tag.name:='MTaho';
  tag.dsc:='���. ��������';
  tags.AddObj(tag);
  m_MTag:=cScalarTag(tag);

  tag:=cScalarTag.create;
  tag.active:=true;
  tag.name:='DTaho';
  tag.dsc:='���������';
  tags.AddObj(tag);
  m_DTag:=cScalarTag(tag);
  setTagsBuffers(nil);
end;

// ��c��� ����� ������ ;��������� ������� �� ������� � ������ ��������
procedure EvalTaxo_(sensor:csensor; tags:cBaseObjList; useUTS:boolean);
var
  ticks:cBaseTicks;
  len:integer;
  dT:stickdata;
  i: Integer;
  time,freq,TurnTime:double;

  lp2:point2;
  TahoTag,Mtag,DTag,minmax:cbasetag;

  uts:cUTSSensor;
begin
  if useUTS then
    uts:=cUTSSensor(sensor.eng.uts);

  tahotag:=cbasetag(tags.getobj('Taho'));
  minmax:=cbasetag(tags.getobj('MinMaxTaho'));
  Mtag:=cbasetag(tags.getobj('MTaho'));
  DTag:=cbasetag(tags.getobj('DTaho'));

  ticks:=sensor.chan.ticks;
  len:=ticks.Count;
  c2VectorTag(tahotag).length:=len-1;
  // ��������� �����
  for i := 1 to len-1 do
  begin
    //sensor.eng.getmessage(inttostr(i)+' '+ticktostr(ticks.gettick(i)), 2);
    dt:=DecTicks(ticks.gettick(i-1),ticks.gettick(i));
    TurnTime:=TickToSec(dt);
    // ������ ������� ��������
    freq:=1/turntime;
    // ������ �������(����� ���� ������� freq)
    if not useUTS then
      time:=TickToSec(ticks.gettick(i))-(turntime/2)
    else
      time:=uts.gettime(ticks.gettick(i));
    c2VectorTag(tahotag).value[i-1]:=p2(time,freq);
    if minmax.active then
    begin
      if i=1 then
      begin
        c2ScalarTag(minmax).Value:=p2(freq,freq);
      end
      else
      begin
        lp2:=c2ScalarTag(minmax).Value;
        if lp2.x>freq then
          c2ScalarTag(minmax).Value:=p2(freq,lp2.y);
        if c2ScalarTag(minmax).Value.y<freq then
          c2ScalarTag(minmax).Value:=p2(lp2.x,freq);
      end;
    end;
  end;
  if Mtag.active then
  begin
    cScalarTag(Mtag).value:=c2VectorTag(tahotag).m;
  end;
  if Dtag.active then
  begin
    cScalarTag(Dtag).value:=c2VectorTag(tahotag).d;
  end;
end;


procedure cTahoAlg.CommonSensorProc(taho:csensor;sensors:cAlgSensorList);
begin
  EvalTaxo_(taho, tags, useuts);
  // ��������� �������� �������� � RT
  algblocked:=true;
end;


function cTahoAlg.AlgID:integer;
begin
  result:=c_TahoAlg;
end;

function cTahoAlg.CreateOpts:cbaseopts;
begin
  result:=cBaseOpts.create;
  setopts(result);
end;}

end.
