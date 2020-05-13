// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditgroup.pas' rev: 21.00

#ifndef FrxeditgroupHPP
#define FrxeditgroupHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditgroup
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxGroupEditorForm;
class PASCALIMPLEMENTATION TfrxGroupEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TGroupBox* BreakOnL;
	Stdctrls::TComboBox* DataFieldCB;
	Stdctrls::TComboBox* DataSetCB;
	Frxctrls::TfrxComboEdit* ExpressionE;
	Stdctrls::TRadioButton* DataFieldRB;
	Stdctrls::TRadioButton* ExpressionRB;
	Stdctrls::TGroupBox* OptionsL;
	Stdctrls::TCheckBox* KeepGroupTogetherCB;
	Stdctrls::TCheckBox* StartNewPageCB;
	Stdctrls::TCheckBox* OutlineCB;
	Stdctrls::TCheckBox* DrillCB;
	Stdctrls::TCheckBox* ResetCB;
	void __fastcall ExpressionEButtonClick(System::TObject* Sender);
	void __fastcall DataFieldRBClick(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall DataSetCBChange(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Frxclass::TfrxGroupHeader* FGroupHeader;
	Frxclass::TfrxReport* FReport;
	void __fastcall FillDataFieldCB(void);
	void __fastcall FillDataSetCB(void);
	
public:
	__property Frxclass::TfrxGroupHeader* GroupHeader = {read=FGroupHeader, write=FGroupHeader};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxGroupEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxGroupEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxGroupEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxGroupEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditgroup */
using namespace Frxeditgroup;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditgroupHPP
