// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditoptions.pas' rev: 21.00

#ifndef FrxeditoptionsHPP
#define FrxeditoptionsHPP

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
#include <Frxctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditoptions
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxOptionsEditor;
class PASCALIMPLEMENTATION TfrxOptionsEditor : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Dialogs::TColorDialog* ColorDialog;
	Stdctrls::TButton* RestoreDefaultsB;
	Stdctrls::TGroupBox* Label1;
	Stdctrls::TLabel* Label2;
	Stdctrls::TLabel* Label3;
	Stdctrls::TLabel* Label4;
	Stdctrls::TLabel* Label13;
	Stdctrls::TLabel* Label14;
	Stdctrls::TLabel* Label15;
	Stdctrls::TLabel* Label16;
	Stdctrls::TRadioButton* CMRB;
	Stdctrls::TRadioButton* InchesRB;
	Stdctrls::TRadioButton* PixelsRB;
	Stdctrls::TEdit* CME;
	Stdctrls::TEdit* InchesE;
	Stdctrls::TEdit* PixelsE;
	Stdctrls::TEdit* DialogFormE;
	Stdctrls::TCheckBox* ShowGridCB;
	Stdctrls::TCheckBox* AlignGridCB;
	Stdctrls::TGroupBox* Label6;
	Stdctrls::TLabel* Label7;
	Stdctrls::TLabel* Label8;
	Stdctrls::TLabel* Label9;
	Stdctrls::TLabel* Label10;
	Stdctrls::TComboBox* CodeWindowFontCB;
	Stdctrls::TComboBox* CodeWindowSizeCB;
	Stdctrls::TComboBox* MemoEditorFontCB;
	Stdctrls::TComboBox* MemoEditorSizeCB;
	Stdctrls::TCheckBox* ObjectFontCB;
	Stdctrls::TGroupBox* Label11;
	Extctrls::TPaintBox* WorkspacePB;
	Extctrls::TPaintBox* ToolPB;
	Stdctrls::TButton* WorkspaceB;
	Stdctrls::TButton* ToolB;
	Stdctrls::TCheckBox* LCDCB;
	Stdctrls::TGroupBox* Label5;
	Stdctrls::TLabel* Label12;
	Stdctrls::TLabel* Label17;
	Stdctrls::TCheckBox* EditAfterInsCB;
	Stdctrls::TCheckBox* FreeBandsCB;
	Stdctrls::TEdit* GapE;
	Stdctrls::TCheckBox* BandsCaptionsCB;
	Stdctrls::TCheckBox* DropFieldsCB;
	Stdctrls::TCheckBox* StartupCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall WorkspacePBPaint(System::TObject* Sender);
	void __fastcall ToolPBPaint(System::TObject* Sender);
	void __fastcall WorkspaceBClick(System::TObject* Sender);
	void __fastcall ToolBClick(System::TObject* Sender);
	void __fastcall RestoreDefaultsBClick(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Graphics::TColor FWColor;
	Graphics::TColor FTColor;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxOptionsEditor(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxOptionsEditor(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxOptionsEditor(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxOptionsEditor(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditoptions */
using namespace Frxeditoptions;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditoptionsHPP
