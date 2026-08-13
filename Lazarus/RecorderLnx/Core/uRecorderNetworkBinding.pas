unit uRecorderNetworkBinding;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, ctypes, Sockets, ssockets;

const
  CRecorderNetworkAutomatic = '';

type
  TRecorderSocketSetup = procedure(ASocket: LongInt);

function RecorderNetworkBindAddress: string;
procedure SetRecorderNetworkBindAddress(const AValue: string);
procedure RecorderEnumerateLocalIPv4(AItems: TStrings);
function RecorderNetworkAddressFromDisplay(const AValue: string): string;
procedure RecorderSetNetworkDebugLogFile(const AFileName: string);
procedure RecorderEnumerateArpIPv4(AItems: TStrings);
function RecorderTcpPortOpen(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
procedure RecorderFindOpenTcpHosts(ACandidates, AFound: TStrings;
  APort: Word; ATimeoutMs: Cardinal);
procedure RecorderEnumerateDiscoveryIPv4(AItems: TStrings;
  AMaximumHosts: Integer = 65534);
procedure RecorderDiscoverMeraBroadcast(AFoundHosts: TStrings;
  ATimeoutMs: Cardinal = 1200);
function RecorderProbeMeraLegacyHost(const AHost: string; out AKind: string;
  out ASerial: string; ATimeoutMs: Cardinal = 300): Boolean;
function RecorderOpenBoundTcpStream(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal; out AStream: TSocketStream;
  out AErrorText: string; AUseConfiguredBind: Boolean = True;
  ABeforeConnect: TRecorderSocketSetup = nil): Boolean;

implementation

uses
  Resolve, StrUtils, uRecorderDebugLog
  {$ifdef unix}, BaseUnix{$endif}
  {$ifdef windows}, Windows, WinSock2, JwaIpHlpApi, JwaIpTypes,
    JwaIpRtrMib{$endif};

var
  g_RecorderNetworkBindAddress: string = '';
  g_RecorderNetworkDebugLogFile: string = '';

procedure NetworkDebugLog(const AMessage: string);
var
  lFile: TextFile;
begin
  RecorderDebugLog(AMessage);
  if g_RecorderNetworkDebugLogFile = '' then Exit;
  try
    AssignFile(lFile, g_RecorderNetworkDebugLogFile);
    if FileExists(g_RecorderNetworkDebugLogFile) then
      Append(lFile)
    else
      Rewrite(lFile);
    try
      Writeln(lFile, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz ', Now) +
        AMessage);
    finally
      CloseFile(lFile);
    end;
  except
  end;
end;

function RecorderNetworkBindAddress: string;
begin
  Result := g_RecorderNetworkBindAddress;
end;

procedure RecorderSetNetworkDebugLogFile(const AFileName: string);
begin
  g_RecorderNetworkDebugLogFile := AFileName;
end;

{$ifdef unix}
function IsLocalIPv4(const AValue: string): Boolean;
var
  lAddress: TInetSockAddr;
  lSocket: cint;
begin
  Result := False;
  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket < 0 then Exit;
  try
    FillChar(lAddress, SizeOf(lAddress), 0);
    lAddress.sin_family := AF_INET;
    lAddress.sin_addr := StrToHostAddr(AValue);
    Result := fpBind(lSocket, @lAddress, SizeOf(lAddress)) = 0;
  finally
    fpClose(lSocket);
  end;
end;
{$endif}

{$ifdef windows}
function IsLocalIPv4(const AValue: string): Boolean;
var
  lTable: PMIB_IPADDRTABLE;
  lSize, lWanted: DWORD;
  I: Integer;
begin
  Result := False;
  lWanted := inet_addr(PChar(AnsiString(AValue)));
  if lWanted = INADDR_NONE then Exit;
  lSize := 0;
  if GetIpAddrTable(nil, lSize, False) <> ERROR_INSUFFICIENT_BUFFER then Exit;
  GetMem(lTable, lSize);
  try
    if GetIpAddrTable(lTable, lSize, False) <> NO_ERROR then Exit;
    for I := 0 to Integer(lTable^.dwNumEntries) - 1 do
      if lTable^.table[I].dwAddr = lWanted then Exit(True);
  finally
    FreeMem(lTable);
  end;
end;
{$endif}

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
  { Проект может быть общим с Windows. Чужой адрес интерфейса нельзя явно
    привязывать в Linux: в этом случае маршрут выбирает ОС. }
  if not IsLocalIPv4(HostAddrToStr(lAddress)) then
  begin
    g_RecorderNetworkBindAddress := '';
    NetworkDebugLog(Format('[Network] bind address %s is not local, using OS routing',
      [HostAddrToStr(lAddress)]));
    Exit;
  end;
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

procedure RecorderEnumerateArpIPv4(AItems: TStrings);
{$ifdef windows}
var
  lNetTable: PMIB_IPNETTABLE;
  lAddrTable: PMIB_IPADDRTABLE;
  lNetSize, lAddrSize, lWanted, lWantedIndex: DWORD;
  I: Integer;
  lIn: TInAddr;
  lIp: string;
begin
  if AItems = nil then Exit;
  AItems.Clear;
  lWantedIndex := 0;
  lWanted := 0;
  if g_RecorderNetworkBindAddress <> '' then
  begin
    lWanted := inet_addr(PChar(AnsiString(g_RecorderNetworkBindAddress)));
    lAddrSize := 0;
    if GetIpAddrTable(nil, lAddrSize, False) = ERROR_INSUFFICIENT_BUFFER then
    begin
      GetMem(lAddrTable, lAddrSize);
      try
        if GetIpAddrTable(lAddrTable, lAddrSize, False) = NO_ERROR then
          for I := 0 to Integer(lAddrTable^.dwNumEntries) - 1 do
            if lAddrTable^.table[I].dwAddr = lWanted then
            begin
              lWantedIndex := lAddrTable^.table[I].dwIndex;
              Break;
            end;
      finally
        FreeMem(lAddrTable);
      end;
    end;
  end;

  lNetSize := 0;
  if GetIpNetTable(nil, lNetSize, False) <> ERROR_INSUFFICIENT_BUFFER then Exit;
  GetMem(lNetTable, lNetSize);
  try
    if GetIpNetTable(lNetTable, lNetSize, False) <> NO_ERROR then Exit;
    for I := 0 to Integer(lNetTable^.dwNumEntries) - 1 do
    begin
      if (lWantedIndex <> 0) and
        (lNetTable^.table[I].dwIndex <> lWantedIndex) then Continue;
      if lNetTable^.table[I].dwType <> MIB_IPNET_TYPE_DYNAMIC then Continue;
      if (lNetTable^.table[I].dwAddr = 0) or
        (lNetTable^.table[I].dwAddr = lWanted) then Continue;
      lIn.S_addr := lNetTable^.table[I].dwAddr;
      lIp := string(inet_ntoa(lIn));
      if (lIp <> '') and (Pos('224.', lIp) <> 1) and
        (AItems.IndexOf(lIp) < 0) then AItems.Add(lIp);
    end;
    NetworkDebugLog(Format('[HardwareSearch] ARP candidates: %d bind="%s"',
      [AItems.Count, g_RecorderNetworkBindAddress]));
  finally
    FreeMem(lNetTable);
  end;
end;
{$else}
begin
  if AItems <> nil then AItems.Clear;
end;
{$endif}

function RecorderTcpPortOpen(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
{$ifdef windows}
var
  lRemote, lLocal: TSockAddrIn;
  lBlockMode: u_long;
  lError, lErrorLen: LongInt;
  lHost: string;
  lIp, lLocalIp: u_long;
  lSocket: TSocket;
  lTimeVal: TTimeVal;
  lWriteSet: TFDSet;
  lWsa: TWSAData;
begin
  Result := False;
  lHost := Trim(AHost);
  if lHost = '' then Exit;
  if WSAStartup($0202, lWsa) <> 0 then Exit;
  try
    lIp := inet_addr(PChar(AnsiString(lHost)));
    if lIp = INADDR_NONE then Exit;
    lSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if lSocket = INVALID_SOCKET then Exit;
    try
      if g_RecorderNetworkBindAddress <> '' then
      begin
        lLocalIp := inet_addr(PChar(AnsiString(g_RecorderNetworkBindAddress)));
        if lLocalIp = INADDR_NONE then Exit;
        FillChar(lLocal, SizeOf(lLocal), 0);
        lLocal.sin_family := AF_INET;
        lLocal.sin_port := 0;
        lLocal.sin_addr.S_addr := lLocalIp;
        if WinSock2.bind(lSocket, @lLocal, SizeOf(lLocal)) <> 0 then Exit;
      end;

      lBlockMode := 1;
      if ioctlsocket(lSocket, LongInt(FIONBIO), lBlockMode) <> 0 then Exit;

      FillChar(lRemote, SizeOf(lRemote), 0);
      lRemote.sin_family := AF_INET;
      lRemote.sin_port := htons(APort);
      lRemote.sin_addr.S_addr := lIp;
      if WinSock2.connect(lSocket, @lRemote, SizeOf(lRemote)) = 0 then
        Exit(True);
      lError := WSAGetLastError;
      if (lError <> WSAEWOULDBLOCK) and (lError <> WSAEINPROGRESS) then Exit;

      FillChar(lTimeVal, SizeOf(lTimeVal), 0);
      lTimeVal.tv_sec := ATimeoutMs div 1000;
      lTimeVal.tv_usec := (ATimeoutMs mod 1000) * 1000;
      FD_ZERO(lWriteSet);
      FD_SET(lSocket, lWriteSet);
      if WinSock2.select(0, nil, @lWriteSet, nil, @lTimeVal) <= 0 then Exit;
      if not FD_ISSET(lSocket, lWriteSet) then Exit;

      lError := -1;
      lErrorLen := SizeOf(lError);
      if getsockopt(lSocket, SOL_SOCKET, SO_ERROR, lError, lErrorLen) <> 0 then
        Exit;
      Result := lError = 0;
    finally
      closesocket(lSocket);
    end;
  finally
    WSACleanup;
  end;
end;
{$else}
var
  lStream: TSocketStream;
  lErrorText: string;
begin
  Result := False;
  Result := RecorderOpenBoundTcpStream(AHost, APort, ATimeoutMs, lStream,
    lErrorText);
  lStream.Free;
end;
{$endif}

procedure RecorderFindOpenTcpHosts(ACandidates, AFound: TStrings;
  APort: Word; ATimeoutMs: Cardinal);
var
  I: Integer;
  lHost: string;
begin
  if (ACandidates = nil) or (AFound = nil) then Exit;
  AFound.Clear;
  for I := 0 to ACandidates.Count - 1 do
  begin
    lHost := Trim(ACandidates[I]);
    if (lHost <> '') and (AFound.IndexOf(lHost) < 0) and
      RecorderTcpPortOpen(lHost, APort, ATimeoutMs) then
      AFound.Add(lHost);
  end;
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
  CMic140_96Type = $412D;
  CMic140_48Type = $413C;
  CMic140_48EthernetType = $413D;
  CMic140_48V2Type = $413E;
  CMic140_48V2EthernetType = $413F;
  CMic140_48V3Type = $4140;
  CMic140_48V3EthernetType = $4141;
  CMic140_96V3Type = $4142;
  CMic140_96V3EthernetType = $4143;
  CMic140_96V5Type = $4144;
  CMic140MebiusDeviceType = $02090000;
  CMic140V2MebiusDeviceType = $02220000;
  CMic183MebiusDeviceType = $020A0000;
  CMic185V2MebiusDeviceType = $02190000;
  CMic140DeviceType = $440C;
  CMic140_96V2DeviceType = $4417;
  CMic140_16V2DeviceType = $442F;
  CMic183DeviceType = $440E;
  CMic185V2DeviceType = $442A;
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
  lHost, lDeviceIpText: string;
  lDeviceKind, lSerial: string;
  lDeviceType, lDeviceIp: Cardinal;
  lLegacyType, lLegacySerial, lLegacyCCSerial: Word;
  lDirectedBroadcast: u_long;
  lLocalSendIps: TStringList;

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

  function IPv4FromLECardinal(AValue: Cardinal): string;
  begin
    if AValue = 0 then Exit('');
    Result := Format('%d.%d.%d.%d', [
      AValue and $ff,
      (AValue shr 8) and $ff,
      (AValue shr 16) and $ff,
      (AValue shr 24) and $ff]);
  end;

  function ReadFixedAnsi(AOffset, ASize: Integer): string;
  var
    lCount: Integer;
  begin
    Result := '';
    lCount := 0;
    while (lCount < ASize) and (AOffset + lCount < lRead) and
      (lBuffer[AOffset + lCount] <> 0) do Inc(lCount);
    if lCount > 0 then
      SetString(Result, PAnsiChar(@lBuffer[AOffset]), lCount);
    Result := Trim(Result);
  end;

  function SocketErrorText(const AAction: string): string;
  begin
    Result := Format('%s failed: WSA=%d', [AAction, WSAGetLastError]);
  end;

  function IPv4FromSocketValue(AValue: u_long): string;
  var
    lIn: TInAddr;
  begin
    lIn.S_addr := AValue;
    Result := string(inet_ntoa(lIn));
  end;

  function OpenListener(APort: Word): TSocket;
  var
    lLocal: TSockAddrIn;
    lBindIp: u_long;
  begin
    Result := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if Result = INVALID_SOCKET then
    begin
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('socket listener/%d', [APort + 1])));
      Exit;
    end;
    lOpt := 1;
    setsockopt(Result, SOL_SOCKET, SO_REUSEADDR, @lOpt, SizeOf(lOpt));
    setsockopt(Result, SOL_SOCKET, SO_BROADCAST, @lOpt, SizeOf(lOpt));
    FillChar(lLocal, SizeOf(lLocal), 0);
    lLocal.sin_family := AF_INET;
    lLocal.sin_port := htons(APort + 1);
    if g_RecorderNetworkBindAddress = '' then
      lLocal.sin_addr.S_addr := INADDR_ANY
    else
      lLocal.sin_addr.S_addr := inet_addr(PChar(AnsiString(
        g_RecorderNetworkBindAddress)));
    if WinSock2.bind(Result, @lLocal, SizeOf(lLocal)) <> 0 then
    begin
      lBindIp := lLocal.sin_addr.S_addr;
      if lBindIp <> INADDR_ANY then
      begin
        NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
          Format('bind listener/%s:%d',
          [IPv4FromSocketValue(lBindIp), APort + 1])) +
          '; trying 0.0.0.0');
        FillChar(lLocal, SizeOf(lLocal), 0);
        lLocal.sin_family := AF_INET;
        lLocal.sin_port := htons(APort + 1);
        lLocal.sin_addr.S_addr := INADDR_ANY;
        if WinSock2.bind(Result, @lLocal, SizeOf(lLocal)) = 0 then
        begin
          NetworkDebugLog(Format('[HardwareSearch] listener bound to %s:%d',
            [IPv4FromSocketValue(lLocal.sin_addr.S_addr), APort + 1]));
          Exit;
        end;
      end;
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('bind listener/%s:%d',
        [IPv4FromSocketValue(lLocal.sin_addr.S_addr), APort + 1])));
      closesocket(Result);
      Result := INVALID_SOCKET;
      Exit;
    end;
    NetworkDebugLog(Format('[HardwareSearch] listener bound to %s:%d',
      [IPv4FromSocketValue(lLocal.sin_addr.S_addr), APort + 1]));
  end;

  function OpenSender(APort: Word): TSocket;
  var lLocal: TSockAddrIn;
  begin
    Result := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if Result = INVALID_SOCKET then
    begin
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('socket sender/%d', [APort])));
      Exit;
    end;
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
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('bind sender/%s:%d',
        [IPv4FromSocketValue(lLocal.sin_addr.S_addr), APort])));
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
  var
    lSent: LongInt;
  begin
    if ASocket = INVALID_SOCKET then Exit;
    FillChar(lAddr, SizeOf(lAddr), 0);
    lAddr.sin_family := AF_INET;
    lAddr.sin_port := htons(APort);
    lAddr.sin_addr.S_addr := ADestination;
    lSent := sendto(ASocket, @ARequest[1], Length(ARequest), 0, @lAddr,
      SizeOf(lAddr));
    if lSent = SOCKET_ERROR then
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('sendto broadcast/%d', [APort])))
    else
      NetworkDebugLog(Format('[HardwareSearch] sent %d byte(s) to %s:%d',
        [lSent, IPv4FromSocketValue(ADestination), APort]));
  end;

  procedure SendRequestFromReplySocket(ASocket: TSocket; APort: Word;
    const ARequest: AnsiString; ADestination: u_long);
  var
    lSent: LongInt;
  begin
    if ASocket = INVALID_SOCKET then Exit;
    FillChar(lAddr, SizeOf(lAddr), 0);
    lAddr.sin_family := AF_INET;
    lAddr.sin_port := htons(APort);
    lAddr.sin_addr.S_addr := ADestination;
    lSent := sendto(ASocket, @ARequest[1], Length(ARequest), 0, @lAddr,
      SizeOf(lAddr));
    if lSent = SOCKET_ERROR then
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('sendto reply-socket broadcast/%d', [APort])))
    else
      NetworkDebugLog(Format('[HardwareSearch] reply-socket sent %d byte(s) from port %d to %s:%d',
        [lSent, APort + 1, IPv4FromSocketValue(ADestination), APort]));
  end;

  procedure AddLocalSendIp(const AValue: string);
  begin
    if (AValue <> '') and (AValue <> '0.0.0.0') and
       (lLocalSendIps.IndexOf(AValue) < 0) then
      lLocalSendIps.Add(AValue);
  end;

  procedure CollectOriginalStyleSendIps;
  var
    I: Integer;
    lItems: TStringList;
    lText, lIp: string;
  begin
    lLocalSendIps.Clear;
    if g_RecorderNetworkBindAddress <> '' then
    begin
      AddLocalSendIp(g_RecorderNetworkBindAddress);
      Exit;
    end;
    lItems := TStringList.Create;
    try
      RecorderEnumerateLocalIPv4(lItems);
      for I := 0 to lItems.Count - 1 do
      begin
        lText := lItems[I];
        lIp := RecorderNetworkAddressFromDisplay(lText);
        if lIp <> '' then
          AddLocalSendIp(lIp);
      end;
    finally
      lItems.Free;
    end;
  end;

  procedure SendOriginalStyleBroadcast(APort: Word; const ARequest: AnsiString;
    const ALocalIp: string; ADestination: u_long);
  var
    lSocket: TSocket;
    lLocal: TSockAddrIn;
    lSent: LongInt;
  begin
    lSocket := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if lSocket = INVALID_SOCKET then
    begin
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('socket original sender/%d', [APort])));
      Exit;
    end;
    try
      lOpt := 1;
      setsockopt(lSocket, SOL_SOCKET, SO_BROADCAST, @lOpt, SizeOf(lOpt));
      FillChar(lLocal, SizeOf(lLocal), 0);
      lLocal.sin_family := AF_INET;
      lLocal.sin_port := htons(APort);
      if ALocalIp = '' then
        lLocal.sin_addr.S_addr := INADDR_ANY
      else
        lLocal.sin_addr.S_addr := inet_addr(PChar(AnsiString(ALocalIp)));
      if WinSock2.bind(lSocket, @lLocal, SizeOf(lLocal)) <> 0 then
      begin
        NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
          Format('bind original sender/%s:%d',
          [IPv4FromSocketValue(lLocal.sin_addr.S_addr), APort])));
        Exit;
      end;
      FillChar(lAddr, SizeOf(lAddr), 0);
      lAddr.sin_family := AF_INET;
      lAddr.sin_port := htons(APort);
      lAddr.sin_addr.S_addr := ADestination;
      lSent := sendto(lSocket, @ARequest[1], Length(ARequest), 0, @lAddr,
        SizeOf(lAddr));
      if lSent = SOCKET_ERROR then
        NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
          Format('sendto original broadcast/%s:%d',
          [IPv4FromSocketValue(lLocal.sin_addr.S_addr), APort])))
      else
        NetworkDebugLog(Format('[HardwareSearch] original-style sent %d byte(s) from %s:%d to %s:%d',
          [lSent, IPv4FromSocketValue(lLocal.sin_addr.S_addr), APort,
          IPv4FromSocketValue(ADestination), APort]));
    finally
      shutdown(lSocket, SD_BOTH);
      closesocket(lSocket);
    end;
  end;

  procedure SendOriginalStyleRequests;
  var
    I: Integer;
  begin
    SendRequestFromReplySocket(lListenModern, CModernPort, CModernRequest,
      INADDR_BROADCAST);
    SendRequestFromReplySocket(lListenLegacy, CLegacyPort, CLegacyRequest,
      INADDR_BROADCAST);
    if lDirectedBroadcast <> INADDR_BROADCAST then
    begin
      SendRequestFromReplySocket(lListenModern, CModernPort, CModernRequest,
        lDirectedBroadcast);
      SendRequestFromReplySocket(lListenLegacy, CLegacyPort, CLegacyRequest,
        lDirectedBroadcast);
    end;
    CollectOriginalStyleSendIps;
    if lLocalSendIps.Count = 0 then
    begin
      SendOriginalStyleBroadcast(CModernPort, CModernRequest, '',
        INADDR_BROADCAST);
      SendOriginalStyleBroadcast(CLegacyPort, CLegacyRequest, '',
        INADDR_BROADCAST);
      Exit;
    end;
    for I := 0 to lLocalSendIps.Count - 1 do
    begin
      SendOriginalStyleBroadcast(CModernPort, CModernRequest,
        lLocalSendIps[I], INADDR_BROADCAST);
      SendOriginalStyleBroadcast(CLegacyPort, CLegacyRequest,
        lLocalSendIps[I], INADDR_BROADCAST);
      if lDirectedBroadcast <> INADDR_BROADCAST then
      begin
        SendOriginalStyleBroadcast(CModernPort, CModernRequest,
          lLocalSendIps[I], lDirectedBroadcast);
        SendOriginalStyleBroadcast(CLegacyPort, CLegacyRequest,
          lLocalSendIps[I], lDirectedBroadcast);
      end;
    end;
  end;
begin
  if AFoundHosts = nil then Exit;
  AFoundHosts.Clear;
  if WSAStartup($0202, lWsa) <> 0 then
  begin
    NetworkDebugLog('[HardwareSearch] WSAStartup failed');
    Exit;
  end;
  lListenModern := INVALID_SOCKET;
  lListenLegacy := INVALID_SOCKET;
  lSendModern := INVALID_SOCKET;
  lSendLegacy := INVALID_SOCKET;
  lLocalSendIps := TStringList.Create;
  try
    lLocalSendIps.CaseSensitive := False;
    lLocalSendIps.Sorted := True;
    lLocalSendIps.Duplicates := dupIgnore;
    lListenModern := OpenListener(CModernPort);
    lListenLegacy := OpenListener(CLegacyPort);
    lDirectedBroadcast := DirectedBroadcastForBind;
    NetworkDebugLog(Format('[HardwareSearch] discovery start bind="%s" directed=%s timeout=%d modernListen=%d legacyListen=%d sendMode=original-broadcast',
      [g_RecorderNetworkBindAddress, IPv4FromSocketValue(lDirectedBroadcast),
      ATimeoutMs,
      Ord(lListenModern <> INVALID_SOCKET),
      Ord(lListenLegacy <> INVALID_SOCKET)]));
    SendOriginalStyleRequests;
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
      lRead := WinSock2.select(0, @lReadSet, nil, nil, @lTime);
      if lRead = SOCKET_ERROR then
      begin
        NetworkDebugLog('[HardwareSearch] ' + SocketErrorText('select'));
        Continue;
      end;
      if lRead <= 0 then Continue;
      if (lListenModern <> INVALID_SOCKET) and
         FD_ISSET(lListenModern, lReadSet) then lReadySocket := lListenModern
      else if (lListenLegacy <> INVALID_SOCKET) and
         FD_ISSET(lListenLegacy, lReadSet) then lReadySocket := lListenLegacy
      else Continue;
      lFromLen := SizeOf(lFrom);
      FillChar(lBuffer, SizeOf(lBuffer), 0);
      lRead := recvfrom(lReadySocket, @lBuffer[0], SizeOf(lBuffer), 0,
        @lFrom, @lFromLen);
      if lRead = SOCKET_ERROR then
      begin
        NetworkDebugLog('[HardwareSearch] ' + SocketErrorText('recvfrom'));
        Continue;
      end;
      if lRead > 0 then
      begin
        lHost := string(inet_ntoa(lFrom.sin_addr));
        NetworkDebugLog(Format('[HardwareSearch] received %d byte(s) from %s',
          [lRead, lHost]));
        lDeviceKind := '';
        lSerial := '';
        if (lRead >= 32) and
           (AnsiChar(lBuffer[0]) = 'M') and (AnsiChar(lBuffer[1]) = 'e') and
           (AnsiChar(lBuffer[2]) = 'b') and (AnsiChar(lBuffer[3]) = 'D') and
           (AnsiChar(lBuffer[4]) = 'A') and (AnsiChar(lBuffer[5]) = 'Q') then
        begin
          { DETECT_DEVICE_INFO is naturally aligned: dev_type_ starts at 8. }
          lDeviceType := ReadLECardinal(8);
          lDeviceIp := ReadLECardinal(12);
          case lDeviceType of
            CMic140_96Type, CMic140_48Type, CMic140_48V2Type,
            CMic140_48V3Type, CMic140_96V3Type, CMic140_96V5Type,
            CMic140_48EthernetType, CMic140_48V2EthernetType,
            CMic140_48V3EthernetType, CMic140_96V3EthernetType,
            CMic140DeviceType, CMic140_96V2DeviceType,
            CMic140_16V2DeviceType, CMic140MebiusDeviceType,
            CMic140V2MebiusDeviceType: lDeviceKind := 'MIC-140';
            CMic183DeviceType, CMic185V2DeviceType, CMic183MebiusDeviceType,
            CMic185V2MebiusDeviceType: lDeviceKind := 'MIC183/185';
          end;
          lDeviceIpText := IPv4FromLECardinal(lDeviceIp);
          if lDeviceIpText <> '' then lHost := lDeviceIpText;
          lSerial := ReadFixedAnsi(16, 16);
          if lDeviceKind = '' then
            NetworkDebugLog(Format('[HardwareSearch] ignored modern broadcast: host=%s type=$%x bytes=%d',
              [lHost, lDeviceType, lRead]));
        end
        else if (lRead >= 24) and
          CompareMem(@lBuffer[0], PChar(CLegacyRequest), Length(CLegacyRequest)) then
        begin
          lLegacyType := ReadLEWord(18);
          lLegacySerial := ReadLEWord(22);
          lLegacyCCSerial := 0;
          if lRead >= 28 then
            lLegacyCCSerial := ReadLEWord(26);
          case lLegacyType of
            12, CMic140_96Type, CMic140_48Type, CMic140_48EthernetType,
            CMic140_48V2Type, CMic140_48V2EthernetType, CMic140_48V3Type,
            CMic140_48V3EthernetType, CMic140_96V3Type,
            CMic140_96V3EthernetType, CMic140_96V5Type,
            CMic140DeviceType, CMic140_96V2DeviceType,
            CMic140_16V2DeviceType: lDeviceKind := 'MIC-140';
            $440e, $442a: lDeviceKind := 'MIC183/185';
          end;
          if lLegacyCCSerial <> 0 then
            lSerial := IntToStr(lLegacyCCSerial)
          else if lLegacySerial <> 0 then
            lSerial := IntToStr(lLegacySerial);
          if lDeviceKind = '' then
            NetworkDebugLog(Format('[HardwareSearch] ignored legacy broadcast: host=%s type=$%x bytes=%d',
              [lHost, lLegacyType, lRead]));
        end;
        if (lHost <> '') and (lDeviceKind <> '') and
           (AFoundHosts.IndexOfName(lHost) < 0) then
        begin
          AFoundHosts.Add(lHost + '=' + lDeviceKind + '|' + lSerial);
          lLastNewReply := GetTickCount64;
        end;
      end;
    until False;
    NetworkDebugLog(Format('[HardwareSearch] discovery finished: %d device(s)',
      [AFoundHosts.Count]));
  finally
    lLocalSendIps.Free;
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

function RecorderProbeMeraLegacyHost(const AHost: string; out AKind: string;
  out ASerial: string; ATimeoutMs: Cardinal): Boolean;
{$ifdef windows}
const
  CLegacyRequest: AnsiString = 'MERA:Eth81Srch';
  CLegacyPort = 4001;
  CMic140_96Type = $412D;
  CMic140_48Type = $413C;
  CMic140_48EthernetType = $413D;
  CMic140_48V2Type = $413E;
  CMic140_48V2EthernetType = $413F;
  CMic140_48V3Type = $4140;
  CMic140_48V3EthernetType = $4141;
  CMic140_96V3Type = $4142;
  CMic140_96V3EthernetType = $4143;
  CMic140_96V5Type = $4144;
  CMic140DeviceType = $440C;
  CMic140_96V2DeviceType = $4417;
  CMic140_16V2DeviceType = $442F;
  CMic183DeviceType = $440E;
  CMic185V2DeviceType = $442A;
var
  lWsa: TWSAData;
  lListen, lSend: TSocket;
  lLocal, lRemote, lFrom: TSockAddrIn;
  lFromLen, lOpt, lRead, lWait: LongInt;
  lReadSet: TFDSet;
  lTime: TTimeVal;
  lStarted, lNow: QWord;
  lBuffer: array[0..127] of Byte;
  lHost: string;
  lDeviceType, lSerial, lCCSerial: Word;

  function ReadLEWord(AOffset: Integer): Word;
  begin
    Result := Word(lBuffer[AOffset]) or (Word(lBuffer[AOffset + 1]) shl 8);
  end;

  function IPv4FromSocketValue(AValue: u_long): string;
  var
    lIn: TInAddr;
  begin
    lIn.S_addr := AValue;
    Result := string(inet_ntoa(lIn));
  end;

  function SocketErrorText(const AAction: string): string;
  begin
    Result := Format('%s failed: WSA=%d', [AAction, WSAGetLastError]);
  end;
begin
  Result := False;
  AKind := '';
  ASerial := '';
  if Trim(AHost) = '' then Exit;
  if WSAStartup($0202, lWsa) <> 0 then Exit;
  lListen := INVALID_SOCKET;
  lSend := INVALID_SOCKET;
  try
    lListen := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if lListen = INVALID_SOCKET then Exit;
    lOpt := 1;
    setsockopt(lListen, SOL_SOCKET, SO_REUSEADDR, @lOpt, SizeOf(lOpt));
    FillChar(lLocal, SizeOf(lLocal), 0);
    lLocal.sin_family := AF_INET;
    lLocal.sin_port := htons(CLegacyPort + 1);
    lLocal.sin_addr.S_addr := INADDR_ANY;
    if WinSock2.bind(lListen, @lLocal, SizeOf(lLocal)) <> 0 then
    begin
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        'bind legacy directed listener/4002'));
      Exit;
    end;

    lSend := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if lSend = INVALID_SOCKET then Exit;
    FillChar(lLocal, SizeOf(lLocal), 0);
    lLocal.sin_family := AF_INET;
    lLocal.sin_port := htons(CLegacyPort);
    if g_RecorderNetworkBindAddress = '' then
      lLocal.sin_addr.S_addr := INADDR_ANY
    else
      lLocal.sin_addr.S_addr := inet_addr(PChar(AnsiString(
        g_RecorderNetworkBindAddress)));
    if WinSock2.bind(lSend, @lLocal, SizeOf(lLocal)) <> 0 then
    begin
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('bind legacy directed sender/%s:4001',
        [IPv4FromSocketValue(lLocal.sin_addr.S_addr)])));
      Exit;
    end;

    FillChar(lRemote, SizeOf(lRemote), 0);
    lRemote.sin_family := AF_INET;
    lRemote.sin_port := htons(CLegacyPort);
    lRemote.sin_addr.S_addr := inet_addr(PChar(AnsiString(AHost)));
    if lRemote.sin_addr.S_addr = INADDR_NONE then Exit;
    if sendto(lSend, @CLegacyRequest[1], Length(CLegacyRequest), 0,
      @lRemote, SizeOf(lRemote)) = SOCKET_ERROR then
    begin
      NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
        Format('sendto legacy directed %s:4001', [AHost])));
      Exit;
    end;

    lStarted := GetTickCount64;
    repeat
      lNow := GetTickCount64;
      if lNow - lStarted >= ATimeoutMs then Break;
      lWait := Integer(ATimeoutMs - (lNow - lStarted));
      if lWait > 50 then lWait := 50;
      FD_ZERO(lReadSet);
      FD_SET(lListen, lReadSet);
      lTime.tv_sec := 0;
      lTime.tv_usec := lWait * 1000;
      lRead := WinSock2.select(0, @lReadSet, nil, nil, @lTime);
      if lRead = SOCKET_ERROR then
      begin
        NetworkDebugLog('[HardwareSearch] ' + SocketErrorText(
          'select legacy directed'));
        Continue;
      end;
      if lRead <= 0 then Continue;
      lFromLen := SizeOf(lFrom);
      FillChar(lBuffer, SizeOf(lBuffer), 0);
      lRead := recvfrom(lListen, @lBuffer[0], SizeOf(lBuffer), 0,
        @lFrom, @lFromLen);
      if lRead = SOCKET_ERROR then Continue;
      lHost := string(inet_ntoa(lFrom.sin_addr));
      if not SameText(lHost, AHost) then Continue;
      if (lRead < 24) or not CompareMem(@lBuffer[0], PChar(CLegacyRequest),
        Length(CLegacyRequest)) then Continue;
      lDeviceType := ReadLEWord(18);
      lSerial := ReadLEWord(22);
      lCCSerial := 0;
      if lRead >= 28 then
        lCCSerial := ReadLEWord(26);
      case lDeviceType of
        12, CMic140_96Type, CMic140_48Type, CMic140_48EthernetType,
        CMic140_48V2Type, CMic140_48V2EthernetType, CMic140_48V3Type,
        CMic140_48V3EthernetType, CMic140_96V3Type,
        CMic140_96V3EthernetType, CMic140_96V5Type,
        CMic140DeviceType, CMic140_96V2DeviceType,
        CMic140_16V2DeviceType: AKind := 'MIC-140';
        CMic183DeviceType, CMic185V2DeviceType: AKind := 'MIC183/185';
      else
        NetworkDebugLog(Format('[HardwareSearch] ignored legacy directed: host=%s type=$%x bytes=%d',
          [lHost, lDeviceType, lRead]));
      end;
      if AKind = '' then Exit;
      if lCCSerial <> 0 then
        ASerial := IntToStr(lCCSerial)
      else if lSerial <> 0 then
        ASerial := IntToStr(lSerial);
      Exit(True);
    until False;
  finally
    if lSend <> INVALID_SOCKET then closesocket(lSend);
    if lListen <> INVALID_SOCKET then closesocket(lListen);
    WSACleanup;
  end;
end;
{$else}
begin
  Result := False;
  AKind := '';
  ASerial := '';
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
  out AErrorText: string; AUseConfiguredBind: Boolean;
  ABeforeConnect: TRecorderSocketSetup): Boolean;
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
    if AUseConfiguredBind and (g_RecorderNetworkBindAddress <> '') then
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
    if Assigned(ABeforeConnect) then
      ABeforeConnect(lSocket);
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
