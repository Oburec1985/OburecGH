unit uRecorderComponentManager;

{
  Единая точка создания встроенных визуальных компонентов RecorderLnx.
  MainForm зависит только от общего component API; конкретные фабрики сами
  регистрируют модели, views и редакторы настроек в этом менеджере.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderFormModel, uRecorderTags, uRecorderDacComponentModel;

type
  TRecorderComponentManager = class
  private
    fFactory: TRecorderComponentFactory;
    fMeasurementSectionFactory: TRecorderComponentFactoryBase;
    fDacFactory: TRecorderDacComponentFactory;
  public
    class function CreateComponents: TRecorderComponentManager;
    destructor Destroy; override;
    procedure PublishGeneratedTags(ARegistry: TRecorderTagRegistry);
    procedure BeginAcquisitionSession(ARegistry: TRecorderTagRegistry);
    procedure DoStart;
    procedure DoStop;
    procedure DoUpdateData;
    function AddToPage(APage: TRecorderFormPage;
      AComponent: TRecorderVisualComponent): Boolean;
    property Factory: TRecorderComponentFactory read fFactory;
  end;

implementation

uses
  uRecorder3dModel, uRecorder3dView,
  uRecorderFrequencyResponseModel, uRecorderFrequencyResponseView,
  uRecorderImpactHammerModel, uRecorderImpactHammerView,
  uRecorderMeasurementSectionModel, uRecorderMeasurementSectionView,
  uRecorderMeraBaseModel, uRecorderMeraBaseView,
  uRecorderDacComponentView,
  uRecorderSignalGeneratorModel, uRecorderSignalGeneratorView,
  uRecorderSqlTrendModel, uRecorderSqlTrendView,
  uRecorderTrendView;

class function TRecorderComponentManager.CreateComponents:
  TRecorderComponentManager;
begin
  Result := TRecorderComponentManager.Create;
  try
    Result.fFactory := TRecorderComponentFactory.Create;
    Result.fFactory.RegisterDefaultComponents;
    RegisterRecorderSignalGeneratorFactory(Result.fFactory);
    RegisterRecorderDacComponentFactory(Result.fFactory);
    RegisterRecorderFrequencyResponseFactory(Result.fFactory);
    RegisterRecorder3dFactory(Result.fFactory);
    RegisterRecorderImpactHammerFactory(Result.fFactory);
    RegisterRecorderSqlTrendFactory(Result.fFactory);
    RegisterRecorderMeraBaseFactory(Result.fFactory);
    RegisterRecorderMeasurementSectionFactory(Result.fFactory);
    Result.fMeasurementSectionFactory := Result.fFactory.FindFactory(
      TRecorderMeasurementSectionComponent.TypeId);
    Result.fDacFactory := TRecorderDacComponentFactory(
      Result.fFactory.FindFactory(TRecorderDacComponent.TypeId));
  except
    Result.Free;
    raise;
  end;
end;

destructor TRecorderComponentManager.Destroy;
begin
  fFactory.Free;
  inherited Destroy;
end;

procedure TRecorderComponentManager.PublishGeneratedTags(
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
begin
  if (fMeasurementSectionFactory = nil) or (ARegistry = nil) then Exit;
  for I := 0 to fMeasurementSectionFactory.ChildCount - 1 do
    TRecorderMeasurementSectionComponent(
      fMeasurementSectionFactory.Children[I]).PublishGeneratedTags(ARegistry);
end;

procedure TRecorderComponentManager.BeginAcquisitionSession(
  ARegistry: TRecorderTagRegistry);
begin
  TRecorderTrendView.BeginAcquisitionSession(ARegistry);
  if fDacFactory <> nil then fDacFactory.SetTagRegistry(ARegistry);
end;

procedure TRecorderComponentManager.DoStart;
begin
  fFactory.DoStart;
end;

procedure TRecorderComponentManager.DoStop;
begin
  fFactory.DoStop;
end;

procedure TRecorderComponentManager.DoUpdateData;
begin
  fFactory.DoUpdateData;
end;

function TRecorderComponentManager.AddToPage(APage: TRecorderFormPage;
  AComponent: TRecorderVisualComponent): Boolean;
begin
  Result := AComponent is TRecorderImageComponent;
  if (APage = nil) or (AComponent = nil) then Exit(False);
  if Result then
    APage.AddComponentToBack(AComponent)
  else
    APage.AddComponent(AComponent);
end;

end.
