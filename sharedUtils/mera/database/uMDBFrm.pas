unit uMDBFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, VirtualTrees, uVTServices, ComCtrls, uBtnListView,
  Buttons, uMeasureBase, ImgList,
  uBaseObjService, uBaseObj, ShellAPI,uMDBTestObjFrame,uMDBBaseObjFrame,
  uComponentServises, uMDBRegObjFrame;

type
  TMDBFrm = class(TForm)
    TopPanel: TPanel;
    BaseFolderEdit: TEdit;
    BaseFolderLabel: TLabel;
    mdbPanel: TPanel;
    mdbTV: TVTree;
    BaseFolderBtn: TButton;
    PropertiesPanel: TPanel;
    PropertiesLV: TBtnListView;
    PropertiesTopPanel: TPanel;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    BottonPanel: TPanel;
    ZipBtn: TSpeedButton;
    FindPageControl: TPageControl;
    ObjPage: TTabSheet;
    FindNameLabel: TLabel;
    FindNameEdit: TEdit;
    TestPage: TTabSheet;
    FindTestTypeLabel: TLabel;
    FindTestTypeCB: TComboBox;
    RegPage: TTabSheet;
    WinPosBtn: TSpeedButton;
    ObjPropsGB: TGroupBox;
    FindTestDateRG: TRadioGroup;
    FindTestDateLabel: TLabel;
    FindTestDate1: TDateTimePicker;
    FindTestDate2: TDateTimePicker;
    ShowChildsCB: TCheckBox;
    Splitter1: TSplitter;
    procedure ZipBtnClick(Sender: TObject);
    procedure FindNameEditChange(Sender: TObject);
    procedure WinPosBtnClick(Sender: TObject);
    procedure mdbTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    m_db:cMBase;
    curfr:TMDBBaseObjFrame;
    m_frames:tstringlist;
    procedure ShowObjectProps(obj:cXmlFolder);
    procedure ShowTestTypes;
    function CheckFlt(obj:cbaseobj; HideParent:boolean):boolean;
    function CheckObj(obj:cbaseobj):boolean;
    function CheckTest(obj:cbaseobj; HideParent:boolean):boolean;
    function CheckReg(obj:cbaseobj; HideParent:boolean):boolean;
    function UseFlt:boolean;
    function getObj(o:cbaseobj):cObjFolder;
    function getTest(o:cbaseobj):cTestFolder;
    function getReg(o:cbaseobj):cRegFolder;
    procedure doFlt(sender:tobject);
    procedure Addframe(f:TMDBBaseObjFrame);
    procedure destroyframes;
  public
    procedure ShowMDB(db:cMBase);
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

  function CheckDate(d, d1, d2:tdatetime; checktype:integer):boolean;

var
  MDBFrm: TMDBFrm;

const
  c_FindDate_NotUsed=0;
  c_FindDate_T1=1;
  c_FindDate_T2=2;
  c_FindDate_T1T2=3;

implementation

{$R *.dfm}

// ����������� ����� ������
procedure FindInTree( Tree: TVirtualStringTree; Node: PVirtualNode;
                      var Hide: boolean );
var
  childNode:pvirtualNode;
  str:string;
  d: pnodedata;
  obj:cbaseobj;
  hideChild,
  // ���� false �� ����� ������������ ���� ���� ��� �������� �������� ��������
  HideThisNode,
  // ���� �� �������� �������
  childVisible:boolean;
begin
  childVisible:=false;
  d := Tree.GetNodeData( Node );
  if Assigned( d ) then
  begin
    obj:=cbaseobj(d.data);
    if not MDBFrm.UseFlt then
      Hide := false
    else
    begin
      // �������� �� ������������ �������
      Hide :=not MDBFrm.checkflt(obj, hide);
    end;
    HideThisNode:=hide;
    if (Node.ChildCount > 0) then
    begin
      childNode:=Tree.GetFirstChild(Node);
      while childNode<>nil do
      begin
        hideChild:=true;
        FindInTree( Tree, childNode, hideChild );
        if not hideChild then
        begin
          childVisible:=true;
        end;
        childnode:=childnode.NextSibling;
      end;
    end;
    if (not hideThisNode) or (childVisible)
    then
    begin
      Node.States := Node.States + [vsVisible];
      hide:=false;
    end
    else
    begin
      Node.States := Node.States - [vsVisible]
    end;
    // �� �������� ���� � ��� ������������
    if tree.GetNodeLevel(node)=0 then
    begin
      Node := Node.NextSibling;
      if node<>nil then
      begin
        FindInTree(tree,node, hide);
      end;
    end;
  end;
  str:=obj.name;
  setlength(str,1);
end;



{ TMDBFrm }

function TMDBFrm.CheckObj(obj: cbaseobj): boolean;
begin
  result:=false;
  if obj is cObjFolder then
  begin
    if pos(FindNameEdit.text, cObjFolder(obj).name)>0 then
    begin
      result:=true;
    end;
  end;
end;


function CheckDate(d, d1, d2:tdatetime;checktype:integer):boolean;
begin
  result:=false;
  case checkType of
    c_FindDate_NotUsed: result:=true;
    c_FindDate_T1:
    begin
      if d>d1 then
        result:=true;
    end;
    c_FindDate_T2:
    begin
      if d<d2 then
        result:=true;
    end;
    c_FindDate_T1T2:
    begin
      if d1<d then
      begin
        if d2>d then
        begin
          result:=true;
        end;
      end;
    end;
  end;
end;

function TMDBFrm.CheckTest(obj: cbaseobj; HideParent:boolean): boolean;
var
  d:tdatetime;
begin
  result:=false;
  if obj is cTestFolder then
  begin
    result:=CheckDate(cTestFolder(obj).datetime,FindTestDate1.DateTime,FindTestDate2.DateTime, FindTestDateRG.ItemIndex);
    if result then
    begin
      if FindTestTypeCB.Text<>'' then
      begin
        if cTestFolder(obj).ObjType<>FindTestTypeCB.Text then
        begin
          result:=false;
          exit;
        end;
      end;
      if FindNameEdit.text<>'' then
      begin
        if pos(FindNameEdit.text,obj.caption)>0 then
        begin
          result:=true;
        end
        else
        begin
          result:=false;
        end;
      end;
    end;
  end;
end;

procedure TMDBFrm.doFlt(sender: tobject);
var
  hide:boolean;
begin
  hide:=true;
  FindInTree( mdbTV, mdbTV.GetFirstChild( nil ), Hide );
  mdbTV.Invalidate;
end;

procedure TMDBFrm.FindNameEditChange(Sender: TObject);
begin
  doflt(sender);
end;

function TMDBFrm.CheckReg(obj: cbaseobj; HideParent:boolean): boolean;
var
  d:tdatetime;
  nameflt:boolean;
begin
  result:=false;
  if obj is cRegFolder then
  begin
    result:=CheckDate(cRegFolder(obj).datetime, FindTestDate1.DateTime,
                                                FindTestDate2.DateTime,
                                                FindTestDateRG.ItemIndex);
    if not result then
      exit;
    nameflt:=false;
    if findnameedit.Text<>'' then
    begin
      if pos(lowercase(findnameedit.Text),lowercase(obj.caption))>0 then
        nameflt:=true
      else
        nameflt:=false;
    end;
    if ShowChildsCB.checked then
    begin
      // ���� ������������ �������� � �������� �������� ���������� ��������,
      // �� �������� ������ ������ �� ����
      if not HideParent then
      begin

      end
    end
    else
    begin
      result:=result and nameflt;
    end;
  end;
end;

constructor TMDBFrm.create(aowner: tcomponent);
var
  f:TMDBBaseObjFrame;
begin
  inherited;
  m_frames:=TStringList.Create;
  f:=TMDBBaseObjFrame.Create(nil);
  Addframe(f);

  f:=TMDBTestObjFrame.Create(nil);
  Addframe(f);

  f:=TMDBRegObjFrame.Create(nil);
  Addframe(f);
end;

destructor TMDBFrm.destroy;
begin
  destroyframes;
  m_frames.Destroy;
  inherited;
end;

procedure TMDBFrm.destroyframes;
var
  f:TMDBBaseObjFrame;
  i:integer;
begin
  for I := 0 to m_frames.Count - 1 do
  begin
    f:=TMDBBaseObjFrame(m_frames.Objects[i]);
    f.Destroy;
  end;
  m_frames.Clear;
end;



procedure TMDBFrm.Addframe(f: TMDBBaseObjFrame);
begin
  f.Parent:=ObjPropsGB;
  f.Visible:=false;
  m_frames.AddObject(f.ClassName, f);
end;

procedure TMDBFrm.ShowObjectProps(obj: cXmlFolder);
var
  I: Integer;
  f:TMDBBaseObjFrame;
begin
  if curfr<>nil then
    curfr.visible:=false;
  for I := 0 to m_frames.Count - 1 do
  begin
    f:=TMDBBaseObjFrame(m_frames.Objects[i]);
    if f.SupportObj(obj) then
    begin
      f.Visible:=true;
      f.showObjProps(obj);
      curfr:=f;
    end;
  end;
end;


function TMDBFrm.CheckFlt(obj: cbaseobj; HideParent:boolean): boolean;
begin
  result:=false;
  if obj is cObjFolder then
  begin
    result:=CheckObj(cObjFolder(obj));
  end
  else
  begin
    if obj is cTestFolder then
    begin
      result:=CheckTest(cTestFolder(obj), HideParent);
    end
    else
    begin
      if obj is cRegFolder then
      begin
        result:=CheckReg(cRegFolder(obj), HideParent);
      end;
    end;
  end;
end;

function TMDBFrm.getObj(o:cbaseobj):cObjFolder;
begin
  result:=nil;
  if o is cObjFolder then
    result:=cObjFolder(o)
  else
  begin
    result:=cObjFolder(o.GetParentByClassName('cObjFolder'));
  end;
end;

function TMDBFrm.getReg(o: cbaseobj): cRegFolder;
begin
  result:=nil;
  if o is cTestFolder then
  begin
    result:=cRegFolder(o);
  end;
end;

function TMDBFrm.getTest(o:cbaseobj):cTestFolder;
begin
  result:=nil;
  if o is cTestFolder then
  begin
    result:=cTestFolder(o);
  end
  else
  begin
    result:=cTestFolder(o.GetParentByClassName('cTestFolder'));
  end;
end;

procedure TMDBFrm.mdbTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  n:pvirtualnode;
  d:pNodeData;
  obj:cXmlFolder;
begin
  n:=GetSelectNode(mdbTV);
  if n<>nil then
  begin
    d:=mdbTV.GetNodeData(n);
    obj:=cxmlfolder(d.data);
    ShowObjectProps(obj);
  end;
end;

procedure TMDBFrm.ShowMDB(db: cMBase);
begin
  m_db:=db;
  basefolderedit.text:=db.m_BaseFolder.Absolutepath;
  showInVTreeView(mdbTV, db.m_BaseFolder, ImageList_16);
  ShowTestTypes;
  //FormStyle:=fsStayOnTop;
  show;
end;

procedure TMDBFrm.ShowTestTypes;
var
  I: Integer;
  s:string;
begin
  for I := 0 to (cBaseMeaFolder(m_db.m_BaseFolder).m_TestTypes.Count - 1) do
  begin
    s:=cBaseMeaFolder(m_db.m_BaseFolder).m_TestTypes.Strings[i];
    FindTestTypeCB.Items.Add(s);
  end;
end;

function TMDBFrm.UseFlt: boolean;
begin
  result:=false;
  if FindNameEdit.Text<>'' then
    result:=true;

  if FindTestDateRG.ItemIndex<>c_FindDate_NotUsed then
    result:=true;
end;

// ���������� true ���� ���� ��� ��� �������� ������
function nodeselected(n:pvirtualnode):boolean;
begin
  result:=false;
  if vsSelected in n.States then
  begin
    result:=true;
    exit;
  end;
  while n.Parent<>nil do
  begin
    n:=n.Parent;
    if vsSelected in n.States then
    begin
      result:=true;
      exit;
    end;
  end;
end;

procedure TMDBFrm.WinPosBtnClick(Sender: TObject);
var
  I, j: Integer;
  n, next: PVirtualNode;
  obj: cbaseobj;
  Data: PNodeData;
  fpath:string;
begin
  for I := 0 to mdbTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := mdbTV.GetNext(n)
    else
      n := mdbTV.GetFirst;
    if vsSelected in n.States then
    begin
      Data := mdbTV.GetNodeData(n);
      next := mdbTV.GetNextSelected(n, true);
      obj := cbaseobj(Data.Data);
      if obj is cRegFolder then
      begin
        for j := 0 to cRegFolder(obj).m_signals.Count - 1 do
        begin
          fpath:=cRegFolder(obj).getMeraPath(j);
          if fileexists(fpath) then
          begin
            ShellExecute(0,nil,pwidechar(fpath),nil,nil, SW_HIDE);
          end;
        end;
      end;
    end;
  end;
end;


procedure TMDBFrm.ZipBtnClick(Sender: TObject);
var
  I: Integer;
  n, next: PVirtualNode;
  obj: cbaseobj;
  Data: PNodeData;
begin
  for I := 0 to mdbTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := mdbTV.GetNext(n)
    else
      n := mdbTV.GetFirst;
    if nodeselected(n) then
    begin
      Data := mdbTV.GetNodeData(n);
      next := mdbTV.GetNextSelected(n, true);
      obj := cbaseobj(Data.Data);
      if obj is cRegFolder then
      begin
        cRegFolder(obj).MakeZip;
        Data.ImageIndex:=obj.imageindex;
        mdbTV.Refresh;
      end;
    end;
  end;
end;

end.
