// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportdbf.pas' rev: 21.00

#ifndef FrxexportdbfHPP
#define FrxexportdbfHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Frxexportmatrix.hpp>	// Pascal unit
#include <Shellapi.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexportdbf
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxDBFExportDialog;
class PASCALIMPLEMENTATION TfrxDBFExportDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Dialogs::TSaveDialog* sd;
	Stdctrls::TGroupBox* GroupPageRange;
	Stdctrls::TLabel* DescrL;
	Stdctrls::TRadioButton* AllRB;
	Stdctrls::TRadioButton* CurPageRB;
	Stdctrls::TRadioButton* PageNumbersRB;
	Stdctrls::TEdit* PageNumbersE;
	Stdctrls::TGroupBox* GroupQuality;
	Stdctrls::TCheckBox* OpenCB;
	Stdctrls::TCheckBox* OEMCB;
	Stdctrls::TGroupBox* gbFNames;
	Stdctrls::TRadioButton* rbFNAuto;
	Stdctrls::TRadioButton* rbFNManual;
	Stdctrls::TButton* btFNLoad;
	Dialogs::TOpenDialog* odFN;
	Stdctrls::TMemo* mmFN;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall btFNLoadClick(System::TObject* Sender);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxDBFExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxDBFExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxDBFExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxDBFExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxDBFExport;
class PASCALIMPLEMENTATION TfrxDBFExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	bool FOpenAfterExport;
	Frxexportmatrix::TfrxIEMatrix* FMatrix;
	Classes::TStream* Exp;
	bool FOEM;
	Classes::TStrings* FFieldNames;
	System::AnsiString FFieldPrefix;
	void __fastcall SetFieldNames(Classes::TStrings* Value);
	void __fastcall ExportMatrix(Classes::TStream* Stream, Frxexportmatrix::TfrxIEMatrix* mx);
	void __fastcall SetFieldPrefix(const System::AnsiString Value);
	
public:
	__fastcall virtual TfrxDBFExport(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDBFExport(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	
__published:
	__property bool OEMCodepage = {read=FOEM, write=FOEM, nodefault};
	__property bool OpenAfterExport = {read=FOpenAfterExport, write=FOpenAfterExport, default=0};
	__property OverwritePrompt;
	__property System::AnsiString FieldPrefix = {read=FFieldPrefix, write=SetFieldPrefix};
	__property Classes::TStrings* FieldNames = {read=FFieldNames, write=SetFieldNames};
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxDBFExport(void) : Frxclass::TfrxCustomExportFilter() { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexportdbf */
using namespace Frxexportdbf;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportdbfHPP
