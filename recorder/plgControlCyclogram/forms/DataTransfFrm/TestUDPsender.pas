unit TestUDPsender;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uCommonMath, MathFunction, uCommonTypes, uobject,
  uMnk,
  IdUDPClient, IdBaseComponent, IdComponent, uRCFunc,
  IdUDPBase, IdUDPServer, IdSocketHandle, uSpin;

type
  TTestUDPSenderFrm = class(TForm)
    StartBtn: TButton;
    StopBtn: TButton;
    IdUDPServer1: TIdUDPServer;
    IdUDPClient1: TIdUDPClient;
    ViewUpdateTimer: TTimer;
    BalanceBtn: TButton;
    xCalibrBtn: TButton;
    XcalibrE: TEdit;
    XcalibrLabel: TLabel;
    KxLabel: TLabel;
    KyLabel: TLabel;
    KzLabel: TLabel;
    KxcalibrE: TFloatSpinEdit;
    kyCalibrE: TFloatSpinEdit;
    kzCalibrE: TFloatSpinEdit;
    yCalibrBtn: TButton;
    zCalibrBtn: TButton;
    RevBitsCB: TCheckBox;
    RevByteCB: TCheckBox;
    CheckBox1: TCheckBox;
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BalanceBtnClick(Sender: TObject);
    procedure xCalibrBtnClick(Sender: TObject);
    procedure yCalibrBtnClick(Sender: TObject);
    procedure zCalibrBtnClick(Sender: TObject);
    procedure IdUDPClient1Connected(Sender: TObject);
    procedure ViewUpdateTimerTimer(Sender: TObject);
  private
    finit, fneedupdate:boolean;
    fplay, ffirstval: boolean;
    // период работы
    fcycle: cardinal;
    fSrvPort: cardinal;
    fClientPort: cardinal;
    // балансировочные коды (запоминаем m_x, m_y, m_z)
    fx0, fy0, fz0,
    // получено с платы (коды)
    fx, fy, fz,
    // после экспоненциального усреднения
    m_x, m_y, m_z: integer;
    m_ang:point3d;
    fdatagram, fOutBuff: TBytes;
    m_xTag, m_yTag, m_zTag:ctag;
    mainThread, uThread:cardinal;
  protected
  public
    procedure loadtags;
    procedure createtags;
    procedure PushTags;
    procedure doRCinit;
    procedure resetfirstVal;
    function GetX: double;
    function GetY: double;
    function GetZ: double;
    procedure initUDP;
    procedure doRCStart;
    procedure doRCStop;
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

var
  TestUDPSenderFrm: TTestUDPSenderFrm;

const
  c_exp = 0.95;
  c_SrvPort = 33444;
  c_ClientPort = 44555;
  c_broadcast = '255.255.255.255';

implementation
uses
  PluginClass;

{$R *.dfm}

procedure TTestUDPSenderFrm.BalanceBtnClick(Sender: TObject);
begin
  resetfirstVal;
  fx0 := fx;
  fy0 := fy;
  fz0 := fz;
end;

procedure TTestUDPSenderFrm.xCalibrBtnClick(Sender: TObject);
var
  lk, xDouble: double;
  max, ax, i: integer;
begin
  resetfirstVal;
  xDouble := strtofloat(XcalibrE.text);
  ax := m_x - fx0;
  lk := xDouble / ax;
  KxcalibrE.Value := lk;
end;


procedure TTestUDPSenderFrm.yCalibrBtnClick(Sender: TObject);
var
  lk, xDouble: double;
  max, ax, i: integer;
begin
  resetfirstVal;
  xDouble := strtofloat(XcalibrE.text);
  ax := m_y - fy0;
  lk := xDouble / ax;
  kyCalibrE.Value := lk;
end;

procedure TTestUDPSenderFrm.zCalibrBtnClick(Sender: TObject);
var
  lk, xDouble: double;
  max, ax, i: integer;
begin
  resetfirstVal;
  xDouble := strtofloat(XcalibrE.text);
  ax := m_z - fz0;
  lk := xDouble / ax;
  kzCalibrE.Value := lk;
end;


constructor TTestUDPSenderFrm.create(aowner: tcomponent);
begin
  inherited;
  m_xTag:=cTag.create;
  m_yTag:=cTag.create;
  m_zTag:=cTag.create;

  mainThread:=GetCurrentThreadId;
  finit:=false;
end;

procedure TTestUDPSenderFrm.createtags;
begin
  loadtags;
  if m_xTag.tag=nil then
  begin
    m_xTag.tag:=CreateStateTag('xRotTag', nil);
    m_xTag.tag.CfgWritable(true);
  end;
  if m_yTag.tag=nil then
  begin
    m_yTag.tag:=CreateStateTag('yRotTag', nil);
    m_yTag.tag.CfgWritable(true);
  end;
  if m_zTag.tag=nil then
  begin
    m_zTag.tag:=CreateStateTag('zRotTag', nil);
    m_zTag.tag.CfgWritable(true);
  end;
end;

procedure TTestUDPSenderFrm.loadtags;
begin
  m_xTag.tag:=getTagByName('xRotTag');
  m_yTag.tag:=getTagByName('yRotTag');
  m_zTag.tag:=getTagByName('zRotTag');
end;

procedure TTestUDPSenderFrm.PushTags;
begin
  if RStatePlay then
  begin
    if fneedupdate then
    begin
      m_xTag.tag.PushValue(m_ang.x, -1);
      m_yTag.tag.PushValue(m_ang.y, -1);
      m_zTag.tag.PushValue(m_ang.z, -1);
      fneedupdate:=false;
    end;
  end;
end;

destructor TTestUDPSenderFrm.destroy;
begin
  exit;
  m_xTag.destroy;
  m_yTag.destroy;
  m_zTag.destroy;
  inherited;
end;

procedure TTestUDPSenderFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  IdUDPServer1.Active := false;
end;

procedure TTestUDPSenderFrm.FormCreate(Sender: TObject);
var
  p: point3;
  str:string;
begin
  fneedupdate:=false;
  setlength(fOutBuff, 6);
  setlength(fdatagram, 3);
  // период работы сервера
  fcycle := 100;
  ViewUpdateTimer.Interval := fcycle;
  ViewUpdateTimer.Enabled := false;
  // настройки подключения к ESP
  fSrvPort := c_SrvPort;
  fClientPort := c_ClientPort;
  fplay := false;
  ffirstval := true;
  fx0 := 0;
  fy0 := 0;
  fz0 := 0;
  KxcalibrE.Value := 0;
  kyCalibrE.Value := -0.0884086444007859;
  kzCalibrE.Value := 0.117955439056356;

end;

procedure TTestUDPSenderFrm.StartBtnClick(Sender: TObject);
begin
  if not fplay then
  begin
    ViewUpdateTimer.Enabled := true;
    fplay := true;
    // Старт
    fdatagram[0] := $AB;
    fdatagram[1] := $CD;
    fdatagram[2] := $EF;
    IdUDPClient1.Broadcast(fdatagram, fSrvPort);
    ffirstval:=true;
  end;
end;

procedure TTestUDPSenderFrm.StopBtnClick(Sender: TObject);
begin
  if fplay then
  begin
    fplay := false;
    // Стоп
    fdatagram[0] := $AA;
    fdatagram[1] := $BB;
    fdatagram[2] := $CC;
    IdUDPClient1.Broadcast(fdatagram, fSrvPort);
  end;
end;

procedure TTestUDPSenderFrm.ViewUpdateTimerTimer(Sender: TObject);
begin
  PushTags;
end;

procedure TTestUDPSenderFrm.IdUDPClient1Connected(Sender: TObject);
begin
  CheckBox1.Checked:=true;
end;

procedure TTestUDPSenderFrm.IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
  AData: TBytes; ABinding: TIdSocketHandle);
var
  p:array [0..1] of byte;
  b:byte;
  i:smallint;
begin
  // x
  p[0]:=AData[0];
  p[1] := AData[1];
  if RevByteCB.Checked then
  begin
    b := p[1];
    p[0]:=b;
    p[1] := p[0];
  end;
  if RevBitsCB.Checked then
  begin
    b:=ReverseBits(p[1]);
    p[1]:=b;
    p[0]:=ReverseBits(p[0]);
  end;
  move(p[0],i,2);
  fx:=i;
  // y
  p[0]:=AData[2];
  p[1] := AData[3];
  if RevByteCB.Checked then
  begin
    b := p[1];
    p[0]:=b;
    p[1] := p[0];
  end;
  if RevBitsCB.Checked then
  begin
    b:=ReverseBits(p[1]);
    p[1]:=b;
    p[0]:=ReverseBits(p[0]);
  end;
  move(p[0],i,2);
  fy:=i;
  // z
  p[0]:=AData[4];
  p[1] := AData[5];
  if RevByteCB.Checked then
  begin
    b := p[1];
    p[0]:=b;
    p[1] := p[0];
  end;
  if RevBitsCB.Checked then
  begin
    b:=ReverseBits(p[1]);
    p[1]:=b;
    p[0]:=ReverseBits(p[0]);
  end;
  move(p[0],i,2);
  fz:=i;

  if ffirstval then
  begin
    ffirstval := false;
    fx0 := fx;
    fy0 := fy;
    fz0 := fz;

    m_x := 0;
    m_y := 0;
    m_z := 0;
  end
  else // экспоненциальное усреднение
  begin
    m_x := round((1 - c_exp) * fx + c_exp * m_x);
    m_y := round((1 - c_exp) * fy + c_exp * m_y);
    m_z := round((1 - c_exp) * fz + c_exp * m_z);
  end;

  m_ang.x := GetX;
  m_ang.y := GetY;
  m_ang.z := GetZ;
  fneedupdate:=true;
end;

procedure TTestUDPSenderFrm.initUDP;
begin
  if not finit then
  begin
    uThread:=GetCurrentThreadId;
    // Настройка считывателя
    IdUDPServer1.BroadcastEnabled := true;
    IdUDPServer1.DefaultPort := fClientPort;
    IdUDPServer1.Active := true;
    //IdUDPServer1.OnUDPRead:= IdUDPServer1UDPRead;
    // UDPClient отправляет пакеты
    IdUDPClient1.BroadcastEnabled := true;
    IdUDPClient1.Host := c_broadcast;
    IdUDPClient1.port := fSrvPort;
    finit:=true;
  end;
  caption:='MainThread='+inttostr( mainThread)+' CurThread='+inttostr( uThread);
end;

procedure TTestUDPSenderFrm.doRCinit;
begin
  createtags;
  initudp;
end;

procedure TTestUDPSenderFrm.doRCStart;
begin
  // Настройка считывателя
  StartBtnClick(nil);
end;

procedure TTestUDPSenderFrm.doRCStop;
begin
  StopBtnClick(nil);
end;

procedure TTestUDPSenderFrm.resetfirstVal;
begin
  ffirstval := true;
end;


function TTestUDPSenderFrm.GetX: double;
begin
  result := (m_x - fx0) * KxcalibrE.Value;
end;

function TTestUDPSenderFrm.GetY: double;
begin
  result := (m_y - fy0) * kyCalibrE.Value;
end;

function TTestUDPSenderFrm.GetZ: double;
begin
  result := (m_z - fz0) * kzCalibrE.Value;
end;


end.
