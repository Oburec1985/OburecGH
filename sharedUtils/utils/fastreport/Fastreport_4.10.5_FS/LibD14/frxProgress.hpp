// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxprogress.pas' rev: 21.00

#ifndef FrxprogressHPP
#define FrxprogressHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxprogress
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxProgress;
class PASCALIMPLEMENTATION TfrxProgress : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Extctrls::TPanel* Panel1;
	Stdctrls::TLabel* LMessage;
	Comctrls::TProgressBar* Bar;
	Stdctrls::TButton* CancelB;
	HIDESBASE MESSAGE void __fastcall WMNCHitTest(Messages::TWMNCHitTest &Message);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall CancelBClick(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormDestroy(System::TObject* Sender);
	
private:
	Forms::TForm* FActiveForm;
	bool FTerminated;
	int FPosition;
	System::UnicodeString FMessage;
	bool FProgress;
	HIDESBASE void __fastcall SetPosition(int Value);
	void __fastcall SetMessage(const System::UnicodeString Value);
	void __fastcall SetTerminated(bool Value);
	void __fastcall SetProgress(bool Value);
	
public:
	void __fastcall Reset(void);
	void __fastcall Execute(int MaxValue, const System::UnicodeString Msg, bool Canceled, bool Progress);
	void __fastcall Tick(void);
	__property bool Terminated = {read=FTerminated, write=SetTerminated, nodefault};
	__property int Position = {read=FPosition, write=SetPosition, nodefault};
	__property bool ShowProgress = {read=FProgress, write=SetProgress, nodefault};
	__property System::UnicodeString Message = {read=FMessage, write=SetMessage};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxProgress(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxProgress(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxProgress(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxProgress(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxprogress */
using namespace Frxprogress;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxprogressHPP
