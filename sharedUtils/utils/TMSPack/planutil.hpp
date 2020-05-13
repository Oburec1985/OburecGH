// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Planutil.pas' rev: 21.00

#ifndef PlanutilHPP
#define PlanutilHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Planhtml.hpp>	// Pascal unit
#include <Strutils.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Planutil
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TArrowDirection { adUp, adDown, adRight, adLeft };
#pragma option pop

#pragma option push -b-
enum TVAlignment { vtaCenter, vtaTop, vtaBottom };
#pragma option pop

class DELPHICLASS TDateTimeObject;
class PASCALIMPLEMENTATION TDateTimeObject : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::TDateTime FDT;
	__property System::TDateTime DT = {read=FDT, write=FDT};
public:
	/* TObject.Create */ inline __fastcall TDateTimeObject(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TDateTimeObject(void) { }
	
};


class DELPHICLASS TDateTimeList;
class PASCALIMPLEMENTATION TDateTimeList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	System::TDateTime operator[](int index) { return Items[index]; }
	
private:
	System::TDateTime __fastcall GetDT(int index);
	void __fastcall SetDT(int index, const System::TDateTime Value);
	
public:
	__property System::TDateTime Items[int index] = {read=GetDT, write=SetDT/*, default*/};
	HIDESBASE void __fastcall Add(System::TDateTime Value);
	HIDESBASE void __fastcall Insert(int Index, System::TDateTime Value);
	HIDESBASE void __fastcall Delete(int Index);
	virtual void __fastcall Clear(void);
	__fastcall virtual ~TDateTimeList(void);
public:
	/* TObject.Create */ inline __fastcall TDateTimeList(void) : Classes::TList() { }
	
};


#pragma option push -b-
enum TGaugeOrientation { goHorizontal, goVertical };
#pragma option pop

struct TGaugeSettings
{
	
public:
	Graphics::TColor Level0Color;
	Graphics::TColor Level0ColorTo;
	Graphics::TColor Level1Color;
	Graphics::TColor Level1ColorTo;
	Graphics::TColor Level2Color;
	Graphics::TColor Level2ColorTo;
	Graphics::TColor Level3Color;
	Graphics::TColor Level3ColorTo;
	int Level1Perc;
	int Level2Perc;
	Graphics::TColor BorderColor;
	bool ShowBorder;
	bool Stacked;
	bool ShowPercentage;
	Graphics::TFont* Font;
	bool CompletionSmooth;
	bool ShowGradient;
	int Steps;
	int Position;
	Graphics::TColor BackgroundColor;
	TGaugeOrientation Orientation;
	System::UnicodeString CompletionFormat;
};


class DELPHICLASS TRecurrencyDialogLanguage;
class PASCALIMPLEMENTATION TRecurrencyDialogLanguage : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FCaption;
	System::UnicodeString FExceptions;
	System::UnicodeString FSettings;
	System::UnicodeString FRange;
	System::UnicodeString FRecurrencyPattern;
	System::UnicodeString FPatternDetails;
	System::UnicodeString FRangeFor;
	System::UnicodeString FRangeOccurences;
	System::UnicodeString FRangeInfinite;
	System::UnicodeString FRangeUntil;
	System::UnicodeString FFreqWeekly;
	System::UnicodeString FFreqDaily;
	System::UnicodeString FFreqHourly;
	System::UnicodeString FFreqYearly;
	System::UnicodeString FFreqNone;
	System::UnicodeString FFreqMonthly;
	System::UnicodeString FButtonRemove;
	System::UnicodeString FButtonAdd;
	System::UnicodeString FButtonClear;
	System::UnicodeString FButtonCancel;
	System::UnicodeString FButtonOK;
	System::UnicodeString FEveryDay;
	System::UnicodeString FEveryWeekDay;
	System::UnicodeString FDayFriday;
	System::UnicodeString FDayThursday;
	System::UnicodeString FDayMonday;
	System::UnicodeString FDayTuesday;
	System::UnicodeString FDaySaturday;
	System::UnicodeString FDaySunday;
	System::UnicodeString FDayWednesday;
	System::UnicodeString FMonthJanuary;
	System::UnicodeString FMonthFebruary;
	System::UnicodeString FMonthMarch;
	System::UnicodeString FMonthApril;
	System::UnicodeString FMonthMay;
	System::UnicodeString FMonthJune;
	System::UnicodeString FMonthJuly;
	System::UnicodeString FMonthAugust;
	System::UnicodeString FMonthSeptember;
	System::UnicodeString FMonthOctober;
	System::UnicodeString FMonthNovember;
	System::UnicodeString FMonthDecember;
	System::UnicodeString FEveryMonthDay;
	System::UnicodeString FEveryYearDay;
	System::UnicodeString FEvery;
	System::UnicodeString FEveryThird;
	System::UnicodeString FEveryFirst;
	System::UnicodeString FEveryFourth;
	System::UnicodeString FEverySecond;
	System::UnicodeString FDayWeekend;
	System::UnicodeString FDayWeekday;
	System::UnicodeString FInterval;
	
public:
	__fastcall TRecurrencyDialogLanguage(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString Caption = {read=FCaption, write=FCaption};
	__property System::UnicodeString Settings = {read=FSettings, write=FSettings};
	__property System::UnicodeString Exceptions = {read=FExceptions, write=FExceptions};
	__property System::UnicodeString RecurrencyPattern = {read=FRecurrencyPattern, write=FRecurrencyPattern};
	__property System::UnicodeString PatternDetails = {read=FPatternDetails, write=FPatternDetails};
	__property System::UnicodeString Range = {read=FRange, write=FRange};
	__property System::UnicodeString RangeInfinite = {read=FRangeInfinite, write=FRangeInfinite};
	__property System::UnicodeString RangeUntil = {read=FRangeUntil, write=FRangeUntil};
	__property System::UnicodeString RangeFor = {read=FRangeFor, write=FRangeFor};
	__property System::UnicodeString RangeOccurences = {read=FRangeOccurences, write=FRangeOccurences};
	__property System::UnicodeString FreqNone = {read=FFreqNone, write=FFreqNone};
	__property System::UnicodeString FreqHourly = {read=FFreqHourly, write=FFreqHourly};
	__property System::UnicodeString FreqDaily = {read=FFreqDaily, write=FFreqDaily};
	__property System::UnicodeString FreqWeekly = {read=FFreqWeekly, write=FFreqWeekly};
	__property System::UnicodeString FreqMonthly = {read=FFreqMonthly, write=FFreqMonthly};
	__property System::UnicodeString FreqYearly = {read=FFreqYearly, write=FFreqYearly};
	__property System::UnicodeString ButtonAdd = {read=FButtonAdd, write=FButtonAdd};
	__property System::UnicodeString ButtonClear = {read=FButtonClear, write=FButtonClear};
	__property System::UnicodeString ButtonRemove = {read=FButtonRemove, write=FButtonRemove};
	__property System::UnicodeString ButtonOK = {read=FButtonOK, write=FButtonOK};
	__property System::UnicodeString ButtonCancel = {read=FButtonCancel, write=FButtonCancel};
	__property System::UnicodeString Every = {read=FEvery, write=FEvery};
	__property System::UnicodeString EveryDay = {read=FEveryDay, write=FEveryDay};
	__property System::UnicodeString EveryWeekDay = {read=FEveryWeekDay, write=FEveryWeekDay};
	__property System::UnicodeString EveryMonthDay = {read=FEveryMonthDay, write=FEveryMonthDay};
	__property System::UnicodeString EveryYearDay = {read=FEveryYearDay, write=FEveryYearDay};
	__property System::UnicodeString EveryFirst = {read=FEveryFirst, write=FEveryFirst};
	__property System::UnicodeString EverySecond = {read=FEverySecond, write=FEverySecond};
	__property System::UnicodeString EveryThird = {read=FEveryThird, write=FEveryThird};
	__property System::UnicodeString EveryFourth = {read=FEveryFourth, write=FEveryFourth};
	__property System::UnicodeString Interval = {read=FInterval, write=FInterval};
	__property System::UnicodeString DayMonday = {read=FDayMonday, write=FDayMonday};
	__property System::UnicodeString DayTuesday = {read=FDayTuesday, write=FDayTuesday};
	__property System::UnicodeString DayWednesday = {read=FDayWednesday, write=FDayWednesday};
	__property System::UnicodeString DayThursday = {read=FDayThursday, write=FDayThursday};
	__property System::UnicodeString DayFriday = {read=FDayFriday, write=FDayFriday};
	__property System::UnicodeString DaySaturday = {read=FDaySaturday, write=FDaySaturday};
	__property System::UnicodeString DaySunday = {read=FDaySunday, write=FDaySunday};
	__property System::UnicodeString DayWeekday = {read=FDayWeekday, write=FDayWeekday};
	__property System::UnicodeString DayWeekend = {read=FDayWeekend, write=FDayWeekend};
	__property System::UnicodeString MonthJanuary = {read=FMonthJanuary, write=FMonthJanuary};
	__property System::UnicodeString MonthFebruary = {read=FMonthFebruary, write=FMonthFebruary};
	__property System::UnicodeString MonthMarch = {read=FMonthMarch, write=FMonthMarch};
	__property System::UnicodeString MonthApril = {read=FMonthApril, write=FMonthApril};
	__property System::UnicodeString MonthMay = {read=FMonthMay, write=FMonthMay};
	__property System::UnicodeString MonthJune = {read=FMonthJune, write=FMonthJune};
	__property System::UnicodeString MonthJuly = {read=FMonthJuly, write=FMonthJuly};
	__property System::UnicodeString MonthAugust = {read=FMonthAugust, write=FMonthAugust};
	__property System::UnicodeString MonthSeptember = {read=FMonthSeptember, write=FMonthSeptember};
	__property System::UnicodeString MonthOctober = {read=FMonthOctober, write=FMonthOctober};
	__property System::UnicodeString MonthNovember = {read=FMonthNovember, write=FMonthNovember};
	__property System::UnicodeString MonthDecember = {read=FMonthDecember, write=FMonthDecember};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TRecurrencyDialogLanguage(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall FixControlStyles(Controls::TControl* ctrl);
extern PACKAGE System::UnicodeString __fastcall ColorToHtml(const Graphics::TColor Value);
extern PACKAGE bool __fastcall DynaLink_UpdateLayeredWindow(unsigned hwnd, unsigned hdcDst, Types::PPoint pptDst, Types::PPoint size, unsigned hdcSrc, Types::PPoint pptSrc, unsigned crKey, _BLENDFUNCTION &pblend, unsigned dwFlags);
extern PACKAGE bool __fastcall DynaLink_SetLayeredWindowAttributes(unsigned HWND, unsigned crKey, System::Byte bAlpha, unsigned dwFlags);
extern PACKAGE double __fastcall CanvasToHTMLFactor(Graphics::TCanvas* ScreenCanvas, Graphics::TCanvas* Canvas);
extern PACKAGE int __fastcall PrinterDrawString(Graphics::TCanvas* Canvas, System::UnicodeString Value, Types::TRect &Rect, unsigned Format);
extern PACKAGE System::TDateTime __fastcall EndOfMonth(System::TDateTime dt);
extern PACKAGE System::Word __fastcall NextMonth(System::Word mo);
extern PACKAGE int __fastcall Limit(int Value, int vmin, int vmax);
extern PACKAGE void __fastcall DrawGradient(Graphics::TCanvas* Canvas, Graphics::TColor FromColor, Graphics::TColor ToColor, int Steps, const Types::TRect &R, bool Direction);
extern PACKAGE System::Word __fastcall DaysInMonth(System::Word mo, System::Word ye);
extern PACKAGE System::UnicodeString __fastcall HTMLStrip(System::UnicodeString s);
extern PACKAGE unsigned __fastcall AlignToFlag(Classes::TAlignment alignment);
extern PACKAGE unsigned __fastcall VAlignToFlag(TVAlignment VAlignment);
extern PACKAGE unsigned __fastcall WordWrapToFlag(System::UnicodeString s, bool ww);
extern PACKAGE void __fastcall RectLine(Graphics::TCanvas* canvas, const Types::TRect &r, Graphics::TColor Color, int width);
extern PACKAGE void __fastcall RectLineEx(Graphics::TCanvas* Canvas, const Types::TRect &R, Graphics::TColor Color, int Width);
extern PACKAGE void __fastcall RectLineExEx(Graphics::TCanvas* Canvas, const Types::TRect &R, Graphics::TColor Color, int Width);
extern PACKAGE void __fastcall RectLineExExEx(Graphics::TCanvas* Canvas, const Types::TRect &R, Graphics::TColor Color, int Width);
extern PACKAGE void __fastcall RectHorz(Graphics::TCanvas* canvas, const Types::TRect &r, Graphics::TColor Color, Graphics::TColor pencolor);
extern PACKAGE void __fastcall RectHorzEx(Graphics::TCanvas* Canvas, const Types::TRect &r, Graphics::TColor Color, Graphics::TColor BKColor, Graphics::TColor PenColor1, Graphics::TColor PenColor2, int PenWidth, Graphics::TBrushStyle BrushStyle);
extern PACKAGE void __fastcall RectVert(Graphics::TCanvas* canvas, const Types::TRect &r, Graphics::TColor Color, Graphics::TColor pencolor);
extern PACKAGE void __fastcall RectVertEx(Graphics::TCanvas* Canvas, const Types::TRect &r, Graphics::TColor Color, Graphics::TColor BKColor, Graphics::TColor PenColor, int PenWidth, Graphics::TBrushStyle BrushStyle);
extern PACKAGE System::UnicodeString __fastcall LFToCLF(System::UnicodeString s);
extern PACKAGE void __fastcall DrawArrow(Graphics::TCanvas* Canvas, Graphics::TColor Color, int X, int Y, TArrowDirection ADir);
extern PACKAGE bool __fastcall MatchStr(System::UnicodeString s1, System::UnicodeString s2, bool DoCase);
extern PACKAGE void __fastcall DrawBitmapTransp(const Types::TRect &DstRect, Graphics::TCanvas* Canvas, Graphics::TBitmap* Bitmap, Graphics::TColor BKColor, const Types::TRect &SrcRect);
extern PACKAGE void __fastcall DrawBumpVert(Graphics::TCanvas* Canvas, const Types::TRect &r, Graphics::TColor Color);
extern PACKAGE void __fastcall DrawBumpHorz(Graphics::TCanvas* Canvas, const Types::TRect &r, Graphics::TColor Color);
extern PACKAGE Graphics::TColor __fastcall BlendColor(Graphics::TColor Col1, Graphics::TColor Col2, int BlendFactor);
extern PACKAGE void __fastcall DrawGauge(Graphics::TCanvas* Canvas, const Types::TRect &R, int Position, const TGaugeSettings &Settings);
extern PACKAGE void __fastcall BitmapStretch(Graphics::TBitmap* bmp, Graphics::TCanvas* Canvas, int x, int y, int width);
extern PACKAGE void __fastcall BitmapStretchHeight(Graphics::TBitmap* bmp, Graphics::TCanvas* canvas, int x, int y, int height, int width);

}	/* namespace Planutil */
using namespace Planutil;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// PlanutilHPP
