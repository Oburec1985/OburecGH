unit uTVFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, uSceneMng, uBaseObj, uBaseObjService, uUI,
  StdCtrls, ExtCtrls, uSpin, ComCtrls, uBtnListView, DCL_MYOWN, uObject,
  uGlEventTypes, MathFunction, uCommonTypes, uNodeObject, usetlist, uObjectTypes,
  ubasecamera
  ,umeshobr
  ,umaterial
  ,urender, ToolWin
  ;

type
  TSceneTVFrame = class(TFrame)
    SceneTV: TVTree;
    Splitter1: TSplitter;
    ObjectPropertyScrollBox: TScrollBox;
    BoundingGroupBox: TGroupBox;
    Label9: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    DrawBoundsCheckBox: TCheckBox;
    BoundFE: TFloatEdit;
    TypeE: TEdit;
    NameE: TEdit;
    FreezCheckBox: TCheckBox;
    MeshGroupBox: TGroupBox;
    Label3: TLabel;
    DrawNormalCheckBox: TCheckBox;
    NormalLengthE: TFloatEdit;
    MatrixGroupBox: TGroupBox;
    Label15: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    NodeMatrixLV: TBtnListView;
    LocalNodeMatrixLV: TBtnListView;
    NodeResMatrixLV: TBtnListView;
    LocalNodeResMatrixLV: TBtnListView;
    TabControl: TPageControl;
    TabSheet1: TTabSheet;
    Label10: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    NearPlaneLabel: TLabel;
    FarPlaneLabel: TLabel;
    RightPlaneLabel: TLabel;
    LeftPlaneLabel: TLabel;
    BottomPlaneLabel: TLabel;
    TopPlaneLabel: TLabel;
    ActiveCheckBox: TCheckBox;
    TargetComboBox: TComboBox;
    FovSpinEdit: TFloatSpinEdit;
    AspectSpinEdit: TFloatSpinEdit;
    NearPlaneFE: TFloatSpinEdit;
    FarPlaneFE: TFloatSpinEdit;
    KeepQuadCheckBox: TCheckBox;
    OrthoCheckBox: TCheckBox;
    LeftPlaneFE: TFloatSpinEdit;
    RightPlaneFE: TFloatSpinEdit;
    TopPlaneFE: TFloatSpinEdit;
    BottomPlaneFE: TFloatSpinEdit;
    TabSheet2: TTabSheet;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    MaterialLabel: TLabel;
    DefaultColorLabel: TLabel;
    DefColorPanel: TPanel;
    TabSheet3: TTabSheet;
    Label20: TLabel;
    EnableLightCheckBox: TCheckBox;
    LightIDE: TEdit;
    MaterialComboBox: TComboBox;
    PointsCheckBox: TCheckBox;
    GeomCheckBox: TCheckBox;
    EdgesCheckBox: TCheckBox;
    DrawLocalCheckBox: TCheckBox;
    DrawNodeCheckBox: TCheckBox;
    ToolBar1: TToolBar;
    ApplyBtn: TToolButton;
    procedure ApplyBtnClick(Sender: TObject);
    procedure SceneTVClick(Sender: TObject);
  private
    s:cscene;
    ui:cUI;
    list:cselectlist;
    // картинки получаем с главной формы
    imagelist:timagelist;
  private
    procedure showNodeMatrix(m:matrixgl);
    procedure showNodeResMatrix(m:matrixgl);
    procedure showLocalNodeMatrix(m:matrixgl);
    procedure showLocalNodeResMatrix(m:matrixgl);
    procedure showobjMatrix(obj:cnodeobject);
    procedure ShowCommonProperty;
    procedure ShowCameraProperty;
    procedure ShowMeshProperty;
    procedure SetMeshProperty;
    //procedure ShowLightProperty(obj:cnodeobject);
    procedure ShowObjectProperty;

    procedure DoSelectEvent(sender:tobject);
    procedure DoUpdateSceneEvent(sender:tobject);

    procedure MaterialComboBoxUpdate(Sender: TObject);
    procedure MaterialComboBoxChange;
  public
    procedure CreateEvents;
    procedure getproperties;
    // картинки получаем с главной формы
    procedure link(p_ui:cUI;c:twincontrol; images: timagelist);
    procedure showScene;
  end;

implementation

{$R *.dfm}
procedure TSceneTVFrame.link(p_ui:cUI;c:twincontrol; images: timagelist);
begin
  ui:=p_ui;
  s:=ui.scene;
  showScene;
  parent:=c;
  CreateEvents;
  list:=cSelectList.create;
  imagelist:=images;
  toolbar1.Images:=images;
end;

procedure TSceneTVFrame.getproperties;
begin

end;


procedure TSceneTVFrame.showScene;
begin
  showInVTreeView(SceneTV, s.World, s.images_16);
end;

procedure TSceneTVFrame.ApplyBtnClick(Sender: TObject);
begin
  SetMeshProperty;
end;

procedure TSceneTVFrame.CreateEvents;
begin
  ui.EventList.AddEvent('TSceneTreeViewFrame_OnSelect',E_glSelectNew,DoSelectEvent);
  ui.EventList.AddEvent('TSceneTreeViewFrame_OnUpdateScene',E_glLoadScene,DoUpdateSceneEvent);
  ui.EventList.AddEvent('TSceneTreeViewFrame_OnLoad_Materialchange',//E_glSelectNew+
  E_glLoadScene,MaterialComboBoxUpdate);
end;

procedure TSceneTVFrame.DoSelectEvent(sender:tobject);
var
  p3:point3;
  obj:cbaseobj;
begin
  ShowObjectProperty;
end;

procedure TSceneTVFrame.DoUpdateSceneEvent(sender:tobject);
begin
  showScene;
end;

procedure TSceneTVFrame.ShowObjectProperty;
begin
  if UI.selectcount<>0 then
  begin
    ShowCommonProperty;
    ShowMeshProperty;
    ShowCameraProperty;
    //ShowLightProperty(obj);
  end;
end;

procedure ShowTEName(list:cselectlist; e:tedit);
var
  I: Integer;
  o:cbaseObj;
  str:string;
begin
  o:=cbaseobj(list.Items[0]);
  str:=o.name;
  for I := 1 to List.Count - 1 do
  begin
    o:=cbaseobj(list.Items[i]);
    if o.name<>str then
    begin
      e.Text:='';
      exit;
    end;
  end;
  e.Text:=str;
end;

procedure ShowTEType(list:cselectlist; e:tedit);
var
  I: Integer;
  o:cbaseObj;
  str:string;
begin
  o:=cbaseobj(list.Items[0]);
  str:=o.TypeString;
  for I := 1 to List.Count - 1 do
  begin
    o:=cbaseobj(list.Items[i]);
    if o.TypeString<>str then
    begin
      e.Text:='';
      exit;
    end;
  end;
  e.Text:=str;
end;

procedure ShowBoundSize(list:cselectlist; e:tedit);
var
  I: Integer;
  o:cbaseObj;
  str:string;
begin
  for I := 0 to List.Count - 1 do
  begin
    o:=cbaseobj(list.Items[i]);
    if o is cObject then
    begin
      str:=floattostr(cobject(o).boundsize);
      if i>1 then
      begin
        if str<>e.Text then
        begin
          e.Text:='';
          exit;
        end;
      end;
    end
    else
    begin
      e.Text:='';
      exit;
    end;
  end;
  e.Text:=str;
end;

procedure SetCBEnabled(b:boolean; cb:tcheckBox);
begin
  if b then
  begin
    CB.Enabled:=true;
    if cb.Checked then
      CB.State:=cbChecked
    else
    begin
      CB.State:=cbUnChecked;
    end;
  end
  else
  begin
    CB.Enabled:=false;
    CB.State:=cbGrayed;
  end;
end;

procedure ShowCBfreez(list:cselectlist; cb:tcheckBox);
var
  I: Integer;
  o:cbaseObj;
  str:string;
  b:boolean;
begin
  for I := 0 to list.Count - 1 do
  begin
    o:=list.items[i];
    if not (o is cNodeObject) then
    begin
      b:=false;
      break;
    end;
  end;
  SetCBEnabled(b, cb);
  if cb.Enabled then
  begin
    for I := 0 to list.Count - 1 do
    begin
      o:=list.items[i];
      if o is cNodeObject then
      begin
        b:=cnodeobject(o).freezObj;
        if i>1 then
        begin
          if b<>cnodeobject(o).freezObj then
          begin
            cb.state:=cbGrayed;
            break;
          end;
        end;
      end;
    end;
  end;
end;

procedure ShowCBDrawBound(list:cselectlist; cb:tcheckBox);
var
  I: Integer;
  o:cbaseObj;
  str:string;
  b:boolean;
begin
  b:=true;
  for I := 0 to list.Count - 1 do
  begin
    o:=list.items[i];
    if not (o is cObject) then
    begin
      b:=false;
      break;
    end;
  end;
  SetCBEnabled(b, cb);
  if cb.Enabled then
  begin
    for I := 0 to list.Count - 1 do
    begin
      o:=list.items[i];
      if o is cObject then
      begin
        b:=checkflag(cobject(o).settings, draw_bound);
        if i>1 then
        begin
          if b<>checkflag(cobject(o).settings, draw_bound) then
          begin
            cb.state:=cbGrayed;
            break;
          end;
        end;
      end;
    end;
  end;
end;


procedure ShowCBDrawLocal(list:cselectlist; cb:tcheckBox);
var
  I: Integer;
  o:cbaseObj;
  str:string;
  b:boolean;
begin
  b:=true;
  for I := 0 to list.Count - 1 do
  begin
    o:=list.items[i];
    if not (o is cNodeObject) then
    begin
      b:=false;
      break;
    end;
  end;
  SetCBEnabled(b, cb);
  if cb.Enabled then
  begin
    for I := 0 to list.Count - 1 do
    begin
      o:=list.items[i];
      if o is cNodeObject then
      begin
        b:=checkflag(cobject(o).settings, DRAW_LOCAL);
        if i>1 then
        begin
          if b<>checkflag(cobject(o).settings, DRAW_LOCAL) then
          begin
            cb.state:=cbGrayed;
            break;
          end;
        end;
      end;
    end;
  end;
end;

procedure ShowCBDrawNode(list:cselectlist; cb:tcheckBox);
var
  I: Integer;
  o:cbaseObj;
  str:string;
  b:boolean;
begin
  b:=true;
  for I := 0 to list.Count - 1 do
  begin
    o:=list.items[i];
    if not (o is cNodeObject) then
    begin
      b:=false;
      break;
    end;
  end;
  SetCBEnabled(b, cb);
  if cb.Enabled then
  begin
    for I := 0 to list.Count - 1 do
    begin
      o:=list.items[i];
      if o is cNodeObject then
      begin
        b:=checkflag(cobject(o).settings, DRAW_NODE);
        if i>1 then
        begin
          if b<>checkflag(cobject(o).settings, DRAW_NODE) then
          begin
            cb.state:=cbGrayed;
            break;
          end;
        end;
      end;
    end;
  end;
end;

procedure ShowCBDrawParent(list:cselectlist; cb:tcheckBox);
var
  I: Integer;
  o:cbaseObj;
  str:string;
  b:boolean;
begin
  b:=true;
  for I := 0 to list.Count - 1 do
  begin
    o:=list.items[i];
    if not (o is cNodeObject) then
    begin
      b:=false;
      break;
    end;
  end;
  SetCBEnabled(b, cb);
  if cb.Enabled then
  begin
    for I := 0 to list.Count - 1 do
    begin
      o:=list.items[i];
      if o is cNodeObject then
      begin
        b:=checkflag(cobject(o).settings, draw_Parent);
        if i>1 then
        begin
          if b<>checkflag(cobject(o).settings, draw_Parent) then
          begin
            cb.state:=cbGrayed;
            break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TSceneTVFrame.ShowCommonProperty;
begin
  ShowTEName(ui.GetSelectList, nameE);
  ShowTEType(ui.GetSelectList, typee);
  ShowCBfreez(ui.GetSelectList,FreezCheckBox);
  ShowCBDrawBound(ui.GetSelectList, DrawBoundsCheckBox);
  ShowCBDrawLocal(ui.GetSelectList,DrawLocalCheckBox);
  ShowCBDrawNode(ui.GetSelectList,DrawNodeCheckBox);
  ShowCBDrawParent(ui.GetSelectList,DrawNodeCheckBox);
  ShowBoundSize(ui.GetSelectList,BoundFE);
  if ui.GetSelectList.Count=1 then
  begin
    if ui.getselected(0) is cNodeObject then
    begin
      showobjMatrix(cnodeobject(ui.getselected(0)));
    end;
  end;
end;


procedure UpdateView(l_fm: array of Single;var matrixLV:TBtnListView);
var
  i:integer;
  li:TListItem;
begin
  for I := 0 to 15 do
  begin
    if abs(l_fm[i])<0.00005 then
      l_fm[i]:=0;
  end;
  li:=matrixLV.Items[0];
  matrixLV.SetSubItemByColumnName('x',floattostr(l_fm[0]),li);
  matrixLV.SetSubItemByColumnName('y',floattostr(l_fm[4]),li);
  matrixLV.SetSubItemByColumnName('z',floattostr(l_fm[8]),li);
  matrixLV.SetSubItemByColumnName('pos',floattostr(l_fm[12]),li);
  li:=matrixLV.Items[1];
  matrixLV.SetSubItemByColumnName('x',floattostr(l_fm[1]),li);
  matrixLV.SetSubItemByColumnName('y',floattostr(l_fm[5]),li);
  matrixLV.SetSubItemByColumnName('z',floattostr(l_fm[9]),li);
  matrixLV.SetSubItemByColumnName('pos',floattostr(l_fm[13]),li);
  li:=matrixLV.Items[2];
  matrixLV.SetSubItemByColumnName('x',floattostr(l_fm[2]),li);
  matrixLV.SetSubItemByColumnName('y',floattostr(l_fm[6]),li);
  matrixLV.SetSubItemByColumnName('z',floattostr(l_fm[10]),li);
  matrixLV.SetSubItemByColumnName('pos',floattostr(l_fm[14]),li);
  li:=matrixLV.Items[3];
  matrixLV.SetSubItemByColumnName('x',floattostr(l_fm[3]),li);
  matrixLV.SetSubItemByColumnName('y',floattostr(l_fm[7]),li);
  matrixLV.SetSubItemByColumnName('z',floattostr(l_fm[11]),li);
  matrixLV.SetSubItemByColumnName('pos',floattostr(l_fm[15]),li);
end;

procedure TSceneTVFrame.showNodeMatrix(m:matrixgl);
begin
  UpdateView(m,NodeMatrixLV);
end;

procedure TSceneTVFrame.showNodeResMatrix(m:matrixgl);
begin
  UpdateView(m,NodeResMatrixLV);
end;

procedure TSceneTVFrame.showLocalNodeMatrix(m:matrixgl);
begin
  UpdateView(m,LocalNodeMatrixLV);
end;

procedure TSceneTVFrame.showLocalNodeResMatrix(m:matrixgl);
begin
  UpdateView(m,LocalNodeResMatrixLV);
end;

procedure TSceneTVFrame.showobjMatrix(obj:cnodeobject);
begin
  showNodeMatrix(obj.Node.getlocalTM);
  showNodeResMatrix(obj.Node.restm);
  showLocalNodeMatrix(obj.LocalNode.getlocalTM);
  showLocalNodeResMatrix(obj.LocalNode.restm);
end;

procedure TSceneTVFrame.MaterialComboBoxUpdate(Sender: TObject);
var
  sc:cscene;
  i:integer;
  mat:cmaterial;
begin
  sc:=cscene(sender);
  MaterialComboBox.Clear;
  for I := 0 to crender(sc.render).m_MatMng.Count - 1 do
  begin
    mat:=ui.m_RenderScene.m_MatMng.getmaterial(i);
    MaterialComboBox.AddItem(mat.name,mat);
  end;
  //ShowSystemInfo;
end;

procedure TSceneTVFrame.MaterialComboBoxChange;
var obj:cNodeObject;
begin
  obj:=nil;
  obj:=UI.GetSelected(0);
  if obj=nil then exit;
  if not (obj is cmeshobr) then exit;
  if MaterialComboBox.ItemIndex<>-1 then
  begin
    cmeshobr(obj).material:=cmaterial( materialComboBox.items.Objects[materialComboBox.ItemIndex]);
  end
  else
    cmeshobr(obj).material:=nil;
end;

procedure TSceneTVFrame.SceneTVClick(Sender: TObject);
begin
  showScene;
end;

procedure TSceneTVFrame.SetMeshProperty;
var
  i:integer;
  m:cmeshobr;
  obj:cnodeobject;
begin
  for I := 0 to ui.selectCount - 1 do
  begin
    obj:=ui.getselected(i);
    if obj is cmeshobr then
    begin
      m:=cMeshObr(obj);
      m.drawGeom:=geomcheckbox.Checked;
      m.drawEdges:=EdgesCheckBox.Checked;
      m.drawPoints:=PointsCheckBox.Checked;
    end;
  end;
end;

procedure TSceneTVFrame.ShowMeshProperty;
var
  I, color: Integer;
  obj:cnodeobject;
  m:cmeshobr;
begin
  // список выбраных
  list.clear;
  for I := 0 to ui.selectCount - 1 do
  begin
    obj:=ui.getselected(i);
    if obj is cmeshobr then
    begin
      list.AddObj(obj);
    end;
  end;
  for I := 0 to List.Count - 1 do
  begin
    m:=cmeshobr(list.getNode(i));
    if i=0 then
    begin
      // рисовать геометрию
      SetCBEnabled(true,GeomCheckBox);
      GeomCheckBox.Checked:=CheckFlag(draw_Geom, m.settings);
      // рисовать точки
      SetCBEnabled(true,PointsCheckBox);
      PointsCheckBox.Checked:=CheckFlag(draw_Points, m.settings);
      // рисовать каркас
      SetCBEnabled(true,EdgesCheckBox);
      EdgesCheckBox.Checked:=CheckFlag(draw_Edges, m.settings);

      MaterialComboBox.Text:=cmeshobr(m).material.name;
      color:=RGBtoInt(cmeshobr(m).mesh.defoultcolor);
      defColorPanel.Color:=color;
    end;
    if i>0 then
    begin
      if GeomCheckBox.Checked<>CheckFlag(draw_Geom, m.settings) then
      begin
        GeomCheckBox.State:=cbGrayed;
      end;
      if PointsCheckBox.Checked<>CheckFlag(draw_Points, m.settings) then
      begin
        PointsCheckBox.State:=cbGrayed;
      end;
      if EdgesCheckBox.Checked<>CheckFlag(draw_Edges, m.settings) then
      begin
        EdgesCheckBox.State:=cbGrayed;
      end;
    end;
  end
end;

procedure TSceneTVFrame.ShowCameraProperty;
var
  I: Integer;
  obj:cnodeobject;
  c:cbasecamera;
begin
  // список выбраных
  list.clear;
  for I := 0 to ui.selectCount - 1 do
  begin
    obj:=ui.getselected(i);
    if obj is cbasecamera then
    begin
      list.AddObj(obj);
    end;
  end;
  for I := 0 to List.Count - 1 do
  begin
    c:=cbasecamera(list.getNode(i));
    // камера
    if i=0 then
    begin
      SetCBEnabled(true,ActiveCheckBox);
      ActiveCheckBox.Checked:=c.active;
      FovSpinEdit.Value:=c.fov;
      Aspectspinedit.Value:=c.aspect;

      NearPlaneFE.Value:=c.nearplane;
      FarPlaneFE.Value:=c.farplane;

      LeftPlaneFE.Value:=c.left;
      RightPlaneFE.Value:=c.right;

      TopPlaneFE.Value:=c.top;
      BottomPlaneFE.Value:=c.bottom;

      KeepQuadCheckBox.State:=cbUnchecked;
      KeepQuadCheckBox.Checked:=c.keepquad;

      OrthoCheckBox.State:=cbUnchecked;
      OrthoCheckBox.Checked:=c.ortho;
    end;
    if i>0 then
    begin
      SetCBEnabled(false,ActiveCheckBox);
      ActiveCheckBox.State:=cbGrayed;
      if FovSpinEdit.Value<>c.fov then
      begin
        FovSpinEdit.Text:='';
      end;
      if Aspectspinedit.Value<>c.aspect then
      begin
        Aspectspinedit.Text:='';
      end;
      if FarPlaneFE.Value<>c.farplane then
      begin
        FarPlaneFE.Text:='';
      end;
      if NearPlaneFE.Value<>c.nearplane then
      begin
        NearPlaneFE.Text:='';
      end;
      if LeftPlaneFE.Value<>c.left then
      begin
        LeftPlaneFE.Text:='';
      end;
      if RightPlaneFE.Value<>c.right then
      begin
        RightPlaneFE.Text:='';
      end;
      if TopPlaneFE.Value<>c.top then
      begin
        TopPlaneFE.Text:='';
      end;
      if BottomPlaneFE.Value<>c.bottom then
      begin
        BottomPlaneFE.Text:='';
      end;
      if KeepQuadCheckBox.Checked<>c.keepquad then
      begin
        KeepQuadCheckBox.State:=cbGrayed;
      end;
      if OrthoCheckBox.Checked<>c.fOrtho then
      begin
        OrthoCheckBox.State:=cbGrayed;
      end;
    end;
  end;
end;



end.
