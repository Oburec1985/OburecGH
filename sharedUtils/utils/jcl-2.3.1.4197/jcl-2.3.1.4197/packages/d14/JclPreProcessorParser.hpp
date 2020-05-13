// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorparser.pas' rev: 21.00

#ifndef JclpreprocessorparserHPP
#define JclpreprocessorparserHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclpreprocessorlexer.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessorparser
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EPppParserError;
class PASCALIMPLEMENTATION EPppParserError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EPppParserError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EPppParserError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EPppParserError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EPppParserError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EPppParserError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EPppParserError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EPppParserError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EPppParserError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EPppParserError(void) { }
	
};


class DELPHICLASS TJppParser;
class DELPHICLASS TPppState;
class PASCALIMPLEMENTATION TJppParser : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Jclpreprocessorlexer::TJppLexer* FLexer;
	TPppState* FState;
	System::UnicodeString FResult;
	int FResultLen;
	int FLineBreakPos;
	bool FAllWhiteSpaceIn;
	bool FAllWhiteSpaceOut;
	
protected:
	void __fastcall AddResult(const System::UnicodeString S, bool FixIndent = false, bool ForceRecurseTest = false);
	bool __fastcall IsExcludedInclude(const System::UnicodeString FileName);
	void __fastcall NextToken(void);
	void __fastcall ParseText(void);
	void __fastcall ParseCondition(Jclpreprocessorlexer::TJppToken Token);
	System::UnicodeString __fastcall ParseInclude(void);
	void __fastcall ParseDefine(bool Skip);
	void __fastcall ParseUndef(bool Skip);
	void __fastcall ParseDefineMacro(void);
	void __fastcall ParseExpandMacro(void);
	void __fastcall ParseUndefMacro(void);
	void __fastcall ParseGetBoolValue(void);
	void __fastcall ParseGetIntValue(void);
	void __fastcall ParseGetStrValue(void);
	void __fastcall ParseLoop(void);
	void __fastcall ParseSetBoolValue(void);
	void __fastcall ParseSetIntValue(void);
	void __fastcall ParseSetStrValue(void);
	
public:
	__fastcall TJppParser(const System::UnicodeString ABuffer, TPppState* APppState);
	__fastcall virtual ~TJppParser(void);
	System::UnicodeString __fastcall Parse(void);
	__property Jclpreprocessorlexer::TJppLexer* Lexer = {read=FLexer};
	__property TPppState* State = {read=FState};
};


class DELPHICLASS EPppState;
class PASCALIMPLEMENTATION EPppState : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EPppState(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EPppState(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EPppState(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EPppState(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EPppState(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EPppState(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EPppState(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EPppState(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EPppState(void) { }
	
};


#pragma option push -b-
enum TPppOption { poProcessIncludes, poProcessDefines, poStripComments, poProcessMacros, poProcessValues, poNoWarningHeader, poKeepTabAndSpaces, poIgnoreUnterminatedStrings };
#pragma option pop

typedef Set<TPppOption, poProcessIncludes, poIgnoreUnterminatedStrings>  TPppOptions;

#pragma option push -b-
enum TTriState { ttUnknown, ttUndef, ttDefined };
#pragma option pop

class DELPHICLASS TPppStateItem;
class PASCALIMPLEMENTATION TPppStateItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	Jclcontainerintf::_di_IJclUnicodeStrMap DefinedKeywords;
	Jclcontainerintf::_di_IJclUnicodeStrList ExcludedFiles;
	Jclcontainerintf::_di_IJclUnicodeStrIntfMap Macros;
	Jclcontainerintf::_di_IJclUnicodeStrList SearchPath;
	TTriState TriState;
public:
	/* TObject.Create */ inline __fastcall TPppStateItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TPppStateItem(void) { }
	
};


typedef TMetaClass* TPppStateItemClass;

class DELPHICLASS TPppProvider;
class PASCALIMPLEMENTATION TPppProvider : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
protected:
	virtual bool __fastcall GetBoolValue(const System::UnicodeString Name) = 0 ;
	virtual TTriState __fastcall GetDefine(const System::UnicodeString ASymbol) = 0 ;
	virtual int __fastcall GetIntegerValue(const System::UnicodeString Name) = 0 ;
	virtual System::UnicodeString __fastcall GetStringValue(const System::UnicodeString Name) = 0 ;
	virtual void __fastcall SetBoolValue(const System::UnicodeString Name, bool Value) = 0 ;
	virtual void __fastcall SetDefine(const System::UnicodeString ASymbol, const TTriState Value) = 0 ;
	virtual void __fastcall SetIntegerValue(const System::UnicodeString Name, int Value) = 0 ;
	virtual void __fastcall SetStringValue(const System::UnicodeString Name, const System::UnicodeString Value) = 0 ;
	
public:
	__property TTriState Defines[const System::UnicodeString ASymbol] = {read=GetDefine, write=SetDefine};
	__property bool BoolValues[const System::UnicodeString Name] = {read=GetBoolValue, write=SetBoolValue};
	__property System::UnicodeString StringValues[const System::UnicodeString Name] = {read=GetStringValue, write=SetStringValue};
	__property int IntegerValues[const System::UnicodeString Name] = {read=GetIntegerValue, write=SetIntegerValue};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TPppProvider(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TPppProvider(void) : Classes::TPersistent() { }
	
};


class PASCALIMPLEMENTATION TPppState : public TPppProvider
{
	typedef TPppProvider inherited;
	
private:
	Jclcontainerintf::_di_IJclStack FStateStack;
	TPppOptions FOptions;
	Jclcontainerintf::_di_IJclUnicodeStrMap __fastcall InternalPeekDefines(void);
	Jclcontainerintf::_di_IJclUnicodeStrList __fastcall InternalPeekExcludedFiles(void);
	Jclcontainerintf::_di_IJclUnicodeStrIntfMap __fastcall InternalPeekMacros(void);
	Jclcontainerintf::_di_IJclUnicodeStrList __fastcall InternalPeekSearchPath(void);
	TTriState __fastcall InternalPeekTriState(void);
	void __fastcall InternalSetTriState(TTriState Value);
	
protected:
	__classmethod virtual TPppStateItemClass __fastcall StateItemClass();
	virtual void __fastcall InternalPushState(TPppStateItem* FromStateItem, TPppStateItem* ToStateItem);
	TPppStateItem* __fastcall PeekStateItem(void);
	TPppOptions __fastcall GetOptions(void);
	void __fastcall SetOptions(TPppOptions AOptions);
	Jclcontainerintf::_di_IJclUnicodeStrList __fastcall FindMacro(const System::UnicodeString AMacroName);
	Jclbase::TDynWideStringArray __fastcall AssociateParameters(const Jclcontainerintf::_di_IJclUnicodeStrList ParamNames, const Jclbase::TDynStringArray ParamValues);
	virtual bool __fastcall GetBoolValue(const System::UnicodeString Name);
	virtual TTriState __fastcall GetDefine(const System::UnicodeString ASymbol);
	virtual int __fastcall GetIntegerValue(const System::UnicodeString Name);
	virtual System::UnicodeString __fastcall GetStringValue(const System::UnicodeString Name);
	virtual void __fastcall SetBoolValue(const System::UnicodeString Name, bool Value);
	virtual void __fastcall SetDefine(const System::UnicodeString ASymbol, const TTriState Value);
	virtual void __fastcall SetIntegerValue(const System::UnicodeString Name, int Value);
	virtual void __fastcall SetStringValue(const System::UnicodeString Name, const System::UnicodeString Value);
	
public:
	__fastcall TPppState(void);
	__fastcall virtual ~TPppState(void);
	virtual void __fastcall AfterConstruction(void);
	void __fastcall PushState(void);
	void __fastcall PopState(void);
	__property TTriState TriState = {read=InternalPeekTriState, write=InternalSetTriState, nodefault};
	void __fastcall Define(const System::UnicodeString ASymbol);
	void __fastcall Undef(const System::UnicodeString ASymbol);
	Classes::TStream* __fastcall FindFile(const System::UnicodeString AName);
	void __fastcall AddToSearchPath(const System::UnicodeString AName);
	void __fastcall AddFileToExclusionList(const System::UnicodeString AName);
	bool __fastcall IsFileExcluded(const System::UnicodeString AName);
	virtual System::UnicodeString __fastcall ExpandMacro(const System::UnicodeString AName, const Jclbase::TDynStringArray ParamValues);
	void __fastcall DefineMacro(const System::UnicodeString AName, const Jclbase::TDynStringArray ParamNames, const System::UnicodeString Value);
	void __fastcall UndefMacro(const System::UnicodeString AName, const Jclbase::TDynStringArray ParamNames);
	__property TPppOptions Options = {read=GetOptions, write=SetOptions, nodefault};
};


typedef TMetaClass* TPppStateClass;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorparser */
using namespace Jclpreprocessorparser;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorparserHPP
