unit uGenFreqForm;

interface

uses
  Windows, SysUtils,  Classes, Forms, dialogs,messages,opengl, uBldMath,
  StdCtrls, uOglChart, uBldFile, Controls, DCL_MYOWN, uOglProcess, Buttons
  ,umytypes_,utickdata, umymath, ubldturnmath;

type
  TGenFreqForm = class(TForm)
    GetDataBtn: TButton;
    CancelBtn: TButton;
    GroupBox1: TGroupBox;
    UnitsComboBox: TComboBox;
    GroupBox2: TGroupBox;
    XPosEdit: TEdit;
    Label1: TLabel;
    YPosEdit: TEdit;
    Label2: TLabel;
    GroupBox3: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    CursorXPosEdit: TEdit;
    CursorYPosEdit: TEdit;
    GroupBox4: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    iXPosEdit: TEdit;
    iYPosEdit: TEdit;
    Edit1: TEdit;
    cGlChart1: cGlChart;
    Label7: TLabel;
    ChangeChartTargetButton: TButton;
    SpeedButton1: TSpeedButton;
    TVibrEdit: TEdit;
    Label8: TLabel;
    GroupBox5: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    SensorPosEdit: TFloatEdit;
    Label12: TLabel;
    Label13: TLabel;
    StartTimeEdit: TFloatEdit;
    EndTimeEdit: TFloatEdit;
    Label11: TLabel;
    Label15: TLabel;
    Label14: TLabel;
    BladePosEdit: TFloatEdit;
    Button1: TButton;
    PeriodFloatEdit: TFloatEdit;
    Label16: TLabel;
    AutoTCheckBox: TCheckBox;
    FloatEdit1: TFloatEdit;
    procedure ViewPointsClick(Sender: TObject);
    procedure cGlChart1BeforeDrawChart(Sender: TObject);
    procedure TVibrEditChange(Sender: TObject);
    procedure cGlChart1BeforeUpdateAxisByText(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cGlChart1UpdateAxisByText(Sender: TObject);
    procedure cGlChart1BeforeNormaliseBtnClick(Sender: TObject);
    procedure cGlChart1BeforeSetPoint(var p: Point2; sel: selectType);
    procedure cGlChart1ChangePointsType;
    procedure cGlChart1Remove(points: array of selectType);
    procedure cGlChart1Refine(x, y: Single);
    procedure ChangeChartTargetButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cGlChart1Paint(Sender: TObject);
    procedure cGlChart1Moove(Sender: TObject);
    procedure cGlChart1Click(Sender: TObject);
  private
    { Private declarations }
    m_freqdata:cpoints; // Ссылка на внешний массив данных с тиками, из uAddConstForm
    procedure updatetext;
    procedure ZoomVibration(sender:tobject);
  public
    // Найти время одного полнеого колебания лопатки.
    function Getdx:single;
    // Найти y по фазе на графике редактирования вибрации.
    function GetYbyPhase(phase:single):single;
    // Действия выполняемые при вызове формы генерация частоты
    function ShowModal(var FreqData:cpoints):integer;
    procedure evalFreqData(var FreqData:cpoints);
  end;
  // Преобразовать значение фазы в значение вибрации взятой из чарта

var
  GenFreqForm: TGenFreqForm;

  rezoom      // нужно призумить ось x/ True становится однократно, при
  // только для задания закона генерации
  ,updateX    // если изменили ось x по кнопке время процесса, то нужно масштабировать точки
              // графика по x
  ,updateaxis // были обновлены оси пользователем
  ,targetVibr // активно редактирование периода вибрации
  ,autozoom:boolean;

implementation
procedure TGenFreqForm.updatetext;
var
    f:point2;
    bp:BeziePoint;
    a:vectorf;
    len:integer;
    pi:point2i;
    ltrend:ctrend;
begin
  ltrend:=ctrend(cGlChart1.Chart.m_trends.items
                [cglChart1.Chart.m_SelectOpts.activetrend]);
  len:=Length(ltrend.m_trend.m_selectedPoints);
  SetLength(a,len);
  if cGlChart1.Chart.m_SelectOpts.select then
  begin
    bp:=ltrend.GetBezie(ltrend.m_trend.m_selectedPoints[0].index);
    a:=cGlChart1.Chart.GetSelectedCoord;
    case ltrend.m_trend.m_selectedPoints[0].t of
      0:f:=a[0];
      1:f:=bp.leftp;
      2:f:=bp.rightp;
    end;
    XPosEdit.Text:=FloatTostr(f.x);
    YPosEdit.Text:=FloatTostr(f.y);
    a:=cGlChart1.Chart.GetSelectedCoord;
    f:=a[0];
    pi:=cGlChart1.Chart.TrendPToP2i(f);
    iXPosEdit.Text:=FloatTostr(pi.x);
    iYPosEdit.Text:=FloatTostr(pi.y);
  end;
end;
// находит в массиве элемент слева от элемента с заданным x
function FindInArrayLowBound(a:cpoints;x:single):integer;
var b:boolean;
    len,range,curind,
    left,right:integer;
    frac_:boolean;
    function _div(a,b:integer;var frac_:boolean):integer;
    var res:integer;
    begin
       if a=1 then
       begin
        result:=0;
        exit;
       end;
       res:= trunc(a/b);
       frac_:=((a mod b)<>0);
       result:=res;
    end;
begin
  len:=Length(a.ar.ar);
  // Проверка граничных результатов
  if a.ar.ar[len-1].x<x then
  begin
    result:=len-1;
    exit;
  end;
  if a.ar.ar[0].x>x then
  begin
    result:=0;
    exit;
  end;
  // Определяем границы поиска в массиве
  left:=0;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a.ar.ar[curind].x>x then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if a.ar.ar[curind].x>x then
    result:=curind-1
  else
    result:=curind;
end;
// находит в массиве элемент справа от элемента с заданным x
function FindInArrayHiBound(a:cpoints;x:single):integer;
var b:boolean;
    len,range,curind,
    left,right:integer;
    frac_:boolean;
    function _div(a,b:integer;var frac_:boolean):integer;
    var res:integer;
    begin
       if a=1 then
       begin
        result:=0;
        exit;
       end;
       res:= trunc(a/b);
       frac_:=((a mod b)<>0);
       result:=res;
    end;
begin
  len:=Length(a.ar.ar);
  // Проверка граничных результатов
  if a.ar.ar[len-1].x<x then
  begin
    result:=len-1;
    exit;
  end;
  if a.ar.ar[0].x>x then
  begin
    result:=0;
    exit;
  end;
  // Определяем границы поиска в массиве
  left:=0;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if a.ar.ar[curind].x>x then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if a.ar.ar[curind].x>x then
    result:=curind
  else
    result:=curind+1;
end;
// Найти точку на прямой, образованной двумя точками, по X
function CalkYbyX(startP,endP:point2;X:single):single;
var k,b:single;
begin
  k:=(endP.y - startp.y)/(endP.x - startp.x);
  if k=0 then
  begin
    result:=startp.y;
    exit;
  end;
  b:=-k*startp.x+startp.y;
  result:=k*x+b;
end;
{$R *.dfm}
// В сенере соержится ссылка на класс cOglCHART
procedure TGenFreqForm.cGlChart1BeforeDrawChart(Sender: TObject);
var dAxis,newdAxis:point2;
    ltrend:ctrend;
    rect1,rect2:frect;
    dx:single;
    ps:PaintStruct;
    procedure DrawRect(rect:frect);
    var oldcolor,newcolor:point3;
    begin
        newcolor.x:=0.3;newcolor.y:=0.3;newcolor.z:=0.3;
        oldcolor.x:=0.9;oldcolor.y:=0.9;oldcolor.z:=0.9;
        //glgetfloatv(GL_CURRENT_COLOR,@oldcolor);
        glcolor3fv(@newcolor);
        glBegin(GL_QUADS);
        glvertex2f(rect.BottomLeft.x,rect.BottomLeft.y);
        glvertex2f(rect.BottomLeft.x,rect.TopRight.y);
        glvertex2f(rect.topright.x,rect.TopRight.y);
        glvertex2f(rect.topright.x,rect.BottomLeft.y);
        glend;
        glcolor3fv(@oldcolor);
    end;
begin
  if targetVibr then
  begin
    //BeginPaint(cOglChart(sender).m_ContextConfig.m_Handle,ps);
    //wglMakeCurrent(cOglChart(sender).m_ContextConfig.m_dc,cOglChart(sender).m_ContextConfig.m_hrc);   //где и чем рисовать

    ltrend:=ctrend(cGlChart1.Chart.m_trends.items[1]);
    dx :=ltrend.m_trend.m_Max.x - ltrend.m_trend.m_Min.x;

    rect1.BottomLeft.x := ltrend.m_trend.m_Min.x - dx;
    rect1.TopRight.x := ltrend.m_trend.m_Min.x;
    rect1.BottomLeft.y := cOglChart(Sender).m_AxisConfig.m_MinValues.y;
    rect1.TopRight.y := cOglChart(Sender).m_AxisConfig.m_MaxValues.y;
    // отрисовка границ чарта
    rect2:=rect1;
    rect2.BottomLeft.x:=ltrend.m_trend.m_Max.x;
    rect2.TopRight.x:=ltrend.m_trend.m_Max.x + dx;
    glViewPort(cOglChart(sender).m_AxisConfig.m_pixelTabSpace.Left,
               cOglChart(sender).m_AxisConfig.m_pixelTabSpace.Bottom,
               cOglChart(sender).m_ContextConfig.m_ClientWidth -
               cOglChart(sender).m_AxisConfig.m_pixelTabSpace.right -
               cOglChart(sender).m_AxisConfig.m_pixelTabSpace.Left,
               cOglChart(sender).m_ContextConfig.m_ClientHeight -
               cOglChart(sender).m_AxisConfig.m_pixelTabSpace.top -
               cOglChart(sender).m_AxisConfig.m_pixelTabSpace.Bottom);
    // отрисовка границ чарта
    Drawrect(rect1);
    Drawrect(rect2);
    glViewPort(0,0,cOglChart(sender).m_ContextConfig.m_ClientWidth,cOglChart(sender).m_ContextConfig.m_ClientHeight);
  end;
end;

procedure TGenFreqForm.cGlChart1BeforeNormaliseBtnClick(Sender: TObject);
var rect:frect;
begin
    if not cGlChart1.Chart.m_SelectOpts.b_rescalepoints then
    begin
      rect.BottomLeft.x:=strtofloat(cGlChart1.Chart.XMinEdit.Text);
      rect.BottomLeft.y:=strtofloat(cGlChart1.Chart.YMinEdit.Text);
      rect.TopRight.x:=strtofloat(cGlChart1.Chart.XMaxEdit.Text);
      rect.TopRight.y:=strtofloat(cGlChart1.Chart.YMaxEdit.Text);
      //ZoomfRect(rect);
    end;
end;

procedure TGenFreqForm.cGlChart1BeforeSetPoint(var p: Point2; sel: selectType);
var len:integer;
    ltrend:ctrend;
begin
  // Процедура нужна для коректировки координат
  // в которые помещает пользователь точку
  // в данном случае нельзя перемещать вершины на концах диапазона
  if targetVibr then
  begin
    ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[1]);
    len:=length(ltrend.m_trend.m_trenddata);
    if ((sel.index = 0) or (sel.index = len-1))
    and (sel.t = 0) and not updateX and not updateaxis then
    begin
      p:=ltrend.m_trend.m_trenddata[sel.index];
    end;
  end;
end;

procedure TGenFreqForm.cGlChart1BeforeUpdateAxisByText(Sender: TObject);
var y:string;
begin
  autozoom:=true;
  updateaxis:=true;
  if (tedit(sender).Name[1] = 'Y') then
  begin
    y:=(tedit(sender).text);
    cGlChart1.Chart.FullZoom(true,false);
    tedit(sender).text:=y;
  end;
  // Если зум по оси x производится пользователем, то нужно запрещать масштаб точек
  // Если по кнопке время процесса, то разрешать
  cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=
    (tedit(sender).Name[1] <> 'X') and (SpeedButton1.Down) or (updateX);
end;

procedure TGenFreqForm.cGlChart1ChangePointsType;
var ltrend1,ltrend2:ctrend;
begin
  if targetVibr then
  begin
    ltrend1:=ctrend(cGlChart1.Chart.m_trends.Items[2]);
    ltrend2:=ctrend(cGlChart1.Chart.m_trends.Items[3]);
    cglChart1.Chart.m_SelectOpts.activetrend:=2;
    cglChart1.Chart.ChangeType;
    cglChart1.Chart.m_SelectOpts.activetrend:=3;
    cglChart1.Chart.ChangeType;
    cglChart1.Chart.m_SelectOpts.activetrend:=1;
  end;
end;

function TGenFreqForm.Getdx:single;
var dx:single;
    ltrend:ctrend;
begin
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[1]);
  dx:=ltrend.m_trend.m_Max.x - ltrend.m_trend.m_Min.x;
  result:=dx;
end;

function TGenFreqForm.GetYbyPhase(phase:single):single;
var dx:single;
    ltrend:ctrend;
  function PhaseToX(phase:single):single;
  begin
    Result:=dx*phase/360;
  end;
begin
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[1]);
  dx:=ltrend.m_trend.m_Max.x - ltrend.m_trend.m_Min.x;
  result:=ltrend.FindYOnSpline(Phasetox(phase));
end;

procedure TGenFreqForm.cGlChart1Click(Sender: TObject);
begin
  updateText;
end;

procedure TGenFreqForm.cGlChart1Moove(Sender: TObject);
var ltrend,ltrend1,ltrend2:ctrend;
    len,count,i,j,j_:integer;
    index,index1:selectType;
    p2,p2_:point2;
    dx:single;
    bp:beziepoint;
    grow:boolean;
begin
  CursorXPosEdit.Text:=inttostr(cGlChart1.Chart.m_AxisConfig.m_camera.m_ix1);
  CursorYPosEdit.Text:=inttostr(cGlChart1.Chart.m_AxisConfig.m_camera.m_iy1);
  if targetVibr then
    i:=1
  else
    i:=0;
  ltrend:=ctrend(ctrend(cGlChart1.Chart.m_trends.Items[i]));
  count:=length(ltrend.m_trend.m_TrendData);
  // Если были смасштабированы оси то нужно переместить все точки
  // соседних трендов выделив их
  if updateaxis then
  begin
    setlength(ltrend.m_trend.m_selectedPoints,count
                           + ltrend.m_trend.m_Smooth
                           + ltrend.m_trend.m_Smooth);
    j:=0;
    for I := 0 to count - 1 do
    begin
      bp:=ltrend.GetBezie(i);
      ltrend.m_trend.m_selectedPoints[j].index:=i;
      ltrend.m_trend.m_selectedPoints[j].t:=0;
      inc(j,1);
      // Если точка сглаженая, нужно выделить ее касательные
      if bp.m_type then
      begin
        ltrend.m_trend.m_selectedPoints[j].index:=i;
        ltrend.m_trend.m_selectedPoints[j].t:=1;
        inc(j,1);
        ltrend.m_trend.m_selectedPoints[j].index:=i;
        ltrend.m_trend.m_selectedPoints[j].t:=2;
        inc(j,1);
      end;
    end;
  end;
  if ((i=1) or (updatex) or (updateaxis)) and targetVibr then
  begin
    len:=length(ltrend.m_trend.m_selectedPoints);
    if (len<>0) then
    begin
      ltrend1:=ctrend(ctrend(cGlChart1.Chart.m_trends.Items[2]));
      ltrend2:=ctrend(ctrend(cGlChart1.Chart.m_trends.Items[3]));
      dx :=ltrend.m_trend.m_Max.x - ltrend.m_trend.m_Min.x;
      index.index:=1;
      p2_.x:=ltrend.m_trend.m_trendData[index.index].x + dx;
      p2.x:=ltrend2.m_trend.m_trendData[index.index].x;
      grow:=p2.x<p2_.x;
      setLength(ltrend1.m_trend.m_selectedPoints,len);
      setLength(ltrend2.m_trend.m_selectedPoints,len);
      for j := 0 to len - 1 do
      begin
        ltrend1.m_trend.m_selectedPoints[j]:=ltrend.m_trend.m_selectedPoints[j];
        ltrend2.m_trend.m_selectedPoints[j]:=ltrend.m_trend.m_selectedPoints[j];
      end;
      // Перемещение точек правого чарта
      for j := 0 to len - 1 do
      begin
        if grow then
          j_:=len-1 - j
        else
          j_:=j;
        index:=ltrend.m_trend.m_selectedPoints[j_];
        if index.t<>0 then
          index.t:=index.t;
        if index.t=0 then
        begin
          p2.x:=ltrend.m_trend.m_trendData[index.index].x - dx;
          p2.y:=ltrend.m_trend.m_trendData[index.index].y;
          p2_:=p2;
          p2_.x:=ltrend.m_trend.m_trendData[index.index].x + dx;
        end;
        if index.t=1 then
        begin
          bp:=ltrend.GetBezie(index.index);
          p2.x:=bp.leftp.x - dx;
          p2.y:=bp.leftp.y;
          p2_:=p2;
          p2_.x:=bp.leftp.x + dx;
        end;
        if index.t=2 then
        begin
          bp:=ltrend.GetBezie(index.index);
          p2.x:=bp.rightp.x - dx;
          p2.y:=bp.rightp.y;
          p2_:=p2;
          p2_.x:=bp.rightp.x + dx;
        end;
        if (index.index<>0) and (index.index<>count-1)
            or (index.t<>0) or (updatex) or (updateaxis) then
        begin
          cGlChart1.Chart.m_SelectOpts.activetrend:=3;
          cGlChart1.Chart.setSelected(p2_,index,true);
          cGlChart1.Chart.m_SelectOpts.activetrend:=1;
        end
        else
        // Если были передвинуты точки на границах диапазона
        begin

        end;
      end;
      // Перемещение точек левого чарта
      for j := len - 1 downto 0 do
      begin
        if grow then
          j_:=len-1 - j
        else
          j_:=j;
        index:=ltrend.m_trend.m_selectedPoints[j_];
        if index.t<>0 then
          index.t:=index.t;
        dx :=ltrend.m_trend.m_Max.x - ltrend.m_trend.m_Min.x;
        if index.t=0 then
        begin
          p2.x:=ltrend.m_trend.m_trendData[index.index].x - dx;
          p2.y:=ltrend.m_trend.m_trendData[index.index].y;
        end;
        if index.t=1 then
        begin
          bp:=ltrend.GetBezie(index.index);
          p2.x:=bp.leftp.x - dx;
          p2.y:=bp.leftp.y;
        end;
        if index.t=2 then
        begin
          bp:=ltrend.GetBezie(index.index);
          p2.x:=bp.rightp.x - dx;
          p2.y:=bp.rightp.y;
        end;
        if (index.index<>0) and (index.index<>count-1)
            or (index.t<>0) or (updatex) or (updateaxis) then
        begin
          cGlChart1.Chart.m_SelectOpts.activetrend:=2;
          cGlChart1.Chart.setSelected(p2,index,true);
          cGlChart1.Chart.m_SelectOpts.activetrend:=1;
        end
        else
        // Если были передвинуты точки на границах диапазона
        begin

        end;
     end;
    end;
  end;
  if updateaxis then
  begin
    // сбросить выделение точек кликнув по окну (программно)
    postmessage(cGlChart1.Handle,WM_LBUTTONDOWN,0,0);
    updateaxis:=false;
  end;
end;

procedure TGenFreqForm.cGlChart1Paint(Sender: TObject);
begin
  Edit1.Text:=inttostr(dTime);
end;

procedure TGenFreqForm.cGlChart1Refine(x, y: Single);
var ltrend,ltrend1,ltrend2:ctrend;
    dx:single;
    p:array[0..0] of point2;
begin
  // Если активен чарт редактирования частоты вибрации
  if targetVibr then
  begin
    ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[1]);
    ltrend1:=ctrend(cGlChart1.Chart.m_trends.Items[2]);
    ltrend2:=ctrend(cGlChart1.Chart.m_trends.Items[3]);
    dx :=ltrend1.m_trend.m_Max.x - ltrend1.m_trend.m_Min.x;
    p[0].x:=x-dx;
    p[0].y:=y;
    ltrend1.GetData(p);
    p[0].x:=x+dx;
    p[0].y:=y;
    ltrend2.GetData(p);
  end;
end;

procedure TGenFreqForm.cGlChart1Remove(points: array of selectType);
var ltrend1,ltrend2:ctrend;
begin
  if targetVibr then
  begin
    ltrend1:=ctrend(cGlChart1.Chart.m_trends.Items[2]);
    ltrend2:=ctrend(cGlChart1.Chart.m_trends.Items[3]);
    cglChart1.Chart.m_SelectOpts.activetrend:=2;
    cglChart1.Chart.RemovePoints(points);
    cglChart1.Chart.m_SelectOpts.activetrend:=3;
    cglChart1.Chart.RemovePoints(points);
    cglChart1.Chart.m_SelectOpts.activetrend:=1;
  end;
end;

procedure TGenFreqForm.cGlChart1UpdateAxisByText(Sender: TObject);
var rect,newrect:frect;
    dx,dy:single;
begin
  if (cGlChart1.Chart.m_SelectOpts.b_rescalepoints) then
  begin
    rect.BottomLeft.x:=strtofloat(cGlChart1.Chart.XMinEdit.Text);
    rect.BottomLeft.y:=strtofloat(cGlChart1.Chart.YMinEdit.Text);
    rect.TopRight.x:=strtofloat(cGlChart1.Chart.XMaxEdit.Text);
    rect.TopRight.y:=strtofloat(cGlChart1.Chart.YMaxEdit.Text);
    dx:=(rect.TopRight.x - rect.BottomLeft.x);
    //dy:=(rect.TopRight.y - rect.BottomLeft.y);
    if rezoom then
    begin
      newrect.BottomLeft.x:=rect.BottomLeft.x - dx;
      newrect.TopRight.x:=rect.TopRight.x + dx;
      newrect.BottomLeft.y:=rect.BottomLeft.y;
      newrect.TopRight.y:=rect.TopRight.y;
      rezoom:=false;
    end
    else
      newrect:=rect;
    updateaxis:=true;
    cGlChart1.Chart.ZoomfRect(newrect);
    cGlChart1Moove(self);
    if autozoom then
      zoomvibration(sender);
  end;
  // Необходимо восстанавливать переменную, тк в событии масштабирования по X
  // она в любом случае сбросится в фелс.
  cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=SpeedButton1.Down;
  updateX:=false;
end;

procedure TGenFreqForm.ZoomVibration(sender:tobject);
var ltrend:ctrend;
begin
  autozoom:=false;
  rezoom:=true;
  cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=SpeedButton1.Down;
  cGlChart1.Chart.m_SelectOpts.activetrend:=1;
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[0]);
  ltrend.m_trend.visible:=false;
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[1]);
  ltrend.m_trend.visible:=true;
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[2]);
  ltrend.m_trend.visible:=true;
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[3]);
  ltrend.m_trend.visible:=true;
  cGlChart1.Chart.FullZoom(true,true);
  cGlChart1UpdateAxisByText(self);
end;

procedure TGenFreqForm.ChangeChartTargetButtonClick(Sender: TObject);
var ltrend:ctrend;
begin
  targetVibr:= not targetVibr;
  if targetVibr then
  begin
    ZoomVibration(sender);
  end
  else
  begin
    cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=false;
    cGlChart1.Chart.m_SelectOpts.activetrend:=0;
    ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[0]);
    ltrend.m_trend.visible:=true;
    ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[1]);
    ltrend.m_trend.visible:=false;
    ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[2]);
    ltrend.m_trend.visible:=false;
    ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[3]);
    ltrend.m_trend.visible:=false;
  end;
  cGlChart1.Repaint;
end;

procedure TGenFreqForm.FormCreate(Sender: TObject);
var ltrend:ctrend;
    blue,gray,black:point3;
    data:array of point2;
begin
  rezoom:=false;
  updateaxis:=false;
  black.x:=0;black.y:=0;black.z:=0;
  blue.x:=0.3;blue.y:=0.3;blue.z:=0.7;
  gray.x:=0.75;gray.y:=0.75;gray.z:=0.75;
  targetVibr:=false; // редактирование частоты ротора
  //ltrend:=ctrend(cglChart1.Chart.m_Trends.Items[0]);
  cglChart1.Chart.AddTrend(black,blue);
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[1]);
  setLength(data,4);
  data[0].x:=0;data[0].y:=0;
  data[1].x:=3;data[1].y:=3;
  data[2].x:=5;data[2].y:=3;
  data[3].x:=6;data[3].y:=0;
  ltrend.GetData(data);

  cglChart1.Chart.AddTrend(gray,blue);
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[2]);
  setLength(data,4);
  data[0].x:=-6;data[0].y:=0;
  data[1].x:=-3;data[1].y:=3;
  data[2].x:=-1;data[2].y:=3;
  data[3].x:=0;data[3].y:=0;
  ltrend.GetData(data);

  cglChart1.Chart.AddTrend(gray,blue);
  ltrend:=ctrend(cGlChart1.Chart.m_trends.Items[3]);
  setLength(data,4);
  data[0].x:=6;data[0].y:=0;
  data[1].x:=9;data[1].y:=3;
  data[2].x:=11;data[2].y:=3;
  data[3].x:=12;data[3].y:=0;
  ltrend.GetData(data);
end;

procedure TGenFreqForm.evalFreqData(var FreqData:cpoints);
var len,i:cardinal;
    dx:single;
    a:array of point2;
    ltrend:ctrend;
  // Получить dx из формы
  function GetDXfromForm(var dx:single):boolean;
  begin
    result:=true;
    if UnitsComBoBox.Text[1]='С' then
      dx:=strToFloat(FloatEdit1.Text)
    else if UnitsComBoBox.Text[1]='Г' then
      dx:=1/strToFloat(FloatEdit1.Text)
    else
    begin
      showMessage('Неправильные единицы измерения');
      result:=false;
    end;
  end;
  // Скопировать данные из чарта
  procedure CopyData;
  var i:integer;
  begin
    len:=length(ltrend.m_OutData);
    SetLength(FreqData.ar.ar,len);
    for I := 0 to len - 1 do
    begin
      FreqData.ar.ar[i].x:=ltrend.m_OutData[i].x;
      FreqData.ar.ar[i].y:=ltrend.m_OutData[i].y;
    end;
  end;
  // Расчет массива тиков
  procedure CalcTicks;
  var curFreq,
      curt,      // Время текущего тика
      curdt,     // время до следующего тика
      dt:single; // В секундах
      _curT,_dt:sTickData;
      tickscount,maxTickCount:cardinal; // текущее количество тиков
      startp,endp:point2;
      k:single;
      Datalen,starti,endi,rootcount:integer;
      root:point2;
      part:single; // Часть оборота
      endb:boolean; // Признак выхода из цикла
  begin
    curt:=ltrend.m_trend.m_Min.x;
    Datalen:=length(freqData.ar.ar);
    dt:=ltrend.m_trend.m_Max.x - curt;
    // Длину массива тиков определяем как максимально возможную = f*t
    maxTickCount:=trunc(ltrend.m_trend.m_Max.y*dt);
    SetLength(freqData.ticks.ticks,round(maxTickCount));
    _dt:=CalcTime(dt);
    freqData.ticks.ticks[0].Data:=0;
    freqData.ticks.ticks[0].OverflowCount:=0;
    tickscount:=1;
    part:=0;
    endb:=true;
    while (curt<ltrend.m_trend.m_Max.x) and (TicksCount<maxTickCount) do
    begin
      if not endb then
        break;
      starti:=FindInArrayLowBound(FreqData,curt);
      endi:=FindInArrayHiBound(FreqData,curt);
      startp.x:=FreqData.ar.ar[starti].x;
      endp.x:=FreqData.ar.ar[endi].x;
      startp.y:=FreqData.ar.ar[starti].y;
      endp.y:=FreqData.ar.ar[endi].y;
      while (curt<endp.x) and (TicksCount<maxTickCount) do
      begin
        curFreq:=CalkYbyX(startp,endp,curt);
        // промежуток времени который пройдет за оборот v0*t+at^2/2 = S(один оборот)
        // из уравнения находим время оборота
        // part -часть оборота которая была пройдена на предыдущем участке.
        k:=(endp.y-startp.y)/(endp.x-startp.x);
        root:=SqRoot(k/2,curFreq,(-1 + part),rootcount);
        curdt:=root.x;
        if ((curt + curdt)<=endp.x) and (rootcount<>0) then
        begin
          part:=0;
          curt:=curt + curdt;
          freqData.ticks.ticks[tickscount]:=CalcTime(curt
                                      - ltrend.m_trend.m_Min.x);
          inc(tickscount,1);
        end
        else
        begin
          part:=curFreq*(endp.x - curt) + k*(endp.x - curt)*(endp.x - curt)/2 + part;
          inc(starti,1);
          inc(endi,1);
          if endi>=Datalen then
          begin
           endb:=false;
           break;
          end;
          startp.x:=FreqData.ar.ar[starti].x;
          endp.x:=FreqData.ar.ar[endi].x;
          startp.y:=FreqData.ar.ar[starti].y;
          endp.y:=FreqData.ar.ar[endi].y;
          curt:=startp.x;
          // -----------------------------------------
        end;
      end;
    end;
    SetLength(freqData.ticks.ticks,round(tickscount));
  end;
begin
  ltrend:=ctrend(cGlChart1.Chart.m_trends.items[0]);
  begin
    // Получаем шаг дискретизации в чарте
    if not GetDXfromForm(dx) then exit;
    // Получаем массив точе xy внутри чарта
    ltrend.GetArray(dx);
    // Копируем данные из чарта
    CopyData;
    // Расчет массива тиков по данным XY.
    CalcTicks;
  end;
end;

function TGenFreqForm.ShowModal(var FreqData:cpoints):integer;
begin
  m_freqdata:=FreqData;
  result:=inherited ShowModal;
  if result = mrOk then
  begin
    evalFreqData(freqdata);
  end;
end;

procedure TGenFreqForm.SpeedButton1Click(Sender: TObject);
begin
  cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=SpeedButton1.Down;
end;

// Расчитывает точки которые будут записаны в файл за определленное
// время и по определленной лопатке
procedure TGenFreqForm.ViewPointsClick(Sender: TObject);
var bufdata:array of sTickData;
    Tick:sTickData;
    dT,Tturn,overflow:cardinal; // время прохода одного градуса в обороте
    Ticks:integer;
    count,i,periodcount:integer;
    black,blue:point3;
    ltrend:ctrend;
    freq,phase,T, amplitude:single;
    ar:array of point2;
begin
  // Вычисляет по данным формы массив тиков частоты
  evalFreqData(m_freqdata);
  i:=0;
  count:=length(m_freqdata.ticks.ticks);
  Setlength(bufdata,count);
  // Расчет точек только за определленное время, поэтому часть данных
  // фильтруется по EndTimeEdit и StartTimeEdit
  t:=CalcTime_(m_freqdata.ticks.ticks[0]);
  count:=0;
  while t<EndTimeEdit.FloatNum do
  begin
    if t>StartTimeEdit.FloatNum then
    begin
      bufdata[i]:=m_freqdata.ticks.ticks[i];
      inc(count);
    end;
    inc(i);
    t:=CalcTime_(m_freqdata.ticks.ticks[i]);
  end;
  inc(count);
  setlength(bufdata,count);
  setlength(ar,count);
  // Вычисляем массив времен прихода лопатки на датчик
  for I:=0 to count - 2 do
  begin
    overflow:=bufdata[i+1].OverflowCount;
    // Время оборота
    Tturn:=decTicks(bufdata[i+1].Data, bufdata[i].Data, overflow);
    // Время прохода одного градуса
    dT:=trunc(Tturn/360);
    // Расчет времени прихода лопатки при нулевой амплитуде
    Tick := EvalBladePosTick(BladePosEdit.FloatNum,
                             SensorPosEdit.FloatNum,
                             0,
                             bufdata[i],
                             bufdata[i+1]);
    // Расчет частоты (реально расчитывается из длины периода генерируемой частоты)
    freq:=1/genFreqForm.Getdx;
    t:=calctime_(tick);
    // Расчет фазы  1)перевод в секунды (деление на CardFreq) 2) расчет фазы(время/частоту)
    phase :=frac(T*freq)*360;
    // Расчет отклонения в тиках от ожидаемого времени прихода лопатки
    amplitude:=GetYbyPhase(phase);
    Ticks :=trunc(dT*amplitude);
    overflow:=tick.OverflowCount;
    tick.Data:=AddTicks(tick.Data,ticks,overflow);
    tick.overflowcount:=overflow;
    t:=calctime_(tick);
    ar[i].x:=t;
    // период вибрации
    if autoTCheckBox.Checked then
      t:=genFreqForm.Getdx
    else
      t:=PeriodFloatEdit.FloatNum;    
    periodcount:=trunc(ar[i].x/t);
    ar[i].x:=ar[i].x - periodcount*t;
    ar[i].y:=amplitude;
  end;
  if cGlChart1.gettrendcount=4 then
  begin
    black.x:=0;black.y:=0;black.z:=0;
    blue.x:=0.3;blue.y:=0.3;blue.z:=0.7;
    cGlChart1.Chart.AddTrend(black,blue);
  end;
  cGlChart1.Chart.gettrend(4,ltrend);
  ltrend.Clear;
  ltrend.m_trend.m_DrawLines:=false;
  ltrend.GetData(ar);
  cGlChart1.invalidate;
end;

procedure TGenFreqForm.TVibrEditChange(Sender: TObject);
var dAxis,newdAxis:point2;
    ltrend:ctrend;
    newrect:frect;
    dx:single;
begin
  ltrend:=ctrend(cGlChart1.Chart.m_trends.items[1]);
  cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=false;
  cGlChart1.Chart.FullZoom(true,false);
  cGlChart1.Chart.XMaxEdit.Text:=TVibrEdit.Text;
  cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=true;
  updateX:=true;
  cGlChart1.Chart.StartUpdateAxisByText(cGlChart1.Chart.XMaxEdit);
  //WndProc(cGlChart1.Chart.XMaxEdit.Handle,WM_keydown,13,0);
  dx :=ltrend.m_trend.m_Max.x - ltrend.m_trend.m_Min.x;
  newrect.BottomLeft.x:=ltrend.m_trend.m_Min.x - dx;
  newrect.TopRight.x:=ltrend.m_trend.m_Max.x + dx;
  newrect.BottomLeft.y:=ltrend.m_trend.m_Min.y;
  newrect.TopRight.y:=ltrend.m_trend.m_Max.y;
  cGlChart1.Chart.m_SelectOpts.b_rescalepoints:=false;
  cGlChart1.Chart.ZoomfRect(newrect);
  updateaxis:=false;
end;

end.
