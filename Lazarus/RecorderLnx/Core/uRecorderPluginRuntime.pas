unit uRecorderPluginRuntime;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DynLibs, uRecorderFormModel, uRecorderPluginApi,
  uRecorderTags;

type
  TRecorderPluginLogEvent = procedure(const AMessage: string) of object;
  TRecorderPluginRuntime = class
  private
    fRegistry: TRecorderComponentFactory;
    fTagRegistry: TRecorderTagRegistry;
    fProjectDirectory: string;
    fPlugins: TList;
    fPendingFactories: TList;
    fOnLogMessage: TRecorderPluginLogEvent;
    function GetLoadedCount: Integer;
  public
    constructor Create(ARegistry: TRecorderComponentFactory;
      ATagRegistry: TRecorderTagRegistry = nil);
    destructor Destroy; override;
    procedure LoadConfigured(const AConfigFileName: string);
    procedure NotifyAll(AEvent: LongInt);
    function LoadedPluginDetails(const AFileName: string;
      out APath, AVersion: string): Boolean;
    property LoadedCount: Integer read GetLoadedCount;
    property ProjectDirectory: string read fProjectDirectory
      write fProjectDirectory;
    property OnLogMessage: TRecorderPluginLogEvent read fOnLogMessage
      write fOnLogMessage;
  end;

function RecorderPluginRepaint(AComponent: TRecorderVisualComponent;
  AFrame: PRecorderPluginOscillogramFrame): Boolean;

implementation

uses
  uRecorderPluginInfo, uRecorderPluginConfig, uRecorderDebugLog;

type
  TLoadedPlugin = class
    Handle: TLibHandle;
    Instance: Pointer;
    FileName: string;
    Version: string;
    CloseProc: TRecorderPluginClose;
    NotifyProc: TRecorderPluginNotify;
    DestroyProc: TRecorderPluginDestroyClass;
    destructor Destroy; override;
  end;

  TPluginComponentHooks = class
    Component: TRecorderVisualComponent;
    Context: Pointer;
    Repaint: TRecorderPluginOscillogramRepaint;
    Close: TRecorderPluginOscillogramClose;
  end;

  TPluginOscillogramFactory = class(TRecorderComponentFactoryBase)
  private
    fCreate: TRecorderPluginCreateComponent;
    fContext: Pointer;
    fHooks: TList;
    fPendingTagId: Int64;
    fPendingTagName: string;
    function FindHooks(AComponent: TRecorderVisualComponent): TPluginComponentHooks;
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create(const ATypeId, ACaption, AGroup: string;
      ACreate: TRecorderPluginCreateComponent; APluginContext: Pointer);
    destructor Destroy; override;
    function CreateComponent: TRecorderVisualComponent; override;
    function CreateComponentForPage(
      const AContext: TRecorderComponentCreateContext): TRecorderVisualComponent; override;
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent); override;
    function Repaint(AComponent: TRecorderVisualComponent;
      AFrame: PRecorderPluginOscillogramFrame): Boolean;
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
  fHooks := TList.Create;
  ConfigurePalette(ACaption, ACaption, 'oscillogram', 90, rppGroup,
    AGroup);
end;

destructor TPluginOscillogramFactory.Destroy;
begin
  inherited Destroy;
  fHooks.Free;
end;

function TPluginOscillogramFactory.FindHooks(
  AComponent: TRecorderVisualComponent): TPluginComponentHooks;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fHooks.Count - 1 do
    if TPluginComponentHooks(fHooks[I]).Component = AComponent then
      Exit(TPluginComponentHooks(fHooks[I]));
end;

function TPluginOscillogramFactory.CreateComponent: TRecorderVisualComponent;
var
  lHooks: TPluginComponentHooks;
  lSpec: TRecorderPluginComponentSpec;
begin
  Result := inherited CreateComponent;
  TRecorderOscillogramComponent(Result).XScale := 0.3;
  lSpec := Default(TRecorderPluginComponentSpec);
  lSpec.Size := SizeOf(lSpec);
  lSpec.Width := DefaultWidth;
  lSpec.Height := DefaultHeight;
  lSpec.SelectedTagId := fPendingTagId;
  StrPLCopy(@lSpec.SelectedTagName[0], fPendingTagName,
    High(lSpec.SelectedTagName));
  if not Assigned(fCreate) or not fCreate(fContext, @lSpec) then
    Exit;
  if (lSpec.Width > 0) and (lSpec.Height > 0) then
    Result.SetBounds(0, 0, lSpec.Width, lSpec.Height);
  if lSpec.Name[0] <> #0 then
    Result.Name := StrPas(@lSpec.Name[0]);
  if (lSpec.ComponentContext = nil) or not Assigned(lSpec.DoClose) then
    Exit;
  lHooks := TPluginComponentHooks.Create;
  lHooks.Component := Result;
  lHooks.Context := lSpec.ComponentContext;
  lHooks.Repaint := lSpec.DoRepaint;
  lHooks.Close := lSpec.DoClose;
  fHooks.Add(lHooks);
end;

function TPluginOscillogramFactory.CreateComponentForPage(
  const AContext: TRecorderComponentCreateContext): TRecorderVisualComponent;
begin
  fPendingTagId := 0;
  fPendingTagName := '';
  if AContext.SelectedTag <> nil then
  begin
    fPendingTagId := AContext.SelectedTag.Id;
    fPendingTagName := AContext.SelectedTag.Name;
  end;
  try
    Result := inherited CreateComponentForPage(AContext);
  finally
    fPendingTagId := 0;
    fPendingTagName := '';
  end;
end;

procedure TPluginOscillogramFactory.ReleaseComponent(
  AComponent: TRecorderVisualComponent);
var
  lHooks: TPluginComponentHooks;
begin
  lHooks := FindHooks(AComponent);
  if lHooks <> nil then
  begin
    fHooks.Remove(lHooks);
    try
      if Assigned(lHooks.Close) then
        lHooks.Close(lHooks.Context);
    except
      on E: Exception do
        RecorderDebugLog('[Plugin] doClose failed for ' + TypeId +
          ': ' + E.Message);
    end;
    lHooks.Free;
  end;
  inherited ReleaseComponent(AComponent);
end;

function TPluginOscillogramFactory.Repaint(
  AComponent: TRecorderVisualComponent;
  AFrame: PRecorderPluginOscillogramFrame): Boolean;
var
  lHooks: TPluginComponentHooks;
begin
  lHooks := FindHooks(AComponent);
  Result := (lHooks <> nil) and Assigned(lHooks.Repaint);
  if Result then
    try
      Result := lHooks.Repaint(lHooks.Context, AFrame);
    except
      on E: Exception do
      begin
        lHooks.Repaint := nil;
        RecorderDebugLog('[Plugin] doRepaint disabled for ' + TypeId +
          ': ' + E.Message);
        Result := False;
      end;
    end;
end;

function RecorderPluginRepaint(AComponent: TRecorderVisualComponent;
  AFrame: PRecorderPluginOscillogramFrame): Boolean;
begin
  Result := (AComponent <> nil) and
    (AComponent.Factory is TPluginOscillogramFactory);
  if Result then
    Result := TPluginOscillogramFactory(AComponent.Factory).Repaint(
      AComponent, AFrame);
end;

procedure TPluginOscillogramFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  inherited ConfigureNewComponent(AComponent, AContext);
  if AContext.SelectedTag <> nil then
  begin
    TRecorderOscillogramComponent(AComponent).TagId := AContext.SelectedTag.Id;
    TRecorderOscillogramComponent(AComponent).TagName := AContext.SelectedTag.Name;
    TRecorderOscillogramComponent(AComponent).BindingMode := rtbmAbsoluteTag;
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

function PluginTagCount(AHostContext: Pointer): LongInt; cdecl;
var
  lRuntime: TRecorderPluginRuntime;
begin
  Result := 0;
  if AHostContext = nil then Exit;
  lRuntime := TRecorderPluginRuntime(AHostContext);
  if lRuntime.fTagRegistry <> nil then
    Result := lRuntime.fTagRegistry.TagCount;
end;

function PluginGetTagInfo(AHostContext: Pointer; AIndex: LongInt;
  AInfo: PRecorderPluginTagInfo): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
begin
  Result := False;
  if (AHostContext = nil) or (AInfo = nil) or
    (AInfo^.Size < SizeOf(TRecorderPluginTagInfo)) then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  if (lRegistry = nil) or (AIndex < 0) or (AIndex >= lRegistry.TagCount) then
    Exit;
  lTag := lRegistry.Tags[AIndex];
  if lTag = nil then Exit;
  AInfo^.Id := lTag.Id;
  StrPLCopy(@AInfo^.Name[0], UTF8Encode(lTag.Name), High(AInfo^.Name));
  StrPLCopy(@AInfo^.UnitName[0], UTF8Encode(lTag.UnitName),
    High(AInfo^.UnitName));
  AInfo^.IsVirtual := lTag.IsVirtual;
  Result := True;
end;

function PluginReadTagValue(AHostContext: Pointer; AName: PAnsiChar;
  out ATimeSec, AValue: Double): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
begin
  Result := False;
  ATimeSec := 0;
  AValue := 0;
  if (AHostContext = nil) or (AName = nil) then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  if lRegistry = nil then Exit;
  lTag := lRegistry.FindByName(UTF8Decode(StrPas(AName)));
  if (lTag = nil) or (lTag.SignalBuffer.Count = 0) then Exit;
  ATimeSec := lTag.SignalBuffer.LatestTime;
  AValue := lTag.SignalBuffer.LatestValue;
  Result := True;
end;

function PluginPublishTagValue(AHostContext: Pointer; AName: PAnsiChar;
  AValue: Double): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
begin
  Result := False;
  if (AHostContext = nil) or (AName = nil) then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  if lRegistry = nil then Exit;
  lTag := lRegistry.FindByName(UTF8Decode(StrPas(AName)));
  if (lTag = nil) or not lTag.IsVirtual then Exit;
  lRegistry.PublishValue(lTag, AValue);
  Result := True;
end;

function PluginGetProjectDirectory(AHostContext: Pointer; ABuffer: PAnsiChar;
  ABufferSize: LongInt): LongInt; cdecl;
var
  lDirectory: UTF8String;
begin
  Result := 0;
  if AHostContext = nil then Exit;
  lDirectory := UTF8Encode(TRecorderPluginRuntime(AHostContext).fProjectDirectory);
  Result := Length(lDirectory) + 1;
  if (ABuffer = nil) or (ABufferSize < Result) then Exit;
  if Length(lDirectory) > 0 then
    Move(PAnsiChar(lDirectory)^, ABuffer^, Length(lDirectory));
  ABuffer[Length(lDirectory)] := #0;
end;

procedure PluginLogMessage(AHostContext: Pointer; AMessage: PAnsiChar); cdecl;
var
  lRuntime: TRecorderPluginRuntime;
  lMessage: string;
begin
  if (AHostContext = nil) or (AMessage = nil) then Exit;
  lRuntime := TRecorderPluginRuntime(AHostContext);
  lMessage := UTF8Decode(StrPas(AMessage));
  if GetCurrentThreadId = MainThreadID then
  begin
    if Assigned(lRuntime.fOnLogMessage) then
      lRuntime.fOnLogMessage(lMessage)
    else
      RecorderDebugLog('[Lua] ' + lMessage);
  end
  else
    RecorderDebugLog('[Lua worker] ' + lMessage);
end;

constructor TRecorderPluginRuntime.Create(ARegistry: TRecorderComponentFactory;
  ATagRegistry: TRecorderTagRegistry);
begin
  inherited Create;
  fRegistry := ARegistry;
  fTagRegistry := ATagRegistry;
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

function TRecorderPluginRuntime.LoadedPluginDetails(const AFileName: string;
  out APath, AVersion: string): Boolean;
var
  I: Integer;
  lPlugin: TLoadedPlugin;
begin
  APath := '';
  AVersion := '';
  for I := 0 to fPlugins.Count - 1 do
  begin
    lPlugin := TLoadedPlugin(fPlugins[I]);
    if not SameText(ExtractFileName(lPlugin.FileName),
      ExtractFileName(AFileName)) then
      Continue;
    APath := lPlugin.FileName;
    AVersion := lPlugin.Version;
    Exit(True);
  end;
  Result := False;
end;

procedure TRecorderPluginRuntime.LoadConfigured(const AConfigFileName: string);
var
  lCatalog: TRecorderPluginCatalog;
  lPlugin: TLoadedPlugin;
  lCreateClass: TRecorderPluginCreateClass;
  lCreate: TRecorderPluginCreate;
  lGetType: TRecorderPluginGetType;
  lGetInfo: TRecorderPluginGetInfo;
  lInfo: TRecorderPluginInfo;
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
        lPlugin.FileName := ExpandFileName(
          IncludeTrailingPathDelimiter(RecorderPluginDirectory) +
          lCatalog.Entries[I].FileName);
        lPlugin.Handle := SafeLoadLibrary(lPlugin.FileName);
        if lPlugin.Handle = NilHandle then
        begin
          RecorderDebugLog('[Plugin] library unavailable ' +
            lPlugin.FileName + ': ' + GetLoadErrorStr);
          Continue;
        end;
        Pointer(lCreateClass) := GetProcedureAddress(lPlugin.Handle,
          'CreatePluginClass');
        Pointer(lGetType) := GetProcedureAddress(lPlugin.Handle,
          'GetPluginType');
        Pointer(lGetInfo) := GetProcedureAddress(lPlugin.Handle,
          'GetPluginInfo');
        if not Assigned(lGetInfo) then
          Pointer(lGetInfo) := GetProcedureAddress(lPlugin.Handle,
            '_GetPluginInfo');
        if Assigned(lGetInfo) then
        begin
          lInfo := Default(TRecorderPluginInfo);
          lInfo.Version := SizeOf(lInfo);
          lGetInfo(lInfo);
          lPlugin.Version := Format('%d.%d.%d.%d', [lInfo.Version,
            lInfo.SubVersion, lInfo.BugFix, lInfo.BuildNumber]);
        end
        else
          lPlugin.Version := 'GetPluginInfo отсутствует';
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
        lApi.TagCount := @PluginTagCount;
        lApi.GetTagInfo := @PluginGetTagInfo;
        lApi.ReadTagValue := @PluginReadTagValue;
        lApi.PublishTagValue := @PluginPublishTagValue;
        lApi.GetProjectDirectory := @PluginGetProjectDirectory;
        lApi.LogMessage := @PluginLogMessage;
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
        RecorderDebugLog('[Plugin] loaded version=' + lPlugin.Version +
          '; path=' + lPlugin.FileName);
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
