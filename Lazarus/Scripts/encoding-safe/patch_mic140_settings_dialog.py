#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Rewrite uRecorderMic140SettingsDialog.pas — original-style MIC-140 setup UI."""
from __future__ import annotations

from pathlib import Path

TARGET = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140\UI\uRecorderMic140SettingsDialog.pas"
)

CONTENT = r'''unit uRecorderMic140SettingsDialog;

{
  Runtime-built MIC-140 setup dialog (original Recorder layout).

  Shows device serial/version, channel grid with CJC mapping and ADC range.
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
    PollFrequencyHz: Double;
    DeviceSerial: Integer;
    VersionText: string;
    ThermoCompensationEnabled: Boolean;
    DefaultCorrector: Boolean;
    CorrectorChannel: string;
    OutputMode: TRecorderMic140OutputMode;
    SelectedChannels: TStringList;
  end;

function ShowRecorderMic140SettingsDialog(AOwner: TComponent;
  var AResult: TRecorderMic140DialogResult): Boolean;
procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);

implementation

type
  TRecorderMic140SettingsDialog = class(TForm)
  private
    fHostEdit: TEdit;
    fPortEdit: TEdit;
    fFrequencyEdit: TComboBox;
    fChannelCountCombo: TComboBox;
    fSerialEdit: TEdit;
    fVersionEdit: TEdit;
    fTimingLabel: TLabel;
    fThermoCompCheck: TCheckBox;
    fDefaultCorrectorCheck: TCheckBox;
    fCorrectorCombo: TComboBox;
    fOutputModeCombo: TComboBox;
    fGrid: TStringGrid;
    fDeviceSerial: Integer;
    procedure BuildUi;
    procedure FillGrid(AChannelCount: Integer; ASelected: TStrings);
    procedure ToggleGridRow(ARow: Integer);
    procedure GridDblClick(Sender: TObject);
    procedure ChannelCountChange(Sender: TObject);
    procedure SearchClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure FrequencyChange(Sender: TObject);
    procedure UpdateDeviceCaption;
    procedure QueryDeviceInfo;
    function ReadPort: Word;
    function ReadFrequency: Double;
    function ReadChannelCount: Integer;
    function CjcChannelText(AChannelIndex: Integer): string;
    function ChannelAddressText(AChannelNumber: Integer): string;
    function ChannelRangeIndex(AChannelNumber: Integer): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromResult(const AResult: TRecorderMic140DialogResult);
    procedure StoreToResult(var AResult: TRecorderMic140DialogResult);
  end;

procedure InitRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
begin
  AResult.Host := MIC140DefaultHost;
  AResult.Port := MIC140DefaultPort;
  AResult.ChannelCount := MIC140DefaultChannelCount;
  AResult.PollFrequencyHz := MIC140DefaultPollFrequencyHz;
  AResult.DeviceSerial := 0;
  AResult.VersionText := '';
  AResult.ThermoCompensationEnabled := False;
  AResult.DefaultCorrector := True;
  AResult.CorrectorChannel := 'T2';
  AResult.OutputMode := momMillivolts;
  AResult.SelectedChannels := TStringList.Create;
end;

procedure DoneRecorderMic140DialogResult(var AResult: TRecorderMic140DialogResult);
begin
  FreeAndNil(AResult.SelectedChannels);
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

constructor TRecorderMic140SettingsDialog.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  fDeviceSerial := 0;
  BuildUi;
end;

procedure TRecorderMic140SettingsDialog.BuildUi;
var
  lBottom: TPanel;
  lButton: TButton;
  lButtonPanel: TPanel;
  I: Integer;
  lTop: TPanel;
begin
  Caption := 'MIC-140';
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  ClientWidth := 920;
  ClientHeight := 580;
  Constraints.MinWidth := 760;
  Constraints.MinHeight := 480;

  lTop := TPanel.Create(Self);
  lTop.Parent := Self;
  lTop.Align := alTop;
  lTop.Height := 168;
  lTop.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 12;
    Top := 12;
    Caption := 'Серийный номер';
  end;
  fSerialEdit := TEdit.Create(Self);
  fSerialEdit.Parent := lTop;
  fSerialEdit.Left := 120;
  fSerialEdit.Top := 8;
  fSerialEdit.Width := 72;
  fSerialEdit.ReadOnly := True;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 210;
    Top := 12;
    Caption := 'Версия';
  end;
  fVersionEdit := TEdit.Create(Self);
  fVersionEdit.Parent := lTop;
  fVersionEdit.Left := 268;
  fVersionEdit.Top := 8;
  fVersionEdit.Width := 96;
  fVersionEdit.ReadOnly := True;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 12;
    Top := 44;
    Caption := 'IP';
  end;
  fHostEdit := TEdit.Create(Self);
  fHostEdit.Parent := lTop;
  fHostEdit.Left := 46;
  fHostEdit.Top := 40;
  fHostEdit.Width := 128;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 188;
    Top := 44;
    Caption := 'Port';
  end;
  fPortEdit := TEdit.Create(Self);
  fPortEdit.Parent := lTop;
  fPortEdit.Left := 226;
  fPortEdit.Top := 40;
  fPortEdit.Width := 58;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 300;
    Top := 44;
    Caption := 'Каналов';
  end;
  fChannelCountCombo := TComboBox.Create(Self);
  fChannelCountCombo.Parent := lTop;
  fChannelCountCombo.Left := 366;
  fChannelCountCombo.Top := 40;
  fChannelCountCombo.Width := 72;
  fChannelCountCombo.Style := csDropDownList;
  fChannelCountCombo.Items.Add('48');
  fChannelCountCombo.Items.Add('96');
  fChannelCountCombo.OnChange := @ChannelCountChange;

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 454;
    Top := 44;
    Caption := 'Гц';
  end;
  fFrequencyEdit := TComboBox.Create(Self);
  fFrequencyEdit.Parent := lTop;
  fFrequencyEdit.Left := 482;
  fFrequencyEdit.Top := 40;
  fFrequencyEdit.Width := 86;
  fFrequencyEdit.Style := csDropDownList;
  for I := 0 to RecorderMic140FrequencyCount - 1 do
    fFrequencyEdit.Items.Add(FormatFloat('0.######', RecorderMic140Frequency(I)));
  fFrequencyEdit.OnChange := @FrequencyChange;

  lButton := TButton.Create(Self);
  lButton.Parent := lTop;
  lButton.Left := 590;
  lButton.Top := 36;
  lButton.Width := 126;
  lButton.Height := 28;
  lButton.Caption := 'Автопоиск';
  lButton.OnClick := @SearchClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lTop;
  lButton.Left := 724;
  lButton.Top := 36;
  lButton.Width := 126;
  lButton.Height := 28;
  lButton.Caption := 'Проверка связи';
  lButton.OnClick := @TestClick;

  fThermoCompCheck := TCheckBox.Create(Self);
  fThermoCompCheck.Parent := lTop;
  fThermoCompCheck.Left := 12;
  fThermoCompCheck.Top := 78;
  fThermoCompCheck.Width := 170;
  fThermoCompCheck.Caption := 'Термокомпенсация';

  fDefaultCorrectorCheck := TCheckBox.Create(Self);
  fDefaultCorrectorCheck.Parent := lTop;
  fDefaultCorrectorCheck.Left := 200;
  fDefaultCorrectorCheck.Top := 78;
  fDefaultCorrectorCheck.Width := 150;
  fDefaultCorrectorCheck.Caption := 'КХС по умолчанию';

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 370;
    Top := 80;
    Caption := 'КХС';
  end;
  fCorrectorCombo := TComboBox.Create(Self);
  fCorrectorCombo.Parent := lTop;
  fCorrectorCombo.Left := 410;
  fCorrectorCombo.Top := 74;
  fCorrectorCombo.Width := 70;
  fCorrectorCombo.Style := csDropDownList;
  for I := 1 to MIC140TemperatureChannelCount do
    fCorrectorCombo.Items.Add('T' + IntToStr(I));

  with TLabel.Create(Self) do
  begin
    Parent := lTop;
    Left := 500;
    Top := 80;
    Caption := 'Значение';
  end;
  fOutputModeCombo := TComboBox.Create(Self);
  fOutputModeCombo.Parent := lTop;
  fOutputModeCombo.Left := 566;
  fOutputModeCombo.Top := 74;
  fOutputModeCombo.Width := 116;
  fOutputModeCombo.Style := csDropDownList;
  fOutputModeCombo.Items.Add('мВ');
  fOutputModeCombo.Items.Add('°C');

  fTimingLabel := TLabel.Create(Self);
  fTimingLabel.Parent := lTop;
  fTimingLabel.Left := 12;
  fTimingLabel.Top := 112;
  fTimingLabel.Width := 880;
  fTimingLabel.Caption := '';

  lBottom := TPanel.Create(Self);
  lBottom.Parent := Self;
  lBottom.Align := alBottom;
  lBottom.Height := 44;
  lBottom.BevelOuter := bvNone;

  lButtonPanel := TPanel.Create(Self);
  lButtonPanel.Parent := lBottom;
  lButtonPanel.Align := alRight;
  lButtonPanel.Width := 204;
  lButtonPanel.BevelOuter := bvNone;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := 10;
  lButton.Top := 8;
  lButton.Caption := 'OK';
  lButton.Default := True;
  lButton.ModalResult := mrOk;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := 102;
  lButton.Top := 8;
  lButton.Caption := 'Отмена';
  lButton.Cancel := True;
  lButton.ModalResult := mrCancel;

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.Align := alClient;
  fGrid.FixedCols := 0;
  fGrid.FixedRows := 1;
    fGrid.ColCount := 6;
  fGrid.Options := fGrid.Options + [goRowSelect, goRangeSelect, goColSizing];
  fGrid.OnDblClick := @GridDblClick;
  fGrid.Cells[0, 0] := 'Исп.';
  fGrid.Cells[1, 0] := 'Адрес';
  fGrid.Cells[2, 0] := 'Имя';
  fGrid.Cells[3, 0] := 'Диапазон [°C]';
  fGrid.Cells[4, 0] := 'Канал КХС';
  fGrid.Cells[5, 0] := 'Диапазон [mV]';
  fGrid.ColWidths[0] := 36;
  fGrid.ColWidths[1] := 72;
  fGrid.ColWidths[2] := 140;
  fGrid.ColWidths[3] := 96;
  fGrid.ColWidths[4] := 72;
  fGrid.ColWidths[5] := 110;
end;

function TRecorderMic140SettingsDialog.ChannelAddressText(
  AChannelNumber: Integer): string;
begin
  if fDeviceSerial > 0 then
    Result := Format('%4.4d-%d', [fDeviceSerial, AChannelNumber])
  else
    Result := Format('%4.4d-%2.2d', [0, AChannelNumber]);
end;

function TRecorderMic140SettingsDialog.ChannelRangeIndex(
  AChannelNumber: Integer): Integer;
begin
  Result := 2;
  if (AChannelNumber >= 1) and (AChannelNumber <= MIC140DefaultChannelCount) then
    Result := 2;
end;

function TRecorderMic140SettingsDialog.CjcChannelText(AChannelIndex: Integer): string;
var
  lManual: Integer;
begin
  if fDefaultCorrectorCheck.Checked then
  begin
    Result := IntToStr(RecorderMic140DefaultCjcChannel(AChannelIndex));
    if Result = '0' then
      Result := '';
    Exit;
  end;
  lManual := 0;
  if TryStrToInt(StringReplace(fCorrectorCombo.Text, 'T', '', [rfIgnoreCase]), lManual) then
    Result := IntToStr(lManual)
  else
    Result := Trim(fCorrectorCombo.Text);
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
  lVersion: string;
begin
  lHost := Trim(fHostEdit.Text);
  if lHost = '' then
    Exit;
  Screen.Cursor := crHourGlass;
  try
    if RecorderMic140QueryDeviceInfo(lHost, ReadPort, lSerial, lVersion) then
    begin
      if lSerial > 0 then
        fDeviceSerial := lSerial;
      if lVersion <> '' then
        fVersionEdit.Text := lVersion;
      fSerialEdit.Text := IntToStr(fDeviceSerial);
      UpdateDeviceCaption;
      FillGrid(ReadChannelCount, nil);
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
  lRangeIdx: Integer;
  lRangeMv: string;
  lRangeGrad: string;
begin
  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  fGrid.RowCount := AChannelCount + 1;
  for I := 1 to AChannelCount do
  begin
    lAddress := IntToStr(I);
    if (ASelected = nil) or (ASelected.Count = 0) or
      (ASelected.IndexOf(lAddress) >= 0) then
      fGrid.Cells[0, I] := '[x]'
    else
      fGrid.Cells[0, I] := '[ ]';
    lRangeIdx := ChannelRangeIndex(I);
    lRangeMv := RecorderMic140FormatAdcRangeMv(lRangeIdx);
    lRangeGrad := RecorderMic140FormatAdcRangeGrad(lRangeIdx);
    fGrid.Cells[1, I] := ChannelAddressText(I);
    fGrid.Cells[2, I] := Format('MIC140-{%s}', [fGrid.Cells[1, I]]);
    fGrid.Cells[3, I] := lRangeGrad;
    fGrid.Cells[4, I] := CjcChannelText(I - 1);
    fGrid.Cells[5, I] := lRangeMv;
  end;
end;

procedure TRecorderMic140SettingsDialog.ToggleGridRow(ARow: Integer);
begin
  if (ARow <= 0) or (ARow >= fGrid.RowCount) then
    Exit;
  if fGrid.Cells[0, ARow] = '[x]' then
    fGrid.Cells[0, ARow] := '[ ]'
  else
    fGrid.Cells[0, ARow] := '[x]';
end;

procedure TRecorderMic140SettingsDialog.GridDblClick(Sender: TObject);
begin
  ToggleGridRow(fGrid.Row);
end;

procedure TRecorderMic140SettingsDialog.ChannelCountChange(Sender: TObject);
var
  I: Integer;
  lSelected: TStringList;
begin
  lSelected := TStringList.Create;
  try
    for I := 1 to fGrid.RowCount - 1 do
      if fGrid.Cells[0, I] = '[x]' then
        lSelected.Add(IntToStr(I));
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

function TRecorderMic140SettingsDialog.ReadFrequency: Double;
var
  lText: string;
begin
  lText := Trim(fFrequencyEdit.Text);
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  if not TryStrToFloat(lText, Result) then
    Result := MIC140DefaultPollFrequencyHz;
  if Result <= 0 then
    Result := MIC140DefaultPollFrequencyHz;
  Result := RecorderMic140NormalizeFrequency(Result);
end;

procedure TRecorderMic140SettingsDialog.FrequencyChange(Sender: TObject);
var
  lTiming: TRecorderMic140Timing;
begin
  if fTimingLabel = nil then
    Exit;
  lTiming := RecorderMic140TimingForFrequency(ReadFrequency);
  fTimingLabel.Caption := Format(
    'АЦП: ожидание %.3f мкс, GND %.3f мкс, усреднение %d x %.3f мкс',
    [lTiming.ChannelCommutationUs, lTiming.GroundCommutationUs,
    lTiming.AverageSampleCount, lTiming.AveragePeriodUs]);
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
begin
  fDeviceSerial := AResult.DeviceSerial;
  fHostEdit.Text := AResult.Host;
  fPortEdit.Text := IntToStr(AResult.Port);
  fFrequencyEdit.Text := FormatFloat('0.######',
    RecorderMic140NormalizeFrequency(AResult.PollFrequencyHz));
  if fFrequencyEdit.Items.IndexOf(fFrequencyEdit.Text) < 0 then
    fFrequencyEdit.ItemIndex := 0;
  fSerialEdit.Text := '';
  if AResult.DeviceSerial > 0 then
    fSerialEdit.Text := IntToStr(AResult.DeviceSerial);
  fVersionEdit.Text := AResult.VersionText;
  fThermoCompCheck.Checked := AResult.ThermoCompensationEnabled;
  fDefaultCorrectorCheck.Checked := AResult.DefaultCorrector;
  fCorrectorCombo.Text := AResult.CorrectorChannel;
  if fCorrectorCombo.ItemIndex < 0 then
    fCorrectorCombo.ItemIndex := 1;
  fOutputModeCombo.ItemIndex := Ord(AResult.OutputMode);
  if fOutputModeCombo.ItemIndex < 0 then
    fOutputModeCombo.ItemIndex := 0;
  if AResult.ChannelCount > MIC140DefaultChannelCount then
    fChannelCountCombo.ItemIndex := 1
  else
    fChannelCountCombo.ItemIndex := 0;
  FillGrid(ReadChannelCount, AResult.SelectedChannels);
  FrequencyChange(fFrequencyEdit);
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
  AResult.PollFrequencyHz := ReadFrequency;
  AResult.DeviceSerial := fDeviceSerial;
  AResult.VersionText := Trim(fVersionEdit.Text);
  AResult.ThermoCompensationEnabled := fThermoCompCheck.Checked;
  AResult.DefaultCorrector := fDefaultCorrectorCheck.Checked;
  AResult.CorrectorChannel := Trim(fCorrectorCombo.Text);
  if fOutputModeCombo.ItemIndex = Ord(momTemperatureC) then
    AResult.OutputMode := momTemperatureC
  else
    AResult.OutputMode := momMillivolts;
  if AResult.SelectedChannels <> nil then
  begin
    AResult.SelectedChannels.Clear;
    for I := 1 to fGrid.RowCount - 1 do
      if fGrid.Cells[0, I] = '[x]' then
        AResult.SelectedChannels.Add(IntToStr(I));
  end;
end;

end.
'''


def main() -> int:
    TARGET.write_bytes(CONTENT.replace("\n", "\r\n").encode("utf-8"))
    print("written", TARGET)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
