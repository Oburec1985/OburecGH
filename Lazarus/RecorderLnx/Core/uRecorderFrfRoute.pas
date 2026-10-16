unit uRecorderFrfRoute;

{ Persisted measurement route. CaptureEntry saves without changing selection;
  CaptureCurrent is the legacy advancing command.
  playback reloads every curve from disk and never substitutes live RAM data.
  Calls belong to the explicit acquisition command, outside rendering loops. }

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Math, IniFiles, uRecorderFrfRepository;

type
  TRecorderRouteCurveArray = array of TRecorderFrfCurveData;
  TRecorderFrfRouteEntry = record
    ChannelIndex, PointNumber: Integer;
    TargetNodeId, CurveId: QWord;
    TargetNodeName, PointLabel, StorageFolder: string;
    Captured: Boolean;
  end;

  TRecorderFrfRoute = class
  private
    fEntries: array of TRecorderFrfRouteEntry;
    fDirectory: string;
    fCurrentIndex: Integer;
    function GetCount: Integer;
    function GetEntry(AIndex: Integer): TRecorderFrfRouteEntry;
    function CurveFile(AIndex: Integer): string;
  public
    procedure Add(const AEntry: TRecorderFrfRouteEntry);
    procedure UpdateEntry(AIndex: Integer; const AEntry: TRecorderFrfRouteEntry);
    procedure MoveEntry(AFrom, ATo: Integer);
    procedure SetPointLabel(AIndex: Integer; const ALabel: string);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    procedure Save(const ADirectory: string);
    procedure Load(const ADirectory: string);
    procedure CaptureCurrent(const ACurve: TRecorderFrfCurveData);
    procedure CaptureEntry(AIndex: Integer; const ACurve: TRecorderFrfCurveData);
    function PointDirectory(AIndex: Integer): string;
    procedure ResetProgress;
    function AllComplete: Boolean;
    function LoadSavedCurves(out ACurves: TRecorderRouteCurveArray): Boolean;
    property Count: Integer read GetCount;
    property Entries[AIndex: Integer]: TRecorderFrfRouteEntry read GetEntry; default;
    property CurrentIndex: Integer read fCurrentIndex write fCurrentIndex;
    property Directory: string read fDirectory;
  end;

implementation

const CurveMagic: LongWord = $46524631;
  MaxCurveSamples = 16777216;

type TValues = array of Double;

procedure WriteValues(AStream: TStream; const AValues: array of Double);
var lCount: LongInt;
begin
  lCount := Length(AValues);
  AStream.WriteBuffer(lCount, SizeOf(lCount));
  if lCount > 0 then AStream.WriteBuffer(AValues[0], lCount * SizeOf(Double));
end;

procedure ReadValues(AStream: TStream; out AValues: TValues);
var lCount: LongInt;
begin
  AStream.ReadBuffer(lCount, SizeOf(lCount));
  if (lCount < 0) or (lCount > MaxCurveSamples) or
    (Int64(lCount) * SizeOf(Double) > AStream.Size - AStream.Position) then
    raise EReadError.Create('Invalid FRF route sample count');
  SetLength(AValues, lCount);
  if lCount > 0 then AStream.ReadBuffer(AValues[0], lCount * SizeOf(Double));
end;

procedure WriteCurve(const AFile: string; const ACurve: TRecorderFrfCurveData);
var lStream: TFileStream; lMagic: LongWord;
begin
  lStream := TFileStream.Create(AFile, fmCreate);
  try
    lMagic := CurveMagic;
    lStream.WriteBuffer(lMagic, SizeOf(lMagic));
    WriteValues(lStream, ACurve.FrequencyHz);
    WriteValues(lStream, ACurve.Magnitude);
    WriteValues(lStream, ACurve.PhaseRadians);
    WriteValues(lStream, ACurve.Coherence);
    WriteValues(lStream, ACurve.Amplitude);
  finally lStream.Free end;
end;

procedure ReadCurve(const AFile: string; out ACurve: TRecorderFrfCurveData);
var lStream: TFileStream; lMagic: LongWord;
begin
  lStream := TFileStream.Create(AFile, fmOpenRead or fmShareDenyWrite);
  try
    lStream.ReadBuffer(lMagic, SizeOf(lMagic));
    if lMagic <> CurveMagic then raise EReadError.Create('Invalid FRF route file');
    ReadValues(lStream, ACurve.FrequencyHz);
    ReadValues(lStream, ACurve.Magnitude);
    ReadValues(lStream, ACurve.PhaseRadians);
    ReadValues(lStream, ACurve.Coherence);
    ReadValues(lStream, ACurve.Amplitude);
  finally lStream.Free end;
