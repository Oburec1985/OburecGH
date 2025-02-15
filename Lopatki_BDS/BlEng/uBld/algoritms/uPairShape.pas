// ��� ���������� ������� ��������� ������ �������� ������� ����� ��������� ����, ��
// ��������� ��������� �� ��������� ��������. � ���������� ��������� �������� ����� �����
// �������� ���������� ����� ������� ���������
// ����������� ����� ����� (��������� � �����������)
unit uPairShape;

interface
uses
  classes, sysutils,Graphics,  controls, stdctrls, uchart, uaxis,
  uBldMath, uCommonMath, uErrorProc, uBldObj, uTickdata, usensor, uProgressDlg,
  ubldeng, uBaseBldAlg, ustage, uBaseObj, uturbina, PathUtils,
  usensorlist, uCommonTypes, uGistogram, uBldTypes, upair, uTag, NativeXML, upage;

type
  sArray = array of single;
  // ��� ����������� ���������� ��������� ��� �������� ������ ���� ���������� �������� �������
  // ���� ��������� ���������� ��� 0-� ������� � �������� ������� correctBlade
  cPairShapeOpts = class(cbaseopts)
    PointForEvalCount, // ������ ������
    skipblade // ���������� �������
    :integer;
    // ��������� ����� ����� �� �������� �������� ��������. ����� (��������-1)*0.9
    // ����� �������� �����, �.�. ����� ��� ��������� ��������
    EvalPointCount,
    // ���������� ��������� ����� ��������� � �� ���������
    ShowOffset:boolean;
    chart:cchart;
    pair:cpair;
    // ������ ��������� ��� ������ �������� ���� ������� (������ ������)
    evalMinMax,
    // ������ ���� �������� ��� ������ �������� ���� ������� (������ ������)
    evalAverage,
    // ������ ��������� ��� ������ �������� ���� ������� (������ ������)
    evalDisperse:boolean;
  public
    constructor create;override;
  end;
  // �������� ��������������� ������ �������� �� ����� ������
  cPairShape = class(cBaseBldAlg)
  protected
    pair:cpair;
    skipblade,
    // ������ �����
    PointForEvalCount:integer;
    // ������ ��������� ����� ��������� ���� ����������� �� �������
    // ������ n �������� ���������� ������ ��������� � ResArray
    BufArray: array of sArray;
    EvalPointCount,
    initBuffers:boolean;
    m_MTag, m_DTag, m_MinMaxMTag, m_MinMaxDTag:cBaseTag;
  public

  protected
    // ���������� ��� ������� ����������� ������� CommonSensorProc
    // ��� ���� ������ �������, ������ � ����� �������, ��������� � protected
    // ��������
    function TurnSensorProc(s:csensor):integer;override;
    procedure eraseMinMax;
    procedure CommonSensorProc(taho:csensor;sensors:cAlgSensorList);override;
    // ��������� ������. ���� ��������� ������ ���������� false
    function ProcessErrors(taho:csensor; sensors:cAlgSensorList):boolean;override;
    // ��������� ������ ��� ������� ���������
    procedure PrepareBuffers;
    procedure setTagsBuffers(data:cbaseopts);override;
    // ������� ����
    procedure createTags;override;
    // ��������� ��������� ��� i-� �������
    procedure evalDisperse(i:integer);
    // ��������� ����������� ��� i-� �������
    function EvalM(i:integer):single;
    procedure updateMinMax(blade:integer; v:single; MinMaxTag:c2VectorTag);
    function CorrectBlade(i:integer):boolean;
    procedure setopts(opts:cbaseopts);override;
    procedure InitOpts;override;
    procedure OnSetGistToTag(sender:tobject);
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    procedure getOpts(opts:cBaseOpts);override;
    function CreateOpts:cbaseopts;override;
    function AlgID:integer;override;
  end;

  procedure BuildPairShape(taho:csensor; sensors:cAlgSensorList; data:pointer);
  function PreparePairShape(taho:csensor; sensors:cAlgSensorList; data:pointer):cbasebldalg;

implementation
uses
  uPairShapeForm, umarkers;


function getGistogram(c:cchart):cGistogram;
var
  i:integer;
  obj:cbaseobj;
  axis:caxis;
begin
  axis:=cpage(c.activepage).activeAxis;
  axis.destroychildrens;
  for I := 0 to Axis.ChildCount - 1 do
  begin
    obj:=axis.getChild(i);
    if obj is cgistogram then
    begin
      result:=cgistogram(obj);
      exit;
    end;
  end;
  result:=axis.AddGistogram;
end;

constructor cPairShapeOpts.create;
begin
  inherited;
  skipblade:=0;
  EvalPointCount:=false;
  callBadTicksProc:=false;
  evalMinMax:=true;
  evalAverage:=true;
  evalDisperse:=true;
end;

function cPairShape.TurnSensorProc(s:csensor):integer;
var
  i:integer;
  v:single;
begin
  // ������������ ����� ��������� �������������� � ������ ������� �����������
  result:=0;
  if sstruct[cursensorind].validturns<PointForEvalCount then
  begin
    for I := sensorind to sensorind + stage.BladeCount - 1 do
    begin
      EvalTurnCluster(s,i);
      if CurSensorInd=0 then
        BufArray[sstruct[cursensorind].validturns][turnCluster.blade]:=turnCluster.p
      else
      begin
        v:=abs(turnCluster.p - BufArray[sstruct[cursensorind].validturns][turnCluster.blade]);
        if CorrectBlade(turnCluster.blade) then
          v:=360-v;
        BufArray[sstruct[cursensorind].validturns][turnCluster.blade]:=v;
      end;
    end;
  end;
end;

procedure cPairShape.PrepareBuffers;
var
  i:integer;
  ax:caxis;
begin
  if EvalPointCount then
  begin
    PointForEvalCount:=round((EndInd-beginInd-1)*0.9);
  end;
  if (not initBuffers) or (EvalPointCount) then
  begin
    if initbuffers then
    begin
      // ����������� �����
      for I := 0 to PointForEvalCount - 1 do
      begin
        setlength(bufarray[i],0);
      end;
      setlength(bufarray,0);
    end;
    // �������� ������
    setlength(bufArray,PointForEvalCount);
    for I := 0 to PointForEvalCount - 1 do
    begin
      setlength(bufarray[i],stage.BladeCount);
    end;
  end;
  //if gist<>nil then
  //  gist.clear;
  initBuffers:=true;
end;

procedure cPairShape.CommonSensorProc(taho:csensor;sensors:cAlgSensorList);
var
  i:integer;
  p:single;
  m:cmarkerlist;
  tag:cbasetag;
begin
  PrepareBuffers;
  if m_MinMaxMTag.active or m_MinMaxDTag.active then
    eraseMinMax;
  inherited;
  for I := 0 to stage.BladeCount - 1 do
  begin
    // ���������� ��� ���������� �� ������� ��������� �����������, ���������
    evalDisperse(i);
  end;
end;


function cPairShape.ProcessErrors(taho:csensor;sensors:cAlgsensorList):boolean;
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

// ��������� ����������� ��� i-� �������
function cPairShape.EvalM(i:integer):single;
var
  j:integer;
begin
  result:=0;
  for j := 0 to PointForEvalCount-1 do
  begin
    result:=result+bufarray[j][i];
  end;
  result:=result/PointForEvalCount;
end;

procedure cPairShape.evalDisperse(i:integer);
var
  j:integer;
  s:single;
begin
  if m_dtag.active then
    cvectortag(m_DTag).Value[i]:=0;
  if m_MTag.active then
    cvectortag(m_MTag).Value[i]:=0;
  // j - ����� �������
  for j := 0 to PointForEvalCount - 1 do
  begin
    if m_DTag.active then
    begin
      s:=(evalM(i) - bufarray[j][i]);
      s:=abs(s);
      cvectortag(m_DTag).Value[i]:=cvectortag(m_DTag).Value[i]+s;
      updateMinMax(i,s,c2vectortag(m_MinMaxDTag));
    end;
    if m_MTag.active then
    begin
      s:=bufarray[j][i];
      cvectortag(m_MTag).Value[i]:=s+cvectortag(m_MTag).Value[i];
      updateMinMax(i,s,c2vectortag(m_MinMaxMTag));
    end;
  end;
  if m_DTag.active then
  begin
    cvectortag(m_DTag).Value[i]:=cvectortag(m_DTag).Value[i]/PointForEvalCount;
  end;
  if m_MTag.active then
  begin
    cvectortag(m_MTag).Value[i]:=cvectortag(m_MTag).Value[i]/PointForEvalCount;
  end;
end;

procedure cPairShape.updateMinMax(blade:integer; v:single; MinMaxTag:c2VectorTag);
begin
  if m_DTag.active then
  begin
    if MinMaxTag.active then
    begin
      // ���������� min/ max
      if (MinMaxTag.Value[blade].x>v) or
         (MinMaxTag.Value[blade].x=-1) then
      begin
        MinMaxTag.setX(blade,v);
      end
      else
      begin
        if MinMaxTag.Value[blade].y<v then
          MinMaxTag.setY(blade,v)
      end;
    end;
  end;
end;

function cPairShape.CorrectBlade(i:integer):boolean;
var
  s1,s2:csensor;
begin
  s1:=sensorsList.GetSensor(0);
  s2:=sensorsList.GetSensor(1);
  result:=(s1.skipBlade<i) <> (s2.skipBlade<i);
end;

procedure  cPairShape.getopts(opts:cbaseopts);
begin
  inherited;
  EvalPointCount:=cPairShapeOpts(opts).EvalPointCount;
  initBuffers:=false;
  skipblade:=cPairShapeOpts(opts).skipblade;
  PointForEvalCount:=cpairshapeopts(opts).PointForEvalCount;
  m_Mtag.active:=cpairshapeopts(opts).evalAverage;
  m_Dtag.active:=cpairshapeopts(opts).evalDisperse;
  m_MinMaxMtag.active:=cpairshapeopts(opts).evalMinMax and m_Mtag.active;
  m_MinMaxDtag.active:=cpairshapeopts(opts).evalMinMax and m_Dtag.active;
end;

procedure cPairShape.setopts(opts:cbaseopts);
begin
  inherited setopts(opts);
  cpairshapeopts(opts).skipblade:=skipblade;
  cpairshapeopts(opts).PointForEvalCount:=PointForEvalCount;
  cpairshapeopts(opts).EvalPointCount:=EvalPointCount;  
end;

function cPairShape.CreateOpts:cbaseopts;
begin
  result:=cpairshapeopts.create;
  cpairshapeopts(result).EvalPointCount:=EvalPointCount;
  cpairshapeopts(result).ShowOffset:=true;
  if tags.count=0 then
  begin
    cpairshapeopts(result).evalMinMax:=false;
    cpairshapeopts(result).evalAverage:=false;
    cpairshapeopts(result).evalDisperse:=false;
  end
  else
  begin
    cpairshapeopts(result).evalMinMax:=(m_minmaxMTag.active) or (m_minmaxDTag.active);
    cpairshapeopts(result).evalAverage:=m_MTag.active;
    cpairshapeopts(result).evalDisperse:=m_DTag.active;
  end;
  setopts(result);
end;

function cPairShape.AlgID:integer;
begin
  result:=c_pairShape
end;

procedure cPairShape.InitOpts;
begin
  inherited;
  LinkedSensors:=true;
end;

procedure cPairShape.eraseMinMax;
var
  i:integer;
begin
  for I := 0 to stage.BladeCount - 1 do
  begin
    c2vectortag(m_MinMaxMTag).value[i]:=p2(-1,-1);
  end;
  for I := 0 to stage.BladeCount - 1 do
  begin
    c2vectortag(m_MinMaxDTag).value[i]:=p2(-1,-1);
  end;
end;

procedure cPairShape.setTagsBuffers(data:cbaseopts);
begin
  inherited;
  if stage<>nil then
  begin
    cBaseTag(m_MTag).length:=stage.BladeCount;
    cBaseTag(m_DTag).length:=stage.BladeCount;
    m_MinMaxMTag.length:=stage.BladeCount;
    m_MinMaxDTag.length:=stage.BladeCount;
    eraseMinMax;
  end;
end;

procedure cPairShape.OnSetGistToTag(sender:tobject);
begin
  if sender is cGistogram then
  begin
    if stage<>nil then
      cgistogram(sender).width:=180/stage.BladeCount;
  end;
end;

procedure cPairShape.createTags;
var
  tag:cBaseTag;
  i:integer;
begin
  if tags.Count<>0 then exit;
  tag:=cVectorTag.create;
  tag.active:=true;
  tag.name:='MArray';
  tag.dsc:='������ ���. �������� ��������� ����� ���������';
  tags.addobj(tag);
  tag.OnSetDrawObj:=OnSetGistToTag;
  m_MTag:=tag;

  tag:=c2VectorTag.create;
  tag.active:=true;
  tag.name:='MinMaxMArray';
  tag.dsc:='������ ���./����. ��������� ����� ���������';
  tags.AddObj(tag);
  m_minmaxMTag:=tag;

  tag:=cVectorTag.create;
  tag.active:=true;
  tag.name:='DArray';
  tag.dsc:='������ ��������� ��������� ����� ���������';
  tags.AddObj(tag);
  tag.OnSetDrawObj:=OnSetGistToTag;
  m_DTag:=tag;

  tag:=c2VectorTag.create;
  tag.active:=true;  
  tag.name:='MinMaxDArray';
  tag.dsc:='������ ���./����. ��������� ��������� ����� ���������';
  tags.AddObj(tag);
  m_minmaxDTag:=tag;

  for i := 0 to tags.Count - 1 do
  begin
    tag:=cBaseTag(tags.getobj(i));
    // ��������� ������� ������ ��������� �����
    tag.blocked:=true;
  end;
end;

procedure cPairShape.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
begin
  inherited;
  PointForEvalCount:=xmlNode.ReadAttributeInteger('PointForEvalCount');
  EvalPointCount:=xmlNode.ReadAttributeBool('EvalPointCount');
  skipblade:=xmlNode.ReadAttributeInteger('skipblade');
end;

procedure cPairShape.SaveObjAttributes(xmlNode:txmlNode);
begin
  inherited;
  xmlNode.WriteAttributeInteger('PointForEvalCount',PointForEvalCount);
  xmlNode.WriteAttributeInteger('skipblade',skipblade);
  xmlNode.WriteAttributeBool('EvalPointCount', EvalPointCount);
end;

procedure BuildPairShape(taho:csensor; sensors:cAlgSensorList; data:pointer);
var
  alg: cPairShape;
  PairShapeForm: TPairShapeForm;
  opts:cPairShapeOpts;
  slist:cAlgSensorList;
  i:integer;
  p:cpair;
  gist:cgistogram;
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
  opts:=cPairShapeOpts.Create;
  opts.chart:=cchart(data);
  opts.useBladesPos:=true;
  opts.evalMinMax:=true;
  opts.evalAverage:=true;
  opts.evalDisperse:=true;
  alg:=cPairShape.create;
  opts.tags:=alg.tags;
  PairShapeForm:=TPairShapeForm.Create(nil);
  if PairShapeForm.ShowModal(taho,slist,opts)=mrok then
  begin
    alg.getOpts(opts);
    gist:=getGistogram(cPairShapeOpts(opts).chart);
    gist.clear;
    gist.width:=180/opts.stage.BladeCount;
    if opts.ShowOffset then
    begin
      if alg.m_MTag.DrawObj=nil then
        alg.m_MTag.DrawObj:=gist;
      if opts.evalMinMax then
        alg.m_MinMaxMTag.DrawObj:=gist.getMarkers;
    end
    else
    begin
      if alg.m_MTag.DrawObj=nil then
        alg.m_DTag.DrawObj:=gist;
      if opts.evalMinMax then
        alg.m_MinMaxDTag.DrawObj:=gist.getMarkers;
    end;
    alg.apply(taho,slist,opts);
  end;
  alg.Destroy;
  PairShapeForm.Destroy;
  opts.Destroy;
  slist.destroy;
end;

function PreparePairShape(taho:csensor; sensors:cAlgSensorList; data:pointer):cbasebldalg;
var
  alg: cPairShape;
  PairShapeForm: TPairShapeForm;
  opts:cPairShapeOpts;
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
  opts:=cPairShapeOpts.Create;
  opts.chart:=cchart(data);
  opts.useBladesPos:=true;
  alg:=cPairShape.create;
  alg.PointForEvalCount:=opts.PointForEvalCount;
  alg.skipblade:=opts.skipblade;
  //alg.apply(taho,slist,opts);
  result:=alg;
end;

end.
