unit uRecorderVisualComponentApiV2;

{ Generic visual-component ABI v2.
  This unit is additive: it does not alter the legacy Recorder plugin ABI.
  Only C-layout records, fixed ANSI byte arrays, integer scalars, opaque
  pointers, pointer/size buffers and cdecl callbacks may cross the boundary.
  Record fields are append-only within ABI major version 2. A consumer must
  check Size before reading a field that may not exist in an older prefix. }

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

const
  REC_VISUAL_ABI_V2_MAJOR = 2;
  REC_VISUAL_ABI_V2_MINOR = 7;
  REC_VISUAL_STATE_INI_SECTION_V1 = 'recorder.ini.section-v1';
  REC_VISUAL_STATE_UNKNOWN_ENVELOPE_V1 = 'recorder.unknown-envelope-v1';

  REC_VISUAL_OK = 0;
  REC_VISUAL_ERROR = -1;
  REC_VISUAL_BUFFER_TOO_SMALL = 1;
  REC_VISUAL_NOT_HANDLED = 2;
  REC_VISUAL_END_OF_ENUMERATION = 3;
  REC_VISUAL_NOT_FOUND = 4;
  REC_VISUAL_CANCELLED = 5;
  REC_VISUAL_MAX_DESCRIPTORS = 1024;
  REC_VISUAL_MAX_STATE_BYTES = 16 * 1024 * 1024;

  { Generic ViewDispatch lifecycle messages. They carry no component-specific
    meaning and are delivered on the UI thread. }
  REC_VISUAL_DISPATCH_START = 1;
  REC_VISUAL_DISPATCH_STOP = 2;
  REC_VISUAL_DISPATCH_DATA_UPDATED = 3;
  REC_VISUAL_DISPATCH_CONFIGURE = 4;
  REC_VISUAL_DISPATCH_ATTACH_VIEW = 5;
  REC_VISUAL_DISPATCH_DETACH_VIEW = 6;
  REC_VISUAL_DISPATCH_RESIZE_VIEW = 7;
  REC_VISUAL_DISPATCH_VIEW_MODE = 8;
  { Cold notification: metadata/settings/units may have changed. Re-enumerate
    and prepare buffers here, never during DATA_UPDATED. No selection reset. }
  REC_VISUAL_DISPATCH_CATALOG_CHANGED = 9;
  { Cold per-view display context. Older plugins return NOT_HANDLED. }
  REC_VISUAL_DISPATCH_VIEW_CONTEXT = 10;

  REC_VISUAL_TYPE_ID_CAPACITY = 128;
  REC_VISUAL_DISPLAY_NAME_CAPACITY = 128;
  REC_VISUAL_CATEGORY_CAPACITY = 64;
  REC_VISUAL_TAG_NAME_CAPACITY = 128;
  REC_VISUAL_TAG_UNIT_CAPACITY = 64;
  REC_VISUAL_TAG_ADDRESS_CAPACITY = 128;
  REC_VISUAL_TAG_DESCRIPTION_CAPACITY = 256;

  REC_VISUAL_TAG_FLAG_VIRTUAL = QWord(1) shl 0;
  REC_VISUAL_TAG_FLAG_VECTOR = QWord(1) shl 1;
  REC_VISUAL_TAG_FLAG_AUTO_RANGE = QWord(1) shl 2;
  REC_VISUAL_TAG_FLAG_SOURCE_VISIBLE = QWord(1) shl 3;

  { Stable numeric estimate kinds; these are protocol values, not Pascal enums. }
  REC_VISUAL_ESTIMATE_MEAN = 0;
  REC_VISUAL_ESTIMATE_RMS = 1;
  REC_VISUAL_ESTIMATE_RMS_DEVIATION = 2;
  REC_VISUAL_ESTIMATE_PEAK = 3;
  REC_VISUAL_ESTIMATE_PEAK_TO_PEAK = 4;
  REC_VISUAL_ESTIMATE_MINIMUM = 5;
  REC_VISUAL_ESTIMATE_MAXIMUM = 6;
  REC_VISUAL_ESTIMATE_PEAK_TO_PEAK_BY_RMS = 7;
  REC_VISUAL_ESTIMATE_LAST = 8;

  REC_VISUAL_NATIVE_NONE = 0;
  REC_VISUAL_NATIVE_WIN32 = 1;
  REC_VISUAL_NATIVE_GTK2 = 2;
  REC_VISUAL_NATIVE_GTK3 = 3;
  REC_VISUAL_NATIVE_QT5 = 4;
  REC_VISUAL_NATIVE_QT6 = 5;
  REC_VISUAL_NATIVE_COCOA = 6;
  REC_VISUAL_VIEW_INTERACTIVE = LongWord(1) shl 0;

type
  PRecorderVisualAbiHeaderV2 = ^TRecorderVisualAbiHeaderV2;
  TRecorderVisualAbiHeaderV2 = record
    Size: LongWord;
    AbiMajor: Word;
    AbiMinor: Word;
  end;

  PRecorderVisualViewContextV2 = ^TRecorderVisualViewContextV2;
  TRecorderVisualViewContextV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ViewId: QWord;
    DisplayWindowSeconds: Double;
  end;

  { For ABI 2.1, AHostContext points to a borrowed
    TRecorderVisualHostServicesV2 table. ABI 2.0 plugins may still ignore it.
    Payloads passed to edit/view carry their own size/version headers. }
  TRecorderVisualCreateInstanceV2 = function(AHostContext: Pointer;
    AConfigData: Pointer; AConfigSize: SizeUInt;
    out AInstance: Pointer): LongInt; cdecl;
  TRecorderVisualDestroyInstanceV2 = procedure(AInstance: Pointer); cdecl;
  TRecorderVisualSaveStateV2 = function(AInstance: Pointer;
    ABuffer: Pointer; ACapacity: SizeUInt;
    out ARequiredSize: SizeUInt): LongInt; cdecl;
  TRecorderVisualLoadStateV2 = function(AInstance: Pointer;
    AStateData: Pointer; AStateSize: SizeUInt): LongInt; cdecl;
  TRecorderVisualEditV2 = function(AInstance: Pointer;
    AHostContext: Pointer; AEditRequest: Pointer;
    AEditRequestSize: SizeUInt): LongInt; cdecl;
  TRecorderVisualViewDispatchV2 = function(AInstance: Pointer;
    ADispatchKind: LongWord; AInput: Pointer; AInputSize: SizeUInt;
    AOutput: Pointer; AOutputCapacity: SizeUInt;
    out AOutputSize: SizeUInt): LongInt; cdecl;

  { Borrowed UTF8 JSON object of the complete INI section, all values strings.
    The host transports bytes only. Only the plugin interprets legacy keys.
    Import failure leaves the instance unchanged; success is followed by Save. }
  PRecorderVisualImportRequestV2 = ^TRecorderVisualImportRequestV2;
  TRecorderVisualImportRequestV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    FormatId: array[0..63] of AnsiChar;
    OriginalTypeId: array[0..REC_VISUAL_TYPE_ID_CAPACITY - 1] of AnsiChar;
    Data: Pointer;
    DataSize: SizeUInt;
  end;
  TRecorderVisualImportStateV2 = function(AInstance: Pointer;
    ARequest: PRecorderVisualImportRequestV2; ARequestSize: SizeUInt): LongInt; cdecl;
  { Aliases are discovery metadata, never additional owned factories. }
  TRecorderVisualEnumerateAliasesV2 = function(AIndex: LongWord;
    ABuffer: PAnsiChar; ACapacity: SizeUInt): LongInt; cdecl;

  PRecorderVisualTagInfoV2 = ^TRecorderVisualTagInfoV2;
  TRecorderVisualTagInfoV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    TagId: QWord;
    Flags: QWord;
    PollFrequencyHz: Double;
    RangeMin: Double;
    RangeMax: Double;
    Name: array[0..REC_VISUAL_TAG_NAME_CAPACITY - 1] of AnsiChar;
    UnitName: array[0..REC_VISUAL_TAG_UNIT_CAPACITY - 1] of AnsiChar;
    Address: array[0..REC_VISUAL_TAG_ADDRESS_CAPACITY - 1] of AnsiChar;
    Description: array[0..REC_VISUAL_TAG_DESCRIPTION_CAPACITY - 1] of AnsiChar;
  end;

  TRecorderVisualEnumerateTagsV2 = function(AContext: Pointer;
    AIndex: LongWord; AInfo: PRecorderVisualTagInfoV2): LongInt; cdecl;
  TRecorderVisualCopyLatestHistoryV2 = function(AContext: Pointer;
    ATagId: QWord; AWindowSeconds: Double; ATimes, AValues: PDouble;
    ACapacity: LongWord; out ACount: LongWord; out ARevision: QWord;
    out AWindowStartSec, ALatestTimeSec: Double): LongInt; cdecl;

  TRecorderVisualSignalInfoV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    Revision, BlockCounter: QWord;
    Count: LongWord;
    Reserved: LongWord;
    LatestTimeSec: Double;
  end;
  PRecorderVisualSignalInfoV2 = ^TRecorderVisualSignalInfoV2;
  TRecorderVisualEstimateV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    Kind, Valid, Count, Reserved: LongWord;
    Value, StartTimeSec, EndTimeSec: Double;
  end;
  PRecorderVisualEstimateV2 = ^TRecorderVisualEstimateV2;
  TRecorderVisualEstimateSettingsV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    EnabledKinds: QWord;
    DefaultKind, Reserved: LongWord;
  end;
  PRecorderVisualEstimateSettingsV2 = ^TRecorderVisualEstimateSettingsV2;
  TRecorderVisualUnitInfoV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ScaleToBase: Double;
    Name, BaseUnitName, QuantityId: array[0..63] of AnsiChar;
  end;
  PRecorderVisualUnitInfoV2 = ^TRecorderVisualUnitInfoV2;
  { Range endpoints are inclusive. IncludePrevious is 0/1 and includes at
    most one predecessor of FromTimeSec. Revision and LatestTimeSec describe
    the same locked buffer as the copied samples. ACount reports required
    capacity; BUFFER_TOO_SMALL writes no caller array data. }
  TRecorderVisualCopyRangeHistoryV2 = function(AContext: Pointer;
    ATagId: QWord; AFromTimeSec, AToTimeSec: Double;
    AIncludePrevious: LongWord; ATimes, AValues: PDouble;
    ACapacity: LongWord; out ACount: LongWord; out ARevision: QWord;
    out AWindowStartSec, ALatestTimeSec: Double): LongInt; cdecl;
  TRecorderVisualGetSignalInfoV2 = function(AContext: Pointer;
    ATagId: QWord; AInfo: PRecorderVisualSignalInfoV2): LongInt; cdecl;
  TRecorderVisualGetSelectedTagIdV2 = function(AContext: Pointer;
    out ATagId: QWord): LongInt; cdecl;
  TRecorderVisualReadEstimateV2 = function(AContext: Pointer;
    ATagId: QWord; AKind: LongWord;
    AEstimate: PRecorderVisualEstimateV2): LongInt; cdecl;
  TRecorderVisualGetEstimateSettingsV2 = function(AContext: Pointer;
    ATagId: QWord; ASettings: PRecorderVisualEstimateSettingsV2): LongInt; cdecl;
  TRecorderVisualEnumerateUnitsV2 = function(AContext: Pointer;
    AIndex: LongWord; AInfo: PRecorderVisualUnitInfoV2): LongInt; cdecl;
  TRecorderVisualConversionFactorV2 = function(AContext: Pointer;
    AFromUnit, AToUnit: PAnsiChar; out AFactor: Double): LongInt; cdecl;

  { Borrowed host services. The host keeps this table alive until after all
    plugin instances and callbacks are destroyed. All callbacks are serialized
    on the UI thread. History arrays are caller-owned and never retained. }
  PRecorderVisualHostServicesV2 = ^TRecorderVisualHostServicesV2;
  TRecorderVisualHostServicesV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    Context: Pointer;
    EnumerateTags: TRecorderVisualEnumerateTagsV2;
    CopyLatestHistory: TRecorderVisualCopyLatestHistoryV2;
    { ABI 2.3 append-only generic read services. Consumers check Header.Size
      before accessing each callback; all POD strings use UTF-8. }
    CopyRangeHistory: TRecorderVisualCopyRangeHistoryV2;
    GetSignalInfo: TRecorderVisualGetSignalInfoV2;
    GetSelectedTagId: TRecorderVisualGetSelectedTagIdV2;
    ReadEstimate: TRecorderVisualReadEstimateV2;
    GetTagEstimateSettings: TRecorderVisualGetEstimateSettingsV2;
    EnumerateUnits: TRecorderVisualEnumerateUnitsV2;
    ConversionFactor: TRecorderVisualConversionFactorV2;
  end;

  { Generic palette-creation context delivered through
    REC_VISUAL_DISPATCH_CONFIGURE. Names, bounds and opaque component state
    remain in their normal host/plugin ownership domains. }
  PRecorderVisualCreateContextV2 = ^TRecorderVisualCreateContextV2;
  TRecorderVisualCreateContextV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ComponentNo: LongWord;
    SelectedTagId: QWord;
    DefaultTagId: QWord;
  end;

  { The plugin owns its modal editor and draft. Only a native owner handle
    crosses the boundary. Backend must be supported by the plugin. On OK the
    host saves opaque state; on CANCELLED/error it restores the prior snapshot.
    OwnerWindow is borrowed only for the synchronous Edit call. }
  PRecorderVisualEditRequestV2 = ^TRecorderVisualEditRequestV2;
  TRecorderVisualEditRequestV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    NativeBackend: LongWord;
    Dpi: LongWord;
    OwnerWindow: PtrUInt;
  end;

  { A plugin-owned native child view is attached to this borrowed native
    parent. Width/Height are parent-client pixels, Dpi describes their scale.
    NativeBackend identifies the actual C/widgetset native handle kind, not
    an LCL object. Unsupported backends return NOT_HANDLED. The plugin owns
    child controls and destroys/detaches them synchronously on DETACH_VIEW.
    In non-interactive mode pointer gestures belong to the host form editor.
    Every view must detach before its native parent or instance is destroyed. }
  PRecorderVisualSurfaceV2 = ^TRecorderVisualSurfaceV2;
  TRecorderVisualSurfaceV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ViewId: QWord;
    NativeBackend: LongWord;
    Dpi: LongWord;
    ParentWindow: PtrUInt;
    Width: LongInt;
    Height: LongInt;
    Flags: LongWord;
    Reserved: LongWord;
  end;

  { Optional status-bearing destruction: no exception crosses C ABI. }
  TRecorderVisualTryDestroyInstanceV2 = function(AInstance: Pointer): LongInt; cdecl;
  PRecorderVisualComponentDescriptorV2 = ^TRecorderVisualComponentDescriptorV2;
  TRecorderVisualComponentDescriptorV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    TypeId: array[0..REC_VISUAL_TYPE_ID_CAPACITY - 1] of AnsiChar;
    DisplayName: array[0..REC_VISUAL_DISPLAY_NAME_CAPACITY - 1] of AnsiChar;
    Category: array[0..REC_VISUAL_CATEGORY_CAPACITY - 1] of AnsiChar;
    Flags: QWord;
    CreateInstance: TRecorderVisualCreateInstanceV2;
    DestroyInstance: TRecorderVisualDestroyInstanceV2;
    SaveState: TRecorderVisualSaveStateV2;
    LoadState: TRecorderVisualLoadStateV2;
    Edit: TRecorderVisualEditV2;
    ViewDispatch: TRecorderVisualViewDispatchV2;
    ImportState: TRecorderVisualImportStateV2;
    EnumerateAliases: TRecorderVisualEnumerateAliasesV2;
    TryDestroyInstance: TRecorderVisualTryDestroyInstanceV2;
  end;

  PRecorderVisualGetDescriptorV2 = ^TRecorderVisualGetDescriptorV2;
  TRecorderVisualGetDescriptorV2 = function(AIndex: LongWord;
    ADescriptor: PRecorderVisualComponentDescriptorV2;
    ADescriptorCapacity: SizeUInt): LongInt; cdecl;

{ Overflow-safe append-only ABI guard. A field is present iff its complete
  byte range lies inside the size advertised by the peer. }
function RecorderVisualFieldPresentV2(ARecordSize, AFieldOffset,
  AFieldSize: SizeUInt): Boolean;

implementation

function RecorderVisualFieldPresentV2(ARecordSize, AFieldOffset,
  AFieldSize: SizeUInt): Boolean;
begin
  Result := (AFieldOffset <= ARecordSize) and
    (AFieldSize <= ARecordSize - AFieldOffset);
end;

end.
