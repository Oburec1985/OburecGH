// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclstringconversions.pas' rev: 21.00

#ifndef JclstringconversionsHPP
#define JclstringconversionsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclstringconversions
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclStringConversionError;
class PASCALIMPLEMENTATION EJclStringConversionError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclStringConversionError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclStringConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclStringConversionError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclStringConversionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclStringConversionError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclStringConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclStringConversionError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclStringConversionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclStringConversionError(void) { }
	
};


class DELPHICLASS EJclUnexpectedEOSequenceError;
class PASCALIMPLEMENTATION EJclUnexpectedEOSequenceError : public EJclStringConversionError
{
	typedef EJclStringConversionError inherited;
	
public:
	__fastcall EJclUnexpectedEOSequenceError(void);
public:
	/* Exception.CreateFmt */ inline __fastcall EJclUnexpectedEOSequenceError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EJclStringConversionError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclUnexpectedEOSequenceError(int Ident)/* overload */ : EJclStringConversionError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclUnexpectedEOSequenceError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EJclStringConversionError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclUnexpectedEOSequenceError(const System::UnicodeString Msg, int AHelpContext) : EJclStringConversionError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclUnexpectedEOSequenceError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EJclStringConversionError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclUnexpectedEOSequenceError(int Ident, int AHelpContext)/* overload */ : EJclStringConversionError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclUnexpectedEOSequenceError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EJclStringConversionError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclUnexpectedEOSequenceError(void) { }
	
};


typedef bool __fastcall (*TJclStreamGetNextCharFunc)(Classes::TStream* S, /* out */ unsigned &Ch);

typedef bool __fastcall (*TJclStreamSkipCharsFunc)(Classes::TStream* S, int &NbSeq);

typedef bool __fastcall (*TJclStreamSetNextCharFunc)(Classes::TStream* S, unsigned Ch);

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall ExpandASCIIString(const char * Source, System::WideChar * Target, int Count);
extern PACKAGE unsigned __fastcall UTF8GetNextChar(const System::AnsiString S, int &StrPos);
extern PACKAGE int __fastcall UTF8GetNextBuffer(const System::AnsiString S, int &StrPos, Jclbase::TUCS4Array &Buffer, int &Start, int Count);
extern PACKAGE bool __fastcall UTF8GetNextCharFromStream(Classes::TStream* S, /* out */ unsigned &Ch);
extern PACKAGE int __fastcall UTF8GetNextBufferFromStream(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int &Start, int Count);
extern PACKAGE bool __fastcall UTF8SkipChars(const System::AnsiString S, int &StrPos, int &NbSeq);
extern PACKAGE bool __fastcall UTF8SkipCharsFromStream(Classes::TStream* S, int &NbSeq);
extern PACKAGE bool __fastcall UTF8SetNextChar(System::AnsiString &S, int &StrPos, unsigned Ch);
extern PACKAGE int __fastcall UTF8SetNextBuffer(System::AnsiString &S, int &StrPos, const Jclbase::TUCS4Array Buffer, int &Start, int Count);
extern PACKAGE bool __fastcall UTF8SetNextCharToStream(Classes::TStream* S, unsigned Ch);
extern PACKAGE int __fastcall UTF8SetNextBufferToStream(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int &Start, int Count);
extern PACKAGE unsigned __fastcall UTF16GetNextChar(const System::WideString S, int &StrPos)/* overload */;
extern PACKAGE int __fastcall UTF16GetNextBuffer(const System::WideString S, int &StrPos, Jclbase::TUCS4Array &Buffer, int &Start, int Count)/* overload */;
extern PACKAGE unsigned __fastcall UTF16GetNextChar(const System::UnicodeString S, int &StrPos)/* overload */;
extern PACKAGE int __fastcall UTF16GetNextBuffer(const System::UnicodeString S, int &StrPos, Jclbase::TUCS4Array &Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall UTF16GetNextCharFromStream(Classes::TStream* S, /* out */ unsigned &Ch);
extern PACKAGE int __fastcall UTF16GetNextBufferFromStream(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int &Start, int Count);
extern PACKAGE unsigned __fastcall UTF16GetPreviousChar(const System::WideString S, int &StrPos)/* overload */;
extern PACKAGE unsigned __fastcall UTF16GetPreviousChar(const System::UnicodeString S, int &StrPos)/* overload */;
extern PACKAGE bool __fastcall UTF16SkipChars(const System::WideString S, int &StrPos, int &NbSeq)/* overload */;
extern PACKAGE bool __fastcall UTF16SkipChars(const System::UnicodeString S, int &StrPos, int &NbSeq)/* overload */;
extern PACKAGE bool __fastcall UTF16SkipCharsFromStream(Classes::TStream* S, int &NbSeq);
extern PACKAGE bool __fastcall UTF16SetNextChar(System::WideString &S, int &StrPos, unsigned Ch)/* overload */;
extern PACKAGE int __fastcall UTF16SetNextBuffer(System::WideString &S, int &StrPos, const Jclbase::TUCS4Array Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall UTF16SetNextChar(System::UnicodeString &S, int &StrPos, unsigned Ch)/* overload */;
extern PACKAGE int __fastcall UTF16SetNextBuffer(System::UnicodeString &S, int &StrPos, const Jclbase::TUCS4Array Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall UTF16SetNextCharToStream(Classes::TStream* S, unsigned Ch);
extern PACKAGE int __fastcall UTF16SetNextBufferToStream(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int &Start, int Count);
extern PACKAGE unsigned __fastcall AnsiGetNextChar(const System::AnsiString S, int &StrPos)/* overload */;
extern PACKAGE int __fastcall AnsiGetNextBuffer(const System::AnsiString S, int &StrPos, Jclbase::TUCS4Array &Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall AnsiGetNextCharFromStream(Classes::TStream* S, /* out */ unsigned &Ch)/* overload */;
extern PACKAGE int __fastcall AnsiGetNextBufferFromStream(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int &Start, int Count)/* overload */;
extern PACKAGE unsigned __fastcall AnsiGetNextChar(const System::AnsiString S, System::Word CodePage, int &StrPos)/* overload */;
extern PACKAGE int __fastcall AnsiGetNextBuffer(const System::AnsiString S, System::Word CodePage, int &StrPos, Jclbase::TUCS4Array &Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall AnsiGetNextCharFromStream(Classes::TStream* S, System::Word CodePage, /* out */ unsigned &Ch)/* overload */;
extern PACKAGE int __fastcall AnsiGetNextBufferFromStream(Classes::TStream* S, System::Word CodePage, Jclbase::TUCS4Array &Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall AnsiSkipChars(const System::AnsiString S, int &StrPos, int &NbSeq);
extern PACKAGE bool __fastcall AnsiSkipCharsFromStream(Classes::TStream* S, int &NbSeq);
extern PACKAGE bool __fastcall AnsiSetNextChar(System::AnsiString &S, int &StrPos, unsigned Ch)/* overload */;
extern PACKAGE int __fastcall AnsiSetNextBuffer(System::AnsiString &S, int &StrPos, const Jclbase::TUCS4Array Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall AnsiSetNextCharToStream(Classes::TStream* S, unsigned Ch)/* overload */;
extern PACKAGE int __fastcall AnsiSetNextBufferToStream(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall AnsiSetNextChar(System::AnsiString &S, System::Word CodePage, int &StrPos, unsigned Ch)/* overload */;
extern PACKAGE int __fastcall AnsiSetNextBuffer(System::AnsiString &S, System::Word CodePage, int &StrPos, const Jclbase::TUCS4Array Buffer, int &Start, int Count)/* overload */;
extern PACKAGE bool __fastcall AnsiSetNextCharToStream(Classes::TStream* S, System::Word CodePage, unsigned Ch)/* overload */;
extern PACKAGE int __fastcall AnsiSetNextBufferToStream(Classes::TStream* S, System::Word CodePage, const Jclbase::TUCS4Array Buffer, int &Start, int Count)/* overload */;
extern PACKAGE unsigned __fastcall StringGetNextChar(const System::UnicodeString S, int &StrPos);
extern PACKAGE int __fastcall StringGetNextBuffer(const System::UnicodeString S, int &StrPos, Jclbase::TUCS4Array &Buffer, int &Start, int Count);
extern PACKAGE bool __fastcall StringSkipChars(const System::UnicodeString S, int &StrPos, int &NbSeq);
extern PACKAGE bool __fastcall StringSetNextChar(System::UnicodeString &S, int &StrPos, unsigned Ch);
extern PACKAGE int __fastcall StringSetNextBuffer(System::UnicodeString &S, int &StrPos, const Jclbase::TUCS4Array Buffer, int &Start, int Count);
extern PACKAGE System::AnsiString __fastcall WideStringToUTF8(const System::WideString S);
extern PACKAGE System::WideString __fastcall UTF8ToWideString(const System::AnsiString S);
extern PACKAGE Jclbase::TUCS4Array __fastcall WideStringToUCS4(const System::WideString S);
extern PACKAGE System::WideString __fastcall UCS4ToWideString(const Jclbase::TUCS4Array S);
extern PACKAGE System::AnsiString __fastcall AnsiStringToUTF8(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall UTF8ToAnsiString(const System::AnsiString S);
extern PACKAGE System::WideString __fastcall AnsiStringToUTF16(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall UTF16ToAnsiString(const System::WideString S);
extern PACKAGE Jclbase::TUCS4Array __fastcall AnsiStringToUCS4(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall UCS4ToAnsiString(const Jclbase::TUCS4Array S);
extern PACKAGE System::AnsiString __fastcall StringToUTF8(const System::UnicodeString S);
extern PACKAGE bool __fastcall TryStringToUTF8(const System::UnicodeString S, /* out */ System::AnsiString &D);
extern PACKAGE System::UnicodeString __fastcall UTF8ToString(const System::AnsiString S);
extern PACKAGE bool __fastcall TryUTF8ToString(const System::AnsiString S, /* out */ System::UnicodeString &D);
extern PACKAGE System::WideString __fastcall StringToUTF16(const System::UnicodeString S);
extern PACKAGE bool __fastcall TryStringToUTF16(const System::UnicodeString S, /* out */ System::WideString &D);
extern PACKAGE System::UnicodeString __fastcall UTF16ToString(const System::WideString S);
extern PACKAGE bool __fastcall TryUTF16ToString(const System::WideString S, /* out */ System::UnicodeString &D);
extern PACKAGE Jclbase::TUCS4Array __fastcall StringToUCS4(const System::UnicodeString S);
extern PACKAGE bool __fastcall TryStringToUCS4(const System::UnicodeString S, /* out */ Jclbase::TUCS4Array &D);
extern PACKAGE System::UnicodeString __fastcall UCS4ToString(const Jclbase::TUCS4Array S);
extern PACKAGE bool __fastcall TryUCS4ToString(const Jclbase::TUCS4Array S, /* out */ System::UnicodeString &D);
extern PACKAGE System::WideString __fastcall UTF8ToUTF16(const System::AnsiString S);
extern PACKAGE bool __fastcall TryUTF8ToUTF16(const System::AnsiString S, /* out */ System::WideString &D);
extern PACKAGE System::AnsiString __fastcall UTF16ToUTF8(const System::WideString S);
extern PACKAGE bool __fastcall TryUTF16ToUTF8(const System::WideString S, /* out */ System::AnsiString &D);
extern PACKAGE Jclbase::TUCS4Array __fastcall UTF8ToUCS4(const System::AnsiString S);
extern PACKAGE bool __fastcall TryUTF8ToUCS4(const System::AnsiString S, /* out */ Jclbase::TUCS4Array &D);
extern PACKAGE System::AnsiString __fastcall UCS4ToUTF8(const Jclbase::TUCS4Array S);
extern PACKAGE bool __fastcall TryUCS4ToUTF8(const Jclbase::TUCS4Array S, /* out */ System::AnsiString &D);
extern PACKAGE Jclbase::TUCS4Array __fastcall UTF16ToUCS4(const System::WideString S);
extern PACKAGE bool __fastcall TryUTF16ToUCS4(const System::WideString S, /* out */ Jclbase::TUCS4Array &D);
extern PACKAGE System::WideString __fastcall UCS4ToUTF16(const Jclbase::TUCS4Array S);
extern PACKAGE bool __fastcall TryUCS4ToUTF16(const Jclbase::TUCS4Array S, /* out */ System::WideString &D);
extern PACKAGE int __fastcall UTF8CharCount(const System::AnsiString S);
extern PACKAGE int __fastcall UTF16CharCount(const System::WideString S);
extern PACKAGE int __fastcall UCS2CharCount(const System::WideString S);
extern PACKAGE int __fastcall UCS4CharCount(const Jclbase::TUCS4Array S);
extern PACKAGE bool __fastcall GetUCS4CharAt(const System::AnsiString UTF8Str, int Index, /* out */ unsigned &Value)/* overload */;
extern PACKAGE bool __fastcall GetUCS4CharAt(const System::WideString WideStr, int Index, /* out */ unsigned &Value, bool IsUTF16 = true)/* overload */;
extern PACKAGE bool __fastcall GetUCS4CharAt(const Jclbase::TUCS4Array UCS4Str, int Index, /* out */ unsigned &Value)/* overload */;
extern PACKAGE char __fastcall UCS4ToAnsiChar(unsigned Value);
extern PACKAGE System::WideChar __fastcall UCS4ToWideChar(unsigned Value);
extern PACKAGE System::WideChar __fastcall UCS4ToChar(unsigned Value);
extern PACKAGE unsigned __fastcall AnsiCharToUCS4(char Value);
extern PACKAGE unsigned __fastcall WideCharToUCS4(System::WideChar Value);
extern PACKAGE unsigned __fastcall CharToUCS4(System::WideChar Value);

}	/* namespace Jclstringconversions */
using namespace Jclstringconversions;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclstringconversionsHPP
