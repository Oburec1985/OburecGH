// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Esbmathslib.pas' rev: 21.00

#ifndef EsbmathslibHPP
#define EsbmathslibHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Advpars.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Esbmathslib
{
//-- type declarations -------------------------------------------------------
typedef unsigned LongWord;

class DELPHICLASS TESBMathsLib;
class PASCALIMPLEMENTATION TESBMathsLib : public Advpars::TMathLib
{
	typedef Advpars::TMathLib inherited;
	
public:
	virtual bool __fastcall HandlesConstant(System::UnicodeString Constant);
	virtual double __fastcall GetConstant(System::UnicodeString Constant);
	virtual bool __fastcall HandlesFunction(System::UnicodeString FuncName);
	virtual double __fastcall CalcFunction(System::UnicodeString FuncName, Advpars::TParamList* Params, int &ErrType, int &ErrParam);
	virtual System::UnicodeString __fastcall GetEditHint(System::UnicodeString FuncName, int ParamIndex);
public:
	/* TComponent.Create */ inline __fastcall virtual TESBMathsLib(Classes::TComponent* AOwner) : Advpars::TMathLib(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TESBMathsLib(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall Register(void);

}	/* namespace Esbmathslib */
using namespace Esbmathslib;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// EsbmathslibHPP
