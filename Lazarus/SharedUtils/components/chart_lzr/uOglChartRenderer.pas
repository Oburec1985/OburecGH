unit uOglChartRenderer;
{$mode objfpc}{$H+}
{$codepage UTF8}

{
  Модуль uOglChartRenderer
  Описание: Реализует рендеринг дерева моделей графика TOglChart средствами OpenGL.
            Отвечает за отрисовку подложки страниц, сеток, делений (линейных и логарифмических),
            линий графиков (включая шейдерный рендеринг и буферизованные тренды), текстовых
            подписей и осей. Поддерживает интерактивное редактирование числовых значений на месте.
}
interface
uses
  Classes, SysUtils, Math, gl, glext, uOglChartTypes, uOglChartBaseObj,
  uOglChartDrawObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, uOglChartFontMng, uOglChartLineHelper, uOglChartTextLabel, uOglChartCursor, LConvEncoding;

type
  // Тип редактируемой интерактивной текстовой метки на графике
  TChartEditLabelKind = (
    celNone,       // Метка не редактируется
    celAxisMin,    // Минимальное значение оси Y
    celAxisMax,    // Максимальное значение оси Y
    celXMin,       // Минимальное значение оси X
    celXMax        // Максимальное значение оси X
  );
  // Описание интерактивной текстовой области на экране для обработки кликов и редактирования
  TChartTextHit = record
    Rect: TChartPixelRect;          // Экранные границы метки в пикселях
    Axis: TChartAxis;               // Связанная ось (если есть)
    Page: TChartPage;               // Связанная страница (если есть)
    Kind: TChartEditLabelKind;      // Роль метки
    Text: string;                   // Текущий текст метки
    TextLeft: Integer;              // Координата X левой границы начала отрисовки текста
    Font: cOglFont;                 // Использованный шрифт
  end;

  // Описание деления (тика) на оси координат
  TChartTick = record
    Value: Double;                  // Физическое значение деления
    Text: string;                   // Отформатированный текст подписи деления
  end;

  TChartTickArray = array of TChartTick;
  { TOpenGLChartRenderer }
  // Класс OpenGL-рендера дерева модели графика.
  // Реализует интерфейсы IChartRenderer (для TOglChart) и IChartOffsetHelper (для проецирования координат).
  TOpenGLChartRenderer = class(TInterfacedObject, IChartRenderer, IChartOffsetHelper)
  private
    fHost: IOpenGLContextHost;        // Ссылка на хост OpenGL (окно вывода)
    fUseShader: Boolean;              // Флаг использования шейдеров для ускорения линий
    fProgram: GLuint;                 // Шейдерная программа для 2D-линий (с поддержкой логарифмических осей)
    fProgram1d: GLuint;               // Шейдерная программа для одномерных буферизованных данных
    fShaderInitialized: Boolean;      // Флаг успешной компиляции и сборки шейдеров
    fPageRect: TChartPixelRect;       // Текущий прямоугольник отрисовки страницы в пикселях
    fFontMng: cOglFontMng;            // Менеджер OpenGL-шрифтов для рендеринга текста осей и подписей
    fTextHits: array of TChartTextHit; // Массив интерактивных текстовых областей (для кликов и редактирования)
    fActiveHit: TChartTextHit;        // Активная в данный момент редактируемая текстовая область
    fEditText: string;                // Накапливаемый редактируемый текст
    fEditCursor: Integer;             // Положение курсора при редактировании
    fEditSelectionStart: Integer;     // Начало выделения текста при редактировании
    fEditSelectionLength: Integer;    // Длина выделения текста
    fSelectedObject: TChartBaseObject; // Выбранный объект модели (выделен в дереве)
    fHoveredObject: TChartBaseObject;  // Объект модели под курсором мыши
    fSelectionRectActive: Boolean;    // Активен ли прямоугольник выделения (рамка масштабирования)
    fSelectionRect: TChartPixelRect;  // Координаты рамки выделения в пикселях
    /// <summary> Компиляция и инициализация вершинных и фрагментных шейдеров. </summary>

    procedure InitShaders;
    /// <summary> Настройка ортогональной проекции OpenGL 2D под размер области вывода. </summary>

    procedure Apply2DView;
    /// <summary> Вспомогательный метод установки цвета рисования в OpenGL (ABGR -> RGBA). </summary>

    procedure SetGLColor(AColor: Cardinal);
    /// <summary> Вычисление внутренней рабочей области страницы (без полей осей). </summary>

    function PageContentRect(APage: TChartPage): TChartPixelRect;
    /// <summary> Вычисление полной экранной области страницы с учетом полей. </summary>

    function PageToPixelRect(APage: TChartPage): TChartPixelRect;
    /// <summary> Возвращает основную ось X для переданной страницы. </summary>

    function GetPrimaryXAxis(APage: TChartPage): TChartAxis;
    /// <summary> Расчет оптимального шага делений шкалы для красивого шага сетки. </summary>

    function NiceStep(ARange: Double; ATargetCount: Integer): Double;
    /// <summary> Генерация массива тиков (делений) для линейного масштаба оси. </summary>

    procedure BuildLinearTicks(AMin, AMax: Double; ATargetCount: Integer; out ATicks: TChartTickArray);
    /// <summary> Генерация массива тиков (делений) для логарифмического масштаба оси. </summary>

    procedure BuildLogTicks(AMin, AMax: Double; out ATicks: TChartTickArray);
    /// <summary> Автоматический выбор алгоритма и построение тиков для оси Y. </summary>

    procedure BuildAxisTicks(AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
    /// <summary> Автоматический выбор алгоритма и построение тиков для оси X. </summary>

    procedure BuildXTicks(APage: TChartPage; AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
    /// <summary> Форматирование числового значения тика в строку подписи оси. </summary>

    function FormatTick(AValue, AStep: Double): string;
    /// <summary> Общая формула проецирования физического значения в пиксель экрана. </summary>

    function ValueToPixel(AValue, AMin, AMax: Double; APixelMin, APixelMax: Single): Single;
    /// <summary> Низкоуровневая отрисовка линии через Immediate Mode OpenGL. </summary>

    procedure DrawLine(AX1, AY1, AX2, AY2: Single);
    /// <summary> Отрисовка контура прямоугольника. </summary>

    procedure DrawRect(const ARect: TChartPixelRect);
    /// <summary> Отрисовка закрашенного прямоугольника. </summary>

    procedure FillRect(const ARect: TChartPixelRect);
    /// <summary> Регистрация текстовой области для последующей обработки кликов мыши. </summary>

    procedure AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont; AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);
    /// <summary> Отрисовка строки текста с использованием текстурных шрифтов. </summary>

    procedure DrawText(const AText: string; AX, AY: Single; AFont: cOglFont);
    /// <summary> Отрисовка выделения внутри редактируемого текста. </summary>

    procedure DrawTextSelection(AX, AY: Single; AFont: cOglFont; AStartIndex, ALength: Integer);
    /// <summary> Отрисовка интерактивной текстовой метки с возможностью редактирования на месте. </summary>

    procedure DrawEditableText(const AText: string; AX, AY: Single; AFont: cOglFont; AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);
    /// <summary> Отрисовка линий сетки и логарифмических подсеток для переданной оси. </summary>

    procedure DrawGrid(const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    /// <summary> Отрисовка осей, шкал делений и их числовых подписей. </summary>

    procedure DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
    /// <summary> Отрисовка подложки и внешних рамок страницы. </summary>

    procedure DrawPageFrame(APage: TChartPage; const ARect: TChartPixelRect);
    /// <summary> Отрисовка линейного графика TChartLineSeries (через Immediate Mode или шейдеры). </summary>

    procedure DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    /// <summary> Отрисовка одномерного буферизованного тренда cBuffTrend1d (оптимизировано под шейдеры). </summary>

    procedure DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure DrawBuffTrendQueue(ATrend: cBuffTrendQueue; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    /// <summary> Отрисовка базового тренда cBaseTrend (определяет и перенаправляет вызовы). </summary>

    procedure DrawBaseTrend(ATrend: cBaseTrend; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    /// <summary> Отрисовка опорных точек сплайна Безье и усов манипуляции. </summary>

    procedure DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);

    procedure DrawTextLabel(ALabel: TChartTextLabel; APage: TChartPage; const ARect: TChartPixelRect);
    procedure DrawCursor(ACursor: TChartCursor; APage: TChartPage; const ARect: TChartPixelRect);
      procedure DrawFrequencyBand(ABand: TChartFrequencyBand; APage: TChartPage; const ARect: TChartPixelRect);
      procedure DrawBandShadedRects(APage: TChartPage; const ARect: TChartPixelRect);
    procedure CollectFlags(AObject: TChartBaseObject; AList: TList);
    procedure ResolveFlagOverlaps(APage: TChartPage);
    procedure DrawCursorLabel(ACursor: TChartCursor; AXPixel, AYPixel: Single; const AText: string; const AColors: TCardinalArray);
    /// <summary> Рекурсивный обход и отрисовка дочерних объектов модели. </summary>

    procedure RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure RenderLabels(AObject: TChartBaseObject; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    /// <summary> Подготовка контекста и отрисовка отдельной страницы APage. </summary>

    procedure RenderPage(APage: TChartPage);
    /// <summary> Отрисовка рамок подсветки при наведении и выделении элементов. </summary>

    procedure DrawHighlights;
    /// <summary> Вспомогательная отрисовка тонкого прямоугольника рамки выделения. </summary>

    procedure DrawHighlightRect(const ARect: TChartPixelRect; AColor: Cardinal);
  public
    function GetCursorLabelTextAndColors(ACursor: TChartCursor; ALabelIdx: Integer; APage: TChartPage; out AColors: TCardinalArray): string;
    function FindSelectedTrend(APage: TChartPage; ASelectedObj: TChartBaseObject): cBaseTrend;
    function GetTrendValueAtX(ATrend: cBaseTrend; AWorldX: Double; out AValueY: Double): Boolean;

    constructor Create;

    destructor Destroy; override;
    // --- Интерфейс IChartRenderer ---

    // --- Реализация IChartRenderer ---

    procedure Initialize(AHost: IOpenGLContextHost);

    procedure Resize(AWidth, AHeight: Integer);

    procedure Render(AModel: TObject);
    // --- Интерфейс IChartOffsetHelper ---

    // --- Реализация IChartOffsetHelper ---

    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;

    function XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
    // --- Методы обработки ввода ---

    // --- Методы ввода мыши ---

    function MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;

    function KeyDown(AKey: Word): Boolean;

    function TextInput(const AText: string): Boolean;
    // --- Информационные методы геометрии ---

    // --- Дополнительные методы рендерера ---

    function GetPageRect(APage: TChartPage): TChartPixelRect;

    function GetPageContentRect(APage: TChartPage): TChartPixelRect;

    function GetTextHitAt(AX, AY: Integer; out AHit: TChartTextHit): Boolean;

    function PixelToXValue(APage: TChartPage; AAxis: TChartAxis; APixelX, ALeft, ARight: Single): Double;

    function PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;

    function GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;
    // --- Свойства выделения ---
    // --- Свойства состояния ---
    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;
    property FontManager: cOglFontMng read fFontMng;
    property HoveredObject: TChartBaseObject read fHoveredObject write fHoveredObject;
    property SelectionRectActive: Boolean read fSelectionRectActive write fSelectionRectActive;
    property SelectionRect: TChartPixelRect read fSelectionRect write fSelectionRect;
    property UseShader: Boolean read fUseShader write fUseShader;
  end;

implementation

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

function TryStrToFloatUniversal(const AStr: string; out AValue: Double): Boolean;

var
  lFS: TFormatSettings;
begin
  if TryStrToFloat(AStr, AValue) then
    Exit(True);
  {$IFDEF FPC}
  lFS := DefaultFormatSettings;
  {$ELSE}
  GetLocaleFormatSettings(LOCALE_USER_DEFAULT, lFS);
  {$ENDIF}
  lFS.DecimalSeparator := '.';
  if TryStrToFloat(AStr, AValue, lFS) then
    Exit(True);
  lFS.DecimalSeparator := ',';
  if TryStrToFloat(AStr, AValue, lFS) then
    Exit(True);
  Result := False;
end;

const
  // Шейдер для рендеринга 2D-линий с поддержкой логарифмических шкал по X/Y
  SHADER_LINE_LG_VERT =
    'uniform vec4 a_minmax;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(max(x, 1e-10))/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range, test;'#10 +
    '  gl_Position = gl_Vertex;'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg[0] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[1]);'#10 +
    '    if (a_minmax[0] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[0]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[1] - a_minmax[0];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    float val_x = max(gl_Position[0], 1e-10);'#10 +
    '    rate = (Log10(val_x) - lgMin) * lgRange;'#10 +
    '    gl_Position[0] = range * rate + a_minmax[0];'#10 +
    '  }'#10 +
    '  if (a_Lg[1] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[3]);'#10 +
    '    if (a_minmax[2] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[2]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[3] - a_minmax[2];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    float val_y = max(gl_Position[1], 1e-10);'#10 +
    '    rate = (Log10(val_y) - lgMin) * lgRange;'#10 +
    '    gl_Position[1] = range * rate + a_minmax[2];'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * gl_Position;'#10 +
    '}';
  // Шейдер для рендеринга одномерных буферизованных данных
  SHADER_LINE_LG_1D_VERT =
    '#version 130'#10 +
    'uniform vec4 a_minmax;'#10 +
    'uniform vec2 a_LinePar;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(max(x, 1e-10))/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range, test;'#10 +
    '  gl_Position = gl_Vertex;'#10 +
    '  gl_Position[0] = a_LinePar[0] + a_LinePar[1] * gl_Vertex[1];'#10 +
    '  gl_Position[1] = gl_Vertex[0];'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg[0] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[1]);'#10 +
    '    if (a_minmax[0] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[0]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[1] - a_minmax[0];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    float val_x = max(gl_Position[0], 1e-10);'#10 +
    '    rate = (Log10(val_x) - lgMin) * lgRange;'#10 +
    '    gl_Position[0] = range * rate + a_minmax[0];'#10 +
    '  }'#10 +
    '  if (a_Lg[1] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[3]);'#10 +
    '    if (a_minmax[2] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[2]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[3] - a_minmax[2];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    float val_y = max(gl_Position[1], 1e-10);'#10 +
    '    rate = (Log10(val_y) - lgMin) * lgRange;'#10 +
    '    gl_Position[1] = range * rate + a_minmax[2];'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * gl_Position;'#10 +
    '}';

function CreateShader(AShaderType: GLenum; const ASource: string): GLuint;

var
  lShader: GLuint;
  lStatus: GLint;
  lLogLen: GLint;
  lLog: string;
  lSourcePtr: PAnsiChar;
  lSourceLen: GLint;
begin
  lShader := glCreateShader(AShaderType);
  lSourcePtr := PAnsiChar(ASource);
  lSourceLen := Length(ASource);
  glShaderSource(lShader, 1, @lSourcePtr, @lSourceLen);
  glCompileShader(lShader);
  glGetShaderiv(lShader, GL_COMPILE_STATUS, @lStatus);
  if lStatus = GL_FALSE then
  begin
    glGetShaderiv(lShader, GL_INFO_LOG_LENGTH, @lLogLen);
    SetLength(lLog, lLogLen);
    glGetShaderInfoLog(lShader, lLogLen, nil, PAnsiChar(lLog));
    LogToFile('Shader compile error: ' + lLog);
    glDeleteShader(lShader);
    Exit(0);
  end;

  Result := lShader;
end;

function CreateProgram(AVertexSource: string): GLuint;

var
  lVertexShader: GLuint;
  lProgram: GLuint;
  lStatus: GLint;
  lLogLen: GLint;
  lLog: string;
begin
  Result := 0;
  lVertexShader := CreateShader(GL_VERTEX_SHADER, AVertexSource);
  if lVertexShader = 0 then Exit;
  lProgram := glCreateProgram();
  glAttachShader(lProgram, lVertexShader);
  glLinkProgram(lProgram);
  glGetProgramiv(lProgram, GL_LINK_STATUS, @lStatus);
  if lStatus = GL_FALSE then
  begin
    glGetProgramiv(lProgram, GL_INFO_LOG_LENGTH, @lLogLen);
    SetLength(lLog, lLogLen);
    glGetProgramInfoLog(lProgram, lLogLen, nil, PAnsiChar(lLog));
    LogToFile('Program link error: ' + lLog);
    glDeleteProgram(lProgram);
    glDeleteShader(lVertexShader);
    Exit;
  end;

  glDeleteShader(lVertexShader);
  Result := lProgram;
end;

const
  VK_BACK = 8;
  VK_DELETE = 46;
  VK_LEFT = 37;
  VK_RIGHT = 39;
  VK_HOME = 36;
  VK_END = 35;
{ TOpenGLChartRenderer }

constructor TOpenGLChartRenderer.Create;
begin
  inherited Create;
  fFontMng := cOglFontMng.Create;
end;

procedure TOpenGLChartRenderer.InitShaders;
begin
  fShaderInitialized := False;
  if not Load_GL_version_2_0 then
  begin
    LogToFile('Failed to load OpenGL 2.0 extensions.');
    Exit;
  end;

  fProgram := CreateProgram(SHADER_LINE_LG_VERT);
  fProgram1d := CreateProgram(SHADER_LINE_LG_1D_VERT);
  if (fProgram <> 0) and (fProgram1d <> 0) then
  begin
    fShaderInitialized := True;
    LogToFile('Shaders initialized successfully.');
  end

  else
    LogToFile('Failed to initialize shaders.');
end;

destructor TOpenGLChartRenderer.Destroy;
begin
  if fShaderInitialized then
  begin
    glDeleteProgram(fProgram);
    glDeleteProgram(fProgram1d);
  end;

  fFontMng.Free;
  inherited Destroy;
end;

procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  Inc(gGLContextVersion);
  if not Assigned(fFontMng) then
    fFontMng := cOglFontMng.Create;
  fHost.MakeCurrent;
  if not fShaderInitialized then
    InitShaders;
  { Включаем шейдерный путь по умолчанию после успешной инициализации }
  if fShaderInitialized then
    fUseShader := True;
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;

procedure TOpenGLChartRenderer.Resize(AWidth, AHeight: Integer);
begin
  if AHeight = 0 then
    AHeight := 1;
  glViewport(0, 0, AWidth, AHeight);
end;

procedure TOpenGLChartRenderer.Apply2DView;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0, fHost.GetWidth, fHost.GetHeight, 0, -1, 1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
end;

procedure TOpenGLChartRenderer.SetGLColor(AColor: Cardinal);

var
  r, g, b, a: Byte;
begin
  r := Byte(AColor);
  g := Byte(AColor shr 8);
  b := Byte(AColor shr 16);
  a := Byte(AColor shr 24);
  glColor4ub(r, g, b, a);
end;

function TOpenGLChartRenderer.PageContentRect(APage: TChartPage): TChartPixelRect;

var
  lTotalOffset: Single;
  lYTicks: TChartTickArray;
  lAxisFont: cOglFont;
  lYAxis: TChartAxis;
  lText: string;
  lMaxTextWidth, lTextWidth: Single;
  I, J, lYAxisIdx: Integer;
begin
  lTotalOffset := 0;
  lYAxisIdx := 0;
  if Assigned(APage) then
  begin
    for I := 0 to APage.ChildCount - 1 do
      if APage.Children[I] is TChartAxis then
      begin
        lYAxis := TChartAxis(APage.Children[I]);
        if lYAxisIdx > 0 then
        begin
          BuildAxisTicks(lYAxis, 8, lYTicks);
          if lYAxis = fSelectedObject then
            lAxisFont := fFontMng.Font(cfAxisSelected)
          else
            lAxisFont := fFontMng.Font(cfAxisLabel);
          lMaxTextWidth := 0;
          for J := 0 to High(lYTicks) do
          begin
            lText := lYTicks[J].Text;
            lTextWidth := lAxisFont.TextPixelWidth(lText);
            if lTextWidth > lMaxTextWidth then
              lMaxTextWidth := lTextWidth;
          end;

          if lMaxTextWidth < 30.0 then
            lMaxTextWidth := 30.0;
          lTotalOffset := lTotalOffset + lMaxTextWidth + 15;
        end;

        Inc(lYAxisIdx);
      end;

  end;

  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left + Round(lTotalOffset);
  Result.Top := fPageRect.Top + APage.PixelTabSpace.Top;
  Result.Right := fPageRect.Right - APage.PixelTabSpace.Right;
  Result.Bottom := fPageRect.Bottom - APage.PixelTabSpace.Bottom;
  if Result.Right < Result.Left + 20 then
    Result.Right := Result.Left + 20;
  if Result.Bottom < Result.Top + 20 then
    Result.Bottom := Result.Top + 20;
end;

function TOpenGLChartRenderer.PageToPixelRect(APage: TChartPage): TChartPixelRect;
begin
  if not Assigned(fHost) or not Assigned(APage) then
  begin
    Result.Left := 0;
    Result.Top := 0;
    Result.Right := 0;
    Result.Bottom := 0;
    Exit;
  end;

  Result.Left := Round(APage.FloatRect.Left * fHost.GetWidth);
  Result.Top := Round(APage.FloatRect.Top * fHost.GetHeight);
  Result.Right := Round(APage.FloatRect.Right * fHost.GetWidth);
  Result.Bottom := Round(APage.FloatRect.Bottom * fHost.GetHeight);
  if Result.Right < Result.Left + 80 then
    Result.Right := Result.Left + 80;
  if Result.Bottom < Result.Top + 60 then
    Result.Bottom := Result.Top + 60;
end;

procedure TOpenGLChartRenderer.DrawLine(AX1, AY1, AX2, AY2: Single);
begin
  glBegin(GL_LINES);
  glVertex2f(AX1, AY1);
  glVertex2f(AX2, AY2);
  glEnd;
end;

procedure TOpenGLChartRenderer.DrawRect(const ARect: TChartPixelRect);
begin
  glBegin(GL_LINE_LOOP);
  glVertex2f(ARect.Left, ARect.Top);
  glVertex2f(ARect.Right, ARect.Top);
  glVertex2f(ARect.Right, ARect.Bottom);
  glVertex2f(ARect.Left, ARect.Bottom);
  glEnd;
end;

procedure TOpenGLChartRenderer.FillRect(const ARect: TChartPixelRect);
begin
  glBegin(GL_QUADS);
  glVertex2f(ARect.Left, ARect.Top);
  glVertex2f(ARect.Right, ARect.Top);
  glVertex2f(ARect.Right, ARect.Bottom);
  glVertex2f(ARect.Left, ARect.Bottom);
  glEnd;
end;

function TOpenGLChartRenderer.GetPrimaryXAxis(APage: TChartPage): TChartAxis;

var
  I: Integer;
begin
  Result := nil;
  if not Assigned(APage) then
    Exit;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      Result := TChartAxis(APage.Children[I]);
      Exit;
    end;

end;

function TOpenGLChartRenderer.NiceStep(ARange: Double; ATargetCount: Integer): Double;

var
  lRawStep: Double;
  lPower: Double;
  lFraction: Double;
begin
  if (ARange <= 0) or (ATargetCount <= 0) then
    Exit(1);
  lRawStep := ARange / ATargetCount;
  lPower := Power(10, Floor(Log10(lRawStep)));
  lFraction := lRawStep / lPower;
  if lFraction <= 1 then
    Result := 1 * lPower
  else if lFraction <= 2 then
    Result := 2 * lPower
  else if lFraction <= 5 then
    Result := 5 * lPower
  else
    Result := 10 * lPower;
end;

function TOpenGLChartRenderer.FormatTick(AValue, AStep: Double): string;

var
  lDigits: Integer;
begin
  if AStep >= 1 then
    Result := FormatFloat('0', AValue)
  else
  begin
    lDigits := Min(6, Max(0, Ceil(-Log10(AStep))));
    if lDigits = 0 then
      Result := FormatFloat('0', AValue)
    else
      Result := FormatFloat('0.' + StringOfChar('0', lDigits), AValue);
  end;

end;

procedure TOpenGLChartRenderer.BuildLinearTicks(AMin, AMax: Double; ATargetCount: Integer; out ATicks: TChartTickArray);

var
  lStep: Double;
  lValue: Double;
  lIndex: Integer;
  lOriginalMin: Double;
  lOriginalMax: Double;
begin
  ATicks := nil;
  if AMax = AMin then
    AMax := AMin + 1;
  if AMax < AMin then
  begin
    lValue := AMin;
    AMin := AMax;
    AMax := lValue;
  end;

  lOriginalMin := AMin;
  lOriginalMax := AMax;
  lStep := NiceStep(AMax - AMin, ATargetCount);
  if lStep <= 0 then
    lStep := 1;
  lValue := Ceil(AMin / lStep) * lStep;
  lIndex := 0;
  SetLength(ATicks, 1);
  ATicks[0].Value := lOriginalMin;
  ATicks[0].Text := FormatTick(lOriginalMin, lStep);
  lIndex := 1;
  while lValue < lOriginalMax - lStep * 1E-6 do
  begin
    if lValue > lOriginalMin + lStep * 1E-6 then
    begin
      SetLength(ATicks, lIndex + 1);
      ATicks[lIndex].Value := lValue;
      ATicks[lIndex].Text := FormatTick(lValue, lStep);
      Inc(lIndex);
    end;

    lValue := lValue + lStep;
  end;

  if Abs(lOriginalMax - lOriginalMin) > lStep * 1E-6 then
  begin
    SetLength(ATicks, lIndex + 1);
    ATicks[lIndex].Value := lOriginalMax;
    ATicks[lIndex].Text := FormatTick(lOriginalMax, lStep);
  end;

end;

procedure TOpenGLChartRenderer.BuildLogTicks(AMin, AMax: Double; out ATicks: TChartTickArray);

var
  lPow: Integer;
  lMinPow, lMaxPow: Integer;
  lValue: Double;
  lIndex: Integer;
  lMinVal: Double;
  lOriginalMin, lOriginalMax: Double;
begin
  ATicks := nil;
  lOriginalMin := AMin;
  lOriginalMax := AMax;
  lMinVal := AMin;
  if lMinVal <= 0 then
    lMinVal := 1e-10;
  if AMax <= lMinVal then
    AMax := lMinVal * 10;
  // Добавляем минимальное значение в качестве первого тика
  SetLength(ATicks, 1);
  ATicks[0].Value := lOriginalMin;
  if lOriginalMin >= 1e-5 then
    ATicks[0].Text := FormatFloat('0.#######', lOriginalMin)
  else
    ATicks[0].Text := FormatFloat('0.E+0', lOriginalMin);
  lIndex := 1;
  lMinPow := Floor(Log10(lMinVal));
  lMaxPow := Ceil(Log10(AMax));
  for lPow := lMinPow to lMaxPow do
  begin
    lValue := Power(10, lPow);
    // Добавляем промежуточные степени десятки, если они лежат строго между границами
    if (lValue > lMinVal * (1.0 + 1e-9)) and (lValue < AMax * (1.0 - 1e-9)) then
    begin
      SetLength(ATicks, lIndex + 1);
      ATicks[lIndex].Value := lValue;
      if (lOriginalMin <= 0) and (lValue <= 1.01e-10) then
        ATicks[lIndex].Text := '0'
      else if (lValue >= 1) and (lValue < 1e6) then
        ATicks[lIndex].Text := FormatFloat('0', lValue)
      else if (lValue < 1) and (lValue >= 1e-5) then
        ATicks[lIndex].Text := FormatFloat('0.#######', lValue)
      else
        ATicks[lIndex].Text := FormatFloat('0.E+0', lValue);
      Inc(lIndex);
    end;

  end;

  // Добавляем максимальное значение в качестве последнего тика
  if AMax > lMinVal * (1.0 + 1e-9) then
  begin
    SetLength(ATicks, lIndex + 1);
    ATicks[lIndex].Value := lOriginalMax;
    if lOriginalMax >= 1e-5 then
      ATicks[lIndex].Text := FormatFloat('0.#######', lOriginalMax)
    else
      ATicks[lIndex].Text := FormatFloat('0.E+0', lOriginalMax);
  end;

end;

procedure TOpenGLChartRenderer.BuildAxisTicks(AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
    BuildLogTicks(AAxis.MinValue, AAxis.MaxValue, ATicks)
  else if Assigned(AAxis) then
    BuildLinearTicks(AAxis.MinValue, AAxis.MaxValue, ATargetCount, ATicks)
  else
    ATicks := nil;
end;

procedure TOpenGLChartRenderer.BuildXTicks(APage: TChartPage; AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);

var
  lMin, lMax: Double;
  lScale: TChartAxisScale;
begin
  lMin := 0;
  lMax := 1;
  lScale := casLinear;
  if Assigned(AAxis) and AAxis.UseOwnX then
  begin
    lMin := AAxis.XMinValue;
    lMax := AAxis.XMaxValue;
    lScale := AAxis.XScale;
  end

  else if Assigned(APage) then
  begin
    lMin := APage.XMinValue;
    lMax := APage.XMaxValue;
    lScale := APage.XScale;
  end;

  if lScale = casLog10 then
    BuildLogTicks(lMin, lMax, ATicks)
  else
    BuildLinearTicks(lMin, lMax, ATargetCount, ATicks);
end;

function TOpenGLChartRenderer.ValueToPixel(AValue, AMin, AMax: Double; APixelMin, APixelMax: Single): Single;
begin
  if AMax = AMin then
    Exit((APixelMin + APixelMax) / 2);
  Result := APixelMin + (APixelMax - APixelMin) * ((AValue - AMin) / (AMax - AMin));
end;

function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;

var
  lMin: Double;
  lMax: Double;
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
  begin
    lMin := Max(AAxis.MinValue, 1e-10);
    lMax := AAxis.MaxValue;
    if lMax <= lMin then
      lMax := lMin * 10;
    Result := ValueToPixel(Log10(Max(AValue, 1e-10)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end

  else if Assigned(AAxis) then
    Result := ValueToPixel(AValue, AAxis.MinValue, AAxis.MaxValue, APixelMin, APixelMax)
  else
    Result := (APixelMin + APixelMax) / 2;
end;

function TOpenGLChartRenderer.XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;

var
  lMin, lMax: Double;
  lScale: TChartAxisScale;
begin
  lMin := 0;
  lMax := 1;
  lScale := casLinear;
  if Assigned(AAxis) and AAxis.UseOwnX then
  begin
    lMin := AAxis.XMinValue;
    lMax := AAxis.XMaxValue;
    lScale := AAxis.XScale;
  end

  else if Assigned(APage) then
  begin
    lMin := APage.XMinValue;
    lMax := APage.XMaxValue;
    lScale := APage.XScale;
  end;

  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1e-10);
    if lMax <= lMin then
      lMax := lMin * 10;
    Result := ValueToPixel(Log10(Max(AValue, 1e-10)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end

  else
    Result := ValueToPixel(AValue, lMin, lMax, APixelMin, APixelMax);
end;

function TOpenGLChartRenderer.FindSelectedTrend(APage: TChartPage; ASelectedObj: TChartBaseObject): cBaseTrend;
var
  lAxis: TChartAxis;
  I, J: Integer;
begin
  Result := nil;
  if not Assigned(APage) then Exit;

  if Assigned(ASelectedObj) then
  begin
    if ASelectedObj is cBaseTrend then
      Exit(cBaseTrend(ASelectedObj))
    else if ASelectedObj is TChartAxis then
    begin
      lAxis := TChartAxis(ASelectedObj);
      for I := 0 to lAxis.ChildCount - 1 do
        if lAxis.Children[I] is cBaseTrend then
          Exit(cBaseTrend(lAxis.Children[I]));
    end;
  end;

  for I := 0 to APage.ChildCount - 1 do
  begin
    if APage.Children[I] is TChartAxis then
    begin
      lAxis := TChartAxis(APage.Children[I]);
      for J := 0 to lAxis.ChildCount - 1 do
        if lAxis.Children[J] is cBaseTrend then
        begin
          if cBaseTrend(lAxis.Children[J]).Visible then
            Exit(cBaseTrend(lAxis.Children[J]));
        end;
    end;
  end;
end;

function TOpenGLChartRenderer.GetTrendValueAtX(ATrend: cBaseTrend; AWorldX: Double; out AValueY: Double): Boolean;
var
  lLine: cLineSeries;
  lBuff: cBuffTrend1d;
  lQueue: cBuffTrendQueue;
  lPoint1, lPoint2: TChartPoint;
  I: Integer;
  lIdx: Integer;
  lX1, lX2, lY1, lY2: Double;
  lRatio: Double;
begin
  Result := False;
  AValueY := 0;
  if not Assigned(ATrend) or not ATrend.Visible then Exit;

  if ATrend is cLineSeries then
  begin
    lLine := cLineSeries(ATrend);
    if lLine.PointCount = 0 then Exit;
    if lLine.PointCount = 1 then
    begin
      AValueY := lLine.Points[0].Y;
      Exit(True);
    end;

    if AWorldX <= lLine.Points[0].X then
    begin
      AValueY := lLine.Points[0].Y;
      Exit(True);
    end;
    if AWorldX >= lLine.Points[lLine.PointCount - 1].X then
    begin
      AValueY := lLine.Points[lLine.PointCount - 1].Y;
      Exit(True);
    end;

    for I := 0 to lLine.PointCount - 2 do
    begin
      if (AWorldX >= lLine.Points[I].X) and (AWorldX <= lLine.Points[I+1].X) then
      begin
        lX1 := lLine.Points[I].X;
        lX2 := lLine.Points[I+1].X;
        lY1 := lLine.Points[I].Y;
        lY2 := lLine.Points[I+1].Y;
        if lX2 <> lX1 then
          lRatio := (AWorldX - lX1) / (lX2 - lX1)
        else
          lRatio := 0;
        AValueY := lY1 + lRatio * (lY2 - lY1);
        Exit(True);
      end;
    end;
  end
  else if ATrend is cBuffTrendQueue then
  begin
    lQueue := cBuffTrendQueue(ATrend);
    if lQueue.Count = 0 then Exit;
    if lQueue.Count = 1 then
    begin
      AValueY := lQueue.Points[0].Y;
      Exit(True);
    end;

    if AWorldX <= lQueue.Points[0].X then
    begin
      AValueY := lQueue.Points[0].Y;
      Exit(True);
    end;
    if AWorldX >= lQueue.Points[lQueue.Count - 1].X then
    begin
      AValueY := lQueue.Points[lQueue.Count - 1].Y;
      Exit(True);
    end;

    for I := 0 to lQueue.Count - 2 do
    begin
      lPoint1 := lQueue.Points[I];
      lPoint2 := lQueue.Points[I + 1];
      if (AWorldX >= lPoint1.X) and (AWorldX <= lPoint2.X) then
      begin
        if lPoint2.X <> lPoint1.X then
          lRatio := (AWorldX - lPoint1.X) / (lPoint2.X - lPoint1.X)
        else
          lRatio := 0;
        AValueY := lPoint1.Y + lRatio * (lPoint2.Y - lPoint1.Y);
        Exit(True);
      end;
    end;
  end  else if ATrend is cBuffTrend1d then
  begin
    lBuff := cBuffTrend1d(ATrend);
    if lBuff.Count = 0 then Exit;
    if lBuff.Count = 1 then
    begin
      AValueY := lBuff.Values[0];
      Exit(True);
    end;
    if lBuff.DX = 0 then Exit;

    lRatio := (AWorldX - lBuff.X0) / lBuff.DX;
    if lRatio <= 0 then
    begin
      AValueY := lBuff.Values[0];
      Exit(True);
    end;
    if lRatio >= lBuff.Count - 1 then
    begin
      AValueY := lBuff.Values[lBuff.Count - 1];
      Exit(True);
    end;

    lIdx := Trunc(lRatio);
    lY1 := lBuff.Values[lIdx];
    lY2 := lBuff.Values[lIdx + 1];
    lRatio := lRatio - lIdx;
    AValueY := lY1 + lRatio * (lY2 - lY1);
    Exit(True);
  end;
end;

function TOpenGLChartRenderer.GetCursorLabelTextAndColors(ACursor: TChartCursor; ALabelIdx: Integer; APage: TChartPage; out AColors: TCardinalArray): string;
var
  lValX: Double;
  lText: string;
  lTrend, lTr: cBaseTrend;
  lAxis: TChartAxis;
  I, J: Integer;
  lValY: Double;
  lCount: Integer;
begin
  if ALabelIdx = 1 then
    lValX := ACursor.X1
  else
    lValX := ACursor.X2;

  lText := Format('X%d: %0.5g', [ALabelIdx, lValX]);
  SetLength(AColors, 1);
  AColors[0] := $FF101010;

  if ACursor.MultiLineMode <> mlDisabled then
  begin
    lCount := 1;
    for I := 0 to APage.ChildCount - 1 do
    begin
      if APage.Children[I] is TChartAxis then
      begin
        lAxis := TChartAxis(APage.Children[I]);
        for J := 0 to lAxis.ChildCount - 1 do
        begin
          if lAxis.Children[J] is cBaseTrend then
          begin
            lTr := cBaseTrend(lAxis.Children[J]);
            if lTr.Visible then
            begin
              lValY := 0.0;
              if GetTrendValueAtX(lTr, lValX, lValY) then
              begin
                if ACursor.MultiLineMode = mlShowNames then
                  lText := lText + #13 + Format('%s: %0.5g', [lTr.Caption, lValY])
                else
                  lText := lText + #13 + Format('%0.5g', [lValY]);
                Inc(lCount);
                SetLength(AColors, lCount);
                AColors[lCount - 1] := lTr.Color;
              end;
            end;
          end;
        end;
      end;
    end;
  end
  else
  begin
    lTrend := FindSelectedTrend(APage, fSelectedObject);
    if Assigned(lTrend) then
    begin
      lValY := 0.0;
      GetTrendValueAtX(lTrend, lValX, lValY);
      lText := lText + #13 + Format('Y%d: %0.5g', [ALabelIdx, lValY]);
      SetLength(AColors, 2);
      AColors[1] := lTrend.Color;
    end;
  end;

  Result := lText;
end;

procedure TOpenGLChartRenderer.DrawCursorLabel(ACursor: TChartCursor; AXPixel, AYPixel: Single; const AText: string; const AColors: TCardinalArray);
var
  lFont: cOglFont;
  lTextWidth, lTextHeight: Single;
  lRect: TChartPixelRect;
  lLines: TStringList;
  I: Integer;
  lOldColor: Cardinal;
begin
  lFont := fFontMng.Font(cfGridTick);
  lLines := TStringList.Create;
  try
    lLines.Text := AText;
    lTextWidth := 0;
    for I := 0 to lLines.Count - 1 do
      lTextWidth := Max(lTextWidth, lFont.TextPixelWidth(lLines[I]));
    lTextHeight := lLines.Count * lFont.TextPixelHeight + (lLines.Count - 1) * 2;

    lRect.Left := Round(AXPixel + 2);
    lRect.Right := Round(AXPixel + 2 + lTextWidth + 12);
    lRect.Top := Round(AYPixel - lTextHeight / 2 - 4);
    lRect.Bottom := Round(AYPixel + lTextHeight / 2 + 4);

    SetGLColor($D8F5F5FA); // Светлая подложка флага (85% непрозрачности)
    FillRect(lRect);

    SetGLColor(ACursor.Color);
    glLineWidth(1);
    DrawRect(lRect);

    lOldColor := lFont.Color;
    try
      for I := 0 to lLines.Count - 1 do
      begin
        if I < Length(AColors) then
          lFont.Color := AColors[I]
        else
          lFont.Color := $FF101010;
        DrawText(lLines[I], lRect.Left + 6, lRect.Top + 4 + I * (lFont.TextPixelHeight + 2), lFont);
      end;
    finally
      lFont.Color := lOldColor;
    end;
  finally
    lLines.Free;
  end;
end;

procedure TOpenGLChartRenderer.DrawCursor(ACursor: TChartCursor; APage: TChartPage; const ARect: TChartPixelRect);
var
  lPixelX1, lPixelX2: Single;
  lYAxis: TChartAxis;
  lLabelY1, lLabelY2: Single;
  lText1, lText2: string;
  lColors1, lColors2: TCardinalArray;
begin
  if not Assigned(ACursor) or not ACursor.Visible then Exit;

  lYAxis := GetPrimaryXAxis(APage);
  lPixelX1 := XValueToPixel(APage, lYAxis, ACursor.X1, ARect.Left, ARect.Right);
  lPixelX2 := XValueToPixel(APage, lYAxis, ACursor.X2, ARect.Left, ARect.Right);

  if (lPixelX1 >= ARect.Left) and (lPixelX1 <= ARect.Right) then
  begin
    SetGLColor(ACursor.Color);
    glLineWidth(2.0);
    glLineStipple(2, $0F0F);
    glEnable(GL_LINE_STIPPLE);
    DrawLine(lPixelX1, ARect.Bottom, lPixelX1, ARect.Top);
    glDisable(GL_LINE_STIPPLE);

    if ACursor.ShowLabel then
    begin
      lText1 := GetCursorLabelTextAndColors(ACursor, 1, APage, lColors1);
      lLabelY1 := ARect.Bottom + ACursor.LabelY1Offset * (ARect.Top - ARect.Bottom);
      DrawCursorLabel(ACursor, lPixelX1, lLabelY1, lText1, lColors1);
    end;
  end;

  if ACursor.CursorType = cctDouble then
  begin
    if (lPixelX2 >= ARect.Left) and (lPixelX2 <= ARect.Right) then
    begin
      SetGLColor(ACursor.Color);
      glLineWidth(1.5);
      glLineStipple(2, $3333);
      glEnable(GL_LINE_STIPPLE);
      DrawLine(lPixelX2, ARect.Bottom, lPixelX2, ARect.Top);
      glDisable(GL_LINE_STIPPLE);

      if ACursor.ShowLabel then
      begin
        lText2 := GetCursorLabelTextAndColors(ACursor, 2, APage, lColors2);
        lLabelY2 := ARect.Bottom + ACursor.LabelY2Offset * (ARect.Top - ARect.Bottom);
        DrawCursorLabel(ACursor, lPixelX2, lLabelY2, lText2, lColors2);
      end;
    end;
  end;
end;

function FindTrendPeak(ATrend: cBuffTrend1d; AX1, AX2: Double; out APeakX, APeakY: Double): Boolean;
var
  I, lStartIdx, lEndIdx: Integer;
  lMaxVal: Double;
  lMaxIdx: Integer;
  lVal: Double;
begin
  Result := False;
  if (ATrend = nil) or (ATrend.Count = 0) or (ATrend.DX = 0.0) then Exit;

  lStartIdx := Round((AX1 - ATrend.X0) / ATrend.DX);
  lEndIdx := Round((AX2 - ATrend.X0) / ATrend.DX);

  if lStartIdx < 0 then lStartIdx := 0;
  if lEndIdx >= ATrend.Count then lEndIdx := ATrend.Count - 1;
  if lStartIdx > lEndIdx then Exit;

  lMaxVal := ATrend.Values[lStartIdx];
  lMaxIdx := lStartIdx;

  for I := lStartIdx + 1 to lEndIdx do
  begin
    lVal := ATrend.Values[I];
    if lVal > lMaxVal then
    begin
      lMaxVal := lVal;
      lMaxIdx := I;
    end;
  end;

  APeakX := ATrend.X0 + lMaxIdx * ATrend.DX;
  APeakY := lMaxVal;
  Result := True;
end;

procedure TOpenGLChartRenderer.DrawBandShadedRects(APage: TChartPage; const ARect: TChartPixelRect);
var
  I: Integer;
  lBand: TChartFrequencyBand;
  lYAxis: TChartAxis;
  lPixelX1, lPixelX2: Single;
  lRect: TChartPixelRect;
begin
  if not Assigned(APage) then Exit;
  lYAxis := GetPrimaryXAxis(APage);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  for I := 0 to APage.ChildCount - 1 do
  begin
    if APage.Children[I] is TChartFrequencyBand then
    begin
      lBand := TChartFrequencyBand(APage.Children[I]);
      if lBand.Visible then
      begin
        lPixelX1 := XValueToPixel(APage, lYAxis, lBand.X1, ARect.Left, ARect.Right);
        lPixelX2 := XValueToPixel(APage, lYAxis, lBand.X2, ARect.Left, ARect.Right);

        lRect.Left := Round(Min(lPixelX1, lPixelX2));
        lRect.Right := Round(Max(lPixelX1, lPixelX2));
        lRect.Top := ARect.Top;
        lRect.Bottom := ARect.Bottom;

        if lRect.Left < ARect.Left then lRect.Left := ARect.Left;
        if lRect.Right > ARect.Right then lRect.Right := ARect.Right;

        if lRect.Left < lRect.Right then
        begin
          SetGLColor(lBand.Color);
          FillRect(lRect);
        end;
      end;
    end;
  end;
end;

procedure TOpenGLChartRenderer.DrawFrequencyBand(ABand: TChartFrequencyBand; APage: TChartPage; const ARect: TChartPixelRect);
var
  lYAxis: TChartAxis;
  lPixelX1, lPixelX2: Single;
  lRect: TChartPixelRect;
  lFont: cOglFont;
  lTextWidth, lTextHeight: Single;
  lCenterX: Single;
  I, J, K: Integer;
  lAxis: TChartAxis;
  lTrend: cBaseTrend;
  lPeakX, lPeakY: Double;
  lPixelPeakX, lPixelY, lConnX: Single;
  lMarkerRect: TChartPixelRect;
  lTextRect: TChartPixelRect;
  lLabelText: string;
  lLabelLines: TStringList;
  lHasPeak: Boolean;
  lOffsetCount: Integer;
begin
  if not Assigned(ABand) or not ABand.Visible then Exit;

  lYAxis := GetPrimaryXAxis(APage);
  lPixelX1 := XValueToPixel(APage, lYAxis, ABand.X1, ARect.Left, ARect.Right);
  lPixelX2 := XValueToPixel(APage, lYAxis, ABand.X2, ARect.Left, ARect.Right);

  lRect.Left := Round(Min(lPixelX1, lPixelX2));
  lRect.Right := Round(Max(lPixelX1, lPixelX2));
  lRect.Top := ARect.Top;
  lRect.Bottom := ARect.Bottom;

  if lRect.Left < ARect.Left then lRect.Left := ARect.Left;
  if lRect.Right > ARect.Right then lRect.Right := ARect.Right;

  if lRect.Left < lRect.Right then
  begin
    // 1. Shaded rectangle is drawn in DrawBandShadedRects pass.

    // 2. Draw green name label (Caption) at the bottom
    if ABand.Caption <> '' then
    begin
      lFont := fFontMng.Font(cfGridTick);
      lLabelLines := TStringList.Create;
      try
        lLabelLines.Text := ABand.Caption;
        lTextWidth := 0;
        for I := 0 to lLabelLines.Count - 1 do
          lTextWidth := Max(lTextWidth, lFont.TextPixelWidth(lLabelLines[I]));
        lTextHeight := lLabelLines.Count * lFont.TextPixelHeight + (lLabelLines.Count - 1) * 2;

        lCenterX := (lPixelX1 + lPixelX2) / 2;

        lTextRect.Left := Round(lCenterX - lTextWidth / 2 - 4);
        lTextRect.Right := Round(lCenterX + lTextWidth / 2 + 4);
        lTextRect.Bottom := ARect.Bottom - 4;
        lTextRect.Top := Round(lTextRect.Bottom - lTextHeight - 6);

        if lTextRect.Left < ARect.Left then
        begin
          lTextRect.Right := lTextRect.Right + (ARect.Left - lTextRect.Left);
          lTextRect.Left := ARect.Left;
        end;
        if lTextRect.Right > ARect.Right then
        begin
          lTextRect.Left := lTextRect.Left - (lTextRect.Right - ARect.Right);
          lTextRect.Right := ARect.Right;
        end;

        if lTextRect.Left < lTextRect.Right then
        begin
          SetGLColor($FF00C000); // Green
          FillRect(lTextRect);

          SetGLColor($FF000000);
          glLineWidth(1);
          DrawRect(lTextRect);

          lFont.Color := $FF000000;
          for I := 0 to lLabelLines.Count - 1 do
            DrawText(lLabelLines[I], lTextRect.Left + 4, lTextRect.Top + 3 + I * (lFont.TextPixelHeight + 2), lFont);
        end;
      finally
        lLabelLines.Free;
      end;
    end;

    // 3. Draw peak markers/labels for each visible trend! (NO vertical red line)
    lOffsetCount := 0;
    for I := 0 to APage.ChildCount - 1 do
    begin
      if APage.Children[I] is TChartAxis then
      begin
        lAxis := TChartAxis(APage.Children[I]);
        for J := 0 to lAxis.ChildCount - 1 do
        begin
          if lAxis.Children[J] is cBuffTrend1d then
          begin
            lTrend := cBaseTrend(lAxis.Children[J]);
            if lTrend.Visible then
            begin
              lHasPeak := FindTrendPeak(cBuffTrend1d(lTrend), ABand.X1, ABand.X2, lPeakX, lPeakY);
              if lHasPeak then
              begin
                lPixelPeakX := XValueToPixel(APage, nil, lPeakX, ARect.Left, ARect.Right);
                lPixelY := AxisValueToPixel(lAxis, lPeakY, ARect.Bottom, ARect.Top);

                // Black dot
                if (lPixelPeakX >= ARect.Left) and (lPixelPeakX <= ARect.Right) and
                   (lPixelY >= ARect.Top) and (lPixelY <= ARect.Bottom) then
                begin
                  SetGLColor($FF000000); // Black
                  lMarkerRect.Left := Round(lPixelPeakX - 3);
                  lMarkerRect.Right := Round(lPixelPeakX + 3);
                  lMarkerRect.Top := Round(lPixelY - 3);
                  lMarkerRect.Bottom := Round(lPixelY + 3);
                  FillRect(lMarkerRect);

                  // Label stacked from the top of the chart downwards
                  if lPeakX >= 1000.0 then
                    lLabelText := Format('F:%.3e V:%.3g', [lPeakX, lPeakY])
                  else
                    lLabelText := Format('F:%.1f V:%.3g', [lPeakX, lPeakY]);

                  lLabelText := CP1251ToUTF8(lLabelText);

                  lFont := fFontMng.Font(cfGridTick);
                  lTextWidth := lFont.TextPixelWidth(lLabelText);
                  lTextHeight := lFont.TextPixelHeight;

                  // Shift horizontally to avoid covering the peak dot
                  if lPixelPeakX + 10 + lTextWidth + 8 <= ARect.Right then
                  begin
                    lTextRect.Left := Round(lPixelPeakX + 10);
                    lTextRect.Right := Round(lTextRect.Left + lTextWidth + 8);
                  end
                  else
                  begin
                    lTextRect.Right := Round(lPixelPeakX - 10);
                    lTextRect.Left := Round(lTextRect.Right - lTextWidth - 8);
                  end;

                  // Stack vertically from the top downwards
                  lTextRect.Top := Round(ARect.Top + 4 + lOffsetCount * (lTextHeight + 8));
                  lTextRect.Bottom := Round(lTextRect.Top + lTextHeight + 6);

                  if lTextRect.Left < ARect.Left then
                  begin
                    lTextRect.Right := lTextRect.Right + (ARect.Left - lTextRect.Left);
                    lTextRect.Left := ARect.Left;
                  end;
                  if lTextRect.Right > ARect.Right then
                  begin
                    lTextRect.Left := lTextRect.Left - (lTextRect.Right - ARect.Right);
                    lTextRect.Right := ARect.Right;
                  end;

                  if lTextRect.Left < lTextRect.Right then
                  begin
                    // Draw a thin line from the nearest edge of the label box to the peak dot
                    lConnX := lTextRect.Left;
                    if lPixelPeakX > lTextRect.Right then
                      lConnX := lTextRect.Right;

                    SetGLColor($FF808080); // Gray line
                    glLineWidth(1.0);
                    glBegin(GL_LINES);
                    glVertex2f(lConnX, (lTextRect.Top + lTextRect.Bottom) / 2);
                    glVertex2f(lPixelPeakX, lPixelY);
                    glEnd;

                    SetGLColor($FFFFFFFF);
                    FillRect(lTextRect);

                    SetGLColor(lTrend.Color);
                    glLineWidth(1);
                    DrawRect(lTextRect);

                    lFont.Color := lTrend.Color;
                    DrawText(lLabelText, lTextRect.Left + 4, lTextRect.Top + 3, lFont);
                  end;
                  Inc(lOffsetCount);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TOpenGLChartRenderer.AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont;
  AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);

var
  lIndex: Integer;
begin
  if not Assigned(AFont) or (AKind = celNone) then
    Exit;
  lIndex := Length(fTextHits);
  SetLength(fTextHits, lIndex + 1);
  fTextHits[lIndex].Rect.Left := Floor(AX);
  fTextHits[lIndex].Rect.Top := Floor(AY);
  fTextHits[lIndex].Rect.Right := Ceil(AX + AFont.TextPixelWidth(AText));
  fTextHits[lIndex].Rect.Bottom := Ceil(AY + AFont.TextPixelHeight);
  fTextHits[lIndex].Axis := AAxis;
  fTextHits[lIndex].Page := APage;
  fTextHits[lIndex].Kind := AKind;
  fTextHits[lIndex].Text := AText;
  fTextHits[lIndex].TextLeft := Floor(AX);
  fTextHits[lIndex].Font := AFont;
end;

procedure TOpenGLChartRenderer.DrawTextSelection(AX, AY: Single; AFont: cOglFont; AStartIndex, ALength: Integer);

var
  lRect: TChartPixelRect;
begin
  if not Assigned(AFont) or (ALength <= 0) then
    Exit;
  lRect.Left := Round(AX + AFont.TextPixelWidth(Copy(fEditText, 1, AStartIndex - 1)));
  lRect.Top := Round(AY - 1);
  lRect.Right := Round(lRect.Left + AFont.TextPixelWidth(Copy(fEditText, AStartIndex, ALength)));
  lRect.Bottom := Round(AY + AFont.TextPixelHeight + 1);
  SetGLColor($553C7DFF);
  FillRect(lRect);
end;

procedure TOpenGLChartRenderer.DrawText(const AText: string; AX, AY: Single; AFont: cOglFont);
begin
  if not Assigned(AFont) then
    Exit;
  AFont.DrawText(AText, AX, AY);
end;

procedure TOpenGLChartRenderer.DrawEditableText(const AText: string; AX, AY: Single; AFont: cOglFont;
  AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);

var
  lCursorX: Single;
begin
  AddTextHit(AText, AX, AY, AFont, AAxis, APage, AKind);
  if (Assigned(fActiveHit.Axis) and (fActiveHit.Axis = AAxis) and (fActiveHit.Kind = AKind)) or
     (Assigned(fActiveHit.Page) and (fActiveHit.Page = APage) and (fActiveHit.Kind = AKind)) then
  begin
    DrawTextSelection(AX, AY, AFont, fEditSelectionStart, fEditSelectionLength);
    lCursorX := AX + AFont.TextPixelWidth(Copy(fEditText, 1, Max(0, fEditCursor - 1)));
    SetGLColor($FF202020);
    DrawLine(lCursorX, AY - 1, lCursorX, AY + AFont.TextPixelHeight + 1);
    DrawText(fEditText, AX, AY, AFont);
  end

  else
    DrawText(AText, AX, AY, AFont);
end;

procedure TOpenGLChartRenderer.DrawGrid(const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);

var
  lIndex: Integer;
  lX: Single;
  lY: Single;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
begin
  BuildXTicks(APage, AYAxis, 8, lXTicks);
  if Assigned(AYAxis) then
    BuildAxisTicks(AYAxis, 8, lYTicks)
  else
    lYTicks := nil;
  SetGLColor($FFB8B8B8);
  glLineWidth(1.6);
  for lIndex := 0 to High(lXTicks) do
  begin
    lX := XValueToPixel(APage, AYAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right);
    DrawLine(lX, ARect.Top, lX, ARect.Bottom);
  end;

  for lIndex := 0 to High(lYTicks) do
  begin
    lY := AxisValueToPixel(AYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
    DrawLine(ARect.Left, lY, ARect.Right, lY);
  end;

end;

procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);

const
  CTick = 5;

var
  lIndex: Integer;
  I: Integer;
  lX: Single;
  lY: Single;
  lPrimaryAxis: TChartAxis;
  lYAxis: TChartAxis;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
  lFont: cOglFont;
  lText: string;
  lAxisOffset: Single;
  lMaxTextWidth, lTextWidth: Single;
  lLabelTop, lMinLabelTop, lMaxLabelTop: Single;
  lIsMinTick, lIsMaxTick, lHideTickText: Boolean;

  function ClampYLabelTop(AY: Single; AFont: cOglFont): Single;
  var
    lTextHeight: Single;
  begin
    if Assigned(AFont) then
      lTextHeight := AFont.TextPixelHeight
    else
      lTextHeight := 0;
    Result := AY - lTextHeight / 2;
    if Result < ARect.Top then
      Result := ARect.Top;
    if Result + lTextHeight > ARect.Bottom then
      Result := ARect.Bottom - lTextHeight;
  end;

  function YLabelIntersects(ATop1, ATop2: Single; AFont: cOglFont): Boolean;
  var
    lTextHeight: Single;
  begin
    if Assigned(AFont) then
      lTextHeight := AFont.TextPixelHeight
    else
      lTextHeight := 0;
    Result := (ATop1 < ATop2 + lTextHeight) and (ATop2 < ATop1 + lTextHeight);
  end;

begin
  lPrimaryAxis := GetPrimaryXAxis(APage);
  SetGLColor($FF303030);
  glLineWidth(2);
  DrawLine(ARect.Left, ARect.Bottom, ARect.Right, ARect.Bottom);
  SetGLColor($FF606060);
  glLineWidth(1.5);
  DrawRect(ARect);
  // Draw X ticks and labels
  BuildXTicks(APage, lPrimaryAxis, 8, lXTicks);
  SetGLColor($FF404040);
  glLineWidth(1);
  for lIndex := 0 to High(lXTicks) do
  begin
    lX := XValueToPixel(APage, lPrimaryAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right);
    DrawLine(lX, ARect.Bottom, lX, ARect.Bottom + CTick);
  end;

  if Assigned(APage) and (APage.Caption <> '') then
    DrawText(APage.Caption, fPageRect.Left + APage.PixelTabSpace.Left, fPageRect.Top + 6, fFontMng.Font(cfPageCaption));
  lFont := fFontMng.Font(cfGridTick);
  for lIndex := 0 to High(lXTicks) do
  begin
    lText := lXTicks[lIndex].Text;
    lX := XValueToPixel(APage, lPrimaryAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right) -
      lFont.TextPixelWidth(lText) / 2;
    if (Assigned(lPrimaryAxis) and lPrimaryAxis.UseOwnX) then
    begin
      if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lPrimaryAxis, nil, celXMin)
      else if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lPrimaryAxis, nil, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lFont);
    end

    else if Assigned(APage) then
    begin
      if Abs(lXTicks[lIndex].Value - APage.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, nil, APage, celXMin)
      else if Abs(lXTicks[lIndex].Value - APage.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, nil, APage, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lFont);
    end

    else
      DrawText(lText, lX, ARect.Bottom + 7, lFont);
  end;

  // Draw Y axes and labels
  lAxisOffset := 0;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lYAxis := TChartAxis(APage.Children[I]);
      BuildAxisTicks(lYAxis, 8, lYTicks);
      // Названия осей Y не выводятся, чтобы избежать наложений и мешанины
      lX := ARect.Left - lAxisOffset;
      SetGLColor(lYAxis.Color);
      glLineWidth(1.5);
      DrawLine(lX, ARect.Top, lX, ARect.Bottom);
      if lYAxis = fSelectedObject then
        lFont := fFontMng.Font(cfAxisSelected)
      else
        lFont := fFontMng.Font(cfGridTick);
      lMinLabelTop := ClampYLabelTop(AxisValueToPixel(lYAxis, lYAxis.MinValue, ARect.Bottom, ARect.Top), lFont);
      lMaxLabelTop := ClampYLabelTop(AxisValueToPixel(lYAxis, lYAxis.MaxValue, ARect.Bottom, ARect.Top), lFont);
      lMaxTextWidth := 0;
      for lIndex := 0 to High(lYTicks) do
      begin
        lText := lYTicks[lIndex].Text;
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
        SetGLColor($FF404040);
        glLineWidth(1);
        DrawLine(lX, lY, lX - CTick, lY);
        lTextWidth := lFont.TextPixelWidth(lText);
        if lTextWidth > lMaxTextWidth then
          lMaxTextWidth := lTextWidth;
        lLabelTop := ClampYLabelTop(lY, lFont);
        lIsMinTick := Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9;
        lIsMaxTick := Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9;
        lHideTickText := (not lIsMinTick) and (not lIsMaxTick) and
          (YLabelIntersects(lLabelTop, lMinLabelTop, lFont) or
           YLabelIntersects(lLabelTop, lMaxLabelTop, lFont));
        if lIsMinTick then
          DrawEditableText(lText, lX - lTextWidth - 7, lLabelTop, lFont, lYAxis, nil, celAxisMin)
        else if lIsMaxTick then
          DrawEditableText(lText, lX - lTextWidth - 7, lLabelTop, lFont, lYAxis, nil, celAxisMax)
        else if not lHideTickText then
          DrawText(lText, lX - lTextWidth - 7, lLabelTop, lFont);
      end;

      if lMaxTextWidth < 30.0 then
        lMaxTextWidth := 30.0;
      lAxisOffset := lAxisOffset + lMaxTextWidth + 15;
    end;

end;

procedure TOpenGLChartRenderer.DrawPageFrame(APage: TChartPage; const ARect: TChartPixelRect);
begin
  SetGLColor(APage.FillColor);
  FillRect(ARect);
  if Assigned(APage) and APage.Selected then
    SetGLColor($FF3C7DFF)
  else
    SetGLColor(APage.BorderColor);
  glLineWidth(APage.BorderWidth);
  DrawRect(ARect);
end;

procedure TOpenGLChartRenderer.DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
begin
  RenderLineSeries(Self, ASeries, ARect, APage, AYAxis, fUseShader, fShaderInitialized, fProgram);
end;

procedure TOpenGLChartRenderer.DrawBaseTrend(ATrend: cBaseTrend; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
begin
  if not Assigned(ATrend) then
    Exit;
  if ATrend is cBuffTrendQueue then
    DrawBuffTrendQueue(cBuffTrendQueue(ATrend), ARect, APage, AYAxis)
  else if ATrend is cBuffTrend1d then
    DrawBuffTrend1d(cBuffTrend1d(ATrend), ARect, APage, AYAxis)
  else if ATrend is TChartLineSeries then
  begin
    DrawLineSeries(TChartLineSeries(ATrend), ARect, APage, AYAxis);
    if ATrend is cTrend then
      DrawTrendPoints(cTrend(ATrend), ARect, APage, AYAxis);
  end;

end;

procedure TOpenGLChartRenderer.DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
begin
  RenderBuffTrend1d(Self, ATrend, ARect, APage, AYAxis, fUseShader, fShaderInitialized, fProgram1d);
end;

procedure TOpenGLChartRenderer.DrawBuffTrendQueue(ATrend: cBuffTrendQueue;
  const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
begin
  RenderBuffTrendQueue(Self, ATrend, ARect, APage, AYAxis, fUseShader,
    fShaderInitialized, fProgram);
end;
procedure TOpenGLChartRenderer.DrawTextLabel(ALabel: TChartTextLabel; APage: TChartPage; const ARect: TChartPixelRect);

var
  lPageRect, lContentRect, lLabelRect: TChartPixelRect;
  lX, lY: Single;
  lPageWidth, lPageHeight: Integer;
  lFont: cOglFont;
  lLines: TStringList;
  I: Integer;
  lLineY: Single;
  lFlag: TChartFlagLabel;
  lTrend: cBaseTrend;
  lTrendYVal: Double;
  lPtX, lPtY, lConnX: Single;
  lAxis: TChartAxis;
  lTrends: TList;
  lTrendIdx: Integer;
  lOldUseTextureAtlas: Boolean;
  lOldColor: Cardinal;
  lRawLines: TStringList;
  lLineW: Single;
  lMaxW: Single;
  lTextWidth: Integer;
begin
  lPageRect := PageToPixelRect(APage);
  lContentRect := PageContentRect(APage);  lPageWidth := lPageRect.Right - lPageRect.Left;
  lPageHeight := lPageRect.Bottom - lPageRect.Top;

  // Вычисляем динамическую ширину метки на основе текста
  if ALabel is TChartFlagLabel then
    lFont := fFontMng.Font(cfGridTick)
  else
    lFont := fFontMng.Font(cfAxisLabel);

  lTextWidth := ALabel.Width;
  if Assigned(lFont) then
  begin
    lRawLines := TStringList.Create;
    try
      lRawLines.Text := ALabel.Text;
      lMaxW := 0;
      for I := 0 to lRawLines.Count - 1 do
      begin
        lLineW := lFont.TextPixelWidth(lRawLines[I]);
        if lLineW > lMaxW then
          lMaxW := lLineW;
      end;
      if lMaxW > 0 then
        lTextWidth := Round(lMaxW) + 12; // 6px слева, 6px справа
    finally
      lRawLines.Free;
    end;
  end;

  // В X-координатах:
  if ALabel.IsWorldX then
  begin
    lX := XValueToPixel(APage, nil, ALabel.WorldX, lContentRect.Left, lContentRect.Right);
    lLabelRect.Left := Round(lX);
    lLabelRect.Right := lLabelRect.Left + lTextWidth;
  end
  else
  begin
    lLabelRect.Left := lContentRect.Left + Round(ALabel.FloatRect.Left * (lContentRect.Right - lContentRect.Left));
    lLabelRect.Right := lLabelRect.Left + lTextWidth;
  end;

  // Вычисляем координаты Y рамки метки в пикселях
  if ALabel.IsWorldY and Assigned(ALabel.Axis) then
  begin
    lY := AxisValueToPixel(ALabel.Axis, ALabel.WorldY, lContentRect.Bottom, lContentRect.Top);
    lLabelRect.Top := Round(lY) + ALabel.RenderYOffset;
    lLabelRect.Bottom := lLabelRect.Top + ALabel.Height;
  end

  else
  begin
    lLabelRect.Top := lContentRect.Top + Round(ALabel.FloatRect.Top * (lContentRect.Bottom - lContentRect.Top)) + ALabel.RenderYOffset;
    lLabelRect.Bottom := lContentRect.Top + Round(ALabel.FloatRect.Bottom * (lContentRect.Bottom - lContentRect.Top)) + ALabel.RenderYOffset;
  end;

  // 1. Если это флаг, рисуем линию выноски и маркер на самом тренде
  if ALabel is TChartFlagLabel then
  begin
    lFlag := TChartFlagLabel(ALabel);
    // Собираем все тренды для отрисовки выносок
    lTrends := TList.Create;
    try
      if lFlag.AttachToAllTrends then
      begin
        // Ищем все тренды на странице
        for I := 0 to APage.ChildCount - 1 do
          if APage.Children[I] is TChartAxis then
          begin
            lAxis := TChartAxis(APage.Children[I]);
            for lTrendIdx := 0 to lAxis.ChildCount - 1 do
              if lAxis.Children[lTrendIdx] is cBaseTrend then
                lTrends.Add(lAxis.Children[lTrendIdx]);
          end;

      end

      else if Assigned(lFlag.Trend) then
      begin
        lTrends.Add(lFlag.Trend);
      end;

      for I := 0 to lTrends.Count - 1 do
      begin
        lTrend := cBaseTrend(lTrends[I]);
        lAxis := TChartAxis(lTrend.Parent);
        // Получаем значение Y тренда по координате X флага (которая в мировых координатах)
        if GetTrendValueAtX(lTrend, lFlag.AnchorX, lTrendYVal) then
        begin
          // Преобразуем мировые координаты точки привязки в пиксели
          lPtX := XValueToPixel(APage, nil, lFlag.AnchorX, lContentRect.Left, lContentRect.Right);
          lPtY := AxisValueToPixel(lAxis, lTrendYVal, lContentRect.Bottom, lContentRect.Top);
          // Рисуем линию-выноску от точки привязки к центру нижней (или верхней) части рамки флага
          lConnX := (lLabelRect.Left + lLabelRect.Right) / 2;
          if lPtX < lLabelRect.Left then
            lConnX := lLabelRect.Left
          else if lPtX > lLabelRect.Right then
            lConnX := lLabelRect.Right;

          SetGLColor($FF808080); // Line color
          glLineWidth(1.0);
          glBegin(GL_LINES);
          glVertex2f(lPtX, lPtY);
          glVertex2f(lConnX, (lLabelRect.Top + lLabelRect.Bottom) / 2);
          glEnd;
          // Рисуем незалитый маркер, чтобы он не перекрывал текст флага
          SetGLColor($FF202020);
          glBegin(GL_LINE_LOOP);
          glVertex2f(lPtX - 3, lPtY - 3);
          glVertex2f(lPtX + 3, lPtY - 3);
          glVertex2f(lPtX + 3, lPtY + 3);
          glVertex2f(lPtX - 3, lPtY + 3);
          glEnd;
        end;

      end;

    finally
      lTrends.Free;
    end;

  end;

  // 2. Рисуем фон метки (для флага максимума делаем его полупрозрачным, как у курсора)
  if (ALabel is TChartFlagLabel) and (TChartFlagLabel(ALabel).Trend <> nil) then
    SetGLColor($D8F5F5FA)
  else
    SetGLColor($FFFFFFFF);
  FillRect(lLabelRect);
  // 3. Рисуем границу рамки
  if SelectedObject = ALabel then
    SetGLColor($FFFF0000) // Выделено (красный)
  else if (ALabel is TChartFlagLabel) and (TChartFlagLabel(ALabel).Trend <> nil) then
    SetGLColor(TChartFlagLabel(ALabel).Trend.Color) // В цвет соответствующей линии
  else
    SetGLColor($FFCCCCCC); // Обычный серый
  glLineWidth(1.0);
  DrawRect(lLabelRect);
  // 4. Отрисовка текста с автопереносом
  // 4. Отрисовка текста внутри метки
  if ALabel is TChartFlagLabel then
    lFont := fFontMng.Font(cfGridTick) // Используем мелкий шрифт, как на курсорах
  else
    lFont := fFontMng.Font(cfAxisLabel);
  if Assigned(lFont) then
  begin
    lOldColor := lFont.Color;
    if (ALabel is TChartFlagLabel) and (TChartFlagLabel(ALabel).Trend <> nil) then
      lFont.Color := TChartFlagLabel(ALabel).Trend.Color // Текст цветом линии
    else
      lFont.Color := $FF333333;
    lLines := TStringList.Create;
    try
      ALabel.GetWrappedLines(lFont, lLabelRect.Right - lLabelRect.Left - 8, lLines);
      lLineY := lLabelRect.Top + 4;
      for I := 0 to lLines.Count - 1 do
      begin
        if (I > 0) and (lLineY + lFont.TextPixelHeight > lLabelRect.Bottom - 2) then
          Break;
        DrawText(lLines[I], lLabelRect.Left + 4, lLineY, lFont);
        lLineY := lLineY + lFont.TextPixelHeight + 2;
      end;
    finally
      lFont.Color := lOldColor;
      lLines.Free;
    end;
  end;

end;

procedure TOpenGLChartRenderer.RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);

var
  lIndex: Integer;
  lYAxis: TChartAxis;
begin
  if not Assigned(AObject) then
    Exit;
  if (AObject is TChartDrawObject) and not TChartDrawObject(AObject).Visible then
    Exit;
  lYAxis := AYAxis;
  if AObject is TChartAxis then
    lYAxis := TChartAxis(AObject);
  if AObject is cBaseTrend then
    DrawBaseTrend(cBaseTrend(AObject), ARect, APage, lYAxis);
  // В основном проходе TChartTextLabel пропускается (рисуется позже в RenderLabels)
  // if AObject is TChartTextLabel then
  //   DrawTextLabel(TChartTextLabel(AObject), APage, ARect);
  if AObject is TChartCursor then
      DrawCursor(TChartCursor(AObject), APage, ARect);
    if AObject is TChartFrequencyBand then
      DrawFrequencyBand(TChartFrequencyBand(AObject), APage, ARect);
  for lIndex := 0 to AObject.ChildCount - 1 do
    RenderObject(AObject.Children[lIndex], ARect, APage, lYAxis);
end;

procedure TOpenGLChartRenderer.RenderLabels(AObject: TChartBaseObject; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lYAxis: TChartAxis;
begin
  if not Assigned(AObject) then
    Exit;
  if (AObject is TChartDrawObject) and not TChartDrawObject(AObject).Visible then
    Exit;
  lYAxis := AYAxis;
  if AObject is TChartAxis then
    lYAxis := TChartAxis(AObject);
  if AObject is TChartTextLabel then
    DrawTextLabel(TChartTextLabel(AObject), APage, ARect);
  for lIndex := 0 to AObject.ChildCount - 1 do
    RenderLabels(AObject.Children[lIndex], ARect, APage, lYAxis);
end;

procedure TOpenGLChartRenderer.CollectFlags(AObject: TChartBaseObject; AList: TList);
var
  I: Integer;
begin
  if not Assigned(AObject) then Exit;
  if (AObject is TChartFlagLabel) and TChartFlagLabel(AObject).Visible then
    AList.Add(AObject);
  for I := 0 to AObject.ChildCount - 1 do
    CollectFlags(AObject.Children[I], AList);
end;

procedure TOpenGLChartRenderer.ResolveFlagOverlaps(APage: TChartPage);
var
  lFlags: TList;
  lFlag: TChartFlagLabel;
  I, J: Integer;
  lContentRect: TChartPixelRect;
  lY: Single;
  lBaseY: array of Integer;
  lHeight: array of Integer;
  lTemp: Pointer;
  lDiff: Integer;
begin
  lFlags := TList.Create;
  try
    CollectFlags(APage, lFlags);
    if lFlags.Count <= 1 then Exit;

    lContentRect := PageContentRect(APage);

    SetLength(lBaseY, lFlags.Count);
    SetLength(lHeight, lFlags.Count);
    for I := 0 to lFlags.Count - 1 do
    begin
      lFlag := TChartFlagLabel(lFlags[I]);
      lFlag.RenderYOffset := 0;

      if lFlag.IsWorldY and Assigned(lFlag.Axis) then
      begin
        lY := AxisValueToPixel(lFlag.Axis, lFlag.WorldY, lContentRect.Bottom, lContentRect.Top);
        lBaseY[I] := Round(lY);
      end
      else
      begin
        lBaseY[I] := lContentRect.Top + Round(lFlag.FloatRect.Top * (lContentRect.Bottom - lContentRect.Top));
      end;
      lHeight[I] := lFlag.Height;
    end;

    for I := 0 to lFlags.Count - 2 do
      for J := I + 1 to lFlags.Count - 1 do
        if lBaseY[I] > lBaseY[J] then
        begin
          lTemp := lFlags[I];
          lFlags[I] := lFlags[J];
          lFlags[J] := lTemp;

          lDiff := lBaseY[I]; lBaseY[I] := lBaseY[J]; lBaseY[J] := lDiff;
          lDiff := lHeight[I]; lHeight[I] := lHeight[J]; lHeight[J] := lDiff;
        end;

    for I := 1 to lFlags.Count - 1 do
    begin
      lDiff := (lBaseY[I-1] + TChartFlagLabel(lFlags[I-1]).RenderYOffset + lHeight[I-1] + 4) - lBaseY[I];
      if lDiff > 0 then
      begin
        TChartFlagLabel(lFlags[I]).RenderYOffset := lDiff;
      end;
    end;

  finally
    lFlags.Free;
  end;
end;

procedure TOpenGLChartRenderer.RenderPage(APage: TChartPage);

var
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lYAxis: TChartAxis;
begin
  if not Assigned(APage) then
    Exit;
  if not APage.Visible then
    Exit;
  ResolveFlagOverlaps(APage);
  fPageRect := PageToPixelRect(APage);
  lContentRect := PageContentRect(APage);
  lYAxis := GetPrimaryXAxis(APage);
  glEnable(GL_SCISSOR_TEST);
  glScissor(fPageRect.Left, fHost.GetHeight - fPageRect.Bottom,
    Max(1, fPageRect.Right - fPageRect.Left),
    Max(1, fPageRect.Bottom - fPageRect.Top));
  DrawPageFrame(APage, fPageRect);
  DrawGrid(lContentRect, APage, lYAxis);
  DrawBandShadedRects(APage, lContentRect);
  DrawAxes(lContentRect, APage);
  glScissor(lContentRect.Left, fHost.GetHeight - lContentRect.Bottom,
    Max(1, lContentRect.Right - lContentRect.Left),
    Max(1, lContentRect.Bottom - lContentRect.Top));
  for lIndex := 0 to APage.ChildCount - 1 do
    RenderObject(APage.Children[lIndex], lContentRect, APage, nil);
  for lIndex := 0 to APage.ChildCount - 1 do
    RenderLabels(APage.Children[lIndex], lContentRect, APage, nil);
  glDisable(GL_SCISSOR_TEST);
end;

procedure TOpenGLChartRenderer.Render(AModel: TObject);

var
  lColor: Cardinal;
  r: Single;
  g: Single;
  b: Single;
  a: Single;
  lModel: TChartModel;
  lIndex: Integer;
  lPage: TChartPage;
  lAxisIdx: Integer;
  lAxis: TChartAxis;
begin
  if (GetEnvironmentVariable('RECORDER_CHART_RENDER_LOG') = '1') and
    Assigned(AModel) and (AModel is TChartModel) then
  begin
    lModel := TChartModel(AModel);
    LogToFile('=== TOpenGLChartRenderer.Render ===');
    LogToFile('Host Width=' + IntToStr(fHost.GetWidth) + ', Height=' + IntToStr(fHost.GetHeight));
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPage := TChartPage(lModel.Children[lIndex]);
        LogToFile('Page: ' + lPage.Name +
                  ' Visible=' + BoolToStr(lPage.Visible, True) +
                  ' XMinValue=' + FloatToStr(lPage.XMinValue) +
                  ' XMaxValue=' + FloatToStr(lPage.XMaxValue) +
                  ' Align=' + IntToStr(Ord(lPage.Align)) +
                  ' Rect=(' + FloatToStr(lPage.FloatRect.Left) + ',' + FloatToStr(lPage.FloatRect.Top) +
                  ',' + FloatToStr(lPage.FloatRect.Right) + ',' + FloatToStr(lPage.FloatRect.Bottom) + ')');
        for lAxisIdx := 0 to lPage.ChildCount - 1 do
          if lPage.Children[lAxisIdx] is TChartAxis then
          begin
            lAxis := TChartAxis(lPage.Children[lAxisIdx]);
            LogToFile('  Axis: ' + lAxis.Name +
                      ' MinValue=' + FloatToStr(lAxis.MinValue) +
                      ' MaxValue=' + FloatToStr(lAxis.MaxValue));
          end;

      end;

  end;

  if not Assigned(AModel) or not (AModel is TChartModel) then
    Exit;
  lModel := TChartModel(AModel);
  lColor := lModel.BackgroundColor;
  r := (lColor and $000000FF) / 255;
  g := ((lColor and $0000FF00) shr 8) / 255;
  b := ((lColor and $00FF0000) shr 16) / 255;
  a := ((lColor and $FF000000) shr 24) / 255;
  glClearColor(r, g, b, a);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  Apply2DView;
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_TEXTURE_2D);
  SetLength(fTextHits, 0);
  lModel.AlignPagesAuto(fHost.GetWidth / Max(1, fHost.GetHeight));
  for lIndex := 0 to lModel.ChildCount - 1 do
    if lModel.Children[lIndex] is TChartPage then
      RenderPage(TChartPage(lModel.Children[lIndex]));
  DrawHighlights;
  if fSelectionRectActive then
  begin
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // Заливка полупрозрачным синим цветом
    SetGLColor($403C7DFF);
    FillRect(fSelectionRect);
    // Рамка
    SetGLColor($FF3C7DFF);
    glLineWidth(1.5);
    DrawRect(fSelectionRect);
    glDisable(GL_BLEND);
  end;

end;

function TOpenGLChartRenderer.MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;

var
  I: Integer;
begin
  Result := False;
  fActiveHit.Axis := nil;
  fActiveHit.Page := nil;
  fActiveHit.Kind := celNone;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
      (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      fActiveHit := fTextHits[I];
      fEditText := fTextHits[I].Text;
      if ADoubleClick then
      begin
        fEditSelectionStart := 1;
        fEditSelectionLength := Length(fEditText);
        fEditCursor := Length(fEditText) + 1;
      end

      else
      begin
        fEditCursor := fTextHits[I].Font.HitCharIndex(fEditText, AX, fTextHits[I].TextLeft);
        fEditSelectionStart := fEditCursor;
        fEditSelectionLength := 0;
      end;

      Result := True;
      Exit;
    end;

end;

procedure ApplyActiveHitNumericValue(const AHit: TChartTextHit; AValue: Double);
begin
  case AHit.Kind of
    celAxisMin:
      ChartAxisApplyUserValue(AHit.Axis, True, AValue);
    celAxisMax:
      ChartAxisApplyUserValue(AHit.Axis, False, AValue);
    celXMin:
      if Assigned(AHit.Axis) then
        AHit.Axis.XMinValue := AValue
      else if Assigned(AHit.Page) then
      begin
        ChartPageApplyUserXValue(AHit.Page, True, AValue);
        AHit.Page.ZoomedX := True;
      end;
    celXMax:
      if Assigned(AHit.Axis) then
        AHit.Axis.XMaxValue := AValue
      else if Assigned(AHit.Page) then
      begin
        ChartPageApplyUserXValue(AHit.Page, False, AValue);
        AHit.Page.ZoomedX := True;
      end;
  end;
end;

function TOpenGLChartRenderer.KeyDown(AKey: Word): Boolean;

var
  lValue: Double;
begin
  Result := fActiveHit.Kind <> celNone;
  if not Result then
    Exit;
  case AKey of
    VK_BACK:
      if fEditCursor > 1 then
      begin
        Delete(fEditText, fEditCursor - 1, 1);
        Dec(fEditCursor);
      end;

    VK_DELETE:
      if fEditCursor <= Length(fEditText) then
        Delete(fEditText, fEditCursor, 1);
    VK_LEFT:
      fEditCursor := Max(1, fEditCursor - 1);
    VK_RIGHT:
      fEditCursor := Min(Length(fEditText) + 1, fEditCursor + 1);
    VK_HOME:
      fEditCursor := 1;
    VK_END:
      fEditCursor := Length(fEditText) + 1;
    else
      Exit(False);
  end;

  fEditSelectionStart := fEditCursor;
  fEditSelectionLength := 0;
  if TryStrToFloatUniversal(fEditText, lValue) then
    ApplyActiveHitNumericValue(fActiveHit, lValue);

end;

function TOpenGLChartRenderer.TextInput(const AText: string): Boolean;

var
  lValue: Double;
  lChar: Char;
begin
  Result := fActiveHit.Kind <> celNone;
  if not Result or (AText = '') then
    Exit;
  lChar := AText[1];
  if not (lChar in ['0'..'9', '-', '+', '.', ',']) then
    Exit(False);
  if lChar = ',' then
    lChar := '.';
  if fEditSelectionLength > 0 then
  begin
    Delete(fEditText, fEditSelectionStart, fEditSelectionLength);
    fEditCursor := fEditSelectionStart;
  end;

  Insert(lChar, fEditText, fEditCursor);
  Inc(fEditCursor);
  fEditSelectionStart := fEditCursor;
  fEditSelectionLength := 0;
  if TryStrToFloatUniversal(fEditText, lValue) then
    ApplyActiveHitNumericValue(fActiveHit, lValue);

end;

procedure TOpenGLChartRenderer.DrawHighlightRect(const ARect: TChartPixelRect; AColor: Cardinal);
begin
  SetGLColor(AColor);
  glLineWidth(1.2);
  DrawRect(ARect);
end;

procedure TOpenGLChartRenderer.DrawHighlights;

var
  lHovered, lSelected: TChartBaseObject;
  lIndex: Integer;
  lPageRect: TChartPixelRect;
begin
  lHovered := fHoveredObject;
  lSelected := fSelectedObject;
  // 1. Highlight hovered page or axis text hit
  if Assigned(lHovered) then
  begin
    if lHovered is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lHovered));
      DrawHighlightRect(lPageRect, $50FFCC00); // semi-transparent yellow highlight frame
    end

    else if lHovered is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lHovered then
          DrawHighlightRect(fTextHits[lIndex].Rect, $80FFCC00);
    end;

  end;

  // 2. Highlight selected page or axis text hit
  if Assigned(lSelected) then
  begin
    if lSelected is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lSelected));
      SetGLColor($FFFF3300); // Bold orange/red border
      glLineWidth(3);
      DrawRect(lPageRect);
    end

    else if lSelected is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lSelected then
        begin
          SetGLColor($FFFF3300);
          glLineWidth(1.5);
          DrawRect(fTextHits[lIndex].Rect);
        end;

    end;

  end;

end;

function TOpenGLChartRenderer.GetPageRect(APage: TChartPage): TChartPixelRect;
begin
  Result := PageToPixelRect(APage);
end;

function TOpenGLChartRenderer.GetPageContentRect(APage: TChartPage): TChartPixelRect;
begin
  fPageRect := PageToPixelRect(APage);
  Result := PageContentRect(APage);
end;

function TOpenGLChartRenderer.GetTextHitAt(AX, AY: Integer; out AHit: TChartTextHit): Boolean;

var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
       (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      AHit := fTextHits[I];
      Result := True;
      Exit;
    end;

end;

function TOpenGLChartRenderer.PixelToXValue(APage: TChartPage; AAxis: TChartAxis; APixelX, ALeft, ARight: Single): Double;

var
  lMin, lMax: Double;
  lScale: TChartAxisScale;
begin
  lMin := 0;
  lMax := 1;
  lScale := casLinear;
  if Assigned(AAxis) and AAxis.UseOwnX then
  begin
    lMin := AAxis.XMinValue;
    lMax := AAxis.XMaxValue;
    lScale := AAxis.XScale;
  end

  else if Assigned(APage) then
  begin
    lMin := APage.XMinValue;
    lMax := APage.XMaxValue;
    lScale := APage.XScale;
  end;

  if ARight = ALeft then
    Exit(lMin);

  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1e-10);
    if lMax <= lMin then
      lMax := lMin * 10;
    Result := Power(10, Log10(lMin) + (APixelX - ALeft) / (ARight - ALeft) * (Log10(lMax) - Log10(lMin)));
  end
  else
    Result := lMin + (APixelX - ALeft) / (ARight - ALeft) * (lMax - lMin);
end;

function TOpenGLChartRenderer.PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;
begin
  if not Assigned(AAxis) then
    Exit(0);
  if ABottom = ATop then
    Exit(AAxis.MinValue);
  if AAxis.Scale = casLog10 then
    Result := Power(10, Log10(Max(AAxis.MinValue, 1e-10)) + (APixelY - ABottom) / (ATop - ABottom) * (Log10(Max(AAxis.MaxValue, 1e-10)) - Log10(Max(AAxis.MinValue, 1e-10))))
  else
    Result := AAxis.MinValue + (APixelY - ABottom) / (ATop - ABottom) * (AAxis.MaxValue - AAxis.MinValue);
end;

procedure TOpenGLChartRenderer.DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
begin
  RenderTrendPoints(Self, ATrend, ARect, APage, AYAxis);
end;

function TOpenGLChartRenderer.GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;

var
  lIndex, I, J: Integer;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lYAxis: TChartAxis;
  lAxisX, lAxisOffset: Single;
  lYTicks: TChartTickArray;
  lAxisFont: cOglFont;
  lMaxTextWidth, lTextWidth: Integer;
  lText: string;
begin
  AAxis := nil;
  for lIndex := 0 to AModel.ChildCount - 1 do
    if AModel.Children[lIndex] is TChartPage then
    begin
      lPage := TChartPage(AModel.Children[lIndex]);
      lPageRect := GetPageRect(lPage);
      if (AX >= lPageRect.Left) and (AX <= lPageRect.Right) and
         (AY >= lPageRect.Top) and (AY <= lPageRect.Bottom) then
      begin
        lContentRect := GetPageContentRect(lPage);
        lAxisOffset := 0;
        for I := 0 to lPage.ChildCount - 1 do
          if lPage.Children[I] is TChartAxis then
          begin
            lYAxis := TChartAxis(lPage.Children[I]);
            lAxisX := lContentRect.Left - lAxisOffset;
            if (AY >= lContentRect.Top) and (AY <= lContentRect.Bottom) and
               (Abs(AX - lAxisX) <= 10) then
            begin
              AAxis := lYAxis;
              Exit(True);
            end;

            BuildAxisTicks(lYAxis, 8, lYTicks);
            if lYAxis = fSelectedObject then
              lAxisFont := fFontMng.Font(cfAxisSelected)
            else
              lAxisFont := fFontMng.Font(cfAxisLabel);
            lMaxTextWidth := 0;
            for J := 0 to High(lYTicks) do
            begin
              lText := lYTicks[J].Text;
              lTextWidth := lAxisFont.TextPixelWidth(lText);
              if lTextWidth > lMaxTextWidth then
                lMaxTextWidth := lTextWidth;
            end;

            if lMaxTextWidth < 30 then
              lMaxTextWidth := 30;
            lAxisOffset := lAxisOffset + lMaxTextWidth + 15;
          end;

      end;

    end;

  Result := False;
end;

end.
