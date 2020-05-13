// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclstringlists.pas' rev: 21.00

#ifndef JclstringlistsHPP
#define JclstringlistsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclpcre.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclstringlists
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclStringListError;
class PASCALIMPLEMENTATION EJclStringListError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclStringListError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclStringListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclStringListError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclStringListError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclStringListError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclStringListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclStringListError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclStringListError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclStringListError(void) { }
	
};


#pragma option push -b-
enum TJclStringListObjectsMode { omNone, omObjects, omVariants, omInterfaces };
#pragma option pop

__interface IJclStringList;
typedef System::DelphiInterface<IJclStringList> _di_IJclStringList;
typedef int __fastcall (*TJclStringListSortCompare)(_di_IJclStringList List, int Index1, int Index2);

__interface  INTERFACE_UUID("{8DC5B71C-4756-404D-8636-7872CD299796}") IJclStringList  : public System::IInterface 
{
	
public:
	System::UnicodeString operator[](int Index) { return Strings[Index]; }
	
public:
	virtual int __fastcall Add(const System::UnicodeString S) = 0 /* overload */;
	virtual int __fastcall AddObject(const System::UnicodeString S, System::TObject* AObject) = 0 ;
	virtual System::UnicodeString __fastcall Get(int Index) = 0 ;
	virtual int __fastcall GetCapacity(void) = 0 ;
	virtual int __fastcall GetCount(void) = 0 ;
	virtual System::TObject* __fastcall GetObjects(int Index) = 0 ;
	virtual System::UnicodeString __fastcall GetTextStr(void) = 0 ;
	virtual System::UnicodeString __fastcall GetValue(const System::UnicodeString Name) = 0 ;
	virtual bool __fastcall Find(const System::UnicodeString S, int &Index) = 0 ;
	virtual int __fastcall IndexOf(const System::UnicodeString S) = 0 ;
	virtual bool __fastcall GetCaseSensitive(void) = 0 ;
	virtual Classes::TDuplicates __fastcall GetDuplicates(void) = 0 ;
	virtual Classes::TNotifyEvent __fastcall GetOnChange(void) = 0 ;
	virtual Classes::TNotifyEvent __fastcall GetOnChanging(void) = 0 ;
	virtual bool __fastcall GetSorted(void) = 0 ;
	virtual bool __fastcall Equals(Classes::TStrings* Strings) = 0 ;
	virtual int __fastcall IndexOfName(const System::UnicodeString Name) = 0 ;
	virtual int __fastcall IndexOfObject(System::TObject* AObject) = 0 ;
	virtual _di_IJclStringList __fastcall LoadFromFile(const System::UnicodeString FileName) = 0 ;
	virtual _di_IJclStringList __fastcall LoadFromStream(Classes::TStream* Stream) = 0 ;
	virtual _di_IJclStringList __fastcall SaveToFile(const System::UnicodeString FileName) = 0 ;
	virtual _di_IJclStringList __fastcall SaveToStream(Classes::TStream* Stream) = 0 ;
	virtual System::UnicodeString __fastcall GetCommaText(void) = 0 ;
	virtual System::UnicodeString __fastcall GetDelimitedText(void) = 0 ;
	virtual System::WideChar __fastcall GetDelimiter(void) = 0 ;
	virtual System::UnicodeString __fastcall GetName(int Index) = 0 ;
	virtual System::WideChar __fastcall GetNameValueSeparator(void) = 0 ;
	virtual System::UnicodeString __fastcall GetValueFromIndex(int Index) = 0 ;
	virtual System::WideChar __fastcall GetQuoteChar(void) = 0 ;
	virtual void __fastcall SetCommaText(const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetDelimitedText(const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetDelimiter(const System::WideChar Value) = 0 ;
	virtual void __fastcall SetNameValueSeparator(const System::WideChar Value) = 0 ;
	virtual void __fastcall SetValueFromIndex(int Index, const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetQuoteChar(const System::WideChar Value) = 0 ;
	virtual void __fastcall AddStrings(Classes::TStrings* Strings) = 0 /* overload */;
	virtual void __fastcall SetObjects(int Index, const System::TObject* Value) = 0 ;
	virtual void __fastcall Put(int Index, const System::UnicodeString S) = 0 ;
	virtual void __fastcall SetCapacity(int NewCapacity) = 0 ;
	virtual void __fastcall SetTextStr(const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetValue(const System::UnicodeString Name, const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetCaseSensitive(const bool Value) = 0 ;
	virtual void __fastcall SetDuplicates(const Classes::TDuplicates Value) = 0 ;
	virtual void __fastcall SetOnChange(const Classes::TNotifyEvent Value) = 0 ;
	virtual void __fastcall SetOnChanging(const Classes::TNotifyEvent Value) = 0 ;
	virtual void __fastcall SetSorted(const bool Value) = 0 ;
	__property int Count = {read=GetCount};
	__property System::UnicodeString Strings[int Index] = {read=Get, write=Put/*, default*/};
	__property System::UnicodeString Text = {read=GetTextStr, write=SetTextStr};
	__property System::TObject* Objects[int Index] = {read=GetObjects, write=SetObjects};
	__property int Capacity = {read=GetCapacity, write=SetCapacity};
	__property System::UnicodeString Values[const System::UnicodeString Name] = {read=GetValue, write=SetValue};
	__property Classes::TDuplicates Duplicates = {read=GetDuplicates, write=SetDuplicates};
	__property bool Sorted = {read=GetSorted, write=SetSorted};
	__property bool CaseSensitive = {read=GetCaseSensitive, write=SetCaseSensitive};
	__property Classes::TNotifyEvent OnChange = {read=GetOnChange, write=SetOnChange};
	__property Classes::TNotifyEvent OnChanging = {read=GetOnChanging, write=SetOnChanging};
	__property System::UnicodeString DelimitedText = {read=GetDelimitedText, write=SetDelimitedText};
	__property System::WideChar Delimiter = {read=GetDelimiter, write=SetDelimiter};
	__property System::UnicodeString Names[int Index] = {read=GetName};
	__property System::WideChar QuoteChar = {read=GetQuoteChar, write=SetQuoteChar};
	__property System::UnicodeString CommaText = {read=GetCommaText, write=SetCommaText};
	__property System::UnicodeString ValueFromIndex[int Index] = {read=GetValueFromIndex, write=SetValueFromIndex};
	__property System::WideChar NameValueSeparator = {read=GetNameValueSeparator, write=SetNameValueSeparator};
	virtual _di_IJclStringList __fastcall Assign(Classes::TPersistent* Source) = 0 ;
	virtual _di_IJclStringList __fastcall LoadExeParams(void) = 0 ;
	virtual bool __fastcall Exists(const System::UnicodeString S) = 0 ;
	virtual bool __fastcall ExistsName(const System::UnicodeString S) = 0 ;
	virtual _di_IJclStringList __fastcall DeleteBlanks(void) = 0 ;
	virtual _di_IJclStringList __fastcall KeepIntegers(void) = 0 ;
	virtual _di_IJclStringList __fastcall DeleteIntegers(void) = 0 ;
	virtual _di_IJclStringList __fastcall ReleaseInterfaces(void) = 0 ;
	virtual _di_IJclStringList __fastcall FreeObjects(bool AFreeAndNil = false) = 0 ;
	virtual _di_IJclStringList __fastcall Clone(void) = 0 ;
	virtual _di_IJclStringList __fastcall Insert(int Index, const System::UnicodeString S) = 0 ;
	virtual _di_IJclStringList __fastcall InsertObject(int Index, const System::UnicodeString S, System::TObject* AObject) = 0 ;
	virtual _di_IJclStringList __fastcall Sort(TJclStringListSortCompare ACompareFunction = 0x0) = 0 ;
	virtual _di_IJclStringList __fastcall SortAsInteger(void) = 0 ;
	virtual _di_IJclStringList __fastcall SortByName(void) = 0 ;
	virtual _di_IJclStringList __fastcall Delete(int AIndex) = 0 /* overload */;
	virtual _di_IJclStringList __fastcall Delete(const System::UnicodeString AString) = 0 /* overload */;
	virtual _di_IJclStringList __fastcall Exchange(int Index1, int Index2) = 0 ;
	virtual _di_IJclStringList __fastcall Add(System::TVarRec const *A, const int A_Size) = 0 /* overload */;
	virtual _di_IJclStringList __fastcall AddStrings(System::UnicodeString const *A, const int A_Size) = 0 /* overload */;
	virtual _di_IJclStringList __fastcall BeginUpdate(void) = 0 ;
	virtual _di_IJclStringList __fastcall EndUpdate(void) = 0 ;
	virtual _di_IJclStringList __fastcall Trim(void) = 0 ;
	virtual System::UnicodeString __fastcall Join(const System::UnicodeString ASeparator = L"") = 0 ;
	virtual _di_IJclStringList __fastcall Split(const System::UnicodeString AText, const System::UnicodeString ASeparator, bool AClearBeforeAdd = true) = 0 ;
	virtual _di_IJclStringList __fastcall ExtractWords(const System::UnicodeString AText, const Jclbase::TSetOfAnsiChar &ADelims = (Jclbase::TSetOfAnsiChar() << '\x0' << '\x1' << '\x2' << '\x3' << '\x4' << '\x5' << '\x6' << '\x7' << '\x8' << '\x9' << '\xa' << '\xb' << '\xc' << '\xd' << '\xe' << '\xf' << '\x10' << '\x11' << '\x12' << '\x13' << '\x14' << '\x15' << '\x16' << '\x17' << '\x18' << '\x19' << '\x1a' << '\x1b' << '\x1c' << '\x1d' << '\x1e' << '\x1f' << '\x20' ), bool AClearBeforeAdd = true) = 0 ;
	virtual System::UnicodeString __fastcall Last(void) = 0 ;
	virtual System::UnicodeString __fastcall First(void) = 0 ;
	virtual int __fastcall LastIndex(void) = 0 ;
	virtual _di_IJclStringList __fastcall Clear(void) = 0 ;
	virtual _di_IJclStringList __fastcall DeleteRegEx(const System::UnicodeString APattern) = 0 ;
	virtual _di_IJclStringList __fastcall KeepRegEx(const System::UnicodeString APattern) = 0 ;
	virtual _di_IJclStringList __fastcall Files(const System::UnicodeString APattern = L"*", bool ARecursive = false, const System::UnicodeString ARegExPattern = L"") = 0 ;
	virtual _di_IJclStringList __fastcall Directories(const System::UnicodeString APattern = L"*", bool ARecursive = false, const System::UnicodeString ARegExPattern = L"") = 0 ;
	virtual Classes::TStrings* __fastcall GetStringsRef(void) = 0 ;
	virtual _di_IJclStringList __fastcall ConfigAsSet(void) = 0 ;
	virtual _di_IJclStringList __fastcall Delimit(const System::UnicodeString ADelimiter) = 0 ;
	virtual System::_di_IInterface __fastcall GetInterfaceByIndex(int Index) = 0 ;
	virtual _di_IJclStringList __fastcall GetLists(int Index) = 0 ;
	virtual System::Variant __fastcall GetVariants(int AIndex) = 0 ;
	virtual System::_di_IInterface __fastcall GetKeyInterface(const System::UnicodeString AKey) = 0 ;
	virtual System::TObject* __fastcall GetKeyObject(const System::UnicodeString AKey) = 0 ;
	virtual System::Variant __fastcall GetKeyVariant(const System::UnicodeString AKey) = 0 ;
	virtual _di_IJclStringList __fastcall GetKeyList(const System::UnicodeString AKey) = 0 ;
	virtual TJclStringListObjectsMode __fastcall GetObjectsMode(void) = 0 ;
	virtual void __fastcall SetInterfaceByIndex(int Index, const System::_di_IInterface Value) = 0 ;
	virtual void __fastcall SetLists(int Index, const _di_IJclStringList Value) = 0 ;
	virtual void __fastcall SetVariants(int Index, const System::Variant &Value) = 0 ;
	virtual void __fastcall SetKeyInterface(const System::UnicodeString AKey, const System::_di_IInterface Value) = 0 ;
	virtual void __fastcall SetKeyObject(const System::UnicodeString AKey, const System::TObject* Value) = 0 ;
	virtual void __fastcall SetKeyVariant(const System::UnicodeString AKey, const System::Variant &Value) = 0 ;
	virtual void __fastcall SetKeyList(const System::UnicodeString AKey, const _di_IJclStringList Value) = 0 ;
	__property System::_di_IInterface Interfaces[int Index] = {read=GetInterfaceByIndex, write=SetInterfaceByIndex};
	__property _di_IJclStringList Lists[int Index] = {read=GetLists, write=SetLists};
	__property System::Variant Variants[int Index] = {read=GetVariants, write=SetVariants};
	__property _di_IJclStringList KeyList[const System::UnicodeString AKey] = {read=GetKeyList, write=SetKeyList};
	__property System::TObject* KeyObject[const System::UnicodeString AKey] = {read=GetKeyObject, write=SetKeyObject};
	__property System::_di_IInterface KeyInterface[const System::UnicodeString AKey] = {read=GetKeyInterface, write=SetKeyInterface};
	__property System::Variant KeyVariant[const System::UnicodeString AKey] = {read=GetKeyVariant, write=SetKeyVariant};
	__property TJclStringListObjectsMode ObjectsMode = {read=GetObjectsMode};
};

class DELPHICLASS TJclUpdateControl;
class PASCALIMPLEMENTATION TJclUpdateControl : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TStrings* FStrings;
	
public:
	__fastcall TJclUpdateControl(Classes::TStrings* AStrings);
	HRESULT __stdcall QueryInterface(const GUID &IID, /* out */ void *Obj);
	int __stdcall _AddRef(void);
	int __stdcall _Release(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclUpdateControl(void) { }
	
private:
	void *__IInterface;	/* System::IInterface */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::_di_IInterface()
	{
		System::_di_IInterface intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IInterface*(void) { return (IInterface*)&__IInterface; }
	#endif
	
};


class DELPHICLASS TJclStringList;
class PASCALIMPLEMENTATION TJclStringList : public Classes::TStringList
{
	typedef Classes::TStringList inherited;
	
public:
	System::UnicodeString operator[](int Index) { return Strings[Index]; }
	
private:
	TJclStringListObjectsMode FObjectsMode;
	_di_IJclStringList FSelfAsInterface;
	System::UnicodeString FLastRegExPattern;
	Jclpcre::TJclRegEx* FRegEx;
	TJclUpdateControl* FUpdateControl;
	TJclStringListSortCompare FCompareFunction;
	System::_di_IInterface __fastcall AutoUpdateControl(void);
	bool __fastcall CanFreeObjects(void);
	bool __fastcall MatchRegEx(const System::UnicodeString S, const System::UnicodeString APattern);
	void __fastcall EnsureObjectsMode(TJclStringListObjectsMode AMode);
	
protected:
	int FRefCount;
	
public:
	__fastcall TJclStringList(void);
	__fastcall virtual ~TJclStringList(void);
	HRESULT __stdcall QueryInterface(const GUID &IID, /* out */ void *Obj);
	int __stdcall _AddRef(void);
	int __stdcall _Release(void);
	System::TObject* __fastcall GetObjects(int Index);
	HIDESBASE System::UnicodeString __fastcall GetValue(const System::UnicodeString Name);
	bool __fastcall GetCaseSensitive(void);
	Classes::TDuplicates __fastcall GetDuplicates(void);
	Classes::TNotifyEvent __fastcall GetOnChange(void);
	Classes::TNotifyEvent __fastcall GetOnChanging(void);
	bool __fastcall GetSorted(void);
	HIDESBASE _di_IJclStringList __fastcall LoadFromFile(const System::UnicodeString FileName);
	HIDESBASE _di_IJclStringList __fastcall LoadFromStream(Classes::TStream* Stream);
	HIDESBASE _di_IJclStringList __fastcall SaveToFile(const System::UnicodeString FileName);
	HIDESBASE _di_IJclStringList __fastcall SaveToStream(Classes::TStream* Stream);
	HIDESBASE System::UnicodeString __fastcall GetCommaText(void);
	HIDESBASE System::UnicodeString __fastcall GetDelimitedText(void);
	HIDESBASE System::WideChar __fastcall GetDelimiter(void);
	HIDESBASE System::UnicodeString __fastcall GetName(int Index);
	HIDESBASE System::WideChar __fastcall GetNameValueSeparator(void);
	HIDESBASE System::UnicodeString __fastcall GetValueFromIndex(int Index);
	HIDESBASE System::WideChar __fastcall GetQuoteChar(void);
	HIDESBASE void __fastcall SetCommaText(const System::UnicodeString Value);
	HIDESBASE void __fastcall SetDelimitedText(const System::UnicodeString Value);
	HIDESBASE void __fastcall SetDelimiter(const System::WideChar Value);
	HIDESBASE void __fastcall SetNameValueSeparator(const System::WideChar Value);
	HIDESBASE void __fastcall SetValueFromIndex(int Index, const System::UnicodeString Value);
	HIDESBASE void __fastcall SetQuoteChar(const System::WideChar Value);
	void __fastcall SetObjects(int Index, const System::TObject* Value);
	HIDESBASE void __fastcall SetValue(const System::UnicodeString Name, const System::UnicodeString Value);
	HIDESBASE void __fastcall SetCaseSensitive(const bool Value);
	void __fastcall SetDuplicates(const Classes::TDuplicates Value);
	void __fastcall SetOnChange(const Classes::TNotifyEvent Value);
	void __fastcall SetOnChanging(const Classes::TNotifyEvent Value);
	HIDESBASE void __fastcall SetSorted(const bool Value);
	__property int Count = {read=GetCount, nodefault};
	__property System::UnicodeString Strings[int Index] = {read=Get, write=Put/*, default*/};
	__property System::UnicodeString Text = {read=GetTextStr, write=SetTextStr};
	__property System::TObject* Objects[int Index] = {read=GetObjects, write=SetObjects};
	__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
	__property System::UnicodeString Values[const System::UnicodeString Name] = {read=GetValue, write=SetValue};
	__property Classes::TDuplicates Duplicates = {read=GetDuplicates, write=SetDuplicates, nodefault};
	__property bool Sorted = {read=GetSorted, write=SetSorted, nodefault};
	__property bool CaseSensitive = {read=GetCaseSensitive, write=SetCaseSensitive, nodefault};
	__property Classes::TNotifyEvent OnChange = {read=GetOnChange, write=SetOnChange};
	__property Classes::TNotifyEvent OnChanging = {read=GetOnChanging, write=SetOnChanging};
	__property System::UnicodeString DelimitedText = {read=GetDelimitedText, write=SetDelimitedText};
	__property System::WideChar Delimiter = {read=GetDelimiter, write=SetDelimiter, nodefault};
	__property System::UnicodeString Names[int Index] = {read=GetName};
	__property System::WideChar QuoteChar = {read=GetQuoteChar, write=SetQuoteChar, nodefault};
	__property System::UnicodeString CommaText = {read=GetCommaText, write=SetCommaText};
	__property System::UnicodeString ValueFromIndex[int Index] = {read=GetValueFromIndex, write=SetValueFromIndex};
	__property System::WideChar NameValueSeparator = {read=GetNameValueSeparator, write=SetNameValueSeparator, nodefault};
	HIDESBASE _di_IJclStringList __fastcall Assign(Classes::TPersistent* Source);
	_di_IJclStringList __fastcall LoadExeParams(void);
	bool __fastcall Exists(const System::UnicodeString S);
	bool __fastcall ExistsName(const System::UnicodeString S);
	_di_IJclStringList __fastcall DeleteBlanks(void);
	_di_IJclStringList __fastcall KeepIntegers(void);
	_di_IJclStringList __fastcall DeleteIntegers(void);
	_di_IJclStringList __fastcall ReleaseInterfaces(void);
	_di_IJclStringList __fastcall FreeObjects(bool AFreeAndNil = false);
	_di_IJclStringList __fastcall Clone(void);
	HIDESBASE _di_IJclStringList __fastcall Insert(int Index, const System::UnicodeString S);
	HIDESBASE _di_IJclStringList __fastcall InsertObject(int Index, const System::UnicodeString S, System::TObject* AObject);
	HIDESBASE _di_IJclStringList __fastcall Sort(TJclStringListSortCompare ACompareFunction = 0x0);
	_di_IJclStringList __fastcall SortAsInteger(void);
	_di_IJclStringList __fastcall SortByName(void);
	HIDESBASE _di_IJclStringList __fastcall Delete(int AIndex)/* overload */;
	HIDESBASE _di_IJclStringList __fastcall Delete(const System::UnicodeString AString)/* overload */;
	HIDESBASE _di_IJclStringList __fastcall Exchange(int Index1, int Index2);
	HIDESBASE _di_IJclStringList __fastcall Add(System::TVarRec const *A, const int A_Size)/* overload */;
	HIDESBASE _di_IJclStringList __fastcall AddStrings(System::UnicodeString const *A, const int A_Size)/* overload */;
	HIDESBASE _di_IJclStringList __fastcall BeginUpdate(void);
	HIDESBASE _di_IJclStringList __fastcall EndUpdate(void);
	_di_IJclStringList __fastcall Trim(void);
	System::UnicodeString __fastcall Join(const System::UnicodeString ASeparator = L"");
	_di_IJclStringList __fastcall Split(const System::UnicodeString AText, const System::UnicodeString ASeparator, bool AClearBeforeAdd = true);
	_di_IJclStringList __fastcall ExtractWords(const System::UnicodeString AText, const Jclbase::TSetOfAnsiChar &ADelims = (Jclbase::TSetOfAnsiChar() << '\x0' << '\x1' << '\x2' << '\x3' << '\x4' << '\x5' << '\x6' << '\x7' << '\x8' << '\x9' << '\xa' << '\xb' << '\xc' << '\xd' << '\xe' << '\xf' << '\x10' << '\x11' << '\x12' << '\x13' << '\x14' << '\x15' << '\x16' << '\x17' << '\x18' << '\x19' << '\x1a' << '\x1b' << '\x1c' << '\x1d' << '\x1e' << '\x1f' << '\x20' ), bool AClearBeforeAdd = true);
	System::UnicodeString __fastcall Last(void);
	System::UnicodeString __fastcall First(void);
	int __fastcall LastIndex(void);
	HIDESBASE _di_IJclStringList __fastcall Clear(void);
	_di_IJclStringList __fastcall DeleteRegEx(const System::UnicodeString APattern);
	_di_IJclStringList __fastcall KeepRegEx(const System::UnicodeString APattern);
	_di_IJclStringList __fastcall Files(const System::UnicodeString APattern = L"*", bool ARecursive = false, const System::UnicodeString ARegExPattern = L"");
	_di_IJclStringList __fastcall Directories(const System::UnicodeString APattern = L"*", bool ARecursive = false, const System::UnicodeString ARegExPattern = L"");
	Classes::TStrings* __fastcall GetStringsRef(void);
	_di_IJclStringList __fastcall ConfigAsSet(void);
	_di_IJclStringList __fastcall Delimit(const System::UnicodeString ADelimiter);
	System::_di_IInterface __fastcall GetInterfaceByIndex(int Index);
	_di_IJclStringList __fastcall GetLists(int Index);
	System::Variant __fastcall GetVariants(int AIndex);
	System::_di_IInterface __fastcall GetKeyInterface(const System::UnicodeString AKey);
	System::TObject* __fastcall GetKeyObject(const System::UnicodeString AKey);
	System::Variant __fastcall GetKeyVariant(const System::UnicodeString AKey);
	_di_IJclStringList __fastcall GetKeyList(const System::UnicodeString AKey);
	TJclStringListObjectsMode __fastcall GetObjectsMode(void);
	void __fastcall SetInterfaceByIndex(int Index, const System::_di_IInterface Value);
	void __fastcall SetLists(int Index, const _di_IJclStringList Value);
	void __fastcall SetVariants(int Index, const System::Variant &Value);
	void __fastcall SetKeyInterface(const System::UnicodeString AKey, const System::_di_IInterface Value);
	void __fastcall SetKeyObject(const System::UnicodeString AKey, const System::TObject* Value);
	void __fastcall SetKeyVariant(const System::UnicodeString AKey, const System::Variant &Value);
	void __fastcall SetKeyList(const System::UnicodeString AKey, const _di_IJclStringList Value);
	__property System::_di_IInterface Interfaces[int Index] = {read=GetInterfaceByIndex, write=SetInterfaceByIndex};
	__property _di_IJclStringList Lists[int Index] = {read=GetLists, write=SetLists};
	__property System::Variant Variants[int Index] = {read=GetVariants, write=SetVariants};
	__property _di_IJclStringList KeyList[const System::UnicodeString AKey] = {read=GetKeyList, write=SetKeyList};
	__property System::TObject* KeyObject[const System::UnicodeString AKey] = {read=GetKeyObject, write=SetKeyObject};
	__property System::_di_IInterface KeyInterface[const System::UnicodeString AKey] = {read=GetKeyInterface, write=SetKeyInterface};
	__property System::Variant KeyVariant[const System::UnicodeString AKey] = {read=GetKeyVariant, write=SetKeyVariant};
	__property TJclStringListObjectsMode ObjectsMode = {read=GetObjectsMode, nodefault};
private:
	void *__IJclStringList;	/* IJclStringList */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclStringList()
	{
		_di_IJclStringList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStringList*(void) { return (IJclStringList*)&__IJclStringList; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE _di_IJclStringList __fastcall JclStringList(void)/* overload */;
extern PACKAGE _di_IJclStringList __fastcall JclStringList(const System::UnicodeString AText)/* overload */;
extern PACKAGE _di_IJclStringList __fastcall JclStringListStrings(Classes::TStrings* AStrings)/* overload */;
extern PACKAGE _di_IJclStringList __fastcall JclStringListStrings(System::UnicodeString const *A, const int A_Size)/* overload */;
extern PACKAGE _di_IJclStringList __fastcall JclStringList(System::TVarRec const *A, const int A_Size)/* overload */;

}	/* namespace Jclstringlists */
using namespace Jclstringlists;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclstringlistsHPP
