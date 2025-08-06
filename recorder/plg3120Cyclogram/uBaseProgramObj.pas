unit uBaseProgramObj;

interface

uses
  classes, uBaseObj, uBaseObjMng, NativeXML, recorder,
  dialogs, activeX,
  sysutils, windows, uRecorderEvents, VirtualTrees, uVTServices,
  tags,
  MathFunction,
  uCommonMath,
  ucommontypes,
  pluginclass, plugin, u2dMath, uRCFunc, PathUtils,
  uPathMng,
  IniFiles,
  uEventTypes,
  uAlarms,
  uSetList,
  u3120RTrig,
  uControlObj,
  blaccess;

type

  cBaseProgramObj = class(cbaseobj)
  private
    fStartTrig: cBaseTrig;
    fStoptrig: cBaseTrig;

    cs_StartTrig: TRTLCriticalSection;
    fStartState: boolean;

    cs_StopTrig: TRTLCriticalSection;
    fStopState: boolean;

  protected
    procedure InitCS;
    procedure DeleteCS;
    procedure DestroyEvents;
    procedure createEvents;
    procedure setStartTrig(t: cBaseTrig);
    procedure setStopTrig(t: cBaseTrig);
    // здесь по событию обновления триггера, если триггер сработал, то ставиться stateStart или StateStop в true
    // сброс в false происходит в проверке StateStart/StateTrue в Exec
    procedure doUpdateTrig(sender: tobject);
    procedure setname(n: string); override;
    procedure setactive(b:boolean);virtual;abstract;
    function getactive:boolean;virtual;abstract;
  public
    property active:boolean read getactive write setactive;
    constructor create; override;
    destructor destroy; override;
  end;

implementation

uses
  u3120ControlObj;

  //uMeasureBase,   uMBaseControl  ;

function getmin(i1, i2: integer): integer;
begin
  if i1 >= i2 then
    result := i2
  else
    result := i1;
end;


{ cControlObj }
procedure incCounter(var c: Cardinal);
begin
  inc(c);
  if c = c_Cardmax then
  begin
    c := 0;
  end;
end;



function ControlComparator(p1, p2: pointer): integer;
var
  c1, c2: cControlObj;
begin
  c1 := cControlObj(p1);
  c2 := cControlObj(p2);
  // if c1.OwnerProg.fcontrols.sorttype=1 then

  if c1.Index > c2.Index then
  begin
    result := 1;
  end
  else
  begin
    if c1.Index < c2.Index then
    begin
      result := -1;
    end
    else
    begin
      result := 0;
    end;
  end;
end;

procedure writeTrig(node: txmlnode; key: string; t: cBaseTrig);
var
  child, actions, ActNode: txmlnode;
  childTrig: cBaseTrig;
  i: integer;
  act: TTrigAction;
  ct: cTag;
begin
  child := GetNode(node, key);
  if t.m_actions <> nil then
  begin
    actions := GetNode(child, 'Actions');
    for i := 0 to t.m_actions.Count - 1 do
    begin
      ActNode := GetNode(actions, 'Act_' + inttostr(i));
      act := TTrigAction(t.m_actions.Items[i]);
      if act.m_target <> nil then
        ActNode.WriteAttributeString('TargetName', cbaseobj(act.m_target).name)
      else
        ActNode.WriteAttributeString('TargetName', act.targetname);
      ActNode.WriteAttributeInteger('ActionType', act.opertype);
      ActNode.WriteAttributeBool('ActionFront', act.m_Front);
      if (act.opertype = c_action_MDBaddProp) or
        (act.opertype = c_action_MDBsetProp) or
        (act.opertype = c_action_MDBdecProp) then
      begin
        ActNode.WriteAttributeString('MDBPropName', act.mdbPropName);
        if act.mdbTag <> nil then
        begin
          ct := act.getctag;
          saveTag(ct, ActNode);
        end
        else
        begin
          ActNode.WriteAttributeString('MDBPropVal', act.mdbPropVal);
        end;
      end;
    end;
  end;
  child.WriteAttributeString('Name', t.name);
  child.WriteAttributeInteger('Type', TrigTypeToInt(t.Trigtype));
  child.WriteAttributeBool('Inverse', t.Inverse);
  child.WriteAttributeBool('EnableOnStart', t.m_enableOnStart);
  child.WriteAttributeBool('DisableOnApply', t.m_DisableOnApply);
  if t is crtrig then
  begin
    child.WriteAttributeString('Trigname', crtrig(t).channame, '');
    child.WriteAttributeFloat('Threshold', crtrig(t).threshold);
  end
  else
  begin
    if t is cTimeTrig then
    begin
      child.WriteAttributeInteger('dueTime', cTimeTrig(t).dueTime);
    end
    else
    begin
      if t is cAlarmTrig then
      begin
        saveTag(cAlarmTrig(t).tag, child);
      end;
    end;
  end;

  child.WriteAttributeInteger('OrCount', t.m_orTrigs.Count);
  for i := 0 to t.m_orTrigs.Count - 1 do
  begin
    childTrig := cBaseTrig(t.m_orTrigs.Objects[i]);
    writeTrig(child, key + '_or_' + inttostr(i), childTrig);
  end;
  child.WriteAttributeInteger('AndCount', t.m_AndTrigs.Count);
  for i := 0 to t.m_AndTrigs.Count - 1 do
  begin
    childTrig := cBaseTrig(t.m_AndTrigs.Objects[i]);
    writeTrig(child, key + '_and_' + inttostr(i), childTrig);
  end;

  child.WriteAttributeInteger('ChildCount', t.ChildCount);
  for i := 0 to t.ChildCount - 1 do
  begin
    childTrig := cBaseTrig(t.getChild(i));
    writeTrig(child, key + '_' + inttostr(i), childTrig);
  end;
end;


function ReadTrig(node: txmlnode; key: string; p: tobject): cBaseTrig;
var
  child, actions, ActNode: txmlnode;
  act: TTrigAction;
  i: TTrigType;
  ChildCount, J: integer;
  t, childTrig: cBaseTrig;
  str: string;
  trigtarget: cbaseobj;
  ct: cTag;
  b: boolean;
begin
  b := false;
  for J := 0 to node.NodeCount - 1 do
  begin
    child := node.Nodes[J];
    if child.name = key then
    begin
      b := true;
      break;
    end;
  end;
  if not b then
    child := nil;
  // child := node.FindNode(key);
  result := nil;
  if child <> nil then
  begin
    i := InttoTrigtype(child.ReadAttributeInteger('Type', 0));
    case i of
      TrPause:
        begin
          t := cTimeTrig.create(p);
          t.Trigtype := i;
        end;
      trAlarms:
        begin
          t := cAlarmTrig.create(p);
          t.Trigtype := i;
        end
      else
      begin
        t := crtrig.create(p);
        t.Trigtype := i;
      end;
    end;
    if t is crtrig then
    begin
      str := child.ReadAttributeString('Trigname', '');
      crtrig(t).setchannel(str);
      crtrig(t).threshold := child.ReadAttributeFloat('Threshold', 0.5);
    end
    else
    begin
      if t is crtrig then
      begin
        cTimeTrig(t).dueTime := child.ReadAttributeInteger('dueTime', 0);
      end
      else
      begin
        ct := LoadTag(child, nil);
        if ct.tag <> nil then
        begin
          cAlarmTrig(t).tag.tag := ct.tag;
        end;
        ct.destroy;
      end;
    end;
    t.name := child.ReadAttributeString('Name', crtrig(t).name);
    t.Inverse := child.ReadAttributeBool('Inverse', false);
    t.m_enableOnStart := child.ReadAttributeBool('EnableOnStart', false);
    t.m_DisableOnApply := child.ReadAttributeBool('DisableOnApply', false);

    actions := child.FindNode('Actions');
    if actions <> nil then
    begin
      t.m_actions := tlist.create;
      for J := 0 to actions.NodeCount - 1 do
      begin
        ActNode := actions.FindNode('Act_' + inttostr(J));
        act := TTrigAction.create(t);
        str := ActNode.ReadAttributeString('TargetName', '');
        act.targetname := str;
        act.opertype := ActNode.ReadAttributeInteger('ActionType', -1);
        act.m_Front := ActNode.ReadAttributeBool('ActionFront', true);
        if (act.opertype = c_action_MDBaddProp) or
          (act.opertype = c_action_MDBsetProp) or
          (act.opertype = c_action_MDBdecProp) then
        begin
          act.mdbPropName := ActNode.ReadAttributeString('MDBPropName', '');
          ct := LoadTag(ActNode, nil);
          if ct.tag = nil then
          begin
            act.mdbPropVal := ActNode.ReadAttributeString('MDBPropVal', '');
          end;
          act.mdbTag := ct.tag;
          ct.destroy;
          ct := nil;
        end;
        t.addAction(act);
      end;
    end;

    ChildCount := child.ReadAttributeInteger('OrCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_or_' + inttostr(J), p);
      t.addOrTrig(childTrig);
    end;
    ChildCount := child.ReadAttributeInteger('AndCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_and_' + inttostr(J), p);
      // if childTrig.name<>'Trig_m02' then
      t.addAndTrig(childTrig)
      // else
      // childTrig.destroy;
    end;

    ChildCount := child.ReadAttributeInteger('ChildCount', 0);
    for J := 0 to ChildCount - 1 do
    begin
      childTrig := ReadTrig(child, key + '_' + inttostr(J), p);
      t.AddChild(childTrig);
    end;
    result := t;
  end;
end;


{ cModeObj }



Function IntToTPType(i: integer): TPType;
begin
  case i of
    0:
      result := ptNullPoly;
    1:
      result := ptlinePoly;
    2:
      result := ptCubePoly;
  end;
end;

Function TPTypeToInt(pt: TPType): integer;
begin
  case pt of
    ptNullPoly:
      result := 0;
    ptlinePoly:
      result := 1;
    ptCubePoly:
      result := 2;
  end;
end;

{ cBaseProgramObj }

procedure cBaseProgramObj.InitCS;
begin
  InitializeCriticalSection(cs_StartTrig);
  InitializeCriticalSection(cs_StopTrig);
end;

procedure cBaseProgramObj.DeleteCS;
begin
  DeleteCriticalSection(cs_StartTrig);
  DeleteCriticalSection(cs_StopTrig);
end;

destructor cBaseProgramObj.destroy;
begin
  DestroyEvents;
  DeleteCS;
  inherited;
end;

constructor cBaseProgramObj.create;
begin
  inherited;
  createEvents;
  InitCS;
end;

procedure cBaseProgramObj.DestroyEvents;
begin
  if g_conmng.Events <> nil then
  begin
    g_conmng.Events.removeEvent(doUpdateTrig, E_OnUpdateTrig);
  end;
end;

procedure cBaseProgramObj.createEvents;
begin
  g_conmng.Events.AddEvent('cBaseProgramObj_doUpdateTrig', E_OnUpdateTrig,
    doUpdateTrig);
end;

// здесь по событию обновления триггера, если триггер сработал, то ставиться stateStart или StateStop в true
// сброс в false происходит в проверке StateStart/StateTrue в Exec
procedure cBaseProgramObj.doUpdateTrig(sender: tobject);
begin
  if sender is crtrig then
  begin
    if sender = fStartTrig then
    begin

    end;
    if sender = fStoptrig then
    begin

    end;
  end;
end;


procedure cBaseProgramObj.setname(n: string);
begin
  inherited;
  if isValue(n) then
  begin
    caption := n;
    if classname= 'cProgramObj' then
    begin
      fname := 'p' + n;
    end;
    if classname= 'cModeObj' then
    begin
      fname := 'm' + n;
    end;
  end;
end;

procedure cBaseProgramObj.setStartTrig(t: cBaseTrig);
begin
  if fStartTrig <> nil then
  begin
    if fStartTrig.owner = self then
    begin
      fStartTrig.destroy;
    end;
  end;
  fStartTrig := t;
  g_conmng.addtrig(t);
end;

procedure cBaseProgramObj.setStopTrig(t: cBaseTrig);
begin
  if fStoptrig <> nil then
  begin
    if fStartTrig.owner = self then
    begin
      fStoptrig.destroy;
    end;
  end;
  fStoptrig := t;
  g_conmng.addtrig(t);
end;


end.
