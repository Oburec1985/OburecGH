unit uTreeNode;

interface
uses
  classes, usetlist, uEventList;

type
  cTreeNode = class
  protected
    // ��� ����
    m_name:string;
    // ����� ��� ����������� � �����������
    m_caption:string;
    // ���������� � ���������� �����������
    m_visible:boolean;
    // ������������ ����
    m_parent:cTreeNode;
    // ������ �������� �����
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
