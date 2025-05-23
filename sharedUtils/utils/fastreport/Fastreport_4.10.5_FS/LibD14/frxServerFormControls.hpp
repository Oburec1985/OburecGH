// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserverformcontrols.pas' rev: 21.00

#ifndef FrxserverformcontrolsHPP
#define FrxserverformcontrolsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxdctrl.hpp>	// Pascal unit
#include <Frxutils.hpp>	// Pascal unit
#include <Frxservertemplates.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserverformcontrols
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxCustomWebControl;
class PASCALIMPLEMENTATION TfrxCustomWebControl : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TAlignment FAlignment;
	Graphics::TColor FColor;
	bool FEnabled;
	Graphics::TFont* FFont;
	System::Extended FHeight;
	System::Extended FLeft;
	System::UnicodeString FName;
	bool FReadonly;
	int FTabindex;
	System::Extended FTop;
	System::Extended FWidth;
	bool FVisible;
	Frxservertemplates::TfrxServerTemplate* FTemplate;
	void __fastcall SetFont(Graphics::TFont* Value);
	
public:
	__fastcall virtual TfrxCustomWebControl(void);
	__fastcall virtual ~TfrxCustomWebControl(void);
	virtual System::AnsiString __fastcall Build(void) = 0 ;
	System::UnicodeString __fastcall PadText(System::UnicodeString s, int width);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property System::Extended Left = {read=FLeft, write=FLeft};
	__property System::Extended Top = {read=FTop, write=FTop};
	__property System::Extended Width = {read=FWidth, write=FWidth};
	__property System::Extended Height = {read=FHeight, write=FHeight};
	__property Graphics::TFont* Font = {read=FFont, write=SetFont};
	__property Graphics::TColor Color = {read=FColor, write=FColor, nodefault};
	__property Classes::TAlignment Alignment = {read=FAlignment, write=FAlignment, nodefault};
	__property bool Enabled = {read=FEnabled, write=FEnabled, nodefault};
	__property bool Readonly = {read=FReadonly, write=FReadonly, nodefault};
	__property int Tabindex = {read=FTabindex, write=FTabindex, nodefault};
	__property System::AnsiString HTML = {read=Build};
	__property bool Visible = {read=FVisible, write=FVisible, nodefault};
	__property Frxservertemplates::TfrxServerTemplate* Template = {read=FTemplate};
};


class DELPHICLASS TfrxWebLabelControl;
class PASCALIMPLEMENTATION TfrxWebLabelControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	System::UnicodeString FCaption;
	
public:
	__fastcall virtual TfrxWebLabelControl(void);
	__fastcall virtual ~TfrxWebLabelControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property System::UnicodeString Caption = {read=FCaption, write=FCaption};
};


class DELPHICLASS TfrxWebTextControl;
class PASCALIMPLEMENTATION TfrxWebTextControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	System::UnicodeString FText;
	int FSize;
	int FMaxlength;
	bool FPassword;
	
public:
	__fastcall virtual TfrxWebTextControl(void);
	__fastcall virtual ~TfrxWebTextControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property System::UnicodeString Text = {read=FText, write=FText};
	__property int Size = {read=FSize, write=FSize, nodefault};
	__property int Maxlength = {read=FMaxlength, write=FMaxlength, nodefault};
	__property bool Password = {read=FPassword, write=FPassword, nodefault};
};


class DELPHICLASS TfrxWebDateControl;
class PASCALIMPLEMENTATION TfrxWebDateControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	System::UnicodeString FText;
	int FSize;
	int FMaxlength;
	
public:
	__fastcall virtual TfrxWebDateControl(void);
	__fastcall virtual ~TfrxWebDateControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property System::UnicodeString Text = {read=FText, write=FText};
	__property int Size = {read=FSize, write=FSize, nodefault};
	__property int Maxlength = {read=FMaxlength, write=FMaxlength, nodefault};
};


class DELPHICLASS TfrxWebTextAreaControl;
class PASCALIMPLEMENTATION TfrxWebTextAreaControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	Classes::TStrings* FText;
	int FCols;
	int FRows;
	void __fastcall SetText(Classes::TStrings* Value);
	
public:
	__fastcall virtual TfrxWebTextAreaControl(void);
	__fastcall virtual ~TfrxWebTextAreaControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property Classes::TStrings* Text = {read=FText, write=SetText};
	__property int Cols = {read=FCols, write=FCols, nodefault};
	__property int Rows = {read=FRows, write=FRows, nodefault};
};


class DELPHICLASS TfrxWebCheckBoxControl;
class PASCALIMPLEMENTATION TfrxWebCheckBoxControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	System::UnicodeString FCaption;
	bool FChecked;
	
public:
	__fastcall virtual TfrxWebCheckBoxControl(void);
	__fastcall virtual ~TfrxWebCheckBoxControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property System::UnicodeString Caption = {read=FCaption, write=FCaption};
	__property bool Checked = {read=FChecked, write=FChecked, nodefault};
};


class DELPHICLASS TfrxWebRadioControl;
class PASCALIMPLEMENTATION TfrxWebRadioControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	System::UnicodeString FCaption;
	bool FChecked;
	
public:
	__fastcall virtual TfrxWebRadioControl(void);
	__fastcall virtual ~TfrxWebRadioControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property System::UnicodeString Caption = {read=FCaption, write=FCaption};
	__property bool Checked = {read=FChecked, write=FChecked, nodefault};
};


class DELPHICLASS TfrxWebSelectControl;
class PASCALIMPLEMENTATION TfrxWebSelectControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	Classes::TStrings* FItems;
	int FCheckedValue;
	void __fastcall SetItems(Classes::TStrings* Value);
	
public:
	__fastcall virtual TfrxWebSelectControl(void);
	__fastcall virtual ~TfrxWebSelectControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property Classes::TStrings* Items = {read=FItems, write=SetItems};
	__property int CheckedValue = {read=FCheckedValue, write=FCheckedValue, nodefault};
};


class DELPHICLASS TfrxWebSubmitControl;
class PASCALIMPLEMENTATION TfrxWebSubmitControl : public TfrxCustomWebControl
{
	typedef TfrxCustomWebControl inherited;
	
private:
	System::UnicodeString FCaption;
	
public:
	__fastcall virtual TfrxWebSubmitControl(void);
	__fastcall virtual ~TfrxWebSubmitControl(void);
	virtual System::AnsiString __fastcall Build(void);
	virtual void __fastcall Assign(Frxclass::TfrxDialogControl* Value);
	__property System::UnicodeString Caption = {read=FCaption, write=FCaption};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxserverformcontrols */
using namespace Frxserverformcontrols;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverformcontrolsHPP
