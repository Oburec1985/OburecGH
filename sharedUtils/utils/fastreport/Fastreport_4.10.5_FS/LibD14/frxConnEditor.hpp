// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxconneditor.pas' rev: 21.00

#ifndef FrxconneditorHPP
#define FrxconneditorHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxconnitemedit.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxconneditor
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxConnEditorForm;
class PASCALIMPLEMENTATION TfrxConnEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* NewB;
	Stdctrls::TButton* DeleteB;
	Comctrls::TListView* ConnLV;
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* EditB;
	Stdctrls::TButton* TestB;
	void __fastcall NewBClick(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall DeleteBClick(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall OKBClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall EditBClick(System::TObject* Sender);
	void __fastcall TestBClick(System::TObject* Sender);
	
private:
	void __fastcall ReadADOConnections(void);
	void __fastcall SaveADOConnections(void);
	
public:
	Frxclass::TfrxReport* Report;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxConnEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxConnEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxConnEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxConnEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxconneditor */
using namespace Frxconneditor;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxconneditorHPP
