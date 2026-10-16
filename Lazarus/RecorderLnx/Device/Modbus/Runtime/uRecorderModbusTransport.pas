unit uRecorderModbusTransport;

{
  Transport contract for the RecorderLnx Modbus runtime.

  A bus owns exactly one transport and permits one outstanding Exchange call.
  The codec owns frame construction and validation; transports only move bytes.
  Expected communication failures are returned as typed results, never raised.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils;

const
  CRecorderModbusMaxAduSize = 260;

type
  TRecorderModbusTransportCode = (
    mtcOk,
    mtcInvalidArgument,
    mtcInvalidState,
    mtcOpenFailed,
    mtcConfigureFailed,
    mtcWriteFailed,
    mtcReadFailed,
    mtcTimeout,
    mtcConnectionLost,
    mtcBufferTooSmall,
    mtcStopped,
    mtcProtocolError,
    mtcExceptionResponse
  );

  TRecorderModbusTransportStage = (
    mtsNone,
    mtsOpen,
    mtsConfigure,
    mtsWrite,
    mtsRead,
    mtsClose
  );

  TRecorderModbusTransportResult = record
    Code: TRecorderModbusTransportCode;
    Stage: TRecorderModbusTransportStage;
    Endpoint: string;
    Detail: string;
    BytesTransferred: Integer;
    ProtocolCode: Byte;
  end;

  { The caller retains both buffers for the duration of Exchange. Implementors
    neither resize nor retain them. Exchange is synchronous and single-owner. }
  IRecorderModbusTransport = interface
    ['{D7B8A73F-75B4-4677-AD56-50687C1F7739}']
    function Open: TRecorderModbusTransportResult;
    function Close: TRecorderModbusTransportResult;
    function IsOpen: Boolean;
    function Endpoint: string;
    function Exchange(ARequest: PByte; ARequestLength: Integer;
      AResponse: PByte; AResponseCapacity: Integer; out AResponseLength: Integer;
      ATimeoutMs: Cardinal): TRecorderModbusTransportResult;
  end;

function ModbusTransportOk(ABytesTransferred: Integer = 0):
  TRecorderModbusTransportResult;
function ModbusTransportError(ACode: TRecorderModbusTransportCode;
  AStage: TRecorderModbusTransportStage; const AEndpoint, ADetail: string;
  ABytesTransferred: Integer = 0; AProtocolCode: Byte = 0):
  TRecorderModbusTransportResult;

implementation

function ModbusTransportOk(ABytesTransferred: Integer):
  TRecorderModbusTransportResult;
begin
  Result.Stage := mtsNone;
  Result.Endpoint := '';
  Result.Detail := '';
  Result.Code := mtcOk;
  Result.BytesTransferred := ABytesTransferred;
  Result.ProtocolCode := 0;
end;

function ModbusTransportError(ACode: TRecorderModbusTransportCode;
  AStage: TRecorderModbusTransportStage; const AEndpoint, ADetail: string;
  ABytesTransferred: Integer; AProtocolCode: Byte):
  TRecorderModbusTransportResult;
begin
  Result.Code := ACode;
  Result.Stage := AStage;
  Result.Endpoint := AEndpoint;
  Result.Detail := ADetail;
  Result.BytesTransferred := ABytesTransferred;
  Result.ProtocolCode := AProtocolCode;
end;

end.
