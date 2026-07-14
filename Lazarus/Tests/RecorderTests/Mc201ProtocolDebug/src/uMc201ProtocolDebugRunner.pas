unit uMc201ProtocolDebugRunner;

{
  Console runner for MC-201 protocol debugging.

  The runner probes a controller, reads BIOS information and scans module flash
  slots without creating RecorderLnx devices or programming hardware.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

function RunMc201ProtocolDebug(const AExeName: string): Integer;

implementation

uses
  Classes, SysUtils, uMc032Device, uMc201LegacyMdpClient, uMc201ProtocolTypes;

type
  TMc201Options = record
    Host: string;
    Port: Word;
    TimeoutMs: Cardinal;
    MaxSlots: Word;
    AcceptanceMs: Cardinal;
    UpdateMs: Cardinal;
    PlayDiagnosticMs: Cardinal;
    RunAcceptance: Boolean;
    RunPlayDiagnostic: Boolean;
    ConnectAttempts: Integer;
    ConnectRetryMs: Cardinal;
  end;

  TMc201PlayStats = class
  private
    fFlags: array[0..CMc201MaxModuleChannels - 1] of Word;
    fMessageCount: Int64;
    fMinValue: array[0..CMc201MaxModuleChannels - 1] of Integer;
    fMaxValue: array[0..CMc201MaxModuleChannels - 1] of Integer;
    fSumValue: array[0..CMc201MaxModuleChannels - 1] of Int64;
    fSampleCount: array[0..CMc201MaxModuleChannels - 1] of Int64;
    fSlot: Word;
    function FormatPacketWords(const APacket: TMc032DataPacket): string;
    function WordToSigned(AValue: Word): Integer;
  public
    procedure ConfigureFirstModule(const AProgramInfo: TMc201ModuleProgramInfoArray);
    procedure OnData(Sender: TObject; const APacket: TMc032DataPacket);
    procedure OnProgress(Sender: TObject; const AText: string);
    procedure LogSummary;
    property MessageCount: Int64 read fMessageCount;
  end;

var
  g_Log: TStringList;

procedure LogLine(const AText: string);
begin
  Writeln(AText);
  if g_Log <> nil then
    g_Log.Add(AText);
end;

procedure PrintUsage(const AExeName: string);
begin
  LogLine('Usage: ' + ExtractFileName(AExeName) +
    ' --cli [--host=192.169.12.87] [--port=4000] [--timeout-ms=1200] [--slots=4]');
  LogLine('       ' + ExtractFileName(AExeName) +
    ' --cli --acceptance-ms=5000 [--update-ms=200] [--connect-attempts=5]');
  LogLine('       ' + ExtractFileName(AExeName) +
    ' --cli --play-diagnostic-ms=5000');
  LogLine('Without --cli the application starts the GUI.');
end;

function TryParamValue(const APrefix: string; out AValue: string): Boolean;
var
  I: Integer;
  lParam: string;
begin
  Result := False;
  AValue := '';
  for I := 1 to ParamCount do
  begin
    lParam := ParamStr(I);
    if Pos(APrefix, lParam) = 1 then
    begin
      AValue := Copy(lParam, Length(APrefix) + 1, MaxInt);
      Exit(True);
    end;
  end;
end;

function LoadOptions(out AOptions: TMc201Options): Boolean;
var
  lValue: string;
  lInt: Integer;
begin
  AOptions.Host := CMc201DefaultHost;
  AOptions.Port := CMc201DefaultPort;
  AOptions.TimeoutMs := CMc201DefaultTimeoutMs;
  AOptions.MaxSlots := CMc201DefaultMaxSlots;
  AOptions.AcceptanceMs := CMc201DefaultAcceptanceMs;
  AOptions.PlayDiagnosticMs := CMc201DefaultAcceptanceMs;
  AOptions.UpdateMs := CMc201DefaultUpdateMs;
  AOptions.RunAcceptance := False;
  AOptions.RunPlayDiagnostic := False;
  AOptions.ConnectAttempts := 5;
  AOptions.ConnectRetryMs := 1000;
  if TryParamValue('--host=', lValue) and (Trim(lValue) <> '') then
    AOptions.Host := Trim(lValue);
  if TryParamValue('--port=', lValue) and TryStrToInt(lValue, lInt) and
    (lInt > 0) and (lInt <= High(Word)) then
    AOptions.Port := Word(lInt);
  if TryParamValue('--timeout-ms=', lValue) and TryStrToInt(lValue, lInt) and
    (lInt > 0) then
    AOptions.TimeoutMs := Cardinal(lInt);
  if TryParamValue('--slots=', lValue) and TryStrToInt(lValue, lInt) and
    (lInt > 0) and (lInt <= High(Word)) then
    AOptions.MaxSlots := Word(lInt);
  if TryParamValue('--acceptance-ms=', lValue) and TryStrToInt(lValue, lInt) and
    (lInt > 0) then
  begin
    AOptions.AcceptanceMs := Cardinal(lInt);
    AOptions.RunAcceptance := True;
  end;
  if TryParamValue('--play-diagnostic-ms=', lValue) and
    TryStrToInt(lValue, lInt) and (lInt > 0) then
  begin
    AOptions.PlayDiagnosticMs := Cardinal(lInt);
    AOptions.RunPlayDiagnostic := True;
  end;
  if TryParamValue('--update-ms=', lValue) and TryStrToInt(lValue, lInt) and
    (lInt > 0) then
    AOptions.UpdateMs := Cardinal(lInt);
  if TryParamValue('--connect-attempts=', lValue) and TryStrToInt(lValue, lInt) and
    (lInt > 0) then
    AOptions.ConnectAttempts := lInt;
  if TryParamValue('--connect-retry-ms=', lValue) and TryStrToInt(lValue, lInt) and
    (lInt >= 0) then
    AOptions.ConnectRetryMs := Cardinal(lInt);
  Result := True;
end;

function TMc201PlayStats.WordToSigned(AValue: Word): Integer;
begin
  if AValue > $7FFF then
    Result := Integer(AValue) - $10000
  else
    Result := AValue;
end;

function TMc201PlayStats.FormatPacketWords(
  const APacket: TMc032DataPacket): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(APacket.Words) do
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + IntToHex(APacket.Words[I], 4);
  end;
end;

procedure TMc201PlayStats.ConfigureFirstModule(
  const AProgramInfo: TMc201ModuleProgramInfoArray);
var
  I: Integer;
begin
  fSlot := 0;
  for I := 0 to CMc201MaxModuleChannels - 1 do
  begin
    fFlags[I] := 0;
    fMinValue[I] := High(Integer);
    fMaxValue[I] := Low(Integer);
    fSumValue[I] := 0;
    fSampleCount[I] := 0;
  end;
  if Length(AProgramInfo) = 0 then
    Exit;
  fSlot := AProgramInfo[0].Slot;
  for I := 0 to CMc201MaxModuleChannels - 1 do
    fFlags[I] := AProgramInfo[0].FinalFlags[I];
end;

procedure TMc201PlayStats.OnData(Sender: TObject;
  const APacket: TMc032DataPacket);
var
  I: Integer;
  J: Integer;
  lChan: Word;
  lValue: Integer;
begin
  Inc(fMessageCount);
  if Length(APacket.Words) <= CMc201BiosMessageHeaderWords then
    Exit;
  if fMessageCount <= 8 then
    LogLine(Format(
      'PLAY header msg=%d type=%d size=%d scan=%d slot=%d chan=0x%s num=%d state=0x%s words=%d',
      [fMessageCount, APacket.Words[0], APacket.Words[1], APacket.Words[2],
       APacket.Words[3], IntToHex(APacket.Words[4], 4), APacket.Words[8],
       IntToHex(APacket.Words[9], 4), Length(APacket.Words)]));
  if fMessageCount = 1 then
    LogLine('PLAY first packet words=' + FormatPacketWords(APacket));
  if APacket.Words[3] <> fSlot then
    Exit;
  lChan := APacket.Words[4];
  for I := 0 to CMc201MaxModuleChannels - 1 do
    if fFlags[I] = lChan then
    begin
      for J := CMc201BiosMessageHeaderWords to High(APacket.Words) do
      begin
        lValue := WordToSigned(APacket.Words[J]);
        if lValue < fMinValue[I] then
          fMinValue[I] := lValue;
        if lValue > fMaxValue[I] then
          fMaxValue[I] := lValue;
        Inc(fSumValue[I], lValue);
        Inc(fSampleCount[I]);
      end;
      Break;
    end;
end;

procedure TMc201PlayStats.OnProgress(Sender: TObject; const AText: string);
begin
  if (Pos('RX ', AText) = 1) or (Pos('CMD_RESET', AText) = 1) then
    LogLine('play diagnostic: ' + AText);
end;

procedure TMc201PlayStats.LogSummary;
var
  I: Integer;
  lAvg: Double;
begin
  LogLine(Format('PLAY messages=%d firstSlot=%d flags=[0x%s 0x%s 0x%s 0x%s]',
    [fMessageCount, fSlot, IntToHex(fFlags[0], 4), IntToHex(fFlags[1], 4),
     IntToHex(fFlags[2], 4), IntToHex(fFlags[3], 4)]));
  for I := 0 to CMc201MaxModuleChannels - 1 do
  begin
    if fSampleCount[I] > 0 then
      lAvg := fSumValue[I] / fSampleCount[I]
    else
      lAvg := 0;
    LogLine(Format('PLAY slot=%d ch=%d samples=%d min=%d max=%d avg=%.1f',
      [fSlot + 1, I + 1, fSampleCount[I], fMinValue[I], fMaxValue[I], lAvg]));
  end;
end;

function ConnectWithRetry(AClient: TMc201LegacyMdpClient;
  const AOptions: TMc201Options; out AErrorMessage: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  AErrorMessage := '';
  for I := 1 to AOptions.ConnectAttempts do
  begin
    try
      LogLine(Format('connect attempt %d/%d to %s:%d timeout=%dms',
        [I, AOptions.ConnectAttempts, AOptions.Host, AOptions.Port,
         AOptions.TimeoutMs]));
      AClient.Connect;
      Exit(True);
    except
      on E: Exception do
      begin
        AErrorMessage := E.Message;
        LogLine('connect failed: ' + AErrorMessage);
        if I < AOptions.ConnectAttempts then
          Sleep(AOptions.ConnectRetryMs);
      end;
    end;
  end;
end;

function RunAcceptance(AClient: TMc201LegacyMdpClient;
  const AOptions: TMc201Options; out AErrorMessage: string): Boolean;
var
  lBlockCount: Integer;
  lExpectedBlocks: Integer;
  lPort: Word;
  lReply: TMc201WordArray;
  lStartTick: QWord;
  lWords: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  lBlockCount := 0;
  lExpectedBlocks := Round(AOptions.AcceptanceMs / AOptions.UpdateMs);
  if lExpectedBlocks <= 0 then
    lExpectedBlocks := 1;

  LogLine(Format('acceptance: duration=%dms update=%dms expectedBlocks=%d sampleRate=%dHz',
    [AOptions.AcceptanceMs, AOptions.UpdateMs, lExpectedBlocks,
     CMc201DefaultSampleRateHz]));

  if not AClient.CallCommand(CMc201CmdResetScanMain, nil, 0, lReply,
    AErrorMessage) then
  begin
    AErrorMessage := 'RESETSCANMAIN failed: ' + AErrorMessage;
    Exit;
  end;
  LogLine('acceptance: RESETSCANMAIN OK');

  if not AClient.CallCommand(CMc201CmdStartScanMain, nil, 0, lReply,
    AErrorMessage) then
  begin
    AErrorMessage := 'STARTSCANMAIN failed: ' + AErrorMessage;
    Exit;
  end;
  LogLine('acceptance: STARTSCANMAIN OK');

  lStartTick := GetTickCount64;
  try
    while GetTickCount64 - lStartTick < AOptions.AcceptanceMs do
    begin
      if AClient.ReadRawPacket(lPort, lWords) and
        (lPort <> CMc201MdpStreamCommand) then
      begin
        Inc(lBlockCount);
        LogLine(Format('RX block=%d stream=%d words=%d elapsedMs=%d',
          [lBlockCount, lPort, Length(lWords), GetTickCount64 - lStartTick]));
      end;
    end;
  finally
    if AClient.CallCommand(CMc201CmdStopScanMain, nil, 0, lReply,
      AErrorMessage) then
      LogLine('acceptance: STOPSCANMAIN OK')
    else
      LogLine('acceptance: STOPSCANMAIN failed: ' + AErrorMessage);
  end;

  LogLine(Format('acceptance summary: blocks=%d expected=%d updateMs=%d',
    [lBlockCount, lExpectedBlocks, AOptions.UpdateMs]));
  Result := lBlockCount = lExpectedBlocks;
  if Result then
    LogLine('RESULT Mc201Acceptance passed')
  else
    LogLine('RESULT Mc201Acceptance failed');
end;

function RunDeviceAcceptance(const AOptions: TMc201Options;
  out AErrorMessage: string): Boolean;
var
  I: Integer;
  lBlockCount: Integer;
  lConfig: TMc032Config;
  lDevice: TMc032Device;
  lExpectedBlocks: Integer;
  lFrameCount: Integer;
  lModules: TMc201SlotInfoArray;
  lNextUpdateTick: QWord;
  lPort: Word;
  lSizeList: string;
  lStartTick: QWord;
  lStopError: string;
  lWindowFrames: Integer;
  lWindowWords: Integer;
  lWords: TMc201WordArray;

  procedure FlushUpdateBlock;
  begin
    if lWindowFrames <= 0 then
      Exit;
    Inc(lBlockCount);
    LogLine(Format('RX updateBlock=%d frames=%d words=%d sizes=%s elapsedMs=%d',
      [lBlockCount, lWindowFrames, lWindowWords, lSizeList,
       GetTickCount64 - lStartTick]));
    lWindowFrames := 0;
    lWindowWords := 0;
    lSizeList := '';
  end;

  procedure AddFrameSize(ASize: Integer);
  begin
    if lWindowFrames <= 8 then
    begin
      if lSizeList <> '' then
        lSizeList := lSizeList + ',';
      lSizeList := lSizeList + IntToStr(ASize);
    end
    else if lWindowFrames = 9 then
      lSizeList := lSizeList + ',...';
  end;
begin
  Result := False;
  AErrorMessage := '';
  lBlockCount := 0;
  lFrameCount := 0;
  lExpectedBlocks := Round(AOptions.AcceptanceMs / AOptions.UpdateMs);
  if lExpectedBlocks <= 0 then
    lExpectedBlocks := 1;

  lDevice := TMc032Device.Create;
  try
    lDevice.Host := AOptions.Host;
    lDevice.Port := AOptions.Port;
    lDevice.TimeoutMs := AOptions.TimeoutMs;
    LogLine(Format('device acceptance: connect %s:%d timeout=%dms',
      [AOptions.Host, AOptions.Port, AOptions.TimeoutMs]));
    lDevice.Connect;
    LogLine('device acceptance: controller ' + Mc201FormatBios(lDevice.Bios));
    if not lDevice.SearchModules(AOptions.MaxSlots, lModules, AErrorMessage) then
    begin
      AErrorMessage := 'SearchModules failed: ' + AErrorMessage;
      Exit;
    end;
    LogLine(Format('device acceptance: modules=%d', [Length(lModules)]));

    FillChar(lConfig, SizeOf(lConfig), 0);
    lConfig.SampleRateHz := CMc201DefaultSampleRateHz;
    lConfig.MaxSlots := AOptions.MaxSlots;
    lConfig.ReadTimeoutMs := Word(AOptions.TimeoutMs);
    if not lDevice.Config(lConfig, AErrorMessage) then
    begin
      AErrorMessage := 'Config/program scan failed: ' + AErrorMessage;
      Exit;
    end;
    LogLine(Format('device acceptance: Config OK Fs=%dHz slots=%d',
      [lConfig.SampleRateHz, lConfig.MaxSlots]));
    for I := 0 to High(lDevice.ProgramInfo) do
      LogLine('device acceptance: PROGRAM ' +
        Mc201FormatProgramInfo(lDevice.ProgramInfo[I]));

    if not lDevice.StartRawScan(AErrorMessage) then
    begin
      AErrorMessage := 'STARTSCANMAIN failed: ' + AErrorMessage;
      Exit;
    end;
    LogLine('device acceptance: STARTSCANMAIN OK');

    lStartTick := GetTickCount64;
    lNextUpdateTick := lStartTick + AOptions.UpdateMs;
    lWindowFrames := 0;
    lWindowWords := 0;
    lSizeList := '';
    try
      while GetTickCount64 - lStartTick < AOptions.AcceptanceMs do
      begin
        while GetTickCount64 >= lNextUpdateTick do
        begin
          FlushUpdateBlock;
          Inc(lNextUpdateTick, AOptions.UpdateMs);
        end;
        if lDevice.ReadRawPacket(lPort, lWords) and
          (lPort <> CMc201MdpStreamCommand) then
        begin
          Inc(lFrameCount);
          Inc(lWindowFrames);
          Inc(lWindowWords, Length(lWords));
          AddFrameSize(Length(lWords));
        end;
      end;
      FlushUpdateBlock;
    finally
      if lDevice.Stop(lStopError) then
        LogLine('device acceptance: STOPSCANMAIN OK')
      else
        LogLine('device acceptance: STOPSCANMAIN failed: ' + lStopError);
    end;

    LogLine(Format('acceptance summary: updateBlocks=%d expected=%d rawFrames=%d updateMs=%d',
      [lBlockCount, lExpectedBlocks, lFrameCount, AOptions.UpdateMs]));
    Result := (lBlockCount = lExpectedBlocks) and (lFrameCount > 0);
    if Result then
      LogLine('RESULT Mc201Acceptance passed')
    else
      LogLine('RESULT Mc201Acceptance failed');
  except
    on E: Exception do
    begin
      AErrorMessage := E.Message;
      Result := False;
    end;
  end;
  lDevice.Free;
end;

function RunPlayDiagnostic(const AOptions: TMc201Options;
  out AErrorMessage: string): Boolean;
var
  lConfig: TMc032Config;
  lDevice: TMc032Device;
  lModules: TMc201SlotInfoArray;
  lStartTick: QWord;
  lStats: TMc201PlayStats;
  lExpectedMessages: Int64;
  lStopOk: Boolean;
  lStopError: string;

  function ConnectAndReadModules: Boolean;
  begin
    Result := False;
    LogLine(Format('play diagnostic: connect %s:%d timeout=%dms',
      [AOptions.Host, AOptions.Port, AOptions.TimeoutMs]));
    lDevice.Connect;
    LogLine('play diagnostic: controller ' + Mc201FormatBios(lDevice.Bios));
    if not lDevice.SearchModules(AOptions.MaxSlots, lModules, AErrorMessage) then
    begin
      AErrorMessage := 'SearchModules failed: ' + AErrorMessage;
      Exit;
    end;
    LogLine(Format('play diagnostic: modules=%d', [Length(lModules)]));
    Result := True;
  end;

  function ConfigWithResetRetry: Boolean;
  var
    lResetError: string;
  begin
    Result := lDevice.Config(lConfig, AErrorMessage);
    if Result then
      Exit;

    LogLine('play diagnostic: Config failed, reset and retry: ' + AErrorMessage);
    if lDevice.Reset(lResetError) then
      LogLine('play diagnostic: RESET OK')
    else
      LogLine('play diagnostic: RESET failed: ' + lResetError);
    lDevice.Disconnect;
    Sleep(1500);
    if not ConnectAndReadModules then
      Exit(False);
    Result := lDevice.Config(lConfig, AErrorMessage);
  end;
begin
  Result := False;
  AErrorMessage := '';
  lDevice := TMc032Device.Create;
  lStats := TMc201PlayStats.Create;
  try
    lDevice.Host := AOptions.Host;
    lDevice.Port := AOptions.Port;
    lDevice.TimeoutMs := AOptions.TimeoutMs;
    lDevice.OnProgress := @lStats.OnProgress;
    if not ConnectAndReadModules then
      Exit;

    FillChar(lConfig, SizeOf(lConfig), 0);
    lConfig.SampleRateHz := CMc201DefaultSampleRateHz;
    lConfig.MaxSlots := AOptions.MaxSlots;
    lConfig.ReadTimeoutMs := Word(AOptions.TimeoutMs);
    if not ConfigWithResetRetry then
    begin
      AErrorMessage := 'Config/program scan failed: ' + AErrorMessage;
      Exit;
    end;
    lStats.ConfigureFirstModule(lDevice.ProgramInfo);
    LogLine(Format('play diagnostic: Config OK Fs=%dHz slots=%d',
      [lConfig.SampleRateHz, lConfig.MaxSlots]));

    if not lDevice.Play(@lStats.OnData, AErrorMessage) then
    begin
      AErrorMessage := 'Play failed: ' + AErrorMessage;
      Exit;
    end;
    LogLine('play diagnostic: STARTSCANMAIN OK');
    lStartTick := GetTickCount64;
    lStopOk := False;
    try
      while GetTickCount64 - lStartTick < AOptions.PlayDiagnosticMs do
      begin
        CheckSynchronize(20);
        Sleep(1);
      end;
      CheckSynchronize(100);
    finally
      lStopOk := lDevice.Stop(lStopError);
      if lStopOk then
        LogLine('play diagnostic: STOPSCANMAIN OK')
      else
        LogLine('play diagnostic: STOPSCANMAIN failed: ' + lStopError);
    end;
    lStats.LogSummary;
    LogLine(Format('PLAY window-rate=%.1f messages/sec window=%.3f sec',
      [lStats.MessageCount / (AOptions.PlayDiagnosticMs / 1000.0),
       AOptions.PlayDiagnosticMs / 1000.0]));
    lExpectedMessages := AOptions.PlayDiagnosticMs div CMc201DefaultUpdateMs;
    if lExpectedMessages < 1 then
      lExpectedMessages := 1;
    LogLine(Format('PLAY expected-messages>=%d by %d ms update',
      [lExpectedMessages, CMc201DefaultUpdateMs]));
    Result := lStopOk and (lStats.MessageCount >= lExpectedMessages);
    if Result then
      LogLine('RESULT Mc201PlayDiagnostic passed')
    else
      LogLine('RESULT Mc201PlayDiagnostic failed');
  except
    on E: Exception do
    begin
      AErrorMessage := E.Message;
      Result := False;
    end;
  end;
  lStats.Free;
  lDevice.Free;
end;

function ReadSlotInfo(AClient: TMc201LegacyMdpClient; ASlot: Word;
  out AInfo: TMc201SlotInfo; out AErrorMessage: string): Boolean;
var
  lHi: Word;
  lLo: Word;
begin
  FillChar(AInfo, SizeOf(AInfo), 0);
  AInfo.Slot := ASlot;
  Result := AClient.ReadFlashWord(ASlot, CMc201FlashTypeOffset,
    AInfo.TypeId, AErrorMessage);
  if not Result then
    Exit;
  if (AInfo.TypeId = 0) or (AInfo.TypeId = $FFFF) then
    Exit(True);
  Result := AClient.ReadFlashWord(ASlot, CMc201FlashVersionOffset,
    AInfo.VersionCode, AErrorMessage);
  if not Result then
    Exit;
  lLo := 0;
  lHi := 0;
  if not AClient.ReadFlashWord(ASlot, CMc201FlashSerialLoOffset, lLo,
    AErrorMessage) then
    Exit(False);
  if not AClient.ReadFlashWord(ASlot, CMc201FlashSerialHiOffset, lHi,
    AErrorMessage) then
    Exit(False);
  AInfo.SerialLo := lLo;
  AInfo.SerialHi := lHi;
  AInfo.Serial := Word((lHi shl 8) or lLo);
  AInfo.IsMc201 := (AInfo.TypeId = CMc201FlashTypeId) and
    Mc201IsKnownVersionCode(AInfo.VersionCode);
  AInfo.IsMc201A := AInfo.IsMc201 and (AInfo.VersionCode = CMc201AVersionCode);
  Result := True;
end;

function RunMc201ProtocolDebug(const AExeName: string): Integer;
var
  I: Word;
  lBios: TMc201ControllerBios;
  lClient: TMc201LegacyMdpClient;
  lError: string;
  lInfo: TMc201SlotInfo;
  lMc201Count: Integer;
  lOptions: TMc201Options;
  lUsedCount: Integer;
  lLogPath: string;
begin
  Result := 1;
  lLogPath := ChangeFileExt(AExeName, '.log');
  g_Log := TStringList.Create;
  if (ParamCount > 0) and ((ParamStr(1) = '--help') or (ParamStr(1) = '-h')) then
  begin
    PrintUsage(AExeName);
    g_Log.SaveToFile(lLogPath);
    FreeAndNil(g_Log);
    Exit(0);
  end;
  try
    LoadOptions(lOptions);
    LogLine(Format('MC-201 protocol debug: %s:%d timeout=%dms slots=%d',
      [lOptions.Host, lOptions.Port, lOptions.TimeoutMs, lOptions.MaxSlots]));

    if lOptions.RunPlayDiagnostic then
    begin
      if RunPlayDiagnostic(lOptions, lError) then
        Result := 0
      else
      begin
        if lError <> '' then
          LogLine('ERROR play diagnostic: ' + lError);
        Result := 4;
      end;
      Exit;
    end;

    if lOptions.RunAcceptance then
    begin
      if RunDeviceAcceptance(lOptions, lError) then
        Result := 0
      else
      begin
        if lError <> '' then
          LogLine('ERROR acceptance: ' + lError);
        Result := 4;
      end;
      Exit;
    end;

    lClient := nil;
    try
      lClient := TMc201LegacyMdpClient.Create(lOptions.Host, lOptions.Port,
        lOptions.TimeoutMs);
      try
        if not ConnectWithRetry(lClient, lOptions, lError) then
        begin
          LogLine('ERROR connect failed: ' + lError);
          Result := 3;
          Exit;
        end;
        if not lClient.ReadControllerBios(lBios, lError) then
        begin
          LogLine('ERROR controller CMD_REPLY failed: ' + lError);
          Result := 2;
          Exit;
        end;
        LogLine('controller: ' + Mc201FormatBios(lBios));

        lUsedCount := 0;
        lMc201Count := 0;
        for I := 0 to lOptions.MaxSlots - 1 do
        begin
          if not ReadSlotInfo(lClient, I, lInfo, lError) then
          begin
            LogLine(Format('slot %d: read failed: %s', [I, lError]));
            Continue;
          end;
          if (lInfo.TypeId = 0) or (lInfo.TypeId = $FFFF) then
            Continue;
          Inc(lUsedCount);
          if lInfo.IsMc201 then
            Inc(lMc201Count);
          LogLine(Format('slot %d: type=%d version=%d serial=%d lo=%d hi=%d mc201=%s',
            [lInfo.Slot, lInfo.TypeId, lInfo.VersionCode, lInfo.Serial,
             lInfo.SerialLo, lInfo.SerialHi,
             BoolToStr(lInfo.IsMc201, True)]));
        end;

        LogLine(Format('summary: usedSlots=%d mc201Modules=%d', [lUsedCount, lMc201Count]));
        LogLine('RESULT Mc201ProtocolDebug passed');
        Result := 0;
      except
        on E: Exception do
        begin
          LogLine('ERROR ' + E.ClassName + ': ' + E.Message);
          Result := 3;
        end;
      end;
    finally  
      lClient.Free;
    end;
  finally
    g_Log.SaveToFile(lLogPath);
    FreeAndNil(g_Log);
  end;
end;

end.
