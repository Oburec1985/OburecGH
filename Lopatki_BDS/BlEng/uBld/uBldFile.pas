// � ����� ������� ��������� � ������ ��� ���������, ��������, ����������
// ������ Bld �����
unit uBldFile;

interface
 uses
   Messages,ComCtrls,classes,SysUtils,Windows,inifiles,math, uTickData,
   uPair;


 Type
  //
  sData = record
    mChan:byte;      // ����� ������
    mMarker:byte;
    mTicks:sTickData; // ����� ��������� � ����� - 0.025/1000000
  end;

  //
  sblade = record
    offset:single;
    GenVibr:boolean;
  end;

  cBlRecCfg = class
    mode:integer;
    filename:string;
    dN:single;
    LoTaho,HiTaho,LoAmpl,HiAmpl:single;
    method:integer;
    RangeFrom,RangeTo:single;
    ThNumPoint,MgNumPoint:integer;
    //-----------------------
    h1,h4,h5,g1,g2,g3,g4,g5,f2,f3,f4:single;
    mnSource,nmTarget,nmMesage,nmHolder,nmGates,useGates:string;
  end;

  // ����� �������
  cStage = class
    // �������� �������
    name:string;
    // ����� �������
    bladenumber:integer;
    // ������� ������� � ��
    diametr:single;
    blades:array of sBlade;
    // ����� ���
    pairscount:integer;
    // ��� ���
    pairlist:cpairlist;
    // ������� ����� ������� �� �������/ ������ �������
    orderblade:boolean;
    // ���������� ����
    stagetype, countHarm:integer;
    // ���� ���������� �������������
    LimStressResonance, LimStressStill, resonanse,
    kfSigma, bin, bout,
    f1:single;
    OrderHarm:array of integer;
    tahocomb:integer;
  public
    constructor create;
    destructor destroy;
  end;

  // ���� ������� �������� ������ ��������
  cStageList = class(tstringlist)
  public
    // ������� ������ ��� ����������� �������
    m_cleardata:boolean;
  private
    function readstage(index:integer):cStage;
  public
    constructor create;
    destructor destroy;
    procedure cleardata;
    procedure addstage(stage:cstage);
    property stages[index:integer]: cStage read readstage;
  end;

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

  // ���� ��� ������/ ������ Bld �����
  cBldFileGen = class
  private
    mSensors:cSensorList; // ������ �������� ����������� �������
    mStages:cStageList;   // ������ ��������
  public
    mBldTitle:sBldtitle; // ������������ ���������� bld �����
    mData:array of sData;
    filename:string; // ������ ����� ���������� ������������ �����
    f:File;
    // �������� � ������� �������� ������ ������� � �������� bldFile
    // ������� ����� �� ������� �� �������
    //trends:array of cpoints;
  public
    procedure evalTicks;
    // �������� ��������� ���������� ���������� �� ������ �� �����
    function GetStageTaho(StageName:string):cSensor;
    // �������� ��������� ���������� ���������� �� ������ �� �����
    function GetSensor(name:string):cSensor;
    // �������� ������(� ������� �������� BldFile-�) ������� �� �����
    function GetSensorInd(name:string):integer;
    // �������� ������(� ������� �������� BldFile-�) ������� �� �����
    function GetSensorIndByChunNumber(ChunNumber:integer):integer;
    // ��������� �������� ����� ��������� �� �������
    function EvalSensorImpulsCount(name:string):integer;
    // ��������� ����� ��������� �� ������� ��� ��������� taholen*(����� �������)
    function QueekEvalSensorImpulsCount(taholen:integer;name:string):integer;
    // �������� ������ �� ������� ������� ����������� ������ � ��������
    function GetStage(sensorindex:integer):cstage;
    // �������� ������ �� ������� ������� ����������� ������ � ��������
    function GetStageByName(name:string):cstage;
    // ��� �������� � ���������� f ������������� ����
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
    // �������� ����� ��������� �� ������ � �������
    function GetSensorImpulsCount(sensorindex:integer):integer;
    // �������� ����� ��������
    function GetSensorsCount:integer;
    function ChunCount:integer;
  private
    function getSensorList:cSensorList;
    procedure setSensorList(sensorList:cSensorList);
    function getStageList:cStageList;
    procedure setStageList(stageList:cStageList);
  public
    property sensors:csensorlist read getSensorList write setSensorList;
    property stages:cStagelist read getStageList write setStageList;
  end;

  //�������� ������ ��������� BldFil-� �������� ��� f ��������� � ������ DATA
  //���������� ����� ���� ��� �������� � �������� ������� �����
  procedure UpdateTitleSize(var BldFile:cBldFileGen);

  const pi = 3.14159265;

  // ��������� ������������ ��� �������
  const c_root = 0;
  const c_edge = 1;
  const c_rot  = 4;
  const c_UTS  = 7;

implementation
uses ubldmath;

constructor cStage.create;
begin
  pairlist:=cpairlist.create;
end;

destructor cStage.destroy;
begin
  pairlist.destroy;
end;

constructor cStageList.create;
begin
  sorted:=true;
  m_cleardata:=true;
  Duplicates:=dupIgnore;
end;

destructor cStageList.destroy;
begin
  if m_cleardata then
    self.cleardata;
end;

function cStageList.readstage(index: Integer):cStage;
begin
  result:=cStage(objects[index]);
end;

procedure cStageList.cleardata;
var stage:cStage;
    i:integer;
begin
  for I := 0 to Count - 1 do
  begin
    Stage:=stages[i];
    stage.Destroy;
  end;
  clear;
end;

procedure cStageList.addstage(stage:cstage);
begin
  addObject(stage.name,stage);
end;

procedure UpdateTitleSize(var BldFile:cBldFileGen);
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

function cBldFileGen.GetSensorIndByChunNumber(ChunNumber:integer):integer;
var i,len:integer;
begin
  len:=mSensors.Count;
  for I := 0 to len - 1 do
  begin
    if mSensors.Count=chunNumber then
    begin
      result:=i;
      exit;
    end;
  end;
end;


constructor cBldFileGen.Create;
begin
  filename:='';
  msensors:=cSensorList.Create;
  mstages:=cStageList.Create;
end;

function cBldFileGen.getSensorList:cSensorList;
begin
  result:=msensors;
end;

procedure cBldFileGen.setSensorList(sensorList:cSensorList);
var i:integer;
begin
  msensors:=sensorList;
  setlength(trends, sensorList.Count);
  for I := 0 to sensorList.Count - 1 do
  begin
    if trends[i]=nil then
      trends[i]:=cpoints.create;
  end;
end;

function cBldFileGen.getStageList:cStageList;
begin
  result:=mstages;
end;

procedure cBldFileGen.setStageList(stageList:cStageList);
begin
  mstages:=stageList;
end;


// �������� ������ �� ������ ������� �� �����
function cBldFileGen.GetSensorInd(name:string):integer;
var i,len:integer;
begin
  result:=-1;
  len:=mSensors.count;
  for I := 0 to len - 1 do
  begin
    if mSensors.sensors[i].mChanName=name then
      result:=i;
  end;
end;

// �������� ������ �� ������� ������� ����������� ������ � ��������
function cBldFileGen.GetStageByName(name:string):cstage;
var i:integer;
begin
  for i:=0 to mstages.Count-1 do
  begin
    if name = mstages.stages[i].name then
    begin
      result:=mstages.stages[i];
      exit;
    end;
  end;
end;

// �������� ������ �� ������ �� �����
function cBldFileGen.GetSensor(name:string):cSensor;
var i,len:integer;
begin
  len:=mSensors.count;
  for I := 0 to len - 1 do
  begin
    if mSensors.sensors[i].mChanName=name then
      result:=mSensors.sensors[i];
  end;
end;

// �������� ������ ������� �� ������� ��������� ������ � ������� ��������
// ������ ������� �������� � �������� bld �����
function cBldFileGen.GetStage(sensorindex:integer):cstage;
var i:integer;
begin
  for I := 0 to mstages.Count - 1 do
  begin
    if mstages.stages[i].name=mSensors.sensors[sensorindex].stagename then
    begin
      result:=mstages.stages[i];
      exit;
    end;
  end;
end;

function cBldFileGen.GetSensorImpulsCount(sensorindex:integer):integer;
var stage:cstage;
begin
  stage:=getStage(sensorindex);
  if mSensors.sensors[sensorindex].mChanType=c_rot then
    result:=1
  else
    result:=stage.bladenumber;
end;

// ������� BldFile
destructor cBldFileGen.Destroy;
begin
  msensors.destroy;
  mstages.destroy;
  //if assigned(@f) then
  //  closefile(f);
end;

// ��������� ������ � ����
procedure cBldFileGen.Save;
    //�������� � ����  ������� �������
    procedure WriteSensor(const Sensor:cSensor);
    var lWritten,NameLen:integer;
    begin
      BlockWrite(f,sensor.mChanNumber,2,lWritten);       // ����� ������
      BlockWrite(f,sensor.mAmplifier,1,lWritten);        // �������� ������
      NameLen:=Length(sensor.mChanName);
      BlockWrite(f,NameLen,1,lWritten); // ����� �����
      BlockWrite(f,sensor.mChanName[1],NameLen,lWritten);//���
      BlockWrite(f,sensor.mChanType,2,lWritten);         //��� �������
    end;
    //�������� � ���� ���������
    procedure WriteTitle(const BldTitle:sBldTitle);
    var lWritten,i:integer;
        buf:word;
    begin
     BlockWrite(f,BldTitle.mTitle[1],6,lWritten);    // �������� ��������� RecBld
     BlockWrite(f,BldTitle.mTitleSize,4,lWritten);   // ������ ���������
     BlockWrite(f,BldTitle.mCardType,2,lWritten);    // ��� �����
     buf:=Chuncount;
     BlockWrite(f,buf,2,lWritten);  // ����� �������
     for i:=0 to buf-1 do WriteSensor(mSensors.sensors[i]);
     BlockWrite(f,BldTitle.mTestDate,8,lWritten);
     BlockWrite(f,BldTitle.mSamplingFreq,2,lWritten);
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
     WriteData(mData); // �������� ������ � ����
     CloseFile(f); // ������� ����
  end;
end;

// ��������������� � ������. ����� ����� ������ Save � Load ����� ��������
procedure cBldFileGen.GetFile(name:string);
begin
  filename:=name;
  AssignFile(f,name);
end;

// �������� ����� ��������
function cBldFileGen.GetSensorsCount:integer;
begin
  result:=mSensors.Count;
end;

// ��������� Bld ����
function cBldFileGen.Load:boolean;
  var lFileSize:integer;
  // ��������������� ��������� ��� ������ ���-�� ������
  procedure readSensor(var sensor:cSensor);
  var
    nameLen,i:byte;
    Ch:array of char;
    lReaded:cardinal;
  begin
    BlockRead(f,sensor.mChanNumber,2,lReaded);
    BlockRead(f,sensor.mAmplifier,1,lReaded);
    BlockRead(f,nameLen,1,lReaded);
    SetLength(Ch,namelen);SetLength(sensor.mChanName,namelen);
    BlockRead(f,Ch[0],nameLen,lReaded);
    for i := 1 to namelen do
      sensor.mChanName[i]:=Ch[i-1];
    BlockRead(f,sensor.mChanType,2,lReaded);
  end;
  // ��������� ��������� �����
  procedure ReadTitle(var Title:sBldTitle);
  var
    index,lReaded,i:integer;
    lTitle:array[0..6] of char;
    sensor:csensor;
    CountChun:word;
  begin
    SetLength(Title.mTitle,6);
    // ������� ������ ���������(6),��� �����(2) � ����� �������
    BlockRead(f,lTitle,6,lReaded);Title.mTitle:=lTitle;// ��������� RecBld
    if Title.mTitle<>'RecBld' then exit;
    BlockRead(f,Title.mTitleSize,4,lReaded);        // ������ ���������
    BlockRead(f,Title.mCardType,2,lReaded);         // ��� �����
    BlockRead(f,CountChun,2,lReaded);       // ����� �������
    for i:=0 to CountChun-1 do
    begin
      sensor:=cSensor.Create;
      readSensor(sensor);
      if not msensors.Find(inttostr(sensor.mChanNumber),index) then
        msensors.addobject(inttostr(sensor.mChanNumber),sensor);
    end;
    BlockRead(f,Title.mTestDate,8,lReaded);
    BlockRead(f,Title.mSamplingFreq,2,lReaded);
    SetLength(Title.mEmpty,Title.mTitleSize-FilePos(f));
    BlockRead(f,Title.mEmpty[0],Title.mTitleSize-FilePos(f),lReaded);
  end;
  procedure ReadData(var Data:array of sData);
  var i,lReaded,len:integer;
  begin
    len:=Length(Data);
    for I := 0 to len-1 do
    begin
      BlockRead(f,Data[i].mChan,1,lReaded);
      BlockRead(f,Data[i].mMarker,1,lReaded);
      BlockRead(f,Data[i].mTicks,4,lReaded);
    end;
  end;
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
    SetLength(mData,trunc((lFileSize-mBldTitle.mTitleSize)/6));
    ReadData(mData);
    // ������� ����
    CloseFile(f);
    // ���������� �����
    evalTicks;
  end;
end;
// �������� ��������� ���������� ���������� �� ���� ������ �� �����
function cBldFileGen.GetStageTaho(StageName:string):cSensor;
var
    i,len,tahoind:integer;
    li:tlistitem;
begin
  len:=getsensorscount;
  for i := 0 to len - 1 do
  begin
    if mSensors.sensors[i].mChanType=c_rot then
    begin
      if mSensors.sensors[i].stagename=stagename
        then
        begin
          tahoind:=i;
          break;
        end;
    end;
  end;
  result:=mSensors.sensors[i];
end;
// 
procedure cBldFileGen.Clear;
begin
  mSensors.cleardata;
  mstages.cleardata;
  setlength(mBldTitle.mEmpty,0);
  setlength(mData,0);
  mBldTitle.mEmpty:=nil;
  mData:=nil;
end;


// ��������� �������� ����� ��������� �� �������
function cBldFileGen.EvalSensorImpulsCount(name:string):integer;
var sensorind,i,len,count:integer;
begin
  sensorind:=getsensorind(name);
  len:=length(mData);
  count:=0;
  for I := 0 to len-1 do
  begin
    if (mdata[i].mchan=sensorind) then
    begin
      inc(count);
    end;
  end;
  result:=count;
end;

// ��������� ����� ��������� �� ������� ��� ��������� taholen*(����� �������)
function cBldFileGen.QueekEvalSensorImpulsCount(taholen:integer;name:string):integer;
var stage:cstage;
    sensor:cSensor;
begin
  sensor:=getsensor(name);
  stage:=getstagebyname(sensor.stagename);
  result:=stage.bladenumber*taholen;
end;

procedure cBldFileGen.evalTicks;
var i:integer;
begin
  setlength(trends,ChunCount);
  for I := 0 to ChunCount - 1 do
  begin
    trends[i]:=cpoints.Create;
    GetTicks(self,i,0,0,trends[i]);
  end;
end;

function cBldFileGen.ChunCount:integer;
begin
  result:=mSensors.Count;
end;


end.
