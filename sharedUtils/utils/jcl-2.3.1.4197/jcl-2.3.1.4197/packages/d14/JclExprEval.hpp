// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclexpreval.pas' rev: 21.00

#ifndef JclexprevalHPP
#define JclexprevalHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit
#include <Jclstrhashmap.hpp>	// Pascal unit
#include <Jclresources.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclexpreval
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclExprEvalError;
class PASCALIMPLEMENTATION EJclExprEvalError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclExprEvalError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclExprEvalError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclExprEvalError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclExprEvalError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclExprEvalError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclExprEvalError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclExprEvalError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclExprEvalError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclExprEvalError(void) { }
	
};


typedef System::Extended TFloat;

typedef float TFloat32;

typedef float *PFloat32;

typedef double TFloat64;

typedef double *PFloat64;

typedef System::Extended TFloat80;

typedef System::Extended *PFloat80;

typedef System::Extended __fastcall (*TFloatFunc)(void);

typedef float __fastcall (*TFloat32Func)(void);

typedef double __fastcall (*TFloat64Func)(void);

typedef System::Extended __fastcall (*TFloat80Func)(void);

typedef System::Extended __fastcall (*TUnaryFunc)(System::Extended X);

typedef float __fastcall (*TUnary32Func)(float X);

typedef double __fastcall (*TUnary64Func)(double X);

typedef System::Extended __fastcall (*TUnary80Func)(System::Extended X);

typedef System::Extended __fastcall (*TBinaryFunc)(System::Extended X, System::Extended Y);

typedef float __fastcall (*TBinary32Func)(float X, float Y);

typedef double __fastcall (*TBinary64Func)(double X, double Y);

typedef System::Extended __fastcall (*TBinary80Func)(System::Extended X, System::Extended Y);

typedef System::Extended __fastcall (*TTernaryFunc)(System::Extended X, System::Extended Y, System::Extended Z);

typedef float __fastcall (*TTernary32Func)(float X, float Y, float Z);

typedef double __fastcall (*TTernary64Func)(double X, double Y, double Z);

typedef System::Extended __fastcall (*TTernary80Func)(System::Extended X, System::Extended Y, System::Extended Z);

class DELPHICLASS TExprContext;
class DELPHICLASS TExprSym;
class PASCALIMPLEMENTATION TExprContext : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	virtual TExprSym* __fastcall Find(const System::UnicodeString AName) = 0 ;
public:
	/* TObject.Create */ inline __fastcall TExprContext(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TExprContext(void) { }
	
};


class DELPHICLASS TExprHashContext;
class PASCALIMPLEMENTATION TExprHashContext : public TExprContext
{
	typedef TExprContext inherited;
	
private:
	Jclstrhashmap::TStringHashMap* FHashMap;
	
public:
	__fastcall TExprHashContext(bool ACaseSensitive, int AHashSize);
	__fastcall virtual ~TExprHashContext(void);
	void __fastcall Add(TExprSym* ASymbol);
	void __fastcall Remove(const System::UnicodeString AName);
	virtual TExprSym* __fastcall Find(const System::UnicodeString AName);
};


class DELPHICLASS TExprSetContext;
class PASCALIMPLEMENTATION TExprSetContext : public TExprContext
{
	typedef TExprContext inherited;
	
private:
	Classes::TList* FList;
	bool FOwnsContexts;
	TExprContext* __fastcall GetContexts(int AIndex);
	int __fastcall GetCount(void);
	
public:
	__fastcall TExprSetContext(bool AOwnsContexts);
	__fastcall virtual ~TExprSetContext(void);
	void __fastcall Add(TExprContext* AContext);
	void __fastcall Remove(TExprContext* AContext);
	void __fastcall Delete(int AIndex);
	TExprContext* __fastcall Extract(TExprContext* AContext);
	__property int Count = {read=GetCount, nodefault};
	__property TExprContext* Contexts[int AIndex] = {read=GetContexts};
	__property Classes::TList* InternalList = {read=FList};
	virtual TExprSym* __fastcall Find(const System::UnicodeString AName);
};


class DELPHICLASS TExprLexer;
class DELPHICLASS TExprEvalParser;
class DELPHICLASS TExprCompileParser;
class DELPHICLASS TExprNodeFactory;
class DELPHICLASS TExprNode;
class PASCALIMPLEMENTATION TExprSym : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FIdent;
	TExprLexer* FLexer;
	TExprEvalParser* FEvalParser;
	TExprCompileParser* FCompileParser;
	TExprNodeFactory* FNodeFactory;
	
public:
	__fastcall TExprSym(const System::UnicodeString AIdent);
	virtual System::Extended __fastcall Evaluate(void) = 0 ;
	virtual TExprNode* __fastcall Compile(void) = 0 ;
	__property System::UnicodeString Ident = {read=FIdent};
	__property TExprLexer* Lexer = {read=FLexer, write=FLexer};
	__property TExprCompileParser* CompileParser = {read=FCompileParser, write=FCompileParser};
	__property TExprEvalParser* EvalParser = {read=FEvalParser, write=FEvalParser};
	__property TExprNodeFactory* NodeFactory = {read=FNodeFactory, write=FNodeFactory};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprSym(void) { }
	
};


#pragma option push -b-
enum TExprToken { etEof, etNumber, etIdentifier, etUser0, etUser1, etUser2, etUser3, etUser4, etUser5, etUser6, etUser7, etUser8, etUser9, etUser10, etUser11, etUser12, etUser13, etUser14, etUser15, etUser16, etUser17, etUser18, etUser19, etUser20, etUser21, etUser22, etUser23, etUser24, etUser25, etUser26, etUser27, etUser28, etUser29, etUser30, etUser31, etNotEqual, etLessEqual, etGreaterEqual, etBang, etDoubleQuote, etHash, etDollar, etPercent, etAmpersand, etSingleQuote, etLParen, etRParen, etAsterisk, etPlus, etComma, etMinus, etDot, etForwardSlash, etColon, etSemiColon, etLessThan, etEqualTo, etGreaterThan, etQuestion, etAt, etLBracket, etBackSlash, etRBracket, etArrow, etBackTick, etLBrace, etPipe, etRBrace, etTilde, et127, etEuro, et129, et130, et131, et132, et133, et134, et135, et136, et137, et138, et139, et140, et141, et142, et143, et144, et145, et146, et147, et148, et149, et150, et151, et152, et153, et154, et155, et156, et157, et158, et159, et160, et161, et162, et163, et164, et165, et166, et167, 
	et168, et169, et170, et171, et172, et173, et174, et175, et176, et177, et178, et179, et180, et181, et182, et183, et184, et185, et186, et187, et188, et189, et190, et191, et192, et193, et194, et195, et196, et197, et198, et199, et200, et201, et202, et203, et204, et205, et206, et207, et208, et209, et210, et211, et212, et213, et214, et215, et216, et217, et218, et219, et220, et221, et222, et223, et224, et225, et226, et227, et228, et229, et230, et231, et232, et233, et234, et235, et236, et237, et238, et239, et240, et241, et242, et243, et244, et245, et246, et247, et248, et249, et250, et251, et252, et253, et254, et255, etInvalid };
#pragma option pop

class PASCALIMPLEMENTATION TExprLexer : public System::TObject
{
	typedef System::TObject inherited;
	
protected:
	TExprToken FCurrTok;
	System::Extended FTokenAsNumber;
	System::UnicodeString FTokenAsString;
	
public:
	__fastcall TExprLexer(void);
	virtual void __fastcall NextTok(void) = 0 ;
	virtual void __fastcall Reset(void);
	__property System::UnicodeString TokenAsString = {read=FTokenAsString};
	__property System::Extended TokenAsNumber = {read=FTokenAsNumber};
	__property TExprToken CurrTok = {read=FCurrTok, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprLexer(void) { }
	
};


class PASCALIMPLEMENTATION TExprNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TExprNode* operator[](int AIndex) { return Deps[AIndex]; }
	
private:
	Classes::TList* FDepList;
	int __fastcall GetDepCount(void);
	TExprNode* __fastcall GetDeps(int AIndex);
	
public:
	__fastcall TExprNode(TExprNode* const *ADepList, const int ADepList_Size);
	__fastcall virtual ~TExprNode(void);
	void __fastcall AddDep(TExprNode* ADep);
	__property int DepCount = {read=GetDepCount, nodefault};
	__property TExprNode* Deps[int AIndex] = {read=GetDeps/*, default*/};
	__property Classes::TList* DepList = {read=FDepList};
};


class PASCALIMPLEMENTATION TExprNodeFactory : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	virtual TExprNode* __fastcall LoadVar32(PFloat32 ALoc) = 0 ;
	virtual TExprNode* __fastcall LoadVar64(PFloat64 ALoc) = 0 ;
	virtual TExprNode* __fastcall LoadVar80(PFloat80 ALoc) = 0 ;
	virtual TExprNode* __fastcall LoadConst32(float AValue) = 0 ;
	virtual TExprNode* __fastcall LoadConst64(double AValue) = 0 ;
	virtual TExprNode* __fastcall LoadConst80(System::Extended AValue) = 0 ;
	virtual TExprNode* __fastcall CallFloatFunc(TFloatFunc AFunc) = 0 ;
	virtual TExprNode* __fastcall CallFloat32Func(TFloat32Func AFunc) = 0 ;
	virtual TExprNode* __fastcall CallFloat64Func(TFloat64Func AFunc) = 0 ;
	virtual TExprNode* __fastcall CallFloat80Func(TFloat80Func AFunc) = 0 ;
	virtual TExprNode* __fastcall CallUnaryFunc(TUnaryFunc AFunc, TExprNode* X) = 0 ;
	virtual TExprNode* __fastcall CallUnary32Func(TUnary32Func AFunc, TExprNode* X) = 0 ;
	virtual TExprNode* __fastcall CallUnary64Func(TUnary64Func AFunc, TExprNode* X) = 0 ;
	virtual TExprNode* __fastcall CallUnary80Func(TUnary80Func AFunc, TExprNode* X) = 0 ;
	virtual TExprNode* __fastcall CallBinaryFunc(TBinaryFunc AFunc, TExprNode* X, TExprNode* Y) = 0 ;
	virtual TExprNode* __fastcall CallBinary32Func(TBinary32Func AFunc, TExprNode* X, TExprNode* Y) = 0 ;
	virtual TExprNode* __fastcall CallBinary64Func(TBinary64Func AFunc, TExprNode* X, TExprNode* Y) = 0 ;
	virtual TExprNode* __fastcall CallBinary80Func(TBinary80Func AFunc, TExprNode* X, TExprNode* Y) = 0 ;
	virtual TExprNode* __fastcall CallTernaryFunc(TTernaryFunc AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z) = 0 ;
	virtual TExprNode* __fastcall CallTernary32Func(TTernary32Func AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z) = 0 ;
	virtual TExprNode* __fastcall CallTernary64Func(TTernary64Func AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z) = 0 ;
	virtual TExprNode* __fastcall CallTernary80Func(TTernary80Func AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z) = 0 ;
	virtual TExprNode* __fastcall Add(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall Subtract(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall Multiply(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall Divide(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall IntegerDivide(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall Modulo(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall Negate(TExprNode* AValue) = 0 ;
	virtual TExprNode* __fastcall Compare(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall CompareEqual(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall CompareNotEqual(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall CompareLess(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall CompareLessEqual(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall CompareGreater(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall CompareGreaterEqual(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall LogicalAnd(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall LogicalOr(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall LogicalXor(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall LogicalNot(TExprNode* AValue) = 0 ;
	virtual TExprNode* __fastcall BitwiseAnd(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall BitwiseOr(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall BitwiseXor(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall BitwiseNot(TExprNode* AValue) = 0 ;
	virtual TExprNode* __fastcall ShiftLeft(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	virtual TExprNode* __fastcall ShiftRight(TExprNode* ALeft, TExprNode* ARight) = 0 ;
	TExprNode* __fastcall LoadVar(PFloat32 ALoc)/* overload */;
	TExprNode* __fastcall LoadVar(PFloat64 ALoc)/* overload */;
	TExprNode* __fastcall LoadVar(PFloat80 ALoc)/* overload */;
	TExprNode* __fastcall LoadConst(float AValue)/* overload */;
	TExprNode* __fastcall LoadConst(double AValue)/* overload */;
	TExprNode* __fastcall LoadConst(System::Extended AValue)/* overload */;
public:
	/* TObject.Create */ inline __fastcall TExprNodeFactory(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TExprNodeFactory(void) { }
	
};


class PASCALIMPLEMENTATION TExprCompileParser : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TExprContext* FContext;
	TExprLexer* FLexer;
	TExprNodeFactory* FNodeFactory;
	
protected:
	virtual TExprNode* __fastcall CompileExprLevel0(bool ASkip);
	virtual TExprNode* __fastcall CompileExprLevel1(bool ASkip);
	virtual TExprNode* __fastcall CompileExprLevel2(bool ASkip);
	virtual TExprNode* __fastcall CompileExprLevel3(bool ASkip);
	virtual TExprNode* __fastcall CompileFactor(void);
	virtual TExprNode* __fastcall CompileIdentFactor(void);
	
public:
	__fastcall TExprCompileParser(TExprLexer* ALexer, TExprNodeFactory* ANodeFactory);
	virtual TExprNode* __fastcall Compile(void);
	__property TExprLexer* Lexer = {read=FLexer};
	__property TExprNodeFactory* NodeFactory = {read=FNodeFactory};
	__property TExprContext* Context = {read=FContext, write=FContext};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprCompileParser(void) { }
	
};


class PASCALIMPLEMENTATION TExprEvalParser : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TExprContext* FContext;
	TExprLexer* FLexer;
	
protected:
	virtual System::Extended __fastcall EvalExprLevel0(bool ASkip);
	virtual System::Extended __fastcall EvalExprLevel1(bool ASkip);
	virtual System::Extended __fastcall EvalExprLevel2(bool ASkip);
	virtual System::Extended __fastcall EvalExprLevel3(bool ASkip);
	virtual System::Extended __fastcall EvalFactor(void);
	virtual System::Extended __fastcall EvalIdentFactor(void);
	
public:
	__fastcall TExprEvalParser(TExprLexer* ALexer);
	virtual System::Extended __fastcall Evaluate(void);
	__property TExprLexer* Lexer = {read=FLexer};
	__property TExprContext* Context = {read=FContext, write=FContext};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprEvalParser(void) { }
	
};


class DELPHICLASS TExprSimpleLexer;
class PASCALIMPLEMENTATION TExprSimpleLexer : public TExprLexer
{
	typedef TExprLexer inherited;
	
protected:
	System::WideChar *FCurrPos;
	System::UnicodeString FBuf;
	void __fastcall SetBuf(const System::UnicodeString ABuf);
	
public:
	__fastcall TExprSimpleLexer(const System::UnicodeString ABuf);
	virtual void __fastcall NextTok(void);
	virtual void __fastcall Reset(void);
	__property System::UnicodeString Buf = {read=FBuf, write=SetBuf};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprSimpleLexer(void) { }
	
};


class DELPHICLASS TExprVirtMachOp;
class PASCALIMPLEMENTATION TExprVirtMachOp : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Jclbase::PFloat __fastcall GetOutputLoc(void);
	
protected:
	System::Extended FOutput;
	
public:
	virtual void __fastcall Execute(void) = 0 ;
	__property Jclbase::PFloat OutputLoc = {read=GetOutputLoc};
public:
	/* TObject.Create */ inline __fastcall TExprVirtMachOp(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TExprVirtMachOp(void) { }
	
};


class DELPHICLASS TExprVirtMach;
class PASCALIMPLEMENTATION TExprVirtMach : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TList* FCodeList;
	Classes::TList* FConstList;
	
public:
	__fastcall TExprVirtMach(void);
	__fastcall virtual ~TExprVirtMach(void);
	void __fastcall Add(TExprVirtMachOp* AOp);
	void __fastcall AddConst(TExprVirtMachOp* AOp);
	void __fastcall Clear(void);
	System::Extended __fastcall Execute(void);
};


class DELPHICLASS TExprVirtMachNodeFactory;
class PASCALIMPLEMENTATION TExprVirtMachNodeFactory : public TExprNodeFactory
{
	typedef TExprNodeFactory inherited;
	
private:
	Classes::TList* FNodeList;
	TExprNode* __fastcall AddNode(TExprNode* ANode);
	void __fastcall DoClean(TExprVirtMach* AVirtMach);
	void __fastcall DoConsts(TExprVirtMach* AVirtMach);
	void __fastcall DoCode(TExprVirtMach* AVirtMach);
	
public:
	__fastcall TExprVirtMachNodeFactory(void);
	__fastcall virtual ~TExprVirtMachNodeFactory(void);
	void __fastcall GenCode(TExprVirtMach* AVirtMach);
	virtual TExprNode* __fastcall LoadVar32(PFloat32 ALoc);
	virtual TExprNode* __fastcall LoadVar64(PFloat64 ALoc);
	virtual TExprNode* __fastcall LoadVar80(PFloat80 ALoc);
	virtual TExprNode* __fastcall LoadConst32(float AValue);
	virtual TExprNode* __fastcall LoadConst64(double AValue);
	virtual TExprNode* __fastcall LoadConst80(System::Extended AValue);
	virtual TExprNode* __fastcall CallFloatFunc(TFloatFunc AFunc);
	virtual TExprNode* __fastcall CallFloat32Func(TFloat32Func AFunc);
	virtual TExprNode* __fastcall CallFloat64Func(TFloat64Func AFunc);
	virtual TExprNode* __fastcall CallFloat80Func(TFloat80Func AFunc);
	virtual TExprNode* __fastcall CallUnaryFunc(TUnaryFunc AFunc, TExprNode* X);
	virtual TExprNode* __fastcall CallUnary32Func(TUnary32Func AFunc, TExprNode* X);
	virtual TExprNode* __fastcall CallUnary64Func(TUnary64Func AFunc, TExprNode* X);
	virtual TExprNode* __fastcall CallUnary80Func(TUnary80Func AFunc, TExprNode* X);
	virtual TExprNode* __fastcall CallBinaryFunc(TBinaryFunc AFunc, TExprNode* X, TExprNode* Y);
	virtual TExprNode* __fastcall CallBinary32Func(TBinary32Func AFunc, TExprNode* X, TExprNode* Y);
	virtual TExprNode* __fastcall CallBinary64Func(TBinary64Func AFunc, TExprNode* X, TExprNode* Y);
	virtual TExprNode* __fastcall CallBinary80Func(TBinary80Func AFunc, TExprNode* X, TExprNode* Y);
	virtual TExprNode* __fastcall CallTernaryFunc(TTernaryFunc AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z);
	virtual TExprNode* __fastcall CallTernary32Func(TTernary32Func AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z);
	virtual TExprNode* __fastcall CallTernary64Func(TTernary64Func AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z);
	virtual TExprNode* __fastcall CallTernary80Func(TTernary80Func AFunc, TExprNode* X, TExprNode* Y, TExprNode* Z);
	virtual TExprNode* __fastcall Add(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall Subtract(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall Multiply(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall Divide(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall IntegerDivide(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall Modulo(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall Negate(TExprNode* AValue);
	virtual TExprNode* __fastcall Compare(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall CompareEqual(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall CompareNotEqual(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall CompareLess(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall CompareLessEqual(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall CompareGreater(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall CompareGreaterEqual(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall LogicalAnd(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall LogicalOr(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall LogicalXor(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall LogicalNot(TExprNode* AValue);
	virtual TExprNode* __fastcall BitwiseAnd(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall BitwiseOr(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall BitwiseXor(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall BitwiseNot(TExprNode* AValue);
	virtual TExprNode* __fastcall ShiftLeft(TExprNode* ALeft, TExprNode* ARight);
	virtual TExprNode* __fastcall ShiftRight(TExprNode* ALeft, TExprNode* ARight);
};


class DELPHICLASS TExprConstSym;
class PASCALIMPLEMENTATION TExprConstSym : public TExprSym
{
	typedef TExprSym inherited;
	
private:
	System::Extended FValue;
	
public:
	__fastcall TExprConstSym(const System::UnicodeString AIdent, System::Extended AValue);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprConstSym(void) { }
	
};


class DELPHICLASS TExprConst32Sym;
class PASCALIMPLEMENTATION TExprConst32Sym : public TExprSym
{
	typedef TExprSym inherited;
	
private:
	float FValue;
	
public:
	__fastcall TExprConst32Sym(const System::UnicodeString AIdent, float AValue);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprConst32Sym(void) { }
	
};


class DELPHICLASS TExprConst64Sym;
class PASCALIMPLEMENTATION TExprConst64Sym : public TExprSym
{
	typedef TExprSym inherited;
	
private:
	double FValue;
	
public:
	__fastcall TExprConst64Sym(const System::UnicodeString AIdent, double AValue);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprConst64Sym(void) { }
	
};


class DELPHICLASS TExprConst80Sym;
class PASCALIMPLEMENTATION TExprConst80Sym : public TExprSym
{
	typedef TExprSym inherited;
	
private:
	System::Extended FValue;
	
public:
	__fastcall TExprConst80Sym(const System::UnicodeString AIdent, System::Extended AValue);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprConst80Sym(void) { }
	
};


class DELPHICLASS TExprVar32Sym;
class PASCALIMPLEMENTATION TExprVar32Sym : public TExprSym
{
	typedef TExprSym inherited;
	
private:
	float *FLoc;
	
public:
	__fastcall TExprVar32Sym(const System::UnicodeString AIdent, PFloat32 ALoc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprVar32Sym(void) { }
	
};


class DELPHICLASS TExprVar64Sym;
class PASCALIMPLEMENTATION TExprVar64Sym : public TExprSym
{
	typedef TExprSym inherited;
	
private:
	double *FLoc;
	
public:
	__fastcall TExprVar64Sym(const System::UnicodeString AIdent, PFloat64 ALoc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprVar64Sym(void) { }
	
};


class DELPHICLASS TExprVar80Sym;
class PASCALIMPLEMENTATION TExprVar80Sym : public TExprSym
{
	typedef TExprSym inherited;
	
private:
	System::Extended *FLoc;
	
public:
	__fastcall TExprVar80Sym(const System::UnicodeString AIdent, PFloat80 ALoc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprVar80Sym(void) { }
	
};


class DELPHICLASS TExprAbstractFuncSym;
class PASCALIMPLEMENTATION TExprAbstractFuncSym : public TExprSym
{
	typedef TExprSym inherited;
	
protected:
	System::Extended __fastcall EvalFirstArg(void);
	System::Extended __fastcall EvalNextArg(void);
	TExprNode* __fastcall CompileFirstArg(void);
	TExprNode* __fastcall CompileNextArg(void);
	void __fastcall EndArgs(void);
public:
	/* TExprSym.Create */ inline __fastcall TExprAbstractFuncSym(const System::UnicodeString AIdent) : TExprSym(AIdent) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprAbstractFuncSym(void) { }
	
};


class DELPHICLASS TExprFuncSym;
class PASCALIMPLEMENTATION TExprFuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TFloatFunc FFunc;
	
public:
	__fastcall TExprFuncSym(const System::UnicodeString AIdent, TFloatFunc AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprFuncSym(void) { }
	
};


class DELPHICLASS TExprFloat32FuncSym;
class PASCALIMPLEMENTATION TExprFloat32FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TFloat32Func FFunc;
	
public:
	__fastcall TExprFloat32FuncSym(const System::UnicodeString AIdent, TFloat32Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprFloat32FuncSym(void) { }
	
};


class DELPHICLASS TExprFloat64FuncSym;
class PASCALIMPLEMENTATION TExprFloat64FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TFloat64Func FFunc;
	
public:
	__fastcall TExprFloat64FuncSym(const System::UnicodeString AIdent, TFloat64Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprFloat64FuncSym(void) { }
	
};


class DELPHICLASS TExprFloat80FuncSym;
class PASCALIMPLEMENTATION TExprFloat80FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TFloat80Func FFunc;
	
public:
	__fastcall TExprFloat80FuncSym(const System::UnicodeString AIdent, TFloat80Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprFloat80FuncSym(void) { }
	
};


class DELPHICLASS TExprUnaryFuncSym;
class PASCALIMPLEMENTATION TExprUnaryFuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TUnaryFunc FFunc;
	
public:
	__fastcall TExprUnaryFuncSym(const System::UnicodeString AIdent, TUnaryFunc AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprUnaryFuncSym(void) { }
	
};


class DELPHICLASS TExprUnary32FuncSym;
class PASCALIMPLEMENTATION TExprUnary32FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TUnary32Func FFunc;
	
public:
	__fastcall TExprUnary32FuncSym(const System::UnicodeString AIdent, TUnary32Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprUnary32FuncSym(void) { }
	
};


class DELPHICLASS TExprUnary64FuncSym;
class PASCALIMPLEMENTATION TExprUnary64FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TUnary64Func FFunc;
	
public:
	__fastcall TExprUnary64FuncSym(const System::UnicodeString AIdent, TUnary64Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprUnary64FuncSym(void) { }
	
};


class DELPHICLASS TExprUnary80FuncSym;
class PASCALIMPLEMENTATION TExprUnary80FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TUnary80Func FFunc;
	
public:
	__fastcall TExprUnary80FuncSym(const System::UnicodeString AIdent, TUnary80Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprUnary80FuncSym(void) { }
	
};


class DELPHICLASS TExprBinaryFuncSym;
class PASCALIMPLEMENTATION TExprBinaryFuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TBinaryFunc FFunc;
	
public:
	__fastcall TExprBinaryFuncSym(const System::UnicodeString AIdent, TBinaryFunc AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprBinaryFuncSym(void) { }
	
};


class DELPHICLASS TExprBinary32FuncSym;
class PASCALIMPLEMENTATION TExprBinary32FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TBinary32Func FFunc;
	
public:
	__fastcall TExprBinary32FuncSym(const System::UnicodeString AIdent, TBinary32Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprBinary32FuncSym(void) { }
	
};


class DELPHICLASS TExprBinary64FuncSym;
class PASCALIMPLEMENTATION TExprBinary64FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TBinary64Func FFunc;
	
public:
	__fastcall TExprBinary64FuncSym(const System::UnicodeString AIdent, TBinary64Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprBinary64FuncSym(void) { }
	
};


class DELPHICLASS TExprBinary80FuncSym;
class PASCALIMPLEMENTATION TExprBinary80FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TBinary80Func FFunc;
	
public:
	__fastcall TExprBinary80FuncSym(const System::UnicodeString AIdent, TBinary80Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprBinary80FuncSym(void) { }
	
};


class DELPHICLASS TExprTernaryFuncSym;
class PASCALIMPLEMENTATION TExprTernaryFuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TTernaryFunc FFunc;
	
public:
	__fastcall TExprTernaryFuncSym(const System::UnicodeString AIdent, TTernaryFunc AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprTernaryFuncSym(void) { }
	
};


class DELPHICLASS TExprTernary32FuncSym;
class PASCALIMPLEMENTATION TExprTernary32FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TTernary32Func FFunc;
	
public:
	__fastcall TExprTernary32FuncSym(const System::UnicodeString AIdent, TTernary32Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprTernary32FuncSym(void) { }
	
};


class DELPHICLASS TExprTernary64FuncSym;
class PASCALIMPLEMENTATION TExprTernary64FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TTernary64Func FFunc;
	
public:
	__fastcall TExprTernary64FuncSym(const System::UnicodeString AIdent, TTernary64Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprTernary64FuncSym(void) { }
	
};


class DELPHICLASS TExprTernary80FuncSym;
class PASCALIMPLEMENTATION TExprTernary80FuncSym : public TExprAbstractFuncSym
{
	typedef TExprAbstractFuncSym inherited;
	
private:
	TTernary80Func FFunc;
	
public:
	__fastcall TExprTernary80FuncSym(const System::UnicodeString AIdent, TTernary80Func AFunc);
	virtual System::Extended __fastcall Evaluate(void);
	virtual TExprNode* __fastcall Compile(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TExprTernary80FuncSym(void) { }
	
};


class DELPHICLASS TEasyEvaluator;
class PASCALIMPLEMENTATION TEasyEvaluator : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TExprHashContext* FOwnContext;
	TExprSetContext* FExtContextSet;
	TExprSetContext* FInternalContextSet;
	
protected:
	__property TExprSetContext* InternalContextSet = {read=FInternalContextSet};
	
public:
	__fastcall TEasyEvaluator(void);
	__fastcall virtual ~TEasyEvaluator(void);
	void __fastcall AddVar(const System::UnicodeString AName, float &AVar)/* overload */;
	void __fastcall AddVar(const System::UnicodeString AName, double &AVar)/* overload */;
	void __fastcall AddVar(const System::UnicodeString AName, System::Extended &AVar)/* overload */;
	void __fastcall AddConst(const System::UnicodeString AName, float AConst)/* overload */;
	void __fastcall AddConst(const System::UnicodeString AName, double AConst)/* overload */;
	void __fastcall AddConst(const System::UnicodeString AName, System::Extended AConst)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TFloat32Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TFloat64Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TFloat80Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TUnary32Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TUnary64Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TUnary80Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TBinary32Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TBinary64Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TBinary80Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TTernary32Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TTernary64Func AFunc)/* overload */;
	void __fastcall AddFunc(const System::UnicodeString AName, TTernary80Func AFunc)/* overload */;
	void __fastcall Remove(const System::UnicodeString AName);
	virtual void __fastcall Clear(void);
	__property TExprSetContext* ExtContextSet = {read=FExtContextSet};
};


class DELPHICLASS TEvaluator;
class PASCALIMPLEMENTATION TEvaluator : public TEasyEvaluator
{
	typedef TEasyEvaluator inherited;
	
private:
	TExprSimpleLexer* FLexer;
	TExprEvalParser* FParser;
	
public:
	__fastcall TEvaluator(void);
	__fastcall virtual ~TEvaluator(void);
	System::Extended __fastcall Evaluate(const System::UnicodeString AExpr);
};


class DELPHICLASS TCompiledEvaluator;
class PASCALIMPLEMENTATION TCompiledEvaluator : public TEasyEvaluator
{
	typedef TEasyEvaluator inherited;
	
private:
	System::UnicodeString FExpr;
	TExprVirtMach* FVirtMach;
	
public:
	__fastcall TCompiledEvaluator(void);
	__fastcall virtual ~TCompiledEvaluator(void);
	void __fastcall Compile(const System::UnicodeString AExpr);
	System::Extended __fastcall Evaluate(void);
};


typedef System::Extended __fastcall (__closure *TCompiledExpression)(void);

class DELPHICLASS TExpressionCompiler;
class PASCALIMPLEMENTATION TExpressionCompiler : public TEasyEvaluator
{
	typedef TEasyEvaluator inherited;
	
private:
	Jclstrhashmap::TStringHashMap* FExprHash;
	
public:
	__fastcall TExpressionCompiler(void);
	__fastcall virtual ~TExpressionCompiler(void);
	TCompiledExpression __fastcall Compile(const System::UnicodeString AExpr);
	HIDESBASE void __fastcall Remove(const System::UnicodeString AExpr);
	void __fastcall Delete(TCompiledExpression ACompiledExpression);
	virtual void __fastcall Clear(void);
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt cExprEvalHashSize = 0x7f;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclexpreval */
using namespace Jclexpreval;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclexprevalHPP
