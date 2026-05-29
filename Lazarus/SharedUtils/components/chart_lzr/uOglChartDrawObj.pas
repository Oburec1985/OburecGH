unit uOglChartDrawObj;

{$mode objfpc}{$H+}

{
  Модуль uOglChartDrawObj
  Описание: Содержит базовые типы координат (точки, прямоугольники) и классы cDrawObj, cMoveObj,
            которые лежат в основе визуальных и интерактивных элементов интерфейса чарта.
}

interface

uses
  uOglChartBaseObj;

type
  { TChartPoint }
  // Точка на графике (вещественные координаты X, Y)
  TChartPoint = record
    X: Double;
    Y: Double;
  end;

  { TChartFloatRect }
  // Прямоугольник в нормализованных координатах [0..1]
  TChartFloatRect = record
    Left: Double;
    Top: Double;
    Right: Double;
    Bottom: Double;
  end;

  { TChartPixelRect }
  // Прямоугольник в экранных пикселях
  TChartPixelRect = record
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
  end;

  { cDrawObj }
  // Базовый отрисовываемый объект. Координаты FloatRect нормализованы
  // относительно родительской области, а конкретный renderer переводит их в пиксели.
  cDrawObj = class(cBaseObj)
  private
    fVisible: Boolean;                   // Флаг видимости объекта
    fColor: Cardinal;                    // Цвет объекта (RGBA формат)
    fFloatRect: TChartFloatRect;        // Нормализованные координаты объекта
  public
    // Установка свойств по умолчанию
    procedure AssignDefaultProperties; override;
    // Установка координат нормализованного прямоугольника объекта
    procedure SetFloatRect(ALeft, ATop, ARight, ABottom: Double);

    property Visible: Boolean read fVisible write fVisible;
    property Color: Cardinal read fColor write fColor;
    property FloatRect: TChartFloatRect read fFloatRect write fFloatRect;
  end;

  { cMoveObj }
  // Основа интерактивных объектов: выбранность, перемещение и изменение размера (resize).
  // Низкоуровневые события мыши делегируются сюда через листенеры.
  cMoveObj = class(cDrawObj)
  private
    fSelected: Boolean;                  // Флаг выделения объекта
    fCanMove: Boolean;                   // Разрешено ли перемещение
    fCanResize: Boolean;                 // Разрешено ли изменение размеров
    fLocked: Boolean;                    // Заблокирован ли объект для интерактивных изменений
  public
    procedure AssignDefaultProperties; override;

    property Selected: Boolean read fSelected write fSelected;
    property CanMove: Boolean read fCanMove write fCanMove;
    property CanResize: Boolean read fCanResize write fCanResize;
    property Locked: Boolean read fLocked write fLocked;
  end;

  TChartDrawObject = cDrawObj;
  TChartMoveObject = cMoveObj;

implementation

{ cDrawObj }

/// <summary>
/// Задание базовых свойств видимости и координат по умолчанию.
/// </summary>
procedure cDrawObj.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  fVisible := True;
  fColor := $FF000000; // Черный цвет
  SetFloatRect(0.04, 0.06, 0.96, 0.94);
end;

/// <summary>
/// Устанавливает нормализованные координаты прямоугольника объекта.
/// </summary>
procedure cDrawObj.SetFloatRect(ALeft, ATop, ARight, ABottom: Double);
begin
  fFloatRect.Left := ALeft;
  fFloatRect.Top := ATop;
  fFloatRect.Right := ARight;
  fFloatRect.Bottom := ABottom;
end;

{ cMoveObj }

/// <summary>
/// Установка интерактивных свойств объекта по умолчанию.
/// </summary>
procedure cMoveObj.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  fSelected := False;
  fCanMove := True;
  fCanResize := True;
  fLocked := False;
end;

end.
