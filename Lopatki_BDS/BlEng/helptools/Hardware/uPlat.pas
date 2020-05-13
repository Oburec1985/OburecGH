unit uPlat;

interface
uses
  MxxxxAPI, MxxxxTypes, Types4Bld, inifiles, SysUtils, classes, uBaseObjMng,
  uBaseObj, uBldObj, uBaseObjTypes, controls, ubldeng, ubldtimeproc,
  uTagOwnerObj, uTag, ubldEngEventTypes, uBldGlobalStrings, uTagUtils, NativeXML, utickdata,
  udatathread;

type

  cPlat = class(cTagOwnerObj)
  private
   //��� ������������ ����� ������ ������ ����� � ������
   // -������ ������, ������� ���� ������, � �������� FIFO ������ NFrame ����� �������
   // 126, 255,510,1023,2046,4095, 6141
    fBufferSize:cardinal;
  public
    // ������ �� �������� ����� ������
    Thread:cDataThread;
    // ������ � ������ ������� ASyncData (������� ������ � ����� � �������
    // byte, byte, cardinal (chan, marker, ticktime))
    ASyncData:array of byte;
    // ����� �������������������
    finit:boolean;
    // ������� ������
    freq:double;
    // ���� �������� �����
    m_inipath:ansistring;
    // ����� �������
    fChanCount:cardinal;
    // ���� �� �������
    digTags:array of cvectortag;
    fDataMode:integer;
    id:cardinal;
    // ��������� ����� ��� ��������� ����� �� �����. ������������ � ��������� DataHandler
    // ��� �������������� ������ �� ������� ����� � ������ ������
    buffTicksData:array of stickdata;
  protected
    function getengine:cbldeng;override;
    // ������������������� �����
    procedure init(inipath:ansistring; devinfo:TDevice);virtual;
    // ������������ �������� �����. �������� ����� ������� ����� ������
    procedure Config;virtual;abstract;
    procedure SetBufferSize(size:cardinal);virtual;
    procedure createTags;override;
    // ��������� ���������� � ����� ��� ��������� ������ � ��������
    procedure SyncGetData;virtual;
    // ��������� ���������� � ����� ��� ��������� ������ � ��������
    procedure ASyncGetData;virtual;
    procedure ConfigASync;virtual;abstract;
    procedure StopASync;virtual;abstract;
    procedure setperiod(v:cardinal);
    function getperiod:cardinal;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);override;
    procedure SaveObjAttributes(xmlNode:txmlNode);override;
    procedure SetDataMode(v:integer);virtual;
    procedure ConvertDataToEngine(size:cardinal);virtual;abstract;
    // ������� ����
    procedure LinkThread;virtual;
  public
    destructor destroy;override;
    property BufferSize:cardinal read fBufferSize write SetBufferSize;
    property Period:cardinal read getPeriod write SetPeriod;
    property DataMode:integer read fDataMode write SetDataMode;
    constructor create;override;
    // ���������� ����� ������
    procedure Stop;virtual;
    // �������� ����� ������ (������)
    procedure GetData;virtual;abstract;
  end;

  cPlatsList = class(cBaseObjMng)
  public
    eng:cbldeng;
    //���������, ����������� ��������� � ������� �� ����������
    pFoundDevs : TDeviceEnum;
  protected
    procedure regObjClasses;override;
  public
    function getplat(i:integer):cplat;overload;
    function getplat(name:string):cplat;overload;
    procedure OnTagSetActive(sender:tobject);
    // ����� ������������ ����
    procedure Search;
    procedure play;
    procedure stop;
  end;

const
  // 126, 255,510,1023,2046,4095, 6141
  // ��������� ������ �������
  c_DefaultTime = 300;
  c_BuffSize = 1023;
  c_FrameCount = 10;
  c_s2081 = 'M2081';
  c_s2070 = 'M2070';
  c_OscMode = 1;
  c_ASyncMode = 2;
  // ��������
  c_play = 1;
  c_pause = 0;
  c_Delete = 2;

procedure LoadFromFile(FileName:AnsiString;var Size:Cardinal;Buff:pByteArray);

implementation
uses
  u2070, u2081;

function cplat.getengine:cbldeng;
var
  platlist:cplatslist;
begin
  platlist:=cplatslist(getMng);
  result:=nil;
  if getMng<>nil then
  begin
    if platlist.eng<>nil then
    begin
      result:=platlist.eng;
    end;
  end;
end;

procedure LoadFromFile(FileName:AnsiString;var Size:Cardinal;Buff:pByteArray);
var
  f:File;
  llength:Cardinal;
begin
  AssignFile(f,FileName);
  Reset(f, 1);
  llength:= FileSize(f);
  GetMem(Buff,llength);
  BlockRead(f,Buff,llength);
  Close(f);
  Size:=llength;
end;

function checkName(name1:array of ansichar; name2:ansistring):boolean;
var
  I: Integer;
begin
  result:=true;
  for I := 0 to length(name2)-1 do
  begin
    if name1[i]<>name2[i+1] then
    begin
      result:=false;
      exit;
    end;
  end;
end;

procedure cPlatsList.regObjClasses;
begin
  inherited;
  regclass(cM2070);
  regclass(cM2081);
end;

procedure cPlatsList.OnTagSetActive(sender:tobject);
begin
  if cBaseTag(sender).active then
  begin
    cbldtimeproc(eng.timeProc).ftagmng.Add(cBaseTag(sender));
  end
  else
  begin
    cbldtimeproc(eng.timeProc).ftagmng.removeObj(cBaseTag(sender));
  end;
  eng.Events.CallAllEventsWithSender(e_OnAddRemoveTag,cBaseTag(sender));
end;

procedure cPlatsList.Search;
var
  I: Integer;
  plat:cPlat;
  res:cardinal;
  path,section:ansistring;
begin
  SearchDevicesEx(@pFoundDevs);
  if pFoundDevs.nFoundDevs>0 then
  begin
    for I := 0 to pFoundDevs.nFoundDevs - 1 do
    begin
      if checkName(pFoundDevs.DevInfo[i].DeviceName,c_s2070) then
      begin
        Plat:=cM2070.create;
      end
      else
      begin
        if checkName(pFoundDevs.DevInfo[i].DeviceName,c_s2081) then
        begin
          Plat:=cM2081.create;
        end;
      end;
      Add(Plat, nil);
      Plat.id:=count;
      path:=eng.PathMng.findCfgPathFile('M2070.INI');
      plat.init(path, pFoundDevs.DevInfo[i]);
      plat.createTags;
      // �������� ������ ������
      plat.LinkThread;
    end;
  end;
end;

procedure cPlatsList.play;
var
  I: Integer;
  plat:cplat;
begin
  for I := 0 to count - 1 do
  begin
    plat:=getplat(i);
    if plat.DataMode=c_OscMode then
    begin
      //plat.Oscillograph;
    end
    else
    begin
      //plat.ASyncGetData;
    end;
  end;
end;

procedure cPlatsList.stop;
var
  I: Integer;
  plat:cplat;
begin
  for I := 0 to count - 1 do
  begin
    plat:=getplat(i);
    plat.stop;
  end;
end;

function cPlatsList.getplat(i:integer):cplat;
begin
  result:=cplat(getobj(i));
end;

function cPlatsList.getplat(name:string):cplat;
begin
  result:=cplat(getobj(name));
end;

constructor cPlat.create;
begin
  inherited;
  // ����� ���������������
  autocreate:=true;
  DataMode:=c_OscMode;
  finit:=false;
  helper:=false;
  imageindex:=c_Hardware_img;
  blocked:=false;
end;

destructor cPlat.destroy;
begin
  inherited;
end;

procedure cPlat.init(inipath:ansistring; devinfo:TDevice);
begin
  m_inipath:=inipath;
end;

procedure cPlat.SetBufferSize(size:cardinal);
begin
  fBufferSize:=size;
end;


procedure cPlat.setperiod(v:cardinal);
begin
  Thread.period:=v;
end;

function cPlat.getperiod:cardinal;
begin
  result:=Thread.period;
end;

procedure cPlat.createTags;
var
  I: Integer;
  tag:cbaseTag;
begin
  if fchancount<>0 then
  begin
    setlength(digTags,fchancount);
    for I := 0 to fchancount - 1 do
    begin
      tag:=cvectortag.create;
      digTags[i]:=cvectortag(tag);
      tag.OnSetActive:=cPlatsList(getmng).OnTagSetActive;
      tag.name:=Name+'_'+inttostr(i);
      tag.dsc:=v_OscTagDsc;
      tag.blocked:=true;
      tags.addobj(tag);
      if finit then
        tag.active:=true;
    end;
  end;
  for I := 0 to tags.Count - 1 do
  begin
    tag:=gettag(i);
    tag.source:=self;
  end;
  BufferSize:=c_BuffSize;
end;

procedure cPlat.Stop;
begin
  if DataMode=c_OscMode then
  begin
    //thread.stop
  end
  else
  begin
    StopASync;
  end;
end;

procedure cPlat.ASyncGetData;
begin
  ConfigASync;
end;

procedure cPlat.SyncGetData;
var
  I: Integer;
  tag:cbasetag;
begin
  getdata;
  for I := 0 to tags.count - 1 do
  begin
    tag:=gettag(i);
    if tag.DrawObj<>nil then
      TagToDrawObj(tag.DrawObj,tag,nil);
  end;
end;

procedure cPlat.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
var
  i:integer;
  tagNode:txmlnode;
  str:string;
  tag:cbasetag;
begin
  inherited;
  DataMode:=xmlNode.ReadAttributeInteger('DataMode',c_OscMode);
  for I := 0 to tags.count - 1 do
  begin
    tagnode:=xmlNode.Nodes[i];
    if tagnode<>nil then
    begin
      str:=tagnode.Name;
      tag:=cbasetag(tags.getobj(str));
      if tag<>nil then
      begin
        // ���������� � false �� ������ ���� ��� ���������� ������� ��� �������� ���������
        tag.active:=false;
        tag.active:=true;
        tag.opts:=tagnode.ReadAttributeString('DrawObj');
      end;
    end;
  end;
end;

procedure cPlat.SetDataMode(v:integer);
begin
  fDataMode:=v;
end;

procedure cPlat.SaveObjAttributes(xmlNode:txmlNode);
var
  i:integer;
  str:string;
  tag:cbasetag;
  tagNode:txmlnode;
begin
  inherited;
  xmlNode.WriteAttributeInteger('DataMode', DataMode);
  for I := 0 to tags.count - 1 do
  begin
    tag:=cbasetag(tags.getobj(i));
    if tag.active then
    begin
      tagnode:=xmlNode.NodeNew(tag.name);
      if tag.DrawObj<>nil then
        tagnode.WriteAttributeString('DrawObj',tag.DrawObj.name);
    end;
  end;
end;

procedure cPlat.LinkThread;
begin
end;

end.
