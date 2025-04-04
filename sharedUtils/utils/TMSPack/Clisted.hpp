// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Clisted.pas' rev: 21.00

#ifndef ClistedHPP
#define ClistedHPP

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
#include <Checklst.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Cexpvs.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Clisted
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TDropForm;
class PASCALIMPLEMENTATION TDropForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
private:
	HIDESBASE MESSAGE void __fastcall WMClose(Messages::TMessage &Msg);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TDropForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TDropForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TDropForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TDropForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TIntList;
class PASCALIMPLEMENTATION TIntList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	int operator[](int index) { return Items[index]; }
	
private:
	void __fastcall SetInteger(int Index, int Value);
	int __fastcall GetInteger(int Index);
	
public:
	__fastcall TIntList(void);
	__property int Items[int index] = {read=GetInteger, write=SetInteger/*, default*/};
	HIDESBASE void __fastcall Add(int Value);
	HIDESBASE void __fastcall Delete(int Index);
public:
	/* TList.Destroy */ inline __fastcall virtual ~TIntList(void) { }
	
};


class DELPHICLASS TInplaceCheckListBox;
class DELPHICLASS TCheckListEdit;
class PASCALIMPLEMENTATION TInplaceCheckListBox : public Checklst::TCheckListBox
{
	typedef Checklst::TCheckListBox inherited;
	
private:
	TCheckListEdit* FParentEdit;
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Msg);
	
protected:
	DYNAMIC void __fastcall DoExit(void);
	int __fastcall GetDropDownWidth(void);
	__property TCheckListEdit* ParentEdit = {read=FParentEdit, write=FParentEdit};
public:
	/* TCheckListBox.Create */ inline __fastcall virtual TInplaceCheckListBox(Classes::TComponent* AOwner) : Checklst::TCheckListBox(AOwner) { }
	/* TCheckListBox.Destroy */ inline __fastcall virtual ~TInplaceCheckListBox(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TInplaceCheckListBox(HWND ParentWindow) : Checklst::TCheckListBox(ParentWindow) { }
	
};


class DELPHICLASS TDropCheckListButton;
class PASCALIMPLEMENTATION TDropCheckListButton : public Buttons::TSpeedButton
{
	typedef Buttons::TSpeedButton inherited;
	
private:
	Controls::TWinControl* FFocusControl;
	Classes::TNotifyEvent FMouseClick;
	bool FIsWinXP;
	bool FHover;
	HIDESBASE MESSAGE void __fastcall WMLButtonDown(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall CMMouseEnter(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Msg);
	
protected:
	virtual void __fastcall Paint(void);
	__property bool Hover = {read=FHover, write=FHover, nodefault};
	
public:
	DYNAMIC void __fastcall Click(void);
	__fastcall virtual TDropCheckListButton(Classes::TComponent* AOwner);
	__property bool IsWinXP = {read=FIsWinXP, write=FIsWinXP, nodefault};
	
__published:
	__property Controls::TWinControl* FocusControl = {read=FFocusControl, write=FFocusControl};
	__property Classes::TNotifyEvent MouseClick = {read=FMouseClick, write=FMouseClick};
public:
	/* TSpeedButton.Destroy */ inline __fastcall virtual ~TDropCheckListButton(void) { }
	
};


typedef void __fastcall (__closure *TCheckListItemToText)(System::TObject* sender, System::UnicodeString &aText);

typedef void __fastcall (__closure *TTextToCheckListItem)(System::TObject* sender, System::UnicodeString &aItem);

#pragma option push -b-
enum TDropDirection { ddDown, ddUp };
#pragma option pop

class PASCALIMPLEMENTATION TCheckListEdit : public Stdctrls::TCustomEdit
{
	typedef Stdctrls::TCustomEdit inherited;
	
private:
	TDropCheckListButton* FButton;
	bool FEditorEnabled;
	Classes::TNotifyEvent FOnClickBtn;
	TInplaceCheckListBox* FCheckListBox;
	Classes::TStringList* FItems;
	int FDropHeight;
	int FDropWidth;
	int FDropColumns;
	Graphics::TColor FDropColor;
	Graphics::TFont* FDropFont;
	bool FDropFlat;
	bool FDropSorted;
	TDropDirection FDropDirection;
	bool FDroppedDown;
	bool FDropDownEnabled;
	bool CheckFlag;
	Forms::TForm* FChkForm;
	TIntList* FIntList;
	bool FChkClosed;
	bool FCloseClick;
	System::UnicodeString FTextDelimiter;
	System::UnicodeString FTextStartChar;
	System::UnicodeString FTextEndChar;
	int FUpdateCount;
	TCheckListItemToText FOnCheckListItemToText;
	TTextToCheckListItem FOnTextToCheckListItem;
	Classes::TNotifyEvent FOnClose;
	bool FAutoDropWidthSize;
	Classes::TNotifyEvent FAppNtfy;
	Menus::TPopupMenu* FDropDownPopupMenu;
	Classes::TNotifyEvent FOnShowCheckList;
	Classes::TNotifyEvent FOnClickCheck;
	bool __fastcall GetItemEnabled(int ItemIndex);
	void __fastcall SetItemEnabled(int ItemIndex, const bool Value);
	int __fastcall GetMinHeight(void);
	void __fastcall SetEditRect(void);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Msg);
	HIDESBASE MESSAGE void __fastcall CMEnter(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall CMExit(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Message);
	MESSAGE void __fastcall WMPaste(Messages::TWMNoParams &Message);
	MESSAGE void __fastcall WMCut(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMKeyDown(Messages::TWMKey &Msg);
	HIDESBASE MESSAGE void __fastcall WMChar(Messages::TWMKey &Message);
	HIDESBASE MESSAGE void __fastcall WMSysKeyDown(Messages::TWMKey &Msg);
	void __fastcall ItemChange(System::TObject* Sender);
	void __fastcall CheckClick(System::TObject* Sender);
	void __fastcall CheckClickCheck(System::TObject* Sender);
	void __fastcall SetItems(Classes::TStringList* value);
	void __fastcall ShowCheckListInt(bool Focus, System::UnicodeString startchar);
	bool __fastcall GetCheck(int i);
	void __fastcall SetCheck(int i, bool value);
	Stdctrls::TCheckBoxState __fastcall GetState(int i);
	void __fastcall SetState(int i, Stdctrls::TCheckBoxState value);
	void __fastcall FormDeactivate(System::TObject* Sender);
	void __fastcall AppDeactivate(System::TObject* Sender);
	void __fastcall SetTextDelimiter(const System::UnicodeString Value);
	void __fastcall SetTextEndChar(const System::UnicodeString Value);
	void __fastcall SetTextStartChar(const System::UnicodeString Value);
	void __fastcall MouseClick(System::TObject* Sender);
	void __fastcall DownClick(System::TObject* Sender);
	void __fastcall SetDropFont(const Graphics::TFont* Value);
	HIDESBASE System::UnicodeString __fastcall GetText(void);
	HIDESBASE void __fastcall SetText(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	bool __fastcall GetSelected(int Index);
	void __fastcall SetSelected(int Index, const bool Value);
	
protected:
	DYNAMIC void __fastcall Change(void);
	virtual int __fastcall GetVersionNr(void);
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall DestroyWnd(void);
	virtual Forms::TCustomForm* __fastcall GetParentForm(Controls::TControl* Control);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	virtual void __fastcall DoClickCheck(System::TObject* Sender);
	virtual System::UnicodeString __fastcall CheckToString(void);
	virtual void __fastcall StringToCheck(System::UnicodeString s);
	virtual void __fastcall DoOnShowCheckList(void);
	
public:
	__fastcall virtual TCheckListEdit(Classes::TComponent* AOwner);
	__fastcall virtual ~TCheckListEdit(void);
	virtual void __fastcall Loaded(void);
	__property bool ItemEnabled[int ItemIndex] = {read=GetItemEnabled, write=SetItemEnabled};
	void __fastcall CheckAll(void);
	void __fastcall UnCheckAll(void);
	__property TDropCheckListButton* Button = {read=FButton};
	__property bool Checked[int i] = {read=GetCheck, write=SetCheck};
	__property Stdctrls::TCheckBoxState State[int i] = {read=GetState, write=SetState};
	__property System::UnicodeString Text = {read=GetText, write=SetText};
	__property bool DroppedDown = {read=FDroppedDown, nodefault};
	__property bool Selected[int Index] = {read=GetSelected, write=SetSelected};
	void __fastcall ShowCheckList(void);
	void __fastcall HideCheckList(void);
	void __fastcall BeginUpdate(void);
	void __fastcall EndUpdate(void);
	
__published:
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property Constraints;
	__property DragKind = {default=0};
	__property AutoSelect = {default=1};
	__property AutoSize = {default=1};
	__property bool AutoDropWidthSize = {read=FAutoDropWidthSize, write=FAutoDropWidthSize, nodefault};
	__property BorderStyle = {default=1};
	__property Color = {default=-16777211};
	__property Ctl3D;
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property bool EditorEnabled = {read=FEditorEnabled, write=FEditorEnabled, default=1};
	__property Enabled = {default=1};
	__property Font;
	__property MaxLength = {default=0};
	__property ParentColor = {default=0};
	__property ParentCtl3D = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=1};
	__property Visible = {default=1};
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
	__property OnEndDock;
	__property OnStartDock;
	__property Classes::TStringList* Items = {read=FItems, write=SetItems};
	__property int DropWidth = {read=FDropWidth, write=FDropWidth, nodefault};
	__property int DropHeight = {read=FDropHeight, write=FDropHeight, default=100};
	__property int DropColumns = {read=FDropColumns, write=FDropColumns, default=0};
	__property Graphics::TColor DropColor = {read=FDropColor, write=FDropColor, default=-16777211};
	__property bool DropFlat = {read=FDropFlat, write=FDropFlat, default=1};
	__property Graphics::TFont* DropFont = {read=FDropFont, write=SetDropFont};
	__property TDropDirection DropDirection = {read=FDropDirection, write=FDropDirection, default=0};
	__property bool DropSorted = {read=FDropSorted, write=FDropSorted, default=0};
	__property bool DropDownEnabled = {read=FDropDownEnabled, write=FDropDownEnabled, default=1};
	__property Menus::TPopupMenu* DropDownPopupMenu = {read=FDropDownPopupMenu, write=FDropDownPopupMenu};
	__property System::UnicodeString TextDelimiter = {read=FTextDelimiter, write=SetTextDelimiter};
	__property System::UnicodeString TextEndChar = {read=FTextEndChar, write=SetTextEndChar};
	__property System::UnicodeString TextStartChar = {read=FTextStartChar, write=SetTextStartChar};
	__property Classes::TNotifyEvent OnClose = {read=FOnClose, write=FOnClose};
	__property Classes::TNotifyEvent OnClickBtn = {read=FOnClickBtn, write=FOnClickBtn};
	__property Classes::TNotifyEvent OnClickCheck = {read=FOnClickCheck, write=FOnClickCheck};
	__property TTextToCheckListItem OnTextToCheckListItem = {read=FOnTextToCheckListItem, write=FOnTextToCheckListItem};
	__property TCheckListItemToText OnCheckListItemToText = {read=FOnCheckListItemToText, write=FOnCheckListItemToText};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
	__property Classes::TNotifyEvent OnShowCheckList = {read=FOnShowCheckList, write=FOnShowCheckList};
public:
	/* TWinControl.CreateParented */ inline __fastcall TCheckListEdit(HWND ParentWindow) : Stdctrls::TCustomEdit(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt CL_CHECKED = 0x8;
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x3;
static const ShortInt REL_VER = 0x9;
static const ShortInt BLD_VER = 0x0;
extern PACKAGE void __fastcall Register(void);

}	/* namespace Clisted */
using namespace Clisted;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// ClistedHPP
