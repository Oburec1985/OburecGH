// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportimage.pas' rev: 21.00

#ifndef FrxexportimageHPP
#define FrxexportimageHPP

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
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexportimage
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxCustomImageExport;
class PASCALIMPLEMENTATION TfrxCustomImageExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	Graphics::TBitmap* FBitmap;
	bool FCrop;
	int FCurrentPage;
	int FJPEGQuality;
	int FMaxX;
	int FMaxY;
	int FMinX;
	int FMinY;
	bool FMonochrome;
	int FResolution;
	int FCurrentRes;
	bool FSeparate;
	int FYOffset;
	System::UnicodeString FFileSuffix;
	bool FFirstPage;
	bool FExportNotPrintable;
	bool __fastcall SizeOverflow(const System::Extended Val);
	
protected:
	double FPaperWidth;
	double FPaperHeight;
	System::Extended FDiv;
	virtual void __fastcall Save(void);
	virtual void __fastcall FinishExport(void);
	
public:
	__fastcall virtual TfrxCustomImageExport(Classes::TComponent* AOwner);
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	__property int JPEGQuality = {read=FJPEGQuality, write=FJPEGQuality, default=90};
	__property bool CropImages = {read=FCrop, write=FCrop, default=0};
	__property bool Monochrome = {read=FMonochrome, write=FMonochrome, default=0};
	__property int Resolution = {read=FResolution, write=FResolution, nodefault};
	__property bool SeparateFiles = {read=FSeparate, write=FSeparate, nodefault};
	__property bool ExportNotPrintable = {read=FExportNotPrintable, write=FExportNotPrintable, nodefault};
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxCustomImageExport(void) : Frxclass::TfrxCustomExportFilter() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxCustomImageExport(void) { }
	
};


class DELPHICLASS TfrxEMFExport;
class PASCALIMPLEMENTATION TfrxEMFExport : public TfrxCustomImageExport
{
	typedef TfrxCustomImageExport inherited;
	
private:
	Graphics::TMetafile* FMetafile;
	Graphics::TMetafileCanvas* FMetafileCanvas;
	
protected:
	virtual void __fastcall FinishExport(void);
	
public:
	virtual bool __fastcall Start(void);
	virtual void __fastcall StartPage(Frxclass::TfrxReportPage* Page, int Index);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	__fastcall virtual TfrxEMFExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property CropImages = {default=0};
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxEMFExport(void) : TfrxCustomImageExport() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxEMFExport(void) { }
	
};


class DELPHICLASS TfrxBMPExport;
class PASCALIMPLEMENTATION TfrxBMPExport : public TfrxCustomImageExport
{
	typedef TfrxCustomImageExport inherited;
	
protected:
	virtual void __fastcall Save(void);
	
public:
	__fastcall virtual TfrxBMPExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property CropImages = {default=0};
	__property Monochrome = {default=0};
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxBMPExport(void) : TfrxCustomImageExport() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxBMPExport(void) { }
	
};


class DELPHICLASS TfrxTIFFExport;
class PASCALIMPLEMENTATION TfrxTIFFExport : public TfrxCustomImageExport
{
	typedef TfrxCustomImageExport inherited;
	
private:
	bool FMultiImage;
	void __fastcall SaveTiffToStream(const Classes::TStream* Stream, const Graphics::TBitmap* Bitmap, bool Split, bool WriteHeader = true);
	
protected:
	virtual void __fastcall Save(void);
	
public:
	__fastcall virtual TfrxTIFFExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property CropImages = {default=0};
	__property Monochrome = {default=0};
	__property OverwritePrompt;
	__property bool MultiImage = {read=FMultiImage, write=FMultiImage, default=0};
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxTIFFExport(void) : TfrxCustomImageExport() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxTIFFExport(void) { }
	
};


class DELPHICLASS TfrxJPEGExport;
class PASCALIMPLEMENTATION TfrxJPEGExport : public TfrxCustomImageExport
{
	typedef TfrxCustomImageExport inherited;
	
protected:
	virtual void __fastcall Save(void);
	
public:
	__fastcall virtual TfrxJPEGExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property JPEGQuality = {default=90};
	__property CropImages = {default=0};
	__property Monochrome = {default=0};
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxJPEGExport(void) : TfrxCustomImageExport() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxJPEGExport(void) { }
	
};


class DELPHICLASS TfrxGIFExport;
class PASCALIMPLEMENTATION TfrxGIFExport : public TfrxCustomImageExport
{
	typedef TfrxCustomImageExport inherited;
	
protected:
	virtual void __fastcall Save(void);
	
public:
	__fastcall virtual TfrxGIFExport(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property CropImages = {default=0};
	__property Monochrome = {default=0};
	__property OverwritePrompt;
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxGIFExport(void) : TfrxCustomImageExport() { }
	/* TfrxCustomExportFilter.Destroy */ inline __fastcall virtual ~TfrxGIFExport(void) { }
	
};


class DELPHICLASS TfrxIMGExportDialog;
class PASCALIMPLEMENTATION TfrxIMGExportDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OK;
	Stdctrls::TButton* Cancel;
	Stdctrls::TGroupBox* GroupPageRange;
	Stdctrls::TGroupBox* GroupBox1;
	Stdctrls::TCheckBox* CropPage;
	Stdctrls::TLabel* Label2;
	Stdctrls::TEdit* Quality;
	Stdctrls::TCheckBox* Mono;
	Dialogs::TSaveDialog* SaveDialog1;
	Stdctrls::TLabel* DescrL;
	Stdctrls::TRadioButton* AllRB;
	Stdctrls::TRadioButton* CurPageRB;
	Stdctrls::TRadioButton* PageNumbersRB;
	Stdctrls::TEdit* PageNumbersE;
	Stdctrls::TLabel* Label1;
	Stdctrls::TEdit* Resolution;
	Stdctrls::TCheckBox* SeparateCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall PageNumbersEChange(System::TObject* Sender);
	void __fastcall PageNumbersEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	TfrxCustomImageExport* FFilter;
	void __fastcall SetFilter(const TfrxCustomImageExport* Value);
	
public:
	__property TfrxCustomImageExport* Filter = {read=FFilter, write=SetFilter};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxIMGExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxIMGExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxIMGExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxIMGExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall GIFSaveToFile(const System::UnicodeString FileName, const Graphics::TBitmap* Bitmap);
extern PACKAGE void __fastcall GIFSaveToStream(const Classes::TStream* Stream, const Graphics::TBitmap* Bitmap);

}	/* namespace Frxexportimage */
using namespace Frxexportimage;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportimageHPP
