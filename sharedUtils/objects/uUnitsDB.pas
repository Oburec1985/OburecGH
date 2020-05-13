unit uUnitsDB;

interface
uses
  NativeXML, classes, usetlist, sysutils;

type
  TUnit=class;

  TUnitSetList = class (csetlist)
  public
    constructor create;override;
  end;

  TCategory = class
  public
    name:string;
    baseUnit:string;
    m_units:TUnitSetList;
  public
    procedure Create(p_type:TCategory;p_name:string;p_base:string;p_scale:double);
    destructor destroy;
    function GetUnit(i:integer):tunit;
  end;

  TUnit = class
  public
    // Множитель для перевода в СИ
    m_scale:double;
    // название
    m_name:string;
    // тип единиц измерения
    m_type:TCategory;
  public
    constructor create(p_type:TCategory;p_name:string;p_scale:double);
  end;

  TUnitsDB = class
  private
    fpath:string;
    m_Categories:tstringlist;
  public
    constructor create(path:string);
    destructor destroy;
    function getCategories(i:integer):TCategory;
    procedure save;
    procedure load;
  end;

implementation

function UnitComparator(p1,p2:pointer):integer;
begin
  if TUnit(p1).m_scale>TUnit(p2).m_scale then
  begin
    result:=1;
  end
  else
  begin
    if TUnit(p1).m_scale<TUnit(p2).m_scale then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

constructor TUnit.create(p_type:TCategory;p_name:string;p_scale:double);
begin

end;

constructor TUnitSetList.create;
begin
  inherited;
  //setComparator:=UnitComparator;
end;

procedure TCategory.Create(p_type:TCategory;p_name:string;p_base:string;p_scale:double);
begin
  baseUnit:=p_base;
  name:=p_name;
  m_units:=TUnitSetList.Create;
end;

destructor TCategory.destroy;
var
  I: Integer;
  u:tunit;
begin
  for I := 0 to m_units.Count - 1 do
  begin
    u:=GetUnit(i);
    u.Destroy;
  end;
  m_units.destroy;
end;

function TCategory.GetUnit(i:integer):tunit;
begin

end;

constructor TUnitsDB.create(path:string);
begin
  fpath:=path;
end;

destructor TUnitsDB.destroy;
var
  I: Integer;
  cat:TCategory;
begin
  for I := 0 to m_Categories.Count - 1 do
  begin
    cat:=getCategories(i);
    cat.destroy;
  end;
  m_Categories.Destroy;
end;

procedure TUnitsDB.load;
begin

end;

function TUnitsDB.getCategories(i:integer):TCategory;
begin
  result:=TCategory(m_Categories.objects[i]);
end;

procedure TUnitsDB.save;
var
  doc:TNativeXml;
  root,node:txmlnode;
  I: Integer;
  dir:string;
  cat:TCategory;
begin
  doc:=TNativeXml.CreateName('Root');
  Doc.XmlFormat := xfReadable;
  dir:=extractfiledir(fpath);
  if not DirectoryExists(dir) then
  begin
    ForceDirectories(dir);
  end;
  root:=doc.Root;
  for I := 0 to m_Categories.Count - 1 do
  begin
    cat:=getCategories(i);
    Node:=Root.NodeNew(cat.name);
    //Node.WriteAttributeString(c_type, obj.classname);
    //Node.WriteAttributeString(c_Node, obj.name);
  end;
  doc.SaveToFile(fpath);
  doc.destroy;
end;

end.
