unit uRecorderVisualControl;

{
  Модуль: uRecorderVisualControl
  Описание: Общий интерфейс, базовый класс и реестр для визуальных компонентов
            на мнемосхемах. Позволяет контроллеру абстрагироваться от конкретных
            реализаций (осциллограмм, трендов, текстовых полей) и легко добавлять
            новые визуальные компоненты, в том числе из внешних плагинов.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics,
  uOglChart, uRecorderFormModel, uRecorderTags;

type
  { IVForm
    Интерфейс для всех визуальных компонентов мнемосхем.
    Все визуальные виджеты должны реализовывать этот интерфейс. }
  IVForm = interface
    ['{69A4CBA7-4E0D-47C0-B95D-8D5EF980ACF8}']
    { Настройка компонента на основе его модели данных }
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    { Обновление данных компонента при получении новых отсчетов }
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    { Возвращает связанный OpenGL чарт (TOglChart), если он есть. Иначе nil }
    function GetChartControl: TOglChart;
  end;

  { Класс-ссылка на визуальный контрол }
  TRecorderVisualControlClass = class of TControl;

  { Реестр визуальных компонентов мнемосхем }
  TRecorderVisualControlRegistry = class
  private
    class var fRegistryList: TStringList;
    class function GetRegistryList: TStringList;
  public
    { Регистрация связи: Класс модели -> Класс визуального представления }
    class procedure RegisterControl(AComponentClass: TRecorderVisualComponentClass; AControlClass: TRecorderVisualControlClass);
    { Получение класса визуального представления по классу модели }
    class function GetControlClass(AComponentClass: TRecorderVisualComponentClass): TRecorderVisualControlClass;
    { Очистка реестра }
    class procedure ClearRegistry;
  end;

  { TRecorderStaticTextView
    Визуальное представление статического текста (надписей) }
  TRecorderStaticTextView = class(TPanel, IVForm)
  private
    fComponent: TRecorderStaticTextComponent;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

  { TRecorderTagValueView
    Визуальное представление цифрового индикатора значения тега }
  TRecorderTagValueView = class(TPanel, IVForm)
  private
    fComponent: TRecorderTagValueComponent;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

uses
  uOglChartTrend,
  uRecorderOglOscillogramView,
  uRecorderTrendView;

{ TRecorderVisualControlRegistry }

class function TRecorderVisualControlRegistry.GetRegistryList: TStringList;
begin
  if fRegistryList = nil then
  begin
    fRegistryList := TStringList.Create;
    fRegistryList.Sorted := True;
    fRegistryList.Duplicates := dupIgnore;
  end;
  Result := fRegistryList;
end;

class procedure TRecorderVisualControlRegistry.RegisterControl(
  AComponentClass: TRecorderVisualComponentClass; AControlClass: TRecorderVisualControlClass);
begin
  if AComponentClass = nil then Exit;
  GetRegistryList.AddObject(AComponentClass.TypeId, TObject(Pointer(AControlClass)));
end;

class function TRecorderVisualControlRegistry.GetControlClass(
  AComponentClass: TRecorderVisualComponentClass): TRecorderVisualControlClass;
var
  lIdx: Integer;
begin
  Result := nil;
  if AComponentClass = nil then Exit;
  lIdx := GetRegistryList.IndexOf(AComponentClass.TypeId);
  if lIdx >= 0 then
    Result := TRecorderVisualControlClass(Pointer(GetRegistryList.Objects[lIdx]));
end;

class procedure TRecorderVisualControlRegistry.ClearRegistry;
begin
  FreeAndNil(fRegistryList);
end;

{ TRecorderStaticTextView }

constructor TRecorderStaticTextView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
end;

procedure TRecorderStaticTextView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderStaticTextComponent(AComponent);
  Caption := fComponent.Text;
  Alignment := taLeftJustify;
  Color := clWhite;
  
  // Применение настроек шрифта
  Font.Name := fComponent.FontName;
  if fComponent.FontSize > 0 then
    Font.Size := fComponent.FontSize;
  Font.Color := TColor(fComponent.FontColor);
  Font.Style := [];
  if fComponent.FontStyleBold then
    Font.Style := Font.Style + [fsBold];
  if fComponent.FontStyleItalic then
    Font.Style := Font.Style + [fsItalic];
end;

procedure TRecorderStaticTextView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
begin
  // Статический текст не требует обновления значений в реальном времени
end;

function TRecorderStaticTextView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

{ TRecorderTagValueView }

constructor TRecorderTagValueView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := $00F2F8FF;
end;

procedure TRecorderTagValueView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderTagValueComponent(AComponent);
  Alignment := taCenter;
  Font.Style := [fsBold];
  Color := $00F2F8FF;
  RefreshControl(ATagRegistry, 0);
end;

procedure TRecorderTagValueView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lTag: TRecorderTag;
  lValueStr: string;
begin
  if not IsVisible then
    Exit;

  if (fComponent = nil) or (ATagRegistry = nil) then
    Exit;
    
  lTag := ATagRegistry.FindByName(fComponent.TagName);
  if (lTag <> nil) and (lTag.Snapshot.Count > 0) then
    lValueStr := FormatFloat('0.000', lTag.Snapshot.Values[lTag.Snapshot.Count - 1])
  else
    lValueStr := '0.0';
    
  Caption := fComponent.TagName + '  ' + lValueStr;
end;

function TRecorderTagValueView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

initialization
  // Регистрация визуальных контролов мнемосхем
  TRecorderVisualControlRegistry.RegisterControl(TRecorderStaticTextComponent, TRecorderStaticTextView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderTagValueComponent, TRecorderTagValueView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderTrendComponent, TRecorderTrendView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderOscillogramComponent, TRecorderOglOscillogram);

finalization
  TRecorderVisualControlRegistry.ClearRegistry;

end.
