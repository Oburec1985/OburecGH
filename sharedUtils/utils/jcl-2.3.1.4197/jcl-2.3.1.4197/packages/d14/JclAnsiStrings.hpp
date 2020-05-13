// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclansistrings.pas' rev: 21.00

#ifndef JclansistringsHPP
#define JclansistringsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Ansistrings.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclansistrings
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclAnsiStrings;
class PASCALIMPLEMENTATION TJclAnsiStrings : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
public:
	System::AnsiString operator[](int Index) { return Strings[Index]; }
	
private:
	char FDelimiter;
	char FNameValueSeparator;
	bool FStrictDelimiter;
	char FQuoteChar;
	System::AnsiString __fastcall GetText(void);
	void __fastcall SetText(const System::AnsiString Value);
	System::AnsiString __fastcall GetCommaText(void);
	void __fastcall SetCommaText(const System::AnsiString Value);
	System::AnsiString __fastcall GetDelimitedText(void)/* overload */;
	System::AnsiString __fastcall GetDelimitedText(const System::AnsiString ADelimiter, char AQuoteChar)/* overload */;
	void __fastcall SetDelimitedText(const System::AnsiString Value)/* overload */;
	void __fastcall SetDelimitedText(const System::AnsiString Value, const System::AnsiString ADelimiter, char AQuoteChar)/* overload */;
	System::AnsiString __fastcall ExtractName(const System::AnsiString S);
	System::AnsiString __fastcall GetName(int Index);
	System::AnsiString __fastcall GetValue(const System::AnsiString Name);
	void __fastcall SetValue(const System::AnsiString Name, const System::AnsiString Value);
	System::AnsiString __fastcall GetValueFromIndex(int Index);
	void __fastcall SetValueFromIndex(int Index, const System::AnsiString Value);
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	void __fastcall Error(const System::UnicodeString Msg, int Data)/* overload */;
	void __fastcall Error(System::PResStringRec Msg, int Data)/* overload */;
	virtual System::AnsiString __fastcall GetString(int Index) = 0 ;
	virtual void __fastcall SetString(int Index, const System::AnsiString Value) = 0 ;
	virtual System::TObject* __fastcall GetObject(int Index) = 0 ;
	virtual void __fastcall SetObject(int Index, System::TObject* AObject) = 0 ;
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall SetCapacity(const int Value);
	virtual int __fastcall GetCount(void) = 0 ;
	virtual int __fastcall CompareStrings(const System::AnsiString S1, const System::AnsiString S2);
	
public:
	__fastcall TJclAnsiStrings(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	virtual int __fastcall Add(const System::AnsiString S);
	virtual int __fastcall AddObject(const System::AnsiString S, System::TObject* AObject) = 0 ;
	virtual void __fastcall AddStrings(TJclAnsiStrings* Strings);
	virtual void __fastcall Insert(int Index, const System::AnsiString S);
	virtual void __fastcall InsertObject(int Index, const System::AnsiString S, System::TObject* AObject) = 0 ;
	virtual void __fastcall Delete(int Index) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual void __fastcall LoadFromFile(const Sysutils::TFileName FileName);
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream);
	virtual void __fastcall SaveToFile(const Sysutils::TFileName FileName);
	virtual void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall BeginUpdate(void);
	void __fastcall EndUpdate(void);
	virtual int __fastcall IndexOf(const System::AnsiString S);
	virtual int __fastcall IndexOfName(const System::AnsiString Name);
	virtual int __fastcall IndexOfObject(System::TObject* AObject);
	virtual void __fastcall Exchange(int Index1, int Index2);
	__property char Delimiter = {read=FDelimiter, write=FDelimiter, nodefault};
	__property System::AnsiString DelimitedText = {read=GetDelimitedText, write=SetDelimitedText};
	__property System::AnsiString CommaText = {read=GetCommaText, write=SetCommaText};
	__property bool StrictDelimiter = {read=FStrictDelimiter, write=FStrictDelimiter, nodefault};
	__property char QuoteChar = {read=FQuoteChar, write=FQuoteChar, nodefault};
	__property System::AnsiString Strings[int Index] = {read=GetString, write=SetString/*, default*/};
	__property System::TObject* Objects[int Index] = {read=GetObject, write=SetObject};
	__property System::AnsiString Text = {read=GetText, write=SetText};
	__property int Count = {read=GetCount, nodefault};
	__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
	__property System::AnsiString Names[int Index] = {read=GetName};
	__property System::AnsiString Values[const System::AnsiString Name] = {read=GetValue, write=SetValue};
	__property System::AnsiString ValueFromIndex[int Index] = {read=GetValueFromIndex, write=SetValueFromIndex};
	__property char NameValueSeparator = {read=FNameValueSeparator, write=FNameValueSeparator, nodefault};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TJclAnsiStrings(void) { }
	
};


class DELPHICLASS TJclAnsiStringList;
typedef int __fastcall (*TJclAnsiStringListSortCompare)(TJclAnsiStringList* List, int Index1, int Index2);

struct TJclAnsiStringObjectHolder
{
	
public:
	System::AnsiString Str;
	System::TObject* Obj;
};


class PASCALIMPLEMENTATION TJclAnsiStringList : public TJclAnsiStrings
{
	typedef TJclAnsiStrings inherited;
	
private:
	typedef DynamicArray<TJclAnsiStringObjectHolder> _TJclAnsiStringList__1;
	
	
private:
	_TJclAnsiStringList__1 FStrings;
	int FCount;
	Classes::TDuplicates FDuplicates;
	bool FSorted;
	bool FCaseSensitive;
	void __fastcall Grow(void);
	void __fastcall QuickSort(int L, int R, TJclAnsiStringListSortCompare SCompare);
	void __fastcall SetSorted(bool Value);
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	virtual System::AnsiString __fastcall GetString(int Index);
	virtual void __fastcall SetString(int Index, const System::AnsiString Value);
	virtual System::TObject* __fastcall GetObject(int Index);
	virtual void __fastcall SetObject(int Index, System::TObject* AObject);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall SetCapacity(const int Value);
	virtual int __fastcall GetCount(void);
	virtual int __fastcall CompareStrings(const System::AnsiString S1, const System::AnsiString S2);
	
public:
	__fastcall TJclAnsiStringList(void);
	virtual int __fastcall AddObject(const System::AnsiString S, System::TObject* AObject);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	virtual void __fastcall InsertObject(int Index, const System::AnsiString S, System::TObject* AObject);
	virtual void __fastcall Delete(int Index);
	virtual bool __fastcall Find(const System::AnsiString S, int &Index);
	virtual void __fastcall CustomSort(TJclAnsiStringListSortCompare Compare);
	virtual void __fastcall Sort(void);
	virtual void __fastcall Clear(void);
	__property bool CaseSensitive = {read=FCaseSensitive, write=FCaseSensitive, nodefault};
	__property Classes::TDuplicates Duplicates = {read=FDuplicates, write=FDuplicates, nodefault};
	__property bool Sorted = {read=FSorted, write=SetSorted, nodefault};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TJclAnsiStringList(void) { }
	
};


typedef TJclAnsiStrings TAnsiStrings;

typedef TJclAnsiStringList TAnsiStringList;

class DELPHICLASS EJclAnsiStringError;
class PASCALIMPLEMENTATION EJclAnsiStringError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclAnsiStringError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclAnsiStringError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclAnsiStringError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclAnsiStringError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclAnsiStringError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclAnsiStringError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclAnsiStringError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclAnsiStringError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclAnsiStringError(void) { }
	
};


class DELPHICLASS EJclAnsiStringListError;
class PASCALIMPLEMENTATION EJclAnsiStringListError : public EJclAnsiStringError
{
	typedef EJclAnsiStringError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclAnsiStringListError(const System::UnicodeString Msg) : EJclAnsiStringError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclAnsiStringListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EJclAnsiStringError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclAnsiStringListError(int Ident)/* overload */ : EJclAnsiStringError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclAnsiStringListError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EJclAnsiStringError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclAnsiStringListError(const System::UnicodeString Msg, int AHelpContext) : EJclAnsiStringError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclAnsiStringListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EJclAnsiStringError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclAnsiStringListError(int Ident, int AHelpContext)/* overload */ : EJclAnsiStringError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclAnsiStringListError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EJclAnsiStringError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclAnsiStringListError(void) { }
	
};


typedef char * *PAnsiCharVector;

typedef char * PAnsiMultiSz;

//-- var, const, procedure ---------------------------------------------------
static const char AnsiNull = '\x0';
static const char AnsiSoh = '\x1';
static const char AnsiStx = '\x2';
static const char AnsiEtx = '\x3';
static const char AnsiEot = '\x4';
static const char AnsiEnq = '\x5';
static const char AnsiAck = '\x6';
static const char AnsiBell = '\x7';
static const char AnsiBackspace = '\x8';
static const char AnsiTab = '\x9';
static const char AnsiLineFeed = '\xa';
static const char AnsiVerticalTab = '\xb';
static const char AnsiFormFeed = '\xc';
static const char AnsiCarriageReturn = '\xd';
#define AnsiCrLf "\r\n"
static const char AnsiSo = '\xe';
static const char AnsiSi = '\xf';
static const char AnsiDle = '\x10';
static const char AnsiDc1 = '\x11';
static const char AnsiDc2 = '\x12';
static const char AnsiDc3 = '\x13';
static const char AnsiDc4 = '\x14';
static const char AnsiNak = '\x15';
static const char AnsiSyn = '\x16';
static const char AnsiEtb = '\x17';
static const char AnsiCan = '\x18';
static const char AnsiEm = '\x19';
static const char AnsiEndOfFile = '\x1a';
static const char AnsiEscape = '\x1b';
static const char AnsiFs = '\x1c';
static const char AnsiGs = '\x1d';
static const char AnsiRs = '\x1e';
static const char AnsiUs = '\x1f';
static const char AnsiSpace = '\x20';
static const char AnsiComma = '\x2c';
static const char AnsiBackslash = '\x5c';
static const char AnsiForwardSlash = '\x2f';
static const char AnsiDoubleQuote = '\x22';
static const char AnsiSingleQuote = '\x27';
#define AnsiLineBreak "\r\n"
static const char AnsiSignMinus = '\x2d';
static const char AnsiSignPlus = '\x2b';
#define AnsiWhiteSpace (Set<char, 0, 255> () << '\x9' << '\xa' << '\xb' << '\xc' << '\xd' << '\x20' )
#define AnsiSigns (Set<char, 0, 255> () << '\x2b' << '\x2d' )
#define AnsiUppercaseLetters (Set<char, 0, 255> () << '\x41' << '\x42' << '\x43' << '\x44' << '\x45' << '\x46' << '\x47' << '\x48' << '\x49' << '\x4a' << '\x4b' << '\x4c' << '\x4d' << '\x4e' << '\x4f' << '\x50' << '\x51' << '\x52' << '\x53' << '\x54' << '\x55' << '\x56' << '\x57' << '\x58' << '\x59' << '\x5a' )
#define AnsiLowercaseLetters (Set<char, 0, 255> () << '\x61' << '\x62' << '\x63' << '\x64' << '\x65' << '\x66' << '\x67' << '\x68' << '\x69' << '\x6a' << '\x6b' << '\x6c' << '\x6d' << '\x6e' << '\x6f' << '\x70' << '\x71' << '\x72' << '\x73' << '\x74' << '\x75' << '\x76' << '\x77' << '\x78' << '\x79' << '\x7a' )
#define AnsiLetters (Set<char, 0, 255> () << '\x41' << '\x42' << '\x43' << '\x44' << '\x45' << '\x46' << '\x47' << '\x48' << '\x49' << '\x4a' << '\x4b' << '\x4c' << '\x4d' << '\x4e' << '\x4f' << '\x50' << '\x51' << '\x52' << '\x53' << '\x54' << '\x55' << '\x56' << '\x57' << '\x58' << '\x59' << '\x5a' << '\x61' << '\x62' << '\x63' << '\x64' << '\x65' << '\x66' << '\x67' << '\x68' << '\x69' << '\x6a' << '\x6b' << '\x6c' << '\x6d' << '\x6e' << '\x6f' << '\x70' << '\x71' << '\x72' << '\x73' << '\x74' << '\x75' << '\x76' << '\x77' << '\x78' << '\x79' << '\x7a' )
#define AnsiDecDigits (Set<char, 0, 255> () << '\x30' << '\x31' << '\x32' << '\x33' << '\x34' << '\x35' << '\x36' << '\x37' << '\x38' << '\x39' )
#define AnsiOctDigits (Set<char, 0, 255> () << '\x30' << '\x31' << '\x32' << '\x33' << '\x34' << '\x35' << '\x36' << '\x37' )
#define AnsiHexDigits (Set<char, 0, 255> () << '\x30' << '\x31' << '\x32' << '\x33' << '\x34' << '\x35' << '\x36' << '\x37' << '\x38' << '\x39' << '\x41' << '\x42' << '\x43' << '\x44' << '\x45' << '\x46' << '\x61' << '\x62' << '\x63' << '\x64' << '\x65' << '\x66' )
#define AnsiValidIdentifierLetters (Set<char, 0, 255> () << '\x30' << '\x31' << '\x32' << '\x33' << '\x34' << '\x35' << '\x36' << '\x37' << '\x38' << '\x39' << '\x41' << '\x42' << '\x43' << '\x44' << '\x45' << '\x46' << '\x47' << '\x48' << '\x49' << '\x4a' << '\x4b' << '\x4c' << '\x4d' << '\x4e' << '\x4f' << '\x50' << '\x51' << '\x52' << '\x53' << '\x54' << '\x55' << '\x56' << '\x57' << '\x58' << '\x59' << '\x5a' << '\x5f' << '\x61' << '\x62' << '\x63' << '\x64' << '\x65' << '\x66' << '\x67' << '\x68' << '\x69' << '\x6a' << '\x6b' << '\x6c' << '\x6d' << '\x6e' << '\x6f' << '\x70' << '\x71' << '\x72' << '\x73' << '\x74' << '\x75' << '\x76' << '\x77' << '\x78' << '\x79' << '\x7a' )
static const Word AnsiCharCount = 0x100;
static const ShortInt AnsiLoOffset = 0x0;
static const Word AnsiUpOffset = 0x100;
static const Word AnsiReOffset = 0x200;
static const Word AnsiCaseMapSize = 0x300;
extern PACKAGE StaticArray<char, 768> AnsiCaseMap;
extern PACKAGE bool AnsiCaseMapReady;
extern PACKAGE StaticArray<System::Word, 256> AnsiCharTypes;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall StrIsAlpha(const System::AnsiString S);
extern PACKAGE bool __fastcall StrIsAlphaNum(const System::AnsiString S);
extern PACKAGE bool __fastcall StrConsistsOfNumberChars(const System::AnsiString S);
extern PACKAGE bool __fastcall StrContainsChars(const System::AnsiString S, const Sysutils::TSysCharSet &Chars, bool CheckAll);
extern PACKAGE bool __fastcall StrIsAlphaNumUnderscore(const System::AnsiString S);
extern PACKAGE bool __fastcall StrIsDigit(const System::AnsiString S);
extern PACKAGE bool __fastcall StrIsSubset(const System::AnsiString S, const Sysutils::TSysCharSet &ValidChars);
extern PACKAGE bool __fastcall StrSame(const System::AnsiString S1, const System::AnsiString S2);
extern PACKAGE System::AnsiString __fastcall StrCenter(const System::AnsiString S, int L, char C = '\x20');
extern PACKAGE System::AnsiString __fastcall StrCharPosLower(const System::AnsiString S, int CharPos);
extern PACKAGE System::AnsiString __fastcall StrCharPosUpper(const System::AnsiString S, int CharPos);
extern PACKAGE System::AnsiString __fastcall StrDoubleQuote(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall StrEnsureNoPrefix(const System::AnsiString Prefix, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall StrEnsureNoSuffix(const System::AnsiString Suffix, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall StrEnsurePrefix(const System::AnsiString Prefix, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall StrEnsureSuffix(const System::AnsiString Suffix, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall StrEscapedToString(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall StrLower(const System::AnsiString S);
extern PACKAGE void __fastcall StrLowerInPlace(System::AnsiString &S);
extern PACKAGE void __fastcall StrLowerBuff(char * S);
extern PACKAGE void __fastcall StrMove(System::AnsiString &Dest, const System::AnsiString Source, const int ToIndex, const int FromIndex, const int Count);
extern PACKAGE System::AnsiString __fastcall StrPadLeft(const System::AnsiString S, int Len, char C = '\x20');
extern PACKAGE System::AnsiString __fastcall StrPadRight(const System::AnsiString S, int Len, char C = '\x20');
extern PACKAGE System::AnsiString __fastcall StrProper(const System::AnsiString S);
extern PACKAGE void __fastcall StrProperBuff(char * S);
extern PACKAGE System::AnsiString __fastcall StrQuote(const System::AnsiString S, char C);
extern PACKAGE System::AnsiString __fastcall StrRemoveChars(const System::AnsiString S, const Sysutils::TSysCharSet &Chars);
extern PACKAGE System::AnsiString __fastcall StrKeepChars(const System::AnsiString S, const Sysutils::TSysCharSet &Chars);
extern PACKAGE System::AnsiString __fastcall StrRepeat(const System::AnsiString S, int Count);
extern PACKAGE System::AnsiString __fastcall StrRepeatLength(const System::AnsiString S, const int L);
extern PACKAGE void __fastcall StrReplace(System::AnsiString &S, const System::AnsiString Search, const System::AnsiString Replace, Sysutils::TReplaceFlags Flags = Sysutils::TReplaceFlags() );
extern PACKAGE System::AnsiString __fastcall StrReplaceChar(const System::AnsiString S, const char Source, const char Replace);
extern PACKAGE System::AnsiString __fastcall StrReplaceChars(const System::AnsiString S, const Sysutils::TSysCharSet &Chars, char Replace);
extern PACKAGE System::AnsiString __fastcall StrReplaceButChars(const System::AnsiString S, const Sysutils::TSysCharSet &Chars, char Replace);
extern PACKAGE System::AnsiString __fastcall StrReverse(const System::AnsiString S);
extern PACKAGE void __fastcall StrReverseInPlace(System::AnsiString &S);
extern PACKAGE System::AnsiString __fastcall StrSingleQuote(const System::AnsiString S);
extern PACKAGE void __fastcall StrSkipChars(char * &S, const Sysutils::TSysCharSet &Chars)/* overload */;
extern PACKAGE void __fastcall StrSkipChars(const System::AnsiString S, int &Index, const Sysutils::TSysCharSet &Chars)/* overload */;
extern PACKAGE System::AnsiString __fastcall StrSmartCase(const System::AnsiString S, const Sysutils::TSysCharSet &Delimiters);
extern PACKAGE System::AnsiString __fastcall StrStringToEscaped(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall StrStripNonNumberChars(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall StrToHex(const System::AnsiString Source);
extern PACKAGE System::AnsiString __fastcall StrTrimCharLeft(const System::AnsiString S, char C);
extern PACKAGE System::AnsiString __fastcall StrTrimCharsLeft(const System::AnsiString S, const Sysutils::TSysCharSet &Chars);
extern PACKAGE System::AnsiString __fastcall StrTrimCharsRight(const System::AnsiString S, const Sysutils::TSysCharSet &Chars);
extern PACKAGE System::AnsiString __fastcall StrTrimCharRight(const System::AnsiString S, char C);
extern PACKAGE System::AnsiString __fastcall StrTrimQuotes(const System::AnsiString S)/* overload */;
extern PACKAGE System::AnsiString __fastcall StrTrimQuotes(const System::AnsiString S, char QuoteChar)/* overload */;
extern PACKAGE System::AnsiString __fastcall StrUpper(const System::AnsiString S);
extern PACKAGE void __fastcall StrUpperInPlace(System::AnsiString &S);
extern PACKAGE void __fastcall StrUpperBuff(char * S);
extern PACKAGE System::AnsiString __fastcall StrOemToAnsi(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall StrAnsiToOem(const System::AnsiString S);
extern PACKAGE void __fastcall StrAddRef(System::AnsiString &S);
extern PACKAGE void __fastcall StrDecRef(System::AnsiString &S);
extern PACKAGE int __fastcall StrLength(const System::AnsiString S);
extern PACKAGE int __fastcall StrRefCount(const System::AnsiString S);
extern PACKAGE void __fastcall StrResetLength(System::AnsiString &S);
extern PACKAGE int __fastcall StrCharCount(const System::AnsiString S, char C);
extern PACKAGE int __fastcall StrCharsCount(const System::AnsiString S, const Sysutils::TSysCharSet &Chars);
extern PACKAGE int __fastcall StrStrCount(const System::AnsiString S, const System::AnsiString SubS);
extern PACKAGE int __fastcall StrCompareRangeEx(const System::AnsiString S1, const System::AnsiString S2, int Index, int Count, bool CaseSensitive = false);
extern PACKAGE int __fastcall StrCompare(const System::AnsiString S1, const System::AnsiString S2, bool CaseSensitive = false);
extern PACKAGE int __fastcall StrCompareRange(const System::AnsiString S1, const System::AnsiString S2, int Index, int Count, bool CaseSensitive = true);
extern PACKAGE System::AnsiString __fastcall StrRepeatChar(char C, int Count);
extern PACKAGE int __fastcall StrFind(const System::AnsiString Substr, const System::AnsiString S, const int Index = 0x1);
extern PACKAGE bool __fastcall StrHasPrefix(const System::AnsiString S, System::AnsiString const *Prefixes, const int Prefixes_Size);
extern PACKAGE bool __fastcall StrHasSuffix(const System::AnsiString S, System::AnsiString const *Suffixes, const int Suffixes_Size);
extern PACKAGE bool __fastcall StrIHasPrefix(const System::AnsiString S, System::AnsiString const *Prefixes, const int Prefixes_Size);
extern PACKAGE bool __fastcall StrIHasSuffix(const System::AnsiString S, System::AnsiString const *Suffixes, const int Suffixes_Size);
extern PACKAGE int __fastcall StrIndex(const System::AnsiString S, System::AnsiString const *List, const int List_Size, bool CaseSensitive = false);
extern PACKAGE int __fastcall StrILastPos(const System::AnsiString SubStr, const System::AnsiString S);
extern PACKAGE int __fastcall StrIPos(const System::AnsiString SubStr, const System::AnsiString S);
extern PACKAGE int __fastcall StrIPrefixIndex(const System::AnsiString S, System::AnsiString const *Prefixes, const int Prefixes_Size);
extern PACKAGE bool __fastcall StrIsOneOf(const System::AnsiString S, System::AnsiString const *List, const int List_Size);
extern PACKAGE int __fastcall StrISuffixIndex(const System::AnsiString S, System::AnsiString const *Suffixes, const int Suffixes_Size);
extern PACKAGE int __fastcall StrLastPos(const System::AnsiString SubStr, const System::AnsiString S);
extern PACKAGE int __fastcall StrMatch(const System::AnsiString Substr, const System::AnsiString S, int Index = 0x1);
extern PACKAGE bool __fastcall StrMatches(const System::AnsiString Substr, const System::AnsiString S, const int Index = 0x1);
extern PACKAGE int __fastcall StrNPos(const System::AnsiString S, const System::AnsiString SubStr, int N);
extern PACKAGE int __fastcall StrNIPos(const System::AnsiString S, const System::AnsiString SubStr, int N);
extern PACKAGE int __fastcall StrPrefixIndex(const System::AnsiString S, System::AnsiString const *Prefixes, const int Prefixes_Size);
extern PACKAGE int __fastcall StrSearch(const System::AnsiString Substr, const System::AnsiString S, const int Index = 0x1);
extern PACKAGE int __fastcall StrSuffixIndex(const System::AnsiString S, System::AnsiString const *Suffixes, const int Suffixes_Size);
extern PACKAGE System::AnsiString __fastcall StrAfter(const System::AnsiString SubStr, const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall StrBefore(const System::AnsiString SubStr, const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall StrBetween(const System::AnsiString S, const char Start, const char Stop);
extern PACKAGE System::AnsiString __fastcall StrChopRight(const System::AnsiString S, int N);
extern PACKAGE System::AnsiString __fastcall StrLeft(const System::AnsiString S, int Count);
extern PACKAGE System::AnsiString __fastcall StrMid(const System::AnsiString S, int Start, int Count);
extern PACKAGE System::AnsiString __fastcall StrRestOf(const System::AnsiString S, int N);
extern PACKAGE System::AnsiString __fastcall StrRight(const System::AnsiString S, int Count);
extern PACKAGE bool __fastcall CharEqualNoCase(const char C1, const char C2);
extern PACKAGE bool __fastcall CharIsAlpha(const char C);
extern PACKAGE bool __fastcall CharIsAlphaNum(const char C);
extern PACKAGE bool __fastcall CharIsBlank(const char C);
extern PACKAGE bool __fastcall CharIsControl(const char C);
extern PACKAGE bool __fastcall CharIsDelete(const char C);
extern PACKAGE bool __fastcall CharIsDigit(const char C);
extern PACKAGE bool __fastcall CharIsFracDigit(const char C);
extern PACKAGE bool __fastcall CharIsHexDigit(const char C);
extern PACKAGE bool __fastcall CharIsLower(const char C);
extern PACKAGE bool __fastcall CharIsNumberChar(const char C);
extern PACKAGE bool __fastcall CharIsNumber(const char C);
extern PACKAGE bool __fastcall CharIsPrintable(const char C);
extern PACKAGE bool __fastcall CharIsPunctuation(const char C);
extern PACKAGE bool __fastcall CharIsReturn(const char C);
extern PACKAGE bool __fastcall CharIsSpace(const char C);
extern PACKAGE bool __fastcall CharIsUpper(const char C);
extern PACKAGE bool __fastcall CharIsValidIdentifierLetter(const char C);
extern PACKAGE bool __fastcall CharIsWhiteSpace(const char C);
extern PACKAGE bool __fastcall CharIsWildcard(const char C);
extern PACKAGE System::Word __fastcall CharType(const char C);
extern PACKAGE PAnsiCharVector __fastcall StringsToPCharVector(PAnsiCharVector &Dest, const TJclAnsiStrings* Source);
extern PACKAGE int __fastcall PCharVectorCount(PAnsiCharVector Source);
extern PACKAGE void __fastcall PCharVectorToStrings(const TJclAnsiStrings* Dest, PAnsiCharVector Source);
extern PACKAGE void __fastcall FreePCharVector(PAnsiCharVector &Dest);
extern PACKAGE System::Byte __fastcall CharHex(const char C);
extern PACKAGE char __fastcall CharLower(const char C);
extern PACKAGE char __fastcall CharToggleCase(const char C);
extern PACKAGE char __fastcall CharUpper(const char C);
extern PACKAGE int __fastcall CharLastPos(const System::AnsiString S, const char C, const int Index = 0x1);
extern PACKAGE int __fastcall CharPos(const System::AnsiString S, const char C, const int Index = 0x1);
extern PACKAGE int __fastcall CharIPos(const System::AnsiString S, char C, const int Index = 0x1);
extern PACKAGE int __fastcall CharReplace(System::AnsiString &S, const char Search, const char Replace);
extern PACKAGE char * __fastcall StringsToMultiSz(char * &Dest, const TJclAnsiStrings* Source);
extern PACKAGE void __fastcall MultiSzToStrings(const TJclAnsiStrings* Dest, const char * Source);
extern PACKAGE int __fastcall MultiSzLength(const char * Source);
extern PACKAGE void __fastcall AllocateMultiSz(char * &Dest, int Len);
extern PACKAGE void __fastcall FreeMultiSz(char * &Dest);
extern PACKAGE char * __fastcall MultiSzDup(const char * Source);
extern PACKAGE void __fastcall StrToStrings(System::AnsiString S, System::AnsiString Sep, const TJclAnsiStrings* List, const bool AllowEmptyString = true);
extern PACKAGE void __fastcall StrIToStrings(System::AnsiString S, System::AnsiString Sep, const TJclAnsiStrings* List, const bool AllowEmptyString = true);
extern PACKAGE System::AnsiString __fastcall StringsToStr(const TJclAnsiStrings* List, const System::AnsiString Sep, const bool AllowEmptyString = true);
extern PACKAGE void __fastcall TrimStrings(const TJclAnsiStrings* List, bool DeleteIfEmpty = true);
extern PACKAGE void __fastcall TrimStringsRight(const TJclAnsiStrings* List, bool DeleteIfEmpty = true);
extern PACKAGE void __fastcall TrimStringsLeft(const TJclAnsiStrings* List, bool DeleteIfEmpty = true);
extern PACKAGE bool __fastcall AddStringToStrings(const System::AnsiString S, TJclAnsiStrings* Strings, const bool Unique);
extern PACKAGE System::AnsiString __fastcall FileToString(const Sysutils::TFileName FileName);
extern PACKAGE void __fastcall StringToFile(const Sysutils::TFileName FileName, const System::AnsiString Contents, bool Append = false);
extern PACKAGE System::AnsiString __fastcall StrToken(System::AnsiString &S, char Separator);
extern PACKAGE void __fastcall StrTokens(const System::AnsiString S, const TJclAnsiStrings* List);
extern PACKAGE void __fastcall StrTokenToStrings(System::AnsiString S, char Separator, const TJclAnsiStrings* List);
extern PACKAGE bool __fastcall StrWord(const System::AnsiString S, int &Index, /* out */ System::AnsiString &Word)/* overload */;
extern PACKAGE bool __fastcall StrWord(char * &S, /* out */ System::AnsiString &Word)/* overload */;
extern PACKAGE bool __fastcall StrIdent(const System::AnsiString S, int &Index, /* out */ System::AnsiString &Ident)/* overload */;
extern PACKAGE bool __fastcall StrIdent(char * &S, /* out */ System::AnsiString &Ident)/* overload */;
extern PACKAGE System::Extended __fastcall StrToFloatSafe(const System::AnsiString S);
extern PACKAGE int __fastcall StrToIntSafe(const System::AnsiString S);
extern PACKAGE void __fastcall StrNormIndex(const int StrLen, int &Index, int &Count)/* overload */;
extern PACKAGE Jclbase::TDynStringArray __fastcall ArrayOf(TJclAnsiStrings* List)/* overload */;
extern PACKAGE int __fastcall AnsiCompareNaturalStr(const System::AnsiString S1, const System::AnsiString S2)/* overload */;
extern PACKAGE int __fastcall AnsiCompareNaturalText(const System::AnsiString S1, const System::AnsiString S2)/* overload */;

}	/* namespace Jclansistrings */
using namespace Jclansistrings;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclansistringsHPP
