unit uBlade;

interface
uses
  classes;

type
  cBlade = class
  public
    // номер лопатки
    index:integer;
    // смещение лопатки относительно тахо в градусах
    Offset:single;
  end;

  cBlades = class(tlist)
  protected
    procedure setcount(c:integer);
    function getcount:integer;
    function getBlade(i:integer):cBlade;
    procedure deleteBlade(i:integer);
  public
    property BladeCount:integer read getcount write setcount;
    constructor create;
    destructor destroy;
  end;

implementation

constructor cBlades.create;
begin
  inherited;
end;

destructor cBlades.destroy;
begin
  inherited;
end;

function cBlades.getcount:integer;
begin
  result:=count;
end;

function cBlades.getBlade(i:integer):cBlade;
begin
  if i<count then
  begin
    result:=cBlade(items[i]);
  end;
end;

procedure cBlades.deleteBlade(i:integer);
var
  bl:cblade;
begin
  if i<count then
  begin
    bl:=getblade(i);
    bl.destroy;
    delete(i);
  end;
end;

procedure cBlades.setcount(c:integer);
var a:single;
    i:integer;
    bl:cblade;
    lastbl:cblade;
begin
  lastbl:=getBlade(count-1);
  a:=(360 - lastbl.Offset)/abs(c-lastbl.index+1);
  if c>count then
  begin
    i:=1;
    while count<>c do
    begin
      bl:=cblade.create;
      bl.Offset:=lastbl.offset+a*i;
      bl.index:=lastbl.index+i;
      inc(i);
    end;
  end
  else
  begin
    //while count<> do

  end;
end;

end.
