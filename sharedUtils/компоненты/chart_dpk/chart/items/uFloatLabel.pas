unit uFloatLabel;

interface
uses
  ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, types,
  sysutils, math, uCommonMath, stdctrls, forms, controls, uText, uEventList,
  uChartEvents, classes, dialogs, uGistogram, mathfunction, uSimpleObjects,
  uGraphObj, windows, clipbrd, uLabel;

type
  cFloatLabel = class(clabel)
  protected
    fprec:integer;
    fValue:double;
  protected
    procedure setValue(v:double);
    procedure InsertChar(ch:char);override;
    procedure DoOnKeyEnter(key:word);override;
    procedure DoLincParent; override;
  public
    property Value:double read fValue write setValue;
    property precision:integer read fprec write fprec;
    constructor create;override;
  end;

implementation
uses
  uchart, upage;

procedure cFloatLabel.InsertChar(ch:char);
begin
  if Pos(ch,'0123456789.,-')<1 then
  begin
    exit;
  end;
  if (ch='.') or (ch=',') then
  begin
    if cursorpos.y<=0 then
      exit;
    ch:=DecimalSeparator;
    if pos(ch,text)>0 then
      exit;
  end;
  inherited InsertChar(ch);
end;

procedure cFloatLabel.DoOnKeyEnter(key:word);
begin
  inherited;
  if key=VK_EXECUTE then
  begin
    fvalue:=strtoFloat(text);
  end;
end;

procedure cFloatLabel.setValue(v:double);
begin
  fValue:=v;
  if fprec<>-1 then
    text:=formatstr(v,fprec)
  else
    text:=floattostr(v);
end;

constructor cFloatLabel.create;
begin
  Inherited;
  Value:=0;
end;

procedure cFloatLabel.DoLincParent;
var
  page:cpage;
begin
  inherited;
  // ��������� ����� getparentbyclassname
  page:=cpage(getpage);
  if page<>nil then
    fprec:=page.prec
  else
    fprec:=-1;
end;

end.
