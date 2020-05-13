// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditreport.pas' rev: 21.00

#ifndef FrxeditreportHPP
#define FrxeditreportHPP

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
#include <Frxctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Filectrl.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditreport
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxReportEditorForm;
class PASCALIMPLEMENTATION TfrxReportEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Comctrls::TPageControl* PageControl;
	Comctrls::TTabSheet* GeneralTS;
	Comctrls::TTabSheet* DescriptionTS;
	Stdctrls::TGroupBox* ReportSettingsL;
	Stdctrls::TListBox* PrintersLB;
	Stdctrls::TLabel* CopiesL;
	Stdctrls::TEdit* CopiesE;
	Stdctrls::TCheckBox* CollateCB;
	Stdctrls::TGroupBox* GeneralL;
	Stdctrls::TLabel* PasswordL;
	Stdctrls::TCheckBox* DoublePassCB;
	Stdctrls::TCheckBox* PrintIfEmptyCB;
	Stdctrls::TEdit* PasswordE;
	Stdctrls::TGroupBox* DescriptionL;
	Extctrls::TBevel* Bevel3;
	Stdctrls::TLabel* NameL;
	Extctrls::TImage* PictureImg;
	Stdctrls::TLabel* Description1L;
	Stdctrls::TLabel* PictureL;
	Stdctrls::TLabel* AuthorL;
	Stdctrls::TEdit* NameE;
	Stdctrls::TMemo* DescriptionE;
	Stdctrls::TButton* PictureB;
	Stdctrls::TEdit* AuthorE;
	Stdctrls::TGroupBox* VersionL;
	Stdctrls::TLabel* MajorL;
	Stdctrls::TLabel* MinorL;
	Stdctrls::TLabel* ReleaseL;
	Stdctrls::TLabel* BuildL;
	Stdctrls::TLabel* CreatedL;
	Stdctrls::TLabel* Created1L;
	Stdctrls::TLabel* ModifiedL;
	Stdctrls::TLabel* Modified1L;
	Stdctrls::TEdit* MajorE;
	Stdctrls::TEdit* MinorE;
	Stdctrls::TEdit* ReleaseE;
	Stdctrls::TEdit* BuildE;
	Comctrls::TTabSheet* InheritTS;
	Stdctrls::TGroupBox* InheritGB;
	Stdctrls::TLabel* InheritStateL;
	Stdctrls::TRadioButton* DetachRB;
	Stdctrls::TLabel* SelectL;
	Stdctrls::TRadioButton* InheritRB;
	Stdctrls::TRadioButton* DontChangeRB;
	Comctrls::TListView* InheritLV;
	Stdctrls::TLabel* PathLB;
	Stdctrls::TEdit* PathE;
	Stdctrls::TButton* BrowseB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PictureBClick(System::TObject* Sender);
	void __fastcall PrintersLBDrawItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall FormDestroy(System::TObject* Sender);
	void __fastcall BrowseBClick(System::TObject* Sender);
	void __fastcall FillTemplatelist(void);
	void __fastcall PathEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall PageControlChange(System::TObject* Sender);
	
private:
	Classes::TStringList* FTemplates;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxReportEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxReportEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxReportEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxReportEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditreport */
using namespace Frxeditreport;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditreportHPP
