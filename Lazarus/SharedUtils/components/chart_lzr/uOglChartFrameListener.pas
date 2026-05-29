unit uOglChartFrameListener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, LCLType, Math,
  uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj, uOglChartAxis, uOglChartPage,
  uOglChartTrend, uOglChartRenderer, uOglChartChart, uOglChartTextLabel, uOglChartLineHelper;

type
  /// <summary>
  /// Базовый класс слушателя событий кадра и интерактивного ввода для компонента TOglChart.
  /// Предоставляет виртуальные методы для обработки событий мыши, клавиатуры и фаз отрисовки.
  /// </summary>
  TChartFrameListener = class(TObject)
  private
    fEnabled: Boolean;
  public
    /// <summary>
    /// Конструктор по умолчанию. Активирует слушатель событий.
    /// </summary>
    constructor Create; virtual;
    
    /// <summary>
    /// Деструктор. Освобождает занятые ресурсы.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Вызывается перед началом отрисовки очередного кадра графика.
    /// </summary>
    /// <param name="ASender">Экземпляр TOglChart, инициировавший событие.</param>
    procedure FrameStarted(ASender: TObject); virtual;
    
    /// <summary>
    /// Вызывается сразу после завершения отрисовки кадра.
    /// </summary>
    /// <param name="ASender">Экземпляр TOglChart, инициировавший событие.</param>
    procedure FrameEnded(ASender: TObject); virtual;

    /// <summary>
    /// Обработчик нажатия кнопки мыши.
    /// </summary>
    /// <param name="ASender">Компонент-отправитель (обычно TOglChart).</param>
    /// <param name="Button">Нажатая кнопка мыши (левая, правая, средняя).</param>
    /// <param name="Shift">Состояние клавиш-модификаторов (Shift, Ctrl, Alt) и кнопок мыши.</param>
    /// <param name="X">Горизонтальная координата курсора в пикселях относительно компонента.</param>
    /// <param name="Y">Вертикальная координата курсора в пикселях относительно компонента.</param>
    /// <param name="Handled">Флаг, указывающий, было ли событие полностью обработано (прерывает цепочку вызовов).</param>
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    
    /// <summary>
    /// Обработчик перемещения мыши.
    /// </summary>
    /// <param name="ASender">Компонент-отправитель.</param>
    /// <param name="Shift">Состояние клавиш-модификаторов и кнопок мыши.</param>
    /// <param name="X">Координата X курсора.</param>
    /// <param name="Y">Координата Y курсора.</param>
    /// <param name="Handled">Флаг прерывания дальнейшей обработки события.</param>
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    
    /// <summary>
    /// Обработчик отпускания кнопки мыши.
    /// </summary>
    /// <param name="ASender">Компонент-отправитель.</param>
    /// <param name="Button">Отпущенная кнопка.</param>
    /// <param name="Shift">Состояние клавиш-модификаторов.</param>
    /// <param name="X">Координата X курсора.</param>
    /// <param name="Y">Координата Y курсора.</param>
    /// <param name="Handled">Флаг прерывания обработки.</param>
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    
    /// <summary>
    /// Обработчик прокрутки колесика мыши.
    /// </summary>
    /// <param name="ASender">Компонент-отправитель.</param>
    /// <param name="Shift">Состояние клавиш-модификаторов.</param>
    /// <param name="WheelDelta">Величина и направление прокрутки (положительное - вверх, отрицательное - вниз).</param>
    /// <param name="X">Координата X курсора.</param>
    /// <param name="Y">Координата Y курсора.</param>
    /// <param name="Handled">Флаг прерывания обработки.</param>
    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); virtual;

    /// <summary>
    /// Обработчик нажатия клавиши клавиатуры (системные коды клавиш).
    /// </summary>
    /// <param name="ASender">Компонент-отправитель.</param>
    /// <param name="Key">Код нажатой клавиши (может быть обнулен для блокировки дальнейшей обработки).</param>
    /// <param name="Shift">Состояние клавиш-модификаторов.</param>
    /// <param name="Handled">Флаг прерывания обработки.</param>
    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); virtual;
    
    /// <summary>
    /// Обработчик ввода символа с клавиатуры.
    /// </summary>
    /// <param name="ASender">Компонент-отправитель.</param>
    /// <param name="Key">Введенный символ.</param>
    /// <param name="Handled">Флаг прерывания обработки.</param>
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); virtual;

    /// <summary>
    /// Определяет, активен ли данный слушатель событий.
    /// </summary>
    property Enabled: Boolean read fEnabled write fEnabled;
  end;

  /// <summary>
  /// Слушатель для управления выделением (Selection) и подсветкой (Hover) объектов графика.
  /// Обрабатывает клики по страницам (TChartPage), осям (TChartAxis), вершинам трендов (cTrend)
  /// и текстовым меткам (TChartTextHit), а также изменяет форму курсора при наведении.
  /// </summary>
  TChartSelectListener = class(TChartFrameListener)
  public
    /// <summary>
    /// Конструктор по умолчанию.
    /// </summary>
    constructor Create; override;
    
    /// <summary>
    /// Выделяет объекты (страницы, оси, вершины трендов) при левом клике.
    /// Снимает выделение при клике на пустое пространство.
    /// </summary>
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    
    /// <summary>
    /// Подсвечивает элементы при наведении и изменяет форму курсора на руку (crHandPoint) при наведении на оси.
    /// </summary>
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    
    /// <summary>
    /// Изменяет свойства вершин трендов (тип сглаживания) по нажатию горячих клавиш (1, 2, 3, T).
    /// </summary>
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); override;
    
    /// <summary>
    /// Обрабатывает нажатия клавиш DELETE (удаление вершины) и INSERT (вставка вершины тренда).
    /// </summary>
    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); override;
  end;

  /// <summary>
  /// Определяет перетаскиваемую часть вершины Безье.
  /// </summary>
  TChartDragPart = (
    cdpPoint, ///< Сама точка (вершина) тренда.
    cdpLeft,  ///< Левый направляющий вектор (левый ус сглаживания).
    cdpRight  ///< Правый направляющий вектор (правый ус сглаживания).
  );

  /// <summary>
  /// Слушатель для реализации интерактивной навигации: масштабирование (Zoom) и панорамирование (Pan).
  /// Управляет перетаскиванием правой кнопкой мыши, масштабированием колесиком над страницами,
  /// изменением размеров страниц за границы, перетаскиванием страниц с Shift и приближением по рамке с Ctrl.
  /// </summary>
  TChartPanZoomListener = class(TChartFrameListener)
  private
    fIsPanning: Boolean;             // Флаг активного панорамирования графика (правая кнопка мыши).
    fLastX: Integer;                 // Последняя координата X мыши для расчета смещения (delta).
    fLastY: Integer;                 // Последняя координата Y мыши для расчета смещения.
    fActivePage: TChartPage;         // Ссылка на активную (интерактивную в данный момент) страницу чарта.
    fResizingBorder: Integer;        // Код границы страницы для изменения размеров: 1-лево, 2-право, 3-верх, 4-низ.
    fMovingPage: Boolean;            // Флаг активного перетаскивания (перемещения) страницы по холсту.
    fIsResizing: Boolean;            // Флаг активного изменения размеров страницы.
    fSnapSensitivity: Integer;       // Чувствительность примагничивания границ страниц друг к другу (в пикселях).
    fIsZoomSelecting: Boolean;       // Флаг активного выбора рамки зумирования (Ctrl + Drag).
    fZoomStartX: Integer;            // Начальная координата X рамки зумирования.
    fZoomStartY: Integer;            // Начальная координата Y рамки зумирования.
    fDragTrend: cTrend;              // Ссылка на тренд, точка которого сейчас перетаскивается.
    fDragPointIdx: Integer;          // Индекс перетаскиваемой вершины в массиве точек тренда.
    fIsDraggingPoint: Boolean;       // Флаг активного перетаскивания вершины или её направляющего возраста.
    fDragPart: TChartDragPart;       // Какая именно часть вершины сейчас перетаскивается (сама точка или усы).
    fIsDraggingLabel: Boolean;       // Флаг активного перетаскивания/ресайза текстовой метки
    fDragLabel: TChartTextLabel;     // Ссылка на перетаскиваемую метку
    fDragLabelBorder: Integer;       // 0 - drag, 3 - right, 4 - bottom, 5 - corner
  public
    /// <summary>
    /// Конструктор по умолчанию. Инициализирует настройки чувствительности примагничивания.
    /// </summary>
    constructor Create; override;
    
    /// <summary>
    /// Максимальное расстояние в пикселях, на котором срабатывает примагничивание страниц при перемещении.
    /// </summary>
    property SnapSensitivity: Integer read fSnapSensitivity write fSnapSensitivity;
    
    /// <summary>
    /// Запускает интерактивные режимы (панорамирование, перемещение, изменение размеров, перетаскивание точек или рамку зума).
    /// </summary>
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    
    /// <summary>
    /// Выполняет интерактивные операции (смещение графиков, изменение размеров, перетаскивание вершин) в зависимости от активного режима.
    /// </summary>
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    
    /// <summary>
    /// Завершает интерактивные режимы и применяет изменения (например, выполняет зумирование по выделенной рамке).
    /// </summary>
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    
    /// <summary>
    /// Выполняет зумирование графика колесиком мыши относительно текущего положения курсора.
    /// </summary>
    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); override;
  end;

procedure FitZoomX(APage: TChartPage); overload;
procedure FitZoomX(AAxis: TChartAxis); overload;
procedure FitZoomY(APage: TChartPage); overload;
procedure FitZoomY(AAxis: TChartAxis); overload;
procedure FitZoomXY(APage: TChartPage); overload;
procedure FitZoomXY(AAxis: TChartAxis); overload;
procedure FitPageZoom(APage: TChartPage);

implementation

function GetTextLabelPixelRect(ALabel: TChartTextLabel; ARenderer: TOpenGLChartRenderer; APage: TChartPage): TChartPixelRect;
var
  lPageRect, lContentRect: TChartPixelRect;
  lX, lY: Single;
  lPageWidth, lPageHeight: Integer;
begin
  lPageRect := ARenderer.GetPageRect(APage);
  lContentRect := ARenderer.GetPageContentRect(APage);
  lPageWidth := lPageRect.Right - lPageRect.Left;
  lPageHeight := lPageRect.Bottom - lPageRect.Top;

  // Вычисляем X
  if ALabel.IsWorldX then
  begin
    lX := ARenderer.XValueToPixel(APage, nil, ALabel.WorldX, lContentRect.Left, lContentRect.Right);
    Result.Left := Round(lX);
    Result.Right := Result.Left + ALabel.Width;
  end
  else
  begin
    Result.Left := lContentRect.Left + Round(ALabel.FloatRect.Left * (lContentRect.Right - lContentRect.Left));
    Result.Right := lContentRect.Left + Round(ALabel.FloatRect.Right * (lContentRect.Right - lContentRect.Left));
  end;

  // Вычисляем Y
  if ALabel.IsWorldY and Assigned(ALabel.Axis) then
  begin
    lY := ARenderer.AxisValueToPixel(ALabel.Axis, ALabel.WorldY, lContentRect.Bottom, lContentRect.Top);
    Result.Top := Round(lY);
    Result.Bottom := Result.Top + ALabel.Height;
  end
  else
  begin
    Result.Top := lContentRect.Top + Round(ALabel.FloatRect.Top * (lContentRect.Bottom - lContentRect.Top));
    Result.Bottom := lContentRect.Top + Round(ALabel.FloatRect.Bottom * (lContentRect.Bottom - lContentRect.Top));
  end;
end;

/// <summary>
/// Записывает отладочные сообщения во внешний лог-файл 'chart_events.log' в папке запуска приложения.
/// </summary>
/// <param name="AMsg">Сообщение для записи.</param>
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

{ TChartFrameListener }

constructor TChartFrameListener.Create;
begin
  inherited Create;
  fEnabled := True; // По умолчанию все новые слушатели активны
end;

destructor TChartFrameListener.Destroy;
begin
  inherited Destroy;
end;

procedure TChartFrameListener.FrameStarted(ASender: TObject);
begin
  // Базовая реализация пуста. Переопределяется в наследниках при необходимости
end;

procedure TChartFrameListener.FrameEnded(ASender: TObject);
begin
  // Базовая реализация пуста. Переопределяется в наследниках при необходимости
end;

procedure TChartFrameListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
  // Базовая реализация событий ввода пуста
end;

procedure TChartFrameListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);
begin
end;

{ TChartSelectListener }

constructor TChartSelectListener.Create;
begin
  inherited Create;
end;

procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lSelectedAxis: TChartAxis;
  lContentRect: TChartPixelRect;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  I, J, K, lIdx: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
  lHasSelectedPoint: Boolean;
begin
  if not Enabled then Exit;

  // Обрабатываем только левый клик мыши
  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    // 1. Проверяем попадание в текстовые метки (названия осей, подписи значений шкал)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // Не помечаем как Handled (Handled := False), чтобы сработал стандартный текстовый редактор в TOpenGLChartRenderer
      Exit;
    end;

    lModel := TChartModel(lControl.GetModel);
    
    // 1.2. Проверяем попадание в текстовые метки (TChartTextLabel) на активных страницах
    if Assigned(lModel) then
    begin
      for I := 0 to lModel.ChildCount - 1 do
        if lModel.Children[I] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[I]);
          if lPage.Visible then
          begin
            for J := 0 to lPage.ChildCount - 1 do
              if lPage.Children[J] is TChartTextLabel then
              begin
                lPageRect := GetTextLabelPixelRect(TChartTextLabel(lPage.Children[J]), lRenderer, lPage);
                if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                   (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
                begin
                  lRenderer.SelectedObject := lPage.Children[J];
                  lControl.Redraw;
                  Handled := True;
                  Exit;
                end;
              end;
          end;
        end;
    end;

    // 1.5. Проверяем попадание в физическую вертикальную ось Y
    if lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then
    begin
      lRenderer.SelectedObject := lSelectedAxis;
      lControl.Redraw;
      Handled := True; // Прерываем дальнейшую обработку клика
      Exit;
    end;

    // 1.8. Проверяем попадание в вершины Безье нарисованных трендов (cTrend)
    if Assigned(lModel) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            // Если кликнули внутри прямоугольника страницы
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lContentRect := lRenderer.GetPageContentRect(lPage);
              
              // Перебираем оси и тренды на странице
              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is TChartAxis then
                begin
                  lYAxis := TChartAxis(lPage.Children[I]);
                  for J := 0 to lYAxis.ChildCount - 1 do
                    if lYAxis.Children[J] is cTrend then
                    begin
                      lTrend := cTrend(lYAxis.Children[J]);
                      if lTrend.ShowPoints then
                      begin
                        // Ищем, не попали ли мы в какую-либо вершину тренда (радиус попадания - 6 пикселей)
                        for K := 0 to lTrend.BeziePointCount - 1 do
                        begin
                          lPoint := lTrend.BeziePoints[K].Point;
                          lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                          lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            // Выделяем выбранную точку, сбрасывая выделение со всех остальных точек на странице
                            for lIdx := 0 to lPage.ChildCount - 1 do
                              if lPage.Children[lIdx] is TChartAxis then
                              begin
                                lTempAxis := TChartAxis(lPage.Children[lIdx]);
                                for lInnerIdx := 0 to lTempAxis.ChildCount - 1 do
                                  if lTempAxis.Children[lInnerIdx] is cTrend then
                                  begin
                                    lTempTrend := cTrend(lTempAxis.Children[lInnerIdx]);
                                    for lPointIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                      lTempTrend.BeziePoints[lPointIdx].Selected := False;
                                  end;
                              end;
                            lTrend.BeziePoints[K].Selected := True;
                            lRenderer.SelectedObject := lTrend; // Делаем тренд активным объектом
                            lControl.Redraw;
                            Handled := True;
                            Exit;
                          end;
                        end;
                      end;
                    end;
                end;
            end;
          end;
        end;
    end;

    // 2. Проверяем попадание в область страницы (подложку)
    lModel := TChartModel(lControl.GetModel);
    if Assigned(lModel) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              // Если до этого был выделен тренд, проверяем, есть ли выделенные вершины
              if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
              begin
                lTrend := cTrend(lRenderer.SelectedObject);
                lHasSelectedPoint := False;
                for K := 0 to lTrend.BeziePointCount - 1 do
                  if lTrend.BeziePoints[K].Selected then
                  begin
                    lHasSelectedPoint := True;
                    Break;
                  end;

                if lHasSelectedPoint then
                begin
                  // Снимаем выделение со всех вершин тренда, но оставляем активным сам тренд
                  for K := 0 to lTrend.BeziePointCount - 1 do
                    lTrend.BeziePoints[K].Selected := False;
                  lControl.Redraw;
                  Handled := True;
                  Exit;
                end;
              end;

              // Если выделенных точек на тренде не было, то переключаем выделение на саму страницу
              lRenderer.SelectedObject := lPage;
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end;
    end;

    // Снимаем выделение полностью, если кликнули по пустому фону графика
    if Assigned(lRenderer.SelectedObject) then
    begin
      lRenderer.SelectedObject := nil;
      lControl.Redraw;
    end;
  end;
end;

procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lNewHover: TChartBaseObject;
  lSelectedAxis: TChartAxis;
  I, J: Integer;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    lNewHover := nil;

    // 1. Поиск текстовых меток под курсором
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lNewHover := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lNewHover := lHit.Page;
    end;

    // 1.3. Поиск попадания на текстовые метки (TChartTextLabel) на активных страницах
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) then
      begin
        for I := 0 to lModel.ChildCount - 1 do
          if lModel.Children[I] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[I]);
            if lPage.Visible then
            begin
              for J := 0 to lPage.ChildCount - 1 do
                if lPage.Children[J] is TChartTextLabel then
                begin
                  lPageRect := GetTextLabelPixelRect(TChartTextLabel(lPage.Children[J]), lRenderer, lPage);
                  if (X >= lPageRect.Left - 4) and (X <= lPageRect.Right + 4) and
                     (Y >= lPageRect.Top - 4) and (Y <= lPageRect.Bottom + 4) then
                  begin
                    lNewHover := lPage.Children[J];
                    Break;
                  end;
                end;
            end;
            if Assigned(lNewHover) then Break;
          end;
      end;
    end;

    // 1.5. Поиск попадания на физическую линию оси Y (наша доработка)
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) and lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then
        lNewHover := lSelectedAxis;
    end;

    // 2. Поиск страницы под курсором (если курсор не наведен на ось или текст)
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                lNewHover := lPage;
                Break;
              end;
            end;
          end;
      end;
    end;

    // Если состояние наведенного объекта изменилось, обновляем рендерер и перерисовываем чарт
    if lRenderer.HoveredObject <> lNewHover then
    begin
      lRenderer.HoveredObject := lNewHover;
      lControl.Redraw;
    end;

    // Управление формой курсора для текстовых меток и осей
    if lNewHover is TChartTextLabel then
    begin
      lPageRect := GetTextLabelPixelRect(TChartTextLabel(lNewHover), lRenderer, TChartPage(lNewHover.Parent));
      if (Abs(X - lPageRect.Right) <= 5) and (Abs(Y - lPageRect.Bottom) <= 5) then
        TControl(ASender).Cursor := crSizeNWSE
      else if (Abs(X - lPageRect.Right) <= 5) and (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        TControl(ASender).Cursor := crSizeWE
      else if (Abs(Y - lPageRect.Bottom) <= 5) and (X >= lPageRect.Left) and (X <= lPageRect.Right) then
        TControl(ASender).Cursor := crSizeNS
      else if not TChartTextLabel(lNewHover).Locked then
        TControl(ASender).Cursor := crSizeAll
      else
        TControl(ASender).Cursor := crDefault;
    end
    else if lNewHover is TChartAxis then
      TControl(ASender).Cursor := crHandPoint
    else if TControl(ASender).Cursor in [crHandPoint, crSizeNWSE, crSizeWE, crSizeNS, crSizeAll] then
      TControl(ASender).Cursor := crDefault;
  end;
end;



procedure TChartSelectListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  lAxis: TChartAxis;
  lPage: TChartPage;
  lContentRect: TChartPixelRect;
  lXRange, lYRange: Double;
  I, lNewIdx: Integer;
  lMousePos: TPoint;
  lMouseX, lMouseY: Integer;
begin
  if not Enabled then Exit;

  LogToFile('SelectListener.KeyDown: Key=' + IntToStr(Key));

  // Обрабатываем клавиши DELETE (код 46) и INSERT (код 45)
  if (Key in [45, 46]) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) then
    begin
      if Assigned(lRenderer.SelectedObject) then
        LogToFile('  SelectedObject is ' + lRenderer.SelectedObject.ClassName + ' (Name: ' + lRenderer.SelectedObject.Name + ')')
      else
        LogToFile('  SelectedObject is nil');

      // Горячие клавиши применимы, только если выделен тренд
      if (lRenderer.SelectedObject is cTrend) then
      begin
        lTrend := cTrend(lRenderer.SelectedObject);
        
        // Удаление выделенной вершины тренда (клавиша DELETE)
        if Key = 46 then
        begin
          for I := 0 to lTrend.BeziePointCount - 1 do
          begin
            if lTrend.BeziePoints[I].Selected then
            begin
              LogToFile('  Deleting point ' + IntToStr(I));
              lTrend.DeleteBeziePoint(I);
              // Снимаем выделение со всех вершин во избежание некорректных индексов
              for lNewIdx := 0 to lTrend.BeziePointCount - 1 do
                lTrend.BeziePoints[lNewIdx].Selected := False;
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end
        // Вставка новой вершины тренда под указателем мыши (клавиша INSERT)
        else if Key = 45 then
        begin
          if Assigned(lTrend.Parent) and (lTrend.Parent is TChartAxis) then
          begin
            lAxis := TChartAxis(lTrend.Parent);
            if Assigned(lAxis.Parent) and (lAxis.Parent is TChartPage) then
            begin
              lPage := TChartPage(lAxis.Parent);
              lContentRect := lRenderer.GetPageContentRect(lPage);
              
              // Переводим текущие экранные координаты мыши в координаты осей
              lMousePos := TControl(ASender).ScreenToClient(Mouse.CursorPos);
              lMouseX := lMousePos.X;
              lMouseY := lMousePos.Y;

              lXRange := lRenderer.PixelToXValue(lPage, nil, lMouseX, lContentRect.Left, lContentRect.Right);
              lYRange := lRenderer.PixelToAxisValue(lAxis, lMouseY, lContentRect.Bottom, lContentRect.Top);

              LogToFile('  Inserting point at values X=' + FloatToStr(lXRange) + ', Y=' + FloatToStr(lYRange));

              // Вставляем угловую точку (bptCorner)
              lTrend.InsertBeziePoint(lXRange, lYRange, bptCorner);
              lControl.Redraw;
              Handled := True;
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TChartSelectListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);
var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  I: Integer;
begin
  if not Enabled then Exit;

  // Изменение типа вершины выделенного тренда ('1' - угол, '2' - гладкая, '3' - скрытая, 'T' - циклический перебор)
  if (Key in ['1', '2', '3', 't', 'T']) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
    begin
      lTrend := cTrend(lRenderer.SelectedObject);
      for I := 0 to lTrend.BeziePointCount - 1 do
      begin
        if lTrend.BeziePoints[I].Selected then
        begin
          case Key of
            '1': lTrend.BeziePoints[I].PointType := bptCorner;
            '2': lTrend.BeziePoints[I].PointType := bptSmooth;
            '3': lTrend.BeziePoints[I].PointType := bptNull;
            't', 'T': 
              begin
                // Циклический перебор типов точки
                case lTrend.BeziePoints[I].PointType of
                  bptCorner: lTrend.BeziePoints[I].PointType := bptSmooth;
                  bptSmooth: lTrend.BeziePoints[I].PointType := bptNull;
                  bptNull: lTrend.BeziePoints[I].PointType := bptCorner;
                end;
              end;
          end;
          lTrend.GenerateSplinePoints; // Пересчитываем сплайн по новым типам точек
          lControl.Redraw;
          Handled := True;
          Exit;
        end;
      end;
    end;
  end;
end;

type
  TAxisBounds = record
    Axis: TChartAxis;
    MinY, MaxY: Double;
    MinX, MaxX: Double;
    HasY, HasX: Boolean;
  end;
  TAxisBoundsArray = array of TAxisBounds;

function GetOrAddAxisBounds(AAxis: TChartAxis; var ABounds: TAxisBoundsArray): Integer;
var
  i: Integer;
begin
  for i := 0 to High(ABounds) do
    if ABounds[i].Axis = AAxis then
    begin
      Result := i;
      Exit;
    end;
  SetLength(ABounds, Length(ABounds) + 1);
  Result := High(ABounds);
  ABounds[Result].Axis := AAxis;
  ABounds[Result].MinY := 1E30;
  ABounds[Result].MaxY := -1E30;
  ABounds[Result].MinX := 1E30;
  ABounds[Result].MaxX := -1E30;
  ABounds[Result].HasY := False;
  ABounds[Result].HasX := False;
end;

function FindParentAxis(AObject: TChartBaseObject): TChartAxis;
var
  p: TChartBaseObject;
begin
  Result := nil;
  p := AObject.Parent;
  while Assigned(p) do
  begin
    if p is TChartAxis then
    begin
      Result := TChartAxis(p);
      Exit;
    end;
    p := p.Parent;
  end;
end;

function FindParentPage(AObject: TChartBaseObject): TChartPage;
var
  p: TChartBaseObject;
begin
  Result := nil;
  p := AObject.Parent;
  while Assigned(p) do
  begin
    if p is TChartPage then
    begin
      Result := TChartPage(p);
      Exit;
    end;
    p := p.Parent;
  end;
end;

procedure ProcessObjectBounds(AObject: TChartBaseObject; APage: TChartPage; var APageMinX, APageMaxX: Double; var AHasPageX: Boolean; var ABounds: TAxisBoundsArray);
var
  lIdx, lPtIdx, lAxisIdx: Integer;
  lLine: TChartLineSeries;
  lBuff1d: cBuffTrend1d;
  lAxis: TChartAxis;
  lVal: Double;
  lTextLabel: TChartTextLabel;
begin
  if not Assigned(AObject) then Exit;

  // 1. Если это линия тренда / ряд точек
  if AObject is TChartLineSeries then
  begin
    lLine := TChartLineSeries(AObject);
    lAxis := FindParentAxis(lLine);
    if Assigned(lAxis) then
    begin
      lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
      for lPtIdx := 0 to lLine.PointCount - 1 do
      begin
        ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lLine.Points[lPtIdx].Y);
        ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lLine.Points[lPtIdx].Y);
        ABounds[lAxisIdx].HasY := True;

        if lAxis.UseOwnX then
        begin
          ABounds[lAxisIdx].MinX := Min(ABounds[lAxisIdx].MinX, lLine.Points[lPtIdx].X);
          ABounds[lAxisIdx].MaxX := Max(ABounds[lAxisIdx].MaxX, lLine.Points[lPtIdx].X);
          ABounds[lAxisIdx].HasX := True;
        end
        else
        begin
          APageMinX := Min(APageMinX, lLine.Points[lPtIdx].X);
          APageMaxX := Max(APageMaxX, lLine.Points[lPtIdx].X);
          AHasPageX := True;
        end;
      end;
    end;
  end
  // 2. Если это буферизованный тренд 1D
  else if AObject is cBuffTrend1d then
  begin
    lBuff1d := cBuffTrend1d(AObject);
    lAxis := FindParentAxis(lBuff1d);
    if Assigned(lAxis) then
    begin
      lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
      for lPtIdx := 0 to lBuff1d.Count - 1 do
      begin
        ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lBuff1d.Values[lPtIdx]);
        ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lBuff1d.Values[lPtIdx]);
        ABounds[lAxisIdx].HasY := True;

        if lAxis.UseOwnX then
        begin
          ABounds[lAxisIdx].MinX := Min(ABounds[lAxisIdx].MinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          ABounds[lAxisIdx].MaxX := Max(ABounds[lAxisIdx].MaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          ABounds[lAxisIdx].HasX := True;
        end
        else
        begin
          APageMinX := Min(APageMinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          APageMaxX := Max(APageMaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          AHasPageX := True;
        end;
      end;
    end;
  end
  // 3. Если это метка или флаг
  else if AObject is TChartTextLabel then
  begin
    lTextLabel := TChartTextLabel(AObject);
    lAxis := lTextLabel.Axis;
    
    // Если это флаг, его ось определяется осью тренда, к которому он привязан
    if (lTextLabel is TChartFlagLabel) and Assigned(TChartFlagLabel(lTextLabel).Trend) then
      lAxis := FindParentAxis(TChartFlagLabel(lTextLabel).Trend);

    // Если ось у метки все еще не задана, попробуем найти родительскую ось или взять первую ось на странице
    if not Assigned(lAxis) then
      lAxis := FindParentAxis(lTextLabel);
    if not Assigned(lAxis) and Assigned(APage) then
    begin
      for lIdx := 0 to APage.ChildCount - 1 do
        if APage.Children[lIdx] is TChartAxis then
        begin
          lAxis := TChartAxis(APage.Children[lIdx]);
          Break;
        end;
    end;

    // По X
    if lTextLabel.IsWorldX then
    begin
      if Assigned(lAxis) and lAxis.UseOwnX then
      begin
        lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
        ABounds[lAxisIdx].MinX := Min(ABounds[lAxisIdx].MinX, lTextLabel.WorldX);
        ABounds[lAxisIdx].MaxX := Max(ABounds[lAxisIdx].MaxX, lTextLabel.WorldX);
        ABounds[lAxisIdx].HasX := True;
      end
      else
      begin
        APageMinX := Min(APageMinX, lTextLabel.WorldX);
        APageMaxX := Max(APageMaxX, lTextLabel.WorldX);
        AHasPageX := True;
      end;
    end;

    // По Y
    if lTextLabel.IsWorldY or (lTextLabel is TChartFlagLabel) then
    begin
      if Assigned(lAxis) then
      begin
        lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
        if lTextLabel is TChartFlagLabel then
        begin
          if GetTrendValueAtX(TChartFlagLabel(lTextLabel).Trend, TChartFlagLabel(lTextLabel).WorldX, lVal) then
          begin
            ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lVal);
            ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lVal);
            ABounds[lAxisIdx].HasY := True;
          end;
        end
        else
        begin
          ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lTextLabel.WorldY);
          ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lTextLabel.WorldY);
          ABounds[lAxisIdx].HasY := True;
        end;
      end;
    end;
  end;

  // Рекурсивно обходим детей
  for lIdx := 0 to AObject.ChildCount - 1 do
    ProcessObjectBounds(AObject.Children[lIdx], APage, APageMinX, APageMaxX, AHasPageX, ABounds);
end;

procedure FitZoomX(APage: TChartPage);
var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
begin
  if not Assigned(APage) then Exit;
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);

  ProcessObjectBounds(APage, APage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);

  if lHasPageX then
  begin
    if Abs(lPageMaxX - lPageMinX) < 1E-9 then
    begin
      lPageMinX := lPageMinX - 1.0;
      lPageMaxX := lPageMaxX + 1.0;
    end;
    APage.XMinValue := lPageMinX;
    APage.XMaxValue := lPageMaxX;
  end;

  for lIdx := 0 to High(lAxisBounds) do
  begin
    if lAxisBounds[lIdx].HasX and lAxisBounds[lIdx].Axis.UseOwnX then
    begin
      if Abs(lAxisBounds[lIdx].MaxX - lAxisBounds[lIdx].MinX) < 1E-9 then
      begin
        lAxisBounds[lIdx].MinX := lAxisBounds[lIdx].MinX - 1.0;
        lAxisBounds[lIdx].MaxX := lAxisBounds[lIdx].MaxX + 1.0;
      end;
      lAxisBounds[lIdx].Axis.XMinValue := lAxisBounds[lIdx].MinX;
      lAxisBounds[lIdx].Axis.XMaxValue := lAxisBounds[lIdx].MaxX;
    end;
  end;
