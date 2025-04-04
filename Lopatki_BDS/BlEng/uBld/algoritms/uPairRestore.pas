unit uPairRestore;
// ������������ ����� ������ �� ����
// 3d ����� ������ �� �������. � �������� ������� - ����� �������
// � �������� x - ����� �������
// ����� ����� ������ � 3d.
// ������ ������� � ������� - ����� �������
// � ������� �� ����� ����� ����� ���������� ���� ����

interface
uses
  classes, sysutils,Graphics,  controls, stdctrls, uchart, uaxis, uBldGlobalStrings,
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uProgressDlg,
  ubldeng, uBaseBldAlg, ustage, uBaseObj, uturbina, PathUtils, types,
  usensorlist, uCommonTypes, uGistogram, uBldTypes, upair, uTag, NativeXML, dialogs,
  uPairRestoreForm;

type
  sArray = array of single;

  // �������� ��������������� ������ �������� �� ����� ������
  cPairRestore = class(cBaseBldAlg)
  protected
    base:single;
    m_XYArTag:c2vectortag;
    // ����� ��������
    tcount:integer;
  public
    pair:cpair;
  public
    constructor create;override;
  protected
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function getsensorindex(s:csensor):integer;
    procedure CommonSensorProc(taho:csensor;sensors:cAlgSensorList);override;
    // ��������� ������. ���� ��������� ������ ���������� false
    function ProcessErrors(taho:csensor; sensors:cAlgSensorList):boolean;override;
    // ������� ����
    procedure createTags;override;
    procedure InitOpts;override;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
    procedure GetNewData(turncount:integer);override;
    procedure SecondProcess;override;
  public
    function AlgID:integer;override;
  end;

  procedure BuildPairRestore(taho:csensor; sensors:cAlgSensorList; data:pointer);

implementation
uses
  uPairTrendForm, uUTSSensor;

constructor cPairRestore.create;
begin
  inherited;
  // ���� ��������� ���� ������ �� ��������� ���� ������
  LinkedSensors:=true;
  DoubleProcessing:=true;
end;

function cPairRestore.getsensorindex(s:csensor):integer;
var
  i:integer;
begin
  for I := 0 to sensorsList.Count - 1 do
  begin
    if s=sensorslist.getsensor(i) then
    begin
      result:=i;
    end;
  end;
end;

procedure cPairRestore.SecondProcess;
var
  dist, cursensirind, i,turnind, blade, bladeindex, sensorind,
  // lastblock + ����� ��������������� ������� ������ ��������� �������
  processedturn,
  // ����� ���������� ������������ �������
  turn,lastblock:integer;
  chain:tpoint;
  s,s1,s2:csensor;
  t1,t2, tick1,tick2:stickdata;
  freq:single;
  p:point2;
begin
  s:=sensorsList.GetSensor(0);
  s2:=sensorsList.GetSensor(1);
  if s.pos>s2.pos then
  begin
    s1:=s2;
    s2:=s;
  end
  else
  begin
    s1:=s;
  end;
  turn:=0;
  processedturn:=0;
  lastblock:=0;
  // ���� �� �������� ������ ��������
  for I := 0 to goodTurnChainLength - 1 do
  begin
    chain:=GoodTurnsChain[i];
    // ���� � ������� ����� ������ �������
    for turnind := chain.x to  chain.y do
    begin
      if chain.y-chain.x<=2 then
        break;
      processedturn:=lastblock+turnind-chain.x;
      if turnind=chain.y-2 then
      begin
        break;
      end;
      for blade := 0 to bladecount - 1 do
      begin
        // ������� ������� �� ������ �������
        bladeindex:=GetBladeImpulsIndex(s1, blade);
        cursensirind:=getsensorindex(s1);
        // �������� ������ ������� �������� �� ���������� �������
        sensorind:=sstruct[cursensirind].sensorind[processedturn];
        // ������� �� ������� blade
        tick1:=s1.chan.ticks.gettick(sensorind+bladeindex);

        // ������� ������� �� ������ �������
        cursensirind:=getsensorindex(s2);
        bladeindex:=GetBladeImpulsIndex(s2, blade);
        // ������� ������� �� �������
        if (blade>s1.skipBlade) and (blade<=s2.skipBlade) then
        begin
          sensorind:=sstruct[cursensirind].sensorind[processedturn+1];
          // ������ �������
          t1:=curtaho.chan.ticks.gettick(turnind);
          // ����� �������
          if turnind+1=tcount then
            exit;
          t2:=curtaho.chan.ticks.gettick(turnind+2);
          freq:=GetFreq(t1,t2)*2;
        end
        else
        begin
          sensorind:=sstruct[cursensirind].sensorind[processedturn];
          // ������ �������
          t1:=curtaho.chan.ticks.gettick(turnind);
          // ����� �������
          t2:=curtaho.chan.ticks.gettick(turnind+1);
          freq:=GetFreq(t1,t2);
        end;
        tick2:=s2.chan.ticks.gettick(sensorind+bladeindex);
        // ����������� ���
        dist:=evDecTicks(tick1,tick2);
        p.y:=EvalTickDPos(freq, dist);
        p.y:=p.y-base;
        if compareticks(tick1,tick2)=1 then
          p.x:=TickToSec(tick1)
        else
          tick1:=tick2;
        p.x:=bladecount*turn+blade;
        m_XYArTag.Add(p);
      end; // ���������� ����� �� ��������
      inc(turn);
    end;// ���������� ������� ���������� ��������
    lastblock:=lastblock+chain.Y-chain.x+1;
  end;
end;

procedure cPairRestore.CommonSensorProc(taho:csensor;sensors:cAlgSensorList);
begin
  base:=pair.getBase;
  inherited;
end;

function cPairRestore.ProcessErrors(taho:csensor;sensors:cAlgsensorList):boolean;
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


function cPairRestore.AlgID:integer;
begin
  result:=c_PairShapeTrend;
end;

procedure cPairRestore.InitOpts;
begin
  inherited;
  useStageInfo:=true;
  usenearest:=true;
end;


procedure cPairRestore.createTags;
var
  tag:cBaseTag;
  i:integer;
begin
  tags.cleardata;
  tag:=c2VectorTag.create;
  tag.active:=true;
  tag.name:='RestoreShape';
  if pair<>nil then
    tag.dsc:='������ ����� �� ���� �������� '+ pair.name;
  tags.addobj(tag);
  m_XYArTag:=c2VectorTag(tag);
  tag.blocked:=false;
end;

procedure cPairRestore.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
begin
  inherited;
end;

procedure cPairRestore.SaveObjAttributes(xmlNode:txmlNode);
begin
  inherited;
end;

procedure cPairRestore.GetNewData(turncount:integer);
var
  i:integer;
begin
  inherited;
  tcount:=turncount;
  m_XYArTag.length:=turncount*bladecount;
end;


procedure BuildPairRestore(taho:csensor; sensors:cAlgSensorList; data:pointer);
var
  opts:cBaseOpts;
  slist:cAlgSensorList;
  i:integer;
  p:cpair;
begin
  slist:=cAlgSensorList.create;
  slist.destroydata:=false;
  // �������� ����
  p:=cpair(sensors.GetObj(0));
  for I := 0 to p.sensors.Count - 1 do
  begin
    slist.add(csensor(p.sensors.getobj(i)));
  end;
  // ����� ���������
  opts:=cBaseOpts.Create;

  opts.SampleRate:=1;
  opts.SaveSignals:=true;
  opts.b_3D:=true;
  opts.portionSize:=cstage(p.stage).BladeCount;

  opts.testname:=v_ShortDscPairRestore+'_'+p.name;
  opts.eng:=taho.eng;
  opts.chart:=cchart(data);
  opts.useBladesPos:=true;
  opts.useNearest:=true;
  opts.useStageInfo:=true;
  opts.stage:=cstage(p.stage);
  opts.data:=p;
  PairRestoreForm.ShowModal(taho,slist,opts);
  slist.destroy;
  opts.Destroy;
end;

end.
