// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advtoolbarstylers.pas' rev: 21.00

#ifndef AdvtoolbarstylersHPP
#define AdvtoolbarstylersHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Advtoolbar.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Advstyleif.hpp>	// Pascal unit
#include <Advmenus.hpp>	// Pascal unit
#include <Advglowbutton.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advtoolbarstylers
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TToolBarFantasyStyle { bsArctic, bsAquaBlue, bsChocolate, bsMacOS, bsSilverFox, bsSoftSand, bsTerminalGreen, bsTextured, bsWindowsClassic, bsUser, bsWhidbey };
#pragma option pop

#pragma option push -b-
enum TToolBarStyle { bsOffice2003Blue, bsOffice2003Silver, bsOffice2003Olive, bsOffice2003Classic, bsOffice2007Luna, bsOffice2007Obsidian, bsWindowsXP, bsWhidbeyStyle, bsCustom, bsOffice2007Silver, bsOfficeXP, bsWindowsVista, bsWindows7, bsTerminal, bsOffice2010Blue, bsOffice2010Silver, bsOffice2010Black, bsWindows8, bsOffice2013White, bsOffice2013LightGray, bsOffice2013Gray, bsWindows10, bsOffice2016White, bsOffice2016Gray, bsOffice2016Black };
#pragma option pop

class DELPHICLASS TNotifierWindow;
class PASCALIMPLEMENTATION TNotifierWindow : public Controls::TWinControl
{
	typedef Controls::TWinControl inherited;
	
private:
	Classes::TNotifyEvent FOnThemeChange;
	
protected:
	virtual void __fastcall WndProc(Messages::TMessage &Msg);
	
__published:
	__property Classes::TNotifyEvent OnThemeChange = {read=FOnThemeChange, write=FOnThemeChange};
public:
	/* TWinControl.Create */ inline __fastcall virtual TNotifierWindow(Classes::TComponent* AOwner) : Controls::TWinControl(AOwner) { }
	/* TWinControl.CreateParented */ inline __fastcall TNotifierWindow(HWND ParentWindow) : Controls::TWinControl(ParentWindow) { }
	/* TWinControl.Destroy */ inline __fastcall virtual ~TNotifierWindow(void) { }
	
};


class DELPHICLASS TAdvToolBarOfficeStyler;
class PASCALIMPLEMENTATION TAdvToolBarOfficeStyler : public Advtoolbar::TCustomAdvToolBarStyler
{
	typedef Advtoolbar::TCustomAdvToolBarStyler inherited;
	
private:
	Advstyleif::TOfficeTheme FOldOfficeTheme;
	bool FDesignTime;
	TNotifierWindow* FNotifierWnd;
	TToolBarStyle FToolBarStyle;
	
protected:
	virtual void __fastcall SetToolBarStyle(const TToolBarStyle Value);
	void __fastcall ThemeChanged(System::TObject* Sender);
	virtual void __fastcall SetAutoThemeAdapt(const bool Value);
	virtual void __fastcall InitStyle(void);
	
public:
	__fastcall virtual TAdvToolBarOfficeStyler(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvToolBarOfficeStyler(void);
	virtual void __fastcall Loaded(void);
	void __fastcall SaveToFile(System::UnicodeString FileName);
	void __fastcall LoadFromFile(System::UnicodeString FileName);
	void __fastcall SetComponentStyle(Advstyleif::TTMSStyle AStyle);
	void __fastcall SetComponentStyleAndAppColor(Advstyleif::TTMSStyle AStyle, Graphics::TColor AAppColor);
	__property UseBevel = {default=0};
	__property FormBorderColor = {default=8421504};
	void __fastcall UpdateAppColors(void);
	__property RoundEdges = {default=1};
	
__published:
	__property AppColor;
	__property TToolBarStyle Style = {read=FToolBarStyle, write=SetToolBarStyle, default=0};
	__property AdvMenuStyler;
	__property AutoThemeAdapt = {default=0};
	__property BackGround;
	__property BackGroundTransparent = {default=1};
	__property BackGroundDisplay = {default=0};
	__property BorderColor = {default=536870911};
	__property BorderColorHot = {default=536870911};
	__property ButtonAppearance;
	__property CaptionAppearance;
	__property CaptionFont;
	__property ContainerAppearance;
	__property Color;
	__property ColorHot;
	__property CompactGlowButtonAppearance;
	__property DockColor;
	__property DragGripStyle = {default=0};
	__property DragGripImage;
	__property FloatingWindowBorderColor;
	__property FloatingWindowBorderWidth = {default=2};
	__property Font;
	__property GlowButtonAppearance;
	__property GroupAppearance;
	__property PageAppearance;
	__property PagerCaption;
	__property QATAppearance;
	__property RightHandleImage;
	__property RightHandleColor = {default=8421504};
	__property RightHandleColorTo = {default=8421504};
	__property RightHandleColorHot;
	__property RightHandleColorHotTo;
	__property RightHandleColorDown;
	__property RightHandleColorDownTo;
	__property TabAppearance;
	__property SystemFont = {default=1};
private:
	void *__ITMSStyleEx;	/* Advstyleif::ITMSStyleEx */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Advstyleif::_di_ITMSStyleEx()
	{
		Advstyleif::_di_ITMSStyleEx intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITMSStyleEx*(void) { return (ITMSStyleEx*)&__ITMSStyleEx; }
	#endif
	
};


class DELPHICLASS TAdvToolBarFantasyStyler;
class PASCALIMPLEMENTATION TAdvToolBarFantasyStyler : public Advtoolbar::TCustomAdvToolBarStyler
{
	typedef Advtoolbar::TCustomAdvToolBarStyler inherited;
	
private:
	TToolBarFantasyStyle FToolBarStyle;
	
protected:
	void __fastcall SetToolBarStyle(const TToolBarFantasyStyle Value);
	
public:
	__fastcall virtual TAdvToolBarFantasyStyler(Classes::TComponent* AOwner);
	void __fastcall SaveToFile(System::UnicodeString FileName);
	void __fastcall LoadFromFile(System::UnicodeString FileName);
	__property UseBevel = {default=0};
	
__published:
	__property TToolBarFantasyStyle Style = {read=FToolBarStyle, write=SetToolBarStyle, default=2};
	__property AdvMenuStyler;
	__property BackGround;
	__property BackGroundTransparent = {default=1};
	__property BackGroundDisplay = {default=0};
	__property BorderColor = {default=536870911};
	__property BorderColorHot = {default=536870911};
	__property ButtonAppearance;
	__property CaptionAppearance;
	__property CaptionFont;
	__property ContainerAppearance;
	__property Color;
	__property ColorHot;
	__property CompactGlowButtonAppearance;
	__property DockColor;
	__property DragGripStyle = {default=0};
	__property DragGripImage;
	__property FloatingWindowBorderColor;
	__property FloatingWindowBorderWidth = {default=2};
	__property Font;
	__property GlowButtonAppearance;
	__property GroupAppearance;
	__property PageAppearance;
	__property PagerCaption;
	__property QATAppearance;
	__property RightHandleImage;
	__property RightHandleColor = {default=8421504};
	__property RightHandleColorTo = {default=8421504};
	__property RightHandleColorHot;
	__property RightHandleColorHotTo;
	__property RightHandleColorDown;
	__property RightHandleColorDownTo;
	__property TabAppearance;
public:
	/* TCustomAdvToolBarStyler.Destroy */ inline __fastcall virtual ~TAdvToolBarFantasyStyler(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Advtoolbarstylers */
using namespace Advtoolbarstylers;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvtoolbarstylersHPP
