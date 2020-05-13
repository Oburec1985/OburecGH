unit uMDB;

interface
uses
  uBaseObj, uBaseObjMng;

type

  // ���� ������ ��������� WP
  cMDB = class(cBaseObjMng)
    // ������ �������� ���� ������
    ObjList:cBaseObj;
  public
    constructor Create;override;
  end;
  // ��������� (������ �����������)
  cTest = class(cBaseObj)
  public
    constructor Create;override;
  end;
  // ����������� (������ ��������)
  cRegistration = class(cBaseObj)
  public
    constructor Create;override;
  end;

const
  c_MDB_Test_image = 0;
  c_MDB_Obj_image = 1;
  c_MDB_Reg_image = 2;

implementation

constructor cMDB.Create;
begin
  inherited;
  ObjList:=cBaseObj.create;
end;

constructor cTest.Create;
begin
  inherited;
  imageindex:=c_MDB_Test_image;
end;

constructor cRegistration.Create;
begin
  inherited;
  imageindex:=c_MDB_Reg_image;
end;


end.
