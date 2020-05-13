// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advstyleif.pas' rev: 21.00

#ifndef AdvstyleifHPP
#define AdvstyleifHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Registry.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advstyleif
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TMetroStyle { msLight, msDark };
#pragma option pop

#pragma option push -b-
enum TTMSStyle { tsOffice2003Blue, tsOffice2003Silver, tsOffice2003Olive, tsOffice2003Classic, tsOffice2007Luna, tsOffice2007Obsidian, tsWindowsXP, tsWhidbey, tsCustom, tsOffice2007Silver, tsWindowsVista, tsWindows7, tsTerminal, tsOffice2010Blue, tsOffice2010Silver, tsOffice2010Black, tsWindows8, tsOffice2013White, tsOffice2013LightGray, tsOffice2013Gray, tsWindows10, tsOffice2016White, tsOffice2016Gray, tsOffice2016Black };
#pragma option pop

struct TColorTone
{
	
public:
	Graphics::TColor BrushColor;
	Graphics::TColor BorderColor;
	Graphics::TColor TextColor;
};


struct TColorTones
{
	
public:
	TColorTone Background;
	TColorTone Foreground;
	TColorTone Selected;
	TColorTone Hover;
	TColorTone Disabled;
};


#pragma option push -b-
enum XPColorScheme { xpNone, xpBlue, xpGreen, xpGray };
#pragma option pop

#pragma option push -b-
enum TOfficeVersion { ov2003, ov2007, ov2010, ov2013 };
#pragma option pop

#pragma option push -b-
enum TOfficeTheme { ot2003Blue, ot2003Silver, ot2003Olive, ot2003Classic, ot2007Blue, ot2007Silver, ot2007Black, ot2010Blue, ot2010Silver, ot2010Black, ot2013White, ot2013Silver, ot2013Gray, ot2016White, ot2016Gray, ot2016Black, otUnknown };
#pragma option pop

__interface ITMSTones;
typedef System::DelphiInterface<ITMSTones> _di_ITMSTones;
__interface  INTERFACE_UUID("{1F492643-6699-4F25-8B34-3233FA735036}") ITMSTones  : public System::IInterface 
{
	
public:
	virtual void __fastcall SetColorTones(const TColorTones &ATones) = 0 ;
};

__interface ITMSStyle;
typedef System::DelphiInterface<ITMSStyle> _di_ITMSStyle;
__interface  INTERFACE_UUID("{11AC2DDC-C087-4298-AB6E-EA1B5017511B}") ITMSStyle  : public System::IInterface 
{
	
public:
	virtual void __fastcall SetComponentStyle(TTMSStyle AStyle) = 0 ;
};

__interface ITMSStyleEx;
typedef System::DelphiInterface<ITMSStyleEx> _di_ITMSStyleEx;
__interface  INTERFACE_UUID("{037BA87F-7CBD-4FDD-854E-2B3F0BCC06AE}") ITMSStyleEx  : public ITMSStyle 
{
	
public:
	HIDESBASE virtual void __fastcall SetComponentStyle(TTMSStyle AStyle) = 0 ;
	virtual void __fastcall SetComponentStyleAndAppColor(TTMSStyle AStyle, Graphics::TColor AppColor) = 0 ;
};

__interface ITMSMetro;
typedef System::DelphiInterface<ITMSMetro> _di_ITMSMetro;
__interface  INTERFACE_UUID("{A7E8D091-0327-446D-83D6-7069760B3320}") ITMSMetro  : public System::IInterface 
{
	
public:
	virtual bool __fastcall IsMetro(void) = 0 ;
};

class DELPHICLASS THandleList;
class PASCALIMPLEMENTATION THandleList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	int operator[](int index) { return Items[index]; }
	
private:
	void __fastcall SetInteger(int Index, int Value);
	int __fastcall GetInteger(int Index);
	
public:
	__fastcall THandleList(void);
	void __fastcall DeleteValue(int Value);
	bool __fastcall HasValue(int Value);
	__property int Items[int index] = {read=GetInteger, write=SetInteger/*, default*/};
	HIDESBASE void __fastcall Add(int Value);
	HIDESBASE void __fastcall Insert(int Index, int Value);
	HIDESBASE void __fastcall Delete(int Index);
public:
	/* TList.Destroy */ inline __fastcall virtual ~THandleList(void) { }
	
};


class DELPHICLASS TRegMonitorThread;
class PASCALIMPLEMENTATION TRegMonitorThread : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
private:
	Registry::TRegistry* FReg;
	unsigned FEvent;
	System::UnicodeString FKey;
	HKEY FRootKey;
	bool FWatchSub;
	int FFilter;
	unsigned FWnd;
	THandleList* FWinList;
	void __fastcall InitThread(void);
	void __fastcall SetFilter(const int Value);
	int __fastcall GetFilter(void);
	
public:
	__fastcall TRegMonitorThread(void);
	__fastcall virtual ~TRegMonitorThread(void);
	void __fastcall Stop(void);
	__property System::UnicodeString Key = {read=FKey, write=FKey};
	__property HKEY RootKey = {read=FRootKey, write=FRootKey, nodefault};
	__property bool WatchSub = {read=FWatchSub, write=FWatchSub, nodefault};
	__property int Filter = {read=GetFilter, write=SetFilter, nodefault};
	__property unsigned Wnd = {read=FWnd, write=FWnd, nodefault};
	__property THandleList* WinList = {read=FWinList};
	
protected:
	virtual void __fastcall Execute(void);
};


class DELPHICLASS TThemeNotifierWindow;
class PASCALIMPLEMENTATION TThemeNotifierWindow : public Controls::TWinControl
{
	typedef Controls::TWinControl inherited;
	
private:
	Classes::TNotifyEvent FOnOfficeThemeChange;
	
protected:
	virtual void __fastcall WndProc(Messages::TMessage &Msg);
	
__published:
	__property Classes::TNotifyEvent OnOfficeThemeChange = {read=FOnOfficeThemeChange, write=FOnOfficeThemeChange};
public:
	/* TWinControl.Create */ inline __fastcall virtual TThemeNotifierWindow(Classes::TComponent* AOwner) : Controls::TWinControl(AOwner) { }
	/* TWinControl.CreateParented */ inline __fastcall TThemeNotifierWindow(HWND ParentWindow) : Controls::TWinControl(ParentWindow) { }
	/* TWinControl.Destroy */ inline __fastcall virtual ~TThemeNotifierWindow(void) { }
	
};


class DELPHICLASS TThemeNotifier;
class PASCALIMPLEMENTATION TThemeNotifier : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TRegMonitorThread* RegMonitorThread;
	TThemeNotifierWindow* FNotifier;
	Classes::TNotifyEvent FOnOfficeThemeChange;
	
protected:
	void __fastcall OfficeThemeChanged(System::TObject* Sender);
	
public:
	__fastcall virtual TThemeNotifier(Classes::TComponent* AOwner);
	__fastcall virtual ~TThemeNotifier(void);
	void __fastcall RegisterWindow(unsigned Hwnd);
	void __fastcall UnRegisterWindow(unsigned Hwnd);
	
__published:
	__property Classes::TNotifyEvent OnOfficeThemeChange = {read=FOnOfficeThemeChange, write=FOnOfficeThemeChange};
};


//-- var, const, procedure ---------------------------------------------------
static const Word WM_OFFICETHEMECHANGED = 0xbb1;
extern "C" int __stdcall RegNotifyChangeKeyValue(HKEY hKey, unsigned bWatchSubtree, unsigned dwNotifyFilter, unsigned hEvent, unsigned fAsynchronus);
extern PACKAGE TThemeNotifier* ThemeNotifierInstance;
extern PACKAGE bool TMSDISABLEWITHCOLORSATURATION;
extern PACKAGE bool __fastcall IsThemedApp(void);
extern PACKAGE bool __fastcall IsVista(void);
extern PACKAGE TOfficeVersion __fastcall GetOfficeVersion(void);
extern PACKAGE bool __fastcall IsWinXP(void);
extern PACKAGE TOfficeTheme __fastcall GetOfficeTheme(void);
extern PACKAGE TThemeNotifier* __fastcall ThemeNotifier(Controls::TWinControl* AParent);
extern PACKAGE Graphics::TColor __fastcall ChangeColor(Graphics::TColor Color, int Perc);
extern PACKAGE TColorTones __fastcall CreateMetroTones(bool Light, Graphics::TColor Color, Graphics::TColor TextColor);
extern PACKAGE TColorTones __fastcall DefaultMetroTones(void);
extern PACKAGE TColorTones __fastcall ClearTones(void);
extern PACKAGE bool __fastcall IsClearTones(const TColorTones &ATones);
extern PACKAGE System::UnicodeString __fastcall GetMetroFont(void);
extern PACKAGE Graphics::TColor __fastcall ChangeBrightness(Graphics::TColor Color, int Perc);

}	/* namespace Advstyleif */
using namespace Advstyleif;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvstyleifHPP
