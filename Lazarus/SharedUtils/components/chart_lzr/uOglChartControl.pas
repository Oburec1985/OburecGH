unit uOglChartControl;

{$mode objfpc}{$H+}
{$codepage UTF8}

{
  Модуль uOglChartControl
  Описание: Содержит визуальный компонент TOglChartControl, основанный на TOpenGLControl.
            Связывает логическую модель TChartModel, менеджер объектов TChartObjectManager
            и рендерер IChartRenderer для отрисовки графиков в окне LCL.
}

interface

uses
  Classes, SysUtils, LCLIntf, LCLType, Controls, OpenGLContext, SyncObjs,
  uOglChartTypes, uOglChartChart, uOglChartMng;

type
  { TOglChartControl }
  // LCL-компонент для отображения графиков через OpenGL.
  // Наследуется от TOpenGLControl для кроссплатформенного управления графическим контекстом.
  TOglChartControl = class(TOpenGLControl, IOpenGLContextHost)
  private
    fObjectManager: TChartObjectManager; // Менеджер объектов модели чарта
    fRenderer: IChartRenderer;           // Рендерер для отрисовки графиков
    fLock: TCriticalSection;             // Критическая секция для потокобезопасности при изменении модели
    fIsInitialized: Boolean;             // Флаг инициализации OpenGL контекста
    
    function GetModel: TChartModel;
    procedure SetModel(AValue: TChartModel);
  protected
    // Основная процедура отрисовки компонента
    procedure Paint; override;
    // Обработчик изменения размеров компонента
    procedure Resize; override;
    
    { IOpenGLContextHost }
    // Активирует текущий контекст OpenGL для потока
    procedure MakeCurrent; reintroduce;
    // Переключает передний и задний буферы кадра
    procedure SwapBuffers; reintroduce;
    function GetWidth: Integer;
    function GetHeight: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Потокобезопасный вызов перерисовки компонента
    procedure InvalidateChart;

    property Model: TChartModel read GetModel write SetModel;
    property ObjectManager: TChartObjectManager read fObjectManager;
    property Renderer: IChartRenderer read fRenderer write fRenderer;
  end;

implementation

{ TOglChartControl }

/// <summary>
/// Создание контрола чарта с настройками контекста OpenGL по умолчанию.
/// </summary>
constructor TOglChartControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fLock := TCriticalSection.Create;
  fObjectManager := TChartObjectManager.Create;
  fIsInitialized := False;
  
  // Настройки по умолчанию для OpenGLContext
  AutoResizeViewport := True;
end;

/// <summary>
/// Безопасное освобождение менеджера объектов и критической секции.
/// </summary>
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

/// <summary>
/// Отрисовка чарта. При первом вызове инициализирует рендерер.
/// Гарантирует MakeCurrent и SwapBuffers для корректной работы буферов кадра.
/// </summary>
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

/// <summary>
/// Обновление вьюпорта при изменении геометрии контрола.
/// </summary>
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

/// <summary>
/// Потокобезопасный вызов перерисовки. Если вызов происходит не из основного GUI-потока,
/// выполнение перенаправляется в очередь TThread.Queue.
/// </summary>
procedure TOglChartControl.InvalidateChart;
begin
  { Метод Invalidate в LCL обычно потокобезопасен (через PostMessage), 
    но для гарантии мы используем явный вызов через TThread.Queue, 
    если мы находимся не в основном потоке. }
  if TThread.CurrentThread.ThreadID = MainThreadID then
    Invalidate
  else
    TThread.Queue(nil, @Invalidate);
end;

end.
