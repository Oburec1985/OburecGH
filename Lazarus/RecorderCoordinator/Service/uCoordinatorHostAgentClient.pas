unit uCoordinatorHostAgentClient;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils;

type
  TCoordinatorHostAgentAction = (haaStatus, haaStartRecorder, haaShutdown);
  TCoordinatorHostAgentResultEvent = procedure(Sender: TObject;
    AAction: TCoordinatorHostAgentAction; const AHost, AResponse: string;
    AHttpStatus: Integer; const AError: string) of object;

  TCoordinatorHostAgentTask = class(TThread)
  private
    fHost, fToken, fResponse, fError: string;
    fHttpStatus: Integer;
    fPort: Word;
    fAction: TCoordinatorHostAgentAction;
    fOnComplete: TCoordinatorHostAgentResultEvent;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(const AHost: string; APort: Word; const AToken: string;
      AAction: TCoordinatorHostAgentAction;
      AOnComplete: TCoordinatorHostAgentResultEvent);
  end;

procedure StartHostAgentRequest(const AHost: string; APort: Word;
  const AToken: string; AAction: TCoordinatorHostAgentAction;
  AOnComplete: TCoordinatorHostAgentResultEvent);

implementation

uses Sockets, Resolve
  {$ifdef unix}, BaseUnix{$endif}
  {$ifdef windows}, WinSock2{$endif};

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

function HostAgentHttpRequest(const AHost: string; APort: Word;
  const AToken, APath: string; APost: Boolean; ATimeoutMs: Cardinal;
  out AResponse: string; out AHttpStatus: Integer;
  out AError: string): Boolean;
var
  lBuffer: array[0..511] of Byte;
  lAddress: TInetSockAddr;
  lHostAddress: THostAddr;
  lSocket, lResult, lSocketError, lErrorLength, lRead: LongInt;
  lReadSet, lWriteSet: TFDSet;
  lRequest, lRawResponse, lStatusLine: RawByteString;
  lTimeout: TTimeVal;
{$ifdef unix}
  lFlags: LongInt;
{$endif}
{$ifdef windows}
  lMode: DWord;
{$endif}
begin
  Result := False;
  AResponse := '';
  AHttpStatus := 0;
  AError := '';
  if not ResolveIPv4(AHost, lHostAddress) then
  begin
    AError := 'Не удалось определить адрес узла ' + AHost;
    Exit;
  end;
  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket < 0 then
  begin
    AError := 'Не удалось создать TCP-сокет: ' + IntToStr(SocketError);
    Exit;
  end;
  try
{$ifdef unix}
    lFlags := fpFcntl(lSocket, F_GetFl, 0);
    if (lFlags < 0) or
       (fpFcntl(lSocket, F_SetFl, lFlags or O_NONBLOCK) <> 0) then
    begin
      AError := 'Не удалось включить неблокирующий режим TCP-сокета';
      Exit;
    end;
{$endif}
{$ifdef windows}
    lMode := 1;
    if ioctlsocket(lSocket, LongInt(FIONBIO), @lMode) <> 0 then
    begin
      AError := 'Не удалось включить неблокирующий режим TCP-сокета';
      Exit;
    end;
{$endif}
    FillChar(lAddress, SizeOf(lAddress), 0);
    lAddress.sin_family := AF_INET;
    lAddress.sin_port := ShortHostToNet(APort);
    lAddress.sin_addr.s_addr := HostToNet(lHostAddress.s_addr);
    if fpConnect(lSocket, @lAddress, SizeOf(lAddress)) <> 0 then
    begin
      FillChar(lWriteSet, SizeOf(lWriteSet), 0);
{$ifdef unix}
      fpFD_Zero(lWriteSet);
      fpFD_Set(lSocket, lWriteSet);
{$endif}
{$ifdef windows}
      FD_Zero(lWriteSet);
      FD_Set(lSocket, lWriteSet);
{$endif}
      lTimeout.tv_sec := ATimeoutMs div 1000;
      lTimeout.tv_usec := (ATimeoutMs mod 1000) * 1000;
{$ifdef unix}
      lResult := fpSelect(lSocket + 1, nil, @lWriteSet, nil, @lTimeout);
{$endif}
{$ifdef windows}
      lResult := WinSock2.select(lSocket + 1, nil, @lWriteSet, nil, @lTimeout);
{$endif}
      if lResult <= 0 then
      begin
        if lResult = 0 then
          AError := Format('Connection to %s:%d timed out.', [AHost, APort])
        else
          AError := 'Ошибка ожидания TCP-подключения: ' + IntToStr(SocketError);
        Exit;
      end;
      lSocketError := 0;
      lErrorLength := SizeOf(lSocketError);
      if (fpGetSockOpt(lSocket, SOL_SOCKET, SO_ERROR, @lSocketError,
        @lErrorLength) <> 0) or (lSocketError <> 0) then
      begin
        AError := Format('Connection to %s:%d failed (%d).',
          [AHost, APort, lSocketError]);
        Exit;
      end;
    end;

    if APost then
      lRequest := 'POST '
    else
      lRequest := 'GET ';
    lRequest := lRequest + APath + ' HTTP/1.1'#13#10 +
      'Host: ' + AHost + ':' + IntToStr(APort) + #13#10 +
      'Connection: close'#13#10;
    if AToken <> '' then
      lRequest := lRequest + 'Authorization: Bearer ' + AToken + #13#10;
    if APost then
      lRequest := lRequest + 'Content-Length: 0'#13#10;
    lRequest := lRequest + #13#10;
    if fpSend(lSocket, @lRequest[1], Length(lRequest), 0) <> Length(lRequest) then
    begin
      AError := 'Не удалось отправить HTTP-проверку launcher';
      Exit;
    end;
    FillChar(lReadSet, SizeOf(lReadSet), 0);
{$ifdef unix}
    fpFD_Zero(lReadSet);
    fpFD_Set(lSocket, lReadSet);
{$endif}
{$ifdef windows}
    FD_Zero(lReadSet);
    FD_Set(lSocket, lReadSet);
{$endif}
    lTimeout.tv_sec := ATimeoutMs div 1000;
    lTimeout.tv_usec := (ATimeoutMs mod 1000) * 1000;
{$ifdef unix}
    lResult := fpSelect(lSocket + 1, @lReadSet, nil, nil, @lTimeout);
{$endif}
{$ifdef windows}
    lResult := WinSock2.select(lSocket + 1, @lReadSet, nil, nil, @lTimeout);
{$endif}
    if lResult <= 0 then
    begin
      AError := 'Launcher не ответил на HTTP-проверку';
      Exit;
    end;
    lRead := fpRecv(lSocket, @lBuffer[0], SizeOf(lBuffer), 0);
    if lRead <= 0 then
    begin
      AError := 'Launcher закрыл соединение без HTTP-ответа';
      Exit;
    end;
    SetString(lRawResponse, PAnsiChar(@lBuffer[0]), lRead);
    Result := Pos('HTTP/', lRawResponse) = 1;
    if not Result then
      AError := 'Launcher вернул некорректный HTTP-ответ';
    if Result then
    begin
      lRead := Pos(#13#10, lRawResponse);
      if lRead > 0 then
        lStatusLine := Copy(lRawResponse, 1, lRead - 1)
      else
        lStatusLine := lRawResponse;
      lRead := Pos(' ', lStatusLine);
      if lRead > 0 then
        AHttpStatus := StrToIntDef(Copy(lStatusLine, lRead + 1, 3), 0);
      if AHttpStatus = 0 then
      begin
        Result := False;
        AError := 'Launcher вернул HTTP-ответ без корректного кода состояния';
        Exit;
      end;
      lRead := Pos(#13#10#13#10, lRawResponse);
      if lRead > 0 then
        AResponse := Copy(lRawResponse, lRead + 4, MaxInt)
      else
        AResponse := lRawResponse;
    end;
  finally
    CloseSocket(lSocket);
  end;
end;

constructor TCoordinatorHostAgentTask.Create(const AHost: string; APort: Word;
  const AToken: string; AAction: TCoordinatorHostAgentAction;
  AOnComplete: TCoordinatorHostAgentResultEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fHost := AHost; fPort := APort; fToken := AToken;
  fAction := AAction; fOnComplete := AOnComplete;
end;

procedure TCoordinatorHostAgentTask.Execute;
var
  lPath: string;
begin
  case fAction of
    haaStatus:
      lPath := '/api/v1/status';
    haaStartRecorder:
      lPath := '/api/v1/recorder/start';
    haaShutdown:
      lPath := '/api/v1/system/shutdown';
  end;
  HostAgentHttpRequest(fHost, fPort, fToken, lPath,
    fAction <> haaStatus, 1500, fResponse, fHttpStatus, fError);
  TThread.Queue(Self, @Deliver);
end;

procedure TCoordinatorHostAgentTask.Deliver;
begin
  if Assigned(fOnComplete) then
    fOnComplete(Self, fAction, fHost, fResponse, fHttpStatus, fError);
  Free;
end;

procedure StartHostAgentRequest(const AHost: string; APort: Word;
  const AToken: string; AAction: TCoordinatorHostAgentAction;
  AOnComplete: TCoordinatorHostAgentResultEvent);
var lTask: TCoordinatorHostAgentTask;
begin
  lTask := TCoordinatorHostAgentTask.Create(AHost, APort, AToken, AAction,
    AOnComplete);
  lTask.Start;
end;

end.
