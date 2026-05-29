unit uOglChartAxis;

{$mode objfpc}{$H+}

interface

uses
  uOglChartDrawObj;

type
  TChartAxisScale = (casLinear, casLog10);

  { cAxis }
  /// <summary>
  /// Класс оси графика. Задаёт систему координат, масштабы и границы
  /// для всех дочерних графиков/трендов.
  /// </summary>
  cAxis = class(cMoveObj)
  private
    fScale: TChartAxisScale;             // Режим масштаба оси Y (линейный или логарифм)
    fMinValue: Double;                   // Минимальное значение оси Y
    fMaxValue: Double;                   // Максимальное значение оси Y
    fUseOwnX: Boolean;                  // Флаг использования индивидуального масштаба X для этой оси
    fXMinValue: Double;                 // Индивидуальный минимум X
    fXMaxValue: Double;                 // Индивидуальный максимум X
    fXScale: TChartAxisScale;            // Индивидуальный масштаб X (линейный или логарифм)
  public
    procedure AssignDefaultProperties; override;

    /// <summary> Тип шкалы оси Y (линейная/логарифмическая). </summary>
    property Scale: TChartAxisScale read fScale write fScale;
    /// <summary> Минимум шкалы Y. </summary>
    property MinValue: Double read fMinValue write fMinValue;
    /// <summary> Максимум шкалы Y. </summary>
    property MaxValue: Double read fMaxValue write fMaxValue;
    /// <summary> Флаг включения собственной шкалы по оси X для этой оси. </summary>
    property UseOwnX: Boolean read fUseOwnX write fUseOwnX;
    /// <summary> Собственный минимум шкалы X. </summary>
    property XMinValue: Double read fXMinValue write fXMinValue;
    /// <summary> Собственный максимум шкалы X. </summary>
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    /// <summary> Тип собственной шкалы по оси X. </summary>
    property XScale: TChartAxisScale read fXScale write fXScale;
  end;

  TChartAxis = cAxis;

implementation

procedure cAxis.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Axis';
  Caption := 'Axis';
  fScale := casLinear;
  fMinValue := 0;
  fMaxValue := 1;
  fUseOwnX := False;
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
end;

end.
