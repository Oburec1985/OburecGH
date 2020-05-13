// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxrich.pas' rev: 21.00

#ifndef FrxrichHPP
#define FrxrichHPP

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
#include <Forms.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Richedit.hpp>	// Pascal unit
#include <Frxrichedit.hpp>	// Pascal unit
#include <Frxprinter.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxrich
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxRichObject;
class PASCALIMPLEMENTATION TfrxRichObject : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxRichObject(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxRichObject(void) { }
	
};


class DELPHICLASS TfrxRichView;
class PASCALIMPLEMENTATION TfrxRichView : public Frxclass::TfrxStretcheable
{
	typedef Frxclass::TfrxStretcheable inherited;
	
private:
	bool FAllowExpressions;
	System::UnicodeString FExpressionDelimiters;
	TfrxRichView* FFlowTo;
	System::Extended FGapX;
	System::Extended FGapY;
	bool FParaBreak;
	Frxrichedit::TRxRichEdit* FRichEdit;
	Classes::TMemoryStream* FTempStream;
	Classes::TMemoryStream* FTempStream1;
	bool FWysiwyg;
	bool FHasNextDataPart;
	Graphics::TMetafile* __fastcall CreateMetafile(void);
	bool __fastcall IsExprDelimitersStored(void);
	bool __fastcall UsePrinterCanvas(void);
	void __fastcall ReadData(Classes::TStream* Stream);
	void __fastcall WriteData(Classes::TStream* Stream);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	__fastcall virtual TfrxRichView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxRichView(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall AfterPrint(void);
	virtual void __fastcall BeforePrint(void);
	virtual void __fastcall GetData(void);
	virtual void __fastcall InitPart(void);
	virtual System::Extended __fastcall CalcHeight(void);
	virtual System::Extended __fastcall DrawPart(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual System::UnicodeString __fastcall GetComponentText(void);
	virtual bool __fastcall HasNextDataPart(void);
	__property Frxrichedit::TRxRichEdit* RichEdit = {read=FRichEdit};
	
__published:
	__property bool AllowExpressions = {read=FAllowExpressions, write=FAllowExpressions, default=1};
	__property BrushStyle = {default=0};
	__property Color = {default=536870911};
	__property Cursor = {default=0};
	__property DataField;
	__property DataSet;
	__property DataSetName;
	__property System::UnicodeString ExpressionDelimiters = {read=FExpressionDelimiters, write=FExpressionDelimiters, stored=IsExprDelimitersStored};
	__property TfrxRichView* FlowTo = {read=FFlowTo, write=FFlowTo};
	__property Frame;
	__property System::Extended GapX = {read=FGapX, write=FGapX};
	__property System::Extended GapY = {read=FGapY, write=FGapY};
	__property TagStr;
	__property URL;
	__property bool Wysiwyg = {read=FWysiwyg, write=FWysiwyg, default=1};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxRichView(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxStretcheable(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxAssignRich(Frxrichedit::TRxRichEdit* RichFrom, Frxrichedit::TRxRichEdit* RichTo);

}	/* namespace Frxrich */
using namespace Frxrich;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxrichHPP
