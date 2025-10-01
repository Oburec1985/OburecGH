unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

interface

uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  uCommonMath, nativeXml,
  Generics.Collections, Controls, uRecBasicFactory,
  u3120frm, uTransmisNumFrm,
  u3120Factory;

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

var
  g_cfgpath:string;

const
  // Глобальная переменная для храения описания plug-in`а.
  GPluginInfo: TInternalPluginInfo = (
    Name: '3120Cyclogram';
    Dsc: 'Испытания трансмиссии (p3120)';
    Vendor: 'НПП Мера';
    Version: 1;
    SubVertion:0;);

  procedure createComponents(compMng:cCompMng);
  procedure destroyEngine;
  procedure createFormsRecorderUIThread(compMng: cCompMng);
  procedure destroyFormsRecorderUIThread(compMng: cCompMng);
  // MainThead. Здесь создавать формы для настройки плагина в режиме стопа
  procedure createForms();
  // MainThead
  procedure destroyForms();
  procedure RecorderInit;

implementation

procedure destroyEngine;
begin
 if true then exit;
 // обьявле в начале проекта
 {$IfDef DEBUG}
 {$EndIf}
end;


procedure createForms();
begin
  // создание в MainThread
  if GetCurrentThreadId = MainThreadID then
  begin
    // СОЗДАНЫЕ ЗДЕСЬ ФОРМЫ НЕЛЬЗЯ ДЕЛАТЬ SHOWMODAL В UITHREAD
    // необходимо быть осторожным, т.к. создание формы и создание хендлоа разные события
    // если форма первый раз показана не в том же потоке где создана то будут проблеммыс удалением формы
    //frm3120:=Tfrm3120.Create(nil);
  end;
end;

procedure destroyForms();
begin
  if GetCurrentThreadId = MainThreadID then
  begin

  end;
end;


procedure createComponents(compMng:cCompMng);
var
  str, str1:string;
  m_toolBarIcon:IPicture;
  m_btnID:cardinal;
begin
  g_3120Factory:=c3120Factory.create;
  CompMng.Add(g_3120Factory);
end;

procedure createFormsRecorderUIThread(compMng: cCompMng);
var
  h: thandle;
  str, str1:string;
  show:boolean;
begin
  TransNumFrm:=TTransNumFrm.Create(nil);
  TransNumFrm.show;
  begin
  end;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
  TransNumFrm.Destroy;
  begin
  end;
end;

procedure RecorderInit;
begin
  //if ThresholdFrm<>nil then
  //  ThresholdFrm.AttachAlarms;
end;

end.
