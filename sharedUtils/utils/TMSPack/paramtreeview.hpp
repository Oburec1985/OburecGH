// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Paramtreeview.pas' rev: 21.00

#ifndef ParamtreeviewHPP
#define ParamtreeviewHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Spin.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Parhtml.hpp>	// Pascal unit
#include <Picturecontainer.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Paramtreeview
{
//-- type declarations -------------------------------------------------------
typedef Controls::THintInfo THintInfo;

typedef Controls::PHintInfo PHintInfo;

typedef void __fastcall (__closure *TParamTreeViewClickEvent)(System::TObject* Sender, Comctrls::TTreeNode* ANode, System::UnicodeString href, System::UnicodeString &value);

typedef void __fastcall (__closure *TParamTreeViewPopupEvent)(System::TObject* Sender, Comctrls::TTreeNode* ANode, System::UnicodeString href, Classes::TStringList* values, bool &DoPopup);

typedef void __fastcall (__closure *TParamTreeViewSelectEvent)(System::TObject* Sender, Comctrls::TTreeNode* ANode, System::UnicodeString href, System::UnicodeString value);

typedef void __fastcall (__closure *TParamTreeViewChangedEvent)(System::TObject* Sender, Comctrls::TTreeNode* ANode, System::UnicodeString href, System::UnicodeString oldvalue, System::UnicodeString newvalue);

typedef void __fastcall (__closure *TParamTreeViewHintEvent)(System::TObject* Sender, Comctrls::TTreeNode* ANode, System::UnicodeString href, System::UnicodeString &hintvalue, bool &showhint);

typedef void __fastcall (__closure *TParamCustomEditEvent)(System::TObject* Sender, Comctrls::TTreeNode* Node, System::UnicodeString href, System::UnicodeString value, System::UnicodeString props, const Types::TRect &EditRect);

typedef void __fastcall (__closure *TParamTreeviewCustomShowEvent)(System::TObject* Sender, Comctrls::TTreeNode* ANode, System::UnicodeString href, System::UnicodeString &value, const Types::TRect &ARect);

typedef void __fastcall (__closure *TParamTreeViewEditEvent)(System::TObject* Sender, Comctrls::TTreeNode* ANode, System::UnicodeString href, System::UnicodeString &value);

class DELPHICLASS TParamTreeview;
class PASCALIMPLEMENTATION TParamTreeview : public Comctrls::TCustomTreeView
{
	typedef Comctrls::TCustomTreeView inherited;
	
private:
	System::UnicodeString FVersion;
	int FIndent;
	int FOldCursor;
	int FOldScrollPos;
	Graphics::TColor FParamColor;
	Graphics::TColor FSelectionColor;
	Graphics::TColor FSelectionFontColor;
	int FItemHeight;
	Controls::TImageList* FImages;
	Menus::TPopupMenu* FParamPopup;
	Parhtml::TPopupListBox* FParamList;
	Parhtml::TPopupDatePicker* FParamDatePicker;
	Parhtml::TPopupSpinEdit* FParamSpinEdit;
	Parhtml::TPopupEdit* FParamEdit;
	Parhtml::TPopupMaskEdit* FParamMaskEdit;
	System::UnicodeString FOldParam;
	TParamTreeViewChangedEvent FOnParamChanged;
	TParamTreeViewClickEvent FOnParamClick;
	TParamTreeViewHintEvent FOnParamHint;
	TParamTreeViewPopupEvent FOnParamPopup;
	TParamTreeViewPopupEvent FOnParamList;
	TParamTreeViewSelectEvent FOnParamSelect;
	TParamTreeViewSelectEvent FOnParamEnter;
	TParamTreeViewSelectEvent FOnParamExit;
	bool FParamListSorted;
	bool FShowSelection;
	TParamTreeViewClickEvent FOnParamPrepare;
	bool FParamHint;
	Graphics::TColor FShadowColor;
	int FShadowOffset;
	int FUpdateCount;
	bool FWordWrap;
	bool FMouseDown;
	Picturecontainer::TPictureContainer* FContainer;
	System::UnicodeString FCurrCtrlID;
	Types::TRect FCurrCtrlRect;
	Types::TRect FCurrCtrlDown;
	Comctrls::TTreeNode* FHoverNode;
	int FHoverHyperLink;
	Types::TRect FCurrHoverRect;
	Picturecontainer::THTMLPictureCache* FImageCache;
	bool FHover;
	Graphics::TColor FHoverColor;
	Graphics::TColor FHoverFontColor;
	bool FEditAutoSize;
	int FLineSpacing;
	TParamTreeViewEditEvent FOnParamEditStart;
	TParamTreeViewEditEvent FOnParamEditDone;
	System::UnicodeString FEmptyParam;
	System::UnicodeString FOldAnchor;
	int FOldIndex;
	int FFocusLink;
	int FNumHyperLinks;
	System::UnicodeString FEditValue;
	Types::TPoint FEditPos;
	bool FIsEditing;
	TParamTreeViewEditEvent FOnParamQuery;
	TParamCustomEditEvent FOnParamCustomEdit;
	bool FAdvanceOnReturn;
	bool FStopMouseProcessing;
	bool FShowFocusBorder;
	HIDESBASE MESSAGE void __fastcall CMHintShow(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall CMDesignHitTest(Messages::TWMMouse &message);
	MESSAGE void __fastcall CMWantSpecialKey(Messages::TWMKey &Msg);
	HIDESBASE MESSAGE void __fastcall CNNotify(Messages::TWMNotify &message);
	HIDESBASE MESSAGE void __fastcall WMLButtonDown(Messages::TWMMouse &message);
	HIDESBASE MESSAGE void __fastcall WMLButtonUp(Messages::TWMMouse &message);
	HIDESBASE MESSAGE void __fastcall WMMouseMove(Messages::TWMMouse &message);
	HIDESBASE MESSAGE void __fastcall WMHScroll(Messages::TMessage &message);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TMessage &message);
	int __fastcall GetItemHeight(void);
	void __fastcall SetItemHeight(const int Value);
	void __fastcall SetSelectionColor(const Graphics::TColor Value);
	void __fastcall SetSelectionFontColor(const Graphics::TColor Value);
	void __fastcall SetParamColor(const Graphics::TColor Value);
	HIDESBASE void __fastcall SetImages(const Controls::TImageList* Value);
	void __fastcall SetShowSelection(const bool Value);
	System::UnicodeString __fastcall GetNodeParameter(Comctrls::TTreeNode* Node, System::UnicodeString HRef);
	void __fastcall SetNodeParameter(Comctrls::TTreeNode* Node, System::UnicodeString HRef, const System::UnicodeString Value);
	System::UnicodeString __fastcall IsParam(int x, int y, bool GetFocusRect, Comctrls::TTreeNode* &Node, Types::TRect &hr, Types::TRect &cr, System::UnicodeString &CID, System::UnicodeString &CT, System::UnicodeString &CV);
	System::UnicodeString __fastcall HTMLPrep(System::UnicodeString s);
	System::UnicodeString __fastcall InvHTMLPrep(System::UnicodeString s);
	void __fastcall SetShadowColor(const Graphics::TColor Value);
	void __fastcall SetShadowOffset(const int Value);
	void __fastcall SetWordWrap(const bool Value);
	void __fastcall SetLineSpacing(const int Value);
	int __fastcall GetParamItemRefCount(int Item);
	int __fastcall GetParamNodeRefCount(Comctrls::TTreeNode* Node);
	System::UnicodeString __fastcall GetParamItemRefs(int Item, int Index);
	int __fastcall GetParamRefCount(void);
	System::UnicodeString __fastcall GetParamRefs(int Index);
	void __fastcall StartParamEdit(System::UnicodeString param, Comctrls::TTreeNode* Node, const Types::TRect &hr);
	void __fastcall StartParamDir(Comctrls::TTreeNode* Node, System::UnicodeString param, System::UnicodeString curdir, const Types::TRect &hr);
	Types::TRect __fastcall GetParamRect(System::UnicodeString href);
	int __fastcall GetParamNodeIndex(Comctrls::TTreeNode* Node, System::UnicodeString href);
	Comctrls::TTreeNode* __fastcall GetParamRefNode(System::UnicodeString href);
	System::UnicodeString __fastcall GetParameter(System::UnicodeString href);
	void __fastcall SetParameter(System::UnicodeString href, const System::UnicodeString Value);
	void __fastcall SetHover(const bool Value);
	int __fastcall GetParamIndex(System::UnicodeString href);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	
protected:
	virtual int __fastcall GetVersionNr(void);
	virtual void __fastcall HandlePopup(System::TObject* Sender);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall WndProc(Messages::TMessage &Message);
	void __fastcall UpdateParam(System::UnicodeString Param, System::UnicodeString Value);
	void __fastcall PrepareParam(System::UnicodeString Param, System::UnicodeString &Value);
	void __fastcall ControlUpdate(System::TObject* Sender, System::UnicodeString Param, System::UnicodeString Text);
	void __fastcall AdvanceEdit(System::TObject* Sender);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall Change(Comctrls::TTreeNode* Node);
	DYNAMIC void __fastcall Expand(Comctrls::TTreeNode* Node);
	
public:
	__fastcall virtual TParamTreeview(Classes::TComponent* AOwner);
	__fastcall virtual ~TParamTreeview(void);
	virtual void __fastcall BeginUpdate(void);
	virtual void __fastcall EndUpdate(void);
	__property System::UnicodeString NodeParameter[Comctrls::TTreeNode* Node][System::UnicodeString HRef] = {read=GetNodeParameter, write=SetNodeParameter};
	__property int ParamRefCount = {read=GetParamRefCount, nodefault};
	__property System::UnicodeString ParamRefs[int Index] = {read=GetParamRefs};
	__property Comctrls::TTreeNode* ParamRefNode[System::UnicodeString href] = {read=GetParamRefNode};
	__property int ParamNodeRefCount[int Item] = {read=GetParamItemRefCount};
	__property System::UnicodeString ParamNodeRefs[int Item][int Index] = {read=GetParamItemRefs};
	__property int ParamNodeIndex[Comctrls::TTreeNode* Node][System::UnicodeString href] = {read=GetParamNodeIndex};
	__property int ParamIndex[System::UnicodeString href] = {read=GetParamIndex};
	__property System::UnicodeString Parameter[System::UnicodeString href] = {read=GetParameter, write=SetParameter};
	void __fastcall EditParam(System::UnicodeString href);
	bool __fastcall GetParamInfo(Comctrls::TTreeNode* Node, System::UnicodeString HRef, System::UnicodeString &AValue, System::UnicodeString &AClass, System::UnicodeString &AProp, System::UnicodeString &AHint);
	__property Parhtml::TPopupDatePicker* DateTimePicker = {read=FParamDatePicker};
	__property Parhtml::TPopupSpinEdit* SpinEdit = {read=FParamSpinEdit};
	__property Parhtml::TPopupEdit* Editor = {read=FParamEdit};
	__property Parhtml::TPopupMaskEdit* MaskEditor = {read=FParamMaskEdit};
	__property Parhtml::TPopupListBox* ListBox = {read=FParamList};
	__property bool StopMouseProcessing = {read=FStopMouseProcessing, write=FStopMouseProcessing, nodefault};
	
__published:
	__property bool AdvanceOnReturn = {read=FAdvanceOnReturn, write=FAdvanceOnReturn, nodefault};
	__property bool EditAutoSize = {read=FEditAutoSize, write=FEditAutoSize, nodefault};
	__property System::UnicodeString EmptyParam = {read=FEmptyParam, write=FEmptyParam};
	__property Controls::TImageList* HTMLImages = {read=FImages, write=SetImages};
	__property bool Hover = {read=FHover, write=SetHover, default=1};
	__property Graphics::TColor HoverColor = {read=FHoverColor, write=FHoverColor, default=32768};
	__property Graphics::TColor HoverFontColor = {read=FHoverFontColor, write=FHoverFontColor, default=16777215};
	__property int ItemHeight = {read=GetItemHeight, write=SetItemHeight, nodefault};
	__property int LineSpacing = {read=FLineSpacing, write=SetLineSpacing, default=0};
	__property Graphics::TColor SelectionColor = {read=FSelectionColor, write=SetSelectionColor, nodefault};
	__property Graphics::TColor SelectionFontColor = {read=FSelectionFontColor, write=SetSelectionFontColor, nodefault};
	__property bool ShowSelection = {read=FShowSelection, write=SetShowSelection, default=0};
	__property Graphics::TColor ParamColor = {read=FParamColor, write=SetParamColor, default=32768};
	__property bool ParamHint = {read=FParamHint, write=FParamHint, nodefault};
	__property Graphics::TColor ShadowColor = {read=FShadowColor, write=SetShadowColor, nodefault};
	__property int ShadowOffset = {read=FShadowOffset, write=SetShadowOffset, nodefault};
	__property bool ShowFocusBorder = {read=FShowFocusBorder, write=FShowFocusBorder, default=1};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
	__property bool WordWrap = {read=FWordWrap, write=SetWordWrap, nodefault};
	__property TParamTreeViewClickEvent OnParamPrepare = {read=FOnParamPrepare, write=FOnParamPrepare};
	__property TParamTreeViewClickEvent OnParamClick = {read=FOnParamClick, write=FOnParamClick};
	__property TParamTreeViewPopupEvent OnParamPopup = {read=FOnParamPopup, write=FOnParamPopup};
	__property TParamTreeViewPopupEvent OnParamList = {read=FOnParamList, write=FOnParamList};
	__property TParamTreeViewSelectEvent OnParamSelect = {read=FOnParamSelect, write=FOnParamSelect};
	__property TParamTreeViewChangedEvent OnParamChanged = {read=FOnParamChanged, write=FOnParamChanged};
	__property TParamTreeViewHintEvent OnParamHint = {read=FOnParamHint, write=FOnParamHint};
	__property TParamTreeViewSelectEvent OnParamEnter = {read=FOnParamEnter, write=FOnParamEnter};
	__property TParamTreeViewSelectEvent OnParamExit = {read=FOnParamExit, write=FOnParamExit};
	__property TParamTreeViewEditEvent OnParamEditStart = {read=FOnParamEditStart, write=FOnParamEditStart};
	__property TParamTreeViewEditEvent OnParamEditDone = {read=FOnParamEditDone, write=FOnParamEditDone};
	__property TParamCustomEditEvent OnParamCustomEdit = {read=FOnParamCustomEdit, write=FOnParamCustomEdit};
	__property TParamTreeViewEditEvent OnParamQuery = {read=FOnParamQuery, write=FOnParamQuery};
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property AutoExpand = {default=0};
	__property BiDiMode;
	__property BorderWidth = {default=0};
	__property ChangeDelay = {default=0};
	__property Constraints;
	__property DragKind = {default=0};
	__property HotTrack = {default=0};
	__property ParentBiDiMode = {default=1};
	__property RowSelect = {default=0};
	__property OnCustomDraw;
	__property OnCustomDrawItem;
	__property OnEndDock;
	__property OnStartDock;
	__property BorderStyle = {default=1};
	__property Color = {default=-16777211};
	__property Ctl3D;
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property Enabled = {default=1};
	__property Font;
	__property HideSelection = {default=1};
	__property Indent;
	__property Items;
	__property bool ParamListSorted = {read=FParamListSorted, write=FParamListSorted, nodefault};
	__property ParentColor = {default=0};
	__property ParentCtl3D = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property RightClickSelect = {default=0};
	__property ShowButtons = {default=1};
	__property ShowHint;
	__property ShowLines = {default=1};
	__property ShowRoot = {default=1};
	__property SortType = {default=0};
	__property StateImages;
	__property TabOrder = {default=-1};
	__property TabStop = {default=1};
	__property ToolTips = {default=1};
	__property Visible = {default=1};
	__property OnChange;
	__property OnChanging;
	__property OnClick;
	__property OnCollapsing;
	__property OnCollapsed;
	__property OnCompare;
	__property OnDblClick;
	__property OnDeletion;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEdited;
	__property OnEditing;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnExpanding;
	__property OnExpanded;
	__property OnGetImageIndex;
	__property OnGetSelectedIndex;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnStartDrag;
public:
	/* TWinControl.CreateParented */ inline __fastcall TParamTreeview(HWND ParentWindow) : Comctrls::TCustomTreeView(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x3;
static const ShortInt REL_VER = 0x3;
static const ShortInt BLD_VER = 0xa;

}	/* namespace Paramtreeview */
using namespace Paramtreeview;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// ParamtreeviewHPP
