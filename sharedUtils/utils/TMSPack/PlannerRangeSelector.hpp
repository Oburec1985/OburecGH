// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Plannerrangeselector.pas' rev: 21.00

#ifndef PlannerrangeselectorHPP
#define PlannerrangeselectorHPP

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
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Advmedbtn.hpp>	// Pascal unit
#include <Plannercal.hpp>	// Pascal unit
#include <Maskutils.hpp>	// Pascal unit
#include <Mask.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Advedit.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Plannerrangeselector
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TPlannerRangeSelector;
class PASCALIMPLEMENTATION TPlannerRangeSelector : public Advmedbtn::TAdvMaskEditBtn
{
	typedef Advmedbtn::TAdvMaskEditBtn inherited;
	
private:
	Plannercal::TPlannerCalendar* FPlannerCalendar;
	Forms::TForm* FPlannerParent;
	bool CancelThisBtnClick;
	bool FHideCalendarAfterSelection;
	Plannercal::TRangeSelectEvent FOnRangeSelect;
	Classes::TNotifyEvent FOnInvalidDate;
	bool FDroppedDown;
	Mask::TMaskEdit* FEdit;
	Stdctrls::TStaticText* FSeparator;
	bool FCalendarMouseDown;
	bool FCalendarKeyDown;
	System::TDateTime FDownDate;
	bool FInternalChange;
	System::TDateTime FOrigStart;
	System::TDateTime FOrigEnd;
	HIDESBASE MESSAGE void __fastcall WMSetFocus(Messages::TWMSetFocus &Message);
	Plannercal::TGetDateEvent __fastcall GetOnGetDateHint(void);
	Plannercal::TGetDateEventHint __fastcall GetOnGetDateHintString(void);
	void __fastcall SetOnGetDateHint(const Plannercal::TGetDateEvent Value);
	void __fastcall SetOnGetDateHintString(const Plannercal::TGetDateEventHint Value);
	void __fastcall HideParent(void);
	Controls::TWinControl* __fastcall GetParentEx(void);
	void __fastcall SetParentEx(const Controls::TWinControl* Value);
	Plannercal::TEventPropEvent __fastcall GetOnGetEventProp(void);
	void __fastcall SetOnGetEventProp(const Plannercal::TEventPropEvent Value);
	Classes::TNotifyEvent __fastcall GetOnWeekSelect(void);
	void __fastcall SetOnWeekSelect(const Classes::TNotifyEvent Value);
	void __fastcall SetDroppedDown(const bool Value);
	System::TDateTime __fastcall GetDateEnd(void);
	System::TDateTime __fastcall GetDateStart(void);
	void __fastcall SetDateEnd(const System::TDateTime Value);
	void __fastcall SetDateStart(const System::TDateTime Value);
	Maskutils::TEditMask __fastcall GetEditMask(void);
	HIDESBASE void __fastcall SetEditMask(const Maskutils::TEditMask Value);
	
protected:
	virtual int __fastcall GetVersionNr(void);
	virtual void __fastcall InitEvents(void);
	void __fastcall CreateSubControls(void);
	void __fastcall UpdateEditSize(void);
	void __fastcall UpdateSeparatorSize(void);
	virtual int __fastcall GetEditExtraSpace(void);
	virtual void __fastcall BtnClick(System::TObject* Sender);
	void __fastcall PlannerParentDeactivate(System::TObject* Sender);
	void __fastcall PlannerCalendarRangeSelect(System::TObject* Sender, System::TDateTime StartDate, System::TDateTime EndDate);
	void __fastcall PlannerCalendarMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall PlannerCalendarMouseMove(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	void __fastcall PlannerCalendarMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall PlannerCalendarKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall PlannerCalendarKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC Classes::TComponent* __fastcall GetChildParent(void);
	DYNAMIC Classes::TComponent* __fastcall GetChildOwner(void);
	DYNAMIC void __fastcall Change(void);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	virtual void __fastcall ValidateError(void);
	DYNAMIC void __fastcall Resize(void);
	
public:
	__fastcall virtual TPlannerRangeSelector(Classes::TComponent* AOwner);
	__fastcall virtual ~TPlannerRangeSelector(void);
	DYNAMIC void __fastcall DoExit(void);
	virtual void __fastcall DropDown(void);
	virtual void __fastcall CreateWnd(void);
	void __fastcall CancelBtnClick(void);
	__property Controls::TWinControl* Parent = {read=GetParentEx, write=SetParentEx};
	virtual void __fastcall Loaded(void);
	DYNAMIC void __fastcall GetChildren(Classes::TGetChildProc Proc, Classes::TComponent* Root);
	__property bool DroppedDown = {read=FDroppedDown, write=SetDroppedDown, nodefault};
	
__published:
	__property Plannercal::TPlannerCalendar* Calendar = {read=FPlannerCalendar, write=FPlannerCalendar};
	__property System::TDateTime DateStart = {read=GetDateStart, write=SetDateStart};
	__property System::TDateTime DateEnd = {read=GetDateEnd, write=SetDateEnd};
	__property Maskutils::TEditMask EditMask = {read=GetEditMask, write=SetEditMask};
	__property bool HideCalendarAfterSelection = {read=FHideCalendarAfterSelection, write=FHideCalendarAfterSelection, nodefault};
	__property Plannercal::TGetDateEvent OnGetDateHint = {read=GetOnGetDateHint, write=SetOnGetDateHint};
	__property Plannercal::TGetDateEventHint OnGetDateHintString = {read=GetOnGetDateHintString, write=SetOnGetDateHintString};
	__property Plannercal::TEventPropEvent OnGetEventProp = {read=GetOnGetEventProp, write=SetOnGetEventProp};
	__property Classes::TNotifyEvent OnWeekSelect = {read=GetOnWeekSelect, write=SetOnWeekSelect};
	__property Plannercal::TRangeSelectEvent OnRangeSelect = {read=FOnRangeSelect, write=FOnRangeSelect};
	__property Classes::TNotifyEvent OnInvalidDate = {read=FOnInvalidDate, write=FOnInvalidDate};
public:
	/* TWinControl.CreateParented */ inline __fastcall TPlannerRangeSelector(HWND ParentWindow) : Advmedbtn::TAdvMaskEditBtn(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x0;
static const ShortInt REL_VER = 0x0;
static const ShortInt BLD_VER = 0x0;

}	/* namespace Plannerrangeselector */
using namespace Plannerrangeselector;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// PlannerrangeselectorHPP
