// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxbarcode.pas' rev: 21.00

#ifndef FrxbarcodeHPP
#define FrxbarcodeHPP

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
#include <Menus.hpp>	// Pascal unit
#include <Frxbarcod.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxbarcode
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxBarCodeObject;
class PASCALIMPLEMENTATION TfrxBarCodeObject : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxBarCodeObject(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxBarCodeObject(void) { }
	
};


class DELPHICLASS TfrxBarCodeView;
class PASCALIMPLEMENTATION TfrxBarCodeView : public Frxclass::TfrxView
{
	typedef Frxclass::TfrxView inherited;
	
private:
	Frxbarcod::TfrxBarcode* FBarCode;
	Frxbarcod::TfrxBarcodeType FBarType;
	bool FCalcCheckSum;
	System::UnicodeString FExpression;
	Frxclass::TfrxHAlign FHAlign;
	int FRotation;
	bool FShowText;
	System::UnicodeString FText;
	System::Extended FWideBarRatio;
	System::Extended FZoom;
	void __fastcall BcFontChanged(System::TObject* Sender);
	
public:
	__fastcall virtual TfrxBarCodeView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxBarCodeView(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall GetData(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Frxclass::TfrxRect __fastcall GetRealBounds(void);
	__property Frxbarcod::TfrxBarcode* BarCode = {read=FBarCode};
	
__published:
	__property Frxbarcod::TfrxBarcodeType BarType = {read=FBarType, write=FBarType, nodefault};
	__property BrushStyle = {default=0};
	__property bool CalcCheckSum = {read=FCalcCheckSum, write=FCalcCheckSum, default=0};
	__property Color = {default=536870911};
	__property Cursor = {default=0};
	__property DataField;
	__property DataSet;
	__property DataSetName;
	__property System::UnicodeString Expression = {read=FExpression, write=FExpression};
	__property Frame;
	__property Frxclass::TfrxHAlign HAlign = {read=FHAlign, write=FHAlign, default=0};
	__property int Rotation = {read=FRotation, write=FRotation, nodefault};
	__property bool ShowText = {read=FShowText, write=FShowText, default=1};
	__property TagStr;
	__property System::UnicodeString Text = {read=FText, write=FText};
	__property URL;
	__property System::Extended WideBarRatio = {read=FWideBarRatio, write=FWideBarRatio};
	__property System::Extended Zoom = {read=FZoom, write=FZoom};
	__property Font;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxBarCodeView(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxView(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxbarcode */
using namespace Frxbarcode;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxbarcodeHPP
