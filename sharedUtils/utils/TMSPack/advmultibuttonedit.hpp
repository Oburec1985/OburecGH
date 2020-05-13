// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advmultibuttonedit.pas' rev: 21.00

#ifndef AdvmultibuttoneditHPP
#define AdvmultibuttoneditHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Advedit.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Pngimage.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advmultibuttonedit
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TPNGSpeedButton;
class PASCALIMPLEMENTATION TPNGSpeedButton : public Buttons::TSpeedButton
{
	typedef Buttons::TSpeedButton inherited;
	
private:
	System::UnicodeString FPNGName;
	void __fastcall SetPNGName(const System::UnicodeString Value);
	
protected:
	virtual void __fastcall Paint(void);
	
__published:
	__property System::UnicodeString PNGName = {read=FPNGName, write=SetPNGName};
public:
	/* TSpeedButton.Create */ inline __fastcall virtual TPNGSpeedButton(Classes::TComponent* AOwner) : Buttons::TSpeedButton(AOwner) { }
	/* TSpeedButton.Destroy */ inline __fastcall virtual ~TPNGSpeedButton(void) { }
	
};


#pragma option push -b-
enum TButtonPosition { bpLeft, bpRight };
#pragma option pop

#pragma option push -b-
enum TButtonStyle { bsClear, bsFind, bsOK, bsTrash, bsAccept, bsDeny, bsClose, bsCopy, bsPrevious, bsNext, bsUndo, bsAdd, bsSub, bsCustom };
#pragma option pop

class DELPHICLASS TEditButton;
class PASCALIMPLEMENTATION TEditButton : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	TButtonPosition FButtonPosition;
	TPNGSpeedButton* FButton;
	bool FEnabled;
	bool FFlat;
	TButtonStyle FStyle;
	int FImageIndex;
	System::UnicodeString FHint;
	void __fastcall SetButtonPosition(const TButtonPosition Value);
	void __fastcall SetEnabled(const bool Value);
	void __fastcall SetFlat(const bool Value);
	void __fastcall SetImageIndex(const int Value);
	void __fastcall SetStyle(const TButtonStyle Value);
	void __fastcall SetHint(const System::UnicodeString Value);
	
public:
	__fastcall virtual TEditButton(Classes::TCollection* Collection);
	__fastcall virtual ~TEditButton(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TPNGSpeedButton* Button = {read=FButton};
	
__published:
	__property bool Enabled = {read=FEnabled, write=SetEnabled, default=1};
	__property bool Flat = {read=FFlat, write=SetFlat, default=0};
	__property System::UnicodeString Hint = {read=FHint, write=SetHint};
	__property int ImageIndex = {read=FImageIndex, write=SetImageIndex, default=-1};
	__property TButtonPosition Position = {read=FButtonPosition, write=SetButtonPosition, default=1};
	__property TButtonStyle Style = {read=FStyle, write=SetStyle, default=13};
};


class DELPHICLASS TEditButtons;
class DELPHICLASS TAdvMultiButtonEdit;
class PASCALIMPLEMENTATION TEditButtons : public Classes::TOwnedCollection
{
	typedef Classes::TOwnedCollection inherited;
	
public:
	TEditButton* operator[](int Index) { return Items[Index]; }
	
private:
	TAdvMultiButtonEdit* FEdit;
	HIDESBASE TEditButton* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TEditButton* Value);
	
protected:
	virtual void __fastcall Update(Classes::TCollectionItem* Item);
	
public:
	__fastcall TEditButtons(Classes::TPersistent* AOwner);
	__property TEditButton* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
	HIDESBASE TEditButton* __fastcall Add(void);
	HIDESBASE TEditButton* __fastcall Insert(int Index);
	TEditButton* __fastcall FindButton(TButtonStyle AStyle);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TEditButtons(void) { }
	
};


typedef void __fastcall (__closure *TButtonClickEvent)(System::TObject* Sender, int ButtonIndex);

class DELPHICLASS TAdvCustomMultiButtonEdit;
class PASCALIMPLEMENTATION TAdvCustomMultiButtonEdit : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	Advedit::TAdvEdit* FEdit;
	TEditButtons* FEditButtons;
	Imglist::TCustomImageList* FImages;
	Classes::TNotifyEvent FOnClickOK;
	TButtonClickEvent FOnClickCustom;
	Classes::TNotifyEvent FOnClickClear;
	Classes::TNotifyEvent FOnClickFind;
	Classes::TNotifyEvent FOnClickDeny;
	Classes::TNotifyEvent FOnClickClose;
	Classes::TNotifyEvent FOnClickTrash;
	Classes::TNotifyEvent FOnClickAccept;
	Classes::TNotifyEvent FOnClickCopy;
	Classes::TNotifyEvent FOnClickPrevious;
	Classes::TNotifyEvent FOnClickNext;
	Classes::TNotifyEvent FOnClickUndo;
	Classes::TNotifyEvent FOnChange;
	Classes::TNotifyEvent FOnClickAdd;
	Classes::TNotifyEvent FOnClickSub;
	Forms::TFormBorderStyle FBorderStyle;
	Classes::TNotifyEvent FOnDblClick;
	Graphics::TColor FEditColor;
	Stdctrls::TEditCharCase FCharCase;
	bool FHideSelection;
	int FMaxLength;
	bool FReadOnly;
	System::UnicodeString FEmptyText;
	bool FEmptyTextFocused;
	HIDESBASE void __fastcall SetText(const System::UnicodeString Value);
	void __fastcall SetButtons(const TEditButtons* Value);
	HIDESBASE System::UnicodeString __fastcall GetText(void);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetBorderStyle(const Forms::TBorderStyle Value);
	HIDESBASE MESSAGE void __fastcall CMColorChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMBiDiModeChanged(Messages::TMessage &Message);
	void __fastcall SetEditColor(const Graphics::TColor Value);
	void __fastcall SetCharCase(const Stdctrls::TEditCharCase Value);
	void __fastcall SetHideSelection(const bool Value);
	void __fastcall SetMaxLength(const int Value);
	void __fastcall SetReadOnly(const bool Value);
	void __fastcall SetEmptyText(const System::UnicodeString Value);
	void __fastcall SetEmptyTextFocused(const bool Value);
	
protected:
	virtual void __fastcall ButtonClick(System::TObject* Sender);
	virtual void __fastcall DoClickButton(int ButtonIndex);
	virtual void __fastcall DoClickSub(void);
	virtual void __fastcall DoClickAdd(void);
	virtual void __fastcall DoClickFind(void);
	virtual void __fastcall DoClickClear(void);
	virtual void __fastcall DoClickOK(void);
	virtual void __fastcall DoClickClose(void);
	virtual void __fastcall DoClickCopy(void);
	virtual void __fastcall DoClickAccept(void);
	virtual void __fastcall DoClickDeny(void);
	virtual void __fastcall DoClickTrash(void);
	virtual void __fastcall DoClickNext(void);
	virtual void __fastcall DoClickPrevious(void);
	virtual void __fastcall DoClickUndo(void);
	virtual void __fastcall DoEditChange(System::TObject* Sender);
	virtual void __fastcall DoEditKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall DoEditKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall DoEditKeypress(System::TObject* Sender, System::WideChar &Key);
	virtual void __fastcall DoEditEnter(System::TObject* Sender);
	virtual void __fastcall DoEditExit(System::TObject* Sender);
	virtual void __fastcall DoEditDblClick(System::TObject* Sender);
	virtual void __fastcall DoEditClick(System::TObject* Sender);
	virtual void __fastcall CreateWnd(void);
	DYNAMIC void __fastcall DoEnter(void);
	virtual TEditButtons* __fastcall CreateButtons(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	void __fastcall UpdateButtons(void);
	__property TEditButtons* Buttons = {read=FEditButtons, write=SetButtons};
	__property Classes::TNotifyEvent OnClickAdd = {read=FOnClickAdd, write=FOnClickAdd};
	__property Classes::TNotifyEvent OnClickSub = {read=FOnClickSub, write=FOnClickSub};
	__property Classes::TNotifyEvent OnClickFind = {read=FOnClickFind, write=FOnClickFind};
	__property Classes::TNotifyEvent OnClickClear = {read=FOnClickClear, write=FOnClickClear};
	__property Classes::TNotifyEvent OnClickOK = {read=FOnClickOK, write=FOnClickOK};
	__property Classes::TNotifyEvent OnClickTrash = {read=FOnClickTrash, write=FOnClickTrash};
	__property Classes::TNotifyEvent OnClickAccept = {read=FOnClickAccept, write=FOnClickAccept};
	__property Classes::TNotifyEvent OnClickDeny = {read=FOnClickDeny, write=FOnClickDeny};
	__property Classes::TNotifyEvent OnClickClose = {read=FOnClickClose, write=FOnClickClose};
	__property Classes::TNotifyEvent OnClickCopy = {read=FOnClickCopy, write=FOnClickCopy};
	__property Classes::TNotifyEvent OnClickNext = {read=FOnClickNext, write=FOnClickNext};
	__property Classes::TNotifyEvent OnClickPrevious = {read=FOnClickPrevious, write=FOnClickPrevious};
	__property Classes::TNotifyEvent OnClickUndo = {read=FOnClickUndo, write=FOnClickUndo};
	__property TButtonClickEvent OnClickCustom = {read=FOnClickCustom, write=FOnClickCustom};
	
public:
	__fastcall virtual TAdvCustomMultiButtonEdit(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvCustomMultiButtonEdit(void);
	int __fastcall GetVersionNr(void);
	__property Advedit::TAdvEdit* Edit = {read=FEdit};
	
__published:
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property Color = {default=-16777211};
	__property Constraints;
	__property BiDiMode;
	__property Forms::TBorderStyle BorderStyle = {read=FBorderStyle, write=SetBorderStyle, default=1};
	__property Stdctrls::TEditCharCase CharCase = {read=FCharCase, write=SetCharCase, default=0};
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property DragKind = {default=0};
	__property Graphics::TColor EditColor = {read=FEditColor, write=SetEditColor, default=-16777211};
	__property System::UnicodeString EmptyText = {read=FEmptyText, write=SetEmptyText};
	__property bool EmptyTextFocused = {read=FEmptyTextFocused, write=SetEmptyTextFocused, nodefault};
	__property Enabled = {default=1};
	__property Font;
	__property bool HideSelection = {read=FHideSelection, write=SetHideSelection, default=1};
	__property Hint;
	__property Imglist::TCustomImageList* Images = {read=FImages, write=FImages};
	__property int MaxLength = {read=FMaxLength, write=SetMaxLength, default=0};
	__property ParentCtl3D = {default=1};
	__property ParentColor = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property bool ReadOnly = {read=FReadOnly, write=SetReadOnly, default=0};
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=0};
	__property System::UnicodeString Text = {read=GetText, write=SetText};
	__property System::UnicodeString Version = {read=GetVersion};
	__property Visible = {default=1};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property OnClick;
	__property OnContextPopup;
	__property Classes::TNotifyEvent OnDblClick = {read=FOnDblClick, write=FOnDblClick};
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDock;
	__property OnEndDrag;
	__property OnKeyPress;
	__property OnKeyDown;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseUp;
	__property OnMouseMove;
	__property OnMouseLeave;
	__property OnMouseEnter;
	__property OnEnter;
	__property OnExit;
	__property OnStartDock;
	__property OnStartDrag;
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvCustomMultiButtonEdit(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
};


class PASCALIMPLEMENTATION TAdvMultiButtonEdit : public TAdvCustomMultiButtonEdit
{
	typedef TAdvCustomMultiButtonEdit inherited;
	
__published:
	__property Buttons;
	__property OnClickAdd;
	__property OnClickFind;
	__property OnClickClear;
	__property OnClickOK;
	__property OnClickTrash;
	__property OnClickAccept;
	__property OnClickDeny;
	__property OnClickClose;
	__property OnClickCopy;
	__property OnClickNext;
	__property OnClickPrevious;
	__property OnClickUndo;
	__property OnClickCustom;
public:
	/* TAdvCustomMultiButtonEdit.Create */ inline __fastcall virtual TAdvMultiButtonEdit(Classes::TComponent* AOwner) : TAdvCustomMultiButtonEdit(AOwner) { }
	/* TAdvCustomMultiButtonEdit.Destroy */ inline __fastcall virtual ~TAdvMultiButtonEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvMultiButtonEdit(HWND ParentWindow) : TAdvCustomMultiButtonEdit(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x0;
static const ShortInt REL_VER = 0x0;
static const ShortInt BLD_VER = 0x3;

}	/* namespace Advmultibuttonedit */
using namespace Advmultibuttonedit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvmultibuttoneditHPP
