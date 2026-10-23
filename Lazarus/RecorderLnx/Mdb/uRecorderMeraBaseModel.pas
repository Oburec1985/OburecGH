unit uRecorderMeraBaseModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderFormModel;

type
  { Persistent settings of one embedded XML test-database component. }
  TRecorderMeraBaseComponent = class(TRecorderVisualComponent)
  private
    fBasePath: string;
    fObjectId: string;
    fTestId: string;
    procedure SetBasePath(const AValue: string);
    procedure SetObjectId(const AValue: string);
    procedure SetTestId(const AValue: string);
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure ActivateContext;
    property BasePath: string read fBasePath write SetBasePath;
    property ObjectId: string read fObjectId write SetObjectId;
    property TestId: string read fTestId write SetTestId;
  end;

  TRecorderMeraBaseFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
    function CreateComponentForPage(
      const AContext: TRecorderComponentCreateContext): TRecorderVisualComponent;
      override;
  end;

procedure RegisterRecorderMeraBaseFactory(AFactory: TRecorderComponentFactory);
function RecorderMeraObjectDirectory: string;
function RecorderMeraContextRevision: QWord;

implementation

uses
  uRecorderMeraPaths, uRecorderMdbRepository, uRecorderXmlDatabase,
  uRecorderMdbManager;

var g_BaseModels: TList = nil;
    g_ContextRevision: QWord = 0;
    g_ActiveBaseModel: TRecorderMeraBaseComponent = nil;

procedure TRecorderMeraBaseComponent.ActivateContext;
begin
  if ParentPage = nil then Exit;
  g_ActiveBaseModel := Self;
  Inc(g_ContextRevision);
  NotifyRecorderMdbContextChanged;
end;

function RecorderMeraContextRevision: QWord;
begin
  Result:=g_ContextRevision;
end;

procedure TRecorderMeraBaseComponent.SetBasePath(const AValue: string);
begin
  if fBasePath=AValue then Exit;
  fBasePath:=AValue;
  Inc(g_ContextRevision);
  NotifyRecorderMdbContextChanged;
end;

procedure TRecorderMeraBaseComponent.SetObjectId(const AValue: string);
begin
  if fObjectId=AValue then Exit;
  fObjectId:=AValue;
  Inc(g_ContextRevision);
  NotifyRecorderMdbContextChanged;
end;

procedure TRecorderMeraBaseComponent.SetTestId(const AValue: string);
begin
  if fTestId=AValue then Exit;
  fTestId:=AValue;
  Inc(g_ContextRevision);
  NotifyRecorderMdbContextChanged;
end;

constructor TRecorderMeraBaseComponent.Create;
begin
  inherited Create;
  if g_BaseModels = nil then g_BaseModels := TList.Create;
  g_BaseModels.Add(Self);
  Inc(g_ContextRevision);
end;

destructor TRecorderMeraBaseComponent.Destroy;
begin
  if g_ActiveBaseModel = Self then g_ActiveBaseModel := nil;
  if g_BaseModels <> nil then g_BaseModels.Remove(Self);
  Inc(g_ContextRevision);
  NotifyRecorderMdbContextChanged;
  inherited Destroy;
end;

function RecorderMeraObjectDirectory: string;
var
  I: Integer;
  Model: TRecorderMeraBaseComponent;
  Repository: TRecorderMdbRepository;
  Node: TRecorderXmlDbNode;
begin
  Result := '';
  if g_BaseModels = nil then Exit;
  // Models remain alive on inactive pages; views and their managers do not.
  // Ignore undo/copy snapshots, which have no owning page.
  for I := -1 to g_BaseModels.Count - 1 do
  begin
    if I = -1 then Model := g_ActiveBaseModel
    else Model := TRecorderMeraBaseComponent(g_BaseModels[I]);
    if Model = nil then Continue;
    if (Model.ParentPage = nil) or (Trim(Model.ObjectId) = '') or
      not DirectoryExists(Model.BasePath) then Continue;
    Repository := TRecorderMdbRepository.Create(Model.BasePath);
    try
      Repository.Open;
      Node := Repository.FindNode(Model.ObjectId);
      if Node <> nil then
        Exit(IncludeTrailingPathDelimiter(Repository.BasePath + Node.RelativePath));
    finally
      Repository.Free;
    end;
  end;
end;

class function TRecorderMeraBaseComponent.GetTypeId: string;
begin
  Result := 'MeraBase';
end;

constructor TRecorderMeraBaseFactory.Create;
begin
  inherited Create(TRecorderMeraBaseComponent.TypeId,
    'База испытаний', TRecorderMeraBaseComponent, 590, 640, False);
  ConfigurePalette('База испытаний', 'Добавить базу испытаний',
    'mera-base', 70, rppStandalone);
end;

function TRecorderMeraBaseFactory.CreateComponentForPage(
  const AContext: TRecorderComponentCreateContext): TRecorderVisualComponent;
var I: Integer;
begin
  if AContext.Page <> nil then
    for I := 0 to AContext.Page.ComponentCount - 1 do
      if AContext.Page.Components[I] is TRecorderMeraBaseComponent then
        raise ERecorderFormError.Create(
          'На этой форме уже есть компонент базы испытаний');
  Result := inherited CreateComponentForPage(AContext);
end;

procedure TRecorderMeraBaseFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := 'MeraBase';
  TRecorderMeraBaseComponent(AComponent).BasePath :=
    IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'mdb';
end;

procedure RegisterRecorderMeraBaseFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorderMeraBaseComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorderMeraBaseFactory.Create);
end;

finalization
  FreeAndNil(g_BaseModels);
end.
