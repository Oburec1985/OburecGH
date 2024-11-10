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
    CurvelSG: TStringGrid;
    Splitter1: TSplitter;
    cChart1: cChart;
    BottomPanel: TPanel;
    OkBtn: TButton;
    SGPic: TImageList;
    procedure FormCreate(Sender: TObject);
  public

  private
    m_tr:ctrend;
    m_page:cpage;
    m_ax:caxis;
  private
    procedure init;
    procedure showCurve;
  public
    procedure editCurve(p_curve:cCurve);
  end;

var
  EditCurveFrm: TEditCurveFrm;

implementation

{$R *.dfm}

{ TEditCurveFrm }

procedure TEditCurveFrm.editCurve(p_curve: cCurve);
var
  I: Integer;
  p:cBeziePoint;
begin
  m_tr.Clear;
  for I := 0 to p_curve.m_size - 1 do
  begin
    p:=cBeziePoint.create;
    p.point.y:=p_curve.m_points[i].p.y;
    p.point.x:=p_curve.m_points[i].p.x;
    p.PType:=p_curve.m_points[i].ptype;
    m_tr.AddPoint(p);
  end;
end;

procedure TEditCurveFrm.FormCreate(Sender: TObject);
begin
  init;
end;

procedure TEditCurveFrm.init;
begin
  CurvelSG.RowCount:=3;
  CurvelSG.ColCount:=3;
  CurvelSG.Cells[0,0]:='X:';
  CurvelSG.Cells[1,0]:='Y:';
  m_page:=cpage(cChart1.activePage);
  m_ax:=m_page.activeAxis;
  m_tr:=cTrend.create;
  M_Ax.AddChild(m_tr);
  SGChange(CurvelSG);
end;

procedure TEditCurveFrm.showCurve;
var
  I: Integer;
begin

  for I := 0 to List.Count - 1 do
  begin

  end;
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
