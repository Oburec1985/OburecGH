// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportpdf.pas' rev: 21.00

#ifndef FrxexportpdfHPP
#define FrxexportpdfHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Frxrc4.hpp>	// Pascal unit
#include <Widestrings.hpp>	// Pascal unit
#include <Ansistrings.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#pragma link "usp10.lib"

namespace Frxexportpdf
{
//-- type declarations -------------------------------------------------------
typedef void * SCRIPT_CACHE;

typedef void * *PScriptCache;

struct SCRIPT_ANALYSIS
{
	
public:
	System::Word fFlags;
	System::Word s;
};


typedef SCRIPT_ANALYSIS *PScriptAnalysis;

struct SCRIPT_ITEM
{
	
public:
	int iCharPos;
	SCRIPT_ANALYSIS a;
};


typedef SCRIPT_ITEM *PScriptItem;

struct GOFFSET
{
	
public:
	int du;
	int dv;
};


typedef GOFFSET *PGOffset;

#pragma option push -b-
enum TfrxPDFEncBit { ePrint, eModify, eCopy, eAnnot };
#pragma option pop

typedef Set<TfrxPDFEncBit, ePrint, eAnnot>  TfrxPDFEncBits;

class DELPHICLASS TfrxPDFExportDialog;
class PASCALIMPLEMENTATION TfrxPDFExportDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TPageControl* PageControl1;
	Comctrls::TTabSheet* ExportPage;
	Comctrls::TTabSheet* InfoPage;
	Comctrls::TTabSheet* SecurityPage;
	Comctrls::TTabSheet* ViewerPage;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Dialogs::TSaveDialog* SaveDialog1;
	Stdctrls::TCheckBox* OpenCB;
	Stdctrls::TGroupBox* GroupQuality;
	Stdctrls::TCheckBox* CompressedCB;
	Stdctrls::TCheckBox* EmbeddedCB;
	Stdctrls::TCheckBox* PrintOptCB;
	Stdctrls::TCheckBox* OutlineCB;
	Stdctrls::TCheckBox* BackgrCB;
	Stdctrls::TGroupBox* GroupPageRange;
	Stdctrls::TLabel* DescrL;
	Stdctrls::TRadioButton* AllRB;
	Stdctrls::TRadioButton* CurPageRB;
	Stdctrls::TRadioButton* PageNumbersRB;
	Stdctrls::TEdit* PageNumbersE;
	Stdctrls::TGroupBox* SecGB;
	Stdctrls::TLabel* OwnPassL;
	Stdctrls::TLabel* UserPassL;
	Stdctrls::TEdit* OwnPassE;
	Stdctrls::TEdit* UserPassE;
	Stdctrls::TGroupBox* PermGB;
	Stdctrls::TCheckBox* PrintCB;
	Stdctrls::TCheckBox* ModCB;
	Stdctrls::TCheckBox* CopyCB;
	Stdctrls::TCheckBox* AnnotCB;
	Stdctrls::TGroupBox* DocInfoGB;
	Stdctrls::TLabel* TitleL;
	Stdctrls::TEdit* TitleE;
	Stdctrls::TEdit* AuthorE;
	Stdctrls::TLabel* AuthorL;
	Stdctrls::TLabel* SubjectL;
	Stdctrls::TEdit* SubjectE;
	Stdctrls::TLabel* KeywordsL;
	Stdctrls::TEdit* KeywordsE;
	Stdctrls::TEdit* CreatorE;
	Stdctrls::TLabel* CreatorL;
	Stdctrls::TLabel* ProducerL;
	Stdctrls::TEdit* ProducerE;
	Stdctrls::TGroupBox* ViewerGB;
	Stdctrls::TCheckBox* HideToolbarCB;
	Stdctrls::TCheckBox* HideMenubarCB;
	Stdctrls::TCheckBox* HideWindowUICB;
	Stdctrls::TCheckBox* FitWindowCB;
	Stdctrls::TCheckBox* CenterWindowCB;
	Stdctrls::TCheckBox* PrintScalingCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxPDFExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxPDFExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxPDFExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxPDFExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxPDFRun;
class PASCALIMPLEMENTATION TfrxPDFRun : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	SCRIPT_ANALYSIS analysis;
	System::WideString text;
	__fastcall TfrxPDFRun(System::WideString t, SCRIPT_ANALYSIS a);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxPDFRun(void) { }
	
};


class DELPHICLASS TfrxPDFFont;
class PASCALIMPLEMENTATION TfrxPDFFont : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Graphics::TBitmap* tempBitmap;
	void * *FUSCache;
	int __fastcall GetGlyphs(HDC hdc, TfrxPDFRun* run, PWORD glyphs, System::PInteger widths, int maxGlyphs, bool rtl);
	Classes::TList* __fastcall Itemize(System::WideString s, bool rtl, int maxItems);
	Classes::TList* __fastcall Layout(Classes::TList* runs, bool rtl);
	int __fastcall GetGlyphIndices(HDC hdc, System::WideString text, PWORD glyphs, System::PInteger widths, bool rtl);
	
public:
	int Index;
	Classes::TList* Widths;
	Classes::TList* UsedAlphabet;
	Classes::TList* UsedAlphabetUnicode;
	_OUTLINETEXTMETRICA *TextMetric;
	System::AnsiString Name;
	Graphics::TFont* SourceFont;
	int Reference;
	bool Saved;
	char *FontData;
	int FontDataSize;
	double PDFdpi_divider;
	double FDpiFX;
	__fastcall TfrxPDFFont(Graphics::TFont* Font);
	__fastcall virtual ~TfrxPDFFont(void);
	void __fastcall Cleanup(void);
	void __fastcall FillOutlineTextMetrix(void);
	void __fastcall GetFontFile(void);
	System::WideString __fastcall RemapString(System::WideString str, bool rtl);
	System::AnsiString __fastcall GetFontName(void);
};


class DELPHICLASS TfrxPDFOutlineNode;
class PASCALIMPLEMENTATION TfrxPDFOutlineNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	int Number;
	int Dest;
	int Top;
	int CountTree;
	int Count;
	System::UnicodeString Title;
	TfrxPDFOutlineNode* First;
	TfrxPDFOutlineNode* Last;
	TfrxPDFOutlineNode* Next;
	TfrxPDFOutlineNode* Prev;
	TfrxPDFOutlineNode* Parent;
	__fastcall TfrxPDFOutlineNode(void);
	__fastcall virtual ~TfrxPDFOutlineNode(void);
};


class DELPHICLASS TfrxPDFPage;
class PASCALIMPLEMENTATION TfrxPDFPage : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	double Height;
public:
	/* TObject.Create */ inline __fastcall TfrxPDFPage(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxPDFPage(void) { }
	
};


class DELPHICLASS TfrxPDFExport;
class PASCALIMPLEMENTATION TfrxPDFExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	bool FCompressed;
	bool FEmbedded;
	bool FEmbedProt;
	bool FOpenAfterExport;
	bool FPrintOpt;
	Classes::TList* FPages;
	bool FOutline;
	Frxclass::TfrxCustomOutline* FPreviewOutline;
	System::WideString FSubject;
	System::WideString FAuthor;
	bool FBackground;
	System::WideString FCreator;
	bool FTags;
	bool FProtection;
	System::AnsiString FUserPassword;
	System::AnsiString FOwnerPassword;
	TfrxPDFEncBits FProtectionFlags;
	System::WideString FKeywords;
	System::WideString FTitle;
	System::WideString FProducer;
	bool FPrintScaling;
	bool FFitWindow;
	bool FHideMenubar;
	bool FCenterWindow;
	bool FHideWindowUI;
	bool FHideToolbar;
	Classes::TStream* pdf;
	int FRootNumber;
	int FPagesNumber;
	int FInfoNumber;
	int FStartXRef;
	Classes::TList* FFonts;
	Classes::TList* FPageFonts;
	Classes::TStringList* FXRef;
	Classes::TStringList* FPagesRef;
	System::Extended FWidth;
	System::Extended FHeight;
	System::Extended FMarginLeft;
	System::Extended FMarginWoBottom;
	System::Extended FMarginTop;
	System::AnsiString FEncKey;
	System::AnsiString FOPass;
	System::AnsiString FUPass;
	unsigned FEncBits;
	System::AnsiString FFileID;
	System::Extended FDivider;
	Graphics::TColor FLastColor;
	System::UnicodeString FLastColorResult;
	Classes::TMemoryStream* OutStream;
	Classes::TMemoryStream* FAnnots;
	System::UnicodeString __fastcall PrepXrefPos(int pos);
	void __fastcall Write(Classes::TStream* Stream, const System::AnsiString S)/* overload */;
	void __fastcall Write(Classes::TStream* Stream, const System::UnicodeString S)/* overload */;
	void __fastcall WriteLn(Classes::TStream* Stream, const System::AnsiString S)/* overload */;
	void __fastcall WriteLn(Classes::TStream* Stream, const System::UnicodeString S)/* overload */;
	System::AnsiString __fastcall GetID(void);
	System::AnsiString __fastcall CryptStr(System::AnsiString Source, System::AnsiString Key, bool Enc, int id);
	System::AnsiString __fastcall CryptStream(Classes::TStream* Source, Classes::TStream* Target, System::AnsiString Key, int id);
	System::AnsiString __fastcall PrepareString(const System::WideString Text, System::AnsiString Key, bool Enc, int id);
	System::AnsiString __fastcall EscapeSpecialChar(System::AnsiString TextStr);
	System::AnsiString __fastcall StrToUTF16(const System::WideString Value);
	System::AnsiString __fastcall PMD52Str(void * p);
	System::AnsiString __fastcall PadPassword(System::AnsiString Password);
	void __fastcall PrepareKeys(void);
	void __fastcall SetProtectionFlags(const TfrxPDFEncBits Value);
	void __fastcall Clear(void);
	void __fastcall WriteFont(TfrxPDFFont* pdfFont);
	void __fastcall AddObject(const Frxclass::TfrxView* Obj);
	System::AnsiString __fastcall StrToHex(const System::WideString Value);
	TfrxPDFPage* __fastcall AddPage(Frxclass::TfrxReportPage* Page);
	System::UnicodeString __fastcall ObjNumber(int FNumber);
	System::UnicodeString __fastcall ObjNumberRef(int FNumber);
	int __fastcall UpdateXRef(void);
	System::UnicodeString __fastcall GetPDFColor(const Graphics::TColor Color);
	
public:
	__fastcall virtual TfrxPDFExport(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxPDFExport(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	virtual void __fastcall Finish(void);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	
__published:
	__property bool Compressed = {read=FCompressed, write=FCompressed, default=1};
	__property bool EmbeddedFonts = {read=FEmbedded, write=FEmbedded, default=0};
	__property bool EmbedFontsIfProtected = {read=FEmbedProt, write=FEmbedProt, default=1};
	__property bool OpenAfterExport = {read=FOpenAfterExport, write=FOpenAfterExport, default=0};
	__property bool PrintOptimized = {read=FPrintOpt, write=FPrintOpt, nodefault};
	__property bool Outline = {read=FOutline, write=FOutline, nodefault};
	__property bool Background = {read=FBackground, write=FBackground, nodefault};
	__property bool HTMLTags = {read=FTags, write=FTags, nodefault};
	__property OverwritePrompt;
	__property System::WideString Title = {read=FTitle, write=FTitle};
	__property System::WideString Author = {read=FAuthor, write=FAuthor};
	__property System::WideString Subject = {read=FSubject, write=FSubject};
	__property System::WideString Keywords = {read=FKeywords, write=FKeywords};
	__property System::WideString Creator = {read=FCreator, write=FCreator};
	__property System::WideString Producer = {read=FProducer, write=FProducer};
	__property System::AnsiString UserPassword = {read=FUserPassword, write=FUserPassword};
	__property System::AnsiString OwnerPassword = {read=FOwnerPassword, write=FOwnerPassword};
	__property TfrxPDFEncBits ProtectionFlags = {read=FProtectionFlags, write=SetProtectionFlags, nodefault};
	__property bool HideToolbar = {read=FHideToolbar, write=FHideToolbar, nodefault};
	__property bool HideMenubar = {read=FHideMenubar, write=FHideMenubar, nodefault};
	__property bool HideWindowUI = {read=FHideWindowUI, write=FHideWindowUI, nodefault};
	__property bool FitWindow = {read=FFitWindow, write=FFitWindow, nodefault};
	__property bool CenterWindow = {read=FCenterWindow, write=FCenterWindow, nodefault};
	__property bool PrintScaling = {read=FPrintScaling, write=FPrintScaling, nodefault};
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxPDFExport(void) : Frxclass::TfrxCustomExportFilter() { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern "C" HRESULT __stdcall ScriptFreeCache(PScriptCache psc);
extern "C" HRESULT __stdcall ScriptItemize(const System::WideChar * pwcInChars, int cInChars, int cMaxItems, const System::PInteger psControl, const PWORD psState, PScriptItem pItems, System::PInteger pcItems);
extern "C" HRESULT __stdcall ScriptLayout(int cRuns, const Frxrc4::PByte pbLevel, System::PInteger piVisualToLogical, System::PInteger piLogicalToVisual);
extern "C" HRESULT __stdcall ScriptShape(HDC hdc, PScriptCache psc, const System::WideChar * pwcChars, int cChars, int cMaxGlyphs, PScriptAnalysis psa, PWORD pwOutGlyphs, PWORD pwLogClust, PWORD psva, System::PInteger pcGlyphs);
extern "C" HRESULT __stdcall ScriptPlace(HDC hdc, PScriptCache psc, const PWORD pwGlyphs, int cGlyphs, const PWORD psva, PScriptAnalysis psa, System::PInteger piAdvance, const PGOffset pGoffset, PABC pABC);
extern PACKAGE System::AnsiString __fastcall PdfSetLineColor(Graphics::TColor Color);
extern PACKAGE System::AnsiString __fastcall PdfSetLineWidth(double Width);
extern PACKAGE System::AnsiString __fastcall PdfFillRect(double Left, double Bottom, double Right, double Top, Graphics::TColor Color);
extern PACKAGE System::AnsiString __fastcall PdfSetColor(Graphics::TColor Color);
extern PACKAGE System::AnsiString __fastcall PdfFill(void);
extern PACKAGE System::AnsiString __fastcall PdfPoint(double x, double y);
extern PACKAGE System::AnsiString __fastcall PdfLine(double x, double y);
extern PACKAGE System::AnsiString __fastcall PdfMove(double x, double y);
extern PACKAGE System::AnsiString __fastcall PdfColor(Graphics::TColor Color);

}	/* namespace Frxexportpdf */
using namespace Frxexportpdf;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportpdfHPP
