// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxole.pas' rev: 21.00

#ifndef FrxoleHPP
#define FrxoleHPP

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
#include <Olectnrs.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxole
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxSizeMode { fsmClip, fsmScale };
#pragma option pop

class DELPHICLASS TfrxOLEObject;
class PASCALIMPLEMENTATION TfrxOLEObject : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxOLEObject(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxOLEObject(void) { }
	
};


class DELPHICLASS TfrxOLEView;
class PASCALIMPLEMENTATION TfrxOLEView : public Frxclass::TfrxView
{
	typedef Frxclass::TfrxView inherited;
	
private:
	Olectnrs::TOleContainer* FOleContainer;
	TfrxSizeMode FSizeMode;
	bool FStretched;
	void __fastcall ReadData(Classes::TStream* Stream);
	void __fastcall SetStretched(const bool Value);
	void __fastcall WriteData(Classes::TStream* Stream);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	
public:
	__fastcall virtual TfrxOLEView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxOLEView(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall GetData(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Olectnrs::TOleContainer* OleContainer = {read=FOleContainer};
	
__published:
	__property BrushStyle = {default=0};
	__property Color = {default=536870911};
	__property Cursor = {default=0};
	__property DataField;
	__property DataSet;
	__property DataSetName;
	__property Frame;
	__property TfrxSizeMode SizeMode = {read=FSizeMode, write=FSizeMode, default=0};
	__property bool Stretched = {read=FStretched, write=SetStretched, default=0};
	__property TagStr;
	__property URL;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxOLEView(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxView(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxAssignOle(Olectnrs::TOleContainer* ContFrom, Olectnrs::TOleContainer* ContTo);

}	/* namespace Frxole */
using namespace Frxole;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxoleHPP
