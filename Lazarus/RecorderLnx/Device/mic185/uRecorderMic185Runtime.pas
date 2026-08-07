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

{ Инициализирует общий runtime-кэш и путь лога MIC-185. }
procedure RecorderMic185RuntimeInit;
{ Пишет диагностическую строку MIC-185 в файл и общий лог. }
procedure RecorderMic185RuntimeLog(const AMessage: string);

{ Помечает endpoint занятым активным драйвером и кэширует идентификацию. }
procedure RecorderMic185RuntimeAttach(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord; AAcquiring: Boolean);
{ Обновляет флаг активного сбора для endpoint. }
procedure RecorderMic185RuntimeSetAcquiring(const AHost: string; APort: Word;
  AAcquiring: Boolean);
{ Обновляет серийный номер/версию, полученные probe или драйвером. }
procedure RecorderMic185RuntimeUpdateInfo(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord);
{ Освобождает endpoint после остановки/отключения драйвера. }
procedure RecorderMic185RuntimeDetach(const AHost: string; APort: Word);

{ Проверяет, занят ли endpoint активным сбором, hold-флагом или TCP-клиентом. }
function RecorderMic185RuntimeIsBusy(const AHost: string; APort: Word): Boolean;
{ Проверяет, есть ли другой TCP-клиент к тому же endpoint. }
function RecorderMic185RuntimeHasForeignTcpClient(const AHost: string; APort: Word;
  AClient: TObject): Boolean;
{ Регистрирует TCP-клиент, чтобы probe не открыл второй сокет к прибору. }
procedure RecorderMic185RuntimeRegisterTcpClient(AClient: TObject;
  const AHost: string; APort: Word);
{ Удаляет TCP-клиент из runtime-реестра. }
procedure RecorderMic185RuntimeUnregisterTcpClient(AClient: TObject);
{ Возвращает кэшированную идентификацию занятого endpoint. }
function RecorderMic185RuntimeTryGetInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string): Boolean;
{ Временно удерживает endpoint занятым во время критичных операций UI. }
procedure RecorderMic185RuntimeHoldBusy(const AHost: string; APort: Word;
  AHold: Boolean);

{ Счетчик probe-соединений для регрессионных тестов. }
function RecorderMic185SelfTestProbeTcpOpenCount: Integer;
{ Сбрасывает счетчик probe-соединений. }
procedure RecorderMic185SelfTestResetProbeTcpOpenCount;
{ Фиксирует попытку probe открыть TCP-сокет. }
procedure RecorderMic185RuntimeNoteProbeTcpOpen;

implementation

uses
  SyncObjs, uMic185DebugLog, uMic185MebiusTypes, uSharedFileLogger,
  uRecorderMeraPaths;

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
  gMic185InitLock: TRTLCriticalSection;
  gMic185LogReady: Boolean = False;
  gMic185ProbeTcpOpenCount: Integer = 0;

function Mic185ProjectLogPath: string;
begin
  {$IFDEF MSWINDOWS}
  Result := RecorderServiceFileName('LogWindows.log');
  {$ELSE}
  Result := RecorderServiceFileName('LogLinux.log');
  {$ENDIF}
end;

procedure RecorderMic185RuntimeInit;
begin
  if gMic185LogReady then
    Exit;
  EnterCriticalSection(gMic185InitLock);
  try
    if gMic185LogReady then
      Exit;
    { Publish the ready flag only after every shared object exists. During
      parallel cold start another device thread may enter immediately. }
    if gMic185Endpoints = nil then
      gMic185Endpoints := TThreadList.Create;
    if gMic185TcpClients = nil then
      gMic185TcpClients := TThreadList.Create;
    Mic185LogInit(Mic185ProjectLogPath);
    gMic185LogReady := True;
  finally
    LeaveCriticalSection(gMic185InitLock);
  end;
end;

procedure RecorderMic185RuntimeLog(const AMessage: string);
begin
  RecorderMic185RuntimeInit;
  Mic185Log(AMessage);
  if SharedLogger.Enabled then
    SharedLogger.Debug('[MIC185] ' + AMessage);
end;

function RecorderMic185RuntimeFindLocked(AList: TList; const AHost: string;
  APort: Word; ACreate: Boolean): TRecorderMic185Endpoint;
var
  I: Integer;
  lEndpoint: TRecorderMic185Endpoint;
  lHost: string;
begin
  Result := nil;
  lHost := Trim(AHost);
  if lHost = '' then
    Exit;
  for I := 0 to AList.Count - 1 do
  begin
    lEndpoint := TRecorderMic185Endpoint(AList[I]);
    if SameText(lEndpoint.Host, lHost) and (lEndpoint.Port = APort) then
      Exit(lEndpoint);
  end;
  if not ACreate then
    Exit;
  Result := TRecorderMic185Endpoint.Create;
  Result.Host := lHost;
  Result.Port := APort;
  AList.Add(Result);
end;

procedure RecorderMic185RuntimeAttach(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord; AAcquiring: Boolean);
var
  lEndpoint: TRecorderMic185Endpoint;
  lList: TList;
  lLogHost: string;
  lLogPort: Word;
begin
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    lEndpoint := RecorderMic185RuntimeFindLocked(lList, AHost, APort, True);
    if lEndpoint = nil then Exit;
    lEndpoint.SocketBusy := True;
    lEndpoint.Acquiring := AAcquiring;
    lEndpoint.SerialNumber := ASerialNumber;
    lEndpoint.SoftVersion := ASoftVersion;
    lLogHost := lEndpoint.Host;
    lLogPort := lEndpoint.Port;
  finally
    gMic185Endpoints.UnlockList;
  end;
  RecorderMic185RuntimeLog(Format(
    'RuntimeAttach %s:%d busy=1 acquiring=%s sn=%d',
    [lLogHost, lLogPort, BoolToStr(AAcquiring, True),
     ASerialNumber]));
end;

procedure RecorderMic185RuntimeSetAcquiring(const AHost: string; APort: Word;
  AAcquiring: Boolean);
var
  lEndpoint: TRecorderMic185Endpoint;
  lList: TList;
begin
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    lEndpoint := RecorderMic185RuntimeFindLocked(lList, AHost, APort, False);
    if lEndpoint = nil then Exit;
    lEndpoint.Acquiring := AAcquiring;
  finally
    gMic185Endpoints.UnlockList;
  end;
  RecorderMic185RuntimeLog(Format('RuntimeAcquire %s:%d acquiring=%s',
    [Trim(AHost), APort, BoolToStr(AAcquiring, True)]));
end;

procedure RecorderMic185RuntimeUpdateInfo(const AHost: string; APort: Word;
  ASerialNumber, ASoftVersion: LongWord);
var
  lEndpoint: TRecorderMic185Endpoint;
  lList: TList;
begin
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    lEndpoint := RecorderMic185RuntimeFindLocked(lList, AHost, APort, True);
    if lEndpoint = nil then Exit;
    if ASerialNumber <> 0 then lEndpoint.SerialNumber := ASerialNumber;
    if ASoftVersion <> 0 then lEndpoint.SoftVersion := ASoftVersion;
  finally
    gMic185Endpoints.UnlockList;
  end;
end;

procedure RecorderMic185RuntimeHoldBusy(const AHost: string; APort: Word;
  AHold: Boolean);
var
  lEndpoint: TRecorderMic185Endpoint;
  lList: TList;
begin
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    lEndpoint := RecorderMic185RuntimeFindLocked(lList, AHost, APort, AHold);
    if lEndpoint = nil then Exit;
    lEndpoint.HoldBusy := AHold;
  finally
    gMic185Endpoints.UnlockList;
  end;
  if not AHold then Exit;
  RecorderMic185RuntimeLog(Format('RuntimeHoldBusy %s:%d hold=1',
    [Trim(AHost), APort]));
end;

procedure RecorderMic185RuntimeDetach(const AHost: string; APort: Word);
var
  lEndpoint: TRecorderMic185Endpoint;
  lList: TList;
  lSerialNumber: LongWord;
begin
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    lEndpoint := RecorderMic185RuntimeFindLocked(lList, AHost, APort, False);
    if lEndpoint = nil then Exit;
    { Disconnect releases only the session. Keep the last confirmed identity. }
    lEndpoint.SocketBusy := False;
    lEndpoint.Acquiring := False;
    lEndpoint.HoldBusy := False;
    lSerialNumber := lEndpoint.SerialNumber;
  finally
    gMic185Endpoints.UnlockList;
  end;
  RecorderMic185RuntimeLog(Format('RuntimeDetach %s:%d keep sn=%d',
    [Trim(AHost), APort, lSerialNumber]));
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
  lList: TList;
begin
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    lEndpoint := RecorderMic185RuntimeFindLocked(lList, AHost, APort, False);
    Result := (lEndpoint <> nil) and
      (lEndpoint.SocketBusy or lEndpoint.Acquiring or lEndpoint.HoldBusy);
  finally
    gMic185Endpoints.UnlockList;
  end;
  Result := Result or (RecorderMic185RuntimeTcpClientCount(AHost, APort) > 0);
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
  lList: TList;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  RecorderMic185RuntimeInit;
  lList := gMic185Endpoints.LockList;
  try
    lEndpoint := RecorderMic185RuntimeFindLocked(lList, AHost, APort, False);
    if lEndpoint = nil then Exit;
    ASerialNumber := lEndpoint.SerialNumber;
    if lEndpoint.SoftVersion <> 0 then
      AVersionText := Mic185FormatSoftVersion(lEndpoint.SoftVersion);
    Result := True;
  finally
    gMic185Endpoints.UnlockList;
  end;
end;

initialization
  InitCriticalSection(gMic185InitLock);

finalization
  if gMic185TcpClients <> nil then
  begin
    with gMic185TcpClients.LockList do
    try
      while Count > 0 do
      begin
        TRecorderMic185TcpClientRef(Items[0]).Free;
        Delete(0);
      end;
    finally
      gMic185TcpClients.UnlockList;
    end;
    FreeAndNil(gMic185TcpClients);
  end;
  if gMic185Endpoints <> nil then
  begin
    with gMic185Endpoints.LockList do
    try
      while Count > 0 do
      begin
        TRecorderMic185Endpoint(Items[0]).Free;
        Delete(0);
      end;
    finally
      gMic185Endpoints.UnlockList;
    end;
    FreeAndNil(gMic185Endpoints);
  end;
  DoneCriticalSection(gMic185InitLock);

end.
