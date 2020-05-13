unit cplxfft2;
 
interface
 
type
  PScalar = ^TScalar;
  TScalar = Extended;
 
  PScalars = ^TScalars;
  TScalars = array[0..High(Integer) div SizeOf(TScalar) - 1] of TScalar;
 
const
  TrigTableDepth : word = 0;
  CosTable : PScalars = NIL;
  SinTable : PScalars = NIL;
 
procedure InitTrigTables(Depth : Word);
 
procedure FFT(Depth : Word; SrcR, SrcI : PScalars; DestR, DestI : PScalars);
 
{ѕеред вызовом Src и Dest “–≈Ѕ”≈“—я распределение (integer(1) shl Depth) * SizeOf(TScalar) байт пам€ти!}
 
implementation
 
procedure DoFFT(Depth : Word; SrcR, SrcI : PScalars; SrcSpacing : Word;
 DestR, DestI : PScalars);
{рекурсивна€ часть, вызываема€ при готовности FFT}
var
  J, N : Integer;
  TempR, TempI : TScalar;
  Sh : Word;
  c, s : Extended;
begin
  if Depth = 0 then
  begin
    DestR^[0] := SrcR^[0];
    DestI^[0] := SrcI^[0];
    Exit;
  end;
 
  N := Integer(1) shl (Depth - 1);
 
  DoFFT(Depth - 1, SrcR, SrcI, SrcSpacing * 2, DestR, DestI);
  DoFFT(Depth - 1, @SrcR^[srcSpacing], @SrcI^[SrcSpacing], SrcSpacing * 2, @DestR^[N], @DestI^[N]);
 
  Sh := TrigTableDepth - Depth;
 
  for J := 0 to N - 1 do
  begin
    c := CosTable^[J shl Sh];
    s := SinTable^[J shl Sh];
 
    TempR := c * DestR^[J + N] - s * DestI^[J + N];
    TempI := c * DestI^[J + N] + s * DestR^[J + N];
 
    DestR^[J + N] := DestR^[J] - TempR;
    DestI^[J + N] := DestI^[J] - TempI;
 
    DestR^[J] := DestR^[J] + TempR;
    DestI^[J] := DestI^[J] + TempI;
  end;
end;
 
procedure FFT(Depth : Word; SrcR, SrcI : PScalars; DestR, DestI : PScalars);
var
  J, N : Integer;
  Normalizer : Extended;
begin
  N := Integer(1) shl Depth;
 
  if Depth TrigTableDepth then
    InitTrigTables(Depth);
 
  DoFFT(Depth, SrcR, SrcI, 1, DestR, DestI);
 
  Normalizer := 1 / sqrt(N);
 
  for J := 0 to N - 1 do
  begin
    DestR^[J] := DestR^[J] * Normalizer;
    DestI^[J] := DestI^[J] * Normalizer;
  end;
end;
 
procedure InitTrigTables(Depth : Word);
var
  J, N : Integer;
begin
  N := Integer(1) shl Depth;
  ReAllocMem(CosTable, N * SizeOf(TScalar));
  ReAllocMem(SinTable, N * SizeOf(TScalar));
 
  for J := 0 to N - 1 do
  begin
    CosTable^[J] := cos(-(2 * Pi) * J / N);
    SinTable^[J] := sin(-(2 * Pi) * J / N);
  end;
  TrigTableDepth := Depth;
end;
 
finalization
  ReAllocMem(CosTable, 0);
  ReAllocMem(SinTable, 0);
 
end.
 
unit demofrm;
 
interface
 
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, cplxfft2, StdCtrls;
 
type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
var
  Form1: TForm1;
 
implementation
 
{$R *.DFM}
 
uses
  MMSystem;
 
procedure TForm1.Button1Click(Sender: TObject);
var
  SR, SI, DR, DI : PScalars;
  J, D, N : Integer;
  st, et : Longint;
  norm : Extended;
begin
  D := StrToIntDef(edit1.text, -1);
  if d < 1 then
    raise
      exception.Create('глубина рекурсии должны быть положительным целым числом');
 
  N := Integer(1) shl D;
 
  GetMem(SR, N * SizeOf(TScalar));
  GetMem(SI, N * SizeOf(TScalar));
  GetMem(DR, N * SizeOf(TScalar));
  GetMem(DI, N * SizeOf(TScalar));
 
  for J := 0 to N - 1 do
  begin
    SR^[J] := Random;
    SI^[J] := Random;
  end;
 
  st := TimeGetTime;
  FFT(D, SR, SI, DR, DI);
 
  et := TimeGetTime;
 
  memo1.Lines.Add('N = ' + inttostr(N));
  memo1.Lines.Add('норма ожидани€: ' + #9 + FloatToStr(N * 2 / 3));
 
  norm := 0;
  for J := 0 to N - 1 do
    norm := norm + SR^[J] * SR^[J] + SI^[J] * SI^[J];
  memo1.Lines.Add('норма данных: ' + #9 + FloatToStr(norm));
 
  norm := 0;
  for J := 0 to N - 1 do
    norm := norm + DR^[J] * DR^[J] + DI^[J] * DI^[J];
  memo1.Lines.Add('норма FT: ' + #9#9 + FloatToStr(norm));
 
  memo1.Lines.Add('¬рем€ расчета FFT: ' + #9 + inttostr(et - st));
  memo1.Lines.add('');
 
  FreeMem(SR, N * SizeOf(TScalar));
  FreeMem(SI, N * SizeOf(TScalar));
  FreeMem(DR, N * SizeOf(TScalar));
  FreeMem(DI, N * SizeOf(TScalar));
end;
 
end.