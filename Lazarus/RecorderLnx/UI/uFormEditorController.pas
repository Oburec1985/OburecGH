unit uFormEditorController;

{
  Модуль uFormEditorController

  Назначение:
    Контроллер design-time редактирования мнемосхем RecorderLnx. Модуль
    подключается к LCL-полотну, рисует модельные компоненты страницы и
    обрабатывает мышь/клавиатуру для выбора, перемещения и изменения размеров.

  Место в архитектуре:
    UI adapter/controller. Работает поверх TRecorderFormPage и LCL-controls,
    не содержит логики сбора данных, тегов, записи или потоков источников.

  Алгоритм работы:
    1. MainForm создает TFormEditorController для панели-полотна и передает
       callback AGetPage. Callback возвращает текущий TRecorderFormPage.
    2. Render полностью перестраивает LCL-представление активной страницы:
       каждый TRecorderVisualComponent получает временный TPanel на полотне.
       Эти TPanel не являются моделью и не сохраняются в конфигурацию.
    3. Выбор хранится как список индексов компонентов страницы. Одинарный клик
       выбирает компонент, Ctrl+клик добавляет/убирает его из выбора, протяжка
       пустого места создает прямоугольник выбора.
    4. Текущая операция хранится в fOperation. Операция выбирается только
       мышью: клик по центру выбранного компонента начинает move/drag, клик по
       краям или фиолетовым ручкам выделения начинает resize. Отдельной кнопки
       выбора операции пока нет.
    5. При старте операции BeginOperation запоминает стартовую точку мыши,
       общий прямоугольник группы и стартовые Bounds всех выбранных компонентов.
       UpdateOperation каждый раз пересчитывает модельные Bounds относительно
       этих стартовых значений, поэтому накопительная ошибка от предыдущих
       MouseMove не нарастает.
    6. Клавиатура используется для точной правки геометрии: стрелки двигают
       выбранные компоненты на 1 пиксель, Ctrl+Shift+стрелки двигают на 5
       пикселей, Ctrl+стрелки меняют размер на 1 пиксель, Shift+стрелки меняют
       размер на 5 пикселей.
    7. Ctrl+C сохраняет снимки выбранных компонентов во внутренний буфер
       редактора. Ctrl+V создает новые компоненты через TRecorderComponentFactory,
       копирует свойства, добавляет их на активную страницу и выделяет вставку.

  Ограничения:
    Используются кроссплатформенные LCL-события вместо прямых WinAPI-сообщений.
    При Enabled = False обработчики остаются подключенными, но edit-функции
    отключены и выбор очищается.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Math, Controls, ExtCtrls, Graphics, Buttons,
  LCLType, uRecorderFormModel, uRecorderTags, uRecorderOglOscillogramView;

type
  PRecorderRect = ^TRecorderRect;

  { TFormEditorOperation
    Текущая мышиная операция редактора.
    
    feoNone - редактор ничего не тащит.
    feoDrag - перемещение выбранных компонентов мышью.
    feoSelectRect - выделение протяжкой пустого места.
    feoResize* - изменение размера выбранной группы за соответствующий край
      или угол. Эти операции запускаются только мышью по краям/ручкам. }
  TFormEditorOperation = (
    feoNone,
    feoDrag,
    feoSelectRect,
    feoResizeLeft,
    feoResizeTop,
    feoResizeRight,
    feoResizeBottom,
    feoResizeTopLeft,
    feoResizeTopRight,
    feoResizeBottomLeft,
    feoResizeBottomRight
  );

  { Колбэк получения текущей активной страницы редактора }
  TGetEditorPageEvent = function: TRecorderFormPage of object;
  { Событийный колбэк уведомления об изменении в редакторе }
  TEditorNotifyEvent = procedure of object;

  { TFormEditorClipboardItem
    Снимок одного компонента для внутреннего copy/paste. Это не живой
    TRecorderVisualComponent: элемент буфера не зарегистрирован в фабрике и не
    принадлежит странице. Реальный компонент создается только при Paste. }
  TFormEditorClipboardItem = class
  public
    BindingMode: TRecorderTagBindingMode; { Режим привязки к тегу }
    Bounds: TRecorderRect;     { Границы компонента }
    Id: string;                { Идентификатор компонента }
    DisplayFormat: string;     { Формат отображения вещественных чисел }
    Name: string;              { Имя компонента }
    TagName: string;           { Привязанный тег }
    TagOffset: Integer;        { Смещение относительно выбранного тега }
    Text: string;              { Отображаемый статический текст }
    TypeId: string;            { Идентификатор типа компонента }
  end;

  { TFormEditorUndoState
    Объект хранения состояния отмены (Undo) для одной страницы }
  TFormEditorUndoState = class
  private
    fItems: TList;             { Список снимков компонентов TFormEditorClipboardItem }
    fSelectedIds: TStringList; { Идентификаторы выделенных элементов }
  public
    PageId: string;            { Идентификатор страницы }
    constructor Create;
    destructor Destroy; override;
    property Items: TList read fItems;
    property SelectedIds: TStringList read fSelectedIds;
  end;

  { TFormEditorController
    Управляет design-time поведением мнемосхемы: отрисовкой временных LCL
    контролов по доменной модели, выбором компонентов, мышиным drag/resize и
    клавиатурным точным перемещением. Контроллер не владеет TRecorderFormPage:
    страница каждый раз берется через callback AGetPage. }
  TFormEditorController = class
  private
    fCanvas: TPanel;                               { Панель-полотно редактора }
    fClipboard: TList;                             { Буфер обмена (TFormEditorClipboardItem) }
    fComponentFactory: TRecorderComponentFactory;  { Фабрика создания компонентов }
    fDisplaySeconds: Double;                       { Длина окна данных для embedded-графиков }
    fEnabled: Boolean;                             { Флаг активности режима редактирования }
    fGetPage: TGetEditorPageEvent;                 { Колбэк получения текущей страницы }
    fOnChanged: TEditorNotifyEvent;                { Событие изменения данных в редакторе }
    fOperation: TFormEditorOperation;              { Текущая активная операция }
    fSelected: TList;                              { Выбранные индексы компонентов (Pointer(Index)) }
    fSelectionFrame: TShape;                       { Рамка выделения прямоугольником }
    fDragStartPoint: TPoint;                       { Стартовая точка перемещения/выбора }
    fDragStartBounds: TList;                       { Стартовые границы выделенных компонентов }
    fStartGroupBounds: TRecorderRect;              { Стартовые групповые границы выделения }
    fUndoStack: TList;                             { Стек отката изменений (TFormEditorUndoState) }
    fTagRegistry: TRecorderTagRegistry;            { Реестр тегов для live-компонентов }
    fOperationUndoSaved: Boolean;                  { Флаг сохранения состояния Undo для текущей операции }

    procedure CanvasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComponentMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChildMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ChildMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ResizeHandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetEnabled(AValue: Boolean);
    function GetActivePage: TRecorderFormPage;
    procedure BeginOperation(AOperation: TFormEditorOperation; X, Y: Integer);
    procedure UpdateOperation(X, Y: Integer);
    procedure EndOperation;
    procedure ClearDragStartBounds;
    procedure ClearClipboard;
    procedure ClearUndoStack;
    procedure PushUndoState;
    procedure RestoreUndoState(AState: TFormEditorUndoState);
    function CreateUndoState(APage: TRecorderFormPage): TFormEditorUndoState;
    function CreateComponentFromSnapshot(
      AItem: TFormEditorClipboardItem): TRecorderVisualComponent;
    procedure RenderLive;
    procedure NotifyChanged;
    procedure CopySelected;
    procedure PasteClipboard;
    function ClipboardItemFromComponent(
      AComponent: TRecorderVisualComponent): TFormEditorClipboardItem;
    function CreateComponentFromClipboard(
      AItem: TFormEditorClipboardItem): TRecorderVisualComponent;
    function UniqueComponentId(APage: TRecorderFormPage;
      const ABaseId: string): string;
    function UniqueComponentName(APage: TRecorderFormPage;
      const ABaseName: string): string;
    function IsSelected(AIndex: Integer): Boolean;
    procedure SelectIndex(AIndex: Integer; AAdd: Boolean);
    procedure ToggleIndex(AIndex: Integer);
    procedure SelectByRect(const ARect: TRect);
    function GetGroupBounds(out ABounds: TRecorderRect): Boolean;
    function GetResizeOperationAtControlPoint(AControl: TControl; X,
      Y: Integer): TFormEditorOperation;
    function CursorForOperation(AOperation: TFormEditorOperation): TCursor;
    procedure UpdateHoverCursor(AControl: TControl; X, Y: Integer);
    function NormalizeRect(X1, Y1, X2, Y2: Integer): TRect;
    function RecorderRectToRect(const ABounds: TRecorderRect): TRect;
    function RectsIntersectPartial(const A, B: TRect): Boolean;
  public
    { Создает контроллер для полотна.
      ACanvas - панель, внутри которой строится редактор мнемосхемы.
      AGetPage - callback, возвращающий активную страницу модели.
      AComponentFactory - фабрика компонентов. }
    constructor Create(ACanvas: TPanel; AGetPage: TGetEditorPageEvent;
      AComponentFactory: TRecorderComponentFactory);
    { Деструктор корректно очищает буфер обмена, стек Undo и выделения }
    destructor Destroy; override;

    { Снимает выделение со всех компонентов, не меняя модель страницы. }
    procedure ClearSelection;

    { Задает контекст данных для live-компонентов на мнемосхеме. }
    procedure SetDataContext(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);

    { Полностью перестраивает визуальное представление активной страницы. }
    procedure Render;

    { Удаляет выбранные компоненты из активной страницы. }
    procedure DeleteSelected;
    { Фиксирует текущую точку отката в Undo }
    procedure RememberUndoStep;
    { Возвращает на один шаг Undo назад }
    procedure UndoLastStep;
    { Полностью очищает историю изменений для текущей страницы }
    procedure ClearUndoHistory;

    { Обрабатывает клавиатуру редактора.
      Стрелки двигают выбранные компоненты на 1 пиксель.
      Ctrl+Shift+стрелки двигают выбранные компоненты на 5 пикселей.
      Ctrl+стрелки меняют размер на 1 пиксель.
      Shift+стрелки меняют размер на 5 пикселей.
      Ctrl+C копирует выбранные компоненты.
      Ctrl+V вставляет компоненты со смещением. }
    procedure HandleKeyDown(var Key: Word; Shift: TShiftState);
    
    property Enabled: Boolean read fEnabled write SetEnabled;
    property OnChanged: TEditorNotifyEvent read fOnChanged write fOnChanged;
  end;

implementation

const
  CMinComponentSize = 8;
  CPasteOffset = 16;
  CResizeHandleSize = 8;
  CResizeHotZone = 5;
  CUndoDepth = 5;

{ TFormEditorUndoState }

constructor TFormEditorUndoState.Create;
begin
  inherited Create;
  fItems := TList.Create;
  fSelectedIds := TStringList.Create;
end;

destructor TFormEditorUndoState.Destroy;
var
  I: Integer;
begin
  for I := 0 to fItems.Count - 1 do
    TObject(fItems[I]).Free;
  fItems.Free;
  fSelectedIds.Free;
  inherited Destroy;
end;

{ TFormEditorController }

constructor TFormEditorController.Create(ACanvas: TPanel;
  AGetPage: TGetEditorPageEvent; AComponentFactory: TRecorderComponentFactory);
begin
  inherited Create;
  if ACanvas = nil then
    raise ERecorderFormError.Create('Editor canvas cannot be nil');
  if not Assigned(AGetPage) then
    raise ERecorderFormError.Create('Editor page provider cannot be nil');
  if AComponentFactory = nil then
    raise ERecorderFormError.Create('Editor component factory cannot be nil');

  fCanvas := ACanvas;
  fGetPage := AGetPage;
  fComponentFactory := AComponentFactory;
  fClipboard := TList.Create;
  fSelected := TList.Create;
  fDragStartBounds := TList.Create;
  fUndoStack := TList.Create;
  fDisplaySeconds := 1.0;

  fCanvas.OnMouseDown := @CanvasMouseDown;
  fCanvas.OnMouseMove := @CanvasMouseMove;
  fCanvas.OnMouseUp := @CanvasMouseUp;
  fCanvas.Cursor := crDefault;
end;

destructor TFormEditorController.Destroy;
begin
  EndOperation;
  ClearClipboard;
  ClearUndoStack;
  ClearDragStartBounds;
  fClipboard.Free;
  fDragStartBounds.Free;
  fUndoStack.Free;
  fSelected.Free;
  inherited Destroy;
end;

procedure TFormEditorController.SetEnabled(AValue: Boolean);
begin
  if fEnabled = AValue then
    Exit;

  fEnabled := AValue;
  if not fEnabled then
  begin
    ClearSelection;
    EndOperation;
    fCanvas.Cursor := crDefault;
  end;
  Render;
end;

function TFormEditorController.GetActivePage: TRecorderFormPage;
begin
  Result := fGetPage();
end;

procedure TFormEditorController.NotifyChanged;
begin
  if Assigned(fOnChanged) then
    fOnChanged;
end;

procedure TFormEditorController.ClearSelection;
begin
  fSelected.Clear;
end;

procedure TFormEditorController.SetDataContext(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
begin
  fTagRegistry := ATagRegistry;
  if ADisplaySeconds > 0 then
    fDisplaySeconds := ADisplaySeconds
  else
    fDisplaySeconds := 1.0;
end;

procedure TFormEditorController.Render;
var
  I: Integer;
  lPage: TRecorderFormPage;
  lComponent: TRecorderVisualComponent;
  lBounds: TRecorderRect;
  lPanel: TPanel;
  lShape: TShape;
  lGroupBounds: TRecorderRect;
  lHandle: TPanel;
  lOsc: TRecorderOglOscillogram;

  procedure AddHandle(AOperation: TFormEditorOperation; ALeft, ATop: Integer);
  begin
    lHandle := TPanel.Create(fCanvas);
    lHandle.Parent := fCanvas;
    lHandle.SetBounds(ALeft, ATop, CResizeHandleSize, CResizeHandleSize);
    lHandle.Tag := Ord(AOperation);
    lHandle.Color := clFuchsia;
    lHandle.ParentBackground := False;
    lHandle.BevelOuter := bvRaised;
    lHandle.OnMouseDown := @ResizeHandleMouseDown;
    lHandle.OnMouseMove := @ChildMouseMove;
    lHandle.OnMouseUp := @ChildMouseUp;
    lHandle.Cursor := CursorForOperation(AOperation);
    lHandle.ShowHint := True;
    lHandle.Hint := 'Resize selection';
    lHandle.BringToFront;
  end;

begin
  while fCanvas.ControlCount > 0 do
    fCanvas.Controls[0].Free;

  lPage := GetActivePage;
  if lPage = nil then
    Exit;

  for I := 0 to lPage.ComponentCount - 1 do
  begin
    lComponent := lPage.Components[I];
    lBounds := lComponent.Bounds;

    lPanel := TPanel.Create(fCanvas);
    lPanel.Parent := fCanvas;
    lPanel.SetBounds(lBounds.Left, lBounds.Top, lBounds.Width, lBounds.Height);
    lPanel.Tag := I;
    lPanel.OnMouseDown := @ComponentMouseDown;
    lPanel.OnMouseMove := @ChildMouseMove;
    lPanel.OnMouseUp := @ChildMouseUp;
    lPanel.Cursor := crDefault;
    lPanel.ParentBackground := False;
    lPanel.BevelOuter := bvLowered;
    lPanel.BorderSpacing.Around := 0;
    lPanel.ShowHint := True;

    if lComponent is TRecorderStaticTextComponent then
    begin
      lPanel.Caption := TRecorderStaticTextComponent(lComponent).Text;
      lPanel.Alignment := taLeftJustify;
      lPanel.Color := clWhite;
      lPanel.Hint := 'Static text: ' + lComponent.Name;
    end
    else if lComponent is TRecorderTagValueComponent then
    begin
      lPanel.Caption := TRecorderTagValueComponent(lComponent).TagName + '  0.0';
      lPanel.Alignment := taCenter;
      lPanel.Font.Style := [fsBold];
      lPanel.Color := $00F2F8FF;
      lPanel.Hint := 'Digital indicator: ' + lComponent.Name;
    end
    else if lComponent is TRecorderOscillogramComponent then
    begin
      lPanel.Caption := '';
      lPanel.Color := clWhite;
      lPanel.Hint := 'Oscillogram: ' + lComponent.Name;
      lOsc := TRecorderOglOscillogram.Create(lPanel);
      lOsc.Parent := lPanel;
      lOsc.Align := alClient;
      lOsc.Tag := I;
      lOsc.BindingMode := TRecorderOscillogramComponent(lComponent).BindingMode;
      lOsc.TagOffset := TRecorderOscillogramComponent(lComponent).TagOffset;
      lOsc.AbsoluteTagName := lComponent.TagName;
      lOsc.OnMouseDown := @ComponentMouseDown;
      lOsc.OnMouseMove := @ChildMouseMove;
      lOsc.OnMouseUp := @ChildMouseUp;
      if lOsc.ChartControl <> nil then
      begin
        lOsc.ChartControl.Tag := I;
        lOsc.ChartControl.OnMouseDown := @ComponentMouseDown;
        lOsc.ChartControl.OnMouseMove := @ChildMouseMove;
        lOsc.ChartControl.OnMouseUp := @ChildMouseUp;
      end;
      lOsc.Refresh(fTagRegistry, fDisplaySeconds);
    end
    else
    begin
      lPanel.Caption := lComponent.Name;
      lPanel.Color := clWhite;
      lPanel.Hint := lComponent.TypeId;
    end;

    if fEnabled and IsSelected(I) then
      lPanel.BevelOuter := bvRaised;
  end;

  if not fEnabled then
    Exit;

  for I := 0 to fSelected.Count - 1 do
  begin
    lComponent := lPage.Components[Integer(PtrUInt(fSelected[I]))];
    lBounds := lComponent.Bounds;
    lShape := TShape.Create(fCanvas);
    lShape.Parent := fCanvas;
    lShape.SetBounds(lBounds.Left - 2, lBounds.Top - 2,
      lBounds.Width + 4, lBounds.Height + 4);
    lShape.Brush.Style := bsClear;
    lShape.Pen.Color := clFuchsia;
    lShape.Pen.Width := 2;
    lShape.Enabled := False;
    lShape.BringToFront;
  end;

  if GetGroupBounds(lGroupBounds) then
  begin
    lShape := TShape.Create(fCanvas);
    lShape.Parent := fCanvas;
    lShape.SetBounds(lGroupBounds.Left - 4, lGroupBounds.Top - 4,
      lGroupBounds.Width + 8, lGroupBounds.Height + 8);
    lShape.Brush.Style := bsClear;
    lShape.Pen.Color := clRed;
    lShape.Pen.Width := 2;
    lShape.Enabled := False;
    lShape.BringToFront;

    AddHandle(feoResizeTopLeft, lGroupBounds.Left - 8, lGroupBounds.Top - 8);
    AddHandle(feoResizeTop, lGroupBounds.Left + lGroupBounds.Width div 2 - 4,
      lGroupBounds.Top - 8);
    AddHandle(feoResizeTopRight, lGroupBounds.Left + lGroupBounds.Width,
      lGroupBounds.Top - 8);
    AddHandle(feoResizeLeft, lGroupBounds.Left - 8,
      lGroupBounds.Top + lGroupBounds.Height div 2 - 4);
    AddHandle(feoResizeRight, lGroupBounds.Left + lGroupBounds.Width,
      lGroupBounds.Top + lGroupBounds.Height div 2 - 4);
    AddHandle(feoResizeBottomLeft, lGroupBounds.Left - 8,
      lGroupBounds.Top + lGroupBounds.Height);
    AddHandle(feoResizeBottom, lGroupBounds.Left + lGroupBounds.Width div 2 - 4,
      lGroupBounds.Top + lGroupBounds.Height);
    AddHandle(feoResizeBottomRight, lGroupBounds.Left + lGroupBounds.Width,
      lGroupBounds.Top + lGroupBounds.Height);
  end;
end;

procedure TFormEditorController.DeleteSelected;
var
  lPage: TRecorderFormPage;
  I: Integer;
  lMaxPos: Integer;
  lMaxIndex: PtrUInt;
begin
  lPage := GetActivePage;
  if lPage = nil then
    Exit;

  if fSelected.Count = 0 then
    Exit;

  PushUndoState;

  while fSelected.Count > 0 do
  begin
    lMaxPos := 0;
    lMaxIndex := PtrUInt(fSelected[0]);
    for I := 1 to fSelected.Count - 1 do
      if PtrUInt(fSelected[I]) > lMaxIndex then
      begin
        lMaxIndex := PtrUInt(fSelected[I]);
        lMaxPos := I;
      end;

    fSelected.Delete(lMaxPos);
    if Integer(lMaxIndex) < lPage.ComponentCount then
      lPage.DeleteComponent(Integer(lMaxIndex));
  end;

  NotifyChanged;
  Render;
end;

procedure TFormEditorController.HandleKeyDown(var Key: Word; Shift: TShiftState);
var
  lResize: Boolean;
  lStep: Integer;
  lDeltaW: Integer;
  lDeltaH: Integer;
  lDeltaX: Integer;
  lDeltaY: Integer;
  I: Integer;
  lPage: TRecorderFormPage;
  lComponent: TRecorderVisualComponent;
  lBounds: TRecorderRect;
begin
  if not fEnabled then
    Exit;

  if (ssCtrl in Shift) and (Key = VK_C) then
  begin
    CopySelected;
    Key := 0;
    Exit;
  end;

  if (ssCtrl in Shift) and (Key = VK_V) then
  begin
    if fClipboard.Count > 0 then
      PushUndoState;
    PasteClipboard;
    Key := 0;
    Exit;
  end;

  if (ssCtrl in Shift) and (Key = VK_Z) then
  begin
    UndoLastStep;
    Key := 0;
    Exit;
  end;

  if fSelected.Count = 0 then
    Exit;

  lResize := ((ssCtrl in Shift) or (ssShift in Shift)) and
    (not ((ssCtrl in Shift) and (ssShift in Shift)));
  lStep := 1;
  if ssShift in Shift then
    lStep := 5;

  lDeltaW := 0;
  lDeltaH := 0;
  lDeltaX := 0;
  lDeltaY := 0;

  if lResize then
  begin
    case Key of
      VK_LEFT: lDeltaW := -lStep;
      VK_RIGHT: lDeltaW := lStep;
      VK_UP: lDeltaH := -lStep;
      VK_DOWN: lDeltaH := lStep;
    else
      Exit;
    end;
  end
  else
  begin
    case Key of
      VK_LEFT: lDeltaX := -lStep;
      VK_RIGHT: lDeltaX := lStep;
      VK_UP: lDeltaY := -lStep;
      VK_DOWN: lDeltaY := lStep;
    else
      Exit;
    end;
  end;

  lPage := GetActivePage;
  if lPage = nil then
    Exit;

  PushUndoState;

  for I := 0 to fSelected.Count - 1 do
  begin
    lComponent := lPage.Components[Integer(PtrUInt(fSelected[I]))];
    lBounds := lComponent.Bounds;
    lComponent.SetBounds(lBounds.Left + lDeltaX, lBounds.Top + lDeltaY,
      Max(CMinComponentSize, lBounds.Width + lDeltaW),
      Max(CMinComponentSize, lBounds.Height + lDeltaH));
  end;

  Key := 0;
  NotifyChanged;
  Render;
end;

procedure TFormEditorController.CanvasMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (not fEnabled) or (Button <> mbLeft) then
    Exit;

  if not (ssCtrl in Shift) then
    ClearSelection;

  BeginOperation(feoSelectRect, X, Y);
end;

procedure TFormEditorController.CanvasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if not fEnabled then
    Exit;

  if fOperation = feoNone then
  begin
    UpdateHoverCursor(fCanvas, X, Y);
    Exit;
  end;

  UpdateOperation(X, Y);
end;

procedure TFormEditorController.CanvasMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then
    Exit;

  if fOperation = feoSelectRect then
    SelectByRect(NormalizeRect(fDragStartPoint.X, fDragStartPoint.Y, X, Y));
  if (fOperation <> feoNone) and (fOperation <> feoSelectRect) then
    UpdateOperation(X, Y);

  EndOperation;
  Render;
end;

procedure TFormEditorController.ComponentMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
  lIndex: Integer;
  lOperation: TFormEditorOperation;
begin
  if (not fEnabled) or (Button <> mbLeft) or (not (Sender is TControl)) then
    Exit;

  lIndex := TControl(Sender).Tag;
  if ssCtrl in Shift then
    ToggleIndex(lIndex)
  else if not IsSelected(lIndex) then
    SelectIndex(lIndex, False);

  lPoint := fCanvas.ScreenToClient(TControl(Sender).ClientToScreen(Point(X, Y)));
  lOperation := GetResizeOperationAtControlPoint(TControl(Sender), X, Y);
  if lOperation = feoNone then
    lOperation := feoDrag;
  BeginOperation(lOperation, lPoint.X, lPoint.Y);
end;

procedure TFormEditorController.ChildMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
begin
  if (not fEnabled) or (not (Sender is TControl)) then
    Exit;

  if fOperation = feoNone then
  begin
    UpdateHoverCursor(TControl(Sender), X, Y);
    Exit;
  end;

  lPoint := fCanvas.ScreenToClient(TControl(Sender).ClientToScreen(Point(X, Y)));
  UpdateOperation(lPoint.X, lPoint.Y);
end;

procedure TFormEditorController.ChildMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
begin
  if (Button <> mbLeft) or (not (Sender is TControl)) then
    Exit;

  lPoint := fCanvas.ScreenToClient(TControl(Sender).ClientToScreen(Point(X, Y)));
  if fOperation <> feoNone then
    UpdateOperation(lPoint.X, lPoint.Y);
  EndOperation;
  Render;
end;

procedure TFormEditorController.ResizeHandleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
begin
  if (not fEnabled) or (Button <> mbLeft) or (not (Sender is TControl)) then
    Exit;

  lPoint := fCanvas.ScreenToClient(TControl(Sender).ClientToScreen(Point(X, Y)));
  BeginOperation(TFormEditorOperation(TControl(Sender).Tag), lPoint.X, lPoint.Y);
end;

procedure TFormEditorController.BeginOperation(AOperation: TFormEditorOperation;
  X, Y: Integer);
var
  I: Integer;
  lPage: TRecorderFormPage;
  lBounds: PRecorderRect;
begin
  if (AOperation <> feoSelectRect) and (fSelected.Count = 0) then
    Exit;

  ClearDragStartBounds;
  fOperation := AOperation;
  fOperationUndoSaved := False;
  fDragStartPoint := Point(X, Y);
  SetCaptureControl(fCanvas);

  if AOperation = feoSelectRect then
    Exit;

  GetGroupBounds(fStartGroupBounds);
  lPage := GetActivePage;
  if lPage = nil then
    Exit;

  for I := 0 to fSelected.Count - 1 do
  begin
    New(lBounds);
    lBounds^ := lPage.Components[Integer(PtrUInt(fSelected[I]))].Bounds;
    fDragStartBounds.Add(lBounds);
  end;
end;

procedure TFormEditorController.UpdateOperation(X, Y: Integer);
var
  lDeltaX: Integer;
  lDeltaY: Integer;
  lPage: TRecorderFormPage;
  I: Integer;
  lIndex: Integer;
  lStartBounds: PRecorderRect;
  lNewBounds: TRecorderRect;
  lNewGroup: TRecorderRect;
  lScaleX: Double;
  lScaleY: Double;
begin
  if fOperation = feoNone then
    Exit;

  lDeltaX := X - fDragStartPoint.X;
  lDeltaY := Y - fDragStartPoint.Y;

  if fOperation = feoSelectRect then
  begin
    if fSelectionFrame = nil then
    begin
      fSelectionFrame := TShape.Create(fCanvas);
      fSelectionFrame.Parent := fCanvas;
      fSelectionFrame.Brush.Style := bsClear;
      fSelectionFrame.Pen.Color := clRed;
      fSelectionFrame.Pen.Style := psDot;
      fSelectionFrame.Enabled := False;
    end;
    fSelectionFrame.BoundsRect := NormalizeRect(fDragStartPoint.X,
      fDragStartPoint.Y, X, Y);
    fSelectionFrame.BringToFront;
    Exit;
  end;

  lPage := GetActivePage;
  if lPage = nil then
    Exit;

  if (not fOperationUndoSaved) and ((lDeltaX <> 0) or (lDeltaY <> 0)) then
  begin
    PushUndoState;
    fOperationUndoSaved := True;
  end;

  lNewGroup := fStartGroupBounds;
  case fOperation of
    feoDrag:
      begin
        for I := 0 to fDragStartBounds.Count - 1 do
        begin
          lIndex := Integer(PtrUInt(fSelected[I]));
          lStartBounds := PRecorderRect(fDragStartBounds[I]);
          lPage.Components[lIndex].SetBounds(lStartBounds^.Left + lDeltaX,
            lStartBounds^.Top + lDeltaY, lStartBounds^.Width,
            lStartBounds^.Height);
        end;
        NotifyChanged;
        RenderLive;
        Exit;
      end;
    feoResizeLeft, feoResizeTopLeft, feoResizeBottomLeft:
      begin
        lNewGroup.Left := fStartGroupBounds.Left + lDeltaX;
        lNewGroup.Width := fStartGroupBounds.Width - lDeltaX;
      end;
    feoResizeRight, feoResizeTopRight, feoResizeBottomRight:
      lNewGroup.Width := fStartGroupBounds.Width + lDeltaX;
  end;

  case fOperation of
    feoResizeTop, feoResizeTopLeft, feoResizeTopRight:
      begin
        lNewGroup.Top := fStartGroupBounds.Top + lDeltaY;
        lNewGroup.Height := fStartGroupBounds.Height - lDeltaY;
      end;
    feoResizeBottom, feoResizeBottomLeft, feoResizeBottomRight:
      lNewGroup.Height := fStartGroupBounds.Height + lDeltaY;
  end;

  if lNewGroup.Width < CMinComponentSize then
    lNewGroup.Width := CMinComponentSize;
  if lNewGroup.Height < CMinComponentSize then
    lNewGroup.Height := CMinComponentSize;

  if fStartGroupBounds.Width = 0 then
    lScaleX := 1
  else
    lScaleX := lNewGroup.Width / fStartGroupBounds.Width;

  if fStartGroupBounds.Height = 0 then
    lScaleY := 1
  else
    lScaleY := lNewGroup.Height / fStartGroupBounds.Height;

  for I := 0 to fDragStartBounds.Count - 1 do
  begin
    lIndex := Integer(PtrUInt(fSelected[I]));
    lStartBounds := PRecorderRect(fDragStartBounds[I]);
    lNewBounds.Left := lNewGroup.Left +
      Round((lStartBounds^.Left - fStartGroupBounds.Left) * lScaleX);
    lNewBounds.Top := lNewGroup.Top +
      Round((lStartBounds^.Top - fStartGroupBounds.Top) * lScaleY);
    lNewBounds.Width := Max(CMinComponentSize,
      Round(lStartBounds^.Width * lScaleX));
    lNewBounds.Height := Max(CMinComponentSize,
      Round(lStartBounds^.Height * lScaleY));
    lPage.Components[lIndex].Bounds := lNewBounds;
  end;

  NotifyChanged;
  RenderLive;
end;

procedure TFormEditorController.EndOperation;
begin
  fOperation := feoNone;
  fOperationUndoSaved := False;
  if GetCaptureControl = fCanvas then
    SetCaptureControl(nil);
  ClearDragStartBounds;
  FreeAndNil(fSelectionFrame);
end;

procedure TFormEditorController.ClearDragStartBounds;
var
  I: Integer;
begin
  for I := 0 to fDragStartBounds.Count - 1 do
    Dispose(PRecorderRect(fDragStartBounds[I]));
  fDragStartBounds.Clear;
end;

procedure TFormEditorController.ClearClipboard;
var
  I: Integer;
begin
  for I := 0 to fClipboard.Count - 1 do
    TObject(fClipboard[I]).Free;
  fClipboard.Clear;
end;

procedure TFormEditorController.ClearUndoStack;
var
  I: Integer;
begin
  for I := 0 to fUndoStack.Count - 1 do
    TObject(fUndoStack[I]).Free;
  fUndoStack.Clear;
end;

function TFormEditorController.CreateUndoState(
  APage: TRecorderFormPage): TFormEditorUndoState;
var
  I: Integer;
  lIndex: Integer;
begin
  Result := TFormEditorUndoState.Create;
  try
    Result.PageId := APage.Id;
    for I := 0 to APage.ComponentCount - 1 do
      Result.Items.Add(ClipboardItemFromComponent(APage.Components[I]));

    for I := 0 to fSelected.Count - 1 do
    begin
      lIndex := Integer(PtrUInt(fSelected[I]));
      if (lIndex >= 0) and (lIndex < APage.ComponentCount) then
        Result.SelectedIds.Add(APage.Components[lIndex].Id);
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TFormEditorController.PushUndoState;
var
  lPage: TRecorderFormPage;
begin
  lPage := GetActivePage;
  if lPage = nil then
    Exit;

  fUndoStack.Add(CreateUndoState(lPage));
  while fUndoStack.Count > CUndoDepth do
  begin
    TObject(fUndoStack[0]).Free;
    fUndoStack.Delete(0);
  end;
end;

function TFormEditorController.CreateComponentFromSnapshot(
  AItem: TFormEditorClipboardItem): TRecorderVisualComponent;
begin
  Result := fComponentFactory.CreateComponent(AItem.TypeId);
  try
    Result.Id := AItem.Id;
    Result.Name := AItem.Name;
    Result.TagName := AItem.TagName;
    Result.Bounds := AItem.Bounds;

    if Result is TRecorderStaticTextComponent then
      TRecorderStaticTextComponent(Result).Text := AItem.Text
    else if Result is TRecorderTagValueComponent then
      TRecorderTagValueComponent(Result).DisplayFormat := AItem.DisplayFormat
    else if Result is TRecorderOscillogramComponent then
    begin
      TRecorderOscillogramComponent(Result).BindingMode := AItem.BindingMode;
      TRecorderOscillogramComponent(Result).TagOffset := AItem.TagOffset;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TFormEditorController.RestoreUndoState(AState: TFormEditorUndoState);
var
  I: Integer;
  lPage: TRecorderFormPage;
  lItem: TFormEditorClipboardItem;
  lComponent: TRecorderVisualComponent;
begin
  if AState = nil then
    Exit;

  lPage := GetActivePage;
  if (lPage = nil) or (not SameText(lPage.Id, AState.PageId)) then
    Exit;

  ClearSelection;
  while lPage.ComponentCount > 0 do
    lPage.DeleteComponent(lPage.ComponentCount - 1);

  for I := 0 to AState.Items.Count - 1 do
  begin
    lItem := TFormEditorClipboardItem(AState.Items[I]);
    lComponent := CreateComponentFromSnapshot(lItem);
    try
      lPage.AddComponent(lComponent);
    except
      lComponent.Free;
      raise;
    end;

    if AState.SelectedIds.IndexOf(lComponent.Id) >= 0 then
      fSelected.Add(Pointer(PtrUInt(lPage.ComponentCount - 1)));
  end;
end;

procedure TFormEditorController.RememberUndoStep;
begin
  PushUndoState;
end;

procedure TFormEditorController.ClearUndoHistory;
begin
  ClearUndoStack;
end;

procedure TFormEditorController.UndoLastStep;
var
  lState: TFormEditorUndoState;
begin
  if (not fEnabled) or (fUndoStack.Count = 0) then
    Exit;

  lState := TFormEditorUndoState(fUndoStack[fUndoStack.Count - 1]);
  fUndoStack.Delete(fUndoStack.Count - 1);
  try
    RestoreUndoState(lState);
  finally
    lState.Free;
  end;

  NotifyChanged;
  Render;
end;

procedure TFormEditorController.RenderLive;
begin
  Render;
  fCanvas.Invalidate;
  fCanvas.Update;
end;

procedure TFormEditorController.CopySelected;
var
  I: Integer;
  lPage: TRecorderFormPage;
  lIndex: Integer;
begin
  lPage := GetActivePage;
  if (lPage = nil) or (fSelected.Count = 0) then
    Exit;

  ClearClipboard;
  for I := 0 to fSelected.Count - 1 do
  begin
    lIndex := Integer(PtrUInt(fSelected[I]));
    if (lIndex >= 0) and (lIndex < lPage.ComponentCount) then
      fClipboard.Add(ClipboardItemFromComponent(lPage.Components[lIndex]));
  end;
end;

procedure TFormEditorController.PasteClipboard;
var
  I: Integer;
  lPage: TRecorderFormPage;
  lItem: TFormEditorClipboardItem;
  lComponent: TRecorderVisualComponent;
begin
  lPage := GetActivePage;
  if (lPage = nil) or (fClipboard.Count = 0) then
    Exit;

  ClearSelection;
  for I := 0 to fClipboard.Count - 1 do
  begin
    lItem := TFormEditorClipboardItem(fClipboard[I]);
    lComponent := CreateComponentFromClipboard(lItem);
    try
      lComponent.Id := UniqueComponentId(lPage, lItem.TypeId + '.copy');
      lComponent.Name := UniqueComponentName(lPage, lItem.Name + 'Copy');
      lComponent.TagName := lItem.TagName;
      lComponent.SetBounds(lItem.Bounds.Left + CPasteOffset,
        lItem.Bounds.Top + CPasteOffset, lItem.Bounds.Width,
        lItem.Bounds.Height);

      if lComponent is TRecorderStaticTextComponent then
        TRecorderStaticTextComponent(lComponent).Text := lItem.Text
      else if lComponent is TRecorderTagValueComponent then
        TRecorderTagValueComponent(lComponent).DisplayFormat :=
          lItem.DisplayFormat
      else if lComponent is TRecorderOscillogramComponent then
      begin
        TRecorderOscillogramComponent(lComponent).BindingMode := lItem.BindingMode;
        TRecorderOscillogramComponent(lComponent).TagOffset := lItem.TagOffset;
      end;

      lPage.AddComponent(lComponent);
      fSelected.Add(Pointer(PtrUInt(lPage.ComponentCount - 1)));

      Inc(lItem.Bounds.Left, CPasteOffset);
      Inc(lItem.Bounds.Top, CPasteOffset);
    except
      lComponent.Free;
      raise;
    end;
  end;

  NotifyChanged;
  Render;
end;

function TFormEditorController.ClipboardItemFromComponent(
  AComponent: TRecorderVisualComponent): TFormEditorClipboardItem;
begin
  Result := TFormEditorClipboardItem.Create;
  Result.Bounds := AComponent.Bounds;
  Result.Id := AComponent.Id;
  Result.Name := AComponent.Name;
  Result.TagName := AComponent.TagName;
  Result.TypeId := AComponent.TypeId;

  if AComponent is TRecorderStaticTextComponent then
    Result.Text := TRecorderStaticTextComponent(AComponent).Text
  else if AComponent is TRecorderTagValueComponent then
    Result.DisplayFormat := TRecorderTagValueComponent(AComponent).DisplayFormat
  else if AComponent is TRecorderOscillogramComponent then
  begin
    Result.BindingMode := TRecorderOscillogramComponent(AComponent).BindingMode;
    Result.TagOffset := TRecorderOscillogramComponent(AComponent).TagOffset;
  end;
end;

function TFormEditorController.CreateComponentFromClipboard(
  AItem: TFormEditorClipboardItem): TRecorderVisualComponent;
begin
  Result := fComponentFactory.CreateComponent(AItem.TypeId);
end;

function TFormEditorController.UniqueComponentId(APage: TRecorderFormPage;
  const ABaseId: string): string;
var
  lIndex: Integer;
begin
  lIndex := 1;
  repeat
    Result := Format('%s.%s%d', [APage.Id, ABaseId, lIndex]);
    Inc(lIndex);
  until APage.FindComponentById(Result) = nil;
end;

function TFormEditorController.UniqueComponentName(APage: TRecorderFormPage;
  const ABaseName: string): string;
var
  I: Integer;
  lIndex: Integer;
  lExists: Boolean;
begin
  lIndex := 1;
  repeat
    Result := Format('%s%d', [ABaseName, lIndex]);
    lExists := False;
    for I := 0 to APage.ComponentCount - 1 do
      if SameText(APage.Components[I].Name, Result) then
      begin
        lExists := True;
        Break;
      end;
    Inc(lIndex);
  until not lExists;
end;

function TFormEditorController.IsSelected(AIndex: Integer): Boolean;
begin
  Result := fSelected.IndexOf(Pointer(PtrUInt(AIndex))) >= 0;
end;

procedure TFormEditorController.SelectIndex(AIndex: Integer; AAdd: Boolean);
var
  lPage: TRecorderFormPage;
begin
  lPage := GetActivePage;
  if (lPage = nil) or (AIndex < 0) or (AIndex >= lPage.ComponentCount) then
    Exit;

  if not AAdd then
    ClearSelection;

  if not IsSelected(AIndex) then
    fSelected.Add(Pointer(PtrUInt(AIndex)));
end;

procedure TFormEditorController.ToggleIndex(AIndex: Integer);
var
  lPos: Integer;
begin
  lPos := fSelected.IndexOf(Pointer(PtrUInt(AIndex)));
  if lPos >= 0 then
    fSelected.Delete(lPos)
  else
    SelectIndex(AIndex, True);
end;

procedure TFormEditorController.SelectByRect(const ARect: TRect);
var
  I: Integer;
  lPage: TRecorderFormPage;
begin
  lPage := GetActivePage;
  if lPage = nil then
    Exit;

  for I := 0 to lPage.ComponentCount - 1 do
    if RectsIntersectPartial(ARect, RecorderRectToRect(lPage.Components[I].Bounds)) and
      (not IsSelected(I)) then
      fSelected.Add(Pointer(PtrUInt(I)));
end;

function TFormEditorController.GetResizeOperationAtControlPoint(
  AControl: TControl; X, Y: Integer): TFormEditorOperation;
var
  lOnLeft: Boolean;
  lOnRight: Boolean;
  lOnTop: Boolean;
  lOnBottom: Boolean;
begin
  Result := feoNone;
  if (AControl = nil) or (not IsSelected(AControl.Tag)) then
    Exit;

  lOnLeft := X <= CResizeHotZone;
  lOnRight := X >= AControl.Width - CResizeHotZone;
  lOnTop := Y <= CResizeHotZone;
  lOnBottom := Y >= AControl.Height - CResizeHotZone;

  if lOnLeft and lOnTop then
    Result := feoResizeTopLeft
  else if lOnRight and lOnTop then
    Result := feoResizeTopRight
  else if lOnLeft and lOnBottom then
    Result := feoResizeBottomLeft
  else if lOnRight and lOnBottom then
    Result := feoResizeBottomRight
  else if lOnLeft then
    Result := feoResizeLeft
  else if lOnRight then
    Result := feoResizeRight
  else if lOnTop then
    Result := feoResizeTop
  else if lOnBottom then
    Result := feoResizeBottom;
end;

function TFormEditorController.CursorForOperation(
  AOperation: TFormEditorOperation): TCursor;
begin
  case AOperation of
    feoDrag:
      Result := crSizeAll;
    feoResizeLeft, feoResizeRight:
      Result := crSizeWE;
    feoResizeTop, feoResizeBottom:
      Result := crSizeNS;
    feoResizeTopLeft, feoResizeBottomRight:
      Result := crSizeNWSE;
    feoResizeTopRight, feoResizeBottomLeft:
      Result := crSizeNESW;
  else
    Result := crDefault;
  end;
end;

procedure TFormEditorController.UpdateHoverCursor(AControl: TControl; X,
  Y: Integer);
var
  lOperation: TFormEditorOperation;
  lCursor: TCursor;
begin
  if (not fEnabled) or (AControl = nil) then
    lCursor := crDefault
  else if (AControl.Hint = 'Resize selection') and
    (AControl.Tag >= Ord(feoResizeLeft)) and
    (AControl.Tag <= Ord(feoResizeBottomRight)) then
    lCursor := CursorForOperation(TFormEditorOperation(AControl.Tag))
  else if AControl = fCanvas then
    lCursor := crDefault
  else
  begin
    lOperation := GetResizeOperationAtControlPoint(AControl, X, Y);
    if lOperation <> feoNone then
      lCursor := CursorForOperation(lOperation)
    else
      lCursor := crSizeAll;
  end;

  AControl.Cursor := lCursor;
  if fCanvas <> AControl then
    fCanvas.Cursor := lCursor;
end;

function TFormEditorController.GetGroupBounds(out ABounds: TRecorderRect): Boolean;
var
  I: Integer;
  lPage: TRecorderFormPage;
  lBounds: TRecorderRect;
  lLeft: Integer;
  lTop: Integer;
  lRight: Integer;
  lBottom: Integer;
begin
  Result := False;
  lPage := GetActivePage;
  if (lPage = nil) or (fSelected.Count = 0) then
    Exit;

  lBounds := lPage.Components[Integer(PtrUInt(fSelected[0]))].Bounds;
  lLeft := lBounds.Left;
  lTop := lBounds.Top;
  lRight := lBounds.Left + lBounds.Width;
  lBottom := lBounds.Top + lBounds.Height;

  for I := 1 to fSelected.Count - 1 do
  begin
    lBounds := lPage.Components[Integer(PtrUInt(fSelected[I]))].Bounds;
    if lBounds.Left < lLeft then
      lLeft := lBounds.Left;
    if lBounds.Top < lTop then
      lTop := lBounds.Top;
    if lBounds.Left + lBounds.Width > lRight then
      lRight := lBounds.Left + lBounds.Width;
    if lBounds.Top + lBounds.Height > lBottom then
      lBottom := lBounds.Top + lBounds.Height;
  end;

  ABounds.Left := lLeft;
  ABounds.Top := lTop;
  ABounds.Width := lRight - lLeft;
  ABounds.Height := lBottom - lTop;
  Result := True;
end;

function TFormEditorController.NormalizeRect(X1, Y1, X2, Y2: Integer): TRect;
begin
  Result.Left := Min(X1, X2);
  Result.Top := Min(Y1, Y2);
  Result.Right := Max(X1, X2);
  Result.Bottom := Max(Y1, Y2);
end;

function TFormEditorController.RecorderRectToRect(
  const ABounds: TRecorderRect): TRect;
begin
  Result := Rect(ABounds.Left, ABounds.Top, ABounds.Left + ABounds.Width,
    ABounds.Top + ABounds.Height);
end;

function TFormEditorController.RectsIntersectPartial(const A, B: TRect): Boolean;
begin
  Result := (A.Left <= B.Right) and (A.Right >= B.Left) and
    (A.Top <= B.Bottom) and (A.Bottom >= B.Top);
end;

end.
