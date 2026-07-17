unit uRecorderMc201Calibration;

{
  Аппаратная ГХ MC-201 как масштабный коэффициент (rckScale), не кусочная
  интерполяция — дешевле на каждый отсчёт.

  Путь Mera Files (как оригинал CChannelModule):
    Calibr\hardware\MTC\MC-201\snXXXX\<rangeDir>\NN.csv
  CSV — две точки (0,0) и (1,K); .tid = ScaleTransformer.1 (как в оригинале).
  В RecorderLnx runtime — rckScale (Y = K * X), без кусочной интерполяции.

  Сервисная калибровка: сдвиг балансировочного ЦАП на известное V (UREF),
  отношение ΔV/Δcode → K [В/код]. См. Docs/devices/mc/mc201-hardware-scale.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Types,
  uRecorderTags, uRecorderMcbusDevice;

const
  CMc201HardwareCalibrSubDir = 'hardware' + PathDelim + 'MTC' + PathDelim +
    'MC-201' + PathDelim;

function RecorderMc201RangeDirName(ARangeIndex: Integer;
  ARev2176: Boolean = False): string;

function RecorderMc201RangeFullScaleVolt(ARangeIndex: Integer;
  ARev2176: Boolean = False): Double;

function RecorderMc201HardwareCalibrCsvPath(ASerial: Integer;
  ARangeIndex, AChannel1Based: Integer; ARev2176: Boolean = False): string;

function RecorderMc201MakeHardwareCalibrationName(ASerial: Integer;
  ARangeIndex, AChannel1Based: Integer): string;

function RecorderMc201SaveScaleToHardwareFiles(ASerial: Integer;
  ARangeIndex, AChannel1Based: Integer; AScaleVoltPerCode: Double;
  ARev2176: Boolean; out ACsvPath, AErrorMessage: string): Boolean;

function RecorderMc201UpsertScaleCalibration(ARegistry: TRecorderTagRegistry;
  const AName: string; AScaleVoltPerCode: Double): TRecorderCalibration;

function RecorderMc201ApplyScaleToSlotTags(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; ASlot1Based, AChannel0Based, ARangeIndex: Integer;
  ASerial: Integer; AScaleVoltPerCode: Double;
  out AErrorMessage: string): Boolean;

{ Единицы тега: без ГХ — «код», с назначенной аппаратной ГХ — «В». }
procedure RecorderMc201SyncTagUnitFromHardwareGx(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag);

function RecorderMc201TryLoadScaleFromCsv(const ACsvPath: string;
  out AScaleVoltPerCode: Double): Boolean;

function RecorderMc201EnsureHardwareCalibrationInRegistry(
  ARegistry: TRecorderTagRegistry; ASerial, ARangeIndex, AChannel1Based: Integer;
  ARev2176: Boolean; out ACalibrationName: string): Boolean;

{ Подгрузить ГХ с диска для тега (SN+диапазон из CFG).
  Если галочку сняли, но имя ГХ оставили — не трогаем.
  Если имя пустое и файлы есть — подгружаем и включаем галочку. }
function RecorderMc201LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  const AConfigText: string): Boolean;

procedure RecorderMc201ApplyHardwareCalibrations(ARegistry: TRecorderTagRegistry;
  const ASourceId, AConfigText: string);

function RecorderMc201CalibrateSlotChannels(ADevice: TRecorderMcbusDevice;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ASlot1Based, ASerial: Integer; const AChannelSelected: array of Boolean;
  const ARangeIndexPerChannel: array of Integer;
  ARev2176: Boolean; out AReport, AErrorMessage: string): Boolean;

implementation

uses
  Math, LazFileUtils, uMc201ProtocolTypes, uRecorderMeraPaths;

const
  { Имена каталогов диапазонов — ranges_MC201[].name из mtc/Mc201.cpp. }
  CMc201RangeDirs: array[0..5] of string = (
    '01_10V', '02_2V', '03_1V', '04_200mV', '05_100mV', '06_20mV');
  CMc201RangeFs: array[0..5] of Double = (8.5, 2.0, 1.0, 0.2, 0.1, 0.02);
  CMc201RangeDirs2176: array[0..5] of string = (
    '01_27_5V', '02_5_5V', '03_2_75V', '04_550mV', '05_275mV', '06_55mV');
  CMc201RangeFs2176: array[0..5] of Double = (27.5, 5.5, 2.75, 0.55, 0.275, 0.055);
  { Сдвиг ЦАП для калибровки: product=20*20, V≈0.061 В @ UREF=2.5. }
  CMc201CalibLoOff = 20;
  CMc201CalibHiOff = 20;
  { Как в оригинале: ScaleTransformer, не кусочная интерполяция. }
  CMc201CalibTidProgId = 'MeraRecorder.ScaleTransformer.1';

