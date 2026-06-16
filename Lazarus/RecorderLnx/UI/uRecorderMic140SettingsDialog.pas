unit uRecorderMic140SettingsDialog;

{
  Runtime-built MIC-140 setup dialog.

  The dialog keeps MIC-140 configuration in the same tag/source model as other
  RecorderLnx data sources: selected channels become tags bound to
  RecorderMic140SourceId(Host, Port).
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids, Buttons, Dialogs,
  uRecorderMic140DataSource;

type
  TRecorderMic140DialogResult = record
    Host: string;
    Port: Word;
    ChannelCount: Integer;
    PollFrequencyHz: Double;
    VersionText: string;
    ThermoCompensationEnabled: Boolean;
    DefaultCorrector: Boolean;
    CorrectorChannel: string;
    SelectedChannels: TStringList;
  end;

function ShowRecorderMic140SettingsDialog(AOwner: TComponent;
  var AResult: TRecorderMic140DialogResult): Boolean;
procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);

implementation

type
  TRecorderMic140SettingsDialog = class(TForm)
  private
    fHostEdit: TEdit;
    fPortEdit: TEdit;
    fFrequencyEdit: TComboBox;
    fChannelCountCombo: TComboBox;
    fVersionEdit: TEdit;
    fTimingLabel: TLabel;
    fThermoCompCheck: TCheckBox;
    fDefaultCorrectorCheck: TCheckBox;
    fCorrectorCombo: TComboBox;
    fGrid: TStringGrid;
    procedure BuildUi;
    procedure FillGrid(AChannelCount: Integer; ASelected: TStrings);
    procedure ToggleGridRow(ARow: Integer);
    procedure GridDblClick(Sender: TObject);
    procedure ChannelCountChange(Sender: TObject);
    procedure SearchClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure FrequencyChange(Sender: TObject);
    function ReadPort: Word;
    function ReadFrequency: Double;
    function ReadChannelCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromResult(const AResult: TRecorderMic140DialogResult);
    procedure StoreToResult(var AResult: TRecorderMic140DialogResult);
  end;

procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
begin
  AResult.Host := MIC140DefaultHost;
  AResult.Port := MIC140DefaultPort;
  AResult.ChannelCount := MIC140DefaultChannelCount;
  AResult.PollFrequencyHz := MIC140DefaultPollFrequencyHz;
  AResult.VersionText := '';
  AResult.ThermoCompensationEnabled := False;
  AResult.DefaultCorrector := True;
  AResult.CorrectorChannel := 'T2';
  AResult.SelectedChannels := TStringList.Create;
end;

procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
begin
  FreeAndNil(AResult.SelectedChannels);
end;

function ShowRecorderMic140SettingsDialog(AOwner: TComponent;
  var AResult: TRecorderMic140DialogResult): Boolean;
var
  lDialog: TRecorderMic140SettingsDialog;
begin
  lDialog := TRecorderMic140SettingsDialog.Create(AOwner);
  try
    lDialog.LoadFromResult(AResult);
    Result := lDialog.ShowModal = mrOk;
    if Result then
      lDialog.StoreToResult(AResult);
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderMic140SettingsDialog.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  BuildUi;
end;

procedure TRecorderMic140SettingsDialog.BuildUi;
var
  lBottom: TPanel;
  lButton: TButton;
  lButtonPanel: TPanel;
  I: Integer;
  lTop: TPanel;
begin
  Caption := 'MIC-140';
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  ClientWidth := 720;
  ClientHeight := 560;
  Constraints.MinWidth := 640;
  Constraints.MinHeight := 460;

  lTop := TPanel.Create(Self);
  lTop.Parent := Self;
  lTop.Align := alTop;
  lTop.Height := 118;
  lTop.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 12;
    Top := 14;
    Caption := 'IP';
  end;
  fHostEdit := TEdit.Create(Self);
  fHostEdit.Parent := lTop;
  fHostEdit.Left := 46;
  fHostEdit.Top := 10;
  fHostEdit.Width := 128;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 188;
    Top := 14;
    Caption := 'Port';
  end;
  fPortEdit := TEdit.Create(Self);
  fPortEdit.Parent := lTop;
  fPortEdit.Left := 226;
  fPortEdit.Top := 10;
  fPortEdit.Width := 58;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 300;
    Top := 14;
    Caption := 'Channels';
  end;
  fChannelCountCombo := TComboBox.Create(Self);
  fChannelCountCombo.Parent := lTop;
  fChannelCountCombo.Left := 366;
  fChannelCountCombo.Top := 10;
  fChannelCountCombo.Width := 72;
  fChannelCountCombo.Style := csDropDownList;
  fChannelCountCombo.Items.Add('48');
  fChannelCountCombo.Items.Add('96');
  fChannelCountCombo.OnChange := @ChannelCountChange;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 454;
    Top := 14;
    Caption := 'Hz';
  end;
  fFrequencyEdit := TComboBox.Create(Self);
  fFrequencyEdit.Parent := lTop;
  fFrequencyEdit.Left := 482;
  fFrequencyEdit.Top := 10;
  fFrequencyEdit.Width := 86;
  fFrequencyEdit.Style := csDropDownList;
  for I := 0 to RecorderMic140FrequencyCount - 1 do
    fFrequencyEdit.Items.Add(FormatFloat('0.######', RecorderMic140Frequency(I)));
  fFrequencyEdit.OnChange := @FrequencyChange;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 586;
    Top := 14;
    Caption := 'Version';
  end;
  fVersionEdit := TEdit.Create(Self);
  fVersionEdit.Parent := lTop;
  fVersionEdit.Left := 640;
  fVersionEdit.Top := 10;
  fVersionEdit.Width := 70;
  fVersionEdit.ReadOnly := True;

  lButton := TButton.Create(Self);
  lButton.Parent := lTop;
  lButton.Left := 12;
  lButton.Top := 46;
  lButton.Width := 126;
  lButton.Height := 28;
  lButton.Caption := 'Auto search';
  lButton.OnClick := @SearchClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lTop;
  lButton.Left := 148;
  lButton.Top := 46;
  lButton.Width := 126;
  lButton.Height := 28;
  lButton.Caption := 'Test connect';
  lButton.OnClick := @TestClick;

  fThermoCompCheck := TCheckBox.Create(Self);
  fThermoCompCheck.Parent := lTop;
  fThermoCompCheck.Left := 300;
  fThermoCompCheck.Top := 50;
  fThermoCompCheck.Width := 150;
  fThermoCompCheck.Caption := 'Thermo comp';

  fDefaultCorrectorCheck := TCheckBox.Create(Self);
  fDefaultCorrectorCheck.Parent := lTop;
  fDefaultCorrectorCheck.Left := 450;
  fDefaultCorrectorCheck.Top := 50;
  fDefaultCorrectorCheck.Width := 120;
  fDefaultCorrectorCheck.Caption := 'Default CJC';

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 584;
    Top := 52;
    Caption := 'CJC';
  end;
  fCorrectorCombo := TComboBox.Create(Self);
  fCorrectorCombo.Parent := lTop;
  fCorrectorCombo.Left := 640;
  fCorrectorCombo.Top := 48;
  fCorrectorCombo.Width := 70;
  fCorrectorCombo.Style := csDropDownList;
  for I := 1 to MIC140TemperatureChannelCount do
    fCorrectorCombo.Items.Add('T' + IntToStr(I));

  fTimingLabel := TLabel.Create(Self);
  fTimingLabel.Parent := lTop;
  fTimingLabel.Left := 12;
  fTimingLabel.Top := 88;
  fTimingLabel.Width := 680;
  fTimingLabel.Caption := '';

  lBottom := TPanel.Create(Self);
  lBottom.Parent := Self;
  lBottom.Align := alBottom;
  lBottom.Height := 44;
  lBottom.BevelOuter := bvNone;

  lButtonPanel := TPanel.Create(Self);
  lButtonPanel.Parent := lBottom;
  lButtonPanel.Align := alRight;
  lButtonPanel.Width := 204;
  lButtonPanel.BevelOuter := bvNone;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := 10;
  lButton.Top := 8;
  lButton.Anchors := [akTop, akLeft];
  lButton.Caption := 'OK';
  lButton.Default := True;
  lButton.ModalResult := mrOk;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := 102;
  lButton.Top := 8;
  lButton.Anchors := [akTop, akLeft];
  lButton.Caption := 'Cancel';
  lButton.Cancel := True;
  lButton.ModalResult := mrCancel;

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.Align := alClient;
  fGrid.FixedCols := 0;
  fGrid.FixedRows := 1;
  fGrid.ColCount := 5;
  fGrid.Options := fGrid.Options + [goRowSelect, goRangeSelect, goColSizing];
  fGrid.OnDblClick := @GridDblClick;
  fGrid.Cells[0, 0] := 'Use';
  fGrid.Cells[1, 0] := 'Channel';
  fGrid.Cells[2, 0] := 'Name';
  fGrid.Cells[3, 0] := 'Mode';
  fGrid.Cells[4, 0] := 'Unit';
end;

procedure TRecorderMic140SettingsDialog.FillGrid(AChannelCount: Integer;
  ASelected: TStrings);
var
  I: Integer;
  lAddress: string;
begin
  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  fGrid.RowCount := AChannelCount + 1;
  for I := 1 to AChannelCount do
  begin
    lAddress := IntToStr(I);
    if (ASelected = nil) or (ASelected.Count = 0) or
      (ASelected.IndexOf(lAddress) >= 0) then
      fGrid.Cells[0, I] := '[x]'
    else
      fGrid.Cells[0, I] := '[ ]';
    fGrid.Cells[1, I] := lAddress;
    fGrid.Cells[2, I] := Format('MIC140_%2.2d', [I]);
    fGrid.Cells[3, I] := 'U';
    fGrid.Cells[4, I] := '';
  end;
  // TIn channels are configured through the CJC controls above. They are
  // intentionally hidden from the ordinary channel grid: the original Recorder
  // does not expose them as user channels, and scanning them like AIn channels
  // breaks the MIC-140 block layout.
end;

procedure TRecorderMic140SettingsDialog.ToggleGridRow(ARow: Integer);
begin
  if (ARow <= 0) or (ARow >= fGrid.RowCount) then
    Exit;
  if fGrid.Cells[0, ARow] = '[x]' then
    fGrid.Cells[0, ARow] := '[ ]'
  else
    fGrid.Cells[0, ARow] := '[x]';
end;

procedure TRecorderMic140SettingsDialog.GridDblClick(Sender: TObject);
begin
  ToggleGridRow(fGrid.Row);
end;

procedure TRecorderMic140SettingsDialog.ChannelCountChange(Sender: TObject);
var
  I: Integer;
  lSelected: TStringList;
begin
  lSelected := TStringList.Create;
  try
    for I := 1 to fGrid.RowCount - 1 do
      if fGrid.Cells[0, I] = '[x]' then
        lSelected.Add(fGrid.Cells[1, I]);
    FillGrid(ReadChannelCount, lSelected);
  finally
    lSelected.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.SearchClick(Sender: TObject);
var
  lFound: TStringList;
begin
  lFound := TStringList.Create;
  try
    Screen.Cursor := crHourGlass;
    try
      RecorderMic140Discover(lFound, MIC140DefaultDiscoverySubnet, ReadPort, 180);
    finally
      Screen.Cursor := crDefault;
    end;
    if lFound.Count > 0 then
    begin
      fHostEdit.Text := lFound[0];
      MessageDlg('MIC-140', 'Found: ' + lFound.CommaText, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg('MIC-140', 'Device not found in 192.168.14.0/24',
        mtWarning, [mbOK], 0);
  finally
    lFound.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.TestClick(Sender: TObject);
begin
  if RecorderMic140TestConnection(Trim(fHostEdit.Text), ReadPort, 500) then
    MessageDlg('MIC-140', 'Connection OK', mtInformation, [mbOK], 0)
  else
    MessageDlg('MIC-140', 'Connection failed', mtWarning, [mbOK], 0);
end;

function TRecorderMic140SettingsDialog.ReadPort: Word;
var
  lPort: Integer;
begin
  if not TryStrToInt(Trim(fPortEdit.Text), lPort) then
    lPort := MIC140DefaultPort;
  if (lPort <= 0) or (lPort > High(Word)) then
    lPort := MIC140DefaultPort;
  Result := Word(lPort);
end;

function TRecorderMic140SettingsDialog.ReadFrequency: Double;
var
  lText: string;
begin
  lText := Trim(fFrequencyEdit.Text);
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  if not TryStrToFloat(lText, Result) then
    Result := MIC140DefaultPollFrequencyHz;
  if Result <= 0 then
    Result := MIC140DefaultPollFrequencyHz;
  Result := RecorderMic140NormalizeFrequency(Result);
end;

procedure TRecorderMic140SettingsDialog.FrequencyChange(Sender: TObject);
var
  lTiming: TRecorderMic140Timing;
begin
  if fTimingLabel = nil then
    Exit;
  lTiming := RecorderMic140TimingForFrequency(ReadFrequency);
  fTimingLabel.Caption := Format('ADC wait %.3f us, GND %.3f us, average %d x %.3f us',
    [lTiming.ChannelCommutationUs, lTiming.GroundCommutationUs,
    lTiming.AverageSampleCount, lTiming.AveragePeriodUs]);
end;

function TRecorderMic140SettingsDialog.ReadChannelCount: Integer;
begin
  if not TryStrToInt(fChannelCountCombo.Text, Result) then
    Result := MIC140DefaultChannelCount;
  if Result > MIC140DefaultChannelCount then
    Result := MIC140MaxChannelCount
  else
    Result := MIC140DefaultChannelCount;
end;

procedure TRecorderMic140SettingsDialog.LoadFromResult(
  const AResult: TRecorderMic140DialogResult);
begin
  fHostEdit.Text := AResult.Host;
  fPortEdit.Text := IntToStr(AResult.Port);
  fFrequencyEdit.Text := FormatFloat('0.######',
    RecorderMic140NormalizeFrequency(AResult.PollFrequencyHz));
  if fFrequencyEdit.Items.IndexOf(fFrequencyEdit.Text) < 0 then
    fFrequencyEdit.ItemIndex := 0;
  fVersionEdit.Text := AResult.VersionText;
  fThermoCompCheck.Checked := AResult.ThermoCompensationEnabled;
  fDefaultCorrectorCheck.Checked := AResult.DefaultCorrector;
  fCorrectorCombo.Text := AResult.CorrectorChannel;
  if fCorrectorCombo.ItemIndex < 0 then
    fCorrectorCombo.ItemIndex := 1;
  if AResult.ChannelCount > MIC140DefaultChannelCount then
    fChannelCountCombo.ItemIndex := 1
  else
    fChannelCountCombo.ItemIndex := 0;
  FillGrid(ReadChannelCount, AResult.SelectedChannels);
  FrequencyChange(fFrequencyEdit);
end;

procedure TRecorderMic140SettingsDialog.StoreToResult(
  var AResult: TRecorderMic140DialogResult);
var
  I: Integer;
begin
  AResult.Host := Trim(fHostEdit.Text);
  if AResult.Host = '' then
    AResult.Host := MIC140DefaultHost;
  AResult.Port := ReadPort;
  AResult.ChannelCount := ReadChannelCount;
  AResult.PollFrequencyHz := ReadFrequency;
  AResult.VersionText := Trim(fVersionEdit.Text);
  AResult.ThermoCompensationEnabled := fThermoCompCheck.Checked;
  AResult.DefaultCorrector := fDefaultCorrectorCheck.Checked;
  AResult.CorrectorChannel := Trim(fCorrectorCombo.Text);
  if AResult.SelectedChannels <> nil then
  begin
    AResult.SelectedChannels.Clear;
    for I := 1 to fGrid.RowCount - 1 do
      if fGrid.Cells[0, I] = '[x]' then
        AResult.SelectedChannels.Add(fGrid.Cells[1, I]);
  end;
end;

end.
