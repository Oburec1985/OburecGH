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
    edBlockSize: TSpinEdit;
    edEndpoint: TEdit;
    edInputSearch: TEdit;
    edMax: TFloatSpinEdit;
    edMin: TFloatSpinEdit;
    edMirrorSearch: TEdit;
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
  private
    fComponent: TRecorderDacComponent;
    fFactory: TRecorderDacComponentFactory;
    fRegistry: TRecorderTagRegistry;
    fLoaded: Boolean;
    fInputSelectedId: TRecorderTagId;
    fMirrorSelectedId: TRecorderTagId;
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
  lIndex: Integer;
begin
  fFactory.GetBackendIds(cbBackend.Items);
  lIndex := cbBackend.Items.IndexOf(fComponent.BackendId);
  if lIndex < 0 then
  begin
    cbBackend.Items.Add(fComponent.BackendId);
    lIndex := cbBackend.Items.Count - 1;
  end;
  cbBackend.ItemIndex := lIndex;
  cbEnabled.Checked := fComponent.Enabled;
  edEndpoint.Text := fComponent.Endpoint;
  edSampleRate.Value := fComponent.SampleRateHz;
  edBlockSize.Value := fComponent.FramesPerBlock;
  edMin.Value := fComponent.MinimumValue;
  edMax.Value := fComponent.MaximumValue;
  edSafe.Value := fComponent.SafeValue;
  cbUnderrun.ItemIndex := Ord(fComponent.UnderrunPolicy);
  cbMirror.Checked := fComponent.MirrorEnabled;
  fInputSelectedId := fComponent.InputTagId;
  fMirrorSelectedId := fComponent.MirrorTagId;
  FillTagList(lbInput, '', fInputSelectedId);
  FillTagList(lbMirror, '', fMirrorSelectedId);
  UpdateMirrorControls;
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
begin
  fMirrorSelectedId := SelectedTagId(lbMirror);
end;

procedure TRecorderDacSettingsDialog.MirrorClick(Sender: TObject);
begin
  UpdateMirrorControls;
end;

procedure TRecorderDacSettingsDialog.UpdateMirrorControls;
begin
  edMirrorSearch.Enabled := cbMirror.Checked;
  lbMirror.Enabled := cbMirror.Checked;
end;

function TRecorderDacSettingsDialog.ValidateSettings(
  out AMessage: string): Boolean;
var
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
begin
  Result := False;
  if (fComponent.SourceMode = rdsmTag) and (SelectedTag(lbInput) = nil) then
  begin
    AMessage := 'Выберите входной тег ЦАП.';
    Exit;
  end;
  if cbMirror.Checked and (SelectedTag(lbMirror) = nil) then
  begin
    AMessage := 'Выберите тег зеркала или выключите зеркалирование.';
    Exit;
  end;
  if cbMirror.Checked and
    (SelectedTagId(lbInput) = SelectedTagId(lbMirror)) then
  begin
    AMessage := 'Входной тег и тег зеркала должны различаться.';
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
  lInput, lMirror: TRecorderTag;
begin
  lInput := SelectedTag(lbInput);
  lMirror := SelectedTag(lbMirror);
  fComponent.Enabled := cbEnabled.Checked;
  fComponent.BackendId := cbBackend.Text;
  fComponent.Endpoint := Trim(edEndpoint.Text);
  if lInput <> nil then
  begin
    fComponent.InputTagId := lInput.Id;
    fComponent.InputTagName := lInput.Name;
  end;
  fComponent.MirrorEnabled := cbMirror.Checked;
  if cbMirror.Checked then
  begin
    fComponent.MirrorTagId := lMirror.Id;
    fComponent.MirrorTagName := lMirror.Name;
  end
  else
  begin
    fComponent.MirrorTagId := 0;
    fComponent.MirrorTagName := '';
  end;
  fComponent.SampleRateHz := edSampleRate.Value;
  fComponent.FramesPerBlock := edBlockSize.Value;
  fComponent.MinimumValue := edMin.Value;
  fComponent.MaximumValue := edMax.Value;
  fComponent.SafeValue := edSafe.Value;
  fComponent.UnderrunPolicy := TRecorderDacUnderrunPolicy(cbUnderrun.ItemIndex);
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
