unit uRecorderMic185AdditionalDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls,
  uMic185MebiusTypes;

type
  TRecorderMic185AdditionalForm = class(TForm)
    cbAverageCount: TComboBox;
    chkBalanceDac: TCheckBox;
    chkBreakSensor: TCheckBox;
    chkMaxOneChannel: TCheckBox;
    chkThermoCompensation: TCheckBox;
    edBalanceSamples: TEdit;
    edChannelCommutUs: TEdit;
    edGroundCommutUs: TEdit;
    edMaxFrequencyHz: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    btnApply: TButton;
    btnCancel: TButton;
    btnFactory: TButton;
    procedure btnFactoryClick(Sender: TObject);
    procedure cbAverageCountChange(Sender: TObject);
    procedure edTimingEditingDone(Sender: TObject);
  private
    procedure FillAverageItems;
    function ReadEditLongWord(AEdit: TEdit; ADefault: LongWord): LongWord;
    procedure UpdateMaxFrequency;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadDefaults;
    procedure LoadSettings(const ASettings: TMic185ModuleProgramSettings;
      ATemperatureCompensation: Boolean);
    procedure SaveSettings(var ASettings: TMic185ModuleProgramSettings;
      out ATemperatureCompensation: Boolean);
  end;

function ShowRecorderMic185AdditionalDialog(AOwner: TComponent;
  var ASettings: TMic185ModuleProgramSettings;
  var ATemperatureCompensation: Boolean): Boolean;

implementation

{$R *.lfm}

uses
  Math, uMic185Constants;

constructor TRecorderMic185AdditionalForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  cbAverageCount.OnChange := @cbAverageCountChange;
  edGroundCommutUs.OnEditingDone := @edTimingEditingDone;
  edChannelCommutUs.OnEditingDone := @edTimingEditingDone;
  chkMaxOneChannel.OnChange := @cbAverageCountChange;
  btnFactory.OnClick := @btnFactoryClick;
end;

procedure TRecorderMic185AdditionalForm.FillAverageItems;
begin
  cbAverageCount.Items.Clear;
  cbAverageCount.Items.Add('1');
  cbAverageCount.Items.Add('2');
  cbAverageCount.Items.Add('4');
  cbAverageCount.Items.Add('8');
  cbAverageCount.Items.Add('16');
  cbAverageCount.Items.Add('32');
  cbAverageCount.Items.Add('64');
  cbAverageCount.Items.Add('128');
end;

function TRecorderMic185AdditionalForm.ReadEditLongWord(AEdit: TEdit;
  ADefault: LongWord): LongWord;
var
  lValue: Int64;
begin
  if TryStrToInt64(Trim(AEdit.Text), lValue) and (lValue >= 0) then
    Result := LongWord(Min(lValue, High(LongWord)))
  else
    Result := ADefault;
end;

procedure TRecorderMic185AdditionalForm.UpdateMaxFrequency;
var
  lSettings: TMic185ModuleProgramSettings;
  lTemperatureCompensation: Boolean;
begin
  Mic185DefaultModuleProgramSettings(lSettings);
  SaveSettings(lSettings, lTemperatureCompensation);
  edMaxFrequencyHz.Text := FormatFloat('0.###',
    Mic185CalcMaxFrequencyHz(lSettings));
end;

procedure TRecorderMic185AdditionalForm.LoadDefaults;
var
  lSettings: TMic185ModuleProgramSettings;
begin
  Mic185DefaultModuleProgramSettings(lSettings);
  LoadSettings(lSettings, True);
end;

procedure TRecorderMic185AdditionalForm.LoadSettings(
  const ASettings: TMic185ModuleProgramSettings;
  ATemperatureCompensation: Boolean);
var
  lPointText: string;
begin
  FillAverageItems;
  lPointText := IntToStr(Mic185AverageExponentToPointCount(
    ASettings.AveragePointCount));
  cbAverageCount.ItemIndex := cbAverageCount.Items.IndexOf(lPointText);
  if cbAverageCount.ItemIndex < 0 then
    cbAverageCount.ItemIndex := cbAverageCount.Items.IndexOf('128');
  edGroundCommutUs.Text := IntToStr(ASettings.GroundCommutationUs);
  edChannelCommutUs.Text := IntToStr(ASettings.ChannelCommutationUs);
  edBalanceSamples.Text := IntToStr(ASettings.BalancePortionLength);
  chkBreakSensor.Checked := ASettings.DetermineBreak;
  chkThermoCompensation.Checked := ATemperatureCompensation;
  chkBalanceDac.Checked := ASettings.HardwareBalanceOn;
  chkMaxOneChannel.Checked := ASettings.MaxFreqMode <> 0;
  UpdateMaxFrequency;
end;

procedure TRecorderMic185AdditionalForm.SaveSettings(
  var ASettings: TMic185ModuleProgramSettings;
  out ATemperatureCompensation: Boolean);
var
  lPointCount: Integer;
begin
  ASettings.GroundCommutationUs := ReadEditLongWord(edGroundCommutUs,
    CMic185DefaultGndCommutUs);
  ASettings.ChannelCommutationUs := ReadEditLongWord(edChannelCommutUs,
    CMic185DefaultChnCommutUs);
  ASettings.BalancePortionLength := ReadEditLongWord(edBalanceSamples,
    CMic185DefaultBlnPortionLength);
  if not TryStrToInt(Trim(cbAverageCount.Text), lPointCount) then
    lPointCount := Mic185AverageExponentToPointCount(CMic185DefaultAveragePointCount);
  ASettings.AveragePointCount :=
    Mic185AveragePointCountToExponent(LongWord(lPointCount));
  ASettings.MaxFreqMode := Ord(chkMaxOneChannel.Checked);
  ASettings.CalibrShuntIndex := CMic185DefaultCalibrShuntIndex;
  ASettings.DetermineBreak := chkBreakSensor.Checked;
  ASettings.HardwareBalanceOn := chkBalanceDac.Checked;
  ATemperatureCompensation := chkThermoCompensation.Checked;
end;

procedure TRecorderMic185AdditionalForm.btnFactoryClick(Sender: TObject);
begin
  LoadDefaults;
end;

procedure TRecorderMic185AdditionalForm.cbAverageCountChange(Sender: TObject);
begin
  UpdateMaxFrequency;
end;

procedure TRecorderMic185AdditionalForm.edTimingEditingDone(Sender: TObject);
begin
  UpdateMaxFrequency;
end;

function ShowRecorderMic185AdditionalDialog(AOwner: TComponent;
  var ASettings: TMic185ModuleProgramSettings;
  var ATemperatureCompensation: Boolean): Boolean;
var
  lForm: TRecorderMic185AdditionalForm;
begin
  lForm := TRecorderMic185AdditionalForm.Create(AOwner);
  try
    lForm.LoadSettings(ASettings, ATemperatureCompensation);
    Result := lForm.ShowModal = mrOk;
    if Result then
      lForm.SaveSettings(ASettings, ATemperatureCompensation);
  finally
    lForm.Free;
  end;
end;

end.
