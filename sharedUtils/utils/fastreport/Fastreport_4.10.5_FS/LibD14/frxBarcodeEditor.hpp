// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxbarcodeeditor.pas' rev: 21.00

#ifndef FrxbarcodeeditorHPP
#define FrxbarcodeeditorHPP

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
#include <Menus.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxbarcode.hpp>	// Pascal unit
#include <Frxcustomeditors.hpp>	// Pascal unit
#include <Frxbarcod.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Frxdsgnintf.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxbarcodeeditor
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxBarcodeEditor;
class PASCALIMPLEMENTATION TfrxBarcodeEditor : public Frxcustomeditors::TfrxViewEditor
{
	typedef Frxcustomeditors::TfrxViewEditor inherited;
	
public:
	virtual bool __fastcall Edit(void);
	virtual bool __fastcall HasEditor(void);
	virtual void __fastcall GetMenuItems(void);
	virtual bool __fastcall Execute(int Tag, bool Checked);
public:
	/* TfrxComponentEditor.Create */ inline __fastcall TfrxBarcodeEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu) : Frxcustomeditors::TfrxViewEditor(Component, Designer, Menu) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxBarcodeEditor(void) { }
	
};


class DELPHICLASS TfrxBarcodeEditorForm;
class PASCALIMPLEMENTATION TfrxBarcodeEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* CancelB;
	Stdctrls::TButton* OkB;
	Frxctrls::TfrxComboEdit* CodeE;
	Stdctrls::TLabel* CodeLbl;
	Stdctrls::TComboBox* TypeCB;
	Stdctrls::TLabel* TypeLbl;
	Extctrls::TBevel* ExampleBvl;
	Extctrls::TPaintBox* ExamplePB;
	Stdctrls::TGroupBox* OptionsLbl;
	Stdctrls::TLabel* ZoomLbl;
	Stdctrls::TCheckBox* CalcCheckSumCB;
	Stdctrls::TCheckBox* ViewTextCB;
	Stdctrls::TEdit* ZoomE;
	Comctrls::TUpDown* UpDown1;
	Stdctrls::TGroupBox* RotationLbl;
	Stdctrls::TRadioButton* Rotation0RB;
	Stdctrls::TRadioButton* Rotation90RB;
	Stdctrls::TRadioButton* Rotation180RB;
	Stdctrls::TRadioButton* Rotation270RB;
	void __fastcall ExprBtnClick(System::TObject* Sender);
	void __fastcall UpBClick(System::TObject* Sender);
	void __fastcall DownBClick(System::TObject* Sender);
	void __fastcall ExamplePBPaint(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Frxbarcode::TfrxBarCodeView* FBarcode;
	
public:
	__property Frxbarcode::TfrxBarCodeView* Barcode = {read=FBarcode, write=FBarcode};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxBarcodeEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxBarcodeEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxBarcodeEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxBarcodeEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxbarcodeeditor */
using namespace Frxbarcodeeditor;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxbarcodeeditorHPP
