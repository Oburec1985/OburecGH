// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advlistbox.pas' rev: 21.00

#ifndef AdvlistboxHPP
#define AdvlistboxHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Advedit.hpp>	// Pascal unit
#include <Advmultibuttonedit.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advlistbox
{
//-- type declarations -------------------------------------------------------
typedef Controls::THintInfo THintInfo;

typedef Controls::PHintInfo PHintInfo;

class DELPHICLASS TListBoxItem;
class PASCALIMPLEMENTATION TListBoxItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	int FTag;
	System::UnicodeString FText;
	bool FChecked;
	int FImageIndex;
	bool FHasCheckBox;
	System::TObject* FObject;
	int FFilterIndex;
	bool FFiltered;
	void __fastcall SetChecked(const bool Value);
	void __fastcall SetHasCheckBox(const bool Value);
	void __fastcall SetImageIndex(const int Value);
	void __fastcall SetText(const System::UnicodeString Value);
	
protected:
	__property int FilterIndex = {read=FFilterIndex, write=FFilterIndex, nodefault};
	__property bool Filtered = {read=FFiltered, write=FFiltered, nodefault};
	
public:
	__fastcall virtual TListBoxItem(Classes::TCollection* Collection);
	__property bool HasCheckBox = {read=FHasCheckBox, write=SetHasCheckBox, nodefault};
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property System::TObject* ItemObject = {read=FObject, write=FObject};
	
__published:
	__property bool Checked = {read=FChecked, write=SetChecked, default=0};
	__property System::UnicodeString Text = {read=FText, write=SetText};
	__property int ImageIndex = {read=FImageIndex, write=SetImageIndex, default=-1};
	__property int Tag = {read=FTag, write=FTag, default=0};
public:
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TListBoxItem(void) { }
	
};


class DELPHICLASS TListBoxItems;
class PASCALIMPLEMENTATION TListBoxItems : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TListBoxItem* operator[](int Index) { return Items[Index]; }
	
private:
	Classes::TNotifyEvent FOnChange;
	TListBoxItem* __fastcall GetItems(int Index);
	void __fastcall SetItems(int Index, const TListBoxItem* Value);
	
protected:
	virtual void __fastcall Update(Classes::TCollectionItem* Item);
	
public:
	__fastcall TListBoxItems(void);
	__fastcall virtual ~TListBoxItems(void);
	__property TListBoxItem* Items[int Index] = {read=GetItems, write=SetItems/*, default*/};
	HIDESBASE TListBoxItem* __fastcall Add(void);
	HIDESBASE TListBoxItem* __fastcall Insert(int Index);
	int __fastcall IndexOf(System::UnicodeString Value);
	void __fastcall Move(int FromIndex, int ToIndex);
	
__published:
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
};


#pragma option push -b-
enum TAdvListBoxStyle { stList, stCheckList };
#pragma option pop

#pragma option push -b-
enum TFilterMethod { fmStartsWith, fmEndsWith, fmContains, fmNotContains, fmEqual, fmNotEqual };
#pragma option pop

#pragma option push -b-
enum TSearchStyle { ssFilter, ssHighlight, ssGoto };
#pragma option pop

#pragma option push -b-
enum TInputPosition { ipTop, ipBottom };
#pragma option pop

class DELPHICLASS TSearchOptions;
class PASCALIMPLEMENTATION TSearchOptions : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	TSearchStyle FStyle;
	Classes::TNotifyEvent FOnChange;
	bool FShowClose;
	bool FAutoFind;
	bool FShowFind;
	bool FVisible;
	System::UnicodeString FHintFind;
	System::UnicodeString FHintClose;
	TFilterMethod FFilterMethod;
	Graphics::TColor FEditColor;
	bool FCaseSensitive;
	TInputPosition FPosition;
	Classes::TNotifyEvent FOnAlignmentChange;
	System::UnicodeString FTextHint;
	bool FFlat;
	void __fastcall SetStyle(const TSearchStyle Value);
	void __fastcall SetVisible(const bool Value);
	void __fastcall SetShowClose(const bool Value);
	void __fastcall SetHintClose(const System::UnicodeString Value);
	void __fastcall SetHintFind(const System::UnicodeString Value);
	void __fastcall SetFilterMethod(const TFilterMethod Value);
	void __fastcall SetEditColor(const Graphics::TColor Value);
	void __fastcall SetPosition(const TInputPosition Value);
	void __fastcall SetTextHint(const System::UnicodeString Value);
	void __fastcall SetFlat(const bool Value);
	void __fastcall SetShowFind(const bool Value);
	
protected:
	void __fastcall Changed(void);
	void __fastcall AlignmentChanged(void);
	
public:
	__fastcall TSearchOptions(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property bool AutoFind = {read=FAutoFind, write=FAutoFind, default=0};
	__property bool CaseSensitive = {read=FCaseSensitive, write=FCaseSensitive, default=0};
	__property Graphics::TColor EditColor = {read=FEditColor, write=SetEditColor, default=-16777211};
	__property System::UnicodeString HintClose = {read=FHintClose, write=SetHintClose};
	__property System::UnicodeString HintFind = {read=FHintFind, write=SetHintFind};
	__property TFilterMethod FilterMethod = {read=FFilterMethod, write=SetFilterMethod, default=0};
	__property bool Flat = {read=FFlat, write=SetFlat, default=1};
	__property TInputPosition Position = {read=FPosition, write=SetPosition, default=0};
	__property bool ShowClose = {read=FShowClose, write=SetShowClose, default=0};
	__property bool ShowFind = {read=FShowFind, write=SetShowFind, default=1};
	__property TSearchStyle Style = {read=FStyle, write=SetStyle, nodefault};
	__property System::UnicodeString TextHint = {read=FTextHint, write=SetTextHint};
	__property bool Visible = {read=FVisible, write=SetVisible, default=1};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property Classes::TNotifyEvent OnAlignmentChange = {read=FOnAlignmentChange, write=FOnAlignmentChange};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TSearchOptions(void) { }
	
};


class DELPHICLASS TInsertOptions;
class PASCALIMPLEMENTATION TInsertOptions : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	bool FVisible;
	Classes::TNotifyEvent FOnChange;
	bool FShowClose;
	bool FInsertAndClear;
	System::UnicodeString FHintClose;
	bool FAutoInsert;
	Graphics::TColor FEditColor;
	System::UnicodeString FHintInsert;
	TInputPosition FPosition;
	Classes::TNotifyEvent FOnAlignmentChange;
	System::UnicodeString FTextHint;
	bool FFlat;
	void __fastcall SetVisible(const bool Value);
	void __fastcall SetShowClose(const bool Value);
	void __fastcall SetHintClose(const System::UnicodeString Value);
	void __fastcall SetEditColor(const Graphics::TColor Value);
	void __fastcall SetHintInsert(const System::UnicodeString Value);
	void __fastcall SetPosition(const TInputPosition Value);
	void __fastcall SetTextHint(const System::UnicodeString Value);
	void __fastcall SetFlat(const bool Value);
	
protected:
	void __fastcall Changed(void);
	void __fastcall AlignmentChanged(void);
	
public:
	__fastcall TInsertOptions(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property bool AutoInsert = {read=FAutoInsert, write=FAutoInsert, default=0};
	__property Graphics::TColor EditColor = {read=FEditColor, write=SetEditColor, default=-16777211};
	__property bool Flat = {read=FFlat, write=SetFlat, default=1};
	__property bool InsertAndClear = {read=FInsertAndClear, write=FInsertAndClear, default=0};
	__property System::UnicodeString HintClose = {read=FHintClose, write=SetHintClose};
	__property System::UnicodeString HintInsert = {read=FHintInsert, write=SetHintInsert};
	__property TInputPosition Position = {read=FPosition, write=SetPosition, default=0};
	__property bool ShowClose = {read=FShowClose, write=SetShowClose, default=0};
	__property System::UnicodeString TextHint = {read=FTextHint, write=SetTextHint};
	__property bool Visible = {read=FVisible, write=SetVisible, nodefault};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property Classes::TNotifyEvent OnAlignmentChange = {read=FOnAlignmentChange, write=FOnAlignmentChange};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TInsertOptions(void) { }
	
};


typedef void __fastcall (__closure *TCheckBoxClickEvent)(System::TObject* Sender, int Index);

typedef void __fastcall (__closure *TListBoxItemEvent)(System::TObject* Sender, TListBoxItem* Item);

typedef void __fastcall (__closure *TListBoxItemHintEvent)(System::TObject* Sender, TListBoxItem* Item, int Index, System::UnicodeString &HintStr);

class DELPHICLASS TAdvListBox;
class DELPHICLASS TVisualListBox;
class DELPHICLASS TIntList;
class PASCALIMPLEMENTATION TAdvListBox : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	TVisualListBox* FListBox;
	Advmultibuttonedit::TAdvMultiButtonEdit* FSearchEdit;
	Advmultibuttonedit::TAdvMultiButtonEdit* FInsertEdit;
	Imglist::TCustomImageList* FImages;
	TListBoxItems* FItems;
	TAdvListBoxStyle FStyle;
	int FFilterItems;
	System::UnicodeString FFilterCondition;
	bool FFilterActive;
	TIntList* FFilterIndexes;
	TSearchOptions* FSearchOptions;
	TInsertOptions* FInsertOptions;
	int FItemHeight;
	Classes::TShortCut FSearchShortCut;
	Classes::TShortCut FInsertShortCut;
	int FAutoCompleteDelay;
	bool FAutoComplete;
	Forms::TFormBorderStyle FBorderStyle;
	bool FMultiSelect;
	Graphics::TColor FListColor;
	Classes::TNotifyEvent FOnListDblClick;
	Classes::TNotifyEvent FOnListClick;
	Classes::TNotifyEvent FOnSearchEditDblClick;
	Classes::TNotifyEvent FOnSearchEditChange;
	Classes::TNotifyEvent FOnSearchEditClick;
	Classes::TNotifyEvent FOnInsertEditDblClick;
	Classes::TNotifyEvent FOnInsertEditChange;
	Classes::TNotifyEvent FOnInsertEditClick;
	Controls::TKeyEvent FOnSearchEditKeyDown;
	Controls::TKeyEvent FOnSearchEditKeyUp;
	Controls::TKeyPressEvent FOnInsertEditKeyPress;
	Controls::TKeyEvent FOnInsertEditKeyDown;
	Controls::TKeyEvent FOnInsertEditKeyUp;
	Controls::TKeyPressEvent FOnSearchEditKeyPress;
	Controls::TKeyPressEvent FOnListKeyPress;
	Controls::TKeyEvent FOnListKeyDown;
	Controls::TKeyEvent FOnListKeyUp;
	TCheckBoxClickEvent FOnListCheckBoxClick;
	Classes::TNotifyEvent FOnSearchClose;
	Classes::TNotifyEvent FOnSearchClick;
	Classes::TNotifyEvent FOnInsertClose;
	Classes::TNotifyEvent FOnInsertClick;
	Classes::TNotifyEvent FOnSearchShow;
	Classes::TNotifyEvent FOnInsertShow;
	TListBoxItemEvent FOnInsertItem;
	Controls::TMouseEvent FOnListMouseDown;
	Controls::TMouseMoveEvent FOnListMouseMove;
	Controls::TMouseEvent FOnListMouseUp;
	TListBoxItemHintEvent FOnItemHint;
	HIDESBASE MESSAGE void __fastcall CMColorChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Msg);
	HIDESBASE MESSAGE void __fastcall WMSetFocus(Messages::TWMSetFocus &Msg);
	void __fastcall SetImages(const Imglist::TCustomImageList* Value);
	void __fastcall SetItems(const TListBoxItems* Value);
	void __fastcall SetStyle(const TAdvListBoxStyle Value);
	void __fastcall SetFilterActive(const bool Value);
	void __fastcall SetInsertOptions(const TInsertOptions* Value);
	void __fastcall SetSearchOptions(const TSearchOptions* Value);
	void __fastcall SetItemHeight(const int Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetAutoComplete(const bool Value);
	void __fastcall SetAutoCompleteDelay(const int Value);
	void __fastcall SetBorderStyle(const Forms::TBorderStyle Value);
	int __fastcall GetItemIndex(void);
	void __fastcall SetItemIndex(const int Value);
	void __fastcall SetMultiSelect(const bool Value);
	void __fastcall SetListColor(const Graphics::TColor Value);
	bool __fastcall GetSelected(int Index);
	void __fastcall SetSelected(int Index, const bool Value);
	void __fastcall SetFilterCondition(const System::UnicodeString Value);
	Controls::TDragMode __fastcall GetDragModeEx(void);
	void __fastcall SetDragModeEx(const Controls::TDragMode Value);
	
protected:
	void __fastcall UpdateItems(void);
	void __fastcall UpdateAlignment(void);
	virtual TListBoxItems* __fastcall CreateItems(void);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall Loaded(void);
	System::UnicodeString __fastcall BuildCondition(TFilterMethod st, System::UnicodeString s);
	virtual void __fastcall DoFilter(void);
	virtual void __fastcall AlignmentChanged(System::TObject* Sender);
	virtual void __fastcall ItemsChanged(System::TObject* Sender);
	virtual void __fastcall SearchChanged(System::TObject* Sender);
	virtual void __fastcall SearchEditChanged(System::TObject* Sender);
	virtual void __fastcall SearchFindClick(System::TObject* Sender);
	virtual void __fastcall SearchCloseClick(System::TObject* Sender);
	virtual void __fastcall SearchShow(void);
	virtual void __fastcall InsertChanged(System::TObject* Sender);
	virtual void __fastcall InsertAddClick(System::TObject* Sender);
	virtual void __fastcall InsertCloseClick(System::TObject* Sender);
	virtual void __fastcall InsertShow(void);
	virtual void __fastcall InsertEditKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall InsertEditKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall InsertEditKeyPress(System::TObject* Sender, System::WideChar &Key);
	virtual void __fastcall SearchEditClick(System::TObject* Sender);
	virtual void __fastcall SearchEditDblClick(System::TObject* Sender);
	virtual void __fastcall InsertEditChanged(System::TObject* Sender);
	virtual void __fastcall InsertEditClick(System::TObject* Sender);
	virtual void __fastcall InsertEditDblClick(System::TObject* Sender);
	virtual void __fastcall SearchEditKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall SearchEditKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall SearchEditKeyPress(System::TObject* Sender, System::WideChar &Key);
	virtual void __fastcall ListClick(System::TObject* Sender);
	virtual void __fastcall ListDblClick(System::TObject* Sender);
	virtual void __fastcall ListKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall ListKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall ListKeyPress(System::TObject* Sender, System::WideChar &Key);
	virtual void __fastcall ListCheckBoxClick(System::TObject* Sender, int Index);
	virtual void __fastcall ListMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	virtual void __fastcall ListMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	virtual void __fastcall ListMouseMove(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	void __fastcall ListDragOver(System::TObject* Sender, System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall ListDragDrop(System::TObject* Sender, System::TObject* Source, int X, int Y);
	void __fastcall ListStartDrag(System::TObject* Sender, Controls::TDragObject* &DragObject);
	void __fastcall ListEndDrag(System::TObject* Sender, System::TObject* Target, int X, int Y);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	void __fastcall HandleShortCut(const Messages::TWMKey &Key);
	void __fastcall HandleSearch(bool Filter);
	void __fastcall DoInsertItem(System::UnicodeString Value);
	void __fastcall DoItemHint(TListBoxItem* AItem, int Index, System::UnicodeString &HintStr);
	
public:
	__fastcall virtual TAdvListBox(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvListBox(void);
	int __fastcall ItemCount(void);
	int __fastcall GetVersionNr(void);
	__property System::UnicodeString FilterCondition = {read=FFilterCondition, write=SetFilterCondition};
	__property bool FilterActive = {read=FFilterActive, write=SetFilterActive, nodefault};
	__property int ItemIndex = {read=GetItemIndex, write=SetItemIndex, nodefault};
	TListBoxItem* __fastcall GetItem(int Index);
	TListBoxItem* __fastcall GetItemAtXY(int X, int Y);
	__property bool Selected[int Index] = {read=GetSelected, write=SetSelected};
	__property Advmultibuttonedit::TAdvMultiButtonEdit* SearchEdit = {read=FSearchEdit};
	__property Advmultibuttonedit::TAdvMultiButtonEdit* InsertEdit = {read=FInsertEdit};
	
__published:
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property bool AutoComplete = {read=FAutoComplete, write=SetAutoComplete, default=1};
	__property int AutoCompleteDelay = {read=FAutoCompleteDelay, write=SetAutoCompleteDelay, default=500};
	__property Forms::TBorderStyle BorderStyle = {read=FBorderStyle, write=SetBorderStyle, default=1};
	__property Color = {default=-16777201};
	__property Constraints;
	__property DragCursor = {default=-12};
	__property DragKind = {default=0};
	__property Controls::TDragMode DragMode = {read=GetDragModeEx, write=SetDragModeEx, default=0};
	__property Enabled = {default=1};
	__property Font;
	__property Hint;
	__property Imglist::TCustomImageList* Images = {read=FImages, write=SetImages};
	__property Classes::TShortCut InsertShortCut = {read=FInsertShortCut, write=FInsertShortCut, default=0};
	__property TInsertOptions* InsertOptions = {read=FInsertOptions, write=SetInsertOptions};
	__property int ItemHeight = {read=FItemHeight, write=SetItemHeight, default=15};
	__property TListBoxItems* Items = {read=FItems, write=SetItems};
	__property Graphics::TColor ListColor = {read=FListColor, write=SetListColor, default=-16777211};
	__property bool MultiSelect = {read=FMultiSelect, write=SetMultiSelect, default=0};
	__property ParentColor = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property Classes::TShortCut SearchShortCut = {read=FSearchShortCut, write=FSearchShortCut, default=0};
	__property TSearchOptions* SearchOptions = {read=FSearchOptions, write=SetSearchOptions};
	__property ShowHint;
	__property TAdvListBoxStyle Style = {read=FStyle, write=SetStyle, nodefault};
	__property TabOrder = {default=-1};
	__property TabStop = {default=0};
	__property System::UnicodeString Version = {read=GetVersion};
	__property Visible = {default=1};
	__property OnContextPopup;
	__property OnDragOver;
	__property OnDragDrop;
	__property OnEndDock;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnMouseLeave;
	__property OnMouseEnter;
	__property OnStartDock;
	__property OnStartDrag;
	__property TListBoxItemHintEvent OnItemHint = {read=FOnItemHint, write=FOnItemHint};
	__property Classes::TNotifyEvent OnListClick = {read=FOnListClick, write=FOnListClick};
	__property Classes::TNotifyEvent OnListDblClick = {read=FOnListDblClick, write=FOnListDblClick};
	__property Controls::TKeyEvent OnListKeyDown = {read=FOnListKeyDown, write=FOnListKeyDown};
	__property Controls::TKeyEvent OnListKeyUp = {read=FOnListKeyUp, write=FOnListKeyUp};
	__property Controls::TKeyPressEvent OnListKeyPress = {read=FOnListKeyPress, write=FOnListKeyPress};
	__property TCheckBoxClickEvent OnListCheckBoxClick = {read=FOnListCheckBoxClick, write=FOnListCheckBoxClick};
	__property Controls::TMouseEvent OnListMouseDown = {read=FOnListMouseDown, write=FOnListMouseDown};
	__property Controls::TMouseMoveEvent OnListMouseMove = {read=FOnListMouseMove, write=FOnListMouseMove};
	__property Controls::TMouseEvent OnListMouseUp = {read=FOnListMouseUp, write=FOnListMouseUp};
	__property Classes::TNotifyEvent OnSearchClick = {read=FOnSearchClick, write=FOnSearchClick};
	__property Classes::TNotifyEvent OnSearchClose = {read=FOnSearchClose, write=FOnSearchClose};
	__property Classes::TNotifyEvent OnSearchShow = {read=FOnSearchShow, write=FOnSearchShow};
	__property Classes::TNotifyEvent OnSearchEditChange = {read=FOnSearchEditChange, write=FOnSearchEditChange};
	__property Classes::TNotifyEvent OnSearchEditClick = {read=FOnSearchEditClick, write=FOnSearchEditClick};
	__property Classes::TNotifyEvent OnSearchEditDblClick = {read=FOnSearchEditDblClick, write=FOnSearchEditDblClick};
	__property Controls::TKeyEvent OnSearchEditKeyDown = {read=FOnSearchEditKeyDown, write=FOnSearchEditKeyDown};
	__property Controls::TKeyEvent OnSearchEditKeyUp = {read=FOnSearchEditKeyUp, write=FOnSearchEditKeyUp};
	__property Controls::TKeyPressEvent OnSearchEditKeyPress = {read=FOnSearchEditKeyPress, write=FOnSearchEditKeyPress};
	__property TListBoxItemEvent OnInsertItem = {read=FOnInsertItem, write=FOnInsertItem};
	__property Classes::TNotifyEvent OnInsertClick = {read=FOnInsertClick, write=FOnInsertClick};
	__property Classes::TNotifyEvent OnInsertClose = {read=FOnInsertClose, write=FOnInsertClose};
	__property Classes::TNotifyEvent OnInsertShow = {read=FOnInsertShow, write=FOnInsertShow};
	__property Classes::TNotifyEvent OnInsertEditChange = {read=FOnInsertEditChange, write=FOnInsertEditChange};
	__property Classes::TNotifyEvent OnInsertEditClick = {read=FOnInsertEditClick, write=FOnInsertEditClick};
	__property Classes::TNotifyEvent OnInsertEditDblClick = {read=FOnInsertEditDblClick, write=FOnInsertEditDblClick};
	__property Controls::TKeyEvent OnInsertEditKeyDown = {read=FOnInsertEditKeyDown, write=FOnInsertEditKeyDown};
	__property Controls::TKeyEvent OnInsertEditKeyUp = {read=FOnInsertEditKeyUp, write=FOnInsertEditKeyUp};
	__property Controls::TKeyPressEvent OnInsertEditKeyPress = {read=FOnInsertEditKeyPress, write=FOnInsertEditKeyPress};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvListBox(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
};


#pragma option push -b-
enum TControlStyle { csClassic, csThemed };
#pragma option pop

class PASCALIMPLEMENTATION TVisualListBox : public Stdctrls::TListBox
{
	typedef Stdctrls::TListBox inherited;
	
private:
	bool FIsThemed;
	TAdvListBox* FOwner;
	int chk;
	TCheckBoxClickEvent FOnCheckBoxClick;
	System::UnicodeString FHighlightText;
	HIDESBASE MESSAGE void __fastcall CMHintShow(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Msg);
	
protected:
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	virtual void __fastcall DrawItem(int Index, const Types::TRect &Rect, Windows::TOwnerDrawState State);
	virtual void __fastcall MeasureItem(int Index, int &Height);
	void __fastcall DrawCheck(const Types::TRect &R, bool State, bool Enabled, bool Grayed, TControlStyle ControlStyle);
	virtual void __fastcall DoCheckBoxClick(int Index);
	virtual void __fastcall CreateWnd(void);
	
public:
	__fastcall virtual TVisualListBox(Classes::TComponent* AOwner);
	__property System::UnicodeString HighlightText = {read=FHighlightText, write=FHighlightText};
	
__published:
	__property TCheckBoxClickEvent OnCheckBoxClick = {read=FOnCheckBoxClick, write=FOnCheckBoxClick};
public:
	/* TCustomListBox.Destroy */ inline __fastcall virtual ~TVisualListBox(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TVisualListBox(HWND ParentWindow) : Stdctrls::TListBox(ParentWindow) { }
	
};


class PASCALIMPLEMENTATION TIntList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	int operator[](int index) { return Items[index]; }
	
private:
	Classes::TNotifyEvent FOnChange;
	void __fastcall SetInteger(int Index, int Value);
	int __fastcall GetInteger(int Index);
	System::UnicodeString __fastcall GetStrValue(void);
	void __fastcall SetStrValue(const System::UnicodeString Value);
	
protected:
	virtual void __fastcall DoChange(void);
	
public:
	__fastcall TIntList(void);
	void __fastcall DeleteValue(int Value);
	bool __fastcall HasValue(int Value);
	__property int Items[int index] = {read=GetInteger, write=SetInteger/*, default*/};
	HIDESBASE void __fastcall Add(int Value);
	HIDESBASE void __fastcall Insert(int Index, int Value);
	HIDESBASE void __fastcall Delete(int Index);
	__property System::UnicodeString StrValue = {read=GetStrValue, write=SetStrValue};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
public:
	/* TList.Destroy */ inline __fastcall virtual ~TIntList(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x1;
static const ShortInt REL_VER = 0x5;
static const ShortInt BLD_VER = 0x1;

}	/* namespace Advlistbox */
using namespace Advlistbox;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvlistboxHPP
