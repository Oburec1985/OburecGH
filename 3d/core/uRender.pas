// 1) RenderScene - отвечает за настройку сцены и вызов отрисовщиков объектов
// сцены
unit uRender;

interface

uses
  Windows, Messages, uCommonTypes, u3dTypes, uPlatformInfo, ueventlist, dglOpenGL,
  uglEventTypes, MathFunction, uMaterial, TextureGL, uBaseCamera, uSceneMng, uObject, uNodeObject;
  //Windows,Math,,uMeshObr,uShader,SysUtils,
  //ulight,uselectools, uScene, classes,uobject,messages,usimpleobjects,
  //ubasecamera,uConfigFile3d, uplatforminfo, uNodeObject,uObjectTypes,
  //dialogs, uCommonTypes, ;//

   //----------Настройки-------------------------------------------------
const
  // Включение теста глубины
  C_R_DepthTest = $000001;
  // Включение цвета материала
  C_R_ColorMaterial = $000002;
  // Нормировать нормали
  C_R_Normalize = $000004;
  // Включение режима отсечения граней
  C_R_CullFaceEnable = $000008;
  // Выбор отсекаемых граней (передние/ задние)
  C_R_CullFrontFace = $000010;
  C_R_CullBackFace = $000020;
  // Выбор положительного направления обхода граней
  C_R_FrontFace = $000040;
  C_R_EnableLight = $000080;

type
// ------------------------------------------------------------------
 cRender = class
   ui:tobject;
   p1,p2:point3;
   //-------------
   boundColor:point3;
   //
   m_wndContext:TWndContext;
   // менеджер шейдеров
   //m_shaderMng:cshaderManager;
   // Сцена
   scene:cscene;
   // Поддерживаемые расширения
   PlatformInfo:cPlatform;
   // менеджер текстур
   m_TexMng:cTextureManager;
   m_MatMng:cMaterialManager;
 public
   // Настройки окна
   settings:cardinal;
 public
 public
   // ссылка на список событий объекта cUInterface
   eventlist:ceventlist;
 private
   procedure initflags;
   procedure deletecontext;
   procedure setactivecamera(c:cbasecamera);
 public
   function GetActiveCamera:cBaseCamera;
   procedure LoadScene(name:string);
   procedure InitGL;
   Constructor Create(p_ui:tobject;Handle:THandle;ResourcesFile:string;p_EventList:cEventList);
   destructor destroy;
   //function  GetObjectsNames:TStringlist;
   procedure RenderScene;
   procedure invalidaterect;
   procedure GetGlContext(H:Hwnd);
   procedure ChangeSize;
 public
   property activecamera:cbasecamera read getactivecamera write setactivecamera;
 end;
implementation

procedure glGenTextures (n: GLsizei; textures: PGLuint); stdcall; external opengl32;

Constructor cRender.Create(p_ui:tobject;Handle:THandle;ResourcesFile:string;p_EventList:cEventList);
var str:string;
    pstr:pstring;
    i:integer;
begin
  ui:=p_ui;
  EventList:=p_EventList;
  //m_shaderMng:= cshaderManager.create;
  // Получаем пути к ресурсам
  //ConfigFile:=cCfgFile.create(ResourcesFile);
  // Отображение информации о поддерживаемых расширениях
  platforminfo:=cPlatform.create;

  m_TexMng:=cTextureManager.Create(PlatformInfo);
  m_MatMng := cMaterialManager.Create(m_TexMng);
  initflags;
  GetGlContext(Handle);
  Eventlist.CallAllEvents(E_glOnInitContext);
end;

destructor cRender.destroy;
begin
  deletecontext;
  m_MatMng.destroy;
  m_MatMng:=nil;
  m_TexMng.Destroy;
  m_TexMng:=nil;
  //m_shaderMng.destroy;
  PlatformInfo.destroy;
  PlatformInfo:=nil;
  inherited;
end;

procedure cRender.deletecontext;
begin
  //wglMakeCurrent(m_wndContext.dc,m_wndContext.hrc);
  //перед удалением контекста надо сбросить текущий контекст OpenGL подсистемы
  wglMakeCurrent(0, 0);
  //а теперь само удаление
  wglDeleteContext(m_wndContext.hrc);
end;

procedure cRender.ChangeSize;
var
  TMtype:GLUInt;
begin
  //----------Настройки камеры------------------------------------------
  GetClientRect(m_wndContext.Handle, m_wndContext.Bound);
  m_wndContext.axislength:=3;
  m_wndContext.ClientWidth:=abs(m_wndContext.Bound.Left-m_wndContext.Bound.Right);
  m_wndContext.ClientHeight:=abs(m_wndContext.Bound.Top-m_wndContext.Bound.Bottom);
  glViewport(0, 0, m_wndContext.ClientWidth, m_wndContext.ClientHeight);
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  if TMType = GL_MODELVIEW then
   glMatrixMode(GL_MODELVIEW);
  if TMType = GL_PROJECTION then
   glMatrixMode(GL_PROJECTION);
  invalidaterect;
end;

procedure cRender.invalidaterect;
begin
  postmessage(m_wndContext.handle,WM_PAINT,0,0);
end;

procedure ClearViewPort(color:point3);
begin
  //----------------------Очистка холста--------------------------------------
 glClearColor (color.x, color.y, color.z, 1.0);       // цвет фона
 glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);// очистка буфера цвета
 glLoadIdentity;
end;

Procedure cRender.RenderScene;
var
  ps:paintstruct;
  camera:cbasecamera;
  i:integer;
  obj:cnodeobject;
  projection:array [0..15] of gldouble; // матрица проекции.
begin
  if wglGetCurrentContext<>m_wndContext.hrc then
    wglMakeCurrent(m_wndContext.dc,m_wndContext.hrc);
  glViewport(0, 0, m_wndContext.ClientWidth, m_wndContext.ClientHeight);
  //======================Подготовка к рисованию=========================
  BeginPaint(m_wndContext.Handle,ps);
  ClearViewPort(m_wndContext.color);
  //---------------------------------------------------------------------------
  //glutSolidCube (1);
  scene.lights.setLights;
  camera:=GetActiveCamera;
  camera.setCamera;
  for i := 0 to scene.count-1 do
  begin
    obj:=cNodeObject(scene.getobj(i));
    if obj=nil then break;
    if obj is cobject then
    begin
      cObject(obj).draw;
      cObject(obj).drawbounds(boundColor);
    end;
  end;
  glGetDoublev(GL_PROJECTION_MATRIX,@projection); // узнаём матрицу проекции.
  // Вызов событий отрисовки сцены
  eventlist.CallAllEvents(E_glRenderScene);
  //---------------------------------------------------------------------------
  SwapBuffers(m_wndContext.dc);
  EndPaint(m_wndContext.Handle, PS);
end;

procedure cRender.initflags;
begin
 setflag(settings,c_r_DEPTHTEST);
 setflag(settings,c_r_COLORMATERIAL);
 setflag(settings,c_r_NORMALIZE);
 setflag(settings,C_R_CullFaceEnable);
 setflag(settings,C_R_CullBackFace);
 // GL_CCW/ GL_CW
 setflag(settings,C_R_FrontFace);
 setflag(settings,C_R_EnableLight);
end;

procedure cRender.LoadScene(name:string);
begin
  cscene(scene).LoadFile_Obr(name);
  invalidaterect;
end;

//=================== Инициация OpenGl =================================}
Procedure cRender.InitGL;
begin
 //----------Настройки-------------------------------------------------
 if checkflag(settings,C_R_EnableLight) then
   glEnable(gl_Lighting)
 else
   glDisable(gl_Lighting);
 if checkflag(settings,c_r_DEPTHTEST) then
   glEnable(GL_DEPTH_TEST)
 else
   glDisable(GL_DEPTH_TEST);
 if checkflag(settings,c_r_COLORMATERIAL) then
   glEnable (GL_COLOR_MATERIAL)
 else
   glDisable(GL_COLOR_MATERIAL);
 // Включить преобразование нормалей
 // при масштабировании
 if checkflag(settings,c_r_NORMALIZE) then
   glEnable (GL_NORMALIZE)
 else
   glDisable (GL_NORMALIZE);
 if checkflag(settings,C_R_CullFaceEnable) then
   GlEnable(GL_CULL_FACE)
 else
   glDisable (GL_CULL_FACE);
 if checkflag(settings,C_R_CullBackFace) then
   GlCullFace(GL_Back);
 if checkflag(settings,C_R_CullFrontFace) then
   GlCullFace(GL_Front);
 if checkflag(settings,C_R_FrontFace) then
   glFrontFace(GL_CCW)
 else
   glFrontFace(GL_CW);
 //----------Настройки камеры------------------------------------------
 changesize;
end;

//==========================Получение Gl контекста======================
procedure cRender.GetGlContext(H:Hwnd);
var nPixelFormat: Integer;
    pfd: TPixelFormatDescriptor;
    name:PChar;
    folder,shadername:string;
begin
 InitOpenGL;
 InitOpenGL('opengl32.dll','glu32.dll');
 m_wndContext.Handle:=H;
 m_wndContext.DC := GetDC (m_wndContext.Handle);
 m_wndContext.hrc:=CreateRenderingContext(m_wndContext.DC,[opDoubleBuffered], 32, 24, 8, 0, 0, 0 );
 ActivateRenderingContext(m_wndContext.DC, m_wndContext.hrc, true);

 wglMakeCurrent(m_wndContext.DC, m_wndContext.hrc);
 //-------------
 platforminfo.contextInit(nil);
 //--------Установка камеры,материалов и т.д.-------------
 InitGL;
 if platforminfo.CheckARBShaderExt then
 begin
   //shadername:=configfile.findShaderFile('toon');
   //if shadername<>'' then
   //  m_shaderMng.addShader(extractFilePath(shadername),'toon');
 end;
end;

function cRender.GetActiveCamera:cBaseCamera;
var i:integer;
    obj:cNodeObject;
begin
  result:=nil;
  if scene<>nil then
    result:=scene.getactivecamera;
end;

procedure cRender.setactivecamera(c:cbasecamera);
var cam:cBaseCamera;
begin
  cam:=activecamera;
  if cam<>nil then
    cam.active:=false;
  c.active:=true;
  invalidaterect;
end;


end.
