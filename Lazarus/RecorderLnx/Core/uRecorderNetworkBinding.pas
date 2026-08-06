unit uRecorderNetworkBinding;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, ctypes, Sockets, ssockets;

const
  CRecorderNetworkAutomatic = '';

function RecorderNetworkBindAddress: string;
procedure SetRecorderNetworkBindAddress(const AValue: string);
procedure RecorderEnumerateLocalIPv4(AItems: TStrings);
function RecorderNetworkAddressFromDisplay(const AValue: string): string;
procedure RecorderEnumerateDiscoveryIPv4(AItems: TStrings;
  AMaximumHosts: Integer = 65534);
procedure RecorderDiscoverMeraBroadcast(AFoundHosts: TStrings;
  ATimeoutMs: Cardinal = 1200);
function RecorderOpenBoundTcpStream(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal; out AStream: TSocketStream;
  out AErrorText: string): Boolean;

implementation

uses
  Resolve, StrUtils
  {$ifdef unix}, BaseUnix{$endif}
  {$ifdef windows}, Windows, WinSock2, JwaIpHlpApi, JwaIpTypes,
    JwaIpRtrMib{$endif};

var
  g_RecorderNetworkBindAddress: string = '';

function RecorderNetworkBindAddress: string;
begin
  Result := g_RecorderNetworkBindAddress;
end;

procedure SetRecorderNetworkBindAddress(const AValue: string);
var
  lAddress: THostAddr;
begin
  if Trim(AValue) = '' then
  begin
    g_RecorderNetworkBindAddress := '';
    Exit;
  end;
  lAddress := StrToHostAddr(Trim(AValue));
  if lAddress.s_addr = 0 then
    raise ESocketError.CreateFmt('Некорректный локальный IPv4-адрес: %s',
      [AValue]);
  g_RecorderNetworkBindAddress := HostAddrToStr(lAddress);
end;

procedure RecorderEnumerateLocalIPv4(AItems: TStrings);
var
  I: Integer;
  lHostName: string;
  lIp: string;
  lResolver: THostResolver;
{$ifdef windows}
  lAdapter: PIP_ADAPTER_ADDRESSES;
  lBuffer: Pointer;
  lBufferSize: ULONG;
  lResult: DWORD;
  lUnicast: PIP_ADAPTER_UNICAST_ADDRESS;
  lSockAddr: PSockAddrIn;
  lName: UnicodeString;
{$endif}
begin
  if AItems = nil then Exit;
  AItems.BeginUpdate;
  try
    AItems.Clear;
    AItems.Add('Автоматически (метрика ОС)');
{$ifdef windows}
    lBuffer := nil;
    lBufferSize := 0;
    lResult := GetAdaptersAddresses(AF_INET,
      GAA_FLAG_SKIP_ANYCAST or GAA_FLAG_SKIP_MULTICAST or
      GAA_FLAG_SKIP_DNS_SERVER, nil, nil, @lBufferSize);
    if (lResult = ERROR_BUFFER_OVERFLOW) and (lBufferSize > 0) then
    begin
      GetMem(lBuffer, lBufferSize);
      try
        lResult := GetAdaptersAddresses(AF_INET,
          GAA_FLAG_SKIP_ANYCAST or GAA_FLAG_SKIP_MULTICAST or
          GAA_FLAG_SKIP_DNS_SERVER, nil, PIP_ADAPTER_ADDRESSES(lBuffer),
          @lBufferSize);
        if lResult = NO_ERROR then
        begin
          lAdapter := PIP_ADAPTER_ADDRESSES(lBuffer);
          while lAdapter <> nil do
          begin
            if lAdapter^.OperStatus = IfOperStatusUp then
            begin
              lName := UnicodeString(lAdapter^.FriendlyName);
              lUnicast := lAdapter^.FirstUnicastAddress;
              while lUnicast <> nil do
              begin
                if (lUnicast^.Address.lpSockaddr <> nil) and
                   (lUnicast^.Address.lpSockaddr^.sa_family = AF_INET) then
                begin
                  lSockAddr := PSockAddrIn(lUnicast^.Address.lpSockaddr);
                  lIp := string(WinSock2.inet_ntoa(lSockAddr^.sin_addr));
                  if (lIp <> '') and (lIp <> '0.0.0.0') then
                    AItems.Add(UTF8Encode(lName) + ' [' + lIp + ']');
                end;
                lUnicast := lUnicast^.Next;
              end;
            end;
            lAdapter := lAdapter^.Next;
          end;
        end;
      finally
        FreeMem(lBuffer);
      end;
      Exit;
    end;
{$endif}
    lHostName := SysUtils.GetEnvironmentVariable('COMPUTERNAME');
    if lHostName = '' then
      lHostName := SysUtils.GetEnvironmentVariable('HOSTNAME');
    if lHostName = '' then Exit;
    lResolver := THostResolver.Create(nil);
    try
      if lResolver.NameLookup(lHostName) then
        for I := 0 to lResolver.AddressCount - 1 do
        begin
          lIp := HostAddrToStr(lResolver.Addresses[I]);
          if (lIp <> '') and (lIp <> '0.0.0.0') and
             (AItems.IndexOf(lIp) < 0) then
            AItems.Add(lIp);
        end;
    finally
      lResolver.Free;
    end;
  finally
    AItems.EndUpdate;
  end;
end;

function RecorderNetworkAddressFromDisplay(const AValue: string): string;
var
  lOpenPos, lClosePos: SizeInt;
begin
  Result := Trim(AValue);
  if SameText(Result, 'Автоматически (метрика ОС)') then Exit('');
  lClosePos := RPos(']', Result);
  lOpenPos := RPos('[', Result);
  if (lOpenPos > 0) and (lClosePos > lOpenPos) then
    Result := Copy(Result, lOpenPos + 1, lClosePos - lOpenPos - 1);
end;

function TryIPv4ToUInt32(const AValue: string; out AResult: Cardinal): Boolean;
var
  lParts: TStringList;
  I, lPart: Integer;
begin
  Result := False;
  AResult := 0;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := '.';
    lParts.DelimitedText := Trim(AValue);
    if lParts.Count <> 4 then Exit;
    for I := 0 to 3 do
    begin
      if not TryStrToInt(lParts[I], lPart) or (lPart < 0) or (lPart > 255) then
        Exit;
      AResult := (AResult shl 8) or Cardinal(lPart);
    end;
    Result := True;
  finally
    lParts.Free;
  end;
end;

function UInt32ToIPv4(AValue: Cardinal): string;
begin
  Result := Format('%d.%d.%d.%d', [(AValue shr 24) and $ff,
    (AValue shr 16) and $ff, (AValue shr 8) and $ff, AValue and $ff]);
end;

procedure RecorderEnumerateDiscoveryIPv4(AItems: TStrings;
  AMaximumHosts: Integer);
var
  lLocalValue, lMask, lNetwork, lBroadcast, lValue: Cardinal;
  lAdded: Integer;
  lIp: string;
{$ifdef windows}
  lAdapter: PIP_ADAPTER_ADDRESSES;
  lBuffer: Pointer;
  lBufferSize: ULONG;
  lResult: DWORD;
  lUnicast: PIP_ADAPTER_UNICAST_ADDRESS;
  lSockAddr: PSockAddrIn;
  lPrefix: Integer;
{$endif}

  procedure AddSubnet(const ALocalIp: string; APrefix: Integer);
  begin
    if (APrefix < 8) or (APrefix > 30) or
       not TryIPv4ToUInt32(ALocalIp, lLocalValue) then Exit;
    if APrefix = 0 then lMask := 0
    else lMask := Cardinal($ffffffff) shl (32 - APrefix);
    lNetwork := lLocalValue and lMask;
    lBroadcast := lNetwork or (not lMask);
    lValue := lNetwork + 1;
    while (lValue < lBroadcast) and (lAdded < AMaximumHosts) do
    begin
      if lValue <> lLocalValue then
      begin
        lIp := UInt32ToIPv4(lValue);
        if AItems.IndexOf(lIp) < 0 then
        begin
          AItems.Add(lIp);
          Inc(lAdded);
        end;
      end;
      Inc(lValue);
    end;
  end;
{$ifdef windows}
  function PrefixForAddress(const ALocalIp: string): Integer;
  var
    lTable: PMIB_IPADDRTABLE;
    lRow: PMIB_IPADDRROW;
    lSize, lWanted, lMaskValue: DWORD;
    J: Integer;
  begin
    Result := 24;
    lSize := 0;
    if GetIpAddrTable(nil, lSize, False) <> ERROR_INSUFFICIENT_BUFFER then Exit;
    GetMem(lTable, lSize);
    try
      if GetIpAddrTable(lTable, lSize, False) <> NO_ERROR then Exit;
      lWanted := inet_addr(PChar(AnsiString(ALocalIp)));
      for J := 0 to Integer(lTable^.dwNumEntries) - 1 do
      begin
        lRow := PMIB_IPADDRROW(PByte(lTable) + SizeOf(DWORD) +
          J * SizeOf(MIB_IPADDRROW));
        if lRow^.dwAddr <> lWanted then Continue;
        Result := 0;
        lMaskValue := lRow^.dwMask;
        while lMaskValue <> 0 do
        begin
          Inc(Result, lMaskValue and 1);
          lMaskValue := lMaskValue shr 1;
        end;
        Exit;
      end;
    finally
      FreeMem(lTable);
    end;
  end;
{$endif}
begin
  if AItems = nil then Exit;
  AItems.Clear;
  lAdded := 0;
{$ifdef windows}
  lBuffer := nil;
  lBufferSize := 0;
  lResult := GetAdaptersAddresses(AF_INET, GAA_FLAG_SKIP_ANYCAST or
    GAA_FLAG_SKIP_MULTICAST or GAA_FLAG_SKIP_DNS_SERVER, nil, nil,
    @lBufferSize);
  if (lResult <> ERROR_BUFFER_OVERFLOW) or (lBufferSize = 0) then Exit;
  GetMem(lBuffer, lBufferSize);
  try
    lResult := GetAdaptersAddresses(AF_INET, GAA_FLAG_SKIP_ANYCAST or
      GAA_FLAG_SKIP_MULTICAST or GAA_FLAG_SKIP_DNS_SERVER, nil,
      PIP_ADAPTER_ADDRESSES(lBuffer), @lBufferSize);
    if lResult <> NO_ERROR then Exit;
    lAdapter := PIP_ADAPTER_ADDRESSES(lBuffer);
    while (lAdapter <> nil) and (lAdded < AMaximumHosts) do
    begin
      if lAdapter^.OperStatus = IfOperStatusUp then
      begin
        lUnicast := lAdapter^.FirstUnicastAddress;
        while (lUnicast <> nil) and (lAdded < AMaximumHosts) do
        begin
          if (lUnicast^.Address.lpSockaddr <> nil) and
             (lUnicast^.Address.lpSockaddr^.sa_family = AF_INET) then
          begin
            lSockAddr := PSockAddrIn(lUnicast^.Address.lpSockaddr);
            lIp := string(WinSock2.inet_ntoa(lSockAddr^.sin_addr));
            lPrefix := PrefixForAddress(lIp);
            if ((g_RecorderNetworkBindAddress = '') or
                SameText(lIp, g_RecorderNetworkBindAddress)) and
               (Pos('127.', lIp) <> 1) and (Pos('169.254.', lIp) <> 1) then
              AddSubnet(lIp, lPrefix);
          end;
          lUnicast := lUnicast^.Next;
        end;
      end;
      lAdapter := lAdapter^.Next;
    end;
  finally
    FreeMem(lBuffer);
  end;
{$else}
  { Portable fallback: a selected IPv4 is searched as a /24. }
  if g_RecorderNetworkBindAddress <> '' then
    AddSubnet(g_RecorderNetworkBindAddress, 24);
{$endif}
end;

procedure RecorderDiscoverMeraBroadcast(AFoundHosts: TStrings;
  ATimeoutMs: Cardinal);
{$ifdef windows}
const
  CModernRequest: AnsiString = 'MERA: MebiusDAQ devices search. [v.1]';
  CLegacyRequest: AnsiString = 'MERA:Eth81Srch';
  CModernPort = 4400;
  CLegacyPort = 4001;
