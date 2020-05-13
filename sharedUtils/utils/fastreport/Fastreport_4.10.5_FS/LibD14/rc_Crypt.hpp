// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Rc_crypt.pas' rev: 21.00

#ifndef Rc_cryptHPP
#define Rc_cryptHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Rc_apiref.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Rc_crypt
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
static const Byte _KEYLength = 0x80;
extern PACKAGE System::AnsiString __fastcall ExpandKey(System::AnsiString sKey, int iLength);
extern PACKAGE System::AnsiString __fastcall EnCryptString(const System::AnsiString sMessage, System::AnsiString sKeyMaterial);
extern PACKAGE System::AnsiString __fastcall DeCryptString(const System::AnsiString sMessage, System::AnsiString sKeyMaterial);

}	/* namespace Rc_crypt */
using namespace Rc_crypt;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Rc_cryptHPP
