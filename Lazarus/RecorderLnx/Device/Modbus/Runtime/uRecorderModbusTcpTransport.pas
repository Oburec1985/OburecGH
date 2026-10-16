unit uRecorderModbusTcpTransport;

{
  Modbus TCP byte transport using RecorderLnx network binding selection.
  It owns one socket stream per open session and performs no frame decoding.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, ssockets, uRecorderModbusTransport;

type
  TRecorderModbusTcpTransport = class(TInterfacedObject,
    IRecorderModbusTransport)
  private
    fHost: string;
    fPort: Word;
    fConnectTimeoutMs: Cardinal;
    fStream: TSocketStream;
    function ReadReply(AResponse: PByte; ACapacity: Integer;
      out ALength: Integer): TRecorderModbusTransportResult;
    function ReadExact(ABuffer: PByte; ACount: Integer;
      out ARead: Integer): TRecorderModbusTransportResult;
    function WriteRequest(ARequest: PByte; ALength: Integer):
      TRecorderModbusTransportResult;
  public
    constructor Create(const AHost: string; APort: Word;
      AConnectTimeoutMs: Cardinal);
    destructor Destroy; override;
    function Open: TRecorderModbusTransportResult;
    function Close: TRecorderModbusTransportResult;
    function IsOpen: Boolean;
    function Endpoint: string;
    function Exchange(ARequest: PByte; ARequestLength: Integer;
      AResponse: PByte; AResponseCapacity: Integer; out AResponseLength: Integer;
      ATimeoutMs: Cardinal): TRecorderModbusTransportResult;
  end;

implementation

uses
  uRecorderNetworkBinding;

constructor TRecorderModbusTcpTransport.Create(const AHost: string; APort: Word;
  AConnectTimeoutMs: Cardinal);
begin
  inherited Create;
  fHost := Trim(AHost);
  fPort := APort;
  fConnectTimeoutMs := AConnectTimeoutMs;
end;

destructor TRecorderModbusTcpTransport.Destroy;
begin
  Close;
  inherited Destroy;
end;

function TRecorderModbusTcpTransport.Endpoint: string;
begin
  Result := fHost + ':' + IntToStr(fPort);
end;

function TRecorderModbusTcpTransport.IsOpen: Boolean;
begin
  Result := fStream <> nil;
end;

function TRecorderModbusTcpTransport.Open: TRecorderModbusTransportResult;
var
  lError: string;
begin
  if IsOpen then
    Exit(ModbusTransportOk);
  if (fHost = '') or (fPort = 0) then
    Exit(ModbusTransportError(mtcInvalidArgument, mtsOpen, Endpoint,
      'TCP host and port are required'));
  if not RecorderOpenBoundTcpStream(fHost, fPort, fConnectTimeoutMs, fStream,
    lError) then
    Exit(ModbusTransportError(mtcOpenFailed, mtsOpen, Endpoint, lError));
  Result := ModbusTransportOk;
end;

function TRecorderModbusTcpTransport.Close: TRecorderModbusTransportResult;
begin
  FreeAndNil(fStream);
  Result := ModbusTransportOk;
end;

function TRecorderModbusTcpTransport.WriteRequest(ARequest: PByte;
  ALength: Integer): TRecorderModbusTransportResult;
var
  lCount, lOffset: Integer;
begin
  lOffset := 0;
  while lOffset < ALength do
  begin
    lCount := fStream.Write((ARequest + lOffset)^, ALength - lOffset);
    if lCount <= 0 then
      Exit(ModbusTransportError(mtcConnectionLost, mtsWrite, Endpoint,
        'TCP connection closed while writing', lOffset));
    Inc(lOffset, lCount);
  end;
  Result := ModbusTransportOk(lOffset);
end;

function TRecorderModbusTcpTransport.ReadReply(AResponse: PByte;
  ACapacity: Integer; out ALength: Integer): TRecorderModbusTransportResult;
var
  lBodyLength, lCount: Integer;
begin
  ALength := 0;
  if ACapacity < 7 then
    Exit(ModbusTransportError(mtcBufferTooSmall, mtsRead, Endpoint,
      'Response buffer cannot hold an MBAP header'));
  Result := ReadExact(AResponse, 7, lCount);
  if Result.Code <> mtcOk then Exit;
  ALength := lCount;
  { MBAP length includes the unit id already read as byte 7. }
  lBodyLength := (Integer((AResponse + 4)^) shl 8) or (AResponse + 5)^;
  Dec(lBodyLength);
  if (lBodyLength < 1) or (7 + lBodyLength > ACapacity) then
    Exit(ModbusTransportError(mtcBufferTooSmall, mtsRead, Endpoint,
      'Invalid or oversized MBAP length', ALength));
  Result := ReadExact(AResponse + 7, lBodyLength, lCount);
  Inc(ALength, lCount);
  if Result.Code = mtcOk then Result := ModbusTransportOk(ALength);
end;

function TRecorderModbusTcpTransport.ReadExact(ABuffer: PByte;
  ACount: Integer; out ARead: Integer): TRecorderModbusTransportResult;
var
  lCount: Integer;
begin
  ARead := 0;
  while ARead < ACount do
  begin
    lCount := fStream.Read((ABuffer + ARead)^, ACount - ARead);
    if lCount = 0 then
      Exit(ModbusTransportError(mtcTimeout, mtsRead, Endpoint,
        'TCP response timeout', ARead));
    if lCount < 0 then
      Exit(ModbusTransportError(mtcConnectionLost, mtsRead, Endpoint,
        'TCP connection closed while reading', ARead));
    Inc(ARead, lCount);
  end;
  Result := ModbusTransportOk(ARead);
end;

function TRecorderModbusTcpTransport.Exchange(ARequest: PByte;
  ARequestLength: Integer; AResponse: PByte; AResponseCapacity: Integer;
  out AResponseLength: Integer; ATimeoutMs: Cardinal):
  TRecorderModbusTransportResult;
begin
  AResponseLength := 0;
  if not IsOpen then
    Exit(ModbusTransportError(mtcInvalidState, mtsWrite, Endpoint,
      'TCP transport is not open'));
  if (ARequest = nil) or (ARequestLength <= 0) or (AResponse = nil) or
    (AResponseCapacity <= 0) then
    Exit(ModbusTransportError(mtcInvalidArgument, mtsWrite, Endpoint,
      'Exchange buffers are invalid'));
  fStream.IOTimeout := ATimeoutMs;
  try
    Result := WriteRequest(ARequest, ARequestLength);
    if Result.Code <> mtcOk then Exit;
    Result := ReadReply(AResponse, AResponseCapacity, AResponseLength);
  except
    on E: Exception do
    begin
      Result := ModbusTransportError(mtcConnectionLost, mtsRead, Endpoint,
        E.Message);
      Close;
    end;
  end;
end;

end.
