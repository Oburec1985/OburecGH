unit uXNetDetect_Demo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XNetDetect_v2;

type
  TForm1 = class(TForm)
    lblStatus: TLabel;
    lblTime: TLabel;
    tmrClock: TTimer;
    XNetDetect: TXNetDetect;
    Label1: TLabel;
    btnActivate: TButton;
    procedure FormCreate(Sender: TObject);
    procedure XNetDetectConnectionStatusChanged(Sender: TObject;
      isConnected: Boolean);
    procedure tmrClockTimer(Sender: TObject);
    procedure btnActivateClick(Sender: TObject);
    procedure XNetDetectConnectionStatus(Sender: TObject;
      isConnected: Boolean);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // start a new thread for requesting internet connection response
  XNetDetect.InitiateCheckingConnection();
  lblStatus.Caption := 'Checking Connection...';
  Application.ProcessMessages;
end;

procedure TForm1.tmrClockTimer(Sender: TObject);
begin
  lblTime.Caption := TimeToStr(Now);
end;

procedure TForm1.XNetDetectConnectionStatus(Sender: TObject;
  isConnected: Boolean);
begin
  if isConnected then
    lblStatus.Caption := 'Currently Connected!'
  else
    lblStatus.Caption := 'Currently Not Connected!';
end;

procedure TForm1.XNetDetectConnectionStatusChanged(Sender: TObject;
  isConnected: Boolean);
begin
  if isConnected then
    lblStatus.Caption := 'Connected!'
  else
    lblStatus.Caption := 'Disconnected!';
end;

procedure TForm1.btnActivateClick(Sender: TObject);
begin
  XNetDetect.Enabled := not XNetDetect.Enabled;
  if XNetDetect.Enabled then
    btnActivate.Caption := 'Stop'
  else
    btnActivate.Caption := 'Start';
end;

end.
