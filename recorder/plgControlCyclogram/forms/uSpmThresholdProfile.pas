unit uSpmThresholdProfile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uProfile, StdCtrls, ExtCtrls, Grids,
  utrend, upage, uPoint,
  uComponentServises, uStringGridExt, uCommonTypes, ImgList, uChart;

type
  cBmp = class
    bmp:tbitmap;
    t: TPType;
  public
    constructor create;
    destructor destroy;
  end;

  TSpmThresholdProfileFrm = class(TForm)
    PanBottom: TPanel;
    PanAlClient: TPanel;
    GBleft: TGroupBox;
    ProfileSG: TStringGridExt;
    UnitsLabel: TLabel;
    UnitsCB: TComboBox;
    ProfileNameLabel: TLabel;
    ProfileNameEdit: TEdit;
    SGPic: TImageList;
    cChart1: cChart;
    procedure ProfileSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ProfileSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProfileSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ProfileSGDblClick(Sender: TObject);
    procedure cChart1Init(Sender: TObject);
  public
    // список кнопок с интерполяцией
    SGbuttons:tlist;
    m_r:integer;
    m_c:integer;
    m_prof:cProfile;
    m_tr: ctrend;
  private
    procedure init;
    procedure ClearSGButtons;
    procedure createSGBtn;
    function EmptyRow(sg: tstringgrid; r: integer): boolean;
    procedure TableToTrend;
    procedure showTrend;
  public
    constructor create(AOwner: TComponent); override;
    procedure edit(p:cProfile);
  end;

var
  SpmThresholdProfileFrm: TSpmThresholdProfileFrm;

const
  c_headerSize = 1;
  c_Col_N = 0;
  c_Col_X = 1;
  c_Col_P = 2;

implementation

{$R *.dfm}


procedure TSpmThresholdProfileFrm.cChart1Init(Sender: TObject);
begin
  m_tr:=cpage(cChart1.activePage).activeAxis.AddTrend;
end;

procedure TSpmThresholdProfileFrm.ClearSGButtons;
var
  btn: cbmp;
  i: integer;
begin
  for i := 0 to SGbuttons.Count - 1 do
  begin
    btn := cbmp(SGbuttons.Items[i]);
    btn.destroy;
  end;
  SGbuttons.clear;
end;


procedure TSpmThresholdProfileFrm.createSGBtn;
var
  btn: cbmp;
  row, i: integer;
begin
  if ProfileSG.RowCount < SGbuttons.Count then
  begin
    while ProfileSG.RowCount <> SGbuttons.Count do
    begin
      i := SGbuttons.Count - 1;
      btn := cbmp(SGbuttons.Items[i]);
      btn.destroy;
      SGbuttons.Delete(i);
    end;
  end;
  while SGbuttons.Count < ProfileSG.RowCount - 1 do
  begin
    row := SGbuttons.Count + 1;
    btn := cbmp.Create();
    ProfileSG.Objects[2, row] := btn;
    SGbuttons.Add(btn);
  end;
end;

constructor TSpmThresholdProfileFrm.create(AOwner: TComponent);
begin
  inherited;
  SGbuttons:=TList.Create;
  init;
end;

procedure TSpmThresholdProfileFrm.edit(p: cProfile);
var
  I: Integer;
  tp:TProfPoint;
begin
  m_prof:=p;
  profilesg.RowCount:=p.size+2;
  for I := 0 to p.size - 1 do
  begin
    tp:=p.m_data[i];
    profilesg.Cells[c_Col_N,i+1]:=inttostr(i+1);
    profilesg.Cells[c_Col_X,i+1]:=floattostr(tp.p.x);
    profilesg.Cells[c_Col_P,i+1]:=floattostr(tp.p.y);
  end;
  showmodal;
end;

function TSpmThresholdProfileFrm.EmptyRow(sg: tstringgrid; r: integer): boolean;
var
  I: Integer;
begin
  result:=true;
  for I := 0 to sg.ColCount - 1 do
  begin
    if sg.Cells[i, r]<>'' then
    begin
      result:=false;
      exit;
    end;
  end;
end;

procedure TSpmThresholdProfileFrm.init;
begin
  ProfileSG.RowCount:=2;
  ProfileSG.ColCount:=3;
  ProfileSG.Cells[c_Col_N, 0] :=  '№';
  ProfileSG.Cells[c_Col_X, 0] :=  'X';
  ProfileSG.Cells[c_Col_P, 0] :=  'Задание';
  SGChange(ProfileSG);
end;


procedure TSpmThresholdProfileFrm.showTrend;
var
  i:integer;
  p:cBeziePoint;
begin
  // отображаем тренд
  m_tr.Clear;
  for I := 0 to m_prof.m_size - 1 do
  begin
    p:=cBeziePoint.create;
    p.point.y:=m_curve.m_points[i].p.y;
    p.point.x:=m_curve.m_points[i].p.x;
    p.PType:=m_curve.m_points[i].ptype;
    m_tr.AddPoint(p);
  end;
  m_ax.AddChild(m_tr);
  m_page.Normalise;
  cChart1.redraw;
end;

procedure TSpmThresholdProfileFrm.ProfileSGDblClick(Sender: TObject);
var
  b:cbmp;
begin
  if m_c=2 then
  begin
    b:=cbmp(ProfileSG.Objects[m_c,m_r]);
    case b.t of
      ptNullPoly: b.t:=ptlinePoly;
      ptlinePoly: b.t:=ptNullPoly;
      ptCubePoly: b.t:=ptNullPoly;
    end;
    TableToTrend;
    showTrend;
  end;
end;

procedure TSpmThresholdProfileFrm.ProfileSGDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  bmp: cbmp;

  imageind, X, Y: integer;
begin
  if ARow < 1 then // headersize
    exit;
  if ACol = 2 then
  begin // Простое рисование
    ProfileSG.Canvas.FillRect(Rect);
    ProfileSG.Canvas.FillRect(Rect);
    bmp := cbmp(ProfileSG.Objects[ACol, ARow]);
    if bmp = nil then
      exit;
    case bmp.t of
      ptNullPoly:imageind:=2;
      ptlinePoly:imageind:=0;
      ptCubePoly:imageind:=1;
    end;
    bmp.bmp.Height := SGPic.Height;
    bmp.bmp.Width := SGPic.Width;
    bmp.bmp.Assign(nil);
    SGPic.GetBitmap(imageind, bmp.bmp);
    X := round((Rect.Left + Rect.Right - bmp.bmp.Width) / 2);
    Y := round((Rect.Top + Rect.Bottom - bmp.bmp.Height) / 2);
    ProfileSG.Canvas.Draw(X, Y, bmp.bmp);
  end;
end;

procedure TSpmThresholdProfileFrm.ProfileSGKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin

  end;
  if Key = VK_RETURN then
  begin
    if m_r=Profilesg.RowCount-1 then
    begin
      if not EmptyRow(Profilesg, m_r) then
      begin
        Profilesg.RowCount:=Profilesg.RowCount+1;
      end;
    end;
    TableToTrend;
    showTrend;
  end;
end;

procedure TSpmThresholdProfileFrm.ProfileSGSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  m_r:=ARow;
  m_c:=ACol;
end;

procedure TSpmThresholdProfileFrm.TableToTrend;
var
  I, c: Integer;
  p:TProfPoint;
  bmp:cbmp;
  b:boolean;
begin
  c:=0;
  m_prof.clear;
  for I := 1 to Profilesg.RowCount - 1 do
  begin
    if not EmptyRow(Profilesg,i) then
    begin
      inc(c);
      p.p.x:=strtofloat(Profilesg.Cells[1,i]);
      p.p.y:=strtofloat(Profilesg.Cells[2,i]);
      bmp:=cbmp(Profilesg.Objects[2,i]);
      p.t:=bmp.t;
      b:=false;
      if i=Profilesg.RowCount - 1 then
        b:=true;
      m_prof.AddP(p.p.x, p.p.y, p.t, b);
    end;
  end;
end;

{ cBmp }

constructor cBmp.create;
begin
  bmp:=TBitmap.Create;
  t:=ptlinePoly;
end;

destructor cBmp.destroy;
begin
  bmp.Destroy;
end;


end.
