unit uDetachedMnemonicForm;

{
  Отдельное окно пользовательского формуляра.

  Окно владеет только LCL-представлением и контроллером редактора. Модель
  страницы остаётся в TRecorderFormManager, поэтому вкладка и отдельное окно
  используют одну конфигурацию компонентов без копирования.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, ExtCtrls, Buttons, Graphics,
  ImgList, uRecorderFormModel, uRecorderTags, uRecorderAlarms,
  uFormEditorController, uRecorderCommandImages;

type
  TDetachedMnemonicForm = class(TForm)
  private
    fPage: TRecorderFormPage;
    fFactory: TRecorderComponentFactory;
    fEditor: TFormEditorController;
    fCanvas: TPanel;
    fToolbar: TPanel;
    fImages: TCustomImageList;
    fEditButton: TSpeedButton;
    fDeleteButton: TSpeedButton;
    fOnAttach: TNotifyEvent;
    fOnChanged: TNotifyEvent;
    fClosingApplication: Boolean;
    function AddToolButton(ALeft, AImageIndex: Integer; const AHint: string;
      AOnClick: TNotifyEvent; AGroupIndex: Integer = 0;
      AAllowAllUp: Boolean = False; AEnabled: Boolean = True;
      const ACaption: string = ''; AImageWidth: Integer = 25): TSpeedButton;
    function GetEditorPage: TRecorderFormPage;
    function UniqueComponentId(const ATypeName: string): string;
    procedure AddComponent(const ATypeId, ATypeName: string; AWidth,
      AHeight: Integer);
    procedure AddTextClick(Sender: TObject);
    procedure AddValueClick(Sender: TObject);
    procedure AddOscClick(Sender: TObject);
    procedure AddTrendClick(Sender: TObject);
    procedure AddSpectrumClick(Sender: TObject);
    procedure AddImageClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure EditorChanged;
    procedure FormCloseHandler(Sender: TObject; var CloseAction: TCloseAction);
    procedure SaveMonitorAndBounds;
    procedure RestoreMonitorAndBounds;
  public
    constructor CreateForPage(AOwner: TComponent; APage: TRecorderFormPage;
      AFactory: TRecorderComponentFactory; ATagRegistry: TRecorderTagRegistry;
      AAlarmEngine: IRecorderAlarmEngine; ADisplaySeconds: Double;
      AImages: TCustomImageList;
      AOnAttach, AOnChanged: TNotifyEvent);
    destructor Destroy; override;
    procedure RefreshLive;
    procedure SavePlacement;
    procedure CloseForApplication;
    procedure DiscardDeletedPage;
    property Page: TRecorderFormPage read fPage;
  end;

implementation

constructor TDetachedMnemonicForm.CreateForPage(AOwner: TComponent;
  APage: TRecorderFormPage; AFactory: TRecorderComponentFactory;
  ATagRegistry: TRecorderTagRegistry; AAlarmEngine: IRecorderAlarmEngine;
  ADisplaySeconds: Double; AImages: TCustomImageList;
  AOnAttach, AOnChanged: TNotifyEvent);
begin
  inherited CreateNew(AOwner);
  fPage := APage;
  fFactory := AFactory;
  fImages := AImages;
  fOnAttach := AOnAttach;
  fOnChanged := AOnChanged;
  Caption := fPage.Title;
  Position := poDesigned;
  KeyPreview := True;
  OnClose := @FormCloseHandler;

  fToolbar := TPanel.Create(Self);
  fToolbar.Parent := Self;
  fToolbar.Align := alTop;
  fToolbar.Height := 32;
  fToolbar.BevelOuter := bvLowered;

  fEditButton := AddToolButton(4, CIconEditForm, 'Edit mnemonic',
    @EditClick, 1, True);
  AddToolButton(38, CIconOscillogram, 'Add oscillogram', @AddOscClick);
  AddToolButton(72, CIconTrends, 'Add trend', @AddTrendClick);
  AddToolButton(106, CIconTextLabel, 'Add text label', @AddTextClick);
  AddToolButton(140, CIconSpectrum, 'Add spectrum', @AddSpectrumClick);
  AddToolButton(174, CIconDigitalIndicator, 'Add digital indicator',
    @AddValueClick);
  AddToolButton(208, -1, 'Добавить картинку', @AddImageClick, 0, False,
    True, 'Img');
  AddToolButton(248, CIconTagTable, 'Add tag table', nil, 0, False, False);
  AddToolButton(282, CIconButton, 'Add button', nil, 0, False, False);
  AddToolButton(316, CIconComboBox, 'Add combo box', nil, 0, False, False);
  fDeleteButton := AddToolButton(356, -1, 'Delete selected component',
    @DeleteClick, 0, False, True, '-');

  fCanvas := TPanel.Create(Self);
  fCanvas.Parent := Self;
  fCanvas.Align := alClient;
  fCanvas.BevelOuter := bvNone;
  fCanvas.Color := clWhite;
  fCanvas.ParentBackground := False;

  fEditor := TFormEditorController.Create(fCanvas, @GetEditorPage, fFactory);
  fEditor.OnChanged := @EditorChanged;
  fEditor.SetDataContext(ATagRegistry, AAlarmEngine, ADisplaySeconds);
  fEditor.Enabled := False;

  RestoreMonitorAndBounds;
  fEditor.Render;
end;

destructor TDetachedMnemonicForm.Destroy;
begin
  SaveMonitorAndBounds;
  fEditor.Free;
  inherited Destroy;
end;

function TDetachedMnemonicForm.AddToolButton(ALeft, AImageIndex: Integer;
  const AHint: string; AOnClick: TNotifyEvent; AGroupIndex: Integer;
  AAllowAllUp: Boolean; AEnabled: Boolean; const ACaption: string;
  AImageWidth: Integer): TSpeedButton;
begin
  Result := TSpeedButton.Create(Self);
  Result.Parent := fToolbar;
  Result.Left := ALeft;
  Result.Top := 4;
  if AImageIndex >= 0 then
  begin
    Result.Width := 30;
    Result.Height := 24;
    Result.Caption := '';
    Result.Images := fImages;
    Result.ImageIndex := AImageIndex;
    Result.ImageWidth := AImageWidth;
  end
  else
  begin
    Result.Width := 24;
    Result.Height := 24;
    Result.Caption := ACaption;
  end;
  Result.Hint := AHint;
  Result.ShowHint := True;
  Result.GroupIndex := AGroupIndex;
  Result.AllowAllUp := AAllowAllUp;
  Result.Enabled := AEnabled;
  Result.OnClick := AOnClick;
end;

function TDetachedMnemonicForm.GetEditorPage: TRecorderFormPage;
begin
  Result := fPage;
end;

function TDetachedMnemonicForm.UniqueComponentId(
  const ATypeName: string): string;
var
  I: Integer;
begin
  I := fPage.ComponentCount + 1;
  repeat
    Result := Format('%s.%s%d', [fPage.Id, ATypeName, I]);
    Inc(I);
  until fPage.FindComponentById(Result) = nil;
end;

procedure TDetachedMnemonicForm.AddComponent(const ATypeId, ATypeName: string;
  AWidth, AHeight: Integer);
var
  lComponent: TRecorderVisualComponent;
begin
  fEditor.RememberUndoStep;
  lComponent := fFactory.CreateComponent(ATypeId);
  try
    lComponent.Id := UniqueComponentId(ATypeName);
    lComponent.Name := ExtractFileName(lComponent.Id);
    lComponent.SetBounds(16, 16, AWidth, AHeight);
    fEditor.PositionNewComponent(lComponent);
    fPage.AddComponent(lComponent);
    lComponent := nil;
  finally
    lComponent.Free;
  end;
  fEditor.Render;
  EditorChanged;
end;

procedure TDetachedMnemonicForm.AddTextClick(Sender: TObject);
begin
  AddComponent(TRecorderStaticTextComponent.TypeId, 'Text', 180, 28);
end;

procedure TDetachedMnemonicForm.AddValueClick(Sender: TObject);
begin
  AddComponent(TRecorderTagValueComponent.TypeId, 'Value', 180, 32);
end;

procedure TDetachedMnemonicForm.AddOscClick(Sender: TObject);
begin
  AddComponent(TRecorderOscillogramComponent.TypeId, 'Osc', 360, 220);
end;

procedure TDetachedMnemonicForm.AddTrendClick(Sender: TObject);
begin
  AddComponent(TRecorderTrendComponent.TypeId, 'Trend', 400, 300);
end;

procedure TDetachedMnemonicForm.AddSpectrumClick(Sender: TObject);
begin
  AddComponent(TRecorderSpectrumComponent.TypeId, 'Spectrum', 400, 300);
end;

procedure TDetachedMnemonicForm.AddImageClick(Sender: TObject);
begin
  AddComponent(TRecorderImageComponent.TypeId, 'Image', 240, 160);
end;

procedure TDetachedMnemonicForm.DeleteClick(Sender: TObject);
begin
  fEditor.DeleteSelected;
end;

procedure TDetachedMnemonicForm.EditClick(Sender: TObject);
begin
  fEditor.Enabled := fEditButton.Down;
end;

procedure TDetachedMnemonicForm.EditorChanged;
begin
  if Assigned(fOnChanged) then
    fOnChanged(Self);
end;

procedure TDetachedMnemonicForm.FormCloseHandler(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveMonitorAndBounds;
  if not fClosingApplication then
  begin
    fPage.Detached := False;
    if Assigned(fOnAttach) then
      fOnAttach(Self);
  end;
  CloseAction := caHide;
end;

procedure TDetachedMnemonicForm.SaveMonitorAndBounds;
var
  I: Integer;
  lCenter: TPoint;
begin
  if fPage = nil then
    Exit;
  fPage.DetachedMaximized := WindowState = wsMaximized;
  if WindowState = wsNormal then
  begin
    fPage.DetachedLeft := Left;
    fPage.DetachedTop := Top;
    fPage.DetachedWidth := Width;
    fPage.DetachedHeight := Height;
  end;
  lCenter := Point(Left + Width div 2, Top + Height div 2);
  for I := 0 to Screen.MonitorCount - 1 do
    if PtInRect(Screen.Monitors[I].BoundsRect, lCenter) then
    begin
      fPage.DetachedMonitor := I;
      Break;
    end;
end;

procedure TDetachedMnemonicForm.RestoreMonitorAndBounds;
var
  I: Integer;
  lBounds: TRect;
  lIntersection: TRect;
  lVisible: Boolean;
  lMonitor: TMonitor;
begin
  SetBounds(fPage.DetachedLeft, fPage.DetachedTop,
    fPage.DetachedWidth, fPage.DetachedHeight);
  lBounds := BoundsRect;
  lVisible := False;
  for I := 0 to Screen.MonitorCount - 1 do
    if IntersectRect(lIntersection, lBounds, Screen.Monitors[I].BoundsRect) then
    begin
      lVisible := True;
      Break;
    end;
  if not lVisible and (Screen.MonitorCount > 0) then
  begin
    I := fPage.DetachedMonitor;
    if (I < 0) or (I >= Screen.MonitorCount) then
      I := 0;
    lMonitor := Screen.Monitors[I];
    Left := lMonitor.WorkareaRect.Left + 40;
    Top := lMonitor.WorkareaRect.Top + 40;
  end;
  if fPage.DetachedMaximized then
    WindowState := wsMaximized;
end;

procedure TDetachedMnemonicForm.RefreshLive;
begin
  if Visible and (WindowState <> wsMinimized) then
    fEditor.RefreshLive;
end;

procedure TDetachedMnemonicForm.SavePlacement;
begin
  SaveMonitorAndBounds;
end;

procedure TDetachedMnemonicForm.CloseForApplication;
begin
  fClosingApplication := True;
  SaveMonitorAndBounds;
  Hide;
end;

procedure TDetachedMnemonicForm.DiscardDeletedPage;
begin
  fClosingApplication := True;
  fPage := nil;
  Hide;
end;

end.
