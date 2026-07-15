unit uRecorderMc201SlotSettingsDialog;

{
  LFM-диалог аппаратных свойств одного слота MC-201.

  Открывается только двойным кликом по дочернему узлу модуля, не по MC-032.
  Настройки четырёх каналов (диапазон, ФВЧ, ФНЧ, режим входа, ICP), коммутация
  и субмодуль сохраняются в конфигурационном тексте контроллера по номеру слота
  и не должны стираться повторным поиском модулей.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ButtonPanel;

type
  TRecorderMc201SlotSettingsDialog = class(TForm)
    fButtonPanel: TButtonPanel;
    fCommutationGroup: TRadioGroup;
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
    procedure FillChoices;
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
  StrUtils;

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
  FillChoices;
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
    lRanges[I].Items.Add('2 В');
    lRanges[I].Items.Add('1 В');
    lRanges[I].Items.Add('0.2 В');
    lRanges[I].Items.Add('0.1 В');
    lRanges[I].ItemIndex := 0;
    lInputs[I].Items.Add('Дифференциальный');
    lInputs[I].Items.Add('Однопроводный');
    lInputs[I].ItemIndex := 0;
  end;
  fSubmoduleCombo.Items.Add('Отсутствует');
  fSubmoduleCombo.Items.Add('Выбромодуль 4 канала');
  fSubmoduleCombo.ItemIndex := 1;
  fRevisionCombo.Items.Add('v5.0');
  fRevisionCombo.Items.Add('Другая');
  fRevisionCombo.ItemIndex := 0;
  fCommutationGroup.ItemIndex := 0;
end;

procedure TRecorderMc201SlotSettingsDialog.LoadSettings(
  const AConfigText: string; ASlot: Integer);
var
  I, J: Integer;
  lFields: TStringList;
  lLines: TStringList;
  lPrefix: string;
  lChecks: array[0..11] of TCheckBox;
  lCombos: array[0..7] of TComboBox;
begin
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
        lFields.DelimitedText := Copy(lLines[I], Length(lPrefix) + 1, MaxInt);
        for J := 0 to 7 do
          lCombos[J].ItemIndex := StrToIntDef(lFields.Values['c' + IntToStr(J)], lCombos[J].ItemIndex);
        for J := 0 to 11 do
          lChecks[J].Checked := lFields.Values['b' + IntToStr(J)] = '1';
        fCommutationGroup.ItemIndex := StrToIntDef(lFields.Values['comm'], 0);
        fSubmoduleCombo.ItemIndex := StrToIntDef(lFields.Values['sub'], 1);
        fRevisionCombo.ItemIndex := StrToIntDef(lFields.Values['rev'], 0);
        Break;
      end;
  finally
    lFields.Free;
    lLines.Free;
  end;
end;

procedure TRecorderMc201SlotSettingsDialog.SaveSettings(
  var AConfigText: string; ASlot: Integer);
var
  I: Integer;
  lLine: string;
  lLines: TStringList;
  lPrefix: string;
  lChecks: array[0..11] of TCheckBox;
  lCombos: array[0..7] of TComboBox;
begin
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
  lLines := TStringList.Create;
  try
    lLines.Text := AConfigText;
    for I := lLines.Count - 1 downto 0 do
      if Pos(lPrefix, lLines[I]) = 1 then lLines.Delete(I);
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
    Result := lDialog.ShowModal = mrOk;
    if Result then lDialog.SaveSettings(AConfigText, lSlot);
  finally
    lDialog.Free;
  end;
end;

end.
