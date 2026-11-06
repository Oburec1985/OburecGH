unit uLuaPluginAdapter;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Адаптирует существующий вычислительный плагин к общему жизненному циклу SDK. }
interface

uses uRecorderPluginBase, uRecorderPluginApi, uLuaCalcPlugin;

type
  TLuaPluginAdapter = class(TRecorderPluginBase)
  private
    fPlugin: TLuaCalcPlugin;
  public
    constructor Create;
    destructor Destroy; override;
    function Initialize(AHostApi: PRecorderPluginHostApi): Boolean; override;
    function Notify(AKind: LongWord; AData: Pointer): LongInt; override;
    procedure Close; override;
  end;

function CreateLuaPlugin: TRecorderPluginBase;

implementation

uses uRecorderVisualComponentApiV2;

function CreateLuaPlugin: TRecorderPluginBase;
begin
  Result := TLuaPluginAdapter.Create;
end;

constructor TLuaPluginAdapter.Create;
begin
  inherited Create;
  fPlugin := TLuaCalcPlugin.Create;
end;

destructor TLuaPluginAdapter.Destroy;
begin
  fPlugin.Free;
  inherited Destroy;
end;

function TLuaPluginAdapter.Initialize(AHostApi: PRecorderPluginHostApi): Boolean;
begin
  Result := fPlugin.Initialize(AHostApi);
end;

function TLuaPluginAdapter.Notify(AKind: LongWord; AData: Pointer): LongInt;
begin
  if fPlugin.Notify(LongInt(AKind)) then Result := REC_VISUAL_OK
  else Result := REC_VISUAL_ERROR;
end;

procedure TLuaPluginAdapter.Close;
begin
  fPlugin.Close;
end;

end.
