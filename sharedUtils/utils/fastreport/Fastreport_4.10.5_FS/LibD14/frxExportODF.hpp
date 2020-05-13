// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportodf.pas' rev: 21.00

#ifndef FrxexportodfHPP
#define FrxexportodfHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Frxexportmatrix.hpp>	// Pascal unit
#include <Frxprogress.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Shellapi.hpp>	// Pascal unit
#include <Frxzip.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexportodf
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxODFExportDialog;
class PASCALIMPLEMENTATION TfrxODFExportDialog : public Forms::TForm
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
	Stdctrls::TCheckBox* OpenCB;
	Stdctrls::TCheckBox* BackgrCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxODFExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxODFExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxODFExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxODFExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxODFExport;
class PASCALIMPLEMENTATION TfrxODFExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	bool FExportPageBreaks;
	bool FExportStyles;
	bool FFirstPage;
	Frxexportmatrix::TfrxIEMatrix* FMatrix;
	bool FOpenAfterExport;
	System::Extended FPageBottom;
	System::Extended FPageLeft;
	System::Extended FPageRight;
	System::Extended FPageTop;
	System::Extended FPageWidth;
	System::Extended FPageHeight;
	Printers::TPrinterOrientation FPageOrientation;
	bool FWysiwyg;
	bool FBackground;
	System::UnicodeString FCreator;
	bool FEmptyLines;
	System::UnicodeString FTempFolder;
	Frxzip::TfrxZipArchive* FZipFile;
	Extctrls::TImage* FThumbImage;
	Frxprogress::TfrxProgress* FProgress;
	System::UnicodeString FExportType;
	bool FExportEMF;
	void __fastcall DoOnProgress(System::TObject* Sender);
	System::WideString __fastcall OdfPrepareString(const System::WideString Str);
	System::UnicodeString __fastcall OdfGetFrameName(const Frxclass::TfrxFrameStyle FrameStyle);
	void __fastcall OdfMakeHeader(const Frxxml::TfrxXMLItem* Item);
	void __fastcall OdfCreateMeta(const System::UnicodeString FileName, const System::UnicodeString Creator);
	void __fastcall OdfCreateManifest(const System::UnicodeString FileName, const int PicCount, const System::UnicodeString MValue);
	void __fastcall OdfCreateMime(const System::UnicodeString FileName, const System::UnicodeString MValue);
	
public:
	__fastcall virtual TfrxODFExport(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxODFExport(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	__property System::UnicodeString ExportType = {read=FExportType, write=FExportType};
	__property ExportTitle;
	
protected:
	void __fastcall ExportPage(Classes::TStream* Stream);
	
__published:
	__property bool ExportEMF = {read=FExportEMF, write=FExportEMF, nodefault};
	__property bool ExportStyles = {read=FExportStyles, write=FExportStyles, default=1};
	__property bool ExportPageBreaks = {read=FExportPageBreaks, write=FExportPageBreaks, default=1};
	__property bool OpenAfterExport = {read=FOpenAfterExport, write=FOpenAfterExport, default=0};
	__property bool Wysiwyg = {read=FWysiwyg, write=FWysiwyg, default=1};
	__property bool Background = {read=FBackground, write=FBackground, default=0};
	__property System::UnicodeString Creator = {read=FCreator, write=FCreator};
	__property bool EmptyLines = {read=FEmptyLines, write=FEmptyLines, nodefault};
	__property SuppressPageHeadersFooters;
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxODFExport(void) : Frxclass::TfrxCustomExportFilter() { }
	
};


class DELPHICLASS TfrxODSExport;
class PASCALIMPLEMENTATION TfrxODSExport : public TfrxODFExport
{
	typedef TfrxODFExport inherited;
	
public:
	__fastcall virtual TfrxODSExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property ExportTitle;
	
__published:
	__property ExportStyles = {default=1};
	__property ExportPageBreaks = {default=1};
	__property OpenAfterExport = {default=0};
	__property ShowProgress;
	__property Wysiwyg = {default=1};
	__property Background = {default=0};
	__property Creator;
	__property EmptyLines;
	__property SuppressPageHeadersFooters;
	__property OverwritePrompt;
public:
	/* TfrxODFExport.Destroy */ inline __fastcall virtual ~TfrxODSExport(void) { }
	
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxODSExport(void) : TfrxODFExport() { }
	
};


class DELPHICLASS TfrxODTExport;
class PASCALIMPLEMENTATION TfrxODTExport : public TfrxODFExport
{
	typedef TfrxODFExport inherited;
	
public:
	__fastcall virtual TfrxODTExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property ExportStyles = {default=1};
	__property ExportPageBreaks = {default=1};
	__property OpenAfterExport = {default=0};
	__property ShowProgress;
	__property Wysiwyg = {default=1};
	__property Background = {default=0};
	__property Creator;
	__property EmptyLines;
	__property SuppressPageHeadersFooters;
	__property OverwritePrompt;
public:
	/* TfrxODFExport.Destroy */ inline __fastcall virtual ~TfrxODTExport(void) { }
	
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxODTExport(void) : TfrxODFExport() { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexportodf */
using namespace Frxexportodf;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportodfHPP
