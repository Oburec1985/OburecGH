unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

interface

uses
  uEvalStepCfgFrm,
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  uEvalStepAlg, uCommonMath, nativeXml, ulogfile,
  Generics.Collections, Controls;

type
  {Тип для хранения информации о plug-in`е}
  {Этот тип удобнее использовать в Delphi, чем PLUGININFO}
  TInternalPluginInfo = record
    Name: AnsiString; // наименование
    Dsc: AnsiString; // описание
    Vendor: AnsiString; // описание разработчика
    Version: integer; // версия
    SubVertion: integer; // под-версия
  end;

  // транслятор сообщений из Recorder в базу TMBaseControl
  cEvalStepValNP = class(cNonifyProcessor)
  public
    fload:boolean;
    m_toolBarIcon:IPicture;
    m_btnID:cardinal;
    // сохранялка
    m_toolBarIcon2:IPicture;
    m_btnID2:cardinal;
  protected
    procedure doAddParentList;override;
    procedure doSave(path: string);override;
    procedure doLoad(path: string);override;
    procedure doLeaveCfg;override;
    procedure doRCInit; override;
  public
    function ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;override;
    constructor create;
  end;

var
  g_EvalStepValNP:cEvalStepValNP;
  g_cfgpath:string;

const
  // Глобальная переменная для храения описания plug-in`а.
  GPluginInfo: TInternalPluginInfo = (
    Name: 'EvalStepAlg';
    Dsc: 'Модуль расчета значения на переходном процессе';
    Vendor: 'НПП Мера';
    Version: 1;
    SubVertion:0;);

  procedure createComponents(compMng:cCompMng);
  procedure destroyEngine;
  procedure createFormsRecorderUIThread(compMng: cCompMng);
  procedure destroyFormsRecorderUIThread(compMng: cCompMng);
  // MainThead. Здесь создавать формы для настройки плагина в режиме стопа
  procedure createForms(compMng: cCompMng);
  // MainThead
  procedure destroyForms(compMng: cCompMng);
  procedure RecorderInit;


implementation

procedure RecorderInit;
begin
  //if ThresholdFrm<>nil then
  //  ThresholdFrm.AttachAlarms;
end;

procedure destroyEngine;
begin
 if true then exit;
 // обьявле в начале проекта
 {$IfDef DEBUG}
 {$EndIf}
end;


procedure createForms(compMng: cCompMng);
begin
  // создание в MainThread
  if GetCurrentThreadId = MainThreadID then
  begin

  end;
end;

procedure destroyForms(compMng: cCompMng);
begin
  exit;
  if GetCurrentThreadId = MainThreadID then
  begin
    if EvalStepCfgFrm<>nil then
    begin
      EvalStepCfgFrm.destroy;
      EvalStepCfgFrm:=nil;
    end;
    g_EvalStepValNP.Destroy;
    g_AlgList.Destroy;
  end;
end;


procedure createComponents(compMng:cCompMng);
var
  str, str1, cfg, dir, fname:string;
  m_toolBarIcon:IPicture;
  i, m_btnID:cardinal;
begin
  cfg := extractfiledir(getRConfig);
  i := 0;
  if DirectoryExists(cfg) then
  begin
    dir := cfg + '\logs\';
    if not DirectoryExists(dir) then
    begin
      ForceDirectories(dir);
    end;
    fname := dir + 'ControlCyclogramLog_' + inttostr(i) + '.log';
    while FileExists(fname) do
    begin
      inc(i);
      fname := dir + 'ControlCyclogramLog_' + inttostr(i) + '.log';
    end;
    g_logFile := cLogFile.Create(fname, ';');
    g_logFile.m_Rewrite := false;
  end;
end;

procedure createFormsRecorderUIThread(compMng: cCompMng);
var
  h: thandle;
  str, str1:string;
  show:boolean;
begin
  if EvalStepCfgFrm=nil then
  begin
    EvalStepCfgFrm:=TEvalStepCfgFrm.Create(nil);
    EvalStepCfgFrm.show;
    EvalStepCfgFrm.close;
  end;

  g_EvalStepValNP:=cEvalStepValNP.Create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(g_EvalStepValNP);

  g_AlgList:=cAlgList.Create;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
  if true then exit;
  
  if EvalStepCfgFrm<>nil then
  begin
    EvalStepCfgFrm.free;
    EvalStepCfgFrm := nil;
  end;
end;

{ cMBaseAlgNP }
constructor cEvalStepValNP.create;
begin
  fload:=false;
end;

procedure cEvalStepValNP.doAddParentList;
var
  str, str1:string;
begin
  inherited;
  // добавляем кнопку в редакторе формуляров
  str  := 'Расчетные каналы';
  str1 := 'Расчетные каналы';
  m_toolBarIcon:= LoadPicFromRes('FX48');
  cCompMng(TExtRecorderPack(GPluginInstance).m_CompMng).m_BtnTagPropPage.AddButton(m_toolBarIcon,
                                m_toolBarIcon, m_toolBarIcon,
                                m_toolBarIcon,
                                pAnsiChar(@str1[1]), @str[1], GPluginInstance, m_btnID);
end;


procedure cEvalStepValNP.doLoad(path: string);
var
  doc:TNativeXml;
  node:txmlnode;
begin
  g_cfgpath:=path;
  ecm;
  g_algList.doLoad(nil);
  lcm;
  fload:=true;
end;

procedure cEvalStepValNP.doRCInit;
var
  i:integer;
  a:cEvalStepAlg;
begin
  if not fload then
  begin
    g_cfgpath:=getRConfig;
    doLoad(g_cfgpath);
  end;
  for i:=0 to g_AlgList.Count-1 do
  begin
    a:=g_AlgList.getobj(i);
    a.m_tag.tagname:=a.m_tag.tagname;
    a.m_outTag.tagname:=a.m_outTag.tagname;
    ecm;
    a.m_outTag.tag.SetFreq(a.m_tag.freq);
    a.UpdateFFTSize;
    lcm;
  end;
end;

procedure cEvalStepValNP.doLeaveCfg;
begin
  g_algList.doLeaveCfg;
end;

procedure cEvalStepValNP.doSave(path: string);
var
  dir, name:string;
begin
  g_cfgpath:=path;
  dir:=extractfiledir(path);
  name:=trimext(extractfilename(path));
  g_algList.doSave(nil);
end;

function cEvalStepValNP.ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean;
begin
  if pMsgInfo.uID=m_btnID then
  begin
    EvalStepCfgFrm.Show;   // показываем форму настроек
  end;
end;

end.
