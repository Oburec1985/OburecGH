unit uXMLBase;

interface
uses
  classes, sysutils, dialogs, NativeXML, uBaseObjMng, uBaseObj;

type
  cTestList = class(cBaseObjList)
  protected
    procedure setcomparetype(t:integer);override;
  end;

  cXMLTest = class;

  cXmlDB =class(cBaseObjMng)
  private
    // хранит признак как генерить имя
    // Имя объекта
    // Имя испытания
    // дата испытания
    // папка с базой данных
    // константная строка задающая например тип испытания (может быть несколько)
    pathOrder: tstringlist;
    // полный путь к базе данных
    fpath:string;
    // список объектов
    Tests:cTestList;
  public
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    procedure regObjClasses;override;
  private
  public
    constructor create;override;
    destructor destroy;override;
    procedure clear;override;
    function GenPath(test:cXMLTest):string;
    // сохранить базу данных
    procedure save;
    // загрузить базу
    procedure load;
    procedure removeObj(obj:cBaseObj);override;
    procedure Init(path:string);
  end;

  // информация которая пишется для испытания
  cXMLTest = class (cBaseObj)
    // дата испытания
    Date:tDateTime;
  public
    // получить путь к испытанию
    function GenPath:string;
  end;

  // информация которая пишется для испытываемого объекта
  cXMLTestObj = class (cBaseObj)
    // серийный номер
    sn:string;
  end;

  c_DateComparator = 3;

  Function DateComparator(p1,p2:pointer):integer;

implementation

function DateComparator(p1,p2:pointer):integer;
begin
  if cXMLTest(p1).Date>cXMLTest(p2).Date then
    result:=1
  else
  begin
    if cXMLTest(p1).Date<cXMLTest(p2).Date then
      result:=-1
    else
    begin
      result:=0;
    end;
  end;
end;

procedure cTestList.setcomparetype(t: Integer);
begin
  if t=c_DateComparator then
  begin
    comparator:=datecomparator;
  end
  else
    inherited;
end;

constructor cXmlDB.create;
begin
  pathOrder:=tstringlist.Create;
  pathOrder.Sorted:=false;

  Tests:=cBaseObjList.create;
  tests.sorted:=true;
  tests.destroydata:=false;
  inherited;
end;

destructor cXmlDB.destroy;
begin
  pathOrder.Destroy;
  tests.destroy;
  inherited;
end;

procedure cXmlDB.clear;
begin

end;

procedure cXmlDB.Init(path:string);
begin
  fpath:=path;
end;

procedure cXmlDB.removeObj(obj:cBaseObj);
begin
  if obj is cXMLTest then
  begin
    Tests.RemoveObj(obj);
  end;
  inherited removeobj(obj);
end;

procedure cXmlDB.AddBaseObjInstance(obj:cbaseobj);
var
  I: Integer;
begin
  if obj is cxmlTestObj then
  begin
    for I := 0 to obj.childCount - 1 do
    begin
      Tests.Add(obj.getChild(i));
    end;
  end;
  inherited;
end;

procedure cXmlDB.regObjClasses;
begin
  inherited;
  regclass(cXMLTestObj);
  regclass(cXMLTest);
end;

// сохранить базу данных
procedure cXmlDB.save;
begin
  SaveToXML(fpath, 'XMLBase');
end;

// загрузить базу
procedure cXmlDB.load;
begin
  LoadFromXML(fpath, 'XMLBase');
end;

function cXMLTest.GenPath:string;
var
  db:cXmlDB;
begin
  db:=getmng;
  result:=extractfiledir(db.fpath)+'\'+datetostr+'\'+name;
end;



end.
