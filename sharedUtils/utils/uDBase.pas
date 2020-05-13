unit uDBase;

interface
uses
  classes, IBDatabase, IBCustomDataSet, IBQuery, sysutils, dialogs;

type
  TDataType = (vaInt, vaString, vaDouble, vaDateTime);

  FBCol = record
    m_name:string;
    m_type:tDataType;
  end;

  cDB =class
  private
    // перечень испытываемых объектов
    PropertyList: tstringlist;
    // работа с бд
    datasetObjects, datasetTests, dataSetObjProp, DatataSetTestProp:TIBDataSet;
    database:tibdatabase;
    query:tibQuery;
    Transaction:tibtransaction;
  public
    constructor create(path:string);
    procedure CreateTable(tableName:string;columns:array of fbcol);
    // создаем базу данныз программно
    procedure CreateDataBase(path:string;user:string;psw:string);
  end;

implementation

procedure cDB.CreateDataBase(path:string;user:string;psw:string);
begin
  database:=tibdatabase.Create(nil);
  // Создаёт базу данных с указанным именем (DatabaseName),
  // диалектом (SqlDialect) и заданными параметрами (Params).
  database.DatabaseName:='localhost:'+path;
  database.Params.Add('user_name='+user);
  database.Params.Add('password='+psw);
  database.Params.Add('lc_ctype=WIN1251');
  database.sqlDialect:=3;
  database.CreateDatabase;
end;

procedure cDB.CreateTable(tableName:string;columns:array of fbcol);
var
  I: Integer;
  sType, colStr:string;
begin
  // добавляем генератор
  query.sql.Text:='CREATE GENERATOR GEN_'+tablename+'_ID';
  query.ExecSQL;
  query.sql.Text:='create table '+tableName+' (';
  query.sql.Text:=query.sql.Text+tableName+'_ID Integer NOT NULL PRIMARY KEY';
  for I := 0 to length(columns) - 1 do
  begin
    case columns[i].m_type of
      vaInt:
      begin
        sType:='Integer default 0';
      end;
      vaString:
      begin
        sType:='VARCHAR (500) character set WIN1251';
      end;
      vaDouble:
      begin
        sType:='DOUBLE PRECISION default 0';
      end;
      vaDateTime:
      begin
        sType:='TIMESTAMP';
      end;
    end;
    colStr:=columns[i].m_name+' '+ sType;
    if i<>length(columns) - 1 then
      colstr:=colstr+', ';
  end;
  query.sql.Text:=query.sql.Text+columns[i].m_name+' '+colstr+')';
  query.ExecSQL;

  query.sql.Text:='SET TERM ^ ;';
  query.ExecSQL;
  // вставляем триггер
  //CREATE OR ALTER TRIGGER DATA_BI FOR DATA
  //ACTIVE BEFORE INSERT POSITION 0
  //as
  //begin
  //  if (new.data_id is null) then
  //    new.data_id = gen_id(gen_data_id,1);
  //end
  //^
  query.sql.Text:='CREATE OR ALTER TRIGGER '+ tablename+'_BI FOR'+ tablename+
                  ' ACTIVE BEFORE INSERT POSITION 0 as begin if (new.data_id is null) then new.data_id = gen_id('
                  +'GEN_'+tablename+'_ID ,1); end  ^';
  query.ExecSQL;
  query.sql.Text:='SET TERM ; ^';
  query.ExecSQL;
end;

constructor cDB.create(path:string);
begin
  Transaction:=TIBTransaction.Create(nil);;
  database:=tibDataBase.Create(nil);

  query:=tibquery.Create(nil);
  query.Database:=database;
  query.transaction:=transaction;

  if not fileexists(path) then
  begin
    showmessage('file not found '+path);
    exit;
  end;
  database.DatabaseName:='localhost:'+path;
  database.loginprompt:=false;
  database.DefaultTransaction:=Transaction;
  database.Params.Clear;
  database.Params.Add('user_name=sysdba');
  database.Params.Add('password=masterkey');
  database.Params.Add('lc_ctype=WIN1251');

  Transaction.DefaultDatabase:=database;

  datasetObjects:=TIBDataSet.Create(nil);
  datasetObjects.Database:=database;
  datasetObjects.Transaction:=Transaction;
  datasetObjects.InsertSQL.Text := 'Insert into OBJECTS (OBJECT_ID,NAME,DSC) Values (:OBJECT_ID,:NAME,:DSC)';
  datasetObjects.SelectSQL.Text := 'select * from OBJECTS';
  datasetObjects.RefreshSQL.Text := 'select * from OBJECTS where OBJECT_ID = :OBJECT_ID';
  datasetObjects.DeleteSQL.Text := 'delete from OBJECTS where OBJECT_ID = :OBJECT_ID';
  datasetObjects.GeneratorField.Generator:='GEN_OBJECTS_ID';
  datasetObjects.GeneratorField.Field:='OBJECT_ID';
  datasetObjects.Open;

  datasetTests:=TIBDataSet.Create(nil);
  datasetTests.Database:=database;
  datasetTests.Transaction:=Transaction;
  datasetTests.InsertSQL.Text := 'Insert into TESTS (TEST_ID,NAME,DSC) Values (:TEST_ID,:NAME,:DSC)';
  datasetTests.SelectSQL.Text := 'select * from TESTS';
  datasetTests.RefreshSQL.Text := 'select * from TESTS where TEST_ID = :TEST_ID';
  datasetTests.DeleteSQL.Text := 'delete from OBJECTS where TEST_ID = :TEST_ID';
  datasetTests.GeneratorField.Generator:='GEN_TEST_ID';
  datasetTests.GeneratorField.Field:='TEST_ID';
  datasetTests.Open;

  dataSetObjProp:=TIBDataSet.Create(nil);
  dataSetObjProp.Database:=database;
  dataSetObjProp.Transaction:=Transaction;
  dataSetObjProp.InsertSQL.Text := 'Insert into OBJECTS (OBJECT_ID,NAME,DSC) Values (:OBJECT_ID,:NAME,:DSC)';
  dataSetObjProp.SelectSQL.Text := 'select * from OBJECTS';
  dataSetObjProp.RefreshSQL.Text := 'select * from OBJECTS where OBJECT_ID = :OBJECT_ID';
  dataSetObjProp.DeleteSQL.Text := 'delete from OBJECTS where OBJECT_ID = :OBJECT_ID';
  dataSetObjProp.GeneratorField.Generator:='GEN_OBJECTS_ID';
  dataSetObjProp.GeneratorField.Field:='OBJECT_ID';
  dataSetObjProp.Open;

  dataSetObjProp:=TIBDataSet.Create(nil);
  dataSetObjProp.Database:=database;
  dataSetObjProp.Transaction:=Transaction;
  dataSetObjProp.InsertSQL.Text := 'Insert into PROPERTIES (OBJECT_ID,NAME,DSC) Values (:OBJECT_ID,:NAME,:DSC)';
  dataSetObjProp.SelectSQL.Text := 'select * from PROPERTIES';
  dataSetObjProp.RefreshSQL.Text := 'select * from PROPERTIES where OBJECT_ID = :PROPERTY_ID';
  dataSetObjProp.DeleteSQL.Text := 'delete from PROPERTIES where PROPERTY_ID = :PROPERTY_ID';
  dataSetObjProp.GeneratorField.Generator:='GEN_PROPERTY_ID';
  dataSetObjProp.GeneratorField.Field:='PROPERTY_ID';
  dataSetObjProp.Open;
end;

end.
