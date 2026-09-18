unit uRecorderOscillogramSettingsDialog;

{
  Диалог настройки осциллограммы на пользовательской мнемосхеме.

  UI показывает единый список каналов: первый добавленный канал — синяя линия,
  второй — зелёная, третий — красная. Каналы разных устройств допустимы.

  Для совместимости проекта первая линия хранится в TagName компонента, а
  остальные — в Lines[]. Это внутренняя деталь модели: отдельной пользовательской
  опции «Основной канал» быть не должно. При удалении первой линии следующая
  дополнительная линия повышается до первой.
  Кодировка (2026-06):
  Файл в UTF-8, {$codepage UTF8}. Строки для LCL — обычные string-литералы.
  См. Docs/source-encoding.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, Dialogs,
  uRecorderColorSwatch, uRecorderFormModel, uRecorderTags, uOglChartColors,
  uRecorderTagRefs;

function ShowRecorderOscillogramSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderOscillogramComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

type
  TRecorderOscillogramSettingsDialog = class(TForm)
  private
    fComponent: TRecorderOscillogramComponent;
    fDraft: TRecorderOscillogramComponent;
    fTagRegistry: TRecorderTagRegistry;
    fSelectedLine: Integer;
    fSelectedAxis: Integer;
    fUpdating: Boolean;

    fTagSearchEdit: TEdit;
    fTagCombo: TComboBox;
    fBindingModeCombo: TComboBox;
    fTagOffsetEdit: TEdit;
    fLineList: TListBox;
    fAddLineButton: TButton;
    fDeleteLineButton: TButton;
    fLineColorSwatch: TRecorderColorSwatch;
    fLineVisibleCheck: TCheckBox;
    fAxisCombo: TComboBox;
    fNewAxisButton: TButton;
    fXScaleEdit: TEdit;
    fYScaleEdit: TEdit;
    fYOffsetEdit: TEdit;
    fTriggerCombo: TComboBox;
    fTriggerCheck: TCheckBox;
    fTriggerLevelEdit: TEdit;
    fOkButton: TButton;
    fCancelButton: TButton;

    procedure AddLineClick(Sender: TObject);
    procedure BindingModeComboChange(Sender: TObject);
    procedure BuildUi;
    procedure DeleteLineClick(Sender: TObject);
    procedure FillPrimaryTagCombo(const AFilter: string);
    procedure LineSelectionChange(Sender: TObject);
    procedure AxisComboChange(Sender: TObject);
    procedure NewAxisClick(Sender: TObject);
    procedure RefreshAxisCombo;
    procedure LoadAxisControls(AIndex: Integer);
    procedure StoreAxisControls;
    procedure SelectPrimaryTag(const ATagName: string);
    procedure SyncDraftLineNames;
    procedure LoadFromComponent;
    procedure LoadLineControls(AIndex: Integer);
    procedure OkButtonClick(Sender: TObject);
    procedure PrimaryTagChange(Sender: TObject);
    procedure TagSearchEditChange(Sender: TObject);
    procedure StoreLineControls;
    procedure StoreToComponent;
    procedure RefreshLineList;
    function ValidateChannels: Boolean;
    procedure UpdatePrimaryTagVisibility;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderOscillogramComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderOscillogramSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderOscillogramComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderOscillogramSettingsDialog;
begin
  lDialog := TRecorderOscillogramSettingsDialog.CreateDialog(AOwner, AComponent,
    ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderOscillogramSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderOscillogramComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  fDraft := TRecorderOscillogramComponent.Create;
  fSelectedLine := -1;
  fSelectedAxis := 0;
  Caption := 'Настройка осциллограммы - ' + AComponent.Name;
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 560;
  ClientHeight := 630;
  BuildUi;
  LoadFromComponent;
end;

destructor TRecorderOscillogramSettingsDialog.Destroy;
begin
  fDraft.Free;
  inherited Destroy;
end;

procedure TRecorderOscillogramSettingsDialog.BuildUi;
var
  lLabel: TLabel;
  lTop: Integer;
begin
  lTop := 12;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'Поиск тега:';

  fTagSearchEdit := TEdit.Create(Self);
  fTagSearchEdit.Parent := Self;
  fTagSearchEdit.SetBounds(130, lTop, 410, 23);
  fTagSearchEdit.OnChange := @TagSearchEditChange;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'Канал:';

  fTagCombo := TComboBox.Create(Self);
  fTagCombo.Parent := Self;
  fTagCombo.SetBounds(130, lTop, 310, 23);
  fTagCombo.Style := csDropDownList;
  fTagCombo.OnChange := @PrimaryTagChange;

  fAddLineButton := TButton.Create(Self);
  fAddLineButton.Parent := Self;
  fAddLineButton.SetBounds(450, lTop, 90, 25);
  fAddLineButton.Caption := 'Добавить';
  fAddLineButton.OnClick := @AddLineClick;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'Привязка:';

  fBindingModeCombo := TComboBox.Create(Self);
  fBindingModeCombo.Parent := Self;
  fBindingModeCombo.SetBounds(130, lTop, 260, 23);
  fBindingModeCombo.Style := csDropDownList;
  fBindingModeCombo.Items.Add('Относительная (выбранный тег)');
  fBindingModeCombo.Items.Add('Абсолютная привязка');
  fBindingModeCombo.OnChange := @BindingModeComboChange;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'Относит. смещение:';

  fTagOffsetEdit := TEdit.Create(Self);
  fTagOffsetEdit.Parent := Self;
  fTagOffsetEdit.SetBounds(130, lTop, 80, 23);
  Inc(lTop, 40);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop, 320, 16);
  lLabel.Caption := 'Добавленные каналы:';

  fLineList := TListBox.Create(Self);
  fLineList.Parent := Self;
  fLineList.SetBounds(12, lTop + 20, 320, 120);
  fLineList.OnClick := @LineSelectionChange;

  fDeleteLineButton := TButton.Create(Self);
  fDeleteLineButton.Parent := Self;
  fDeleteLineButton.SetBounds(340, lTop + 20, 90, 25);
  fDeleteLineButton.Caption := 'Удалить';
  fDeleteLineButton.OnClick := @DeleteLineClick;
  Inc(lTop, 150);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 80, 16);
  lLabel.Caption := 'Цвет:';

  fLineColorSwatch := TRecorderColorSwatch.Create(Self);
  fLineColorSwatch.Parent := Self;
  fLineColorSwatch.SetBounds(90, lTop, 28, 24);

  fLineVisibleCheck := TCheckBox.Create(Self);
  fLineVisibleCheck.Parent := Self;
  fLineVisibleCheck.SetBounds(130, lTop + 2, 120, 20);
  fLineVisibleCheck.Caption := 'Видимая';
  Inc(lTop, 34);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 80, 16);
  lLabel.Caption := 'Ось канала:';
  fAxisCombo := TComboBox.Create(Self);
  fAxisCombo.Parent := Self;
  fAxisCombo.SetBounds(130, lTop, 160, 23);
  fAxisCombo.Style := csDropDownList;
  fAxisCombo.OnChange := @AxisComboChange;
  fNewAxisButton := TButton.Create(Self);
  fNewAxisButton.Parent := Self;
  fNewAxisButton.SetBounds(300, lTop, 130, 25);
  fNewAxisButton.Caption := 'В новую ось';
  fNewAxisButton.OnClick := @NewAxisClick;
  Inc(lTop, 34);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'XScale, с:';
  fXScaleEdit := TEdit.Create(Self);
  fXScaleEdit.Parent := Self;
  fXScaleEdit.SetBounds(130, lTop, 90, 23);
  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(260, lTop + 4, 105, 16);
  lLabel.Caption := 'Масштаб оси:';
  fYScaleEdit := TEdit.Create(Self);
  fYScaleEdit.Parent := Self;
  fYScaleEdit.SetBounds(370, lTop, 80, 23);
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'Сдвиг оси Y:';
  fYOffsetEdit := TEdit.Create(Self);
  fYOffsetEdit.Parent := Self;
  fYOffsetEdit.SetBounds(130, lTop, 90, 23);
  Inc(lTop, 32);

  fTriggerCheck := TCheckBox.Create(Self);
  fTriggerCheck.Parent := Self;
  fTriggerCheck.SetBounds(12, lTop + 2, 120, 20);
  fTriggerCheck.Caption := 'Триггер';
  fTriggerCombo := TComboBox.Create(Self);
  fTriggerCombo.Parent := Self;
  fTriggerCombo.SetBounds(130, lTop, 310, 23);
  fTriggerCombo.Style := csDropDownList;
  Inc(lTop, 32);

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(12, lTop + 4, 120, 16);
  lLabel.Caption := 'Уровень:';
  fTriggerLevelEdit := TEdit.Create(Self);
  fTriggerLevelEdit.Parent := Self;
  fTriggerLevelEdit.SetBounds(130, lTop, 90, 23);
  Inc(lTop, 35);

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := Self;
  fCancelButton.SetBounds(450, lTop, 90, 25);
  fCancelButton.Caption := 'Отмена';
  fCancelButton.ModalResult := mrCancel;

  fOkButton := TButton.Create(Self);
  fOkButton.Parent := Self;
  fOkButton.SetBounds(350, lTop, 90, 25);
  fOkButton.Caption := 'OK';
  fOkButton.Default := True;
  fOkButton.OnClick := @OkButtonClick;
end;

procedure TRecorderOscillogramSettingsDialog.FillPrimaryTagCombo(
  const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lTag: TRecorderTag;
  lCurrent: string;
  lSearchText: string;
  lWasUpdating: Boolean;
begin
  if fTagCombo = nil then
    Exit;
  lCurrent := fDraft.TagName;
  lWasUpdating := fUpdating;
  fUpdating := True;
  fTagCombo.Items.BeginUpdate;
  try
    fTagCombo.Items.Clear;
    lFilter := LowerCase(Trim(AFilter));
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      lSearchText := LowerCase(lTag.Name + ' ' + lTag.Address + ' ' + lTag.Description);
      if (lFilter = '') or (Pos(lFilter, lSearchText) > 0) then
        fTagCombo.Items.AddObject(lTag.Name, lTag);
    end;
    fTagCombo.ItemIndex := -1;
    for I := 0 to fTagCombo.Items.Count - 1 do
      if (fTagCombo.Items.Objects[I] is TRecorderTag) and
        SameText(TRecorderTag(fTagCombo.Items.Objects[I]).Name, lCurrent) then
      begin
        fTagCombo.ItemIndex := I;
        Break;
      end;
    if (fTagCombo.ItemIndex < 0) and (fTagCombo.Items.Count > 0) then
      fTagCombo.ItemIndex := 0;
  finally
    fTagCombo.Items.EndUpdate;
    fUpdating := lWasUpdating;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.SelectPrimaryTag(
  const ATagName: string);
var
  I: Integer;
  lWasUpdating: Boolean;
begin
  if fTagCombo = nil then
    Exit;
  lWasUpdating := fUpdating;
  fUpdating := True;
  try
    fTagCombo.ItemIndex := -1;
    for I := 0 to fTagCombo.Items.Count - 1 do
      if (fTagCombo.Items.Objects[I] is TRecorderTag) and
        SameText(TRecorderTag(fTagCombo.Items.Objects[I]).Name, ATagName) then
      begin
        fTagCombo.ItemIndex := I;
        Break;
      end;
  finally
    fUpdating := lWasUpdating;
  end;
  UpdatePrimaryTagVisibility;
end;

procedure TRecorderOscillogramSettingsDialog.SyncDraftLineNames;
var
  I: Integer;
  lName: string;
  lColor: LongInt;
begin
  for I := 0 to fDraft.LineCount - 1 do
  begin
    lName := OglChartLinePaletteNameForColor(TColor(fDraft.Lines[I].Color));
    if lName <> '' then
      fDraft.Lines[I].Name := lName
    else
    begin
      OglChartLineAppearance(I + 1, lName, lColor);
      fDraft.Lines[I].Name := lName;
      fDraft.Lines[I].Color := lColor;
    end;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.LoadFromComponent;
var
  I: Integer;
begin
  fDraft.AssignOscillogram(fComponent);
  fDraft.TagName := fComponent.TagName;
  SyncDraftLineNames;
  fBindingModeCombo.ItemIndex := Ord(fDraft.BindingMode);
  fTagOffsetEdit.Text := IntToStr(fDraft.TagOffset);
  fXScaleEdit.Text := FloatToStr(fDraft.XScale);
  fTriggerCheck.Checked := fDraft.TriggerEnabled;
  fTriggerLevelEdit.Text := FloatToStr(fDraft.TriggerLevel);
  fTriggerCombo.Items.Clear;
  fTriggerCombo.Items.Add('');
  for I := 0 to fTagRegistry.TagCount - 1 do
    fTriggerCombo.Items.Add(fTagRegistry.Tags[I].Name);
  fTriggerCombo.ItemIndex := fTriggerCombo.Items.IndexOf(fDraft.TriggerTagName);
  if fTriggerCombo.ItemIndex < 0 then
    fTriggerCombo.ItemIndex := 0;
  FillPrimaryTagCombo('');
  RefreshAxisCombo;
  RefreshLineList;
  UpdatePrimaryTagVisibility;
end;

procedure TRecorderOscillogramSettingsDialog.RefreshLineList;
var
  I: Integer;
begin
  if fLineList = nil then
    Exit;
  fUpdating := True;
  try
    fLineList.Items.Clear;
    if Trim(fDraft.TagName) <> '' then
      fLineList.Items.Add(Format('[Y%d] %s - %s',
        [fDraft.PrimaryAxisIndex + 1, OglChartLinePaletteName(0), fDraft.TagName]));
    for I := 0 to fDraft.LineCount - 1 do
      fLineList.Items.Add(Format('[Y%d] %s - %s',
        [fDraft.Lines[I].AxisIndex + 1, fDraft.Lines[I].Name,
        fDraft.Lines[I].TagName]));
    if (fSelectedLine >= 0) and (fSelectedLine < fLineList.Items.Count) then
      fLineList.ItemIndex := fSelectedLine
    else if fLineList.Items.Count > 0 then
    begin
      fSelectedLine := 0;
      fLineList.ItemIndex := 0;
    end
    else
      fSelectedLine := -1;
    LoadLineControls(fSelectedLine);
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.LoadLineControls(AIndex: Integer);
var
  lLine: TRecorderTrendLine;
  lEnabled: Boolean;
begin
  lEnabled := (AIndex >= 0) and (AIndex <= fDraft.LineCount) and
    (fDraft.TagName <> '');
  fLineColorSwatch.Enabled := lEnabled;
  fLineVisibleCheck.Enabled := lEnabled;
  fDeleteLineButton.Enabled := lEnabled;
  fAxisCombo.Enabled := lEnabled;
  fNewAxisButton.Enabled := lEnabled and (fDraft.AxisCount < 16);
  if not lEnabled then
  begin
    fLineVisibleCheck.Checked := True;
    LoadAxisControls(0);
    Exit;
  end;
  if AIndex = 0 then
  begin
    SelectPrimaryTag(fDraft.TagName);
    fLineColorSwatch.LineColor := OglChartLinePaletteColor(0);
    fLineColorSwatch.Enabled := False;
    fLineVisibleCheck.Checked := True;
    fLineVisibleCheck.Enabled := False;
    LoadAxisControls(fDraft.PrimaryAxisIndex);
  end
  else
  begin
    lLine := fDraft.Lines[AIndex - 1];
    SelectPrimaryTag(lLine.TagName);
    fLineColorSwatch.LineColor := TColor(lLine.Color);
    fLineVisibleCheck.Checked := lLine.Visible;
    LoadAxisControls(lLine.AxisIndex);
  end;
end;

procedure TRecorderOscillogramSettingsDialog.RefreshAxisCombo;
var
  I: Integer;
begin
  fAxisCombo.Items.Clear;
  for I := 0 to fDraft.AxisCount - 1 do
    fAxisCombo.Items.Add(Format('Y%d — %s', [I + 1, fDraft.Axes[I].Name]));
end;

procedure TRecorderOscillogramSettingsDialog.LoadAxisControls(AIndex: Integer);
var
  lWasUpdating: Boolean;
begin
  if (AIndex < 0) or (AIndex >= fDraft.AxisCount) then
    AIndex := 0;
  fSelectedAxis := AIndex;
  lWasUpdating := fUpdating;
  fUpdating := True;
  try
    fAxisCombo.ItemIndex := AIndex;
    fYScaleEdit.Text := FloatToStr(fDraft.Axes[AIndex].YScale);
    fYOffsetEdit.Text := FloatToStr(fDraft.Axes[AIndex].YOffset);
  finally
    fUpdating := lWasUpdating;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.StoreAxisControls;
var
  lValue: Double;
begin
  if (fSelectedAxis < 0) or (fSelectedAxis >= fDraft.AxisCount) then
    Exit;
  if TryStrToFloat(fYScaleEdit.Text, lValue) and (lValue > 0) then
    fDraft.Axes[fSelectedAxis].YScale := lValue;
  if TryStrToFloat(fYOffsetEdit.Text, lValue) then
    fDraft.Axes[fSelectedAxis].YOffset := lValue;
end;

procedure TRecorderOscillogramSettingsDialog.AxisComboChange(Sender: TObject);
var
  lAxis: Integer;
begin
  if fUpdating or (fSelectedLine < 0) or
    (fAxisCombo.ItemIndex < 0) then
    Exit;
  StoreAxisControls;
  lAxis := fAxisCombo.ItemIndex;
  if fSelectedLine = 0 then
    fDraft.PrimaryAxisIndex := lAxis
  else
    fDraft.Lines[fSelectedLine - 1].AxisIndex := lAxis;
  LoadAxisControls(lAxis);
  RefreshLineList;
end;

procedure TRecorderOscillogramSettingsDialog.NewAxisClick(Sender: TObject);
var
  lAxis: Integer;
begin
  if (fSelectedLine < 0) or (fDraft.AxisCount >= 16) then
    Exit;
  StoreLineControls;
  lAxis := fDraft.AxisCount;
  fDraft.AddAxis;
  if fSelectedLine = 0 then
    fDraft.PrimaryAxisIndex := lAxis
  else
    fDraft.Lines[fSelectedLine - 1].AxisIndex := lAxis;
  RefreshAxisCombo;
  RefreshLineList;
end;

procedure TRecorderOscillogramSettingsDialog.StoreLineControls;
var
  lLine: TRecorderTrendLine;
  lName: string;
begin
  StoreAxisControls;
  { Привязка канала меняется непосредственно в PrimaryTagChange. Здесь
    сохраняются остальные свойства выбранной строки. }
  if (fSelectedLine < 0) or (fSelectedLine > fDraft.LineCount) then
    Exit;
  if fSelectedLine = 0 then
    Exit;
  lLine := fDraft.Lines[fSelectedLine - 1];
  lLine.Color := LongInt(fLineColorSwatch.LineColor);
  lName := OglChartLinePaletteNameForColor(fLineColorSwatch.LineColor);
  if lName <> '' then
    lLine.Name := lName;
  lLine.Visible := fLineVisibleCheck.Checked;
end;

procedure TRecorderOscillogramSettingsDialog.StoreToComponent;
begin
  fDraft.BindingMode := TRecorderTagBindingMode(fBindingModeCombo.ItemIndex);
  fDraft.TagOffset := StrToIntDef(fTagOffsetEdit.Text, 0);
  fDraft.XScale := StrToFloat(fXScaleEdit.Text);
  fDraft.TriggerTagName := fTriggerCombo.Text;
  fDraft.TriggerEnabled := fTriggerCheck.Checked;
  fDraft.TriggerLevel := StrToFloat(fTriggerLevelEdit.Text);
  StoreLineControls;
  SyncDraftLineNames;
  fComponent.AssignOscillogram(fDraft);
  fComponent.TagId := fDraft.TagId;
  fComponent.TagName := fDraft.TagName;
end;

function TRecorderOscillogramSettingsDialog.ValidateChannels: Boolean;
begin
  Result := fDraft.TagName <> '';
  if not Result then
    ShowMessage('Добавьте хотя бы один канал.');
end;

procedure TRecorderOscillogramSettingsDialog.OkButtonClick(Sender: TObject);
var
  lXScale, lYScale, lYOffset, lTriggerLevel: Double;
begin
  if (not TryStrToFloat(fXScaleEdit.Text, lXScale)) or (lXScale < 0) or
    (not TryStrToFloat(fYScaleEdit.Text, lYScale)) or (lYScale <= 0) or
    (not TryStrToFloat(fYOffsetEdit.Text, lYOffset)) or
    (not TryStrToFloat(fTriggerLevelEdit.Text, lTriggerLevel)) then
  begin
    ShowMessage('Укажите XScale не меньше нуля (0 — общее окно), масштаб оси больше нуля и корректные сдвиг/уровень.');
    Exit;
  end;
  if fTriggerCheck.Checked and (fTriggerCombo.ItemIndex <= 0) then
  begin
    ShowMessage('Выберите тег для триггера.');
    Exit;
  end;
  if not ValidateChannels then
    Exit;
  StoreToComponent;
  ModalResult := mrOk;
end;

procedure TRecorderOscillogramSettingsDialog.AddLineClick(Sender: TObject);
var
  lLine: TRecorderTrendLine;
  lTag: TRecorderTag;
  I: Integer;

  function TagAlreadyUsed(ATag: TRecorderTag): Boolean;
  var
    J: Integer;
  begin
    Result := (ATag = nil) or SameText(fDraft.TagName, ATag.Name);
    if Result then
      Exit;
    for J := 0 to fDraft.LineCount - 1 do
      if SameText(fDraft.Lines[J].TagName, ATag.Name) then
        Exit(True);
  end;
begin
  StoreLineControls;
  if (fTagCombo.ItemIndex < 0) or
    not (fTagCombo.Items.Objects[fTagCombo.ItemIndex] is TRecorderTag) then
    Exit;
  lTag := TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]);
  { При наличии выбранной линии combo уже перепривязал её. Для новой строки
    берём следующий свободный канал; затем пользователь может сразу заменить
    его тем же combo. }
  if (fDraft.TagName <> '') and TagAlreadyUsed(lTag) then
  begin
    lTag := nil;
    for I := 0 to fTagCombo.Items.Count - 1 do
      if (fTagCombo.Items.Objects[I] is TRecorderTag) and
        not TagAlreadyUsed(TRecorderTag(fTagCombo.Items.Objects[I])) then
      begin
        lTag := TRecorderTag(fTagCombo.Items.Objects[I]);
        Break;
      end;
    if lTag = nil then
      Exit;
  end;
  if fDraft.TagName = '' then
  begin
    RecorderBindComponentTag(fDraft, lTag);
    fSelectedLine := 0;
  end
  else
  begin
    lLine := fDraft.AddLine;
    RecorderBindTrendLineTag(lLine, lTag);
    fSelectedLine := fDraft.LineCount;
  end;
  RefreshLineList;
end;

procedure TRecorderOscillogramSettingsDialog.DeleteLineClick(Sender: TObject);
begin
  if (fSelectedLine < 0) or (fSelectedLine > fDraft.LineCount) then
    Exit;
  if fSelectedLine = 0 then
  begin
    if fDraft.LineCount > 0 then
    begin
      if fTagRegistry.FindByName(fDraft.Lines[0].TagName) <> nil then
        RecorderBindComponentTag(fDraft,
          fTagRegistry.FindByName(fDraft.Lines[0].TagName));
      fDraft.DeleteLine(0);
    end
    else
    begin
      fDraft.TagId := 0;
      fDraft.TagName := '';
    end;
  end
  else
    fDraft.DeleteLine(fSelectedLine - 1);
  if fSelectedLine > fDraft.LineCount then
    fSelectedLine := fDraft.LineCount;
  RefreshLineList;
end;

procedure TRecorderOscillogramSettingsDialog.LineSelectionChange(Sender: TObject);
begin
  if fUpdating then
    Exit;
  StoreLineControls;
  fSelectedLine := fLineList.ItemIndex;
  LoadLineControls(fSelectedLine);
end;


procedure TRecorderOscillogramSettingsDialog.TagSearchEditChange(Sender: TObject);
begin
  FillPrimaryTagCombo(fTagSearchEdit.Text);
end;

procedure TRecorderOscillogramSettingsDialog.PrimaryTagChange(Sender: TObject);
var
  I: Integer;
  lCurrentName: string;
  lTag: TRecorderTag;
begin
  UpdatePrimaryTagVisibility;
  if fUpdating or (fTagCombo.ItemIndex < 0) or
    not (fTagCombo.Items.Objects[fTagCombo.ItemIndex] is TRecorderTag) or
    (fSelectedLine < 0) or (fSelectedLine > fDraft.LineCount) then
    Exit;

  lTag := TRecorderTag(fTagCombo.Items.Objects[fTagCombo.ItemIndex]);
  if fSelectedLine = 0 then
    lCurrentName := fDraft.TagName
  else
    lCurrentName := fDraft.Lines[fSelectedLine - 1].TagName;
  if SameText(lCurrentName, lTag.Name) then
    Exit;

  { Один канал не должен одновременно занимать две линии. }
  if (fSelectedLine <> 0) and SameText(fDraft.TagName, lTag.Name) then
  begin
    SelectPrimaryTag(lCurrentName);
    Exit;
  end;
  for I := 0 to fDraft.LineCount - 1 do
    if (I + 1 <> fSelectedLine) and
      SameText(fDraft.Lines[I].TagName, lTag.Name) then
    begin
      SelectPrimaryTag(lCurrentName);
      Exit;
    end;

  StoreLineControls;
  if fSelectedLine = 0 then
    RecorderBindComponentTag(fDraft, lTag)
  else
    RecorderBindTrendLineTag(fDraft.Lines[fSelectedLine - 1], lTag);
  RefreshLineList;
end;

procedure TRecorderOscillogramSettingsDialog.BindingModeComboChange(Sender: TObject);
begin
  UpdatePrimaryTagVisibility;
end;

procedure TRecorderOscillogramSettingsDialog.UpdatePrimaryTagVisibility;
var
  lCanSelectTag: Boolean;
begin
  lCanSelectTag := (fBindingModeCombo = nil) or
    (TRecorderTagBindingMode(fBindingModeCombo.ItemIndex) <>
    rtbmRelativeSelectedTag);
  if fTagSearchEdit <> nil then
    fTagSearchEdit.Enabled := lCanSelectTag;
  if fTagCombo <> nil then
    fTagCombo.Enabled := lCanSelectTag;
  if fAddLineButton <> nil then
    fAddLineButton.Enabled := lCanSelectTag and (fTagCombo <> nil) and
      (fTagCombo.ItemIndex >= 0);
end;

end.
