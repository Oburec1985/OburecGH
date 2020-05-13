// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxpreviewpagesettings.pas' rev: 21.00

#ifndef FrxpreviewpagesettingsHPP
#define FrxpreviewpagesettingsHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxpreviewpagesettings
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxDesignerUnits { duCM, duInches, duPixels, duChars };
#pragma option pop

class DELPHICLASS TfrxPageSettingsForm;
class PASCALIMPLEMENTATION TfrxPageSettingsForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TGroupBox* SizeL;
	Stdctrls::TLabel* WidthL;
	Stdctrls::TLabel* HeightL;
	Stdctrls::TLabel* UnitL1;
	Stdctrls::TLabel* UnitL2;
	Stdctrls::TEdit* WidthE;
	Stdctrls::TEdit* HeightE;
	Stdctrls::TComboBox* SizeCB;
	Stdctrls::TGroupBox* OrientationL;
	Extctrls::TImage* PortraitImg;
	Extctrls::TImage* LandscapeImg;
	Stdctrls::TRadioButton* PortraitRB;
	Stdctrls::TRadioButton* LandscapeRB;
	Stdctrls::TGroupBox* MarginsL;
	Stdctrls::TLabel* LeftL;
	Stdctrls::TLabel* TopL;
	Stdctrls::TLabel* RightL;
	Stdctrls::TLabel* BottomL;
	Stdctrls::TLabel* UnitL3;
	Stdctrls::TLabel* UnitL4;
	Stdctrls::TLabel* UnitL5;
	Stdctrls::TLabel* UnitL6;
	Stdctrls::TEdit* MarginLeftE;
	Stdctrls::TEdit* MarginTopE;
	Stdctrls::TEdit* MarginRightE;
	Stdctrls::TEdit* MarginBottomE;
	Stdctrls::TGroupBox* OtherL;
	Stdctrls::TRadioButton* ApplyToCurRB;
	Stdctrls::TRadioButton* ApplyToAllRB;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall PortraitRBClick(System::TObject* Sender);
	void __fastcall SizeCBClick(System::TObject* Sender);
	void __fastcall WidthEChange(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
protected:
	Frxclass::TfrxReportPage* FPage;
	Frxclass::TfrxReport* FReport;
	TfrxDesignerUnits FUnits;
	bool FUpdating;
	bool __fastcall GetNeedRebuild(void);
	System::Extended __fastcall mmToUnits(System::Extended mm);
	System::Extended __fastcall UnitsTomm(System::Extended mm);
	
public:
	__property bool NeedRebuild = {read=GetNeedRebuild, nodefault};
	__property Frxclass::TfrxReportPage* Page = {read=FPage, write=FPage};
	__property Frxclass::TfrxReport* Report = {read=FReport, write=FReport};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxPageSettingsForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxPageSettingsForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxPageSettingsForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxPageSettingsForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxpreviewpagesettings */
using namespace Frxpreviewpagesettings;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxpreviewpagesettingsHPP
