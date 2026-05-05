unit uOglChartControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLIntf, LCLType, Controls, OpenGLContext, SyncObjs,
  uOglChartTypes, uOglChartModel;

type
  { TOglChartControl - LCL-компонент для отображения графиков через OpenGL.
    Наследуется от TOpenGLControl для кроссплатформенного управления контекстом. }
  TOglChartControl = class(TOpenGLControl, IOpenGLContextHost)
  private
    fObjectManager: TChartObjectManager;
    fRenderer: IChartRenderer;
    fLock: TCriticalSection;
    fIsInitialized: Boolean;
    
    function GetModel: TChartModel;
    procedure SetModel(AValue: TChartModel);
  protected
    procedure Paint; override;
    procedure Resize; override;
    
    { IOpenGLContextHost }
    procedure MakeCurrent; reintroduce;
    procedure SwapBuffers; reintroduce;
    function GetWidth: Integer;
    function GetHeight: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateChart; // Потокобезопасный вызов перерисовки

    property Model: TChartModel read GetModel write SetModel;
    property ObjectManager: TChartObjectManager read fObjectManager;
    property Renderer: IChartRenderer read fRenderer write fRenderer;
  end;

implementation

{ TOglChartControl }

constructor TOglChartControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fLock := TCriticalSection.Create;
  fObjectManager := TChartObjectManager.Create;
  fIsInitialized := False;
  
  // Настройки по умолчанию для OpenGLContext
  AutoResizeViewport := True;
end;

destructor TOglChartControl.Destroy;
begin
  fLock.Enter;
  try
    FreeAndNil(fObjectManager);
  finally
    fLock.Leave;
  end;
  FreeAndNil(fLock);
  inherited Destroy;
end;

function TOglChartControl.GetModel: TChartModel;
begin
  Result := fObjectManager.Root;
end;

procedure TOglChartControl.SetModel(AValue: TChartModel);
begin
  fLock.Enter;
  try
    fObjectManager.SetRoot(AValue);
  finally
    fLock.Leave;
  end;
  InvalidateChart;
end;

procedure TOglChartControl.Paint;
begin
  if not fIsInitialized then
  begin
    if Assigned(fRenderer) then
      fRenderer.Initialize(Self as IOpenGLContextHost);
    fIsInitialized := True;
  end;

  if Assigned(fRenderer) then
  begin
    inherited MakeCurrent;
    fLock.Enter;
    try
      fRenderer.Render(Model);
    finally
      fLock.Leave;
    end;
    inherited SwapBuffers;
  end;
end;

procedure TOglChartControl.Resize;
begin
  inherited Resize;
  if Assigned(fRenderer) then
  begin
    inherited MakeCurrent;
    fRenderer.Resize(Width, Height);
  end;
end;

procedure TOglChartControl.MakeCurrent;
begin
  inherited MakeCurrent;
end;

procedure TOglChartControl.SwapBuffers;
begin
  inherited SwapBuffers;
end;

function TOglChartControl.GetWidth: Integer;
begin
  Result := Width;
end;

function TOglChartControl.GetHeight: Integer;
begin
  Result := Height;
end;

procedure TOglChartControl.InvalidateChart;
begin
  { Метод Invalidate в LCL обычно потокобезопасен (через PostMessage), 
    но для гарантии можно использовать явный вызов через очередь сообщений 
    или TThread.ForceQueue если мы не в основном потоке. }
  if TThread.CurrentThread.ThreadID = MainThreadID then
    Invalidate
  else
    TThread.Queue(nil, @Invalidate);
end;

end.
