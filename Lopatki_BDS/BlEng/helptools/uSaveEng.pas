unit uSaveEng;

interface
uses
  inifiles, ubldeng, forms, uCommonMath, uErrorProc, sysutils, uLfmFile, uBldFile
  , uBldEngEventTypes, uXmlFile, uBldTimeProc, dialogs;

// в качестве параметров главная форма TMainBldForm и двиг
procedure saveEng(form:TForm; eng:cbldeng);
procedure LoadEng(form:TForm; eng:cbldeng);

implementation
uses
  MainForm;

const
  c_MainFormSection = 'MainForm';
  // отображать панель с координатами мыши на чарте
  c_ShowMouseInputPannelKey = 'ShowUserInput';
  // отображать события чарта
  c_ShowChartEventsKey = 'ShowChartEventsKey';
  c_EngSection = 'Engine';
  // писать в файл события движка
  c_WriteJournalKey = 'WriteJournal';
  // показывать всплывающие диаложки при событиях
  c_ShowMessagesKey = 'ShowMessages';
  c_DefaultCfg = 'DefaultCfg';
  c_ModeType = 'ModeType';
  c_SaveFolder = 'DefaultSaveFolder';
  c_Prec = 'Digits';

procedure saveEng(form:TForm; eng:cbldeng);
var
  iFile:tinifile;
  fname:string;
begin
  fname:=eng.PathMng.findCfgPathFile('Main.ini');
  ifile:=tinifile.Create(fname);
  //  пишем нужно ли писать в файл события движка
  ifile.WriteBool(c_EngSection,c_WriteJournalKey,CheckFlag(eng.flags, c_LogMessage));
  //  пишем нужно ли отображать события вспылвающими окошками
  ifile.WriteBool(c_EngSection,c_ShowMessagesKey,CheckFlag(eng.flags, c_ShowMessage));
  ifile.WriteBool(c_EngSection,c_ShowMessagesKey,CheckFlag(eng.flags, c_ShowMessage));
  ifile.WriteString(c_EngSection,c_DefaultCfg,eng.curCfg);
  ifile.WriteString(c_EngSection,c_SaveFolder,eng.SaveFolder);
  // талог и имя файла для воспроизведения
  ifile.WriteString(c_EngSection,'NamePart',eng.GetFName);
  ifile.WriteString(c_EngSection,'Folder',eng.GetFolder);
  // пишем каталог из которого воспроизводяться данные
  // пишем параметры главной формы
  // отображать панель с координатами мыши на чарте
  ifile.WriteBool(c_MainFormSection,c_ShowMouseInputPannelKey,
                  TMainBldForm(form).MouseGB.Visible);
  // отображать события чарта
  //ifile.WriteBool(c_MainFormSection,c_ShowChartEventsKey,
  //                TMainBldForm(form).chartframe1.EventsListView.Visible);
  // Режим воспроизведения/ получения данных
  ifile.WriteInteger(c_MainFormSection, c_ModeType, TMainBldForm(form).fMode);

  ifile.WriteInteger(c_MainFormSection, c_Prec, eng.prec);
  ifile.Destroy;
end;

function LoadFromFile(name:string;form:TForm; eng:cbldeng):boolean;
var
  ext:string;
begin
  result:=false;
  if not fileexists(name) then
  begin
    ext:='Файл '+name+'не найден';
    showmessage(ext);
    exit;
  end;
  ext:=extractfileext(name);
  ext:=lowerCase(ext);
  if ext='.lfm' then
  begin
    // удалить объекты движка
    eng.clear;
    // загружаем новую конфигурацию
    readLFMData(eng,name);
    result:=true;
  end;
  if ext='.bld' then
  begin
    result:=ReadBldData(name,eng);
  end;
  if ext='.xml' then
  begin
    //result:=LoadXMLFile(name,eng,tmainbldform(form).ChartFrame1.chart);
  end;
  if result then
  begin
    eng.curCfg:=name;
    eng.events.CallAllEvents(E_OnEngLoadCfg);
  end;
end;

procedure LoadEng(form:TForm; eng:cbldeng);
var
  iFile:tinifile;
  fname, folder:string;
  b:boolean;
begin
  setflag(eng.flags,c_EngLoading);
  fname:=eng.PathMng.findCfgPathFile('Main.ini');
  ifile:=tinifile.Create(fname);
  //  пишем нужно ли писать в файл события движка
  b:=ifile.ReadBool(c_EngSection,c_WriteJournalKey,true);
  eng.setEngFlag(c_LogMessage,b);
  eng.curCfg:=ifile.ReadString(c_EngSection,c_DefaultCfg,'');
  eng.SaveFolder:=ifile.ReadString(c_EngSection,c_SaveFolder,'');
  //  пишем нужно ли отображать события вспылвающими окошками
  b:=ifile.ReadBool(c_EngSection,c_ShowMessagesKey,true);
  eng.setEngFlag(c_ShowMessage,b);
  LoadFromFile(eng.curCfg,form,eng);
  // пишем параметры главной формы
  // отображать панель с координатами мыши на чарте
  TMainBldForm(form).MouseGB.Visible:=ifile.ReadBool(c_MainFormSection,
                                            c_ShowMouseInputPannelKey,true);
  // пишем каталог из которого воспроизводяться данные
  fname:=ifile.readstring(c_EngSection, 'NamePart','');
  folder:=ifile.readstring(c_EngSection, 'Folder','');
  eng.SetFolderPath(folder,fname);
  // отображать события чарта
  //TMainBldForm(form).chartframe1.EventsListView.Visible:=ifile.ReadBool(c_MainFormSection,
  //                                          c_ShowChartEventsKey,true);
  // Режим воспроизведения/ получения данных
  TMainBldForm(form).fMode:= ifile.ReadInteger(c_MainFormSection, c_ModeType, 0);
  eng.prec:=ifile.ReadInteger(c_MainFormSection, c_Prec,6);
  ifile.Destroy;
  dropflag(eng.flags,c_EngLoading);
end;


end.
