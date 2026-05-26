unit uOglChart;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  OpenGLContext, uOglChartTypes, uOglChartChart, uOglChartMng, uOglChartRenderer;

type
  { TOglChart - LCL/OpenGL-хост компонента графика.
    Хранит модель и делегирует отрисовку renderer-слою. }
  TOglChart = class(TOpenGLControl, IOpenGLContextHost)
  private
    fObjectManager: TChartObjectManager;
    fRenderer: IChartRenderer;
    fOpenGLRenderer: TOpenGLChartRenderer;
    fIsRendererInitialized: Boolean;

    function GetModel: TChartModel;
    procedure SetModel(AValue: TChartModel);
  protected
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Paint; override;
    procedure Redraw;

    { IOpenGLContextHost }
    procedure MakeCurrent; reintroduce;
    procedure SwapBuffers; reintroduce;
    function GetWidth: Integer;
    function GetHeight: Integer;

    property Model: TChartModel read GetModel write SetModel;
    property ObjectManager: TChartObjectManager read fObjectManager;
    property Renderer: IChartRenderer read fRenderer write fRenderer;
  end;

procedure Register;

implementation

{ TOglChart }

constructor TOglChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoResizeViewport := True;
  TabStop := True;
  fOpenGLRenderer := TOpenGLChartRenderer.Create;
  fRenderer := fOpenGLRenderer;
  fObjectManager := TChartObjectManager.Create;
  fObjectManager.Root.BackgroundColor := $FFFFFFFF;
end;

destructor TOglChart.Destroy;
begin
  fRenderer := nil;
  fOpenGLRenderer := nil;
  FreeAndNil(fObjectManager);
  inherited Destroy;
end;

function TOglChart.GetModel: TChartModel;
begin
  Result := fObjectManager.Root;
end;

procedure TOglChart.SetModel(AValue: TChartModel);
begin
  fObjectManager.SetRoot(AValue);
  Redraw;
end;

procedure TOglChart.Resize;
begin
  inherited Resize;
  if Assigned(fRenderer) and fIsRendererInitialized then
  begin
    inherited MakeCurrent;
    fRenderer.Resize(Width, Height);
  end;
  Redraw;
end;

procedure TOglChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  SetFocus;
  if (Button = mbLeft) and Assigned(fOpenGLRenderer) and fOpenGLRenderer.MouseDown(X, Y) then
    Redraw;
end;

procedure TOglChart.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Assigned(fOpenGLRenderer) and fOpenGLRenderer.KeyDown(Key) then
  begin
    Key := 0;
    Redraw;
  end;
end;

procedure TOglChart.KeyPress(var Key: char);
begin
  inherited KeyPress(Key);
  if Assigned(fOpenGLRenderer) and fOpenGLRenderer.TextInput(Key) then
  begin
    Key := #0;
    Redraw;
  end;
end;

procedure TOglChart.Paint;
begin
  inherited MakeCurrent;

  if Assigned(fRenderer) then
  begin
    if not fIsRendererInitialized then
    begin
      fRenderer.Initialize(Self as IOpenGLContextHost);
      fIsRendererInitialized := True;
    end;

    fRenderer.Resize(Width, Height);
    fRenderer.Render(Model);
  end;

  inherited SwapBuffers;
end;

procedure TOglChart.Redraw;
begin
  Invalidate;
end;

procedure TOglChart.MakeCurrent;
begin
  inherited MakeCurrent;
end;

procedure TOglChart.SwapBuffers;
begin
  inherited SwapBuffers;
end;

function TOglChart.GetWidth: Integer;
begin
  Result := Width;
end;

function TOglChart.GetHeight: Integer;
begin
  Result := Height;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TOglChart]);
end;

end.
