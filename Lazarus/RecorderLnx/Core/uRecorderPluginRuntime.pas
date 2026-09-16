unit uRecorderPluginRuntime;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DynLibs, uRecorderFormModel, uRecorderPluginApi;

type
  TRecorderPluginRuntime = class
  private
    fRegistry: TRecorderComponentFactory;
    fPlugins: TList;
    fPendingFactories: TList;
    function GetLoadedCount: Integer;
  public
    constructor Create(ARegistry: TRecorderComponentFactory);
    destructor Destroy; override;
    procedure LoadConfigured(const AConfigFileName: string);
    procedure NotifyAll(AEvent: LongInt);
    property LoadedCount: Integer read GetLoadedCount;
  end;

implementation

uses
  uRecorderPluginInfo, uRecorderPluginConfig, uRecorderDebugLog;

type
  TLoadedPlugin = class
    Handle: TLibHandle;
    Instance: Pointer;
    CloseProc: TRecorderPluginClose;
    NotifyProc: TRecorderPluginNotify;
    DestroyProc: TRecorderPluginDestroyClass;
    destructor Destroy; override;
  end;

  TPluginOscillogramFactory = class(TRecorderComponentFactoryBase)
  private
    fCreate: TRecorderPluginCreateComponent;
    fContext: Pointer;
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create(const ATypeId, ACaption, AGroup: string;
      ACreate: TRecorderPluginCreateComponent; APluginContext: Pointer);
  end;

destructor TLoadedPlugin.Destroy;
begin
  if Assigned(CloseProc) and (Instance <> nil) then
    CloseProc(Instance);
  if Assigned(DestroyProc) and (Instance <> nil) then
    DestroyProc(Instance);
  if Handle <> NilHandle then
    FreeLibrary(Handle);
  inherited Destroy;
end;

constructor TPluginOscillogramFactory.Create(const ATypeId, ACaption,
  AGroup: string; ACreate: TRecorderPluginCreateComponent;
  APluginContext: Pointer);
begin
  inherited Create(ATypeId, ACaption, TRecorderOscillogramComponent,
    360, 220, True);
  fCreate := ACreate;
  fContext := APluginContext;
  ConfigurePalette(ACaption, ACaption, 'oscillogram', 90, rppGroup,
    AGroup);
end;

procedure TPluginOscillogramFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lSpec: TRecorderPluginComponentSpec;
begin
  inherited ConfigureNewComponent(AComponent, AContext);
  lSpec := Default(TRecorderPluginComponentSpec);
  lSpec.Size := SizeOf(lSpec);
  lSpec.Width := DefaultWidth;
  lSpec.Height := DefaultHeight;
  if Assigned(fCreate) and fCreate(fContext, @lSpec) then
  begin
    if (lSpec.Width > 0) and (lSpec.Height > 0) then
      AComponent.SetBounds(0, 0, lSpec.Width, lSpec.Height);
    if lSpec.Name[0] <> #0 then
      AComponent.Name := StrPas(@lSpec.Name[0]);
  end;
end;

function RegisterOscillogramFactory(AHostContext: Pointer; ATypeId,
  ACaption, AGroupId: PAnsiChar; ACreate: TRecorderPluginCreateComponent;
  APluginContext: Pointer): LongBool; cdecl;
var
  lRuntime: TRecorderPluginRuntime;
  lFactory: TPluginOscillogramFactory;
  lTypeId: string;
  I: Integer;
begin
  Result := False;
  if (AHostContext = nil) or (ATypeId = nil) or (ACreate = nil) then
    Exit;
  lRuntime := TRecorderPluginRuntime(AHostContext);
  lTypeId := StrPas(ATypeId);
  if (lTypeId = '') or lRuntime.fRegistry.IsComponentRegistered(lTypeId) then
    Exit;
  for I := 0 to lRuntime.fPendingFactories.Count - 1 do
    if SameText(TPluginOscillogramFactory(
      lRuntime.fPendingFactories[I]).TypeId, lTypeId) then
      Exit;
  lFactory := TPluginOscillogramFactory.Create(lTypeId, StrPas(ACaption),
    StrPas(AGroupId), ACreate, APluginContext);
  try
    lRuntime.fPendingFactories.Add(lFactory);
    Result := True;
  except
    lFactory.Free;
  end;
end;

constructor TRecorderPluginRuntime.Create(ARegistry: TRecorderComponentFactory);
begin
  inherited Create;
  fRegistry := ARegistry;
  fPlugins := TList.Create;
  fPendingFactories := TList.Create;
end;

destructor TRecorderPluginRuntime.Destroy;
var
  I: Integer;
begin
  for I := fPendingFactories.Count - 1 downto 0 do
    TObject(fPendingFactories[I]).Free;
  fPendingFactories.Free;
  for I := fPlugins.Count - 1 downto 0 do
    TObject(fPlugins[I]).Free;
  fPlugins.Free;
  inherited Destroy;
end;

function TRecorderPluginRuntime.GetLoadedCount: Integer;
begin
  Result := fPlugins.Count;
end;

procedure TRecorderPluginRuntime.LoadConfigured(const AConfigFileName: string);
var
  lCatalog: TRecorderPluginCatalog;
  lPlugin: TLoadedPlugin;
  lCreateClass: TRecorderPluginCreateClass;
  lCreate: TRecorderPluginCreate;
  lGetType: TRecorderPluginGetType;
  lApi: TRecorderPluginHostApi;
  I, J: Integer;
begin
  lCatalog := TRecorderPluginCatalog.Create;
  try
    LoadRecorderPluginConfig(AConfigFileName, lCatalog);
    for I := 0 to lCatalog.Count - 1 do
    begin
      lPlugin := TLoadedPlugin.Create;
      try
        try
        lPlugin.Handle := SafeLoadLibrary(
          IncludeTrailingPathDelimiter(RecorderPluginDirectory) +
          lCatalog.Entries[I].FileName);
        if lPlugin.Handle = NilHandle then
        begin
          RecorderDebugLog('[Plugin] library unavailable ' +
            lCatalog.Entries[I].FileName + ': ' + GetLoadErrorStr);
          Continue;
        end;
        Pointer(lCreateClass) := GetProcedureAddress(lPlugin.Handle,
          'CreatePluginClass');
        Pointer(lGetType) := GetProcedureAddress(lPlugin.Handle,
          'GetPluginType');
        Pointer(lCreate) := GetProcedureAddress(lPlugin.Handle, 'PluginCreate');
        Pointer(lPlugin.CloseProc) := GetProcedureAddress(lPlugin.Handle,
          'PluginClose');
        Pointer(lPlugin.NotifyProc) := GetProcedureAddress(lPlugin.Handle,
          'PluginNotify');
        Pointer(lPlugin.DestroyProc) := GetProcedureAddress(lPlugin.Handle,
          'DestroyPluginClass');
        if not Assigned(lCreateClass) or not Assigned(lCreate) or
          not Assigned(lPlugin.DestroyProc) then
        begin
          RecorderDebugLog('[Plugin] lifecycle exports missing: ' +
            lCatalog.Entries[I].FileName);
          Continue;
        end;
        if Assigned(lGetType) and (lGetType() <> PLUGIN_CLASS) then
        begin
          RecorderDebugLog('[Plugin] unsupported plugin type: ' +
            lCatalog.Entries[I].FileName);
          Continue;
        end;
        lPlugin.Instance := lCreateClass();
        if lPlugin.Instance = nil then
          Continue;
        lApi := Default(TRecorderPluginHostApi);
        lApi.Size := SizeOf(lApi);
        lApi.HostContext := Self;
        lApi.RegisterOscillogramFactory := @RegisterOscillogramFactory;
        if not lCreate(lPlugin.Instance, @lApi) then
        begin
          RecorderDebugLog('[Plugin] PluginCreate rejected: ' +
            lCatalog.Entries[I].FileName);
          Continue;
        end;
        for J := 0 to fPendingFactories.Count - 1 do
          fRegistry.RegisterFactory(TRecorderComponentFactoryBase(
            fPendingFactories[J]));
        fPendingFactories.Clear;
        fPlugins.Add(lPlugin);
        RecorderDebugLog('[Plugin] loaded ' +
          lCatalog.Entries[I].FileName);
        lPlugin := nil;
        except
          on E: Exception do
            RecorderDebugLog('[Plugin] load failed ' +
              lCatalog.Entries[I].FileName + ': ' + E.Message);
        end;
      finally
        for J := fPendingFactories.Count - 1 downto 0 do
          TObject(fPendingFactories[J]).Free;
        fPendingFactories.Clear;
        lPlugin.Free;
      end;
    end;
  finally
    lCatalog.Free;
  end;
end;

procedure TRecorderPluginRuntime.NotifyAll(AEvent: LongInt);
var
  I: Integer;
  lPlugin: TLoadedPlugin;
begin
  for I := 0 to fPlugins.Count - 1 do
  begin
    lPlugin := TLoadedPlugin(fPlugins[I]);
    if not Assigned(lPlugin.NotifyProc) then
      Continue;
    try
      lPlugin.NotifyProc(lPlugin.Instance, AEvent, nil);
    except
      on E: Exception do
        RecorderDebugLog(Format('[Plugin] notify %d failed: %s',
          [AEvent, E.Message]));
    end;
  end;
end;

end.
