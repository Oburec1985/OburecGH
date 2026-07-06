unit uRecorderDeviceInterfaces;

{
  Абстракция устройства захвата данных.
  Этапы: Connect → Program → Start → Stop.
  Параметры через GetDeviceProperty / TrySetDeviceProperty.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants,
  uRecorderAcquisitionTypes;

type
  ERecorderDeviceError = class(Exception);

  TRecorderDeviceState = (rdsDisconnected, rdsConnected, rdsProgrammed, rdsStarted);

  TRecorderDeviceProperty = (
    rdpName, rdpHost, rdpPort,
    rdpPollFrequencyHz, rdpUpdateTimeMs, rdpChannelCount,
    rdpDeviceSerial, rdpStateWord, rdpErrorCode, rdpErrorText
  );

  TRecorderDeviceChannel = record
    Name: string;
    Address: string;
    UnitName: string;
    ModuleType: string;
    PollFrequencyHz: Double;
    Enabled: Boolean;
  end;

  TRecorderDeviceChannelArray = array of TRecorderDeviceChannel;

  IRecorderDevice = interface
    ['{39D2026D-851C-4EE4-97C7-3C86A02962A6}']
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    function GetNativeObject: TObject;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer = -1): Boolean;
    procedure Connect;
    procedure Disconnect;
    procedure ProgramDevice;
    procedure Start;
    procedure Stop;
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean;
    property DeviceId: string read GetDeviceId;
    property Name: string read GetName;
    property State: TRecorderDeviceState read GetState;
  end;

  TRecorderDevice = class(TInterfacedObject, IRecorderDevice)
  protected
    fDeviceId: string;
    fState: TRecorderDeviceState;
    fHost: string;
    fPort: Integer;
    fName: string;
    fChannelCount: Integer;
    fPollFrequencyHz: Double;
    fUpdateTimeMs: Integer;
    procedure ReadDeviceParameters; virtual;
    function BuildChannelName(AIndex: Integer): string; virtual;
    function BuildChannelAddress(AIndex: Integer): string; virtual;
    procedure SetFs(fs: Double); virtual;
    function GetDeviceId: string; virtual;
    function GetName: string; virtual;
    function GetState: TRecorderDeviceState; virtual;
    function GetChannels: TRecorderDeviceChannelArray; virtual;
    function GetNativeObject: TObject; virtual;
  public
    constructor Create(const ADeviceId, AName: string); virtual;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant; virtual;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer = -1): Boolean; virtual;
    procedure Connect; virtual;
    procedure Disconnect; virtual;
    procedure ProgramDevice; virtual;
    procedure Start; virtual;
    procedure Stop; virtual;
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean; virtual;
    property DeviceId: string read GetDeviceId;
    property Name: string read GetName;
    property State: TRecorderDeviceState read GetState;
  end;

implementation

constructor TRecorderDevice.Create(const ADeviceId, AName: string);
begin
  inherited Create;
  fDeviceId := ADeviceId;
  fName := AName;
  fState := rdsDisconnected;
end;

procedure TRecorderDevice.ReadDeviceParameters; begin end;

function TRecorderDevice.BuildChannelName(AIndex: Integer): string;
begin Result := Format('AIn%d', [AIndex + 1]); end;

function TRecorderDevice.BuildChannelAddress(AIndex: Integer): string;
begin Result := IntToStr(AIndex + 1); end;

procedure TRecorderDevice.SetFs(fs: Double);
begin fPollFrequencyHz := fs; end;

function TRecorderDevice.GetDeviceId: string; begin Result := fDeviceId; end;
function TRecorderDevice.GetName: string; begin Result := fName; end;
function TRecorderDevice.GetState: TRecorderDeviceState; begin Result := fState; end;
function TRecorderDevice.GetNativeObject: TObject; begin Result := Self; end;

function TRecorderDevice.GetChannels: TRecorderDeviceChannelArray;
var
  I: Integer;
begin
  SetLength(Result, fChannelCount);
  for I := 0 to fChannelCount - 1 do
  begin
    Result[I].Name := BuildChannelName(I);
    Result[I].Address := BuildChannelAddress(I);
    Result[I].UnitName := 'mV';
    Result[I].ModuleType := fName;
    Result[I].PollFrequencyHz := fPollFrequencyHz;
    Result[I].Enabled := True;
  end;
end;

function TRecorderDevice.GetDeviceProperty(AProperty: TRecorderDeviceProperty;
  AIndex: Integer): Variant;
begin
  case AProperty of
    rdpName:           Result := fName;
    rdpHost:           Result := fHost;
    rdpPort:           Result := fPort;
    rdpPollFrequencyHz: Result := fPollFrequencyHz;
    rdpUpdateTimeMs:   Result := fUpdateTimeMs;
    rdpChannelCount:   Result := fChannelCount;
    rdpStateWord:      Result := Ord(fState);
    rdpErrorCode:      Result := 0;
    rdpErrorText:      Result := '';
  else
    Result := Null;
  end;
end;

function TRecorderDevice.TrySetDeviceProperty(
  AProperty: TRecorderDeviceProperty; const AValue: Variant;
  AIndex: Integer): Boolean;
begin
  Result := True;
  case AProperty of
    rdpName:           fName := VarToStr(AValue);
    rdpHost:           fHost := VarToStr(AValue);
    rdpPort:           fPort := Integer(AValue);
    rdpPollFrequencyHz: SetFs(Double(AValue));
    rdpUpdateTimeMs:   fUpdateTimeMs := Integer(AValue);
    rdpChannelCount:   fChannelCount := Integer(AValue);
  else
    Result := False;
  end;
end;

procedure TRecorderDevice.Connect;
begin ReadDeviceParameters; fState := rdsConnected; end;

procedure TRecorderDevice.Disconnect;
begin fState := rdsDisconnected; end;

procedure TRecorderDevice.ProgramDevice;
begin fState := rdsProgrammed; end;

procedure TRecorderDevice.Start;
begin fState := rdsStarted; end;

procedure TRecorderDevice.Stop;
begin if fState = rdsStarted then fState := rdsProgrammed; end;

function TRecorderDevice.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderAcquisitionBlock): Boolean;
begin
  ClearRecorderAcquisitionBlock(ABlock);
  Result := False;
end;

end.
