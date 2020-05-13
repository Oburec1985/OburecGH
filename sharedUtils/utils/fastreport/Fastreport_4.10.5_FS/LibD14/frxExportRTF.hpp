// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportrtf.pas' rev: 21.00

#ifndef FrxexportrtfHPP
#define FrxexportrtfHPP

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
#include <Comobj.hpp>	// Pascal unit
#include <Printers.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Jpeg.hpp>	// Pascal unit
#include <Shellapi.hpp>	// Pascal unit
#include <Frxexportmatrix.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Frxprogress.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Frxgraphicutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexportrtf
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxHeaderFooterMode { hfText, hfPrint, hfNone };
#pragma option pop

class DELPHICLASS TfrxRTFExportDialog;
class PASCALIMPLEMENTATION TfrxRTFExportDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TGroupBox* GroupPageRange;
	Stdctrls::TLabel* DescrL;
	Stdctrls::TRadioButton* AllRB;
	Stdctrls::TRadioButton* CurPageRB;
	Stdctrls::TRadioButton* PageNumbersRB;
	Stdctrls::TEdit* PageNumbersE;
	Stdctrls::TGroupBox* GroupQuality;
	Stdctrls::TCheckBox* WCB;
	Stdctrls::TCheckBox* PageBreaksCB;
	Stdctrls::TCheckBox* PicturesCB;
	Stdctrls::TCheckBox* OpenCB;
	Dialogs::TSaveDialog* SaveDialog1;
	Stdctrls::TCheckBox* ContinuousCB;
	Stdctrls::TLabel* HeadFootL;
	Stdctrls::TComboBox* PColontitulCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxRTFExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxRTFExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxRTFExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxRTFExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxRTFExport;
class PASCALIMPLEMENTATION TfrxRTFExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	Classes::TStringList* FColorTable;
	int FCurrentPage;
	Classes::TList* FDataList;
	bool FExportPageBreaks;
	bool FExportPictures;
	bool FFirstPage;
	Classes::TStringList* FFontTable;
	Classes::TStringList* FCharsetTable;
	Frxexportmatrix::TfrxIEMatrix* FMatrix;
	bool FOpenAfterExport;
	Frxprogress::TfrxProgress* FProgress;
	bool FWysiwyg;
	System::UnicodeString FCreator;
	TfrxHeaderFooterMode FHeaderFooterMode;
	bool FAutoSize;
	bool FExportEMF;
	System::WideString __fastcall TruncReturns(const System::WideString Str);
	System::UnicodeString __fastcall GetRTFBorders(const Frxexportmatrix::TfrxIEMStyle* Style);
	System::UnicodeString __fastcall GetRTFColor(const unsigned c);
	System::UnicodeString __fastcall GetRTFFontStyle(const Graphics::TFontStyles f);
	System::UnicodeString __fastcall GetRTFFontColor(const System::UnicodeString f);
	System::UnicodeString __fastcall GetRTFFontName(const System::UnicodeString f, const int charset);
	System::UnicodeString __fastcall GetRTFHAlignment(const Frxclass::TfrxHAlign HAlign);
	System::UnicodeString __fastcall GetRTFVAlignment(const Frxclass::TfrxVAlign VAlign);
	System::WideString __fastcall StrToRTFSlash(const System::WideString Value);
	System::UnicodeString __fastcall StrToRTFUnicodeEx(const System::WideString Value);
	System::UnicodeString __fastcall StrToRTFUnicode(const System::WideString Value);
	void __fastcall ExportPage(const Classes::TStream* Stream);
	void __fastcall PrepareExport(void);
	
public:
	__fastcall virtual TfrxRTFExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	
__published:
	__property bool ExportEMF = {read=FExportEMF, write=FExportEMF, nodefault};
	__property bool ExportPageBreaks = {read=FExportPageBreaks, write=FExportPageBreaks, default=1};
	__property bool ExportPictures = {read=FExportPictures, write=FExportPictures, default=1};
	__property bool OpenAfterExport = {read=FOpenAfterExport, write=FOpenAfterExport, default=0};
	__property bool Wysiwyg = {read=FWysiwyg, write=FWysiwyg, nodefault};
	__property System::UnicodeString Creator = {read=FCreator, write=FCreator};
	__property SuppressPageHeadersFooters;
	__property TfrxHeaderFooterMode HeaderFooterMode = {read=FHeaderFooterMode, write=FHeaderFooterMode, nodefault};
	__property bool AutoSize = {read=FAutoSize, write=FAutoSize, nodefault};
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxRTFExport(void) : Frxclass::TfrxCustomExportFilter() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxRTFExport(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexportrtf */
using namespace Frxexportrtf;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportrtfHPP
