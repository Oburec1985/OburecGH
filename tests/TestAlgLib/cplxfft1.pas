unit cplxfft1;

interface

uses Cmplx;

type
  PScalar = ^TScalar;
  TScalar = TComplex; {Ћегко получаем преобразование в реальную величину}

  PScalars = ^TScalars;
  TScalars = array[0..High(integer) div SizeOf(TScalar) - 1]
    of TScalar;

const
  TrigTableDepth: word = 0;
  TrigTable: PScalars = nil;

procedure InitTrigTable(Depth: word);

procedure FFT(Depth: word;
  Src: PScalars;
  Dest: PScalars);

{ѕеред вызовом Src и Dest “–≈Ѕ”≈“—я распределение
(integer(1) shl Depth) * SizeOf(TScalar)
байт пам€ти!}

implementation

procedure DoFFT(Depth: word;
  Src: PScalars;
  SrcSpacing: word;
  Dest: PScalars);
{рекурсивна€ часть, вызываема€ при готовности FFT}
var
  j, N: integer;
  Temp: TScalar;
  Shift: word;
begin
  if Depth = 0 then
  begin
    Dest^[0] := Src^[0];
    exit;
  end;

  N := integer(1) shl (Depth - 1);

  DoFFT(Depth - 1, Src, SrcSpacing * 2, Dest);
  DoFFT(Depth - 1, @Src^[SrcSpacing], SrcSpacing * 2, @Dest^[N]);

  Shift := TrigTableDepth - Depth;

  for j := 0 to N - 1 do
  begin
    Temp := Product(TrigTable^[j shl Shift],
      Dest^[j + N]);
    Dest^[j + N] := Difference(Dest^[j], Temp);
    Dest^[j] := Sum(Dest^[j], Temp);
  end;
end;

procedure FFT(Depth: word;
  Src: PScalars;
  Dest: PScalars);
var
  j, N: integer;
  Normalizer: extended;
begin
  N := integer(1) shl depth;
  if Depth=TrigTableDepth then
    InitTrigTable(Depth);
  DoFFT(Depth, Src, 1, Dest);
  Normalizer := 1 / sqrt(N);
  for j := 0 to N - 1 do
    Dest^[j] := TimesReal(Dest^[j], Normalizer);
end;

procedure InitTrigTable(Depth: word);
var
  j, N: integer;
begin
  N := integer(1) shl depth;
  //ReAllocMem(TrigTable, N * SizeOf(TScalar));
  for j := 0 to N - 1 do

    TrigTable^[j] := EiT(-(2 * Pi) * j / N);
  //TrigTableDepth := Depth;
end;

initialization
  ;

finalization
  //ReAllocMem(TrigTable, 0);

end.
