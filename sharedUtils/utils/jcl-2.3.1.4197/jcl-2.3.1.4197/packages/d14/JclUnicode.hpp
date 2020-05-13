// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclunicode.pas' rev: 21.00

#ifndef JclunicodeHPP
#define JclunicodeHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclunicode
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TSaveFormat { sfUTF16LSB, sfUTF16MSB, sfUTF8, sfAnsi };
#pragma option pop

#pragma option push -b-
enum TCharacterCategory { ccLetterUppercase, ccLetterLowercase, ccLetterTitlecase, ccMarkNonSpacing, ccMarkSpacingCombining, ccMarkEnclosing, ccNumberDecimalDigit, ccNumberLetter, ccNumberOther, ccSeparatorSpace, ccSeparatorLine, ccSeparatorParagraph, ccOtherControl, ccOtherFormat, ccOtherSurrogate, ccOtherPrivate, ccOtherUnassigned, ccLetterModifier, ccLetterOther, ccPunctuationConnector, ccPunctuationDash, ccPunctuationOpen, ccPunctuationClose, ccPunctuationInitialQuote, ccPunctuationFinalQuote, ccPunctuationOther, ccSymbolMath, ccSymbolCurrency, ccSymbolModifier, ccSymbolOther, ccLeftToRight, ccLeftToRightEmbedding, ccLeftToRightOverride, ccRightToLeft, ccRightToLeftArabic, ccRightToLeftEmbedding, ccRightToLeftOverride, ccPopDirectionalFormat, ccEuropeanNumber, ccEuropeanNumberSeparator, ccEuropeanNumberTerminator, ccArabicNumber, ccCommonNumberSeparator, ccBoundaryNeutral, ccSegmentSeparator, ccWhiteSpace, ccOtherNeutrals, ccComposed, ccNonBreaking, ccSymmetric, ccHexDigit, ccQuotationMark, ccMirroring, 
	ccAssigned, ccASCIIHexDigit, ccBidiControl, ccDash, ccDeprecated, ccDiacritic, ccExtender, ccHyphen, ccIdeographic, ccIDSBinaryOperator, ccIDSTrinaryOperator, ccJoinControl, ccLogicalOrderException, ccNonCharacterCodePoint, ccOtherAlphabetic, ccOtherDefaultIgnorableCodePoint, ccOtherGraphemeExtend, ccOtherIDContinue, ccOtherIDStart, ccOtherLowercase, ccOtherMath, ccOtherUppercase, ccPatternSyntax, ccPatternWhiteSpace, ccRadical, ccSoftDotted, ccSTerm, ccTerminalPunctuation, ccUnifiedIdeograph, ccVariationSelector };
#pragma option pop

typedef Set<TCharacterCategory, ccLetterUppercase, ccVariationSelector>  TCharacterCategories;

#pragma option push -b-
enum TNormalizationForm { nfNone, nfC, nfD, nfKC, nfKD };
#pragma option pop

#pragma option push -b-
enum TCompatibilityFormattingTag { cftCanonical, cftFont, cftNoBreak, cftInitial, cftMedial, cftFinal, cftIsolated, cftCircle, cftSuper, cftSub, cftVertical, cftWide, cftNarrow, cftSmall, cftSquare, cftFraction, cftCompat };
#pragma option pop

struct TUnicodeBlockRange
{
	
public:
	unsigned RangeStart;
	unsigned RangeEnd;
};


#pragma option push -b-
enum TUnicodeBlock { ubUndefined, ubBasicLatin, ubLatin1Supplement, ubLatinExtendedA, ubLatinExtendedB, ubIPAExtensions, ubSpacingModifierLetters, ubCombiningDiacriticalMarks, ubGreekandCoptic, ubCyrillic, ubCyrillicSupplement, ubArmenian, ubHebrew, ubArabic, ubSyriac, ubArabicSupplement, ubThaana, ubNKo, ubDevanagari, ubBengali, ubGurmukhi, ubGujarati, ubOriya, ubTamil, ubTelugu, ubKannada, ubMalayalam, ubSinhala, ubThai, ubLao, ubTibetan, ubMyanmar, ubGeorgian, ubHangulJamo, ubEthiopic, ubEthiopicSupplement, ubCherokee, ubUnifiedCanadianAboriginalSyllabics, ubOgham, ubRunic, ubTagalog, ubHanunoo, ubBuhid, ubTagbanwa, ubKhmer, ubMongolian, ubLimbu, ubTaiLe, ubNewTaiLue, ubKhmerSymbols, ubBuginese, ubBalinese, ubPhoneticExtensions, ubPhoneticExtensionsSupplement, ubCombiningDiacriticalMarksSupplement, ubLatinExtendedAdditional, ubGreekExtended, ubGeneralPunctuation, ubSuperscriptsandSubscripts, ubCurrencySymbols, ubCombiningDiacriticalMarksforSymbols, ubLetterlikeSymbols, ubNumberForms, ubArrows, 
	ubMathematicalOperators, ubMiscellaneousTechnical, ubControlPictures, ubOpticalCharacterRecognition, ubEnclosedAlphanumerics, ubBoxDrawing, ubBlockElements, ubGeometricShapes, ubMiscellaneousSymbols, ubDingbats, ubMiscellaneousMathematicalSymbolsA, ubSupplementalArrowsA, ubBraillePatterns, ubSupplementalArrowsB, ubMiscellaneousMathematicalSymbolsB, ubSupplementalMathematicalOperators, ubMiscellaneousSymbolsandArrows, ubGlagolitic, ubLatinExtendedC, ubCoptic, ubGeorgianSupplement, ubTifinagh, ubEthiopicExtended, ubSupplementalPunctuation, ubCJKRadicalsSupplement, ubKangxiRadicals, ubIdeographicDescriptionCharacters, ubCJKSymbolsandPunctuation, ubHiragana, ubKatakana, ubBopomofo, ubHangulCompatibilityJamo, ubKanbun, ubBopomofoExtended, ubCJKStrokes, ubKatakanaPhoneticExtensions, ubEnclosedCJKLettersandMonths, ubCJKCompatibility, ubCJKUnifiedIdeographsExtensionA, ubYijingHexagramSymbols, ubCJKUnifiedIdeographs, ubYiSyllables, ubYiRadicals, ubModifierToneLetters, ubLatinExtendedD, ubSylotiNagri, ubPhagsPa, ubHangulSyllables, 
	ubHighSurrogates, ubHighPrivateUseSurrogates, ubLowSurrogates, ubPrivateUseArea, ubCJKCompatibilityIdeographs, ubAlphabeticPresentationForms, ubArabicPresentationFormsA, ubVariationSelectors, ubVerticalForms, ubCombiningHalfMarks, ubCJKCompatibilityForms, ubSmallFormVariants, ubArabicPresentationFormsB, ubHalfwidthandFullwidthForms, ubSpecials, ubLinearBSyllabary, ubLinearBIdeograms, ubAegeanNumbers, ubAncientGreekNumbers, ubOldItalic, ubGothic, ubUgaritic, ubOldPersian, ubDeseret, ubShavian, ubOsmanya, ubCypriotSyllabary, ubPhoenician, ubKharoshthi, ubCuneiform, ubCuneiformNumbersAndPunctuation, ubByzantineMusicalSymbols, ubMusicalSymbols, ubAncientGreekMusicalNotation, ubTaiXuanJingSymbols, ubCountingRodNumerals, ubMathematicalAlphanumericSymbols, ubCJKUnifiedIdeographsExtensionB, ubCJKCompatibilityIdeographsSupplement, ubTags, ubVariationSelectorsSupplement, ubSupplementaryPrivateUseAreaA, ubSupplementaryPrivateUseAreaB };
#pragma option pop

struct TUnicodeBlockData
{
	
public:
	TUnicodeBlockRange Range;
	System::UnicodeString Name;
};


typedef TUnicodeBlockData *PUnicodeBlockData;

typedef StaticArray<TUnicodeBlockData, 155> Jclunicode__1;

#pragma option push -b-
enum TSearchFlag { sfCaseSensitive, sfIgnoreNonSpacing, sfSpaceCompress, sfWholeWordOnly };
#pragma option pop

typedef Set<TSearchFlag, sfCaseSensitive, sfWholeWordOnly>  TSearchFlags;

class DELPHICLASS TSearchEngine;
class DELPHICLASS TWideStrings;
class PASCALIMPLEMENTATION TSearchEngine : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TList* FResults;
	TWideStrings* FOwner;
	
protected:
	virtual int __fastcall GetCount(void);
	
public:
	__fastcall virtual TSearchEngine(TWideStrings* AOwner);
	__fastcall virtual ~TSearchEngine(void);
	virtual void __fastcall AddResult(int Start, int Stop);
	virtual void __fastcall Clear(void);
	virtual void __fastcall ClearResults(void);
	virtual void __fastcall DeleteResult(int Index);
	virtual void __fastcall FindPrepare(const System::WideString Pattern, TSearchFlags Options) = 0 /* overload */;
	virtual void __fastcall FindPrepare(System::WideChar * Pattern, int PatternLength, TSearchFlags Options) = 0 /* overload */;
	virtual bool __fastcall FindFirst(const System::WideString Text, int &Start, int &Stop) = 0 /* overload */;
	virtual bool __fastcall FindFirst(System::WideChar * Text, int TextLen, int &Start, int &Stop) = 0 /* overload */;
	virtual bool __fastcall FindAll(const System::WideString Text) = 0 /* overload */;
	virtual bool __fastcall FindAll(System::WideChar * Text, int TextLen) = 0 /* overload */;
	virtual void __fastcall GetResult(int Index, int &Start, int &Stop);
	__property int Count = {read=GetCount, nodefault};
};


struct TUTBMChar;
typedef TUTBMChar *PUTBMChar;

struct TUTBMChar
{
	
public:
	unsigned LoCase;
	unsigned UpCase;
	unsigned TitleCase;
};


struct TUTBMSkip;
typedef TUTBMSkip *PUTBMSkip;

struct TUTBMSkip
{
	
public:
	TUTBMChar *BMChar;
	int SkipValues;
};


class DELPHICLASS TUTBMSearch;
class PASCALIMPLEMENTATION TUTBMSearch : public TSearchEngine
{
	typedef TSearchEngine inherited;
	
private:
	TSearchFlags FFlags;
	TUTBMChar *FPattern;
	int FPatternUsed;
	int FPatternSize;
	int FPatternLength;
	TUTBMSkip *FSkipValues;
	int FSkipsUsed;
	int FMD4;
	
protected:
	void __fastcall ClearPattern(void);
	void __fastcall Compile(System::WideChar * Pattern, int PatternLength, TSearchFlags Flags);
	bool __fastcall Find(System::WideChar * Text, int TextLen, int &MatchStart, int &MatchEnd);
	int __fastcall GetSkipValue(System::WideChar * TextStart, System::WideChar * TextEnd);
	bool __fastcall Match(System::WideChar * Text, System::WideChar * Start, System::WideChar * Stop, int &MatchStart, int &MatchEnd);
	
public:
	virtual void __fastcall Clear(void);
	virtual void __fastcall FindPrepare(const System::WideString Pattern, TSearchFlags Options)/* overload */;
	virtual void __fastcall FindPrepare(System::WideChar * Pattern, int PatternLength, TSearchFlags Options)/* overload */;
	virtual bool __fastcall FindFirst(const System::WideString Text, int &Start, int &Stop)/* overload */;
	virtual bool __fastcall FindFirst(System::WideChar * Text, int TextLen, int &Start, int &Stop)/* overload */;
	virtual bool __fastcall FindAll(const System::WideString Text)/* overload */;
	virtual bool __fastcall FindAll(System::WideChar * Text, int TextLen)/* overload */;
public:
	/* TSearchEngine.Create */ inline __fastcall virtual TUTBMSearch(TWideStrings* AOwner) : TSearchEngine(AOwner) { }
	/* TSearchEngine.Destroy */ inline __fastcall virtual ~TUTBMSearch(void) { }
	
};


struct TUcRange;
typedef TUcRange *PUcRange;

struct TUcRange
{
	
public:
	unsigned MinCode;
	unsigned MaxCode;
};


struct TUcCClass
{
	
private:
	typedef DynamicArray<TUcRange> _TUcCClass__1;
	
	
public:
	_TUcCClass__1 Ranges;
	int RangesUsed;
};


struct TUcSymbol
{
	
public:
	unsigned Chr;
	TUcCClass CCL;
};


struct TUcElement
{
	
public:
	bool OnStack;
	int AType;
	int LHS;
	int RHS;
};


struct TUcStateList;
typedef TUcStateList *PUcStateList;

struct TUcStateList
{
	
private:
	typedef DynamicArray<int> _TUcStateList__1;
	
	
public:
	_TUcStateList__1 List;
	int ListUsed;
};


struct TUcSymbolTableEntry;
typedef TUcSymbolTableEntry *PUcSymbolTableEntry;

struct TUcSymbolTableEntry
{
	
public:
	int ID;
	int AType;
	TCharacterCategories Mods;
	TCharacterCategories Categories;
	TUcSymbol Symbol;
	TUcStateList States;
};


struct TUcState;
typedef TUcState *PUcState;

struct TUcState
{
	
private:
	typedef DynamicArray<TUcElement> _TUcState__1;
	
	
public:
	int ID;
	bool Accepting;
	TUcStateList StateList;
	_TUcState__1 Transitions;
	int TransitionsUsed;
};


struct TUcStateTable
{
	
private:
	typedef DynamicArray<TUcState> _TUcStateTable__1;
	
	
public:
	_TUcStateTable__1 States;
	int StatesUsed;
};


struct TUcEquivalent
{
	
public:
	int Left;
	int Right;
};


struct TUcExpressionList
{
	
private:
	typedef DynamicArray<TUcElement> _TUcExpressionList__1;
	
	
public:
	_TUcExpressionList__1 Expressions;
	int ExpressionsUsed;
};


struct TUcSymbolTable
{
	
private:
	typedef DynamicArray<TUcSymbolTableEntry> _TUcSymbolTable__1;
	
	
public:
	_TUcSymbolTable__1 Symbols;
	int SymbolsUsed;
};


struct TUcEquivalentList
{
	
private:
	typedef DynamicArray<TUcEquivalent> _TUcEquivalentList__1;
	
	
public:
	_TUcEquivalentList__1 Equivalents;
	int EquivalentsUsed;
};


struct TUREBuffer;
typedef TUREBuffer *PUREBuffer;

struct TUREBuffer
{
	
public:
	bool Reducing;
	int Error;
	unsigned Flags;
	TUcStateList Stack;
	TUcSymbolTable SymbolTable;
	TUcExpressionList ExpressionList;
	TUcStateTable States;
	TUcEquivalentList EquivalentList;
};


struct TUcTransition
{
	
public:
	int Symbol;
	int NextState;
};


struct TDFAState;
typedef TDFAState *PDFAState;

struct TDFAState
{
	
public:
	bool Accepting;
	int NumberTransitions;
	int StartTransition;
};


struct TDFAStates
{
	
private:
	typedef DynamicArray<TDFAState> _TDFAStates__1;
	
	
public:
	_TDFAStates__1 States;
	int StatesUsed;
};


struct TUcTransitions
{
	
private:
	typedef DynamicArray<TUcTransition> _TUcTransitions__1;
	
	
public:
	_TUcTransitions__1 Transitions;
	int TransitionsUsed;
};


struct TDFA
{
	
public:
	unsigned Flags;
	TUcSymbolTable SymbolTable;
	TDFAStates StateList;
	TUcTransitions TransitionList;
};


class DELPHICLASS TURESearch;
class PASCALIMPLEMENTATION TURESearch : public TSearchEngine
{
	typedef TSearchEngine inherited;
	
private:
	TUREBuffer FUREBuffer;
	TDFA FDFA;
	
protected:
	void __fastcall AddEquivalentPair(int L, int R);
	void __fastcall AddRange(TUcCClass &CCL, const TUcRange &Range);
	int __fastcall AddState(int *NewStates, const int NewStates_Size);
	void __fastcall AddSymbolState(int Symbol, int State);
	int __fastcall BuildCharacterClass(System::WideChar * CP, int Limit, PUcSymbolTableEntry Symbol);
	void __fastcall ClearUREBuffer(void);
	int __fastcall CompileSymbol(System::WideChar * S, int Limit, PUcSymbolTableEntry Symbol);
	void __fastcall CompileURE(System::WideChar * RE, int RELength, bool Casefold);
	void __fastcall CollectPendingOperations(int &State);
	int __fastcall ConvertRegExpToNFA(System::WideChar * RE, int RELength);
	bool __fastcall ExecuteURE(unsigned Flags, System::WideChar * Text, int TextLen, int &MatchStart, int &MatchEnd);
	void __fastcall ClearDFA(void);
	void __fastcall HexDigitSetup(PUcSymbolTableEntry Symbol);
	int __fastcall MakeExpression(int AType, int LHS, int RHS);
	int __fastcall MakeHexNumber(System::WideChar * NP, int Limit, unsigned &Number);
	int __fastcall MakeSymbol(System::WideChar * S, int Limit, /* out */ int &Consumed);
	void __fastcall MergeEquivalents(void);
	int __fastcall ParsePropertyList(System::WideChar * Properties, int Limit, TCharacterCategories &Categories);
	int __fastcall Peek(void);
	int __fastcall Pop(void);
	int __fastcall PosixCCL(System::WideChar * CP, int Limit, PUcSymbolTableEntry Symbol);
	int __fastcall ProbeLowSurrogate(System::WideChar * LeftState, int Limit, unsigned &Code);
	void __fastcall Push(int V);
	void __fastcall Reduce(int Start);
	void __fastcall SpaceSetup(PUcSymbolTableEntry Symbol, const TCharacterCategories &Categories);
	bool __fastcall SymbolsAreDifferent(PUcSymbolTableEntry A, PUcSymbolTableEntry B);
	
public:
	virtual void __fastcall Clear(void);
	virtual void __fastcall FindPrepare(const System::WideString Pattern, TSearchFlags Options)/* overload */;
	virtual void __fastcall FindPrepare(System::WideChar * Pattern, int PatternLength, TSearchFlags Options)/* overload */;
	virtual bool __fastcall FindFirst(const System::WideString Text, int &Start, int &Stop)/* overload */;
	virtual bool __fastcall FindFirst(System::WideChar * Text, int TextLen, int &Start, int &Stop)/* overload */;
	virtual bool __fastcall FindAll(const System::WideString Text)/* overload */;
	virtual bool __fastcall FindAll(System::WideChar * Text, int TextLen)/* overload */;
public:
	/* TSearchEngine.Create */ inline __fastcall virtual TURESearch(TWideStrings* AOwner) : TSearchEngine(AOwner) { }
	/* TSearchEngine.Destroy */ inline __fastcall virtual ~TURESearch(void) { }
	
};


typedef void __fastcall (__closure *TConfirmConversionEvent)(TWideStrings* Sender, bool &Allowed);

class PASCALIMPLEMENTATION TWideStrings : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
public:
	System::WideString operator[](int Index) { return Strings[Index]; }
	
private:
	int FUpdateCount;
	unsigned FLanguage;
	bool FSaved;
	TNormalizationForm FNormalizationForm;
	TConfirmConversionEvent FOnConfirmConversion;
	TSaveFormat FSaveFormat;
	System::WideString __fastcall GetCommaText(void);
	System::WideString __fastcall GetName(int Index);
	System::WideString __fastcall GetValue(const System::WideString Name);
	void __fastcall ReadData(Classes::TReader* Reader);
	void __fastcall SetCommaText(const System::WideString Value);
	void __fastcall SetNormalizationForm(const TNormalizationForm Value);
	void __fastcall SetValue(const System::WideString Name, const System::WideString Value);
	void __fastcall WriteData(Classes::TWriter* Writer);
	bool __fastcall GetSaveUnicode(void);
	void __fastcall SetSaveUnicode(const bool Value);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	virtual void __fastcall DoConfirmConversion(bool &Allowed);
	void __fastcall Error(const System::UnicodeString Msg, int Data);
	virtual System::WideString __fastcall Get(int Index) = 0 ;
	virtual int __fastcall GetCapacity(void);
	virtual int __fastcall GetCount(void) = 0 ;
	virtual System::TObject* __fastcall GetObject(int Index);
	virtual System::WideString __fastcall GetTextStr(void);
	virtual void __fastcall Put(int Index, const System::WideString S) = 0 ;
	virtual void __fastcall PutObject(int Index, System::TObject* AObject) = 0 ;
	virtual void __fastcall SetCapacity(int NewCapacity);
	virtual void __fastcall SetUpdateState(bool Updating);
	virtual void __fastcall SetLanguage(unsigned Value);
	
public:
	__fastcall TWideStrings(void);
	virtual int __fastcall Add(const System::WideString S);
	virtual int __fastcall AddObject(const System::WideString S, System::TObject* AObject);
	void __fastcall Append(const System::WideString S);
	virtual void __fastcall AddStrings(Classes::TStrings* Strings)/* overload */;
	virtual void __fastcall AddStrings(TWideStrings* Strings)/* overload */;
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	void __fastcall BeginUpdate(void);
	virtual void __fastcall Clear(void) = 0 ;
	virtual void __fastcall Delete(int Index) = 0 ;
	void __fastcall EndUpdate(void);
	HIDESBASE bool __fastcall Equals(TWideStrings* Strings);
	virtual void __fastcall Exchange(int Index1, int Index2);
	virtual System::WideString __fastcall GetSeparatedText(System::WideString Separators);
	virtual System::WideChar * __fastcall GetText(void);
	virtual int __fastcall IndexOf(const System::WideString S);
	int __fastcall IndexOfName(const System::WideString Name);
	int __fastcall IndexOfObject(System::TObject* AObject);
	virtual void __fastcall Insert(int Index, const System::WideString S) = 0 ;
	void __fastcall InsertObject(int Index, const System::WideString S, System::TObject* AObject);
	virtual void __fastcall LoadFromFile(const Sysutils::TFileName FileName);
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream);
	virtual void __fastcall Move(int CurIndex, int NewIndex);
	virtual void __fastcall SaveToFile(const Sysutils::TFileName FileName);
	virtual void __fastcall SaveToStream(Classes::TStream* Stream, bool WithBOM = true);
	virtual void __fastcall SetText(const System::WideString Value);
	__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
	__property System::WideString CommaText = {read=GetCommaText, write=SetCommaText};
	__property int Count = {read=GetCount, nodefault};
	__property unsigned Language = {read=FLanguage, write=SetLanguage, nodefault};
	__property System::WideString Names[int Index] = {read=GetName};
	__property TNormalizationForm NormalizationForm = {read=FNormalizationForm, write=SetNormalizationForm, default=1};
	__property System::TObject* Objects[int Index] = {read=GetObject, write=PutObject};
	__property System::WideString Values[const System::WideString Name] = {read=GetValue, write=SetValue};
	__property bool Saved = {read=FSaved, nodefault};
	__property bool SaveUnicode = {read=GetSaveUnicode, write=SetSaveUnicode, default=1};
	__property TSaveFormat SaveFormat = {read=FSaveFormat, write=FSaveFormat, default=0};
	__property System::WideString Strings[int Index] = {read=Get, write=Put/*, default*/};
	__property System::WideString Text = {read=GetTextStr, write=SetText};
	__property TConfirmConversionEvent OnConfirmConversion = {read=FOnConfirmConversion, write=FOnConfirmConversion};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TWideStrings(void) { }
	
};


struct TWideStringItem
{
	
public:
	System::WideChar *FString;
	System::TObject* FObject;
};


typedef DynamicArray<TWideStringItem> TWideStringItemList;

class DELPHICLASS TWideStringList;
class PASCALIMPLEMENTATION TWideStringList : public TWideStrings
{
	typedef TWideStrings inherited;
	
private:
	TWideStringItemList FList;
	int FCount;
	bool FSorted;
	Classes::TDuplicates FDuplicates;
	Classes::TNotifyEvent FOnChange;
	Classes::TNotifyEvent FOnChanging;
	void __fastcall ExchangeItems(int Index1, int Index2);
	void __fastcall Grow(void);
	void __fastcall QuickSort(int L, int R);
	void __fastcall InsertItem(int Index, const System::WideString S);
	void __fastcall SetSorted(bool Value);
	void __fastcall SetListString(int Index, const System::WideString S);
	
protected:
	virtual void __fastcall Changed(void);
	virtual void __fastcall Changing(void);
	virtual System::WideString __fastcall Get(int Index);
	virtual int __fastcall GetCapacity(void);
	virtual int __fastcall GetCount(void);
	virtual System::TObject* __fastcall GetObject(int Index);
	virtual void __fastcall Put(int Index, const System::WideString S);
	virtual void __fastcall PutObject(int Index, System::TObject* AObject);
	virtual void __fastcall SetCapacity(int NewCapacity);
	virtual void __fastcall SetUpdateState(bool Updating);
	virtual void __fastcall SetLanguage(unsigned Value);
	
public:
	__fastcall virtual ~TWideStringList(void);
	virtual int __fastcall Add(const System::WideString S);
	virtual void __fastcall Clear(void);
	virtual void __fastcall Delete(int Index);
	virtual void __fastcall Exchange(int Index1, int Index2);
	virtual bool __fastcall Find(const System::WideString S, int &Index);
	virtual int __fastcall IndexOf(const System::WideString S);
	virtual void __fastcall Insert(int Index, const System::WideString S);
	virtual void __fastcall Sort(void);
	__property Classes::TDuplicates Duplicates = {read=FDuplicates, write=FDuplicates, nodefault};
	__property bool Sorted = {read=FSorted, write=SetSorted, nodefault};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property Classes::TNotifyEvent OnChanging = {read=FOnChanging, write=FOnChanging};
public:
	/* TWideStrings.Create */ inline __fastcall TWideStringList(void) : TWideStrings() { }
	
};


#pragma option push -b-
enum TCaseType { ctFold, ctLower, ctTitle, ctUpper };
#pragma option pop

struct TUcNumber
{
	
public:
	int Numerator;
	int Denominator;
};


typedef int __fastcall (*TCompareFunc)(const System::WideString W1, const System::WideString W2, unsigned Locale);

class DELPHICLASS EJclUnicodeError;
class PASCALIMPLEMENTATION EJclUnicodeError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclUnicodeError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclUnicodeError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclUnicodeError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclUnicodeError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclUnicodeError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclUnicodeError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclUnicodeError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclUnicodeError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclUnicodeError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const System::WideChar WideNull = (System::WideChar)(0x0);
static const System::WideChar WideTabulator = (System::WideChar)(0x9);
static const System::WideChar WideSpace = (System::WideChar)(0x20);
static const System::WideChar WideLF = (System::WideChar)(0xa);
static const System::WideChar WideLineFeed = (System::WideChar)(0xa);
static const System::WideChar WideVerticalTab = (System::WideChar)(0xb);
static const System::WideChar WideFormFeed = (System::WideChar)(0xc);
static const System::WideChar WideCR = (System::WideChar)(0xd);
static const System::WideChar WideCarriageReturn = (System::WideChar)(0xd);
#define WideCRLF L"\r\n"
static const System::WideChar WideLineSeparator = (System::WideChar)(0x2028);
static const System::WideChar WideParagraphSeparator = (System::WideChar)(0x2029);
static const System::WideChar BOM_LSB_FIRST = (System::WideChar)(0xfeff);
static const System::WideChar BOM_MSB_FIRST = (System::WideChar)(0xfffe);
static const TSaveFormat sfUnicodeLSB = (TSaveFormat)(0);
static const TSaveFormat sfUnicodeMSB = (TSaveFormat)(1);
extern PACKAGE Jclunicode__1 UnicodeBlockData;
extern PACKAGE TCompareFunc WideCompareText;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall LoadCharacterCategories(void);
extern PACKAGE void __fastcall LoadCaseMappingData(void);
extern PACKAGE Jclbase::TUCS4Array __fastcall UnicodeCaseFold(unsigned Code);
extern PACKAGE Jclbase::TUCS4Array __fastcall UnicodeToUpper(unsigned Code);
extern PACKAGE Jclbase::TUCS4Array __fastcall UnicodeToLower(unsigned Code);
extern PACKAGE Jclbase::TUCS4Array __fastcall UnicodeToTitle(unsigned Code);
extern PACKAGE void __fastcall LoadDecompositionData(void);
extern PACKAGE void __fastcall LoadCombiningClassData(void);
extern PACKAGE void __fastcall LoadNumberData(void);
extern PACKAGE bool __fastcall UnicodeNumberLookup(unsigned Code, TUcNumber &Number);
extern PACKAGE void __fastcall LoadCompositionData(void);
extern PACKAGE int __fastcall UnicodeCompose(unsigned const *Codes, const int Codes_Size, /* out */ unsigned &Composite);
extern PACKAGE System::WideString __fastcall WideAdjustLineBreaks(const System::WideString S);
extern PACKAGE System::WideString __fastcall WideQuotedStr(const System::WideString S, System::WideChar Quote);
extern PACKAGE System::WideString __fastcall WideExtractQuotedStr(System::WideChar * &Src, System::WideChar Quote);
extern PACKAGE System::WideString __fastcall WideStringOfChar(System::WideChar C, int Count);
extern PACKAGE System::WideString __fastcall WideTrim(const System::WideString S);
extern PACKAGE System::WideString __fastcall WideTrimLeft(const System::WideString S);
extern PACKAGE System::WideString __fastcall WideTrimRight(const System::WideString S);
extern PACKAGE int __fastcall WideCharPos(const System::WideString S, const System::WideChar Ch, const int Index);
extern PACKAGE System::WideString __fastcall WideCompose(const System::WideString S);
extern PACKAGE System::WideString __fastcall WideDecompose(const System::WideString S, bool Compatible);
extern PACKAGE System::WideString __fastcall WideNormalize(const System::WideString S, TNormalizationForm Form);
extern PACKAGE bool __fastcall WideSameText(const System::WideString Str1, const System::WideString Str2);
extern PACKAGE System::WideString __fastcall WideCaseConvert(System::WideChar C, TCaseType CaseType)/* overload */;
extern PACKAGE System::WideString __fastcall WideCaseConvert(const System::WideString S, TCaseType CaseType)/* overload */;
extern PACKAGE System::WideString __fastcall WideCaseFolding(System::WideChar C)/* overload */;
extern PACKAGE System::WideString __fastcall WideCaseFolding(const System::WideString S)/* overload */;
extern PACKAGE System::WideString __fastcall WideLowerCase(System::WideChar C)/* overload */;
extern PACKAGE System::WideString __fastcall WideLowerCase(const System::WideString S)/* overload */;
extern PACKAGE System::WideString __fastcall WideTitleCase(System::WideChar C)/* overload */;
extern PACKAGE System::WideString __fastcall WideTitleCase(const System::WideString S)/* overload */;
extern PACKAGE System::WideString __fastcall WideUpperCase(System::WideChar C)/* overload */;
extern PACKAGE System::WideString __fastcall WideUpperCase(const System::WideString S)/* overload */;
extern PACKAGE bool __fastcall UnicodeIsAlpha(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsDigit(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsAlphaNum(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsNumberOther(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsCased(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsControl(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSpace(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsWhiteSpace(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsBlank(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsPunctuation(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsGraph(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsPrintable(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsUpper(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLower(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsTitle(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsHexDigit(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsIsoControl(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsFormatControl(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSymbol(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsNumber(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsNonSpacing(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOpenPunctuation(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsClosePunctuation(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsInitialPunctuation(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsFinalPunctuation(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsComposed(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsQuotationMark(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSymmetric(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsMirroring(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsNonBreaking(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsRightToLeft(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLeftToRight(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsStrong(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsWeak(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsNeutral(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSeparator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsMark(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsModifier(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLetterNumber(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsConnectionPunctuation(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsDash(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsMath(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsCurrency(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsModifierSymbol(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSpacingMark(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsEnclosing(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsPrivate(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSurrogate(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLineSeparator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsParagraphSeparator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsIdentifierStart(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsIdentifierPart(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsDefined(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsUndefined(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsHan(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsHangul(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsUnassigned(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLetterOther(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsConnector(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsPunctuationOther(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSymbolOther(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLeftToRightEmbedding(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLeftToRightOverride(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsRightToLeftArabic(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsRightToLeftEmbedding(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsRightToLeftOverride(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsPopDirectionalFormat(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsEuropeanNumber(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsEuropeanNumberSeparator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsEuropeanNumberTerminator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsArabicNumber(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsCommonNumberSeparator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsBoundaryNeutral(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSegmentSeparator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherNeutrals(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsASCIIHexDigit(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsBidiControl(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsDeprecated(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsDiacritic(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsExtender(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsHyphen(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsIdeographic(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsIDSBinaryOperator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsIDSTrinaryOperator(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsJoinControl(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsLogicalOrderException(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsNonCharacterCodePoint(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherAlphabetic(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherDefaultIgnorableCodePoint(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherGraphemeExtend(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherIDContinue(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherIDStart(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherLowercase(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherMath(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsOtherUppercase(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsPatternSyntax(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsPatternWhiteSpace(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsRadical(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSoftDotted(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsSTerm(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsTerminalPunctuation(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsUnifiedIdeograph(unsigned C);
extern PACKAGE bool __fastcall UnicodeIsVariationSelector(unsigned C);
extern PACKAGE bool __fastcall GetCharSetFromLocale(unsigned Language, /* out */ System::Byte &FontCharSet);
extern PACKAGE System::Byte __fastcall CharSetFromLocale(unsigned Language);
extern PACKAGE System::Word __fastcall CodePageFromLocale(unsigned Language);
extern PACKAGE System::Word __fastcall KeyboardCodePage(void);
extern PACKAGE System::WideChar __fastcall KeyUnicode(System::WideChar C);
extern PACKAGE TUnicodeBlockRange __fastcall CodeBlockRange(const TUnicodeBlock CB);
extern PACKAGE System::UnicodeString __fastcall CodeBlockName(const TUnicodeBlock CB);
extern PACKAGE TUnicodeBlock __fastcall CodeBlockFromChar(const unsigned C);
extern PACKAGE System::WideString __fastcall StringToWideStringEx(const System::AnsiString S, System::Word CodePage);
extern PACKAGE System::AnsiString __fastcall WideStringToStringEx(const System::WideString WS, System::Word CodePage);
extern PACKAGE System::AnsiString __fastcall TranslateString(const System::AnsiString S, System::Word CP1, System::Word CP2);
extern PACKAGE Jclbase::TUCS4Array __fastcall UCS4Array(unsigned Ch);
extern PACKAGE Jclbase::TUCS4Array __fastcall UCS4ArrayConcat(unsigned Left, unsigned Right)/* overload */;
extern PACKAGE void __fastcall UCS4ArrayConcat(Jclbase::TUCS4Array &Left, unsigned Right)/* overload */;
extern PACKAGE void __fastcall UCS4ArrayConcat(Jclbase::TUCS4Array &Left, const Jclbase::TUCS4Array Right)/* overload */;
extern PACKAGE bool __fastcall UCS4ArrayEquals(const Jclbase::TUCS4Array Left, const Jclbase::TUCS4Array Right)/* overload */;
extern PACKAGE bool __fastcall UCS4ArrayEquals(const Jclbase::TUCS4Array Left, unsigned Right)/* overload */;
extern PACKAGE bool __fastcall UCS4ArrayEquals(const Jclbase::TUCS4Array Left, const System::AnsiString Right)/* overload */;
extern PACKAGE bool __fastcall UCS4ArrayEquals(const Jclbase::TUCS4Array Left, char Right)/* overload */;

}	/* namespace Jclunicode */
using namespace Jclunicode;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclunicodeHPP
