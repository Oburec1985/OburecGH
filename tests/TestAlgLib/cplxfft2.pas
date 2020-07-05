unit cplxfft2;

interface

type

  PScalar = ^TScalar;
  TScalar = extended;

  PScalars = ^TScalars;
  TScalars = array[0..High(integer) div SizeOf(TScalar) - 1]
    of TScalar;

const

  TrigTableDepth: word = 0;
  CosTable: PScalars = nil;
  SinTable: PScalars = nil;

procedure InitTrigTables(Depth: word);

procedure FFT(Depth: word;

  SrcR, SrcI: PScalars;
  DestR, DestI: PScalars);

{ѕеред вызовом Src и Dest “–≈Ѕ”≈“—я распределение

(integer(1) shl Depth) * SizeOf(TScalar)

байт пам€ти!}

implementation

procedure DoFFT(Depth: word;

  SrcR, SrcI: PScalars;
  SrcSpacing: word;
  DestR, DestI: PScalars);
{рекурсивна€ часть, вызываема€ при готовности FFT}
var
  j, N: integer;

  TempR, TempI: TScalar;
  Shift: word;
  c, s: extended;
begin
  if Depth = 0 then

  begin
    DestR^[0] := SrcR^[0];
    DestI^[0] := SrcI^[0];
    exit;
  end;

  N := integer(1) shl (Depth - 1);

  DoFFT(Depth - 1, SrcR, SrcI, SrcSpacing * 2, DestR, DestI);
  DoFFT(Depth - 1,

    @SrcR^[srcSpacing],
    @SrcI^[SrcSpacing],
    SrcSpacing * 2,
    @DestR^[N],
    @DestI^[N]);

  Shift := TrigTableDepth - Depth;

  for j := 0 to N - 1 do
  begin

    c := CosTable^[j shl Shift];
    s := SinTable^[j shl Shift];

    TempR := c * DestR^[j + N] - s * DestI^[j + N];
    TempI := c * DestI^[j + N] + s * DestR^[j + N];

    DestR^[j + N] := DestR^[j] - TempR;
    DestI^[j + N] := DestI^[j] - TempI;

    DestR^[j] := DestR^[j] + TempR;
    DestI^[j] := DestI^[j] + TempI;
  end;

end;

procedure FFT(Depth: word;

  SrcR, SrcI: PScalars;
  DestR, DestI: PScalars);
var
  j, N: integer;
  Normalizer: extended;
begin

  N := integer(1) shl depth;

  if Depth=TrigTableDepth then

    InitTrigTables(Depth);

  DoFFT(Depth, SrcR, SrcI, 1, DestR, DestI);

  Normalizer := 1 / sqrt(N);

  for j := 0 to N - 1 do

  begin
    DestR^[j] := DestR^[j] * Normalizer;
    DestI^[j] := DestI^[j] * Normalizer;
  end;

end;

procedure InitTrigTables(Depth: word);
var
  j, N: integer;
begin

  N := integer(1) shl depth;
  //ReAllocMem(CosTable, N * SizeOf(TScalar));
  //ReAllocMem(SinTable, N * SizeOf(TScalar));
  for j := 0 to N - 1 do

  begin
    CosTable^[j] := cos(-(2 * Pi) * j / N);
    SinTable^[j] := sin(-(2 * Pi) * j / N);
  end;
   //trigTableDepth := Depth;

end;

initialization

  ;

finalization

  //ReAllocMem(CosTable, 0);
  //ReAllocMem(SinTable, 0);

end.
