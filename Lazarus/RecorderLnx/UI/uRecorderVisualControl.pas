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
  Classes, SysUtils, Math, Controls, ExtCtrls, Graphics,
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
    fLastTag: TRecorderTag;
    fLastRevision: QWord;
    fHasRevision: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

  { Оконный контрол обязателен: TGraphicControl рисует на Canvas родителя,
    поэтому design-time изменение Bevel/Bounds панели может стереть картинку. }
  TRecorderImageView = class(TCustomControl, IVForm)
  private
    fComponent: TRecorderImageComponent;
    fPicture: TPicture;
    fCurrentFileName: string;
    fLastRevision: QWord;
    fHasRevision: Boolean;
    fEditMode: Boolean;
    fLastPaintLogMode: Integer;
    function FileNameForValue(AValue: Double): string;
    function PreviewFileName(ATagRegistry: TRecorderTagRegistry): string;
    procedure SelectFile(const AFileName: string);
    procedure SetEditMode(AValue: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    property EditMode: Boolean read fEditMode write SetEditMode;
  end;

implementation

uses
  uOglChartTrend,
  uRecorderOglOscillogramView,
  uRecorderTrendView,
  uRecorderSpectrumView,
  uRecorderTagRefs,
  uRecorderDebugLog;

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
  fLastTag := nil;
  fLastRevision := 0;
  fHasRevision := False;
  Alignment := taCenter;
  WordWrap := True;
  Font.Name := fComponent.FontName;
  if fComponent.FontSize > 0 then
    Font.Size := fComponent.FontSize;
  Font.Color := TColor(fComponent.FontColor);
  Font.Style := [];
  if fComponent.FontStyleBold then
    Font.Style := Font.Style + [fsBold];
  if fComponent.FontStyleItalic then
    Font.Style := Font.Style + [fsItalic];
  Color := $00F2F8FF;
  RefreshControl(ATagRegistry, 0);
end;

procedure TRecorderTagValueView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lTag: TRecorderTag;
  lTagName: string;
  lValue: Double;
  lValueStr: string;
  lSingleLine: string;
begin
  if not IsVisible then
    Exit;

  if (fComponent = nil) or (ATagRegistry = nil) then
    Exit;
    
  lTag := RecorderResolveTag(ATagRegistry, fComponent.TagId, fComponent.TagName);
  if lTag <> nil then
    RecorderBindComponentTag(fComponent, lTag);
  if (lTag <> nil) and fHasRevision and (fLastTag = lTag) and
    (fLastRevision = lTag.SignalBuffer.Revision) then
    Exit;
  fLastTag := lTag;
  if lTag <> nil then
    fLastRevision := lTag.SignalBuffer.Revision
  else
    fLastRevision := 0;
  fHasRevision := True;
  if (lTag <> nil) and (lTag.SignalBuffer.Count > 0) then
  begin
    lValue := lTag.SignalBuffer.LatestValue;
    lValueStr := FormatFloat(fComponent.DisplayFormat, lValue);
  end
  else
    lValueStr := '0.0';

  if lTag <> nil then
    lTagName := lTag.Name
  else
    lTagName := fComponent.TagName;

  case fComponent.ShowNameMode of
    tvnmNone:
      lSingleLine := lValueStr;
    tvnmLeft:
      lSingleLine := lTagName + '  ' + lValueStr;
  else
    begin
      // Автоматический режим сохраняет компактную строку, пока она помещается.
      //  Для длинного имени значение переносится целиком на следующую строку.
      lSingleLine := lTagName + '  ' + lValueStr;
      if Canvas.TextWidth(lTagName) > ClientWidth - 4 then
        lSingleLine := lTagName + LineEnding + lValueStr;
    end;
  end;

  { Назначение прежнего Caption также инвалидирует LCL-контрол.
    Обновляем его только при фактическом изменении отображаемого текста. }
  if Caption <> lSingleLine then
    Caption := lSingleLine;
end;

function TRecorderTagValueView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

{ TRecorderImageView }

constructor TRecorderImageView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fPicture := TPicture.Create;
  fLastPaintLogMode := -1;
end;

destructor TRecorderImageView.Destroy;
begin
  fPicture.Free;
  inherited Destroy;
end;

function TRecorderImageView.FileNameForValue(AValue: Double): string;
var
  I: Integer;
  lValue: Double;
begin
  Result := '';
  if (fComponent = nil) or (fComponent.Images.Count = 0) then
    Exit;
  if Trim(fComponent.TagName) = '' then
    Exit(fComponent.Images.ValueFromIndex[0]);
  for I := 0 to fComponent.Images.Count - 1 do
    if TryStrToFloat(fComponent.Images.Names[I], lValue) and
      SameValue(lValue, AValue, 1E-9) then
      Exit(fComponent.Images.ValueFromIndex[I]);
end;

procedure TRecorderImageView.SelectFile(const AFileName: string);
begin
  if SameFileName(fCurrentFileName, AFileName) and
    ((AFileName = '') or
     ((fPicture.Graphic <> nil) and not fPicture.Graphic.Empty)) then
    Exit;
  fCurrentFileName := AFileName;
  fPicture.Clear;
  if (AFileName <> '') and FileExists(AFileName) then
    try
      fPicture.LoadFromFile(AFileName);
    except
      on E: Exception do
      begin
        RecorderDebugLog(Format(
          '[IMAGE] load failed file="%s" error="%s"', [AFileName, E.Message]));
        fPicture.Clear;
      end;
    end;
  RecorderDebugLog(Format(
    '[IMAGE] select file="%s" exists=%s loaded=%s',
    [AFileName, BoolToStr(FileExists(AFileName), True),
     BoolToStr((fPicture.Graphic <> nil) and
       not fPicture.Graphic.Empty, True)]));
  fLastPaintLogMode := -1;
  Invalidate;
end;

procedure TRecorderImageView.SetEditMode(AValue: Boolean);
begin
  if fEditMode = AValue then
    Exit;
  fEditMode := AValue;
  fLastPaintLogMode := -1;
  RecorderDebugLog(Format('[IMAGE] edit mode=%s file="%s"',
    [BoolToStr(fEditMode, True), fCurrentFileName]));
  Invalidate;
end;

procedure TRecorderImageView.Paint;
var
  lPaintMode: Integer;
  lPaintModeName: string;
begin
  if (fPicture.Graphic <> nil) and not fPicture.Graphic.Empty then
  begin
    lPaintMode := 1;
    lPaintModeName := 'IMAGE';
  end
  else if fEditMode then
  begin
    lPaintMode := 2;
    lPaintModeName := 'EDIT_FILL';
  end
  else
  begin
    lPaintMode := 3;
    lPaintModeName := 'EMPTY';
  end;
  if lPaintMode <> fLastPaintLogMode then
  begin
    RecorderDebugLog(Format(
      '[IMAGE] paint mode=%s edit=%s size=%dx%d file="%s"',
      [lPaintModeName, BoolToStr(fEditMode, True), Width, Height,
       fCurrentFileName]));
    fLastPaintLogMode := lPaintMode;
  end;

  if fEditMode then
  begin
    if lPaintMode = 1 then
      Canvas.StretchDraw(ClientRect, fPicture.Graphic)
    else
    begin
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := $00C0FFFF;
      Canvas.FillRect(ClientRect);
    end;
    { Rectangle рисует не только контур, но и заполняет внутреннюю область
      текущей кистью. После StretchDraw обязательно отключаем заливку, иначе
      белая кисть стирает уже нарисованную картинку в режиме редактирования. }
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := clFuchsia;
    Canvas.Pen.Width := 3;
    Canvas.Rectangle(1, 1, Width - 1, Height - 1);
    Exit;
  end;

  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(ClientRect);
  if lPaintMode = 1 then
    Canvas.StretchDraw(ClientRect, fPicture.Graphic)
  else
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clGray;
    Canvas.Rectangle(0, 0, Width, Height);
  end;
end;

function TRecorderImageView.PreviewFileName(
  ATagRegistry: TRecorderTagRegistry): string;
var
  I: Integer;
  lTag: TRecorderTag;
  lFileName: string;
begin
  Result := '';
  if (fComponent = nil) or (fComponent.Images.Count = 0) then
    Exit;

  { Если в рабочем режиме уже была выбрана и загружена картинка, редактор
    обязан сохранить именно её, а не заменять первой строкой таблицы. }
  if (fCurrentFileName <> '') and FileExists(fCurrentFileName) and
    (fPicture.Graphic <> nil) and not fPicture.Graphic.Empty then
    Exit(fCurrentFileName);

  lTag := nil;
  if (ATagRegistry <> nil) and (Trim(fComponent.TagName) <> '') then
  begin
    if fComponent.TagId <> 0 then
      lTag := ATagRegistry.FindById(fComponent.TagId);
    if lTag = nil then
      lTag := ATagRegistry.FindByName(fComponent.TagName);
    if (lTag <> nil) and (lTag.SignalBuffer.Count > 0) then
    begin
      lFileName := FileNameForValue(lTag.SignalBuffer.LatestValue);
      if (lFileName <> '') and FileExists(lFileName) then
        Exit(lFileName);
    end;
  end;

  { Для нового визуального контрола выбираем не первую строку вообще,
    а первый реально существующий и читаемый ресурс. }
  for I := 0 to fComponent.Images.Count - 1 do
  begin
    lFileName := Trim(fComponent.Images.ValueFromIndex[I]);
    if (lFileName <> '') and FileExists(lFileName) then
      Exit(lFileName);
  end;
end;


procedure TRecorderImageView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderImageComponent(AComponent);
  fHasRevision := False;
  if fEditMode then
    SelectFile(PreviewFileName(ATagRegistry))
  else if (fComponent <> nil) and (fComponent.Images.Count > 0) and
    (Trim(fComponent.TagName) = '') then
    SelectFile(fComponent.Images.ValueFromIndex[0])
  else
    SelectFile('');
end;

procedure TRecorderImageView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lTag: TRecorderTag;
begin
  if fComponent = nil then
    Exit;
  if fEditMode then
  begin
    SelectFile(PreviewFileName(ATagRegistry));
    Exit;
  end;
  if Trim(fComponent.TagName) = '' then
  begin
    if fComponent.Images.Count > 0 then
      SelectFile(fComponent.Images.ValueFromIndex[0])
    else
      SelectFile('');
    Exit;
  end;
  lTag := nil;
  if ATagRegistry <> nil then
  begin
    if fComponent.TagId <> 0 then
      lTag := ATagRegistry.FindById(fComponent.TagId);
    if lTag = nil then
      lTag := ATagRegistry.FindByName(fComponent.TagName);
  end;
  if (lTag = nil) or (lTag.SignalBuffer.Count = 0) then
  begin
    SelectFile('');
    Exit;
  end;
  if fHasRevision and (fLastRevision = lTag.SignalBuffer.Revision) then
    Exit;
  fLastRevision := lTag.SignalBuffer.Revision;
  fHasRevision := True;
  SelectFile(FileNameForValue(lTag.SignalBuffer.LatestValue));
end;

function TRecorderImageView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

initialization
  // Регистрация визуальных контролов мнемосхем
  TRecorderVisualControlRegistry.RegisterControl(TRecorderStaticTextComponent, TRecorderStaticTextView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderTagValueComponent, TRecorderTagValueView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderImageComponent, TRecorderImageView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderTrendComponent, TRecorderTrendView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderOscillogramComponent, TRecorderOglOscillogram);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderSpectrumComponent, TRecorderSpectrumView);

finalization
  TRecorderVisualControlRegistry.ClearRegistry;

end.
