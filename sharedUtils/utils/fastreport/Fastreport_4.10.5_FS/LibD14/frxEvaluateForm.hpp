// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxevaluateform.pas' rev: 21.00

#ifndef FrxevaluateformHPP
#define FrxevaluateformHPP

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
#include <Fs_iinterpreter.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxevaluateform
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxEvaluateForm;
class PASCALIMPLEMENTATION TfrxEvaluateForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TLabel* Label1;
	Stdctrls::TEdit* ExpressionE;
	Stdctrls::TLabel* Label2;
	Stdctrls::TMemo* ResultM;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	void __fastcall ExpressionEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Fs_iinterpreter::TfsScript* FScript;
	bool FIsWatch;
	
public:
	__property bool IsWatch = {read=FIsWatch, write=FIsWatch, nodefault};
	__property Fs_iinterpreter::TfsScript* Script = {read=FScript, write=FScript};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxEvaluateForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxEvaluateForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxEvaluateForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxEvaluateForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxevaluateform */
using namespace Frxevaluateform;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxevaluateformHPP
