// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advlookupbar.pas' rev: 21.00

#ifndef AdvlookupbarHPP
#define AdvlookupbarHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Math.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Advstyleif.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advlookupbar
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TLookUpBarOrder { loNumericFirst, loNumericLast };
#pragma option pop

#pragma option push -b-
enum TLookUpBarCategoryType { alphanumeric, custom };
#pragma option pop

class DELPHICLASS TLookupBarCategory;
class DELPHICLASS TAdvLookupBar;
class PASCALIMPLEMENTATION TLookupBarCategory : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	TAdvLookupBar* FOwner;
	System::UnicodeString FText;
	int FID;
	int FTag;
	int FImageIndex;
	System::UnicodeString FLookupText;
	void __fastcall SetText(const System::UnicodeString Value);
	void __fastcall SetId(const int Value);
	void __fastcall SetImageIndex(const int Value);
	void __fastcall SetTag(const int Value);
	void __fastcall SetLookupText(const System::UnicodeString Value);
	
protected:
	HIDESBASE void __fastcall Changed(void);
	
public:
	__fastcall virtual TLookupBarCategory(Classes::TCollection* Collection);
	__fastcall virtual ~TLookupBarCategory(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property int ImageIndex = {read=FImageIndex, write=SetImageIndex, default=-1};
	__property int Tag = {read=FTag, write=SetTag, nodefault};
	__property System::UnicodeString Text = {read=FText, write=SetText};
	__property System::UnicodeString LookupText = {read=FLookupText, write=SetLookupText};
	__property int Id = {read=FID, write=SetId, nodefault};
};


class DELPHICLASS TShadowedCollection;
class PASCALIMPLEMENTATION TShadowedCollection : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	Classes::TCollectionItemClass FItemClass;
	Classes::TList* FItems;
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TShadowedCollection(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TShadowedCollection(void) : Classes::TPersistent() { }
	
};


class DELPHICLASS TLookUpBarCategories;
class PASCALIMPLEMENTATION TLookUpBarCategories : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TLookupBarCategory* operator[](int Index) { return Items[Index]; }
	
private:
	TAdvLookupBar* FOwner;
	Classes::TNotifyEvent FOnChange;
	HIDESBASE TLookupBarCategory* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TLookupBarCategory* Value);
	
protected:
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
	virtual int __fastcall Compare(TLookupBarCategory* Item1, TLookupBarCategory* Item2);
	void __fastcall QuickSort(int L, int R);
	
public:
	__fastcall TLookUpBarCategories(TAdvLookupBar* AOwner);
	__property TLookupBarCategory* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
	TLookupBarCategory* __fastcall ItemById(int id);
	int __fastcall ItemIndexById(int id);
	HIDESBASE TLookupBarCategory* __fastcall Add(void);
	HIDESBASE TLookupBarCategory* __fastcall Insert(int Index);
	HIDESBASE void __fastcall Delete(int Index);
	void __fastcall Sort(void);
	HIDESBASE void __fastcall Clear(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TLookUpBarCategories(void) { }
	
};


#pragma option push -b-
enum TCharRecMode { rmNormal, rmHover, rmSelected };
#pragma option pop

struct TCharRec
{
	
public:
	System::UnicodeString Str;
	int Tag;
	bool Active;
	TCharRecMode Mode;
	TLookupBarCategory* Category;
};


typedef void __fastcall (__closure *TOnLookUpEvent)(System::TObject* Sender, const TCharRec &LookUp);

class DELPHICLASS TTransparentHint;
class PASCALIMPLEMENTATION TTransparentHint : public Controls::THintWindow
{
	typedef Controls::THintWindow inherited;
	
private:
	System::Byte FTransparency;
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	
public:
	__property System::Byte Transparency = {read=FTransparency, write=FTransparency, nodefault};
	__fastcall virtual TTransparentHint(Classes::TComponent* AOwner);
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TTransparentHint(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TTransparentHint(HWND ParentWindow) : Controls::THintWindow(ParentWindow) { }
	
};


struct TCategoryString
{
	
public:
	System::UnicodeString Text;
	int ID;
};


typedef DynamicArray<TCategoryString> TCategoryStrings;

class PASCALIMPLEMENTATION TAdvLookupBar : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	typedef StaticArray<TCharRec, 36> _TAdvLookupBar__1;
	
	typedef DynamicArray<TCharRec> _TAdvLookupBar__2;
	
	
private:
	TTransparentHint* FScrollHint;
	Stdctrls::TLabel* FScrolllbl;
	TCharRec FCurrentChar;
	bool FMouseDown;
	_TAdvLookupBar__1 FChar;
	_TAdvLookupBar__2 FCustomChar;
	Graphics::TColor FColor;
	TLookUpBarOrder FOrder;
	Graphics::TColor FColorTo;
	int FSpacing;
	bool FNumeric;
	bool FRotated;
	TLookUpBarCategories* FCategories;
	TLookUpBarCategoryType FCategoryType;
	Imglist::TCustomImageList* FImages;
	Graphics::TColor FBorderColor;
	Graphics::TFont* FSelectedFont;
	Graphics::TFont* FActiveFont;
	Graphics::TFont* FInActiveFont;
	Graphics::TColor FScrollColor;
	Graphics::TFont* FScrollFont;
	bool FAutoSize;
	TOnLookUpEvent FOnLookUp;
	TOnLookUpEvent FOnLookUpClick;
	bool FTransparent;
	bool FRounded;
	bool FProgLookup;
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	HIDESBASE void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetColorTo(const Graphics::TColor Value);
	void __fastcall SetNumeric(const bool Value);
	void __fastcall SetOrder(const TLookUpBarOrder Value);
	void __fastcall SetRotated(const bool Value);
	void __fastcall SetSpacing(const int Value);
	void __fastcall SetCategories(const TLookUpBarCategories* Value);
	void __fastcall SetCategoryType(const TLookUpBarCategoryType Value);
	void __fastcall SetActiveFont(const Graphics::TFont* Value);
	void __fastcall SetBorderColor(const Graphics::TColor Value);
	void __fastcall SetInActiveFont(const Graphics::TFont* Value);
	void __fastcall SetScrollColor(const Graphics::TColor Value);
	void __fastcall SetScrollFont(const Graphics::TFont* Value);
	void __fastcall SetSelectedFont(const Graphics::TFont* Value);
	void __fastcall SetAS(const bool Value);
	void __fastcall SetRounded(const bool Value);
	void __fastcall SetTransparent(const bool Value);
	
protected:
	int __fastcall GetVersionNr(void);
	void __fastcall DrawLookUpBar(Graphics::TCanvas* ACanvas, const Types::TRect &R);
	HIDESBASE void __fastcall FontChanged(System::TObject* Sender);
	void __fastcall UpdateScrollHint(int X, int Y);
	TLookupBarCategory* __fastcall GetCategoryByID(int ID);
	TCharRec __fastcall XYToLookUpItem(int pX, int pY);
	TCharRec __fastcall XYToLookUpCategory(int pX, int pY);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	virtual void __fastcall DoLookupClick(const TCharRec &ACurrentChar);
	virtual void __fastcall DoLookup(const TCharRec &ACurrentChar);
	int __fastcall CalcMinSize(void);
	virtual void __fastcall Loaded(void);
	__property bool ProgLookup = {read=FProgLookup, write=FProgLookup, nodefault};
	
public:
	__fastcall virtual TAdvLookupBar(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvLookupBar(void);
	virtual void __fastcall Paint(void);
	HIDESBASE void __fastcall Changed(void);
	TCharRec __fastcall XYToLookUp(int X, int Y);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall SelectLookup(System::UnicodeString Lookup);
	__property TCharRec SelectedLookup = {read=FCurrentChar};
	void __fastcall InitLookupBar(Classes::TStrings* LookupStrings);
	void __fastcall InitLookupBarCategories(void);
	void __fastcall SetComponentStyle(Advstyleif::TTMSStyle AStyle);
	virtual void __fastcall SetBounds(int ALeft, int ATop, int AWidth, int AHeight);
	void __fastcall AddLookupCategory(TCategoryStrings &LookupCategories, const TCategoryString &LookupCategory);
	
__published:
	__property bool AutoSize = {read=FAutoSize, write=SetAS, default=1};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
	__property Graphics::TColor BorderColor = {read=FBorderColor, write=SetBorderColor, default=12164479};
	__property Graphics::TColor Color = {read=FColor, write=SetColor, default=15987699};
	__property Graphics::TColor ColorTo = {read=FColorTo, write=SetColorTo, default=14145495};
	__property Graphics::TColor ScrollColor = {read=FScrollColor, write=SetScrollColor, default=-16777192};
	__property bool Numeric = {read=FNumeric, write=SetNumeric, default=0};
	__property TLookUpBarOrder Order = {read=FOrder, write=SetOrder, default=1};
	__property Graphics::TFont* ActiveFont = {read=FActiveFont, write=SetActiveFont};
	__property Graphics::TFont* InActiveFont = {read=FInActiveFont, write=SetInActiveFont};
	__property Graphics::TFont* SelectedFont = {read=FSelectedFont, write=SetSelectedFont};
	__property Graphics::TFont* ScrollFont = {read=FScrollFont, write=SetScrollFont};
	__property int Spacing = {read=FSpacing, write=SetSpacing, default=1};
	__property bool Rotated = {read=FRotated, write=SetRotated, default=0};
	__property TLookUpBarCategoryType CategoryType = {read=FCategoryType, write=SetCategoryType, default=0};
	__property TLookUpBarCategories* Categories = {read=FCategories, write=SetCategories};
	__property Imglist::TCustomImageList* Images = {read=FImages, write=FImages};
	__property TOnLookUpEvent OnLookUp = {read=FOnLookUp, write=FOnLookUp};
	__property TOnLookUpEvent OnLookUpClick = {read=FOnLookUpClick, write=FOnLookUpClick};
	__property bool Transparent = {read=FTransparent, write=SetTransparent, default=0};
	__property bool Rounded = {read=FRounded, write=SetRounded, default=0};
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property Ctl3D;
	__property Constraints;
	__property PopupMenu;
	__property TabOrder = {default=-1};
	__property ParentShowHint = {default=1};
	__property ShowHint;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseUp;
	__property OnMouseMove;
	__property OnMouseDown;
	__property OnMouseEnter;
	__property OnMouseLeave;
	__property DragKind = {default=0};
	__property DragMode = {default=0};
	__property OnResize;
	__property OnDblClick;
	__property OnClick;
	__property OnEnter;
	__property OnExit;
	__property OnStartDrag;
	__property OnEndDrag;
	__property OnDragDrop;
	__property OnDragOver;
	__property Visible = {default=1};
	__property TabStop = {default=1};
	__property OnGesture;
	__property Touch;
	__property BevelEdges = {default=15};
	__property BevelInner = {index=0, default=2};
	__property BevelOuter = {index=1, default=1};
	__property BevelKind = {default=0};
	__property BevelWidth = {default=1};
	__property BiDiMode;
	__property DockSite = {default=0};
	__property DoubleBuffered;
	__property DragCursor = {default=-12};
	__property Enabled = {default=1};
	__property Padding;
	__property ParentBackground = {default=0};
	__property ParentBiDiMode = {default=1};
	__property ParentCtl3D = {default=1};
	__property ParentFont = {default=1};
	__property OnCanResize;
	__property OnConstrainedResize;
	__property OnContextPopup;
	__property OnDockDrop;
	__property OnDockOver;
	__property OnEndDock;
	__property OnGetSiteInfo;
	__property OnMouseWheel;
	__property OnMouseWheelDown;
	__property OnMouseWheelUp;
	__property OnStartDock;
	__property OnUnDock;
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvLookupBar(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
private:
	void *__ITMSStyle;	/* Advstyleif::ITMSStyle */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Advstyleif::_di_ITMSStyle()
	{
		Advstyleif::_di_ITMSStyle intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITMSStyle*(void) { return (ITMSStyle*)&__ITMSStyle; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x0;
static const ShortInt REL_VER = 0x1;
static const ShortInt BLD_VER = 0x0;

}	/* namespace Advlookupbar */
using namespace Advlookupbar;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvlookupbarHPP
