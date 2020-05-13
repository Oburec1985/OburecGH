// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advofficepager.pas' rev: 21.00

#ifndef AdvofficepagerHPP
#define AdvofficepagerHPP

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
#include <Math.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Commctrl.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Advgdip.hpp>	// Pascal unit
#include <Gdipicture.hpp>	// Pascal unit
#include <Advhintinfo.hpp>	// Pascal unit
#include <Advglowbutton.hpp>	// Pascal unit
#include <Acxpvs.hpp>	// Pascal unit
#include <Advdwm.hpp>	// Pascal unit
#include <Advstyleif.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Axctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advofficepager
{
//-- type declarations -------------------------------------------------------
typedef Controls::THintInfo THintInfo;

typedef Controls::PHintInfo PHintInfo;

#pragma option push -b-
enum TGradientDirection { gdHorizontal, gdVertical };
#pragma option pop

#pragma option push -b-
enum TGlowState { gsHover, gsPush, gsNone };
#pragma option pop

#pragma option push -b-
enum TButtonLayout { blGlyphLeft, blGlyphTop, blGlyphRight, blGlyphBottom };
#pragma option pop

#pragma option push -b-
enum TImagePosition { ipLeft, ipTop, ipRight, ipBottom };
#pragma option pop

#pragma option push -b-
enum TDropDownPosition { dpRight, dpBottom };
#pragma option pop

#pragma option push -b-
enum TCloseOnTabPos { cpRight, cpLeft };
#pragma option pop

#pragma option push -b-
enum TAdvTabShape { tsRectangle, tsLeftRamp, tsRightRamp, tsLeftRightRamp };
#pragma option pop

#pragma option push -b-
enum TCloseButtonLook { cblOffice, cblChrome };
#pragma option pop

typedef ShortInt TTabRounding;

class DELPHICLASS TPagerTabSettings;
class DELPHICLASS TAdvOfficePager;
class PASCALIMPLEMENTATION TPagerTabSettings : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	int FLeftMargin;
	int FRightMargin;
	Classes::TNotifyEvent FOnChange;
	int FHeight;
	int FStartMargin;
	int FEndMargin;
	int FSpacing;
	int FWidth;
	bool FWordWrap;
	TImagePosition FImagePosition;
	TTabRounding FRounding;
	TAdvTabShape FShape;
	Classes::TAlignment FAlignment;
	bool FGlass;
	TAdvOfficePager* FPager;
	bool FButtonBorder;
	void __fastcall SetLeftMargin(const int Value);
	void __fastcall SetRightMargin(const int Value);
	void __fastcall SetHeight(const int Value);
	void __fastcall SetStartMargin(const int Value);
	void __fastcall SetEndMargin(const int Value);
	void __fastcall SetSpacing(const int Value);
	void __fastcall SetWidth(const int Value);
	void __fastcall SetWordWrap(const bool Value);
	void __fastcall SetImagePosition(const TImagePosition Value);
	void __fastcall SetRounding(const TTabRounding Value);
	void __fastcall SetShape(const TAdvTabShape Value);
	void __fastcall SetAlignment(const Classes::TAlignment Value);
	void __fastcall SetGlass(const bool Value);
	void __fastcall SetButtonBorder(const bool Value);
	
protected:
	void __fastcall Changed(void);
	__property TAdvOfficePager* Pager = {read=FPager};
	
public:
	__fastcall TPagerTabSettings(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	
__published:
	__property Classes::TAlignment Alignment = {read=FAlignment, write=SetAlignment, default=0};
	__property bool ButtonBorder = {read=FButtonBorder, write=SetButtonBorder, default=1};
	__property int LeftMargin = {read=FLeftMargin, write=SetLeftMargin, default=4};
	__property int RightMargin = {read=FRightMargin, write=SetRightMargin, default=4};
	__property int StartMargin = {read=FStartMargin, write=SetStartMargin, default=4};
	__property int EndMargin = {read=FEndMargin, write=SetEndMargin, default=0};
	__property int Height = {read=FHeight, write=SetHeight, default=26};
	__property int Spacing = {read=FSpacing, write=SetSpacing, default=4};
	__property int Width = {read=FWidth, write=SetWidth, default=0};
	__property bool WordWrap = {read=FWordWrap, write=SetWordWrap, default=0};
	__property TImagePosition ImagePosition = {read=FImagePosition, write=SetImagePosition, default=0};
	__property TAdvTabShape Shape = {read=FShape, write=SetShape, default=0};
	__property TTabRounding Rounding = {read=FRounding, write=SetRounding, default=1};
	__property bool Glass = {read=FGlass, write=SetGlass, default=0};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TPagerTabSettings(void) { }
	
};


class DELPHICLASS TGradientBackground;
class PASCALIMPLEMENTATION TGradientBackground : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	int FSteps;
	Graphics::TColor FColor;
	Graphics::TColor FColorTo;
	TGradientDirection FDirection;
	Classes::TNotifyEvent FOnChange;
	void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetColorTo(const Graphics::TColor Value);
	void __fastcall SetDirection(const TGradientDirection Value);
	void __fastcall SetSteps(const int Value);
	void __fastcall Changed(void);
	
public:
	__fastcall TGradientBackground(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property Graphics::TColor Color = {read=FColor, write=SetColor, nodefault};
	__property Graphics::TColor ColorTo = {read=FColorTo, write=SetColorTo, nodefault};
	__property TGradientDirection Direction = {read=FDirection, write=SetDirection, nodefault};
	__property int Steps = {read=FSteps, write=SetSteps, default=64};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TGradientBackground(void) { }
	
};


class DELPHICLASS TVistaBackground;
class PASCALIMPLEMENTATION TVistaBackground : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	int FSteps;
	Graphics::TColor FColor;
	Graphics::TColor FColorTo;
	Classes::TNotifyEvent FOnChange;
	Graphics::TColor FColorMirror;
	Graphics::TColor FColorMirrorTo;
	Graphics::TColor FBorderColor;
	Advglowbutton::TGDIPGradient FGradientMirror;
	Advglowbutton::TGDIPGradient FGradient;
	void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetColorTo(const Graphics::TColor Value);
	void __fastcall SetSteps(const int Value);
	void __fastcall Changed(void);
	void __fastcall SetBorderColor(const Graphics::TColor Value);
	void __fastcall SetColorMirror(const Graphics::TColor Value);
	void __fastcall SetColorMirrorTo(const Graphics::TColor Value);
	void __fastcall SetGradient(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientMirror(const Advglowbutton::TGDIPGradient Value);
	
public:
	__fastcall TVistaBackground(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property Graphics::TColor BorderColor = {read=FBorderColor, write=SetBorderColor, nodefault};
	__property Graphics::TColor Color = {read=FColor, write=SetColor, nodefault};
	__property Graphics::TColor ColorTo = {read=FColorTo, write=SetColorTo, nodefault};
	__property Graphics::TColor ColorMirror = {read=FColorMirror, write=SetColorMirror, nodefault};
	__property Graphics::TColor ColorMirrorTo = {read=FColorMirrorTo, write=SetColorMirrorTo, nodefault};
	__property Advglowbutton::TGDIPGradient Gradient = {read=FGradient, write=SetGradient, nodefault};
	__property Advglowbutton::TGDIPGradient GradientMirror = {read=FGradientMirror, write=SetGradientMirror, nodefault};
	__property int Steps = {read=FSteps, write=SetSteps, default=64};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TVistaBackground(void) { }
	
};


class DELPHICLASS TCustomTabAppearance;
class PASCALIMPLEMENTATION TCustomTabAppearance : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	Classes::TNotifyEvent FOnChange;
	Graphics::TColor FBorderColor;
	Graphics::TColor FBorderColorHot;
	Graphics::TColor FColor;
	Graphics::TColor FColorTo;
	Graphics::TColor FColorHot;
	Graphics::TColor FColorHotTo;
	Graphics::TColor FColorSelectedTo;
	Graphics::TColor FBorderColorDisabled;
	Graphics::TColor FBorderColorSelected;
	Graphics::TColor FColorDisabled;
	Graphics::TColor FColorDisabledTo;
	Graphics::TColor FColorSelected;
	Graphics::TColor FColorMirror;
	Graphics::TColor FColorMirrorTo;
	Graphics::TColor FColorMirrorHot;
	Graphics::TColor FColorMirrorHotTo;
	Advglowbutton::TGDIPGradient FGradientMirror;
	Advglowbutton::TGDIPGradient FGradientMirrorHot;
	Advglowbutton::TGDIPGradient FGradient;
	Advglowbutton::TGDIPGradient FGradientHot;
	Graphics::TColor FColorMirrorDisabledTo;
	Graphics::TColor FColorMirrorDisabled;
	Graphics::TColor FColorMirrorSelectedTo;
	Graphics::TColor FColorMirrorSelected;
	Advglowbutton::TGDIPGradient FGradientSelected;
	Advglowbutton::TGDIPGradient FGradientDisabled;
	Advglowbutton::TGDIPGradient FGradientMirrorSelected;
	Advglowbutton::TGDIPGradient FGradientMirrorDisabled;
	Graphics::TColor FTextColorDisabled;
	Graphics::TColor FTextColorSelected;
	Graphics::TColor FTextColor;
	Graphics::TColor FTextColorHot;
	TGradientBackground* FBackGround;
	Graphics::TColor FBorderColorSelectedHot;
	Graphics::TColor FBorderColorDown;
	Graphics::TFont* FFont;
	Graphics::TColor FHighLightColorHot;
	Graphics::TColor FShadowColor;
	Graphics::TColor FHighLightColorDown;
	Graphics::TColor FHighLightColorSelected;
	Graphics::TColor FHighLightColorSelectedHot;
	Graphics::TColor FHighLightColor;
	Classes::TNotifyEvent FOnFontChange;
	void __fastcall OnBackGroundChanged(System::TObject* Sender);
	void __fastcall OnFontChanged(System::TObject* Sender);
	void __fastcall SetBackGround(const TGradientBackground* Value);
	void __fastcall SetBorderColor(const Graphics::TColor Value);
	void __fastcall SetBorderColorDisabled(const Graphics::TColor Value);
	void __fastcall SetBorderColorSelected(const Graphics::TColor Value);
	void __fastcall SetBorderColorSelectedHot(const Graphics::TColor Value);
	void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetColorDisabled(const Graphics::TColor Value);
	void __fastcall SetColorDisabledTo(const Graphics::TColor Value);
	void __fastcall SetColorHot(const Graphics::TColor Value);
	void __fastcall SetColorHotTo(const Graphics::TColor Value);
	void __fastcall SetColorMirror(const Graphics::TColor Value);
	void __fastcall SetColorMirrorDisabled(const Graphics::TColor Value);
	void __fastcall SetColorMirrorDisabledTo(const Graphics::TColor Value);
	void __fastcall SetColorMirrorHot(const Graphics::TColor Value);
	void __fastcall SetColorMirrorHotTo(const Graphics::TColor Value);
	void __fastcall SetColorMirrorSelected(const Graphics::TColor Value);
	void __fastcall SetColorMirrorSelectedTo(const Graphics::TColor Value);
	void __fastcall SetColorMirrorTo(const Graphics::TColor Value);
	void __fastcall SetColorSelected(const Graphics::TColor Value);
	void __fastcall SetColorSelectedTo(const Graphics::TColor Value);
	void __fastcall SetColorTo(const Graphics::TColor Value);
	void __fastcall SetGradient(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientDisabled(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientHot(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientMirror(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientMirrorDisabled(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientMirrorHot(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientMirrorSelected(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetGradientSelected(const Advglowbutton::TGDIPGradient Value);
	void __fastcall SetTextColor(const Graphics::TColor Value);
	void __fastcall SetTextColorDisabled(const Graphics::TColor Value);
	void __fastcall SetTextColorHot(const Graphics::TColor Value);
	void __fastcall SetTextColorSelected(const Graphics::TColor Value);
	void __fastcall SetBorderColorDown(const Graphics::TColor Value);
	void __fastcall SetFont(const Graphics::TFont* Value);
	
protected:
	void __fastcall Changed(void);
	void __fastcall ClearValues(void);
	__property TGradientBackground* BackGround = {read=FBackGround, write=SetBackGround};
	__property Classes::TNotifyEvent OnFontChange = {read=FOnFontChange, write=FOnFontChange};
	
public:
	__fastcall TCustomTabAppearance(void);
	__fastcall virtual ~TCustomTabAppearance(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	
__published:
	__property Graphics::TColor BorderColor = {read=FBorderColor, write=SetBorderColor, nodefault};
	__property Graphics::TColor BorderColorHot = {read=FBorderColorHot, write=FBorderColorHot, nodefault};
	__property Graphics::TColor BorderColorSelected = {read=FBorderColorSelected, write=SetBorderColorSelected, nodefault};
	__property Graphics::TColor BorderColorSelectedHot = {read=FBorderColorSelectedHot, write=SetBorderColorSelectedHot, nodefault};
	__property Graphics::TColor BorderColorDisabled = {read=FBorderColorDisabled, write=SetBorderColorDisabled, nodefault};
	__property Graphics::TColor BorderColorDown = {read=FBorderColorDown, write=SetBorderColorDown, nodefault};
	__property Graphics::TColor Color = {read=FColor, write=SetColor, nodefault};
	__property Graphics::TColor ColorTo = {read=FColorTo, write=SetColorTo, nodefault};
	__property Graphics::TColor ColorSelected = {read=FColorSelected, write=SetColorSelected, nodefault};
	__property Graphics::TColor ColorSelectedTo = {read=FColorSelectedTo, write=SetColorSelectedTo, nodefault};
	__property Graphics::TColor ColorDisabled = {read=FColorDisabled, write=SetColorDisabled, nodefault};
	__property Graphics::TColor ColorDisabledTo = {read=FColorDisabledTo, write=SetColorDisabledTo, nodefault};
	__property Graphics::TColor ColorHot = {read=FColorHot, write=SetColorHot, nodefault};
	__property Graphics::TColor ColorHotTo = {read=FColorHotTo, write=SetColorHotTo, nodefault};
	__property Graphics::TColor ColorMirror = {read=FColorMirror, write=SetColorMirror, nodefault};
	__property Graphics::TColor ColorMirrorTo = {read=FColorMirrorTo, write=SetColorMirrorTo, nodefault};
	__property Graphics::TColor ColorMirrorHot = {read=FColorMirrorHot, write=SetColorMirrorHot, nodefault};
	__property Graphics::TColor ColorMirrorHotTo = {read=FColorMirrorHotTo, write=SetColorMirrorHotTo, nodefault};
	__property Graphics::TColor ColorMirrorSelected = {read=FColorMirrorSelected, write=SetColorMirrorSelected, nodefault};
	__property Graphics::TColor ColorMirrorSelectedTo = {read=FColorMirrorSelectedTo, write=SetColorMirrorSelectedTo, nodefault};
	__property Graphics::TColor ColorMirrorDisabled = {read=FColorMirrorDisabled, write=SetColorMirrorDisabled, nodefault};
	__property Graphics::TColor ColorMirrorDisabledTo = {read=FColorMirrorDisabledTo, write=SetColorMirrorDisabledTo, nodefault};
	__property Graphics::TFont* Font = {read=FFont, write=SetFont};
	__property Advglowbutton::TGDIPGradient Gradient = {read=FGradient, write=SetGradient, nodefault};
	__property Advglowbutton::TGDIPGradient GradientMirror = {read=FGradientMirror, write=SetGradientMirror, nodefault};
	__property Advglowbutton::TGDIPGradient GradientHot = {read=FGradientHot, write=SetGradientHot, nodefault};
	__property Advglowbutton::TGDIPGradient GradientMirrorHot = {read=FGradientMirrorHot, write=SetGradientMirrorHot, nodefault};
	__property Advglowbutton::TGDIPGradient GradientSelected = {read=FGradientSelected, write=SetGradientSelected, nodefault};
	__property Advglowbutton::TGDIPGradient GradientMirrorSelected = {read=FGradientMirrorSelected, write=SetGradientMirrorSelected, nodefault};
	__property Advglowbutton::TGDIPGradient GradientDisabled = {read=FGradientDisabled, write=SetGradientDisabled, nodefault};
	__property Advglowbutton::TGDIPGradient GradientMirrorDisabled = {read=FGradientMirrorDisabled, write=SetGradientMirrorDisabled, nodefault};
	__property Graphics::TColor TextColor = {read=FTextColor, write=SetTextColor, nodefault};
	__property Graphics::TColor TextColorHot = {read=FTextColorHot, write=SetTextColorHot, nodefault};
	__property Graphics::TColor TextColorSelected = {read=FTextColorSelected, write=SetTextColorSelected, nodefault};
	__property Graphics::TColor TextColorDisabled = {read=FTextColorDisabled, write=SetTextColorDisabled, nodefault};
	__property Graphics::TColor ShadowColor = {read=FShadowColor, write=FShadowColor, nodefault};
	__property Graphics::TColor HighLightColor = {read=FHighLightColor, write=FHighLightColor, nodefault};
	__property Graphics::TColor HighLightColorHot = {read=FHighLightColorHot, write=FHighLightColorHot, nodefault};
	__property Graphics::TColor HighLightColorSelected = {read=FHighLightColorSelected, write=FHighLightColorSelected, nodefault};
	__property Graphics::TColor HighLightColorSelectedHot = {read=FHighLightColorSelectedHot, write=FHighLightColorSelectedHot, nodefault};
	__property Graphics::TColor HighLightColorDown = {read=FHighLightColorDown, write=FHighLightColorDown, nodefault};
};


class DELPHICLASS TTabAppearance;
class PASCALIMPLEMENTATION TTabAppearance : public TCustomTabAppearance
{
	typedef TCustomTabAppearance inherited;
	
__published:
	__property BackGround;
public:
	/* TCustomTabAppearance.Create */ inline __fastcall TTabAppearance(void) : TCustomTabAppearance() { }
	/* TCustomTabAppearance.Destroy */ inline __fastcall virtual ~TTabAppearance(void) { }
	
};


class DELPHICLASS TPagerTabScroller;
class PASCALIMPLEMENTATION TPagerTabScroller : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FMin;
	int FMax;
	int FPosition;
	bool FVisible;
	void __fastcall SetMax(const int Value);
	void __fastcall SetMin(const int Value);
	void __fastcall SetPosition(const int Value);
	void __fastcall SetVisible(const bool Value);
	
public:
	__fastcall TPagerTabScroller(void);
	bool __fastcall CanGoForward(void);
	bool __fastcall CanGoBack(void);
	__property int Min = {read=FMin, write=SetMin, nodefault};
	__property int Max = {read=FMax, write=SetMax, nodefault};
	__property int Position = {read=FPosition, write=SetPosition, nodefault};
	__property bool Visible = {read=FVisible, write=SetVisible, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TPagerTabScroller(void) { }
	
};


class DELPHICLASS TDbgList;
class PASCALIMPLEMENTATION TDbgList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	void * operator[](int Index) { return Items[Index]; }
	
private:
	void * __fastcall GetItemsEx(int Index);
	void __fastcall SetItemsEx(int Index, const void * Value);
	
public:
	__property void * Items[int Index] = {read=GetItemsEx, write=SetItemsEx/*, default*/};
public:
	/* TList.Destroy */ inline __fastcall virtual ~TDbgList(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TDbgList(void) : Classes::TList() { }
	
};


class DELPHICLASS TPageButtonSettings;
class PASCALIMPLEMENTATION TPageButtonSettings : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	Classes::TNotifyEvent FOnChange;
	bool FPageListButton;
	bool FCloseButton;
	Gdipicture::TGDIPPicture* FScrollButtonNextPicture;
	Gdipicture::TGDIPPicture* FScrollButtonPrevPicture;
	Gdipicture::TGDIPPicture* FPageListButtonPicture;
	Gdipicture::TGDIPPicture* FCloseButtonPicture;
	System::UnicodeString FScrollButtonPrevHint;
	System::UnicodeString FScrollButtonNextHint;
	System::UnicodeString FCloseButtonHint;
	System::UnicodeString FPageListButtonHint;
	bool FScrollButtonsAlways;
	Gdipicture::TGDIPPicture* FScrollButtonFirstPicture;
	Gdipicture::TGDIPPicture* FScrollButtonLastPicture;
	System::UnicodeString FScrollButtonFirstHint;
	System::UnicodeString FScrollButtonLastHint;
	bool FLastButton;
	bool FFirstButton;
	System::UnicodeString FClosedListButtonHint;
	Gdipicture::TGDIPPicture* FClosedListButtonPicture;
	bool FClosedListButton;
	TCloseButtonLook FCloseButtonLook;
	int FButtonSize;
	bool FShowInsertButton;
	System::UnicodeString FInsertButtonHint;
	void __fastcall Changed(void);
	void __fastcall OnPictureChanged(System::TObject* Sender);
	void __fastcall SetCloseButton(const bool Value);
	void __fastcall SetCloseButtonPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetPageListButton(const bool Value);
	void __fastcall SetPageListButtonPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetScrollButtonNextPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetScrollButtonPrevPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetScrollButtonsAlways(const bool Value);
	void __fastcall SetScrollButtonFirstPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetScrollButtonLastPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetFirstButton(const bool Value);
	void __fastcall SetLastButton(const bool Value);
	void __fastcall SetClosedListButtonPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetClosedListButton(const bool Value);
	void __fastcall SetCloseButtonLook(const TCloseButtonLook Value);
	void __fastcall SetButtonSize(const int Value);
	void __fastcall SetShowInsertButton(const bool Value);
	
protected:
	Gdipicture::TGDIPPicture* FScrollButtonDownPicture;
	Gdipicture::TGDIPPicture* FScrollButtonDownLastPicture;
	Gdipicture::TGDIPPicture* FScrollButtonUpPicture;
	Gdipicture::TGDIPPicture* FScrollButtonUpFirstPicture;
	bool FPrevPictureChanged;
	bool FNextPictureChanged;
	bool FFirstPictureChanged;
	bool FLastPictureChanged;
	
public:
	__fastcall TPageButtonSettings(void);
	__fastcall virtual ~TPageButtonSettings(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property bool CloseButton = {read=FCloseButton, write=SetCloseButton, default=0};
	__property bool PageListButton = {read=FPageListButton, write=SetPageListButton, default=0};
	__property bool ClosedListButton = {read=FClosedListButton, write=SetClosedListButton, default=0};
	__property Gdipicture::TGDIPPicture* CloseButtonPicture = {read=FCloseButtonPicture, write=SetCloseButtonPicture};
	__property Gdipicture::TGDIPPicture* PageListButtonPicture = {read=FPageListButtonPicture, write=SetPageListButtonPicture};
	__property Gdipicture::TGDIPPicture* ScrollButtonPrevPicture = {read=FScrollButtonPrevPicture, write=SetScrollButtonPrevPicture};
	__property Gdipicture::TGDIPPicture* ScrollButtonNextPicture = {read=FScrollButtonNextPicture, write=SetScrollButtonNextPicture};
	__property Gdipicture::TGDIPPicture* ScrollButtonFirstPicture = {read=FScrollButtonFirstPicture, write=SetScrollButtonFirstPicture};
	__property Gdipicture::TGDIPPicture* ScrollButtonLastPicture = {read=FScrollButtonLastPicture, write=SetScrollButtonLastPicture};
	__property Gdipicture::TGDIPPicture* ClosedListButtonPicture = {read=FClosedListButtonPicture, write=SetClosedListButtonPicture};
	__property System::UnicodeString CloseButtonHint = {read=FCloseButtonHint, write=FCloseButtonHint};
	__property System::UnicodeString InsertButtonHint = {read=FInsertButtonHint, write=FInsertButtonHint};
	__property System::UnicodeString PageListButtonHint = {read=FPageListButtonHint, write=FPageListButtonHint};
	__property bool ScrollButtonsAlways = {read=FScrollButtonsAlways, write=SetScrollButtonsAlways, default=0};
	__property System::UnicodeString ScrollButtonNextHint = {read=FScrollButtonNextHint, write=FScrollButtonNextHint};
	__property System::UnicodeString ScrollButtonPrevHint = {read=FScrollButtonPrevHint, write=FScrollButtonPrevHint};
	__property System::UnicodeString ScrollButtonFirstHint = {read=FScrollButtonFirstHint, write=FScrollButtonFirstHint};
	__property System::UnicodeString ScrollButtonLastHint = {read=FScrollButtonLastHint, write=FScrollButtonLastHint};
	__property System::UnicodeString ClosedListButtonHint = {read=FClosedListButtonHint, write=FClosedListButtonHint};
	__property bool FirstButton = {read=FFirstButton, write=SetFirstButton, default=0};
	__property bool LastButton = {read=FLastButton, write=SetLastButton, default=0};
	__property TCloseButtonLook CloseButtonLook = {read=FCloseButtonLook, write=SetCloseButtonLook, default=0};
	__property int ButtonSize = {read=FButtonSize, write=SetButtonSize, default=18};
	__property bool ShowInsertButton = {read=FShowInsertButton, write=SetShowInsertButton, default=0};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
};


class DELPHICLASS TCustomAdvOfficePagerStyler;
class PASCALIMPLEMENTATION TCustomAdvOfficePagerStyler : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TDbgList* FControlList;
	TTabAppearance* FTabAppearance;
	TVistaBackground* FPageAppearance;
	bool FRoundEdges;
	bool FAutoThemeAdapt;
	Advglowbutton::TGlowButtonAppearance* FGlowButtonAppearance;
	int FBlendFactor;
	bool FShowShadow;
	bool FShow3D;
	TTabRounding FTabRounding;
	void __fastcall OnTabAppearanceChanged(System::TObject* Sender);
	void __fastcall OnTabAppearanceFontChanged(System::TObject* Sender);
	void __fastcall OnPageAppearanceChanged(System::TObject* Sender);
	void __fastcall OnGlowButtonAppearanceChanged(System::TObject* Sender);
	void __fastcall SetRoundEdges(const bool Value);
	void __fastcall SetTabAppearance(const TTabAppearance* Value);
	void __fastcall SetPageAppearance(const TVistaBackground* Value);
	void __fastcall SetGlowButtonAppearance(const Advglowbutton::TGlowButtonAppearance* Value);
	void __fastcall SetShow3D(const bool Value);
	void __fastcall SetShowShadow(const bool Value);
	void __fastcall SetTabRounding(const TTabRounding Value);
	
protected:
	void __fastcall AddControl(Controls::TCustomControl* AControl);
	void __fastcall RemoveControl(Controls::TCustomControl* AControl);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	void __fastcall Change(int PropID);
	void __fastcall SetColorTones(const Advstyleif::TColorTones &ATones);
	virtual void __fastcall InitColorTones(void);
	__property int BlendFactor = {read=FBlendFactor, write=FBlendFactor, nodefault};
	virtual void __fastcall SetAutoThemeAdapt(const bool Value);
	__property bool AutoThemeAdapt = {read=FAutoThemeAdapt, write=SetAutoThemeAdapt, default=0};
	__property TTabAppearance* TabAppearance = {read=FTabAppearance, write=SetTabAppearance};
	__property TVistaBackground* PageAppearance = {read=FPageAppearance, write=SetPageAppearance};
	__property bool RoundEdges = {read=FRoundEdges, write=SetRoundEdges, default=1};
	__property Advglowbutton::TGlowButtonAppearance* GlowButtonAppearance = {read=FGlowButtonAppearance, write=SetGlowButtonAppearance};
	__property bool Show3D = {read=FShow3D, write=SetShow3D, default=1};
	__property bool ShowShadow = {read=FShowShadow, write=SetShowShadow, default=1};
	__property TTabRounding TabRounding = {read=FTabRounding, write=SetTabRounding, default=1};
	
public:
	__fastcall virtual TCustomAdvOfficePagerStyler(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomAdvOfficePagerStyler(void);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
};


class DELPHICLASS TTabProgress;
class PASCALIMPLEMENTATION TTabProgress : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	Graphics::TColor FColor;
	Graphics::TColor FCompleteColor;
	Classes::TNotifyEvent FOnChange;
	int FMax;
	int FMin;
	bool FVisible;
	int FPosition;
	Graphics::TColor FColorTo;
	Graphics::TColor FCompleteColorTo;
	void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetCompleteColor(const Graphics::TColor Value);
	void __fastcall SetMax(const int Value);
	void __fastcall SetMin(const int Value);
	void __fastcall SetPosition(const int Value);
	void __fastcall SetVisible(const bool Value);
	void __fastcall SetColorTo(const Graphics::TColor Value);
	void __fastcall SetCompleteColorTo(const Graphics::TColor Value);
	
protected:
	void __fastcall Changed(void);
	void __fastcall Draw(Advgdip::TGPGraphics* g, const Types::TRect &R, bool RotateTabLeftRight, Comctrls::TTabPosition Direction);
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	
public:
	__fastcall TTabProgress(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property Graphics::TColor Color = {read=FColor, write=SetColor, default=16777215};
	__property Graphics::TColor ColorTo = {read=FColorTo, write=SetColorTo, default=12632256};
	__property Graphics::TColor CompleteColor = {read=FCompleteColor, write=SetCompleteColor, default=16777215};
	__property Graphics::TColor CompleteColorTo = {read=FCompleteColorTo, write=SetCompleteColorTo, default=255};
	__property int Min = {read=FMin, write=SetMin, default=0};
	__property int Max = {read=FMax, write=SetMax, default=100};
	__property int Position = {read=FPosition, write=SetPosition, default=50};
	__property bool Visible = {read=FVisible, write=SetVisible, default=0};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TTabProgress(void) { }
	
};


#pragma option push -b-
enum TArrowDirection { arrUp, arrDown, arrLeft, arrRight };
#pragma option pop

class DELPHICLASS TArrowWindow;
class PASCALIMPLEMENTATION TArrowWindow : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
private:
	TArrowDirection Dir;
	StaticArray<Types::TPoint, 9> Arrow;
	Graphics::TColor FBrColor;
	
public:
	__fastcall TArrowWindow(Classes::TComponent* AOwner, TArrowDirection direction);
	virtual void __fastcall Loaded(void);
	
protected:
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall Paint(void);
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
public:
	/* TCustomPanel.Create */ inline __fastcall virtual TArrowWindow(Classes::TComponent* AOwner) : Extctrls::TPanel(AOwner) { }
	
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TArrowWindow(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TArrowWindow(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


class DELPHICLASS TProWinControl;
class PASCALIMPLEMENTATION TProWinControl : public Controls::TWinControl
{
	typedef Controls::TWinControl inherited;
	
public:
	/* TWinControl.Create */ inline __fastcall virtual TProWinControl(Classes::TComponent* AOwner) : Controls::TWinControl(AOwner) { }
	/* TWinControl.CreateParented */ inline __fastcall TProWinControl(HWND ParentWindow) : Controls::TWinControl(ParentWindow) { }
	/* TWinControl.Destroy */ inline __fastcall virtual ~TProWinControl(void) { }
	
};


class DELPHICLASS TAdvPagerButton;
class PASCALIMPLEMENTATION TAdvPagerButton : public Controls::TGraphicControl
{
	typedef Controls::TGraphicControl inherited;
	
private:
	bool FMouseEnter;
	Classes::TNotifyEvent FOnMouseLeave;
	Classes::TNotifyEvent FOnMouseEnter;
	bool FTransparent;
	bool FMouseDown;
	Gdipicture::TGDIPPicture* FIPicture;
	Gdipicture::TGDIPPicture* FIHotPicture;
	Gdipicture::TGDIPPicture* FIDownPicture;
	Gdipicture::TGDIPPicture* FIDisabledPicture;
	bool FDrawClose;
	MESSAGE void __fastcall WMEraseBkGnd(Messages::TWMEraseBkgnd &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	void __fastcall SetTransparent(const bool Value);
	void __fastcall SetDownPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetHotPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetDisabledPicture(const Gdipicture::TGDIPPicture* Value);
	
protected:
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	virtual void __fastcall Paint(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	__property Enabled = {default=1};
	__property Font;
	__property bool Transparent = {read=FTransparent, write=SetTransparent, default=1};
	__property Gdipicture::TGDIPPicture* HotPicture = {read=FIHotPicture, write=SetHotPicture};
	__property Gdipicture::TGDIPPicture* Picture = {read=FIPicture, write=SetPicture};
	__property Gdipicture::TGDIPPicture* DownPicture = {read=FIDownPicture, write=SetDownPicture};
	__property Gdipicture::TGDIPPicture* DisabledPicture = {read=FIDisabledPicture, write=SetDisabledPicture};
	__property bool DrawClose = {read=FDrawClose, write=FDrawClose, default=1};
	__property Visible = {default=1};
	__property OnClick;
	__property OnDblClick;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property Classes::TNotifyEvent OnMouseEnter = {read=FOnMouseEnter, write=FOnMouseEnter};
	__property Classes::TNotifyEvent OnMouseLeave = {read=FOnMouseLeave, write=FOnMouseLeave};
	
public:
	__fastcall virtual TAdvPagerButton(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvPagerButton(void);
	DYNAMIC void __fastcall Click(void);
	virtual void __fastcall SetBounds(int ALeft, int ATop, int AWidth, int AHeight);
};


__interface IFloatingPagerWindow;
typedef System::DelphiInterface<IFloatingPagerWindow> _di_IFloatingPagerWindow;
__interface  INTERFACE_UUID("{26C994ED-F15A-4CBC-92FF-5DD24E3D24C6}") IFloatingPagerWindow  : public System::IInterface 
{
	
public:
	virtual TAdvOfficePager* __fastcall AdvPager(void) = 0 ;
	virtual void __fastcall SetAdvPager(TAdvOfficePager* Pager) = 0 ;
};

class DELPHICLASS TFloatingPagerWindow;
class PASCALIMPLEMENTATION TFloatingPagerWindow : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
private:
	TAdvOfficePager* FAdvPager;
	
public:
	TAdvOfficePager* __fastcall AdvPager(void);
	void __fastcall SetAdvPager(TAdvOfficePager* Pager);
	
__published:
	__property Height;
	__property Width;
	__property OnActivate;
	__property OnClose;
	__property OnCloseQuery;
	__property OnDeactivate;
	__property OnShow;
	__property OnHide;
	__property OnResize;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TFloatingPagerWindow(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TFloatingPagerWindow(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TFloatingPagerWindow(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TFloatingPagerWindow(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
private:
	void *__IFloatingPagerWindow;	/* IFloatingPagerWindow */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IFloatingPagerWindow()
	{
		_di_IFloatingPagerWindow intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IFloatingPagerWindow*(void) { return (IFloatingPagerWindow*)&__IFloatingPagerWindow; }
	#endif
	
};


typedef TMetaClass* TFloatingPagerWindowClass;

class DELPHICLASS TAdvOfficePage;
class PASCALIMPLEMENTATION TAdvOfficePage : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	bool FTabVisible;
	TAdvOfficePager* FAdvOfficePager;
	Controls::TCaption FCaption;
	bool FTabEnabled;
	Imglist::TImageIndex FImageIndex;
	Extctrls::TTimer* FTimer;
	int FTimeInc;
	int FStepHover;
	int FStepPush;
	TGlowState FGlowState;
	System::UnicodeString FTabHint;
	Advhintinfo::TAdvHintInfo* FOfficeHint;
	Gdipicture::TGDIPPicture* FIPicture;
	Gdipicture::TGDIPPicture* FIDisabledPicture;
	bool FUpdatingParent;
	Advglowbutton::TShortCutHintWindow* FShortCutHint;
	Advglowbutton::TShortCutHintPos FShortCutHintPos;
	System::UnicodeString FShortCutHintText;
	Classes::TNotifyEvent FOnShow;
	Classes::TNotifyEvent FOnHide;
	bool FShowClose;
	bool FUseTabAppearance;
	TTabAppearance* FTabAppearance;
	TVistaBackground* FPageAppearance;
	bool FUsePageAppearance;
	Graphics::TBitmap* FBkgCache;
	bool FValidCache;
	System::WideString FWideCaption;
	bool FShowCheckBox;
	bool FChecked;
	Advglowbutton::TAdvGlowButton* FCloseButton;
	TAdvPagerButton* FCloseButtonChrome;
	TTabProgress* FProgress;
	bool FGlow;
	Graphics::TColor FGlowColor;
	Graphics::TColor FTxtColor;
	int FTabIndex;
	bool FLocked;
	TAdvOfficePager* FParentPager;
	bool FFloating;
	bool FDraggingAccept;
	Graphics::TColor FBadgeColor;
	Graphics::TColor FBadgeTextColor;
	System::UnicodeString FBadge;
	System::TObject* FObject;
	void __fastcall TimerProc(System::TObject* Sender);
	HIDESBASE MESSAGE void __fastcall CMVisibleChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMShowingChanged(Messages::TMessage &Message);
	MESSAGE void __fastcall CMControlChange(Controls::TCMControlChange &Message);
	HIDESBASE MESSAGE void __fastcall CMControlListChange(Controls::TCMControlListChange &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Msg);
	void __fastcall PictureChanged(System::TObject* Sender);
	void __fastcall OnTabAppearanceFontChanged(System::TObject* Sender);
	void __fastcall OnTabAppearanceChanged(System::TObject* Sender);
	void __fastcall OnPageAppearanceChanged(System::TObject* Sender);
	void __fastcall OnProgressChanged(System::TObject* Sender);
	void __fastcall SetAdvOfficePager(const TAdvOfficePager* Value);
	void __fastcall SetTabVisible(const bool Value);
	void __fastcall SetCaption(const Controls::TCaption Value);
	void __fastcall SetTabEnabled(const bool Value);
	void __fastcall SetImageIndex(const Imglist::TImageIndex Value);
	void __fastcall SetOfficeHint(const Advhintinfo::TAdvHintInfo* Value);
	void __fastcall SetDisabledPicture(const Gdipicture::TGDIPPicture* Value);
	void __fastcall SetPicture(const Gdipicture::TGDIPPicture* Value);
	int __fastcall GetPageIndex(void);
	void __fastcall SetPageIndex(const int Value);
	void __fastcall SetShowClose(const bool Value);
	void __fastcall SetTabAppearance(const TTabAppearance* Value);
	void __fastcall SetUseTabAppearance(const bool Value);
	void __fastcall SetPageAppearance(const TVistaBackground* Value);
	void __fastcall SetUsePageAppearance(const bool Value);
	void __fastcall SetWideCaption(const System::WideString Value);
	void __fastcall SetShowCheckBox(const bool Value);
	void __fastcall SetChecked(const bool Value);
	void __fastcall SetProgress(const TTabProgress* Value);
	void __fastcall SetGlow(const bool Value);
	void __fastcall SetGlowColor(const Graphics::TColor Value);
	void __fastcall SetLocked(const bool Value);
	void __fastcall SetBadge(const System::UnicodeString Value);
	void __fastcall SetBadgeColor(const Graphics::TColor Value);
	void __fastcall SetBadgeTextColor(const Graphics::TColor Value);
	
protected:
	Types::TRect FTabRect;
	virtual void __fastcall AlignControls(Controls::TControl* AControl, Types::TRect &ARect);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	DYNAMIC void __fastcall DragOver(System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	virtual void __fastcall SetParent(Controls::TWinControl* AParent);
	virtual void __fastcall Paint(void);
	virtual void __fastcall ReadState(Classes::TReader* Reader);
	virtual void __fastcall AdjustClientRect(Types::TRect &Rect);
	virtual void __fastcall SetName(const Classes::TComponentName Value);
	__property Graphics::TColor TxtColor = {read=FTxtColor, write=FTxtColor, nodefault};
	
public:
	__fastcall virtual TAdvOfficePage(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvOfficePage(void);
	void __fastcall ShowShortCutHint(void);
	void __fastcall HideShortCutHint(void);
	void __fastcall SelectFirstControl(void);
	_di_IFloatingPagerWindow __fastcall FloatingWindow(void);
	Forms::TForm* __fastcall GetFloatingWindow(void);
	void __fastcall SetFloating(int X = 0x0, int Y = 0x0)/* overload */;
	void __fastcall SetFloating(int X, int Y, int W, int H)/* overload */;
	__property int TabIndex = {read=FTabIndex, write=FTabIndex, nodefault};
	__property TAdvOfficePager* AdvOfficePager = {read=FAdvOfficePager, write=SetAdvOfficePager};
	__property System::TObject* PageObject = {read=FObject, write=FObject};
	
__published:
	__property System::UnicodeString Badge = {read=FBadge, write=SetBadge};
	__property Graphics::TColor BadgeColor = {read=FBadgeColor, write=SetBadgeColor, default=255};
	__property Graphics::TColor BadgeTextColor = {read=FBadgeTextColor, write=SetBadgeTextColor, default=16777215};
	__property Controls::TCaption Caption = {read=FCaption, write=SetCaption};
	__property DoubleBuffered;
	__property System::WideString WideCaption = {read=FWideCaption, write=SetWideCaption};
	__property Gdipicture::TGDIPPicture* DisabledPicture = {read=FIDisabledPicture, write=SetDisabledPicture};
	__property Imglist::TImageIndex ImageIndex = {read=FImageIndex, write=SetImageIndex, default=-1};
	__property TVistaBackground* PageAppearance = {read=FPageAppearance, write=SetPageAppearance};
	__property bool UsePageAppearance = {read=FUsePageAppearance, write=SetUsePageAppearance, default=0};
	__property Gdipicture::TGDIPPicture* Picture = {read=FIPicture, write=SetPicture};
	__property System::UnicodeString TabHint = {read=FTabHint, write=FTabHint};
	__property bool TabVisible = {read=FTabVisible, write=SetTabVisible, default=1};
	__property bool TabEnabled = {read=FTabEnabled, write=SetTabEnabled, default=1};
	__property bool ShowClose = {read=FShowClose, write=SetShowClose, default=1};
	__property ShowHint;
	__property Advhintinfo::TAdvHintInfo* OfficeHint = {read=FOfficeHint, write=SetOfficeHint};
	__property int PageIndex = {read=GetPageIndex, write=SetPageIndex, stored=false, nodefault};
	__property System::UnicodeString ShortCutHint = {read=FShortCutHintText, write=FShortCutHintText};
	__property Advglowbutton::TShortCutHintPos ShortCutHintPos = {read=FShortCutHintPos, write=FShortCutHintPos, default=1};
	__property TTabAppearance* TabAppearance = {read=FTabAppearance, write=SetTabAppearance};
	__property bool UseTabAppearance = {read=FUseTabAppearance, write=SetUseTabAppearance, default=0};
	__property bool ShowCheckBox = {read=FShowCheckBox, write=SetShowCheckBox, default=0};
	__property bool Checked = {read=FChecked, write=SetChecked, default=0};
	__property TTabProgress* Progress = {read=FProgress, write=SetProgress};
	__property bool Glow = {read=FGlow, write=SetGlow, default=0};
	__property Graphics::TColor GlowColor = {read=FGlowColor, write=SetGlowColor, default=255};
	__property bool Locked = {read=FLocked, write=SetLocked, default=0};
	__property Classes::TNotifyEvent OnHide = {read=FOnHide, write=FOnHide};
	__property Classes::TNotifyEvent OnShow = {read=FOnShow, write=FOnShow};
	__property OnClick;
	__property OnDblClick;
	__property PopupMenu;
	__property OnContextPopup;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnDragOver;
	__property OnDragDrop;
	__property OnEndDrag;
	__property OnStartDrag;
	__property OnExit;
	__property OnEnter;
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvOfficePage(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
};


typedef void __fastcall (__closure *TTabChangingEvent)(System::TObject* Sender, int FromPage, int ToPage, bool &AllowChange);

typedef void __fastcall (__closure *TOnClosePage)(System::TObject* Sender, int PageIndex, bool &Allow);

typedef void __fastcall (__closure *TOnClosedPage)(System::TObject* Sender, int PageIndex);

typedef void __fastcall (__closure *TOnPageListClick)(System::TObject* Sender, int X, int Y);

typedef void __fastcall (__closure *TTabMovedEvent)(System::TObject* Sender, int FromPos, int ToPos);

typedef void __fastcall (__closure *TDrawTabEvent)(System::TObject* Sender, int TabIndex, const Types::TRect &TabRect);

typedef void __fastcall (__closure *TTabClickEvent)(System::TObject* Sender, int PageIndex);

typedef void __fastcall (__closure *TClosedListClick)(System::TObject* Sender, int X, int Y);

typedef void __fastcall (__closure *TTabEvent)(System::TObject* Sender, int PageIndex);

typedef void __fastcall (__closure *TPageEvent)(System::TObject* Sender, TAdvOfficePage* APage);

typedef void __fastcall (__closure *TTabUndockingEvent)(System::TObject* Sender, TAdvOfficePage* APage, bool &Allow);

class PASCALIMPLEMENTATION TAdvOfficePager : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	typedef DynamicArray<Types::TPoint> _TAdvOfficePager__1;
	
	
private:
	Advstyleif::TColorTones FTones;
	Advglowbutton::TAdvGlowButton* FCloseButtonGlobal;
	bool FIsWinXP;
	TCustomAdvOfficePagerStyler* FInternalOfficePagerStyler;
	TCustomAdvOfficePagerStyler* FOfficePagerStyler;
	TCustomAdvOfficePagerStyler* FCurrentOfficePagerStyler;
	int FPageMargin;
	int FOffSetY;
	int FOffSetX;
	TDbgList* FAdvPages;
	bool FPropertiesLoaded;
	bool FShowNonSelectedTabs;
	TPagerTabSettings* FTabSettings;
	TPagerTabScroller* FTabScroller;
	int FActivePageIndex;
	int FHotPageIndex;
	int FDownPageIndex;
	int FOldHotPageIndex;
	int FHintPageIndex;
	Imglist::TCustomImageList* FImages;
	Imglist::TCustomImageList* FDisabledImages;
	TAdvOfficePage* FNewPage;
	TAdvOfficePage* FUndockPage;
	bool FShowTabHint;
	Classes::TNotifyEvent FOnChange;
	TTabChangingEvent FOnChanging;
	int FOldCapRightIndent;
	Advhintinfo::TAdvHintInfo* FOfficeHint;
	Comctrls::TTabPosition FTabPosition;
	Advgdip::TAntiAlias FAntiAlias;
	TPageButtonSettings* FButtonSettings;
	Menus::TPopupMenu* FPageListMenu;
	TOnClosePage FOnClosePage;
	TOnClosedPage FOnClosedPage;
	TOnPageListClick FOnPageListClick;
	bool FRotateTabLeftRight;
	bool FCloseOnTab;
	Advglowbutton::TAdvGlowButton* FPageListButton;
	Advglowbutton::TAdvGlowButton* FScrollPrevButton;
	Advglowbutton::TAdvGlowButton* FScrollNextButton;
	Advglowbutton::TAdvGlowButton* FScrollFirstButton;
	Advglowbutton::TAdvGlowButton* FScrollLastButton;
	int FTabOffSet;
	bool FUseMaxSpace;
	bool FFreeOnClose;
	TDbgList* FShortCutHintWinList;
	Classes::TWndMethod FFormWndProc;
	bool FTabShortCutHintShowing;
	System::UnicodeString FTabShortCutChars;
	bool FShowShortCutHints;
	bool FTabReorder;
	TTabMovedEvent FOnTabMoved;
	bool FIsClosing;
	TDrawTabEvent FOnDrawTab;
	Graphics::TBitmap* FButtonsBkg;
	TCloseOnTabPos FCloseOnTabPosition;
	bool FDesignTime;
	bool FBufferedPages;
	TTabClickEvent FOnTabClick;
	TTabClickEvent FOnTabDblClick;
	TTabClickEvent FOnTabRightClick;
	TTabClickEvent FOnTabCheckBoxClick;
	bool FGlow;
	bool FFormScaled;
	bool FTransparent;
	bool FShowCloseOnNonSelectedTabs;
	Classes::TNotifyEvent FOnLastClick;
	Classes::TNotifyEvent FOnFirstClick;
	Classes::TNotifyEvent FOnPrevClick;
	Classes::TNotifyEvent FOnNextClick;
	TTabUndockingEvent FOnTabUndocking;
	Advglowbutton::TAdvGlowButton* FClosedListButton;
	Menus::TPopupMenu* FClosedListMenu;
	Menus::TPopupMenu* FInternalClosedListMenu;
	TClosedListClick FOnClosedListClick;
	Classes::TStringList* FClosedPageList;
	TTabEvent FOnTabMouseLeave;
	TTabEvent FOnTabMouseEnter;
	Extctrls::TTimer* FBrGlowTimer;
	int FStepHover;
	int FTimeInc;
	TArrowWindow* FArrow;
	int FFixedTabs;
	bool FIsAeroVista;
	Graphics::TColor FTabReorderIndicatorColor;
	bool FInsertButtonHot;
	bool FInsertButtonDown;
	int FOldMouseX;
	int FOldMouseY;
	bool FDraging;
	bool FAllowTabUndock;
	TDbgList* FDockList;
	TAdvOfficePager* FClonedOfPager;
	TDbgList* FFloatingPages;
	TAdvOfficePage* FDragingPage;
	Forms::TForm* FFloatingWindow;
	Forms::TBorderIcons FFloatingBorderIcons;
	Forms::TFormBorderStyle FFloatingBorderStyle;
	int FDragTabX;
	int FDragTabY;
	TPageEvent FOnTabDock;
	TPageEvent FOnTabUnDock;
	TPageEvent FOnInsertPage;
	bool FTabRoundEdges;
	bool FShadow;
	bool FShow3D;
	bool FItones;
	TVistaBackground* FPageAppearance;
	TTabAppearance* FTabAppearance;
	Advglowbutton::TGlowButtonAppearance* FGlowButtonAppearance;
	TFloatingPagerWindowClass FFloatingPagerWindowClass;
	bool FMultiLine;
	_TAdvOfficePager__1 FTabRows;
	int FMultiLineRowCount;
	int FTabRowSize;
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Message);
	HIDESBASE MESSAGE void __fastcall WMNCHitTest(Messages::TWMNCHitTest &Msg);
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Message);
	MESSAGE void __fastcall WMGetDlgCode(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMKillFocus(Messages::TWMSetFocus &Message);
	HIDESBASE MESSAGE void __fastcall WMLButtonDown(Messages::TWMMouse &Message);
	HIDESBASE MESSAGE void __fastcall WMLButtonDblClk(Messages::TWMMouse &Message);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Message);
	HIDESBASE MESSAGE void __fastcall CMVisibleChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMShowingChanged(Messages::TMessage &Message);
	MESSAGE void __fastcall CMControlChange(Controls::TCMControlChange &Message);
	HIDESBASE MESSAGE void __fastcall CMControlListChange(Controls::TCMControlListChange &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall CMDesignHitTest(Messages::TWMMouse &Msg);
	HIDESBASE MESSAGE void __fastcall CMHintShow(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMDialogChar(Messages::TWMKey &Message);
	HIDESBASE MESSAGE void __fastcall CMDialogKey(Messages::TWMKey &Message);
	HIDESBASE MESSAGE void __fastcall CMFocusChanged(Controls::TCMFocusChanged &Message);
	HIDESBASE MESSAGE void __fastcall CMDockClient(Controls::TCMDockClient &Message);
	MESSAGE void __fastcall CMDockNotification(Controls::TCMDockNotification &Message);
	HIDESBASE MESSAGE void __fastcall CMUnDockClient(Controls::TCMUnDockClient &Message);
	void __fastcall OnTabSettingsChanged(System::TObject* Sender);
	void __fastcall OnButtonSettingChanged(System::TObject* Sender);
	void __fastcall OnCloseButtonClick(System::TObject* Sender);
	void __fastcall OnCloseButtonMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall OnPageListButtonClick(System::TObject* Sender);
	void __fastcall OnPageListMenuClick(System::TObject* Sender);
	void __fastcall OnScrollPrevButtonClick(System::TObject* Sender);
	void __fastcall OnScrollNextButtonClick(System::TObject* Sender);
	void __fastcall OnScrollFirstButtonClick(System::TObject* Sender);
	void __fastcall OnScrollLastButtonClick(System::TObject* Sender);
	void __fastcall SubclassProc(Messages::TMessage &Msg);
	void __fastcall OnEnterTab(int PageIndex);
	void __fastcall OnExitTab(int PageIndex);
	void __fastcall SetPageValidCache(bool Value);
	void __fastcall SetPagePosition(TAdvOfficePage* AdvPage);
	void __fastcall SetAllPagesPosition(void);
	void __fastcall SetOfficePagerStyler(const TCustomAdvOfficePagerStyler* Value);
	int __fastcall GetAdvOfficePageCount(void);
	TAdvOfficePage* __fastcall GetAdvPages(int index);
	Menus::TPopupMenu* __fastcall GetPopupMenuEx(void);
	void __fastcall SetPopupMenuEx(const Menus::TPopupMenu* Value);
	void __fastcall SetShowNonSelectedTabs(const bool Value);
	TAdvOfficePage* __fastcall GetActivePage(void);
	int __fastcall GetActivePageIndex(void);
	void __fastcall SetActivePage(const TAdvOfficePage* Value);
	void __fastcall SetActivePageIndex(const int Value);
	void __fastcall SetTabSettings(const TPagerTabSettings* Value);
	void __fastcall SetImages(const Imglist::TCustomImageList* Value);
	void __fastcall SetDisabledImages(const Imglist::TCustomImageList* Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	void __fastcall SetOfficeHint(const Advhintinfo::TAdvHintInfo* Value);
	void __fastcall SetTabPosition(const Comctrls::TTabPosition Value);
	void __fastcall SetAntiAlias(const Advgdip::TAntiAlias Value);
	void __fastcall SetButtonSettings(const TPageButtonSettings* Value);
	void __fastcall SetPageListMenu(const Menus::TPopupMenu* Value);
	void __fastcall SetCloseOnTab(const bool Value);
	void __fastcall SetRotateTabLeftRight(const bool Value);
	void __fastcall SetPageMargin(const int Value);
	bool __fastcall GetNextPictureChanged(void);
	bool __fastcall GetPrevPictureChanged(void);
	void __fastcall SetNextPictureChanged(const bool Value);
	void __fastcall SetPrevPictureChanged(const bool Value);
	void __fastcall ReadNextPicChanged(Classes::TReader* Reader);
	void __fastcall ReadPrevPicChanged(Classes::TReader* Reader);
	void __fastcall WriteNextPicChanged(Classes::TWriter* Writer);
	void __fastcall WritePrevPicChanged(Classes::TWriter* Writer);
	void __fastcall SetCloseOnTabPosition(const TCloseOnTabPos Value);
	Controls::TControl* __fastcall GetDockClientFromMousePos(const Types::TPoint &MousePos);
	void __fastcall SetShowCloseOnNonSelectedTabs(const bool Value);
	void __fastcall SetTransparent(const bool Value);
	void __fastcall OnCloseListMenuClick(System::TObject* Sender);
	void __fastcall ClosedListButtonClick(System::TObject* Sender);
	void __fastcall CreateClosedListButton(void);
	void __fastcall UpdateClosedListButton(void);
	void __fastcall OnGlowTimerTime(System::TObject* Sender);
	void __fastcall CreateGlowTimer(void);
	bool __fastcall IsAnyTabGlowing(void);
	void __fastcall CreateDropArrow(void);
	void __fastcall SetFixedTabs(int Value);
	void __fastcall SetTabReorderIndicatorColor(const Graphics::TColor Value);
	void __fastcall SetAllowTabUndock(const bool Value);
	int __fastcall GetAdvOfficePageVisibleCount(void);
	void __fastcall SetShadow(const bool Value);
	void __fastcall SetShow3D(const bool Value);
	void __fastcall SetTabRoundEdges(const bool Value);
	void __fastcall SetGlowButtonColorTones(Advglowbutton::TAdvGlowButton* AdvGlowButton);
	int __fastcall GetFloatingPageCount(void);
	TAdvOfficePage* __fastcall GetFloatingPages(int index);
	System::UnicodeString __fastcall GetSettings(void);
	void __fastcall SetSettings(const System::UnicodeString Value);
	void __fastcall SetMultiLine(const bool Value);
	
protected:
	virtual void __fastcall AlignControls(Controls::TControl* AControl, Types::TRect &ARect);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetParent(Controls::TWinControl* AParent);
	virtual void __fastcall WndProc(Messages::TMessage &Msg);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall DragOver(System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	DYNAMIC void __fastcall DragCanceled(void);
	DYNAMIC void __fastcall DoAddDockClient(Controls::TControl* Client, const Types::TRect &ARect);
	DYNAMIC void __fastcall DockOver(Controls::TDragDockObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	DYNAMIC void __fastcall DoRemoveDockClient(Controls::TControl* Client);
	TAdvOfficePage* __fastcall GetPageFromDockClient(Controls::TControl* Client);
	virtual void __fastcall AdjustClientRect(Types::TRect &Rect);
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	void __fastcall DrawAllTabs(void);
	void __fastcall DrawTabScrollButtons(void);
	void __fastcall DrawInsertButton(void)/* overload */;
	void __fastcall DrawInsertButton(Graphics::TCanvas* Canvas, const Types::TRect &R)/* overload */;
	virtual void __fastcall Paint(void);
	DYNAMIC void __fastcall SetChildOrder(Classes::TComponent* Child, int Order);
	void __fastcall SetAdvPageBounds(TAdvOfficePage* AdvPage, int &ALeft, int &ATop, int &AWidth, int &AHeight);
	void __fastcall UpdateGlowTimer(void);
	bool __fastcall IsTabShowing(int TabIndex);
	bool __fastcall IsGlass(void);
	bool __fastcall IsOnGlass(void);
	void __fastcall BeginMove(Classes::TShiftState Shift, int X, int Y, TAdvOfficePage* Page);
	void __fastcall Move(Classes::TShiftState Shift, int X, int Y);
	void __fastcall EndMove(void);
	TAdvOfficePager* __fastcall CreateClonedPager(Controls::TWinControl* PrtWindow);
	void __fastcall SetFloatingPage(TAdvOfficePage* Page, int X = 0x0, int Y = 0x0)/* overload */;
	void __fastcall SetFloatingPage(TAdvOfficePage* Page, int X, int Y, int W, int H)/* overload */;
	void __fastcall AssignPager(TAdvOfficePager* Source);
	void __fastcall UpdateMe(int PropID);
	void __fastcall ChangeActivePage(int PageIndex);
	void __fastcall UpdateTabScroller(void);
	void __fastcall ScrollLeftBtnClick(void);
	void __fastcall ScrollRightBtnClick(void);
	void __fastcall ScrollLastBtnClick(void);
	void __fastcall ScrollFirstBtnClick(void);
	void __fastcall ShowShortCutHintOfAllPages(void);
	void __fastcall HideShortCutHintOfAllPages(void);
	Advglowbutton::TShortCutHintWindow* __fastcall CreateShortCutHintWin(void);
	void __fastcall DestroyShortCutHintWin(Advglowbutton::TShortCutHintWindow* ShortCutWin);
	void __fastcall InitializeAndUpdateButtons(void);
	bool __fastcall AnyButtonVisible(void);
	bool __fastcall CanShowTab(int PageIndex);
	int __fastcall GetVisibleTabCount(void);
	tagSIZE __fastcall GetTextSize(int PageIndex);
	tagSIZE __fastcall GetTabImageSize(int PageIndex);
	void __fastcall GetCloseBtnImageAndTextRect(int PageIndex, Types::TRect &CloseBtnR, Types::TRect &TextR, Types::TPoint &ImgP);
	void __fastcall InvalidateTab(int PageIndex);
	Types::TRect __fastcall GetAdvPageRect(void);
	Types::TRect __fastcall GetButtonsRect(void);
	Types::TRect __fastcall GetTabsArea(void);
	Types::TRect __fastcall GetTabsRect(void);
	Types::TRect __fastcall GetTabRect(int StartIndex, int PageIndex, bool ConsiderTabScroller)/* overload */;
	int __fastcall PTOnTab(int X, int Y);
	bool __fastcall PTOnCheckBox(int PageIndex, int X, int Y);
	Types::TRect __fastcall GetCheckBoxRect(int PageIndex);
	Types::TRect __fastcall GetCloseButtonRect(int PageIndex);
	Types::TRect __fastcall GetPageListRect(void);
	Types::TRect __fastcall GetClosedListButtonRect(void);
	Types::TRect __fastcall GetTabScrollerRect(void);
	Types::TRect __fastcall GetTabScrollerFirstRect(void);
	Types::TRect __fastcall GetTabScrollerLastRect(void);
	Types::TRect __fastcall GetTabScrollerLeftRect(void);
	Types::TRect __fastcall GetTabScrollerRightRect(void);
	bool __fastcall PtOnTabScrollLeftBtn(int X, int Y);
	bool __fastcall PtOnTabScrollRightBtn(int X, int Y);
	bool __fastcall PtOnInsertButton(int X, int Y);
	Types::TRect __fastcall GetInsertButtonRect(void);
	void __fastcall InvalidateInsertButton(void);
	virtual void __fastcall DoInsertButtonClick(void);
	int __fastcall GetLastDisplayTab(void);
	int __fastcall IsActivePageNeighbour(int PageIndex);
	int __fastcall GetLeftRoundingOffset(void);
	int __fastcall GetRightRoundingOffset(void);
	void __fastcall GlassChanged(void);
	bool __fastcall CanGlow(void);
	bool __fastcall CanShow3D(void);
	bool __fastcall CanShowShadow(void);
	bool __fastcall CanShowCloseButton(void);
	bool __fastcall UseOldDrawing(void);
	void __fastcall UpdatePageAppearanceOfPages(TVistaBackground* PageAppearance);
	void __fastcall UpdateTabAppearanceOfPages(TTabAppearance* TabAppearance);
	__property bool NextPictureChanged = {read=GetNextPictureChanged, write=SetNextPictureChanged, nodefault};
	__property bool PrevPictureChanged = {read=GetPrevPictureChanged, write=SetPrevPictureChanged, nodefault};
	void __fastcall UpdateMultiLineTabs(void);
	void __fastcall UpdateMultiLineActiveTab(void);
	__property bool TabRoundEdges = {read=FTabRoundEdges, write=SetTabRoundEdges, default=1};
	__property bool Show3D = {read=FShow3D, write=SetShow3D, default=1};
	__property bool Shadow = {read=FShadow, write=SetShadow, default=1};
	
public:
	__fastcall virtual TAdvOfficePager(Classes::TComponent* AOwner);
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	__fastcall virtual ~TAdvOfficePager(void);
	DYNAMIC void __fastcall GetChildren(Classes::TGetChildProc Proc, Classes::TComponent* Root);
	void __fastcall Init(void);
	void __fastcall InitOrder(void);
	bool __fastcall CloseActivePage(void);
	Types::TRect __fastcall GetTabRect(int PageIndex)/* overload */;
	Types::TRect __fastcall GetTabRect(TAdvOfficePage* Page)/* overload */;
	void __fastcall DrawTab(int PageIndex);
	void __fastcall DrawTabContent(int PageIndex, const Types::TRect &R);
	DYNAMIC void __fastcall DragDrop(System::TObject* Source, int X, int Y);
	int __fastcall GetVersionNr(void);
	void __fastcall OpenAllClosedPages(void);
	bool __fastcall OpenClosedPage(TAdvOfficePage* APage);
	void __fastcall ClearAdvPages(void);
	void __fastcall SaveToFile(System::UnicodeString FileName);
	void __fastcall LoadFromFile(System::UnicodeString FileName);
	void __fastcall SetColorTones(const Advstyleif::TColorTones &ATones);
	void __fastcall ResetPages(void);
	int __fastcall AddAdvPage(TAdvOfficePage* AdvPage)/* overload */;
	int __fastcall AddAdvPage(Controls::TCaption PageCaption)/* overload */;
	void __fastcall RemoveAdvPage(TAdvOfficePage* AdvPage);
	void __fastcall MoveAdvPage(int CurIndex, int NewIndex);
	TAdvOfficePage* __fastcall FindNextPage(TAdvOfficePage* CurPage, bool GoForward, bool CheckTabVisible);
	void __fastcall SelectNextPage(bool GoForward);
	int __fastcall IndexOfPage(TAdvOfficePage* AdvPage);
	int __fastcall IndexOfTabAt(int X, int Y);
	TAdvOfficePage* __fastcall PageByName(System::UnicodeString Value);
	TAdvOfficePage* __fastcall PageByCaption(System::UnicodeString Value);
	TAdvOfficePage* __fastcall PageAtTabIndex(int Value);
	__property Canvas;
	__property System::UnicodeString Settings = {read=GetSettings, write=SetSettings};
	__property int ActivePageIndex = {read=GetActivePageIndex, write=SetActivePageIndex, nodefault};
	__property bool BufferedPages = {read=FBufferedPages, write=FBufferedPages, nodefault};
	__property int AdvPageCount = {read=GetAdvOfficePageCount, nodefault};
	__property int AdvPageVisibleCount = {read=GetAdvOfficePageVisibleCount, nodefault};
	__property TAdvOfficePage* AdvPages[int index] = {read=GetAdvPages};
	__property TAdvOfficePage* FloatingPages[int index] = {read=GetFloatingPages};
	__property int FloatingPageCount = {read=GetFloatingPageCount, nodefault};
	__property TFloatingPagerWindowClass FloatingPagerWindowClass = {read=FFloatingPagerWindowClass, write=FFloatingPagerWindowClass};
	__property TPagerTabScroller* TabScroller = {read=FTabScroller};
	__property int HotPageIndex = {read=FHotPageIndex, nodefault};
	__property int RowCount = {read=FMultiLineRowCount, nodefault};
	__property Advglowbutton::TAdvGlowButton* ScrollNextButton = {read=FScrollNextButton};
	__property Advglowbutton::TAdvGlowButton* ScrollPrevButton = {read=FScrollPrevButton};
	__property Advglowbutton::TAdvGlowButton* ScrollFirstButton = {read=FScrollFirstButton};
	__property Advglowbutton::TAdvGlowButton* ScrollLastButton = {read=FScrollLastButton};
	
__published:
	__property TCustomAdvOfficePagerStyler* AdvOfficePagerStyler = {read=FOfficePagerStyler, write=SetOfficePagerStyler};
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property TAdvOfficePage* ActivePage = {read=GetActivePage, write=SetActivePage};
	__property Advgdip::TAntiAlias AntiAlias = {read=FAntiAlias, write=SetAntiAlias, default=1};
	__property bool AllowTabUndock = {read=FAllowTabUndock, write=SetAllowTabUndock, default=0};
	__property TPageButtonSettings* ButtonSettings = {read=FButtonSettings, write=SetButtonSettings};
	__property Constraints;
	__property bool CloseOnTab = {read=FCloseOnTab, write=SetCloseOnTab, default=0};
	__property TCloseOnTabPos CloseOnTabPosition = {read=FCloseOnTabPosition, write=SetCloseOnTabPosition, default=0};
	__property Menus::TPopupMenu* ClosedListMenu = {read=FClosedListMenu, write=FClosedListMenu};
	__property Imglist::TCustomImageList* DisabledImages = {read=FDisabledImages, write=SetDisabledImages};
	__property DoubleBuffered;
	__property bool FreeOnClose = {read=FFreeOnClose, write=FFreeOnClose, default=0};
	__property int FixedTabs = {read=FFixedTabs, write=SetFixedTabs, default=0};
	__property Forms::TBorderIcons FloatingBorderIcons = {read=FFloatingBorderIcons, write=FFloatingBorderIcons, default=7};
	__property Forms::TFormBorderStyle FloatingBorderStyle = {read=FFloatingBorderStyle, write=FFloatingBorderStyle, default=2};
	__property DockSite = {default=0};
	__property bool Glow = {read=FGlow, write=FGlow, default=1};
	__property Imglist::TCustomImageList* Images = {read=FImages, write=SetImages};
	__property bool MultiLine = {read=FMultiLine, write=SetMultiLine, default=0};
	__property Advhintinfo::TAdvHintInfo* OfficeHint = {read=FOfficeHint, write=SetOfficeHint};
	__property int PageMargin = {read=FPageMargin, write=SetPageMargin, default=1};
	__property Menus::TPopupMenu* PageListMenu = {read=FPageListMenu, write=SetPageListMenu};
	__property Menus::TPopupMenu* PopupMenu = {read=GetPopupMenuEx, write=SetPopupMenuEx};
	__property bool RotateTabLeftRight = {read=FRotateTabLeftRight, write=SetRotateTabLeftRight, default=1};
	__property bool ShowCloseOnNonSelectedTabs = {read=FShowCloseOnNonSelectedTabs, write=SetShowCloseOnNonSelectedTabs, default=0};
	__property bool ShowNonSelectedTabs = {read=FShowNonSelectedTabs, write=SetShowNonSelectedTabs, default=0};
	__property bool ShowTabHint = {read=FShowTabHint, write=FShowTabHint, default=0};
	__property ShowHint;
	__property Comctrls::TTabPosition TabPosition = {read=FTabPosition, write=SetTabPosition, default=0};
	__property TPagerTabSettings* TabSettings = {read=FTabSettings, write=SetTabSettings};
	__property bool TabReorder = {read=FTabReorder, write=FTabReorder, default=0};
	__property Graphics::TColor TabReorderIndicatorColor = {read=FTabReorderIndicatorColor, write=SetTabReorderIndicatorColor, default=16711680};
	__property OnGesture;
	__property Touch;
	__property bool Transparent = {read=FTransparent, write=SetTransparent, default=0};
	__property bool ShowShortCutHints = {read=FShowShortCutHints, write=FShowShortCutHints, nodefault};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion, stored=false};
	__property Visible = {default=1};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property TTabChangingEvent OnChanging = {read=FOnChanging, write=FOnChanging};
	__property TOnClosePage OnClosePage = {read=FOnClosePage, write=FOnClosePage};
	__property TOnClosedPage OnClosedPage = {read=FOnClosedPage, write=FOnClosedPage};
	__property TClosedListClick OnClosedListClick = {read=FOnClosedListClick, write=FOnClosedListClick};
	__property TDrawTabEvent OnDrawTab = {read=FOnDrawTab, write=FOnDrawTab};
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDrag;
	__property OnDockDrop;
	__property OnDockOver;
	__property OnEndDock;
	__property OnStartDock;
	__property TPageEvent OnInsertPage = {read=FOnInsertPage, write=FOnInsertPage};
	__property OnUnDock;
	__property OnEnter;
	__property OnExit;
	__property TOnPageListClick OnPageListClick = {read=FOnPageListClick, write=FOnPageListClick};
	__property TTabMovedEvent OnTabMoved = {read=FOnTabMoved, write=FOnTabMoved};
	__property TTabClickEvent OnTabClick = {read=FOnTabClick, write=FOnTabClick};
	__property TTabClickEvent OnTabCheckBoxClick = {read=FOnTabCheckBoxClick, write=FOnTabCheckBoxClick};
	__property TTabClickEvent OnTabDblClick = {read=FOnTabDblClick, write=FOnTabDblClick};
	__property TTabClickEvent OnTabRightClick = {read=FOnTabRightClick, write=FOnTabRightClick};
	__property OnKeyDown;
	__property OnKeyUp;
	__property OnKeyPress;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnResize;
	__property OnStartDrag;
	__property TabOrder = {default=-1};
	__property TabStop = {default=0};
	__property Classes::TNotifyEvent OnPrevClick = {read=FOnPrevClick, write=FOnPrevClick};
	__property Classes::TNotifyEvent OnNextClick = {read=FOnNextClick, write=FOnNextClick};
	__property Classes::TNotifyEvent OnFirstClick = {read=FOnFirstClick, write=FOnFirstClick};
	__property Classes::TNotifyEvent OnLastClick = {read=FOnLastClick, write=FOnLastClick};
	__property TTabEvent OnTabMouseEnter = {read=FOnTabMouseEnter, write=FOnTabMouseEnter};
	__property TTabEvent OnTabMouseLeave = {read=FOnTabMouseLeave, write=FOnTabMouseLeave};
	__property TPageEvent OnTabDock = {read=FOnTabDock, write=FOnTabDock};
	__property TPageEvent OnTabUnDock = {read=FOnTabUnDock, write=FOnTabUnDock};
	__property TTabUndockingEvent OnTabUnDocking = {read=FOnTabUndocking, write=FOnTabUndocking};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvOfficePager(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
private:
	void *__ITMSTones;	/* Advstyleif::ITMSTones */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Advstyleif::_di_ITMSTones()
	{
		Advstyleif::_di_ITMSTones intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITMSTones*(void) { return (ITMSTones*)&__ITMSTones; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt GLOWSPEED = 0x32;
static const ShortInt GLOWSTEP = 0x14;
static const ShortInt IMG_SPACE = 0x2;
static const ShortInt DropDownSectWidth = 0xd;
static const ShortInt DEFAULT_TABHEIGHT = 0x1a;
static const ShortInt ADVPAGE_OFFSET = 0x1;
static const ShortInt SCROLLER_SIZE = 0x20;
static const ShortInt PAGEBUTTON_SIZE = 0x12;
static const ShortInt MAJ_VER = 0x3;
static const ShortInt MIN_VER = 0x5;
static const ShortInt REL_VER = 0x0;
static const ShortInt BLD_VER = 0x0;
extern PACKAGE void __fastcall DrawVistaTab(Graphics::TCanvas* Canvas, const Types::TRect &r, Graphics::TColor CFU, Graphics::TColor CTU, Graphics::TColor CFB, Graphics::TColor CTB, Graphics::TColor PC, Advglowbutton::TGDIPGradient GradientU, Advglowbutton::TGDIPGradient GradientB, bool Enabled, TAdvTabShape Shape, bool Focus, TTabRounding Rounding, bool RotateLeftRight, Comctrls::TTabPosition Direction, TTabProgress* Progress);

}	/* namespace Advofficepager */
using namespace Advofficepager;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvofficepagerHPP
