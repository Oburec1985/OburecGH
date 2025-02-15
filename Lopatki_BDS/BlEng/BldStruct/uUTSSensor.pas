unit uUTSSensor;

interface
uses
  ubldObj, uchan, utickdata, universal_time, uBaseObjService, ubaseobj,
  uBldGlobalStrings, NativeXML, uBldMath, sysutils, uTag, uCommonTypes,
  windows;

type
  UTSType = (irig_b, UTS);

  cUTSSensor = class(cbldObj)
  private
    fUTStime:TUnTimeAutomat;
    // ������ ������ � �������� UTS
    f_SecondsCard:array of cardinal;
    // ������ ������ � �������������
    f_MsCard:array of cardinal;
    // ������ ������ � �������� UTS
    f_Seconds:array of double;
    // ������ ������ � ����� �����
    f_Ticks:array of stickdata;
    fcount:integer;
    b_init:boolean;
    // ������� ��������� ������� ��������� �� ����� �������� ���
    // ���������� ������ ������
    PrevTimeCount,badTimeCount:integer;
    m_UTSType:UTSType;
  public
    // ����� ������ ��������� ��� ��������  � ��������� ����� �� ��������
    timeZone:integer;
  public
    // ������ ���������
    fchan:smallint;
    StartTime:double;
  private
    procedure AddTick(tick:stickdata);
  protected
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
    function GetCount:integer;
    // ������ ��������� ������ (�������� � ������� cBldEng)
    function getchannumber:smallint;
    procedure setchannumber(i:smallint);
    function getchan:cchan;
    // ����� ����� (����)
    procedure prepareTime;
    procedure SetUTSType(t:UTSType);
  public
    constructor create;override;
    destructor destroy;override;
    property channumber:smallint read getchannumber write setchannumber;
    property chan:cchan read getChan;
    procedure SetUtsChan(ch:cchan);
    property Count:integer read getcount write fcount;
    function gettick(i:integer):stickdata;
    function gettime(i:integer):double;overload;
    function GetTime(t:stickdata):double;overload;
    function TypeString:String;override;
    property UTSSignalType:UTSType read m_UTSType write m_UTSType;
    // ������� ��� xy
    function CreateTag:c2dVectorTag;
  end;

  const
   c_BufSize = 100000;
   c_irig = 0;
   c_SEV = 1;

implementation

constructor cUTSSensor.create;
var
  lpTimeZoneInformation: TTimeZoneInformation;
begin
  inherited;
  m_UTSType:=irig_b;
  b_init:=false;
  setlength(f_seconds, c_BufSize);
  setlength(f_Ticks, c_BufSize);
  setlength(f_SecondsCard,c_BufSize);
  setlength(f_MsCard,c_BufSize);
  fcount:=0;
  objtype:=c_UTS;
  helper:=false;
  autocreate:=false;
  PrevTimeCount:=0;
  badTimeCount:=0;
  imageindex:=20;
  GetTimeZoneInformation(lpTimeZoneInformation);
  timeZone:=lpTimeZoneInformation.Bias*60;
end;

destructor cUTSSensor.destroy;
begin
  inherited;
end;

function cUTSSensor.getchannumber:smallint;
begin
  result:=fchan;
  if not b_init then
  begin
    if chan<>nil then
    begin
      if chan.ticksCount<>0 then
      begin
        SetUtsChan(chan);
        b_init:=true;
      end;
    end;
  end;
end;

procedure cUTSSensor.setchannumber(i:smallint);
var
  lchan:cchan;
begin
  if fchan<>i then
  begin
    b_init:=false;
    fCount:=0;
  end;
  fchan:=i;
  if eng<>nil then
  begin
    if chan=nil then
    begin
      if i<>-1 then
        eng.Addchan(i);
    end
  end;
end;

function cUTSSensor.TypeString:String;
begin
  result:=v_UTS;
end;

procedure cUTSSensor.SetUtsChan(ch:cchan);
var
  I: Integer;
begin
  fchan:=ch.chan;
  fcount:=0;
  fUTStime:=TUnTimeAutomat.create;
  if m_utstype=irig_b then
  begin
    fUTStime.TipeOfTime:=IRIG;
  end
  else
  begin
    fUTStime.TipeOfTime:=SEV;
  end;
  for I := 0 to chan.ticksCount - 1 do
  begin
    AddTick(chan.ticks.gettick(i));
  end;
  prepareTime;
  starttime:=f_Seconds[0];
  fUTStime.Destroy;
end;

procedure cUTSSensor.prepareTime;
var
  dTime,i, bad:integer;
  t:double;
  str:string;
begin
  bad:=-1;
  for I := 1 to fCount - 1 do
  begin
    t:=f_Seconds[i];
    if t-f_Seconds[i-1]>100 then
    begin
      bad:=i;
      break;
    end;
  end;
  if bad<>-1 then
    begin
    for I := 0 to bad - 1 do
    begin
      dTime:=evDecTicks(f_Ticks[i], f_Ticks[bad]);
      t:=TickToSec(dTime);
      f_Seconds[i]:=f_Seconds[bad]-t;
      f_SecondsCard[fcount]:=f_SecondsCard[bad] - trunc(t);
      dTime:=f_MsCard[bad] - trunc(frac(t)*1000);
      if dTime<0 then
        dTime:=dTime+1000;
      f_MsCard[i]:=dTime;
    end;
  end;
end;

procedure cUTSSensor.AddTick(tick:stickdata);
var
  I: Integer;
  t:double;
begin
  fUTStime.NewStick(tick.Data);
  t:=fUTStime.second+fUTStime.ms/1000;
  if fcount=0 then
  begin
    f_SecondsCard[fcount]:=fUTStime.second;
    f_MsCard[fcount]:=fUTStime.ms;
    f_Seconds[fcount]:=t;
    f_Ticks[fcount]:=tick;
    inc(fcount);
  end
  else
  begin
    if abs(t-f_Seconds[fcount-1])>1 then
    begin
      f_SecondsCard[fcount]:=fUTStime.second;
      f_MsCard[fcount]:=fUTStime.ms;
      f_Seconds[fcount]:=t;
      f_Ticks[fcount]:=tick;
      inc(fcount);
    end;
  end;
end;

function cUTSSensor.gettick(i:integer):stickdata;
begin
  result:=f_Ticks[i];
end;

function cUTSSensor.gettime(i:integer):double;
begin
  result:=f_Seconds[i]
end;

function cUTSSensor.SupportedChildClass(obj:cbaseobj):boolean;
begin
  result:=false;
end;

function cUTSSensor.SupportedChildClass(classname:string):boolean;
begin
  result:=false;
end;

function cUTSSensor.SupportedChildClass(objtype:integer):boolean;
begin
  result:=false;
end;

function cUTSSensor.GetCount:integer;
begin
  if chan=nil then
    result:=0
  else
    result:=fcount;
end;

procedure cUTSSensor.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
var
  lchan:cchan;
  lutstype:integer;
  i:integer;
begin
  inherited;
  channumber:=xmlNode.ReadAttributeInteger('Chan',-1);
  lutstype:=xmlNode.ReadAttributeInteger('UTSType',-1);
  if lutstype=c_irig then
  begin
    UTSSignalType:=irig_b;
  end
  else
    UTSSignalType:=uts;
end;

procedure cUTSSensor.SaveObjAttributes(xmlNode:txmlNode);
begin
  inherited;
  if chan<>nil then
    xmlNode.WriteAttributeInteger('Chan',channumber)
  else
    xmlNode.WriteAttributeInteger('Chan',-1);
  if utssignaltype=irig_b then
  begin
    xmlNode.WriteAttributeInteger('UTSType',c_irig);
  end
  else
    xmlNode.WriteAttributeInteger('UTSType',c_SEV);
end;

function cUTSSensor.getchan:cchan;
begin
  result:=cchan(eng.findchan(fchan));
end;

function cUTSSensor.getTime(t:stickdata):double;
var
  lo:integer;
  t1,t2:stickdata;
  dPos,d_t1, d_t2:double;
  i:integer;
begin
  i:=getchannumber;
  lo:=FindInTickArrayLowBound(f_Ticks,t,0,count-1);
  if lo<count then
  begin
    t1:=f_Ticks[lo];
    t2:=f_Ticks[lo+1];
    d_t1:=f_Seconds[lo];
    d_t2:=f_Seconds[lo+1];
    dPos:=EvalTickPos(t1,t2,t)/360;
    result:=(d_t2-d_t1)*dPos + d_t1;
  end
  else
    result:=f_Seconds[count];
end;

function cUTSSensor.CreateTag:c2dVectorTag;
var
  t:single;
  I: Integer;
begin
  result:=nil;
  // �������������
  getchannumber;
  if fcount>0 then
  begin
    result:=c2dVectorTag.create;
    result.offset:=timeZone;
    result.length:=fCount;
    for I := 0 to fCount - 1 do
    begin
      t:=ticktosec(f_ticks[i]);
      result.Add(p2d(t,f_seconds[i]));
    end;
    result.name:='UTS';
  end;
end;

procedure cUTSSensor.SetUTSType(t:UTSType);
begin
  m_UTSType:=t;
end;

end.
