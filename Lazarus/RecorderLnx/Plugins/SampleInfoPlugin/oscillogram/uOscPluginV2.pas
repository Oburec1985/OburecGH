unit uOscPluginV2;
{$mode objfpc}{$H+}{$codepage UTF8}

{ The plugin owns type/model/state/editor/views and Oscillogram behavior.
  Only versioned flat SDK services, native parents and opaque bytes cross ABI.
  RecorderLnx domain classes/objects and host-side Oscillogram logic are banned. }
interface
uses uRecorderVisualComponentApiV2;
function RecorderVisualGetDescriptorV2(AIndex: LongWord;
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ADescriptorCapacity: SizeUInt): LongInt; cdecl;
implementation
uses Classes, SysUtils, Math, Forms, Controls, uOscModel, uOscTags, uOscUnits,
  uOscDataAdapter, uOscSettings, uOscNativeForm, uOscLegacyImport;

function ValidPayload(AData: Pointer; ASize, ARequired: SizeUInt): Boolean;
var lHeader: PRecorderVisualAbiHeaderV2;
begin
  Result := False;
  if (AData = nil) or (ASize < ARequired) then Exit;
  lHeader := PRecorderVisualAbiHeaderV2(AData);
  Result := (lHeader^.AbiMajor = REC_VISUAL_ABI_V2_MAJOR) and
    (lHeader^.Size >= ARequired) and (lHeader^.Size <= ASize);
end;
type
  TOscInstance = class
  private
    fServices: PRecorderVisualHostServicesV2;
    fModel: TOscModel;
    fTags: TOscTagRegistry;
    fUnits: TOscUnitCatalog;
    fViews: TList;
    fRunning: Boolean;
    function FindView(AId: QWord): TOscNativeForm;
    procedure ConfigureViews;
    procedure RefreshViews;
    function ViewMessage(AKind: LongWord;
      const ASurface: TRecorderVisualSurfaceV2): LongInt;
  public
    constructor Create(AServices: PRecorderVisualHostServicesV2);
    destructor Destroy; override;
  end;

constructor TOscInstance.Create(AServices: PRecorderVisualHostServicesV2);
begin
  inherited Create;
  fServices := AServices;
  fViews := TList.Create;
  fModel := TOscModel.Create;
  fTags := TOscTagRegistry.Create(AServices);
  fUnits := TOscUnitCatalog.Create;
  if fTags.Configure <> REC_VISUAL_OK then
    raise Exception.Create('Cannot enumerate plugin tag catalog');
  if fUnits.Configure(AServices) <> REC_VISUAL_OK then
    raise Exception.Create('Cannot enumerate shared unit catalog');
  fTags.RefreshInfo;
end;

destructor TOscInstance.Destroy;
begin
  if fViews <> nil then
    while fViews.Count > 0 do
    begin
      TObject(fViews[fViews.Count - 1]).Free;
      fViews.Delete(fViews.Count - 1);
    end;
  fViews.Free;
  fUnits.Free;
  fTags.Free;
  fModel.Free;
  inherited Destroy;
end;

function TOscInstance.FindView(AId: QWord): TOscNativeForm;
var I: Integer;
begin
  for I := 0 to fViews.Count - 1 do
  begin
    Result := TOscNativeForm(fViews[I]);
    if Result.ViewId = AId then Exit;
  end;
  Result := nil;
end;

procedure TOscInstance.ConfigureViews;
var I: Integer;
begin
  fTags.RefreshInfo;
  for I := 0 to fViews.Count - 1 do
  begin
    TOscNativeForm(fViews[I]).View.Configure(fModel, fTags);
    TOscNativeForm(fViews[I]).View.PrepareHistoryBuffers(
      Max(fModel.XScale, TOscNativeForm(fViews[I]).DisplayWindowSeconds));
  end;
end;

procedure TOscInstance.RefreshViews;
var I: Integer;
begin
  fTags.RefreshInfo;
  for I := 0 to fViews.Count - 1 do
    TOscNativeForm(fViews[I]).View.Refresh(fTags,
      TOscNativeForm(fViews[I]).DisplayWindowSeconds, fRunning);
end;

function TOscInstance.ViewMessage(AKind: LongWord;
  const ASurface: TRecorderVisualSurfaceV2): LongInt;
var lView: TOscNativeForm; lBackend: LongWord;
begin
  lBackend := REC_VISUAL_NATIVE_NONE;
  {$IFDEF LCLwin32} lBackend := REC_VISUAL_NATIVE_WIN32; {$ENDIF}
  {$IFDEF LCLgtk2} lBackend := REC_VISUAL_NATIVE_GTK2; {$ENDIF}
  if (lBackend = REC_VISUAL_NATIVE_NONE) or
    (ASurface.NativeBackend <> lBackend) then Exit(REC_VISUAL_NOT_HANDLED);
  lView := FindView(ASurface.ViewId);
  case AKind of
    REC_VISUAL_DISPATCH_ATTACH_VIEW:
      begin
        if (lView <> nil) or (ASurface.ParentWindow = 0) then Exit(REC_VISUAL_ERROR);
        lView := TOscNativeForm.Create(nil);
        try
          lView.ViewId := ASurface.ViewId;
          lView.DisplayWindowSeconds := 1.0;
          lView.ParentWindow := ASurface.ParentWindow;
          lView.SetBounds(0,0,ASurface.Width,ASurface.Height);
          lView.Enabled := (ASurface.Flags and REC_VISUAL_VIEW_INTERACTIVE) <> 0;
          lView.View.UnitCatalog := fUnits;
          lView.View.Configure(fModel, fTags);
          lView.Show;
          lView.View.ForceRepaint;
          fViews.Add(lView);
        except
          lView.Free;
          raise;
        end;
      end;
    REC_VISUAL_DISPATCH_DETACH_VIEW:
      begin
        if lView = nil then Exit(REC_VISUAL_OK);
        lView.Free;
        fViews.Remove(lView);
      end;
    REC_VISUAL_DISPATCH_RESIZE_VIEW:
      begin
        if lView = nil then Exit(REC_VISUAL_ERROR);
        lView.SetBounds(0,0,ASurface.Width,ASurface.Height);
      end;
    REC_VISUAL_DISPATCH_VIEW_MODE:
      begin
        if lView = nil then Exit(REC_VISUAL_ERROR);
        lView.Enabled := (ASurface.Flags and REC_VISUAL_VIEW_INTERACTIVE) <> 0;
      end;
    else Exit(REC_VISUAL_NOT_HANDLED);
  end;
  Result := REC_VISUAL_OK;
end;

function OscCreate(AHostContext, AConfigData: Pointer; AConfigSize: SizeUInt;
  out AInstance: Pointer): LongInt; cdecl;
begin
  AInstance := nil;
  if (AConfigData <> nil) or (AConfigSize <> 0) then Exit(REC_VISUAL_ERROR);
  if not OscServicesAvailable(PRecorderVisualHostServicesV2(AHostContext)) or
    (PRecorderVisualHostServicesV2(AHostContext)^.Header.Size <
    SizeOf(TRecorderVisualHostServicesV2)) then Exit(REC_VISUAL_ERROR);
  try
    AInstance := TOscInstance.Create(PRecorderVisualHostServicesV2(AHostContext));
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function OscTryDestroy(AInstance: Pointer): LongInt; cdecl;
begin
  try
    TOscInstance(AInstance).Free;
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

procedure OscDestroy(AInstance: Pointer); cdecl;
begin
  { Old peers still use a void callback; never throw across their C boundary. }
  OscTryDestroy(AInstance);
end;

function OscSave(AInstance, ABuffer: Pointer; ACapacity: SizeUInt;
  out ARequiredSize: SizeUInt): LongInt; cdecl;
var lData: UTF8String;
begin
  ARequiredSize := 0;
  if AInstance = nil then Exit(REC_VISUAL_ERROR);
  try
    lData := TOscInstance(AInstance).fModel.SaveUtf8;
    ARequiredSize := Length(lData);
    if (ABuffer = nil) or (ACapacity < ARequiredSize) then
      Exit(REC_VISUAL_BUFFER_TOO_SMALL);
    if ARequiredSize > 0 then Move(lData[1], ABuffer^, ARequiredSize);
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function OscLoad(AInstance, AStateData: Pointer; AStateSize: SizeUInt): LongInt; cdecl;
var lData: UTF8String; lError: string; lBefore: TOscModel;
  lInstance: TOscInstance;
begin
  if (AInstance = nil) or (AStateData = nil) or
    (AStateSize > REC_VISUAL_MAX_STATE_BYTES) then Exit(REC_VISUAL_ERROR);
  lBefore := nil;
  try
    try
    lInstance := TOscInstance(AInstance);
    lBefore := lInstance.fModel.Clone;
    SetString(lData, PAnsiChar(AStateData), AStateSize);
    if not lInstance.fModel.LoadUtf8(lData, lError) then
      Exit(REC_VISUAL_ERROR);
    try
      lInstance.ConfigureViews;
      Result := REC_VISUAL_OK;
    except
      { Keep the published model identity: views borrow this same instance. }
      lInstance.fModel.Assign(lBefore);
      lInstance.ConfigureViews;
      Result := REC_VISUAL_ERROR;
    end;
    except Result := REC_VISUAL_ERROR;
    end;
  finally
    lBefore.Free;
  end;
end;

function OscImport(AInstance: Pointer; ARequest: PRecorderVisualImportRequestV2;
  ARequestSize: SizeUInt): LongInt; cdecl;
var lText: UTF8String; lError: string; lBefore: TOscModel;
  lInstance: TOscInstance;
begin
  Result := REC_VISUAL_ERROR;
  if (AInstance = nil) or not ValidPayload(ARequest,ARequestSize,SizeOf(ARequest^)) then Exit;
  if (ARequest^.Data = nil) or (ARequest^.DataSize > REC_VISUAL_MAX_STATE_BYTES) then Exit;
  if ARequest^.FormatId[High(ARequest^.FormatId)] <> #0 then Exit;
  if ARequest^.OriginalTypeId[High(ARequest^.OriginalTypeId)] <> #0 then Exit;
  if StrPas(@ARequest^.FormatId[0]) <> REC_VISUAL_STATE_INI_SECTION_V1 then
    Exit(REC_VISUAL_NOT_HANDLED);
  lBefore := nil;
  try
    try
      lInstance := TOscInstance(AInstance);
      lBefore := lInstance.fModel.Clone;
      SetString(lText,PAnsiChar(ARequest^.Data),ARequest^.DataSize);
      if not ImportOscLegacy(lText,StrPas(@ARequest^.OriginalTypeId[0]),
        lInstance.fModel,lError) then Exit;
      try
        lInstance.ConfigureViews;
        Result := REC_VISUAL_OK;
      except
        lInstance.fModel.Assign(lBefore);
        lInstance.ConfigureViews;
      end;
    except Result := REC_VISUAL_ERROR; end;
  finally lBefore.Free; end;
end;

function OscEdit(AInstance, AHostContext, AEditRequest: Pointer;
  AEditRequestSize: SizeUInt): LongInt; cdecl;
var lCatalog: TOscTagCatalog;
begin
  if (AInstance = nil) or not ValidPayload(AEditRequest, AEditRequestSize,
    SizeOf(TRecorderVisualEditRequestV2)) then
    Exit(REC_VISUAL_ERROR);
  try
    if LoadOscTagCatalog(TOscInstance(AInstance).fServices, lCatalog) <>
      REC_VISUAL_OK then Exit(REC_VISUAL_ERROR);
    if not ShowOscSettings(nil, TOscInstance(AInstance).fModel, lCatalog,
      PRecorderVisualEditRequestV2(AEditRequest)^.OwnerWindow,
      PRecorderVisualEditRequestV2(AEditRequest)^.NativeBackend,
      PRecorderVisualEditRequestV2(AEditRequest)^.Dpi) then
      Exit(REC_VISUAL_CANCELLED);
    TOscInstance(AInstance).ConfigureViews;
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function OscDispatch(AInstance: Pointer; AKind: LongWord;
  AInput: Pointer; AInputSize: SizeUInt; AOutput: Pointer;
  AOutputCapacity: SizeUInt; out AOutputSize: SizeUInt): LongInt; cdecl;
var lInstance: TOscInstance; lContext: PRecorderVisualCreateContextV2;
  lTag: TOscTag; lViewContext: PRecorderVisualViewContextV2;
  lView: TOscNativeForm;
begin
  AOutputSize := 0;
  if AInstance = nil then Exit(REC_VISUAL_ERROR);
  lInstance := TOscInstance(AInstance);
  try
    case AKind of
      REC_VISUAL_DISPATCH_CONFIGURE:
        begin
          if not ValidPayload(AInput, AInputSize, SizeOf(TRecorderVisualCreateContextV2)) then
            Exit(REC_VISUAL_ERROR);
          lContext := PRecorderVisualCreateContextV2(AInput);
          lTag := lInstance.fTags.FindById(lContext^.SelectedTagId);
          if lTag = nil then lTag := lInstance.fTags.FindById(lContext^.DefaultTagId);
          if lTag <> nil then
          begin
            lInstance.fModel.TagId := lTag.Id;
            lInstance.fModel.TagName := lTag.Name;
          end;
          lInstance.ConfigureViews;
        end;
      REC_VISUAL_DISPATCH_START: lInstance.fRunning := True;
      REC_VISUAL_DISPATCH_STOP: lInstance.fRunning := False;
      REC_VISUAL_DISPATCH_CATALOG_CHANGED:
        begin
          if lInstance.fUnits.Configure(lInstance.fServices) <> REC_VISUAL_OK then
            Exit(REC_VISUAL_ERROR);
          if lInstance.fTags.Configure <> REC_VISUAL_OK then
            Exit(REC_VISUAL_ERROR);
          lInstance.ConfigureViews;
        end;
      REC_VISUAL_DISPATCH_DATA_UPDATED: lInstance.RefreshViews;
      REC_VISUAL_DISPATCH_VIEW_CONTEXT:
        begin
          if not ValidPayload(AInput, AInputSize, SizeOf(TRecorderVisualViewContextV2)) then
            Exit(REC_VISUAL_ERROR);
          lViewContext := PRecorderVisualViewContextV2(AInput);
          if IsNan(lViewContext^.DisplayWindowSeconds) or
            IsInfinite(lViewContext^.DisplayWindowSeconds) or
            (lViewContext^.DisplayWindowSeconds <= 0) then Exit(REC_VISUAL_ERROR);
          lView := lInstance.FindView(lViewContext^.ViewId);
          if lView = nil then Exit(REC_VISUAL_NOT_FOUND);
          if lView.DisplayWindowSeconds <> lViewContext^.DisplayWindowSeconds then
          begin
            lView.View.PrepareHistoryBuffers(Max(lInstance.fModel.XScale,
              lViewContext^.DisplayWindowSeconds));
            lView.DisplayWindowSeconds := lViewContext^.DisplayWindowSeconds;
            lView.View.Refresh(lInstance.fTags, lView.DisplayWindowSeconds,
              lInstance.fRunning);
          end;
        end;
      REC_VISUAL_DISPATCH_ATTACH_VIEW, REC_VISUAL_DISPATCH_DETACH_VIEW,
      REC_VISUAL_DISPATCH_RESIZE_VIEW, REC_VISUAL_DISPATCH_VIEW_MODE:
        begin
          if not ValidPayload(AInput, AInputSize, SizeOf(TRecorderVisualSurfaceV2)) then
            Exit(REC_VISUAL_ERROR);
          if (PRecorderVisualSurfaceV2(AInput)^.Width < 0) or
            (PRecorderVisualSurfaceV2(AInput)^.Height < 0) or
            ((PRecorderVisualSurfaceV2(AInput)^.Flags and not REC_VISUAL_VIEW_INTERACTIVE) <> 0) then
            Exit(REC_VISUAL_ERROR);
          Exit(lInstance.ViewMessage(AKind, PRecorderVisualSurfaceV2(AInput)^));
        end;
      else Exit(REC_VISUAL_NOT_HANDLED);
    end;
    Result := REC_VISUAL_OK;
  except Result := REC_VISUAL_ERROR; end;
end;

function RecorderVisualGetDescriptorV2(AIndex: LongWord;
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ADescriptorCapacity: SizeUInt): LongInt; cdecl;
var lDescriptor: TRecorderVisualComponentDescriptorV2;
  lDestination: PRecorderVisualComponentDescriptorV2; lCopySize: SizeUInt;
begin
  if AIndex <> 0 then Exit(REC_VISUAL_END_OF_ENUMERATION);
  if (ADescriptor = nil) or (ADescriptorCapacity <
    PtrUInt(@lDescriptor.Edit)-PtrUInt(@lDescriptor)) then
    Exit(REC_VISUAL_ERROR);
  { Old hosts can request their known prefix. Build locally and publish only
    the bytes they supplied capacity for, with Size describing that prefix. }
  lDestination := ADescriptor;
  lCopySize := SizeOf(lDescriptor);
  if ADescriptorCapacity < lCopySize then lCopySize := ADescriptorCapacity;
  ADescriptor := @lDescriptor;
  FillChar(ADescriptor^, SizeOf(ADescriptor^), 0);
  ADescriptor^.Header.Size := SizeOf(ADescriptor^);
  ADescriptor^.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  ADescriptor^.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
  StrPLCopy(@ADescriptor^.TypeId[0], 'sample.oscillogram', High(ADescriptor^.TypeId));
  StrPLCopy(@ADescriptor^.DisplayName[0], UTF8String('Осциллограф'),
    High(ADescriptor^.DisplayName));
  StrPLCopy(@ADescriptor^.Category[0], 'charts', High(ADescriptor^.Category));
  ADescriptor^.CreateInstance := @OscCreate;
  ADescriptor^.DestroyInstance := @OscDestroy;
  ADescriptor^.SaveState := @OscSave;
  ADescriptor^.LoadState := @OscLoad;
  ADescriptor^.Edit := @OscEdit;
  ADescriptor^.ViewDispatch := @OscDispatch;
  ADescriptor^.ImportState := @OscImport;
  ADescriptor^.TryDestroyInstance := @OscTryDestroy;
  ADescriptor^.Header.Size := lCopySize;
  Move(lDescriptor,lDestination^,lCopySize);
  Result := REC_VISUAL_OK;
end;
end.
