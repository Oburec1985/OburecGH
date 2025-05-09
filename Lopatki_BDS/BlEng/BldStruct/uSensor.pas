unit uSensor;

interface
uses uBaseObj, controls, uBldObj, classes, uTickData, uBaseObjTypes, uChan,
     uErrorProc, nativexml, ucommonmath, mathfunction, uBldGlobalStrings;

type

  cSensor = class(cBldObj)
  protected
    fchan:smallint;
    // ���������� �������: ����� ������� ������� ���� ����������, ���� ������ �������
    // �� ������� �������
    skipBlades:integer;
    InitSkipBlades:boolean;
  public
    // ��������� ������ ������ ������ ��������
    hint:string;
    pairs:cbaseobjlist;
    // ���������� �� ������� �������� � �������. �������� ��� ����� �����������
    firstBladeOffset:single;
    // �������� ������������ ������� ������� � ��������
    pos:single;
    // ��� �������
    sensortype:integer;
  public
    constructor create;override;
    destructor destroy;override;
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
  public
    function getsensorstring:string;
    procedure setsensorstring(s:string);
    function tickscount:integer;
    function getTurbine:cbldobj;
    function pairsCount:integer;
    function getpair(name:string):cbldobj;overload;
    function getpair(i:integer):cbldobj;overload;
    // ��������� ������ �� ���� ������� ���������� ������ ������
    procedure AddPairRef(pair:cbldobj);
    // ������� ������ �� ���� ������� ���������� ������ ������.
    procedure DelPairRef(pair:cbldobj);
    function EvalSkipBlades:integer;
    // ��������� ��������� �������
    function EvalPosition:single;
  private
  protected
    function GetImageIndex:integer;override;
    function getstage:cbldobj;
    procedure setstage(obj:cbldobj);
    procedure unlincMng;override;
    procedure setName(newname:string);override;
    function GetStageName:string;
    procedure SetStageName(str:string);
    procedure SetPairName(str:string);
    function GetPairName:string;
    // ������ ��������� ������ (�������� � ������� cBldEng)
    function getchannumber:smallint;
    procedure setchannumber(i:smallint);
    function getchan:cchan;
    function GetMainParent:cbaseobj;override;
    procedure SetMainParent(p:cbaseobj);override;
    procedure setskipblades(skip:integer);
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
  public
    function getTStart:single;
    function getTEnd:single;
    function mainParentClassName:string;override;
    property stagename:string read getStageName write SetStageName;
    property pairname:string read getpairname write setpairname;
    property channumber:smallint read getchannumber write setchannumber;
    property chan:cchan read getChan;
    property turbine:cbldobj read getturbine;
    property stage:cbldobj read getstage write setstage;
    property sensorString:string read getsensorstring write setsensorstring;
    property skipBlade:integer read skipblades write setskipblades;
  end;


  cSensorList = class(cBldObj)
  public
    constructor create;override;
    // �������� ��� ������ ��� ������� ����� �������� � �������� �������
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
  end;
  // ����� ������ ����� �� t
  function GetT1(s:csensor;t:single):integer;

  function SensorStringToInt(str:string):integer;
  // ����� ������ �� ������ ������ � ������ (���������� �������� ������)
  function findSensorByChunNumber(obj:cbldObj; chan:integer):csensor;

implementation
uses ustage, upair, ubldmath, ubldeng;

// ����� ������ ����� �� t
function GetT1(s:csensor;t:single):integer;
var
  tick:stickdata;
  p:pointer;
  chan:cchan;
begin
  if s.tickscount<>0 then
  begin
    tick:=SecToTick(t);
    chan:=s.chan;
    p:=chan.ticks.GetLow(@tick,result);
    if p=nil then
    begin
      result:=0;
    end;
  end
  else
    result:=-1;
end;



constructor cSensorList.create;
begin
  inherited;
  helper:=true;
  imageindex:=c_sensor_img;
end;

function cSensorList.SupportedChildClass(objtype:integer):boolean;
begin
  result:=true;
  case objtype of
    c_Sensor:;
  else
    result:=false;
  end;
end;

function cSensorList.SupportedChildClass(obj:cbaseobj):boolean;
begin
  if obj is cSensor then
    result:=true
  else
    result:=false;
end;

function cSensorList.SupportedChildClass(classname:string):boolean;
var strlist:tstringlist;
    i:integer;
begin
  strlist:=tStringList.Create;
  strlist.Sorted:=true;
  strlist.Add(v_sensor);
  result:=strlist.find(classname,i);
end;


function SensorStringToInt(str:string):integer;
begin
  result:=-1;
  if str=v_Root then
    result:=c_Root;
  if str=v_Edge then
    result:=c_Edge;
  if str=v_Rot then
    result:=c_Rot;
  if str=v_UTS then
    result:=c_UTS;
end;

constructor cSensor.create;
begin
  inherited;
  firstBladeOffset:=-1;
  fchan:=-1;
  helper:=false;
  objtype:=c_sensor;
  imageindex:=c_sensor_img;
  InitSkipBlades:=false;
  skipblades:=0;
  pairs:=cbaseobjlist.create;
  pairs.destroydata:=false;
end;

destructor cSensor.destroy;
var
  pair:cpair;
begin
  while pairs.count<>0 do
  begin
    pair:=cpair(getpair(0));
    delpairref(pair);
  end;
  pairs.destroy;
  pairs:=nil;
  inherited;
end;

function cSensor.getsensorstring:string;
begin
  case sensortype of
    c_root: result:=v_Root;
    c_edge: result:=v_Edge;
    c_rot: result:=v_Rot;
    c_UTS: result:=v_UTS;
  end;
end;

procedure cSensor.setsensorstring(s:string);
begin
  sensortype:=SensorStringToInt(sensorString);
  if sensortype=-1 then
    errorSensor_ErrorType(self,eng.flags);
end;

function cSensor.GetStageName:string;
begin
  if stage<>nil then
  begin
    result:=stage.name;
    exit;
  end;
  result:='';
end;

procedure cSensor.SetStageName(str:string);
begin
  parentname:=str;
end;

procedure cSensor.SetPairName(str:string);
var
  index:integer;
  pair:cbldobj;
begin
  if not pairs.Find(str,index) then
  begin
    if eng<>nil then
    begin
      pair:=cbldobj(eng.getobj(str));
      if pair is cpair then
      begin
        if pair<>nil then
          cpair(pair).AddSensor(self);
      end;
    end;
  end;
end;

function cSensor.GetPairName:string;
var pair:cbldobj;
begin
  pair:=getpair(0);
  if pair<>nil then
  begin
    result:=pair.name;
  end
  else
    result:='';
end;

function cSensor.tickscount:integer;
begin
  result:=0;
  if chan<>nil then
  begin
    if chan.ticks<>nil then
    begin
      result:=chan.ticks.count;
    end;
  end
end;

function cSensor.SupportedChildClass(obj:cbaseobj):boolean;
begin
  result:=false;
end;

function cSensor.SupportedChildClass(classname:string):boolean;
begin
  result:=false;
end;

function cSensor.SupportedChildClass(objtype:integer):boolean;
begin
  result:=false;
end;

function findSensorByChunNumber(obj:cbldObj;chan:integer):csensor;
var
  i, childcount:integer;
  child:cbldobj;
begin
  if obj is csensor then
  begin
    if csensor(obj).ChanNumber=chan then
    begin
      result:=csensor(obj);
      exit;
    end;
  end;
  if obj.ChildCount=0 then
  begin
    result:=nil;
    exit;
  end;
  for I := 0 to obj.ChildCount - 1 do
  begin
    child:=cbldobj(obj.getChild(i));
    result:=findSensorByChunNumber(child,chan);
    if result<>nil then
      exit;
  end;
end;

function cSensor.getchannumber:smallint;
begin
  result:=fchan;
end;

procedure cSensor.setchannumber(i:smallint);
var lchan:cchan;
begin
  if eng<>nil then
  begin
    if chan<>nil then
    begin
      chan.chan:=i;
    end
    else
      eng.Addchan(i);
  end;
  fchan:=i;
end;

function cSensor.getchan:cchan;
begin
  result:=cchan(eng.findchan(fchan));
end;

function cSensor.getstage:cbldobj;
begin
  if parent<>nil then
  begin
    if parent.parent<>nil then
    begin
      result:=cbldobj(parent.parent);
      exit;
    end;
  end;
  result:=nil;
end;

procedure cSensor.setstage(obj:cbldobj);
var
  i:integer;
  p:cpair;
begin
  if obj<>stage then
  begin
    for I := 0 to pairscount - 1 do
    begin
      p:=cpair(getpair(i));
      if p.stage<>obj then
      begin
        p.removesensor(self);
        errorSensorPair_notSameStageProc(self, p, c_showmessage);
      end;
    end;
    if obj<>nil then
      cstage(obj).Addsensor(self);
  end;
end;

function cSensor.getTurbine:cbldobj;
begin
  if parent<>nil then
  begin
    if parent.parent<>nil then
    begin
      if parent.parent.parent<>nil then
      begin
        result:=cbldobj(parent.parent.parent);
        exit;
      end;
    end;
  end;
  result:=nil;
end;

procedure csensor.setName(newname:string);
var
  i:integer;
  pair:cpair;
begin
  for I := 0 to pairs.Count - 1 do
  begin
    pair:=cpair(pairs.getobj(i));
    pair.childrens.RemoveObj(self);
  end;
  inherited;
  for I := 0 to pairs.Count - 1 do
  begin
    pair:=cpair(pairs.getobj(i));
    pair.childrens.addobj(self);
  end;
end;

procedure csensor.AddpairRef(pair:cbldobj);
begin
  pairs.addobj(pair);
end;

procedure csensor.DelpairRef(pair:cbldobj);
begin
  pairs.removeobj(pair);
  cpair(pair).sensors.removeobj(self);
end;

function csensor.pairsCount:integer;
begin
  if pairs<>nil then
  begin
    result:=pairs.count;
  end
  else
    result:=0;
end;

function csensor.getpair(name:string):cbldobj;
begin
  result:=cbldobj(pairs.getobj(name));
end;

function csensor.getpair(i:integer):cbldobj;
begin
  result:=cbldobj(pairs.getobj(i));
end;

procedure csensor.unlincMng;
var
  i:integer;
  p:cpair;
begin
  inherited;
  while pairsCount<>0 do
  begin
    p:=cpair(getpair(0));
    delpairref(p);
  end;
end;

function csensor.GetMainParent:cbaseobj;
begin
  result:=stage;
end;

procedure csensor.SetMainParent(p:cbaseobj);
begin
  stage:=cbldobj(p);
end;

function getSkipBlade(blades:array of single; sensorpos:single):integer;
var
  I, bladecount: Integer;
begin
  result:=0;
  bladecount:=length(blades);
  for I := 1 to bladecount - 1 do
  begin
    if blades[i]>sensorpos then
    begin
      result:=i-1;
      exit;
    end;
  end;
end;

function csensor.EvalSkipBlades:integer;
begin
  // �������� ��������� ����� ������������ ���������, ����� ������ ������� ��
  // ������� ������� � �������. ������� ������� - �� ������� ��������� ������ ������� �����
  // ������ ������� (����������� ���� ��������)
  result:=0;
  if stage<>nil then
  begin
    // ����������� �������� �� ������������� �������� ��� ��������� �������
    if cstage(stage).Shape<>nil then
    begin
      if GetOffsetsInit(cstage(stage).Shape.blades) then
        skipBlades:=getSkipBlade(cstage(stage).Shape.blades,pos)
      else
      if GetOffsetsInit(cstage(stage).Shape.offset) then
      begin
        cstage(stage).Shape.PrepareBladePos(cstage(stage).Shape.offset);
        result:=getSkipBlade(cstage(stage).Shape.blades,pos);
        if not InitSkipBlades then
        begin
          skipblade:=result;
        end;
      end
    end;
  end;
  result:=skipblades;
end;

procedure csensor.setskipblades(skip:integer);
begin
  skipblades:=skip;
  InitSkipBlades:=true;
end;

function csensor.mainParentClassName:string;
begin
  result:='cStage';
end;

function csensor.EvalPosition:single;
var
  blades:array of single;
begin
  if GetOffsetsInit(cstage(stage).Shape.blades) then
  begin
    result:=cstage(stage).Shape.blades[skipblades]+firstBladeOffset;
  end
  else
  begin
    setlength(blades,cstage(stage).BladeCount);
    PrepareBlades(blades,cstage(stage).shape.offset);
    result:=cstage(stage).Shape.blades[skipblades]+firstBladeOffset;
  end;
end;

procedure csensor.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
begin
  inherited;
  // ����� ������
  channumber:=xmlNode.ReadAttributeInteger('Chan');
  // ������� �������
  pos:=xmlNode.ReadAttributeFloat('Position');
  // ��� �������
  sensortype:=xmlNode.ReadAttributeInteger('SensorType');
  // ������� ������� �� �������
  skipBlade:=xmlNode.ReadAttributeInteger('SkipBlades');
  // ��������� �� ������� �������� � �������
  firstBladeOffset:=xmlNode.ReadAttributeFloat('FirstBladeOffset');
end;

procedure csensor.SaveObjAttributes(xmlNode:txmlNode);
begin
  inherited;
  // ����� ������
  xmlNode.WriteAttributeInteger('Chan',channumber);
  // ������� �������
  xmlNode.WriteAttributeFloat('Position',pos);
  // ��� �������
  xmlNode.WriteAttributeInteger('SensorType',sensortype);
  // ������� ������� �� �������
  xmlNode.WriteAttributeInteger('SkipBlades',skipBlade);
  // ��������� �� ������� �������� � �������
  xmlNode.WriteAttributeFloat('FirstBladeOffset',firstBladeOffset);
end;

function csensor.getTStart:single;
begin
  if tickscount<>0 then
    result:=TickToSec(chan.ticks.gettick(0))
  else
    result:=0;
end;

function csensor.getTEnd:single;
begin
  if tickscount<>0 then
    result:=TickToSec(chan.ticks.gettick(tickscount-1))
  else
    result:=0;
end;

function csensor.GetImageIndex:integer;
var
  lskip:integer;
  lstage:cstage;
  taho:csensor;
  divticks:double;
begin
  result:=inherited;
  hint:='';
  if stage<>nil then
  begin
    lstage:=cstage(stage);
    if lstage<>nil then
    begin
      taho:=lstage.gettaho;
      if taho=nil then
      begin
        if eng<>nil then
          taho:=csensor(eng.GetTaho(nil,false));
      end;
    end
    else
      taho:=nil;
    if (abs(pos-EvalPosition)>1) or (firstBladeOffset=-1) then
    begin
      RESULT:=21;
      hint:='�� ���������� ��������� �� �������';
      exit;
    end;
    if (stage=nil) then
    begin
      RESULT:=21;
      hint:='�� ��������� �������';
      exit;
    end;
    if (taho=nil) then
    begin
      RESULT:=21;
      hint:='�� �������� ���� ������';
      exit;
    end;
    divticks:=tickscount/taho.tickscount;
    if taho<>nil then
    begin
      if round(divticks)<>lstage.BladeCount then
      begin
        result:=21;
        hint:='����������� ���� ��������� � ����������� �� ��������� � ������ �������';
        exit;
      end;
    end;
  end;
end;


end.
