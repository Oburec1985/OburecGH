unit uOglChartPage;

{$mode objfpc}{$H+}

{
  Модуль uOglChartPage
  Описание: Содержит класс cBasePage (TChartPage), представляющий страницу внутри чарта.
            Каждая страница имеет рамку, цвет фона, параметры выравнивания (Align, AlignWeight)
            и пиксельные отступы (PixelTabSpace) для внутренней области графиков.
}

interface

uses
  uOglChartDrawObj, uOglChartAxis;

type
  { TChartPageAlign }
  // Способы выравнивания/размещения страницы на экране
  TChartPageAlign = (
    cpaNone,     // Ручное позиционирование по нормализованным координатам
    cpaAuto,     // Автоматическое размещение в сетке (по умолчанию)
    cpaClient,   // Растягивание на всю доступную область PageArea
    cpaTop,      // Прижатие к верхнему краю (для будущего расширения)
    cpaBottom,   // Прижатие к нижнему краю
    cpaLeft,     // Прижатие к левому краю
    cpaRight     // Прижатие к правому краю
  );

  { cBasePage }
  // Страница чарта: содержит рамку, фон и полезную область сетки.
  // PixelTabSpace задаёт пиксельные отступы от рамки до вьюпорта графиков (для размещения подписей шкал).
  cBasePage = class(cMoveObj)
  private
    fAlign: TChartPageAlign;             // Тип выравнивания страницы
    fAlignWeight: Integer;               // Вес для выравнивания (используется при расчете пропорций ячейки)
    fBorderColor: Cardinal;              // Цвет границы страницы в формате RGBA
    fFillColor: Cardinal;                // Цвет заливки фона страницы в формате RGBA
    fBorderWidth: Single;                // Толщина линии границы
    fPixelTabSpace: TChartPixelRect;     // Пиксельные отступы от рамки до вьюпорта графиков (лево, верх, право, низ)
    fXMinValue: Double;                  // Минимальное значение шкалы X для всей страницы
    fXMaxValue: Double;                  // Максимальное значение шкалы X для всей страницы
    fXScale: TChartAxisScale;            // Тип шкалы X страницы (линейная/логарифм)
    fPresetMinXValue: Double;            // Преднастроенный минимум шкалы X
    fPresetMaxXValue: Double;            // Преднастроенный максимум шкалы X
    fHasPresetXRange: Boolean;           // Признак заданного преднастроенного диапазона X
    fZoomedX: Boolean;                   // Флаг того, что масштаб оси X изменен пользователем (зум/пан)
  public
    // Установка свойств страницы по умолчанию
    procedure AssignDefaultProperties; override;

    property Align: TChartPageAlign read fAlign write fAlign;
    property AlignWeight: Integer read fAlignWeight write fAlignWeight;
    property BorderColor: Cardinal read fBorderColor write fBorderColor;
    property FillColor: Cardinal read fFillColor write fFillColor;
    property BorderWidth: Single read fBorderWidth write fBorderWidth;
    property PixelTabSpace: TChartPixelRect read fPixelTabSpace write fPixelTabSpace;
    property XMinValue: Double read fXMinValue write fXMinValue;
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    property XScale: TChartAxisScale read fXScale write fXScale;
    property PresetMinXValue: Double read fPresetMinXValue write fPresetMinXValue;
    property PresetMaxXValue: Double read fPresetMaxXValue write fPresetMaxXValue;
    property HasPresetXRange: Boolean read fHasPresetXRange write fHasPresetXRange;
    property ZoomedX: Boolean read fZoomedX write fZoomedX;
  end;

  TChartPage = cBasePage;

implementation

{ cBasePage }

/// <summary>
/// Инициализация стандартных свойств страницы: серая рамка, белый фон, тип cpaAuto,
/// а также стандартные отступы PixelTabSpace под подписи осей координат (левый отступ 42 пикселя
/// для шкал значений Y, нижний отступ 24 пикселя для шкалы времени X).
/// </summary>
procedure cBasePage.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Page';
  Caption := 'Page';
  fBorderColor := $FF606060;
  fFillColor := $FFFFFFFF;
  fBorderWidth := 2;
  fPixelTabSpace.Left := 42;
  fPixelTabSpace.Top := 34;
  fPixelTabSpace.Right := 12;
  fPixelTabSpace.Bottom := 24;
  fAlign := cpaAuto;
  fAlignWeight := 1;
  SetFloatRect(0.04, 0.06, 0.96, 0.94);
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
  fPresetMinXValue := fXMinValue;
  fPresetMaxXValue := fXMaxValue;
  fHasPresetXRange := False;
  fZoomedX := False;
end;

end.
