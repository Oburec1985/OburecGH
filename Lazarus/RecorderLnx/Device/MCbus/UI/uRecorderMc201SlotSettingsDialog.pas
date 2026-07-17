unit uRecorderMc201SlotSettingsDialog;

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
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ButtonPanel, Dialogs,
  uRecorderDataSources, uRecorderTags;

type
  TRecorderMc201SlotSettingsDialog = class(TForm)
    fButtonPanel: TButtonPanel;
    fCommutationGroup: TRadioGroup;
    fDacHi1: TEdit;
    fDacHi2: TEdit;
    fDacHi3: TEdit;
    fDacHi4: TEdit;
    fDacLo1: TEdit;
    fDacLo2: TEdit;
    fDacLo3: TEdit;
    fDacLo4: TEdit;
    fDacVolt1: TEdit;
    fDacVolt2: TEdit;
    fDacVolt3: TEdit;
    fDacVolt4: TEdit;
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
    fCalCh1: TCheckBox;
    fCalCh2: TCheckBox;
    fCalCh3: TCheckBox;
    fCalCh4: TCheckBox;
    fCalibrateBtn: TButton;
  private
    fUpdating: Boolean;
    fDacCodes: array[0..3, 0..5] of Word;
    fLastRange: array[0..3] of Integer;
    fSlot: Integer;
    fSourceId: string;
    fDataSources: TRecorderDataSourceManager;
    fRegistry: TRecorderTagRegistry;
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
    function TryParseSignedDac(const AText: string; out ASigned: Integer): Boolean;
    function TryReadChannelDac(AChannel: Integer; out ACode: Word;
      AShowErrors: Boolean): Boolean;
    function CommitDacEdits(AShowErrors: Boolean): Boolean;
    procedure SetChannelDacEdits(AChannel: Integer; ACode: Word);
    procedure SetChannelVoltEdit(AChannel: Integer; ALo, AHi: Integer);
    procedure DacCodeChange(Sender: TObject);
    procedure DacVoltChange(Sender: TObject);
    function ChannelIndexOfDacEdit(AEdit: TEdit; out AIsVolt: Boolean): Integer;
    function TryParseVoltText(const AText: string; out AVolt: Double): Boolean;
    procedure LoadSettings(const AConfigText: string; ASlot: Integer);
    procedure SaveSettings(var AConfigText: string; ASlot: Integer);
    procedure CalibrateClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

function TryParseRecorderMc201ModuleCaption(const ACaption: string;
  out ASlot: Integer; out ASerial, AVersion: string): Boolean;

function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;
  const AModuleCaption: string; var AConfigText: string;
  const ASourceId: string = '';
  ADataSources: TRecorderDataSourceManager = nil;
  ARegistry: TRecorderTagRegistry = nil): Boolean;

implementation

uses
  Math, StrUtils, uMc201ProtocolTypes, uRecorderMcbusDevice,
  uRecorderMc201Calibration, uRecorderHardwareLiveDevices,
  uRecorderDeviceInterfaces;

{$R *.lfm}

procedure TRecorderMc201SlotSettingsDialog.CalibrateClick(Sender: TObject);
var
  lDevice: IRecorderDevice;
  lNative: TRecorderMcbusDevice;
  lSel: array[0..3] of Boolean;
  lRanges: array[0..3] of Integer;
  lSerial: Integer;
  lReport, lErr: string;
  lRev2176: Boolean;
  lCombos: array[0..3] of TComboBox;
begin
  if not CommitDacEdits(True) then
    Exit;
  if fSourceId = '' then
  begin
    MessageDlg('Нет SourceId контроллера — откройте свойства из дерева/тега.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lDevice := RecorderHardwareFindLiveDevice(fSourceId);
  if (lDevice = nil) or not (lDevice.GetNativeObject is TRecorderMcbusDevice) then
  begin
    MessageDlg('MC-032 не подключён (live device). Запустите Preview или Connect.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lNative := TRecorderMcbusDevice(lDevice.GetNativeObject);
  if not TryStrToInt(Trim(fSerialEdit.Text), lSerial) or (lSerial <= 0) then
  begin
    MessageDlg('Некорректный серийный номер модуля (нужен sn для Mera Files).',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lSel[0] := fCalCh1.Checked;
  lSel[1] := fCalCh2.Checked;
  lSel[2] := fCalCh3.Checked;
  lSel[3] := fCalCh4.Checked;
  if not (lSel[0] or lSel[1] or lSel[2] or lSel[3]) then
  begin
    MessageDlg('Выберите хотя бы один канал.', mtInformation, [mbOK], 0);
    Exit;
  end;
  lCombos[0] := fRange1;
  lCombos[1] := fRange2;
  lCombos[2] := fRange3;
  lCombos[3] := fRange4;
  lRanges[0] := EnsureRange(lCombos[0].ItemIndex, 0, 5);
  lRanges[1] := EnsureRange(lCombos[1].ItemIndex, 0, 5);
  lRanges[2] := EnsureRange(lCombos[2].ItemIndex, 0, 5);
  lRanges[3] := EnsureRange(lCombos[3].ItemIndex, 0, 5);
  lRev2176 := fRevisionCombo.ItemIndex > 0;
  Screen.Cursor := crHourGlass;
  try
    if not RecorderMc201CalibrateSlotChannels(lNative, fRegistry, fSourceId,
      fSlot, lSerial, lSel, lRanges, lRev2176, lReport, lErr) then
    begin
      MessageDlg(lErr, mtError, [mbOK], 0);
      Exit;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
  MessageDlg('Калибровка завершена.' + LineEnding + LineEnding + lReport,
    mtInformation, [mbOK], 0);
end;

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
  fSlot := 0;
  fSourceId := '';
  fDataSources := nil;
  fRegistry := nil;
  ResetDacCodes;
  FillChoices;
  fCalibrateBtn.OnClick := @CalibrateClick;
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

procedure TRecorderMc201SlotSettingsDialog.SetChannelVoltEdit(
  AChannel: Integer; ALo, AHi: Integer);
var
  lVolts: array[0..3] of TEdit;
  lFS: TFormatSettings;
begin
  lVolts[0] := fDacVolt1; lVolts[1] := fDacVolt2;
  lVolts[2] := fDacVolt3; lVolts[3] := fDacVolt4;
  lFS := DefaultFormatSettings;
  lVolts[AChannel].Text := FormatFloat('0.########',
    RecorderMc201BalanceVoltFromSigned(ALo, AHi), lFS);
end;

procedure TRecorderMc201SlotSettingsDialog.SetChannelDacEdits(
  AChannel: Integer; ACode: Word);
var
  lLos: array[0..3] of TEdit;
  lHis: array[0..3] of TEdit;
  lLo, lHi: Integer;
begin
  lLos[0] := fDacLo1; lLos[1] := fDacLo2; lLos[2] := fDacLo3; lLos[3] := fDacLo4;
  lHis[0] := fDacHi1; lHis[1] := fDacHi2; lHis[2] := fDacHi3; lHis[3] := fDacHi4;
  { Два 8-бит ЦАП в смещённом формате: 0=-128, 128=0, 255=+127. }
  RecorderMc201BalanceUnpackWord(ACode, lLo, lHi);
  fUpdating := True;
  try
    lLos[AChannel].Text := IntToStr(lLo);
    lHis[AChannel].Text := IntToStr(lHi);
  finally
    fUpdating := False;
  end;
  SetChannelVoltEdit(AChannel, lLo, lHi);
end;

function TRecorderMc201SlotSettingsDialog.ChannelIndexOfDacEdit(AEdit: TEdit;
  out AIsVolt: Boolean): Integer;
begin
  AIsVolt := False;
  if (AEdit = fDacLo1) or (AEdit = fDacHi1) then Result := 0
  else if (AEdit = fDacLo2) or (AEdit = fDacHi2) then Result := 1
  else if (AEdit = fDacLo3) or (AEdit = fDacHi3) then Result := 2
  else if (AEdit = fDacLo4) or (AEdit = fDacHi4) then Result := 3
  else if AEdit = fDacVolt1 then begin AIsVolt := True; Result := 0; end
  else if AEdit = fDacVolt2 then begin AIsVolt := True; Result := 1; end
  else if AEdit = fDacVolt3 then begin AIsVolt := True; Result := 2; end
  else if AEdit = fDacVolt4 then begin AIsVolt := True; Result := 3; end
  else Result := -1;
end;

function TRecorderMc201SlotSettingsDialog.TryParseVoltText(const AText: string;
  out AVolt: Double): Boolean;
var
  lText: string;
  lFs: TFormatSettings;
begin
  AVolt := 0;
  lText := Trim(AText);
  if lText = '' then
  begin
    Result := True;
    Exit;
  end;
  lText := StringReplace(lText, ',', '.', [rfReplaceAll]);
  lFs := DefaultFormatSettings;
  lFs.DecimalSeparator := '.';
  Result := TryStrToFloat(lText, AVolt, lFs);
end;

procedure TRecorderMc201SlotSettingsDialog.DacCodeChange(Sender: TObject);
var
  lChannel: Integer;
  lIsVolt: Boolean;
  lCode: Word;
  lLo, lHi: Integer;
begin
  if fUpdating then
    Exit;
  lChannel := ChannelIndexOfDacEdit(Sender as TEdit, lIsVolt);
  if (lChannel < 0) or lIsVolt then
    Exit;
  if not TryReadChannelDac(lChannel, lCode, False) then
    Exit;
  RecorderMc201BalanceUnpackWord(lCode, lLo, lHi);
  fUpdating := True;
  try
    SetChannelVoltEdit(lChannel, lLo, lHi);
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderMc201SlotSettingsDialog.DacVoltChange(Sender: TObject);
var
  lChannel: Integer;
  lIsVolt: Boolean;
  lVolt: Double;
  lLo, lHi: Integer;
  lLos: array[0..3] of TEdit;
  lHis: array[0..3] of TEdit;
begin
  if fUpdating then
    Exit;
  lChannel := ChannelIndexOfDacEdit(Sender as TEdit, lIsVolt);
  if (lChannel < 0) or (not lIsVolt) then
    Exit;
  if not TryParseVoltText((Sender as TEdit).Text, lVolt) then
    Exit;
  RecorderMc201BalanceSignedFromVolt(lVolt, lLo, lHi);
  lLos[0] := fDacLo1; lLos[1] := fDacLo2; lLos[2] := fDacLo3; lLos[3] := fDacLo4;
  lHis[0] := fDacHi1; lHis[1] := fDacHi2; lHis[2] := fDacHi3; lHis[3] := fDacHi4;
  fUpdating := True;
  try
    lLos[lChannel].Text := IntToStr(lLo);
    lHis[lChannel].Text := IntToStr(lHi);
    { Нормализуем отображение вольт под фактически выбранные Lo/Hi. }
    SetChannelVoltEdit(lChannel, lLo, lHi);
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderMc201SlotSettingsDialog.ShowDacEdits;
var
  lRanges: array[0..3] of TComboBox;
  I, lRange: Integer;
begin
  lRanges[0] := fRange1; lRanges[1] := fRange2;
  lRanges[2] := fRange3; lRanges[3] := fRange4;
  for I := 0 to 3 do
  begin
    lRange := EnsureRange(lRanges[I].ItemIndex, 0, 5);
    fLastRange[I] := lRange;
    SetChannelDacEdits(I, fDacCodes[I, lRange]);
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

function TRecorderMc201SlotSettingsDialog.TryParseSignedDac(
  const AText: string; out ASigned: Integer): Boolean;
var
  lText: string;
begin
  ASigned := 0;
  lText := Trim(AText);
  if lText = '' then
  begin
    Result := True;
    Exit;
  end;
  Result := TryStrToInt(lText, ASigned);
  if Result then
    Result := (ASigned >= -128) and (ASigned <= 127);
end;

function TRecorderMc201SlotSettingsDialog.TryReadChannelDac(AChannel: Integer;
  out ACode: Word; AShowErrors: Boolean): Boolean;
var
  lLos: array[0..3] of TEdit;
  lHis: array[0..3] of TEdit;
  lLo, lHi: Integer;
begin
  Result := False;
  ACode := $8080;
  lLos[0] := fDacLo1; lLos[1] := fDacLo2; lLos[2] := fDacLo3; lLos[3] := fDacLo4;
  lHis[0] := fDacHi1; lHis[1] := fDacHi2; lHis[2] := fDacHi3; lHis[3] := fDacHi4;
  if not TryParseSignedDac(lLos[AChannel].Text, lLo) then
  begin
    if AShowErrors then
      MessageDlg('Свойства MC-201',
        Format('Канал %d, грубый ЦАП: нужно целое -128..+127 (сейчас "%s").',
          [AChannel + 1, lLos[AChannel].Text]), mtWarning, [mbOK], 0);
    Exit;
  end;
  if not TryParseSignedDac(lHis[AChannel].Text, lHi) then
  begin
    if AShowErrors then
      MessageDlg('Свойства MC-201',
        Format('Канал %d, тонкий ЦАП: нужно целое -128..+127 (сейчас "%s").',
          [AChannel + 1, lHis[AChannel].Text]), mtWarning, [mbOK], 0);
    Exit;
  end;
  ACode := RecorderMc201BalancePackWord(lLo, lHi);
  Result := True;
end;

function TRecorderMc201SlotSettingsDialog.CommitDacEdits(
  AShowErrors: Boolean): Boolean;
var
  lRanges: array[0..3] of TComboBox;
  I, lRange: Integer;
  lCode: Word;
begin
  Result := False;
  lRanges[0] := fRange1; lRanges[1] := fRange2;
  lRanges[2] := fRange3; lRanges[3] := fRange4;
  for I := 0 to 3 do
  begin
    if not TryReadChannelDac(I, lCode, AShowErrors) then
      Exit;
    lRange := EnsureRange(lRanges[I].ItemIndex, 0, 5);
    fDacCodes[I, lRange] := lCode;
    fLastRange[I] := lRange;
    SetChannelDacEdits(I, lCode);
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
  fDacLo1.OnChange := @DacCodeChange;
  fDacLo2.OnChange := @DacCodeChange;
  fDacLo3.OnChange := @DacCodeChange;
  fDacLo4.OnChange := @DacCodeChange;
  fDacHi1.OnChange := @DacCodeChange;
  fDacHi2.OnChange := @DacCodeChange;
  fDacHi3.OnChange := @DacCodeChange;
  fDacHi4.OnChange := @DacCodeChange;
  fDacLo1.OnExit := @DacCodeChange;
  fDacLo2.OnExit := @DacCodeChange;
  fDacLo3.OnExit := @DacCodeChange;
  fDacLo4.OnExit := @DacCodeChange;
  fDacHi1.OnExit := @DacCodeChange;
  fDacHi2.OnExit := @DacCodeChange;
  fDacHi3.OnExit := @DacCodeChange;
  fDacHi4.OnExit := @DacCodeChange;
  fDacVolt1.OnChange := @DacVoltChange;
  fDacVolt2.OnChange := @DacVoltChange;
  fDacVolt3.OnChange := @DacVoltChange;
  fDacVolt4.OnChange := @DacVoltChange;
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
  lChannel: Integer;
  lCode: Word;
  lNewRange: Integer;
begin
  if fUpdating then
    Exit;
  lChannel := ChannelIndexOfRangeCombo(Sender as TComboBox);
  if lChannel < 0 then
    Exit;
  { Сохраняем правку в код предыдущего диапазона, затем показываем код нового. }
  if TryReadChannelDac(lChannel, lCode, False) then
    fDacCodes[lChannel, EnsureRange(fLastRange[lChannel], 0, 5)] := lCode;
  lNewRange := EnsureRange((Sender as TComboBox).ItemIndex, 0, 5);
  fLastRange[lChannel] := lNewRange;
  SetChannelDacEdits(lChannel, fDacCodes[lChannel, lNewRange]);
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
  const AModuleCaption: string; var AConfigText: string;
  const ASourceId: string = '';
  ADataSources: TRecorderDataSourceManager = nil;
  ARegistry: TRecorderTagRegistry = nil): Boolean;
var
  lDialog: TRecorderMc201SlotSettingsDialog;
  lSerial: string;
  lSlot: Integer;
  lVersion: string;
  lDevice: IRecorderDevice;
begin
  Result := TryParseRecorderMc201ModuleCaption(AModuleCaption, lSlot,
    lSerial, lVersion);
  if not Result then Exit;
  { Подтянуть коды ЦАП, которые реально уйдут в SEND_BALANCE / ApplySaved. }
  if ASourceId <> '' then
  begin
    lDevice := RecorderHardwareFindLiveDevice(ASourceId);
    if (lDevice <> nil) and (lDevice.GetNativeObject is TRecorderMcbusDevice) then
      TRecorderMcbusDevice(lDevice.GetNativeObject).MergeSlotBalanceDacsIntoConfigText(
        AConfigText, lSlot);
  end;
  lDialog := TRecorderMc201SlotSettingsDialog.Create(AOwner);
  try
    lDialog.Caption := Format('Слот %d — свойства MC-201', [lSlot]);
    lDialog.fSerialEdit.Text := lSerial;
    lDialog.fVersionEdit.Text := lVersion;
    lDialog.fSlot := lSlot;
    lDialog.fSourceId := ASourceId;
    lDialog.fDataSources := ADataSources;
    lDialog.fRegistry := ARegistry;
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
