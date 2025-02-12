// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Zlibh.pas' rev: 21.00

#ifndef ZlibhHPP
#define ZlibhHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#define ZEXPORT __fastcall
#define ZEXPORTVA __cdecl
#define __MACTYPES__
#include <ZLib.hpp>
namespace Zlibh {
typedef Zlib::TZStreamRec z_stream_s;
}

namespace Zlibh
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall IsZLibLoaded(void);
extern PACKAGE bool __fastcall LoadZLib(void);
extern PACKAGE void __fastcall UnloadZLib(void);

}	/* namespace Zlibh */
using namespace Zlibh;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// ZlibhHPP
