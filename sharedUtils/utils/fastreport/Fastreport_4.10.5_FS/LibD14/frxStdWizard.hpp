// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxstdwizard.pas' rev: 21.00

#ifndef FrxstdwizardHPP
#define FrxstdwizardHPP

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
#include <Buttons.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxdesgn.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxstdwizard
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxStdWizard;
class PASCALIMPLEMENTATION TfrxStdWizard : public Frxclass::TfrxCustomWizard
{
	typedef Frxclass::TfrxCustomWizard inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void);
public:
	/* TfrxCustomWizard.Create */ inline __fastcall virtual TfrxStdWizard(Classes::TComponent* AOwner) : Frxclass::TfrxCustomWizard(AOwner) { }
	
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxStdWizard(void) { }
	
};


class DELPHICLASS TfrxDotMatrixWizard;
class PASCALIMPLEMENTATION TfrxDotMatrixWizard : public Frxclass::TfrxCustomWizard
{
	typedef Frxclass::TfrxCustomWizard inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void);
public:
	/* TfrxCustomWizard.Create */ inline __fastcall virtual TfrxDotMatrixWizard(Classes::TComponent* AOwner) : Frxclass::TfrxCustomWizard(AOwner) { }
	
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxDotMatrixWizard(void) { }
	
};


class DELPHICLASS TfrxStdEmptyWizard;
class PASCALIMPLEMENTATION TfrxStdEmptyWizard : public Frxclass::TfrxCustomWizard
{
	typedef Frxclass::TfrxCustomWizard inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void);
public:
	/* TfrxCustomWizard.Create */ inline __fastcall virtual TfrxStdEmptyWizard(Classes::TComponent* AOwner) : Frxclass::TfrxCustomWizard(AOwner) { }
	
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxStdEmptyWizard(void) { }
	
};


class DELPHICLASS TfrxDMPEmptyWizard;
class PASCALIMPLEMENTATION TfrxDMPEmptyWizard : public Frxclass::TfrxCustomWizard
{
	typedef Frxclass::TfrxCustomWizard inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void);
public:
	/* TfrxCustomWizard.Create */ inline __fastcall virtual TfrxDMPEmptyWizard(Classes::TComponent* AOwner) : Frxclass::TfrxCustomWizard(AOwner) { }
	
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxDMPEmptyWizard(void) { }
	
};


class DELPHICLASS TfrxStdWizardForm;
class PASCALIMPLEMENTATION TfrxStdWizardForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TPageControl* Pages;
	Comctrls::TTabSheet* FieldsTab;
	Comctrls::TTabSheet* GroupsTab;
	Comctrls::TTabSheet* LayoutTab;
	Stdctrls::TListBox* FieldsLB;
	Buttons::TSpeedButton* AddFieldB;
	Buttons::TSpeedButton* AddAllFieldsB;
	Buttons::TSpeedButton* RemoveFieldB;
	Buttons::TSpeedButton* RemoveAllFieldsB;
	Stdctrls::TListBox* SelectedFieldsLB;
	Stdctrls::TLabel* SelectedFieldsL;
	Buttons::TSpeedButton* FieldUpB;
	Buttons::TSpeedButton* FieldDownB;
	Stdctrls::TListBox* AvailableFieldsLB;
	Buttons::TSpeedButton* AddGroupB;
	Buttons::TSpeedButton* RemoveGroupB;
	Stdctrls::TListBox* GroupsLB;
	Stdctrls::TLabel* GroupsL;
	Buttons::TSpeedButton* GroupUpB;
	Buttons::TSpeedButton* GroupDownB;
	Stdctrls::TLabel* AvailableFieldsL;
	Stdctrls::TButton* BackB;
	Stdctrls::TButton* NextB;
	Stdctrls::TButton* FinishB;
	Stdctrls::TCheckBox* FitWidthCB;
	Stdctrls::TLabel* Step2L;
	Stdctrls::TLabel* Step3L;
	Stdctrls::TLabel* Step4L;
	Comctrls::TTabSheet* StyleTab;
	Stdctrls::TLabel* Step5L;
	Forms::TScrollBox* ScrollBox1;
	Extctrls::TPaintBox* StylePB;
	Stdctrls::TListBox* StyleLB;
	Stdctrls::TGroupBox* OrientationL;
	Stdctrls::TGroupBox* LayoutL;
	Extctrls::TImage* PortraitImg;
	Extctrls::TImage* LandscapeImg;
	Stdctrls::TRadioButton* PortraitRB;
	Stdctrls::TRadioButton* LandscapeRB;
	Stdctrls::TRadioButton* TabularRB;
	Stdctrls::TRadioButton* ColumnarRB;
	Comctrls::TTabSheet* DataTab;
	Stdctrls::TComboBox* DatasetsCB;
	Stdctrls::TLabel* Step1L;
	Stdctrls::TButton* NewTableB;
	Stdctrls::TButton* NewQueryB;
	Forms::TScrollBox* ScrollBox2;
	Extctrls::TPaintBox* LayoutPB;
	Stdctrls::TLabel* AvailableFieldsL1;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall DatasetsCBClick(System::TObject* Sender);
	void __fastcall AddFieldBClick(System::TObject* Sender);
	void __fastcall AddAllFieldsBClick(System::TObject* Sender);
	void __fastcall RemoveFieldBClick(System::TObject* Sender);
	void __fastcall RemoveAllFieldsBClick(System::TObject* Sender);
	void __fastcall AddGroupBClick(System::TObject* Sender);
	void __fastcall RemoveGroupBClick(System::TObject* Sender);
	void __fastcall FieldUpBClick(System::TObject* Sender);
	void __fastcall FieldDownBClick(System::TObject* Sender);
	void __fastcall GroupUpBClick(System::TObject* Sender);
	void __fastcall GroupDownBClick(System::TObject* Sender);
	void __fastcall NextBClick(System::TObject* Sender);
	void __fastcall BackBClick(System::TObject* Sender);
	void __fastcall GroupsTabShow(System::TObject* Sender);
	void __fastcall StylePBPaint(System::TObject* Sender);
	void __fastcall PortraitRBClick(System::TObject* Sender);
	void __fastcall PagesChange(System::TObject* Sender);
	void __fastcall StyleLBClick(System::TObject* Sender);
	void __fastcall FinishBClick(System::TObject* Sender);
	void __fastcall NewTableBClick(System::TObject* Sender);
	void __fastcall NewQueryBClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall LayoutPBPaint(System::TObject* Sender);
	void __fastcall TabularRBClick(System::TObject* Sender);
	
private:
	Frxdesgn::TfrxDesignerForm* FDesigner;
	bool FDotMatrix;
	Frxclass::TfrxReport* FLayoutReport;
	Frxclass::TfrxReport* FReport;
	Frxclass::TfrxReport* FStyleReport;
	Frxclass::TfrxStyleSheet* FStyleSheet;
	void __fastcall DrawSample(Extctrls::TPaintBox* PaintBox, Frxclass::TfrxReport* Report);
	void __fastcall FillDatasets(void);
	void __fastcall FillFields(void);
	void __fastcall NewDBItem(const System::UnicodeString wizName);
	void __fastcall UpdateAvailableFields(void);
	
public:
	__fastcall virtual TfrxStdWizardForm(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxStdWizardForm(void);
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxStdWizardForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxStdWizardForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxstdwizard */
using namespace Frxstdwizard;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxstdwizardHPP
