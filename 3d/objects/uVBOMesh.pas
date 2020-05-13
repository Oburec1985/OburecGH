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

  // ����� ��� ������ cVBOBufferData
  cBatch = class
  private
    textured:boolean;
    //����� ������ � ������
    size, pointercount:cardinal;
    // ������ ��������
    pointers: array of tface;
    // ������ ������
    Data:array of single;
    // ������������� ���������� ������
    ID:batchID;
  private
    // ������������� �������� �����
    procedure preparedata(mesh:cmesh);
  public
    // ������� ��������� ����� �� ������ ���������� � mesh
    constructor create(mesh:cmesh);
    // ������� ��������� ����� �� ������ ���������� � mesh
    destructor destroy;
    // ��������������
    procedure apply(textured:boolean);
  end;

  // ����� ���������������� ��� ��������� ������ ���������
  cARBMesh = class(cMesh)
  private
    batch:cBatch;
  protected
    // ���������� ���������
    procedure drawgeometrie(textured:boolean);override;
  public
    destructor destroy;override;
    // ���������� ���������� ������
    procedure prepareVertexBuffer;override;
  end;

implementation
const

   beginnormal = 2;
   beginvertex = 5;
   begintexture = 0;

constructor cBatch.create(mesh: cMesh);
begin
  // ������������� ��������� �����
  preparedata(mesh);
  // ������� ������������� ������ (���������� ������)
  glGenBuffersARB (2, @id);
  // ������� ���� �� ��������� �����
  glBindBufferARB(GL_ARRAY_BUFFER_ARB, id.vertex);
  // ���������� ������ � ������ ����������
  glBufferDataARB(GL_ARRAY_BUFFER_ARB, size*8*sizeof(single), data, GL_STATIC_DRAW_ARB);
  // ������� ���� �� ��������� � ������
  glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, id.pointers);
  // ���������� ������ � ������ ����������
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
  // �������� ������
  setlength(data,size*8*sizeof(glfloat));
  for I := 0 to size - 1 do
  begin
    p:=i*8;// ����� �������
    // ���������� ����������
    Data[p]:=mesh.TexVertexArray[i][0];
    Data[p+1]:=mesh.TexVertexArray[i][1];
    // �������
    Data[p+2]:=mesh.DrawNormals[i][0];
    Data[p+3]:=mesh.DrawNormals[i][1];
    Data[p+4]:=mesh.DrawNormals[i][2];
    // ��� �������
    Data[p+5]:=mesh.drawarray[i][0];
    Data[p+6]:=mesh.drawarray[i][1];
    Data[p+7]:=mesh.drawarray[i][2];
  end;
  pointercount:=length(mesh.FaceArray)*3;
  pointers:=@mesh.FaceArray[0];
end;

procedure cBatch.apply(textured:boolean);
begin
  // ��������� ��������� ������
  glEnableClientState(GL_VERTEX_ARRAY);
  // ����������� ������� ������
  glBindBufferARB( GL_ARRAY_BUFFER_ARB, id.vertex );
  // ��������� ��������� �� ��������
  glBindBufferARB( GL_ELEMENT_ARRAY_BUFFER_ARB, id.pointers );
  {glVertexPointer(3, GL_FLOAT, 0,nil);
  // ��������� ��������
  glEnableClientState(GL_NORMAL_ARRAY);
  glNormalPointer(3, 5, nil);
  // ��������� ���������� ��������
  if textured then
  begin
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer( 2, GL_FLOAT, 6,nil);
  end;}
  //������ ������ ������ ��� ����c����
  if not textured then
    glInterleavedArrays( GL_T2F_N3F_V3F, 0,0)
  else
    glInterleavedArrays( GL_T2F_N3F_V3F, 0,0);
  // ��������� ������� ����������
  glDrawElements(GL_Triangles,pointercount,GL_UNSIGNED_INT,0);
  //��������� �������
  glDisableClientState(GL_VERTEX_ARRAY);
  // ��������� ����� ������ � ���������� ��������� �������
  glBindBufferARB( GL_ARRAY_BUFFER_ARB, 0 );
  glBindBufferARB( GL_ELEMENT_ARRAY_BUFFER_ARB, 0 );  
  //if textured then
  //  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
end;

// ���������� ���������� ������
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
