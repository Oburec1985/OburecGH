unit uTreeNode;

interface
uses
  classes, usetlist, uEventList;

type
  cTreeNode = class
  protected
    // имя узла
    m_name:string;
    // метка для отображения в компоеннтах
    m_caption:string;
    // отображать в визуальных компонентах
    m_visible:boolean;
    // родительский узел
    m_parent:cTreeNode;
    // список дочерних узлов
    m_childrens:cSetList;
  public
  public
    function childCount:integer;
    procedure addchild(obj:cTreeNode);
    function getchild(i:integer):cTreeNode;
    constructor create(parent:cTreeNode);
    destructor destroy;
  end;

implementation

{ cTreeNode }

procedure cTreeNode.addchild(obj: cTreeNode);
begin

end;

function cTreeNode.childCount: integer;
begin

end;

constructor cTreeNode.create(parent: cTreeNode);
begin

end;

destructor cTreeNode.destroy;
begin

end;

function cTreeNode.getchild(i: integer): cTreeNode;
begin

end;

end.
