// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcltimezones.pas' rev: 21.00

#ifndef JcltimezonesHPP
#define JcltimezonesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcltimezones
{
//-- type declarations -------------------------------------------------------
struct TJclTZIValueInfo
{
	
public:
	int Bias;
	int StandardBias;
	int DaylightBias;
	_SYSTEMTIME StandardDate;
	_SYSTEMTIME DaylightDate;
};


struct TJclTimeZoneRegInfo;
typedef TJclTimeZoneRegInfo *PJclTimeZoneRegInfo;

struct TJclTimeZoneRegInfo
{
	
public:
	System::UnicodeString DisplayDesc;
	System::UnicodeString StandardName;
	System::UnicodeString DaylightName;
	int SortIndex;
	System::UnicodeString MapID;
	TJclTZIValueInfo TZI;
};


typedef bool __fastcall (__closure *TJclTimeZoneCallBackFunc)(const TJclTimeZoneRegInfo &TimeZoneRec);

class DELPHICLASS TJclTimeZoneInfo;
class PASCALIMPLEMENTATION TJclTimeZoneInfo : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FStandardName;
	System::UnicodeString FDaylightName;
	System::UnicodeString FTZDescription;
	int FSortIndex;
	System::UnicodeString FMapID;
	TJclTZIValueInfo FBiasInfo;
	int __fastcall GetActiveBias(void);
	System::TDateTime __fastcall GetCurrentDateTime(void);
	System::TDateTime __fastcall GetDaylightSavingsStartDate(void);
	System::UnicodeString __fastcall GetGMTOffset(void);
	System::TDateTime __fastcall GetStandardStartDate(void);
	bool __fastcall GetSupportsDaylightSavings(void);
	unsigned __fastcall GetTimeZoneType(const TJclTZIValueInfo &TZI);
	
public:
	void __fastcall Assign(const TJclTimeZoneRegInfo &Source);
	void __fastcall ApplyTimeZone(void);
	System::UnicodeString __fastcall DayLightSavingsPeriod(void);
	bool __fastcall DateTimeIsInDaylightSavings(System::TDateTime ADateTime);
	System::TDateTime __fastcall StandardStartDateInYear(const int AYear);
	System::TDateTime __fastcall DaylightStartDateInYear(const int AYear);
	__property int ActiveBias = {read=GetActiveBias, nodefault};
	__property System::TDateTime CurrentDateTime = {read=GetCurrentDateTime};
	__property System::UnicodeString DaylightName = {read=FDaylightName};
	__property System::TDateTime DaylightSavingsStartDate = {read=GetDaylightSavingsStartDate};
	__property System::UnicodeString DisplayDescription = {read=FTZDescription};
	__property System::UnicodeString GMTOffset = {read=GetGMTOffset};
	__property System::UnicodeString MapID = {read=FMapID};
	__property int SortIndex = {read=FSortIndex, nodefault};
	__property System::UnicodeString StandardName = {read=FStandardName};
	__property System::TDateTime StandardStartDate = {read=GetStandardStartDate};
	__property bool SupportsDaylightSavings = {read=GetSupportsDaylightSavings, nodefault};
public:
	/* TObject.Create */ inline __fastcall TJclTimeZoneInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTimeZoneInfo(void) { }
	
};


class DELPHICLASS TJclTimeZones;
class PASCALIMPLEMENTATION TJclTimeZones : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclTimeZoneInfo* operator[](int Index) { return Items[Index]; }
	
private:
	int FActiveTimeZoneIndex;
	Contnrs::TObjectList* FTimeZones;
	bool FAutoAdjustEnabled;
	bool __fastcall GetAutoAdjustEnabled(void);
	TJclTimeZoneInfo* __fastcall GetActiveTimeZoneInfo(void);
	int __fastcall GetCount(void);
	TJclTimeZoneInfo* __fastcall GetItem(int Index);
	void __fastcall LoadTimeZones(void);
	bool __fastcall TimeZoneCallback(const TJclTimeZoneRegInfo &TimeZoneRec);
	
public:
	__fastcall TJclTimeZones(void);
	__fastcall virtual ~TJclTimeZones(void);
	bool __fastcall SetDateTime(System::TDateTime DateTime);
	void __fastcall SetAutoAdjustEnabled(bool Value);
	__property int Count = {read=GetCount, nodefault};
	__property TJclTimeZoneInfo* Items[int Index] = {read=GetItem/*, default*/};
	__property TJclTimeZoneInfo* ActiveTimeZone = {read=GetActiveTimeZoneInfo};
	__property bool AutoAdjustEnabled = {read=FAutoAdjustEnabled, write=FAutoAdjustEnabled, nodefault};
};


class DELPHICLASS EDaylightSavingsNotSupported;
class PASCALIMPLEMENTATION EDaylightSavingsNotSupported : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EDaylightSavingsNotSupported(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EDaylightSavingsNotSupported(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EDaylightSavingsNotSupported(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EDaylightSavingsNotSupported(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EDaylightSavingsNotSupported(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EDaylightSavingsNotSupported(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EDaylightSavingsNotSupported(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EDaylightSavingsNotSupported(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EDaylightSavingsNotSupported(void) { }
	
};


class DELPHICLASS EAutoAdjustNotEnabled;
class PASCALIMPLEMENTATION EAutoAdjustNotEnabled : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EAutoAdjustNotEnabled(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EAutoAdjustNotEnabled(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EAutoAdjustNotEnabled(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EAutoAdjustNotEnabled(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EAutoAdjustNotEnabled(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EAutoAdjustNotEnabled(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EAutoAdjustNotEnabled(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EAutoAdjustNotEnabled(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EAutoAdjustNotEnabled(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall EnumTimeZones(TJclTimeZoneCallBackFunc CallBackFunc);
extern PACKAGE bool __fastcall CurrentTimeZoneSupportsDaylightSavings(void);
extern PACKAGE System::TDateTime __fastcall DateCurrentTimeZoneClocksChangeToDaylightSavings(void);
extern PACKAGE System::TDateTime __fastcall DateCurrentTimeZoneClocksChangeToStandard(void);
extern PACKAGE System::UnicodeString __fastcall GetCurrentTimeZoneDescription(void);
extern PACKAGE System::UnicodeString __fastcall GetCurrentTimeZoneDaylightSavingsPeriod(void);
extern PACKAGE System::UnicodeString __fastcall GetCurrentTimeZoneGMTOffset(void);
extern PACKAGE int __fastcall GetCurrentTimeZoneUTCBias(void);
extern PACKAGE System::TDateTime __fastcall UTCNow(void);
extern PACKAGE System::UnicodeString __fastcall GetWMIScheduledJobUTCTime(System::TDateTime Time);
extern PACKAGE bool __fastcall IsAutoAdjustEnabled(void);

}	/* namespace Jcltimezones */
using namespace Jcltimezones;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcltimezonesHPP
