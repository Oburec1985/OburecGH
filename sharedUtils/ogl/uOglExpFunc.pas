unit uOglExpFunc;

interface
uses opengl, windows;

procedure glTexCoordPointer (size: GLint; atype: GLenum;
          stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
procedure glVertexPointer (size: GLint; atype: GLenum;
          stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glNormalPointer (size: GLint; stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glColorPointer (size: GLint; atype: GLenum; stride: GLsizei;
          data: pointer); stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDrawArrays (mode: GLenum; first: GLint; count: GLsizei);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glEnableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDisableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDrawElements(mode: GLenum;count: GLsizei;
          GlType:GLEnum;data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glBindTexture(mode: GLenum; Texture:GLuint
          ); stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glGenTextures (n: GLsizei; textures: PGLuint);
          stdcall; external opengl32;
//---------------------------------------------------------------------
procedure glLightModeli (n: GLEnum; u: GLuint);
          stdcall; external opengl32;

// GL_ARB_vertex_buffer_object
// ѕараметр target задает тип данных, которые будет содержать буфер - информацию
// о вершинах (GL_ARRAY_BUFFER_ARB) или индексы в другие массивы (GL_ELEMENTS_ARRAY_BUFFER_ARB).
procedure glBindBufferARB (target: GLenum; buffer: GLuint); stdcall; external OpenGL32;
procedure glDeleteBuffersARB (n: GLsizei; const buffers: PGLuint); stdcall; external OpenGL32;
procedure glGenBuffersARB (n: GLsizei; buffers: PGLuint); stdcall; external OpenGL32;
procedure glIsBufferARB (buffer: GLuint); stdcall; external OpenGL32;
// ѕараметр target имеет тот же смысл, что и в команде glBindBufferARB. ѕараметры size и data задают
// размер буфера в байтах и указатель на область пам€ти, содержаща€ значени€, которые следует использовать
// дл€ инициализации данного вершинного буфера.
procedure glBufferDataARB (target: GLenum; size: GLsizei; const data: Pointer; usage: GLenum); stdcall; external OpenGL32;
// »змен€ет данные в уже заполненном буфере, параметр target имеет то же смысл что и в других подобных
// функци€х, offset Ц задает смещение в байтах относительно начала буфера, size - размер измен€емого блока данных в байтах, data Ц указатель на массив данных.
procedure glBufferSubDataARB (target: GLenum; offset: GLuint; size: GLsizei; const data: Pointer); stdcall; external OpenGL32;
procedure glGetBufferSubDataARB (target: GLenum; offset: GLuint; size: GLsizei; data: Pointer); stdcall; external OpenGL32;
function glMapBufferARB (target: GLenum; access: GLenum): Pointer; stdcall; external OpenGL32;
function glUnmapBufferARB (target: GLenum): GLboolean; stdcall; external OpenGL32;
procedure glGetBufferParameterivARB (target: GLenum; pname: GLenum; params: PGLint); stdcall; external OpenGL32;
function glGetBufferPointervARB (target: GLenum; pname: GLenum; params: Pointer): Pointer; stdcall; external OpenGL32;


const
  GL_VERTEX_ARRAY             = $8074;
  GL_COLOR_ARRAY              = $8076;
  GL_Normal_ARRAY             = $8075;
  GL_TEXTURE_COORD_ARRAY      = $8078;

  // ARB_vertex_buffer_object
  GL_ARRAY_BUFFER_ARB                               = $8892;
  GL_ELEMENT_ARRAY_BUFFER_ARB                       = $8893;
  GL_ARRAY_BUFFER_BINDING_ARB                       = $8894;
  GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB               = $8895;
  GL_VERTEX_ARRAY_BUFFER_BINDING_ARB                = $8896;
  GL_NORMAL_ARRAY_BUFFER_BINDING_ARB                = $8897;
  GL_COLOR_ARRAY_BUFFER_BINDING_ARB                 = $8898;
  GL_INDEX_ARRAY_BUFFER_BINDING_ARB                 = $8899;
  GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB         = $889A;
  GL_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB             = $889B;
  GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB       = $889C;
  GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB        = $889D;
  GL_WEIGHT_ARRAY_BUFFER_BINDING_ARB                = $889E;
  GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB         = $889F;
  GL_STREAM_DRAW_ARB                                = $88E0;
  GL_STREAM_READ_ARB                                = $88E1;
  GL_STREAM_COPY_ARB                                = $88E2;
  GL_STATIC_DRAW_ARB                                = $88E4;
  GL_STATIC_READ_ARB                                = $88E5;
  GL_STATIC_COPY_ARB                                = $88E6;
  GL_DYNAMIC_DRAW_ARB                               = $88E8;
  GL_DYNAMIC_READ_ARB                               = $88E9;
  GL_DYNAMIC_COPY_ARB                               = $88EA;
  GL_READ_ONLY_ARB                                  = $88B8;
  GL_WRITE_ONLY_ARB                                 = $88B9;
  GL_READ_WRITE_ARB                                 = $88BA;
  GL_BUFFER_SIZE_ARB                                = $8764;
  GL_BUFFER_USAGE_ARB                               = $8765;
  GL_BUFFER_ACCESS_ARB                              = $88BB;
  GL_BUFFER_MAPPED_ARB                              = $88BC;
  GL_BUFFER_MAP_POINTER_ARB                         = $88BD;

implementation



end.
