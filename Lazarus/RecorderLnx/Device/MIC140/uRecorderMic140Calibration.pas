unit uRecorderMic140Calibration;

{
  MIC-140 hardware calibration: CSV paths, registry, download from flash.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderMic140Flash, uRecorderMic140Utils, uRecorderMic140StreamTypes;

function RecorderMic140CalibrRootDir: string;
function RecorderMic140RangeCalibrDirName(ARangeIndex: Integer): string;
function RecorderMic140HardwareCalibrCsvPath(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
function RecorderMic140TInHardwareCalibrExportCsvPath(ADeviceSerial,
  ATinChannelNumber: Integer): string;
function RecorderMic140LoadCalibrationFromCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderMic140SaveCalibrationToCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderMic140MakeHardwareCalibrationName(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
function RecorderMic140UpsertHardwareCalibration(ARegistry: TRecorderTagRegistry;
  const AName: string; ASource: TRecorderCalibration): TRecorderCalibration;
function RecorderMic140MakeTInHardwareCalibrationName(ADeviceSerial,
  ATInFileNumber: Integer): string;
function RecorderMic140TInHardwareCalibrCsvPath(ADeviceSerial, ATInListIndex,
  ADevSubRev: Integer): string;
function RecorderMic140EnsureTInHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ADeviceSerial, ATInListIndex,
  ADevSubRev: Integer; out ACalibrationName: string): Boolean;
function RecorderMic140ResolveDeviceSerialForTag(ARegistry: TRecorderTagRegistry;
  const ATag: TRecorderTag; ADeviceSerial: Integer): Integer;
function RecorderMic140EnsureHardwareCalibrationInRegistry(
  ARegistry: TRecorderTagRegistry; ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer; out ACalibrationName: string): Boolean;
function RecorderMic140LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ADeviceSerial: Integer; AEnableOnTag: Boolean = True): Boolean;
procedure RecorderMic140ApplyHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial: Integer);
procedure RecorderMic140ApplyTInHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial, ADevSubRev: Integer; const ATemperatureTagNames: TStrings);
function RecorderMic140DownloadHardwareCalibrationFromDevice(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AErrorMessage: string): Boolean;

implementation

uses
  Math, StrUtils, LazFileUtils, fpjson,
  uRecorderProjectFiles,
  uRecorderMeraPaths,
  uRecorderMic140LegacyConstants, uRecorderMic140Thermocouple,
  uRecorderMic140StreamHelpers,
  uRecorderMic140MebiusConstants, uRecorderMic140DeviceConfig,
  uRecorderMic140Protocol, uRecorderMic140DeviceApi,
  uRecorderMic140WireTypes,
  uRecorderHardwareLiveDevices, uRecorderDeviceInterfaces;

{ TMic140v2Firmware (uRecorderMic140Protocol/WireTypes) and the independently
  declared uRecorderMic140StreamTypes.TRecorderMic140LegacyFirmware are
  structurally identical (11 Word fields) but nominally distinct record types
  kept in separate legacy-era units; copy field-by-field at the boundary. }
procedure Mic140CopyWireFirmwareToStreamFirmware(
  const ASrc: uRecorderMic140WireTypes.TRecorderMic140LegacyFirmware;
  out ADst: uRecorderMic140StreamTypes.TRecorderMic140LegacyFirmware);
begin
  ADst.Signature := ASrc.Signature;
  ADst.MdpType := ASrc.MdpType;
  ADst.DevType := ASrc.DevType;
  ADst.DevRevNo := ASrc.DevRevNo;
  ADst.DevSerNo := ASrc.DevSerNo;
  ADst.CCType := ASrc.CCType;
  ADst.CCSerNo := ASrc.CCSerNo;
  ADst.EepromManufactId := ASrc.EepromManufactId;
  ADst.EepromDeviceId := ASrc.EepromDeviceId;
  ADst.BiosFunction := ASrc.BiosFunction;
  ADst.BiosVersion := ASrc.BiosVersion;
end;

const
  CMic140RangeCalibrDirNames: array[0..CMic140RangeCount - 1] of string =
    ('06_100mV', '07_50mV', '8_25mV');
  CMic140HardwareCalibrSubDir = 'hardware' + PathDelim + 'MIC140' + PathDelim;
  CMic140TInCalibrSubDirName = 'TIn';

var
  g_Mic140TInCalibrFailedKeys: TStringList;
  g_Mic140TInCalibrMissLogged: TStringList;

type
  { Thin IMic140LegacyClient adapter over the clean TMic140v2Tcp transport, used
    only by the flash-download helpers below (Mic140Find.../Mic140TryRead...
    still take the narrow legacy-client interface). }
  TMic140LegacyClientAdapter = class(TInterfacedObject, IMic140LegacyClient)
  private
    fCli: TMic140v2Tcp;
  public
    constructor Create(ACli: TMic140v2Tcp);
    function ReadFirmware(out AFirmware: uRecorderMic140StreamTypes.TRecorderMic140LegacyFirmware;
      out AErrorMessage: string): Boolean;
    function ReadFlashStorage(AAddress: LongWord; var ABuffer;
      AByteCount: Integer; out AErrorMessage: string): Boolean;
    function StopScan(out AErrorMessage: string): Boolean;
  end;

  { Адаптер к сервисному интерфейсу уже зарегистрированного устройства.
    В отличие от отдельного TCP-клиента он не конкурирует с рабочей сессией. }
  TMic140LiveServiceClientAdapter = class(TInterfacedObject,
    IMic140LegacyClient)
  private
    fService: IMic140ServiceMemory;
  public
    constructor Create(const AService: IMic140ServiceMemory);
    function ReadFirmware(out AFirmware: uRecorderMic140StreamTypes.TRecorderMic140LegacyFirmware;
      out AErrorMessage: string): Boolean;
    function ReadFlashStorage(AAddress: LongWord; var ABuffer;
      AByteCount: Integer; out AErrorMessage: string): Boolean;
    function StopScan(out AErrorMessage: string): Boolean;
  end;

constructor TMic140LegacyClientAdapter.Create(ACli: TMic140v2Tcp);
begin
  inherited Create;
  fCli := ACli;
end;

function TMic140LegacyClientAdapter.ReadFirmware(
  out AFirmware: uRecorderMic140StreamTypes.TRecorderMic140LegacyFirmware;
  out AErrorMessage: string): Boolean;
var
  lWireFirmware: TMic140v2Firmware;
begin
  Result := fCli.ReadFirmware(lWireFirmware, AErrorMessage);
  if Result then
    Mic140CopyWireFirmwareToStreamFirmware(lWireFirmware, AFirmware);
end;

function TMic140LegacyClientAdapter.ReadFlashStorage(AAddress: LongWord;
  var ABuffer; AByteCount: Integer; out AErrorMessage: string): Boolean;
begin
  Result := fCli.ReadFlashStorage(AAddress, ABuffer, AByteCount, AErrorMessage);
end;

function TMic140LegacyClientAdapter.StopScan(out AErrorMessage: string): Boolean;
begin
  Result := fCli.StopScan(AErrorMessage);
end;

constructor TMic140LiveServiceClientAdapter.Create(
  const AService: IMic140ServiceMemory);
begin
  inherited Create;
  fService := AService;
end;

function TMic140LiveServiceClientAdapter.ReadFirmware(
  out AFirmware: uRecorderMic140StreamTypes.TRecorderMic140LegacyFirmware;
  out AErrorMessage: string): Boolean;
var
  lFirmware: uRecorderMic140WireTypes.TRecorderMic140LegacyFirmware;
begin
  Result := fService.ReadServiceFirmware(lFirmware, AErrorMessage);
  if Result then
    Mic140CopyWireFirmwareToStreamFirmware(lFirmware, AFirmware);
end;

function TMic140LiveServiceClientAdapter.ReadFlashStorage(AAddress: LongWord;
  var ABuffer; AByteCount: Integer; out AErrorMessage: string): Boolean;
begin
  Result := fService.ReadServiceFlash(AAddress, ABuffer, AByteCount,
    AErrorMessage);
end;

function TMic140LiveServiceClientAdapter.StopScan(
  out AErrorMessage: string): Boolean;
begin
  Result := fService.StopServiceScan(AErrorMessage);
end;

function RecorderMic140QueryHardwareCalibrSerial(const AHost: string; APort: Word;
  out ACalibrSerial: Integer): Boolean;
var
  lCli: TMic140v2Tcp;
  lErrorMessage: string;
  lFirmware: TMic140v2Firmware;
  lSourceId: string;
begin
  Result := False;
  ACalibrSerial := 0;
  lSourceId := RecorderMic140SourceId(AHost, APort);
  { При загрузке проекта не открываем протокольный сокет до успешного TEST.
    Так отсутствие прибора остаётся штатным offline-состоянием, а не
    исключением, которое перехватывает отладчик. }
  if not RecorderMic140TcpProbe(AHost, APort, 1000) then
  begin
    lErrorMessage := Format('connection test failed for %s:%d', [AHost, APort]);
    RecorderHardwareMarkSourceOffline(lSourceId, lErrorMessage);
    Mic140LogWarning(Format('[DataSource:%s] MIC-140 %s',
      [lSourceId, lErrorMessage]));
    Exit;
  end;
  lCli := TMic140v2Tcp.Create(AHost, APort, CMic140LegacyCommandTimeoutMs);
  try
    try
      lCli.Connect;
      RecorderHardwareClearSourceOffline(lSourceId);
    except
      on E: Exception do
      begin
        lErrorMessage := E.ClassName + ': ' + E.Message;
        RecorderHardwareMarkSourceOffline(lSourceId, lErrorMessage);
        Mic140LogWarning(Format('[DataSource:%s] MIC-140 connection failed: %s',
          [lSourceId, lErrorMessage]));
        Exit;
      end;
    end;
    if lCli.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ACalibrSerial := Mic140v2HardwareCalibrSerial(lFirmware);
      Result := ACalibrSerial > 0;
    end;
  finally
    lCli.Free;
  end;
end;

function Mic140TInCalibrFileNumber(ATInListIndex, ADevSubRev: Integer): Integer;
begin
  { CChannelTInMIC140::GetTransFileName использует физический GetChanN().
    Для 48v3 видимый список 0..6 соответствует физическим TIn6..TIn12. }
  if (ATInListIndex >= 0) and
    (ATInListIndex < MIC140v3VisibleTemperatureChannelCount) then
  begin
    if ADevSubRev = CMic140Mic140SubRev1 then
      Result := ATInListIndex + CMic140V3FirstVisibleTInNumber
    else
      Result := ATInListIndex + 1;
  end
  else
    Result := 0;
end;

function Mic140FindRegistryTagBySourceAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, ASourceId) and
      SameMic140Address(ARegistry.Tags[I].Address, AAddress) then
      Exit(ARegistry.Tags[I]);
end;

function Mic140FindTemperatureTag(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; ATemperatureListIndex: Integer): TRecorderTag;
var
  I: Integer;
  lIndex: Integer;
begin
  Result := nil;
  if (ARegistry = nil) or (ATemperatureListIndex < 1) then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, ASourceId) and
      ParseMic140TemperatureChannelIndex(ARegistry.Tags[I].Address, lIndex) and
      (lIndex = ATemperatureListIndex) then
      Exit(ARegistry.Tags[I]);
end;
function RecorderMic140CalibrRootDir: string;
begin
  Result := RecorderMeraCalibrRootDir;
end;

function RecorderMic140RangeCalibrDirName(ARangeIndex: Integer): string;
begin
  if (ARangeIndex >= 0) and (ARangeIndex < CMic140RangeCount) then
    Result := CMic140RangeCalibrDirNames[ARangeIndex]
  else
    Result := CMic140RangeCalibrDirNames[CMic140Range100mV];
end;

function RecorderMic140HardwareCalibrCsvPath(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
var
  lRangeDir: string;
begin
  if (ADeviceSerial <= 0) or (AChannelNumber <= 0) then
    Exit('');
  lRangeDir := RecorderMic140RangeCalibrDirName(ARangeIndex);
  Result := IncludeTrailingPathDelimiter(RecorderMic140CalibrRootDir) +
    CMic140HardwareCalibrSubDir + Format('sn%4.4d', [ADeviceSerial]) +
    PathDelim + lRangeDir + PathDelim + Format('%2.2d.csv', [AChannelNumber]);
end;

function RecorderMic140TInHardwareCalibrExportCsvPath(ADeviceSerial,
  ATinChannelNumber: Integer): string;
begin
  if (ADeviceSerial <= 0) or (ATinChannelNumber <= 0) then
    Exit('');
  { CChannelTInMIC140::GetTransFileName + GetCalibrGroupDir -> ...\TIn\NN.csv }
  Result := IncludeTrailingPathDelimiter(RecorderMic140CalibrRootDir) +
    CMic140HardwareCalibrSubDir + Format('sn%4.4d', [ADeviceSerial]) +
    PathDelim + CMic140TInCalibrSubDirName + PathDelim +
    Format('%2.2d.csv', [ATinChannelNumber]);
end;

function RecorderMic140ParseCsvNumber(const AText: string; out AValue: Double): Boolean;
var
  lFS: TFormatSettings;
  lText: string;
begin
  lText := Trim(StringReplace(AText, ',', '.', [rfReplaceAll]));
  lFS := DefaultFormatSettings;
  lFS.DecimalSeparator := '.';
  Result := TryStrToFloat(lText, AValue, lFS);
end;

function RecorderMic140LoadCalibrationFromCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  I: Integer;
  lLines: TStringList;
  lParts: TStringList;
  lX: Double;
  lY: Double;
begin
  Result := False;
  if (ACalibration = nil) or (Trim(AFileName) = '') or
    (not FileExistsUTF8(AFileName)) then
    Exit;

  lLines := TStringList.Create;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ',';
    lLines.LoadFromFile(AFileName);
    ACalibration.ClearPoints;
    for I := 0 to lLines.Count - 1 do
    begin
      if Trim(lLines[I]) = '' then
        Continue;
      lParts.DelimitedText := lLines[I];
      if lParts.Count < 2 then
        Continue;
      if not RecorderMic140ParseCsvNumber(lParts[0], lX) then
        Continue;
      if not RecorderMic140ParseCsvNumber(lParts[1], lY) then
        Continue;
      ACalibration.AddPoint(lX, lY);
    end;
    Result := ACalibration.PointCount > 0;
  finally
    lParts.Free;
    lLines.Free;
  end;
end;

function RecorderMic140MakeHardwareCalibrationName(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
begin
  Result := Format('MIC140 sn%4.4d %s ch%2.2d',
    [ADeviceSerial, RecorderMic140RangeCalibrDirName(ARangeIndex), AChannelNumber]);
end;

function RecorderMic140UpsertHardwareCalibration(ARegistry: TRecorderTagRegistry;
  const AName: string; ASource: TRecorderCalibration): TRecorderCalibration;
var
  lExisting: TRecorderCalibration;
begin
  Result := nil;
  if (ARegistry = nil) or (ASource = nil) or (Trim(AName) = '') then
    Exit;
  lExisting := ARegistry.FindCalibrationByName(AName);
  if lExisting = nil then
  begin
    Result := TRecorderCalibration.Create(rckPiecewiseLinear);
    Result.Assign(ASource);
    Result.Name := AName;
    ARegistry.Calibrations.Add(Result);
    Exit;
  end;
  lExisting.Assign(ASource);
  lExisting.Name := AName;
  Result := lExisting;
end;

function RecorderMic140MakeTInHardwareCalibrationName(ADeviceSerial,
  ATInFileNumber: Integer): string;
begin
  Result := Format('MIC140 sn%4.4d TIn ch%2.2d', [ADeviceSerial, ATInFileNumber]);
end;

function RecorderMic140TInHardwareCalibrCsvPath(ADeviceSerial, ATInListIndex,
  ADevSubRev: Integer): string;
var
  lTInFileNumber: Integer;
begin
  Result := '';
  if ADeviceSerial <= 0 then
    Exit;
  lTInFileNumber := Mic140TInCalibrFileNumber(ATInListIndex, ADevSubRev);
  if lTInFileNumber <= 0 then
    Exit;
  Result := IncludeTrailingPathDelimiter(RecorderMic140CalibrRootDir) +
    CMic140HardwareCalibrSubDir + Format('sn%4.4d', [ADeviceSerial]) +
    PathDelim + CMic140TInCalibrSubDirName + PathDelim +
    Format('%2.2d.csv', [lTInFileNumber]);
end;
function RecorderMic140EnsureTInHardwareCalibration(
  ARegistry: TRecorderTagRegistry; ADeviceSerial, ATInListIndex,
  ADevSubRev: Integer; out ACalibrationName: string): Boolean;
var
  lCalibration: TRecorderCalibration;
  lCacheKey: string;
  lCsvPath: string;
  lName: string;
  lTInFileNumber: Integer;
begin
  Result := False;
  ACalibrationName := '';
  if (ARegistry = nil) or (ADeviceSerial <= 0) or (ATInListIndex < 0) then
    Exit;
  lTInFileNumber := Mic140TInCalibrFileNumber(ATInListIndex, ADevSubRev);
  if lTInFileNumber <= 0 then
    Exit;
  lName := RecorderMic140MakeTInHardwareCalibrationName(ADeviceSerial,
    lTInFileNumber);
  if ARegistry.FindCalibrationByName(lName) <> nil then
  begin
    ACalibrationName := lName;
    Exit(True);
  end;
  lCsvPath := RecorderMic140TInHardwareCalibrCsvPath(ADeviceSerial,
    ATInListIndex, ADevSubRev);
  if lCsvPath = '' then
    Exit;
  lCacheKey := Format('%d:%d:%d', [ADeviceSerial, ATInListIndex, ADevSubRev]);
  if (g_Mic140TInCalibrFailedKeys <> nil) and
    (g_Mic140TInCalibrFailedKeys.IndexOf(lCacheKey) >= 0) and
    (not FileExistsUTF8(lCsvPath)) then
    Exit;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderMic140LoadCalibrationFromCsv(lCsvPath, lCalibration) then
    begin
      if g_Mic140TInCalibrFailedKeys <> nil then
        g_Mic140TInCalibrFailedKeys.Add(lCacheKey);
      if (g_Mic140TInCalibrMissLogged <> nil) and
        (g_Mic140TInCalibrMissLogged.IndexOf(lCsvPath) < 0) then
      begin
        g_Mic140TInCalibrMissLogged.Add(lCsvPath);
        Mic140LogWarning(Format('[MIC-140] TIn hardware calibration not found: %s',
          [lCsvPath]));
      end;
      Exit;
    end;
    lCalibration.Extrapolation := True;
    lCalibration.Name := lName;
    if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) = nil then
      Exit;
    if (g_Mic140TInCalibrFailedKeys <> nil) and
      (g_Mic140TInCalibrFailedKeys.IndexOf(lCacheKey) >= 0) then
      g_Mic140TInCalibrFailedKeys.Delete(
        g_Mic140TInCalibrFailedKeys.IndexOf(lCacheKey));
    ACalibrationName := lName;
    Result := True;
    Mic140LogWarning(Format('[MIC-140] loaded TIn hardware calibration from %s',
      [lCsvPath]));
  finally
    lCalibration.Free;
  end;
end;

function RecorderMic140ResolveDeviceSerialForTag(ARegistry: TRecorderTagRegistry;
  const ATag: TRecorderTag; ADeviceSerial: Integer): Integer;
var
  lHost: string;
  lPort: Word;
  lSerial: Integer;
  lHostOctet: Integer;
  lTagSerial: Integer;
begin
  if ADeviceSerial > 0 then
    Exit(ADeviceSerial);
  if (ATag <> nil) and (ARegistry <> nil) then
  begin
    lTagSerial := RecorderMic140DeviceSerialForSource(ARegistry, ATag.SourceId);
    if lTagSerial > 0 then
    begin
      if TryParseRecorderMic140SourceId(ATag.SourceId, lHost, lPort) and
         RecorderMic140HostLastOctet(lHost, lHostOctet) and
         (lTagSerial = lHostOctet) then
      begin
        { Старые конфиги сохраняли DevSerNo (= последний октет IP), не CCSerNo. }
      end
      else
        Exit(lTagSerial);
    end;
  end;
  if (ATag <> nil) and TryParseRecorderMic140SourceId(ATag.SourceId, lHost, lPort) and
    RecorderMic140QueryHardwareCalibrSerial(lHost, lPort, lSerial) then
    Exit(lSerial);
  Result := 0;
end;

function RecorderMic140EnsureHardwareCalibrationInRegistry(
  ARegistry: TRecorderTagRegistry; ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer; out ACalibrationName: string): Boolean;
var
  lCalibration: TRecorderCalibration;
  lCsvPath: string;
  lName: string;
begin
  Result := False;
  ACalibrationName := '';
  if (ARegistry = nil) or (ADeviceSerial <= 0) or (AChannelNumber <= 0) then
    Exit;
  if ARangeIndex >= CMic140RangeCount then
    ARangeIndex := CMic140Range100mV;
  lName := RecorderMic140MakeHardwareCalibrationName(ADeviceSerial, ARangeIndex,
    AChannelNumber);
  if ARegistry.FindCalibrationByName(lName) <> nil then
  begin
    ACalibrationName := lName;
    Exit(True);
  end;
  lCsvPath := RecorderMic140HardwareCalibrCsvPath(ADeviceSerial, ARangeIndex,
    AChannelNumber);
  if lCsvPath = '' then
    Exit;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderMic140LoadCalibrationFromCsv(lCsvPath, lCalibration) then
    begin
      Mic140LogWarning(Format('[MIC-140] hardware calibration not found: %s',
        [lCsvPath]));
      Exit;
    end;
    lCalibration.Extrapolation := True;
    lCalibration.Name := lName;
    if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) = nil then
      Exit;
    ACalibrationName := lName;
    Result := True;
    Mic140LogWarning(Format('[MIC-140] loaded hardware calibration from %s',
      [lCsvPath]));
  finally
    lCalibration.Free;
  end;
end;

function RecorderMic140LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ADeviceSerial: Integer; AEnableOnTag: Boolean): Boolean;
var
  lChannelNumber: Integer;
  lName: string;
  lRangeIndex: Integer;
  lSerial: Integer;
  lSettings: TRecorderMic140ChannelSettings;
begin
  Result := False;
  if (ARegistry = nil) or (ATag = nil) then
    Exit;
  if Pos(CMic140SourcePrefix, ATag.SourceId) <> 1 then
    Exit;
  if not ParseMic140ChannelNumber(ATag.Address, lChannelNumber) then
    Exit;

  lSerial := RecorderMic140ResolveDeviceSerialForTag(ARegistry, ATag, ADeviceSerial);
  if lSerial <= 0 then
    Exit;

  lRangeIndex := CMic140Range100mV;
  if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber, lSettings) then
    lRangeIndex := lSettings.RangeIndex;
  if lRangeIndex >= CMic140RangeCount then
    lRangeIndex := CMic140Range100mV;

  if not RecorderMic140EnsureHardwareCalibrationInRegistry(ARegistry, lSerial,
    lRangeIndex, lChannelNumber, lName) then
    Exit;
  RecorderMic140SetDeviceSerialForSource(ARegistry, ATag.SourceId, lSerial);
  lSettings.HardwareCalibrationName := lName;
  if AEnableOnTag then
    lSettings.HardwareCalibrationEnabled := True;
  RecorderMic140UpdateChannelSettings(ARegistry, ATag, lSettings);
  ATag.HardwareCalibrationName := lName;
  if AEnableOnTag then
    ATag.HardwareCalibrationEnabled := True;
  RecorderMic140ApplyTagOutputPresentation(ATag, lSettings);
  Result := True;
  Mic140LogWarning(Format('[MIC-140] assigned hardware calibration %s to tag %s',
    [lName, ATag.Name]));
end;

procedure RecorderMic140ApplyHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial: Integer);
var
  I: Integer;
  lCalName: string;
  lChannelNumber: Integer;
  lRangeIndex: Integer;
  lTag: TRecorderTag;
  lSettings: TRecorderMic140ChannelSettings;
begin
  if (ARegistry = nil) or (Trim(ASourceId) = '') then
    Exit;
  RecorderMic140SetDeviceSerialForSource(ARegistry, ASourceId, ADeviceSerial);
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if not SameText(lTag.SourceId, ASourceId) or
      (Pos('diagnostics.', LowerCase(lTag.Address)) = 1) or
      (not ParseMic140ChannelNumber(lTag.Address, lChannelNumber)) then
      Continue;
    lRangeIndex := CMic140Range100mV;
    if RecorderMic140TryGetChannelSettings(ARegistry, lTag, lChannelNumber,
      lSettings) then
      lRangeIndex := lSettings.RangeIndex;
    if lRangeIndex >= CMic140RangeCount then
      lRangeIndex := CMic140Range100mV;
    if not RecorderMic140EnsureHardwareCalibrationInRegistry(ARegistry,
      ADeviceSerial, lRangeIndex, lChannelNumber, lCalName) then
      Continue;
    if lTag.HardwareCalibrationEnabled then
    begin
      if Trim(lTag.HardwareCalibrationName) = '' then
        lTag.HardwareCalibrationName := lCalName;
    end;
  end;
end;

procedure RecorderMic140ApplyTInHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial, ADevSubRev: Integer; const ATemperatureTagNames: TStrings);
var
  I: Integer;
  lCalName: string;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (Trim(ASourceId) = '') or (ADeviceSerial <= 0) or
    (ATemperatureTagNames = nil) then
    Exit;
  for I := 0 to ATemperatureTagNames.Count - 1 do
  begin
    if not RecorderMic140EnsureTInHardwareCalibration(ARegistry, ADeviceSerial,
      I, ADevSubRev, lCalName) then
      Continue;
    lTag := Mic140FindRegistryTagBySourceAddress(ARegistry, ASourceId,
      ATemperatureTagNames[I]);
    if lTag = nil then
      lTag := ARegistry.FindByName(ATemperatureTagNames[I]);
    if lTag = nil then
      Continue;
    if lTag.HardwareCalibrationEnabled then
      lTag.HardwareCalibrationName := lCalName;
  end;
end;
function RecorderMic140SaveCalibrationToCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  lFS: TFormatSettings;
  lI: Integer;
  lLines: TStringList;
begin
  Result := False;
  if (ACalibration = nil) or (Trim(AFileName) = '') then
    Exit;
  ForceDirectories(ExtractFileDir(AFileName));
  lLines := TStringList.Create;
  try
    lFS := DefaultFormatSettings;
    lFS.DecimalSeparator := '.';
    for lI := 0 to ACalibration.PointCount - 1 do
      lLines.Add(Format('%.9g,%.9g',
        [ACalibration.PointAt(lI).X, ACalibration.PointAt(lI).Y], lFS));
    lLines.SaveToFile(AFileName);
    Result := lLines.Count > 0;
  finally
    lLines.Free;
  end;
end;
function RecorderMic140DownloadHardwareCalibrationFromDevice(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AErrorMessage: string): Boolean;
var
  lCli: TMic140v2Tcp;
  lCalibration: TRecorderCalibration;
  lCandidateAinCounts: array[0..1] of Integer;
  lChanIndex: Integer;
  lChannelNumber: Integer;
  lClient: IMic140LegacyClient;
  lCjcChannel: Integer;
  lCjcError: string;
  lCjcTag: TRecorderTag;
  lDevice: IRecorderDevice;
  lCsvPath: string;
  lFirmware: uRecorderMic140StreamTypes.TRecorderMic140LegacyFirmware;
  lHost: string;
  lIsTemperature: Boolean;
  lLayoutIndex: Integer;
  lLogPrefix: string;
  lMaxAinChannels: Integer;
  lMi118Base: LongWord;
  lName: string;
  lPort: Word;
  lRangeIndex: Integer;
  lSerial: Integer;
  lSettings: TRecorderMic140ChannelSettings;
  lService: IMic140ServiceMemory;
  lStopError: string;
  lTare: TMic140TareType1;
  lTare2: TMic140TareType2;
  lTempIndex: Integer;
  lTinFileNumber: Integer;
  lTryError: string;
begin
  Result := False;
  AErrorMessage := '';
  lLogPrefix := Format('[MIC-140 flash:%s]', [IfThen(ATag <> nil, ATag.Name, '?')]);
  if (ARegistry = nil) or (ATag = nil) then
  begin
    AErrorMessage := 'Tag registry is not available';
    Exit;
  end;
  if Pos(CMic140SourcePrefix, ATag.SourceId) <> 1 then
  begin
    AErrorMessage := 'Tag is not linked to MIC-140';
    Exit;
  end;
  lIsTemperature := ParseMic140TemperatureChannelIndex(ATag.Address, lTempIndex);
  if lIsTemperature then
  begin
    if (lTempIndex < 1) or
      (lTempIndex > MIC140v3VisibleTemperatureChannelCount) then
    begin
      AErrorMessage := 'Invalid MIC-140 temperature channel index';
      Exit;
    end;
    lTinFileNumber := Mic140TInCalibrFileNumber(lTempIndex - 1,
      CMic140Mic140SubRev1);
    lChannelNumber := 0;
  end
  else
  begin
    if not ParseMic140ChannelNumber(ATag.Address, lChannelNumber) then
    begin
      AErrorMessage := 'Invalid MIC-140 channel address';
      Exit;
    end;
  end;
  if not TryParseRecorderMic140SourceId(ATag.SourceId, lHost, lPort) then
  begin
    AErrorMessage := 'Invalid MIC-140 source id';
    Exit;
  end;

  lRangeIndex := CMic140Range100mV;
  if (not lIsTemperature) and
    RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber, lSettings) then
    lRangeIndex := lSettings.RangeIndex;
  if lRangeIndex >= CMic140RangeCount then
    lRangeIndex := CMic140Range100mV;

  if lIsTemperature then
    lChanIndex := -1
  else
  begin
    lChanIndex := lChannelNumber - 1;
    if lChanIndex < 0 then
    begin
      AErrorMessage := 'Invalid MIC-140 channel number';
      Exit;
    end;
  end;

  Mic140LogFlash(lLogPrefix + Format('start download host=%s port=%d address=%s chanIndex=%d temp=%s tagRange=%d log=%s',
    [lHost, lPort, ATag.Address, lChanIndex, BoolToStr(lIsTemperature, True),
     lRangeIndex, Mic140FlashLogFilePath()]));

  FillChar(lTare, SizeOf(lTare), 0);
  FillChar(lTare2, SizeOf(lTare2), 0);
  lCli := nil;
  lDevice := RecorderHardwareFindLiveDevice(ATag.SourceId);
  if (lDevice <> nil) and Supports(lDevice, IMic140ServiceMemory, lService) then
  begin
    lClient := TMic140LiveServiceClientAdapter.Create(lService);
    Mic140LogFlash(lLogPrefix + 'using registered MIC-140 service session');
  end
  else
  begin
    lCli := TMic140v2Tcp.Create(lHost, lPort, CMic140LegacyCommandTimeoutMs);
    lClient := TMic140LegacyClientAdapter.Create(lCli);
    Mic140LogFlash(lLogPrefix + 'using standalone MIC-140 service session');
  end;
  try
    if lCli <> nil then
      try
        lCli.Connect;
      except
        on E: Exception do
        begin
          AErrorMessage := 'Connect failed: ' + E.Message;
          Mic140LogFlash(lLogPrefix + AErrorMessage);
          Exit;
        end;
      end;
    if not lClient.ReadFirmware(lFirmware, AErrorMessage) then
    begin
      Mic140LogFlash(lLogPrefix + 'ReadFirmware failed: ' + AErrorMessage);
      Exit;
    end;

    Mic140LogFlash(lLogPrefix + Format('firmware sig=%u mdp=%u devType=%u devRev=%u devSerNo=%u ccType=%u ccSerNo=%u bios=%u.%u',
      [lFirmware.Signature, lFirmware.MdpType, lFirmware.DevType, lFirmware.DevRevNo, lFirmware.DevSerNo,
      lFirmware.CCType, lFirmware.CCSerNo, lFirmware.BiosFunction, lFirmware.BiosVersion]));

    if not lClient.StopScan(lStopError) then
      Mic140LogFlash(lLogPrefix + 'StopScan before flash read failed: ' + lStopError)
    else
      Mic140LogFlash(lLogPrefix + 'StopScan before flash read: ok');

    lSerial := RecorderMic140HardwareCalibrSerialFromFirmware(lFirmware);
    Mic140LogFlash(lLogPrefix + Format(
      'using hardware calibr serial=%d (DevSerNo=%u CCSerNo=%u tag address=%s)',
      [lSerial, lFirmware.DevSerNo, lFirmware.CCSerNo, ATag.Address]));
    if lSerial <= 0 then
    begin
      AErrorMessage := 'Device serial number is unknown';
      Mic140LogFlash(lLogPrefix + AErrorMessage);
      Exit;
    end;

    lCandidateAinCounts[0] := CMic140MaxAinChannels48;
    lCandidateAinCounts[1] := CMic140MaxAinChannels96;
    if Mic140ResolveMaxAinChannelsFromFirmware(lFirmware) = CMic140MaxAinChannels96 then
    begin
      lCandidateAinCounts[0] := CMic140MaxAinChannels96;
      lCandidateAinCounts[1] := CMic140MaxAinChannels48;
    end;

    for lLayoutIndex := 0 to High(lCandidateAinCounts) do
    begin
      lMaxAinChannels := lCandidateAinCounts[lLayoutIndex];
      Mic140LogFlash(lLogPrefix + Format('try layout #%d maxAin=%d maxTin=%d',
        [lLayoutIndex, lMaxAinChannels, CMic140MaxTinChannels96]));
      if not Mic140FindMi118TarBaseAddress(lClient, lMaxAinChannels,
        CMic140MaxTinChannels96, lMi118Base, lTryError,
        lLogPrefix + Format('layout%d', [lLayoutIndex])) then
      begin
        AErrorMessage := lTryError;
        Continue;
      end;

      if lIsTemperature then
      begin
        { В v3 видимый T1 списка означает физический T6 во flash-дескрипторе. }
        lChanIndex := lMaxAinChannels +
          (lTinFileNumber - 1);
        if Mic140TryReadHardwareTare2FromFlash(lClient, lMi118Base, lChanIndex,
          lMaxAinChannels, CMic140MaxTinChannels96, lRangeIndex, lTare2, lRangeIndex,
          lTryError, lLogPrefix + Format('layout%d', [lLayoutIndex])) then
          Break;
      end
      else
      if Mic140TryReadHardwareTareFromFlash(lClient, lMi118Base, lChanIndex,
        lMaxAinChannels, CMic140MaxTinChannels96, lRangeIndex, lTare, lRangeIndex,
        lTryError, lLogPrefix + Format('layout%d', [lLayoutIndex])) then
        Break;

      AErrorMessage := lTryError;
    end;

    if lIsTemperature then
    begin
      if not Mic140HardwareTare2IsUsable(lTare2) then
      begin
        if Trim(AErrorMessage) = '' then
          AErrorMessage := 'Calibration was not found in device flash memory';
        AErrorMessage := AErrorMessage + ' (details in ' + Mic140FlashLogFilePath() + ')';
        Mic140LogFlash(lLogPrefix + 'TIn download failed: ' + AErrorMessage);
        Exit;
      end;
    end
    else
    if not Mic140HardwareTareIsUsable(lTare) then
    begin
      if Trim(AErrorMessage) = '' then
        AErrorMessage := 'Calibration was not found in device flash memory';
      AErrorMessage := AErrorMessage + ' (details in ' + Mic140FlashLogFilePath() + ')';
      Mic140LogFlash(lLogPrefix + 'download failed: ' + AErrorMessage);
      Exit;
    end;

    lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
    try
      if lIsTemperature then
      begin
        if not Mic140Tare2ToCalibration(lTare2, lCalibration) then
        begin
          AErrorMessage := 'Unsupported TIn calibration format in device flash (details in ' +
            Mic140FlashLogFilePath() + ')';
          Mic140LogFlash(lLogPrefix + AErrorMessage + ' ' + Mic140DescribeTare2Record(lTare2));
          Exit;
        end;
        lName := RecorderMic140MakeTInHardwareCalibrationName(lSerial, lTinFileNumber);
        lCsvPath := RecorderMic140TInHardwareCalibrExportCsvPath(lSerial, lTinFileNumber);
      end
      else
      begin
        if not Mic140TareToCalibration(lTare, lCalibration) then
        begin
          AErrorMessage := 'Unsupported calibration format in device flash (details in ' +
            Mic140FlashLogFilePath() + ')';
          Mic140LogFlash(lLogPrefix + AErrorMessage + ' ' + Mic140DescribeTareRecord(lTare));
          Exit;
        end;
        lName := RecorderMic140MakeHardwareCalibrationName(lSerial, lRangeIndex,
          lChannelNumber);
        lCsvPath := RecorderMic140HardwareCalibrCsvPath(lSerial, lRangeIndex,
          lChannelNumber);
      end;
      if not RecorderMic140SaveCalibrationToCsv(lCsvPath, lCalibration) then
      begin
        AErrorMessage := 'Failed to save calibration CSV';
        Mic140LogFlash(lLogPrefix + AErrorMessage + ' path=' + lCsvPath);
        Exit;
      end;

      if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) = nil then
      begin
        AErrorMessage := 'Failed to register hardware calibration';
        Mic140LogFlash(lLogPrefix + AErrorMessage);
        Exit;
      end;

      RecorderMic140SetDeviceSerialForSource(ARegistry, ATag.SourceId, lSerial);
      if not lIsTemperature then
      begin
        if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
          lSettings) then
        begin
          lSettings.RangeIndex := lRangeIndex;
          lSettings.HardwareCalibrationName := lName;
          lSettings.HardwareCalibrationEnabled := True;
          RecorderMic140UpdateChannelSettings(ARegistry, ATag, lSettings);
        end;
      end;
      ATag.HardwareCalibrationName := lName;
      ATag.HardwareCalibrationEnabled := True;
      if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
        lSettings) then
        RecorderMic140ApplyTagOutputPresentation(ATag, lSettings);
      if lIsTemperature then
        Mic140LogWarning(Format('[MIC-140] downloaded TIn hardware calibration for tag %s to %s',
          [ATag.Name, lCsvPath]))
      else
        Mic140LogWarning(Format('[MIC-140] downloaded hardware calibration for tag %s to %s',
          [ATag.Name, lCsvPath]));
      Mic140LogFlash(lLogPrefix + Format('download success csv=%s points=%d',
        [lCsvPath, lCalibration.PointCount]));
      Result := True;
    finally
      lCalibration.Free;
    end;
  finally
    lClient := nil;
    lCli.Free;
  end;

  { В оригинальном Recorder калибровка корректирующего TIn является частью
    готовности термопарного канала. Поэтому после ручного чтения ГХ AIn сразу
    читаем один связанный TIn, а не ждём отдельной операции над служебным тегом. }
  if Result and (not lIsTemperature) and
    RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
      lSettings) and RecorderMic140ChannelUsesTemperature(lSettings) then
  begin
    if lSettings.DefaultCjc then
      lCjcChannel := RecorderMic140DefaultCjcChannel(lChannelNumber - 1,
        CMic140Mic140SubRev1)
    else
      lCjcChannel := lSettings.CjcChannel;
    lCjcTag := Mic140FindTemperatureTag(ARegistry, ATag.SourceId, lCjcChannel);
    if (lCjcTag <> nil) and
      (not RecorderMic140LoadHardwareCalibrationForTag(ARegistry, lCjcTag,
        lSerial, True)) then
      if not RecorderMic140DownloadHardwareCalibrationFromDevice(ARegistry,
        lCjcTag, lCjcError) then
        Mic140LogWarning(Format(
          '[MIC-140] CJC T%d calibration download failed after AIn %d: %s',
          [lCjcChannel + CMic140V3FirstVisibleTInNumber - 1,
           lChannelNumber, lCjcError]));
  end;
end;

procedure RecorderMic140CalibrationProjectTagLoaded(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);
var
  lChannelNumber: Integer;
  lDeviceSerial: Integer;
  lSettings: TRecorderMic140ChannelSettings;
begin
  if (ARegistry = nil) or (ATag = nil) or
    (Pos(CMic140SourcePrefix, ATag.SourceId) <> 1) then
    Exit;

  { Конфигурация устройства загружается раньше тегов. В новых проектах флаг
    применения аппаратной ГХ принадлежит тегу; копия в старом channel config
    используется только как fallback для прежнего формата. }
  if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
    lSettings) then
  begin
    if (AJson <> nil) and
      (AJson.Find('hardwareCalibrationEnabled') <> nil) then
    begin
      lSettings.HardwareCalibrationEnabled :=
        ATag.HardwareCalibrationEnabled;
      lSettings.HardwareCalibrationName := ATag.HardwareCalibrationName;
      RecorderMic140UpdateChannelSettings(ARegistry, ATag, lSettings);
    end
    else
    begin
      ATag.HardwareCalibrationEnabled :=
        lSettings.HardwareCalibrationEnabled;
      ATag.HardwareCalibrationName := lSettings.HardwareCalibrationName;
    end;
    RecorderMic140ApplyTagOutputPresentation(ATag, lSettings);
  end;
  { Project loading is a UI-startup path and must not probe the same device
    once per tag. Use only the serial already stored in the device config;
    PrepareHardware resolves the live serial once after the form is shown. }
  lDeviceSerial := RecorderMic140DeviceSerialForSource(ARegistry,
    ATag.SourceId);
  if lDeviceSerial > 0 then
    RecorderMic140LoadHardwareCalibrationForTag(ARegistry, ATag,
      lDeviceSerial, False);
end;

initialization
  RecorderRegisterProjectConfigExtension(nil, nil,
    @RecorderMic140CalibrationProjectTagLoaded);
  g_Mic140TInCalibrFailedKeys := TStringList.Create;
  g_Mic140TInCalibrFailedKeys.Sorted := True;
  g_Mic140TInCalibrFailedKeys.Duplicates := dupIgnore;
  g_Mic140TInCalibrMissLogged := TStringList.Create;
  g_Mic140TInCalibrMissLogged.Sorted := True;
  g_Mic140TInCalibrMissLogged.Duplicates := dupIgnore;

finalization
  FreeAndNil(g_Mic140TInCalibrMissLogged);
  FreeAndNil(g_Mic140TInCalibrFailedKeys);

end.
