// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advpars.pas' rev: 21.00

#ifndef AdvparsHPP
#define AdvparsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Grids.hpp>	// Pascal unit
#include <Basegrid.hpp>	// Pascal unit
#include <Advgrid.hpp>	// Pascal unit
#include <Advutil.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advpars
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TokenType { Delimiter, Non, Variable, Digit, EndExpr, Error, Func, Operator, Text };
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


typedef void __fastcall (__closure *TIsCustomFunction)(System::TObject* sender, System::UnicodeString &func, bool &match);

typedef void __fastcall (__closure *TCalcCustomFunction)(System::TObject* sender, System::UnicodeString &func, double &param);

typedef void __fastcall (__closure *TErrorEvent)(System::TObject* Sender, int ACol, int ARow, int ErrType, int ErrPos, int ErrParam, System::UnicodeString ErrStr);

class DELPHICLASS TDoubleItem;
class PASCALIMPLEMENTATION TDoubleItem : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	double FValue;
	__property double Value = {read=FValue, write=FValue};
public:
	/* TObject.Create */ inline __fastcall TDoubleItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TDoubleItem(void) { }
	
};


class DELPHICLASS TParamList;
class PASCALIMPLEMENTATION TParamList : public Classes::TList
{
	typedef Classes::TList inherited;
	
private:
	double __fastcall GetItem(int Index);
	void __fastcall SetItem(int Index, const double Value);
	
public:
	HIDESBASE void __fastcall Add(double Item);
	virtual void __fastcall Clear(void);
	__property double Items[int Index] = {read=GetItem, write=SetItem};
public:
	/* TList.Destroy */ inline __fastcall virtual ~TParamList(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TParamList(void) : Classes::TList() { }
	
};


class DELPHICLASS TMathLib;
class PASCALIMPLEMENTATION TMathLib : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	virtual bool __fastcall HandlesConstant(System::UnicodeString Constant);
	virtual double __fastcall GetConstant(System::UnicodeString Constant);
	virtual bool __fastcall HandlesFunction(System::UnicodeString FuncName);
	virtual bool __fastcall HandlesStrFunction(System::UnicodeString FuncName);
	virtual double __fastcall CalcFunction(System::UnicodeString FuncName, TParamList* Params, int &ErrType, int &ErrParam);
	virtual System::UnicodeString __fastcall CalcStrFunction(System::UnicodeString FuncName, Classes::TStringList* Params, int &ErrType, int &ErrParam);
	System::UnicodeString __fastcall GetErrorMessage(int ErrType);
	virtual System::UnicodeString __fastcall GetEditHint(System::UnicodeString FuncName, int ParamIndex);
public:
	/* TComponent.Create */ inline __fastcall virtual TMathLib(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TMathLib(void) { }
	
};


class DELPHICLASS TGridBinderItem;
class PASCALIMPLEMENTATION TGridBinderItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	Basegrid::TBaseGrid* FGrid;
	System::UnicodeString FName;
	
public:
	__fastcall virtual TGridBinderItem(Classes::TCollection* Collection);
	__fastcall virtual ~TGridBinderItem(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property Basegrid::TBaseGrid* Grid = {read=FGrid, write=FGrid};
	__property System::UnicodeString Name = {read=FName, write=FName};
};


class DELPHICLASS TGridBinderItems;
class DELPHICLASS TGridBinder;
class PASCALIMPLEMENTATION TGridBinderItems : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
private:
	TGridBinder* FOwner;
	HIDESBASE TGridBinderItem* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TGridBinderItem* Value);
	Basegrid::TBaseGrid* __fastcall GetGridByName(System::UnicodeString Name);
	
public:
	HIDESBASE TGridBinderItem* __fastcall Add(void);
	__fastcall TGridBinderItems(TGridBinder* AOwner);
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
	__property TGridBinderItem* Items[int Index] = {read=GetItem, write=SetItem};
	__property Basegrid::TBaseGrid* GridByName[System::UnicodeString Name] = {read=GetGridByName};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TGridBinderItems(void) { }
	
};


class PASCALIMPLEMENTATION TGridBinder : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TGridBinderItems* FGrids;
	void __fastcall SetGrids(const TGridBinderItems* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	
public:
	__fastcall virtual TGridBinder(Classes::TComponent* AOwner);
	__fastcall virtual ~TGridBinder(void);
	
__published:
	__property TGridBinderItems* Grids = {read=FGrids, write=SetGrids};
};


class DELPHICLASS TLibBinderItem;
class PASCALIMPLEMENTATION TLibBinderItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	TMathLib* FMathLib;
	
public:
	__fastcall virtual TLibBinderItem(Classes::TCollection* Collection);
	__fastcall virtual ~TLibBinderItem(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property TMathLib* MathLib = {read=FMathLib, write=FMathLib};
};


class DELPHICLASS TLibBinderItems;
class DELPHICLASS TLibBinder;
class PASCALIMPLEMENTATION TLibBinderItems : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
private:
	TLibBinder* FOwner;
	HIDESBASE TLibBinderItem* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TLibBinderItem* Value);
	
public:
	HIDESBASE TLibBinderItem* __fastcall Add(void);
	__fastcall TLibBinderItems(TLibBinder* AOwner);
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
	__property TLibBinderItem* Items[int Index] = {read=GetItem, write=SetItem};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TLibBinderItems(void) { }
	
};


class PASCALIMPLEMENTATION TLibBinder : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TLibBinderItems* FLibs;
	void __fastcall SetLibs(const TLibBinderItems* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	
public:
	__fastcall virtual TLibBinder(Classes::TComponent* AOwner);
	__fastcall virtual ~TLibBinder(void);
	
__published:
	__property TLibBinderItems* Libs = {read=FLibs, write=SetLibs};
};


class DELPHICLASS TGridFormula;
class PASCALIMPLEMENTATION TGridFormula : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int i;
	int Varlen;
	bool FFirstError;
	System::UnicodeString FOrigExpression;
	System::UnicodeString FExpression;
	int FCol;
	int FRow;
	int FErrorPosition;
	Advgrid::TAdvStringGrid* FStringGrid;
	Classes::TStringList* FCellNameList;
	TIsCustomFunction FIsCustomFunction;
	TCalcCustomFunction FCalcCustomFunction;
	bool FUseRCNames;
	TLibBinder* FMathLib;
	TGridBinder* FBinder;
	TErrorEvent FOnError;
	Set<char, 0, 255>  FTokenEnd;
	Set<char, 0, 255>  FParamEnd;
	System::UnicodeString __fastcall ReadWord(void);
	System::UnicodeString __fastcall ReadWordEx(void);
	System::UnicodeString __fastcall ReadStr(void);
	double __fastcall ReadNumber(void);
	TokenType __fastcall GetToken(void);
	bool __fastcall MatchFunc(System::UnicodeString Match, double &Res, TokenType &n);
	bool __fastcall MatchFuncStr(System::UnicodeString Match, System::UnicodeString &Res, TokenType &n);
	bool __fastcall MatchDualParamFunc(System::UnicodeString Match, double &Res1, double &Res2, TokenType &n);
	bool __fastcall MatchTriParamFunc(System::UnicodeString Match, double &Res1, double &Res2, double &Res3, TokenType &n);
	bool __fastcall MatchVarParamFunc(System::UnicodeString Match, TParamList* pl, TokenType &n, bool SkipEmptyCells = false);
	bool __fastcall MatchVarStrParamFunc(System::UnicodeString Match, Classes::TStringList* pl, TokenType &n);
	bool __fastcall MatchRangeDualNumFunc(System::UnicodeString Match, Classes::TStringList* pl, TokenType &n);
	bool __fastcall MatchStrNumFunc(System::UnicodeString Match, System::UnicodeString &resstr, double &resnum, TokenType &n);
	bool __fastcall MatchStrDualNumFunc(System::UnicodeString Match, System::UnicodeString &resstr, double &resnum1, double &resnum2, TokenType &n);
	bool __fastcall MatchToken(System::UnicodeString Match);
	bool __fastcall DoPI(double &r);
	bool __fastcall DoE(double &r);
	bool __fastcall DoTrue(double &r);
	bool __fastcall DoFalse(double &r);
	bool __fastcall DoCol(double &r);
	bool __fastcall DoRow(double &r);
	bool __fastcall DoNow(double &r);
	bool __fastcall DoToday(double &r);
	bool __fastcall DoChoose(double &Res, TokenType &n);
	bool __fastcall DoLt(double &Res, TokenType &n);
	bool __fastcall DoSt(double &Res, TokenType &n);
	bool __fastcall DoEq(double &Res, TokenType &n);
	bool __fastcall DoFrac(double &Res, TokenType &n);
	bool __fastcall DoFact(double &Res, TokenType &n);
	bool __fastcall DoInt(double &Res, TokenType &n);
	bool __fastcall DoIndex(double &res, System::UnicodeString &resstr, TokenType &n);
	bool __fastcall DoMatch(double &Res, TokenType &n);
	bool __fastcall DoLookup(System::UnicodeString &ResStr, TokenType &n);
	bool __fastcall DoChs(double &Res, TokenType &n);
	bool __fastcall DoSin(double &Res, TokenType &n);
	bool __fastcall DoCos(double &Res, TokenType &n);
	bool __fastcall DoTan(double &res, TokenType &n);
	bool __fastcall DoCoTan(double &res, TokenType &n);
	bool __fastcall DoSinh(double &Res, TokenType &n);
	bool __fastcall DoCosh(double &Res, TokenType &n);
	bool __fastcall DoTanh(double &res, TokenType &n);
	bool __fastcall DoCoTanh(double &res, TokenType &n);
	bool __fastcall DoMonth(double &res, TokenType &n);
	bool __fastcall DoYear(double &res, TokenType &n);
	bool __fastcall DoDay(double &res, TokenType &n);
	bool __fastcall DoDayOfWeek(double &res, TokenType &n);
	bool __fastcall DoMinute(double &res, TokenType &n);
	bool __fastcall DoSecond(double &res, TokenType &n);
	bool __fastcall DoHour(double &res, TokenType &n);
	bool __fastcall DoExp(double &Res, TokenType &n);
	bool __fastcall DoLn(double &res, TokenType &n);
	bool __fastcall DoLog10(double &res, TokenType &n);
	bool __fastcall DoLog2(double &res, TokenType &n);
	bool __fastcall DoAbs(double &res, TokenType &n);
	bool __fastcall DoArcTan(double &res, TokenType &n);
	bool __fastcall DoArcCoTan(double &res, TokenType &n);
	bool __fastcall DoRound(double &res, TokenType &n);
	bool __fastcall DoCeiling(double &res, TokenType &n);
	bool __fastcall DoTrunc(double &res, TokenType &n);
	bool __fastcall DoDegrees(double &res, TokenType &n);
	bool __fastcall DoRadians(double &res, TokenType &n);
	bool __fastcall DoRand(double &res, TokenType &n);
	bool __fastcall DoSqr(double &res, TokenType &n);
	bool __fastcall DoCube(double &res, TokenType &n);
	bool __fastcall DoSqrt(double &res, TokenType &n);
	bool __fastcall DoArcSin(double &res, TokenType &n);
	bool __fastcall DoArcCos(double &res, TokenType &n);
	bool __fastcall DoOR(double &res, TokenType &n);
	bool __fastcall DoAND(double &res, TokenType &n);
	bool __fastcall DoNOR(double &res, TokenType &n);
	bool __fastcall DoXOR(double &res, TokenType &n);
	bool __fastcall DoNAND(double &res, TokenType &n);
	bool __fastcall DoNOT(double &res, TokenType &n);
	bool __fastcall DoSum(double &res, TokenType &n);
	bool __fastcall DoProduct(double &res, TokenType &n);
	bool __fastcall DoAverage(double &res, TokenType &n);
	bool __fastcall DoCount(double &res, TokenType &n);
	bool __fastcall DoCountA(double &res, TokenType &n);
	bool __fastcall DoCountBlank(double &res, TokenType &n);
	bool __fastcall DoCountIF(double &res, TokenType &n);
	bool __fastcall DoMin(double &res, TokenType &n);
	bool __fastcall DoMax(double &res, TokenType &n);
	bool __fastcall DoStDev(double &res, TokenType &n);
	bool __fastcall DoDevSQ(double &res, TokenType &n);
	bool __fastcall DoStDevP(double &res, TokenType &n);
	bool __fastcall DoPower(double &res, TokenType &n);
	bool __fastcall DoVar(double &res, TokenType &n);
	bool __fastcall DoUpper(System::UnicodeString &res, TokenType &n);
	bool __fastcall DoLower(System::UnicodeString &res, TokenType &n);
	bool __fastcall DoTrim(System::UnicodeString &res, TokenType &n);
	bool __fastcall DoLen(double &res, System::UnicodeString &resstr, TokenType &n);
	bool __fastcall DoSearch(double &res, System::UnicodeString &resstr, TokenType &n);
	bool __fastcall DoConcatenate(System::UnicodeString &res, TokenType &n);
	bool __fastcall DoSubstitute(System::UnicodeString &res, TokenType &n);
	bool __fastcall DoLeft(System::UnicodeString &res, TokenType &n);
	bool __fastcall DoRight(System::UnicodeString &res, TokenType &n);
	bool __fastcall DoMid(System::UnicodeString &res, TokenType &n);
	void __fastcall DoFunc(double &res, System::UnicodeString &ResStr, TokenType &n);
	void __fastcall Primitive(double &Res, System::UnicodeString &ResStr, TokenType &n);
	double __fastcall Sign(double Number);
	void __fastcall Level6(double &res, System::UnicodeString &resstr, TokenType &n);
	void __fastcall Level5(double &res, System::UnicodeString &resstr, TokenType &n);
	void __fastcall Level4(double &res, System::UnicodeString &resstr, TokenType &n);
	void __fastcall Level3(double &res, System::UnicodeString &resstr, TokenType &n);
	void __fastcall Level2(double &res, System::UnicodeString &resstr, TokenType &n);
	void __fastcall Level1(double &res, System::UnicodeString &resstr, TokenType &n);
	System::Variant __fastcall GetExpr(bool &Valid);
	void __fastcall DoErr(TokenType &n, int ErrPos, int ErrType, System::UnicodeString ErrStr);
	int __fastcall GetNextVar(System::UnicodeString &Full, System::UnicodeString &Expr, System::UnicodeString &c, System::UnicodeString &r);
	bool __fastcall IsCellVar(void);
	bool __fastcall GetCellRange(System::UnicodeString Sheet, System::UnicodeString Range, TParamList* Params, bool SkipEmptyCells = false);
	bool __fastcall GetCellRangeCoord(System::UnicodeString Range, Grids::TGridRect &gr);
	bool __fastcall GetCellStrRange(System::UnicodeString Sheet, System::UnicodeString Range, Classes::TStringList* Params);
	System::Variant __fastcall GetCellVar(void);
	System::Variant __fastcall GetCellVal(System::UnicodeString Sheet, int ACol, int ARow);
	System::Variant __fastcall GetCellValStr(System::UnicodeString Sheet, int ACol, int ARow);
	int __fastcall IsCellNameRef(System::UnicodeString Sheet, System::UnicodeString Match);
	bool __fastcall SolveCellNameRef(System::UnicodeString Sheet, System::UnicodeString Match, double &Res);
	Types::TPoint __fastcall GetCoord(System::AnsiString rng);
	System::UnicodeString __fastcall GetExpression(void);
	void __fastcall SetExpression(const System::UnicodeString Value);
	
public:
	__fastcall TGridFormula(Advgrid::TAdvStringGrid* Grid);
	__fastcall virtual ~TGridFormula(void);
	__property System::UnicodeString Expression = {read=GetExpression, write=SetExpression};
	__property int Row = {read=FRow, write=FRow, nodefault};
	__property int Col = {read=FCol, write=FCol, nodefault};
	__property int ErrorPosition = {read=FErrorPosition, write=FErrorPosition, nodefault};
	bool __fastcall Calc(System::Variant &r);
	__property Classes::TStringList* CellNameList = {read=FCellNameList};
	__property bool UseRCNames = {read=FUseRCNames, write=FUseRCNames, nodefault};
	__property TGridBinder* Binder = {read=FBinder, write=FBinder};
	__property TLibBinder* Libs = {read=FMathLib, write=FMathLib};
	__property TIsCustomFunction IsCustomFunction = {read=FIsCustomFunction, write=FIsCustomFunction};
	__property TCalcCustomFunction CalcCustomFunction = {read=FCalcCustomFunction, write=FCalcCustomFunction};
	__property TErrorEvent OnError = {read=FOnError, write=FOnError};
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt Error_NoError = 0x0;
static const ShortInt Error_NoFormula = 0x1;
static const ShortInt Error_DivisionByZero = 0x2;
static const ShortInt Error_InvalidValue = 0x3;
static const ShortInt Error_InvalidCellRef = 0x4;
static const ShortInt Error_InvalidRangeRef = 0x5;
static const ShortInt Error_InvalidGridRef = 0x6;
static const ShortInt Error_InvalidNrOfParams = 0x7;
static const ShortInt Error_CircularReference = 0x8;
static const ShortInt Error_NoOpenParenthesis = 0x9;
static const ShortInt Error_NoCloseParenthesis = 0xa;
static const ShortInt Error_PrematureEndOfFormula = 0xb;
static const ShortInt Error_UnknownError = 0xc;
static const ShortInt Error_InvalidQualifier = 0xd;
static const ShortInt Error_InvalidTokenAtPosition = 0xe;
static const ShortInt Error_Overflow = 0xf;
static const ShortInt Error_Underflow = 0x10;
static const ShortInt Error_CircularRange = 0x11;
static const ShortInt Error_NoDataSource = 0x12;
static const ShortInt Error_NoDataSet = 0x13;
static const ShortInt Error_NoDataSetActive = 0x14;
static const ShortInt Error_MaxErrorNumber = 0x64;

}	/* namespace Advpars */
using namespace Advpars;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvparsHPP
