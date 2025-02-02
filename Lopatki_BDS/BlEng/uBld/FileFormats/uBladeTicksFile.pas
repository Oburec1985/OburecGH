unit uBladeTicksFile;

interface
uses
 Messages, controls, ComCtrls, classes, SysUtils, Windows,inifiles,
 uTickData, uSensor, uBaseObj, ubldeng, ubinfile, uLoadBldForm,
 uVectorlist, uchan, uSetList, uCommonMath, uTicks, uArrayTicks,
 uBldMath;

type
  cFile =  class
  public
    chan:integer;
    f:file;
  public
    constructor create(name:string ;read:boolean; p_chan:integer);
    destructor destroy;
  end;

  cBladeTicksFile = class
  private
    channels:cBaseObj;
    folder, m_name:string;
    fileList:TStringList;
  private
    // ���������� �����
    procedure ReleaseFiles;
    // ������� �����
    procedure Readfiles;
    // ������� ����� ��� ������ ������
    procedure Writefiles;
    // ����� � ���� � ������ name
    procedure ReadData(name:string;ticks:cbaseticks);overload;
    procedure ReadData(chan:cchan);overload;
    procedure ReadDataToArrayTicks(ticks:cArrayTicks; f:cfile);
    procedure WriteData(name:string;ticks:cbaseticks; t1,t2:integer);overload;
    procedure WriteData(chan:cchan;t1,t2:single);overload;
    // ����� ��������� ������
    procedure WriteHeader;
    // �������� ��������� ���� �� ������� ��� �����
    function getfile(i:integer):cFile;overload;
    function getfile(name:string):cFile;overload;
  public
    // ����, ����� � �������, ��� ���������
    constructor create(p_channels:cBaseObj;p_folder:string; name:string; read:boolean);
    destructor destroy;
    // ��������� ������ ���� �������� � �����
    procedure SavaSensorsData(t1,t2:single);
    // ������ ������
    procedure ReadSensorsData;
  end;

const
  c_ChannelsSection = 'Channels';

procedure SaveData(Folder:string;name:string; channels:cBaseObj; t1,t2:single);overload;
procedure SaveData(name:string; channels:cBaseObj; t1,t2:single);overload;

procedure ReadData(Folder:string;name:string; channels:cBaseObj);overload;
procedure ReadData(name:string; channels:cBaseObj);overload;

function CheckSDTFile(name:string):boolean;

implementation


constructor cFile.create(name:string; read:boolean; p_chan:integer);
begin
  chan:=p_chan;
  AssignFile(f,name);
  if read then
    Reset(f,1)
  else
    Rewrite(f,1);
end;

destructor cFile.destroy;
begin
  closefile(f);
end;

destructor cBladeTicksFile.destroy;
begin
  ReleaseFiles;
  fileList.Destroy;
end;

constructor cBladeTicksFile.create(p_channels:cBaseObj;p_folder:string; name:string; read:boolean);
begin
  fileList:=tStringList.Create;
  m_name:=name;
  fileList.Sorted:=true;
  channels:=p_channels;
  folder:=p_folder;
  if folder[length(folder)]<>'\' then
  begin
    folder:=folder+'\';
  end;
  // ������� ������� � �������
  if not DirectoryExists(folder) then
    ForceDirectories(p_folder);
end;

procedure cBladeTicksFile.ReleaseFiles;
var
  I: Integer;
  f:cfile;
begin
  // ���������� �����
  for I := 0 to fileList.Count - 1 do
  begin
    f:=GetFile(i);
    f.destroy;
  end;
  fileList.clear;
end;

procedure cBladeTicksFile.Writefiles;
var
  I, j: Integer;
  chan:cchan;
  f:cfile;
  str, name:string;
begin
  for I := 0 to channels.childCount - 1 do
  begin
    chan:=cchan(channels.getchild(i));
    name:=inttostr(chan.chan);
    str:=folder+name+'.dat';
    f:=getfile(name);
    if f=nil then
    begin
      f:=cfile.create(str, false, chan.chan);
      fileList.AddObject(name,f);
    end;
  end;
end;

procedure cBladeTicksFile.Readfiles;
var
  I, j, ind: Integer;
  chan:cchan;
  f:cfile;
  str, name:string;
  ini:tinifile;
  sections:tstringlist;
begin
  sections:=tstringlist.Create;
  ini:=tinifile.Create(folder+m_name);
  ini.ReadSection(c_ChannelsSection, sections);
  for I := 0 to sections.Count - 1 do
  begin
    str:=sections.Strings[i];
    j:=ini.ReadInteger(c_ChannelsSection,str,0);
    chan:=cchan(channels.findObj(@j,ind));
    if chan=nil then
    begin
      chan:=cchan.create;
      chan.chan:=j;
      channels.addchild(chan);
    end;
    name:=inttostr(chan.chan);
    str:=folder+name+'.dat';
    if (fileexists(str)) then
    begin
      f:=getfile(name);
      if f=nil then
      begin
        f:=cfile.create(str, true, chan.chan);
        fileList.AddObject(name,f);
      end;
    end;
  end;
  sections.Destroy;
  ini.Destroy;
