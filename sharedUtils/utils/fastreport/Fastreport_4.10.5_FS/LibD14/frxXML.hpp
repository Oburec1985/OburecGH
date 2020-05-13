// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxxml.pas' rev: 21.00

#ifndef FrxxmlHPP
#define FrxxmlHPP

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
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxxml
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxInvalidXMLException;
class PASCALIMPLEMENTATION TfrxInvalidXMLException : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall TfrxInvalidXMLException(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall TfrxInvalidXMLException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall TfrxInvalidXMLException(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall TfrxInvalidXMLException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall TfrxInvalidXMLException(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall TfrxInvalidXMLException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall TfrxInvalidXMLException(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall TfrxInvalidXMLException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~TfrxInvalidXMLException(void) { }
	
};


class DELPHICLASS TfrxXMLItem;
class PASCALIMPLEMENTATION TfrxXMLItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TfrxXMLItem* operator[](int Index) { return Items[Index]; }
	
private:
	void *FData;
	System::Byte FHiOffset;
	Classes::TList* FItems;
	bool FLoaded;
	int FLoOffset;
	bool FModified;
	System::UnicodeString FName;
	TfrxXMLItem* FParent;
	System::UnicodeString FText;
	bool FUnloadable;
	System::UnicodeString FValue;
	int __fastcall GetCount(void);
	TfrxXMLItem* __fastcall GetItems(int Index);
	__int64 __fastcall GetOffset(void);
	void __fastcall SetOffset(const __int64 Value);
	System::UnicodeString __fastcall GetProp(System::UnicodeString Index);
	void __fastcall SetProp(System::UnicodeString Index, const System::UnicodeString Value);
	
public:
	__fastcall TfrxXMLItem(void);
	__fastcall virtual ~TfrxXMLItem(void);
	void __fastcall AddItem(TfrxXMLItem* Item);
	void __fastcall Clear(void);
	void __fastcall InsertItem(int Index, TfrxXMLItem* Item);
	TfrxXMLItem* __fastcall Add(void);
	int __fastcall Find(const System::UnicodeString Name);
	TfrxXMLItem* __fastcall FindItem(const System::UnicodeString Name);
	int __fastcall IndexOf(TfrxXMLItem* Item);
	bool __fastcall PropExists(const System::UnicodeString Index);
	TfrxXMLItem* __fastcall Root(void);
	void __fastcall DeleteProp(const System::UnicodeString Index);
	__property int Count = {read=GetCount, nodefault};
	__property void * Data = {read=FData, write=FData};
	__property TfrxXMLItem* Items[int Index] = {read=GetItems/*, default*/};
	__property bool Loaded = {read=FLoaded, nodefault};
	__property bool Modified = {read=FModified, write=FModified, nodefault};
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property __int64 Offset = {read=GetOffset, write=SetOffset};
	__property TfrxXMLItem* Parent = {read=FParent};
	__property System::UnicodeString Prop[System::UnicodeString Index] = {read=GetProp, write=SetProp};
	__property System::UnicodeString Text = {read=FText, write=FText};
	__property bool Unloadable = {read=FUnloadable, write=FUnloadable, nodefault};
	__property System::UnicodeString Value = {read=FValue, write=FValue};
};


class DELPHICLASS TfrxXMLDocument;
class PASCALIMPLEMENTATION TfrxXMLDocument : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FAutoIndent;
	TfrxXMLItem* FRoot;
	System::UnicodeString FTempDir;
	System::UnicodeString FTempFile;
	Classes::TStream* FTempStream;
	bool FTempFileCreated;
	bool FOldVersion;
	void __fastcall CreateTempFile(void);
	void __fastcall DeleteTempFile(void);
	
public:
	__fastcall TfrxXMLDocument(void);
	__fastcall virtual ~TfrxXMLDocument(void);
	void __fastcall Clear(void);
	void __fastcall LoadItem(TfrxXMLItem* Item);
	void __fastcall UnloadItem(TfrxXMLItem* Item);
	void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall LoadFromStream(Classes::TStream* Stream, bool AllowPartialLoading = false);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	__property bool AutoIndent = {read=FAutoIndent, write=FAutoIndent, nodefault};
	__property TfrxXMLItem* Root = {read=FRoot};
	__property System::UnicodeString TempDir = {read=FTempDir, write=FTempDir};
	__property bool OldVersion = {read=FOldVersion, nodefault};
};


class DELPHICLASS TfrxXMLReader;
class PASCALIMPLEMENTATION TfrxXMLReader : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	char *FBuffer;
	int FBufPos;
	int FBufEnd;
	__int64 FPosition;
	__int64 FSize;
	Classes::TStream* FStream;
	bool FOldFormat;
	void __fastcall SetPosition(const __int64 Value);
	void __fastcall ReadBuffer(void);
	void __fastcall ReadItem(System::UnicodeString &NameS, System::UnicodeString &Text);
	
public:
	__fastcall TfrxXMLReader(Classes::TStream* Stream);
	__fastcall virtual ~TfrxXMLReader(void);
	void __fastcall RaiseException(void);
	void __fastcall ReadHeader(void);
	void __fastcall ReadRootItem(TfrxXMLItem* Item, bool ReadChildren = true);
	__property __int64 Position = {read=FPosition, write=SetPosition};
	__property __int64 Size = {read=FSize};
};


class DELPHICLASS TfrxXMLWriter;
class PASCALIMPLEMENTATION TfrxXMLWriter : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FAutoIndent;
	System::AnsiString FBuffer;
	Classes::TStream* FStream;
	Classes::TStream* FTempStream;
	void __fastcall FlushBuffer(void);
	void __fastcall WriteLn(const System::AnsiString s);
	void __fastcall WriteItem(TfrxXMLItem* Item, int Level = 0x0);
	
public:
	__fastcall TfrxXMLWriter(Classes::TStream* Stream);
	void __fastcall WriteHeader(void);
	void __fastcall WriteRootItem(TfrxXMLItem* RootItem);
	__property Classes::TStream* TempStream = {read=FTempStream, write=FTempStream};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxXMLWriter(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::UnicodeString __fastcall frxStrToXML(const System::UnicodeString s);
extern PACKAGE System::UnicodeString __fastcall frxXMLToStr(const System::UnicodeString s);
extern PACKAGE System::UnicodeString __fastcall frxValueToXML(const System::Variant &Value);

}	/* namespace Frxxml */
using namespace Frxxml;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxxmlHPP
