program TagDisplayOrderUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, Forms, Controls, Classes, SysUtils, Types, Grids, ComCtrls,
  fpjson, jsonparser, uRecorder, uRecorderTags, uRecorderProjectFiles,
  uRecorderSettingsDialog, uRecorderFormModel, uRecorderBuiltInFormsUI;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure CheckOrder(ARegistry: TRecorderTagRegistry; const ANames: array of string);
var
  lTags: TList;
  I: Integer;
begin
  lTags := TList.Create;
  try
    ARegistry.GetDisplayTags(lTags);
    Check(lTags.Count = Length(ANames), 'Wrong display count');
    for I := 0 to High(ANames) do
      Check(TRecorderTag(lTags[I]).Name = ANames[I],
        Format('Order at %d: got %s expected %s', [I,
          TRecorderTag(lTags[I]).Name, ANames[I]]));
  finally
    lTags.Free;
  end;
end;

procedure CreateFixture(ARegistry: TRecorderTagRegistry);
const
  Names: array[0..2] of string = ('Zulu', 'Alpha', 'Mike');
  Addresses: array[0..2] of string = ('10-10', '2-10', '2-2');
  Keys: array[0..2] of string = ('z', 'a', 'm');
  Rates: array[0..2] of Double = (30, 10, 20);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  ARegistry.Clear;
  for I := 0 to 2 do
  begin
    lTag := ARegistry.AddTag(TRecorderTag.Create(100 + I, Names[I], 32, True));
    lTag.Address := Addresses[I];
    lTag.ModuleType := Keys[I];
    lTag.SourceId := Keys[I];
    lTag.GroupPath := Keys[I];
    lTag.Description := Keys[I];
    lTag.UnitName := 'unit-' + Keys[I];
    lTag.PollFrequencyHz := Rates[I];
  end;
end;

procedure CheckRuntimeIdentity(ARegistry: TRecorderTagRegistry;
  AFirst, ASecond, AThird: TRecorderTag);
begin
  Check((ARegistry.Tags[0] = AFirst) and (ARegistry.Tags[1] = ASecond) and
    (ARegistry.Tags[2] = AThird), 'Presentation sort reordered runtime storage');
  Check((ARegistry.FindById(AFirst.Id) = AFirst) and
    (ARegistry.FindById(ASecond.Id) = ASecond) and
    (ARegistry.FindByName(AThird.Name) = AThird), 'Tag identity lookup changed');
end;

procedure TestModel(ARegistry: TRecorderTagRegistry);
var
  lField: TRecorderTagSortField;
  lFirst, lSecond, lThird: TRecorderTag;
begin
  CreateFixture(ARegistry);
  lFirst := ARegistry.Tags[0]; lSecond := ARegistry.Tags[1]; lThird := ARegistry.Tags[2];
  Check((ARegistry.DisplaySortField = rtsAddress) and
    ARegistry.DisplaySortAscending, 'Default is not address ascending');
  for lField := rtsName to rtsId do
  begin
    ARegistry.SetDisplaySort(lField, True);
    case lField of
      rtsAddress, rtsCalibration: CheckOrder(ARegistry, ['Mike', 'Alpha', 'Zulu']);
      rtsId: CheckOrder(ARegistry, ['Zulu', 'Alpha', 'Mike']);
    else CheckOrder(ARegistry, ['Alpha', 'Mike', 'Zulu']);
    end;
    ARegistry.SetDisplaySort(lField, False);
    case lField of
      rtsAddress, rtsCalibration: CheckOrder(ARegistry, ['Zulu', 'Alpha', 'Mike']);
      rtsId: CheckOrder(ARegistry, ['Mike', 'Alpha', 'Zulu']);
    else CheckOrder(ARegistry, ['Zulu', 'Mike', 'Alpha']);
    end;
    CheckRuntimeIdentity(ARegistry, lFirst, lSecond, lThird);
  end;
  ARegistry.SetDisplaySort(rtsNone, True);
  CheckOrder(ARegistry, ['Zulu', 'Alpha', 'Mike']);
  Writeln('RESULT all fields ascending/descending, numeric address and runtime identity passed');
end;

procedure TestPersistence(ARegistry: TRecorderTagRegistry);
var
  lReloaded: TRecorderTagRegistry;
  lFileName: string;
  lText: TStringList;
  lJson: TJSONObject;
begin
  lFileName := ExpandFileName('lib/order-config.json');
  lReloaded := TRecorderTagRegistry.Create;
  lText := TStringList.Create;
  try
    ARegistry.SetDisplaySort(rtsGroup, False);
    SaveRecorderProjectConfig(lFileName, ARegistry);
    LoadRecorderProjectConfig(lFileName, lReloaded);
    Check((lReloaded.DisplaySortField = rtsGroup) and
      not lReloaded.DisplaySortAscending, 'Sort preferences lost in JSON roundtrip');
    CheckOrder(lReloaded, ['Zulu', 'Mike', 'Alpha']);
    Check((lReloaded.Tags[0].Name = 'Zulu') and
      (lReloaded.Tags[1].Name = 'Alpha'), 'JSON changed acquisition order');
    lText.LoadFromFile(lFileName);
    lJson := TJSONObject(GetJSON(lText.Text));
    try
      lJson.Delete('tagSortField'); lJson.Delete('tagSortAscending');
      lText.Text := lJson.FormatJSON;
      lText.SaveToFile(lFileName);
      LoadRecorderProjectConfig(lFileName, lReloaded);
      Check((lReloaded.DisplaySortField = rtsAddress) and
        lReloaded.DisplaySortAscending, 'Legacy defaults inherit previous project sorting');
      CheckOrder(lReloaded, ['Mike', 'Alpha', 'Zulu']);
      lJson.Add('tagSortField', 999);
      lText.Text := lJson.FormatJSON;
      lText.SaveToFile(lFileName);
      LoadRecorderProjectConfig(lFileName, lReloaded);
      Check(lReloaded.DisplaySortField = rtsAddress, 'Invalid sort field was not defaulted');
    finally
      lJson.Free;
    end;
  finally
    lText.Free;
    lReloaded.Free;
    DeleteFile(lFileName);
  end;
  Writeln('RESULT JSON preference roundtrip, legacy and invalid defaults passed');
end;

procedure ClickHeader(ADialog: TRecorderSettingsDialog; AColumn: Integer);
var
  lRect: TRect;
  lGrid: TStringGrid;
begin
  lGrid := ADialog.fSelectedChannelsGrid;
  lGrid.LeftCol := AColumn;
  lRect := lGrid.CellRect(AColumn, 0);
  ADialog.fSelectedChannelsGridMouseDown(lGrid, mbLeft, [],
    (lRect.Left + lRect.Right) div 2, (lRect.Top + lRect.Bottom) div 2);
end;

procedure CheckHeaderResizeBoundary(ADialog: TRecorderSettingsDialog; AColumn: Integer);
var
  lRect: TRect;
  lGrid: TStringGrid;
  lField: TRecorderTagSortField;
  lAscending: Boolean;
begin
  lField := ADialog.Recorder.Tags.DisplaySortField;
  lAscending := ADialog.Recorder.Tags.DisplaySortAscending;
  lGrid := ADialog.fSelectedChannelsGrid;
  lGrid.LeftCol := AColumn;
  lRect := lGrid.CellRect(AColumn, 0);
  ADialog.fSelectedChannelsGridMouseDown(lGrid, mbLeft, [],
    lRect.Right - 1, (lRect.Top + lRect.Bottom) div 2);
  Check((ADialog.Recorder.Tags.DisplaySortField = lField) and
    (ADialog.Recorder.Tags.DisplaySortAscending = lAscending),
    'Scrolled header resize boundary changed sorting');
end;

procedure CheckSettingsRows(ADialog: TRecorderSettingsDialog;
  const ANames: array of string);
var
  I: Integer;
begin
  Check(ADialog.fSelectedChannelsGrid.RowCount = Length(ANames) + 1,
    'Wrong settings filtered row count');
  for I := 0 to High(ANames) do
    Check(ADialog.fSelectedChannelsGrid.Cells[1, I + 1] = ANames[I],
      'Settings order differs from shared order at row ' + IntToStr(I));
end;

procedure TestSettings(ARecorder: TRecorder);
var
  lDialog: TRecorderSettingsDialog;
  lParent: TWinControl;
begin
  ARecorder.Tags.SetDisplaySort(rtsAddress, True);
  lDialog := TRecorderSettingsDialog.Create(nil);
  try
    lDialog.Recorder := ARecorder;
    lParent := lDialog.fSelectedChannelsGrid.Parent;
    while lParent <> nil do
    begin
      if lParent is TTabSheet then
        TTabSheet(lParent).PageControl.ActivePage := TTabSheet(lParent);
      lParent := lParent.Parent;
    end;
    lDialog.Show;
    Application.ProcessMessages;
    CheckSettingsRows(lDialog, ['Mike', 'Alpha', 'Zulu']);
    ClickHeader(lDialog, 1);
    Check(ARecorder.Tags.DisplaySortField = rtsName, 'Name header did not set shared sort');
    CheckSettingsRows(lDialog, ['Alpha', 'Mike', 'Zulu']);
    lDialog.edSelectedChannelsFilter.Text := 'Alpha';
    CheckSettingsRows(lDialog, ['Alpha']);
    ClickHeader(lDialog, 2);
    CheckOrder(ARecorder.Tags, ['Mike', 'Alpha', 'Zulu']);
    lDialog.edSelectedChannelsFilter.Clear;
    CheckSettingsRows(lDialog, ['Mike', 'Alpha', 'Zulu']);
    ClickHeader(lDialog, 2);
    CheckSettingsRows(lDialog, ['Zulu', 'Alpha', 'Mike']);
    Check(not ARecorder.Tags.DisplaySortAscending, 'Address header did not toggle shared sort');
    ClickHeader(lDialog, 7);
    Check((ARecorder.Tags.DisplaySortField = rtsGroup) and
      ARecorder.Tags.DisplaySortAscending, 'Group header is not linked to visible group column');
    CheckSettingsRows(lDialog, ['Alpha', 'Mike', 'Zulu']);
    CheckHeaderResizeBoundary(lDialog, 7);
    CheckHeaderResizeBoundary(lDialog, 8);
    { Empty groups use the same visible caption for sorting and drawing. }
    ARecorder.Tags.FindByName('Zulu').GroupPath := '';
    ARecorder.Tags.FindByName('Alpha').GroupPath := 'Аварийные';
    ARecorder.Tags.FindByName('Mike').GroupPath := 'Alpha';
    ClickHeader(lDialog, 7);
    CheckOrder(ARecorder.Tags, ['Zulu', 'Alpha', 'Mike']);
    CheckSettingsRows(lDialog, ['Zulu', 'Alpha', 'Mike']);
    Check(lDialog.fSelectedChannelsGrid.Cells[7, 1] = CRecorderDefaultTagGroupPath,
      'Empty group visible caption differs from shared default');
    ClickHeader(lDialog, 7);
    CheckOrder(ARecorder.Tags, ['Mike', 'Alpha', 'Zulu']);
    CheckSettingsRows(lDialog, ['Mike', 'Alpha', 'Zulu']);
    Check(lDialog.fSelectedChannelsGrid.Cells[7, 3] = CRecorderDefaultTagGroupPath,
      'Ascending mixed groups did not use visible default caption');
    ARecorder.Tags.FindByName('Zulu').GroupPath := '   ';
    ClickHeader(lDialog, 7);
    CheckOrder(ARecorder.Tags, ['Zulu', 'Alpha', 'Mike']);
    CheckSettingsRows(lDialog, ['Zulu', 'Alpha', 'Mike']);
    Check(lDialog.fSelectedChannelsGrid.Cells[7, 1] = CRecorderDefaultTagGroupPath,
      'Whitespace group was not normalized to visible default');
  finally
    lDialog.Free;
  end;
  Writeln('RESULT native settings headers, filtered global sort and mixed default/Russian/Latin groups passed');
end;

procedure TestDigital(ARecorder: TRecorder);
var
  lWindow: TForm;
  lGrid: TStringGrid;
  lFrame: TRecorderBuiltInFormsFrame;
  lForms: TRecorderFormManager;
  lTags: TList;
  lSettings: TRecorderTagEstimateSettings;
  lTarget, lPrevious: TRecorderTag;
  I, lIndex, lSelectedEstimateRow: Integer;
begin
  lWindow := TForm.CreateNew(nil);
  lForms := TRecorderFormManager.Create;
  lTags := TList.Create;
  try
    lGrid := TStringGrid.Create(lWindow);
    lGrid.Parent := lWindow;
    lGrid.Align := alClient;
    lWindow.SetBounds(20, 20, 900, 400);
    lFrame := TRecorderBuiltInFormsFrame.Create(lWindow);
    lFrame.Parent := lWindow;
    lFrame.Visible := False;
    lFrame.Configure(ARecorder, lForms, lGrid);
    lForms.AddPage(TRecorderFormPage.Create(CRecorderDigitalFormPageId, 'Digital', 'Digital'));
    lTarget := ARecorder.Tags.FindByName('Alpha');
    lSettings := lTarget.EstimateSettings;
    lSettings.EnabledKinds[tekRmsValue] := True;
    lTarget.EstimateSettings := lSettings;
    ARecorder.Tags.SetDisplaySort(rtsAddress, True);
    lFrame.RenderDigital(True);
    lWindow.Show;
    Application.ProcessMessages;
    Check(lFrame.FocusDigitalTag(lTarget), 'Initial tag focus failed');
    Check(lGrid.Objects[0, lGrid.Row] = lTarget, 'Focus selected wrong tag identity');
    ARecorder.Tags.GetDisplayTags(lTags);
    lPrevious := nil; lIndex := 0;
    for I := 1 to lGrid.RowCount - 1 do
    begin
      if lGrid.Objects[0, I] = lPrevious then Continue;
      Check((lIndex < lTags.Count) and (lGrid.Objects[0, I] = TObject(lTags[lIndex])),
        'Digital rows differ from shared tag order');
      lPrevious := TRecorderTag(lGrid.Objects[0, I]);
      Inc(lIndex);
    end;
    Check(lIndex = lTags.Count, 'Digital lost a tag');
    lSelectedEstimateRow := -1;
    for I := 1 to lGrid.RowCount - 1 do
      if (lGrid.Objects[0, I] = lTarget) and
        (PtrInt(lGrid.Objects[1, I]) = Ord(tekRmsValue) + 1) then
        lSelectedEstimateRow := I;
    Check(lSelectedEstimateRow > 1, 'RMS selection fixture has no movable row');
    lGrid.Col := 3;
    lGrid.Row := lSelectedEstimateRow;
    ARecorder.Tags.SetDisplaySort(rtsName, True);
    lFrame.RenderDigital(True);
    Check((lGrid.Row <> lSelectedEstimateRow) and
      (lGrid.Objects[0, lGrid.Row] = lTarget) and
      (PtrInt(lGrid.Objects[1, lGrid.Row]) = Ord(tekRmsValue) + 1) and
      (lGrid.Col = 3), 'Automatic selection lost tag/estimate/column across sort');
    lSettings.EnabledKinds[tekRmsValue] := False;
    lTarget.EstimateSettings := lSettings;
    lFrame.RenderDigital(True);
    Check((lGrid.Row = 1) and (lGrid.Objects[0, lGrid.Row] = lTarget) and
      (PtrInt(lGrid.Objects[1, lGrid.Row]) = Ord(tekMean) + 1) and
      (lGrid.Col = 3), 'Removed estimate did not fall back to the same tag first row');
    ARecorder.Tags.RemoveTag(lTarget);
    lFrame.RenderDigital(True);
    Check((lGrid.Row > 0) and (lGrid.Row < lGrid.RowCount) and
      (lGrid.Objects[0, lGrid.Row] <> lTarget) and
      ARecorder.Tags.ContainsTag(TRecorderTag(lGrid.Objects[0, lGrid.Row])),
      'Deleted selected tag left invalid digital selection');
    ARecorder.Tags.Clear;
    lFrame.RenderDigital(True);
    Check((lGrid.RowCount = 2) and (lGrid.Objects[0, 1] = nil) and
      (lGrid.Objects[1, 1] = nil) and (lGrid.Cells[0, 1] = ''),
      'Empty digital view retained a deleted tag or estimate pointer');
  finally
    lTags.Free;
    lWindow.Free;
    lForms.Free;
  end;
  Writeln('RESULT digital shared order, automatic tag/estimate/column selection, removed estimate/tag passed');
end;

var
  lRecorder: TRecorder;
begin
  Application.Initialize;
  try
    lRecorder := TRecorder.Create;
    try
      TestModel(lRecorder.Tags);
      TestPersistence(lRecorder.Tags);
      TestSettings(lRecorder);
      TestDigital(lRecorder);
    finally
      lRecorder.Free;
    end;
    Writeln('RESULT TagDisplayOrderUiSmoke passed');
  except
    on E: Exception do
    begin
      Writeln('RESULT TagDisplayOrderUiSmoke failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
