unit uConfigFile3d;

interface
 uses inifiles, forms, sysutils, classes, dialogs, uPathMng;

 type
 // класс для загрузки путей к ресурсам
  cCfgFile = class(cPathMng)
  public
    UIConfigname:string;
  protected
    procedure addDefaultPathLists;override;
  public
    function findMeshFile(name:string):string;
    function findShaderFile(name:string):string;
    function findCfgPathFile(name:string):string;
    function findTextureFile(name:string):string;
    procedure load;override;
    procedure Save;override;
  end;

const
  CfgSection = 'CfgPath';
  objectsSection = 'Objects';
  ShaderSection = 'Shaders';
  TextureSection = 'TexturePath';
  UISection = 'UI';

implementation

procedure cCfgFile.load;
begin
  inherited;
  UIConfigname:=ifile.ReadString(uisection,UISection+'name','UICfg.ini');
  UIConfigname:=findCfgPathFile(UIConfigname);
end;

procedure cCfgFile.save;
begin
  inherited;
end;

procedure cCfgFile.addDefaultPathLists;
begin
  inherited;
  AddPathList(CfgSection);
  AddPathList(objectsSection);
  AddPathList(ShaderSection);
  AddPathList(TextureSection);
end;

function cCfgFile.findTextureFile(name:string):string;
begin
  result:=GetFile(name, TextureSection);
end;

function cCfgFile.findMeshFile(name:string):string;
begin
  result:=GetFile(name, objectsSection);
end;

function cCfgFile.findShaderFile(name:string):string;
begin
  if FileExists(filename) then
  begin
    result:=GetFile(name+'.*', ShaderSection);
  end
  else
  begin
    result:=FindFile(name+'.*', startdir, deep+2);
  end;
end;

function cCfgFile.findCfgPathFile(name:string):string;
begin
  result:=GetFile(name, CfgSection);
end;

end.