function RecorderMc201RangeDirName(ARangeIndex: Integer;
  ARev2176: Boolean): string;
begin
  if (ARangeIndex < 0) or (ARangeIndex > 5) then
    ARangeIndex := 0;
  if ARev2176 then
    Result := CMc201RangeDirs2176[ARangeIndex]
  else
    Result := CMc201RangeDirs[ARangeIndex];
end;

function RecorderMc201RangeFullScaleVolt(ARangeIndex: Integer;
  ARev2176: Boolean): Double;
begin
  if (ARangeIndex < 0) or (ARangeIndex > 5) then
    ARangeIndex := 0;
  if ARev2176 then
    Result := CMc201RangeFs2176[ARangeIndex]
  else
    Result := CMc201RangeFs[ARangeIndex];
end;

function RecorderMc201HardwareCalibrCsvPath(ASerial: Integer;
  ARangeIndex, AChannel1Based: Integer; ARev2176: Boolean): string;
begin
  Result := '';
  if (ASerial <= 0) or (AChannel1Based < 1) or (AChannel1Based > 4) then
    Exit;
  Result := IncludeTrailingPathDelimiter(RecorderMeraCalibrRootDir) +
    CMc201HardwareCalibrSubDir + Format('sn%4.4d', [ASerial]) + PathDelim +
    RecorderMc201RangeDirName(ARangeIndex, ARev2176) + PathDelim +
    Format('%2.2d.csv', [AChannel1Based]);
end;

function RecorderMc201MakeHardwareCalibrationName(ASerial: Integer;
  ARangeIndex, AChannel1Based: Integer): string;
begin
  Result := Format('MC201 sn%4.4d %s ch%2.2d',
    [ASerial, RecorderMc201RangeDirName(ARangeIndex), AChannel1Based]);
end;

procedure Mc201WriteTidFile(const ATidPath: string);
var
  lBytes: TBytes;
  lWide: UnicodeString;
  lStream: TFileStream;
begin
  lWide := UnicodeString(CMc201CalibTidProgId);
  SetLength(lBytes, 2 + Length(lWide) * SizeOf(WideChar));
  lBytes[0] := $FF;
  lBytes[1] := $FE;
  if Length(lWide) > 0 then
    Move(lWide[1], lBytes[2], Length(lWide) * SizeOf(WideChar));
  ForceDirectories(ExtractFileDir(ATidPath));
  lStream := TFileStream.Create(ATidPath, fmCreate);
  try
    if Length(lBytes) > 0 then
      lStream.WriteBuffer(lBytes[0], Length(lBytes));
  finally
    lStream.Free;
  end;
end;

function RecorderMc201SaveScaleToHardwareFiles(ASerial: Integer;
  ARangeIndex, AChannel1Based: Integer; AScaleVoltPerCode: Double;
  ARev2176: Boolean; out ACsvPath, AErrorMessage: string): Boolean;
var
  lFS: TFormatSettings;
  lLines: TStringList;
  lTid: string;
begin
  Result := False;
  ACsvPath := '';
  AErrorMessage := '';
  if Abs(AScaleVoltPerCode) < 1e-18 then
  begin
    AErrorMessage := 'MC-201 scale is zero';
    Exit;
  end;
  ACsvPath := RecorderMc201HardwareCalibrCsvPath(ASerial, ARangeIndex,
    AChannel1Based, ARev2176);
  if ACsvPath = '' then
  begin
    AErrorMessage := 'MC-201 calibr path invalid (serial/channel)';
    Exit;
  end;
  ForceDirectories(ExtractFileDir(ACsvPath));
  lLines := TStringList.Create;
  try
    lFS := DefaultFormatSettings;
    lFS.DecimalSeparator := '.';
    { Файл совместим с 2-точечным CSV; runtime — rckScale (Y = K*X). }
    lLines.Add(Format('%.9g,%.9g', [0.0, 0.0], lFS));
    lLines.Add(Format('%.9g,%.9g', [1.0, AScaleVoltPerCode], lFS));
    lLines.SaveToFile(ACsvPath);
  finally
    lLines.Free;
  end;
  lTid := ChangeFileExt(ACsvPath, '.tid');
  try
    Mc201WriteTidFile(lTid);
  except
    on E: Exception do
    begin
      AErrorMessage := 'TID write failed: ' + E.Message;
      Exit;
    end;
  end;
  Result := FileExistsUTF8(ACsvPath);
  if not Result then
    AErrorMessage := 'CSV was not created: ' + ACsvPath;
end;

function RecorderMc201UpsertScaleCalibration(ARegistry: TRecorderTagRegistry;
  const AName: string; AScaleVoltPerCode: Double): TRecorderCalibration;
var
  lExisting: TRecorderCalibration;
begin
  Result := nil;
  if (ARegistry = nil) or (Trim(AName) = '') then
    Exit;
  lExisting := ARegistry.FindCalibrationByName(AName);
  if lExisting <> nil then
  begin
    lExisting.Kind := rckScale;
    lExisting.Scale := AScaleVoltPerCode;
    lExisting.ClearPoints;
    lExisting.Description := Format('MC-201 hardware scale K=%.9g V/code',
      [AScaleVoltPerCode]);
    lExisting.UnitIn := 'codes';
    lExisting.UnitOut := 'V';
    Exit(lExisting);
  end;
  Result := TRecorderCalibration.Create(rckScale);
  Result.Name := AName;
  Result.Scale := AScaleVoltPerCode;
  Result.Description := Format('MC-201 hardware scale K=%.9g V/code',
    [AScaleVoltPerCode]);
  Result.UnitIn := 'codes';
  Result.UnitOut := 'V';
  Result.Extrapolation := True;
  ARegistry.Calibrations.Add(Result);
end;

function RecorderMc201ApplyScaleToSlotTags(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; ASlot1Based, AChannel0Based, ARangeIndex: Integer;
  ASerial: Integer; AScaleVoltPerCode: Double;
  out AErrorMessage: string): Boolean;
var
  I: Integer;
  lName: string;
  lTag: TRecorderTag;
  lParts: TStringList;
  lSlot, lChan: Integer;
begin
  Result := False;
  AErrorMessage := '';
  if ARegistry = nil then
  begin
    AErrorMessage := 'Tag registry is nil';
    Exit;
  end;
  lName := RecorderMc201MakeHardwareCalibrationName(ASerial, ARangeIndex,
    AChannel0Based + 1);
  RecorderMc201UpsertScaleCalibration(ARegistry, lName, AScaleVoltPerCode);
  lParts := TStringList.Create;
  try
    lParts.Delimiter := '-';
    lParts.StrictDelimiter := True;
    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      if (lTag = nil) or (not SameText(lTag.SourceId, ASourceId)) then
        Continue;
      lParts.DelimitedText := Trim(lTag.Address);
      if lParts.Count < 3 then
        Continue;
      if not TryStrToInt(lParts[lParts.Count - 2], lSlot) then
        Continue;
      if not TryStrToInt(lParts[lParts.Count - 1], lChan) then
        Continue;
      if (lSlot <> ASlot1Based) or (lChan <> AChannel0Based + 1) then
        Continue;
      lTag.HardwareCalibrationName := lName;
      lTag.HardwareCalibrationEnabled := True;
      RecorderMc201SyncTagUnitFromHardwareGx(ARegistry, lTag);
      Result := True;
    end;
  finally
    lParts.Free;
  end;
  if not Result then
  begin
    { ГХ сохранена на диск/в реестр даже без привязанного тега. }
    Result := True;
    AErrorMessage := Format(
      'scale saved (%s), no tag for slot=%d ch=%d yet',
      [lName, ASlot1Based, AChannel0Based + 1]);
  end;
end;

procedure RecorderMc201SyncTagUnitFromHardwareGx(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag);
var
  lCal: TRecorderCalibration;
  lHasGx: Boolean;
