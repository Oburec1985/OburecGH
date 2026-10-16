program OscViewSmoke;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Controls, ExtCtrls, ComCtrls, SysUtils, uOscModel, uOscTags,
  uOscView, uOscUnits, uRecorderVisualComponentApiV2;
var
  gRevision: QWord = 1;
  gReads: Integer;
  gMinCapacity: LongWord;
  gPointers: array[0..1] of Pointer;
  gCheckPointers: Boolean;

function EnumTags(AContext: Pointer; AIndex: LongWord;
  AInfo: PRecorderVisualTagInfoV2): LongInt; cdecl;
begin
  if AIndex > 1 then Exit(REC_VISUAL_END_OF_ENUMERATION);
  AInfo^.TagId := AIndex + 1;
  AInfo^.Flags := REC_VISUAL_TAG_FLAG_SOURCE_VISIBLE;
  AInfo^.PollFrequencyHz := 10000;
  AInfo^.RangeMin := -10;
  AInfo^.RangeMax := 10;
  StrPLCopy(@AInfo^.Name[0], 'Wave' + IntToStr(AIndex + 1), High(AInfo^.Name));
  Result := REC_VISUAL_OK;
end;

function SignalInfo(AContext: Pointer; ATagId: QWord;
  AInfo: PRecorderVisualSignalInfoV2): LongInt; cdecl;
begin
  AInfo^.Count := 5000;
  AInfo^.Revision := gRevision;
  AInfo^.BlockCounter := gRevision;
  AInfo^.LatestTimeSec := 1;
  Result := REC_VISUAL_OK;
end;

function Selection(AContext: Pointer; out ATagId: QWord): LongInt; cdecl;
begin
  ATagId := 1;
  Result := REC_VISUAL_OK;
end;

function CopyHistory(AContext: Pointer; ATagId: QWord; AWindowSeconds: Double;
  ATimes, AValues: PDouble; ACapacity: LongWord; out ACount: LongWord;
  out ARevision: QWord; out AStart, ALatest: Double): LongInt; cdecl;
var I, lIndex: Integer;
begin
  ACount := 5000;
  ARevision := gRevision;
  AStart := 0;
  ALatest := 1;
  if ACapacity < ACount then Exit(REC_VISUAL_BUFFER_TOO_SMALL);
  if ACapacity < gMinCapacity then
    raise Exception.Create('Base history not sized from frequency/window');
  lIndex := ATagId - 1;
  if gCheckPointers and (gPointers[lIndex] <> ATimes) then
    raise Exception.Create('Base history reallocated during Refresh');
  gPointers[lIndex] := ATimes;
  for I := 0 to ACount - 1 do
  begin
    ATimes[I] := I / 10000;
    AValues[I] := ATagId * Sin(I / 100);
  end;
  Inc(gReads);
  Result := REC_VISUAL_OK;
end;

procedure CheckBaseSurface(AOwner: TForm);
var
  lServices: TRecorderVisualHostServicesV2;
  lTags: TOscTagRegistry;
  lSurface: TOscBaseSurface;
begin
  lServices := Default(TRecorderVisualHostServicesV2);
  lServices.Header.Size := SizeOf(lServices);
  lServices.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
  lServices.EnumerateTags := @EnumTags;
  lServices.CopyLatestHistory := @CopyHistory;
  lServices.GetSignalInfo := @SignalInfo;
  lServices.GetSelectedTagId := @Selection;
  lTags := TOscTagRegistry.Create(@lServices);
  lSurface := TOscBaseSurface.Create(AOwner);
  try
    if lTags.Configure <> REC_VISUAL_OK then
      raise Exception.Create('Base catalog configuration failed');
    lSurface.Parent := AOwner;
    lSurface.Align := alClient;
    gMinCapacity := 10016;
    lSurface.Rebuild(lTags, 2, 1);
    if gReads <> 2 then raise Exception.Create('Both populated base pages must read');
    gCheckPointers := True;
    Inc(gRevision);
    lTags.RefreshInfo;
    lSurface.Refresh(lTags, 1);
    if gReads <> 4 then raise Exception.Create('Both base pages must refresh');
    lSurface.Refresh(lTags, 1);
    if gReads <> 4 then raise Exception.Create('Unchanged base data must stay cached');
    gCheckPointers := False;
    gMinCapacity := 20016;
    lSurface.Rebuild(lTags, 2, 2);
    if gReads <> 6 then raise Exception.Create('Same-count rebuild must refresh both pages');
    gCheckPointers := True;
    Inc(gRevision);
    lTags.RefreshInfo;
    lSurface.Refresh(lTags, 2);
    if gReads <> 8 then raise Exception.Create('Prepared resized history must refresh');
    WriteLn('RESULT OscBaseSurface populated two-tag preallocation passed');
  finally
    lSurface.Free;
    lTags.Free;
  end;
end;
var lModel: TOscModel; lTags: TOscTagRegistry; lUnits: TOscUnitCatalog;
  lView: TOscView; lOwner: TForm; lToolbar: TToolBar; I: Integer;
begin
  try
    Application.Initialize;
    Application.ShowMainForm := False;
    lModel := TOscModel.Create;
    lTags := TOscTagRegistry.Create(nil);
    lUnits := TOscUnitCatalog.Create;
    lOwner := TForm.CreateNew(nil);
    lView := TOscView.Create(lOwner);
    try
      lOwner.SetBounds(10,10,650,350);
      lView.Parent := lOwner;
      lView.Align := alClient;
      lView.UnitCatalog := lUnits;
      lView.Configure(lModel,lTags);
      if lView.GetChartControl = nil then
        raise Exception.Create('Plugin-owned chart was not created');
      lOwner.Show;
      Application.ProcessMessages;
      lToolbar := nil;
      for I := 0 to lView.ControlCount - 1 do
        if lView.Controls[I] is TToolBar then lToolbar := TToolBar(lView.Controls[I]);
      if (lToolbar = nil) or (lToolbar.Height > lToolbar.ButtonHeight + 2) then
        raise Exception.Create('Toolbar reserves extra height beyond buttons');
      if lView.GetChartControl.Top > lToolbar.Height + 2 then
        raise Exception.Create('Unbound oscillogram reserves a blank statistics row');
      WriteLn('RESULT OscView compact header passed height=',lToolbar.Height);
      lView.Visible := False;
      CheckBaseSurface(lOwner);
      WriteLn('RESULT OscViewSmoke passed');
    finally
      lOwner.Free;
      lUnits.Free;
      lTags.Free;
      lModel.Free;
    end;
  except
    on E: Exception do begin WriteLn('RESULT OscViewSmoke failed: ',E.Message); Halt(1); end;
  end;
end.
