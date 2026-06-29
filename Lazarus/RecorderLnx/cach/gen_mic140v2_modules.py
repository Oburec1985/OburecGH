#!/usr/bin/env python3
"""Generate isolated MIC140v2 modules from MIC140 legacy sources."""
from pathlib import Path

ROOT = Path(r'D:\works\OburecGH\Lazarus\RecorderLnx\Device')
MIC = ROOT / 'MIC140'
V2 = ROOT / 'MIC140v2'
DEV = ROOT

RENAME = [
    ('unit uRecorderMic140LegacyProtocol;', 'unit uRecorderMic140v2Protocol;'),
    ('ERecorderMic140LegacyProtocol', 'EMic140v2Protocol'),
    ('TRecorderMic140LegacyWordArray', 'TMic140v2WordBuf'),
    ('TRecorderMic140LegacyByteArray', 'TMic140v2ByteBuf'),
    ('TRecorderMic140LegacyFirmware', 'TMic140v2Firmware'),
    ('TRecorderMic140LegacyScanBlock', 'TMic140v2ScanPacket'),
    ('TRecorderMic140LegacyClient', 'TMic140v2Tcp'),
    ('MIC140_LEGACY_CMD_', 'MIC140v2_CMD_'),
    ('RecorderMic140HardwareCalibrSerialFromFirmware', 'Mic140v2HardwareCalibrSerial'),
    ('RecorderMic140DeviceSerialFromFirmware', 'Mic140v2DeviceSerialFromFirmware'),
    ('RecorderMic140DisplaySerialFromFirmware', 'Mic140v2DisplaySerialFromFirmware'),
    ('RecorderMic140HostLastOctet', 'Mic140v2HostLastOctet'),
    ('RecorderMic140FirmwareVersionText', 'Mic140v2FirmwareVersionText'),
    ('RecorderMic140DevRevFromFirmware', 'Mic140v2DevRevFromFirmware'),
    ('RecorderMic140DevSubRevFromFirmware', 'Mic140v2DevSubRevFromFirmware'),
    ('unit uRecorderMic140LegacyConstants;', 'unit uRecorderMic140v2Consts;'),
    ('unit uRecorderMic140LegacyTiming;', 'unit uRecorderMic140v2Timing;'),
    ('Mic140LegacyTimingForFrequency', 'Mic140v2TimingForFrequency'),
    ('RecorderMic140NormalizeFrequency', 'Mic140v2NormalizeFrequency'),
    ('RecorderMic140FrequencyCount', 'Mic140v2FrequencyCount'),
    ('RecorderMic140Frequency(', 'Mic140v2Frequency('),
    ('RecorderMic140TimingForFrequency', 'Mic140v2UiTimingForFrequency'),
    ('Mic140LegacyPeriodDecayToSport', 'Mic140v2PeriodDecayToSport'),
    ('Mic140LegacyPeriodAverageToSport', 'Mic140v2PeriodAverageToSport'),
    ('Mic140LegacySportToPeriodDecay', 'Mic140v2SportToPeriodDecay'),
    ('Mic140LegacySportToPeriodAverage', 'Mic140v2SportToPeriodAverage'),
    ('Mic140LegacyCheckPeriodDecay', 'Mic140v2CheckPeriodDecay'),
    ('Mic140LegacyCheckCountAver', 'Mic140v2CheckCountAver'),
    ('unit uRecorderMic140LegacyChannelDesc;', 'unit uRecorderMic140v2ChanDesc;'),
    ('Mic140LegacyPackMic140RegDesc', 'Mic140v2PackMic140RegDesc'),
    ('Mic140LegacyPackMe04848', 'Mic140v2PackMe04848'),
    ('Mic140LegacyPackMe04896', 'Mic140v2PackMe04896'),
    ('Mic140LegacyMe048ForPhysicalChannel', 'Mic140v2Me048ForPhysicalChannel'),
    ('Mic140LegacyMe048Code48', 'Mic140v2Me048Code48'),
    ('Mic140LegacyLevel0Code', 'Mic140v2Level0Code'),
    ('Mic140LegacyTInCode48', 'Mic140v2TInCode48'),
    ('Mic140LegacyTInDesc48', 'Mic140v2TInDesc48'),
    ('Mic140LegacyWordAt', 'Mic140v2WordAt'),
]

WIRE = '''unit uRecorderMic140WireTypes;

{
  Общие wire-типы MIC-140 (кадр скана, прошивка, TIn).
  Контракт IMic140Device; v1 legacy и v2 используют один layout.
}

{$mode objfpc}{$H+}

interface

const
  CMic140LegacyMaxScanDataWords = 102;
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;
  CMic140LegacyBiosNumBuffIdx = 8;

type
  TRecorderMic140LegacyFirmware = record
    Signature: Word;
    MdpType: Word;
    DevType: Word;
    DevRevNo: Word;
    DevSerNo: Word;
    CCType: Word;
    CCSerNo: Word;
    EepromManufactId: Word;
    EepromDeviceId: Word;
    BiosFunction: Word;
    BiosVersion: Word;
  end;

  TMic140LegacyRawBlock = record
    Header: array[0..9] of Word;
    Data: array[0..CMic140LegacyMaxScanDataWords - 1] of Word;
    DataWordCount: Word;
    FirstSampleIndex: Int64;
    ReadSerial: Int64;
  end;

  TRecorderMic140Timing = record
    FrequencyHz: Double;
    GroundCommutationUs: Double;
    ChannelCommutationUs: Double;
    AveragePeriodUs: Double;
    AverageSampleCount: Word;
    AveragePower: Word;
    LegacyGroundDelaySport: Word;
    LegacyChannelDelaySport: Word;
    LegacyAverageDelaySport: Word;
  end;

  TMic140AuxTemperatureBlock = record
    ChannelCount: Integer;
    SampleCount: Integer;
    Values: array of array of Double;
    Valid: array of array of Boolean;
  end;

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);

implementation

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);
begin
  ABlock.ChannelCount := 0;
  ABlock.SampleCount := 0;
  SetLength(ABlock.Values, 0);
  SetLength(ABlock.Valid, 0);
end;

end.
'''

STREAM_TYPES = '''unit uRecorderMic140StreamTypes;

{
  Совместимость: типы перенесены в uRecorderMic140WireTypes.
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140WireTypes;

const
  CMic140LegacyMaxScanDataWords = uRecorderMic140WireTypes.CMic140LegacyMaxScanDataWords;
  MIC140DefaultChannelCount = uRecorderMic140WireTypes.MIC140DefaultChannelCount;
  MIC140MaxChannelCount = uRecorderMic140WireTypes.MIC140MaxChannelCount;
  MIC140TemperatureChannelCount = uRecorderMic140WireTypes.MIC140TemperatureChannelCount;
  MIC140DefaultPollFrequencyHz = uRecorderMic140WireTypes.MIC140DefaultPollFrequencyHz;

type
  TMic140LegacyRawBlock = uRecorderMic140WireTypes.TMic140LegacyRawBlock;
  TRecorderMic140Timing = uRecorderMic140WireTypes.TRecorderMic140Timing;
  TMic140AuxTemperatureBlock = uRecorderMic140WireTypes.TMic140AuxTemperatureBlock;

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);

implementation

procedure ClearMic140AuxTemperatureBlock(var ABlock: TMic140AuxTemperatureBlock);
begin
  uRecorderMic140WireTypes.ClearMic140AuxTemperatureBlock(ABlock);
end;

end.
'''


def xform(text: str) -> str:
    for a, b in RENAME:
        text = text.replace(a, b)
    return text


def copy_unit(src_name: str, dst_name: str, header: str, uses_fix: dict[str, str]):
    src = MIC / src_name
    text = src.read_text(encoding='utf-8')
    text = xform(text)
    if header:
        lines = text.splitlines()
        for i, line in enumerate(lines):
            if line.startswith('{'):
                continue
            if line.startswith('unit '):
                # insert header after unit line + mode
                insert_at = i + 1
                while insert_at < len(lines) and lines[insert_at].strip().startswith('{$'):
                    insert_at += 1
                lines.insert(insert_at, '')
                lines.insert(insert_at + 1, header)
                text = '\n'.join(lines)
                break
    for old, new in uses_fix.items():
        text = text.replace(old, new)
    (V2 / dst_name).write_text(text, encoding='utf-8')
    print('wrote', V2 / dst_name)


def main():
    (DEV / 'uRecorderMic140WireTypes.pas').write_text(WIRE, encoding='utf-8')
    (MIC / 'uRecorderMic140StreamTypes.pas').write_text(STREAM_TYPES, encoding='utf-8')
    print('wrote wire types')

    copy_unit(
        'uRecorderMic140LegacyConstants.pas',
        'uRecorderMic140v2Consts.pas',
        '{ BIOS scan: команды, адреса DM, пороги перезапуска. }',
        {},
    )
    copy_unit(
        'uRecorderMic140LegacyProtocol.pas',
        'uRecorderMic140v2Protocol.pas',
        '{ TCP + MDP, CC Ethernet BIOS. Только v2. }',
        {
            '  uRecorderMic140LegacyProtocol, uRecorderMic140StreamTypes':
                '  uRecorderMic140WireTypes',
            'uses\n  Classes, SysUtils, SyncObjs, ssockets;':
                'uses\n  Classes, SysUtils, SyncObjs, ssockets,\n  uRecorderMic140WireTypes;',
        },
    )
    # fix protocol - remove duplicate firmware type, use wire types
    proto = (V2 / 'uRecorderMic140v2Protocol.pas').read_text(encoding='utf-8')
    start = proto.find('  TMic140v2Firmware = record')
    end = proto.find('  end;', start) + len('  end;')
    proto = proto[:start] + proto[end:]
    proto = proto.replace(
        'type\n  EMic140v2Protocol',
        'type\n  TMic140v2Firmware = uRecorderMic140WireTypes.TRecorderMic140LegacyFirmware;\n\n  EMic140v2Protocol',
    )
    (V2 / 'uRecorderMic140v2Protocol.pas').write_text(proto, encoding='utf-8')

    copy_unit(
        'uRecorderMic140LegacyTiming.pas',
        'uRecorderMic140v2Timing.pas',
        '{ Таймер MC114 16 МГц, SPORT-задержки для дескрипторов. }',
        {
            'uRecorderMic140StreamTypes': 'uRecorderMic140WireTypes',
        },
    )
    copy_unit(
        'uRecorderMic140LegacyChannelDesc.pas',
        'uRecorderMic140v2ChanDesc.pas',
        '{ ME048 / MIC140 reg — коды каналов для APPENDSCAN. }',
        {
            'uRecorderMic140LegacyProtocol, uRecorderMic140StreamTypes':
                'uRecorderMic140WireTypes',
            'TRecorderMic140LegacyWordArray': 'TMic140v2WordBuf',
            'function Mic140v2WordAt(const AWords: TMic140v2WordBuf;':
                'function Mic140v2WordAt(const AWords: array of Word;',
        },
    )
    # chan desc uses word array from protocol - add uses v2Protocol
    cd = (V2 / 'uRecorderMic140v2ChanDesc.pas').read_text(encoding='utf-8')
    cd = cd.replace(
        'uses\n  SysUtils,\n  uRecorderMic140WireTypes;',
        'uses\n  SysUtils,\n  uRecorderMic140WireTypes, uRecorderMic140v2Protocol;',
    )
    cd = cd.replace(
        'function Mic140v2WordAt(const AWords: array of Word;',
        'function Mic140v2WordAt(const AWords: TMic140v2WordBuf;',
    )
    (V2 / 'uRecorderMic140v2ChanDesc.pas').write_text(cd, encoding='utf-8')

    print('done')


if __name__ == '__main__':
    main()
