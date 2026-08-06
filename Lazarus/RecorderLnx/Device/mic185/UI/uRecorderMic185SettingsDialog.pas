unit uRecorderMic185SettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Grids,
  uRecorderTags, uMic185MebiusTypes;

type
  TRecorderMic185RowArray = array of Integer;

  { TRecorderMic185SettingsForm }

  TRecorderMic185SettingsForm = class(TForm)
    btnAdditional: TButton;
    btnApply: TButton;
    btnBalance: TButton;
    btnCancel: TButton;
    btnMetrology: TButton;
    btnOk: TButton;
    btnProperties: TButton;
    btnSelectAll: TButton;
    edAddress: TEdit;
    edPort: TEdit;
    edSerial: TEdit;
    edState: TEdit;
    edVersion: TEdit;
    gridChannels: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure btnAdditionalClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnBalanceClick(Sender: TObject);
    procedure btnMetrologyClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnPropertiesClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fChannelSettings: TMic185ChannelProgramSettingsArray;
    fPowerMaCode: LongWord;
    fRegistry: TRecorderTagRegistry;
    fSourceId: string;
    function ApplySettingsToDevice: Boolean;
    procedure ApplySettingsToRow(const ASettings: TMic185ChannelProgramSettings;
      const AUnitName: string; ARow: Integer);
    function EnsureTagForGridRow(ARow: Integer): TRecorderTag;
    function FindTagBySourceAddress(const ASourceId,
      AAddress: string): TRecorderTag;
    procedure GetSourceRowSettings(ARow: Integer;
      out ASettings: TMic185ChannelProgramSettings);
    procedure FillGrid;
    procedure RefreshDeviceInfo;
    procedure StoreSourceConfig;
    procedure StoreAllGridTags;
    procedure GetSelectedMeasurementRows(out ARows: TRecorderMic185RowArray);
    procedure LoadChannelSettingsFromSource;
    procedure SelectAllGridRows;
    procedure StoreChannelSettingsConfig;
    procedure UpdateGridRow(ARow: Integer; ATag: TRecorderTag);
    function SelectedChannelAddress: string;
  public
    procedure LoadSource(ARegistry: TRecorderTagRegistry; const ASourceId: string);
    function BuildSourceId: string;
  end;

function ApplyRecorderMic185SourceDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string): Boolean;

procedure SetRecorderMic185SettingsSelfTestActive(AActive: Boolean);

implementation

{$R *.lfm}

uses
  Dialogs, Math, StrUtils, uRecorderMic185DataSource, uRecorderMic185AdditionalDialog,
  uRecorderMic185ChannelDialog, uRecorderConfiguredSourceEditor,
  uRecorderMic185DeviceInfoProbe, uMic185Constants;

var
  GRecorderMic185SettingsSelfTestActive: Boolean = False;

procedure SetRecorderMic185SettingsSelfTestActive(AActive: Boolean);
begin
  GRecorderMic185SettingsSelfTestActive := AActive;
end;

procedure TRecorderMic185SettingsForm.FormCreate(Sender: TObject);
begin
  Mic185DefaultChannelProgramSettingsArray(MIC185DefaultPollFrequencyHz,
    fChannelSettings);
  fPowerMaCode := CMic185DefaultPowerMaCode;
  gridChannels.ColCount := 10;
  gridChannels.FixedRows := 1;
  gridChannels.RowCount := 71;
  gridChannels.Cells[0, 0] := '№';
  gridChannels.Cells[1, 0] := 'Имя';
  gridChannels.Cells[2, 0] := 'Диап-н факт.';
  gridChannels.Cells[3, 0] := 'Аппарат. б-ка';
  gridChannels.Cells[4, 0] := 'Прогр. б-ка';
  gridChannels.Cells[5, 0] := 'Ед. изм-ния';
  gridChannels.Cells[6, 0] := 'Коммутация';
  gridChannels.Cells[7, 0] := 'Тип датчика';
  gridChannels.Cells[8, 0] := 'Канал термо';
  gridChannels.Cells[9, 0] := 'Сост. б-ки';
  FillGrid;
end;

function TRecorderMic185SettingsForm.ApplySettingsToDevice: Boolean;
var
  lErrorText: string;
begin
  Result := False;
  StoreChannelSettingsConfig;
  Result := RecorderMic185ProgramConfiguredSource(fRegistry, BuildSourceId,
    lErrorText);
  if not Result then
  begin
    if Trim(lErrorText) = '' then
      lErrorText := 'MIC183/185 programming failed';
    ShowMessage(lErrorText);
  end;
end;

procedure TRecorderMic185SettingsForm.ApplySettingsToRow(
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string;
  ARow: Integer);
var
  lTargetTag: TRecorderTag;
begin
  if (ARow < 1) or (ARow > CMic185ChannelCountMax) then
    Exit;
  fChannelSettings[ARow - 1] := ASettings;
  lTargetTag := EnsureTagForGridRow(ARow);
  if lTargetTag <> nil then
  begin
    if Trim(AUnitName) <> '' then
      lTargetTag.UnitName := AUnitName;
    lTargetTag.AutoUnit := False;
    lTargetTag.RangeMax := RecorderMic185EffectiveRangeMax(ASettings,
      lTargetTag.UnitName);
    lTargetTag.RangeMin := -lTargetTag.RangeMax;
    UpdateGridRow(ARow, lTargetTag);
  end;
end;

procedure TRecorderMic185SettingsForm.FillGrid;
var
  I: Integer;
  lDeviceIndex: Integer;
  lName: string;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  lSourceId := BuildSourceId;
  lDeviceIndex := RecorderMic185SourceDeviceIndex(fRegistry, lSourceId);
  for I := 1 to 70 do
  begin
    if I <= 64 then
      lName := Format('185-{%d-%d}', [lDeviceIndex, I])
    else if I <= 69 then
      lName := Format('185-{%d-t%d}', [lDeviceIndex, I - 64])
    else
      lName := Format('185-{%d-uts}', [lDeviceIndex]);
    gridChannels.Cells[0, I] := IntToStr(I);
    gridChannels.Cells[1, I] := lName;
    gridChannels.Cells[2, I] := '±5.000';
    gridChannels.Cells[3, I] := '0.000';
    gridChannels.Cells[4, I] := '0.000';
    if I <= 64 then
      gridChannels.Cells[5, I] := 'мВ'
    else if I <= 69 then
      gridChannels.Cells[5, I] := '°C'
    else
      gridChannels.Cells[5, I] := 'с';
    gridChannels.Cells[6, I] := 'Вход';
    gridChannels.Cells[7, I] := '-';
    gridChannels.Cells[8, I] := '1';
    gridChannels.Cells[9, I] := '-';
    lTag := FindTagBySourceAddress(lSourceId, lName);
    if lTag <> nil then
      UpdateGridRow(I, lTag);
  end;
end;

function TRecorderMic185SettingsForm.FindTagBySourceAddress(const ASourceId,
  AAddress: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  if fRegistry = nil then
    Exit;
  for I := 0 to fRegistry.TagCount - 1 do
    if SameText(fRegistry.Tags[I].SourceId, ASourceId) and
      SameText(fRegistry.Tags[I].Address, AAddress) then
      Exit(fRegistry.Tags[I]);
end;

procedure TRecorderMic185SettingsForm.GetSourceRowSettings(ARow: Integer;
  out ASettings: TMic185ChannelProgramSettings);
begin
  if (ARow >= 1) and (ARow <= CMic185ChannelCountMax) then
  begin
    ASettings := fChannelSettings[ARow - 1]
  end
  else
    Mic185DefaultChannelProgramSettings(CMic185DefaultTempFrequencyHz, ASettings);
  ASettings.PowerMaCode := fPowerMaCode;
end;

procedure TRecorderMic185SettingsForm.StoreSourceConfig;
begin
  fSourceId := BuildSourceId;
  RecorderMic185EnsureConfiguredSource(fRegistry, fSourceId,
    MIC185DefaultPollFrequencyHz);
end;

procedure TRecorderMic185SettingsForm.StoreAllGridTags;
var
  I: Integer;
begin
  StoreSourceConfig;
  StoreChannelSettingsConfig;
  for I := 1 to 70 do
    EnsureTagForGridRow(I);
end;

procedure TRecorderMic185SettingsForm.GetSelectedMeasurementRows(
  out ARows: TRecorderMic185RowArray);
var
  I: Integer;
  lBottom: Integer;
  lCount: Integer;
  lRow: Integer;
  lSelection: TGridRect;
  lTop: Integer;
begin
  SetLength(ARows, 0);
  lCount := 0;
  lSelection := gridChannels.Selection;
  lTop := Max(1, Min(lSelection.Top, lSelection.Bottom));
  lBottom := Min(CMic185ChannelCountMax, Max(lSelection.Top, lSelection.Bottom));
  if lBottom >= lTop then
    for I := lTop to lBottom do
    begin
      SetLength(ARows, lCount + 1);
      ARows[lCount] := I;
      Inc(lCount);
    end;

  if Length(ARows) = 0 then
  begin
    lRow := gridChannels.Row;
    if (lRow >= 1) and (lRow <= CMic185ChannelCountMax) then
    begin
      SetLength(ARows, 1);
      ARows[0] := lRow;
    end;
  end;
end;

procedure TRecorderMic185SettingsForm.LoadChannelSettingsFromSource;
var
  I: Integer;
  lAddress: string;
  lDeviceIndex: Integer;
  lSourceId: string;
begin
  Mic185DefaultChannelProgramSettingsArray(MIC185DefaultPollFrequencyHz,
    fChannelSettings);
  lSourceId := BuildSourceId;
  lDeviceIndex := RecorderMic185SourceDeviceIndex(fRegistry, lSourceId);
  fPowerMaCode := RecorderMic185GetSourcePowerMaCode(fRegistry, lSourceId);
  for I := 0 to CMic185ChannelCountMax - 1 do
  begin
    lAddress := Format('185-{%d-%d}', [lDeviceIndex, I + 1]);
    RecorderMic185GetSourceChannelMode(fRegistry, lSourceId, lAddress,
      MIC185DefaultPollFrequencyHz, fChannelSettings[I]);
    fChannelSettings[I].PowerMaCode := fPowerMaCode;
  end;
end;

procedure TRecorderMic185SettingsForm.SelectAllGridRows;
var
  lSelection: TGridRect;
begin
  if gridChannels.RowCount <= 1 then
    Exit;
  lSelection.Left := 0;
  lSelection.Top := 1;
  lSelection.Right := gridChannels.ColCount - 1;
  lSelection.Bottom := gridChannels.RowCount - 1;
  gridChannels.Row := 1;
  gridChannels.Selection := lSelection;
end;

procedure TRecorderMic185SettingsForm.StoreChannelSettingsConfig;
var
  I: Integer;
  lAddress: string;
  lDeviceIndex: Integer;
  lSourceId: string;
  lStored: TMic185ChannelProgramSettings;
begin
  if fRegistry = nil then
    Exit;
  lSourceId := BuildSourceId;
  lDeviceIndex := RecorderMic185SourceDeviceIndex(fRegistry, lSourceId);
  RecorderMic185EnsureConfiguredSource(fRegistry, lSourceId,
    MIC185DefaultPollFrequencyHz);
  RecorderMic185SetSourcePowerMaCode(fRegistry, lSourceId,
    MIC185DefaultPollFrequencyHz, fPowerMaCode);
  for I := 0 to CMic185ChannelCountMax - 1 do
  begin
    fChannelSettings[I].PowerMaCode := fPowerMaCode;
    lAddress := Format('185-{%d-%d}', [lDeviceIndex, I + 1]);
    RecorderMic185SetSourceChannelMode(fRegistry, lSourceId, lAddress,
      MIC185DefaultPollFrequencyHz, fChannelSettings[I]);
  end;
  if RecorderMic185GetSourceChannelMode(fRegistry, lSourceId,
    Format('185-{%d-4}', [lDeviceIndex]),
    MIC185DefaultPollFrequencyHz, lStored) then
    RecorderMic185Log(Format('SettingsDialog stored %s ch4 range=%d commut=%d scheme=%d power=%d',
      [lSourceId, lStored.MeasRangeIndex, lStored.CommutIndex,
       lStored.SensorScheme, fPowerMaCode]));
end;

procedure TRecorderMic185SettingsForm.UpdateGridRow(ARow: Integer;
  ATag: TRecorderTag);
var
  lSettings: TMic185ChannelProgramSettings;
  lUnitName: string;
begin
  if (ARow < 1) or (ATag = nil) then
    Exit;
  gridChannels.Cells[1, ARow] := ATag.Address;
  if ARow <= CMic185ChannelCountMax then
  begin
    GetSourceRowSettings(ARow, lSettings);
    lUnitName := Trim(ATag.UnitName);
    if lUnitName = '' then
      lUnitName := RecorderMic185RangeUnitText(lSettings.MeasRangeIndex);
    gridChannels.Cells[2, ARow] := RecorderMic185EffectiveRangeText(lSettings,
      lUnitName);
    gridChannels.Cells[3, ARow] := '0.000';
    gridChannels.Cells[4, ARow] := FloatToStr(lSettings.SoftBalance);
    gridChannels.Cells[5, ARow] := lUnitName;
    gridChannels.Cells[6, ARow] := RecorderMic185CommutationText(lSettings.CommutIndex);
    gridChannels.Cells[7, ARow] := RecorderMic185SensorSchemeText(lSettings.SensorScheme);
  end
  else
  begin
    gridChannels.Cells[5, ARow] := ATag.UnitName;
    gridChannels.Cells[6, ARow] := '-';
    gridChannels.Cells[7, ARow] := '-';
  end;
  gridChannels.Cells[9, ARow] := 'связан';
end;

function TRecorderMic185SettingsForm.EnsureTagForGridRow(
  ARow: Integer): TRecorderTag;
var
  lAddress: string;
  lCapacity: Integer;
  lName: string;
  lPollHz: Double;
  lSettings: TMic185ChannelProgramSettings;
  lSourceId: string;
begin
  Result := nil;
  if (fRegistry = nil) or (ARow < 1) or (ARow > 70) then
    Exit;
  StoreSourceConfig;
  lSourceId := fSourceId;
  lAddress := gridChannels.Cells[1, ARow];
  lName := lAddress;
  if Trim(lName) = '' then
    Exit;
  if ARow <= CMic185ChannelCountMax then
    lPollHz := MIC185DefaultPollFrequencyHz
  else
    lPollHz := CMic185DefaultTempFrequencyHz;
  Result := FindTagBySourceAddress(lSourceId, lAddress);
  if Result = nil then
    Result := fRegistry.FindByName(lName);
  if Result = nil then
  begin
    lCapacity := Ceil(Max(4096, lPollHz * 4));
    Result := fRegistry.CreateTag(lName, lCapacity);
  end;
  Result.SourceId := lSourceId;
  Result.Address := lAddress;
  Result.ModuleType := 'MIC183/185';
  Result.PollFrequencyHz := lPollHz;
  Result.SourceValueMode := '';
  Result.AutoRange := False;
  Result.AutoUnit := False;
  Result.Description := Format('MIC183/185 channel %s', [lAddress]);
  if ARow <= CMic185ChannelCountMax then
  begin
    lSettings := fChannelSettings[ARow - 1];
    if Trim(Result.UnitName) = '' then
      Result.UnitName := RecorderMic185RangeUnitText(lSettings.MeasRangeIndex);
    Result.RangeMax := RecorderMic185EffectiveRangeMax(lSettings,
      Result.UnitName);
    Result.RangeMin := -Result.RangeMax;
  end
  else if ARow <= CMic185ChannelCountMax + CMic185TempChannelCount then
  begin
    Result.UnitName := '°C';
    Result.RangeMin := CMic185TempMinRangeC;
    Result.RangeMax := CMic185TempMaxRangeC;
    Result.SourceValueMode := '';
  end
  else
  begin
    Result.UnitName := 'с';
    Result.RangeMin := 0;
    Result.RangeMax := 0;
    Result.SourceValueMode := '';
  end;
  Result.EnsureBufferCapacity(Ceil(Max(4096, lPollHz * 4)));
  UpdateGridRow(ARow, Result);
end;

procedure TRecorderMic185SettingsForm.LoadSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string);
var
  lHost: string;
  lPort: Word;
begin
  fRegistry := ARegistry;
  fSourceId := ASourceId;
  if not TryParseRecorderMic185SourceId(ASourceId, lHost, lPort) then
  begin
    lHost := MIC185DefaultHost;
    lPort := MIC185DefaultPort;
  end;
  edAddress.Text := lHost;
  edPort.Text := IntToStr(lPort);
  edSerial.Text := '';
  edVersion.Text := '';
  edState.Text := 'Норма';
  RefreshDeviceInfo;
  StoreSourceConfig;
  LoadChannelSettingsFromSource;
  FillGrid;
end;

procedure TRecorderMic185SettingsForm.RefreshDeviceInfo;
var
  lAcquiring: Boolean;
  lErrorText: string;
  lPort: Integer;
  lSerialNumber: LongWord;
  lVersionText: string;
begin
  if not TryStrToInt(Trim(edPort.Text), lPort) then
    Exit;
  if (lPort < 1) or (lPort > 65535) then
    Exit;

  if RecorderMic185ProbeDeviceInfo(Trim(edAddress.Text), Word(lPort),
    lSerialNumber, lVersionText, lAcquiring, lErrorText, 3000) then
  begin
    if lSerialNumber <> 0 then
      edSerial.Text := IntToStr(lSerialNumber)
    else
      edSerial.Text := '';
    edVersion.Text := lVersionText;
    if lAcquiring then
      edState.Text := 'Опрос активен'
    else
      edState.Text := 'Подключён';
    Exit;
  end;

  edSerial.Text := '';
  edVersion.Text := '';
  if lErrorText <> '' then
    edState.Text := lErrorText
  else if Trim(edAddress.Text) <> '' then
    edState.Text := 'Нет связи';
end;

function TRecorderMic185SettingsForm.BuildSourceId: string;
var
  lPort: Integer;
begin
  if not TryStrToInt(Trim(edPort.Text), lPort) then
    lPort := MIC185DefaultPort;
  Result := RecorderMic185SourceId(Trim(edAddress.Text), Word(lPort));
end;

function TRecorderMic185SettingsForm.SelectedChannelAddress: string;
var
  lRow: Integer;
begin
  lRow := gridChannels.Row;
  if lRow < 1 then
    lRow := 1;
  Result := gridChannels.Cells[1, lRow];
end;

procedure TRecorderMic185SettingsForm.btnAdditionalClick(Sender: TObject);
var
  lModuleSettings: TMic185ModuleProgramSettings;
  lSourceId: string;
  lTemperatureCompensation: Boolean;
begin
  lSourceId := BuildSourceId;
  RecorderMic185EnsureConfiguredSource(fRegistry, lSourceId,
    MIC185DefaultPollFrequencyHz);
  RecorderMic185GetSourceModuleSettings(fRegistry, lSourceId, lModuleSettings);
  lTemperatureCompensation :=
    RecorderMic185GetSourceTemperatureCompensation(fRegistry, lSourceId);
  if ShowRecorderMic185AdditionalDialog(Self, lModuleSettings,
    lTemperatureCompensation) then
  begin
    RecorderMic185SetSourceModuleSettings(fRegistry, lSourceId,
      MIC185DefaultPollFrequencyHz, lModuleSettings);
    RecorderMic185SetSourceTemperatureCompensation(fRegistry, lSourceId,
      MIC185DefaultPollFrequencyHz, lTemperatureCompensation);
    ApplySettingsToDevice;
  end;
end;

procedure TRecorderMic185SettingsForm.btnApplyClick(Sender: TObject);
begin
  StoreAllGridTags;
  ApplySettingsToDevice;
  FillGrid;
end;

procedure TRecorderMic185SettingsForm.btnBalanceClick(Sender: TObject);
begin
  ShowMessage('Балансировка MIC183/185 пока не реализована.');
end;

procedure TRecorderMic185SettingsForm.btnMetrologyClick(Sender: TObject);
begin
  ShowMessage('Метрология MIC183/185 пока не реализована.');
end;

procedure TRecorderMic185SettingsForm.btnOkClick(Sender: TObject);
begin
  StoreAllGridTags;
  if ApplySettingsToDevice then
    ModalResult := mrOk
  else
    ModalResult := mrNone;
end;

procedure TRecorderMic185SettingsForm.btnPropertiesClick(Sender: TObject);
var
  I: Integer;
  lAddress: string;
  lCurrentRow: Integer;
  lFoundCurrent: Boolean;
  lRows: TRecorderMic185RowArray;
  lRow: Integer;
  lSettings: TMic185ChannelProgramSettings;
  lSourceId: string;
  lTag: TRecorderTag;
  lUnitName: string;
begin
  lTag := nil;
  GetSelectedMeasurementRows(lRows);
  if Length(lRows) = 0 then
    Exit;
  lCurrentRow := gridChannels.Row;
  lFoundCurrent := False;
  for I := 0 to High(lRows) do
    if lRows[I] = lCurrentRow then
    begin
      lFoundCurrent := True;
      Break;
    end;
  if lFoundCurrent then
    lRow := lCurrentRow
  else
    lRow := lRows[0];
  lAddress := gridChannels.Cells[1, lRow];
  lSourceId := BuildSourceId;
  if fRegistry <> nil then
    for I := 0 to fRegistry.TagCount - 1 do
      if SameText(fRegistry.Tags[I].SourceId, lSourceId) and
        SameText(fRegistry.Tags[I].Address, lAddress) then
      begin
        lTag := fRegistry.Tags[I];
        Break;
      end;
  if lTag = nil then
    lTag := EnsureTagForGridRow(lRow);
  if lTag = nil then
    Exit;
  GetSourceRowSettings(lRow, lSettings);
  lSettings.PowerMaCode := fPowerMaCode;
  lTag.SourceValueMode := RecorderMic185FormatChannelMode(lSettings);
  if ShowRecorderMic185ChannelDialog(Self, lTag) then
  begin
    RecorderMic185ReadChannelMode(lTag.SourceValueMode, lTag.PollFrequencyHz,
      lSettings);
    if lSettings.PowerMaCode <> 0 then
      fPowerMaCode := lSettings.PowerMaCode;
    lSettings.PowerMaCode := fPowerMaCode;
    lUnitName := lTag.UnitName;
    fChannelSettings[lRow - 1] := lSettings;
    RecorderMic185SetSourceChannelMode(fRegistry, lSourceId, lAddress,
      lTag.PollFrequencyHz, fChannelSettings[lRow - 1]);
    UpdateGridRow(lRow, lTag);
    for I := 0 to High(lRows) do
      if lRows[I] <> lRow then
        ApplySettingsToRow(lSettings, lUnitName, lRows[I]);
    StoreChannelSettingsConfig;
    RecorderMic185Log(Format('SettingsDialog properties applied %s master=%s rows=%d mode=%s',
      [lSourceId, lAddress, Length(lRows), lTag.SourceValueMode]));
  end;
  lTag.SourceValueMode := '';
end;

procedure TRecorderMic185SettingsForm.btnSelectAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to 70 do
    EnsureTagForGridRow(I);
  FillGrid;
  SelectAllGridRows;
end;

function ApplyRecorderMic185SourceDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string): Boolean;
var
  lForm: TRecorderMic185SettingsForm;
begin
  lForm := TRecorderMic185SettingsForm.Create(AOwner);
  try
    lForm.LoadSource(ARegistry, ASourceId);
    if GRecorderMic185SettingsSelfTestActive then
    begin
      Result := True;
      ANewSourceId := lForm.BuildSourceId;
      Exit;
    end;
    Result := lForm.ShowModal in [mrOk, mrYes];
    if Result then
    begin
      lForm.StoreAllGridTags;
      ANewSourceId := lForm.BuildSourceId
    end
    else
      ANewSourceId := ASourceId;
  finally
    lForm.Free;
  end;
end;

type
  TRecorderMic185ConfiguredSourceEditor = class(TInterfacedObject,
    IRecorderConfiguredSourceEditor)
  public
    function SupportsSource(const ASourceId, AModuleType: string): Boolean;
    function EditSource(AOwner: TComponent; ARegistry: TRecorderTagRegistry;
      const ASourceId: string; out ANewSourceId: string): Boolean;
  end;

function TRecorderMic185ConfiguredSourceEditor.SupportsSource(
  const ASourceId, AModuleType: string): Boolean;
begin
  Result := SameText(AModuleType, 'MIC183/185') or
    SameText(AModuleType, 'MIC185') or
    RecorderIsHardwareMic185TagSource(ASourceId);
end;

function TRecorderMic185ConfiguredSourceEditor.EditSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string): Boolean;
begin
  Result := ApplyRecorderMic185SourceDialog(AOwner, ARegistry, ASourceId,
    ANewSourceId);
end;

initialization
  RecorderRegisterConfiguredSourceEditor(TRecorderMic185ConfiguredSourceEditor.Create);

end.
