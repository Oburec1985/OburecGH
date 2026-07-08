unit uRecorderMic140Calibration;

{
  MIC-140 hardware calibration: CSV paths, registry, download from flash.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderMic140Flash;

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
function RecorderMic140ResolveDeviceSerialForTag(const ATag: TRecorderTag;
  ADeviceSerial: Integer): Integer;
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
  Math, StrUtils, LazFileUtils,
  uRecorderMeraPaths, uRecorderMic140Utils, uRecorderMic140StreamTypes,
  uRecorderMic140LegacyConstants, uRecorderMic140Thermocouple,
  uRecorderMic140StreamHelpers, uRecorderMic140LegacyProtocol,
  uRecorderMic140MebiusConstants;

const
  CMic140RangeCalibrDirNames: array[0..CMic140RangeCount - 1] of string =
    ('06_100mV', '07_50mV', '8_25mV');
  CMic140HardwareCalibrSubDir = 'hardware' + PathDelim + 'MIC140' + PathDelim;
  CMic140TInCalibrSubDirName = 'TIn';

var
  g_Mic140TInCalibrFailedKeys: TStringList;
  g_Mic140TInCalibrMissLogged: TStringList;

function RecorderMic140QueryHardwareCalibrSerial(const AHost: string; APort: Word;
  out ACalibrSerial: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ACalibrSerial := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ACalibrSerial := RecorderMic140HardwareCalibrSerialFromFirmware(lFirmware);
      Result := ACalibrSerial > 0;
    end;
  finally
    lClient.Free;
  end;
end;

function Mic140TInCalibrFileNumber(ATInListIndex: Integer): Integer;
begin
  { CChannelTInMIC140::GetTransFileName uses GetChanN() -> TIn\01..03.csv.
    TInNum/TInGetChanN tables map ME048 slots only, not calibration file names. }
  if (ATInListIndex >= 0) and (ATInListIndex < MIC140TemperatureChannelCount) then
    Result := ATInListIndex + 1
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
  lTInFileNumber := Mic140TInCalibrFileNumber(ATInListIndex);
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
  lTInFileNumber := Mic140TInCalibrFileNumber(ATInListIndex);
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

function RecorderMic140ResolveDeviceSerialForTag(const ATag: TRecorderTag;
  ADeviceSerial: Integer): Integer;
var
  lHost: string;
  lPort: Word;
  lSerial: Integer;
  lHostOctet: Integer;
  lTagSerial: Integer;
begin
  if ADeviceSerial > 0 then
    Exit(ADeviceSerial);
  if (ATag <> nil) and (ATag.Mic140DeviceSerial > 0) then
  begin
    lTagSerial := ATag.Mic140DeviceSerial;
    if TryParseRecorderMic140SourceId(ATag.SourceId, lHost, lPort) and
       RecorderMic140HostLastOctet(lHost, lHostOctet) and
       (lTagSerial = lHostOctet) then
    begin
      { Старые конфиги сохраняли DevSerNo (= последний октет IP), не CCSerNo. }
    end
    else
      Exit(lTagSerial);
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
begin
  Result := False;
  if (ARegistry = nil) or (ATag = nil) then
    Exit;
  if Pos(CMic140SourcePrefix, ATag.SourceId) <> 1 then
    Exit;
  if not ParseMic140ChannelNumber(ATag.Address, lChannelNumber) then
    Exit;

  lSerial := RecorderMic140ResolveDeviceSerialForTag(ATag, ADeviceSerial);
  if lSerial <= 0 then
    Exit;

  lRangeIndex := ATag.MeasRangeIndex;
  if lRangeIndex >= CMic140RangeCount then
    lRangeIndex := CMic140Range100mV;

  if not RecorderMic140EnsureHardwareCalibrationInRegistry(ARegistry, lSerial,
    lRangeIndex, lChannelNumber, lName) then
    Exit;
  ATag.Mic140DeviceSerial := lSerial;
  ATag.HardwareCalibrationName := lName;
  if AEnableOnTag then
    ATag.HardwareCalibrationEnabled := True;
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
begin
  if (ARegistry = nil) or (Trim(ASourceId) = '') then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if not SameText(lTag.SourceId, ASourceId) or
      (Pos('diagnostics.', LowerCase(lTag.Address)) = 1) or
      (not ParseMic140ChannelNumber(lTag.Address, lChannelNumber)) then
      Continue;
    lRangeIndex := lTag.MeasRangeIndex;
    if lRangeIndex >= CMic140RangeCount then
      lRangeIndex := CMic140Range100mV;
    if not RecorderMic140EnsureHardwareCalibrationInRegistry(ARegistry,
      ADeviceSerial, lRangeIndex, lChannelNumber, lCalName) then
      Continue;
    if lTag.HardwareCalibrationEnabled then
    begin
      if Trim(lTag.HardwareCalibrationName) = '' then
        lTag.HardwareCalibrationName := lCalName;
      if lTag.Mic140DeviceSerial <= 0 then
        lTag.Mic140DeviceSerial := ADeviceSerial;
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
    begin
      lTag.HardwareCalibrationName := lCalName;
      if lTag.Mic140DeviceSerial <= 0 then
        lTag.Mic140DeviceSerial := ADeviceSerial;
    end;
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
  lCalibration: TRecorderCalibration;
  lCandidateAinCounts: array[0..1] of Integer;
  lChanIndex: Integer;
  lChannelNumber: Integer;
  lClient: TRecorderMic140LegacyClient;
  lCsvPath: string;
  lFirmware: TRecorderMic140LegacyFirmware;
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
    if (lTempIndex < 1) or (lTempIndex > MIC140TemperatureChannelCount) then
    begin
      AErrorMessage := 'Invalid MIC-140 temperature channel index';
      Exit;
    end;
    lTinFileNumber := lTempIndex;
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

  lRangeIndex := ATag.MeasRangeIndex;
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
  lClient := TRecorderMic140LegacyClient.Create(lHost, lPort, 10000);
  try
    lClient.Connect;
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
    lClient.ClearBufferedPackets;

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
        lChanIndex := lMaxAinChannels + (lTempIndex - 1);
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

      ATag.Mic140DeviceSerial := lSerial;
      if not lIsTemperature then
        ATag.MeasRangeIndex := LongWord(lRangeIndex);
      ATag.HardwareCalibrationName := lName;
      ATag.HardwareCalibrationEnabled := True;
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
    lClient.Free;
  end;
end;

initialization
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
