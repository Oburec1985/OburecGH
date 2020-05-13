unit uStageList;

interface
uses
  Windows, SysUtils, Classes, uBaseObjList, uStage;
type

  cStageList = class(cObjectList)
  public
    function getObjByName(name:string):cStage;
  end;

implementation

function cStageList.getObjByName(name:string):cStage;
begin
  result:= cStage(inherited getobjbyname(name));
end;


end.
