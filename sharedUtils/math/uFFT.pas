unit uFFT;

interface

type
  TArrayValues = array of Double;

// AVal - массив анализируемых данных, Nvl - длина массива, должна быть кратна степени 2.
// FTvl - массив полученных значений, Nft - длина массива, должна быть равна Nvl / 2 или меньше.
// возвращает амплитудлный спектр
procedure FFTAnalysis(var AVal, FTvl: TArrayValues; Nvl, Nft: Integer);
// преобразование окном ханнинга порции AVal. pCount - размер порции
// w(n):=0.5*(1-cos(2*pi*n/(N-1)));
procedure HanningWnd(var AVal: TArrayValues; pCount:integer);

const
  TwoPi = 6.283185307179586;
  spm_HanningWnd = 0;
  spm_sqrWnd = 1;


implementation

procedure HanningWnd(var AVal: TArrayValues; pCount:integer);
var
  I: Integer;
  cosArg:double;
begin
  // w(n):=0.5*(1-cos(2*pi*n/(N-1)));
  cosArg:=TwoPi/(pCount-1);
  for I := 0 to pCount - 1 do
  begin
    aval[i]:=aval[i]*0.5*(1-cos(cosArg*i));
  end;
end;


procedure FFTAnalysis(var AVal, FTvl: TArrayValues; Nvl, Nft: Integer);
var
  i, j, n, m, Mmax, Istp: Integer;
  Tmpr, Tmpi, Wtmp, Theta: Double;
  Wpr, Wpi, Wr, Wi: Double;
  Tmvl: TArrayValues;
begin
  n:= Nvl * 2;
  SetLength(Tmvl, n);

  for i:= 0 to Nvl-1 do begin
    j:= i * 2;
    Tmvl[j]:= 0;
    Tmvl[j+1]:= AVal[i];
  end;

  i:= 1; j:= 1;
  while i < n do begin
    if j > i then begin
      Tmpr:= Tmvl[i];
      Tmvl[i]:= Tmvl[j];
      Tmvl[j]:= Tmpr;
      Tmpr:= Tmvl[i+1];
      Tmvl[i+1]:=Tmvl[j+1];
      Tmvl[j+1]:= Tmpr;
    end;
    i:= i + 2;
    m:= Nvl;
    while (m >= 2) and (j > m) do
    begin
      j:= j - m; m:= m div 2;
    end;
    j:= j + m;
  end;

  Mmax:= 2;
  while n > Mmax do
  begin
    Theta:= -TwoPi / Mmax; Wpi:= Sin(Theta);
    Wtmp:= Sin(Theta / 2); Wpr:= Wtmp * Wtmp * 2;
    Istp:= Mmax * 2; Wr:= 1; Wi:= 0; m:= 1;

    while m < Mmax do
    begin
      i:= m; m:= m + 2; Tmpr:= Wr; Tmpi:= Wi;
      Wr:= Wr - Tmpr * Wpr - Tmpi * Wpi;
      Wi:= Wi + Tmpr * Wpi - Tmpi * Wpr;

      while i < n do
      begin
        j:= i + Mmax;
        Tmpr:= Wr * Tmvl[j] - Wi * Tmvl[j-1];
        Tmpi:= Wi * Tmvl[j] + Wr * Tmvl[j-1];

        Tmvl[j]:= Tmvl[i] - Tmpr; Tmvl[j-1]:= Tmvl[i-1] - Tmpi;
        Tmvl[i]:= Tmvl[i] + Tmpr; Tmvl[i-1]:= Tmvl[i-1] + Tmpi;
        i:= i + Istp;
      end;
    end;

    Mmax:= Istp;
  end;

  for i:= 0 to Nft-1 do
  begin
    j:= i * 2;
    FTvl[ i ]:= 2*Sqrt(Sqr(Tmvl[j]) + Sqr(Tmvl[j+1]))/Nvl;
    //FTvl[ i ]:= 2*Sqrt(Sqr(Tmvl[j]) + Sqr(Tmvl[j+1]));
  end;

  SetLength(Tmvl, 0);
end;


end.
