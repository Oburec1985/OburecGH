unit uConfirmDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TConfirmFmr = class(TForm)
    ConfirmTextLabel: TLabel;
    TxtLabel: TLabel;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    procedure ApplyBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    fExecute:boolean;
  public
    data:pointer;
    fApplyCallBack:TNotifyEvent;
  public
    procedure SecCallBack(cb:TNotifyEvent; p_data:pointer);
    procedure SetText(str:string);
    function Execute:boolean;
  end;

var
  ConfirmFmr: TConfirmFmr;

implementation

{$R *.dfm}

{ TConfirmFmr }

procedure TConfirmFmr.ApplyBtnClick(Sender: TObject);
begin
  hide;
  if Assigned(fApplyCallBack) then
    fApplyCallBack(data);
  fExecute:=false;
end;

procedure TConfirmFmr.CancelBtnClick(Sender: TObject);
begin
  hide;
end;

function TConfirmFmr.Execute: boolean;
begin
  show;
end;

procedure TConfirmFmr.SecCallBack(cb: TNotifyEvent; p_data: pointer);
begin
  fApplyCallBack:=cb;
  data:=p_data;
end;

procedure TConfirmFmr.SetText(str: string);
begin
  TxtLabel.caption:=str;
end;

end.
