program ImpactSessionTest;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, Math, IniFiles, uRecorderImpactSessionContracts,
  uRecorderImpactSessionJson, uRecorderImpactSessionCsv,
  uRecorderImpactSessionValidation, uRecorderImpactMeraAdapter;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create(AMessage);
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
