// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Miscmathlib.pas' rev: 21.00

#ifndef MiscmathlibHPP
#define MiscmathlibHPP

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
#include <Advpars.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Miscmathlib
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TMiscMathLib;
class PASCALIMPLEMENTATION TMiscMathLib : public Advpars::TMathLib
{
	typedef Advpars::TMathLib inherited;
	
public:
	virtual bool __fastcall HandlesFunction(System::UnicodeString FuncName);
	virtual double __fastcall CalcFunction(System::UnicodeString FuncName, Advpars::TParamList* Params, int &ErrType, int &ErrParam);
	virtual System::UnicodeString __fastcall GetEditHint(System::UnicodeString FuncName, int ParamIndex);
public:
	/* TComponent.Create */ inline __fastcall virtual TMiscMathLib(Classes::TComponent* AOwner) : Advpars::TMathLib(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TMiscMathLib(void) { }
	
};


class DELPHICLASS TFinanceMathLib;
class PASCALIMPLEMENTATION TFinanceMathLib : public Advpars::TMathLib
{
	typedef Advpars::TMathLib inherited;
	
public:
	virtual bool __fastcall HandlesFunction(System::UnicodeString FuncName);
	virtual double __fastcall CalcFunction(System::UnicodeString FuncName, Advpars::TParamList* Params, int &ErrType, int &ErrParam);
public:
	/* TComponent.Create */ inline __fastcall virtual TFinanceMathLib(Classes::TComponent* AOwner) : Advpars::TMathLib(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TFinanceMathLib(void) { }
	
};


class DELPHICLASS TConversionMathLib;
class PASCALIMPLEMENTATION TConversionMathLib : public Advpars::TMathLib
{
	typedef Advpars::TMathLib inherited;
	
public:
	virtual bool __fastcall HandlesFunction(System::UnicodeString FuncName);
	virtual double __fastcall CalcFunction(System::UnicodeString FuncName, Advpars::TParamList* Params, int &ErrType, int &ErrParam);
public:
	/* TComponent.Create */ inline __fastcall virtual TConversionMathLib(Classes::TComponent* AOwner) : Advpars::TMathLib(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TConversionMathLib(void) { }
	
};


class DELPHICLASS TStringMathLib;
class PASCALIMPLEMENTATION TStringMathLib : public Advpars::TMathLib
{
	typedef Advpars::TMathLib inherited;
	
public:
	virtual bool __fastcall HandlesStrFunction(System::UnicodeString FuncName);
	virtual System::UnicodeString __fastcall CalcStrFunction(System::UnicodeString FuncName, Classes::TStringList* Params, int &ErrType, int &ErrParam);
public:
	/* TComponent.Create */ inline __fastcall virtual TStringMathLib(Classes::TComponent* AOwner) : Advpars::TMathLib(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TStringMathLib(void) { }
	
};


class DELPHICLASS TDBMathLib;
class PASCALIMPLEMENTATION TDBMathLib : public Advpars::TMathLib
{
	typedef Advpars::TMathLib inherited;
	
private:
	Db::TDataSource* FDataSource;
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	
public:
	virtual bool __fastcall HandlesStrFunction(System::UnicodeString FuncName);
	virtual System::UnicodeString __fastcall CalcStrFunction(System::UnicodeString FuncName, Classes::TStringList* Params, int &ErrType, int &ErrParam);
	
__published:
	__property Db::TDataSource* DataSource = {read=FDataSource, write=FDataSource};
public:
	/* TComponent.Create */ inline __fastcall virtual TDBMathLib(Classes::TComponent* AOwner) : Advpars::TMathLib(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TDBMathLib(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Miscmathlib */
using namespace Miscmathlib;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// MiscmathlibHPP
