program BaseFormSmoke;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Controls, SysUtils, uOscBaseForm, uOscTags, uOscUnits,
  uRecorderVisualComponentApiV2;
type
  TCountProbe = class
    Calls: Integer;
    procedure Changed(Sender: TObject);
  end;
var gReads: Integer; gRevision: QWord = 1;
procedure TCountProbe.Changed(Sender: TObject);
begin Inc(Calls); end;
function EnumTags(AContext: Pointer; AIndex: LongWord;
  AInfo: PRecorderVisualTagInfoV2): LongInt; cdecl;
begin
  if AIndex > 1 then Exit(REC_VISUAL_END_OF_ENUMERATION);
  AInfo^.TagId := AIndex + 1;
  AInfo^.Flags := REC_VISUAL_TAG_FLAG_SOURCE_VISIBLE;
  AInfo^.PollFrequencyHz := 100;
  AInfo^.RangeMin := -10; AInfo^.RangeMax := 10;
  StrPLCopy(@AInfo^.Name[0], 'Wave' + IntToStr(AIndex + 1), High(AInfo^.Name));
  Result := REC_VISUAL_OK;
end;
function SignalInfo(AContext: Pointer; ATagId: QWord;
  AInfo: PRecorderVisualSignalInfoV2): LongInt; cdecl;
begin
  AInfo^.Count := 10; AInfo^.Revision := gRevision;
  AInfo^.BlockCounter := gRevision; AInfo^.LatestTimeSec := 0.9;
  Result := REC_VISUAL_OK;
end;
function Selection(AContext: Pointer; out ATagId: QWord): LongInt; cdecl;
begin ATagId := 1; Result := REC_VISUAL_OK; end;
function History(AContext: Pointer; ATagId: QWord; AWindowSeconds: Double;
  ATimes, AValues: PDouble; ACapacity: LongWord; out ACount: LongWord;
  out ARevision: QWord; out AStart, ALatest: Double): LongInt; cdecl;
var I: Integer;
begin
  ACount := 10; ARevision := gRevision; AStart := 0; ALatest := 0.9;
  if ACapacity < ACount then Exit(REC_VISUAL_BUFFER_TOO_SMALL);
  for I := 0 to 9 do begin ATimes[I] := I/10; AValues[I] := ATagId*Sin(I); end;
  Inc(gReads); Result := REC_VISUAL_OK;
end;
procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;
var lServices: TRecorderVisualHostServicesV2; lTags: TOscTagRegistry;
  lUnits: TOscUnitCatalog; lForm: TOscBaseForm; lOwner: TForm;
  lProbe: TCountProbe; lBefore: Integer;
begin
  try
    Application.Initialize; Application.ShowMainForm := False;
    lServices := Default(TRecorderVisualHostServicesV2);
    lServices.Header.Size := SizeOf(lServices);
    lServices.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    lServices.EnumerateTags := @EnumTags;
    lServices.GetSignalInfo := @SignalInfo;
    lServices.GetSelectedTagId := @Selection;
    lServices.CopyLatestHistory := @History;
    lTags := TOscTagRegistry.Create(@lServices);
    lUnits := TOscUnitCatalog.Create; lOwner := TForm.CreateNew(nil);
    lForm := TOscBaseForm.Create(nil); lProbe := TCountProbe.Create;
    try
      Check(lTags.Configure = REC_VISUAL_OK, 'Catalog loading failed');
      Check((lForm.Count = 2) and Assigned(lForm.CountEdit.OnChange) and
        Assigned(lForm.OnResize), 'LFM defaults/event bindings failed');
      lOwner.SetBounds(20,20,800,600); lOwner.Show;
      lForm.ParentWindow := lOwner.Handle; lForm.SetBounds(0,0,800,600);
      lForm.OnCountChanged := @lProbe.Changed;
      lForm.Configure(lTags,lUnits,2,1);
      Check((lForm.Surface.Count = 2) and (gReads = 2), 'Two populated pages failed');
      Check(lProbe.Calls = 0, 'Configure emitted user-change event');
      lForm.Show; Application.ProcessMessages;
      lForm.CountEdit.Value := 3;
      Check((lForm.Count = 3) and (lForm.Surface.Count = 3) and
        (lProbe.Calls = 1), 'User Count change failed');
      lForm.SetBounds(0,0,400,300); Application.ProcessMessages;
      Check((lForm.Surface.Align = alClient) and (lForm.TopPan.Align = alTop)
        and (lForm.Surface.Width = lForm.ClientWidth) and
        (lForm.Surface.Height = lForm.ClientHeight-lForm.TopPan.Height), 'Dock resize failed');
      lForm.SetBounds(0,0,1000,700); Application.ProcessMessages;
      Check(lForm.Surface.Width = lForm.ClientWidth, 'Expanded dock resize failed');
      lBefore := gReads; Inc(gRevision); lTags.RefreshInfo; lForm.Refresh(True);
      Check(gReads > lBefore, 'Running data refresh did not update populated pages');
      Check(Pos('FPS',lForm.FpsLabel.Caption) > 0, 'FPS label was not refreshed');
      lForm.CountEdit.Value := 1;
      Check((lForm.Surface.Count = 1) and (lProbe.Calls = 2), 'Count decrease failed');
      WriteLn('RESULT BaseFormSmoke resource/two-tags/count/resize/refresh/FPS passed');
    finally lForm.Free; lProbe.Free; lOwner.Free; lUnits.Free; lTags.Free; end;
  except on E: Exception do begin WriteLn('RESULT BaseFormSmoke failed: ',E.Message); Halt(1); end; end;
end.
