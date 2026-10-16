program VisualComponentAbiV2StateRoundTrip;

{$mode objfpc}{$H+}

uses
  SysUtils, DynLibs, uRecorderVisualComponentApiV2;

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

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function SaveBytes(ASave: TRecorderVisualSaveStateV2;
  AInstance: Pointer): TBytes;
var
  lRequired: SizeUInt;
  lStatus: LongInt;
begin
  Result := nil;
  lRequired := 0;
  lStatus := ASave(AInstance, nil, 0, lRequired);
  Check(lStatus = REC_VISUAL_BUFFER_TOO_SMALL,
    'non-empty state query must return BUFFER_TOO_SMALL');
  Check(lRequired = SizeOf(TProbeState), 'unexpected queried state size');
  SetLength(Result, lRequired);
  lStatus := ASave(AInstance, @Result[0], Length(Result), lRequired);
  Check(lStatus = REC_VISUAL_OK, 'state save failed');
  Check(lRequired = Length(Result), 'state save returned inconsistent size');
end;

procedure RunProbe(const APluginFileName: string);
var
  lHandle: TLibHandle;
  lGetDescriptor: TRecorderVisualGetDescriptorV2;
  lDescriptor: TRecorderVisualComponentDescriptorV2;
  lSecondDescriptor: TRecorderVisualComponentDescriptorV2;
  lInstance1: Pointer;
  lInstance2: Pointer;
  lSavedState: TBytes;
  lAfterInvalidLoad: TBytes;
  lRoundTripState: TBytes;
  lShortState: TProbeState;
  lBadState: TProbeState;
  lSmallBuffer: array[0..SizeOf(TProbeState) - 2] of Byte;
  lRequired: SizeUInt;
  lStatus: LongInt;
  lGuardedDescriptor: TRecorderVisualComponentDescriptorV2;
  lEmptyDescriptor: TRecorderVisualComponentDescriptorV2;
  lEmptyInstance: Pointer;
  lGuardByte: Byte;
begin
  lHandle := SafeLoadLibrary(APluginFileName);
  Check(lHandle <> NilHandle, 'could not load stateful probe plugin');
  lInstance1 := nil;
  lInstance2 := nil;
  try
    Pointer(lGetDescriptor) := GetProcedureAddress(lHandle,
      'RecorderVisualGetDescriptorV2');
    Check(Assigned(lGetDescriptor), 'v2 descriptor export is missing');

    FillChar(lDescriptor, SizeOf(lDescriptor), 0);
    lDescriptor.Header.Size := SizeOf(lDescriptor);
    Check(lGetDescriptor(0, @lDescriptor, SizeOf(lDescriptor)) = REC_VISUAL_OK,
      'descriptor index zero failed');
    Check(lDescriptor.Header.AbiMajor = REC_VISUAL_ABI_V2_MAJOR,
      'plugin ABI major mismatch');
    Check(StrPas(@lDescriptor.TypeId[0]) = 'test.stateful-visual',
      'unexpected plugin TypeId');
    Check(Assigned(lDescriptor.CreateInstance) and
      Assigned(lDescriptor.DestroyInstance) and
      Assigned(lDescriptor.SaveState) and Assigned(lDescriptor.LoadState),
      'required state callbacks are missing');

    FillChar(lSecondDescriptor, SizeOf(lSecondDescriptor), 0);
    lSecondDescriptor.Header.Size := SizeOf(lSecondDescriptor);
    Check(lGetDescriptor(2, @lSecondDescriptor, SizeOf(lSecondDescriptor)) =
      REC_VISUAL_END_OF_ENUMERATION, 'descriptor enumeration did not end');

    FillChar(lGuardedDescriptor, SizeOf(lGuardedDescriptor), $A5);
    lGuardByte := $A5;
    Check(lGetDescriptor(0, @lGuardedDescriptor, 1) = REC_VISUAL_ERROR,
      'undersized descriptor buffer should be rejected');
    Check(PByte(@lGuardedDescriptor)^ = lGuardByte,
      'undersized descriptor call wrote into caller memory');

    FillChar(lEmptyDescriptor, SizeOf(lEmptyDescriptor), 0);
    Check(lGetDescriptor(1, @lEmptyDescriptor, SizeOf(lEmptyDescriptor)) =
      REC_VISUAL_OK, 'empty-state descriptor missing');
    Check(not RecorderVisualFieldPresentV2(lEmptyDescriptor.Header.Size,
      PtrUInt(@lEmptyDescriptor.ImportState)-PtrUInt(@lEmptyDescriptor),SizeOf(Pointer)),
      'pre-2.4 descriptor unexpectedly exposes import');
    Check(StrPas(@lEmptyDescriptor.TypeId[0]) = 'test.empty-state-visual',
      'unexpected empty-state TypeId');
    lEmptyInstance := nil;
    Check(lEmptyDescriptor.CreateInstance(nil, nil, 0, lEmptyInstance) =
      REC_VISUAL_OK, 'empty state instance creation failed');
    Check(lEmptyDescriptor.SaveState(lEmptyInstance, nil, 0, lRequired) =
      REC_VISUAL_OK, 'empty state save should succeed with zero bytes');
    Check(lRequired = 0, 'empty state should serialize to zero bytes');
    Check(lEmptyDescriptor.LoadState(lEmptyInstance, nil, 0) = REC_VISUAL_OK,
      'empty state load should succeed');
    lEmptyDescriptor.DestroyInstance(lEmptyInstance);

    Check(lDescriptor.CreateInstance(nil, nil, 0, lInstance1) = REC_VISUAL_OK,
      'default instance creation failed');
    Check(lInstance1 <> nil, 'plugin returned a nil instance');

    lSavedState := SaveBytes(lDescriptor.SaveState, lInstance1);
    Check(Length(lSavedState) = SizeOf(TProbeState),
      'default state was not serialized');
    Move(lSavedState[0], lShortState, SizeOf(lShortState));
    Check(lShortState.Value = 17, 'plugin default state is unexpected');
    lShortState.Value := 991;
    Move(lShortState, lSavedState[0], SizeOf(lShortState));
    FillChar(lSmallBuffer, SizeOf(lSmallBuffer), $CC);
    lRequired := 0;
    lStatus := lDescriptor.SaveState(lInstance1, @lSmallBuffer[0],
      SizeOf(lSmallBuffer), lRequired);
    Check(lStatus = REC_VISUAL_BUFFER_TOO_SMALL,
      'undersized state buffer should return BUFFER_TOO_SMALL');
    Check(lRequired = SizeOf(TProbeState),
      'undersized state response should report required byte count');
    Check(lSmallBuffer[0] = $CC,
      'undersized state save wrote partial bytes');
    Check(lDescriptor.LoadState(lInstance1, @lSavedState[0],
      Length(lSavedState)) = REC_VISUAL_OK, 'valid state load failed');

    lAfterInvalidLoad := SaveBytes(lDescriptor.SaveState, lInstance1);
    Check(lDescriptor.LoadState(lInstance1, @lSavedState[0],
      Length(lSavedState) - 1) = REC_VISUAL_ERROR,
      'truncated state should be rejected');
    lBadState := lShortState;
    lBadState.Magic := 0;
    Check(lDescriptor.LoadState(lInstance1, @lBadState, SizeOf(lBadState)) =
      REC_VISUAL_ERROR, 'same-size state with bad magic should be rejected');
    lRoundTripState := SaveBytes(lDescriptor.SaveState, lInstance1);
    Check(CompareMem(@lAfterInvalidLoad[0], @lRoundTripState[0],
      Length(lAfterInvalidLoad)),
      'failed LoadState changed the prior instance state');

    Check(lDescriptor.CreateInstance(nil, nil, 0, lInstance2) = REC_VISUAL_OK,
      'second instance creation failed');
    Check(lDescriptor.LoadState(lInstance2, @lSavedState[0],
      Length(lSavedState)) = REC_VISUAL_OK, 'restoring into fresh instance failed');
    lRoundTripState := SaveBytes(lDescriptor.SaveState, lInstance2);
    Check(CompareMem(@lSavedState[0], @lRoundTripState[0],
      Length(lSavedState)),
      'save/load round-trip changed opaque state bytes');

    { Destruction is deliberately complete before the library is unloaded. }
    lDescriptor.DestroyInstance(lInstance2);
    lInstance2 := nil;
    lDescriptor.DestroyInstance(lInstance1);
    lInstance1 := nil;
  finally
    if lInstance2 <> nil then
      lDescriptor.DestroyInstance(lInstance2);
    if lInstance1 <> nil then
      lDescriptor.DestroyInstance(lInstance1);
    FreeLibrary(lHandle);
  end;
end;

begin
  try
    if ParamCount <> 1 then
      raise Exception.Create('Usage: VisualComponentAbiV2StateRoundTrip <plugin>');
    RunProbe(ParamStr(1));
    WriteLn('RESULT VisualComponentAbiV2StateRoundTrip passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT VisualComponentAbiV2StateRoundTrip failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
