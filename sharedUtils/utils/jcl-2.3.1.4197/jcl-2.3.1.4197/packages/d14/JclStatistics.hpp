// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclstatistics.pas' rev: 21.00

#ifndef JclstatisticsHPP
#define JclstatisticsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclmath.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclstatistics
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclStatisticsError;
class PASCALIMPLEMENTATION EJclStatisticsError : public Jclmath::EJclMathError
{
	typedef Jclmath::EJclMathError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclStatisticsError(const System::UnicodeString Msg) : Jclmath::EJclMathError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclStatisticsError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclmath::EJclMathError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclStatisticsError(int Ident)/* overload */ : Jclmath::EJclMathError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclStatisticsError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclmath::EJclMathError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclStatisticsError(const System::UnicodeString Msg, int AHelpContext) : Jclmath::EJclMathError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclStatisticsError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclmath::EJclMathError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclStatisticsError(int Ident, int AHelpContext)/* overload */ : Jclmath::EJclMathError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclStatisticsError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclmath::EJclMathError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclStatisticsError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE System::Extended __fastcall ArithmeticMean(const Jclbase::TDynFloatArray X);
extern PACKAGE System::Extended __fastcall GeometricMean(const Jclbase::TDynFloatArray X);
extern PACKAGE System::Extended __fastcall HarmonicMean(const Jclbase::TDynFloatArray X);
extern PACKAGE System::Extended __fastcall HeronianMean(const System::Extended A, const System::Extended B);
extern PACKAGE System::Extended __fastcall BinomialCoeff(unsigned N, unsigned R);
extern PACKAGE bool __fastcall IsPositiveFloatArray(const Jclbase::TDynFloatArray X);
extern PACKAGE System::Extended __fastcall MaxFloatArray(const Jclbase::TDynFloatArray B);
extern PACKAGE int __fastcall MaxFloatArrayIndex(const Jclbase::TDynFloatArray B);
extern PACKAGE System::Extended __fastcall Median(const Jclbase::TDynFloatArray X);
extern PACKAGE System::Extended __fastcall MedianUnsorted(const Jclbase::TDynFloatArray X);
extern PACKAGE System::Extended __fastcall MinFloatArray(const Jclbase::TDynFloatArray B);
extern PACKAGE int __fastcall MinFloatArrayIndex(const Jclbase::TDynFloatArray B);
extern PACKAGE System::Extended __fastcall Permutation(unsigned N, unsigned R);
extern PACKAGE System::Extended __fastcall Combinations(unsigned N, unsigned R);
extern PACKAGE System::Extended __fastcall SumOfSquares(const Jclbase::TDynFloatArray X);
extern PACKAGE System::Extended __fastcall PopulationVariance(const Jclbase::TDynFloatArray X);
extern PACKAGE void __fastcall PopulationVarianceAndMean(const Jclbase::TDynFloatArray X, System::Extended &Variance, System::Extended &Mean);
extern PACKAGE System::Extended __fastcall SampleVariance(const Jclbase::TDynFloatArray X);
extern PACKAGE void __fastcall SampleVarianceAndMean(const Jclbase::TDynFloatArray X, System::Extended &Variance, System::Extended &Mean);
extern PACKAGE System::Extended __fastcall StdError(const Jclbase::TDynFloatArray X)/* overload */;
extern PACKAGE System::Extended __fastcall StdError(const System::Extended Variance, const int SampleSize)/* overload */;
extern PACKAGE System::Extended __fastcall SumFloatArray(const Jclbase::TDynFloatArray B);
extern PACKAGE System::Extended __fastcall SumSquareDiffFloatArray(const Jclbase::TDynFloatArray B, System::Extended Diff);
extern PACKAGE System::Extended __fastcall SumSquareFloatArray(const Jclbase::TDynFloatArray B);
extern PACKAGE System::Extended __fastcall SumPairProductFloatArray(const Jclbase::TDynFloatArray X, const Jclbase::TDynFloatArray Y);

}	/* namespace Jclstatistics */
using namespace Jclstatistics;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclstatisticsHPP
