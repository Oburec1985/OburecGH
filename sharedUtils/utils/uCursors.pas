unit uCursors;
{$R ./files/res/CURSORS.res } //прикомпиллируем ресурсы-картинки

interface
uses
  SysUtils, windows, classes, uCommonTypes;
type

  cCursor = class
  public
    index:cardinal;
    HIcon:integer;
    Name:string;
  public
    constructor create(p_name:string);
  end;

  // Загрузка курсора из файла
  function LoadCursors:tStringlist;
  procedure SetCursorByHinst(hicon:integer; h:thandle);

implementation
uses
  forms;

const
  constWindowStyle = 'WindowStyle';
  constControlConfig = 'ControlConfig';
  defaultpath = '.\files\UICfg.ini';

  axisX:point3 = (x:1;y:0;z:0);
  axisY:point3 = (x:0;y:1;z:0);
  axisZ:point3 = (x:0;y:0;z:1);
  axisO:point3 = (x:0;y:0;z:0);

procedure SetCursorByHinst(hicon:integer; h:thandle);
begin
  hicon:=screen.Cursors[hicon];
  SetClassLong(h,GCL_HCURSOR,hicon);
end;

constructor cCursor.create(p_name:string);
begin
  name:=p_name;
  //HIcon:=LoadCursor(hInstance, PAnsiChar(name));
  HIcon:=LoadCursor(hInstance, @(name[1]));
end;

function LoadCursors:tStringlist;
var cursors:tStringlist;
    curs:cCursor;
begin
  cursors:=tStringlist.create;

  curs:=cCursor.create('PAN_CURSOR');
  cursors.AddObject(curs.Name,curs);
  curs.index:=cursors.Count;

  curs:=cCursor.create('ZOOM_CURSOR');
  cursors.AddObject(curs.Name,curs);
  curs.index:=cursors.Count;

  result:=cursors;
end;


end.
