// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advdatetimepicker.pas' rev: 21.00

#ifndef AdvdatetimepickerHPP
#define AdvdatetimepickerHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Commctrl.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advdatetimepicker
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TAdvDateTimeKind { dkDate, dkTime, dkDateTime };
#pragma option pop

#pragma option push -b-
enum TLabelPosition { lpLeftTop, lpLeftCenter, lpLeftBottom, lpTopLeft, lpBottomLeft, lpLeftTopLeft, lpLeftCenterLeft, lpLeftBottomLeft, lpTopCenter, lpBottomCenter, lpRightTop, lpRightCenter, lpRighBottom, lpTopRight, lpBottomRight };
#pragma option pop

class DELPHICLASS TCustomDateTimePicker;
class PASCALIMPLEMENTATION TCustomDateTimePicker : public Comctrls::TDateTimePicker
{
	typedef Comctrls::TDateTimePicker inherited;
	
private:
	Forms::TFormBorderStyle FBorderStyle;
	Graphics::TColor FBorderColor;
	bool FIsThemed;
	Graphics::TColor FButtonColorDown;
	Graphics::TColor FButtonBorderColor;
	Graphics::TColor FButtonTextColor;
	Graphics::TColor FButtonTextColorHot;
	Graphics::TColor FButtonColor;
	Graphics::TColor FButtonColorHot;
	Graphics::TColor FButtonTextColorDown;
	int FButtonWidth;
	bool FButtonHover;
	bool FMouseInControl;
	bool FIsWinXP;
	bool FMetroStyle;
	Graphics::TColor FFocusBorderColor;
	bool FDisabledBorder;
	bool FHasFocus;
	bool FFocusBorder;
	bool FAutoTab;
	bool FAutoTabToNext;
	System::Word Fh;
	System::Word Fm;
	System::Word Fs;
	System::Word Fms;
	bool FIsTimePicker;
	bool FGridTabhandling;
	MESSAGE void __fastcall WMGetDlgCode(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Message);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Message);
	HIDESBASE MESSAGE void __fastcall WMNCPaint(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Message);
	HIDESBASE MESSAGE void __fastcall CMCtl3DChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMEnter(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall CMExit(Messages::TWMNoParams &Message);
	void __fastcall NCPaintProc(void);
	void __fastcall SetBorderColor(const Graphics::TColor Value);
	void __fastcall SetButtonWidth(const int Value);
	void __fastcall SetMetroStyle(const bool Value);
	bool __fastcall Is3DBorderControl(void);
	bool __fastcall Is3DBorderButton(void);
	void __fastcall DrawButtonBorder(HDC DC);
	void __fastcall DrawControlBorder(HDC DC);
	void __fastcall DrawBorders(void);
	bool __fastcall GetMetroStyleShowing(void);
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall WndProc(Messages::TMessage &Message);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	virtual void __fastcall ShiftFocus(void);
	virtual void __fastcall SetAutoTab(const bool Value);
	virtual void __fastcall SetAutoTabToNext(const bool Value);
	bool __fastcall DoVisualStyles(void);
	virtual bool __fastcall IsInnerCtrl(void);
	virtual void __fastcall SetBorderStyle(const Forms::TBorderStyle Value);
	__property Forms::TBorderStyle BorderStyle = {read=FBorderStyle, write=SetBorderStyle, nodefault};
	__property Graphics::TColor BorderColor = {read=FBorderColor, write=SetBorderColor, default=0};
	__property int ButtonWidth = {read=FButtonWidth, write=SetButtonWidth, default=19};
	__property Graphics::TColor ButtonColor = {read=FButtonColor, write=FButtonColor, default=536870911};
	__property Graphics::TColor ButtonColorHot = {read=FButtonColorHot, write=FButtonColorHot, default=536870911};
	__property Graphics::TColor ButtonColorDown = {read=FButtonColorDown, write=FButtonColorDown, default=536870911};
	__property Graphics::TColor ButtonTextColor = {read=FButtonTextColor, write=FButtonTextColor, default=536870911};
	__property Graphics::TColor ButtonTextColorHot = {read=FButtonTextColorHot, write=FButtonTextColorHot, default=536870911};
	__property Graphics::TColor ButtonTextColorDown = {read=FButtonTextColorDown, write=FButtonTextColorDown, default=536870911};
	__property Graphics::TColor ButtonBorderColor = {read=FButtonBorderColor, write=FButtonBorderColor, default=536870911};
	__property Graphics::TColor FocusBorderColor = {read=FFocusBorderColor, write=FFocusBorderColor, default=536870911};
	__property bool FocusBorder = {read=FFocusBorder, write=FFocusBorder, default=0};
	__property bool DisabledBorder = {read=FDisabledBorder, write=FDisabledBorder, default=1};
	__property bool MetroStyleShowing = {read=GetMetroStyleShowing, nodefault};
	void __fastcall TabToNext(void);
	__property bool IsTimePicker = {read=FIsTimePicker, write=FIsTimePicker, nodefault};
	__property bool GridTabHandling = {read=FGridTabhandling, write=FGridTabhandling, nodefault};
	
public:
	__fastcall virtual TCustomDateTimePicker(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomDateTimePicker(void);
	__property bool MetroStyle = {read=FMetroStyle, write=SetMetroStyle, nodefault};
	
__published:
	__property bool AutoTab = {read=FAutoTab, write=SetAutoTab, default=0};
	__property bool AutoTabToNext = {read=FAutoTabToNext, write=SetAutoTabToNext, default=1};
public:
	/* TWinControl.CreateParented */ inline __fastcall TCustomDateTimePicker(HWND ParentWindow) : Comctrls::TDateTimePicker(ParentWindow) { }
	
};


class DELPHICLASS TAdvDateTimePicker;
class PASCALIMPLEMENTATION TAdvDateTimePicker : public TCustomDateTimePicker
{
	typedef TCustomDateTimePicker inherited;
	
private:
	TAdvDateTimeKind FKind;
	Classes::TNotifyEvent FOnTimeChange;
	Extctrls::TTimer* FFocusTimer;
	Types::TPoint Fpt;
	System::UnicodeString FTimeFormat;
	System::Word Fy;
	System::Word Fm;
	System::Word Fd;
	Stdctrls::TLabel* FLabel;
	Graphics::TFont* FLabelFont;
	TLabelPosition FLabelPosition;
	int FLabelMargin;
	bool FLabelTransparent;
	bool FFocusLabel;
	bool FLabelAlwaysEnabled;
	Classes::TNotifyEvent FOnLabelClick;
	Classes::TNotifyEvent FOnLabelDblClick;
	bool FParentFnt;
	bool FIgnoreTimePickerCheck;
	bool FFirstRun;
	bool FNullDateIsToday;
	void __fastcall OnTimePickerChanged(System::TObject* Sender);
	void __fastcall OnTimePickerClicked(System::TObject* Sender);
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Message);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Message);
	HIDESBASE void __fastcall SetKind(const TAdvDateTimeKind Value);
	HIDESBASE MESSAGE void __fastcall CMColorChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CNNotify(Commctrl::TWMNotifyDT &Message);
	HIDESBASE MESSAGE void __fastcall CMParentFontChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMSetFocus(Messages::TWMSetFocus &Msg);
	HIDESBASE MESSAGE void __fastcall WMKillFocus(Messages::TWMKillFocus &Msg);
	HIDESBASE MESSAGE void __fastcall CMShowingChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMVisibleChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Message);
	void __fastcall OnFocusTimerTime(System::TObject* Sender);
	System::TTime __fastcall GetTimeEx(void);
	void __fastcall SetTimeEx(const System::TTime Value);
	System::TDateTime __fastcall GetDateTimeEx(void);
	System::UnicodeString __fastcall GetFormatEx(void);
	void __fastcall SetFormatEx(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetTimeFormat(void);
	void __fastcall SetTimeFormat(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	void __fastcall LabelFontChange(System::TObject* Sender);
	void __fastcall SetLabelFont(const Graphics::TFont* Value);
	void __fastcall SetLabelCaption(const System::UnicodeString value);
	System::UnicodeString __fastcall GetLabelCaption(void);
	void __fastcall SetLabelPosition(const TLabelPosition value);
	void __fastcall SetLabelMargin(const int value);
	void __fastcall SetLabelTransparent(const bool value);
	void __fastcall UpdateLabel(void);
	void __fastcall UpdateLabelPos(void);
	void __fastcall SetLabelAlwaysEnabled(const bool Value);
	System::TDate __fastcall GetDateEx(void);
	void __fastcall SetDateEx(const System::TDate Value);
	bool __fastcall GetTabStopEx(void);
	void __fastcall SetTabStopEx(const bool Value);
	
protected:
	TCustomDateTimePicker* FTimePicker;
	virtual void __fastcall ShiftFocus(void);
	virtual void __fastcall SetAutoTab(const bool Value);
	virtual void __fastcall SetAutoTabToNext(const bool Value);
	void __fastcall CreateTimePicker(void);
	void __fastcall UpdateTimePicker(void);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall SetBorderStyle(const Forms::TBorderStyle Value);
	virtual void __fastcall CreateWnd(void);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	virtual void __fastcall SetParent(Controls::TWinControl* AParent);
	virtual void __fastcall TimePickerChanged(void);
	virtual void __fastcall TimePickerClicked(void);
	virtual void __fastcall SetDateTimeEx(const System::TDateTime Value);
	virtual void __fastcall TimePickerKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall TimePickerKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	Stdctrls::TLabel* __fastcall CreateLabel(void);
	void __fastcall LabelClick(System::TObject* Sender);
	void __fastcall LabelDblClick(System::TObject* Sender);
	virtual bool __fastcall MsgSetDateTime(const _SYSTEMTIME &Value);
	DYNAMIC void __fastcall Change(void);
	virtual void __fastcall WndProc(Messages::TMessage &Message);
	virtual bool __fastcall IsInnerCtrl(void);
	
public:
	__fastcall virtual TAdvDateTimePicker(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvDateTimePicker(void);
	virtual void __fastcall SetBounds(int ALeft, int ATop, int AWidth, int AHeight);
	__property BorderColor = {default=0};
	int __fastcall GetVersionNr(void);
	__property Stdctrls::TLabel* PickerLabel = {read=FLabel};
	__property Classes::TNotifyEvent OnTimeChange = {read=FOnTimeChange, write=FOnTimeChange};
	__property ButtonColor = {default=536870911};
	__property ButtonColorHot = {default=536870911};
	__property ButtonColorDown = {default=536870911};
	__property ButtonTextColor = {default=536870911};
	__property ButtonTextColorHot = {default=536870911};
	__property ButtonTextColorDown = {default=536870911};
	__property ButtonBorderColor = {default=536870911};
	__property bool NullDateIsToday = {read=FNullDateIsToday, write=FNullDateIsToday, nodefault};
	
__published:
	__property BorderStyle;
	__property Ctl3D;
	__property System::TDate Date = {read=GetDateEx, write=SetDateEx};
	__property System::TDateTime DateTime = {read=GetDateTimeEx, write=SetDateTimeEx};
	__property System::UnicodeString Format = {read=GetFormatEx, write=SetFormatEx};
	__property System::UnicodeString TimeFormat = {read=GetTimeFormat, write=SetTimeFormat};
	__property TAdvDateTimeKind Kind = {read=FKind, write=SetKind, nodefault};
	__property bool TabStop = {read=GetTabStopEx, write=SetTabStopEx, default=0};
	__property System::TTime Time = {read=GetTimeEx, write=SetTimeEx};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
	__property bool FocusLabel = {read=FFocusLabel, write=FFocusLabel, default=0};
	__property System::UnicodeString LabelCaption = {read=GetLabelCaption, write=SetLabelCaption};
	__property TLabelPosition LabelPosition = {read=FLabelPosition, write=SetLabelPosition, default=0};
	__property int LabelMargin = {read=FLabelMargin, write=SetLabelMargin, default=4};
	__property bool LabelTransparent = {read=FLabelTransparent, write=SetLabelTransparent, default=0};
	__property bool LabelAlwaysEnabled = {read=FLabelAlwaysEnabled, write=SetLabelAlwaysEnabled, default=0};
	__property Graphics::TFont* LabelFont = {read=FLabelFont, write=SetLabelFont};
	__property Classes::TNotifyEvent OnLabelClick = {read=FOnLabelClick, write=FOnLabelClick};
	__property Classes::TNotifyEvent OnLabelDblClick = {read=FOnLabelDblClick, write=FOnLabelDblClick};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvDateTimePicker(HWND ParentWindow) : TCustomDateTimePicker(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x2;
static const ShortInt REL_VER = 0x2;
static const ShortInt BLD_VER = 0x0;
static const ShortInt DROPDOWNBTN_WIDTH = 0x15;

}	/* namespace Advdatetimepicker */
using namespace Advdatetimepicker;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvdatetimepickerHPP
