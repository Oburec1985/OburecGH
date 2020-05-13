// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxreporttree.pas' rev: 21.00

#ifndef FrxreporttreeHPP
#define FrxreporttreeHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxreporttree
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxReportTreeForm;
class PASCALIMPLEMENTATION TfrxReportTreeForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TTreeView* Tree;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall TreeChange(System::TObject* Sender, Comctrls::TTreeNode* Node);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall TreeKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Classes::TList* FComponents;
	Frxclass::TfrxCustomDesigner* FDesigner;
	Classes::TList* FNodes;
	Frxclass::TfrxReport* FReport;
	bool FUpdating;
	Classes::TNotifyEvent FOnSelectionChanged;
	
public:
	__fastcall virtual TfrxReportTreeForm(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxReportTreeForm(void);
	HIDESBASE void __fastcall SetColor(Graphics::TColor Value);
	void __fastcall UpdateItems(void);
	void __fastcall UpdateSelection(void);
	__property Classes::TNotifyEvent OnSelectionChanged = {read=FOnSelectionChanged, write=FOnSelectionChanged};
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxReportTreeForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxReportTreeForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxreporttree */
using namespace Frxreporttree;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxreporttreeHPP
