unit uRecorderModbusDataSource;

{ RecorderLnx adapter for the Modbus Bus -> Device -> Tag runtime.  Internal
  Modbus paths never escape this unit: registry tags use the datasource alias
  plus the public tag alias and retain their Recorder identity across starts. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uRecorderDataSources, uRecorderTags, uModbusCoreTypes,
  uRecorderModbusRuntime, uRecorderDeviceInterfaces, uRecorderModbusDevice;

type
  TRecorderModbusDataSource = class(TRecorderDataSourceBase)
  private type
    TTagBinding = record
      DeviceIndex: Integer;
      TagIndex: Integer;
      Tag: TRecorderTag;
      LastGeneration: QWord;
      WriteCursor: QWord;
    end;
  private
    fDevice: IRecorderDevice;
    fModbusDevice: TRecorderModbusDevice;
    fBindings: array of TTagBinding;
    fStartedAtMs: QWord;
    function FindTag(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure PublishChanged;
    procedure ProcessWrites;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ADevice: IRecorderDevice;
      AUpdateTimeMs: Cardinal);
    destructor Destroy; override;
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
  end;

implementation

uses
  Math;

constructor TRecorderModbusDataSource.Create(const ADevice: IRecorderDevice;
  AUpdateTimeMs: Cardinal);
begin
  if (ADevice = nil) or not (ADevice.GetNativeObject is TRecorderModbusDevice) then
    raise EArgumentNilException.Create('Modbus device is required');
  fDevice := ADevice;
  fModbusDevice := TRecorderModbusDevice(ADevice.GetNativeObject);
  inherited Create(ADevice.DeviceId,
    CRecorderModbusModuleType, AUpdateTimeMs);
end;

destructor TRecorderModbusDataSource.Destroy;
begin
  if fDevice <> nil then fDevice.Disconnect;
  fModbusDevice := nil;
  fDevice := nil;
  inherited Destroy;
end;

function TRecorderModbusDataSource.FindTag(ARegistry: TRecorderTagRegistry;
  const AAddress: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, SourceId) and
      SameText(ARegistry.Tags[I].Address, AAddress) then
      Exit(ARegistry.Tags[I]);
end;

procedure TRecorderModbusDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I, J, K, lCapacity: Integer;
  lAddress, lName: string;
  lConfigTag: TModbusTagConfig;
  lTag: TRecorderTag;
begin
  SetLength(fBindings, 0);
  for I := 0 to fModbusDevice.Config.DeviceCount - 1 do
    for J := 0 to fModbusDevice.Config.DeviceAt(I).TagCount - 1 do
      if fModbusDevice.Config.DeviceAt(I).Enabled and
        fModbusDevice.Config.DeviceAt(I).TagAt(J).Enabled then
      begin
        lConfigTag := fModbusDevice.Config.DeviceAt(I).TagAt(J);
        lAddress := ModbusTagIdentity(fModbusDevice.Config.Alias,
          lConfigTag.Alias);
        lTag := FindTag(ARegistry, lAddress);
        if lTag = nil then
        begin
          lName := lAddress;
          K := 2;
          while ARegistry.FindByName(lName) <> nil do
          begin
            lName := lAddress + ' [' + IntToStr(K) + ']';
            Inc(K);
          end;
          lCapacity := Max(4096, Round(4000.0 /
            fModbusDevice.Config.PollIntervalMs));
          lTag := ARegistry.CreateTag(lName, lCapacity);
        end;
        lTag.SourceId := SourceId;
        lTag.ModuleType := CRecorderModbusModuleType;
        lTag.Address := lAddress;
        lTag.Description := lConfigTag.Description;
        lTag.SourceUnitName := lConfigTag.EngineeringUnit;
        lTag.PollFrequencyHz := 1000.0 /
          fModbusDevice.Config.PollIntervalMs;
        lTag.ExternalWriteAllowed := lConfigTag.Access = maReadWrite;
        SetLength(fBindings, Length(fBindings) + 1);
        with fBindings[High(fBindings)] do
        begin
          DeviceIndex := I;
          TagIndex := J;
          Tag := lTag;
          LastGeneration := 0;
          WriteCursor := lTag.ExternalWriteCursor;
        end;
      end;
end;

procedure TRecorderModbusDataSource.PrepareHardware;
begin
  inherited PrepareHardware;
  fDevice.Connect;
  if fDevice.State <> rdsConnected then Exit;
  fDevice.InitializeDevice;
  fDevice.ConfigureDevice;
end;

procedure TRecorderModbusDataSource.Start;
begin
  if fDevice.State = rdsProgrammed then fDevice.Start;
  { A temporarily unavailable device is a normal runtime state.  Enter the
    worker loop so Tick can drive the bounded reconnect lifecycle. }
  inherited Start;
  fStartedAtMs := GetTickCount64;
end;

procedure TRecorderModbusDataSource.Stop;
begin
  if fDevice <> nil then fDevice.Stop;
  inherited Stop;
end;

procedure TRecorderModbusDataSource.ProcessWrites;
var
  I: Integer;
  lCandidate: QWord;
  lValue: Double;
begin
  for I := 0 to High(fBindings) do
  begin
    lCandidate := fBindings[I].WriteCursor;
    while fBindings[I].Tag.ReadExternalWrite(lCandidate, lValue) do
      if fModbusDevice.WriteValue(fBindings[I].DeviceIndex,
        fBindings[I].TagIndex, lValue) then
        fBindings[I].WriteCursor := lCandidate
      else
        Break;
  end;
end;

procedure TRecorderModbusDataSource.PublishChanged;
var
  I: Integer;
  lRuntimeTag: TRecorderModbusTagRuntime;
begin
  for I := 0 to High(fBindings) do
  begin
    lRuntimeTag := fModbusDevice.TagAt(fBindings[I].DeviceIndex,
      fBindings[I].TagIndex);
    if (lRuntimeTag.Generation = fBindings[I].LastGeneration) or
      (lRuntimeTag.Quality <> mqGood) then Continue;
    fBindings[I].LastGeneration := lRuntimeTag.Generation;
    fBindings[I].Tag.AddSample((GetTickCount64 - fStartedAtMs) / 1000.0,
      lRuntimeTag.Value);
  end;
end;

procedure TRecorderModbusDataSource.DoTick;
begin
  ProcessWrites;
  { Expected transport/protocol failures remain typed device state.  The
    worker survives while the runtime reconnect policy restores the session. }
  fModbusDevice.Iterate;
  PublishChanged;
end;

end.
