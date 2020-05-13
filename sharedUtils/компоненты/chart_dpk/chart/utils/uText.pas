unit uText;

interface

uses
  ubaseobj, uCommonTypes, opengl, uOglExpFunc, classes, stdctrls,
  Graphics, windows, uCommonMath, sysutils, dialogs, MathFunction, uMatrix;

// ��� ���������� ������ �������� � ���������� ������� Resource Compiler
// ��������� Multi-byte character set = True
const
  GLYPHMETRICSSIZE = 500;

type
  // �����
  tfont = record
    // ����� ������
    index: integer;
    font: hfont;
    W: integer;
    height: integer;
    TabWidth: integer;
    color: point3;
  end;

  cFont = class
  private
    // ������� ��������� �� 1,1 � ���������� ���������� ��������
    fscaleVectorText: point2;
  public
    // ������� ��� ���������� ������ ������������ ��� wglUseFontOutlines
    gmf: array [0 .. GLYPHMETRICSSIZE] of GLYPHMETRICSFLOAT;
    index: integer;
    // hwnd:thandle;
    dc: hdc;
    name: string;
    text_size: point2;
    vectortype: boolean;
    cfg: tfont;
  protected
    // ������������� ���������� x, y � ��������� ������������ ����� 0, 0 � �������
    // ���������� ��� ������� ��� ������������ ������� ��������
    function P2iToP2Length(p: tpoint): point2;
    procedure setscaletext(p:point2);
  public
    constructor create(pname: string; p_index: integer; p_dc: hdc);
    destructor destroy; override;
    procedure setfont(isize, width, weight, style: integer;
      p_vectortype: boolean);
    // ������� align �������� ��������� ���� ��������� ������ ������� ������� (�� ���
    // ������������ ������ ���� � ����������� ����, ���� outText ������������ � ������
    // ����������� ���������� ��������� ������� ������ �������)
    procedure OutText(str: string; p: point2; align: integer);overload;
    procedure OutText(str: string; p: point2; worldWidth:single; align: integer);overload;
    // ��� ��������� �������
    function getWidth(str: string): single; overload;
    function getWidth(str: string; finish: integer): single; overload;
    function getCharWidth(ch: char): single;
    function getFontHeigth: single;
    function getHeigth(str: string): single;
    function getPixelWidth(str: string): integer;
    function getPixelHeight: integer;
    procedure TypedOutText(p2: point2; text: string);
    function EvalScaleY(h: double; ih: integer): double;overload;
    // ������������ ��� ������ �������� � ����������� ���� 1,1
    function EvalScaleY(ih: integer): double;overload;
    // ����������� ����������� ��������, ���� ��������� ������ ������
    function EvalScale(W, h: single; iw, ih: integer): point2; overload;
    // ������������ ��� ������ �������� � ����������� ���� 1,1
    function EvalScale(iw, ih: integer): point2; overload;
    property scaleVectorText:point2 read fscaleVectorText write setScaleText;
  end;

function fontbase(ind:integer):integer;

const
  c_charcount = GLYPHMETRICSSIZE;
  GLF_START_LIST = 1000;
  c_left = 0;
  c_right = 1;
  c_centr = 2;
  k = 1.3;

  c_activeFontInd = 0;
  c_AxisFontInd = 0;
  c_AxisBoldFontInd = 1;
  c_LabelFont = 2;

implementation

function CreateFont(index, isize, width, weight, style: integer; dc: hdc;
  name: string; vectortype: boolean; var gmf: array of GLYPHMETRICSFLOAT)
  : tfont;
var
  lfont: LogFontA;
  len: integer;
  I: integer;
begin
  lfont.lfHeight := isize;
  lfont.lfWidth := width;
  lfont.lfEscapement := 0;
  lfont.lfOrientation := 0;
  lfont.lfWeight := weight;
  // ������
  lfont.lfItalic := byte((style and 1));
  // �������������
  lfont.lfUnderline := byte(false);
  // �������������
  lfont.lfStrikeOut := byte(false);
  lfont.lfCharSet := RUSSIAN_CHARSET; // �����������
  //lfont.lfCharSet:=ANSI_CHARSET;
  // OUT_DEFAULT_PRECIS;
  lfont.lfOutPrecision := OUT_TT_ONLY_PRECIS;
  lfont.lfClipPrecision := CLIP_DEFAULT_PRECIS;
  lfont.lfQuality := DEFAULT_QUALITY;
  lfont.lfPitchAndFamily := DEFAULT_PITCH;
  // ������� �����
  for I := 0 to length(name) - 1 do
  begin
    lfont.lfFaceName[I] := ansichar(name[I + 1]);
  end;
  lfont.lfFaceName[length(name) + 1] := #0;
  result.font := CreateFontIndirectA(lfont);
  result.height := isize;
  result.index := index;
  result.W := width;
  SelectObject(dc, result.font);
  if vectortype then
  begin
    wglUseFontOutlinesA(dc,
      // ���������   ������ � ������ (code �������)
      0,
      // ���������� ����������� ������� �����������
      c_charcount,
      // ��������� �������� ������ �����������
      fontbase(index),
      0, // ������� �������
      0, // ������� �� ��� z
      WGL_FONT_POLYGONS,
      @gmf);
  end
  else
  begin
    wglUseFontBitmaps(dc, 0, c_charcount, GLF_START_LIST + index * c_charcount);
  end;
  // ����� ������ ������
  // GetTextExtentPoint(DC, K_STR, length(K_STR), sz);
  // text_size.x := sz.cx; text_height := sz.cy;
end;

// ����� ������
function FuncOutText(str: ansistring; p2: point2; index: integer): single;
var
  p: GLUInt;
  rightX: array [0 .. 3] of glfloat; // ������ ������� ���������� ������
begin
  if str <> '' then
  begin
    glGetIntegerv(gl_Matrix_Mode, @p);
    glMatrixMode(GL_PROJECTION);
    // glPushMatrix;
    // glLoadIdentity;
    glRasterPos2f(p2.x, p2.y);
    glGetFloatv(GL_CURRENT_RASTER_POSITION, @rightX[0]);
    glListBase(fontbase(index));
    //glCallLists(length(str), GL_UNSIGNED_SHORT, @str[1]);
    glCallLists(Length(str),GL_UNSIGNED_BYTE,@str[1]);
    glGetFloatv(GL_CURRENT_RASTER_POSITION, @rightX[0]);
    // glPopMatrix;
    result := rightX[0];
    if p = GL_MODELVIEW then
      glMatrixMode(GL_MODELVIEW);
    if p = GL_PROJECTION then
      glMatrixMode(GL_PROJECTION);
  end;
end;

// ����� ������
function FuncOutVectorText(str: ansistring; p2: point2; scale: point2;
  index: integer): single;
// function FuncOutVectorText(str:string; p2:point2; scale:point2; index:integer):single;
var
  p: GLUInt;
  rightX: array [0 .. 3] of glfloat; // ������ ������� ���������� ������
  m1, m: matrixgl;
begin
  if str <> '' then
  begin
    glGetIntegerv(gl_Matrix_Mode, @p);
    glMatrixMode(GL_MODELVIEW);
    glGetFloatv(GL_MODELVIEW_MATRIX, @m1);
    glLoadIdentity;
    glScale(scale.x, scale.y, 1);
    glGetFloatv(GL_MODELVIEW_MATRIX, @m);
    m := SetPos(m, p2.x, p2.y, 0);
    glLoadMatrixf(@m);
    glListBase(fontbase(index));
    glCallLists(Length(str),GL_UNSIGNED_Byte,@str[1]);
    //glCallLists(length(str), GL_UNSIGNED_SHORT, @str[1]);
    // glCallLists(Length(str),GL_INT,@str[1]);
    glLoadMatrixf(@m1);
    if p = GL_MODELVIEW then
      glMatrixMode(GL_MODELVIEW);
    if p = GL_PROJECTION then
      glMatrixMode(GL_PROJECTION);
    glGetFloatv(GL_MODELVIEW_MATRIX, @m);
  end;
end;

procedure cFont.TypedOutText(p2: point2; text: string);
begin
  if vectortype then
    FuncOutVectorText(text, p2, scaleVectorText, cfg.index)
  else
    FuncOutText(text, p2, cfg.index);
end;

procedure cFont.setfont(isize, width, weight, style: integer;
  p_vectortype: boolean);
begin
  cfg := CreateFont(cfg.index, isize, width, weight, style, dc, name, vectortype, gmf);
end;

procedure cFont.setscaletext(p: point2);
begin
  fscaleVectorText:=p;
end;

procedure drawrect(rect: frect; color: point3);
var
  data: array [0 .. 3] of point2;
  curcolor: point3;

  p: GLUInt;
  ightX: array [0 .. 3] of glfloat; // ������ ������� ���������� ������
begin
  data[0] := rect.BottomLeft;
  data[1] := p2(rect.BottomLeft.x, rect.topright.y);
  data[2] := rect.topright;
  data[3] := p2(rect.topright.x, rect.BottomLeft.y);
  // ��������� ������
  glGetIntegerv(gl_Matrix_Mode, @p);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  // ��������� �����
  glGetFloatv(GL_CURRENT_COLOR, @curcolor);
  glcolor3fv(@color);
  // ��������� ��������
  glBegin(GL_QUADs);
  glvertex2fv(@data[0]);
  glvertex2fv(@data[1]);
  glvertex2fv(@data[2]);
  glvertex2fv(@data[3]);
  glend;
  glcolor3fv(@curcolor);
  // ������� ������
  glPopMatrix;
  if p = GL_MODELVIEW then
    glMatrixMode(GL_MODELVIEW);
  if p = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

// ����������� ���������� ���������� � ���������� ����, ��� �������, ���
// ������������ ������� ��������
function cFont.P2iToP2Length(p: tpoint): point2;
var
  viewport: array [0 .. 3] of glint;
  m: array [0 .. 15] of glfloat;
  W, h: single;
begin
  // x, y , w, h
  glGetIntegerv(GL_VIEWPORT, @viewport);
  glGetFloatv(GL_PROJECTION_matrix, @m);
  W := 1 / m[0];
  h := 1 / m[5];
  result.x := W * p.x * 2 / viewport[2]; // -1;
  result.y := h * p.y * 2 / viewport[3]; // -1;
end;

procedure cFont.OutText(str: string; p: point2; worldWidth:single; align: integer);
var
  width: integer;
  l_p: point2;
  viewport: array [0 .. 3] of glint;
  m: array [0 .. 15] of glfloat;
  W, h, shiftX: single;
begin
  shiftX:=0;
  case align of
    c_right:
    begin
      width := getPixelWidth(str);
      glGetIntegerv(GL_VIEWPORT, @viewport);
      glGetFloatv(GL_PROJECTION_matrix, @m);
      W := worldWidth;
      h := 1 / m[5];
      shiftX := W * p.x * 2 / viewport[2];
      //result.y := h * p.y * 2 / viewport[3];
    end;
    c_centr:
    begin
      width := getPixelWidth(str);
      glGetIntegerv(GL_VIEWPORT, @viewport);
      glGetFloatv(GL_PROJECTION_matrix, @m);
      W := worldWidth;
      h := 1 / m[5];
      shiftX := (W * p.x * 2 / viewport[2])/2;
    end;
  end;
  OutText(str, p2(p.x-shiftX,p.y),c_left);
end;

procedure cFont.OutText(str: string; p: point2; align: integer);
var
  len, width: integer;
  l_p: point2;
  x: single;
  // rect:frect;
begin
  case align of
    c_left:
      begin
        TypedOutText(p, str);
      end;
    c_right:
      begin
        if not vectortype then
        begin
          width := getPixelWidth(str); // FuncOutText(str, p, cfg.color, cfg.index);
          l_p := P2iToP2Length(point(width, 8));
          x := p.x - l_p.x;
          // �������� ���� ����� �� ���������� � ���� �������
          while x < -1 do
          begin
            len := length(str);
            if len < 1 then
              exit;
            if (str[len] = ',') or (str[len] = '.') then
            begin
              dec(len);
            end;
            setlength(str, len);
            width := getPixelWidth(str);
            l_p := P2iToP2Length(point(width, 8));
            x := p.x - l_p.x;
          end;
          // rect.BottomLeft:=p;
          // rect.TopRight:=summp2(l_p,p);
          // drawrect(rect,blue);
          TypedOutText(p2(x, p.y), str);
        end
        else
        begin
          x := getWidth(str);
          p.x := p.x - x;
          TypedOutText(p, str);
        end;
      end;
    c_centr:
      begin
        width := getPixelWidth(str);
        l_p := P2iToP2Length(point(width, 8));
        x := p.x - l_p.x / 2;
        // �������� ���� ����� �� ���������� � ���� �������
        while x < -1 do
        begin
          len := length(str) - 1;
          if len < 2 then
            exit;
          if (str[len - 1] = ',') or (str[len - 1] = '.') then
          begin
            dec(len);
          end;
          setlength(str, len);
          width := getPixelWidth(str);
          l_p := P2iToP2Length(point(width, 8));
          x := p.x - l_p.x / 2;
        end;
        TypedOutText(p2(x, p.y), str);
      end;
  end;
end;

function cFont.getPixelWidth(str: string): integer;
var
  width: array [0 .. c_charcount] of abc;
  abcstruct: abc; // ������ �����/ ������/ ������ ������
  I: integer;
begin
  SelectObject(dc, cfg.font);
  if not GetCharABCWidths(dc, 0, c_charcount, width) then
  begin
  end;
  result := 0;
  for I := 1 to length(str) do
  begin
    abcstruct := width[byte(str[I])];
    result := abcstruct.abcA + abcstruct.abcB + abcstruct.abcC + result;
  end;
end;

function cFont.getPixelHeight: integer;
begin
  result := cfg.height;
end;

constructor cFont.create(pname: string; p_index: integer; p_dc: hdc);
begin
  index := p_index;
  name := pname;
  dc := p_dc;
  cfg.index := index;
  scaleVectorText:=p2(1,1);
end;

destructor cFont.destroy;
begin
  glDeleteLists(fontbase(index), c_charcount);
  inherited;
end;

// �������� ������ ������ � ����������� ���
function cFont.getWidth(str: string): single;
begin
  result := getWidth(str, length(str));
end;

function UnicodeToAnsiString(const ws: WideString; codePage: Word): AnsiString;
 overload;
var
 l: integer;
begin
 if ws = '' then
   Result := ''
 else
 begin
   l := WideCharToMultiByte(codePage,
     WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
     @ws[1], -1, nil, 0, nil, nil);
   SetLength(Result, l - 1);
   if l > 1 then
     WideCharToMultiByte(codePage,
       WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
       @ws[1], -1, @Result[1], l - 1, nil, nil);
 end;
end;

function cFont.getWidth(str: string; finish: integer): single;
var
  I: integer;
  code:byte;
  //utf8:UTF8String;
  //w:widechar;
  //ucs4:UCS4Char;
  //ucs4str:UCS4String;
  //unicstring:UnicodeString;
  astring:ansistring;
begin
  result := 0;
  if finish > length(str) then
    finish := length(str);
  //ucs4str:=UnicodeStringToUCS4String(str);
  //utf8:=AnsiToUtf8(str);
  //RUSSIAN_CHARSET; // �����������
  //ANSI_CHARSET;
  // ���� � ��� ��� ������ �������� � gmf ������������� ascii ��������� � � ���� gl
  // ���������� utf16 ������. OpenGl �������������� ������ ������ ��������, �������
  // ��� ����� ������� ������ �� ������� ascii
  astring:=UnicodeToAnsiString(str,ANSI_CHARSET);
 // WideCharToMultiByte
  for I := 1 to finish do
  begin
    if length(astring)<i then
      break;
    //ucs4:=ucs4str[i];
    code:=byte(astring[i]);
    result := gmf[code].gmfCellIncX + result;
    // result:=gmf[byte(str[i])].gmfCellIncX+result;
  end;
  result := result * scaleVectorText.x;
end;

function cFont.getCharWidth(ch: char): single;
var
  astring:ansistring;
  code:byte;
begin
  astring:=UnicodeToAnsiString(ch,ANSI_CHARSET);
  code:=byte(astring[1]);
  result := gmf[code].gmfCellIncX;
  result := scaleVectorText.x * result;
end;

function cFont.getFontHeigth: single;
begin
  result := scaleVectorText.y * getPixelHeight;
end;

function cFont.getHeigth(str: string): single;
var
  v: single;
  I: integer;
begin
  result := 0;
  for I := 1 to length(str) do
  begin
    v := gmf[byte(str[I])].gmfCellIncY;
    if v > result then
    begin
      result := v;
    end;
  end;
end;

function cFont.EvalScale(W, h: single; iw, ih: integer): point2;
begin
  scaleVectorText := p2(1, 1);
  result.y := k * h * getPixelHeight / ih;
  result.x := k * W * getPixelWidth('1') / (iw * getCharWidth('1'));
end;

function cFont.EvalScale(iw, ih: integer): point2;
begin
  scaleVectorText := p2(1, 1);
  result.y := 2 * k * getPixelHeight / ih;
  result.x := 2 * k * getPixelWidth('1') / (iw * getCharWidth('1'));
end;

function cFont.EvalScaleY(h: double; ih: integer):double;
begin
  result:= h/ih;
end;
// ������������ ��� ������ �������� � ����������� ���� 1,1
function cFont.EvalScaleY(ih: integer): double;
begin
  result:= EvalScaleY(2, ih);
end;

function fontbase(ind:integer): integer;
begin
  result:=GLF_START_LIST+ind*c_charcount;
end;

end.
