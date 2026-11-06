unit uRecorderDacSettingsDialog;

{ Transactional editor for DAC routing and transport settings. Tag lists use
  stable IDs and substring search over name, address and description. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, LazUTF8, Forms, Controls, StdCtrls, ExtCtrls, Spin, Dialogs,
  uRecorderTags, uRecorderDacTypes, uRecorderDacComponentModel;

type
  TRecorderDacSettingsDialog = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    cbBackend: TComboBox;
    cbEnabled: TCheckBox;
    cbMirror: TCheckBox;
    cbUnderrun: TComboBox;
    cbFeedbackSync: TCheckBox;
    rgPhaseCalibrationMode: TRadioGroup;
    btnFeedbackTag: TButton;
    edFeedbackTag: TEdit;
    edFeedbackTimeout, edFeedbackCalibrationDuration: TFloatSpinEdit;
    gbCalibration: TGroupBox;
    lblFeedbackTimeout, lblFeedbackCalibrationDuration: TLabel;
    edBlockSize: TSpinEdit;
    edEndpoint: TEdit;
    edInputSearch: TEdit;
    edMax: TFloatSpinEdit;
    edMin: TFloatSpinEdit;
    edMirrorSearch: TEdit;
    edMirrorName: TEdit;
    edSafe: TFloatSpinEdit;
    edSampleRate: TFloatSpinEdit;
    gbDevice: TGroupBox;
    gbInput: TGroupBox;
    gbMirror: TGroupBox;
    lbInput: TListBox;
    lbMirror: TListBox;
    lblBackend: TLabel;
    lblBlockSize: TLabel;
    lblEndpoint: TLabel;
    lblMax: TLabel;
    lblMin: TLabel;
    lblSafe: TLabel;
    lblSampleRate: TLabel;
    lblUnderrun: TLabel;
    procedure FormShow(Sender: TObject);
    procedure InputSearchChange(Sender: TObject);
    procedure InputTagClick(Sender: TObject);
    procedure MirrorClick(Sender: TObject);
    procedure MirrorSearchChange(Sender: TObject);
    procedure MirrorTagClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure DeviceChange(Sender: TObject);
    procedure SelectFeedbackTag(Sender: TObject);
    procedure FeedbackSyncClick(Sender: TObject);
  private
    fComponent: TRecorderDacComponent;
    fFactory: TRecorderDacComponentFactory;
    fRegistry: TRecorderTagRegistry;
    fLoaded: Boolean;
    fEndpoints: TRecorderDacEndpoints;
    fInputSelectedId: TRecorderTagId;
    fMirrorSelectedId: TRecorderTagId;
    fFeedbackSelectedId: TRecorderTagId;
    procedure FillTagList(AList: TListBox; const AFilter: string;
      ASelectedId: TRecorderTagId);
    function SelectedTag(AList: TListBox): TRecorderTag;
    function SelectedTagId(AList: TListBox): TRecorderTagId;
    procedure LoadSettings;
    procedure UpdateMirrorControls;
    function ValidateSettings(out AMessage: string): Boolean;
    procedure ApplySettings;
  public
    class function Execute(AOwner: TComponent;
      AComponent: TRecorderDacComponent; ARegistry: TRecorderTagRegistry): Boolean;
  end;

implementation

uses uRecorderTagPickerDialog;

{$R *.lfm}

class function TRecorderDacSettingsDialog.Execute(AOwner: TComponent;
  AComponent: TRecorderDacComponent; ARegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderDacSettingsDialog;
begin
  Result := False;
  if (AComponent = nil) or
    not (AComponent.Factory is TRecorderDacComponentFactory) then Exit;
  lDialog := TRecorderDacSettingsDialog.Create(AOwner);
  try
    lDialog.fComponent := AComponent;
    lDialog.fFactory := TRecorderDacComponentFactory(AComponent.Factory);
    lDialog.fRegistry := ARegistry;
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderDacSettingsDialog.FormShow(Sender: TObject);
begin
  if fLoaded then Exit;
  fLoaded := True;
  LoadSettings;
end;

procedure TRecorderDacSettingsDialog.LoadSettings;
var
  I, lIndex: Integer;
  lResult: TRecorderDacResult;
begin
  fFactory.DiscoverEndpoints(fEndpoints, lResult);
  cbBackend.Items.Clear;
  lIndex := -1;
  for I := 0 to High(fEndpoints) do
  begin
    cbBackend.Items.Add(fEndpoints[I].DisplayName);
    if SameText(fEndpoints[I].BackendId, fComponent.BackendId) and
      SameText(fEndpoints[I].Endpoint, fComponent.Endpoint) then lIndex := I;
  end;
  if lIndex < 0 then
  begin
    SetLength(fEndpoints, Length(fEndpoints) + 1);
    I := High(fEndpoints);
    fEndpoints[I].BackendId := fComponent.BackendId;
    fEndpoints[I].Endpoint := fComponent.Endpoint;
    fEndpoints[I].SampleRateHz := 0;
    cbBackend.Items.Add(fComponent.BackendId + ': ' + fComponent.Endpoint + ' (недоступно)');
    lIndex := cbBackend.Items.Count - 1;
  end;
  cbBackend.ItemIndex := lIndex;
  cbEnabled.Checked := fComponent.Enabled;
  edEndpoint.Text := fComponent.Endpoint;
  edSampleRate.Value := fComponent.SampleRateHz;
  DeviceChange(nil);
  edBlockSize.Value := fComponent.FramesPerBlock;
  edMin.Value := fComponent.MinimumValue;
  edMax.Value := fComponent.MaximumValue;
  edSafe.Value := fComponent.SafeValue;
  cbUnderrun.ItemIndex := Ord(fComponent.UnderrunPolicy);
  cbMirror.Checked := fComponent.MirrorEnabled;
  fInputSelectedId := fComponent.InputTagId;
  fMirrorSelectedId := fComponent.MirrorTagId;
  edMirrorName.Text := fComponent.MirrorTagName;
  fFeedbackSelectedId := fComponent.FeedbackTagId;
  edFeedbackTag.Text := fComponent.FeedbackTagName;
  cbFeedbackSync.Checked := fComponent.SynchronizeByFeedback;
  rgPhaseCalibrationMode.ItemIndex := Ord(fComponent.PhaseCalibrationMode);
  FeedbackSyncClick(nil);
  edFeedbackTimeout.Value := fComponent.FeedbackTimeoutSec;
  edFeedbackCalibrationDuration.Value := fComponent.FeedbackCalibrationDurationSec;
  FillTagList(lbInput, '', fInputSelectedId);
  FillTagList(lbMirror, '', fMirrorSelectedId);
  UpdateMirrorControls;
end;

procedure TRecorderDacSettingsDialog.SelectFeedbackTag(Sender: TObject);
var
  lTag: TRecorderTag;
begin
  if not ShowRecorderTagPickerDialog(Self, fRegistry,
    edFeedbackTag.Text, True, lTag, True) then Exit;
  fFeedbackSelectedId := lTag.Id;
  edFeedbackTag.Text := lTag.Name;
end;

procedure TRecorderDacSettingsDialog.DeviceChange(Sender: TObject);
var
  I: Integer;
begin
  I := cbBackend.ItemIndex;
  if (I < 0) or (I >= Length(fEndpoints)) then Exit;
  edEndpoint.Text := fEndpoints[I].Endpoint;
  edSampleRate.Enabled := fEndpoints[I].SampleRateHz <= 0;
  if fEndpoints[I].SampleRateHz > 0 then
    edSampleRate.Value := fEndpoints[I].SampleRateHz;
end;

procedure TRecorderDacSettingsDialog.FillTagList(AList: TListBox;
  const AFilter: string; ASelectedId: TRecorderTagId);
var
  I, lIndex: Integer;
  lNeedle, lText: string;
  lTag: TRecorderTag;
begin
  AList.Items.BeginUpdate;
  try
    AList.Clear;
    if fRegistry = nil then Exit;
    lNeedle := UTF8LowerCase(Trim(AFilter));
    lIndex := -1;
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      lTag := fRegistry.Tags[I];
      if (AList = lbMirror) and not lTag.IsVirtual then Continue;
      if (AList = lbMirror) and (lTag.Id = fInputSelectedId) then Continue;
      lText := lTag.Name + '  ' + lTag.Address + '  ' + lTag.Description;
      if (lNeedle <> '') and
        (Pos(lNeedle, UTF8LowerCase(lText)) = 0) then Continue;
      AList.Items.AddObject(lText, lTag);
      if lTag.Id = ASelectedId then lIndex := AList.Items.Count - 1;
    end;
    AList.ItemIndex := lIndex;
  finally
    AList.Items.EndUpdate;
  end;
end;

function TRecorderDacSettingsDialog.SelectedTag(AList: TListBox): TRecorderTag;
begin
  Result := nil;
  if (AList.ItemIndex >= 0) and (AList.ItemIndex < AList.Count) then
    Result := TRecorderTag(AList.Items.Objects[AList.ItemIndex]);
  if (Result = nil) and (fRegistry <> nil) then
    if AList = lbInput then
      Result := fRegistry.FindById(fInputSelectedId)
    else if AList = lbMirror then
      Result := fRegistry.FindById(fMirrorSelectedId);
end;

function TRecorderDacSettingsDialog.SelectedTagId(
  AList: TListBox): TRecorderTagId;
var
  lTag: TRecorderTag;
begin
  lTag := SelectedTag(AList);
  if lTag <> nil then Result := lTag.Id else Result := 0;
end;

procedure TRecorderDacSettingsDialog.InputSearchChange(Sender: TObject);
begin
  FillTagList(lbInput, edInputSearch.Text, fInputSelectedId);
end;

procedure TRecorderDacSettingsDialog.InputTagClick(Sender: TObject);
begin
  fInputSelectedId := SelectedTagId(lbInput);
  if fMirrorSelectedId = fInputSelectedId then
    fMirrorSelectedId := 0;
  FillTagList(lbMirror, edMirrorSearch.Text, fMirrorSelectedId);
end;

procedure TRecorderDacSettingsDialog.MirrorSearchChange(Sender: TObject);
begin
  FillTagList(lbMirror, edMirrorSearch.Text, fMirrorSelectedId);
end;

procedure TRecorderDacSettingsDialog.MirrorTagClick(Sender: TObject);
var
  lTag: TRecorderTag;
begin
  fMirrorSelectedId := SelectedTagId(lbMirror);
  lTag := SelectedTag(lbMirror);
  if lTag <> nil then edMirrorName.Text := lTag.Name;
end;

procedure TRecorderDacSettingsDialog.FeedbackSyncClick(Sender: TObject);
begin
  rgPhaseCalibrationMode.Enabled := cbFeedbackSync.Checked;
end;

procedure TRecorderDacSettingsDialog.MirrorClick(Sender: TObject);
begin
  UpdateMirrorControls;
end;

procedure TRecorderDacSettingsDialog.UpdateMirrorControls;
begin
  edMirrorSearch.Enabled := cbMirror.Checked;
  edMirrorName.Enabled := cbMirror.Checked;
  lbMirror.Enabled := cbMirror.Checked;
end;

function TRecorderDacSettingsDialog.ValidateSettings(
  out AMessage: string): Boolean;
var
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
  lTag: TRecorderTag;
begin
  Result := False;
  if cbFeedbackSync.Checked then
  begin
    lTag := nil;
    if fRegistry <> nil then lTag := fRegistry.FindById(fFeedbackSelectedId);
    if (lTag = nil) or lTag.IsVirtual or not RecorderTagCanProvideBlocks(lTag) then
    begin
      AMessage := 'Выберите аппаратный векторный тег обратной связи.';
      Exit;
    end;
  end;
  if edFeedbackTimeout.Value <= 0 then
  begin
    AMessage := 'Время ожидания должно быть больше нуля.';
    Exit;
  end;
  if (edFeedbackCalibrationDuration.Value < 0.6) or
    (edFeedbackCalibrationDuration.Value > 30) then
  begin
    AMessage := 'Время калибровочного сигнала должно быть от 0,6 до 30 с.';
    Exit;
  end;
  if edFeedbackTimeout.Value < edFeedbackCalibrationDuration.Value + 0.5 then
  begin
    AMessage := 'Ожидание должно превышать время калибровочного сигнала минимум на 0,5 с.';
    Exit;
  end;
  if cbMirror.Checked then
  begin
    if fRegistry = nil then
    begin
      AMessage := 'Реестр тегов недоступен.';
      Exit;
    end;
    lTag := fRegistry.FindByName(Trim(edMirrorName.Text));
    if (lTag <> nil) and not lTag.IsVirtual then
    begin
      AMessage := 'Для зеркала разрешены только виртуальные теги. Укажите другое имя.';
      Exit;
    end;
    if (lTag <> nil) and (fComponent.SourceMode = rdsmTag) and
      (lTag.Id = SelectedTagId(lbInput)) then
    begin
      AMessage := 'Входной тег и зеркало должны различаться.';
      Exit;
    end;
  end;
  if (fComponent.SourceMode = rdsmTag) and (SelectedTag(lbInput) = nil) then
  begin
    AMessage := 'Выберите входной тег ЦАП.';
    Exit;
  end;
  lConfig.SampleRateHz := edSampleRate.Value;
  lConfig.ChannelCount := 1;
  lConfig.FramesPerBlock := edBlockSize.Value;
  lConfig.MinimumValue := edMin.Value;
  lConfig.MaximumValue := edMax.Value;
  lConfig.SafeValue := edSafe.Value;
  lConfig.UnderrunPolicy := TRecorderDacUnderrunPolicy(cbUnderrun.ItemIndex);
  Result := RecorderDacValidateConfig(lConfig, lResult);
  if not Result then AMessage := lResult.Text;
end;

procedure TRecorderDacSettingsDialog.ApplySettings;
var
  lInput: TRecorderTag;
begin
  lInput := SelectedTag(lbInput);
  fComponent.Enabled := cbEnabled.Checked;
  if (cbBackend.ItemIndex >= 0) and (cbBackend.ItemIndex < Length(fEndpoints)) then
    fComponent.BackendId := fEndpoints[cbBackend.ItemIndex].BackendId;
  fComponent.Endpoint := Trim(edEndpoint.Text);
  if lInput <> nil then
  begin
    fComponent.InputTagId := lInput.Id;
    fComponent.InputTagName := lInput.Name;
  end;
  fComponent.MirrorEnabled := cbMirror.Checked;
  fComponent.FeedbackTagId := fFeedbackSelectedId;
  fComponent.FeedbackTagName := edFeedbackTag.Text;
  fComponent.SynchronizeByFeedback := cbFeedbackSync.Checked;
  fComponent.PhaseCalibrationMode := TRecorderDacPhaseCalibrationMode(
    rgPhaseCalibrationMode.ItemIndex);
  fComponent.FeedbackTimeoutSec := edFeedbackTimeout.Value;
  fComponent.FeedbackCalibrationDurationSec := edFeedbackCalibrationDuration.Value;
  if cbMirror.Checked then
  begin
    fComponent.MirrorTagName := Trim(edMirrorName.Text);
    fComponent.MirrorTagId := 0;
  end;
  fComponent.SampleRateHz := edSampleRate.Value;
  fComponent.FramesPerBlock := edBlockSize.Value;
  fComponent.MinimumValue := edMin.Value;
  fComponent.MaximumValue := edMax.Value;
  fComponent.SafeValue := edSafe.Value;
  fComponent.UnderrunPolicy := TRecorderDacUnderrunPolicy(cbUnderrun.ItemIndex);
  if cbMirror.Checked then fComponent.EnsureMirrorTag(fRegistry);
end;

procedure TRecorderDacSettingsDialog.OkClick(Sender: TObject);
var
  lMessage: string;
begin
  if not ValidateSettings(lMessage) then
  begin
    MessageDlg(lMessage, mtError, [mbOK], 0);
    Exit;
  end;
  ApplySettings;
  ModalResult := mrOk;
end;

end.
