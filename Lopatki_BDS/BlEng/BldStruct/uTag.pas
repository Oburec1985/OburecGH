unit uTag;

interface
uses
  sysutils, udrawobj, classes, uBaseObj, uBaseObjMng, uPoint, uCommonTypes,
  uMyMath, uVectorList, uEventList, ubldEngEventTypes, windows,
  NativeXML, uBldGlobalStrings;

type
  cBaseTag = class(cBaseObj)
  protected
    // �������� �������� ������ ���
    fsource:tobject;
    // ������ � ������� ���������� ���
    fdrawobj:cdrawobj;
    // �������
    factive:boolean;
    // ��������
    fdsc:string;
    // ����������� ������ ������ ������
    cs:TRTLCriticalSection;
  public
    offset:single;
    alarms:cFloatVectorList;
    OnSetDrawObj:tNotifyevent;
    OnSetActive:tNotifyevent;
    // ������ ������������� ���� ������ ���������. �����
    // ����� �������������� � ������ ������
    id:string;
    // �������������� ��������� �������� ��� �������� �� xml
    // ��������� ��������� �������������� ������
    opts:string;
    // ��������/ ��������� ������ ������
    LogData:boolean;
  protected
    procedure setname(name:string);override;
    function getLen:integer;virtual;
    procedure SetLen(i:integer);virtual;
    Procedure setDrawObj(obj:cdrawobj);virtual;
    procedure setactive(b:boolean);virtual;
    procedure setDsc(str:string);
    function getDsc:string;
    // ��������� ������� �������� ����
    function CheckAlarm:boolean;virtual;
    Procedure OnAlarm;
  // ���������
  public
    procedure UpdateDrawObj;
    // ������ ����� ������
    procedure UpdateValue;
    function  AlarmCount:integer;
    procedure addalarm(a:cbaseobj);
    Function TypeString:String;override;
    Procedure setSource(src:tobject);virtual;
    constructor create;override;
    destructor destroy;override;
  // ��������
  public
    property source:tobject read fsource write setSource;
    property dsc:string read fdsc write setdsc;
    property active:boolean read factive write setactive;
    property DrawObj:cdrawObj read fdrawobj write setdrawobj;
    property length:integer read getLen write SetLen;
  end;

  cBaseScalarTag = class(cBaseTag)

  end;

  cScalarTag = class(cBaseScalarTag)
  protected
    fValue:single;
  protected
    function getValue:single;
    procedure SetValue(v:single);
    // ��������� ������� �������� ����
    function CheckAlarm:boolean;override;
  public
    Function TypeString:String;override;
  public
    property Value:single read getValue write SetValue;
  end;

  c2ScalarTag = class(cBaseScalarTag)
  protected
    fValue:point2;
  protected
    function getValue:point2;
    procedure SetValue(v:point2);
    function CheckAlarm:boolean;override;
  public
    Function TypeString:String;override;
  public
    property Value:point2 read getValue write SetValue;
  end;

  cArrayTag = class(cBaseTag)
  public
    // ����� ��������������������� �����
    used:integer;
    initMinMax:Boolean;
  protected
    constructor create;override;
    procedure updateUseditems;
  public
    // �������� �����
    procedure clear;
  end;

  cVectorTag = class(cArrayTag)
  public
    dx:single;
    fValue:array of single;
    MinMax:point2;
  protected
    function getValue(i:integer):single;
    procedure SetValue(index:integer;v:single);
    function getLen:integer;override;
    procedure SetLen(i:integer);override;
    function CheckAlarm:boolean;override;
  public
    Function TypeString:String;override;
    procedure Add(v:single);
    Function M:single;
    Function D:single;
  public
    destructor destroy;override;
    constructor create;override;
    property Value[index:integer]:single read getValue write SetValue;
  end;

  c2VectorTag = class(cArrayTag)
  public
    fValue:array of point2;
    XMinMax:point2;
    YMinMax:point2;
  protected
    function getValue(i:integer):point2;
    procedure SetValue(index:integer;v:point2);
    function getLen:integer;override;
    procedure SetLen(i:integer);override;
    function CheckAlarm:boolean;override;
  public
    procedure SetX(i:integer;x:single);
    procedure SetY(i:integer;y:single);
  public
    // ��������� �������� ������ ���� ������ ������ ������������ �� X
    function getY(x:single):single;
    Function TypeString:String;override;
    procedure Add(v:point2);
    function M:single;
    Function D:single;
    function Count:integer;
  public
    property Value[index:integer]:point2 read getValue write SetValue;
    property length:integer read getLen write SetLen;
  end;

  c2dVectorTag = class(cArrayTag)
  public
    fValue:array of point2d;
    XMinMax:point2d;
    YMinMax:point2d;
  protected
    function getValue(i:integer):point2d;
    procedure SetValue(index:integer;v:point2d);
    function getLen:integer;override;
    procedure SetLen(i:integer);override;
    function CheckAlarm:boolean;override;
  public
    procedure SetX(i:integer;x:double);
    procedure SetY(i:integer;y:double);
  public
    // ��������� �������� ������ ���� ������ ������ ������������ �� X
    function getY(x:double):double;
    Function TypeString:String;override;
    procedure Add(v:point2d);
    function M:double;
    Function D:double;
    function Count:integer;
  public
    property Value[index:integer]:point2d read getValue write SetValue;
    property length:integer read getLen write SetLen;
  end;


  cTagMng = class(cBaseObjMng)
  public
    // ���� � ��������� ������ �� �����
    TagsFolder:string;
    // ��������/��������� ������
    logtags:boolean;
  protected
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    procedure XMLSaveMngAttributes(node:txmlnode);override;
    procedure XMLlOADMngAttributes(node:txmlnode);override;
  private
  public
    constructor create;override;
    destructor destroy;override;
    function gettag(i:integer):cbasetag;overload;
    function gettag(name:string):cbasetag;overload;
    function createTag(ID:integer):cBaseTag;
    procedure AddToXML(fname:string; sectionName:string);override;
    function LoadFromXML(fname:string; sectionName:string):boolean;override;
  end;

  const
    // ������������� ����� �����
    c_ScalarTag = 1;
    c_VectorTag = 2;

implementation
uses
  uTagUtils, uAlarms;

constructor cBaseTag.create;
begin
  inherited;
  alarms:=calarmslist.create;
  drawobj:=nil;
end;

destructor cBaseTag.destroy;
begin
  alarms.destroy;
  inherited;
end;

procedure cBaseTag.setname(name:string);
begin
  inherited;
  if id='' then
    id:=name;
end;

procedure cBaseTag.addalarm(a:cbaseobj);
begin
  if a<>nil then
  begin
    calarmslist(alarms).AddAlarm(calarm(a));
    calarm(a).source:=self;
  end;
end;

function cBaseTag.CheckAlarm:boolean;
begin
  result:=false;
end;

Procedure cBaseTag.OnAlarm;
var
  e:ceventlist;
  a:calarm;
begin
  a:=calarmslist(alarms).getAlarm(0);
  e:=a.alarmMng.Events;
  e.CallAllEventsWithSender(e_OnTagAlarm, self);
end;

procedure cBaseTag.updateValue;
begin
  checkalarm;
end;

function  cBaseTag.AlarmCount:integer;
begin
  result:=alarms.Count;
end;

procedure cBaseTag.setDsc(str:string);
begin
  fdsc:=str;
end;

function cBaseTag.getDsc:string;
begin
  result:=fdsc;
end;

procedure cBaseTag.UpdateDrawObj;
begin
  if fdrawobj<>nil then
    TagToDrawObj(fdrawobj,self,nil);
end;

Procedure cBaseTag.setSource(src:tobject);
begin
  fsource:=src;
end;

Procedure cBaseTag.setDrawObj(obj:cdrawobj);
begin
  fdrawobj:=obj;
  if assigned(OnSetDrawObj) then
    OnSetDrawObj(obj);
end;

function cBaseTag.getLen:integer;
begin
  result:=1;
end;

procedure cBaseTag.SetLen(i:integer);
begin
end;

procedure cBaseTag.setactive(b:boolean);
begin
  if factive<>b then
  begin
    factive:=b;
    if assigned(OnSetActive) then
      OnSetActive(self);
  end;
end;

Function cBaseTag.TypeString:String;
begin
  result:=v_BaseTagDsc;
end;

function cScalarTag.getValue:single;
begin
  result:=fValue;
end;

procedure cScalarTag.SetValue(v:single);
begin
  fValue:=v;
end;

function cScalarTag.CheckAlarm:boolean;
var
  a:calarm;
  i:integer;
  b:boolean;
begin
  result:=false;
  if alarms.count=0 then exit;
  // �������� �� ���� ������� � ������� ��
  for I := 0 to alarms.Count - 1 do
  begin
    a:=calarm(alarms.getObj(i));
    b:=a.checkValue(value);
    if b then
      result:=b;
  end;
  if b then
    OnAlarm;
end;

Function c2ScalarTag.TypeString:String;
begin
  result:=v_2ScalarTAgDSCf;
end;

function c2ScalarTag.CheckAlarm:boolean;
var
  a:calarm;
  i:integer;
  b:boolean;
begin
  result:=false;
  if alarms.count=0 then exit;
  // �������� �� ���� ������� � ������� ��
  for I := 0 to alarms.Count - 1 do
  begin
    a:=calarm(alarms.getObj(i));
    b:=a.checkValue(value.y);
    if b then
      result:=b;
  end;
  if b then
    OnAlarm;
end;

function c2ScalarTag.getValue:point2;
begin
  result:=fValue;
end;

procedure c2ScalarTag.SetValue(v:point2);
begin
  fValue:=v;
end;


Function cScalarTag.TypeString:String;
begin
  result:=v_ScalarTAgDSCf;
end;

constructor cArrayTag.create;
begin
  inherited;
  clear;
end;

procedure cArrayTag.clear;
begin
  used:=0;
  initMinMax:=false;
end;

procedure cArrayTag.updateUseditems;
begin
  inc(used);
end;

constructor cVectorTag.create;
begin
  inherited;
end;

destructor cVectorTag.destroy;
begin
  inherited;
end;

function cVectorTag.getValue(i:integer):single;
begin
  result:=fValue[i];
end;

procedure cVectorTag.SetValue(index:integer;v:single);
begin
  if index>used then
    used:=index;
  fValue[index]:=v;
  if initMinMax then
  begin
    if v<minMax.x then
    begin
      minMax.x:=v
    end
    else
    begin
      if v>minMax.y then
        minMax.y:=v;
    end;
  end
  else
  begin
    initMinMax:=true;
    minmax:=p2(v,v);
  end;
end;

function cVectorTag.CheckAlarm:boolean;
var
  a:calarm;
  i:integer;
  b:boolean;
begin
  result:=false;
  if alarms.count=0 then exit;
  // �������� �� ���� ������� � ������� ��
  for I := 0 to alarms.Count - 1 do
  begin
    a:=calarm(alarms.getObj(i));
    if a.loAlarm then
      b:=a.checkValue(MinMax.x)
    else
      b:=a.checkValue(MinMax.y);
    if b then
      result:=b;
  end;
  if b then
    OnAlarm;
end;

function cVectorTag.getLen:integer;
begin
  result:=system.Length(fvalue);
end;

Function cVectorTag.M:single;
begin
  result:=GetM(fvalue);
end;

Function cVectorTag.D:single;
begin
  result:=getdisp(fvalue);
end;

procedure cVectorTag.SetLen(i:integer);
begin
  if i>=0 then
    setlength(fValue,i);
end;

Function cVectorTag.typestring:String;
begin
  result:=v_VectorTagDscf;
end;

procedure cVectorTag.Add(v:single);
begin
  Value[used]:=v;
  updateUseditems;
end;

function c2VectorTag.CheckAlarm:boolean;
var
  a:calarm;
  i:integer;
  b:boolean;
begin
  result:=false;
  if alarms.count=0 then exit;
  // �������� �� ���� ������� � ������� ��
  for I := 0 to alarms.Count - 1 do
  begin
    a:=calarm(alarms.getObj(i));
    if a.loAlarm then
      b:=a.checkValue(YMinMax.x)
    else
      b:=a.checkValue(YMinMax.y);
    if b then
      result:=b;
  end;
  if b then
    OnAlarm;
end;

function c2VectorTag.getValue(i:integer):point2;
begin
  result:=fValue[i];
end;

procedure c2VectorTag.SetValue(index:integer;v:point2);
begin
  if index>used then
    used:=index;
  fValue[index]:=v;
  if initMinMax then
  begin
    if v.x<xminMax.x then
    begin
      xminMax.x:=v.x
    end
    else
    begin
      if v.x>xminMax.y then
        xminMax.y:=v.x;
    end;
    if v.y<YminMax.x then
    begin
      YminMax.x:=v.y
    end
    else
    begin
      if v.y>YminMax.y then
        YminMax.y:=v.y;
    end;
  end
  else
  begin
    initMinMax:=true;
    XMinMax:=p2(v.x,v.x);
    yMinMax:=p2(v.y,v.y);
  end;
end;

procedure c2VectorTag.SetX(i:integer;x:single);
begin
  fValue[i].x:=x;
end;

procedure c2VectorTag.SetY(i:integer;y:single);
begin
  fValue[i].y:=y;
end;

Function c2VectorTag.M:single;
begin
  result:=GetM(fvalue);
end;

Function c2VectorTag.D:single;
begin
  result:=getdisp(fvalue);
end;

function c2VectorTag.getLen:integer;
begin
  result:=system.Length(fvalue);
end;

procedure c2VectorTag.SetLen(i:integer);
begin
  if i>=0 then
    setlength(fValue,i);
end;

Function c2VectorTag.typestring:String;
begin
  result:=v_2VectorTagDsc;
end;

procedure c2VectorTag.Add(v:point2);
begin
  if used>=length then
    exit;
  Value[used]:=v;
  updateUseditems;
end;

function c2VectorTag.getY(x:single):single;
var
  right,left:integer;
  k:single;
  p1,p2:point2;
begin
  right:=FindInPointsArrayHiBound(fValue,x,0,used);
  if right=0 then
  begin
    result:=fValue[0].y;
    exit;
  end;
  left:=FindInPointsArrayLowbound(fValue,x,0,used);
  if left=length-1 then
  begin
    result:=fValue[length-1].y;
    exit;
  end;
  p2:=fValue[right];
  p1:=fValue[left];
  k:=(p2.y-p1.y)/(p2.x-p1.x);
  result:=p1.y+k*(x-p1.x);
end;

function c2VectorTag.Count:integer;
begin
  result:=used;
end;

function c2dVectorTag.CheckAlarm:boolean;
var
  a:calarm;
  i:integer;
  b:boolean;
begin
  result:=false;
  if alarms.count=0 then exit;
  // �������� �� ���� ������� � ������� ��
  for I := 0 to alarms.Count - 1 do
  begin
    a:=calarm(alarms.getObj(i));
    if a.loAlarm then
      b:=a.checkValue(YMinMax.x)
    else
      b:=a.checkValue(YMinMax.y);
    if b then
      result:=b;
  end;
  if b then
    OnAlarm;
end;

function c2dVectorTag.getValue(i:integer):point2d;
begin
  result:=fValue[i];
end;

procedure c2dVectorTag.SetValue(index:integer;v:point2d);
begin
  if index>used then
    used:=index;
  fValue[index]:=v;
  if initMinMax then
  begin
    if v.x<xminMax.x then
    begin
      xminMax.x:=v.x
    end
    else
    begin
      if v.x>xminMax.y then
        xminMax.y:=v.x;
    end;
    if v.y<YminMax.x then
    begin
      YminMax.x:=v.y
    end
    else
    begin
      if v.y>YminMax.y then
        YminMax.y:=v.y;
    end;
  end
  else
  begin
    initMinMax:=true;
    XMinMax:=p2d(v.x,v.x);
    yMinMax:=p2d(v.y,v.y);
  end;
end;

procedure c2dVectorTag.SetX(i:integer;x:double);
begin
  fValue[i].x:=x;
end;

procedure c2dVectorTag.SetY(i:integer;y:double);
begin
  fValue[i].y:=y;
end;

Function c2dVectorTag.M:double;
begin
  result:=GetMd(fvalue);
end;

Function c2dVectorTag.D:double;
begin
  result:=getdispd(fvalue);
end;

function c2dVectorTag.getLen:integer;
begin
  result:=system.Length(fvalue);
end;

procedure c2dVectorTag.SetLen(i:integer);
begin
  if i>=0 then
    setlength(fValue,i);
end;

Function c2dVectorTag.typestring:String;
begin
  result:=v_2VectorTagDsc;
end;

procedure c2dVectorTag.Add(v:point2d);
begin
  if used>=length then
    exit;
  Value[used]:=v;
  updateUseditems;
end;

function c2dVectorTag.getY(x:double):double;
var
  right,left:integer;
  k:double;
  p1,p2:point2d;
begin
  right:=FindInDPointsArrayHiBound(fValue,x,0,used);
  if right=0 then
  begin
    result:=fValue[0].y;
    exit;
  end;
  left:=FindInDPointsArrayLowbound(fValue,x,0,used);
  if left=length-1 then
  begin
    result:=fValue[length-1].y;
    exit;
  end;
  p2:=fValue[right];
  p1:=fValue[left];
  k:=(p2.y-p1.y)/(p2.x-p1.x);
  result:=p1.y+k*(x-p1.x);
end;

function c2dVectorTag.Count:integer;
begin
  result:=used;
end;

constructor cTagMng.create;
begin
  inherited;
end;

destructor cTagMng.destroy;
begin
  inherited;
end;

procedure cTagMng.AddBaseObjInstance(obj:cbaseobj);
begin
  if obj is cBaseTag then
    inherited;
end;

function cTagMng.createTag(ID:integer):cBaseTag;
var
  tag:cBaseTag;
begin
  case id of
    c_ScalarTag: tag:=cScalarTag.create;
    c_VectorTag: tag:=cVectorTag.create;
  end;
  Add(tag,nil);
  result:=tag;
end;

function cTagMng.gettag(i:integer):cbasetag;
begin
  result:=cbasetag(getobj(i));
end;

function cTagMng.gettag(name:string):cbasetag;
begin
  result:=cbasetag(getobj(name));
end;

procedure cTagMng.XMLSaveMngAttributes(node:txmlnode);
begin
  // ��� ���� �������
  node.WriteAttributeString('TagsFolder',TagsFolder);
  node.WriteAttributeBool('LogTags',logtags);
end;

procedure cTagMng.XMLlOADMngAttributes(node:txmlnode);
begin
  if node<>nil then
  begin
    TagsFolder:=node.ReadAttributeString('TagsFolder');
    logtags:=node.ReadAttributeBool('LogTags');
  end;
end;

procedure cTagMng.AddToXML(fname:string; sectionName:string);
var
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  obj:cbaseobj;
begin
  doc:=TNativeXml.Create;
  doc.LoadFromFile(fname);
  node:=doc.Root;
  node:=node.NodeNew(sectionName);
  XMLSaveMngAttributes(node);
  Doc.XmlFormat := xfReadable;
  doc.SaveToFile(fname);
  doc.destroy;
end;

function cTagMng.LoadFromXML(fname:string; sectionName:string):boolean;
var
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  obj:cbaseobj;
begin
  doc:=TNativeXml.Create;
  doc.LoadFromFile(fname);
  node:=doc.Root.FindNode(sectionname);
  XMLlOADMngAttributes(node);
  doc.destroy;
end;



end.
