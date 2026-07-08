unit uRecorderMic185Runtime;

{
  Process-wide MIC183/185 endpoint state: which host:port is held by an active
  device driver socket. UI and probe helpers must not open a second TCP client.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

procedure RecorderMic185RuntimeInit;
procedure RecorderMic185RuntimeLog(const AMessage: string);

procedure RecorderMic185RuntimeAttach(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord; AAcquiring: Boolean);
procedure RecorderMic185RuntimeSetAcquiring(const AHost: string; APort: Word;
  AAcquiring: Boolean);
procedure RecorderMic185RuntimeUpdateInfo(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord);
procedure RecorderMic185RuntimeDetach(const AHost: string; APort: Word);

function RecorderMic185RuntimeIsBusy(const AHost: string; APort: Word): Boolean;
function RecorderMic185RuntimeHasForeignTcpClient(const AHost: string; APort: Word;
  AClient: TObject): Boolean;
procedure RecorderMic185RuntimeRegisterTcpClient(AClient: TObject;
  const AHost: string; APort: Word);
procedure RecorderMic185RuntimeUnregisterTcpClient(AClient: TObject);
function RecorderMic185RuntimeTryGetInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string): Boolean;
procedure RecorderMic185RuntimeHoldBusy(const AHost: string; APort: Word;
  AHold: Boolean);

function RecorderMic185SelfTestProbeTcpOpenCount: Integer;
procedure RecorderMic185SelfTestResetProbeTcpOpenCount;
procedure RecorderMic185RuntimeNoteProbeTcpOpen;

implementation

uses
  SyncObjs, uMic185DebugLog, uMic185MebiusTypes, uSharedFileLogger;

type
  TRecorderMic185Endpoint = class
  public
    Host: string;
    Port: Word;
    SerialNumber: LongWord;
    SoftVersion: LongWord;
    SocketBusy: Boolean;
    Acquiring: Boolean;
    HoldBusy: Boolean;
  end;

  TRecorderMic185TcpClientRef = class
  public
    Client: TObject;
    Host: string;
    Port: Word;
  end;

var
  gMic185Endpoints: TThreadList;
  gMic185TcpClients: TThreadList;
  gMic185LogReady: Boolean = False;
  gMic185ProbeTcpOpenCount: Integer = 0;

function Mic185ProjectLogPath: string;
begin
  {$IFDEF MSWINDOWS}
  Result := ExtractFilePath(ParamStr(0)) + 'LogWindows.log';
  if DirectoryExists(ExtractFilePath(ParamStr(0)) + '..\..') then
    Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..\LogWindows.log');
  {$ELSE}
  if DirectoryExists('/mnt/win_share/OburecGH/Lazarus/RecorderLnx') then
    Result := '/mnt/win_share/OburecGH/Lazarus/RecorderLnx/LogLinux.log'
  else
    Result := ExtractFilePath(ParamStr(0)) + 'LogLinux.log';
  {$ENDIF}
end;

procedure RecorderMic185RuntimeInit;
begin
  if gMic185LogReady then
    Exit;
  Mic185LogInit(Mic185ProjectLogPath);
  gMic185LogReady := True;
  if gMic185Endpoints = nil then
    gMic185Endpoints := TThreadList.Create;
  if gMic185TcpClients = nil then
    gMic185TcpClients := TThreadList.Create;
end;

procedure RecorderMic185RuntimeLog(const AMessage: string);
begin
  RecorderMic185RuntimeInit;
  Mic185Log(AMessage);
  if SharedLogger.Enabled then
    SharedLogger.Debug('[MIC185] ' + AMessage);
end;

function RecorderMic185RuntimeFind(const AHost: string; APort: Word;
  ACreate: Boolean): TRecorderMic185Endpoint;
var
  I: Integer;
  lEndpoint: TRecorderMic185Endpoint;
  lHost: string;
  lList: TList;
begin
  Result := nil;
  RecorderMic185RuntimeInit;
  lHost := Trim(AHost);
  if lHost = '' then
    Exit;
  lList := gMic185Endpoints.LockList;
  try
    for I := 0 to lList.Count - 1 do
    begin
      lEndpoint := TRecorderMic185Endpoint(lList[I]);
      if SameText(lEndpoint.Host, lHost) and (lEndpoint.Port = APort) then
        Exit(lEndpoint);
    end;
    if not ACreate then
      Exit;
    Result := TRecorderMic185Endpoint.Create;
    Result.Host := lHost;
    Result.Port := APort;
    lList.Add(Result);
  finally
    gMic185Endpoints.UnlockList;
  end;
end;

procedure RecorderMic185RuntimeAttach(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord; AAcquiring: Boolean);
var
  lEndpoint: TRecorderMic185Endpoint;
begin
  lEndpoint := RecorderMic185RuntimeFind(AHost, APort, True);
  lEndpoint.SocketBusy := True;
  lEndpoint.Acquiring := AAcquiring;
  lEndpoint.SerialNumber := ASerialNumber;
  lEndpoint.SoftVersion := ASoftVersion;
  RecorderMic185RuntimeLog(Format(
    'RuntimeAttach %s:%d busy=1 acquiring=%s sn=%d',
    [lEndpoint.Host, lEndpoint.Port, BoolToStr(AAcquiring, True),
     ASerialNumber]));
end;

procedure RecorderMic185RuntimeSetAcquiring(const AHost: string; APort: Word;
  AAcquiring: Boolean);
var
  lEndpoint: TRecorderMic185Endpoint;
begin
  lEndpoint := RecorderMic185RuntimeFind(AHost, APort, False);
  if lEndpoint = nil then
    Exit;
  lEndpoint.Acquiring := AAcquiring;
  RecorderMic185RuntimeLog(Format('RuntimeAcquire %s:%d acquiring=%s',
    [lEndpoint.Host, lEndpoint.Port, BoolToStr(AAcquiring, True)]));
end;

procedure RecorderMic185RuntimeUpdateInfo(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord);
var
  lEndpoint: TRecorderMic185Endpoint;
begin
  lEndpoint := RecorderMic185RuntimeFind(AHost, APort, False);
  if lEndpoint = nil then
    Exit;
  lEndpoint.SerialNumber := ASerialNumber;
  lEndpoint.SoftVersion := ASoftVersion;
end;

procedure RecorderMic185RuntimeHoldBusy(const AHost: string; APort: Word;
  AHold: Boolean);
var
  lEndpoint: TRecorderMic185Endpoint;
begin
  if not AHold then
  begin
    lEndpoint := RecorderMic185RuntimeFind(AHost, APort, False);
    if lEndpoint <> nil then
      lEndpoint.HoldBusy := False;
    Exit;
  end;
  lEndpoint := RecorderMic185RuntimeFind(AHost, APort, True);
  lEndpoint.HoldBusy := True;
  RecorderMic185RuntimeLog(Format('RuntimeHoldBusy %s:%d hold=1',
    [lEndpoint.Host, lEndpoint.Port]));
end;

procedure RecorderMic185RuntimeDetach(const AHost: string; APort: Word);
var
  I: Integer;
  lEndpoint: TRecorderMic185Endpoint;
  lHost: string;
  lList: TList;
begin
  lHost := Trim(AHost);
  if lHost = '' then
    Exit;
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    for I := lList.Count - 1 downto 0 do
    begin
      lEndpoint := TRecorderMic185Endpoint(lList[I]);
      if SameText(lEndpoint.Host, lHost) and (lEndpoint.Port = APort) then
      begin
        RecorderMic185RuntimeLog(Format('RuntimeDetach %s:%d', [lHost, APort]));
        lEndpoint.Free;
        lList.Delete(I);
        Break;
      end;
    end;
  finally
    gMic185Endpoints.UnlockList;
  end;
end;

function RecorderMic185RuntimeHasForeignTcpClient(const AHost: string; APort: Word;
  AClient: TObject): Boolean;
var
  I: Integer;
  lHost: string;
  lList: TList;
  lRef: TRecorderMic185TcpClientRef;
begin
  Result := False;
  lHost := Trim(AHost);
  if (lHost = '') or (gMic185TcpClients = nil) then
    Exit;
  lList := gMic185TcpClients.LockList;
  try
    for I := 0 to lList.Count - 1 do
    begin
      lRef := TRecorderMic185TcpClientRef(lList[I]);
      if (lRef.Client <> AClient) and SameText(lRef.Host, lHost) and
        (lRef.Port = APort) then
        Exit(True);
    end;
  finally
    gMic185TcpClients.UnlockList;
  end;
end;

procedure RecorderMic185RuntimeRegisterTcpClient(AClient: TObject;
  const AHost: string; APort: Word);
var
  lRef: TRecorderMic185TcpClientRef;
  lList: TList;
begin
  if AClient = nil then
    Exit;
  RecorderMic185RuntimeUnregisterTcpClient(AClient);
  RecorderMic185RuntimeInit;
  lRef := TRecorderMic185TcpClientRef.Create;
  lRef.Client := AClient;
  lRef.Host := Trim(AHost);
  lRef.Port := APort;
  lList := gMic185TcpClients.LockList;
  try
    lList.Add(lRef);
  finally
    gMic185TcpClients.UnlockList;
  end;
  RecorderMic185RuntimeLog(Format('TcpClientRegister %s:%d client=%p',
    [lRef.Host, lRef.Port, Pointer(AClient)]));
end;

procedure RecorderMic185RuntimeUnregisterTcpClient(AClient: TObject);
var
  I: Integer;
  lList: TList;
  lRef: TRecorderMic185TcpClientRef;
begin
  if (AClient = nil) or (gMic185TcpClients = nil) then
    Exit;
  lList := gMic185TcpClients.LockList;
  try
    for I := lList.Count - 1 downto 0 do
    begin
      lRef := TRecorderMic185TcpClientRef(lList[I]);
      if lRef.Client = AClient then
      begin
        RecorderMic185RuntimeLog(Format('TcpClientUnregister %s:%d client=%p',
          [lRef.Host, lRef.Port, Pointer(AClient)]));
        lRef.Free;
        lList.Delete(I);
      end;
    end;
  finally
    gMic185TcpClients.UnlockList;
  end;
end;

function RecorderMic185RuntimeTcpClientCount(const AHost: string; APort: Word): Integer;
var
  I: Integer;
  lHost: string;
  lList: TList;
  lRef: TRecorderMic185TcpClientRef;
begin
  Result := 0;
  lHost := Trim(AHost);
  if (lHost = '') or (gMic185TcpClients = nil) then
    Exit;
  lList := gMic185TcpClients.LockList;
  try
    for I := 0 to lList.Count - 1 do
    begin
      lRef := TRecorderMic185TcpClientRef(lList[I]);
      if SameText(lRef.Host, lHost) and (lRef.Port = APort) then
        Inc(Result);
    end;
  finally
    gMic185TcpClients.UnlockList;
  end;
end;

function RecorderMic185RuntimeIsBusy(const AHost: string; APort: Word): Boolean;
var
  lEndpoint: TRecorderMic185Endpoint;
begin
  lEndpoint := RecorderMic185RuntimeFind(AHost, APort, False);
  Result := (RecorderMic185RuntimeTcpClientCount(AHost, APort) > 0) or
    ((lEndpoint <> nil) and
    (lEndpoint.SocketBusy or lEndpoint.Acquiring or lEndpoint.HoldBusy));
end;

function RecorderMic185SelfTestProbeTcpOpenCount: Integer;
begin
  Result := gMic185ProbeTcpOpenCount;
end;

procedure RecorderMic185SelfTestResetProbeTcpOpenCount;
begin
  gMic185ProbeTcpOpenCount := 0;
end;

procedure RecorderMic185RuntimeNoteProbeTcpOpen;
begin
  Inc(gMic185ProbeTcpOpenCount);
end;

function RecorderMic185RuntimeTryGetInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string): Boolean;
var
  lEndpoint: TRecorderMic185Endpoint;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  lEndpoint := RecorderMic185RuntimeFind(AHost, APort, False);
  if (lEndpoint = nil) and (RecorderMic185RuntimeTcpClientCount(AHost, APort) = 0) then
    Exit;
  if lEndpoint <> nil then
  begin
    ASerialNumber := lEndpoint.SerialNumber;
    if lEndpoint.SoftVersion <> 0 then
      AVersionText := Mic185FormatSoftVersion(lEndpoint.SoftVersion);
  end;
  Result := True;
end;

finalization
  if gMic185TcpClients <> nil then
  begin
    with gMic185TcpClients.LockList do
    try
      while Count > 0 do
        TRecorderMic185TcpClientRef(Items[0]).Free;
    finally
      gMic185TcpClients.UnlockList;
    end;
    gMic185TcpClients.Free;
  end;
  if gMic185Endpoints <> nil then
  begin
    with gMic185Endpoints.LockList do
    try
      while Count > 0 do
        TRecorderMic185Endpoint(Items[0]).Free;
    finally
      gMic185Endpoints.UnlockList;
    end;
    gMic185Endpoints.Free;
  end;

end.
