unit uFontMng;

interface
uses
  uText, classes, windows, sysutils;

type
  cFontMng = class(TstringList)
  public
    constructor create;
    destructor destroy;
    function font(i:integer):cfont;
    // ������� �����: ��� ������, ������, ������ ��������
    // ������, ������ � ������� ������, �����( ������������/ ������/ ������)
    function AddFont(pname:string; index:integer; p_dc:hdc;
                     isize, width, weight, style:integer; vectortype:boolean):cfont;
  end;

implementation

constructor cFontMng.create;
begin
  inherited;
  sorted:=true;
end;

destructor cFontMng.destroy;
var
  I: Integer;
  font:cfont;
begin
  for I := 0 to Count - 1 do
  begin
    font:=cfont(objects[i]);
    font.Destroy;
  end;
  inherited;
end;

function cFontMng.font(i:integer):cfont;
var
  str:string;
  j:integer;
begin
  result:=nil;
  str:=inttostr(i);
  for j:=0 to Count-1 do
  begin
    if (strings[j]=str) then
    begin
      result:=cfont(objects[j]);
      exit;
    end;
  end;
end;

function cFontMng.AddFont(pname:string;index:integer;p_dc:hdc;isize,width,weight,style:integer;vectortype:boolean):cfont;
begin
  result:=cFont.create(pname,index, p_dc);
  result.vectortype:=vectortype;
  result.setfont(isize,width,weight,style, vectortype);
  AddObject(inttostr(index),result);
end;

end.
