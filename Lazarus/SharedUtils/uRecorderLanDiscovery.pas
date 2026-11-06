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
    AAddress, ABaseUrl, AMacAddresses: string) of object;
  TRecorderDiscoveryOwnerFoundEvent = procedure(const AInstanceId,
    ACoordinatorId, AClaimId: string) of object;
  TRecorderCoordinatorControlRequest = record
    CoordinatorId, CoordinatorUrl, ClaimId: string;
    Force, Release: Boolean;
  end;
  TRecorderDiscoveryControlPacket = record
    Address, TargetInstanceId, ClaimId: string;
    Force, Release: Boolean;
  end;

  { UDP advertises endpoints and carries explicit control-session requests.
    The Recorder worker validates the candidate through HTTP before adopting
    it; recording commands and results remain in the HTTP contract. }
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
    fMacAddresses: string;
    fLocalAddresses: string;
    fHttpPort: Word;
    fThread: TRecorderLanDiscoveryThread;
    fSocket: cint;
    fLock: TCriticalSection;
    fCoordinatorUrl: string;
    fSearchRequested: Boolean;
    fOnFound: TRecorderDiscoveryFoundEvent;
    fOnOwnerFound: TRecorderDiscoveryOwnerFoundEvent;
    fControlOwnerId, fControlOwnerClaimId, fControlToken: string;
    fControlRequests: array[0..15] of TRecorderCoordinatorControlRequest;
    fControlRequestCount: Integer;
    fControlPackets: array[0..63] of TRecorderDiscoveryControlPacket;
    fControlPacketCount: Integer;
    function ConsumeSearchRequest: Boolean;
    procedure QueueControlPacket(const AAddress, ATargetInstanceId,
      AClaimId: string; AForce, ARelease: Boolean);
    procedure SendPendingControlPackets;
    procedure Run;
    procedure SendPacket(const AKind: string; const AAddress: TInetSockAddr);
    procedure SendBroadcast(const AKind: string; APort: Word);
  protected
    procedure HandlePacket(const AText, ASourceAddress: string;
      const ASource: TInetSockAddr);
  public
    constructor Create(ARole: TRecorderDiscoveryRole;
      const AInstanceId, ADisplayName: string; AHttpPort: Word;
      const AMacAddresses: string = ''; const ALocalAddresses: string = '');
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    procedure RequestSearch;
    function TakeCoordinatorUrl(out AUrl: string): Boolean;
    procedure RequestClaim(const AAddress, ATargetInstanceId,
      AClaimId: string; AForce: Boolean);
    procedure RequestRelease(const AAddress, ATargetInstanceId,
      AClaimId: string);
    function TakeControlRequest(
      out ARequest: TRecorderCoordinatorControlRequest): Boolean;
    procedure SetControlOwner(const ACoordinatorId, AClaimId: string);
    procedure SetControlToken(const AToken: string);
    procedure SetDisplayName(const ADisplayName: string);
    property OnFound: TRecorderDiscoveryFoundEvent read fOnFound write fOnFound;
    property OnOwnerFound: TRecorderDiscoveryOwnerFoundEvent
      read fOnOwnerFound write fOnOwnerFound;
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
  const AInstanceId, ADisplayName: string; AHttpPort: Word;
  const AMacAddresses, ALocalAddresses: string);
begin
  inherited Create;
  fRole := ARole;
  fInstanceId := AInstanceId;
  fDisplayName := ADisplayName;
  fMacAddresses := AMacAddresses;
  fLocalAddresses := ALocalAddresses;
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
  { fpShutdown above wakes the blocking fpRecvFrom in Run. WaitFor is used
    only as the ownership barrier before the thread object is released. }
  fThread.WaitFor;
  FreeAndNil(fThread);
end;

procedure TRecorderLanDiscovery.RequestSearch;
begin
  fLock.Acquire;
  try
    fSearchRequested := True;
  finally
    fLock.Release;
  end;
end;

function TRecorderLanDiscovery.ConsumeSearchRequest: Boolean;
begin
  fLock.Acquire;
  try
    Result := fSearchRequested;
    fSearchRequested := False;
  finally
    fLock.Release;
  end;
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

procedure TRecorderLanDiscovery.QueueControlPacket(const AAddress,
  ATargetInstanceId, AClaimId: string; AForce, ARelease: Boolean);
begin
  if (fRole <> rdrCoordinator) or (AAddress = '') or
    (ATargetInstanceId = '') or (AClaimId = '') then Exit;
  fLock.Acquire;
  try
    if fControlPacketCount >= Length(fControlPackets) then Exit;
    with fControlPackets[fControlPacketCount] do
    begin
      Address := AAddress;
      TargetInstanceId := ATargetInstanceId;
      ClaimId := AClaimId;
      Force := AForce;
      Release := ARelease;
    end;
    Inc(fControlPacketCount);
  finally
    fLock.Release;
  end;