var
  lWsa: TWSAData;
  lListenModern, lListenLegacy, lSendModern, lSendLegacy,
    lReadySocket: TSocket;
  lAddr, lFrom: TSockAddrIn;
  lFromLen, lOpt, lRead, lWait: LongInt;
  lReadSet: TFDSet;
  lTime: TTimeVal;
  lStarted, lNow, lLastNewReply: QWord;
  lBuffer: array[0..1023] of Byte;
  lHost: string;
  lDeviceKind, lSerial: string;
  lDeviceType: Cardinal;
  lLegacyType, lLegacySerial: Word;
  lDirectedBroadcast: u_long;

  function ReadLEWord(AOffset: Integer): Word;
  begin
    Result := Word(lBuffer[AOffset]) or (Word(lBuffer[AOffset + 1]) shl 8);
  end;

  function ReadLECardinal(AOffset: Integer): Cardinal;
  begin
    Result := Cardinal(lBuffer[AOffset]) or
      (Cardinal(lBuffer[AOffset + 1]) shl 8) or
      (Cardinal(lBuffer[AOffset + 2]) shl 16) or
      (Cardinal(lBuffer[AOffset + 3]) shl 24);
  end;

  function OpenListener(APort: Word): TSocket;
  var lLocal: TSockAddrIn;
  begin
    Result := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if Result = INVALID_SOCKET then Exit;
    lOpt := 1;
    setsockopt(Result, SOL_SOCKET, SO_REUSEADDR, @lOpt, SizeOf(lOpt));
    FillChar(lLocal, SizeOf(lLocal), 0);
    lLocal.sin_family := AF_INET;
    lLocal.sin_port := htons(APort + 1);
    lLocal.sin_addr.S_addr := INADDR_ANY;
    if WinSock2.bind(Result, @lLocal, SizeOf(lLocal)) <> 0 then
    begin
      closesocket(Result);
      Result := INVALID_SOCKET;
    end;
  end;

  function OpenSender(APort: Word): TSocket;
  var lLocal: TSockAddrIn;
  begin
    Result := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if Result = INVALID_SOCKET then Exit;
    lOpt := 1;
    setsockopt(Result, SOL_SOCKET, SO_BROADCAST, @lOpt, SizeOf(lOpt));
    FillChar(lLocal, SizeOf(lLocal), 0);
    lLocal.sin_family := AF_INET;
    lLocal.sin_port := htons(APort);
    if g_RecorderNetworkBindAddress = '' then
      lLocal.sin_addr.S_addr := INADDR_ANY
    else
      lLocal.sin_addr.S_addr := inet_addr(PChar(AnsiString(
        g_RecorderNetworkBindAddress)));
    if WinSock2.bind(Result, @lLocal, SizeOf(lLocal)) <> 0 then
    begin
      closesocket(Result);
      Result := INVALID_SOCKET;
    end;
  end;

  function DirectedBroadcastForBind: u_long;
  var
    lTable: PMIB_IPADDRTABLE;
    lRow: PMIB_IPADDRROW;
    lSize, lWanted: DWORD;
    J: Integer;
  begin
    Result := INADDR_BROADCAST;
    if g_RecorderNetworkBindAddress = '' then Exit;
    lSize := 0;
    if GetIpAddrTable(nil, lSize, False) <> ERROR_INSUFFICIENT_BUFFER then Exit;
    GetMem(lTable, lSize);
    try
      if GetIpAddrTable(lTable, lSize, False) <> NO_ERROR then Exit;
      lWanted := inet_addr(PChar(AnsiString(g_RecorderNetworkBindAddress)));
      for J := 0 to Integer(lTable^.dwNumEntries) - 1 do
      begin
        lRow := PMIB_IPADDRROW(PByte(lTable) + SizeOf(DWORD) +
          J * SizeOf(MIB_IPADDRROW));
        if lRow^.dwAddr = lWanted then
          Exit(lRow^.dwAddr or (not lRow^.dwMask));
      end;
    finally
      FreeMem(lTable);
    end;
  end;

  procedure SendRequest(ASocket: TSocket; APort: Word;
    const ARequest: AnsiString; ADestination: u_long);
  begin
    if ASocket = INVALID_SOCKET then Exit;
    FillChar(lAddr, SizeOf(lAddr), 0);
    lAddr.sin_family := AF_INET;
    lAddr.sin_port := htons(APort);
    lAddr.sin_addr.S_addr := ADestination;
    sendto(ASocket, @ARequest[1], Length(ARequest), 0, @lAddr, SizeOf(lAddr));
  end;
begin
  if AFoundHosts = nil then Exit;
  AFoundHosts.Clear;
  if WSAStartup($0202, lWsa) <> 0 then Exit;
  lListenModern := INVALID_SOCKET;
  lListenLegacy := INVALID_SOCKET;
  lSendModern := INVALID_SOCKET;
  lSendLegacy := INVALID_SOCKET;
  try
    lListenModern := OpenListener(CModernPort);
    lListenLegacy := OpenListener(CLegacyPort);
    lSendModern := OpenSender(CModernPort);
    lSendLegacy := OpenSender(CLegacyPort);
    lDirectedBroadcast := DirectedBroadcastForBind;
    SendRequest(lSendModern, CModernPort, CModernRequest, INADDR_BROADCAST);
    SendRequest(lSendLegacy, CLegacyPort, CLegacyRequest, INADDR_BROADCAST);
    if lDirectedBroadcast <> INADDR_BROADCAST then
    begin
      SendRequest(lSendModern, CModernPort, CModernRequest,
        lDirectedBroadcast);
      SendRequest(lSendLegacy, CLegacyPort, CLegacyRequest,
        lDirectedBroadcast);
    end;
    lStarted := GetTickCount64;
    lLastNewReply := 0;
    repeat
      lNow := GetTickCount64;
      if lNow - lStarted >= ATimeoutMs then Break;
      { Replies to one broadcast arrive as a compact group. Keep the original
        long upper bound for slow devices, but finish once a full second has
        passed without a new device after the first response. }
      if (lLastNewReply <> 0) and (lNow - lStarted >= 1600) and
         (lNow - lLastNewReply >= 1000) then Break;
      lWait := Integer(ATimeoutMs - (lNow - lStarted));
      if lWait > 100 then lWait := 100;
      FD_ZERO(lReadSet);
      if lListenModern <> INVALID_SOCKET then FD_SET(lListenModern, lReadSet);
      if lListenLegacy <> INVALID_SOCKET then FD_SET(lListenLegacy, lReadSet);
      lTime.tv_sec := 0;
      lTime.tv_usec := lWait * 1000;
      if WinSock2.select(0, @lReadSet, nil, nil, @lTime) <= 0 then Continue;
      if (lListenModern <> INVALID_SOCKET) and
         FD_ISSET(lListenModern, lReadSet) then lReadySocket := lListenModern
      else if (lListenLegacy <> INVALID_SOCKET) and
         FD_ISSET(lListenLegacy, lReadSet) then lReadySocket := lListenLegacy
      else Continue;
      lFromLen := SizeOf(lFrom);
      FillChar(lBuffer, SizeOf(lBuffer), 0);
      lRead := recvfrom(lReadySocket, @lBuffer[0], SizeOf(lBuffer), 0,
        @lFrom, @lFromLen);
      if lRead > 0 then
      begin
        lHost := string(inet_ntoa(lFrom.sin_addr));
        lDeviceKind := '';
        lSerial := '';
        if (lRead >= 32) and
           (AnsiChar(lBuffer[0]) = 'M') and (AnsiChar(lBuffer[1]) = 'e') and
           (AnsiChar(lBuffer[2]) = 'b') and (AnsiChar(lBuffer[3]) = 'D') and
           (AnsiChar(lBuffer[4]) = 'A') and (AnsiChar(lBuffer[5]) = 'Q') then
        begin
          { DETECT_DEVICE_INFO is naturally aligned: dev_type_ starts at 8. }
          lDeviceType := ReadLECardinal(8);
          case (lDeviceType shr 16) and $1ff of
            9, 34: lDeviceKind := 'MIC-140';
            10, 23, 25: lDeviceKind := 'MIC183/185';
          end;
          lSerial := Trim(PChar(@lBuffer[16]));
        end
        else if (lRead >= 24) and
          CompareMem(@lBuffer[0], PChar(CLegacyRequest), Length(CLegacyRequest)) then
        begin
          lLegacyType := ReadLEWord(18);
          lLegacySerial := ReadLEWord(22);
          case lLegacyType of
            12: lDeviceKind := 'MIC-140';
            $440e, $442a: lDeviceKind := 'MIC183/185';
          end;
          if lLegacySerial <> 0 then lSerial := IntToStr(lLegacySerial);
        end;
        if (lHost <> '') and (lDeviceKind <> '') and
           (AFoundHosts.IndexOfName(lHost) < 0) then
        begin
          AFoundHosts.Add(lHost + '=' + lDeviceKind + '|' + lSerial);
          lLastNewReply := GetTickCount64;
        end;
      end;
    until False;
  finally
    if lSendModern <> INVALID_SOCKET then closesocket(lSendModern);
    if lSendLegacy <> INVALID_SOCKET then closesocket(lSendLegacy);
    if lListenModern <> INVALID_SOCKET then closesocket(lListenModern);
    if lListenLegacy <> INVALID_SOCKET then closesocket(lListenLegacy);
    WSACleanup;
  end;
end;
{$else}
begin
  if AFoundHosts <> nil then AFoundHosts.Clear;
end;
{$endif}

function ResolveIPv4(const AHost: string; out AAddress: THostAddr): Boolean;
var
  lResolver: THostResolver;
begin
  AAddress := StrToHostAddr(AHost);
  Result := AAddress.s_addr <> 0;
  if Result then Exit;
  lResolver := THostResolver.Create(nil);
  try
    Result := lResolver.NameLookup(AHost);
    if Result then AAddress := lResolver.HostAddress;
  finally
    lResolver.Free;
  end;
end;

function RecorderOpenBoundTcpStream(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal; out AStream: TSocketStream;
  out AErrorText: string): Boolean;
var
  lRemote, lLocal: TInetSockAddr;
  lRemoteHost, lLocalHost: THostAddr;
  lSocket: LongInt;
  lErr, lErrLen, lRes: LongInt;
  lFds: TFDSet;
  lTime: TTimeVal;
{$ifdef unix}
  lFlags: LongInt;
{$endif}
{$ifdef windows}
  lMode: DWord;
{$endif}
begin
  Result := False;
  AStream := nil;
  AErrorText := '';
  lSocket := -1;
  try
    if not ResolveIPv4(AHost, lRemoteHost) then
    begin
      AErrorText := 'Не удалось определить адрес узла ' + AHost;
      Exit;
    end;
    lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
    if lSocket < 0 then
    begin
      AErrorText := 'Не удалось создать TCP-сокет: ' + IntToStr(SocketError);
      Exit;
    end;
    if g_RecorderNetworkBindAddress <> '' then
    begin
      lLocalHost := StrToHostAddr(g_RecorderNetworkBindAddress);
      FillChar(lLocal, SizeOf(lLocal), 0);
      lLocal.sin_family := AF_INET;
      lLocal.sin_port := 0;
      lLocal.sin_addr.s_addr := HostToNet(lLocalHost.s_addr);
      if fpBind(lSocket, @lLocal, SizeOf(lLocal)) <> 0 then
      begin
        AErrorText := Format('Не удалось привязать сокет к %s: %d',
          [g_RecorderNetworkBindAddress, SocketError]);
        Exit;
      end;
    end;
{$ifdef unix}
    lFlags := fpFcntl(lSocket, F_GetFl, 0);
    fpFcntl(lSocket, F_SetFl, lFlags or O_NONBLOCK);
{$endif}
{$ifdef windows}
    lMode := 1;
    ioctlsocket(lSocket, LongInt(FIONBIO), @lMode);
{$endif}
    FillChar(lRemote, SizeOf(lRemote), 0);
    lRemote.sin_family := AF_INET;
    lRemote.sin_port := ShortHostToNet(APort);
    lRemote.sin_addr.s_addr := HostToNet(lRemoteHost.s_addr);
    if fpConnect(lSocket, @lRemote, SizeOf(lRemote)) <> 0 then
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
      lTime.tv_sec := ATimeoutMs div 1000;
      lTime.tv_usec := (ATimeoutMs mod 1000) * 1000;
{$ifdef unix}
      lRes := fpSelect(lSocket + 1, nil, @lFds, nil, @lTime);
{$endif}
{$ifdef windows}
      lRes := WinSock2.select(lSocket + 1, nil, @lFds, nil, @lTime);
{$endif}
      if lRes <= 0 then
      begin
        if lRes = 0 then AErrorText := 'Истекло время TCP-подключения'
        else AErrorText := 'Ошибка ожидания TCP-подключения: ' + IntToStr(SocketError);
        Exit;
      end;
      lErr := 0;
      lErrLen := SizeOf(lErr);
      fpGetSockOpt(lSocket, SOL_SOCKET, SO_ERROR, @lErr, @lErrLen);
      if lErr <> 0 then
      begin
        AErrorText := 'Ошибка TCP-подключения: ' + IntToStr(lErr);
        Exit;
      end;
    end;
{$ifdef unix}
    fpFcntl(lSocket, F_SetFl, lFlags and (not O_NONBLOCK));
{$endif}
{$ifdef windows}
    lMode := 0;
    ioctlsocket(lSocket, LongInt(FIONBIO), @lMode);
{$endif}
    AStream := TSocketStream.Create(lSocket);
    AStream.IOTimeout := Integer(ATimeoutMs);
    lSocket := -1;
    Result := True;
  finally
    if lSocket >= 0 then CloseSocket(lSocket);
  end;
end;

end.
