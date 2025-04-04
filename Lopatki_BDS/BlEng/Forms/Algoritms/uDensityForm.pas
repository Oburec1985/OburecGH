unit uDensityForm;

interface

uses
  Windows, SysUtils, Classes, Forms, uBaseBldAlg, uSensor, uSensorList,
  StdCtrls, Spin, CommonOptsFrame, uSpin, Controls, uDensityAlg, uChart;

type
  TDensityForm = class(TForm)
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    OrderFE: TFloatSpinEdit;
    OrderLabel: TLabel;
    SensorEdit: TEdit;
    SensorLabel: TLabel;
    TextCheckBox: TCheckBox;
    NormaliseCheckBox: TCheckBox;
    UseStageInfoCheckBox: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
    Function ShowModal(t:csensor; s:calgSensorList;c:cchart):integer;
  end;
var
  DensityForm: TDensityForm;

implementation

{$R *.dfm}

procedure TDensityForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

Function TDensityForm.ShowModal(t:csensor; s:calgSensorList;c:cchart):integer;
begin
  SensorEdit.Text:=s.GetSensor(0).name;
  result:= inherited showmodal;
  if Result=mrok then
  begin
    EvalDensity(t,s,c,orderfe.Value, NormaliseCheckBox.Checked, TextCheckBox.Checked, UseStageInfoCheckBox.checked);
  end;
end;


end.
