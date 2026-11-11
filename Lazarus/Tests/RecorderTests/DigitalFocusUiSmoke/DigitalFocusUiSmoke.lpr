program DigitalFocusUiSmoke;

{ Real built-in digital frame and native grid, without loading a project,
  starting acquisition, attaching hardware or opening tag editors. }
{$mode objfpc}{$H+}
uses
  Interfaces, Forms, Classes, SysUtils, Controls, StdCtrls, Grids,
  uRecorder, uRecorderTags, uRecorderFormModel, uRecorderBuiltInFormsUI;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

function FirstTagRow(AGrid: TStringGrid; ATag: TRecorderTag): Integer;
var I: Integer;
begin
  for I := 1 to AGrid.RowCount - 1 do
    if AGrid.Objects[0, I] = ATag then Exit(I);
  Result := -1;
end;

procedure Run;
var
  lWindow: TForm;
  lGrid: TStringGrid;
  lOtherInput: TEdit;
  lFrame: TRecorderBuiltInFormsFrame;
  lRecorder: TRecorder;
  lForms: TRecorderFormManager;
  lFirst, lTarget, lOutside, lTag: TRecorderTag;
  lSettings: TRecorderTagEstimateSettings;
  I, lRow, lPreviousRow: Integer;
begin
  lRecorder := TRecorder.Create;
  lForms := TRecorderFormManager.Create;
  lWindow := TForm.CreateNew(nil);
  lOutside := nil;
  try
    lWindow.SetBounds(30, 30, 900, 400);
    lGrid := TStringGrid.Create(lWindow);
    lGrid.Parent := lWindow;
    lGrid.Align := alClient;
    lOtherInput := TEdit.Create(lWindow);
    lOtherInput.Parent := lWindow;
    lOtherInput.Align := alBottom;
    lFrame := TRecorderBuiltInFormsFrame.Create(lWindow);
    lFrame.Parent := lWindow;
    lFrame.Visible := False;
    lFrame.Configure(lRecorder, lForms, lGrid);
    lForms.AddPage(TRecorderFormPage.Create(CRecorderDigitalFormPageId, 'Digital', 'Digital'));
    lForms.AddPage(TRecorderFormPage.Create('other', 'Other', 'Other'));
    lFirst := nil;
    lTarget := nil;
    for I := 1 to 60 do
    begin
      lTag := lRecorder.Tags.CreateTag('tag-' + IntToStr(I), 32, True);
      if I = 1 then lFirst := lTag;
      if I = 60 then lTarget := lTag;
    end;
    lSettings := lTarget.EstimateSettings;
    lSettings.EnabledKinds[tekRmsValue] := True;
    lTarget.EstimateSettings := lSettings;
    lFrame.RenderDigital(True);
    lWindow.Show;
    Application.ProcessMessages;
    lOtherInput.SetFocus;
    lRow := FirstTagRow(lGrid, lTarget);
    Check(lRow > 1, 'Target fixture is not near bottom');
    Check(lFrame.FocusDigitalTag(lTarget), 'Target not selected');
    Check((lGrid.Row = lRow) and (lGrid.Col = 4), 'Wrong first estimate/value cell');
    Check(lWindow.ActiveControl = lGrid, 'Native input focus not transferred');
    Check(lGrid.TopRow <= lRow, 'Target above viewport');
    Check(lGrid.TopRow + lGrid.VisibleRowCount > lRow, 'Target below viewport');
    Check(lForms.ActivePage.Id = CRecorderDigitalFormPageId, 'Active page changed');

    { Identity wins over both stale position and misleading displayed text. }
    lGrid.Objects[0, 1] := lTarget;
    lGrid.Cells[0, 1] := 'not-the-target-caption';
    lGrid.Objects[0, lRow] := lFirst;
    Check(lFrame.FocusDigitalTag(lTarget) and (lGrid.Row = 1), 'Identity navigation failed after reorder');

    lOutside := TRecorderTag.Create(999999, 'not-in-grid', 32, True);
    lPreviousRow := lGrid.Row;
    Check(not lFrame.FocusDigitalTag(lOutside), 'Missing tag incorrectly selected');
    Check(lGrid.Row = lPreviousRow, 'Missing tag changed selection');
    Check(not lFrame.FocusDigitalTag(nil), 'Nil tag accepted');

    lForms.SetActivePageById('other');
    Check(not lFrame.FocusDigitalTag(lTarget), 'Inactive digital form accepted navigation');
    Check(lForms.ActivePage.Id = 'other', 'Navigation changed active page');
    Check(lGrid.Row = lPreviousRow, 'Inactive page changed selection');

    lForms.SetActivePageById(CRecorderDigitalFormPageId);
    lFrame.SetDigitalViewMode(rdvmMessages);
    lFrame.RenderDigital(True);
    Check(lFrame.FocusDigitalTag(lTarget), 'Messages-to-tags navigation failed');
    Check(lFrame.ViewMode = rdvmTags, 'Messages mode not changed to tags');
    Check(lGrid.Row = FirstTagRow(lGrid, lTarget), 'Messages-to-tags selected wrong identity');
    Check(lWindow.ActiveControl = lGrid, 'Messages-to-tags lost focus');
    Writeln('RESULT DigitalFocusUiSmoke identity/reorder/multi-estimate/viewport/focus/inactive/missing/messages passed');
  finally
    lOutside.Free;
    lWindow.Free;
    lForms.Free;
    lRecorder.Free;
  end;
end;

begin
  Application.Initialize;
  try
    Run;
  except
    on E: Exception do
    begin
      Writeln('RESULT DigitalFocusUiSmoke failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