end;

procedure TRecorderLanDiscovery.SetControlOwner(const ACoordinatorId,
  AClaimId: string);
begin
  fLock.Acquire;
  try
    fControlOwnerId := ACoordinatorId;
    fControlOwnerClaimId := AClaimId;
    fSearchRequested := True;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderLanDiscovery.SetControlToken(const AToken: string);
begin
  fLock.Acquire;
  try
    fControlToken := AToken;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderLanDiscovery.SetDisplayName(const ADisplayName: string);
begin
  fLock.Acquire;
  try
    if fDisplayName <> ADisplayName then
    begin
      fDisplayName := ADisplayName;
      fSearchRequested := True;
    end;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderLanDiscovery.RequestClaim(const AAddress,
  ATargetInstanceId, AClaimId: string; AForce: Boolean);
begin
  QueueControlPacket(AAddress, ATargetInstanceId, AClaimId, AForce, False);
end;

procedure TRecorderLanDiscovery.RequestRelease(const AAddress,
  ATargetInstanceId, AClaimId: string);
begin
  QueueControlPacket(AAddress, ATargetInstanceId, AClaimId, False, True);
end;

function TRecorderLanDiscovery.TakeControlRequest(
  out ARequest: TRecorderCoordinatorControlRequest): Boolean;
var
  lIndex: Integer;
begin
  ARequest.CoordinatorId := '';
  ARequest.CoordinatorUrl := '';
  ARequest.ClaimId := '';
  ARequest.Force := False;
  ARequest.Release := False;
  fLock.Acquire;
  try
    Result := fControlRequestCount > 0;
    if not Result then Exit;
    ARequest := fControlRequests[0];
    Dec(fControlRequestCount);
    for lIndex := 0 to fControlRequestCount - 1 do
      fControlRequests[lIndex] := fControlRequests[lIndex + 1];
    fControlRequests[fControlRequestCount].CoordinatorId := '';
    fControlRequests[fControlRequestCount].CoordinatorUrl := '';
    fControlRequests[fControlRequestCount].ClaimId := '';
  finally
    fLock.Release;
  end;
end;

procedure TRecorderLanDiscovery.SendPendingControlPackets;
var
  lPacket: TRecorderDiscoveryControlPacket;
  lJson: TJSONObject;
  lAddress: TInetSockAddr;
  lText: RawByteString;
  lIndex: Integer;
begin
  repeat
    fLock.Acquire;
    try
      if fControlPacketCount = 0 then Exit;
      lPacket := fControlPackets[0];
      Dec(fControlPacketCount);
      for lIndex := 0 to fControlPacketCount - 1 do
        fControlPackets[lIndex] := fControlPackets[lIndex + 1];
      fControlPackets[fControlPacketCount].Address := '';
      fControlPackets[fControlPacketCount].TargetInstanceId := '';
      fControlPackets[fControlPacketCount].ClaimId := '';
    finally
      fLock.Release;
    end;
    FillChar(lAddress, SizeOf(lAddress), 0);
    lAddress.sin_family := AF_INET;
    lAddress.sin_port := htons(CRecorderDiscoveryClientPort);
    lAddress.sin_addr := StrToNetAddr(lPacket.Address);
    lJson := TJSONObject.Create;
    try
      lJson.Add('magic', CDiscoveryMagic);
      lJson.Add('version', CDiscoveryVersion);
      if lPacket.Release then lJson.Add('kind', 'coordinator.release')
      else lJson.Add('kind', 'coordinator.claim');
      lJson.Add('instance_id', fInstanceId);
      lJson.Add('target_instance_id', lPacket.TargetInstanceId);
      lJson.Add('http_port', Integer(fHttpPort));
      lJson.Add('claim_id', lPacket.ClaimId);
      lJson.Add('force', lPacket.Force);
      fLock.Acquire;
      try
        lJson.Add('auth_token', fControlToken);
      finally
        fLock.Release;
      end;
      lText := UTF8Encode(lJson.AsJSON);
      fpSendTo(fSocket, @lText[1], Length(lText), 0,
        @lAddress, SizeOf(lAddress));
    finally
      lJson.Free;
    end;
  until fThread.Terminated;
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
    if fMacAddresses <> '' then
      lJson.Add('mac_addresses', fMacAddresses);
    lJson.Add('http_port', Integer(fHttpPort));
    fLock.Acquire;
    try
      lJson.Add('display_name', fDisplayName);
      lJson.Add('control_owner', fControlOwnerId);
      lJson.Add('control_claim', fControlOwnerClaimId);
    finally
      fLock.Release;
    end;
    lText := UTF8Encode(lJson.AsJSON);
    fpSendTo(fSocket, @lText[1], Length(lText), 0, @AAddress, SizeOf(AAddress));
  finally
    lJson.Free;
  end;
end;

procedure TRecorderLanDiscovery.SendBroadcast(const AKind: string; APort: Word);
var
  lAddress: TInetSockAddr;
  lAddresses: TStringList;
  I: Integer;
begin
  FillChar(lAddress, SizeOf(lAddress), 0);
  lAddress.sin_family := AF_INET;
  lAddress.sin_port := htons(APort);
  lAddress.sin_addr := StrToNetAddr('255.255.255.255');
  SendPacket(AKind, lAddress);
  { A measurement network may have no route to limited broadcast. Send
    directly to each real local address as well: using loopback here would
    replace the panel's saved network address with 127.0.0.1. }
  lAddresses := TStringList.Create;
  try
    lAddresses.StrictDelimiter := True;
    lAddresses.Delimiter := ',';
    lAddresses.DelimitedText := fLocalAddresses;
    for I := 0 to lAddresses.Count - 1 do
      if Trim(lAddresses[I]) <> '' then
      begin
        lAddress.sin_addr := StrToNetAddr(Trim(lAddresses[I]));
        SendPacket(AKind, lAddress);
      end;
  finally
    lAddresses.Free;
  end;
end;

procedure TRecorderLanDiscovery.HandlePacket(const AText, ASourceAddress: string;
  const ASource: TInetSockAddr);
var
  lData: TJSONData;
  lJson: TJSONObject;
  lKind, lInstanceId, lDisplayName, lUrl, lMacAddresses: string;
  lPort: Integer;
  lReply: TInetSockAddr;
  lRequest: TRecorderCoordinatorControlRequest;
  lIndex: Integer;
  lDuplicate: Boolean;
begin
  lData := nil;
  try
   try
    lData := GetJSON(AText);
    if not (lData is TJSONObject) then Exit;
    lJson := TJSONObject(lData);
    if (lJson.Get('magic', '') <> CDiscoveryMagic) or
       (lJson.Get('version', 0) <> CDiscoveryVersion) then Exit;
    lKind := lJson.Get('kind', '');
    lInstanceId := lJson.Get('instance_id', '');
    lDisplayName := lJson.Get('display_name', '');
    lMacAddresses := lJson.Get('mac_addresses', '');
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
          fOnFound(lInstanceId, lDisplayName, ASourceAddress, lUrl,
            lMacAddresses);
        if Assigned(fOnOwnerFound) then
          fOnOwnerFound(lInstanceId, lJson.Get('control_owner', ''),
            lJson.Get('control_claim', ''));
      end;
    end
    else if (lKind = 'coordinator.claim') or
      (lKind = 'coordinator.release') then
    begin
      if (lJson.Get('target_instance_id', '') <> fInstanceId) or
        (lInstanceId = '') or (lPort < 1) or (lPort > 65535) or
        (lJson.Get('claim_id', '') = '') then Exit;
      lRequest.CoordinatorId := lInstanceId;
      { An advertised URL must never redirect a claim to an unrelated host. }
      lRequest.CoordinatorUrl := 'http://' + ASourceAddress + ':' + IntToStr(lPort);
      lRequest.ClaimId := lJson.Get('claim_id', '');
      lRequest.Force := lJson.Get('force', False);
      lRequest.Release := lKind = 'coordinator.release';
      fLock.Acquire;
      try
        if lJson.Get('auth_token', '') <> fControlToken then Exit;
        lDuplicate := False;
        for lIndex := 0 to fControlRequestCount - 1 do
          if (fControlRequests[lIndex].CoordinatorId = lRequest.CoordinatorId) and
            (fControlRequests[lIndex].ClaimId = lRequest.ClaimId) and
            (fControlRequests[lIndex].Release = lRequest.Release) then
            lDuplicate := True;
        if not lDuplicate and
          (fControlRequestCount < Length(fControlRequests)) then
        begin
          fControlRequests[fControlRequestCount] := lRequest;
          Inc(fControlRequestCount);
        end;
      finally
        fLock.Release;
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
      { Reply immediately so an explicit Coordinator search does not wait for
        the Recorder's periodic announcement. }
      lReply := ASource;
      lReply.sin_port := htons(CRecorderDiscoveryCoordinatorPort);
      SendPacket('recorder.available', lReply);
    end;
  except
    on E: Exception do
      SharedLogger.Error('Discovery invalid packet from ' + ASourceAddress +
        ': ' + E.Message);
   end;
  finally
    lData.Free;
  end;
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
    SendPendingControlPackets;
    if ConsumeSearchRequest or (lLastAnnounce = 0) or
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
