unit uRecorderTachoPhaseAlgorithms;

{
  Tachometer and phase runtime algorithms.

  Both algorithms receive already transformed tag values from the common
  algorithm manager and publish their results through virtual tags.  Runtime
  objects and FFT buffers are prepared before acquisition starts.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, uRecorderTags, uRecorderAlgorithmManager,
  uRecorderSpectrumEngine;

type
  TRecorderTachoMode = (rtmThreshold, rtmSpectrum);

  TRecorderTachoAlgorithm = class(TRecorderAlgorithm)
  private
    fRegistry: TRecorderTagRegistry;
    fInputTag: TRecorderTag;
    fOutputTag: TRecorderTag;
    fMode: TRecorderTachoMode;
    fOutputTagName: string;
    fPeriodSec: Double;
    fLowPercent: Double;
    fHighPercent: Double;
    fMinimumAmplitude: Double;
    fMinimumFrequencyHz: Double;
    fMaximumFrequencyHz: Double;
    fFFTSize: Integer;
    fSampleRateHz: Double;
    fSpectrumChannel: TRecorderSpectrumChannel;
    fTriggerHigh: Boolean;
    fHasPreviousValue: Boolean;
    fPreviousValue: Double;
    fFirstEdgeTime: Double;
    fLastEdgeTime: Double;
    fLastPublishTime: Double;
    fEdgeCount: Integer;
    procedure ParseProperties;
    procedure PrepareSpectrum;
    procedure PublishFrequency(ATimeSec, AFrequencyHz: Double);
    procedure HandleSpectrumFrame(ASender: TObject;
      const AFrame: TRecorderSpectrumFrame);
    procedure EvalThresholdBlock(const ATimes, AValues: array of Double;
      ACount: Integer);
  public
    destructor Destroy; override;
    class function AlgorithmTypeName: string; override;
    procedure PrepareConfiguration; override;
    procedure LinkTags(ATagRegistry: TRecorderTagRegistry); override;
    procedure DoStart; override;
    function AcceptsTag(ATag: TRecorderTag): Boolean; override;
    procedure DoEvalValue(ATag: TRecorderTag; ATimeSec, AValue: Double); override;
    procedure DoEvalBlock(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer); override;
  end;

  TRecorderPhaseAlgorithm = class(TRecorderAlgorithm)
  private
    fRegistry: TRecorderTagRegistry;
    fSignalTag: TRecorderTag;
    fReferenceTag: TRecorderTag;
    fOutputTag: TRecorderTag;
    fOutputTagName: string;
    fFFTSize: Integer;
    fSampleRateHz: Double;
    fMinimumFrequencyHz: Double;
    fMaximumFrequencyHz: Double;
    fMinimumAmplitude: Double;
    fHarmonic: Integer;
    fSignalChannel: TRecorderSpectrumChannel;
    fReferenceChannel: TRecorderSpectrumChannel;
    fSignalPhase: array of Double;
    fReferencePhase: array of Double;
    fSignalEndTime: Double;
    fReferenceEndTime: Double;
    fReferenceFrequencyHz: Double;
    fReferenceRms: Double;
    fHasSignalFrame: Boolean;
    fHasReferenceFrame: Boolean;
    procedure ParseProperties;
    procedure PrepareChannels;
    procedure HandleSignalFrame(ASender: TObject;
      const AFrame: TRecorderSpectrumFrame);
    procedure HandleReferenceFrame(ASender: TObject;
      const AFrame: TRecorderSpectrumFrame);
    procedure TryPublishPhase;
  public
    destructor Destroy; override;
    class function AlgorithmTypeName: string; override;
    procedure PrepareConfiguration; override;
    procedure LinkTags(ATagRegistry: TRecorderTagRegistry); override;
    procedure DoStart; override;
    function AcceptsTag(ATag: TRecorderTag): Boolean; override;
    procedure DoEvalValue(ATag: TRecorderTag; ATimeSec, AValue: Double); override;
    procedure DoEvalBlock(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer); override;
  end;

implementation

function PropertyValue(const AProperties, AName, ADefault: string): string;
var
  lItems: TStringList;
  lText: string;
  I: Integer;
  lSeparator: SizeInt;
begin
  Result := ADefault;
  lText := StringReplace(AProperties, ';', LineEnding, [rfReplaceAll]);
  lText := StringReplace(lText, ',', LineEnding, [rfReplaceAll]);
  lItems := TStringList.Create;
  try
    lItems.Text := lText;
    for I := 0 to lItems.Count - 1 do
    begin
      lSeparator := Pos('=', lItems[I]);
      if (lSeparator > 0) and SameText(Trim(Copy(lItems[I], 1,
        lSeparator - 1)), AName) then
        Exit(Trim(Copy(lItems[I], lSeparator + 1, MaxInt)));
    end;
  finally
    lItems.Free;
  end;
end;

function PropertyFloat(const AProperties, AName: string;
  ADefault: Double): Double;
var
  lValue: string;
  lFormat: TFormatSettings;
begin
  lValue := PropertyValue(AProperties, AName, '');
  if lValue = '' then
    Exit(ADefault);
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  if not TryStrToFloat(lValue, Result, lFormat) then
    Result := ADefault;
end;

function PropertyInteger(const AProperties, AName: string;
  ADefault: Integer): Integer;
begin
  Result := StrToIntDef(PropertyValue(AProperties, AName, ''), ADefault);
end;

function NormalizeDegrees(AValue: Double): Double;
begin
  Result := AValue;
  while Result > 180.0 do
    Result := Result - 360.0;
  while Result <= -180.0 do
    Result := Result + 360.0;
end;

function ResolveInputTag(ATagRegistry: TRecorderTagRegistry;
  ABinding: TRecorderAlgorithmBinding): TRecorderTag;
begin
  Result := nil;
  if (ATagRegistry = nil) or (ABinding = nil) then
    Exit;
  if ABinding.TagId <> 0 then
    Result := ATagRegistry.FindById(ABinding.TagId);
  if (Result = nil) and (ABinding.TagName <> '') then
    Result := ATagRegistry.FindByName(ABinding.TagName);
end;

function ResolveOutputTag(ATagRegistry: TRecorderTagRegistry;
  const AName, AUnitName: string): TRecorderTag;
begin
  Result := ATagRegistry.FindByName(AName);
  if Result = nil then
    Result := ATagRegistry.CreateTag(AName, 4096, True);
  Result.UnitName := AUnitName;
end;

{ TRecorderTachoAlgorithm }

destructor TRecorderTachoAlgorithm.Destroy;
begin
  fSpectrumChannel.Free;
  inherited Destroy;
end;

class function TRecorderTachoAlgorithm.AlgorithmTypeName: string;
begin
  Result := 'Tacho';
end;

procedure TRecorderTachoAlgorithm.ParseProperties;
var
  lMode: string;
begin
  lMode := PropertyValue(Properties, 'Mode',
    PropertyValue(Properties, 'TahoType', 'Threshold'));
  if SameText(lMode, 'Spectrum') or SameText(lMode, 'FFT') then
    fMode := rtmSpectrum
  else
    fMode := rtmThreshold;
  fOutputTagName := PropertyValue(Properties, 'OutputTag', 'Tacho');
  fPeriodSec := PropertyFloat(Properties, 'PeriodSec',
    PropertyFloat(Properties, 'Period', 0.1));
  fLowPercent := PropertyFloat(Properties, 'LowPercent',
    PropertyFloat(Properties, 'LLo', 30.0));
  fHighPercent := PropertyFloat(Properties, 'HighPercent',
    PropertyFloat(Properties, 'LHi', 70.0));
  fMinimumAmplitude := PropertyFloat(Properties, 'MinimumAmplitude',
    PropertyFloat(Properties, 'MinValue', 0.1));
  fSampleRateHz := PropertyFloat(Properties, 'SampleRateHz', 0.0);
  fMinimumFrequencyHz := PropertyFloat(Properties, 'MinimumFrequencyHz',
    PropertyFloat(Properties, 'FFTBand1', 0.0));
  fMaximumFrequencyHz := PropertyFloat(Properties, 'MaximumFrequencyHz',
    PropertyFloat(Properties, 'FFTBand2', fSampleRateHz * 0.5));
  fFFTSize := PropertyInteger(Properties, 'FFTSize',
    PropertyInteger(Properties, 'FFTCount', 16384));
end;

procedure TRecorderTachoAlgorithm.PrepareSpectrum;
var
  lSettings: TRecorderSpectrumSettings;
begin
  FreeAndNil(fSpectrumChannel);
  if fMode <> rtmSpectrum then
    Exit;
  lSettings.SetDefaults;
  lSettings.FFTSize := fFFTSize;
  lSettings.SampleRateHz := fSampleRateHz;
  lSettings.WindowKind := swkHann;
  lSettings.KeepPhase := False;
  lSettings.Validate;
  fSpectrumChannel := TRecorderSpectrumChannel.Create(fInputTag.Name,
    lSettings);
  fSpectrumChannel.OnFrame := @HandleSpectrumFrame;
end;

procedure TRecorderTachoAlgorithm.PrepareConfiguration;
begin
  ParseProperties;
  if fPeriodSec <= 0.0 then
  begin
    SetReady(False, 'Период тахометра должен быть больше нуля');
    Exit;
  end;
  if (fLowPercent < 0.0) or (fHighPercent > 100.0) or
    (fLowPercent >= fHighPercent) then
  begin
    SetReady(False, 'Пороги тахометра должны удовлетворять 0 <= Low < High <= 100');
    Exit;
  end;
  if (fMode = rtmSpectrum) and ((fSampleRateHz <= 0.0) or (fFFTSize < 2)) then
  begin
    SetReady(False, 'Для спектрального тахометра нужны частота опроса и FFTSize');
    Exit;
  end;
  SetReady(True);
end;

procedure TRecorderTachoAlgorithm.LinkTags(ATagRegistry: TRecorderTagRegistry);
begin
  fRegistry := ATagRegistry;
  fInputTag := nil;
  fOutputTag := nil;
  if ATagRegistry = nil then
  begin
    SetReady(False, 'Не создан реестр тегов');
    Exit;
  end;
  if BindingCount < 1 then
  begin
    SetReady(False, 'Не выбран вход тахометра');
    Exit;
  end;
  fInputTag := ResolveInputTag(ATagRegistry, Binding(0));
  if fInputTag = nil then
  begin
    SetReady(False, 'Не найден вход тахометра: ' + Binding(0).TagName);
    Exit;
  end;
  if SameText(fOutputTagName, fInputTag.Name) then
  begin
    SetReady(False, 'Выход тахометра совпадает со входом');
    Exit;
  end;
  fOutputTag := ResolveOutputTag(ATagRegistry, fOutputTagName, 'Hz');
  PrepareSpectrum;
  SetReady(True);
end;

procedure TRecorderTachoAlgorithm.DoStart;
begin
  fTriggerHigh := False;
  fHasPreviousValue := False;
  fPreviousValue := 0.0;
  fFirstEdgeTime := 0.0;
  fLastEdgeTime := 0.0;
  fLastPublishTime := 0.0;
  fEdgeCount := 0;
  if fSpectrumChannel <> nil then
    fSpectrumChannel.Clear;
end;

function TRecorderTachoAlgorithm.AcceptsTag(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and (ATag = fInputTag);
end;

procedure TRecorderTachoAlgorithm.PublishFrequency(ATimeSec,
  AFrequencyHz: Double);
begin
  if (fRegistry <> nil) and (fOutputTag <> nil) then
    fRegistry.PublishValue(fOutputTag, ATimeSec, AFrequencyHz);
end;

procedure TRecorderTachoAlgorithm.HandleSpectrumFrame(ASender: TObject;
  const AFrame: TRecorderSpectrumFrame);
var
  lFirstBin: Integer;
  lLastBin: Integer;
  lIndex: Integer;
  lMaxIndex: Integer;
  lMaximum: Double;
begin
  if not RecorderSpectrumBandBinRange(fMinimumFrequencyHz,
    fMaximumFrequencyHz, AFrame.FrequencyStepHz, AFrame.Bins, lFirstBin,
    lLastBin) then
  begin
    PublishFrequency(AFrame.EndTimeSec, 0.0);
    Exit;
  end;
  if lFirstBin = 0 then
    Inc(lFirstBin);
  lMaximum := 0.0;
  lMaxIndex := -1;
  for lIndex := lFirstBin to lLastBin do
    if (lMaxIndex < 0) or (AFrame.Rms[lIndex] > lMaximum) then
    begin
      lMaxIndex := lIndex;
      lMaximum := AFrame.Rms[lIndex];
    end;
  if (lMaxIndex < 0) or (lMaximum < fMinimumAmplitude) then
    PublishFrequency(AFrame.EndTimeSec, 0.0)
  else
    PublishFrequency(AFrame.EndTimeSec,
      lMaxIndex * AFrame.FrequencyStepHz);
end;

procedure TRecorderTachoAlgorithm.EvalThresholdBlock(const ATimes,
  AValues: array of Double; ACount: Integer);
var
  I: Integer;
  lMinimum: Double;
  lMaximum: Double;
  lLow: Double;
  lHigh: Double;
  lRange: Double;
  lFrequency: Double;
begin
  if ACount <= 0 then
    Exit;
  lMinimum := AValues[0];
  lMaximum := AValues[0];
  for I := 1 to ACount - 1 do
  begin
    if AValues[I] < lMinimum then lMinimum := AValues[I];
    if AValues[I] > lMaximum then lMaximum := AValues[I];
  end;
  lRange := lMaximum - lMinimum;
  if 0.5 * lRange < fMinimumAmplitude then
  begin
    if (fLastPublishTime = 0.0) or
      (ATimes[ACount - 1] - fLastPublishTime >= fPeriodSec) then
    begin
      PublishFrequency(ATimes[ACount - 1], 0.0);
      fLastPublishTime := ATimes[ACount - 1];
    end;
    Exit;
  end;
  lLow := lMinimum + lRange * fLowPercent / 100.0;
  lHigh := lMinimum + lRange * fHighPercent / 100.0;
  for I := 0 to ACount - 1 do
  begin
    if not fHasPreviousValue then
    begin
      fPreviousValue := AValues[I];
      fTriggerHigh := fPreviousValue >= lHigh;
      fHasPreviousValue := True;
      Continue;
    end;
    if fTriggerHigh then
    begin
      if AValues[I] <= lLow then
      begin
        fTriggerHigh := False;
        if fEdgeCount = 0 then
          fFirstEdgeTime := ATimes[I];
        fLastEdgeTime := ATimes[I];
        Inc(fEdgeCount);
      end;
    end
    else if AValues[I] >= lHigh then
      fTriggerHigh := True;
    fPreviousValue := AValues[I];
    if (fEdgeCount >= 2) and ((fLastPublishTime = 0.0) or
      (ATimes[I] - fLastPublishTime >= fPeriodSec)) then
    begin
      if fLastEdgeTime > fFirstEdgeTime then
      begin
        lFrequency := (fEdgeCount - 1) / (fLastEdgeTime - fFirstEdgeTime);
        PublishFrequency(ATimes[I], lFrequency);
      end;
      fFirstEdgeTime := fLastEdgeTime;
      fEdgeCount := 1;
      fLastPublishTime := ATimes[I];
    end;
  end;
  if (fLastPublishTime > 0.0) and
    (ATimes[ACount - 1] - fLastPublishTime >= 3.0 * fPeriodSec) then
  begin
    PublishFrequency(ATimes[ACount - 1], 0.0);
    fLastPublishTime := ATimes[ACount - 1];
    fEdgeCount := 0;
  end;
end;

procedure TRecorderTachoAlgorithm.DoEvalValue(ATag: TRecorderTag;
  ATimeSec, AValue: Double);
var
  lTimes: array[0..0] of Double;
  lValues: array[0..0] of Double;
begin
  lTimes[0] := ATimeSec;
  lValues[0] := AValue;
  DoEvalBlock(ATag, lTimes, lValues, 1);
end;

procedure TRecorderTachoAlgorithm.DoEvalBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
begin
  if (ATag <> fInputTag) or (ACount <= 0) then
    Exit;
  if fMode = rtmSpectrum then
    fSpectrumChannel.FeedSamples(ATimes, AValues, ACount)
  else
    EvalThresholdBlock(ATimes, AValues, ACount);
end;

{ TRecorderPhaseAlgorithm }

destructor TRecorderPhaseAlgorithm.Destroy;
begin
  fSignalChannel.Free;
  fReferenceChannel.Free;
  inherited Destroy;
end;

class function TRecorderPhaseAlgorithm.AlgorithmTypeName: string;
begin
  Result := 'Phase';
end;

procedure TRecorderPhaseAlgorithm.ParseProperties;
begin
  fOutputTagName := PropertyValue(Properties, 'OutputTag', 'Phase');
  fFFTSize := PropertyInteger(Properties, 'FFTSize',
    PropertyInteger(Properties, 'FFTCount', 1024));
  fSampleRateHz := PropertyFloat(Properties, 'SampleRateHz', 0.0);
  fMinimumFrequencyHz := PropertyFloat(Properties, 'MinimumFrequencyHz', 0.0);
  fMaximumFrequencyHz := PropertyFloat(Properties, 'MaximumFrequencyHz',
    fSampleRateHz * 0.5);
  fMinimumAmplitude := PropertyFloat(Properties, 'MinimumAmplitude', 0.0);
  fHarmonic := PropertyInteger(Properties, 'Harmonic', 1);
end;

procedure TRecorderPhaseAlgorithm.PrepareConfiguration;
begin
  ParseProperties;
  if (fFFTSize < 2) or (fSampleRateHz <= 0.0) then
  begin
    SetReady(False, 'Для фазы нужны частота опроса и FFTSize');
    Exit;
  end;
  if fHarmonic < 1 then
  begin
    SetReady(False, 'Номер гармоники должен быть больше нуля');
    Exit;
  end;
  SetReady(True);
end;

procedure TRecorderPhaseAlgorithm.PrepareChannels;
var
  lSettings: TRecorderSpectrumSettings;
begin
  FreeAndNil(fSignalChannel);
  FreeAndNil(fReferenceChannel);
  lSettings.SetDefaults;
  lSettings.FFTSize := fFFTSize;
  lSettings.SampleRateHz := fSampleRateHz;
  lSettings.WindowKind := swkHann;
  lSettings.KeepPhase := True;
  lSettings.Validate;
  fSignalChannel := TRecorderSpectrumChannel.Create(fSignalTag.Name, lSettings);
  fReferenceChannel := TRecorderSpectrumChannel.Create(fReferenceTag.Name,
    lSettings);
  fSignalChannel.OnFrame := @HandleSignalFrame;
  fReferenceChannel.OnFrame := @HandleReferenceFrame;
  SetLength(fSignalPhase, fFFTSize div 2);
  SetLength(fReferencePhase, fFFTSize div 2);
end;

procedure TRecorderPhaseAlgorithm.LinkTags(ATagRegistry: TRecorderTagRegistry);
begin
  fRegistry := ATagRegistry;
  fSignalTag := nil;
  fReferenceTag := nil;
  fOutputTag := nil;
  if ATagRegistry = nil then
  begin
    SetReady(False, 'Не создан реестр тегов');
    Exit;
  end;
  if BindingCount < 2 then
  begin
    SetReady(False, 'Для фазы нужны сигнал и опорный канал');
    Exit;
  end;
  fSignalTag := ResolveInputTag(ATagRegistry, Binding(0));
  fReferenceTag := ResolveInputTag(ATagRegistry, Binding(1));
  if (fSignalTag = nil) or (fReferenceTag = nil) then
  begin
    SetReady(False, 'Не найдены входные теги фазы');
    Exit;
  end;
  if SameText(fOutputTagName, fSignalTag.Name) or
    SameText(fOutputTagName, fReferenceTag.Name) then
  begin
    SetReady(False, 'Выход фазы совпадает со входом');
    Exit;
  end;
  fOutputTag := ResolveOutputTag(ATagRegistry, fOutputTagName, 'deg');
  PrepareChannels;
  SetReady(True);
end;

procedure TRecorderPhaseAlgorithm.DoStart;
begin
  fHasSignalFrame := False;
  fHasReferenceFrame := False;
  if fSignalChannel <> nil then fSignalChannel.Clear;
  if fReferenceChannel <> nil then fReferenceChannel.Clear;
end;

function TRecorderPhaseAlgorithm.AcceptsTag(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and
    ((ATag = fSignalTag) or (ATag = fReferenceTag));
end;

procedure TRecorderPhaseAlgorithm.HandleSignalFrame(ASender: TObject;
  const AFrame: TRecorderSpectrumFrame);
begin
  if Length(AFrame.PhaseRad) <> Length(fSignalPhase) then
    Exit;
  Move(AFrame.PhaseRad[0], fSignalPhase[0],
    Length(fSignalPhase) * SizeOf(Double));
  fSignalEndTime := AFrame.EndTimeSec;
  fHasSignalFrame := True;
  TryPublishPhase;
end;

procedure TRecorderPhaseAlgorithm.HandleReferenceFrame(ASender: TObject;
  const AFrame: TRecorderSpectrumFrame);
var
  lFirstBin: Integer;
  lLastBin: Integer;
  lIndex: Integer;
  lMaxIndex: Integer;
begin
  if Length(AFrame.PhaseRad) <> Length(fReferencePhase) then
    Exit;
  Move(AFrame.PhaseRad[0], fReferencePhase[0],
    Length(fReferencePhase) * SizeOf(Double));
  fReferenceEndTime := AFrame.EndTimeSec;
  fReferenceFrequencyHz := 0.0;
  fReferenceRms := 0.0;
  lMaxIndex := -1;
  if RecorderSpectrumBandBinRange(fMinimumFrequencyHz, fMaximumFrequencyHz,
    AFrame.FrequencyStepHz, AFrame.Bins, lFirstBin, lLastBin) then
  begin
    if lFirstBin = 0 then Inc(lFirstBin);
    for lIndex := lFirstBin to lLastBin do
      if (lMaxIndex < 0) or (AFrame.Rms[lIndex] > fReferenceRms) then
      begin
        lMaxIndex := lIndex;
        fReferenceRms := AFrame.Rms[lIndex];
      end;
    if lMaxIndex >= 0 then
      fReferenceFrequencyHz := lMaxIndex * AFrame.FrequencyStepHz;
  end;
  fHasReferenceFrame := True;
  TryPublishPhase;
end;

procedure TRecorderPhaseAlgorithm.TryPublishPhase;
var
  lFrequencyStep: Double;
  lBin: Integer;
  lPhase: Double;
  lFrameDuration: Double;
  lTime: Double;
begin
  if not (fHasSignalFrame and fHasReferenceFrame) then
    Exit;
  lFrameDuration := fFFTSize / fSampleRateHz;
  if Abs(fSignalEndTime - fReferenceEndTime) > lFrameDuration then
    Exit;
  if (fReferenceFrequencyHz <= 0.0) or
    (fReferenceRms < fMinimumAmplitude) then
    lPhase := 0.0
  else
  begin
    lFrequencyStep := fSampleRateHz / fFFTSize;
    lBin := Round(fReferenceFrequencyHz * fHarmonic / lFrequencyStep);
    if (lBin <= 0) or (lBin >= Length(fSignalPhase)) then
      lPhase := 0.0
    else
      lPhase := NormalizeDegrees((fSignalPhase[lBin] -
        fReferencePhase[lBin]) * 180.0 / Pi);
  end;
  lTime := Max(fSignalEndTime, fReferenceEndTime);
  fRegistry.PublishValue(fOutputTag, lTime, lPhase);
  fHasSignalFrame := False;
  fHasReferenceFrame := False;
end;

procedure TRecorderPhaseAlgorithm.DoEvalValue(ATag: TRecorderTag;
  ATimeSec, AValue: Double);
var
  lTimes: array[0..0] of Double;
  lValues: array[0..0] of Double;
begin
  lTimes[0] := ATimeSec;
  lValues[0] := AValue;
  DoEvalBlock(ATag, lTimes, lValues, 1);
end;

procedure TRecorderPhaseAlgorithm.DoEvalBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
begin
  if ACount <= 0 then Exit;
  if ATag = fSignalTag then
    fSignalChannel.FeedSamples(ATimes, AValues, ACount)
  else if ATag = fReferenceTag then
    fReferenceChannel.FeedSamples(ATimes, AValues, ACount);
end;

end.
