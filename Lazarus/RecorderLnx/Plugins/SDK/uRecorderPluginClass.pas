unit uRecorderPluginClass;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Общий объект визуального плагина: создаёт менеджер и передаёт ему
  зарегистрированные конкретным плагином фабрики при Initialize. Он не зависит от вида
  компонента; экспорт библиотеки обращается к нему через ABI-обёртку. }

interface

uses
  uRecorderVisualComponentApiV2, uRecorderPluginComponentManager,
  uRecorderPluginApi, uRecorderPluginBase;

type
  TRecorderRegisterVisualFactories = procedure(
    AManager: cCompMng);

  TExtRecorderPack = class(TRecorderPluginBase)
  private
    fManager: cCompMng;
    fHostApi: PRecorderPluginHostApi;
    fRegister: TRecorderRegisterVisualFactories;
  public
    constructor Create(ARegister: TRecorderRegisterVisualFactories);
    destructor Destroy; override;
    function _Create(AHostApi: PRecorderPluginHostApi): Boolean;
    function ProcessNotify(AKind: LongWord; AData: Pointer): LongInt;
    function Initialize(AHostApi: PRecorderPluginHostApi): Boolean; override;
    function GetDescriptor(AIndex: LongWord;
      ADescriptor: PRecorderVisualComponentDescriptorV2;
      ACapacity: SizeUInt): LongInt;
    function Notify(AKind: LongWord; AData: Pointer): LongInt; override;
    procedure Close; override;
    function HasInstances: Boolean;
    property HostApi: PRecorderPluginHostApi read fHostApi;
  end;

implementation

uses SysUtils;

constructor TExtRecorderPack.Create(ARegister: TRecorderRegisterVisualFactories);
begin
  inherited Create;
  fRegister := ARegister;
end;

destructor TExtRecorderPack.Destroy;
begin
  fManager.Free;
  inherited Destroy;
end;

{ Таблица принадлежит хосту и действует до закрытия объекта плагина. }
function TExtRecorderPack._Create(AHostApi: PRecorderPluginHostApi): Boolean;
begin
  Result := False;
  if (AHostApi = nil) or (AHostApi^.Size < SizeOf(TRecorderPluginHostApi)) then Exit;
  if fManager <> nil then Exit(fHostApi = AHostApi);
  fHostApi := AHostApi;
  try
    fManager := cCompMng.Create(AHostApi);
    if Assigned(fRegister) then fRegister(fManager);
    Result := True;
  except
    FreeAndNil(fManager);
    fHostApi := nil;
  end;
end;

function TExtRecorderPack.Initialize(AHostApi: PRecorderPluginHostApi): Boolean;
begin
  Result := _Create(AHostApi);
end;

function TExtRecorderPack.GetDescriptor(AIndex: LongWord;
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ACapacity: SizeUInt): LongInt;
begin
  if fManager = nil then Exit(REC_VISUAL_ERROR);
  try
    Result := fManager.GetDescriptor(AIndex, ADescriptor, ACapacity);
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

function TExtRecorderPack.ProcessNotify(AKind: LongWord; AData: Pointer): LongInt;
begin
  if fManager = nil then Exit(REC_VISUAL_ERROR);
  try
    Result := fManager.Notify(AKind, AData);
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

function TExtRecorderPack.Notify(AKind: LongWord; AData: Pointer): LongInt;
begin
  Result := ProcessNotify(AKind, AData);
end;

function TExtRecorderPack.HasInstances: Boolean;
begin
  Result := (fManager <> nil) and fManager.HasInstances;
end;

procedure TExtRecorderPack.Close;
begin
  if (fManager <> nil) and (fManager.Close <> REC_VISUAL_OK) then
    raise Exception.Create('Не удалось остановить потоки фабрик плагина');
end;

end.
