unit uEditCurveFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, uChart, StdCtrls,
  upoint, u2DMath,
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
    m_ScaleDataSize:integer;
  protected
    function getLowInd(x:double):integer;
  public
    // выделить память под результат. m_ScaleData  -хранится в
    // окне класса cSpm - коррекция АЧХ CorrAFHar: TAlignDarray;
    procedure getMemScaleData(len:integer);
    procedure EvalData;
    function toStr:string;
    procedure fromStr(s:string);
    constructor create;
  end;

  cBmp = class
    bmp:tbitmap;
    t: TPType;
  public
    constructor create;
    destructor destroy;
  end;

  TEditCurveFrm = class(TForm)
    CurveSG: TStringGrid;
    Splitter1: TSplitter;
    cChart1: cChart;
    BottomPanel: TPanel;
    SGPic: TImageList;

    procedure FormCreate(Sender: TObject);
    procedure CurveSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure CurveSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CurveSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure OkBtnClick(Sender: TObject);
    procedure CurveSGDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    // список кнопок с интерполяцией
    SGbuttons:tlist;
  private
    m_curve:ccurve;
    m_tr:ctrend;
    m_page:cpage;
    m_ax:caxis;
    m_r, m_c:integer;
  private
    procedure init;
    procedure showTrend;
    procedure ShowTable;
    procedure TableToTrend;
    procedure ClearSGButtons;
    procedure createSGBtn;
    function EmptyRow(sg:tstringgrid; r:integer):boolean;
  public
    procedure editCurve(p_curve:cCurve);
  end;

var
  EditCurveFrm: TEditCurveFrm;

implementation

{$R *.dfm}

{ TEditCurveFrm }

procedure TEditCurveFrm.CurveSGDblClick(Sender: TObject);
var
  b:cbmp;
begin
  if m_c=2 then
  begin
    b:=cbmp(curvesg.Objects[m_c,m_r]);
    case b.t of
      ptNullPoly: b.t:=ptlinePoly;
      ptlinePoly: b.t:=ptNullPoly;
      ptCubePoly: b.t:=ptNullPoly;
    end;
    TableToTrend;
    showTrend;
  end;
end;

procedure TEditCurveFrm.CurveSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  bmp: cbmp;

  imageind, X, Y: integer;
begin
  if ARow < 1 then // headersize
    exit;
  if ACol = 2 then
  begin // Простое рисование
    CurveSG.Canvas.FillRect(Rect);
    CurveSG.Canvas.FillRect(Rect);
    bmp := cbmp(CurveSG.Objects[ACol, ARow]);
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
    CurveSG.Canvas.Draw(X, Y, bmp.bmp);
  end;
end;

procedure TEditCurveFrm.CurveSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin

  end;
  if Key = VK_RETURN then
  begin
    if m_r=curvesg.RowCount-1 then
    begin
      if not EmptyRow(curvesg, m_r) then
      begin
        curvesg.RowCount:=curvesg.RowCount+1;
      end;
    end;
    TableToTrend;
    showTrend;
  end;
end;

procedure TEditCurveFrm.CurveSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  m_r:=ARow;
  m_c:=ACol;
end;

procedure TEditCurveFrm.editCurve(p_curve: cCurve);
begin
  m_curve:=p_curve;
  m_tr.Clear;
  if p_curve<>nil then
  begin
    ShowTrend;
    ShowTable;
  end;
  Show;
end;

function TEditCurveFrm.EmptyRow(sg: tstringgrid; r: integer): boolean;
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

procedure TEditCurveFrm.ClearSGButtons;
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


procedure TEditCurveFrm.createSGBtn;
var
  btn: cbmp;
  row, i: integer;
begin
  if curvesg.RowCount < SGbuttons.Count then
  begin
    while curvesg.RowCount <> SGbuttons.Count do
    begin
      i := SGbuttons.Count - 1;
      btn := cbmp(SGbuttons.Items[i]);
      btn.destroy;
      SGbuttons.Delete(i);
    end;
  end;
  while SGbuttons.Count < curvesg.RowCount - 1 do
  begin
    row := SGbuttons.Count + 1;
    btn := cbmp.Create();
    curvesg.Objects[2, row] := btn;
    SGbuttons.Add(btn);
  end;
end;

procedure TEditCurveFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_curve.EvalData;
end;

procedure TEditCurveFrm.FormCreate(Sender: TObject);
begin
  init;
  SGbuttons:=tlist.create;
end;

procedure TEditCurveFrm.init;
begin
  CurveSG.RowCount:=4;
  CurveSG.ColCount:=3;
  CurveSG.Cells[0,0]:='X:';
  CurveSG.Cells[1,0]:='Y:';
  CurveSG.Cells[2,0]:='Тип:';
  m_page:=cpage(cChart1.activePage);
  m_ax:=m_page.activeAxis;
  m_tr:=cTrend.create;
  M_Ax.AddChild(m_tr);
  SGChange(CurveSG);
end;


procedure TEditCurveFrm.OkBtnClick(Sender: TObject);
begin
  TableToTrend;
  showTrend;
end;

procedure TEditCurveFrm.ShowTable;
var
  i:integer;
begin
  CurveSG.RowCount:=m_curve.m_size+2;
  // отображаем таблицу
  for I := 0 to m_curve.m_size - 1 do
  begin
    CurveSG.Cells[0,i+1]:=floattostr(m_curve.m_points[i].p.x);
    CurveSG.Cells[1,i+1]:=floattostr(m_curve.m_points[i].p.y);
  end;
  createSGBtn;
  SGChange(CurveSG);
end;

procedure TEditCurveFrm.showTrend;
var
  i:integer;
  p:cBeziePoint;
begin
  // отображаем тренд
  m_tr.Clear;
  for I := 0 to m_curve.m_size - 1 do
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

procedure TEditCurveFrm.TableToTrend;
var
  I, c: Integer;
  bmp:cbmp;
begin
  c:=0;
  for I := 1 to CurveSG.RowCount - 1 do
  begin
    if not EmptyRow(curvesg,i) then
    begin
      inc(c);
      m_curve.m_points[i-1].p.x:=strtoFloatExt(CurveSG.Cells[0,i]);
      m_curve.m_points[i-1].p.y:=strtoFloatExt(CurveSG.Cells[1,i]);
      bmp:=cbmp(CurveSG.Objects[2,i]);
      m_curve.m_points[i-1].ptype:=bmp.t;
    end;
  end;
  m_curve.m_size:=c;
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

procedure cCurve.EvalData;
var
  I, ind: Integer;
  dx, x:double;
begin
  dx:=(m_points[m_size-1].p.x-m_points[0].p.x)/m_ScaleDataSize;
  x:=m_points[0].p.x;
  for I := 0 to m_ScaleDataSize - 1 do
  begin
    ind:=getLowInd(x);
    if (ind+1)<=m_ScaleDataSize - 1 then
    begin
      case m_points[ind+1].ptype of
        ptlinePoly: TAlignDarray(m_ScaleData.p)[i]:=EvalLineY(x, m_points[ind].p, m_points[ind+1].p);
        ptNullPoly:
        begin
          if x<m_points[ind+1].p.x then
            TAlignDarray(m_ScaleData.p)[i]:=m_points[ind].p.y
          else
            TAlignDarray(m_ScaleData.p)[i]:=m_points[ind+1].p.y
        end;
      end;
    end
    else
    begin
      TAlignDarray(m_ScaleData.p)[i]:=m_points[ind].p.y
    end;
    x:=x+dx;
  end;
end;

function cCurve.getLowInd(x: double): integer;
var
  I: Integer;
  low:boolean;
begin
  i:=-1;
  low:=x>m_points[0].p.x;
  if not low then
  begin
    result:=-1;
    exit;
  end;
  for I := 1 to m_size - 1 do
  begin
    if low then
    begin
      if x<m_points[i].p.x then
      begin
        result:=i-1;
        exit;
      end;
    end;
    low:=x>m_points[i].p.x;
  end;
  if low then
    result:=i;
end;

procedure cCurve.getMemScaleData(len:integer);
begin
  GetMemAlignedArray_d(len, m_ScaleData^);
  m_ScaleDataSize:=len;
end;

function cCurve.toStr: string;
begin

end;

procedure cCurve.fromStr(s: string);
begin

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
