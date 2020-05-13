// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxutils.pas' rev: 21.00

#ifndef FrxutilsHPP
#define FrxutilsHPP

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
#include <Stdctrls.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Actnlist.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxutils
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxRectArea;
class PASCALIMPLEMENTATION TfrxRectArea : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::Extended X;
	System::Extended Y;
	System::Extended X1;
	System::Extended Y1;
	__fastcall TfrxRectArea(Frxclass::TfrxComponent* c)/* overload */;
	__fastcall TfrxRectArea(System::Extended Left, System::Extended Top, System::Extended Right, System::Extended Bottom)/* overload */;
	bool __fastcall InterceptsX(TfrxRectArea* a);
	bool __fastcall InterceptsY(TfrxRectArea* a);
	TfrxRectArea* __fastcall InterceptX(TfrxRectArea* a);
	TfrxRectArea* __fastcall InterceptY(TfrxRectArea* a);
	System::Extended __fastcall Max(System::Extended x1, System::Extended x2);
	System::Extended __fastcall Min(System::Extended x1, System::Extended x2);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxRectArea(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE unsigned __fastcall frxStreamCRC32(Classes::TStream* Stream);
extern PACKAGE Classes::TComponent* __fastcall frxFindComponent(Classes::TComponent* Owner, const System::UnicodeString Name);
extern PACKAGE void __fastcall frxGetComponents(Classes::TComponent* Owner, System::TClass ClassRef, Classes::TStrings* List, Classes::TComponent* Skip);
extern PACKAGE System::UnicodeString __fastcall frxGetFullName(Classes::TComponent* Owner, Classes::TComponent* c);
extern PACKAGE void __fastcall frxSetCommaText(const System::UnicodeString Text, Classes::TStrings* sl, System::WideChar Comma = (System::WideChar)(0x3b));
extern PACKAGE System::UnicodeString __fastcall frxRemoveQuotes(const System::UnicodeString s);
extern PACKAGE System::UnicodeString __fastcall frxStreamToString(Classes::TStream* Stream);
extern PACKAGE void __fastcall frxStringToStream(const System::UnicodeString s, Classes::TStream* Stream);
extern PACKAGE System::Extended __fastcall frxStrToFloat(System::UnicodeString s);
extern PACKAGE System::UnicodeString __fastcall frxFloatToStr(System::Extended d);
extern PACKAGE Frxclass::TfrxRect __fastcall frxRect(System::Extended ALeft, System::Extended ATop, System::Extended ARight, System::Extended ABottom);
extern PACKAGE Frxclass::TfrxPoint __fastcall frxPoint(System::Extended X, System::Extended Y);
extern PACKAGE System::AnsiString __fastcall frxGetBrackedVariable(const System::AnsiString Str, const System::AnsiString OpenBracket, const System::AnsiString CloseBracket, int &i, int &j);
extern PACKAGE System::WideString __fastcall frxGetBrackedVariableW(const System::WideString Str, const System::WideString OpenBracket, const System::WideString CloseBracket, int &i, int &j);
extern PACKAGE void __fastcall frxCommonErrorHandler(Frxclass::TfrxReport* Report, const System::UnicodeString Text);
extern PACKAGE void __fastcall frxErrorMsg(const System::UnicodeString Text);
extern PACKAGE int __fastcall frxConfirmMsg(const System::UnicodeString Text, int Buttons);
extern PACKAGE void __fastcall frxInfoMsg(const System::UnicodeString Text);
extern PACKAGE bool __fastcall frxIsValidFloat(const System::UnicodeString Value);
extern PACKAGE void __fastcall frxAssignImages(Graphics::TBitmap* Bitmap, int dx, int dy, Controls::TImageList* ImgList1, Controls::TImageList* ImgList2 = (Controls::TImageList*)(0x0));
extern PACKAGE void __fastcall frxDrawTransparent(Graphics::TCanvas* Canvas, int x, int y, Graphics::TBitmap* bmp);
extern PACKAGE void __fastcall frxDrawGraphic(Graphics::TCanvas* Canvas, const Types::TRect &DestRect, Graphics::TGraphic* aGraph, bool IsPrinting, bool Smooth, bool Transparent, Graphics::TColor TransparentColor);
extern PACKAGE void __fastcall frxParsePageNumbers(const System::UnicodeString PageNumbers, Classes::TStrings* List, int Total);
extern PACKAGE System::UnicodeString __fastcall HTMLRGBColor(Graphics::TColor Color);
extern PACKAGE void __fastcall frxWriteCollection(Classes::TCollection* Collection, Classes::TWriter* Writer, Frxclass::TfrxComponent* Owner);
extern PACKAGE void __fastcall frxReadCollection(Classes::TCollection* Collection, Classes::TReader* Reader, Frxclass::TfrxComponent* Owner);
extern PACKAGE System::UnicodeString __fastcall GetTemporaryFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetTempFile(void);
extern PACKAGE System::UnicodeString __fastcall frxCreateTempFile(const System::UnicodeString TempDir);
extern PACKAGE System::UnicodeString __fastcall GetAppFileName(void);
extern PACKAGE System::UnicodeString __fastcall GetAppPath(void);
extern PACKAGE System::UnicodeString __fastcall frFloat2Str(const System::Extended Value, const int Prec = 0x2, const System::WideChar Sep = (System::WideChar)(0x2e));
extern PACKAGE System::UnicodeString __fastcall frxReverseString(const System::UnicodeString AText);
extern PACKAGE System::UnicodeString __fastcall frxUnixPath2WinPath(const System::UnicodeString Path);

}	/* namespace Frxutils */
using namespace Frxutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxutilsHPP
