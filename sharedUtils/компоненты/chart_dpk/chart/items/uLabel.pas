unit uLabel;

interface

uses
  uCommonTypes, opengl, uOglExpFunc, types, dialogs,
  sysutils, math, uCommonMath, stdctrls, forms, controls, classes,
  uText, uEventList,
  ubaseobj, udrawobj,
  uChartEvents, mathfunction,
  uSimpleObjects,
  uGraphObj, windows,
  messages,
  uLogFile,
  clipbrd;

type
  // �������� � ��������� ������ �������� (�� DrawObjVP)
  cLabel = class(cMoveObj)
  protected
    // �������� ������ ������������ �����
    fPixBorderOffset: tpoint;
    // �� �� ��� ���������� ����� �� ������������ ���������� -1..1
    fBorderOffset: point2d;
    m_intervalScale:double;
    // ���������� ����
    m_log:string;
  public
    // ���������� ������� �������� ����� ����������
    m_drawobjVP: boolean;

    align: integer;
    // ���������������� �������/ ������ ����� �� �������� ����������� ������ ��������
    // ���� �� ����� 1 (�� ��������� �� 29.01.19)
    m_addscalex, m_addscaley: double;
  public
    fOnSetText: TNotifyEvent;
    fKeyDown: TKeyEvent;
    fOnMove: TNotifyEvent;
  public
    // ������ �������� ������
    fontIndex: integer;
  protected
    fbufStrList: tstringlist;
    // ������� ���������� ����
    fSelectText: array [0 .. 1] of tpoint;
    fText: tstringlist;
    // ������� ������� (����� ����� �������� ����� ������� ��� ������� ������)
    // x - ������, y - ������
    fCursorPos: tpoint;
    // ������ (� �����)
    fHeigth: integer;
    // ������ (� �����)
    fWidth: integer;
    // ������������ ������� ������������ ����� ����� ��� ������� ���������������
    // ����������� ������� ��� ��������������� ����
    scale: point2;
    KeepScale: boolean;
    m_TextColor, m_SelectTextColor: point3;

    f_iTextPos: tpoint;
    // �������� ������ ������������ ������ ������� ���� �����
    f_TextPos: point2;
    fTransparent: boolean;
  protected
    procedure DoOnMove(p: point2); override;
    procedure SetPos(p: point2); override;
    procedure DelSelectText;
    procedure SetText(s: string);
    procedure DrawData; override;
    procedure DrawBorder;
    procedure DrawCursorPos;
    procedure DrawText;
    procedure DrawSelectText;
    procedure SetCursPos(pos: tpoint);
    procedure SetHeigth(h: integer);
    procedure SetWidth(w: integer);
    procedure correctBorderOffset;
    procedure doUpdateWorldSize(sender: tobject); override;
    procedure reEvalScales;
    // x - ������, y - ������
    function GetCharIndexByPos(p: point2): tpoint;
    procedure SetTransparent(b: boolean);
    function getChar(key: cardinal): char;
    function getText: string;
    procedure InsertChar(ch: char); virtual;
    // ������� ������ ��� ������������ �� ������� ����
    function TextRightPos: single;
    function EvalRowBound(row: integer; font: cfont; startindex: integer;
      lastindex: integer): frect;
  public
    property OnKeyEnter: TKeyEvent read fKeyDown write fKeyDown;
  public
    procedure setMng(m: tobject); override;
    function EvalRowHeigth: double; overload;
    function EvalRowHeigth(p_font: cfont): double; overload;
    function GetTextHeigth: double;
    function GetTextWidth: single;
    procedure SelectText(p1, p2: point2);
    procedure DoOnBtnUp(p: point2); override;
    procedure DoOnMouseMove(p: point2); override;
    procedure DoOnClick(p: point2); override;
    procedure DoOnDblClick(p: point2); override;
    procedure DoOnKeyEnter(key: word); override;
    procedure DoOnMouseLeave; override;
    procedure DoOnExit; override;
    function TestObj(p_p2: point2; dist: single): boolean; override;
    constructor create; override;
    destructor destroy; override;
    property Text: string read getText write SetText;
    property Heigth: integer read fHeigth write SetHeigth;
    property Width: integer read fWidth write SetWidth;
    property CursorPos: tpoint read fCursorPos write SetCursPos;
    property Transparent: boolean read fTransparent write SetTransparent;
    property TextColor: point3 read m_TextColor write m_TextColor;
    property OnSetText: TNotifyEvent read fOnSetText write fOnSetText;
  end;

implementation

uses
  uchart, uBasePage, upage, uaxis;

function cLabel.TestObj(p_p2: point2; dist: single): boolean;
var
  r: frect;
begin
  result := inherited;
  r := GetBound;
  if (p_p2.x > r.BottomLeft.x - dist) and (p_p2.x < r.TopRight.x + dist) then
  begin
    if (p_p2.y > r.BottomLeft.y - dist) and (p_p2.y < r.TopRight.y + dist) then
    begin
      result := true;
    end;
  end;
end;

procedure cLabel.correctBorderOffset;
var
  p2: point2;
  rh, MaxRowWidth: double;
begin
  // �������� ����� � ����������� Ogl
  // ��� ���� ������ ������ ������ ������������� 0.0
  p2 := GetSize(point(fWidth, fHeigth));
  rh := EvalRowHeigth;
  MaxRowWidth := GetTextWidth;

  boundrect.TopRight.y := rh + fBorderOffset.y;
  boundrect.BottomLeft.y := rh - p2.y - fBorderOffset.y;
  if align = c_left then
  begin
    boundrect.TopRight.x := boundrect.BottomLeft.x + MaxRowWidth;
    boundrect.TopRight.x := p2.x + fBorderOffset.x;
    boundrect.BottomLeft.x := -fBorderOffset.x; // +boundrect.BottomLeft.x;
  end
  else
  begin
    boundrect.TopRight.x := fBorderOffset.x;
    boundrect.BottomLeft.x := boundrect.TopRight.x - MaxRowWidth -
      fBorderOffset.x;
  end;
end;

constructor cLabel.create;
begin
  inherited;
  // ������������ ��������
  m_intervalScale:=1.1;
  m_drawobjVP := false;
  m_addscalex := 1;
  m_addscaley := 1;

  fbufStrList := tstringlist.create;
  fText := tstringlist.create;
  fText.Sorted := false;
  fText.Delimiter := char(10);
  fText.StrictDelimiter := true;

  align := c_left;

  CursorPos := point(-1, -1);
  fontIndex := c_LabelFont;

  color := green;
  m_TextColor := black;
  m_SelectTextColor := blue;
  KeepScale := true;
  scale := p2(1, 1);
  f_iTextPos := point(0, 0);
  fWidth := 80;
  fHeigth := 20;
  Text := name;

  fPixBorderOffset := point(2, 2);

  fTransparent := true;
  locked := true;
  enabled := true;
  selectable := true;
end;

destructor cLabel.destroy;
begin
  fbufStrList.destroy;
  fText.destroy;
  inherited;
end;

procedure cLabel.SetPos(p: point2);
var
  //callStack: TJclStackInfoList;
  I, j: integer;
  str: string;
begin
  inherited;
end;

procedure cLabel.SetText(s: string);
var
  font: cfont;
  lscale: point2;
  p: cbasepage;
  textH, MaxRowWidth: double;

  I: integer;
  // ������ ����������
  textsize: tpoint;
