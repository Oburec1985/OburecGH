unit u3dOpenGLRenderer;

interface

uses
  Windows, SysUtils, OpenGL, u3dContracts;

type
  T3dOpenGLRenderer = class(TInterfacedObject, I3dRenderer)
  private
    fWindowHandle: HWND;
    fDeviceContext: HDC;
    fRenderContext: HGLRC;
    fWidth: Integer;
    fHeight: Integer;
    procedure Activate;
    procedure ConfigurePixelFormat;
    procedure ApplyProjection;
  protected
    procedure DrawScene; virtual;
  public
    destructor Destroy; override;
    procedure Attach(const AWindowHandle: NativeUInt;
      const AWidth, AHeight: Integer);
    procedure Resize(const AWidth, AHeight: Integer);
    procedure Render;
    procedure Detach;
  end;

implementation

procedure T3dOpenGLRenderer.ConfigurePixelFormat;
var
  lFormat: Integer;
  lDescriptor: TPixelFormatDescriptor;
begin
  if GetPixelFormat(fDeviceContext) <> 0 then
    Exit;
  FillChar(lDescriptor, SizeOf(lDescriptor), 0);
  lDescriptor.nSize := SizeOf(lDescriptor);
  lDescriptor.nVersion := 1;
  lDescriptor.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
    PFD_DOUBLEBUFFER;
  lDescriptor.iPixelType := PFD_TYPE_RGBA;
  lDescriptor.cColorBits := 24;
  lDescriptor.cDepthBits := 24;
  lDescriptor.iLayerType := PFD_MAIN_PLANE;
  lFormat := ChoosePixelFormat(fDeviceContext, @lDescriptor);
  if (lFormat = 0) or
     not SetPixelFormat(fDeviceContext, lFormat, @lDescriptor) then
    RaiseLastOSError;
end;

destructor T3dOpenGLRenderer.Destroy;
begin
  Detach;
  inherited;
end;

procedure T3dOpenGLRenderer.Attach(const AWindowHandle: NativeUInt;
  const AWidth, AHeight: Integer);
begin
  if fRenderContext <> 0 then
    raise Exception.Create('OpenGL renderer is already attached');
  fWindowHandle := HWND(AWindowHandle);
  fDeviceContext := GetDC(fWindowHandle);
  if fDeviceContext = 0 then
    RaiseLastOSError;
  try
    ConfigurePixelFormat;
    fRenderContext := wglCreateContext(fDeviceContext);
    if fRenderContext = 0 then
      RaiseLastOSError;
    Resize(AWidth, AHeight);
  except
    Detach;
    raise;
  end;
end;

procedure T3dOpenGLRenderer.Activate;
begin
  if (fDeviceContext = 0) or (fRenderContext = 0) then
    raise Exception.Create('OpenGL renderer is not attached');
  if not wglMakeCurrent(fDeviceContext, fRenderContext) then
    RaiseLastOSError;
end;

procedure T3dOpenGLRenderer.ApplyProjection;
var
  lAspect: Double;
begin
  Activate;
  glViewport(0, 0, fWidth, fHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  lAspect := fWidth / fHeight;
  glOrtho(-lAspect, lAspect, -1, 1, -10, 10);
  glMatrixMode(GL_MODELVIEW);
end;

procedure T3dOpenGLRenderer.Resize(const AWidth, AHeight: Integer);
begin
  fWidth := AWidth;
  if fWidth < 1 then
    fWidth := 1;
  fHeight := AHeight;
  if fHeight < 1 then
    fHeight := 1;
  if fRenderContext <> 0 then
    ApplyProjection;
end;

procedure T3dOpenGLRenderer.DrawScene;
begin
  glBegin(GL_LINES);
  glColor3f(1, 0, 0);
  glVertex3f(0, 0, 0);
  glVertex3f(0.8, 0, 0);
  glColor3f(0, 1, 0);
  glVertex3f(0, 0, 0);
  glVertex3f(0, 0.8, 0);
  glColor3f(0, 0, 1);
  glVertex3f(0, 0, 0);
  glVertex3f(0, 0, 0.8);
  glEnd;
end;

procedure T3dOpenGLRenderer.Render;
begin
  Activate;
  glEnable(GL_DEPTH_TEST);
  glClearColor(0.08, 0.08, 0.1, 1);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  DrawScene;
  SwapBuffers(fDeviceContext);
end;

procedure T3dOpenGLRenderer.Detach;
begin
  if fRenderContext <> 0 then
  begin
    if wglGetCurrentContext = fRenderContext then
      wglMakeCurrent(0, 0);
    wglDeleteContext(fRenderContext);
    fRenderContext := 0;
  end;
  if (fDeviceContext <> 0) and (fWindowHandle <> 0) then
  begin
    ReleaseDC(fWindowHandle, fDeviceContext);
    fDeviceContext := 0;
  end;
  fWindowHandle := 0;
end;

end.
