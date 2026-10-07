unit uRecorderImpactMeraAdapter;

{ Portable legacy-style Mera folder adapter. It writes frf.mera plus separate
  FRF and phase .dat files and can import those files for comparison. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, IniFiles, LCLIntf,
  uRecorderImpactSessionContracts;

type
  TRecorderImpactExportContext = class
  private
    fLastExportPath: string;
  public
    property LastExportPath: string read fLastExportPath write fLastExportPath;
  end;

  TRecorderImpactMeraFolderAdapter = class(TInterfacedObject,
    IRecorderImpactMdbAdapter, IRecorderImpactComparisonPort)
  private
    fContext: TRecorderImpactExportContext;
    function ResolveFolder(const APath: string): string;
  protected
    procedure WriteStagedSnapshot(const AFolder: string;
      const ASnapshot: TRecorderImpactSessionSnapshot); virtual;
  public
    constructor Create(AContext: TRecorderImpactExportContext);
    function Save(const AFileName: string;
      const ASnapshot: TRecorderImpactSessionSnapshot;
      const AOptions: TRecorderImpactSessionSaveOptions;
      out AError: string): Boolean;
    function Load(const AFileName: string;
      out ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean;
    function ImportComparison(const AFileName: string;
      out ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean;
  end;

  TRecorderImpactWinPosLauncher = class(TInterfacedObject,
    IRecorderImpactExternalToolPort)
  private
    fContext: TRecorderImpactExportContext;
  public
    constructor Create(AContext: TRecorderImpactExportContext);
    function LaunchWinPos(const ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean;
  end;

implementation

uses
  uRecorderImpactSessionValidation;

const
  MERA_MAX_MANIFEST_BYTES = 1024 * 1024;
  MERA_MAX_CHILD_BYTES = 16 * 1024 * 1024;
  MERA_MAX_TOTAL_BYTES = 128 * 1024 * 1024;
  MERA_FREQUENCY_TOLERANCE = 1E-9;

procedure RemoveTree(const AFolder: string);
var
  Entry: TSearchRec;
  Name: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(AFolder) + '*', faAnyFile,
    Entry) = 0 then
  try
    repeat
      if (Entry.Name = '.') or (Entry.Name = '..') then
        Continue;
      Name := IncludeTrailingPathDelimiter(AFolder) + Entry.Name;
      if (Entry.Attr and faDirectory) <> 0 then
        RemoveTree(Name)
      else
        DeleteFile(Name);
    until FindNext(Entry) <> 0;
  finally
    FindClose(Entry);
  end;
  RemoveDir(AFolder);
end;

function SafeChildName(const AFolder, AChild: string;
  out AResolved: string): Boolean;
var
  Root: string;
  Candidate: string;
begin
  Result := False;
  AResolved := '';
  if (AChild = '') or (ExtractFileDrive(AChild) <> '') or
    (AChild[1] in ['/', '\']) or (Pos('..', AChild) > 0) then
    Exit;
  Root := IncludeTrailingPathDelimiter(ExpandFileName(AFolder));
  Candidate := ExpandFileName(Root + AChild);
  if CompareText(Copy(Candidate, 1, Length(Root)), Root) <> 0 then
    Exit;
  AResolved := Candidate;
  Result := True;
end;

function CheckedFileSize(const AFileName: string; AMaximum: Int64;
  out ASize: Int64; out AError: string): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;
  ASize := 0;
  if not FileExists(AFileName) then
  begin
    AError := 'Missing Mera file: ' + ExtractFileName(AFileName);
    Exit;
  end;
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    ASize := Stream.Size;
  finally
    Stream.Free;
  end;
  if (ASize < 0) or (ASize > AMaximum) then
  begin
    AError := 'Mera file exceeds size limit: ' + ExtractFileName(AFileName);
    Exit;
  end;
  Result := True;
end;

constructor TRecorderImpactMeraFolderAdapter.Create(
  AContext: TRecorderImpactExportContext);
begin
  inherited Create;
  fContext := AContext;
end;

function TRecorderImpactMeraFolderAdapter.ResolveFolder(
  const APath: string): string;
begin
  if DirectoryExists(APath) then
    Result := APath
  else if ExtractFileExt(APath) <> '' then
    Result := ChangeFileExt(APath, '')
  else
    Result := APath;
end;

procedure TRecorderImpactMeraFolderAdapter.WriteStagedSnapshot(
  const AFolder: string; const ASnapshot: TRecorderImpactSessionSnapshot);
var
  Manifest: TMemIniFile;
  Data: TStringList;
  Section: string;
  I, J: Integer;
begin
  if not ForceDirectories(AFolder) then
    raise EFCreateError.Create('Cannot create Mera staging folder');
  Manifest := TMemIniFile.Create(IncludeTrailingPathDelimiter(AFolder) +
    'frf.mera');
  try
    Manifest.WriteInteger('Session', 'Version',
      RECORDER_IMPACT_SESSION_VERSION);
    Manifest.WriteString('Session', 'Id', ASnapshot.SessionId);
    Manifest.WriteFloat('Session', 'SampleRateHz', ASnapshot.SampleRateHz);
    Manifest.WriteInteger('Session', 'CurveCount', Length(ASnapshot.Curves));
    for I := 0 to High(ASnapshot.Curves) do
    begin
      Section := 'Curve.' + IntToStr(I);
      Manifest.WriteString(Section, 'CurveId',
        UIntToStr(ASnapshot.Curves[I].CurveId));
      Manifest.WriteString(Section, 'TagId',
        UIntToStr(ASnapshot.Curves[I].TagId));
      Manifest.WriteString(Section, 'Name', ASnapshot.Curves[I].Name);
      Manifest.WriteString(Section, 'ExcitationUnit',
        ASnapshot.Curves[I].ExcitationUnitName);
      Manifest.WriteString(Section, 'ResponseUnit',
        ASnapshot.Curves[I].ResponseUnitName);
      Manifest.WriteString(Section, 'FrfFile', Format('frf_%d.dat',
        [ASnapshot.Curves[I].CurveId]));
      Manifest.WriteString(Section, 'PhaseFile', Format('phase_%d.dat',
        [ASnapshot.Curves[I].CurveId]));
      Data := TStringList.Create;
      try
        Data.Add('# frequency_hz magnitude coherence');
        for J := 0 to High(ASnapshot.Curves[I].FrequencyHz) do
          Data.Add(Format('%.17g %.17g %.17g', [
            ASnapshot.Curves[I].FrequencyHz[J],
            ASnapshot.Curves[I].Magnitude[J],
            ASnapshot.Curves[I].Coherence[J]], DefaultFormatSettings));
        Data.SaveToFile(IncludeTrailingPathDelimiter(AFolder) +
          Format('frf_%d.dat', [ASnapshot.Curves[I].CurveId]),
          TEncoding.UTF8);
        Data.Clear;
        Data.Add('# frequency_hz phase_radians');
        for J := 0 to High(ASnapshot.Curves[I].FrequencyHz) do
          Data.Add(Format('%.17g %.17g', [
            ASnapshot.Curves[I].FrequencyHz[J],
            ASnapshot.Curves[I].PhaseRadians[J]], DefaultFormatSettings));
        Data.SaveToFile(IncludeTrailingPathDelimiter(AFolder) +
          Format('phase_%d.dat', [ASnapshot.Curves[I].CurveId]),
          TEncoding.UTF8);
      finally
        Data.Free;
      end;
    end;
    Manifest.UpdateFile;
  finally
    Manifest.Free;
  end;
end;

function TRecorderImpactMeraFolderAdapter.Save(const AFileName: string;
  const ASnapshot: TRecorderImpactSessionSnapshot;
  const AOptions: TRecorderImpactSessionSaveOptions;
  out AError: string): Boolean;
var
  Folder: string;
  StageFolder: string;
  BackupFolder: string;
  HadExisting: Boolean;
begin
  Result := False;
  AError := '';
  if not ValidateImpactSession(ASnapshot, AError) then
    Exit;
  Folder := ExcludeTrailingPathDelimiter(ExpandFileName(
    ResolveFolder(AFileName)));
  StageFolder := Folder + '.tmp-' + IntToHex(GetTickCount64, 16);
  BackupFolder := Folder + '.bak-' + IntToHex(GetTickCount64, 16);
  try
    WriteStagedSnapshot(StageFolder, ASnapshot);
    HadExisting := DirectoryExists(Folder);
    if HadExisting and not RenameFile(Folder, BackupFolder) then
      raise EFCreateError.Create('Cannot stage existing Mera folder');
    try
      if not RenameFile(StageFolder, Folder) then
        raise EFCreateError.Create('Cannot commit Mera staging folder');
    except
      if HadExisting and DirectoryExists(BackupFolder) then
        RenameFile(BackupFolder, Folder);
      raise;
    end;
    if DirectoryExists(BackupFolder) then
      RemoveTree(BackupFolder);
    if fContext <> nil then
      fContext.LastExportPath := IncludeTrailingPathDelimiter(Folder) +
        'frf.mera';
    Result := True;
  except
    on E: Exception do
      AError := E.Message;
  end;
  if DirectoryExists(StageFolder) then
    RemoveTree(StageFolder);
end;

function TRecorderImpactMeraFolderAdapter.Load(const AFileName: string;
  out ASnapshot: TRecorderImpactSessionSnapshot;
  out AError: string): Boolean;
begin
  { Comparison import is intentionally implemented by the same adapter. }
  Result := ImportComparison(AFileName, ASnapshot, AError);
end;

function TRecorderImpactMeraFolderAdapter.ImportComparison(
  const AFileName: string; out ASnapshot: TRecorderImpactSessionSnapshot;
  out AError: string): Boolean;
var
  Folder, ManifestName, Section, Line: string;
  Manifest: TMemIniFile;
  FrfData, PhaseData, Parts: TStringList;
  I, J, Count: Integer;
  FrfNames: array of string;
  PhaseNames: array of string;
  FileSize: Int64;
  TotalSize: Int64;
  PhaseFrequency: Double;
begin
  Result := False;
  AError := '';
  ASnapshot := Default(TRecorderImpactSessionSnapshot);
  Folder := ResolveFolder(AFileName);
  if ExtractFileName(AFileName) = 'frf.mera' then
    Folder := ExtractFileDir(AFileName);
  Folder := ExpandFileName(Folder);
  ManifestName := IncludeTrailingPathDelimiter(Folder) + 'frf.mera';
  if not CheckedFileSize(ManifestName, MERA_MAX_MANIFEST_BYTES,
    FileSize, AError) then
    Exit;
  TotalSize := FileSize;
  Manifest := TMemIniFile.Create(ManifestName);
  FrfData := TStringList.Create;
  PhaseData := TStringList.Create;
  Parts := TStringList.Create;
  try
    ASnapshot.FormatVersion := Manifest.ReadInteger('Session', 'Version', 0);
    ASnapshot.SessionId := Manifest.ReadString('Session', 'Id', '');
    ASnapshot.SampleRateHz := Manifest.ReadFloat('Session', 'SampleRateHz', 0);
    Count := Manifest.ReadInteger('Session', 'CurveCount', -1);
    if not ValidImpactCount(Count, RECORDER_IMPACT_MAX_CURVES,
      'Curve count', AError) then
      Exit;
    SetLength(FrfNames, Count);
    SetLength(PhaseNames, Count);
    for I := 0 to Count - 1 do
    begin
      Section := 'Curve.' + IntToStr(I);
      if not SafeChildName(Folder,
        Manifest.ReadString(Section, 'FrfFile', ''), FrfNames[I]) or
        not SafeChildName(Folder,
        Manifest.ReadString(Section, 'PhaseFile', ''), PhaseNames[I]) then
      begin
        AError := 'Unsafe Mera child path';
        Exit;
      end;
      if not CheckedFileSize(FrfNames[I], MERA_MAX_CHILD_BYTES,
        FileSize, AError) then
        Exit;
      Inc(TotalSize, FileSize);
      if not CheckedFileSize(PhaseNames[I], MERA_MAX_CHILD_BYTES,
        FileSize, AError) then
        Exit;
      Inc(TotalSize, FileSize);
      if TotalSize > MERA_MAX_TOTAL_BYTES then
      begin
        AError := 'Mera session exceeds total size limit';
        Exit;
      end;
    end;
    SetLength(ASnapshot.Curves, Count);
    Parts.Delimiter := ' ';
    Parts.StrictDelimiter := True;
    for I := 0 to Count - 1 do
    begin
      Section := 'Curve.' + IntToStr(I);
      ASnapshot.Curves[I].CurveId := StrToQWordDef(
        Manifest.ReadString(Section, 'CurveId', '0'), 0);
      ASnapshot.Curves[I].TagId := StrToQWordDef(
        Manifest.ReadString(Section, 'TagId', '0'), 0);
      ASnapshot.Curves[I].Name := Manifest.ReadString(Section, 'Name', '');
      ASnapshot.Curves[I].ExcitationUnitName := Manifest.ReadString(Section,
        'ExcitationUnit', '');
      ASnapshot.Curves[I].ResponseUnitName := Manifest.ReadString(Section,
        'ResponseUnit', '');
      FrfData.LoadFromFile(FrfNames[I]);
      PhaseData.LoadFromFile(PhaseNames[I]);
      if (FrfData.Count <> PhaseData.Count) or (FrfData.Count < 1) or
        (FrfData.Count - 1 > RECORDER_IMPACT_MAX_BINS) then
        Exit;
      SetLength(ASnapshot.Curves[I].FrequencyHz, FrfData.Count - 1);
      SetLength(ASnapshot.Curves[I].Magnitude, FrfData.Count - 1);
      SetLength(ASnapshot.Curves[I].Coherence, FrfData.Count - 1);
      SetLength(ASnapshot.Curves[I].PhaseRadians, FrfData.Count - 1);
      for J := 1 to FrfData.Count - 1 do
      begin
        Line := Trim(FrfData[J]);
        Parts.DelimitedText := Line;
        if Parts.Count <> 3 then
          Exit;
        ASnapshot.Curves[I].FrequencyHz[J - 1] :=
          StrToFloat(Parts[0], DefaultFormatSettings);
        ASnapshot.Curves[I].Magnitude[J - 1] :=
          StrToFloat(Parts[1], DefaultFormatSettings);
        ASnapshot.Curves[I].Coherence[J - 1] :=
          StrToFloat(Parts[2], DefaultFormatSettings);
        Parts.DelimitedText := Trim(PhaseData[J]);
        if Parts.Count <> 2 then
          Exit;
        PhaseFrequency := StrToFloat(Parts[0], DefaultFormatSettings);
        if Abs(PhaseFrequency -
          ASnapshot.Curves[I].FrequencyHz[J - 1]) >
          MERA_FREQUENCY_TOLERANCE * Max(1.0,
          Abs(ASnapshot.Curves[I].FrequencyHz[J - 1])) then
        begin
          AError := 'FRF and phase frequency grids do not match';
          Exit;
        end;
        ASnapshot.Curves[I].PhaseRadians[J - 1] :=
          StrToFloat(Parts[1], DefaultFormatSettings);
      end;
    end;
    Result := ValidateImpactSession(ASnapshot, AError);
  except
    on E: Exception do
      AError := E.Message;
  end;
  Parts.Free;
  PhaseData.Free;
  FrfData.Free;
  Manifest.Free;
end;

constructor TRecorderImpactWinPosLauncher.Create(
  AContext: TRecorderImpactExportContext);
begin
  inherited Create;
  fContext := AContext;
end;

function TRecorderImpactWinPosLauncher.LaunchWinPos(
  const ASnapshot: TRecorderImpactSessionSnapshot;
  out AError: string): Boolean;
begin
  AError := '';
  Result := (fContext <> nil) and (fContext.LastExportPath <> '') and
    OpenURL(fContext.LastExportPath);
  if not Result then
    AError := 'Сначала экспортируйте сессию в Mera/MDB-папку.';
end;

end.
