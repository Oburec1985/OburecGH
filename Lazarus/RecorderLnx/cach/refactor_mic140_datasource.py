#!/usr/bin/env python3
"""Apply MIC-140 datasource slimming: double buffer + remove extracted helpers."""
from pathlib import Path

PATH = Path(r'D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140\uRecorderMic140DataSource.pas')

def drop_between(lines, start_pred, end_pred, include_end=False):
    out = []
    skipping = False
    for line in lines:
        if not skipping and start_pred(line):
            skipping = True
            continue
        if skipping and end_pred(line):
            if include_end:
                out.append(line)
            skipping = False
            continue
        if not skipping:
            out.append(line)
    return out

def main():
    text = PATH.read_text(encoding='utf-8')
    lines = text.splitlines(keepends=True)

    text = text.replace(
        '  uRecorderMic140LegacyProtocol, uRecorderMic140Utils,\n  uRecorderTags;',
        '  uRecorderMic140LegacyProtocol, uRecorderMic140Utils,\n'
        '  uRecorderMic140StreamTypes, uRecorderMic140DoubleBuffer,\n'
        '  uRecorderMic140ScanConfig, uRecorderMic140StreamFsm,\n'
        '  uRecorderMic140StreamHelpers, uRecorderMic140LegacyTiming,\n'
        '  uRecorderTags;')

    text = text.replace(
        '  MIC140DefaultDiscoverySubnet = ''192.168.14.'';\n'
        '  CMic140LegacyMaxScanDataWords = 102;\n'
        '  CMic140RawRingSlotCount = 32;\n',
        '  MIC140DefaultDiscoverySubnet = ''192.168.14.'';\n')

    old_types = '''  TMic140LegacyRawBlock = record
    Header: array[0..9] of Word;
    Data: array[0..CMic140LegacyMaxScanDataWords - 1] of Word;
    DataWordCount: Word;
    FirstSampleIndex: Int64;
    ReadSerial: Int64;
  end;

  TMic140RawBlockRing = class(TObject)
  private
    fSlots: array[0..CMic140RawRingSlotCount - 1] of TMic140LegacyRawBlock;
    fHead: Integer;
    fCount: Integer;
    fLock: TCriticalSection;
    fDropped: Int64;
    fLastDropLogTick: QWord;
    fSourceId: string;
  public
    constructor Create(const ASourceId: string);
    destructor Destroy; override;
    function Enqueue(const ARaw: TMic140LegacyRawBlock; out ADepth: Integer;
      out ADroppedOldest: Boolean; out ADroppedRaw: TMic140LegacyRawBlock): Boolean;
    function Dequeue(out ARaw: TMic140LegacyRawBlock): Boolean;
    function PendingCount: Integer;
    function DroppedCount: Int64;
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

  TRecorderMic140Device'''
    text = text.replace(old_types, '  TRecorderMic140Device')

    text = text.replace(
        '    fRawRing: TMic140RawBlockRing;',
        '    fRawBuffer: TMic140RawDoubleBuffer;\n'
        '    fStreamFsm: TMic140StreamFsm;\n'
        '    fScanConfig: TRecorderMic140ScanConfig;')

    if 'procedure SyncScanConfig;' not in text:
        text = text.replace(
            '    procedure ProcessAndPublishBlock(const ABlock: TRecorderDeviceSampleBlock);',
            '    procedure ProcessAndPublishBlock(const ABlock: TRecorderDeviceSampleBlock);\n'
            '    procedure SyncScanConfig;')

    for decl in [
        'function RecorderMic140FrequencyCount: Integer;\n',
        'function RecorderMic140Frequency(AIndex: Integer): Double;\n',
        'function RecorderMic140NormalizeFrequency(AFrequencyHz: Double): Double;\n',
        'function RecorderMic140TimingForFrequency(AFrequencyHz: Double): TRecorderMic140Timing;\n',
    ]:
        text = text.replace(decl, '')

    lines = text.splitlines(keepends=True)
    lines = drop_between(lines,
        lambda l: l.strip().startswith('procedure Mic140LogWarning'),
        lambda l: l.strip().startswith('function TRecorderMic140Device.LegacyNoteReadSincePrevMs'))
    lines = drop_between(lines,
        lambda l: l.strip().startswith('function RecorderMic140FrequencyCount'),
        lambda l: l.strip().startswith('procedure RecorderMic140ApplySourceFrequency'),
        include_end=True)
    lines = drop_between(lines,
        lambda l: l.strip() == '{ TMic140RawBlockRing }',
        lambda l: l.strip() == '{ TMic140BlockPublishThread }')

    text = ''.join(lines)
    text = text.replace('fRawRing := TMic140RawBlockRing.Create(ASourceId);',
        'fRawBuffer := TMic140RawDoubleBuffer.Create;\n'
        '  fStreamFsm := TMic140StreamFsm.Create;\n'
        '  fScanConfig := TRecorderMic140ScanConfig.Create(AChannelCount, APollFrequencyHz, AUpdateTimeMs);')
    text = text.replace('  fRawRing.Free;',
        '  fScanConfig.Free;\n  fStreamFsm.Free;\n  fRawBuffer.Free;')

    # SyncScanConfig body if missing
    if 'procedure TRecorderMic140DataSource.SyncScanConfig;' not in text:
        insert = '''
procedure TRecorderMic140DataSource.SyncScanConfig;
var
  lChannels: Integer;
begin
  lChannels := MIC140DefaultChannelCount;
  if fMic140Device <> nil then
    lChannels := fMic140Device.ChannelCount;
  if fScanConfig = nil then
    fScanConfig := TRecorderMic140ScanConfig.Create(lChannels, fPollFrequencyHz, UpdateTimeMs)
  else
  begin
    fScanConfig.ChannelCount := lChannels;
    fScanConfig.PollFrequencyHz := fPollFrequencyHz;
    fScanConfig.UpdateTimeMs := UpdateTimeMs;
  end;
end;

'''
        text = text.replace('procedure TRecorderMic140DataSource.Start;',
            insert + 'procedure TRecorderMic140DataSource.Start;')

    text = text.replace(
        'procedure TRecorderMic140DataSource.Start;\nbegin\n  inherited Start;',
        'procedure TRecorderMic140DataSource.Start;\nbegin\n  inherited Start;\n  SyncScanConfig;')
    text = text.replace(
        '  fPollFrequencyHz := RecorderMic140NormalizeFrequency(lFreq);\n  if fMic140Device <> nil then',
        '  fPollFrequencyHz := RecorderMic140NormalizeFrequency(lFreq);\n  SyncScanConfig;\n  if fMic140Device <> nil then')
    text = text.replace(
        '  inherited RequestStop;\n  if fMic140Device <> nil then',
        '  inherited RequestStop;\n  if fStreamFsm <> nil then\n    fStreamFsm.SetPhase(mspStopping);\n  if fMic140Device <> nil then')
    text = text.replace(
        'procedure TRecorderMic140DataSource.Stop;\nvar\n  lRingDropped: Int64;\nbegin\n  StopLegacyReadThread;',
        'procedure TRecorderMic140DataSource.Stop;\nvar\n  lBufferDropped: Int64;\nbegin\n  if fStreamFsm <> nil then\n    fStreamFsm.SetPhase(mspStopping);\n  StopLegacyReadThread;')
    text = text.replace('lRingDropped := fRawRing.DroppedCount', 'lBufferDropped := fRawBuffer.DroppedCount')
    text = text.replace('if fRawRing <> nil then', 'if fRawBuffer <> nil then')
    text = text.replace('lRingDropped', 'lBufferDropped')
    text = text.replace('ringDropped=%d', 'bufferDropped=%d')
    text = text.replace(
        '  inherited Stop;\n  fHardwarePrepared := False;',
        '  inherited Stop;\n  fHardwarePrepared := False;\n  if fStreamFsm <> nil then\n    fStreamFsm.SetPhase(mspOffline);')

    text = text.replace('while fOwner.fRawRing.PendingCount > 0 do',
        'while fOwner.fRawBuffer.HasPending do')
    text = text.replace('if not fOwner.fRawRing.Dequeue(lRaw) then',
        'if not fOwner.fStreamFsm.ShouldPublish then\n    begin\n      fWakeEvent.WaitFor(fOwner.fScanConfig.IdleWaitMs);\n      Continue;\n    end;\n    if not fOwner.fRawBuffer.TryTake(lRaw) then')
    text = text.replace('while fOwner.fRawRing.Dequeue(lRaw) do',
        'while fOwner.fRawBuffer.TryTake(lRaw) do')

    # Read thread execute block - replace whole procedure body key section
    old_read = '''    if fOwner.ShouldStop or (fOwner.fDevice = nil) or
       (fOwner.fDevice.State <> rdsStarted) then
    begin
      fWakeEvent.WaitFor(1000);
      Continue;
    end;
    lPacingMs := fOwner.UpdateTimeMs;
    if lPacingMs = 0 then
      lPacingMs := 200;
    // One pacing wait per poll cycle — do not read faster than DataUpdateMs.
    fWakeEvent.WaitFor(lPacingMs);
    if Terminated then
      Break;
    lTimeoutMs := Mic140LegacyReadThreadTimeoutMs(fOwner.fPollFrequencyHz,
      fOwner.UpdateTimeMs);'''
    new_read = '''    if Terminated or not fOwner.fStreamFsm.ShouldRead or (fOwner.fDevice = nil) or
       (fOwner.fDevice.State <> rdsStarted) then
    begin
      fWakeEvent.WaitFor(fOwner.fScanConfig.IdleWaitMs);
      Continue;
    end;
    fWakeEvent.WaitFor(fOwner.fScanConfig.DataUpdateMs);
    if Terminated then
      Break;
    lTimeoutMs := fOwner.fScanConfig.ReadTimeoutMs;'''
    text = text.replace(old_read, new_read)
    text = text.replace('(lConsecutiveFails >= CMic140LegacyReadStallRestartAfter)',
        '(lConsecutiveFails >= fOwner.fScanConfig.ReadStallRestartAfter)')
    text = text.replace('lConsecutiveFails = CMic140LegacyReadTimeoutWarnAfter',
        'lConsecutiveFails = fOwner.fScanConfig.ReadTimeoutWarnAfter')
    text = text.replace(
        '        fOwner.PublishDiagnostics(CMic140StatusError,\n          ''read exception: '' + E.Message, True);',
        '        fOwner.fStreamFsm.SetPhase(mspError, E.Message);\n        fOwner.PublishDiagnostics(CMic140StatusError,\n          ''read exception: '' + E.Message, True);')

    text = text.replace(
        '  if fDevice.State = rdsStarted then\n  begin\n    EnsureBlockPublishThread;',
        '  if fDevice.State = rdsStarted then\n  begin\n    fStreamFsm.SetPhase(mspAcquiring);\n    EnsureBlockPublishThread;')

    # EnqueueLegacyRawBlock
    old_enq = '''  if fRawRing = nil then
  begin
    ProcessLegacyRawBlock(ARaw);
    Exit;
  end;
  fRawRing.Enqueue(ARaw, lDepth, lDropped, lDroppedRaw);
  lNow := GetTickCount64;
  if lDropped and (lNow - fLastRingOverloadLogTick >= CMic140RawRingDropLogIntervalMs) then
  begin
    fLastRingOverloadLogTick := lNow;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 raw ring overflow: dropped readSerial=%d num_buff=%d (depth=%d slots=%d)',
      [SourceId, lDroppedRaw.ReadSerial,
       lDroppedRaw.Header[CMic140LegacyBiosNumBuffIdx], lDepth,
       CMic140RawRingSlotCount]));
  end
  else
  if (lDepth > 3) and (lNow - fLastRingOverloadLogTick >= CMic140RawRingDropLogIntervalMs) then
  begin
    fLastRingOverloadLogTick := lNow;
    RecorderDebugLog(Format(
      '[DataSource:%s] MIC-140 raw ring depth=%d readSerial=%d num_buff=%d',
      [SourceId, lDepth, ARaw.ReadSerial, ARaw.Header[CMic140LegacyBiosNumBuffIdx]]));
  end;'''
    new_enq = '''  if fRawBuffer = nil then
  begin
    ProcessLegacyRawBlock(ARaw);
    Exit;
  end;
  lDropped := fRawBuffer.Publish(ARaw);
  lNow := GetTickCount64;
  if lDropped and (lNow - fLastRingOverloadLogTick >= CMic140RawBufferDropLogIntervalMs) then
  begin
    fLastRingOverloadLogTick := lNow;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 raw buffer overflow: readSerial=%d num_buff=%d lag=%d',
      [SourceId, ARaw.ReadSerial, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       fRawBuffer.PendingLag]));
  end;'''
    text = text.replace(old_enq, new_enq)
    text = text.replace('fRawRing.PendingCount', 'fRawBuffer.PendingLag')
    text = text.replace('CMic140LegacyBiosNumBuffIdx', 'CMic140LegacyBiosNumBuffIdx')  # noop keep protocol const
    text = text.replace(
        'Mic140LegacyReadThreadTimeoutMs(fPollFrequencyHz, UpdateTimeMs)',
        'fScanConfig.ReadTimeoutMs')

    # Fix enqueue var section
    text = text.replace(
        '  lDepth: Integer;\n  lDropped: Boolean;\n  lDroppedRaw: TMic140LegacyRawBlock;',
        '  lDropped: Boolean;')

    PATH.write_text(text, encoding='utf-8', newline='\n')
    n = text.count('\n')
    print(f'Wrote {n} lines')
    if n < 4500:
        raise SystemExit('ERROR: file too short, abort')

if __name__ == '__main__':
    main()
