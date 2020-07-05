unit demfrm;

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs, cplxfft2, StdCtrls;

type

  TdemoFrm = class(TForm)
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

  demoFrm1: TdemoFrm;

implementation

{$R *.DFM}

uses MMSystem;

procedure TdemoFrm.Button1Click(Sender: TObject);
var
  SR, SI, DR, DI: PScalars;
  j, d, N: integer;
  st, et: longint;
  norm: extended;
begin

  d := StrToIntDef(edit1.text, -1);
  if d < 1 then
    raise
      exception.Create('глубина рекурсии должны быть положительным целым числом');

  N := integer(1) shl d;

  GetMem(SR, N * SizeOf(TScalar));
  GetMem(SI, N * SizeOf(TScalar));
  GetMem(DR, N * SizeOf(TScalar));
  GetMem(DI, N * SizeOf(TScalar));

  for j := 0 to N - 1 do
  begin

    SR^[j] := random;
    SI^[j] := random;
  end;

  st := timeGetTime;
  FFT(d, SR, SI, DR, DI);

  et := timeGetTime;

  memo1.Lines.Add('N = ' + inttostr(N));
  memo1.Lines.Add('норма ожидания: ' + #9 + FloatToStr(N * 2 / 3));

  norm := 0;
  for j := 0 to N - 1 do

    norm := norm + SR^[j] * SR^[j] + SI^[j] * SI^[j];
  memo1.Lines.Add('норма данных: ' + #9 + FloatToStr(norm));

  norm := 0;
  for j := 0 to N - 1 do

    norm := norm + DR^[j] * DR^[j] + DI^[j] * DI^[j];
  memo1.Lines.Add('норма FT: ' + #9#9 + FloatToStr(norm));

  memo1.Lines.Add('Время расчета FFT: ' + #9 + inttostr(et - st));
  memo1.Lines.add('');
  (*for j:=0 to N - 1 do

  Memo1.Lines.Add(FloatToStr(SR^[j])
  + ' + '
  + FloatToStr(SI^[j])
  + 'i');

  for j:=0 to N - 1 do

  Memo1.Lines.Add(FloatToStr(DR^[j])
  + ' + '
  + FloatToStr(DI^[j])
  + 'i');*)

  FreeMem(SR, N * SizeOf(TScalar));
  FreeMem(SI, N * SizeOf(TScalar));
  FreeMem(DR, N * SizeOf(TScalar));
  FreeMem(DI, N * SizeOf(TScalar));
end;

end.
