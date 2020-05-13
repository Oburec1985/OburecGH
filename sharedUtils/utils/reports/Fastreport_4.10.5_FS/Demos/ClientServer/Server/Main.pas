
{******************************************}
{                                          }
{             FastReport v4.0              }
{          FastReport Server demo          }
{         Copyright (c) 1998-2007          }
{         by Alexander Fediachov,          }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit Main;

{$I frx.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Db, DBTables, frxDesgn, frxClass, frxDCtrl,
  frxChart, frxRich, frxBarcode, ImgList, ComCtrls, ExtCtrls, frxOLE,
  frxCross, frxServer, frxGradient, frxChBox, Menus, ShellApi,
  frxADOComponents, ADODB, frxGZip, Dialogs, frxMD5, frxServerUtils, IniFiles,
  frxServerStat, frxServerConfig, frxVariables;

type
  TMainForm = class(TForm)
    frBarCodeObject1: TfrxBarCodeObject;
    frRichObject1: TfrxRichObject;
    frChartObject1: TfrxChartObject;
    frDialogControls1: TfrxDialogControls;
    ImageList1: TImageList;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    frOLEObject1: TfrxOLEObject;
    frCrossObject1: TfrxCrossObject;
    frxCheckBoxObject1: TfrxCheckBoxObject;
    PopupMenu1: TPopupMenu;
    Close1: TMenuItem;
    ShowWin: TMenuItem;
    N1: TMenuItem;
    MinimizeBtn: TButton;
    CloseBtn: TButton;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    LBActive: TLabel;
    LBInactive: TLabel;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    ETotalSessions: TEdit;
    Label6: TLabel;
    ETotalReports: TEdit;
    Timer1: TTimer;
    Label7: TLabel;
    Label8: TLabel;
    EMaxReports: TEdit;
    EMaxSessions: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    ECurrentReports: TEdit;
    ECurrentSessions: TEdit;
    Label11: TLabel;
    EErrors: TEdit;
    N2: TMenuItem;
    Start1: TMenuItem;
    Stop1: TMenuItem;
    StartBtn: TButton;
    StopBtn: TButton;
    DesignBtn: TButton;
    frxDesigner1: TfrxDesigner;
    OpenDialog1: TOpenDialog;
    Label12: TLabel;
    Uptime: TLabel;
    frxADOComponents1: TfrxADOComponents;
    Serv: TfrxReportServer;
    Label13: TLabel;
    DemoDatabase: TADOConnection;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MinimizeBtnClick(Sender: TObject);
    procedure ShutBtnClick(Sender: TObject);
    procedure ShowWinClick(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DesignBtnClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure ServGetVariables(const ReportName: String;
      Variables: TfrxVariables; User: String);
  protected
    procedure ControlWindow(var Msg:TMessage); message WM_SYSCOMMAND;
    procedure IconMouse(var Msg : TMessage); message WM_USER + 1;
  private
    Icon: TIcon;
    frReport1: TfrxReport;
    procedure TrayIcon(n: Integer; Icon: TIcon);
  end;

var
  MainForm: TMainForm;
  dbMd: String;

implementation

{$R *.DFM}

{$IFDEF Delphi7}
uses  XPMan;
{$ENDIF}

var
  DATABASE_FILE: String;
  DBConnStr: String = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=';

procedure TMainForm.TrayIcon(n:Integer;Icon:TIcon);
var
  Nim: TNotifyIconData;
begin
  with Nim do
  begin
    cbSize:=SizeOf(Nim);
    Wnd:=Self.Handle;
    uID:=1;
    uFlags:=NIF_ICON or NIF_MESSAGE or NIF_TIP;
    hicon:=Icon.Handle;
    uCallbackMessage:=WM_USER + 1;
    szTip:='FastReport Server';
  end;
  case n of
    1: Shell_NotifyIcon(Nim_Add,@Nim);
    2: Shell_NotifyIcon(Nim_Delete,@Nim);
    3: Shell_NotifyIcon(Nim_Modify,@Nim);
  end;
end;

procedure TMainForm.ControlWindow(var Msg: TMessage);
begin
  if Msg.WParam = SC_MINIMIZE then
  begin
    TrayIcon(1, Icon);
    ShowWindow(Application.Handle, SW_HIDE);
    ShowWindow(Handle, SW_HIDE);
  end else
    inherited;
end;

procedure TMainForm.IconMouse(var Msg: TMessage);
var
  p:tpoint;
begin
  GetCursorPos(p);
  case Msg.LParam of
    WM_LBUTTONUP, WM_LBUTTONDBLCLK:
      ShowWinClick(nil);
    WM_RBUTTONUP:
    begin
      SetForegroundWindow(Handle);
      PopupMenu1.Popup(p.X, p.Y);
      PostMessage(Handle,WM_NULL,0,0)
    end;
  End;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Label13.Caption := #174;
  Icon := TIcon.Create;
  ImageList1.GetIcon(0, Icon);
  DemoDatabase.ConnectionString := DBConnStr + frxGetAbsPath(ServerConfig.GetValue('server.database.pathtodatabase'));
  try
    DemoDatabase.Open;
  except
    ShowMessage('Error database connection!');
  end;
  StartBtnClick(Sender);
  MinimizeBtnClick(Sender);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Serv <> nil then
    StopBtnClick(Sender);
  TrayIcon(2, Icon);
  Icon.Free;
  if DemoDatabase.Connected then
    DemoDatabase.Close;
end;

procedure TMainForm.MinimizeBtnClick(Sender: TObject);
begin
  PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TMainForm.ShutBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.ShowWinClick(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_SHOWNORMAL);
  ShowWindow(Handle, SW_SHOWNORMAL);
end;

procedure TMainForm.StartBtnClick(Sender: TObject);
begin
  if DemoDatabase.Connected then
  begin
    Screen.Cursor := crHourGlass;
    try
      Serv.Open;
      if Serv.Active then
      begin
        StartBtn.Enabled := False;
        StopBtn.Enabled := True;
        LBActive.Visible := True;
        LBInactive.Visible := False;
        Timer1.Enabled := True;
        ImageList1.GetIcon(0, Icon);
        TrayIcon(3, Icon);
        Start1.Enabled := False;
        Stop1.Enabled := True;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMainForm.StopBtnClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    Timer1.Enabled := False;
    Serv.Close;
    StartBtn.Enabled := True;
    StopBtn.Enabled := False;
    LBActive.Visible := False;
    LBInactive.Visible := True;
    ImageList1.GetIcon(1, Icon);
    TrayIcon(3, Icon);
    Start1.Enabled := True;
    Stop1.Enabled := False;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  ETotalSessions.Text := IntToStr(ServerStatistic.TotalSessionsCount);
  ETotalReports.Text := IntToStr(ServerStatistic.TotalReportsCount);
  EMaxSessions.Text := IntToStr(ServerStatistic.MaxSessionsCount);
  EMaxReports.Text := IntToStr(ServerStatistic.MaxReportsCount);
  EErrors.Text := IntToStr(ServerStatistic.TotalErrors);
  ECurrentSessions.Text := IntToStr(ServerStatistic.CurrentSessionsCount);
  ECurrentReports.Text := IntToStr(ServerStatistic.CurrentReportsCount);
  Uptime.Caption := ServerStatistic.FormatUpTime;
  Label2.Caption := 'Version: ' + String(Serv.Variables.GetValue('SERVER_SOFTWARE'));
end;

procedure TMainForm.DesignBtnClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := Serv.Configuration.ReportPath;
  if OpenDialog1.Execute then
  begin
    frReport1 := TfrxReport.Create(nil);
    frReport1.LoadFromFile(OpenDialog1.FileName);
    frReport1.Variables['PathToDataBase'] := '''' + DATABASE_FILE + '''';
    frReport1.DesignReport;
    frReport1.Free;
  end;
end;

procedure TMainForm.Label3Click(Sender: TObject);
begin
  ShellExecute(GetDesktopWindow, 'open', PChar(Label3.Caption), nil, nil, SW_SHOW);
end;

procedure TMainForm.ServGetVariables(const ReportName: String;
  Variables: TfrxVariables; User: String);
begin
  Variables['param1'] := QuotedStr('add new variable');
end;

end.
