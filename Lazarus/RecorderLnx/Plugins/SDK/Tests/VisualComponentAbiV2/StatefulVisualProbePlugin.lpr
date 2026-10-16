library StatefulVisualProbePlugin;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

uses
  Interfaces, Forms, Classes, SysUtils, Math, uRecorderVisualComponentApiV2,
  uProbeNativeView;

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
  Result := REC_VISUAL_OK;
end;

procedure DestroyInstance(AInstance: Pointer); cdecl;
begin
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

exports
  RecorderVisualGetDescriptorV2 name 'RecorderVisualGetDescriptorV2',
  ProbeNativeViewCount name 'ProbeNativeViewCount',
  ProbeFailedDestroyCount name 'ProbeFailedDestroyCount',
  ProbeVoidDestroyCount name 'ProbeVoidDestroyCount',
  ProbeCleanupFailedDestroy name 'ProbeCleanupFailedDestroy';

begin
  Application.Initialize;
  Application.ShowMainForm := False;
end.
