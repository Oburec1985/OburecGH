unit uMic140Registration;

{
  Модуль регистрации и поиска MIC-140 для локального отладочного проекта.

  Это точка связывания конкретной реализации MIC-140 с общим менеджером
  устройств. Форма работает только с IRecorderDevice и RecorderDeviceManager,
  а этот модуль регистрирует фабрику MIC-140 и обработчик поиска MIC-140.

  Логика работы:
    1. initialization вызывает RegisterMIC140_48.
    2. RegisterMIC140_48 добавляет тип устройства MIC140 в RecorderDeviceManager.
    3. RecorderDeviceManager.Search('MIC140') вызывает FindMIC140_48.
    4. FindMIC140_48 вычисляет Host/Port через FindMIC140OnSubnet14.
    5. FindMIC140OnSubnet14 передает поиск подсети в DiscoverMIC140OnSubnet14.
    6. Менеджер создает IRecorderDevice и записывает Host/Port через общий
       вызов TrySetDeviceProperty.

  Соответствие именам оригинального Recorder:
    RegisterMIC140_48   -> MIC140_48app.cpp::RegisterMIC140_48
    RegisterDeviceClass -> DevAPI.cpp::RegisterDeviceClass
    RegisterSearchDevice / RegisterInterface -> записи найденных устройств
}

{$mode objfpc}{$H+}

interface

// Публичная точка входа: регистрирует MIC-140-48 в общем менеджере устройств.
procedure RegisterMIC140_48;

implementation

uses
  Classes, SysUtils,
  uRecorderDeviceManager, uMic140Device
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

const
  CMic140DefaultDiscoverySubnet = '192.168.14.';
  CMic140DefaultDiscoveryHost = '192.168.14.155';
  CMic140DefaultPort = 4000;

type
  // класс для поиска MIC-140
  // Один рабочий поток проверяет один IP-кандидат, не блокируя остальные проверки.
  // Класс не реализует интерфейсы; ниже только объектные методы TThread-наследника.
  TMic140DiscoveryThread = class(TThread)
  private
    // Поля объекта потока поиска.
    //  Поток не реализует интерфейсы устройств, а только проверяет один IP. }
    fFound: Boolean;
    fHost: string;
    fPort: Integer;
    // таймаут ожидания после которого считаем что поток ничего не нашел
    fTimeoutMs: Cardinal;
  protected
    // Переопределение объектного метода TThread.
    // Объектный метод TThread.
    //  Это override базового класса TThread, не метод IRecorderDevice. }
    procedure Execute; override;
  public
    // Объектные методы и свойства потока поиска.
    // Сохраняет проверяемый сетевой узел и сразу запускает поток.
    // Объектные методы и свойства TMic140DiscoveryThread.
    //  Интерфейсных методов в этом классе нет. }
    constructor Create(const AHost: string; APort: Integer; ATimeoutMs: Cardinal);
    property Found: Boolean read fFound;
    property Host: string read fHost;
  end;

// Возвращает True, если сетевой узел принял TCP-подключение за заданное время.
function Mic140TcpProbe(const AHost: string; APort: Integer;
  ATimeoutMs: Cardinal): Boolean;
{$IFDEF MSWINDOWS}
var
  lAddr: TSockAddrIn;
  lBlockMode: u_long;
  lError: LongInt;
  lErrorLen: LongInt;
  lHost: string;
  lIp: u_long;
  lSocket: TSocket;
  lTimeVal: TTimeVal;
  lWriteSet: TFDSet;
  lWsaData: TWSAData;
begin
  Result := False;
  lHost := Trim(AHost);
  if (lHost = '') or (APort <= 0) or (APort > High(Word)) then
    Exit;

  if WSAStartup($0202, lWsaData) <> 0 then
    Exit;
  try
    lIp := inet_addr(PChar(AnsiString(lHost)));
    if lIp = INADDR_NONE then
      Exit;

    lSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if lSocket = INVALID_SOCKET then
      Exit;
    try
      FillChar(lAddr, SizeOf(lAddr), 0);
      lAddr.sin_family := AF_INET;
      lAddr.sin_port := htons(Word(APort));
      lAddr.sin_addr.S_addr := lIp;

      lBlockMode := 1;
      if ioctlsocket(lSocket, LongInt(FIONBIO), lBlockMode) <> 0 then
        Exit;

      if WinSock2.connect(lSocket, @lAddr, SizeOf(lAddr)) = 0 then
        Exit(True);
      lError := WSAGetLastError;
      if lError <> WSAEWOULDBLOCK then
        Exit;

      FillChar(lTimeVal, SizeOf(lTimeVal), 0);
      lTimeVal.tv_sec := ATimeoutMs div 1000;
      lTimeVal.tv_usec := (ATimeoutMs mod 1000) * 1000;
      FD_ZERO(lWriteSet);
      FD_SET(lSocket, lWriteSet);
      if WinSock2.select(0, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
        Exit;
      if not FD_ISSET(lSocket, lWriteSet) then
        Exit;

      lError := -1;
      lErrorLen := SizeOf(lError);
      if getsockopt(lSocket, SOL_SOCKET, SO_ERROR, lError, lErrorLen) <> 0 then
        Exit;
      Result := lError = 0;
    finally
      closesocket(lSocket);
    end;
  finally
    WSACleanup;
  end;
end;
{$ELSE}
var
  lAddr: TInetSockAddr;
  lError: LongInt;
  lErrorLen: LongInt;
  lHost: string;
  lHostAddr: in_addr;
  lSocket: cint;
  lTimeVal: TTimeVal;
  lWriteSet: TFDSet;
begin
  Result := False;
  lHost := Trim(AHost);
  if (lHost = '') or (APort <= 0) or (APort > High(Word)) then
    Exit;
  if not TryStrToHostAddr(AnsiString(lHost), lHostAddr) then
    Exit;

  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket < 0 then
    Exit;
  try
    FillChar(lAddr, SizeOf(lAddr), 0);
    lAddr.sin_family := AF_INET;
    lAddr.sin_port := ShortHostToNet(Word(APort));
    lAddr.sin_addr.s_addr := HostToNet(lHostAddr.s_addr);

    {$IFDEF UNIX}
    if FpFcntl(lSocket, F_SetFl, FpFcntl(lSocket, F_GetFl, 0) or O_NONBLOCK) <> 0 then
      Exit;
    {$ENDIF}

    if fpConnect(lSocket, @lAddr, SizeOf(lAddr)) = 0 then
      Exit(True);
    if SocketError <> ESysEINPROGRESS then
      Exit;

    FillChar(lTimeVal, SizeOf(lTimeVal), 0);
    lTimeVal.tv_sec := ATimeoutMs div 1000;
    lTimeVal.tv_usec := (ATimeoutMs mod 1000) * 1000;
    fpFD_ZERO(lWriteSet);
    fpFD_SET(lSocket, lWriteSet);
    if fpSelect(lSocket + 1, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
      Exit;
    if fpFD_ISSET(lSocket, lWriteSet) <> 1 then
      Exit;

    lError := -1;
    lErrorLen := SizeOf(lError);
    if fpGetSockOpt(lSocket, SOL_SOCKET, SO_ERROR, @lError, @lErrorLen) <> 0 then
      Exit;
    Result := lError = 0;
  finally
    fpClose(lSocket);
  end;
end;
{$ENDIF}

// Конструктор намеренно простой: только сохраняет параметры проверки.
constructor TMic140DiscoveryThread.Create(const AHost: string; APort: Integer;
  ATimeoutMs: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fFound := False;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  Start;
end;

// Точка входа потока: выполняет TCP-проверку и сохраняет результат в fFound.
procedure TMic140DiscoveryThread.Execute;
begin
  fFound := Mic140TcpProbe(fHost, fPort, fTimeoutMs);
end;

// Параллельный поиск в подсети: сначала стенд, затем 192.168.14.1..254.
procedure DiscoverMIC140OnSubnet14(AFoundHosts: TStrings; APort: Integer;
  ATimeoutMs: Cardinal);
var
  lIndex: Integer;
  lThread: TMic140DiscoveryThread;
  lThreads: TList;
  lHost: string;
begin
  if AFoundHosts = nil then
    Exit;
  AFoundHosts.Clear;
  lThreads := TList.Create;
  try
    for lIndex := 0 to 254 do
    begin
      lHost := CMic140DefaultDiscoverySubnet + IntToStr(lIndex);
      lThreads.Add(TMic140DiscoveryThread.Create(lHost, APort, ATimeoutMs));
    end;

    for lIndex := 0 to lThreads.Count - 1 do
    begin
      lThread := TMic140DiscoveryThread(lThreads[lIndex]);
      lThread.WaitFor;
      if lThread.Found and (AFoundHosts.IndexOf(lThread.Host) < 0) then
        AFoundHosts.Add(lThread.Host);
      lThread.Free;
    end;
  finally
    lThreads.Free;
  end;
end;

// Определяет один адрес MIC-140 для менеджера; при молчании сети берет IP стенда.
function FindMIC140OnSubnet14(out AHost: string): Boolean;
var
  lFound: TStringList;
begin
  //  Аналог в RecorderLnx:
  //  RecorderMic140Discover(lFound, MIC140DefaultDiscoverySubnet, port, timeout).
  //  Оригинальный Recorder:
  //  RegisterSearchDevice(TDeviceEnum* info) заполняет записи найденных устройств.
  AHost := '';
  lFound := TStringList.Create;
  try
    DiscoverMIC140OnSubnet14(lFound, CMic140DefaultPort, 180);
    if lFound.Count > 0 then
      AHost := lFound[0]
    else
      // Если TCP-проверка молчит, оставляем известный стенд как кандидат поиска.
      AHost := CMic140DefaultDiscoveryHost;
    Result := AHost <> '';
  finally
    lFound.Free;
  end;
end;

// Обработчик поиска для менеджера: заполняет общий результат для типа MIC140.
function FindMIC140_48(out AResult: TRecorderDeviceSearchResult): Boolean;
begin
  //  Оригинальный Recorder:
  //  RegisterSearchDevice(TDeviceEnum* info) / RegisterInterface(&FoundDevs)
  //  выполняют поиск Ethernet-интерфейса.
  AResult.DeviceType := 'MIC140';
  Result := FindMIC140OnSubnet14(AResult.Host);
  AResult.Port := CMic140DefaultPort;
end;

// Регистрирует тип MIC-140, описание, фабрику и обработчик поиска.
procedure RegisterMIC140_48;
begin
  //  Оригинальный Recorder:
  //    MIC140_48app.cpp::RegisterMIC140_48
  //    RegisterDeviceClass(CMIC140_48::TYPE, CMIC140_48::Creator)
  //    RegisterDevice(&FoundDevs)
  RecorderDeviceManager.RegisterDeviceClass(
    'MIC140',
    'MIC-140',
    'MIC-140 recorder device stub',
    @CreateMic140Device,
    @FindMIC140_48);
end;

initialization
  RegisterMIC140_48;

end.
