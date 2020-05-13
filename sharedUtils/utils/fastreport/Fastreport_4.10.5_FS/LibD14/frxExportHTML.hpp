// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexporthtml.pas' rev: 21.00

#ifndef FrxexporthtmlHPP
#define FrxexporthtmlHPP

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
#include <Jpeg.hpp>	// Pascal unit
#include <Shellapi.hpp>	// Pascal unit
#include <Frxexportmatrix.hpp>	// Pascal unit
#include <Frxprogress.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Frxexportimage.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexporthtml
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxHTMLExportDialog;
class PASCALIMPLEMENTATION TfrxHTMLExportDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Dialogs::TSaveDialog* SaveDialog1;
	Stdctrls::TGroupBox* GroupQuality;
	Stdctrls::TCheckBox* StylesCB;
	Stdctrls::TCheckBox* PicsSameCB;
	Stdctrls::TCheckBox* FixWidthCB;
	Stdctrls::TCheckBox* NavigatorCB;
	Stdctrls::TCheckBox* MultipageCB;
	Stdctrls::TGroupBox* GroupPageRange;
	Stdctrls::TLabel* DescrL;
	Stdctrls::TRadioButton* AllRB;
	Stdctrls::TRadioButton* CurPageRB;
	Stdctrls::TRadioButton* PageNumbersRB;
	Stdctrls::TEdit* PageNumbersE;
	Stdctrls::TCheckBox* OpenAfterCB;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TCheckBox* BackgrCB;
	Stdctrls::TLabel* PicturesL;
	Stdctrls::TComboBox* PFormatCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxHTMLExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxHTMLExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxHTMLExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxHTMLExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


typedef void __fastcall (__closure *TfrxHTMLExportGetNavTemplate)(const System::UnicodeString ReportName, bool Multipage, bool PicsInSameFolder, System::UnicodeString Prefix, int TotalPages, System::UnicodeString &Template);

typedef void __fastcall (__closure *TfrxHTMLExportGetMainTemplate)(const System::UnicodeString Title, const System::UnicodeString FrameFolder, bool Multipage, System::UnicodeString &Template);

class DELPHICLASS TfrxHTMLExport;
class PASCALIMPLEMENTATION TfrxHTMLExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	Classes::TStream* Exp;
	bool FAbsLinks;
	int FCurrentPage;
	bool FExportPictures;
	bool FExportStyles;
	bool FFixedWidth;
	Frxexportmatrix::TfrxIEMatrix* FMatrix;
	bool FMozillaBrowser;
	bool FMultipage;
	bool FNavigator;
	bool FOpenAfterExport;
	bool FPicsInSameFolder;
	int FPicturesCount;
	Frxprogress::TfrxProgress* FProgress;
	bool FUseJpeg;
	bool FServer;
	System::UnicodeString FPrintLink;
	System::UnicodeString FRefreshLink;
	bool FBackground;
	Graphics::TBitmap* FBackImage;
	bool FBackImageExist;
	System::UnicodeString FReportPath;
	bool FUseGif;
	bool FCentered;
	bool FEmptyLines;
	System::UnicodeString FURLTarget;
	bool FPrint;
	bool FUseTemplates;
	TfrxHTMLExportGetNavTemplate FGetNavTemplate;
	TfrxHTMLExportGetMainTemplate FGetMainTemplate;
	Classes::TStrings* FHTMLDocumentBegin;
	Classes::TStrings* FHTMLDocumentBody;
	Classes::TStrings* FHTMLDocumentEnd;
	void __fastcall WriteExpLn(const System::UnicodeString str);
	void __fastcall WriteExpLnA(const System::AnsiString str);
	void __fastcall ExportPage(void);
	System::UnicodeString __fastcall ChangeReturns(const System::UnicodeString Str);
	System::WideString __fastcall TruncReturns(const System::WideString Str);
	System::UnicodeString __fastcall GetPicsFolder(void);
	System::UnicodeString __fastcall GetPicsFolderRel(void);
	System::UnicodeString __fastcall GetFrameFolder(void);
	System::UnicodeString __fastcall ReverseSlash(const System::UnicodeString S);
	System::UnicodeString __fastcall HTMLCodeStr(const System::UnicodeString Str);
	void __fastcall SetUseGif(const bool Value);
	void __fastcall SetUseJpeg(const bool Value);
	
public:
	__fastcall virtual TfrxHTMLExport(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxHTMLExport(void);
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property bool Server = {read=FServer, write=FServer, nodefault};
	__property System::UnicodeString PrintLink = {read=FPrintLink, write=FPrintLink};
	__property System::UnicodeString RefreshLink = {read=FRefreshLink, write=FRefreshLink};
	__property System::UnicodeString ReportPath = {read=FReportPath, write=FReportPath};
	__property bool UseTemplates = {read=FUseTemplates, write=FUseTemplates, nodefault};
	__property TfrxHTMLExportGetMainTemplate OnGetMainTemplate = {read=FGetMainTemplate, write=FGetMainTemplate};
	__property TfrxHTMLExportGetNavTemplate OnGetNavTemplate = {read=FGetNavTemplate, write=FGetNavTemplate};
	
__published:
	__property bool OpenAfterExport = {read=FOpenAfterExport, write=FOpenAfterExport, default=0};
	__property bool FixedWidth = {read=FFixedWidth, write=FFixedWidth, default=0};
	__property bool ExportPictures = {read=FExportPictures, write=FExportPictures, default=1};
	__property bool PicsInSameFolder = {read=FPicsInSameFolder, write=FPicsInSameFolder, default=0};
	__property bool ExportStyles = {read=FExportStyles, write=FExportStyles, default=1};
	__property bool Navigator = {read=FNavigator, write=FNavigator, default=0};
	__property bool Multipage = {read=FMultipage, write=FMultipage, default=0};
	__property bool MozillaFrames = {read=FMozillaBrowser, write=FMozillaBrowser, default=0};
	__property bool UseJpeg = {read=FUseJpeg, write=SetUseJpeg, default=1};
	__property bool UseGif = {read=FUseGif, write=SetUseGif, default=0};
	__property bool AbsLinks = {read=FAbsLinks, write=FAbsLinks, default=0};
	__property bool Background = {read=FBackground, write=FBackground, nodefault};
	__property bool Centered = {read=FCentered, write=FCentered, nodefault};
	__property bool EmptyLines = {read=FEmptyLines, write=FEmptyLines, nodefault};
	__property OverwritePrompt;
	__property Classes::TStrings* HTMLDocumentBegin = {read=FHTMLDocumentBegin};
	__property Classes::TStrings* HTMLDocumentBody = {read=FHTMLDocumentBody};
	__property Classes::TStrings* HTMLDocumentEnd = {read=FHTMLDocumentEnd};
	__property System::UnicodeString URLTarget = {read=FURLTarget, write=FURLTarget};
	__property bool Print = {read=FPrint, write=FPrint, nodefault};
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxHTMLExport(void) : Frxclass::TfrxCustomExportFilter() { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexporthtml */
using namespace Frxexporthtml;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexporthtmlHPP
