// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxricheditor.pas' rev: 21.00

#ifndef FrxricheditorHPP
#define FrxricheditorHPP

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
#include <Frxrich.hpp>	// Pascal unit
#include <Frxcustomeditors.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Frxrichedit.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Frxdock.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Frxunicodectrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Frxdsgnintf.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxricheditor
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxRichEditor;
class PASCALIMPLEMENTATION TfrxRichEditor : public Frxcustomeditors::TfrxViewEditor
{
	typedef Frxcustomeditors::TfrxViewEditor inherited;
	
public:
	virtual bool __fastcall Edit(void);
	virtual bool __fastcall HasEditor(void);
	virtual void __fastcall GetMenuItems(void);
	virtual bool __fastcall Execute(int Tag, bool Checked);
public:
	/* TfrxComponentEditor.Create */ inline __fastcall TfrxRichEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu) : Frxcustomeditors::TfrxViewEditor(Component, Designer, Menu) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxRichEditor(void) { }
	
};


class DELPHICLASS TfrxRichEditorForm;
class PASCALIMPLEMENTATION TfrxRichEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Dialogs::TOpenDialog* OpenDialog;
	Dialogs::TSaveDialog* SaveDialog;
	Comctrls::TToolBar* SpeedBar;
	Extctrls::TPanel* Ruler;
	Dialogs::TFontDialog* FontDialog1;
	Stdctrls::TLabel* FirstInd;
	Stdctrls::TLabel* LeftInd;
	Extctrls::TBevel* RulerLine;
	Stdctrls::TLabel* RightInd;
	Comctrls::TToolButton* BoldB;
	Comctrls::TToolButton* ItalicB;
	Comctrls::TToolButton* LeftAlignB;
	Comctrls::TToolButton* CenterAlignB;
	Comctrls::TToolButton* RightAlignB;
	Comctrls::TToolButton* UnderlineB;
	Comctrls::TToolButton* BulletsB;
	Comctrls::TToolButton* TTB;
	Comctrls::TToolButton* CancelB;
	Comctrls::TToolButton* OkB;
	Comctrls::TToolButton* ExprB;
	Frxctrls::TfrxFontComboBox* FontNameCB;
	Frxctrls::TfrxComboBox* FontSizeCB;
	Comctrls::TToolButton* OpenB;
	Comctrls::TToolButton* SaveB;
	Comctrls::TToolButton* UndoB;
	Comctrls::TToolButton* Sep1;
	Comctrls::TToolButton* Sep2;
	Frxdock::TfrxTBPanel* Sep3;
	Comctrls::TToolButton* Sep4;
	Comctrls::TToolButton* Sep5;
	Comctrls::TToolButton* BlockAlignB;
	void __fastcall SelectionChange(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FileOpen(System::TObject* Sender);
	void __fastcall FileSaveAs(System::TObject* Sender);
	void __fastcall EditUndo(System::TObject* Sender);
	void __fastcall SelectFont(System::TObject* Sender);
	void __fastcall RulerResize(System::TObject* Sender);
	void __fastcall FormResize(System::TObject* Sender);
	void __fastcall FormPaint(System::TObject* Sender);
	void __fastcall BoldBClick(System::TObject* Sender);
	void __fastcall AlignButtonClick(System::TObject* Sender);
	void __fastcall FontNameCBChange(System::TObject* Sender);
	void __fastcall BulletsBClick(System::TObject* Sender);
	void __fastcall RulerItemMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall RulerItemMouseMove(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	void __fastcall FirstIndMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall LeftIndMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall RightIndMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall CancelBClick(System::TObject* Sender);
	void __fastcall OkBClick(System::TObject* Sender);
	void __fastcall ExprBClick(System::TObject* Sender);
	void __fastcall FontSizeCBChange(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	bool FDragging;
	int FDragOfs;
	Frxrich::TfrxRichView* FRichView;
	bool FUpdating;
	Frxunicodectrls::TRxUnicodeRichEdit* RichEdit1;
	Frxrichedit::TRxTextAttributes* __fastcall CurrText(void);
	void __fastcall SetupRuler(void);
	void __fastcall SetEditRect(void);
	
public:
	__property Frxrich::TfrxRichView* RichView = {read=FRichView, write=FRichView};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxRichEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxRichEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxRichEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxRichEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxricheditor */
using namespace Frxricheditor;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxricheditorHPP
