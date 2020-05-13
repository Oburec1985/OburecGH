// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcllocales.pas' rev: 21.00

#ifndef JcllocalesHPP
#define JcllocalesHPP

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
#include <Contnrs.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclwin32.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcllocales
{
//-- type declarations -------------------------------------------------------
typedef ShortInt TJclLocalesDays;

typedef ShortInt TJclLocalesMonths;

#pragma option push -b-
enum TJclLocaleDateFormats { ldShort, ldLong, ldYearMonth };
#pragma option pop

class DELPHICLASS TJclLocaleInfo;
class PASCALIMPLEMENTATION TJclLocaleInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::UnicodeString operator[](int InfoType) { return StringInfo[InfoType]; }
	
private:
	Classes::TStringList* FCalendars;
	StaticArray<Classes::TStringList*, 3> FDateFormats;
	unsigned FLocaleID;
	Classes::TStringList* FTimeFormats;
	bool FUseSystemACP;
	bool FValidCalendars;
	Set<TJclLocaleDateFormats, ldShort, ldYearMonth>  FValidDateFormatLists;
	bool FValidTimeFormatLists;
	Classes::TStrings* __fastcall GetCalendars(void);
	int __fastcall GetCalendarIntegerInfo(unsigned Calendar, int InfoType);
	System::UnicodeString __fastcall GetCalendarStringInfo(unsigned Calendar, int InfoType);
	int __fastcall GetIntegerInfo(int InfoType);
	System::UnicodeString __fastcall GetStringInfo(int InfoType);
	System::Word __fastcall GetLangID(void);
	System::Word __fastcall GetSortID(void);
	System::Word __fastcall GetLangIDPrimary(void);
	System::Word __fastcall GetLangIDSub(void);
	System::UnicodeString __fastcall GetLongMonthNames(TJclLocalesMonths Month);
	System::UnicodeString __fastcall GetAbbreviatedMonthNames(TJclLocalesMonths Month);
	System::UnicodeString __fastcall GetLongDayNames(TJclLocalesDays Day);
	System::UnicodeString __fastcall GetAbbreviatedDayNames(TJclLocalesDays Day);
	System::WideChar __fastcall GetCharInfo(int InfoType);
	Classes::TStrings* __fastcall GetTimeFormats(void);
	Classes::TStrings* __fastcall GetDateFormats(TJclLocaleDateFormats Format);
	System::Byte __fastcall GetFontCharset(void);
	int __fastcall GetCalTwoDigitYearMax(unsigned Calendar);
	void __fastcall SetUseSystemACP(const bool Value);
	void __fastcall SetCharInfo(int InfoType, const System::WideChar Value);
	void __fastcall SetIntegerInfo(int InfoType, const int Value);
	void __fastcall SetStringInfo(int InfoType, const System::UnicodeString Value);
	
public:
	__fastcall TJclLocaleInfo(unsigned ALocaleID);
	__fastcall virtual ~TJclLocaleInfo(void);
	__property System::WideChar CharInfo[int InfoType] = {read=GetCharInfo, write=SetCharInfo};
	__property int IntegerInfo[int InfoType] = {read=GetIntegerInfo, write=SetIntegerInfo};
	__property System::UnicodeString StringInfo[int InfoType] = {read=GetStringInfo, write=SetStringInfo/*, default*/};
	__property bool UseSystemACP = {read=FUseSystemACP, write=SetUseSystemACP, nodefault};
	__property System::Byte FontCharset = {read=GetFontCharset, nodefault};
	__property System::Word LangID = {read=GetLangID, nodefault};
	__property unsigned LocaleID = {read=FLocaleID, nodefault};
	__property System::Word LangIDPrimary = {read=GetLangIDPrimary, nodefault};
	__property System::Word LangIDSub = {read=GetLangIDSub, nodefault};
	__property System::Word SortID = {read=GetSortID, nodefault};
	__property Classes::TStrings* DateFormats[TJclLocaleDateFormats Format] = {read=GetDateFormats};
	__property Classes::TStrings* TimeFormats = {read=GetTimeFormats};
	__property System::UnicodeString LanguageIndentifier = {read=GetStringInfo, index=1};
	__property System::UnicodeString LocalizedLangName = {read=GetStringInfo, index=2};
	__property System::UnicodeString EnglishLangName = {read=GetStringInfo, index=4097};
	__property System::UnicodeString AbbreviatedLangName = {read=GetStringInfo, index=3};
	__property System::UnicodeString NativeLangName = {read=GetStringInfo, index=4};
	__property System::UnicodeString ISOAbbreviatedLangName = {read=GetStringInfo, index=89};
	__property int CountryCode = {read=GetIntegerInfo, index=5, nodefault};
	__property System::UnicodeString LocalizedCountryName = {read=GetStringInfo, index=6};
	__property System::UnicodeString EnglishCountryName = {read=GetStringInfo, index=4098};
	__property System::UnicodeString AbbreviatedCountryName = {read=GetStringInfo, index=7};
	__property System::UnicodeString NativeCountryName = {read=GetStringInfo, index=8};
	__property System::UnicodeString ISOAbbreviatedCountryName = {read=GetStringInfo, index=90};
	__property int DefaultLanguageId = {read=GetIntegerInfo, index=9, nodefault};
	__property int DefaultCountryCode = {read=GetIntegerInfo, index=10, nodefault};
	__property int DefaultCodePageEBCDIC = {read=GetIntegerInfo, index=4114, nodefault};
	__property int CodePageOEM = {read=GetIntegerInfo, index=11, nodefault};
	__property int CodePageANSI = {read=GetIntegerInfo, index=4100, nodefault};
	__property int CodePageMAC = {read=GetIntegerInfo, index=4113, nodefault};
	__property System::WideChar ListItemSeparator = {read=GetCharInfo, write=SetCharInfo, index=12, nodefault};
	__property int Measure = {read=GetIntegerInfo, write=SetIntegerInfo, index=13, nodefault};
	__property System::WideChar DecimalSeparator = {read=GetCharInfo, write=SetCharInfo, index=14, nodefault};
	__property System::WideChar ThousandSeparator = {read=GetCharInfo, write=SetCharInfo, index=15, nodefault};
	__property System::UnicodeString DigitGrouping = {read=GetStringInfo, write=SetStringInfo, index=16};
	__property int NumberOfFractionalDigits = {read=GetIntegerInfo, write=SetIntegerInfo, index=17, nodefault};
	__property int LeadingZeros = {read=GetIntegerInfo, write=SetIntegerInfo, index=18, nodefault};
	__property int NegativeNumberMode = {read=GetIntegerInfo, write=SetIntegerInfo, index=4112, nodefault};
	__property System::UnicodeString NativeDigits = {read=GetStringInfo, index=19};
	__property int DigitSubstitution = {read=GetIntegerInfo, index=4116, nodefault};
	__property System::UnicodeString MonetarySymbolLocal = {read=GetStringInfo, write=SetStringInfo, index=20};
	__property System::UnicodeString MonetarySymbolIntl = {read=GetStringInfo, index=21};
	__property System::WideChar MonetaryDecimalSeparator = {read=GetCharInfo, write=SetCharInfo, index=22, nodefault};
	__property System::WideChar MonetaryThousandsSeparator = {read=GetCharInfo, write=SetCharInfo, index=23, nodefault};
	__property System::UnicodeString MonetaryGrouping = {read=GetStringInfo, write=SetStringInfo, index=24};
	__property int NumberOfLocalMonetaryDigits = {read=GetIntegerInfo, write=SetIntegerInfo, index=25, nodefault};
	__property int NumberOfIntlMonetaryDigits = {read=GetIntegerInfo, index=26, nodefault};
	__property System::UnicodeString PositiveCurrencyMode = {read=GetStringInfo, write=SetStringInfo, index=27};
	__property System::UnicodeString NegativeCurrencyMode = {read=GetStringInfo, write=SetStringInfo, index=28};
	__property System::UnicodeString EnglishCurrencyName = {read=GetStringInfo, index=4103};
	__property System::UnicodeString NativeCurrencyName = {read=GetStringInfo, index=4104};
	__property System::WideChar DateSeparator = {read=GetCharInfo, write=SetCharInfo, index=29, nodefault};
	__property System::WideChar TimeSeparator = {read=GetCharInfo, write=SetCharInfo, index=30, nodefault};
	__property System::UnicodeString ShortDateFormat = {read=GetStringInfo, write=SetStringInfo, index=31};
	__property System::UnicodeString LongDateFormat = {read=GetStringInfo, write=SetStringInfo, index=32};
	__property System::UnicodeString TimeFormatString = {read=GetStringInfo, write=SetStringInfo, index=4099};
	__property int ShortDateOrdering = {read=GetIntegerInfo, index=33, nodefault};
	__property int LongDateOrdering = {read=GetIntegerInfo, index=34, nodefault};
	__property int TimeFormatSpecifier = {read=GetIntegerInfo, write=SetIntegerInfo, index=35, nodefault};
	__property int TimeMarkerPosition = {read=GetIntegerInfo, index=4101, nodefault};
	__property int CenturyFormatSpecifier = {read=GetIntegerInfo, index=36, nodefault};
	__property int LeadZerosInTime = {read=GetIntegerInfo, index=37, nodefault};
	__property int LeadZerosInDay = {read=GetIntegerInfo, index=38, nodefault};
	__property int LeadZerosInMonth = {read=GetIntegerInfo, index=39, nodefault};
	__property System::UnicodeString AMDesignator = {read=GetStringInfo, write=SetStringInfo, index=40};
	__property System::UnicodeString PMDesignator = {read=GetStringInfo, write=SetStringInfo, index=41};
	__property System::UnicodeString YearMonthFormat = {read=GetStringInfo, write=SetStringInfo, index=4102};
	__property int CalendarType = {read=GetIntegerInfo, write=SetIntegerInfo, index=4105, nodefault};
	__property int AdditionalCaledarTypes = {read=GetIntegerInfo, index=4107, nodefault};
	__property int FirstDayOfWeek = {read=GetIntegerInfo, write=SetIntegerInfo, index=4108, nodefault};
	__property int FirstWeekOfYear = {read=GetIntegerInfo, write=SetIntegerInfo, index=4109, nodefault};
	__property System::UnicodeString LongDayNames[TJclLocalesDays Day] = {read=GetLongDayNames};
	__property System::UnicodeString AbbreviatedDayNames[TJclLocalesDays Day] = {read=GetAbbreviatedDayNames};
	__property System::UnicodeString LongMonthNames[TJclLocalesMonths Month] = {read=GetLongMonthNames};
	__property System::UnicodeString AbbreviatedMonthNames[TJclLocalesMonths Month] = {read=GetAbbreviatedMonthNames};
	__property System::UnicodeString PositiveSign = {read=GetStringInfo, write=SetStringInfo, index=80};
	__property System::UnicodeString NegativeSign = {read=GetStringInfo, write=SetStringInfo, index=81};
	__property int PositiveSignPos = {read=GetIntegerInfo, index=82, nodefault};
	__property int NegativeSignPos = {read=GetIntegerInfo, index=83, nodefault};
	__property int PosOfPositiveMonetarySymbol = {read=GetIntegerInfo, index=84, nodefault};
	__property int SepOfPositiveMonetarySymbol = {read=GetIntegerInfo, index=85, nodefault};
	__property int PosOfNegativeMonetarySymbol = {read=GetIntegerInfo, index=86, nodefault};
	__property int SepOfNegativeMonetarySymbol = {read=GetIntegerInfo, index=87, nodefault};
	__property int DefaultPaperSize = {read=GetIntegerInfo, index=4106, nodefault};
	__property System::UnicodeString FontSignature = {read=GetStringInfo, index=88};
	__property System::UnicodeString LocalizedSortName = {read=GetStringInfo, index=4115};
	__property Classes::TStrings* Calendars = {read=GetCalendars};
	__property int CalendarIntegerInfo[unsigned Calendar][int InfoType] = {read=GetCalendarIntegerInfo};
	__property System::UnicodeString CalendarStringInfo[unsigned Calendar][int InfoType] = {read=GetCalendarStringInfo};
	__property int CalTwoDigitYearMax[unsigned Calendar] = {read=GetCalTwoDigitYearMax};
};


#pragma option push -b-
enum TJclLocalesKind { lkInstalled, lkSupported };
#pragma option pop

class DELPHICLASS TJclLocalesList;
class PASCALIMPLEMENTATION TJclLocalesList : public Contnrs::TObjectList
{
	typedef Contnrs::TObjectList inherited;
	
public:
	TJclLocaleInfo* operator[](int Index) { return Items[Index]; }
	
private:
	Classes::TStringList* FCodePages;
	TJclLocalesKind FKind;
	TJclLocaleInfo* __fastcall GetItemFromLangID(System::Word LangID);
	TJclLocaleInfo* __fastcall GetItemFromLangIDPrimary(System::Word LangIDPrimary);
	TJclLocaleInfo* __fastcall GetItemFromLocaleID(unsigned LocaleID);
	TJclLocaleInfo* __fastcall GetItems(int Index);
	Classes::TStrings* __fastcall GetCodePages(void);
	
protected:
	void __fastcall CreateList(void);
	
public:
	__fastcall TJclLocalesList(TJclLocalesKind AKind);
	__fastcall virtual ~TJclLocalesList(void);
	void __fastcall FillStrings(Classes::TStrings* AStrings, int InfoType);
	__property Classes::TStrings* CodePages = {read=GetCodePages};
	__property TJclLocaleInfo* ItemFromLangID[System::Word LangID] = {read=GetItemFromLangID};
	__property TJclLocaleInfo* ItemFromLangIDPrimary[System::Word LangIDPrimary] = {read=GetItemFromLangIDPrimary};
	__property TJclLocaleInfo* ItemFromLocaleID[unsigned LocaleID] = {read=GetItemFromLocaleID};
	__property TJclLocaleInfo* Items[int Index] = {read=GetItems/*, default*/};
	__property TJclLocalesKind Kind = {read=FKind, nodefault};
};


#pragma option push -b-
enum TJclKeybLayoutFlag { klReorder, klUnloadPrevious, klSetForProcess, klActivate, klNotEllShell, klReplaceLang, klSubstituteOK };
#pragma option pop

typedef Set<TJclKeybLayoutFlag, klReorder, klSubstituteOK>  TJclKeybLayoutFlags;

class DELPHICLASS TJclAvailableKeybLayout;
class DELPHICLASS TJclKeyboardLayoutList;
class PASCALIMPLEMENTATION TJclAvailableKeybLayout : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	unsigned FIdentifier;
	System::Word FLayoutID;
	System::UnicodeString FLayoutFile;
	TJclKeyboardLayoutList* FOwner;
	System::UnicodeString FName;
	System::UnicodeString __fastcall GetIdentifierName(void);
	bool __fastcall GetLayoutFileExists(void);
	
public:
	bool __fastcall Load(const TJclKeybLayoutFlags LoadFlags);
	__property unsigned Identifier = {read=FIdentifier, nodefault};
	__property System::UnicodeString IdentifierName = {read=GetIdentifierName};
	__property System::Word LayoutID = {read=FLayoutID, nodefault};
	__property System::UnicodeString LayoutFile = {read=FLayoutFile};
	__property bool LayoutFileExists = {read=GetLayoutFileExists, nodefault};
	__property System::UnicodeString Name = {read=FName};
public:
	/* TObject.Create */ inline __fastcall TJclAvailableKeybLayout(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAvailableKeybLayout(void) { }
	
};


class DELPHICLASS TJclKeyboardLayout;
class PASCALIMPLEMENTATION TJclKeyboardLayout : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	HKL FLayout;
	TJclLocaleInfo* FLocaleInfo;
	TJclKeyboardLayoutList* FOwner;
	System::Word __fastcall GetDeviceHandle(void);
	System::UnicodeString __fastcall GetDisplayName(void);
	System::Word __fastcall GetLocaleID(void);
	TJclLocaleInfo* __fastcall GetLocaleInfo(void);
	System::UnicodeString __fastcall GetVariationName(void);
	
public:
	__fastcall TJclKeyboardLayout(TJclKeyboardLayoutList* AOwner, HKL ALayout);
	__fastcall virtual ~TJclKeyboardLayout(void);
	bool __fastcall Activate(TJclKeybLayoutFlags ActivateFlags = TJclKeybLayoutFlags() );
	bool __fastcall Unload(void);
	__property System::Word DeviceHandle = {read=GetDeviceHandle, nodefault};
	__property System::UnicodeString DisplayName = {read=GetDisplayName};
	__property HKL Layout = {read=FLayout, nodefault};
	__property System::Word LocaleID = {read=GetLocaleID, nodefault};
	__property TJclLocaleInfo* LocaleInfo = {read=GetLocaleInfo};
	__property System::UnicodeString VariationName = {read=GetVariationName};
};


