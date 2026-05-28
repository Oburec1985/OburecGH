unit uOglChartDrawObj;

{$mode objfpc}{$H+}

interface

uses
  uOglChartBaseObj;

type
  TChartPoint = record
    X: Double;
    Y: Double;
  end;

  TChartFloatRect = record
    Left: Double;
    Top: Double;
    Right: Double;
    Bottom: Double;
  end;

  TChartPixelRect = record
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
  end;

  { cDrawObj
    Базовый отрисовываемый объект. Координаты FloatRect нормализованы
    относительно родительской области, а конкретный renderer переводит их в пиксели. }
  cDrawObj = class(cBaseObj)
  private
    fVisible: Boolean;
    fColor: Cardinal;
    fFloatRect: TChartFloatRect;
  public
    procedure AssignDefaultProperties; override;
    procedure SetFloatRect(ALeft, ATop, ARight, ABottom: Double);

    property Visible: Boolean read fVisible write fVisible;
    property Color: Cardinal read fColor write fColor;
    property FloatRect: TChartFloatRect read fFloatRect write fFloatRect;
  end;

  { cMoveObj
    Основа интерактивных объектов: выбранность, перемещение и resize.
    Низкоуровневые события мыши будут делегироваться сюда позже. }
  cMoveObj = class(cDrawObj)
  private
    fSelected: Boolean;
    fCanMove: Boolean;
    fCanResize: Boolean;
    fLocked: Boolean;
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

procedure cDrawObj.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  fVisible := True;
  fColor := $FF000000;
  SetFloatRect(0.04, 0.06, 0.96, 0.94);
end;

procedure cDrawObj.SetFloatRect(ALeft, ATop, ARight, ABottom: Double);
begin
  fFloatRect.Left := ALeft;
  fFloatRect.Top := ATop;
  fFloatRect.Right := ARight;
  fFloatRect.Bottom := ABottom;
end;

procedure cMoveObj.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  fSelected := False;
  fCanMove := True;
  fCanResize := True;
  fLocked := False;
end;

end.
