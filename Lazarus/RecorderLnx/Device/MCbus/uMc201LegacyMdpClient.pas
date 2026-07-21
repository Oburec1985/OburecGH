unit uMc201LegacyMdpClient;

{
  Минимальный TCP/MDP-клиент для MC-031/MC-032.

  Это автономная диагностическая копия обмена пакетами из оригинального пути
  Recorder mdpEthernet81::CallCommand. Модуль не использует классы устройств
  MIC/MEB из RecorderLnx, чтобы отладка MC-201 не затрагивала рабочие драйверы.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, ctypes, sockets, ssockets, resolve,
{$ifdef windows}
  WinSock2, Windows,
{$endif}
{$ifdef unix}
  BaseUnix, Unix,
{$endif}
  uMc201ProtocolTypes;

type
  EMc201MdpProtocol = class(Exception);
  { Загрузка BIOS медленная. Кеш намеренно живет внутри одного TCP-клиента:
    после переподключения/сброса признак в памяти модуля может быть устаревшим,
    поэтому новый клиент сначала валидирует уже загруженный BIOS легким INIT. }
  TMc201LoadedBiosSlots = set of 0..31;

  TMc201LegacyMdpClient = class
  private
    fHost: string;
    fPort: Word;
    fRxBuffer: array of Byte;
    fSocket: TSocketStream;
    fTimeoutMs: Cardinal;
    fDmHeapAddr: Word;
    fDmHeapRemain: Word;
    fLoadedBiosSlots: TMc201LoadedBiosSlots;
    function EnsureRxBytes(ACount: Integer): Boolean;
    procedure DropRxBytes(ACount: Integer);
    function OpenTcpStreamNoRaise(out AStream: TSocketStream;
      out AErrorMessage: string): Boolean;
    procedure WriteBytes(const ABuffer; ACount: Integer);
    procedure SendPacket(APort: Word; const AWords: TMc201WordArray);
    function ReadPacket(out APort: Word; out AWords: TMc201WordArray): Boolean;
    procedure SetTimeoutMs(AValue: Cardinal);
  public
    constructor Create(const AHost: string; APort: Word; ATimeoutMs: Cardinal);
    destructor Destroy; override;
    procedure Connect;
    function TryConnect(out AErrorMessage: string): Boolean;
    procedure Disconnect;
    { Сбрасывает только локальное знание о загруженных BIOS модулей.
      После RESET контроллера RAM модулей нельзя считать сохранённой. }
    procedure InvalidateLoadedBios;
    function DrainPackets(ATimeoutMs: Cardinal; out APacketCount: Integer;
      out AErrorMessage: string): Boolean;
    function ReadRawPacket(out APort: Word; out AWords: TMc201WordArray): Boolean;
    function CallCommand(ACommand: Word; const AArgs: TMc201WordArray;
      ARetWordCount: Integer; out ARet: TMc201WordArray;
      out AErrorMessage: string): Boolean;
    function SendCommandNoWait(ACommand: Word; const AArgs: TMc201WordArray;
      out AErrorMessage: string): Boolean;
    function ReadControllerBios(out ABios: TMc201ControllerBios;
      out AErrorMessage: string): Boolean;
    function ReadFlashWord(ASlot, AOffset: Word; out AValue: Word;
      out AErrorMessage: string): Boolean;
    procedure ResetLocalMemoryHeap;
    function GetInternalMemHeap(ASizeWords: Word; out APage, AAddr: Word;
      out AErrorMessage: string): Boolean;
    function GetAddrModuleReg(ASlot, AReg: Word): Word;
    function ReadRemoteWordArrayDM(AAddress: Word; ACount: Word;
      out AData: TMc201WordArray; out AErrorMessage: string): Boolean;
    function WriteRemoteWordArrayDM(AAddress: Word; const AData: TMc201WordArray;
      out AErrorMessage: string): Boolean;
    function ReadRemoteWordArrayModule(ASlot, AAddress, ACount: Word;
      out AData: TMc201WordArray; out AErrorMessage: string): Boolean;
    function WriteRemoteWordArrayModule(ASlot, AAddress: Word;
      const AData: TMc201WordArray; out AErrorMessage: string): Boolean;
    function WriteModuleReg(ASlot, AReg, AValue: Word;
      out AErrorMessage: string): Boolean;
    function LoadMc201BiosIdma(ASlot: Word; const ABiosPath: string;
      out AErrorMessage: string; AWaitAfterInit: Boolean = True): Boolean;
    function CallCommandModuleIdmaNotActivated(ASlot, ACommand: Word;
      const AArgs: TMc201WordArray; ARetWordCount: Integer;
      out ARet: TMc201WordArray; out AErrorMessage: string): Boolean;
    function CallCommandModule(ASlot, ACommand: Word; const AArgs: TMc201WordArray;
      ARetWordCount: Integer; out ARet: TMc201WordArray;
      out AErrorMessage: string): Boolean;
    function CallCommandModuleIdmaActivated(ASlot, ACommand: Word;
      const AArgs: TMc201WordArray; ARetWordCount: Integer;
      out ARet: TMc201WordArray; out AErrorMessage: string): Boolean;
    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write SetTimeoutMs;
  end;

implementation

uses
  uMc201FirmwareResources;

function GetWordLE(const AData: array of Byte; AOffset: Integer): Word;
begin
  Result := Word(AData[AOffset]) or (Word(AData[AOffset + 1]) shl 8);
end;

procedure PutWordLE(var AData: array of Byte; AOffset: Integer; AValue: Word);
begin
  AData[AOffset] := Byte(AValue and $FF);
  AData[AOffset + 1] := Byte((AValue shr 8) and $FF);
end;

constructor TMc201LegacyMdpClient.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  fLoadedBiosSlots := [];
  ResetLocalMemoryHeap;
end;

destructor TMc201LegacyMdpClient.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

{ TInetSocket.Create бросает ESocketError при обычном timeout соединения. GUI
  использует этот вариант без исключения, чтобы Search/Test/Connect писали
  "не найдено" в лог и не останавливали отладчик Lazarus на штатной ошибке. }
function TMc201LegacyMdpClient.OpenTcpStreamNoRaise(out AStream: TSocketStream;
  out AErrorMessage: string): Boolean;
var
  lAddr: TInetSockAddr;
  lErr: Longint;
  lErrLen: Longint;
  lFds: TFDSet;
  lHostAddr: THostAddr;
{$ifdef unix}
  lFlags: Longint;
{$endif}
{$ifdef windows}
  lMode: DWord;
{$endif}
  lRes: Longint;
  lSocket: cint;
  lTime: TTimeVal;
begin
  Result := False;
  AStream := nil;
  AErrorMessage := '';
  lSocket := -1;
  try
    lHostAddr := StrToHostAddr(fHost);
    if lHostAddr.s_bytes[1] = 0 then
      with THostResolver.Create(nil) do
        try
          if not NameLookup(fHost) then
          begin
            AErrorMessage := 'Host name resolution for "' + fHost + '" failed.';
            Exit;
          end;
          lHostAddr := HostAddress;
        finally
          Free;
        end;

    FillChar(lAddr, SizeOf(lAddr), 0);
    lAddr.sin_family := AF_INET;
    lAddr.sin_port := ShortHostToNet(fPort);
    lAddr.sin_addr.s_addr := HostToNet(lHostAddr.s_addr);

    lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
    if lSocket < 0 then
    begin
      AErrorMessage := 'Creation of socket failed: ' + IntToStr(SocketError);
      Exit;
    end;

{$ifdef unix}
    lFlags := FpFcntl(lSocket, F_GetFl, 0);
    if FpFcntl(lSocket, F_SetFl, lFlags or O_NONBLOCK) <> 0 then
    begin
      AErrorMessage := 'Setting nonblocking socket mode failed: ' +
        IntToStr(SocketError);
      Exit;
    end;
{$endif}
{$ifdef windows}
    lMode := 1;
    if ioctlsocket(lSocket, Longint(FIONBIO), @lMode) <> 0 then
    begin
      AErrorMessage := 'Setting nonblocking socket mode failed: ' +
        IntToStr(SocketError);
      Exit;
    end;
{$endif}

    lErr := 0;
    if fpConnect(lSocket, @lAddr, SizeOf(lAddr)) <> 0 then
    begin
      FillChar(lFds, SizeOf(lFds), 0);
{$ifdef unix}
      fpFD_Zero(lFds);
      fpFD_Set(lSocket, lFds);
{$endif}
{$ifdef windows}
      FD_Zero(lFds);
      FD_Set(lSocket, lFds);
{$endif}
      lTime.tv_sec := fTimeoutMs div 1000;
      lTime.tv_usec := (fTimeoutMs mod 1000) * 1000;
{$ifdef unix}
      lRes := fpSelect(lSocket + 1, nil, @lFds, nil, @lTime);
{$endif}
{$ifdef windows}
      lRes := WinSock2.select(lSocket + 1, nil, @lFds, nil, @lTime);
{$endif}
      if lRes = 0 then
      begin
        AErrorMessage := Format('Connection to %s:%d timed out.',
          [fHost, fPort]);
        Exit;
      end;
      if lRes < 0 then
      begin
        AErrorMessage := 'TCP connect select failed: ' + IntToStr(SocketError);
        Exit;
      end;
      lErrLen := SizeOf(lErr);
      fpGetSockOpt(lSocket, SOL_SOCKET, SO_ERROR, @lErr, @lErrLen);
      if lErr <> 0 then
      begin
        AErrorMessage := Format('Connection to %s:%d failed: %d',
          [fHost, fPort, lErr]);
        Exit;
      end;
    end;

{$ifdef unix}
    FpFcntl(lSocket, F_SetFl, lFlags and (not O_NONBLOCK));
{$endif}
{$ifdef windows}
    lMode := 0;
    ioctlsocket(lSocket, Longint(FIONBIO), @lMode);
{$endif}

    AStream := TSocketStream.Create(lSocket);
    AStream.IOTimeout := Integer(fTimeoutMs);
    lSocket := -1;
    Result := True;
  finally
    if lSocket >= 0 then
      CloseSocket(lSocket);
  end;
end;

function TMc201LegacyMdpClient.TryConnect(out AErrorMessage: string): Boolean;
begin
  Disconnect;
  Result := OpenTcpStreamNoRaise(fSocket, AErrorMessage);
end;

procedure TMc201LegacyMdpClient.Connect;
var
  lError: string;
begin
  if not TryConnect(lError) then
    raise EMc201MdpProtocol.Create(lError);
end;

procedure TMc201LegacyMdpClient.Disconnect;
begin
  SetLength(fRxBuffer, 0);
  FreeAndNil(fSocket);
end;

procedure TMc201LegacyMdpClient.InvalidateLoadedBios;
begin
  fLoadedBiosSlots := [];
end;

procedure TMc201LegacyMdpClient.SetTimeoutMs(AValue: Cardinal);
begin
  fTimeoutMs := AValue;
  if fSocket <> nil then
    fSocket.IOTimeout := Integer(fTimeoutMs);
end;

function TMc201LegacyMdpClient.ReadRawPacket(out APort: Word;
  out AWords: TMc201WordArray): Boolean;
begin
  Result := ReadPacket(APort, AWords);
end;

function TMc201LegacyMdpClient.DrainPackets(ATimeoutMs: Cardinal;
  out APacketCount: Integer; out AErrorMessage: string): Boolean;
var
  lOldTimeout: Cardinal;
  lPort: Word;
  lWords: TMc201WordArray;
begin
  Result := False;
  APacketCount := 0;
  AErrorMessage := '';
  lOldTimeout := fTimeoutMs;
  try
    SetTimeoutMs(ATimeoutMs);
    while ReadPacket(lPort, lWords) do
      Inc(APacketCount);
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
  SetTimeoutMs(lOldTimeout);
end;

function TMc201LegacyMdpClient.EnsureRxBytes(ACount: Integer): Boolean;
var
  lOldLength: Integer;
  lRead: Integer;
begin
  Result := Length(fRxBuffer) >= ACount;
  if Result then
    Exit;
  if fSocket = nil then
    raise EMc201MdpProtocol.Create('MDP socket is not connected');
  while Length(fRxBuffer) < ACount do
  begin
    lOldLength := Length(fRxBuffer);
    SetLength(fRxBuffer, ACount);
    lRead := fSocket.Read(fRxBuffer[lOldLength], ACount - lOldLength);
    if lRead <= 0 then
    begin
      SetLength(fRxBuffer, lOldLength);
      Exit(False);
    end;
    SetLength(fRxBuffer, lOldLength + lRead);
  end;
  Result := True;
end;

procedure TMc201LegacyMdpClient.DropRxBytes(ACount: Integer);
var
  lRemain: Integer;
begin
  if ACount <= 0 then
    Exit;
  if ACount >= Length(fRxBuffer) then
  begin
    SetLength(fRxBuffer, 0);
    Exit;
  end;
  lRemain := Length(fRxBuffer) - ACount;
  Move(fRxBuffer[ACount], fRxBuffer[0], lRemain);
  SetLength(fRxBuffer, lRemain);
end;

procedure TMc201LegacyMdpClient.WriteBytes(const ABuffer; ACount: Integer);
var
  lDone: Integer;
  lWritten: Integer;
begin
  if fSocket = nil then
    raise EMc201MdpProtocol.Create('MDP socket is not connected');
  lDone := 0;
  while lDone < ACount do
  begin
    lWritten := fSocket.Write((PByte(@ABuffer) + lDone)^, ACount - lDone);
    if lWritten <= 0 then
      raise EMc201MdpProtocol.Create('MDP TCP write failed');
    Inc(lDone, lWritten);
  end;
end;

procedure TMc201LegacyMdpClient.SendPacket(APort: Word;
  const AWords: TMc201WordArray);
var
  I: Integer;
  lBytes: array of Byte;
  lDataSum: LongWord;
  lHeaderSum: Word;
  lOffset: Integer;
begin
  if Length(AWords) > CMc201MdpMaxPacketWords then
    raise EMc201MdpProtocol.Create('MDP packet is too large');
  SetLength(lBytes, CMc201MdpHeaderBytes + (Length(AWords) + 1) * SizeOf(Word));
  lHeaderSum := Word((LongWord(CMc201MdpSyncWord) + APort + Length(AWords)) and $FFFF);
  PutWordLE(lBytes, 0, CMc201MdpSyncWord);
  PutWordLE(lBytes, 2, APort);
  PutWordLE(lBytes, 4, Length(AWords));
  PutWordLE(lBytes, 6, lHeaderSum);
  lOffset := CMc201MdpHeaderBytes;
  lDataSum := 0;
  for I := 0 to High(AWords) do
  begin
    PutWordLE(lBytes, lOffset, AWords[I]);
    Inc(lDataSum, AWords[I]);
    Inc(lOffset, SizeOf(Word));
  end;
  PutWordLE(lBytes, lOffset, Word(lDataSum and $FFFF));
  WriteBytes(lBytes[0], Length(lBytes));
end;

function TMc201LegacyMdpClient.ReadPacket(out APort: Word;
  out AWords: TMc201WordArray): Boolean;
var
  I: Integer;
  lDataSum: LongWord;
  lHeaderSum: Word;
  lPacketBytes: Integer;
  lSizeWords: Word;
begin
  Result := False;
  APort := 0;
  SetLength(AWords, 0);
  while True do
  begin
    if not EnsureRxBytes(CMc201MdpHeaderBytes) then
      Exit;
    if GetWordLE(fRxBuffer, 0) <> CMc201MdpSyncWord then
    begin
      DropRxBytes(1);
      Continue;
    end;
    APort := GetWordLE(fRxBuffer, 2);
    lSizeWords := GetWordLE(fRxBuffer, 4);
    lHeaderSum := Word((LongWord(CMc201MdpSyncWord) + APort + lSizeWords) and $FFFF);
    if (GetWordLE(fRxBuffer, 6) <> lHeaderSum) or
      (lSizeWords > CMc201MdpMaxPacketWords) then
    begin
      DropRxBytes(1);
      Continue;
    end;
    lPacketBytes := CMc201MdpHeaderBytes + (Integer(lSizeWords) + 1) * SizeOf(Word);
    if not EnsureRxBytes(lPacketBytes) then
      Exit;
    lDataSum := 0;
    for I := 0 to lSizeWords - 1 do
      Inc(lDataSum, GetWordLE(fRxBuffer, CMc201MdpHeaderBytes + I * SizeOf(Word)));
    if GetWordLE(fRxBuffer, CMc201MdpHeaderBytes + lSizeWords * SizeOf(Word)) <>
      Word(lDataSum and $FFFF) then
    begin
      DropRxBytes(1);
      Continue;
    end;
    SetLength(AWords, lSizeWords);
    for I := 0 to lSizeWords - 1 do
      AWords[I] := GetWordLE(fRxBuffer, CMc201MdpHeaderBytes + I * SizeOf(Word));
    DropRxBytes(lPacketBytes);
    Exit(True);
  end;
end;

function TMc201LegacyMdpClient.CallCommand(ACommand: Word;
  const AArgs: TMc201WordArray; ARetWordCount: Integer;
  out ARet: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  lPort: Word;
  lRequest: TMc201WordArray;
  lStartTick: QWord;
begin
  Result := False;
  AErrorMessage := '';
  SetLength(ARet, 0);
  try
    SetLength(lRequest, 3 + Length(AArgs));
    lRequest[0] := ACommand;
    lRequest[1] := Length(AArgs);
    lRequest[2] := ARetWordCount;
    if Length(AArgs) > 0 then
      Move(AArgs[0], lRequest[3], Length(AArgs) * SizeOf(Word));
    SendPacket(CMc201MdpStreamCommand, lRequest);
    lStartTick := GetTickCount64;
    repeat
      if not ReadPacket(lPort, ARet) then
      begin
        AErrorMessage := 'MDP command timeout';
        Exit;
      end;
      if (lPort <> CMc201MdpStreamCommand) and
        (GetTickCount64 - lStartTick >= fTimeoutMs) then
      begin
        AErrorMessage := Format(
          'MDP command reply timeout: cmd=%d, last port=%d',
          [ACommand, lPort]);
        Exit;
      end;
    until lPort = CMc201MdpStreamCommand;
    if (ARetWordCount > 0) and (Length(ARet) < ARetWordCount) then
    begin
      AErrorMessage := Format('MDP reply is too short: %d/%d',
        [Length(ARet), ARetWordCount]);
      Exit;
    end;
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc201LegacyMdpClient.SendCommandNoWait(ACommand: Word;
  const AArgs: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  lRequest: TMc201WordArray;
begin
  Result := False;
  AErrorMessage := '';
  try
    SetLength(lRequest, 3 + Length(AArgs));
    lRequest[0] := ACommand;
    lRequest[1] := Length(AArgs);
    lRequest[2] := 0;
    if Length(AArgs) > 0 then
      Move(AArgs[0], lRequest[3], Length(AArgs) * SizeOf(Word));
    SendPacket(CMc201MdpStreamCommand, lRequest);
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

function TMc201LegacyMdpClient.ReadControllerBios(
  out ABios: TMc201ControllerBios; out AErrorMessage: string): Boolean;
var
  lReply: TMc201WordArray;
begin
  FillChar(ABios, SizeOf(ABios), 0);
  Result := CallCommand(CMc201CmdReply, nil, SizeOf(ABios) div SizeOf(Word),
    lReply, AErrorMessage);
  if Result then
    Move(lReply[0], ABios, SizeOf(ABios));
end;

function TMc201LegacyMdpClient.ReadFlashWord(ASlot, AOffset: Word;
  out AValue: Word; out AErrorMessage: string): Boolean;
var
  lArgs: TMc201WordArray;
  lReply: TMc201WordArray;
begin
  AValue := 0;
  SetLength(lArgs, 2);
  lArgs[0] := ASlot;
  lArgs[1] := AOffset;
  Result := CallCommand(CMc201CmdReadFlash, lArgs, 1, lReply, AErrorMessage);
  if Result then
    AValue := lReply[0];
end;

procedure TMc201LegacyMdpClient.ResetLocalMemoryHeap;
begin
  fDmHeapAddr := CMc201DmHeapBegin;
  fDmHeapRemain := CMc201DmHeapEnd - CMc201DmHeapBegin;
end;

function TMc201LegacyMdpClient.GetInternalMemHeap(ASizeWords: Word;
  out APage, AAddr: Word; out AErrorMessage: string): Boolean;
begin
  AErrorMessage := '';
  APage := 0;
  AAddr := fDmHeapAddr;
  Result := ASizeWords <= fDmHeapRemain;
  if not Result then
  begin
    AErrorMessage := Format('MC032 local DM heap exhausted: need=%d remain=%d',
      [ASizeWords, fDmHeapRemain]);
    Exit;
  end;
  Inc(fDmHeapAddr, ASizeWords);
  Dec(fDmHeapRemain, ASizeWords);
end;

function TMc201LegacyMdpClient.GetAddrModuleReg(ASlot, AReg: Word): Word;
begin
  Result := (ASlot shl 3) or AReg;
end;

function TMc201LegacyMdpClient.ReadRemoteWordArrayDM(AAddress: Word;
  ACount: Word; out AData: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  lArgs: TMc201WordArray;
begin
  SetLength(AData, 0);
  SetLength(lArgs, 1);
  lArgs[0] := AAddress or CMc201IsDm;
  Result := CallCommand(CMc201CmdReadMemDm, lArgs, ACount, AData, AErrorMessage);
end;

function TMc201LegacyMdpClient.WriteRemoteWordArrayDM(AAddress: Word;
  const AData: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lArgs: TMc201WordArray;
  lReply: TMc201WordArray;
begin
  SetLength(lArgs, Length(AData) + 1);
  lArgs[0] := AAddress or CMc201IsDm;
  for I := 0 to High(AData) do
    lArgs[I + 1] := AData[I];
  Result := CallCommand(CMc201CmdWriteDm, lArgs, 0, lReply, AErrorMessage);
end;

{ IDMA GETARRAY проходит через исходное 32-словное окно аргументов команды.
  PM-память адресуется парами слов, поэтому не-DM адрес увеличивается на
  count div 2. Общая константа размера куска держит GETARRAY и PUTARRAY
  одинаково выровненными. }
function TMc201LegacyMdpClient.ReadRemoteWordArrayModule(ASlot, AAddress,
  ACount: Word; out AData: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lArgs: TMc201WordArray;
  lChunk: TMc201WordArray;
  lDone: Word;
  lReadCount: Word;
begin
  Result := False;
  SetLength(AData, ACount);
  lDone := 0;
  while lDone < ACount do
  begin
    lReadCount := ACount - lDone;
    if lReadCount > CMc201IdmaArrayMaxDataWords then
      lReadCount := CMc201IdmaArrayMaxDataWords;
    SetLength(lArgs, CMc201IdmaArrayHeaderWords);
    lArgs[0] := ASlot;
    lArgs[1] := GetAddrModuleReg(ASlot, CMc201ModuleDataReg);
    lArgs[2] := GetAddrModuleReg(ASlot, CMc201ModuleIdmaReg);
    lArgs[3] := AAddress;
    lArgs[4] := lReadCount;
    if not CallCommand(CMc201CmdIdmaGetArray, lArgs, lReadCount, lChunk,
      AErrorMessage) then
      Exit;
    for I := 0 to lReadCount - 1 do
      if I <= High(lChunk) then
        AData[lDone + I] := lChunk[I];
    if (AAddress and CMc201IsDm) <> 0 then
      Inc(AAddress, lReadCount)
    else
      Inc(AAddress, lReadCount div 2);
    Inc(lDone, lReadCount);
  end;
  Result := True;
end;

{ IDMA PUTARRAY должен использовать такое же разбиение, как исходный Recorder.
  Большие куски помещаются в сырой Ethernet-пакет, но не в буфер аргументов
  mdpEthernet81; нечетные куски PM сдвигают адрес следующей записи. }
function TMc201LegacyMdpClient.WriteRemoteWordArrayModule(ASlot,
  AAddress: Word; const AData: TMc201WordArray;
  out AErrorMessage: string): Boolean;
var
  I: Integer;
  lArgs: TMc201WordArray;
  lDone: Word;
  lReply: TMc201WordArray;
  lWriteCount: Word;
begin
  Result := False;
  lDone := 0;
  while lDone < Length(AData) do
  begin
    lWriteCount := Length(AData) - lDone;
    if lWriteCount > CMc201IdmaArrayMaxDataWords then
      lWriteCount := CMc201IdmaArrayMaxDataWords;
    SetLength(lArgs, lWriteCount + CMc201IdmaArrayHeaderWords);
    lArgs[0] := ASlot;
    lArgs[1] := GetAddrModuleReg(ASlot, CMc201ModuleDataReg);
    lArgs[2] := GetAddrModuleReg(ASlot, CMc201ModuleIdmaReg);
    lArgs[3] := AAddress;
    lArgs[4] := lWriteCount;
    for I := 0 to lWriteCount - 1 do
      lArgs[5 + I] := AData[lDone + I];
    if not CallCommand(CMc201CmdIdmaPutArray, lArgs, 0, lReply,
      AErrorMessage) then
      Exit;
    if (AAddress and CMc201IsDm) <> 0 then
      Inc(AAddress, lWriteCount)
    else
      Inc(AAddress, lWriteCount div 2);
    Inc(lDone, lWriteCount);
  end;
  Result := True;
end;

function TMc201LegacyMdpClient.WriteModuleReg(ASlot, AReg, AValue: Word;
  out AErrorMessage: string): Boolean;
var
  lArgs: TMc201WordArray;
  lReply: TMc201WordArray;
begin
  SetLength(lArgs, 2);
  lArgs[0] := GetAddrModuleReg(ASlot, AReg);
  lArgs[1] := AValue;
  Result := CallCommand(CMc201CmdPutRemote, lArgs, 0, lReply, AErrorMessage);
end;

{ Готовит небольшой BIOS MC-201, через который затем выполняются модульные
  команды. Быстрый путь сначала проверяет уже загруженный BIOS по A5A5 и INIT;
  если проверка не прошла, выполняется полная загрузка .bio в память модуля. }
function TMc201LegacyMdpClient.LoadMc201BiosIdma(ASlot: Word;
  const ABiosPath: string; out AErrorMessage: string;
  AWaitAfterInit: Boolean): Boolean;
var
  I: Integer;
  lBiosBytes: TBytes;
  lBiosWords: TMc201WordArray;
  lCodeWords: TMc201WordArray;
  lK: Word;
  lN: Word;
  lReply: TMc201WordArray;
  lSource: string;
  lStartTick: QWord;
  lStatus: TMc201WordArray;
  lVars: TMc201WordArray;

  function TryUseLoadedBios(out ALocalError: string): Boolean;
  begin
    Result := False;
    ALocalError := '';
    if not WriteModuleReg(ASlot, CMc201ModuleIdmaReg, $6000, ALocalError) then
      Exit;
    if not ReadRemoteWordArrayModule(ASlot, CMc201ModuleBiosLoadTMode, 1,
      lStatus, ALocalError) then
      Exit;
    if (Length(lStatus) = 0) or
      (lStatus[0] <> CMc201ModuleBiosLoadFlag) then
    begin
      if Length(lStatus) > 0 then
        ALocalError := Format('признак BIOS slot=%d status=0x%.4x',
          [ASlot, lStatus[0]])
      else
        ALocalError := Format('признак BIOS slot=%d не прочитан', [ASlot]);
      Exit;
    end;
    Result := CallCommandModuleIdmaNotActivated(ASlot, CMc201ModuleCmdInit,
      nil, 2, lReply, ALocalError);
  end;

begin
  Result := False;
  AErrorMessage := '';
  if (ASlot <= 31) and (ASlot in fLoadedBiosSlots) then
    Exit(True);

  if TryUseLoadedBios(AErrorMessage) then
  begin
    if ASlot <= 31 then
      Include(fLoadedBiosSlots, ASlot);
    Exit(True);
  end;

  if not WriteModuleReg(ASlot, CMc201ModuleIdmaReg, $6000, AErrorMessage) then
    Exit;
  Sleep(50);

  if not LoadDeviceBinaryResource(CMc201BiosResourceName, ABiosPath,
    lBiosBytes, lSource, AErrorMessage) then
    Exit;
  if (Length(lBiosBytes) < 8) or ((Length(lBiosBytes) mod 2) <> 0) then
  begin
    AErrorMessage := 'MC201 BIOS имеет неверный размер: ' + lSource;
    Exit;
  end;
  SetLength(lBiosWords, Length(lBiosBytes) div 2);
  for I := 0 to High(lBiosWords) do
    lBiosWords[I] := GetWordLE(lBiosBytes, I * 2);

  lK := lBiosWords[0];
  if (lK < 3) or (lK + 1 > High(lBiosWords)) then
  begin
    AErrorMessage := Format('MC201 BIOS header is invalid: k=%d words=%d',
      [lK, Length(lBiosWords)]);
    Exit;
  end;
  lN := lBiosWords[lK + 1];
  if lK + 1 + lN > High(lBiosWords) then
  begin
    AErrorMessage := Format('MC201 BIOS var block is invalid: k=%d n=%d words=%d',
      [lK, lN, Length(lBiosWords)]);
    Exit;
  end;

  SetLength(lVars, lN);
  for I := 0 to lN - 1 do
    lVars[I] := lBiosWords[lK + 2 + I];
  if not WriteRemoteWordArrayModule(ASlot, CMc201ModuleBiosLoadVarSpace,
    lVars, AErrorMessage) then
    Exit;

  SetLength(lCodeWords, lK - 2);
  for I := 0 to High(lCodeWords) do
    lCodeWords[I] := lBiosWords[3 + I];
  if not WriteRemoteWordArrayModule(ASlot, 1, lCodeWords, AErrorMessage) then
    Exit;

  SetLength(lVars, 1);
  lVars[0] := ASlot;
  if not WriteRemoteWordArrayModule(ASlot, CMc201ModuleBiosLoadTMode, lVars,
    AErrorMessage) then
    Exit;

  SetLength(lCodeWords, 2);
  lCodeWords[0] := lBiosWords[1];
  lCodeWords[1] := lBiosWords[2];
  if not WriteRemoteWordArrayModule(ASlot, 0, lCodeWords, AErrorMessage) then
    Exit;

  lStartTick := GetTickCount64;
  repeat
    if not ReadRemoteWordArrayModule(ASlot, CMc201ModuleBiosLoadTMode, 1,
      lStatus, AErrorMessage) then
      Exit;
    if (Length(lStatus) > 0) and
      (lStatus[0] = CMc201ModuleBiosLoadFlag) then
      Break;
    Sleep(1);
  until GetTickCount64 - lStartTick >= 10000;

  if (Length(lStatus) = 0) or
    (lStatus[0] <> CMc201ModuleBiosLoadFlag) then
  begin
    if Length(lStatus) > 0 then
      AErrorMessage := Format('MC201 BIOS load timeout slot=%d status=0x%.4x',
        [ASlot, lStatus[0]])
    else
      AErrorMessage := Format('MC201 BIOS load timeout slot=%d no status',
        [ASlot]);
    Exit;
  end;

  if not CallCommandModuleIdmaNotActivated(ASlot, CMc201ModuleCmdInit, nil, 2,
    lReply, AErrorMessage) then
    Exit;
  if AWaitAfterInit then
    Sleep(350);
  if ASlot <= 31 then
    Include(fLoadedBiosSlots, ASlot);
  Result := True;
end;

function TMc201LegacyMdpClient.CallCommandModuleIdmaNotActivated(ASlot,
  ACommand: Word; const AArgs: TMc201WordArray; ARetWordCount: Integer;
  out ARet: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  lCommand: TMc201WordArray;
  lStartTick: QWord;
  lStatusWord: Word;
  lStatus: TMc201WordArray;
begin
  SetLength(ARet, 0);
  if Length(AArgs) > 0 then
    if not WriteRemoteWordArrayModule(ASlot, CMc201ModuleVarVars, AArgs,
      AErrorMessage) then
      Exit(False);
  SetLength(lCommand, 1);
  lCommand[0] := ACommand;
  if not WriteRemoteWordArrayModule(ASlot, CMc201ModuleVarCommand, lCommand,
    AErrorMessage) then
    Exit(False);
  if not WriteModuleReg(ASlot, CMc201ModuleIrqReg, 0, AErrorMessage) then
    Exit(False);

  lStartTick := GetTickCount64;
  repeat
    if not ReadRemoteWordArrayModule(ASlot, CMc201ModuleVarCommand, 1,
      lStatus, AErrorMessage) then
      Exit(False);
    if (Length(lStatus) > 0) and (lStatus[0] = CMc201FlagCommandFinish) then
      Break;
    Sleep(0);
  until GetTickCount64 - lStartTick >= fTimeoutMs;

  if (Length(lStatus) = 0) or (lStatus[0] <> CMc201FlagCommandFinish) then
  begin
    lStatusWord := 0;
    if Length(lStatus) > 0 then
      lStatusWord := lStatus[0];
    AErrorMessage := Format('module command timeout slot=%d cmd=%d status=0x%.4x',
      [ASlot, ACommand, lStatusWord]);
    Exit(False);
  end;

  if ARetWordCount <= 0 then
    Exit(True);
  Result := ReadRemoteWordArrayModule(ASlot, CMc201ModuleVarVars,
    ARetWordCount, ARet, AErrorMessage);
end;

function TMc201LegacyMdpClient.CallCommandModule(ASlot, ACommand: Word;
  const AArgs: TMc201WordArray; ARetWordCount: Integer;
  out ARet: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lArgs: TMc201WordArray;
  lReply: TMc201WordArray;
begin
  SetLength(ARet, 0);
  SetLength(lArgs, 4 + Length(AArgs));
  lArgs[0] := ASlot;
  lArgs[1] := ACommand;
  lArgs[2] := Length(AArgs);
  lArgs[3] := ARetWordCount;
  for I := 0 to High(AArgs) do
    lArgs[4 + I] := AArgs[I];
  Result := CallCommand(CMc201CmdIdmaCallCommand, lArgs, 1 + ARetWordCount,
    lReply, AErrorMessage);
  if not Result then
    Exit;
  if Length(lReply) < 1 then
  begin
    AErrorMessage := 'IDMA module command returned empty reply';
    Exit(False);
  end;
  if lReply[0] <> 0 then
  begin
    AErrorMessage := Format('IDMA module command error=%d slot=%d cmd=%d',
      [lReply[0], ASlot, ACommand]);
    Exit(False);
  end;
  SetLength(ARet, ARetWordCount);
  for I := 0 to ARetWordCount - 1 do
    if I + 1 <= High(lReply) then
      ARet[I] := lReply[I + 1];
end;

function TMc201LegacyMdpClient.CallCommandModuleIdmaActivated(ASlot,
  ACommand: Word; const AArgs: TMc201WordArray; ARetWordCount: Integer;
  out ARet: TMc201WordArray; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lFirstArg: TMc201WordArray;
  lReply: TMc201WordArray;
  lTail: TMc201WordArray;
begin
  SetLength(ARet, 0);
  if Length(AArgs) > 1 then
  begin
    SetLength(lTail, Length(AArgs) - 1);
    for I := 1 to High(AArgs) do
      lTail[I - 1] := AArgs[I];
    if not WriteRemoteWordArrayModule(ASlot, CMc201ModuleVarVars + 1, lTail,
      AErrorMessage) then
      Exit(False);
  end;
  SetLength(lFirstArg, 1);
  if Length(AArgs) > 0 then
    lFirstArg[0] := AArgs[0]
  else
    lFirstArg[0] := 0;
  if not CallCommandModule(ASlot, ACommand, lFirstArg, 0, lReply,
    AErrorMessage) then
    Exit(False);
  if ARetWordCount <= 0 then
    Exit(True);
  Result := ReadRemoteWordArrayModule(ASlot, CMc201ModuleVarVars,
    ARetWordCount, ARet, AErrorMessage);
end;

end.
