// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditreportdata.pas' rev: 21.00

#ifndef FrxeditreportdataHPP
#define FrxeditreportdataHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Checklst.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditreportdata
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxReportDataForm;
class PASCALIMPLEMENTATION TfrxReportDataForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* CancelB;
	Checklst::TCheckListBox* DatasetsLB;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall DatasetsLBClickCheck(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	bool FStandalone;
	void __fastcall BuildConnectionList(void);
	void __fastcall BuildDatasetList(void);
	
public:
	Frxclass::TfrxReport* Report;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxReportDataForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxReportDataForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxReportDataForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxReportDataForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditreportdata */
using namespace Frxeditreportdata;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditreportdataHPP
