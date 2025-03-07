unit uBaseBldAlg;

interface
uses
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uchart,types, sysutils,
  uGistogram, uTrend, ubldeng, ustage, ubldtypes, uSensorList, uCommonTypes, dialogs,
  udrawobj, uTag, classes, ueventlist, uBaseObj, NativeXml, uMyMath,
  MathFunction, uMeraFile, utagsignal, uUtsSensor, uTagOwnerObj;


type
  sTurnCluster = record
    // ��������� �������� � �������
    p,
    // ��������� ��������� �������� � �������
    p0,
    // ��������� ���� ������� ������ ������ �������
    path:single;
    // ����� ������� �� ������� ������ �������
    blade,
    // ������ �������� � ������� �����
    i:integer;
    // ����� �������� � �����
    t:stickdata;
    // ����� � ���������� ������� �� ���������� ���������
    p2:point2;
  end;

  AdjustSensorStruct = record
    interrupt:boolean;
    // ���������� ��������
    prevOffset:single;
    // ������ ����� ���������� �������� ��� ������� �� ������������ ��������
    validturns,
    dropedturn:integer;
    // ����������� 0..1
    droped:single;
    // ���������� ����� ������ � ��������� ��������
    // ��������� ��������� ��������� �������.
    FirstEndDist,
    EndPos:single;
    // ������������� �� ����� ������
    // ����� ���������� �� �������, ��� 0-� ������� ���������� �� ������� ��������
    // 1-� �� �������
    offsets:array of single;
    // ������ �������� ������ ��������� � ���������� ��������. ���� ������ ������ �������
    // �� ������� ������� - ������ ������� �� ������� �� ������ �������.
    // ����������� ���� �������� �������������
    // ������ ������� ��������� � ������� ���������� ���������� �������
    sensorind:array of integer;
  end;

  cBaseOpts = class
    needevalBladeCount:boolean;
    // ������� ������������� (<0 ���� ������ x/y)
    SampleRate,
    // ������ ������ ��� ������ 3d
    portionSize,
    dZ
    :integer;
    // ��������� ������
    SaveSignals,
    // ���������� ����� ��������� ����� ����������� ������
    showSaveDlg,
    // �������� 3d
    b_3D:boolean;
    // ���� � ������������ ������
    path, dsc, testname:string;
    // ������������ ���
    useUTS:boolean;
    chart:cchart;
    showFrm:boolean;
    // ������������ ��������� ����������. ���� false �� �� ��������������
    // useprevoffset, useBladesPos (�� ������ firstsensorind)
    useStageInfo,
    // �������� ��������, ��� ������� �� ����������� � ������ ������ �� ���������
    // ������ (������������ ������� �� �������, ��������)
    useNearest,
    // ������������ ������� ���������� ��������� �� �������
    // ��� �������� ����������� ���������
    useDist:boolean;
    // UseCorr ������ ������ ������� � ������� �� ������������ ����������
    useCorr:boolean;
    // ������������ blades ���� true ����� ������������ shape (����� �������)
    useBladesPos:boolean;
    // ������ �� ���������� �� ������ �������
    offset:single;
    // ��������� ��������� ������ �������
    pos,
    // ������ �� �������
    stage:cstage;
    // ������ �� ����� ��� ����������� �����������
    trend:ctrend;
    // ��� ������
    data:pointer;
    // ������������ ����� ����������� ������� � �������
    evalSkipBladesInTurn,
    // �������� ��������� �� ��������� ��������������� �����
    callBadTicksProc:boolean;
    eng:cbldeng;
    taho:csensor;
    tags:cBaseObjList;
    alg:tobject;
    startind,endind:integer;
  public
    constructor create;virtual;
    procedure createEvents(e:ceventlist);
    procedure DeleteEvents(e:ceventlist);
  end;

  cBaseBldAlg = class(cTagOwnerObj)
  public
    // ������������ � false ��� ������� ���������� ����� ���� ��� ���������� ���������
    // ����� ��� ��������� ������ �� ������� � �� ����� ��������� ����� �������
    // ������
    needevalBladeCount:boolean;
    // ������� ������������� (<0 ���� ������ x/y)
    SampleRate,
    // ������ ������ ��� ������ 3d
    portionSize,
    dZ
    :integer;
    // ��������� ������
    SaveSignals,
    // ���������� ����� ��������� ����� ����������� ������
    showSaveDlg,
    // �������� 3d
    b_3D:boolean;
    // ���� � ������������ ������
    path, dsc, testname:string;

    // ������������ ���
    useUTS:boolean;
    // ����� � ������� ����������� ��������
    Task:cbaseobj;
    ownerSensorList:boolean;
    sensorsList:cAlgSensorList;
    // ������� ������
    curtaho:csensor;
    drawObj:cdrawObj;
    eng:cbldeng;
    prepared,
    algBlocked:boolean;
    // ��� ������� ������� �������
    UTSTag:c2dVectorTag;
  protected
    // �������� ������������� - �� ������ ������ ���������� ���������� �������
    // �� ������ ������ ����������� ���� ��������� ����� ���� ������ ������� �� �������
    DoubleProcessing:boolean;
    // ������������������ ���������� ��������. ����� ��������� - ����� ���������� ��������
    // �������� p.x - ������ ������������������ p.y - ����� �������������������
    GoodTurnsChain:array of tpoint;
    // ����� �������������������
    goodTurnChainCapacity, goodTurnChainLength,
    ValidTurns:integer;

    beginInd,EndInd:integer;
    sstruct:array of AdjustSensorStruct;
    // ������������ ��������� ����������. ���� false �� �� ��������������
    // useprevoffset, useBladesPos (�� ������ firstsensorind)
    useStageInfo,
    // ���� ��������, ��� ������� �������� � ������, �.�. ���� ������������ ������
    // �� ������ ������� ���� ����������� � ������. validturn �������������, ������ ���� ���
    // ������� ����� ���������� ������
    LinkedSensors,
    // ������������ ����� ����������� ������� � �������
    evalSkipBladesInTurn,
    // ���� ������� �������, ��� ���������� ���������� ������ ��� �������,
    // ������������ � false ���� ������� ������� LinkedSensors � ���������� ������ �� ����
    // ������� �������
    needProcessTurn,
    // ������������ ������� ���������� ��������� �� �������
    // ��� �������� ����������� ���������
    usedist:boolean;
    turnCluster:sTurnCluster;
    // �������� ��������� �� ��������� ��������������� �����
    callBadTicksProc,
    // �������� ��������, ��� ������� �� ����������� � ������ ������ �� ���������
    // ������ (������������ ������� �� �������, ��������)
    fuseNearest:boolean;
    // UseCorr ������ ������ ������� � ������� �� ������������ ����������
    useCorr:boolean;
    // ������������ blades ���� true
    useBladesPos:boolean;
    // ������ �� ���������� �� ������ �������
    offset:single;
    BladePos:single;
    // ������ �� �������
    stage:cstage;
    // ����� �������
    bladecount:integer;
    // ������ � ����� ���������� �������
    t1, t2:stickdata;
    // ������ ������� ���� � ������� ������ ������ �������
    sensorind,
    // ��������� ��� � ���������� �������
    lastSensorInd,
    // ������ ��������������� �������
    turnind,
    // ������ ��������������� ������� � ������
    CurSensorInd:integer;
    blades:array of single;
    // ����� �������
    turnFlags:cardinal;
  private
    // ��������������� ����� ������������ ���������� ����������� ���� ��
    // ������������ ������ �� ������ �������
    buf:array of integer;
  protected
    procedure GetNewData(turncount:integer);virtual;
    procedure setTagsBuffers(opts:cbaseOPts);virtual;
    procedure setopts(opts:cbaseopts);virtual;
    function AlgEvalTickPos(t1_,t2_, tick:stickdata):single;
    // �������� ������ ������� ������� � �������
    function GetFirstIndInTurn(t1_,t2_:stickdata;s:csensor):integer;
    function GetLastIndInTurn(t1_,t2_:stickdata;s:csensor; var skipCount:integer):integer;
    // i:����� �������� � ������� �����
    procedure EvalTurnCluster(s:csensor;i:integer);
    // �� ���������� ��������� ����������. ���������� �������� ���������
    // �������� � ������� � ��� �����
    procedure EvalSimpleTurnCluster(s:csensor;i:integer);
    // ��������� ������ � blades. ������ ������� �� ������� s (������� ��������
    //firstbladeoffset)
    procedure PrepareBladePos(s:csensor);
    // �������� ����� ������� � �����
    function GetDTurn:integer;
    // �������� ������ ������� ���� � ����� �������.
    function GetSensorInd(s:csensor; t1, t2:stickdata):integer;
    function GetEndSensorInd(s:csensor; t1, t2:stickdata):integer;
    // ���������� false ���� ���������� �������� ���������� ���������
    // ���������� 0 - ���������� ����������. 1 - ������� � ���������� �������.
    // 2 - �������� ����������
    function TurnSensorProc(s:csensor):integer;virtual;
    // ��������� ��� ��������� ��������������� �����
    // i - ������ �������� ��������
    function BadTicksProc(s:csensor;i:integer):integer;virtual;
    // ���������� ����� turnProc
    function BeforeTurnSensorProc:boolean;virtual;
    // ������ ��������� �������. BladeCount - �������� ��� ���������� ��������
    procedure CommonSensorProc(taho:csensor; sensors:cAlgSensorList);virtual;
    // ��������� i-� ������� �� ������� �� ��������� �������
    function GetSensorBladePos(s:csensor; index:integer):single;
    // �������� ��������� ��������� �������
    function getEndBladePos:single;
    // �������������� ������ �������
    function CorrectFirstWithNearest(s:csensor;firstInTurn:integer;t1_,t2_:stickdata):integer;
    function CorrectFirstWithPrevOffset(s:csensor;firstInTurn:integer;t1_,t2_:stickdata):integer;
    // �������������� ��������� ������� bcgjkmpez ������ ����������� �������.
    // � �������� ����� ������� �������� ��������� �������� ��������� ����� ��������� ��� ��������
    // � �������� ���������� �������� ����� ��������� ������� �� ������� �������, � ����������� ���
    // �������� �� ����, ������ ��������� �� ����� ��������� ��� ��� ������� ����� �������.
    function CorrectLastWithDist(s:csensor;LastInTurn:integer;
                                 t1_,t2_:stickdata; var skipcount:integer;var inserted:integer):integer;
    function CorrectLastWithNearest(t1_,t2_:stickdata;s:csensor):integer;
    // �������� ����� ������� �� ������ ���� � �������
    function getBladeNumber(s:csensor; SensorIndex:integer):integer;
    // �������� ������ �� ��������� � ���������� �������:
    // �������� ����� ������� � ������� ���� ������ ������� ��� ������� bl
    function GetBladeImpulsIndex(s:csensor; bl:integer):integer;
    procedure InitOpts;virtual;
    // ��������� ��������� �� ���������� ��� ������� ���������� ��������
    function ProcClusterError(taho:csensor;sensors:cAlgSensorList):boolean;
    // ��������� ������. ���� ��������� ������ ���������� false
    function ProcessErrors(taho:csensor;sensors:cAlgSensorList):boolean;virtual;
    // �������� ��������� ��������� �������. ������ �������� ������ ������������
    // 0-� ������� (������ ������� �� ������� �� �������� ������� �����).
    // ����� �������� ��������� i-� ������� �� ������� �� ��������� �������
    // (����� ����� ������� ������ ������� �� ����), ����� ������������
    // GetSensorBladePos(index:integer):single;
    function GetBladePos(index:integer):single;
    // ��������� �������
    function SensorProcessTurn(s:csensor):integer;
    function getUseNearest:boolean;
    function BeforeCommonSensorProc:boolean;virtual;
    procedure AfterTurnProc;virtual;
    procedure SecondProcess;virtual;
    property usenearest:boolean read getUseNearest write fusenearest;
    procedure createEvents(e:ceventlist);virtual;
    procedure DeleteEvents(e:ceventlist);virtual;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
    procedure OnEndTurn;virtual;
    procedure Preparetosave(tag:cbasetag);virtual;
  public
    procedure SaveMera;
    // ������������� ����� ���������
    procedure getOpts(opts:cBaseOpts);virtual;
    constructor create;override;
    destructor destroy;override;
    function CreateOpts:cbaseopts;virtual;
    procedure apply(taho:csensor; sensors:cAlgSensorList; data:cBaseOpts);overload;
    procedure apply(ibegin,iend:integer);overload;
    function AlgID:integer;virtual;
    procedure SetTimeBeginEnd(time:tpoint);
    procedure prepare;
    function status:integer;
  end;

  const
    // �������������� (�������� ��� ������� ������������� ������� �������)
    c_Correct = $000001;
    // ������ ������� � �������
    c_NewTurn = $000002;
    // ����������
    c_Drop = $000004;

    c_error = -1;
    c_Ok = 1;

    // ������������ �������� � TurnSensorProc
    c_interrupt = 2;
    // ������� ������
    c_breakTurn = 1;
    c_continue = 0;

    // �������������� ����������
    c_BaseAlg = 1;
    c_PairShape = 2;
    c_TahoAlg = 3;
    c_BladeTrend = 4;
    c_RestoreSignal = 5;
    c_PairShapeTrend = 6;



implementation
uses
  uAlgMng, ubldtimeproc, uAlarms, uprocessAlgTask;

constructor cBaseOpts.create;
begin
  showFrm:=true;
  useStageInfo:=true;
  useNearest:=true;
  useCorr:=false;
  useBladesPos:=false;
  offset:=2;
  callBadTicksProc:=false;
  evalSkipBladesInTurn:=true;

  SampleRate:=1000;
end;

procedure cBaseOpts.createEvents(e:ceventlist);
begin
  if alg<>nil then
    cBaseBldAlg(alg).createevents(e);
end;

procedure cBaseOpts.DeleteEvents(e:ceventlist);
begin
  if alg<>nil then
    cBaseBldAlg(alg).DeleteEvents(e);
end;

destructor cBaseBldAlg.destroy;
begin
  if ownerSensorList then
    sensorsList.destroy;
  // ������� ����� ���
  if UTSTag<>nil then
    UTSTag.destroy;
  inherited;
end;

constructor cBaseBldAlg.create;
begin
  inherited;
  DoubleProcessing:=false;
  ownerSensorList:=false;
  algblocked:=false;
  prepared:=false;
  name:=ClassName;
  InitOpts;
  createTags;
end;

procedure cBaseBldAlg.createEvents(e:ceventlist);
begin

end;

procedure cBaseBldAlg.DeleteEvents(e:ceventlist);
begin

end;

function cBaseBldAlg.getdturn:integer;
begin
  result:=evDecTicks(t1,t2);
end;

procedure cBaseBldAlg.PrepareBladePos(s:csensor);
var
  I: Integer;
begin
  setlength(blades, bladecount);
  prepareBlades(blades,stage.Shape.offset);
end;

function cBaseBldAlg.AlgID:integer;
begin
  result:=c_BaseAlg;
end;

function cBaseBldAlg.GetBladePos(index:integer):single;
var
  i:integer;
  p:single;
begin
  if stage<>nil then
  begin
    if useBladesPos then
      p:=stage.Shape.blades[index]
    else
    begin
      p:=0;
      if GetOffsetsInit(blades) then
      begin
        p:=blades[index];
      end
      else
      begin
        p:=-1;
        errorStage_noBladesPos(stage,stage.eng.flags);
      end;
    end;
    result:=p;
  end
  else
  begin
    result:=-1;
  end;
end;

function cBaseBldAlg.GetSensorBladePos(s:csensor; index:integer):single;
var
  p, spos:single;
begin
  p:=GetBladePos(index);
  spos:=s.pos;
  if p<=spos then
  begin
    result:=spos - p;
    exit;
  end
  else
    result:=360 - p + sPos;
end;

function cBaseBldAlg.getEndBladePos:single;
var
  i:integer;
  p:single;
begin
  result:=GetBladePos(bladecount-1);
end;

function cBaseBldAlg.BeforeTurnSensorProc:boolean;
begin

end;

function cBaseBldAlg.TurnSensorProc(s:csensor):integer;
begin
  result:=0;
end;

function cBaseBldAlg.GetSensorInd(s:csensor;t1,t2:stickdata):integer;
var
  tick:stickdata;
  i:integer;
  dist, dist2:integer;
  sdist, sdist2:single;
begin
  tick:=s.chan.ticks.GetHiTick(t1,i);
  // �������� ������ ��� ������� ������ ���� ����� ������ �������
  if i>0 then
  begin
    if compareticks(tick,t2)>0 then
    begin
      result:=-1;
      exit;
    end
    else
    begin
      if compareticks(s.chan.ticks.gettick(i-1),t1)=0 then
      begin
        i:=i-1;
      end;
    end;
  end;
  result:=i;
end;

function cBaseBldAlg.GetEndSensorInd(s:csensor;t1,t2:stickdata):integer;
var
  tick:stickdata;
  i:integer;
  dist, dist2:integer;
  sdist, sdist2:single;
begin
  tick:=s.chan.ticks.GetLoTick(t2,i);
  // �������� ������ ��� ������� ������ ���� ����� ������ �������
  if i>0 then
  begin
    if i+1<s.chan.ticks.Count then
    begin
      if compareticks(s.chan.ticks.gettick(i+1),t2)=0 then
      begin
        i:=i+1;
      end;
    end;
  end;
  result:=i;
end;

function FindBlade(pos:single; blades:array of single; bladecount:integer):integer;
begin
  result:=FindInFloatArrayHiBound(blades,pos,0,bladecount-1);
  if blades[result]>pos then
    dec(result);
end;



function cBaseBldAlg.CorrectLastWithDist(s:csensor;LastInTurn:integer;
                                 t1_,t2_:stickdata; var skipcount:integer;
                                 var inserted:integer):integer;
var
  tick:stickdata;

  // ����� �������
  PrevBlade,
  blade,
  sub,
  i:integer;

  dist,min,
  TickPos,
  bladePos:single;
begin
  result:=-1;
  skipcount:=0;
  inserted:=0;
  min:=offset*2;
  PrevBlade:=0;
  for I := sensorind+1 to sensorind+bladecount - 1 do
  begin
    // ����� ������� �������� � �������
    tick:=s.chan.ticks.gettick(i);
    TickPos:=EvalTickPos(t1_,t2_,tick);
    blade:=FindBlade(tickpos,sstruct[cursensorind].offsets,bladecount);
    if blade>0 then
    begin
      dist:=abs(sstruct[cursensorind].offsets[blade-1]-TickPos);
      min:=dist;
      sub:=-1;
    end;
    dist:=abs(sstruct[cursensorind].offsets[blade]-TickPos);
    if dist<min then
    begin
      min:=dist;
      sub:=0;
    end;
    if blade<bladecount-1 then
    begin
      dist:=abs(sstruct[cursensorind].offsets[blade+1]-TickPos);
      if abs(dist)<abs(min) then
      begin
        min:=dist;
        sub:=1;
      end;
    end;
    // ���� ��������� ������� ��� �������� ������� �������
    if min>Offset then
    begin
      exit;
    end;
    blade:=blade+sub;
    sub:=blade - prevblade;
    // ���� � ������������ ������� ����� ����� ������� sub=0 ��� �� ����� >1
    if sub<>1 then
    begin
      exit;
    end;
    prevblade:=blade;
  end;
  result:=sensorind+bladecount - 1;
end;

function cBaseBldAlg.CorrectLastWithNearest(t1_,t2_:stickdata;s:csensor):integer;
var
  i,j, d:integer;
  function testLast(t,t1,t2:stickdata):boolean;
  var
    dpos:single;
  begin
    result:=false;
    dpos:=algEvalTickPos(t1,t2,t);
    // ������� ���������� �������� �� ���������� ��������� ���������
    if sstruct[cursensorind].endPos>=0 then
    begin
      dpos:=abs(sstruct[cursensorind].endpos-dpos);
      // ���������, ��� ������� ����������� �� ����� ��� �� �������� ����������
      if dpos<c_step then
      begin
        result:=true;
      end;
    end
    // ���� ��������� ��������� ������� �� ��������, �� �������, ��� �������
    // ������ ������ ������� ������ �� ������ "����" ����� ���������
    else
    begin
      if (dpos-360)<c_step then
        result:=true;
    end;
  end;
begin
  result:=lastSensorInd;
  d:=lastSensorInd-sensorind-bladecount+1;
  for I := lastsensorind-d to lastsensorind do
  begin
    if (i>=0) and (i<s.chan.ticks.count) then
    begin
      if testLast(s.chan.ticks.gettick(i),t1_,t2_) then
      begin
        result:=i;
        exit;
      end;
    end;
  end;
end;

function cBaseBldAlg.GetLastIndInTurn(t1_,t2_:stickdata;s:csensor;var skipCount:integer):integer;
var
  inserted:integer;
begin
  skipCount:=-1;
  result:=lastSensorInd;
  if lastSensorInd=s.chan.ticks.Count-1 then
    exit;
  // ������������ ������� ���������� ��������� �� �������
  // ��� �������� ����������� ���������
  if useDist then
  begin
    result:=CorrectLastWithDist(s, result,t1_,t2_,skipCount,inserted);
  end
  else
  begin
    if useStageInfo then
    begin
      if useNearest then
        result:=CorrectLastWithNearest(t1_,t2_,s)
    end;
  end;
end;

function cBaseBldAlg.CorrectFirstWithPrevOffset(s:csensor;firstInTurn:integer;t1_,t2_:stickdata):integer;
var
  tick:stickdata;
  sdist:SINGLE;
  i:integer;
begin
  result:=firstInTurn;
  // ��������� �������� � ��� ������� ����� ������� �������� ��������� �������� ���������
  // ��� �������, �� ����� �������� ��� �������� ������� �� �������
  if (sstruct[cursensorind].prevoffset<>-1000) then
  begin
    for i := -1 to 1 do
    begin
      if firstInTurn+i>=0 then
      begin
        tick:=s.chan.ticks.GetTick(firstInTurn+i);
        // ��������� ����� ��������� � ������ ��������
        sdist:=abs(sstruct[cursensorind].prevoffset-360 - algEvalTickPos(t1_,t2_,tick));
        if abs(sdist-sstruct[cursensorind].FirstEndDist)/sstruct[cursensorind].FirstEndDist<Offset then
        begin
          result:=firstInTurn+i;
          exit;
        end;
      end;
    end;
  end
  else
    result:=lastSensorInd+1;
end;

function cBaseBldAlg.CorrectFirstWithNearest(s:csensor; firstInTurn:integer;t1_,t2_:stickdata):integer;
var
  tick:stickdata;
  dist,dist2,dist3:integer;
  min,sdist,sdist2,sdist3:SINGLE;
begin
  result:=firstinturn;
  if s.pos<0 then
    s.pos:=0;
  tick:=s.chan.ticks.GetTick(firstInTurn);
  dist:=evDecTicks(t1_,tick);
  // ������������� ���������� �������� �� ����� � �������
  sdist:=EvalTickDPos(t1_,t2_,dist)-s.firstBladeOffset;
  min:=sdist;
  if abs(sdist)>offset then
    result:=-1;
  // ��������� ��� ������ ������� � ������� �� ����������� �� ����� ������� �������
  if firstInTurn>0 then
  begin
    tick:=s.chan.ticks.GetTick(firstInTurn-1);
    dist2:=evDecTicks(t1_,tick);
    sdist2:=EvalTickDPos(t1_,t2_,dist2)-s.firstBladeOffset;
    // ���� ������������ � �������� ���������
    if abs(sdist2)<abs(min) then
    begin
      if abs(sdist2)<offset then
      begin
        result:=firstInTurn-1;
      end
      else
        result:=-1;
      exit;
    end;
  end;
  // ��������� ��� ������ ������� � ������� �� ����������� �� ����� ������� �������
  if firstInTurn<s.chan.ticksCount then
  begin
    tick:=s.chan.ticks.GetTick(firstInTurn+1);
    dist3:=evDecTicks(t1_,tick);
    sdist3:=EvalTickDPos(t1_,t2_,dist3)-s.firstBladeOffset;
    if abs(sdist3)<abs(min) then
    begin
      if abs(sdist3)<offset then
        result:=firstInTurn+1
      else
        result:=-1;
    end;
  end;
end;

function cBaseBldAlg.GetFirstIndInTurn(t1_,t2_:stickdata;s:csensor):integer;
var
  NewSensorind,ind:integer;
begin
  // �������� ������ ������� �������� � �������.
  ind:=sensorind;
  // �������� ������ ������� �������� � �������.
  result:=ind;
  // ������������� ������� �������� � ������� �� ������,
  // ���� �� ���������� � ������ ������
  dropflag(TurnFlags,c_Correct);
  if useStageInfo then
  begin
    if useNearest then
    begin
      result:=CorrectFirstWithNearest(s, result,t1_,t2_);
    end
  end;
end;

function cBaseBldAlg.SensorProcessTurn(s:csensor):integer;
var
  // ������ ������� � ������� �������� �� �������
  newSensorind,
  // ������ ��� ������ �������������� �����
  j,skipcount:integer;
  nextt2:stickdata;
begin
  // ���� ������ ��� ����� t1
  sensorind:=GetSensorInd(s, t1, t2);
  if sensorind+bladecount>s.tickscount then
  begin
    sstruct[CurSensorInd].interrupt:=true;
    result:=c_breakTurn;
  end;
  if (sensorind=-1) then
  begin
    // � ������� ��� ����������. ������������� ������
    newsensorind:=-1;
    setflag(turnflags, c_drop);
    result:=c_breakTurn;
  end
  else
  begin
    // ���� ��������� ��� ����� t2
    lastSensorInd:=GetLastTick(t1,t2,s.chan.ticks);
    // ������������� ������� �������� � ������� �� ������,
    // ���� �� ���������� � ������ ������
    dropflag(TurnFlags,c_Correct);
    // ����������� ������ � ��������� ������� �� ��������� ����
    if useStageInfo then
    begin
      newSensorind:=GetFirstIndInTurn(t1,t2,s);
      if newSensorind=-1 then
      begin
        setflag(turnflags, c_drop);
        result:=c_breakTurn;
        exit;
      end;
      if NewSensorind<>Sensorind then
        SetFlag(TurnFlags,c_Correct);
      Sensorind:=NewSensorind;
    end;
    // ������� ��������� ������� � �������
    lastSensorInd:=GetLastIndInTurn(t1,t2,s, skipcount);
    if lastSensorInd-sensorind<>bladecount-1 then
    begin
      setflag(turnflags, c_drop);
      result:=c_breakTurn;
      exit;
    end;
  end;
  BeforeTurnSensorProc;
  // ���� ������ ����������
  if (newsensorind<>-1) then
  begin
    result:=c_continue;
  end;
end;

procedure cBaseBldAlg.EvalTurnCluster(s:csensor;i:integer);
begin
  EvalSimpleTurnCluster(s,i);
  if useStageInfo then
  begin
    turncluster.blade:=getBladeNumber(s,i-sensorind);
    turncluster.p0:=GetBladePos(turncluster.blade);
    // ����� ���������� �������� �� �������
    //turncluster.t:=s.chan.ticks.gettick(i);
    // �������� ��������� �������� � �������
    //turncluster.p:=algEvalTickPos(t1,t2,turncluster.t);
    // �������� ��������� ����
    turncluster.path:=GetSensorBladePos(s, turncluster.blade);
    // �������� ���������� �� ���������� ����
    turncluster.p2.y:=turncluster.p-turncluster.path;
    //turncluster.p2.x:=TickToSec(turncluster.t);
  end;
end;

procedure cBaseBldAlg.EvalSimpleTurnCluster(s:csensor;i:integer);
begin
  // ����� ���������� �������� �� �������
  turncluster.t:=s.chan.ticks.gettick(i);
  // �������� ��������� �������� � �������
  turncluster.p:=algEvalTickPos(t1,t2,turncluster.t);
  // �������� ���������� �� ���������� ����
  turncluster.p2.x:=TickToSec(turncluster.t);
end;

procedure cBaseBldAlg.CommonSensorProc(taho:csensor;sensors:cAlgSensorList);
var
  tick:stickdata;
  // ������ �������� ���� �������
  i,
  // ������ �������
  j,
  // ���� �� ������� �����
  k:integer;
  s:csensor;
  valid:boolean;
  offsets:array of single;
  dropindex:array of tpoint;
begin
  validturns:=0;
  lastSensorInd:=-1;
  // ���������� ����� ��� �������
  turnFlags:=0;
  // ���� �� ��������
  for i := beginInd to EndInd-1 do
  begin
    if sstruct[cursensorind].interrupt then
    begin
      // ���� �� ������� ��������� ������ � �� �������� ��������
      if LinkedSensors then exit;
      continue;
    end;
    turnind:=i;
    // ������ �������
    t1:=taho.chan.ticks.gettick(turnind);
    // ����� �������
    t2:=taho.chan.ticks.gettick(turnind+1);
    // ��������� ������� �� ������ �������
    valid:=true;
    for j:=0 to sensors.Count-1 do
    begin
      CurSensorInd:=j;
      s:=sensors.GetSensor(j);
      if s.tickscount<1 then
        continue;
      case SensorProcessTurn(s) of
        c_continue:
        begin
          valid:=true;
          if TurnSensorProc(s) = c_interrupt then
          begin
            valid:=false;
            sstruct[cursensorind].interrupt:=true;
          end;
        end;
        c_breakTurn:
        begin
          valid:=false;
          if callBadTicksProc then
          begin
            BadTicksProc(s,sensorind);
          end;
          if linkedsensors then
          begin
            inc(sstruct[cursensorind].dropedturn);
            break;
          end;
        end;
        c_interrupt:
        begin
          valid:=false;
          sstruct[cursensorind].interrupt:=true;
        end;
      end;
      if valid then
      begin
        inc(sstruct[cursensorind].validturns);
        if DoubleProcessing then
        begin
          sstruct[cursensorind].sensorind[validturns]:=sensorind;
        end;
      end
      else
        inc(sstruct[cursensorind].dropedturn);
    end;
    AfterTurnProc;
    // ���� ��� ������� ���������� ��������� ������
    if valid then
    begin
      OnEndTurn;
    end;
    // ���� ����� �� ����
    dropflag(turnflags,c_Drop);
  end;
  SecondProcess;
end;

function cBaseBldAlg.ProcessErrors(taho:csensor;sensors:cAlgSensorList):boolean;
var
  s:csensor;
  bExit:boolean;
  I: Integer;
begin
  result:=false;
  bExit:=false;
  if taho.tickscount<1 then
  begin
    errorTicksCount_ErrorType(taho, taho.eng.flags);
    exit;
  end;
  for I := 0 to sensors.Count - 1 do
  begin
    s:=sensors.GetSensor(i);
    if s.tickscount<1 then
    begin
      errorTicksCount_ErrorType(s, s.eng.flags);
      if sensors.Count=1 then
      begin
        result:=false;
        exit;
      end;
    end;
  end;
  if bExit then
    exit;
  result:=true;
end;

function cBaseBldAlg.ProcClusterError(taho:csensor;sensors:cAlgSensorList):boolean;
var
  sensor:csensor;
  i,l:integer;
begin
  result:=true;
  if usestageinfo=false then
    exit;
  for I := 0 to sensors.Count - 1 do
  begin
    sensor:=sensors.GetSensor(i);
    if sensor.stage=nil then
    begin
      result:=false;
    end
    else
    begin
      if cstage(sensor.stage).shape=nil then
      begin
        result:=false;
      end
      else
      begin
        if usebladespos=false then
        begin
          l:=length(cstage(sensor.stage).shape.offset);
          if cstage(sensor.stage).shape.offset[l-1]=0 then
            result:=false;
        end;
      end;
    end;
    if not result then
    begin
      errorSensor_BladePos(sensor,sensor.eng.flags);
      break;
    end;
  end;
end;

function cBaseBldAlg.BeforeCommonSensorProc:boolean;
var
  s:csensor;
  i,j:integer;
begin
  result:=ProcessErrors(curtaho, sensorslist);
  prepared:=result;
  if result then
  begin
    setlength(sstruct,sensorslist.Count);
    for I := 0 to sensorslist.Count - 1 do
    begin
      sstruct[i].validturns:=0;
      sstruct[i].dropedturn:=0;
    end;
    s:=sensorslist.GetSensor(0);
    if stage<>nil then
    begin
      bladecount:=stage.BladeCount;
      setlength(buf,stage.BladeCount);
    end;
    // ���� ������ ��������� ������� �� ������ ��� ������� ������ ��� �������� �� ���������
    if useStageInfo then
    begin
      if stage<>nil then
      begin
        if stage.Shape<>nil then
        begin
          if not usebladespos and (GetOffsetsInit(stage.Shape.offset)) then
          begin
            PrepareBladePos(s);
          end;
          // �������� ��������� ������ ������� � ������� �� ��������� ������
          // ���������� � stag
          if useNearest then
          begin
            for i := 0 to sensorslist.Count - 1 do
            begin
              s:=sensorslist.GetSensor(i);
              sstruct[cursensorind].endpos:=getEndBladePos;
              // ���������� ����� ������ � ��������� �������� � �������
              sstruct[cursensorind].FirstEndDist:=abs(sstruct[cursensorind].EndPos - 360 - s.pos);
            end;
          end;
        end;
      end
      else
        useStageInfo:=false;
    end;
    if bladecount=-1 then
    begin
      if s<>nil then
      begin
        if needevalBladeCount then
          // ������� ����� ������� �� ���������� ��������� (������/ ����)
          bladecount:=evalBladesCount(curtaho.chan.ticks, s.chan.ticks);
      end;
    end;
  end;
end;

procedure cBaseBldAlg.apply(taho:csensor; sensors:cAlgSensorList; data:cBaseOpts);
var
  s:CSENSOR;
begin
  sensorslist:=sensors;
  // ��� RunTime ����� ������ �-��� ��� getOpts ����������������
  getOpts(data);
  curtaho:=taho;
  data.startind:=0;
  data.endind:=curtaho.tickscount-1;
  if BeforeCommonSensorProc then
  begin
    apply(data.startind,data.endind);
  end;
end;

procedure cBaseBldAlg.apply(ibegin,iend:integer);
var
  s:csensor;
  i,j, tcount:integer;
  tag:cbasetag;
begin
  beginind:=ibegin;
  endind:=iend;
  //beginind:=169604*3+14000;
  tcount:=endind-beginind;
  GetNewData(tcount);
  for I := 0 to sensorslist.Count - 1 do
  begin
    sstruct[i].interrupt:=false;
  end;
  if useStageInfo then
  begin
    for I := 0 to sensorslist.Count - 1 do
    begin
      setlength(sstruct[i].offsets,bladecount);
      sstruct[i].validturns:=0;
      sstruct[i].dropedturn:=0;
      for j := 0 to bladecount - 1 do
      begin
        s:=sensorsList.GetSensor(i);
        // ����� ���� ����� �������
        tcount:=getBladeNumber(s,j);
        sstruct[i].offsets[j]:=GetSensorBladePos(s, tcount);
      end;
    end;
  end;
  CommonSensorProc(curtaho, sensorslist);
  for I := 0 to tags.Count - 1 do
  begin
    tag:=cBaseTag(tags.getobj(i));
    if tag.active then
    begin
      // �������� ����������. ���� �������� ������ � ����.
      tag.UpdateValue;
      // �������� ���������
      tag.UpdateDrawObj;
    end;
  end;
  for I := 0 to sensorslist.Count - 1 do
  begin
    sstruct[i].droped:=sstruct[i].dropedturn/(sstruct[i].dropedturn+sstruct[i].validturns);
    if sstruct[i].droped<>0 then
    begin
      sstruct[i].droped:=sstruct[i].dropedturn/(sstruct[i].dropedturn+sstruct[i].validturns);
      eng.getmessage('�� ������� '+sensorslist.GetSensor(i).name+
                    ' ������������� '+ formatstr(sstruct[i].droped*100,3)+
                    '% ��������',c_infoMessage);
    end;
  end;
  if SaveSignals then
  begin
    SaveMera;
  end;
end;



procedure cBaseBldAlg.InitOpts;
begin
  evalSkipBladesInTurn:=true;
  useNearest:=true;
  useCorr:=false;
  useBladesPos:=false;
  lastSensorInd:=0;
  offset:=2;
  bladecount:=-1;
end;

function cBaseBldAlg.getBladeNumber(s:csensor; SensorIndex:integer):integer;
begin
  result:=uBldMath.getBladeNumber(s.skipblade,sensorindex,bladecount);
end;

function cBaseBldAlg.GetBladeImpulsIndex(s:csensor; bl:integer):integer;
begin
  if s.skipblade<bl then
  begin
    result:=bladecount - bl + s.skipblade;
  end
  else
    result:=s.skipblade - bl;
end;

function cBaseBldAlg.BadTicksProc(s:csensor; i:integer):integer;
begin

end;

