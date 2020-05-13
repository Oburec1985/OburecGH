// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fqbutils.pas' rev: 21.00

#ifndef FqbutilsHPP
#define FqbutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Fqbzlib.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fqbutils
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE unsigned __fastcall fqbStringCRC32(const System::AnsiString Str);
extern PACKAGE System::UnicodeString __fastcall fqbGetUniqueFileName(const System::UnicodeString Prefix);
extern PACKAGE System::UnicodeString __fastcall fqbTrim(const System::UnicodeString Input, const Sysutils::TSysCharSet &EArray);
extern PACKAGE System::UnicodeString __fastcall fqbParse(System::UnicodeString Char, System::UnicodeString S, int Count, bool Last = false);
extern PACKAGE System::AnsiString __fastcall fqbBase64Decode(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall fqbBase64Encode(const System::AnsiString S);
extern PACKAGE System::UnicodeString __fastcall fqbCompress(const System::UnicodeString S);
extern PACKAGE System::UnicodeString __fastcall fqbDeCompress(const System::UnicodeString S);
extern PACKAGE void __fastcall fqbDeflateStream(Classes::TStream* Source, Classes::TStream* Dest, Fqbzlib::TZCompressionLevel Compression = (Fqbzlib::TZCompressionLevel)(0x2));
extern PACKAGE void __fastcall fqbInflateStream(Classes::TStream* Source, Classes::TStream* Dest);

}	/* namespace Fqbutils */
using namespace Fqbutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FqbutilsHPP
