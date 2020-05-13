// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Esbmaths.pas' rev: 21.00

#ifndef EsbmathsHPP
#define EsbmathsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Esbmaths
{
//-- type declarations -------------------------------------------------------
typedef unsigned LongWord;

typedef System::Word TBitList;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE float MinSingle;
extern PACKAGE float MaxSingle;
extern PACKAGE double MinDouble;
extern PACKAGE double MaxDouble;
extern PACKAGE System::Extended MinExtended;
extern PACKAGE System::Extended MaxExtended;
extern PACKAGE System::Currency MinCurrency;
extern PACKAGE System::Currency MaxCurrency;
extern PACKAGE System::Extended Sqrt2;
extern PACKAGE System::Extended Sqrt3;
extern PACKAGE System::Extended Sqrt5;
extern PACKAGE System::Extended Sqrt10;
extern PACKAGE System::Extended SqrtPi;
extern PACKAGE System::Extended Cbrt2;
extern PACKAGE System::Extended Cbrt3;
extern PACKAGE System::Extended Cbrt10;
extern PACKAGE System::Extended Cbrt100;
extern PACKAGE System::Extended CbrtPi;
extern PACKAGE System::Extended InvSqrt2;
extern PACKAGE System::Extended InvSqrt3;
extern PACKAGE System::Extended InvSqrt5;
extern PACKAGE System::Extended InvSqrtPi;
extern PACKAGE System::Extended InvCbrtPi;
extern PACKAGE System::Extended ESBe;
extern PACKAGE System::Extended ESBe2;
extern PACKAGE System::Extended ESBePi;
extern PACKAGE System::Extended ESBePiOn2;
extern PACKAGE System::Extended ESBePiOn4;
extern PACKAGE System::Extended Ln2;
extern PACKAGE System::Extended Ln10;
extern PACKAGE System::Extended LnPi;
static const Extended Log10Base2 = 3.321928E+00;
extern PACKAGE System::Extended Log2Base10;
extern PACKAGE System::Extended Log3Base10;
extern PACKAGE System::Extended LogPiBase10;
extern PACKAGE System::Extended LogEBase10;
extern PACKAGE System::Extended ESBPi;
extern PACKAGE System::Extended InvPi;
extern PACKAGE System::Extended TwoPi;
extern PACKAGE System::Extended ThreePi;
extern PACKAGE System::Extended Pi2;
extern PACKAGE System::Extended PiToE;
extern PACKAGE System::Extended PiOn2;
extern PACKAGE System::Extended PiOn3;
extern PACKAGE System::Extended PiOn4;
extern PACKAGE System::Extended ThreePiOn2;
extern PACKAGE System::Extended FourPiOn3;
extern PACKAGE System::Extended TwoToPower63;
extern PACKAGE System::Extended OneRadian;
extern PACKAGE System::Extended OneDegree;
extern PACKAGE System::Extended OneMinute;
extern PACKAGE System::Extended OneSecond;
extern PACKAGE System::Extended ESBGamma;
extern PACKAGE System::Extended LnRt2Pi;
extern PACKAGE System::Extended ESBTolerance;
extern PACKAGE void __fastcall IncLim(System::Byte &B, const System::Byte Limit);
extern PACKAGE void __fastcall IncLimSI(System::ShortInt &B, const System::ShortInt Limit);
extern PACKAGE void __fastcall IncLimW(System::Word &B, const System::Word Limit);
extern PACKAGE void __fastcall IncLimI(int &B, const int Limit);
extern PACKAGE void __fastcall IncLimL(int &B, const int Limit);
extern PACKAGE void __fastcall DecLim(System::Byte &B, const System::Byte Limit);
extern PACKAGE void __fastcall DecLimSI(System::ShortInt &B, const System::ShortInt Limit);
extern PACKAGE void __fastcall DecLimW(System::Word &B, const System::Word Limit);
extern PACKAGE void __fastcall DecLimI(int &B, const int Limit);
extern PACKAGE void __fastcall DecLimL(int &B, const int Limit);
extern PACKAGE System::Byte __fastcall MaxB(const System::Byte B1, const System::Byte B2);
extern PACKAGE System::Byte __fastcall MinB(const System::Byte B1, const System::Byte B2);
extern PACKAGE System::ShortInt __fastcall MaxSI(const System::ShortInt B1, const System::ShortInt B2);
extern PACKAGE System::ShortInt __fastcall MinSI(const System::ShortInt B1, const System::ShortInt B2);
extern PACKAGE System::Word __fastcall MaxW(const System::Word B1, const System::Word B2);
extern PACKAGE System::Word __fastcall MinW(const System::Word B1, const System::Word B2);
extern PACKAGE int __fastcall MaxI(const int B1, const int B2);
extern PACKAGE int __fastcall MinI(const int B1, const int B2);
extern PACKAGE int __fastcall MaxL(const int B1, const int B2);
extern PACKAGE int __fastcall MinL(const int B1, const int B2);
extern PACKAGE void __fastcall SwapB(System::Byte &B1, System::Byte &B2);
extern PACKAGE void __fastcall SwapSI(System::ShortInt &B1, System::ShortInt &B2);
extern PACKAGE void __fastcall SwapW(System::Word &B1, System::Word &B2);
extern PACKAGE void __fastcall SwapI(short &B1, short &B2);
extern PACKAGE void __fastcall SwapL(int &B1, int &B2);
extern PACKAGE void __fastcall SwapI32(int &B1, int &B2);
extern PACKAGE void __fastcall SwapC(unsigned &B1, unsigned &B2);
extern PACKAGE System::ShortInt __fastcall Sign(const int B);
extern PACKAGE System::Word __fastcall Max4Word(const System::Word X1, const System::Word X2, const System::Word X3, const System::Word X4);
extern PACKAGE System::Word __fastcall Min4Word(const System::Word X1, const System::Word X2, const System::Word X3, const System::Word X4);
extern PACKAGE System::Word __fastcall Max3Word(const System::Word X1, const System::Word X2, const System::Word X3);
extern PACKAGE System::Word __fastcall Min3Word(const System::Word X1, const System::Word X2, const System::Word X3);
extern PACKAGE System::Byte __fastcall MaxBArray(System::Byte const *B, const int B_Size);
extern PACKAGE System::Word __fastcall MaxWArray(System::Word const *B, const int B_Size);
extern PACKAGE int __fastcall MaxIArray(int const *B, const int B_Size);
extern PACKAGE System::ShortInt __fastcall MaxSIArray(System::ShortInt const *B, const int B_Size);
extern PACKAGE int __fastcall MaxLArray(int const *B, const int B_Size);
extern PACKAGE System::Byte __fastcall MinBArray(System::Byte const *B, const int B_Size);
extern PACKAGE System::Word __fastcall MinWArray(System::Word const *B, const int B_Size);
extern PACKAGE int __fastcall MinIArray(int const *B, const int B_Size);
extern PACKAGE System::ShortInt __fastcall MinSIArray(System::ShortInt const *B, const int B_Size);
extern PACKAGE int __fastcall MinLArray(int const *B, const int B_Size);
extern PACKAGE unsigned __fastcall ISqrt(const unsigned I);
extern PACKAGE unsigned __fastcall ILog2(const unsigned I);
extern PACKAGE System::Byte __fastcall SumBArray(System::Byte const *B, const int B_Size);
extern PACKAGE System::Word __fastcall SumBArray2(System::Byte const *B, const int B_Size);
extern PACKAGE System::ShortInt __fastcall SumSIArray(System::ShortInt const *B, const int B_Size);
extern PACKAGE int __fastcall SumSIArray2(System::ShortInt const *B, const int B_Size);
extern PACKAGE System::Word __fastcall SumWArray(System::Word const *B, const int B_Size);
extern PACKAGE int __fastcall SumWArray2(System::Word const *B, const int B_Size);
extern PACKAGE int __fastcall SumIArray(int const *B, const int B_Size);
extern PACKAGE int __fastcall SumLArray(int const *B, const int B_Size);
extern PACKAGE unsigned __fastcall SumLWArray(unsigned const *B, const int B_Size);
extern PACKAGE System::Word __fastcall Get87ControlWord(void);
extern PACKAGE void __fastcall Set87ControlWord(const System::Word CWord);
extern PACKAGE void __fastcall Polar2XY(const System::Extended Rho, const System::Extended Theta, System::Extended &X, System::Extended &Y);
extern PACKAGE void __fastcall XY2Polar(const System::Extended X, const System::Extended Y, System::Extended &Rho, System::Extended &Theta);
extern PACKAGE System::ShortInt __fastcall Sgn(const System::Extended X);
extern PACKAGE System::Extended __fastcall DMS2Extended(const System::Extended Degs, const System::Extended Mins, const System::Extended Secs);
extern PACKAGE void __fastcall Extended2DMS(const System::Extended X, System::Extended &Degs, System::Extended &Mins, System::Extended &Secs);
extern PACKAGE System::Extended __fastcall Distance(const System::Extended X1, const System::Extended Y1, const System::Extended X2, const System::Extended Y2);
extern PACKAGE System::Extended __fastcall ExtMod(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall ExtRem(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall MaxExt(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall MinExt(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Comp __fastcall CompMOD(const System::Comp X, const System::Comp Y);
extern PACKAGE System::Extended __fastcall MaxEArray(System::Extended const *B, const int B_Size);
extern PACKAGE System::Extended __fastcall MinEArray(System::Extended const *B, const int B_Size);
extern PACKAGE float __fastcall MaxSArray(float const *B, const int B_Size);
extern PACKAGE float __fastcall MinSArray(float const *B, const int B_Size);
extern PACKAGE System::Comp __fastcall MaxCArray(System::Comp const *B, const int B_Size);
extern PACKAGE System::Comp __fastcall MinCArray(System::Comp const *B, const int B_Size);
extern PACKAGE float __fastcall SumSArray(float const *B, const int B_Size);
extern PACKAGE System::Extended __fastcall SumEArray(System::Extended const *B, const int B_Size);
extern PACKAGE System::Extended __fastcall SumSqEArray(System::Extended const *B, const int B_Size);
extern PACKAGE System::Extended __fastcall SumSqDiffEArray(System::Extended const *B, const int B_Size, System::Extended Diff);
extern PACKAGE System::Extended __fastcall SumXYEArray(System::Extended const *X, const int X_Size, System::Extended const *Y, const int Y_Size);
extern PACKAGE System::Comp __fastcall SumCArray(System::Comp const *B, const int B_Size);
extern PACKAGE bool __fastcall SameFloat(const System::Extended X1, const System::Extended X2);
extern PACKAGE bool __fastcall FloatIsZero(const System::Extended X);
extern PACKAGE bool __fastcall FloatIsPositive(const System::Extended X);
extern PACKAGE bool __fastcall FloatIsNegative(const System::Extended X);
extern PACKAGE System::Extended __fastcall FactorialX(unsigned A);
extern PACKAGE System::Extended __fastcall PermutationX(unsigned N, unsigned R);
extern PACKAGE System::Extended __fastcall BinomialCoeff(unsigned N, unsigned R);
extern PACKAGE bool __fastcall IsPositiveEArray(System::Extended const *X, const int X_Size);
extern PACKAGE System::Extended __fastcall GeometricMean(System::Extended const *X, const int X_Size);
extern PACKAGE System::Extended __fastcall HarmonicMean(System::Extended const *X, const int X_Size);
extern PACKAGE System::Extended __fastcall ESBMean(System::Extended const *X, const int X_Size);
extern PACKAGE System::Extended __fastcall SampleVariance(System::Extended const *X, const int X_Size);
extern PACKAGE System::Extended __fastcall PopulationVariance(System::Extended const *X, const int X_Size);
extern PACKAGE void __fastcall SampleVarianceAndMean(System::Extended const *X, const int X_Size, System::Extended &Variance, System::Extended &Mean);
extern PACKAGE void __fastcall PopulationVarianceAndMean(System::Extended const *X, const int X_Size, System::Extended &Variance, System::Extended &Mean);
extern PACKAGE System::Extended __fastcall GetMedian(System::Extended const *SortedX, const int SortedX_Size);
extern PACKAGE bool __fastcall GetMode(System::Extended const *SortedX, const int SortedX_Size, System::Extended &Mode);
extern PACKAGE void __fastcall GetQuartiles(System::Extended const *SortedX, const int SortedX_Size, System::Extended &Q1, System::Extended &Q3);
extern PACKAGE System::Byte __fastcall ESBDigits(const unsigned X);
extern PACKAGE int __fastcall ESBMagnitude(const System::Extended X);
extern PACKAGE int __fastcall BitsHighest(const unsigned X);
extern PACKAGE int __fastcall ESBBitsNeeded(const unsigned X);
extern PACKAGE System::Extended __fastcall ESBTan(System::Extended Angle);
extern PACKAGE System::Extended __fastcall ESBCot(System::Extended Angle);
extern PACKAGE System::Extended __fastcall ESBArcTan(System::Extended X, System::Extended Y);
extern PACKAGE void __fastcall ESBSinCos(System::Extended Angle, System::Extended &SinX, System::Extended &CosX);
extern PACKAGE System::Extended __fastcall ESBArcCos(const System::Extended X);
extern PACKAGE System::Extended __fastcall ESBArcSin(const System::Extended X);
extern PACKAGE System::Extended __fastcall ESBCosec(const System::Extended Angle);
extern PACKAGE System::Extended __fastcall ESBSec(const System::Extended Angle);
extern PACKAGE System::Extended __fastcall ESBArcSec(const System::Extended X);
extern PACKAGE System::Extended __fastcall ESBArcCosec(const System::Extended X);
extern PACKAGE System::Extended __fastcall Pow2(const System::Extended X);
extern PACKAGE System::Extended __fastcall IntPow(const System::Extended Base, const unsigned Exponent);
extern PACKAGE System::Extended __fastcall ESBLog10(const System::Extended X);
extern PACKAGE System::Extended __fastcall ESBLog2(const System::Extended X);
extern PACKAGE System::Extended __fastcall ESBLogBase(const System::Extended X, const System::Extended Base);
extern PACKAGE System::Extended __fastcall LogXtoBaseY(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall ESBIntPower(const System::Extended X, const int N);
extern PACKAGE System::Extended __fastcall XtoY(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall TenToY(const System::Extended Y);
extern PACKAGE System::Extended __fastcall TwoToY(const System::Extended Y);
extern PACKAGE System::Extended __fastcall ESBArCosh(System::Extended X);
extern PACKAGE System::Extended __fastcall ESBArSinh(System::Extended X);
extern PACKAGE System::Extended __fastcall ESBArTanh(System::Extended X);
extern PACKAGE System::Extended __fastcall ESBCosh(System::Extended X);
extern PACKAGE System::Extended __fastcall ESBSinh(System::Extended X);
extern PACKAGE System::Extended __fastcall ESBTanh(System::Extended X);
extern PACKAGE unsigned __fastcall GCD(const unsigned X, const unsigned Y);
extern PACKAGE int __fastcall LCM(const int X, const int Y);
extern PACKAGE bool __fastcall RelativePrime(const unsigned X, const unsigned Y);
extern PACKAGE void __fastcall SwapExt(System::Extended &X, System::Extended &Y);
extern PACKAGE void __fastcall SwapDbl(double &X, double &Y);
extern PACKAGE void __fastcall SwapSing(float &X, float &Y);
extern PACKAGE System::Extended __fastcall InverseGamma(const System::Extended X);
extern PACKAGE System::Extended __fastcall Gamma(const System::Extended X);
extern PACKAGE System::Extended __fastcall LnGamma(const System::Extended X);
extern PACKAGE System::Extended __fastcall Beta(const System::Extended X, const System::Extended Y);
extern PACKAGE System::Extended __fastcall IncompleteBeta(System::Extended X, System::Extended P, System::Extended Q);
extern PACKAGE unsigned __fastcall IGreatestPowerOf2(const unsigned N);

}	/* namespace Esbmaths */
using namespace Esbmaths;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// EsbmathsHPP
