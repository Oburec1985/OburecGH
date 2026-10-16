unit uModbusCoreTypes;

{$mode objfpc}{$H+}

// Pure Modbus domain types.  The runtime datasource owns transports; this
// unit only describes the stable Bus -> Device -> Tag configuration tree.
interface

uses
  Classes, SysUtils, Contnrs, fpjson, jsonparser;

type
  TModbusTransport = (mtTcp, mtRtu);
  TModbusRegion = (mrCoil, mrDiscreteInput, mrInputRegister, mrHoldingRegister);
  TModbusDataType = (mdBool, mdUInt16, mdInt16, mdUInt32, mdInt32, mdFloat32,
    mdFloat64);
  TModbusByteOrder = (moABCD, moBADC, moCDAB, moDCBA);
  TModbusAccess = (maReadOnly, maReadWrite);

  TModbusTagConfig = class
  public
    Id: string;
    Alias: string;
    Description: string;
    Enabled: Boolean;
    EngineeringUnit: string;
    Scale: Double;
    Offset: Double;
    Region: TModbusRegion;
    Address: Word;             // Protocol address, always zero based.
    DataType: TModbusDataType;
    ByteOrder: TModbusByteOrder;
    Access: TModbusAccess;
    constructor Create;
    procedure Assign(ASource: TModbusTagConfig);
    function RegisterCount: Word;
    function ToJson: TJSONObject;
    procedure LoadJson(AJson: TJSONObject);
  end;

  TModbusDeviceConfig = class
  private
    fTags: TFPObjectList;
  public
    Id: string;
    Alias: string;
    Description: string;
    UnitId: Byte;
    Enabled: Boolean;
    constructor Create;
    destructor Destroy; override;
    function AddTag: TModbusTagConfig;
    procedure RemoveTag(ATag: TModbusTagConfig);
    function TagCount: Integer;
    function TagAt(AIndex: Integer): TModbusTagConfig;
    function ToJson: TJSONObject;
    procedure LoadJson(AJson: TJSONObject);
    procedure Assign(ASource: TModbusDeviceConfig);
  end;

  TModbusBusConfig = class
  private
    fDevices: TFPObjectList;
  public
    Alias: string;
    Transport: TModbusTransport;
    Host: string;
    Port: Word;
    SerialPort: string;
    BaudRate: Integer;
    DataBits: Byte;
    Parity: Char;
    StopBits: Byte;
    TimeoutMs: Cardinal;
    PollIntervalMs: Cardinal;
    Retries: Byte;
    constructor Create;
    destructor Destroy; override;
    function AddDevice: TModbusDeviceConfig;
    procedure RemoveDevice(ADevice: TModbusDeviceConfig);
    procedure Clear;
    function DeviceCount: Integer;
    function DeviceAt(AIndex: Integer): TModbusDeviceConfig;
    function ToJsonString: string;
    procedure LoadJsonString(const AText: string);
    procedure Assign(ASource: TModbusBusConfig);
    function Clone: TModbusBusConfig;
    function Validate(out AError: string): Boolean;
  end;

const
  CRecorderModbusModuleType = 'Modbus Master';
  CRecorderModbusSourcePrefix = 'Modbus: ';

function ModbusTagIdentity(const ADataSourceAlias, ATagAlias: string): string;
function RecorderModbusSourceId(const AAlias: string): string;
function RecorderIsModbusSource(const ASourceId: string): Boolean;
function ModbusTransportName(AValue: TModbusTransport): string;
function ModbusRegionName(AValue: TModbusRegion): string;
function ModbusRegionDisplayName(AValue: TModbusRegion): string;
function ModbusDataTypeName(AValue: TModbusDataType): string;
function ModbusByteOrderName(AValue: TModbusByteOrder): string;
function ModbusAccessName(AValue: TModbusAccess): string;
function TryParseReferenceAddress(const AText: string; out ARegion: TModbusRegion;
  out AAddress: Word): Boolean;
function FormatReferenceAddress(ARegion: TModbusRegion; AAddress: Word): string;

implementation

const
  CTransportNames: array[TModbusTransport] of string = ('tcp', 'rtu');
  CRegionNames: array[TModbusRegion] of string =
    ('coil', 'discreteInput', 'inputRegister', 'holdingRegister');
  CDataTypeNames: array[TModbusDataType] of string =
    ('bool', 'uint16', 'int16', 'uint32', 'int32', 'float32', 'float64');
  COrderNames: array[TModbusByteOrder] of string = ('ABCD', 'BADC', 'CDAB', 'DCBA');
  CAccessNames: array[TModbusAccess] of string = ('read', 'readWrite');

function NewStableId: string;
var
  lGuid: TGUID;
begin
  if CreateGUID(lGuid) <> 0 then
    raise Exception.Create('Cannot create stable identifier');
  Result := LowerCase(GUIDToString(lGuid));
end;

function EnumNameIndex(const AValue: string; const ANames: array of string): Integer;
var
  lIndex: Integer;
begin
  Result := -1;
  for lIndex := 0 to High(ANames) do
    if SameText(AValue, ANames[lIndex]) then
      Exit(lIndex);
end;

constructor TModbusTagConfig.Create;
begin
  Id := NewStableId;
  Enabled := True;
  Scale := 1.0;
  Region := mrHoldingRegister;
  DataType := mdFloat32;
  ByteOrder := moABCD;
  Access := maReadOnly;
end;

procedure TModbusTagConfig.Assign(ASource: TModbusTagConfig);
begin
  Id := ASource.Id; Alias := ASource.Alias; Description := ASource.Description;
  Enabled := ASource.Enabled; EngineeringUnit := ASource.EngineeringUnit;
  Scale := ASource.Scale; Offset := ASource.Offset; Region := ASource.Region;
  Address := ASource.Address; DataType := ASource.DataType;
  ByteOrder := ASource.ByteOrder; Access := ASource.Access;
end;

function TModbusTagConfig.RegisterCount: Word;
begin
  { Recorder exposes every channel as a number. Coil/discrete values are
    normalized to 0 or 1 and occupy one Modbus bit regardless of the stale
    register data-type value that may be present in an imported config. }
  if Region in [mrCoil, mrDiscreteInput] then Exit(1);
  case DataType of
    mdBool, mdUInt16, mdInt16: Result := 1;
    mdUInt32, mdInt32, mdFloat32: Result := 2;
    mdFloat64: Result := 4;
  end;
end;

function TModbusTagConfig.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('id', Id);
  Result.Add('alias', Alias);
  Result.Add('description', Description);
  Result.Add('enabled', Enabled);
  Result.Add('unit', EngineeringUnit);
  Result.Add('scale', Scale);
  Result.Add('offset', Offset);
  Result.Add('region', CRegionNames[Region]);
  Result.Add('address', Address);
  Result.Add('dataType', CDataTypeNames[DataType]);
  Result.Add('byteOrder', COrderNames[ByteOrder]);
  Result.Add('access', CAccessNames[Access]);
end;

procedure TModbusTagConfig.LoadJson(AJson: TJSONObject);
var
  lIndex: Integer;
begin
  Id := AJson.Get('id', Id);
  Alias := AJson.Get('alias', '');
  Description := AJson.Get('description', '');
  Enabled := AJson.Get('enabled', True);
  EngineeringUnit := AJson.Get('unit', '');
  Scale := AJson.Get('scale', 1.0);
  Offset := AJson.Get('offset', 0.0);
  Address := AJson.Get('address', 0);
  lIndex := EnumNameIndex(AJson.Get('region', ''), CRegionNames);
  if lIndex < 0 then raise EJSON.Create('Unknown Modbus region');
  Region := TModbusRegion(lIndex);
  lIndex := EnumNameIndex(AJson.Get('dataType', ''), CDataTypeNames);
  if lIndex < 0 then raise EJSON.Create('Unknown Modbus data type');
  DataType := TModbusDataType(lIndex);
  lIndex := EnumNameIndex(AJson.Get('byteOrder', 'ABCD'), COrderNames);
  if lIndex < 0 then raise EJSON.Create('Unknown Modbus byte order');
  ByteOrder := TModbusByteOrder(lIndex);
  lIndex := EnumNameIndex(AJson.Get('access', 'read'), CAccessNames);
  if lIndex < 0 then raise EJSON.Create('Unknown Modbus access');
  Access := TModbusAccess(lIndex);
end;

constructor TModbusDeviceConfig.Create;
begin
  fTags := TFPObjectList.Create(True);
  Id := NewStableId;
  UnitId := 1;
  Enabled := True;
end;

destructor TModbusDeviceConfig.Destroy;
begin
  fTags.Free;
  inherited Destroy;
end;

function TModbusDeviceConfig.AddTag: TModbusTagConfig;
begin
  Result := TModbusTagConfig.Create;
  fTags.Add(Result);
end;

procedure TModbusDeviceConfig.RemoveTag(ATag: TModbusTagConfig);
begin
  fTags.Remove(ATag);
end;

function TModbusDeviceConfig.TagCount: Integer;
begin
  Result := fTags.Count;
end;

function TModbusDeviceConfig.TagAt(AIndex: Integer): TModbusTagConfig;
begin
  Result := TModbusTagConfig(fTags[AIndex]);
end;

function TModbusDeviceConfig.ToJson: TJSONObject;
var
  lTags: TJSONArray;
  lIndex: Integer;
begin
  Result := TJSONObject.Create;
  Result.Add('id', Id);
  Result.Add('alias', Alias);
  Result.Add('description', Description);
  Result.Add('unitId', UnitId);
  Result.Add('enabled', Enabled);
  lTags := TJSONArray.Create;
  Result.Add('tags', lTags);
  for lIndex := 0 to fTags.Count - 1 do
    lTags.Add(TagAt(lIndex).ToJson);
end;

procedure TModbusDeviceConfig.LoadJson(AJson: TJSONObject);
var
  lTags: TJSONArray;
  lIndex: Integer;
begin
  fTags.Clear;
  Id := AJson.Get('id', Id);
  Alias := AJson.Get('alias', '');
  Description := AJson.Get('description', '');
  UnitId := AJson.Get('unitId', 1);
  Enabled := AJson.Get('enabled', True);
  lTags := AJson.Arrays['tags'];
  for lIndex := 0 to lTags.Count - 1 do
    AddTag.LoadJson(lTags.Objects[lIndex]);
end;

procedure TModbusDeviceConfig.Assign(ASource: TModbusDeviceConfig);
var
  lIndex: Integer;
begin
  fTags.Clear;
  Id := ASource.Id; Alias := ASource.Alias; Description := ASource.Description;
  UnitId := ASource.UnitId; Enabled := ASource.Enabled;
  for lIndex := 0 to ASource.TagCount - 1 do
    AddTag.Assign(ASource.TagAt(lIndex));
end;

constructor TModbusBusConfig.Create;
begin
  fDevices := TFPObjectList.Create(True);
  Transport := mtTcp;
  Host := '127.0.0.1';
  Port := 502;
  BaudRate := 9600;
  DataBits := 8;
  Parity := 'N';
  StopBits := 1;
  TimeoutMs := 1000;
  PollIntervalMs := 100;
  Retries := 2;
end;

destructor TModbusBusConfig.Destroy;
begin
  fDevices.Free;
  inherited Destroy;
end;

function TModbusBusConfig.AddDevice: TModbusDeviceConfig;
begin
  Result := TModbusDeviceConfig.Create;
  fDevices.Add(Result);
end;

procedure TModbusBusConfig.RemoveDevice(ADevice: TModbusDeviceConfig);
begin
  fDevices.Remove(ADevice);
end;

procedure TModbusBusConfig.Clear;
begin
  fDevices.Clear;
end;

function TModbusBusConfig.DeviceCount: Integer;
begin
  Result := fDevices.Count;
end;

function TModbusBusConfig.DeviceAt(AIndex: Integer): TModbusDeviceConfig;
begin
  Result := TModbusDeviceConfig(fDevices[AIndex]);
end;

function TModbusBusConfig.ToJsonString: string;
var
  lRoot, lTcp, lRtu: TJSONObject;
  lDevices: TJSONArray;
  lIndex: Integer;
begin
  lRoot := TJSONObject.Create;
  try
    lRoot.Add('schema', 1);
    lRoot.Add('alias', Alias);
    lRoot.Add('transport', CTransportNames[Transport]);
    lRoot.Add('timeoutMs', TimeoutMs);
    lRoot.Add('pollIntervalMs', PollIntervalMs);
    lRoot.Add('retries', Retries);
    lTcp := TJSONObject.Create(['host', Host, 'port', Port]);
    lRoot.Add('tcp', lTcp);
    lRtu := TJSONObject.Create(['port', SerialPort, 'baudRate', BaudRate,
      'dataBits', DataBits, 'parity', string(Parity), 'stopBits', StopBits]);
    lRoot.Add('rtu', lRtu);
    lDevices := TJSONArray.Create;
    lRoot.Add('devices', lDevices);
    for lIndex := 0 to fDevices.Count - 1 do
      lDevices.Add(DeviceAt(lIndex).ToJson);
    Result := lRoot.FormatJSON;
  finally
    lRoot.Free;
  end;
end;

procedure TModbusBusConfig.LoadJsonString(const AText: string);
var
  lRoot, lTcp, lRtu: TJSONObject;
  lDevices: TJSONArray;
  lData: TJSONData;
  lIndex, lEnum: Integer;
  lParity: string;
begin
  lData := GetJSON(AText);
  try
    if lData.JSONType <> jtObject then raise EJSON.Create('Root must be object');
    lRoot := TJSONObject(lData);
    if lRoot.Get('schema', 0) <> 1 then raise EJSON.Create('Unsupported schema');
    fDevices.Clear;
    Alias := lRoot.Get('alias', '');
    TimeoutMs := lRoot.Get('timeoutMs', 1000);
    PollIntervalMs := lRoot.Get('pollIntervalMs', 100);
    Retries := lRoot.Get('retries', 2);
    lEnum := EnumNameIndex(lRoot.Get('transport', ''), CTransportNames);
    if lEnum < 0 then raise EJSON.Create('Unknown transport');
    Transport := TModbusTransport(lEnum);
    lTcp := lRoot.Objects['tcp'];
    Host := lTcp.Get('host', '127.0.0.1');
    Port := lTcp.Get('port', 502);
    lRtu := lRoot.Objects['rtu'];
    SerialPort := lRtu.Get('port', '');
    BaudRate := lRtu.Get('baudRate', 9600);
    DataBits := lRtu.Get('dataBits', 8);
    lParity := lRtu.Get('parity', 'N');
    if lParity = '' then Parity := 'N' else Parity := UpCase(lParity[1]);
    StopBits := lRtu.Get('stopBits', 1);
    lDevices := lRoot.Arrays['devices'];
    for lIndex := 0 to lDevices.Count - 1 do
      AddDevice.LoadJson(lDevices.Objects[lIndex]);
  finally
    lData.Free;
  end;
end;

procedure TModbusBusConfig.Assign(ASource: TModbusBusConfig);
var
  lIndex: Integer;
begin
  Clear;
  Alias := ASource.Alias; Transport := ASource.Transport;
  Host := ASource.Host; Port := ASource.Port; SerialPort := ASource.SerialPort;
  BaudRate := ASource.BaudRate; DataBits := ASource.DataBits;
  Parity := ASource.Parity; StopBits := ASource.StopBits;
  TimeoutMs := ASource.TimeoutMs; PollIntervalMs := ASource.PollIntervalMs;
  Retries := ASource.Retries;
  for lIndex := 0 to ASource.DeviceCount - 1 do
    AddDevice.Assign(ASource.DeviceAt(lIndex));
end;

function TModbusBusConfig.Clone: TModbusBusConfig;
begin
  Result := TModbusBusConfig.Create;
  Result.Assign(Self);
end;

function TModbusBusConfig.Validate(out AError: string): Boolean;
var
  lDeviceIndex, lOtherDevice, lTagIndex, lOtherTag: Integer;
  lDevice: TModbusDeviceConfig;
  lTag: TModbusTagConfig;
  lSpanEnd: Cardinal;
begin
  Result := False; AError := '';
  if Trim(Alias) = '' then begin AError := 'Bus alias is required'; Exit; end;
  if PollIntervalMs = 0 then begin AError := 'Poll interval must be positive'; Exit; end;
  for lDeviceIndex := 0 to DeviceCount - 1 do begin
    lDevice := DeviceAt(lDeviceIndex);
    if Trim(lDevice.Id) = '' then begin AError := 'Device id is required'; Exit; end;
    if Trim(lDevice.Alias) = '' then begin AError := 'Device alias is required'; Exit; end;
    if not (lDevice.UnitId in [1..247]) then begin AError := 'Unit id must be in 1..247'; Exit; end;
    for lOtherDevice := 0 to lDeviceIndex - 1 do
      if SameText(DeviceAt(lOtherDevice).Alias, lDevice.Alias) then begin AError := 'Duplicate device alias: ' + lDevice.Alias; Exit; end;
    for lTagIndex := 0 to lDevice.TagCount - 1 do begin
      lTag := lDevice.TagAt(lTagIndex);
      if Trim(lTag.Id) = '' then begin AError := 'Tag id is required'; Exit; end;
      if Trim(lTag.Alias) = '' then begin AError := 'Tag alias is required'; Exit; end;
      for lOtherDevice := 0 to DeviceCount - 1 do
        for lOtherTag := 0 to DeviceAt(lOtherDevice).TagCount - 1 do
          if ((lOtherDevice < lDeviceIndex) or ((lOtherDevice = lDeviceIndex) and (lOtherTag < lTagIndex))) and
             SameText(DeviceAt(lOtherDevice).TagAt(lOtherTag).Alias, lTag.Alias) then begin AError := 'Duplicate public tag alias: ' + lTag.Alias; Exit; end;
      if (lTag.Region in [mrInputRegister, mrHoldingRegister]) and (lTag.DataType = mdBool) then begin AError := 'Register regions do not accept Bool data type'; Exit; end;
      if (lTag.Access = maReadWrite) and (lTag.Region in [mrDiscreteInput, mrInputRegister]) then begin AError := 'Input regions are read-only'; Exit; end;
      lSpanEnd := Cardinal(lTag.Address) + lTag.RegisterCount;
      if lSpanEnd > 65536 then begin AError := 'Tag register span exceeds address space'; Exit; end;
    end;
  end;
  Result := True;
end;

function ModbusTagIdentity(const ADataSourceAlias, ATagAlias: string): string;
begin
  Result := ADataSourceAlias + '/' + ATagAlias;
end;

function RecorderModbusSourceId(const AAlias: string): string;
begin
  Result := CRecorderModbusSourcePrefix + AAlias;
end;

function RecorderIsModbusSource(const ASourceId: string): Boolean;
begin
  Result := Copy(ASourceId, 1, Length(CRecorderModbusSourcePrefix)) = CRecorderModbusSourcePrefix;
end;

function ModbusTransportName(AValue: TModbusTransport): string;
begin Result := CTransportNames[AValue]; end;
function ModbusRegionName(AValue: TModbusRegion): string;
begin Result := CRegionNames[AValue]; end;
function ModbusDataTypeName(AValue: TModbusDataType): string;
begin Result := CDataTypeNames[AValue]; end;
function ModbusByteOrderName(AValue: TModbusByteOrder): string;
begin Result := COrderNames[AValue]; end;
function ModbusAccessName(AValue: TModbusAccess): string;
begin Result := CAccessNames[AValue]; end;
function ModbusRegionDisplayName(AValue: TModbusRegion): string;
const CDisplay: array[TModbusRegion] of string = ('Coils', 'Discrete Inputs', 'Input Registers', 'Holding Registers');
begin Result := CDisplay[AValue]; end;

function TryParseReferenceAddress(const AText: string; out ARegion: TModbusRegion;
  out AAddress: Word): Boolean;
var
  lValue, lBase: Int64;
begin
  Result := TryStrToInt64(Trim(AText), lValue);
  if not Result then Exit;
  if (lValue >= 1) and (lValue <= 9999) then begin ARegion := mrCoil; lBase := 1; end
  else if (lValue >= 10001) and (lValue <= 19999) then begin ARegion := mrDiscreteInput; lBase := 10001; end
  else if (lValue >= 30001) and (lValue <= 39999) then begin ARegion := mrInputRegister; lBase := 30001; end
  else if (lValue >= 40001) and (lValue <= 49999) then begin ARegion := mrHoldingRegister; lBase := 40001; end
  else Exit(False);
  AAddress := lValue - lBase;
end;

function FormatReferenceAddress(ARegion: TModbusRegion; AAddress: Word): string;
const
  CBase: array[TModbusRegion] of Cardinal = (1, 10001, 30001, 40001);
begin
  Result := IntToStr(CBase[ARegion] + AAddress);
end;

end.
