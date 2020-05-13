// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxctrls.pas' rev: 21.00

#ifndef FrxctrlsHPP
#define FrxctrlsHPP

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
#include <Commctrl.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Registry.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxctrls
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxCustomComboBox;
class PASCALIMPLEMENTATION TfrxCustomComboBox : public Stdctrls::TCustomComboBox
{
	typedef Stdctrls::TCustomComboBox inherited;
	
private:
	bool FUpDropdown;
	int FButtonWidth;
	bool msMouseInControl;
	HWND FListHandle;
	void *FListInstance;
	void *FDefListProc;
	HWND FChildHandle;
	bool FSolidBorder;
	bool FReadOnly;
	int FEditOffset;
	int FListWidth;
	HIDESBASE void __fastcall ListWndProc(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Message);
	HIDESBASE MESSAGE void __fastcall CNCommand(Messages::TWMCommand &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	void __fastcall PaintButtonGlyph(HDC DC, int X, int Y, Graphics::TColor Color);
	void __fastcall PaintButton(int ButtonStyle);
	void __fastcall PaintBorder(HDC DC, const bool SolidBorder);
	void __fastcall PaintDisabled(void);
	bool __fastcall GetSolidBorder(void);
	int __fastcall GetListHeight(void);
	void __fastcall SetReadOnly(bool Value);
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall ComboWndProc(Messages::TMessage &Message, HWND ComboWnd, void * ComboProc);
	virtual void __fastcall WndProc(Messages::TMessage &Message);
	virtual void __fastcall CreateWnd(void);
	DYNAMIC void __fastcall DrawImage(HDC DC, int Index, const Types::TRect &R);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	__property int ListWidth = {read=FListWidth, write=FListWidth, nodefault};
	__property bool ReadOnly = {read=FReadOnly, write=SetReadOnly, default=0};
	__property bool SolidBorder = {read=FSolidBorder, nodefault};
	
public:
	__fastcall virtual TfrxCustomComboBox(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomComboBox(void);
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxCustomComboBox(HWND ParentWindow) : Stdctrls::TCustomComboBox(ParentWindow) { }
	
};


class DELPHICLASS TfrxComboBox;
class PASCALIMPLEMENTATION TfrxComboBox : public TfrxCustomComboBox
{
	typedef TfrxCustomComboBox inherited;
	
__published:
	__property Color = {default=-16777211};
	__property DragMode = {default=0};
	__property DragCursor = {default=-12};
	__property DropDownCount = {default=8};
	__property Enabled = {default=1};
	__property Font;
	__property ItemHeight;
	__property Items;
	__property ListWidth;
	__property MaxLength = {default=0};
	__property ParentColor = {default=0};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property ShowHint;
	__property Sorted = {default=0};
	__property TabOrder = {default=-1};
	__property TabStop = {default=1};
	__property Text;
	__property ReadOnly = {default=0};
	__property Visible = {default=1};
	__property ItemIndex;
	__property OnChange;
	__property OnClick;
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnDrawItem;
	__property OnDropDown;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnStartDrag;
	__property Anchors = {default=3};
	__property BiDiMode;
	__property Constraints;
	__property DragKind = {default=0};
	__property ParentBiDiMode = {default=1};
	__property OnEndDock;
	__property OnStartDock;
public:
	/* TfrxCustomComboBox.Create */ inline __fastcall virtual TfrxComboBox(Classes::TComponent* AOwner) : TfrxCustomComboBox(AOwner) { }
	/* TfrxCustomComboBox.Destroy */ inline __fastcall virtual ~TfrxComboBox(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxComboBox(HWND ParentWindow) : TfrxCustomComboBox(ParentWindow) { }
	
};


class DELPHICLASS TfrxFontPreview;
class PASCALIMPLEMENTATION TfrxFontPreview : public Controls::TWinControl
{
	typedef Controls::TWinControl inherited;
	
private:
	Extctrls::TPanel* FPanel;
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	
public:
	__fastcall virtual TfrxFontPreview(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxFontPreview(void);
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxFontPreview(HWND ParentWindow) : Controls::TWinControl(ParentWindow) { }
	
};


class DELPHICLASS TfrxFontComboBox;
class PASCALIMPLEMENTATION TfrxFontComboBox : public TfrxCustomComboBox
{
	typedef TfrxCustomComboBox inherited;
	
private:
	TfrxFontPreview* frFontViewForm;
	System::UnicodeString FRegKey;
	Graphics::TBitmap* FTrueTypeBMP;
	Graphics::TBitmap* FDeviceBMP;
	Classes::TNotifyEvent FOnClick;
	bool FUpdate;
	bool FShowMRU;
	int Numused;
	HIDESBASE MESSAGE void __fastcall CNCommand(Messages::TWMCommand &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChange(Messages::TMessage &Message);
	void __fastcall SetRegKey(System::UnicodeString Value);
	
protected:
	virtual void __fastcall Loaded(void);
	void __fastcall Init(void);
	void __fastcall Reset(void);
	DYNAMIC void __fastcall Click(void);
	virtual void __fastcall DrawItem(int Index, const Types::TRect &Rect, Windows::TOwnerDrawState State);
	DYNAMIC void __fastcall DrawImage(HDC DC, int Index, const Types::TRect &R);
	
public:
	__fastcall virtual TfrxFontComboBox(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxFontComboBox(void);
	virtual void __fastcall PopulateList(void);
	
__published:
	__property bool ShowMRU = {read=FShowMRU, write=FShowMRU, default=1};
	__property System::UnicodeString MRURegKey = {read=FRegKey, write=SetRegKey};
	__property Text;
	__property Color = {default=-16777211};
	__property DragMode = {default=0};
	__property DragCursor = {default=-12};
	__property DropDownCount = {default=8};
	__property Enabled = {default=1};
	__property Font;
	__property Anchors = {default=3};
	__property BiDiMode;
	__property Constraints;
	__property DragKind = {default=0};
	__property ParentBiDiMode = {default=1};
	__property ItemHeight;
	__property ParentColor = {default=0};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=1};
	__property Visible = {default=1};
	__property OnChange;
	__property Classes::TNotifyEvent OnClick = {read=FOnClick, write=FOnClick};
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnDropDown;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnStartDrag;
	__property OnEndDock;
	__property OnStartDock;
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxFontComboBox(HWND ParentWindow) : TfrxCustomComboBox(ParentWindow) { }
	
};


class DELPHICLASS TfrxComboEdit;
class PASCALIMPLEMENTATION TfrxComboEdit : public Stdctrls::TComboBox
{
	typedef Stdctrls::TComboBox inherited;
	
private:
	Controls::TWinControl* FPanel;
	Buttons::TSpeedButton* FButton;
	bool FButtonEnabled;
	Classes::TNotifyEvent FOnButtonClick;
	Graphics::TBitmap* __fastcall GetGlyph(void);
	void __fastcall SetGlyph(Graphics::TBitmap* Value);
	System::UnicodeString __fastcall GetButtonHint(void);
	void __fastcall SetButtonHint(System::UnicodeString Value);
	void __fastcall SetButtonEnabled(bool Value);
	void __fastcall ButtonClick(System::TObject* Sender);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Message);
	void __fastcall SetPos(void);
	
public:
	__fastcall virtual TfrxComboEdit(Classes::TComponent* AOwner);
	virtual void __fastcall CreateWnd(void);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	
__published:
	__property Graphics::TBitmap* Glyph = {read=GetGlyph, write=SetGlyph};
	__property bool ButtonEnabled = {read=FButtonEnabled, write=SetButtonEnabled, default=1};
	__property System::UnicodeString ButtonHint = {read=GetButtonHint, write=SetButtonHint};
	__property Classes::TNotifyEvent OnButtonClick = {read=FOnButtonClick, write=FOnButtonClick};
public:
	/* TCustomComboBox.Destroy */ inline __fastcall virtual ~TfrxComboEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxComboEdit(HWND ParentWindow) : Stdctrls::TComboBox(ParentWindow) { }
	
};


class DELPHICLASS TfrxScrollWin;
class PASCALIMPLEMENTATION TfrxScrollWin : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	Forms::TFormBorderStyle FBorderStyle;
	int FHorzPage;
	int FHorzPosition;
	int FHorzRange;
	int FLargeChange;
	int FSmallChange;
	int FVertPage;
	int FVertPosition;
	int FVertRange;
	int __fastcall GetLongPosition(int DefValue, System::Word Code);
	void __fastcall SetHorzPosition(int Value);
	void __fastcall SetHorzRange(int Value);
	void __fastcall SetPosition(int Value, System::Word Code);
	void __fastcall SetVertPosition(int Value);
	void __fastcall SetVertRange(int Value);
	void __fastcall UpdateScrollBar(int Max, int Page, int Pos, System::Word Code);
	MESSAGE void __fastcall WMEraseBackground(Messages::TMessage &Message);
	MESSAGE void __fastcall WMGetDlgCode(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMHScroll(Messages::TWMScroll &Message);
	HIDESBASE MESSAGE void __fastcall WMVScroll(Messages::TWMScroll &Message);
	void __fastcall SetHorzPage(const int Value);
	void __fastcall SetVertPage(const int Value);
	void __fastcall SetBorderStyle(const Forms::TBorderStyle Value);
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall OnHScrollChange(System::TObject* Sender);
	virtual void __fastcall OnVScrollChange(System::TObject* Sender);
	
public:
	__fastcall virtual TfrxScrollWin(Classes::TComponent* AOwner);
	virtual void __fastcall Paint(void);
	__property BevelKind = {default=0};
	__property Forms::TBorderStyle BorderStyle = {read=FBorderStyle, write=SetBorderStyle, nodefault};
	__property int HorzPage = {read=FHorzPage, write=SetHorzPage, nodefault};
	__property int HorzPosition = {read=FHorzPosition, write=SetHorzPosition, nodefault};
	__property int HorzRange = {read=FHorzRange, write=SetHorzRange, nodefault};
	__property int LargeChange = {read=FLargeChange, write=FLargeChange, nodefault};
	__property int SmallChange = {read=FSmallChange, write=FSmallChange, nodefault};
	__property int VertPage = {read=FVertPage, write=SetVertPage, nodefault};
	__property int VertPosition = {read=FVertPosition, write=SetVertPosition, nodefault};
	__property int VertRange = {read=FVertRange, write=SetVertRange, nodefault};
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxScrollWin(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxScrollWin(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxctrls */
using namespace Frxctrls;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxctrlsHPP
