unit uProgressDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TProgresDlg = class(TForm)
    ProgressBar1: TProgressBar;
    UserBtnGB: TGroupBox;
    CancelBtn: TButton;
    StatusLabel: TLabel;
    MessageLabel: TLabel;
    procedure CancelBtnClick(Sender: TObject);
  private
    cancelProc:boolean;
  public
    procedure showProgress(header:string);
    function UpdateProgress(pr:integer; mess:string):boolean;
  end;

var
  ProgresDlg: TProgresDlg;

implementation

{$R *.dfm}

procedure TProgresDlg.showProgress;
begin
  cancelProc:=true;
  caption:=header;
  show;
end;

procedure TProgresDlg.CancelBtnClick(Sender: TObject);
begin
  // отменить процесс
  cancelProc:=false;
  progressbar1.Position:=0;
  hide;
end;

function TProgresDlg.UpdateProgress(pr:integer; mess:string):boolean;
begin
  Application.ProcessMessages;
  MessageLabel.Caption:=inttostr(ProgressBar1.position)+' % '+mess;
  result:=cancelProc;
  ProgressBar1.Position:=pr;

end;

end.
