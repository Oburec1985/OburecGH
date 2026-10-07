unit uRecorderImpactSessionJson;

{ Portable JSON adapter for impact-hammer sessions. Conversion is performed
  only on explicit save/load commands, never in acquisition or paint paths. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Classes, fpjson, jsonparser, uRecorderImpactSessionContracts,
  uRecorderImpactSessionValidation;

type
  TRecorderImpactSessionJsonStore = class(TInterfacedObject,
    IRecorderImpactSessionStore, IRecorderImpactComparisonPort)
  private
    class function SeriesToJson(const ASeries: TRecorderImpactSessionSeries;
      ATimeOrigin: Double): TJSONObject; static;
    class function SeriesFromJson(AJson: TJSONObject;
      ATimeOrigin: Double; var ATotalSamples: Int64;
      out ASeries: TRecorderImpactSessionSeries): Boolean; static;
  public
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

implementation

function DoubleArrayToJson(const AValues: array of Double): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to High(AValues) do
    Result.Add(AValues[I]);
end;

function JsonToDoubleArray(AJson: TJSONArray; out AValues: array of Double): Boolean;
var
  I: Integer;
begin
  Result := (AJson <> nil) and (AJson.Count = Length(AValues));
  if not Result then
    Exit;
  for I := 0 to AJson.Count - 1 do
    AValues[I] := AJson.Floats[I];
end;

class function TRecorderImpactSessionJsonStore.SeriesToJson(
  const ASeries: TRecorderImpactSessionSeries;
  ATimeOrigin: Double): TJSONObject;
var
  Samples: TJSONArray;
  Sample: TJSONArray;
  I: Integer;
begin
  Result := TJSONObject.Create;
  Result.Add('tagId', Int64(ASeries.TagId));
  Result.Add('curveId', Int64(ASeries.CurveId));
  Result.Add('name', ASeries.Name);
  Result.Add('unit', ASeries.UnitName);
  Samples := TJSONArray.Create;
  Result.Add('samples', Samples);
  for I := 0 to High(ASeries.Samples) do
  begin
    Sample := TJSONArray.Create;
    Sample.Add(ASeries.Samples[I].TimeSeconds - ATimeOrigin);
    Sample.Add(ASeries.Samples[I].Value);
    Samples.Add(Sample);
  end;
end;

class function TRecorderImpactSessionJsonStore.SeriesFromJson(
  AJson: TJSONObject; ATimeOrigin: Double; var ATotalSamples: Int64;
  out ASeries: TRecorderImpactSessionSeries): Boolean;
var
  Samples: TJSONArray;
  Sample: TJSONArray;
  I: Integer;
begin
  ASeries := Default(TRecorderImpactSessionSeries);
  Result := AJson <> nil;
  if not Result then
    Exit;
  ASeries.TagId := AJson.Get('tagId', Int64(0));
  ASeries.CurveId := AJson.Get('curveId', Int64(0));
  ASeries.Name := AJson.Get('name', '');
  ASeries.UnitName := AJson.Get('unit', '');
  Samples := AJson.Arrays['samples'];
  if Samples.Count > RECORDER_IMPACT_MAX_TOTAL_SAMPLES - ATotalSamples then
    Exit(False);
  Inc(ATotalSamples, Samples.Count);
  SetLength(ASeries.Samples, Samples.Count);
  for I := 0 to Samples.Count - 1 do
  begin
    Sample := Samples.Arrays[I];
    if Sample.Count <> 2 then
      Exit(False);
    ASeries.Samples[I].TimeSeconds := Sample.Floats[0] + ATimeOrigin;
    ASeries.Samples[I].Value := Sample.Floats[1];
  end;
end;

function TRecorderImpactSessionJsonStore.Save(const AFileName: string;
  const ASnapshot: TRecorderImpactSessionSnapshot;
  const AOptions: TRecorderImpactSessionSaveOptions;
  out AError: string): Boolean;
var
  Root, ImpactJson, CurveJson: TJSONObject;
  Impacts, Responses, Curves: TJSONArray;
  Lines: TStringList;
  Origin: Double;
  I, J: Integer;
begin
  Result := False;
  AError := '';
  if not ValidateImpactSession(ASnapshot, AError) then
    Exit;
  Root := TJSONObject.Create;
  Lines := TStringList.Create;
  try
    Root.Add('format', 'recorder-impact-session');
    Root.Add('version', ASnapshot.FormatVersion);
    Root.Add('sessionId', ASnapshot.SessionId);
    Root.Add('createdUtc', DateTimeToStr(ASnapshot.CreatedUtc,
      DefaultFormatSettings));
    Root.Add('sampleRateHz', ASnapshot.SampleRateHz);
    Root.Add('saveT0', AOptions.SaveT0);
    Impacts := TJSONArray.Create;
    Root.Add('impacts', Impacts);
    if AOptions.IncludeRawBlocks then
      for I := 0 to High(ASnapshot.Impacts) do
      begin
        ImpactJson := TJSONObject.Create;
        Impacts.Add(ImpactJson);
        ImpactJson.Add('sequence', Int64(ASnapshot.Impacts[I].Sequence));
        ImpactJson.Add('triggerTime', ASnapshot.Impacts[I].TriggerTimeSeconds);
        ImpactJson.Add('accepted', ASnapshot.Impacts[I].Accepted);
        ImpactJson.Add('hidden', ASnapshot.Impacts[I].Hidden);
        if AOptions.SaveT0 then
          Origin := 0
        else
          Origin := ASnapshot.Impacts[I].TriggerTimeSeconds;
        ImpactJson.Add('excitation', SeriesToJson(
          ASnapshot.Impacts[I].Excitation, Origin));
        Responses := TJSONArray.Create;
        ImpactJson.Add('responses', Responses);
        for J := 0 to High(ASnapshot.Impacts[I].Responses) do
          Responses.Add(SeriesToJson(ASnapshot.Impacts[I].Responses[J], Origin));
      end;
    Curves := TJSONArray.Create;
    Root.Add('curves', Curves);
    for I := 0 to High(ASnapshot.Curves) do
    begin
      CurveJson := TJSONObject.Create;
      Curves.Add(CurveJson);
      CurveJson.Add('curveId', Int64(ASnapshot.Curves[I].CurveId));
      CurveJson.Add('tagId', Int64(ASnapshot.Curves[I].TagId));
      CurveJson.Add('name', ASnapshot.Curves[I].Name);
      CurveJson.Add('excitationUnit', ASnapshot.Curves[I].ExcitationUnitName);
      CurveJson.Add('responseUnit', ASnapshot.Curves[I].ResponseUnitName);
      CurveJson.Add('frequencyHz', DoubleArrayToJson(
        ASnapshot.Curves[I].FrequencyHz));
      if AOptions.IncludeSpectra and
        (Length(ASnapshot.Curves[I].ExcitationSpectrum) =
          Length(ASnapshot.Curves[I].FrequencyHz)) and
        (Length(ASnapshot.Curves[I].ResponseSpectrum) =
          Length(ASnapshot.Curves[I].FrequencyHz)) then
      begin
        CurveJson.Add('excitationSpectrum', DoubleArrayToJson(
          ASnapshot.Curves[I].ExcitationSpectrum));
        CurveJson.Add('responseSpectrum', DoubleArrayToJson(
          ASnapshot.Curves[I].ResponseSpectrum));
      end;
      CurveJson.Add('magnitude', DoubleArrayToJson(
        ASnapshot.Curves[I].Magnitude));
      CurveJson.Add('phaseRadians', DoubleArrayToJson(
        ASnapshot.Curves[I].PhaseRadians));
      CurveJson.Add('coherence', DoubleArrayToJson(
        ASnapshot.Curves[I].Coherence));
    end;
    Lines.Text := Root.FormatJSON;
    Lines.SaveToFile(AFileName, TEncoding.UTF8);
    Result := True;
  except
    on E: Exception do
      AError := E.Message;
  end;
  Lines.Free;
  Root.Free;
end;

function TRecorderImpactSessionJsonStore.Load(const AFileName: string;
  out ASnapshot: TRecorderImpactSessionSnapshot;
  out AError: string): Boolean;
var
  Root, ImpactJson, CurveJson: TJSONObject;
  Data: TJSONData;
  Impacts, Responses, Curves: TJSONArray;
  Lines: TStringList;
  Origin: Double;
  I, J, Count: Integer;
  Input: TFileStream;
  TotalSamples: Int64;
begin
  ASnapshot := Default(TRecorderImpactSessionSnapshot);
  Result := False;
  AError := '';
  Lines := TStringList.Create;
  Data := nil;
  try
    Input := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
    try
      if Input.Size > RECORDER_IMPACT_MAX_FILE_BYTES then
        raise EConvertError.Create('Impact session file exceeds supported limit');
    finally
      Input.Free;
    end;
    Lines.LoadFromFile(AFileName, TEncoding.UTF8);
    Data := GetJSON(Lines.Text);
    if not (Data is TJSONObject) then
      raise EConvertError.Create('Impact session root must be an object');
    Root := TJSONObject(Data);
    if Root.Get('format', '') <> 'recorder-impact-session' then
      raise EConvertError.Create('Unsupported impact session format');
    ASnapshot.FormatVersion := Root.Get('version', 0);
    if ASnapshot.FormatVersion <> RECORDER_IMPACT_SESSION_VERSION then
      raise EConvertError.Create('Unsupported impact session schema version');
    ASnapshot.SessionId := Root.Get('sessionId', '');
    ASnapshot.SampleRateHz := Root.Get('sampleRateHz', 0.0);
    TryStrToDateTime(Root.Get('createdUtc', ''), ASnapshot.CreatedUtc,
      DefaultFormatSettings);
    Impacts := Root.Arrays['impacts'];
    if not ValidImpactCount(Impacts.Count, RECORDER_IMPACT_MAX_IMPACTS,
      'Impact count', AError) then
      raise EConvertError.Create(AError);
    SetLength(ASnapshot.Impacts, Impacts.Count);
    TotalSamples := 0;
    for I := 0 to Impacts.Count - 1 do
    begin
      ImpactJson := Impacts.Objects[I];
      ASnapshot.Impacts[I].Sequence := ImpactJson.Get('sequence', Int64(0));
      ASnapshot.Impacts[I].TriggerTimeSeconds :=
        ImpactJson.Get('triggerTime', 0.0);
      ASnapshot.Impacts[I].Accepted := ImpactJson.Get('accepted', False);
      ASnapshot.Impacts[I].Hidden := ImpactJson.Get('hidden', False);
      if Root.Get('saveT0', True) then
        Origin := 0
      else
        Origin := ASnapshot.Impacts[I].TriggerTimeSeconds;
      if not SeriesFromJson(ImpactJson.Objects['excitation'], Origin,
        TotalSamples,
        ASnapshot.Impacts[I].Excitation) then
        raise EConvertError.Create('Invalid excitation series');
      Responses := ImpactJson.Arrays['responses'];
      if not ValidImpactCount(Responses.Count, RECORDER_IMPACT_MAX_RESPONSES,
        'Response count', AError) then
        raise EConvertError.Create(AError);
      SetLength(ASnapshot.Impacts[I].Responses, Responses.Count);
      for J := 0 to Responses.Count - 1 do
        if not SeriesFromJson(Responses.Objects[J], Origin, TotalSamples,
          ASnapshot.Impacts[I].Responses[J]) then
          raise EConvertError.Create('Invalid response series');
    end;
    Curves := Root.Arrays['curves'];
    if not ValidImpactCount(Curves.Count, RECORDER_IMPACT_MAX_CURVES,
      'Curve count', AError) then
      raise EConvertError.Create(AError);
    SetLength(ASnapshot.Curves, Curves.Count);
    for I := 0 to Curves.Count - 1 do
    begin
      CurveJson := Curves.Objects[I];
      ASnapshot.Curves[I].CurveId := CurveJson.Get('curveId', Int64(0));
      ASnapshot.Curves[I].TagId := CurveJson.Get('tagId', Int64(0));
      ASnapshot.Curves[I].Name := CurveJson.Get('name', '');
      ASnapshot.Curves[I].ExcitationUnitName :=
        CurveJson.Get('excitationUnit', '');
      ASnapshot.Curves[I].ResponseUnitName :=
        CurveJson.Get('responseUnit', '');
      Count := CurveJson.Arrays['frequencyHz'].Count;
      if not ValidImpactCount(Count, RECORDER_IMPACT_MAX_BINS,
        'Frequency bin count', AError) then
        raise EConvertError.Create(AError);
      SetLength(ASnapshot.Curves[I].FrequencyHz, Count);
      SetLength(ASnapshot.Curves[I].Magnitude, Count);
      SetLength(ASnapshot.Curves[I].PhaseRadians, Count);
      SetLength(ASnapshot.Curves[I].Coherence, Count);
      if not JsonToDoubleArray(CurveJson.Arrays['frequencyHz'],
        ASnapshot.Curves[I].FrequencyHz) or
        not JsonToDoubleArray(CurveJson.Arrays['magnitude'],
        ASnapshot.Curves[I].Magnitude) or
        not JsonToDoubleArray(CurveJson.Arrays['phaseRadians'],
        ASnapshot.Curves[I].PhaseRadians) or
        not JsonToDoubleArray(CurveJson.Arrays['coherence'],
        ASnapshot.Curves[I].Coherence) then
        raise EConvertError.Create('Invalid FRF curve arrays');
      if CurveJson.Find('excitationSpectrum') <> nil then
      begin
        SetLength(ASnapshot.Curves[I].ExcitationSpectrum, Count);
        SetLength(ASnapshot.Curves[I].ResponseSpectrum, Count);
        if not JsonToDoubleArray(CurveJson.Arrays['excitationSpectrum'],
          ASnapshot.Curves[I].ExcitationSpectrum) or
          not JsonToDoubleArray(CurveJson.Arrays['responseSpectrum'],
          ASnapshot.Curves[I].ResponseSpectrum) then
          raise EConvertError.Create('Invalid spectrum arrays');
      end;
    end;
    Result := ValidateImpactSession(ASnapshot, AError);
  except
    on E: Exception do
      AError := E.Message;
  end;
  Data.Free;
  Lines.Free;
end;

function TRecorderImpactSessionJsonStore.ImportComparison(
  const AFileName: string; out ASnapshot: TRecorderImpactSessionSnapshot;
  out AError: string): Boolean;
begin
  Result := Load(AFileName, ASnapshot, AError);
end;

end.
