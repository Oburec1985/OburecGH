// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpcre.pas' rev: 21.00

#ifndef JclpcreHPP
#define JclpcreHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Pcre.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclstringconversions.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpcre
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EPCREError;
class PASCALIMPLEMENTATION EPCREError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
private:
	int FErrorCode;
	
public:
	__fastcall EPCREError(System::PResStringRec ResStringRec, int ErrorCode);
	__property int ErrorCode = {read=FErrorCode, nodefault};
public:
	/* Exception.Create */ inline __fastcall EPCREError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EPCREError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateResFmt */ inline __fastcall EPCREError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EPCREError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EPCREError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EPCREError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EPCREError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EPCREError(void) { }
	
};


typedef StaticArray<int, 1> TPCREIntArray;

typedef TPCREIntArray *PPCREIntArray;

#pragma option push -b-
enum TJclRegExOption { roIgnoreCase, roMultiLine, roDotAll, roExtended, roAnchored, roDollarEndOnly, roExtra, roNotBOL, roNotEOL, roUnGreedy, roNotEmpty, roUTF8, roNoAutoCapture, roNoUTF8Check, roAutoCallout, roPartial, roDfaShortest, roDfaRestart, roDfaFirstLine, roDupNames, roNewLineCR, roNewLineLF, roNewLineCRLF, roNewLineAny, roBSRAnyCRLF, roBSRUnicode, roJavascriptCompat, roNoStartOptimize, roPartialHard, roNotEmptyAtStart };
#pragma option pop

typedef Set<TJclRegExOption, roIgnoreCase, roNotEmptyAtStart>  TJclRegExOptions;

struct TJclCaptureRange
{
	
public:
	int FirstPos;
	int LastPos;
};


class DELPHICLASS TJclRegEx;
typedef void __fastcall (__closure *TJclRegExCallout)(TJclRegEx* Sender, int Index, int MatchStart, int SubjectPos, int LastCapture, int PatternPos, int NextItemLength, int &ErrorCode);

typedef Byte TPCRECalloutIndex;

class PASCALIMPLEMENTATION TJclRegEx : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<System::UnicodeString> _TJclRegEx__1;
	
	
private:
	Pcre::real_pcre *FCode;
	Pcre::real_pcre_extra *FExtra;
	TJclRegExOptions FOptions;
	System::UnicodeString FPattern;
	bool FDfaMode;
	System::UnicodeString FSubject;
	bool FViewChanges;
	Classes::TList* FChangedCaptures;
	_TJclRegEx__1 FResultValues;
	int FErrorCode;
	System::UnicodeString FErrorMessage;
	int FErrorOffset;
	TPCREIntArray *FVector;
	int FVectorSize;
	int FCaptureCount;
	TJclRegExCallout FOnCallout;
	System::UnicodeString __fastcall GetResult(void);
	System::UnicodeString __fastcall GetCapture(int Index);
	void __fastcall SetCapture(int Index, const System::UnicodeString Value);
	TJclCaptureRange __fastcall GetCaptureRange(int Index);
	System::UnicodeString __fastcall GetNamedCapture(const System::UnicodeString Name);
	void __fastcall SetNamedCapture(const System::UnicodeString Name, const System::UnicodeString Value);
	int __fastcall GetCaptureNameCount(void);
	System::UnicodeString __fastcall GetCaptureName(int Index);
	int __fastcall GetAPIOptions(bool RunTime);
	int __fastcall CalloutHandler(Pcre::pcre_callout_block &CalloutBlock);
	
public:
	__fastcall virtual ~TJclRegEx(void);
	__property TJclRegExOptions Options = {read=FOptions, write=FOptions, nodefault};
	bool __fastcall Compile(const System::UnicodeString Pattern, bool Study, bool UserLocale = false);
	__property System::UnicodeString Pattern = {read=FPattern};
	__property bool DfaMode = {read=FDfaMode, write=FDfaMode, nodefault};
	bool __fastcall Match(const System::UnicodeString Subject, unsigned StartOffset = (unsigned)(0x1));
	__property System::UnicodeString Subject = {read=FSubject};
	__property System::UnicodeString Result = {read=GetResult};
	__property bool ViewChanges = {read=FViewChanges, write=FViewChanges, nodefault};
	__property int CaptureCount = {read=FCaptureCount, write=FCaptureCount, nodefault};
	__property System::UnicodeString Captures[int Index] = {read=GetCapture, write=SetCapture};
	__property TJclCaptureRange CaptureRanges[int Index] = {read=GetCaptureRange};
	__property System::UnicodeString NamedCaptures[const System::UnicodeString Name] = {read=GetNamedCapture, write=SetNamedCapture};
	__property int CaptureNameCount = {read=GetCaptureNameCount, nodefault};
	__property System::UnicodeString CaptureNames[int Index] = {read=GetCaptureName};
	int __fastcall IndexOfName(const System::UnicodeString Name);
	bool __fastcall IsNameValid(const System::UnicodeString Name);
	__property int ErrorCode = {read=FErrorCode, nodefault};
	__property System::UnicodeString ErrorMessage = {read=FErrorMessage};
	__property int ErrorOffset = {read=FErrorOffset, nodefault};
	__property TJclRegExCallout OnCallout = {read=FOnCallout, write=FOnCallout};
public:
	/* TObject.Create */ inline __fastcall TJclRegEx(void) : System::TObject() { }
	
};


typedef TJclRegEx TJclAnsiRegEx;

typedef TJclRegExOption TJclAnsiRegExOption;

typedef TJclRegExOptions TJclAnsiRegExOptions;

typedef TJclCaptureRange TJclAnsiCaptureRange;

typedef TJclRegExCallout TJclAnsiRegExCallout;

//-- var, const, procedure ---------------------------------------------------
static const ShortInt JCL_PCRE_CALLOUT_NOERROR = 0x0;
static const ShortInt JCL_PCRE_CALLOUT_FAILCONTINUE = 0x1;
static const short JCL_PCRE_ERROR_CALLOUTERROR = -998;
static const short JCL_PCRE_ERROR_STUDYFAILED = -999;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall InitializeLocaleSupport(void);
extern PACKAGE void __fastcall TerminateLocaleSupport(void);
extern PACKAGE System::UnicodeString __fastcall StrReplaceRegEx(const System::UnicodeString Subject, const System::UnicodeString Pattern, System::TVarRec *Args, const int Args_Size);

}	/* namespace Jclpcre */
using namespace Jclpcre;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpcreHPP
