#!/usr/bin/env python3
"""Extract TRecorderMic140Device from datasource by verified fixed line ranges."""
from pathlib import Path

ROOT = Path(r'D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140')
SRC = ROOT / 'uRecorderMic140DataSource.pas'
CORE = ROOT / 'uRecorderMic140DeviceCore.pas'

lines = SRC.read_text(encoding='utf-8').splitlines(keepends=True)

TYPE_START, TYPE_END = 61, 161
IMPL_RANGES = [(313, 397), (644, 786), (818, 1049), (1461, 2466)]

iface = ''.join(lines[TYPE_START - 1:TYPE_END])
iface = iface.replace(
    'TRecorderMic140Device = class(TInterfacedObject, IRecorderDevice)',
    'TRecorderMic140DeviceCore = class(TInterfacedObject, IMic140Device)',
)
iface = iface.replace(
    'function LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;',
    'function LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;\n'
    '    function UsesRawRing: Boolean; virtual;\n'
    '    function ChannelCount: Integer;',
)
iface = iface.replace('    property ChannelCount: Integer read fChannelCount;\n', '')

impl_body = ''
for s, e in IMPL_RANGES:
    chunk = ''.join(lines[s - 1:e])
    chunk = chunk.replace('TRecorderMic140Device', 'TRecorderMic140DeviceCore')
    impl_body += chunk + '\n'

impl_body += '''
function TRecorderMic140DeviceCore.UsesRawRing: Boolean;
begin
  Result := False;
end;

function TRecorderMic140DeviceCore.ChannelCount: Integer;
begin
  Result := fChannelCount;
end;
'''

core = f'''unit uRecorderMic140DeviceCore;

{{
  Общая реализация драйвера MIC-140 (TCP, MDP, скан, чтение кадров).
  v1 и v2 — тонкие наследники; переопределяют только UsesRawRing.
}}

{{$mode objfpc}}{{$H+}}

interface

uses
  Classes, SysUtils, Variants, Forms, SyncObjs,
  uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140LegacyProtocol, uRecorderMic140Utils,
  uRecorderMic140StreamTypes, uRecorderMic140LegacyConstants,
  uRecorderMic140LegacyTiming,
  uRecorderMic140DeviceApi, uRecorderTags;

const
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;

type
{iface}

implementation

uses
  Math, StrUtils, LazFileUtils, Controls, Dialogs, LCLIntf,
  uSharedFileLogger, uRecorderMeraPaths, uRecorderDebugLog,
  uRecorderMeraSdbThermocouples, uRecorderSdbStore,
  uRecorderMic140FlashConstants,
  uRecorderMic140Thermocouple, uRecorderMic140MebiusConstants,
  uRecorderMic140DeviceConfig, uRecorderMic140Flash,
  uRecorderMic140MebiusTypes,
  uRecorderMic140LegacyChannelDesc, uRecorderMic140StreamHelpers,
  uRecorderMic140Calibration
  {{$IFDEF MSWINDOWS}}, WinSock2{{$ELSE}}, BaseUnix, CTypes, Sockets{{$ENDIF}};

const
  CMic140ReadTimeoutMinMs = 1500;
  CMic140IoCtlTypeCallCommand = 2;
  CMic140IoCtlCmdSetControllerParams =
    (CMic140IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic140BalanceMinSamples = 30;
  CMic140BalanceDiscardSamples = 10;
  CMic140BalanceSampleFraction = 0.3;
  CMic140Range5mV = 2;

{impl_body}
end.
'''

CORE.write_text(core, encoding='utf-8')

remove = sorted([(TYPE_START - 1, TYPE_END)] + [(s - 1, e) for s, e in IMPL_RANGES], reverse=True)
new_lines = lines[:]
for s, e in remove:
    del new_lines[s:e]

out = []
prev_blank = False
for l in new_lines:
    blank = l.strip() == ''
    if blank and prev_blank:
        continue
    out.append(l)
    prev_blank = blank

SRC.write_text(''.join(out), encoding='utf-8')
print('Core written, datasource lines:', len(out))
