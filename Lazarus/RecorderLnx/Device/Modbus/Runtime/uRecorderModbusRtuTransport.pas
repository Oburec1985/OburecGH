unit uRecorderModbusRtuTransport;

{
  Cross-platform Modbus RTU byte transport. Platform serial details are
  isolated behind FPC's Serial unit; the public contract is OS-independent.
  One bus owns one handle and performs one request/response at a time.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Serial, uRecorderModbusTransport;

type
  TRecorderModbusParity = (mpNone, mpOdd, mpEven);

  TRecorderModbusRtuTransport = class(TInterfacedObject,
    IRecorderModbusTransport)
  private
    fDeviceName: string;
    fBaudRate: Integer;
    fDataBits: Integer;
    fParity: TRecorderModbusParity;
    fStopBits: Integer;
    fHandle: TSerialHandle;
    function SerialParity: TParityType;
  public
    constructor Create(const ADeviceName: string; ABaudRate, ADataBits: Integer;
      AParity: TRecorderModbusParity; AStopBits: Integer);
    destructor Destroy; override;
    function Open: TRecorderModbusTransportResult;
    function Close: TRecorderModbusTransportResult;
    function IsOpen: Boolean;
    function Endpoint: string;
    function Exchange(ARequest: PByte; ARequestLength: Integer;
      AResponse: PByte; AResponseCapacity: Integer; out AResponseLength: Integer;
      ATimeoutMs: Cardinal): TRecorderModbusTransportResult;
  end;

{ Modbus serial-line t3.5 in microseconds. Above 19200 baud the specification
  recommends the fixed 1.75 ms interval. }
function RecorderModbusRtuSilentIntervalUs(ABaudRate, ADataBits: Integer;
  AParity: TRecorderModbusParity; AStopBits: Integer): Cardinal;

implementation

function RecorderModbusRtuSilentIntervalUs(ABaudRate, ADataBits: Integer;
  AParity: TRecorderModbusParity; AStopBits: Integer): Cardinal;
var
  lBitsPerCharacter: QWord;
begin
  if ABaudRate <= 0 then Exit(0);
  if ABaudRate > 19200 then Exit(1750);
  lBitsPerCharacter := 1 + ADataBits + AStopBits;
  if AParity <> mpNone then Inc(lBitsPerCharacter);
  Result := (3500000 * lBitsPerCharacter + QWord(ABaudRate) - 1) div
    QWord(ABaudRate);
end;

constructor TRecorderModbusRtuTransport.Create(const ADeviceName: string;
  ABaudRate, ADataBits: Integer; AParity: TRecorderModbusParity;
  AStopBits: Integer);
begin
  inherited Create;
  fDeviceName := Trim(ADeviceName);
  fBaudRate := ABaudRate;
  fDataBits := ADataBits;
  fParity := AParity;
  fStopBits := AStopBits;
  fHandle := TSerialHandle(-1);
end;

destructor TRecorderModbusRtuTransport.Destroy;
begin
  Close;
  inherited Destroy;
end;

function TRecorderModbusRtuTransport.Endpoint: string;
begin
  Result := fDeviceName;
end;

function TRecorderModbusRtuTransport.IsOpen: Boolean;
begin
  Result := (fHandle <> TSerialHandle(-1)) and (fHandle <> 0);
end;

function TRecorderModbusRtuTransport.SerialParity: TParityType;
begin
  case fParity of
    mpOdd: Result := OddParity;
    mpEven: Result := EvenParity;
  else
    Result := NoneParity;
  end;
end;

function TRecorderModbusRtuTransport.Open: TRecorderModbusTransportResult;
begin
  if IsOpen then Exit(ModbusTransportOk);
  if (fDeviceName = '') or (fBaudRate <= 0) or
    not (fDataBits in [7, 8]) or not (fStopBits in [1, 2]) then
    Exit(ModbusTransportError(mtcInvalidArgument, mtsOpen, Endpoint,
      'Invalid serial configuration'));
  fHandle := SerOpen(fDeviceName);
  if not IsOpen then
    Exit(ModbusTransportError(mtcOpenFailed, mtsOpen, Endpoint,
      'Cannot open serial device'));
  try
    SerSetParams(fHandle, fBaudRate, fDataBits, SerialParity, fStopBits, []);
    SerFlushInput(fHandle);
    Result := ModbusTransportOk;
  except
    on E: Exception do
    begin
      Close;
      Result := ModbusTransportError(mtcConfigureFailed, mtsConfigure,
        Endpoint, E.Message);
    end;
  end;
end;

function TRecorderModbusRtuTransport.Close: TRecorderModbusTransportResult;
begin
  if IsOpen then SerClose(fHandle);
  fHandle := TSerialHandle(-1);
  Result := ModbusTransportOk;
end;

function TRecorderModbusRtuTransport.Exchange(ARequest: PByte;
  ARequestLength: Integer; AResponse: PByte; AResponseCapacity: Integer;
  out AResponseLength: Integer; ATimeoutMs: Cardinal):
  TRecorderModbusTransportResult;
var
  lCount, lOffset: Integer;
  lSilentMs: Cardinal;
begin
  AResponseLength := 0;
  if not IsOpen then
    Exit(ModbusTransportError(mtcInvalidState, mtsWrite, Endpoint,
      'RTU transport is not open'));
  if (ARequest = nil) or (ARequestLength <= 0) or (AResponse = nil) or
    (AResponseCapacity <= 0) then
    Exit(ModbusTransportError(mtcInvalidArgument, mtsWrite, Endpoint,
      'Exchange buffers are invalid'));
  lSilentMs := (RecorderModbusRtuSilentIntervalUs(fBaudRate, fDataBits,
    fParity, fStopBits) + 999) div 1000;
  { A complete silent interval before transmission prevents a new request from
    being joined to residual traffic on a multidrop bus. }
  if lSilentMs > 0 then Sleep(lSilentMs);
  SerFlushInput(fHandle);
  lOffset := 0;
  while lOffset < ARequestLength do
  begin
    lCount := SerWrite(fHandle, (ARequest + lOffset)^,
      ARequestLength - lOffset);
    if lCount <= 0 then
      Exit(ModbusTransportError(mtcWriteFailed, mtsWrite, Endpoint,
        'Serial write failed', lOffset));
    Inc(lOffset, lCount);
  end;
  SerDrain(fHandle);
  { First byte uses the transaction timeout. Further bytes use the RTU silent
    gap as the end-of-frame marker, without allocating a temporary array. }
  lCount := SerReadTimeout(fHandle, AResponse^, ATimeoutMs);
  if lCount <= 0 then
  begin
    Exit(ModbusTransportError(mtcTimeout, mtsRead, Endpoint,
      'RTU response timeout'));
  end;
  AResponseLength := 1;
  while AResponseLength < AResponseCapacity do
  begin
    lCount := SerReadTimeout(fHandle, (AResponse + AResponseLength)^, lSilentMs);
    if lCount <= 0 then Break;
    Inc(AResponseLength);
  end;
  Result := ModbusTransportOk(AResponseLength);
end;

end.
