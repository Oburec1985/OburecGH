program RecorderHardwareMathTest;

{$mode delphi}{$H+}

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  Classes,
  SysUtils,
  LConvEncoding,
  uCommonTypes,
  complex,
  uHardwareMath,
  uRecorderSpectrumEngine;

var
  g_LogFile: TextFile;

procedure Log(const AText: string);
begin
  Writeln(AText);
  Writeln(g_LogFile, AText);
  Flush(g_LogFile);
end;

procedure AssertEquals(AActual, AExpected: Double; const AStep: string); overload; overload;
begin
  if Abs(AActual - AExpected) > 1e-9 then
    raise Exception.CreateFmt('%s: expected %f, got %f', [AStep, AExpected, AActual]);
end;

procedure AssertEquals(AActual, AExpected: Integer; const AStep: string); overload; overload;
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d', [AStep, AExpected, AActual]);
end;

// Замер времени (QueryPerformanceCounter)
function GetTimeUs: Int64;
var
  lFreq, lCount: Int64;
begin
  QueryPerformanceFrequency(lFreq);
  QueryPerformanceCounter(lCount);
  Result := (lCount * 1000000) div lFreq;
end;

procedure TestFillDouble;
const
  Count = 10007; // нечетное число для проверки остатка
var
  lArrPascal, lArrSSE, lArrAVX2: array of Double;
  I: Integer;
  lStart, lTimeP, lTimeS, lTimeA: Int64;
begin
  SetLength(lArrPascal, Count);
  SetLength(lArrSSE, Count);
  SetLength(lArrAVX2, Count);

  // 1. Проверка корректности
  FillDouble_Pascal(@lArrPascal[0], Count, 3.14);
  FillDouble_SSE(@lArrSSE[0], Count, 3.14);
  FillDouble_AVX2(@lArrAVX2[0], Count, 3.14);

  for I := 0 to Count - 1 do
  begin
    AssertEquals(lArrSSE[I], lArrPascal[I], Format('FillDouble SSE corr at %d', [I]));
    AssertEquals(lArrAVX2[I], lArrPascal[I], Format('FillDouble AVX2 corr at %d', [I]));
  end;

  // 2. Бенчмарк (100 000 итераций)
  lStart := GetTimeUs;
  for I := 1 to 100000 do
    FillDouble_Pascal(@lArrPascal[0], Count, 5.5);
  lTimeP := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    FillDouble_SSE(@lArrSSE[0], Count, 5.5);
  lTimeS := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    FillDouble_AVX2(@lArrAVX2[0], Count, 5.5);
  lTimeA := GetTimeUs - lStart;

  Log(Format('FillDouble (%d elements, 100k runs):', [Count]));
  Log(Format('  Pascal: %d us', [lTimeP]));
  Log(Format('  SSE:    %d us (%.2fx speedup)', [lTimeS, lTimeP / lTimeS]));
  Log(Format('  AVX2:   %d us (%.2fx speedup)', [lTimeA, lTimeP / lTimeA]));
end;

procedure TestAddArrays;
const
  Count = 10007;
var
  lA, lB, lC_P, lC_S, lC_A: array of Double;
  I: Integer;
  lStart, lTimeP, lTimeS, lTimeA: Int64;
  lPtrA, lPtrB, lPtrC: PDouble;
begin
  SetLength(lA, Count);
  SetLength(lB, Count);
  SetLength(lC_P, Count);
  SetLength(lC_S, Count);
  SetLength(lC_A, Count);

  for I := 0 to Count - 1 do
  begin
    lA[I] := I * 1.5;
    lB[I] := I * 0.25;
  end;

  lPtrA := @lA[0];
  lPtrB := @lB[0];
  
  lPtrC := @lC_P[0];
  AddArrays_Pascal(lPtrA, lPtrB, lPtrC, Count);
  
  lPtrC := @lC_S[0];
  AddArrays_SSE(lPtrA, lPtrB, lPtrC, Count);
  
  lPtrC := @lC_A[0];
  AddArrays_AVX2(lPtrA, lPtrB, lPtrC, Count);

  for I := 0 to Count - 1 do
  begin
    AssertEquals(lC_S[I], lC_P[I], Format('AddArrays SSE corr at %d', [I]));
    AssertEquals(lC_A[I], lC_P[I], Format('AddArrays AVX2 corr at %d', [I]));
  end;

  lStart := GetTimeUs;
  lPtrC := @lC_P[0];
  for I := 1 to 100000 do
    AddArrays_Pascal(lPtrA, lPtrB, lPtrC, Count);
  lTimeP := GetTimeUs - lStart;

  lStart := GetTimeUs;
  lPtrC := @lC_S[0];
  for I := 1 to 100000 do
    AddArrays_SSE(lPtrA, lPtrB, lPtrC, Count);
  lTimeS := GetTimeUs - lStart;

  lStart := GetTimeUs;
  lPtrC := @lC_A[0];
  for I := 1 to 100000 do
    AddArrays_AVX2(lPtrA, lPtrB, lPtrC, Count);
  lTimeA := GetTimeUs - lStart;

  Log(Format('AddArrays (%d elements, 100k runs):', [Count]));
  Log(Format('  Pascal: %d us', [lTimeP]));
  Log(Format('  SSE:    %d us (%.2fx speedup)', [lTimeS, lTimeP / lTimeS]));
  Log(Format('  AVX2:   %d us (%.2fx speedup)', [lTimeA, lTimeP / lTimeA]));
end;

procedure TestSubtractFromArray;
const
  Count = 10007;
var
  lA_P, lA_S, lA_A: TDoubleArray;
  I: Integer;
  lStart, lTimeP, lTimeS, lTimeA: Int64;
begin
  SetLength(lA_P, Count);
  SetLength(lA_S, Count);
  SetLength(lA_A, Count);

  for I := 0 to Count - 1 do
  begin
    lA_P[I] := I * 2.5;
    lA_S[I] := I * 2.5;
    lA_A[I] := I * 2.5;
  end;

  SubtractFromArray_Pascal(lA_P, 42.1);
  SubtractFromArray_SSE(lA_S, 42.1);
  SubtractFromArray_AVX2(lA_A, 42.1);

  for I := 0 to Count - 1 do
  begin
    AssertEquals(lA_S[I], lA_P[I], Format('Subtract SSE corr at %d', [I]));
    AssertEquals(lA_A[I], lA_P[I], Format('Subtract AVX2 corr at %d', [I]));
  end;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    SubtractFromArray_Pascal(lA_P, 5.0);
  lTimeP := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    SubtractFromArray_SSE(lA_S, 5.0);
  lTimeS := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    SubtractFromArray_AVX2(lA_A, 5.0);
  lTimeA := GetTimeUs - lStart;

  Log(Format('SubtractFromArray (%d elements, 100k runs):', [Count]));
  Log(Format('  Pascal: %d us', [lTimeP]));
  Log(Format('  SSE:    %d us (%.2fx speedup)', [lTimeS, lTimeP / lTimeS]));
  Log(Format('  AVX2:   %d us (%.2fx speedup)', [lTimeA, lTimeP / lTimeA]));
end;

procedure TestConjugateComplex;
const
  Count = 5003;
var
  lA_P, lA_S, lA_A: TCmxArray_d;
  I: Integer;
  lStart, lTimeP, lTimeS, lTimeA: Int64;
begin
  SetLength(lA_P, Count);
  SetLength(lA_S, Count);
  SetLength(lA_A, Count);

  for I := 0 to Count - 1 do
  begin
    lA_P[I].Re := I * 1.1; lA_P[I].Im := I * 2.2;
    lA_S[I].Re := I * 1.1; lA_S[I].Im := I * 2.2;
    lA_A[I].Re := I * 1.1; lA_A[I].Im := I * 2.2;
  end;

  ConjugateComplex_Pascal(lA_P);
  ConjugateComplex_SSE(lA_S);
  ConjugateComplex_AVX2(lA_A);

  for I := 0 to Count - 1 do
  begin
    AssertEquals(lA_S[I].Re, lA_P[I].Re, Format('Conjugate SSE Re corr at %d', [I]));
    AssertEquals(lA_S[I].Im, lA_P[I].Im, Format('Conjugate SSE Im corr at %d', [I]));
    AssertEquals(lA_A[I].Re, lA_P[I].Re, Format('Conjugate AVX2 Re corr at %d', [I]));
    AssertEquals(lA_A[I].Im, lA_P[I].Im, Format('Conjugate AVX2 Im corr at %d', [I]));
  end;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    ConjugateComplex_Pascal(lA_P);
  lTimeP := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    ConjugateComplex_SSE(lA_S);
  lTimeS := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 100000 do
    ConjugateComplex_AVX2(lA_A);
  lTimeA := GetTimeUs - lStart;

  Log(Format('ConjugateComplex (%d elements, 100k runs):', [Count]));
  Log(Format('  Pascal: %d us', [lTimeP]));
  Log(Format('  SSE:    %d us (%.2fx speedup)', [lTimeS, lTimeP / lTimeS]));
  Log(Format('  AVX2:   %d us (%.2fx speedup)', [lTimeA, lTimeP / lTimeA]));
end;

procedure TestComplexMultiply;
const
  Count = 5003;
var
  lA, lB, lC_P, lC_S, lC_A: TCmxArray_d;
  I: Integer;
  lStart, lTimeP, lTimeS, lTimeA: Int64;
begin
  SetLength(lA, Count);
  SetLength(lB, Count);
  SetLength(lC_P, Count);
  SetLength(lC_S, Count);
  SetLength(lC_A, Count);

  for I := 0 to Count - 1 do
  begin
    lA[I].Re := I * 0.5; lA[I].Im := I * 0.8;
    lB[I].Re := I * 1.2; lB[I].Im := -I * 0.3;
  end;

  ComplexMultiply_Pascal(lA, lB, lC_P);
  ComplexMultiply_SSE(lA, lB, lC_S);
  ComplexMultiply_AVX2(lA, lB, lC_A);

  for I := 0 to Count - 1 do
  begin
    AssertEquals(lC_S[I].Re, lC_P[I].Re, Format('ComplexMult SSE Re corr at %d', [I]));
    AssertEquals(lC_S[I].Im, lC_P[I].Im, Format('ComplexMult SSE Im corr at %d', [I]));
    AssertEquals(lC_A[I].Re, lC_P[I].Re, Format('ComplexMult AVX2 Re corr at %d', [I]));
    AssertEquals(lC_A[I].Im, lC_P[I].Im, Format('ComplexMult AVX2 Im corr at %d', [I]));
  end;

  lStart := GetTimeUs;
  for I := 1 to 50000 do
    ComplexMultiply_Pascal(lA, lB, lC_P);
  lTimeP := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 50000 do
    ComplexMultiply_SSE(lA, lB, lC_S);
  lTimeS := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 50000 do
    ComplexMultiply_AVX2(lA, lB, lC_A);
  lTimeA := GetTimeUs - lStart;

  Log(Format('ComplexMultiply (%d elements, 50k runs):', [Count]));
  Log(Format('  Pascal: %d us', [lTimeP]));
  Log(Format('  SSE:    %d us (%.2fx speedup)', [lTimeS, lTimeP / lTimeS]));
  Log(Format('  AVX2:   %d us (%.2fx speedup)', [lTimeA, lTimeP / lTimeA]));
end;

procedure TestEvalSpmMag;
const
  Count = 1024; // размер FFT
var
  lIn: TCmxArray_d;
  lOut_P, lOut_S, lOut_A: TDoubleArray;
  I: Integer;
  lStart, lTimeP, lTimeS, lTimeA: Int64;
begin
  SetLength(lIn, Count);
  SetLength(lOut_P, Count div 2);
  SetLength(lOut_S, Count div 2);
  SetLength(lOut_A, Count div 2);

  for I := 0 to Count - 1 do
  begin
    lIn[I].Re := sin(I * 0.1);
    lIn[I].Im := cos(I * 0.1);
  end;

  EvalSpmMag_Pascal(lIn, lOut_P);
  EvalSpmMag_SSE(lIn, lOut_S);
  EvalSpmMag_AVX2(lIn, lOut_A);

  for I := 0 to (Count div 2) - 1 do
  begin
    AssertEquals(lOut_S[I], lOut_P[I], Format('EvalSpmMag SSE corr at %d', [I]));
    AssertEquals(lOut_A[I], lOut_P[I], Format('EvalSpmMag AVX2 corr at %d', [I]));
  end;

  lStart := GetTimeUs;
  for I := 1 to 200000 do
    EvalSpmMag_Pascal(lIn, lOut_P);
  lTimeP := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 200000 do
    EvalSpmMag_SSE(lIn, lOut_S);
  lTimeS := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 200000 do
    EvalSpmMag_AVX2(lIn, lOut_A);
  lTimeA := GetTimeUs - lStart;

  Log(Format('EvalSpmMag (FFT %d, 200k runs):', [Count]));
  Log(Format('  Pascal: %d us', [lTimeP]));
  Log(Format('  SSE:    %d us (%.2fx speedup)', [lTimeS, lTimeP / lTimeS]));
  Log(Format('  AVX2:   %d us (%.2fx speedup)', [lTimeA, lTimeP / lTimeA]));
end;

procedure TestNormalizeAndScaleSpmMag;
const
  Count = 1024;
var
  lIn: TCmxArray_d;
  lOut_P, lOut_S, lOut_A: TDoubleArray;
  I: Integer;
  lStart, lTimeP, lTimeS, lTimeA: Int64;
begin
  SetLength(lIn, Count);
  SetLength(lOut_P, Count div 2);
  SetLength(lOut_S, Count div 2);
  SetLength(lOut_A, Count div 2);

  for I := 0 to Count - 1 do
  begin
    lIn[I].Re := sin(I * 0.05) * 5.0;
    lIn[I].Im := cos(I * 0.05) * 5.0;
  end;

  NormalizeAndScaleSpmMag_Pascal(lIn, lOut_P);
  NormalizeAndScaleSpmMag_SSE(lIn, lOut_S);
  NormalizeAndScaleSpmMag_AVX2(lIn, lOut_A);

  for I := 0 to (Count div 2) - 1 do
  begin
    AssertEquals(lOut_S[I], lOut_P[I], Format('Normalize SSE corr at %d', [I]));
    AssertEquals(lOut_A[I], lOut_P[I], Format('Normalize AVX2 corr at %d', [I]));
  end;

  lStart := GetTimeUs;
  for I := 1 to 200000 do
    NormalizeAndScaleSpmMag_Pascal(lIn, lOut_P);
  lTimeP := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 200000 do
    NormalizeAndScaleSpmMag_SSE(lIn, lOut_S);
  lTimeS := GetTimeUs - lStart;

  lStart := GetTimeUs;
  for I := 1 to 200000 do
    NormalizeAndScaleSpmMag_AVX2(lIn, lOut_A);
  lTimeA := GetTimeUs - lStart;

  Log(Format('NormalizeAndScaleSpmMag (FFT %d, 200k runs):', [Count]));
  Log(Format('  Pascal: %d us', [lTimeP]));
  Log(Format('  SSE:    %d us (%.2fx speedup)', [lTimeS, lTimeP / lTimeS]));
  Log(Format('  AVX2:   %d us (%.2fx speedup)', [lTimeA, lTimeP / lTimeA]));
end;

type
  TTestSpectrumReceiver = class
  private
    fFrameCount: Integer;
    fLastFrame: TRecorderSpectrumFrame;
  public
    procedure OnSpectrumFrame(ASender: TObject; const AFrame: TRecorderSpectrumFrame);
    property FrameCount: Integer read fFrameCount;
    property LastFrame: TRecorderSpectrumFrame read fLastFrame;
  end;

procedure TTestSpectrumReceiver.OnSpectrumFrame(ASender: TObject; const AFrame: TRecorderSpectrumFrame);
begin
  Inc(fFrameCount);
  fLastFrame.SourceTagName := AFrame.SourceTagName;
  fLastFrame.FrameIndex := AFrame.FrameIndex;
  fLastFrame.StartTimeSec := AFrame.StartTimeSec;
  fLastFrame.EndTimeSec := AFrame.EndTimeSec;
  fLastFrame.SampleRateHz := AFrame.SampleRateHz;
  fLastFrame.FFTSize := AFrame.FFTSize;
  fLastFrame.Bins := AFrame.Bins;
  fLastFrame.FrequencyStepHz := AFrame.FrequencyStepHz;
  
  SetLength(fLastFrame.Rms, Length(AFrame.Rms));
  if Length(AFrame.Rms) > 0 then
    Move(AFrame.Rms[0], fLastFrame.Rms[0], Length(AFrame.Rms) * SizeOf(Double));
    
  SetLength(fLastFrame.PhaseRad, Length(AFrame.PhaseRad));
  if Length(AFrame.PhaseRad) > 0 then
    Move(AFrame.PhaseRad[0], fLastFrame.PhaseRad[0], Length(AFrame.PhaseRad) * SizeOf(Double));
end;

procedure TestSpectrumFFT;
const
  FFT_SIZE = 1024;
  SAMPLE_RATE = 1000.0;
  SIGNAL_FREQ = 100.0; // 100 Гц
var
  lSettings: TRecorderSpectrumSettings;
  lChannel: TRecorderSpectrumChannel;
  lReceiver: TTestSpectrumReceiver;
  lTimes, lValues: array of Double;
  I, lMaxBin: Integer;
  lMaxVal, lFreq: Double;
begin
  Log('--- Тест вычислений спектра (FFT) ---');
  
  // 1. Инициализация настроек
  lSettings.SetDefaults;
  lSettings.FFTSize := FFT_SIZE;
  lSettings.SampleRateHz := SAMPLE_RATE;
  lSettings.WindowKind := swkHann;
  lSettings.NormalizeMode := snmNone;
  lSettings.KeepPhase := True;
  lSettings.Validate;

  // 2. Создание канала спектрального анализа и приемника кадров
  lReceiver := TTestSpectrumReceiver.Create;
  lChannel := TRecorderSpectrumChannel.Create('TestTag', lSettings);
  try
    lChannel.OnFrame := lReceiver.OnSpectrumFrame;

    // Генерируем синусоидальный сигнал 100 Гц длительностью 2.0 секунды
    // При частоте дискретизации 1000 Гц это 2000 отсчетов
    SetLength(lTimes, 2000);
    SetLength(lValues, 2000);
    for I := 0 to 1999 do
    begin
      lTimes[I] := I / SAMPLE_RATE;
      lValues[I] := sin(2.0 * Pi * SIGNAL_FREQ * lTimes[I]);
    end;

    // 3. Передаем данные порциями в канал (эмулируем поток данных)
    // Передаем порциями по 250 отсчетов
    for I := 0 to 7 do
    begin
      lChannel.FeedSamples(
        Copy(lTimes, I * 250, 250),
        Copy(lValues, I * 250, 250),
        250
      );
    end;

    // С размером FFT = 1024 и без перекрытия, из 2000 отсчетов должно
    // сформироваться ровно 1 полный кадр (1024 отсчета). Оставшиеся 976 отсчетов
    // будут ожидать следующей порции в буфере.
    AssertEquals(lReceiver.FrameCount, 1, 'Количество сформированных кадров');
    AssertEquals(lChannel.PendingCount, 2000 - 1024, 'Количество отсчетов в буфере ожидания');

    // 4. Проверка характеристик сформированного спектрального кадра
    AssertEquals(lReceiver.LastFrame.Bins, FFT_SIZE div 2, 'Количество спектральных бинов');
    if Abs(lReceiver.LastFrame.FrequencyStepHz - (SAMPLE_RATE / FFT_SIZE)) > 1e-9 then
      raise Exception.Create('Некорректный шаг по частоте');

    // Ищем пиковую частоту в рассчитанном спектре
    lMaxVal := -1.0;
    lMaxBin := -1;
    for I := 0 to lReceiver.LastFrame.Bins - 1 do
    begin
      if lReceiver.LastFrame.Rms[I] > lMaxVal then
      begin
        lMaxVal := lReceiver.LastFrame.Rms[I];
        lMaxBin := I;
      end;
    end;

    // Рассчитываем частоту пика
    lFreq := lMaxBin * lReceiver.LastFrame.FrequencyStepHz;
    Log(Format('  Найден пик на частоте: %.2f Гц (Бин %d, Амплитуда %.4f)', 
      [lFreq, lMaxBin, lMaxVal]));

    // Ожидаемый бин для 100 Гц при шаге 0.9765625 Гц: 100 / 0.9765625 = 102.4 -> 102
    AssertEquals(lMaxBin, 102, 'Номер бина пиковой частоты');

    // Проверяем, что пиковая частота близка к 100 Гц
    if Abs(lFreq - SIGNAL_FREQ) > lReceiver.LastFrame.FrequencyStepHz then
      raise Exception.CreateFmt('Частота пика %.2f Гц отличается от заданной %.2f Гц', 
        [lFreq, SIGNAL_FREQ]);

    // 5. Проверяем работу метода Clear (очистка буфера)
    lChannel.Clear;
    AssertEquals(lChannel.PendingCount, 0, 'Буфер канала после Clear');

    Log('  Тест расчетов спектра успешно пройден!');
  finally
    lChannel.Free;
    lReceiver.Free;
  end;
end;

begin
  Writeln('Program started!');
  AssignFile(g_LogFile, 'logfile.log');
  Rewrite(g_LogFile);
  try
    Log('=== Running HardwareMath Performance Tests ===');
    Log(Format('CPU AVX2 Supported: %s', [BoolToStr(IsAVX2supported and OSEnabledXmmYmm, True)]));
    Log('');

    TestFillDouble;
    Log('');
    TestAddArrays;
    Log('');
    TestSubtractFromArray;
    Log('');
    TestConjugateComplex;
    Log('');
    TestComplexMultiply;
    Log('');
    TestEvalSpmMag;
    Log('');
    TestNormalizeAndScaleSpmMag;
    Log('');
    TestSpectrumFFT;

    Log('');
    Log('=== All HardwareMath tests passed successfully! ===');
  finally
    CloseFile(g_LogFile);
  end;
end.
