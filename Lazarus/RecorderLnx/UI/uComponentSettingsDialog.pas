unit uComponentSettingsDialog;

{$mode objfpc}{$H+}
{$codepage cp1251}

interface

uses
  LConvEncoding,
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, Buttons,
  Dialogs, uRecorderFormModel, uRecorderTags, uComponentServices;

type
  TComponentSettingsDialog = class(TForm)
  private
    fComponent: TRecorderVisualComponent;
    fTagRegistry: TRecorderTagRegistry;
    fTagSearchLabel: TLabel;
    fTagComboLabel: TLabel;
    fTagCombo: TComboBox;
    fTagSearchEdit: TEdit;
    fOkButton: TButton;
    fCancelButton: TButton;
    fSelectedFontName: string;
    fSelectedFontSize: Integer;
    fSelectedFontColor: TColor;
    fSelectedFontBold: Boolean;
    fSelectedFontItalic: Boolean;
    fFontPreviewLabel: TLabel;
    fFontButton: TButton;
    fTextEdit: TEdit;
    fDisplayFormatEdit: TEdit;
    fShowNameCombo: TComboBox;
    fUseDefaultEstimateCheck: TCheckBox;
    fEstimateKindCombo: TComboBox;
    fBindingModeCombo: TComboBox;
    fTagOffsetEdit: TEdit;

    procedure BindingModeComboChange(Sender: TObject);
    procedure FontButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure TagSearchEditChange(Sender: TObject);
    procedure UseDefaultEstimateCheckChange(Sender: TObject);
    procedure BuildUi;
    procedure LoadFromComponent;
    procedure PopulateTags(const AFilter: string);
    procedure StoreToComponent;
    procedure UpdateFontPreview;
    procedure UpdateTagVisibility;
  public
    constructor CreateDialog(AOwner: TComponent; AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
  end;

function ShowComponentSettingsDialog(AOwner: TComponent; AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

uses
  uRecorderTrendSettingsDialog, uRecorderSpectrumSettingsDialog;

function ShowComponentSettingsDialog(AOwner: TComponent; AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TComponentSettingsDialog;
begin
  if AComponent is TRecorderTrendComponent then
    Exit(ShowRecorderTrendSettingsDialog(AOwner,
      TRecorderTrendComponent(AComponent), ATagRegistry));
  if AComponent is TRecorderSpectrumComponent then
    Exit(ShowRecorderSpectrumSettingsDialog(AOwner,
      TRecorderSpectrumComponent(AComponent), ATagRegistry));

  lDialog := TComponentSettingsDialog.CreateDialog(AOwner, AComponent, ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TComponentSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  Caption := CP1251ToUTF8('Настройка компонента - ') + AComponent.Name;
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 460;
  BuildUi;
  LoadFromComponent;
end;

procedure TComponentSettingsDialog.BuildUi;
var
  lTop: Integer;
  lLabel: TLabel;
  lEst: TRecorderTagEstimateKind;
begin
  lTop := 16;

  if (fComponent is TRecorderTagValueComponent) or (fComponent is TRecorderOscillogramComponent) then
  begin
    fTagSearchLabel := TLabel.Create(Self);
    fTagSearchLabel.Parent := Self;
    fTagSearchLabel.SetBounds(16, lTop + 4, 120, 16);
    fTagSearchLabel.Caption := CP1251ToUTF8('Поиск тега:');

    fTagSearchEdit := TEdit.Create(Self);
    fTagSearchEdit.Parent := Self;
    fTagSearchEdit.SetBounds(140, lTop, 300, 23);
    fTagSearchEdit.OnChange := @TagSearchEditChange;
    Inc(lTop, 32);

    fTagComboLabel := TLabel.Create(Self);
    fTagComboLabel.Parent := Self;
    fTagComboLabel.SetBounds(16, lTop + 4, 120, 16);
    fTagComboLabel.Caption := CP1251ToUTF8('Выбранный тег:');

    fTagCombo := TComboBox.Create(Self);
    fTagCombo.Parent := Self;
    fTagCombo.SetBounds(140, lTop, 300, 23);
    fTagCombo.Style := csDropDownList;
    Inc(lTop, 40);
  end;

  if fComponent is TRecorderStaticTextComponent then
  begin
    lLabel := TLabel.Create(Self);
    lLabel.Parent := Self;
    lLabel.SetBounds(16, lTop + 4, 120, 16);
    lLabel.Caption := CP1251ToUTF8('Текст метки:');

    fTextEdit := TEdit.Create(Self);
    fTextEdit.Parent := Self;
    fTextEdit.SetBounds(140, lTop, 300, 23);
    Inc(lTop, 40);
  end;

  if (fComponent is TRecorderStaticTextComponent) or (fComponent is TRecorderTagValueComponent) then
  begin
    lLabel := TLabel.Create(Self);
    lLabel.Parent := Self;
    lLabel.SetBounds(16, lTop + 10, 120, 16);
    lLabel.Caption := CP1251ToUTF8('Шрифт компонента:');

    fFontButton := TButton.Create(Self);
    fFontButton.Parent := Self;
    fFontButton.SetBounds(140, lTop, 100, 25);
    fFontButton.Caption := CP1251ToUTF8('Выбрать...');
    fFontButton.OnClick := @FontButtonClick;

    fFontPreviewLabel := TLabel.Create(Self);
    fFontPreviewLabel.Parent := Self;
    fFontPreviewLabel.SetBounds(250, lTop + 4, 190, 25);
    fFontPreviewLabel.Caption := CP1251ToUTF8('Образец текста');
    Inc(lTop, 40);
  end;

  if fComponent is TRecorderTagValueComponent then
  begin
    lLabel := TLabel.Create(Self);
    lLabel.Parent := Self;
    lLabel.SetBounds(16, lTop + 4, 120, 16);
    lLabel.Caption := CP1251ToUTF8('Формат (Format):');

    fDisplayFormatEdit := TEdit.Create(Self);
    fDisplayFormatEdit.Parent := Self;
    fDisplayFormatEdit.SetBounds(140, lTop, 120, 23);
    Inc(lTop, 32);

    lLabel := TLabel.Create(Self);
    lLabel.Parent := Self;
    lLabel.SetBounds(16, lTop + 4, 120, 16);
    lLabel.Caption := CP1251ToUTF8('Отображение имени:');

    fShowNameCombo := TComboBox.Create(Self);
    fShowNameCombo.Parent := Self;
    fShowNameCombo.SetBounds(140, lTop, 180, 23);
    fShowNameCombo.Style := csDropDownList;
    fShowNameCombo.Items.Add(CP1251ToUTF8('Скрыть имя'));
    fShowNameCombo.Items.Add(CP1251ToUTF8('Имя сверху'));
    fShowNameCombo.Items.Add(CP1251ToUTF8('Имя слева'));
    Inc(lTop, 32);

    fUseDefaultEstimateCheck := TCheckBox.Create(Self);
    fUseDefaultEstimateCheck.Parent := Self;
    fUseDefaultEstimateCheck.SetBounds(16, lTop, 220, 20);
    fUseDefaultEstimateCheck.Caption := CP1251ToUTF8('Оценка по умолчанию из тега');
    fUseDefaultEstimateCheck.OnChange := @UseDefaultEstimateCheckChange;

    lLabel := TLabel.Create(Self);
    lLabel.Parent := Self;
    lLabel.SetBounds(240, lTop + 2, 70, 16);
    lLabel.Caption := CP1251ToUTF8('Оценка:');

    fEstimateKindCombo := TComboBox.Create(Self);
    fEstimateKindCombo.Parent := Self;
    fEstimateKindCombo.SetBounds(310, lTop, 130, 23);
    fEstimateKindCombo.Style := csDropDownList;
    for lEst := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
      fEstimateKindCombo.Items.Add(RecorderTagEstimateKindToShortName(lEst));
    Inc(lTop, 40);
  end;

  if fComponent is TRecorderOscillogramComponent then
  begin
    lLabel := TLabel.Create(Self);
    lLabel.Parent := Self;
    lLabel.SetBounds(16, lTop + 4, 120, 16);
    lLabel.Caption := CP1251ToUTF8('Привязка к каналу:');

    fBindingModeCombo := TComboBox.Create(Self);
    fBindingModeCombo.Parent := Self;
    fBindingModeCombo.SetBounds(140, lTop, 220, 23);
    fBindingModeCombo.Style := csDropDownList;
    fBindingModeCombo.Items.Add(CP1251ToUTF8('Относительная (выбранный тег)'));
    fBindingModeCombo.Items.Add(CP1251ToUTF8('Абсолютная привязка'));
    fBindingModeCombo.OnChange := @BindingModeComboChange;
    Inc(lTop, 32);

    lLabel := TLabel.Create(Self);
    lLabel.Parent := Self;
    lLabel.SetBounds(16, lTop + 4, 120, 16);
    lLabel.Caption := CP1251ToUTF8('Относит. смещение:');

    fTagOffsetEdit := TEdit.Create(Self);
    fTagOffsetEdit.Parent := Self;
    fTagOffsetEdit.SetBounds(140, lTop, 80, 23);
    Inc(lTop, 40);
  end;

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(350, lTop, 90, 25);
  fCancelButton.Caption := CP1251ToUTF8('Отмена');
  fCancelButton.ModalResult := mrCancel;

  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(250, lTop, 90, 25);
  fOkButton.Caption := 'OK';
  fOkButton.OnClick := @OkButtonClick;
  fOkButton.Default := True;
  ClientHeight := lTop + 40;
end;

procedure TComponentSettingsDialog.PopulateTags(const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lTag: TRecorderTag;
  lCurrentSelection: string;
  lSearchText: string;
begin
  if (fTagCombo = nil) or (fTagRegistry = nil) then
    Exit;

  lCurrentSelection := '';
  if (fTagCombo.ItemIndex >= 0) and
    (fTagCombo.Items.Objects[fTagCombo.ItemIndex] is TRecorderTag) then
    lCurrentSelection := TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]).Name
  else
    lCurrentSelection := fTagCombo.Text;

  fTagCombo.Items.BeginUpdate;
  try
    fTagCombo.Items.Clear;
    lFilter := LowerCase(Trim(LclText(AFilter)));
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      lSearchText := LowerCase(LclText(lTag.Name + ' ' + lTag.Address + ' ' + lTag.Description));
      if (lFilter = '') or (Pos(lFilter, lSearchText) > 0) then
        fTagCombo.Items.AddObject(LclText(lTag.Name), lTag);
    end;

    fTagCombo.ItemIndex := -1;
    for I := 0 to fTagCombo.Items.Count - 1 do
      if (fTagCombo.Items.Objects[I] is TRecorderTag) and
        (TRecorderTag(fTagCombo.Items.Objects[I]).Name = lCurrentSelection) then
      begin
        fTagCombo.ItemIndex := I;
        Break;
      end;
    if (fTagCombo.ItemIndex < 0) and (fTagCombo.Items.Count > 0) then
      fTagCombo.ItemIndex := 0;
  finally
    fTagCombo.Items.EndUpdate;
  end;
end;

procedure TComponentSettingsDialog.LoadFromComponent;
var
  lTagIndex: Integer;
begin
  if fTagCombo <> nil then
  begin
    PopulateTags('');
    lTagIndex := 0;
    while (lTagIndex < fTagCombo.Items.Count) and
      ((not (fTagCombo.Items.Objects[lTagIndex] is TRecorderTag)) or
       (TRecorderTag(fTagCombo.Items.Objects[lTagIndex]).Name <> fComponent.TagName)) do
      Inc(lTagIndex);
    if lTagIndex < fTagCombo.Items.Count then
      fTagCombo.ItemIndex := lTagIndex
    else if fTagCombo.Items.Count > 0 then
      fTagCombo.ItemIndex := 0;
  end;

  if fComponent is TRecorderStaticTextComponent then
  begin
    fTextEdit.Text := TRecorderStaticTextComponent(fComponent).Text;
    fSelectedFontName := TRecorderStaticTextComponent(fComponent).FontName;
    fSelectedFontSize := TRecorderStaticTextComponent(fComponent).FontSize;
    fSelectedFontColor := TRecorderStaticTextComponent(fComponent).FontColor;
    fSelectedFontBold := TRecorderStaticTextComponent(fComponent).FontStyleBold;
    fSelectedFontItalic := TRecorderStaticTextComponent(fComponent).FontStyleItalic;
    UpdateFontPreview;
  end
  else if fComponent is TRecorderTagValueComponent then
  begin
    fDisplayFormatEdit.Text := TRecorderTagValueComponent(fComponent).DisplayFormat;
    fShowNameCombo.ItemIndex := Ord(TRecorderTagValueComponent(fComponent).ShowNameMode);
    fUseDefaultEstimateCheck.Checked := TRecorderTagValueComponent(fComponent).UseDefaultEstimate;
    fEstimateKindCombo.ItemIndex := Ord(TRecorderTagValueComponent(fComponent).EstimateKind);
    fEstimateKindCombo.Enabled := not fUseDefaultEstimateCheck.Checked;
    fSelectedFontName := TRecorderTagValueComponent(fComponent).FontName;
    fSelectedFontSize := TRecorderTagValueComponent(fComponent).FontSize;
    fSelectedFontColor := TRecorderTagValueComponent(fComponent).FontColor;
    fSelectedFontBold := TRecorderTagValueComponent(fComponent).FontStyleBold;
    fSelectedFontItalic := TRecorderTagValueComponent(fComponent).FontStyleItalic;
    UpdateFontPreview;
  end
  else if fComponent is TRecorderOscillogramComponent then
  begin
    fBindingModeCombo.ItemIndex := Ord(TRecorderOscillogramComponent(fComponent).BindingMode);
    fTagOffsetEdit.Text := IntToStr(TRecorderOscillogramComponent(fComponent).TagOffset);
  end;
  UpdateTagVisibility;
end;

procedure TComponentSettingsDialog.StoreToComponent;
begin
  if fTagCombo <> nil then
  begin
    if (fTagCombo.ItemIndex >= 0) and
      (fTagCombo.Items.Objects[fTagCombo.ItemIndex] is TRecorderTag) then
      fComponent.TagName := TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]).Name
    else
      fComponent.TagName := fTagCombo.Text;
  end;

  if fComponent is TRecorderStaticTextComponent then
  begin
    TRecorderStaticTextComponent(fComponent).Text := fTextEdit.Text;
    TRecorderStaticTextComponent(fComponent).FontName := fSelectedFontName;
    TRecorderStaticTextComponent(fComponent).FontSize := fSelectedFontSize;
    TRecorderStaticTextComponent(fComponent).FontColor := fSelectedFontColor;
    TRecorderStaticTextComponent(fComponent).FontStyleBold := fSelectedFontBold;
    TRecorderStaticTextComponent(fComponent).FontStyleItalic := fSelectedFontItalic;
  end
  else if fComponent is TRecorderTagValueComponent then
  begin
    TRecorderTagValueComponent(fComponent).DisplayFormat := fDisplayFormatEdit.Text;
    TRecorderTagValueComponent(fComponent).ShowNameMode := TRecorderTagValueNameMode(fShowNameCombo.ItemIndex);
    TRecorderTagValueComponent(fComponent).UseDefaultEstimate := fUseDefaultEstimateCheck.Checked;
    TRecorderTagValueComponent(fComponent).EstimateKind := TRecorderTagEstimateKind(fEstimateKindCombo.ItemIndex);
    TRecorderTagValueComponent(fComponent).FontName := fSelectedFontName;
    TRecorderTagValueComponent(fComponent).FontSize := fSelectedFontSize;
    TRecorderTagValueComponent(fComponent).FontColor := fSelectedFontColor;
    TRecorderTagValueComponent(fComponent).FontStyleBold := fSelectedFontBold;
    TRecorderTagValueComponent(fComponent).FontStyleItalic := fSelectedFontItalic;
  end
  else if fComponent is TRecorderOscillogramComponent then
  begin
    TRecorderOscillogramComponent(fComponent).BindingMode := TRecorderTagBindingMode(fBindingModeCombo.ItemIndex);
    TRecorderOscillogramComponent(fComponent).TagOffset := StrToIntDef(fTagOffsetEdit.Text, 0);
  end;
end;

procedure TComponentSettingsDialog.UpdateFontPreview;
begin
  if fFontPreviewLabel = nil then
    Exit;
  fFontPreviewLabel.Font.Name := fSelectedFontName;
  fFontPreviewLabel.Font.Size := fSelectedFontSize;
  fFontPreviewLabel.Font.Color := fSelectedFontColor;
  fFontPreviewLabel.Font.Style := [];
  if fSelectedFontBold then
    fFontPreviewLabel.Font.Style := fFontPreviewLabel.Font.Style + [fsBold];
  if fSelectedFontItalic then
    fFontPreviewLabel.Font.Style := fFontPreviewLabel.Font.Style + [fsItalic];
end;

procedure TComponentSettingsDialog.FontButtonClick(Sender: TObject);
var
  lDlg: TFontDialog;
begin
  lDlg := TFontDialog.Create(Self);
  try
    lDlg.Font.Name := fSelectedFontName;
    lDlg.Font.Size := fSelectedFontSize;
    lDlg.Font.Color := fSelectedFontColor;
    lDlg.Font.Style := [];
    if fSelectedFontBold then
      lDlg.Font.Style := lDlg.Font.Style + [fsBold];
    if fSelectedFontItalic then
      lDlg.Font.Style := lDlg.Font.Style + [fsItalic];

    if lDlg.Execute then
    begin
      fSelectedFontName := lDlg.Font.Name;
      fSelectedFontSize := lDlg.Font.Size;
      fSelectedFontColor := lDlg.Font.Color;
      fSelectedFontBold := fsBold in lDlg.Font.Style;
      fSelectedFontItalic := fsItalic in lDlg.Font.Style;
      UpdateFontPreview;
    end;
  finally
    lDlg.Free;
  end;
end;

procedure TComponentSettingsDialog.TagSearchEditChange(Sender: TObject);
begin
  PopulateTags(fTagSearchEdit.Text);
end;

procedure TComponentSettingsDialog.UseDefaultEstimateCheckChange(Sender: TObject);
begin
  if fEstimateKindCombo <> nil then
    fEstimateKindCombo.Enabled := not fUseDefaultEstimateCheck.Checked;
end;

procedure TComponentSettingsDialog.BindingModeComboChange(Sender: TObject);
begin
  UpdateTagVisibility;
end;

procedure TComponentSettingsDialog.UpdateTagVisibility;
var
  lShowTagChoice: Boolean;
begin
  if (fComponent is TRecorderOscillogramComponent) and (fBindingModeCombo <> nil) then
  begin
    lShowTagChoice := TRecorderTagBindingMode(fBindingModeCombo.ItemIndex) <> rtbmRelativeSelectedTag;
    if fTagSearchLabel <> nil then fTagSearchLabel.Visible := lShowTagChoice;
    if fTagSearchEdit <> nil then fTagSearchEdit.Visible := lShowTagChoice;
    if fTagComboLabel <> nil then fTagComboLabel.Visible := lShowTagChoice;
    if fTagCombo <> nil then fTagCombo.Visible := lShowTagChoice;
  end;
end;

procedure TComponentSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToComponent;
  ModalResult := mrOk;
end;

end.