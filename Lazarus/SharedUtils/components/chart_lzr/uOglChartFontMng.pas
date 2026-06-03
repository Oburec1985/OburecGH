unit uOglChartFontMng;

{$mode objfpc}{$H+}

{
  Модуль uOglChartFontMng
  Описание: Управляет шрифтами отрисовки в OpenGL (вычисление пиксельной ширины символов,
            высоты текста, определение символа под курсором мыши).
}

interface

type
  { cChartFontKind }
  // Типы шрифтов для различных элементов чарта
  cChartFontKind = (
    cfPageCaption,   // Заголовок страницы
    cfAxisLabel,     // Подписи осей
    cfAxisSelected,  // Подпись выделенной оси
    cfGridTick,      // Деления сетки
    cfLegend,        // Легенда графика
    cfDebug          // Отладочная информация
  );

  { cOglFont }
  // Класс шрифта, используемый для вычисления метрик текста.
  cOglFont = class(TObject)
  private
    fName: string;                       // Название шрифта (для рендерера)
    fScale: Single;                      // Масштаб шрифта (множитель размера)
    fColor: Cardinal;                    // Цвет шрифта в формате RGBA
    fBold: Boolean;                      // Жирное начертание
  public
    constructor Create(const AName: string; AScale: Single; AColor: Cardinal; ABold: Boolean);
    
    // Возвращает ширину одного символа в пикселях
    function CharPixelWidth(AChar: WideChar): Integer;
    // Вычисляет общую ширину строки в пикселях
    function TextPixelWidth(const AText: string): Integer;
    // Возвращает высоту текста в пикселях
    function TextPixelHeight: Integer;
    // Определяет индекс символа в строке, по которому кликнули мышкой (для редактирования)
    function HitCharIndex(const AText: string; AX, ATextLeft: Integer): Integer;

    property Name: string read fName write fName;
    property Scale: Single read fScale write fScale;
    property Color: Cardinal read fColor write fColor;
    property Bold: Boolean read fBold write fBold;
  end;

  { cOglFontMng }
  // Менеджер шрифтов чарта, содержащий преднастроенные шрифты для всех типов cChartFontKind.
  cOglFontMng = class(TObject)
  private
    fFonts: array[cChartFontKind] of cOglFont; // Набор преднастроенных шрифтов
  public
    constructor Create;
    destructor Destroy; override;

    // Возвращает объект шрифта по его типу
    function Font(AKind: cChartFontKind): cOglFont;
  end;

implementation

uses
  Math;

{ cOglFont }

constructor cOglFont.Create(const AName: string; AScale: Single; AColor: Cardinal; ABold: Boolean);
begin
  inherited Create;
  fName := AName;
  fScale := AScale;
  fColor := AColor;
  fBold := ABold;
end;

/// <summary>
/// Вычисляет пиксельную ширину символа на основе масштаба и стиля Bold.
/// </summary>
function cOglFont.CharPixelWidth(AChar: WideChar): Integer;
begin
  // Пробел считается чуть уже обычных моноширинных символов
  if AChar = ' ' then
    Result := Round(4 * fScale)
  else
    Result := Round(6 * fScale);
  if fBold then
    Inc(Result);
end;

/// <summary>
/// Вычисляет суммарную пиксельную ширину всей строки.
/// </summary>
function cOglFont.TextPixelWidth(const AText: string): Integer;
var
  I: Integer;
  lWideText: WideString;
begin
  lWideText := UTF8Decode(AText);
  Result := 0;
  for I := 1 to Length(lWideText) do
    Inc(Result, CharPixelWidth(lWideText[I]));
end;

/// <summary>
/// Возвращает высоту строки текста в пикселях с учетом масштаба.
/// </summary>
function cOglFont.TextPixelHeight: Integer;
begin
  Result := Max(1, Round(7 * fScale));
end;

/// <summary>
/// Нахождение индекса символа в строке по координате клика.
/// </summary>
/// <param name="AText">Строка текста</param>
/// <param name="AX">Координата X клика</param>
/// <param name="ATextLeft">Начальная координата X отрисованного текста</param>
function cOglFont.HitCharIndex(const AText: string; AX, ATextLeft: Integer): Integer;
var
  I: Integer;
  lX: Integer;
  lWideText: WideString;
begin
  lWideText := UTF8Decode(AText);
  Result := Length(lWideText) + 1;
  lX := ATextLeft;
  for I := 1 to Length(lWideText) do
  begin
    if AX < lX + CharPixelWidth(lWideText[I]) div 2 then
      Exit(I);
    Inc(lX, CharPixelWidth(lWideText[I]));
  end;
end;

{ cOglFontMng }

/// <summary>
/// Конструктор менеджера: инициализирует стандартный набор шрифтов с предопределенными масштабами и цветами.
/// </summary>
constructor cOglFontMng.Create;
begin
  inherited Create;
  fFonts[cfPageCaption] := cOglFont.Create('PageCaption', 1.8, $FF303030, True);
  fFonts[cfAxisLabel] := cOglFont.Create('AxisLabel', 1.55, $FF404040, False);
  fFonts[cfAxisSelected] := cOglFont.Create('AxisSelected', 1.55, $FF202020, True);
  fFonts[cfGridTick] := cOglFont.Create('GridTick', 1.45, $FF505050, False);
  fFonts[cfLegend] := cOglFont.Create('Legend', 1.65, $FF303030, False);
  fFonts[cfDebug] := cOglFont.Create('Debug', 1.45, $FF806020, False);
end;

destructor cOglFontMng.Destroy;
var
  lKind: cChartFontKind;
begin
  // Уничтожаем каждый шрифт в массиве
  for lKind := Low(cChartFontKind) to High(cChartFontKind) do
    fFonts[lKind].Free;
  inherited Destroy;
end;

function cOglFontMng.Font(AKind: cChartFontKind): cOglFont;
begin
  Result := fFonts[AKind];
end;

end.
