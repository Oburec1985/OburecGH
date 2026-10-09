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
  Classes, SysUtils, Math, Controls, ExtCtrls, Graphics, StdCtrls, Buttons,
  BGRABitmap, BGRABitmapTypes, BGRASVG,
  uOglChart, uRecorderFormModel, uRecorderTags, uRecorderAlarms,
  uRecorderSvgRenderer;

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
    fAppliedFont: TRecorderFontSnapshot;
    fHasAppliedFont: Boolean;
    procedure ApplyFont;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

  TRecorderButtonView = class(TSpeedButton, IVForm)
  private
    fComponent: TRecorderButtonComponent;
    fTagRegistry: TRecorderTagRegistry;
    fPulseTimer: TTimer;
    fEditMode: Boolean;
    fPressedGlyph: TBitmap;
    fReleasedGlyph: TBitmap;
    fVisualPressed: Boolean;
    fTogglePressed: Boolean;
    function CurrentStateGlyph: TBitmap;
    procedure LoadStateGlyph(const AFileName: string; ABitmap: TBitmap);
    procedure SetVisualPressed(AValue: Boolean);
    function TryReadTagPressed(out APressed: Boolean): Boolean;
    function TagIsPressed: Boolean;
    procedure ButtonClick(Sender: TObject);
    procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PulseTimerTimer(Sender: TObject);
    procedure Publish(AValue: Double);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    property EditMode: Boolean read fEditMode write fEditMode;
  end;

  TRecorderInputFieldView = class(TEdit, IVForm)
  private
    fComponent: TRecorderInputFieldComponent;
    fTagRegistry: TRecorderTagRegistry;
    fLastRevision: QWord;
    fEditing: Boolean;
    fUpdatingText: Boolean;
    fEditMode: Boolean;
    procedure CommitValue(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure NumericKeyPress(Sender: TObject; var Key: Char);
  public
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    property EditMode: Boolean read fEditMode write fEditMode;
  end;

  { TRecorderTagValueView
    Визуальное представление цифрового индикатора значения тега }
  TRecorderTagValueView = class(TPanel, IVForm)
  private
    fComponent: TRecorderTagValueComponent;
    fAlarmEngine: IRecorderAlarmEngine;
    fLastTag: TRecorderTag;
    fLastRevision: QWord;
    fHasRevision: Boolean;
    fLastLabel: string;
    fAppliedFont: TRecorderFontSnapshot;
    fHasAppliedFont: Boolean;
    procedure ApplyFont;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    property AlarmEngine: IRecorderAlarmEngine read fAlarmEngine write fAlarmEngine;
  end;

  TRecorderVibrationEstimateView = class(TPanel, IVForm)
  private
    fComponent: TRecorderVibrationEstimateComponent;
    fTagRegistry: TRecorderTagRegistry;
    fValueLabel: TLabel;
    fPreviousButton: TSpeedButton;
    fNextButton: TSpeedButton;
    fQuantityButton: TSpeedButton;
    fUnitButton: TSpeedButton;
    fLastFrameIndex: Int64;
    procedure LayoutSelectorButtons;
    procedure StepBand(ADelta: Integer);
    procedure UpdateSelectorButtons;
    procedure PreviousBandClick(Sender: TObject);
    procedure NextBandClick(Sender: TObject);
    procedure QuantityClick(Sender: TObject);
    procedure UnitClick(Sender: TObject);
    procedure ChildMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

  { Оконный контрол обязателен: TGraphicControl рисует на Canvas родителя,
    поэтому design-time изменение Bevel/Bounds панели может стереть картинку. }
  TRecorderImageView = class(TCustomControl, IVForm)
  private
    fComponent: TRecorderImageComponent;
    fAlarmEngine: IRecorderAlarmEngine;
    fTagRegistry: TRecorderTagRegistry;
    fPicture: TPicture;
    fSvg: TBGRASVG;
    fSvgBitmap: TBGRABitmap;
    fSvgLoaded: Boolean;
    fLoadedImageRevision: QWord;
    fCurrentFileName: string;
    fLastRevision: QWord;
    fHasRevision: Boolean;
    fEditMode: Boolean;
    fLastPaintLogMode: Integer;
    fSvgParameterSignature: string;
    fSvgTemplateSource: string;
    fSvgBindingTags: TList;
    fSvgBindingRevisions: TList;
    fSvgResolvedValues: TStringList;
    function FileNameForValue(AValue: Double): string;
    function PreviewFileName(ATagRegistry: TRecorderTagRegistry): string;
    procedure SelectFile(const AFileName: string; AForceReload: Boolean = False);
    function BuildParameterizedSvg(out ASignature: string): string;
    function SvgParameterSignature: string;
    function BindingValue(AIndex: Integer; ABinding: TRecorderSvgTagBinding;
      out AValue: string): Boolean;
    procedure RefreshSvgParameters;
    procedure ResolveSvgBindingTags;
    function SvgInputsChanged: Boolean;
    procedure RememberSvgInputRevisions;
    function SvgBindingInputToken(AIndex: Integer;
      ABinding: TRecorderSvgTagBinding): QWord;
    function ResolveNormalizedSvgValue(AIndex: Integer;
      ABinding: TRecorderSvgTagBinding; out AValue: string): Boolean;
    function HasImage: Boolean;
    procedure DrawImage;
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
    property AlarmEngine: IRecorderAlarmEngine read fAlarmEngine write fAlarmEngine;
    property EditMode: Boolean read fEditMode write SetEditMode;
  end;

implementation

uses
  uOglChartTrend,
  uRecorderOglOscillogramView,
  uRecorderTrendView,
  uRecorderSpectrumView,
  uRecorderLissajousView,
  uRecorderSpectrumRuntime,
  uRecorderSpectrumEngine,
  uRecorderVibrationEstimate,
  uRecorderDonutView,
  uRecorderTagRefs,
  uRecorderSvgParameters,
  uRecorderDebugLog,
  uSharedNumberFormat;

function RecorderSvgValueKindIsColor(AKind: TRecorderSvgValueKind): Boolean;
begin
  Result := AKind in [rsvHighAlarmColor, rsvHighWarningColor,
    rsvLowWarningColor, rsvLowAlarmColor, rsvActiveAlarmColorWhite,
    rsvActiveAlarmColorTransparent, rsvActiveAlarmColorCurrent];
end;

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

{ TRecorderButtonView }

constructor TRecorderButtonView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fPressedGlyph := TBitmap.Create;
  fReleasedGlyph := TBitmap.Create;
  GroupIndex := 1;
  AllowAllUp := True;
end;

procedure TRecorderButtonView.LoadStateGlyph(const AFileName: string;
  ABitmap: TBitmap);
var
  I: Integer;
  lPicture: TPicture;
  lWidth, lHeight: Integer;
begin
  ABitmap.Clear;
  if (Trim(AFileName) = '') or not FileExists(AFileName) then Exit;
  lPicture := TPicture.Create;
  try
    try
      lPicture.LoadFromFile(AFileName);
      if (lPicture.Graphic = nil) or lPicture.Graphic.Empty then Exit;
      lWidth := Max(1, Width - 8);
      lHeight := Max(1, Height - 8);
      ABitmap.SetSize(lWidth, lHeight);
      ABitmap.Canvas.Brush.Color := clBtnFace;
      ABitmap.Canvas.FillRect(Rect(0, 0, lWidth, lHeight));
      ABitmap.Canvas.StretchDraw(Rect(0, 0, lWidth, lHeight), lPicture.Graphic);
    except
      ABitmap.Clear;
    end;
  finally
    lPicture.Free;
  end;
end;

function TRecorderButtonView.CurrentStateGlyph: TBitmap;
begin
  if fVisualPressed then
    Result := fPressedGlyph
  else
    Result := fReleasedGlyph;
end;

procedure TRecorderButtonView.Paint;
var
  lBitmap: TBitmap;
begin
  lBitmap := CurrentStateGlyph;
  if (lBitmap = nil) or lBitmap.Empty then
  begin
    inherited Paint;
    Exit;
  end;

  { Изображение состояния занимает весь компонент. Вызов inherited здесь
    намеренно пропущен: он добавляет поля Glyph и рисует Caption. }
  Canvas.StretchDraw(ClientRect, lBitmap);
end;

function TRecorderButtonView.TryReadTagPressed(out APressed: Boolean): Boolean;
var
  lTag: TRecorderTag;
  lValue: Double;
begin
  APressed := False;
  Result := False;
  if (fComponent = nil) or (fTagRegistry = nil) then
    Exit;
  lTag := fTagRegistry.FindByName(fComponent.TagName);
  if (lTag = nil) or (lTag.SignalBuffer.Count <= 0) then
    Exit;
  lValue := lTag.SignalBuffer.LatestValue;
  APressed := Abs(lValue - fComponent.PressedValue) <=
    Abs(lValue - fComponent.ReleasedValue);
  Result := True;
end;

function TRecorderButtonView.TagIsPressed: Boolean;
begin
  if not TryReadTagPressed(Result) then
    Result := False;
end;

procedure TRecorderInputFieldView.Configure(
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderInputFieldComponent(AComponent);
  fTagRegistry := ATagRegistry;
  fLastRevision := 0;
  fEditing := False;
  OnChange := @EditChange;
  OnEditingDone := @CommitValue;
  OnKeyPress := @NumericKeyPress;
  RefreshControl(ATagRegistry, 0.0);
end;

procedure TRecorderInputFieldView.EditChange(Sender: TObject);
begin
  if not fUpdatingText then
    fEditing := True;
end;

procedure TRecorderInputFieldView.NumericKeyPress(Sender: TObject;
  var Key: Char);
var
  I: Integer;
  lCandidate: string;
  lHasSeparator: Boolean;
begin
  if Key in [#10, #13] then
  begin
    { После повторного hide/show GTK может на OnChange кратковременно вернуть
      Focused=False. Enter всё равно является явным подтверждением текста. }
    fEditing := True;
    CommitValue(Sender);
    Key := #0;
    Exit;
  end;
  if Key < #32 then
    Exit;
  lCandidate := Copy(Text, 1, SelStart) + Key +
    Copy(Text, SelStart + SelLength + 1, MaxInt);
  lHasSeparator := False;
  for I := 1 to Length(lCandidate) do
    case lCandidate[I] of
      '0'..'9': ;
      '+', '-': if I <> 1 then Key := #0;
      '.', ',': if lHasSeparator then Key := #0
        else lHasSeparator := True;
    else
      Key := #0;
    end;
end;

procedure TRecorderInputFieldView.CommitValue(Sender: TObject);
var
  lTag: TRecorderTag;
  lValue: Double;
  lText: string;
begin
  if not fEditing or (fComponent = nil) or (fTagRegistry = nil) then
    Exit;
  lText := Trim(Text);
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  fEditing := False;
  if not TryStrToFloat(lText, lValue) then
  begin
    fUpdatingText := True;
    try
      Text := '';
    finally
      fUpdatingText := False;
    end;
    fLastRevision := 0;
    RefreshControl(fTagRegistry, 0.0);
    Exit;
  end;
  lTag := RecorderResolveTag(fTagRegistry, fComponent.TagId,
    fComponent.TagName);
  if (lTag <> nil) and lTag.ExternalWriteAllowed then
  begin
    fTagRegistry.PublishExternalValue(lTag, lValue);
    RecorderDebugLog(Format('[INPUT-FIELD] committed component=%s tag=%s value=%s',
      [fComponent.Name, lTag.Name, FloatToStr(lValue)]));
  end
  else
    RecorderDebugLog(Format(
      '[INPUT-FIELD] commit rejected component=%s tag=%s resolved=%s writable=%s',
      [fComponent.Name, fComponent.TagName, BoolToStr(lTag <> nil, True),
       BoolToStr((lTag <> nil) and lTag.ExternalWriteAllowed, True)]));
  fLastRevision := 0;
  RefreshControl(fTagRegistry, 0.0);
end;

procedure TRecorderInputFieldView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
var
  lTag: TRecorderTag;
begin
  if fEditing or (fComponent = nil) then
    Exit;
  lTag := RecorderResolveTag(ATagRegistry, fComponent.TagId,
    fComponent.TagName);
  Enabled := fEditMode or ((lTag <> nil) and lTag.ExternalWriteAllowed);
  ReadOnly := fEditMode;
  if (lTag = nil) or (lTag.SignalBuffer.Count = 0) or
    (lTag.SignalBuffer.Revision = fLastRevision) then
    Exit;
  fLastRevision := lTag.SignalBuffer.Revision;
  fUpdatingText := True;
  try
    Text := FormatFloat(fComponent.DisplayFormat, lTag.SignalBuffer.LatestValue);
  finally
    fUpdatingText := False;
  end;
end;

function TRecorderInputFieldView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

procedure TRecorderButtonView.SetVisualPressed(AValue: Boolean);
begin
  fVisualPressed := AValue;
  Down := AValue;
  Glyph.Clear;
  Invalidate;
end;

procedure TRecorderButtonView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderButtonComponent(AComponent);
  fTagRegistry := ATagRegistry;
  Caption := fComponent.Caption;
  LoadStateGlyph(fComponent.PressedImageFileName, fPressedGlyph);
  LoadStateGlyph(fComponent.ReleasedImageFileName, fReleasedGlyph);
  fTogglePressed := TagIsPressed;
  SetVisualPressed(fTogglePressed);
  if not fEditMode then
  begin
    OnClick := @ButtonClick;
    OnMouseDown := @ButtonMouseDown;
    OnMouseUp := @ButtonMouseUp;
  end;
end;

destructor TRecorderButtonView.Destroy;
begin
  FreeAndNil(fPulseTimer);
  FreeAndNil(fPressedGlyph);
  FreeAndNil(fReleasedGlyph);
  inherited Destroy;
end;

procedure TRecorderButtonView.Publish(AValue: Double);
begin
  if fEditMode or (fComponent = nil) or (fTagRegistry = nil) or
    (Trim(fComponent.TagName) = '') then Exit;
  fTagRegistry.PublishExternalValue(fComponent.TagName, AValue);
end;

procedure TRecorderButtonView.ButtonClick(Sender: TObject);
begin
  if fEditMode or (fComponent = nil) or (fComponent.Behavior <> rbbToggle) then Exit;
  fTogglePressed := not fTogglePressed;
  SetVisualPressed(fTogglePressed);
  if fTogglePressed then
  begin
    Publish(fComponent.PressedValue);
  end
  else
  begin
    Publish(fComponent.ReleasedValue)
  end;
end;

procedure TRecorderButtonView.ButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if fEditMode or (Button <> mbLeft) or (fComponent = nil) then Exit;
  if fComponent.Behavior = rbbHold then
  begin
    SetVisualPressed(True);
    Publish(fComponent.PressedValue);
  end
  else if fComponent.Behavior = rbbPulse then
  begin
    SetVisualPressed(True);
    Publish(fComponent.PressedValue);
    if fPulseTimer = nil then
    begin
      fPulseTimer := TTimer.Create(Self);
      fPulseTimer.OnTimer := @PulseTimerTimer;
    end;
    fPulseTimer.Interval := Max(1, fComponent.PulseDurationMs);
    fPulseTimer.Enabled := True;
  end;
end;

procedure TRecorderButtonView.ButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (not fEditMode) and (Button = mbLeft) and (fComponent <> nil) and
    (fComponent.Behavior = rbbHold) then
  begin
    SetVisualPressed(False);
    Publish(fComponent.ReleasedValue);
  end;
end;

procedure TRecorderButtonView.PulseTimerTimer(Sender: TObject);
begin
  fPulseTimer.Enabled := False;
  SetVisualPressed(False);
  if fComponent <> nil then Publish(fComponent.ReleasedValue);
end;

procedure TRecorderButtonView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lPressed: Boolean;
begin
  if ATagRegistry <> nil then fTagRegistry := ATagRegistry;
  if (fComponent <> nil) and (fComponent.Behavior = rbbToggle) then
  begin
    if TryReadTagPressed(lPressed) then
      fTogglePressed := lPressed;
    SetVisualPressed(fTogglePressed);
    Exit;
  end;
  SetVisualPressed(TagIsPressed);
end;

function TRecorderButtonView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

{ TRecorderStaticTextView }

procedure TRecorderStaticTextView.ApplyFont;
var
  lFont: TRecorderFontSnapshot;
begin
  fComponent.GetFontSnapshot(lFont);
  if fHasAppliedFont and (fAppliedFont.Name = lFont.Name) and
     (fAppliedFont.Size = lFont.Size) and (fAppliedFont.Color = lFont.Color) and
     (fAppliedFont.Bold = lFont.Bold) and (fAppliedFont.Italic = lFont.Italic) then
    Exit;
  Font.Name := lFont.Name;
  if lFont.Size > 0 then Font.Size := lFont.Size;
  Font.Color := TColor(lFont.Color);
  Font.Style := [];
  if lFont.Bold then Font.Style := Font.Style + [fsBold];
  if lFont.Italic then Font.Style := Font.Style + [fsItalic];
  fAppliedFont := lFont;
  fHasAppliedFont := True;
end;

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
  fHasAppliedFont := False;
  Caption := fComponent.Text;
  Alignment := taLeftJustify;
  Color := clWhite;
  
  ApplyFont;
end;

procedure TRecorderStaticTextView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
begin
  ApplyFont;
end;

function TRecorderStaticTextView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

{ TRecorderTagValueView }

procedure TRecorderTagValueView.ApplyFont;
var
  lFont: TRecorderFontSnapshot;
begin
  fComponent.GetFontSnapshot(lFont);
  if fHasAppliedFont and (fAppliedFont.Name = lFont.Name) and
     (fAppliedFont.Size = lFont.Size) and (fAppliedFont.Color = lFont.Color) and
     (fAppliedFont.Bold = lFont.Bold) and (fAppliedFont.Italic = lFont.Italic) then
    Exit;
  Font.Name := lFont.Name;
  if lFont.Size > 0 then Font.Size := lFont.Size;
  Font.Color := TColor(lFont.Color);
  Font.Style := [];
  if lFont.Bold then Font.Style := Font.Style + [fsBold];
  if lFont.Italic then Font.Style := Font.Style + [fsItalic];
  fAppliedFont := lFont;
  fHasAppliedFont := True;
end;

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
  fHasAppliedFont := False;
  fLastTag := nil;
  fLastRevision := 0;
  fHasRevision := False;
  fLastLabel := '';
  Alignment := taCenter;
  WordWrap := True;
  ApplyFont;
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
  lAlarmColor: LongInt;
begin
  if not IsVisible then
    Exit;

  if (fComponent = nil) or (ATagRegistry = nil) then
    Exit;
  ApplyFont;
    
  lTag := RecorderResolveTag(ATagRegistry, fComponent.TagId, fComponent.TagName);
  if lTag <> nil then
    RecorderBindComponentTag(fComponent, lTag);
  if fComponent.UseSourceTagName then
  begin
    if lTag <> nil then
      lTagName := lTag.Name
    else
      lTagName := fComponent.TagName;
  end
  else
    lTagName := fComponent.Caption;
  if (lTag <> nil) and fHasRevision and (fLastTag = lTag) and
    (fLastRevision = lTag.SignalBuffer.Revision) and
    (fLastLabel = lTagName) then
    Exit;
  fLastTag := lTag;
  if lTag <> nil then
    fLastRevision := lTag.SignalBuffer.Revision
  else
    fLastRevision := 0;
  fHasRevision := True;
  fLastLabel := lTagName;
  lAlarmColor := 0;
  if (lTag = nil) or (lTag.SignalBuffer.Count = 0) then
    lAlarmColor := $808080
  else if fAlarmEngine <> nil then
    lAlarmColor := fAlarmEngine.GetTagAlarmColor(lTag);
  if lAlarmColor <> 0 then
    Color := TColor(lAlarmColor)
  else
    Color := $00F2F8FF;
  if RecorderTryReadScalarValue(lTag,fComponent.UseDefaultEstimate,
    fComponent.EstimateKind,lValue) then
  begin
    lValueStr := FormatFloat(fComponent.DisplayFormat, lValue);
  end
  else
    lValueStr := '0.0';

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

{ TRecorderVibrationEstimateView }

constructor TRecorderVibrationEstimateView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  ParentBackground := False;
  Color := $00F2F8FF;
  Alignment := taCenter;
  WordWrap := True;
  fValueLabel := TLabel.Create(Self);
  fValueLabel.Parent := Self;
  fValueLabel.Align := alClient;
  fValueLabel.Alignment := taCenter;
  fValueLabel.Layout := tlCenter;
  fValueLabel.WordWrap := True;
  fValueLabel.BorderSpacing.Left := 24;
  fValueLabel.BorderSpacing.Right := 24;
  fValueLabel.BorderSpacing.Bottom := 30;
  fValueLabel.OnMouseUp := @ChildMouseUp;
  fPreviousButton := TSpeedButton.Create(Self);
  fPreviousButton.Parent := Self;
  fPreviousButton.Caption := '<';
  fPreviousButton.Align := alLeft;
  fPreviousButton.Width := 22;
  fPreviousButton.OnClick := @PreviousBandClick;
  fPreviousButton.OnMouseUp := @ChildMouseUp;
  fNextButton := TSpeedButton.Create(Self);
  fNextButton.Parent := Self;
  fNextButton.Caption := '>';
  fNextButton.Align := alRight;
  fNextButton.Width := 22;
  fNextButton.OnClick := @NextBandClick;
  fNextButton.OnMouseUp := @ChildMouseUp;
  fQuantityButton := TSpeedButton.Create(Self);
  fQuantityButton.Parent := Self;
  fQuantityButton.Hint := 'Переключить тип виброоценки';
  fQuantityButton.ShowHint := True;
  fQuantityButton.OnClick := @QuantityClick;
  fQuantityButton.OnMouseUp := @ChildMouseUp;
  fUnitButton := TSpeedButton.Create(Self);
  fUnitButton.Parent := Self;
  fUnitButton.Hint := 'Переключить единицу измерения';
  fUnitButton.ShowHint := True;
  fUnitButton.OnClick := @UnitClick;
  fUnitButton.OnMouseUp := @ChildMouseUp;
end;

procedure TRecorderVibrationEstimateView.ChildMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
begin
  if (Button <> mbRight) or (not Assigned(OnMouseUp)) or
    (not (Sender is TControl)) then
    Exit;
  lPoint := ScreenToClient(TControl(Sender).ClientToScreen(Point(X, Y)));
  OnMouseUp(Self, Button, Shift, lPoint.X, lPoint.Y);
end;

procedure TRecorderVibrationEstimateView.Configure(
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
var
  lFont: TRecorderFontSnapshot;
begin
  fComponent := TRecorderVibrationEstimateComponent(AComponent);
  fTagRegistry := ATagRegistry;
  fComponent.GetFontSnapshot(lFont);
  fValueLabel.Font.Name := lFont.Name;
  fValueLabel.Font.Size := lFont.Size;
  fValueLabel.Font.Color := lFont.Color;
  fValueLabel.Font.Style := [];
  if lFont.Bold then
    fValueLabel.Font.Style := fValueLabel.Font.Style + [fsBold];
  if lFont.Italic then
    fValueLabel.Font.Style := fValueLabel.Font.Style + [fsItalic];
  fLastFrameIndex := -1;
  UpdateSelectorButtons;
  RefreshControl(ATagRegistry, 0.0);
end;

procedure TRecorderVibrationEstimateView.Resize;
begin
  inherited Resize;
  LayoutSelectorButtons;
end;

procedure TRecorderVibrationEstimateView.LayoutSelectorButtons;
var
  lButtonHeight, lQuantityWidth, lUnitWidth, lBottom: Integer;
begin
  { Text measurement through Canvas may allocate this WinControl handle on
    Win32. During construction the view is not attached to the component
    panel yet, so creating its HWND would fail with "has no parent window". }
  if (Parent = nil) or (fQuantityButton = nil) or (fUnitButton = nil) then
    Exit;
  lButtonHeight := Max(26, Canvas.TextHeight('Mg') + 10);
  lQuantityWidth := Max(48, Canvas.TextWidth(fQuantityButton.Caption) + 18);
  lUnitWidth := Max(56, Canvas.TextWidth(fUnitButton.Caption) + 18);
  lBottom := Max(1, ClientHeight - lButtonHeight - 2);
  if fQuantityButton <> nil then
    fQuantityButton.SetBounds(24, lBottom, lQuantityWidth, lButtonHeight);
  if fUnitButton <> nil then
    fUnitButton.SetBounds(ClientWidth - 24 - lUnitWidth, lBottom,
      lUnitWidth, lButtonHeight);
end;

procedure TRecorderVibrationEstimateView.UpdateSelectorButtons;
begin
  if (fComponent = nil) or (fQuantityButton = nil) or
    (fUnitButton = nil) then Exit;
  case fComponent.Quantity of
    rvqAcceleration: fQuantityButton.Caption := 'A';
    rvqVelocity: fQuantityButton.Caption := 'V';
    rvqDisplacement: fQuantityButton.Caption := 'S';
  else
    fQuantityButton.Caption := 'F';
  end;
  fUnitButton.Caption := fComponent.OutputUnit;
  LayoutSelectorButtons;
end;

procedure TRecorderVibrationEstimateView.StepBand(ADelta: Integer);
var
  I, lCurrent, lCount, lNext: Integer;
begin
  if (fComponent = nil) or (fTagRegistry = nil) or
    (fTagRegistry.FrequencyBands = nil) then Exit;
  lCount := fTagRegistry.FrequencyBands.BandCount;
  lCurrent := -1;
  for I := 0 to lCount - 1 do
    if SameText(fTagRegistry.FrequencyBands.Bands[I].Name,
      fComponent.BandName) then
    begin
      lCurrent := I;
      Break;
    end;
  { Position -1 is the full spectrum, named bands follow it. }
  lNext := lCurrent + ADelta;
  if lNext < -1 then lNext := lCount - 1;
  if lNext >= lCount then lNext := -1;
  if lNext < 0 then
    fComponent.BandName := ''
  else
    fComponent.BandName := fTagRegistry.FrequencyBands.Bands[lNext].Name;
  fLastFrameIndex := -1;
  RefreshControl(fTagRegistry, 0.0);
end;

procedure TRecorderVibrationEstimateView.PreviousBandClick(Sender: TObject);
begin
  StepBand(-1);
end;

procedure TRecorderVibrationEstimateView.NextBandClick(Sender: TObject);
begin
  StepBand(1);
end;

procedure TRecorderVibrationEstimateView.QuantityClick(Sender: TObject);
begin
  if fComponent = nil then Exit;
  if fComponent.Quantity = High(TRecorderVibrationQuantity) then
    fComponent.Quantity := Low(TRecorderVibrationQuantity)
  else
    fComponent.Quantity := Succ(fComponent.Quantity);
  fComponent.OutputUnit := RecorderVibrationDefaultUnit(fComponent.Quantity);
  fLastFrameIndex := -1;
  UpdateSelectorButtons;
  RefreshControl(fTagRegistry, 0.0);
end;

procedure TRecorderVibrationEstimateView.UnitClick(Sender: TObject);
begin
  if fComponent = nil then Exit;
  case fComponent.Quantity of
    rvqAcceleration:
      if SameText(fComponent.OutputUnit, 'm/s2') then fComponent.OutputUnit := 'g'
      else if SameText(fComponent.OutputUnit, 'g') then fComponent.OutputUnit := 'mm/s2'
      else fComponent.OutputUnit := 'm/s2';
    rvqVelocity:
      if SameText(fComponent.OutputUnit, 'mm/s') then fComponent.OutputUnit := 'm/s'
      else if SameText(fComponent.OutputUnit, 'm/s') then fComponent.OutputUnit := 'um/s'
      else fComponent.OutputUnit := 'mm/s';
    rvqDisplacement:
      if SameText(fComponent.OutputUnit, 'um') then fComponent.OutputUnit := 'mm'
      else if SameText(fComponent.OutputUnit, 'mm') then fComponent.OutputUnit := 'm'
      else fComponent.OutputUnit := 'um';
    rvqDominantFrequency:
      if SameText(fComponent.OutputUnit, 'Hz') then fComponent.OutputUnit := 'kHz'
      else fComponent.OutputUnit := 'Hz';
  end;
  fLastFrameIndex := -1;
  UpdateSelectorButtons;
  RefreshControl(fTagRegistry, 0.0);
end;

procedure TRecorderVibrationEstimateView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
var
  lTag: TRecorderTag;
  lFrame: TRecorderSpectrumFrame;
  lManager: TRecorderSpectrumRuntimeManager;
  lLabelText, lBandText, lError, lValueText, lFrequencyText: string;
  lBandIndex, I: Integer;
  lValue, lDominantFrequency: Double;
  lSourceUnit: string;

  function ValueWithUnit(const AValueText, AUnit: string): string;
  const
    CNoBreakSpace = #194#160;
  begin
    Result := AValueText;
    if Trim(AUnit) <> '' then
      Result := Result + CNoBreakSpace + Trim(AUnit);
  end;

  function BandCaption(const AName: string; const AF1, AF2: Double): string;
  begin
    if Max(AF1, AF2) > 10000.0 then
      Result := Format('%s: %s-%s кГц', [AName,
        FormatFloat('0.0', AF1 / 1000.0),
        FormatFloat('0.0', AF2 / 1000.0)])
    else
      Result := Format('%s: %s-%s Гц', [AName,
        FormatSignificant(AF1), FormatSignificant(AF2)]);
  end;

  function EffectiveSourceUnit: string;
  var
    lCalibration: TRecorderCalibration;
    lCalibrationIndex: Integer;
  begin
    Result := lTag.UnitName;
    if Trim(lTag.SensorCalibrationName) <> '' then
    begin
      lCalibration := ATagRegistry.FindCalibrationByName(
        lTag.SensorCalibrationName);
      if (lCalibration <> nil) and (Trim(lCalibration.UnitOut) <> '') then
        Result := lCalibration.UnitOut;
    end;
    if lTag.CalibrationNames = nil then Exit;
    for lCalibrationIndex := 0 to lTag.CalibrationNames.Count - 1 do
    begin
      lCalibration := ATagRegistry.FindCalibrationByName(
        lTag.CalibrationNames[lCalibrationIndex]);
      if (lCalibration <> nil) and (Trim(lCalibration.UnitOut) <> '') then
        Result := lCalibration.UnitOut;
    end;
  end;
begin
  if (fComponent = nil) or (ATagRegistry = nil) then Exit;
  fTagRegistry := ATagRegistry;
  lTag := RecorderResolveTag(ATagRegistry, fComponent.TagId, fComponent.TagName);
  if lTag <> nil then RecorderBindComponentTag(fComponent, lTag);
  if fComponent.UseSourceTagName and (lTag <> nil) then
    lLabelText := lTag.Name
  else
    lLabelText := fComponent.Caption;
  lManager := TRecorderSpectrumRuntimeManager.Instance;
  if lTag = nil then
  begin
    fValueLabel.Caption := lLabelText + LineEnding + 'тег не найден';
    Exit;
  end;
  if lManager = nil then
  begin
    fValueLabel.Caption := lLabelText + LineEnding + 'спектр недоступен';
    Exit;
  end;
  if not lManager.HasInputTag(lTag.Name) then
  begin
    fValueLabel.Caption := lLabelText + LineEnding + 'нет входа спектра';
    Exit;
  end;
  if not lManager.GetLastFrame(lTag.Name, lFrame) then
  begin
    fValueLabel.Caption := lLabelText + LineEnding + 'ожидание спектра';
    Exit;
  end;
  lBandIndex := -1;
  lBandText := BandCaption('вся полоса', 0.0,
    Max(0.0, (Length(lFrame.RectRms) - 1) * lFrame.FrequencyStepHz));
  if Trim(fComponent.BandName) <> '' then
    for I := 0 to Length(lFrame.Bands) - 1 do
      if SameText(lFrame.Bands[I].BandName, fComponent.BandName) then
      begin
        lBandIndex := I;
        lBandText := BandCaption(lFrame.Bands[I].BandName,
          lFrame.Bands[I].F1, lFrame.Bands[I].F2);
        Break;
      end;
  lLabelText := lLabelText + ' [' + lBandText + ']';
  if (fLastFrameIndex = lFrame.FrameIndex) and
    (Pos(lBandText, fValueLabel.Caption) > 0) then Exit;
  fLastFrameIndex := lFrame.FrameIndex;
  lSourceUnit := EffectiveSourceUnit;
  if RecorderTryCalculateVibrationEstimate(lFrame, lSourceUnit,
    fComponent.Quantity, lBandIndex, fComponent.OutputUnit, lValue, lError) then
  begin
    if fComponent.AmplitudeMode and
      (fComponent.Quantity <> rvqDominantFrequency) then
      lValue := lValue * Sqrt(2.0);
    if fComponent.Quantity = rvqDominantFrequency then
      lValueText := FormatSignificant(lValue)
    else
      lValueText := FormatFloat(fComponent.DisplayFormat, lValue);
    lValueText := ValueWithUnit(lValueText, fComponent.OutputUnit);
    if (fComponent.Quantity <> rvqDominantFrequency) and
      RecorderTryGetDominantFrequency(lFrame, lBandIndex, 'Hz',
        lDominantFrequency, lError) then
    begin
      lFrequencyText := 'F:' + #194#160 +
        ValueWithUnit(FormatSignificant(lDominantFrequency), 'Hz');
      lValueText := lValueText + '  ' + lFrequencyText;
    end;
    if fComponent.Quantity <> rvqDominantFrequency then
      if fComponent.AmplitudeMode then
        lValueText := 'A: ' + lValueText
      else
        lValueText := 'СКО: ' + lValueText;
    fValueLabel.Caption := lLabelText + LineEnding + lValueText;
    Hint := '';
  end
  else
  begin
    fValueLabel.Caption := lLabelText + LineEnding + lError;
    Hint := lError;
    ShowHint := True;
  end;
end;

function TRecorderVibrationEstimateView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

{ TRecorderImageView }

constructor TRecorderImageView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fPicture := TPicture.Create;
  fSvg := TBGRASVG.Create;
  fSvgBitmap := TBGRABitmap.Create;
  fSvgBindingTags := TList.Create;
  fSvgBindingRevisions := TList.Create;
  fSvgResolvedValues := TStringList.Create;
  fLastPaintLogMode := -1;
end;

destructor TRecorderImageView.Destroy;
begin
  fSvgResolvedValues.Free;
  fSvgBindingRevisions.Free;
  fSvgBindingTags.Free;
  fSvgBitmap.Free;
  fSvg.Free;
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

procedure TRecorderImageView.SelectFile(const AFileName: string;
  AForceReload: Boolean);
var
  lSignature: string;
  lSvgSource: string;
  lValidationError: string;
begin
  if (not AForceReload) and SameFileName(fCurrentFileName, AFileName) and
    ((AFileName = '') or HasImage) then
    Exit;
  fCurrentFileName := AFileName;
  fPicture.Clear;
  fSvgLoaded := False;
  fSvgTemplateSource := '';
  fSvgBitmap.SetSize(0, 0);
  if (AFileName <> '') and FileExists(AFileName) then
    try
      if SameText(ExtractFileExt(AFileName), '.svg') then
      begin
        fSvgTemplateSource := LoadSvgText(AFileName);
        if not ValidateSvgParameterTemplate(fSvgTemplateSource,
          lValidationError) then
        begin
          RecorderDebugLog('[IMAGE] SVG template rejected: ' +
            lValidationError);
          fSvgTemplateSource := '';
          fSvgLoaded := False;
          Exit;
        end;
        ResolveSvgBindingTags;
        lSvgSource := BuildParameterizedSvg(lSignature);
        if lSvgSource <> '' then
        begin
          fSvg.AsUTF8String := lSvgSource;
          fSvgParameterSignature := lSignature;
          RememberSvgInputRevisions;
        end
        else
          fSvg.AsUTF8String := fSvgTemplateSource;
        fSvgLoaded := True;
      end
      else
        fPicture.LoadFromFile(AFileName);
    except
      on E: Exception do
      begin
        RecorderDebugLog(Format(
          '[IMAGE] load failed file="%s" error="%s"', [AFileName, E.Message]));
        fPicture.Clear;
        fSvgLoaded := False;
      end;
    end;
  RecorderDebugLog(Format(
    '[IMAGE] select file="%s" exists=%s loaded=%s',
    [AFileName, BoolToStr(FileExists(AFileName), True),
     BoolToStr(HasImage, True)]));
  fLastPaintLogMode := -1;
  Invalidate;
end;

procedure TRecorderImageView.ResolveSvgBindingTags;
var
  I: Integer;
  lBinding: TRecorderSvgTagBinding;
  lTag: TRecorderTag;
begin
  fSvgBindingTags.Clear;
  fSvgBindingRevisions.Clear;
  fSvgResolvedValues.Clear;
  if fComponent = nil then
    Exit;
  for I := 0 to fComponent.SvgBindingCount - 1 do
  begin
    lBinding := fComponent.SvgBindings[I];
    lTag:=RecorderResolveTagReference(fTagRegistry,lBinding.TagId,
      lBinding.TagName);
    fSvgBindingTags.Add(lTag);
    fSvgBindingRevisions.Add(Pointer(PtrUInt(0)));
  end;
end;

function TRecorderImageView.SvgInputsChanged: Boolean;
var
  I: Integer;
  lRevision: QWord;
begin
  if fSvgBindingRevisions.Count <> fSvgBindingTags.Count then
    Exit(True);
  for I := 0 to fSvgBindingTags.Count - 1 do
  begin
    lRevision := SvgBindingInputToken(I, fComponent.SvgBindings[I]);
    if PtrUInt(fSvgBindingRevisions[I]) <> PtrUInt(lRevision) then
      Exit(True);
  end;
  Result := False;
end;

procedure TRecorderImageView.RememberSvgInputRevisions;
var
  I: Integer;
  lRevision: QWord;
begin
  for I := 0 to fSvgBindingTags.Count - 1 do
  begin
    lRevision := SvgBindingInputToken(I, fComponent.SvgBindings[I]);
    fSvgBindingRevisions[I] := Pointer(PtrUInt(lRevision));
  end;
end;

function TRecorderImageView.SvgBindingInputToken(AIndex: Integer;
  ABinding: TRecorderSvgTagBinding): QWord;
var
  lTag: TRecorderTag;
  lSetpoint: TRecorderTagSetpoint;
  lBits: QWord;
  lColor: LongInt;
begin
  Result := 1;
  if (ABinding = nil) or (AIndex < 0) or
    (AIndex >= fSvgBindingTags.Count) then
    Exit;
  lTag := TRecorderTag(fSvgBindingTags[AIndex]);
  if lTag = nil then
    Exit;
  case ABinding.ValueKind of
    rsvCurrentValue, rsvVisibleWhenNonZero:
      Result := lTag.SignalBuffer.Revision;
    rsvHighAlarm, rsvHighAlarmColor:
      begin
        lSetpoint := lTag.Setpoints[tskHighAlarm];
        Move(lSetpoint.Threshold, lBits, SizeOf(lBits));
        Result := lBits xor QWord(ColorToRGB(lSetpoint.Color));
      end;
    rsvHighWarning, rsvHighWarningColor:
      begin
        lSetpoint := lTag.Setpoints[tskHighWarning];
        Move(lSetpoint.Threshold, lBits, SizeOf(lBits));
        Result := lBits xor QWord(ColorToRGB(lSetpoint.Color));
      end;
    rsvLowWarning, rsvLowWarningColor:
      begin
        lSetpoint := lTag.Setpoints[tskLowWarning];
        Move(lSetpoint.Threshold, lBits, SizeOf(lBits));
        Result := lBits xor QWord(ColorToRGB(lSetpoint.Color));
      end;
    rsvLowAlarm, rsvLowAlarmColor:
      begin
        lSetpoint := lTag.Setpoints[tskLowAlarm];
        Move(lSetpoint.Threshold, lBits, SizeOf(lBits));
        Result := lBits xor QWord(ColorToRGB(lSetpoint.Color));
      end;
    rsvActiveAlarmColorWhite, rsvActiveAlarmColorTransparent,
    rsvActiveAlarmColorCurrent:
      if fAlarmEngine <> nil then
      begin
        lColor := ColorToRGB(fAlarmEngine.GetTagAlarmColor(lTag));
        Result := QWord(Ord(fAlarmEngine.GetTagAlarmLevel(lTag))) shl 32 xor
          QWord(lColor);
      end;
  end;
end;

function TRecorderImageView.BindingValue(AIndex: Integer;
  ABinding: TRecorderSvgTagBinding;
  out AValue: string): Boolean;
var
  lTag: TRecorderTag;
  lSetpoint: TRecorderTagSetpoint;
  lNumber: Double;
  lColor: LongInt;
  lSettings: TFormatSettings;
begin
  Result := False;
  AValue := '';
  if ABinding = nil then
    Exit;
  if ABinding.ValueKind = rsvLiteral then
  begin
    AValue := EscapeSvgParameterValue(ABinding.LiteralValue);
    Exit(True);
  end;
  if ABinding.ValueKind = rsvAlwaysVisible then
  begin
    AValue := 'inline';
    Exit(True);
  end;
  if ABinding.ValueKind = rsvAlwaysHidden then
  begin
    AValue := 'none';
    Exit(True);
  end;
  if fTagRegistry = nil then
    Exit;
  lTag := nil;
  if (AIndex >= 0) and (AIndex < fSvgBindingTags.Count) then
    lTag := TRecorderTag(fSvgBindingTags[AIndex]);
  if lTag = nil then
    Exit;
  lColor := 0;
  case ABinding.ValueKind of
    rsvCurrentValue:
      begin
        if not RecorderTryReadScalarValue(lTag,True,tekMean,lNumber) then
          Exit;
      end;
    rsvVisibleWhenNonZero:
      begin
        if not RecorderTryReadScalarValue(lTag,True,tekMean,lNumber) then
          Exit;
        if Abs(lNumber) > 1.0E-12 then
          AValue := 'inline'
        else
          AValue := 'none';
        Exit(True);
      end;
    rsvHighAlarm, rsvHighAlarmColor:
      begin
        lSetpoint := lTag.Setpoints[tskHighAlarm];
        lNumber := lSetpoint.Threshold;
        lColor := ColorToRGB(lSetpoint.Color);
      end;
    rsvHighWarning, rsvHighWarningColor:
      begin
        lSetpoint := lTag.Setpoints[tskHighWarning];
        lNumber := lSetpoint.Threshold;
        lColor := ColorToRGB(lSetpoint.Color);
      end;
    rsvLowWarning, rsvLowWarningColor:
      begin
        lSetpoint := lTag.Setpoints[tskLowWarning];
        lNumber := lSetpoint.Threshold;
        lColor := ColorToRGB(lSetpoint.Color);
      end;
    rsvLowAlarm, rsvLowAlarmColor:
      begin
        lSetpoint := lTag.Setpoints[tskLowAlarm];
        lNumber := lSetpoint.Threshold;
        lColor := ColorToRGB(lSetpoint.Color);
      end;
    rsvActiveAlarmColorWhite,
    rsvActiveAlarmColorTransparent,
    rsvActiveAlarmColorCurrent:
      begin
        if (fAlarmEngine <> nil) and
          (fAlarmEngine.GetTagAlarmLevel(lTag) <> ralNone) then
        begin
          lColor := ColorToRGB(fAlarmEngine.GetTagAlarmColor(lTag));
          AValue := Format('#%.2x%.2x%.2x', [lColor and $FF,
            (lColor shr 8) and $FF, (lColor shr 16) and $FF]);
        end
        else
          case ABinding.ValueKind of
            rsvActiveAlarmColorWhite:
              AValue := '#FFFFFF';
            rsvActiveAlarmColorTransparent:
              AValue := 'none';
            rsvActiveAlarmColorCurrent:
              AValue := 'currentColor';
          end;
        Exit(True);
      end;
  end;
  if RecorderSvgValueKindIsColor(ABinding.ValueKind) then
    AValue := Format('#%.2x%.2x%.2x', [lColor and $FF,
      (lColor shr 8) and $FF, (lColor shr 16) and $FF])
  else
  begin
    lSettings := DefaultFormatSettings;
    lSettings.DecimalSeparator := '.';
    AValue := FloatToStr(lNumber, lSettings);
  end;
  Result := True;
end;

function TRecorderImageView.ResolveNormalizedSvgValue(AIndex: Integer;
  ABinding: TRecorderSvgTagBinding; out AValue: string): Boolean;
var
  lValidationError: string;
begin
  if not BindingValue(AIndex, ABinding, AValue) then
    if ABinding.LiteralValue <> '' then
      AValue := EscapeSvgParameterValue(ABinding.LiteralValue)
    else if RecorderSvgValueKindIsColor(ABinding.ValueKind) then
      AValue := '#000000'
    else
      AValue := '0';
  Result := ValidateSvgParameterValue(fSvgTemplateSource,
    ABinding.ParameterName, AValue, lValidationError);
  if Result then
    Exit;
  { Invalid runtime data is normalized to a deterministic safe value. It is
    intentionally not logged per sample; a repeated bad tag must not turn the
    repaint path into an unbounded diagnostic stream. }
  if RecorderSvgValueKindIsColor(ABinding.ValueKind) then
    AValue := '#000000'
  else if ABinding.ValueKind in [rsvVisibleWhenNonZero,
    rsvAlwaysVisible, rsvAlwaysHidden] then
    AValue := 'none'
  else
    AValue := '0';
end;

function TRecorderImageView.BuildParameterizedSvg(out ASignature: string): string;
var
  I: Integer;
  lBinding: TRecorderSvgTagBinding;
  lValue: string;
begin
  Result := '';
  ASignature := '';
  if (fComponent = nil) or
    not SameText(ExtractFileExt(fCurrentFileName), '.svg') then
    Exit;
  Result := fSvgTemplateSource;
  if Result = '' then
    Exit;
  if fSvgResolvedValues.Count <> fComponent.SvgBindingCount then
    SvgParameterSignature;
  for I := 0 to fComponent.SvgBindingCount - 1 do
  begin
    lBinding := fComponent.SvgBindings[I];
    lValue := fSvgResolvedValues[I];
    Result := ReplaceSvgParameter(Result, lBinding.ParameterName, lValue);
    ASignature := ASignature + lBinding.ParameterName + '=' + lValue + #10;
  end;
  Result := ResolveSvgParameterDefaults(Result);
  Result := ResolveSvgRendererExpressions(Result);
end;

function TRecorderImageView.SvgParameterSignature: string;
var
  I: Integer;
  lBinding: TRecorderSvgTagBinding;
  lValue: string;
begin
  Result := '';
  if fComponent = nil then
    Exit;
  fSvgResolvedValues.Clear;
  for I := 0 to fComponent.SvgBindingCount - 1 do
  begin
    lBinding := fComponent.SvgBindings[I];
    ResolveNormalizedSvgValue(I, lBinding, lValue);
    fSvgResolvedValues.Add(lValue);
    Result := Result + lBinding.ParameterName + '=' + lValue + #10;
  end;
end;

procedure TRecorderImageView.RefreshSvgParameters;
var
  lSignature, lSource: string;
begin
  if not fSvgLoaded or (fComponent = nil) or
    (fComponent.SvgBindingCount = 0) then
    Exit;
  if not SvgInputsChanged then
    Exit;
  lSignature := SvgParameterSignature;
  if lSignature = fSvgParameterSignature then
  begin
    RememberSvgInputRevisions;
    Exit;
  end;
  lSource := BuildParameterizedSvg(lSignature);
  if lSource = '' then
    Exit;
  try
    fSvg.AsUTF8String := lSource;
    RememberSvgInputRevisions;
    fSvgParameterSignature := lSignature;
    fSvgBitmap.SetSize(0, 0);
    Invalidate;
  except
    on E: Exception do
      RecorderDebugLog(Format('[IMAGE] SVG parameters failed: %s',
        [E.Message]));
  end;
end;

function TRecorderImageView.HasImage: Boolean;
begin
  Result := fSvgLoaded or
    ((fPicture.Graphic <> nil) and not fPicture.Graphic.Empty);
end;

procedure TRecorderImageView.DrawImage;
var
  lBitmap: TBGRABitmap;
begin
  if fSvgLoaded then
  begin
    if (fSvgBitmap.Width <> Width) or (fSvgBitmap.Height <> Height) then
    begin
      lBitmap := RenderSvgContent(fSvg, Width, Height);
      try
        fSvgBitmap.Assign(lBitmap);
      finally
        lBitmap.Free;
      end;
    end;
    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(ClientRect);
    fSvgBitmap.Draw(Canvas, ClientRect, True);
  end
  else
    Canvas.StretchDraw(ClientRect, fPicture.Graphic);
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
  if HasImage then
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
      DrawImage
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
    DrawImage
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
  lValue: Double;
begin
  Result := '';
  if (fComponent = nil) or (fComponent.Images.Count = 0) then
    Exit;

  if Trim(fComponent.TagName)<>'' then
  begin
    lTag:=RecorderResolveTagReference(ATagRegistry,fComponent.TagId,
      fComponent.TagName);
    if RecorderTryReadScalarValue(lTag,True,tekMean,lValue) then
    begin
      lFileName := FileNameForValue(lValue);
      if (lFileName <> '') and FileExists(lFileName) then
        Exit(lFileName);
    end;
  end;

  { Без свежего значения тега сохраняем текущий файл только пока он всё ещё
    присутствует в актуальном списке компонента. }
  for I := 0 to fComponent.Images.Count - 1 do
    if SameFileName(fCurrentFileName,
      Trim(fComponent.Images.ValueFromIndex[I])) and
      FileExists(fCurrentFileName) and HasImage then
      Exit(fCurrentFileName);

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
var
  lForceReload: Boolean;
begin
  fComponent := TRecorderImageComponent(AComponent);
  fTagRegistry := ATagRegistry;
  lForceReload := fLoadedImageRevision <> fComponent.ImageRevision;
  fLoadedImageRevision := fComponent.ImageRevision;
  fHasRevision := False;
  if fEditMode then
    SelectFile(PreviewFileName(ATagRegistry), lForceReload)
  else if (fComponent <> nil) and (fComponent.Images.Count > 0) and
    (Trim(fComponent.TagName) = '') then
    SelectFile(fComponent.Images.ValueFromIndex[0], lForceReload)
  else
    SelectFile('');
end;

procedure TRecorderImageView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lTag: TRecorderTag;
  lValue: Double;
begin
  if fComponent = nil then
    Exit;
  fTagRegistry := ATagRegistry;
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
    RefreshSvgParameters;
    Exit;
  end;
  lTag:=RecorderResolveTagReference(ATagRegistry,fComponent.TagId,
    fComponent.TagName);
  if not RecorderTryReadScalarValue(lTag,True,tekMean,lValue) then
  begin
    SelectFile('');
    Exit;
  end;
  if fHasRevision and (fLastRevision = lTag.SignalBuffer.Revision) then
  begin
    RefreshSvgParameters;
    Exit;
  end;
  fLastRevision := lTag.SignalBuffer.Revision;
  fHasRevision := True;
  SelectFile(FileNameForValue(lValue));
  RefreshSvgParameters;
end;

function TRecorderImageView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

initialization
  // Регистрация визуальных контролов мнемосхем
  TRecorderVisualControlRegistry.RegisterControl(TRecorderStaticTextComponent, TRecorderStaticTextView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderButtonComponent, TRecorderButtonView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderInputFieldComponent,
    TRecorderInputFieldView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderTagValueComponent, TRecorderTagValueView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderVibrationEstimateComponent,
    TRecorderVibrationEstimateView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderImageComponent, TRecorderImageView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderTrendComponent, TRecorderTrendView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderOscillogramComponent, TRecorderOglOscillogram);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderSpectrumComponent, TRecorderSpectrumView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderLissajousComponent, TRecorderLissajousView);
  TRecorderVisualControlRegistry.RegisterControl(TRecorderDonutComponent, TRecorderDonutView);

finalization
  TRecorderVisualControlRegistry.ClearRegistry;

end.
