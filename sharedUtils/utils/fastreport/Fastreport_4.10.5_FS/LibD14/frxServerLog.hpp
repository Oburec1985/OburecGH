// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserverlog.pas' rev: 21.00

#ifndef FrxserverlogHPP
#define FrxserverlogHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Syncobjs.hpp>	// Pascal unit
#include <Frxutils.hpp>	// Pascal unit
#include <Frxserverutils.hpp>	// Pascal unit
#include <Frxnetutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserverlog
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxServerLog;
class PASCALIMPLEMENTATION TfrxServerLog : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
private:
	int FCurrentReports;
	int FCurrentSessions;
	int FErrorsCount;
	Classes::TStringList* FLevelFName;
	Classes::TList* FLevels;
	System::UnicodeString FLogDir;
	bool FLogging;
	int FMaxReports;
	int FMaxReportTime;
	int FMaxSessions;
	int FTotalReports;
	int FTotalReportTime;
	int FTotalSessions;
	int FMaxLogSize;
	int FMaxLogFiles;
	Syncobjs::TCriticalSection* FCS;
	int FTotalCacheHits;
	bool FThreadActive;
	void __fastcall WriteFile(const System::UnicodeString FName, const System::UnicodeString Text);
	void __fastcall LogRotate(const System::UnicodeString FName);
	
protected:
	virtual void __fastcall Execute(void);
	
public:
	__fastcall TfrxServerLog(void);
	__fastcall virtual ~TfrxServerLog(void);
	int __fastcall AddLevel(const System::UnicodeString FileName);
	void __fastcall Clear(void);
	void __fastcall Flush(void);
	void __fastcall ErrorReached(void);
	void __fastcall StartAddReportTime(int i);
	void __fastcall StatAddCurrentReport(void);
	void __fastcall StatAddCurrentSession(void);
	void __fastcall StatAddCacheHit(void);
	void __fastcall StatAddReports(int i);
	void __fastcall StatAddSessions(int i);
	void __fastcall StatRemoveCurrentReport(void);
	void __fastcall StatRemoveCurrentSession(void);
	void __fastcall Write(const int Level, const System::UnicodeString Msg);
	__property bool Active = {read=FLogging, write=FLogging, nodefault};
	__property int CurrentReports = {read=FCurrentSessions, write=FCurrentReports, nodefault};
	__property int CurrentSessions = {read=FCurrentSessions, write=FCurrentSessions, nodefault};
	__property int ErrorsCount = {read=FErrorsCount, write=FErrorsCount, nodefault};
	__property System::UnicodeString LogDir = {read=FLogDir, write=FLogDir};
	__property int MaxReports = {read=FMaxReports, write=FMaxReports, nodefault};
	__property int MaxReportTime = {read=FMaxReportTime, write=FMaxReportTime, nodefault};
	__property int MaxSessions = {read=FMaxSessions, write=FMaxSessions, nodefault};
	__property int TotalReports = {read=FTotalReports, write=FTotalReports, nodefault};
	__property int TotalReportTime = {read=FTotalReportTime, write=FTotalReportTime, nodefault};
	__property int TotalSessions = {read=FTotalSessions, write=FTotalSessions, nodefault};
	__property int MaxLogSize = {read=FMaxLogSize, write=FMaxLogSize, nodefault};
	__property int MaxLogFiles = {read=FMaxLogFiles, write=FMaxLogFiles, nodefault};
	__property int TotalCacheHits = {read=FTotalCacheHits, write=FTotalCacheHits, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxServerLog* LogWriter;
static const ShortInt ERROR_LEVEL = 0x0;
static const ShortInt ACCESS_LEVEL = 0x1;
static const ShortInt REFERER_LEVEL = 0x2;
static const ShortInt AGENT_LEVEL = 0x3;
static const ShortInt SERVER_LEVEL = 0x4;

}	/* namespace Frxserverlog */
using namespace Frxserverlog;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverlogHPP
