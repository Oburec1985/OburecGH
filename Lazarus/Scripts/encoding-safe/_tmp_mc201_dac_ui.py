# -*- coding: utf-8 -*-
"""Add editable balance DAC fields to MC-201 slot settings dialog."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

PAS = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\UI\uRecorderMc201SlotSettingsDialog.pas"
)
LFM = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\UI\uRecorderMc201SlotSettingsDialog.lfm"
)

pas = r'''unit uRecorderMc201SlotSettingsDialog;

{
  LFM-диалог аппаратных свойств одного слота MC-201.

  Открывается только двойным кликом по дочернему узлу модуля, не по MC-032.
  Настройки четырёх каналов (диапазон, ФВЧ, ФНЧ, режим входа, ICP, ЦАП),
  коммутация и субмодуль сохраняются в конфигурационном тексте контроллера
  по номеру слота и не должны стираться повторным поиском модулей.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ButtonPanel, Dialogs;

type
  TRecorderMc201SlotSettingsDialog = class(TForm)
    fButtonPanel: TButtonPanel;
    fCommutationGroup: TRadioGroup;
    fDac1: TEdit;
    fDac2: TEdit;
    fDac3: TEdit;
    fDac4: TEdit;
    fHpf1: TCheckBox;
    fHpf2: TCheckBox;
    fHpf3: TCheckBox;
    fHpf4: TCheckBox;
    fIcp1: TCheckBox;
    fIcp2: TCheckBox;
    fIcp3: TCheckBox;
    fIcp4: TCheckBox;
    fInput1: TComboBox;
    fInput2: TComboBox;
    fInput3: TComboBox;
    fInput4: TComboBox;
    fLpf1: TCheckBox;
    fLpf2: TCheckBox;
    fLpf3: TCheckBox;
    fLpf4: TCheckBox;
    fRange1: TComboBox;
    fRange2: TComboBox;
    fRange3: TComboBox;
    fRange4: TComboBox;
    fRevisionCombo: TComboBox;
    fSerialEdit: TEdit;
    fSubmoduleCombo: TComboBox;
    fVersionEdit: TEdit;
  private
    fUpdating: Boolean;
    fDacCodes: array[0..3, 0..5] of Word;
    fLastRange: array[0..3] of Integer;
    procedure FillChoices;
    procedure IcpClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure RangeChange(Sender: TObject);
    procedure SubmoduleChange(Sender: TObject);
    procedure SyncIcpControls(AResetUnchecked: Boolean);
    procedure SyncSubmoduleControls;
    procedure ResetDacCodes;
    procedure ShowDacEdits;
    function ChannelIndexOfRangeCombo(ACombo: TComboBox): Integer;
    function TryParseDacText(const AText: string; out ACode: Word): Boolean;
    function CommitDacEdits(AShowErrors: Boolean): Boolean;
    procedure LoadSettings(const AConfigText: string; ASlot: Integer);
    procedure SaveSettings(var AConfigText: string; ASlot: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  end;

function TryParseRecorderMc201ModuleCaption(const ACaption: string;
  out ASlot: Integer; out ASerial, AVersion: string): Boolean;
function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;
  const AModuleCaption: string; var AConfigText: string): Boolean;

implementation

uses
  Math, StrUtils;

{$R *.lfm}

function ExtractCaptionValue(const ACaption, AKey: string): string;
var
  lEnd: SizeInt;
  lStart: SizeInt;
begin
  Result := '';
  lStart := Pos(AKey, ACaption);
  if lStart = 0 then Exit;
  Inc(lStart, Length(AKey));
  lEnd := PosEx(',', ACaption, lStart);
  if lEnd = 0 then lEnd := Length(ACaption) + 1;
  Result := Trim(Copy(ACaption, lStart, lEnd - lStart));
end;

function TryParseRecorderMc201ModuleCaption(const ACaption: string;
  out ASlot: Integer; out ASerial, AVersion: string): Boolean;
var
  lColon: SizeInt;
  lPrefix: string;
  lText: string;
begin
  ASlot := 0;
  ASerial := '';
  AVersion := '';
  lPrefix := 'Слот ';
  lText := Trim(ACaption);
  Result := (Pos(lPrefix, lText) = 1) and
    (Pos('MC-201', UpperCase(lText)) > 0);
  if not Result then Exit;
  lColon := Pos(':', lText);
  Result := (lColon > Length(lPrefix)) and
    TryStrToInt(Trim(Copy(lText, Length(lPrefix) + 1,
      lColon - Length(lPrefix) - 1)), ASlot) and (ASlot > 0);
  if not Result then Exit;
  ASerial := ExtractCaptionValue(lText, 'SN=');
  AVersion := ExtractCaptionValue(lText, 'version=');
end;

constructor TRecorderMc201SlotSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ResetDacCodes;
  FillChoices;
end;

procedure TRecorderMc201SlotSettingsDialog.ResetDacCodes;
var
  I, J: Integer;
begin
  for I := 0 to 3 do
  begin
    fLastRange[I] := 1;
    for J := 0 to 5 do
      fDacCodes[I, J] := $8080;
  end;
end;

procedure TRecorderMc201SlotSettingsDialog.ShowDacEdits;
var
  lDacs: array[0..3] of TEdit;
  lRanges: array[0..3] of TComboBox;
  I, lRange: Integer;
begin
  lDacs[0] := fDac1; lDacs[1] := fDac2; lDacs[2] := fDac3; lDacs[3] := fDac4;
  lRanges[0] := fRange1; lRanges[1] := fRange2;
  lRanges[2] := fRange3; lRanges[3] := fRange4;
  for I := 0 to 3 do
  begin
    lRange := EnsureRange(lRanges[I].ItemIndex, 0, 5);
    fLastRange[I] := lRange;
    lDacs[I].Text := Format('$%.4x', [fDacCodes[I, lRange]]);
  end;
end;

function TRecorderMc201SlotSettingsDialog.ChannelIndexOfRangeCombo(
  ACombo: TComboBox): Integer;
begin
  if ACombo = fRange1 then Result := 0
  else if ACombo = fRange2 then Result := 1
  else if ACombo = fRange3 then Result := 2
  else if ACombo = fRange4 then Result := 3
  else Result := -1;
end;

function TRecorderMc201SlotSettingsDialog.TryParseDacText(const AText: string;
  out ACode: Word): Boolean;
var
  lText: string;
  lValue: Integer;
begin
  ACode := $8080;
  lText := Trim(AText);
  if lText = '' then
  begin
    Result := True;
    Exit;
  end;
  if (Length(lText) > 0) and (lText[1] = '$') then
    Delete(lText, 1, 1);
  if (Length(lText) > 1) and ((lText[1] = '0') or (lText[1] = '0')) and
    ((lText[2] = 'x') or (lText[2] = 'X')) then
    Delete(lText, 1, 2);
  Result := TryStrToInt('$' + lText, lValue);
  if not Result then
    Result := TryStrToInt(lText, lValue);
  if Result then
    ACode := Word(EnsureRange(lValue, 0, $ffff));
end;

function TRecorderMc201SlotSettingsDialog.CommitDacEdits(
  AShowErrors: Boolean): Boolean;
var
  lDacs: array[0..3] of TEdit;
  lRanges: array[0..3] of TComboBox;
  I, lRange: Integer;
  lCode: Word;
begin
  Result := False;
  lDacs[0] := fDac1; lDacs[1] := fDac2; lDacs[2] := fDac3; lDacs[3] := fDac4;
  lRanges[0] := fRange1; lRanges[1] := fRange2;
  lRanges[2] := fRange3; lRanges[3] := fRange4;
  for I := 0 to 3 do
  begin
    if not TryParseDacText(lDacs[I].Text, lCode) then
    begin
      if AShowErrors then
        MessageDlg('Свойства MC-201',
          Format('Канал %d: неверный код ЦАП "%s". Ожидается $0000..$FFFF.',
            [I + 1, lDacs[I].Text]), mtWarning, [mbOK], 0);
      Exit;
    end;
    lRange := EnsureRange(lRanges[I].ItemIndex, 0, 5);
    fDacCodes[I, lRange] := lCode;
    fLastRange[I] := lRange;
    lDacs[I].Text := Format('$%.4x', [lCode]);
  end;
  Result := True;
end;

procedure TRecorderMc201SlotSettingsDialog.FillChoices;
var
  I: Integer;
  lInputs: array[0..3] of TComboBox;
  lRanges: array[0..3] of TComboBox;
begin
  lRanges[0] := fRange1; lRanges[1] := fRange2;
  lRanges[2] := fRange3; lRanges[3] := fRange4;
  lInputs[0] := fInput1; lInputs[1] := fInput2;
  lInputs[2] := fInput3; lInputs[3] := fInput4;
  for I := 0 to 3 do
  begin
    { Порядок обязан совпадать с таблицей ranges_MC201 из оригинального
      Mc201.cpp: индекс элемента является аппаратным кодом диапазона. }
    lRanges[I].Items.Add('8.5 В');
    lRanges[I].Items.Add('2 В');
    lRanges[I].Items.Add('1 В');
    lRanges[I].Items.Add('0.2 В');
    lRanges[I].Items.Add('0.1 В');
    lRanges[I].Items.Add('0.02 В');
    { Исходное состояние MC-201 соответствует диапазону 2 В (индекс 1). }
    lRanges[I].ItemIndex := 1;
    lRanges[I].OnChange := @RangeChange;
    lInputs[I].Items.Add('Дифференциальный');
    lInputs[I].Items.Add('Однопроводный');
    lInputs[I].ItemIndex := 0;
  end;
  fIcp1.OnClick := @IcpClick;
  fIcp2.OnClick := @IcpClick;
  fIcp3.OnClick := @IcpClick;
  fIcp4.OnClick := @IcpClick;
  fSubmoduleCombo.Items.Add('Отсутствует');
  fSubmoduleCombo.Items.Add('Выбромодуль 4 канала');
  fSubmoduleCombo.ItemIndex := 1;
  fSubmoduleCombo.OnChange := @SubmoduleChange;
  fRevisionCombo.Items.Add('v5.0');
  fRevisionCombo.Items.Add('Другая');
  fRevisionCombo.ItemIndex := 0;
  fCommutationGroup.ItemIndex := 0;
  ShowDacEdits;
  SyncSubmoduleControls;
end;

procedure TRecorderMc201SlotSettingsDialog.SyncIcpControls(
  AResetUnchecked: Boolean);
var
  I: Integer;
  lHasMm202: Boolean;
  lIcps: array[0..3] of TCheckBox;
  lInputs: array[0..3] of TComboBox;
begin
  lIcps[0] := fIcp1; lIcps[1] := fIcp2;
  lIcps[2] := fIcp3; lIcps[3] := fIcp4;
  lInputs[0] := fInput1; lInputs[1] := fInput2;
  lInputs[2] := fInput3; lInputs[3] := fInput4;
  lHasMm202 := fSubmoduleCombo.ItemIndex = 1;
  for I := 0 to 3 do
  begin
    if lIcps[I].Checked then
      lInputs[I].ItemIndex := 1
    else if AResetUnchecked then
      lInputs[I].ItemIndex := 0;
    lInputs[I].Enabled := lHasMm202 and (not lIcps[I].Checked);
  end;
end;

procedure TRecorderMc201SlotSettingsDialog.SyncSubmoduleControls;
var
  I: Integer;
  lEnabled: Boolean;
  lIcps: array[0..3] of TCheckBox;
begin
  lEnabled := fSubmoduleCombo.ItemIndex = 1;
  fRevisionCombo.Enabled := lEnabled;
  lIcps[0] := fIcp1; lIcps[1] := fIcp2;
  lIcps[2] := fIcp3; lIcps[3] := fIcp4;
  for I := 0 to 3 do
    lIcps[I].Enabled := lEnabled;
  SyncIcpControls(False);
end;

procedure TRecorderMc201SlotSettingsDialog.IcpClick(Sender: TObject);
begin
  if fUpdating then
    Exit;
  { Точное поведение Cmc201pp::OnIcpCheck: ICP всегда означает
    недифференциальный вход; снятие галочки сбрасывает режим в дифференциальный. }
  SyncIcpControls(True);
end;

procedure TRecorderMc201SlotSettingsDialog.SubmoduleChange(Sender: TObject);
begin
  if fUpdating then
    Exit;
  SyncSubmoduleControls;
end;

procedure TRecorderMc201SlotSettingsDialog.RangeChange(Sender: TObject);
var
  lDacs: array[0..3] of TEdit;
  lChannel: Integer;
  lCode: Word;
  lNewRange: Integer;
begin
  if fUpdating then
    Exit;
  lChannel := ChannelIndexOfRangeCombo(Sender as TComboBox);
  if lChannel < 0 then
    Exit;
  lDacs[0] := fDac1; lDacs[1] := fDac2; lDacs[2] := fDac3; lDacs[3] := fDac4;
  { Сохраняем правку в код предыдущего диапазона, затем показываем код нового. }
  if TryParseDacText(lDacs[lChannel].Text, lCode) then
    fDacCodes[lChannel, EnsureRange(fLastRange[lChannel], 0, 5)] := lCode;
  lNewRange := EnsureRange((Sender as TComboBox).ItemIndex, 0, 5);
  fLastRange[lChannel] := lNewRange;
  lDacs[lChannel].Text := Format('$%.4x', [fDacCodes[lChannel, lNewRange]]);
end;

procedure TRecorderMc201SlotSettingsDialog.OkClick(Sender: TObject);
begin
  if CommitDacEdits(True) then
    ModalResult := mrOk
  else
    ModalResult := mrNone;
end;

procedure TRecorderMc201SlotSettingsDialog.LoadSettings(
  const AConfigText: string; ASlot: Integer);
var
  I, J, K: Integer;
  lFields: TStringList;
  lLines: TStringList;
  lPrefix: string;
  lChecks: array[0..11] of TCheckBox;
  lCombos: array[0..7] of TComboBox;
  lKey: string;
begin
  fUpdating := True;
  ResetDacCodes;
  lPrefix := 'CFG slot=' + IntToStr(ASlot) + ';';
  lCombos[0] := fRange1; lCombos[1] := fRange2;
  lCombos[2] := fRange3; lCombos[3] := fRange4;
  lCombos[4] := fInput1; lCombos[5] := fInput2;
  lCombos[6] := fInput3; lCombos[7] := fInput4;
  lChecks[0] := fHpf1; lChecks[1] := fHpf2; lChecks[2] := fHpf3; lChecks[3] := fHpf4;
  lChecks[4] := fLpf1; lChecks[5] := fLpf2; lChecks[6] := fLpf3; lChecks[7] := fLpf4;
  lChecks[8] := fIcp1; lChecks[9] := fIcp2; lChecks[10] := fIcp3; lChecks[11] := fIcp4;
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  try
    lLines.Text := AConfigText;
    for I := 0 to lLines.Count - 1 do
      if Pos(lPrefix, lLines[I]) = 1 then
      begin
        lFields.StrictDelimiter := True;
        lFields.Delimiter := ';';
        lFields.NameValueSeparator := '=';
        lFields.DelimitedText := StringReplace(
          Copy(lLines[I], Length(lPrefix) + 1, MaxInt), ',', ';',
          [rfReplaceAll]);
        for J := 0 to 7 do
          lCombos[J].ItemIndex := StrToIntDef(lFields.Values['c' + IntToStr(J)],
            lCombos[J].ItemIndex);
        for J := 0 to 11 do
          lChecks[J].Checked := lFields.Values['b' + IntToStr(J)] = '1';
        fCommutationGroup.ItemIndex := StrToIntDef(lFields.Values['comm'], 0);
        fSubmoduleCombo.ItemIndex := StrToIntDef(lFields.Values['sub'], 1);
        fRevisionCombo.ItemIndex := StrToIntDef(lFields.Values['rev'], 0);
        for J := 0 to 3 do
          for K := 0 to 5 do
          begin
            lKey := 'd' + IntToStr(J) + 'r' + IntToStr(K);
            if lFields.Values[lKey] <> '' then
              fDacCodes[J, K] := Word(EnsureRange(
                StrToIntDef(lFields.Values[lKey], $8080), 0, $ffff));
          end;
        Break;
      end;
  finally
    lFields.Free;
    lLines.Free;
    ShowDacEdits;
    fUpdating := False;
  end;
  { OnInitDialog оригинала принудительно показывает недифференциальный режим
    для уже сохранённого ICP и запрещает ручное изменение combo. }
  SyncSubmoduleControls;
end;

procedure TRecorderMc201SlotSettingsDialog.SaveSettings(
  var AConfigText: string; ASlot: Integer);
var
  I, J, K: Integer;
  lLine: string;
  lLines: TStringList;
  lPrefix: string;
  lChecks: array[0..11] of TCheckBox;
  lCombos: array[0..7] of TComboBox;
begin
  CommitDacEdits(False);
  lPrefix := 'CFG slot=' + IntToStr(ASlot) + ';';
  lCombos[0] := fRange1; lCombos[1] := fRange2; lCombos[2] := fRange3; lCombos[3] := fRange4;
  lCombos[4] := fInput1; lCombos[5] := fInput2; lCombos[6] := fInput3; lCombos[7] := fInput4;
  lChecks[0] := fHpf1; lChecks[1] := fHpf2; lChecks[2] := fHpf3; lChecks[3] := fHpf4;
  lChecks[4] := fLpf1; lChecks[5] := fLpf2; lChecks[6] := fLpf3; lChecks[7] := fLpf4;
  lChecks[8] := fIcp1; lChecks[9] := fIcp2; lChecks[10] := fIcp3; lChecks[11] := fIcp4;
  lLine := lPrefix;
  for I := 0 to 7 do lLine += Format('c%d=%d;', [I, lCombos[I].ItemIndex]);
  for I := 0 to 11 do lLine += Format('b%d=%d;', [I, Ord(lChecks[I].Checked)]);
  lLine += Format('comm=%d;sub=%d;rev=%d;', [fCommutationGroup.ItemIndex,
    fSubmoduleCombo.ItemIndex, fRevisionCombo.ItemIndex]);
  { ЦАП по диапазонам: d{канал}r{диапазон}. Пишем все ячейки, включая $8080,
    чтобы ручной сброс нейтрали не терялся при следующем открытии. }
  for J := 0 to 3 do
    for K := 0 to 5 do
      lLine += Format('d%dr%d=%d;', [J, K, fDacCodes[J, K]]);
  lLines := TStringList.Create;
  try
    lLines.Text := AConfigText;
    for I := lLines.Count - 1 downto 0 do
      if Pos(lPrefix, lLines[I]) = 1 then
        lLines.Delete(I);
    lLines.Add(lLine);
    AConfigText := lLines.Text;
  finally
    lLines.Free;
  end;
end;

function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;
  const AModuleCaption: string; var AConfigText: string): Boolean;
var
  lDialog: TRecorderMc201SlotSettingsDialog;
  lSerial: string;
  lSlot: Integer;
  lVersion: string;
begin
  Result := TryParseRecorderMc201ModuleCaption(AModuleCaption, lSlot,
    lSerial, lVersion);
  if not Result then Exit;
  lDialog := TRecorderMc201SlotSettingsDialog.Create(AOwner);
  try
    lDialog.Caption := Format('Слот %d — свойства MC-201', [lSlot]);
    lDialog.fSerialEdit.Text := lSerial;
    lDialog.fVersionEdit.Text := lVersion;
    lDialog.LoadSettings(AConfigText, lSlot);
    lDialog.fButtonPanel.OKButton.ModalResult := mrNone;
    lDialog.fButtonPanel.OKButton.OnClick := @lDialog.OkClick;
    Result := lDialog.ShowModal = mrOk;
    if Result then lDialog.SaveSettings(AConfigText, lSlot);
  finally
    lDialog.Free;
  end;
end;

end.
'''

# Fix the silly redundant check I left in TryParseDacText
pas = pas.replace(
    """  if (Length(lText) > 1) and ((lText[1] = '0') or (lText[1] = '0')) and
    ((lText[2] = 'x') or (lText[2] = 'X')) then
    Delete(lText, 1, 2);
""",
    """  if (Length(lText) > 1) and (lText[1] = '0') and
    ((lText[2] = 'x') or (lText[2] = 'X')) then
    Delete(lText, 1, 2);
""",
)

write_utf8_crlf(PAS, pas)

lfm = '''object RecorderMc201SlotSettingsDialog: TRecorderMc201SlotSettingsDialog
  Left = 420
  Height = 430
  Top = 220
  Width = 740
  BorderStyle = bsDialog
  Caption = 'Аппаратные свойства MC-201'
  ClientHeight = 430
  ClientWidth = 740
  Position = poOwnerFormCenter
  object fSerialEdit: TEdit
    Left = 120
    Height = 25
    Top = 16
    Width = 190
    ReadOnly = True
    TabOrder = 0
  end
  object fVersionEdit: TEdit
    Left = 430
    Height = 25
    Top = 16
    Width = 190
    ReadOnly = True
    TabOrder = 1
  end
  object SerialLabel: TLabel
    Left = 16
    Top = 21
    Caption = 'Серийный номер'
  end
  object VersionLabel: TLabel
    Left = 330
    Top = 21
    Caption = 'Версия'
  end
  object ChannelGroup: TGroupBox
    Left = 16
    Height = 190
    Top = 55
    Width = 708
    Caption = 'Каналы'
    TabOrder = 2
    object HeaderRange: TLabel
      Left = 45
      Top = 24
      Caption = 'Диапазон'
    end
    object HeaderHpf: TLabel
      Left = 160
      Top = 24
      Caption = 'HPF'
    end
    object HeaderLpf: TLabel
      Left = 200
      Top = 24
      Caption = 'LPF'
    end
    object HeaderInput: TLabel
      Left = 280
      Top = 24
      Caption = 'Режим входа'
    end
    object HeaderDac: TLabel
      Left = 500
      Top = 24
      Caption = 'ЦАП'
    end
    object HeaderIcp: TLabel
      Left = 590
      Top = 24
      Caption = 'ICP'
    end
    object Ch1Label: TLabel
      Left = 15
      Top = 55
      Caption = '1.'
    end
    object Ch2Label: TLabel
      Left = 15
      Top = 87
      Caption = '2.'
    end
    object Ch3Label: TLabel
      Left = 15
      Top = 119
      Caption = '3.'
    end
    object Ch4Label: TLabel
      Left = 15
      Top = 151
      Caption = '4.'
    end
    object fRange1: TComboBox
      Left = 40
      Height = 25
      Top = 48
      Width = 110
      Style = csDropDownList
      TabOrder = 0
    end
    object fRange2: TComboBox
      Left = 40
      Height = 25
      Top = 80
      Width = 110
      Style = csDropDownList
      TabOrder = 1
    end
    object fRange3: TComboBox
      Left = 40
      Height = 25
      Top = 112
      Width = 110
      Style = csDropDownList
      TabOrder = 2
    end
    object fRange4: TComboBox
      Left = 40
      Height = 25
      Top = 144
      Width = 110
      Style = csDropDownList
      TabOrder = 3
    end
    object fHpf1: TCheckBox
      Left = 165
      Height = 23
      Top = 49
      Width = 22
      TabOrder = 4
    end
    object fHpf2: TCheckBox
      Left = 165
      Height = 23
      Top = 81
      Width = 22
      TabOrder = 5
    end
    object fHpf3: TCheckBox
      Left = 165
      Height = 23
      Top = 113
      Width = 22
      TabOrder = 6
    end
    object fHpf4: TCheckBox
      Left = 165
      Height = 23
      Top = 145
      Width = 22
      TabOrder = 7
    end
    object fLpf1: TCheckBox
      Left = 205
      Height = 23
      Top = 49
      Width = 22
      TabOrder = 8
    end
    object fLpf2: TCheckBox
      Left = 205
      Height = 23
      Top = 81
      Width = 22
      TabOrder = 9
    end
    object fLpf3: TCheckBox
      Left = 205
      Height = 23
      Top = 113
      Width = 22
      TabOrder = 10
    end
    object fLpf4: TCheckBox
      Left = 205
      Height = 23
      Top = 145
      Width = 22
      TabOrder = 11
    end
    object fInput1: TComboBox
      Left = 245
      Height = 25
      Top = 48
      Width = 235
      Style = csDropDownList
      TabOrder = 12
    end
    object fInput2: TComboBox
      Left = 245
      Height = 25
      Top = 80
      Width = 235
      Style = csDropDownList
      TabOrder = 13
    end
    object fInput3: TComboBox
      Left = 245
      Height = 25
      Top = 112
      Width = 235
      Style = csDropDownList
      TabOrder = 14
    end
    object fInput4: TComboBox
      Left = 245
      Height = 25
      Top = 144
      Width = 235
      Style = csDropDownList
      TabOrder = 15
    end
    object fDac1: TEdit
      Left = 495
      Height = 25
      Top = 48
      Width = 75
      TabOrder = 16
      Text = '$8080'
    end
    object fDac2: TEdit
      Left = 495
      Height = 25
      Top = 80
      Width = 75
      TabOrder = 17
      Text = '$8080'
    end
    object fDac3: TEdit
      Left = 495
      Height = 25
      Top = 112
      Width = 75
      TabOrder = 18
      Text = '$8080'
    end
    object fDac4: TEdit
      Left = 495
      Height = 25
      Top = 144
      Width = 75
      TabOrder = 19
      Text = '$8080'
    end
    object fIcp1: TCheckBox
      Left = 595
      Height = 23
      Top = 49
      Width = 22
      TabOrder = 20
    end
    object fIcp2: TCheckBox
      Left = 595
      Height = 23
      Top = 81
      Width = 22
      TabOrder = 21
    end
    object fIcp3: TCheckBox
      Left = 595
      Height = 23
      Top = 113
      Width = 22
      TabOrder = 22
    end
    object fIcp4: TCheckBox
      Left = 595
      Height = 23
      Top = 145
      Width = 22
      TabOrder = 23
    end
  end
  object fCommutationGroup: TRadioGroup
    Left = 16
    Height = 95
    Top = 255
    Width = 220
    Caption = 'Коммутация'
    Items.Strings = (
      'Разъём модуля'
      'Земля'
    )
    TabOrder = 3
  end
  object SubmoduleGroup: TGroupBox
    Left = 248
    Height = 95
    Top = 255
    Width = 476
    Caption = 'Субмодуль'
    TabOrder = 4
    object SubmoduleLabel: TLabel
      Left = 16
      Top = 28
      Caption = 'Тип'
    end
    object RevisionLabel: TLabel
      Left = 16
      Top = 62
      Caption = 'Версия'
    end
    object fSubmoduleCombo: TComboBox
      Left = 90
      Height = 25
      Top = 20
      Width = 360
      Style = csDropDownList
      TabOrder = 0
    end
    object fRevisionCombo: TComboBox
      Left = 90
      Height = 25
      Top = 54
      Width = 360
      Style = csDropDownList
      TabOrder = 1
    end
  end
  object fButtonPanel: TButtonPanel
    Left = 0
    Height = 50
    Top = 380
    Width = 740
    Align = alBottom
    AutoSize = True
    ShowButtons = [pbOK, pbCancel]
    TabOrder = 5
  end
end
'''

LFM.write_text(lfm, encoding="utf-8", newline="\r\n")
print("written pas+lfm")
