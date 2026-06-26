#!/usr/bin/env python3
"""Extract MIC-140 submodules from uRecorderMic140DataSource.pas."""
from pathlib import Path

ROOT = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140")
SRC = ROOT / "uRecorderMic140DataSource.pas"


def slice_lines(lines, start, end):
    return "\n".join(lines[start - 1 : end]) + "\n"


def main():
    text = SRC.read_text(encoding="utf-8")
    lines = text.splitlines()

    flash_header = """unit uRecorderMic140Flash;

{
  MIC-140 flash/PZU: mi118tar layout, tare records, read from device.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderMic140LegacyProtocol,
  uRecorderMic140FlashConstants, uRecorderMic140MebiusConstants,
  uRecorderMic140StreamHelpers;

type
"""
    flash_types = slice_lines(lines, 2112, 2142)
    flash_body = slice_lines(lines, 459, 481) + slice_lines(lines, 2144, 2614)
    flash_footer = """
implementation

uses
  Math, StrUtils,
  uSharedFileLogger;

"""
    (ROOT / "uRecorderMic140Flash.pas").write_text(
        flash_header + flash_types + flash_body + flash_footer + "end.\n",
        encoding="utf-8",
    )

    calibr_header = """unit uRecorderMic140Calibration;

{
  MIC-140 hardware calibration: CSV paths, registry, download from flash.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderMic140Flash;

function RecorderMic140CalibrRootDir: string;
function RecorderMic140RangeCalibrDirName(ARangeIndex: Integer): string;
function RecorderMic140HardwareCalibrCsvPath(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
function RecorderMic140TInHardwareCalibrExportCsvPath(ADeviceSerial,
  ATinChannelNumber: Integer): string;
function RecorderMic140LoadCalibrationFromCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderMic140SaveCalibrationToCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderMic140MakeHardwareCalibrationName(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
function RecorderMic140UpsertHardwareCalibration(ARegistry: TRecorderTagRegistry;
  const AName: string; ASource: TRecorderCalibration): TRecorderCalibration;
function RecorderMic140MakeTInHardwareCalibrationName(ADeviceSerial,
  ATInFileNumber: Integer): string;
function RecorderMic140TInHardwareCalibrCsvPath(ADeviceSerial, ATInListIndex,
  ADevSubRev: Integer): string;
function RecorderMic140EnsureTInHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ADeviceSerial, ATInListIndex,
  ADevSubRev: Integer; out ACalibrationName: string): Boolean;
function RecorderMic140ResolveDeviceSerialForTag(const ATag: TRecorderTag;
  ADeviceSerial: Integer): Integer;
function RecorderMic140EnsureHardwareCalibrationInRegistry(
  ARegistry: TRecorderTagRegistry; ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer; out ACalibrationName: string): Boolean;
function RecorderMic140LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ADeviceSerial: Integer; AEnableOnTag: Boolean = True): Boolean;
procedure RecorderMic140ApplyHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial: Integer);
procedure RecorderMic140ApplyTInHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial, ADevSubRev: Integer; const ATemperatureTagNames: TStrings);
function RecorderMic140DownloadHardwareCalibrationFromDevice(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AErrorMessage: string): Boolean;

implementation

uses
  Math, StrUtils, LazFileUtils,
  uRecorderMeraPaths, uRecorderMic140Utils, uRecorderMic140StreamTypes,
  uRecorderMic140LegacyConstants, uRecorderMic140Thermocouple,
  uRecorderMic140StreamHelpers, uRecorderMic140LegacyProtocol;

const
  CMic140RangeCalibrDirNames: array[0..CMic140RangeCount - 1] of string =
    ('06_100mV', '07_50mV', '8_25mV');
  CMic140HardwareCalibrSubDir = 'hardware' + PathDelim + 'MIC140' + PathDelim;
  CMic140TInCalibrSubDirName = 'TIn';

"""
    calibr_helpers = slice_lines(lines, 1296, 1318)
    calibr_body = (
        slice_lines(lines, 1320, 1460)
        + slice_lines(lines, 1462, 1526)
        + slice_lines(lines, 1933, 2109)
        + slice_lines(lines, 2341, 2364)
        + slice_lines(lines, 2616, 2855)
    )
    calibr_globals = """
var
  g_Mic140TInCalibrFailedKeys: TStringList;
  g_Mic140TInCalibrMissLogged: TStringList;

initialization
  g_Mic140TInCalibrFailedKeys := TStringList.Create;
  g_Mic140TInCalibrFailedKeys.Sorted := True;
  g_Mic140TInCalibrFailedKeys.Duplicates := dupIgnore;
  g_Mic140TInCalibrMissLogged := TStringList.Create;
  g_Mic140TInCalibrMissLogged.Sorted := True;
  g_Mic140TInCalibrMissLogged.Duplicates := dupIgnore;

finalization
  FreeAndNil(g_Mic140TInCalibrMissLogged);
  FreeAndNil(g_Mic140TInCalibrFailedKeys);

"""
    (ROOT / "uRecorderMic140Calibration.pas").write_text(
        calibr_header + calibr_helpers + calibr_body + calibr_globals + "end.\n",
        encoding="utf-8",
    )

    mebius_header = """unit uRecorderMic140MebiusTypes;

{
  Mebius MIC-140 device settings blob (ProgramDeviceBin).
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uRecorderMebiusTcpProtocol, uRecorderMic140StreamTypes,
  uRecorderMic140LegacyTiming, uRecorderMic140MebiusConstants,
  uRecorderMic140Thermocouple, uRecorderMic140LegacyConstants;

type
"""
    mebius_types = slice_lines(lines, 329, 370)
    mebius_procs = """
function Mic140GenerateSessionId: LongWord;
function Mic140BuildSettings(AChannelCount: Integer;
  APollFrequencyHz: Double): TRecorderByteArray;
"""
    mebius_funcs = slice_lines(lines, 3240, 3301)
    mebius_footer = """
implementation

"""
    (ROOT / "uRecorderMic140MebiusTypes.pas").write_text(
        mebius_header + mebius_types + mebius_procs + mebius_funcs + mebius_footer + "end.\n",
        encoding="utf-8",
    )

    chdesc_header = """unit uRecorderMic140LegacyChannelDesc;

{
  Legacy scan channel descriptor packing (ME048 / MIC140 reg bits).
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uRecorderMic140LegacyProtocol, uRecorderMic140StreamTypes;

"""
    chdesc_body = slice_lines(lines, 947, 1174)
    chdesc_footer = """
implementation

end.
"""
    (ROOT / "uRecorderMic140LegacyChannelDesc.pas").write_text(
        chdesc_header + chdesc_body + chdesc_footer,
        encoding="utf-8",
    )

    remove_ranges = [
        (5197, 5207),
        (3240, 3301),
        (2616, 2855),
        (2341, 2364),
        (2111, 2614),
        (1933, 2109),
        (1462, 1526),
        (1320, 1460),
        (1296, 1318),
        (947, 1174),
        (459, 481),
        (327, 371),
        (323, 325),
    ]
    new_lines = lines[:]
    for start, end in sorted(remove_ranges, reverse=True):
        del new_lines[start - 1 : end]

    out = "\n".join(new_lines) + "\n"

    impl_uses_old = "  uRecorderMic140DeviceConfig"
    impl_uses_new = (
        "  uRecorderMic140DeviceConfig, uRecorderMic140Flash,\n"
        "  uRecorderMic140Calibration, uRecorderMic140MebiusTypes,\n"
        "  uRecorderMic140LegacyChannelDesc"
    )
    out = out.replace(impl_uses_old, impl_uses_new, 1)

    iface_uses = "  uRecorderMic140LegacyTiming,\n  uRecorderTags;"
    iface_uses_new = (
        "  uRecorderMic140LegacyTiming, uRecorderMic140Calibration,\n"
        "  uRecorderMic140StreamTypes, uRecorderTags;"
    )
    out = out.replace(iface_uses, iface_uses_new, 1)

    # Drop moved calibr declarations from interface (re-exported via Calibration in uses)
    decls_to_remove = [
        "function RecorderMic140CalibrRootDir: string;\n",
        "function RecorderMic140RangeCalibrDirName(ARangeIndex: Integer): string;\n",
        "function RecorderMic140HardwareCalibrCsvPath(ADeviceSerial, ARangeIndex,\n"
        "  AChannelNumber: Integer): string;\n",
        "function RecorderMic140TInHardwareCalibrExportCsvPath(ADeviceSerial,\n"
        "  ATinChannelNumber: Integer): string;\n",
        "function RecorderMic140LoadCalibrationFromCsv(const AFileName: string;\n"
        "  ACalibration: TRecorderCalibration): Boolean;\n",
        "function RecorderMic140QueryDeviceSerial(const AHost: string; APort: Word;\n",
    ]
    # Keep QueryDeviceSerial - only remove calibr block before it
    calibr_iface_start = "function RecorderMic140CalibrRootDir: string;"
    calibr_iface_end = "  ADeviceSerial: Integer; AEnableOnTag: Boolean = True): Boolean;\n"
    idx_start = out.find(calibr_iface_start)
    idx_end = out.find(
        "procedure RecorderMic140ApplyTInHardwareCalibrations(\n"
        "  ARegistry: TRecorderTagRegistry; const ASourceId: string;\n"
        "  ADeviceSerial, ADevSubRev: Integer; const ATemperatureTagNames: TStrings);\n"
    )
    if idx_start >= 0 and idx_end >= 0:
        idx_end = out.find("\n", idx_end + len(
            "procedure RecorderMic140ApplyTInHardwareCalibrations(\n"
            "  ARegistry: TRecorderTagRegistry; const ASourceId: string;\n"
            "  ADeviceSerial, ADevSubRev: Integer; const ATemperatureTagNames: TStrings);"
        ))
        out = out[:idx_start] + out[idx_end + 1 :]

    out = out.replace(
        "  MIC140DefaultChannelCount = 48;\n"
        "  MIC140MaxChannelCount = 96;\n"
        "  MIC140TemperatureChannelCount = 3;\n"
        "  MIC140DefaultPollFrequencyHz = 100.0;\n"
        "  MIC140DefaultDiscoverySubnet = '192.168.14.';\n",
        "  MIC140DefaultDiscoverySubnet = '192.168.14.';\n",
        1,
    )

    out = out.replace(
        "  CMic140Range100mV = 0;\n"
        "  CMic140RangeCount = 3;\n",
        "",
        1,
    )

    out = out.replace(
        "  CMic140ChannelCommutIn = 0;\n"
        "  CMic140ChannelCommutGround = 1;\n",
        "",
        1,
    )

    SRC.write_text(out, encoding="utf-8")
    print("Done. New datasource lines:", out.count("\n"))


if __name__ == "__main__":
    main()
