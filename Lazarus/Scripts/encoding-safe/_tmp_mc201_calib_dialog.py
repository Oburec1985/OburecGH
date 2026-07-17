# -*- coding: utf-8 -*-
"""Wire MC-201 slot dialog calibrate button + fields."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

PATH = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MCbus\UI\uRecorderMc201SlotSettingsDialog.pas"
)


def main() -> None:
    t = read_pas(PATH)

    old_uses = """uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ButtonPanel, Dialogs,
  uRecorderDataSources;"""
    new_uses = """uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ButtonPanel, Dialogs,
  uRecorderDataSources, uRecorderTags;"""
    if old_uses not in t:
        raise SystemExit("uses not found")
    t = t.replace(old_uses, new_uses, 1)

    old_fields = """    fRevisionCombo: TComboBox;
    fSerialEdit: TEdit;
    fSubmoduleCombo: TComboBox;
    fVersionEdit: TEdit;
  private
    fUpdating: Boolean;
    fDacCodes: array[0..3, 0..5] of Word;
    fLastRange: array[0..3] of Integer;"""
    new_fields = """    fRevisionCombo: TComboBox;
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
    fRegistry: TRecorderTagRegistry;"""
    if old_fields not in t:
        raise SystemExit("fields not found")
    t = t.replace(old_fields, new_fields, 1)

    old_priv = """    procedure LoadSettings(const AConfigText: string; ASlot: Integer);
    procedure SaveSettings(var AConfigText: string; ASlot: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  end;"""
    new_priv = """    procedure LoadSettings(const AConfigText: string; ASlot: Integer);
    procedure SaveSettings(var AConfigText: string; ASlot: Integer);
    procedure CalibrateClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;"""
    if old_priv not in t:
        raise SystemExit("priv methods not found")
    t = t.replace(old_priv, new_priv, 1)

    old_show = """function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;
  const AModuleCaption: string; var AConfigText: string;
  const ASourceId: string = '';
  ADataSources: TRecorderDataSourceManager = nil): Boolean;"""
    new_show = """function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;
  const AModuleCaption: string; var AConfigText: string;
  const ASourceId: string = '';
  ADataSources: TRecorderDataSourceManager = nil;
  ARegistry: TRecorderTagRegistry = nil): Boolean;"""
    if old_show not in t:
        raise SystemExit("show decl not found")
    t = t.replace(old_show, new_show, 1)

    old_impl_uses = """uses
  Math, StrUtils, uMc201ProtocolTypes, uRecorderMcbusDevice,
  uRecorderHardwareLiveDevices, uRecorderDeviceInterfaces;"""
    new_impl_uses = """uses
  Math, StrUtils, uMc201ProtocolTypes, uRecorderMcbusDevice,
  uRecorderMc201Calibration, uRecorderHardwareLiveDevices,
  uRecorderDeviceInterfaces;"""
    if old_impl_uses not in t:
        raise SystemExit("impl uses not found")
    t = t.replace(old_impl_uses, new_impl_uses, 1)

    old_ctor = """constructor TRecorderMc201SlotSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ResetDacCodes;
  FillChoices;
end;"""
    new_ctor = """constructor TRecorderMc201SlotSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fSlot := 0;
  fSourceId := '';
  fDataSources := nil;
  fRegistry := nil;
  ResetDacCodes;
  FillChoices;
  fCalibrateBtn.OnClick := @CalibrateClick;
end;"""
    if old_ctor not in t:
        raise SystemExit("ctor not found")
    t = t.replace(old_ctor, new_ctor, 1)

    # Insert CalibrateClick before ShowRecorderMc201SlotSettingsDialog impl
    calib_fn = r"""
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

"""
    if "procedure TRecorderMc201SlotSettingsDialog.CalibrateClick" not in t:
        marker = "function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;"
        idx = t.find(marker)
        if idx < 0:
            raise SystemExit("show impl not found")
        t = t[:idx] + calib_fn + t[idx:]

    old_show_impl = """function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;
  const AModuleCaption: string; var AConfigText: string;
  const ASourceId: string = '';
  ADataSources: TRecorderDataSourceManager = nil): Boolean;
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
    lDialog.LoadSettings(AConfigText, lSlot);
    lDialog.fButtonPanel.OKButton.ModalResult := mrNone;
    lDialog.fButtonPanel.OKButton.OnClick := @lDialog.OkClick;
    Result := lDialog.ShowModal = mrOk;
    if Result then lDialog.SaveSettings(AConfigText, lSlot);
  finally
    lDialog.Free;
  end;
end;"""
    new_show_impl = """function ShowRecorderMc201SlotSettingsDialog(AOwner: TComponent;
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
end;"""
    if old_show_impl not in t:
        raise SystemExit("show impl body not found")
    t = t.replace(old_show_impl, new_show_impl, 1)

    write_utf8_crlf(PATH, t)
    print("patched dialog", PATH)


if __name__ == "__main__":
    main()
