// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxabout.pas' rev: 21.00

#ifndef FrxaboutHPP
#define FrxaboutHPP

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
#include <Extctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxabout
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxAboutForm;
class PASCALIMPLEMENTATION TfrxAboutForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* Button1;
	Stdctrls::TLabel* Label2;
	Stdctrls::TLabel* Label3;
	Extctrls::TImage* Image1;
	Extctrls::TBevel* Bevel2;
	Stdctrls::TLabel* Label5;
	Extctrls::TShape* Shape1;
	Stdctrls::TLabel* Label1;
	Stdctrls::TLabel* Label4;
	Stdctrls::TLabel* Label6;
	Stdctrls::TLabel* Label7;
	Stdctrls::TLabel* Label8;
	Stdctrls::TLabel* Label9;
	Stdctrls::TLabel* Label10;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall LabelClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall FormDestroy(System::TObject* Sender);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxAboutForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxAboutForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxAboutForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxAboutForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxabout */
using namespace Frxabout;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxaboutHPP
