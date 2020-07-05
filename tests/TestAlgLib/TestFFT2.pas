unit TestFFT2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uComplex, PerformanceTime;

type
  TTestFFTFrm = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;

  private

  public
    procedure DFT(var D: TCmxArray);
    procedure Calcculate;
    procedure draw;
  end;

var
  TestFFTFrm: TTestFFTFrm;
  Sampl:TCmxArray;

Const
  FCount = 4096;
  FCount_1 = FCount-1;
  FCountDiv2 = FCount div 2;
  MaxValue = 32000;



implementation

{$R *.dfm}

{ TTestFFTFrm }

procedure TTestFFTFrm.draw;
var
  I:Integer;
  my:Real;
begin
 Image1.Picture:=Nil;
 Image1.Canvas.Brush.Color:=clWhite;
 Image1.Canvas.FillRect(Rect(0,0,Image1.Width,Image1.Height));
 my:=Image1.Height/MaxValue; //масштабный коэффициент
 Image1.Canvas.Pen.Color:=clRed;
 for I:=0 to FCount_1 do
 begin
 Image1.Canvas.MoveTo(I,Image1.Height);
 Image1.Canvas.LineTo(I,Image1.Height-Round(Sampl[I].Re*my));
 end;
 //Проведем линию середины
 Image1.Canvas.Pen.Color:=clBlack;
 Image1.Canvas.MoveTo(FCountDiv2,Image1.Height);
 Image1.Canvas.LineTo(FCountDiv2,0);
end;procedure TTestFFTFrm.Calcculate;var
  Time:TPerformanceTime;
begin
  Time:=TPerformanceTime.Create;
  Time.Start;
  DFT(Sampl);
  Time.Stop;
  Memo1.Lines.Add('Время Расчета ДПФ = '+FloatToStr(Time.Delay)+' сек.');
  Time.Free;
end;procedure TTestFFTFrm.DFT(var D: TCmxArray);var
  I,J,Len,Len_1,LenDiv2,LenDiv2_1:Integer;
  TempAr:TCmxArray;
  wn:TComplex;
begin
  Len := Length(D);
  Len_1 := Len-1;
  LenDiv2 := Len div 2;
  LenDiv2_1 := LenDiv2 -1;
  SetLength(TempAr,LenDiv2);
  For I:=0 to LenDiv2_1 do
  begin
    TempAr[I]:=0;
    For J:=0 to Len_1 do
    begin
      wn.Re := 0;
      wn.Im := -2*Pi*I*J/Len;
      wn := exp(wn);
      TempAr[I]:=TempAr[I]+D[J]*wn;
    end;
  end;
  For I:=0 to LenDiv2_1 do
    D[I] := abs(TempAr[I])/LenDiv2;
  TempAr:=Nil;end;

end.
