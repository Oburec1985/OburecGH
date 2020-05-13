// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxpicturecache.pas' rev: 21.00

#ifndef FrxpicturecacheHPP
#define FrxpicturecacheHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxpicturecache
{
//-- type declarations -------------------------------------------------------
#pragma pack(push,1)
struct TfrxCacheItem
{
	
public:
	int Segment;
	int Offset;
};
#pragma pack(pop)


typedef TfrxCacheItem *PfrxCacheItem;

class DELPHICLASS TfrxCacheList;
class PASCALIMPLEMENTATION TfrxCacheList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	PfrxCacheItem operator[](int Index) { return Items[Index]; }
	
private:
	PfrxCacheItem __fastcall Get(int Index);
	
protected:
	Classes::TList* FItems;
	void __fastcall Clear(void);
	
public:
	__fastcall TfrxCacheList(void);
	__fastcall virtual ~TfrxCacheList(void);
	PfrxCacheItem __fastcall Add(void);
	int __fastcall Count(void);
	__property PfrxCacheItem Items[int Index] = {read=Get/*, default*/};
};


class DELPHICLASS TfrxFileStream;
class PASCALIMPLEMENTATION TfrxFileStream : public Classes::TFileStream
{
	typedef Classes::TFileStream inherited;
	
private:
	unsigned FSz;
	
public:
	virtual int __fastcall Seek(int Offset, System::Word Origin)/* overload */;
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
public:
	/* TFileStream.Create */ inline __fastcall TfrxFileStream(const System::UnicodeString AFileName, System::Word Mode)/* overload */ : Classes::TFileStream(AFileName, Mode) { }
	/* TFileStream.Destroy */ inline __fastcall virtual ~TfrxFileStream(void) { }
	
};


class DELPHICLASS TfrxMemoryStream;
class PASCALIMPLEMENTATION TfrxMemoryStream : public Classes::TMemoryStream
{
	typedef Classes::TMemoryStream inherited;
	
private:
	unsigned FSz;
	
public:
	virtual int __fastcall Seek(int Offset, System::Word Origin)/* overload */;
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
public:
	/* TMemoryStream.Destroy */ inline __fastcall virtual ~TfrxMemoryStream(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TfrxMemoryStream(void) : Classes::TMemoryStream() { }
	
};


class DELPHICLASS TfrxPictureCache;
class PASCALIMPLEMENTATION TfrxPictureCache : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TfrxCacheList* FItems;
	Classes::TList* FCacheStreamList;
	Classes::TStringList* FTempFile;
	System::UnicodeString FTempDir;
	bool FUseFileCache;
	void __fastcall Add(void);
	void __fastcall SetTempDir(const System::UnicodeString Value);
	void __fastcall SetUseFileCache(const bool Value);
	
public:
	__fastcall TfrxPictureCache(void);
	__fastcall virtual ~TfrxPictureCache(void);
	void __fastcall Clear(void);
	void __fastcall AddPicture(Frxclass::TfrxPictureView* Picture);
	void __fastcall GetPicture(Frxclass::TfrxPictureView* Picture);
	void __fastcall SaveToXML(Frxxml::TfrxXMLItem* Item);
	void __fastcall LoadFromXML(Frxxml::TfrxXMLItem* Item);
	void __fastcall AddSegment(void);
	__property bool UseFileCache = {read=FUseFileCache, write=SetUseFileCache, nodefault};
	__property System::UnicodeString TempDir = {read=FTempDir, write=SetTempDir};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxpicturecache */
using namespace Frxpicturecache;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxpicturecacheHPP
