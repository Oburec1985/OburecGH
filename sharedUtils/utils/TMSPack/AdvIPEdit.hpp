// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advipedit.pas' rev: 21.00

#ifndef AdvipeditHPP
#define AdvipeditHPP

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
#include <Controls.hpp>	// Pascal unit
#include <Advedit.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Maskutils.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Mask.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advipedit
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TNumericInputMode { niNumbers, niHex };
#pragma option pop

class DELPHICLASS TAdvNumCustomMaskEdit;
class PASCALIMPLEMENTATION TAdvNumCustomMaskEdit : public Advedit::TAdvCustomMaskEdit
{
	typedef Advedit::TAdvCustomMaskEdit inherited;
	
private:
	TNumericInputMode FMode;
	HIDESBASE MESSAGE void __fastcall WMChar(Messages::TWMKey &Msg);
	
protected:
	__property TNumericInputMode Mode = {read=FMode, write=FMode, nodefault};
public:
	/* TAdvCustomMaskEdit.Create */ inline __fastcall virtual TAdvNumCustomMaskEdit(Classes::TComponent* AOwner) : Advedit::TAdvCustomMaskEdit(AOwner) { }
	/* TAdvCustomMaskEdit.Destroy */ inline __fastcall virtual ~TAdvNumCustomMaskEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvNumCustomMaskEdit(HWND ParentWindow) : Advedit::TAdvCustomMaskEdit(ParentWindow) { }
	
};


#pragma option push -b-
enum TIPAddressType { ipv4, ipv6, mac };
#pragma option pop

class DELPHICLASS TAdvIPEdit;
class PASCALIMPLEMENTATION TAdvIPEdit : public TAdvNumCustomMaskEdit
{
	typedef TAdvNumCustomMaskEdit inherited;
	
private:
	StaticArray<TAdvNumCustomMaskEdit*, 7> FOctets;
	int FNumOctets;
	int FOctetLen;
	StaticArray<Stdctrls::TStaticText*, 7> FSeparators;
	System::UnicodeString FIPAddress;
	TIPAddressType FIPAddressType;
	HIDESBASE MESSAGE void __fastcall WMKillFocus(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMColorChanged(Messages::TMessage &Message);
	Maskutils::TEditMask __fastcall GetEditMask(void);
	HIDESBASE void __fastcall SetEditMask(const Maskutils::TEditMask Value);
	void __fastcall SetIPAddress(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetIPAddress(void);
	void __fastcall IPToOctets(void);
	void __fastcall SetIPAddressType(const TIPAddressType Value);
	
protected:
	void __fastcall DestroySubControls(void);
	void __fastcall CreateSubControls(void);
	void __fastcall UpdateSubControls(void);
	void __fastcall InitControls(void);
	void __fastcall SetEditRect(void);
	DYNAMIC void __fastcall KeyUp(System::Word &Key, Classes::TShiftState Shift);
	void __fastcall OctetKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall OctetKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall OctetKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall OctetChange(System::TObject* Sender);
	void __fastcall OctetExit(System::TObject* Sender);
	DYNAMIC void __fastcall Resize(void);
	DYNAMIC void __fastcall DoEnter(void);
	virtual int __fastcall GetVersionNr(void);
	
public:
	__fastcall virtual TAdvIPEdit(Classes::TComponent* AOwner);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall SetBounds(int ALeft, int ATop, int AWidth, int AHeight);
	
__published:
	__property Align = {default=0};
	__property Alignment = {default=0};
	__property Anchors = {default=3};
	__property AutoSelect = {default=1};
	__property AutoSize = {default=1};
	__property BevelEdges = {default=15};
	__property BevelInner = {index=0, default=2};
	__property BevelOuter = {index=1, default=1};
	__property BevelKind = {default=0};
	__property BevelWidth = {default=1};
	__property BiDiMode;
	__property BorderStyle = {default=1};
	__property CharCase = {default=0};
	__property Color;
	__property Constraints;
	__property Ctl3D;
	__property DoubleBuffered;
	__property DragCursor = {default=-12};
	__property DragKind = {default=0};
	__property DragMode = {default=0};
	__property Enabled;
	__property Font;
	__property ImeMode = {default=3};
	__property ImeName;
	__property MaxLength = {default=0};
	__property ParentBiDiMode = {default=1};
	__property ParentColor = {default=0};
	__property ParentCtl3D = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PasswordChar = {default=0};
	__property PopupMenu;
	__property ReadOnly = {default=0};
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=1};
	__property Visible;
	__property AutoFocus;
	__property AutoTab = {default=1};
	__property CanUndo = {default=0};
	__property BorderColor = {default=536870911};
	__property DisabledBorder = {default=1};
	__property DisabledColor = {default=12632256};
	__property Flat;
	__property FlatLineColor;
	__property FlatParentColor;
	__property ShowModified;
	__property FocusBorderColor = {default=536870911};
	__property FocusColor = {default=536870911};
	__property FocusBorder;
	__property FocusFontColor;
	__property FocusLabel = {default=0};
	__property LabelCaption;
	__property LabelAlwaysEnabled;
	__property LabelPosition;
	__property LabelMargin;
	__property LabelTransparent;
	__property LabelFont;
	__property ModifiedColor;
	__property ReturnIsTab = {default=1};
	__property SoftBorder = {default=0};
	__property SelectFirstChar;
	__property Version;
	__property Maskutils::TEditMask EditMask = {read=GetEditMask, write=SetEditMask};
	__property System::UnicodeString IPAddress = {read=GetIPAddress, write=SetIPAddress};
	__property TIPAddressType IPAddressType = {read=FIPAddressType, write=SetIPAddressType, nodefault};
	__property OnMaskComplete;
	__property OnChange;
	__property OnClick;
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDock;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnStartDock;
	__property OnStartDrag;
public:
	/* TAdvCustomMaskEdit.Destroy */ inline __fastcall virtual ~TAdvIPEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvIPEdit(HWND ParentWindow) : TAdvNumCustomMaskEdit(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x1;
static const ShortInt REL_VER = 0x1;
static const ShortInt BLD_VER = 0x0;

}	/* namespace Advipedit */
using namespace Advipedit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvipeditHPP
