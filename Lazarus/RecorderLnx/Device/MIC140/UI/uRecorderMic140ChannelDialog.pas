unit uRecorderMic140ChannelDialog;

{
  Per-channel MIC-140 properties (range, thermocouple GH, CJC), like CchanMic140pp.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls,
  uRecorderMic140DataSource, uRecorderMeraSdbThermocouples,
  uRecorderSdbSelectDialog;

function ShowRecorderMic140ChannelDialog(AOwner: TComponent; AChannelNumber: Integer;
  ADeviceSerial, ADevSubRev: Integer;
  var ASettings: TRecorderMic140ChannelSettings): Boolean;

implementation

type
  TRecorderMic140ChannelDialog = class(TForm)
    lbRange: TLabel;
    fRangeCombo: TComboBox;
    lbThermocouple: TLabel;
    fThermocoupleCombo: TComboBox;
    btnSelectThermocouple: TButton;
    btnClearThermocouple: TButton;
    lbCjc: TLabel;
    fCjcCombo: TComboBox;
    fDefaultCjcCheck: TCheckBox;
    lbTempRange: TLabel;
    fTempRangeEdit: TEdit;
    pnButtons: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure RangeChange(Sender: TObject);
    procedure ThermocoupleChange(Sender: TObject);
    procedure ThermocoupleDblClick(Sender: TObject);
    procedure SelectThermocoupleClick(Sender: TObject);
    procedure ClearThermocoupleClick(Sender: TObject);
    procedure DefaultCjcChange(Sender: TObject);
  private
    fChannelNumber: Integer;
    fDeviceSerial: Integer;
    fDevSubRev: Integer;
    fSettings: TRecorderMic140ChannelSettings;
    procedure InitCombos;
    procedure LoadFromSettings;
    procedure StoreToSettings;
    procedure UpdateTempRange;
    procedure UpdateCjcEnabled;
  public
    function Execute(AChannelNumber, ADeviceSerial, ADevSubRev: Integer;
      var ASettings: TRecorderMic140ChannelSettings): Boolean;
  end;

{$R *.lfm}

function ShowRecorderMic140ChannelDialog(AOwner: TComponent; AChannelNumber: Integer;
  ADeviceSerial, ADevSubRev: Integer;
  var ASettings: TRecorderMic140ChannelSettings): Boolean;
var
  lDialog: TRecorderMic140ChannelDialog;
begin
  lDialog := TRecorderMic140ChannelDialog.Create(AOwner);
  try
    Result := lDialog.Execute(AChannelNumber, ADeviceSerial, ADevSubRev, ASettings);
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderMic140ChannelDialog.FormCreate(Sender: TObject);
begin
  InitCombos;
end;

procedure TRecorderMic140ChannelDialog.InitCombos;
var
  I: Integer;
begin
  fRangeCombo.Items.Clear;
  for I := 0 to CMic140RangeCount - 1 do
    fRangeCombo.Items.Add(RecorderMic140RangeComboLabel(I));

  fThermocoupleCombo.Items.Clear;
  fThermocoupleCombo.Items.Add('');
  RecorderMeraListThermocoupleScales(fThermocoupleCombo.Items);

  fCjcCombo.Items.Clear;
  for I := 1 to MIC140TemperatureChannelCount do
    fCjcCombo.Items.Add('T' + IntToStr(I));
end;

procedure TRecorderMic140ChannelDialog.LoadFromSettings;
var
  lIndex: Integer;
begin
  if (fSettings.RangeIndex >= 0) and (fSettings.RangeIndex < fRangeCombo.Items.Count) then
    fRangeCombo.ItemIndex := fSettings.RangeIndex
  else
    fRangeCombo.ItemIndex := CMic140Range100mV;

  lIndex := fThermocoupleCombo.Items.IndexOf(fSettings.ThermocoupleScaleName);
  if (lIndex < 0) and (Trim(fSettings.ThermocoupleScaleName) <> '') then
  begin
    fThermocoupleCombo.Items.Add(fSettings.ThermocoupleScaleName);
    lIndex := fThermocoupleCombo.Items.Count - 1;
  end;
  if lIndex >= 0 then
    fThermocoupleCombo.ItemIndex := lIndex
  else
    fThermocoupleCombo.ItemIndex := 0;

  fDefaultCjcCheck.Checked := fSettings.DefaultCjc;
  if (fSettings.CjcChannel >= 1) and (fSettings.CjcChannel <= MIC140TemperatureChannelCount) then
    fCjcCombo.ItemIndex := fSettings.CjcChannel - 1
  else
    fCjcCombo.ItemIndex := 0;
  UpdateCjcEnabled;
  UpdateTempRange;
end;

procedure TRecorderMic140ChannelDialog.StoreToSettings;
var
  lName: string;
  lPath: string;
begin
  if fRangeCombo.ItemIndex >= 0 then
    fSettings.RangeIndex := fRangeCombo.ItemIndex
  else
    fSettings.RangeIndex := CMic140Range100mV;

  lName := Trim(fThermocoupleCombo.Text);
  if lName = '' then
  begin
    fSettings.ThermocoupleScaleName := '';
    fSettings.ThermocoupleScalePath := '';
  end
  else
  begin
    fSettings.ThermocoupleScaleName := lName;
    lPath := fSettings.ThermocoupleScalePath;
    if (lPath = '') or not SameText(RecorderMeraThermocoupleDisplayName(lPath),
      lName) then
      lPath := RecorderMeraThermocoupleRelativePath(lName);
    fSettings.ThermocoupleScalePath := lPath;
  end;

  fSettings.DefaultCjc := fDefaultCjcCheck.Checked;
  if fCjcCombo.ItemIndex >= 0 then
    fSettings.CjcChannel := fCjcCombo.ItemIndex + 1
  else
    fSettings.CjcChannel := 1;
end;

procedure TRecorderMic140ChannelDialog.UpdateTempRange;
begin
  StoreToSettings;
  if RecorderMic140ChannelUsesTemperature(fSettings) then
    fTempRangeEdit.Text := RecorderMic140ChannelGradRangeText(fSettings)
  else
    fTempRangeEdit.Text := '';
end;

procedure TRecorderMic140ChannelDialog.UpdateCjcEnabled;
begin
  fCjcCombo.Enabled := not fDefaultCjcCheck.Checked;
  if fDefaultCjcCheck.Checked then
  begin
    if fCjcCombo.Items.Count > 0 then
    begin
      if RecorderMic140DefaultCjcChannel(fChannelNumber - 1, fDevSubRev) - 1 >= 0 then
        fCjcCombo.ItemIndex := RecorderMic140DefaultCjcChannel(fChannelNumber - 1,
          fDevSubRev) - 1;
    end;
  end;
end;

procedure TRecorderMic140ChannelDialog.RangeChange(Sender: TObject);
begin
  UpdateTempRange;
end;

procedure TRecorderMic140ChannelDialog.ThermocoupleChange(Sender: TObject);
begin
  UpdateTempRange;
end;

procedure TRecorderMic140ChannelDialog.ThermocoupleDblClick(Sender: TObject);
begin
  SelectThermocoupleClick(Sender);
end;

procedure TRecorderMic140ChannelDialog.SelectThermocoupleClick(Sender: TObject);
var
  lIndex: Integer;
  lKey: string;
  lName: string;
begin
  if not ShowRecorderSdbSelectDialog(Self, fSettings.ThermocoupleScalePath,
    lKey) then
    Exit;
  lName := RecorderMeraThermocoupleDisplayName(lKey);
  lIndex := fThermocoupleCombo.Items.IndexOf(lName);
  if lIndex < 0 then
  begin
    fThermocoupleCombo.Items.Add(lName);
    lIndex := fThermocoupleCombo.Items.Count - 1;
  end;
  fThermocoupleCombo.ItemIndex := lIndex;
  fSettings.ThermocoupleScaleName := lName;
  fSettings.ThermocoupleScalePath := lKey;
  UpdateTempRange;
end;

procedure TRecorderMic140ChannelDialog.ClearThermocoupleClick(Sender: TObject);
begin
  fThermocoupleCombo.ItemIndex := 0;
  UpdateTempRange;
end;

procedure TRecorderMic140ChannelDialog.DefaultCjcChange(Sender: TObject);
begin
  UpdateCjcEnabled;
end;

function TRecorderMic140ChannelDialog.Execute(AChannelNumber, ADeviceSerial,
  ADevSubRev: Integer; var ASettings: TRecorderMic140ChannelSettings): Boolean;
begin
  fChannelNumber := AChannelNumber;
  fDeviceSerial := ADeviceSerial;
  fDevSubRev := ADevSubRev;
  fSettings := ASettings;
  if fDeviceSerial > 0 then
    Caption := Format('Свойства канала MIC140-%4.4d-%d',
      [fDeviceSerial, AChannelNumber])
  else
    Caption := Format('Свойства канала MIC140-%4.4d-%d', [0, AChannelNumber]);
  LoadFromSettings;
  Result := ShowModal = mrOk;
  if Result then
  begin
    StoreToSettings;
    ASettings := fSettings;
  end;
end;

end.
