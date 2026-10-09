unit uRecorderMeraBaseModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderFormModel;

type
  { Model of the embedded test database component. The selected context itself
    lives in sql-db.ini, so every form and the SQL writer share one value. }
  TRecorderMeraBaseComponent = class(TRecorderVisualComponent)
  protected
    class function GetTypeId: string; override;
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

implementation

class function TRecorderMeraBaseComponent.GetTypeId: string;
begin
  Result := 'MeraBase';
end;

constructor TRecorderMeraBaseFactory.Create;
begin
  inherited Create(TRecorderMeraBaseComponent.TypeId,
    'База испытаний', TRecorderMeraBaseComponent, 590, 640, False);
  ConfigurePalette('База испытаний', 'Добавить базу испытаний',
    'sql-trend', 70, rppStandalone);
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
end;

procedure RegisterRecorderMeraBaseFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorderMeraBaseComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorderMeraBaseFactory.Create);
end;

end.
