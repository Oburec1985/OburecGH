unit uVBOMesh;

interface
uses
  Windows, Classes, MathFunction, TextureGl, uMaterial,
  SysUtils, uObjectTypes, uEventList, uVectorList, uMesh, //uOglExpFunc,
  dglOpenGl;

type
  tface = record
    first,
    second,
    third:cardinal;
  end;

  batchID = record
    vertex:GLUint;
    pointers:GLUint;
  end;

  // Класс для работы cVBOBufferData
  cBatch = class
  private
    textured:boolean;
    //число вершин в буфере
    size, pointercount:cardinal;
    // массив индексов
    pointers: array of tface;
    // массив вершин
    Data:array of single;
    // идентификатор вершинного буфера
    ID:batchID;
  private
    // заготавливаем вершинны буфер
    procedure preparedata(mesh:cmesh);
  public
    // Создает вершинный буфер из данных хранящихся в mesh
    constructor create(mesh:cmesh);
    // Создает вершинный буфер из данных хранящихся в mesh
    destructor destroy;
    // активизировать
    procedure apply(textured:boolean);
  end;

  // класс оптимизированной для отрисовки видяхо геометрии
  cARBMesh = class(cMesh)
  private
    batch:cBatch;
  protected
    // Отрисовать геометрию
    procedure drawgeometrie(textured:boolean);override;
  public
    destructor destroy;override;
    // Подготовка вершинного буфера
    procedure prepareVertexBuffer;override;
  end;

implementation
const

   beginnormal = 2;
   beginvertex = 5;
   begintexture = 0;

constructor cBatch.create(mesh: cMesh);
begin
  // заготавливаем вершинный буфер
  preparedata(mesh);
  // Создаем идентификатор буфера (фактически ссылка)
  glGenBuffersARB (2, @id);
  // злобный бинд на вершинный буфер
  glBindBufferARB(GL_ARRAY_BUFFER_ARB, id.vertex);
  // Записываем данные в память видеокарты
  glBufferDataARB(GL_ARRAY_BUFFER_ARB, size*8*sizeof(single), data, GL_STATIC_DRAW_ARB);
  // злобный бинд на указатели к фейсам
  glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, id.pointers);
  // Записываем данные в память видеокарты
  glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB, pointercount*sizeof(cardinal), pointers, GL_STATIC_DRAW_ARB);
end;

destructor cBatch.destroy;
begin
//  glDeleteBuffersARB(1,@id.vertex);
end;

procedure cBatch.preparedata(mesh:cmesh);
var i,p:integer;
begin
  size:=length(mesh.DrawArray);
  // выделяем память
  setlength(data,size*8*sizeof(glfloat));
  for I := 0 to size - 1 do
  begin
    p:=i*8;// номер вершины
    // текстурные координаты
    Data[p]:=mesh.TexVertexArray[i][0];
    Data[p+1]:=mesh.TexVertexArray[i][1];
    // нормаль
    Data[p+2]:=mesh.DrawNormals[i][0];
    Data[p+3]:=mesh.DrawNormals[i][1];
    Data[p+4]:=mesh.DrawNormals[i][2];
    // сам вертекс
    Data[p+5]:=mesh.drawarray[i][0];
    Data[p+6]:=mesh.drawarray[i][1];
    Data[p+7]:=mesh.drawarray[i][2];
  end;
  pointercount:=length(mesh.FaceArray)*3;
  pointers:=@mesh.FaceArray[0];
end;

procedure cBatch.apply(textured:boolean);
begin
  // Включение вершинных данных
  glEnableClientState(GL_VERTEX_ARRAY);
  // Подключение массива вершин
  glBindBufferARB( GL_ARRAY_BUFFER_ARB, id.vertex );
  // включение отрисовки по индексам
  glBindBufferARB( GL_ELEMENT_ARRAY_BUFFER_ARB, id.pointers );
  {glVertexPointer(3, GL_FLOAT, 0,nil);
  // Включение нормалей
  glEnableClientState(GL_NORMAL_ARRAY);
  glNormalPointer(3, 5, nil);
  // Включение текстурных кординат
  if textured then
  begin
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer( 2, GL_FLOAT, 6,nil);
  end;}
  //ставлю формат вершин для отриcовки
  if not textured then
    glInterleavedArrays( GL_T2F_N3F_V3F, 0,0)
  else
    glInterleavedArrays( GL_T2F_N3F_V3F, 0,0);
  // Включение массива указателей
  glDrawElements(GL_Triangles,pointercount,GL_UNSIGNED_INT,0);
  //выключаем массивы
  glDisableClientState(GL_VERTEX_ARRAY);
  // отключаем режим работы с аппаратным вершинным буфером
  glBindBufferARB( GL_ARRAY_BUFFER_ARB, 0 );
  glBindBufferARB( GL_ELEMENT_ARRAY_BUFFER_ARB, 0 );  
  //if textured then
  //  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
end;

// Подготовка вершинного буфера
procedure cARBMesh.prepareVertexBuffer;
begin
  batch:=cBatch.create(self);
end;

procedure cARBMesh.drawgeometrie(textured:boolean);
begin
  batch.apply(textured);
end;

destructor cARBMesh.destroy;
begin
  batch.destroy;
  inherited;
end;

end.
