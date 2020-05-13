// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Calcedit.pas' rev: 21.00

#ifndef CalceditHPP
#define CalceditHPP

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
#include <Advformula.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Calcedit
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS ECalcEditError;
class PASCALIMPLEMENTATION ECalcEditError : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall ECalcEditError(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall ECalcEditError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall ECalcEditError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall ECalcEditError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall ECalcEditError(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall ECalcEditError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall ECalcEditError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall ECalcEditError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~ECalcEditError(void) { }
	
};


typedef void __fastcall (__closure *TCalcErrorEvent)(System::TObject* sender, int errorposition);

typedef void __fastcall (__closure *TIsCustomFunction)(System::TObject* sender, System::UnicodeString &func, bool &match);

typedef void __fastcall (__closure *TCalcCustomFunction)(System::TObject* sender, System::UnicodeString &func, double &param);

class DELPHICLASS TCalcEdit;
class PASCALIMPLEMENTATION TCalcEdit : public Stdctrls::TEdit
{
	typedef Stdctrls::TEdit inherited;
	
private:
	Advformula::TExpressionVariables fExprVars;
	System::UnicodeString fExpression;
	double fLastResult;
	System::UnicodeString fResultFormat;
	TCalcErrorEvent fOnCalcError;
	bool fShowFormula;
	Classes::TStringList* fHooks;
	TCalcCustomFunction fCalcCustomFunction;
	TIsCustomFunction fIsCustomFunction;
	bool fLink;
	HIDESBASE MESSAGE void __fastcall CNCommand(Messages::TMessage &Msg);
	void __fastcall SetResultFormat(const System::UnicodeString Value);
	HIDESBASE System::UnicodeString __fastcall GetText(void);
	HIDESBASE void __fastcall SetText(const System::UnicodeString Value);
	void __fastcall SetShowFormula(const bool Value);
	double __fastcall GetVariable(int i);
	void __fastcall SetVariable(int i, const double Value);
	void __fastcall IsCustom(System::TObject* sender, System::UnicodeString &func, bool &match);
	void __fastcall CalcCustom(System::TObject* sender, System::UnicodeString &func, double &param);
	void __fastcall AddCompRef(System::TObject* sender, System::UnicodeString compname, Stdctrls::TCustomEdit* compref);
	void __fastcall SetLink(const bool Value);
	double __fastcall GetFormulaResult(void);
	
protected:
	StaticArray<Classes::TNotifyEvent, 101> oldhandlers;
	void __fastcall EditChange(System::TObject* sender);
	DYNAMIC void __fastcall DoEnter(void);
	DYNAMIC void __fastcall DoExit(void);
	virtual void __fastcall Loaded(void);
	
public:
	__fastcall virtual TCalcEdit(Classes::TComponent* aOwner);
	__fastcall virtual ~TCalcEdit(void);
	__property double Variable[int i] = {read=GetVariable, write=SetVariable};
	void __fastcall Calculate(void);
	void __fastcall Hook(void);
	void __fastcall UnHook(void);
	__property double FormulaResult = {read=GetFormulaResult};
	
__published:
	__property bool Link = {read=fLink, write=SetLink, nodefault};
	__property System::UnicodeString ResultFormat = {read=fResultFormat, write=SetResultFormat};
	__property System::UnicodeString Text = {read=GetText, write=SetText};
	__property bool ShowFormula = {read=fShowFormula, write=SetShowFormula, nodefault};
	__property TCalcErrorEvent OnCalcError = {read=fOnCalcError, write=fOnCalcError};
	__property TIsCustomFunction OnIsCustomFunction = {read=fIsCustomFunction, write=fIsCustomFunction};
	__property TCalcCustomFunction OnCalcCustomFunction = {read=fCalcCustomFunction, write=fCalcCustomFunction};
public:
	/* TWinControl.CreateParented */ inline __fastcall TCalcEdit(HWND ParentWindow) : Stdctrls::TEdit(ParentWindow) { }
	
};


class DELPHICLASS TCalcLabel;
class PASCALIMPLEMENTATION TCalcLabel : public Stdctrls::TLabel
{
	typedef Stdctrls::TLabel inherited;
	
private:
	Advformula::TExpressionVariables fExprVars;
	bool fShowFormula;
	double fLastResult;
	System::UnicodeString fResultFormat;
	System::UnicodeString fFormula;
	Classes::TStringList* fHooks;
	TCalcCustomFunction fCalcCustomFunction;
	TCalcErrorEvent fOnCalcError;
	TIsCustomFunction fIsCustomFunction;
	bool fLink;
	double __fastcall GetVariable(int i);
	void __fastcall SetResultFormat(const System::UnicodeString Value);
	void __fastcall SetShowFormula(const bool Value);
	void __fastcall SetVariable(int i, const double Value);
	void __fastcall IsCustom(System::TObject* sender, System::UnicodeString &func, bool &match);
	void __fastcall CalcCustom(System::TObject* sender, System::UnicodeString &func, double &param);
	void __fastcall SetFormula(const System::UnicodeString Value);
	void __fastcall AddCompRef(System::TObject* sender, System::UnicodeString compname, Stdctrls::TCustomEdit* compref);
	void __fastcall SetLink(const bool Value);
	
protected:
	StaticArray<Classes::TNotifyEvent, 101> oldhandlers;
	void __fastcall EditChange(System::TObject* sender);
	
public:
	__fastcall virtual TCalcLabel(Classes::TComponent* aOwner);
	__fastcall virtual ~TCalcLabel(void);
	__property double Variable[int i] = {read=GetVariable, write=SetVariable};
	void __fastcall Calculate(void);
	virtual void __fastcall Loaded(void);
	void __fastcall Hook(void);
	void __fastcall UnHook(void);
	
__published:
	__property bool Link = {read=fLink, write=SetLink, nodefault};
	__property System::UnicodeString ResultFormat = {read=fResultFormat, write=SetResultFormat};
	__property bool ShowFormula = {read=fShowFormula, write=SetShowFormula, nodefault};
	__property System::UnicodeString Formula = {read=fFormula, write=SetFormula};
	__property TCalcErrorEvent OnCalcError = {read=fOnCalcError, write=fOnCalcError};
	__property TIsCustomFunction OnIsCustomFunction = {read=fIsCustomFunction, write=fIsCustomFunction};
	__property TCalcCustomFunction OnCalcCustomFunction = {read=fCalcCustomFunction, write=fCalcCustomFunction};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Calcedit */
using namespace Calcedit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// CalceditHPP
