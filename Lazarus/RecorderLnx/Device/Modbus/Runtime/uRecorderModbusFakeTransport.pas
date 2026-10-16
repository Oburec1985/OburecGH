unit uRecorderModbusFakeTransport;

{
  Deterministic in-memory transport for protocol and lifecycle tests.
  ConfigureResponse is setup-only; Exchange copies into caller-owned buffers.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uRecorderModbusTransport;

type
  TRecorderModbusFakeTransport = class(TInterfacedObject,
    IRecorderModbusTransport)
  private
    fOpen: Boolean;
    fResponse: array[0..CRecorderModbusMaxAduSize - 1] of Byte;
    fResponseLength: Integer;
    fNextCode: TRecorderModbusTransportCode;
    fExchangeCount: Cardinal;
    fLastRequest: array[0..CRecorderModbusMaxAduSize - 1] of Byte;
    fLastRequestLength: Integer;
  public
    constructor Create;
    procedure ConfigureResponse(AData: PByte; ALength: Integer);
    procedure FailNext(ACode: TRecorderModbusTransportCode);
    function Open: TRecorderModbusTransportResult;
    function Close: TRecorderModbusTransportResult;
    function IsOpen: Boolean;
    function Endpoint: string;
    function Exchange(ARequest: PByte; ARequestLength: Integer;
      AResponse: PByte; AResponseCapacity: Integer; out AResponseLength: Integer;
      ATimeoutMs: Cardinal): TRecorderModbusTransportResult;
    function LastRequestByte(AIndex: Integer): Byte;
    property ExchangeCount: Cardinal read fExchangeCount;
    property LastRequestLength: Integer read fLastRequestLength;
  end;

implementation

constructor TRecorderModbusFakeTransport.Create;
begin
  inherited Create;
  fNextCode := mtcOk;
end;

function TRecorderModbusFakeTransport.LastRequestByte(AIndex: Integer): Byte;
begin
  if (AIndex < 0) or (AIndex >= fLastRequestLength) then Exit(0);
  Result := fLastRequest[AIndex];
end;

procedure TRecorderModbusFakeTransport.ConfigureResponse(AData: PByte;
  ALength: Integer);
begin
  if ALength < 0 then ALength := 0;
  if ALength > Length(fResponse) then ALength := Length(fResponse);
  fResponseLength := ALength;
  if (AData <> nil) and (ALength > 0) then Move(AData^, fResponse[0], ALength);
end;

procedure TRecorderModbusFakeTransport.FailNext(
  ACode: TRecorderModbusTransportCode);
begin
  fNextCode := ACode;
end;

function TRecorderModbusFakeTransport.Endpoint: string;
begin
  Result := 'fake://modbus';
end;

function TRecorderModbusFakeTransport.IsOpen: Boolean;
begin
  Result := fOpen;
end;

function TRecorderModbusFakeTransport.Open: TRecorderModbusTransportResult;
begin
  fOpen := True;
  Result := ModbusTransportOk;
end;

function TRecorderModbusFakeTransport.Close: TRecorderModbusTransportResult;
begin
  fOpen := False;
  Result := ModbusTransportOk;
end;

function TRecorderModbusFakeTransport.Exchange(ARequest: PByte;
  ARequestLength: Integer; AResponse: PByte; AResponseCapacity: Integer;
  out AResponseLength: Integer; ATimeoutMs: Cardinal):
  TRecorderModbusTransportResult;
var
  lCode: TRecorderModbusTransportCode;
begin
  AResponseLength := 0;
  if not fOpen then
    Exit(ModbusTransportError(mtcInvalidState, mtsWrite, Endpoint,
      'Fake transport is not open'));
  if (ARequest = nil) or (ARequestLength <= 0) or
    (ARequestLength > Length(fLastRequest)) then
    Exit(ModbusTransportError(mtcInvalidArgument, mtsWrite, Endpoint,
      'Invalid fake request'));
  Inc(fExchangeCount);
  fLastRequestLength := ARequestLength;
  Move(ARequest^, fLastRequest[0], ARequestLength);
  lCode := fNextCode;
  fNextCode := mtcOk;
  if lCode <> mtcOk then
    Exit(ModbusTransportError(lCode, mtsRead, Endpoint,
      'Injected fake transport failure'));
  if fResponseLength > AResponseCapacity then
    Exit(ModbusTransportError(mtcBufferTooSmall, mtsRead, Endpoint,
      'Configured fake response exceeds supplied buffer'));
  if (fResponseLength > 0) and (AResponse <> nil) then
    Move(fResponse[0], AResponse^, fResponseLength);
  AResponseLength := fResponseLength;
  Result := ModbusTransportOk(AResponseLength);
end;

end.
