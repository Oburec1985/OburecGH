unit uMultiSensorForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, CommonOptsFrame, uBldObj,
  uturbina, ustage, uBaseBldAlg, uBldCompProc, usensor, uSpin, uSensorRep, Spin,
  ExtCtrls, uSensorlist, Dialogs;

type
  TMultiSensorForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    SensorRepOptsGB: TGroupBox;
    CancelBtn: TButton;
    OkBtn: TButton;
    BladeIndexSE: TSpinEdit;
    BladeIndexLabel: TLabel;
    ExcludeRootCB: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    sList:cAlgSensorList;
  private
    procedure excludeRoot;
  public
    Function ShowModal(t:csensor;sensorlist:cAlgSensorList; opts:cBaseOpts):integer;
  end;

var
  MultiSensorForm: TMultiSensorForm;

implementation
uses uMultiSensor;
{$R *.dfm}

procedure TMultiSensorForm.excluderoot;
var
  I: Integer;
  s:csensor;
begin
  i:=0;
  while I <= sList.Count - 1 do
  begin
    s:=csensor(slist.GetObj(i));
    if s.sensortype=c_Root then
    begin
      slist.RemoveObj(i);
    end;
    inc(i);
  end;
end;

procedure TMultiSensorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

Function TMultiSensorForm.ShowModal(t:csensor;sensorlist:cAlgSensorList; opts:cBaseOpts):integer;
var
  s:csensor;
begin
  slist:=sensorlist;
  BaseAlgOptsFrame1.SetOpts(t,sensorlist,Opts);
  // имя отчета
  BladeIndexSE.Value:=0;
  result:= inherited showmodal;
  if Result=mrok then
  begin
    BaseAlgOptsFrame1.GetOpts(opts);
    if ExcludeRootCB.Checked then
      excluderoot;
  end;
end;

end.
