// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Planrecurredit.pas' rev: 21.00

#ifndef PlanrecurreditHPP
#define PlanrecurreditHPP

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
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Planrecurr.hpp>	// Pascal unit
#include <Planutil.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Planrecurredit
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TRecurrEdit;
class PASCALIMPLEMENTATION TRecurrEdit : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* Button1;
	Stdctrls::TButton* Button2;
	Comctrls::TPageControl* PageControl1;
	Comctrls::TTabSheet* TabSheet1;
	Comctrls::TTabSheet* TabSheet2;
	Extctrls::TRadioGroup* Freq;
	Stdctrls::TGroupBox* GroupBox1;
	Stdctrls::TLabel* Label1;
	Extctrls::TNotebook* Notebook1;
	Stdctrls::TRadioButton* rDay;
	Stdctrls::TRadioButton* rWeekDay;
	Stdctrls::TCheckBox* cMon;
	Stdctrls::TCheckBox* cTue;
	Stdctrls::TCheckBox* cWed;
	Stdctrls::TCheckBox* cThu;
	Stdctrls::TCheckBox* cFri;
	Stdctrls::TCheckBox* cSat;
	Stdctrls::TCheckBox* cSun;
	Stdctrls::TRadioButton* rMonthDay;
	Stdctrls::TRadioButton* rSpecialDay;
	Stdctrls::TComboBox* cWeekNum;
	Stdctrls::TComboBox* cDay;
	Stdctrls::TLabel* Label3;
	Stdctrls::TLabel* Label4;
	Stdctrls::TLabel* Label5;
	Stdctrls::TLabel* Label6;
	Stdctrls::TLabel* Label7;
	Stdctrls::TLabel* Label8;
	Stdctrls::TLabel* Label9;
	Stdctrls::TLabel* Label10;
	Stdctrls::TLabel* Label11;
	Stdctrls::TLabel* Label12;
	Stdctrls::TLabel* Label13;
	Stdctrls::TLabel* Label14;
	Stdctrls::TRadioButton* rYearDay;
	Stdctrls::TComboBox* cYearDay;
	Stdctrls::TRadioButton* rYearSpecialDay;
	Stdctrls::TComboBox* cYearWeekNum;
	Stdctrls::TCheckBox* yck1;
	Stdctrls::TCheckBox* yck2;
	Stdctrls::TCheckBox* yck3;
	Stdctrls::TCheckBox* yck4;
	Stdctrls::TCheckBox* yck5;
	Stdctrls::TCheckBox* yck6;
	Stdctrls::TCheckBox* yck7;
	Stdctrls::TCheckBox* yck8;
	Stdctrls::TCheckBox* yck9;
	Stdctrls::TCheckBox* yck10;
	Stdctrls::TCheckBox* yck11;
	Stdctrls::TCheckBox* yck12;
	Stdctrls::TEdit* Interval;
	Stdctrls::TGroupBox* GroupBox2;
	Stdctrls::TLabel* Label2;
	Stdctrls::TRadioButton* rInfinite;
	Stdctrls::TRadioButton* rUntil;
	Stdctrls::TRadioButton* rUntilDate;
	Comctrls::TDateTimePicker* cDate;
	Stdctrls::TEdit* cOccur;
	Comctrls::TDateTimePicker* exsd;
	Stdctrls::TListBox* ExList;
	Stdctrls::TButton* Button3;
	Stdctrls::TButton* Button4;
	Comctrls::TDateTimePicker* exst;
	Comctrls::TDateTimePicker* exed;
	Comctrls::TDateTimePicker* exet;
	Stdctrls::TButton* Button5;
	Stdctrls::TLabel* Label15;
	void __fastcall Button1Click(System::TObject* Sender);
	void __fastcall FreqClick(System::TObject* Sender);
	void __fastcall Button5Click(System::TObject* Sender);
	void __fastcall Button3Click(System::TObject* Sender);
	void __fastcall Button4Click(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormDestroy(System::TObject* Sender);
	
private:
	System::UnicodeString FRecurrency;
	void __fastcall SetRecurrency(const System::UnicodeString Value);
	
public:
	Planrecurr::TDateItems* ExDates;
	__property System::UnicodeString Recurrency = {read=FRecurrency, write=SetRecurrency};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TRecurrEdit(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TRecurrEdit(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TRecurrEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TRecurrEdit(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TPlannerRecurrencyEditor;
class PASCALIMPLEMENTATION TPlannerRecurrencyEditor : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	System::UnicodeString FRecurrency;
	Planutil::TRecurrencyDialogLanguage* FLanguage;
	void __fastcall SetLanguage(const Planutil::TRecurrencyDialogLanguage* Value);
	
public:
	bool __fastcall Execute(void);
	__fastcall virtual TPlannerRecurrencyEditor(Classes::TComponent* AOwner);
	__fastcall virtual ~TPlannerRecurrencyEditor(void);
	
__published:
	__property System::UnicodeString Recurrency = {read=FRecurrency, write=FRecurrency};
	__property Planutil::TRecurrencyDialogLanguage* LanguageSettings = {read=FLanguage, write=SetLanguage};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TRecurrEdit* RecurrEdit;

}	/* namespace Planrecurredit */
using namespace Planrecurredit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// PlanrecurreditHPP
