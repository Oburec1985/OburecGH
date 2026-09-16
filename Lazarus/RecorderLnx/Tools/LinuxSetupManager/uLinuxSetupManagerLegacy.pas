unit uLinuxSetupManagerLegacy;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

function ExecuteLegacySetup(const Section: string; Args: TStrings;
  out Output: string): Integer;

implementation

uses SysUtils, Process, fpjson
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

const
  CRegistry = '/etc/recorderlnx/network-shares.d';
  CMountRoot = '/home/user/Сеть/MeraFiles';
  CCredentials = '/etc/samba/kip-obmen.credentials';
  CWolService = '/etc/systemd/system/recorderlnx-wol.service';

function Run(const ProgramName: string; const Arguments: array of string;
  out Text: string; const WorkingDir: string = ''): Boolean;
var
  P: TProcess;
  Buffer: array[0..4095] of Byte;
  Count, I: Integer;
  Stream: TMemoryStream;
begin
  Text := '';
  Result := False;
  P := TProcess.Create(nil);
  Stream := TMemoryStream.Create;
  try
    P.Executable := ProgramName;
    if WorkingDir <> '' then P.CurrentDirectory := WorkingDir;
    for I := Low(Arguments) to High(Arguments) do P.Parameters.Add(Arguments[I]);
    P.Options := [poUsePipes, poStderrToOutPut];
    try
      P.Execute;
      while P.Running or (P.Output.NumBytesAvailable > 0) do
      begin
        Count := P.Output.Read(Buffer, SizeOf(Buffer));
        if Count > 0 then Stream.WriteBuffer(Buffer, Count);
      end;
      P.WaitOnExit;
      SetLength(Text, Stream.Size);
      if Stream.Size > 0 then
      begin
        Stream.Position := 0;
        Stream.ReadBuffer(Text[1], Stream.Size);
      end;
      Result := P.ExitStatus = 0;
    except on E: Exception do Text := E.Message; end;
  finally
    Stream.Free;
    P.Free;
  end;
end;

function NeedRun(const ProgramName: string; const Arguments: array of string;
  out Output: string): Boolean; forward;
function SaveSystemFile(const Path, Content: string;
  out ErrorText: string): Boolean; forward;

function UserInfo(out UserName, HomeDir, ErrorText: string): Boolean;
var Uid, Entry: string; Parts: TStringArray;
begin
  Result := False;
  Uid := GetEnvironmentVariable('PKEXEC_UID');
  if Uid <> '' then
  begin
    if not Run('getent', ['passwd', Uid], Entry) then
    begin ErrorText := 'Пользователь PKEXEC_UID не найден.'; Exit; end;
    Parts := Entry.Split(':');
    if Length(Parts) < 6 then Exit;
    UserName := Parts[0];
    HomeDir := Parts[5];
  end
  else
  begin
    UserName := GetEnvironmentVariable('SUDO_USER');
    if UserName = '' then UserName := 'user';
    if not Run('getent', ['passwd', UserName], Entry) then
    begin ErrorText := 'Пользователь рабочего стола не найден.'; Exit; end;
    Parts := Entry.Split(':');
    if Length(Parts) < 6 then Exit;
    HomeDir := Parts[5];
  end;
  Result := (UserName <> '') and (HomeDir <> '') and
    (HomeDir[1] = '/');
  if not Result then ErrorText := 'Некорректная запись пользователя.';
end;

function SetMimeDefault(const UserName, HomeDir, DesktopId,
  MimeType: string; out Output: string): Boolean;
begin
  Result := Run('runuser', ['-u', UserName, '--', 'env',
    'HOME=' + HomeDir, 'XDG_CONFIG_HOME=' + HomeDir + '/.config',
    'xdg-mime', 'default', DesktopId, MimeType], Output);
end;

function XmlPackage(const MimeType, Extension, Comment: string): string;
begin
  Result := '<?xml version="1.0" encoding="UTF-8"?>' + LineEnding +
    '<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">' + LineEnding +
    '  <mime-type type="' + MimeType + '">' + LineEnding +
    '    <comment>' + Comment + '</comment>' + LineEnding +
    '    <glob pattern="*.' + Extension + '" weight="100"/>' + LineEnding +
    '  </mime-type>' + LineEnding + '</mime-info>' + LineEnding;
end;

function DesktopArgument(const Value: string): string;
begin
  Result := StringReplace(Value, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, '$', '\$', [rfReplaceAll]);
  Result := StringReplace(Result, '`', '\`', [rfReplaceAll]);
  Result := '"' + Result + '"';
end;

function InstallAssociation(const Extension, MimeType, DesktopId,
  DesktopName, ExecArgs: string; out Output: string): Boolean;
var Desktop: string;
begin
  Result := False;
  if not SaveSystemFile('/usr/share/mime/packages/recorderlnx-' +
    Extension + '.xml', XmlPackage(MimeType, Extension, DesktopName), Output) then Exit;
  Desktop := '[Desktop Entry]' + LineEnding + 'Type=Application' + LineEnding +
    'Name=' + DesktopName + LineEnding +
    'Exec=/opt/mera/RecorderLnx/LinuxSetupManager --internal ' +
    ExecArgs + ' %f' + LineEnding +
    'Terminal=false' + LineEnding + 'MimeType=' + MimeType + ';';
  if Extension = 'mera' then
    Desktop += 'application/x-wine-extension-mera;';
  Desktop +=
    LineEnding + 'NoDisplay=true' + LineEnding +
    'Categories=Utility;' + LineEnding;
  if not SaveSystemFile('/usr/share/applications/' + DesktopId,
    Desktop, Output) then Exit;
  if not NeedRun('update-mime-database', ['/usr/share/mime'], Output) then Exit;
  Result := NeedRun('update-desktop-database',
    ['/usr/share/applications'], Output);
end;

function AssociateMera(const Args: TStrings; out Output: string): Integer;
var UserName, HomeDir: string;
begin
  Result := 1;
  if Args.Count <> 0 then begin Output := 'associate-mera не принимает аргументы.'; Exit; end;
  if not FileExists('/opt/mera/RecorderLnx/LinuxSetupManager') then
  begin Output := 'LinuxSetupManager не установлен в /opt/mera/RecorderLnx.'; Exit; end;
  if not UserInfo(UserName, HomeDir, Output) then Exit;
  if not InstallAssociation('mera', 'application/x-mera-measurement',
    'recorderlnx-winpos.desktop', 'WinPOS', 'open-mera', Output) then Exit;
  if not SetMimeDefault(UserName, HomeDir, 'recorderlnx-winpos.desktop',
    'application/x-mera-measurement', Output) then Exit;
  if not SetMimeDefault(UserName, HomeDir, 'recorderlnx-winpos.desktop',
    'application/x-wine-extension-mera', Output) then Exit;
  Output := '.mera -> WinPOS (' + UserName + ')';
  Result := 0;
end;

function AssociateFile(const Args: TStrings; out Output: string): Integer;
var Extension, ProgramName, UserName, HomeDir, MimeType, DesktopId: string;
    I: Integer;
begin
  Result := 1;
  if Args.Count <> 2 then
  begin Output := 'associate-file ФАЙЛ ПРОГРАММА'; Exit; end;
  if not FileExists(Args[0]) then
  begin Output := 'Файл-пример не найден.'; Exit; end;
  ProgramName := ExpandFileName(Args[1]);
  if (ProgramName[1] <> '/') or not FileExists(ProgramName) then
  begin Output := 'Программа не найдена.'; Exit; end;
  Extension := ExtractFileExt(Args[0]);
  if Extension = '' then
  begin Output := 'У файла нет расширения.'; Exit; end;
  Delete(Extension, 1, 1);
  Extension := LowerCase(Extension);
  for I := 1 to Length(Extension) do
    if not (Extension[I] in ['a'..'z','0'..'9','_','-']) then
    begin Output := 'Недопустимое расширение.'; Exit; end;
  if not UserInfo(UserName, HomeDir, Output) then Exit;
  MimeType := 'application/x-recorderlnx-' + Extension;
  DesktopId := 'recorderlnx-open-' + Extension + '.desktop';
  if not InstallAssociation(Extension, MimeType, DesktopId,
    ExtractFileName(ProgramName), 'open-associated ' +
    DesktopArgument(ProgramName), Output) then Exit;
  if not SetMimeDefault(UserName, HomeDir, DesktopId,
    MimeType, Output) then Exit;
  Output := '*.' + Extension + ' -> ' + ProgramName + ' (' + UserName + ')';
  Result := 0;
end;

function OpenMera(const Args: TStrings; out Output: string): Integer;
var Prefix, WinPos, WinDir, WineFile: string;
begin
  Result := 1;
  if (Args.Count <> 1) or not FileExists(Args[0]) then
  begin Output := 'Файл замера не найден.'; Exit; end;
  Prefix := GetEnvironmentVariable('HOME') + '/.wine';
  WinDir := Prefix + '/drive_c/Program Files (x86)/Mera/WinPOS';
  WinPos := WinDir + '/WinPos.exe';
  if not FileExists(WinPos) then
  begin Output := 'WinPOS не найден: ' + WinPos; Exit; end;
  if not NeedRun('env', ['WINEPREFIX=' + Prefix, 'winepath', '-w',
    ExpandFileName(Args[0])], WineFile) then
  begin Output := WineFile; Exit; end;
  if not Run('env', ['WINEPREFIX=' + Prefix, 'wine', WinPos,
    Trim(WineFile)], Output, WinDir) then Exit;
  Result := 0;
end;

function OpenAssociated(const Args: TStrings; out Output: string): Integer;
begin
  Result := 1;
  if (Args.Count <> 2) or (Args[0] = '') or (Args[0][1] <> '/') or
     not FileExists(Args[0]) or not FileExists(Args[1]) then
  begin Output := 'Программа или файл не найдены.'; Exit; end;
  if Run(Args[0], [ExpandFileName(Args[1])], Output) then Result := 0;
end;

function NeedRun(const ProgramName: string; const Arguments: array of string;
  out Output: string): Boolean;
begin
  Result := Run(ProgramName, Arguments, Output);
  if not Result then Output := ProgramName + ': ' + Trim(Output);
end;

function SafeToken(const Value: string; AllowDot: Boolean = True): Boolean;
var I: Integer;
begin
  Result := (Value <> '') and (Length(Value) <= 63) and
    (Value[1] <> '-') and (Value[Length(Value)] <> '-');
  if not Result then Exit;
  for I := 1 to Length(Value) do
    if not (Value[I] in ['a'..'z','A'..'Z','0'..'9','_','-']) and
       not (AllowDot and (Value[I] = '.')) then Exit(False);
end;

function SafeLocalName(const Value: string): Boolean;
var I: Integer;
begin
  Result := (Value <> '') and (Value <> '.') and (Value <> '..') and
    (Pos('/', Value) = 0) and (Pos('\', Value) = 0) and
    (Pos(#10, Value) = 0) and (Pos(#13, Value) = 0);
  if not Result then Exit;
  for I := 1 to Length(Value) do
    if Ord(Value[I]) < 32 then Exit(False);
end;

function SaveSystemFile(const Path, Content: string; out ErrorText: string): Boolean;
var Lines: TStringList;
begin
  Result := False;
  Lines := TStringList.Create;
  try
    if FileExists(Path) and not Run('cp', ['-p', '--', Path,
      Path + '.recorderlnx.bak'], ErrorText) then
    begin ErrorText := 'Не удалось создать резервную копию ' + Path; Exit; end;
    Lines.Text := Content;
    try
      Lines.SaveToFile(Path);
      Result := True;
    except on E: Exception do ErrorText := E.Message; end;
  finally Lines.Free; end;
end;

function ReadValue(const Path, Key: string): string;
var Lines: TStringList; I: Integer;
begin
  Result := '';
  if not FileExists(Path) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(Path);
    for I := 0 to Lines.Count - 1 do
      if Copy(Lines[I], 1, Length(Key) + 1) = Key + '=' then
        Exit(Copy(Lines[I], Length(Key) + 2, MaxInt));
  finally Lines.Free; end;
end;

function Hostname(const Args: TStrings; out Output: string): Integer;
var Name, OldName, Hosts: string; Lines: TStringList; I: Integer;
begin
  Result := 1;
  if Args.Count <> 1 then begin Output := 'Требуется новое имя ПК.'; Exit; end;
  Name := Args[0];
  if not SafeToken(Name, False) then begin Output := 'Недопустимое имя ПК.'; Exit; end;
  if not NeedRun('hostname', [], OldName) then begin Output := OldName; Exit; end;
  OldName := Trim(OldName);
  if not NeedRun('hostnamectl', ['set-hostname', Name], Output) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile('/etc/hosts');
    Hosts := '';
    for I := 0 to Lines.Count - 1 do
    begin
      if (Pos('#', TrimLeft(Lines[I])) <> 1) and
         (Pos(OldName, Lines[I]) > 0) then
        Lines[I] := StringReplace(Lines[I], OldName, Name, [rfReplaceAll]);
      if Pos(Name, Lines[I]) > 0 then Hosts := Name;
    end;
    if Hosts = '' then Lines.Add('127.0.1.1' + #9 + Name);
    if not SaveSystemFile('/etc/hosts', Lines.Text, Output) then Exit;
  finally Lines.Free; end;
  Run('systemctl', ['try-reload-or-restart', 'smbd'], Hosts);
  Output := Name;
  Result := 0;
end;

function Wol(const Args: TStrings; out Output: string): Integer;
var Service, Ethtool, Check: string;
begin
  Result := 1;
  if Args.Count <> 0 then begin Output := 'Wake-on-LAN не принимает аргументы.'; Exit; end;
  if not DirectoryExists('/sys/class/net/enp3s0') then
  begin Output := 'Интерфейс enp3s0 не найден.'; Exit; end;
  if not NeedRun('which', ['ethtool'], Ethtool) then
  begin Output := 'Не установлен ethtool.'; Exit; end;
  Ethtool := Trim(Ethtool);
  if not NeedRun(Ethtool, ['-s', 'enp3s0', 'wol', 'g'], Output) then Exit;
  Service := '[Unit]' + LineEnding +
    'Description=Enable Wake-on-LAN for RecorderLnx host' + LineEnding +
    'After=network.target' + LineEnding + LineEnding +
    '[Service]' + LineEnding + 'Type=oneshot' + LineEnding +
    'ExecStart=' + Ethtool + ' -s enp3s0 wol g' + LineEnding +
    'RemainAfterExit=yes' + LineEnding + LineEnding +
    '[Install]' + LineEnding + 'WantedBy=multi-user.target' + LineEnding;
  if not SaveSystemFile(CWolService, Service, Output) then Exit;
  if not NeedRun('systemctl', ['daemon-reload'], Output) then Exit;
  if not NeedRun('systemctl', ['enable', 'recorderlnx-wol.service'], Output) then Exit;
  if not NeedRun('systemctl', ['restart', 'recorderlnx-wol.service'], Output) then Exit;
  if not NeedRun(Ethtool, ['enp3s0'], Check) then begin Output := Check; Exit; end;
  Output := Check;
  Result := 0;
end;

function ConfigPath(const LocalName: string): string;
var I: Integer; Base: string;
begin
  Base := LocalName;
  for I := 1 to Length(Base) do
    if not (Base[I] in ['a'..'z','A'..'Z','0'..'9','_','-','.']) then Base[I] := '_';
  Result := CRegistry + '/' + Base + '.ini';
end;

function FindConfig(const LocalName: string): string;
var Search: TSearchRec;
begin
  Result := ConfigPath(LocalName);
  if FileExists(Result) and (ReadValue(Result, 'LocalName') = LocalName) then Exit;
  Result := '';
  if FindFirst(CRegistry + '/*.ini', faAnyFile, Search) = 0 then
  try repeat
    if ReadValue(CRegistry + '/' + Search.Name, 'LocalName') = LocalName then
      Exit(CRegistry + '/' + Search.Name);
  until FindNext(Search) <> 0;
  finally FindClose(Search); end;
end;

function Mounted(const MountPoint: string): Boolean;
var Text: string;
begin Result := Run('mountpoint', ['-q', MountPoint], Text); end;

function ShareMarker(const Name, Suffix: string): string;
begin
  Result := '# RECORDERLNX-SHARE-' + Name + '-' + Suffix;
end;

function ManagedShareRange(const Lines: TStrings; const Name: string;
  out First, Last: Integer): Boolean;
var I: Integer;
begin
  First := -1;
  Last := -1;
  for I := 0 to Lines.Count - 1 do
  begin
    if Trim(Lines[I]) = ShareMarker(Name, 'BEGIN') then First := I;
    if Trim(Lines[I]) = ShareMarker(Name, 'END') then
    begin Last := I; Break; end;
  end;
  Result := (First >= 0) and (Last > First);
end;

function ShareSource(const Name: string): string;
var Lines: TStringList; I: Integer; Marker, Entry: string;
begin
  Result := '';
  Marker := '# recorderlnx-share-' + Name + '-bind';
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile('/etc/fstab');
    for I := 0 to Lines.Count - 1 do
    begin
      Entry := Trim(Lines[I]);
      if (Entry <> '') and (Entry[1] <> '#') and
         (Pos(' ' + Marker, Entry) > 0) then
      begin
        Result := Copy(Entry, 1, Pos(' ', Entry) - 1);
        Result := StringReplace(Result, '\040', ' ', [rfReplaceAll]);
        Exit;
      end;
    end;
  finally Lines.Free; end;
end;

function ManagedShareList(out Output: string): Integer;
var Lines: TStringList; Items: TJSONArray; Item: TJSONObject;
    I, First, Last: Integer; Name: string;
begin
  Result := 1;
  Lines := TStringList.Create;
  Items := TJSONArray.Create;
  try
    Lines.LoadFromFile('/etc/samba/smb.conf');
    for I := 0 to Lines.Count - 1 do
    begin
      if Pos('# RECORDERLNX-SHARE-', Trim(Lines[I])) <> 1 then Continue;
      Name := Trim(Lines[I]);
      Name := Copy(Name, Length('# RECORDERLNX-SHARE-') + 1, MaxInt);
      if Copy(Name, Length(Name) - 5, 6) <> '-BEGIN' then Continue;
      SetLength(Name, Length(Name) - 6);
      if not SafeToken(Name) or
         not ManagedShareRange(Lines, Name, First, Last) then Continue;
      Item := TJSONObject.Create;
      Item.Add('name', Name);
      Item.Add('path', ShareSource(Name));
      Item.Add('mount', '/srv/recorderlnx/' + Name);
      Items.Add(Item);
    end;
    Output := Items.AsJSON;
    Result := 0;
  finally Items.Free; Lines.Free; end;
end;

function SameDirectory(const Left, Right: string): Boolean;
var A, B: string;
begin
  Result := Run('stat', ['-Lc', '%d:%i', '--', Left], A) and
    Run('stat', ['-Lc', '%d:%i', '--', Right], B) and
    (Trim(A) = Trim(B));
end;

function ValidPublishedSource(const Path: string; out Source,
  Output: string): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 1 to Length(Path) do
    if Ord(Path[I]) < 32 then
    begin Output := 'Путь содержит недопустимый управляющий символ.'; Exit; end;
  if not NeedRun('readlink', ['-f', '--', Path], Source) then
  begin Output := Source; Exit; end;
  Source := Trim(Source);
  if (Source = '/') or not DirectoryExists(Source) then
  begin Output := 'Каталог не существует или выбран корень файловой системы.'; Exit; end;
  Result := True;
end;

function RestoreConfigFile(const Path, Content: string): Boolean;
var Lines: TStringList;
begin
  Result := False;
  Lines := TStringList.Create;
  try
    Lines.Text := Content;
    try Lines.SaveToFile(Path); Result := True;
    except end;
  finally Lines.Free; end;
end;

function ApplyPublishedChange(const Root, OldSource, NewSource,
  NewSmb, NewFstab: string; out Output: string): Boolean;
label Rollback;
var Smb, Fstab: TStringList; OldSmb, OldFstab, ErrorText,
    Current: string; WasMounted, ChangedMount: Boolean;
begin
  Result := False;
  Smb := TStringList.Create;
  Fstab := TStringList.Create;
  try
    Smb.LoadFromFile('/etc/samba/smb.conf');
    Fstab.LoadFromFile('/etc/fstab');
    OldSmb := Smb.Text;
    OldFstab := Fstab.Text;
  finally Smb.Free; Fstab.Free; end;
  if DirectoryExists(Root) then
  begin
    if not NeedRun('readlink', ['-f', '--', Root], Current) then
    begin Output := Current; Exit; end;
    if Trim(Current) <> Root then
    begin Output := 'Точка публикации является ссылкой: ' + Root; Exit; end;
  end;
  WasMounted := Mounted(Root);
  if WasMounted and ((OldSource = '') or
     not SameDirectory(Root, OldSource)) then
  begin Output := 'Точка занята чужим монтированием: ' + Root; Exit; end;
  if not SaveSystemFile('/etc/samba/smb.conf', NewSmb, Output) then
  begin
    ErrorText := Output;
    if not RestoreConfigFile('/etc/samba/smb.conf', OldSmb) then
      ErrorText := ErrorText + '; не удалось восстановить smb.conf';
    Output := ErrorText;
    Exit;
  end;
  if not SaveSystemFile('/etc/fstab', NewFstab, Output) then
  begin
    ErrorText := Output;
    if not RestoreConfigFile('/etc/samba/smb.conf', OldSmb) then
      ErrorText := ErrorText + '; не удалось восстановить smb.conf';
    if not RestoreConfigFile('/etc/fstab', OldFstab) then
      ErrorText := ErrorText + '; не удалось восстановить fstab';
    Output := ErrorText;
    Exit;
  end;
  ChangedMount := False;
  if WasMounted and ((NewSource = '') or
     not SameDirectory(OldSource, NewSource)) then
  begin
    if not NeedRun('umount', [Root], Output) then goto Rollback;
    ChangedMount := True;
  end;
  if (NewSource <> '') and not Mounted(Root) then
  begin
    if not NeedRun('mount', ['--bind', NewSource, Root], Output) then
      goto Rollback;
    ChangedMount := True;
  end;
  Run('systemctl', ['daemon-reload'], Current);
  if not Run('systemctl', ['reload', 'smbd'], Current) and
     not NeedRun('systemctl', ['restart', 'smbd'], Output) then
    goto Rollback;
  Result := True;
  Exit;
Rollback:
  ErrorText := Output;
  if ChangedMount then
  begin
    if Mounted(Root) then Run('umount', [Root], Current);
    if WasMounted and not Run('mount', ['--bind', OldSource, Root], Current) then
      ErrorText := ErrorText + '; прежнее монтирование не восстановлено: ' + Current;
  end;
  if not RestoreConfigFile('/etc/samba/smb.conf', OldSmb) then
    ErrorText := ErrorText + '; не удалось восстановить smb.conf';
  if not RestoreConfigFile('/etc/fstab', OldFstab) then
    ErrorText := ErrorText + '; не удалось восстановить fstab';
  Run('systemctl', ['daemon-reload'], Current);
  Run('systemctl', ['reload', 'smbd'], Current);
  Output := ErrorText;
end;

function MountShare(const Host, ShareName, LocalName: string;
  out Output: string): Boolean;
var MountPoint, Options, Uid, Gid: string;
begin
  Result := False;
  if not SafeToken(Host) or not SafeToken(ShareName) or
     not SafeLocalName(LocalName) then
  begin Output := 'Недопустимый хост, ресурс или локальное имя.'; Exit; end;
  if not FileExists(CCredentials) then
  begin Output := 'Нет SMB-учётных данных: ' + CCredentials; Exit; end;
  MountPoint := CMountRoot + '/' + LocalName;
  if not ForceDirectories(MountPoint) then
  begin Output := 'Не удалось создать каталог ' + MountPoint; Exit; end;
  if not NeedRun('id', ['-u', 'user'], Uid) then Exit;
  if not NeedRun('id', ['-g', 'user'], Gid) then Exit;
  if Mounted(MountPoint) then Exit(True);
  Options := 'credentials=' + CCredentials + ',uid=' + Trim(Uid) +
    ',gid=' + Trim(Gid) + ',iocharset=utf8,vers=3.0,noperm';
  Result := Run('mount', ['-t', 'cifs', '//' + Host + '/' + ShareName,
    MountPoint, '-o', Options], Output);
  if not Result then
  begin
    Options := StringReplace(Options, 'vers=3.0', 'vers=2.1', []);
    Result := Run('mount', ['-t', 'cifs', '//' + Host + '/' + ShareName,
      MountPoint, '-o', Options], Output);
  end;
end;

function ShareList(out Output: string): Integer;
var Search: TSearchRec; Path, Point, State: string;
begin
  Output := 'HOST' + #9 + 'SHARE' + #9 + 'LOCAL_NAME' + #9 +
    'MOUNT_POINT' + #9 + 'STATE' + LineEnding;
  if FindFirst(CRegistry + '/*.ini', faAnyFile, Search) = 0 then
  try repeat
    Path := CRegistry + '/' + Search.Name;
    Point := ReadValue(Path, 'MountPoint');
    State := 'disconnected';
    if (Point <> '') and Mounted(Point) then State := 'mounted';
    Output += ReadValue(Path, 'Host') + #9 + ReadValue(Path, 'Name') + #9 +
      ReadValue(Path, 'LocalName') + #9 + Point + #9 + State + LineEnding;
  until FindNext(Search) <> 0;
  finally FindClose(Search); end;
  Result := 0;
end;

function Shares(const Args: TStrings; out Output: string): Integer;
var Action, Path, Name, Point, Host, ShareName, ErrorText: string;
    Search: TSearchRec; Failed: Boolean;
begin
  Result := 1;
  if Args.Count < 1 then begin Output := 'Не указано действие.'; Exit; end;
  Action := Args[0];
  if Action = 'list' then Exit(ShareList(Output));
  if Action = 'restore' then
  begin
    Failed := False;
    if FindFirst(CRegistry + '/*.ini', faAnyFile, Search) = 0 then
    try repeat
      Path := CRegistry + '/' + Search.Name;
      if not MountShare(ReadValue(Path, 'Host'), ReadValue(Path, 'Name'),
        ReadValue(Path, 'LocalName'), ErrorText) then
      begin Failed := True; Output += Search.Name + ': ' + ErrorText + LineEnding; end;
    until FindNext(Search) <> 0;
    finally FindClose(Search); end;
    if Failed then Exit(1) else Exit(0);
  end;
  if Action = 'connect' then
  begin
    if Args.Count <> 4 then begin Output := 'connect ХОСТ РЕСУРС ИМЯ'; Exit; end;
    Host := Args[1]; ShareName := Args[2]; Name := Args[3];
    if not MountShare(Host, ShareName, Name, Output) then Exit;
    if not ForceDirectories(CRegistry) then Exit;
    Point := CMountRoot + '/' + Name;
    if not SaveSystemFile(ConfigPath(Name), '[Share]' + LineEnding +
      'Host=' + Host + LineEnding + 'Name=' + ShareName + LineEnding +
      'LocalName=' + Name + LineEnding + 'MountPoint=' + Point + LineEnding,
      Output) then Exit;
    Output := Point;
    Exit(0);
  end;
  if (Action = 'disconnect') or (Action = 'reconnect') then
  begin
    if Args.Count = 2 then Name := Args[1]
    else if Args.Count = 4 then Name := Args[3]
    else begin Output := Action + ' ИМЯ'; Exit; end;
    if not SafeLocalName(Name) then begin Output := 'Недопустимое имя.'; Exit; end;
    Path := FindConfig(Name);
    if Path = '' then begin Output := 'Подключение не найдено.'; Exit; end;
    Point := ReadValue(Path, 'MountPoint');
    if (Point = '') or (Pos(CMountRoot + '/', Point) <> 1) then
    begin Output := 'Недопустимый каталог монтирования в реестре.'; Exit; end;
    if Mounted(Point) and not NeedRun('umount', [Point], Output) then Exit;
    if Action = 'reconnect' then
    begin
      if not MountShare(ReadValue(Path, 'Host'), ReadValue(Path, 'Name'),
        Name, Output) then Exit;
    end
    else
    begin
      if not DeleteFile(Path) then begin Output := 'Не удалить ' + Path; Exit; end;
      RemoveDir(Point);
    end;
    Output := Point;
    Exit(0);
  end;
  Output := 'Неизвестное действие: ' + Action;
end;

function PublishFolder(const Args: TStrings; out Output: string): Integer;
var Source, ShareName, Root, Marker, Fstab, Smb, TestFile, Current,
    OldSource: string;
    Lines: TStringList; I, First, Last: Integer;
begin
  Result := 1;
  if (Args.Count < 1) or (Args.Count > 2) then
  begin Output := 'publish КАТАЛОГ [СЕТЕВОЕ_ИМЯ]'; Exit; end;
  if not ValidPublishedSource(Args[0], Source, Output) then Exit;
  ShareName := 'MeraFiles';
  if Args.Count = 2 then ShareName := Args[1];
  if not SafeToken(ShareName) then
  begin Output := 'Недопустимое сетевое имя.'; Exit; end;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile('/etc/samba/smb.conf');
    if not ManagedShareRange(Lines, ShareName, First, Last) then
    begin First := -1; Last := -1; end;
    for I := 0 to Lines.Count - 1 do
      if (Trim(Lines[I]) = '[' + ShareName + ']') and
         ((I <= First) or (I >= Last) or (First < 0)) then
      begin Output := 'Имя занято чужой секцией Samba: ' + ShareName; Exit; end;
  finally Lines.Free; end;
  Root := '/srv/recorderlnx/' + ShareName;
  OldSource := ShareSource(ShareName);
  if (OldSource <> '') and (First < 0) then
  begin Output := 'Запись /etc/fstab занята без управляемой секции Samba.'; Exit; end;
  if (OldSource = '') and (First >= 0) then
  begin Output := 'Управляемая секция Samba не имеет записи /etc/fstab.'; Exit; end;
  if Mounted(Root) and (OldSource = '') then
  begin Output := 'Каталог публикации уже занят другим монтированием: ' + Root; Exit; end;
  if not ForceDirectories(Root) then
  begin Output := 'Не удалось создать каталог публикации.'; Exit; end;
  if not NeedRun('readlink', ['-f', '--', Root], Current) then Exit;
  if Trim(Current) <> Root then
  begin Output := 'Точка публикации является ссылкой: ' + Root; Exit; end;
  Marker := '# recorderlnx-share-' + ShareName + '-bind';
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile('/etc/fstab');
    for I := Lines.Count - 1 downto 0 do
      if (Pos(' ' + Marker, Trim(Lines[I])) > 0) or
         ((ShareName = 'MeraFiles') and
          (Pos(' # recorderlnx-merafiles-bind', Trim(Lines[I])) > 0)) then
        Lines.Delete(I);
    Fstab := StringReplace(Source, '\', '\\', [rfReplaceAll]);
    Fstab := StringReplace(Fstab, ' ', '\040', [rfReplaceAll]);
    Lines.Add(Fstab + ' ' + Root + ' none bind,nofail 0 0 ' + Marker);
    Current := Lines.Text;
    Lines.LoadFromFile('/etc/samba/smb.conf');
    Smb := '# RECORDERLNX-SHARE-' + ShareName + '-BEGIN';
    Fstab := '# RECORDERLNX-SHARE-' + ShareName + '-END';
    if ManagedShareRange(Lines, ShareName, First, Last) then
    begin
      for I := Last downto First do Lines.Delete(I);
    end;
    Lines.Add('');
    Lines.Add(Smb);
    Lines.Add('[' + ShareName + ']');
    Lines.Add('   path = ' + Root);
    Lines.Add('   browseable = yes');
    Lines.Add('   read only = yes');
    Lines.Add('   guest ok = no');
    Lines.Add('   valid users = user');
    Lines.Add(Fstab);
    TestFile := GetTempFileName('/tmp', 'smb');
    try
      Lines.SaveToFile(TestFile);
      if not NeedRun('testparm', ['-s', TestFile], Output) then Exit;
    finally DeleteFile(TestFile); end;
    if not ApplyPublishedChange(Root, OldSource, Source,
      Lines.Text, Current, Output) then Exit;
  finally Lines.Free; end;
  if not NeedRun('hostname', ['-f'], Current) then Run('hostname', [], Current);
  Output := 'smb://' + Trim(Current) + '/' + ShareName;
  Result := 0;
end;

function DeletePublishedShare(const Name: string; out Output: string): Integer;
var Smb, Fstab: TStringList; First, Last, I: Integer;
    Root, Marker, TestFile, OldSource: string;
begin
  Result := 1;
  if not SafeToken(Name) then
  begin Output := 'Недопустимое сетевое имя.'; Exit; end;
  Smb := TStringList.Create;
  Fstab := TStringList.Create;
  try
    Smb.LoadFromFile('/etc/samba/smb.conf');
    if not ManagedShareRange(Smb, Name, First, Last) then
    begin Output := 'Управляемая публикация не найдена: ' + Name; Exit; end;
    OldSource := ShareSource(Name);
    if OldSource = '' then
    begin Output := 'Не найдена управляемая запись /etc/fstab: ' + Name; Exit; end;
    for I := Last downto First do Smb.Delete(I);
    TestFile := GetTempFileName('/tmp', 'smb');
    try
      Smb.SaveToFile(TestFile);
      if not NeedRun('testparm', ['-s', TestFile], Output) then Exit;
    finally DeleteFile(TestFile); end;
    Fstab.LoadFromFile('/etc/fstab');
    Marker := ' # recorderlnx-share-' + Name + '-bind';
    for I := Fstab.Count - 1 downto 0 do
      if Pos(Marker, Trim(Fstab[I])) > 0 then Fstab.Delete(I);
    Root := '/srv/recorderlnx/' + Name;
    if not ApplyPublishedChange(Root, OldSource, '',
      Smb.Text, Fstab.Text, Output) then Exit;
  finally Smb.Free; Fstab.Free; end;
  RemoveDir(Root);
  Output := 'Публикация ' + Name + ' удалена.';
  Result := 0;
end;

function Publish(const Args: TStrings; out Output: string): Integer;
var Params, Smb: TStringList; Name: string; First, Last: Integer;
begin
  if (Args.Count = 1) and (Args[0] = 'list') then
    Exit(ManagedShareList(Output));
  if (Args.Count = 2) and (Args[0] = 'delete') then
    Exit(DeletePublishedShare(Args[1], Output));
  if (Args.Count = 3) and (Args[0] = 'update') then
  begin
    Name := Args[1];
    if not SafeToken(Name) or (ShareSource(Name) = '') then
    begin Output := 'Управляемая публикация не найдена: ' + Name; Exit(1); end;
    Smb := TStringList.Create;
    try
      Smb.LoadFromFile('/etc/samba/smb.conf');
      if not ManagedShareRange(Smb, Name, First, Last) then
      begin Output := 'Управляемая секция Samba не найдена: ' + Name; Exit(1); end;
    finally Smb.Free; end;
    Params := TStringList.Create;
    try
      Params.Add(Args[2]);
      Params.Add(Name);
      Exit(PublishFolder(Params, Output));
    finally Params.Free; end;
  end;
  Result := PublishFolder(Args, Output);
end;

function ExecuteLegacySetup(const Section: string; Args: TStrings;
  out Output: string): Integer;
begin
  Output := '';
  {$IFDEF UNIX}
  if Section = 'open-mera' then Exit(OpenMera(Args, Output));
  if Section = 'open-associated' then Exit(OpenAssociated(Args, Output));
  if (Section = 'publish') and (Args.Count = 1) and
     (Args[0] = 'list') then Exit(Publish(Args, Output));
  if fpGetEUID <> 0 then
  begin Output := 'Требуются права root (pkexec/sudo).'; Exit(1); end;
  if Section = 'hostname' then Exit(Hostname(Args, Output));
  if Section = 'wol' then Exit(Wol(Args, Output));
  if Section = 'shares' then Exit(Shares(Args, Output));
  if Section = 'publish' then Exit(Publish(Args, Output));
  if Section = 'associate-mera' then Exit(AssociateMera(Args, Output));
  if Section = 'associate-file' then Exit(AssociateFile(Args, Output));
  {$ENDIF}
  Result := 1;
  Output := 'Раздел пока не перенесён во встроенный код: ' + Section;
end;

end.
