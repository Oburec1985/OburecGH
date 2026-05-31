unit uOglChart;
{$mode ObjFPC}{$H+}
{
  Модуль uOglChart
  Описание: Содержит основной визуальный компонент TOglChart для Lazarus (LCL).
            Интегрирует все части библиотеки: модель (TChartModel), рендерер (TOpenGLChartRenderer),
            систему событий/слушателей (TChartFrameListener) и обеспечивает их взаимодействие.
}
interface
uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  OpenGLContext, uOglChartTypes, uOglChartChart, uOglChartMng, uOglChartRenderer,
  uOglChartFrameListener, uOglChartSelectListener, uOglChartPanZoomListener,
  uOglChartPageGeometryListener, uOglChartVertexEditListener,
  uOglChartLabelEditListener, uOglChartBaseObj;

type
  TChartAfterRenderEvent = procedure(Sender: TObject; ARenderTimeMs: Double) of object;
  { TOglChart }
  // LCL/OpenGL-хост компонента графика.
  // Хранит модель и делегирует отрисовку renderer-слою.
  TOglChart = class(TOpenGLControl, IOpenGLContextHost, IChartControl)
  private
    fObjectManager: TChartObjectManager; // Менеджер объектов чарта
    fRenderer: IChartRenderer;           // Интерфейс рендерера
    fOpenGLRenderer: TOpenGLChartRenderer; // Конкретный OpenGL рендерер
    fIsRendererInitialized: Boolean;     // Флаг успешной инициализации рендерера
    fListeners: TList;                   // Список слушателей событий мыши/клавиатуры
    fOnAfterRender: TChartAfterRenderEvent; // Событие после отрисовки кадра

    function GetModel: TChartModel;

    procedure SetModel(AValue: TChartModel);

    function GetSelectedObject: cBaseObj;

    procedure SetSelectedObject(AValue: cBaseObj);

    function GetHoveredObject: cBaseObj;

    procedure SetHoveredObject(AValue: cBaseObj);
  protected
    // Переопределение изменения размеров компонента

    procedure Resize; override;
    // Обработка событий мыши и клавиатуры

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    procedure KeyPress(var Key: char); override;
  public

    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;
    // Перерисовка кадра

    procedure Paint; override;
    // Потокобезопасный вызов инвалидации контрола

    procedure Redraw;
    // Регистрация слушателя событий графического окна

    procedure AddFrameListener(AListener: TChartFrameListener);
    // Удаление слушателя событий

    procedure RemoveFrameListener(AListener: TChartFrameListener);
    { IChartControl }

    function GetRenderer: TObject;

    function GetModel: TObject;
    { IOpenGLContextHost }

    procedure MakeCurrent; reintroduce;

    procedure SwapBuffers; reintroduce;

    function GetWidth: Integer;

    function GetHeight: Integer;
    property Model: TChartModel read GetModel write SetModel;
    property OnAfterRender: TChartAfterRenderEvent read fOnAfterRender write fOnAfterRender;
    property ObjectManager: TChartObjectManager read fObjectManager;
    property Renderer: IChartRenderer read fRenderer write fRenderer;
    property SelectedObject: cBaseObj read GetSelectedObject write SetSelectedObject;
    property HoveredObject: cBaseObj read GetHoveredObject write SetHoveredObject;
  published
    property Align;
    property AutoResizeViewport;
  end;

procedure Register;

implementation
{$IFDEF WINDOWS}
uses Windows;
{$ENDIF}
/// <summary>
/// Записывает отладочные сообщения событий ввода/вывода в локальный текстовый файл.
/// </summary>

procedure LogToFile(const AMsg: string);

var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;

end;

{ TOglChart }
/// <summary>
/// Инициализация компонента, создание рендерера по умолчанию (TOpenGLChartRenderer),
/// менеджера объектов и добавление стандартных слушателей событий (зум, панорамирование, выделение).
/// </summary>

constructor TOglChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoResizeViewport := True;
  TabStop := True;
  fOpenGLRenderer := TOpenGLChartRenderer.Create;
  fRenderer := fOpenGLRenderer;
  fObjectManager := TChartObjectManager.Create;
  fObjectManager.Root.BackgroundColor := $FFFFFFFF;
  fListeners := TList.Create;
  // Добавление стандартных слушателей перетаскивания (Pan/Zoom) и выделения элементов
  AddFrameListener(TChartPanZoomListener.Create);
    AddFrameListener(TChartPageGeometryListener.Create);
    AddFrameListener(TChartVertexEditListener.Create);
    AddFrameListener(TChartLabelEditListener.Create);
  AddFrameListener(TChartSelectListener.Create);
end;

destructor TOglChart.Destroy;

var
  I: Integer;
begin
  fRenderer := nil;
  fOpenGLRenderer := nil;
  FreeAndNil(fObjectManager);
  if Assigned(fListeners) then
  begin
    for I := 0 to fListeners.Count - 1 do
      TObject(fListeners[I]).Free;
    FreeAndNil(fListeners);
  end;

  inherited Destroy;
end;

function TOglChart.GetModel: TChartModel;
begin
  Result := fObjectManager.Root;
end;

procedure TOglChart.SetModel(AValue: TChartModel);
begin
  fObjectManager.SetRoot(AValue);
  Redraw;
end;

procedure TOglChart.Resize;
begin
  inherited Resize;
  if Assigned(fRenderer) and fIsRendererInitialized then
  begin
    inherited MakeCurrent;
    fRenderer.Resize(Width, Height);
  end;

  Redraw;
end;

/// <summary>
/// Обработчик нажатия кнопки мыши. Сначала передает управление зарегистрированным слушателям,
/// затем (если событие не обработано) – встроенным методам рендерера для выделения или редактирования точек.
/// </summary>

procedure TOglChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var
  lHandled: Boolean;
  I: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  SetFocus;
  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseDown(Self, Button, Shift, X, Y, lHandled);
      if lHandled then
        Break;
    end;

  if not lHandled and (Button = mbLeft) and Assigned(fOpenGLRenderer) and fOpenGLRenderer.MouseDown(X, Y, ssDouble in Shift) then
    Redraw;
end;

/// <summary>
/// Обработчик перемещения мыши. Передает событие слушателям для панорамирования или зума области.
/// </summary>

procedure TOglChart.MouseMove(Shift: TShiftState; X, Y: Integer);

var
  lHandled: Boolean;
  I: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseMove(Self, Shift, X, Y, lHandled);
      if lHandled then
        Break;
    end;

end;

/// <summary>
/// Обработчик отпускания кнопки мыши.
/// </summary>

procedure TOglChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var
  lHandled: Boolean;
  I: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseUp(Self, Button, Shift, X, Y, lHandled);
      if lHandled then
        Break;
    end;

end;

/// <summary>
/// Обработчик вращения колесика мыши для зума относительно курсора мыши.
/// </summary>

function TOglChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;

var
  lHandled: Boolean;
  I: Integer;
  lClientPos: TPoint;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  lClientPos := ScreenToClient(MousePos);
  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseWheel(Self, Shift, WheelDelta, lClientPos.X, lClientPos.Y, lHandled);
      if lHandled then
      begin
        Result := True;
        Break;
      end;

    end;

end;

/// <summary>
/// Обработчик нажатия клавиш. Используется для горячих клавиш и удаления точек (Del).
/// </summary>

procedure TOglChart.KeyDown(var Key: Word; Shift: TShiftState);

var
  lHandled: Boolean;
  I: Integer;
begin
  LogToFile('TOglChart.KeyDown: Key=' + IntToStr(Key));
  inherited KeyDown(Key, Shift);
  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).KeyDown(Self, Key, Shift, lHandled);
      if lHandled then
        Break;
    end;

  if not lHandled and Assigned(fOpenGLRenderer) and fOpenGLRenderer.KeyDown(Key) then
  begin
    Key := 0;
    Redraw;
  end;

end;

/// <summary>
/// Ввод текста с клавиатуры для редактирования названий объектов на графике.
/// </summary>

procedure TOglChart.KeyPress(var Key: char);

var
  lHandled: Boolean;
  I: Integer;
begin
  inherited KeyPress(Key);
  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).KeyPress(Self, Key, lHandled);
      if lHandled then
        Break;
    end;

  if not lHandled and Assigned(fOpenGLRenderer) and fOpenGLRenderer.TextInput(Key) then
  begin
    Key := #0;
    Redraw;
  end;

end;

/// <summary>
/// Отрисовка кадра. Инициализирует рендерер, вызывает Render и вычисляет время отрисовки в миллисекундах.
/// Вызывает события FrameStarted и FrameEnded у слушателей.
/// </summary>

procedure TOglChart.Paint;

var
  I: Integer;
  lStart, lEnd, lFreq: Int64;
  lRenderTimeMs: Double;
begin
  inherited MakeCurrent;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
      TChartFrameListener(fListeners[I]).FrameStarted(Self);
  if Assigned(fRenderer) then
  begin
    if not fIsRendererInitialized then
    begin
      fRenderer.Initialize(Self as IOpenGLContextHost);
      fIsRendererInitialized := True;
    end;

    fRenderer.Resize(Width, Height);
    lFreq := 0;
    lStart := 0;
    lEnd := 0;
    {$IFDEF WINDOWS}
    QueryPerformanceFrequency(lFreq);
    QueryPerformanceCounter(lStart);
    {$ELSE}
    lStart := GetTickCount64;
    {$ENDIF}
    fRenderer.Render(Model);
    {$IFDEF WINDOWS}
    QueryPerformanceCounter(lEnd);
    if lFreq > 0 then
      lRenderTimeMs := (lEnd - lStart) * 1000.0 / lFreq
    else
      lRenderTimeMs := 0;
    {$ELSE}
    lEnd := GetTickCount64;
    lRenderTimeMs := lEnd - lStart;
    {$ENDIF}
    if Assigned(fOnAfterRender) then
      fOnAfterRender(Self, lRenderTimeMs);
  end;

  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
      TChartFrameListener(fListeners[I]).FrameEnded(Self);
  inherited SwapBuffers;
end;

procedure TOglChart.Redraw;
begin
  Invalidate;
end;

procedure TOglChart.MakeCurrent;
begin
  inherited MakeCurrent;
end;

procedure TOglChart.SwapBuffers;
begin
  inherited SwapBuffers;
end;

function TOglChart.GetWidth: Integer;
begin
  Result := Width;
end;

function TOglChart.GetHeight: Integer;
begin
  Result := Height;
end;

function TOglChart.GetSelectedObject: cBaseObj;
begin
  if Assigned(fOpenGLRenderer) then
    Result := fOpenGLRenderer.SelectedObject
  else
    Result := nil;
end;

procedure TOglChart.SetSelectedObject(AValue: cBaseObj);
begin
  if Assigned(fOpenGLRenderer) then
  begin
    fOpenGLRenderer.SelectedObject := AValue;
    Redraw;
  end;

end;

function TOglChart.GetHoveredObject: cBaseObj;
begin
  if Assigned(fOpenGLRenderer) then
    Result := fOpenGLRenderer.HoveredObject
  else
    Result := nil;
end;

procedure TOglChart.SetHoveredObject(AValue: cBaseObj);
begin
  if Assigned(fOpenGLRenderer) then
  begin
    fOpenGLRenderer.HoveredObject := AValue;
    Redraw;
  end;

end;

procedure TOglChart.AddFrameListener(AListener: TChartFrameListener);
begin
  if Assigned(AListener) and (fListeners.IndexOf(AListener) < 0) then
    fListeners.Add(AListener);
end;

procedure TOglChart.RemoveFrameListener(AListener: TChartFrameListener);
begin
  if Assigned(AListener) then
    fListeners.Remove(AListener);
end;

function TOglChart.GetRenderer: TObject;
begin
  Result := fOpenGLRenderer;
end;

function TOglChart.GetModel: TObject;
begin
  Result := Model;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TOglChart]);
end;

initialization
  Classes.RegisterClass(TOglChart);
end.

