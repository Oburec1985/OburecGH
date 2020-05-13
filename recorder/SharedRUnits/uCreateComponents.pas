unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

interface

uses
  Windows,
  SysUtils,
  cfreg,
  uGateFrm,
  uCompMng;

type
  {Тип для хранения информации о plug-in`е}
  {Этот тип удобнее использовать в Delphi, чем PLUGININFO}
  TInternalPluginInfo = record
    Name: AnsiString;    // наименование
    Dsc: AnsiString;     // описание
    Vendor: AnsiString;  // описание разработчика
    Version: integer;    // версия
    SubVertion: integer; // под-версия
  end;

  procedure createComponents(compMng:cCompMng);
  function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
  procedure destroyComponents(compMng:cCompMng);

const
  // Глобальная переменная для храения описания plug-in`а.
  GPluginInfo: TInternalPluginInfo = (
    Name: 'Модуль для управления задвижками';
    Dsc: 'Модуль для управления задвижками';
    Vendor: 'НПП Мера';
    Version: 1;
    SubVertion:0;);

implementation
//uses
//  PluginClass;

procedure createComponents(compMng:cCompMng);
begin
  CompMng.Add(cGateFactory.Create);
  //CompMng.Add(cRecFactory.Create);
end;

procedure destroyComponents(compMng:cCompMng);
begin

end;

function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;
var
  str : string;
begin
  str := GPluginInfo.Name + #13#10 +
         GPluginInfo.Dsc + #13#10 +
         'Версия ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr(GPluginInfo.SubVertion) + #13#10 + #13#10 +
         GPluginInfo.Vendor;
  MessageBox(0, PChar(str), 'Информация о модуле', MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);

  result := true;
end;

end.
