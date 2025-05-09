// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Hardlinks.pas' rev: 21.00

#ifndef HardlinksHPP
#define HardlinksHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Hardlinks
{
//-- type declarations -------------------------------------------------------
typedef BOOL __stdcall (*TFNCreateHardLinkW)(System::WideChar * szLinkName, System::WideChar * szLinkTarget, Windows::PSecurityAttributes lpSecurityAttributes);

typedef BOOL __stdcall (*TFNCreateHardLinkA)(char * szLinkName, char * szLinkTarget, Windows::PSecurityAttributes lpSecurityAttributes);

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE unsigned hNtDll;
extern PACKAGE bool bRtdlFunctionsLoaded;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Hardlinks */
using namespace Hardlinks;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// HardlinksHPP
