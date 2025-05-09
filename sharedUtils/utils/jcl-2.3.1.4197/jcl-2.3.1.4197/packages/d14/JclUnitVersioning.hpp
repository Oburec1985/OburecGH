// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclunitversioning.pas' rev: 21.00

#ifndef JclunitversioningHPP
#define JclunitversioningHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclunitversioning
{
//-- type declarations -------------------------------------------------------
struct TUnitVersionInfo;
typedef TUnitVersionInfo *PUnitVersionInfo;

struct TUnitVersionInfo
{
	
public:
	System::WideChar *RCSfile;
	System::WideChar *Revision;
	System::WideChar *Date;
	System::WideChar *LogPath;
	System::WideChar *Extra;
	void *Data;
};


class DELPHICLASS TUnitVersion;
class PASCALIMPLEMENTATION TUnitVersion : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TUnitVersionInfo *FInfo;
	
public:
	__fastcall TUnitVersion(PUnitVersionInfo AInfo);
	System::UnicodeString __fastcall RCSfile(void);
	System::UnicodeString __fastcall Revision(void);
	System::UnicodeString __fastcall Date(void);
	System::UnicodeString __fastcall Extra(void);
	System::UnicodeString __fastcall LogPath(void);
	void * __fastcall Data(void);
	System::TDateTime __fastcall DateTime(void);
	System::UnicodeString __fastcall Summary(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TUnitVersion(void) { }
	
};


class DELPHICLASS TUnitVersioningModule;
class PASCALIMPLEMENTATION TUnitVersioningModule : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TUnitVersion* operator[](int Index) { return Items[Index]; }
	
private:
	unsigned FInstance;
	Contnrs::TObjectList* FItems;
	TUnitVersion* __fastcall GetItems(int Index);
	int __fastcall GetCount(void);
	void __fastcall Add(PUnitVersionInfo Info);
	int __fastcall IndexOfInfo(PUnitVersionInfo Info);
	
public:
	__fastcall TUnitVersioningModule(unsigned AInstance);
	__fastcall virtual ~TUnitVersioningModule(void);
	int __fastcall IndexOf(const System::UnicodeString RCSfile, const System::UnicodeString LogPath = L"*");
	TUnitVersion* __fastcall FindUnit(const System::UnicodeString RCSfile, const System::UnicodeString LogPath = L"*");
	__property unsigned Instance = {read=FInstance, nodefault};
	__property int Count = {read=GetCount, nodefault};
	__property TUnitVersion* Items[int Index] = {read=GetItems/*, default*/};
};


class DELPHICLASS TCustomUnitVersioningProvider;
class PASCALIMPLEMENTATION TCustomUnitVersioningProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__fastcall virtual TCustomUnitVersioningProvider(void);
	virtual void __fastcall LoadModuleUnitVersioningInfo(unsigned Instance);
	virtual void __fastcall ReleaseModuleUnitVersioningInfo(unsigned Instance);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TCustomUnitVersioningProvider(void) { }
	
};


typedef TMetaClass* TUnitVersioningProviderClass;

class DELPHICLASS TUnitVersioning;
class PASCALIMPLEMENTATION TUnitVersioning : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TUnitVersion* operator[](int Index) { return Items[Index]; }
	
private:
	Contnrs::TObjectList* FModules;
	Contnrs::TObjectList* FProviders;
	TUnitVersion* __fastcall GetItem(int Index);
	int __fastcall GetCount(void);
	int __fastcall GetModuleCount(void);
	TUnitVersioningModule* __fastcall GetModule(int Index);
	void __fastcall UnregisterModule(TUnitVersioningModule* Module)/* overload */;
	void __fastcall ValidateModules(void);
	virtual void __fastcall Add(unsigned Instance, PUnitVersionInfo Info);
	virtual void __fastcall UnregisterModule(unsigned Instance)/* overload */;
	
public:
	__fastcall TUnitVersioning(void);
	__fastcall virtual ~TUnitVersioning(void);
	void __fastcall RegisterProvider(TUnitVersioningProviderClass AProviderClass);
	void __fastcall LoadModuleUnitVersioningInfo(unsigned Instance);
	int __fastcall IndexOf(const System::UnicodeString RCSfile, const System::UnicodeString LogPath = L"*");
	TUnitVersion* __fastcall FindUnit(const System::UnicodeString RCSfile, const System::UnicodeString LogPath = L"*");
	__property int ModuleCount = {read=GetModuleCount, nodefault};
	__property TUnitVersioningModule* Modules[int Index] = {read=GetModule};
	__property int Count = {read=GetCount, nodefault};
	__property TUnitVersion* Items[int Index] = {read=GetItem/*, default*/};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TUnitVersionInfo UnitVersioning;
extern PACKAGE TUnitVersioning* __fastcall GetUnitVersioning(void);
extern PACKAGE void __fastcall RegisterUnitVersion(unsigned Instance, const TUnitVersionInfo &Info);
extern PACKAGE void __fastcall UnregisterUnitVersion(unsigned Instance);
extern PACKAGE void __fastcall ExportUnitVersioningToFile(System::UnicodeString iFileName);

}	/* namespace Jclunitversioning */
using namespace Jclunitversioning;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclunitversioningHPP
