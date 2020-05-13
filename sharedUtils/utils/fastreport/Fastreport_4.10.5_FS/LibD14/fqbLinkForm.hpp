// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fqblinkform.pas' rev: 21.00

#ifndef FqblinkformHPP
#define FqblinkformHPP

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
#include <Buttons.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fqblinkform
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfqbLinkForm;
class PASCALIMPLEMENTATION TfqbLinkForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Extctrls::TRadioGroup* RadioOpt;
	Extctrls::TRadioGroup* RadioType;
	Stdctrls::TStaticText* txtTable1;
	Stdctrls::TStaticText* txtTable2;
	Stdctrls::TLabel* Label1;
	Stdctrls::TLabel* Label2;
	Stdctrls::TLabel* Label3;
	Stdctrls::TStaticText* txtCol1;
	Stdctrls::TLabel* Label4;
	Stdctrls::TStaticText* txtCol2;
	Buttons::TBitBtn* BitBtn1;
	Buttons::TBitBtn* BitBtn2;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfqbLinkForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfqbLinkForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfqbLinkForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbLinkForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Fqblinkform */
using namespace Fqblinkform;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FqblinkformHPP
