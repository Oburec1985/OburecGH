unit uSensorRepForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, CommonOptsFrame,
  uturbina, ustage, uBaseBldAlg, uBldCompProc, usensor, uSpin, uSensorRep, Spin,
  ExtCtrls, uSensorlist, Dialogs;

type
  TSensorRepForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    SensorRepOptsGB: TGroupBox;
    RepNameLabel: TLabel;
    SelectNameBtn: TButton;
    CancelBtn: TButton;
    OkBtn: TButton;
    PrecSE: TSpinEdit;
    PrecLabel: TLabel;
    RepNameCB: TComboBox;
    SingleFileCheckBox: TCheckBox;
    SaveDialog1: TSaveDialog;
    procedure SingleFileCheckBoxClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    sList:cAlgSensorList;
  public
    Function ShowModal(t:csensor;sensorlist:cAlgSensorList; opts:cBaseOpts):integer;
  end;

var
  SensorRepForm: TSensorRepForm;

implementation

{$R *.dfm}

procedure TSensorRepForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

Function TSensorRepForm.ShowModal(t:csensor;sensorlist:cAlgSensorList; opts:cBaseOpts):integer;
var
  s:csensor;
begin
  BaseAlgOptsFrame1.SetOpts(t,sensorlist,Opts);
  PrecSE.Value:=crepopts(opts).prec;
  if sensorlist.Count=1 then
  begin
    SingleFileCheckBox.Checked:=true;
    SingleFileCheckBox.Enabled:=false;
  end
  else
  begin
    SingleFileCheckBox.Enabled:=true;
    SingleFileCheckBox.Checked:=crepopts(opts).singlefile;
  end;
  GenerateReportName(RepNameCB,SingleFileCheckBox.Checked,sensorlist, sensorlist.Engine);
  // имя отчета
  result:= inherited showmodal;
  if Result=mrok then   
  begin
    BaseAlgOptsFrame1.GetOpts(Opts);
    crepopts(opts).repname:=RepNameCB.Items;
    crepopts(opts).prec:=PrecSE.Value;
    crepopts(opts).singlefile:=SingleFileCheckBox.Checked;
  end;
end;

procedure TSensorRepForm.SingleFileCheckBoxClick(Sender: TObject);
begin
  if slist<>nil then
    GenerateReportName(RepNameCB,SingleFileCheckBox.Checked,slist, slist.Engine);
end;

end.
