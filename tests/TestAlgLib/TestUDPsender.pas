unit TestUDPsender;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uCommonMath, MathFunction, uCommonTypes, uobject,
  uMnk,
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
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    x1e: TFloatSpinEdit;
    x2e: TFloatSpinEdit;
    x3e: TFloatSpinEdit;
    y1e: TFloatSpinEdit;
    y2e: TFloatSpinEdit;
    y3e: TFloatSpinEdit;
    z1e: TFloatSpinEdit;
    z2e: TFloatSpinEdit;
    z3e: TFloatSpinEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    CalX1: TFloatSpinEdit;
    CalX2: TFloatSpinEdit;
    CalX3: TFloatSpinEdit;
    CalY1: TFloatSpinEdit;
    CalY2: TFloatSpinEdit;
    CalY3: TFloatSpinEdit;
    CalZ1: TFloatSpinEdit;
    CalZ2: TFloatSpinEdit;
    CalZ3: TFloatSpinEdit;
    BuildMatrix: TButton;
    Test_x: TFloatSpinEdit;
    Test_y: TFloatSpinEdit;
    Test_z: TFloatSpinEdit;
    out_x: TFloatSpinEdit;
    out_y: TFloatSpinEdit;
    out_z: TFloatSpinEdit;
    TestBtn: TButton;
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
    procedure BuildMatrixClick(Sender: TObject);
    procedure TestBtnClick(Sender: TObject);
  private
    fplay, ffirstval, Mexists: boolean;
    // ������ ������
    fcycle: cardinal;
    fSrvPort: cardinal;
    fClientPort: cardinal;
    // ��������������� ���� (���������� m_x, m_y, m_z)
    fx0, fy0, fz0,
    // �������� � ����� (����)
    fx, fy, fz,
    // ����� ����������������� ����������
    m_x, m_y, m_z: integer;
    m_shape: cobject;
    m_starttm: MatrixGl;
    fdatagram, fOutBuff: TBytes;
    // ������� �������� ������
    m, invM, in_m, out_m, cal_m:d2array;
  public
    procedure GetColumn(c:integer);
    procedure resetfirstVal;
    function GetX: double;
    function GetY: double;
    function GetZ: double;
    procedure ShowCodes;
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
  GetColumn(0);
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
  GetColumn(1);
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
  GetColumn(2);
end;

procedure TTestUDPSenderFrm.BuildMatrixClick(Sender: TObject);
var
  tm:d2array;
begin
  m[0][0]:=x1e.Value;
  m[0][1]:=x2e.Value;
  m[0][2]:=x3e.Value;
  m[1][0]:=y1e.Value;
  m[1][1]:=y2e.Value;
  m[1][2]:=y3e.Value;
  m[2][0]:=z1e.Value;
  m[2][1]:=z2e.Value;
  m[2][2]:=z3e.Value;
  invm:=Invers(m);
  cal_m[0][0]:=90;
  cal_m[0][1]:=0;

  cal_m[0][2]:=0;

  cal_m[1][0]:=0;
  cal_m[1][1]:=90;
  cal_m[1][2]:=0;

  cal_m[2][0]:=0;
  cal_m[2][1]:=0;
  cal_m[2][2]:=90;
  MultMatrix(invm, cal_m,   invm);

  CalX1.Value:=invm[0][0];
  CalX2.Value:=invm[0][1];
  CalX3.Value:=invm[0][2];
  CalY1.Value:=invm[1][0];
  CalY2.Value:=invm[1][1];
  CalY3.Value:=invm[1][2];
  CalZ1.Value:=invm[2][0];
  CalZ2.Value:=invm[2][1];
  CalZ3.Value:=invm[2][2];
  MultMatrix(m, invm, tm);
  Mexists:=true;
end;

procedure TTestUDPSenderFrm.TestBtnClick(Sender: TObject);
var
  outm:d2array;
begin

  in_m[0][0]:=test_x.Value;
  in_m[1][0]:=test_y.Value;
  in_m[2][0]:=test_z.Value;
  MultMatrix(in_m, invm, outm);
  out_x.Value:=outm[0][0];
  out_y.Value:=outm[1][0];
  out_z.Value:=outm[2][0];
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

constructor TTestUDPSenderFrm.create(aowner: tcomponent);
begin
  inherited;
  setlength(m,3,3);
  setlength(invM,3,3);
  setlength(cal_M,3,3);
  setlength(in_m,3,1);
  Mexists:=false;
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
  // ������ ������ �������
  fcycle := 100;
  ViewUpdateTimer.Interval := fcycle;
  ViewUpdateTimer.Enabled := false;
  // ��������� ����������� � ESP
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

  KxcalibrE.Value := 0;
  kyCalibrE.Value := -0.0884086444007859;
  kzCalibrE.Value := 0.117955439056356;

  // ��������� �����������
  IdUDPServer1.BroadcastEnabled := true;
  IdUDPServer1.DefaultPort := fClientPort;
  IdUDPServer1.Active := true;
  // UDPClient ���������� ������
  IdUDPClient1.BroadcastEnabled := true;
  IdUDPClient1.Host := c_broadcast;
  IdUDPClient1.port := fSrvPort;

  // ������������
  cBaseGlComponent1.resources :='F:\Oburec\delphi\2011\OburecGH\3d\files\resources.ini';
  //str:='c:\Users\SkripnikAA\Documents\3ds Max 2020\export\1.OBR';
  str:='e:\Users\SkripnikAA\Documents\3ds Max 2020\export\4.OBR';
  //cbaseglcomponent1.scenename:='f:\Oburec\delphi\2011\OburecGH\3d\files\3d\Meshes\Type_001.OBR';
  cBaseGlComponent1.scenename := str;
end;

procedure TTestUDPSenderFrm.StartBtnClick(Sender: TObject);
begin
  if not fplay then
  begin
    ViewUpdateTimer.Enabled := true;
    fplay := true;
    // �����
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
    // ����
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
  else // ���������������� ����������
  begin
    m_x := round((1 - c_exp) * fx + c_exp * m_x);
    m_y := round((1 - c_exp) * fy + c_exp * m_y);
    m_z := round((1 - c_exp) * fz + c_exp * m_z);
  end;

  if Mexists then
  begin
    Test_x.Value:=m_x;
    Test_y.Value:=m_y;
    Test_z.Value:=m_z;
    TestBtnClick(nil);
  end;
end;

procedure TTestUDPSenderFrm.resetfirstVal;
begin
  ffirstval := true;
end;

procedure TTestUDPSenderFrm.GetColumn(c: integer);
begin
  case c of
    0:
    begin
      x1e.Value:=m_x;
      x2e.Value:=m_y;
      x3e.Value:=m_z;
    end;
    1:
    begin
      y1e.Value:=m_x;
      y2e.Value:=m_y;
      y3e.Value:=m_z;
    end;
    2:
    begin
      z1e.Value:=m_x;
      z2e.Value:=m_y;
      z3e.Value:=m_z;
    end;
  end;
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