function cBaseBldAlg.AlgEvalTickPos(t1_,t2_, tick:stickdata):single;
begin
  if checkflag(turnFlags, c_drop) then
  begin
    //����������� ���� ��� ���� �� ����
    //Result:=evaltickpos(t1,tick,tahoar[turnind-1]);
    Result:=evaltickpos(t1,t2,tick);
  end
  else
    Result:=evaltickpos(t1,t2,tick);
end;

function cBaseBldAlg.getUseNearest:boolean;
begin
  result:=false;
  if useStageInfo then
    result:=fusenearest;
end;

procedure cBaseBldAlg.setopts(opts:cbaseopts);
begin
  opts.useStageInfo:=useStageInfo;
  opts.useNearest:=useNearest;
  opts.useCorr:=useCorr;
  opts.useBladesPos:=useBladesPos;
  opts.callBadTicksProc:=callBadTicksProc;
  opts.offset:=offset;
  opts.stage:=stage;
  opts.tags:=tags;
  opts.needevalBladeCount:=needevalBladeCount;
  // ������������ ������� ���������� ��������� �� �������
  // ��� �������� ����������� ���������
  opts.useDist:=useDist;
  opts.alg:=self;
end;

procedure cBaseBldAlg.getOpts(opts:cBaseOpts);
var
  uts:cUTSSensor;
begin
  if opts.taho<>nil then
    eng:=opts.taho.eng;
  if doubleprocessing then
  begin
    goodTurnChainCapacity:=10000;
    goodTurnChainLength:=0;
    SetLength(GoodTurnsChain,goodTurnChainCapacity);
    GoodTurnsChain[0].x:=0;
    GoodTurnsChain[0].x:=0;
  end;
  needevalBladeCount:=opts.needevalBladeCount;
  useStageInfo:=opts.useStageInfo;
  useNearest:=opts.useNearest;
  useCorr:=opts.useCorr;
  useBladesPos:=opts.useBladesPos;
  callBadTicksProc:=opts.callBadTicksProc;
  offset:=opts.offset;
  stage:=opts.stage;
  if stage<>nil then
  begin
    bladecount:=stage.BladeCount;
  end;
  // ������������ ������� ���������� ��������� �� �������
  // ��� �������� ����������� ���������
  useDist:=opts.useDist;
  if curtaho=nil then
    curtaho:=opts.taho;
  createTags;
  setTagsBuffers(opts);

  path:=opts.path;
  testname:=opts.testname;
  dsc:=opts.dsc;
  SampleRate:=opts.SampleRate;
  SaveSignals:=opts.SaveSignals;
  portionsize:=opts.portionSize;
  dZ:=opts.dZ;
  b_3d:=opts.b_3D;

  useuts:=opts.useUTS;
  if useuts then
  begin
    uts:=cUTSSensor(eng.UTS);
    UTSTag:=uts.createtag;
  end;
end;

procedure cBaseBldAlg.setTagsBuffers(opts:cbaseopts);
var
  i:integer;
  tag:cbasetag;
begin
  for i:=0 to tags.Count - 1 do
  begin
    tag:=cbasetag(tags.getobj(i));
    tag.source:=self;
  end;
end;

function cBaseBldAlg.CreateOpts:cbaseopts;
var
  o:cbaseopts;
begin
  o:=cbaseopts.create;
  setopts(o);
  result:=o;
end;

procedure cBaseBldAlg.SetTimeBeginEnd(time:tpoint);
begin
  beginInd:=time.X;
  if (curtaho.tickscount-2)>=time.Y then
  begin
    endind:=time.Y
  end
  else
  begin
    endind:=curtaho.tickscount-2;
  end;
end;

procedure cBaseBldAlg.prepare;
begin
  BeforeCommonSensorProc;
end;

procedure cBaseBldAlg.GetNewData(turncount:integer);
var
  tag:cbaseTag;
  i:integer;
begin
  for I := 0 to tags.count - 1 do
  begin
    tag:=cbasetag(tags.getobj(i));
    if tag.active then
    begin
      if tag is carraytag then
      begin
        carraytag(tag).used:=0;
      end;
    end;
  end;
  if DoubleProcessing then
  begin
    for I := 0 to sensorsList.Count - 1 do
    begin
      setlength(sstruct[i].sensorind, turncount+1);
    end;
  end;
end;

procedure cBaseBldAlg.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
var
  str:string;
  s:csensor;
  scount, aCount,i,j,activeTagCount:integer;
  tag:cbasetag;
  tagnode:txmlnode;
  a:calarm;
  task:ctask;
begin
  inherited;
  useStageInfo:=xmlNode.ReadAttributeBool('useStageInfo');
  useNearest:=xmlNode.ReadAttributeBool('useNearest');
  useDist:=xmlNode.ReadAttributeBool('useDist');
  useCorr:=xmlNode.ReadAttributeBool('useCorr');
  useBladesPos:=xmlNode.ReadAttributeBool('useBladesPos');
  offset:=xmlNode.ReadAttributeFloat('offset');
  // ������ ������
  str:=xmlNode.ReadAttributeString('TaskName');
  task:=ctask(cbldtimeproc(cAlgMng(mng).getTProc).TaskList.getobj(str));
  if task<>nil then
    task.Thread.addAlg(self);
  // ��� �������
  str:=xmlNode.ReadAttributeString('StageName');
  stage:=cstage(eng.getobj(str));
  if stage<>nil then
  begin
    bladecount:=stage.bladecount;
    createTags;
    setTagsBuffers(nil);
  end
  else
    bladecount:=0;
  // ����� ��������
  scount:=xmlNode.ReadAttributeInteger('SensorsCount');
  for I := 0 to scount - 1 do
  begin
    str:='s_'+inttostr(i);
    str:=xmlNode.ReadAttributeString(str);
    s:=csensor(eng.getobj(str));
    sensorsList.add(s);
  end;
  str:=xmlNode.ReadAttributeString('taho');
  curtaho:=csensor(eng.getobj(str));
  // ����� �������� ����
  activeTagCount:=xmlNode.ReadAttributeInteger('activeTagCount');
  for I := 0 to activeTagCount - 1 do
  begin
    tagnode:=xmlNode.Nodes[i];
    str:=tagnode.Name;
    tag:=cbasetag(tags.getobj(str));
    if tag<>nil then
    begin
      // ���������� � false �� ������ ���� ��� ���������� ������� ��� �������� ���������
      tag.active:=false;
      tag.active:=true;
      tag.opts:=tagnode.ReadAttributeString('DrawObj');
      // ��������� �����
      aCount:=tagnode.ReadAttributeInteger('AlarmCount');
      for j:=0 to aCount-1 do
      begin
        a:=calarmmng(cbldtimeproc(eng.timeProc).alarms).createalarm;
        a.name:=tagnode.ReadAttributeString('AlarmName');
        a.dsc:=tagnode.ReadAttributeString('Desc',a.dsc);
        a.LoAlarm:=tagnode.ReadAttributeBool('LoAlarm',a.LoAlarm);
        a.threshold:=tagnode.ReadAttributeFloat('Thereshold',a.threshold);
        a.Gisterezis:=tagnode.ReadAttributeInteger('Gisterezis',a.Gisterezis);
        tag.addalarm(a);
      end;
    end;
  end;
end;

procedure cBaseBldAlg.SaveObjAttributes(xmlNode:txmlNode);
var
  str:string;
  i,j, activeTagCount:integer;
  tag:cbasetag;
  tagnode:txmlnode;
  a:calarm;
begin
  inherited;
  xmlNode.WriteAttributeBool('useStageInfo',useStageInfo);
  xmlNode.WriteAttributeBool('useNearest',useNearest);
  xmlNode.WriteAttributeBool('useDist',useDist);
  xmlNode.WriteAttributeBool('useCorr',useCorr);
  xmlNode.WriteAttributeBool('useBladesPos',useBladesPos);
  xmlNode.WriteAttributeFloat('offset',offset);
  if task<>nil then
    xmlNode.WriteAttributeString('TaskName',task.name)
  else
    xmlNode.WriteAttributeString('TaskName','');
  if task<>nil then
    xmlNode.WriteAttributeString('Task',task.name);
  if stage<>nil then
    xmlNode.WriteAttributeString('StageName',stage.name)
  else
    xmlNode.WriteAttributeString('StageName','');
  xmlNode.WriteAttributeFloat('SensorsCount',sensorsList.Count);
  for I := 0 to sensorsList.Count - 1 do
  begin
    str:='s_'+inttostr(i);
    xmlNode.WriteAttributeString(str,sensorslist.GetSensor(i).name);
  end;
  if curtaho<>nil then
    xmlNode.WriteAttributeString('taho',curtaho.name)
  else
    xmlNode.WriteAttributeString('taho','');
  // ����� �������� ����
  activeTagCount:=0;
  for I := 0 to tags.count - 1 do
  begin
    tag:=cbasetag(tags.getobj(i));
    if tag.active then
    begin
      tagnode:=xmlNode.NodeNew(tag.id);
      if tag.DrawObj<>nil then
        tagnode.WriteAttributeString('DrawObj',tag.DrawObj.name);
      inc(activeTagCount);
      // ��������� �����
      tagnode.WriteAttributeInteger('AlarmCount',tag.alarms.Count);
      for j:=0 to tag.alarms.Count-1 do
      begin
        a:=calarmslist(tag.alarms).GetAlarm(i);
        tagnode.WriteAttributeString('AlarmName',a.name);
        tagnode.WriteAttributeString('Desc',a.dsc);
        tagnode.WriteAttributeBool('LoAlarm',a.LoAlarm);
        tagnode.WriteAttributeFloat('Thereshold',a.threshold);
        tagnode.WriteAttributeInteger('Gisterezis',a.Gisterezis);
      end;
    end;
  end;
  xmlNode.WriteAttributeInteger('activeTagCount',activeTagCount);
end;

function cBaseBldAlg.status:integer;
begin
  if prepared then
    Result:=c_Ok
  else
    Result:=c_error;
end;

procedure cBaseBldAlg.OnEndTurn;
begin
  inc(validturns);
  if doubleprocessing then
  begin
    if ValidTurns=1 then
    begin
      inc(goodTurnChainLength);
    end
    else
    begin
      if turnind-GoodTurnsChain[goodTurnChainLength-1].Y=1 then
      begin
        inc(GoodTurnsChain[goodTurnChainLength-1].Y);
      end
      else
      begin
        inc(goodTurnChainLength);
        GoodTurnsChain[goodTurnChainLength-1].x:=turnind;
        GoodTurnsChain[goodTurnChainLength-1].y:=turnind;
      end;
    end;
  end;
end;

procedure cBaseBldAlg.SecondProcess;
begin

end;

procedure cBaseBldAlg.SaveMera;
var
  list:tStringList;
  s:cTagSignal;
  // ������� �� �������� � ��
  k1:single;
  i:integer;
  tag:cbasetag;
  lpath,lname:string;
  merafile:cmerafile;
  opts:tmeraopts;
begin
  k1:=cstage(stage).getscale;
  list:=tstringlist.Create;
  for i:=0 to tags.count-1 do
  begin
    tag:=cbaseTag(tags.getobj(i));
    if tag is c2VectorTag then
    begin
      if tag.active then
      begin
        s:=cTagSignal.Create;
        s.obj:=tag;
        s.k1:=k1;
        s.k0:=0;
        s.yUnits:='��';
        s.xUnits:='���';
        // ������ ���������� ������ mera �����
        list.AddObject(tag.name, s);
      end;
    end;
  end;
  opts.TestName:=TestName;
  opts.TestDsc:=Dsc;
  opts.freq:=samplerate;
  for I := 0 to list.Count - 1 do
  begin
    s:=cTagSignal(list.Objects[i]);
    s.freqX:=opts.freq;
    if opts.freq<1 then
    begin
      s.WriteXY:=true;
    end;
    s.b_3d:=b_3d;
    s.dz:=dz;
    s.portionsize:=portionsize;
  end;
  lpath:=extractfiledir(path);
  lname:=extractfileName(path);
  // ������� � ������ ���
  if UTSTag<>nil then
  begin
    s:=cTagSignal.Create;
    s.obj:=UTSTag;
    s.k1:=1;
    s.k0:=0;
    s.WriteXY:=true;
    s.yUnits:='���.';
    s.xUnits:='���.';
  end
  else
    s:=nil;
  merafile:=cmerafile.create(path,lpath, list, opts ,s);
  merafile.save;
  merafile.DestroySignals;
  merafile.Destroy;
  list.Destroy;
end;

procedure cBaseBldAlg.Preparetosave(tag:cbasetag);
begin

end;

procedure cBaseBldAlg.AfterTurnProc;
begin

end;

end.
