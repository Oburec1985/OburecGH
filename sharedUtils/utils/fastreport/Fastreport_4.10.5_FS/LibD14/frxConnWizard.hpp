// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxconnwizard.pas' rev: 21.00

#ifndef FrxconnwizardHPP
#define FrxconnwizardHPP

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
#include <Buttons.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxsynmemo.hpp>	// Pascal unit
#include <Frxcustomdb.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Fqbclass.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxconnwizard
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxDBConnWizard;
class PASCALIMPLEMENTATION TfrxDBConnWizard : public Frxclass::TfrxCustomWizard
{
	typedef Frxclass::TfrxCustomWizard inherited;
	
private:
	Frxclass::TfrxCustomDatabase* FDatabase;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void);
	__property Frxclass::TfrxCustomDatabase* Database = {read=FDatabase, write=FDatabase};
public:
	/* TfrxCustomWizard.Create */ inline __fastcall virtual TfrxDBConnWizard(Classes::TComponent* AOwner) : Frxclass::TfrxCustomWizard(AOwner) { }
	
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxDBConnWizard(void) { }
	
};


class DELPHICLASS TfrxDBTableWizard;
class PASCALIMPLEMENTATION TfrxDBTableWizard : public Frxclass::TfrxCustomWizard
{
	typedef Frxclass::TfrxCustomWizard inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void);
public:
	/* TfrxCustomWizard.Create */ inline __fastcall virtual TfrxDBTableWizard(Classes::TComponent* AOwner) : Frxclass::TfrxCustomWizard(AOwner) { }
	
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxDBTableWizard(void) { }
	
};


class DELPHICLASS TfrxDBQueryWizard;
class PASCALIMPLEMENTATION TfrxDBQueryWizard : public Frxclass::TfrxCustomWizard
{
	typedef Frxclass::TfrxCustomWizard inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void);
public:
	/* TfrxCustomWizard.Create */ inline __fastcall virtual TfrxDBQueryWizard(Classes::TComponent* AOwner) : Frxclass::TfrxCustomWizard(AOwner) { }
	
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxDBQueryWizard(void) { }
	
};


class DELPHICLASS TfrxConnectionWizardForm;
class PASCALIMPLEMENTATION TfrxConnectionWizardForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OKB;
	Stdctrls::TButton* CancelB;
	Comctrls::TPageControl* PageControl1;
	Comctrls::TTabSheet* ConnTS;
	Comctrls::TTabSheet* TableTS;
	Stdctrls::TLabel* ConnL1;
	Stdctrls::TLabel* DBL;
	Stdctrls::TLabel* LoginL;
	Stdctrls::TLabel* PasswordL;
	Buttons::TSpeedButton* ChooseB;
	Stdctrls::TComboBox* ConnCB;
	Stdctrls::TEdit* DatabaseE;
	Stdctrls::TEdit* LoginE;
	Stdctrls::TEdit* PasswordE;
	Stdctrls::TRadioButton* PromptRB;
	Stdctrls::TRadioButton* LoginRB;
	Stdctrls::TLabel* ConnL2;
	Stdctrls::TComboBox* ConnCB1;
	Stdctrls::TLabel* TableL;
	Stdctrls::TComboBox* TableCB;
	Stdctrls::TCheckBox* FilterCB;
	Stdctrls::TEdit* FilterE;
	Comctrls::TTabSheet* QueryTS;
	Stdctrls::TLabel* ConnL3;
	Stdctrls::TComboBox* ConnCB2;
	Stdctrls::TLabel* QueryL;
	Comctrls::TToolBar* ToolBar1;
	Comctrls::TToolButton* BuildSQLB;
	Comctrls::TToolButton* ParamsB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall ChooseBClick(System::TObject* Sender);
	void __fastcall ConnCBClick(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall ConnCB1Click(System::TObject* Sender);
	void __fastcall ConnCB2Click(System::TObject* Sender);
	void __fastcall BuildSQLBClick(System::TObject* Sender);
	void __fastcall ParamsBClick(System::TObject* Sender);
	void __fastcall OKBClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Frxclass::TfrxComponent* FComponent;
	Frxclass::TfrxCustomDatabase* FDatabase;
	Frxclass::TfrxCustomDesigner* FDesigner;
	int FItem;
	int FItemIndex;
	Frxsynmemo::TfrxSyntaxMemo* FMemo;
	int FOldItem;
	Frxclass::TfrxPage* FPage;
	Frxcustomdb::TfrxCustomQuery* FQuery;
	Frxclass::TfrxReport* FReport;
	Frxcustomdb::TfrxCustomTable* FTable;
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxConnectionWizardForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxConnectionWizardForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxConnectionWizardForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxConnectionWizardForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxconnwizard */
using namespace Frxconnwizard;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxconnwizardHPP
