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
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property BasePath: string read fBasePath write fBasePath;
    property ObjectId: string read fObjectId write fObjectId;
    property TestId: string read fTestId write fTestId;
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

implementation

uses
  uRecorderMeraPaths, uRecorderMdbRepository, uRecorderXmlDatabase;

var g_BaseModels: TList = nil;

constructor TRecorderMeraBaseComponent.Create;
begin
  inherited Create;
  if g_BaseModels = nil then g_BaseModels := TList.Create;
  g_BaseModels.Add(Self);
end;

destructor TRecorderMeraBaseComponent.Destroy;
begin
  if g_BaseModels <> nil then g_BaseModels.Remove(Self);
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
  for I := 0 to g_BaseModels.Count - 1 do
  begin
    Model := TRecorderMeraBaseComponent(g_BaseModels[I]);
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
