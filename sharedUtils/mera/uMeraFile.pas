unit uMeraFile;

interface
uses
  Messages,
  dialogs,
  controls,
  ComCtrls,
  classes,
  SysUtils,
  Windows,
  ubinfile,
  uCommonTypes,
  uCommonMath,
  uVectorlist,
  uSetList,
  inifiles,
  uMeraSignal;

  type

  cSignalClass = class of cSignal;


  TMeraOpts = record
    // имя испытания
    TestName:string;
    // описание испытания
    TestDsc:string;
    // частота оцифровки исходного сигнала
    freq:single;
  end;

  cMeraFile = class
  public
    // список сохраняемых сигналов
    // сигналы должны быть потомками cBaseObj
    signals:tstringlist;
  public
    signalClass:cSignalClass;
  protected
    opts:TMeraOpts;
    // имя файла
    dir,name:string;
    // сигнал СЕВ
    fUts:csignal;
    owner:boolean;
  protected
    procedure LoadSignalHeader(f:tinifile);
    procedure SaveSignalHeader(signal:cSignal; f:tinifile);
    procedure SaveTrend(signal:cSignal);
    procedure ModNames;
  public
    procedure Save;overload;
    procedure Save(p_name:string);overload;
    procedure Load(p_name:string);
    procedure LoadSignal(signal:cSignal);
    function GetSignal(name:string):csignal;overload;
    function GetSignal(i:integer):csignal;overload;
    // создает для чтения
    constructor create(p_filename:string; folder:string; p_signals:tstringlist; meraopts:tmeraopts; uts:csignal);overload;
    // создает для чтения
    constructor create(p_filename:string; p_SignalsClass:cSignalClass);overload;
    // создать для записи
    constructor create(p_filename:string);overload;
    //destructor destroy;
    procedure DestroySignals;
    procedure clear;
    procedure Add(s:csignal);
    function count:integer;
    destructor destroy;
  end;

// сшивает 2 мера файла
procedure ConnectFiles(f1, f2, res:string; blSize:cardinal; start2:double; errorLog:tstringlist; abstime:boolean);
function signalLength(fname, chan:string):double;
procedure GetSignalList(fname:string; signallist:tstringlist);overload;
procedure GetSignalList(f:tinifile; signallist:tstringlist);overload;

implementation

const
  c_mainSection = 'Mera';
  c_TestName = 'Test';
  c_Info = 'Info';
  c_Time = 'Time';
  c_Prod = 'Prod';
  c_freq = 'Freq';
  c_XUnits = 'XUnits';
  c_YUnits = 'YUnits';
  c_CharTP = 'c_CharTP';
  c_k0 ='k0';
  c_k1 ='k1';
  c_YFormat = 'YFormat';
  c_XFormat = 'XFormat';
  c_ChanID = 'ChanID';
  c_ChanNo = 'ChanNо';
  c_Start = 'Start';
  c_Z = 'ZSize';
  c_Zstep = 'ZStep';

procedure cMeraFile.ModNames;
var
  i:integer;
begin
  name:=LowerCase(name);
  if pos('.mera', name)>0 then
  begin
    dir:=extractfiledir(name)+'\';
    name:=extractfilename(name);
  end
  else
  begin
    for I := length(dir) downto 1 do
    begin
      if dir[i]='\' then
      begin
        name:=copy(dir,i+1,length(dir)-i)+'.mera';
        break;
      end;
    end;
    dir:=dir+'\';
  end;
end;

constructor cMeraFile.create(p_filename:string; p_SignalsClass:cSignalClass);
begin
  owner:=false;
  dir:=extractfiledir(p_filename);
  name:=p_filename;
  Signals:=TStringList.Create;
  Signals.Sorted:=true;
  signalClass:=P_SignalsClass;
  if fileexists(p_filename) then
  begin
    Load(p_filename);
  end;
end;

constructor cMeraFile.create(p_filename:string);
begin
  owner:=false;
  dir:=extractfiledir(p_filename)+'\';
  name:=extractfilename(p_filename);
  Signals:=TStringList.Create;
  Signals.Sorted:=true;
end;

constructor cMeraFile.create(p_filename:string; folder:string;p_signals:tstringlist; meraopts:tmeraopts; uts:csignal);
begin
  owner:=false;
  dir:=folder;
  name:=p_filename;
  // список сохраняемых сигналов
  signals:=p_signals;
  // опции mera файла (частота дискретизации, описание испытания, имя испытания)
  opts:=meraopts;
  modnames;
  fUts:=uts;
end;

procedure cMeraFile.Save(p_name:string);
begin
  name:=p_name;
  modnames;
  Save;
end;

procedure cMeraFile.Save;
var
  f:tinifile;
  date:tdatetime;
  datestr:string;
  i:integer;
begin
  if not DirectoryExists(dir) then
    ForceDirectories(dir);
  f:=tinifile.Create(dir+name);
  // имя испытания
  f.WriteString(c_mainSection, c_TestName, opts.TestName);
  // Описание испытания
  f.WriteString(c_mainSection, c_Info, opts.TestDsc);
  // Время испытания
  date:=now;
  datestr:=DateToStr(date)+' '+TimeToStr(date);
  f.WriteString(c_mainSection, c_Time, datestr);
  for I := 0 to signals.Count - 1 do
  begin
    // сохранить заголовочную информацию
    SaveSignalHeader(cSignal(signals.objects[i]),f);
    // сохранить данные
    SaveTrend(cSignal(signals.objects[i]));
  end;
  if fUts<>nil then
  begin
    // сохранить заголовочную информацию
    SaveSignalHeader(fUts,f);
    // сохранить СЕВ
    SaveTrend(futs);
  end;
    //SaveSignalToHeader(futs,f);
  f.Destroy;
end;

function ReadFloat(f:tinifile;section, key:string):double;
var
  str:string;
  j:integer;
begin
  str:=floattostr(readFloatFromIni(f, section, key));
  j:=pos('.',str);
  if j>0 then
  begin
    if DecimalSeparator<>'.' then
    begin
      str[j]:=',';
    end;
  end;
  result:=strtofloat(str);
end;

procedure cMeraFile.LoadSignalHeader(f:tinifile);
var
  sections:tstringlist;
  i,j, ind:integer;
  s:cSignal;
  str, sname:string;

  prtlist:tstringlist;
begin
  prtlist:=tstringlist.Create;
  sections:=tstringlist.Create;
  f.ReadSections(sections);
  for I := 1 to sections.Count - 1 do
  begin
    s:=signalClass.create;
    str:=sections.Strings[i];
    s.DataType:=f.ReadString(str, 'YFormat', '');
    s.DataType:=LowerCase(s.datatype);
    // пишем имя сигнала
    sname:=sections.Strings[i];
    s.name:=sections.Strings[i];
    s.k1:=ReadFloat(f, sname, 'k1');
    s.k0:=ReadFloat(f, sname, 'k0');
    s.freqx:=ReadFloat(f,sname,c_freq);
    // Подпись оси x
    s.xunits:=f.ReadString(sname, c_XUnits, '');
    // Подпись оси Y
    s.yunits:=f.ReadString(sname, c_YUnits, '');
    if signals=nil then
    begin
      signals:=tstringlist.Create;
      owner:=true;
    end;
    str:=dir+sname+'.prt';
    if FileExists(str) then
    begin
      prtlist.Clear;
      prtlist.LoadFromFile(str);
      if prtlist.Count>1 then
      begin
        setlength(s.prt,prtlist.Count);
        for j := 0 to prtlist.Count - 1 do
        begin
          // src:string;tabs:string;p:integer;var index:integer)
          str:=GetSubString(prtlist.Strings[j],' ',1,ind);
          s.prt[i].t:=strtoFloatExt(str);
          str:=GetSubString(prtlist.Strings[j],' ',ind+1,ind);
          s.prt[i].i:=strtoint(str);
        end;
      end;
    end;
    signals.AddObject(sname, s);
  end;
  prtlist.Destroy;
end;

procedure writeWPFloat(f:tinifile;section:string; key:string; v:double);
var
  str:string;
begin
  str:=floattostr(v);
  str:=replaceChar(str, ',', '.');
  f.WriteString(section, key, str);
end;

procedure cMeraFile.SaveSignalHeader(signal:cSignal; f:tinifile);
var
  t:extended;
  str:string;
begin
  if signal.WriteXY then
  begin
    // пишем имя сигнала
    f.WriteString(signal.getname, 'XFile', signal.getname + '.x');
  end;
  // пишем имя сигнала
  f.WriteFloat(signal.getname, c_freq, signal.freqx);
  // Подпись оси x
  f.WriteString(signal.getname, c_XUnits, signal.xunits);
  // Подпись оси Y
  f.WriteString(signal.getname, c_YUnits, signal.yunits);
  if signal.VType=c_float then
    str:='R4'
  else
    str:='R8';
  f.WriteString(signal.getname, c_XFormat, str);
  // формат Y
  f.WriteString(signal.getname, c_YFormat, str);
  // k0
  writeWPFloat(f,signal.getname,c_k0,signal.k0);
  // k1
  writeWPFloat(f,signal.getname,c_k1,signal.k1);
  // Freq
  writeWPFloat(f,signal.getname,c_freq,signal.freqx);
  // x0
  writeWPFloat(f,signal.getname,'Start',signal.x0);
  // СЕВ
  if (fUTS<>nil) and (signal<>fUTS) then
  begin
    f.WriteString(signal.getname, 'UTS_Channel', fUTS.getname);
  end;
  if signal.b_3d then
  begin
    f.WriteInteger(signal.getname,c_Z , round(signal.count/ signal.portionsize));
    f.WriteInteger(signal.getname,c_Zstep , signal.dZ);
  end
  else
    f.WriteInteger(signal.getname, c_Zstep, 0);
end;

procedure cMeraFile.LoadSignal(signal:cSignal);
begin
  if dir[length(dir)]<>'\' then
  begin
    dir:=dir+'\';
  end;
  signal.loadSignal(dir+signal.getname);
end;

procedure cMeraFile.SaveTrend(signal:cSignal);
var
  f,fx:file;
  i:integer;
  dt:double;
  p2d:point2d;
  p2:point2;
begin
  AssignFile(f,dir+signal.getname+'.dat');
  Rewrite(f,1);
  if signal.WriteXY then
  begin
    AssignFile(fx,dir+signal.getname+'.x');
    Rewrite(fx,1);
  end;
  if signal.Count<1 then exit;
  dt:=1/signal.freqX;
  if signal.WriteXY or signal.b_3d then
  begin
    // если сигнал сплайновый то пишем с частотой дискретизации указанной в файле
    for I := 0 to signal.count - 1 do
    begin
      if signal.VType=c_float then
      begin
        p2:=signal.GetP2(i);
        WriteSingle(f,p2.y);
        if not signal.b_3d then
          WriteSingle(fx,P2.x);
      end
      else
      begin
        p2d:=signal.GetP2d(i);
        WriteDouble(f,p2d.y);
        if not signal.b_3d then
          WriteDouble(fx,p2d.x);
      end;
    end;
  end
  else
  begin
    signal.SaveData(f);
  end;
  // Длина одной записываемой единицы.
  CloseFile(f); // Закрыть файл
  if signal.WriteXY then
  begin
    CloseFile(fx);
  end;
end;

procedure cMeraFile.DestroySignals;
var
  I: Integer;
  s:csignal;
begin
  for I := 0 to signals.Count - 1 do
  begin
    s:=csignal(signals.Objects[i]);
    s.Destroy;
  end;
  if fUts<>nil then
    fUTS.Destroy;
  signals.clear;
end;

procedure cMeraFile.Load(p_name:string);
var
  f:tinifile;
  datestr:string;
  i:integer;
  s:csignal;
begin
  name:=p_name;
  modnames;
  f:=tinifile.Create(p_name);
  // имя испытания
  opts.TestName:=f.ReadString(c_mainSection, c_TestName, '');
  // Описание испытания
  opts.TestDsc:=f.ReadString(c_mainSection, c_Info, '');
  datestr:=f.ReadString(c_mainSection, c_Time, '');
  // сохранить заголовочную информацию
  LoadSignalHeader(f);
  for I := 0 to Count - 1 do
  begin
    s:=GetSignal(i);
    LoadSignal(s);
  end;
end;

function cMeraFile.GetSignal(name:string):csignal;
var
  i:integer;
begin
  result:=nil;
  if signals.Find(name,i) then
  begin
    result:=csignal(signals.Objects[i]);
  end;
end;

function cMeraFile.GetSignal(i:integer):csignal;
begin
  result:=csignal(signals.Objects[i]);
end;

procedure cMeraFile.clear;
var
  I: Integer;
  s:csignal;
begin
  if signals<>nil then
  begin
    for I := 0 to signals.Count - 1 do
    begin
      s:=csignal(signals.objects[i]);
      s.destroy;
    end;
    signals.clear;
  end;
end;

procedure cMeraFile.Add(s:csignal);
begin
  if signals=nil then
  begin
    signals:=TStringList.Create;
    signals.Sorted:=true;
    owner:=true;
  end;
  signals.AddObject(s.name,s);
end;

function cMeraFile.count:integer;
begin
  result:=signals.Count;
end;

destructor cMeraFile.destroy;
begin
  if owner then
  begin
    signals.destroy;
  end;
  inherited;
end;

procedure ConnectFiles(f1, f2, res:string; blSize:cardinal; start2:double; errorLog:tstringlist; abstime:boolean);
var
  lf1, lf2:file;
  buff:array of byte;
  slist:tstringlist;

  m1,m2:tinifile;
  size, i, j, k, blockcount, read, ind:integer;
  fsize, fsize1, lsize, datasize:cardinal;
  lbool:longbool;

  str,Namepath,str2,dataType, dir1, dir2 , s1, s2, prtstr:string;
  st1,st2, len1, freq1, freq2, start:double;

  prtlist1,prtlist2:tstringlist;
  prt2:array of tSignalPrt;

  date1,date2:tdatetime;
begin
  if not fileexists(f1) then
  begin
    errorlog.Add('Файл отсутствует: '+f1);
    errorlog.Add('Расчет прерван');
    exit;
  end;

  if not fileexists(f2) then
  begin
    errorlog.Add('Файл отсутствует: '+f2);
    errorlog.Add('Расчет прерван');
    exit;
  end;

  dir1:=extractfiledir(f1)+'\';
  dir2:=extractfiledir(f2)+'\';

  // создание переменных
  if errorLog=nil then
    errorLog:=tstringlist.Create;
  slist:=tstringlist.Create;
  slist.Sorted:=true;
  m1:=TIniFile.Create(f1);
  m2:=TIniFile.Create(f2);
  // обработка
  m1.ReadSections(slist);

  prtlist1:=tstringlist.Create;
  prtlist2:=tstringlist.Create;

  setlength(buff, blSize);
  for I := 0 to slist.Count - 1 do
  begin
    str:=slist.Strings[i];
    // если во втором файде есть секция с таким каналом то сшиваем каналы
    if not m2.SectionExists(str) then
    begin
      if lowercase(str)<>'mera' then
      begin
        errorlog.Add('Канал '+ str + ' не найден');
        continue;
      end;
    end;
    // проверка длины сигналов
    len1:=signalLength(f1, str);
    if len1>start2 then
    begin
      errorlog.Add('Длина сигнала '+str+' в первом файле ' +
                    floattostr(len1) + ' '+
                   'больше чем время отступа ' + floattostr(start2));
      errorlog.Add('Расчет прерван');
      exit;
    end;

    datatype:=LowerCase(m1.ReadString(str, 'YFormat', ''));
    if datatype='' then continue;
    str2:=m1.ReadString(str, 'freq', '1');
    freq1:=strtoFloatExt(str2);
    str2:=m2.ReadString(str, 'freq', '1');
    freq2:=strtofloatext(str2);
    if freq1<>freq2 then
    begin
      errorlog.Add('Канал '+ str + ' записан с разной частотой дискретизации');
      continue;
    end;

    if datatype<>LowerCase(m2.ReadString(str, 'YFormat', '')) then
    begin
      errorlog.Add('Канал '+ str + ' записан в разных форматах');
      continue;
    end;

    datasize:=SignalFormatToDataSize(datatype);


    s1:=dir1+str+'.dat';
    s2:=dir2+str+'.dat';
    if not fileexists(s1) then
    begin
      errorlog.Add('Канал '+ s1 + ' отсутствует');
      continue;
    end;
    if not fileexists(s2) then
    begin
      errorlog.Add('Канал '+ s2 + ' отсутствует');
      continue;
    end;
    for k := length(res) downto 1 do
    begin
      if res[k]='.' then
      begin
        Namepath:=res;
        setlength(Namepath,k-1);
        break;
      end;
    end;

    str2:=extractfiledir(res)+'\'+str+'.dat';
    if not DirectoryExists(extractfiledir(res)) then
    begin
      ForceDirectories(extractfiledir(res));
    end;

    CopyFile(pwidechar(@s1[1]),pwidechar(@str2[1]),lbool);

    AssignFile(lf1,str2);
    reset(lf1,1);

    AssignFile(lf2,s2);
    reset(lf2,1);

    fsize:=FileSize(lf2);
    if fsize=0 then
      continue;

    blockcount:=trunc(fsize/blsize);
    inc(blockcount);
    size:=filesize(lf1);
    fsize1:=size;
    seek(lf1, size);
    lsize:=fsize;
    size:=blsize;
    // читаем и пишем куски сигнала
    for j := 0 to blockCount - 1 do
    begin
      if j=blockCount - 1 then
      begin
        size:=lsize;
      end
      else
      begin
        lsize:=lsize-blSize;
      end;
      blockread(lf2, buff[0], size, read);
      BlockWrite(lf1, buff[0], size, read);
    end;

    closefile(lf1);
    closefile(lf2);

    // пишем разделы

    str2:=m1.ReadString(str, 'Start', '0');
    st1:=strtoFloatExt(str2);

    str2:=m2.ReadString(str, 'Start', '0');
    st2:=strtoFloatExt(str2);

    s1:=dir1+str+'.prt';
    s2:=dir2+str+'.prt';
    prtlist1.Clear;
    prtlist2.Clear;

    if abstime=false then
    begin
      start:=start2+len1;
    end
    else
    begin
      start:=start2;
    end;
    if fileexists(s1) then
    begin
      prtlist1.LoadFromFile(s1);
    end;
    if fileexists(s2) then
    begin
      prtlist2.LoadFromFile(s2);
      if prtlist2.Count>1 then
      begin
        setlength(prt2, prtlist2.count);
        for j := 0 to prtlist2.Count - 1 do
        begin
          // src:string;tabs:string;p:integer;var index:integer)
          // p - откуда искать ; index - где нашли разделитель
          prtstr:=GetSubString(prtlist2.Strings[j],' ',1,ind);
          prt2[j].t:=strtoFloatExt(prtstr) + start;
          prtstr:=GetSubString(prtlist2.Strings[j],' ',ind+1,ind);
          // смещаем на размер первого файла
          prt2[j].i:=strtoint(prtstr)+round(fsize/datasize);
        end;
      end;
    end;
    if prtlist1.Count=0 then
    begin
      prtlist1.Add(floattostr(st1)+' 0');
    end;
    if length(prt2)=0 then
    begin
      str2:=floattostr(st2+start);
      k:=pos(',',str2);
      if k>=1 then
        str2[k]:='.';
      prtlist1.Add(str2+' '+inttostr(round(fsize1/datasize)));
    end
    else
    begin
      for k := 0 to length(prt2) - 1 do
      begin
        str2:=floattostr(prt2[k].t);
        j:=pos(',',str2);
        if k>=1 then
          str2[j]:='.';
        prtlist1.add(str2+' '+inttostr(prt2[k].i));
      end;
    end;
    prtlist1.SaveToFile(extractfiledir(res)+'\'+str+'.prt');
  end;

  // копируем заголовок
  CopyFile(pwidechar(@f1[1]),pwidechar(@res[1]),lbool);

  prtlist1.Destroy;
  prtlist2.Destroy;

  // удаление переменных
  slist.Destroy;
  m1.Destroy;
  m2.Destroy;
end;

function EvalPrt(str:string;datasize:cardinal):tSignalPrt;
var
  prtstr:string;
  ind:integer;
begin
  // src:string;tabs:string;p:integer;var index:integer)
  // p - откуда искать ; index - где нашли разделитель
  prtstr:=GetSubString(str,' ',1,ind);
  result.t:=strtoFloatExt(prtstr);
  prtstr:=GetSubString(str,' ',ind+1,ind);
  result.i:=strtoint(prtstr);
end;

function getFileSizeFunc(name:string):cardinal;
var
 hFile: Integer;
begin
  hFile := FileOpen(Name, fmOpenRead);
  result := GetFileSize(hFile, nil);
  FileClose(hFile);
end;

function signalLength(fname, chan:string):double;
var
  ifile:tinifile;
  f:file;
  freq:double;
  str:string;
  prt:tstringlist;
  fsize,datasize:cardinal;
  lprt:tSignalPrt;
begin
  result:=-1;
  ifile:=tinifile.Create(fname);

  str:=ifile.ReadString(chan, 'freq', '1');
  freq:=strtofloatext(str);

  str:=LowerCase(ifile.ReadString(chan, 'YFormat', ''));
  if str='' then exit;

  datasize:=SignalFormatToDataSize(str);

  str:=extractfiledir(fname)+'\'+chan+'.dat';
  if fileexists(str) then
  begin
    fsize:=round(getFileSizeFunc(str)/datasize);
  end
  else
    exit;

  str:=extractfiledir(fname)+'\'+chan+'.prt';
  if fileexists(str) then
  begin
    prt:=TStringList.create;
    prt.LoadFromFile(str);
    lprt:=EvalPrt(prt.Strings[prt.Count-1],datasize);
    result:=lprt.t+(fsize-lprt.i)/freq;
  end
  else
  begin
    result:=fsize/freq;
  end;
end;

procedure GetSignalList(f:tinifile; signallist:tstringlist);
var
  sections:tstringlist;
  i:integer;
  str:string;
begin
  if signallist=nil then exit;
  sections:=tstringlist.Create;
  f.ReadSections(sections);
  for I := 1 to sections.Count - 1 do
  begin
    str:=sections.Strings[i];
    if lowercase(str)<>'mera' then
    begin
      signallist.Add(str);
    end;
  end;
  sections.Destroy;
end;

procedure GetSignalList(fname:string; signallist:tstringlist);
var
  f:tinifile;
  sections:tstringlist;
  i:integer;
  str:string;
begin
  if signallist=nil then exit;
  if signallist.count=0 then exit;
  f:=tinifile.Create(fname);
  sections:=tstringlist.Create;
  f.ReadSections(sections);
  for I := 1 to sections.Count - 1 do
  begin
    str:=sections.Strings[i];
    if lowercase(str)<>'mera' then
    begin
      signallist.Add(str);
    end;
  end;
  sections.Destroy;
  f.Destroy;
end;


end.