end;

function TRecorderFrfRoute.GetCount: Integer;
begin Result := Length(fEntries) end;

function TRecorderFrfRoute.GetEntry(AIndex: Integer): TRecorderFrfRouteEntry;
begin
  if (AIndex < 0) or (AIndex >= Count) then raise ERangeError.Create('FRF route index');
  Result := fEntries[AIndex];
end;

function TRecorderFrfRoute.CurveFile(AIndex: Integer): string;
var lLegacy: string;
begin
  Result := IncludeTrailingPathDelimiter(PointDirectory(AIndex)) + 'curve.frf';
  lLegacy := IncludeTrailingPathDelimiter(fDirectory) +
    'curve-' + UIntToStr(fEntries[AIndex].CurveId) + '.frf';
  if not FileExists(Result) and FileExists(lLegacy) then Result := lLegacy;
end;

function TRecorderFrfRoute.PointDirectory(AIndex: Integer): string;
var lName, lOther: string; I: Integer;
begin
  GetEntry(AIndex);
  lName := fEntries[AIndex].StorageFolder;
  if lName = '' then
  begin
    lName := Trim(fEntries[AIndex].PointLabel);
    for I := 1 to Length(lName) do
      if (lName[I] in ['<', '>', ':', '"', '/', '\', '|', '?', '*']) or
        (Ord(lName[I]) < 32) then lName[I] := '_';
    while (lName <> '') and (lName[Length(lName)] in [' ', '.']) do
      System.Delete(lName, Length(lName), 1);
    if lName = '' then lName := IntToStr(fEntries[AIndex].PointNumber);
    for I := 0 to Count - 1 do
      if I <> AIndex then
      begin
        lOther := fEntries[I].StorageFolder;
        if lOther = '' then lOther := Trim(fEntries[I].PointLabel);
        if SameText(lName, lOther) then
        begin
          lName := lName + '-' + UIntToStr(fEntries[AIndex].CurveId);
          Break;
        end;
      end;
  end;
  Result := IncludeTrailingPathDelimiter(fDirectory) + lName;
end;

procedure TRecorderFrfRoute.Add(const AEntry: TRecorderFrfRouteEntry);
var lEntry: TRecorderFrfRouteEntry; lGuid: TGUID; lIndex: Integer; lCollision: Boolean;
begin
  lEntry := AEntry;
  if Trim(lEntry.PointLabel) = '' then lEntry.PointLabel := IntToStr(lEntry.PointNumber);
  repeat
    CreateGUID(lGuid);
    Move(lGuid, lEntry.CurveId, SizeOf(lEntry.CurveId));
    lCollision := lEntry.CurveId = 0;
    for lIndex := 0 to Count - 1 do
      lCollision := lCollision or (fEntries[lIndex].CurveId = lEntry.CurveId);
  until not lCollision;
  lEntry.Captured := False;
  SetLength(fEntries, Count + 1);
  fEntries[High(fEntries)] := lEntry;
end;

procedure TRecorderFrfRoute.SetPointLabel(AIndex: Integer; const ALabel: string);
begin
  GetEntry(AIndex);
  fEntries[AIndex].PointLabel := Trim(ALabel);
  if fEntries[AIndex].PointLabel = '' then
    fEntries[AIndex].PointLabel := IntToStr(fEntries[AIndex].PointNumber);
  if fDirectory <> '' then Save(fDirectory);
end;

procedure TRecorderFrfRoute.UpdateEntry(AIndex: Integer;
  const AEntry: TRecorderFrfRouteEntry);
var lPrevious, lEntry: TRecorderFrfRouteEntry;
begin
  lPrevious := GetEntry(AIndex);
  lEntry := AEntry;
  { Editing an assignment must not detach its already captured realization. }
  lEntry.CurveId := lPrevious.CurveId;
  lEntry.Captured := lPrevious.Captured;
  lEntry.StorageFolder := lPrevious.StorageFolder;
  lEntry.PointLabel := Trim(lEntry.PointLabel);
  if lEntry.PointLabel = '' then lEntry.PointLabel := IntToStr(lEntry.PointNumber);
  fEntries[AIndex] := lEntry;
  if fDirectory <> '' then Save(fDirectory);
end;

procedure TRecorderFrfRoute.MoveEntry(AFrom, ATo: Integer);
var lEntry: TRecorderFrfRouteEntry; lIndex: Integer;
begin
  lEntry := GetEntry(AFrom);
  GetEntry(ATo);
  if AFrom = ATo then Exit;
  if AFrom < ATo then
    for lIndex := AFrom to ATo - 1 do fEntries[lIndex] := fEntries[lIndex + 1]
  else
    for lIndex := AFrom downto ATo + 1 do fEntries[lIndex] := fEntries[lIndex - 1];
  fEntries[ATo] := lEntry;
  if fCurrentIndex = AFrom then fCurrentIndex := ATo
  else if (AFrom < fCurrentIndex) and (fCurrentIndex <= ATo) then Dec(fCurrentIndex)
  else if (ATo <= fCurrentIndex) and (fCurrentIndex < AFrom) then Inc(fCurrentIndex);
  if fDirectory <> '' then Save(fDirectory);
end;

procedure TRecorderFrfRoute.Delete(AIndex: Integer);
var lIndex: Integer;
begin
  GetEntry(AIndex);
  for lIndex := AIndex to Count - 2 do fEntries[lIndex] := fEntries[lIndex + 1];
  SetLength(fEntries, Count - 1);
  if fCurrentIndex > AIndex then Dec(fCurrentIndex);
  if fCurrentIndex > Count then fCurrentIndex := Count;
end;

procedure TRecorderFrfRoute.Clear;
begin SetLength(fEntries, 0); fCurrentIndex := 0; fDirectory := '' end;

procedure TRecorderFrfRoute.Save(const ADirectory: string);
var lIni: TMemIniFile; lIndex: Integer; lSection: string;
begin
  if Trim(ADirectory) = '' then raise Exception.Create('FRF route directory is empty');
  fDirectory := ExpandFileName(ADirectory);
  if not ForceDirectories(fDirectory) then raise Exception.Create('Cannot create FRF route directory');
  lIni := TMemIniFile.Create(IncludeTrailingPathDelimiter(fDirectory) + 'route.ini');
  try
    lIni.Clear;
    lIni.WriteInteger('Route', 'Version', 1);
    lIni.WriteInteger('Route', 'Count', Count);
    lIni.WriteInteger('Route', 'Current', fCurrentIndex);
    for lIndex := 0 to Count - 1 do
    begin
      lSection := 'Point' + IntToStr(lIndex);
      lIni.WriteInteger(lSection, 'Channel', fEntries[lIndex].ChannelIndex);
      lIni.WriteInteger(lSection, 'Point', fEntries[lIndex].PointNumber);
      lIni.WriteString(lSection, 'PointLabel', fEntries[lIndex].PointLabel);
      lIni.WriteString(lSection, 'NodeId', UIntToStr(fEntries[lIndex].TargetNodeId));
      lIni.WriteString(lSection, 'NodeName', fEntries[lIndex].TargetNodeName);
      lIni.WriteString(lSection, 'CurveId', UIntToStr(fEntries[lIndex].CurveId));
      lIni.WriteBool(lSection, 'Captured', fEntries[lIndex].Captured);
      lIni.WriteString(lSection, 'StorageFolder', fEntries[lIndex].StorageFolder);
    end;
    lIni.UpdateFile;
  finally lIni.Free end;
end;

procedure TRecorderFrfRoute.Load(const ADirectory: string);
var lIni: TMemIniFile; lIndex, lCount: Integer; lSection: string;
begin
  fDirectory := ExpandFileName(ADirectory);
  if not FileExists(IncludeTrailingPathDelimiter(fDirectory) + 'route.ini') then
    raise EReadError.Create('FRF route manifest not found');
  lIni := TMemIniFile.Create(IncludeTrailingPathDelimiter(fDirectory) + 'route.ini');
  try
    if lIni.ReadInteger('Route', 'Version', 0) <> 1 then
      raise EReadError.Create('Unsupported FRF route version');
    lCount := lIni.ReadInteger('Route', 'Count', 0);
    if (lCount < 0) or (lCount > 100000) then raise EReadError.Create('Invalid FRF route count');
    SetLength(fEntries, lCount);
    fCurrentIndex := lIni.ReadInteger('Route', 'Current', 0);
    if (fCurrentIndex < 0) or (fCurrentIndex > Count) then fCurrentIndex := 0;
    for lIndex := 0 to Count - 1 do
    begin
      lSection := 'Point' + IntToStr(lIndex);
      fEntries[lIndex].ChannelIndex := lIni.ReadInteger(lSection, 'Channel', 0);
      fEntries[lIndex].PointNumber := lIni.ReadInteger(lSection, 'Point', 1);
      fEntries[lIndex].PointLabel := lIni.ReadString(lSection, 'PointLabel',
        IntToStr(fEntries[lIndex].PointNumber));
      if Trim(fEntries[lIndex].PointLabel) = '' then
        fEntries[lIndex].PointLabel := IntToStr(fEntries[lIndex].PointNumber);
      fEntries[lIndex].TargetNodeId := StrToQWord(lIni.ReadString(lSection, 'NodeId', '0'));
      fEntries[lIndex].TargetNodeName := lIni.ReadString(lSection, 'NodeName', '');
      fEntries[lIndex].CurveId := StrToQWord(lIni.ReadString(lSection, 'CurveId', '0'));
      fEntries[lIndex].Captured := lIni.ReadBool(lSection, 'Captured', False);
      fEntries[lIndex].StorageFolder := lIni.ReadString(lSection, 'StorageFolder', '');
    end;
  finally lIni.Free end;
end;

procedure TRecorderFrfRoute.CaptureCurrent(const ACurve: TRecorderFrfCurveData);
begin
  CaptureEntry(fCurrentIndex, ACurve);
  Inc(fCurrentIndex);
  Save(fDirectory);
end;

procedure TRecorderFrfRoute.CaptureEntry(AIndex: Integer;
  const ACurve: TRecorderFrfCurveData);
var lIndex: Integer;
begin
  GetEntry(AIndex);
  if fDirectory = '' then raise Exception.Create('Save FRF route before capture');
  if (Length(ACurve.FrequencyHz) = 0) or
    (Length(ACurve.Magnitude) <> Length(ACurve.FrequencyHz)) or
    (Length(ACurve.PhaseRadians) <> Length(ACurve.FrequencyHz)) or
    (Length(ACurve.Coherence) <> Length(ACurve.FrequencyHz)) then
    raise Exception.Create('Incomplete FRF realization');
  for lIndex := 0 to High(ACurve.FrequencyHz) do
    if IsNan(ACurve.FrequencyHz[lIndex]) or IsInfinite(ACurve.FrequencyHz[lIndex]) or
      IsNan(ACurve.Magnitude[lIndex]) or IsInfinite(ACurve.Magnitude[lIndex]) or
      IsNan(ACurve.PhaseRadians[lIndex]) or IsInfinite(ACurve.PhaseRadians[lIndex]) or
      IsNan(ACurve.Coherence[lIndex]) or IsInfinite(ACurve.Coherence[lIndex]) or
      (ACurve.Magnitude[lIndex] < 0) or (ACurve.Coherence[lIndex] < 0) or
      (ACurve.Coherence[lIndex] > 1) or ((lIndex > 0) and
      (ACurve.FrequencyHz[lIndex] <= ACurve.FrequencyHz[lIndex - 1])) then
      raise Exception.Create('Invalid FRF realization');
  if fEntries[AIndex].StorageFolder = '' then
    fEntries[AIndex].StorageFolder := ExtractFileName(PointDirectory(AIndex));
  ForceDirectories(PointDirectory(AIndex));
  WriteCurve(IncludeTrailingPathDelimiter(PointDirectory(AIndex)) + 'curve.frf', ACurve);
  fEntries[AIndex].Captured := True;
  Save(fDirectory);
end;

procedure TRecorderFrfRoute.ResetProgress;
begin
  fCurrentIndex := 0;
  while (fCurrentIndex < Count) and fEntries[fCurrentIndex].Captured and
    FileExists(CurveFile(fCurrentIndex)) do Inc(fCurrentIndex);
end;

function TRecorderFrfRoute.AllComplete: Boolean;
var lIndex: Integer;
begin
  Result := Count > 0;
  for lIndex := 0 to Count - 1 do
    Result := Result and fEntries[lIndex].Captured and FileExists(CurveFile(lIndex));
end;

function TRecorderFrfRoute.LoadSavedCurves(out ACurves: TRecorderRouteCurveArray): Boolean;
var lIndex: Integer;
begin
  ACurves := nil;
  Result := AllComplete;
  if not Result then Exit;
  try
    SetLength(ACurves, Count);
    for lIndex := 0 to Count - 1 do
    begin
      ReadCurve(CurveFile(lIndex), ACurves[lIndex]);
      if (Length(ACurves[lIndex].FrequencyHz) = 0) or
        (Length(ACurves[lIndex].Magnitude) <> Length(ACurves[lIndex].FrequencyHz)) or
        (Length(ACurves[lIndex].PhaseRadians) <> Length(ACurves[lIndex].FrequencyHz)) or
        (Length(ACurves[lIndex].Coherence) <> Length(ACurves[lIndex].FrequencyHz)) then
        raise EReadError.Create('Incomplete saved FRF realization');
      ACurves[lIndex].Id := fEntries[lIndex].CurveId;
    end;
  except
    ACurves := nil;
    Result := False;
  end;
end;

end.
