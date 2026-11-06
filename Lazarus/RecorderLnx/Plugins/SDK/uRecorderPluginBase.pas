unit uRecorderPluginBase;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Общий жизненный цикл плагина без привязки к визуальным компонентам.
  Обёртка ABI вызывает методы и преобразует исключения в код ошибки. }
interface

uses uRecorderPluginApi;

type
  TRecorderPluginBase = class
  public
    function Initialize(AHostApi: PRecorderPluginHostApi): Boolean; virtual; abstract;
    function Notify(AKind: LongWord; AData: Pointer): LongInt; virtual; abstract;
    procedure Close; virtual;
  end;

implementation

procedure TRecorderPluginBase.Close;
begin
end;

end.
