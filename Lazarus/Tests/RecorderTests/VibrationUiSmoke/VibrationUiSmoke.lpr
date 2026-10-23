program VibrationUiSmoke;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Buttons,
  uRecorderVibrationEstimateSettingsDialog, uRecorderVibrationEstimate,
  uRecorderFormModel, uRecorderTags, uRecorderVisualControl;
type
  TProbe = class
    WantVibration, Commit, Opened: Boolean;
    ErrorText: string;
    InvalidStage: Integer;
    procedure Tick(Sender: TObject);
  end;
procedure TProbe.Tick(Sender: TObject);
var I: Integer; lForm: TRecorderVibrationEstimateSettingsForm;
begin
  if Commit and (InvalidStage = 1) then
  begin
    if (Screen.ActiveForm <> nil) and
      not (Screen.ActiveForm is TRecorderVibrationEstimateSettingsForm) then
    begin
      Screen.ActiveForm.ModalResult := mrOk;
      InvalidStage := 2;
    end;
    Exit;
  end;
  for I := 0 to Screen.FormCount - 1 do
  begin
    if not (Screen.Forms[I] is TRecorderVibrationEstimateSettingsForm) then Continue;
    TTimer(Sender).Enabled := False;
    Opened := True;
    lForm := TRecorderVibrationEstimateSettingsForm(Screen.Forms[I]);
    if WantVibration then
    begin
      if lForm.QuantityCombo.Items.Count <> 4 then ErrorText := 'Vibration choices';
    end
    else
    begin
      if lForm.QuantityCombo.Items.Count <> 2 then ErrorText := 'Generic choices';
      if lForm.QuantityCombo.Text <> RecorderVibrationQuantityCaption(rvqAmplitude) then
        ErrorText := 'Generic amplitude default';
    end;
    lForm.HoldMaximumCheck.Checked := True;
    if Commit then
    begin
      lForm.BandCombo.ItemIndex := 1;
      lForm.BandChange(nil);
      if not lForm.FromEdit.Enabled or not lForm.ToEdit.Enabled then
        ErrorText := 'Manual fields disabled';
      lForm.FromEdit.Text := '20'; lForm.ToEdit.Text := '300';
      if InvalidStage = 0 then
      begin
        lForm.FromEdit.Text := '300'; lForm.ToEdit.Text := '20';
        InvalidStage := 1;
        TTimer(Sender).Enabled := True;
        lForm.ModalResult := mrOk;
        Exit;
      end;
    end
    else if WantVibration then
    begin
      if (lForm.BandCombo.ItemIndex <> 1) or (lForm.FromEdit.Text <> '20') or
        (lForm.ToEdit.Text <> '300') then ErrorText := 'Manual range not restored';
      lForm.BandCombo.ItemIndex := 0; lForm.BandChange(nil);
      if lForm.FromEdit.Enabled or lForm.ToEdit.Enabled then
        ErrorText := 'Full-band fields enabled';
    end;
    lForm.SetBounds(0, 0, 560, 430);
    lForm.SetBounds(0, 0, 720, 520);
    if Commit then lForm.ModalResult := mrOk else lForm.ModalResult := mrCancel;
    Exit;
  end;
end;
procedure CheckGenericView(AModel: TRecorderVibrationEstimateComponent;
  ATags: TRecorderTagRegistry; ATag: TRecorderTag);
var
  lForm: TForm;
  lView: TRecorderVibrationEstimateView;
  lQuantity, lUnit: TSpeedButton;
  I: Integer;
begin
  ATag.UnitName := 'V';
  AModel.Quantity := rvqAcceleration;
  AModel.OutputUnit := 'g';
  lForm := TForm.CreateNew(nil);
  try
    lView := TRecorderVibrationEstimateView.Create(lForm);
    lView.Parent := lForm;
    lView.SetBounds(0, 0, 300, 120);
    lView.Configure(AModel, ATags);
    lQuantity := nil;
    lUnit := nil;
    for I := 0 to lView.ControlCount - 1 do
      if lView.Controls[I] is TSpeedButton then
        with TSpeedButton(lView.Controls[I]) do
        begin
          if Pos('тип', Hint) > 0 then lQuantity := TSpeedButton(lView.Controls[I]);
          if Pos('единицу', Hint) > 0 then lUnit := TSpeedButton(lView.Controls[I]);
        end;
    if (lQuantity = nil) or (lUnit = nil) then
      raise Exception.Create('View selectors absent');
    if lUnit.Enabled or (lUnit.Caption <> 'V') then
      raise Exception.Create('Generic legacy unit switch enabled/stale');
    for I := 0 to 3 do
    begin
      lQuantity.Click;
      if (I mod 2 = 0) and (AModel.Quantity <> rvqDominantFrequency) then
        raise Exception.Create('Generic frequency toggle');
      if (I mod 2 = 1) and (AModel.Quantity <> rvqAmplitude) then
        raise Exception.Create('Generic amplitude toggle');
      if lUnit.Enabled then raise Exception.Create('Generic units unlocked');
      if (I mod 2 = 0) and (lUnit.Caption <> 'Hz') then
        raise Exception.Create('Generic frequency unit');
      if (I mod 2 = 1) and (lUnit.Caption <> 'V') then
        raise Exception.Create('Generic amplitude unit');
    end;
  finally
    lForm.Free;
  end;
end;
var lTags: TRecorderTagRegistry; lModel: TRecorderVibrationEstimateComponent;
  lTag: TRecorderTag; lProbe: TProbe; lTimer: TTimer; I: Integer; lResult: Boolean;
begin
  try
    Application.Initialize;
    Application.ShowMainForm := False;
    lTags := TRecorderTagRegistry.Create;
    lModel := TRecorderVibrationEstimateComponent.Create;
    lProbe := TProbe.Create;
    lTimer := TTimer.Create(nil);
    try
      lTag := lTags.AddTag(TRecorderTag.Create(1, 'source'));
      lTag.PollFrequencyHz := 1000;
      lModel.TagId := lTag.Id;
      lModel.TagName := lTag.Name;
      lTimer.Interval := 30;
      lTimer.OnTimer := @lProbe.Tick;
      for I := 0 to 2 do
      begin
        if I = 2 then lTag.UnitName := 'm/s2' else lTag.UnitName := 'V';
        lProbe.WantVibration := I = 2;
        lProbe.Commit := I = 1;
        lProbe.Opened := False;
        lProbe.InvalidStage := 0;
        lProbe.ErrorText := '';
        lTimer.Enabled := True;
        lResult := ShowRecorderVibrationEstimateSettingsDialog(nil, lModel, lTags);
        if lResult <> lProbe.Commit then raise Exception.Create('Modal result');
        if not lProbe.Opened then raise Exception.Create('Dialog not opened');
        if lProbe.ErrorText <> '' then raise Exception.Create(lProbe.ErrorText);
        if (I = 0) and lModel.HoldMaximum then raise Exception.Create('Cancel committed');
        if (I = 1) and not lModel.HoldMaximum then raise Exception.Create('Hold not saved');
        if (I = 1) and (not lModel.ManualBand or (lModel.BandFromHz <> 20) or
          (lModel.BandToHz <> 300)) then raise Exception.Create('Manual bounds not saved');
        if (I = 1) and (lProbe.InvalidStage <> 2) then
          raise Exception.Create('Reversed manual bounds did not show validation');
        if (I = 1) and (lModel.OutputUnit <> 'V') then raise Exception.Create('Generic unit');
      end;
      CheckGenericView(lModel, lTags, lTag);
      WriteLn('RESULT VibrationUiSmoke resource/resize/cancel/generic/vibration/hold/view passed');
    finally
      lTimer.Free; lProbe.Free; lModel.Free; lTags.Free;
    end;
  except on E: Exception do
    begin WriteLn('RESULT VibrationUiSmoke failed: ', E.Message); Halt(1); end;
  end;
end.
