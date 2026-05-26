unit uOglChartMng;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uOglChartTypes, uOglChartLog, uOglChartBaseObj, uOglChartChart;

type
  { cChartMng
    Владеет корневой моделью и ведёт плоский реестр объектов для поиска,
    сериализации и будущего инспектора. }
  cChartMng = class(cChartObjRegistry)
  private
    fObjects: TList;
    fRoot: cChart;

    function GetObject(AIndex: Integer): cBaseObj;
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure RegisterObject(AObject: cBaseObj); override;
    procedure UnregisterObject(AObject: cBaseObj); override;
    procedure RegisterTree(AObject: cBaseObj); override;
    procedure UnregisterTree(AObject: cBaseObj); override;

    procedure Clear;
    procedure AlignPagesAuto(AAspect: Double = 1);
    procedure SetRoot(ARoot: cChart);
    procedure Add(AObject, ARoot: cBaseObj);
    function FindObject(const AName: string): cBaseObj;
    function SaveToString(ASerializer: IChartSerializer): string;
    procedure LoadFromString(ASerializer: IChartSerializer; const AData: string);

    property Root: cChart read fRoot;
    property Objects[AIndex: Integer]: cBaseObj read GetObject;
    property Count: Integer read GetCount;
  end;

  TChartObjectManager = cChartMng;

implementation

constructor cChartMng.Create;
begin
  inherited Create;
  fObjects := TList.Create;
  ChartLogInfo('cChartMng.Create self=' + ChartPtr(Self));
  SetRoot(cChart.Create);
end;

destructor cChartMng.Destroy;
begin
  ChartLogInfo(Format('cChartMng.Destroy self=%s root=%s count=%d', [
    ChartPtr(Self), ChartPtr(fRoot), Count
  ]));
  FreeAndNil(fRoot);
  fObjects.Free;
  inherited Destroy;
end;

procedure cChartMng.RegisterObject(AObject: cBaseObj);
begin
  if not Assigned(AObject) or (fObjects.IndexOf(AObject) >= 0) then
    Exit;
  fObjects.Add(AObject);
  AObject.Manager := Self;
end;

procedure cChartMng.UnregisterObject(AObject: cBaseObj);
begin
  if not Assigned(AObject) then
    Exit;
  fObjects.Remove(AObject);
  if AObject.Manager = Self then
    AObject.Manager := nil;
end;

procedure cChartMng.RegisterTree(AObject: cBaseObj);
var
  I: Integer;
begin
  if not Assigned(AObject) then
    Exit;
  RegisterObject(AObject);
  for I := 0 to AObject.ChildCount - 1 do
    RegisterTree(AObject.Children[I]);
end;

procedure cChartMng.UnregisterTree(AObject: cBaseObj);
var
  I: Integer;
begin
  if not Assigned(AObject) then
    Exit;
  for I := 0 to AObject.ChildCount - 1 do
    UnregisterTree(AObject.Children[I]);
  UnregisterObject(AObject);
end;

function cChartMng.GetObject(AIndex: Integer): cBaseObj;
begin
  Result := cBaseObj(fObjects[AIndex]);
end;

function cChartMng.GetCount: Integer;
begin
  Result := fObjects.Count;
end;

procedure cChartMng.Clear;
begin
  if Assigned(fRoot) then
  begin
    fRoot.Clear;
    fObjects.Clear;
    RegisterTree(fRoot);
  end;
end;

procedure cChartMng.AlignPagesAuto(AAspect: Double);
begin
  if Assigned(fRoot) then
    fRoot.AlignPagesAuto(AAspect);
end;

procedure cChartMng.SetRoot(ARoot: cChart);
begin
  if fRoot = ARoot then
    Exit;
  if Assigned(fRoot) then
    FreeAndNil(fRoot);
  fRoot := ARoot;
  fObjects.Clear;
  RegisterTree(fRoot);
end;

procedure cChartMng.Add(AObject, ARoot: cBaseObj);
begin
  if not Assigned(AObject) then
    Exit;
  if Assigned(ARoot) then
    ARoot.AddChild(AObject);
  RegisterTree(AObject);
end;

function cChartMng.FindObject(const AName: string): cBaseObj;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Objects[I].Name, AName) then
      Exit(Objects[I]);
end;

function cChartMng.SaveToString(ASerializer: IChartSerializer): string;
begin
  Result := '';
  if Assigned(fRoot) and Assigned(ASerializer) then
    Result := ASerializer.SaveObject(fRoot);
end;

procedure cChartMng.LoadFromString(ASerializer: IChartSerializer; const AData: string);
begin
  if Assigned(fRoot) and Assigned(ASerializer) then
  begin
    ASerializer.LoadObject(fRoot, AData);
    fObjects.Clear;
    RegisterTree(fRoot);
  end;
end;

end.
