unit uSkinFrame;

interface

uses
  Windows, messages, SysUtils, Classes, Controls, Forms,
  ComCtrls, uBtnListView, StdCtrls, uSpin, dialogs,mathfunction,
  uUI, uNodeObject, uEventList, uObjectTypes, uBaseDeformer, umeshobr,
  DCL_MYOWN, uglFrameListener, uselectools, uglEventTypes, u3dTypes, uscenemng, uskin;

type

  cEditFrameListener = class(cglFrameListener)
  public
    procedure wndproc(msg:tmessage; mouse:mousestruct);override;
  end;

  TSkinFrame = class(TFrame)
    GroupBox1: TGroupBox;
    MeshesCB: TComboBox;
    AddMeshBtn: TButton;
    DelMeshBtn: TButton;
    Label2: TLabel;
    MeshWeight: TFloatSpinEdit;
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
    BonesLV: TBtnListView;
    procedure BonesLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure AddMeshBtnClick(Sender: TObject);
    procedure AddPointBtnClick(Sender: TObject);
  public
    skin:cskin;
  private
    ui:cUI;
    fr:cEditFrameListener;
    // Ссылка на текущий деформируемый объект
    curMesh:cdeformmesh;
  private
    // Событие которое происходит при выделении объекта
    procedure SelObjNotify(Sender: TObject);
    // Событие которое происходит при выделении вершины объекта
    procedure SelPointNotify(Sender: TObject);
    // отобразить список точек на которые влияет деформатор
    procedure ShowPoints(b:cbone);
  public
    procedure OnHide;  
    // Отобразить модификатор
    procedure Show;
    procedure LincScene(pUI:cui);
  end;

implementation

{$R *.dfm}

procedure cEditFrameListener.wndproc(msg:tmessage; mouse:mousestruct);
var
  selectp:integer;
begin
  case msg.msg of
    WM_LBUTTONDOWN:
    begin
      // Выделение вершин редактируемого объекта
      //if curMesh<>nil then
      //begin
        //selectp:=findvertex(mouse.x,mouse.y,5,cUInterface(ui).editMesh);
        //if selectp<>-1 then
        //begin
      //    cUInterface(ui).editMesh.mesh.selectp:=selectp;
          //cUInterface(ui).callevents(E_glSelectMeshPoint);
      //    cUInterface(ui).needredraw:=true;
        //end;
      //end;
    end;
  end;
end;

procedure TSkinFrame.OnHide;
begin
  if curMesh<>nil then
  begin
    //ui.editMesh:=nil;
    curMesh:=nil;
  end;
end;

// заполнение структуры выделенного объекта
procedure TSkinFrame.SelObjNotify(Sender: TObject);
var sc:cscene;
    i:integer;
    obj:cNodeObject;
begin
  sc:=cscene(sender);
  MeshesCB.Clear;
  for I := 0 to sc.Objects.Count - 1 do
  begin
    obj:=cnodeobject(sc.GetObj(i));
    if obj.objtype=constmesh then
    begin
      MeshesCB.AddItem(obj.name,obj);
    end;
  end;
end;

// Событие которое происходит при выделении вершины объекта
procedure TSkinFrame.SelPointNotify(Sender: TObject);
var ui:cui;
    i:integer;
    obj:cNodeObject;
begin
  ui:=cui(sender);
  //pointindex.IntNum:=ui.editMesh.mesh.selectp;
end;

procedure TSkinFrame.Show;
var
  bone:cbone;
  obj:cmeshobr;
  i:integer;
  li:tlistitem;
begin
  BonesLV.clear;
  for I := 0 to skin.Count - 1 do
  begin
    bone:=skin.getbone(i);
    li:=BonesLV.items.Add;
    li.Data:=bone;
    BonesLV.SetSubItemByColumnName('Список костей',bone.name,li);
  end;
end;

procedure TSkinFrame.ShowPoints(b:cbone);
var i:integer;
    p:cDeformPoint;
    li:tlistitem;
    obj:cmeshobr;
begin
  obj:=skin.mesh;
  PointsCountEdit.IntNum:=b.count;
  PointsLV.clear;
  for I := 0 to b.Count - 1 do
  begin
    p:=b.getpoint(i);
    li:=PointsLV.items.Add;
    li.Data:=p;
    PointsLV.SetSubItemByColumnName('Список точек',inttostr(p.p),li);
    PointsLV.SetSubItemByColumnName('Вес',floattostr(p.weight),li);
  end;
end;

procedure TSkinFrame.AddMeshBtnClick(Sender: TObject);
var
  mesh:cDeformMesh;
  obj:cnodeobject;
begin
  obj:=cnodeobject(meshesCB.Items.Objects[meshesCB.ItemIndex]);
  if obj.objtype=constmesh then
  begin
    //mesh.bone:=cnodeobject(deformer.owner);
    //mesh:=cDeformMesh.create(cnodeobject(deformer.owner));
    //mesh.mesh:=cmeshobr(obj);
    //deformer.AddDeformMesh(mesh);
    Show;
  end
  else
    showmessage('Деформировать можно только геометрический объект');
end;

procedure TSkinFrame.AddPointBtnClick(Sender: TObject);
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
    //ShowPoints();
  end;
end;

procedure TSkinFrame.LincScene(pUI:cui);
begin
  UI:=pUI;
  ui.EventList.AddEvent('TDeformFrame_OnSelect',E_glLoadScene,SelObjNotify);
  ui.EventList.AddEvent('E_SelectMeshPoint',E_glSelectMeshPoint,SelPointNotify);
  if fr=nil then
  begin
    fr:=cEditFrameListener.create(ui,'EditSkinFrListener');
    ui.framelistener.add(fr);
  end;
end;

procedure TSkinFrame.BonesLVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  b:cbone;
begin
  if item.Data<>nil then
  begin
    b:=cbone(item.data);
    ShowPoints(b);
    //ui.editMesh:=curMesh.mesh;
  end;
end;

end.
