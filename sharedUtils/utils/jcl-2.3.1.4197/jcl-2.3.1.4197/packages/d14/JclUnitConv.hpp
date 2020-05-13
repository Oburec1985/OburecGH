// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclunitconv.pas' rev: 21.00

#ifndef JclunitconvHPP
#define JclunitconvHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclunitconv
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EUnitConversionError;
class PASCALIMPLEMENTATION EUnitConversionError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EUnitConversionError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EUnitConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EUnitConversionError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EUnitConversionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EUnitConversionError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EUnitConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EUnitConversionError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EUnitConversionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EUnitConversionError(void) { }
	
};


class DELPHICLASS ETemperatureConversionError;
class PASCALIMPLEMENTATION ETemperatureConversionError : public EUnitConversionError
{
	typedef EUnitConversionError inherited;
	
public:
	/* Exception.Create */ inline __fastcall ETemperatureConversionError(const System::UnicodeString Msg) : EUnitConversionError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall ETemperatureConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EUnitConversionError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall ETemperatureConversionError(int Ident)/* overload */ : EUnitConversionError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall ETemperatureConversionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EUnitConversionError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall ETemperatureConversionError(const System::UnicodeString Msg, int AHelpContext) : EUnitConversionError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall ETemperatureConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EUnitConversionError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall ETemperatureConversionError(int Ident, int AHelpContext)/* overload */ : EUnitConversionError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall ETemperatureConversionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EUnitConversionError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~ETemperatureConversionError(void) { }
	
};


#pragma option push -b-
enum TTemperatureType { ttCelsius, ttFahrenheit, ttKelvin, ttRankine, ttReaumur };
#pragma option pop

//-- var, const, procedure ---------------------------------------------------
#define CelsiusFreezingPoint  (0.000000E+00)
#define FahrenheitFreezingPoint  (3.200000E+01)
#define KelvinFreezingPoint  (2.731500E+02)
#define CelsiusBoilingPoint  (1.000000E+02)
#define FahrenheitBoilingPoint  (2.120000E+02)
#define KelvinBoilingPoint  (3.731500E+02)
#define CelsiusAbsoluteZero  (-2.731500E+02)
#define FahrenheitAbsoluteZero  (-4.596700E+02)
#define KelvinAbsoluteZero  (0.000000E+00)
#define RankineAbsoluteZero  (0.000000E+00)
#define RankineAtFahrenheitZero  (4.596700E+02)
#define RankineFreezingPoint  (4.916700E+02)
static const Extended RankineBoilingPoint = 6.716700E+02;
#define ReaumurAbsoluteZero  (-2.185200E+02)
#define ReaumurFreezingPoint  (0.000000E+00)
#define ReaumurBoilingPoint  (8.000000E+01)
extern PACKAGE System::Extended DegPerCycle;
extern PACKAGE System::Extended DegPerGrad;
extern PACKAGE System::Extended DegPerRad;
extern PACKAGE System::Extended GradPerCycle;
extern PACKAGE System::Extended GradPerDeg;
extern PACKAGE System::Extended GradPerRad;
extern PACKAGE System::Extended RadPerCycle;
extern PACKAGE System::Extended RadPerDeg;
extern PACKAGE System::Extended RadPerGrad;
extern PACKAGE System::Extended CyclePerDeg;
extern PACKAGE System::Extended CyclePerGrad;
extern PACKAGE System::Extended CyclePerRad;
#define ArcMinutesPerDeg  (6.000000E+01)
#define ArcSecondsPerArcMinute  (6.000000E+01)
#define ArcSecondsPerDeg  (3.600000E+03)
static const Extended DegPerArcMinute = 1.666667E-02;
static const Extended DegPerArcSecond = 2.777778E-04;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE int __fastcall HowAOneLinerCanBiteYou(const int Step, const int Max);
extern PACKAGE int __fastcall MakePercentage(const int Step, const int Max);
extern PACKAGE System::Extended __fastcall CelsiusToFahrenheit(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall CelsiusToKelvin(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall CelsiusToRankine(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall CelsiusToReaumur(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall FahrenheitToCelsius(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall FahrenheitToKelvin(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall FahrenheitToRankine(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall FahrenheitToReaumur(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall KelvinToCelsius(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall KelvinToFahrenheit(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall KelvinToRankine(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall KelvinToReaumur(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall RankineToCelsius(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall RankineToFahrenheit(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall RankineToKelvin(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall RankineToReaumur(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall ReaumurToCelsius(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall ReaumurToFahrenheit(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall ReaumurToKelvin(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall ReaumurToRankine(const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall ConvertTemperature(const TTemperatureType FromType, const TTemperatureType ToType, const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall CelsiusTo(TTemperatureType ToType, const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall FahrenheitTo(TTemperatureType ToType, const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall KelvinTo(TTemperatureType ToType, const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall RankineTo(TTemperatureType ToType, const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall ReaumurTo(TTemperatureType ToType, const System::Extended Temperature);
extern PACKAGE System::Extended __fastcall CycleToDeg(const System::Extended Cycles);
extern PACKAGE System::Extended __fastcall CycleToGrad(const System::Extended Cycles);
extern PACKAGE System::Extended __fastcall CycleToRad(const System::Extended Cycles);
extern PACKAGE System::Extended __fastcall DegToGrad(const System::Extended Degrees);
extern PACKAGE System::Extended __fastcall DegToCycle(const System::Extended Degrees);
extern PACKAGE System::Extended __fastcall DegToRad(const System::Extended Degrees);
extern PACKAGE System::Extended __fastcall GradToCycle(const System::Extended Grads);
extern PACKAGE System::Extended __fastcall GradToDeg(const System::Extended Grads);
extern PACKAGE System::Extended __fastcall GradToRad(const System::Extended Grads);
extern PACKAGE System::Extended __fastcall RadToCycle(const System::Extended Radians);
extern PACKAGE System::Extended __fastcall RadToDeg(const System::Extended Radians);
extern PACKAGE System::Extended __fastcall RadToGrad(const System::Extended Radians);
extern PACKAGE System::Extended __fastcall DmsToDeg(const int D, const int M, const System::Extended S);
extern PACKAGE System::Extended __fastcall DmsToRad(const int D, const int M, const System::Extended S);
extern PACKAGE void __fastcall DegToDms(const System::Extended Degrees, /* out */ int &D, /* out */ int &M, /* out */ System::Extended &S);
extern PACKAGE System::UnicodeString __fastcall DegToDmsStr(const System::Extended Degrees, const unsigned SecondPrecision = (unsigned)(0x3));
extern PACKAGE void __fastcall CartesianToCylinder(const System::Extended X, const System::Extended Y, const System::Extended Z, /* out */ System::Extended &R, /* out */ System::Extended &Phi, /* out */ System::Extended &Zeta);
extern PACKAGE void __fastcall CartesianToPolar(const System::Extended X, const System::Extended Y, /* out */ System::Extended &R, /* out */ System::Extended &Phi);
extern PACKAGE void __fastcall CartesianToSpheric(const System::Extended X, const System::Extended Y, const System::Extended Z, /* out */ System::Extended &Rho, /* out */ System::Extended &Phi, /* out */ System::Extended &Theta);
extern PACKAGE void __fastcall CylinderToCartesian(const System::Extended R, const System::Extended Phi, const System::Extended Zeta, /* out */ System::Extended &X, /* out */ System::Extended &Y, /* out */ System::Extended &Z);
extern PACKAGE void __fastcall PolarToCartesian(const System::Extended R, const System::Extended Phi, /* out */ System::Extended &X, /* out */ System::Extended &Y);
extern PACKAGE void __fastcall SphericToCartesian(const System::Extended Rho, const System::Extended Theta, const System::Extended Phi, /* out */ System::Extended &X, /* out */ System::Extended &Y, /* out */ System::Extended &Z);
extern PACKAGE System::Extended __fastcall CmToInch(const System::Extended Cm);
extern PACKAGE System::Extended __fastcall InchToCm(const System::Extended Inch);
extern PACKAGE System::Extended __fastcall FeetToMetre(const System::Extended Feet);
extern PACKAGE System::Extended __fastcall MetreToFeet(const System::Extended Metre);
extern PACKAGE System::Extended __fastcall YardToMetre(const System::Extended Yard);
extern PACKAGE System::Extended __fastcall MetreToYard(const System::Extended Metre);
extern PACKAGE System::Extended __fastcall NmToKm(const System::Extended Nm);
extern PACKAGE System::Extended __fastcall KmToNm(const System::Extended Km);
extern PACKAGE System::Extended __fastcall KmToSm(const System::Extended Km);
extern PACKAGE System::Extended __fastcall SmToKm(const System::Extended Sm);
extern PACKAGE System::Extended __fastcall LitreToGalUs(const System::Extended Litre);
extern PACKAGE System::Extended __fastcall GalUsToLitre(const System::Extended GalUs);
extern PACKAGE System::Extended __fastcall GalUsToGalCan(const System::Extended GalUs);
extern PACKAGE System::Extended __fastcall GalCanToGalUs(const System::Extended GalCan);
extern PACKAGE System::Extended __fastcall GalUsToGalUk(const System::Extended GalUs);
extern PACKAGE System::Extended __fastcall GalUkToGalUs(const System::Extended GalUk);
extern PACKAGE System::Extended __fastcall LitreToGalCan(const System::Extended Litre);
extern PACKAGE System::Extended __fastcall GalCanToLitre(const System::Extended GalCan);
extern PACKAGE System::Extended __fastcall LitreToGalUk(const System::Extended Litre);
extern PACKAGE System::Extended __fastcall GalUkToLitre(const System::Extended GalUk);
extern PACKAGE System::Extended __fastcall KgToLb(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall LbToKg(const System::Extended Lb);
extern PACKAGE System::Extended __fastcall KgToOz(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall OzToKg(const System::Extended Oz);
extern PACKAGE System::Extended __fastcall QrUsToKg(const System::Extended Qr);
extern PACKAGE System::Extended __fastcall QrUkToKg(const System::Extended Qr);
extern PACKAGE System::Extended __fastcall KgToQrUs(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall KgToQrUk(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall CwtUsToKg(const System::Extended Cwt);
extern PACKAGE System::Extended __fastcall CwtUkToKg(const System::Extended Cwt);
extern PACKAGE System::Extended __fastcall KgToCwtUs(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall KgToCwtUk(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall LtonToKg(const System::Extended Lton);
extern PACKAGE System::Extended __fastcall StonToKg(const System::Extended STon);
extern PACKAGE System::Extended __fastcall KgToLton(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall KgToSton(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall KgToKarat(const System::Extended Kg);
extern PACKAGE System::Extended __fastcall KaratToKg(const System::Extended Karat);
extern PACKAGE System::Extended __fastcall PascalToBar(const System::Extended Pa);
extern PACKAGE System::Extended __fastcall PascalToAt(const System::Extended Pa);
extern PACKAGE System::Extended __fastcall PascalToTorr(const System::Extended Pa);
extern PACKAGE System::Extended __fastcall BarToPascal(const System::Extended Bar);
extern PACKAGE System::Extended __fastcall AtToPascal(const System::Extended At);
extern PACKAGE System::Extended __fastcall TorrToPascal(const System::Extended Torr);
extern PACKAGE System::Extended __fastcall KnotToMs(const System::Extended Knot);
extern PACKAGE System::Extended __fastcall HpElectricToWatt(const System::Extended HpE);
extern PACKAGE System::Extended __fastcall HpMetricToWatt(const System::Extended HpM);
extern PACKAGE System::Extended __fastcall MsToKnot(const System::Extended Ms);
extern PACKAGE System::Extended __fastcall WattToHpElectric(const System::Extended W);
extern PACKAGE System::Extended __fastcall WattToHpMetric(const System::Extended W);

}	/* namespace Jclunitconv */
using namespace Jclunitconv;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclunitconvHPP
