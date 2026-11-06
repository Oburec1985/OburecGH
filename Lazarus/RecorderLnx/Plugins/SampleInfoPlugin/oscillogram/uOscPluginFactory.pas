unit uOscPluginFactory;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Фабрика осциллографа связывает ABI компонента с общим менеджером плагина,
  учитывает экземпляры и направляет им уведомления жизненного цикла. }

interface

uses uRecorderPluginComponentManager, uRecorderVisualComponentApiV2;

type
  TOscVisualFactory = class(cRecBasicFactory)
  public
    constructor Create;
    destructor Destroy; override;
    function GetDescriptor(ADescriptor: PRecorderVisualComponentDescriptorV2;
      ACapacity: SizeUInt): LongInt; override;
  end;

implementation

uses SysUtils, uOscPluginV2;

var
  g_OscFactory: TOscVisualFactory = nil;

{ Обёртки сохраняют экземпляры фабрики для доставки общих уведомлений. }
function CreateOscInstance(AHostContext, AConfigData: Pointer; AConfigSize: SizeUInt;
  out AInstance: Pointer): LongInt; cdecl;
begin
  AInstance := nil;
  if g_OscFactory = nil then Exit(REC_VISUAL_ERROR);
  try
    Result := g_OscFactory.Descriptor.CreateInstance(AHostContext, AConfigData,
      AConfigSize, AInstance);
    if Result = REC_VISUAL_OK then
    begin
      if AInstance = nil then Exit(REC_VISUAL_ERROR);
      try
        g_OscFactory.RegisterInstance(AInstance);
      except
        g_OscFactory.Descriptor.DestroyInstance(AInstance);
        AInstance := nil;
        Result := REC_VISUAL_ERROR;
      end;
    end;
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

procedure DestroyOscInstance(AInstance: Pointer); cdecl;
begin
  if (g_OscFactory = nil) or not g_OscFactory.OwnsInstance(AInstance) then Exit;
  try
    g_OscFactory.Descriptor.DestroyInstance(AInstance);
    g_OscFactory.UnregisterInstance(AInstance);
  except
    { Исключения не должны пересекать границу ABI. }
  end;
end;

function TryDestroyOscInstance(AInstance: Pointer): LongInt; cdecl;
begin
  if (g_OscFactory = nil) or not g_OscFactory.OwnsInstance(AInstance) then
    Exit(REC_VISUAL_ERROR);
  try
    if Assigned(g_OscFactory.Descriptor.TryDestroyInstance) then
      Result := g_OscFactory.Descriptor.TryDestroyInstance(AInstance)
    else
    begin
      g_OscFactory.Descriptor.DestroyInstance(AInstance);
      Result := REC_VISUAL_OK;
    end;
    if Result = REC_VISUAL_OK then g_OscFactory.UnregisterInstance(AInstance);
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

constructor TOscVisualFactory.Create;
var lDescriptor: TRecorderVisualComponentDescriptorV2;
begin
  inherited Create;
  if uOscPluginV2.RecorderVisualGetDescriptorV2(0, @lDescriptor,
    SizeOf(lDescriptor)) <> REC_VISUAL_OK then
    raise Exception.Create('Не удалось получить дескриптор осциллографа');
  SetDescriptor(lDescriptor);
  g_OscFactory := Self;
end;

destructor TOscVisualFactory.Destroy;
begin
  if g_OscFactory = Self then g_OscFactory := nil;
  inherited Destroy;
end;

function TOscVisualFactory.GetDescriptor(
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ACapacity: SizeUInt): LongInt;
begin
  Result := uOscPluginV2.RecorderVisualGetDescriptorV2(0, ADescriptor, ACapacity);
  if Result <> REC_VISUAL_OK then Exit;
  ADescriptor^.CreateInstance := @CreateOscInstance;
  ADescriptor^.DestroyInstance := @DestroyOscInstance;
  if RecorderVisualFieldPresentV2(ADescriptor^.Header.Size,
    PtrUInt(@ADescriptor^.TryDestroyInstance) - PtrUInt(ADescriptor),
    SizeOf(ADescriptor^.TryDestroyInstance)) then
    ADescriptor^.TryDestroyInstance := @TryDestroyOscInstance;
end;

end.
