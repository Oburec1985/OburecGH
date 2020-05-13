// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditpage.pas' rev: 21.00

#ifndef FrxeditpageHPP
#define FrxeditpageHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditpage
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxPageEditorForm;
class PASCALIMPLEMENTATION TfrxPageEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* CancelB;
	Comctrls::TPageControl* PageControl1;
	Comctrls::TTabSheet* TabSheet1;
	Comctrls::TTabSheet* TabSheet3;
	Stdctrls::TGroupBox* Label11;
	Stdctrls::TLabel* Label1;
	Stdctrls::TLabel* Label2;
	Stdctrls::TLabel* UnitL1;
	Stdctrls::TLabel* UnitL2;
	Stdctrls::TEdit* WidthE;
	Stdctrls::TEdit* HeightE;
	Stdctrls::TComboBox* SizeCB;
	Stdctrls::TGroupBox* Label14;
	Stdctrls::TGroupBox* Label12;
	Extctrls::TImage* PortraitImg;
	Extctrls::TImage* LandscapeImg;
	Stdctrls::TRadioButton* PortraitRB;
	Stdctrls::TRadioButton* LandscapeRB;
	Stdctrls::TGroupBox* Label13;
	Stdctrls::TLabel* Label3;
	Stdctrls::TLabel* Label4;
	Stdctrls::TLabel* Label5;
	Stdctrls::TLabel* Label6;
	Stdctrls::TLabel* UnitL3;
	Stdctrls::TLabel* UnitL4;
	Stdctrls::TLabel* UnitL5;
	Stdctrls::TLabel* UnitL6;
	Stdctrls::TEdit* MarginLeftE;
	Stdctrls::TEdit* MarginTopE;
	Stdctrls::TEdit* MarginRightE;
	Stdctrls::TEdit* MarginBottomE;
	Stdctrls::TLabel* Label9;
	Stdctrls::TLabel* Label10;
	Stdctrls::TComboBox* Tray1CB;
	Stdctrls::TComboBox* Tray2CB;
	Stdctrls::TGroupBox* Label7;
	Stdctrls::TLabel* Label8;
	Stdctrls::TLabel* Label15;
	Stdctrls::TLabel* Label16;
	Stdctrls::TLabel* UnitL7;
	Stdctrls::TEdit* ColumnsNumberE;
	Stdctrls::TEdit* ColumnWidthE;
	Stdctrls::TMemo* ColumnPositionsM;
	Comctrls::TUpDown* UpDown1;
	Stdctrls::TGroupBox* Label17;
	Stdctrls::TLabel* Label18;
	Stdctrls::TCheckBox* PrintOnPrevCB;
	Stdctrls::TCheckBox* MirrorMarginsCB;
	Stdctrls::TCheckBox* LargeHeightCB;
	Stdctrls::TComboBox* DuplexCB;
	Stdctrls::TCheckBox* EndlessWidthCB;
	Stdctrls::TCheckBox* EndlessHeightCB;
	void __fastcall PortraitRBClick(System::TObject* Sender);
	void __fastcall SizeCBClick(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall WidthEChange(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall UpDown1Click(System::TObject* Sender, Comctrls::TUDBtnType Button);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	bool FUpdating;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxPageEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxPageEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxPageEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxPageEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditpage */
using namespace Frxeditpage;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditpageHPP
