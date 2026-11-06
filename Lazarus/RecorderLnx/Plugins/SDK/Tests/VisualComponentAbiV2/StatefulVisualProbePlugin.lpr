library StatefulVisualProbePlugin;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

uses
  Interfaces, Forms, Classes, SysUtils, Math, SyncObjs, uRecorderVisualComponentApiV2,
  uProbeNativeView
  {$IFDEF PLUGIN_NEW_LIFECYCLE}, uRecorderPluginApi,
  uRecorderPluginClass, uRecorderPluginComponentManager{$ENDIF};

type
  TProbeState = record
    Magic: QWord;
    Value: Int64;
    ObservedTagId: QWord;
    ObservedHistoryCount: LongWord;
    Reserved: LongWord;
    ObservedLatestValue: Double;
    ObservedRevision: QWord;
    ObservedTagInfo: TRecorderVisualTagInfoV2;
    ConfiguredContext: TRecorderVisualCreateContextV2;
    StartCount, UpdateCount, StopCount: LongWord;
    ServiceChecks: LongWord;
    AttachCount, DetachCount, ResizeCount, ModeCount: LongWord;
    LiveViews, SurfaceReserved: LongWord;
    LastSurface: TRecorderVisualSurfaceV2;
    FailNextDetach, FailNextResize, FailNextMode, ErrorReserved: LongWord;
    MouseInputCount, KeyInputCount: LongWord;
  end;
  PProbeState = ^TProbeState;

const
  CProbeMagic = QWord($56495355414C5632);
  CProbeTypeId = 'test.stateful-visual';
  CEmptyTypeId = 'test.empty-state-visual';

var gFailedInstances:TList; gVoidDestroyCount:LongWord;
  gBorrowedVisualServices:PRecorderVisualHostServicesV2;
{$IFDEF PLUGIN_NEW_LIFECYCLE}
type
  TProbeFactory = class(cRecBasicFactory)
    function GetDescriptor(ADescriptor:PRecorderVisualComponentDescriptorV2;
      ACapacity:SizeUInt):LongInt; override;
    function Notify(AKind:LongWord; AData:Pointer):LongInt; override;
    function doRecorderInit:LongInt; override;
    function doClose:LongInt; override;
  end;
  TProbeWorker = class(TThread)
    Wake: TEvent;
    procedure Execute; override;
    constructor Create;
    destructor Destroy; override;
  end;
var gInstances:TList; gPlugin:TExtRecorderPack; gFactory:TProbeFactory;
  gBorrowedHostApi:PRecorderPluginHostApi;
  gProbeWorker:TProbeWorker; gCloseCount,gPluginDestroyCount,gWorkerStopCount:LongWord;
{$ENDIF}

function CreateInstance(AHostContext: Pointer; AConfigData: Pointer;
  AConfigSize: SizeUInt; out AInstance: Pointer): LongInt; cdecl;
var
  lState: PProbeState;
  lServices:PRecorderVisualHostServicesV2;
  lTagInfo:TRecorderVisualTagInfoV2;
  lCount,lCapacity,lEnumerated:LongWord;
  lRevision:QWord;
  lWindowStart,lLatestTime:Double;
  lTimes,lValues:PDouble;
  lStatus:LongInt;
  lEmptyTagId: QWord;
  lCanaryTimes, lCanaryValues: array[0..1] of Double;
  lSignalInfo: TRecorderVisualSignalInfoV2;
  lEstimate: TRecorderVisualEstimateV2;
  lSettings: TRecorderVisualEstimateSettingsV2;
  lUnit: TRecorderVisualUnitInfoV2;
  lSelectedId: QWord;
  lFactor: Double;
begin
  AInstance := nil;
  if (AConfigData <> nil) or (AConfigSize <> 0) then
    Exit(REC_VISUAL_ERROR);
  GetMem(lState, SizeOf(TProbeState));
  FillChar(lState^,SizeOf(TProbeState),0);
  lState^.Magic := CProbeMagic;
  lState^.Value := 17;
  if AHostContext<>nil then
  begin
    lServices:=PRecorderVisualHostServicesV2(AHostContext);
    gBorrowedVisualServices:=lServices;
    if (lServices^.Header.Size<SizeOf(TRecorderVisualHostServicesV2)) or
      (lServices^.Header.AbiMajor<>REC_VISUAL_ABI_V2_MAJOR) or
      (lServices^.Header.AbiMinor<1) or (lServices^.Context=nil) or
      not Assigned(lServices^.EnumerateTags) or
      not Assigned(lServices^.CopyLatestHistory) then
    begin
      FreeMem(lState);
      Exit(REC_VISUAL_ERROR);
    end;
    FillChar(lTagInfo,SizeOf(lTagInfo),0);
    lTagInfo.Header.Size:=SizeOf(lTagInfo);
    lTagInfo.Header.AbiMajor:=REC_VISUAL_ABI_V2_MAJOR;
    lStatus:=lServices^.EnumerateTags(lServices^.Context,0,@lTagInfo);
    if (lStatus<>REC_VISUAL_OK) or (lTagInfo.TagId=0) then
    begin
      FreeMem(lState);
      Exit(REC_VISUAL_ERROR);
    end;
    lState^.ObservedTagId:=lTagInfo.TagId;
    lState^.ObservedTagInfo:=lTagInfo;
    lEmptyTagId := 0;
    lEnumerated:=1;
    while lEnumerated<16 do
    begin
      lTagInfo.Header.Size:=SizeOf(lTagInfo);
      lTagInfo.Header.AbiMajor:=REC_VISUAL_ABI_V2_MAJOR;
      lStatus:=lServices^.EnumerateTags(lServices^.Context,lEnumerated,
        @lTagInfo);
      if lStatus=REC_VISUAL_END_OF_ENUMERATION then Break;
      if lStatus<>REC_VISUAL_OK then
      begin
        FreeMem(lState);
        Exit(REC_VISUAL_ERROR);
      end;
      lEmptyTagId := lTagInfo.TagId;
      Inc(lEnumerated);
    end;
    if lEnumerated>=16 then
    begin
      FreeMem(lState);
      Exit(REC_VISUAL_ERROR);
    end;
    lState^.Reserved := lEnumerated;
    if lServices^.EnumerateTags(lServices^.Context,0,nil) <> REC_VISUAL_ERROR then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if lServices^.CopyLatestHistory(lServices^.Context,High(QWord),1.5,
      nil,nil,0,lCount,lRevision,lWindowStart,lLatestTime) <> REC_VISUAL_NOT_FOUND then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if lServices^.CopyLatestHistory(lServices^.Context,lState^.ObservedTagId,-1,
      nil,nil,0,lCount,lRevision,lWindowStart,lLatestTime) <> REC_VISUAL_ERROR then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if lServices^.CopyLatestHistory(lServices^.Context,lState^.ObservedTagId,NaN,
      nil,nil,0,lCount,lRevision,lWindowStart,lLatestTime) <> REC_VISUAL_ERROR then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if lServices^.CopyLatestHistory(lServices^.Context,lState^.ObservedTagId,Infinity,
      nil,nil,0,lCount,lRevision,lWindowStart,lLatestTime) <> REC_VISUAL_ERROR then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if (lEmptyTagId = 0) or
      (lServices^.CopyLatestHistory(lServices^.Context,lEmptyTagId,1.5,
      nil,nil,0,lCount,lRevision,lWindowStart,lLatestTime) <> REC_VISUAL_OK) or
      (lCount <> 0) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    lCanaryTimes[0] := 12345; lCanaryValues[0] := 54321;
    if (lServices^.CopyLatestHistory(lServices^.Context,lState^.ObservedTagId,1.5,
      @lCanaryTimes[0],@lCanaryValues[0],1,lCount,lRevision,lWindowStart,
      lLatestTime) <> REC_VISUAL_BUFFER_TOO_SMALL) or (lCount <> 2) or
      (lCanaryTimes[0] <> 12345) or (lCanaryValues[0] <> 54321) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if lServices^.CopyLatestHistory(lServices^.Context,lState^.ObservedTagId,1.5,
      nil,@lCanaryValues[0],2,lCount,lRevision,lWindowStart,lLatestTime) <> REC_VISUAL_ERROR then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if lServices^.CopyLatestHistory(lServices^.Context,lState^.ObservedTagId,1.5,
      @lCanaryTimes[0],nil,2,lCount,lRevision,lWindowStart,lLatestTime) <> REC_VISUAL_ERROR then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    lCount:=0; lRevision:=0; lWindowStart:=0; lLatestTime:=0;
    lStatus:=lServices^.CopyLatestHistory(lServices^.Context,
      lState^.ObservedTagId,1.5,nil,nil,0,lCount,lRevision,
      lWindowStart,lLatestTime);
    if lStatus<>REC_VISUAL_BUFFER_TOO_SMALL then
    begin
      FreeMem(lState);
      Exit(REC_VISUAL_ERROR);
    end;
    if lCount<>2 then
    begin
      FreeMem(lState);
      Exit(REC_VISUAL_ERROR);
    end;
    lTimes := @lCanaryTimes[0];
    lValues := @lCanaryValues[0];
      lCapacity:=lCount;
      lStatus:=lServices^.CopyLatestHistory(lServices^.Context,
        lState^.ObservedTagId,1.5,lTimes,lValues,lCapacity,lCount,lRevision,
        lWindowStart,lLatestTime);
      if (lStatus<>REC_VISUAL_OK) or (lCount <> 2) or
        (lTimes[1] - lTimes[0] <> 1) or
        (lValues[0] <> 10 * lTimes[0]) or (lValues[1] <> 10 * lTimes[1]) or
        (lWindowStart <> lTimes[0]) or (lLatestTime <> lTimes[1]) then
      begin
        FreeMem(lState);
        Exit(REC_VISUAL_ERROR);
      end;
      lState^.ObservedHistoryCount:=lCount;
      lState^.ObservedLatestValue:=lValues[lCount-1];
      lState^.ObservedRevision:=lRevision;
    if not Assigned(lServices^.CopyRangeHistory) or
      not Assigned(lServices^.GetSignalInfo) or
      not Assigned(lServices^.GetSelectedTagId) or
      not Assigned(lServices^.ReadEstimate) or
      not Assigned(lServices^.GetTagEstimateSettings) or
      not Assigned(lServices^.EnumerateUnits) or
      not Assigned(lServices^.ConversionFactor) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    if (lServices^.CopyRangeHistory(lServices^.Context,lState^.ObservedTagId,
      2.5,3.5,1,nil,nil,0,lCount,lRevision,lWindowStart,lLatestTime)
      <> REC_VISUAL_BUFFER_TOO_SMALL) or (lCount <> 2) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if (lServices^.CopyRangeHistory(lServices^.Context,lState^.ObservedTagId,
      2.5,3.5,1,lTimes,lValues,2,lCount,lRevision,lWindowStart,lLatestTime)
      <> REC_VISUAL_OK) or (lCount <> 2) or (lTimes[0] <> 2) or
      (lTimes[1] <> 3) or (lValues[0] <> 20) or (lValues[1] <> 30) or
      (lRevision <> lState^.ObservedRevision) or (lWindowStart <> 2) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    lSignalInfo := Default(TRecorderVisualSignalInfoV2);
    lSignalInfo.Header.Size := SizeOf(lSignalInfo);
    lSignalInfo.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    if (lServices^.GetSignalInfo(lServices^.Context,lState^.ObservedTagId,
      @lSignalInfo) <> REC_VISUAL_OK) or
      (lSignalInfo.Revision <> lState^.ObservedRevision) or
      (lSignalInfo.Count < 4) or (lSignalInfo.LatestTimeSec <> lLatestTime) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if (lServices^.GetSelectedTagId(lServices^.Context,lSelectedId) <>
      REC_VISUAL_OK) or (lSelectedId <> lState^.ObservedTagId) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    lSettings := Default(TRecorderVisualEstimateSettingsV2);
    lSettings.Header.Size := SizeOf(lSettings);
    lSettings.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    if (lServices^.GetTagEstimateSettings(lServices^.Context,lSelectedId,
      @lSettings) <> REC_VISUAL_OK) or (lSettings.EnabledKinds <> 3) or
      (lSettings.DefaultKind <> REC_VISUAL_ESTIMATE_MEAN) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    lEstimate := Default(TRecorderVisualEstimateV2);
    lEstimate.Header.Size := SizeOf(lEstimate);
    lEstimate.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    if (lServices^.ReadEstimate(lServices^.Context,lSelectedId,
      REC_VISUAL_ESTIMATE_MEAN,@lEstimate) <> REC_VISUAL_OK) or
      (lEstimate.Valid = 0) or (lEstimate.Count <> 4) or
      (lEstimate.Value <> 25) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    lUnit := Default(TRecorderVisualUnitInfoV2);
    lUnit.Header.Size := SizeOf(lUnit);
    lUnit.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    if (lServices^.EnumerateUnits(lServices^.Context,0,@lUnit) <>
      REC_VISUAL_OK) or (lUnit.Name[0] = #0) or (lUnit.ScaleToBase <= 0) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
    if (lServices^.ConversionFactor(lServices^.Context,'V','mV',lFactor) <>
      REC_VISUAL_OK) or (lFactor <> 1000) then
    begin FreeMem(lState); Exit(REC_VISUAL_ERROR); end;
    Inc(lState^.ServiceChecks);
  end;
  AInstance := lState;
  {$IFDEF PLUGIN_NEW_LIFECYCLE}
  gInstances.Add(AInstance);
  gFactory.RegisterInstance(AInstance);
  {$ENDIF}
  Result := REC_VISUAL_OK;
end;

procedure DestroyInstance(AInstance: Pointer); cdecl;
begin
  {$IFDEF PLUGIN_NEW_LIFECYCLE}
  if gInstances <> nil then gInstances.Remove(AInstance);
  if gFactory <> nil then gFactory.UnregisterInstance(AInstance);
  {$ENDIF}
  Inc(gVoidDestroyCount);
  CloseProbeNativeViews(AInstance);
  if AInstance <> nil then
    FreeMem(AInstance);
end;

function TryDestroyInstance(AInstance:Pointer):LongInt; cdecl;
begin
  if GetEnvironmentVariable('RECORDER_DESTROY_PROBE')='error' then
  begin
    if gFailedInstances=nil then gFailedInstances:=TList.Create;
    if gFailedInstances.IndexOf(AInstance)<0 then gFailedInstances.Add(AInstance);
    Exit(REC_VISUAL_ERROR);
  end;
  DestroyInstance(AInstance);
  Result:=REC_VISUAL_OK;
end;

function PoisonTryDestroy(AInstance:Pointer):LongInt; cdecl;
begin
  Result:=REC_VISUAL_ERROR;
end;

function ProbeFailedDestroyCount:LongWord; cdecl;
begin
  Result:=0;
  if gFailedInstances<>nil then Result:=gFailedInstances.Count;
end;

function ProbeVoidDestroyCount:LongWord; cdecl;
begin Result:=gVoidDestroyCount; end;

function ProbeCleanupFailedDestroy:LongInt; cdecl;
var I:Integer;
begin
  if gFailedInstances<>nil then
  begin
    for I:=0 to gFailedInstances.Count-1 do DestroyInstance(gFailedInstances[I]);
    FreeAndNil(gFailedInstances);
  end;
  Result:=REC_VISUAL_OK;
end;

{ Вызывается только тестовым дочерним процессом; проверяет таблицы, оставленные
  живому экземпляру после отказа TryDestroyInstance. 0 — до завершения хоста,
  1 — после завершения; callback должен отказать, не обращаясь к старому хосту. }
function ProbeBorrowedServices(AAfterShutdown:LongInt):LongInt; cdecl;
var lInfo:TRecorderVisualTagInfoV2; lStatus:LongInt;
  {$IFDEF PLUGIN_NEW_LIFECYCLE} lTag:TRecorderPluginTagInfo; lOk:LongBool; {$ENDIF}
begin
  Result:=-101;
  if (gBorrowedVisualServices=nil) or
    (gBorrowedVisualServices^.Header.Size<SizeOf(TRecorderVisualHostServicesV2)) or
    not Assigned(gBorrowedVisualServices^.EnumerateTags) then Exit;
  Result:=-102;
  lInfo:=Default(TRecorderVisualTagInfoV2);
  lInfo.Header.Size:=SizeOf(lInfo); lInfo.Header.AbiMajor:=REC_VISUAL_ABI_V2_MAJOR;
  lStatus:=gBorrowedVisualServices^.EnumerateTags(gBorrowedVisualServices^.Context,0,@lInfo);
  if AAfterShutdown=0 then begin
    if lStatus<>REC_VISUAL_OK then Exit;
  end else if (lStatus<>REC_VISUAL_ERROR) and
    (lStatus<>REC_VISUAL_NOT_FOUND) then begin
    Result:=-200-lStatus; Exit;
  end;
  {$IFDEF PLUGIN_NEW_LIFECYCLE}
  Result:=-103;
  if (gBorrowedHostApi=nil) or (gBorrowedHostApi^.Size<SizeOf(TRecorderPluginHostApi)) or
    not Assigned(gBorrowedHostApi^.GetTagInfo) then Exit;
  Result:=-104;
  lTag:=Default(TRecorderPluginTagInfo); lTag.Size:=SizeOf(lTag);
  lOk:=gBorrowedHostApi^.GetTagInfo(gBorrowedHostApi^.HostContext,0,@lTag);
  if (AAfterShutdown=0) and not lOk then Exit;
  if (AAfterShutdown<>0) and lOk then Exit;
  {$ENDIF}
  Result:=REC_VISUAL_OK;
end;

function SaveState(AInstance: Pointer; ABuffer: Pointer;
  ACapacity: SizeUInt; out ARequiredSize: SizeUInt): LongInt; cdecl;
begin
  ARequiredSize := SizeOf(TProbeState);
  if (AInstance = nil) or (PProbeState(AInstance)^.Magic <> CProbeMagic) then
    Exit(REC_VISUAL_ERROR);
  if (ABuffer = nil) or (ACapacity < ARequiredSize) then
    Exit(REC_VISUAL_BUFFER_TOO_SMALL);
  Move(PProbeState(AInstance)^, ABuffer^, SizeOf(TProbeState));
  Result := REC_VISUAL_OK;
end;

function LoadState(AInstance: Pointer; AStateData: Pointer;
  AStateSize: SizeUInt): LongInt; cdecl;
var
  lCandidate: TProbeState;
begin
  if (AInstance = nil) or (AStateData = nil) or
    (AStateSize <> SizeOf(TProbeState)) then
    Exit(REC_VISUAL_ERROR);
  Move(AStateData^, lCandidate, SizeOf(lCandidate));
  if lCandidate.Magic <> CProbeMagic then
    Exit(REC_VISUAL_ERROR);
  PProbeState(AInstance)^ := lCandidate;
  Result := REC_VISUAL_OK;
end;

function Edit(AInstance: Pointer; AHostContext: Pointer; AEditRequest: Pointer;
  AEditRequestSize: SizeUInt): LongInt; cdecl;
begin
  if AInstance = Pointer(PtrUInt(1)) then Exit(REC_VISUAL_NOT_HANDLED);
  if (AInstance = nil) or (AEditRequest = nil) or
    (AEditRequestSize <> SizeOf(TRecorderVisualEditRequestV2)) then
    Exit(REC_VISUAL_ERROR);
  if PRecorderVisualEditRequestV2(AEditRequest)^.Header.AbiMajor <>
    REC_VISUAL_ABI_V2_MAJOR then Exit(REC_VISUAL_ERROR);
  { Deliberately mutate even on Cancel to prove the production host restores
    opaque state instead of trusting the probe's editor implementation. }
  Inc(PProbeState(AInstance)^.Value);
  if PProbeState(AInstance)^.Value = 736 then
    Result := REC_VISUAL_OK
  else
    Result := REC_VISUAL_CANCELLED;
end;

function ViewDispatch(AInstance: Pointer; ADispatchKind: LongWord;
  AInput: Pointer; AInputSize: SizeUInt; AOutput: Pointer;
  AOutputCapacity: SizeUInt; out AOutputSize: SizeUInt): LongInt; cdecl;
var
  lStatus: LongInt;
begin
  AOutputSize := 0;
  if (AInstance = nil) or (AInstance = Pointer(PtrUInt(1))) then
    Exit(REC_VISUAL_NOT_HANDLED);
  if PProbeState(AInstance)^.Magic <> CProbeMagic then Exit(REC_VISUAL_ERROR);
  case ADispatchKind of
    REC_VISUAL_DISPATCH_ATTACH_VIEW, REC_VISUAL_DISPATCH_DETACH_VIEW,
    REC_VISUAL_DISPATCH_RESIZE_VIEW, REC_VISUAL_DISPATCH_VIEW_MODE:
      begin
        if (AInput = nil) or (AInputSize <> SizeOf(TRecorderVisualSurfaceV2)) or
          (PRecorderVisualSurfaceV2(AInput)^.Header.Size <> AInputSize) or
          (PRecorderVisualSurfaceV2(AInput)^.ViewId = 0) then
          Exit(REC_VISUAL_ERROR);
        if (ADispatchKind = REC_VISUAL_DISPATCH_DETACH_VIEW) and
          (PProbeState(AInstance)^.FailNextDetach > 0) then
        begin
          Dec(PProbeState(AInstance)^.FailNextDetach);
          Exit(REC_VISUAL_ERROR);
        end;
        if (ADispatchKind = REC_VISUAL_DISPATCH_RESIZE_VIEW) and
          (PProbeState(AInstance)^.FailNextResize > 0) then
        begin
          Dec(PProbeState(AInstance)^.FailNextResize);
          Exit(REC_VISUAL_ERROR);
        end;
        if (ADispatchKind = REC_VISUAL_DISPATCH_VIEW_MODE) and
          (PProbeState(AInstance)^.FailNextMode > 0) then
        begin
          Dec(PProbeState(AInstance)^.FailNextMode);
          Exit(REC_VISUAL_ERROR);
        end;
        lStatus := ProbeNativeViewDispatch(AInstance, ADispatchKind,
          PRecorderVisualSurfaceV2(AInput)^,
          PProbeState(AInstance)^.MouseInputCount,
          PProbeState(AInstance)^.KeyInputCount);
        if lStatus <> REC_VISUAL_OK then Exit(lStatus);
        PProbeState(AInstance)^.LastSurface := PRecorderVisualSurfaceV2(AInput)^;
        case ADispatchKind of
          REC_VISUAL_DISPATCH_ATTACH_VIEW:
            begin
              Inc(PProbeState(AInstance)^.AttachCount);
              Inc(PProbeState(AInstance)^.LiveViews);
            end;
          REC_VISUAL_DISPATCH_DETACH_VIEW:
            begin
              if PProbeState(AInstance)^.LiveViews = 0 then Exit(REC_VISUAL_ERROR);
              Inc(PProbeState(AInstance)^.DetachCount);
              Dec(PProbeState(AInstance)^.LiveViews);
            end;
          REC_VISUAL_DISPATCH_RESIZE_VIEW: Inc(PProbeState(AInstance)^.ResizeCount);
          REC_VISUAL_DISPATCH_VIEW_MODE: Inc(PProbeState(AInstance)^.ModeCount);
        end;
      end;
    REC_VISUAL_DISPATCH_CONFIGURE:
      begin
        if (AInput = nil) or (AInputSize <> SizeOf(TRecorderVisualCreateContextV2)) then
          Exit(REC_VISUAL_ERROR);
        PProbeState(AInstance)^.ConfiguredContext :=
          PRecorderVisualCreateContextV2(AInput)^;
      end;
    REC_VISUAL_DISPATCH_CATALOG_CHANGED: Inc(PProbeState(AInstance)^.SurfaceReserved);
    REC_VISUAL_DISPATCH_START: Inc(PProbeState(AInstance)^.StartCount);
    REC_VISUAL_DISPATCH_STOP: Inc(PProbeState(AInstance)^.StopCount);
    REC_VISUAL_DISPATCH_DATA_UPDATED: Inc(PProbeState(AInstance)^.UpdateCount);
    else Exit(REC_VISUAL_NOT_HANDLED);
  end;
  Exit(REC_VISUAL_OK);
end;

function CreateEmptyInstance(AHostContext: Pointer; AConfigData: Pointer;
  AConfigSize: SizeUInt; out AInstance: Pointer): LongInt; cdecl;
begin
  AInstance := Pointer(PtrUInt(1));
  if (AConfigData <> nil) or (AConfigSize <> 0) then
    Exit(REC_VISUAL_ERROR);
  Result := REC_VISUAL_OK;
end;

procedure DestroyEmptyInstance(AInstance: Pointer); cdecl;
begin
end;

function TryDestroyEmptyInstance(AInstance:Pointer):LongInt; cdecl;
begin DestroyEmptyInstance(AInstance); Result:=REC_VISUAL_OK; end;

function SaveEmptyState(AInstance: Pointer; ABuffer: Pointer;
  ACapacity: SizeUInt; out ARequiredSize: SizeUInt): LongInt; cdecl;
begin
  ARequiredSize := 0;
  if AInstance <> Pointer(PtrUInt(1)) then
    Exit(REC_VISUAL_ERROR);
  Result := REC_VISUAL_OK;
end;

function LoadEmptyState(AInstance: Pointer; AStateData: Pointer;
  AStateSize: SizeUInt): LongInt; cdecl;
begin
  if (AInstance <> Pointer(PtrUInt(1))) or (AStateData <> nil) or
    (AStateSize <> 0) then
    Exit(REC_VISUAL_ERROR);
  Result := REC_VISUAL_OK;
end;

function EnumerateProbeAliases(AIndex:LongWord; ABuffer:PAnsiChar;
  ACapacity:SizeUInt):LongInt; cdecl;
var lMode,lAlias:string;
begin
  lMode:=GetEnvironmentVariable('RECORDER_ALIAS_PROBE');
  if lMode='' then Exit(REC_VISUAL_END_OF_ENUMERATION);
  if (ABuffer=nil) or (ACapacity<REC_VISUAL_TYPE_ID_CAPACITY) then Exit(REC_VISUAL_ERROR);
  if (lMode='error') and (AIndex=1) then Exit(REC_VISUAL_ERROR);
  if lMode='oldprefix' then Exit(REC_VISUAL_ERROR);
  if (AIndex>0) and (lMode<>'endless') and
    not ((lMode='duplicate') and (AIndex=1)) then Exit(REC_VISUAL_END_OF_ENUMERATION);
  lAlias:='test.alias';
  if lMode='host' then lAlias:='test.hostcollision';
  if lMode='future' then lAlias:=CEmptyTypeId;
  if lMode='self' then lAlias:=CProbeTypeId;
  if lMode='endless' then lAlias:='test.alias.'+IntToStr(AIndex);
  if lMode='empty' then lAlias:='';
  if lMode='nonul' then FillChar(ABuffer^,ACapacity,Ord('A'))
  else StrPLCopy(ABuffer,lAlias,ACapacity-1);
  Result:=REC_VISUAL_OK;
end;

function RecorderVisualGetDescriptorV2(AIndex: LongWord;
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ADescriptorCapacity: SizeUInt): LongInt; cdecl;
begin
  if AIndex > 1 then
    Exit(REC_VISUAL_END_OF_ENUMERATION);
  if (ADescriptor = nil) or
    (ADescriptorCapacity < SizeOf(TRecorderVisualComponentDescriptorV2)) then
    Exit(REC_VISUAL_ERROR);
  FillChar(ADescriptor^, SizeOf(TRecorderVisualComponentDescriptorV2), 0);
  ADescriptor^.Header.Size := SizeOf(TRecorderVisualComponentDescriptorV2);
  ADescriptor^.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  ADescriptor^.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  if AIndex = 0 then
  begin
    StrPLCopy(@ADescriptor^.TypeId[0], CProbeTypeId,
      High(ADescriptor^.TypeId));
    StrPLCopy(@ADescriptor^.DisplayName[0], 'Stateful visual ABI probe',
      High(ADescriptor^.DisplayName));
    ADescriptor^.CreateInstance := @CreateInstance;
    ADescriptor^.DestroyInstance := @DestroyInstance;
    ADescriptor^.SaveState := @SaveState;
    ADescriptor^.LoadState := @LoadState;
  end
  else
  begin
    { Advertise only the required callbacks. The populated optional slots
      below are poison outside Size: a host must never invoke them. }
    ADescriptor^.Header.Size := PtrUInt(@ADescriptor^.Edit)-PtrUInt(ADescriptor);
    ADescriptor^.Header.AbiMinor := 0;
    StrPLCopy(@ADescriptor^.TypeId[0], CEmptyTypeId,
      High(ADescriptor^.TypeId));
    StrPLCopy(@ADescriptor^.DisplayName[0], 'Empty state ABI probe',
      High(ADescriptor^.DisplayName));
    ADescriptor^.CreateInstance := @CreateEmptyInstance;
    ADescriptor^.DestroyInstance := @DestroyEmptyInstance;
    ADescriptor^.SaveState := @SaveEmptyState;
    ADescriptor^.LoadState := @LoadEmptyState;
  end;
  StrPLCopy(@ADescriptor^.Category[0], 'tests',
    High(ADescriptor^.Category));
  ADescriptor^.Edit := @Edit;
  ADescriptor^.ViewDispatch := @ViewDispatch;
  ADescriptor^.EnumerateAliases := @EnumerateProbeAliases;
  if AIndex=0 then ADescriptor^.TryDestroyInstance:=@TryDestroyInstance
  else ADescriptor^.TryDestroyInstance:=@PoisonTryDestroy;
  if (AIndex=1) and (GetEnvironmentVariable('RECORDER_ALIAS_PROBE')='crossalias') then
  begin
    ADescriptor^.Header.Size:=SizeOf(ADescriptor^);
    ADescriptor^.Edit:=nil; ADescriptor^.ViewDispatch:=nil;
  end;
  if (AIndex=0) and (GetEnvironmentVariable('RECORDER_ALIAS_PROBE')<>'') then
  begin
    { Discovery-only fixture modes leave the normal state/service probe intact. }
    ADescriptor^.CreateInstance:=@CreateEmptyInstance;
    ADescriptor^.DestroyInstance:=@DestroyEmptyInstance;
    ADescriptor^.SaveState:=@SaveEmptyState;
    ADescriptor^.LoadState:=@LoadEmptyState;
    ADescriptor^.TryDestroyInstance:=@TryDestroyEmptyInstance;
    ADescriptor^.Edit:=nil; ADescriptor^.ViewDispatch:=nil;
    if GetEnvironmentVariable('RECORDER_ALIAS_PROBE')='oldprefix' then
      ADescriptor^.Header.Size:=PtrUInt(@ADescriptor^.EnumerateAliases)-PtrUInt(ADescriptor);
  end;
  Result := REC_VISUAL_OK;
end;

{$IFDEF PLUGIN_NEW_LIFECYCLE}
constructor TProbeWorker.Create;
begin
  inherited Create(True); FreeOnTerminate:=False;
  Wake:=TEvent.Create(nil,True,False,''); Start;
end;

destructor TProbeWorker.Destroy;
begin Wake.Free; inherited Destroy; end;

procedure TProbeWorker.Execute;
begin Wake.WaitFor(INFINITE); end;

function TProbeFactory.doClose:LongInt;
begin
  Inc(gCloseCount);
  if (GetEnvironmentVariable('RECORDER_CLOSE_PROBE')<>'') and
    (gCloseCount=1) then Exit(REC_VISUAL_ERROR);
  if gProbeWorker<>nil then begin
    gProbeWorker.Wake.SetEvent; gProbeWorker.WaitFor;
    FreeAndNil(gProbeWorker); Inc(gWorkerStopCount);
  end;
  Result:=REC_VISUAL_OK;
end;

function TProbeFactory.GetDescriptor(ADescriptor:PRecorderVisualComponentDescriptorV2;
  ACapacity:SizeUInt):LongInt;
begin
  Result:=REC_VISUAL_NOT_HANDLED;
end;

function TProbeFactory.Notify(AKind:LongWord; AData:Pointer):LongInt;
var I:Integer; lCode:LongWord;
begin
  lCode:=0;
  case AKind of
    PN_RCSTART:begin
      if PtrUInt(AData)>1 then Exit(REC_VISUAL_ERROR);
      lCode:=1+PtrUInt(AData);
    end;
    PN_RCSTOP:begin
      if AData<>nil then Exit(REC_VISUAL_ERROR);
      lCode:=3;
    end;
  end;
  if lCode<>0 then
    for I:=0 to gInstances.Count-1 do
      PProbeState(gInstances[I])^.ErrorReserved:=
        (PProbeState(gInstances[I])^.ErrorReserved shl 4) or lCode;
  Result:=inherited Notify(AKind,AData);
end;

function TProbeFactory.doRecorderInit:LongInt;
var I:Integer;
begin
  Result:=REC_VISUAL_ERROR;
  for I:=0 to gInstances.Count-1 do begin
    if PProbeState(gInstances[I])^.SurfaceReserved=0 then Exit;
    PProbeState(gInstances[I])^.SurfaceReserved:=
      PProbeState(gInstances[I])^.SurfaceReserved or $80000000;
  end;
  Result:=REC_VISUAL_OK;
end;

procedure RegisterProbeFactories(AManager:cCompMng);
var lDescriptor:TRecorderVisualComponentDescriptorV2;
begin
  gFactory:=TProbeFactory.Create;
  try
    lDescriptor:=Default(TRecorderVisualComponentDescriptorV2);
    lDescriptor.ViewDispatch:=@ViewDispatch;
    gFactory.SetDescriptor(lDescriptor);
    AManager.Add(gFactory);
  except
    FreeAndNil(gFactory);
    raise;
  end;
end;

function CreatePluginClass:Pointer; cdecl;
begin
  Result:=nil;
  if gPlugin<>nil then Exit;
  gInstances:=TList.Create;
  try
    gPlugin:=TExtRecorderPack.Create(@RegisterProbeFactories);
    Result:=Pointer(gPlugin);
  except
    FreeAndNil(gInstances);
  end;
end;

function PluginCreate(AInstance:Pointer; AHostApi:PRecorderPluginHostApi):LongBool; cdecl;
begin
  Result:=(AInstance=Pointer(gPlugin)) and (AInstance<>nil);
  if Result then begin
    gBorrowedHostApi:=AHostApi;
    Result:=gPlugin.Initialize(AHostApi);
    if Result and (GetEnvironmentVariable('RECORDER_CLOSE_PROBE')<>'') then begin
      gProbeWorker:=TProbeWorker.Create;
      if GetEnvironmentVariable('RECORDER_CLOSE_PROBE')='initfail' then Result:=False;
    end;
  end;
end;

function PluginNotify(AInstance:Pointer; AEvent:LongInt; AData:Pointer):LongBool; cdecl;
begin
  Result:=False;
  if (AInstance=nil) or (AInstance<>Pointer(gPlugin)) then Exit;
  Result:=gPlugin.Notify(AEvent,AData)>=0;
end;

function PluginClose(AInstance:Pointer):LongBool; cdecl;
begin
  Result:=False;
  if (AInstance=nil) or (AInstance<>Pointer(gPlugin)) then Exit;
  try gPlugin.Close; Result:=True; except Result:=False; end;
end;

function DestroyPluginClass(AInstance:Pointer):LongInt; cdecl;
begin
  Result:=-1;
  if (AInstance=nil) or (AInstance<>Pointer(gPlugin)) or gPlugin.HasInstances then Exit;
  Inc(gPluginDestroyCount);
  FreeAndNil(gPlugin); gFactory:=nil;
  FreeAndNil(gInstances); Result:=0;
end;

function RecorderVisualUsesPluginNotifications:LongBool; cdecl;
begin Result:=True; end;

function ProbeCloseCount:LongWord; cdecl;
begin Result:=gCloseCount; end;
function ProbePluginDestroyCount:LongWord; cdecl;
begin Result:=gPluginDestroyCount; end;
function ProbeWorkerStopCount:LongWord; cdecl;
begin Result:=gWorkerStopCount; end;
function ProbeWorkerRunning:LongWord; cdecl;
begin Result:=Ord(gProbeWorker<>nil); end;

function ProbeFinalizePinnedPlugin:LongInt; cdecl;
begin
  Result:=REC_VISUAL_ERROR;
  if (gPlugin=nil) or gPlugin.HasInstances then Exit;
  if not PluginClose(Pointer(gPlugin)) then Exit;
  if DestroyPluginClass(Pointer(gPlugin))<>0 then Exit;
  Result:=REC_VISUAL_OK;
end;

{ Для теста gateway: синхронно вызывает сервис журнала на потоке вызывающего. }
function ProbeLogService:LongInt; cdecl;
begin
  Result:=REC_VISUAL_ERROR;
  if (gBorrowedHostApi=nil) or not Assigned(gBorrowedHostApi^.LogMessage) then Exit;
  gBorrowedHostApi^.LogMessage(gBorrowedHostApi^.HostContext,'blocking probe');
  Result:=REC_VISUAL_OK;
end;
{$ENDIF}

exports
  {$IFDEF PLUGIN_NEW_LIFECYCLE}
  CreatePluginClass, PluginCreate, PluginNotify, PluginClose,
  DestroyPluginClass, RecorderVisualUsesPluginNotifications, ProbeFinalizePinnedPlugin,
  ProbeCloseCount, ProbePluginDestroyCount, ProbeWorkerStopCount, ProbeWorkerRunning,
  ProbeLogService,
  {$ENDIF}
  RecorderVisualGetDescriptorV2 name 'RecorderVisualGetDescriptorV2',
  ProbeNativeViewCount name 'ProbeNativeViewCount',
  ProbeFailedDestroyCount name 'ProbeFailedDestroyCount',
  ProbeVoidDestroyCount name 'ProbeVoidDestroyCount',
  ProbeBorrowedServices name 'ProbeBorrowedServices',
  ProbeCleanupFailedDestroy name 'ProbeCleanupFailedDestroy';

begin
  Application.Initialize;
  Application.ShowMainForm := False;
end.
