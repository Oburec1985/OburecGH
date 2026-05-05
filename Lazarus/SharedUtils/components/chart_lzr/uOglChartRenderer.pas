unit uOglChartRenderer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, gl, uOglChartTypes, uOglChartModel;

type
  { TOpenGLChartRenderer - реализация рендера через OpenGL.
    Отвечает за трансляцию объектов модели в графические примитивы. }
  TOpenGLChartRenderer = class(TInterfacedObject, IChartRenderer)
  private
    fHost: IOpenGLContextHost;
  public
    procedure Initialize(AHost: IOpenGLContextHost);
    procedure Resize(AWidth, AHeight: Integer);
    procedure Render(AModel: TObject);
  end;

implementation

{ TOpenGLChartRenderer }

procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  // Базовая настройка OpenGL
  fHost.MakeCurrent;
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;

procedure TOpenGLChartRenderer.Resize(AWidth, AHeight: Integer);
begin
  if AHeight = 0 then AHeight := 1;
  glViewport(0, 0, AWidth, AHeight);
end;

procedure TOpenGLChartRenderer.Render(AModel: TObject);
var
  lColor: Cardinal;
  r, g, b, a: Single;
  lModel: TChartModel;
begin
  if not Assigned(AModel) or not (AModel is TChartModel) then Exit;
  lModel := TChartModel(AModel);

  // Извлекаем цвет фона из модели
  lColor := lModel.BackgroundColor;
  r := (lColor and $000000FF) / 255;
  g := ((lColor and $0000FF00) shr 8) / 255;
  b := ((lColor and $00FF0000) shr 16) / 255;
  a := ((lColor and $FF000000) shr 24) / 255;

  glClearColor(r, g, b, a);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  // Здесь в будущем будет обход дерева объектов
end;

end.
