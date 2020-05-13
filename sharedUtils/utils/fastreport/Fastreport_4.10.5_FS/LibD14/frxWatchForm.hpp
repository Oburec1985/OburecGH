// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxwatchform.pas' rev: 21.00

#ifndef FrxwatchformHPP
#define FrxwatchformHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Fs_iinterpreter.hpp>	// Pascal unit
#include <Checklst.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxwatchform
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxWatchForm;
class PASCALIMPLEMENTATION TfrxWatchForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TToolBar* ToolBar1;
	Comctrls::TToolButton* AddB;
	Comctrls::TToolButton* DeleteB;
	Comctrls::TToolButton* EditB;
	Checklst::TCheckListBox* WatchLB;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall FormDestroy(System::TObject* Sender);
	void __fastcall AddBClick(System::TObject* Sender);
	void __fastcall DeleteBClick(System::TObject* Sender);
	void __fastcall EditBClick(System::TObject* Sender);
	void __fastcall FormCloseQuery(System::TObject* Sender, bool &CanClose);
	void __fastcall WatchLBClickCheck(System::TObject* Sender);
	
private:
	Fs_iinterpreter::TfsScript* FScript;
	bool FScriptRunning;
	Classes::TStrings* FWatches;
	System::UnicodeString __fastcall CalcWatch(const System::UnicodeString s);
	
public:
	void __fastcall UpdateWatches(void);
	__property Fs_iinterpreter::TfsScript* Script = {read=FScript, write=FScript};
	__property bool ScriptRunning = {read=FScriptRunning, write=FScriptRunning, nodefault};
	__property Classes::TStrings* Watches = {read=FWatches};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxWatchForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxWatchForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxWatchForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxWatchForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxwatchform */
using namespace Frxwatchform;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxwatchformHPP
