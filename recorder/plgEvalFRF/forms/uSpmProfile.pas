unit uSpmProfile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uProfile, StdCtrls, ExtCtrls, Grids, math,
  utrend, upage, uPoint, mathfunction, uCommonMath,
  uComponentServises, uStringGridExt, uCommonTypes, ImgList, uChart, DCL_MYOWN;

type
  // картинки для отображения в Stringgrid
  cBmp = class
    bmp: tbitmap;
    t: TPType;
  public
    constructor create;
    destructor destroy;
  end;

  TSpmProfileFrm = class(TForm)
    PanBottom: TPanel;
    PanAlClient: TPanel;
    GBleft: TGroupBox;
    ProfileSG: TStringGridExt;
    UnitsLabel: TLabel;
    UnitsCB: TComboBox;
    ProfileNameLabel: TLabel;
    ProfileNameEdit: TEdit;
    SGPic: TImageList;
    ApplyBtn: TButton;
    Splitter1: TSplitter;
    cChart1: cChart;
    HLabel: TLabel;
    HFE: TFloatEdit;
    HHLabel: TLabel;
    HHFE: TFloatEdit;
    EmergencyLabel: TLabel;
    EmergencyFE: TFloatEdit;
    procedure ProfileSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ProfileSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProfileSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ProfileSGDblClick(Sender: TObject);
    procedure cChart1Init(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    // список кнопок с интерполяцией
    SGbuttons: tlist;
    m_r: Integer;
    m_c: Integer;
    m_prof: cProfile;
    m_tProf: ctrend;
  private
    procedure init;
    procedure ClearSGButtons;
    procedure createSGBtn;
    function EvalLevel(v, threshold: double): double;
    function EmptyRow(sg: tstringgrid; r: Integer): Boolean;
    procedure TableToProf;
    procedure showTrend;
  public
    constructor create(AOwner: TComponent); override;
    procedure edit(p: cProfile);
  end;

var
  SpmProfileFrm: TSpmProfileFrm;

const
  c_headerSize = 1;
  c_Col_N = 0;
  c_Col_X = 1;
  c_Col_P = 2;
  c_Col_Bmp = 3;

implementation

{$R *.dfm}

procedure TSpmProfileFrm.ApplyBtnClick(Sender: TObject);
var
  I: Integer;
  l: cProfileLine;
begin
  m_prof.m_LineUnits := IntToTUnits(UnitsCB.ItemIndex);

  l := cProfileLine(m_prof.childs.Items[0]);
  l.m_ref := HFE.FloatNum;

  showTrend;
end;

procedure TSpmProfileFrm.cChart1Init(Sender: TObject);
begin
  m_tProf := cpage(cChart1.activePage).activeAxis.AddTrend;
  m_tProf.color := green;

  showTrend;
end;

procedure TSpmProfileFrm.ClearSGButtons;
var
  btn: cBmp;
  I: Integer;
begin
  for I := 0 to SGbuttons.Count - 1 do
  begin
    btn := cBmp(SGbuttons.Items[I]);
    btn.destroy;
  end;
  SGbuttons.clear;
end;

procedure TSpmProfileFrm.createSGBtn;
var
  btn: cBmp;
  row, I: Integer;
begin
  if ProfileSG.RowCount < SGbuttons.Count then
  begin
    while ProfileSG.RowCount <> SGbuttons.Count do
    begin
      I := SGbuttons.Count - 1;
      btn := cBmp(SGbuttons.Items[I]);
      btn.destroy;
      SGbuttons.Delete(I);
    end;
  end;
  while SGbuttons.Count < ProfileSG.RowCount - 1 do
  begin
    row := SGbuttons.Count + 1;
    btn := cBmp.create();
    ProfileSG.Objects[c_Col_Bmp, row] := btn;
    SGbuttons.Add(btn);
  end;
end;

constructor TSpmProfileFrm.create(AOwner: TComponent);
begin
  inherited;
  SGbuttons := tlist.create;
  init;
end;

procedure TSpmProfileFrm.edit(p: cProfile);
var
  I: Integer;
  tp: TProfPoint;
  bmp:cBmp;
begin
  m_prof := p;
  ProfileSG.RowCount := p.size + 2;
  for I := 0 to p.size - 1 do
  begin
    tp := p.m_data[I];
    ProfileSG.Cells[c_Col_N, I + 1] := inttostr(I + 1);
    ProfileSG.Cells[c_Col_X, I + 1] := floattostr(tp.p.x);
    ProfileSG.Cells[c_Col_P, I + 1] := floattostr(tp.p.y);
    bmp:=cbmp(Profilesg.Objects[c_Col_Bmp,i+1]);
    if bmp=nil then
    begin
      bmp := cbmp.Create();
      ProfileSG.Objects[c_Col_Bmp, i+1] := bmp;
      SGbuttons.Add(bmp);
      bmp.t:=tp.t;
    end;
  end;
  SGChange(ProfileSG);
  ProfileSG.ColWidths[c_Col_Bmp] := 60;
  showTrend;
  show;
end;

function TSpmProfileFrm.EmptyRow(sg: tstringgrid; r: Integer): Boolean;
var
  I: Integer;
begin
  result := true;
  for I := 0 to sg.ColCount - 1 do
  begin
    if sg.Cells[I, r] <> '' then
    begin
      result := false;
      exit;
    end;
  end;
end;

function TSpmProfileFrm.EvalLevel(v, threshold: double): double;
begin
  case UnitsCB.ItemIndex of
    // %
    0:
      begin
        result := v * threshold;
      end;
    // Дб, SweepSinus 10Log(...)
    1:
      begin
        result := threshold * (Power(10, v / 10));
      end;
    // Дб, ШСВ 20Log(...)
    2:
      begin
        result := threshold * (Power(10, v / 20));
      end;
    // Абс. (отклонение)
    3:
      begin
        result := threshold;
      end;
  end;
end;

procedure TSpmProfileFrm.FormShow(Sender: TObject);
begin
  cChart1.Realign;
  cChart1.Width := PanAlClient.Width - GBleft.Width;
  Realign;
end;

procedure TSpmProfileFrm.init;
begin
  UnitsCB.ItemIndex := 0;

  ProfileSG.RowCount := 2;
  ProfileSG.ColCount := 4;
  ProfileSG.Cells[c_Col_N, 0] := '№';
  ProfileSG.Cells[c_Col_X, 0] := 'X';
  ProfileSG.Cells[c_Col_P, 0] := 'Задание';
  SGChange(ProfileSG);
  ProfileSG.ColWidths[c_Col_Bmp] := 60;
end;

procedure TSpmProfileFrm.showTrend;
var
  I: Integer;
  p: cBeziePoint;
begin
  if m_prof=nil then exit;
  
  if m_tProf<>nil then
  begin
    // отображаем тренд
    m_tProf.clear;
    for I := 0 to m_prof.size - 1 do
    begin
      p := cBeziePoint.create;
      p.point.y := m_prof.m_data[I].p.y;
      p.point.x := m_prof.m_data[I].p.x;
      p.PType := m_prof.m_data[I].t;
      m_tProf.AddPoint(p);
    end;
    if cChart1 <> nil then
    begin
      cpage(cChart1.activePage).Normalise;
      cChart1.redraw;
    end;
  end;
end;

procedure TSpmProfileFrm.ProfileSGDblClick(Sender: TObject);
var
  b: cBmp;
begin
  if m_c = c_Col_Bmp then
  begin
    b := cBmp(ProfileSG.Objects[m_c, m_r]);
    case b.t of
      ptNullPoly:
        begin
          b.t := ptlinePoly;
          m_prof.m_data[m_r - 1].t := ptlinePoly;
        end;
      ptlinePoly:
        begin
          b.t := ptNullPoly;
          m_prof.m_data[m_r - 1].t := ptNullPoly;
        end;
      ptCubePoly:
        begin
          b.t := ptNullPoly;
          m_prof.m_data[m_r - 1].t := ptNullPoly;
        end;
    end;
    TableToProf;
    showTrend;
  end;
end;

procedure TSpmProfileFrm.ProfileSGDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  bmp: cBmp;

  imageind, x, y: Integer;
begin
  if ARow < 1 then // headersize
    exit;
  if ACol = c_Col_Bmp then
  begin // Простое рисование
    ProfileSG.Canvas.FillRect(Rect);
    ProfileSG.Canvas.FillRect(Rect);
    bmp := cBmp(ProfileSG.Objects[ACol, ARow]);
    if bmp = nil then
      exit;
    case bmp.t of
      ptNullPoly:
        imageind := 2;
      ptlinePoly:
        imageind := 0;
      ptCubePoly:
        imageind := 1;
    end;
    bmp.bmp.Height := SGPic.Height;
    bmp.bmp.Width := SGPic.Width;
    bmp.bmp.Assign(nil);
    SGPic.GetBitmap(imageind, bmp.bmp);
    x := round((Rect.Left + Rect.Right - bmp.bmp.Width) / 2);
    y := round((Rect.Top + Rect.Bottom - bmp.bmp.Height) / 2);
    ProfileSG.Canvas.Draw(x, y, bmp.bmp);
  end;
end;

procedure TSpmProfileFrm.ProfileSGKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin

  end;
  if Key = VK_RETURN then
  begin
    if m_r = ProfileSG.RowCount - 1 then
    begin
      if not EmptyRow(ProfileSG, m_r) then
      begin
        ProfileSG.RowCount := ProfileSG.RowCount + 1;

      end;
    end;
    SGChange(ProfileSG);
    ProfileSG.ColWidths[c_Col_Bmp] := 60;
    TableToProf;
    showTrend;
  end;
end;

procedure TSpmProfileFrm.ProfileSGSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  m_r := ARow;
  m_c := ACol;
end;

procedure TSpmProfileFrm.TableToProf;
var
  I, c: Integer;
  p: TProfPoint;
  bmp: cBmp;
  b: Boolean;
begin
  c := 0;
  m_prof.clear;
  for I := 1 to ProfileSG.RowCount - 1 do
  begin
    if not EmptyRow(ProfileSG, I) then
    begin
      inc(c);
      p.p.x := strtofloatext(ProfileSG.Cells[c_Col_X, I]);
      p.p.y := strtofloatext(ProfileSG.Cells[c_Col_P, I]);
      bmp := cBmp(ProfileSG.Objects[c_Col_Bmp, I]);
      if bmp = nil then
      begin
        bmp := cBmp.create();
        ProfileSG.Objects[c_Col_Bmp, I] := bmp;
        SGbuttons.Add(bmp);
      end;
      p.t := bmp.t;
      b := false;
      if I = ProfileSG.RowCount - 1 then
        b := true;
      m_prof.AddP(p.p.x, p.p.y, p.t, b);
    end;
  end;
end;

{ cBmp }

constructor cBmp.create;
begin
  bmp := tbitmap.create;
  t := ptlinePoly;
end;

destructor cBmp.destroy;
begin
  bmp.destroy;
end;

end.
