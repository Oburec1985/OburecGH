unit uLinuxSetupManagerNetwork;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

{ The caller runs this code in the privileged LinuxSetupManagerCli process for
  mutating actions. No private recorderlnx helper executable is invoked. }
function ExecuteNetworkSetup(AArgs: TStrings; out AOutput: string): Integer;
function ExecuteProxySetup(AArgs: TStrings; const APassword: string;
  out AOutput: string): Integer;
function ExecuteTimeSetup(AArgs: TStrings; out AOutput: string): Integer;

implementation

uses SysUtils, Process, StrUtils
  {$IFDEF UNIX}, BaseUnix, Unix{$ENDIF};

{$IFDEF UNIX}
function CFileChmod(AFd: cint; AMode: cuint): cint; cdecl;
  external 'c' name 'fchmod';
{$ENDIF}

const
  CNetworkBackup = '/var/backups/recorderlnx/network';
  CAptProxy = '/etc/apt/apt.conf.d/90recorderlnx-proxy';
  CSystemProxy = '/etc/environment.d/90-recorderlnx-proxy.conf';
  CUserProxy = '.config/environment.d/90-recorderlnx-proxy.conf';
  CTimeServers = '/etc/systemd/timesyncd.conf.d/90-recorderlnx.conf';
  CChronySetup = '/etc/chrony/conf.d/90-linuxsetupmanager.conf';
  CPrivateChrony = '/opt/mera/RecorderLnx/chronyd-private';
  CPrivateChronyConfig = '/opt/mera/RecorderLnx/chrony-server.conf';

type
  TNetworkConfig = record
    InterfaceName, Address, Gateway, Dns: string;
    Dhcp: Boolean;
    Routes: TStringList;
  end;

function RunCommand(const AExe: string; AArgs: array of string;
  out AOutput: string): Integer;
var
  lProcess: TProcess;
  lText: TStringStream;
  lIndex: Integer;
begin
  AOutput := '';
  lProcess := TProcess.Create(nil);
  lText := TStringStream.Create('');
  try
    lProcess.Executable := AExe;
    for lIndex := Low(AArgs) to High(AArgs) do
      lProcess.Parameters.Add(AArgs[lIndex]);
    lProcess.Options := [poUsePipes, poStderrToOutPut];
    try
      lProcess.Execute;
      lText.CopyFrom(lProcess.Output, 0);
      lProcess.WaitOnExit;
      AOutput := lText.DataString;
      Result := lProcess.ExitStatus;
    except
      on E: Exception do begin AOutput := E.Message; Result := 2; end;
    end;
  finally
    lText.Free;
    lProcess.Free;
  end;
end;

function ArgValue(AArgs: TStrings; const AOption: string): string;
var lIndex: Integer;
begin
  Result := '';
  for lIndex := 0 to AArgs.Count - 2 do
    if AArgs[lIndex] = AOption then Exit(AArgs[lIndex + 1]);
end;

function HasArg(AArgs: TStrings; const AOption: string): Boolean;
begin Result := AArgs.IndexOf(AOption) >= 0; end;

function IsSafeName(const AValue: string): Boolean;
var lChar: Char;
begin
  Result := AValue <> '';
  for lChar in AValue do
    if not (lChar in ['a'..'z','A'..'Z','0'..'9','_','-', '.', ':']) then
      Exit(False);
end;

function IsSafeZone(const AValue: string): Boolean;
var lChar: Char;
begin
  Result := (AValue <> '') and (Pos('..', AValue) = 0) and
    (AValue[1] <> '/');
  for lChar in AValue do
    if not (lChar in ['a'..'z','A'..'Z','0'..'9','_','-','+','/']) then
      Exit(False);
end;

function IsSafeServerList(const AValue: string): Boolean;
var lChar: Char;
begin
  Result := AValue <> '';
  for lChar in AValue do
    if not (lChar in ['a'..'z','A'..'Z','0'..'9','_','-', '.', ':', ',']) then
      Exit(False);
end;

function IsIpv4(const AValue: string): Boolean;
var lParts: TStringList; lIndex, lNumber: Integer;
begin
  Result := False;
  lParts := TStringList.Create;
  try
    lParts.Delimiter := '.';
    lParts.StrictDelimiter := True;
    lParts.DelimitedText := AValue;
    if lParts.Count <> 4 then Exit;
    for lIndex := 0 to 3 do
    begin
      if (lParts[lIndex] = '') or (Length(lParts[lIndex]) > 3) or
        not TryStrToInt(lParts[lIndex], lNumber) or
        (lNumber < 0) or (lNumber > 255) then Exit;
    end;
    Result := True;
  finally lParts.Free; end;
end;

function IsCidr(const AValue: string): Boolean;
var lSlash, lPrefix: Integer;
begin
  lSlash := Pos('/', AValue);
  Result := (lSlash > 0) and
    IsIpv4(Copy(AValue, 1, lSlash - 1)) and
    TryStrToInt(Copy(AValue, lSlash + 1, MaxInt), lPrefix) and
    (lPrefix >= 0) and (lPrefix <= 32);
end;

function ValidateNetwork(var AConfig: TNetworkConfig; out AError: string): Boolean;
var lIndex, lEqual: Integer; lParts: TStringList; lRoute: string;
begin
  AError := '';
  if not IsSafeName(AConfig.InterfaceName) or
    not DirectoryExists('/sys/class/net/' + AConfig.InterfaceName) then
    AError := 'Интерфейс не найден или имеет недопустимое имя.'
  else if (not AConfig.Dhcp) and (not IsCidr(AConfig.Address)) then
    AError := 'Ожидается адрес IPv4/CIDR.'
  else if (AConfig.Gateway <> '') and not IsIpv4(AConfig.Gateway) then
    AError := 'Некорректный шлюз IPv4.';
  lParts := TStringList.Create;
  try
    lParts.Delimiter := ','; lParts.StrictDelimiter := True;
    lParts.DelimitedText := AConfig.Dns;
    for lIndex := 0 to lParts.Count - 1 do
      if (lParts[lIndex] <> '') and not IsIpv4(lParts[lIndex]) then
        AError := 'Некорректный DNS: ' + lParts[lIndex];
  finally lParts.Free; end;
  for lIndex := 0 to AConfig.Routes.Count - 1 do
  begin
    lRoute := AConfig.Routes[lIndex];
    lEqual := Pos('=', lRoute);
    if (lEqual < 2) or not IsCidr(Copy(lRoute, 1, lEqual - 1)) or
      ((Copy(lRoute, lEqual + 1, MaxInt) <> '-') and
       not IsIpv4(Copy(lRoute, lEqual + 1, MaxInt))) then
      AError := 'Маршрут задаётся СЕТЬ/CIDR=ШЛЮЗ или СЕТЬ/CIDR=-.';
  end;
  Result := AError = '';
end;

function ReadNetworkArgs(AArgs: TStrings; var AConfig: TNetworkConfig;
  out AError: string): Boolean;
var lIndex: Integer;
begin
  AConfig.InterfaceName := ArgValue(AArgs, '--interface');
  AConfig.Address := ArgValue(AArgs, '--address');
  AConfig.Gateway := ArgValue(AArgs, '--gateway');
  AConfig.Dns := ArgValue(AArgs, '--dns');
  AConfig.Dhcp := HasArg(AArgs, '--dhcp');
  for lIndex := 1 to AArgs.Count - 2 do
    if AArgs[lIndex] = '--route' then
      AConfig.Routes.Add(AArgs[lIndex + 1]);
  if AConfig.Dhcp = (AConfig.Address <> '') then
  begin AError := 'Укажите ровно один режим: --dhcp или --address.'; Exit(False); end;
  Result := ValidateNetwork(AConfig, AError);
end;

function NetworkBackend: string;
var lText: string;
begin
  Result := '';
  if RunCommand('systemctl', ['is-active', '--quiet', 'NetworkManager'], lText) = 0 then
    Exit('NetworkManager');
  if RunCommand('systemctl', ['is-active', '--quiet', 'systemd-networkd'], lText) = 0 then
    Exit('systemd-networkd');
  if FileExists('/etc/network/interfaces') then Exit('ifupdown');
end;

function NetworkPlan(const AConfig: TNetworkConfig; const ABackend: string): string;
var lIndex: Integer;
begin
  Result := 'Backend: ' + ABackend + LineEnding +
    'Интерфейс: ' + AConfig.InterfaceName + LineEnding;
  if AConfig.Dhcp then Result := Result + 'Режим: DHCP' + LineEnding
  else Result := Result + 'Адрес: ' + AConfig.Address + LineEnding;
  if AConfig.Gateway <> '' then Result := Result + 'Шлюз: ' + AConfig.Gateway + LineEnding;
  if AConfig.Dns <> '' then Result := Result + 'DNS: ' + AConfig.Dns + LineEnding;
  for lIndex := 0 to AConfig.Routes.Count - 1 do
    Result := Result + 'Маршрут: ' + AConfig.Routes[lIndex] + LineEnding;
  Result := Result + 'Применение может прервать текущую сеть и SSH-сеанс.' + LineEnding;
end;

function SaveFile(const APath, AText: string; AMode: LongInt;
  out AError: string): Boolean;
{$IFDEF UNIX}
var lFd: cint; lBytes: UTF8String;
{$ENDIF}
begin
  AError := '';
  if not ForceDirectories(ExtractFileDir(APath)) then
  begin AError := 'Не удалось создать каталог: ' + ExtractFileDir(APath); Exit(False); end;
  {$IFDEF UNIX}
  lFd := fpOpen(PChar(APath), O_WRONLY or O_CREAT or O_TRUNC, AMode);
  if lFd < 0 then begin AError := 'Не удалось открыть: ' + APath; Exit(False); end;
  try
    if CFileChmod(lFd, AMode) <> 0 then
    begin AError := 'Не удалось установить права файла: ' + APath; Exit(False); end;
    lBytes := UTF8String(AText);
    Result := fpWrite(lFd, lBytes[1], Length(lBytes)) = Length(lBytes);
    if not Result then AError := 'Не удалось записать: ' + APath;
  finally fpClose(lFd); end;
  {$ELSE}
  AError := 'Изменение системных файлов доступно только в Linux.';
  Result := False;
  {$ENDIF}
end;

function BackupFile(const APath: string; out ABackup, AError: string): Boolean;
var lStamp, lText: string; lLines: TStringList;
begin
  ABackup := '';
  AError := '';
  if not FileExists(APath) then Exit(True);
  lStamp := FormatDateTime('yyyymmdd-hhnnss-zzz', Now);
  ABackup := CNetworkBackup + '/' + lStamp + APath;
  lLines := TStringList.Create;
  try
    try
      lLines.LoadFromFile(APath);
      lText := lLines.Text;
      Result := SaveFile(ABackup, lText, 384, AError);
    except on E: Exception do begin AError := E.Message; Result := False; end; end;
  finally lLines.Free; end;
end;

function ApplyNetworkd(const AConfig: TNetworkConfig; out AOutput: string): Integer;
var lPath, lBackup, lText, lError, lRoute, lVia: string; lIndex, lEqual: Integer;
begin
  lPath := '/etc/systemd/network/90-recorderlnx-' + AConfig.InterfaceName + '.network';
  if not BackupFile(lPath, lBackup, lError) then
  begin AOutput := lError; Exit(2); end;
  lText := '[Match]' + LineEnding + 'Name=' + AConfig.InterfaceName +
    LineEnding + LineEnding + '[Network]' + LineEnding;
  if AConfig.Dhcp then lText := lText + 'DHCP=ipv4' + LineEnding
  else
  begin
    lText := lText + 'Address=' + AConfig.Address + LineEnding;
    if AConfig.Gateway <> '' then lText := lText + 'Gateway=' + AConfig.Gateway + LineEnding;
    for lRoute in AConfig.Dns.Split([',']) do
      if lRoute <> '' then lText := lText + 'DNS=' + lRoute + LineEnding;
    for lIndex := 0 to AConfig.Routes.Count - 1 do
    begin
      lRoute := AConfig.Routes[lIndex]; lEqual := Pos('=', lRoute);
      lVia := Copy(lRoute, lEqual + 1, MaxInt);
      lText := lText + LineEnding + '[Route]' + LineEnding +
        'Destination=' + Copy(lRoute, 1, lEqual - 1) + LineEnding;
      if lVia <> '-' then lText := lText + 'Gateway=' + lVia + LineEnding;
    end;
  end;
  if not SaveFile(lPath, lText, 420, lError) then
  begin AOutput := lError; Exit(2); end;
  Result := RunCommand('networkctl', ['reload'], AOutput);
  if Result = 0 then Result := RunCommand('networkctl',
    ['reconfigure', AConfig.InterfaceName], AOutput);
  if lBackup <> '' then AOutput := AOutput + LineEnding + 'Резервная копия: ' + lBackup;
end;

function ApplyNmcli(const AConfig: TNetworkConfig; out AOutput: string): Integer;
var lConnection, lText, lRoutes, lRoute, lVia: string; lIndex, lEqual: Integer;
begin
  Result := RunCommand('nmcli', ['-g', 'GENERAL.CONNECTION', 'device',
    'show', AConfig.InterfaceName], lConnection);
  if Result <> 0 then begin AOutput := lConnection; Exit; end;
  lConnection := Trim(lConnection);
  if (lConnection = '') or (lConnection = '--') then
  begin AOutput := 'Нет активного профиля NetworkManager для интерфейса.'; Exit(2); end;
  { Preserve the full active profile, not only the fields changed here. }
  if not ForceDirectories(CNetworkBackup) then
  begin AOutput := 'Не удалось создать каталог резервных копий.'; Exit(2); end;
  Result := RunCommand('nmcli', ['-g', 'connection.id,ipv4.method,ipv4.addresses,' +
    'ipv4.gateway,ipv4.dns,ipv4.routes', 'connection', 'show', lConnection], lText);
  if Result <> 0 then begin AOutput := lText; Exit; end;
  if not SaveFile(CNetworkBackup + '/nmcli-' +
    FormatDateTime('yyyymmdd-hhnnss-zzz', Now) + '.txt', lText, 384, AOutput) then
    Exit(2);
  if AConfig.Dhcp then
    Result := RunCommand('nmcli', ['connection', 'modify', lConnection,
      'ipv4.method', 'auto', 'ipv4.addresses', '', 'ipv4.gateway', '',
      'ipv4.dns', '', 'ipv4.routes', ''], AOutput)
  else
  begin
    lRoutes := '';
    for lIndex := 0 to AConfig.Routes.Count - 1 do
    begin
      lRoute := AConfig.Routes[lIndex]; lEqual := Pos('=', lRoute);
      lVia := Copy(lRoute, lEqual + 1, MaxInt);
      if lRoutes <> '' then lRoutes := lRoutes + ', ';
      lRoutes := lRoutes + Copy(lRoute, 1, lEqual - 1);
      if lVia <> '-' then lRoutes := lRoutes + ' ' + lVia;
    end;
    Result := RunCommand('nmcli', ['connection', 'modify', lConnection,
      'ipv4.method', 'manual', 'ipv4.addresses', AConfig.Address,
      'ipv4.gateway', AConfig.Gateway, 'ipv4.dns',
      StringReplace(AConfig.Dns, ',', ' ', [rfReplaceAll]),
      'ipv4.routes', lRoutes], AOutput);
  end;
  if Result = 0 then Result := RunCommand('nmcli',
    ['connection', 'up', lConnection], AOutput);
end;

function ApplyIfupdown(const AConfig: TNetworkConfig; out AOutput: string): Integer;
var lPath, lBackup, lError, lText, lRoute, lVia: string; lIndex, lEqual: Integer;
begin
  lPath := '/etc/network/interfaces.d/90-recorderlnx-' + AConfig.InterfaceName;
  if not BackupFile(lPath, lBackup, lError) then
  begin AOutput := lError; Exit(2); end;
  lText := 'auto ' + AConfig.InterfaceName + LineEnding + 'iface ' +
    AConfig.InterfaceName + ' inet ';
  if AConfig.Dhcp then lText := lText + 'dhcp' + LineEnding
  else
  begin
    lText := lText + 'static' + LineEnding + '    address ' + AConfig.Address + LineEnding;
    if AConfig.Gateway <> '' then lText := lText + '    gateway ' + AConfig.Gateway + LineEnding;
    if AConfig.Dns <> '' then lText := lText + '    dns-nameservers ' +
      StringReplace(AConfig.Dns, ',', ' ', [rfReplaceAll]) + LineEnding;
    for lIndex := 0 to AConfig.Routes.Count - 1 do
    begin
      lRoute := AConfig.Routes[lIndex]; lEqual := Pos('=', lRoute);
      lVia := Copy(lRoute, lEqual + 1, MaxInt);
      lText := lText + '    up ip route replace ' +
        Copy(lRoute, 1, lEqual - 1);
      if lVia <> '-' then lText := lText + ' via ' + lVia;
      lText := lText + ' dev ' + AConfig.InterfaceName + LineEnding;
    end;
  end;
  if not SaveFile(lPath, lText, 420, lError) then
  begin AOutput := lError; Exit(2); end;
  RunCommand('ifdown', [AConfig.InterfaceName], AOutput);
  Result := RunCommand('ifup', [AConfig.InterfaceName], AOutput);
  if lBackup <> '' then AOutput := AOutput + LineEnding + 'Резервная копия: ' + lBackup;
end;

function ExecuteNetworkSetup(AArgs: TStrings; out AOutput: string): Integer;
var lConfig: TNetworkConfig; lAction, lError, lBackend, lRoutes: string;
begin
  Result := 2; AOutput := '';
  if AArgs.Count = 0 then begin AOutput := 'Нужна команда show, plan или apply.'; Exit; end;
  lAction := AArgs[0];
  if lAction = 'show' then
  begin
    lError := ArgValue(AArgs, '--interface');
    if lError <> '' then Result := RunCommand('ip',
      ['-brief', 'address', 'show', 'dev', lError], AOutput)
    else Result := RunCommand('ip', ['-brief', 'address'], AOutput);
    if Result = 0 then
    begin
      if lError <> '' then Result := RunCommand('ip',
        ['route', 'show', 'dev', lError], lRoutes)
      else Result := RunCommand('ip', ['route', 'show'], lRoutes);
      AOutput := AOutput + LineEnding + lRoutes;
    end;
    Exit;
  end;
  if (lAction <> 'plan') and (lAction <> 'apply') then
  begin AOutput := 'Нужна команда show, plan или apply.'; Exit; end;
  lConfig.Routes := TStringList.Create;
  try
    if not ReadNetworkArgs(AArgs, lConfig, lError) then
    begin AOutput := lError; Exit; end;
    lBackend := NetworkBackend;
    if lBackend = '' then begin AOutput := 'Сетевой backend не найден.'; Exit; end;
    AOutput := NetworkPlan(lConfig, lBackend);
    if lAction = 'plan' then Exit(0);
    {$IFDEF UNIX}
    if fpGetEUid <> 0 then begin AOutput := 'Нужны права root.'; Exit; end;
    {$ENDIF}
    case lBackend of
      'NetworkManager': Result := ApplyNmcli(lConfig, AOutput);
      'systemd-networkd': Result := ApplyNetworkd(lConfig, AOutput);
      'ifupdown': Result := ApplyIfupdown(lConfig, AOutput);
    end;
  finally lConfig.Routes.Free; end;
end;

function UrlEncode(const AValue: string): string;
var lChar: Char;
begin
  Result := '';
  for lChar in AValue do
    if lChar in ['a'..'z','A'..'Z','0'..'9','.','_','~','-'] then
      Result := Result + lChar
    else Result := Result + '%' + IntToHex(Ord(lChar), 2);
end;

function ValidProxyHost(const AValue: string): Boolean;
begin Result := IsSafeName(AValue) and (Pos(':', AValue) = 0); end;

function UserHome(const AUser: string; out AHome: string): Boolean;
var lText: string; lFields: TStringList;
begin
  Result := False; AHome := '';
  if not IsSafeName(AUser) then Exit;
  if RunCommand('getent', ['passwd', AUser], lText) <> 0 then Exit;
  lFields := TStringList.Create;
  try
    lFields.Delimiter := ':'; lFields.StrictDelimiter := True;
    lFields.DelimitedText := Trim(lText);
    if lFields.Count > 5 then AHome := lFields[5];
    Result := (AHome <> '') and DirectoryExists(AHome);
  finally lFields.Free; end;
end;

function ProxyPath(const AScope, AHome: string): string;
begin
  if AScope = 'user' then Result := IncludeTrailingPathDelimiter(AHome) + CUserProxy
  else Result := CSystemProxy;
end;

function ProxyText(const AUrl: string): string;
begin
  Result := 'http_proxy="' + AUrl + '"' + LineEnding +
    'https_proxy="' + AUrl + '"' + LineEnding +
    'HTTP_PROXY="' + AUrl + '"' + LineEnding +
    'HTTPS_PROXY="' + AUrl + '"' + LineEnding;
end;

function RemoveFile(const APath: string; out AOutput: string): Integer;
begin
  if not FileExists(APath) or DeleteFile(APath) then
  begin AOutput := 'Удалено: ' + APath; Result := 0; end
  else begin AOutput := 'Не удалось удалить: ' + APath; Result := 2; end;
end;

function ExecuteProxySetup(AArgs: TStrings; const APassword: string;
  out AOutput: string): Integer;
var lAction, lScope, lUser, lHost, lPort, lLogin, lHome, lUrl,
    lError, lText, lPath: string; lPortNum: Integer;
begin
  Result := 2; AOutput := '';
  if AArgs.Count = 0 then begin AOutput := 'Нужна команда show, plan, apply или remove.'; Exit; end;
  lAction := AArgs[0];
  lScope := ArgValue(AArgs, '--scope');
  if lScope = '' then lScope := 'both';
  if lScope = 'apt' then lScope := 'system';
  if not ((lScope = 'user') or (lScope = 'system') or (lScope = 'both')) then
  begin AOutput := 'Область: user, system или both.'; Exit; end;
  lUser := ArgValue(AArgs, '--user');
  if lUser = '' then lUser := GetEnvironmentVariable('SUDO_USER');
  if lUser = '' then lUser := GetEnvironmentVariable('USER');
  if ((lScope = 'user') or (lScope = 'both')) and not UserHome(lUser, lHome) then
  begin AOutput := 'Пользователь не найден: ' + lUser; Exit; end;
  if (lAction = 'show') or (lAction = 'export') then
  begin
    AOutput := 'Прокси (секреты скрыты):' + LineEnding;
    if lScope <> 'user' then
      AOutput := AOutput + CAptProxy + ': ' + BoolToStr(FileExists(CAptProxy), True) +
        LineEnding + CSystemProxy + ': ' + BoolToStr(FileExists(CSystemProxy), True) + LineEnding;
    if lScope <> 'system' then
      AOutput := AOutput + ProxyPath('user', lHome) + ': ' +
        BoolToStr(FileExists(ProxyPath('user', lHome)), True) + LineEnding;
    Exit(0);
  end;
  if lAction = 'plan' then
  begin
    AOutput := 'Изменятся настройки прокси для ' + lScope +
      '. Пароль скрыт и не передаётся через аргументы процесса.';
    Exit(0);
  end;
  if (lAction <> 'apply') and (lAction <> 'remove') then
  begin AOutput := 'Нужна команда show, plan, apply или remove.'; Exit; end;
  {$IFDEF UNIX}
  if fpGetEUid <> 0 then begin AOutput := 'Нужны права root.'; Exit; end;
  {$ENDIF}
  if lAction = 'remove' then
  begin
    Result := 0;
    if lScope <> 'user' then
    begin
      Result := RemoveFile(CAptProxy, lText); AOutput := lText + LineEnding;
      if Result <> 0 then Exit;
      Result := RemoveFile(CSystemProxy, lText); AOutput := AOutput + lText + LineEnding;
      if Result <> 0 then Exit;
    end;
    if lScope <> 'system' then
    begin Result := RemoveFile(ProxyPath('user', lHome), lText);
      AOutput := AOutput + lText; end;
    Exit;
  end;
  lHost := ArgValue(AArgs, '--host'); lPort := ArgValue(AArgs, '--port');
  lLogin := ArgValue(AArgs, '--login');
  if not ValidProxyHost(lHost) or not TryStrToInt(lPort, lPortNum) or
    (lPortNum < 1) or (lPortNum > 65535) then
  begin AOutput := 'Некорректный хост или порт прокси.'; Exit; end;
  lUrl := 'http://';
  if lLogin <> '' then
  begin
    lUrl := lUrl + UrlEncode(lLogin);
    if APassword <> '' then lUrl := lUrl + ':' + UrlEncode(APassword);
    lUrl := lUrl + '@';
  end;
  lUrl := lUrl + lHost + ':' + lPort + '/';
  if lScope <> 'user' then
  begin
    lText := 'Acquire::http::Proxy "' + lUrl + '";' + LineEnding +
      'Acquire::https::Proxy "' + lUrl + '";' + LineEnding;
    if not SaveFile(CAptProxy, lText, 384, lError) then
    begin AOutput := lError; Exit; end;
    if not SaveFile(CSystemProxy, ProxyText(lUrl), 384, lError) then
    begin AOutput := lError; Exit; end;
  end;
  if lScope <> 'system' then
  begin
    lPath := ProxyPath('user', lHome);
    if not SaveFile(lPath, ProxyText(lUrl), 384, lError) then
    begin AOutput := lError; Exit; end;
    Result := RunCommand('chown', [lUser, lPath], lText);
    if Result <> 0 then begin AOutput := 'Не удалось назначить владельца: ' + lText; Exit; end;
  end;
  AOutput := 'Прокси настроен: ' + lHost + ':' + lPort + ' (учётные данные скрыты).';
  Result := 0;
end;

function ExecuteTimeSetup(AArgs: TStrings; out AOutput: string): Integer;
var lAction, lSub, lServers, lFallback, lText, lError, lConfig: string;
begin
  Result := 2; AOutput := '';
  if AArgs.Count = 0 then begin AOutput := 'Нужна команда времени.'; Exit; end;
  lAction := AArgs[0];
  if lAction = 'show' then
  begin
    Result := RunCommand('timedatectl', ['status'], AOutput);
    if RunCommand('systemctl', ['is-active', '--quiet', 'chrony.service'], lText) = 0 then
    begin
      if RunCommand('chronyc', ['tracking'], lText) = 0 then
        AOutput := AOutput + LineEnding + lText;
      if RunCommand('chronyc', ['sources', '-v'], lText) = 0 then
        AOutput := AOutput + LineEnding + lText;
    end;
    Exit;
  end;
  if lAction = 'list-timezones' then
    Exit(RunCommand('timedatectl', ['list-timezones'], AOutput));
  {$IFDEF UNIX}
  if fpGetEUid <> 0 then begin AOutput := 'Нужны права root.'; Exit; end;
  {$ENDIF}
  if lAction = 'set-timezone' then
  begin
    if AArgs.Count <> 2 then begin AOutput := 'Укажите часовой пояс.'; Exit; end;
    if not IsSafeZone(AArgs[1]) or not FileExists('/usr/share/zoneinfo/' + AArgs[1]) then
    begin AOutput := 'Неизвестный часовой пояс.'; Exit; end;
    Exit(RunCommand('timedatectl', ['set-timezone', AArgs[1]], AOutput));
  end;
  if lAction = 'ntp' then
  begin
    if AArgs.Count <> 2 then begin AOutput := 'Укажите enable или disable.'; Exit; end;
    if AArgs[1] = 'enable' then lSub := 'true'
    else if AArgs[1] = 'disable' then lSub := 'false'
    else begin AOutput := 'Укажите enable или disable.'; Exit; end;
    Exit(RunCommand('timedatectl', ['set-ntp', lSub], AOutput));
  end;
  if (lAction = 'ntp-server') or (lAction = 'ntp-client') then
  begin
    if AArgs.Count <> 2 then
    begin AOutput := 'Укажите подсеть клиентов или хост NTP-сервера.'; Exit; end;
    if lAction = 'ntp-server' then
    begin
      if not IsCidr(AArgs[1]) then
      begin AOutput := 'Укажите подсеть IPv4/CIDR, например 192.168.1.0/24.'; Exit; end;
      lConfig := 'allow ' + AArgs[1] + LineEnding +
        'local stratum 10' + LineEnding;
    end
    else
    begin
      if not IsSafeName(AArgs[1]) then
      begin AOutput := 'Недопустимый хост NTP-сервера.'; Exit; end;
      lText := '[Time]' + LineEnding + 'NTP=' + LineEnding +
        'NTP=' + AArgs[1] + LineEnding + 'FallbackNTP=' + LineEnding;
      if not SaveFile(CTimeServers, lText, 420, lError) then
      begin AOutput := lError; Exit; end;
      Result := RunCommand('systemctl',
        ['restart', 'systemd-timesyncd.service'], AOutput);
      if Result = 0 then
        Result := RunCommand('timedatectl', ['set-ntp', 'true'], AOutput);
      if Result = 0 then AOutput := 'NTP-клиент настроен: ' + AArgs[1];
      Exit;
    end;
    if (lAction = 'ntp-server') and FileExists(CPrivateChrony) then
    begin
      lConfig := lConfig + 'cmdport 0' + LineEnding +
        'pidfile /run/recorderlnx-ntp-server.pid' + LineEnding;
      if not SaveFile(CPrivateChronyConfig, lConfig, 420, lError) then
      begin AOutput := lError; Exit; end;
      Result := RunCommand(CPrivateChrony,
        ['-p', '-f', CPrivateChronyConfig], AOutput);
      if Result <> 0 then Exit;
      Result := RunCommand('systemctl',
        ['enable', '--now', 'recorderlnx-ntp-server.service'], AOutput);
      if Result <> 0 then Exit;
      Result := RunCommand('systemctl',
        ['restart', 'recorderlnx-ntp-server.service'], AOutput);
      if Result = 0 then AOutput := 'NTP-сервер настроен: ' + AArgs[1];
      Exit;
    end;
    if not FileExists('/usr/sbin/chronyd') and not FileExists('/usr/bin/chronyd') then
    begin AOutput := 'Chrony не установлен. Установите пакет chrony.'; Exit; end;
    if not SaveFile(CChronySetup, lConfig, 420, lError) then
    begin AOutput := lError; Exit; end;
    RunCommand('systemctl', ['disable', '--now', 'systemd-timesyncd.service'], lText);
    Result := RunCommand('systemctl', ['enable', '--now', 'chrony.service'], AOutput);
    if Result <> 0 then Exit;
    Result := RunCommand('systemctl', ['restart', 'chrony.service'], AOutput);
    if Result <> 0 then Exit;
    if lAction = 'ntp-server' then
    begin
      if RunCommand('ufw', ['status'], lText) = 0 then
        if Pos('Status: active', lText) > 0 then
        begin
          Result := RunCommand('ufw', ['allow', 'from', AArgs[1],
            'to', 'any', 'port', '123', 'proto', 'udp'], AOutput);
          if Result <> 0 then Exit;
        end;
    end;
    AOutput := 'Chrony настроен: ' + lConfig;
    Exit;
  end;
  if lAction = 'ntp-servers' then
  begin
    if AArgs.Count < 2 then begin AOutput := 'Укажите список серверов.'; Exit; end;
    if AArgs[1] = 'remove' then
    begin
      Result := RemoveFile(CTimeServers, AOutput);
      if Result = 0 then RunCommand('systemctl',
        ['restart', 'systemd-timesyncd.service'], lText);
      Exit;
    end;
    lServers := AArgs[1]; lFallback := ArgValue(AArgs, '--fallback');
    if not IsSafeServerList(lServers) or
      ((lFallback <> '') and not IsSafeServerList(lFallback)) then
    begin AOutput := 'Недопустимый NTP-сервер.'; Exit; end;
    lText := '[Time]' + LineEnding + 'NTP=' + LineEnding + 'NTP=' +
      StringReplace(lServers, ',', ' ', [rfReplaceAll]) + LineEnding;
    lText := lText + 'FallbackNTP=' + LineEnding;
    if lFallback <> '' then lText := lText + 'FallbackNTP=' +
      StringReplace(lFallback, ',', ' ', [rfReplaceAll]) + LineEnding;
    if not SaveFile(CTimeServers, lText, 420, lError) then
    begin AOutput := lError; Exit; end;
    Result := RunCommand('systemctl',
      ['restart', 'systemd-timesyncd.service'], AOutput);
    if Result = 0 then Result := RunCommand('timedatectl', ['set-ntp', 'true'], AOutput);
    Exit;
  end;
  AOutput := 'Неизвестная команда времени.';
end;

end.
