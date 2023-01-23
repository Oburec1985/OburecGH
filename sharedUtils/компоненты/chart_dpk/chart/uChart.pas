unit uChart;

interface

uses classes, stdctrls, controls, messages, windows, types, ExtCtrls, ComCtrls,
  graphics, sysUtils, dialogs,
  upage,
  uaxis,
  ucommonmath,
  uEventList,
  uFrameListener,
  uCommonTypes,
  uChartClickFrListener,
  uChartEvents,
  utrend,
  uBaseObjService,
  udrawobj,
  ubtnlistview,
  ulegend,
  uDoubleCursor,
  uCursors,
  uObjFrameListener,
  uPageFrameListener,
  uPageMng,
  uComponentServises,
  uDrawObjMng,
  uEventTypes,
  // uShader,
  uConfigFile3d,
  uBasePage,
  jcldebug;

type

  cChart = class(tPanel)
  public
    tabs: cPageMngList;
    OBJmNG: cDrawObjMng;
    dc: hdc;
    hrc: HGLRC;
    // модификаторы оконной процедуры
    frList: cFrameList;
    // опции отрисовки
    settings: cardinal;
    // нуждается в перерисовке. Не предназначен для установки пользователем.
    // в концуе оконной процедуры если true будет вызван метод redraw
    needRedraw: boolean;
    // блокирует needRedraw
    RedrawOnDemand: boolean;
    // необходимо перерисовать TV
    needRedrawTV: boolean;
    // пользовательские нажатия
    mouse: smousestruct;
    // дерево отображения структуры компонентов
    tv: ttreeview;
    // легенда
    legend: clegend;
    // идентификатор обьекта который менял курсор. Если какой-то объект
    // поменял курсор то сбросить его в дефолтный имеет право только он
    cursorowner: integer;
    // блокировка оконной процедуры. Управляется с помощью blockwndproc
    cs: TRTLCriticalSection;

    // путь к папке с ресурсами
    path: string;
    configfile: cCfgFile;
    // m_ShaderMng: cShaderManager;
    initGl: boolean;
    // используется framlistener-ами например при двойном клике по метке текста.
    // после взвода отключается при выходе из wndProc
    fDisableInheritedWndProc: boolean;
    fDisabledMsg: integer;
  protected
    fselectObj: cdrawobj;
    // разрешать таскать границы страниц
    fAllowEditPages: boolean;
    // размер выделяющей области при клике
    // (в координатах чарта(пересчитывается из пиксельного размера))
    fselectSize: integer;
    // флаг который защищает от многократного вызова postmessage
    // устанавливается в True после renderscene
    needPostMessage: boolean;
    // число запросов к генерации имени курсора. каждый новый запрос увеличивает на 1
    cursowners: integer;
    EditMenuChartForm: tobject;
  public
    OnDeadLock: tNotifyEvent;
    OnEnterCS: tNotifyEvent;
    OnExitCS: tNotifyEvent;
    deadLockDSC: string;
    debugMode: boolean;
  protected
    fOnMovePoint: TDoubleDataEvent;
    fOnDesroyObj: tNotifyEvent;
    fOnObjEndDrag: tNotifyEvent;
    fOnMouseMove: tNotifyEvent;
    // подменяет fOnEdit
    fOnRightBtnClick: tNotifyEvent;
    // происходит при добавлении точки к тренду. первый параметр - тренд (cTrend),
    // второй - точка cBeziePoint
    fOnAddPoint: TDoubleDataEvent;
    fOnInsertPoint: TDoubleDataEvent;
    // происходит при выделении точки
    fOnSelectPoint: tNotifyEvent;
    fOnKeyDown: TKeyEvent;
    // происходит после инициализации
    fOninit: tNotifyEvent;
    fOnDraw: tNotifyEvent;
    // происходит перед редактированием по правой кнопке
    // сюда добавлять пользовательские диалоги настройки
    fbeforeedit: tNotifyEvent;
    // сюда добавлять реакцию на редактирование
    fafteredit: tNotifyEvent;
    // вызывается при редактировании объекта
    fOnEdit: tNotifyEvent;
    fOnCursorMove: tNotifyEvent;
    fOnSelectObj: tNotifyEvent;
  protected
    procedure doOnCursorMove(sender: tobject);
    // событие происходит
    procedure doOnMouseMove(sender: tobject);
    // происходит при обновлении структуры компонента
    procedure doOnUpdateCfg(sender: tobject);
  protected
    procedure renderscene;
    procedure wndProc(var Message: TMessage); override;
    procedure GetGlContext(H: Hwnd);
    procedure deletecontext;
    procedure UpdateMouse(var message: TMessage);
    // создание объектов движка компонента
    procedure CreateEngStructs;
    procedure destroyEngStructs;
    // создание модификаторов оконной процедуры
    procedure CreateFrameListeners;
    procedure lincEvents;
    procedure CreateParams(var Params: TCreateParams);
    procedure redrawComponents;
    procedure setactivepage(page: cbasepage);
    function getActivePage: cbasepage;
    procedure setactivepageMng(tab: cPageMng);
    function getActivePageMng: cPageMng;
    procedure initscene;
    function gettrend: ctrend;
    // обновить дерево объектов
    procedure updateTV;
    procedure doOnDeleteObj(sender: tobject);
  public
    procedure doOnInsertPoint(data: tobject; subdata: tobject);
  protected
    procedure setpath(p_path: string);
    procedure setselectObj(obj: cdrawobj);
    function getShowLegend: boolean;
    procedure setShowLegend(v: boolean);
    function getShowTV: boolean;
    procedure setShowTV(v: boolean);
    procedure setimagelist(im: timagelist);
    function getimagelist: timagelist;
    procedure setAllowEditPages(b: boolean);
    function getAllowEditPages: boolean;
    // происходит при выборе нового объекта в дереве
    procedure doTVClick(sender: tobject);
    procedure doRBtnClick(sender: tobject);
    procedure CfgTVChange(sender: tobject; Node: TTreeNode);
    procedure TVMouseUp(sender: tobject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
  public
    Constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure EnterCS;
    procedure ExitCS;
  public
    procedure SelectInTV(obj: cdrawobj);
    procedure SaveToFile(filename: string);
    property activeTab: cPageMng read getActivePageMng write setactivepageMng;
    property activePage: cbasepage read getActivePage write setactivepage;
    property selected: cdrawobj read fselectObj write setselectObj;
    // с - новый курсор
    procedure setcursor(c: integer; cursowner: integer); overload;
    // гет контрол - перехватить управление палюбому
    procedure setcursor(c: integer; cursowner: integer; getControl: boolean);
      overload;
    // убить объект
    procedure deleteObj(obj: cdrawobj);
    // убить выбранный
    procedure deleteselected;
    // копировать в клипборт
    procedure CopyScreenToClipboard;
    property activetrend: ctrend read gettrend;
    function GenCursOwnerName: integer;
    function addPage: cpage;
    function addTab: cPageMng;
    function GetPage(i: integer): cpage; overload;
    function GetPage(p_name: string): cpage; overload;
    // перерисовывает окно послыая сообщение wm_paint
    procedure redraw;
    function getcolor(i: integer): point3;
    procedure doSelectObj(sender: tobject);
  published
    // события
    property OnRightMBtnClick
      : tNotifyEvent read fOnMouseMove write fOnMouseMove;
    property OnKeyDown;
    property OnObjEndDrag: tNotifyEvent read fOnObjEndDrag write fOnObjEndDrag;
    property OnMouseMove: tNotifyEvent read fOnMouseMove write fOnMouseMove;
    property OnDestroyObj: tNotifyEvent read fOnDesroyObj write fOnDesroyObj;
    property OnRBtnClick: tNotifyEvent read fOnRightBtnClick write
      fOnRightBtnClick;
    property OnMovePoint: TDoubleDataEvent read fOnMovePoint write fOnMovePoint;
    // происходит при добавлении точки к тренду. первый параметр - тренд (cTrend),
    // второй - точка cBeziePoint
    property OnAddPoint: TDoubleDataEvent read fOnAddPoint write fOnAddPoint;
    property OnInsertPoint
      : TDoubleDataEvent read fOnInsertPoint write fOnInsertPoint;
    // происходит при выделении точки
    property OnSelectPoint
      : tNotifyEvent read fOnSelectPoint write fOnSelectPoint;
    // происходит при инициализации
    property OnInit: tNotifyEvent read fOninit write fOninit;
    property OnDraw: tNotifyEvent read fOnDraw write fOnDraw;
    property OnEditObj: tNotifyEvent read fOnEdit write fOnEdit;
    property OnCursorMove: tNotifyEvent read fOnCursorMove write fOnCursorMove;
    property OnSelectObj: tNotifyEvent read fOnSelectObj write fOnSelectObj;
    // происходит перед редактированием по правой кнопке
    // сюда добавлять пользовательские диалоги настройки
    property onbeforeedit: tNotifyEvent read fbeforeedit write fbeforeedit;
    property onafteredit: tNotifyEvent read fafteredit write fafteredit;

    property allowEditPages: boolean read getAllowEditPages write
      setAllowEditPages;
    property imagelist: timagelist read getimagelist write setimagelist;
    property Resources: string read path write setpath;
    property showTV: boolean read getShowTV write setShowTV;
    property showLegend: boolean read getShowLegend write setShowLegend;
    property selectSize: integer read fselectSize write fselectSize;
  end;

var
  g_initGL:boolean = false;
const
  // рисовать селектирующий прямойгольник
  c_drawSelRect = $000001;

  c_BlockWndProc = $000001;
  c_InWndProc = $000002;

implementation

uses
  uEditMenuChartForm, dglopengl, Forms;

// ==========================Получение Gl контекста======================
procedure cChart.GetGlContext(H: Hwnd);
var
  nPixelFormat: integer;
  pfd: TPixelFormatDescriptor;
  p: cpage;
begin
  if not g_initGL then
    g_initGL:=InitOpenGL('opengl32.dll', 'glu32.dll');
  dc := GetDC(Handle);

  hrc := CreateRenderingContext(dc, [opDoubleBuffered], 32, 24, 8, 0, 0, 0);
  ActivateRenderingContext(dc, hrc, true);

  wglMakeCurrent(dc, hrc);

  p := cpage(activePage);
  if p <> nil then
    p.SetPointSize(5);

  initGl := true;
end;

procedure cChart.deletecontext;
begin
  // перед удалением контекста надо сбросить текущий контекст OpenGL подсистемы
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
end;

procedure cChart.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // WS_CLIPCHILDREN - не перерисовывать дочернее окно, при перерисовке родительского
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

// Войти в настройку движка
procedure cChart.CfgTVChange(sender: tobject; Node: TTreeNode);
begin
  selected := cdrawobj(Node.data);
end;

Constructor cChart.Create(AOwner: TComponent);
var
  dc: hdc;
begin
  RedrawOnDemand := FALSE;
  InitializeCriticalSection(cs);
  inherited Create(AOwner);
  selectSize := 5;
  cursor := crdefault;
  cursowners := 1;
  cursorowner := -1;
  OBJmNG := cDrawObjMng.Create;
  OBJmNG.chart := self;
  // создание менеджера дерева
  tv := ttreeview.Create(self);
  tv.name := 'ChartTV';
  // tv.Visible:=false;
  tv.Parent := self;
  tv.Align := alleft;
  tv.Width := 200;
  tv.OnClick := doTVClick;
  tv.OnChange := CfgTVChange;
  tv.OnMouseUp := TVMouseUp;
  // создание легенды
  legend := clegend.Create(self);
  legend.name := 'ChartLegend';
  // Создание событий
  lincEvents;
  initGl := FALSE;

  Parent := TWinControl(AOwner);
  Width := 400;
  Height := 400;
  top := 10;
  left := 10;
  settings := 0;
  EditMenuChartForm := tEditMenuChartForm.Create(nil);
  tEditMenuChartForm(EditMenuChartForm).linc(self);
  selected := nil;

  // Перенесено из CreateStructs 23.01.23
  tabs := cPageMngList.Create;
  OBJmNG.Add(tabs);
  tabs.chart := self;

  tabs.activeTab:=tabs.addTab;
  tabs.activetab.lincchart(self);

  cpage(tabs.activetab.addpage(true)); ///

  debugMode := FALSE;
end;

destructor cChart.destroy;
begin
  if initGl then
  begin
    destroyEngStructs;
    deletecontext;
  end;
  initGl := FALSE;
  // if m_ShaderMng <> nil then
  // begin
  // m_ShaderMng.destroy;
  if configfile <> nil then
  begin
    configfile.destroy;
  end;
  // end;
  tv.destroy;
  tv := nil;

  // if Owner = nil then
  if legend <> nil then
    legend.destroy;
  legend := nil;

  tabs := nil;
  OBJmNG.destroy;
  OBJmNG := nil;

  EditMenuChartForm.destroy;
  EditMenuChartForm := nil;

  DeleteCriticalSection(cs);
  // showmessage('delChart');
  inherited;
end;

function cChart.GetPage(i: integer): cpage;
begin
  result := activeTab.GetPage(i);
end;

function cChart.GetPage(p_name: string): cpage;
begin
  result := activeTab.GetPage(p_name);
end;

function cChart.addPage: cpage;
begin
  result := activeTab.addPage(true);
  if activePage = nil then
    activePage := result;
end;

procedure cChart.CreateEngStructs;
begin
  OBJmNG.initfonts;
  // нельзя переносить до инициации контекста! в Create
  //tabs.LincChart(self);
  // создаем список оконных процедур
  frList := cFrameList.Create(self);
  CreateFrameListeners;
  updateTV;
end;

function cChart.getimagelist: timagelist;
begin
  result := OBJmNG.images_32;
end;

procedure cChart.setimagelist(im: timagelist);
begin
  OBJmNG.images_32 := im;
  if tv <> nil then
    tv.Images := im;
end;

procedure cChart.destroyEngStructs;
begin
  frList.destroy;
  frList := nil;
end;

procedure cChart.UpdateMouse(var message: TMessage);
var
  p, p_: point2;
  p2i: tpoint;
  page: cdrawobj;
begin
  if tabs = nil then
    exit;
  case message.Msg of
    wm_mousemove:
      begin
        page := activePage;
        // Преобразразование стрейфа
        p2i.X := loWord(message.lParam);
        // Преобразование кооржинат по y
        if message.lParam > 0 then
          mouse.ipos.Y := hiWord(message.lParam);
        if mouse.ipos.Y > Height then
          mouse.ipos.Y := 0;
        p2i.Y := Height - mouse.ipos.Y;
        mouse.ipos_inv.Y := Height - mouse.ipos.Y;
        // Преобразование кооржинат по x
        if p2i.X < 65000 then
        begin
          mouse.ipos.X := p2i.X;
          mouse.ipos_inv.X := p2i.X;
        end
        else // Если ушли в зашкал по x
        begin
          if page <> nil then
          begin
            if page is cpage then
            begin
              mouse.pos.X := cpage(page).activeAxis.min.X;
              mouse.ipos.X := 0;
              mouse.ipos_inv.X := 0;
            end;
          end;
        end;
        if page <> nil then
        begin
          if page is cpage then
          begin
            if cpage(page).activeAxis <> nil then
            begin
              p := cpage(page).p2itoP2(mouse.ipos_inv);
              mouse.strafe := p2(p.X - mouse.pos.X, p.Y - mouse.pos.Y);
              mouse.pos := p2(p.X, p.Y);

              p_ := cpage(page).Point2ToTrend(mouse.pos,
                cpage(page).activeAxis);
              mouse.activeAxisstrafe := p2d(p_.X - mouse.activeAxisPos.X,
                p_.Y - mouse.activeAxisPos.Y);
              mouse.activeAxisPos := p_;
            end;
          end;
        end;
        // вызов событий передвижения мыши
        if OBJmNG.events <> nil then
          OBJmNG.events.CallAllEvents(E_OnMouseMove);
      end;
    wm_lbuttondown:
      begin
        mouse.DragBegginPos := mouse.ipos;
        mouse.mousedown := true;
      end;
    wm_rbuttondown:
      begin
        if Assigned(fOnRightBtnClick) then
          doRBtnClick(self)
        else
          tEditMenuChartForm(EditMenuChartForm).ShowModal;
      end;
    wm_lbuttonup:
      begin
        mouse.mousedown := FALSE;
      end;
  end;
end;

procedure cChart.redraw;
begin
  if needPostMessage then
  begin
    if tabs <> nil then
    begin
      needRedraw := FALSE;
      // windows.InvalidateRect(m_wndContext.handle, nil, false);
      // renderscene;
      needPostMessage := FALSE;
      postmessage(Handle, WM_PAINT, 0, 0);
      // redrawComponents;
    end;
  end;
end;

procedure cChart.renderscene;
var
  ps: PaintStruct;
begin
  if not initGl then
    exit;
  updateTV;
  // если не коментировать wglMakeCurrent происходит утечка памяти
  if wglGetCurrentContext <> hrc then
    wglMakeCurrent(dc, hrc);
  BeginPaint(Handle, ps);
  glClearColor(0.9, 0.9, 0.3, 1);
  glClear(GL_COLOR_BUFFER_BIT); // очистка буфера цвета
  if activeTab <> nil then
  begin
    activeTab.draw;
  end;
  OBJmNG.events.CallAllEvents(e_onDraw);
  SwapBuffers(dc);
  EndPaint(Handle, ps);
  needPostMessage := true;
  // вероятно не коректно так делать (скорее надо вызывать в wm_size)
  // wglMakeCurrent(0,0);
end;

procedure cChart.wndProc(var Message: TMessage);
var
  i, j: integer;
  tab: cPageMng;
  page: cpage;
begin
  // E-nterCS;
  if initGl then
  begin
    if tabs <> nil then
    begin
      // обновление координат мыши
      UpdateMouse(message);
      // вызов модификаторов оконной процедуры
      if frList <> nil then
      begin
        if tabs.activeTab <> nil then
          frList.wndProc(message, mouse);
      end;
    end;
  end;
  // отрисовка окна
  case message.Msg of
    CM_EXIT:
    begin

    end;
    WM_KEYDown:
    begin
      // cpage(activePage).caption:='k_down';
    end;
    WM_KEYup:
    begin
      // cpage(activePage).caption:='k_Up';
    end;
    WM_PAINT:
    begin
      renderscene;
      if Assigned(fOnDraw) then
        fOnDraw(self);
    end;
    wm_size:
      begin
        initscene;
        if activeTab <> nil then
        begin
          // activeTab.doalign(activeTab.GetPage(0));
          updateTV;
          for i := 0 to tabs.ChildCount - 1 do
          begin
            tab := tabs.getTab(i);
            for j := 0 to tab.ChildCount - 1 do
            begin
              page := tab.GetPage(j);
              // page.ChangeSize;
              page.updateRelativeBound;
            end;
          end;
          OBJmNG.events.CallAllEvents(e_OnChartResize);
        end;
      end;
  end;
  // активизация перерисовки окна
  if not RedrawOnDemand then
  begin
    if needRedraw then
    begin
      redraw;
    end;
  end;
  if message.Msg <> cn_keydown then
  begin
    if not fDisableInheritedWndProc then
    begin
      inherited;
    end
    else
    begin
      if fDisabledMsg <> Message.Msg then
      begin
        inherited;
      end
      else
      begin
        fDisableInheritedWndProc := FALSE;
        fDisabledMsg := 0;
      end;
    end;
  end;
end;

procedure cChart.CreateFrameListeners;
var
  fr: cFrameListener;
begin
  fr := cDoubleCursorFrameListener.Create(self);
  frList.Add(fr);
  fr := cClickFrListener.Create(self);
  frList.Add(fr);
  fr := cObjFrListener.Create(self);
  frList.Add(fr);
  fr := cPageFrListener.Create(self);
  frList.Add(fr);
end;

procedure cChart.doRBtnClick(sender: tobject);
begin
  if Assigned(fOnRightBtnClick) then
  begin
    fOnRightBtnClick(sender);
  end;
end;

procedure cChart.doOnMouseMove(sender: tobject);
begin
  if Assigned(fOnMouseMove) then
  begin
    if activePage <> nil then
      fOnMouseMove(self);
  end;
end;

procedure cChart.lincEvents;
begin
  OBJmNG.events.AddEvent('ChartOnCursorMove', e_OnMoveCursor + e_OnMoveCursor2,
    doOnCursorMove);
  OBJmNG.events.AddEvent('OnMouseMove', E_OnMouseMove, doOnMouseMove);
  // происходит при обновлении структуры компонента
  OBJmNG.events.AddEvent('OnCfgUpdate', e_onLincParent + E_OnEngUpdateList,
    doOnUpdateCfg);
  // происходит при обновлении имени
  OBJmNG.events.AddEvent('OnNameUpdate', e_onChangeName, doOnUpdateCfg);
  // происходит при удалении объекта
  OBJmNG.events.AddEvent('OnDestroy', E_OnDestroyObject, doOnDeleteObj);
end;

procedure cChart.redrawComponents;
var
  i: integer;
begin
  for i := 0 to componentcount - 1 do
  begin
    TWinControl(components[i]).Repaint;
  end;
end;

procedure cChart.setactivepageMng(tab: cPageMng);
begin
  if tabs <> nil then
    tabs.activeTab := tab;
end;

procedure cChart.setAllowEditPages(b: boolean);
begin
  fAllowEditPages := b;
end;

function cChart.getAllowEditPages: boolean;
begin
  result := fAllowEditPages;
end;

function cChart.getActivePageMng: cPageMng;
begin
  if tabs <> nil then
    result := tabs.activeTab
  else
    result := nil;
end;

procedure cChart.setactivepage(page: cbasepage);
var
  tab: cPageMng;
begin
  if activeTab = nil then
  begin
    if page.Parent <> nil then
      activeTab := cPageMng(page.Parent);
  end;
  if activeTab <> nil then
  begin
    tab := activeTab;
    tab.activePage := page;
  end;
end;

function cChart.getActivePage: cbasepage;
begin
  if activeTab <> nil then
  begin
    result := activeTab.activePage;
  end
  else
    result := nil;
end;

procedure cChart.initscene;
begin
  if HandleAllocated then
  begin
    if not initGl then
    begin
      GetGlContext(Handle);
      CreateEngStructs;
      setpath(path);
      if Assigned(fOninit) then
        fOninit(self);
    end;
  end;
end;

function cChart.gettrend: ctrend;
var
  axis: caxis;
  obj: cdrawobj;
begin
  result := nil;
  if activePage <> nil then
  begin
    axis := cpage(activePage).activeAxis;
    if axis <> nil then
    begin
      obj := selected;
      if obj <> nil then
      begin
        if obj is ctrend then
        begin
          if obj.Parent = axis then
          begin
            result := ctrend(obj);
            exit;
          end;
        end;
      end;
      obj := cdrawobj(cpage(activePage).activeAxis.getchild(0));
      if obj is ctrend then
        result := ctrend(obj);
    end;
  end;
end;

function cChart.getShowTV: boolean;
begin
  result := tv.Visible;
end;

procedure cChart.setShowTV(v: boolean);
var
  page: cpage;
begin
  tv.Visible := v;
  page := cpage(activePage);
  if page <> nil then
  begin
    page.ChangeSize;
    redraw;
    updateTV;
  end;
end;

procedure ShowPage(tv: ttreeview; page: cpage);
begin

end;

procedure cChart.SelectInTV(obj: cdrawobj);
var
  Node: TTreeNode;
begin
  if tv <> nil then
  begin
    Node := FindNodeInTV(obj, tv);
    if Node <> nil then
    begin
      // tv.Select(node,[]);
      Node.Focused := true;
      Node.selected := true;
      Node.Expanded := true;
    end;
  end;
end;

procedure cChart.updateTV;
begin
  if needRedrawTV then
  begin
    needRedrawTV := FALSE;
    tv.Items.Clear;
    showInTreeView(tv, tabs);
  end;
end;

procedure cChart.doOnUpdateCfg(sender: tobject);
begin
  needRedrawTV := true;
end;

procedure cChart.doSelectObj(sender: tobject);
begin
  if Assigned(fOnSelectObj) then
    fOnSelectObj(sender);
end;

procedure cChart.doTVClick(sender: tobject);
begin
  if tv.selected <> nil then
  begin
    selected := cdrawobj(tv.selected.data);
  end;
end;

procedure cChart.TVMouseUp(sender: tobject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
  begin
    tEditMenuChartForm(EditMenuChartForm).ShowModal;
  end;
end;

procedure cChart.setcursor(c: integer; cursowner: integer);
begin
  // если новый владелец не -1, если владеле = новый владелец,
  if (cursowner = -1) or (cursowner = cursorowner) or (cursorowner = -1) then
  begin
    if (cursor <> c) then
    begin
      cursor := c;
      if cursorowner <> cursowner then
        cursorowner := cursowner;
      if cursor = crdefault then
      begin
        cursorowner := -1;
      end;
      SetCursorByHinst(cursor, Handle);
    end
  end;
end;

procedure cChart.setcursor(c: integer; cursowner: integer; getControl: boolean);
begin
  // если новый владелец -1, если владеле = новый владелец,
  if (cursowner = -1) or (cursowner = cursorowner) or (cursorowner = -1)
    or getControl then
  begin
    if (cursor <> c) then
    begin
      cursor := c;
      if cursorowner <> cursowner then
        cursorowner := cursowner;
      if cursor = crdefault then
      begin
        cursorowner := -1;
      end;
      SetCursorByHinst(cursor, Handle);
    end
  end;
end;

procedure cChart.SaveToFile(filename: string);
var
  bmp: tbitmap;
  canva: tcanvas;
begin
  renderscene;
  redrawComponents;
  // копируем контекст
  canva := tcanvas.Create;
  canva.Handle := dc;
  bmp := tbitmap.Create;
  bmp.Width := Width;
  bmp.Height := Height;
  bmp.Canvas.FillRect(BoundsRect);
  canva.lock;
  bmp.Canvas.lock;
  bmp.Canvas.CopyRect(Rect(0, 0, Width, Height), canva,
    Rect(0, 0, Width, Height));
  canva.unlock;
  bmp.Canvas.unlock;
  bmp.SaveToFile(filename);
  bmp.destroy;
  canva.destroy;
  if wglGetCurrentContext <> hrc then
    wglMakeCurrent(dc, hrc);
end;

procedure cChart.deleteObj(obj: cdrawobj);
begin
  if obj is cdrawobj then
  begin
    if obj is cPageMngList then
      exit;
    obj.destroy;
  end;
end;

procedure cChart.deleteselected;
begin
  deleteObj(fselectObj);
end;

procedure cChart.CopyScreenToClipboard;
var
  dx, dy: integer;
  hDestDC, hBM, hbmOld: THandle;
begin
  dx := Width;
  dy := Height;
  hDestDC := CreateCompatibleDC(dc);
  hBM := CreateCompatibleBitmap(dc, dx, dy);
  hbmOld := SelectObject(hDestDC, hBM);
  BitBlt(hDestDC, 0, 0, dx, dy, dc, 0, 0, SRCCopy);
  OpenClipBoard(Handle);
  EmptyClipBoard;
  SetClipBoardData(CF_Bitmap, hBM);
  CloseClipBoard;
  SelectObject(hDestDC, hbmOld);
  DeleteObject(hBM);
  DeleteDC(hDestDC);
end;

procedure cChart.doOnInsertPoint(data: tobject; subdata: tobject);
begin
  if Assigned(fOnInsertPoint) then
  begin
    fOnInsertPoint(data, subdata);
  end;
end;

procedure cChart.doOnCursorMove(sender: tobject);
begin
  if Assigned(fOnCursorMove) then
    fOnCursorMove(sender);
end;

procedure cChart.doOnDeleteObj(sender: tobject);
begin
  if tabs <> nil then
  begin
    if sender = activePage then
    begin
      activePage := nil;
    end;
    if sender = tabs.activeTab then
    begin
      tabs.activeTab := nil;
    end;
    if sender = tabs then
    begin
      tabs := nil;
    end;
    redraw;
  end;
  if Assigned(fOnDesroyObj) then
  begin
    fOnDesroyObj(sender);
  end;
end;

function cChart.GenCursOwnerName: integer;
begin
  result := cursowners;
  inc(cursowners);
end;

procedure cChart.setselectObj(obj: cdrawobj);
begin
  fselectObj := obj;
  if obj = nil then
    exit;
  if (not(obj is cPageMng)) and (not(obj is cPageMngList)) then
  begin
    if obj is cpage then
      activePage := cpage(obj)
    else
    begin
      // activePage := cpage(obj.GetParentByClassName('cPage'));
      activePage := cbasepage(obj.getCarrierPage);
    end;
  end;
  doSelectObj(obj);
end;

function cChart.addTab: cPageMng;
begin
  result := tabs.addTab;
end;

procedure cChart.EnterCS;
begin
  EnterCriticalSection(cs);
end;

procedure cChart.ExitCS;
begin
  LeaveCriticalSection(cs);
end;

procedure cChart.setpath(p_path: string);
var
  // shader: cshader;
  lpath, shadername: string;

begin
  path := p_path;
  if initGl then
  begin
    { if m_ShaderMng = nil then
      begin
      if fileexists(path) then
      begin
      configfile := cCfgFile.Create(path);
      m_ShaderMng := cShaderManager.Create;
      shadername := configfile.findShaderFile('1dLine');
      if shadername <> '' then
      begin
      lpath := extractfiledir(shadername);
      shadername := extractfilename(shadername);
      if shadername[length(shadername)] = '*' then
      setlength(shadername, length(shadername) - 2);
      shader := cshader.Create(lpath, shadername);
      m_ShaderMng.Add(shader);
      end;
      end;
      end; }
  end;
end;

function cChart.getShowLegend: boolean;
begin
  if legend <> nil then
    result := legend.Visible
  else
    result := FALSE;
end;

procedure cChart.setShowLegend(v: boolean);
begin
  if legend <> nil then
  begin
    legend.Visible := v;
  end;
end;

function cChart.getcolor(i: integer): point3;
begin
  case i of
    0:
      result := blue;
    1:
      result := green;
    2:
      result := red;
    3:
      result := yellow;
    4:
      result := black;
    5:
      result := purple;
    6:
      result := acid;
    7:
      result := bRIGHTbLUE;
    8:
      result := Orange;
    9:
      result := violet;
    10:
      result := brightyellow;
    11:
      result := Lilac;
  else
    result := blue;
  end
end;

end.
