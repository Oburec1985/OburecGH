unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

interface

uses
  Windows,
  SysUtils, Classes,
  cfreg,
  uMainFrm, uSettingsFrm, uSelectChannelFrm,
  uCompMng,
  PluginClass, uRCFunc,
  uCreateNotifyProcess;

type
  {Тип для хранения информации о plug-in`е}
  {Этот тип удобнее использовать в Delphi, чем PLUGININFO}
  TInternalPluginInfo = record
    Name: AnsiString;    // наименование
    Dsc: AnsiString;     // описание
    Vendor: AnsiString;  // описание разработчика
    Version: integer;    // версия
    SubVertion: integer; // под-версия
    Year: integer;       // год выпуска
  end;

  procedure createComponents(compMng:cCompMng);
  // Thread окна Recorder. Здесь надо создавать виджеты для формуляров
   procedure createFormsRecorderUIThread(compMng:cCompMng);
   procedure destroyFormsRecorderUIThread(compMng:cCompMng);
  // MainThead. Здесь создавать формы для настройки плагина в режиме стопа
  procedure createForms(compMng:cCompMng);
  // MainThead
  procedure destroyForms(compMng:cCompMng);
  function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
  procedure destroyComponents(compMng:cCompMng);

const
  // Глобальная переменная для хранения описания plug-in`а.
  GPluginInfo: TInternalPluginInfo = (
    Name:      'Плагин ГОРН';
    Dsc:       'Плагин управления блоками ГОРН';
    Vendor:    'НПП Мера';
    Version:   1;
    SubVertion:4;
    Year:      2023;);

var
  // флаг для запрета удаления frmSync пока не удалим все формы в потоке формы FrmSync
  g_delFrms : boolean;

implementation

procedure createFormsRecorderUIThread(compMng:cCompMng);
var
  np : cNonifyProcessor;
begin
  g_delFrms := false;
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=true;

  // GetCurrentThreadId;
  np := cTagPropNP.create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);

  SettingsFrm := TSettingsFrm.create(nil);
  SettingsFrm.show;
  SettingsFrm.close;
  SettingsFrm.m_ThID:=GetCurrentThreadId;
  SettingsFrm.m_MainThread:=MainThreadID;
  //SettingsFrm.HandleNeeded;

  SelectChannelFrm := TSelectChannelFrm.create(nil);
  SelectChannelFrm.HandleNeeded;
end;

procedure destroyFormsRecorderUIThread(compMng:cCompMng);
begin
  // удаление форм в UIThread
  // ВАЖНО!!! Первое изменение свойств формы имеет право происходить только в UIThread
  // Если произойдет в MainThread (например менять форму при загрузке объектов программы),
  // то будет ошибка при удалении формы Code Error 5 (с HandleAllocated не связано!)

  TExtRecorderPack(GPluginInstance).EList.active := false;

  if SettingsFrm <> nil then
    begin
      SettingsFrm.free;
      SettingsFrm := nil;
    end;

  if SelectChannelFrm <> nil then
    begin
      SelectChannelFrm.free;
      SelectChannelFrm := nil;
    end;

  g_delFrms := true;
end;

procedure createForms(compMng:cCompMng);
begin
  // создание в MainThread
  if GetCurrentThreadId=MainThreadID then
  begin
    // здесь создавать формы (происходит в контексте mainThread) Вызывается из uFrmSync
  end;
end;

procedure destroyForms(compMng:cCompMng);
begin
  // удаление форм в MainThread
end;

procedure createComponents(compMng:cCompMng);
var
  fact:cGORNFactory;
begin
  fact:=cGORNFactory.Create;
  CompMng.Add(fact);
  //CompMng.Add(cRecFactory.Create);

  //CompMng.Add(cPluginFactory.Create);
end;

procedure destroyComponents(compMng:cCompMng);
begin
end;

function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
var
  str : string;
begin
  str := GPluginInfo.Name + #13#10 + #13#10 +
         GPluginInfo.Dsc + #13#10 + 'Версия ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr(GPluginInfo.SubVertion) + #13#10 + #13#10 + GPluginInfo.Vendor + ', ' + IntToStr(GPluginInfo.Year);
  MessageBox(0, PChar(str), 'Информация о модуле', MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);

  result := true;
end;

end.
