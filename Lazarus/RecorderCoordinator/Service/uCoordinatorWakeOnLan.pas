unit uCoordinatorWakeOnLan;

{$mode objfpc}{$H+}

interface

function SendWakeOnLan(const AMacAddress: string;
  const ABroadcastAddress: string = '255.255.255.255'; APort: Word = 9): Boolean;
function IsValidWakeOnLanMac(const AMacAddress: string): Boolean;
function WakeOnLanBroadcast(const AHost: string): string;
function SendWakeOnLanDetailed(const AMacAddress, ABroadcastAddress: string;
  APort: Word; out AError: string): Boolean;

implementation

uses SysUtils, Classes, Sockets, ctypes
  {$ifdef windows}, Windows, JwaIpHlpApi, JwaIpRtrMib{$endif};

{$ifdef linux}
type
  PInterfaceAddress = ^TInterfaceAddress;
  TInterfaceAddress = record
    Next: PInterfaceAddress;
    Name: PChar;
    Flags: cuint;
    Address, Netmask, Broadcast, Data: Pointer;
  end;
function getifaddrs(out AList: PInterfaceAddress): cint; cdecl; external 'c';
procedure freeifaddrs(AList: PInterfaceAddress); cdecl; external 'c';
{$endif}

function WakeOnLanBroadcast(const AHost: string): string;
var
  lHost, lBestMask, lBroadcast: Cardinal;
{$ifdef linux}
  lList, lItem: PInterfaceAddress;
{$endif}
{$ifdef windows}
  lSize: DWORD;
  lTable: PMIB_IPADDRTABLE;
  lRow: PMIB_IPADDRROW;
  lIndex: Integer;
{$endif}

  procedure Consider(AAddress, AMask: Cardinal);
  var lMask: Cardinal;
  begin
    lMask := NetToHost(AMask);
    if (lMask <= lBestMask) or (lMask >= $FFFFFFFE) or
       ((AAddress and AMask) <> (lHost and AMask)) then Exit;
    lBestMask := lMask;
    lBroadcast := AAddress or not AMask;
  end;

begin
  Result := '255.255.255.255';
  lHost := StrToNetAddr(AHost).s_addr;
  if lHost = 0 then Exit;
  lBestMask := 0;
  lBroadcast := 0;
{$ifdef linux}
  if getifaddrs(lList) = 0 then
  try
    lItem := lList;
    while lItem <> nil do
    begin
      if ((lItem^.Flags and 3) = 3) and (lItem^.Address <> nil) and
         (lItem^.Netmask <> nil) and
         (PInetSockAddr(lItem^.Address)^.sin_family = AF_INET) then
        Consider(PInetSockAddr(lItem^.Address)^.sin_addr.s_addr,
          PInetSockAddr(lItem^.Netmask)^.sin_addr.s_addr);
      lItem := lItem^.Next;
    end;
  finally
    freeifaddrs(lList);
  end;
{$endif}
{$ifdef windows}
  lSize := 0;
  if GetIpAddrTable(nil, lSize, False) = ERROR_INSUFFICIENT_BUFFER then
  begin
    GetMem(lTable, lSize);
    try
      if GetIpAddrTable(lTable, lSize, False) = NO_ERROR then
        for lIndex := 0 to Integer(lTable^.dwNumEntries) - 1 do
        begin
          lRow := PMIB_IPADDRROW(PByte(lTable) + SizeOf(DWORD) +
            lIndex * SizeOf(MIB_IPADDRROW));
          Consider(lRow^.dwAddr, lRow^.dwMask);
        end;
    finally
      FreeMem(lTable);
    end;
  end;
{$endif}
  if lBroadcast <> 0 then
    Result := NetAddrToStr(in_addr(lBroadcast));
end;

function ParseMac(const AValue: string; out ABytes: array of Byte): Boolean;
var lText: string; lIndex: Integer;
begin
  lText := StringReplace(StringReplace(Trim(AValue), ':', '', [rfReplaceAll]),
    '-', '', [rfReplaceAll]);
  Result := (Length(lText) = 12) and (Length(ABytes) >= 6);
  if not Result then Exit;
  try
    for lIndex := 0 to 5 do
      ABytes[lIndex] := StrToInt('$' + Copy(lText, lIndex * 2 + 1, 2));
  except
    Result := False;
  end;
end;

function IsValidWakeOnLanMac(const AMacAddress: string): Boolean;
var
  lMac: array[0..5] of Byte;
begin
  Result := ParseMac(AMacAddress, lMac);
end;

function SendWakeOnLan(const AMacAddress, ABroadcastAddress: string;
  APort: Word): Boolean;
var lError: string;
begin
  Result := SendWakeOnLanDetailed(AMacAddress, ABroadcastAddress, APort, lError);
end;

function SendWakeOnLanDetailed(const AMacAddress, ABroadcastAddress: string;
  APort: Word; out AError: string): Boolean;
var lSocket: TSocket; lTarget: TInetSockAddr; lMac: array[0..5] of Byte;
  lPacket: array[0..101] of Byte; lIndex, lOffset, lEnabled: Integer;
begin
  Result := False;
  AError := 'Invalid MAC address';
  if not ParseMac(AMacAddress, lMac) then Exit;
  FillChar(lPacket, SizeOf(lPacket), $FF);
  for lIndex := 0 to 15 do
  begin
    lOffset := 6 + lIndex * 6;
    Move(lMac[0], lPacket[lOffset], 6);
  end;
  lSocket := fpSocket(AF_INET, SOCK_DGRAM, 0);
  if lSocket = TSocket(-1) then
  begin
    AError := 'socket: ' + IntToStr(SocketError);
    Exit;
  end;
  try
    lEnabled := 1;
    if fpSetSockOpt(lSocket, SOL_SOCKET, SO_BROADCAST, @lEnabled,
      SizeOf(lEnabled)) <> 0 then
    begin
      AError := 'SO_BROADCAST: ' + IntToStr(SocketError);
      Exit;
    end;
    FillChar(lTarget, SizeOf(lTarget), 0);
    lTarget.sin_family := AF_INET;
    lTarget.sin_port := htons(APort);
    lTarget.sin_addr := StrToNetAddr(ABroadcastAddress);
    Result := fpSendTo(lSocket, @lPacket[0], SizeOf(lPacket), 0,
      @lTarget, SizeOf(lTarget)) = SizeOf(lPacket);
    if Result then AError := ''
    else AError := 'sendto: ' + IntToStr(SocketError);
  finally
    CloseSocket(lSocket);
  end;
end;

end.
