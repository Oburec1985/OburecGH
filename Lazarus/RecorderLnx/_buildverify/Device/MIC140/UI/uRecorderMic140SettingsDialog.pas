unit uRecorderMic140SettingsDialog;

{
  MIC-140 setup dialog (LFM layout, editable in Lazarus IDE).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids, Buttons, Dialogs, Menus,
  uRecorderTags, uRecorderDataSources, uRecorderMic140DataSource, uRecorderMic140Utils,
  uRecorderMic140DeviceConfig;

function ShowRecorderMic140SettingsDialog(AOwner: TComponent;
  var AResult: TRecorderMic140DialogResult;
  ATagRegistry: TRecorderTagRegistry = nil; const ASourceId: string = '';
  ADataSources: TRecorderDataSourceManager = nil): Boolean;
function ApplyRecorderMic140SourceDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; AMic140Configs: TStringList;
  const ASourceId: string; out ANewSourceId: string): Boolean;

implementation

uses
  Math, uRecorderMic140ChannelDialog;

type
  TRecorderMic140SettingsDialog = class(TForm)
    pnTop: TPanel;
    lbSerial: TLabel;
    fSerialEdit: TEdit;
    lbVersion: TLabel;
    fVersionEdit: TEdit;
    lbHost: TLabel;
    fHostEdit: TEdit;
    lbPort: TLabel;
    fPortEdit: TEdit;
    lbChannelCount: TLabel;
    fChannelCountCombo: TComboBox;
    btnSearch: TButton;
    btnTest: TButton;
    fThermoCompCheck: TCheckBox;
    fGrid: TStringGrid;
    pnBottom: TPanel;
    pnButtons: TPanel;
    btnBalance: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure GridClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChannelPropertiesClick(Sender: TObject);
    procedure ChannelCountChange(Sender: TObject);
    procedure SearchClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure BalanceClick(Sender: TObject);
  private
    fTagRegistry: TRecorderTagRegistry;
    fSourceId: string;
    fDataSources: TRecorderDataSourceManager;
    fDeviceSerial: Integer;
    fDevSubRev: Integer;
    fChannelSettings: array of TRecorderMic140ChannelSettings;
    fGridPopup: TPopupMenu;
    procedure InitGrid;
    procedure EnsureChannelSettings(AChannelCount: Integer);
    procedure FillGrid(AChannelCount: Integer; ASelected: TStrings);
    procedure ToggleGridRow(ARow: Integer);
    function CollectTargetChannelRows(AClickRow: Integer): TStringList;
    procedure OpenChannelsDialog(ARows: TStrings);
    procedure OpenChannelDialog(ARow: Integer);
    procedure UpdateDeviceCaption;
    procedure QueryDeviceInfo;
    function ReadPort: Word;
    function ReadChannelCount: Integer;
    function ChannelAddressText(AChannelNumber: Integer): string;
    function CollectSelectedChannels: TStringList;
    function FindTagForChannel(AChannelNumber: Integer): TRecorderTag;
    procedure SyncChannelSoftBalanceToTag(AChannelNumber: Integer);
  public
    procedure ConfigureContext(ATagRegistry: TRecorderTagRegistry;
      const ASourceId: string; ADataSources: TRecorderDataSourceManager = nil);
    procedure LoadFromResult(const AResult: TRecorderMic140DialogResult);
    procedure StoreToResult(var AResult: TRecorderMic140DialogResult);
  end;

{$R *.lfm}

function ShowRecorderMic140SettingsDialog(AOwner: TComponent;
  var AResult: TRecorderMic140DialogResult;
  ATagRegistry: TRecorderTagRegistry; const ASourceId: string;
  ADataSources: TRecorderDataSourceManager): Boolean;
var
  lDialog: TRecorderMic140SettingsDialog;
begin
  lDialog := TRecorderMic140SettingsDialog.Create(AOwner);
  try
    lDialog.ConfigureContext(ATagRegistry, ASourceId, ADataSources);
    lDialog.LoadFromResult(AResult);
    Result := lDialog.ShowModal = mrOk;
    if Result then
      lDialog.StoreToResult(AResult);
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.FormCreate(Sender: TObject);
var
  lItem: TMenuItem;
begin
  fDeviceSerial := 0;
  fDevSubRev := CMic140Mic140SubRev1;
  fTagRegistry := nil;
  fSourceId := '';
  fDataSources := nil;
  SetLength(fChannelSettings, 0);
  InitGrid;
  btnBalance.OnClick := @BalanceClick;

  fGridPopup := TPopupMenu.Create(Self);
  lItem := TMenuItem.Create(fGridPopup);
  lItem.Caption := 'Свойства каналов...';
  lItem.OnClick := @ChannelPropertiesClick;
  fGridPopup.Items.Add(lItem);
  fGrid.PopupMenu := fGridPopup;
end;

procedure TRecorderMic140SettingsDialog.InitGrid;
begin
  fGrid.ColCount := 8;
  fGrid.Cells[0, 0] := 'Исп.';
  fGrid.Cells[1, 0] := 'Адрес';
  fGrid.Cells[2, 0] := 'Имя';
  fGrid.Cells[3, 0] := 'Диапазон [°C]';
  fGrid.Cells[4, 0] := 'Канал КХС';
  fGrid.Cells[5, 0] := 'Диапазон [mV]';
  fGrid.Cells[6, 0] := 'ГХ';
  fGrid.Cells[7, 0] := 'Баланс';
  fGrid.ColWidths[0] := 36;
  fGrid.ColWidths[1] := 76;
  fGrid.ColWidths[2] := 120;
  fGrid.ColWidths[3] := 88;
  fGrid.ColWidths[4] := 64;
  fGrid.ColWidths[5] := 88;
  fGrid.ColWidths[6] := 100;
  fGrid.ColWidths[7] := 64;
end;

procedure TRecorderMic140SettingsDialog.ConfigureContext(
  ATagRegistry: TRecorderTagRegistry; const ASourceId: string;
  ADataSources: TRecorderDataSourceManager);
begin
  fTagRegistry := ATagRegistry;
  fSourceId := ASourceId;
  fDataSources := ADataSources;
  btnBalance.Visible := fTagRegistry <> nil;
end;

function TRecorderMic140SettingsDialog.FindTagForChannel(
  AChannelNumber: Integer): TRecorderTag;
var
  I: Integer;
  lChannelNumber: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if (fTagRegistry = nil) or (fSourceId = '') then
    Exit;
  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if not SameText(lTag.SourceId, fSourceId) then
      Continue;
    if ParseMic140ChannelNumber(lTag.Address, lChannelNumber) and
      (lChannelNumber = AChannelNumber) then
      Exit(lTag);
  end;
end;

procedure TRecorderMic140SettingsDialog.SyncChannelSoftBalanceToTag(
  AChannelNumber: Integer);
var
  lConfig: TRecorderMic140SourceConfig;
  lSettings: TRecorderMic140ChannelSettings;
  lTag: TRecorderTag;
begin
  if (AChannelNumber <= 0) or (AChannelNumber > Length(fChannelSettings)) then
    Exit;
  if (fTagRegistry = nil) or (fSourceId = '') then
    Exit;
  lTag := FindTagForChannel(AChannelNumber);
  if lTag = nil then
    Exit;
  lConfig := EnsureRecorderMic140DeviceConfig(fTagRegistry, fSourceId);
  lSettings := fChannelSettings[AChannelNumber - 1];
  lSettings.ChannelAddress := lTag.Address;
  lConfig.SetChannelSettings(AChannelNumber, lTag.Address, lSettings);
end;

procedure TRecorderMic140SettingsDialog.EnsureChannelSettings(AChannelCount: Integer);
var
  I: Integer;
  lOldLen: Integer;
begin
  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  lOldLen := Length(fChannelSettings);
  if lOldLen < AChannelCount then
  begin
    SetLength(fChannelSettings, AChannelCount);
    for I := lOldLen to AChannelCount - 1 do
      RecorderMic140InitChannelSettings(fChannelSettings[I], I, fDevSubRev);
  end;
end;

function TRecorderMic140SettingsDialog.ChannelAddressText(
  AChannelNumber: Integer): string;
begin
  if fDeviceSerial > 0 then
    Result := Format('%4.4d-%d', [fDeviceSerial, AChannelNumber])
  else
    Result := Format('%4.4d-%2.2d', [0, AChannelNumber]);
end;

function TRecorderMic140SettingsDialog.CollectSelectedChannels: TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  for I := 1 to fGrid.RowCount - 1 do
    if fGrid.Cells[0, I] = '[x]' then
      Result.Add(IntToStr(I));
end;

procedure TRecorderMic140SettingsDialog.UpdateDeviceCaption;
var
  lModel: string;
begin
  if ReadChannelCount > MIC140DefaultChannelCount then
    lModel := 'MIC-140-96'
  else
    lModel := 'MIC-140-48';
  if fDeviceSerial > 0 then
    Caption := Format('%s, с/н %d', [lModel, fDeviceSerial])
  else
    Caption := lModel;
end;

procedure TRecorderMic140SettingsDialog.QueryDeviceInfo;
var
  lHost: string;
  lSerial: Integer;
  lSubRev: Integer;
  lVersion: string;
begin
  lHost := Trim(fHostEdit.Text);
  if lHost = '' then
    Exit;
  Screen.Cursor := crHourGlass;
  try
    if RecorderMic140QueryDeviceInfo(lHost, ReadPort, lSerial, lVersion, lSubRev) then
    begin
      if lSerial > 0 then
        fDeviceSerial := lSerial;
      fDevSubRev := lSubRev;
      if lVersion <> '' then
        fVersionEdit.Text := lVersion;
      fSerialEdit.Text := IntToStr(fDeviceSerial);
      UpdateDeviceCaption;
      FillGrid(ReadChannelCount, CollectSelectedChannels);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TRecorderMic140SettingsDialog.FillGrid(AChannelCount: Integer;
  ASelected: TStrings);
var
  I: Integer;
  lAddress: string;
  lGrad: string;
  lOwned: TStringList;
  lSelected: TStrings;
  lSettings: TRecorderMic140ChannelSettings;
begin
  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  EnsureChannelSettings(AChannelCount);
  lOwned := nil;
  if ASelected <> nil then
    lSelected := ASelected
  else
  begin
    lOwned := CollectSelectedChannels;
    lSelected := lOwned;
  end;
  try
    fGrid.RowCount := AChannelCount + 1;
    for I := 1 to AChannelCount do
    begin
      lAddress := IntToStr(I);
      if (lSelected.Count = 0) or (lSelected.IndexOf(lAddress) >= 0) then
        fGrid.Cells[0, I] := '[x]'
      else
        fGrid.Cells[0, I] := '[ ]';
      lSettings := fChannelSettings[I - 1];
      fGrid.Cells[1, I] := ChannelAddressText(I);
      fGrid.Cells[2, I] := Format('MIC140-{%s}', [fGrid.Cells[1, I]]);
      if RecorderMic140ChannelUsesTemperature(lSettings) then
        lGrad := RecorderMic140ChannelGradRangeText(lSettings)
      else
        lGrad := RecorderMic140FormatAdcRangeMv(lSettings.RangeIndex);
      fGrid.Cells[3, I] := lGrad;
      fGrid.Cells[4, I] := IntToStr(RecorderMic140ChannelCjcNumber(lSettings, I - 1, fDevSubRev));
      fGrid.Cells[5, I] := RecorderMic140FormatAdcRangeMv(lSettings.RangeIndex);
      fGrid.Cells[6, I] := lSettings.ThermocoupleScaleName;
      fGrid.Cells[7, I] := FormatFloat('0.000', lSettings.SoftBalance);
    end;
  finally
    lOwned.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.ToggleGridRow(ARow: Integer);
begin
  if (ARow <= 0) or (ARow >= fGrid.RowCount) then
    Exit;
  if fGrid.Col <> 0 then
    Exit;
  if fGrid.Cells[0, ARow] = '[x]' then
    fGrid.Cells[0, ARow] := '[ ]'
  else
    fGrid.Cells[0, ARow] := '[x]';
end;

procedure TRecorderMic140SettingsDialog.OpenChannelDialog(ARow: Integer);
var
  lRows: TStringList;
begin
  if (ARow <= 0) or (ARow >= fGrid.RowCount) then
    Exit;
  lRows := CollectTargetChannelRows(ARow);
  try
    OpenChannelsDialog(lRows);
  finally
    lRows.Free;
  end;
end;

function TRecorderMic140SettingsDialog.CollectTargetChannelRows(
  AClickRow: Integer): TStringList;
var
  I: Integer;
  lSel: TGridRect;
begin
  Result := TStringList.Create;
  lSel := fGrid.Selection;
  if (lSel.Top > 0) and (lSel.Bottom >= lSel.Top) then
  begin
    for I := lSel.Top to lSel.Bottom do
      if (I > 0) and (I < fGrid.RowCount) then
        Result.Add(IntToStr(I));
    if Result.Count > 0 then
      Exit;
  end;

  if (AClickRow > 0) and (AClickRow < fGrid.RowCount) then
    Result.Add(IntToStr(AClickRow));
end;

procedure TRecorderMic140SettingsDialog.OpenChannelsDialog(ARows: TStrings);
var
  I: Integer;
  lBulkCount: Integer;
  lFirstRow: Integer;
  lRow: Integer;
  lSettings: TRecorderMic140ChannelSettings;
begin
  if (ARows = nil) or (ARows.Count = 0) then
    Exit;
  if not TryStrToInt(ARows[0], lFirstRow) then
    Exit;
  EnsureChannelSettings(ReadChannelCount);
  if (lFirstRow <= 0) or (lFirstRow > Length(fChannelSettings)) then
    Exit;

  lSettings := fChannelSettings[lFirstRow - 1];
  lBulkCount := ARows.Count;
  if ShowRecorderMic140ChannelDialog(Self, lFirstRow, fDeviceSerial, fDevSubRev,
    lSettings, lBulkCount) then
  begin
    for I := 0 to ARows.Count - 1 do
    begin
      if not TryStrToInt(ARows[I], lRow) then
        Continue;
      if (lRow <= 0) or (lRow > Length(fChannelSettings)) then
        Continue;
      fChannelSettings[lRow - 1].RangeIndex := lSettings.RangeIndex;
      fChannelSettings[lRow - 1].ThermocoupleScaleName := lSettings.ThermocoupleScaleName;
      fChannelSettings[lRow - 1].ThermocoupleScalePath := lSettings.ThermocoupleScalePath;
      fChannelSettings[lRow - 1].DefaultCjc := lSettings.DefaultCjc;
      fChannelSettings[lRow - 1].CjcChannel := lSettings.CjcChannel;
      fChannelSettings[lRow - 1].SoftBalance := lSettings.SoftBalance;
      SyncChannelSoftBalanceToTag(lRow);
    end;
    FillGrid(ReadChannelCount, CollectSelectedChannels);
  end;
end;

procedure TRecorderMic140SettingsDialog.BalanceClick(Sender: TObject);
var
  I: Integer;
  lChannelNumber: Integer;
  lMessages: TStringList;
  lRows: TStringList;
  lTags: TList;
  lTag: TRecorderTag;
begin
  if fTagRegistry = nil then
    Exit;
  lRows := CollectSelectedChannels;
  try
    if lRows.Count = 0 then
    begin
      MessageDlg('MIC-140', 'Выберите каналы для балансировки нуля.',
        mtInformation, [mbOK], 0);
      Exit;
    end;
    lTags := TList.Create;
    lMessages := TStringList.Create;
    try
      for I := 0 to lRows.Count - 1 do
      begin
        if not TryStrToInt(lRows[I], lChannelNumber) then
          Continue;
        lTag := FindTagForChannel(lChannelNumber);
        if lTag <> nil then
          lTags.Add(lTag);
      end;
      if lTags.Count = 0 then
      begin
        MessageDlg('MIC-140', 'Для выбранных каналов нет тегов в проекте.',
          mtInformation, [mbOK], 0);
        Exit;
      end;
      if RecorderMic140ZeroBalanceTags(Self, fTagRegistry, lTags, fDataSources,
        lMessages) then
      begin
        for I := 0 to lTags.Count - 1 do
        begin
          lTag := TRecorderTag(lTags[I]);
          if ParseMic140ChannelNumber(lTag.Address, lChannelNumber) then
          begin
            if (lChannelNumber > 0) and (lChannelNumber <= Length(fChannelSettings)) then
              RecorderMic140TryGetChannelSettings(fTagRegistry, lTag, lChannelNumber,
                fChannelSettings[lChannelNumber - 1]);
          end;
        end;
        FillGrid(ReadChannelCount, CollectSelectedChannels);
      end;
      if lMessages.Count > 0 then
        MessageDlg('Балансировка нуля', lMessages.Text, mtInformation, [mbOK], 0);
    finally
      lMessages.Free;
      lTags.Free;
    end;
  finally
    lRows.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.GridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lCol, lRow: Integer;
begin
  if Button <> mbRight then
    Exit;
  fGrid.MouseToCell(X, Y, lCol, lRow);
  if (lRow <= 0) or (lRow >= fGrid.RowCount) then
    Exit;
  if (fGrid.Row <> lRow) or (fGrid.Col <> lCol) then
    fGrid.Row := lRow;
end;

procedure TRecorderMic140SettingsDialog.ChannelPropertiesClick(Sender: TObject);
begin
  OpenChannelDialog(fGrid.Row);
end;

procedure TRecorderMic140SettingsDialog.GridClick(Sender: TObject);
begin
  if fGrid.Col = 0 then
    ToggleGridRow(fGrid.Row);
end;

procedure TRecorderMic140SettingsDialog.GridDblClick(Sender: TObject);
begin
  OpenChannelDialog(fGrid.Row);
end;

procedure TRecorderMic140SettingsDialog.ChannelCountChange(Sender: TObject);
var
  lSelected: TStringList;
begin
  lSelected := CollectSelectedChannels;
  try
    FillGrid(ReadChannelCount, lSelected);
    UpdateDeviceCaption;
  finally
    lSelected.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.SearchClick(Sender: TObject);
var
  lFound: TStringList;
begin
  lFound := TStringList.Create;
  try
    Screen.Cursor := crHourGlass;
    try
      RecorderMic140Discover(lFound, MIC140DefaultDiscoverySubnet, ReadPort, 180);
    finally
      Screen.Cursor := crDefault;
    end;
    if lFound.Count > 0 then
    begin
      fHostEdit.Text := lFound[0];
      QueryDeviceInfo;
      MessageDlg('MIC-140', 'Найдено: ' + lFound.CommaText, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg('MIC-140', 'Устройство не найдено в 192.168.14.0/24',
        mtWarning, [mbOK], 0);
  finally
    lFound.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.TestClick(Sender: TObject);
begin
  if RecorderMic140TestConnection(Trim(fHostEdit.Text), ReadPort, 500) then
  begin
    QueryDeviceInfo;
    MessageDlg('MIC-140', 'Связь установлена', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg('MIC-140', 'Нет связи с устройством', mtWarning, [mbOK], 0);
end;

function TRecorderMic140SettingsDialog.ReadPort: Word;
var
  lPort: Integer;
begin
  if not TryStrToInt(Trim(fPortEdit.Text), lPort) then
    lPort := MIC140DefaultPort;
  if (lPort <= 0) or (lPort > High(Word)) then
    lPort := MIC140DefaultPort;
  Result := Word(lPort);
end;

function TRecorderMic140SettingsDialog.ReadChannelCount: Integer;
begin
  if not TryStrToInt(fChannelCountCombo.Text, Result) then
    Result := MIC140DefaultChannelCount;
  if Result > MIC140DefaultChannelCount then
    Result := MIC140MaxChannelCount
  else
    Result := MIC140DefaultChannelCount;
end;

procedure TRecorderMic140SettingsDialog.LoadFromResult(
  const AResult: TRecorderMic140DialogResult);
var
  I: Integer;
begin
  fDeviceSerial := AResult.DeviceSerial;
  fDevSubRev := CMic140Mic140SubRev1;
  fHostEdit.Text := AResult.Host;
  fPortEdit.Text := IntToStr(AResult.Port);
  fSerialEdit.Text := '';
  if AResult.DeviceSerial > 0 then
    fSerialEdit.Text := IntToStr(AResult.DeviceSerial);
  fVersionEdit.Text := AResult.VersionText;
  fThermoCompCheck.Checked := AResult.ThermoCompensationEnabled;
  if AResult.ChannelCount > MIC140DefaultChannelCount then
    fChannelCountCombo.ItemIndex := 1
  else
    fChannelCountCombo.ItemIndex := 0;
  SetLength(fChannelSettings, Length(AResult.ChannelSettings));
  for I := 0 to High(AResult.ChannelSettings) do
    fChannelSettings[I] := AResult.ChannelSettings[I];
  FillGrid(ReadChannelCount, AResult.SelectedChannels);
  UpdateDeviceCaption;
  if (Trim(AResult.VersionText) = '') and (Trim(AResult.Host) <> '') and
    (AResult.DeviceSerial <= 0) then
    QueryDeviceInfo;
end;

procedure TRecorderMic140SettingsDialog.StoreToResult(
  var AResult: TRecorderMic140DialogResult);
var
  I: Integer;
begin
  AResult.Host := Trim(fHostEdit.Text);
  if AResult.Host = '' then
    AResult.Host := MIC140DefaultHost;
  AResult.Port := ReadPort;
  AResult.ChannelCount := ReadChannelCount;
  AResult.DeviceSerial := fDeviceSerial;
  AResult.VersionText := Trim(fVersionEdit.Text);
  AResult.ThermoCompensationEnabled := fThermoCompCheck.Checked;
  if AResult.SelectedChannels <> nil then
  begin
    AResult.SelectedChannels.Clear;
    for I := 1 to fGrid.RowCount - 1 do
      if fGrid.Cells[0, I] = '[x]' then
        AResult.SelectedChannels.Add(IntToStr(I));
  end;
  SetLength(AResult.ChannelSettings, Length(fChannelSettings));
  for I := 0 to High(fChannelSettings) do
    AResult.ChannelSettings[I] := fChannelSettings[I];
end;

function ApplyRecorderMic140SourceDialog(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; AMic140Configs: TStringList;
  const ASourceId: string; out ANewSourceId: string): Boolean;
var
  I: Integer;
  lCalibrSerial: Integer;
  lCalName: string;
  lCapacity: Integer;
  lChannelNumber: Integer;
  lConfig: TRecorderMic140SourceConfig;
  lHost: string;
  lPort: Word;
  lResult: TRecorderMic140DialogResult;
  lSettings: TRecorderMic140ChannelSettings;
  lTag: TRecorderTag;
begin
  Result := False;
  ANewSourceId := ASourceId;
  if ATagRegistry = nil then
    Exit;

  InitRecorderMic140DialogResult(lResult);
  try
    if TryParseRecorderMic140SourceId(ASourceId, lHost, lPort) then
    begin
      lResult.Host := lHost;
      lResult.Port := lPort;
      lConfig := FindRecorderMic140DeviceConfig(ATagRegistry, ASourceId);
      if lConfig = nil then
        lConfig := FindRecorderMic140SourceConfig(AMic140Configs, ASourceId);
      if lConfig <> nil then
        lConfig.SaveToResult(lResult);
      for I := 0 to ATagRegistry.TagCount - 1 do
      begin
        lTag := ATagRegistry.Tags[I];
        if not SameText(lTag.SourceId, ASourceId) then
          Continue;
        if ParseMic140ChannelNumber(lTag.Address, lChannelNumber) then
        begin
          if lResult.SelectedChannels.IndexOf(IntToStr(lChannelNumber)) < 0 then
            lResult.SelectedChannels.Add(IntToStr(lChannelNumber));
          if lChannelNumber > lResult.ChannelCount then
            lResult.ChannelCount := MIC140MaxChannelCount;
        end
        else
          lResult.SelectedChannels.Add(lTag.Address);
        if (lResult.DeviceSerial <= 0) and
          TryParseRecorderMic140SourceId(ASourceId, lHost, lPort) then
          RecorderMic140QueryHardwareCalibrSerial(lHost, lPort, lResult.DeviceSerial);
      end;
    end;

    if not ShowRecorderMic140SettingsDialog(AOwner, lResult, ATagRegistry, ASourceId,
      nil) then
      Exit;

    if not lResult.ThermoCompensationEnabled then
      for I := 0 to High(lResult.ChannelSettings) do
        if RecorderMic140ChannelUsesTemperature(lResult.ChannelSettings[I]) and
          ((lResult.SelectedChannels.Count = 0) or
          (lResult.SelectedChannels.IndexOf(IntToStr(I + 1)) >= 0)) then
        begin
          lResult.ThermoCompensationEnabled := True;
          Break;
        end;

    ANewSourceId := RecorderMic140SourceId(lResult.Host, lResult.Port);
    lCalibrSerial := 0;
    if TryParseRecorderMic140SourceId(ANewSourceId, lHost, lPort) then
      RecorderMic140QueryHardwareCalibrSerial(lHost, lPort, lCalibrSerial);

    if lCalibrSerial > 0 then
      lResult.DeviceSerial := lCalibrSerial;

    lConfig := EnsureRecorderMic140DeviceConfig(ATagRegistry, ANewSourceId);
    lConfig.LoadFromResult(lResult);
    if AMic140Configs <> nil then
    begin
      EnsureRecorderMic140SourceConfig(AMic140Configs, ANewSourceId).LoadFromResult(lResult);
      if (ASourceId <> '') and (not SameText(ASourceId, ANewSourceId)) then
      begin
        lConfig := FindRecorderMic140SourceConfig(AMic140Configs, ASourceId);
        if lConfig <> nil then
          AMic140Configs.Delete(AMic140Configs.IndexOf(ASourceId));
      end;
    end;
    if (ASourceId <> '') and (not SameText(ASourceId, ANewSourceId)) then
      ATagRegistry.UnregisterActiveSource(ASourceId);
    ATagRegistry.RegisterActiveSource(ANewSourceId);

    lCapacity := 4096;
    for I := 0 to ATagRegistry.TagCount - 1 do
    begin
      lTag := ATagRegistry.Tags[I];
      if SameText(lTag.SourceId, ANewSourceId) and (lTag.PollFrequencyHz > 0) then
        lCapacity := Max(lCapacity, Ceil(lTag.PollFrequencyHz));
    end;
    for I := 0 to ATagRegistry.TagCount - 1 do
    begin
      lTag := ATagRegistry.Tags[I];
      if (not SameText(lTag.SourceId, ANewSourceId)) and
        ((ASourceId = '') or (not SameText(lTag.SourceId, ASourceId))) then
        Continue;
      if (lResult.SelectedChannels.Count > 0) and
        (not ParseMic140ChannelNumber(lTag.Address, lChannelNumber) or
        (lResult.SelectedChannels.IndexOf(IntToStr(lChannelNumber)) < 0)) then
        Continue;
      lTag.SourceId := ANewSourceId;
      lTag.ModuleType := 'MIC-140';
      if ParseMic140ChannelNumber(lTag.Address, lChannelNumber) and
        (lChannelNumber > 0) and (lChannelNumber <= Length(lResult.ChannelSettings)) then
      begin
        lSettings := lResult.ChannelSettings[lChannelNumber - 1];
        lSettings.ChannelAddress := lTag.Address;
        lConfig.SetChannelSettings(lChannelNumber, lTag.Address, lSettings);
        if RecorderMic140ChannelUsesTemperature(lSettings) then
        begin
          if (not lTag.ChannelCalibrationEnabled) or
            (lTag.SourceValueMode <>
            RecorderMic140OutputModeToConfigName(momTemperatureC)) then
            lTag.ClearSignalHistory;
          lTag.ChannelCalibrationEnabled := True;
          lTag.SourceValueMode := RecorderMic140OutputModeToConfigName(momTemperatureC);
          lTag.UnitName := RecorderMic140OutputModeUnitName(momTemperatureC);
          lCalName := RecorderMic140EnsureThermocoupleCalibration(ATagRegistry, lSettings);
          lTag.CalibrationNames.Clear;
          if lCalName <> '' then
            lTag.CalibrationNames.Add(lCalName);
          if lCalName = '' then
            lTag.CalibrationNames.Add('TC ' + lSettings.ThermocoupleScaleName);
        end
        else
        begin
          if lTag.ChannelCalibrationEnabled or
            (lTag.SourceValueMode <>
            RecorderMic140OutputModeToConfigName(momMillivolts)) then
            lTag.ClearSignalHistory;
          lTag.ChannelCalibrationEnabled := False;
          lTag.SourceValueMode := RecorderMic140OutputModeToConfigName(momMillivolts);
          lTag.UnitName := RecorderMic140OutputModeUnitName(momMillivolts);
          if lTag.CalibrationNames <> nil then
            lTag.CalibrationNames.Clear;
        end;
      end;
      RecorderTagClearMic140Settings(lTag);
      lTag.Description := Format('MIC-140 channel %s; freq=%s Hz; mode=%s',
        [lTag.Address, FormatFloat('0.######', lTag.PollFrequencyHz),
         lTag.SourceValueMode]);
      lTag.EnsureBufferCapacity(lCapacity);
    end;
    Result := True;
  finally
    DoneRecorderMic140DialogResult(lResult);
  end;
end;

end.
