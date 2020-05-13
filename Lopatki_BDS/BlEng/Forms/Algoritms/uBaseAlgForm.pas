unit uBaseAlgForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, CommonOptsFrame,
  uturbina, ustage, uBaseBldAlg, uBldCompProc, usensor, uSpin, uSensorRep,
  uSensorList,Spin;

type
  TBaseAlgForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
  private
    { Private declarations }
  public
    Function ShowModal(t:csensor; s:calgSensorList;opts:cBaseOpts):integer;
  end;

var
  BaseAlgForm: TBaseAlgForm;

implementation

{$R *.dfm}

Function TBaseAlgForm.ShowModal(t:csensor;s:calgSensorList; opts:cBaseOpts):integer;
begin
  // имя отчета
  BaseAlgOptsFrame1.SetOpts(t,s,Opts);
  BaseAlgOptsFrame1.ValidBladeGB.Enabled:=false;
  BaseAlgOptsFrame1.UseBadTickProcCheckBox.Enabled:=false;
  result:= inherited showmodal;
  if Result=mrok then
  begin
    BaseAlgOptsFrame1.GetOpts(opts);
  end;
end;

end.
