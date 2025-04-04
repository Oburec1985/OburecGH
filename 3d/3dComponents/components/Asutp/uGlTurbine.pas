unit uGlTurbine;

interface

uses
  SysUtils, Classes, Controls, messages, dialogs, usceneMng, mathfunction,
  uUI, uRender, uobject, ueditobj, uNodeObject, uObrfile,
  uglbaseitem,
  ueventlist,
  uglEventTypes,
  uEventTypes,
  uCommonTypes,
  uGroupObjects;

type
  cGlTurbine = class;

  cGlStage = class
  public
    glturbine: cGlTurbine;
    // �������
    st: cnodeobject;
    // ������ �������
    blades: tlist;
  protected
    procedure setbladecount(c: integer);
    Function Getbladecount: integer;
    procedure setBladesPos(blades: tlist);
  public
    constructor create(t: cGlTurbine);
    destructor destroy;
  public
    property bladecount: integer read Getbladecount write setbladecount;
  end;

  cGlTurbine = class(glRegItem)
  private
    blade: cnodeobject;
    stageObj: cnodeobject;
    res: string; // ���� � �������� (����������� ������)
    // ������ ��� ���������� �������
    stages: tstringlist;
  protected
    // ��������� ��������� �������
    startm: matrixgl;
    fphase: single;
  private
    function getscene: cscene;
  private
    function getname: string;
  protected
    // ������������� �� ������� cBaseGlComponent � ���������� ��� ��������� �����
    // ���� ��� ���������� ������� glRegItem �������� cBaseGlComponent
    procedure init; override;
    procedure setphase(p: single);
    // ������������� �� ������� ������ � ���������� �� ������ cScene.Add()
    procedure beforeaddobj(obj: cnodeobject); override;
  protected
    procedure setstagecount(c: integer);
    function GetStageCount: integer;
  public
    procedure addstage;
    function GetStage(i: integer): cGlStage;
    destructor destroy; override;
  published
    property Phase: single read fphase write setphase;
    property stageCount: integer read GetStageCount write setstagecount;
  end;

implementation

uses uBaseGlComponent, uConfigFile3d;

const
  sourceData = 'turbina_insts_1Blade.obr';

  // -----------------------------------------------------------------------
  // -----------------------------------------------------------------------
destructor cGlTurbine.destroy;
var
  i: integer;
  st: cGlStage;
begin
  if stages <> nil then
  begin
    for i := 0 to stages.Count - 1 do
    begin
      st := GetStage(i);
      st.destroy;
    end;
    stages.clear;
    stages.destroy;
  end;
  inherited;
end;

procedure cGlTurbine.setphase(p: single);
var
  d: single;
  i: integer;
  rot: point3;
begin
  i := trunc(p / 360);
  p := p - 360 * i;
  d := fphase - p;
  rot.x := 0;
  rot.y := d;
  rot.z := 0;
  node.RotateNodeInLocalNodeWorld(rot);
  fphase := p;
end;

function cGlTurbine.getname: string;
begin
  result := node.name;
end;

function cGlTurbine.getscene: cscene;
var
  ui: cUI;
begin
  ui := cbaseglcomponent(basegl).mUI;
  if ui <> nil then
    result := ui.scene
  else
    result := nil;
end;

procedure cGlTurbine.beforeaddobj(obj: cnodeobject);
var
  p3: point3;
  st: cGlStage;
begin
  inherited;
  if not allinit then
  begin
    if (stageObj = nil) and (obj.name = 'Cylinder01') then
      stageObj := obj;
    if (node = nil) and (obj.name = 'Group01') then
      node := obj;
    if (blade = nil) and (obj.name = 'Loft01') then
    begin
      blade := obj;
      startm := blade.nodetm;
    end;
    if (stageObj <> nil) and (node <> nil) and (blade <> nil) then
    begin
      allinit := true;
    end;
    if allinit then
    begin
      stages := tstringlist.create;
      stages.Sorted := true;
      st := cGlStage.create(self);
      st.st := stageObj;
      st.blades.Add(blade);
      stages.AddObject(st.st.name, st);
    end;
  end;
end;

procedure cGlTurbine.init;
var
  scene: cscene;
  p3: point3;
begin
  // ��������� ������� �����
  if cbaseglcomponent(basegl).mUI = nil then
    exit;
  cbaseglcomponent(basegl).mUI.EventList.AddEvent
    (name + ' BeforeAddObjToScene', E_OnAddObjInstance, doBeforeAddObj);
  scene := getscene;
  if scene = nil then
    exit;
  res := cbaseglcomponent(basegl).mUI.ConfigFile.findMeshFile(sourceData);
  // meshes.strings[0]+sourceData;
  if node = nil then
  begin
    scene.m_EnableAddObjInstanceEvent:=true;
    if LoadObrFile(res, cbaseglcomponent(basegl).mUI.ConfigFile, scene) then
    begin
      fphase := 0;
      if blade <> nil then
      begin
        // startm:=stick.nodetm;
        // p3.x:=-90; p3.y:=0; p3.z:=0;
        // stick.RotateNodeLocal(p3);
        // endtm:=stick.nodetm;
        // cobject(node).fOnClick:=doClick;
        // allinit:=true;
        cbaseglcomponent(basegl).mUI.EventList.removeEvent
          (doBeforeAddObj, E_OnAddObjInstance);
      end;
    end;
    scene.m_EnableAddObjInstanceEvent:=false;
  end;
  inherited;
end;

procedure cGlTurbine.addstage;
var
  newstage: cGlStage;
  scene: cscene;
  obj: cnodeobject;
begin
  scene := getscene;
  newstage := cGlStage.create(self);
  obj := scene.CopyObject(stageObj);
  newstage.st := obj;
  stages.AddObject(obj.name, newstage);
end;

procedure cGlTurbine.setstagecount(c: integer);
var
  st: cGlStage;
begin
  if c = stages.Count then
    exit;
  if c > stages.Count then
  begin
    while c > stages.Count do
    begin
      addstage;
    end;
  end
  else
  begin
    while c < stages.Count do
    begin
      st := cGlStage(stages.Objects[stages.Count - 1]);
      stages.Delete(stages.Count - 1);
    end;
  end;
end;

function cGlTurbine.GetStageCount: integer;
begin
  result := stages.Count;
end;

function cGlTurbine.GetStage(i: integer): cGlStage;
begin
  result := cGlStage(stages.Objects[i]);
end;

constructor cGlStage.create(t: cGlTurbine);
begin
  glturbine := t;
  blades := tlist.create;
end;

destructor cGlStage.destroy;
var
  i: integer;
  obj: cnodeobject;
begin
  if glturbine.InitUI then
  begin
    for i := 0 to blades.Count - 1 do
    begin
      obj := cnodeobject(blades.Items[i]);
      obj.destroy;
    end;
    st.destroy;
  end;
  blades.destroy;
end;

procedure cGlStage.setBladesPos(blades: tlist);
var
  blCount: integer;
  d: single;
  i: integer;
  bl: cnodeobject;
  StartBladeTM: matrixgl;
begin
  blCount := blades.Count;
  d := 360 / blCount;
  StartBladeTM := cnodeobject(blades.Items[0]).nodetm;
  for i := 1 to blades.Count - 1 do
  begin
    bl := cnodeobject(blades.Items[i]);
    bl.nodetm := StartBladeTM;
    bl.RotateNodeInParentWorld(p3(0, d * i, 0));
  end;
end;

procedure cGlStage.setbladecount(c: integer);
var
  i: integer;
  bl: cnodeobject;
  scene: cscene;
begin
  if c = blades.Count then
    exit;
  scene := glturbine.getscene;
  if c > blades.Count then
  begin
    SetGroupState(st, false);
    while c > blades.Count do
    begin
      bl := scene.CopyObject(glturbine.blade);
      bl.parent := glturbine.blade.parent;
      blades.Add(bl);
    end;
    SetGroupState(st, true);
  end
  else
  begin
    while c < blades.Count do
    begin
      bl := cnodeobject(blades.Items[blades.Count - 1]);
      bl.destroy;
      blades.Delete(blades.Count - 1);
    end;
  end;
  setBladesPos(blades);
  cbaseglcomponent(glturbine.basegl).Invalidate;
end;

Function cGlStage.Getbladecount: integer;
begin
  result := blades.Count;
end;

initialization

finalization

end.
