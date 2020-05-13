
{******************************************}
{                                          }
{             FastReport v4.0              }
{         ADO enduser components           }
{                                          }
{         Copyright (c) 1998-2008          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxADOComponents;

interface

{$I frx.inc}

uses
  Windows, Classes, SysUtils, frxClass, frxCustomDB, DB, ADODB, ADOInt
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF}
{$IFDEF FR_COM}
, VclCOM, ComObj, ComServ, frxDBSet
, FastReport_TLB
{$ENDIF}
;

{$IFDEF FR_COM}
const
  CLASS_TfrxADODatabase: TGUID = '{4B15360C-223C-4F3E-A306-8E5C19E2EA98}';
  CLASS_TfrxADOTable: TGUID = '{75AE7A73-E752-4DE6-A326-9C18C8D753F4}';
  CLASS_TfrxADOQuery: TGUID = '{6B1A7A66-07F6-4B4C-A454-BAA59FC951FA}';
{$ENDIF}

type
  TfrxADOComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: TADOConnection;
    FOldComponents: TfrxADOComponents;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetDefaultDatabase(Value: TADOConnection);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: TADOConnection read FDefaultDatabase write SetDefaultDatabase;
  end;

{$IFDEF FR_COM}
  TfrxADODatabase = class(TfrxCustomDatabase, IfrxADODatabase)
{$ELSE}
  TfrxADODatabase = class(TfrxCustomDatabase)
{$ENDIF}
  private
    FDatabase: TADOConnection;
  protected
    procedure SetConnected(Value: Boolean); override;
    procedure SetDatabaseName(const Value: String); override;
    procedure SetLoginPrompt(Value: Boolean); override;
    function GetConnected: Boolean; override;
    function GetDatabaseName: String; override;
    function GetLoginPrompt: Boolean; override;
    procedure ADOBeforeConnect(Sende: TObject);
    procedure ADOAfterDisconnect(Sende: TObject);
{$IFDEF FR_COM}
    function COM_Object: TfrxADODatabase; // Internal helper function
    function Get_ConnectionString: WideString; safecall;
    procedure Set_ConnectionString(const Value: WideString); safecall;
    function Get_LoginPrompt: WordBool; safecall;
    procedure Set_LoginPrompt(Value: WordBool); safecall;
    function Get_Connected: WordBool; safecall;
    procedure Set_Connected(Value: WordBool); safecall;
    function Get_ConnectionTimeout: Integer; safecall;
    procedure Set_ConnectionTimeout(Value: Integer); safecall;
    function Get_CommandTimeout: Integer; safecall;
    procedure Set_CommandTimeout(Value: Integer); safecall;

{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    procedure SetLogin(const Login, Password: String); override;
    function ToString: WideString; override;
    procedure FromString(const Connection: WideString); override;
    property Database: TADOConnection read FDatabase;
  published
    property DatabaseName;
    property LoginPrompt;
    property Connected;
  end;

{$IFDEF FR_COM}
  TfrxADOTable = class(TfrxCustomTable, IfrxADOTable)
{$ELSE}
  TfrxADOTable = class(TfrxCustomTable)
{$ENDIF}
  private
    FDatabase: TfrxADODatabase;
    FTable: TADOTable;
    procedure SetDatabase(Value: TfrxADODatabase);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetMasterFields(const Value: String); override;
    procedure SetIndexFieldNames(const Value: String); override;
    procedure SetIndexName(const Value: String); override;
    procedure SetTableName(const Value: String); override;
    function GetIndexFieldNames: String; override;
    function GetIndexName: String; override;
    function GetTableName: String; override;
{$IFDEF FR_COM}
    function COM_Object: TfrxADOTable; // Internal helper function
    function Get_DataBase(out Value: IfrxADODatabase): HResult; stdcall;
    function Set_DataBase(const Value: IfrxADODatabase): HResult; stdcall;
    function Get_IndexName(out Value: WideString): HResult; stdcall;
    function Set_IndexName(const Value: WideString): HResult; stdcall;
    function Get_TableName(out Value: WideString): HResult; stdcall;
    function Set_TableName(const Value: WideString): HResult; stdcall;
    function Get_Name(out Value: WideString): HResult; stdcall;
    function Set_Name(const Value: WideString): HResult; stdcall;
    function Set_Master(const Value: IfrxDataSet): HResult; stdcall;
    function Get_MasterFileds(out Value: WideString): HResult; stdcall;
    function Set_MasterFileds(const Value: WideString): HResult; stdcall;
    function Get_DataBaseEx(out Value: IfrxADODatabase): HResult; stdcall;
    function Set_DataBaseEx(const Value: IfrxADODatabase): HResult; stdcall;
    function _Set_DataBaseEx(var Value: IfrxADODatabase): HResult; stdcall;
    function Get_FieldsCount(out Value: Integer): HResult; stdcall;
    function FieldName(Index: Integer; out Name: WideString): HResult; stdcall;
    function Get_Active(out Value: WordBool): HResult; stdcall;
    function Set_Active(Value: WordBool): HResult; stdcall;
    function FieldType(Index: Integer; out Value: frxFieldType): HResult; stdcall;
    function DisplayWidth(Index: Integer; out Value: Integer): HResult; stdcall;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    property Table: TADOTable read FTable;
  published
    property Database: TfrxADODatabase read FDatabase write SetDatabase;
  end;

{$IFDEF FR_COM}
  TfrxADOQuery = class(TfrxCustomQuery, IfrxADOQuery)
{$ELSE}
  TfrxADOQuery = class(TfrxCustomQuery)
{$ENDIF}
  private
    FDatabase: TfrxADODatabase;
    FQuery: TADOQuery;
    FStrings: TStrings;
    FLock: Boolean;
    procedure SetDatabase(Value: TfrxADODatabase);
    function GetCommandTimeout: Integer;
    procedure SetCommandTimeout(const Value: Integer);
{$IFDEF Delphi7}
    function GetLockType: TADOLockType;
    procedure SetLockType(const Value: TADOLockType);
{$ENDIF}
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure OnChangeSQL(Sender: TObject); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetSQL(Value: TStrings); override;
    function GetSQL: TStrings; override;
{$IFDEF FR_COM}
    function Get_Database: IfrxADODatabase; safecall;
    procedure Set_Database(const Value: IfrxADODatabase); safecall;
    function Get_Query: WideString; safecall;
    procedure Set_Query(const Value: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function ParamByName(const Name: WideString): IfrxParamItem; safecall;
    function Get_CommandTimeout: Integer; safecall;
    procedure Set_CommandTimeout(Value: Integer); safecall;
    function Get_Filter: WideString; safecall;
    procedure Set_Filter(const Value: WideString); safecall;
    procedure Set_Master(const Param1: IfrxDataSet); safecall;
    function AddParameter(const Name: WideString): IfrxParamItem; safecall;
    function Get_DataBaseEx: IfrxADODatabase; safecall;
    procedure Set_DataBaseEx(const Value: IfrxADODatabase); safecall;
    procedure _Set_DataBaseEx(var Value: IfrxADODatabase); safecall;
    function Get_FieldAliases: WideString; safecall;
    procedure Set_FieldAliases(const Value: WideString); safecall;

    function COM_Object: TfrxADOQuery; // COM helper
{
    function Get_DataBase(out Value: IfrxADODatabase): HResult; stdcall;
    function Set_DataBase(const Val: IfrxADODatabase): HResult; stdcall;
    function Get_Query(out Value: WideString): HResult; stdcall;
    function Set_Query(const Value: WideString): HResult; stdcall;
    function Get_Name(out Value: WideString): HResult; stdcall;
    function Set_Name(const Value: WideString): HResult; stdcall;
    function ParamByName(const Name: WideString; out Param: IfrxParamItem): HResult; stdcall;
    function Get_CommandTimeout(out Value: Integer): HResult; stdcall;
    function Set_CommandTimeout(Value: Integer): HResult; stdcall;
    function Get_Filter(out Value: WideString): HResult; stdcall;
    function Set_Filter(const Val: WideString): HResult; stdcall;
    function Set_Master(const Val: IfrxDataSet): HResult; stdcall;
    function AddParameter(const Name: WideString; out Param: IfrxParamItem): HResult; stdcall;
    function Get_DataBaseEx(out Value: IfrxADODatabase): HResult; stdcall;
    function Set_DataBaseEx(const Value: IfrxADODatabase): HResult; stdcall;
    function _Set_DataBaseEx(var Value: IfrxADODatabase): HResult; stdcall;
    function Get_FieldAliases(out Value: WideString): HResult; stdcall;
    function Set_FieldAliases(const Value: WideString): HResult; stdcall;
}
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    procedure UpdateParams; override;
{$IFDEF QBUILDER}
    function QBEngine: TfqbEngine; override;
{$ENDIF}
    property Query: TADOQuery read FQuery;
  published
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
    property Database: TfrxADODatabase read FDatabase write SetDatabase;
{$IFDEF Delphi7}
    property LockType: TADOLockType read GetLockType write SetLockType;
{$ENDIF}
  end;

{$IFDEF QBUILDER}
  TfrxEngineADO = class(TfqbEngine)
  private
    FQuery: TADOQuery;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReadTableList(ATableList: TStrings); override;
    procedure ReadFieldList(const ATableName: string; var AFieldList: TfqbFieldList); override;
    function ResultDataSet: TDataSet; override;
    procedure SetSQL(const Value: string); override;
  end;
{$ENDIF}

procedure frxParamsToTParameters(Query: TfrxCustomQuery; Params: TParameters);
procedure frxADOGetTableNames(conADO: TADOConnection; List: TStrings; SystemTables: Boolean);

var
  ADOComponents: TfrxADOComponents;

implementation

uses
  frxADORTTI,
{$IFNDEF NO_EDITORS}
  frxADOEditor,
{$ENDIF}
  frxDsgnIntf, frxRes;

type
  THackQuery = class(TADOQuery);


{ frxParamsToTParameters }

procedure frxParamsToTParameters(Query: TfrxCustomQuery; Params: TParameters);
var
  i: Integer;
  Item: TfrxParamItem;
begin
  for i := 0 to Params.Count - 1 do
    if Query.Params.IndexOf(Params[i].Name) <> -1 then
    begin
      Item := Query.Params[Query.Params.IndexOf(Params[i].Name)];
      Params[i].DataType := Item.DataType;
      Params[i].Attributes := [paNullable];
      if Trim(Item.Expression) <> '' then
        if not (Query.IsLoading or Query.IsDesigning) then
        begin
          Query.Report.CurObject := Query.Name;
          Item.Value := Query.Report.Calc(Item.Expression);
        end;
      Params[i].Value := Item.Value;
    end;
end;

procedure frxADOGetTableNames(conADO: TADOConnection; List: TStrings; SystemTables: Boolean);
var
  tbl: TADODataSet;
  s: string;
begin
  tbl := TADODataSet.Create(nil);
  List.Clear;
  try
    conADO.OpenSchema(siTables, EmptyParam, EmptyParam, tbl);
    tbl.First;
    while not tbl.Eof do
    begin
      s := Trim(tbl.FieldByName('TABLE_SCHEMA').AsString);
      if s <> '' then
        List.Add(s + '.' + tbl.FieldByName('TABLE_NAME').AsString)
      else
        List.Add(tbl.FieldByName('TABLE_NAME').AsString);
      tbl.Next;
    end;
  finally
    tbl.Free;
  end;
end;

{ TfrxDBComponents }

constructor TfrxADOComponents.Create(AOwner: TComponent);
begin
  inherited;
  FOldComponents := ADOComponents;
  FDefaultDatabase := nil;
  ADOComponents := Self;
end;

destructor TfrxADOComponents.Destroy;
begin
  if ADOComponents = Self then
    ADOComponents := FOldComponents;
  inherited;
end;

function TfrxADOComponents.GetDescription: String;
begin
  Result := 'ADO';
end;

procedure TfrxADOComponents.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FDefaultDatabase) and (Operation = opRemove) then
    FDefaultDatabase := nil;
end;


{ TfrxADODatabase }

constructor TfrxADODatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TADOConnection.Create(nil);
  FDatabase.BeforeConnect := ADOBeforeConnect;
  FDatabase.AfterDisconnect := ADOAfterDisconnect;
  Component := FDatabase;
end;

class function TfrxADODatabase.GetDescription: String;
begin
  Result := frxResources.Get('obADODB');
end;

function TfrxADODatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxADODatabase.GetDatabaseName: String;
begin
  Result := FDatabase.ConnectionString;
end;

function TfrxADODatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TfrxADODatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
end;

procedure TfrxADODatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.ConnectionString := Value;
end;

procedure TfrxADODatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxADODatabase.SetLogin(const Login, Password: String);
var
  i, j: Integer;
  s: String;
begin
  s := DatabaseName;
  i := Pos('USER ID=', AnsiUppercase(s));
  if i <> 0 then
  begin
    for j := i to Length(s) do
      if s[j] = ';' then
        break;
    Delete(s, i, j - i);
    Insert('User ID=' + Login, s, i);
  end
  else
    s := s + ';User ID=' + Login;

  i := Pos('PASSWORD=', AnsiUppercase(s));
  if i <> 0 then
  begin
    for j := i to Length(s) do
      if s[j] = ';' then
        break;
    Delete(s, i, j - i);
    Insert('Password=' + Password, s, i);
  end
  else
    s := s + ';Password=' + Password;

  DatabaseName := s;
end;
{$IFDEF FR_COM}
// helper function that supports IUnknown and IDispatchable interfaces
function TfrxADODatabase.COM_Object: TfrxADODatabase;
var
  idsp:   IInterfaceComponentReference;
begin
  if not Assigned( VCLComObject ) then Result := Self
  else try
    idsp := IVCLComObject(VCLComObject) as IInterfaceComponentReference;
    Result := TfrxADODatabase( idsp.GetComponent );
  except
    Result := Self;
  end;
end;

function TfrxADODatabase.Get_ConnectionString: WideString; safecall;
begin
  Result := PChar(COM_Object.DatabaseName);
end;

procedure TfrxADODatabase.Set_ConnectionString(const Value: WideString); safecall;
begin
  COM_Object.DatabaseName := Value;
end;

function TfrxADODatabase.Get_LoginPrompt: WordBool; safecall;
begin
  Result := COM_Object.LoginPrompt;
end;

procedure TfrxADODatabase.Set_LoginPrompt(Value: WordBool); safecall;
begin
  COM_Object.LoginPrompt := Value;
end;

function TfrxADODatabase.Get_Connected: WordBool; safecall;
begin
  Result := COM_Object.Connected;
end;

procedure TfrxADODatabase.Set_Connected(Value: WordBool); safecall;
begin
  COM_Object.Connected := Value;
end;

function TfrxADODatabase.Get_ConnectionTimeout: Integer; safecall;
begin
  Result := COM_Object.FDatabase.ConnectionTimeout;
end;

procedure TfrxADODatabase.Set_ConnectionTimeout(Value: Integer); safecall;
begin
  COM_Object.FDatabase.ConnectionTimeout := Value;
end;

function TfrxADODatabase.Get_CommandTimeout: Integer; safecall;
begin
  Result := COM_Object.FDatabase.CommandTimeout;
end;

procedure TfrxADODatabase.Set_CommandTimeout(Value: Integer); safecall;
begin
  COM_Object.FDatabase.CommandTimeout := Value;
end;
{$ENDIF}

procedure TfrxADODatabase.FromString(const Connection: WideString);
begin
  FDatabase.ConnectionString := Connection;
end;

function TfrxADODatabase.ToString: WideString;
begin
  Result := FDatabase.ConnectionString;
end;

procedure TfrxADODatabase.ADOBeforeConnect(Sende: TObject);
var
 Param: Boolean;
begin
  Param := True;
  BeforeConnect(Param);
end;

procedure TfrxADODatabase.ADOAfterDisconnect(Sende: TObject);
begin
 AfterDisconnect;
end;

procedure TfrxADOComponents.SetDefaultDatabase(Value: TADOConnection);
begin
  if (Value <> nil) then
    Value.FreeNotification(Self);

  if FDefaultDatabase <> nil then
      FDefaultDatabase.RemoveFreeNotification(Self);

  FDefaultDatabase := Value;
end;

{ TfrxADOTable }

constructor TfrxADOTable.Create(AOwner: TComponent);
begin
  FTable := TADOTable.Create(nil);
  DataSet := FTable;
  SetDatabase(nil);
  inherited;
end;

constructor TfrxADOTable.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxADODatabase then
    begin
      SetDatabase(TfrxADODatabase(l[i]));
      break;
    end;
end;

class function TfrxADOTable.GetDescription: String;
begin
  Result := frxResources.Get('obADOTb');
end;

procedure TfrxADOTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxADOTable.SetDatabase(Value: TfrxADODatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FTable.Connection := Value.Database
  else if ADOComponents <> nil then
    FTable.Connection := ADOComponents.DefaultDatabase
  else
    FTable.Connection := nil;
  DBConnected := FTable.Connection <> nil;
end;

function TfrxADOTable.GetIndexFieldNames: String;
begin
  Result := FTable.IndexFieldNames;
end;

function TfrxADOTable.GetIndexName: String;
begin
  Result := FTable.IndexName;
end;

function TfrxADOTable.GetTableName: String;
begin
  Result := FTable.TableName;
end;

procedure TfrxADOTable.SetIndexFieldNames(const Value: String);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TfrxADOTable.SetIndexName(const Value: String);
begin
  FTable.IndexName := Value;
end;

procedure TfrxADOTable.SetTableName(const Value: String);
begin
  FTable.TableName := Value;
end;

procedure TfrxADOTable.SetMaster(const Value: TDataSource);
begin
  FTable.MasterSource := Value;
end;

procedure TfrxADOTable.SetMasterFields(const Value: String);
begin
  FTable.MasterFields := Value;
end;

procedure TfrxADOTable.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;

{$IFDEF FR_COM}
// helper function that supports IUnknown and IDispatchable interfaces
function TfrxADOTable.COM_Object: TfrxADOTable;
var
  idsp:   IInterfaceComponentReference;
begin
  if not Assigned( VCLComObject ) then Result := Self
  else try
    idsp := IVCLComObject(VCLComObject) as IInterfaceComponentReference;
    Result := TfrxADOTable( idsp.GetComponent );
  except
    Result := Self;
  end;
end;

function TfrxADOTable.Get_DataBase(out Value: IfrxADODatabase): HResult; stdcall;
begin
  Value := COM_Object.Database;
  Result := S_OK;
end;

function TfrxADOTable.Set_DataBase(const Value: IfrxADODatabase): HResult; stdcall;
var
  idsp :          IInterfaceComponentReference;
  WorkingObject:  TfrxADOTable;
begin
  WorkingObject := COM_Object;
  if Value <> nil then
  begin
    Result := Value.QueryInterface( IInterfaceComponentReference, idsp);
    if Result = S_OK then
      WorkingObject.Database := TfrxADODatabase( idsp.GetComponent );
  end
  else
  begin
    WorkingObject.Database := nil;
    Result := S_OK;
  end;
end;

function TfrxADOTable.Get_IndexName(out Value: WideString): HResult; stdcall;
begin
  Value := COM_Object.FTable.IndexName;
  Result := S_OK;
end;

function TfrxADOTable.Set_IndexName(const Value: WideString): HResult; stdcall;
begin
  COM_Object.FTable.IndexName := Value;
  Result := S_OK;
end;

function TfrxADOTable.Get_TableName( out Value : WideString): HResult; stdcall;
begin
  Value := COM_Object.FTable.TableName;
  Result := S_OK;
end;

function TfrxADOTable.Set_TableName(const Value: WideString): HResult; stdcall;
begin
  COM_Object.FTable.TableName := Value;
  Result := S_OK;
end;

function TfrxADOTable.Get_Name(out Value: WideString): HResult; stdcall;
begin
  Value := COM_Object.Name;
  Result := S_OK;
end;

function TfrxADOTable.Set_Name(const Value: WideString): HResult; stdcall;
begin
  COM_Object.Name := Value;
  Result := S_OK;
end;

function TfrxADOTable.Set_Master(const Value: IfrxDataSet): HResult; stdcall;
var
  idsp : IInterfaceComponentReference;
  WorkingObject:  TfrxADOTable;
begin
  try
    WorkingObject := COM_Object;
    if Value <> nil then
    begin
      Result := Value.QueryInterface( IInterfaceComponentReference, idsp);
      if Result = S_OK then
        WorkingObject.Master := TfrxDBDataSet( idsp.GetComponent );
    end
    else
    begin
      WorkingObject.Master := nil;
      Result := S_OK;
    end;
  except
    Result := E_INVALIDARG;
  end;
end;

function TfrxADOTable.Get_MasterFileds(out Value: WideString): HResult; stdcall;
begin
  Value := COM_Object.MasterFields;
  Result := S_OK;
end;

function TfrxADOTable.Set_MasterFileds(const Value: WideString): HResult; stdcall;
begin
  COM_Object.MasterFields := Value;
  Result := S_OK;
end;

function TfrxADOTable.Get_DataBaseEx(out Value: IfrxADODatabase): HResult; stdcall;
begin
  Value := COM_Object.Database;
  Result := S_OK;
end;

function TfrxADOTable.Set_DataBaseEx(const Value: IfrxADODatabase): HResult; stdcall;
begin
  Result := Set_DataBase(value);
end;

function TfrxADOTable._Set_DataBaseEx(var Value: IfrxADODatabase): HResult; stdcall;
begin
  Result := Set_DataBase(value);
end;

function TfrxADOTable.Get_FieldsCount(out Value: Integer): HResult; stdcall;
begin
  Value := COM_Object.FTable.FieldDefs.Count;
  Result := S_OK;
end;

function TfrxADOTable.FieldName(Index: Integer; out Name: WideString): HResult; stdcall;
begin
  Result := E_FAIL;
  if (Index < 0) or (Index > COM_Object.FTable.Fields.Count) then exit;
  Name := COM_Object.FTable.Fields.Fields[Index].FieldName;
  Result := S_OK;
end;

function TfrxADOTable.Get_Active(out Value: WordBool): HResult; stdcall;
begin
  Value := COM_Object.Active;
  Result := S_OK;
end;

function TfrxADOTable.Set_Active(Value: WordBool): HResult; stdcall;
begin
  COM_Object.Active := Value;
  Result := S_OK;
end;

function TfrxADOTable.FieldType(Index: Integer; out Value: frxFieldType): HResult; stdcall;
begin
  Value := frxFieldType(COM_Object.FTable.Fields.Fields[Index].DataType);
  Result := S_OK;
end;

function TfrxADOTable.DisplayWidth(Index: Integer; out Value: Integer): HResult; stdcall;
begin
  Value := COM_Object.FTable.Fields.Fields[Index].DisplayWidth;
  Result := S_OK;
end;
{$ENDIF}

{ TfrxADOQuery }

constructor TfrxADOQuery.Create(AOwner: TComponent);
begin
  FStrings := TStringList.Create;
  FQuery := TADOQuery.Create(nil);
{$IFDEF Delphi7}
  FQuery.LockType := ltReadOnly;
{$ENDIF}
  Dataset := FQuery;
  SetDatabase(nil);
  FLock := False;
  inherited;
end;

constructor TfrxADOQuery.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxADODatabase then
    begin
      SetDatabase(TfrxADODatabase(l[i]));
      break;
    end;
end;

destructor TfrxADOQuery.Destroy;
begin
  FStrings.Free;
  inherited;
end;

class function TfrxADOQuery.GetDescription: String;
begin
  Result := frxResources.Get('obADOQ');
end;

procedure TfrxADOQuery.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

function TfrxADOQuery.GetSQL: TStrings;
begin
  FLock := True;
  FStrings.Assign(FQuery.SQL);
  FLock := False;
  Result := FStrings;
end;

procedure TfrxADOQuery.SetSQL(Value: TStrings);
begin
  FQuery.SQL.Assign(Value);
  FStrings.Assign(FQuery.SQL);
end;

procedure TfrxADOQuery.SetDatabase(Value: TfrxADODatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FQuery.Connection := Value.Database
  else if ADOComponents <> nil then
    FQuery.Connection := ADOComponents.DefaultDatabase
  else
    FQuery.Connection := nil;
  DBConnected := FQuery.Connection <> nil;
end;

procedure TfrxADOQuery.SetMaster(const Value: TDataSource);
begin
  FQuery.DataSource := Value;
end;

function TfrxADOQuery.GetCommandTimeout: Integer;
begin
  Result := THackQuery(FQuery).CommandTimeout;
end;

procedure TfrxADOQuery.SetCommandTimeout(const Value: Integer);
begin
  THackQuery(FQuery).CommandTimeout := Value;
end;

procedure TfrxADOQuery.UpdateParams;
begin
  frxParamsToTParameters(Self, FQuery.Parameters);
end;

procedure TfrxADOQuery.OnChangeSQL(Sender: TObject);
var
  i, ind: Integer;
  Param: TfrxParamItem;
  QParam: TParameter;
begin
  if not FLock then
  begin
    { needed to update parameters }
    FQuery.SQL.Text := '';
    FQuery.SQL.Assign(FStrings);
    inherited;

    { fill datatype automatically, if possible }
    for i := 0 to FQuery.Parameters.Count - 1 do
    begin
      QParam := FQuery.Parameters[i];
      ind := Params.IndexOf(QParam.Name);
      if ind <> -1 then
      begin
        Param := Params[ind];
        if (Param.DataType = ftUnknown) and (QParam.DataType <> ftUnknown) then
          Param.DataType := QParam.DataType;
      end;
    end;
  end;
end;

procedure TfrxADOQuery.BeforeStartReport;
begin
  SetDatabase(FDatabase);
  { needed to update parameters }
  SQL.Text := SQL.Text;
end;

{$IFDEF QBUILDER}
function TfrxADOQuery.QBEngine: TfqbEngine;
begin
  Result := TfrxEngineADO.Create(nil);
  TfrxEngineADO(Result).FQuery.Connection := FQuery.Connection;
end;
{$ENDIF}

{$IFDEF Delphi7}
function TfrxADOQuery.GetLockType: TADOLockType;
begin
  Result := FQuery.LockType;
end;

procedure TfrxADOQuery.SetLockType(const Value: TADOLockType);
begin
  FQuery.LockType := Value;
end;
{$ENDIF}

{$IFDEF FR_COM}
// helper function that supports IUnknown and IDispatchable interfaces
function TfrxADOQuery.COM_Object: TfrxADOQuery;
var
  idsp:   IInterfaceComponentReference;
begin
  if not Assigned( VCLComObject ) then Result := Self
  else try
    idsp := IVCLComObject(VCLComObject) as IInterfaceComponentReference;
    Result := TfrxADOQuery( idsp.GetComponent );
  except
    Result := Self;
  end;
end;

function TfrxADOQuery.Get_Database: IfrxADODatabase; safecall;
begin
  Result := COM_Object.Database;
end;

procedure TfrxADOQuery.Set_Database(const Value: IfrxADODatabase); safecall;
//var
//  idsp : IInterfaceComponentReference;
begin
//  with COM_Object do
//    if Val <> nil then
//    begin
//      Result := Val.QueryInterface( IInterfaceComponentReference, idsp );
//      if Result = S_OK then Database := TfrxADODatabase( idsp.GetComponent );
//    end else begin
//      Database := nil;
//    end;
    Database := TfrxADODatabase( value );
end;

function TfrxADOQuery.Get_Query: WideString; safecall;
begin
  Result := COM_Object.SQL.GetText;
end;

procedure TfrxADOQuery.Set_Query(const Value: WideString); safecall;
begin
  COM_Object.SQL.Text := Value;
end;

function TfrxADOQuery.Get_Name: WideString; safecall;
begin
  Result := COM_Object.Name;
end;

procedure TfrxADOQuery.Set_Name(const Value: WideString); safecall;
begin
  COM_Object.Name := Value;
end;

function TfrxADOQuery.Get_CommandTimeout: Integer; safecall;
begin
  Result := COM_Object.CommandTimeout;
end;

procedure TfrxADOQuery.Set_CommandTimeout(Value: Integer); safecall;
begin
  COM_Object.CommandTimeout := Value;
end;

function TfrxADOQuery.ParamByName(const Name: WideString): IfrxParamItem; safecall;
var
  par: TfrxParamItem;
begin
    par := inherited ParamByName(Name);
    if par <>  nil then Result := par;
end;

function TfrxADOQuery.AddParameter(const Name: WideString): IfrxParamItem; safecall;
var
  par: TfrxParamItem;
begin
  par := Params.Add;
  par.Name := Name;
  Result := par;
end;

function TfrxADOQuery.Get_Filter: WideString; safecall;
begin
  Result := COM_Object.Query.Filter;
end;

procedure TfrxADOQuery.Set_Filter(const Value: WideString); safecall;
begin
  if Value <> '' then
  begin
    COM_Object.Query.Filtered := False;
    COM_Object.Query.Filter := Value;
    COM_Object.Query.Filtered := True;
  end
  else
    COM_Object.Query.Filtered := False;
end;

procedure TfrxADOQuery.Set_Master(const Param1: IfrxDataSet); safecall;
var
  idsp : IInterfaceComponentReference;
  Res: HResult;
begin
  with COM_Object do
    if Param1 <> nil then
    begin
      Res := Param1.QueryInterface( IInterfaceComponentReference, idsp);
      if Res = S_OK then
        Master := TfrxDBDataSet( idsp.GetComponent );
    end
    else
    begin
      Master := nil;
    end;
end;

function TfrxADOQuery.Get_DataBaseEx: IfrxADODatabase; safecall;
begin
  Result := COM_Object.Database;
end;

procedure TfrxADOQuery.Set_DataBaseEx(const Value: IfrxADODatabase); safecall;
begin
  Set_DataBase(value);
end;

procedure TfrxADOQuery._Set_DataBaseEx(var Value: IfrxADODatabase); safecall;
begin
  Set_DataBase(value);
end;

function TfrxADOQuery.Get_FieldAliases: WideString; safecall;
begin
  Result := FieldAliases.GetText;
end;

procedure TfrxADOQuery.Set_FieldAliases(const Value: WideString); safecall;
begin
  FieldAliases.SetText( PChar(Value));
end;
{$ENDIF}

{$IFDEF QBUILDER}
constructor TfrxEngineADO.Create(AOwner: TComponent);
begin
  inherited;
  FQuery := TADOQuery.Create(Self);
end;

destructor TfrxEngineADO.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TfrxEngineADO.ReadFieldList(const ATableName: string;
  var AFieldList: TfqbFieldList);
var
  TempTable: TADOTable;
  Fields: TFieldDefs;
  i: Integer;
  tmpField: TfqbField;
begin
  AFieldList.Clear;
  TempTable := TADOTable.Create(Self);
  TempTable.Connection := FQuery.Connection;
  TempTable.TableName := ATableName;
  Fields := TempTable.FieldDefs;
  try
    try
      TempTable.Active := True;
      tmpField:= TfqbField(AFieldList.Add);
      tmpField.FieldName := '*';
      for i := 0 to Fields.Count - 1 do
      begin
        tmpField := TfqbField(AFieldList.Add);
        tmpField.FieldName := Fields.Items[i].Name;
        tmpField.FieldType := Ord(Fields.Items[i].DataType)
      end;
    except
    end;
  finally
    TempTable.Free;
  end;
end;

procedure TfrxEngineADO.ReadTableList(ATableList: TStrings);
begin
  ATableList.Clear;
  frxADOGetTableNames(FQuery.Connection, ATableList, ShowSystemTables);
//  FQuery.Connection.GetTableNames(ATableList, ShowSystemTables);
end;

function TfrxEngineADO.ResultDataSet: TDataSet;
begin
  Result := FQuery;
end;

procedure TfrxEngineADO.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;
{$ENDIF}


initialization
  frxObjects.RegisterObject1(TfrxADODataBase, nil, '', {$IFDEF DB_CAT}'DATABASES'{$ELSE}''{$ENDIF}, 0, {$IFDEF FR_COM}37{$ELSE}51{$ENDIF});
  frxObjects.RegisterObject1(TfrxADOTable, nil, '', {$IFDEF DB_CAT}'TABLES'{$ELSE}''{$ENDIF}, 0, {$IFDEF FR_COM}38{$ELSE}52{$ENDIF});
  frxObjects.RegisterObject1(TfrxADOQuery, nil, '', {$IFDEF DB_CAT}'QUERIES'{$ELSE}''{$ENDIF}, 0, {$IFDEF FR_COM}39{$ELSE}53{$ENDIF});

{$IFDEF FR_COM}
try
  TComponentFactory.Create(ComServer, TfrxADODatabase, Class_TfrxADODatabase, ciMultiInstance, tmApartment);
  TComponentFactory.Create(ComServer, TfrxADOTable, CLASS_TfrxADOTable, ciMultiInstance, tmApartment);
  TComponentFactory.Create(ComServer, TfrxADOQuery, CLASS_TfrxADOQuery, ciMultiInstance, tmApartment);
except
end;
{$ENDIF}

finalization
  frxObjects.UnRegister(TfrxADODataBase);
  frxObjects.UnRegister(TfrxADOTable);
  frxObjects.UnRegister(TfrxADOQuery);

end.