unit uTagSettingsDialog;

{
  Dialog for editing one or several RecorderLnx tags.

  It follows the original Recorder multi-select rule: a field displays a value
  only when that value is identical for all selected tags. Empty mixed fields are
  left unchanged on OK. Tag name is editable only for a single selected tag.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls,
  Buttons, Dialogs, ImgList, uRecorderTags;

type
  TTagSettingsDialog = class(TForm)
  private
    fApplyButton: TButton;
    fAutoRangeCheck: TCheckBox;
    fAutoUnitCheck: TCheckBox;
    fDescriptionEdit: TEdit;
    fDefaultEstimateCombo: TComboBox;
    fEstimateChecks: array[TRecorderTagEstimateKind] of TCheckBox;
    fFrequencyCombo: TComboBox;
    fHardwareCurveCheck: TCheckBox;
    fHardwareCurveEdit: TEdit;
    fImages: TCustomImageList;
    fMaxEdit: TEdit;
    fMinEdit: TEdit;
    fModuleEdit: TEdit;
    fNameEdit: TEdit;
    fPortionLengthEdit: TEdit;
    fScadaCheck: TCheckBox;
    fSetpointColorPanels: array[TRecorderTagSetpointKind] of TPanel;
    fSetpointEnabledChecks: array[TRecorderTagSetpointKind] of TCheckBox;
    fSetpointHysteresisCheck: TCheckBox;
    fSetpointSoundCheck: TCheckBox;
    fSetpointStatusChannelCheck: TCheckBox;
    fSetpointThresholdEdits: array[TRecorderTagSetpointKind] of TEdit;
    fSmoothingCheck: TCheckBox;
    fSmoothingKEdit: TEdit;
    fTagRegistry: TRecorderTagRegistry;
    fTags: TList;
    fUnitCombo: TComboBox;
    procedure ApplyButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure BuildUi;
    procedure BuildAdditionalTab(ATab: TTabSheet);
    procedure BuildSetpointsTab(ATab: TTabSheet);
    procedure LoadFromTags;
    procedure StoreToTags;
    function AllBool(AGetter: Integer): Integer;
    function AllEstimateBool(AKind: TRecorderTagEstimateKind;
      out AValue: Boolean): Boolean;
    function AllEstimateDefault(out AValue: TRecorderTagEstimateKind): Boolean;
    function AllEstimateFlag(AGetter: Integer; out AValue: Boolean): Boolean;
    function AllEstimateFloat(AKind: Integer; out AValue: Double): Boolean;
    function AllEstimateInt(out AValue: Integer): Boolean;
    function AllFloat(AKind: Integer; out AValue: Double): Boolean;
    function AllSetpointBool(AKind: TRecorderTagSetpointKind;
      AGetter: Integer; out AValue: Boolean): Boolean;
    function AllSetpointFloat(AKind: TRecorderTagSetpointKind;
      AGetter: Integer; out AValue: Double): Boolean;
    function AllSetpointGlobalBool(AGetter: Integer; out AValue: Boolean): Boolean;
    function AllString(AKind: Integer; out AValue: string): Boolean;
    function FrequencyCanBeEdited: Boolean;
    function ReadFloat(const AText: string; out AValue: Double): Boolean;
    function TagAt(AIndex: Integer): TRecorderTag;
  public
    constructor CreateDialog(AOwner: TComponent; ATagRegistry: TRecorderTagRegistry;
      ATags: TList; AImages: TCustomImageList = nil); reintroduce;
    destructor Destroy; override;
  end;

function ShowTagSettingsDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; ATags: TList;
  AImages: TCustomImageList = nil): Boolean;

implementation

const
  CTagDialogIconAddress = 0;
  CTagDialogIconEdit = 1;
  CTagDialogIconProperty = 2;
  CTagDialogIconHardwareCurve = 3;
  CTagDialogIconAdd = 4;
  CTagDialogIconRemove = 5;
  CTagDialogIconChannelCurve = 6;

function ShowTagSettingsDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; ATags: TList;
  AImages: TCustomImageList): Boolean;
var
  lDialog: TTagSettingsDialog;
begin
  lDialog := TTagSettingsDialog.CreateDialog(AOwner, ATagRegistry, ATags, AImages);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TTagSettingsDialog.CreateDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; ATags: TList; AImages: TCustomImageList);
begin
  inherited CreateNew(AOwner, 1);
  if ATagRegistry = nil then
    raise ERecorderTagError.Create('Tag registry cannot be nil');
  if (ATags = nil) or (ATags.Count = 0) then
    raise ERecorderTagError.Create('No tags selected');

  fTagRegistry := ATagRegistry;
  fImages := AImages;
  fTags := TList.Create;
  fTags.Assign(ATags);
  BuildUi;
  LoadFromTags;
end;

destructor TTagSettingsDialog.Destroy;
begin
  fTags.Free;
  inherited Destroy;
end;

function TTagSettingsDialog.TagAt(AIndex: Integer): TRecorderTag;
begin
  Result := TRecorderTag(fTags[AIndex]);
end;

procedure TTagSettingsDialog.BuildUi;
var
  lTabs: TPageControl;
  lTab: TTabSheet;
  lAdditionalTab: TTabSheet;
  lSetpointsTab: TTabSheet;
  lGroup: TGroupBox;
  lPanel: TPanel;
  lOkButton: TButton;
  lCancelButton: TButton;
  lLabel: TLabel;

  function AddLabel(AParent: TWinControl; ALeft, ATop: Integer;
    const ACaption: string): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := AParent;
    Result.Left := ALeft;
    Result.Top := ATop + 4;
    Result.Caption := ACaption;
  end;

  function AddEdit(AParent: TWinControl; ALeft, ATop, AWidth: Integer): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := AParent;
    Result.SetBounds(ALeft, ATop, AWidth, 23);
  end;

  function AddButton(AParent: TWinControl; ALeft, ATop, AImageIndex: Integer;
    const ACaption, AHint: string): TSpeedButton;
  begin
    Result := TSpeedButton.Create(Self);
    Result.Parent := AParent;
    Result.SetBounds(ALeft, ATop, 34, 32);
    Result.Caption := ACaption;
    if (fImages <> nil) and (AImageIndex >= 0) and (AImageIndex < fImages.Count) then
    begin
      Result.Images := fImages;
      Result.ImageIndex := AImageIndex;
      Result.ImageWidth := 32;
      Result.Caption := '';
    end;
    Result.Hint := AHint;
    Result.ShowHint := True;
  end;

begin
  BorderStyle := bsDialog;
  Caption := 'Настройка канала';
  ClientWidth := 560;
  ClientHeight := 580;
  Position := poScreenCenter;

  lTabs := TPageControl.Create(Self);
  lTabs.Parent := Self;
  lTabs.Align := alClient;
  lTabs.BorderSpacing.Around := 8;
  lTabs.BorderSpacing.Bottom := 46;

  lTab := TTabSheet.Create(Self);
  lTab.PageControl := lTabs;
  lTab.Caption := 'Параметры';

  lAdditionalTab := TTabSheet.Create(Self);
  lAdditionalTab.PageControl := lTabs;
  lAdditionalTab.Caption := 'Дополнительно';
  lSetpointsTab := TTabSheet.Create(Self);
  lSetpointsTab.PageControl := lTabs;
  lSetpointsTab.Caption := 'Уставки';

  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := lTab;
  lGroup.SetBounds(8, 8, 520, 166);
  lGroup.Caption := 'Общие параметры';

  AddLabel(lGroup, 12, 22, 'Имя');
  fNameEdit := AddEdit(lGroup, 72, 18, 250);

  AddLabel(lGroup, 334, 22, 'ед.');
  fUnitCombo := TComboBox.Create(Self);
  fUnitCombo.Parent := lGroup;
  fUnitCombo.SetBounds(362, 18, 80, 23);
  fUnitCombo.Items.Add('-');
  fUnitCombo.Items.Add('a.u.');
  fUnitCombo.Items.Add('V');
  fUnitCombo.Items.Add('mV');
  fUnitCombo.Items.Add('g');
  fUnitCombo.Items.Add('Hz');
  fAutoUnitCheck := TCheckBox.Create(Self);
  fAutoUnitCheck.Parent := lGroup;
  fAutoUnitCheck.SetBounds(450, 20, 58, 20);
  fAutoUnitCheck.Caption := 'Авто';

  AddLabel(lGroup, 12, 52, 'Адрес');
  fModuleEdit := AddEdit(lGroup, 72, 48, 250);
  fModuleEdit.ReadOnly := True;
  AddButton(lGroup, 330, 44, CTagDialogIconAddress, '...', 'Выбор адреса канала');

  AddLabel(lGroup, 12, 86, 'Описание');
  fDescriptionEdit := AddEdit(lGroup, 72, 82, 380);
  AddButton(lGroup, 460, 78, CTagDialogIconEdit, '*', 'Редактировать описание');

  AddLabel(lGroup, 12, 124, 'Частота опроса');
  fFrequencyCombo := TComboBox.Create(Self);
  fFrequencyCombo.Parent := lGroup;
  fFrequencyCombo.SetBounds(132, 120, 128, 23);
  fFrequencyCombo.Items.Add('100.0');
  fFrequencyCombo.Items.Add('1000.0');
  fFrequencyCombo.Items.Add('57600.0');
  fFrequencyCombo.Items.Add('100000.0');
  AddLabel(lGroup, 268, 124, 'Гц');

  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := lTab;
  lGroup.SetBounds(8, 184, 520, 78);
  lGroup.Caption := 'Диапазон значений';

  AddLabel(lGroup, 12, 24, 'Нижний');
  fMinEdit := AddEdit(lGroup, 72, 20, 90);
  AddLabel(lGroup, 210, 24, 'Верхний');
  fMaxEdit := AddEdit(lGroup, 272, 20, 90);
  fAutoRangeCheck := TCheckBox.Create(Self);
  fAutoRangeCheck.Parent := lGroup;
  fAutoRangeCheck.SetBounds(420, 22, 58, 20);
  fAutoRangeCheck.Caption := 'Авто';

  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := lTab;
  lGroup.SetBounds(8, 274, 520, 74);
  lGroup.Caption := 'Аппаратная КХ';
  fHardwareCurveCheck := TCheckBox.Create(Self);
  fHardwareCurveCheck.Parent := lGroup;
  fHardwareCurveCheck.SetBounds(8, 22, 16, 20);
  fHardwareCurveEdit := AddEdit(lGroup, 30, 22, 360);
  fHardwareCurveEdit.ReadOnly := True;
  AddButton(lGroup, 400, 16, CTagDialogIconProperty, '...', 'Выбор аппаратной характеристики');
  AddButton(lGroup, 438, 16, CTagDialogIconHardwareCurve, 'f/c', 'Настройка аппаратной характеристики');

  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := lTab;
  lGroup.SetBounds(8, 360, 520, 74);
  lGroup.Caption := 'Канальная ГХ';
  TCheckBox.Create(Self).Parent := lGroup;
  TCheckBox(lGroup.Controls[lGroup.ControlCount - 1]).SetBounds(8, 22, 16, 20);
  TCheckBox(lGroup.Controls[lGroup.ControlCount - 1]).Checked := True;
  AddEdit(lGroup, 30, 22, 290).ReadOnly := True;
  AddButton(lGroup, 330, 16, CTagDialogIconProperty, '...', 'Выбор канальной градуировки');
  AddButton(lGroup, 368, 16, CTagDialogIconAdd, '+', 'Добавить градуировку');
  AddButton(lGroup, 406, 16, CTagDialogIconRemove, 'x', 'Удалить градуировку');
  AddButton(lGroup, 444, 16, CTagDialogIconChannelCurve, 'f/c', 'Настройка канальной градуировки');

  lLabel := TLabel.Create(Self);
  lLabel.Parent := lTab;
  lLabel.SetBounds(72, 462, 320, 24);
  lLabel.Caption := 'Настройка виртуального канала';

  lPanel := TPanel.Create(Self);
  lPanel.Parent := Self;
  lPanel.Align := alBottom;
  lPanel.Height := 42;
  lPanel.BevelOuter := bvNone;

  lOkButton := TButton.Create(Self);
  lOkButton.Parent := lPanel;
  lOkButton.SetBounds(316, 8, 74, 26);
  lOkButton.Caption := 'OK';
  lOkButton.ModalResult := mrNone;
  lOkButton.OnClick := @OkButtonClick;

  lCancelButton := TButton.Create(Self);
  lCancelButton.Parent := lPanel;
  lCancelButton.SetBounds(396, 8, 74, 26);
  lCancelButton.Caption := 'Отмена';
  lCancelButton.ModalResult := mrCancel;

  fApplyButton := TButton.Create(Self);
  fApplyButton.Parent := lPanel;
  fApplyButton.SetBounds(476, 8, 74, 26);
  fApplyButton.Caption := 'Применить';
  fApplyButton.OnClick := @ApplyButtonClick;

  BuildAdditionalTab(lAdditionalTab);
  BuildSetpointsTab(lSetpointsTab);
end;

procedure TTagSettingsDialog.BuildAdditionalTab(ATab: TTabSheet);
const
  CEstimateCaptions: array[TRecorderTagEstimateKind] of string = (
    'математическое ожидание (МО) precision: default',
    'среднеквадратическое значение (СКЗ) precision: default',
    'среднеквадратическое отклонение (СКО) precision: default',
    'амплитуда (Пик) precision: default',
    'размах (Пик-Пик) precision: default',
    'Минимальное значение (Минимум) precision: default',
    'Максимальное значение (Максимум) precision: default',
    'Размах по среднеквадратическому отклонению (ПП по СКО) precision: default',
    'последнее значение precision: default'
  );
var
  lGroup: TGroupBox;
  lKind: TRecorderTagEstimateKind;
  lIndex: Integer;
  lLabel: TLabel;
begin
  { The "Additional" tab mirrors the original Recorder estimate-calculation
    block. The controls only edit persistent tag settings; estimate calculation
    itself stays in uRecorderTags and recorder backends can consume it later. }
  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := ATab;
  lGroup.SetBounds(8, 8, 520, 250);
  lGroup.Caption := 'Вычисляемые оценки';

  lIndex := 0;
  for lKind := Low(TRecorderTagEstimateKind) to tekPeakToPeakByRmsDeviation do
  begin
    fEstimateChecks[lKind] := TCheckBox.Create(Self);
    fEstimateChecks[lKind].Parent := lGroup;
    fEstimateChecks[lKind].SetBounds(12, 20 + lIndex * 18, 490, 18);
    fEstimateChecks[lKind].Caption := CEstimateCaptions[lKind];
    Inc(lIndex);
  end;
  fEstimateChecks[tekLastValue] := nil;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := ATab;
  lLabel.SetBounds(16, 274, 130, 20);
  lLabel.Caption := 'Оценка по умолчанию';

  fDefaultEstimateCombo := TComboBox.Create(Self);
  fDefaultEstimateCombo.Parent := ATab;
  fDefaultEstimateCombo.SetBounds(150, 270, 370, 23);
  fDefaultEstimateCombo.Style := csDropDownList;
  for lKind := Low(TRecorderTagEstimateKind) to tekPeakToPeakByRmsDeviation do
    fDefaultEstimateCombo.Items.AddObject(
      RecorderTagEstimateKindToShortName(lKind), TObject(PtrInt(Ord(lKind))));

  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := ATab;
  lGroup.SetBounds(16, 306, 200, 58);
  lGroup.Caption := 'Длина порции';
  fPortionLengthEdit := TEdit.Create(Self);
  fPortionLengthEdit.Parent := lGroup;
  fPortionLengthEdit.SetBounds(12, 22, 104, 23);
  lLabel := TLabel.Create(Self);
  lLabel.Parent := lGroup;
  lLabel.SetBounds(124, 26, 60, 18);
  lLabel.Caption := 'отсчетов';

  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := ATab;
  lGroup.SetBounds(244, 306, 276, 58);
  lGroup.Caption := 'Усреднение y''=kx+(1-k)y';
  fSmoothingCheck := TCheckBox.Create(Self);
  fSmoothingCheck.Parent := lGroup;
  fSmoothingCheck.SetBounds(12, 24, 46, 18);
  fSmoothingCheck.Caption := 'k=';
  fSmoothingKEdit := TEdit.Create(Self);
  fSmoothingKEdit.Parent := lGroup;
  fSmoothingKEdit.SetBounds(62, 22, 92, 23);

  lGroup := TGroupBox.Create(Self);
  lGroup.Parent := ATab;
  lGroup.SetBounds(8, 376, 520, 74);
  lGroup.Caption := 'Свойства канала';
  fScadaCheck := TCheckBox.Create(Self);
  fScadaCheck.Parent := lGroup;
  fScadaCheck.SetBounds(16, 22, 120, 20);
  fScadaCheck.Caption := 'SCADA';
end;

procedure TTagSettingsDialog.BuildSetpointsTab(ATab: TTabSheet);
const
  CSetpointNames: array[TRecorderTagSetpointKind] of string = (
    'Верхняя аварийная',
    'Верхняя предупредительная',
    'Нижняя предупредительная',
    'Нижняя аварийная'
  );
var
  lKind: TRecorderTagSetpointKind;
  lTop: Integer;
  lRow: TPanel;
  lLabel: TLabel;
  lUnitLabel: TPanel;
  lText: TLabel;
begin
  { The "Setpoints" tab stores the four limit rows from the original Recorder
    dialog. Blue routing captions are intentionally read-only placeholders until
    the recorder output/sound backends exist in RecorderLnx. }
  for lKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
  begin
    lTop := 8 + Ord(lKind) * 82;
    lRow := TPanel.Create(Self);
    lRow.Parent := ATab;
    lRow.SetBounds(16, lTop, 510, 78);
    lRow.BevelOuter := bvLowered;

    lLabel := TLabel.Create(Self);
    lLabel.Parent := lRow;
    lLabel.SetBounds(12, 8, 190, 18);
    lLabel.Caption := CSetpointNames[lKind];
    lLabel.Font.Style := [fsBold];

    fSetpointEnabledChecks[lKind] := TCheckBox.Create(Self);
    fSetpointEnabledChecks[lKind].Parent := lRow;
    fSetpointEnabledChecks[lKind].SetBounds(12, 34, 52, 20);
    fSetpointEnabledChecks[lKind].Caption := 'Вкл';

    lUnitLabel := TPanel.Create(Self);
    lUnitLabel.Parent := lRow;
    lUnitLabel.SetBounds(226, 12, 18, 20);
    lUnitLabel.Caption := 'm';
    lUnitLabel.BorderStyle := bsSingle;
    lUnitLabel.BevelOuter := bvNone;

    fSetpointThresholdEdits[lKind] := TEdit.Create(Self);
    fSetpointThresholdEdits[lKind].Parent := lRow;
    fSetpointThresholdEdits[lKind].SetBounds(246, 10, 72, 23);

    lText := TLabel.Create(Self);
    lText.Parent := lRow;
    lText.SetBounds(68, 34, 150, 42);
    lText.Font.Color := clBlue;
    lText.Caption := 'Запись: выкл' + LineEnding +
      'Звук: выкл.' + LineEnding + 'Брать из: значение';

    lText := TLabel.Create(Self);
    lText.Parent := lRow;
    lText.SetBounds(332, 34, 90, 42);
    lText.Font.Color := clBlue;
    lText.Caption := 'Выдать в:' + LineEnding +
      'Значение: 1' + LineEnding + 'Гистерезис: 0%';

    fSetpointColorPanels[lKind] := TPanel.Create(Self);
    fSetpointColorPanels[lKind].Parent := lRow;
    fSetpointColorPanels[lKind].SetBounds(434, 28, 32, 28);
    fSetpointColorPanels[lKind].BevelOuter := bvLowered;
  end;

  lRow := TPanel.Create(Self);
  lRow.Parent := ATab;
  lRow.SetBounds(16, 338, 510, 86);
  lRow.BevelOuter := bvLowered;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := lRow;
  lLabel.SetBounds(12, 8, 120, 18);
  lLabel.Caption := 'Дополнительно';
  lLabel.Font.Style := [fsBold];

  fSetpointHysteresisCheck := TCheckBox.Create(Self);
  fSetpointHysteresisCheck.Parent := lRow;
  fSetpointHysteresisCheck.SetBounds(198, 8, 130, 20);
  fSetpointHysteresisCheck.Caption := 'Вкл. гистерезис';

  fSetpointStatusChannelCheck := TCheckBox.Create(Self);
  fSetpointStatusChannelCheck.Parent := lRow;
  fSetpointStatusChannelCheck.SetBounds(12, 34, 176, 20);
  fSetpointStatusChannelCheck.Caption := 'Канал состояния уставки:';
  fSetpointStatusChannelCheck.Font.Color := clBlue;

  fSetpointSoundCheck := TCheckBox.Create(Self);
  fSetpointSoundCheck.Parent := lRow;
  fSetpointSoundCheck.SetBounds(12, 58, 250, 20);
  fSetpointSoundCheck.Caption := 'Прослушать звуковое оповещение до конца';
end;

function TTagSettingsDialog.AllString(AKind: Integer; out AValue: string): Boolean;
var
  I: Integer;
  lValue: string;
begin
  AValue := '';
  if fTags.Count = 0 then
    Exit(False);

  case AKind of
    0: AValue := TagAt(0).Name;
    1: AValue := TagAt(0).UnitName;
    2: AValue := TagAt(0).Address;
    3: AValue := TagAt(0).Description;
    4: AValue := TagAt(0).ModuleType;
  end;

  for I := 1 to fTags.Count - 1 do
  begin
    case AKind of
      0: lValue := TagAt(I).Name;
      1: lValue := TagAt(I).UnitName;
      2: lValue := TagAt(I).Address;
      3: lValue := TagAt(I).Description;
      4: lValue := TagAt(I).ModuleType;
    else
      lValue := '';
    end;
    if not SameText(AValue, lValue) then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.AllFloat(AKind: Integer; out AValue: Double): Boolean;
var
  I: Integer;
  lValue: Double;
begin
  AValue := 0;
  if fTags.Count = 0 then
    Exit(False);

  case AKind of
    0: AValue := TagAt(0).PollFrequencyHz;
    1: AValue := TagAt(0).RangeMin;
    2: AValue := TagAt(0).RangeMax;
  end;

  for I := 1 to fTags.Count - 1 do
  begin
    case AKind of
      0: lValue := TagAt(I).PollFrequencyHz;
      1: lValue := TagAt(I).RangeMin;
      2: lValue := TagAt(I).RangeMax;
    else
      lValue := 0;
    end;
    if Abs(AValue - lValue) > 1E-9 then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.AllBool(AGetter: Integer): Integer;
var
  I: Integer;
  lValue: Boolean;
  lFirst: Boolean;
begin
  Result := -1;
  if fTags.Count = 0 then
    Exit;

  if AGetter = 0 then
    lFirst := TagAt(0).AutoUnit
  else
    lFirst := TagAt(0).AutoRange;

  for I := 1 to fTags.Count - 1 do
  begin
    if AGetter = 0 then
      lValue := TagAt(I).AutoUnit
    else
      lValue := TagAt(I).AutoRange;
    if lFirst <> lValue then
      Exit;
  end;

  if lFirst then
    Result := 1
  else
    Result := 0;
end;

function TTagSettingsDialog.AllEstimateBool(AKind: TRecorderTagEstimateKind;
  out AValue: Boolean): Boolean;
var
  I: Integer;
  lValue: Boolean;
begin
  AValue := TagAt(0).EstimateSettings.EnabledKinds[AKind];
  for I := 1 to fTags.Count - 1 do
  begin
    lValue := TagAt(I).EstimateSettings.EnabledKinds[AKind];
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.AllEstimateDefault(
  out AValue: TRecorderTagEstimateKind): Boolean;
var
  I: Integer;
begin
  AValue := TagAt(0).EstimateSettings.DefaultKind;
  for I := 1 to fTags.Count - 1 do
    if AValue <> TagAt(I).EstimateSettings.DefaultKind then
      Exit(False);
  Result := True;
end;

function TTagSettingsDialog.AllEstimateFlag(AGetter: Integer;
  out AValue: Boolean): Boolean;
var
  I: Integer;
  lValue: Boolean;
begin
  if AGetter = 0 then
    AValue := TagAt(0).EstimateSettings.SmoothingEnabled
  else
    AValue := TagAt(0).EstimateSettings.ScadaEnabled;

  for I := 1 to fTags.Count - 1 do
  begin
    if AGetter = 0 then
      lValue := TagAt(I).EstimateSettings.SmoothingEnabled
    else
      lValue := TagAt(I).EstimateSettings.ScadaEnabled;
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.AllEstimateFloat(AKind: Integer;
  out AValue: Double): Boolean;
var
  I: Integer;
  lValue: Double;
begin
  if AKind = 0 then
    AValue := TagAt(0).EstimateSettings.SmoothingK
  else
    Exit(False);

  for I := 1 to fTags.Count - 1 do
  begin
    lValue := TagAt(I).EstimateSettings.SmoothingK;
    if Abs(AValue - lValue) > 1E-9 then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.AllEstimateInt(out AValue: Integer): Boolean;
var
  I: Integer;
begin
  AValue := TagAt(0).EstimateSettings.PortionLength;
  for I := 1 to fTags.Count - 1 do
    if AValue <> TagAt(I).EstimateSettings.PortionLength then
      Exit(False);
  Result := True;
end;

function TTagSettingsDialog.AllSetpointBool(AKind: TRecorderTagSetpointKind;
  AGetter: Integer; out AValue: Boolean): Boolean;
var
  I: Integer;
  lSetpoint: TRecorderTagSetpoint;
  lValue: Boolean;
begin
  lSetpoint := TagAt(0).Setpoints[AKind];
  if AGetter = 0 then
    AValue := lSetpoint.Enabled
  else
    AValue := lSetpoint.OutputEnabled;

  for I := 1 to fTags.Count - 1 do
  begin
    lSetpoint := TagAt(I).Setpoints[AKind];
    if AGetter = 0 then
      lValue := lSetpoint.Enabled
    else
      lValue := lSetpoint.OutputEnabled;
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.AllSetpointFloat(AKind: TRecorderTagSetpointKind;
  AGetter: Integer; out AValue: Double): Boolean;
var
  I: Integer;
  lSetpoint: TRecorderTagSetpoint;
  lValue: Double;
begin
  lSetpoint := TagAt(0).Setpoints[AKind];
  if AGetter = 0 then
    AValue := lSetpoint.Threshold
  else
    AValue := lSetpoint.HysteresisPercent;

  for I := 1 to fTags.Count - 1 do
  begin
    lSetpoint := TagAt(I).Setpoints[AKind];
    if AGetter = 0 then
      lValue := lSetpoint.Threshold
    else
      lValue := lSetpoint.HysteresisPercent;
    if Abs(AValue - lValue) > 1E-9 then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.AllSetpointGlobalBool(AGetter: Integer;
  out AValue: Boolean): Boolean;
var
  I: Integer;
  lValue: Boolean;
begin
  case AGetter of
    0: AValue := TagAt(0).SetpointHysteresisEnabled;
    1: AValue := TagAt(0).SetpointSoundUntilEnd;
    2: AValue := TagAt(0).SetpointStatusChannelEnabled;
  else
    Exit(False);
  end;

  for I := 1 to fTags.Count - 1 do
  begin
    case AGetter of
      0: lValue := TagAt(I).SetpointHysteresisEnabled;
      1: lValue := TagAt(I).SetpointSoundUntilEnd;
      2: lValue := TagAt(I).SetpointStatusChannelEnabled;
    else
      lValue := False;
    end;
    if AValue <> lValue then
      Exit(False);
  end;
  Result := True;
end;

function TTagSettingsDialog.FrequencyCanBeEdited: Boolean;
var
  lValue: string;
begin
  Result := AllString(4, lValue);
end;

procedure TTagSettingsDialog.LoadFromTags;
var
  lText: string;
  lFloat: Double;
  lBool: Integer;
  lChecked: Boolean;
  lEstimateKind: TRecorderTagEstimateKind;
  lIndex: Integer;
  lInt: Integer;
  lSetpointKind: TRecorderTagSetpointKind;
begin
  if fTags.Count = 1 then
  begin
    Caption := 'Настройка канала ' + TagAt(0).Name;
    fNameEdit.Text := TagAt(0).Name;
    fNameEdit.Enabled := True;
  end
  else
  begin
    Caption := Format('Настройка каналов (%d)', [fTags.Count]);
    fNameEdit.Text := '';
    fNameEdit.Enabled := False;
  end;

  if AllString(1, lText) then
    fUnitCombo.Text := lText
  else
    fUnitCombo.Text := '';
  if AllString(2, lText) then
    fModuleEdit.Text := lText
  else
    fModuleEdit.Text := '';
  if AllString(3, lText) then
    fDescriptionEdit.Text := lText
  else
    fDescriptionEdit.Text := '';

  if AllFloat(0, lFloat) and (lFloat > 0) then
    fFrequencyCombo.Text := FormatFloat('0.######', lFloat)
  else
    fFrequencyCombo.Text := '';
  fFrequencyCombo.Enabled := FrequencyCanBeEdited;

  if AllFloat(1, lFloat) then
    fMinEdit.Text := FormatFloat('0.######', lFloat)
  else
    fMinEdit.Text := '';
  if AllFloat(2, lFloat) then
    fMaxEdit.Text := FormatFloat('0.######', lFloat)
  else
    fMaxEdit.Text := '';

  lBool := AllBool(0);
  fAutoUnitCheck.AllowGrayed := fTags.Count > 1;
  if lBool < 0 then
    fAutoUnitCheck.State := cbGrayed
  else
    fAutoUnitCheck.Checked := lBool > 0;

  lBool := AllBool(1);
  fAutoRangeCheck.AllowGrayed := fTags.Count > 1;
  if lBool < 0 then
    fAutoRangeCheck.State := cbGrayed
  else
    fAutoRangeCheck.Checked := lBool > 0;

  { Additional tab: load common estimate calculation settings. Mixed values use
    grayed/empty controls and are left unchanged by StoreToTags. }
  for lEstimateKind := Low(TRecorderTagEstimateKind) to tekPeakToPeakByRmsDeviation do
  begin
    fEstimateChecks[lEstimateKind].AllowGrayed := fTags.Count > 1;
    if AllEstimateBool(lEstimateKind, lChecked) then
      fEstimateChecks[lEstimateKind].Checked := lChecked
    else
      fEstimateChecks[lEstimateKind].State := cbGrayed;
  end;

  if AllEstimateDefault(lEstimateKind) then
  begin
    lIndex := Ord(lEstimateKind);
    if (lIndex >= 0) and (lIndex < fDefaultEstimateCombo.Items.Count) then
      fDefaultEstimateCombo.ItemIndex := lIndex
    else
      fDefaultEstimateCombo.ItemIndex := -1;
  end
  else
    fDefaultEstimateCombo.ItemIndex := -1;

  if AllEstimateInt(lInt) then
    fPortionLengthEdit.Text := IntToStr(lInt)
  else
    fPortionLengthEdit.Text := '';

  fSmoothingCheck.AllowGrayed := fTags.Count > 1;
  if AllEstimateFlag(0, lChecked) then
    fSmoothingCheck.Checked := lChecked
  else
    fSmoothingCheck.State := cbGrayed;
  if AllEstimateFloat(0, lFloat) then
    fSmoothingKEdit.Text := FormatFloat('0.######', lFloat)
  else
    fSmoothingKEdit.Text := '';

  fScadaCheck.AllowGrayed := fTags.Count > 1;
  if AllEstimateFlag(1, lChecked) then
    fScadaCheck.Checked := lChecked
  else
    fScadaCheck.State := cbGrayed;

  { Setpoints tab: load four threshold rows and global setpoint flags. }
  for lSetpointKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
  begin
    fSetpointEnabledChecks[lSetpointKind].AllowGrayed := fTags.Count > 1;
    if AllSetpointBool(lSetpointKind, 0, lChecked) then
      fSetpointEnabledChecks[lSetpointKind].Checked := lChecked
    else
      fSetpointEnabledChecks[lSetpointKind].State := cbGrayed;

    if AllSetpointFloat(lSetpointKind, 0, lFloat) then
      fSetpointThresholdEdits[lSetpointKind].Text := FormatFloat('0.######', lFloat)
    else
      fSetpointThresholdEdits[lSetpointKind].Text := '';

    fSetpointColorPanels[lSetpointKind].Color :=
      TColor(TagAt(0).Setpoints[lSetpointKind].Color);
  end;

  fSetpointHysteresisCheck.AllowGrayed := fTags.Count > 1;
  if AllSetpointGlobalBool(0, lChecked) then
    fSetpointHysteresisCheck.Checked := lChecked
  else
    fSetpointHysteresisCheck.State := cbGrayed;

  fSetpointSoundCheck.AllowGrayed := fTags.Count > 1;
  if AllSetpointGlobalBool(1, lChecked) then
    fSetpointSoundCheck.Checked := lChecked
  else
    fSetpointSoundCheck.State := cbGrayed;

  fSetpointStatusChannelCheck.AllowGrayed := fTags.Count > 1;
  if AllSetpointGlobalBool(2, lChecked) then
    fSetpointStatusChannelCheck.Checked := lChecked
  else
    fSetpointStatusChannelCheck.State := cbGrayed;
end;

function TTagSettingsDialog.ReadFloat(const AText: string;
  out AValue: Double): Boolean;
var
  lText: string;
begin
  lText := StringReplace(Trim(AText), '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  Result := TryStrToFloat(lText, AValue);
end;

procedure TTagSettingsDialog.StoreToTags;
var
  I: Integer;
  lTag: TRecorderTag;
  lExisting: TRecorderTag;
  lEstimateKind: TRecorderTagEstimateKind;
  lEstimateSettings: TRecorderTagEstimateSettings;
  lFloat: Double;
  lInt: Integer;
  lSetpoint: TRecorderTagSetpoint;
  lSetpointKind: TRecorderTagSetpointKind;
begin
  if fNameEdit.Enabled and (Trim(fNameEdit.Text) <> '') then
  begin
    lExisting := fTagRegistry.FindByName(Trim(fNameEdit.Text));
    if (lExisting <> nil) and (lExisting <> TagAt(0)) then
      raise ERecorderTagError.Create('Tag name already exists: ' + Trim(fNameEdit.Text));
    TagAt(0).Name := Trim(fNameEdit.Text);
  end;

  for I := 0 to fTags.Count - 1 do
  begin
    lTag := TagAt(I);
    if Trim(fUnitCombo.Text) <> '' then
      lTag.UnitName := Trim(fUnitCombo.Text);
    if Trim(fDescriptionEdit.Text) <> '' then
      lTag.Description := Trim(fDescriptionEdit.Text);
    if fFrequencyCombo.Enabled and (Trim(fFrequencyCombo.Text) <> '') then
    begin
      if not ReadFloat(fFrequencyCombo.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid poll frequency');
      lTag.PollFrequencyHz := lFloat;
    end;
    if Trim(fMinEdit.Text) <> '' then
    begin
      if not ReadFloat(fMinEdit.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid lower range value');
      lTag.RangeMin := lFloat;
    end;
    if Trim(fMaxEdit.Text) <> '' then
    begin
      if not ReadFloat(fMaxEdit.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid upper range value');
      lTag.RangeMax := lFloat;
    end;
    if fAutoUnitCheck.State <> cbGrayed then
      lTag.AutoUnit := fAutoUnitCheck.Checked;
    if fAutoRangeCheck.State <> cbGrayed then
      lTag.AutoRange := fAutoRangeCheck.Checked;

    { Additional tab: write only explicit values. Mixed multi-select controls
      are grayed or empty and therefore do not overwrite tag-specific settings. }
    lEstimateSettings := lTag.EstimateSettings;
    for lEstimateKind := Low(TRecorderTagEstimateKind) to tekPeakToPeakByRmsDeviation do
      if fEstimateChecks[lEstimateKind].State <> cbGrayed then
        lEstimateSettings.EnabledKinds[lEstimateKind] :=
          fEstimateChecks[lEstimateKind].Checked;
    if fDefaultEstimateCombo.ItemIndex >= 0 then
      lEstimateSettings.DefaultKind := TRecorderTagEstimateKind(PtrInt(
        fDefaultEstimateCombo.Items.Objects[fDefaultEstimateCombo.ItemIndex]));
    if Trim(fPortionLengthEdit.Text) <> '' then
    begin
      if not TryStrToInt(Trim(fPortionLengthEdit.Text), lInt) or (lInt <= 0) then
        raise ERecorderTagError.Create('Invalid estimate portion length');
      lEstimateSettings.PortionLength := lInt;
    end;
    if fSmoothingCheck.State <> cbGrayed then
      lEstimateSettings.SmoothingEnabled := fSmoothingCheck.Checked;
    if Trim(fSmoothingKEdit.Text) <> '' then
    begin
      if not ReadFloat(fSmoothingKEdit.Text, lFloat) then
        raise ERecorderTagError.Create('Invalid smoothing coefficient');
      lEstimateSettings.SmoothingK := lFloat;
    end;
    if fScadaCheck.State <> cbGrayed then
      lEstimateSettings.ScadaEnabled := fScadaCheck.Checked;
    lTag.EstimateSettings := lEstimateSettings;

    { Setpoints tab: update enabled flags, thresholds and global options. }
    for lSetpointKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
    begin
      lSetpoint := lTag.Setpoints[lSetpointKind];
      if fSetpointEnabledChecks[lSetpointKind].State <> cbGrayed then
        lSetpoint.Enabled := fSetpointEnabledChecks[lSetpointKind].Checked;
      if Trim(fSetpointThresholdEdits[lSetpointKind].Text) <> '' then
      begin
        if not ReadFloat(fSetpointThresholdEdits[lSetpointKind].Text, lFloat) then
          raise ERecorderTagError.Create('Invalid setpoint threshold');
        lSetpoint.Threshold := lFloat;
      end;
      lTag.Setpoints[lSetpointKind] := lSetpoint;
    end;
    if fSetpointHysteresisCheck.State <> cbGrayed then
      lTag.SetpointHysteresisEnabled := fSetpointHysteresisCheck.Checked;
    if fSetpointSoundCheck.State <> cbGrayed then
      lTag.SetpointSoundUntilEnd := fSetpointSoundCheck.Checked;
    if fSetpointStatusChannelCheck.State <> cbGrayed then
      lTag.SetpointStatusChannelEnabled := fSetpointStatusChannelCheck.Checked;
  end;
end;

procedure TTagSettingsDialog.ApplyButtonClick(Sender: TObject);
begin
  StoreToTags;
  LoadFromTags;
end;

procedure TTagSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToTags;
  ModalResult := mrOk;
end;

end.
