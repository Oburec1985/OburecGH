// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxinheriterror.pas' rev: 21.00

#ifndef FrxinheriterrorHPP
#define FrxinheriterrorHPP

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
#include <Imglist.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxinheriterror
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxInheritErrorForm;
class PASCALIMPLEMENTATION TfrxInheritErrorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TLabel* MessageL;
	Stdctrls::TRadioButton* DeleteRB;
	Stdctrls::TRadioButton* RenameRB;
	Extctrls::TPaintBox* PaintBox1;
	Controls::TImageList* ImageList1;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PaintBox1Paint(System::TObject* Sender);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxInheritErrorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxInheritErrorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxInheritErrorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxInheritErrorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxinheriterror */
using namespace Frxinheriterror;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxinheriterrorHPP
