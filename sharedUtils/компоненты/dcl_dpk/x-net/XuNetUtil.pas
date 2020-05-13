unit XuNetUtil;

interface

uses Windows, SysUtils, WinInet;

function IsConnectedToInternet(host: string; timeOut: Cardinal): boolean;
function IsModemConnection: boolean;

implementation

function IsModemConnection : boolean;
var flags: dword;
begin
  Result := false;
  if InternetGetConnectedState(@flags, 0) then
    if (flags and INTERNET_CONNECTION_MODEM) = INTERNET_CONNECTION_MODEM then
      Result := true;
end;

function IsConnectedToInternet(host: string; timeOut: Cardinal): boolean;
var hInet, hInetUrl: Pointer;
begin
  Result := false;
  if IsModemConnection then
    hInet := InternetOpen('XNetDetect v2.1', INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0)
  else
    hInet := InternetOpen('XNetDetect v2.1', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    InternetSetOption(hInet, INTERNET_OPTION_CONNECT_TIMEOUT, @timeOut, sizeOf(timeOut));
    hInetUrl := InternetOpenUrl(hInet,
                                PChar(host),
                                nil,
                                0,
                                INTERNET_FLAG_KEEP_CONNECTION or INTERNET_FLAG_NO_CACHE_WRITE or
                                INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_AUTO_REDIRECT,
                                0);
    if Assigned(hInetUrl) then
    begin
      InternetCloseHandle(hInet);
      Result := true;
    end
    else
      InternetCloseHandle(hInet);
  except
    InternetCloseHandle(hInet);
  end;
end;

end.
