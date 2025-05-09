unit uStageShapeForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, CommonOptsFrame,
  uturbina, ustage, uBaseBldAlg, uBldCompProc, usensor, uSpin, uSensorRep,
  uSensorList,Spin;

type
  TStageShapeForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
    Function ShowModal(t:csensor; s:calgSensorList;opts:cBaseOpts):integer;
  end;

var
  StageShapeForm: TStageShapeForm;

implementation

{$R *.dfm}

procedure TStageShapeForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

Function TStageShapeForm.ShowModal(t:csensor;s:calgSensorList; opts:cBaseOpts):integer;
begin
  // ��� ������
  BaseAlgOptsFrame1.SetOpts(t,s,Opts);
  BaseAlgOptsFrame1.ValidBladeGB.Enabled:=false;
  BaseAlgOptsFrame1.UseBadTickProcCheckBox.Enabled:=false;
  if opts.showFrm then
  begin
    result:= inherited showmodal;
    if Result=mrok then
    begin
      BaseAlgOptsFrame1.GetOpts(opts);
    end;
  end
  else
  begin
    result:=mrok;
    BaseAlgOptsFrame1.GetOpts(opts);
  end;
end;

end.
