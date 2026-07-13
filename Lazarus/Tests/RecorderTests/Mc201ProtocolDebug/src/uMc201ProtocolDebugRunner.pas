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
    RunAcceptance: Boolean;
    ConnectAttempts: Integer;
    ConnectRetryMs: Cardinal;
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
  AOptions.UpdateMs := CMc201DefaultUpdateMs;
  AOptions.RunAcceptance := False;
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
  lBlockCount: Integer;
  lConfig: TMc032Config;
  lDevice: TMc032Device;
  lExpectedBlocks: Integer;
  lModules: TMc201SlotInfoArray;
  lPort: Word;
  lStartTick: QWord;
  lStopError: string;
  lWords: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  lBlockCount := 0;
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

    if not lDevice.StartRawScan(AErrorMessage) then
    begin
      AErrorMessage := 'STARTSCANMAIN failed: ' + AErrorMessage;
      Exit;
    end;
    LogLine('device acceptance: STARTSCANMAIN OK');

    lStartTick := GetTickCount64;
    try
      while GetTickCount64 - lStartTick < AOptions.AcceptanceMs do
      begin
        if lDevice.ReadRawPacket(lPort, lWords) and
          (lPort <> CMc201MdpStreamCommand) then
        begin
          Inc(lBlockCount);
          LogLine(Format('RX block=%d stream=%d words=%d elapsedMs=%d',
            [lBlockCount, lPort, Length(lWords), GetTickCount64 - lStartTick]));
        end;
      end;
    finally
      if lDevice.Stop(lStopError) then
        LogLine('device acceptance: STOPSCANMAIN OK')
      else
        LogLine('device acceptance: STOPSCANMAIN failed: ' + lStopError);
    end;

    LogLine(Format('acceptance summary: blocks=%d expected=%d updateMs=%d',
      [lBlockCount, lExpectedBlocks, AOptions.UpdateMs]));
    Result := lBlockCount = lExpectedBlocks;
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
