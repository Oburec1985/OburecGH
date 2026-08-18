unit uRecorderMic185Calibration;

{
  MIC-183/185 hardware calibration reader.

  Source of protocol information:
    - windev-v3.9\Mebius\Include\IoControlIds.h:
      IOCTL_CMD_GET_CALIBR_KOEF, IOCTL_CMD_RELOAD_CALIBR.
    - windev-v3.9\examples\mebius.daq\mebius_daq_devices\ms\mic185\mic185.cpp:
      CMIC185::LoadCalibrCoefficients reads MIC185_CHANNEL_KX_FULL per channel.
    - windev-v3.9\Mebius\MebiusDAQDevices\mic183\mic183base\ComputePhysical.h:
      MIC183_CHANNEL_KX is k,b and the linear evaluator is k * (x - b).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags;

function RecorderMic185DownloadHardwareCalibrationFromDevice(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AErrorMessage: string): Boolean;

function RecorderMic185DownloadHardwareCalibrationFromDeviceEx(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AK, AB: Double; out ACalibrationName, AErrorMessage: string): Boolean;

function RecorderMic185LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  AEnableOnTag: Boolean = True): Boolean;

function RecorderMic185ApplyCurrentCalibration(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ANominalPowerMa: Double): Double;

function RecorderMic185TryExtractHardwareKx(ACalibration: TRecorderCalibration;
  out AK, AB: Double): Boolean;

function RecorderMic185FormatHardwareKx(AK, AB: Double): string;

function RecorderMic185HardwareCalibrationDisplayText(
  ACalibration: TRecorderCalibration): string;

implementation

uses
  Math, LazFileUtils,
  uMic185Constants, uMic185MebiusTcpProtocol, uMic185MebiusTypes,
  uMic185Device, uRecorderMeraPaths, uRecorderMic185DataSource,
  uRecorderMic185Runtime;

const
  { In original MIC183/185: four mV ranges plus one current/Ohm evaluator. }
  CMic185HardwareRangeCount = 4;
  CMic185HardwareEvalCount = 5;
  { MIC185_CHANNEL_KX_FULL = 5*(k,b) + TC[4] + AdtTc[8], all Single. }
  CMic185ChannelKxSize = SizeOf(Single) * 2;
  CMic185ChannelKxFullSize = SizeOf(Single) * (CMic185HardwareEvalCount * 2 + 4 + 8);
  CMic185HardwareCalibrSubDir = 'hardware' + PathDelim + 'MIC-185' + PathDelim;

function Mic185NormalizeHardwareRangeIndex(ARangeIndex: Integer): Integer;
begin
  Result := ARangeIndex;
  if Result < 0 then
    Result := CMic185Range500mV
  else if Result >= CMic185HardwareRangeCount then
    Result := CMic185HardwareRangeCount - 1;
end;

function RecorderMic185MakeHardwareCalibrationName(ASerial: LongWord;
  ARangeIndex, AChannelNumber: Integer): string;
begin
  ARangeIndex := Mic185NormalizeHardwareRangeIndex(ARangeIndex);
  Result := Format('MIC185 sn%4.4d range%d ch%2.2d',
    [ASerial, ARangeIndex + 1, AChannelNumber]);
end;

function RecorderMic185HardwareCalibrCsvPath(ASerial: LongWord;
  ARangeIndex, AChannelNumber: Integer): string;
begin
  Result := '';
  if (ASerial = 0) or (AChannelNumber <= 0) then
    Exit;
  ARangeIndex := Mic185NormalizeHardwareRangeIndex(ARangeIndex);
  Result := IncludeTrailingPathDelimiter(RecorderMeraCalibrRootDir) +
    CMic185HardwareCalibrSubDir + Format('sn%4.4d', [ASerial]) +
    PathDelim + Format('range%d', [ARangeIndex + 1]) + PathDelim +
    Format('%2.2d.csv', [AChannelNumber]);
end;

function RecorderMic185CurrentCalibrCsvPath(ASerial: LongWord;
  AChannelNumber: Integer): string;
begin
  Result := '';
  if (ASerial = 0) or (AChannelNumber <= 0) then
    Exit;
  Result := IncludeTrailingPathDelimiter(RecorderMeraCalibrRootDir) +
    CMic185HardwareCalibrSubDir + Format('sn%4.4d', [ASerial]) +
    PathDelim + 'current' + PathDelim + Format('%2.2d.csv', [AChannelNumber]);
end;

function RecorderMic185MakeCurrentCalibrationName(ASerial: LongWord;
  AChannelNumber: Integer): string;
begin
  Result := Format('MIC185 sn%4.4d current ch%2.2d',
    [ASerial, AChannelNumber]);
end;

function Mic185ParseCsvNumber(const AText: string; out AValue: Double): Boolean;
var
  lFS: TFormatSettings;
  lText: string;
begin
  lText := Trim(StringReplace(AText, ',', '.', [rfReplaceAll]));
  lFS := DefaultFormatSettings;
  lFS.DecimalSeparator := '.';
  Result := TryStrToFloat(lText, AValue, lFS);
end;

function Mic185LoadCalibrationFromCsv(const AFileName, AName: string;
  out AK, AB: Double; out ACalibration: TRecorderCalibration): Boolean;
var
  I: Integer;
  lLines: TStringList;
  lParts: TStringList;
  lX: Double;
  lY: Double;
begin
  Result := False;
  AK := 0;
  AB := 0;
  ACalibration := nil;
  if (Trim(AFileName) = '') or (not FileExistsUTF8(AFileName)) then
    Exit;

  ACalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  lLines := TStringList.Create;
  lParts := TStringList.Create;
  try
    ACalibration.Name := AName;
    ACalibration.Description := 'MIC-185 hardware GX loaded from ' + AFileName;
    ACalibration.UnitIn := 'codes';
    ACalibration.UnitOut := 'mV';
    ACalibration.Extrapolation := True;
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ',';
    lLines.LoadFromFile(AFileName);
    for I := 0 to lLines.Count - 1 do
    begin
      if Trim(lLines[I]) = '' then
        Continue;
      lParts.DelimitedText := lLines[I];
      if lParts.Count < 2 then
        Continue;
      if not Mic185ParseCsvNumber(lParts[0], lX) then
        Continue;
      if not Mic185ParseCsvNumber(lParts[1], lY) then
        Continue;
      ACalibration.AddPoint(lX, lY);
    end;
    Result := RecorderMic185TryExtractHardwareKx(ACalibration, AK, AB);
    if not Result then
      FreeAndNil(ACalibration);
  finally
    lParts.Free;
    lLines.Free;
  end;
end;

function Mic185SaveCalibrationToCsv(const AFileName: string;
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

function Mic185TryParseCalibrationName(const AName: string; out ASerial: LongWord;
  out ARangeIndex, AChannelNumber: Integer): Boolean;
var
  lParts: TStringList;
  lSerial: Integer;
begin
  Result := False;
  ASerial := 0;
  ARangeIndex := -1;
  AChannelNumber := 0;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ' ';
    lParts.DelimitedText := Trim(AName);
    if lParts.Count <> 4 then
      Exit;
    if not SameText(lParts[0], 'MIC185') then
      Exit;
    if Pos('sn', LowerCase(lParts[1])) <> 1 then
      Exit;
    if Pos('range', LowerCase(lParts[2])) <> 1 then
      Exit;
    if Pos('ch', LowerCase(lParts[3])) <> 1 then
      Exit;
    if not TryStrToInt(Copy(lParts[1], 3, MaxInt), lSerial) then
      Exit;
    if not TryStrToInt(Copy(lParts[2], 6, MaxInt), ARangeIndex) then
      Exit;
    if not TryStrToInt(Copy(lParts[3], 3, MaxInt), AChannelNumber) then
      Exit;
    if (lSerial <= 0) or (ARangeIndex <= 0) or (AChannelNumber <= 0) then
      Exit;
    ASerial := LongWord(lSerial);
    Dec(ARangeIndex);
    Result := True;
  finally
    lParts.Free;
  end;
end;

function Mic185ResolveSerialFromTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; out ASerial: LongWord): Boolean;
var
  lAcquiring: Boolean;
  lChannelNumber: Integer;
  lErrorText: string;
  lHost: string;
  lKnownVersion: LongWord;
  lPort: Word;
  lRangeIndex: Integer;
  lVersionText: string;
begin
  Result := False;
  ASerial := 0;
  if (ATag <> nil) and Mic185TryParseCalibrationName(
    ATag.HardwareCalibrationName, ASerial, lRangeIndex, lChannelNumber) then
    Exit(True);
  if (ATag = nil) or (not TryParseRecorderMic185SourceId(ATag.SourceId, lHost, lPort)) then
    Exit;
  if RecorderMic185GetKnownIdentity(ARegistry, ATag.SourceId, ASerial,
    lKnownVersion) and (ASerial > 0) then
    Exit(True);
  if RecorderMic185TryGetLiveDeviceInfo(lHost, lPort, ASerial, lVersionText,
    lAcquiring) and (ASerial > 0) then
    Exit(True);
  Result := RecorderMic185ReadDeviceInfo(lHost, lPort, ASerial, lVersionText,
    lErrorText, 700) and (ASerial > 0);
end;

function RecorderMic185FormatHardwareKx(AK, AB: Double): string;
begin
  Result := Format('k=%s; b=%s',
    [FloatToStrF(AK, ffGeneral, 9, 6), FloatToStrF(AB, ffGeneral, 9, 6)]);
end;

function RecorderMic185TryExtractHardwareKx(ACalibration: TRecorderCalibration;
  out AK, AB: Double): Boolean;
var
  lPoint0: TRecorderCalibrationPoint;
  lPoint1: TRecorderCalibrationPoint;
begin
  Result := False;
  AK := 0;
  AB := 0;
  if (ACalibration = nil) or (ACalibration.Kind <> rckPiecewiseLinear) or
    (ACalibration.PointCount < 2) then
    Exit;

  lPoint0 := ACalibration.PointAt(0);
  lPoint1 := ACalibration.PointAt(1);
  if SameValue(lPoint0.X, lPoint1.X) then
    Exit;

  AK := (lPoint1.Y - lPoint0.Y) / (lPoint1.X - lPoint0.X);
  if SameValue(AK, 0.0) then
    Exit;

  { The stored two-point curve is y = k * (code - b). }
  AB := lPoint0.X - (lPoint0.Y / AK);
  Result := True;
end;

function RecorderMic185HardwareCalibrationDisplayText(
  ACalibration: TRecorderCalibration): string;
var
  lB: Double;
  lK: Double;
begin
  if ACalibration = nil then
    Exit('');
  if RecorderMic185TryExtractHardwareKx(ACalibration, lK, lB) then
    Result := RecorderMic185FormatHardwareKx(lK, lB)
  else
    Result := ACalibration.Name;
end;

function Mic185SingleFromBytes(const AData: TRecorderByteArray;
  AOffset: Integer): Single;
begin
  Result := 0;
  if (AOffset < 0) or (Length(AData) < AOffset + SizeOf(Result)) then
    Exit;
  Move(AData[AOffset], Result, SizeOf(Result));
end;

function Mic185MakeChannelQuery(AChannelIndex: Integer): TRecorderByteArray;
begin
  SetLength(Result, 1);
  Result[0] := Byte(AChannelIndex);
end;

function Mic185LinearKxToCalibration(const AName, AUnitIn, AUnitOut: string;
  AK, AB: Double): TRecorderCalibration;
var
  lX0: Double;
  lX1: Double;
begin
  Result := TRecorderCalibration.Create(rckPiecewiseLinear);
  Result.Name := AName;
  Result.Description := 'MIC-185 hardware GX: ' +
    RecorderMic185FormatHardwareKx(AK, AB) + '; evaluator k*(code-b)';
  Result.UnitIn := AUnitIn;
  Result.UnitOut := AUnitOut;
  Result.Extrapolation := True;
  lX0 := 0.0;
  lX1 := 1.0;
  Result.AddPoint(lX0, AK * (lX0 - AB));
  Result.AddPoint(lX1, AK * (lX1 - AB));
end;

function Mic185UpsertHardwareCalibration(ARegistry: TRecorderTagRegistry;
  ASource: TRecorderCalibration): TRecorderCalibration; forward;

function Mic185LoadCachedCalibration(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; ASerial: LongWord; ARangeIndex, AChannelIndex: Integer;
  out AK, AB: Double; out ACalibrationName: string): Boolean;
var
  lCalibration: TRecorderCalibration;
  lCsvPath: string;
  lExisting: TRecorderCalibration;
  lName: string;
  lStored: TRecorderCalibration;
begin
  Result := False;
  AK := 0;
  AB := 0;
  ACalibrationName := '';
  if (ARegistry = nil) or (ATag = nil) or (ASerial = 0) or
    (AChannelIndex < 0) then
    Exit;

  lName := RecorderMic185MakeHardwareCalibrationName(ASerial, ARangeIndex,
    AChannelIndex + 1);
  lExisting := ARegistry.FindCalibrationByName(lName);
  if lExisting <> nil then
  begin
    RecorderMic185TryExtractHardwareKx(lExisting, AK, AB);
    ACalibrationName := lName;
    Exit(True);
  end;

  lCsvPath := RecorderMic185HardwareCalibrCsvPath(ASerial, ARangeIndex,
    AChannelIndex + 1);
  if not Mic185LoadCalibrationFromCsv(lCsvPath, lName, AK, AB, lCalibration) then
    Exit;
  try
    lStored := Mic185UpsertHardwareCalibration(ARegistry, lCalibration);
    if lStored = nil then
      Exit;
    ACalibrationName := lStored.Name;
    Result := True;
  finally
    lCalibration.Free;
  end;
end;

function Mic185LoadCachedCurrentCalibration(ARegistry: TRecorderTagRegistry;
  ASerial: LongWord; AChannelIndex: Integer; out AK, AB: Double;
  out ACalibration: TRecorderCalibration): Boolean;
var
  lCsvPath: string;
  lExisting: TRecorderCalibration;
  lLoaded: TRecorderCalibration;
  lName: string;
  lStored: TRecorderCalibration;
begin
  Result := False;
  AK := 0;
  AB := 0;
  ACalibration := nil;
  if (ARegistry = nil) or (ASerial = 0) or (AChannelIndex < 0) then
    Exit;

  lName := RecorderMic185MakeCurrentCalibrationName(ASerial,
    AChannelIndex + 1);
  lExisting := ARegistry.FindCalibrationByName(lName);
  if lExisting <> nil then
  begin
    Result := RecorderMic185TryExtractHardwareKx(lExisting, AK, AB);
    ACalibration := lExisting;
    Exit;
  end;

  lCsvPath := RecorderMic185CurrentCalibrCsvPath(ASerial, AChannelIndex + 1);
  if not Mic185LoadCalibrationFromCsv(lCsvPath, lName, AK, AB, lLoaded) then
    Exit;
  try
    lStored := Mic185UpsertHardwareCalibration(ARegistry, lLoaded);
    Result := lStored <> nil;
    if Result then
      ACalibration := lStored;
  finally
    lLoaded.Free;
  end;
end;

function Mic185UpsertHardwareCalibration(ARegistry: TRecorderTagRegistry;
  ASource: TRecorderCalibration): TRecorderCalibration;
var
  lExisting: TRecorderCalibration;
begin
  Result := nil;
  if (ARegistry = nil) or (ASource = nil) or (Trim(ASource.Name) = '') then
    Exit;

  lExisting := ARegistry.FindCalibrationByName(ASource.Name);
  if lExisting = nil then
  begin
    Result := TRecorderCalibration.Create(rckPiecewiseLinear);
    Result.Assign(ASource);
    ARegistry.Calibrations.Add(Result);
    Exit;
  end;

  lExisting.Assign(ASource);
  Result := lExisting;
end;

function Mic185ReadChannelRangeKx(AClient: TRecorderMebiusTcpClient;
  AChannelIndex, ARangeIndex: Integer; out AK, AB, ACurrentK,
  ACurrentB: Double;
  out AErrorMessage: string): Boolean;
var
  lIn: TRecorderByteArray;
  lOut: TRecorderByteArray;
  lOffset: Integer;
begin
  Result := False;
  AK := 0;
  AB := 0;
  ACurrentK := 0;
  ACurrentB := 0;
  if ARangeIndex < 0 then
    ARangeIndex := 0;
  if ARangeIndex >= CMic185HardwareRangeCount then
    ARangeIndex := CMic185HardwareRangeCount - 1;

  lIn := Mic185MakeChannelQuery(AChannelIndex);
  if not AClient.TryCallCommand(CMic185IoCtlCmdGetCalibrKoef, lIn,
    CMic185ChannelKxFullSize, lOut, AErrorMessage) then
    Exit;

  if Length(lOut) < CMic185ChannelKxFullSize then
  begin
    AErrorMessage := 'MIC-185 calibration reply is shorter than expected';
    Exit;
  end;

  lOffset := ARangeIndex * CMic185ChannelKxSize;
  AK := Mic185SingleFromBytes(lOut, lOffset);
  AB := Mic185SingleFromBytes(lOut, lOffset + SizeOf(Single));
  lOffset := CMic185HardwareRangeCount * CMic185ChannelKxSize;
  ACurrentK := Mic185SingleFromBytes(lOut, lOffset);
  ACurrentB := Mic185SingleFromBytes(lOut, lOffset + SizeOf(Single));
  if (AK <> AK) or (AB <> AB) or (Abs(AK) > 1E20) or (Abs(AB) > 1E20) then
  begin
    AErrorMessage := 'MIC-185 calibration reply contains invalid k,b values';
    Exit;
  end;
  if (ACurrentK <> ACurrentK) or (ACurrentB <> ACurrentB) or
    (Abs(ACurrentK) > 1E20) or (Abs(ACurrentB) > 1E20) then
  begin
    ACurrentK := 0;
    ACurrentB := 0;
  end;

  Result := True;
end;

function Mic185ReadSerialFromConnectedClient(AClient: TRecorderMebiusTcpClient;
  const AHost: string; APort: Word; out ASerial: LongWord): Boolean;
var
  lError: string;
  lInfo: TMic185HardDeviceInfo;
  lOut: TRecorderByteArray;
begin
  Result := False;
  ASerial := 0;
  if AClient = nil then
    Exit;
  if not AClient.TryCallCommand(CMic185IoCtlCmdGetSoftVersion, nil,
    CMic185HardDeviceInfoSize, lOut, lError) then
  begin
    RecorderMic185Log(Format('Hardware GX serial read failed %s:%d: %s',
      [AHost, APort, lError]));
    Exit;
  end;
  if Length(lOut) < CMic185HardDeviceInfoSize then
  begin
    RecorderMic185Log(Format('Hardware GX serial read short reply %s:%d: %d bytes',
      [AHost, APort, Length(lOut)]));
    Exit;
  end;
  FillChar(lInfo, SizeOf(lInfo), 0);
  Move(lOut[0], lInfo, SizeOf(lInfo));
  ASerial := lInfo.SerialNumber;
  Result := ASerial <> 0;
  if Result then
    RecorderMic185RuntimeUpdateInfo(AHost, APort, ASerial, lInfo.SoftVersion);
end;

function RecorderMic185DownloadHardwareCalibrationFromDevice(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AErrorMessage: string): Boolean;
var
  lB: Double;
  lCalibrationName: string;
  lK: Double;
begin
  Result := RecorderMic185DownloadHardwareCalibrationFromDeviceEx(ARegistry,
    ATag, lK, lB, lCalibrationName, AErrorMessage);
end;

function RecorderMic185DownloadHardwareCalibrationFromDeviceEx(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AK, AB: Double; out ACalibrationName, AErrorMessage: string): Boolean;
var
  lCalibration: TRecorderCalibration;
  lChannelIndex: Integer;
  lClient: TRecorderMebiusTcpClient;
  lCurrentB: Double;
  lCurrentCalibration: TRecorderCalibration;
  lCurrentK: Double;
  lHost: string;
  lLiveDevice: TRecorderMic185Device;
  lName: string;
  lPort: Word;
  lSerial: LongWord;
  lSettings: TMic185ChannelProgramSettings;
  lStored: TRecorderCalibration;
  lCsvPath: string;
begin
  Result := False;
  AK := 0;
  AB := 0;
  ACalibrationName := '';
  AErrorMessage := '';
  if (ARegistry = nil) or (ATag = nil) then
  begin
    AErrorMessage := 'MIC-185 tag registry is not available';
    Exit;
  end;
  if not TryParseRecorderMic185SourceId(ATag.SourceId, lHost, lPort) then
  begin
    AErrorMessage := 'Tag is not linked to a MIC-185 source';
    Exit;
  end;
  lChannelIndex := RecorderMic185ChannelAddressToIndex(ATag.Address);
  if (lChannelIndex < 0) or (lChannelIndex >= CMic185ChannelCountMax) then
  begin
    AErrorMessage := 'Tag address is not a MIC-185 measurement channel';
    Exit;
  end;

  RecorderMic185GetSourceChannelMode(ARegistry, ATag.SourceId, ATag.Address,
    ATag.PollFrequencyHz, lSettings);

  if Mic185ResolveSerialFromTag(ARegistry, ATag, lSerial) and
    Mic185LoadCachedCalibration(ARegistry, ATag, lSerial, lSettings.MeasRangeIndex,
      lChannelIndex, AK, AB, ACalibrationName) then
  begin
    if Mic185LoadCachedCurrentCalibration(ARegistry, lSerial, lChannelIndex,
      lCurrentK, lCurrentB, lCurrentCalibration) then
    begin
      ATag.HardwareCalibrationName := ACalibrationName;
      ATag.HardwareCalibrationEnabled := True;
      Exit(True);
    end;
  end;

  { Match the original working-channel path: CMIC185::LoadCalibrCoefficients
    reads the currently loaded evaluator with GET_CALIBR_KOEF. RELOAD_CALIBR
    is intentionally not called here because its flash fileType is a separate
    device setting and changing it from the tag dialog would alter OMAP state. }
  lLiveDevice := RecorderMic185FindLiveDevice(lHost, lPort);
  if lLiveDevice <> nil then
  begin
    if not lLiveDevice.TryReadChannelRangeKx(lChannelIndex,
      lSettings.MeasRangeIndex, AK, AB, lCurrentK, lCurrentB,
      AErrorMessage) then
      Exit;
    if lSerial = 0 then
      lSerial := lLiveDevice.DeviceSerial;
    RecorderMic185Log(Format('Hardware GX read via live MIC-185 session %s:%d ch=%d',
      [lHost, lPort, lChannelIndex + 1]));
  end
  else
  begin
    if RecorderMic185RuntimeIsBusy(lHost, lPort) then
    begin
      AErrorMessage :=
        'MIC183/185 endpoint is busy by active RecorderLnx session';
      Exit;
    end;
    lClient := TRecorderMebiusTcpClient.Create(lHost, lPort, 5000);
    try
      if not lClient.TryConnect(AErrorMessage) then
        Exit;

      if not Mic185ReadChannelRangeKx(lClient, lChannelIndex,
        lSettings.MeasRangeIndex, AK, AB, lCurrentK, lCurrentB,
        AErrorMessage) then
        Exit;
      if lSerial = 0 then
        Mic185ReadSerialFromConnectedClient(lClient, lHost, lPort, lSerial);
    finally
      lClient.Free;
    end;
  end;

  if lSerial = 0 then
    Mic185ResolveSerialFromTag(ARegistry, ATag, lSerial);
  if lSerial > 0 then
    lName := RecorderMic185MakeHardwareCalibrationName(lSerial,
      lSettings.MeasRangeIndex, lChannelIndex + 1)
  else
    lName := Format('MIC185 %s ch%2.2d range%d',
      [ATag.SourceId, lChannelIndex + 1, lSettings.MeasRangeIndex]);
  lCalibration := Mic185LinearKxToCalibration(lName, 'codes', 'mV', AK, AB);
  try
    if lSerial > 0 then
    begin
      lCsvPath := RecorderMic185HardwareCalibrCsvPath(lSerial,
        lSettings.MeasRangeIndex, lChannelIndex + 1);
      Mic185SaveCalibrationToCsv(lCsvPath, lCalibration);
      if not SameValue(lCurrentK, 0.0) then
      begin
        lCurrentCalibration := Mic185LinearKxToCalibration(
          RecorderMic185MakeCurrentCalibrationName(lSerial, lChannelIndex + 1),
          'mA', 'mA', lCurrentK, lCurrentB);
        try
          lCsvPath := RecorderMic185CurrentCalibrCsvPath(lSerial,
            lChannelIndex + 1);
          Mic185SaveCalibrationToCsv(lCsvPath, lCurrentCalibration);
          Mic185UpsertHardwareCalibration(ARegistry, lCurrentCalibration);
        finally
          lCurrentCalibration.Free;
        end;
      end;
    end;
    if lSerial = 0 then
      RecorderMic185Log(Format(
        'Hardware GX cache skipped for %s %s: serial number is unknown',
        [ATag.SourceId, ATag.Address]));
    lStored := Mic185UpsertHardwareCalibration(ARegistry, lCalibration);
    if lStored = nil then
    begin
      AErrorMessage := 'Failed to register MIC-185 hardware calibration';
      Exit;
    end;

    ATag.HardwareCalibrationName := lStored.Name;
    ATag.HardwareCalibrationEnabled := True;
    ACalibrationName := lStored.Name;
    Result := True;
  finally
    lCalibration.Free;
  end;
end;

function RecorderMic185ApplyCurrentCalibration(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ANominalPowerMa: Double): Double;
var
  lB: Double;
  lCalibration: TRecorderCalibration;
  lChannelIndex: Integer;
  lChannelNumber: Integer;
  lK: Double;
  lRangeIndex: Integer;
  lSerial: LongWord;
begin
  Result := ANominalPowerMa;
  if (ARegistry = nil) or (ATag = nil) or SameValue(ANominalPowerMa, 0.0) then
    Exit;
  lChannelIndex := RecorderMic185ChannelAddressToIndex(ATag.Address);
  if lChannelIndex < 0 then
    Exit;
  if not Mic185TryParseCalibrationName(ATag.HardwareCalibrationName, lSerial,
    lRangeIndex, lChannelNumber) then
    if not Mic185ResolveSerialFromTag(ARegistry, ATag, lSerial) then
      Exit;
  if not Mic185LoadCachedCurrentCalibration(ARegistry, lSerial, lChannelIndex,
    lK, lB, lCalibration) then
    Exit;
  Result := lCalibration.Transform(ANominalPowerMa);
  if SameValue(Result, 0.0, 1E-9) or (Result <> Result) then
    Result := ANominalPowerMa;
end;

function RecorderMic185LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  AEnableOnTag: Boolean): Boolean;
var
  lB: Double;
  lCalibrationName: string;
  lChannelIndex: Integer;
  lChannelNumber: Integer;
  lCsvPath: string;
  lK: Double;
  lOldCalibrationName: string;
  lRangeIndex: Integer;
  lSerial: LongWord;
  lSettings: TMic185ChannelProgramSettings;
begin
  Result := False;
  if (ARegistry = nil) or (ATag = nil) or
    (not (Pos('MIC-185:', ATag.SourceId) = 1)) then
    Exit;
  lChannelIndex := RecorderMic185ChannelAddressToIndex(ATag.Address);
  if lChannelIndex < 0 then
  begin
    RecorderMic185Log(Format(
      'Hardware GX cache miss tag="%s" addr="%s" source="%s": invalid MIC185 channel address',
      [ATag.Name, ATag.Address, ATag.SourceId]));
    Exit;
  end;
  RecorderMic185GetSourceChannelMode(ARegistry, ATag.SourceId, ATag.Address,
    ATag.PollFrequencyHz, lSettings);
  lRangeIndex := Mic185NormalizeHardwareRangeIndex(lSettings.MeasRangeIndex);
  lOldCalibrationName := Trim(ATag.HardwareCalibrationName);
  if not Mic185TryParseCalibrationName(ATag.HardwareCalibrationName, lSerial,
    lRangeIndex, lChannelNumber) then
  begin
    if not Mic185ResolveSerialFromTag(ARegistry, ATag, lSerial) then
    begin
      RecorderMic185Log(Format(
        'Hardware GX cache miss tag="%s" addr="%s" source="%s": serial unknown',
      [ATag.Name, ATag.Address, ATag.SourceId]));
      Exit;
    end;
  end;
  lRangeIndex := Mic185NormalizeHardwareRangeIndex(lRangeIndex);
  lChannelIndex := RecorderMic185ChannelAddressToIndex(ATag.Address);
  if not Mic185LoadCachedCalibration(ARegistry, ATag, lSerial, lRangeIndex,
    lChannelIndex, lK, lB, lCalibrationName) then
  begin
    lCsvPath := RecorderMic185HardwareCalibrCsvPath(lSerial, lRangeIndex,
      lChannelIndex + 1);
    RecorderMic185Log(Format(
      'Hardware GX cache miss tag="%s" addr="%s" source="%s" sn=%d range=%d ch=%d file="%s"',
      [ATag.Name, ATag.Address, ATag.SourceId, lSerial, lRangeIndex + 1,
      lChannelIndex + 1, lCsvPath]));
    Exit;
  end;
  ATag.HardwareCalibrationName := lCalibrationName;
  if AEnableOnTag then
    ATag.HardwareCalibrationEnabled := True;
  if (lOldCalibrationName = '') or
    (not SameText(lOldCalibrationName, lCalibrationName)) then
    RecorderMic185Log(Format(
      'Hardware GX cache restore OK tag="%s" addr="%s" source="%s" sn=%d range=%d ch=%d name="%s" enabled=%s',
      [ATag.Name, ATag.Address, ATag.SourceId, lSerial, lRangeIndex + 1,
      lChannelIndex + 1, lCalibrationName,
      BoolToStr(ATag.HardwareCalibrationEnabled, True)]));
  Result := True;
end;

end.
