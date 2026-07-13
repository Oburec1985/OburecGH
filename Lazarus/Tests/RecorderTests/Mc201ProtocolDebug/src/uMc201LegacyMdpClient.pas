unit uMc201LegacyMdpClient;

{
  Minimal MC-031/MC-032 legacy MDP/TCP client.

  This is a standalone diagnostic copy of the packet mechanics used by the
  original Recorder path mdpEthernet81::CallCommand. It does not use any
  RecorderLnx MIC/MEB device units.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, ssockets, uMc201ProtocolTypes;

type
  EMc201MdpProtocol = class(Exception);

  TMc201LegacyMdpClient = class
  private
    fHost: string;
    fPort: Word;
    fRxBuffer: array of Byte;
    fSocket: TInetSocket;
    fTimeoutMs: Cardinal;
    fDmHeapAddr: Word;
    fDmHeapRemain: Word;
    function EnsureRxBytes(ACount: Integer): Boolean;
    procedure DropRxBytes(ACount: Integer);
    procedure WriteBytes(const ABuffer; ACount: Integer);
    procedure SendPacket(APort: Word; const AWords: TMc201WordArray);
    function ReadPacket(out APort: Word; out AWords: TMc201WordArray): Boolean;
    procedure SetTimeoutMs(AValue: Cardinal);
  public
    constructor Create(const AHost: string; APort: Word; ATimeoutMs: Cardinal);
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    function ReadRawPacket(out APort: Word; out AWords: TMc201WordArray): Boolean;
    function CallCommand(ACommand: Word; const AArgs: TMc201WordArray;
      ARetWordCount: Integer; out ARet: TMc201WordArray;
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
  ResetLocalMemoryHeap;
end;

destructor TMc201LegacyMdpClient.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

procedure TMc201LegacyMdpClient.Connect;
begin
  Disconnect;
  fSocket := TInetSocket.Create(fHost, fPort, Integer(fTimeoutMs));
  fSocket.IOTimeout := Integer(fTimeoutMs);
end;

procedure TMc201LegacyMdpClient.Disconnect;
begin
  SetLength(fRxBuffer, 0);
  FreeAndNil(fSocket);
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
    repeat
      if not ReadPacket(lPort, ARet) then
      begin
        AErrorMessage := 'MDP command timeout';
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
    if lReadCount > 24 then
      lReadCount := 24;
  SetLength(lArgs, 5);
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
    if lWriteCount > 24 then
      lWriteCount := 24;
  SetLength(lArgs, Length(AData) + 5);
  lArgs[0] := ASlot;
  lArgs[1] := GetAddrModuleReg(ASlot, CMc201ModuleDataReg);
  lArgs[2] := GetAddrModuleReg(ASlot, CMc201ModuleIdmaReg);
  lArgs[3] := AAddress;
    lArgs[4] := lWriteCount;
    SetLength(lArgs, lWriteCount + 5);
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
  Result := CallCommandModuleIdmaNotActivated(ASlot, ACommand, AArgs,
    ARetWordCount, ARet, AErrorMessage);
  Exit;

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
