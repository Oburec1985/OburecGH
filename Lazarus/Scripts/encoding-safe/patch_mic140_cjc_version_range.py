#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix MIC-140 version parsing, CJC display mapping, default ADC range."""
from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

LEGACY = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140\uRecorderMic140LegacyProtocol.pas"
)
DATASOURCE = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140\uRecorderMic140DataSource.pas"
)
SETTINGS = Path(
    r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140\UI\uRecorderMic140SettingsDialog.pas"
)


def patch_legacy(text: str) -> str:
    if "RecorderMic140DevRevFromFirmware" not in text:
        insert_before = "function RecorderMic140FirmwareVersionText("
        helpers = """
function RecorderMic140DevRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;
function RecorderMic140DevSubRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;

"""
        text = text.replace(insert_before, helpers + insert_before)

    if "RecorderMic140DevSubRevFromFirmware" in text.split("implementation")[0]:
        pass
    else:
        text = text.replace(
            "function RecorderMic140FirmwareVersionText(\n"
            "  const AFirmware: TRecorderMic140LegacyFirmware): string;\n\nimplementation",
            "function RecorderMic140FirmwareVersionText(\n"
            "  const AFirmware: TRecorderMic140LegacyFirmware): string;\n"
            "function RecorderMic140DevRevFromFirmware(\n"
            "  const AFirmware: TRecorderMic140LegacyFirmware): Word;\n"
            "function RecorderMic140DevSubRevFromFirmware(\n"
            "  const AFirmware: TRecorderMic140LegacyFirmware): Word;\n\nimplementation",
        )

    text = re.sub(
        r"function RecorderMic140FirmwareVersionText\([\s\S]*?end;\n\nend\.",
        """function RecorderMic140DevRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;
begin
  Result := AFirmware.DevRevNo and $FF;
end;

function RecorderMic140DevSubRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;
begin
  Result := (AFirmware.DevRevNo shr 8) and $FF;
end;

function RecorderMic140FirmwareVersionText(
  const AFirmware: TRecorderMic140LegacyFirmware): string;
begin
  Result := Format('%u.%u.%u.%u', [
    RecorderMic140DevRevFromFirmware(AFirmware),
    RecorderMic140DevSubRevFromFirmware(AFirmware),
    AFirmware.BiosVersion,
    AFirmware.BiosFunction]);
end;

end.""",
        text,
        count=1,
    )
    return text


def patch_datasource(text: str) -> str:
    text = text.replace(
        "  CMic140Range5mV = 2;\n  CMic140RangeCount = 3;",
        "  CMic140Range100mV = 0;\n  CMic140Range5mV = 2;\n  CMic140RangeCount = 3;",
    )
    if "CMic140Mic140SubRev1" not in text:
        text = text.replace(
            "  CMic140DefaultCjcIndex48: array[0..47] of Integer =",
            """  CMic140Mic140SubRev1 = 1;
  CMic140TInNum: array[0..11] of Integer =
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
  CMic140TInNumSubRev1: array[0..11] of Integer =
    (4, 3, 2, 1, 0, 5, 6, 7, 8, 9, 10, 11);
  CMic140DefaultCjcIndex48: array[0..47] of Integer =""",
        )

    text = text.replace(
        "function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;\n"
        "  out ADeviceSerial: Integer; out AVersionText: string): Boolean;",
        "function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;\n"
        "  out ADeviceSerial: Integer; out AVersionText: string;\n"
        "  out ADevSubRev: Integer): Boolean;",
    )
    text = text.replace(
        "function RecorderMic140DefaultCjcChannel(AChannelIndex: Integer): Integer;",
        "function RecorderMic140DefaultCjcChannel(AChannelIndex: Integer;\n"
        "  ADevSubRev: Integer): Integer;",
    )

    text = re.sub(
        r"function RecorderMic140QueryDeviceInfo\([\s\S]*?end;\n\nfunction RecorderMic140DefaultCjcChannel",
        """function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;
  out ADeviceSerial: Integer; out AVersionText: string;
  out ADevSubRev: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ADeviceSerial := 0;
  AVersionText := '';
  ADevSubRev := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ADeviceSerial := RecorderMic140DeviceSerialFromFirmware(lFirmware);
      AVersionText := RecorderMic140FirmwareVersionText(lFirmware);
      ADevSubRev := RecorderMic140DevSubRevFromFirmware(lFirmware);
      Result := (ADeviceSerial > 0) or (AVersionText <> '');
    end;
  finally
    lClient.Free;
  end;
end;

function Mic140TInDisplayNumber(ATInListIndex, ADevSubRev: Integer): Integer;
begin
  if (ATInListIndex < 0) or (ATInListIndex > High(CMic140TInNum)) then
    Exit(0);
  if ADevSubRev = CMic140Mic140SubRev1 then
    Result := CMic140TInNumSubRev1[ATInListIndex] + 1
  else
    Result := CMic140TInNum[ATInListIndex] + 1;
end;

function RecorderMic140DefaultCjcChannel""",
        text,
        count=1,
    )

    text = re.sub(
        r"function RecorderMic140DefaultCjcChannel\([\s\S]*?end;\n\nfunction RecorderMic140FormatAdcRangeMv",
        """function RecorderMic140DefaultCjcChannel(AChannelIndex: Integer;
  ADevSubRev: Integer): Integer;
var
  lIdx: Integer;
begin
  lIdx := Mic140DefaultCjcIndex(AChannelIndex);
  if lIdx < 0 then
    Result := 0
  else
    Result := Mic140TInDisplayNumber(lIdx, ADevSubRev);
end;

function RecorderMic140FormatAdcRangeMv""",
        text,
        count=1,
    )

    text = text.replace(
        "    lIdx := CMic140Range5mV;\n  Result := Format('%.1f...%.1f', [",
        "    lIdx := CMic140Range100mV;\n  Result := Format('%.1f...%.1f', [",
    )
    text = text.replace(
        "    Result := CMic140RangeCalibrDirNames[CMic140Range5mV];",
        "    Result := CMic140RangeCalibrDirNames[CMic140Range100mV];",
    )
    text = text.replace(
        "    lRangeIndex := CMic140Range5mV;",
        "    lRangeIndex := CMic140Range100mV;",
        2,
    )
    text = text.replace(
        "    lSettings.Channels[I].MeasRangeIndex := CMic140Range5mV;",
        "    lSettings.Channels[I].MeasRangeIndex := CMic140Range100mV;",
    )
    return text


def patch_settings(text: str) -> str:
    if "fDevSubRev: Integer;" not in text:
        text = text.replace(
            "    fDeviceSerial: Integer;\n    procedure BuildUi;",
            "    fDeviceSerial: Integer;\n    fDevSubRev: Integer;\n    procedure BuildUi;",
        )
    text = text.replace(
        "  fDeviceSerial := 0;\n  BuildUi;",
        "  fDeviceSerial := 0;\n  fDevSubRev := CMic140Mic140SubRev1;\n  BuildUi;",
    )
    text = text.replace(
        "    Result := IntToStr(RecorderMic140DefaultCjcChannel(AChannelIndex));",
        "    Result := IntToStr(RecorderMic140DefaultCjcChannel(AChannelIndex, fDevSubRev));",
    )

    text = re.sub(
        r"function TRecorderMic140SettingsDialog\.ChannelRangeIndex\([\s\S]*?end;",
        """function TRecorderMic140SettingsDialog.ChannelRangeIndex(
  AChannelNumber: Integer): Integer;
begin
  Result := CMic140Range100mV;
  if (AChannelNumber < 1) or (AChannelNumber > MIC140DefaultChannelCount) then
    Result := CMic140Range100mV;
end;""",
        text,
        count=1,
    )

    text = re.sub(
        r"procedure TRecorderMic140SettingsDialog\.QueryDeviceInfo;[\s\S]*?end;\n\nprocedure TRecorderMic140SettingsDialog\.FillGrid",
        """procedure TRecorderMic140SettingsDialog.QueryDeviceInfo;
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
      FillGrid(ReadChannelCount, nil);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TRecorderMic140SettingsDialog.FillGrid""",
        text,
        count=1,
    )

    # Layout: wider version field, aligned rows, anchor buttons
    text = text.replace("  lTop.Height := 168;", "  lTop.Height := 176;")
    text = text.replace("  fSerialEdit.Width := 72;", "  fSerialEdit.Width := 80;")
    text = text.replace("  fVersionEdit.Width := 96;", "  fVersionEdit.Width := 120;")
    text = text.replace("  fVersionEdit.Left := 268;", "  fVersionEdit.Left := 276;")
    text = text.replace("    Left := 210;\n    Top := 12;\n    Caption := 'Версия';",
                        "    Left := 218;\n    Top := 12;\n    Caption := 'Версия';")
    text = text.replace("  fHostEdit.Width := 128;", "  fHostEdit.Width := 140;")
    text = text.replace("  fPortEdit.Left := 226;", "  fPortEdit.Left := 238;")
    text = text.replace("    Left := 188;\n    Top := 44;\n    Caption := 'Port';",
                        "    Left := 200;\n    Top := 44;\n    Caption := 'Port';")
    text = text.replace("  fChannelCountCombo.Left := 366;", "  fChannelCountCombo.Left := 378;")
    text = text.replace("    Left := 300;\n    Top := 44;\n    Caption := 'Каналов';",
                        "    Left := 312;\n    Top := 44;\n    Caption := 'Каналов';")
    text = text.replace("  fFrequencyEdit.Left := 482;", "  fFrequencyEdit.Left := 494;")
    text = text.replace("    Left := 454;\n    Top := 44;\n    Caption := 'Гц';",
                        "    Left := 466;\n    Top := 44;\n    Caption := 'Гц';")
    text = text.replace("  lButton.Caption := 'Автопоиск';", "  lButton.Caption := 'Автопоиск';\n  lButton.Anchors := [akTop, akRight];")
    text = text.replace(
        "  lButton.Caption := 'Проверка связи';",
        "  lButton.Caption := 'Проверка связи';\n  lButton.Anchors := [akTop, akRight];",
    )
    text = text.replace("  lButton.Left := 590;", "  lButton.Left := 600;")
    text = text.replace("  lButton.Left := 724;", "  lButton.Left := 734;")

    text = text.replace("  fDefaultCorrectorCheck.Left := 200;", "  fDefaultCorrectorCheck.Left := 210;")
    text = text.replace("  fDefaultCorrectorCheck.Top := 78;", "  fDefaultCorrectorCheck.Top := 82;")
    text = text.replace("  fThermoCompCheck.Top := 78;", "  fThermoCompCheck.Top := 82;")
    text = text.replace("    Left := 370;\n    Top := 80;\n    Caption := 'КХС';",
                        "    Left := 384;\n    Top := 84;\n    Caption := 'КХС';")
    text = text.replace("  fCorrectorCombo.Left := 410;", "  fCorrectorCombo.Left := 424;")
    text = text.replace("  fCorrectorCombo.Top := 74;", "  fCorrectorCombo.Top := 78;")
    text = text.replace("    Left := 500;\n    Top := 80;\n    Caption := 'Значение';",
                        "    Left := 514;\n    Top := 84;\n    Caption := 'Значение';")
    text = text.replace("  fOutputModeCombo.Left := 566;", "  fOutputModeCombo.Left := 580;")
    text = text.replace("  fOutputModeCombo.Top := 74;", "  fOutputModeCombo.Top := 78;")
    text = text.replace("  fTimingLabel.Top := 112;", "  fTimingLabel.Top := 120;")
    text = text.replace("  fTimingLabel.Width := 880;", "  fTimingLabel.Width := 896;\n  fTimingLabel.Anchors := [akLeft, akTop, akRight];")

    return text


def main() -> int:
    for path, patcher in (
        (LEGACY, patch_legacy),
        (DATASOURCE, patch_datasource),
        (SETTINGS, patch_settings),
    ):
        original = read_pas(path)
        updated = patcher(original)
        if updated == original:
            print(f"WARN: no changes in {path.name}")
        else:
            write_utf8_crlf(path, updated)
            print(f"OK: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
