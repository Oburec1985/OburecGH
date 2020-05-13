unit uRestoreAlgForm;

interface

uses
  Windows, SysUtils, Controls, Forms,
  CommonOptsFrame, StdCtrls, usensor, uBaseBldAlg, Classes, uSensorList;

type
  TRestoreAlgForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BaseAlgOptsFrame1MeraFileCBClick(Sender: TObject);
  private
    { Private declarations }
  public
    Function ShowModal(t:csensor;sensors:calgsensorlist;opts:cBaseOpts):integer;
  end;

var
  RestoreAlgForm: TRestoreAlgForm;

implementation
uses
  uRestoreVibrationAlg;
{$R *.dfm}


procedure TRestoreAlgForm.BaseAlgOptsFrame1MeraFileCBClick(Sender: TObject);
begin
  BaseAlgOptsFrame1.MeraFileCBClick(Sender);
end;

procedure TRestoreAlgForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

Function TRestoreAlgForm.ShowModal(t:csensor; sensors:calgsensorlist;opts:cBaseOpts):integer;
begin
  BaseAlgOptsFrame1.SetOpts(t,sensors,opts);
  // имя отчета
  result:= inherited showmodal;
  if result=mrok then
  begin
    BaseAlgOptsFrame1.GetOpts(opts);
  end;
end;

end.
