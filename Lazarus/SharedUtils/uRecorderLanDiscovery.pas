unit uRecorderLanDiscovery;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Sockets, SyncObjs, ctypes;

const
  CRecorderDiscoveryCoordinatorPort = 38765;
  CRecorderDiscoveryClientPort = 38766;

type
  TRecorderDiscoveryRole = (rdrCoordinator, rdrRecorder);
  TRecorderDiscoveryFoundEvent = procedure(const AInstanceId, ADisplayName,
    AAddress, ABaseUrl: string) of object;

  { UDP discovery is deliberately independent from HTTP. It only advertises
    endpoints; authentication and all commands remain in the HTTP contract. }
  TRecorderLanDiscovery = class;

  TRecorderLanDiscoveryThread = class(TThread)
  private
    fOwner: TRecorderLanDiscovery;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderLanDiscovery);
  end;

  TRecorderLanDiscovery = class
  private
    fRole: TRecorderDiscoveryRole;
    fInstanceId: string;
    fDisplayName: string;
    fHttpPort: Word;
    fThread: TRecorderLanDiscoveryThread;
    fSocket: cint;
    fLock: TCriticalSection;
    fCoordinatorUrl: string;
    fOnFound: TRecorderDiscoveryFoundEvent;
    procedure Run;
    procedure SendPacket(const AKind: string; const AAddress: TInetSockAddr);
    procedure SendBroadcast(const AKind: string; APort: Word);
    procedure HandlePacket(const AText, ASourceAddress: string;
      const ASource: TInetSockAddr);
  public
    constructor Create(ARole: TRecorderDiscoveryRole;
      const AInstanceId, ADisplayName: string; AHttpPort: Word);
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    function TakeCoordinatorUrl(out AUrl: string): Boolean;
    property OnFound: TRecorderDiscoveryFoundEvent read fOnFound write fOnFound;
  end;

implementation

uses
  fpjson, jsonparser, uSharedFileLogger
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

const
  CDiscoveryMagic = 'RecorderLnxDiscovery';
  CDiscoveryVersion = 1;
  CAnnounceIntervalMs = 3000;

constructor TRecorderLanDiscoveryThread.Create(AOwner: TRecorderLanDiscovery);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
end;

procedure TRecorderLanDiscoveryThread.Execute;
begin
  fOwner.Run;
end;

constructor TRecorderLanDiscovery.Create(ARole: TRecorderDiscoveryRole;
  const AInstanceId, ADisplayName: string; AHttpPort: Word);
begin
  inherited Create;
  fRole := ARole;
  fInstanceId := AInstanceId;
  fDisplayName := ADisplayName;
  fHttpPort := AHttpPort;
  fSocket := -1;
  fLock := TCriticalSection.Create;
end;

destructor TRecorderLanDiscovery.Destroy;
begin
  Stop;
  fLock.Free;
  inherited Destroy;
end;

procedure TRecorderLanDiscovery.Start;
begin
  if fThread <> nil then Exit;
  fThread := TRecorderLanDiscoveryThread.Create(Self);
  fThread.Start;
end;

procedure TRecorderLanDiscovery.Stop;
begin
  if fThread = nil then Exit;
  fThread.Terminate;
  if fSocket >= 0 then
    fpShutdown(fSocket, SHUT_RDWR);
  fThread.WaitFor;
  FreeAndNil(fThread);
end;

function TRecorderLanDiscovery.TakeCoordinatorUrl(out AUrl: string): Boolean;
begin
  fLock.Acquire;
  try
    AUrl := fCoordinatorUrl;
    fCoordinatorUrl := '';
    Result := AUrl <> '';
  finally
    fLock.Release;
  end;
end;

procedure TRecorderLanDiscovery.SendPacket(const AKind: string;
  const AAddress: TInetSockAddr);
var
  lJson: TJSONObject;
  lText: RawByteString;
begin
  if fSocket < 0 then Exit;
  lJson := TJSONObject.Create;
  try
    lJson.Add('magic', CDiscoveryMagic);
    lJson.Add('version', CDiscoveryVersion);
    lJson.Add('kind', AKind);
    lJson.Add('instance_id', fInstanceId);
    lJson.Add('display_name', fDisplayName);
    lJson.Add('http_port', Integer(fHttpPort));
    lText := UTF8Encode(lJson.AsJSON);
    fpSendTo(fSocket, @lText[1], Length(lText), 0, @AAddress, SizeOf(AAddress));
  finally
    lJson.Free;
  end;
end;

procedure TRecorderLanDiscovery.SendBroadcast(const AKind: string; APort: Word);
var
  lAddress: TInetSockAddr;
begin
  FillChar(lAddress, SizeOf(lAddress), 0);
  lAddress.sin_family := AF_INET;
  lAddress.sin_port := htons(APort);
  lAddress.sin_addr := StrToNetAddr('255.255.255.255');
  SendPacket(AKind, lAddress);
end;

procedure TRecorderLanDiscovery.HandlePacket(const AText, ASourceAddress: string;
  const ASource: TInetSockAddr);
var
  lData: TJSONData;
  lJson: TJSONObject;
  lKind, lInstanceId, lDisplayName, lUrl: string;
  lPort: Integer;
  lReply: TInetSockAddr;
begin
  lData := nil;
  try
    lData := GetJSON(AText);
    if not (lData is TJSONObject) then Exit;
    lJson := TJSONObject(lData);
    if (lJson.Get('magic', '') <> CDiscoveryMagic) or
       (lJson.Get('version', 0) <> CDiscoveryVersion) then Exit;
    lKind := lJson.Get('kind', '');
    lInstanceId := lJson.Get('instance_id', '');
    lDisplayName := lJson.Get('display_name', '');
    lPort := lJson.Get('http_port', 0);
    if fRole = rdrCoordinator then
    begin
      if lKind = 'discover.coordinator' then
      begin
        lReply := ASource;
        lReply.sin_port := htons(CRecorderDiscoveryClientPort);
        SendPacket('coordinator.available', lReply);
      end
      else if (lKind = 'recorder.available') and (lInstanceId <> '') then
      begin
        lUrl := 'http://' + ASourceAddress + ':' + IntToStr(lPort);
        SharedLogger.Info('Discovery recorder found: ' + lDisplayName +
          ' ' + ASourceAddress);
        if Assigned(fOnFound) then
          fOnFound(lInstanceId, lDisplayName, ASourceAddress, lUrl);
      end;
    end
    else if (lKind = 'coordinator.available') and (lPort > 0) then
    begin
      lUrl := 'http://' + ASourceAddress + ':' + IntToStr(lPort);
      fLock.Acquire;
      try
        fCoordinatorUrl := lUrl;
      finally
        fLock.Release;
      end;
      SharedLogger.Info('Discovery coordinator found: ' + lUrl);
    end;
  except
    on E: Exception do
      SharedLogger.Error('Discovery invalid packet from ' + ASourceAddress +
        ': ' + E.Message);
  end;
  lData.Free;
end;

procedure TRecorderLanDiscovery.Run;
var
  lLocal, lFrom: TInetSockAddr;
  lFromLen: TSockLen;
  lBuffer: array[0..2047] of Byte;
  lRead, lOpt: cint;
  {$IFDEF UNIX}lReceiveTimeout: TTimeVal;{$ENDIF}
  {$IFDEF MSWINDOWS}lReceiveTimeoutMs: LongInt;{$ENDIF}
  lText, lSource: string;
  lListenPort: Word;
  lLastAnnounce: QWord;
begin
  fSocket := fpSocket(AF_INET, SOCK_DGRAM, 0);
  if fSocket < 0 then
  begin
    SharedLogger.Error('Discovery socket creation failed');
    Exit;
  end;
  lOpt := 1;
  fpSetSockOpt(fSocket, SOL_SOCKET, SO_REUSEADDR, @lOpt, SizeOf(lOpt));
  fpSetSockOpt(fSocket, SOL_SOCKET, SO_BROADCAST, @lOpt, SizeOf(lOpt));
  {$IFDEF UNIX}
  lReceiveTimeout.tv_sec := 0;
  lReceiveTimeout.tv_usec := 250000;
  fpSetSockOpt(fSocket, SOL_SOCKET, SO_RCVTIMEO, @lReceiveTimeout,
    SizeOf(lReceiveTimeout));
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  lReceiveTimeoutMs := 250;
  fpSetSockOpt(fSocket, SOL_SOCKET, SO_RCVTIMEO, @lReceiveTimeoutMs,
    SizeOf(lReceiveTimeoutMs));
  {$ENDIF}
  FillChar(lLocal, SizeOf(lLocal), 0);
  lLocal.sin_family := AF_INET;
  if fRole = rdrCoordinator then
    lListenPort := CRecorderDiscoveryCoordinatorPort
  else
    lListenPort := CRecorderDiscoveryClientPort;
  lLocal.sin_port := htons(lListenPort);
  lLocal.sin_addr.s_addr := 0;
  if fpBind(fSocket, @lLocal, SizeOf(lLocal)) <> 0 then
  begin
    SharedLogger.Error('Discovery bind failed on UDP/' + IntToStr(lListenPort));
    CloseSocket(fSocket);
    fSocket := -1;
    Exit;
  end;
  SharedLogger.Info('Discovery listening on UDP/' + IntToStr(lListenPort));
  lLastAnnounce := 0;
  while not fThread.Terminated do
  begin
    if (lLastAnnounce = 0) or
       (GetTickCount64 - lLastAnnounce >= CAnnounceIntervalMs) then
    begin
      if fRole = rdrCoordinator then
        SendBroadcast('coordinator.available', CRecorderDiscoveryClientPort)
      else
      begin
        SendBroadcast('discover.coordinator', CRecorderDiscoveryCoordinatorPort);
        SendBroadcast('recorder.available', CRecorderDiscoveryCoordinatorPort);
      end;
      lLastAnnounce := GetTickCount64;
    end;
    lFromLen := SizeOf(lFrom);
    FillChar(lFrom, SizeOf(lFrom), 0);
    lRead := fpRecvFrom(fSocket, @lBuffer[0], SizeOf(lBuffer), 0,
      @lFrom, @lFromLen);
    if lRead <= 0 then Continue;
    SetString(lText, PAnsiChar(@lBuffer[0]), lRead);
    lSource := NetAddrToStr(lFrom.sin_addr);
    HandlePacket(lText, lSource, lFrom);
  end;
  CloseSocket(fSocket);
  fSocket := -1;
  SharedLogger.Info('Discovery stopped');
end;

end.
