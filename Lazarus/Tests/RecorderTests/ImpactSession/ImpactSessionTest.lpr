program ImpactSessionTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, Classes, Math, IniFiles, LConvEncoding, uRecorderImpactSessionContracts,
  uRecorderImpactSessionJson, uRecorderImpactSessionCsv,
  uRecorderImpactSessionValidation, uRecorderImpactMeraAdapter,
  uRecorderImpactMeraPointStore, uMeraFile;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create(AMessage);
end;

procedure CheckOneSecondSave;
var
  Snapshot, Loaded: TRecorderImpactSessionSnapshot;
  Store: IRecorderImpactSessionStore;
  Options: TRecorderImpactSessionSaveOptions;
  I: Integer;
  Started: QWord;
  FileName, ErrorText, Directory, FrfPayload, PhasePayload, PhaseChannel: string;
  Signals: TList;
  Search: TSearchRec;
  Payload: TFileStream;
  BinaryManifest: TMemIniFile;
  Signal: TMeraSignalInfo;
begin
  Snapshot.FormatVersion := RECORDER_IMPACT_SESSION_VERSION;
  Snapshot.SessionId := 'one-second-"quoted"-' + #9 + #10;
  Snapshot.SampleRateHz := 54000;
  SetLength(Snapshot.Impacts, 1);
  Snapshot.Impacts[0].Sequence := 1;
  Snapshot.Impacts[0].Accepted := True;
  Snapshot.Impacts[0].Hidden := True;
  Snapshot.Impacts[0].Excitation.TagId := High(QWord);
  Snapshot.Impacts[0].Excitation.Name := 'Воздействие "ЦАП"' + #10 + 'канал';
  Snapshot.Impacts[0].Excitation.UnitName := 'м/с²';
  SetLength(Snapshot.Impacts[0].Excitation.Samples, 44100);
  SetLength(Snapshot.Impacts[0].Responses, 1);
  Snapshot.Impacts[0].Responses[0].Name := 'Датчик/АЦП:[1]?';
  SetLength(Snapshot.Impacts[0].Responses[0].Samples, 54000);
  for I := 0 to 44099 do
  begin
    Snapshot.Impacts[0].Excitation.Samples[I].TimeSeconds := I / 44100;
    Snapshot.Impacts[0].Excitation.Samples[I].Value := Sin(I * 0.11);
  end;
  for I := 0 to 53999 do
  begin
    Snapshot.Impacts[0].Responses[0].Samples[I].TimeSeconds := I / 54000;
    Snapshot.Impacts[0].Responses[0].Samples[I].Value := Sin(I * 0.09);
  end;
  SetLength(Snapshot.Curves, 1);
  Snapshot.Curves[0].CurveId := 1;
  Snapshot.Curves[0].Name := Snapshot.Impacts[0].Responses[0].Name;
  SetLength(Snapshot.Curves[0].FrequencyHz, 32769);
  SetLength(Snapshot.Curves[0].Magnitude, 32769);
  SetLength(Snapshot.Curves[0].PhaseRadians, 32769);
  SetLength(Snapshot.Curves[0].Coherence, 32769);
  SetLength(Snapshot.Curves[0].ExcitationSpectrum, 32769);
  SetLength(Snapshot.Curves[0].ResponseSpectrum, 32769);
  for I := 0 to 32768 do
  begin
    Snapshot.Curves[0].FrequencyHz[I] := I * 27000 / 32768;
    Snapshot.Curves[0].Magnitude[I] := I * 0.001;
    Snapshot.Curves[0].Coherence[I] := 0.9;
  end;
  Store := TRecorderImpactSessionJsonStore.Create;
  Options.IncludeRawBlocks := True;
  Options.IncludeSpectra := True;
  Options.SaveT0 := True;
  FileName := GetTempDir + 'impact-session-one-second.json';
  Started := GetTickCount64;
  Check(Store.Save(FileName, Snapshot, Options, ErrorText), ErrorText);
  WriteLn('BENCH one-second JSON save ms=', GetTickCount64 - Started);
  Check(Store.Load(FileName, Loaded, ErrorText), ErrorText);
  Check(Loaded.SessionId = Snapshot.SessionId, 'escaped session id roundtrip');
  Check(Length(Loaded.Impacts[0].Responses[0].Samples) = 54000, 'response count');
  Check(Abs(Loaded.Impacts[0].Excitation.Samples[44099].Value -
    Snapshot.Impacts[0].Excitation.Samples[44099].Value) < 1E-14, 'raw precision');
  Check(Length(Loaded.Curves[0].ExcitationSpectrum) = 32769, 'spectra retained');
  DeleteFile(FileName);
  Directory := GetTempDir + 'impact-session-binary-' + IntToHex(GetTickCount64, 16);
  Started := GetTickCount64;
  Check(TRecorderImpactMeraPointStore.Save(Directory, Snapshot, ErrorText), ErrorText);
  WriteLn('BENCH one-second MERA save ms=', GetTickCount64 - Started);
  Check(TRecorderImpactMeraPointStore.Load(Directory, Loaded, ErrorText), ErrorText);
  Check(Loaded.SessionId = Snapshot.SessionId, 'MERA session id');
  Check(Loaded.Impacts[0].Hidden and Loaded.Impacts[0].Accepted,
    'MERA hidden and accepted flags');
  Check((Loaded.Impacts[0].Excitation.TagId = High(QWord)) and
    (Loaded.Impacts[0].Excitation.Name = Snapshot.Impacts[0].Excitation.Name) and
    (Loaded.Impacts[0].Excitation.UnitName = Snapshot.Impacts[0].Excitation.UnitName),
    'MERA full identity and Unicode metadata');
  Check(Length(Loaded.Curves[0].ResponseSpectrum) = 32769, 'MERA spectra');
  for I := 0 to 53999 do
  begin
    Check(Loaded.Impacts[0].Responses[0].Samples[I].TimeSeconds =
      Snapshot.Impacts[0].Responses[0].Samples[I].TimeSeconds, 'MERA exact raw time');
    Check(Loaded.Impacts[0].Responses[0].Samples[I].Value =
      Snapshot.Impacts[0].Responses[0].Samples[I].Value, 'MERA exact raw value');
  end;
  for I := 0 to 32768 do
    Check((Loaded.Curves[0].Magnitude[I] = Snapshot.Curves[0].Magnitude[I]) and
      (Loaded.Curves[0].Coherence[I] = Snapshot.Curves[0].Coherence[I]) and
      (Loaded.Curves[0].PhaseRadians[I] = Snapshot.Curves[0].PhaseRadians[I]) and
      (Loaded.Curves[0].ExcitationSpectrum[I] = Snapshot.Curves[0].ExcitationSpectrum[I]) and
      (Loaded.Curves[0].ResponseSpectrum[I] = Snapshot.Curves[0].ResponseSpectrum[I]),
      'MERA exact FRF phase coherence spectra');
  Signals := TList.Create;
  try
    LoadMeraSignalsFromFile(TRecorderImpactMeraPointStore.SessionFileName(Directory), Signals);
    Check(Signals.Count = 7, 'canonical MERA parser sees raw and spectral channels');
    for I := 0 to Signals.Count - 1 do
    begin
      Signal := TMeraSignalInfo(Signals[I]);
      Check((Pos('Curve_', Signal.Name) = 0) and
        (Pos('Impact_', Signal.Name) = 0) and
        (Pos('excitation', Signal.Name) = 0), 'external channel uses tag identity');
      Check(FileExists(Signal.FileName), 'Unicode channel payload exists');
      Check(Pos('_1_', Signal.Name) > 0, 'external channel number is one-based');
    end;
    Check(TMeraSignalInfo(Signals[0]).Name = 'Воздействие _ЦАП__канал_1_exc',
      'raw excitation short name and unsafe character sanitization');
    Check(TMeraSignalInfo(Signals[2]).Name = 'Датчик_АЦП__1___1_frf',
      'FRF tag name and short line type');
    Check(TMeraSignalInfo(Signals[3]).Name = 'Датчик_АЦП__1___1_ph', 'short phase type');
    Check(TMeraSignalInfo(Signals[4]).Name = 'Датчик_АЦП__1___1_coh', 'short coherence type');
    Check(TMeraSignalInfo(Signals[6]).Name = 'Датчик_АЦП__1___1_spm', 'short spectrum type');
  finally
    ClearMeraSignals(Signals);
    Signals.Free;
  end;
  BinaryManifest := TMemIniFile.Create(TRecorderImpactMeraPointStore.SessionFileName(Directory));
  try
    FrfPayload := CP1251ToUTF8(BinaryManifest.ReadString('Curve_0', 'FrfChannel', '')) + '.dat';
    PhaseChannel := CP1251ToUTF8(BinaryManifest.ReadString('Curve_0', 'PhaseChannel', ''));
    PhasePayload := PhaseChannel + '.x';
  finally
    BinaryManifest.Free;
  end;
  Payload := TFileStream.Create(IncludeTrailingPathDelimiter(Directory) +
    FrfPayload, fmOpenWrite);
  Payload.Size := Payload.Size - 1;
  Payload.Free;
  Check(not TRecorderImpactMeraPointStore.Load(Directory, Loaded, ErrorText),
    'truncated binary payload accepted');
  Check(Length(Loaded.Curves) = 0, 'failed binary read exposes partial data');
  Snapshot.Curves[0].ExcitationSpectrum := nil;
  Snapshot.Curves[0].ResponseSpectrum := nil;
  Check(TRecorderImpactMeraPointStore.Save(Directory, Snapshot, ErrorText), ErrorText);
  Check(TRecorderImpactMeraPointStore.Load(Directory, Loaded, ErrorText), ErrorText);
  Check((Length(Loaded.Curves[0].ExcitationSpectrum) = 0) and
    (Length(Loaded.Curves[0].ResponseSpectrum) = 0), 'optional spectra omitted');
  BinaryManifest := TMemIniFile.Create(TRecorderImpactMeraPointStore.SessionFileName(Directory));
  try
    BinaryManifest.WriteString(UTF8ToCP1251(PhaseChannel), 'XFile', '..\outside.dat');
    BinaryManifest.UpdateFile;
  finally
    BinaryManifest.Free;
  end;
  Check(not TRecorderImpactMeraPointStore.Load(Directory, Loaded, ErrorText),
    'MERA traversal channel accepted');
  Check(Pos('Unsafe MERA payload', ErrorText) > 0, 'MERA traversal rejected before opening');
  Check(TRecorderImpactMeraPointStore.Save(Directory, Snapshot, ErrorText), ErrorText);
  Payload := TFileStream.Create(IncludeTrailingPathDelimiter(Directory) +
    PhasePayload, fmOpenWrite);
  Payload.Size := Payload.Size - 8;
  Payload.Free;
  Check(not TRecorderImpactMeraPointStore.Load(Directory, Loaded, ErrorText),
    'mismatched phase frequency grid accepted');
  if FindFirst(IncludeTrailingPathDelimiter(Directory) + '*', faAnyFile, Search) = 0 then
  try
    repeat
      if (Search.Attr and faDirectory) = 0 then
        DeleteFile(IncludeTrailingPathDelimiter(Directory) + Search.Name);
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
  RemoveDir(Directory);
end;

type
  TFailingMeraAdapter = class(TRecorderImpactMeraFolderAdapter)
  protected
    procedure WriteStagedSnapshot(const AFolder: string;
      const ASnapshot: TRecorderImpactSessionSnapshot); override;
  end;

procedure TFailingMeraAdapter.WriteStagedSnapshot(const AFolder: string;
  const ASnapshot: TRecorderImpactSessionSnapshot);
var
  Marker: TStringList;
begin
  ForceDirectories(AFolder);
  Marker := TStringList.Create;
  try
    Marker.Text := 'partial';
    Marker.SaveToFile(IncludeTrailingPathDelimiter(AFolder) + 'partial.dat');
  finally
    Marker.Free;
  end;
  raise EWriteError.Create('injected staging failure');
end;

var
  Store: IRecorderImpactSessionStore;
  Csv: IRecorderImpactSessionCsvExporter;
  Source, Loaded: TRecorderImpactSessionSnapshot;
  Options: TRecorderImpactSessionSaveOptions;
  FileName, ErrorText: string;
  Lines: TStringList;
  Invalid: TRecorderImpactSessionSnapshot;
  OriginalText: string;
  OversizedFile: TFileStream;
  Mera: IRecorderImpactMdbAdapter;
  FailingMera: IRecorderImpactMdbAdapter;
  MeraFolder: string;
  ManifestName: string;
  PhaseName: string;
  OutsideName: string;
  Manifest: TMemIniFile;
  I: Integer;
begin
  CheckOneSecondSave;
  Source.FormatVersion := 1;
  Source.SessionId := 'golden';
  Source.SampleRateHz := 1024;
  SetLength(Source.Impacts, 1);
  Source.Impacts[0].Sequence := 7;
  Source.Impacts[0].TriggerTimeSeconds := 10;
  SetLength(Source.Impacts[0].Excitation.Samples, 2);
  Source.Impacts[0].Excitation.Samples[0].TimeSeconds := 9.5;
  Source.Impacts[0].Excitation.Samples[1].TimeSeconds := 10.5;
  Source.Impacts[0].Excitation.Samples[1].Value := 4;
  SetLength(Source.Curves, 1);
  Source.Curves[0].CurveId := 12;
  Source.Curves[0].FrequencyHz := [1.0, 2.0];
  Source.Curves[0].Magnitude := [3.0, 4.0];
  Source.Curves[0].PhaseRadians := [0.1, 0.2];
  Source.Curves[0].Coherence := [0.9, 0.8];
  Options.SaveT0 := False;
  Options.IncludeRawBlocks := True;
  Options.IncludeSpectra := True;
  Store := TRecorderImpactSessionJsonStore.Create;
  FileName := GetTempDir + 'impact-session-golden.json';
  Check(Store.Save(FileName, Source, Options, ErrorText), ErrorText);
  Check(Store.Load(FileName, Loaded, ErrorText), ErrorText);
  Check(Loaded.SessionId = 'golden', 'session id');
  Check(Loaded.Impacts[0].Excitation.Samples[0].TimeSeconds = 9.5,
    'relative T0 roundtrip');
  Check(Loaded.Curves[0].Magnitude[1] = 4, 'FRF roundtrip');
  DeleteFile(FileName);

  FileName := GetTempDir + 'impact-session-oversized.json';
  OversizedFile := TFileStream.Create(FileName, fmCreate);
  try
    OversizedFile.Size := Int64(RECORDER_IMPACT_MAX_FILE_BYTES) + 1;
  finally
    OversizedFile.Free;
  end;
  Check(not Store.Load(FileName, Loaded, ErrorText),
    'oversized session file accepted');
  DeleteFile(FileName);
  Csv := TRecorderImpactSessionCsvExporter.Create;
  Source.Curves[0].Name := '=2+2';
  FileName := GetTempDir + 'impact-session-golden.csv';
  Check(Csv.ExportCsv(FileName, Source, Options, ErrorText), ErrorText);
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName, TEncoding.UTF8);
    Check(Pos('raw;hammer;7', Lines.Text) > 0, 'CSV raw hammer row');
    Check(Pos('frf;magnitude', Lines.Text) > 0, 'CSV FRF row');
    Check(Pos('"''=2+2"', Lines.Text) > 0, 'CSV formula neutralization');
  finally
    Lines.Free;
  end;
  DeleteFile(FileName);
  MeraFolder := GetTempDir + 'impact-mera-golden-' +
    IntToHex(GetTickCount64, 8);
  Mera := TRecorderImpactMeraFolderAdapter.Create(nil);
  Check(Mera.Save(MeraFolder, Source, Options, ErrorText), ErrorText);
  Check(FileExists(IncludeTrailingPathDelimiter(MeraFolder) + 'frf.mera'),
    'Mera manifest missing');
  Check(FileExists(IncludeTrailingPathDelimiter(MeraFolder) +
    'frf_12.dat'), 'Mera FRF data missing');
  Check(FileExists(IncludeTrailingPathDelimiter(MeraFolder) +
    'phase_12.dat'), 'Mera phase data missing');
  Check(Mera.Load(MeraFolder, Loaded, ErrorText), ErrorText);
  Check(Loaded.Curves[0].Magnitude[1] = 4, 'Mera FRF roundtrip');
  Lines := TStringList.Create;
  ManifestName := IncludeTrailingPathDelimiter(MeraFolder) + 'frf.mera';
  PhaseName := IncludeTrailingPathDelimiter(MeraFolder) + 'phase_12.dat';
  Lines.LoadFromFile(ManifestName);
  OriginalText := Lines.Text;
  Lines.Text := StringReplace(OriginalText, 'frf_12.dat', '..\outside.dat', []);
  Lines.SaveToFile(ManifestName);
  Check(not Mera.Load(MeraFolder, Loaded, ErrorText),
    'Mera traversal child accepted');
  OutsideName := ExpandFileName(IncludeTrailingPathDelimiter(MeraFolder) +
    '..\outside.dat');
  Lines.Text := StringReplace(OriginalText, 'frf_12.dat', OutsideName, []);
  Lines.SaveToFile(ManifestName);
  Check(not Mera.Load(MeraFolder, Loaded, ErrorText),
    'Mera absolute child accepted');
  Lines.Text := OriginalText;
  Lines.SaveToFile(ManifestName);
  Lines.LoadFromFile(PhaseName);
  Lines[1] := '1.5 0.1';
  Lines.SaveToFile(PhaseName);
  Check(not Mera.Load(MeraFolder, Loaded, ErrorText),
    'mismatched FRF/phase frequency grid accepted');
  Check(Mera.Save(MeraFolder, Source, Options, ErrorText), ErrorText);
  OversizedFile := TFileStream.Create(
    IncludeTrailingPathDelimiter(MeraFolder) + 'frf_12.dat', fmOpenWrite);
  try
    OversizedFile.Size := 16 * 1024 * 1024 + 1;
  finally
    OversizedFile.Free;
  end;
  Check(not Mera.Load(MeraFolder, Loaded, ErrorText),
    'oversized Mera child accepted');
  Check(Mera.Save(MeraFolder, Source, Options, ErrorText), ErrorText);
  Manifest := TMemIniFile.Create(ManifestName);
  try
    Manifest.WriteInteger('Session', 'CurveCount', 5);
    for I := 0 to 4 do
    begin
      Manifest.WriteString('Curve.' + IntToStr(I), 'FrfFile',
        'bulk_frf_' + IntToStr(I) + '.dat');
      Manifest.WriteString('Curve.' + IntToStr(I), 'PhaseFile',
        'bulk_phase_' + IntToStr(I) + '.dat');
      OversizedFile := TFileStream.Create(IncludeTrailingPathDelimiter(
        MeraFolder) + 'bulk_frf_' + IntToStr(I) + '.dat', fmCreate);
      OversizedFile.Size := 14 * 1024 * 1024;
      OversizedFile.Free;
      OversizedFile := TFileStream.Create(IncludeTrailingPathDelimiter(
        MeraFolder) + 'bulk_phase_' + IntToStr(I) + '.dat', fmCreate);
      OversizedFile.Size := 14 * 1024 * 1024;
      OversizedFile.Free;
    end;
    Manifest.UpdateFile;
  finally
    Manifest.Free;
  end;
  Check(not Mera.Load(MeraFolder, Loaded, ErrorText),
    'oversized total Mera payload accepted');
  for I := 0 to 4 do
  begin
    DeleteFile(IncludeTrailingPathDelimiter(MeraFolder) +
      'bulk_frf_' + IntToStr(I) + '.dat');
    DeleteFile(IncludeTrailingPathDelimiter(MeraFolder) +
      'bulk_phase_' + IntToStr(I) + '.dat');
  end;
  Check(Mera.Save(MeraFolder, Source, Options, ErrorText), ErrorText);
  Lines.LoadFromFile(ManifestName);
  OriginalText := Lines.Text;
  FailingMera := TFailingMeraAdapter.Create(nil);
  Check(not FailingMera.Save(MeraFolder, Source, Options, ErrorText),
    'injected partial Mera write succeeded');
  Lines.LoadFromFile(ManifestName);
  Check(Lines.Text = OriginalText,
    'partial Mera write replaced the previous session');
  FailingMera := nil;
  Lines.Free;
  DeleteFile(IncludeTrailingPathDelimiter(MeraFolder) + 'frf.mera');
  DeleteFile(IncludeTrailingPathDelimiter(MeraFolder) + 'frf_12.dat');
  DeleteFile(IncludeTrailingPathDelimiter(MeraFolder) + 'phase_12.dat');
  RemoveDir(MeraFolder);

  Invalid := Source;
  Invalid.Curves[0].FrequencyHz := [2.0, 1.0];
  Check(not ValidateImpactSession(Invalid, ErrorText),
    'nonmonotonic frequency accepted');
  Invalid := Source;
  Invalid.Curves[0].Coherence[0] := 1.1;
  Check(not ValidateImpactSession(Invalid, ErrorText),
    'invalid coherence accepted');
  Invalid := Source;
  Invalid.Curves[0].Magnitude := [3.0];
  Check(not ValidateImpactSession(Invalid, ErrorText),
    'mismatched arrays accepted');
  Invalid := Source;
  Invalid.Curves[0].CurveId := 0;
  Check(not ValidateImpactSession(Invalid, ErrorText), 'zero curve id accepted');
  Invalid := Source;
  SetLength(Invalid.Curves, 2);
  Invalid.Curves[1] := Invalid.Curves[0];
  Check(not ValidateImpactSession(Invalid, ErrorText),
    'duplicate curve id accepted');
  Invalid := Source;
  Invalid.Curves[0].Magnitude[0] := NaN;
  Check(not ValidateImpactSession(Invalid, ErrorText), 'NaN accepted');
  Invalid := Source;
  Invalid.Impacts[0].Excitation.Samples[1].TimeSeconds := 9.0;
  Check(not ValidateImpactSession(Invalid, ErrorText),
    'nonmonotonic timestamps accepted');
  Invalid := Source;
  SetLength(Invalid.Impacts, RECORDER_IMPACT_MAX_IMPACTS + 1);
  Check(not ValidateImpactSession(Invalid, ErrorText),
    'oversized impact count accepted');

  FileName := GetTempDir + 'impact-session-preserve.csv';
  Lines := TStringList.Create;
  try
    Lines.Text := 'previous';
    Lines.SaveToFile(FileName, TEncoding.UTF8);
    OriginalText := Lines.Text;
    Check(not Csv.ExportCsv(FileName, Invalid, Options, ErrorText),
      'invalid snapshot export succeeded');
    Lines.LoadFromFile(FileName, TEncoding.UTF8);
    Check(Lines.Text = OriginalText, 'failed CSV export replaced prior file');
  finally
    Lines.Free;
  end;
  DeleteFile(FileName);
  WriteLn('RESULT ImpactSession passed');
end.
