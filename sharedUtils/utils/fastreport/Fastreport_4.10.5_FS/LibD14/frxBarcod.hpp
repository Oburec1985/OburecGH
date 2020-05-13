// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxbarcod.pas' rev: 21.00

#ifndef FrxbarcodHPP
#define FrxbarcodHPP

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
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxbarcod
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxBarcodeType { bcCode_2_5_interleaved, bcCode_2_5_industrial, bcCode_2_5_matrix, bcCode39, bcCode39Extended, bcCode128A, bcCode128B, bcCode128C, bcCode93, bcCode93Extended, bcCodeMSI, bcCodePostNet, bcCodeCodabar, bcCodeEAN8, bcCodeEAN13, bcCodeUPC_A, bcCodeUPC_E0, bcCodeUPC_E1, bcCodeUPC_Supp2, bcCodeUPC_Supp5, bcCodeEAN128A, bcCodeEAN128B, bcCodeEAN128C };
#pragma option pop

#pragma option push -b-
enum TfrxBarLineType { white, black, black_half };
#pragma option pop

#pragma option push -b-
enum TfrxCheckSumMethod { csmNone, csmModulo10 };
#pragma option pop

class DELPHICLASS TfrxBarcode;
class PASCALIMPLEMENTATION TfrxBarcode : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	double FAngle;
	Graphics::TColor FColor;
	Graphics::TColor FColorBar;
	bool FCheckSum;
	TfrxCheckSumMethod FCheckSumMethod;
	int FHeight;
	int FLeft;
	int FModul;
	double FRatio;
	System::AnsiString FText;
	int FTop;
	TfrxBarcodeType FTyp;
	Graphics::TFont* FFont;
	StaticArray<System::ShortInt, 4> modules;
	void __fastcall DoLines(System::AnsiString data, Graphics::TCanvas* Canvas);
	void __fastcall OneBarProps(char code, int &Width, TfrxBarLineType &lt);
	System::AnsiString __fastcall SetLen(System::Byte pI);
	System::AnsiString __fastcall Code_2_5_interleaved(void);
	System::AnsiString __fastcall Code_2_5_industrial(void);
	System::AnsiString __fastcall Code_2_5_matrix(void);
	System::AnsiString __fastcall Code_39(void);
	System::AnsiString __fastcall Code_39Extended(void);
	System::AnsiString __fastcall Code_128(void);
	System::AnsiString __fastcall Code_93(void);
	System::AnsiString __fastcall Code_93Extended(void);
	System::AnsiString __fastcall Code_MSI(void);
	System::AnsiString __fastcall Code_PostNet(void);
	System::AnsiString __fastcall Code_Codabar(void);
	System::AnsiString __fastcall Code_EAN8(void);
	System::AnsiString __fastcall Code_EAN13(void);
	System::AnsiString __fastcall Code_UPC_A(void);
	System::AnsiString __fastcall Code_UPC_E0(void);
	System::AnsiString __fastcall Code_UPC_E1(void);
	System::AnsiString __fastcall Code_Supp5(void);
	System::AnsiString __fastcall Code_Supp2(void);
	void __fastcall MakeModules(void);
	int __fastcall GetWidth(void);
	System::AnsiString __fastcall DoCheckSumming(const System::AnsiString data);
	System::AnsiString __fastcall MakeData(void);
	
public:
	__fastcall virtual TfrxBarcode(Classes::TComponent* Owner);
	__fastcall virtual ~TfrxBarcode(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall DrawBarcode(Graphics::TCanvas* Canvas, const Types::TRect &ARect, bool ShowText);
	
__published:
	__property System::AnsiString Text = {read=FText, write=FText};
	__property int Modul = {read=FModul, write=FModul, nodefault};
	__property double Ratio = {read=FRatio, write=FRatio};
	__property TfrxBarcodeType Typ = {read=FTyp, write=FTyp, nodefault};
	__property bool Checksum = {read=FCheckSum, write=FCheckSum, nodefault};
	__property TfrxCheckSumMethod CheckSumMethod = {read=FCheckSumMethod, write=FCheckSumMethod, nodefault};
	__property double Angle = {read=FAngle, write=FAngle};
	__property int Width = {read=GetWidth, nodefault};
	__property int Height = {read=FHeight, write=FHeight, nodefault};
	__property Graphics::TColor Color = {read=FColor, write=FColor, nodefault};
	__property Graphics::TColor ColorBar = {read=FColorBar, write=FColorBar, nodefault};
	__property Graphics::TFont* Font = {read=FFont, write=FFont};
};


#pragma pack(push,1)
struct TBCdata
{
	
public:
	System::AnsiString Name;
	bool num;
};
#pragma pack(pop)


typedef StaticArray<TBCdata, 23> Frxbarcod__2;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Frxbarcod__2 BCdata;

}	/* namespace Frxbarcod */
using namespace Frxbarcod;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxbarcodHPP
