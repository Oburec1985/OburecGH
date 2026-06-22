unit uRecorderMic140SettingsDialog;

{
  MIC-140 setup dialog (LFM layout, editable in Lazarus IDE).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids, Buttons, Dialogs,
  uRecorderMic140DataSource, uRecorderMic140Utils;

type
  TRecorderMic140DialogResult = record
    Host: string;
    Port: Word;
    ChannelCount: Integer;
    DeviceSerial: Integer;
    VersionText: string;
    ThermoCompensationEnabled: Boolean;
    SelectedChannels: TStringList;
    ChannelSettings: array of TRecorderMic140ChannelSettings;
  end;

function ShowRecorderMic140SettingsDialog(AOwner: TComponent;
  var AResult: TRecorderMic140DialogResult): Boolean;
procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);

implementation

uses
  uRecorderMic140ChannelDialog;

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
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure GridClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure ChannelCountChange(Sender: TObject);
    procedure SearchClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
  private
    fDeviceSerial: Integer;
    fDevSubRev: Integer;
    fChannelSettings: array of TRecorderMic140ChannelSettings;
    procedure InitGrid;
    procedure EnsureChannelSettings(AChannelCount: Integer);
    procedure FillGrid(AChannelCount: Integer; ASelected: TStrings);
    procedure ToggleGridRow(ARow: Integer);
    procedure OpenChannelDialog(ARow: Integer);
    procedure UpdateDeviceCaption;
    procedure QueryDeviceInfo;
    function ReadPort: Word;
    function ReadChannelCount: Integer;
    function ChannelAddressText(AChannelNumber: Integer): string;
    function CollectSelectedChannels: TStringList;
  public
    procedure LoadFromResult(const AResult: TRecorderMic140DialogResult);
    procedure StoreToResult(var AResult: TRecorderMic140DialogResult);
  end;

{$R *.lfm}

procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
var
  I: Integer;
begin
  AResult.Host := MIC140DefaultHost;
  AResult.Port := MIC140DefaultPort;
  AResult.ChannelCount := MIC140DefaultChannelCount;
  AResult.DeviceSerial := 0;
  AResult.VersionText := '';
  AResult.ThermoCompensationEnabled := False;
  AResult.SelectedChannels := TStringList.Create;
  SetLength(AResult.ChannelSettings, MIC140MaxChannelCount);
  for I := 0 to High(AResult.ChannelSettings) do
    RecorderMic140InitChannelSettings(AResult.ChannelSettings[I], I, CMic140Mic140SubRev1);
end;

procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
begin
  FreeAndNil(AResult.SelectedChannels);
  SetLength(AResult.ChannelSettings, 0);
end;

function ShowRecorderMic140SettingsDialog(AOwner: TComponent;
  var AResult: TRecorderMic140DialogResult): Boolean;
var
  lDialog: TRecorderMic140SettingsDialog;
begin
  lDialog := TRecorderMic140SettingsDialog.Create(AOwner);
  try
    lDialog.LoadFromResult(AResult);
    Result := lDialog.ShowModal = mrOk;
    if Result then
      lDialog.StoreToResult(AResult);
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderMic140SettingsDialog.FormCreate(Sender: TObject);
begin
  fDeviceSerial := 0;
  fDevSubRev := CMic140Mic140SubRev1;
  SetLength(fChannelSettings, 0);
  InitGrid;
end;

procedure TRecorderMic140SettingsDialog.InitGrid;
begin
  fGrid.ColCount := 7;
  fGrid.Cells[0, 0] := 'Исп.';
  fGrid.Cells[1, 0] := 'Адрес';
  fGrid.Cells[2, 0] := 'Имя';
  fGrid.Cells[3, 0] := 'Диапазон [°C]';
  fGrid.Cells[4, 0] := 'Канал КХС';
  fGrid.Cells[5, 0] := 'Диапазон [mV]';
  fGrid.Cells[6, 0] := 'ГХ';
  fGrid.ColWidths[0] := 36;
  fGrid.ColWidths[1] := 76;
  fGrid.ColWidths[2] := 132;
  fGrid.ColWidths[3] := 96;
  fGrid.ColWidths[4] := 64;
  fGrid.ColWidths[5] := 96;
  fGrid.ColWidths[6] := 120;
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
  lSettings: TRecorderMic140ChannelSettings;
begin
  if (ARow <= 0) or (ARow >= fGrid.RowCount) then
    Exit;
  EnsureChannelSettings(ReadChannelCount);
  lSettings := fChannelSettings[ARow - 1];
  if ShowRecorderMic140ChannelDialog(Self, ARow, fDeviceSerial, fDevSubRev, lSettings) then
  begin
    fChannelSettings[ARow - 1] := lSettings;
    FillGrid(ReadChannelCount, CollectSelectedChannels);
  end;
end;

procedure TRecorderMic140SettingsDialog.GridClick(Sender: TObject);
begin
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
  if (Trim(AResult.VersionText) = '') and (Trim(AResult.Host) <> '') then
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

end.
