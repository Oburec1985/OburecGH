// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fs_ipascal.pas' rev: 21.00

#ifndef Fs_ipascalHPP
#define Fs_ipascalHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Fs_itools.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fs_ipascal
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfsPascal;
class PASCALIMPLEMENTATION TfsPascal : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfsPascal(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfsPascal(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall fsModifyPascalForFR2(void);

}	/* namespace Fs_ipascal */
using namespace Fs_ipascal;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Fs_ipascalHPP
