// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcustomeditors.pas' rev: 21.00

#ifndef FrxcustomeditorsHPP
#define FrxcustomeditorsHPP

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
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxdmpclass.hpp>	// Pascal unit
#include <Frxdsgnintf.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcustomeditors
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxViewEditor;
class PASCALIMPLEMENTATION TfrxViewEditor : public Frxdsgnintf::TfrxComponentEditor
{
	typedef Frxdsgnintf::TfrxComponentEditor inherited;
	
public:
	virtual void __fastcall GetMenuItems(void);
	virtual bool __fastcall Execute(int Tag, bool Checked);
public:
	/* TfrxComponentEditor.Create */ inline __fastcall TfrxViewEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu) : Frxdsgnintf::TfrxComponentEditor(Component, Designer, Menu) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxViewEditor(void) { }
	
};


class DELPHICLASS TfrxCustomMemoEditor;
class PASCALIMPLEMENTATION TfrxCustomMemoEditor : public TfrxViewEditor
{
	typedef TfrxViewEditor inherited;
	
public:
	virtual void __fastcall GetMenuItems(void);
	virtual bool __fastcall Execute(int Tag, bool Checked);
public:
	/* TfrxComponentEditor.Create */ inline __fastcall TfrxCustomMemoEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu) : TfrxViewEditor(Component, Designer, Menu) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxCustomMemoEditor(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxcustomeditors */
using namespace Frxcustomeditors;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcustomeditorsHPP
