// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdctrl.pas' rev: 21.00

#ifndef FrxdctrlHPP
#define FrxdctrlHPP

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
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Mask.hpp>	// Pascal unit
#include <Checklst.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdctrl
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxDialogControls;
class PASCALIMPLEMENTATION TfrxDialogControls : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxDialogControls(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxDialogControls(void) { }
	
};


class DELPHICLASS TfrxLabelControl;
class PASCALIMPLEMENTATION TfrxLabelControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Stdctrls::TLabel* FLabel;
	Classes::TAlignment __fastcall GetAlignment(void);
	bool __fastcall GetAutoSize(void);
	bool __fastcall GetWordWrap(void);
	void __fastcall SetAlignment(const Classes::TAlignment Value);
	void __fastcall SetAutoSize(const bool Value);
	void __fastcall SetWordWrap(const bool Value);
	
public:
	__fastcall virtual TfrxLabelControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__property Stdctrls::TLabel* LabelCtl = {read=FLabel};
	
__published:
	__property Classes::TAlignment Alignment = {read=GetAlignment, write=SetAlignment, default=0};
	__property bool AutoSize = {read=GetAutoSize, write=SetAutoSize, default=1};
	__property Caption;
	__property Color;
	__property bool WordWrap = {read=GetWordWrap, write=SetWordWrap, default=0};
	__property OnClick;
	__property OnDblClick;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxLabelControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxLabelControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxCustomEditControl;
class PASCALIMPLEMENTATION TfrxCustomEditControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Frxclass::TfrxNotifyEvent FOnChange;
	int __fastcall GetMaxLength(void);
	System::WideChar __fastcall GetPasswordChar(void);
	bool __fastcall GetReadOnly(void);
	System::UnicodeString __fastcall GetText(void);
	void __fastcall DoOnChange(System::TObject* Sender);
	void __fastcall SetMaxLength(const int Value);
	void __fastcall SetPasswordChar(const System::WideChar Value);
	void __fastcall SetReadOnly(const bool Value);
	void __fastcall SetText(const System::UnicodeString Value);
	
protected:
	Stdctrls::TCustomEdit* FCustomEdit;
	
public:
	__fastcall virtual TfrxCustomEditControl(Classes::TComponent* AOwner);
	__property int MaxLength = {read=GetMaxLength, write=SetMaxLength, nodefault};
	__property System::WideChar PasswordChar = {read=GetPasswordChar, write=SetPasswordChar, nodefault};
	__property bool ReadOnly = {read=GetReadOnly, write=SetReadOnly, default=0};
	__property System::UnicodeString Text = {read=GetText, write=SetText};
	__property Frxclass::TfrxNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxCustomEditControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomEditControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxEditControl;
class PASCALIMPLEMENTATION TfrxEditControl : public TfrxCustomEditControl
{
	typedef TfrxCustomEditControl inherited;
	
private:
	Stdctrls::TEdit* FEdit;
	
public:
	__fastcall virtual TfrxEditControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TEdit* Edit = {read=FEdit};
	
__published:
	__property Color;
	__property MaxLength;
	__property PasswordChar;
	__property ReadOnly = {default=0};
	__property TabStop = {default=1};
	__property Text;
	__property OnChange;
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxEditControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxEditControl(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomEditControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxMemoControl;
class PASCALIMPLEMENTATION TfrxMemoControl : public TfrxCustomEditControl
{
	typedef TfrxCustomEditControl inherited;
	
private:
	Stdctrls::TMemo* FMemo;
	Classes::TStrings* __fastcall GetLines(void);
	void __fastcall SetLines(const Classes::TStrings* Value);
	Stdctrls::TScrollStyle __fastcall GetScrollStyle(void);
	bool __fastcall GetWordWrap(void);
	void __fastcall SetScrollStyle(const Stdctrls::TScrollStyle Value);
	void __fastcall SetWordWrap(const bool Value);
	
public:
	__fastcall virtual TfrxMemoControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TMemo* Memo = {read=FMemo};
	
__published:
	__property Color;
	__property Classes::TStrings* Lines = {read=GetLines, write=SetLines};
	__property MaxLength;
	__property ReadOnly = {default=0};
	__property Stdctrls::TScrollStyle ScrollBars = {read=GetScrollStyle, write=SetScrollStyle, default=0};
	__property TabStop = {default=1};
	__property bool WordWrap = {read=GetWordWrap, write=SetWordWrap, default=1};
	__property OnChange;
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxMemoControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxMemoControl(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomEditControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxButtonControl;
class PASCALIMPLEMENTATION TfrxButtonControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Stdctrls::TButton* FButton;
	bool __fastcall GetCancel(void);
	bool __fastcall GetDefault(void);
	Controls::TModalResult __fastcall GetModalResult(void);
	void __fastcall SetCancel(const bool Value);
	void __fastcall SetDefault(const bool Value);
	void __fastcall SetModalResult(const Controls::TModalResult Value);
	bool __fastcall GetWordWrap(void);
	void __fastcall SetWordWrap(const bool Value);
	
public:
	__fastcall virtual TfrxButtonControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TButton* Button = {read=FButton};
	
__published:
	__property bool Cancel = {read=GetCancel, write=SetCancel, default=0};
	__property Caption;
	__property bool Default = {read=GetDefault, write=SetDefault, default=0};
	__property Controls::TModalResult ModalResult = {read=GetModalResult, write=SetModalResult, default=0};
	__property bool WordWrap = {read=GetWordWrap, write=SetWordWrap, default=0};
	__property TabStop = {default=1};
	__property OnClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxButtonControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxButtonControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxCheckBoxControl;
class PASCALIMPLEMENTATION TfrxCheckBoxControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Stdctrls::TCheckBox* FCheckBox;
	Classes::TAlignment __fastcall GetAlignment(void);
	bool __fastcall GetAllowGrayed(void);
	bool __fastcall GetChecked(void);
	Stdctrls::TCheckBoxState __fastcall GetState(void);
	void __fastcall SetAlignment(const Classes::TAlignment Value);
	void __fastcall SetAllowGrayed(const bool Value);
	void __fastcall SetChecked(const bool Value);
	void __fastcall SetState(const Stdctrls::TCheckBoxState Value);
	bool __fastcall GetWordWrap(void);
	void __fastcall SetWordWrap(const bool Value);
	
public:
	__fastcall virtual TfrxCheckBoxControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TCheckBox* CheckBox = {read=FCheckBox};
	
__published:
	__property Classes::TAlignment Alignment = {read=GetAlignment, write=SetAlignment, default=1};
	__property Caption;
	__property bool Checked = {read=GetChecked, write=SetChecked, default=0};
	__property bool AllowGrayed = {read=GetAllowGrayed, write=SetAllowGrayed, default=0};
	__property Stdctrls::TCheckBoxState State = {read=GetState, write=SetState, default=0};
	__property TabStop = {default=1};
	__property bool WordWrap = {read=GetWordWrap, write=SetWordWrap, default=0};
	__property Color;
	__property OnClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxCheckBoxControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCheckBoxControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxRadioButtonControl;
class PASCALIMPLEMENTATION TfrxRadioButtonControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Stdctrls::TRadioButton* FRadioButton;
	Classes::TAlignment __fastcall GetAlignment(void);
	bool __fastcall GetChecked(void);
	void __fastcall SetAlignment(const Classes::TAlignment Value);
	void __fastcall SetChecked(const bool Value);
	bool __fastcall GetWordWrap(void);
	void __fastcall SetWordWrap(const bool Value);
	
public:
	__fastcall virtual TfrxRadioButtonControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TRadioButton* RadioButton = {read=FRadioButton};
	
__published:
	__property Classes::TAlignment Alignment = {read=GetAlignment, write=SetAlignment, default=1};
	__property Caption;
	__property bool Checked = {read=GetChecked, write=SetChecked, default=0};
	__property TabStop = {default=1};
	__property bool WordWrap = {read=GetWordWrap, write=SetWordWrap, default=0};
	__property Color;
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxRadioButtonControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxRadioButtonControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxListBoxControl;
class PASCALIMPLEMENTATION TfrxListBoxControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Stdctrls::TListBox* FListBox;
	Classes::TStrings* __fastcall GetItems(void);
	void __fastcall SetItems(const Classes::TStrings* Value);
	int __fastcall GetItemIndex(void);
	void __fastcall SetItemIndex(const int Value);
	
public:
	__fastcall virtual TfrxListBoxControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TListBox* ListBox = {read=FListBox};
	__property int ItemIndex = {read=GetItemIndex, write=SetItemIndex, nodefault};
	
__published:
	__property Color;
	__property Classes::TStrings* Items = {read=GetItems, write=SetItems};
	__property TabStop = {default=1};
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxListBoxControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxListBoxControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxComboBoxControl;
class PASCALIMPLEMENTATION TfrxComboBoxControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Stdctrls::TComboBox* FComboBox;
	Frxclass::TfrxNotifyEvent FOnChange;
	int __fastcall GetItemIndex(void);
	Classes::TStrings* __fastcall GetItems(void);
	Stdctrls::TComboBoxStyle __fastcall GetStyle(void);
	System::UnicodeString __fastcall GetText(void);
	void __fastcall DoOnChange(System::TObject* Sender);
	void __fastcall SetItemIndex(const int Value);
	void __fastcall SetItems(const Classes::TStrings* Value);
	void __fastcall SetStyle(const Stdctrls::TComboBoxStyle Value);
	void __fastcall SetText(const System::UnicodeString Value);
	
public:
	__fastcall virtual TfrxComboBoxControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TComboBox* ComboBox = {read=FComboBox};
	
__published:
	__property Color;
	__property Classes::TStrings* Items = {read=GetItems, write=SetItems};
	__property Stdctrls::TComboBoxStyle Style = {read=GetStyle, write=SetStyle, default=0};
	__property TabStop = {default=1};
	__property System::UnicodeString Text = {read=GetText, write=SetText};
	__property int ItemIndex = {read=GetItemIndex, write=SetItemIndex, nodefault};
	__property Frxclass::TfrxNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxComboBoxControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxComboBoxControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxPanelControl;
class PASCALIMPLEMENTATION TfrxPanelControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Extctrls::TPanel* FPanel;
	Classes::TAlignment __fastcall GetAlignment(void);
	Controls::TBevelCut __fastcall GetBevelInner(void);
	Controls::TBevelCut __fastcall GetBevelOuter(void);
	int __fastcall GetBevelWidth(void);
	void __fastcall SetAlignment(const Classes::TAlignment Value);
	void __fastcall SetBevelInner(const Controls::TBevelCut Value);
	void __fastcall SetBevelOuter(const Controls::TBevelCut Value);
	void __fastcall SetBevelWidth(const int Value);
	
public:
	__fastcall virtual TfrxPanelControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Extctrls::TPanel* Panel = {read=FPanel};
	
__published:
	__property Classes::TAlignment Alignment = {read=GetAlignment, write=SetAlignment, default=2};
	__property Controls::TBevelCut BevelInner = {read=GetBevelInner, write=SetBevelInner, default=0};
	__property Controls::TBevelCut BevelOuter = {read=GetBevelOuter, write=SetBevelOuter, default=2};
	__property int BevelWidth = {read=GetBevelWidth, write=SetBevelWidth, default=1};
	__property Caption;
	__property Color;
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxPanelControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxPanelControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxGroupBoxControl;
class PASCALIMPLEMENTATION TfrxGroupBoxControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Stdctrls::TGroupBox* FGroupBox;
	
public:
	__fastcall virtual TfrxGroupBoxControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Stdctrls::TGroupBox* GroupBox = {read=FGroupBox};
	
__published:
	__property Caption;
	__property Color;
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxGroupBoxControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxGroupBoxControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDateEditControl;
class PASCALIMPLEMENTATION TfrxDateEditControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Comctrls::TDateTimePicker* FDateEdit;
	Frxclass::TfrxNotifyEvent FOnChange;
	bool FWeekNumbers;
	System::TDate __fastcall GetDate(void);
	System::TTime __fastcall GetTime(void);
	Comctrls::TDTDateFormat __fastcall GetDateFormat(void);
	Comctrls::TDateTimeKind __fastcall GetKind(void);
	void __fastcall DoOnChange(System::TObject* Sender);
	void __fastcall SetDate(const System::TDate Value);
	void __fastcall SetTime(const System::TTime Value);
	void __fastcall SetDateFormat(const Comctrls::TDTDateFormat Value);
	void __fastcall SetKind(const Comctrls::TDateTimeKind Value);
	void __fastcall DropDown(System::TObject* Sender);
	
public:
	__fastcall virtual TfrxDateEditControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Comctrls::TDateTimePicker* DateEdit = {read=FDateEdit};
	
__published:
	__property Color;
	__property System::TDate Date = {read=GetDate, write=SetDate};
	__property Comctrls::TDTDateFormat DateFormat = {read=GetDateFormat, write=SetDateFormat, default=0};
	__property Comctrls::TDateTimeKind Kind = {read=GetKind, write=SetKind, default=0};
	__property TabStop = {default=1};
	__property System::TTime Time = {read=GetTime, write=SetTime};
	__property bool WeekNumbers = {read=FWeekNumbers, write=FWeekNumbers, nodefault};
	__property Frxclass::TfrxNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxDateEditControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDateEditControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxImageControl;
class PASCALIMPLEMENTATION TfrxImageControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Extctrls::TImage* FImage;
	bool __fastcall GetAutoSize(void);
	bool __fastcall GetCenter(void);
	Graphics::TPicture* __fastcall GetPicture(void);
	bool __fastcall GetStretch(void);
	void __fastcall SetAutoSize(const bool Value);
	void __fastcall SetCenter(const bool Value);
	void __fastcall SetPicture(const Graphics::TPicture* Value);
	void __fastcall SetStretch(const bool Value);
	
public:
	__fastcall virtual TfrxImageControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Extctrls::TImage* Image = {read=FImage};
	
__published:
	__property bool AutoSize = {read=GetAutoSize, write=SetAutoSize, default=0};
	__property bool Center = {read=GetCenter, write=SetCenter, default=0};
	__property Graphics::TPicture* Picture = {read=GetPicture, write=SetPicture};
	__property bool Stretch = {read=GetStretch, write=SetStretch, default=0};
	__property OnClick;
	__property OnDblClick;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxImageControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxImageControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxBevelControl;
class PASCALIMPLEMENTATION TfrxBevelControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Extctrls::TBevel* FBevel;
	Extctrls::TBevelShape __fastcall GetBevelShape(void);
	Extctrls::TBevelStyle __fastcall GetBevelStyle(void);
	void __fastcall SetBevelShape(const Extctrls::TBevelShape Value);
	void __fastcall SetBevelStyle(const Extctrls::TBevelStyle Value);
	
public:
	__fastcall virtual TfrxBevelControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Extctrls::TBevel* Bevel = {read=FBevel};
	
__published:
	__property Extctrls::TBevelShape Shape = {read=GetBevelShape, write=SetBevelShape, default=0};
	__property Extctrls::TBevelStyle Style = {read=GetBevelStyle, write=SetBevelStyle, default=0};
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxBevelControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxBevelControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxBitBtnControl;
class PASCALIMPLEMENTATION TfrxBitBtnControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Buttons::TBitBtn* FBitBtn;
	Graphics::TBitmap* __fastcall GetGlyph(void);
	Buttons::TBitBtnKind __fastcall GetKind(void);
	Buttons::TButtonLayout __fastcall GetLayout(void);
	int __fastcall GetMargin(void);
	Controls::TModalResult __fastcall GetModalResult(void);
	int __fastcall GetSpacing(void);
	void __fastcall SetGlyph(const Graphics::TBitmap* Value);
	void __fastcall SetKind(const Buttons::TBitBtnKind Value);
	void __fastcall SetLayout(const Buttons::TButtonLayout Value);
	void __fastcall SetMargin(const int Value);
	void __fastcall SetModalResult(const Controls::TModalResult Value);
	void __fastcall SetSpacing(const int Value);
	int __fastcall GetNumGlyphs(void);
	void __fastcall SetNumGlyphs(const int Value);
	bool __fastcall GetWordWrap(void);
	void __fastcall SetWordWrap(const bool Value);
	
public:
	__fastcall virtual TfrxBitBtnControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Buttons::TBitBtn* BitBtn = {read=FBitBtn};
	
__published:
	__property Graphics::TBitmap* Glyph = {read=GetGlyph, write=SetGlyph};
	__property Buttons::TBitBtnKind Kind = {read=GetKind, write=SetKind, default=0};
	__property Caption;
	__property Buttons::TButtonLayout Layout = {read=GetLayout, write=SetLayout, default=0};
	__property int Margin = {read=GetMargin, write=SetMargin, default=-1};
	__property Controls::TModalResult ModalResult = {read=GetModalResult, write=SetModalResult, default=0};
	__property int NumGlyphs = {read=GetNumGlyphs, write=SetNumGlyphs, default=1};
	__property int Spacing = {read=GetSpacing, write=SetSpacing, default=4};
	__property bool WordWrap = {read=GetWordWrap, write=SetWordWrap, default=0};
	__property TabStop = {default=1};
	__property OnClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxBitBtnControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxBitBtnControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxSpeedButtonControl;
class PASCALIMPLEMENTATION TfrxSpeedButtonControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Buttons::TSpeedButton* FSpeedButton;
	bool __fastcall GetAllowAllUp(void);
	bool __fastcall GetDown(void);
	bool __fastcall GetFlat(void);
	Graphics::TBitmap* __fastcall GetGlyph(void);
	int __fastcall GetGroupIndex(void);
	Buttons::TButtonLayout __fastcall GetLayout(void);
	int __fastcall GetMargin(void);
	int __fastcall GetSpacing(void);
	void __fastcall SetAllowAllUp(const bool Value);
	void __fastcall SetDown(const bool Value);
	void __fastcall SetFlat(const bool Value);
	void __fastcall SetGlyph(const Graphics::TBitmap* Value);
	void __fastcall SetGroupIndex(const int Value);
	void __fastcall SetLayout(const Buttons::TButtonLayout Value);
	void __fastcall SetMargin(const int Value);
	void __fastcall SetSpacing(const int Value);
	
public:
	__fastcall virtual TfrxSpeedButtonControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Buttons::TSpeedButton* SpeedButton = {read=FSpeedButton};
	
__published:
	__property bool AllowAllUp = {read=GetAllowAllUp, write=SetAllowAllUp, default=0};
	__property Caption;
	__property bool Down = {read=GetDown, write=SetDown, default=0};
	__property bool Flat = {read=GetFlat, write=SetFlat, default=0};
	__property Graphics::TBitmap* Glyph = {read=GetGlyph, write=SetGlyph};
	__property int GroupIndex = {read=GetGroupIndex, write=SetGroupIndex, nodefault};
	__property Buttons::TButtonLayout Layout = {read=GetLayout, write=SetLayout, default=0};
	__property int Margin = {read=GetMargin, write=SetMargin, default=-1};
	__property int Spacing = {read=GetSpacing, write=SetSpacing, default=4};
	__property OnClick;
	__property OnDblClick;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxSpeedButtonControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxSpeedButtonControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxMaskEditControl;
class PASCALIMPLEMENTATION TfrxMaskEditControl : public TfrxCustomEditControl
{
	typedef TfrxCustomEditControl inherited;
	
private:
	Mask::TMaskEdit* FMaskEdit;
	System::UnicodeString __fastcall GetEditMask(void);
	void __fastcall SetEditMask(const System::UnicodeString Value);
	
public:
	__fastcall virtual TfrxMaskEditControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Mask::TMaskEdit* MaskEdit = {read=FMaskEdit};
	
__published:
	__property Color;
	__property System::UnicodeString EditMask = {read=GetEditMask, write=SetEditMask};
	__property MaxLength;
	__property ReadOnly = {default=0};
	__property TabStop = {default=1};
	__property Text;
	__property OnChange;
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxMaskEditControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxMaskEditControl(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomEditControl(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxCheckListBoxControl;
class PASCALIMPLEMENTATION TfrxCheckListBoxControl : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Checklst::TCheckListBox* FCheckListBox;
	bool __fastcall GetAllowGrayed(void);
	Classes::TStrings* __fastcall GetItems(void);
	bool __fastcall GetSorted(void);
	bool __fastcall GetChecked(int Index);
	Stdctrls::TCheckBoxState __fastcall GetState(int Index);
	void __fastcall SetAllowGrayed(const bool Value);
	void __fastcall SetItems(const Classes::TStrings* Value);
	void __fastcall SetSorted(const bool Value);
	void __fastcall SetChecked(int Index, const bool Value);
	void __fastcall SetState(int Index, const Stdctrls::TCheckBoxState Value);
	int __fastcall GetItemIndex(void);
	void __fastcall SetItemIndex(const int Value);
	
public:
	__fastcall virtual TfrxCheckListBoxControl(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Checklst::TCheckListBox* CheckListBox = {read=FCheckListBox};
	__property bool Checked[int Index] = {read=GetChecked, write=SetChecked};
	__property int ItemIndex = {read=GetItemIndex, write=SetItemIndex, nodefault};
	__property Stdctrls::TCheckBoxState State[int Index] = {read=GetState, write=SetState};
	
__published:
	__property bool AllowGrayed = {read=GetAllowGrayed, write=SetAllowGrayed, default=0};
	__property Color;
	__property Classes::TStrings* Items = {read=GetItems, write=SetItems};
	__property bool Sorted = {read=GetSorted, write=SetSorted, default=0};
	__property TabStop = {default=1};
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxDialogControl.Destroy */ inline __fastcall virtual ~TfrxCheckListBoxControl(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCheckListBoxControl(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxdctrl */
using namespace Frxdctrl;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdctrlHPP
