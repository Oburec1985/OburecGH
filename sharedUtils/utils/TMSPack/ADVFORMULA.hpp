// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advformula.pas' rev: 21.00

#ifndef AdvformulaHPP
#define AdvformulaHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advformula
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TokenType { Delimiter, Non, variable, Digit, endExpr, Error, Func };
#pragma option pop

struct TokenRec;
typedef TokenRec *TokenPtr;

struct TokenRec
{
	
public:
	TokenRec *Next;
	short Start;
	short Close;
};


typedef void __fastcall (__closure *TIsCustomFunction)(System::TObject* sender, System::UnicodeString &Func, bool &match);

typedef void __fastcall (__closure *TCalcCustomFunction)(System::TObject* sender, System::UnicodeString &Func, double &param);

typedef void __fastcall (__closure *TIsCompRefEvent)(System::TObject* sender, System::UnicodeString compname, Stdctrls::TCustomEdit* compobj);

typedef StaticArray<double, 101> TExpressionVariables;

class DELPHICLASS TAdvFormula;
class PASCALIMPLEMENTATION TAdvFormula : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int i;
	int varlen;
	Classes::TComponent* fOwner;
	System::UnicodeString fExpression;
	int fErrorPosition;
	TIsCustomFunction fIsCustomFunction;
	TCalcCustomFunction fCalcCustomFunction;
	TIsCompRefEvent fIsCompRefEvent;
	System::UnicodeString __fastcall ReadWord(void);
	double __fastcall ReadNumber(void);
	void __fastcall SkipBlanks(void);
	TokenType __fastcall GetToken(void);
	bool __fastcall MatchFunc(System::UnicodeString match, double &Res, TokenType &n);
	bool __fastcall MatchToken(System::UnicodeString match);
	bool __fastcall doPI(double &r);
	bool __fastcall doE(double &r);
	bool __fastcall DoNow(double &r);
	bool __fastcall DoToday(double &r);
	bool __fastcall DoFrac(double &Res, TokenType &n);
	bool __fastcall DoFact(double &Res, TokenType &n);
	bool __fastcall DoInt(double &Res, TokenType &n);
	bool __fastcall DoChs(double &Res, TokenType &n);
	bool __fastcall DoSin(double &Res, TokenType &n);
	bool __fastcall DoCos(double &Res, TokenType &n);
	bool __fastcall DoTan(double &Res, TokenType &n);
	bool __fastcall DoCoTan(double &Res, TokenType &n);
	bool __fastcall DoSinh(double &Res, TokenType &n);
	bool __fastcall DoCosh(double &Res, TokenType &n);
	bool __fastcall DoTanh(double &Res, TokenType &n);
	bool __fastcall DoCoTanh(double &Res, TokenType &n);
	bool __fastcall DoMonth(double &Res, TokenType &n);
	bool __fastcall DoYear(double &Res, TokenType &n);
	bool __fastcall DoDay(double &Res, TokenType &n);
	bool __fastcall DoDayOfWeek(double &Res, TokenType &n);
	bool __fastcall DoMinute(double &Res, TokenType &n);
	bool __fastcall DoSecond(double &Res, TokenType &n);
	bool __fastcall DoHour(double &Res, TokenType &n);
	bool __fastcall DoExp(double &Res, TokenType &n);
	bool __fastcall DoLn(double &Res, TokenType &n);
	bool __fastcall DoLog10(double &Res, TokenType &n);
	bool __fastcall DoLog2(double &Res, TokenType &n);
	bool __fastcall DoAbs(double &Res, TokenType &n);
	bool __fastcall DoArcTan(double &Res, TokenType &n);
	bool __fastcall DoArcCoTan(double &Res, TokenType &n);
	bool __fastcall DoRound(double &Res, TokenType &n);
	bool __fastcall DoTrunc(double &Res, TokenType &n);
	bool __fastcall DoDegrees(double &Res, TokenType &n);
	bool __fastcall DoRadians(double &Res, TokenType &n);
	bool __fastcall DoRand(double &Res, TokenType &n);
	bool __fastcall DoSqr(double &Res, TokenType &n);
	bool __fastcall DoCube(double &Res, TokenType &n);
	bool __fastcall DoSqrt(double &Res, TokenType &n);
	bool __fastcall DoArcSin(double &Res, TokenType &n);
	bool __fastcall DoArcCos(double &Res, TokenType &n);
	void __fastcall DoFunc(double &Res, TokenType &n);
	void __fastcall Primitive(double &Res, TokenType &n);
	double __fastcall Sign(double Number);
	void __fastcall Level6(double &Res, TokenType &n);
	void __fastcall Level5(double &Res, TokenType &n);
	void __fastcall Level4(double &Res, TokenType &n);
	void __fastcall Level3(double &Res, TokenType &n);
	void __fastcall Level2(double &Res, TokenType &n);
	void __fastcall Level1(double &Res, TokenType &n);
	double __fastcall GetExpr(bool &Valid);
	void __fastcall DoErr(TokenType &n);
	void __fastcall GetNextVar(System::UnicodeString &full, System::UnicodeString &expr, System::UnicodeString &c, System::UnicodeString &r);
	bool __fastcall IsExprVar(void);
	double __fastcall GetExprVar(void);
	bool __fastcall IsCompRefFunc(System::UnicodeString match);
	bool __fastcall SolveCompRefFunc(System::UnicodeString match, double &Res);
	
public:
	TExpressionVariables V;
	__fastcall TAdvFormula(Classes::TComponent* aOwner);
	__fastcall virtual ~TAdvFormula(void);
	__property System::UnicodeString Expression = {read=fExpression, write=fExpression};
	__property int ErrorPosition = {read=fErrorPosition, write=fErrorPosition, nodefault};
	bool __fastcall Calc(double &r);
	__property TIsCustomFunction IsCustomFunction = {read=fIsCustomFunction, write=fIsCustomFunction};
	__property TCalcCustomFunction CalcCustomFunction = {read=fCalcCustomFunction, write=fCalcCustomFunction};
	__property TIsCompRefEvent OnIsCompRef = {read=fIsCompRefEvent, write=fIsCompRefEvent};
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAXVARS = 0x64;

}	/* namespace Advformula */
using namespace Advformula;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvformulaHPP
