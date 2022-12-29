unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

interface

uses
  uEvalStepCfgFrm,
  windows,
  uCompMng;

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


const
  // Глобальная переменная для храения описания plug-in`а.
  GPluginInfo: TInternalPluginInfo = (
    Name: '';
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

implementation
uses
  PluginClass;

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
    // СОЗДАНЫЕ ЗДЕСЬ ФОРМЫ НЕЛЬЗЯ ДЕЛАТЬ SHOWMODAL В UITHREAD
    // необходимо быть осторожным, т.к. создание формы и создание хендлоа разные события
    // если форма первый раз показана не в том же потоке где создана то будут проблеммыс удалением формы
    EvalStepCfgFrm:=TEvalStepCfgFrm.Create(nil);
    EvalStepCfgFrm.Show;
    EvalStepCfgFrm.close;
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
  end;
end;


procedure createComponents(compMng:cCompMng);
begin
  //CompMng.Add(cGLFact.Create);
end;

procedure createFormsRecorderUIThread(compMng: cCompMng);
var
  h: thandle;
  str, str1:string;
  show:boolean;
begin
  EvalStepCfgFrm:=TEvalStepCfgFrm.Create(nil);
  EvalStepCfgFrm.show;
  EvalStepCfgFrm.close;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
  if EvalStepCfgFrm<>nil then
  begin
    EvalStepCfgFrm.free;
    EvalStepCfgFrm := nil;
  end;
end;

end.
