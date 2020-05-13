// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdock.pas' rev: 21.00

#ifndef FrxdockHPP
#define FrxdockHPP

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
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Inifiles.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdock
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxTBPanel;
class PASCALIMPLEMENTATION TfrxTBPanel : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
protected:
	virtual void __fastcall SetParent(Controls::TWinControl* AParent);
	
public:
	__fastcall virtual TfrxTBPanel(Classes::TComponent* AOwner);
	virtual void __fastcall Paint(void);
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxTBPanel(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxTBPanel(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


class DELPHICLASS TfrxDockSite;
class PASCALIMPLEMENTATION TfrxDockSite : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
private:
	int FPanelSize;
	int FSavedSize;
	Controls::TControl* FSplitter;
	Controls::TWinControl* FTopParentWin;
	
public:
	__fastcall virtual TfrxDockSite(Classes::TComponent* AOwner);
	DYNAMIC void __fastcall DockDrop(Controls::TDragDockObject* Source, int X, int Y);
	DYNAMIC void __fastcall DockOver(Controls::TDragDockObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	DYNAMIC bool __fastcall DoUnDock(Controls::TWinControl* NewTarget, Controls::TControl* Client);
	virtual void __fastcall SetParent(Controls::TWinControl* AParent);
	virtual void __fastcall SetBounds(int ALeft, int ATop, int AWidth, int AHeight);
	DYNAMIC void __fastcall ReloadDockedControl(const System::UnicodeString AControlName, Controls::TControl* &AControl);
	__property int SavedSize = {read=FSavedSize, write=FSavedSize, nodefault};
	__property Controls::TWinControl* TopParentWin = {read=FTopParentWin, write=FTopParentWin};
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxDockSite(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxDockSite(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxSaveToolbarPosition(Inifiles::TCustomIniFile* Ini, Comctrls::TToolBar* t);
extern PACKAGE void __fastcall frxRestoreToolbarPosition(Inifiles::TCustomIniFile* Ini, Comctrls::TToolBar* t);
extern PACKAGE void __fastcall frxSaveDock(Inifiles::TCustomIniFile* Ini, TfrxDockSite* d);
extern PACKAGE void __fastcall frxRestoreDock(Inifiles::TCustomIniFile* Ini, TfrxDockSite* d);
extern PACKAGE void __fastcall frxSaveFormPosition(Inifiles::TCustomIniFile* Ini, Forms::TForm* f);
extern PACKAGE void __fastcall frxRestoreFormPosition(Inifiles::TCustomIniFile* Ini, Forms::TForm* f);

}	/* namespace Frxdock */
using namespace Frxdock;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdockHPP
