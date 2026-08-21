unit uRecorderOscillogramSettingsDialog;

{
  Диалог настройки осциллограммы на пользовательской мнемосхеме.

  UI показывает единый список каналов: первый добавленный канал — синяя линия,
  второй — зелёная, третий — красная. Ограничение выбора каналами того же
  аппаратного модуля выполняется существующей фильтрацией реестра тегов.

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
    fOkButton: TButton;
    fCancelButton: TButton;

    procedure AddLineClick(Sender: TObject);
    procedure BindingModeComboChange(Sender: TObject);
    procedure BuildUi;
    procedure DeleteLineClick(Sender: TObject);
    procedure FillPrimaryTagCombo(const AFilter: string);
    procedure LineSelectionChange(Sender: TObject);
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
    function ValidateSourceIds: Boolean;
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
  Caption := 'Настройка осциллограммы - ' + AComponent.Name;
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 560;
  ClientHeight := 456;
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
  Inc(lTop, 44);

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
  lPrimary: TRecorderTag;
  lTag: TRecorderTag;
  lCurrent: string;
  lSearchText: string;
  lWasUpdating: Boolean;
begin
  if fTagCombo = nil then
    Exit;
  lCurrent := fDraft.TagName;
  lPrimary := fTagRegistry.FindByName(fDraft.TagName);
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
      if ((lPrimary = nil) or SameText(lTag.SourceId, lPrimary.SourceId)) and
        ((lFilter = '') or (Pos(lFilter, lSearchText) > 0)) then
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
begin
  fDraft.AssignOscillogram(fComponent);
  fDraft.TagName := fComponent.TagName;
  SyncDraftLineNames;
  fBindingModeCombo.ItemIndex := Ord(fDraft.BindingMode);
  fTagOffsetEdit.Text := IntToStr(fDraft.TagOffset);
  FillPrimaryTagCombo('');
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
      fLineList.Items.Add(OglChartLinePaletteName(0) + ' - ' + fDraft.TagName);
    for I := 0 to fDraft.LineCount - 1 do
      fLineList.Items.Add(fDraft.Lines[I].Name + ' - ' +
        fDraft.Lines[I].TagName);
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
  if not lEnabled then
  begin
    fLineVisibleCheck.Checked := True;
    Exit;
  end;
  if AIndex = 0 then
  begin
    SelectPrimaryTag(fDraft.TagName);
    fLineColorSwatch.LineColor := OglChartLinePaletteColor(0);
    fLineColorSwatch.Enabled := False;
    fLineVisibleCheck.Checked := True;
    fLineVisibleCheck.Enabled := False;
  end
  else
  begin
    lLine := fDraft.Lines[AIndex - 1];
    SelectPrimaryTag(lLine.TagName);
    fLineColorSwatch.LineColor := TColor(lLine.Color);
    fLineVisibleCheck.Checked := lLine.Visible;
  end;
end;

procedure TRecorderOscillogramSettingsDialog.StoreLineControls;
var
  lLine: TRecorderTrendLine;
  lName: string;
begin
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
  StoreLineControls;
  SyncDraftLineNames;
  fComponent.AssignOscillogram(fDraft);
  fComponent.TagId := fDraft.TagId;
  fComponent.TagName := fDraft.TagName;
end;

function TRecorderOscillogramSettingsDialog.ValidateSourceIds: Boolean;
var
  I: Integer;
  lNames: array of string;
  lCount: Integer;
begin
  Result := False;
  if fDraft.TagName = '' then
  begin
    ShowMessage('Добавьте хотя бы один канал.');
    Exit;
  end;
  lCount := 1;
  for I := 0 to fDraft.LineCount - 1 do
    if Trim(fDraft.Lines[I].TagName) <> '' then
      Inc(lCount);
  SetLength(lNames, lCount);
  lCount := 0;
  lNames[lCount] := fDraft.TagName;
  Inc(lCount);
  for I := 0 to fDraft.LineCount - 1 do
    if Trim(fDraft.Lines[I].TagName) <> '' then
    begin
      lNames[lCount] := fDraft.Lines[I].TagName;
      Inc(lCount);
    end;
  if not RecorderTagsShareSourceId(fTagRegistry, lNames) then
  begin
    ShowMessage('Все каналы осциллограммы должны принадлежать одному устройству (SourceId).');
    Exit;
  end;
  Result := True;
end;

procedure TRecorderOscillogramSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToComponent;
  if not ValidateSourceIds then
    Exit;
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