end;

procedure FitZoomX(AAxis: TChartAxis);
var
  lPage: TChartPage;
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
begin
  if not Assigned(AAxis) then Exit;
  lPage := FindParentPage(AAxis);
  if not Assigned(lPage) then Exit;

  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);

  ProcessObjectBounds(lPage, lPage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);

  if AAxis.UseOwnX then
  begin
    for lIdx := 0 to High(lAxisBounds) do
      if lAxisBounds[lIdx].Axis = AAxis then
      begin
        if lAxisBounds[lIdx].HasX then
        begin
          if Abs(lAxisBounds[lIdx].MaxX - lAxisBounds[lIdx].MinX) < 1E-9 then
          begin
            lAxisBounds[lIdx].MinX := lAxisBounds[lIdx].MinX - 1.0;
            lAxisBounds[lIdx].MaxX := lAxisBounds[lIdx].MaxX + 1.0;
          end;
          AAxis.XMinValue := lAxisBounds[lIdx].MinX;
          AAxis.XMaxValue := lAxisBounds[lIdx].MaxX;
        end;
        Break;
      end;
  end
  else
  begin
    if lHasPageX then
    begin
      if Abs(lPageMaxX - lPageMinX) < 1E-9 then
      begin
        lPageMinX := lPageMinX - 1.0;
        lPageMaxX := lPageMaxX + 1.0;
      end;
      lPage.XMinValue := lPageMinX;
      lPage.XMaxValue := lPageMaxX;
    end;
  end;
end;

procedure FitZoomY(APage: TChartPage);
var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
  lSpan: Double;
begin
  if not Assigned(APage) then Exit;
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);

  ProcessObjectBounds(APage, APage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);

  for lIdx := 0 to High(lAxisBounds) do
  begin
    if lAxisBounds[lIdx].HasY then
    begin
      if Abs(lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY) < 1E-9 then
      begin
        lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - 1.0;
        lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + 1.0;
      end
      else
      begin
        lSpan := lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY;
        lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - lSpan * 0.1;
        lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + lSpan * 0.1;
      end;
      lAxisBounds[lIdx].Axis.MinValue := lAxisBounds[lIdx].MinY;
      lAxisBounds[lIdx].Axis.MaxValue := lAxisBounds[lIdx].MaxY;
    end;
  end;
end;

procedure FitZoomY(AAxis: TChartAxis);
var
  lPage: TChartPage;
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
  lSpan: Double;
begin
  if not Assigned(AAxis) then Exit;
  lPage := FindParentPage(AAxis);
  if not Assigned(lPage) then Exit;

  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);

  ProcessObjectBounds(lPage, lPage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);

  for lIdx := 0 to High(lAxisBounds) do
    if lAxisBounds[lIdx].Axis = AAxis then
    begin
      if lAxisBounds[lIdx].HasY then
      begin
        if Abs(lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY) < 1E-9 then
        begin
          lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - 1.0;
          lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + 1.0;
        end
        else
        begin
          lSpan := lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY;
          lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - lSpan * 0.1;
          lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + lSpan * 0.1;
        end;
        AAxis.MinValue := lAxisBounds[lIdx].MinY;
        AAxis.MaxValue := lAxisBounds[lIdx].MaxY;
      end;
      Break;
    end;
end;

procedure FitZoomXY(APage: TChartPage);
begin
  FitZoomX(APage);
  FitZoomY(APage);
end;

procedure FitZoomXY(AAxis: TChartAxis);
begin
  FitZoomX(AAxis);
  FitZoomY(AAxis);
end;

procedure FitPageZoom(APage: TChartPage);
begin
  FitZoomXY(APage);
end;

{ TChartPanZoomListener }

constructor TChartPanZoomListener.Create;
begin
  inherited Create;
  fIsPanning := False;
  fActivePage := nil;
  fResizingBorder := 0;
  fMovingPage := False;
  fIsResizing := False;
  fSnapSensitivity := 5;
  fIsZoomSelecting := False;
  fZoomStartX := 0;
  fZoomStartY := 0;
  fIsDraggingPoint := False;
  fDragTrend := nil;
  fDragPointIdx := -1;
  fDragPart := cdpPoint;
end;

/// <summary>
/// Обработчик нажатия кнопки мыши для управления зумом, панорамированием, перетаскиванием и изменением размеров.
/// Инициирует соответствующее интерактивное состояние в зависимости от клавиш-модификаторов и кнопок.
/// </summary>
procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  lXLeft, lYLeft, lXRight, lYRight: Single;
  J, K, lIdx, I: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if Button = mbLeft then
    begin
      // 0.5. Проверяем попадание в вершины тренда для перетаскивания (mbLeft)
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lContentRect := lRenderer.GetPageContentRect(lPage);
              
              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is TChartAxis then
                begin
                  lYAxis := TChartAxis(lPage.Children[I]);
                  for J := 0 to lYAxis.ChildCount - 1 do
                    if lYAxis.Children[J] is cTrend then
                    begin
                      lTrend := cTrend(lYAxis.Children[J]);
                      if lTrend.ShowPoints then
                      begin
                        for K := 0 to lTrend.BeziePointCount - 1 do
                        begin
                          lPoint := lTrend.BeziePoints[K].Point;
                          lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                          lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                          // Если вершина сглаженная и выделена, сначала проверяем её направляющие векторы (усы)
                          if (lTrend.BeziePoints[K].PointType = bptSmooth) and lTrend.BeziePoints[K].Selected then
                          begin
                            lXLeft := lRenderer.XValueToPixel(lPage, lYAxis, lTrend.BeziePoints[K].Left.X, lContentRect.Left, lContentRect.Right);
                            lYLeft := lRenderer.AxisValueToPixel(lYAxis, lTrend.BeziePoints[K].Left.Y, lContentRect.Bottom, lContentRect.Top);
                            lXRight := lRenderer.XValueToPixel(lPage, lYAxis, lTrend.BeziePoints[K].Right.X, lContentRect.Left, lContentRect.Right);
                            lYRight := lRenderer.AxisValueToPixel(lYAxis, lTrend.BeziePoints[K].Right.Y, lContentRect.Bottom, lContentRect.Top);

                            if (Abs(X - lXLeft) <= 6) and (Abs(Y - lYLeft) <= 6) then
                            begin
                              fIsDraggingPoint := True;
                              fDragTrend := lTrend;
                              fDragPointIdx := K;
                              fDragPart := cdpLeft;
                              fActivePage := lPage;
                              Handled := True;
                              Exit;
                            end;

                            if (Abs(X - lXRight) <= 6) and (Abs(Y - lYRight) <= 6) then
                            begin
                              fIsDraggingPoint := True;
                              fDragTrend := lTrend;
                              fDragPointIdx := K;
                              fDragPart := cdpRight;
                              fActivePage := lPage;
                              Handled := True;
                              Exit;
                            end;
                          end;

                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            fIsDraggingPoint := True;
                            fDragTrend := lTrend;
                            fDragPointIdx := K;
                            fDragPart := cdpPoint;
                            fActivePage := lPage;

                            // Снимаем выделение со всех вершин всех трендов страницы
                            for lIdx := 0 to lPage.ChildCount - 1 do
                              if lPage.Children[lIdx] is TChartAxis then
                              begin
                                lTempAxis := TChartAxis(lPage.Children[lIdx]);
                                for lInnerIdx := 0 to lTempAxis.ChildCount - 1 do
                                  if lTempAxis.Children[lInnerIdx] is cTrend then
                                  begin
                                    lTempTrend := cTrend(lTempAxis.Children[lInnerIdx]);
                                    for lPointIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                      lTempTrend.BeziePoints[lPointIdx].Selected := False;
                                  end;
                              end;
                            lTrend.BeziePoints[K].Selected := True;
                            lRenderer.SelectedObject := lTrend;
                            lControl.Redraw;
                            Handled := True;
                            Exit;
                          end;
                        end;
                      end;
                    end;
                end;
            end;
          end;
        end;

      // 0.8. Проверяем попадание в текстовую метку (TChartTextLabel) для перетаскивания или изменения размеров
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if lPage.Visible then
          begin
            for J := 0 to lPage.ChildCount - 1 do
              if lPage.Children[J] is TChartTextLabel then
              begin
                lPageRect := GetTextLabelPixelRect(TChartTextLabel(lPage.Children[J]), lRenderer, lPage);
                if (X >= lPageRect.Left - 5) and (X <= lPageRect.Right + 5) and
                   (Y >= lPageRect.Top - 5) and (Y <= lPageRect.Bottom + 5) then
                begin
                  fDragLabel := TChartTextLabel(lPage.Children[J]);
                  if not fDragLabel.Locked then
                  begin
                    fIsDraggingLabel := True;
                    fActivePage := lPage;
                    fLastX := X;
                    fLastY := Y;
                    
                    // Вычисляем, за какую границу тащим
                    if (Abs(X - lPageRect.Right) <= 5) and (Abs(Y - lPageRect.Bottom) <= 5) then
                      fDragLabelBorder := 5 // правый нижний угол (ресайз по обеим осям)
                    else if (Abs(X - lPageRect.Right) <= 5) then
                      fDragLabelBorder := 3 // правая граница (ресайз ширины)
                    else if (Abs(Y - lPageRect.Bottom) <= 5) then
                      fDragLabelBorder := 4 // нижняя граница (ресайз высоты)
                    else
                      fDragLabelBorder := 0; // перемещение всей метки

                    lRenderer.SelectedObject := fDragLabel;
                    lControl.Redraw;
                    Handled := True;
                    Exit;
                  end;
                end;
              end;
          end;
        end;

      // 1. Изменение размеров выделенной страницы
      if (fResizingBorder > 0) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
      begin
        lPage := TChartPage(lRenderer.SelectedObject);
        if not lPage.Locked then
        begin
          fIsResizing := True;
          fActivePage := lPage;

          for lInnerIndex := 0 to lModel.ChildCount - 1 do
            if lModel.Children[lInnerIndex] is TChartPage then
              TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

          fLastX := X;
          fLastY := Y;
          Handled := True;
          Exit;
        end;
      end;

      // 2. Если зажат Ctrl, то это режим зума по рамке (только внутри plot area)
      if ssCtrl in Shift then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                lContentRect := lRenderer.GetPageContentRect(lPage);
                if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                   (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
                begin
                  // Клик внутри области построения - начинаем выделение зума
                  fIsZoomSelecting := True;
                  fZoomStartX := X;
                  fZoomStartY := Y;
                  fActivePage := lPage;
                  Handled := True;
                  Exit;
                end;
              end;
            end;
          end;
      end;

      // 3. Если зажат Shift, то это режим перемещения страницы
      if ssShift in Shift then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                fMovingPage := True;
                fActivePage := lPage;

                for lInnerIndex := 0 to lModel.ChildCount - 1 do
                  if lModel.Children[lInnerIndex] is TChartPage then
                    TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

                fLastX := X;
                fLastY := Y;
                TControl(ASender).Cursor := crSizeAll;
                Handled := True;
                Exit;
              end;
            end;
          end;
      end;
    end;

    if (Button = mbRight) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              fIsPanning := True;
              fLastX := X;
              fLastY := Y;
              fActivePage := lPage;
              Handled := True;
              Exit;
            end;
          end;
        end;
    end;
  end;
end;

/// <summary>
/// Обработчик перемещения мыши. Выполняет интерактивное перемещение страниц с Shift, 
/// изменение размеров страниц за границы, перетаскивание вершин Безье, панорамирование (Pan) правой кнопкой 
/// и выделение рамки зума (Ctrl + Drag).
/// </summary>
procedure TChartPanZoomListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPageRect: TChartPixelRect;
  lWidth, lHeight: Single;
  lXRange, lYRange: Double;
  dX, dY: Integer;
  dValX, dValY: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
  lPage, lTempPage: TChartPage;
  lRect: TChartFloatRect;
  lTargetVal: Integer;
  lTargetLeft, lTargetTop, lTargetRight, lTargetBottom: Integer;
  lSnappedLeft, lSnappedRight, lSnappedTop, lSnappedBottom: Integer;
  lPageWidth, lPageHeight: Integer;
  lSelRect: TChartPixelRect;
  lContentRect: TChartPixelRect;

  /// <summary>
  /// Выполняет примагничивание горизонтальной координаты X к границам других страниц или области построения.
  /// </summary>
  function SnapX(APixelX: Integer; AExcludePage: TChartPage; AMaxDiff: Integer): Integer;
  var
    lIdx: Integer;
    lOtherPage: TChartPage;
    lOtherRect: TChartPixelRect;
  begin
    Result := APixelX;
    for lIdx := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIdx] is TChartPage then
      begin
        lOtherPage := TChartPage(lModel.Children[lIdx]);
        if lOtherPage <> AExcludePage then
        begin
          lOtherRect := lRenderer.GetPageRect(lOtherPage);
          if Abs(APixelX - lOtherRect.Left) <= AMaxDiff then
          begin
            Result := lOtherRect.Left;
            Exit;
          end;
          if Abs(APixelX - lOtherRect.Right) <= AMaxDiff then
          begin
            Result := lOtherRect.Right;
            Exit;
          end;
        end;
      end;
    if Abs(APixelX - Round(lModel.PageArea.Left * lWidth)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Left * lWidth)
    else if Abs(APixelX - Round(lModel.PageArea.Right * lWidth)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Right * lWidth);
  end;

  /// <summary>
  /// Выполняет примагничивание вертикальной координаты Y к границам других страниц или области построения.
  /// </summary>
  function SnapY(APixelY: Integer; AExcludePage: TChartPage; AMaxDiff: Integer): Integer;
  var
    lIdx: Integer;
    lOtherPage: TChartPage;
    lOtherRect: TChartPixelRect;
  begin
    Result := APixelY;
    for lIdx := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIdx] is TChartPage then
      begin
        lOtherPage := TChartPage(lModel.Children[lIdx]);
        if lOtherPage <> AExcludePage then
        begin
          lOtherRect := lRenderer.GetPageRect(lOtherPage);
          if Abs(APixelY - lOtherRect.Top) <= AMaxDiff then
          begin
            Result := lOtherRect.Top;
            Exit;
          end;
          if Abs(APixelY - lOtherRect.Bottom) <= AMaxDiff then
          begin
            Result := lOtherRect.Bottom;
            Exit;
          end;
        end;
      end;
    if Abs(APixelY - Round(lModel.PageArea.Top * lHeight)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Top * lHeight)
    else if Abs(APixelY - Round(lModel.PageArea.Bottom * lHeight)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Bottom * lHeight);
  end;

begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    lWidth := Max(1.0, TControl(ASender).Width);
    lHeight := Max(1.0, TControl(ASender).Height);

    // 0.2. Состояние перетаскивания вершины тренда
    if fIsDraggingPoint and Assigned(fDragTrend) and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lAxis := nil;
      if Assigned(fDragTrend.Parent) and (fDragTrend.Parent is TChartAxis) then
        lAxis := TChartAxis(fDragTrend.Parent);
      if not Assigned(lAxis) then
      begin
        for lIndex := 0 to fActivePage.ChildCount - 1 do
          if fActivePage.Children[lIndex] is TChartAxis then
          begin
            lAxis := TChartAxis(fActivePage.Children[lIndex]);
            Break;
          end;
      end;

      if Assigned(lAxis) then
      begin
        lXRange := lRenderer.PixelToXValue(fActivePage, nil, X, lContentRect.Left, lContentRect.Right);
        lYRange := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);

        if lXRange < fActivePage.XMinValue then lXRange := fActivePage.XMinValue;
        if lXRange > fActivePage.XMaxValue then lXRange := fActivePage.XMaxValue;

        if lYRange < lAxis.MinValue then lYRange := lAxis.MinValue;
        if lYRange > lAxis.MaxValue then lYRange := lAxis.MaxValue;

        case fDragPart of
          cdpPoint: fDragTrend.UpdateBeziePoint(fDragPointIdx, lXRange, lYRange);
          cdpLeft: fDragTrend.UpdateBezieLeft(fDragPointIdx, lXRange, lYRange);
          cdpRight: fDragTrend.UpdateBezieRight(fDragPointIdx, lXRange, lYRange);
        end;
        lControl.Redraw;
        Handled := True;
        Exit;
      end;
    end;

    // 0.1. Состояние перетаскивания или изменения размеров текстовой метки
    if fIsDraggingLabel and Assigned(fDragLabel) and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;
      
      lPageRect := lRenderer.GetPageRect(fActivePage);
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lPageWidth := Max(1, lContentRect.Right - lContentRect.Left);
      lPageHeight := Max(1, lContentRect.Bottom - lContentRect.Top);
      
      // Перемещение
      if fDragLabelBorder = 0 then
      begin
        if fDragLabel.IsWorldX then
        begin
          lXRange := lRenderer.XValueToPixel(fActivePage, nil, fDragLabel.WorldX, lContentRect.Left, lContentRect.Right);
          fDragLabel.WorldX := lRenderer.PixelToXValue(fActivePage, nil, lXRange + dX, lContentRect.Left, lContentRect.Right);
        end
        else
        begin
          lRect := fDragLabel.FloatRect;
          dValX := lRect.Right - lRect.Left;
          lRect.Left := lRect.Left + dX / lPageWidth;
          if lRect.Left < 0.0 then lRect.Left := 0.0;
          if lRect.Left + dValX > 1.0 then lRect.Left := 1.0 - dValX;
          lRect.Right := lRect.Left + dValX;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

        if fDragLabel.IsWorldY and Assigned(fDragLabel.Axis) then
        begin
          lYRange := lRenderer.AxisValueToPixel(fDragLabel.Axis, fDragLabel.WorldY, lContentRect.Bottom, lContentRect.Top);
          fDragLabel.WorldY := lRenderer.PixelToAxisValue(fDragLabel.Axis, lYRange + dY, lContentRect.Bottom, lContentRect.Top);
        end
        else
        begin
          lRect := fDragLabel.FloatRect;
          dValY := lRect.Bottom - lRect.Top;
          lRect.Top := lRect.Top + dY / lPageHeight;
          if lRect.Top < 0.0 then lRect.Top := 0.0;
          if lRect.Top + dValY > 1.0 then lRect.Top := 1.0 - dValY;
          lRect.Bottom := lRect.Top + dValY;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;
      end
      // Изменение ширины
      else if fDragLabelBorder = 3 then
      begin
        if fDragLabel.IsWorldX then
          fDragLabel.Width := Max(20, fDragLabel.Width + dX)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Right := Max(lRect.Left + 0.01, lRect.Right + dX / lPageWidth);
          if lRect.Right > 1.0 then lRect.Right := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;
      end
      // Изменение высоты
      else if fDragLabelBorder = 4 then
      begin
        if fDragLabel.IsWorldY and Assigned(fDragLabel.Axis) then
          fDragLabel.Height := Max(15, fDragLabel.Height + dY)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Bottom := Max(lRect.Top + 0.01, lRect.Bottom + dY / lPageHeight);
          if lRect.Bottom > 1.0 then lRect.Bottom := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;
      end
      // Угол (ширина и высота)
      else if fDragLabelBorder = 5 then
      begin
        if fDragLabel.IsWorldX then
          fDragLabel.Width := Max(20, fDragLabel.Width + dX)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Right := Max(lRect.Left + 0.01, lRect.Right + dX / lPageWidth);
          if lRect.Right > 1.0 then lRect.Right := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;

        if fDragLabel.IsWorldY and Assigned(fDragLabel.Axis) then
          fDragLabel.Height := Max(15, fDragLabel.Height + dY)
        else
        begin
          lRect := fDragLabel.FloatRect;
          lRect.Bottom := Max(lRect.Top + 0.01, lRect.Bottom + dY / lPageHeight);
          if lRect.Bottom > 1.0 then lRect.Bottom := 1.0;
          fDragLabel.SetFloatRect(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        end;
      end;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 0. Состояние выделения области зумирования (Ctrl + Drag)
    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lSelRect.Left := Max(lContentRect.Left, Min(fZoomStartX, X));
      lSelRect.Right := Min(lContentRect.Right, Max(fZoomStartX, X));
      lSelRect.Top := Max(lContentRect.Top, Min(fZoomStartY, Y));
      lSelRect.Bottom := Min(lContentRect.Bottom, Max(fZoomStartY, Y));

      lRenderer.SelectionRectActive := True;
      lRenderer.SelectionRect := lSelRect;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 1. Состояние перетаскивания изменения размеров границы страницы
    if fIsResizing and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;

      lPageRect := lRenderer.GetPageRect(fActivePage);
      lRect := fActivePage.FloatRect;

      case fResizingBorder of
        1: // Левая граница
          begin
            lTargetVal := SnapX(lPageRect.Left + dX, fActivePage, fSnapSensitivity);
            lRect.Left := Min(lRect.Right - 0.05, lTargetVal / lWidth);
          end;
        2: // Правая граница
          begin
            lTargetVal := SnapX(lPageRect.Right + dX, fActivePage, fSnapSensitivity);
            lRect.Right := Max(lRect.Left + 0.05, lTargetVal / lWidth);
          end;
        3: // Верхняя граница
          begin
            lTargetVal := SnapY(lPageRect.Top + dY, fActivePage, fSnapSensitivity);
            lRect.Top := Min(lRect.Bottom - 0.05, lTargetVal / lHeight);
          end;
        4: // Нижняя граница
          begin
            lTargetVal := SnapY(lPageRect.Bottom + dY, fActivePage, fSnapSensitivity);
            lRect.Bottom := Max(lRect.Top + 0.05, lTargetVal / lHeight);
          end;
      end;
      fActivePage.FloatRect := lRect;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 2. Состояние перемещения страницы (с зажатым Ctrl)
    if fMovingPage and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;

      lPageRect := lRenderer.GetPageRect(fActivePage);
      lTargetLeft := lPageRect.Left + dX;
      lTargetTop := lPageRect.Top + dY;

      // Примагничивание по X (левая или правая граница)
      lSnappedLeft := SnapX(lTargetLeft, fActivePage, fSnapSensitivity);
      if lSnappedLeft <> lTargetLeft then
        lTargetLeft := lSnappedLeft
      else
      begin
        lTargetRight := lPageRect.Right + dX;
        lSnappedRight := SnapX(lTargetRight, fActivePage, fSnapSensitivity);
        if lSnappedRight <> lTargetRight then
          lTargetLeft := lSnappedRight - (lPageRect.Right - lPageRect.Left);
      end;

      // Примагничивание по Y (верхняя или нижняя граница)
      lSnappedTop := SnapY(lTargetTop, fActivePage, fSnapSensitivity);
      if lSnappedTop <> lTargetTop then
        lTargetTop := lSnappedTop
      else
      begin
        lTargetBottom := lPageRect.Bottom + dY;
        lSnappedBottom := SnapY(lTargetBottom, fActivePage, fSnapSensitivity);
        if lSnappedBottom <> lTargetBottom then
          lTargetTop := lSnappedBottom - (lPageRect.Bottom - lPageRect.Top);
      end;

      lPageWidth := lPageRect.Right - lPageRect.Left;
      lPageHeight := lPageRect.Bottom - lPageRect.Top;

      lRect.Left := lTargetLeft / lWidth;
      lRect.Right := (lTargetLeft + lPageWidth) / lWidth;
      lRect.Top := lTargetTop / lHeight;
      lRect.Bottom := (lTargetTop + lPageHeight) / lHeight;

      fActivePage.FloatRect := lRect;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 3. Состояние обычного панорамирования графика правой кнопкой мыши
    if fIsPanning and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lWidth := Max(1.0, lContentRect.Right - lContentRect.Left);
      lHeight := Max(1.0, lContentRect.Bottom - lContentRect.Top);

      dX := X - fLastX;
      dY := Y - fLastY;

      lXRange := fActivePage.XMaxValue - fActivePage.XMinValue;
      dValX := (dX / lWidth) * lXRange;
      fActivePage.XMinValue := fActivePage.XMinValue - dValX;
      fActivePage.XMaxValue := fActivePage.XMaxValue - dValX;

      for lIndex := 0 to fActivePage.ChildCount - 1 do
        if fActivePage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(fActivePage.Children[lIndex]);
          lYRange := lAxis.MaxValue - lAxis.MinValue;
          dValY := (dY / lHeight) * lYRange;
          lAxis.MinValue := lAxis.MinValue + dValY;
          lAxis.MaxValue := lAxis.MaxValue + dValY;
        end;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 4. Обычное движение мыши: меняем курсор при наведении на границы выделенной страницы
    if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
    begin
      lPage := TChartPage(lRenderer.SelectedObject);
      lPageRect := lRenderer.GetPageRect(lPage);

      fResizingBorder := 0;
      if (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
      begin
        if Abs(X - lPageRect.Left) <= 6 then
          fResizingBorder := 1
        else if Abs(X - lPageRect.Right) <= 6 then
          fResizingBorder := 2;
      end;
      
      if (fResizingBorder = 0) and (X >= lPageRect.Left) and (X <= lPageRect.Right) then
      begin
        if Abs(Y - lPageRect.Top) <= 6 then
          fResizingBorder := 3
        else if Abs(Y - lPageRect.Bottom) <= 6 then
          fResizingBorder := 4;
      end;

      if fResizingBorder in [1, 2] then
        TControl(ASender).Cursor := crSizeWE
      else if fResizingBorder in [3, 4] then
        TControl(ASender).Cursor := crSizeNS
      else if ssShift in Shift then
      begin
        // Если курсор внутри выделенной страницы с зажатым Shift
        if not TChartPage(lRenderer.SelectedObject).Locked and
           (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          TControl(ASender).Cursor := crSizeAll
        else
          TControl(ASender).Cursor := crDefault;
      end
      else
        TControl(ASender).Cursor := crDefault;
    end
    else
    begin
      // Если выделенной страницы нет, но зажат Shift, меняем курсор над любой незаблокированной страницей
      lPage := nil;
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lTempPage := TChartPage(lModel.Children[lIndex]);
          if not lTempPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lTempPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lPage := lTempPage;
              Break;
            end;
          end;
        end;

      if Assigned(lPage) and (ssShift in Shift) then
        TControl(ASender).Cursor := crSizeAll
      else
        TControl(ASender).Cursor := crDefault;
    end;
  end;
end;

/// <summary>
/// Обработчик отпускания кнопки мыши. Завершает все активные интерактивные операции 
/// (перетаскивание, панорамирование, изменение размеров) и применяет выделенную область зумирования 
/// (Down-Right для приближения или Up-Left для сброса масштаба в авто).
/// </summary>
procedure TChartPanZoomListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lAxis: TChartAxis;
  NewXMin, NewXMax, NewYMin, NewYMax: Double;
  lSelRect: TChartPixelRect;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lRenderer.SelectionRectActive := False;
      fIsZoomSelecting := False;

      // 1. Полный масштаб при движении влево и вверх
      if (X < fZoomStartX) and (Y < fZoomStartY) then
      begin
        FitPageZoom(fActivePage);
        lControl.Redraw;
        Handled := True;
      end
      // 2. Приближение при движении вправо и вниз (размер рамки должен быть больше 2 пикселей во избежание случайных зумов при кликах)
      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then
      begin
        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        
        lSelRect.Left := Max(lContentRect.Left, fZoomStartX);
        lSelRect.Right := Min(lContentRect.Right, X);
        lSelRect.Top := Max(lContentRect.Top, fZoomStartY);
        lSelRect.Bottom := Min(lContentRect.Bottom, Y);

        if (lSelRect.Right > lSelRect.Left) and (lSelRect.Bottom > lSelRect.Top) then
        begin
          // Зум по X
          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
          NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
          fActivePage.XMinValue := NewXMin;
          fActivePage.XMaxValue := NewXMax;

          // Зум по осям Y
          for lIndex := 0 to fActivePage.ChildCount - 1 do
            if fActivePage.Children[lIndex] is TChartAxis then
            begin
              lAxis := TChartAxis(fActivePage.Children[lIndex]);
              
              if lAxis.UseOwnX then
              begin
                NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                lAxis.XMinValue := NewXMin;
                lAxis.XMaxValue := NewXMax;
              end;

              NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
              NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
              lAxis.MinValue := NewYMin;
              lAxis.MaxValue := NewYMax;
            end;

          lControl.Redraw;
          Handled := True;
        end;
      end
      else
      begin
        lControl.Redraw;
        Handled := True;
      end;
      
      fActivePage := nil;
      Exit;
    end;

    if Button = mbLeft then
    begin
      if fIsDraggingPoint then
      begin
        fIsDraggingPoint := False;
        fDragTrend := nil;
        fDragPointIdx := -1;
        fActivePage := nil;
        Handled := True;
      end;

      if fIsResizing or fMovingPage then
      begin
        fIsResizing := False;
        fMovingPage := False;
        fActivePage := nil;
        fResizingBorder := 0;
        TControl(ASender).Cursor := crDefault;
        Handled := True;
      end;

      if fIsDraggingLabel then
      begin
        fIsDraggingLabel := False;
        fDragLabel := nil;
        fDragLabelBorder := 0;
        fActivePage := nil;
        TControl(ASender).Cursor := crDefault;
        Handled := True;
      end;
    end;

    if Button = mbRight then
    begin
      if fIsPanning then
      begin
        fIsPanning := False;
        fActivePage := nil;
        Handled := True;
      end;
    end;
  end;
end;

/// <summary>
/// Обработчик вращения колесика мыши. Выполняет плавное масштабирование графика по осям X и Y
/// относительно текущего положения курсора мыши на активной странице.
/// </summary>
procedure TChartPanZoomListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lContentRect: TChartPixelRect;
  lZoomFactor: Double;
  lMouseValX: Double;
  lMouseValY: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    // Находим страницу под мышкой для масштабирования
    lPage := nil;
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[lIndex]));
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          Break;
        end;
      end;

    if Assigned(lPage) and not lPage.Locked then
    begin
      lContentRect := lRenderer.GetPageContentRect(lPage);
      if WheelDelta < 0 then
        lZoomFactor := 1.1
      else
        lZoomFactor := 1.0 / 1.1;

      // Масштабирование по оси X относительно курсора мыши
      lMouseValX := lRenderer.PixelToXValue(lPage, nil, X, lContentRect.Left, lContentRect.Right);
      lPage.XMinValue := lMouseValX - (lMouseValX - lPage.XMinValue) * lZoomFactor;
      lPage.XMaxValue := lMouseValX + (lPage.XMaxValue - lMouseValX) * lZoomFactor;

      // Масштабирование по осям Y относительно курсора мыши
      for lIndex := 0 to lPage.ChildCount - 1 do
        if lPage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(lPage.Children[lIndex]);
          lMouseValY := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);
          lAxis.MinValue := lMouseValY - (lMouseValY - lAxis.MinValue) * lZoomFactor;
          lAxis.MaxValue := lMouseValY + (lAxis.MaxValue - lMouseValY) * lZoomFactor;
        end;

      lControl.Redraw;
      Handled := True;
    end;
  end;
end;

end.
