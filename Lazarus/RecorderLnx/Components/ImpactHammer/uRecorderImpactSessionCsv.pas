unit uRecorderImpactSessionCsv;

{ Long-form CSV projection of an immutable impact session. It is intended for
  exchange and inspection; the JSON bundle remains the lossless import format. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Classes, uRecorderImpactSessionContracts,
  uRecorderImpactSessionValidation;

type
  TRecorderImpactSessionCsvExporter = class(TInterfacedObject,
    IRecorderImpactSessionCsvExporter)
  public
    function ExportCsv(const AFileName: string;
      const ASnapshot: TRecorderImpactSessionSnapshot;
      const AOptions: TRecorderImpactSessionSaveOptions;
      out AError: string): Boolean;
  end;

implementation

function CsvText(const AValue: string): string;
var
  SafeValue: string;
begin
  SafeValue := AValue;
  if (SafeValue <> '') and (SafeValue[1] in ['=', '+', '-', '@']) then
    SafeValue := '''' + SafeValue;
  Result := '"' + StringReplace(SafeValue, '"', '""', [rfReplaceAll]) + '"';
end;

procedure SaveAtomically(ALines: TStrings; const AFileName: string);
var
  TempName: string;
  BackupName: string;
  HadOriginal: Boolean;
begin
  TempName := AFileName + '.tmp.' + IntToHex(GetTickCount64, 16);
  BackupName := AFileName + '.bak.' + IntToHex(GetTickCount64, 16);
  ALines.SaveToFile(TempName, TEncoding.UTF8);
  HadOriginal := FileExists(AFileName);
  try
    if HadOriginal and not RenameFile(AFileName, BackupName) then
      raise EFOpenError.Create('Cannot stage previous CSV file');
    if not RenameFile(TempName, AFileName) then
    begin
      if HadOriginal then
        RenameFile(BackupName, AFileName);
      raise EFOpenError.Create('Cannot replace CSV file');
    end;
    if HadOriginal then
      DeleteFile(BackupName);
  except
    DeleteFile(TempName);
    raise;
  end;
end;

function NumberText(AValue: Double): string;
begin
  Result := FloatToStr(AValue, DefaultFormatSettings);
end;

function TRecorderImpactSessionCsvExporter.ExportCsv(const AFileName: string;
  const ASnapshot: TRecorderImpactSessionSnapshot;
  const AOptions: TRecorderImpactSessionSaveOptions;
  out AError: string): Boolean;
var
  Lines: TStringList;
  Origin: Double;
  I, J, K: Integer;

  procedure AddSeries(const AKind: string; ASequence: QWord;
    const ASeries: TRecorderImpactSessionSeries; ATimeOrigin: Double);
  var
    SampleIndex: Integer;
  begin
    for SampleIndex := 0 to High(ASeries.Samples) do
      Lines.Add(Format('raw;%s;%d;%d;%d;%s;%s;%s;%s', [
        AKind, ASequence, ASeries.TagId, ASeries.CurveId,
        CsvText(ASeries.Name), CsvText(ASeries.UnitName),
        NumberText(ASeries.Samples[SampleIndex].TimeSeconds - ATimeOrigin),
        NumberText(ASeries.Samples[SampleIndex].Value)]));
  end;

begin
  Result := False;
  AError := '';
  if not ValidateImpactSession(ASnapshot, AError) then
    Exit;
  Lines := TStringList.Create;
  try
    Lines.Add('record;kind;sequence;tag_id;curve_id;name;unit;x;value');
    if AOptions.IncludeRawBlocks then
      for I := 0 to High(ASnapshot.Impacts) do
      begin
        if AOptions.SaveT0 then
          Origin := 0
        else
          Origin := ASnapshot.Impacts[I].TriggerTimeSeconds;
        AddSeries('hammer', ASnapshot.Impacts[I].Sequence,
          ASnapshot.Impacts[I].Excitation, Origin);
        for J := 0 to High(ASnapshot.Impacts[I].Responses) do
          AddSeries('response', ASnapshot.Impacts[I].Sequence,
            ASnapshot.Impacts[I].Responses[J], Origin);
      end;
    for I := 0 to High(ASnapshot.Curves) do
      for K := 0 to High(ASnapshot.Curves[I].FrequencyHz) do
      begin
        Lines.Add(Format('frf;magnitude;0;%d;%d;%s;%s;%s;%s', [
          ASnapshot.Curves[I].TagId, ASnapshot.Curves[I].CurveId,
          CsvText(ASnapshot.Curves[I].Name),
          CsvText(ASnapshot.Curves[I].ResponseUnitName),
          NumberText(ASnapshot.Curves[I].FrequencyHz[K]),
          NumberText(ASnapshot.Curves[I].Magnitude[K])]));
        Lines.Add(Format('frf;phase;0;%d;%d;%s;rad;%s;%s', [
          ASnapshot.Curves[I].TagId, ASnapshot.Curves[I].CurveId,
          CsvText(ASnapshot.Curves[I].Name),
          NumberText(ASnapshot.Curves[I].FrequencyHz[K]),
          NumberText(ASnapshot.Curves[I].PhaseRadians[K])]));
        Lines.Add(Format('frf;coherence;0;%d;%d;%s;1;%s;%s', [
          ASnapshot.Curves[I].TagId, ASnapshot.Curves[I].CurveId,
          CsvText(ASnapshot.Curves[I].Name),
          NumberText(ASnapshot.Curves[I].FrequencyHz[K]),
          NumberText(ASnapshot.Curves[I].Coherence[K])]));
      end;
    SaveAtomically(Lines, AFileName);
    Result := True;
  except
    on E: Exception do
      AError := E.Message;
  end;
  Lines.Free;
end;

end.
