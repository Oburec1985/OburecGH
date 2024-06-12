unit uTrfrmToolsFrame;

interface

uses
  Windows, Messages, SysUtils,
  Variants, Classes, Graphics,
  Controls, Forms,
  uNodeObject, MathFunction, uObject, uObjectTypes, uBaseCamera, uMatrix,
  uObjCtrFrame, uGlEventTypes, uCommonTypes, uTimeController,
  Dialogs, Buttons, StdCtrls, uUI, uSpin, ExtCtrls;

type
  TTrfrmToolsFrame = class(TFrame)
    GroupBox1: TGroupBox;
    PanBtn: TSpeedButton;
    RotBtn: TSpeedButton;
    ZoomBtn: TSpeedButton;
    SpeedZoom: TSpeedButton;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    MoveXSpinEdit: TFloatSpinEdit;
    MoveYSpinEdit: TFloatSpinEdit;
    MoveZSpinEdit: TFloatSpinEdit;
    WorldCB: TComboBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RotZSpinEdit: TFloatSpinEdit;
    RotYSpinEdit: TFloatSpinEdit;
    RotXSpinEdit: TFloatSpinEdit;
    Label9: TLabel;
    ObjNameE: TEdit;
    Label4: TLabel;
    AnimationControlGroupBox: TGroupBox;
    FrwBtn: TSpeedButton;
    PausePlayBtn: TSpeedButton;
    RewndBtn: TSpeedButton;
    TimeScrollBar: TScrollBar;
    AnimationTimer: TTimer;
    procedure PanBtnClick(Sender: TObject);
    procedure RotBtnClick(Sender: TObject);
    procedure SpeedZoomClick(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
    // procedure GroupBox2MouseEnter(Sender: TObject);
    procedure MoveXSpinEditChange(Sender: TObject);
    procedure GroupBox2MouseEnter(Sender: TObject);
    procedure WorldCBChange(Sender: TObject);
    procedure RotXSpinEditChange(Sender: TObject);
    procedure PausePlayBtnClick(Sender: TObject);
    procedure AnimationTimerTimer(Sender: TObject);
  private
    updatePos: boolean;
    m_fr: cCtrlFrameListener;
    m_ui: cUI;
    m_timecntrl:ctimeController;
    oldRotPos:point3;
  private

  public
    procedure OnTimeCtrlChange(sender:tobject);
    function GetTime:cardinal;

    procedure RotateObjectInSystem(obj:cnodeobject;rot:point3;system:word);
    procedure updateObjName(Sender: TObject);
    procedure InitWorldCB;
    procedure AddBtnClick(dPos: point3);
    procedure GetObjPos;
    procedure lincScene(p_ui: cUI);
  end;

implementation

{$R *.dfm}

procedure TTrfrmToolsFrame.OnTimeCtrlChange(sender:tobject);
begin
  TimeScrollBar.Max:=m_timecntrl.maxtime;
  TimeScrollBar.Position:=m_timecntrl.ticks;
end;

function TTrfrmToolsFrame.GetTime:cardinal;
begin
  result:=TimeScrollBar.Position;
end;

procedure TTrfrmToolsFrame.AnimationTimerTimer(Sender: TObject);
begin
  m_ui.TimeCntrl.time:=m_ui.TimeCntrl.time+AnimationTimer.Interval;
  m_ui.m_RenderScene.invalidaterect;
end;

procedure TTrfrmToolsFrame.InitWorldCB;
begin
  WorldCB.AddItem('World', nil);
  WorldCB.AddItem('Node', nil);
  WorldCB.AddItem('Local', nil);
  WorldCB.AddItem('Parent', nil);
  WorldCB.AddItem('View', nil);
  WorldCB.ItemIndex:=0;
end;

procedure TTrfrmToolsFrame.GetObjPos;
var
  p3: point3;
  obj: cNodeObject;
begin
  obj := m_ui.GetSelected(0);
  if obj <> nil then
  begin
    updatePos := false;
    p3 := obj.position;
    MoveYSpinEdit.Value := p3.y;
    MoveZSpinEdit.Value := p3.z;
    MoveXSpinEdit.Value := p3.x;
    updatePos := true;
  end;
end;

procedure TTrfrmToolsFrame.GroupBox2MouseEnter(Sender: TObject);
begin
  GetObjPos;
end;

procedure TTrfrmToolsFrame.AddBtnClick(dPos: point3);
var
  obj: cNodeObject;
  d: point3;
begin
  obj := m_ui.GetSelected();
  if obj <> nil then
  begin
    begin
      d := subvector(cobject(obj).position, dPos);
      case WorldCB.ItemIndex of
        constWorld:
          cobject(obj).position := dPos;
        constNode:
          begin
            cobject(obj).MoveNodeLocal(d.x, d.y, d.z);
            GetObjPos;
          end;
        constLocal:
          begin
            cobject(obj).MoveNodeInLocalNodeWorld(d.x, d.y, d.z);
            GetObjPos;
          end;
        constParent:
          begin
            cobject(obj).MoveNodeInParentWorld(d.x, d.y, d.z);
            GetObjPos;
          end;
      end;
    end;
  end;
end;

procedure TTrfrmToolsFrame.updateObjName(Sender: TObject);
var
  p3: point3;
  obj: cNodeObject;
begin
  obj := m_ui.GetSelected(0);
  if obj <> nil then
  begin
    ObjNameE.Text := obj.name;
    // обновляем позицию
    p3:=obj.position;
    MoveXSpinEdit.Value:=p3.x;
    MoveYSpinEdit.Value:=p3.y;
    MoveZSpinEdit.Value:=p3.z;
  end
  else
    ObjNameE.Text := '';


end;

procedure TTrfrmToolsFrame.lincScene(p_ui: cUI);
begin
  m_ui := p_ui;
  m_fr := cCtrlFrameListener.create(p_ui, 'CntrlFrame');
  m_ui.framelistener.add(m_fr);
  // Опциональные фичи
  m_ui.EventList.AddEvent('UI DrawMoveAxis', E_glRenderScene,  m_fr.DrawMoveAxis);
  m_ui.EventList.AddEvent('UI DrawRotateInterface', E_glRenderScene,  m_fr.drawRotateInterface);
  m_ui.EventList.AddEvent('TransformToolsFrameSelectUpdate', E_glSelectNew, updateObjName);

  // Анимация
  m_timecntrl:=m_ui.TimeCntrl;
  m_timecntrl.TimeEvents.AddEvent('TAnimationCtrlFrame onTimeChanged', ChangeOptsEvent+ChangeTimeEvent,OnTimeCtrlChange);
  OnTimeCtrlChange(nil);


  InitWorldCB;
end;

procedure TTrfrmToolsFrame.MoveXSpinEditChange(Sender: TObject);
var
  obj: cNodeObject;
  pos: point3;
begin
  // if UI.GetSelected(obj) then
  begin
    if updatePos then
    begin
      pos.x := MoveXSpinEdit.Value;
      pos.y := MoveYSpinEdit.Value;
      pos.z := MoveZSpinEdit.Value;
      AddBtnClick(pos);
      m_ui.m_RenderScene.invalidaterect;
    end;
  end;
end;

procedure TTrfrmToolsFrame.PanBtnClick(Sender: TObject);
var
  index: integer;
begin
  if TSpeedButton(Sender).Down then
  begin
    m_fr.LockMouse := true;
    m_fr.btn := pan;
    m_ui.setcursbyname('PAN_CURSOR');
  end
  else
  begin
    m_fr.btn := -1;
    m_fr.LockMouse := false;
    m_ui.cursor := crDefault;
  end;
  m_ui.m_RenderScene.invalidaterect;
end;

procedure TTrfrmToolsFrame.PausePlayBtnClick(Sender: TObject);
begin
  AnimationTimer.Enabled:=PausePlayBtn.down;
end;

procedure TTrfrmToolsFrame.RotBtnClick(Sender: TObject);
begin
  if TSpeedButton(Sender).Down then
  begin
    m_fr.btn := rot;
    m_fr.LockMouse := true;
  end
  else
  begin
    m_fr.LockMouse := false;
    m_fr.btn := -1;
  end;
  m_ui.cursor := crDefault;
  m_ui.m_RenderScene.invalidaterect;
end;

procedure TTrfrmToolsFrame.RotateObjectInSystem(obj:cnodeobject;rot:point3;system:word);
var
  camera:cbasecamera;
  tm:MatrixGl;
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
    constView:
    begin
      camera:=m_ui.m_renderscene.activecamera;
      tm:=camera.restm;
      tm:=setpos(tm,obj.position);
      obj.RotateNodeWorld(rot, tm);
      obj.SetObjToWorld;
    end;
  end;
end;


procedure TTrfrmToolsFrame.RotXSpinEditChange(Sender: TObject);
var
  obj: cNodeObject;
  p3, axis: point3;
begin
  obj := m_ui.GetSelected;
  if obj <> nil then
  begin
    if RotXSpinEdit.enabled then
    begin
      p3.x := RotXSpinEdit.Value - oldRotPos.x;
      p3.y := RotYSpinEdit.Value - oldRotPos.y;
      p3.z := RotZSpinEdit.Value - oldRotPos.z;
      if abs(p3.x) < 0.5 then
        p3.x := 0;
      if abs(p3.y) < 0.5 then
        p3.y := 0;
      if abs(p3.z) < 0.5 then
        p3.z := 0;
      RotateObjectInSystem(obj, p3, WorldCB.ItemIndex);
      m_ui.m_RenderScene.invalidaterect;
    end;
    oldRotPos.x := RotXSpinEdit.Value;
    oldRotPos.y := RotYSpinEdit.Value;
    oldRotPos.z := RotZSpinEdit.Value;
  end;
end;

procedure TTrfrmToolsFrame.SpeedZoomClick(Sender: TObject);
begin
  m_ui.Zoom;
  m_ui.m_RenderScene.invalidaterect;
  SpeedZoom.Down := false;
end;

procedure TTrfrmToolsFrame.WorldCBChange(Sender: TObject);
begin
  m_ui.AxisSystem := WorldCB.ItemIndex;
  m_ui.m_RenderScene.invalidaterect;
end;

procedure TTrfrmToolsFrame.ZoomBtnClick(Sender: TObject);
begin
  if TSpeedButton(Sender).Down then
  begin
    m_fr.btn := Zoom;
    m_ui.setcursbyname('ZOOM_CURSOR');
  end
  else
    m_fr.btn := -1;
  m_ui.m_RenderScene.invalidaterect;
end;

end.
