// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxinsp.pas' rev: 21.00

#ifndef FrxinspHPP
#define FrxinspHPP

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
#include <Extctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Frxdsgnintf.hpp>	// Pascal unit
#include <Frxpopupform.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Tabs.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxinsp
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxObjectInspector;
class PASCALIMPLEMENTATION TfrxObjectInspector : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TComboBox* ObjectsCB;
	Menus::TPopupMenu* PopupMenu1;
	Menus::TMenuItem* N11;
	Menus::TMenuItem* N21;
	Menus::TMenuItem* N31;
	Extctrls::TPanel* BackPanel;
	Forms::TScrollBox* Box;
	Extctrls::TPaintBox* PB;
	Stdctrls::TEdit* Edit1;
	Extctrls::TPanel* EditPanel;
	Buttons::TSpeedButton* EditBtn;
	Extctrls::TPanel* ComboPanel;
	Buttons::TSpeedButton* ComboBtn;
	Forms::TScrollBox* HintPanel;
	Extctrls::TSplitter* Splitter1;
	Stdctrls::TLabel* PropL;
	Stdctrls::TLabel* DescrL;
	Menus::TMenuItem* N41;
	Menus::TMenuItem* N51;
	Menus::TMenuItem* N61;
	void __fastcall PBPaint(System::TObject* Sender);
	void __fastcall FormResize(System::TObject* Sender);
	void __fastcall PBMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall PBMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall PBMouseMove(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	void __fastcall Edit1KeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall Edit1KeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall EditBtnClick(System::TObject* Sender);
	void __fastcall ComboBtnClick(System::TObject* Sender);
	void __fastcall Edit1MouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall ObjectsCBClick(System::TObject* Sender);
	void __fastcall ObjectsCBDrawItem(Controls::TWinControl* Control, int Index, const Types::TRect &Rect, Windows::TOwnerDrawState State);
	void __fastcall PBDblClick(System::TObject* Sender);
	void __fastcall FormMouseWheelDown(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall FormMouseWheelUp(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall FormEndDock(System::TObject* Sender, System::TObject* Target, int X, int Y);
	void __fastcall ComboBtnMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall TabChange(System::TObject* Sender);
	void __fastcall N11Click(System::TObject* Sender);
	void __fastcall N21Click(System::TObject* Sender);
	void __fastcall N31Click(System::TObject* Sender);
	void __fastcall FormDeactivate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Frxclass::TfrxCustomDesigner* FDesigner;
	bool FDisableDblClick;
	bool FDisableUpdate;
	bool FDown;
	Frxdsgnintf::TfrxPropertyList* FEventList;
	Controls::THintWindow* FHintWindow;
	int FItemIndex;
	System::UnicodeString FLastPosition;
	Frxdsgnintf::TfrxPropertyList* FList;
	Frxpopupform::TfrxPopupForm* FPopupForm;
	Stdctrls::TListBox* FPopupLB;
	bool FPopupLBVisible;
	Frxdsgnintf::TfrxPropertyList* FPropertyList;
	Extctrls::TPanel* FPanel;
	int FRowHeight;
	Classes::TList* FSelectedObjects;
	int FSplitterPos;
	Tabs::TTabSet* FTabs;
	Graphics::TBitmap* FTempBMP;
	Classes::TList* FTempList;
	unsigned FTickCount;
	bool FUpdatingObjectsCB;
	bool FUpdatingPB;
	Classes::TNotifyEvent FOnSelectionChanged;
	Classes::TNotifyEvent FOnModify;
	int __fastcall Count(void);
	Frxdsgnintf::TfrxPropertyItem* __fastcall GetItem(int Index);
	System::UnicodeString __fastcall GetName(int Index);
	int __fastcall GetOffset(int Index);
	Frxdsgnintf::TfrxPropertyAttributes __fastcall GetType(int Index);
	System::UnicodeString __fastcall GetValue(int Index);
	void __fastcall AdjustControls(void);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Msg);
	void __fastcall DrawOneLine(int i, bool Selected);
	void __fastcall DoModify(void);
	void __fastcall SetObjects(Classes::TList* Value);
	void __fastcall SetItemIndex(int Value);
	void __fastcall SetSelectedObjects(Classes::TList* Value);
	void __fastcall SetValue(int Index, System::UnicodeString Value);
	void __fastcall LBClick(System::TObject* Sender);
	int __fastcall GetSplitter1Pos(void);
	void __fastcall SetSplitter1Pos(const int Value);
	
public:
	__fastcall virtual TfrxObjectInspector(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxObjectInspector(void);
	void __fastcall DisableUpdate(void);
	void __fastcall EnableUpdate(void);
	void __fastcall Inspect(Classes::TPersistent* *AObjects, const int AObjects_Size);
	HIDESBASE void __fastcall SetColor(Graphics::TColor Color);
	void __fastcall UpdateProperties(void);
	__property Classes::TList* Objects = {write=SetObjects};
	__property int ItemIndex = {read=FItemIndex, write=SetItemIndex, nodefault};
	__property Classes::TList* SelectedObjects = {read=FSelectedObjects, write=SetSelectedObjects};
	__property int SplitterPos = {read=FSplitterPos, write=FSplitterPos, nodefault};
	__property int Splitter1Pos = {read=GetSplitter1Pos, write=SetSplitter1Pos, nodefault};
	__property Classes::TNotifyEvent OnModify = {read=FOnModify, write=FOnModify};
	__property Classes::TNotifyEvent OnSelectionChanged = {read=FOnSelectionChanged, write=FOnSelectionChanged};
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxObjectInspector(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxObjectInspector(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxinsp */
using namespace Frxinsp;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxinspHPP
