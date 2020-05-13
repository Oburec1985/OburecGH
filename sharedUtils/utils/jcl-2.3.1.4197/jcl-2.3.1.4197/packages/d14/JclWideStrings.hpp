// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclwidestrings.pas' rev: 21.00

#ifndef JclwidestringsHPP
#define JclwidestringsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclwidestrings
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclWideStringError;
class PASCALIMPLEMENTATION EJclWideStringError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclWideStringError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclWideStringError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclWideStringError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclWideStringError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclWideStringError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclWideStringError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclWideStringError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclWideStringError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclWideStringError(void) { }
	
};


typedef Classes::TStrings TJclWideStrings;

typedef Classes::TStringList TJclWideStringList;

typedef Classes::TStringList TWideStringList;

typedef Classes::TStrings TWideStrings;

typedef Classes::TStringList TJclUnicodeStringList;

typedef Classes::TStrings TJclUnicodeStrings;

typedef Classes::TStringList TWStringList;

typedef Classes::TStrings TWStrings;

typedef System::WideChar * PWideMultiSz;

//-- var, const, procedure ---------------------------------------------------
static const System::WideChar WideNull = (System::WideChar)(0x0);
static const System::WideChar WideTabulator = (System::WideChar)(0x9);
static const System::WideChar WideSpace = (System::WideChar)(0x20);
static const System::WideChar WideLF = (System::WideChar)(0xa);
static const System::WideChar WideLineFeed = (System::WideChar)(0xa);
static const System::WideChar WideVerticalTab = (System::WideChar)(0xb);
static const System::WideChar WideFormFeed = (System::WideChar)(0xc);
static const System::WideChar WideCR = (System::WideChar)(0xd);
static const System::WideChar WideCarriageReturn = (System::WideChar)(0xd);
#define WideCRLF L"\r\n"
static const System::WideChar WideLineSeparator = (System::WideChar)(0x2028);
static const System::WideChar WideParagraphSeparator = (System::WideChar)(0x2029);
#define WideLineBreak L"\r\n"
static const System::WideChar BOM_LSB_FIRST = (System::WideChar)(0xfeff);
static const System::WideChar BOM_MSB_FIRST = (System::WideChar)(0xfffe);
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE System::WideChar __fastcall CharToWideChar(char Ch);
extern PACKAGE char __fastcall WideCharToChar(System::WideChar Ch);
extern PACKAGE void __fastcall MoveWideChar(const void *Source, void *Dest, int Count);
extern PACKAGE System::WideChar * __fastcall StrAllocW(int WideSize);
extern PACKAGE System::WideChar * __fastcall StrNewW(const System::WideChar * Str)/* overload */;
extern PACKAGE System::WideChar * __fastcall StrNewW(const System::WideString Str)/* overload */;
extern PACKAGE void __fastcall StrDisposeW(System::WideChar * Str);
extern PACKAGE void __fastcall StrDisposeAndNilW(System::WideChar * &Str);
extern PACKAGE int __fastcall StrCompW(const System::WideChar * Str1, const System::WideChar * Str2);
extern PACKAGE int __fastcall StrLCompW(const System::WideChar * Str1, const System::WideChar * Str2, int MaxLen);
extern PACKAGE int __fastcall StrICompW(const System::WideChar * Str1, const System::WideChar * Str2);
extern PACKAGE int __fastcall StrLICompW(const System::WideChar * Str1, const System::WideChar * Str2, int MaxLen);
extern PACKAGE int __fastcall StrLICompW2(const System::WideChar * Str1, const System::WideChar * Str2, int MaxLen);
extern PACKAGE System::WideChar * __fastcall StrPosW(const System::WideChar * Str, const System::WideChar * SubStr);
extern PACKAGE int __fastcall StrLenW(const System::WideChar * Str);
extern PACKAGE System::WideChar * __fastcall StrScanW(const System::WideChar * Str, System::WideChar Ch)/* overload */;
extern PACKAGE System::WideChar * __fastcall StrEndW(const System::WideChar * Str);
extern PACKAGE System::WideChar * __fastcall StrCopyW(System::WideChar * Dest, const System::WideChar * Source);
extern PACKAGE System::WideChar * __fastcall StrECopyW(System::WideChar * Dest, const System::WideChar * Source);
extern PACKAGE System::WideChar * __fastcall StrLCopyW(System::WideChar * Dest, const System::WideChar * Source, int MaxLen);
extern PACKAGE System::WideChar * __fastcall StrCatW(System::WideChar * Dest, const System::WideChar * Source);
extern PACKAGE System::WideChar * __fastcall StrLCatW(System::WideChar * Dest, const System::WideChar * Source, int MaxLen);
extern PACKAGE System::WideChar * __fastcall StrMoveW(System::WideChar * Dest, const System::WideChar * Source, int Count);
extern PACKAGE System::WideChar * __fastcall StrPCopyWW(System::WideChar * Dest, const System::WideString Source);
extern PACKAGE System::WideChar * __fastcall StrPLCopyWW(System::WideChar * Dest, const System::WideString Source, int MaxLen);
extern PACKAGE System::WideChar * __fastcall StrRScanW(const System::WideChar * Str, System::WideChar Chr);
extern PACKAGE void __fastcall StrSwapByteOrder(System::WideChar * Str);
extern PACKAGE int __fastcall StrNScanW(const System::WideChar * Str1, const System::WideChar * Str2);
extern PACKAGE int __fastcall StrRNScanW(const System::WideChar * Str1, const System::WideChar * Str2);
extern PACKAGE System::WideChar * __fastcall StrScanW(System::WideChar * Str, System::WideChar Chr, int StrLen)/* overload */;
extern PACKAGE int __fastcall StrBufSizeW(const System::WideChar * Str);
extern PACKAGE System::WideChar * __fastcall StrPCopyW(System::WideChar * Dest, const System::AnsiString Source);
extern PACKAGE System::WideChar * __fastcall StrPLCopyW(System::WideChar * Dest, const System::AnsiString Source, int MaxLen);
extern PACKAGE int __fastcall WidePos(const System::WideString SubStr, const System::WideString S);
extern PACKAGE System::WideString __fastcall WideQuotedStr(const System::WideString S, System::WideChar Quote);
extern PACKAGE System::WideString __fastcall WideExtractQuotedStr(System::WideChar * &Src, System::WideChar Quote);
extern PACKAGE System::WideString __fastcall TrimW(const System::WideString S);
extern PACKAGE System::WideString __fastcall TrimLeftW(const System::WideString S);
extern PACKAGE System::WideString __fastcall TrimRightW(const System::WideString S);
extern PACKAGE System::WideString __fastcall WideReverse(const System::WideString AText);
extern PACKAGE void __fastcall WideReverseInPlace(System::WideString &S);
extern PACKAGE int __fastcall WideCompareText(const System::WideString S1, const System::WideString S2);
extern PACKAGE int __fastcall WideCompareStr(const System::WideString S1, const System::WideString S2);
extern PACKAGE System::WideString __fastcall WideUpperCase(const System::WideString S);
extern PACKAGE System::WideString __fastcall WideLowerCase(const System::WideString S);
extern PACKAGE int __fastcall TrimLeftLengthW(const System::WideString S);
extern PACKAGE int __fastcall TrimRightLengthW(const System::WideString S);
extern PACKAGE bool __fastcall WideStartsText(const System::WideString SubStr, const System::WideString S);
extern PACKAGE bool __fastcall WideStartsStr(const System::WideString SubStr, const System::WideString S);
extern PACKAGE System::WideChar * __fastcall StringsToMultiSz(System::WideChar * &Dest, const Classes::TStrings* Source);
extern PACKAGE void __fastcall MultiSzToStrings(const Classes::TStrings* Dest, const System::WideChar * Source);
extern PACKAGE int __fastcall MultiSzLength(const System::WideChar * Source);
extern PACKAGE void __fastcall AllocateMultiSz(System::WideChar * &Dest, int Len);
extern PACKAGE void __fastcall FreeMultiSz(System::WideChar * &Dest);
extern PACKAGE System::WideChar * __fastcall MultiSzDup(const System::WideChar * Source);

}	/* namespace Jclwidestrings */
using namespace Jclwidestrings;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclwidestringsHPP
