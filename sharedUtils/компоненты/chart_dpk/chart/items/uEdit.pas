unit uEdit;

interface

uses ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, classes,
  windows, uAxis, messages, utext, sysutils, uEventList, mathfunction,
  uChartEvents, uPoint, types, controls, forms,
  uDoubleCursor, usimpleobjects, NativeXML, uBasePage, Clipbrd;

type

  cEdit = class(cBasePage)
  public
    FontIndex: integer;
    // ����� �� ��������
    fCaption: string;
    // ��������� ����� � �����(������������� ���������� (�� ������ �������� ����))
    f_iCaptionPos: tpoint;
    // ��������� ����� � ������ � ����������� ����
    f_fCaptionPos: point2;
    // ������� ������
    f_TextPos: point2;
    // ����� �� ��������
    fText: string;
    // ������� �������� ��� ������
    f_fieldRect: frect;
    // ������ ������� � �������� �� ������ bound
    i_fieldRect: trect;
    // ���������� ��������
    fTransparent: boolean;
    // ������� ������� ������ ��� ��������� ����
    keepLabelSize: boolean;
    // ������������ ������� ������������ ����� ����� ��� ������� ���������������
    // ����������� ������� ��� ��������������� ����
    scale: point2;
    // ���� �������� ��� ������
    m_FieldColor: point3;
    m_TextColor: point3;
    // ������ ������ � ����� ����������� ������
    fSelectText: tpoint;
    fSelectBound: frect;
  protected
    procedure drawLabel;
    procedure drawText;
    procedure drawSelectTextBound;
  protected
    procedure setCaption(s: string);
    procedure setText(s: string);
    procedure drawData; override;
    procedure setBound(rect: trect); override;
    procedure setFieldRect(r: trect);
    procedure setCaptionPos(p: tpoint);
    procedure DoLincParent; override;
    procedure DoButtonUp(i_p: tpoint; f_p: point2); override;
    procedure DoMouseMove(i_p: tpoint; f_p: point2); override;
    procedure DoDblClick(i_p: tpoint; f_p: point2); override;
    procedure BuildSelectRect(left: integer; right: integer);
  protected
    procedure setTransparent(b: boolean);
    procedure SelectText(rect: trect);
  public
    procedure DoKeyDowne(key:word);override;
    constructor create; override;
    property Caption: string read fCaption write setCaption;
    property Text: string read fText write setText;
    property transparent: boolean read fTransparent write setTransparent;
    // ���� ��� ��������� ������
    property Field: trect read i_fieldRect write setFieldRect;
    // �������� � �������� (�� ������ �������� ����)
    property CaptionPos: tpoint read f_iCaptionPos write setCaptionPos;
  end;

var
  IdentRect: frect;

implementation

uses
  uchart;

constructor cEdit.create;
var
  r: trect;
begin
  inherited;
  move(identmatrix4d[0], m_view[0], 16 * sizeof(double));
  fTransparent := true;
  Caption := name;
  FontIndex := 2;
  IdentRect.BottomLeft := p2(-1, -1);
  IdentRect.TopRight := p2(1, 1);
  r.Bottom := 10;
  r.Right := 2;
  r.Left := 15;
  r.top := 10;
  Field := r;
  keepLabelSize := true;
  scale := p2(-1, -1);
  color := white;
  m_FieldColor := white;
  m_TextColor := black;
  Text := 'Text';
end;

procedure cEdit.setCaption(s: string);
begin
  fCaption := s;
end;

procedure cEdit.setText(s: string);
begin
  fText := s;
end;

procedure cEdit.drawData;
begin
  inherited;
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  setCommonVP;
  drawPageField;
  if not transparent then
  begin
    usimpleobjects.drawrect(f_fieldRect, m_FieldColor);
  end;
  drawLabel;
  drawSelectTextBound;
  drawText;
  drawBound;
  glpopmatrix;
end;

procedure cEdit.setTransparent(b: boolean);
begin
  fTransparent := b;
end;

procedure cEdit.drawLabel;
var
  font: cfont;
  col: point3;
begin
  col := black;
  glcolor3fv(@col);
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  if getmng <> nil then
  begin
    if fCaption <> '' then
    begin
      font := GetFont(FontIndex);
      // �������������� ����� ����� ��������� ��� ��������
      font.scaleVectorText := scale;
      font.OutText(fCaption, f_fCaptionPos, c_left);
    end;
  end;
  glpopmatrix;
end;

procedure cEdit.drawText;
var
  font: cfont;
begin
  glcolor3fv(@m_TextColor);
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  if getmng <> nil then
  begin
    if fText <> '' then
    begin
      font := GetFont(FontIndex);
      // �������������� ����� ����� ��������� ��� ��������
      font.scaleVectorText := scale;
      font.OutText(fText, f_TextPos, c_left);
    end;
  end;
  glpopmatrix;
end;

procedure cEdit.drawSelectTextBound;
begin
  if fSelectText.X <> -1 then
  begin
    usimpleobjects.drawrect(fSelectBound, blue);
  end;
end;

procedure cEdit.setFieldRect(r: trect);
var
  low, hi: tpoint;
  I: Integer;
  font:cfont;
  h:single;
begin
  i_fieldRect := r;
  low := point(bound.Left + r.Left, bound.Bottom + r.Bottom);
  hi := point(bound.Right - r.Right, bound.top - r.top);
  f_fieldRect.BottomLeft := P2iToP2proc(bound, IdentRect, low);
  f_fieldRect.TopRight := P2iToP2proc(bound, IdentRect, hi);

  f_TextPos.X := f_fieldRect.BottomLeft.X;
  f_TextPos.y := f_fieldRect.BottomLeft.y;

  font:=GetFont(fontindex);
  fSelectBound.BottomLeft.y := f_fieldRect.BottomLeft.y;
  if getheight<>0 then
  begin
    h:=font.getPixelHeight*2/getheight;
    fSelectBound.TopRight.y :=fSelectBound.BottomLeft.y+h;//f_fieldRect.TopRight.y;
  end;
end;

procedure cEdit.setBound(rect: trect);
var
  h, w, pixW: integer;
  lWidth: single;
  font: cfont;
begin
  inherited;
  h := getheight;
  w := getwidth;

  // ������� ������
  font := GetFont(FontIndex);
  // �������� ������ ������
  lWidth := font.getwidth(ftext);
  // �������� ������ ������ � ��������
  pixW := trunc(w * lWidth / 2);

  scale.X := 2*font.getPixelWidth(ftext) / pixW;
  scale.y := 2*font.getPixelHeight / (h);

  // ������������� ����� ����
  setFieldRect(i_fieldRect);
  // ������������� ����� ���������� �����
  CaptionPos := f_iCaptionPos;
  BuildSelectRect(fSelectText.x,fSelectText.y);
end;

procedure cEdit.setCaptionPos(p: tpoint);
var
  ip: tpoint;
  font: cfont;
  lHeight: single;
begin
  f_iCaptionPos := p;
  if getwidth <> 0 then
  begin
    font := GetFont(FontIndex);
    // lHeight:=font.getHeigth(fCaption);
    // ������ ������ � ��������
    // pixH:=trunc(getheight*lHeight/2);
    ip.y := bound.top - font.getPixelHeight - f_iCaptionPos.y;
    ip.X := bound.Left + f_iCaptionPos.X;
    f_fCaptionPos := P2iToP2proc(bound, IdentRect, ip);
  end;
end;

procedure cEdit.DoLincParent;
var
  font: cfont;
begin
  inherited;
  font := GetFont(FontIndex);
  if font <> nil then
    CaptionPos := point(0, 0);
end;

procedure cEdit.DoMouseMove(i_p: tpoint; f_p: point2);
var
  rect: trect;
  //p1: point2;
begin
  inherited;
  //p1:=p2iTop2(i_p,m_view);
  //fText:=floattostr(p1.x);
  //setlength(fText,6);
  //fText:=fText+' '+'v:'+inttostr(m_viewport[0])+' '+inttostr(i_p.x);
  if fdrag then
  begin
    if fDragBegin.X > i_p.X then
    begin
      rect.Left := i_p.X;
      rect.Right := fDragBegin.X;
    end
    else
    begin
      rect.Left := fDragBegin.X;
      rect.Right := i_p.X;
    end;
    if fDragBegin.y > i_p.y then
    begin
      rect.Bottom := i_p.y;
      rect.top := fDragBegin.y;
    end
    else
    begin
      rect.Bottom := fDragBegin.y;
      rect.top := i_p.y;
    end;
    SelectText(rect);
  end;
  cchart(chart).needRedraw := true;
end;

procedure cEdit.DoKeyDowne(key:word);
var
  ltext:string;
begin
  inherited;
  if key=VK_DELETE then
  begin
    delete(ftext,fSelectText.x,fSelectText.y-fSelectText.x+1);
    fSelectText:=point(-1,-1);
    cchart(chart).needRedraw := true;
  end;
  // ���� ����� VK_CONTROL
  if GetKeyState(VK_CONTROL)<0 then
  begin
    // �������� �� �
    if (key=67) then
    begin
      ltext := copy(ftext, fSelectText.x, fSelectText.y-fSelectText.x+1);
      clipboard.AsText:=ltext;
    end;
    // �������� �� X
    if (key=88) then
    begin
      ltext := copy(ftext, fSelectText.x, fSelectText.y-fSelectText.x+1);
      delete(ftext,fSelectText.x,fSelectText.y-fSelectText.x+1);
      clipboard.AsText:=ltext;
      fSelectText:=point(-1,-1);
      cchart(chart).needRedraw := true;
    end;
  end;
end;

procedure cEdit.DoButtonUp(i_p: tpoint; f_p: point2);
begin
  inherited;
  if (not fDblClick) and (fDragBegin.X=fDragEnd.X) then
  begin
    fSelectText:=point(-1,-1);
    cchart(chart).needRedraw := true;
  end;
end;

procedure cEdit.SelectText(rect: trect);
var
  p1, p2: point2;
  font: cfont;
  I,j: integer;
  len, charWidth: single;
begin
  p1 := p2iTop2(rect.BottomRight, m_view, true);
  p2 := p2iTop2(rect.TopLeft, m_view, true);

  font := GetFont(FontIndex);
  font.scaleVectorText:=scale;

  fSelectText := point(-1, -1);
  // ��������� ������ ������
  if p1.X < f_TextPos.X then
  begin
    exit;
  end;
  // ��������� ����� ������
  if p2.X > f_TextPos.X + font.getwidth(fText) then
  begin
    exit;
  end;

  len := f_TextPos.X;
  for I := 1 to length(fText) do
  begin
    // ����� �������
    if p2.X < len then
    begin
      fSelectText.X := I;
      fSelectBound.BottomLeft.X := len;
      break;
    end;
    charWidth := font.getCharWidth(fText[I]);
    len := len + charWidth;
  end;
  j:=i;

  for I := j to length(fText) do
  begin
    charWidth := font.getCharWidth(fText[I]);
    len := len + charWidth;
    // ������ ������� ��� ������ �� ����
    if p1.X < len then
    begin
      fSelectText.y := I - 1;
      fSelectBound.TopRight.X := len - charWidth;
      break;
    end
    else
    begin
      if I = length(fText) then
      begin
        fSelectText.y := I;
        fSelectBound.TopRight.x:=len;//+font.getCharWidth(fText[i]);
      end;
    end;
  end;

  if fSelectText.X = 0 then
    inc(fSelectText.X);
  if fSelectText.y = length(fText) + 1 then
    dec(fSelectText.y)
end;

procedure cEdit.BuildSelectRect(left: integer; right: integer);
var
  I: Integer;
  len:single;
  font:cfont;
begin
  if left=-1 then exit;
  font:=GetFont(fontindex);
  font.scaleVectorText:=scale;
  len:=f_TextPos.x;
  for I := 1 to right do
  begin
    if left=i then
    begin
      fSelectBound.BottomLeft.x:=len;
    end;
    len:=len+font.getCharWidth(ftext[i]);
    if right=i then
    begin
      fSelectBound.TopRight.x:=len;
      exit;
    end;
  end;
end;

procedure cEdit.DoDblClick(i_p: tpoint; f_p: point2);
begin
  fSelectText:=point(1,Length(ftext));
  BuildSelectRect(fSelectText.x,fSelectText.y);
  cchart(chart).needRedraw := true;
end;

end.
