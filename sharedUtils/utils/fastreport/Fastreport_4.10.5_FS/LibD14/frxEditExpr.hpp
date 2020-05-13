// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditexpr.pas' rev: 21.00

#ifndef FrxeditexprHPP
#define FrxeditexprHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Frxdatatree.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditexpr
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxExprEditorForm;
class PASCALIMPLEMENTATION TfrxExprEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TMemo* ExprMemo;
	Extctrls::TPanel* Panel1;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Extctrls::TSplitter* Splitter1;
	Extctrls::TPanel* Panel2;
	Stdctrls::TLabel* ExprL;
	Extctrls::TPanel* Panel;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall ExprMemoDragOver(System::TObject* Sender, System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall ExprMemoDragDrop(System::TObject* Sender, System::TObject* Source, int X, int Y);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall FormResize(System::TObject* Sender);
	
private:
	Frxdatatree::TfrxDataTreeForm* FDataTree;
	Frxclass::TfrxReport* FReport;
	void __fastcall OnDataTreeDblClick(System::TObject* Sender);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxExprEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxExprEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxExprEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxExprEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditexpr */
using namespace Frxeditexpr;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditexprHPP
