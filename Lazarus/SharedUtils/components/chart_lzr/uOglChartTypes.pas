unit uOglChartTypes;

{ Интерфейсы и специфичные типы компонента OglChart.
  Общие геометрические типы (point2, point2d, fRectd и др.) берём
  из uCommonTypes — не переопределяем здесь. }

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  { Интерфейс хоста OpenGL-контекста.
    Отделяет логику рендера от конкретного LCL-контрола. }
  IOpenGLContextHost = interface
    ['{8A5D6E7F-1234-4567-8901-ABCDEFABCDEF}']
    procedure MakeCurrent;
    procedure SwapBuffers;
    function GetWidth: Integer;
    function GetHeight: Integer;
  end;

  { Интерфейс рендера графика. }
  IChartRenderer = interface
    ['{B1C2D3E4-5678-90AB-CDEF-1234567890AB}']
    procedure Initialize(AHost: IOpenGLContextHost);
    procedure Resize(AWidth, AHeight: Integer);
    procedure Render(AModel: TObject);
  end;

  { Интерфейс сериализатора модели. }
  IChartSerializer = interface
    ['{D5E6F7A8-B9C0-D1E2-F3A4-B5C6D7E8F9A0}']
    function SaveObject(AObject: TObject): string;
    procedure LoadObject(AObject: TObject; const AData: string);
  end;

  { Интерфейс для доступа к элементам управления графиком из слушателей }
  IChartControl = interface
    ['{C1D2E3F4-5678-90AB-CDEF-1234567890AB}']
    function GetRenderer: TObject;
    function GetModel: TObject;
    procedure Redraw;
  end;

implementation

end.
