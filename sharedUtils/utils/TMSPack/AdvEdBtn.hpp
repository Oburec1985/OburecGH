// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advedbtn.pas' rev: 21.00

#ifndef AdvedbtnHPP
#define AdvedbtnHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Advedit.hpp>	// Pascal unit
#include <Aebxpvs.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advedbtn
{
//-- type declarations -------------------------------------------------------
typedef Buttons::TNumGlyphs TNumGlyphs;

#pragma option push -b-
enum TButtonStyle { bsButton, bsDropDown };
#pragma option pop

class DELPHICLASS TAdvSpeedButton;
class PASCALIMPLEMENTATION TAdvSpeedButton : public Buttons::TSpeedButton
{
	typedef Buttons::TSpeedButton inherited;
	
private:
	bool FEtched;
	bool FFocused;
	bool FHot;
	bool FUp;
	bool FIsWinXP;
	void __fastcall SetEtched(const bool Value);
	void __fastcall SetFocused(const bool Value);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Message);
	void __fastcall PaintDropDown(void);
	void __fastcall PaintButton(void);
	
protected:
	virtual void __fastcall Paint(void);
	bool __fastcall DoVisualStyles(void);
	
public:
	void __fastcall SetUp(void);
	__fastcall virtual TAdvSpeedButton(Classes::TComponent* AOwner);
	
__published:
	__property bool Etched = {read=FEtched, write=SetEtched, nodefault};
	__property bool Focused = {read=FFocused, write=SetFocused, nodefault};
public:
	/* TSpeedButton.Destroy */ inline __fastcall virtual ~TAdvSpeedButton(void) { }
	
};


class DELPHICLASS TEditButton;
class PASCALIMPLEMENTATION TEditButton : public Controls::TWinControl
{
	typedef Controls::TWinControl inherited;
	
private:
	TAdvSpeedButton* FButton;
	Controls::TWinControl* FFocusControl;
	Classes::TNotifyEvent FOnClick;
	int FBWidth;
	Graphics::TColor FButtonColorDown;
	Graphics::TColor FButtonBorderColor;
	Graphics::TColor FButtonColor;
	Graphics::TColor FButtonColorHot;
	Graphics::TColor FButtonTextColor;
	Graphics::TColor FButtonTextColorHot;
	Graphics::TColor FButtonTextColorDown;
	TAdvSpeedButton* __fastcall CreateButton(void);
	Graphics::TBitmap* __fastcall GetGlyph(void);
	void __fastcall SetGlyph(Graphics::TBitmap* Value);
	Buttons::TNumGlyphs __fastcall GetNumGlyphs(void);
	void __fastcall SetNumGlyphs(Buttons::TNumGlyphs Value);
	void __fastcall SetCaption(System::UnicodeString value);
	System::UnicodeString __fastcall GetCaption(void);
	void __fastcall BtnMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall AdjustWinSize(int &W, int &H);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Message);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall BtnClick(System::TObject* Sender);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	__property int BWidth = {read=FBWidth, write=FBWidth, nodefault};
	void __fastcall Setup(void);
	
public:
	__fastcall virtual TEditButton(Classes::TComponent* AOwner);
	virtual void __fastcall SetBounds(int ALeft, int ATop, int AWidth, int AHeight);
	
__published:
	__property Align = {default=0};
	__property Ctl3D;
	__property Graphics::TBitmap* Glyph = {read=GetGlyph, write=SetGlyph};
	__property Graphics::TColor ButtonColor = {read=FButtonColor, write=FButtonColor, default=536870911};
	__property Graphics::TColor ButtonColorHot = {read=FButtonColorHot, write=FButtonColorHot, default=536870911};
	__property Graphics::TColor ButtonColorDown = {read=FButtonColorDown, write=FButtonColorDown, default=536870911};
	__property Graphics::TColor ButtonTextColor = {read=FButtonTextColor, write=FButtonTextColor, default=536870911};
	__property Graphics::TColor ButtonTextColorHot = {read=FButtonTextColorHot, write=FButtonTextColorHot, default=536870911};
	__property Graphics::TColor ButtonTextColorDown = {read=FButtonTextColorDown, write=FButtonTextColorDown, default=536870911};
	__property Graphics::TColor ButtonBorderColor = {read=FButtonBorderColor, write=FButtonBorderColor, default=536870911};
	__property System::UnicodeString ButtonCaption = {read=GetCaption, write=SetCaption};
	__property Buttons::TNumGlyphs NumGlyphs = {read=GetNumGlyphs, write=SetNumGlyphs, default=1};
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property Enabled = {default=1};
	__property Controls::TWinControl* FocusControl = {read=FFocusControl, write=FFocusControl};
	__property ParentCtl3D = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=0};
	__property Visible = {default=1};
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnStartDrag;
	__property Classes::TNotifyEvent OnClick = {read=FOnClick, write=FOnClick};
public:
	/* TWinControl.CreateParented */ inline __fastcall TEditButton(HWND ParentWindow) : Controls::TWinControl(ParentWindow) { }
	/* TWinControl.Destroy */ inline __fastcall virtual ~TEditButton(void) { }
	
};


class DELPHICLASS TAdvEditBtn;
class PASCALIMPLEMENTATION TAdvEditBtn : public Advedit::TAdvEdit
{
	typedef Advedit::TAdvEdit inherited;
	
private:
	int FUnitSize;
	TEditButton* FButton;
	bool FEditorEnabled;
	Classes::TNotifyEvent FOnClickBtn;
	bool FFlat;
	bool FEtched;
	bool FMouseInControl;
	System::UnicodeString FButtonHint;
	TButtonStyle FButtonStyle;
	int __fastcall GetMinHeight(void);
	void __fastcall SetGlyph(Graphics::TBitmap* value);
	Graphics::TBitmap* __fastcall GetGlyph(void);
	void __fastcall SetCaption(System::UnicodeString value);
	System::UnicodeString __fastcall GetCaption(void);
	HIDESBASE void __fastcall SetFlat(const bool Value);
	void __fastcall SetEtched(const bool Value);
	HIDESBASE void __fastcall DrawControlBorder(HDC DC);
	void __fastcall DrawButtonBorder(void);
	void __fastcall DrawBorders(void);
	bool __fastcall Is3DBorderControl(void);
	HIDESBASE bool __fastcall Is3DBorderButton(void);
	HIDESBASE MESSAGE void __fastcall CMEnter(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall CMExit(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall WMPaste(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMCut(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMCopy(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Msg);
	HIDESBASE MESSAGE void __fastcall WMNCPaint(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Msg);
	HIDESBASE MESSAGE void __fastcall WMChar(Messages::TWMKey &Msg);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Msg);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	int __fastcall GetButtonWidth(void);
	void __fastcall SetButtonWidth(const int Value);
	void __fastcall ResizeControl(void);
	void __fastcall SetButtonHint(const System::UnicodeString Value);
	void __fastcall SetButtonStyle(const TButtonStyle Value);
	bool __fastcall GetReadOnlyEx(void);
	void __fastcall SetReadOnlyEx(const bool Value);
	
protected:
	virtual int __fastcall GetVersionNr(void);
	virtual void __fastcall BtnClick(System::TObject* Sender);
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall Loaded(void);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall DoEnter(void);
	
public:
	void __fastcall SetEditRect(void);
	__fastcall virtual TAdvEditBtn(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvEditBtn(void);
	__property TEditButton* Button = {read=FButton};
	HIDESBASE void __fastcall PaintTo(HDC DC, int X, int Y)/* overload */;
	HIDESBASE void __fastcall PaintTo(Graphics::TCanvas* Canvas, int X, int Y)/* overload */;
	
__published:
	__property AutoSelect = {default=1};
	__property AutoSize = {default=1};
	__property BorderStyle = {default=1};
	__property TButtonStyle ButtonStyle = {read=FButtonStyle, write=SetButtonStyle, nodefault};
	__property int ButtonWidth = {read=GetButtonWidth, write=SetButtonWidth, default=17};
	__property System::UnicodeString ButtonHint = {read=FButtonHint, write=SetButtonHint};
	__property Color;
	__property Ctl3D;
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property bool EditorEnabled = {read=FEditorEnabled, write=FEditorEnabled, default=1};
	__property Enabled = {default=1};
	__property bool Flat = {read=FFlat, write=SetFlat, nodefault};
	__property Font;
	__property bool Etched = {read=FEtched, write=SetEtched, nodefault};
	__property FocusBorder = {default=0};
	__property Graphics::TBitmap* Glyph = {read=GetGlyph, write=SetGlyph};
	__property System::UnicodeString ButtonCaption = {read=GetCaption, write=SetCaption};
	__property MaxLength = {default=0};
	__property ParentColor = {default=0};
	__property ParentCtl3D = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property bool ReadOnly = {read=GetReadOnlyEx, write=SetReadOnlyEx, nodefault};
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=1};
	__property Text;
	__property Visible;
	__property Height;
	__property Width;
	__property OnChange;
	__property OnClick;
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnStartDrag;
	__property Classes::TNotifyEvent OnClickBtn = {read=FOnClickBtn, write=FOnClickBtn};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvEditBtn(HWND ParentWindow) : Advedit::TAdvEdit(ParentWindow) { }
	
};


typedef void __fastcall (__closure *TUnitChangeEvent)(System::TObject* Sender, System::UnicodeString NewUnit);

class DELPHICLASS TUnitAdvEditBtn;
class PASCALIMPLEMENTATION TUnitAdvEditBtn : public TAdvEditBtn
{
	typedef TAdvEditBtn inherited;
	
private:
	System::UnicodeString FUnitID;
	Classes::TStringList* FUnits;
	TUnitChangeEvent FUnitChanged;
	int __fastcall GetUnitSize(void);
	void __fastcall SetUnitSize(int value);
	void __fastcall SetUnits(Classes::TStringList* value);
	void __fastcall SetUnitID(System::UnicodeString value);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Msg);
	HIDESBASE MESSAGE void __fastcall WMCommand(Messages::TWMCommand &Message);
	
protected:
	virtual void __fastcall BtnClick(System::TObject* Sender);
	
public:
	__fastcall virtual TUnitAdvEditBtn(Classes::TComponent* AOwner);
	__fastcall virtual ~TUnitAdvEditBtn(void);
	
__published:
	__property Classes::TStringList* Units = {read=FUnits, write=SetUnits};
	__property System::UnicodeString UnitID = {read=FUnitID, write=SetUnitID};
	__property int UnitSpace = {read=GetUnitSize, write=SetUnitSize, nodefault};
	__property TUnitChangeEvent OnUnitChanged = {read=FUnitChanged, write=FUnitChanged};
public:
	/* TWinControl.CreateParented */ inline __fastcall TUnitAdvEditBtn(HWND ParentWindow) : TAdvEditBtn(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x3;
static const ShortInt REL_VER = 0x5;
static const ShortInt BLD_VER = 0x1;

}	/* namespace Advedbtn */
using namespace Advedbtn;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvedbtnHPP
