// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Plansimpleedit.pas' rev: 21.00

#ifndef PlansimpleeditHPP
#define PlansimpleeditHPP

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
#include <Planner.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Plansimpleedit
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TEditState { esEdit, esNew };
#pragma option pop

class DELPHICLASS TSimplePlannerItemEditForm;
class PASCALIMPLEMENTATION TSimplePlannerItemEditForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TLabel* lbl_subj;
	Stdctrls::TLabel* lbl_from;
	Stdctrls::TLabel* lbl_date;
	Stdctrls::TLabel* lbl_notes;
	Stdctrls::TLabel* lbl_to;
	Stdctrls::TLabel* lbl_shape;
	Stdctrls::TLabel* lbl_color;
	Comctrls::TDateTimePicker* StartTime;
	Comctrls::TDateTimePicker* EndTime;
	Stdctrls::TComboBox* CBShape;
	Stdctrls::TEdit* EdSubject;
	Stdctrls::TMemo* Notes;
	Comctrls::TDateTimePicker* PlanDate;
	Dialogs::TColorDialog* ColorDialog;
	Extctrls::TPanel* WarningPanel;
	Extctrls::TPanel* ButtonBottomPanel;
	Extctrls::TPanel* ButtonBottomRightPanel;
	Stdctrls::TButton* OKBtn;
	Stdctrls::TButton* CancBtn;
	Extctrls::TPanel* Panel1;
	Extctrls::TShape* Shape1;
	void __fastcall Shape1MouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	
private:
	TEditState FEditState;
	
protected:
	virtual void __fastcall AssignFromPlannerItem(Planner::TPlannerItem* PlannerItem);
	virtual void __fastcall AssignToPlannerItem(Planner::TPlannerItem* PlannerItem);
	virtual void __fastcall InternalEditModal(Planner::TPlannerItem* PlannerItem);
	virtual void __fastcall ProcessWarnings(void);
	virtual void __fastcall SetEditState(const TEditState Value);
	
public:
	virtual void __fastcall EditModal(Planner::TPlannerItem* PlannerItem);
	__property TEditState EditState = {read=FEditState, write=SetEditState, nodefault};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TSimplePlannerItemEditForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TSimplePlannerItemEditForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TSimplePlannerItemEditForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TSimplePlannerItemEditForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TSimpleItemEditor;
class PASCALIMPLEMENTATION TSimpleItemEditor : public Planner::TCustomItemEditor
{
	typedef Planner::TCustomItemEditor inherited;
	
private:
	TSimplePlannerItemEditForm* FEditForm;
	bool FCenter;
	int FFormLeft;
	int FFormTop;
	System::UnicodeString FLblWarning;
	System::UnicodeString FLblSubject;
	System::UnicodeString FLblDate;
	System::UnicodeString FLblFrom;
	System::UnicodeString FLblTo;
	System::UnicodeString FLblColor;
	System::UnicodeString FLblShape;
	System::UnicodeString FLblNotes;
	bool FShowShape;
	bool FShowColor;
	
public:
	__fastcall virtual TSimpleItemEditor(Classes::TComponent* AOwner);
	virtual void __fastcall CreateEditor(Classes::TComponent* AOwner);
	virtual void __fastcall DestroyEditor(void);
	virtual int __fastcall Execute(void);
	virtual void __fastcall PlannerItemToEdit(Planner::TPlannerItem* APlannerItem);
	virtual void __fastcall EditToPlannerItem(Planner::TPlannerItem* APlannerItem);
	
__published:
	__property bool CenterOnScreen = {read=FCenter, write=FCenter, default=1};
	__property int FormLeft = {read=FFormLeft, write=FFormLeft, nodefault};
	__property int FormTop = {read=FFormTop, write=FFormTop, nodefault};
	__property System::UnicodeString LblWarning = {read=FLblWarning, write=FLblWarning};
	__property System::UnicodeString LblSubject = {read=FLblSubject, write=FLblSubject};
	__property System::UnicodeString LblDate = {read=FLblDate, write=FLblDate};
	__property System::UnicodeString LblFrom = {read=FLblFrom, write=FLblFrom};
	__property System::UnicodeString LblTo = {read=FLblTo, write=FLblTo};
	__property System::UnicodeString LblColor = {read=FLblColor, write=FLblColor};
	__property System::UnicodeString LblShape = {read=FLblShape, write=FLblShape};
	__property System::UnicodeString LblNotes = {read=FLblNotes, write=FLblNotes};
	__property bool ShowShape = {read=FShowShape, write=FShowShape, default=1};
	__property bool ShowColor = {read=FShowColor, write=FShowColor, default=1};
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TSimpleItemEditor(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Plansimpleedit */
using namespace Plansimpleedit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// PlansimpleeditHPP
