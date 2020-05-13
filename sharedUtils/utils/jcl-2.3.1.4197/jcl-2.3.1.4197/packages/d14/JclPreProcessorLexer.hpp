// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorlexer.pas' rev: 21.00

#ifndef JclpreprocessorlexerHPP
#define JclpreprocessorlexerHPP

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
#include <Jclstrhashmap.hpp>	// Pascal unit
#include <Jclstrings.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessorlexer
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TJppToken { ptEof, ptComment, ptText, ptEol, ptDefine, ptUndef, ptIfdef, ptIfndef, ptIfopt, ptElse, ptEndif, ptInclude, ptJppDefineMacro, ptJppExpandMacro, ptJppUndefMacro, ptJppGetStrValue, ptJppGetIntValue, ptJppGetBoolValue, ptJppSetStrValue, ptJppSetIntValue, ptJppSetBoolValue, ptJppLoop, ptJppDefine, ptJppUndef };
#pragma option pop

class DELPHICLASS EJppLexerError;
class PASCALIMPLEMENTATION EJppLexerError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJppLexerError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJppLexerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJppLexerError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJppLexerError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJppLexerError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJppLexerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJppLexerError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJppLexerError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJppLexerError(void) { }
	
};


class DELPHICLASS TJppLexer;
class PASCALIMPLEMENTATION TJppLexer : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FBuf;
	Jclstrhashmap::TStringHashMap* FTokenHash;
	System::WideChar *FCurrPos;
	int FCurrLine;
	TJppToken FCurrTok;
	System::UnicodeString FTokenAsString;
	System::UnicodeString FRawComment;
	bool FIgnoreUnterminatedStrings;
	
public:
	__fastcall TJppLexer(const System::UnicodeString ABuffer, bool AIgnoreUnterminatedStrings);
	__fastcall virtual ~TJppLexer(void);
	void __fastcall Error(const System::UnicodeString AMsg);
	void __fastcall NextTok(void);
	void __fastcall Reset(void);
	__property TJppToken CurrTok = {read=FCurrTok, nodefault};
	__property System::UnicodeString TokenAsString = {read=FTokenAsString};
	__property System::UnicodeString RawComment = {read=FRawComment};
	__property bool IgnoreUnterminatedStrings = {read=FIgnoreUnterminatedStrings, write=FIgnoreUnterminatedStrings, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorlexer */
using namespace Jclpreprocessorlexer;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorlexerHPP
