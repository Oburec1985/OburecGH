// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclmath.pas' rev: 21.00

#ifndef JclmathHPP
#define JclmathHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
static const Infinity    =  1.0 / 0.0;
static const NaN         =  0.0 / 0.0;
static const NegInfinity = -1.0 / 0.0;

namespace Jclmath
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TPrimalityTestMethod { ptTrialDivision, ptRabinMiller };
#pragma option pop

#pragma option push -b-
enum TFloatingPointClass { fpZero, fpNormal, fpDenormal, fpInfinite, fpNaN, fpInvalid, fpEmpty };
#pragma option pop

typedef int TNaNTag;

class DELPHICLASS TJclASet;
class PASCALIMPLEMENTATION TJclASet : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	virtual bool __fastcall GetBit(const int Idx) = 0 ;
	virtual void __fastcall SetBit(const int Idx, const bool Value) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual void __fastcall Invert(void) = 0 ;
	virtual bool __fastcall GetRange(const int Low, const int High, const bool Value) = 0 ;
	virtual void __fastcall SetRange(const int Low, const int High, const bool Value) = 0 ;
public:
	/* TObject.Create */ inline __fastcall TJclASet(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclASet(void) { }
	
};


class DELPHICLASS TJclFlatSet;
class PASCALIMPLEMENTATION TJclFlatSet : public TJclASet
{
	typedef TJclASet inherited;
	
private:
	Classes::TBits* FBits;
	
public:
	__fastcall TJclFlatSet(void);
	__fastcall virtual ~TJclFlatSet(void);
	virtual void __fastcall Clear(void);
	virtual void __fastcall Invert(void);
	virtual void __fastcall SetRange(const int Low, const int High, const bool Value);
	virtual bool __fastcall GetBit(const int Idx);
	virtual bool __fastcall GetRange(const int Low, const int High, const bool Value);
	virtual void __fastcall SetBit(const int Idx, const bool Value);
};


typedef StaticArray<void *, 8388608> TPointerArray;

typedef TPointerArray *PPointerArray;

typedef Set<System::Byte, 0, 255>  TDelphiSet;

typedef TDelphiSet *PDelphiSet;

class DELPHICLASS TJclSparseFlatSet;
class PASCALIMPLEMENTATION TJclSparseFlatSet : public TJclASet
{
	typedef TJclASet inherited;
	
private:
	TPointerArray *FSetList;
	int FSetListEntries;
	
public:
	__fastcall virtual ~TJclSparseFlatSet(void);
	virtual void __fastcall Clear(void);
	virtual void __fastcall Invert(void);
	virtual bool __fastcall GetBit(const int Idx);
	virtual void __fastcall SetBit(const int Idx, const bool Value);
	virtual void __fastcall SetRange(const int Low, const int High, const bool Value);
	virtual bool __fastcall GetRange(const int Low, const int High, const bool Value);
public:
	/* TObject.Create */ inline __fastcall TJclSparseFlatSet(void) : TJclASet() { }
	
};


class DELPHICLASS TJclRational;
class PASCALIMPLEMENTATION TJclRational : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FT;
	int FN;
	System::UnicodeString __fastcall GetAsString(void);
	void __fastcall SetAsString(const System::UnicodeString S);
	System::Extended __fastcall GetAsFloat(void);
	void __fastcall SetAsFloat(const System::Extended R);
	
protected:
	void __fastcall Simplify(void);
	
public:
	__fastcall TJclRational(void)/* overload */;
	__fastcall TJclRational(const System::Extended R)/* overload */;
	__fastcall TJclRational(const int Numerator, const int Denominator)/* overload */;
	__property int Numerator = {read=FT, nodefault};
	__property int Denominator = {read=FN, nodefault};
	__property System::UnicodeString AsString = {read=GetAsString, write=SetAsString};
	__property System::Extended AsFloat = {read=GetAsFloat, write=SetAsFloat};
	void __fastcall Assign(const TJclRational* R)/* overload */;
	void __fastcall Assign(const System::Extended R)/* overload */;
	void __fastcall Assign(const int Numerator, const int Denominator = 0x1)/* overload */;
	void __fastcall AssignZero(void);
	void __fastcall AssignOne(void);
	TJclRational* __fastcall Duplicate(void);
	bool __fastcall IsEqual(const TJclRational* R)/* overload */;
	bool __fastcall IsEqual(const int Numerator, const int Denominator = 0x1)/* overload */;
	bool __fastcall IsEqual(const System::Extended R)/* overload */;
	bool __fastcall IsZero(void);
	bool __fastcall IsOne(void);
	void __fastcall Add(const TJclRational* R)/* overload */;
	void __fastcall Add(const System::Extended V)/* overload */;
	void __fastcall Add(const int V)/* overload */;
	void __fastcall Subtract(const TJclRational* R)/* overload */;
	void __fastcall Subtract(const System::Extended V)/* overload */;
	void __fastcall Subtract(const int V)/* overload */;
	void __fastcall Negate(void);
	void __fastcall Abs(void);
	int __fastcall Sgn(void);
	void __fastcall Multiply(const TJclRational* R)/* overload */;
	void __fastcall Multiply(const System::Extended V)/* overload */;
	void __fastcall Multiply(const int V)/* overload */;
	void __fastcall Reciprocal(void);
	void __fastcall Divide(const TJclRational* R)/* overload */;
	void __fastcall Divide(const System::Extended V)/* overload */;
	void __fastcall Divide(const int V)/* overload */;
	void __fastcall Sqrt(void);
	void __fastcall Sqr(void);
	void __fastcall Power(const TJclRational* R)/* overload */;
	void __fastcall Power(const int V)/* overload */;
	void __fastcall Power(const System::Extended V)/* overload */;
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclRational(void) { }
	
};


class DELPHICLASS EJclMathError;
class PASCALIMPLEMENTATION EJclMathError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclMathError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclMathError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclMathError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclMathError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMathError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMathError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMathError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMathError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMathError(void) { }
	
};


class DELPHICLASS EJclNaNSignal;
class PASCALIMPLEMENTATION EJclNaNSignal : public EJclMathError
{
	typedef EJclMathError inherited;
	
private:
	TNaNTag FTag;
	
public:
	__fastcall EJclNaNSignal(TNaNTag ATag, bool Dummy);
	__property TNaNTag Tag = {read=FTag, nodefault};
public:
	/* Exception.CreateFmt */ inline __fastcall EJclNaNSignal(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EJclMathError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclNaNSignal(int Ident)/* overload */ : EJclMathError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclNaNSignal(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EJclMathError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclNaNSignal(const System::UnicodeString Msg, int AHelpContext) : EJclMathError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclNaNSignal(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EJclMathError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclNaNSignal(int Ident, int AHelpContext)/* overload */ : EJclMathError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclNaNSignal(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EJclMathError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclNaNSignal(void) { }
	
};


typedef StaticArray<System::Word, 256> TCrc16Table;

typedef StaticArray<unsigned, 256> TCrc32Table;

struct TRectComplex;
struct TRectComplex
{
	
public:
	System::Extended Re;
	System::Extended Im;
	static TRectComplex __fastcall _op_Implicit(const System::Extended Value);
	static bool __fastcall _op_Equality(const TRectComplex &Z1, const TRectComplex &Z2);
	static bool __fastcall _op_Inequality(const TRectComplex &Z1, const TRectComplex &Z2);
	static TRectComplex __fastcall _op_Addition(const TRectComplex &Z1, const TRectComplex &Z2);
	static TRectComplex __fastcall _op_Subtraction(const TRectComplex &Z1, const TRectComplex &Z2);
	static TRectComplex __fastcall _op_Multiply(const TRectComplex &Z1, const TRectComplex &Z2);
	static TRectComplex __fastcall _op_Division(const TRectComplex &Z1, const TRectComplex &Z2);
	static TRectComplex __fastcall _op_UnaryNegation(const TRectComplex &Z);
	static TRectComplex __fastcall _op_UnaryPlus(const TRectComplex &Z);
	System::UnicodeString __fastcall AsString(void);
	TRectComplex __fastcall Conjugate(void);
	bool __fastcall IsZero(void);
	bool __fastcall IsInfinite(void);
};


struct TPolarComplex;
struct TPolarComplex
{
	
public:
	System::Extended Radius;
	System::Extended Angle;
	static TPolarComplex __fastcall _op_Implicit(const System::Extended Value);
	__fastcall operator TRectComplex();
	static TPolarComplex __fastcall _op_Implicit(const TRectComplex &Z);
	static bool __fastcall _op_Equality(const TPolarComplex &Z1, const TPolarComplex &Z2);
	static bool __fastcall _op_Inequality(const TPolarComplex &Z1, const TPolarComplex &Z2);
	static TRectComplex __fastcall _op_Addition(const TPolarComplex &Z1, const TPolarComplex &Z2);
	static TRectComplex __fastcall _op_Subtraction(const TPolarComplex &Z1, const TPolarComplex &Z2);
	static TPolarComplex __fastcall _op_Multiply(const TPolarComplex &Z1, const TPolarComplex &Z2);
	static TPolarComplex __fastcall _op_Division(const TPolarComplex &Z1, const TPolarComplex &Z2);
	static TPolarComplex __fastcall _op_UnaryNegation(const TPolarComplex &Z);
	static TPolarComplex __fastcall _op_UnaryPlus(const TPolarComplex &Z);
	System::UnicodeString __fastcall AsString(void);
	TPolarComplex __fastcall Conjugate(void);
	bool __fastcall IsZero(void);
	bool __fastcall IsInfinite(void);
	TPolarComplex __fastcall Power(const TRectComplex &Exponent)/* overload */;
	TPolarComplex __fastcall Power(const System::Extended Exponent)/* overload */;
	TPolarComplex __fastcall Power(const int Exponent)/* overload */;
	TPolarComplex __fastcall Root(const unsigned K, const unsigned N);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::Extended Bernstein;
extern PACKAGE System::Extended Cbrt2;
extern PACKAGE System::Extended Cbrt3;
extern PACKAGE System::Extended Cbrt10;
extern PACKAGE System::Extended Cbrt100;
extern PACKAGE System::Extended CbrtPi;
extern PACKAGE System::Extended Catalan;
extern PACKAGE System::Extended Pi;
extern PACKAGE System::Extended PiOn2;
extern PACKAGE System::Extended PiOn3;
extern PACKAGE System::Extended PiOn4;
extern PACKAGE System::Extended Sqrt2;
extern PACKAGE System::Extended Sqrt3;
extern PACKAGE System::Extended Sqrt5;
extern PACKAGE System::Extended Sqrt10;
extern PACKAGE System::Extended SqrtPi;
extern PACKAGE System::Extended Sqrt2Pi;
extern PACKAGE System::Extended TwoPi;
extern PACKAGE System::Extended ThreePi;
extern PACKAGE System::Extended Ln2;
extern PACKAGE System::Extended Ln10;
extern PACKAGE System::Extended LnPi;
extern PACKAGE System::Extended Log2;
extern PACKAGE System::Extended Log3;
extern PACKAGE System::Extended LogPi;
extern PACKAGE System::Extended LogE;
extern PACKAGE System::Extended E;
extern PACKAGE System::Extended hLn2Pi;
extern PACKAGE System::Extended inv2Pi;
extern PACKAGE System::Extended TwoToPower63;
extern PACKAGE System::Extended GoldenMean;
extern PACKAGE System::Extended EulerMascheroni;
extern PACKAGE System::Extended MaxAngle;
extern PACKAGE System::Extended MaxTanH;
static const Word MaxFactorial = 0x6da;
extern PACKAGE System::Extended MaxFloatingPoint;
extern PACKAGE System::Extended MinFloatingPoint;
static const Extended PiExt = 3.141593E+00;
extern PACKAGE System::Extended RatioDegToRad;
extern PACKAGE System::Extended RatioRadToDeg;
extern PACKAGE System::Extended RatioGradToRad;
extern PACKAGE System::Extended RatioRadToGrad;
extern PACKAGE System::Extended RatioDegToGrad;
extern PACKAGE System::Extended RatioGradToDeg;
extern PACKAGE System::Extended PrecisionTolerance;
extern PACKAGE float EpsSingle;
extern PACKAGE double EpsDouble;
extern PACKAGE System::Extended EpsExtended;
extern PACKAGE System::Extended Epsilon;
extern PACKAGE float ThreeEpsSingle;
extern PACKAGE double ThreeEpsDouble;
extern PACKAGE System::Extended ThreeEpsExtended;
extern PACKAGE System::Extended ThreeEpsilon;
extern PACKAGE bool __fastcall (*IsPrime)(unsigned N);
static const int LowValidNaNTag = -4194303;
static const int HighValidNaNTag = 0x3ffffe;
extern PACKAGE TDelphiSet EmptyDelphiSet;
extern PACKAGE TDelphiSet CompleteDelphiSet;
extern PACKAGE TCrc16Table Crc16DefaultTable;
extern PACKAGE unsigned Crc16DefaultStart;
static const Word Crc16PolynomCCITT = 0x1021;
static const Word Crc16PolynomIBM = 0x8005;
static const ShortInt Crc16Bits = 0x10;
static const ShortInt Crc16Bytes = 0x2;
static const Word Crc16HighBit = 0x8000;
static const Word NotCrc16HighBit = 0x7fff;
extern PACKAGE TCrc32Table Crc32DefaultTable;
extern PACKAGE unsigned Crc32DefaultStart;
static const int Crc32PolynomIEEE = 0x4c11db7;
static const int Crc32PolynomCastagnoli = 0x1edc6f41;
static const int Crc32Koopman = 0x741b8cd7;
static const ShortInt Crc32Bits = 0x20;
static const ShortInt Crc32Bytes = 0x4;
static const unsigned Crc32HighBit = 0x80000000;
static const int NotCrc32HighBit = 0x7fffffff;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall SwapOrd(int &X, int &Y);
extern PACKAGE System::UnicodeString __fastcall DoubleToHex(const double D);
extern PACKAGE double __fastcall HexToDouble(const System::UnicodeString Hex);
extern PACKAGE System::Extended __fastcall DegToRad(const System::Extended Value)/* overload */;
extern PACKAGE double __fastcall DegToRad(const double Value)/* overload */;
extern PACKAGE float __fastcall DegToRad(const float Value)/* overload */;
extern PACKAGE void __fastcall FastDegToRad(void);
extern PACKAGE System::Extended __fastcall RadToDeg(const System::Extended Value)/* overload */;
extern PACKAGE double __fastcall RadToDeg(const double Value)/* overload */;
extern PACKAGE float __fastcall RadToDeg(const float Value)/* overload */;
extern PACKAGE void __fastcall FastRadToDeg(void);
extern PACKAGE System::Extended __fastcall GradToRad(const System::Extended Value)/* overload */;
extern PACKAGE double __fastcall GradToRad(const double Value)/* overload */;
extern PACKAGE float __fastcall GradToRad(const float Value)/* overload */;
extern PACKAGE void __fastcall FastGradToRad(void);
extern PACKAGE System::Extended __fastcall RadToGrad(const System::Extended Value)/* overload */;
extern PACKAGE double __fastcall RadToGrad(const double Value)/* overload */;
extern PACKAGE float __fastcall RadToGrad(const float Value)/* overload */;
extern PACKAGE void __fastcall FastRadToGrad(void);
extern PACKAGE System::Extended __fastcall DegToGrad(const System::Extended Value)/* overload */;
extern PACKAGE double __fastcall DegToGrad(const double Value)/* overload */;
extern PACKAGE float __fastcall DegToGrad(const float Value)/* overload */;
extern PACKAGE void __fastcall FastDegToGrad(void);
extern PACKAGE System::Extended __fastcall GradToDeg(const System::Extended Value)/* overload */;
extern PACKAGE double __fastcall GradToDeg(const double Value)/* overload */;
extern PACKAGE float __fastcall GradToDeg(const float Value)/* overload */;
extern PACKAGE void __fastcall FastGradToDeg(void);
extern PACKAGE void __fastcall DomainCheck(bool Err);
extern PACKAGE System::Extended __fastcall LogBase10(System::Extended X);
extern PACKAGE System::Extended __fastcall LogBase2(System::Extended X);
extern PACKAGE System::Extended __fastcall LogBaseN(System::Extended Base, System::Extended X);
extern PACKAGE System::Extended __fastcall ArcCos(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcCot(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcCsc(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcSec(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcSin(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcTan(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcTan2(System::Extended Y, System::Extended X);
extern PACKAGE System::Extended __fastcall Cos(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall Cot(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall Coversine(System::Extended X);
extern PACKAGE System::Extended __fastcall Csc(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall Exsecans(System::Extended X);
extern PACKAGE System::Extended __fastcall Haversine(System::Extended X);
extern PACKAGE System::Extended __fastcall Sec(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall Sin(System::Extended X)/* overload */;
extern PACKAGE void __fastcall SinCos(System::Extended X, /* out */ System::Extended &Sin, /* out */ System::Extended &Cos)/* overload */;
extern PACKAGE void __fastcall SinCos(double X, /* out */ double &Sin, /* out */ double &Cos)/* overload */;
extern PACKAGE void __fastcall SinCos(float X, /* out */ float &Sin, /* out */ float &Cos)/* overload */;
extern PACKAGE System::Extended __fastcall Tan(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall Versine(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcCosH(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcCotH(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcCscH(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcSecH(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcSinH(System::Extended X);
extern PACKAGE System::Extended __fastcall ArcTanH(System::Extended X);
extern PACKAGE System::Extended __fastcall CosH(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall CotH(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall CscH(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall SecH(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall SinH(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall TanH(System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall DegMinSecToFloat(const System::Extended Degs, const System::Extended Mins, const System::Extended Secs);
extern PACKAGE void __fastcall FloatToDegMinSec(const System::Extended X, System::Extended &Degs, System::Extended &Mins, System::Extended &Secs);
extern PACKAGE System::Extended __fastcall Exp(const System::Extended X)/* overload */;
extern PACKAGE System::Extended __fastcall Power(const System::Extended Base, const System::Extended Exponent)/* overload */;
extern PACKAGE System::Extended __fastcall PowerInt(const System::Extended X, int N)/* overload */;
extern PACKAGE System::Extended __fastcall TenToY(const System::Extended Y);
extern PACKAGE System::Extended __fastcall TruncPower(const System::Extended Base, const System::Extended Exponent);
extern PACKAGE System::Extended __fastcall TwoToY(const System::Extended Y);
extern PACKAGE bool __fastcall IsFloatZero(const System::Extended X);
extern PACKAGE bool __fastcall FloatsEqual(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall MaxFloat(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall MinFloat(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall ModFloat(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall RemainderFloat(const System::Extended X, const System::Extended Y);
extern PACKAGE void __fastcall SwapFloats(System::Extended &X, System::Extended &Y);
extern PACKAGE void __fastcall CalcMachineEpsSingle(void);
extern PACKAGE void __fastcall CalcMachineEpsDouble(void);
extern PACKAGE void __fastcall CalcMachineEpsExtended(void);
extern PACKAGE void __fastcall CalcMachineEps(void);
extern PACKAGE void __fastcall SetPrecisionToleranceToEpsilon(void);
extern PACKAGE System::Extended __fastcall SetPrecisionTolerance(System::Extended NewTolerance);
extern PACKAGE int __fastcall Ceiling(const System::Extended X);
extern PACKAGE __int64 __fastcall CommercialRound(const System::Extended X);
extern PACKAGE System::Extended __fastcall Factorial(const int N);
extern PACKAGE int __fastcall Floor(const System::Extended X);
extern PACKAGE unsigned __fastcall GCD(unsigned X, unsigned Y);
extern PACKAGE short __fastcall ISqrt(const short I);
extern PACKAGE unsigned __fastcall LCM(const unsigned X, const unsigned Y);
extern PACKAGE System::Extended __fastcall NormalizeAngle(const System::Extended Angle);
extern PACKAGE System::Extended __fastcall Pythagoras(const System::Extended X, const System::Extended Y);
extern PACKAGE int __fastcall Sgn(const System::Extended X);
extern PACKAGE System::Extended __fastcall Signe(const System::Extended X, const System::Extended Y);
extern PACKAGE int __fastcall Ackermann(const int A, const int B);
extern PACKAGE int __fastcall Fibonacci(const int N);
extern PACKAGE int __fastcall EnsureRange(const int AValue, const int AMin, const int AMax)/* overload */;
extern PACKAGE __int64 __fastcall EnsureRange(const __int64 AValue, const __int64 AMin, const __int64 AMax)/* overload */;
extern PACKAGE double __fastcall EnsureRange(const double AValue, const double AMin, const double AMax)/* overload */;
extern PACKAGE bool __fastcall IsPrimeTD(unsigned N);
extern PACKAGE bool __fastcall IsPrimeRM(unsigned N);
extern PACKAGE Jclbase::TDynCardinalArray __fastcall PrimeFactors(unsigned N);
extern PACKAGE bool __fastcall IsPrimeFactor(const unsigned F, const unsigned N);
extern PACKAGE bool __fastcall IsRelativePrime(const unsigned X, const unsigned Y);
extern PACKAGE void __fastcall SetPrimalityTest(const TPrimalityTestMethod Method);
extern PACKAGE TFloatingPointClass __fastcall FloatingPointClass(const float Value)/* overload */;
extern PACKAGE TFloatingPointClass __fastcall FloatingPointClass(const double Value)/* overload */;
extern PACKAGE TFloatingPointClass __fastcall FloatingPointClass(const System::Extended Value)/* overload */;
extern PACKAGE bool __fastcall IsInfinite(const float Value)/* overload */;
extern PACKAGE bool __fastcall IsInfinite(const double Value)/* overload */;
extern PACKAGE bool __fastcall IsInfinite(const System::Extended Value)/* overload */;
extern PACKAGE bool __fastcall IsNaN(const float Value)/* overload */;
extern PACKAGE bool __fastcall IsNaN(const double Value)/* overload */;
extern PACKAGE bool __fastcall IsNaN(const System::Extended Value)/* overload */;
extern PACKAGE TNaNTag __fastcall GetNaNTag(const float NaN)/* overload */;
extern PACKAGE TNaNTag __fastcall GetNaNTag(const double NaN)/* overload */;
extern PACKAGE TNaNTag __fastcall GetNaNTag(const System::Extended NaN)/* overload */;
extern PACKAGE void __fastcall MakeQuietNaN(float &X, TNaNTag Tag = (TNaNTag)(0x0))/* overload */;
extern PACKAGE void __fastcall MakeQuietNaN(double &X, TNaNTag Tag = (TNaNTag)(0x0))/* overload */;
extern PACKAGE void __fastcall MakeQuietNaN(System::Extended &X, TNaNTag Tag = (TNaNTag)(0x0))/* overload */;
extern PACKAGE void __fastcall MakeSignalingNaN(float &X, TNaNTag Tag = (TNaNTag)(0x0))/* overload */;
extern PACKAGE void __fastcall MakeSignalingNaN(double &X, TNaNTag Tag = (TNaNTag)(0x0))/* overload */;
extern PACKAGE void __fastcall MakeSignalingNaN(System::Extended &X, TNaNTag Tag = (TNaNTag)(0x0))/* overload */;
extern PACKAGE void __fastcall MineSingleBuffer(void *Buffer, int Count, TNaNTag StartTag = (TNaNTag)(0x0));
extern PACKAGE void __fastcall MineDoubleBuffer(void *Buffer, int Count, TNaNTag StartTag = (TNaNTag)(0x0));
extern PACKAGE Jclbase::TDynSingleArray __fastcall MinedSingleArray(int Length);
extern PACKAGE Jclbase::TDynDoubleArray __fastcall MinedDoubleArray(int Length);
extern PACKAGE bool __fastcall IsSpecialValue(const System::Extended X);
extern PACKAGE bool __fastcall GetParity(Jclbase::TDynByteArray Buffer, int Len)/* overload */;
extern PACKAGE bool __fastcall GetParity(System::PByte Buffer, int Len)/* overload */;
extern PACKAGE System::Word __fastcall Crc16_P(System::Word const *Crc16Table, Jclbase::PJclByteArray X, int N, System::Word Crc = (System::Word)(0x0))/* overload */;
extern PACKAGE System::Word __fastcall Crc16_P(Jclbase::PJclByteArray X, int N, System::Word Crc = (System::Word)(0x0))/* overload */;
extern PACKAGE int __fastcall CheckCrc16_P(System::Word const *Crc16Table, Jclbase::PJclByteArray X, int N, System::Word Crc)/* overload */;
extern PACKAGE int __fastcall CheckCrc16_P(Jclbase::PJclByteArray X, int N, System::Word Crc)/* overload */;
extern PACKAGE System::Word __fastcall Crc16(System::Word const *Crc16Table, System::Byte const *X, const int X_Size, int N, System::Word Crc = (System::Word)(0x0))/* overload */;
extern PACKAGE System::Word __fastcall Crc16(System::Byte const *X, const int X_Size, int N, System::Word Crc = (System::Word)(0x0))/* overload */;
extern PACKAGE int __fastcall CheckCrc16(System::Word const *Crc16Table, System::Byte *X, const int X_Size, int N, System::Word Crc)/* overload */;
extern PACKAGE int __fastcall CheckCrc16(System::Byte *X, const int X_Size, int N, System::Word Crc)/* overload */;
extern PACKAGE System::Word __fastcall Crc16_A(System::Word const *Crc16Table, System::Byte const *X, const int X_Size, System::Word Crc = (System::Word)(0x0))/* overload */;
extern PACKAGE System::Word __fastcall Crc16_A(System::Byte const *X, const int X_Size, System::Word Crc = (System::Word)(0x0))/* overload */;
extern PACKAGE int __fastcall CheckCrc16_A(System::Word const *Crc16Table, System::Byte *X, const int X_Size, System::Word Crc)/* overload */;
extern PACKAGE int __fastcall CheckCrc16_A(System::Byte *X, const int X_Size, System::Word Crc)/* overload */;
extern PACKAGE void __fastcall InitCrc16(System::Word Polynom, System::Word Start, /* out */ System::Word *Crc16Table)/* overload */;
extern PACKAGE void __fastcall InitCrc16(System::Word Polynom, System::Word Start)/* overload */;
extern PACKAGE unsigned __fastcall Crc32_P(unsigned const *Crc32Table, Jclbase::PJclByteArray X, int N, unsigned Crc = (unsigned)(0x0))/* overload */;
extern PACKAGE unsigned __fastcall Crc32_P(Jclbase::PJclByteArray X, int N, unsigned Crc = (unsigned)(0x0))/* overload */;
extern PACKAGE int __fastcall CheckCrc32_P(unsigned const *Crc32Table, Jclbase::PJclByteArray X, int N, unsigned Crc)/* overload */;
extern PACKAGE int __fastcall CheckCrc32_P(Jclbase::PJclByteArray X, int N, unsigned Crc)/* overload */;
extern PACKAGE unsigned __fastcall Crc32(unsigned const *Crc32Table, System::Byte const *X, const int X_Size, int N, unsigned Crc = (unsigned)(0x0))/* overload */;
extern PACKAGE unsigned __fastcall Crc32(System::Byte const *X, const int X_Size, int N, unsigned Crc = (unsigned)(0x0))/* overload */;
extern PACKAGE int __fastcall CheckCrc32(unsigned const *Crc32Table, System::Byte *X, const int X_Size, int N, unsigned Crc)/* overload */;
extern PACKAGE int __fastcall CheckCrc32(System::Byte *X, const int X_Size, int N, unsigned Crc)/* overload */;
extern PACKAGE unsigned __fastcall Crc32_A(unsigned const *Crc32Table, System::Byte const *X, const int X_Size, unsigned Crc = (unsigned)(0x0))/* overload */;
extern PACKAGE unsigned __fastcall Crc32_A(System::Byte const *X, const int X_Size, unsigned Crc = (unsigned)(0x0))/* overload */;
extern PACKAGE int __fastcall CheckCrc32_A(unsigned const *Crc32Table, System::Byte *X, const int X_Size, unsigned Crc)/* overload */;
extern PACKAGE int __fastcall CheckCrc32_A(System::Byte *X, const int X_Size, unsigned Crc)/* overload */;
extern PACKAGE void __fastcall InitCrc32(unsigned Polynom, unsigned Start, /* out */ unsigned *Crc32Table)/* overload */;
extern PACKAGE void __fastcall InitCrc32(unsigned Polynom, unsigned Start)/* overload */;
extern PACKAGE void __fastcall SetRectComplexFormatStr(const System::UnicodeString S);
extern PACKAGE void __fastcall SetPolarComplexFormatStr(const System::UnicodeString S);
extern PACKAGE System::UnicodeString __fastcall ComplexToStr(const TRectComplex &Z)/* overload */;
extern PACKAGE System::UnicodeString __fastcall ComplexToStr(const TPolarComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall RectComplex(const System::Extended Re, const System::Extended Im = 0.000000E+00)/* overload */;
extern PACKAGE TRectComplex __fastcall RectComplex(const TPolarComplex &Z)/* overload */;
extern PACKAGE TPolarComplex __fastcall PolarComplex(const System::Extended Radius, const System::Extended Angle = 0.000000E+00)/* overload */;
extern PACKAGE TPolarComplex __fastcall PolarComplex(const TRectComplex &Z)/* overload */;
extern PACKAGE bool __fastcall Equal(const TRectComplex &Z1, const TRectComplex &Z2)/* overload */;
extern PACKAGE bool __fastcall Equal(const TPolarComplex &Z1, const TPolarComplex &Z2)/* overload */;
extern PACKAGE bool __fastcall IsZero(const TRectComplex &Z)/* overload */;
extern PACKAGE bool __fastcall IsZero(const TPolarComplex &Z)/* overload */;
extern PACKAGE bool __fastcall IsInfinite(const TRectComplex &Z)/* overload */;
extern PACKAGE bool __fastcall IsInfinite(const TPolarComplex &Z)/* overload */;
extern PACKAGE System::Extended __fastcall Norm(const TRectComplex &Z)/* overload */;
extern PACKAGE System::Extended __fastcall Norm(const TPolarComplex &Z)/* overload */;
extern PACKAGE System::Extended __fastcall AbsSqr(const TRectComplex &Z)/* overload */;
extern PACKAGE System::Extended __fastcall AbsSqr(const TPolarComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Conjugate(const TRectComplex &Z)/* overload */;
extern PACKAGE TPolarComplex __fastcall Conjugate(const TPolarComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Inv(const TRectComplex &Z)/* overload */;
extern PACKAGE TPolarComplex __fastcall Inv(const TPolarComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Neg(const TRectComplex &Z)/* overload */;
extern PACKAGE TPolarComplex __fastcall Neg(const TPolarComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Sum(const TRectComplex &Z1, const TRectComplex &Z2)/* overload */;
extern PACKAGE TRectComplex __fastcall Sum(TRectComplex const *Z, const int Z_Size)/* overload */;
extern PACKAGE TRectComplex __fastcall Diff(const TRectComplex &Z1, const TRectComplex &Z2);
extern PACKAGE TRectComplex __fastcall Product(const TRectComplex &Z1, const TRectComplex &Z2)/* overload */;
extern PACKAGE TPolarComplex __fastcall Product(const TPolarComplex &Z1, const TPolarComplex &Z2)/* overload */;
extern PACKAGE TPolarComplex __fastcall Product(TPolarComplex const *Z, const int Z_Size)/* overload */;
extern PACKAGE TRectComplex __fastcall Quotient(const TRectComplex &Z1, const TRectComplex &Z2)/* overload */;
extern PACKAGE TPolarComplex __fastcall Quotient(const TPolarComplex &Z1, const TPolarComplex &Z2)/* overload */;
extern PACKAGE TRectComplex __fastcall Ln(const TPolarComplex &Z);
extern PACKAGE TPolarComplex __fastcall Exp(const TRectComplex &Z)/* overload */;
extern PACKAGE TPolarComplex __fastcall Power(const TPolarComplex &Z, const System::Extended Exponent)/* overload */;
extern PACKAGE TPolarComplex __fastcall Power(const TPolarComplex &Z, const TRectComplex &Exponent)/* overload */;
extern PACKAGE TPolarComplex __fastcall PowerInt(const TPolarComplex &Z, const int Exponent)/* overload */;
extern PACKAGE TPolarComplex __fastcall Root(const TPolarComplex &Z, const unsigned K, const unsigned N);
extern PACKAGE TRectComplex __fastcall Cos(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Sin(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Tan(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Cot(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Sec(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall Csc(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall CosH(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall SinH(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall TanH(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall CotH(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall SecH(const TRectComplex &Z)/* overload */;
extern PACKAGE TRectComplex __fastcall CscH(const TRectComplex &Z)/* overload */;

}	/* namespace Jclmath */
using namespace Jclmath;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclmathHPP
