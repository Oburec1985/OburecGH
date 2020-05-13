// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advappstyler.pas' rev: 21.00

#ifndef AdvappstylerHPP
#define AdvappstylerHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Advstyleif.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advappstyler
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TThemeNotifierWindow;
class PASCALIMPLEMENTATION TThemeNotifierWindow : public Controls::TWinControl
{
	typedef Controls::TWinControl inherited;
	
private:
	Classes::TNotifyEvent FOnThemeChange;
	
protected:
	virtual void __fastcall WndProc(Messages::TMessage &Msg);
	
__published:
	__property Classes::TNotifyEvent OnThemeChange = {read=FOnThemeChange, write=FOnThemeChange};
public:
	/* TWinControl.Create */ inline __fastcall virtual TThemeNotifierWindow(Classes::TComponent* AOwner) : Controls::TWinControl(AOwner) { }
	/* TWinControl.CreateParented */ inline __fastcall TThemeNotifierWindow(HWND ParentWindow) : Controls::TWinControl(ParentWindow) { }
	/* TWinControl.Destroy */ inline __fastcall virtual ~TThemeNotifierWindow(void) { }
	
};


class DELPHICLASS TAdvAppStyler;
class DELPHICLASS TAdvFormStyler;
class PASCALIMPLEMENTATION TAdvAppStyler : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	Advstyleif::TColorTones FTones;
	Classes::TList* FForms;
	Advstyleif::TTMSStyle FStyle;
	bool FAutoThemeAdapt;
	TThemeNotifierWindow* FNotifier;
	Classes::TNotifyEvent FOnChange;
	Advstyleif::TMetroStyle FMetroStyle;
	bool FMetro;
	Graphics::TColor FMetroTextColor;
	Graphics::TColor FMetroColor;
	bool FEnabled;
	Graphics::TColor FAppColor;
	void __fastcall SetStyle(const Advstyleif::TTMSStyle Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	void __fastcall ThemeChanged(System::TObject* Sender);
	void __fastcall SetAutoThemeAdapt(const bool Value);
	void __fastcall SetMetro(const bool Value);
	void __fastcall SetMetroColor(const Graphics::TColor Value);
	void __fastcall SetMetroStyle(const Advstyleif::TMetroStyle Value);
	void __fastcall SetMetroTextColor(const Graphics::TColor Value);
	void __fastcall SetEnabled(const bool Value);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall ChangeTones(void);
	virtual void __fastcall DoChange(void);
	
public:
	__fastcall virtual TAdvAppStyler(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvAppStyler(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall ApplyStyle(void);
	void __fastcall RegisterFormStyler(TAdvFormStyler* AFormStyler);
	void __fastcall UnRegisterFormStyler(TAdvFormStyler* AFormStyler);
	int __fastcall GetVersionNr(void);
	void __fastcall SetColorTones(const Advstyleif::TColorTones &ATones);
	
__published:
	__property Graphics::TColor AppColor = {read=FAppColor, write=FAppColor, default=536870911};
	__property bool AutoThemeAdapt = {read=FAutoThemeAdapt, write=SetAutoThemeAdapt, default=0};
	__property bool Enabled = {read=FEnabled, write=SetEnabled, default=1};
	__property bool Metro = {read=FMetro, write=SetMetro, default=0};
	__property Graphics::TColor MetroColor = {read=FMetroColor, write=SetMetroColor, default=-16777203};
	__property Graphics::TColor MetroTextColor = {read=FMetroTextColor, write=SetMetroTextColor, default=0};
	__property Advstyleif::TMetroStyle MetroStyle = {read=FMetroStyle, write=SetMetroStyle, default=0};
	__property Advstyleif::TTMSStyle Style = {read=FStyle, write=SetStyle, default=8};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion, stored=false};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
};


typedef void __fastcall (__closure *TApplyStyleEvent)(System::TObject* Sender, Classes::TComponent* AComponent, bool &Allow);

typedef void __fastcall (__closure *TAppliedStyleEvent)(System::TObject* Sender, Classes::TComponent* AComponent);

class PASCALIMPLEMENTATION TAdvFormStyler : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	Advstyleif::TTMSStyle FStyle;
	TAdvAppStyler* FAppStyle;
	Classes::TNotifyEvent FOnChange;
	bool FAutoThemeAdapt;
	TThemeNotifierWindow* FNotifier;
	TApplyStyleEvent FOnApplyStyle;
	TApplyStyleEvent FOnApplyColorTones;
	Advstyleif::TMetroStyle FMetroStyle;
	bool FMetro;
	Graphics::TColor FMetroTextColor;
	Graphics::TColor FMetroColor;
	Advstyleif::TColorTones FTones;
	TAppliedStyleEvent FOnAppliedStyle;
	TAppliedStyleEvent FOnAppliedColorTones;
	bool FEnabled;
	Stdctrls::TComboBox* FComboBox;
	Graphics::TColor FAppColor;
	void __fastcall SetStyle(const Advstyleif::TTMSStyle Value);
	void __fastcall SetAppStyle(const TAdvAppStyler* Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	void __fastcall ThemeChanged(System::TObject* Sender);
	void __fastcall SetAutoThemeAdapt(const bool Value);
	void __fastcall SetMetro(const bool Value);
	void __fastcall SetMetroColor(const Graphics::TColor Value);
	void __fastcall SetMetroStyle(const Advstyleif::TMetroStyle Value);
	void __fastcall SetMetroTextColor(const Graphics::TColor Value);
	void __fastcall SetEnabled(const bool Value);
	void __fastcall SetComboBox(const Stdctrls::TComboBox* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	virtual void __fastcall ChangeTones(void);
	virtual void __fastcall DoChange(void);
	
public:
	virtual void __fastcall Loaded(void);
	__fastcall virtual TAdvFormStyler(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvFormStyler(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall ApplyStyle(void);
	void __fastcall ApplyStyleToForm(Forms::TCustomForm* Form, Advstyleif::TTMSStyle AStyle);
	void __fastcall ApplyStyleToFrame(Forms::TCustomFrame* Frame, Advstyleif::TTMSStyle AStyle);
	void __fastcall ApplyColorTonesToForm(Forms::TCustomForm* Form, const Advstyleif::TColorTones &ATones);
	void __fastcall ApplyColorTonesToFrame(Forms::TCustomFrame* Frame, const Advstyleif::TColorTones &ATones);
	void __fastcall SetColorTones(const Advstyleif::TColorTones &ATones);
	int __fastcall GetVersionNr(void);
	Classes::TStringList* __fastcall GetStyles(void);
	void __fastcall HandleStyleSelect(System::TObject* Sender);
	
__published:
	__property Graphics::TColor AppColor = {read=FAppColor, write=FAppColor, default=0};
	__property bool AutoThemeAdapt = {read=FAutoThemeAdapt, write=SetAutoThemeAdapt, default=0};
	__property bool Enabled = {read=FEnabled, write=SetEnabled, default=1};
	__property bool Metro = {read=FMetro, write=SetMetro, default=0};
	__property Graphics::TColor MetroColor = {read=FMetroColor, write=SetMetroColor, default=-16777203};
	__property Graphics::TColor MetroTextColor = {read=FMetroTextColor, write=SetMetroTextColor, default=0};
	__property Advstyleif::TMetroStyle MetroStyle = {read=FMetroStyle, write=SetMetroStyle, default=0};
	__property Advstyleif::TTMSStyle Style = {read=FStyle, write=SetStyle, default=8};
	__property TAdvAppStyler* AppStyle = {read=FAppStyle, write=SetAppStyle};
	__property Stdctrls::TComboBox* ComboBox = {read=FComboBox, write=SetComboBox};
	__property TApplyStyleEvent OnApplyStyle = {read=FOnApplyStyle, write=FOnApplyStyle};
	__property TAppliedStyleEvent OnAppliedStyle = {read=FOnAppliedStyle, write=FOnAppliedStyle};
	__property TApplyStyleEvent OnApplyColorTones = {read=FOnApplyColorTones, write=FOnApplyColorTones};
	__property TAppliedStyleEvent OnAppliedColorTones = {read=FOnAppliedColorTones, write=FOnAppliedColorTones};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion, stored=false};
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x2;
static const ShortInt MIN_VER = 0x2;
static const ShortInt REL_VER = 0x1;
static const ShortInt BLD_VER = 0x0;
extern PACKAGE void __fastcall Register(void);

}	/* namespace Advappstyler */
using namespace Advappstyler;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvappstylerHPP
