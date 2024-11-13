unit uEditCurveFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, uChart, StdCtrls,
  upoint,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView,
  ucommontypes, utrend, uaxis, upage, uHardwareMath, uspm,
  ucommonmath, ImgList;


type

  // функционал для редактирования АЧХ
  TCurvePoint = record
    p:point2d;
    ptype:TPType;
  end;

  cCurve = class
  public
    m_points:array of TCurvePoint;
    m_capacity:integer;
    m_size:integer;
    // данные для калибровки АЧХ.
    m_ScaleData:PAlignDarray;
  protected

  public
    // выделить память под результат. m_ScaleData  -хранится в
    // окне класса cSpm - коррекция АЧХ CorrAFHar: TAlignDarray;
    procedure getMemScaleData(len:integer);
    constructor create;
  end;

  TEditCurveFrm = class(TForm)
    CurveSG: TStringGrid;
    Splitter1: TSplitter;
    cChart1: cChart;
    BottomPanel: TPanel;
    OkBtn: TButton;
    SGPic: TImageList;

    procedure FormCreate(Sender: TObject);
    procedure CurveSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  public
    // список кнопок с интерполяцией
    SGbuttons:tlist;
  private
    m_curve:ccurve;
    m_tr:ctrend;
    m_page:cpage;
    m_ax:caxis;
  private
    procedure init;
    procedure ClearSGButtons;
  public
    procedure editCurve(p_curve:cCurve);
  end;

var
  EditCurveFrm: TEditCurveFrm;

implementation

{$R *.dfm}

{ TEditCurveFrm }

procedure TEditCurveFrm.CurveSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  bmp: Tbitmap;
  imageind, X, Y: integer;
begin
  if ARow < 1 then // headersize
    exit;
  if ACol = 2 then
  begin // Простое рисование
    CurveSG.Canvas.FillRect(Rect);
    case m_curve.m_points[ARow-1].ptype of
      ptNullPoly:imageind:=2;
      ptlinePoly:imageind:=0;
      ptCubePoly:imageind:=1;
    end;
    CurveSG.Canvas.FillRect(Rect);
    bmp := Tbitmap(CurveSG.Objects[ACol, ARow]);
    if bmp = nil then
      exit;
    bmp.Height := SGPic.Height;
    bmp.Width := SGPic.Width;
    bmp.Assign(nil);
    SGPic.GetBitmap(imageind, bmp);
    X := round((Rect.Left + Rect.Right - bmp.Width) / 2);
    Y := round((Rect.Top + Rect.Bottom - bmp.Height) / 2);
    CurveSG.Canvas.Draw(X, Y, bmp);
  end;
end;

procedure TEditCurveFrm.editCurve(p_curve: cCurve);
var
  I: Integer;
  p:cBeziePoint;
begin
  m_curve:=p_curve;
  m_tr.Clear;
  if p_curve<>nil then
  begin
    // отображаем тренд
    for I := 0 to p_curve.m_size - 1 do
    begin
      p:=cBeziePoint.create;
      p.point.y:=p_curve.m_points[i].p.y;
      p.point.x:=p_curve.m_points[i].p.x;
      p.PType:=p_curve.m_points[i].ptype;
      m_tr.AddPoint(p);
      m_ax.AddChild(m_tr);
      m_page.Normalise;
    end;
    cChart1.redraw;
    // отображаем таблицу
    for I := 0 to p_curve.m_size - 1 do
    begin
      CurveSG.Cells[0,i+1]:=floattostr(p_curve.m_points[i].p.x);
      CurveSG.Cells[1,i+1]:=floattostr(p_curve.m_points[i].p.y);
      SGChange(CurveSG);
    end;
  end;
  Show;
end;

procedure TEditCurveFrm.ClearSGButtons;
var
  btn: Tbitmap;
  i: integer;
begin

  for i := 0 to SGbuttons.Count - 1 do
  begin
    btn := Tbitmap(SGbuttons.Items[i]);
    btn.destroy;
  end;
  SGbuttons.clear;
end;


procedure TEditCurveFrm.FormCreate(Sender: TObject);
begin
  init;
  SGbuttons:=tlist.create;
end;

procedure TEditCurveFrm.init;
begin
  CurveSG.RowCount:=3;
  CurveSG.ColCount:=3;
  CurveSG.Cells[0,0]:='X:';
  CurveSG.Cells[1,0]:='Y:';
  m_page:=cpage(cChart1.activePage);
  m_ax:=m_page.activeAxis;
  m_tr:=cTrend.create;
  M_Ax.AddChild(m_tr);
  SGChange(CurveSG);
end;


{ cCurve }

constructor cCurve.create;
begin
  m_capacity:=256;
  SetLength(m_points, 256);
  m_size:=2;
  m_points[0].p.x:=0;
  m_points[1].p.x:=1;
  m_points[0].p.y:=1;
  m_points[1].p.y:=1;
  m_points[0].ptype:=ptlinePoly;
  m_points[1].ptype:=ptlinePoly;
end;

procedure cCurve.getMemScaleData(len:integer);
begin
  GetMemAlignedArray_d(len, m_ScaleData^);
end;

end.
