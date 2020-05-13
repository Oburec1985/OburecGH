// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxnewitem.pas' rev: 21.00

#ifndef FrxnewitemHPP
#define FrxnewitemHPP

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
#include <Imglist.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxnewitem
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxNewItemForm;
class PASCALIMPLEMENTATION TfrxNewItemForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TPageControl* Pages;
	Comctrls::TTabSheet* ItemsTab;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Comctrls::TTabSheet* TemplateTab;
	Stdctrls::TCheckBox* InheritCB;
	Comctrls::TListView* TemplateLV;
	Comctrls::TListView* ItemsLV;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall ItemsLVDblClick(System::TObject* Sender);
	void __fastcall FormDestroy(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Classes::TStringList* FTemplates;
	
public:
	__fastcall virtual TfrxNewItemForm(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxNewItemForm(void);
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxNewItemForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxNewItemForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxnewitem */
using namespace Frxnewitem;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxnewitemHPP
