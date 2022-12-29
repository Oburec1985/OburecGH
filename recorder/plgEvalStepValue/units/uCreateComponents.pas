unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

interface

uses
  uRecFactory,
  uGlFrm,
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
    Name: 'Модуль для управления задвижками';
    Dsc: 'Модуль для управления задвижками';
    Vendor: 'НПП Мера';
    Version: 1;
    SubVertion:0;);

  procedure createComponents(compMng:cCompMng);

implementation
uses
  PluginClass;

procedure createComponents(compMng:cCompMng);
begin
  //CompMng.Add(cRecFactory.Create);
  CompMng.Add(cGLFact.Create);
end;

end.
