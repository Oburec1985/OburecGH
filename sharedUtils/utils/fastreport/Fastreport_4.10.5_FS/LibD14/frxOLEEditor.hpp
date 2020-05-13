// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxoleeditor.pas' rev: 21.00

#ifndef FrxoleeditorHPP
#define FrxoleeditorHPP

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
#include <Frxcustomeditors.hpp>	// Pascal unit
#include <Frxdsgnintf.hpp>	// Pascal unit
#include <Frxole.hpp>	// Pascal unit
#include <Olectnrs.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxoleeditor
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxOLEEditor;
class PASCALIMPLEMENTATION TfrxOLEEditor : public Frxcustomeditors::TfrxViewEditor
{
	typedef Frxcustomeditors::TfrxViewEditor inherited;
	
public:
	virtual bool __fastcall Edit(void);
	virtual bool __fastcall HasEditor(void);
	virtual void __fastcall GetMenuItems(void);
	virtual bool __fastcall Execute(int Tag, bool Checked);
public:
	/* TfrxComponentEditor.Create */ inline __fastcall TfrxOLEEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu) : Frxcustomeditors::TfrxViewEditor(Component, Designer, Menu) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxOLEEditor(void) { }
	
};


class DELPHICLASS TfrxOleEditorForm;
class PASCALIMPLEMENTATION TfrxOleEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* InsertB;
	Stdctrls::TButton* EditB;
	Stdctrls::TButton* CloseB;
	Olectnrs::TOleContainer* OleContainer;
	void __fastcall InsertBClick(System::TObject* Sender);
	void __fastcall EditBClick(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxOleEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxOleEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxOleEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxOleEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxoleeditor */
using namespace Frxoleeditor;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxoleeditorHPP
