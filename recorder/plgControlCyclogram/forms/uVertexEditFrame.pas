unit uVertexEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, ExtCtrls, StdCtrls, Spin,
  ucommontypes,
  uComponentServises,
  MathFunction,
  uMatrix,
  uSkin, uUI, usceneMng, uRender, uGlEventTypes,
  uNodeObject,
  uObject,
  uMeshObr,
  uShape,
  uBaseDeformer,
  DCL_MYOWN,
  uSpin,
  uRcFunc,
  uRcCtrls;

type
  // объект (кость) управляющий скелетом
  cSkinPoint = class(cObject)
  public
    m_bone:cBone; // информация о кости
    // номер точки
    m_PName:integer;
    m_w:double;
    // деформируемый объект
    m_defObj:cnodeobject;
    PId:tpoint; // вершина скелета
    // теги отвечающие за амплитуду смещения кости
    xTag, yTag, zTag:cTag;
  public
    constructor create;override;
    destructor destroy;override;
  end;

  TVertexEditFrame = class(TFrame)
    TopPanel: TPanel;
    AlPanel: TPanel;
    VertLV: TBtnListView;
    TypeCB: TCheckBox;
    NameEdit: TEdit;
    ObjNameLabel: TLabel;
    PointNumSE: TSpinEdit;
    PintNumLabel: TLabel;
    SkinCB: TCheckBox;
    RightPan: TGroupBox;
    Panel1: TPanel;
    PNameLabel: TLabel;
    WeightLabel: TLabel;
    PointNumEdit: TIntEdit;
    PointWeight: TFloatSpinEdit;
    TagLabel: TLabel;
    AxisLabel: TLabel;
    SkinPointsLV: TBtnListView;
    Label1: TLabel;
    Splitter1: TSplitter;
    AddBtn: TButton;
    PIDLab: TLabel;
    pIdEdit: TEdit;
    AxisCB: TComboBox;
    TagCB: TRcComboBox;
    procedure VertLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AddBtnClick(Sender: TObject);
  public
    m_ui:cUI;
  private
    finit:Boolean;
    m_curObj:cobject;
    // список добавленных вершин
    m_pList:tlist;
    m_skin:cSkin;
    // Id выбраной вершины
    m_Point:TPoint;
    m_frm:tform;
  protected
    procedure OnSelectVertex(sender:tobject);
    // найти по id вершину в ListView
    function findItem(pointnum:tpoint):integer;
    // найти кость по номеру точки
    function findBone(pNum:integer):cSkinPoint;
    procedure ShowPoint(p:cSkinPoint);
  public
    procedure createevents;
    procedure destroyevents;
    procedure Apply;
    procedure showObj(o:cObject; frm:tform);
    // u3dObj TObjFrm3d
    procedure init;
    destructor destroy;
  end;

implementation
uses
  u3dObj;
{$R *.dfm}

{ TVertexEditFrame }

procedure TVertexEditFrame.AddBtnClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  p:cSkinPoint;
  deformP:cDeformPoint;
  b:boolean;
  bone:cbone;
  p3:point3;
  m:matrixgl;
begin
  if m_Point.x<>-1 then
  begin
    i:=findItem(m_Point);
    li:=VertLV.Items[i];
    VertLV.SetSubItemByColumnName('Point',inttostr(PointNumSE.Value),li);
    if m_skin=nil then
    begin
      m_skin:=cskin(m_curObj.ModCreator.CreateModificator('cSkin'));
      SkinCB.Checked:=true;
    end;
    // признак что такая кость найдена
    p:=findBone(PointNumSE.Value);
    if p=nil then
    begin
      p:=cSkinPoint.create;
      p.fHelper:=false;
      p.Name:='Point_'+inttostr(PointNumSE.Value);
      p.m_PName:=PointNumSE.Value;
      p.m_defObj:=m_curObj;
      p.m_w:=1;
      m_ui.scene.Add(p, m_ui.scene.World);
      if m_curObj is cShapeObj then
      begin
        p3:=cShapeObj(m_curObj).getPoint(m_point);
        m:=cShapeObj(m_curObj).nodeResTm;
        p.position:=MultP3byM(m, p3);
      end;
      bone:=m_skin.AddBone(p);
      p.m_bone:=bone;
      p.PId:=m_Point;
    end;
    deformP:=p.m_bone.AddPoint(m_Point, 1);
    deformP.weight:=p.m_w;
    m_pList.Add(p);
    ShowPoint(p);
    TObjFrm3d(m_frm).UpdateTreeView;
  end;
end;

procedure TVertexEditFrame.Apply;
var
  p:cSkinPoint;
begin
  if m_curObj<>nil then
  begin
    if SkinCB.Checked then
    begin
      if m_skin=nil then
      begin
        m_skin:=cskin(m_curObj.ModCreator.CreateModificator('cSkin'));
      end;
      p:=findBone(PointNumSE.Value);
      p.yTag.tag:=tagcb.gettag();
    end;
  end;
end;


destructor TVertexEditFrame.destroy;
begin
  m_pList.Destroy;
end;


procedure TVertexEditFrame.createevents;
begin
  m_ui.eventlist.AddEvent('TVertexEditFrame_OnSelVert',E_glSelectMeshPoint,OnSelectVertex);
end;


procedure TVertexEditFrame.destroyevents;
begin
  m_ui.eventlist.removeEvent(OnSelectVertex, E_glSelectMeshPoint);
end;

function TVertexEditFrame.findBone(pNum: integer): cSkinPoint;
var
  I: Integer;
  b:cbone;
begin
  result:=nil;
  if m_skin<>nil then
  begin
    for I := 0 to m_skin.Count - 1 do
    begin
      b:=m_skin.getbone(i);
      if b.fbone is cSkinPoint then
      begin
        if cSkinPoint(b.fbone).m_PName=pNum then
        begin
          result:=cSkinPoint(b.fbone);
          exit;
        end;
      end;
    end;
  end;
end;

function TVertexEditFrame.findItem(pointnum: tpoint): integer;
var
  I: Integer;
  li:tlistitem;
  s, s1:string;
begin
  result:=-1;
  s:=inttostr(pointnum.x)+'_'+inttostr(pointnum.Y);
  for I := 0 to VertLV.items.Count - 1 do
  begin
    li:=VertLV.Items[i];
    s1:=li.SubItems[1];
    if s=s1 then
    begin
      result:=i;
      exit;
    end;
  end;
end;

procedure TVertexEditFrame.init;
begin
  m_pList:=TList.Create;
  AxisCB.Items.Add('X:');
  AxisCB.Items.Add('Y:');
  AxisCB.Items.Add('Z:');
end;

procedure TVertexEditFrame.OnSelectVertex(sender: tobject);
var
  p:tpoint;
  s,s1:string;
  I: Integer;
  li:tlistitem;
begin
  if m_curObj<>nil then
  begin
    if m_curObj is cshapeObj then
    begin
      p:=cshapeObj(m_curObj).selectPoints;
      m_Point:=p;
      s:=inttostr(p.x)+'_'+inttostr(p.Y);
      for I := 0 to VertLV.items.Count - 1 do
      begin
        li:=VertLV.Items[i];
        s1:=li.SubItems[1];
        if s=s1 then
        begin
          VertLV.clearcolors;
          VertLV.addColorItem(li.Index, clHighlight);
          VertLV.Invalidate;
          break;
        end;
      end;
    end;
  end;
end;

procedure TVertexEditFrame.showObj(o: cObject; frm:tform);
var
  I, n: Integer;
  s:cShapeObj;
  l:tline;
  li:tlistitem;
  j: Integer;
  p3:point3;
  b:cbone;
  p:cNodeObject;
begin
  TagCB.updateTagsList;
  m_curObj:=o;
  m_frm:=frm;
  NameEdit.Text:=m_curObj.name;
  VertLV.Clear;
  if m_curObj is cshapeobj then
  begin
    n:=0;
    s:=cShapeObj(o);
    for I := 0 to s.LineCount - 1 do
    begin
      l:=s.Lines[i];
      for j := 0 to length(l.data) - 1 do
      begin
        li:=VertLV.Items.Add;
        VertLV.SetSubItemByColumnName('№',inttostr(n),li);
        p3:=l.data[j];
        VertLV.SetSubItemByColumnName('Pos.',p3ToStr(p3,3),li);
        VertLV.SetSubItemByColumnName('ID',inttostr(i)+'_'+inttostr(j),li);
        inc(n);
      end;
    end;
  end;
  LVChange(VertLV);
  m_ui:=cui(cRender(cscene(o.getmng).render).ui);
  if o is cshapeobj then
  begin
    m_skin:=cskin(s.ModCreator.GetModificator('cSkin'));
    if m_skin=nil then
    begin
      SkinCB.Checked:=false;
      exit;
    end
    else
    begin
      m_pList.Clear;
      for I := 0 to m_skin.count - 1 do
      begin
        b:=m_skin.getbone(i);
        p:=b.fbone;
        if p is cSkinPoint then
          m_pList.Add(p);
      end;
    end;
  end;
end;

procedure TVertexEditFrame.ShowPoint(p: cSkinPoint);
var
  I: Integer;
  dp:cDeformPoint;
  li:tlistitem;
begin
  PointNumEdit.IntNum:=p.m_PName;
  pIdEdit.text:=inttostr(p.PId.x)+'_'+inttostr(p.PId.y);
  PointWeight.Value:=p.m_w;
  TagCB.SetTagName(p.yTag.tagname);
  SkinPointsLV.Clear;
  for I := 0 to p.m_bone.Count - 1 do
  begin
    dp:=p.m_bone.getpoint(i);
    li:=SkinPointsLV.Items.Add;
    SkinPointsLV.SetSubItemByColumnName('№',inttostr(i),li);
    SkinPointsLV.SetSubItemByColumnName('ID', tpointtostr(dp.p), li);
    SkinPointsLV.SetSubItemByColumnName('Вес',floattostr(dp.weight),li);
  end;
  LVChange(SkinPointsLV);
end;

procedure TVertexEditFrame.VertLVDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if True then

end;

{ cSkinPoint }

constructor cSkinPoint.create;
begin
  inherited;
  xTag:=cTag.create;
  yTag:=cTag.create;
  zTag:=cTag.create;
end;

destructor cSkinPoint.destroy;
begin
  xTag.destroy;
  yTag.destroy;
  zTag.destroy;
  inherited;
end;

end.
