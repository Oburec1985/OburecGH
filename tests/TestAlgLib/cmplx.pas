unit cmplx;

interface
type

  PReal = ^TReal;
  TReal = extended;

  PComplex = ^TComplex;
  TComplex = record
    r: TReal;
    i: TReal;
  end;

function MakeComplex(x, y: TReal): TComplex;
function Sum(x, y: TComplex): TComplex;
function Difference(x, y: TComplex): TComplex;
function Product(x, y: TComplex): TComplex;
function TimesReal(x: TComplex; y: TReal): TComplex;
function PlusReal(x: TComplex; y: TReal): TComplex;
function EiT(t: TReal): TComplex;
function ComplexToStr(x: TComplex): string;
function AbsSquared(x: TComplex): TReal;

implementation

uses SysUtils;

function MakeComplex(x, y: TReal): TComplex;
begin

  with result do
  begin
    r := x;
    i := y;
  end;
end;

function Sum(x, y: TComplex): TComplex;
begin
  with result do
  begin

    r := x.r + y.r;
    i := x.i + y.i;
  end;
end;

function Difference(x, y: TComplex): TComplex;
begin
  with result do
  begin

    r := x.r - y.r;
    i := x.i - y.i;
  end;
end;

function EiT(t: TReal): TComplex;
begin
  with result do
  begin

    r := cos(t);
    i := sin(t);
  end;
end;

function Product(x, y: TComplex): TComplex;
begin
  with result do
  begin

    r := x.r * y.r - x.i * y.i;
    i := x.r * y.i + x.i * y.r;
  end;
end;

function TimesReal(x: TComplex; y: TReal): TComplex;
begin
  with result do
  begin

    r := x.r * y;
    i := x.i * y;
  end;
end;

function PlusReal(x: TComplex; y: TReal): TComplex;
begin
  with result do
  begin

    r := x.r + y;
    i := x.i;
  end;
end;

function ComplexToStr(x: TComplex): string;
begin
  result := FloatToStr(x.r)
    + ' + '
    + FloatToStr(x.i)
    + 'i';
end;

function AbsSquared(x: TComplex): TReal;
begin
  result := x.r * x.r + x.i * x.i;
end;

end.
