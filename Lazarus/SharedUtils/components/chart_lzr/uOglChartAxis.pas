unit uOglChartAxis;

{$mode objfpc}{$H+}
{$codepage UTF8}

{
  Модуль uOglChartAxis
  Описание: базовый класс cAxis (TChartAxis), используемый для осей графика в компоненте TOglChart.
            Хранит диапазоны значений, масштаб и пресеты для зума.
}

interface

uses
  uOglChartDrawObj;

type
  { TChartAxisScale }
  // Тип шкалирования оси (линейная или логарифмическая)
  TChartAxisScale = (casLinear, casLog10);

  { cAxis }
  /// <summary>
  /// Класс оси графика. Хранит диапазоны значений, масштаб и пресеты
  /// для сброса пользовательского зума/панорамы.
  /// </summary>
  cAxis = class(cMoveObj)
  private
    fScale: TChartAxisScale;             // режим масштаба оси Y (линейный или логарифмический)
    fMinValue: Double;                   // минимальное значение оси Y
    fMaxValue: Double;                   // максимальное значение оси Y
    fUseOwnX: Boolean;                  // флаг использования независимого диапазона X для этой оси
    fXMinValue: Double;                 // независимый минимум X
    fXMaxValue: Double;                 // независимый максимум X
    fXScale: TChartAxisScale;            // независимый масштаб X (линейный или логарифмический)
    fPresetMinValue: Double;             // сохранённый минимум оси Y
    fPresetMaxValue: Double;             // сохранённый максимум оси Y
    fHasPresetRange: Boolean;            // признак наличия пользовательского диапазона Y
  public
    /// <summary>
    /// Устанавливает свойства оси по умолчанию.
    /// </summary>
    procedure AssignDefaultProperties; override;

    /// <summary> Тип шкалы оси Y (линейная/логарифмическая). </summary>
    property Scale: TChartAxisScale read fScale write fScale;
    /// <summary> Нижняя грань Y. </summary>
    property MinValue: Double read fMinValue write fMinValue;
    /// <summary> Верхняя грань Y. </summary>
    property MaxValue: Double read fMaxValue write fMaxValue;
    /// <summary> Флаг наличия собственного диапазона по оси X для этой оси. </summary>
    property UseOwnX: Boolean read fUseOwnX write fUseOwnX;
    /// <summary> Минимальное значение оси X. </summary>
    property XMinValue: Double read fXMinValue write fXMinValue;
    /// <summary> Максимальное значение оси X. </summary>
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    /// <summary> Тип масштабирования оси по оси X. </summary>
    property XScale: TChartAxisScale read fXScale write fXScale;
    property PresetMinValue: Double read fPresetMinValue write fPresetMinValue;
    property PresetMaxValue: Double read fPresetMaxValue write fPresetMaxValue;
    property HasPresetRange: Boolean read fHasPresetRange write fHasPresetRange;
  end;

  TChartAxis = cAxis;

procedure ChartAxisApplyUserValue(AAxis: TChartAxis; AIsMin: Boolean; AValue: Double);

implementation

{ cAxis }

/// <summary>
/// Задаёт значения по умолчанию для оси: линейный масштаб, диапазон [0..1] для X и Y.
/// </summary>
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
  fPresetMinValue := fMinValue;
  fPresetMaxValue := fMaxValue;
  fHasPresetRange := False;
end;

procedure ChartAxisApplyUserValue(AAxis: TChartAxis; AIsMin: Boolean; AValue: Double);
begin
  if AAxis = nil then
    Exit;
  if AIsMin then
  begin
    AAxis.MinValue := AValue;
    AAxis.PresetMinValue := AValue;
  end
  else
  begin
    AAxis.MaxValue := AValue;
    AAxis.PresetMaxValue := AValue;
  end;
  if AAxis.PresetMaxValue > AAxis.PresetMinValue then
    AAxis.HasPresetRange := True;
end;

end.
