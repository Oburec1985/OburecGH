// � ����� ������� ��������� � ������ ��� ���������, ��������, ����������
// ������ Bld �����
unit uBldFile;

interface
 uses
   Messages, dialogs,controls, ComCtrls, classes, SysUtils,Windows,
   uTickData, uSensor, uBaseObj, ubldeng, ubinfile, uLoadBldForm,
   uVectorlist, uchan, uSetList, uCommonMath, ubldEngEventTypes, forms;

 Type
  sData = record
    mChan:byte;      // ����� ������
    mMarker:byte;
    mTicks:sTickData; // ����� ��������� � ����� - 0.025/1000000
  end;

  psdata = ^sdata;

  // ��������� �������� ���������� ��� ���������� ��������� Bld �����
  sBldTitle = record
    mTitle:string;        // C������� ��������� - ������ "RecBld" ��� bld.
    mTitleSize:LongWord;  // ������ ��������� � ������
    mCardType:word;       // C������� ��� ����� 2070 ��� 2081.
    mTestDate:TDateTime;  // ���� ���������
    mSamplingFreq:word;   // ������� �������������
    mEmpty:array of char; // ���������� �� 6���� ��������� ff
    mData:array of byte;  // ������
  end;

  cDataSet = class(cSetList)
  public
    constructor create;override;
    procedure add(data:sData);
    function getData(i:integer):sData;
  protected
    procedure deletechild(node:pointer);override;
  end;

  // ���� ��� ������/ ������ Bld �����
  cBldFile = class
  public
    eng:cbldeng;
    destroysensors, destroychannels:boolean;
  public
    // ������� ���������� ��� ���������� ���������� ����
    ProgressEvent:tNotifyEvent;
    progress:integer;// � ���������

    sensors:cBaseObjList;
    channels:cIntVectorList;
    mBldTitle:sBldtitle; // ������������ ���������� bld �����
    mData:array of sData;
    filename:string; // ������ ����� ���������� ������������ �����
    f:File;
  private
    // ��������� ��� � ���� �� �������� ���������� ��� ������
    procedure evalticks(var p_data:sdata);
    // ��������� ������ ���������
    procedure evalTitleSize;
    // ���������� ������ �� ������� �� ������ � sensors.
    procedure getLists;
    // ����������� ������ ��� ������
    procedure prepareData;
    procedure DelChanData(sender:tobject);
  public
    constructor Create;
    // ������� ��������� �������� ����
    destructor Destroy;
    // ��������������� � ������. ����� ����� ������ Save � Load ����� ��������
    procedure GetFile(name:string);
    // ���������� ���������� ����� ���������� ������ � Bld ����
    procedure Save;
    // �������� Bld ����� � ���� ������
    function Load:boolean;
    // �������� Bld ����� � ���� ������
    procedure Clear;// �������� ������
    // ���������� ����������� ������� � ������������� eng
    procedure MergeCfg;
    function getsensor(i:integer):csensor;overload;
    function getsensor(name:string):csensor;overload;
    function getchan(i:integer):cchan;
    function GetEngChan(i:integer):cchan;
    function findchan(key:integer):cchan;
  end;

  // ��������� Bld ����
  function ReadBldData(filename:string;eng:cbldEng):boolean;
  function ReadBldDataExt(filename:string;eng:cbldEng;progressevent:tnotifyevent):boolean;
  // ��������� Bld ����
  procedure WriteBldData(filename:string;eng:cbldEng);

  const pi = 3.14159265;

  // ��������� ������������ ��� �������
  const
    c_root = 0;
    c_edge = 1;
    c_rot  = 4;
    c_UTS  = 7;

implementation

function proccomparator(p1,p2:pointer):integer;
begin
  result:=CompareTicks(sdata(p1^).mTicks, sdata(p2^).mTicks);
end;

constructor cDataSet.create;
begin
  inherited;
  comparator:=proccomparator;
end;

procedure cDataSet.add(data:sData);
var pdata:psdata;
begin
  getmem(pdata, sizeof(stickdata));
  pdata^:=data;
  AddObj(pdata);
end;

function cDataSet.getData(i:integer):sData;
begin
  result:=sdata(getnode(i)^);
end;

procedure cDataSet.deletechild(node:pointer);
begin
  freemem(psdata(node));
end;



// ��������  � ����� ��������� bld ����� �������� �����
procedure UpdateTitleSize(var BldFile:cBldFile);
var i,
    division,remainder,add:integer;
    str:string;
begin
  division  := (BldFile.mBldTitle.mTitleSize+4) div 6; //�������� ����� �����
  remainder := (BldFile.mBldTitle.mTitleSize+4) mod 6; //�������� ������� �����
  if remainder<>0 then add:=6-remainder else add:=0;
  BldFile.mBldTitle.mTitleSize:=BldFile.mBldTitle.mTitleSize + 4 + add;
  SetLength(BldFile.mBldTitle.mEmpty, add + 4);
  for i:= 0 to (add)-1 do
  begin
    BldFile.mBldTitle.mEmpty[i]:='f'
  end;
  for i:=add to (add+4)-1 do
  begin
    str:='DATA';
    BldFile.mBldTitle.mEmpty[i]:=str[i+1 - add];
  end;
end;

procedure cBldFile.DelChanData(sender:tobject);
begin
  if sender is cchan then
    cchan(sender).destroy;
end;

constructor cBldFile.Create;
begin
  filename:='';
  mBldTitle.mTitle:='RecBld';
  sensors:=cbaseobjlist.create;
  sensors.destroydata:=true;
  channels:=cIntVectorList.create;
  channels.fDelData:=DelChanData;
end;


// ������� BldFile
destructor cBldFile.Destroy;
begin
  clear;
  sensors.destroydata:=destroysensors;
  sensors.destroy;
  channels.destroydata:=destroychannels;
  channels.destroy;
  //if assigned(@f) then
  //  closefile(f);
end;

procedure cBldFile.prepareData;
var
  buf:cdataset;
  chan:cchan;
  I,j: Integer;
  data:sdata;
begin
  buf:=cdataset.create;
  buf.destroydata:=true;
  for I := 0 to eng.ChanCount - 1 do
  begin
    chan:=GetEngChan(i);
    for j := 0 to chan.ticksCount - 1 do
    begin
      data.mTicks:=chan.ticks.gettick(j);
      data.mChan:=chan.chan;
      data.mMarker:=0;
      buf.add(data);
    end;
  end;
  setlength(mdata, buf.Count);
  for I := 0 to buf.Count - 1 do
  begin
    mdata[i]:=buf.getdata(i);
  end;
  buf.destroy;
end;

// ��������� ������ � ����
procedure cBldFile.Save;
    //�������� � ����  ������� �������
    procedure WriteSensor(const Sensor:cSensor);
    begin
      // ����� ������
      writeword(f,sensor.chanNumber);
      // �������� ������
      writebyte(f,sensor.chan.Amplifier);
      // �������� ����� ����� (1 ����) � ���.
      writeansistring(f, sensor.Name);
      // �������� ��� �������
      writeword(f,sensor.sensorType);
    end;
    //�������� � ���� ���������
    procedure WriteTitle(const BldTitle:sBldTitle);
    var lWritten,i:integer;
    begin
     evalTitleSize;
     // �������� ��������� RecBld
     WriteString(f,BldTitle.mTitle);
     // ������ ���������
     WriteCard(f,BldTitle.mTitleSize);
     // ��� �����
     writeword(f,BldTitle.mCardType);
     // ����� �������
     writeword(f,sensors.count);
     for I := 0 to sensors.count - 1 do
       WriteSensor(getsensor(i));
     BlockWrite(f,BldTitle.mTestDate,8,lWritten);
     writeword(f,BldTitle.mSamplingFreq);
     BlockWrite(f,BldTitle.mEmpty[0],Length(BldTitle.mEmpty),lWritten);
    end;
    // �������� � ���� ������
    procedure WriteData(const Data:array of sData);
    var i,Len,lWritten:integer;
    begin
      Len:=Length(Data);
      for I := 0 to len-1 do
      begin
        BlockWrite(f,Data[i].mChan,1,lWritten);
        BlockWrite(f,Data[i].mMarker,1,lWritten);
        BlockWrite(f,Data[i].mTicks,4,lWritten);
      end;
    end;
begin
  // ��������, ��� ���� ����������
  if Assigned(@f) then
  begin
     Rewrite(f,1); // ����� ����� ������������ �������.
     WriteTitle(mBldTitle); // �������� ��������� � ����
     prepareData;
     WriteData(mData); // �������� ������ � ����
     CloseFile(f); // ������� ����
  end;
end;

// ��������������� � ������. ����� ����� ������ Save � Load ����� ��������
procedure cBldFile.GetFile(name:string);
begin
  filename:=name;
  AssignFile(f,name);
end;

// ��������� Bld ����
function cBldFile.Load:boolean;
  var
    count,lFileSize:integer;
  // ��������������� ��������� ��� ������ ���-�� ������
  procedure readSensor(var sensor:cSensor);
  var
    nameLen,i:byte;
    Ch:array of char;
    lReaded:cardinal;
    lchan:cchan;
    ind, index:integer;
  begin
    sensor.channumber:=readword(f);
    ind:=sensor.channumber;
    lchan:=cchan(channels.findObj(@ind,index));
    if lchan=nil then
    begin
      lchan:=cchan.create(c_SortedTicks);
      lchan.chan:=sensor.channumber;
      channels.AddObject(@lchan.chan,lchan);
    end;
    lchan.Amplifier:=readbyte(f);
    sensor.Name:=ReadAnsiString(f);
    sensor.sensortype:=readword(f);
  end;
  // ��������� ��������� �����
  procedure ReadTitle(var Title:sBldTitle);
  var
    index,lReaded,i:integer;
    lTitle:array[0..6] of char;
    sensor:csensor;
    CountChun:word;
  begin
    // ������� ������ ���������(6),��� �����(2) � ����� �������
    Title.mTitle:=readstring(f,6);
    if Title.mTitle<>'RecBld' then exit;
    Title.mTitleSize:=readcard(f);
    Title.mCardType:=readword(f);
    CountChun:=readword(f);
    for i:=0 to CountChun-1 do
    begin
      sensor:=cSensor.Create;
      readSensor(sensor);
      sensors.addobj(sensor);
    end;
    BlockRead(f,Title.mTestDate,8,lReaded);
    Title.mSamplingFreq:=readword(f);
    SetLength(Title.mEmpty,Title.mTitleSize-FilePos(f));
    BlockRead(f,Title.mEmpty[0],Title.mTitleSize-FilePos(f),lReaded);
  end;
  procedure ReadData(len:integer);
  var
    i,lReaded:integer;
    Dat:sData;
  begin
    for I := 0 to len-1 do
    begin
      BlockRead(f,dat.mChan,1,lReaded);
      BlockRead(f,dat.mMarker,1,lReaded);
      BlockRead(f,dat.mTicks.Data,4,lReaded);

      evalticks(dat);
      progress:=round((i/len)*100);
      if Assigned(ProgressEvent) then
        progressevent(self);
      Application.ProcessMessages;
    end;
  end;
begin
  if fileexists(filename) then
  begin
    // ��������, ��� ���� ����������
    if Assigned(@f) then
    begin
      Reset(F,1); // ���������� ����� �������� ������ � ������
      // ������� ���������
      ReadTitle(mBldTitle);
      // ������ ������
      Seek(f,mBldTitle.mTitleSize); // ����������� ������ �� ������ ������ ������
      lFileSize:=FileSize(f);       // ���������� ������ ����� � ������
      count:=trunc((lFileSize-mBldTitle.mTitleSize)/6);
      // ������� count ������
      ReadData(count);
      // ������� ����
      CloseFile(f);
    end;
  end;
end;

procedure cBldFile.Clear;
begin
  setlength(mBldTitle.mEmpty,0);
  setlength(mData,0);
  mBldTitle.mEmpty:=nil;
  mData:=nil;
end;

procedure cBldFile.MergeCfg;
var
  i:integer;
  sensor:csensor;
begin
  for I := 0 to sensors.count - 1 do
  begin
    sensor:=csensor(sensors.getobj(i));
    if True then

  end;
end;

function cBldFile.getsensor(i:integer):csensor;
begin
  result:=csensor(sensors.getobj(i));
end;

function cBldFile.getsensor(name:string):csensor;
begin
  result:=csensor(sensors.getobj(name));
end;

function cBldFile.getchan(i:integer):cchan;
begin
  result:=cchan(channels.getObj(i));
end;

function cBldFile.GetEngChan(i:integer):cchan;
begin
  result:=cchan(eng.getchan(i));
end;

function cBldFile.findchan(key:integer):cchan;
var index:integer;
begin
  result:=cchan(channels.findObj(@key,index));
end;

procedure cBldFile.evalticks(var p_data:sdata);
var
  i,overflow,tickcount:integer;
  chan:cchan;
  prevtick, tick:stickdata;
begin
  chan:=findchan(p_data.mChan);
  if chan=nil then
  begin
    chan:=cchan.create(c_SortedTicks);
    chan.Amplifier:=p_data.mMarker;
    chan.chan:=p_data.mChan;
    channels.AddObject(@chan.chan,chan);
  end;
  tick.data:=p_data.mTicks.Data;
  tickcount:=chan.ticksCount;
  if tickcount>0 then
  begin
    prevtick:=chan.ticks.gettick(tickcount-1);
    if tick.Data<prevtick.data then
    begin
      tick.overflowcount:=prevtick.OverflowCount+1;
    end
    else
      tick.OverflowCount:=prevtick.OverflowCount;
  end
  else
  begin
    tick.OverflowCount:=0;
  end;

  chan.ticks.Add(tick);
end;

procedure cBldFile.evalTitleSize;
var
  i,size:integer;
  sensor:csensor;
begin
  // ���������� ����, ������� ������ ������� � �����
  // 24 =6(RecBld) + 4(������ ���������)TitleSize + 2(��� �����) + 2(����� �������)
  // + 8(����� � ���� ���������)+2(freq)
  mBldTitle.mTitleSize:=24;
  size:=0;
  for I := 0 to sensors.count - 1 do
  begin
    sensor:=getsensor(i);
    // 6=2(����� ������)+1(��������)+1(����� �����)+2(��� �������)
    size:=Length(sensor.Name)+size+6;
  end;
  mBldTitle.mTitleSize:=mBldTitle.mTitleSize+size;
  // ��������� �������� ����� � ����� ��������
  UpdateTitleSize(self);
end;

function addproc(obj:cbaseobj; data:pointer):boolean;
begin
  result:=true;
  cbaseobjlist(data).addobj(obj);
end;

procedure cBldFile.getLists;
begin
  eng.EnumSensors(addproc, sensors);
  // ������������ ������ � ����� ������

end;

function ReadBldDataExt(filename:string;eng:cbldEng;
                       progressevent:tnotifyevent):boolean;
var
  f:cBldFile;
  createNewFrm:boolean;
  lloadBldDlg:tloadBldDlg;
  showblddlg:boolean;
begin
  result:=false;
  if fileexists(filename) then
  begin
    f:=cBldFile.Create;
    f.ProgressEvent:=progressevent;
    f.GetFile(filename);
    f.eng:=eng;
    f.Load;
    createNewFrm:=false;
    if loadBlddlg=nil then
    begin
      lloadBldDlg:=TLoadBldDlg.Create(nil);
      createNewFrm:=true;
    end
    else
      lloadBldDlg:=loadBlddlg;
    showblddlg:=not checkflag(eng.flags,c_EngLoading);
    if lloadBlddlg.showmodal(f,showblddlg)=mrok then
    begin
      result:=true;
    end;
    f.Destroy;
    if createNewFrm then
      lloadBldDlg.Destroy;
    eng.Events.CallAllEvents(E_OnEngLoadData);
  end
  else
    showmessage('���� '+filename+' �� ������');
end;

function ReadBldData(filename:string;eng:cbldEng):boolean;
begin
  result:=ReadBldDataExt(filename, eng, nil);
end;

procedure WriteBldData(filename:string;eng:cbldEng);
var f:cBldFile;
begin
  f:=cBldFile.Create;
  f.GetFile(filename);
  f.eng:=eng;
  // ��������� ������ �������� �� ����� � ����
  f.getLists;
  f.save;
  f.Destroy;
end;

end.
