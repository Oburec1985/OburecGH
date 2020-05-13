unit uDeformerFrame;

interface

uses
  Windows, messages, SysUtils, Classes, Controls, Forms,
  ComCtrls, uBtnListView, StdCtrls, uSpin, dialogs,mathfunction,
  uui, uNodeObject, uEventList, uObjectTypes, uBaseDeformer, umeshobr,
  DCL_MYOWN, uglFrameListener, uselectools, uglEventTypes, u3dTypes;

type

  cEditFrameListener = class(cglFrameListener)
  public
    // редактируемый объект
    editMesh:cnodeobject;
    frame:tframe;
  public
    procedure wndproc(msg:tmessage; mouse:mousestruct);override;
  end;

  TDeformerFrame = class(TFrame)
    GroupBox1: TGroupBox;
    bonesCB: TComboBox;
    AddMeshBtn: TButton;
    DelMeshBtn: TButton;
    Label2: TLabel;
    MeshWeight: TFloatSpinEdit;
    MeshesLV: TBtnListView;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    PointWeight: TFloatSpinEdit;
    PointsLV: TBtnListView;
    PointIndex: TIntEdit;
    Label3: TLabel;
    PointsCountEdit: TIntEdit;
    Label4: TLabel;
    procedure MeshesLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure AddMeshBtnClick(Sender: TObject);
    procedure AddPointBtnClick(Sender: TObject);
  public
    deformer:cBaseDeformer;
  private
    ui:cui;
    //
    fr:cEditFrameListener;
    // Ссылка на текущий деформируемый объект
    curMesh:cdeformmesh;
  private
    procedure ShowBonesCB;
    // Событие которое происходит при выделении объекта
    procedure SelObjNotify(Sender: TObject);
    // Событие которое происходит при выделении вершины объекта
    procedure SelPointNotify(Sender: TObject);
    // отобразить список точек на которые влияет деформатор
    procedure ShowPoints(mesh:cDeformMesh);
  public
    procedure OnHide;
    // Отобразить модификатор
    procedure Show;
    procedure LincScene(pUI:cui);
  end;

implementation

{$R *.dfm}

procedure cEditFrameListener.wndproc(msg:tmessage; mouse:mousestruct);
var selectp:tpoint;
begin
  case msg.msg of
    WM_LBUTTONDOWN:
    begin
      LockMouse:=frame.Visible;
      // Выделение вершин редактируемого объекта
      if editmesh<>nil then
      begin
        selectp:=findvertex(mouse.x,mouse.y,5,editMesh);
        if selectp.x<>-1 then
        begin
          cmeshobr(editMesh).mesh.selectp:=selectp.x;
          cui(ui).scene.Events.CallAllEvents(E_glSelectMeshPoint);
          cui(ui).needredraw:=true;
        end;
      end;
    end;
  end;
end;

procedure TDeformerFrame.ShowBonesCB;
var
  i:integer;
  obj:cnodeobject;
begin
  for i:=0 to ui.scene.count-1 do
  begin
    obj:=cnodeobject(ui.scene.getobj(i));
    if obj<>ui.scene.World then
      bonesCB.AddItem(obj.name, obj);
  end;
end;

procedure TDeformerFrame.OnHide;
begin
  if curMesh<>nil then
  begin
    //ui.:=nil;
    curMesh:=nil;
  end;
end;

// заполнение структуры выделенного объекта
procedure TDeformerFrame.SelObjNotify(Sender: TObject);
var
  i:integer;
  obj:cNodeObject;
begin
  ShowBonesCB;
  if ui.selectCount>0 then
  begin
    obj:=ui.getselected(0);
    if obj is cmeshobr then
      fr.editMesh:=obj;
  end;
end;

// Событие которое происходит при выделении вершины объекта
procedure TDeformerFrame.SelPointNotify(Sender: TObject);
var ui:cui;
    i:integer;
    obj:cNodeObject;
begin
  if fr.editMesh<>nil then
  begin
    if fr.editMesh is cmeshobr then
    begin
      pointindex.IntNum:=cmeshobr(fr.editMesh).mesh.selectp;
    end;
  end;
end;

procedure TDeformerFrame.Show;
var meshe:cdeformmesh;
    obj:cmeshobr;
    i:integer;
    li:tlistitem;
begin
  MeshesLV.Clear;
  for I := 0 to deformer.Count - 1 do
  begin
    meshe:=deformer.getdeformmesh(i);
    obj:=meshe.mesh;
    li:=MeshesLV.items.Add;
    li.Data:=meshe;
    MeshesLV.SetSubItemByColumnName('Список объектов',obj.name,li);
  end;
end;

procedure TDeformerFrame.ShowPoints(mesh:cDeformMesh);
var i:integer;
    p:cDeformPoint;
    li:tlistitem;
    obj:cmeshobr;
begin
  obj:=mesh.mesh;
  PointsCountEdit.IntNum:=obj.mesh.VertexCount;
  PointsLV.clear;
  for I := 0 to mesh.Count - 1 do
  begin
    p:=mesh.getpoint(i);
    li:=PointsLV.items.Add;
    li.Data:=p;
    PointsLV.SetSubItemByColumnName('Список точек',inttostr(p.p),li);
    PointsLV.SetSubItemByColumnName('Вес',floattostr(p.weight),li);
  end;
end;

procedure TDeformerFrame.AddMeshBtnClick(Sender: TObject);
var mesh:cDeformMesh;
    obj:cnodeobject;
begin
  obj:=cnodeobject(BonesCB.Items.Objects[BonesCB.ItemIndex]);
  if obj.objtype=constmesh then
  begin
    mesh.bone:=cnodeobject(deformer.owner);
    mesh:=cDeformMesh.create(cnodeobject(deformer.owner));
    mesh.mesh:=cmeshobr(obj);
    deformer.AddDeformMesh(mesh);
    Show;
  end
  else
    showmessage('Деформировать можно только геометрический объект');
end;

procedure TDeformerFrame.AddPointBtnClick(Sender: TObject);
var mesh:cDeformMesh;
    p:cdeformpoint;
    i,j,ind,len:integer;
begin
  if curMesh<>nil then
  begin
    for I := 0 to curmesh.mesh.mesh.VertexCount - 1 do
    begin
      ind:=curmesh.mesh.mesh.UnicVert[i].Pointers[0];
      if eqvP3(VtoP3(curmesh.mesh.mesh.DrawArray[PointIndex.IntNum]),
               VtoP3(curmesh.mesh.mesh.DrawArray[ind]),3) then
      begin
        len:=length(curmesh.mesh.mesh.UnicVert[i].Pointers);
        for j := 0 to len - 1 do
        begin
          ind:=curmesh.mesh.mesh.UnicVert[i].Pointers[j];
          if ind<>PointIndex.IntNum then
          begin
            p:=curMesh.AddPoint(ind);
            p.weight:=PointWeight.Value;
          end;
        end;
        break;
      end;
    end;
    p:=curMesh.AddPoint(PointIndex.IntNum);
    p.weight:=PointWeight.Value;
    ShowPoints(curmesh);
  end;
end;

procedure TDeformerFrame.LincScene(pUI:cui);
begin
  UI:=pUI;
  ui.EventList.AddEvent('TDeformFrame_OnSelect',E_glLoadScene+E_glSelectNew,SelObjNotify);
  ui.EventList.AddEvent('E_SelectMeshPoint',E_glSelectMeshPoint,SelPointNotify);
  if fr=nil then
  begin
    fr:=cEditFrameListener.create(ui,'EditFrListener');
    fr.ui:=ui;
    fr.frame:=Self;
    ui.framelistener.add(fr);
  end;
end;

procedure TDeformerFrame.MeshesLVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if item.Data<>nil then
  begin
    curMesh:=cdeformmesh(item.data);
    ShowPoints(curMesh);
    //ui.editMesh:=curMesh.mesh;
  end;
end;

end.
