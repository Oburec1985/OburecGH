// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdesgnworkspace1.pas' rev: 21.00

#ifndef Frxdesgnworkspace1HPP
#define Frxdesgnworkspace1HPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Frxdesgn.hpp>	// Pascal unit
#include <Frxdesgnworkspace.hpp>	// Pascal unit
#include <Frxpopupform.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdesgnworkspace1
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxDesignTool { dtSelect, dtHand, dtZoom, dtText, dtFormat };
#pragma option pop

class DELPHICLASS TfrxGuideItem;
class PASCALIMPLEMENTATION TfrxGuideItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	System::Extended Left;
	System::Extended Top;
	System::Extended Right;
	System::Extended Bottom;
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxGuideItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxGuideItem(void) { }
	
};


class DELPHICLASS TfrxVirtualGuides;
class PASCALIMPLEMENTATION TfrxVirtualGuides : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxGuideItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxGuideItem* __fastcall GetGuides(int Index);
	
public:
	__fastcall TfrxVirtualGuides(void);
	HIDESBASE void __fastcall Add(System::Extended Left, System::Extended Top, System::Extended Right, System::Extended Bottom);
	__property TfrxGuideItem* Items[int Index] = {read=GetGuides/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxVirtualGuides(void) { }
	
};


class DELPHICLASS TDesignerWorkspace;
class PASCALIMPLEMENTATION TDesignerWorkspace : public Frxdesgnworkspace::TfrxDesignerWorkspace
{
	typedef Frxdesgnworkspace::TfrxDesignerWorkspace inherited;
	
private:
	Frxdesgn::TfrxDesignerForm* FDesigner;
	int FGuide;
	Stdctrls::TListBox* FListBox;
	Frxclass::TfrxMemoView* FMemo;
	Frxpopupform::TfrxPopupForm* FPopupForm;
	bool FPopupFormVisible;
	bool FShowGuides;
	bool FSimulateMove;
	TfrxDesignTool FTool;
	TfrxVirtualGuides* FVirtualGuides;
	Classes::TList* FVirtualGuideObjects;
	void __fastcall DoLBClick(System::TObject* Sender);
	void __fastcall DoPopupHide(System::TObject* Sender);
	void __fastcall CreateVirtualGuides(void);
	void __fastcall LBDrawItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	void __fastcall SetShowGuides(const bool Value);
	void __fastcall SetHGuides(const Classes::TStrings* Value);
	void __fastcall SetVGuides(const Classes::TStrings* Value);
	Classes::TStrings* __fastcall GetHGuides(void);
	Classes::TStrings* __fastcall GetVGuides(void);
	__property Classes::TStrings* HGuides = {read=GetHGuides, write=SetHGuides};
	__property Classes::TStrings* VGuides = {read=GetVGuides, write=SetVGuides};
	void __fastcall SetTool(const TfrxDesignTool Value);
	
protected:
	virtual void __fastcall CheckGuides(System::Extended &kx, System::Extended &ky, bool &Result);
	DYNAMIC void __fastcall DragOver(System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	virtual void __fastcall DrawObjects(void);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall DblClick(void);
	
public:
	__fastcall virtual TDesignerWorkspace(Classes::TComponent* AOwner);
	__fastcall virtual ~TDesignerWorkspace(void);
	virtual void __fastcall DeleteObjects(void);
	DYNAMIC void __fastcall DragDrop(System::TObject* Source, int X, int Y);
	void __fastcall SimulateMove(void);
	virtual void __fastcall SetInsertion(Frxclass::TfrxComponentClass AClass, System::Extended AWidth, System::Extended AHeight, System::Word AFlag);
	__property bool ShowGuides = {read=FShowGuides, write=SetShowGuides, nodefault};
	__property TfrxDesignTool Tool = {read=FTool, write=SetTool, nodefault};
public:
	/* TWinControl.CreateParented */ inline __fastcall TDesignerWorkspace(HWND ParentWindow) : Frxdesgnworkspace::TfrxDesignerWorkspace(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxdesgnworkspace1 */
using namespace Frxdesgnworkspace1;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Frxdesgnworkspace1HPP
