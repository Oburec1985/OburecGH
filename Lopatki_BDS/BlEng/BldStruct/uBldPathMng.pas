unit uBldPathMng;

interface
 uses inifiles, forms, sysutils, classes, dialogs, uPathMng;

 type
 // класс для загрузки путей к ресурсам
  cBldPathMng = class(cPathMng)
  public
  protected
    procedure addDefaultPathLists;override;
  public
    function getRepList:tstringlist;
    function getCfgList:tstringlist;    
    function findRepPathFile(name:string):string;
    function findHelpPathFile(name:string):string;    
    function findCfgPathFile(name:string):string;
  end;

const
  CfgSection = 'CfgPath';
  RepSection = 'RepPath';
  HelpSection = 'HelpPath';
  
implementation

procedure cBldPathMng.addDefaultPathLists;
begin
  inherited;
  AddPathList(CfgSection);
  AddPathList(RepSection);
  AddPathList(HelpSection);
end;

function cBldPathMng.getRepList:tstringlist;
begin
  result:=getlist(RepSection);
end;

function cBldPathMng.getCfgList:tstringlist;
begin
  result:=getlist(CfgSection);
end;

function cBldPathMng.findCfgPathFile(name:string):string;
begin
  result:=GetFile(name, CfgSection);
end;

function cBldPathMng.findRepPathFile(name:string):string;
begin
  result:=GetFile(name, RepSection);
end;

function cBldPathMng.findHelpPathFile(name:string):string;
begin
  result:=GetFile(name, HelpSection);
end;

end.
