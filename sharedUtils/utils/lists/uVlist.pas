// ������ ������� ������� (��������������� ������) �������������� ������� �������
unit uVList;

interface
uses
  Windows, SysUtils, Classes, uListMath;
type

  fcomparator = function (p1,p2:pointer):integer;

  cVList<T> = class;
  cVObj<T> = class;

  cVList<T> = class(tlist)
  private
    fsorted:boolean;
  public

  end;

  cVObj<T> = class
    parentList:cVList<T>;
    key:T;
  protected
    procedure setKey(k:pointer);virtual;abstract;
  public
    function compare(k:pointer):integer;overload;virtual;
  end;

implementation

function cVObj<T>.compare(k:pointer):integer;
begin

end;

end.
