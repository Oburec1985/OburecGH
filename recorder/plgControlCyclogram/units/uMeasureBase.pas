unit uMeasureBase;

interface
uses
  uDBObject, ubaseobj, pathutils, uCommonMath, sysutils;

type
  // базовый класс для хранения информации о данных каталога в xml файле
  cXmlFolder = class(cDbFolder)

  end;
  сBaseMeaFolder = class(cDbFolder)

  end;
  // испытываемый объект
  cObjFolder = class(cXmlFolder)

  end;
  // испытания
  cTestFolder = class(cXmlFolder)

  end;
  // каталог содержит регистрации
  cRegistrFolder = class(cXmlFolder)

  end;

  cMBase = class(cDB)
  protected
  public
    // имена базовых папок
  protected
    // вызывается в конструкторе cDB класса
    function createBaseFolder:cDBFolder;override;
  public
  end;

  var
    g_MBase:cMBase;

implementation

{ cMeaBase }
function cMBase.createBaseFolder: cDBFolder;
begin
  result:=сBaseMeaFolder.create;
end;

end.
