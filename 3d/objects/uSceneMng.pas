unit uSceneMng;

interface

uses
  classes, sysutils, types, uCommonTypes, ubaseobj, uBaseObjMng, NativeXML,
  windows, uNodeObject, uLight, uBaseCamera,  uTestObjects, uObjectTypes,
  uSelectLoadedObjects, uMaterial, TextureGL, uObrFile, uGlEventTypes,
  uObject, uGroupObjects;

type
  cScene = class (cBaseObjMng)
  public
   render:tobject;
   // �������� ������ �����. ��� ������� ����� ��������� � ����.
   World:cNodeObject;
   // ������ ���������� �����
   lights:cLightList;
   // ������ � ������� �������� ������������ ���������� ������������ �����
   FileHeaderObjectInfo:cFileHeadObjInfoList;
  private
  protected
    procedure regObjClasses;override;
    procedure AddBaseObjInstance(obj:cbaseobj);override;
    //procedure CreateEvents;
  public
    procedure SaveScene(FileName:String);
    // ��������� ObrFile �������
    function LoadFile_Obr(FileName:String):boolean;
    // ��������� �� ObrFile-� ���������� ������� (����� �������������� �������������)
    Procedure LoadObrSelObj(FileName:String);
    constructor create;override;
    destructor destroy;override;
   // �������� �������� ������
    function getactivecamera:cbasecamera;
    // �������� �����
    function CopyObject(obj:cnodeobject):cnodeobject;
  end;

implementation
uses
  uRender, uUI;

function cscene.CopyObject(obj:cnodeobject):cnodeobject;
var newObj:cNodeObject;
  procedure addchild(obj:cnodeobject);
  var i:integer;
  begin
    add(obj);
    for I := 0 to obj.ChildCount - 1 do
    begin
      addchild(cnodeobject(obj.getChild(i)));
    end;
  end;
begin
  if obj.group then
    newobj:=copygroup(obj)
  else
    newobj:=obj.getCopy;
  Addchild(newobj);
  result:=newobj;
  events.CallAllEvents(E_GlOnObjCopy);
end;

procedure cScene.SaveScene(FileName:String);
var
  F:file;//�������� ����
  obj:cNodeObject;
  i:integer;
  info:cFileHeadObjInfo;
begin
 if filename<>'' then
 begin
   AssignFile(F,FileName);
   begin
     ReWrite(F,1);//������ �������� - ����� ����� �������� ������.
     writeHeader(FileHeaderObjectInfo,f,world);
     for I := 0 to FileHeaderObjectInfo.Count - 1 do
     begin
       info:=cFileHeadObjInfo(FileHeaderObjectInfo.objects[i]);
       obj:=cNodeObject(getobj(info.objname));
       writeobject(FileHeaderObjectInfo,obj,f);
     end;
   end;
   CloseFile(f);
 end;
end;

procedure cScene.AddBaseObjInstance(obj:cbaseobj);
begin
  if (obj is cBaseObj)
  then
  begin
    inherited AddBaseObjInstance(obj);
    if obj.parent=nil then
    begin
      if obj<>world then
        obj.parent:=world;
    end;
  end;
end;

procedure cScene.regObjClasses;
begin
  inherited;
  regclass(clight);
  regclass(cBaseCamera);
end;

constructor cScene.create;
begin
  inherited;
  // ������� �������� ������ ����� � �������� ��������� ��� ��������� �������
  // ������� ������ ������� �����
  world:=cnodeobject.create;
  world.name:='World';
  Add(world);
  // ������� �������� ������������
  lights:=clightlist.create(self);
  lights.destroydata:=false;
  FileHeaderObjectInfo:=cFileHeadObjInfoList.Create;
end;

destructor cScene.destroy;
begin
  world.destroy;
  world:=nil;
  lights.destroy;
  FileHeaderObjectInfo.destroy;
  inherited;
end;

function cScene.LoadFile_Obr(FileName:string):boolean;
var
  F:file;//�������� ����
  obj:cNodeObject;
  texturedir:string;
  bRead:boolean;
begin
  result:=LoadObrFile(filename,cui(crender(render).ui).ConfigFile,self);
end;

Procedure cScene.LoadObrSelObj(FileName:String);
var
  F:file;//�������� ����
  obj:cNodeObject;
  i:integer;
  info:cFileHeadObjInfo;
begin
 AssignFile(F,FileName);
 if FileExists(FileName) then
 begin
   Reset(F,1);//������ �������� - ����� ����� �������� ������
   readHeader(FileHeaderObjectInfo,f);
   InfoForm.showmodal(FileHeaderObjectInfo);
   for I := 0 to FileHeaderObjectInfo.count - 1 do
   Begin
     info:=cFileHeadObjInfo(FileHeaderObjectInfo.Objects[i]);
     if info.load then
     begin
       seek(f,info.DataPosInFile);
       obj:=readObj(f,self,cBaseObjList(objects),crender(render).m_MatMng,cui(crender(render).ui).ConfigFile);
       add(obj);
     end;
   end;
 end;
 Events.CallAllEvents(E_glLoadScene);
 CloseFile(f);
end;

function cScene.GetActiveCamera:cBaseCamera;
var i:integer;
    obj:cNodeObject;
begin
  result:=nil;
  if objects.count<>0 then
  begin
    for I := 0 to objects.count - 1 do
    begin
      obj:=cnodeobject(GetObj(i));
      if obj.objtype=constcamera then
      begin
        if cBaseCamera(obj).active then
        begin
          result:=cBaseCamera(obj);
          exit;
        end;
      end;
    end;
  end;
end;



end.