begin
  fText.Clear;
  fText.DelimitedText := s;

  p := cbasepage(getpage);
  if p = nil then
    exit;
  if (p.getwidth = 0) or (p.getheight = 0) then
    exit;

  font := GetFont(fontIndex);
  reEvalScales;
  MaxRowWidth := GetTextWidth;
  if font <> nil then
  begin
    if align = c_left then
    begin
      boundrect.TopRight.x := boundrect.BottomLeft.x + MaxRowWidth;
    end
    else
    begin
      boundrect.TopRight.x := 0;
      boundrect.BottomLeft.x := boundrect.TopRight.x - MaxRowWidth;
    end;
    textH := GetTextHeigth + fBorderOffset.y * 2;
    textsize := GetiSize(p2((boundrect.TopRight.x - boundrect.BottomLeft.x),
        textH));
    fWidth := textsize.x;
    fHeigth := textsize.y;
    correctBorderOffset;
  end;
  if Assigned(fOnSetText) then
    fOnSetText(self);
end;

procedure cLabel.SetHeigth(h: integer);
var
  p: point2;
begin
  fHeigth := h;
  if fWidth <> 0 then
  begin
    if fHeigth <> 0 then
    begin
      boundrect.BottomLeft := p2(0, 0);
      p := GetSize(point(fWidth, fHeigth));
      boundrect.TopRight := p;
    end;
  end;
end;

procedure cLabel.SetWidth(w: integer);
begin
  fWidth := w;
end;

procedure cLabel.setMng(m: tobject);
begin
  inherited;
end;

procedure cLabel.DrawBorder;
var
  m: matrixgl;
begin
  if not Transparent then
  begin
    glgetfloatv(GL_MODELVIEW_MATRIX, @m);
    glgetfloatv(GL_PROJECTION_MATRIX, @m);
    uSimpleObjects.drawrect(boundrect, color);
    uSimpleObjects.DrawBorder(boundrect, TextColor);
  end;
end;

function cLabel.EvalRowBound(row: integer; font: cfont; startindex: integer;
  lastindex: integer): frect;
var
  ltext: string;
  rh: double;
begin
  ltext := fText.Strings[row];
  rh := EvalRowHeigth(font);
  result.BottomLeft.x := font.getwidth(ltext, startindex);
  result.TopRight.x := font.getwidth(ltext, lastindex);
  // ������ ������ ������ ������ ������ (0,0)
  result.BottomLeft.y := -rh * row;
  result.TopRight.y := result.BottomLeft.y + rh;
end;

procedure cLabel.DrawSelectText;
var
  r: frect;
  font: cfont;
  ltext: string;
  selRow, selRowCount, bufind, startrow, endrow, startindex, lastindex: integer;
  swapRow: boolean;
  textwidth: double;
begin
  if fSelectText[0].y > -1 then
  begin
    // ������ ������!!!
    font := GetFont(fontIndex);
    if font = nil then
      exit;
    selRowCount := abs(fSelectText[1].x - fSelectText[0].x) + 1;
    startrow := fSelectText[0].x;
    endrow := fSelectText[1].x;
    swapRow := false;
    if startrow > endrow then
    begin
      bufind := startrow;
      startrow := endrow;
      endrow := bufind;
      swapRow := true;
    end;
    bufind := startrow;
    selRow := startrow;
    if selRow > -1 then
    begin
      while selRow - startrow < selRowCount do
      begin
        if fText.count = 0 then
          exit;

        ltext := fText.Strings[selRow];
        if swapRow then
          startindex := fSelectText[1].y
        else
          startindex := fSelectText[0].y;
        if startrow <> endrow then
        begin
          // ����������� ������ ������
          lastindex := length(ltext);
          if selRow <> startrow then
            startindex := 1;
        end
        else
        begin
          if selRow = endrow then
          begin
            lastindex := fSelectText[1].y;
          end;
        end;
        if startindex > lastindex then
        begin
          bufind := startindex;
          startindex := lastindex;
          lastindex := bufind;
        end;
        r := EvalRowBound(selRow, font, startindex, lastindex);
        if align = c_right then
        begin
          textwidth := GetTextWidth;
          r.BottomLeft.x := r.BottomLeft.x - textwidth;
          r.TopRight.x := r.TopRight.x - textwidth;
        end;
        uSimpleObjects.drawrect(r, m_SelectTextColor);
        inc(selRow);
      end;
    end;
  end;
end;

procedure cLabel.DrawCursorPos;
var
  len: single;
  font: cfont;
  m: matrixgl;
  textwidth: single;
  ltext: string;
  r: frect;
begin
  if CursorPos.y > -1 then
  begin
    if selected then
    begin
      font := GetFont(fontIndex);
      if font = nil then
        exit;
      if CursorPos.x > (fText.count - 1) then
        exit;
      if CursorPos.x = -1 then
        exit;
      ltext := fText.Strings[CursorPos.x];
      // ������ ������ ������
      r := EvalRowBound(CursorPos.x, font, 1, 1);
      len := font.getwidth(ltext, CursorPos.y);
      glgetfloatv(GL_MODELVIEW_MATRIX, @m);
      glgetfloatv(GL_PROJECTION_MATRIX, @m);
      glcolor3fv(@blue);
      if align = c_right then
      begin
        textwidth := GetTextWidth;
        len := boundrect.TopRight.x - textwidth + len;
      end;
      glBegin(GL_LINES);
      glVertex2f(len, r.BottomLeft.y);
      glVertex2f(len, r.TopRight.y);
      glend;
    end;
  end;
end;

procedure cLabel.DrawText;
var
  font: cfont;
  I: integer;
  rowHeight: double;
  p: cbasepage;
begin
  glcolor3fv(@m_TextColor);
  p := cbasepage(getpage);
  if getmng <> nil then
  begin
    if Text <> '' then
    begin
      font := GetFont(fontIndex);
      // �������������� ����� ����� ��������� ��� ��������
      font.scaleVectorText := scale;
      // c_left
      rowHeight := EvalRowHeigth;
      for I := 0 to fText.count - 1 do
      begin
        // 1.1 ������������ ��������
        font.OutText(fText.Strings[I], p2(f_TextPos.x + fpos.x,
            f_TextPos.y + fpos.y - m_intervalScale*rowHeight * I), align);
      end;
    end;
  end;
end;

procedure cLabel.DrawData;
var
  r: frect;
  page: cpage;
  v: array [0 .. 3] of glint;
  m: matrixgl;
  TMtype: glint;
begin
  if m_drawobjVP then
  begin
    page := cpage(getpage);
    page.setDrawObjVP;
  end;
  glGetIntegerv(GL_VIEWPORT, @v);
  if v[0] >= 0 then
  begin
    DrawBorder;
    if flocked then
      DrawSelectText;
    DrawText;
    DrawCursorPos;
  end;
end;

procedure cLabel.doUpdateWorldSize(sender: tobject);
var
  p2: point2;
  p: cbasepage;
  rh: double;
begin
  if parent <> nil then
  begin
    p := cbasepage(getpage);
    if p.getwidth <> 0 then
    begin
      if p.getheight <> 0 then
      begin
        // �������� ����� � ����������� Ogl
        // ��� ���� ������ ������ ������ ������������� 0.0
        p2 := GetSize(point(fWidth, fHeigth));
        // ������ ������ �������� ������
        fBorderOffset.x := p2.x * fPixBorderOffset.x / fWidth;
        fBorderOffset.y := p2.y * fPixBorderOffset.y / fHeigth;

        rh := EvalRowHeigth;

        // ������������� �������
        boundrect.TopRight.y := rh;
        boundrect.TopRight.x := p2.x + rh;
        boundrect.BottomLeft.y := rh - p2.y;
        correctBorderOffset;
        reEvalScales;
      end;
    end;
  end;
end;

procedure cLabel.reEvalScales;
var
  p: cbasepage;
  font: cfont;
begin
  // ������� ������
  p := cbasepage(getpage);
  font := GetFont(fontIndex);
  if font<>nil then
  begin
    scale := font.EvalScale(GetFWidth, GetFHeigth, p.getwidth, p.getheight);
    scale.x := m_addscalex * scale.x;
    scale.y := m_addscaley * scale.y;
  end;
end;

function cLabel.GetCharIndexByPos(p: point2): tpoint;
var
  font: cfont;
  I, row: integer;
  len, charWidth, textwidth: single;
  tPos: point2;
  rh, dy: double;
  ltext: string;
begin
  font := GetFont(fontIndex);
  font.scaleVectorText := scale;
  rh := EvalRowHeigth;
  if align = c_left then
  begin
    // ��������� ������ ����� ������ ������
    tPos := p2(fpos.x + f_TextPos.x, fpos.y + f_TextPos.y);
    if p.y > tPos.y then
      row := 0
    else
    begin
      dy := tPos.y - p.y;
      row := trunc(dy / rh) + 1;
    end;
    result.x := row;
    if row > fText.count - 1 then
    begin
      result := point(-1, -1);
      exit;
    end;

    ltext := fText.Strings[row];

    textwidth := font.getwidth(ltext);
    if p.x < tPos.x then
    begin
      result.y := 0;
      exit;
    end;
    // ��������� ����� ������
    if p.x > tPos.x + textwidth then
    begin
      result.y := length(ltext);
      exit;
    end;
    len := tPos.x;
    for I := 1 to length(ltext) do
    begin
      charWidth := font.getCharWidth(ltext[I]);
      // ����� �������
      if p.x < len + charWidth / 2 then
      begin
        result.y := I - 1;
        exit;
      end;
      len := len + charWidth;
    end;
    result.y := length(ltext);
  end
  else
  // c_right
  begin
    // ��������� ������ ����� ������ ������
    tPos := p2(fpos.x + f_TextPos.x - GetTextWidth, fpos.y + f_TextPos.y);
    if p.y > tPos.y then
      row := 0
    else
    begin
      dy := tPos.y - p.y;
      row := trunc(dy / rh) + 1;
    end;
    result.x := row;
    if row > fText.count - 1 then
    begin
      result := point(-1, -1);
      exit;
    end;
    ltext := fText.Strings[row];
    textwidth := font.getwidth(ltext);

    if p.x < tPos.x then
    begin
      result.y := 0;
      exit;
    end;
    // ��������� ����� ������
    if p.x > tPos.x + textwidth then
    begin
      result.y := length(ltext);
      exit;
    end;
    len := tPos.x;
    for I := 1 to length(ltext) do
    begin
      charWidth := font.getCharWidth(ltext[I]);
      // ����� �������
      if p.x < len + charWidth / 2 then
      begin
        result.y := I - 1;
        exit;
      end;
      len := len + charWidth;
    end;
    result.y := length(ltext);
  end;
end;

function cLabel.getText: string;
begin
  result := fText.DelimitedText;
end;

procedure cLabel.SelectText(p1, p2: point2);
var
  font: cfont;
begin
  font := GetFont(fontIndex);
  font.scaleVectorText := scale;
  fSelectText[0] := point(-1, -1);

  fSelectText[0] := GetCharIndexByPos(p1);
  fSelectText[1] := GetCharIndexByPos(p2);
end;

function cLabel.TextRightPos: single;
var
  font: cfont;
begin
  font := GetFont(fontIndex);
  result := f_TextPos.x + font.getwidth(Text);
end;

procedure cLabel.DoOnMouseMove(p: point2);
begin
  if enabled then
  begin
    inherited;
    if locked then
    begin
      if fdrag then
      begin
        SelectText(fDragBegin, p);
      end;
      cchart(chart).needRedraw := true;
    end;
  end;
end;

procedure cLabel.DoOnClick(p: point2);
var
  tPos: tpoint;
begin
  inherited;
  if enabled then
  begin
    tPos := GetCharIndexByPos(p);
    if (tPos.y <> CursorPos.y) or (tPos.x <> CursorPos.x) then
    begin
      CursorPos := tPos;
      cchart(chart).needRedraw := true;
    end;
  end;
end;

procedure cLabel.DoOnDblClick(p: point2);
var
  row: integer;
  ltext: string;
begin
  if enabled then
  begin
    inherited;
    fontIndex := c_LabelFont;
    row := 0;
    fSelectText[0] := point(0, 0);
    row := fText.count - 1;
    ltext := fText.Strings[row];
    fSelectText[1] := point(fText.count - 1, length(ltext));
    // BuildSelectRect(fSelectText.x,fSelectText.y);
    cchart(chart).needRedraw := true;
    cchart(chart).fDisableInheritedWndProc := true;
    cchart(chart).fDisabledMsg := WM_LBUTTONDBLCLK;
  end;
end;

function cLabel.getChar(key: cardinal): char;
var
  l_ch: cardinal;
begin
  l_ch := mapvirtualkey(key, MAPVK_VK_TO_CHAR);
  result := char(l_ch);
end;

procedure cLabel.DoOnKeyEnter(key: word);
var
  ltext: string;
  ch: char;
  Shiftstate: tshiftstate;
  I: integer;
begin
  if enabled then
  begin
    if key = VK_Shift then
    begin
      exit;
    end;
    if key = VK_LEFT then
    begin
      if fCursorPos.y > 0 then
      begin
        fCursorPos.y := fCursorPos.y - 1;
      end;
      // ���� ����� Shift
      if GetKeyState(VK_Shift) < 0 then
      begin
        if (fSelectText[0].y = -1) or // ������ �������� �����
          ((fSelectText[0].y - CursorPos.y) > 1)
        // ������ ����������� ������ ����� �������
          then
        begin
          fSelectText[0].x := CursorPos.x;
          fSelectText[0].y := CursorPos.y + 1;
          fSelectText[1].x := CursorPos.x;
          fSelectText[1].y := CursorPos.y;
        end
        else
        begin
          if fSelectText[0].y > fSelectText[0].x then
            fSelectText[0].y := CursorPos.y
          else
          begin
            if fSelectText[0].y = fSelectText[0].x then
            begin
              fSelectText[0].x := -1;
              fSelectText[0].y := -1;
              exit;
            end;
            fSelectText[0].x := CursorPos.y + 1
          end;
        end;
        // BuildSelectRect(fselecttext[0].x,fselecttext[0].y);
      end
      else
      begin
        fSelectText[0].x := -1;
        fSelectText[0].y := -1;
      end;
      cchart(chart).needRedraw := true;
      exit;
    end;
    if key = VK_End then
    begin
      if GetKeyState(VK_Shift) < 0 then
      begin
        fSelectText[0].y := length(Text);
        fSelectText[0].x := CursorPos.y;
        if fSelectText[0].x < 1 then
          fSelectText[0].x := 0;
        // BuildSelectRect(fselecttext.x,fselecttext.y);
        cchart(chart).needRedraw := true;
      end
      else
      begin
        fCursorPos.y := length(Text);
      end;
      cchart(chart).needRedraw := true;
      exit;
    end;
    if key = VK_Home then
    begin
      if GetKeyState(VK_Shift) < 0 then
      begin
        fSelectText[0].y := CursorPos.y;
        fSelectText[0].x := 0;
        // BuildSelectRect(fselecttext.x,fselecttext.y);
        cchart(chart).needRedraw := true;
      end
      else
      begin
        fCursorPos.y := 0;
      end;
      exit;
    end;
    if key = VK_Right then
    begin
      if fCursorPos.y < length(Text) then
        fCursorPos.y := fCursorPos.y + 1;
      // ���� ����� Shift
      if GetKeyState(VK_Shift) < 0 then
      begin
        if (fSelectText[0].y = -1) or ((CursorPos.y - fSelectText[0].y) >= 1)
          then
        begin
          fSelectText[0].y := CursorPos.y;
          if fSelectText[0].y = -1 then
            fSelectText[0].y := CursorPos.y;
        end
        else
        begin
          if fSelectText[1].y > fSelectText[0].y then
            fSelectText[0].y := CursorPos.y + 1
          else
          begin
            if fSelectText[0].y = fSelectText[0].x then
            begin
              fSelectText[0].x := -1;
              fSelectText[0].y := -1;
              exit;
            end;
            fSelectText[0].y := CursorPos.y + 1
          end;
        end;
        // BuildSelectRect(fselecttext.x,fselecttext.y);
      end
      else
      begin
        fSelectText[0].x := -1;
        fSelectText[0].y := -1;
      end;
      cchart(chart).needRedraw := true;
      exit;
    end;
    if key = VK_BACK then
    begin
      if fSelectText[0].x = -1 then
      begin
        if fCursorPos.y > 0 then
        begin
          ltext := Text;
          delete(ltext, fCursorPos.y, 1);
          Text := ltext;
          dec(fCursorPos.y);
          cchart(chart).needRedraw := true;
        end;
        exit;
      end
      else
      begin
        ltext := Text;
        delete(ltext, fSelectText[0].y,
          fSelectText[1].y - fSelectText[0].y + 1);
        Text := ltext;
        fCursorPos.y := fSelectText[0].y - 1;
        fSelectText[0] := point(-1, -1);
        cchart(chart).needRedraw := true;
        exit;
      end;
    end;
    if key = VK_DELETE then
    begin
      if fSelectText[0].x = -1 then
      begin
        if CursorPos.y < length(Text) then
        begin
          ltext := Text;
          delete(ltext, fCursorPos.y + 1, 1);
          Text := ltext;
          cchart(chart).needRedraw := true;
          exit;
        end;
      end
      else
      begin
        ltext := Text;
        delete(ltext, fSelectText[0].x,
          fSelectText[0].y - fSelectText[0].x + 1);
        Text := ltext;
        fCursorPos.y := fSelectText[0].y - 1;
        fSelectText[0] := point(-1, -1);
        cchart(chart).needRedraw := true;
        exit;
      end;
    end;
    // ���� ����� VK_CONTROL
    if GetKeyState(VK_CONTROL) < 0 then
    begin
      // �������� �� �
      if (key = 67) then
      begin
        ltext := Text;
        ltext := copy(ltext, fSelectText[0].x,
          fSelectText[0].y - fSelectText[0].x + 1);
        clipboard.AsText := ltext;
      end;
      // �������� �� X
      if (key = 88) then
      begin
        ltext := Text;
        ltext := copy(ltext, fSelectText[0].x,
          fSelectText[0].y - fSelectText[0].x + 1);
        clipboard.AsText := ltext;
        delete(ltext, fSelectText[0].x,
          fSelectText[0].y - fSelectText[0].x + 1);
        Text := ltext;
        fSelectText[0] := point(-1, -1);
        cchart(chart).needRedraw := true;
      end;
      exit;
    end
    else
    // ������ ���� ������
    begin
      if Assigned(fKeyDown) then
      begin
        fKeyDown(self, key, Shiftstate);
      end;
      // ������� �������� �����
      DelSelectText;
      ltext := Text;
      ch := getChar(key);
      InsertChar(ch);
    end;
  end;
end;

procedure cLabel.DelSelectText;
var
  I, firstind, endind: integer;
  ltext: string;
begin
  fbufStrList.Clear;
  for I := 0 to fText.count - 1 do
  begin
    ltext := fText.Strings[I];
    if (I >= fSelectText[0].x) and (I <= fSelectText[1].x) then
    begin
      if (I = fSelectText[0].x) then
      begin
        firstind := fSelectText[0].y;
      end
      else
        firstind := 0;
      if (I = fSelectText[1].x) then
      begin
        endind := fSelectText[1].y;
      end
      else
        endind := length(ltext);
    end;
    delete(ltext, firstind + 1, endind - firstind);
    if ltext <> '' then
      fbufStrList.Add(ltext);
  end;
  fSelectText[0] := point(-1, -1);
  fSelectText[1] := point(-1, -1);
  fText.Clear;
  for I := 0 to fbufStrList.count - 1 do
  begin
    ltext := fbufStrList.Strings[I];
    fText.Add(ltext);
  end;
end;

procedure cLabel.InsertChar(ch: char);
var
  ltxt: string;
begin
  if fSelectText[0].y > fSelectText[0].x then
  begin
    ltxt := Text;
    delete(ltxt, fSelectText[0].x, fSelectText[0].y - fSelectText[0].x + 1);
    Text := ltxt;
    fCursorPos.y := fSelectText[0].y - 1;
    fSelectText[0] := point(-1, -1);
  end;
  ltxt := Text;
  Insert(ch, ltxt, CursorPos.y + 1);
  Text := ltxt;
  inc(fCursorPos.y);
  cchart(chart).needRedraw := true;
end;

procedure cLabel.DoOnMove(p: point2);
begin
  inherited;
  if fdrag then
  begin
    if assigned(fOnMove) then
    begin
      fOnMove(self);
    end;
  end;
end;

procedure cLabel.DoOnBtnUp(p: point2);
var
  rect: trect;
begin
  if (not fDblClick) and (fDragBegin.x = fDragEnd.x) then
  begin
    fSelectText[0] := point(-1, -1);
    cchart(chart).needRedraw := true;
  end;
  if fdrag then
  begin
    //m_userOffset.x := m_StartuserOffset.x + fDragEndI.x - fDragBeginI.x;
    //m_userOffset.y := m_StartuserOffset.y + fDragEndI.y - fDragBeginI.y;
    //m_StartuserOffset := m_userOffset;
  end;
  inherited;
end;

procedure cLabel.DoOnExit;
begin
  inherited;
  fSelectText[0] := point(-1, -1);
  fCursorPos.y := 0;
  cchart(chart).needRedraw := true;
  fdrag := false;
end;

procedure cLabel.DoOnMouseLeave;
begin
  inherited;
end;

procedure cLabel.SetCursPos(pos: tpoint);
begin
  fCursorPos := pos;
  if cchart(chart) <> nil then
  begin
    cchart(chart).needRedraw := true;
  end;
end;

procedure cLabel.SetTransparent(b: boolean);
begin
  fTransparent := b;
  if cchart(chart) <> nil then
  begin
    cchart(chart).needRedraw := true;
  end;
end;

function cLabel.GetTextHeigth: double;
var
  rowH: double;
begin
  rowH := EvalRowHeigth;
  result := rowH * ((fText.count-1)*m_intervalScale+1);
end;

function cLabel.EvalRowHeigth(p_font: cfont): double;
var
  p: cbasepage;
begin
  p := cbasepage(getpage);
  result := p_font.cfg.height * (2 / p.getheight);
end;

function cLabel.EvalRowHeigth: double;
var
  font: cfont;
begin
  font := GetFont(fontIndex);
  if font <> nil then
    result := EvalRowHeigth(font)
  else
    result := 0;
end;

function cLabel.GetTextWidth: single;
var
  font: cfont;
  lscale: point2;
  rw, maxRW: double;
  I: integer;
begin
  font := GetFont(fontIndex);
  result := 0;
  if font <> nil then
  begin
    lscale := font.scaleVectorText;
    font.scaleVectorText := scale;
    maxRW := 0;
    for I := 0 to fText.count - 1 do
    begin
      rw := font.getwidth(fText.Strings[I]);
      if rw > maxRW then
        maxRW := rw;
    end;
    result := maxRW;
    font.scaleVectorText := lscale;
  end;
end;

end.
