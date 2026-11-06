unit uRecorderPluginFramework;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Общая реализация экспортов жизненного цикла для плагинов. Визуальная
  библиотека задаёт регистрацию фабрик; живые экземпляры проверяет менеджер.
  ABI перечисления не передаёт контекст: допускается один объект плагина на
  загруженную библиотеку и произвольное число компонентов его фабрик. }

interface

uses uRecorderPluginApi, uRecorderPluginBase, uRecorderPluginClass,
  uRecorderVisualComponentApiV2;

type
  TRecorderCreatePlugin = function: TRecorderPluginBase;

procedure ConfigurePluginFramework(ACreate: TRecorderCreatePlugin);
procedure ConfigureFramework(ARegister: TRecorderRegisterVisualFactories);
function CreatePluginClass: Pointer; cdecl;
function DestroyPluginClass(AInstance: Pointer): LongInt; cdecl;
function PluginCreate(AInstance: Pointer; AHostApi: PRecorderPluginHostApi): LongBool; cdecl;
function PluginNotify(AInstance: Pointer; AEvent: LongInt; AData: Pointer): LongBool; cdecl;
function PluginClose(AInstance: Pointer): LongBool; cdecl;
function RecorderVisualGetDescriptorV2(AIndex: LongWord;
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ADescriptorCapacity: SizeUInt): LongInt; cdecl;
function RecorderVisualUsesPluginNotifications: LongBool; cdecl;

implementation

var
  g_Plugin: TRecorderPluginBase = nil;
  g_Register: TRecorderRegisterVisualFactories = nil;
  g_Create: TRecorderCreatePlugin = nil;

procedure ConfigurePluginFramework(ACreate: TRecorderCreatePlugin);
begin
  if g_Plugin <> nil then Exit;
  g_Create := ACreate;
  g_Register := nil;
end;

procedure ConfigureFramework(ARegister: TRecorderRegisterVisualFactories);
begin
  if g_Plugin <> nil then Exit;
  g_Register := ARegister;
  g_Create := nil;
end;

function CreatePluginClass: Pointer; cdecl;
begin
  Result := nil;
  if (g_Plugin <> nil) or
    (not Assigned(g_Register) and not Assigned(g_Create)) then Exit;
  try
    if Assigned(g_Create) then g_Plugin := g_Create()
    else g_Plugin := TExtRecorderPack.Create(g_Register);
    Result := g_Plugin;
  except
    g_Plugin := nil;
  end;
end;

function DestroyPluginClass(AInstance: Pointer): LongInt; cdecl;
begin
  Result := -1;
  if (AInstance = nil) or (AInstance <> Pointer(g_Plugin)) then Exit;
  try
    if (g_Plugin is TExtRecorderPack) and
      TExtRecorderPack(g_Plugin).HasInstances then Exit;
    g_Plugin.Free;
    g_Plugin := nil;
    Result := 0;
  except
    g_Plugin := nil;
  end;
end;

function PluginCreate(AInstance: Pointer; AHostApi: PRecorderPluginHostApi): LongBool; cdecl;
begin
  Result := False;
  if (AInstance = nil) or (AInstance <> Pointer(g_Plugin)) then Exit;
  try
    Result := g_Plugin.Initialize(AHostApi);
  except
    Result := False;
  end;
end;

function PluginNotify(AInstance: Pointer; AEvent: LongInt; AData: Pointer): LongBool; cdecl;
begin
  Result := False;
  if (AInstance = nil) or (AInstance <> Pointer(g_Plugin)) then Exit;
  try
    Result := g_Plugin.Notify(AEvent, AData) >= 0;
  except
    Result := False;
  end;
end;

function PluginClose(AInstance: Pointer): LongBool; cdecl;
begin
  Result := (AInstance <> nil) and (AInstance = Pointer(g_Plugin));
  if not Result then Exit;
  try
    g_Plugin.Close;
  except
    Result := False;
  end;
end;

function RecorderVisualGetDescriptorV2(AIndex: LongWord;
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ADescriptorCapacity: SizeUInt): LongInt; cdecl;
begin
  if not (g_Plugin is TExtRecorderPack) then Exit(REC_VISUAL_ERROR);
  Result := TExtRecorderPack(g_Plugin).GetDescriptor(AIndex, ADescriptor,
    ADescriptorCapacity);
end;

function RecorderVisualUsesPluginNotifications: LongBool; cdecl;
begin
  Result := True;
end;

end.
