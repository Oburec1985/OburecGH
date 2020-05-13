// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditmd.pas' rev: 21.00

#ifndef FrxeditmdHPP
#define FrxeditmdHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Frxcustomdb.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditmd
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxMDEditorForm;
class PASCALIMPLEMENTATION TfrxMDEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TListBox* DetailLB;
	Stdctrls::TListBox* MasterLB;
	Stdctrls::TLabel* Label1;
	Stdctrls::TLabel* Label2;
	Stdctrls::TButton* AddB;
	Stdctrls::TListBox* LinksLB;
	Stdctrls::TLabel* Label3;
	Stdctrls::TButton* ClearB;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Extctrls::TBevel* Bevel1;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall ClearBClick(System::TObject* Sender);
	void __fastcall DetailLBClick(System::TObject* Sender);
	void __fastcall MasterLBClick(System::TObject* Sender);
	void __fastcall AddBClick(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Frxcustomdb::TfrxCustomDataset* FDetailDS;
	Frxclass::TfrxCustomDBDataSet* FMasterDS;
	System::UnicodeString FMasterFields;
	void __fastcall FillLists(void);
	
public:
	__property Frxcustomdb::TfrxCustomDataset* DataSet = {read=FDetailDS, write=FDetailDS};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxMDEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxMDEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxMDEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxMDEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditmd */
using namespace Frxeditmd;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditmdHPP
