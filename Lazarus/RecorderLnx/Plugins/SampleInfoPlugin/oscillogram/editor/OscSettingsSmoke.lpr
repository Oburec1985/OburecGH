program OscSettingsSmoke;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Controls, ExtCtrls, SysUtils, uOscSettings, uOscModel,
  uOscDataAdapter, uRecorderVisualComponentApiV2{$IFDEF WINDOWS}, Windows{$ENDIF};
type
  TModalProbe = class
    Owner: TForm;
    Accept: Boolean;
    ErrorText: string;
    StartedAt: QWord;
    procedure Tick(Sender: TObject);
  end;
var lForm: TOscSettings; lModel: TOscModel; lCatalog: TOscTagCatalog;
  lSaved: UTF8String;
  lOwner: TForm; lTimer: TTimer; lProbe: TModalProbe; lAccepted: Boolean;

procedure TModalProbe.Tick(Sender: TObject);
var I: Integer; lDialog: TOscSettings;
  {$IFDEF WINDOWS} lOwnerRect, lDialogRect: Windows.TRect; {$ENDIF}
begin
  for I := 0 to Screen.FormCount - 1 do
    if (Screen.Forms[I] is TOscSettings) and Screen.Forms[I].Visible then
    begin
      TTimer(Sender).Enabled := False;
      lDialog := TOscSettings(Screen.Forms[I]);
      {$IFDEF WINDOWS}
      if Windows.GetWindow(lDialog.Handle, GW_OWNER) <> Owner.Handle then
        ErrorText := 'Native modal owner mismatch';
      if Windows.IsWindowEnabled(Owner.Handle) then
        ErrorText := 'Native owner was not disabled';
      Windows.GetWindowRect(Owner.Handle, lOwnerRect);
      Windows.GetWindowRect(lDialog.Handle, lDialogRect);
      if (Abs((lOwnerRect.Left+lOwnerRect.Right)-
        (lDialogRect.Left+lDialogRect.Right)) > 2) or
        (Abs((lOwnerRect.Top+lOwnerRect.Bottom)-
        (lDialogRect.Top+lDialogRect.Bottom)) > 2) then
        ErrorText := Format('Modal editor was not centered: owner %d %d %d %d dialog %d %d %d %d',
          [lOwnerRect.Left,lOwnerRect.Top,lOwnerRect.Right,lOwnerRect.Bottom,
           lDialogRect.Left,lDialogRect.Top,lDialogRect.Right,lDialogRect.Bottom]);
      {$ENDIF}
      if Accept then lDialog.btOK.OnClick(lDialog.btOK)
      else lDialog.ModalResult := mrCancel;
      Exit;
    end;
  if GetTickCount64 - StartedAt > 3000 then
  begin
    TTimer(Sender).Enabled := False;
    ErrorText := 'Modal dialog did not become visible within 3 seconds';
    Application.Terminate;
  end;
end;
procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;
procedure SelectCandidate(AIndex: Integer);
begin
  lForm.cbTag.ItemIndex := AIndex;
  lForm.cbTag.OnChange(lForm.cbTag);
end;
begin
  try
    Application.Initialize;
    lModel := TOscModel.Create; lForm := nil;
    try
      SetLength(lCatalog, 3);
      lCatalog[0].Id := 1; lCatalog[0].Name := 'Channel1';
      lCatalog[1].Id := 2; lCatalog[1].Name := 'Channel2';
      lCatalog[2].Id := 3; lCatalog[2].Name := 'Channel3';
      lForm := TOscSettings.Create(nil); lForm.Initialize(lModel, lCatalog);
      SelectCandidate(0); lForm.btAdd.OnClick(lForm.btAdd);
      SelectCandidate(1);
      Check(Pos('Channel1', lForm.lbLines.Items[0]) > 0,
        'Candidate selection overwrote existing line');
      lForm.btAdd.OnClick(lForm.btAdd);
      Check(lForm.lbLines.Count = 2, 'Second channel was not added');
      Check(Pos('Channel1', lForm.lbLines.Items[0]) > 0, 'Primary channel lost');
      Check(Pos('Channel2', lForm.lbLines.Items[1]) > 0, 'Additional channel lost');
      SelectCandidate(2); lForm.btApply.OnClick(lForm.btApply);
      Check(Pos('Channel3', lForm.lbLines.Items[1]) > 0, 'Explicit Apply failed');
      lForm.NewAxisClick(nil);
      if lModel.TagName <> '' then raise Exception.Create('Draft mutated original');
      lForm.OkClick(nil);
      if (lForm.ModalResult <> mrOk) or (lModel.TagName <> 'Channel1') or
        (lModel.LineCount <> 1) or (lModel.Lines[0].TagName <> 'Channel3') or
        (lModel.Lines[0].AxisIndex <> 1) then
        raise Exception.Create('Line/axis transaction failed');
      FreeAndNil(lForm);
      lSaved := lModel.SaveUtf8;
      lForm := TOscSettings.Create(nil); lForm.Initialize(lModel, lCatalog);
      SelectCandidate(1); lForm.btApply.OnClick(lForm.btApply);
      lForm.ModalResult := lForm.btCancel.ModalResult;
      Check(lForm.ModalResult = mrCancel, 'Cancel button is not wired');
      FreeAndNil(lForm);
      Check(lModel.SaveUtf8 = lSaved, 'Cancel mutated original');
      {$IFDEF WINDOWS}
      lOwner := TForm.CreateNew(nil); lProbe := TModalProbe.Create;
      lTimer := TTimer.Create(nil);
      try
        lOwner.SetBounds(100, 80, 1000, 800); lOwner.Show;
        Application.ProcessMessages; Windows.SetFocus(lOwner.Handle);
        lProbe.Owner := lOwner; lTimer.Enabled := False;
        lTimer.Interval := 50; lTimer.OnTimer := @lProbe.Tick;
        lProbe.Accept := True; lProbe.StartedAt := GetTickCount64; lTimer.Enabled := True;
        lAccepted := ShowOscSettings(nil, lModel, lCatalog,
          lOwner.Handle, REC_VISUAL_NATIVE_WIN32, 96);
        Check(lAccepted, 'Native modal OK failed');
        Check(lProbe.ErrorText = '', lProbe.ErrorText);
        Check(Windows.IsWindowEnabled(lOwner.Handle), 'Owner remained disabled after OK');
        Check(Windows.GetFocus = lOwner.Handle, 'Owner focus not restored after OK');
        lProbe.Accept := False; lProbe.StartedAt := GetTickCount64; lTimer.Enabled := True;
        lAccepted := ShowOscSettings(nil, lModel, lCatalog,
          lOwner.Handle, REC_VISUAL_NATIVE_WIN32, 96);
        Check(not lAccepted, 'Native modal Cancel failed');
        Check(lProbe.ErrorText = '', lProbe.ErrorText);
        Check(Windows.IsWindowEnabled(lOwner.Handle), 'Owner remained disabled after Cancel');
        Check(Windows.GetFocus = lOwner.Handle, 'Owner focus not restored after Cancel');
      finally lTimer.Free; lProbe.Free; lOwner.Free; end;
      {$ENDIF}
      WriteLn('RESULT OscSettingsSmoke candidate/add/apply/OK/cancel/native-owner/focus passed');
    finally lForm.Free; lModel.Free; end;
  except on E: Exception do begin WriteLn(E.Message); Halt(1); end; end;
end.