end;

procedure cBladeTicksFile.ReadData(name:string;ticks:cbaseticks);
var
  f:cfile;
  I, len, readed: Integer;
  t:stickdata;
begin
  f:=getfile(name);
  len:=trunc(FileSize(f.f)/SizeOf(sTickData));
  ticks.clear;
  if ticks is csortedticks then
  // ����� ����� ���� ������ ������
  begin
    while len>0 do
    begin
      if len<=csortedticks(ticks).BldMemMng.m_BlockCapacity then
      begin
        blockread(f.f,csortedticks(ticks).BldMemMng.MemArray[csortedticks(ticks).BldMemMng.usedBlocks,0],
                                               len*SizeOf(sTickData),readed);
        for I := 0 to len - 1 do
        begin
          csortedticks(ticks).ticklist.AddObj(@csortedticks(ticks).BldMemMng.MemArray[csortedticks(ticks).BldMemMng.usedBlocks,i]);
        end;
        len:=0;
      end
      else
      begin
        blockread(f.f,csortedticks(ticks).BldMemMng.MemArray[csortedticks(ticks).BldMemMng.usedBlocks,0],
                    csortedticks(ticks).BldMemMng.m_BlockCapacity*SizeOf(sTickData),readed);
        csortedticks(ticks).BldMemMng.allocateblock;
        len:=len-csortedticks(ticks).BldMemMng.m_BlockCapacity;
        for I := 0 to csortedticks(ticks).BldMemMng.m_BlockCapacity - 1 do
        begin
          csortedticks(ticks).ticklist.AddObj(@csortedticks(ticks).BldMemMng.MemArray[csortedticks(ticks).BldMemMng.usedBlocks,i]);
        end;
      end;
    end;
  end;
  // ���� ���� cArrayTicks
  if ticks is cArrayTicks then
    ReadDataToArrayTicks(cArrayTicks(ticks), f);
end;

procedure cBladeTicksFile.ReadDataToArrayTicks(ticks:cArrayTicks; f:cfile);
var
  len, readed: Integer;
  t:stickdata;
begin
  len:=trunc(FileSize(f.f)/SizeOf(sTickData));
  // ����� ����� ���� ������ ������
  while len>0 do
  begin
    if len<=ticks.BldMemMng.m_BlockCapacity then
    begin
      blockread(f.f,ticks.BldMemMng.MemArray[ticks.BldMemMng.usedBlocks,0],
                                             len*SizeOf(sTickData),readed);
      ticks.BldMemMng.useditems:=len;
      len:=0;
    end
    else
    begin
      blockread(f.f,ticks.BldMemMng.MemArray[ticks.BldMemMng.usedBlocks,0],
                  ticks.BldMemMng.m_BlockCapacity*SizeOf(sTickData),readed);
      inc(ticks.BldMemMng.usedBlocks);
      ticks.BldMemMng.allocateblock;
      len:=len-ticks.BldMemMng.m_BlockCapacity;
      ticks.BldMemMng.useditems:=ticks.BldMemMng.useditems+
                                 ticks.BldMemMng.m_BlockCapacity;
    end;
  end;
end;

procedure cBladeTicksFile.ReadData(chan:cchan);
begin
  ReadData(inttostr(chan.chan), chan.ticks);
end;

procedure cBladeTicksFile.WriteData(chan:cchan;t1,t2:single);
var
  i1,i2:integer;
  tick:stickdata;
begin
  tick:=sectotick(t1);
  if chan.ticks.count<>0 then
  begin
    chan.ticks.GetLoTick(tick,i1);
    tick:=sectotick(t2);
    chan.ticks.GetHiTick(tick,i2);
    WriteData(inttostr(chan.chan),chan.ticks,i1,i2);
  end;
end;

procedure cBladeTicksFile.WriteHeader;
var
  iFile:tinifile;
  name:string;
  len:integer;
  I: Integer;
  chan:cchan;
begin
  len:=length(folder);
  if folder[len]='\' then
  begin
    name:=folder;
    setlength(name,len-1);
    name:=extractfilename(name);
  end;
  iFile:=tinifile.Create(folder+name+'.sdt');
  for I := 0 to channels.childCount - 1 do
  begin
    chan:=cchan(channels.getchild(i));
    name:='Chan_'+inttostr(i);
    iFile.WriteInteger(c_ChannelsSection,name,chan.chan);
  end;
  iFile.Destroy;
end;

procedure cBladeTicksFile.WriteData(name:string;ticks:cbaseticks; t1,t2:integer);
var
  startblock, startind,
  EndBlock, EndInd, endInBlock,
  I, len: Integer;
  t:stickdata;
  f:cFile;
begin
  if ticks is cSortedTicks then
  // ����� ����� ���� ������ ������
  begin
    if t2>0 then
    begin
      startind:=cSortedTicks(ticks).BldMemMng.GetBlockIndex(t1, startblock);
      EndInd:=cSortedTicks(ticks).BldMemMng.GetBlockIndex(t2, EndBlock);
    end
    else
    begin
      t1:=0;
      t2:=cSortedTicks(ticks).count-1;
    end;
    for i := startblock to EndBlock do
    begin
      if i<>EndBlock then
        len:=cSortedTicks(ticks).BldMemMng.m_BlockCapacity - startind
      else
      begin
        if i=endblock then
          endInBlock:=EndInd
        else
          endInBlock:=cSortedTicks(ticks).BldMemMng.m_BlockCapacity;
        len:=endInBlock - startind;
      end;
      // ����� ������ � ����
      f:=getfile(name);
      if f<>nil then
        BlockWrite(f.f,cSortedTicks(ticks).BldMemMng.MemArray[i,startind],sizeof(stickdata)*len);
    end;
  end
  else
  // ���� ������ ��� ����� ���������� ���������� ����������
  begin
    if t2>0 then
    begin
      startind:=cArrayTicks(ticks).BldMemMng.GetBlockIndex(t1, startblock);
      EndInd:=cArrayTicks(ticks).BldMemMng.GetBlockIndex(t2, EndBlock);
    end
    else
    begin
      t1:=0;
      t2:=cArrayTicks(ticks).count-1;
    end;
    for i := startblock to EndBlock do
    begin
      if i<>EndBlock then
        len:=cArrayTicks(ticks).BldMemMng.m_BlockCapacity - startind
      else
      begin
        if i=endblock then
          endInBlock:=EndInd
        else
          endInBlock:=cArrayTicks(ticks).BldMemMng.m_BlockCapacity;
        len:=endInBlock - startind;
      end;
      // ����� ������ � ����
      f:=getfile(name);
      if f<>nil then
        BlockWrite(f.f,cArrayTicks(ticks).BldMemMng.MemArray[i,startind],sizeof(stickdata)*len);
      startind:=0;
    end;
  end;
end;

function cBladeTicksFile.getfile(i:integer):cFile;
begin
  result:=cFile(filelist.Objects[i]);
end;

function cBladeTicksFile.getfile(name:string):cFile;
var
  i:integer;
begin
  result:=nil;
  if filelist.find(name,i) then
  begin
    result:=getFile(i);
  end;
end;

procedure cBladeTicksFile.SavaSensorsData(t1,t2:single);
var
  I: Integer;
  chan:cchan;
begin
  WriteFiles;
  WriteHeader;
  for I := 0 to channels.ChildCount - 1 do
  begin
    chan:=cchan(channels.getchild(i));
    WriteData(chan, t1,t2);
  end;
end;

procedure cBladeTicksFile.ReadSensorsData;
var
  I, ind: Integer;
  chan:cchan;
  f:cfile;
begin
  // ������� ����� ��� ������ ������
  Readfiles;
  for I := 0 to fileList.count - 1 do
  begin
    f:=getfile(i);
    chan:=cchan(channels.findobj(@f.chan, ind));
    ReadData(chan);
  end;
end;


procedure SaveData(name:string; channels:cBaseObj; t1,t2:single);
var
  fname,folder:string;
begin
  fname:=extractfilename(name);
  folder:=extractfiledir(name);
  SaveData(Folder,fname,channels,t1,t2);
end;


procedure SaveData(Folder:string;name:string; channels:cBaseObj; t1,t2:single);
var
  f:cBladeTicksFile;
begin
  f:=cBladeTicksFile.create(channels,folder,name, false);
  f.SavaSensorsData(t1,t2);
  f.destroy;
end;

procedure ReadData(name:string; channels:cBaseObj);
var
  fname,folder:string;
begin
  fname:=extractfilename(name);
  folder:=extractfiledir(name);
  ReadData(Folder,fname,channels);
end;


procedure ReadData(Folder:string;name:string; channels:cBaseObj);
var
  f:cBladeTicksFile;
begin
  f:=cBladeTicksFile.create(channels,folder,name, true);
  f.ReadSensorsData;
  f.destroy;
end;

function CheckSDTFile(name:string):boolean;
var
  i, num:integer;
  f:tinifile;
  slist:tstringlist;
  l_name, folder:string;
begin
  result:=false;
  folder:=ExtractFileDir(name);
  f:=TIniFile.Create(name);
  slist:=tstringlist.Create;
  f.ReadSectionValues(c_ChannelsSection,slist);
  for I := 0 to slist.Count - 1 do
  begin
    num:=f.ReadInteger(c_ChannelsSection,slist.Strings[i],0);
    l_name:=folder+'\'+inttostr(num)+'.dat';
    if not fileexists(l_name) then
    begin
      slist.destroy;
      f.destroy;
      exit;
    end;
  end;
  slist.destroy;
  f.destroy;
  result:=true;
end;


end.
