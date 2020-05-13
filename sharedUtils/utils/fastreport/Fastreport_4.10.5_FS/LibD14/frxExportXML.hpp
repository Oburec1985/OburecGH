// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportxml.pas' rev: 21.00

#ifndef FrxexportxmlHPP
#define FrxexportxmlHPP

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
#include <Printers.hpp>	// Pascal unit
#include <Comobj.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxexportmatrix.hpp>	// Pascal unit
#include <Frxprogress.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexportxml
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxSplitToSheet { ssNotSplit, ssRPages, ssPrintOnPrev, ssRowsCount };
#pragma option pop

class DELPHICLASS TfrxXMLExportDialog;
class PASCALIMPLEMENTATION TfrxXMLExportDialog : public Forms::TForm
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
	Stdctrls::TCheckBox* WCB;
	Stdctrls::TCheckBox* ContinuousCB;
	Stdctrls::TCheckBox* PageBreaksCB;
	Stdctrls::TCheckBox* OpenExcelCB;
	Stdctrls::TCheckBox* BackgrCB;
	Stdctrls::TGroupBox* SplitToSheetGB;
	Stdctrls::TRadioButton* RPagesRB;
	Stdctrls::TRadioButton* PrintOnPrevRB;
	Stdctrls::TRadioButton* RowsCountRB;
	Stdctrls::TEdit* ERows;
	Stdctrls::TRadioButton* NotSplitRB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall ERowsKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall ERowsChange(System::TObject* Sender);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxXMLExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxXMLExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxXMLExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxXMLExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxXMLExport;
class PASCALIMPLEMENTATION TfrxXMLExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	bool FExportPageBreaks;
	bool FExportStyles;
	bool FFirstPage;
	Frxexportmatrix::TfrxIEMatrix* FMatrix;
	bool FOpenExcelAfterExport;
	System::Extended FPageBottom;
	System::Extended FPageLeft;
	System::Extended FPageRight;
	System::Extended FPageTop;
	Printers::TPrinterOrientation FPageOrientation;
	Frxprogress::TfrxProgress* FProgress;
	bool FShowProgress;
	bool FWysiwyg;
	bool FBackground;
	System::UnicodeString FCreator;
	bool FEmptyLines;
	int FRowsCount;
	TfrxSplitToSheet FSplit;
	void __fastcall ExportPage(Classes::TStream* Stream);
	System::UnicodeString __fastcall ChangeReturns(const System::UnicodeString Str);
	System::WideString __fastcall TruncReturns(const System::WideString Str);
	void __fastcall SetRowsCount(const int Value);
	
public:
	__fastcall virtual TfrxXMLExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	
__published:
	__property bool ExportStyles = {read=FExportStyles, write=FExportStyles, default=1};
	__property bool ExportPageBreaks = {read=FExportPageBreaks, write=FExportPageBreaks, default=1};
	__property bool OpenExcelAfterExport = {read=FOpenExcelAfterExport, write=FOpenExcelAfterExport, default=0};
	__property bool ShowProgress = {read=FShowProgress, write=FShowProgress, nodefault};
	__property bool Wysiwyg = {read=FWysiwyg, write=FWysiwyg, default=1};
	__property bool Background = {read=FBackground, write=FBackground, default=0};
	__property System::UnicodeString Creator = {read=FCreator, write=FCreator};
	__property bool EmptyLines = {read=FEmptyLines, write=FEmptyLines, nodefault};
	__property SuppressPageHeadersFooters;
	__property OverwritePrompt;
	__property int RowsCount = {read=FRowsCount, write=SetRowsCount, nodefault};
	__property TfrxSplitToSheet Split = {read=FSplit, write=FSplit, nodefault};
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxXMLExport(void) : Frxclass::TfrxCustomExportFilter() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxXMLExport(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexportxml */
using namespace Frxexportxml;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportxmlHPP
