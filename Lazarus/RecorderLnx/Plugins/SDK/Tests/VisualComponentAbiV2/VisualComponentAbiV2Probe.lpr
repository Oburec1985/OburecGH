program VisualComponentAbiV2Probe;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

uses
  SysUtils, uRecorderVisualComponentApiV2;

type
  { Simulates a peer compiled against the stable v2 descriptor prefix. }
  TDescriptorPrefixV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    TypeId: array[0..REC_VISUAL_TYPE_ID_CAPACITY - 1] of AnsiChar;
    DisplayName: array[0..REC_VISUAL_DISPLAY_NAME_CAPACITY - 1] of AnsiChar;
    Category: array[0..REC_VISUAL_CATEGORY_CAPACITY - 1] of AnsiChar;
    Flags: QWord;
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function DummyCreate(AHostContext: Pointer; AConfigData: Pointer;
  AConfigSize: SizeUInt; out AInstance: Pointer): LongInt; cdecl;
begin
  AInstance := nil;
  Result := REC_VISUAL_OK;
end;

function FieldOffset(const ABase; const AField): SizeUInt; inline;
begin
  Result := PtrUInt(@AField) - PtrUInt(@ABase);
end;

procedure RunProbe;
var
  lDescriptor: TRecorderVisualComponentDescriptorV2;
  lPrefix: TDescriptorPrefixV2;
  lPointerSize: SizeUInt;
  lCallbackOffset: SizeUInt;
  lServices: TRecorderVisualHostServicesV2;
  lEdit: TRecorderVisualEditRequestV2;
  lSurface: TRecorderVisualSurfaceV2;
  lViewContext: TRecorderVisualViewContextV2;
begin
  FillChar(lDescriptor, SizeOf(lDescriptor), 0);
  lPointerSize := SizeOf(Pointer);

  Check(SizeOf(TRecorderVisualAbiHeaderV2) = 8,
    'ABI header must be exactly 8 bytes');
  Check(SizeOf(lViewContext)=24,'view context C-layout size');
  Check(FieldOffset(lViewContext,lViewContext.ViewId)=8,'view context ID offset');
  Check(FieldOffset(lViewContext,lViewContext.DisplayWindowSeconds)=16,
    'view context window offset');
  Check(FieldOffset(lDescriptor, lDescriptor.TypeId) = 8,
    'unexpected TypeId offset');
  Check(FieldOffset(lDescriptor, lDescriptor.DisplayName) = 136,
    'unexpected DisplayName offset');
  Check(FieldOffset(lDescriptor, lDescriptor.Category) = 264,
    'unexpected Category offset');
  Check(FieldOffset(lDescriptor, lDescriptor.Flags) = 328,
    'unexpected Flags offset');
  lCallbackOffset := (336 + lPointerSize - 1) and not (lPointerSize - 1);
  Check(FieldOffset(lDescriptor, lDescriptor.CreateInstance) = lCallbackOffset,
    'unexpected callback table offset');
  Check(FieldOffset(lDescriptor,lDescriptor.ImportState) = lCallbackOffset + 6*lPointerSize,
    'append-only import callback offset');
  Check(FieldOffset(lDescriptor,lDescriptor.EnumerateAliases) = lCallbackOffset + 7*lPointerSize,
    'append-only alias callback offset');
  Check(FieldOffset(lDescriptor,lDescriptor.TryDestroyInstance) = lCallbackOffset + 8*lPointerSize,
    'append-only status destruction offset');
  Check(not RecorderVisualFieldPresentV2(lCallbackOffset + 8*lPointerSize,
    FieldOffset(lDescriptor,lDescriptor.TryDestroyInstance),lPointerSize),
    'old descriptor must not expose status destruction');
  Check(SizeOf(lDescriptor) = lCallbackOffset + 9 * lPointerSize,
    'unexpected descriptor size');
  Check(not RecorderVisualFieldPresentV2(lCallbackOffset + 6*lPointerSize,
    FieldOffset(lDescriptor,lDescriptor.ImportState),lPointerSize),
    'old descriptor must not expose import callback');
  Check(SizeOf(TRecorderVisualImportRequestV2) = 200 + 2*lPointerSize,
    'legacy import request size');
  Check(FieldOffset(lServices, lServices.Context) = 8, 'services context offset');
  Check(FieldOffset(lServices, lServices.EnumerateTags) = 8 + lPointerSize,
    'services enumeration callback offset');
  Check(FieldOffset(lServices, lServices.CopyLatestHistory) = 8 + 2*lPointerSize,
    'services history callback offset');
  Check(FieldOffset(lServices, lServices.CopyRangeHistory) = 8 + 3*lPointerSize,
    'appended range callback changed the old services prefix');
  Check(FieldOffset(lServices, lServices.ConversionFactor) = 8 + 9*lPointerSize,
    'appended conversion callback offset');
  Check(SizeOf(lServices) = 8 + 10*lPointerSize, 'services table size');
  Check(SizeOf(TRecorderVisualTagInfoV2) = 624, 'tag metadata stable prefix size');
  Check(SizeOf(TRecorderVisualSignalInfoV2) = 40, 'atomic signal info size');
  Check(SizeOf(TRecorderVisualEstimateV2) = 48, 'estimate record size');
  Check(SizeOf(TRecorderVisualEstimateSettingsV2) = 24, 'estimate settings size');
  Check(SizeOf(TRecorderVisualUnitInfoV2) = 208, 'unit metadata size');
  Check(FieldOffset(lEdit, lEdit.OwnerWindow) = 16, 'editor owner offset');
  Check(SizeOf(lEdit) = 16 + lPointerSize, 'editor request size');
  Check(FieldOffset(lSurface, lSurface.ViewId) = 8, 'surface view ID offset');
  Check(FieldOffset(lSurface, lSurface.NativeBackend) = 16, 'surface backend offset');
  Check(FieldOffset(lSurface, lSurface.ParentWindow) = 24, 'surface parent offset');
  Check(FieldOffset(lSurface, lSurface.Width) = 24 + lPointerSize,
    'surface width offset');
  Check(FieldOffset(lSurface, lSurface.Reserved) = 36 + lPointerSize,
    'surface reserved tail offset');
  if lPointerSize = 8 then
    Check(SizeOf(lSurface) = 48, '64-bit native surface size')
  else
    {$IFDEF MSWINDOWS}
    Check(SizeOf(lSurface) = 48, 'Win32 native surface C-aligned size');
    {$ELSE}
    Check(SizeOf(lSurface) = 44, '32-bit native surface C-aligned size');
    {$ENDIF}
  Check(not RecorderVisualFieldPresentV2(24, 24, lPointerSize),
    'truncated surface incorrectly exposes a native parent');

  { A new descriptor is safely readable by an older peer using its known
    prefix, and the new callback tail is detectable without dereferencing it. }
  lDescriptor.Header.Size := SizeOf(lDescriptor);
  lDescriptor.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  lDescriptor.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  lDescriptor.Flags := QWord($1122334455667788);
  lDescriptor.CreateInstance := @DummyCreate;
  Move(lDescriptor, lPrefix, SizeOf(lPrefix));
  Check(lPrefix.Flags = lDescriptor.Flags, 'stable prefix copy failed');
  Check(SizeOf(lPrefix) = 336, 'unexpected stable prefix size');
  Check(RecorderVisualFieldPresentV2(lDescriptor.Header.Size,
    FieldOffset(lDescriptor, lDescriptor.CreateInstance), lPointerSize),
    'new peer callback tail was not detected');
  Check(not RecorderVisualFieldPresentV2(SizeOf(lPrefix),
    FieldOffset(lDescriptor, lDescriptor.CreateInstance), lPointerSize),
    'old prefix incorrectly claims the callback tail exists');
  Check(not RecorderVisualFieldPresentV2(High(SizeUInt), High(SizeUInt), 2),
    'overflow-safe size guard failed');
  Check(RecorderVisualFieldPresentV2(SizeOf(lPrefix), 0, SizeOf(lPrefix)),
    'full prefix should be present');

  WriteLn('ABI pointer size: ', lPointerSize);
  WriteLn('ABI descriptor size: ', SizeOf(lDescriptor));
  WriteLn('ABI stable prefix size: ', SizeOf(lPrefix));
end;

begin
  try
    RunProbe;
    WriteLn('RESULT VisualComponentAbiV2 passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT VisualComponentAbiV2 failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
