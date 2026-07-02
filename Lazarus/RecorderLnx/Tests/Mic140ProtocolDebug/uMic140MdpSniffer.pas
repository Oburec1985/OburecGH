unit uMic140MdpSniffer;

{
  TCP-прокси для сравнения трафика Windows Recorder и стенда Mic140ProtocolDebug.

  Recorder подключается к listenPort; прокси пересылает на deviceHost:devicePort
  и пишет каждый MDP-кадр в Data/captures/mic140_mdp_YYYYMMDD_HHNNSS.log.
}

{$mode objfpc}{$H+}

interface

function Mic140RunMdpProxy(AListenPort: Word; const ADeviceHost: string;
  ADevicePort: Word): Integer;

implementation

uses
  Classes, SysUtils, DateUtils, Math
  {$IFDEF MSWINDOWS}
  , WinSock2, Sockets
  {$ENDIF}
  ;

const
  CLegacySyncWord = Word($12B8);
  CLegacyHeaderBytes = 8;
  CMic140LegacyBiosHeaderWords = 10;
  CMic140LegacyBiosNumBuffIdx = 8;

function GetWordLE(const ABuf: TBytes; AOffset: Integer): Word;
begin
  Result := Word(ABuf[AOffset]) or (Word(ABuf[AOffset + 1]) shl 8);
end;

function HexPreview(const ABuf: TBytes; AMaxBytes: Integer): string;
var
  I, L: Integer;
begin
  Result := '';
  L := Length(ABuf);
  if L > AMaxBytes then
    L := AMaxBytes;
  for I := 0 to L - 1 do
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + IntToHex(ABuf[I], 2);
  end;
  if Length(ABuf) > AMaxBytes then
    Result := Result + ' ...';
end;

function SignedWordsPreview(const ABuf: TBytes; AWordOffset, ACount: Integer): string;
var
  I, L, W: Integer;
begin
  Result := '';
  L := (Length(ABuf) - AWordOffset * 2) div 2;
  if ACount < L then
    L := ACount;
  for I := 0 to L - 1 do
  begin
    W := SmallInt(GetWordLE(ABuf, AWordOffset * 2 + I * 2));
    if Result <> '' then
      Result := Result + ',';
    Result := Result + IntToStr(W);
  end;
end;

procedure LogLine(ALog: TStringList; const ALine: string);
begin
  ALog.Add(ALine);
  WriteLn(ALine);
end;

procedure LogMdpFrame(ALog: TStringList; const ADirection: string;
  const AFrame: TBytes);
var
  lPort, lSize, lHcs, lDcs: Word;
  lCalcHcs, lCalcDcs: LongWord;
  lI, lPayloadBytes: Integer;
  lDataWords, lSamples, lStride: Integer;
  lHcsText, lDcsText: string;
begin
  if Length(AFrame) < CLegacyHeaderBytes + SizeOf(Word) then
  begin
    LogLine(ALog, Format('%s short frame %d bytes: %s',
      [ADirection, Length(AFrame), HexPreview(AFrame, 32)]));
    Exit;
  end;
  lPort := GetWordLE(AFrame, 2);
  lSize := GetWordLE(AFrame, 4);
  lHcs := GetWordLE(AFrame, 6);
  lCalcHcs := Word((LongWord(CLegacySyncWord) + lPort + lSize) and $FFFF);
  lPayloadBytes := lSize * SizeOf(Word);
  if Length(AFrame) < CLegacyHeaderBytes + lPayloadBytes + SizeOf(Word) then
  begin
    LogLine(ALog, Format('%s incomplete frame port=%d size=%d bytes=%d',
      [ADirection, lPort, lSize, Length(AFrame)]));
    Exit;
  end;
  lCalcDcs := 0;
  for lI := 0 to lSize - 1 do
    Inc(lCalcDcs, GetWordLE(AFrame, CLegacyHeaderBytes + lI * 2));
  lDcs := GetWordLE(AFrame, CLegacyHeaderBytes + lPayloadBytes);
  if lHcs = lCalcHcs then
    lHcsText := 'OK'
  else
    lHcsText := 'BAD';
  if lDcs = Word(lCalcDcs and $FFFF) then
    lDcsText := 'OK'
  else
    lDcsText := 'BAD';
  LogLine(ALog, Format(
    '%s port=%d words=%d hcs=%s dcs=%s bytes=%d hex=%s',
    [ADirection, lPort, lSize, lHcsText, lDcsText,
     Length(AFrame), HexPreview(AFrame, 48)]));
  if (lPort = 0) and (lSize >= CMic140LegacyBiosHeaderWords) then
  begin
    lDataWords := lSize - CMic140LegacyBiosHeaderWords;
    for lStride in [48, 51, 60] do
      if (lDataWords > 0) and (lDataWords mod lStride = 0) then
      begin
        lSamples := lDataWords div lStride;
        LogLine(ALog, Format(
          '  bios nb=%d state=%d dataWords=%d stride=%d samples=%d first48=[%s] tin=[%s]',
          [GetWordLE(AFrame, CLegacyHeaderBytes + CMic140LegacyBiosNumBuffIdx * 2),
           GetWordLE(AFrame, CLegacyHeaderBytes + 9 * 2),
           lDataWords, lStride, lSamples,
           SignedWordsPreview(AFrame, CMic140LegacyBiosHeaderWords, 48),
           SignedWordsPreview(AFrame, CMic140LegacyBiosHeaderWords + 48, 3)]));
        Break;
      end;
  end;
end;

procedure PumpSocket(ASock: TSocket; ADst: TSocket; ALog: TStringList;
  const ADirection: string; var ABuffer: TBytes);
var
  lChunk: array[0..4095] of Byte;
  lRead, lNeed, lI: Integer;
  lFrame: TBytes;
begin
  lRead := WinSock2.recv(ASock, lChunk[0], SizeOf(lChunk), 0);
  if lRead <= 0 then
    raise Exception.Create('socket closed');
  if WinSock2.send(ADst, lChunk[0], lRead, 0) <= 0 then
    raise Exception.Create('proxy send failed');

  SetLength(ABuffer, Length(ABuffer) + lRead);
  Move(lChunk[0], ABuffer[Length(ABuffer) - lRead], lRead);

  while Length(ABuffer) >= CLegacyHeaderBytes do
  begin
    if GetWordLE(ABuffer, 0) <> CLegacySyncWord then
    begin
      Delete(ABuffer, 0, 1);
      Continue;
    end;
    lNeed := CLegacyHeaderBytes +
      GetWordLE(ABuffer, 4) * SizeOf(Word) + SizeOf(Word);
    if Length(ABuffer) < lNeed then
      Break;
    SetLength(lFrame, lNeed);
    for lI := 0 to lNeed - 1 do
      lFrame[lI] := ABuffer[lI];
    LogMdpFrame(ALog, ADirection, lFrame);
    Delete(ABuffer, 0, lNeed);
  end;
end;

{$IFDEF MSWINDOWS}
function Mic140OpenListenSocket(APort: Word): TSocket;
var
  addr: TSockAddrIn;
  wsa: TWSAData;
  opt: LongInt;
begin
  Result := INVALID_SOCKET;
  if WSAStartup($0202, wsa) <> 0 then
    Exit;
  Result := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if Result = INVALID_SOCKET then
    Exit;
  opt := 1;
  setsockopt(Result, SOL_SOCKET, SO_REUSEADDR, @opt, SizeOf(opt));
  FillChar(addr, SizeOf(addr), 0);
  addr.sin_family := AF_INET;
  addr.sin_port := htons(APort);
  addr.sin_addr.S_addr := INADDR_ANY;
  if bind(Result, @addr, SizeOf(addr)) <> 0 then
  begin
    closesocket(Result);
    Result := INVALID_SOCKET;
    Exit;
  end;
  if listen(Result, 1) <> 0 then
  begin
    closesocket(Result);
    Result := INVALID_SOCKET;
  end;
end;

function Mic140ConnectSocket(const AHost: string; APort: Word): TSocket;
var
  addr: TSockAddrIn;
  ip: u_long;
begin
  Result := INVALID_SOCKET;
  ip := inet_addr(PChar(AnsiString(AHost)));
  if ip = INADDR_NONE then
    Exit;
  Result := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if Result = INVALID_SOCKET then
    Exit;
  FillChar(addr, SizeOf(addr), 0);
  addr.sin_family := AF_INET;
  addr.sin_port := htons(APort);
  addr.sin_addr.S_addr := ip;
  if WinSock2.connect(Result, @addr, SizeOf(addr)) <> 0 then
  begin
    closesocket(Result);
    Result := INVALID_SOCKET;
  end;
end;

function Mic140RunMdpProxy(AListenPort: Word; const ADeviceHost: string;
  ADevicePort: Word): Integer;
var
  lServer, lClient, lDevice: TSocket;
  lLogPath: string;
  lLog: TStringList;
  lClientBuf, lDeviceBuf: TBytes;
  lReadSet: TFDSet;
  lTv: TTimeVal;
begin
  Result := 1;
  ForceDirectories(ExtractFilePath(ParamStr(0)) + 'Data\captures');
  lLogPath := Format('%sData\captures\mic140_mdp_%s.log',
    [IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))),
     FormatDateTime('yyyymmdd_hhnnss', Now)]);
  lLog := TStringList.Create;
  lServer := INVALID_SOCKET;
  lClient := INVALID_SOCKET;
  lDevice := INVALID_SOCKET;
  try
    lServer := Mic140OpenListenSocket(AListenPort);
    if lServer = INVALID_SOCKET then
      raise Exception.Create('listen failed');
    LogLine(lLog, Format('MIC-140 MDP proxy listen :%d -> %s:%d',
      [AListenPort, ADeviceHost, ADevicePort]));
    LogLine(lLog, 'Log: ' + lLogPath);
    LogLine(lLog, Format('Point Recorder to 127.0.0.1:%d', [AListenPort]));
    LogLine(lLog, 'Press Ctrl+C to stop.');

    lClient := WinSock2.accept(lServer, nil, nil);
    if lClient = INVALID_SOCKET then
      raise Exception.Create('accept failed');
    lDevice := Mic140ConnectSocket(ADeviceHost, ADevicePort);
    if lDevice = INVALID_SOCKET then
      raise Exception.Create('device connect failed');
    LogLine(lLog, Format('# session %s device=%s:%d',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), ADeviceHost, ADevicePort]));

    SetLength(lClientBuf, 0);
    SetLength(lDeviceBuf, 0);
    while True do
    begin
      FD_ZERO(lReadSet);
      FD_SET(lClient, lReadSet);
      FD_SET(lDevice, lReadSet);
      lTv.tv_sec := 0;
      lTv.tv_usec := 200000;
      if select(0, @lReadSet, nil, nil, @lTv) <= 0 then
        Continue;
      if FD_ISSET(lClient, lReadSet) then
        PumpSocket(lClient, lDevice, lLog, 'C->D', lClientBuf);
      if FD_ISSET(lDevice, lReadSet) then
        PumpSocket(lDevice, lClient, lLog, 'D->C', lDeviceBuf);
    end;
  except
    on E: Exception do
    begin
      LogLine(lLog, 'Proxy stopped: ' + E.Message);
      Result := 0;
    end;
  end;
  if lDevice <> INVALID_SOCKET then
    closesocket(lDevice);
  if lClient <> INVALID_SOCKET then
    closesocket(lClient);
  if lServer <> INVALID_SOCKET then
    closesocket(lServer);
  if lLog.Count > 0 then
    lLog.SaveToFile(lLogPath);
  lLog.Free;
  WSACleanup;
end;
{$ELSE}
function Mic140RunMdpProxy(AListenPort: Word; const ADeviceHost: string;
  ADevicePort: Word): Integer;
begin
  WriteLn('MIC-140 MDP proxy is implemented for Windows only in this build.');
  Result := 1;
end;
{$ENDIF}

end.
