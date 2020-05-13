unit uTransformButtons;

interface

uses
  Windows,
  SysUtils,
  Forms,
  StdCtrls,
  DCL_MYOWN,
  SelectObjectsFrame,
  Controls,
  Classes,
  uobject,
  mathfunction,
  usimpleobjects,
  urender,
  uSpin, opengl,
  uQuat,
  uMatrix,
  uUI,
  uselectools,
  uNodeObject,
  uObjectTypes,
  uEventList,
  ExtCtrls,
  uMoveController,
  AnimationControlFrame,
  uObjCtrFrame,
  uglEventTypes,
  uCommonTypes;

type
  TTransformToolsFrame = class(TFrame)
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RotZSpinEdit: TFloatSpinEdit;
    RotYSpinEdit: TFloatSpinEdit;
    RotXSpinEdit: TFloatSpinEdit;
    Label8: TLabel;
    Label9: TLabel;
    ObjNameE: TEdit;
    WorldComboBox: TComboBox;
    TimeCotrolGroupBox: TGroupBox;
    AnimationCtrlFrame1: TAnimationCtrlFrame;
    GroupBox4: TGroupBox;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    MoveXSpinEdit: TFloatSpinEdit;
    MoveYSpinEdit: TFloatSpinEdit;
    MoveZSpinEdit: TFloatSpinEdit;
    CtrlViewFrame1: TCtrlViewFrame;
    procedure DecTimeClick(Sender: TObject);
    procedure AddTimeClick(Sender: TObject);
    procedure WorldComboBoxChange(Sender: TObject);
    procedure AddBtnClick(dPos:point3);
//    procedure RotZSpinEditChange(Sender: TObject);
//    procedure RotYSpinEditChange(Sender: TObject);
    procedure RotXSpinEditChange(Sender: TObject);
    procedure FrameMouseEnter(Sender: TObject);
    procedure GroupBox1MouseEnter(Sender: TObject);
    procedure MoovXSpinEditChange(Sender: TObject);
  private
    updatePos:boolean;
    procedure GetObjPos;
    procedure updateObjName(sender:tobject);
    { Private declarations }
  public
    procedure Lincscene(p_UI:cUI);
    { Public declarations }
  end;

implementation
var
  UI:cUI;
  render:crender;
  oldRotPos:point3;

{$R *.dfm}

procedure TTransformToolsFrame.updateObjName(sender:tobject);
var p3:point3;
    obj:cNodeObject;
begin
  obj:=UI.GetSelected(0);
  if obj<>nil then
  begin
    ObjNameE.Text:=obj.name;
  end
  else
    ObjNameE.Text:='';
end;

procedure TTransformToolsFrame.WorldComboBoxChange(Sender: TObject);
begin
  ui.AxisSystem:=worldComboBox.ItemIndex;
  ui.m_RenderScene.invalidaterect;
end;

procedure TTransformToolsFrame.GetObjPos;
var p3:point3;
    obj:cNodeObject;
begin
  obj:=UI.GetSelected(0);
  if obj<>nil then
  begin
    updatePos:=false;
    p3:=obj.position;
    MoveYSpinEdit.Value:=p3.y;
    MoveZSpinEdit.Value:=p3.z;
    MoveXSpinEdit.Value:=p3.x;
    updatePos:=true;
  end;
end;

procedure TTransformToolsFrame.GroupBox1MouseEnter(Sender: TObject);
begin
  GetObjPos;
end;

procedure TTransformToolsFrame.Lincscene(p_UI:cUI);
var p3:point3;
    obj:cNodeObject;
begin
  render:=p_UI.m_RenderScene;
  UI:=p_UI;
  UI.EventList.AddEvent('TransformToolsFrameSelectUpdate',E_glSelectNew,updateObjName);
  obj:=nil;
  //if UI.GetSelected(obj) then
  begin
    //p3:=obj.GetNodePosition;
    MoveYSpinEdit.Value:=round(p3.y);
    MoveZSpinEdit.Value:=round(p3.z);
    MoveXSpinEdit.Value:=round(p3.x);
  end;
  AnimationCtrlFrame1.linc(UI);
  CtrlViewFrame1.lincscene(UI);
end;

procedure TTransformToolsFrame.MoovXSpinEditChange(Sender: TObject);
var obj:cNodeObject;
    pos:point3;
begin
  obj:=UI.GetSelected;
  if obj<>nil then
  begin
    if updatePos then
    begin
      pos.x:=MoveXSpinEdit.Value;
      pos.y:=MoveYSpinEdit.Value;
      pos.z:=MoveZSpinEdit.Value;
      AddBtnClick(pos);
      render.invalidaterect;
    end;
  end;
end;

procedure TestEuler;
begin
  glmatrixmode(Gl_MODELVIEW);
  glloadidentity;
  glrotate(120,1,0,0);
  glrotate(110,0,1,0);
  glrotate(135,0,0,1);
end;

procedure RotateObjectInSystem(obj:cnodeobject;rot:point3;system:word);
begin
  case system of
    constWorld: cNodeObject(obj).RotateNodeGlobal(rot);
    constNode:
    begin
      cNodeObject(obj).RotateNodeLocal(rot);
    end;
    constLocal:
    begin
      cNodeObject(obj).RotateNodeInLocalNodeWorld(rot);
    end;
    constParent:
    begin
      cNodeObject(obj).RotateNodeInParentWorld(rot);
    end;
  end;
end;

procedure TTransformToolsFrame.RotXSpinEditChange(Sender: TObject);
var obj:cNodeObject;
    p3,axis:point3;
begin
  //if UI.GetSelected(obj) then
  begin
    if RotXspinEdit.enabled then
    begin
      p3.x:=RotXspinEdit.Value - oldRotPos.x;
      p3.y:=RotYspinEdit.Value - oldRotPos.y;
      p3.z:=RotZspinEdit.Value - oldRotPos.z;
      if abs(p3.x)<0.5 then
        p3.x:=0;
      if abs(p3.y)<0.5 then
        p3.y:=0;
      if abs(p3.z)<0.5 then
        p3.z:=0;      
      RotateObjectInSystem(obj,p3,WorldComboBox.ItemIndex);
      render.invalidaterect;
    end;
    oldrotpos.x:=RotXspinEdit.Value;
    oldrotpos.y:=RotYspinEdit.Value;
    oldrotpos.z:=RotZspinEdit.Value;
  end;
end;

procedure TTransformToolsFrame.AddBtnClick(dpos:point3);
var obj:cNodeObject;
    d:point3;
begin
  obj:=UI.GetSelected;
  if obj<>nil then
  begin
    begin
      d:=subvector(cobject(obj).position,dpos);
      case WorldComboBox.ItemIndex of
        constWorld:cobject(obj).position:=dpos;
        constNode:
        begin
          cobject(obj).MoveNodeLocal(d.x,d.y,d.z);
          GetObjPos;
        end;
        constLocal:
        begin
          cobject(obj).MoveNodeInLocalNodeWorld(d.x,d.y,d.z);
          GetObjPos;
        end;
        constParent:
        begin
          cobject(obj).MoveNodeInParentWorld(d.x,d.y,d.z);
          GetObjPos;
        end;
      end;
    end;
  end;
end;

procedure TTransformToolsFrame.AddTimeClick(Sender: TObject);
var obj:cnodeobject;
    i:integer;
    c:cMoveController;
begin
  //obj:=ui.m_RenderScene.m_Loader.GetObjbyName('Box02');
  if obj<>nil then
  begin
    for I := 0 to obj.ModCreator.count - 1 do
    begin
      if obj.ModCreator.getitem(i) is cMoveController then
      begin
        c:=cMoveController(obj.ModCreator.getitem(i));
        //c.apply(cardinal(c.t+dTimeEdit.IntNum));
        ui.m_RenderScene.invalidaterect;
      end;
    end;
  end;
end;

procedure TTransformToolsFrame.DecTimeClick(Sender: TObject);
var obj:cnodeobject;
    i:integer;
    c:cMoveController;
begin
  //obj:=ui.m_RenderScene.m_Loader.GetObjbyName('Box02');
  if obj<>nil then
  begin
    for I := 0 to obj.ModCreator.count - 1 do
    begin
      if obj.ModCreator.getitem(i) is cMoveController then
      begin
        c:=cMoveController(obj.ModCreator.getitem(i));
        //c.apply(cardinal(c.t-dTimeEdit.IntNum));
        ui.m_RenderScene.invalidaterect;
      end;
    end;
  end;
end;

procedure TTransformToolsFrame.FrameMouseEnter(Sender: TObject);
var p3:point3;
    obj:cNodeObject;
begin
  //if UI.GetSelected(obj) then
  begin
    p3:=MatrixglToEuler(obj.NodeTM);
    RotXspinEdit.Value:=p3.x;
    RotYspinEdit.Value:=p3.y;
    RotZspinEdit.Value:=p3.z;
  end;
end;

end.
