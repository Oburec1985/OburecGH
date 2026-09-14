unit uCoordinatorWakeOnLan;

{$mode objfpc}{$H+}

interface

function SendWakeOnLan(const AMacAddress: string;
  const ABroadcastAddress: string = '255.255.255.255'; APort: Word = 9): Boolean;
function IsValidWakeOnLanMac(const AMacAddress: string): Boolean;

implementation

uses SysUtils, Classes, Sockets;

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
var lSocket: LongInt; lTarget: TInetSockAddr; lMac: array[0..5] of Byte;
  lPacket: array[0..101] of Byte; lIndex, lOffset, lEnabled: Integer;
begin
  Result := False;
  if not ParseMac(AMacAddress, lMac) then Exit;
  FillChar(lPacket, SizeOf(lPacket), $FF);
  for lIndex := 0 to 15 do
  begin
    lOffset := 6 + lIndex * 6;
    Move(lMac[0], lPacket[lOffset], 6);
  end;
  lSocket := fpSocket(AF_INET, SOCK_DGRAM, 0);
  if lSocket < 0 then Exit;
  try
    lEnabled := 1;
    if fpSetSockOpt(lSocket, SOL_SOCKET, SO_BROADCAST, @lEnabled,
      SizeOf(lEnabled)) <> 0 then Exit;
    FillChar(lTarget, SizeOf(lTarget), 0);
    lTarget.sin_family := AF_INET;
    lTarget.sin_port := htons(APort);
    lTarget.sin_addr := StrToNetAddr(ABroadcastAddress);
    Result := fpSendTo(lSocket, @lPacket[0], SizeOf(lPacket), 0,
      @lTarget, SizeOf(lTarget)) = SizeOf(lPacket);
  finally
    CloseSocket(lSocket);
  end;
end;

end.
