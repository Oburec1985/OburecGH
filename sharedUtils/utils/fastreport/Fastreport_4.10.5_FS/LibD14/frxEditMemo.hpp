// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditmemo.pas' rev: 21.00

#ifndef FrxeditmemoHPP
#define FrxeditmemoHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxeditformat.hpp>	// Pascal unit
#include <Frxedithighlight.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditmemo
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxMemoEditorForm;
class PASCALIMPLEMENTATION TfrxMemoEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TPageControl* PageControl1;
	Comctrls::TTabSheet* TextTS;
	Comctrls::TTabSheet* FormatTS;
	Comctrls::TTabSheet* HighlightTS;
	Comctrls::TToolBar* ToolBar;
	Comctrls::TToolButton* ExprB;
	Comctrls::TToolButton* AggregateB;
	Comctrls::TToolButton* LocalFormatB;
	Comctrls::TToolButton* WordWrapB;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall WordWrapBClick(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall MemoKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall ExprBClick(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall AggregateBClick(System::TObject* Sender);
	void __fastcall LocalFormatBClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Frxeditformat::TfrxFormatEditorForm* FFormat;
	Frxedithighlight::TfrxHighlightEditorForm* FHighlight;
	Frxclass::TfrxCustomMemoView* FMemoView;
	bool FIsUnicode;
	System::WideString FText;
	
public:
	Stdctrls::TMemo* Memo;
	__property Frxclass::TfrxCustomMemoView* MemoView = {read=FMemoView, write=FMemoView};
	__property System::WideString Text = {read=FText, write=FText};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxMemoEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxMemoEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxMemoEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxMemoEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditmemo */
using namespace Frxeditmemo;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditmemoHPP
