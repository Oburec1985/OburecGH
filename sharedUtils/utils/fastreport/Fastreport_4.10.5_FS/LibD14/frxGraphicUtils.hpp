// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxgraphicutils.pas' rev: 21.00

#ifndef FrxgraphicutilsHPP
#define FrxgraphicutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxunicodeutils.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Widestrings.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#undef NewLine

namespace Frxgraphicutils
{
//-- type declarations -------------------------------------------------------
typedef StaticArray<int, 536870911> TIntArray;

typedef TIntArray *PIntArray;

class DELPHICLASS TfrxHTMLTag;
class PASCALIMPLEMENTATION TfrxHTMLTag : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	int Position;
	int Size;
	int AddY;
	Graphics::TFontStyles Style;
	int Color;
	bool Default;
	bool Small;
	bool DontWRAP;
	void __fastcall Assign(TfrxHTMLTag* Tag);
public:
	/* TObject.Create */ inline __fastcall TfrxHTMLTag(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxHTMLTag(void) { }
	
};


class DELPHICLASS TfrxHTMLTags;
class PASCALIMPLEMENTATION TfrxHTMLTags : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TfrxHTMLTag* operator[](int Index) { return Items[Index]; }
	
private:
	Classes::TList* FItems;
	void __fastcall Add(TfrxHTMLTag* Tag);
	TfrxHTMLTag* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxHTMLTags(void);
	__fastcall virtual ~TfrxHTMLTags(void);
	void __fastcall Clear(void);
	int __fastcall Count(void);
	__property TfrxHTMLTag* Items[int Index] = {read=GetItems/*, default*/};
};


class DELPHICLASS TfrxHTMLTagsList;
class PASCALIMPLEMENTATION TfrxHTMLTagsList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TfrxHTMLTags* operator[](int Index) { return Items[Index]; }
	
private:
	bool FAllowTags;
	int FAddY;
	int FColor;
	int FDefColor;
	int FDefSize;
	Graphics::TFontStyles FDefStyle;
	Classes::TList* FItems;
	int FPosition;
	int FSize;
	Graphics::TFontStyles FStyle;
	bool FDontWRAP;
	TIntArray *FTempArray;
	void __fastcall NewLine(void);
	void __fastcall Wrap(int TagsCount, bool AddBreak);
	TfrxHTMLTag* __fastcall Add(void);
	int __fastcall FillCharSpacingArray(PIntArray &ar, const System::WideString s, Graphics::TCanvas* Canvas, int LineIndex, int Add, bool Convert, bool DefCharset);
	TfrxHTMLTags* __fastcall GetItems(int Index);
	TfrxHTMLTag* __fastcall GetPrevTag(void);
	
public:
	__fastcall TfrxHTMLTagsList(void);
	__fastcall virtual ~TfrxHTMLTagsList(void);
	void __fastcall Clear(void);
	void __fastcall SetDefaults(Graphics::TColor DefColor, int DefSize, Graphics::TFontStyles DefStyle);
	void __fastcall ExpandHTMLTags(System::WideString &s);
	int __fastcall Count(void);
	__property bool AllowTags = {read=FAllowTags, write=FAllowTags, nodefault};
	__property TfrxHTMLTags* Items[int Index] = {read=GetItems/*, default*/};
	__property int Position = {read=FPosition, write=FPosition, nodefault};
};


class DELPHICLASS TfrxDrawText;
class PASCALIMPLEMENTATION TfrxDrawText : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Graphics::TBitmap* FBMP;
	Graphics::TCanvas* FCanvas;
	int FDefPPI;
	int FScrPPI;
	TIntArray *FTempArray;
	int FFontSize;
	TfrxHTMLTagsList* FHTMLTags;
	System::Extended FCharSpacing;
	System::Extended FLineSpacing;
	int FOptions;
	Types::TRect FOriginalRect;
	System::Extended FParagraphGap;
	System::WideString FPlainText;
	System::Extended FPrintScale;
	int FRotation;
	bool FRTLReading;
	Types::TRect FScaledRect;
	System::Extended FScaleX;
	System::Extended FScaleY;
	Widestrings::TWideStrings* FText;
	bool FWordBreak;
	bool FWordWrap;
	bool FWysiwyg;
	bool FUseDefaultCharset;
	System::WideString __fastcall GetWrappedText(void);
	bool __fastcall IsPrinter(Graphics::TCanvas* C);
	void __fastcall DrawTextLine(Graphics::TCanvas* C, const System::WideString s, int X, int Y, int DX, int LineIndex, Frxclass::TfrxHAlign Align, HFONT &fh, HFONT &oldfh);
	void __fastcall WrapTextLine(System::WideString s, int Width, int FirstLineWidth, int CharSpacing);
	
public:
	__fastcall TfrxDrawText(void);
	__fastcall virtual ~TfrxDrawText(void);
	void __fastcall SetFont(Graphics::TFont* Font);
	void __fastcall SetOptions(bool WordWrap, bool HTMLTags, bool RTLReading, bool WordBreak, bool Clipped, bool Wysiwyg, int Rotation);
	void __fastcall SetGaps(System::Extended ParagraphGap, System::Extended CharSpacing, System::Extended LineSpacing);
	void __fastcall SetDimensions(System::Extended ScaleX, System::Extended ScaleY, System::Extended PrintScale, const Types::TRect &OriginalRect, const Types::TRect &ScaledRect);
	void __fastcall SetText(Widestrings::TWideStrings* Text);
	void __fastcall SetParaBreaks(bool FirstParaBreak, bool LastParaBreak);
	System::WideString __fastcall DeleteTags(const System::WideString Txt);
	void __fastcall DrawText(Graphics::TCanvas* C, Frxclass::TfrxHAlign HAlign, Frxclass::TfrxVAlign VAlign);
	System::Extended __fastcall CalcHeight(void);
	System::Extended __fastcall CalcWidth(void);
	System::Extended __fastcall LineHeight(void);
	System::Extended __fastcall TextHeight(void);
	System::WideString __fastcall GetInBoundsText(void);
	System::WideString __fastcall GetOutBoundsText(bool &ParaBreak);
	System::Extended __fastcall UnusedSpace(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	__property Graphics::TCanvas* Canvas = {read=FCanvas};
	__property int DefPPI = {read=FDefPPI, nodefault};
	__property int ScrPPI = {read=FScrPPI, nodefault};
	__property System::WideString WrappedText = {read=GetWrappedText};
	__property bool UseDefaultCharset = {read=FUseDefaultCharset, write=FUseDefaultCharset, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxDrawText* frxDrawText;

}	/* namespace Frxgraphicutils */
using namespace Frxgraphicutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxgraphicutilsHPP
