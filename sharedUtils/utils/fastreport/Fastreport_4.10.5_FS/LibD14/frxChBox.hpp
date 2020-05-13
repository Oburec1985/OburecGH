// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxchbox.pas' rev: 21.00

#ifndef FrxchboxHPP
#define FrxchboxHPP

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
#include <Menus.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxchbox
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxCheckStyle { csCross, csCheck, csLineCross, csPlus };
#pragma option pop

#pragma option push -b-
enum TfrxUncheckStyle { usEmpty, usCross, usLineCross, usMinus };
#pragma option pop

class DELPHICLASS TfrxCheckBoxObject;
class PASCALIMPLEMENTATION TfrxCheckBoxObject : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxCheckBoxObject(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxCheckBoxObject(void) { }
	
};


class DELPHICLASS TfrxCheckBoxView;
class PASCALIMPLEMENTATION TfrxCheckBoxView : public Frxclass::TfrxView
{
	typedef Frxclass::TfrxView inherited;
	
private:
	Graphics::TColor FCheckColor;
	bool FChecked;
	TfrxCheckStyle FCheckStyle;
	TfrxUncheckStyle FUncheckStyle;
	System::UnicodeString FExpression;
	void __fastcall DrawCheck(const Types::TRect &ARect);
	
public:
	__fastcall virtual TfrxCheckBoxView(Classes::TComponent* AOwner);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall GetData(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property BrushStyle = {default=0};
	__property Graphics::TColor CheckColor = {read=FCheckColor, write=FCheckColor, nodefault};
	__property bool Checked = {read=FChecked, write=FChecked, default=1};
	__property TfrxCheckStyle CheckStyle = {read=FCheckStyle, write=FCheckStyle, nodefault};
	__property Color = {default=536870911};
	__property Cursor = {default=0};
	__property DataField;
	__property DataSet;
	__property DataSetName;
	__property System::UnicodeString Expression = {read=FExpression, write=FExpression};
	__property Frame;
	__property TagStr;
	__property TfrxUncheckStyle UncheckStyle = {read=FUncheckStyle, write=FUncheckStyle, default=0};
	__property URL;
public:
	/* TfrxView.Destroy */ inline __fastcall virtual ~TfrxCheckBoxView(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCheckBoxView(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxView(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxchbox */
using namespace Frxchbox;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxchboxHPP
