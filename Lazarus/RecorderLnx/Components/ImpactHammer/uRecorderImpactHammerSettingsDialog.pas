unit uRecorderImpactHammerSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ComCtrls, ExtCtrls, Dialogs, Grids,
  Graphics, LCLType, uRecorderTags, uRecorderImpactHammerModel,
  uRecorderImpactHammerContracts;

type
  TRecorderImpactHammerSettingsDialog = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    cbEstimator: TComboBox;
    cbHammer: TComboBox;
    cbWindow: TComboBox;
    chkEnabled: TCheckBox;
    chkExcitationAxis: TCheckBox;
    chkFront: TCheckBox;
    chkWelch: TCheckBox;
    chkZeroPad: TCheckBox;
    edCapture: TEdit;
    edCapacity: TEdit;
    edCoherence: TEdit;
    edFftSize: TEdit;
    edTagSearch: TEdit;
    edPretrigger: TEdit;
    edSampleRate: TEdit;
    edExcitationUnit: TEdit;
    edExportPath: TEdit;
    edThreshold: TEdit;
    edWelchOverlap: TEdit;
    edWelchSegment: TEdit;
    gbAcquisition: TGroupBox;
    gbAnalysis: TGroupBox;
    gbHammer: TGroupBox;
    gbResponses: TGroupBox;
    gbAvailableTags: TGroupBox;
    gbAxes: TGroupBox;
    grdAxes: TStringGrid;
    lblCapture: TLabel;
    lblCapacity: TLabel;
    lblCoherence: TLabel;
    lblEstimator: TLabel;
    lblFftSize: TLabel;
    lblFftDuration: TLabel;
    lblHammer: TLabel;
    lblPortion: TLabel;
    lblPretrigger: TLabel;
    lblSampleRate: TLabel;
    lblExcitationUnit: TLabel;
    lblThreshold: TLabel;
    lblWelchOverlap: TLabel;
    lblWelchSegment: TLabel;
    lblWindow: TLabel;
    lblExportPath: TLabel;
    tvChannels: TTreeView;
    udFftSize: TUpDown;
    lbAvailableTags: TListBox;
    pnlActions: TPanel;
    procedure btnOkClick(Sender: TObject);
    procedure edTagSearchChange(Sender: TObject);
    procedure cbHammerChange(Sender: TObject);
    procedure chkFrontChange(Sender: TObject);
    procedure chkWelchChange(Sender: TObject);
    procedure edTimeChange(Sender: TObject);
    procedure edFftSizeChange(Sender: TObject);
    procedure udFftSizeClick(Sender: TObject; Button: TUDBtnType);
    procedure tvChannelsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure tvChannelsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tvChannelsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grdAxesDblClick(Sender: TObject);
    procedure grdAxesDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure grdAxesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure grdAxesSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    fTarget: TRecorderImpactHammerComponent;
    fDraft: TRecorderImpactHammerComponent;
    fRegistry: TRecorderTagRegistry;
    fEnabledZeroPadFactor: Integer;
    fAvailableTags: TList;
    procedure PopulateAvailableTags;
    procedure PopulateHammerTags;
    procedure UpdatePortion;
    procedure UpdateFftDuration;
    function SelectedAvailableTag: TRecorderTag;
    procedure RemoveSelectedResponse;
    procedure LoadDraft;
    procedure LoadResponseList;
    procedure LoadAxisGrid;
    function SaveAxisGrid(out AError: string): Boolean;
    function ReadEditors(out AError: string): Boolean;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderImpactHammerComponent;
      ARegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderImpactHammerSettings(AOwner: TComponent;
  AComponent: TRecorderImpactHammerComponent;
  ARegistry: TRecorderTagRegistry): Boolean;

implementation

uses LazUTF8;

{$R *.lfm}

function ShowRecorderImpactHammerSettings(AOwner: TComponent;
  AComponent: TRecorderImpactHammerComponent;
  ARegistry: TRecorderTagRegistry): Boolean;
var
  Dialog: TRecorderImpactHammerSettingsDialog;
begin
  Dialog := TRecorderImpactHammerSettingsDialog.CreateDialog(
    AOwner, AComponent, ARegistry);
  try
    Result := Dialog.ShowModal = mrOk;
  finally
    Dialog.Free;
  end;
end;

constructor TRecorderImpactHammerSettingsDialog.CreateDialog(
  AOwner: TComponent; AComponent: TRecorderImpactHammerComponent;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
begin
  inherited Create(AOwner);
  fTarget := AComponent;
  fRegistry := ARegistry;
  fDraft := TRecorderImpactHammerComponent.Create;
  fDraft.Assign(fTarget);
  fAvailableTags := TList.Create;
  if fRegistry <> nil then
    for I := 0 to fRegistry.TagCount - 1 do
      if fRegistry.Tags[I].PollFrequencyHz > 0 then
        fAvailableTags.Add(fRegistry.Tags[I]);
  LoadDraft;
end;

destructor TRecorderImpactHammerSettingsDialog.Destroy;
begin
  fAvailableTags.Free;
  fDraft.Free;
  inherited Destroy;
end;

procedure TRecorderImpactHammerSettingsDialog.PopulateAvailableTags;
var
  I: Integer;
  lTag: TRecorderTag;
  lFilter: string;
  lSelected: TList;
begin
  lFilter := UTF8LowerCase(Trim(edTagSearch.Text));
  lSelected := TList.Create;
  for I := 0 to lbAvailableTags.Count - 1 do
    if lbAvailableTags.Selected[I] then
      lSelected.Add(lbAvailableTags.Items.Objects[I]);
  lbAvailableTags.Items.BeginUpdate;
  try
    lbAvailableTags.Items.Clear;
    for I := 0 to fAvailableTags.Count - 1 do
    begin
      lTag := TRecorderTag(fAvailableTags[I]);
      if (lFilter <> '') and (Pos(lFilter, UTF8LowerCase(lTag.Name + ' ' +
        lTag.Address + ' ' + lTag.Description)) = 0) then
        Continue;
      lbAvailableTags.Items.AddObject(lTag.Name, lTag);
      if lSelected.IndexOf(lTag) >= 0 then
        lbAvailableTags.Selected[lbAvailableTags.Items.Count - 1] := True;
    end;
  finally
    lbAvailableTags.Items.EndUpdate;
    lSelected.Free;
  end;
end;

function TRecorderImpactHammerSettingsDialog.SelectedAvailableTag: TRecorderTag;
begin
  Result := nil;
  if lbAvailableTags.ItemIndex >= 0 then
    Result := TRecorderTag(lbAvailableTags.Items.Objects[lbAvailableTags.ItemIndex]);
end;

procedure TRecorderImpactHammerSettingsDialog.LoadDraft;
begin
  PopulateAvailableTags;
  PopulateHammerTags;
  chkEnabled.Checked := fDraft.Enabled;
  chkExcitationAxis.Checked := fDraft.ExcitationOwnAxis;
  chkFront.Checked := fDraft.TriggerPolarity <> itpNegative;
  chkFrontChange(chkFront);
  edThreshold.Text := FloatToStr(fDraft.TriggerThreshold);
  edPretrigger.Text := FloatToStr(fDraft.PretriggerSamples / Max(1, fDraft.SampleRateHz));
  edCapture.Text := FloatToStr(fDraft.CaptureSamples / Max(1, fDraft.SampleRateHz));
  edCapacity.Text := IntToStr(fDraft.ImpactCapacity);
  edFftSize.Text := IntToStr(fDraft.FftSize);
  cbWindow.ItemIndex := Ord(fDraft.WindowKind);
  fEnabledZeroPadFactor := fDraft.ZeroPadFactor;
  if fEnabledZeroPadFactor <= 1 then
    fEnabledZeroPadFactor := 2;
  chkZeroPad.Checked := fDraft.ZeroPadFactor > 1;
  cbEstimator.ItemIndex := Ord(fDraft.Estimator);
  edCoherence.Text := FloatToStr(fDraft.CoherenceThreshold);
  chkWelch.Checked := fDraft.WelchEnabled;
  edWelchSegment.Text := IntToStr(fDraft.WelchSegmentSize);
  edWelchOverlap.Text := IntToStr(fDraft.WelchOverlapPercent);
  chkWelchChange(chkWelch);
  edSampleRate.Text := FloatToStr(fDraft.SampleRateHz);
  edExcitationUnit.Text := fDraft.ExcitationUnitName;
  edExportPath.Text := fDraft.ExportPath;
  UpdatePortion;
  UpdateFftDuration;
  LoadResponseList;
  LoadAxisGrid;
end;

procedure TRecorderImpactHammerSettingsDialog.PopulateHammerTags;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  cbHammer.Items.Clear;
  cbHammer.Items.AddObject('(не выбран)', nil);
  cbHammer.ItemIndex := 0;
  for I := 0 to fAvailableTags.Count - 1 do
  begin
    lTag := TRecorderTag(fAvailableTags[I]);
    cbHammer.Items.AddObject(lTag.Name, lTag);
    if (lTag.Id = fDraft.HammerTagId) or
      ((fDraft.HammerTagId = 0) and SameText(lTag.Name, fDraft.HammerTagName)) then
      cbHammer.ItemIndex := cbHammer.Items.Count - 1;
  end;
end;

procedure TRecorderImpactHammerSettingsDialog.UpdatePortion;
var
  lSeconds, lFs: Double;
begin
  lFs := fDraft.SampleRateHz;
  if (cbHammer.ItemIndex > 0) and
    (cbHammer.Items.Objects[cbHammer.ItemIndex] is TRecorderTag) then
    lFs := TRecorderTag(cbHammer.Items.Objects[cbHammer.ItemIndex]).PollFrequencyHz;
  if (lFs <= 0) or not TryStrToFloat(edCapture.Text, lSeconds) then
    lblPortion.Caption := 'Порция: —'
  else
    lblPortion.Caption := Format('Порция: %d точек (Fs %.4g Гц)',
      [Round(lSeconds * lFs), lFs]);
end;

procedure TRecorderImpactHammerSettingsDialog.UpdateFftDuration;
var
  lSize: Integer;
begin
  if (fDraft.SampleRateHz <= 0) or
    not TryStrToInt(edFftSize.Text, lSize) or (lSize < 1) then
    lblFftDuration.Caption := '— с'
  else
    lblFftDuration.Caption := Format('%.4g с',
      [lSize / fDraft.SampleRateHz]);
end;

procedure TRecorderImpactHammerSettingsDialog.edFftSizeChange(Sender: TObject);
begin
  UpdateFftDuration;
end;

procedure TRecorderImpactHammerSettingsDialog.udFftSizeClick(
  Sender: TObject; Button: TUDBtnType);
var
  lSize, lPower: Integer;
begin
  if not TryStrToInt(edFftSize.Text, lSize) then
    lSize := fDraft.FftSize;
  lSize := EnsureRange(lSize, 2, 1048576);
  lPower := 2;
  if Button = btNext then
  begin
    while (lPower <= lSize) and (lPower < 1048576) do
      lPower := lPower * 2;
  end
  else
  begin
    while (lPower * 2 < lSize) and (lPower < 1048576) do
      lPower := lPower * 2;
  end;
  edFftSize.Text := IntToStr(lPower);
end;

procedure TRecorderImpactHammerSettingsDialog.cbHammerChange(Sender: TObject);
var
  lTag: TRecorderTag;
begin
  lTag := nil;
  if cbHammer.ItemIndex > 0 then
    lTag := TRecorderTag(cbHammer.Items.Objects[cbHammer.ItemIndex]);
  if lTag = nil then
  begin
    fDraft.HammerTagId := 0;
    fDraft.HammerTagName := '';
  end
  else
  begin
    fDraft.HammerTagId := lTag.Id;
    fDraft.HammerTagName := lTag.Name;
    fDraft.SampleRateHz := lTag.PollFrequencyHz;
    edSampleRate.Text := FloatToStr(fDraft.SampleRateHz);
  end;
  LoadResponseList;
  UpdatePortion;
  UpdateFftDuration;
end;

procedure TRecorderImpactHammerSettingsDialog.edTimeChange(Sender: TObject);
begin
  UpdatePortion;
end;

procedure TRecorderImpactHammerSettingsDialog.chkFrontChange(Sender: TObject);
begin
  if chkFront.Checked then
    chkFront.Caption := 'Фронт'
  else
    chkFront.Caption := 'Спад';
end;

procedure TRecorderImpactHammerSettingsDialog.chkWelchChange(Sender: TObject);
begin
  edWelchSegment.Enabled := chkWelch.Checked;
  edWelchOverlap.Enabled := chkWelch.Checked;
  lblWelchSegment.Enabled := chkWelch.Checked;
  lblWelchOverlap.Enabled := chkWelch.Checked;
end;

procedure TRecorderImpactHammerSettingsDialog.grdAxesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key <> VK_RETURN) or (Shift <> []) then
    Exit;

  { Enter подтверждает текущую ячейку и продолжает ввод вниз по той же колонке. }
  grdAxes.EditorMode := False;
  if grdAxes.Row < grdAxes.RowCount - 1 then
    grdAxes.Row := grdAxes.Row + 1;
  Key := 0;
end;

procedure TRecorderImpactHammerSettingsDialog.grdAxesDblClick(Sender: TObject);
var
  lValue: Boolean;
begin
  if (grdAxes.Row < grdAxes.FixedRows) or
    not (grdAxes.Col in [1, 2, 3]) then
    Exit;

  grdAxes.EditorMode := False;
  lValue := StrToBoolDef(grdAxes.Cells[grdAxes.Col, grdAxes.Row], False);
  grdAxes.Cells[grdAxes.Col, grdAxes.Row] := BoolToStr(not lValue, True);
end;

procedure TRecorderImpactHammerSettingsDialog.grdAxesDrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
begin
  if (aRow = Ord(irtTime) + 1) and (aCol in [6, 7]) then
  begin
    grdAxes.Canvas.Brush.Color := clBtnFace;
    grdAxes.Canvas.FillRect(aRect);
  end;
end;

procedure TRecorderImpactHammerSettingsDialog.grdAxesSelectEditor(
  Sender: TObject; aCol, aRow: Integer; var Editor: TWinControl);
begin
  if (aRow = Ord(irtTime) + 1) and (aCol in [6, 7]) then
    Editor := nil;
end;

procedure TRecorderImpactHammerSettingsDialog.LoadAxisGrid;
const
  CNames: array[irtTime..irtCoherence] of string =
    ('Время', 'Спектр', 'FRF', 'Фаза', 'Когерентность');
var
  lType: TRecorderImpactResultType;
  lRow: Integer;
  lState: TImpactResultAxisState;
begin
  grdAxes.RowCount := 6;
  grdAxes.Cells[0, 0] := 'График';
  grdAxes.Cells[1, 0] := 'Log X';
  grdAxes.Cells[2, 0] := 'Log Y';
  grdAxes.Cells[3, 0] := 'Авто';
  grdAxes.Cells[4, 0] := 'X min';
  grdAxes.Cells[5, 0] := 'X max';
  grdAxes.Cells[6, 0] := 'Y min';
  grdAxes.Cells[7, 0] := 'Y max';
  for lType := irtTime to irtCoherence do
  begin
    lRow := Ord(lType) + 1;
    lState := fDraft.AxisStates[lType];
    grdAxes.Cells[0, lRow] := CNames[lType];
    grdAxes.Cells[1, lRow] := BoolToStr(lState.LogX, True);
    grdAxes.Cells[2, lRow] := BoolToStr(lState.LogY, True);
    grdAxes.Cells[3, lRow] := BoolToStr(lState.AutoScale, True);
    grdAxes.Cells[4, lRow] := FloatToStr(lState.XMin);
    grdAxes.Cells[5, lRow] := FloatToStr(lState.XMax);
    if lType = irtTime then
    begin
      grdAxes.Cells[6, lRow] := '';
      grdAxes.Cells[7, lRow] := '';
    end
    else
    begin
      grdAxes.Cells[6, lRow] := FloatToStr(lState.YMin);
      grdAxes.Cells[7, lRow] := FloatToStr(lState.YMax);
    end;
  end;
end;

function TRecorderImpactHammerSettingsDialog.SaveAxisGrid(
  out AError: string): Boolean;
var
  lType: TRecorderImpactResultType;
  lRow: Integer;
  lState: TImpactResultAxisState;
begin
  for lType := irtTime to irtCoherence do
  begin
    lRow := Ord(lType) + 1;
    lState := fDraft.AxisStates[lType];
    lState.LogX := StrToBoolDef(grdAxes.Cells[1, lRow], False);
    lState.LogY := StrToBoolDef(grdAxes.Cells[2, lRow], False);
    lState.AutoScale := StrToBoolDef(grdAxes.Cells[3, lRow], True);
    if not TryStrToFloat(grdAxes.Cells[4, lRow], lState.XMin) or
      not TryStrToFloat(grdAxes.Cells[5, lRow], lState.XMax) or
      ((lType <> irtTime) and
       (not TryStrToFloat(grdAxes.Cells[6, lRow], lState.YMin) or
        not TryStrToFloat(grdAxes.Cells[7, lRow], lState.YMax))) then
    begin
      AError := 'В настройках осей указано неверное число.';
      Exit(False);
    end;
    fDraft.AxisStates[lType] := lState;
  end;
  Result := True;
end;

procedure TRecorderImpactHammerSettingsDialog.LoadResponseList;
var
  I: Integer;
  R: TImpactResponseBinding;
  lRoot: TTreeNode;
begin
  tvChannels.Items.BeginUpdate;
  try
    tvChannels.Items.Clear;
    if fDraft.HammerTagName = '' then Exit;
    lRoot := tvChannels.Items.Add(nil, fDraft.HammerTagName);
    for I := 0 to fDraft.ResponseCount - 1 do
    begin
      R := fDraft.Responses[I];
      tvChannels.Items.AddChild(lRoot, R.TagName);
    end;
    lRoot.Expand(False);
  finally
    tvChannels.Items.EndUpdate;
  end;
end;

procedure TRecorderImpactHammerSettingsDialog.edTagSearchChange(Sender: TObject);
begin
  PopulateAvailableTags;
end;

procedure TRecorderImpactHammerSettingsDialog.tvChannelsDragOver(
  Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := (Source = lbAvailableTags) and (lbAvailableTags.SelCount > 0);
end;

procedure TRecorderImpactHammerSettingsDialog.tvChannelsDragDrop(
  Sender, Source: TObject; X, Y: Integer);
var
  I: Integer;
  lTag: TRecorderTag;
  lResponse: TImpactResponseBinding;
begin
  if Source <> lbAvailableTags then
    Exit;
  for I := 0 to lbAvailableTags.Count - 1 do
  begin
    if not lbAvailableTags.Selected[I] then Continue;
    lTag := TRecorderTag(lbAvailableTags.Items.Objects[I]);
    if lTag = nil then Continue;
    if fDraft.HammerTagName = '' then
    begin
      fDraft.HammerTagId := lTag.Id;
      fDraft.HammerTagName := lTag.Name;
      fDraft.SampleRateHz := lTag.PollFrequencyHz;
      edSampleRate.Text := FloatToStr(fDraft.SampleRateHz);
      cbHammer.ItemIndex := cbHammer.Items.IndexOfObject(lTag);
      Continue;
    end;
    if lTag.Id = fDraft.HammerTagId then Continue;
    lResponse := fDraft.AddResponse;
    lResponse.TagId := lTag.Id;
    lResponse.TagName := lTag.Name;
  end;
  LoadResponseList;
  UpdatePortion;
  UpdateFftDuration;
end;

procedure TRecorderImpactHammerSettingsDialog.RemoveSelectedResponse;
var
  I: Integer;
  lSelectedIndex: Integer;
  lCopy: TRecorderImpactHammerComponent;
begin
  if (tvChannels.Selected = nil) or (tvChannels.Selected.Parent = nil) then
    Exit;
  lSelectedIndex := tvChannels.Selected.Index;
  lCopy := TRecorderImpactHammerComponent.Create;
  try
    for I := 0 to fDraft.ResponseCount - 1 do
      if I <> lSelectedIndex then
        lCopy.AddResponse.Assign(fDraft.Responses[I]);
    fDraft.ClearResponses;
    for I := 0 to lCopy.ResponseCount - 1 do
      fDraft.AddResponse.Assign(lCopy.Responses[I]);
  finally
    lCopy.Free;
  end;
  LoadResponseList;
end;

procedure TRecorderImpactHammerSettingsDialog.tvChannelsKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    RemoveSelectedResponse;
    Key := 0;
  end;
end;
function TRecorderImpactHammerSettingsDialog.ReadEditors(
  out AError: string): Boolean;
var
  FloatValue: Double;
  IntValue: Integer;
begin
  Result := fDraft.SampleRateHz > 0;
  if chkFront.Checked then
    fDraft.TriggerPolarity := itpPositive
  else
    fDraft.TriggerPolarity := itpNegative;
  if not Result or not TryStrToFloat(edThreshold.Text, FloatValue) then
    Result := False
  else
  begin
    fDraft.TriggerThreshold := FloatValue;
    Result := True;
  end;
  fDraft.TriggerHysteresis := 0;
  if Result and TryStrToFloat(edPretrigger.Text, FloatValue) then
    fDraft.PretriggerSamples := Round(FloatValue * fDraft.SampleRateHz)
  else
    Result := False;
  if Result and TryStrToFloat(edCapture.Text, FloatValue) then
    fDraft.CaptureSamples := Round(FloatValue * fDraft.SampleRateHz)
  else
    Result := False;
  if Result and TryStrToInt(edCapacity.Text, IntValue) then
    fDraft.ImpactCapacity := IntValue
  else
    Result := False;
  if Result and TryStrToInt(edFftSize.Text, IntValue) then
    fDraft.FftSize := IntValue
  else
    Result := False;
  if chkZeroPad.Checked then
    fDraft.ZeroPadFactor := fEnabledZeroPadFactor
  else
    fDraft.ZeroPadFactor := 1;
  if Result and TryStrToFloat(edCoherence.Text, FloatValue) then
    fDraft.CoherenceThreshold := FloatValue
  else
    Result := False;
  fDraft.WelchEnabled := chkWelch.Checked;
  if fDraft.WelchEnabled then
  begin
    if Result and TryStrToInt(edWelchSegment.Text, IntValue) then
      fDraft.WelchSegmentSize := IntValue
    else
      Result := False;
    if Result and TryStrToInt(edWelchOverlap.Text, IntValue) then
      fDraft.WelchOverlapPercent := IntValue
    else
      Result := False;
  end;
  fDraft.ExportPath := Trim(edExportPath.Text);
  fDraft.Enabled := chkEnabled.Checked;
  fDraft.ExcitationOwnAxis := chkExcitationAxis.Checked;
  fDraft.ExcitationUnitName := Trim(edExcitationUnit.Text);
  if not Result then
  begin
    AError := 'Одно из числовых полей заполнено неверно.';
    Exit;
  end;
  if not SaveAxisGrid(AError) then
    Exit(False);
  fDraft.WindowKind := TImpactWindowKind(cbWindow.ItemIndex);
  fDraft.Estimator := TImpactFrfEstimator(cbEstimator.ItemIndex);
  Result := fDraft.Validate(AError, False);
end;

procedure TRecorderImpactHammerSettingsDialog.btnOkClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not ReadEditors(ErrorText) then
  begin
    MessageDlg(ErrorText, mtError, [mbOK], 0);
    Exit;
  end;
  fTarget.Assign(fDraft);
  ModalResult := mrOk;
end;

end.
