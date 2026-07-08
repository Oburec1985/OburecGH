unit uRecorderMic185AdditionalDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls;

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
  public
    procedure LoadDefaults;
  end;

function ShowRecorderMic185AdditionalDialog(AOwner: TComponent): Boolean;

implementation

{$R *.lfm}

uses
  uMic185Constants;

procedure TRecorderMic185AdditionalForm.LoadDefaults;
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
  cbAverageCount.Text := IntToStr(CMic185DefaultAveragePointCount);
  edGroundCommutUs.Text := IntToStr(CMic185DefaultGndCommutUs);
  edChannelCommutUs.Text := IntToStr(CMic185DefaultChnCommutUs);
  edMaxFrequencyHz.Text := '105';
  edBalanceSamples.Text := IntToStr(CMic185DefaultBlnPortionLength);
end;

function ShowRecorderMic185AdditionalDialog(AOwner: TComponent): Boolean;
var
  lForm: TRecorderMic185AdditionalForm;
begin
  lForm := TRecorderMic185AdditionalForm.Create(AOwner);
  try
    lForm.LoadDefaults;
    Result := lForm.ShowModal = mrOk;
  finally
    lForm.Free;
  end;
end;

end.
