// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxunicodectrls.pas' rev: 21.00

#ifndef FrxunicodectrlsHPP
#define FrxunicodectrlsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Frxrichedit.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxunicodectrls
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TUnicodeEdit;
class PASCALIMPLEMENTATION TUnicodeEdit : public Stdctrls::TEdit
{
	typedef Stdctrls::TEdit inherited;
	
private:
	HIDESBASE void __fastcall SetSelText(const System::WideString Value);
	HIDESBASE System::WideString __fastcall GetText(void);
	HIDESBASE void __fastcall SetText(const System::WideString Value);
	
protected:
	virtual void __fastcall CreateWindowHandle(const Controls::TCreateParams &Params);
	HIDESBASE System::WideString __fastcall GetSelText(void);
	
public:
	__property System::WideString SelText = {read=GetSelText, write=SetSelText};
	__property System::WideString Text = {read=GetText, write=SetText};
public:
	/* TCustomEdit.Create */ inline __fastcall virtual TUnicodeEdit(Classes::TComponent* AOwner) : Stdctrls::TEdit(AOwner) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TUnicodeEdit(HWND ParentWindow) : Stdctrls::TEdit(ParentWindow) { }
	/* TWinControl.Destroy */ inline __fastcall virtual ~TUnicodeEdit(void) { }
	
};


class DELPHICLASS TUnicodeMemo;
class PASCALIMPLEMENTATION TUnicodeMemo : public Stdctrls::TMemo
{
	typedef Stdctrls::TMemo inherited;
	
private:
	HIDESBASE void __fastcall SetSelText(const System::WideString Value);
	HIDESBASE System::WideString __fastcall GetText(void);
	HIDESBASE void __fastcall SetText(const System::WideString Value);
	
protected:
	virtual void __fastcall CreateWindowHandle(const Controls::TCreateParams &Params);
	HIDESBASE System::WideString __fastcall GetSelText(void);
	
public:
	__property System::WideString SelText = {read=GetSelText, write=SetSelText};
	__property System::WideString Text = {read=GetText, write=SetText};
public:
	/* TCustomMemo.Create */ inline __fastcall virtual TUnicodeMemo(Classes::TComponent* AOwner) : Stdctrls::TMemo(AOwner) { }
	/* TCustomMemo.Destroy */ inline __fastcall virtual ~TUnicodeMemo(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TUnicodeMemo(HWND ParentWindow) : Stdctrls::TMemo(ParentWindow) { }
	
};


class DELPHICLASS TRxUnicodeRichEdit;
class PASCALIMPLEMENTATION TRxUnicodeRichEdit : public Frxrichedit::TRxRichEdit
{
	typedef Frxrichedit::TRxRichEdit inherited;
	
public:
	/* TRxCustomRichEdit.Create */ inline __fastcall virtual TRxUnicodeRichEdit(Classes::TComponent* AOwner) : Frxrichedit::TRxRichEdit(AOwner) { }
	/* TRxCustomRichEdit.Destroy */ inline __fastcall virtual ~TRxUnicodeRichEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TRxUnicodeRichEdit(HWND ParentWindow) : Frxrichedit::TRxRichEdit(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxunicodectrls */
using namespace Frxunicodectrls;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxunicodectrlsHPP
