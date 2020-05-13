// Модуль содержит класс отвечающий за текстурирование объекта
// Width, Heigth - длина и ширина текстуры
// pBits - указатель на загруженную текстуру
// LoadfromFile - метод загружающий текстуру из файла
// Enable - включение/ выключение текстурирования объекта

unit TextureGL;

interface

Uses
  Windows, Graphics, SysUtils, OpenGL, Math, dglOpenGl, dialogs, classes, jpeg, ueventlist, uPlatformInfo;

Type
  RGB=Record
    b,g,r: Byte;
  End;

  TPixels=Array[Word] of RGB;
  PPixels= ^TPixels;

  cTextureManager = class;

  TTextureGL = class
    Width,Height,
    maxwidth,maxHeight,// максимальные размеры текстуры используется только при загрузке
    level:Integer; // степень упрощения текстуры
  public
    events:ceventlist;
  protected
    flipvertical:boolean;
    texmng:cTextureManager;
    // имя текстуры
    fname:string;
    // текстура загружена в видеокарту
    redy:boolean;
    // данные текстуры которые скармливаются видеокарте
    pBits : pByteArray;
    bmp:tbitmap;
    // идентификатор текстуры.
    TexId:GLUint;
  public
    Destructor Destroy; override;
    constructor create(tmng:cTextureManager);
    procedure loadfromfile(const AFileName : String);
    // изменить размер загруженой текстуры
    procedure Resize(newwidth,newheigth:integer);
    procedure Bind;
    procedure DrawTo(canvas:tcanvas);
    procedure reinit;
  private
    procedure ConvertBitMapToBitArray(b:tbitmap; flipvertical:boolean);
    procedure LoadFromBMPFile( const AFileName : String; keepqud:boolean;maxwidth,maxheight:integer);
    procedure LoadFromJpgFile( const AFileName : String; keepqud:boolean;maxwidth,maxheight:integer);
    procedure init;
    procedure uninit;
    function platforminf:cPlatform;
  protected
    procedure setname(newname:string);
  public
    property name:string read fname write setname;
  end;

  cTextureManager = class
    m_Textures:TStringList;
    platforminfo:cPlatform;
    Constructor Create(platforminf:cPlatform);
    Destructor Destroy;override;
    function Add(texture:TTextureGl):TTextureGl;
    procedure deleteTexture(i:integer);overload;
    procedure deleteTexture(t:tTextureGl);overload;
    function  GetTexture(name:string):tTextureGl;overload;
    function GetTexture(i:integer):tTextureGl;overload;
    function count:integer;
  end;

//=================== вспомогательные процедуры ============
// --------------- Создает одномерную текстуру -------------
Procedure CreateHeatSigMap;

implementation
procedure glGenTextures (n: GLsizei; textures: PGLuint); stdcall; external opengl32;
procedure glBindTexture(mode: GLenum; Texture:GLuint
          ); stdcall; external OpenGL32;
const
 GL_VERTEX_ARRAY             = $8074;
 GL_COLOR_ARRAY              = $8076;
 GL_Normal_ARRAY             = $8075;
 GL_TEXTURE_COORD_ARRAY      = $8078;

 Procedure CreateHeatSigMap;
var texels:array[0..511] of GlFloat;
    x,size:GLint;
    p:GLFloat;
begin
    size:=Length(texels);
    for x := 0 to Size-1 do
    begin
        p := (x / (Size-1));
        // Gradient from black to blue to green to yellow to red
        if p < 0.25 then
        begin
            // black to blue
            p :=p*4.0;
            texels[x*4+0] := 0;
            texels[x*4+1] := 0;
            texels[x*4+2] := p;
        end
        else if p < 0.5 then
        begin
            // blue to green
            p :=p - 0.25;
            p :=p*4.0;
            texels[x*4+0] := 0;
            texels[x*4+1] := p;
            texels[x*4+2] := 1 - p;
        end
        else if (p < 0.75) then
        begin
            // green to yellow
            p :=p - 0.5;
            p :=p * 4;
            texels[x*4+0] := p;
            texels[x*4+1] := 1;
            texels[x*4+2] := 0;
        end
        else
        begin
            // yellow to red
            p :=p - 0.75;
            p :=p*4;
            texels[x*4+0] := 1.0;
            texels[x*4+1] := 1.0 - p;
            texels[x*4+2] := 0.0;
        end;
        texels[x*4+3] := 1;
    end;
    glTexImage1D(GL_TEXTURE_1D, 0, GL_RGBA, Size, 0, GL_RGBA, GL_FLOAT, @texels);
end;

function GetNearestTwoOrd(val:cardinal):word;
var i:integer;
begin
  i:=0;
  while val<>0 do
  begin
    val:=trunc(val/2);
    if val=0 then break;
    inc(i);
  end;
  result:=round(intpower(2,i));
end;


function TextureCreate(C, B: Integer; Width, Height: Integer; Data: Pointer): DWORD;
begin
  glGenTextures(1, @Result);
  glBindTexture(GL_TEXTURE_2D, Result);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16);
  gluBuild2DMipmaps(GL_TEXTURE_2D, C, Width, Height, B, GL_UNSIGNED_BYTE, Data);
end;

Function LoadFile(BM: TBitmap; FN: String): Boolean;
Var //Загружает BMP,JPG,PNG,... любой формат, объект которого описан.
  Loader: TPicture;
Begin
  LoadFile:=False;
  try
    Loader:=TPicture.Create;
    loader.LoadFromFile(FN);
    BM.PixelFormat:=pf24bit;
    BM.Width:=Loader.Width; BM.Height:=Loader.Height;
    BM.Canvas.Draw(0,0,Loader.Graphic);
    Loader.Free;
    LoadFile:=True;
  except
  end;
End;

Function ComputeS(N1,N,N2: Integer; X1,X2: Double; var Mid: Double): Double;
Begin 
  If (N=N1) or (N=N2) Then
  Begin
    If N1=N2 Then
    Begin
      ComputeS:=X2-X1; Mid:=(X1+X2)*0.5-N1;
    End
    Else
    Begin
      If N=N1 Then
      Begin
        ComputeS:=N1+1-X1; Mid:=(N1+1+X1)*0.5-N1;
      End
      Else
      Begin
        ComputeS:=X2-N2; Mid:=(X2+N2)*0.5-N2;
      End;
    End;
  End
  Else
  Begin
    ComputeS:=1;
    Mid:=0.5;
  End;
End;

function scalebitmap_(BM: TBitmap; SX2,SY2: Integer):TBitmap;
var bmnew:tbitmap;
begin
  BMNew:=TBitmap.Create;
  BMNew.PixelFormat:=pf24bit;
  BMNew.Width:=SX2; BMNew.Height:=Sy2;
  BMNew.Canvas.StretchDraw(Rect(0,0,SX2,Sy2),BM);
  result:=bmnew;
end;

Procedure ScaleBitmap(BM: TBitmap; SX2,SY2: Integer);
Var
  bmout: TBitmap;
  X,Y: Integer;
  Xt,Yt: Integer;
  X1,Y1,X2,Y2: Double;
  Dx,Dy: Double;
  Sx,Sy,S,MaxS: Double;
  MidX,MidY: Double;
  XErr,YErr: Double;
  Xi1,Yi1,Xi2,Yi2: Integer;
  SLin,SLout: PPixels;
  SLinT: PPixels; XR: Integer;
  MaxX,MaxY: Integer;
  P1,P2,P3,P4: Boolean;
  Lx,Ly: Boolean;
  l: Byte;
  ColR,ColG,ColB: Byte;
  Col0,Col1,Col2,Col3: RGB;
  Cn: Byte;
  Rs,Gs,Bs: Double;
Begin
  bmout:=TBitmap.Create;
  bmout.PixelFormat:=pf24bit; bmout.Width:=SX2; bmout.Height:=SY2;
  MaxX:=BM.Width-1; MaxY:=BM.Height-1;
  Dx:=BM.Width/bmout.Width; Dy:=BM.Height/bmout.Height;
  Lx:=(Dx<0.66666); Ly:=(Dy<0.66666);
  MaxS:=1/(Dx*Dy);
  XErr:=Dx/1000; YErr:=Dy/1000;
  For Y:=0 to bmout.Height-1 do
  Begin
    SLout:=bmout.ScanLine[Y];
    Y1:=Y*Dy; Y2:=(Y+1)*Dy;
    Yi1:=Floor(Y1+YErr); Yi2:=Ceil(Y2-YErr)-1;
    For X:=0 to bmout.Width-1 do
    Begin
      X1:=X*Dx; X2:=(X+1)*Dx;
      Xi1:=Floor(X1+XErr); Xi2:=Ceil(X2-XErr)-1;

      Rs:=0; Gs:=0; Bs:=0;
      For Yt:=Yi1 to Yi2 do
      Begin
        P1:=(Yi1>0); P2:=(Yi2<MaxY);
        SLin:=BM.ScanLine[Yt];
        Sy:=ComputeS(Yi1,Yt,Yi2,Y1,Y2,MidY);
        if Ly Then
        Begin
          If MidY<0.5 Then
          Begin
            if P1 Then
              SLinT:=BM.ScanLine[Yt-1]
            Else SLinT:=SLin;
          End
          Else
          Begin
            if P2 Then
              SLinT:=BM.ScanLine[Yt+1]
            Else SLinT:=SLin;
          End;
        End
        Else
          SLinT:=nil;
        For Xt:=Xi1 to Xi2 do
        Begin
          P3:=(Xi1>0); P4:=(Xi2<MaxX);
          Sx:=ComputeS(Xi1,Xt,Xi2,X1,X2,MidX);
          Col0:=SLin[Xt];
          if Lx Then
          Begin
            If MidX<0.5 Then
            Begin
              if P3 Then
                XR:=Xt-1
              Else
                XR:=Xt;
            End
            Else
            Begin
              if P4 Then
                XR:=Xt+1
              Else
                XR:=Xt;
            End;
            Col1:=SLin[XR];
          End
          Else
            XR:=0;
          If Ly Then
          Begin
            Col2:=SLinT[Xt];
            If Lx Then
              Col3:=SLinT[XR];
          End;
          If not (Lx or Ly) Then
          Begin
            ColR:=Col0.r; ColG:=Col0.g; ColB:=Col0.b;
          End
          Else
          Begin
            MidX:=Abs(MidX-0.5); MidY:=Abs(MidY-0.5);
            If Lx and Ly Then
            Begin
              ColR:=Round((Col0.r*(1-MidX)+Col1.r*MidX)*(1-MidY)+(Col2.r*(1-MidX)+Col3.r*MidX)*MidY);
              ColG:=Round((Col0.g*(1-MidX)+Col1.g*MidX)*(1-MidY)+(Col2.g*(1-MidX)+Col3.g*MidX)*MidY);
              ColB:=Round((Col0.b*(1-MidX)+Col1.b*MidX)*(1-MidY)+(Col2.b*(1-MidX)+Col3.b*MidX)*MidY);
            End
            Else
            Begin
              If Lx Then
              Begin
                ColR:=Round(Col0.r*(1-MidX)+Col1.r*MidX);
                ColG:=Round(Col0.g*(1-MidX)+Col1.g*MidX);
                ColB:=Round(Col0.b*(1-MidX)+Col1.b*MidX);
              End
              Else
              Begin
                ColR:=Round(Col0.r*(1-MidY)+Col2.r*MidY);
                ColG:=Round(Col0.g*(1-MidY)+Col2.g*MidY);
                ColB:=Round(Col0.b*(1-MidY)+Col2.b*MidY);
              End;
            End;
          End;
          S:=Sx*Sy; {Площадь пересечения текущего пиксела с текущим квадратиком}
          Rs:=Rs+ColR*S; Gs:=Gs+ColG*S; Bs:=Bs+ColB*S;
        End;
      End;
      Col0.r:=Round(Rs*MaxS); Col0.g:=Round(Gs*MaxS); Col0.b:=Round(Bs*MaxS);
      SLout^[X]:=Col0;
    End;
  End;
  BM.PixelFormat:=pf24bit; BM.Width:=SX2; BM.Height:=SY2;
  For Y:=0 to BMout.Height-1 do
  Begin
    SLin :=BM .ScanLine[y];
    SLout:=bmout.ScanLine[y];
    For X:=0 to BMout.Width-1 do
    Begin
      SLin^[X]:=SLout^[X];
    End;
  End;
  bmout.Destroy;
End;


Constructor cTextureManager.Create(platforminf:cPlatform);
begin
  platforminfo:=platforminf;
  m_Textures:=TStringList.Create;
  m_Textures.Sorted:=true;
  m_Textures.CaseSensitive:=false;
end;

Destructor cTextureManager.destroy;
var i:integer;
    texture:TTextureGl;
begin
  for i := 0 to m_textures.Count - 1 do
  begin
    texture:=ttexturegl(m_Textures.Objects[i]);
    texture.Destroy;
  end;
  m_textures.Destroy;
  inherited;
end;

procedure cTextureManager.deleteTexture(i:integer);
var t:ttexturegl;
begin
  if i<count then
  begin
    t:=gettexture(i);
    m_textures.Delete(i);
    t.Destroy;
  end;
end;

procedure cTextureManager.deleteTexture(t:tTextureGl);
var index:integer;
begin
  if m_textures.find(t.name,index) then
  begin
    m_textures.Delete(index);
    t.Destroy;
  end;
end;

function cTextureManager.count:integer;
begin
  result:=m_textures.Count;
end;

function cTextureManager.Add(texture:TTextureGl):TTextureGl;
var index:integer;
begin
  IF not m_textures.Find(texture.name,index) then
  begin
    m_Textures.AddObject(texture.name,texture);
    result:=texture;
  end
  else
  begin
    result:=GetTexture(index);
  end;
end;

function cTextureManager.GetTexture(name:string):tTextureGl;
var index:integer;
begin
  result:=nil;
  if m_Textures.find(name,index) then
    result:=ttexturegl(m_Textures.Objects[index]);
end;

function cTextureManager.GetTexture(i:integer):tTextureGl;
begin
  result:=ttexturegl(m_Textures.Objects[i])
end;

constructor TTextureGL.create(tmng:cTextureManager);
begin
  inherited create;
  redy:=false; // текстура загружена  в видяху
  maxwidth:=64; // максимальный размер текстуры в ширину
  maxHeight:=64; // максимальный размер текстуры в высоту
  level:=0; // степень упрощения текстуры
  bmp:=tbitmap.Create;
  events:=ceventlist.create(self, false);
  texmng:=tmng;
end;

Destructor TTextureGL.Destroy;
begin
  events.CallAllEvents(E_AllEvents);
  if Assigned(pBits) then FreeMem(pBits);
  bmp.free;
  events.destroy;
  Inherited Destroy;
end;

procedure TTextureGl.loadfromfile(const AFileName : String);
var ext:string;
begin
  ext:=extractfileext(afilename);
  ext:=LowerCase(ext);
  if ext='.bmp' then
  begin
    LoadFromBMPFile(AFileName,false,maxwidth,maxheight);
    reinit;    
  end;
  if ext='.jpg' then
  begin
    LoadFromJpgFile(AFileName,false,maxwidth,maxheight);
    reinit;
  end;
end;

procedure TTextureGl.ConvertBitMapToBitArray(b:tbitmap;flipvertical:boolean);
var row,i,j : Integer;
    l_b:boolean;
begin
  l_b:=platforminf.CheckBGRAExt;
  if l_b then
  begin
    // j номер строки в текстуре // i номер пикселя в строке
    for j := 0 to Height - 1 do
    begin
      if flipvertical then
        row:=Height - j - 1
      else
        row:=j;
      Move(b.ScanLine[j]^, pBits[(row) * Width*3], Width * 3)
    end;
  end
  else
  begin
    for j := 0 to Height - 1 do begin
      for i := 0 to Width - 1 do begin
        if flipvertical then
          row:=Height - j - 1
        else
          row:=j;
        pBits[(row*Width + i)*3] := GetRValue(B.Canvas.Pixels[i,j]);
        pBits[(row*Width + i)*3+1] := GetGValue(B.Canvas.Pixels[i,j]);
        pBits[(row*Width + i)*3+2] := GetBValue(B.Canvas.Pixels[i,j]);
      end;
    end;
  end;
end;

procedure TTextureGl.LoadFromBMPFile( const AFileName : String; keepqud:boolean;maxwidth,maxheight:integer);
var
  b:tbitmap;
begin
  flipvertical:=false;
  Bmp.LoadFromFile(AFileName);
  Width := Bmp.Width;
  Height := Bmp.Height;
  if maxwidth>0 then
  begin
    if width>maxwidth then
      width:=maxwidth;
  end;
  if maxHeight>0 then
  begin
    if Height>maxHeight then
      Height:=maxHeight;
  end;
  width:=GetNearestTwoOrd(width);
  Height:=GetNearestTwoOrd(Height);
  if keepqud then
  begin
    if width>height then
      width:=height
    else
      height:=width;
  end;
  b:=scalebitmap_(bmp,width,height);
  //ScaleBitmap(b,width,height);
  GetMem(pBits,Width*Height*3);
  ConvertBitMapToBitArray(b,flipvertical);
  B.Free;
end;

procedure TTextureGL.LoadFromJpgFile( const AFileName : String; keepqud:boolean;maxwidth,maxheight:integer);
var
  b : TBitmap;
  j,i:integer;
begin
  flipvertical:=true;
  LoadFile(bmp,AFileName);
  Width :=BMP.Width;
  Height :=BMP.Height;
  if maxwidth>0 then
  begin
    if width>maxwidth then
      width:=maxwidth;
  end;
  if maxHeight>0 then
  begin
    if Height>maxHeight then
      Height:=maxHeight;
  end;
  width:=GetNearestTwoOrd(width);
  Height:=GetNearestTwoOrd(Height);
  if keepqud then
  begin
    if width>height then
      width:=height
    else
      height:=width;
  end;
  GetMem(pBits,Width*Height*3);
  b:=scalebitmap_(bmp,width,height);
  ConvertBitMapToBitArray(b,flipvertical);
  b.free;
end;

procedure TTextureGL.Resize(newwidth,newheigth:integer);
var
  b : TBitmap;
  j,i:integer;
begin
  width:=GetNearestTwoOrd(newwidth);
  Height:=GetNearestTwoOrd(newheigth);
  if redy then
  begin
    freemem(pBits);
    uninit;
  end;
  GetMem(pBits,Width*Height*3);
  b:=scalebitmap_(bmp,width,height);
  ConvertBitMapToBitArray(b,flipvertical);
  b.free;
  reinit;
end;

procedure TTextureGL.Bind;
begin
  glBindTexture(GL_TEXTURE_2D, TexId);
end;

procedure TTextureGL.init;
begin
  //TexID := TextureCreate(GL_RGB8, $80E0, Width, Height, pBits);
  glGenTextures( 1, @TexID );
  glBindTexture( GL_TEXTURE_2D, TexID);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  if platforminf.CheckBGRAExt then
    glTexImage2D(GL_TEXTURE_2D,level,GL_RGBA,Width,Height,0,gL_BGR,GL_UNSIGNED_BYTE,pBits)
  else
    glTexImage2D(GL_TEXTURE_2D,level,GL_RGBA,Width,Height,0,gL_RGB,GL_UNSIGNED_BYTE,pBits);
  //glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_Modulate);
  {glEnable(GL_TEXTURE_2D);
  Case glGetError of
    GL_INVALID_ENUM: showmessage('TTextureGL Init GL_INVALID_ENUM');
    GL_INVALID_VALUE: showmessage('TTextureGL Init GL_INVALID_VALUE');
    GL_INVALID_OPERATION: showmessage('TTextureGL Init GL_INVALID_OPERATION');
    GL_NO_ERROR: ;
  end;}
  redy:=true;
end;
// освободить память от текстуры
procedure TTextureGL.uninit;
begin
  glDeleteTextures(1, @TexID);
  redy:=false;
end;
//
procedure TTextureGL.reinit;
begin
  if redy then
    uninit;
  init;
end;

procedure TTextureGL.DrawTo(canvas:tcanvas);
begin
  canvas.StretchDraw(canvas.ClipRect,BMP);
end;

procedure TTextureGL.setname(newname:string);
var index:integer;
begin
  if texmng<>nil then
  begin
    if texmng.m_Textures.Find(fname,index) then
    begin
      texmng.m_Textures.Delete(index);
      texmng.m_Textures.AddObject(newname,self);
    end;
  end;
  fname:=newname;
end;

function TTextureGL.platforminf:cPlatform;
begin
  result:=texmng.platforminfo;
end;

end.