begin
  if ATag = nil then
    Exit;
  lHasGx := False;
  if ATag.HardwareCalibrationEnabled then
  begin
    if ARegistry <> nil then
      lCal := ARegistry.FindTagHardwareCalibration(ATag)
    else
      lCal := nil;
    lHasGx := (lCal <> nil) or (Trim(ATag.HardwareCalibrationName) <> '');
  end;
  if lHasGx then
  begin
    if (Trim(ATag.UnitName) = '') or SameText(ATag.UnitName, 'код') or
      SameText(ATag.UnitName, 'code') then
      ATag.UnitName := 'В';
  end
  else if (Trim(ATag.UnitName) = '') or SameText(ATag.UnitName, 'В') or
    SameText(ATag.UnitName, 'V') then
    ATag.UnitName := 'код';
end;

function Mc201ParseCsvNumber(const AText: string; out AValue: Double): Boolean;
var
  lFS: TFormatSettings;
begin
  lFS := DefaultFormatSettings;
  lFS.DecimalSeparator := '.';
  Result := TryStrToFloat(Trim(StringReplace(AText, ',', '.', [rfReplaceAll])),
    AValue, lFS);
end;

function RecorderMc201TryLoadScaleFromCsv(const ACsvPath: string;
  out AScaleVoltPerCode: Double): Boolean;
var
  lLines, lParts: TStringList;
  I: Integer;
  lX, lY, lX0, lY0, lX1, lY1: Double;
  lHave0, lHave1: Boolean;
begin
  Result := False;
  AScaleVoltPerCode := 0;
  if (Trim(ACsvPath) = '') or (not FileExistsUTF8(ACsvPath)) then
    Exit;
  lLines := TStringList.Create;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ',';
    lLines.LoadFromFile(ACsvPath);
    lHave0 := False;
    lHave1 := False;
    lX0 := 0;
    lY0 := 0;
    lX1 := 0;
    lY1 := 0;
    for I := 0 to lLines.Count - 1 do
    begin
      if Trim(lLines[I]) = '' then
        Continue;
      lParts.DelimitedText := lLines[I];
      if lParts.Count >= 2 then
      begin
        if not Mc201ParseCsvNumber(lParts[0], lX) then
          Continue;
        if not Mc201ParseCsvNumber(lParts[1], lY) then
          Continue;
        if (not lHave0) and SameValue(lX, 0.0) and SameValue(lY, 0.0) then
        begin
          lHave0 := True;
          lX0 := lX;
          lY0 := lY;
        end
        else if not lHave1 then
        begin
          lHave1 := True;
          lX1 := lX;
          lY1 := lY;
        end;
      end
      else if lParts.Count = 1 then
      begin
        if Mc201ParseCsvNumber(lParts[0], lY) and (Abs(lY) > 1e-18) then
        begin
          AScaleVoltPerCode := lY;
          Exit(True);
        end;
      end;
    end;
    if lHave0 and lHave1 and (not SameValue(lX1, lX0)) then
    begin
      AScaleVoltPerCode := (lY1 - lY0) / (lX1 - lX0);
      Result := Abs(AScaleVoltPerCode) > 1e-18;
    end
    else if lHave1 and (not SameValue(lX1, 0.0)) then
    begin
      AScaleVoltPerCode := lY1 / lX1;
      Result := Abs(AScaleVoltPerCode) > 1e-18;
    end;
  finally
    lParts.Free;
    lLines.Free;
  end;
end;

function RecorderMc201EnsureHardwareCalibrationInRegistry(
  ARegistry: TRecorderTagRegistry; ASerial, ARangeIndex, AChannel1Based: Integer;
  ARev2176: Boolean; out ACalibrationName: string): Boolean;
var
  lCsv: string;
  lScale: Double;
  lExisting: TRecorderCalibration;
begin
  Result := False;
  ACalibrationName := '';
  if (ARegistry = nil) or (ASerial <= 0) or (AChannel1Based < 1) or
    (AChannel1Based > 4) then
    Exit;
  ARangeIndex := EnsureRange(ARangeIndex, 0, 5);
  ACalibrationName := RecorderMc201MakeHardwareCalibrationName(ASerial,
    ARangeIndex, AChannel1Based);
  lExisting := ARegistry.FindCalibrationByName(ACalibrationName);
  if (lExisting <> nil) and (lExisting.Kind = rckScale) and
    (Abs(lExisting.Scale) > 1e-18) then
    Exit(True);
  lCsv := RecorderMc201HardwareCalibrCsvPath(ASerial, ARangeIndex,
    AChannel1Based, ARev2176);
  if not RecorderMc201TryLoadScaleFromCsv(lCsv, lScale) then
  begin
    ACalibrationName := '';
    Exit;
  end;
  RecorderMc201UpsertScaleCalibration(ARegistry, ACalibrationName, lScale);
  Result := True;
end;

function Mc201ExtractSerialAfterSnToken(const AText: string): Integer;
var
  lPos: Integer;
  lNum: string;
  lLower: string;
begin
  Result := 0;
  { Нельзя UpperCase по всей UTF-8 строке со «Слот» — ломает позиции. }
  lPos := Pos('SN=', AText);
  if lPos = 0 then
    lPos := Pos('sn=', AText);
  if lPos > 0 then
    Inc(lPos, 3)
  else
  begin
    { Имя калибровки: "MC201 sn1465 02_2V ch01". }
    lLower := LowerCase(AText);
    lPos := Pos('sn', lLower);
    if lPos = 0 then
      Exit;
    Inc(lPos, 2);
  end;
  lNum := '';
  while (lPos <= Length(AText)) and (AText[lPos] in ['0'..'9']) do
  begin
    lNum += AText[lPos];
    Inc(lPos);
  end;
  TryStrToInt(lNum, Result);
  if Result < 0 then
    Result := 0;
end;

function Mc201SlotSerialFromConfig(const AConfigText: string;
  ASlot: Integer): Integer;
var
  lLines: TStringList;
  I: Integer;
  lLine, lPrefix: string;
  lAny: Integer;
begin
  Result := 0;
  lAny := 0;
  lPrefix := 'Слот ' + IntToStr(ASlot) + ':';
  lLines := TStringList.Create;
  try
    lLines.Text := AConfigText;
    for I := 0 to lLines.Count - 1 do
    begin
      lLine := Trim(lLines[I]);
      if Pos(lPrefix, lLine) = 1 then
      begin
        Result := Mc201ExtractSerialAfterSnToken(lLine);
        if Result > 0 then
          Exit;
      end;
      { Запасной SN с любой строки модуля MC-201 в том же конфиге. }
      if (lAny <= 0) and (Pos('MC-201', lLine) > 0) then
        lAny := Mc201ExtractSerialAfterSnToken(lLine);
    end;
    if Result <= 0 then
      Result := lAny;
  finally
    lLines.Free;
  end;
end;

function Mc201ChannelRangeFromConfig(const AConfigText: string;
  ASlot, AChannel0Based: Integer; out ARangeIndex: Integer;
  out ARev2176: Boolean): Boolean;
var
  lLines, lFields: TStringList;
  I: Integer;
  lPrefix, lBody: string;
begin
  Result := False;
  ARangeIndex := 1;
  ARev2176 := False;
  lPrefix := 'CFG slot=' + IntToStr(ASlot) + ';';
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  try
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ';';
    lFields.NameValueSeparator := '=';
    lLines.Text := AConfigText;
    for I := 0 to lLines.Count - 1 do
      if Pos(lPrefix, lLines[I]) = 1 then
      begin
        lBody := StringReplace(Copy(lLines[I], Length(lPrefix) + 1, MaxInt),
          ',', ';', [rfReplaceAll]);
        lFields.DelimitedText := lBody;
        ARangeIndex := EnsureRange(StrToIntDef(lFields.Values['c' +
          IntToStr(AChannel0Based)], 1), 0, 5);
        ARev2176 := StrToIntDef(lFields.Values['rev'], 0) > 0;
        Exit(True);
      end;
  finally
    lFields.Free;
    lLines.Free;
  end;
end;

function RecorderMc201LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  const AConfigText: string): Boolean;
var
  lParts: TStringList;
  lSlot, lChan, lSerial, lRange: Integer;
  lRev2176: Boolean;
  lName: string;
begin
  Result := False;
  if (ARegistry = nil) or (ATag = nil) then
    Exit;
  { Явный отказ: галочку сняли, но имя ГХ оставили — не навязываем диск. }
  if (not ATag.HardwareCalibrationEnabled) and
    (Trim(ATag.HardwareCalibrationName) <> '') then
    Exit;
  lParts := TStringList.Create;
  try
    lParts.Delimiter := '-';
    lParts.StrictDelimiter := True;
    lParts.DelimitedText := Trim(ATag.Address);
    if lParts.Count < 2 then
      Exit;
    if not TryStrToInt(lParts[lParts.Count - 2], lSlot) then
      Exit;
    if not TryStrToInt(lParts[lParts.Count - 1], lChan) then
      Exit;
  finally
    lParts.Free;
  end;
  if (lChan < 1) or (lChan > 4) then
    Exit;
  lSerial := Mc201SlotSerialFromConfig(AConfigText, lSlot);
  if lSerial <= 0 then
    lSerial := Mc201ExtractSerialAfterSnToken(ATag.Description);
  if lSerial <= 0 then
    lSerial := Mc201ExtractSerialAfterSnToken(ATag.HardwareCalibrationName);
  if lSerial <= 0 then
    Exit;
  if not Mc201ChannelRangeFromConfig(AConfigText, lSlot, lChan - 1, lRange,
    lRev2176) then
    lRange := 1;
  if not RecorderMc201EnsureHardwareCalibrationInRegistry(ARegistry, lSerial,
    lRange, lChan, lRev2176, lName) then
    Exit;
  ATag.HardwareCalibrationName := lName;
  ATag.HardwareCalibrationEnabled := True;
  RecorderMc201SyncTagUnitFromHardwareGx(ARegistry, ATag);
  Result := True;
end;

procedure RecorderMc201ApplyHardwareCalibrations(ARegistry: TRecorderTagRegistry;
  const ASourceId, AConfigText: string);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (Trim(ASourceId) = '') then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if (lTag = nil) or (not SameText(lTag.SourceId, ASourceId)) then
      Continue;
    RecorderMc201LoadHardwareCalibrationForTag(ARegistry, lTag, AConfigText);
  end;
end;

function RecorderMc201CalibrateSlotChannels(ADevice: TRecorderMcbusDevice;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ASlot1Based, ASerial: Integer; const AChannelSelected: array of Boolean;
  const ARangeIndexPerChannel: array of Integer;
  ARev2176: Boolean; out AReport, AErrorMessage: string): Boolean;
var
  I, lGlobalCh, lRange: Integer;
  lScale: Double;
  lCsv, lErr, lLine: string;
  lOkAny: Boolean;
begin
  Result := False;
  AReport := '';
  AErrorMessage := '';
  if ADevice = nil then
  begin
    AErrorMessage := 'MC-201 device is nil';
    Exit;
  end;
  if (ASerial <= 0) then
  begin
    AErrorMessage := 'MC-201 serial is empty (нужен SN модуля)';
    Exit;
  end;
  if Length(AChannelSelected) < 4 then
  begin
    AErrorMessage := 'channel selection size < 4';
    Exit;
  end;
  lOkAny := False;
  for I := 0 to 3 do
  begin
    if not AChannelSelected[I] then
      Continue;
    lRange := 0;
    if I <= High(ARangeIndexPerChannel) then
      lRange := EnsureRange(ARangeIndexPerChannel[I], 0, 5);
    lGlobalCh := (ASlot1Based - 1) * CMc201MaxModuleChannels + I;
    if not ADevice.CalibrateScaleByBalanceDacShift(lGlobalCh, lScale, lErr) then
    begin
      AReport += Format('ch%d FAIL: %s' + LineEnding, [I + 1, lErr]);
      Continue;
    end;
    if not RecorderMc201SaveScaleToHardwareFiles(ASerial, lRange, I + 1, lScale,
      ARev2176, lCsv, lErr) then
    begin
      AReport += Format('ch%d scale=%.6g save FAIL: %s' + LineEnding,
        [I + 1, lScale, lErr]);
      Continue;
    end;
    lLine := '';
    RecorderMc201ApplyScaleToSlotTags(ARegistry, ASourceId, ASlot1Based, I,
      lRange, ASerial, lScale, lLine);
    AReport += Format('ch%d OK K=%.6g V/code → %s' + LineEnding,
      [I + 1, lScale, lCsv]);
    if lLine <> '' then
      AReport += '  ' + lLine + LineEnding;
    lOkAny := True;
  end;
  Result := lOkAny;
  if not Result then
    AErrorMessage := 'Ни один канал не откалиброван. ' + Trim(AReport);
end;

end.
