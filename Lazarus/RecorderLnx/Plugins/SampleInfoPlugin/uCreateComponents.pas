unit uCreateComponents;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Состав плагина: регистрация фабрик компонентов в общем менеджере. }

interface

uses uRecorderPluginComponentManager;

procedure CreateComponents(AManager: cCompMng);

implementation

uses uOscPluginFactory;

procedure CreateComponents(AManager: cCompMng);
var
  lFactory: TOscVisualFactory;
begin
  lFactory := TOscVisualFactory.Create;
  try
    AManager.Add(lFactory);
  except
    lFactory.Free;
    raise;
  end;
end;

end.
