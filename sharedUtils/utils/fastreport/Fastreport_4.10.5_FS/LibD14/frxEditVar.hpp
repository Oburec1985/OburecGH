// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditvar.pas' rev: 21.00

#ifndef FrxeditvarHPP
#define FrxeditvarHPP

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
#include <Frxdock.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Frxvariables.hpp>	// Pascal unit
#include <Frxdatatree.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditvar
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxVarEditorForm;
class PASCALIMPLEMENTATION TfrxVarEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TTreeView* VarTree;
	Comctrls::TToolBar* ToolBar;
	Comctrls::TToolButton* NewCategoryB;
	Comctrls::TToolButton* NewVarB;
	Comctrls::TToolButton* EditB;
	Comctrls::TToolButton* DeleteB;
	Comctrls::TToolButton* EditListB;
	Comctrls::TToolButton* OkB;
	Comctrls::TToolButton* CancelB;
	Comctrls::TToolButton* Sep1;
	Stdctrls::TMemo* ExprMemo;
	Extctrls::TSplitter* Splitter1;
	Extctrls::TSplitter* Splitter2;
	Extctrls::TPanel* ExprPanel;
	Comctrls::TToolButton* LoadB;
	Comctrls::TToolButton* SaveB;
	Comctrls::TToolButton* Sep2;
	Dialogs::TOpenDialog* OpenDialog1;
	Dialogs::TSaveDialog* SaveDialog1;
	Extctrls::TPanel* Panel;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormDestroy(System::TObject* Sender);
	void __fastcall DeleteBClick(System::TObject* Sender);
	void __fastcall NewCategoryBClick(System::TObject* Sender);
	void __fastcall NewVarBClick(System::TObject* Sender);
	void __fastcall OkBClick(System::TObject* Sender);
	void __fastcall EditBClick(System::TObject* Sender);
	void __fastcall VarTreeEdited(System::TObject* Sender, Comctrls::TTreeNode* Node, System::UnicodeString &S);
	void __fastcall VarTreeKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall ExprMemoDragOver(System::TObject* Sender, System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall ExprMemoDragDrop(System::TObject* Sender, System::TObject* Source, int X, int Y);
	void __fastcall VarTreeChange(System::TObject* Sender, Comctrls::TTreeNode* Node);
	void __fastcall VarTreeChanging(System::TObject* Sender, Comctrls::TTreeNode* Node, bool &AllowChange);
	void __fastcall CancelBClick(System::TObject* Sender);
	void __fastcall EditListBClick(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall LoadBClick(System::TObject* Sender);
	void __fastcall SaveBClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall Splitter2Moved(System::TObject* Sender);
	
private:
	Frxclass::TfrxReport* FReport;
	bool FUpdating;
	Frxvariables::TfrxVariables* FVariables;
	Frxdatatree::TfrxDataTreeForm* FDataTree;
	Comctrls::TTreeNode* __fastcall Root(void);
	void __fastcall CreateUniqueName(System::UnicodeString &s);
	void __fastcall FillVariables(void);
	void __fastcall UpdateItem0(void);
	void __fastcall OnDataTreeDblClick(System::TObject* Sender);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxVarEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxVarEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxVarEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxVarEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditvar */
using namespace Frxeditvar;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditvarHPP
