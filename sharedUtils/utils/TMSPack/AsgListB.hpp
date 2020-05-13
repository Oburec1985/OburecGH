// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Asglistb.pas' rev: 21.00

#ifndef AsglistbHPP
#define AsglistbHPP

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
#include <Messages.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Asgdd.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Advgrid.hpp>	// Pascal unit
#include <Grids.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Advobj.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Asglistb
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TOleDragStartEvent)(System::TObject* Sender, int DropIndex);

typedef void __fastcall (__closure *TOleDragStopEvent)(System::TObject* Sender, int OLEEffect);

typedef void __fastcall (__closure *TOleDragOverEvent)(System::TObject* Sender, bool &Allow);

typedef void __fastcall (__closure *TOleDropEvent)(System::TObject* Sender, int DropIndex);

class DELPHICLASS TAdvGridHeaderList;
class PASCALIMPLEMENTATION TAdvGridHeaderList : public Stdctrls::TCustomListBox
{
	typedef Stdctrls::TCustomListBox inherited;
	
private:
	Advgrid::TAdvStringGrid* FGrid;
	bool FDragging;
	int FItemIndex;
	Advgrid::THeaderDragButton* FMoveButton;
	Types::TPoint FClickPos;
	bool FMouseDown;
	bool FOleDropTargetAssigned;
	TOleDropEvent FOnOleDrop;
	TOleDragStartEvent FOnOleDragStart;
	TOleDragStopEvent FOnOleDragStop;
	TOleDragOverEvent FOnOleDragOver;
	HIDESBASE MESSAGE void __fastcall CNDrawItem(Messages::TWMDrawItem &Message);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	int __fastcall GetVersionNr(void);
	void __fastcall SetGrid(const Advgrid::TAdvStringGrid* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	virtual void __fastcall DrawItem(int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	virtual void __fastcall MeasureItem(int Index, int &Height);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	virtual void __fastcall CreateWnd(void);
	
public:
	__fastcall virtual TAdvGridHeaderList(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvGridHeaderList(void);
	virtual void __fastcall WndProc(Messages::TMessage &Message);
	void __fastcall MoveFromGridToList(int ColumnIndex);
	void __fastcall MoveFromListToGrid(int ItemIndex);
	void __fastcall MoveAllFromGridToList(void);
	void __fastcall MoveAllFromListToGrid(void);
	
__published:
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property BiDiMode;
	__property Constraints;
	__property DragKind = {default=0};
	__property ParentBiDiMode = {default=1};
	__property OnEndDock;
	__property OnStartDock;
	__property BorderStyle = {default=1};
	__property Color = {default=-16777211};
	__property Columns = {default=0};
	__property Ctl3D;
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property Enabled = {default=1};
	__property Font;
	__property Advgrid::TAdvStringGrid* Grid = {read=FGrid, write=SetGrid};
	__property ImeMode = {default=3};
	__property ImeName;
	__property ItemHeight = {default=16};
	__property ParentCtl3D = {default=1};
	__property ParentColor = {default=0};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property Visible = {default=1};
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
	__property TOleDropEvent OnOleDrop = {read=FOnOleDrop, write=FOnOleDrop};
	__property TOleDragStartEvent OnOleDragStart = {read=FOnOleDragStart, write=FOnOleDragStart};
	__property TOleDragStopEvent OnOleDragStop = {read=FOnOleDragStop, write=FOnOleDragStop};
	__property TOleDragOverEvent OnOleDragOver = {read=FOnOleDragOver, write=FOnOleDragOver};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvGridHeaderList(HWND ParentWindow) : Stdctrls::TCustomListBox(ParentWindow) { }
	
};


class DELPHICLASS TAdvGridHeaderPopupList;
class PASCALIMPLEMENTATION TAdvGridHeaderPopupList : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	Forms::TForm* FForm;
	TAdvGridHeaderList* FHeaderList;
	Classes::TStringList* FColList;
	Advgrid::TAdvStringGrid* FGrid;
	System::UnicodeString FCaption;
	Forms::TCloseQueryEvent FOnCloseQuery;
	Forms::TCloseEvent FOnClose;
	int FFormTop;
	int FFormLeft;
	int FFormHeight;
	int FFormWidth;
	System::UnicodeString FHint;
	bool FShowHint;
	int FItemHeight;
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	int __fastcall GetVersionNr(void);
	void __fastcall SetGrid(const Advgrid::TAdvStringGrid* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	void __fastcall DoFormCloseQuery(System::TObject* Sender, bool &CanClose);
	void __fastcall DoFormClose(System::TObject* Sender, Forms::TCloseAction &Action);
	
public:
	__fastcall virtual TAdvGridHeaderPopupList(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvGridHeaderPopupList(void);
	void __fastcall Show(Classes::TComponent* AOwner);
	void __fastcall ShowAtXY(Classes::TComponent* AOwner, int X, int Y);
	void __fastcall MoveFromGridToList(int ColumnIndex);
	void __fastcall MoveFromListToGrid(int ItemIndex);
	void __fastcall MoveAllFromGridToList(void);
	void __fastcall MoveAllFromListToGrid(void);
	
__published:
	__property System::UnicodeString Caption = {read=FCaption, write=FCaption};
	__property int FormWidth = {read=FFormWidth, write=FFormWidth, default=200};
	__property int FormHeight = {read=FFormHeight, write=FFormHeight, default=300};
	__property int FormTop = {read=FFormTop, write=FFormTop, default=-1};
	__property int FormLeft = {read=FFormLeft, write=FFormLeft, default=-1};
	__property Advgrid::TAdvStringGrid* Grid = {read=FGrid, write=SetGrid};
	__property System::UnicodeString Hint = {read=FHint, write=FHint};
	__property int ItemHeight = {read=FItemHeight, write=FItemHeight, default=16};
	__property bool ShowHint = {read=FShowHint, write=FShowHint, nodefault};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
	__property Forms::TCloseEvent OnClose = {read=FOnClose, write=FOnClose};
	__property Forms::TCloseQueryEvent OnCloseQuery = {read=FOnCloseQuery, write=FOnCloseQuery};
};


class DELPHICLASS TListDropTarget;
class PASCALIMPLEMENTATION TListDropTarget : public Asgdd::TASGDropTarget
{
	typedef Asgdd::TASGDropTarget inherited;
	
private:
	TAdvGridHeaderList* FList;
	
public:
	__fastcall TListDropTarget(TAdvGridHeaderList* AList);
	virtual void __fastcall DropText(const Types::TPoint &pt, System::UnicodeString s);
	virtual void __fastcall DropCol(const Types::TPoint &pt, int col);
	virtual void __fastcall DragMouseMove(const Types::TPoint &pt, bool &Allow, Asgdd::TDropFormats DropFormats);
	virtual void __fastcall DragMouseLeave(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TListDropTarget(void) { }
	
};


class DELPHICLASS TListDropSource;
class PASCALIMPLEMENTATION TListDropSource : public Asgdd::TASGDropSource
{
	typedef Asgdd::TASGDropSource inherited;
	
private:
	TAdvGridHeaderList* FList;
	int FLastEffect;
	
protected:
	virtual void __fastcall DragDropStop(void);
	
public:
	__fastcall TListDropSource(TAdvGridHeaderList* AList);
	virtual void __fastcall CurrentEffect(int dwEffect);
	virtual void __fastcall QueryDrag(void);
	__property int LastEffect = {read=FLastEffect, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TListDropSource(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x0;
static const ShortInt REL_VER = 0x1;
static const ShortInt BLD_VER = 0x0;

}	/* namespace Asglistb */
using namespace Asglistb;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AsglistbHPP
