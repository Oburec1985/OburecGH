// ������ �������� ������� ��� �������� ��������� ��������
unit uTestObjects;

interface
uses
  Classes, uObject, uLight, ubasecamera, uMatrix, MathFunction,
  uNodeObject,opengl,uCommonTypes;

  function TestLight(p_scene:tobject):clight;
  function TestCamera(p_scene:tobject):cBaseCamera;
  function TestNodeObject(p_scene:tobject):cNodeObject;
  function TestObject(p_scene:tobject):cobject;

implementation
uses
  uSceneMng;

function TestObject(p_scene:tobject):cobject;
var obj:cobject;
begin
  obj:=cobject.Create;
  obj.name:='TestObject';
  result:=obj;
end;

function TestLight(p_scene:tobject):clight;
var Light:cLight;
begin
 Light:=clight.create(gl_light0,p_scene);
 //Light:=cscene(p_scene).lights.AddLight;
 Light.name:='TestLight';
 result:=light;
end;

function TestCamera(p_scene:tobject):cBaseCamera;
var camera:cBaseCamera;
    pos:point3;
begin
 camera:=cBaseCamera.Create;
 pos.x:=0; pos.y:=0; pos.z:=-5;
 camera.position:=pos;
 pos.x:=0;pos.y:=0;pos.z:=0;
 camera.RotateNodeGlobal(pos);
 camera.name:='TestCamera';
 camera.keepquad:=true;
 result:=camera;
end;

Function TestNodeObject(p_scene:tobject):cNodeObject;
var obj:cNodeObject;
begin
  obj:=cNodeObject.Create;
  obj.name:='TestNodeObject';
  result:=obj;
end;

end.