class PASCALIMPLEMENTATION TJclKeyboardLayoutList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclKeyboardLayout* operator[](int Index) { return Items[Index]; }
	
private:
	Contnrs::TObjectList* FAvailableLayouts;
	Contnrs::TObjectList* FList;
	Classes::TNotifyEvent FOnRefresh;
	int __fastcall GetCount(void);
	TJclKeyboardLayout* __fastcall GetItems(int Index);
	TJclKeyboardLayout* __fastcall GetActiveLayout(void);
	TJclKeyboardLayout* __fastcall GetItemFromHKL(HKL Layout);
	TJclKeyboardLayout* __fastcall GetLayoutFromLocaleID(System::Word LocaleID);
	int __fastcall GetAvailableLayoutCount(void);
	TJclAvailableKeybLayout* __fastcall GetAvailableLayouts(int Index);
	
protected:
	void __fastcall CreateAvailableLayouts(void);
	DYNAMIC void __fastcall DoRefresh(void);
	
public:
	__fastcall TJclKeyboardLayoutList(void);
	__fastcall virtual ~TJclKeyboardLayoutList(void);
	bool __fastcall ActivatePrevLayout(TJclKeybLayoutFlags ActivateFlags = TJclKeybLayoutFlags() );
	bool __fastcall ActivateNextLayout(TJclKeybLayoutFlags ActivateFlags = TJclKeybLayoutFlags() );
	bool __fastcall LoadLayout(const System::UnicodeString LayoutName, TJclKeybLayoutFlags LoadFlags);
	void __fastcall Refresh(void);
	__property TJclKeyboardLayout* ActiveLayout = {read=GetActiveLayout};
	__property TJclAvailableKeybLayout* AvailableLayouts[int Index] = {read=GetAvailableLayouts};
	__property int AvailableLayoutCount = {read=GetAvailableLayoutCount, nodefault};
	__property int Count = {read=GetCount, nodefault};
	__property TJclKeyboardLayout* ItemFromHKL[HKL Layout] = {read=GetItemFromHKL};
	__property TJclKeyboardLayout* Items[int Index] = {read=GetItems/*, default*/};
	__property TJclKeyboardLayout* LayoutFromLocaleID[System::Word LocaleID] = {read=GetLayoutFromLocaleID};
	__property Classes::TNotifyEvent OnRefresh = {read=FOnRefresh, write=FOnRefresh};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall JclLocalesInfoList(const Classes::TStrings* Strings, int InfoType = 0x1002);

}	/* namespace Jcllocales */
using namespace Jcllocales;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcllocalesHPP
