// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcodeutils.pas' rev: 21.00

#ifndef FrxcodeutilsHPP
#define FrxcodeutilsHPP

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
#include <Typinfo.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcodeutils
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxAddCodeRes(void);
extern PACKAGE void __fastcall frxGetEventHandlersList(Classes::TStrings* Code, const System::UnicodeString Language, Typinfo::PTypeInfo EventType, Classes::TStrings* List);
extern PACKAGE int __fastcall frxLocateEventHandler(Classes::TStrings* Code, const System::UnicodeString Language, const System::UnicodeString EventName);
extern PACKAGE int __fastcall frxLocateMainProc(Classes::TStrings* Code, const System::UnicodeString Language);
extern PACKAGE int __fastcall frxAddEvent(Classes::TStrings* Code, const System::UnicodeString Language, Typinfo::PTypeInfo EventType, const System::UnicodeString EventName);
extern PACKAGE void __fastcall frxEmptyCode(Classes::TStrings* Code, const System::UnicodeString Language);

}	/* namespace Frxcodeutils */
using namespace Frxcodeutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcodeutilsHPP
