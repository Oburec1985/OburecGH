// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Vcardbase64.pas' rev: 21.00

#ifndef Vcardbase64HPP
#define Vcardbase64HPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Vcardbase64
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::AnsiString __fastcall Decode64(const System::AnsiString S);
extern PACKAGE System::UnicodeString __fastcall Encode64(const System::UnicodeString Input);

}	/* namespace Vcardbase64 */
using namespace Vcardbase64;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Vcardbase64HPP
