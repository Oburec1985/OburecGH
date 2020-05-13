// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxedittaborder.pas' rev: 21.00

#ifndef FrxedittaborderHPP
#define FrxedittaborderHPP

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

//-- user supplied -----------------------------------------------------------

namespace Frxedittaborder
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxTabOrderEditorForm;
class PASCALIMPLEMENTATION TfrxTabOrderEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TLabel* Label1;
	Stdctrls::TButton* UpB;
	Stdctrls::TButton* DownB;
	Stdctrls::TListBox* ControlsLB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall UpBClick(System::TObject* Sender);
	void __fastcall DownBClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Classes::TList* FOldOrder;
	Frxclass::TfrxComponent* FParent;
	void __fastcall UpdateOrder(void);
	
public:
	__fastcall virtual TfrxTabOrderEditorForm(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxTabOrderEditorForm(void);
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxTabOrderEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxTabOrderEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxedittaborder */
using namespace Frxedittaborder;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxedittaborderHPP
