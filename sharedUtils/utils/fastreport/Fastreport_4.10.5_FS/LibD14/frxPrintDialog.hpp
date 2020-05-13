// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxprintdialog.pas' rev: 21.00

#ifndef FrxprintdialogHPP
#define FrxprintdialogHPP

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
#include <Frxctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxprintdialog
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxPrintDialog;
class PASCALIMPLEMENTATION TfrxPrintDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Dialogs::TSaveDialog* FileDlg;
	Stdctrls::TGroupBox* Label12;
	Stdctrls::TLabel* WhereL;
	Stdctrls::TLabel* WhereL1;
	Stdctrls::TComboBox* PrintersCB;
	Stdctrls::TButton* PropButton;
	Stdctrls::TCheckBox* FileCB;
	Stdctrls::TGroupBox* Label1;
	Stdctrls::TLabel* DescrL;
	Stdctrls::TRadioButton* AllRB;
	Stdctrls::TRadioButton* CurPageRB;
	Stdctrls::TRadioButton* PageNumbersRB;
	Stdctrls::TEdit* PageNumbersE;
	Stdctrls::TGroupBox* Label2;
	Stdctrls::TLabel* CopiesL;
	Extctrls::TImage* CollateImg;
	Extctrls::TImage* NonCollateImg;
	Extctrls::TPaintBox* CopiesPB;
	Stdctrls::TEdit* CopiesE;
	Stdctrls::TCheckBox* CollateCB;
	Comctrls::TUpDown* UpDown1;
	Stdctrls::TGroupBox* ScaleGB;
	Stdctrls::TComboBox* PagPageSizeCB;
	Stdctrls::TLabel* NameL;
	Stdctrls::TLabel* PagSizeL;
	Stdctrls::TComboBox* PrintModeCB;
	Controls::TImageList* PrintModeIL;
	Stdctrls::TGroupBox* OtherGB;
	Stdctrls::TLabel* PrintL;
	Stdctrls::TLabel* DuplexL;
	Stdctrls::TComboBox* PrintPagesCB;
	Stdctrls::TComboBox* DuplexCB;
	Stdctrls::TLabel* OrderL;
	Stdctrls::TComboBox* OrderCB;
	void __fastcall PrintersCBDrawItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PropButtonClick(System::TObject* Sender);
	void __fastcall PrintersCBClick(System::TObject* Sender);
	void __fastcall PageNumbersRBClick(System::TObject* Sender);
	void __fastcall CollateLClick(System::TObject* Sender);
	void __fastcall CollateCBClick(System::TObject* Sender);
	void __fastcall CopiesPBPaint(System::TObject* Sender);
	void __fastcall PageNumbersEEnter(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall PrintModeCBDrawItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall PrintModeCBClick(System::TObject* Sender);
	
private:
	int OldIndex;
	
public:
	Frxclass::TfrxReport* AReport;
	Frxclass::TfrxDuplexMode ADuplexMode;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxPrintDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxPrintDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxPrintDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxPrintDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxprintdialog */
using namespace Frxprintdialog;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxprintdialogHPP
