unit uRecorderOpcUaDiscovery;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

function RecorderOpcUaDiscoverMdns(AResults: TStrings;
  ATimeoutMs: Cardinal; out AError: string): Boolean;

implementation

uses
  Contnrs, uRecorderOpcUaTypes
  {$ifdef windows}, Windows, WinSock2{$else}, ctypes, Sockets, BaseUnix{$endif};

const
  CRecorderOpcUaDnsHeaderSize = 12;
  CRecorderOpcUaDnsMaxPacketSize = 4096;
  CRecorderOpcUaDnsNamePointerMask = $C0;
  CRecorderOpcUaDnsNamePointerOffset = $3F;
  CRecorderOpcUaDnsClassCacheFlush = $8000;
  CRecorderOpcUaDnsLabelTerminator = 0;
  CRecorderOpcUaDnsQuestionCount = 1;
  CRecorderOpcUaDnsResourceTypeSrvSize = 6;
  CRecorderOpcUaDnsSrvPortOffset = 4;
  CRecorderOpcUaDnsSrvTargetOffset = 6;
  CRecorderOpcUaDnsIpv4Size = 4;
  CRecorderOpcUaDnsWaitMs = 100;

type
{$ifdef windows}
  TOpcUaMdnsSockAddr = TSockAddrIn;
{$else}
  TOpcUaMdnsSockAddr = TInetSockAddr;
{$endif}

  TOpcUaMdnsSrv = class
    InstanceName: string;
    TargetName: string;
    Port: Word;
    Path: string;
  end;

function ReadWord(const AData: TBytes; AOffset: Integer): Word;
begin
  Result := (Word(AData[AOffset]) shl 8) or AData[AOffset + 1];
end;

procedure AddWord(var AData: TBytes; AValue: Word);
var
  lLength: Integer;
begin
  lLength := Length(AData);
  SetLength(AData, lLength + 2);
  AData[lLength] := Byte(AValue shr 8);
  AData[lLength + 1] := Byte(AValue);
end;

function BuildQuery: TBytes;
var
  I, lStart, lLength: Integer;
  lLabel: string;
  lName: string;
begin
  SetLength(Result, CRecorderOpcUaDnsHeaderSize);
  FillChar(Result[0], Length(Result), 0);
  Result[4] := Byte(CRecorderOpcUaDnsQuestionCount shr 8);
  Result[5] := Byte(CRecorderOpcUaDnsQuestionCount);
  lName := CRecorderOpcUaMdnsServiceName;
  lStart := 1;
  for I := 1 to Length(lName) + 1 do
    if (I > Length(lName)) or (lName[I] = '.') then
    begin
      lLabel := Copy(lName, lStart, I - lStart);
      lLength := Length(Result);
      SetLength(Result, lLength + 1 + Length(lLabel));
      Result[lLength] := Byte(Length(lLabel));
      if lLabel <> '' then
        Move(lLabel[1], Result[lLength + 1], Length(lLabel));
      lStart := I + 1;
    end;
  lLength := Length(Result);
  SetLength(Result, lLength + 1);
  Result[lLength] := CRecorderOpcUaDnsLabelTerminator;
  AddWord(Result, CRecorderOpcUaDnsTypePtr);
  AddWord(Result, CRecorderOpcUaDnsClassIn);
end;

function ReadDnsName(const AData: TBytes; var AOffset: Integer): string;
var
  lCursor, lNextOffset, lLabelLength, lLabelsRead: Integer;
  lJumped: Boolean;
begin
  Result := '';
  lCursor := AOffset;
  lNextOffset := AOffset;
  lJumped := False;
  lLabelsRead := 0;
  while (lCursor >= 0) and (lCursor < Length(AData)) and
    (lLabelsRead < Length(AData)) do
  begin
    lLabelLength := AData[lCursor];
    if (lLabelLength and CRecorderOpcUaDnsNamePointerMask) =
      CRecorderOpcUaDnsNamePointerMask then
    begin
      if lCursor + 1 >= Length(AData) then Exit('');
      if not lJumped then lNextOffset := lCursor + 2;
      lCursor := ((lLabelLength and CRecorderOpcUaDnsNamePointerOffset) shl 8) or
        AData[lCursor + 1];
      lJumped := True;
      Inc(lLabelsRead);
      Continue;
    end;
    Inc(lCursor);
    if lLabelLength = CRecorderOpcUaDnsLabelTerminator then
    begin
      if not lJumped then lNextOffset := lCursor;
      AOffset := lNextOffset;
      Exit;
    end;
    if (lLabelLength > 63) or (lCursor + lLabelLength > Length(AData)) then
      Exit('');
    if Result <> '' then Result := Result + '.';
    SetLength(Result, Length(Result) + lLabelLength);
    Move(AData[lCursor], Result[Length(Result) - lLabelLength + 1], lLabelLength);
    Inc(lCursor, lLabelLength);
    Inc(lLabelsRead);
  end;
end;

function ParseTxtPath(const AData: TBytes; AStart, ALength: Integer): string;
var
  lCount: Integer;
  lText: string;
begin
  Result := '';
  while ALength > 0 do
  begin
    lCount := AData[AStart];
    Inc(AStart);
    Dec(ALength);
    if lCount > ALength then Exit;
    SetLength(lText, lCount);
    if lCount > 0 then Move(AData[AStart], lText[1], lCount);
    Inc(AStart, lCount);
    Dec(ALength, lCount);
    if Pos('path=', LowerCase(lText)) = 1 then
      Result := Copy(lText, Length('path=') + 1, MaxInt);
  end;
end;

procedure ParsePacket(const AData: TBytes; ASrvs: TObjectList;
  AAddresses, APaths: TStrings);
var
  lOffset, lQuestions, lRecords, I, J, lDataLength, lDataOffset: Integer;
  lName, lTarget: string;
  lRecordType, lRecordClass: Word;
  lSrv: TOpcUaMdnsSrv;
begin
  if Length(AData) < CRecorderOpcUaDnsHeaderSize then Exit;
  lQuestions := ReadWord(AData, 4);
  lRecords := ReadWord(AData, 6) + ReadWord(AData, 8) + ReadWord(AData, 10);
  lOffset := CRecorderOpcUaDnsHeaderSize;
  for I := 1 to lQuestions do
  begin
    lName := ReadDnsName(AData, lOffset);
    if lOffset + 4 > Length(AData) then Exit;
    Inc(lOffset, 4);
  end;
  for I := 1 to lRecords do
  begin
    lName := ReadDnsName(AData, lOffset);
    if lOffset + 10 > Length(AData) then Exit;
    lRecordType := ReadWord(AData, lOffset);
    lRecordClass := ReadWord(AData, lOffset + 2) and
      not CRecorderOpcUaDnsClassCacheFlush;
    lDataLength := ReadWord(AData, lOffset + 8);
    Inc(lOffset, 10);
    lDataOffset := lOffset;
    if (lDataLength < 0) or (lDataOffset + lDataLength > Length(AData)) then
      Exit;
    if lRecordClass = CRecorderOpcUaDnsClassIn then
      case lRecordType of
        CRecorderOpcUaDnsTypeSrv:
          if lDataLength >= CRecorderOpcUaDnsResourceTypeSrvSize then
          begin
            lSrv := nil;
            for J := 0 to ASrvs.Count - 1 do
              if SameText(TOpcUaMdnsSrv(ASrvs[J]).InstanceName, lName) then
              begin
                lSrv := TOpcUaMdnsSrv(ASrvs[J]);
                Break;
              end;
            if lSrv = nil then
            begin
              lSrv := TOpcUaMdnsSrv.Create;
              lSrv.InstanceName := lName;
              lSrv.Path := '';
              ASrvs.Add(lSrv);
            end;
            lSrv.Port := ReadWord(AData, lDataOffset + CRecorderOpcUaDnsSrvPortOffset);
            lOffset := lDataOffset + CRecorderOpcUaDnsSrvTargetOffset;
            lSrv.TargetName := ReadDnsName(AData, lOffset);
          end;
        CRecorderOpcUaDnsTypeTxt:
          begin
            lTarget := ParseTxtPath(AData, lDataOffset, lDataLength);
            if lTarget <> '' then APaths.Values[LowerCase(lName)] := lTarget;
          end;
        CRecorderOpcUaDnsTypeA:
          if lDataLength = CRecorderOpcUaDnsIpv4Size then
            AAddresses.Values[LowerCase(lName)] := Format('%d.%d.%d.%d',
              [AData[lDataOffset], AData[lDataOffset + 1],
               AData[lDataOffset + 2], AData[lDataOffset + 3]]);
      end;
    lOffset := lDataOffset + lDataLength;
  end;

  for I := 0 to ASrvs.Count - 1 do
  begin
    lSrv := TOpcUaMdnsSrv(ASrvs[I]);
    if APaths.Values[LowerCase(lSrv.InstanceName)] <> '' then
      lSrv.Path := APaths.Values[LowerCase(lSrv.InstanceName)];
  end;
end;

function RecorderOpcUaDiscoverMdns(AResults: TStrings;
  ATimeoutMs: Cardinal; out AError: string): Boolean;
var
  lSocket: TSocket;
  lLocal, lGroup: TOpcUaMdnsSockAddr;
  lMembership: array[0..1] of Cardinal;
  lOption: LongInt;
  lQuery: TBytes;
  lBuffer: array[0..CRecorderOpcUaDnsMaxPacketSize - 1] of Byte;
  lData: TBytes;
  lSource: TOpcUaMdnsSockAddr;
{$ifdef windows}
  lSourceLen: Integer;
  lWsaData: TWSAData;
{$else}
  lSourceLen: TSockLen;
{$endif}
  lReadSet: TFDSet;
  lTimeout: TTimeVal;
  lStarted, lRemaining: QWord;
  lReceived, lSelect: LongInt;
  lSrvs: TObjectList;
  lAddresses, lPaths: TStringList;
  I: Integer;
  lSrv: TOpcUaMdnsSrv;
  lHost: string;
  lEndpoint, lDisplay: string;
begin
  Result := False;
  AError := '';
  if AResults = nil then
  begin
    AError := 'Не задан список результатов поиска.';
    Exit;
  end;
  AResults.Clear;
{$ifdef windows}
  if WSAStartup($0202, lWsaData) <> 0 then
  begin
    AError := 'Не удалось инициализировать Windows Sockets для mDNS.';
    Exit;
  end;
  lSocket := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
{$else}
  lSocket := fpSocket(AF_INET, SOCK_DGRAM, 0);
{$endif}
{$ifdef windows}
  if lSocket = INVALID_SOCKET then
{$else}
  if lSocket < 0 then
{$endif}
  begin
    AError := 'Не удалось создать UDP-сокет для mDNS.';
{$ifdef windows}
    WSACleanup;
{$endif}
    Exit;
  end;
  lSrvs := TObjectList.Create(True);
  lAddresses := TStringList.Create;
  lPaths := TStringList.Create;
  try
    try
      lOption := 1;
{$ifdef windows}
      setsockopt(lSocket, SOL_SOCKET, SO_REUSEADDR, @lOption, SizeOf(lOption));
{$else}
      fpSetSockOpt(lSocket, SOL_SOCKET, SO_REUSEADDR, @lOption, SizeOf(lOption));
{$endif}
      FillChar(lLocal, SizeOf(lLocal), 0);
      lLocal.sin_family := AF_INET;
      lLocal.sin_port := htons(CRecorderOpcUaMdnsPort);
{$ifdef windows}
      lLocal.sin_addr.S_addr := INADDR_ANY;
      if WinSock2.bind(lSocket, @lLocal, SizeOf(lLocal)) <> 0 then
{$else}
      lLocal.sin_addr.s_addr := 0;
      if fpBind(lSocket, @lLocal, SizeOf(lLocal)) <> 0 then
{$endif}
      begin
        AError := 'Не удалось открыть mDNS UDP-порт 5353.';
        Exit;
      end;
{$ifdef windows}
      lMembership[0] := inet_addr(PChar(AnsiString(
        CRecorderOpcUaMdnsGroupIPv4)));
{$else}
      lMembership[0] := StrToNetAddr(CRecorderOpcUaMdnsGroupIPv4).s_addr;
{$endif}
      lMembership[1] := 0;
{$ifdef windows}
      if setsockopt(lSocket, CRecorderOpcUaIpProtocol,
        CRecorderOpcUaIpAddMembership, @lMembership, SizeOf(lMembership)) <> 0 then
{$else}
      if fpSetSockOpt(lSocket, CRecorderOpcUaIpProtocol,
        CRecorderOpcUaIpAddMembership, @lMembership, SizeOf(lMembership)) <> 0 then
{$endif}
      begin
{$ifdef windows}
        AError := Format('Не удалось подписаться на mDNS multicast ' +
          '(Winsock %d).', [WSAGetLastError]);
{$else}
        AError := 'Не удалось подписаться на mDNS multicast.';
{$endif}
        Exit;
      end;
      lQuery := BuildQuery;
      FillChar(lGroup, SizeOf(lGroup), 0);
      lGroup.sin_family := AF_INET;
      lGroup.sin_port := htons(CRecorderOpcUaMdnsPort);
{$ifdef windows}
      lGroup.sin_addr.S_addr := inet_addr(PChar(AnsiString(
        CRecorderOpcUaMdnsGroupIPv4)));
      if sendto(lSocket, @lQuery[0], Length(lQuery), 0, @lGroup,
        SizeOf(lGroup)) = SOCKET_ERROR then
{$else}
      lGroup.sin_addr := StrToNetAddr(CRecorderOpcUaMdnsGroupIPv4);
      if fpSendTo(lSocket, @lQuery[0], Length(lQuery), 0, @lGroup,
        SizeOf(lGroup)) < 0 then
{$endif}
      begin
        AError := 'Не удалось отправить mDNS-запрос OPC UA.';
        Exit;
      end;
      lStarted := GetTickCount64;
      if ATimeoutMs = 0 then ATimeoutMs := CRecorderOpcUaDiscoveryTimeoutMs;
      while not (GetTickCount64 - lStarted >= ATimeoutMs) do
      begin
        lRemaining := ATimeoutMs - (GetTickCount64 - lStarted);
{$ifdef windows}
        FD_ZERO(lReadSet);
        FD_SET(lSocket, lReadSet);
{$else}
        fpFD_ZERO(lReadSet);
        fpFD_SET(lSocket, lReadSet);
{$endif}
        lTimeout.tv_sec := CRecorderOpcUaDnsWaitMs div 1000;
        lTimeout.tv_usec := (CRecorderOpcUaDnsWaitMs mod 1000) * 1000;
        if lRemaining < CRecorderOpcUaDnsWaitMs then
        begin
          lTimeout.tv_sec := lRemaining div 1000;
          lTimeout.tv_usec := (lRemaining mod 1000) * 1000;
        end;
{$ifdef windows}
        lSelect := WinSock2.select(0, @lReadSet, nil, nil, @lTimeout);
{$else}
        lSelect := fpSelect(lSocket + 1, @lReadSet, nil, nil, @lTimeout);
{$endif}
        if lSelect <= 0 then Continue;
        lSourceLen := SizeOf(lSource);
{$ifdef windows}
        lReceived := recvfrom(lSocket, @lBuffer[0], SizeOf(lBuffer), 0,
          @lSource, @lSourceLen);
{$else}
        lReceived := fpRecvFrom(lSocket, @lBuffer[0], SizeOf(lBuffer), 0,
          @lSource, @lSourceLen);
{$endif}
        if lReceived <= 0 then Continue;
        SetLength(lData, lReceived);
        Move(lBuffer[0], lData[0], lReceived);
        ParsePacket(lData, lSrvs, lAddresses, lPaths);
      end;
      for I := 0 to lSrvs.Count - 1 do
      begin
        lSrv := TOpcUaMdnsSrv(lSrvs[I]);
        if (lSrv.Port = 0) or (lSrv.TargetName = '') then Continue;
        lHost := lAddresses.Values[LowerCase(lSrv.TargetName)];
        if lHost = '' then lHost := lSrv.TargetName;
        lEndpoint := 'opc.tcp://' + lHost + ':' + IntToStr(lSrv.Port) +
          lSrv.Path;
        lDisplay := lSrv.InstanceName + #9 + lEndpoint;
        if AResults.IndexOf(lDisplay) < 0 then AResults.Add(lDisplay);
      end;
      if AResults.Count = 0 then
        AError := 'OPC UA-серверы через mDNS не обнаружены. Проверьте, что сервер объявляет _opcua-tcp и multicast разрешён в сети.'
      else
        Result := True;
    except
      on E: Exception do
        AError := E.ClassName + ': ' + E.Message;
    end;
  finally
{$ifdef windows}
    shutdown(lSocket, SD_BOTH);
    closesocket(lSocket);
    WSACleanup;
{$else}
    fpClose(lSocket);
{$endif}
    lPaths.Free;
    lAddresses.Free;
    lSrvs.Free;
  end;
end;

end.
