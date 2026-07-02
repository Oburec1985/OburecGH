unit uCalibratorThread;

interface

uses
  Classes, Windows, SysUtils, IniFiles, variants, ActiveX, tags, recorder, uRCFunc, uLogFile, uCommonTypes;

type
  TCalibratorThread = class(TThread)
  private
    FPortName: string;
    FBaudRate: Integer;
    FParity: Byte; // 0=None, 1=Odd, 2=Even
    FByteSize: Byte;
    FStopBits: Byte; // 0=1, 1=1.5, 2=2
    FInterval: Integer; // мс

    FHandle: THandle;

    FInputTagName: string;
    FOutputTagName: string;
    FInputCommand: string;

    FInputTag: ITag;
    FOutputTag: ITag;

    FLastOutputValue: Double;
    FIsConnected: Boolean;

    procedure LogMsg(const AMsg: string);
    function OpenPort: Boolean;
    procedure ClosePort;
    function SendCmd(const ACmd: string): string;
    function ParsePressure(const AResponse: string; var APressure: Double): Boolean;
    function CalcChecksum(const ACmd: string): string;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure LoadConfig;
  end;

implementation

constructor TCalibratorThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FHandle := INVALID_HANDLE_VALUE;
  FLastOutputValue := -999999.0;
  FIsConnected := False;
  LoadConfig;
end;

destructor TCalibratorThread.Destroy;
begin
  ClosePort;
  inherited;
end;

procedure TCalibratorThread.LogMsg(const AMsg: string);
begin
  logMessage('plgCalibratorPascal: ' + AMsg);
end;

procedure TCalibratorThread.LoadConfig;
var
  lIni: TIniFile;
  lCfgPath: string;
begin
  lCfgPath := ExtractFileDir(string(getRConfig)) + '\plgCalibratorPascal.ini';
  lIni := TIniFile.Create(lCfgPath);
  try
    FPortName := lIni.ReadString('Connection', 'Port', 'COM3');
    FBaudRate := lIni.ReadInteger('Connection', 'BaudRate', 19200);
    FParity := lIni.ReadInteger('Connection', 'Parity', 1); // 1 = Odd
    FByteSize := lIni.ReadInteger('Connection', 'ByteSize', 8);
    FStopBits := lIni.ReadInteger('Connection', 'StopBits', 0); // 0 = 1 stop bit
    FInterval := lIni.ReadInteger('Connection', 'Interval', 500); // 500 ms

    FInputTagName := lIni.ReadString('Tags', 'InputTag', 'Pascal_Pressure');
    FOutputTagName := lIni.ReadString('Tags', 'OutputTag', 'Pascal_Range');
    FInputCommand := lIni.ReadString('Tags', 'InputCommand', 'PRESSURE? 2');
  finally
    lIni.Free;
  end;
end;

function TCalibratorThread.CalcChecksum(const ACmd: string): string;
var
  lSum, i: Integer;
begin
  lSum := 0;
  for i := 1 to Length(ACmd) do
    Inc(lSum, Ord(ACmd[i]));
  Result := ACmd + '$' + Format('%.2X', [lSum mod 256]) + #13#10;
end;

function TCalibratorThread.OpenPort: Boolean;
var
  dcb: TDCB;
  ct: TCommTimeouts;
begin
  Result := False;
  FHandle := CreateFile(PChar('\\.\' + FPortName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if FHandle = INVALID_HANDLE_VALUE then
  begin
    LogMsg('Ошибка открытия порта ' + FPortName + ': ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  FillChar(dcb, sizeof(dcb), 0);
  dcb.DCBlength := sizeof(dcb);
  if not GetCommState(FHandle, dcb) then
  begin
    LogMsg('Ошибка GetCommState: ' + SysErrorMessage(GetLastError));
    ClosePort;
    Exit;
  end;

  dcb.BaudRate := FBaudRate;
  dcb.ByteSize := FByteSize;
  dcb.Parity := FParity;
  dcb.StopBits := FStopBits;

  if not SetCommState(FHandle, dcb) then
  begin
    LogMsg('Ошибка SetCommState: ' + SysErrorMessage(GetLastError));
    ClosePort;
    Exit;
  end;

  ct.ReadIntervalTimeout := 10;
  ct.ReadTotalTimeoutMultiplier := 10;
  ct.ReadTotalTimeoutConstant := 100;
  ct.WriteTotalTimeoutMultiplier := 0;
  ct.WriteTotalTimeoutConstant := 100;
  if not SetCommTimeouts(FHandle, ct) then
  begin
    LogMsg('Ошибка SetCommTimeouts: ' + SysErrorMessage(GetLastError));
    ClosePort;
    Exit;
  end;

  PurgeComm(FHandle, PURGE_TXCLEAR or PURGE_RXCLEAR);
  Result := True;
end;

procedure TCalibratorThread.ClosePort;
begin
  if FHandle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
  end;
  FIsConnected := False;
end;

function TCalibratorThread.SendCmd(const ACmd: string): string;
var
  lFullCmd: string;
  lBytesWritten, lBytesRead: DWORD;
  lBuf: array[0..255] of AnsiChar;
  lAnsiCmd: AnsiString;
begin
  Result := '';
  if FHandle = INVALID_HANDLE_VALUE then Exit;

  lFullCmd := CalcChecksum(ACmd);
  lAnsiCmd := AnsiString(lFullCmd);

  PurgeComm(FHandle, PURGE_TXCLEAR or PURGE_RXCLEAR);

  if not WriteFile(FHandle, lAnsiCmd[1], Length(lAnsiCmd), lBytesWritten, nil) then
  begin
    LogMsg('Ошибка WriteFile: ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  FillChar(lBuf, sizeof(lBuf), 0);
  if ReadFile(FHandle, lBuf, sizeof(lBuf) - 1, lBytesRead, nil) then
  begin
    lBuf[lBytesRead] := #0;
    Result := string(AnsiString(lBuf));
  end
  else
    LogMsg('Ошибка ReadFile: ' + SysErrorMessage(GetLastError));
end;

function TCalibratorThread.ParsePressure(const AResponse: string; var APressure: Double): Boolean;
var
  lCleanStr: string;
  i: Integer;
  fs: TFormatSettings;
begin
  Result := False;
  lCleanStr := '';
  for i := 1 to Length(AResponse) do
  begin
    if AResponse[i] in ['0'..'9', '-', '.', ','] then
      lCleanStr := lCleanStr + AResponse[i]
    else if lCleanStr <> '' then
      Break;
  end;

  if lCleanStr = '' then Exit;

  fs.DecimalSeparator := '.';
  lCleanStr := StringReplace(lCleanStr, ',', '.', [rfReplaceAll]);

  try
    APressure := StrToFloat(lCleanStr, fs);
    Result := True;
  except
    try
      fs.DecimalSeparator := ',';
      APressure := StrToFloat(lCleanStr, fs);
      Result := True;
    except
      LogMsg('Ошибка парсинга давления из ответа: ' + AResponse);
    end;
  end;
end;

procedure TCalibratorThread.Execute;
var
  lResp: string;
  lPressure: Double;
  lVal: OleVariant;
  lDoubleVal: Double;
  lCmd: string;
  lRetryCount: Integer;
  ir: IRecorder;
begin
  lRetryCount := 0;
  while not Terminated do
  begin
    ir := getIR;
    if ir = nil then
    begin
      Sleep(1000);
      Continue;
    end;

    if FHandle = INVALID_HANDLE_VALUE then
    begin
      if OpenPort then
      begin
        LogMsg('Связь с портом ' + FPortName + ' установлена.');
        lRetryCount := 0;
      end
      else
      begin
        Inc(lRetryCount);
        if lRetryCount mod 10 = 1 then
          LogMsg('Ожидание подключения к порту ' + FPortName + '...');
        Sleep(1000);
        Continue;
      end;
    end;

    if not FIsConnected then
    begin
      lResp := SendCmd('R');
      if Pos('REMOTE', UpperCase(lResp)) > 0 then
      begin
        FIsConnected := True;
        LogMsg('Устройство переведено в режим REMOTE.');
      end
      else
      begin
        LogMsg('Ошибка перевода в REMOTE. Ответ прибора: ' + lResp);
        ClosePort;
        Sleep(2000);
        Continue;
      end;
    end;

    if FInputTag = nil then
      FInputTag := getTagByName(FInputTagName);
    if FOutputTag = nil then
      FOutputTag := getTagByName(FOutputTagName);

    if FOutputTag <> nil then
    begin
      VariantInit(lVal);
      if FOutputTag.GetProperty(TAGPROP_ESTIMATE, lVal) then
      begin
        lDoubleVal := Double(lVal);
        if lDoubleVal <> FLastOutputValue then
        begin
          FLastOutputValue := lDoubleVal;
          lCmd := Format('RANGE 2,%d', [Trunc(lDoubleVal)]);
          LogMsg('Отправка управляющей команды: ' + lCmd);
          lResp := SendCmd(lCmd);
          LogMsg('Ответ устройства на команду управления: ' + Trim(lResp));
        end;
      end;
      VariantClear(lVal);
    end;

    lResp := SendCmd(FInputCommand);
    if lResp <> '' then
    begin
      if ParsePressure(lResp, lPressure) then
      begin
        if (FInputTag <> nil) and (not ir.CheckState(RS_stop)) then
        begin
          FInputTag.PushValue(lPressure, -1);
        end;
      end;
    end
    else
    begin
      LogMsg('Нет ответа от устройства на запрос давления.');
      ClosePort;
    end;

    Sleep(FInterval);
  end;
end;

end.