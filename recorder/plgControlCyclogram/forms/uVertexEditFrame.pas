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
  u3dMoveEngine,
  ucommonmath,
  uRcCtrls;

type
  // управляет по тегам движением сцены u3dMoveEngine.g_CtrlObjList
  TVertexEditFrame = class(TFrame)
    TopPanel: TPanel;
    AlPanel: TPanel;
    VertLV: TBtnListView;
    NameEdit: TEdit;
    ObjNameLabel: TLabel;
    PointNumSE: TSpinEdit;
    PintNumLabel: TLabel;
    SkinCB: TCheckBox;
    RightPan: TGroupBox;
    Panel1: TPanel;
    WeightLabel: TLabel;
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
    ChangePBtn: TButton;
    procedure VertLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AddBtnClick(Sender: TObject);
    procedure PointNumSEChange(Sender: TObject);
    procedure ChangePBtnClick(Sender: TObject);
  public
    m_ui:cUI;
  private
    finit:Boolean;
    m_curObj:cobject;
    // список добавленных вершин
    //m_pList:tlist;
    m_skin:cSkin;
    // Id выбраной вершины
    m_Point:TPoint;
    m_frm:tform;
  protected
    procedure OnSelectVertex(sender:tobject);
    // найти по id вершину в ListView
    function findItem(pointnum:tpoint):integer;
    // найти кость по номеру точки
    function findBone(pNum:integer):c3dSkinObj;
    procedure ShowPoint(p:c3dSkinObj);
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
  I, j: Integer;
  id:tpoint;
  li:tlistitem;
  p:c3dSkinObj;
  deformP:cDeformPoint;
  b:boolean;
  bone:cbone;
  p3, selP:point3;
  dist:double;
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
      p:=c3dSkinObj.create;
      g_CtrlObjList.addObj(p);

      p.Name:='Point_'+inttostr(PointNumSE.Value);
      p.m_PName:=PointNumSE.Value;
      p.m_defObj:=m_curObj;
      p.m_w:=1;
      m_ui.scene.Add(p, m_ui.scene.World);
      p.fHelper:=false;
      if m_curObj is cShapeObj then
      begin
        p3:=cShapeObj(m_curObj).getPoint(m_point);
        m:=cShapeObj(m_curObj).nodeResTm;
        p.position:=MultP3byM(m, p3);
        p.startpos:=p.position;
      end;
      bone:=m_skin.AddBone(p);
      p.m_bone:=bone;
      p.PId:=m_Point;
    end;
    deformP:=p.m_bone.AddPoint(m_Point, 1);
    deformP.weight:=pointweight.Value;
    selP:=deformP.v;
    if m_curObj is cShapeObj then
    begin
      for I := 0 to cShapeObj(m_curObj).LineCount - 1 do
      begin
        for j := 0 to length(cShapeObj(m_curObj).Lines[i].data)- 1 do
        begin
          id.x:=i;id.y:=j;
          p3:=cShapeObj(m_curObj).getPoint(id);
          p3:=subVector(selp,p3);
          dist:=VectorLength(p3);
          if dist<0.1 then
          begin
            if (m_point.x<>id.x) or (m_point.y<>id.y) then
            begin
              deformP:=p.m_bone.AddPoint(id, 1);
              deformP.weight:=pointweight.Value;
            end;
          end;
        end;
      end;
    end;
    //m_pList.Add(p);
    ShowPoint(p);
    TObjFrm3d(m_frm).UpdateTreeView;
  end;
end;

procedure TVertexEditFrame.Apply;
var
  p:c3dSkinObj;
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


procedure TVertexEditFrame.ChangePBtnClick(Sender: TObject);
var
  I: Integer;
  id:tpoint;
  li:tlistitem;
  s, s1:string;
  p:c3dSkinObj;
  deformP:cDeformPoint;
begin
  li:=SkinPointsLV.Selected;
  while li<>nil do
  begin
    SkinPointsLV.GetSubItemByColumnName('ID', li, s);
    s1:=getSubStrByIndex(s,'_', 1, 0);
    id.x:=StrToInt(s1);
    s1:=getSubStrByIndex(s,'_', 1,1);
    id.y:=StrToInt(s1);
    // признак что такая кость найдена
    p:=findBone(PointNumSE.Value);
    deformP:=p.m_bone.FindPoint(id);
    deformP.weight:=PointWeight.Value;
    SkinPointsLV.SetSubItemByColumnName('Вес',floattostr(PointWeight.Value),li);
    li:=SkinPointsLV.GetNextItem(li,sdAll,[isselected]);
  end;
end;

destructor TVertexEditFrame.destroy;
begin
  //m_pList.Destroy;
end;


procedure TVertexEditFrame.createevents;
begin
  m_ui.eventlist.AddEvent('TVertexEditFrame_OnSelVert',E_glSelectMeshPoint,OnSelectVertex);
end;


procedure TVertexEditFrame.destroyevents;
begin
  if m_ui<>nil then
    m_ui.eventlist.removeEvent(OnSelectVertex, E_glSelectMeshPoint);
end;

function TVertexEditFrame.findBone(pNum: integer): c3dSkinObj;
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
      if b.fbone is c3dSkinObj then
      begin
        if c3dSkinObj(b.fbone).m_PName=pNum then
        begin
          result:=c3dSkinObj(b.fbone);
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
  //m_pList:=TList.Create;
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

procedure TVertexEditFrame.PointNumSEChange(Sender: TObject);
var
  p:c3dSkinObj; // кость аниматор вершины
begin
  p:=g_CtrlObjList.GetObjBySkin(m_curObj.name, PointNumSE.Value);
  if p<>nil then
    ShowPoint(p);
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
  // объект движка контролирующий костную анимацию в движке Recorder
  skinObj:c3dSkinObj;
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
      SkinCB.Checked:=true;
      // ищем контроллер костей
      skinObj:=c3dSkinObj(g_CtrlObjList.GetObjBySkin(m_curObj.name, PointNumSE.value));
      ShowPoint(skinObj);
    end;
  end;
end;

procedure TVertexEditFrame.ShowPoint(p: c3dSkinObj);
var
  I: Integer;
  dp:cDeformPoint;
  li:tlistitem;
begin
  //PointNumEdit.IntNum:=p.m_PName;
  pIdEdit.text:=inttostr(p.PId.x)+'_'+inttostr(p.PId.y);
  //PointWeight.Value:=p.m_w;
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


end.
