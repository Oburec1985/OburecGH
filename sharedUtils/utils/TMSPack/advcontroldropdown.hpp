// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advcontroldropdown.pas' rev: 21.00

#ifndef AdvcontroldropdownHPP
#define AdvcontroldropdownHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Advdropdown.hpp>	// Pascal unit
#include <Mask.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advcontroldropdown
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TAdvControlDropDown;
class PASCALIMPLEMENTATION TAdvControlDropDown : public Advdropdown::TAdvDropDown
{
	typedef Advdropdown::TAdvDropDown inherited;
	
protected:
	virtual void __fastcall Loaded(void);
	
public:
	__fastcall virtual TAdvControlDropDown(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvControlDropDown(void);
	
__published:
	__property Control;
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvControlDropDown(HWND ParentWindow) : Advdropdown::TAdvDropDown(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Advcontroldropdown */
using namespace Advcontroldropdown;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvcontroldropdownHPP
