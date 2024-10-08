unit u2070;

interface
uses
  MxxxxAPI, MxxxxTypes,  inifiles, SysUtils, classes, uBaseObjMng,
  uBaseObj, uBldObj, uBaseObjTypes, controls, ubldeng, uPlat,  Types4Bld,
  uTag, ubldglobalstrings, utickdata, uDataThread;

type
  LWArr = array of longword;
  ArrLWArr = array of LWArr;
  WordArray = array of Word;
  PWordArray = array of WordArray;

  TData = record
    chan:byte;
    m:byte;
    t:cardinal;
  end;

  TDataArray = array of TData;

  cM2070 = class(cPlat)
  protected
    // ������������� ����������. ����������� ��� ������ CreateDevice
    handle:ppointer;
    // ����� ��� ��������� ������ �� ����� � ���������� ������
    DigBuff:array of longWord;
    // ���� �� ����������
    aTags:array of cvectortag;
  protected
    procedure init(inipath:ansistring; devinfo:TDevice);override;
    // ��������������� ����������� ���� ������
    procedure ConfigASync;override;
    procedure Config;override;
    // ���������� ������ ������
    procedure SetBufferSize(size:cardinal);override;
    procedure CreateTags;override;
    procedure StopASync;override;
    procedure ConvertDataToEngine(size:cardinal);override;
    procedure LinkThread;override;
  public
  public
    constructor create;override;
    destructor destroy;override;
    procedure Stop;override;
    // �������� ����� ������. �������������������. �������� ��������� ���� �������
    procedure GetData;override;
  end;

  c2070DataThread = class(cDataThread)
  protected
    plat:cM2070;
  protected
    // ����� setNewDataEvent
    procedure OnNewData;override;
    // ��������� ������� ����� ������ � ��������� � ������ ���������������
    // ������������ ������ �� ����������� ����� ����. ���� ��������� �������
    // ���� ������ ��������������� ������ ��� ������� ����� ���������
    // � cBldTimeProc ��������� ������ (��������� ���������), �� ���������� ����� �������.
    procedure PlayFunc;override;
    // ����������� � OnFinishPlayData (� �������)
    //procedure OnDataProc(sender:tobject);override;
    // ���������� ��������������� ����� �������� ������ ����� ������ �
    // setEnabled. ����� ���������� ������������ ������� ��� ���������� �������
    // � ������������ � �������� ����� ��� ����������� ��������� ��������
    // � �������. ���������� ���� data
    //procedure OnBeforeStop(sender:tobject);override;
    // ��������� TDirChangeNotifier �� �������� �� ��������� ���������
    // ����� ���������� ����� ���� ���������� �������
    procedure BeforeStartThread(sender:tobject);override;
  public
    constructor create(mng:cDataThreadMng);override;
    //destructor destroy;override;
  end;

  // ��������� callback �� ���������� �� �����
  function DataHandler(sender : tobject):cardinal; stdcall;

  const
    // ����� ������ ��� handler
    memsize = 1000000;
    // ������ �� ������� �������� ����� �������
    section = 'Lopatki';
    // ����� ���������� �������
    c_AChanCount = 1;
    c_OscBuff = 4096;
      // ������� ������ ���������� �������
    cRate = 10000;

implementation
uses
  ubldtimeproc;

Function DataHandler(sender : tobject):cardinal; stdcall; //���������� ����������
var
  dir: Word;
  plat:cM2070;
  BSize, szLost, szOverflow:LongInt;
begin
  plat:=cm2070(sender);
  GetDirection(plat.handle,@dir);
  GetReadBufSize(plat.handle,@BSize,@szLost,@szOverflow);
  MxxxxApi.ReadBuf(plat.handle, @plat.ASyncData[0], @BSize);
  result:=0;
end;

procedure cM2070.ConvertDataToEngine(size:cardinal);
var
  engine:cbldeng;
  i:cardinal;
begin
  engine:=cPlatsList(getmng).eng;
  for I := 0 to size - 1 do
  begin

  end;
end;

procedure cM2070.init(inipath:ansistring; devinfo:TDevice);
var
  inifile:tinifile;
  res:cardinal;
  p:pointer;
begin
  inherited;
  // p - ������ ��������� ���� ����-�� (�� nil)
  getmem(p, memsize);
  handle:=@p;
  res:=MxxxxApi.CreateDevice(devinfo, handle);
  handle:=p;

  inifile:=TIniFile.Create(inipath);
  freq:=inifile.ReadFloat('Lopatki','FreqInN',999);
  inifile.Destroy;
  // ���� �� ���� ������
  if res=ERROR_NOERROR then
  begin
    Res:=ReadPropertyEx(handle,PAnsiChar(inipath),PAnsiChar(section));
    if Res = ERROR_NOERROR then
    begin
      SetInterrupt(handle, self, @DataHandler);
      // ����� ��������� ������ ��������� � ini ����� ������ ���� ���������
      // �������� ���� � Flex �����
      Res :=Load(handle);
      if Res <> ERROR_NOERROR then
      begin
        // ���� ��������� ������, ��������� ����������
        CloseDevice(@handle);
        handle:=nil;
      end
      else //����� 2070 ������
      begin
        finit:=true;
      end;
    end
  end;
  Config;
end;

procedure cM2070.ConfigASync;
var
  size:cardinal;
  v:variant;
  // ����� ������������ �������
  ChannelMask:word;
  i:integer;
  res:cardinal;
begin
  //GetMem(Bf.Buf,SizeOf(Word)*size*cSafetyfactor);
  //Bf.BufEnd:=(SizeOf(Word)*bSize*cSafetyfactor) div glSizeTIndex;
  //��������� ����� �������
  //ChannelMask:=0;
  //for i:=1 to 16 do
  //begin
  //  ChannelMask:=ChannelMask+(1 shl (i-1) );
  //end;
  GetMaxBufSize(handle,@size);
  setlength(ASyncData,size);
  // ��� 1=1 ������ ��� 1 ����� �������, ��� 2 ����� 2 ������ 2-� ������� � �.�.
  ChannelMask:=65535;
  VarClear(v);
  TVarData(v).VType:=varSmallint;
  TVarData(v).VSmallint:=Smallint(ChannelMask);
  SetProperty(handle, PROP_POS_FRONT_0, v);
  res := ConfigDevice(handle);
  res := res OR ResetCount(handle);
  res := res OR Start(handle);
end;

procedure cM2070.Config;
var
  res:cardinal;
  v:variant;
  TestResult:LongInt;
begin
  // ������� �������� �����
  Res:=ReadPropertyEx(handle,PAnsiChar(m_inipath),PAnsiChar(section));
  Res := Test(handle,PAnsiChar(m_inipath),PAnsiChar(section),@TestResult);// �.�.
  // ������� ����������� �����
  VarClear(v);
  TVarData(v).VType := varDouble;
  TVarData(v).VDouble:=freq;
  // 999
  SetProperty(handle, PROP_FREQ_IN, v);
  // ������ ������
  VarClear(v);
  TVarData(v).VType := varSmallint;
  TVarData(v).VSmallint:=c_BuffSize;
  // 1023
  SetProperty(handle,PROP_NWORD, v);
  // ����� �������
  VarClear(v);
  TVarData(v).VType := varSmallint;
  TVarData(v).VSmallint:=c_FrameCount;
  // 10
  SetProperty(handle,PROP_CNT_FRAME, v);
  //����� ����������� ����
  VarClear(v);
  TVarData(v).VType := varSmallint;
  TVarData(v).VSmallint:= cPartFifo;
  // 8
  SetProperty(handle,PROP_CNT_PART_FIFO, v);
  // ����� ����������� �����������
  VarClear(v);
  TVarData(v).VType := varSmallint;
  TVarData(v).VSmallint:=$004+(0); //$004+( ME052.Chan div 8);
  // 4
  SetProperty(handle,PROP_CMD_REG_0, v);
  res := mxxxxapi.Config(handle);

  //ProgramME052(fdevice, mfpi, @fvlw[mfpi]);
end;

destructor cM2070.destroy;
begin
  CloseDevice(@handle);
  //freemem(handle^, memsize);
  inherited;
end;

procedure cM2070.GetData;
var
  res:cardinal;
  AChans: array [0..4] of word;
  i,j:integer;
  Mask, MaskA:LongWord;
  bufsize:word;
  tag:cvectortag;
begin
  for I := 0 to tags.count - 1 do
  begin
    tag:=cvectortag(gettag(i));
    tag.length:=(cBufSize div NumPort);
    tag.clear;
  end;

  AChans[0]:=0;
  AChans[1]:=1;
  AChans[2]:=2;
  AChans[3]:=3;
  //<=4096 � 16-������ ������
  bufsize:=c_OscBuff;
  res:=LpOscil(handle, cRate, @AChans, c_AChanCount, @DigBuff[1], bufsize);
  if res=ERROR_NOERROR then
  begin
    MaskA:=$FFF00000;
    for i:=0 to (bufsize div NumPort)-1 do  //������� ��������������� ���
    begin
       for j:= 0 to fChanCount - 1 do
       begin
         // TODO : ����� ���������� ����� ���
         // ����� ��� ��������� j- ��� ������
         Mask:=1 shl j;
         digtags[j].Add((DigBuff[i] and Mask) shr j);
       end;
       atags[0].add((DigBuff[i] and MaskA) shr 20);
    end;
  end;
end;

procedure cM2070.Stop;
begin
  inherited;
end;

constructor cM2070.create;
begin
  inherited;
  DataMode:=c_OscMode;
  //GetDataMode:=c_ASyncMode;
  objtype:=c_2070;
  fChanCount:=22;
  // ����� ������ ��� ���������� �������
  setlength(aTags,2);
end;

procedure cM2070.SetBufferSize(size:cardinal);
var
  I: Integer;
  tag:cvectortag;
begin
  inherited;
  setlength(buffTicksData ,cBufSize);
  setlength(DigBuff ,cBufSize);
  for I := 0 to tags.count - 1 do
  begin
    tag:=cvectortag(gettag(i));
    tag.length:=(cBufSize div NumPort);
    cvectortag(tag).dx:=1/cRate;
  end;
end;

procedure cM2070.CreateTags;
var
  I: Integer;
  tag:cVectorTag;
begin
  setlength(aTags,2);
  for I := 0 to 1 do
  begin
    tag:=cvectortag.create;
    aTags[i]:=cvectortag(tag);
    tag.OnSetActive:=cPlatsList(getmng).OnTagSetActive;
    tag.name:=Name+'.a_'+inttostr(i);
    tag.dsc:=v_OscTagDsc;
    tag.blocked:=true;
    tags.addobj(tag);
    if finit then
      tag.active:=true;
  end;
  inherited;
end;

procedure cM2070.StopASync;
begin
  //��������� ������/�������� ������
  mxxxxapi.Stop(handle);
end;

procedure cM2070.LinkThread;
begin
  Thread:=c2070DataThread.create(cdatathreadmng(cbldtimeproc(eng.timeproc).dataThreads));
  c2070DataThread(Thread).plat:=self;
  // ��������� ������ ��������� ������ �� �����
  period:=c_DefaultTime;
  inherited;
end;

procedure c2070DataThread.OnNewData;
begin
  if plat.DataMode=c_OscMode then
    setNewDataEvent;
end;

constructor c2070DataThread.create(mng:cDataThreadMng);
begin
  inherited;
  typeThread:=c_PlatThread;
  // ��������� ������
  FreeOnTerminate:=false;
  Priority:=tpLower;
end;

procedure c2070DataThread.PlayFunc;
begin
  plat.SyncGetData;
end;

procedure c2070DataThread.BeforeStartThread(sender:tobject);
begin
  b_waitNewDataEvent:=plat.DataMode<>c_OscMode;
end;


end.
