unit uOglChartModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, uOglChartTypes, uOglChartLog;

type
  TChartBaseObject = class;

  TChartEnumProc = function(AObject: TChartBaseObject; AData: Pointer): Boolean;

  { TChartBaseObject
    Lightweight Lazarus analogue of SharedUtils cBaseObj: name, caption,
    parent-child tree and overridable JSON attributes. }
  TChartBaseObject = class(TObject)
  private
    fName: string;
    fCaption: string;
    fParent: TChartBaseObject;
    fChildren: TList;
    fManager: TObject;

    function GetChild(AIndex: Integer): TChartBaseObject;
    function GetChildCount: Integer;
    procedure SetParent(AValue: TChartBaseObject);
  protected
    procedure SetName(const AValue: string); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function NotSaveToJson: Boolean; virtual;
    procedure AssignDefaultProperties; virtual;
    procedure SaveJsonAttributes(AJson: TJSONObject); virtual;
    procedure LoadJsonAttributes(AJson: TJSONObject); virtual;

    procedure AddChild(AChild: TChartBaseObject);
    procedure RemoveChild(AChild: TChartBaseObject);
    procedure ClearChildren;
    function FindChild(const AName: string): TChartBaseObject;
    function EnumTree(AProc: TChartEnumProc; AData: Pointer): Boolean;

    property Name: string read fName write SetName;
    property Caption: string read fCaption write fCaption;
    property Parent: TChartBaseObject read fParent write SetParent;
    property Children[AIndex: Integer]: TChartBaseObject read GetChild;
    property ChildCount: Integer read GetChildCount;
    property Manager: TObject read fManager write fManager;
  end;

  { TChartModel - root chart object. }
  TChartModel = class(TChartBaseObject)
  private
    fTitle: string;
    fBackgroundColor: Cardinal;
  public
    procedure AssignDefaultProperties; override;
    procedure Clear;
    procedure SaveJsonAttributes(AJson: TJSONObject); override;
    procedure LoadJsonAttributes(AJson: TJSONObject); override;

    function Serialize(ASerializer: IChartSerializer): string;
    procedure Deserialize(ASerializer: IChartSerializer; const AData: string);

    property Title: string read fTitle write fTitle;
    property BackgroundColor: Cardinal read fBackgroundColor write fBackgroundColor;
  end;

  { TChartObjectManager owns the model tree and serializes it as a string. }
  TChartObjectManager = class(TObject)
  private
    fObjects: TList;
    fRoot: TChartModel;

    procedure RegisterObject(AObject: TChartBaseObject);
    procedure UnregisterObject(AObject: TChartBaseObject);
    procedure RegisterTree(AObject: TChartBaseObject);
    procedure UnregisterTree(AObject: TChartBaseObject);
    function GetObject(AIndex: Integer): TChartBaseObject;
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    procedure SetRoot(ARoot: TChartModel);
    procedure Add(AObject, ARoot: TChartBaseObject);
    function FindObject(const AName: string): TChartBaseObject;
    function SaveToString(ASerializer: IChartSerializer): string;
    procedure LoadFromString(ASerializer: IChartSerializer; const AData: string);

    property Root: TChartModel read fRoot;
    property Objects[AIndex: Integer]: TChartBaseObject read GetObject;
    property Count: Integer read GetCount;
  end;

implementation

{ TChartBaseObject }

constructor TChartBaseObject.Create;
begin
  inherited Create;
  fChildren := TList.Create;
  AssignDefaultProperties;
  ChartLogDebug(Format('TChartBaseObject.Create self=%s class=%s name="%s"', [
    ChartPtr(Self), ClassName, fName
  ]));
end;

destructor TChartBaseObject.Destroy;
begin
  ChartLogDebug(Format('TChartBaseObject.Destroy enter self=%s class=%s name="%s" children=%d parent=%s manager=%s', [
    ChartPtr(Self), ClassName, fName, ChildCount, ChartPtr(fParent), ChartPtr(TObject(fManager))
  ]));
  ClearChildren;
  if Assigned(fParent) then
    fParent.RemoveChild(Self);
  if Assigned(fManager) and (fManager is TChartObjectManager) then
    TChartObjectManager(fManager).UnregisterObject(Self);
  fChildren.Free;
  ChartLogDebug('TChartBaseObject.Destroy leave self=' + ChartPtr(Self));
  inherited Destroy;
end;

procedure TChartBaseObject.AssignDefaultProperties;
begin
  fName := ClassName;
  fCaption := fName;
end;

function TChartBaseObject.NotSaveToJson: Boolean;
begin
  Result := False;
end;

procedure TChartBaseObject.SaveJsonAttributes(AJson: TJSONObject);
begin
end;

procedure TChartBaseObject.LoadJsonAttributes(AJson: TJSONObject);
begin
end;

procedure TChartBaseObject.SetName(const AValue: string);
begin
  ChartLogDebug(Format('TChartBaseObject.SetName self=%s old="%s" new="%s"', [
    ChartPtr(Self), fName, AValue
  ]));
  fName := AValue;
  if fCaption = '' then
    fCaption := AValue;
end;

function TChartBaseObject.GetChild(AIndex: Integer): TChartBaseObject;
begin
  Result := TChartBaseObject(fChildren[AIndex]);
end;

function TChartBaseObject.GetChildCount: Integer;
begin
  Result := fChildren.Count;
end;

procedure TChartBaseObject.SetParent(AValue: TChartBaseObject);
begin
  ChartLogDebug(Format('TChartBaseObject.SetParent self=%s old=%s new=%s', [
    ChartPtr(Self), ChartPtr(fParent), ChartPtr(AValue)
  ]));
  if fParent = AValue then
    Exit;
  if Assigned(fParent) then
    fParent.RemoveChild(Self);
  fParent := AValue;
  if Assigned(fParent) and (fParent.fChildren.IndexOf(Self) < 0) then
    fParent.fChildren.Add(Self);
end;

procedure TChartBaseObject.AddChild(AChild: TChartBaseObject);
begin
  ChartLogDebug(Format('TChartBaseObject.AddChild parent=%s child=%s', [
    ChartPtr(Self), ChartPtr(AChild)
  ]));
  if not Assigned(AChild) then
    Exit;
  AChild.Parent := Self;
  if Assigned(fManager) and (fManager is TChartObjectManager) then
    TChartObjectManager(fManager).RegisterTree(AChild);
end;

procedure TChartBaseObject.RemoveChild(AChild: TChartBaseObject);
begin
  ChartLogDebug(Format('TChartBaseObject.RemoveChild parent=%s child=%s', [
    ChartPtr(Self), ChartPtr(AChild)
  ]));
  if not Assigned(AChild) then
    Exit;
  fChildren.Remove(AChild);
  if AChild.fParent = Self then
    AChild.fParent := nil;
end;

procedure TChartBaseObject.ClearChildren;
begin
  ChartLogDebug(Format('TChartBaseObject.ClearChildren self=%s count=%d', [
    ChartPtr(Self), fChildren.Count
  ]));
  while fChildren.Count > 0 do
    TChartBaseObject(fChildren.Last).Free;
end;

function TChartBaseObject.FindChild(const AName: string): TChartBaseObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildCount - 1 do
    if SameText(Children[I].Name, AName) then
      Exit(Children[I]);
end;

function TChartBaseObject.EnumTree(AProc: TChartEnumProc; AData: Pointer): Boolean;
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

{ TChartModel }

procedure TChartModel.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'ChartModel';
  Caption := 'Chart';
  Clear;
end;

procedure TChartModel.Clear;
begin
  ChartLogDebug('TChartModel.Clear self=' + ChartPtr(Self));
  fTitle := 'New Chart';
  fBackgroundColor := $FF000000;
  ClearChildren;
end;

procedure TChartModel.SaveJsonAttributes(AJson: TJSONObject);
begin
  ChartLogDebug(Format('TChartModel.SaveJsonAttributes self=%s title="%s" background=%s json=%s', [
    ChartPtr(Self), fTitle, IntToHex(fBackgroundColor, 8), ChartPtr(AJson)
  ]));
  inherited SaveJsonAttributes(AJson);
  AJson.Add('Title', fTitle);
  AJson.Add('BackgroundColor', IntToHex(fBackgroundColor, 8));
end;

procedure TChartModel.LoadJsonAttributes(AJson: TJSONObject);
begin
  ChartLogDebug(Format('TChartModel.LoadJsonAttributes self=%s json=%s', [
    ChartPtr(Self), ChartPtr(AJson)
  ]));
  inherited LoadJsonAttributes(AJson);
  if not Assigned(AJson) then
    Exit;
  if AJson.IndexOfName('Title') <> -1 then
    fTitle := AJson.Strings['Title'];
  if AJson.IndexOfName('BackgroundColor') <> -1 then
    fBackgroundColor := StrToQWord('$' + AJson.Strings['BackgroundColor']);
end;

function TChartModel.Serialize(ASerializer: IChartSerializer): string;
begin
  ChartLogInfo(Format('TChartModel.Serialize self=%s serializer_assigned=%s', [
    ChartPtr(Self), BoolToStr(Assigned(ASerializer), True)
  ]));
  Result := '';
  if Assigned(ASerializer) then
    Result := ASerializer.SaveObject(Self);
end;

procedure TChartModel.Deserialize(ASerializer: IChartSerializer; const AData: string);
begin
  ChartLogInfo(Format('TChartModel.Deserialize self=%s serializer_assigned=%s data_length=%d', [
    ChartPtr(Self), BoolToStr(Assigned(ASerializer), True), Length(AData)
  ]));
  if Assigned(ASerializer) then
    ASerializer.LoadObject(Self, AData);
end;

{ TChartObjectManager }

constructor TChartObjectManager.Create;
begin
  inherited Create;
  fObjects := TList.Create;
  ChartLogInfo('TChartObjectManager.Create self=' + ChartPtr(Self));
  SetRoot(TChartModel.Create);
end;

destructor TChartObjectManager.Destroy;
begin
  ChartLogInfo(Format('TChartObjectManager.Destroy enter self=%s root=%s count=%d', [
    ChartPtr(Self), ChartPtr(fRoot), Count
  ]));
  FreeAndNil(fRoot);
  fObjects.Free;
  ChartLogInfo('TChartObjectManager.Destroy leave self=' + ChartPtr(Self));
  inherited Destroy;
end;

procedure TChartObjectManager.RegisterObject(AObject: TChartBaseObject);
begin
  ChartLogDebug(Format('TChartObjectManager.RegisterObject manager=%s object=%s', [
    ChartPtr(Self), ChartPtr(AObject)
  ]));
  if not Assigned(AObject) or (fObjects.IndexOf(AObject) >= 0) then
    Exit;
  fObjects.Add(AObject);
  AObject.Manager := Self;
end;

procedure TChartObjectManager.UnregisterObject(AObject: TChartBaseObject);
begin
  ChartLogDebug(Format('TChartObjectManager.UnregisterObject manager=%s object=%s', [
    ChartPtr(Self), ChartPtr(AObject)
  ]));
  if not Assigned(AObject) then
    Exit;
  fObjects.Remove(AObject);
  if AObject.Manager = Self then
    AObject.Manager := nil;
end;

procedure TChartObjectManager.RegisterTree(AObject: TChartBaseObject);
var
  I: Integer;
begin
  ChartLogDebug(Format('TChartObjectManager.RegisterTree manager=%s object=%s', [
    ChartPtr(Self), ChartPtr(AObject)
  ]));
  if not Assigned(AObject) then
    Exit;
  RegisterObject(AObject);
  for I := 0 to AObject.ChildCount - 1 do
    RegisterTree(AObject.Children[I]);
end;

procedure TChartObjectManager.UnregisterTree(AObject: TChartBaseObject);
var
  I: Integer;
begin
  ChartLogDebug(Format('TChartObjectManager.UnregisterTree manager=%s object=%s', [
    ChartPtr(Self), ChartPtr(AObject)
  ]));
  if not Assigned(AObject) then
    Exit;
  for I := 0 to AObject.ChildCount - 1 do
    UnregisterTree(AObject.Children[I]);
  UnregisterObject(AObject);
end;

function TChartObjectManager.GetObject(AIndex: Integer): TChartBaseObject;
begin
  Result := TChartBaseObject(fObjects[AIndex]);
end;

function TChartObjectManager.GetCount: Integer;
begin
  Result := fObjects.Count;
end;

procedure TChartObjectManager.Clear;
begin
  ChartLogInfo('TChartObjectManager.Clear self=' + ChartPtr(Self));
  if Assigned(fRoot) then
  begin
    fRoot.Clear;
    fObjects.Clear;
    RegisterTree(fRoot);
  end;
end;

procedure TChartObjectManager.SetRoot(ARoot: TChartModel);
begin
  ChartLogInfo(Format('TChartObjectManager.SetRoot manager=%s old=%s new=%s', [
    ChartPtr(Self), ChartPtr(fRoot), ChartPtr(ARoot)
  ]));
  if fRoot = ARoot then
    Exit;
  if Assigned(fRoot) then
    FreeAndNil(fRoot);
  fRoot := ARoot;
  fObjects.Clear;
  RegisterTree(fRoot);
end;

procedure TChartObjectManager.Add(AObject, ARoot: TChartBaseObject);
begin
  ChartLogInfo(Format('TChartObjectManager.Add manager=%s object=%s root=%s', [
    ChartPtr(Self), ChartPtr(AObject), ChartPtr(ARoot)
  ]));
  if not Assigned(AObject) then
    Exit;
  if Assigned(ARoot) then
    ARoot.AddChild(AObject);
  RegisterTree(AObject);
end;

function TChartObjectManager.FindObject(const AName: string): TChartBaseObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Objects[I].Name, AName) then
      Exit(Objects[I]);
end;

function TChartObjectManager.SaveToString(ASerializer: IChartSerializer): string;
begin
  ChartLogInfo(Format('TChartObjectManager.SaveToString enter manager=%s root=%s count=%d serializer_assigned=%s', [
    ChartPtr(Self), ChartPtr(fRoot), Count, BoolToStr(Assigned(ASerializer), True)
  ]));
  Result := '';
  if Assigned(fRoot) and Assigned(ASerializer) then
    Result := ASerializer.SaveObject(fRoot);
  ChartLogInfo(Format('TChartObjectManager.SaveToString leave manager=%s result_length=%d', [
    ChartPtr(Self), Length(Result)
  ]));
end;

procedure TChartObjectManager.LoadFromString(ASerializer: IChartSerializer; const AData: string);
begin
  ChartLogInfo(Format('TChartObjectManager.LoadFromString enter manager=%s root=%s data_length=%d serializer_assigned=%s', [
    ChartPtr(Self), ChartPtr(fRoot), Length(AData), BoolToStr(Assigned(ASerializer), True)
  ]));
  if Assigned(fRoot) and Assigned(ASerializer) then
  begin
    ASerializer.LoadObject(fRoot, AData);
    fObjects.Clear;
    RegisterTree(fRoot);
  end;
  ChartLogInfo(Format('TChartObjectManager.LoadFromString leave manager=%s count=%d', [
    ChartPtr(Self), Count
  ]));
end;

end.
