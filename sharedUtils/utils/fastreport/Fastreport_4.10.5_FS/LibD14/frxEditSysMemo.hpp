// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditsysmemo.pas' rev: 21.00

#ifndef FrxeditsysmemoHPP
#define FrxeditsysmemoHPP

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

namespace Frxeditsysmemo
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxSysMemoEditorForm;
class PASCALIMPLEMENTATION TfrxSysMemoEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TRadioButton* AggregateRB;
	Stdctrls::TRadioButton* SysVariableRB;
	Stdctrls::TRadioButton* TextRB;
	Stdctrls::TGroupBox* AggregatePanel;
	Stdctrls::TLabel* DataBandL;
	Stdctrls::TLabel* DataSetL;
	Stdctrls::TLabel* DataFieldL;
	Stdctrls::TLabel* FunctionL;
	Stdctrls::TLabel* ExpressionL;
	Stdctrls::TComboBox* DataFieldCB;
	Stdctrls::TComboBox* DataSetCB;
	Stdctrls::TComboBox* DataBandCB;
	Stdctrls::TCheckBox* CountInvisibleCB;
	Stdctrls::TComboBox* FunctionCB;
	Frxctrls::TfrxComboEdit* ExpressionE;
	Stdctrls::TCheckBox* RunningTotalCB;
	Stdctrls::TGroupBox* GroupBox1;
	Stdctrls::TComboBox* SysVariableCB;
	Stdctrls::TGroupBox* GroupBox2;
	Stdctrls::TEdit* TextE;
	Stdctrls::TLabel* SampleL;
	void __fastcall ExpressionEButtonClick(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall DataSetCBChange(System::TObject* Sender);
	void __fastcall DataBandCBChange(System::TObject* Sender);
	void __fastcall DataFieldCBChange(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FunctionCBChange(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	bool FAggregateOnly;
	Frxclass::TfrxReport* FReport;
	System::UnicodeString FText;
	void __fastcall FillDataBandCB(void);
	void __fastcall FillDataFieldCB(void);
	void __fastcall FillDataSetCB(void);
	System::UnicodeString __fastcall CreateAggregate(void);
	void __fastcall UpdateSample(void);
	
public:
	__property bool AggregateOnly = {read=FAggregateOnly, write=FAggregateOnly, nodefault};
	__property System::UnicodeString Text = {read=FText, write=FText};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxSysMemoEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxSysMemoEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxSysMemoEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxSysMemoEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditsysmemo */
using namespace Frxeditsysmemo;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditsysmemoHPP
