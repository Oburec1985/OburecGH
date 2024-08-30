unit TestUDPsender;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uCommonMath, MathFunction, uCommonTypes, uobject,
  IdUDPClient, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer, IdSocketHandle, uSpin, uBaseGlComponent;

type
  TTestUDPSenderFrm = class(TForm)
    Xedit: TEdit;
    Label1: TLabel;
    YEdit: TEdit;
    Label2: TLabel;
    ZEdit: TEdit;
    Label3: TLabel;
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
    cBaseGlComponent1: cBaseGlComponent;
    CheckBox1: TCheckBox;
    HiEdit: TEdit;
    LoEdit: TEdit;
    Edit3: TEdit;
    b1e: TEdit;
    b2E: TEdit;
    b4e: TEdit;
    b3e: TEdit;
    b1re: TEdit;
    b2re: TEdit;
    RevBitsCB: TCheckBox;
    RevByteCB: TCheckBox;
    procedure StartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BalanceBtnClick(Sender: TObject);
    procedure xCalibrBtnClick(Sender: TObject);
    procedure ViewUpdateTimerTimer(Sender: TObject);
    procedure yCalibrBtnClick(Sender: TObject);
    procedure zCalibrBtnClick(Sender: TObject);
    procedure cBaseGlComponent1InitScene(Sender: TObject);
    procedure XeditChange(Sender: TObject);
    procedure LoEditChange(Sender: TObject);
  private
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
    m_shape: cobject;
    m_starttm: MatrixGl;
    fdatagram, fOutBuff: TBytes;
  public
    procedure resetfirstVal;
    function GetX: double;
    function GetY: double;
    function GetZ: double;
    procedure ShowCodes;
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

procedure TTestUDPSenderFrm.XeditChange(Sender: TObject);
var
  ang: point3;
begin
  exit;
  if checkstr(Xedit.text) then
    ang.x := strtofloat(Xedit.text);
  if checkstr(YEdit.text) then
    ang.y := strtofloat(YEdit.text);
  if checkstr(ZEdit.text) then
    ang.z := strtofloat(ZEdit.text);
  m_shape.nodetm := m_starttm;
  m_shape.RotateNodeInLocalNodeWorld(ang);
  cBaseGlComponent1.Invalidate;
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

procedure TTestUDPSenderFrm.cBaseGlComponent1InitScene(Sender: TObject);
var
  p: point3;
  ax, ang: point3;
begin
  cBaseGlComponent1.mUI.Zoom;
  p := cBaseGlComponent1.mUI.m_RenderScene.activecamera.position;
  p.y := cBaseGlComponent1.mUI.m_RenderScene.activecamera.position.y + 40;
  cBaseGlComponent1.mUI.m_RenderScene.activecamera.position := p;
  ax.x := 0;
  ax.y := 1;
  ax.z := 0;
  cBaseGlComponent1.mUI.m_RenderScene.activecamera.rotateAroundTarget
    (identMatrix4, ax, 60);

  //m_shape:=cobject(cbaseglcomponent1.mUI.scene.getobj('Line001'));
  m_shape:=cobject(cbaseglcomponent1.mUI.scene.getobj('Circle002'));
  //m_shape := cobject(cBaseGlComponent1.mUI.scene.getobj(0));
  if m_shape<>nil then
  begin
    m_starttm := m_shape.nodetm;
    cBaseGlComponent1.mUI.m_RenderScene.activecamera.target:=m_shape.Node;
    cBaseGlComponent1.mUI.m_RenderScene.activecamera.MoveNodeInLocalNodeWorld(0,20,70);
  end;
end;

destructor TTestUDPSenderFrm.destroy;
begin
  exit;
  inherited;
end;

procedure TTestUDPSenderFrm.LoEditChange(Sender: TObject);
var
  p:array [0..1] of byte;
  i:SmallInt;
  str:string;
  b:byte;
  ex:boolean;
begin
  ex:=true;
  if CheckHex(loedit.text) then
  begin
    if CheckHex(hiedit.text) then
    begin
      ex:=false;
    end;
  end;
  if ex then
    exit;
  if (length(loedit.text)=2) and (length(hiedit.text)=2) then
  begin
    p[0]:=strtoint('$'+loedit.Text);
    p[1]:=strtoint('$'+hiedit.Text);
    move(p[0],i, 2);
    Edit3.text:=IntToStr(i);


    b:=strtoint('$'+loedit.Text);
    str:=bytetoBinStr(b);
    b2e.text:=Copy(str, 5, 4);
    b1e.text:=Copy(str, 1, 4);

    b:=ReverseBits(b);
    str:=bytetoBinStr(b);
    b2re.text:=Copy(str, 5, 4);
    b1re.text:=Copy(str, 1, 4);


    b:=strtoint('$'+hiedit.Text);
    str:=bytetoBinStr(b);
    b4e.text:=Copy(str, 5, 4);
    b3e.text:=Copy(str, 1, 4);
  end;
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
  KxcalibrE.Value := 1;
  kyCalibrE.Value := 1;
  kzCalibrE.Value := 1;
  // Настройка считывателя
  IdUDPServer1.BroadcastEnabled := true;
  IdUDPServer1.DefaultPort := fClientPort;
  IdUDPServer1.Active := true;
  // UDPClient отправляет пакеты
  IdUDPClient1.BroadcastEnabled := true;
  IdUDPClient1.Host := c_broadcast;
  IdUDPClient1.port := fSrvPort;

  // визуализация
  cBaseGlComponent1.resources :='F:\Oburec\delphi\2011\OburecGH\3d\files\resources.ini';
  //str:='c:\Users\SkripnikAA\Documents\3ds Max 2020\export\1.OBR';
  str:='e:\Users\SkripnikAA\Documents\3ds Max 2020\export\1.OBR';
  //cbaseglcomponent1.scenename:='f:\Oburec\delphi\2011\OburecGH\3d\files\3d\Meshes\Type_001.OBR';
  cBaseGlComponent1.scenename := str;
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
  ShowCodes;
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
    m_x := fx;
    m_y := fy;
    m_z := fz;
  end
  else // экспоненциальное усреднение
  begin
    m_x := round((1 - c_exp) * fx + c_exp * m_x);
    m_y := round((1 - c_exp) * fy + c_exp * m_y);
    m_z := round((1 - c_exp) * fz + c_exp * m_z);
  end;
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

procedure TTestUDPSenderFrm.ShowCodes;
var
  ang: point3;
begin
  ang.x := GetX;
  ang.y := GetY;
  ang.z := GetZ;
  Xedit.text := formatstrNoE(ang.x, 4);
  YEdit.text := formatstrNoE(ang.y, 4);
  ZEdit.text := formatstrNoE(ang.z, 4);

  if CheckBox1.Checked then
  begin
    m_shape.nodetm := m_starttm;
    m_shape.RotateNodeInLocalNodeWorld(ang);
    cBaseGlComponent1.Invalidate;
  end;
end;

end.
