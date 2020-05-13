// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advlabeledit.pas' rev: 21.00

#ifndef AdvlabeleditHPP
#define AdvlabeleditHPP

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
#include <Dialogs.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Strutils.hpp>	// Pascal unit
#include <Pngimage.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advlabeledit
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


class DELPHICLASS TAdvLabelEditButtons;
class PASCALIMPLEMENTATION TAdvLabelEditButtons : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FHintOK;
	System::UnicodeString FHintCancel;
	System::UnicodeString FHintEdit;
	
public:
	__fastcall TAdvLabelEditButtons(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString HintOK = {read=FHintOK, write=FHintOK};
	__property System::UnicodeString HintCancel = {read=FHintCancel, write=FHintCancel};
	__property System::UnicodeString HintEdit = {read=FHintEdit, write=FHintEdit};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TAdvLabelEditButtons(void) { }
	
};


typedef void __fastcall (__closure *TEditEvent)(System::TObject* Sender, System::UnicodeString &Value);

typedef void __fastcall (__closure *TEditCancelEvent)(System::TObject* Sender, System::UnicodeString Value);

class DELPHICLASS TAdvLabelEdit;
class PASCALIMPLEMENTATION TAdvLabelEdit : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	Stdctrls::TLabel* FLabel;
	TPNGSpeedButton* FEditBtn;
	TPNGSpeedButton* FCancelBtn;
	TPNGSpeedButton* FOKBtn;
	Advedit::TAdvEdit* FEdit;
	bool FEditMode;
	TAdvLabelEditButtons* FButtons;
	Graphics::TColor FHoverColor;
	TEditEvent FOnEditStop;
	TEditEvent FOnEditStart;
	Stdctrls::TEllipsisPosition FEllipsisPosition;
	Classes::TNotifyEvent FOnChange;
	Classes::TNotifyEvent FOnClick;
	Classes::TNotifyEvent FOnDblCLick;
	System::UnicodeString FEmptyText;
	Advedit::TAdvEditType FEditType;
	Advedit::TEditAlign FEditAlign;
	System::UnicodeString FEditPrefix;
	System::UnicodeString FEditSuffix;
	int FEditPrecision;
	int FEditMaxLength;
	bool FEditSigned;
	TEditCancelEvent FOnEditCancel;
	HIDESBASE void __fastcall SetText(const System::UnicodeString Value);
	void __fastcall SetEditMode(const bool Value);
	HIDESBASE System::UnicodeString __fastcall GetText(void);
	void __fastcall SetButtons(const TAdvLabelEditButtons* Value);
	HIDESBASE MESSAGE void __fastcall CMColorChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMEnabledChanged(Messages::TMessage &Message);
	void __fastcall SetEllipsisPosition(const Stdctrls::TEllipsisPosition Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetEmptyText(const System::UnicodeString Value);
	void __fastcall SetEditType(const Advedit::TAdvEditType Value);
	void __fastcall SetEditAlign(const Advedit::TEditAlign Value);
	void __fastcall SetEditPrefix(const System::UnicodeString Value);
	void __fastcall SetEditSuffix(const System::UnicodeString Value);
	void __fastcall SetEditPrecision(const int Value);
	void __fastcall SetEditMaxLength(const int Value);
	void __fastcall SetEditSigned(const bool Value);
	
protected:
	virtual void __fastcall Paint(void);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	virtual void __fastcall DoClick(System::TObject* Sender);
	virtual void __fastcall DoDblClick(System::TObject* Sender);
	virtual void __fastcall DoChange(System::TObject* Sender);
	void __fastcall DoEditClick(System::TObject* Sender);
	void __fastcall DoEditChange(System::TObject* Sender);
	virtual void __fastcall DoEditKeyPress(System::TObject* Sender, System::WideChar &Key);
	virtual void __fastcall DoEditKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall DoEditKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DoOKClick(System::TObject* Sender);
	void __fastcall DoCancelClick(System::TObject* Sender);
	void __fastcall DoLabelEnter(System::TObject* Sender);
	void __fastcall DoLabelLeave(System::TObject* Sender);
	void __fastcall DoLabelClick(System::TObject* Sender);
	void __fastcall DoEditExit(System::TObject* Sender);
	virtual void __fastcall CreateWnd(void);
	DYNAMIC void __fastcall DoEnter(void);
	DYNAMIC void __fastcall DoExit(void);
	virtual void __fastcall SetName(const Classes::TComponentName Value);
	virtual void __fastcall DoEditStart(System::UnicodeString &Value);
	virtual void __fastcall DoEditStop(System::UnicodeString &Value);
	virtual void __fastcall DoEditCancel(System::UnicodeString Value);
	
public:
	__fastcall virtual TAdvLabelEdit(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvLabelEdit(void);
	__property bool EditMode = {read=FEditMode, write=SetEditMode, nodefault};
	__property Advedit::TAdvEdit* Edit = {read=FEdit};
	int __fastcall GetVersionNr(void);
	
__published:
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property BiDiMode;
	__property TAdvLabelEditButtons* Buttons = {read=FButtons, write=SetButtons};
	__property Color = {default=-16777211};
	__property Constraints;
	__property Advedit::TEditAlign EditAlign = {read=FEditAlign, write=SetEditAlign, default=0};
	__property int EditMaxLength = {read=FEditMaxLength, write=SetEditMaxLength, default=0};
	__property System::UnicodeString EditPrefix = {read=FEditPrefix, write=SetEditPrefix};
	__property System::UnicodeString EditSuffix = {read=FEditSuffix, write=SetEditSuffix};
	__property int EditPrecision = {read=FEditPrecision, write=SetEditPrecision, default=0};
	__property bool EditSigned = {read=FEditSigned, write=SetEditSigned, default=0};
	__property Advedit::TAdvEditType EditType = {read=FEditType, write=SetEditType, default=0};
	__property Stdctrls::TEllipsisPosition EllipsisPosition = {read=FEllipsisPosition, write=SetEllipsisPosition, default=0};
	__property System::UnicodeString EmptyText = {read=FEmptyText, write=SetEmptyText};
	__property Enabled = {default=1};
	__property Font;
	__property Hint;
	__property Graphics::TColor HoverColor = {read=FHoverColor, write=FHoverColor, default=8421504};
	__property ParentBiDiMode = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property ShowHint;
	__property System::UnicodeString Text = {read=GetText, write=SetText};
	__property TabOrder = {default=-1};
	__property TabStop = {default=0};
	__property System::UnicodeString Version = {read=GetVersion};
	__property Visible = {default=1};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property Classes::TNotifyEvent OnClick = {read=FOnClick, write=FOnClick};
	__property OnContextPopup;
	__property Classes::TNotifyEvent OnDblClick = {read=FOnDblCLick, write=FOnDblCLick};
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDock;
	__property OnEndDrag;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseLeave;
	__property OnMouseEnter;
	__property TEditCancelEvent OnEditCancel = {read=FOnEditCancel, write=FOnEditCancel};
	__property TEditEvent OnEditStart = {read=FOnEditStart, write=FOnEditStart};
	__property TEditEvent OnEditStop = {read=FOnEditStop, write=FOnEditStop};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvLabelEdit(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x1;
static const ShortInt REL_VER = 0x1;
static const ShortInt BLD_VER = 0x0;

}	/* namespace Advlabeledit */
using namespace Advlabeledit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvlabeleditHPP
