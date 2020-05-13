// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexporttext.pas' rev: 21.00

#ifndef FrxexporttextHPP
#define FrxexporttextHPP

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

namespace Frxexporttext
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxSimpleTextExportDialog;
class PASCALIMPLEMENTATION TfrxSimpleTextExportDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Dialogs::TSaveDialog* SaveDialog1;
	Stdctrls::TGroupBox* GroupPageRange;
	Stdctrls::TLabel* DescrL;
	Stdctrls::TRadioButton* AllRB;
	Stdctrls::TRadioButton* CurPageRB;
	Stdctrls::TRadioButton* PageNumbersRB;
	Stdctrls::TEdit* PageNumbersE;
	Stdctrls::TGroupBox* GroupQuality;
	Stdctrls::TCheckBox* PageBreaksCB;
	Stdctrls::TCheckBox* OpenCB;
	Stdctrls::TCheckBox* FramesCB;
	Stdctrls::TCheckBox* EmptyLinesCB;
	Stdctrls::TCheckBox* OEMCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxSimpleTextExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxSimpleTextExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxSimpleTextExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxSimpleTextExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxSimpleTextExport;
class PASCALIMPLEMENTATION TfrxSimpleTextExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	bool FPageBreaks;
	Frxexportmatrix::TfrxIEMatrix* FMatrix;
	bool FOpenAfterExport;
	Classes::TStream* Exp;
	Frxclass::TfrxReportPage* FPage;
	bool FFrames;
	System::Extended pX;
	System::Extended pY;
	System::Extended pT;
	bool FEmptyLines;
	bool FOEM;
	void __fastcall ExportPage(Classes::TStream* Stream);
	
public:
	__fastcall virtual TfrxSimpleTextExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	
__published:
	__property bool PageBreaks = {read=FPageBreaks, write=FPageBreaks, default=1};
	__property bool Frames = {read=FFrames, write=FFrames, nodefault};
	__property bool EmptyLines = {read=FEmptyLines, write=FEmptyLines, nodefault};
	__property bool OEMCodepage = {read=FOEM, write=FOEM, nodefault};
	__property bool OpenAfterExport = {read=FOpenAfterExport, write=FOpenAfterExport, default=0};
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxSimpleTextExport(void) : Frxclass::TfrxCustomExportFilter() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxSimpleTextExport(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexporttext */
using namespace Frxexporttext;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexporttextHPP
