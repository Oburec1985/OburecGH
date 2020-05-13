// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportxls.pas' rev: 21.00

#ifndef FrxexportxlsHPP
#define FrxexportxlsHPP

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
#include <Printers.hpp>	// Pascal unit
#include <Comobj.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxprogress.hpp>	// Pascal unit
#include <Frxexportmatrix.hpp>	// Pascal unit
#include <Clipbrd.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexportxls
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxXLSExportDialog;
class PASCALIMPLEMENTATION TfrxXLSExportDialog : public Forms::TForm
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
	Stdctrls::TCheckBox* MergeCB;
	Stdctrls::TCheckBox* WCB;
	Stdctrls::TCheckBox* ContinuousCB;
	Stdctrls::TCheckBox* PicturesCB;
	Stdctrls::TCheckBox* OpenExcelCB;
	Stdctrls::TCheckBox* AsTextCB;
	Stdctrls::TCheckBox* BackgrCB;
	Stdctrls::TCheckBox* FastExpCB;
	Stdctrls::TCheckBox* PageBreaksCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxXLSExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxXLSExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxXLSExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxXLSExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxXLSExport;
class DELPHICLASS TfrxExcel;
class PASCALIMPLEMENTATION TfrxXLSExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	TfrxExcel* FExcel;
	bool FExportPictures;
	bool FExportStyles;
	bool FFirstPage;
	Frxexportmatrix::TfrxIEMatrix* FMatrix;
	bool FMergeCells;
	bool FOpenExcelAfterExport;
	System::Extended FPageBottom;
	System::Extended FPageLeft;
	System::Extended FPageRight;
	System::Extended FPageTop;
	Printers::TPrinterOrientation FPageOrientation;
	Frxprogress::TfrxProgress* FProgress;
	bool FWysiwyg;
	bool FAsText;
	bool FBackground;
	bool FFastExport;
	bool FpageBreaks;
	bool FEmptyLines;
	bool FExportEMF;
	bool FTruncateLongTexts;
	void __fastcall ExportPage_Fast(void);
	void __fastcall ExportPage(void);
	System::WideString __fastcall CleanReturns(const System::WideString Str);
	System::Byte __fastcall FrameTypesToByte(Frxclass::TfrxFrameTypes Value);
	int __fastcall GetNewIndex(Classes::TStrings* Strings, int ObjValue);
	
public:
	__fastcall virtual TfrxXLSExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	
__published:
	__property bool ExportEMF = {read=FExportEMF, write=FExportEMF, nodefault};
	__property bool ExportStyles = {read=FExportStyles, write=FExportStyles, default=1};
	__property bool ExportPictures = {read=FExportPictures, write=FExportPictures, default=1};
	__property bool MergeCells = {read=FMergeCells, write=FMergeCells, default=1};
	__property bool OpenExcelAfterExport = {read=FOpenExcelAfterExport, write=FOpenExcelAfterExport, default=0};
	__property bool Wysiwyg = {read=FWysiwyg, write=FWysiwyg, default=1};
	__property bool AsText = {read=FAsText, write=FAsText, nodefault};
	__property bool Background = {read=FBackground, write=FBackground, nodefault};
	__property bool FastExport = {read=FFastExport, write=FFastExport, nodefault};
	__property bool PageBreaks = {read=FpageBreaks, write=FpageBreaks, nodefault};
	__property bool EmptyLines = {read=FEmptyLines, write=FEmptyLines, nodefault};
	__property SuppressPageHeadersFooters;
	__property OverwritePrompt;
	__property bool TruncateLongTexts = {read=FTruncateLongTexts, write=FTruncateLongTexts, default=1};
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxXLSExport(void) : Frxclass::TfrxCustomExportFilter() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxXLSExport(void) { }
	
};


class PASCALIMPLEMENTATION TfrxExcel : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FIsOpened;
	bool FIsVisible;
	System::Variant Excel;
	System::Variant WorkBook;
	System::Variant WorkSheet;
	System::Variant Range;
	Frxclass::TfrxFrameTypes __fastcall ByteToFrameTypes(System::Byte Value);
	
protected:
	System::UnicodeString __fastcall IntToCoord(int X, int Y);
	System::UnicodeString __fastcall Pos2Str(int Pos);
	void __fastcall SetVisible(bool DoShow);
	void __fastcall ApplyStyles(Classes::TStrings* aRanges, System::Byte Kind, Frxprogress::TfrxProgress* aProgress);
	void __fastcall ApplyFrame(const System::UnicodeString RangeCoord, System::Byte aFrame);
	void __fastcall SetRowsSize(Classes::TStrings* aRanges, System::Currency *Sizes, const int Sizes_Size, int MainSizeIndex, int RowsCount, Frxprogress::TfrxProgress* aProgress);
	void __fastcall ApplyStyle(const System::UnicodeString RangeCoord, int aStyle);
	void __fastcall ApplyFormats(Classes::TStringList* aRanges, Frxprogress::TfrxProgress* aProgress);
	void __fastcall ApplyFormat(const System::UnicodeString RangeCoord, const System::UnicodeString aFormat);
	
public:
	__fastcall TfrxExcel(void);
	__fastcall virtual ~TfrxExcel(void);
	void __fastcall MergeCells(void);
	void __fastcall SetCellFrame(Frxclass::TfrxFrameTypes Frame);
	void __fastcall SetRowSize(int y, System::Extended Size);
	void __fastcall OpenExcel(void);
	void __fastcall SetColSize(int x, System::Extended Size);
	void __fastcall SetPageMargin(System::Extended Left, System::Extended Right, System::Extended Top, System::Extended Bottom, Printers::TPrinterOrientation Orientation);
	void __fastcall SetRange(int x, int y, int dx, int dy);
	__property bool Visible = {read=FIsVisible, write=SetVisible, nodefault};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexportxls */
using namespace Frxexportxls;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportxlsHPP
