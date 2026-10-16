unit uRecorderPluginRuntime;

{ Architecture boundary:
  This module loads libraries, validates ABI sizes, dispatches notifications,
  and owns plugin-instance lifetime. It must not implement rendering, trigger,
  cursor, legend, or other component behavior. Component discovery must remain
  generic and keep plugin-owned state behind SDK
  callbacks. Plugin callbacks and contexts must be released before FreeLibrary.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DynLibs, uRecorderFormModel, uRecorderPluginApi,
  uRecorderTags, uRecorderAlarms, uRecorderVisualComponentApiV2;

type
  { Host-owned session. The runtime invalidates it before unloading a library,
    so a surviving host surface can safely release an already detached view. }
  TRecorderPluginViewSession = class
  private
    fOwner: TObject;
    fInstance: Pointer;
    fDispatch: TRecorderVisualViewDispatchV2;
    fAttached: Boolean;
    fSurface: TRecorderVisualSurfaceV2;
    fViewId: QWord;
    function SendSurface(AKind: LongWord;
      const ASurface: TRecorderVisualSurfaceV2): LongInt;
    function Send(AKind: LongWord; AInput: Pointer;
      AInputSize: SizeUInt): LongInt;
    procedure Invalidate;
  public
    destructor Destroy; override;
    function Attach(const ASurface: TRecorderVisualSurfaceV2): LongInt;
    function Resize(const ASurface: TRecorderVisualSurfaceV2): LongInt;
    function SetMode(const ASurface: TRecorderVisualSurfaceV2): LongInt;
    function Detach: LongInt;
    function SetDisplayWindow(ASeconds: Double): LongInt;
    function Active: Boolean;
    property Attached: Boolean read fAttached;
  end;

  TRecorderPluginLogEvent = procedure(const AMessage: string) of object;
  TRecorderPluginRuntime = class
  private
    fRegistry: TRecorderComponentFactory;
    fTagRegistry: TRecorderTagRegistry;
    fAlarmEngine: IRecorderAlarmEngine;
    fProjectDirectory: string;
    fPlugins: TList;
    fPendingFactories: TList;
    fOnLogMessage: TRecorderPluginLogEvent;
    fVisualServices: TRecorderVisualHostServicesV2;
    fVisualScratchTimes: TRecorderDoubleArray;
    fVisualScratchValues: TRecorderDoubleArray;
    function GetLoadedCount: Integer;
  public
    constructor Create(ARegistry: TRecorderComponentFactory; ATagRegistry: TRecorderTagRegistry = nil; AAlarmEngine: IRecorderAlarmEngine = nil);
    destructor Destroy; override;
    procedure LoadConfigured(const AConfigFileName: string);
    procedure NotifyAll(AEvent: LongInt);
    procedure NotifyCatalogChanged;
    function LoadedPluginDetails(const AFileName: string; out APath, AVersion: string): Boolean;
    property LoadedCount: Integer read GetLoadedCount;
    property ProjectDirectory: string read fProjectDirectory write fProjectDirectory;
    property OnLogMessage: TRecorderPluginLogEvent read fOnLogMessage write fOnLogMessage;
  end;

function RecorderPluginVisualHasRuntime( AComponent: TRecorderPluginVisualComponent): Boolean;
function RecorderPluginVisualLoadState( AComponent: TRecorderPluginVisualComponent): Boolean;
function RecorderPluginVisualSaveState( AComponent: TRecorderPluginVisualComponent): Boolean;
function RecorderPluginVisualEdit(AComponent: TRecorderPluginVisualComponent;
  const ARequest: TRecorderVisualEditRequestV2): LongInt;
function RecorderPluginVisualOpenView(AComponent: TRecorderPluginVisualComponent):
  TRecorderPluginViewSession;

implementation

uses
  Math, uRecorderPluginInfo, uRecorderPluginConfig, uRecorderDebugLog,
  uRecorderUnitManager;

function EnumerateVisualTagsV2(AContext: Pointer; AIndex: LongWord;
  AInfo: PRecorderVisualTagInfoV2): LongInt; cdecl;
var
  lRuntime: TRecorderPluginRuntime;
  lTag: TRecorderTag;
  lInfoSize: LongWord;
begin
  if (AContext = nil) or (AInfo = nil) then
    Exit(REC_VISUAL_ERROR);
  lInfoSize := AInfo^.Header.Size;
  if (lInfoSize < SizeOf(TRecorderVisualTagInfoV2)) or
    (AInfo^.Header.AbiMajor <> REC_VISUAL_ABI_V2_MAJOR) then
    Exit(REC_VISUAL_ERROR);
  lRuntime := TRecorderPluginRuntime(AContext);
  try
  if lRuntime.fTagRegistry = nil then
    Exit(REC_VISUAL_END_OF_ENUMERATION);
  if AIndex >= LongWord(lRuntime.fTagRegistry.TagCount) then
    Exit(REC_VISUAL_END_OF_ENUMERATION);
  lTag := lRuntime.fTagRegistry.Tags[AIndex];
  if lTag = nil then
    Exit(REC_VISUAL_ERROR);
  FillChar(AInfo^, SizeOf(AInfo^), 0);
  AInfo^.Header.Size := SizeOf(AInfo^);
  AInfo^.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  AInfo^.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  AInfo^.TagId := lTag.Id;
  if lTag.IsVirtual then
    AInfo^.Flags := AInfo^.Flags or REC_VISUAL_TAG_FLAG_VIRTUAL;
  if lTag.IsVector then
    AInfo^.Flags := AInfo^.Flags or REC_VISUAL_TAG_FLAG_VECTOR;
  if lTag.AutoRange then
    AInfo^.Flags := AInfo^.Flags or REC_VISUAL_TAG_FLAG_AUTO_RANGE;
  if RecorderTagSourceIsVisible(lRuntime.fTagRegistry, lTag) then
    AInfo^.Flags := AInfo^.Flags or REC_VISUAL_TAG_FLAG_SOURCE_VISIBLE;
  AInfo^.PollFrequencyHz := lTag.PollFrequencyHz;
  AInfo^.RangeMin := lTag.RangeMin;
  AInfo^.RangeMax := lTag.RangeMax;
  StrPLCopy(@AInfo^.Name[0], UTF8Encode(lTag.Name), High(AInfo^.Name));
  StrPLCopy(@AInfo^.UnitName[0], UTF8Encode(lTag.UnitName), High(AInfo^.UnitName));
  StrPLCopy(@AInfo^.Address[0], UTF8Encode(lTag.Address), High(AInfo^.Address));
  StrPLCopy(@AInfo^.Description[0], UTF8Encode(lTag.Description),
    High(AInfo^.Description));
  Result := REC_VISUAL_OK;
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

function CopyLatestVisualTagHistoryV2(AContext: Pointer; ATagId: QWord;
  AWindowSeconds: Double; ATimes, AValues: PDouble; ACapacity: LongWord;
  out ACount: LongWord; out ARevision: QWord;
  out AWindowStartSec, ALatestTimeSec: Double): LongInt; cdecl;
var
  lRuntime: TRecorderPluginRuntime;
  lTag: TRecorderTag;
  lSampleCount: Integer;
begin
  ACount := 0;
  ARevision := 0;
  AWindowStartSec := 0;
  ALatestTimeSec := 0;
  if (AContext = nil) or (ATagId = 0) or IsNan(AWindowSeconds) or
    IsInfinite(AWindowSeconds) or (AWindowSeconds < 0) then
    Exit(REC_VISUAL_ERROR);
  lRuntime := TRecorderPluginRuntime(AContext);
  if lRuntime.fTagRegistry = nil then
    Exit(REC_VISUAL_NOT_FOUND);
  try
  lTag := lRuntime.fTagRegistry.FindById(ATagId);
  if lTag = nil then
    Exit(REC_VISUAL_NOT_FOUND);
  { Scratch arrays are runtime-owned and reused. ABI callbacks are serialized
    on the UI thread; capacity grows only when a larger window is requested. }
  lTag.CopyLatestInto(AWindowSeconds, lRuntime.fVisualScratchTimes,
    lRuntime.fVisualScratchValues, lSampleCount, AWindowStartSec, ARevision);
  ACount := lSampleCount;
  if lSampleCount > 0 then
    ALatestTimeSec := lRuntime.fVisualScratchTimes[lSampleCount - 1];
  if ACapacity < ACount then
    Exit(REC_VISUAL_BUFFER_TOO_SMALL);
  if (ACount > 0) and ((ATimes = nil) or (AValues = nil)) then
    Exit(REC_VISUAL_ERROR);
  if ACount > 0 then
  begin
    Move(lRuntime.fVisualScratchTimes[0], ATimes^,
      SizeUInt(ACount) * SizeOf(Double));
    Move(lRuntime.fVisualScratchValues[0], AValues^,
      SizeUInt(ACount) * SizeOf(Double));
  end;
  Result := REC_VISUAL_OK;
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

function VisualServiceTag(AContext: Pointer; ATagId: QWord): TRecorderTag;
var
  lRuntime: TRecorderPluginRuntime;
begin
  Result := nil;
  if (AContext = nil) or (ATagId = 0) or (ATagId > QWord(High(Int64))) then
    Exit;
  lRuntime := TRecorderPluginRuntime(AContext);
  if lRuntime.fTagRegistry <> nil then
    Result := lRuntime.fTagRegistry.FindById(ATagId);
end;

function ValidVisualOutput(AHeader: PRecorderVisualAbiHeaderV2;
  ASize: SizeUInt): Boolean;
begin
  Result := (AHeader <> nil) and (AHeader^.Size >= ASize) and
    (AHeader^.AbiMajor = REC_VISUAL_ABI_V2_MAJOR);
end;

procedure InitVisualOutput(AOutput: Pointer; ASize: SizeUInt);
begin
  FillChar(AOutput^, ASize, 0);
  PRecorderVisualAbiHeaderV2(AOutput)^.Size := ASize;
  PRecorderVisualAbiHeaderV2(AOutput)^.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  PRecorderVisualAbiHeaderV2(AOutput)^.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
end;

function CopyRangeVisualHistoryV2(AContext: Pointer; ATagId: QWord;
  AFromTimeSec, AToTimeSec: Double; AIncludePrevious: LongWord;
  ATimes, AValues: PDouble; ACapacity: LongWord; out ACount: LongWord;
  out ARevision: QWord; out AWindowStartSec, ALatestTimeSec: Double): LongInt; cdecl;
var
  lRuntime: TRecorderPluginRuntime;
  lTag: TRecorderTag;
  lCount: Integer;
begin
  ACount := 0;
  ARevision := 0;
  AWindowStartSec := 0;
  ALatestTimeSec := 0;
  if (AContext = nil) or IsNan(AFromTimeSec) or IsInfinite(AFromTimeSec) or
    IsNan(AToTimeSec) or IsInfinite(AToTimeSec) or
    (AFromTimeSec > AToTimeSec) or (AIncludePrevious > 1) then
    Exit(REC_VISUAL_ERROR);
  try
    lTag := VisualServiceTag(AContext, ATagId);
    if lTag = nil then Exit(REC_VISUAL_NOT_FOUND);
    lRuntime := TRecorderPluginRuntime(AContext);
    lTag.CopyRangeInto(AFromTimeSec, AToTimeSec, AIncludePrevious <> 0,
      lRuntime.fVisualScratchTimes, lRuntime.fVisualScratchValues,
      lCount, ARevision, ALatestTimeSec);
    ACount := lCount;
    AWindowStartSec := AFromTimeSec;
    if ACount > 0 then AWindowStartSec := lRuntime.fVisualScratchTimes[0];
    if ACapacity < ACount then Exit(REC_VISUAL_BUFFER_TOO_SMALL);
    if (ACount > 0) and ((ATimes = nil) or (AValues = nil)) then
      Exit(REC_VISUAL_ERROR);
    if ACount > 0 then
    begin
      Move(lRuntime.fVisualScratchTimes[0], ATimes^, SizeUInt(ACount)*SizeOf(Double));
      Move(lRuntime.fVisualScratchValues[0], AValues^, SizeUInt(ACount)*SizeOf(Double));
    end;
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function GetVisualSignalInfoV2(AContext: Pointer; ATagId: QWord;
  AInfo: PRecorderVisualSignalInfoV2): LongInt; cdecl;
var
  lTag: TRecorderTag;
  lCount: Integer;
begin
  if not ValidVisualOutput(PRecorderVisualAbiHeaderV2(AInfo), SizeOf(AInfo^)) then
    Exit(REC_VISUAL_ERROR);
  try
    InitVisualOutput(AInfo, SizeOf(AInfo^));
    lTag := VisualServiceTag(AContext, ATagId);
    if lTag = nil then Exit(REC_VISUAL_NOT_FOUND);
    lTag.ReadSignalInfo(AInfo^.Revision, AInfo^.BlockCounter, lCount,
      AInfo^.LatestTimeSec);
    AInfo^.Count := lCount;
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function GetVisualSelectedTagIdV2(AContext: Pointer;
  out ATagId: QWord): LongInt; cdecl;
var
  lRuntime: TRecorderPluginRuntime;
  lTag: TRecorderTag;
begin
  ATagId := 0;
  if AContext = nil then Exit(REC_VISUAL_ERROR);
  try
    lRuntime := TRecorderPluginRuntime(AContext);
    if lRuntime.fTagRegistry = nil then Exit(REC_VISUAL_NOT_FOUND);
    lTag := lRuntime.fTagRegistry.SelectedTag;
    if lTag = nil then Exit(REC_VISUAL_NOT_FOUND);
    ATagId := lTag.Id;
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function ReadVisualEstimateV2(AContext: Pointer; ATagId: QWord;
  AKind: LongWord; AEstimate: PRecorderVisualEstimateV2): LongInt; cdecl;
var
  lTag: TRecorderTag;
  lEstimate: TRecorderTagEstimate;
begin
  if (AKind > REC_VISUAL_ESTIMATE_LAST) or
    not ValidVisualOutput(PRecorderVisualAbiHeaderV2(AEstimate), SizeOf(AEstimate^)) then
    Exit(REC_VISUAL_ERROR);
  try
    InitVisualOutput(AEstimate, SizeOf(AEstimate^));
    lTag := VisualServiceTag(AContext, ATagId);
    if lTag = nil then Exit(REC_VISUAL_NOT_FOUND);
    lEstimate := lTag.Estimate(TRecorderTagEstimateKind(AKind));
    AEstimate^.Kind := AKind;
    AEstimate^.Valid := Ord(lEstimate.Valid);
    AEstimate^.Count := Max(0, lEstimate.Count);
    AEstimate^.Value := lEstimate.Value;
    AEstimate^.StartTimeSec := lEstimate.StartTimeSec;
    AEstimate^.EndTimeSec := lEstimate.EndTimeSec;
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function GetVisualEstimateSettingsV2(AContext: Pointer; ATagId: QWord;
  ASettings: PRecorderVisualEstimateSettingsV2): LongInt; cdecl;
var
  lTag: TRecorderTag;
  lSettings: TRecorderTagEstimateSettings;
  lKind: TRecorderTagEstimateKind;
begin
  if not ValidVisualOutput(PRecorderVisualAbiHeaderV2(ASettings), SizeOf(ASettings^)) then
    Exit(REC_VISUAL_ERROR);
  try
    InitVisualOutput(ASettings, SizeOf(ASettings^));
    lTag := VisualServiceTag(AContext, ATagId);
    if lTag = nil then Exit(REC_VISUAL_NOT_FOUND);
    lSettings := lTag.EstimateSettings;
    for lKind := Low(lKind) to High(lKind) do
      if lSettings.EnabledKinds[lKind] then
        ASettings^.EnabledKinds := ASettings^.EnabledKinds or (QWord(1) shl Ord(lKind));
    ASettings^.DefaultKind := Ord(lSettings.DefaultKind);
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function EnumerateVisualUnitsV2(AContext: Pointer; AIndex: LongWord;
  AInfo: PRecorderVisualUnitInfoV2): LongInt; cdecl;
var
  lNames: TStringList;
  lUnit: TRecorderUnitInfo;
begin
  if (AContext = nil) or
    not ValidVisualOutput(PRecorderVisualAbiHeaderV2(AInfo), SizeOf(AInfo^)) then
    Exit(REC_VISUAL_ERROR);
  lNames := nil;
  try
    try
    lNames := TStringList.Create;
    RecorderUnitManager.FillUnitNames(lNames);
    if AIndex >= LongWord(lNames.Count) then Exit(REC_VISUAL_END_OF_ENUMERATION);
    if not RecorderUnitManager.TryGetUnitInfo(lNames[AIndex], lUnit) then
      Exit(REC_VISUAL_ERROR);
    InitVisualOutput(AInfo, SizeOf(AInfo^));
    AInfo^.ScaleToBase := lUnit.ScaleToBase;
    StrPLCopy(@AInfo^.Name[0], UTF8Encode(lUnit.Name), High(AInfo^.Name));
    StrPLCopy(@AInfo^.BaseUnitName[0], UTF8Encode(lUnit.BaseUnitName), High(AInfo^.BaseUnitName));
    StrPLCopy(@AInfo^.QuantityId[0], UTF8Encode(lUnit.QuantityId), High(AInfo^.QuantityId));
    Result := REC_VISUAL_OK;
    except Result := REC_VISUAL_ERROR;
    end;
  finally
    lNames.Free;
  end;
end;

function VisualConversionFactorV2(AContext: Pointer; AFromUnit,
  AToUnit: PAnsiChar; out AFactor: Double): LongInt; cdecl;
begin
  AFactor := 0;
  if (AContext = nil) or (AFromUnit = nil) or (AToUnit = nil) then
    Exit(REC_VISUAL_ERROR);
  try
    if RecorderUnitManager.TryGetConversionFactor(UTF8Decode(StrPas(AFromUnit)),
      UTF8Decode(StrPas(AToUnit)), AFactor) then Result := REC_VISUAL_OK
    else Result := REC_VISUAL_NOT_FOUND;
  except Result := REC_VISUAL_ERROR; end;
end;

type
  TLoadedPlugin = class
    Handle: TLibHandle;
    Instance: Pointer;
    FileName: string;
    Version: string;
    CloseProc: TRecorderPluginClose;
    NotifyProc: TRecorderPluginNotify;
    DestroyProc: TRecorderPluginDestroyClass;
    FactoryTypeIds: TStringList;
    IsVisualV2: Boolean;
    UnloadSafe: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TPluginVisualHooks = class
    Component: TRecorderPluginVisualComponent;
    Instance: Pointer;
    Views: TList;
    LibraryOwner: TLoadedPlugin;
  end;

  TPluginVisualFactory = class(TRecorderComponentFactoryBase)
  private
    fDescriptor: TRecorderVisualComponentDescriptorV2;
    fHostContext: Pointer;
    fHooks: TList;
    fNextViewId: QWord;
    fLibraryOwner: TLoadedPlugin;
    function FindHooks(AComponent: TRecorderVisualComponent):
      TPluginVisualHooks;
    procedure DestroyInstanceSafe(AInstance: Pointer);
    function Dispatch(AComponent: TRecorderPluginVisualComponent;
      AKind: LongWord): Boolean;
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create(const ATypeId, ACaption, AGroup: string;
      const ADescriptor: TRecorderVisualComponentDescriptorV2;
      AHostContext: Pointer; ALibraryOwner: TLoadedPlugin);
    destructor Destroy; override;
    function CreateComponent: TRecorderVisualComponent; override;
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent); override;
    function LoadState(AComponent: TRecorderPluginVisualComponent): Boolean;
    function SaveState(AComponent: TRecorderPluginVisualComponent): Boolean;
    function ImportLegacyState(AComponent: TRecorderPluginVisualComponent): Boolean;
    function EditState(AComponent: TRecorderPluginVisualComponent;
      const ARequest: TRecorderVisualEditRequestV2): LongInt;
    function OpenView(AComponent: TRecorderPluginVisualComponent):
      TRecorderPluginViewSession;
    function LoadOpaqueComponentState(
      AComponent: TRecorderVisualComponent): TRecorderOpaqueStateResult; override;
    function SaveOpaqueComponentState(
      AComponent: TRecorderVisualComponent): TRecorderOpaqueStateResult; override;
    function CopyOpaqueComponentState(ASource, ATarget: TRecorderVisualComponent):
      TRecorderOpaqueStateResult; override;
    procedure DoStart; override;
    procedure DoStop; override;
    procedure DoUpdateData; override;
    procedure CatalogChanged;
  end;


constructor TLoadedPlugin.Create;
begin
  inherited Create;
  Handle := NilHandle;
  UnloadSafe := True;
  FactoryTypeIds := TStringList.Create;
end;

destructor TLoadedPlugin.Destroy;
begin
  if Assigned(CloseProc) and (Instance <> nil) then
    CloseProc(Instance);
  if Assigned(DestroyProc) and (Instance <> nil) then
    DestroyProc(Instance);
  FactoryTypeIds.Free;
  if (Handle <> NilHandle) and UnloadSafe then
    FreeLibrary(Handle);
  if not UnloadSafe then
    RecorderDebugLog('[Plugin V2] Keeping library loaded after failed destruction: ' + FileName);
  inherited Destroy;
end;


constructor TPluginVisualFactory.Create(const ATypeId, ACaption, AGroup: string;
  const ADescriptor: TRecorderVisualComponentDescriptorV2;
  AHostContext: Pointer; ALibraryOwner: TLoadedPlugin);
begin
  inherited Create(ATypeId, ACaption, TRecorderPluginVisualComponent, 320, 180,
    False);
  fDescriptor := ADescriptor;
  if not RecorderVisualFieldPresentV2(ADescriptor.Header.Size,
    PtrUInt(@ADescriptor.Edit)-PtrUInt(@ADescriptor),SizeOf(ADescriptor.Edit)) then
    fDescriptor.Edit := nil;
  if not RecorderVisualFieldPresentV2(ADescriptor.Header.Size,
    PtrUInt(@ADescriptor.ViewDispatch)-PtrUInt(@ADescriptor),SizeOf(ADescriptor.ViewDispatch)) then
    fDescriptor.ViewDispatch := nil;
  if not RecorderVisualFieldPresentV2(ADescriptor.Header.Size,
    PtrUInt(@ADescriptor.ImportState)-PtrUInt(@ADescriptor),SizeOf(ADescriptor.ImportState)) then
    fDescriptor.ImportState := nil;
  if not RecorderVisualFieldPresentV2(ADescriptor.Header.Size,
    PtrUInt(@ADescriptor.TryDestroyInstance)-PtrUInt(@ADescriptor),
    SizeOf(ADescriptor.TryDestroyInstance)) then
    fDescriptor.TryDestroyInstance := nil;
  fHostContext := AHostContext;
  fLibraryOwner := ALibraryOwner;
  fHooks := TList.Create;
  ConfigurePalette(ACaption, ACaption, 'plugin-visual-component', 90,
    rppGroup, AGroup);
end;

destructor TPluginVisualFactory.Destroy;
begin
  inherited Destroy;
  fHooks.Free;
end;

function TPluginVisualFactory.FindHooks(
  AComponent: TRecorderVisualComponent): TPluginVisualHooks;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fHooks.Count - 1 do
    if TPluginVisualHooks(fHooks[I]).Component = AComponent then
      Exit(TPluginVisualHooks(fHooks[I]));
end;

function TPluginVisualFactory.CreateComponent: TRecorderVisualComponent;
var
  lHooks: TPluginVisualHooks;
  lInstance: Pointer;
  lStatus: LongInt;
begin
  Result := inherited CreateComponent;
  TRecorderPluginVisualComponent(Result).PluginTypeId := TypeId;
  lInstance := nil;
  try
    lStatus := fDescriptor.CreateInstance(fHostContext, nil, 0, lInstance);
  except
    Result.Free;
    raise;
  end;
  if (lStatus <> REC_VISUAL_OK) or (lInstance = nil) then
  begin
    if lInstance <> nil then
      DestroyInstanceSafe(lInstance);
    Result.Free;
    raise ERecorderFormError.CreateFmt(
      'Plugin visual instance creation failed: %s (%d)', [TypeId, lStatus]);
  end;
  lHooks := TPluginVisualHooks.Create;
  lHooks.Component := TRecorderPluginVisualComponent(Result);
  lHooks.Instance := lInstance;
  lHooks.Views := TList.Create;
  lHooks.LibraryOwner := fLibraryOwner;
  fHooks.Add(lHooks);
end;

procedure TPluginVisualFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lHooks: TPluginVisualHooks;
  lContext: TRecorderVisualCreateContextV2;
  lOutputSize: SizeUInt;
  lStatus: LongInt;
begin
  inherited ConfigureNewComponent(AComponent, AContext);
  lHooks := FindHooks(AComponent);
  if (lHooks = nil) or not Assigned(fDescriptor.ViewDispatch) then Exit;
  FillChar(lContext, SizeOf(lContext), 0);
  lContext.Header.Size := SizeOf(lContext);
  lContext.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  lContext.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  lContext.ComponentNo := AContext.ComponentNo;
  if AContext.SelectedTag <> nil then
    lContext.SelectedTagId := AContext.SelectedTag.Id;
  if AContext.DefaultTag <> nil then
    lContext.DefaultTagId := AContext.DefaultTag.Id;
  lOutputSize := 0;
  lStatus := fDescriptor.ViewDispatch(lHooks.Instance,
    REC_VISUAL_DISPATCH_CONFIGURE, @lContext, SizeOf(lContext), nil, 0,
    lOutputSize);
  if not (lStatus in [REC_VISUAL_OK, REC_VISUAL_NOT_HANDLED]) then
    raise ERecorderFormError.CreateFmt(
      'Plugin visual configuration failed: %s (%d)', [TypeId, lStatus]);
end;

procedure TPluginVisualFactory.ReleaseComponent(
  AComponent: TRecorderVisualComponent);
var
  lHooks: TPluginVisualHooks;
  I: Integer;
begin
  lHooks := FindHooks(AComponent);
  if lHooks <> nil then
  begin
    fHooks.Remove(lHooks);
    for I := lHooks.Views.Count - 1 downto 0 do
      if TRecorderPluginViewSession(lHooks.Views[I]).Detach <> REC_VISUAL_OK then
      begin
        fLibraryOwner.UnloadSafe := False;
        RecorderDebugLog('[Plugin V2] View detach failed; destroying instance: ' + TypeId);
      end;
    DestroyInstanceSafe(lHooks.Instance);
    for I := lHooks.Views.Count - 1 downto 0 do
      TRecorderPluginViewSession(lHooks.Views[I]).Invalidate;
    lHooks.Views.Free;
    lHooks.Free;
  end;
  inherited ReleaseComponent(AComponent);
end;

procedure TPluginVisualFactory.DestroyInstanceSafe(AInstance: Pointer);
var lStatus: LongInt;
begin
  try
    if Assigned(fDescriptor.TryDestroyInstance) then
      lStatus := fDescriptor.TryDestroyInstance(AInstance)
    else
    begin
      fDescriptor.DestroyInstance(AInstance);
      lStatus := REC_VISUAL_OK;
    end;
    if lStatus <> REC_VISUAL_OK then
    begin
      fLibraryOwner.UnloadSafe := False;
      RecorderDebugLog(Format('[Plugin V2] DestroyInstance status=%d; DLL pinned: %s',
        [lStatus,TypeId]));
    end;
  except
    on E: Exception do
    begin
      fLibraryOwner.UnloadSafe := False;
      RecorderDebugLog('[Plugin V2] DestroyInstance exception; DLL pinned: ' +
        TypeId + ': ' + E.Message);
    end;
  end;
end;

function TPluginVisualFactory.LoadState(
  AComponent: TRecorderPluginVisualComponent): Boolean;
var
  lHooks: TPluginVisualHooks;
  lState: TRecorderPluginConfigBytes;
  lStatePointer: Pointer;
  lStatus: LongInt;
begin
  Result := False;
  lHooks := FindHooks(AComponent);
  if lHooks = nil then
    Exit;
  if not AComponent.ConfigStatePresent then
    Exit(True);
  lState := AComponent.ConfigBlob;
  if Length(lState) > REC_VISUAL_MAX_STATE_BYTES then
    Exit;
  lStatePointer := nil;
  if Length(lState) > 0 then
    lStatePointer := @lState[0];
  try
    lStatus := fDescriptor.LoadState(lHooks.Instance, lStatePointer,
      Length(lState));
  except
    on E: Exception do
    begin
      RecorderDebugLog('[Plugin V2] LoadState failed for ' + TypeId +
        ': ' + E.Message);
      Exit;
    end;
  end;
  Result := lStatus = REC_VISUAL_OK;
end;

function TPluginVisualFactory.SaveState(
  AComponent: TRecorderPluginVisualComponent): Boolean;
var
  lHooks: TPluginVisualHooks;
  lRequired, lWritten: SizeUInt;
  lStatus: LongInt;
  lState: TRecorderPluginConfigBytes;
begin
  Result := False;
  lHooks := FindHooks(AComponent);
  if lHooks = nil then
    Exit;
  lRequired := 0;
  try
    lStatus := fDescriptor.SaveState(lHooks.Instance, nil, 0, lRequired);
    if (lRequired > REC_VISUAL_MAX_STATE_BYTES) then
      Exit;
    if lStatus = REC_VISUAL_OK then
    begin
      if lRequired <> 0 then
        Exit;
      SetLength(lState, 0);
    end
    else if lStatus = REC_VISUAL_BUFFER_TOO_SMALL then
    begin
      if lRequired = 0 then
        Exit;
      SetLength(lState, lRequired);
      lWritten := 0;
      lStatus := fDescriptor.SaveState(lHooks.Instance, @lState[0],
        Length(lState), lWritten);
      if (lStatus <> REC_VISUAL_OK) or (lWritten <> Length(lState)) then
        Exit;
    end
    else
      Exit;
  except
    on E: Exception do
    begin
      RecorderDebugLog('[Plugin V2] SaveState failed for ' + TypeId +
        ': ' + E.Message);
      Exit;
    end;
  end;
  { Commit only after the plugin produced a complete, validated payload. }
  AComponent.ConfigBlob := lState;
  AComponent.ConfigStatePresent := True;
  Result := True;
end;

function TPluginVisualFactory.LoadOpaqueComponentState(
  AComponent: TRecorderVisualComponent): TRecorderOpaqueStateResult;
begin
  if not (AComponent is TRecorderPluginVisualComponent) then
    Exit(rosNotHandled);
  if not TRecorderPluginVisualComponent(AComponent).ConfigStatePresent then
    Exit(rosSuccess);
  if TRecorderPluginVisualComponent(AComponent).ConfigSchemaId =
    REC_VISUAL_STATE_INI_SECTION_V1 then
  begin
    if ImportLegacyState(TRecorderPluginVisualComponent(AComponent)) then
      Exit(rosSuccess)
    else Exit(rosFailure);
  end;
  if LoadState(TRecorderPluginVisualComponent(AComponent)) then
    Result := rosSuccess
  else
    Result := rosFailure;
end;

function TPluginVisualFactory.ImportLegacyState(
  AComponent: TRecorderPluginVisualComponent): Boolean;
var
  lHooks: TPluginVisualHooks;
  lRequest: TRecorderVisualImportRequestV2;
  lLegacy, lBefore: TRecorderPluginConfigBytes;
  lStatus: LongInt;
  lBeforeData: Pointer;
begin
  Result := False;
  lHooks := FindHooks(AComponent);
  if (lHooks = nil) or not Assigned(fDescriptor.ImportState) then Exit;
  lLegacy := AComponent.ConfigBlob;
  if (Length(lLegacy)=0) or not SaveState(AComponent) then Exit;
  lBefore := AComponent.ConfigBlob;
  AComponent.ConfigBlob := lLegacy;
  lRequest := Default(TRecorderVisualImportRequestV2);
  lRequest.Header.Size := SizeOf(lRequest);
  lRequest.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  lRequest.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  StrPLCopy(@lRequest.FormatId[0], REC_VISUAL_STATE_INI_SECTION_V1,
    High(lRequest.FormatId));
  StrPLCopy(@lRequest.OriginalTypeId[0], AComponent.PluginTypeId,
    High(lRequest.OriginalTypeId));
  lRequest.Data := @lLegacy[0];
  lRequest.DataSize := Length(lLegacy);
  try
    lStatus := fDescriptor.ImportState(lHooks.Instance,@lRequest,SizeOf(lRequest));
    if (lStatus = REC_VISUAL_OK) and SaveState(AComponent) then
    begin
      AComponent.ConfigSchemaId := TypeId;
      AComponent.ConfigSchemaVersion := 1;
      AComponent.PluginTypeId := TypeId;
      Exit(True);
    end;
  except
    on E: Exception do
      RecorderDebugLog('[Plugin V2] Import failed for ' + TypeId + ': ' + E.Message);
  end;
  { Restore the live instance from its native snapshot, not from the foreign
    envelope. A rejected callback or failed Save leaves the input available. }
  lBeforeData := nil;
  if Length(lBefore)>0 then lBeforeData := @lBefore[0];
  try
    lStatus := fDescriptor.LoadState(lHooks.Instance,lBeforeData,Length(lBefore));
    if lStatus <> REC_VISUAL_OK then
      RecorderDebugLog('[Plugin V2] Import rollback failed for ' + TypeId);
  except
    on E: Exception do
      RecorderDebugLog('[Plugin V2] Import rollback exception: ' + E.Message);
  end;
  AComponent.ConfigBlob := lLegacy;
end;

function TPluginVisualFactory.SaveOpaqueComponentState(
  AComponent: TRecorderVisualComponent): TRecorderOpaqueStateResult;
begin
  if not (AComponent is TRecorderPluginVisualComponent) then
    Exit(rosNotHandled);
  if SaveState(TRecorderPluginVisualComponent(AComponent)) then
    Result := rosSuccess
  else
    Result := rosFailure;
end;

function TPluginVisualFactory.CopyOpaqueComponentState(ASource,
  ATarget: TRecorderVisualComponent): TRecorderOpaqueStateResult;
var
  lSource, lTarget: TRecorderPluginVisualComponent;
begin
  if not (ASource is TRecorderPluginVisualComponent) or
    not (ATarget is TRecorderPluginVisualComponent) then
    Exit(rosNotHandled);
  lSource := TRecorderPluginVisualComponent(ASource);
  lTarget := TRecorderPluginVisualComponent(ATarget);
  if not SaveState(lSource) then
    Exit(rosFailure);
  lTarget.ConfigSchemaId := lSource.ConfigSchemaId;
  lTarget.ConfigSchemaVersion := lSource.ConfigSchemaVersion;
  lTarget.ConfigBlob := lSource.ConfigBlob;
  lTarget.ConfigStatePresent := lSource.ConfigStatePresent;
  if not LoadState(lTarget) then
    Exit(rosFailure);
  Result := rosSuccess;
end;

function TPluginVisualFactory.Dispatch(
  AComponent: TRecorderPluginVisualComponent; AKind: LongWord): Boolean;
var
  lHooks: TPluginVisualHooks;
  lOutputSize: SizeUInt;
  lStatus: LongInt;
begin
  Result := False;
  if not Assigned(fDescriptor.ViewDispatch) then
    Exit;
  lHooks := FindHooks(AComponent);
  if lHooks = nil then
    Exit;
  lOutputSize := 0;
  try
    lStatus := fDescriptor.ViewDispatch(lHooks.Instance, AKind, nil, 0,
      nil, 0, lOutputSize);
  except
    on E: Exception do
    begin
      RecorderDebugLog('[Plugin V2] ViewDispatch failed for ' + TypeId +
        ': ' + E.Message);
      Exit;
    end;
  end;
  Result := lStatus in [REC_VISUAL_OK, REC_VISUAL_NOT_HANDLED];
end;

procedure TPluginVisualFactory.DoStart;
var
  I: Integer;
begin
  for I := 0 to ChildCount - 1 do
    Dispatch(TRecorderPluginVisualComponent(Children[I]),
      REC_VISUAL_DISPATCH_START);
end;

procedure TPluginVisualFactory.CatalogChanged;
var I: Integer;
begin
  for I := 0 to ChildCount - 1 do
    if not Dispatch(TRecorderPluginVisualComponent(Children[I]),
      REC_VISUAL_DISPATCH_CATALOG_CHANGED) then
      RecorderDebugLog('[Plugin V2] Catalog refresh failed for ' + TypeId);
end;

procedure TPluginVisualFactory.DoStop;
var
  I: Integer;
begin
  for I := 0 to ChildCount - 1 do
    Dispatch(TRecorderPluginVisualComponent(Children[I]),
      REC_VISUAL_DISPATCH_STOP);
end;

procedure TPluginVisualFactory.DoUpdateData;
var
  I: Integer;
begin
  for I := 0 to ChildCount - 1 do
    Dispatch(TRecorderPluginVisualComponent(Children[I]),
      REC_VISUAL_DISPATCH_DATA_UPDATED);
end;

function RecorderPluginVisualHasRuntime(
  AComponent: TRecorderPluginVisualComponent): Boolean;
begin
  Result := (AComponent <> nil) and
    (AComponent.Factory is TPluginVisualFactory);
end;

function RecorderPluginVisualLoadState(
  AComponent: TRecorderPluginVisualComponent): Boolean;
begin
  Result := False;
  if not RecorderPluginVisualHasRuntime(AComponent) then
    Exit;
  Result := TPluginVisualFactory(AComponent.Factory).LoadState(AComponent);
end;

function RecorderPluginVisualSaveState(
  AComponent: TRecorderPluginVisualComponent): Boolean;
begin
  Result := False;
  if not RecorderPluginVisualHasRuntime(AComponent) then
    Exit;
  Result := TPluginVisualFactory(AComponent.Factory).SaveState(AComponent);
end;

function TPluginVisualFactory.EditState(
  AComponent: TRecorderPluginVisualComponent;
  const ARequest: TRecorderVisualEditRequestV2): LongInt;
var
  lHooks: TPluginVisualHooks;
  lBefore: TRecorderPluginConfigBytes;
begin
  Result := REC_VISUAL_NOT_HANDLED;
  lHooks := FindHooks(AComponent);
  if (lHooks = nil) or not Assigned(fDescriptor.Edit) then Exit;
  if not SaveState(AComponent) then Exit(REC_VISUAL_ERROR);
  lBefore := AComponent.ConfigBlob;
  try
    Result := fDescriptor.Edit(lHooks.Instance, fHostContext, @ARequest,
      SizeOf(ARequest));
  except
    Result := REC_VISUAL_ERROR;
  end;
  if (Result = REC_VISUAL_OK) and SaveState(AComponent) then Exit;
  if Result = REC_VISUAL_OK then Result := REC_VISUAL_ERROR;
  AComponent.ConfigBlob := lBefore;
  AComponent.ConfigStatePresent := True;
  if not LoadState(AComponent) then
  begin
    RecorderDebugLog('[Plugin V2] Editor rollback failed for ' + TypeId);
    Result := REC_VISUAL_ERROR;
  end;
end;

function RecorderPluginVisualEdit(AComponent: TRecorderPluginVisualComponent;
  const ARequest: TRecorderVisualEditRequestV2): LongInt;
begin
  if not RecorderPluginVisualHasRuntime(AComponent) then
    Exit(REC_VISUAL_NOT_HANDLED);
  Result := TPluginVisualFactory(AComponent.Factory).EditState(AComponent,
    ARequest);
end;

function TRecorderPluginViewSession.Active: Boolean;
begin
  Result := Assigned(fDispatch) and (fInstance <> nil);
end;

function TRecorderPluginViewSession.Send(AKind: LongWord; AInput: Pointer;
  AInputSize: SizeUInt): LongInt;
var
  lOutputSize: SizeUInt;
begin
  if not Active then Exit(REC_VISUAL_NOT_HANDLED);
  lOutputSize := 0;
  try
    Result := fDispatch(fInstance, AKind, AInput, AInputSize, nil, 0,
      lOutputSize);
  except
    Result := REC_VISUAL_ERROR;
  end;
end;

function TRecorderPluginViewSession.SendSurface(AKind: LongWord;
  const ASurface: TRecorderVisualSurfaceV2): LongInt;
begin
  fSurface := ASurface;
  fSurface.ViewId := fViewId;
  Result := Send(AKind, @fSurface, SizeOf(fSurface));
end;

function TRecorderPluginViewSession.SetDisplayWindow(ASeconds: Double): LongInt;
var lContext: TRecorderVisualViewContextV2;
begin
  if not fAttached then Exit(REC_VISUAL_NOT_HANDLED);
  if IsNan(ASeconds) or IsInfinite(ASeconds) or (ASeconds <= 0) then
    Exit(REC_VISUAL_ERROR);
  lContext := Default(TRecorderVisualViewContextV2);
  lContext.Header.Size := SizeOf(lContext);
  lContext.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  lContext.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  lContext.ViewId := fViewId;
  lContext.DisplayWindowSeconds := ASeconds;
  Result := Send(REC_VISUAL_DISPATCH_VIEW_CONTEXT, @lContext, SizeOf(lContext));
end;

function TRecorderPluginViewSession.Attach(
  const ASurface: TRecorderVisualSurfaceV2): LongInt;
begin
  Result := Detach;
  if Result <> REC_VISUAL_OK then Exit;
  Result := SendSurface(REC_VISUAL_DISPATCH_ATTACH_VIEW, ASurface);
  fAttached := Result = REC_VISUAL_OK;
end;

function TRecorderPluginViewSession.Resize(
  const ASurface: TRecorderVisualSurfaceV2): LongInt;
begin
  if not fAttached then Exit(REC_VISUAL_NOT_HANDLED);
  Result := SendSurface(REC_VISUAL_DISPATCH_RESIZE_VIEW, ASurface);
end;

function TRecorderPluginViewSession.SetMode(
  const ASurface: TRecorderVisualSurfaceV2): LongInt;
begin
  if not fAttached then Exit(REC_VISUAL_NOT_HANDLED);
  Result := SendSurface(REC_VISUAL_DISPATCH_VIEW_MODE, ASurface);
end;

function TRecorderPluginViewSession.Detach: LongInt;
begin
  if not fAttached then Exit(REC_VISUAL_OK);
  Result := Send(REC_VISUAL_DISPATCH_DETACH_VIEW, @fSurface, SizeOf(fSurface));
  if Result <> REC_VISUAL_OK then Exit;
  fAttached := False;
  fSurface.ParentWindow := 0;
end;

procedure TRecorderPluginViewSession.Invalidate;
begin
  fAttached := False;
  fDispatch := nil;
  fInstance := nil;
  fOwner := nil;
end;

destructor TRecorderPluginViewSession.Destroy;
begin
  if (Detach <> REC_VISUAL_OK) and (fOwner <> nil) then
  begin
    TPluginVisualHooks(fOwner).LibraryOwner.UnloadSafe := False;
    RecorderDebugLog('[Plugin V2] Pinning library after failed view destruction');
  end;
  if fOwner <> nil then TPluginVisualHooks(fOwner).Views.Remove(Self);
  inherited Destroy;
end;

function TPluginVisualFactory.OpenView(
  AComponent: TRecorderPluginVisualComponent): TRecorderPluginViewSession;
var
  lHooks: TPluginVisualHooks;
begin
  Result := nil;
  lHooks := FindHooks(AComponent);
  if (lHooks = nil) or not Assigned(fDescriptor.ViewDispatch) then Exit;
  Result := TRecorderPluginViewSession.Create;
  Result.fOwner := lHooks;
  Result.fInstance := lHooks.Instance;
  Result.fDispatch := fDescriptor.ViewDispatch;
  Inc(fNextViewId);
  Result.fViewId := fNextViewId;
  lHooks.Views.Add(Result);
end;

function RecorderPluginVisualOpenView(AComponent: TRecorderPluginVisualComponent):
  TRecorderPluginViewSession;
begin
  if not RecorderPluginVisualHasRuntime(AComponent) then Exit(nil);
  Result := TPluginVisualFactory(AComponent.Factory).OpenView(AComponent);
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
  lTag := lRegistry.FindByName(StrPas(AName));
  if (lTag = nil) or (lTag.SignalBuffer.Count = 0) then Exit;
  ATimeSec := lTag.SignalBuffer.LatestTime;
  AValue := lTag.SignalBuffer.LatestValue;
  Result := True;
end;

procedure PluginLogMessage(AHostContext: Pointer; AMessage: PAnsiChar); cdecl;
  forward;

function PluginPublishTagValue(AHostContext: Pointer; AName: PAnsiChar;
  AValue: Double): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lMessage: UTF8String;
begin
  Result := False;
  if (AHostContext = nil) or (AName = nil) then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  if lRegistry = nil then Exit;
  lTag := lRegistry.FindByName(StrPas(AName));
  if lTag = nil then
  begin
    lMessage := UTF8Encode('setValue: тег "' + StrPas(AName) + '" не найден');
    PluginLogMessage(AHostContext, PAnsiChar(lMessage));
    Exit;
  end;
  if not lTag.ExternalWriteAllowed then
  begin
    lMessage := UTF8Encode('setValue: запись в тег "' + lTag.Name +
      '" запрещена настройками тега');
    PluginLogMessage(AHostContext, PAnsiChar(lMessage));
    Exit;
  end;
  lRegistry.PublishExternalValue(lTag, AValue);
  Result := True;
end;

function PluginTagExists(AHostContext: Pointer; AName: PAnsiChar): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
begin
  Result := False;
  if (AHostContext = nil) or (AName = nil) then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  Result := (lRegistry <> nil) and
    (lRegistry.FindByName(StrPas(AName)) <> nil);
end;

function PluginGetTagAlarmLevel(AHostContext: Pointer; AName: PAnsiChar;
  out ALevel: LongInt): LongBool; cdecl;
var
  lRuntime: TRecorderPluginRuntime;
  lTag: TRecorderTag;
begin
  Result := False;
  ALevel := 0;
  if (AHostContext = nil) or (AName = nil) then Exit;
  lRuntime := TRecorderPluginRuntime(AHostContext);
  if (lRuntime.fTagRegistry = nil) or (lRuntime.fAlarmEngine = nil) then Exit;
  lTag := lRuntime.fTagRegistry.FindByName(StrPas(AName));
  if lTag = nil then Exit;
  ALevel := Ord(lRuntime.fAlarmEngine.GetTagAlarmLevel(lTag));
  Result := True;
end;

function PluginGetTagSetpoint(AHostContext: Pointer; AName: PAnsiChar;
  AKind: LongInt; out AThreshold: Double; out AEnabled: LongBool): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lSetpoint: TRecorderTagSetpoint;
begin
  Result := False;
  AThreshold := 0;
  AEnabled := False;
  if (AHostContext = nil) or (AName = nil) or
    (AKind < Ord(Low(TRecorderTagSetpointKind))) or
    (AKind > Ord(High(TRecorderTagSetpointKind))) then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  if lRegistry = nil then Exit;
  lTag := lRegistry.FindByName(StrPas(AName));
  if lTag = nil then Exit;
  lSetpoint := lTag.Setpoints[TRecorderTagSetpointKind(AKind)];
  AThreshold := lSetpoint.Threshold;
  AEnabled := lSetpoint.Enabled;
  Result := True;
end;

function PluginSetTagSetpoint(AHostContext: Pointer; AName: PAnsiChar;
  AKind: LongInt; AThreshold: Double; AEnabled: LongBool): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lSetpoint: TRecorderTagSetpoint;
begin
  Result := False;
  if (AHostContext = nil) or (AName = nil) or
    (AKind < Ord(Low(TRecorderTagSetpointKind))) or
    (AKind > Ord(High(TRecorderTagSetpointKind))) then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  if lRegistry = nil then Exit;
  lTag := lRegistry.FindByName(StrPas(AName));
  if lTag = nil then Exit;
  lSetpoint := lTag.Setpoints[TRecorderTagSetpointKind(AKind)];
  lSetpoint.Threshold := AThreshold;
  lSetpoint.Enabled := AEnabled;
  lTag.Setpoints[TRecorderTagSetpointKind(AKind)] := lSetpoint;
  Result := True;
end;

function PluginGetRecorderTime(AHostContext: Pointer;
  out ATimeSec: Double): LongBool; cdecl;
var
  lRegistry: TRecorderTagRegistry;
  lRevision: QWord;
begin
  Result := False;
  ATimeSec := 0;
  if AHostContext = nil then Exit;
  lRegistry := TRecorderPluginRuntime(AHostContext).fTagRegistry;
  if lRegistry = nil then Exit;
  lRegistry.GetRuntimeDataState(lRevision, ATimeSec);
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
  lMessage := StrPas(AMessage);
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

function ReadPluginText(AData: PAnsiChar; ACapacity: SizeUInt;
  out AText: string): Boolean;
var
  I: SizeUInt;
begin
  AText := '';
  Result := False;
  if (AData = nil) or (ACapacity = 0) then
    Exit;
  for I := 0 to ACapacity - 1 do
    if AData[I] = #0 then
    begin
      SetString(AText, AData, I);
      Exit(True);
    end;
end;

function LoadVisualV2Plugin(ARuntime: TRecorderPluginRuntime;
  APlugin: TLoadedPlugin;
  AGetDescriptor: TRecorderVisualGetDescriptorV2): Boolean;
var
  lDescriptors: array of TRecorderVisualComponentDescriptorV2;
  lTypeIds, lClaims: TStringList;
  lAliases: array of TStringList;
  lDescriptor: TRecorderVisualComponentDescriptorV2;
  lTypeId, lCaption, lGroup, lAlias: string;
  lAliasBuffer: array[0..REC_VISUAL_TYPE_ID_CAPACITY-1] of AnsiChar;
  lIndex: LongWord;
  I, J: Integer;
  lStatus: LongInt;
  lFactory: TPluginVisualFactory;
begin
  Result := False;
  if (ARuntime = nil) or (APlugin = nil) or not Assigned(AGetDescriptor) then
    Exit;
  lTypeIds := TStringList.Create;
  lClaims := TStringList.Create;
  try
    lTypeIds.CaseSensitive := False;
    lClaims.CaseSensitive := False;
    lIndex := 0;
    while lIndex < REC_VISUAL_MAX_DESCRIPTORS do
    begin
      FillChar(lDescriptor, SizeOf(lDescriptor), 0);
      lStatus := AGetDescriptor(lIndex, @lDescriptor, SizeOf(lDescriptor));
      if lStatus = REC_VISUAL_END_OF_ENUMERATION then
        Break;
      if lStatus <> REC_VISUAL_OK then
        Exit;
      if (lDescriptor.Header.AbiMajor <> REC_VISUAL_ABI_V2_MAJOR) or
        (lDescriptor.Header.Size > SizeOf(lDescriptor)) or
        not RecorderVisualFieldPresentV2(lDescriptor.Header.Size,
          0, SizeOf(TRecorderVisualAbiHeaderV2)) or
        not RecorderVisualFieldPresentV2(lDescriptor.Header.Size,
          PtrUInt(@lDescriptor.LoadState) - PtrUInt(@lDescriptor),
          SizeOf(lDescriptor.LoadState)) or
        not Assigned(lDescriptor.CreateInstance) or
        not Assigned(lDescriptor.DestroyInstance) or
        not Assigned(lDescriptor.SaveState) or
        not Assigned(lDescriptor.LoadState) then
        Exit;
      if not ReadPluginText(@lDescriptor.TypeId[0],
        SizeOf(lDescriptor.TypeId), lTypeId) or (lTypeId = '') or
        not ReadPluginText(@lDescriptor.DisplayName[0],
        SizeOf(lDescriptor.DisplayName), lCaption) or (lCaption = '') or
        not ReadPluginText(@lDescriptor.Category[0],
        SizeOf(lDescriptor.Category), lGroup) then
        Exit;
      if ARuntime.fRegistry.IsComponentRegistered(lTypeId) or
        (lClaims.IndexOf(lTypeId) >= 0) then
        Exit;
      lTypeIds.Add(lTypeId);
      lClaims.Add(lTypeId);
      SetLength(lDescriptors, Length(lDescriptors) + 1);
      lDescriptors[High(lDescriptors)] := lDescriptor;
      SetLength(lAliases,Length(lDescriptors));
      lAliases[High(lAliases)] := TStringList.Create;
      if RecorderVisualFieldPresentV2(lDescriptor.Header.Size,
        PtrUInt(@lDescriptor.EnumerateAliases)-PtrUInt(@lDescriptor),
        SizeOf(lDescriptor.EnumerateAliases)) and Assigned(lDescriptor.EnumerateAliases) then
      begin
        J := 0;
        while J < REC_VISUAL_MAX_DESCRIPTORS do
        begin
          FillChar(lAliasBuffer,SizeOf(lAliasBuffer),0);
          lStatus := lDescriptor.EnumerateAliases(J,@lAliasBuffer[0],SizeOf(lAliasBuffer));
          if lStatus = REC_VISUAL_END_OF_ENUMERATION then Break;
          if (lStatus <> REC_VISUAL_OK) or
            not ReadPluginText(@lAliasBuffer[0],SizeOf(lAliasBuffer),lAlias) then Exit;
          lAlias := Trim(lAlias);
          if (lAlias = '') or ARuntime.fRegistry.IsComponentRegistered(lAlias) or
            (lClaims.IndexOf(lAlias)>=0) then Exit;
          lClaims.Add(lAlias);
          lAliases[High(lAliases)].Add(lAlias);
          Inc(J);
        end;
        if J = REC_VISUAL_MAX_DESCRIPTORS then Exit;
      end;
      Inc(lIndex);
    end;
    if (lIndex = REC_VISUAL_MAX_DESCRIPTORS) or
      (Length(lDescriptors) = 0) then
      Exit;

    for I := 0 to High(lDescriptors) do
    begin
      lTypeId := lTypeIds[I];
      ReadPluginText(@lDescriptors[I].DisplayName[0],
        SizeOf(lDescriptors[I].DisplayName), lCaption);
      ReadPluginText(@lDescriptors[I].Category[0],
        SizeOf(lDescriptors[I].Category), lGroup);
      lFactory := TPluginVisualFactory.Create(lTypeId, lCaption, lGroup,
        lDescriptors[I], @ARuntime.fVisualServices, APlugin);
      try
        ARuntime.fRegistry.RegisterFactory(lFactory);
      except
        lFactory.Free;
        raise;
      end;
      try
        APlugin.FactoryTypeIds.Add(lTypeId);
      except
        ARuntime.fRegistry.UnregisterFactory(lTypeId);
        raise;
      end;
      for J := 0 to lAliases[I].Count - 1 do
        ARuntime.fRegistry.RegisterAlias(lAliases[I][J],lTypeId);
    end;
    APlugin.IsVisualV2 := True;
    if (APlugin.Version = '') or
      (APlugin.Version = 'GetPluginInfo отсутствует') then
      APlugin.Version := Format('Visual ABI %d.%d',
        [REC_VISUAL_ABI_V2_MAJOR, REC_VISUAL_ABI_V2_MINOR]);
    ARuntime.fPlugins.Add(APlugin);
    Result := True;
  finally
    if not Result then
      while APlugin.FactoryTypeIds.Count > 0 do
      begin
        ARuntime.fRegistry.UnregisterFactory(
          APlugin.FactoryTypeIds[APlugin.FactoryTypeIds.Count - 1]);
        APlugin.FactoryTypeIds.Delete(APlugin.FactoryTypeIds.Count - 1);
      end;
    lTypeIds.Free;
    lClaims.Free;
    for I := 0 to High(lAliases) do lAliases[I].Free;
  end;
end;

constructor TRecorderPluginRuntime.Create(ARegistry: TRecorderComponentFactory;
  ATagRegistry: TRecorderTagRegistry; AAlarmEngine: IRecorderAlarmEngine);
begin
  inherited Create;
  fRegistry := ARegistry;
  fTagRegistry := ATagRegistry;
  fAlarmEngine := AAlarmEngine;
  fVisualServices.Header.Size := SizeOf(fVisualServices);
  fVisualServices.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  fVisualServices.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  fVisualServices.Context := Self;
  fVisualServices.EnumerateTags := @EnumerateVisualTagsV2;
  fVisualServices.CopyLatestHistory := @CopyLatestVisualTagHistoryV2;
  fVisualServices.CopyRangeHistory := @CopyRangeVisualHistoryV2;
  fVisualServices.GetSignalInfo := @GetVisualSignalInfoV2;
  fVisualServices.GetSelectedTagId := @GetVisualSelectedTagIdV2;
  fVisualServices.ReadEstimate := @ReadVisualEstimateV2;
  fVisualServices.GetTagEstimateSettings := @GetVisualEstimateSettingsV2;
  fVisualServices.EnumerateUnits := @EnumerateVisualUnitsV2;
  fVisualServices.ConversionFactor := @VisualConversionFactorV2;
  fPlugins := TList.Create;
  fPendingFactories := TList.Create;
end;

destructor TRecorderPluginRuntime.Destroy;
var
  I, J: Integer;
  lPlugin: TLoadedPlugin;
begin
  for I := fPendingFactories.Count - 1 downto 0 do
    TObject(fPendingFactories[I]).Free;
  fPendingFactories.Free;
  for I := fPlugins.Count - 1 downto 0 do
  begin
    lPlugin := TLoadedPlugin(fPlugins[I]);
    for J := lPlugin.FactoryTypeIds.Count - 1 downto 0 do
      fRegistry.UnregisterFactory(lPlugin.FactoryTypeIds[J]);
    lPlugin.FactoryTypeIds.Clear;
    lPlugin.Free;
  end;
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
  lGetVisualDescriptor: TRecorderVisualGetDescriptorV2;
  lFactory: TRecorderComponentFactoryBase;
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
        Pointer(lGetVisualDescriptor) := GetProcedureAddress(lPlugin.Handle,
          'RecorderVisualGetDescriptorV2');
        if Assigned(lGetVisualDescriptor) then
        begin
          if LoadVisualV2Plugin(Self, lPlugin, lGetVisualDescriptor) then
          begin
            RecorderDebugLog('[Plugin V2] loaded version=' + lPlugin.Version +
              '; path=' + lPlugin.FileName);
            lPlugin := nil;
          end;
          Continue;
        end;
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
        { Reserved legacy ABI slot: plugin components use generic V2 discovery,
          never a concrete host model. }
        lApi.RegisterOscillogramFactory := nil;
        lApi.TagCount := @PluginTagCount;
        lApi.GetTagInfo := @PluginGetTagInfo;
        lApi.ReadTagValue := @PluginReadTagValue;
        lApi.PublishTagValue := @PluginPublishTagValue;
        lApi.GetProjectDirectory := @PluginGetProjectDirectory;
        lApi.LogMessage := @PluginLogMessage;
        lApi.TagExists := @PluginTagExists;
        lApi.GetTagAlarmLevel := @PluginGetTagAlarmLevel;
        lApi.GetTagSetpoint := @PluginGetTagSetpoint;
        lApi.SetTagSetpoint := @PluginSetTagSetpoint;
        lApi.GetRecorderTime := @PluginGetRecorderTime;
        if not lCreate(lPlugin.Instance, @lApi) then
        begin
          RecorderDebugLog('[Plugin] PluginCreate rejected: ' +
            lCatalog.Entries[I].FileName);
          Continue;
        end;
        while fPendingFactories.Count > 0 do
        begin
          lFactory := TRecorderComponentFactoryBase(fPendingFactories[0]);
          fRegistry.RegisterFactory(lFactory);
          fPendingFactories.Delete(0);
          try
            lPlugin.FactoryTypeIds.Add(lFactory.TypeId);
          except
            fRegistry.UnregisterFactory(lFactory.TypeId);
            raise;
          end;
        end;
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
        if lPlugin <> nil then
          while lPlugin.FactoryTypeIds.Count > 0 do
          begin
            fRegistry.UnregisterFactory(
              lPlugin.FactoryTypeIds[lPlugin.FactoryTypeIds.Count - 1]);
            lPlugin.FactoryTypeIds.Delete(lPlugin.FactoryTypeIds.Count - 1);
          end;
        lPlugin.Free;
      end;
    end;
  finally
    lCatalog.Free;
  end;
end;

procedure TRecorderPluginRuntime.NotifyCatalogChanged;
var
  I, J: Integer;
  lPlugin: TLoadedPlugin;
  lFactory: TRecorderComponentFactoryBase;
begin
  for I := 0 to fPlugins.Count - 1 do
  begin
    lPlugin := TLoadedPlugin(fPlugins[I]);
    if not lPlugin.IsVisualV2 then Continue;
    for J := 0 to lPlugin.FactoryTypeIds.Count - 1 do
    begin
      lFactory := fRegistry.FindFactory(lPlugin.FactoryTypeIds[J]);
      if lFactory is TPluginVisualFactory then
        TPluginVisualFactory(lFactory).CatalogChanged;
    end;
  end;
end;

procedure TRecorderPluginRuntime.NotifyAll(AEvent: LongInt);
var
  I: Integer;
  lPlugin: TLoadedPlugin;
begin
  if AEvent in [PN_RCLOADCONFIG, PN_LEAVERCCONFIG, PN_RCINITIALIZED] then
    NotifyCatalogChanged;
  if (AEvent = PN_UPDATEDATA) and (fTagRegistry <> nil) then
    fTagRegistry.BeginExternalWriteBatch;
  try
    for I := 0 to fPlugins.Count - 1 do
    begin
      lPlugin := TLoadedPlugin(fPlugins[I]);
      if lPlugin.IsVisualV2 then
        Continue;
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
  finally
    if (AEvent = PN_UPDATEDATA) and (fTagRegistry <> nil) then
      fTagRegistry.EndExternalWriteBatch;
  end;
end;

end.
