unit uOglChart;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs,
  OpenGLContext, uOglChartTypes, uOglChartChart, uOglChartMng, uOglChartRenderer,
  uOglChartFrameListener, uOglChartBaseObj;

type
  TChartAfterRenderEvent = procedure(Sender: TObject; ARenderTimeMs: Double) of object;
  { TOglChart - LCL/OpenGL-хост компонента графика.
    Хранит модель и делегирует отрисовку renderer-слою. }
  TOglChart = class(TOpenGLControl, IOpenGLContextHost, IChartControl)
  private
    fObjectManager: TChartObjectManager;
    fRenderer: IChartRenderer;
    fOpenGLRenderer: TOpenGLChartRenderer;
    fIsRendererInitialized: Boolean;
    fListeners: TList;
    fOnAfterRender: TChartAfterRenderEvent;

    function GetModel: TChartModel;
    procedure SetModel(AValue: TChartModel);
    function GetSelectedObject: cBaseObj;
    procedure SetSelectedObject(AValue: cBaseObj);
    function GetHoveredObject: cBaseObj;
    procedure SetHoveredObject(AValue: cBaseObj);
  protected
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Paint; override;
    procedure Redraw;

    procedure AddFrameListener(AListener: TChartFrameListener);
    procedure RemoveFrameListener(AListener: TChartFrameListener);

    { IChartControl }
    function GetRenderer: TObject;
    function GetModel: TObject;

    { IOpenGLContextHost }
    procedure MakeCurrent; reintroduce;
    procedure SwapBuffers; reintroduce;
    function GetWidth: Integer;
    function GetHeight: Integer;

    property Model: TChartModel read GetModel write SetModel;
    property OnAfterRender: TChartAfterRenderEvent read fOnAfterRender write fOnAfterRender;
    property ObjectManager: TChartObjectManager read fObjectManager;
    property Renderer: IChartRenderer read fRenderer write fRenderer;
    property SelectedObject: cBaseObj read GetSelectedObject write SetSelectedObject;
    property HoveredObject: cBaseObj read GetHoveredObject write SetHoveredObject;
  end;

procedure Register;

implementation

uses Windows;

procedure LogToFile(const AMsg: string);
var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;
end;

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

  fListeners := TList.Create;
  AddFrameListener(TChartPanZoomListener.Create);
  AddFrameListener(TChartSelectListener.Create);
end;

destructor TOglChart.Destroy;
var
  I: Integer;
begin
  fRenderer := nil;
  fOpenGLRenderer := nil;
  FreeAndNil(fObjectManager);

  if Assigned(fListeners) then
  begin
    for I := 0 to fListeners.Count - 1 do
      TObject(fListeners[I]).Free;
    FreeAndNil(fListeners);
  end;

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
var
  lHandled: Boolean;
  I: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  SetFocus;

  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseDown(Self, Button, Shift, X, Y, lHandled);
      if lHandled then
        Break;
    end;

  if not lHandled and (Button = mbLeft) and Assigned(fOpenGLRenderer) and fOpenGLRenderer.MouseDown(X, Y, ssDouble in Shift) then
    Redraw;
end;

procedure TOglChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  lHandled: Boolean;
  I: Integer;
begin
  inherited MouseMove(Shift, X, Y);

  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseMove(Self, Shift, X, Y, lHandled);
      if lHandled then
        Break;
    end;
end;

procedure TOglChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lHandled: Boolean;
  I: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);

  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseUp(Self, Button, Shift, X, Y, lHandled);
      if lHandled then
        Break;
    end;
end;

function TOglChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  lHandled: Boolean;
  I: Integer;
  lClientPos: TPoint;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);

  lClientPos := ScreenToClient(MousePos);

  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).MouseWheel(Self, Shift, WheelDelta, lClientPos.X, lClientPos.Y, lHandled);
      if lHandled then
      begin
        Result := True;
        Break;
      end;
    end;
end;

procedure TOglChart.KeyDown(var Key: Word; Shift: TShiftState);
var
  lHandled: Boolean;
  I: Integer;
begin
  LogToFile('TOglChart.KeyDown: Key=' + IntToStr(Key));
  inherited KeyDown(Key, Shift);

  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).KeyDown(Self, Key, Shift, lHandled);
      if lHandled then
        Break;
    end;

  if not lHandled and Assigned(fOpenGLRenderer) and fOpenGLRenderer.KeyDown(Key) then
  begin
    Key := 0;
    Redraw;
  end;
end;

procedure TOglChart.KeyPress(var Key: char);
var
  lHandled: Boolean;
  I: Integer;
begin
  inherited KeyPress(Key);

  lHandled := False;
  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
    begin
      TChartFrameListener(fListeners[I]).KeyPress(Self, Key, lHandled);
      if lHandled then
        Break;
    end;

  if not lHandled and Assigned(fOpenGLRenderer) and fOpenGLRenderer.TextInput(Key) then
  begin
    Key := #0;
    Redraw;
  end;
end;

procedure TOglChart.Paint;
var
  I: Integer;
  lStart, lEnd, lFreq: Int64;
  lRenderTimeMs: Double;
begin
  inherited MakeCurrent;

  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
      TChartFrameListener(fListeners[I]).FrameStarted(Self);

  if Assigned(fRenderer) then
  begin
    if not fIsRendererInitialized then
    begin
      fRenderer.Initialize(Self as IOpenGLContextHost);
      fIsRendererInitialized := True;
    end;

    fRenderer.Resize(Width, Height);
    
    lFreq := 0;
    lStart := 0;
    lEnd := 0;
    QueryPerformanceFrequency(lFreq);
    QueryPerformanceCounter(lStart);
    
    fRenderer.Render(Model);
    
    QueryPerformanceCounter(lEnd);
    if lFreq > 0 then
      lRenderTimeMs := (lEnd - lStart) * 1000.0 / lFreq
    else
      lRenderTimeMs := 0;
      
    if Assigned(fOnAfterRender) then
      fOnAfterRender(Self, lRenderTimeMs);
  end;

  for I := 0 to fListeners.Count - 1 do
    if TChartFrameListener(fListeners[I]).Enabled then
      TChartFrameListener(fListeners[I]).FrameEnded(Self);

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


function TOglChart.GetSelectedObject: cBaseObj;
begin
  if Assigned(fOpenGLRenderer) then
    Result := fOpenGLRenderer.SelectedObject
  else
    Result := nil;
end;

procedure TOglChart.SetSelectedObject(AValue: cBaseObj);
begin
  if Assigned(fOpenGLRenderer) then
  begin
    fOpenGLRenderer.SelectedObject := AValue;
    Redraw;
  end;
end;

function TOglChart.GetHoveredObject: cBaseObj;
begin
  if Assigned(fOpenGLRenderer) then
    Result := fOpenGLRenderer.HoveredObject
  else
    Result := nil;
end;

procedure TOglChart.SetHoveredObject(AValue: cBaseObj);
begin
  if Assigned(fOpenGLRenderer) then
  begin
    fOpenGLRenderer.HoveredObject := AValue;
    Redraw;
  end;
end;

procedure TOglChart.AddFrameListener(AListener: TChartFrameListener);
begin
  if Assigned(AListener) and (fListeners.IndexOf(AListener) < 0) then
    fListeners.Add(AListener);
end;

procedure TOglChart.RemoveFrameListener(AListener: TChartFrameListener);
begin
  if Assigned(AListener) then
    fListeners.Remove(AListener);
end;

function TOglChart.GetRenderer: TObject;
begin
  Result := fOpenGLRenderer;
end;

function TOglChart.GetModel: TObject;
begin
  Result := Model;
end;


procedure Register;
begin
  RegisterComponents('Samples', [TOglChart]);
end;

end.
