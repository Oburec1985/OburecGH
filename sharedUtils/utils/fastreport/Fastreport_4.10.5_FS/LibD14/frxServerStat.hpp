// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserverstat.pas' rev: 21.00

#ifndef FrxserverstatHPP
#define FrxserverstatHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserverstat
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxServerStatistic;
class PASCALIMPLEMENTATION TfrxServerStatistic : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::TDateTime FStartTime;
	int __fastcall GetCurrentReportsCount(void);
	int __fastcall GetCurrentSessionsCount(void);
	int __fastcall GetMaxReportsCount(void);
	int __fastcall GetMaxSessionsCount(void);
	int __fastcall GetTotalErrors(void);
	int __fastcall GetTotalReportsCount(void);
	int __fastcall GetTotalSessionsCount(void);
	int __fastcall GetUpTimeDays(void);
	int __fastcall GetUpTimeHours(void);
	int __fastcall GetUpTimeMins(void);
	int __fastcall GetUpTimeSecs(void);
	int __fastcall GetTotalCacheHits(void);
	System::UnicodeString __fastcall GetFormatUpTime(void);
	int __fastcall GetCacheCount(void);
	
public:
	__fastcall TfrxServerStatistic(void);
	
__published:
	__property int CurrentReportsCount = {read=GetCurrentReportsCount, nodefault};
	__property int CurrentSessionsCount = {read=GetCurrentSessionsCount, nodefault};
	__property int MaxReportsCount = {read=GetMaxReportsCount, nodefault};
	__property int MaxSessionsCount = {read=GetMaxSessionsCount, nodefault};
	__property int TotalErrors = {read=GetTotalErrors, nodefault};
	__property int TotalReportsCount = {read=GetTotalReportsCount, nodefault};
	__property int TotalSessionsCount = {read=GetTotalSessionsCount, nodefault};
	__property int UpTimeDays = {read=GetUpTimeDays, nodefault};
	__property int UpTimeHours = {read=GetUpTimeHours, nodefault};
	__property int UpTimeMins = {read=GetUpTimeMins, nodefault};
	__property int UpTimeSecs = {read=GetUpTimeSecs, nodefault};
	__property int TotalCacheHits = {read=GetTotalCacheHits, nodefault};
	__property int CurrentCacheCount = {read=GetCacheCount, nodefault};
	__property System::UnicodeString FormatUpTime = {read=GetFormatUpTime};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxServerStatistic(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxServerStatistic* ServerStatistic;

}	/* namespace Frxserverstat */
using namespace Frxserverstat;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverstatHPP
