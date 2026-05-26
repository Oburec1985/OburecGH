unit uOglChartBaseObj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, uOglChartLog;

type
  cBaseObj = class;

  { Обход дерева объектов чарта.
    Возвращай False, если нужно остановить рекурсию. }
  TChartEnumProc = function(AObject: cBaseObj; AData: Pointer): Boolean;

  { Базовый реестр объектов чарта.
    cBaseObj знает только этот контракт, а конкретный менеджер живет отдельно. }
  cChartObjRegistry = class(TObject)
  public
    procedure RegisterObject(AObject: cBaseObj); virtual; abstract;
    procedure UnregisterObject(AObject: cBaseObj); virtual; abstract;
    procedure RegisterTree(AObject: cBaseObj); virtual; abstract;
    procedure UnregisterTree(AObject: cBaseObj); virtual; abstract;
  end;

  { cBaseObj
    Общий корень объектной модели: уникальное имя, подпись, дерево детей,
    связь с менеджером и точки расширения для сериализации. }
  cBaseObj = class(TObject)
  private
    fName: string;
    fCaption: string;
    fParent: cBaseObj;
    fChildren: TList;
    fManager: TObject;

    function GetChild(AIndex: Integer): cBaseObj;
    function GetChildCount: Integer;
    procedure SetParent(AValue: cBaseObj);
  protected
    procedure SetName(const AValue: string); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function NotSaveToJson: Boolean; virtual;
    procedure AssignDefaultProperties; virtual;
    procedure SaveJsonAttributes(AJson: TJSONObject); virtual;
    procedure LoadJsonAttributes(AJson: TJSONObject); virtual;

    procedure AddChild(AChild: cBaseObj);
    procedure RemoveChild(AChild: cBaseObj);
    procedure ClearChildren;
    function FindChild(const AName: string): cBaseObj;
    function EnumTree(AProc: TChartEnumProc; AData: Pointer): Boolean;

    property Name: string read fName write SetName;
    property Caption: string read fCaption write fCaption;
    property Parent: cBaseObj read fParent write SetParent;
    property Children[AIndex: Integer]: cBaseObj read GetChild;
    property ChildCount: Integer read GetChildCount;
    property Manager: TObject read fManager write fManager;
  end;

  TChartBaseObject = cBaseObj;

implementation

constructor cBaseObj.Create;
begin
  inherited Create;
  fChildren := TList.Create;
  AssignDefaultProperties;
  ChartLogDebug(Format('cBaseObj.Create self=%s class=%s name="%s"', [
    ChartPtr(Self), ClassName, fName
  ]));
end;

destructor cBaseObj.Destroy;
begin
  ChartLogDebug(Format('cBaseObj.Destroy enter self=%s class=%s name="%s" children=%d parent=%s manager=%s', [
    ChartPtr(Self), ClassName, fName, ChildCount, ChartPtr(fParent), ChartPtr(TObject(fManager))
  ]));
  ClearChildren;
  if Assigned(fParent) then
    fParent.RemoveChild(Self);
  if Assigned(fManager) and (fManager is cChartObjRegistry) then
    cChartObjRegistry(fManager).UnregisterObject(Self);
  fChildren.Free;
  inherited Destroy;
end;

procedure cBaseObj.AssignDefaultProperties;
begin
  fName := ClassName;
  fCaption := fName;
end;

function cBaseObj.NotSaveToJson: Boolean;
begin
  Result := False;
end;

procedure cBaseObj.SaveJsonAttributes(AJson: TJSONObject);
begin
end;

procedure cBaseObj.LoadJsonAttributes(AJson: TJSONObject);
begin
end;

procedure cBaseObj.SetName(const AValue: string);
begin
  fName := AValue;
  if fCaption = '' then
    fCaption := AValue;
end;

function cBaseObj.GetChild(AIndex: Integer): cBaseObj;
begin
  Result := cBaseObj(fChildren[AIndex]);
end;

function cBaseObj.GetChildCount: Integer;
begin
  Result := fChildren.Count;
end;

procedure cBaseObj.SetParent(AValue: cBaseObj);
begin
  if fParent = AValue then
    Exit;
  if Assigned(fParent) then
    fParent.RemoveChild(Self);
  fParent := AValue;
  if Assigned(fParent) and (fParent.fChildren.IndexOf(Self) < 0) then
    fParent.fChildren.Add(Self);
end;

procedure cBaseObj.AddChild(AChild: cBaseObj);
begin
  if not Assigned(AChild) then
    Exit;
  AChild.Parent := Self;
  if Assigned(fManager) and (fManager is cChartObjRegistry) then
    cChartObjRegistry(fManager).RegisterTree(AChild);
end;

procedure cBaseObj.RemoveChild(AChild: cBaseObj);
begin
  if not Assigned(AChild) then
    Exit;
  fChildren.Remove(AChild);
  if AChild.fParent = Self then
    AChild.fParent := nil;
end;

procedure cBaseObj.ClearChildren;
begin
  while fChildren.Count > 0 do
    cBaseObj(fChildren.Last).Free;
end;

function cBaseObj.FindChild(const AName: string): cBaseObj;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildCount - 1 do
    if SameText(Children[I].Name, AName) then
      Exit(Children[I]);
end;

function cBaseObj.EnumTree(AProc: TChartEnumProc; AData: Pointer): Boolean;
var
  I: Integer;
begin
  Result := True;
  if Assigned(AProc) then
    Result := AProc(Self, AData);
  if not Result then
    Exit;
  for I := 0 to ChildCount - 1 do
  begin
    Result := Children[I].EnumTree(AProc, AData);
    if not Result then
      Exit;
  end;
end;

end.
