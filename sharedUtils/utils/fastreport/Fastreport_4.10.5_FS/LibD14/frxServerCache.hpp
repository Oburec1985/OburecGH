// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxservercache.pas' rev: 21.00

#ifndef FrxservercacheHPP
#define FrxservercacheHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Frxutils.hpp>	// Pascal unit
#include <Frxserverutils.hpp>	// Pascal unit
#include <Frxnetutils.hpp>	// Pascal unit
#include <Frxvariables.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxserverlog.hpp>	// Pascal unit
#include <Syncobjs.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxservercache
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxServerCacheItem;
class PASCALIMPLEMENTATION TfrxServerCacheItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FReportName;
	Frxvariables::TfrxVariables* FVariables;
	System::UnicodeString FFileName;
	System::TDateTime FExpTime;
	System::UnicodeString FSessionId;
	Classes::TStream* FStream;
	System::UnicodeString FInternalId;
	
public:
	__fastcall virtual TfrxServerCacheItem(Classes::TCollection* Collection);
	__fastcall virtual ~TfrxServerCacheItem(void);
	
__published:
	__property System::UnicodeString ReportName = {read=FReportName, write=FReportName};
	__property Frxvariables::TfrxVariables* Variables = {read=FVariables, write=FVariables};
	__property System::UnicodeString FileName = {read=FFileName, write=FFileName};
	__property System::TDateTime ExpTime = {read=FExpTime, write=FExpTime};
	__property System::UnicodeString SessionId = {read=FSessionId, write=FSessionId};
	__property Classes::TStream* Stream = {read=FStream, write=FStream};
	__property System::UnicodeString InternalId = {read=FInternalId, write=FInternalId};
};


class DELPHICLASS TfrxServerCacheSpool;
class PASCALIMPLEMENTATION TfrxServerCacheSpool : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
private:
	TfrxServerCacheItem* __fastcall GetItems(int Index);
	bool __fastcall EqualVariables(const Frxvariables::TfrxVariables* Var1, const Frxvariables::TfrxVariables* Var2);
	
public:
	__fastcall TfrxServerCacheSpool(void);
	__fastcall virtual ~TfrxServerCacheSpool(void);
	__property TfrxServerCacheItem* Items[int Index] = {read=GetItems};
	HIDESBASE void __fastcall Clear(void);
	
__published:
	HIDESBASE TfrxServerCacheItem* __fastcall Add(void);
	HIDESBASE TfrxServerCacheItem* __fastcall Insert(int Index);
	int __fastcall IndexOf(const System::UnicodeString ReportName, const Frxvariables::TfrxVariables* Variables, const System::UnicodeString SessionId);
};


class DELPHICLASS TfrxServerCache;
class PASCALIMPLEMENTATION TfrxServerCache : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
private:
	System::UnicodeString FCachePath;
	bool FActive;
	int FLatency;
	TfrxServerCacheSpool* FHeap;
	bool FMemoryCache;
	bool FThreadActive;
	void __fastcall SetActive(const bool Value);
	void __fastcall CleanUpFiles(void);
	void __fastcall RemoveExpired(void);
	
protected:
	virtual void __fastcall Execute(void);
	
public:
	__fastcall TfrxServerCache(void);
	__fastcall virtual ~TfrxServerCache(void);
	bool __fastcall GetCachedStream(const Frxclass::TfrxReport* Report, const System::UnicodeString ReportName, const Frxvariables::TfrxVariables* Variables, const System::UnicodeString Id);
	bool __fastcall GetCachedReportById(const Frxclass::TfrxReport* Report, const System::UnicodeString Id);
	void __fastcall Open(void);
	void __fastcall Close(void);
	void __fastcall Clear(void);
	void __fastcall AddReport(const Frxclass::TfrxReport* Report, const System::UnicodeString ReportName, const Frxvariables::TfrxVariables* Variables, const System::UnicodeString Id, const System::UnicodeString InternalId);
	__property bool Active = {read=FActive, write=SetActive, nodefault};
	__property System::UnicodeString CachePath = {read=FCachePath, write=FCachePath};
	__property int DefaultLatency = {read=FLatency, write=FLatency, nodefault};
	__property TfrxServerCacheSpool* Heap = {read=FHeap};
	__property bool MemoryCache = {read=FMemoryCache, write=FMemoryCache, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
#define CACHE_PREFIX L"$fr"
extern PACKAGE Syncobjs::TCriticalSection* CacheCS1;
extern PACKAGE TfrxServerCache* ReportCache;

}	/* namespace Frxservercache */
using namespace Frxservercache;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxservercacheHPP
