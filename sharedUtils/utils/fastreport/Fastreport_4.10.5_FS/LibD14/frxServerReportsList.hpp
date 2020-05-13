// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserverreportslist.pas' rev: 21.00

#ifndef FrxserverreportslistHPP
#define FrxserverreportslistHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Frxservertemplates.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Syncobjs.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserverreportslist
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxServerReportsListItem;
class PASCALIMPLEMENTATION TfrxServerReportsListItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FFileName;
	System::UnicodeString FDescription;
	System::UnicodeString FName;
	Classes::TStringList* FGroups;
	int FCacheLatency;
	
public:
	__fastcall virtual TfrxServerReportsListItem(Classes::TCollection* Collection);
	__fastcall virtual ~TfrxServerReportsListItem(void);
	
__published:
	__property System::UnicodeString FileName = {read=FFileName, write=FFileName};
	__property System::UnicodeString ReportName = {read=FName, write=FName};
	__property System::UnicodeString Description = {read=FDescription, write=FDescription};
	__property Classes::TStringList* Groups = {read=FGroups};
	__property int CacheLatency = {read=FCacheLatency, write=FCacheLatency, nodefault};
};


class DELPHICLASS TfrxServerReportsList;
class PASCALIMPLEMENTATION TfrxServerReportsList : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
private:
	System::UnicodeString FReportsPath;
	TfrxServerReportsListItem* __fastcall GetItems(int Index);
	void __fastcall BuildListInFolder(const System::UnicodeString Folder);
	HIDESBASE TfrxServerReportsListItem* __fastcall GetItem(System::UnicodeString Name);
	
public:
	__fastcall TfrxServerReportsList(void);
	__fastcall virtual ~TfrxServerReportsList(void);
	__property TfrxServerReportsListItem* Items[int Index] = {read=GetItems};
	void __fastcall BuildListOfReports(void);
	int __fastcall GetCacheLatency(const System::UnicodeString FileName);
	bool __fastcall GetGroupMembership(const System::UnicodeString FileName, const System::UnicodeString Group);
	
__published:
	HIDESBASE TfrxServerReportsListItem* __fastcall Add(void);
	__property System::UnicodeString ReportsPath = {read=FReportsPath, write=FReportsPath};
	void __fastcall GetReports4Group(const System::UnicodeString GroupName, System::UnicodeString &Html, System::UnicodeString &Lines);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxServerReportsList* ReportsList;

}	/* namespace Frxserverreportslist */
using namespace Frxserverreportslist;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverreportslistHPP
