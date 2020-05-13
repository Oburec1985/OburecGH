// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advgridlookupbar.pas' rev: 21.00

#ifndef AdvgridlookupbarHPP
#define AdvgridlookupbarHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Advlookupbar.hpp>	// Pascal unit
#include <Advgrid.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advgridlookupbar
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TAdvGridLookupBar;
class PASCALIMPLEMENTATION TAdvGridLookupBar : public Advlookupbar::TAdvLookupBar
{
	typedef Advlookupbar::TAdvLookupBar inherited;
	
private:
	Advgrid::TAdvStringGrid* FGrid;
	int FColumn;
	bool FSelChange;
	void __fastcall SetColumn(const int Value);
	void __fastcall SetGrid(const Advgrid::TAdvStringGrid* Value);
	
protected:
	void __fastcall SelectionChange(int Col, int Row);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	virtual void __fastcall DoLookupClick(const Advlookupbar::TCharRec &ACurrentChar);
	virtual void __fastcall DoLookup(const Advlookupbar::TCharRec &ACurrentChar);
	void __fastcall DoSyncGrid(int Row);
	
public:
	__fastcall virtual TAdvGridLookupBar(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvGridLookupBar(void);
	
__published:
	__property Advgrid::TAdvStringGrid* Grid = {read=FGrid, write=SetGrid};
	__property int Column = {read=FColumn, write=SetColumn, default=-1};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvGridLookupBar(HWND ParentWindow) : Advlookupbar::TAdvLookupBar(ParentWindow) { }
	
private:
	void *__ITAdvStringGridSelect;	/* Advgrid::ITAdvStringGridSelect */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Advgrid::_di_ITAdvStringGridSelect()
	{
		Advgrid::_di_ITAdvStringGridSelect intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITAdvStringGridSelect*(void) { return (ITAdvStringGridSelect*)&__ITAdvStringGridSelect; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Advgridlookupbar */
using namespace Advgridlookupbar;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvgridlookupbarHPP
