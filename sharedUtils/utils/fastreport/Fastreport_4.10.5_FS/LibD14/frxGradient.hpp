// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxgradient.pas' rev: 21.00

#ifndef FrxgradientHPP
#define FrxgradientHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxgradient
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxGradientObject;
class PASCALIMPLEMENTATION TfrxGradientObject : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxGradientObject(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxGradientObject(void) { }
	
};


#pragma option push -b-
enum TfrxGradientStyle { gsHorizontal, gsVertical, gsElliptic, gsRectangle, gsVertCenter, gsHorizCenter };
#pragma option pop

class DELPHICLASS TfrxGradientView;
class PASCALIMPLEMENTATION TfrxGradientView : public Frxclass::TfrxView
{
	typedef Frxclass::TfrxView inherited;
	
private:
	Graphics::TColor FBeginColor;
	Graphics::TColor FEndColor;
	TfrxGradientStyle FStyle;
	void __fastcall DrawGradient(int X, int Y, int X1, int Y1);
	Graphics::TColor __fastcall GetColor(void);
	void __fastcall SetColor(const Graphics::TColor Value);
	
public:
	__fastcall virtual TfrxGradientView(Classes::TComponent* AOwner);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property Graphics::TColor BeginColor = {read=FBeginColor, write=FBeginColor, default=16777215};
	__property Graphics::TColor EndColor = {read=FEndColor, write=FEndColor, default=8421504};
	__property TfrxGradientStyle Style = {read=FStyle, write=FStyle, nodefault};
	__property Frame;
	__property Graphics::TColor Color = {read=GetColor, write=SetColor, nodefault};
public:
	/* TfrxView.Destroy */ inline __fastcall virtual ~TfrxGradientView(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxGradientView(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxView(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxgradient */
using namespace Frxgradient;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxgradientHPP
