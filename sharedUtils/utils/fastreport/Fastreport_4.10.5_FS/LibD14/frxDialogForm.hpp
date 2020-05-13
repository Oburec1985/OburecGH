// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdialogform.pas' rev: 21.00

#ifndef FrxdialogformHPP
#define FrxdialogformHPP

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
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdialogform
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxDialogForm;
class PASCALIMPLEMENTATION TfrxDialogForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	void __fastcall FormCloseQuery(System::TObject* Sender, bool &CanClose);
	
protected:
	virtual void __fastcall ReadState(Classes::TReader* Reader);
	
private:
	Classes::TNotifyEvent FOnModify;
	bool FThreadSafe;
	MESSAGE void __fastcall WMExitSizeMove(Messages::TMessage &Msg);
	MESSAGE void __fastcall WMGetDlgCode(Messages::TWMNoParams &Message);
	
public:
	__fastcall virtual TfrxDialogForm(Classes::TComponent* AOwner);
	__property Classes::TNotifyEvent OnModify = {read=FOnModify, write=FOnModify};
	__property bool ThreadSafe = {read=FThreadSafe, write=FThreadSafe, nodefault};
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxDialogForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxDialogForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxDialogForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxdialogform */
using namespace Frxdialogform;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdialogformHPP
