unit uGlComponent;

interface
uses
  SysUtils, Classes, Controls, messages, dialogs, usceneMng, mathfunction,
  uUI, uRender, uobject,ueditobj, uNodeObject, uObrfile,
  uglbaseitem, ueventlist, uglEventTypes, uCommonTypes;

type


  cGlButton = class(glRegItem)
  private
    stick:cnodeobject;
    res:string; // ���� � �������� (����������� ������)
  // ������ ��� ���������� �������
  private
    fdown:boolean;
    startm,endtm:matrixgl;
  private
    function getscene:cscene;
  private
    procedure SetDown(val:boolean);
    function GetDown:boolean;
    function getname:string;
  protected
    // ������������� �� ������� cBaseGlComponent � ���������� ��� ��������� �����
    // ���� ��� ���������� ������� glRegItem �������� cBaseGlComponent
    procedure init;override;
    // ������������� �� ������� ������ � ���������� �� ������ cScene.Add()
    procedure beforeaddobj(obj:cnodeobject);override;
  public
    procedure switchState;
  published
    property down:boolean read getDown write setDown;
  end;

implementation
  uses uBaseGlComponent, uConfigFile3d;
  const sourceData = 'SwitchButton.obr';

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
function cGlButton.getname:string;
begin
  result:=node.name;
end;

function cGlButton.getscene:cscene;
var ui:cUI;
begin
  ui:=cbaseglcomponent(basegl).mUI;
  if ui<>nil then
    result:=ui.scene
  else
    result:=nil;
end;

procedure cGlButton.beforeaddobj(obj:cnodeobject);
var p3:point3;
begin
  inherited;
  if not allinit then
  begin
    if (node=nil) and (obj.name='SwitchButton') then
      node:=obj;
    if (stick=nil) and (obj.name='stick') then
      stick:=obj;
  end;
end;

procedure cGlButton.init;
var
  scene:cscene;
  p3:point3;
begin
  // ��������� ������� �����
  if cBaseGlComponent(basegl).mUI=nil then exit;
  cBaseGlComponent(basegl).mUI.EventList.AddEvent(name+' BeforeAddObjToScene', E_GlBeforeAddObj,doBeforeAddObj);
  scene:=getscene;
  if scene=nil then exit;
  res:=cbaseglcomponent(basegl).mUI.ConfigFile.findMeshFile(sourcedata);
  //meshes.strings[0]+sourceData;
  if node=nil then
  begin
    if LoadObrFile(res, cbaseglcomponent(basegl).mUI.ConfigFile, scene) then
    begin
      if stick<>nil then
      begin
        startm:=stick.nodetm;
        p3.x:=-90; p3.y:=0; p3.z:=0;
        stick.RotateNodeLocal(p3);
        endtm:=stick.nodetm;
        down:=fdown;
        allinit:=true;
        cBaseGlComponent(basegl).mUI.EventList.removeEvent(doBeforeAddObj,E_GlBeforeAddObj);
      end;
    end
    else
    begin
      showmessage('�� ������� ����� ������ � ���������� � �������� '+cbaseglcomponent(basegl).resources);
    end;
  end;
  inherited;
end;

procedure cGlButton.switchState;
begin
  down:=not fdown;
end;

procedure cGlButton.SetDown(val:boolean);
begin
  fdown:=val;
  if stick<>nil then
  begin
    if fdown then
      stick.nodetm:=endtm
    else
      stick.nodetm:=startm;
  end;
  redraw;
end;

function cGlButton.GetDown:boolean;
begin
  result:=fdown;
end;

initialization

finalization


end.
