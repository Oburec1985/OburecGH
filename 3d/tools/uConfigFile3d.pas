unit uConfigFile3d;

interface
 uses inifiles, forms, sysutils, classes, dialogs, uPathMng;

 type
 // класс для загрузки путей к ресурсам
  cCfgFile = class(cPathMng)
  private
    fref:integer;
  public
    UIConfigname:string;
  protected
    procedure addDefaultPathLists;override;
  public
    procedure addref;
    procedure release;
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

procedure cCfgFile.release;
begin
  dec(fref);
  if fref=0 then
    destroy;
end;

procedure cCfgFile.addref;
begin
  inc(fref);
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
  // Сначала список путей Shaders из resources.ini (штатная раскладка плагина),
  // затем поиск рядом с приложением. Берём только .vert/.frag: прежняя маска
  // по всем расширениям находила и посторонние файлы (например, копии из
  // shaders\bu), поэтому на разных машинах мог загрузиться разный шейдер.
  result:=GetFile(name+'.vert', ShaderSection);
  if (result='') or not FileExists(result) then
    result:=GetFile(name+'.frag', ShaderSection);
  if (result<>'') and not FileExists(result) then
    result:='';
  if result='' then
  begin
    result:=FindFile(name+'.vert', startdir, deep+2);
    if (result='') or not FileExists(result) then
      result:=FindFile(name+'.frag', startdir, deep+2);
    if (result<>'') and not FileExists(result) then
      result:='';
  end;
end;


function cCfgFile.findCfgPathFile(name:string):string;
begin
  result:=GetFile(name, CfgSection);
end;

end.
