// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxnetutils.pas' rev: 21.00

#ifndef FrxnetutilsHPP
#define FrxnetutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Registry.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxnetutils
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::UnicodeString __fastcall GMTDateTimeToRFCDateTime(const System::TDateTime D);
extern PACKAGE System::UnicodeString __fastcall DateTimeToRFCDateTime(const System::TDateTime D);
extern PACKAGE System::UnicodeString __fastcall PadLeft(const System::UnicodeString S, const System::WideChar PadChar, const int Len);
extern PACKAGE System::UnicodeString __fastcall PadRight(const System::UnicodeString S, const System::WideChar PadChar, const int Len);
extern PACKAGE System::AnsiString __fastcall Base64Encode(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall Base64Decode(const System::AnsiString S);
extern PACKAGE System::UnicodeString __fastcall GetFileMIMEType(const System::UnicodeString FileName);
extern PACKAGE System::UnicodeString __fastcall GetSocketErrorText(const int ErrorCode);
extern PACKAGE void __fastcall PMessages(void);
extern PACKAGE System::AnsiString __fastcall ParseHeaderField(const System::AnsiString Field, const System::AnsiString Header);

}	/* namespace Frxnetutils */
using namespace Frxnetutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxnetutilsHPP
