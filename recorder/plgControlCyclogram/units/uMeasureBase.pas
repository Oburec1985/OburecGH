unit uMeasureBase;

interface
uses
  uDBObject, ubaseobj, pathutils, uCommonMath, sysutils;

type
  // ������� ����� ��� �������� ���������� � ������ �������� � xml �����
  cXmlFolder = class(cDbFolder)

  end;
  �BaseMeaFolder = class(cDbFolder)

  end;
  // ������������ ������
  cObjFolder = class(cXmlFolder)

  end;
  // ���������
  cTestFolder = class(cXmlFolder)

  end;
  // ������� �������� �����������
  cRegistrFolder = class(cXmlFolder)

  end;

  cMBase = class(cDB)
  protected
  public
    // ����� ������� �����
  protected
    // ���������� � ������������ cDB ������
    function createBaseFolder:cDBFolder;override;
  public
  end;

  var
    g_MBase:cMBase;

implementation

{ cMeaBase }
function cMBase.createBaseFolder: cDBFolder;
begin
  result:=�BaseMeaFolder.create;
end;

end.
