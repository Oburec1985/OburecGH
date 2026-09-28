unit uRecorderScalarAlgorithms;

{ Потоковые арифметические операции и счетчик импульсов.
  Алгоритмы получают уже преобразованные данные тегов, а результаты публикуют
  как виртуальные теги через общий реестр Recorder. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, StrUtils, Math, uRecorderTags, uRecorderAlgorithmManager;

type
  TRecorderArithmeticOperation = (raoAdd, raoSubtract, raoMultiply, raoDivide);

  TRecorderArithmeticAlgorithm = class(TRecorderAlgorithm)
  private
    fRegistry: TRecorderTagRegistry;
    fInputA: TRecorderTag;
    fInputB: TRecorderTag;
    fOutput: TRecorderTag;
    fOperation: TRecorderArithmeticOperation;
    fOutputName: string;
    fTimesA: TRecorderDoubleArray;
    fValuesA: TRecorderDoubleArray;
    fTimesB: TRecorderDoubleArray;
    fValuesB: TRecorderDoubleArray;
    fOutputTimes: TRecorderDoubleArray;
    fOutputValues: TRecorderDoubleArray;
    fCountA: Integer;
    fCountB: Integer;
    fHasA: Boolean;
    fHasB: Boolean;
    fScalarA: Double;
    fScalarB: Double;
    fScalarTimeA: Double;
    fScalarTimeB: Double;
    fHasScalarA: Boolean;
    fHasScalarB: Boolean;
    procedure ReadProperties;
    procedure EnsureCapacity(ACount: Integer);
    procedure StoreBlock(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer);
    procedure CalculateReadyBlocks;
    function Calculate(A, B: Double): Double;
    function DefaultOutputName: string;
  public
    constructor Create; override;
    class function AlgorithmTypeName: string; override;
    procedure LinkTags(ATagRegistry: TRecorderTagRegistry); override;
    procedure PrepareConfiguration; override;
    procedure DoStart; override;
    function AcceptsTag(ATag: TRecorderTag): Boolean; override;
    procedure DoEvalValue(ATag: TRecorderTag; ATimeSec, AValue: Double); override;
    procedure DoEvalBlock(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer); override;
  end;

  TRecorderCounterInputRole = (rcirSignal, rcirGate, rcirReset, rcirShift);

  TRecorderCounterAlgorithm = class(TRecorderAlgorithm)
  private
    fRegistry: TRecorderTagRegistry;
    fInput: TRecorderTag;
    fGate: TRecorderTag;
    fReset: TRecorderTag;
    fShift: TRecorderTag;
    fOutput: TRecorderTag;
    fOutputName: string;
    fLowThreshold: Double;
    fHighThreshold: Double;
    fMinimumAmplitude: Double;
    fRelativeThresholds: Boolean;
    fKeepValueOnStart: Boolean;
    fCounter: QWord;
    fState: Integer;
    fGateValue: Double;
    fResetValue: Double;
    fPreviousResetValue: Double;
    fShiftValue: Double;
    fHasResetValue: Boolean;
    fOutputTimes: TRecorderDoubleArray;
    fOutputValues: TRecorderDoubleArray;
    procedure ReadProperties;
    procedure ResolveBindings;
    procedure EnsureCapacity(ACount: Integer);
    procedure UpdateAuxiliaryValue(ATag: TRecorderTag; const AValues: array of Double;
      ACount: Integer);
    procedure CalculateThresholds(const AValues: array of Double; ACount: Integer;
      out ALow, AHigh, AAmplitude: Double);
    procedure CountBlock(const ATimes, AValues: array of Double; ACount: Integer);
  public
    constructor Create; override;
    class function AlgorithmTypeName: string; override;
    procedure LinkTags(ATagRegistry: TRecorderTagRegistry); override;
    procedure PrepareConfiguration; override;
    procedure DoStart; override;
    function AcceptsTag(ATag: TRecorderTag): Boolean; override;
    procedure DoEvalValue(ATag: TRecorderTag; ATimeSec, AValue: Double); override;
    procedure DoEvalBlock(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer); override;
  end;

implementation

const
  CCounterMaximum = High(Cardinal);

function IsPropertySeparator(const AText: string; AIndex: Integer): Boolean;
var
  I: Integer;
begin
  if AText[AIndex] in [#10, #13, ';'] then
    Exit(True);
  if AText[AIndex] <> ',' then
    Exit(False);
  I := AIndex + 1;
  while (I <= Length(AText)) and (AText[I] in [' ', #9]) do
    Inc(I);
  while (I <= Length(AText)) and
    (AText[I] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
    Inc(I);
  while (I <= Length(AText)) and (AText[I] in [' ', #9]) do
    Inc(I);
  Result := (I <= Length(AText)) and (AText[I] = '=');
end;

function PropertyValue(const AProperties, AName, ADefault: string): string;
var
  lLowerProperties, lNeedle: string;
  lStart, lFinish: Integer;
begin
  Result := ADefault;
  lLowerProperties := LowerCase(AProperties);
  lNeedle := LowerCase(AName) + '=';
  lStart := Pos(lNeedle, lLowerProperties);
  while (lStart > 1) and
    not (AProperties[lStart - 1] in [#10, #13, ';', ',', ' ', #9]) do
    lStart := PosEx(lNeedle, lLowerProperties, lStart + Length(lNeedle));
  if lStart = 0 then
    Exit;
  Inc(lStart, Length(lNeedle));
  lFinish := lStart;
  while (lFinish <= Length(AProperties)) and
    not IsPropertySeparator(AProperties, lFinish) do
    Inc(lFinish);
  Result := Trim(Copy(AProperties, lStart, lFinish - lStart));
end;

function PropertyFloat(const AProperties, AName: string; ADefault: Double): Double;
var
  lValue: string;
begin
  lValue := PropertyValue(AProperties, AName, '');
  if not TryStrToFloat(lValue, Result) then
  begin
    lValue := StringReplace(lValue, '.', FormatSettings.DecimalSeparator, []);
    lValue := StringReplace(lValue, ',', FormatSettings.DecimalSeparator, []);
    if not TryStrToFloat(lValue, Result) then
      Result := ADefault;
  end;
end;

function PropertyBoolean(const AProperties, AName: string;
  ADefault: Boolean): Boolean;
var
  lValue: string;
begin
  lValue := LowerCase(PropertyValue(AProperties, AName, ''));
  if (lValue = '1') or (lValue = 'true') or (lValue = 'yes') then
    Exit(True);
  if (lValue = '0') or (lValue = 'false') or (lValue = 'no') then
    Exit(False);
  Result := ADefault;
end;

function MeanValue(const AValues: array of Double; ACount: Integer): Double;
var
  I: Integer;
begin
  Result := 0;
  if ACount <= 0 then
    Exit;
  for I := 0 to ACount - 1 do
    Result := Result + AValues[I];
  Result := Result / ACount;
end;

{ TRecorderArithmeticAlgorithm }

constructor TRecorderArithmeticAlgorithm.Create;
begin
  inherited Create;
  fOperation := raoAdd;
  Properties := 'TypeRes=0';
end;

class function TRecorderArithmeticAlgorithm.AlgorithmTypeName: string;
begin
  Result := 'Arithmetic';
end;

procedure TRecorderArithmeticAlgorithm.ReadProperties;
var
  lOperation: string;
  lOperationIndex: Integer;
begin
  lOperation := LowerCase(PropertyValue(Properties, 'Operation', ''));
  if lOperation = '' then
  begin
    lOperationIndex := StrToIntDef(PropertyValue(Properties, 'TypeRes', '0'), 0);
    if (lOperationIndex >= Ord(Low(TRecorderArithmeticOperation))) and
      (lOperationIndex <= Ord(High(TRecorderArithmeticOperation))) then
      fOperation := TRecorderArithmeticOperation(lOperationIndex)
    else
      fOperation := raoAdd;
  end
  else if (lOperation = 'sub') or (lOperation = 'subtract') then
    fOperation := raoSubtract
  else if (lOperation = 'mul') or (lOperation = 'multiply') then
    fOperation := raoMultiply
  else if (lOperation = 'div') or (lOperation = 'divide') then
    fOperation := raoDivide
  else
    fOperation := raoAdd;
  fOutputName := PropertyValue(Properties, 'OutChannel', '');
end;

function TRecorderArithmeticAlgorithm.DefaultOutputName: string;
const
  COperationSuffix: array[TRecorderArithmeticOperation] of string =
    ('Add', 'Dec', 'Mult', 'Div');
begin
  Result := fInputA.Name + '_' + fInputB.Name + '_' + COperationSuffix[fOperation];
end;

procedure TRecorderArithmeticAlgorithm.LinkTags(ATagRegistry: TRecorderTagRegistry);
begin
  inherited LinkTags(ATagRegistry);
  fRegistry := ATagRegistry;
  fInputA := nil;
  fInputB := nil;
  fOutput := nil;
  if (fRegistry = nil) or (BindingCount < 2) then
  begin
    SetReady(False, 'Арифметической операции нужны два входных тега');
    Exit;
  end;
  fInputA := fRegistry.FindById(Binding(0).TagId);
  fInputB := fRegistry.FindById(Binding(1).TagId);
  if (fInputA = nil) or (fInputB = nil) then
  begin
    SetReady(False, 'Не найдены входные теги арифметической операции');
    Exit;
  end;
  ReadProperties;
  if fOutputName = '' then
    fOutputName := DefaultOutputName;
  fOutput := fRegistry.FindByName(fOutputName);
  if fOutput = nil then
    fOutput := fRegistry.CreateTag(fOutputName, 4096, True);
  if (fOutput = fInputA) or (fOutput = fInputB) then
  begin
    SetReady(False, 'Выход арифметической операции совпадает со входом');
    Exit;
  end;
  fOutput.PollFrequencyHz := fInputA.PollFrequencyHz;
  case fOperation of
    raoAdd, raoSubtract:
      if SameText(fInputA.UnitName, fInputB.UnitName) then
        fOutput.UnitName := fInputA.UnitName
      else
        fOutput.UnitName := '';
    raoMultiply:
      fOutput.UnitName := fInputA.UnitName + '*' + fInputB.UnitName;
    raoDivide:
      fOutput.UnitName := fInputA.UnitName + '/' + fInputB.UnitName;
  end;
  SetReady(True);
end;

procedure TRecorderArithmeticAlgorithm.PrepareConfiguration;
begin
  ReadProperties;
  SetReady(BindingCount >= 2, 'Арифметической операции нужны два входных тега');
end;

procedure TRecorderArithmeticAlgorithm.DoStart;
begin
  fHasA := False;
  fHasB := False;
  fCountA := 0;
  fCountB := 0;
  fHasScalarA := False;
  fHasScalarB := False;
end;

function TRecorderArithmeticAlgorithm.AcceptsTag(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and ((ATag = fInputA) or (ATag = fInputB));
end;

procedure TRecorderArithmeticAlgorithm.DoEvalValue(ATag: TRecorderTag;
  ATimeSec, AValue: Double);
var
  lTime: Double;
begin
  if ATag = fInputA then
  begin
    fScalarA := AValue;
    fScalarTimeA := ATimeSec;
    fHasScalarA := True;
  end
  else if ATag = fInputB then
  begin
    fScalarB := AValue;
    fScalarTimeB := ATimeSec;
    fHasScalarB := True;
  end;
  if not (fHasScalarA and fHasScalarB) then
    Exit;
  { Два скалярных источника публикуются последовательно. Результат получает
    более позднюю отметку и использует последние доступные значения обоих. }
  lTime := Max(fScalarTimeA, fScalarTimeB);
  fRegistry.PublishValue(fOutput, lTime, Calculate(fScalarA, fScalarB));
  fHasScalarA := False;
  fHasScalarB := False;
end;

procedure TRecorderArithmeticAlgorithm.EnsureCapacity(ACount: Integer);
begin
  if Length(fValuesA) >= ACount then
    Exit;
  SetLength(fTimesA, ACount);
  SetLength(fValuesA, ACount);
  SetLength(fTimesB, ACount);
  SetLength(fValuesB, ACount);
  SetLength(fOutputTimes, ACount);
  SetLength(fOutputValues, ACount);
end;

procedure TRecorderArithmeticAlgorithm.StoreBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
var
  I: Integer;
begin
  EnsureCapacity(ACount);
  if ATag = fInputA then
  begin
    for I := 0 to ACount - 1 do
    begin
      fTimesA[I] := ATimes[I];
      fValuesA[I] := AValues[I];
    end;
    fCountA := ACount;
    fHasA := True;
  end
  else if ATag = fInputB then
  begin
    for I := 0 to ACount - 1 do
    begin
      fTimesB[I] := ATimes[I];
      fValuesB[I] := AValues[I];
    end;
    fCountB := ACount;
    fHasB := True;
  end;
end;

function TRecorderArithmeticAlgorithm.Calculate(A, B: Double): Double;
begin
  case fOperation of
    raoSubtract: Result := A - B;
    raoMultiply: Result := A * B;
    raoDivide:
      if IsZero(B) then
        Result := 0
      else
        Result := A / B;
  else
    Result := A + B;
  end;
end;

procedure TRecorderArithmeticAlgorithm.CalculateReadyBlocks;
var
  I: Integer;
begin
  if not (fHasA and fHasB) then
    Exit;
  if fCountA <> fCountB then
  begin
    { Старый алгоритм также обрабатывал только равные по длине синхронные блоки. }
    fHasA := False;
    fHasB := False;
    Exit;
  end;
  for I := 0 to fCountA - 1 do
  begin
    fOutputTimes[I] := fTimesA[I];
    fOutputValues[I] := Calculate(fValuesA[I], fValuesB[I]);
  end;
  fHasA := False;
  fHasB := False;
  fRegistry.PublishBlock(fOutput.Name, fOutputTimes, fOutputValues, fCountA, True);
end;

procedure TRecorderArithmeticAlgorithm.DoEvalBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
begin
  if (ACount <= 0) or (ACount > Length(ATimes)) or
    (ACount > Length(AValues)) then
    Exit;
  StoreBlock(ATag, ATimes, AValues, ACount);
  CalculateReadyBlocks;
end;

{ TRecorderCounterAlgorithm }

constructor TRecorderCounterAlgorithm.Create;
begin
  inherited Create;
  fLowThreshold := 30;
  fHighThreshold := 70;
  fRelativeThresholds := True;
  Properties := 'Hi=70;Lo=30;Relative=1;MinThreshold=0;SaveVal=0';
end;

class function TRecorderCounterAlgorithm.AlgorithmTypeName: string;
begin
  Result := 'Counter';
end;

procedure TRecorderCounterAlgorithm.ReadProperties;
begin
  fLowThreshold := PropertyFloat(Properties, 'Lo', 30);
  fHighThreshold := PropertyFloat(Properties, 'Hi', 70);
  fMinimumAmplitude := Max(0, PropertyFloat(Properties, 'MinThreshold', 0));
  fRelativeThresholds := PropertyBoolean(Properties, 'Relative', True);
  fKeepValueOnStart := PropertyBoolean(Properties, 'SaveVal', False);
  fOutputName := PropertyValue(Properties, 'OutChannel', '');
end;

procedure TRecorderCounterAlgorithm.ResolveBindings;
var
  I: Integer;
  lBinding: TRecorderAlgorithmBinding;
  lRole: string;
  lTag: TRecorderTag;
begin
  fInput := nil;
  fGate := nil;
  fReset := nil;
  fShift := nil;
  for I := 0 to BindingCount - 1 do
  begin
    lBinding := Binding(I);
    lTag := fRegistry.FindById(lBinding.TagId);
    lRole := LowerCase(PropertyValue(lBinding.Properties, 'Role', ''));
    if (I = 0) and (lRole = '') then
      fInput := lTag
    else if (lRole = 'gate') or (lRole = 'trig') then
      fGate := lTag
    else if (lRole = 'reset') or (lRole = 'null') then
      fReset := lTag
    else if lRole = 'shift' then
      fShift := lTag;
  end;
end;

procedure TRecorderCounterAlgorithm.LinkTags(ATagRegistry: TRecorderTagRegistry);
begin
  inherited LinkTags(ATagRegistry);
  fRegistry := ATagRegistry;
  fOutput := nil;
  if fRegistry = nil then
    Exit;
  ResolveBindings;
  if fInput = nil then
  begin
    SetReady(False, 'Не найден входной тег счетчика');
    Exit;
  end;
  ReadProperties;
  if fOutputName = '' then
    fOutputName := fInput.Name + '_cnt';
  fOutput := fRegistry.FindByName(fOutputName);
  if fOutput = nil then
    fOutput := fRegistry.CreateTag(fOutputName, 4096, True);
  if fOutput = fInput then
  begin
    SetReady(False, 'Выход счетчика совпадает со входом');
    Exit;
  end;
  fOutput.PollFrequencyHz := fInput.PollFrequencyHz;
  fOutput.UnitName := 'count';
  SetReady(True);
end;

procedure TRecorderCounterAlgorithm.PrepareConfiguration;
begin
  ReadProperties;
  SetReady(BindingCount > 0, 'Счетчику нужен входной тег');
end;

procedure TRecorderCounterAlgorithm.DoStart;
begin
  if not fKeepValueOnStart then
    fCounter := 0;
  fState := 0;
  fHasResetValue := False;
end;

function TRecorderCounterAlgorithm.AcceptsTag(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and ((ATag = fInput) or (ATag = fGate) or
    (ATag = fReset) or (ATag = fShift));
end;

procedure TRecorderCounterAlgorithm.EnsureCapacity(ACount: Integer);
begin
  if Length(fOutputValues) >= ACount then
    Exit;
  SetLength(fOutputTimes, ACount);
  SetLength(fOutputValues, ACount);
end;

procedure TRecorderCounterAlgorithm.UpdateAuxiliaryValue(ATag: TRecorderTag;
  const AValues: array of Double; ACount: Integer);
var
  lValue: Double;
begin
  lValue := MeanValue(AValues, ACount);
  if ATag = fGate then
    fGateValue := lValue
  else if ATag = fShift then
    fShiftValue := lValue
  else if ATag = fReset then
  begin
    fResetValue := lValue;
    if fHasResetValue and not SameValue(fResetValue, fPreviousResetValue) then
      fCounter := 0;
    fPreviousResetValue := fResetValue;
    fHasResetValue := True;
  end;
end;

procedure TRecorderCounterAlgorithm.CalculateThresholds(
  const AValues: array of Double; ACount: Integer; out ALow, AHigh,
  AAmplitude: Double);
var
  I: Integer;
  lMinimum, lMaximum, lMean: Double;
begin
  lMinimum := AValues[0];
  lMaximum := AValues[0];
  lMean := 0;
  for I := 0 to ACount - 1 do
  begin
    lMinimum := Min(lMinimum, AValues[I]);
    lMaximum := Max(lMaximum, AValues[I]);
    lMean := lMean + AValues[I];
  end;
  lMean := lMean / ACount;
  AAmplitude := (lMaximum - lMinimum) / 2;
  if fRelativeThresholds then
  begin
    ALow := lMean + AAmplitude * (0.02 * fLowThreshold - 1);
    AHigh := lMean + AAmplitude * (0.02 * fHighThreshold - 1);
  end
  else
  begin
    ALow := fLowThreshold;
    AHigh := fHighThreshold;
  end;
end;

procedure TRecorderCounterAlgorithm.CountBlock(const ATimes,
  AValues: array of Double; ACount: Integer);
var
  I: Integer;
  lLow, lHigh, lAmplitude: Double;
begin
  EnsureCapacity(ACount);
  CalculateThresholds(AValues, ACount, lLow, lHigh, lAmplitude);
  for I := 0 to ACount - 1 do
  begin
    fOutputTimes[I] := ATimes[I];
    if (fGate = nil) or not IsZero(fGateValue) then
      case fState of
        0:
          if AValues[I] > lLow then
            fState := 1;
        1:
          if AValues[I] < lLow then
            fState := 0
          else if AValues[I] > lHigh then
            fState := 2;
        2:
          if AValues[I] < lLow then
          begin
            if lAmplitude > fMinimumAmplitude then
              if fCounter >= CCounterMaximum then
                fCounter := 0
              else
                Inc(fCounter);
            fState := 0;
          end;
      end;
    fOutputValues[I] := fCounter + Round(fShiftValue);
  end;
  fRegistry.PublishBlock(fOutput.Name, fOutputTimes, fOutputValues, ACount, True);
end;

procedure TRecorderCounterAlgorithm.DoEvalValue(ATag: TRecorderTag; ATimeSec,
  AValue: Double);
begin
  if ATag <> fInput then
    UpdateAuxiliaryValue(ATag, [AValue], 1)
  else
    CountBlock([ATimeSec], [AValue], 1);
end;

procedure TRecorderCounterAlgorithm.DoEvalBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
begin
  if (ACount <= 0) or (ACount > Length(ATimes)) or
    (ACount > Length(AValues)) then
    Exit;
  if ATag = fInput then
    CountBlock(ATimes, AValues, ACount)
  else
    UpdateAuxiliaryValue(ATag, AValues, ACount);
end;

end.
