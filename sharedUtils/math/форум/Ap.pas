unit Ap;
 
interface
 
uses Math;
 
 
// constants
 
const
    MachineEpsilon = 5E-16;
    MaxRealNumber = 1E300;
    MinRealNumber = 1E-300;
 
type
 
    Complex = record
        X, Y: Double;
    end;
 
    TInteger1DArray     = array of LongInt;
    TReal1DArray        = array of Double;
    TComplex1DArray     = array of Complex;
    TBoolean1DArray     = array of Boolean;
 
    TInteger2DArray     = array of array of LongInt;
    TReal2DArray        = array of array of Double;
    TComplex2DArray     = array of array of Complex;
    TBoolean2DArray     = array of array of Boolean;
 
 
/////////////////////////////////////////////////////////////////////////
// Functions/procedures
/////////////////////////////////////////////////////////////////////////
function AbsReal(X : Extended):Extended;
function AbsInt (I : Integer):Integer;
function RandomReal():Extended;
function RandomInteger(I : Integer):Integer;
function Sign(X:Extended):Integer;
 
function DynamicArrayCopy(const A: TInteger1DArray):TInteger1DArray;overload;
function DynamicArrayCopy(const A: TReal1DArray):TReal1DArray;overload;
function DynamicArrayCopy(const A: TComplex1DArray):TComplex1DArray;overload;
function DynamicArrayCopy(const A: TBoolean1DArray):TBoolean1DArray;overload;
 
function DynamicArrayCopy(const A: TInteger2DArray):TInteger2DArray;overload;
function DynamicArrayCopy(const A: TReal2DArray):TReal2DArray;overload;
function DynamicArrayCopy(const A: TComplex2DArray):TComplex2DArray;overload;
function DynamicArrayCopy(const A: TBoolean2DArray):TBoolean2DArray;overload;
 
function AbsComplex(const Z : Complex):Double;
function Conj(const Z : Complex):Complex;
function CSqr(const Z : Complex):Complex;
 
function C_Complex(const X : Double):Complex;
function C_Opposite(const Z : Complex):Complex;
function C_Add(const Z1 : Complex; const Z2 : Complex):Complex;
function C_Mul(const Z1 : Complex; const Z2 : Complex):Complex;
function C_AddR(const Z1 : Complex; const R : Double):Complex;
function C_MulR(const Z1 : Complex; const R : Double):Complex;
function C_Sub(const Z1 : Complex; const Z2 : Complex):Complex;
function C_SubR(const Z1 : Complex; const R : Double):Complex;
function C_RSub(const R : Double; const Z1 : Complex):Complex;
function C_Div(const Z1 : Complex; const Z2 : Complex):Complex;
function C_DivR(const Z1 : Complex; const R : Double):Complex;
function C_RDiv(const R : Double; const Z2 : Complex):Complex;
function C_Equal(const Z1 : Complex; const Z2 : Complex):Boolean;
function C_NotEqual(const Z1 : Complex; const Z2 : Complex):Boolean;
function C_EqualR(const Z1 : Complex; const R : Double):Boolean;
function C_NotEqualR(const Z1 : Complex; const R : Double):Boolean;
 
implementation
 
/////////////////////////////////////////////////////////////////////////
// Functions/procedures
/////////////////////////////////////////////////////////////////////////
function AbsReal(X : Extended):Extended;
begin
    Result := Abs(X);
end;
 
function AbsInt (I : Integer):Integer;
begin
    Result := Abs(I);
end;
 
function RandomReal():Extended;
begin
    Result := Random;
end;
 
function RandomInteger(I : Integer):Integer;
begin
    Result := Random(I);
end;
 
function Sign(X:Extended):Integer;
begin
    if X>0 then
        Result := 1
    else if X<0 then
        Result := -1
    else
        Result := 0;
end;
 
/////////////////////////////////////////////////////////////////////////
// dynamical arrays copying
/////////////////////////////////////////////////////////////////////////
function DynamicArrayCopy(const A: TInteger1DArray):TInteger1DArray;overload;
var
    I:  Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
        Result[i]:=A[i];
end;
 
function DynamicArrayCopy(const A: TReal1DArray):TReal1DArray;overload;
var
    I:  Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
        Result[i]:=A[i];
end;
 
function DynamicArrayCopy(const A: TComplex1DArray):TComplex1DArray;overload;
var
    I:  Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
        Result[i]:=A[i];
end;
 
function DynamicArrayCopy(const A: TBoolean1DArray):TBoolean1DArray;overload;
var
    I:  Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
        Result[i]:=A[i];
end;
 
function DynamicArrayCopy(const A: TInteger2DArray):TInteger2DArray;overload;
var
    I,J:    Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
    begin
        SetLength(Result[i], High(A[i])+1);
        for J:=Low(A[i]) to High(A[i]) do
            Result[I,J]:=A[I,J];
    end;
end;
 
function DynamicArrayCopy(const A: TReal2DArray):TReal2DArray;overload;
var
    I,J:    Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
    begin
        SetLength(Result[i], High(A[i])+1);
        for J:=Low(A[i]) to High(A[i]) do
            Result[I,J]:=A[I,J];
    end;
end;
 
function DynamicArrayCopy(const A: TComplex2DArray):TComplex2DArray;overload;
var
    I,J:    Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
    begin
        SetLength(Result[i], High(A[i])+1);
        for J:=Low(A[i]) to High(A[i]) do
            Result[I,J]:=A[I,J];
    end;
end;
 
function DynamicArrayCopy(const A: TBoolean2DArray):TBoolean2DArray;overload;
var
    I,J:    Integer;
begin
    SetLength(Result, High(A)+1);
    for I:=Low(A) to High(A) do
    begin
        SetLength(Result[i], High(A[i])+1);
        for J:=Low(A[i]) to High(A[i]) do
            Result[I,J]:=A[I,J];
    end;
end;
 
/////////////////////////////////////////////////////////////////////////
// complex numbers
/////////////////////////////////////////////////////////////////////////
function AbsComplex(const Z : Complex):Double;
var
    W : Double;
    XABS : Double;
    YABS : Double;
    V : Double;
begin
    XABS := AbsReal(Z.X);
    YABS := AbsReal(Z.Y);
    W := Max(XABS, YABS);
    V := Min(XABS, YABS);
    if V=0 then
    begin
        Result := W;
    end
    else
    begin
        Result := W*SQRT(1+Sqr(V/W));
    end;
end;
 
 
function Conj(const Z : Complex):Complex;
begin
    Result.X := Z.X;
    Result.Y := -Z.Y;
end;
 
 
function CSqr(const Z : Complex):Complex;
begin
    Result.X := Sqr(Z.X)-Sqr(Z.Y);
    Result.Y := 2*Z.X*Z.Y;
end;
 
 
function C_Complex(const X : Double):Complex;
begin
    Result.X := X;
    Result.Y := 0;
end;
 
 
function C_Opposite(const Z : Complex):Complex;
begin
    Result.X := -Z.X;
    Result.Y := -Z.Y;
end;
 
 
function C_Add(const Z1 : Complex; const Z2 : Complex):Complex;
begin
    Result.X := Z1.X+Z2.X;
    Result.Y := Z1.Y+Z2.Y;
end;
 
 
function C_Mul(const Z1 : Complex; const Z2 : Complex):Complex;
begin
    Result.X := Z1.X*Z2.X-Z1.Y*Z2.Y;
    Result.Y := Z1.X*Z2.Y+Z1.Y*Z2.X;
end;
 
 
function C_AddR(const Z1 : Complex; const R : Double):Complex;
begin
    Result.X := Z1.X+R;
    Result.Y := Z1.Y;
end;
 
 
function C_MulR(const Z1 : Complex; const R : Double):Complex;
begin
    Result.X := Z1.X*R;
    Result.Y := Z1.Y*R;
end;
 
 
function C_Sub(const Z1 : Complex; const Z2 : Complex):Complex;
begin
    Result.X := Z1.X-Z2.X;
    Result.Y := Z1.Y-Z2.Y;
end;
 
 
function C_SubR(const Z1 : Complex; const R : Double):Complex;
begin
    Result.X := Z1.X-R;
    Result.Y := Z1.Y;
end;
 
 
function C_RSub(const R : Double; const Z1 : Complex):Complex;
begin
    Result.X := R-Z1.X;
    Result.Y := -Z1.Y;
end;
 
 
function C_Div(const Z1 : Complex; const Z2 : Complex):Complex;
var
    A : Double;
    B : Double;
    C : Double;
    D : Double;
    E : Double;
    F : Double;
begin
    A := Z1.X;
    B := Z1.Y;
    C := Z2.X;
    D := Z2.Y;
    if AbsReal(D)<AbsReal(C) then
    begin
        E := D/C;
        F := C+D*E;
        Result.X := (A+B*E)/F;
        Result.Y := (B-A*E)/F;
    end
    else
    begin
        E := C/D;
        F := D+C*E;
        Result.X := (B+A*E)/F;
        Result.Y := (-A+B*E)/F;
    end;
end;
 
 
function C_DivR(const Z1 : Complex; const R : Double):Complex;
begin
    Result.X := Z1.X/R;
    Result.Y := Z1.Y/R;
end;
 
 
function C_RDiv(const R : Double; const Z2 : Complex):Complex;
var
    A : Double;
    C : Double;
    D : Double;
    E : Double;
    F : Double;
begin
    A := R;
    C := Z2.X;
    D := Z2.Y;
    if AbsReal(D)<AbsReal(C) then
    begin
        E := D/C;
        F := C+D*E;
        Result.X := A/F;
        Result.Y := -A*E/F;
    end
    else
    begin
        E := C/D;
        F := D+C*E;
        Result.X := A*E/F;
        Result.Y := -A/F;
    end;
end;
 
 
function C_Equal(const Z1 : Complex; const Z2 : Complex):Boolean;
begin
    Result := (Z1.X=Z2.X) and (Z1.Y=Z2.Y);
end;
 
 
function C_NotEqual(const Z1 : Complex; const Z2 : Complex):Boolean;
begin
    Result := (Z1.X<>Z2.X) or (Z1.Y<>Z2.Y);
end;
 
function C_EqualR(const Z1 : Complex; const R : Double):Boolean;
begin
    Result := (Z1.X=R) and (Z1.Y=0);
end;
 
function C_NotEqualR(const Z1 : Complex; const R : Double):Boolean;
begin
    Result := (Z1.X<>R) or (Z1.Y<>0);
end;
 
 
end.