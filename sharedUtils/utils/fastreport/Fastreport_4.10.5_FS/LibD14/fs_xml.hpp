// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fs_xml.pas' rev: 21.00

#ifndef Fs_xmlHPP
#define Fs_xmlHPP

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
#include <Ansistrings.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fs_xml
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfsXMLItem;
class PASCALIMPLEMENTATION TfsXMLItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TfsXMLItem* operator[](int Index) { return Items[Index]; }
	
private:
	void *FData;
	Classes::TList* FItems;
	System::UnicodeString FName;
	TfsXMLItem* FParent;
	System::UnicodeString FText;
	int __fastcall GetCount(void);
	TfsXMLItem* __fastcall GetItems(int Index);
	System::UnicodeString __fastcall GetProp(System::UnicodeString Index);
	void __fastcall SetProp(System::UnicodeString Index, const System::UnicodeString Value);
	void __fastcall SetParent(const TfsXMLItem* Value);
	
public:
	__fastcall virtual ~TfsXMLItem(void);
	void __fastcall AddItem(TfsXMLItem* Item);
	void __fastcall Assign(TfsXMLItem* Item);
	void __fastcall Clear(void);
	void __fastcall InsertItem(int Index, TfsXMLItem* Item);
	TfsXMLItem* __fastcall Add(void);
	int __fastcall Find(const System::UnicodeString Name);
	TfsXMLItem* __fastcall FindItem(const System::UnicodeString Name);
	int __fastcall IndexOf(TfsXMLItem* Item);
	bool __fastcall PropExists(const System::UnicodeString Index);
	TfsXMLItem* __fastcall Root(void);
	__property int Count = {read=GetCount, nodefault};
	__property void * Data = {read=FData, write=FData};
	__property TfsXMLItem* Items[int Index] = {read=GetItems/*, default*/};
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property TfsXMLItem* Parent = {read=FParent, write=SetParent};
	__property System::UnicodeString Prop[System::UnicodeString Index] = {read=GetProp, write=SetProp};
	__property System::UnicodeString Text = {read=FText, write=FText};
public:
	/* TObject.Create */ inline __fastcall TfsXMLItem(void) : System::TObject() { }
	
};


class DELPHICLASS TfsXMLDocument;
class PASCALIMPLEMENTATION TfsXMLDocument : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FAutoIndent;
	TfsXMLItem* FRoot;
	
public:
	__fastcall TfsXMLDocument(void);
	__fastcall virtual ~TfsXMLDocument(void);
	void __fastcall Clear(void);
	void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	__property bool AutoIndent = {read=FAutoIndent, write=FAutoIndent, nodefault};
	__property TfsXMLItem* Root = {read=FRoot};
};


class DELPHICLASS TfsXMLReader;
class PASCALIMPLEMENTATION TfsXMLReader : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	char *FBuffer;
	int FBufPos;
	int FBufEnd;
	__int64 FPosition;
	__int64 FSize;
	Classes::TStream* FStream;
	void __fastcall SetPosition(const __int64 Value);
	void __fastcall ReadBuffer(void);
	void __fastcall ReadItem(System::UnicodeString &NameS, System::UnicodeString &Text);
	
public:
	__fastcall TfsXMLReader(Classes::TStream* Stream);
	__fastcall virtual ~TfsXMLReader(void);
	void __fastcall RaiseException(void);
	void __fastcall ReadHeader(void);
	void __fastcall ReadRootItem(TfsXMLItem* Item);
	__property __int64 Position = {read=FPosition, write=SetPosition};
	__property __int64 Size = {read=FSize};
};


class DELPHICLASS TfsXMLWriter;
class PASCALIMPLEMENTATION TfsXMLWriter : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FAutoIndent;
	System::AnsiString FBuffer;
	Classes::TStream* FStream;
	Classes::TStream* FTempStream;
	void __fastcall FlushBuffer(void);
	void __fastcall WriteLn(const System::AnsiString s);
	void __fastcall WriteItem(TfsXMLItem* Item, int Level = 0x0);
	
public:
	__fastcall TfsXMLWriter(Classes::TStream* Stream);
	void __fastcall WriteHeader(void);
	void __fastcall WriteRootItem(TfsXMLItem* RootItem);
	__property Classes::TStream* TempStream = {read=FTempStream, write=FTempStream};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsXMLWriter(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::UnicodeString __fastcall StrToXML(const System::UnicodeString s);
extern PACKAGE System::UnicodeString __fastcall XMLToStr(const System::UnicodeString s);
extern PACKAGE System::UnicodeString __fastcall ValueToXML(const System::Variant &Value);

}	/* namespace Fs_xml */
using namespace Fs_xml;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Fs_xmlHPP
