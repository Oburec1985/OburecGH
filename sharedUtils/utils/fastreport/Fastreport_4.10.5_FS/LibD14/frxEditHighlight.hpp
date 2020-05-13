// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxedithighlight.pas' rev: 21.00

#ifndef FrxedithighlightHPP
#define FrxedithighlightHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxedithighlight
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxHighlightEditorForm;
class PASCALIMPLEMENTATION TfrxHighlightEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TGroupBox* ConditionL;
	Frxctrls::TfrxComboEdit* ConditionE;
	Stdctrls::TGroupBox* FontL;
	Buttons::TSpeedButton* FontColorB;
	Stdctrls::TCheckBox* BoldCB;
	Stdctrls::TCheckBox* ItalicCB;
	Stdctrls::TCheckBox* UnderlineCB;
	Dialogs::TColorDialog* ColorDialog1;
	Stdctrls::TGroupBox* BackgroundL;
	Buttons::TSpeedButton* BackColorB;
	Stdctrls::TRadioButton* TransparentRB;
	Stdctrls::TRadioButton* OtherRB;
	void __fastcall FontColorBClick(System::TObject* Sender);
	void __fastcall BackColorBClick(System::TObject* Sender);
	void __fastcall TransparentRBClick(System::TObject* Sender);
	void __fastcall ConditionEButtonClick(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Graphics::TColor FBackColor;
	Graphics::TColor FFontColor;
	Frxclass::TfrxHighlight* FHighlight;
	Frxclass::TfrxCustomMemoView* FMemoView;
	void __fastcall SetGlyph(Buttons::TSpeedButton* Button, Graphics::TColor Color);
	
public:
	__property Frxclass::TfrxCustomMemoView* MemoView = {read=FMemoView, write=FMemoView};
	void __fastcall HostControls(Controls::TWinControl* Host);
	void __fastcall UnhostControls(Controls::TModalResult AModalResult);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxHighlightEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxHighlightEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxHighlightEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxHighlightEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxedithighlight */
using namespace Frxedithighlight;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxedithighlightHPP
