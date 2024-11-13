unit uModesTabsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, uControlObj, uCommonTypes, uCommonMath, ExtCtrls,
  uChart, utrend, upage, uaxis, upoint, ImgList,  StdCtrls, uSpin, uModesStepFrame,
  uDoubleCursor, uComponentServises, uEventTypes, MathFunction;

type
  TModesTabFrame = class(TFrame)
    ModesSG: TStringGrid;
    Splitter1: TSplitter;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    Panel1: TPanel;
    SGPic: TImageList;
    CursorPosY: TFloatSpinEdit;
    XFE: TFloatSpinEdit;
    YFE: TFloatSpinEdit;
    PointTypeCB: TComboBox;
    Label3: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    TaskParamsEdit: TEdit;
    procedure ModesSGGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure ModesSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ModesSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure ModesSGEditCell(ARow, ACol: Integer; const Value: string);
    procedure cChart1Init(Sender: TObject);
    procedure YFEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cChart1SelectPoint(Sender: TObject);
    procedure cChart1MovePoint(data, subdata: TObject);
    procedure XFEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PointTypeCBChange(Sender: TObject);
    procedure cChart1CursorMove(Sender: TObject);
    procedure cChart1InsertPoint(data, subdata: TObject);
    procedure ModesSGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure cChart1SelectObj(Sender: TObject);
    procedure ModesSGDblClick(Sender: TObject);
    procedure ModesSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  public
    m_stepframe:TModesStepFrame;
  private
    m_val:string;
    m_row,m_col:integer;
    m_p:cProgramObj;
    // выбранная вершина на графике
    m_bp:cbeziepoint;
    m_curTrend:ctrend;
    m_cMng:cControlMng;
    SGbuttons: tlist;
    cchart1:cchart;
  private
    procedure UpdateModesIntervalSG;
    procedure UpdateModesSG(con:cControlObj;bp:cbeziepoint; pointInd:integer);
    procedure updateTrends(pointind:integer;newX:double);
    procedure doSetPoint(x,y:double);
    procedure ShowChart;
    procedure addpoint(tr:ctrend;t:ctask);
    function showControlInChart(con:ccontrolobj):ctrend;
    procedure InitSG;
    function GetTask(row, col:integer):cTask;
    function GetMode(row:integer):cmodeobj;
    function GetModeRow(m:cModeObj):integer;
    function GetControlColumn(c:cControlObj):integer;
    function GetModeName(row:integer):string;
    procedure setInterval(row:integer;m:cModeObj);
    procedure setTask(row, col:integer;t:ctask);
    function getTrend(con:ccontrolobj):ctrend;
    procedure ShowModesSG;
    procedure createSGBtn;
    procedure ClearSGButtons;
    function ToleranceColumn(colname:string; var controlName:string):boolean;
  public
    procedure ShowProgram(p:cprogramobj);
    constructor create(aOwner:tcomponent);override;
    destructor destroy;override;
  end;

  function formatDouble(d:double; digs:integer):string;overload;
  function formatDouble(d:double):string;overload;


const

  c_headerRows = 1;
  c_digs = 3;
  // Таблица шагов программы
  C_Mode_Col = 0;
  C_Interval_Col = 1;
  C_Length_Col = 2;
  C_Interp_Col = 3;
  C_Control_Col = 4;
  c_headerColumns = C_Control_Col;


implementation

{$R *.dfm}


{ TFrame1 }

function TModesTabFrame.ToleranceColumn(colname:string; var controlName:string):boolean;
var
  p:integer;
begin
  p:=pos('_Tol',colname);
  if p>0 then
  begin
    controlName:=colname;
    setlength(controlName, p-1);
    result:=true;
  end
  else
  begin
    controlName:=colname;
    result:=false;
  end;
end;

function formatDouble(d:double; digs:integer):string;
var
  lformat:string;
begin
  //lformat:='%.'+inttostr(digs)+'g';
  //result:=format(lformat, [d]);
  result:=formatstrnoe(d, digs);
end;

function formatDouble(d:double):string;
var
  lformat:string;
begin
  //lformat:='%.'+inttostr(c_digs)+'g';
  //result:=format(lformat, [d]);
  result:=formatstrnoe(d, c_digs);
end;


procedure TModesTabFrame.cChart1CursorMove(Sender: TObject);
var
  c:cDoubleCursor;
  x1,u, y:double;
  bp1_ind:integer;
  bp1,bp2:cBeziePoint;
  m:cmodeobj;
  con:cControlObj;
  tr:ctrend;

begin
  c:=cDoubleCursor(sender);
  x1:=c.getx1;
  tr:=m_curTrend;
  if tr<>nil then
    tr.GetY(x1);
  if tr<>nil then
  begin
    con:=cControlObj(tr.m_userdata);
    bp1_ind:=tr.GetLowInd(x1);
    bp1:=tr.getPoint(bp1_ind);
    bp2:=tr.getPoint(bp1_ind+1);
    if bp2=nil then
      exit;
    m:=m_p.getMode(bp1_ind);
    if m<>nil then
    begin
      u:=(x1-bp1.point.x)/(bp2.point.x-bp1.point.x);
      y:=m.GetTaskValue(con,u);
      CursorPosY.Value:=y;
    end;
  end;
end;

procedure TModesTabFrame.cChart1Init(Sender: TObject);
var
  p:cpage;
  a:caxis;
begin

  p:=cpage(cchart1.activePage);
  p.Caption:='Циклограмма режимов';
  a:=p.activeAxis;
  //a.destroy;
  //p.XMinEdit.visible:=false;
  ShowChart;
  cchart1.showTV:=true;
end;

procedure TModesTabFrame.cChart1InsertPoint(data, subdata: TObject);
var
  bp, prev, next, newP:cBeziePoint;
  tr:ctrend;
  page:cpage;
  ax:caxis;
  i, j:integer;
  m, prevmode:cmodeObj;
begin
  bp:=cBeziePoint(subdata);
  bp.PType:=ptNullPoly;
  page:=cpage(cchart1.activePage);
  for I := 0 to page.getAxisCount - 1 do
  begin
    ax:=page.getaxis(i);
    for j := 0 to ax.ChildCount - 1 do
    begin
      tr:=ctrend(ax.getChild(j));
      if tr<>m_curTrend then
      begin
        newP:=tr.insertpoint(bp.point.x);
        newP.PType:=ptNullPoly;
      end;
    end;
  end;
  prev:=m_curTrend.getPoint(bp.UniqIndex-1);
  next:=m_curTrend.getPoint(bp.UniqIndex+1);
  if next<>nil then
  begin
    m:=cModeObj.create;
    m.name:='Mode';
    m.ModeLength:=next.point.x-bp.point.x;
    m_p.insertMode(m, bp.UniqIndex);
    if prev<>nil then
    begin
      prevmode:=m.getPrevMode;
      prevmode.modelength:=bp.point.x-prev.point.x;
    end;
    cControlMng(m_p.getmng).Events.CallAllEventsWithSender(E_OnEngUpdateList,m);
  end;
  ShowModesSG;
end;

procedure TModesTabFrame.UpdateModesIntervalSG;
var
  i, row, col:integer;
  m:cmodeobj;
begin
  for i:= 0 to m_p.ModeCount - 1 do
  begin
    row:=i+c_headerRows;
    m:=m_p.getMode(i);
    ModesSG.Cells[C_Mode_Col, row] := m.name;
    setInterval(row,m);
  end;
  SGChange(ModesSG);
end;

procedure TModesTabFrame.UpdateModesSG(con:cControlObj;bp:cbeziepoint; pointInd:integer);
var
  modelength:double;
  prevMode, m:cmodeobj;
  row,col:integer;
  t:ctask;
  p2:point2d;
begin
  if pointInd>=0 then
  begin
    m:=m_p.getMode(pointInd);
    prevMode:=m_p.getMode(pointInd-1);
    if prevmode<>nil then
    begin
      prevMode.modelength:=bp.x-m_curTrend.getPoint(pointInd-1).x;
    end;
    t:=m.gettask(con.name);
    if pointInd<(m_curTrend.count-1) then
    begin
      m.modelength:=m_curTrend.getPoint(pointInd+1).x-bp.x;
      t.point:=bp.point;
      t.leftTang:=m_bp.left;
      t.rightTang:=m_bp.right;
    end;

    row:=GetModeRow(m);
    col:=GetControlColumn(t.control);
    p2:=m.gettimeinterval;
    //ModesSG.Cells[col, row] := format('%.2g', [t.task])+;
    ModesSG.Cells[col, row] := format('%.2g', [p2.x])+format('%.2g', [p2.y]);
    UpdateModesIntervalSG;
    m_stepframe.UpdateModesIntervalSG;
    SGChange(ModesSG);
  end;
end;

procedure TModesTabFrame.cChart1MovePoint(data, subdata: TObject);
var
  p2:cbeziepoint;
  t:ctask;
  m:cmodeobj;
  con:cControlObj;
begin
  if data=m_curTrend then
  begin
    p2:=cbeziepoint(subdata);
    ctrend(data).FindPoint(cbeziepoint(subdata).point.x,p2.UniqIndex);
    xfe.Value:=p2.point.x;
    yfe.Value:=p2.point.y;
    updateTrends(p2.UniqIndex, p2.point.x);
    UpdateModesSG(cControlObj(ctrend(data).m_userdata),p2,p2.UniqIndex);

    m:=m_p.getMode(m_bp.UniqIndex);
    con:=cControlObj(m_curTrend.m_userdata);
    t:=m.gettask(con.name);
    t.compilespline;
  end;
end;

procedure TModesTabFrame.PointTypeCBChange(Sender: TObject);
var
  m:cmodeobj;
  con:cControlObj;
  t, prevTask:ctask;
begin
  if m_bp<>nil then
  begin
    m:=m_p.getMode(m_bp.UniqIndex);
    con:=cControlObj(m_curTrend.m_userdata);
    t:=m.gettask(con.name);
    case pointtypecb.ItemIndex of
      0:
      begin
        m_bp.PType:=ptNullPoly;
        t.TaskType:=ptNullPoly;
        t.compilespline;
      end;
      1:
      begin
        m_bp.PType:=ptLinePoly;
        t.TaskType:=ptLinePoly;
        t.compilespline;
      end;
      2:
      begin
        m_bp.PType:=ptCubePoly;
        t.TaskType:=ptCubePoly;

        t.rightTang:=m_bp.right;
        t.leftTang:=m_bp.left;
        t.point:=m_bp.point;
        prevTask:=t.getPrevTask;
        if prevTask<>nil then
        begin
          if prevTask.NullSpline then
          begin
            prevTask.rightTang:=prevTask.point;
            prevTask.leftTang:=prevTask.point;
          end;
        end;
        t.compilespline;
      end;
    end;
    cChart1.Invalidate;
    modessg.Refresh;
  end;
end;

procedure TModesTabFrame.cChart1SelectObj(Sender: TObject);
begin
  if sender is cTrend then
  begin
    m_curTrend:=cTrend(sender);
    modessg.Invalidate;
  end;
end;

procedure TModesTabFrame.cChart1SelectPoint(Sender: TObject);
var
  m:cmodeobj;
  c:cControlObj;
  t:ctask;
begin
  //m_curTrend:=cChart1.activetrend;
  m_bp:=cbeziepoint(sender);
  if m_bp<>nil then
  begin
    xfe.Value:=m_bp.point.x;
    yfe.Value:=m_bp.point.y;
  end;
  case m_bp.PType of
    ptNullPoly:
    begin
      PointTypeCB.ItemIndex:=0;
    end;
    ptlinePoly:
    begin
      PointTypeCB.ItemIndex:=1;
    end;
    ptCubePoly:
    begin
      PointTypeCB.ItemIndex:=2;
    end;
  end;
  m:=m_p.getMode(m_bp.UniqIndex);
  c:=cControlObj(m_curTrend.m_userdata);
  t:=m.gettask(c.name);
  if t<>nil then
  begin
    TaskParamsEdit.text:=t.params;
  end;
end;

constructor TModesTabFrame.create(aOwner: tcomponent);
begin
  inherited;
  cchart1:=cchart.Create(nil);
  cchart1.Caption:='cchart1_ModesTab';
  cchart1.Parent:=Panel1;
  cchart1.Align:=alClient;
  cchart1.showTV:=false;
  cchart1.imagelist:=ImageList_16;
  cchart1.OnInit:=cChart1Init;
  cchart1.OnCursorMove:=cChart1CursorMove;
  cchart1.OnInsertPoint:=cChart1InsertPoint;
  cchart1.OnMovePoint:=cChart1MovePoint;
  cchart1.OnSelectPoint:=cChart1SelectPoint;
  cchart1.OnSelectObj:=cChart1SelectObj;

  InitSG;
  SGbuttons := tlist.Create;
end;

procedure TModesTabFrame.ClearSGButtons;
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

procedure TModesTabFrame.createSGBtn;
var
  btn: Tbitmap;
  row, i: integer;
begin
  if modessg.RowCount < SGbuttons.Count then
  begin
    while modessg.RowCount <> SGbuttons.Count do
    begin
      i := SGbuttons.Count - 1;
      btn := Tbitmap(SGbuttons.Items[i]);
      btn.destroy;
      SGbuttons.Delete(i);
    end;
  end;
  while SGbuttons.Count < modessg.RowCount - c_headerRows do
  begin
    row := SGbuttons.Count + c_headerRows;
    btn := Tbitmap.Create();
    modessg.Objects[C_Interp_Col, row] := btn;
    SGbuttons.Add(btn);
  end;
end;

destructor TModesTabFrame.destroy;
begin
  ClearSGButtons;
  SGbuttons.Destroy;
  SGbuttons:=nil;
  inherited;
end;

function TModesTabFrame.GetMode(row: integer): cmodeobj;
var
  str:string;
begin
  str:=GetModeName(row);
  result:=m_p.getMode(str);
end;


function TModesTabFrame.GetModeName(row: integer): string;
begin
  result:=ModesSG.Cells[C_Mode_Col, row];
end;

function TModesTabFrame.GetModeRow(m: cModeObj): integer;
var
  I: Integer;
begin
  result:=-1;
  for I := 1 to ModesSG.RowCount - 1 do
  begin
    if modesSG.Cells[C_Mode_Col, i]=m.name then
    begin
      result:=i;
      exit;
    end;
  end;
end;

function TModesTabFrame.GetControlColumn(c:cControlObj):integer;
var
  col:integer;
begin
  result:=-1;
  for col:= C_Control_Col to ModesSG.ColCount - 1 do
  begin
    if ModesSG.Cells[col,0]=c.name then
    begin
      result:=col;
      exit;
    end;
  end;
end;

function TModesTabFrame.GetTask(row, col:integer):cTask;
var
  m:cModeObj;
  colname:string;
  p:integer;
begin
  result:=nil;
  m:=GetMode(row);
  colname:=ModesSG.Cells[col,0];
  ToleranceColumn(colname, colname);
  if col>=C_Control_Col then
  begin
    result:=m.gettask(colname);
  end;
end;

function TModesTabFrame.getTrend(con: ccontrolobj): ctrend;
var
  p:cpage;
  a:caxis;
  obj:tobject;
  I: Integer;
  j: Integer;
  tr:ctrend;
begin
  result:=nil;
  p:=cpage(cchart1.activePage);
  for I := 0 to p.getAxisCount - 1 do
  begin
    a:=p.getaxis(i);
    for j := 0 to a.ChildCount - 1 do
    begin
      obj:=a.getChild(j);
      if obj is ctrend then
      begin
        tr:=ctrend(obj);
        if tr.m_userdata=con then
        begin
          result:=tr;
          exit;
        end;
      end;
    end;
  end;
end;

procedure TModesTabFrame.setInterval(row:integer;m:cModeObj);
var
  p2:point2d;
begin
  p2:=m.gettimeinterval;
  ModesSG.Cells[C_Interval_Col, row] := formatdouble(p2.x)+'..'+formatdouble(p2.y);
  ModesSG.Cells[C_Length_Col, row] := formatdouble(m.modelength);
end;

procedure TModesTabFrame.setTask(row, col:integer; t:ctask);
begin
  ModesSG.Cells[col, row]:=t.strvalue;
  ModesSG.Cells[col+1, row]:=t.strUseTol;
end;

procedure TModesTabFrame.InitSG;
begin
  ModesSG.RowCount:=2;
  ModesSG.ColCount:=C_Interval_Col+1;
  ModesSG.Cells[C_Mode_Col, 0] := 'Режим';
  ModesSG.Cells[C_Length_Col, 0] := 'Длительность';
  ModesSG.Cells[C_Interp_Col, 0] := 'Интерп.';
  ModesSG.Cells[C_Interval_Col, 0] := 'Время';
end;

procedure TModesTabFrame.ModesSGGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: string);
begin
  ModesSGSetEditText(sender, acol, arow, value);
end;

procedure TModesTabFrame.ModesSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
  begin
    ModesSGEditCell(m_row, m_col, m_val);
  end;
end;

procedure TModesTabFrame.ModesSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  c:cControlObj;
  colname:string;
  tolcol:boolean;
  tr:ctrend;
begin
  if acol=C_Interp_Col then
  begin
    modessg.Options:=modessg.Options-[goEditing]
  end
  else
  begin
    modessg.Options:=modessg.Options+[goEditing];
  end;
  if acol>=C_Control_Col then
  begin
    colname:=ModesSG.Cells[acol,0];
    tolcol:=ToleranceColumn(colname, colname);
    c:=m_cMng.getControlObj(colname);
    if m_curTrend.m_userdata<>c then
    begin
      tr:=getTrend(c);
      cChart1.selected:=tr;
    end;
  end;
end;

procedure TModesTabFrame.ModesSGSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  m_val:=value;
  m_col:=acol;
  m_row:=arow;
end;

procedure TModesTabFrame.ModesSGDblClick(Sender: TObject);
var
  m:cmodeobj;
  c:cControlObj;
  t:ctask;
begin
  m:=GetMode(modesSG.Row);
  if modesSG.Col=C_Interp_Col then
  begin
    c:=nil;
    if m_curtrend<>nil then
    begin
      c:=cControlObj(m_curTrend.m_userdata);
    end;
    // выбираем вершину
    m_curtrend.deselectAll;
    m_curtrend.selectVertex(m.mindex, c_point);
    m_curtrend.NeedRecompile:=true;
    // меняем тип интерполяции
    if pointtypecb.ItemIndex<pointtypecb.Items.Count-1 then
    begin
      pointtypecb.ItemIndex:=pointtypecb.ItemIndex+1;
    end
    else
    begin
      pointtypecb.ItemIndex:=0;
    end;
    PointTypeCBChange(nil);
  end;
end;

procedure TModesTabFrame.ModesSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: integer;
  m: cModeObj;
  str: string;
  I,x,y, imageind, controlColumn: Integer;
  c:ccontrolobj;
  t:ctask;
  bmp: Tbitmap;
  tolcol:boolean;
begin
  c:=nil;
  if m_curtrend<>nil then
  begin
    c:=cControlObj(m_curTrend.m_userdata);
  end;
  sg := TStringGrid(Sender);
  // подкрашивание колонки с выбраным контролом
  if c<>nil then
  begin
    controlColumn:=GetControlColumn(c);
    if controlColumn=acol then
    begin
      Color := sg.Canvas.Brush.Color;
      sg.Canvas.Brush.Color := CLGReen;
      sg.Canvas.FillRect(Rect);
      sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
      sg.Canvas.Brush.Color := Color;
    end
    else
    begin
      if controlColumn+1=acol then
      begin
        Color := sg.Canvas.Brush.Color;
        sg.Canvas.Brush.Color := cllightGreen;
        sg.Canvas.FillRect(Rect);
        sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
        sg.Canvas.Brush.Color := Color;
      end;
    end;
  end;
  // отображение типа интерполяции
  if c<>nil then
  begin
    if acol=C_Interp_Col then
    begin
      if arow>=c_headerRows then
      begin
        m:=GetMode(arow);
        t:=m.gettask(c.name);
        case t.TaskType of
          ptNullPoly:imageind:=2;
          ptlinePoly:imageind:=0;
          ptCubePoly:imageind:=1;
        end;
        sg.Canvas.FillRect(Rect);
        bmp := Tbitmap(sg.Objects[ACol, ARow]);
        if bmp = nil then
          exit;
        bmp.Height := SGPic.Height;
        bmp.Width := SGPic.Width;
        bmp.Assign(nil);
        SGPic.GetBitmap(imageind, bmp);
        X := round((Rect.Left + Rect.Right - bmp.Width) / 2);
        Y := round((Rect.Top + Rect.Bottom - bmp.Height) / 2);
        sg.Canvas.Draw(X, Y, bmp);
      end;
    end;
  end;
end;

procedure TModesTabFrame.ModesSGEditCell(ARow, ACol: Integer; const Value: string);
var
  m:cmodeobj;
  t:ctask;
  colname:string;
  p:integer;
  ToleranceColumn:boolean;
begin
  M:=GetMode(arow);
  if (ACol=c_Interval_Col) or (ACol=C_Length_Col) then
  begin
    if isValue(value) then
    begin
      m.ModeLength:=strtofloatext(value);
      setInterval(arow,m);
      while arow<modessg.RowCount-1 do
      begin
        inc(arow);
        M:=GetMode(arow);
        setInterval(arow,m);
      end;
      ShowChart;
    end;
  end;
  if aCol>=c_Control_Col then
  begin
    t:=GetTask(arow, acol);

    colname:=ModesSG.Cells[acol,0];
    p:=pos('_Tol',colname);
    if p>0 then
    begin
      ToleranceColumn:=true;
      if isValue(value) then
      begin
        t.m_useTolerance:=true;
        t.m_tolerance:=StrToFloatExt(value);
      end
      else
      begin
        t.m_useTolerance:=false;
        setTask(arow, acol-1, t);
      end;
    end
    else
    begin
      ToleranceColumn:=false;
    end;
    if isValue(value) then
    begin
      if not ToleranceColumn then
      begin
        t.task:=StrToFloatExt(value);
      end;
      if ToleranceColumn then
        setTask(arow, acol-1, t)
      else
        setTask(arow, acol, t);
    end
    else
    begin

    end;
    ShowChart;
  end;
  m_stepframe.UpdateModesIntervalSG;
end;

function TaskColumn(t:ctask; sg:tstringgrid):integer;
var
  I: Integer;
begin
  for I := 2 to sg.ColCount - 1 do
  begin
    if sg.Cells[i,0]=t.control.name then
    begin
      result:=i;
      exit;
    end;
  end;
end;

procedure TModesTabFrame.ShowModesSG;
var
  I, j, row, col, controlCount: Integer;
  m:cModeObj;
  mng:cControlMng;
  p2:point2d;
  con, owncon:cControlObj;
  task:ctask;
  colname:string;
begin
  mng:=cControlMng(m_p.getMng);
  controlCount:=0;
  for I := 0 to mng.ControlsCount - 1 do
  begin
    con:=mng.getControlObj(i);
    owncon:=m_p.getOwnControl(con.name);
    if owncon<>nil then
    begin
      if owncon=con then
      begin
        inc(controlCount);
      end;
    end;
  end;

  ModesSG.RowCount:=m_p.ModeCount+c_headerRows;
  ModesSG.ColCount:=controlCount*2+c_headerColumns;
  for I := 0 to mng.ControlsCount - 1 do
  begin
    con:=mng.getControlObj(i);
    if m_p.getOwnControl(con.name)=con then
    begin
      ModesSG.Cells[C_Control_Col+i*2, 0] := con.name;
      ModesSG.Cells[C_Control_Col+i*2+1, 0] := con.name+'_Tol';
    end;
  end;
  for i:= 0 to m_p.ModeCount - 1 do
  begin
    row:=i+c_headerRows;
    m:=m_p.getMode(i);

    ModesSG.Cells[C_Mode_Col, row] := m.name;
    setInterval(row,m);

    ModesSG.Cells[C_Length_Col, row] :=formatDouble (m.ModeLength, c_digs);
    for j := 0 to mng.ControlsCount - 1 do
    begin
      colname:=ModesSG.Cells[C_Control_Col+j*2,0];
      if colname<>'' then
      begin
        task:=m.gettask(colname);
        setTask(row, C_Control_Col+j*2, task);
      end;
    end;
  end;
  createSGBtn;
  SGChange(ModesSG);
end;

procedure TModesTabFrame.ShowProgram(p: cprogramobj);
begin
  m_p:=p;
  m_cMng:=ccontrolmng(m_p.getMng);
  ShowModesSG;
  ShowChart;
end;

procedure TModesTabFrame.XFEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
  begin
    doSetPoint(xfe.Value, yfe.Value);
  end;
end;

procedure TModesTabFrame.YFEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
  begin
    doSetPoint(xfe.Value, yfe.Value);
  end;
end;

procedure TModesTabFrame.doSetPoint(x,y:double);
var
  sp:selectpoint;
  p2:point2;
  t:ctask;
begin
  if m_bp<>nil then
  begin
    p2.x:=x;
    p2.y:=y;
    sp:=m_curTrend.GetSelectPoint(0);
    if sp<>nil then
    begin
      if sp<>nil then
      begin
       m_curTrend.SetPoint(p2,sp);
       cchart1.redraw;
      end;
    end;
    // обновляем позицию x других трендов в режиме
    if sp.t=c_point then
    begin
      updateTrends(sp.i, x);
      UpdateModesSG(cControlObj(m_curTrend.m_userdata), m_bp, sp.i);
    end;
    cchart1.redraw;
  end;
end;
// перемещаем точки трендов
procedure TModesTabFrame.updateTrends(pointind:integer;newX:double);
var
  i:integer;
  con:cControlObj;
  tr:ctrend;
  sp:selectpoint;
begin
  sp:=selectpoint.Create;
  sp.i:=pointind;
  sp.t:=c_point;
  for I := 0 to m_p.ControlCount - 1 do
  begin
    con:=m_p.getOwnControl(i);
    tr:=getTrend(con);
    if tr<>m_curTrend then
    begin
      tr.SetPointX(newX,sp);
    end;
  end;
  sp.Destroy;
end;

procedure TModesTabFrame.addpoint(tr:ctrend;t:ctask);
var
  prev:cTask;
  prevval:double;
  bp:cBeziePoint;
begin
  case t.TaskType of
    ptNullPoly:
    begin
      bp:=cBeziePoint.create;
      case t.TaskType of
        ptNullPoly: bp.PType:=ptNullPoly;
        ptLinePoly: bp.PType:=ptLinePoly;
        ptCubePoly: bp.PType:=ptCubePoly;
      end;
      bp.point:=p2(t.mode.gettimeinterval.x,t.task);
      tr.AddPoint(bp);
    end;
    ptLinePoly:
    begin
      bp:=cBeziePoint.create;
      case t.TaskType of
        ptNullPoly: bp.PType:=ptNullPoly;
        ptLinePoly: bp.PType:=ptLinePoly;
        ptCubePoly: bp.PType:=ptCubePoly;
      end;
      bp.point:=p2(t.mode.gettimeinterval.x,t.task);
      bp.left:=t.leftTang;
      bp.right:=t.rightTang;
      tr.AddPoint(bp);
    end;
    ptCubePoly:
    begin
      bp:=cBeziePoint.create;
      case t.TaskType of
        ptNullPoly: bp.PType:=ptNullPoly;
        ptLinePoly: bp.PType:=ptLinePoly;
        ptCubePoly: bp.PType:=ptCubePoly;
      end;
      bp.point:=p2(t.mode.gettimeinterval.x,t.task);
      bp.left:=t.leftTang;
      bp.right:=t.rightTang;
      tr.AddPoint(bp);
    end;
  end;
end;

function TModesTabFrame.showControlInChart(con:ccontrolobj):ctrend;
var
  I: Integer;
  m:cmodeobj;
  t:ctask;
  tr:ctrend;
  page:cpage;
  ax:caxis;
begin
  tr:=nil;
  ax:=nil;
  for I := 0 to m_p.ModeCount - 1 do
  begin
    m:=m_p.getMode(i);
    t:=m.gettask(con.name);
    if t<>nil then
    begin
      if tr=nil then
      begin
        page:=cpage(cChart1.activePage);
        if page<>nil then
        begin
          ax:=page.getaxis(con.units);
          if ax=nil then
          begin
            ax:=page.Newaxis;
            ax.name:=con.units;
            ax.m_YUnits:=ax.name;
            page.addaxis(ax);
          end;
          tr:=ax.AddTrend;
          // свойство означает возможность выбрать объект по клику мышкой
          tr.enabled:=true;
          tr.color:=ax.color;
          tr.name:=con.name;
          tr.m_userdata:=con;

        end
        else
        begin
          exit;
        end;
      end;
      addpoint(tr,t);
    end;
  end;
  if ax<>nil then
    page.Normalise(ax);
  if m_curTrend=nil then
  begin
    cchart1.selected:=tr;
  end;
end;

procedure TModesTabFrame.ShowChart;
var
  I: Integer;
  con:ccontrolobj;
begin
  if cchart1.initGl then
  begin
    cpage(cchart1.activePage).clear;
    if m_p<>nil then
    begin
      for I := 0 to m_p.ControlCount - 1 do
      begin
        con:=m_p.getOwnControl(i);
        showControlInChart(con);
      end;
    end;
  end;
end;

end.
