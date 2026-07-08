unit uRecorderMic140ProtocolDriver;

{
  Abstract MIC-140 scan transport. Legacy and Mebius implementations override
  virtual Connect/Program/Start/Stop/ReadRaw/Decommutate while the data
  source orchestrates lifecycle through TMic140StreamFsm.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uRecorderDeviceInterfaces, uRecorderMic140StreamTypes,
  uRecorderMic140ScanConfig;

type
  TRecorderMic140ProtocolKind = (mpkLegacy, mpkMebius);

  TRecorderMic140ProtocolDriver = class abstract(TObject)
  protected
    fConfig: TRecorderMic140ScanConfig;
    fConnected: Boolean;
    fStreaming: Boolean;
  public
    constructor Create(AConfig: TRecorderMic140ScanConfig); virtual;
    function ProtocolKind: TRecorderMic140ProtocolKind; virtual; abstract;
    function Connect(out AError: string): Boolean; virtual; abstract;
    procedure Disconnect; virtual; abstract;
    function ProgramDevice(out AError: string): Boolean; virtual; abstract;
    function StartScan(out AError: string): Boolean; virtual; abstract;
    function StopScan: Boolean; virtual; abstract;
    function ReadRawBlock(out ARaw: TMic140LegacyRawBlock): Boolean; virtual; abstract;
    function Decommutate(const ARaw: TMic140LegacyRawBlock;
      out ABlock: TRecorderDeviceSampleBlock): Boolean; virtual; abstract;
    function TryRestartAfterReadStall: Boolean; virtual;
    function StreamReadCount: Int64; virtual;
    property Config: TRecorderMic140ScanConfig read fConfig;
    property Connected: Boolean read fConnected;
    property Streaming: Boolean read fStreaming;
  end;

implementation

constructor TRecorderMic140ProtocolDriver.Create(
  AConfig: TRecorderMic140ScanConfig);
begin
  inherited Create;
  fConfig := AConfig;
  fConnected := False;
  fStreaming := False;
end;

function TRecorderMic140ProtocolDriver.TryRestartAfterReadStall: Boolean;
begin
  Result := False;
end;

function TRecorderMic140ProtocolDriver.StreamReadCount: Int64;
begin
  Result := 0;
end;

end.
