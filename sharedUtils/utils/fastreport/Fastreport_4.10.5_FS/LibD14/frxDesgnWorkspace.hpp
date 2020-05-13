// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdesgnworkspace.pas' rev: 21.00

#ifndef FrxdesgnworkspaceHPP
#define FrxdesgnworkspaceHPP

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
#include <Frxunicodectrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdesgnworkspace
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxDesignMode { dmSelect, dmInsert, dmDrag };
#pragma option pop

#pragma option push -b-
enum TfrxDesignMode1 { dmNone, dmMove, dmSize, dmSizeBand, dmScale, dmInplaceEdit, dmSelectionRect, dmInsertObject, dmInsertLine, dmMoveGuide, dmContainer };
#pragma option pop

#pragma option push -b-
enum TfrxGridType { gt1pt, gt1cm, gt1in, gtDialog, gtChar, gtNone };
#pragma option pop

#pragma option push -b-
enum TfrxCursorType { ct0, ct1, ct2, ct3, ct4, ct5, ct6, ct7, ct8, ct9, ct10 };
#pragma option pop

typedef void __fastcall (__closure *TfrxNotifyPositionEvent)(const Frxclass::TfrxRect &ARect);

#pragma pack(push,1)
struct TfrxInsertion
{
	
public:
	Frxclass::TfrxComponentClass ComponentClass;
	System::Extended Left;
	System::Extended Top;
	System::Extended Width;
	System::Extended Height;
	System::Extended OriginalWidth;
	System::Extended OriginalHeight;
	System::Word Flags;
};
#pragma pack(pop)


class DELPHICLASS TfrxDesignerWorkspace;
class PASCALIMPLEMENTATION TfrxDesignerWorkspace : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
protected:
	System::Extended FBandHeader;
	Graphics::TCanvas* FCanvas;
	Graphics::TColor FColor;
	TfrxCursorType FCT;
	bool FDblClicked;
	bool FDisableUpdate;
	bool FFreeBandsPlacement;
	int FGapBetweenBands;
	bool FGridAlign;
	bool FGridLCD;
	TfrxGridType FGridType;
	System::Extended FGridX;
	System::Extended FGridY;
	Frxunicodectrls::TUnicodeMemo* FInplaceMemo;
	Frxclass::TfrxCustomMemoView* FInplaceObject;
	TfrxInsertion FInsertion;
	System::Extended FLastMousePointX;
	System::Extended FLastMousePointY;
	Types::TRect FMargins;
	Extctrls::TPanel* FMarginsPanel;
	TfrxDesignMode FMode;
	TfrxDesignMode1 FMode1;
	bool FModifyFlag;
	bool FMouseDown;
	Classes::TList* FObjects;
	System::Extended FOffsetX;
	System::Extended FOffsetY;
	Frxclass::TfrxPage* FPage;
	int FPageHeight;
	int FPageWidth;
	System::Extended FScale;
	Frxclass::TfrxRect FScaleRect;
	Frxclass::TfrxRect FScaleRect1;
	Classes::TList* FSelectedObjects;
	Classes::TList* FSavedAlign;
	Frxclass::TfrxRect FSelectionRect;
	bool FShowBandCaptions;
	bool FShowEdges;
	bool FShowGrid;
	Frxclass::TfrxBand* FSizedBand;
	Classes::TNotifyEvent FOnModify;
	Classes::TNotifyEvent FOnEdit;
	Classes::TNotifyEvent FOnInsert;
	TfrxNotifyPositionEvent FOnNotifyPosition;
	Classes::TNotifyEvent FOnSelectionChanged;
	Classes::TNotifyEvent FOnTopLeftChanged;
	void __fastcall DoModify(void);
	void __fastcall AdjustBandHeight(Frxclass::TfrxBand* Bnd);
	virtual void __fastcall CheckGuides(System::Extended &kx, System::Extended &ky, bool &Result);
	void __fastcall DoNudge(System::Extended dx, System::Extended dy, bool Smooth);
	void __fastcall DoSize(System::Extended dx, System::Extended dy);
	void __fastcall DoStick(int dx, int dy);
	void __fastcall DoTab(void);
	void __fastcall DrawBackground(void);
	void __fastcall DrawCross(bool Down);
	void __fastcall DrawInsertionRect(void);
	virtual void __fastcall DrawObjects(void);
	void __fastcall DrawSelectionRect(void);
	void __fastcall FindNearest(int dx, int dy);
	void __fastcall MouseLeave(void);
	void __fastcall NormalizeCoord(Frxclass::TfrxComponent* c);
	void __fastcall NormalizeRect(Frxclass::TfrxRect &R);
	void __fastcall SelectionChanged(void);
	void __fastcall SetScale(System::Extended Value);
	void __fastcall SetShowBandCaptions(const bool Value);
	void __fastcall UpdateBandHeader(void);
	DYNAMIC void __fastcall DblClick(void);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall KeyUp(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	HIDESBASE MESSAGE void __fastcall CMMouseLeave(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMMove(Messages::TWMMove &Message);
	MESSAGE void __fastcall WMEraseBackground(Messages::TMessage &Message);
	void __fastcall PrepareShiftTree(Frxclass::TfrxBand* Band);
	HIDESBASE void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetGridType(const TfrxGridType Value);
	void __fastcall SetOrigin(const Types::TPoint &Value);
	virtual void __fastcall SetParent(Controls::TWinControl* AParent);
	void __fastcall SetShowGrid(const bool Value);
	Types::TPoint __fastcall GetOrigin(void);
	Frxclass::TfrxComponent* __fastcall GetRightBottomObject(void);
	Frxclass::TfrxRect __fastcall GetSelectionBounds(void);
	bool __fastcall ListsEqual(Classes::TList* List1, Classes::TList* List2);
	int __fastcall SelectedCount(void);
	
public:
	__fastcall virtual TfrxDesignerWorkspace(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDesignerWorkspace(void);
	virtual void __fastcall Paint(void);
	void __fastcall AdjustBands(bool AttachObjects = true);
	virtual void __fastcall DeleteObjects(void);
	void __fastcall DisableUpdate(void);
	void __fastcall EnableUpdate(void);
	virtual void __fastcall EditObject(void);
	void __fastcall GroupObjects(void);
	void __fastcall UngroupObjects(void);
	virtual void __fastcall SetInsertion(Frxclass::TfrxComponentClass AClass, System::Extended AWidth, System::Extended AHeight, System::Word AFlag);
	void __fastcall SetPageDimensions(int AWidth, int AHeight, const Types::TRect &AMargins);
	void __fastcall UpdateView(void);
	__property System::Extended BandHeader = {read=FBandHeader, write=FBandHeader};
	__property Graphics::TColor Color = {read=FColor, write=SetColor, nodefault};
	__property bool FreeBandsPlacement = {read=FFreeBandsPlacement, write=FFreeBandsPlacement, nodefault};
	__property int GapBetweenBands = {read=FGapBetweenBands, write=FGapBetweenBands, nodefault};
	__property bool GridAlign = {read=FGridAlign, write=FGridAlign, nodefault};
	__property bool GridLCD = {read=FGridLCD, write=FGridLCD, nodefault};
	__property TfrxGridType GridType = {read=FGridType, write=SetGridType, nodefault};
	__property System::Extended GridX = {read=FGridX, write=FGridX};
	__property System::Extended GridY = {read=FGridY, write=FGridY};
	__property TfrxInsertion Insertion = {read=FInsertion};
	__property bool IsMouseDown = {read=FMouseDown, nodefault};
	__property TfrxDesignMode1 Mode = {read=FMode1, nodefault};
	__property Classes::TList* Objects = {read=FObjects, write=FObjects};
	__property System::Extended OffsetX = {read=FOffsetX, write=FOffsetX};
	__property System::Extended OffsetY = {read=FOffsetY, write=FOffsetY};
	__property Types::TPoint Origin = {read=GetOrigin, write=SetOrigin};
	__property Frxclass::TfrxPage* Page = {read=FPage, write=FPage};
	__property System::Extended Scale = {read=FScale, write=SetScale};
	__property Classes::TList* SelectedObjects = {read=FSelectedObjects, write=FSelectedObjects};
	__property bool ShowBandCaptions = {read=FShowBandCaptions, write=SetShowBandCaptions, nodefault};
	__property bool ShowEdges = {read=FShowEdges, write=FShowEdges, nodefault};
	__property bool ShowGrid = {read=FShowGrid, write=SetShowGrid, nodefault};
	__property Classes::TNotifyEvent OnModify = {read=FOnModify, write=FOnModify};
	__property Classes::TNotifyEvent OnEdit = {read=FOnEdit, write=FOnEdit};
	__property Classes::TNotifyEvent OnInsert = {read=FOnInsert, write=FOnInsert};
	__property TfrxNotifyPositionEvent OnNotifyPosition = {read=FOnNotifyPosition, write=FOnNotifyPosition};
	__property Classes::TNotifyEvent OnSelectionChanged = {read=FOnSelectionChanged, write=FOnSelectionChanged};
	__property Classes::TNotifyEvent OnTopLeftChanged = {read=FOnTopLeftChanged, write=FOnTopLeftChanged};
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxDesignerWorkspace(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


class DELPHICLASS TInplaceMemo;
class PASCALIMPLEMENTATION TInplaceMemo : public Frxunicodectrls::TUnicodeMemo
{
	typedef Frxunicodectrls::TUnicodeMemo inherited;
	
private:
	TfrxDesignerWorkspace* FDesigner;
	Frxclass::TfrxCustomMemoView* FObject;
	tagSIZE FOriginalSize;
	void __fastcall LinesChange(System::TObject* Sender);
	
public:
	__fastcall virtual TInplaceMemo(Classes::TComponent* AOwner);
	void __fastcall Edit(Frxclass::TfrxCustomMemoView* c);
	void __fastcall EditDone(void);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
public:
	/* TCustomMemo.Destroy */ inline __fastcall virtual ~TInplaceMemo(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TInplaceMemo(HWND ParentWindow) : Frxunicodectrls::TUnicodeMemo(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt crPencil = 0xb;

}	/* namespace Frxdesgnworkspace */
using namespace Frxdesgnworkspace;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdesgnworkspaceHPP
