// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxsearchdialog.pas' rev: 21.00

#ifndef FrxsearchdialogHPP
#define FrxsearchdialogHPP

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
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxsearchdialog
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxSearchDialog;
class PASCALIMPLEMENTATION TfrxSearchDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Extctrls::TPanel* ReplacePanel;
	Stdctrls::TLabel* ReplaceL;
	Stdctrls::TEdit* ReplaceE;
	Extctrls::TPanel* Panel2;
	Stdctrls::TLabel* TextL;
	Stdctrls::TEdit* TextE;
	Extctrls::TPanel* Panel3;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TGroupBox* SearchL;
	Stdctrls::TCheckBox* CaseCB;
	Stdctrls::TCheckBox* TopCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall FormActivate(System::TObject* Sender);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxSearchDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxSearchDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxSearchDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxSearchDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxsearchdialog */
using namespace Frxsearchdialog;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxsearchdialogHPP
