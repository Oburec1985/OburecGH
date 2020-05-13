// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Asgdatetimepicker.pas' rev: 21.00

#ifndef AsgdatetimepickerHPP
#define AsgdatetimepickerHPP

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

//-- user supplied -----------------------------------------------------------

namespace Asgdatetimepicker
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TAsgDateTimePicker;
class PASCALIMPLEMENTATION TAsgDateTimePicker : public Comctrls::TDateTimePicker
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
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall WndProc(Messages::TMessage &Message);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	bool __fastcall DoVisualStyles(void);
	virtual void __fastcall SetBorderStyle(const Forms::TBorderStyle Value);
	__property Forms::TBorderStyle BorderStyle = {read=FBorderStyle, write=SetBorderStyle, nodefault};
	__property int ButtonWidth = {read=FButtonWidth, write=SetButtonWidth, default=19};
	__property Graphics::TColor FocusBorderColor = {read=FFocusBorderColor, write=FFocusBorderColor, default=536870911};
	__property bool FocusBorder = {read=FFocusBorder, write=FFocusBorder, default=0};
	__property bool DisabledBorder = {read=FDisabledBorder, write=FDisabledBorder, default=1};
	__property bool MetroStyleShowing = {read=GetMetroStyleShowing, nodefault};
	
public:
	__fastcall virtual TAsgDateTimePicker(Classes::TComponent* AOwner);
	__fastcall virtual ~TAsgDateTimePicker(void);
	int __fastcall GetVersionNr(void);
	__property Graphics::TColor BorderColor = {read=FBorderColor, write=SetBorderColor, default=536870911};
	__property Graphics::TColor ButtonColor = {read=FButtonColor, write=FButtonColor, default=536870911};
	__property Graphics::TColor ButtonColorHot = {read=FButtonColorHot, write=FButtonColorHot, default=536870911};
	__property Graphics::TColor ButtonColorDown = {read=FButtonColorDown, write=FButtonColorDown, default=536870911};
	__property Graphics::TColor ButtonTextColor = {read=FButtonTextColor, write=FButtonTextColor, default=536870911};
	__property Graphics::TColor ButtonTextColorHot = {read=FButtonTextColorHot, write=FButtonTextColorHot, default=536870911};
	__property Graphics::TColor ButtonTextColorDown = {read=FButtonTextColorDown, write=FButtonTextColorDown, default=536870911};
	__property Graphics::TColor ButtonBorderColor = {read=FButtonBorderColor, write=FButtonBorderColor, default=536870911};
	__property bool MetroStyle = {read=FMetroStyle, write=SetMetroStyle, nodefault};
	
__published:
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAsgDateTimePicker(HWND ParentWindow) : Comctrls::TDateTimePicker(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x0;
static const ShortInt REL_VER = 0x0;
static const ShortInt BLD_VER = 0x0;
static const ShortInt DROPDOWNBTN_WIDTH = 0x15;

}	/* namespace Asgdatetimepicker */
using namespace Asgdatetimepicker;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AsgdatetimepickerHPP
