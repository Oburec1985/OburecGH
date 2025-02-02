// ����� DesignIntf DesignEditors � Proxies ���������� ��������
// ����� ����������� $(Delphi)Lib/designide.dcp
unit uBaseGlComponent;

interface

uses
  SysUtils, Classes, Controls, messages, dialogs, uSceneMng, ExtCtrls,
  stdctrls,
  uUI,
  uObjCtrFrame,
  forms,
  uRender,
  uobject,
  ueditobj,
  uNodeObject,
  uGlBaseItem,
  uGlComponent,
  windows,
  uEventList,
  uClickFrListener,
  uDeformerFrame, //����� ������
  uTransformButtons,
  PathUtils,
  uglEventTypes;

const
  E_ComponentInit = 1;

type

  cBaseGlComponent = class(tpanel)
  protected
    fOnRBtn:Tnotifyevent;
  protected
    fres: string;
    scene: string;
    // ��������� �� �����. ������� ������� ��� ������ idesigner
    mObjects: array of ceditobj;
    // ����� ������
    DeformFrame:cEditFrameListener;
    ClickFrame: cClickFrListener;

    fShowTransforms:boolean;
    TransformToolsFrame: TCtrlViewFrame;
  public
    // ������ �� ������ ������� ����������
    EList: cEventList;
    // ���� �������� true ������ ������ ��� �������� � ����� ���� ���������
    update: boolean;
    // ������ �� ������ ������
    mUI: cUI;
    // ������� ������� � ������� idesigner
    SubComponents: TList;
  protected
    fOnInit: tNotifyEvent;
  public
    Constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure redraw;
    // ������� ��������� �� ������ �����
    procedure RemoveChild(component: TComponent);
  protected
    procedure createEvents;
    procedure DeleteEvents;
    // �������� ������ �������� cEditObjects ��� ���������� � dfm ����
    procedure lincObjects;
    // �������� ������ �������� cEditObjects ��� ���������� � dfm ����
    procedure deleteobjects;
    // ����� ���������� �������� �����
    procedure init;
    // ��������/���������� ���� � ��������
    procedure SetSceneName(val: string);
    function GetSceneName: string;
    // ��������/���������� ���� � ��������
    procedure SetResources(val: string);
    function GetResources: string;
    // �������� �������� ������ �����
    function getObj: cobject;
    // -------------------------------
    function readObj(i: integer): ceditobj;
    procedure WndProc(var Message: TMessage); override;
    // ���������� ����� �������� �����
    procedure Loaded; override;
    procedure CreateFrames;
    // �������� ������� ��� �������������� �����
    procedure linkFormFrames;
  protected
    // ��������� ������� ���������� ��� ���������� �����
    procedure WriteState(Writer: TWriter); override;
    // ���������������� ����� ��� ���������� ������� ��������
    // ��������� ������� ������ �� ��������� ������� ����� ��������� �� ��� ����
    // ��������
    procedure DefineProperties(Filer: TFiler); override;
    // function GetChildOwner:tcomponent; override;
    // function GetChildParent:tcomponent;override;
    procedure OnDestroyScene(Sender: tobject);
  private
    // ��������� ���������� ���������� ������� �������� � �����
    procedure readObjects(Reader: TReader);
    // ��������� �������� ���������� ������� �������� � �����
    procedure writeObjects(Writer: TWriter);
    //
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function getSubComponent(index: integer): glRegItem;
    procedure InitScene;
    // ������������� ��������� ����. ���������� ��� ������ ����������� ����
    procedure Oninithandle(var Message: TCMControlListChanging);
    message wm_size;
    // ������� ����� �������
    procedure changecursor(Sender: tobject);
    // ������� ����� ������� ��� �������� ���������
    procedure changecursorOnUnselect(Sender: tobject);
  public
    // �������� ��� ����. ����� ���������
    property objects[i: integer]: ceditobj read readObj;
  public
  public
    property subComponent[index: integer]: glRegItem read getSubComponent;
  protected
    Procedure SetShowTransforms(b: boolean);
  published
    property OnRBtn:Tnotifyevent read fOnRBtn write fOnRBtn;
    // ������� �������
    // property position:cpoint3 read pos write pos;
    // �������� �������� �� ������� �����
    property obj: cobject read getObj;
    property scenename: string read GetSceneName write SetSceneName;
    property resources: string read GetResources write SetResources;
    property ShowTrasforms: boolean read fShowTransforms write
      SetShowTransforms;
  published
    property OnInitScene: tNotifyEvent read fOnInit write fOnInit;
  end;

implementation

procedure cBaseGlComponent.linkFormFrames;
begin
  // TVframe:=TSceneTVFrame.Create(self);
  // g_ui.scene.images_16:=ImageList_16;
  // g_ui.scene.images_32:=ImageList_32;
  // tvframe.link(g_UI, GroupBox1, ImageList_32);

  //TransformToolsFrame:=TTransformToolsFrame.Create(self);
  //TransformToolsFrame.Parent := self;
  //TransformToolsFrame.Lincscene(mUI);
  //TransformToolsFrame.Visible := ShowTrasforms;

  {gb:=TGroupBox.Create(self);
  gb.Align:=alBottom;
  gb.Height:=200;
  TransformToolsFrame:=TCtrlViewFrame.Create(gb);
  TransformToolsFrame.Align:=alRight;
  TransformToolsFrame.Parent :=gb;
  TransformToolsFrame.lincScene(mUI);}
end;

procedure cBaseGlComponent.changecursor(Sender: tobject);
begin
  if mUI <> nil then
    cursor := mUI.cursor;
end;

procedure cBaseGlComponent.changecursorOnUnselect(Sender: tobject);
begin
  if mUI <> nil then
  begin
    if mUI.cursor <> crdefault then
    begin
      mUI.cursor := crdefault;
      cursor := mUI.cursor;
    end;
  end;
end;

procedure cBaseGlComponent.redraw;
begin
  if mUI <> nil then
    mUI.m_RenderScene.invalidaterect;
end;

// ���������������� ����� ��� ���������� ������� ��������
procedure cBaseGlComponent.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  self.DockSite := true;
  // ���������� ������ ���������� �������� TextHistory � ���� �����
  // Filer.DefineProperty('Objects', readObjects, writeObjects, true);
end;

procedure cBaseGlComponent.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: integer;
begin
  inherited;
  if SubComponents <> nil then
  begin
    for i := 0 to SubComponents.Count - 1 do
    begin
      Proc(TComponent(SubComponents.Items[i]));
      // Proc(TComponent(Components[i]));
    end;
  end;
end;

procedure cBaseGlComponent.RemoveChild(component: TComponent);
var
  i: integer;
begin
  for i := 0 to SubComponents.Count - 1 do
  begin
    if SubComponents.Items[i] = component then
    begin
      SubComponents.Delete(i);
      exit;
    end;
  end;
end;

// ��������� ���������� ���������� ������� �������� � �����
procedure cBaseGlComponent.readObjects(Reader: TReader);
begin
  try
    // ����� ������ ������ ������
    Reader.ReadListBegin;
    // ��������� �������� ������ �������
    while not Reader.EndOfList do
    begin
      Reader.ReadString;
    end;
    // ��������� ������ ��������� ������
    Reader.ReadListEnd;
  except
    raise ;
  end;
end;

procedure cBaseGlComponent.WriteState(Writer: TWriter);
var
  i: integer;
  obj: ceditobj;
begin
  inherited WriteState(Writer);
  if update then
  begin
    update := false;
    if mUI <> nil then
    begin
      mUI.scene.SaveScene(scene);
    end;
  end;
  for i := 0 to ComponentCount - 1 do
  begin
  end;
  // Writer.Root:=self;
  // for I := 0 to length(mobjects) - 1 do
  // begin
  // obj := mobjects[i];
  // if obj.Owner = Writer.Root then
  // Writer.WriteComponent(obj);
  // end;
end;

// ��������� �������� ���������� ������� �������� � �����
procedure cBaseGlComponent.writeObjects(Writer: TWriter);
var
  len, i: integer;
begin
  // �������� ������ ������ ������
  len := length(mObjects);
  if len = 0 then
    exit;
  Writer.WriteListBegin;
  // �������� ������� ���������
  // Writer.root:=self;
  // Writer.WriteComponent(self);
  // for i:=0 to len-1 do
  // begin
  // end;
  // �������� ������ ��������� ������
  Writer.WriteListEnd;
end;

procedure cBaseGlComponent.deleteobjects;
var
  i, len: integer;
begin
  len := length(mObjects);
  for i := 0 to len - 1 do
  begin
    mObjects[i].destroy;
  end;
  setlength(mObjects, 0);
end;

procedure cBaseGlComponent.lincObjects;
var
  len, i: integer;
  obj: ceditobj;
begin
  if mUI <> nil then
  begin
    len := mUI.scene.Count;
    setlength(mObjects, len);
    for i := 0 to len - 1 do
    begin
      obj := ceditobj.Create(self);
      mObjects[i] := obj;
      obj.SetObj(cobject(mUI.scene.getObj(i)));
    end;
  end;
end;

procedure cBaseGlComponent.init;
begin
  if fileexists(scene) then
  begin
    if mUI <> nil then
    begin
      mUI.m_RenderScene.LoadScene(scene);
      lincObjects;
    end;
  end;
end;

procedure cBaseGlComponent.Loaded;
begin
  inherited;
  InitScene;
end;

procedure cBaseGlComponent.SetSceneName(val: string);
begin
  scene := val;
  init;
end;

function cBaseGlComponent.GetSceneName: string;
begin
  result := scene;
end;

Procedure cBaseGlComponent.SetShowTransforms(b: boolean);
begin
  fShowTransforms:=b;
  if TransformToolsFrame<>nil then
    TransformToolsFrame.Visible := b;
end;

function cBaseGlComponent.readObj(i: integer): ceditobj;
var
  obj: cobject;
  len: integer;
begin
  // ���� �� ��������� nil �������� ������� ����� ��������
  len := length(mObjects);
  result := nil;
  if mUI <> nil then
  begin
    if i < len then
      result := mObjects[i];
  end;
end;

function cBaseGlComponent.getObj: cobject;
var
  obj: cobject;
begin
  // ���� �� ��������� nil �������� ������� ����� ��������
  result := nil;
  if mUI <> nil then
  begin
    result := cobject(mUI.getselected);
  end;
end;

procedure cBaseGlComponent.Oninithandle;
begin
  InitScene;
  // ���������� ����� �������������� ���� � ��������� ��������
  if TransformToolsFrame=nil then
  begin
    ShowTrasforms:=true;
    //linkFormFrames;
  end;
end;

procedure cBaseGlComponent.InitScene;
begin
  if Parent <> nil then
  begin
    if Parent.HandleAllocated then
    begin
      if HandleAllocated then
      begin
        if fileexists(fres) then
        begin
          if mUI = nil then
          begin
            mUI := cUI.Create(handle, fres);
            init;
            createEvents;
            // ����� ������� ����������� �����������
            if EList <> nil then
              EList.CallAllEvents(E_ComponentInit);
            CreateFrames;
            if assigned(fOnInit) then
              fOnInit(self);
          end
          else
          begin
          end;
        end;
      end;
    end;
  end;
end;

procedure cBaseGlComponent.createEvents;
begin
  mUI.EventList.AddEvent(name + 'changecursor', E_glMouseMove, changecursor);
  mUI.EventList.AddEvent(name + 'changecursorunselect', E_glUnSelect,
    changecursorOnUnselect);
  mUI.EventList.AddEvent(name + 'OnDestroyScene', E_GlOnDestroyScene,
    OnDestroyScene);
end;

procedure cBaseGlComponent.DeleteEvents;
begin
  mUI.EventList.removeEvent(changecursor, E_glMouseMove);
  mUI.EventList.removeEvent(changecursorOnUnselect, E_glUnSelect);
  mUI.EventList.removeEvent(OnDestroyScene, E_GlOnDestroyScene);
end;

procedure cBaseGlComponent.SetResources(val: string);
var
  curdir:string;
begin
  curdir:=GetCurrentDir;
  if val<>'' then
    val:=RelativePathToAbsolute(curdir, val);
  fres := val;
  if not(csLoading in componentstate) then
  begin
    InitScene;
  end;
end;

function cBaseGlComponent.GetResources: string;
begin
  result := fres;
end;

Constructor cBaseGlComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Parent := TWinControl(AOwner);
  Width := 200;
  hEIght := 200;
  resources := '';
  scenename := '';
  update := false;
  SubComponents := TList.Create;
  EList := cEventList.Create(self, false);

  // SetSubComponent(true);
end;

destructor cBaseGlComponent.destroy;
begin
  if mUI <> nil then
  begin
    mUI.destroy;
  end;
  deleteobjects;
  if SubComponents <> nil then
    SubComponents.destroy;
  if EList <> nil then
    EList.destroy;
  inherited destroy;
end;

procedure cBaseGlComponent.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    wm_paint:
    begin
      if mUI <> nil then
      begin
        if handle <> mUI.m_RenderScene.m_wndContext.handle then
        begin
          mUI.updatehandle := true;
        end;
      end;
      // mUI.m_RenderScene.RenderScene;
    end;
    WM_RBUTTONDOWN:
    begin
      if assigned(OnRBtn) then
      begin
        OnRBtn(self);
      end;
    end;
  end;
end;

{
  // ��������� �������� ���������� ������� �������� � �����
  procedure cBaseGlComponent.writeObjects(Writer: TWriter);
  var
  i:integer;
  begin
  // �������� ������ ������ ������
  Writer.WriteListBegin;
  // �������� ������� ���������
  for i:=0 to mUI.m_RenderScene.GetCount-1 do
  begin
  Writer.WriteString(mUI.m_RenderScene.m_Loader.GetObj(i).name);
  end;
  // �������� ������ ��������� ������
  Writer.WriteListEnd;
  end;
}

procedure cBaseGlComponent.CreateFrames;
begin
  if mUI <> nil then
  begin
    ClickFrame := cClickFrListener.Create(mUI, 'cClickFrListener');
    mUI.framelistener.add(ClickFrame);
    DeformFrame:=cEditFrameListener.create(mUI,'cDeformFrListener');
    mUI.framelistener.add(DeformFrame);
  end;
end;

function cBaseGlComponent.getSubComponent(index: integer): glRegItem;
begin
  result := nil;
  if SubComponents <> nil then
  begin
    if (index >= 0) and (index < SubComponents.Count) then
      result := glRegItem(SubComponents.Items[index]);
  end;
end;

procedure cBaseGlComponent.OnDestroyScene(Sender: tobject);
begin
  mUI := nil;
end;

end.
