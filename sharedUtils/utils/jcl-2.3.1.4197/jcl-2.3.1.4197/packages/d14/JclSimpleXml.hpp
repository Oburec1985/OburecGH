// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclsimplexml.pas' rev: 21.00

#ifndef JclsimplexmlHPP
#define JclsimplexmlHPP

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
#include <Variants.hpp>	// Pascal unit
#include <Inifiles.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclstreams.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclsimplexml
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclSimpleData;
class PASCALIMPLEMENTATION TJclSimpleData : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FName;
	System::UnicodeString FValue;
	void *FData;
	
protected:
	bool __fastcall GetBoolValue(void);
	void __fastcall SetBoolValue(const bool Value);
	virtual void __fastcall SetName(const System::UnicodeString Value);
	System::Extended __fastcall GetFloatValue(void);
	void __fastcall SetFloatValue(const System::Extended Value);
	System::AnsiString __fastcall GetAnsiValue(void);
	void __fastcall SetAnsiValue(const System::AnsiString Value);
	__int64 __fastcall GetIntValue(void);
	void __fastcall SetIntValue(const __int64 Value);
	
public:
	__fastcall TJclSimpleData(const System::UnicodeString AName);
	__property System::UnicodeString Name = {read=FName, write=SetName};
	__property System::UnicodeString Value = {read=FValue, write=FValue};
	__property System::AnsiString AnsiValue = {read=GetAnsiValue, write=SetAnsiValue};
	__property __int64 IntValue = {read=GetIntValue, write=SetIntValue};
	__property bool BoolValue = {read=GetBoolValue, write=SetBoolValue, nodefault};
	__property System::Extended FloatValue = {read=GetFloatValue, write=SetFloatValue};
	__property void * Data = {read=FData, write=FData};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleData(void) { }
	
};


class DELPHICLASS TJclSimpleXMLData;
class PASCALIMPLEMENTATION TJclSimpleXMLData : public TJclSimpleData
{
	typedef TJclSimpleData inherited;
	
private:
	System::UnicodeString FNameSpace;
	
public:
	System::UnicodeString __fastcall FullName(void);
	__property System::UnicodeString NameSpace = {read=FNameSpace, write=FNameSpace};
public:
	/* TJclSimpleData.Create */ inline __fastcall TJclSimpleXMLData(const System::UnicodeString AName) : TJclSimpleData(AName) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleXMLData(void) { }
	
};


class DELPHICLASS EJclSimpleXMLError;
class PASCALIMPLEMENTATION EJclSimpleXMLError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclSimpleXMLError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclSimpleXMLError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclSimpleXMLError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclSimpleXMLError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclSimpleXMLError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclSimpleXMLError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclSimpleXMLError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclSimpleXMLError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclSimpleXMLError(void) { }
	
};


typedef void __fastcall (__closure *TJclOnSimpleXMLParsed)(System::TObject* Sender, const System::UnicodeString Name);

typedef void __fastcall (__closure *TJclOnValueParsed)(System::TObject* Sender, const System::UnicodeString Name, const System::UnicodeString Value);

typedef void __fastcall (__closure *TJclOnSimpleProgress)(System::TObject* Sender, const int Position, const int Total);

#pragma option push -b-
enum TJclHashKind { hkList, hkDirect };
#pragma option pop

struct TJclHashElem;
typedef TJclHashElem *PJclHashElem;

#pragma pack(push,1)
struct TJclHashElem
{
	
public:
	TJclHashElem *Next;
	System::TObject* Obj;
};
#pragma pack(pop)


struct TJclHashRecord;
typedef TJclHashRecord *PJclHashRecord;

typedef StaticArray<PJclHashRecord, 26> TJclHashList;

typedef TJclHashList *PJclHashList;

#pragma pack(push,1)
struct TJclHashRecord
{
	
public:
	System::Byte Count;
	
public:
	TJclHashKind Kind;
	union
	{
		struct 
		{
			TJclHashElem *FirstElem;
			
		};
		struct 
		{
			TJclHashList *List;
			
		};
		
	};
};
#pragma pack(pop)


class DELPHICLASS TJclSimpleXMLProp;
class DELPHICLASS TJclSimpleXMLProps;
class DELPHICLASS TJclSimpleXML;
class PASCALIMPLEMENTATION TJclSimpleXMLProp : public TJclSimpleXMLData
{
	typedef TJclSimpleXMLData inherited;
	
private:
	TJclSimpleXMLProps* FParent;
	
protected:
	virtual void __fastcall SetName(const System::UnicodeString Value);
	
public:
	TJclSimpleXML* __fastcall GetSimpleXML(void);
	void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream);
	__property TJclSimpleXMLProps* Parent = {read=FParent, write=FParent};
public:
	/* TJclSimpleData.Create */ inline __fastcall TJclSimpleXMLProp(const System::UnicodeString AName) : TJclSimpleXMLData(AName) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleXMLProp(void) { }
	
};


class DELPHICLASS TJclSimpleXMLPropsEnumerator;
class PASCALIMPLEMENTATION TJclSimpleXMLPropsEnumerator : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FIndex;
	TJclSimpleXMLProps* FList;
	
public:
	__fastcall TJclSimpleXMLPropsEnumerator(TJclSimpleXMLProps* AList);
	TJclSimpleXMLProp* __fastcall GetCurrent(void);
	bool __fastcall MoveNext(void);
	__property TJclSimpleXMLProp* Current = {read=GetCurrent};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleXMLPropsEnumerator(void) { }
	
};


class DELPHICLASS TJclSimpleXMLElem;
class PASCALIMPLEMENTATION TJclSimpleXMLProps : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclSimpleXMLProp* operator[](const int Index) { return Item[Index]; }
	
private:
	Inifiles::THashedStringList* FProperties;
	TJclSimpleXMLElem* FParent;
	int __fastcall GetCount(void);
	TJclSimpleXMLProp* __fastcall GetItemNamedDefault(const System::UnicodeString Name, const System::UnicodeString Default);
	TJclSimpleXMLProp* __fastcall GetItemNamed(const System::UnicodeString Name);
	
protected:
	TJclSimpleXML* __fastcall GetSimpleXML(void);
	TJclSimpleXMLProp* __fastcall GetItem(const int Index);
	void __fastcall DoItemRename(TJclSimpleXMLProp* Value, const System::UnicodeString Name);
	void __fastcall Error(const System::UnicodeString S);
	void __fastcall FmtError(const System::UnicodeString S, System::TVarRec const *Args, const int Args_Size);
	
public:
	__fastcall TJclSimpleXMLProps(TJclSimpleXMLElem* Parent);
	__fastcall virtual ~TJclSimpleXMLProps(void);
	TJclSimpleXMLProp* __fastcall Add(const System::UnicodeString Name, const System::UnicodeString Value)/* overload */;
	TJclSimpleXMLProp* __fastcall Add(const System::UnicodeString Name, const System::AnsiString Value)/* overload */;
	TJclSimpleXMLProp* __fastcall Add(const System::UnicodeString Name, const __int64 Value)/* overload */;
	TJclSimpleXMLProp* __fastcall Add(const System::UnicodeString Name, const bool Value)/* overload */;
	TJclSimpleXMLProp* __fastcall Insert(const int Index, const System::UnicodeString Name, const System::UnicodeString Value)/* overload */;
	TJclSimpleXMLProp* __fastcall Insert(const int Index, const System::UnicodeString Name, const __int64 Value)/* overload */;
	TJclSimpleXMLProp* __fastcall Insert(const int Index, const System::UnicodeString Name, const bool Value)/* overload */;
	virtual void __fastcall Clear(void);
	void __fastcall Delete(const int Index)/* overload */;
	void __fastcall Delete(const System::UnicodeString Name)/* overload */;
	TJclSimpleXMLPropsEnumerator* __fastcall GetEnumerator(void);
	System::UnicodeString __fastcall Value(const System::UnicodeString Name, const System::UnicodeString Default = L"");
	__int64 __fastcall IntValue(const System::UnicodeString Name, const __int64 Default = 0xffffffffffffffff);
	bool __fastcall BoolValue(const System::UnicodeString Name, bool Default = true);
	System::Extended __fastcall FloatValue(const System::UnicodeString Name, const System::Extended Default = 0.000000E+00);
	void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream);
	void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream);
	__property TJclSimpleXMLProp* Item[const int Index] = {read=GetItem/*, default*/};
	__property TJclSimpleXMLProp* ItemNamed[const System::UnicodeString Name] = {read=GetItemNamed};
	__property int Count = {read=GetCount, nodefault};
};


class DELPHICLASS TJclSimpleXMLElemsPrologEnumerator;
class DELPHICLASS TJclSimpleXMLElemsProlog;
class PASCALIMPLEMENTATION TJclSimpleXMLElemsPrologEnumerator : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FIndex;
	TJclSimpleXMLElemsProlog* FList;
	
public:
	__fastcall TJclSimpleXMLElemsPrologEnumerator(TJclSimpleXMLElemsProlog* AList);
	TJclSimpleXMLElem* __fastcall GetCurrent(void);
	bool __fastcall MoveNext(void);
	__property TJclSimpleXMLElem* Current = {read=GetCurrent};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemsPrologEnumerator(void) { }
	
};


class DELPHICLASS TJclSimpleXMLElemComment;
class DELPHICLASS TJclSimpleXMLElemDocType;
class DELPHICLASS TJclSimpleXMLElemSheet;
class DELPHICLASS TJclSimpleXMLElemMSOApplication;
class PASCALIMPLEMENTATION TJclSimpleXMLElemsProlog : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclSimpleXMLElem* operator[](const int Index) { return Item[Index]; }
	
private:
	Inifiles::THashedStringList* FElems;
	TJclSimpleXML* FSimpleXml;
	int __fastcall GetCount(void);
	TJclSimpleXMLElem* __fastcall GetItem(const int Index);
	System::UnicodeString __fastcall GetEncoding(void);
	bool __fastcall GetStandAlone(void);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetEncoding(const System::UnicodeString Value);
	void __fastcall SetStandAlone(const bool Value);
	void __fastcall SetVersion(const System::UnicodeString Value);
	
protected:
	TJclSimpleXMLElem* __fastcall FindHeader(void);
	void __fastcall Error(const System::UnicodeString S);
	void __fastcall FmtError(const System::UnicodeString S, System::TVarRec const *Args, const int Args_Size);
	
public:
	__fastcall TJclSimpleXMLElemsProlog(void);
	__fastcall virtual ~TJclSimpleXMLElemsProlog(void);
	TJclSimpleXMLElemComment* __fastcall AddComment(const System::UnicodeString AValue);
	TJclSimpleXMLElemDocType* __fastcall AddDocType(const System::UnicodeString AValue);
	void __fastcall Clear(void);
	TJclSimpleXMLElemSheet* __fastcall AddStyleSheet(const System::UnicodeString AType, const System::UnicodeString AHRef);
	TJclSimpleXMLElemMSOApplication* __fastcall AddMSOApplication(const System::UnicodeString AProgId);
	void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	TJclSimpleXMLElemsPrologEnumerator* __fastcall GetEnumerator(void);
	__property TJclSimpleXMLElem* Item[const int Index] = {read=GetItem/*, default*/};
	__property int Count = {read=GetCount, nodefault};
	__property System::UnicodeString Encoding = {read=GetEncoding, write=SetEncoding};
	__property TJclSimpleXML* SimpleXML = {read=FSimpleXml};
	__property bool StandAlone = {read=GetStandAlone, write=SetStandAlone, nodefault};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
};


class DELPHICLASS TJclSimpleXMLNamedElemsEnumerator;
class DELPHICLASS TJclSimpleXMLNamedElems;
class PASCALIMPLEMENTATION TJclSimpleXMLNamedElemsEnumerator : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FIndex;
	TJclSimpleXMLNamedElems* FList;
	
public:
	__fastcall TJclSimpleXMLNamedElemsEnumerator(TJclSimpleXMLNamedElems* AList);
	TJclSimpleXMLElem* __fastcall GetCurrent(void);
	bool __fastcall MoveNext(void);
	__property TJclSimpleXMLElem* Current = {read=GetCurrent};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleXMLNamedElemsEnumerator(void) { }
	
};


class DELPHICLASS TJclSimpleXMLElems;
class DELPHICLASS TJclSimpleXMLElemClassic;
class DELPHICLASS TJclSimpleXMLElemCData;
class DELPHICLASS TJclSimpleXMLElemText;
class PASCALIMPLEMENTATION TJclSimpleXMLNamedElems : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclSimpleXMLElem* operator[](const int Index) { return Item[Index]; }
	
private:
	TJclSimpleXMLElems* FElems;
	System::UnicodeString FName;
	int __fastcall GetCount(void);
	
protected:
	Classes::TList* FItems;
	TJclSimpleXMLElem* __fastcall GetItem(const int Index);
	
public:
	__fastcall TJclSimpleXMLNamedElems(const TJclSimpleXMLElems* AOwner, const System::UnicodeString AName);
	__fastcall virtual ~TJclSimpleXMLNamedElems(void);
	TJclSimpleXMLElemClassic* __fastcall Add(void)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(const System::UnicodeString Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(const __int64 Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(const bool Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(Classes::TStream* Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall AddFirst(void);
	TJclSimpleXMLElemComment* __fastcall AddComment(const System::UnicodeString Value);
	TJclSimpleXMLElemCData* __fastcall AddCData(const System::UnicodeString Value);
	TJclSimpleXMLElemText* __fastcall AddText(const System::UnicodeString Value);
	virtual void __fastcall Clear(void);
	void __fastcall Delete(const int Index);
	void __fastcall Move(const int CurIndex, const int NewIndex);
	int __fastcall IndexOf(const TJclSimpleXMLElem* Value)/* overload */;
	int __fastcall IndexOf(const System::UnicodeString Value)/* overload */;
	TJclSimpleXMLNamedElemsEnumerator* __fastcall GetEnumerator(void);
	__property TJclSimpleXMLElems* Elems = {read=FElems};
	__property TJclSimpleXMLElem* Item[const int Index] = {read=GetItem/*, default*/};
	__property int Count = {read=GetCount, nodefault};
	__property System::UnicodeString Name = {read=FName};
};


class DELPHICLASS TJclSimpleXMLElemsEnumerator;
class PASCALIMPLEMENTATION TJclSimpleXMLElemsEnumerator : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FIndex;
	TJclSimpleXMLElems* FList;
	
public:
	__fastcall TJclSimpleXMLElemsEnumerator(TJclSimpleXMLElems* AList);
	TJclSimpleXMLElem* __fastcall GetCurrent(void);
	bool __fastcall MoveNext(void);
	__property TJclSimpleXMLElem* Current = {read=GetCurrent};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemsEnumerator(void) { }
	
};


typedef int __fastcall (__closure *TJclSimpleXMLElemCompare)(TJclSimpleXMLElems* Elems, int Index1, int Index2);

class PASCALIMPLEMENTATION TJclSimpleXMLElems : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclSimpleXMLElem* operator[](const int Index) { return Item[Index]; }
	
private:
	TJclSimpleXMLElem* FParent;
	int __fastcall GetCount(void);
	TJclSimpleXMLElem* __fastcall GetItemNamedDefault(const System::UnicodeString Name, const System::UnicodeString Default);
	TJclSimpleXMLElem* __fastcall GetItemNamed(const System::UnicodeString Name);
	TJclSimpleXMLNamedElems* __fastcall GetNamedElems(const System::UnicodeString Name);
	
protected:
	Inifiles::THashedStringList* FElems;
	TJclSimpleXMLElemCompare FCompare;
	Inifiles::THashedStringList* FNamedElems;
	TJclSimpleXMLElem* __fastcall GetItem(const int Index);
	void __fastcall AddChild(const TJclSimpleXMLElem* Value);
	void __fastcall AddChildFirst(const TJclSimpleXMLElem* Value);
	void __fastcall InsertChild(const TJclSimpleXMLElem* Value, int Index);
	void __fastcall DoItemRename(TJclSimpleXMLElem* Value, const System::UnicodeString Name);
	void __fastcall CreateElems(void);
	
public:
	__fastcall TJclSimpleXMLElems(const TJclSimpleXMLElem* AOwner);
	__fastcall virtual ~TJclSimpleXMLElems(void);
	void __fastcall Notify(TJclSimpleXMLElem* Value, Classes::TOperation Operation);
	TJclSimpleXMLElemClassic* __fastcall Add(const System::UnicodeString Name)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(const System::UnicodeString Name, const System::UnicodeString Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(const System::UnicodeString Name, const __int64 Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(const System::UnicodeString Name, const bool Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Add(const System::UnicodeString Name, Classes::TStream* Value)/* overload */;
	TJclSimpleXMLElem* __fastcall Add(TJclSimpleXMLElem* Value)/* overload */;
	TJclSimpleXMLElem* __fastcall AddFirst(TJclSimpleXMLElem* Value)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall AddFirst(const System::UnicodeString Name)/* overload */;
	TJclSimpleXMLElemComment* __fastcall AddComment(const System::UnicodeString Name, const System::UnicodeString Value);
	TJclSimpleXMLElemCData* __fastcall AddCData(const System::UnicodeString Name, const System::UnicodeString Value);
	TJclSimpleXMLElemText* __fastcall AddText(const System::UnicodeString Name, const System::UnicodeString Value);
	TJclSimpleXMLElem* __fastcall Insert(TJclSimpleXMLElem* Value, int Index)/* overload */;
	TJclSimpleXMLElemClassic* __fastcall Insert(const System::UnicodeString Name, int Index)/* overload */;
	virtual void __fastcall Clear(void);
	void __fastcall Delete(const int Index)/* overload */;
	void __fastcall Delete(const System::UnicodeString Name)/* overload */;
	int __fastcall Remove(TJclSimpleXMLElem* Value);
	void __fastcall Move(const int CurIndex, const int NewIndex);
	TJclSimpleXMLElemsEnumerator* __fastcall GetEnumerator(void);
	int __fastcall IndexOf(const TJclSimpleXMLElem* Value)/* overload */;
	int __fastcall IndexOf(const System::UnicodeString Name)/* overload */;
	System::UnicodeString __fastcall Value(const System::UnicodeString Name, const System::UnicodeString Default = L"");
	__int64 __fastcall IntValue(const System::UnicodeString Name, const __int64 Default = 0xffffffffffffffff);
	System::Extended __fastcall FloatValue(const System::UnicodeString Name, const System::Extended Default = 0.000000E+00);
	bool __fastcall BoolValue(const System::UnicodeString Name, bool Default = true);
	void __fastcall BinaryValue(const System::UnicodeString Name, Classes::TStream* Stream);
	void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	void __fastcall Sort(void);
	void __fastcall CustomSort(TJclSimpleXMLElemCompare AFunction);
	__property TJclSimpleXMLElem* Parent = {read=FParent, write=FParent};
	__property TJclSimpleXMLElem* Item[const int Index] = {read=GetItem/*, default*/};
	__property TJclSimpleXMLElem* ItemNamed[const System::UnicodeString Name] = {read=GetItemNamed};
	__property int Count = {read=GetCount, nodefault};
	__property TJclSimpleXMLNamedElems* NamedElems[const System::UnicodeString Name] = {read=GetNamedElems};
};


class PASCALIMPLEMENTATION TJclSimpleXMLElem : public TJclSimpleXMLData
{
	typedef TJclSimpleXMLData inherited;
	
private:
	TJclSimpleXMLElem* FParent;
	TJclSimpleXMLElems* FItems;
	TJclSimpleXMLProps* FProps;
	TJclSimpleXML* FSimpleXML;
	TJclSimpleXMLElems* FContainer;
	bool __fastcall GetHasItems(void);
	bool __fastcall GetHasProperties(void);
	int __fastcall GetItemCount(void);
	int __fastcall GetPropertyCount(void);
	
protected:
	TJclSimpleXML* __fastcall GetSimpleXML(void);
	int __fastcall GetChildsCount(void);
	TJclSimpleXMLProps* __fastcall GetProps(void);
	virtual void __fastcall SetName(const System::UnicodeString Value);
	TJclSimpleXMLElems* __fastcall GetItems(void);
	void __fastcall Error(const System::UnicodeString S);
	void __fastcall FmtError(const System::UnicodeString S, System::TVarRec const *Args, const int Args_Size);
	
public:
	__fastcall TJclSimpleXMLElem(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName);
	__fastcall virtual ~TJclSimpleXMLElem(void);
	virtual void __fastcall Assign(TJclSimpleXMLElem* Value);
	virtual void __fastcall Clear(void);
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0)) = 0 ;
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0)) = 0 ;
	void __fastcall LoadFromString(const System::UnicodeString Value);
	System::UnicodeString __fastcall SaveToString(void);
	void __fastcall GetBinaryValue(Classes::TStream* Stream);
	int __fastcall GetChildIndex(const TJclSimpleXMLElem* AChild);
	int __fastcall GetNamedIndex(const TJclSimpleXMLElem* AChild);
	__property TJclSimpleXML* SimpleXML = {read=GetSimpleXML};
	__property TJclSimpleXMLElems* Container = {read=FContainer, write=FContainer};
	
__published:
	__property TJclSimpleXMLElem* Parent = {read=FParent, write=FParent};
	__property int ChildsCount = {read=GetChildsCount, nodefault};
	__property bool HasItems = {read=GetHasItems, nodefault};
	__property bool HasProperties = {read=GetHasProperties, nodefault};
	__property int ItemCount = {read=GetItemCount, nodefault};
	__property int PropertyCount = {read=GetPropertyCount, nodefault};
	__property TJclSimpleXMLElems* Items = {read=GetItems};
	__property TJclSimpleXMLProps* Properties = {read=GetProps};
};


typedef TMetaClass* TJclSimpleXMLElemClass;

class PASCALIMPLEMENTATION TJclSimpleXMLElemComment : public TJclSimpleXMLElem
{
	typedef TJclSimpleXMLElem inherited;
	
public:
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemComment(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElem(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemComment(void) { }
	
};


class PASCALIMPLEMENTATION TJclSimpleXMLElemClassic : public TJclSimpleXMLElem
{
	typedef TJclSimpleXMLElem inherited;
	
public:
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemClassic(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElem(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemClassic(void) { }
	
};


class PASCALIMPLEMENTATION TJclSimpleXMLElemCData : public TJclSimpleXMLElem
{
	typedef TJclSimpleXMLElem inherited;
	
public:
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemCData(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElem(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemCData(void) { }
	
};


class PASCALIMPLEMENTATION TJclSimpleXMLElemText : public TJclSimpleXMLElem
{
	typedef TJclSimpleXMLElem inherited;
	
public:
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemText(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElem(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemText(void) { }
	
};


class DELPHICLASS TJclSimpleXMLElemProcessingInstruction;
class PASCALIMPLEMENTATION TJclSimpleXMLElemProcessingInstruction : public TJclSimpleXMLElem
{
	typedef TJclSimpleXMLElem inherited;
	
public:
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemProcessingInstruction(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElem(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemProcessingInstruction(void) { }
	
};


class DELPHICLASS TJclSimpleXMLElemHeader;
class PASCALIMPLEMENTATION TJclSimpleXMLElemHeader : public TJclSimpleXMLElemProcessingInstruction
{
	typedef TJclSimpleXMLElemProcessingInstruction inherited;
	
private:
	System::UnicodeString __fastcall GetEncoding(void);
	bool __fastcall GetStandalone(void);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetEncoding(const System::UnicodeString Value);
	void __fastcall SetStandalone(const bool Value);
	void __fastcall SetVersion(const System::UnicodeString Value);
	
public:
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
	__property bool StandAlone = {read=GetStandalone, write=SetStandalone, nodefault};
	__property System::UnicodeString Encoding = {read=GetEncoding, write=SetEncoding};
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemHeader(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElemProcessingInstruction(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemHeader(void) { }
	
};


class PASCALIMPLEMENTATION TJclSimpleXMLElemSheet : public TJclSimpleXMLElemProcessingInstruction
{
	typedef TJclSimpleXMLElemProcessingInstruction inherited;
	
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemSheet(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElemProcessingInstruction(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemSheet(void) { }
	
};


class PASCALIMPLEMENTATION TJclSimpleXMLElemMSOApplication : public TJclSimpleXMLElemProcessingInstruction
{
	typedef TJclSimpleXMLElemProcessingInstruction inherited;
	
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemMSOApplication(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElemProcessingInstruction(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemMSOApplication(void) { }
	
};


class PASCALIMPLEMENTATION TJclSimpleXMLElemDocType : public TJclSimpleXMLElem
{
	typedef TJclSimpleXMLElem inherited;
	
public:
	virtual void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream, TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
	virtual void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream, const System::UnicodeString Level = L"", TJclSimpleXML* AParent = (TJclSimpleXML*)(0x0));
public:
	/* TJclSimpleXMLElem.Create */ inline __fastcall TJclSimpleXMLElemDocType(const TJclSimpleXMLElem* AOwner, const System::UnicodeString AName) : TJclSimpleXMLElem(AOwner, AName) { }
	/* TJclSimpleXMLElem.Destroy */ inline __fastcall virtual ~TJclSimpleXMLElemDocType(void) { }
	
};


#pragma option push -b-
enum Jclsimplexml__32 { sxoAutoCreate, sxoAutoIndent, sxoAutoEncodeValue, sxoAutoEncodeEntity, sxoDoNotSaveProlog, sxoTrimPrecedingTextWhitespace, sxoTrimFollowingTextWhitespace, sxoKeepWhitespace, sxoDoNotSaveBOM };
#pragma option pop

typedef Set<Jclsimplexml__32, sxoAutoCreate, sxoDoNotSaveBOM>  TJclSimpleXMLOptions;

typedef void __fastcall (__closure *TJclSimpleXMLEncodeEvent)(System::TObject* Sender, System::UnicodeString &Value);

typedef void __fastcall (__closure *TJclSimpleXMLEncodeStreamEvent)(System::TObject* Sender, Classes::TStream* InStream, Classes::TStream* OutStream);

class PASCALIMPLEMENTATION TJclSimpleXML : public System::TObject
{
	typedef System::TObject inherited;
	
protected:
	Jclstreams::TJclStringEncoding FEncoding;
	System::Word FCodePage;
	Sysutils::TFileName FFileName;
	TJclSimpleXMLOptions FOptions;
	TJclSimpleXMLElemClassic* FRoot;
	TJclOnSimpleXMLParsed FOnTagParsed;
	TJclOnValueParsed FOnValue;
	TJclOnSimpleProgress FOnLoadProg;
	TJclOnSimpleProgress FOnSaveProg;
	TJclSimpleXMLElemsProlog* FProlog;
	int FSaveCount;
	int FSaveCurrent;
	System::UnicodeString FIndentString;
	System::UnicodeString FBaseIndentString;
	TJclSimpleXMLEncodeEvent FOnEncodeValue;
	TJclSimpleXMLEncodeEvent FOnDecodeValue;
	TJclSimpleXMLEncodeStreamEvent FOnDecodeStream;
	TJclSimpleXMLEncodeStreamEvent FOnEncodeStream;
	void __fastcall SetIndentString(const System::UnicodeString Value);
	void __fastcall SetBaseIndentString(const System::UnicodeString Value);
	void __fastcall SetRoot(const TJclSimpleXMLElemClassic* Value);
	void __fastcall SetFileName(const Sysutils::TFileName Value);
	void __fastcall DoLoadProgress(const int APosition, const int ATotal);
	void __fastcall DoSaveProgress(void);
	void __fastcall DoTagParsed(const System::UnicodeString AName);
	void __fastcall DoValueParsed(const System::UnicodeString AName, const System::UnicodeString AValue);
	virtual void __fastcall DoEncodeValue(System::UnicodeString &Value);
	virtual void __fastcall DoDecodeValue(System::UnicodeString &Value);
	
public:
	__fastcall TJclSimpleXML(void);
	__fastcall virtual ~TJclSimpleXML(void);
	void __fastcall LoadFromString(const System::UnicodeString Value);
	void __fastcall LoadFromFile(const Sysutils::TFileName FileName, Jclstreams::TJclStringEncoding Encoding = (Jclstreams::TJclStringEncoding)(0x3), System::Word CodePage = (System::Word)(0x0));
	void __fastcall LoadFromStream(Classes::TStream* Stream, Jclstreams::TJclStringEncoding Encoding = (Jclstreams::TJclStringEncoding)(0x3), System::Word CodePage = (System::Word)(0x0));
	void __fastcall LoadFromStringStream(Jclstreams::TJclStringStream* StringStream);
	void __fastcall LoadFromResourceName(unsigned Instance, const System::UnicodeString ResName, Jclstreams::TJclStringEncoding Encoding = (Jclstreams::TJclStringEncoding)(0x3), System::Word CodePage = (System::Word)(0x0));
	void __fastcall SaveToFile(const Sysutils::TFileName FileName, Jclstreams::TJclStringEncoding Encoding = (Jclstreams::TJclStringEncoding)(0x3), System::Word CodePage = (System::Word)(0x0));
	void __fastcall SaveToStream(Classes::TStream* Stream, Jclstreams::TJclStringEncoding Encoding = (Jclstreams::TJclStringEncoding)(0x3), System::Word CodePage = (System::Word)(0x0));
	void __fastcall SaveToStringStream(Jclstreams::TJclStringStream* StringStream);
	System::UnicodeString __fastcall SaveToString(void);
	__property TJclSimpleXMLElemsProlog* Prolog = {read=FProlog, write=FProlog};
	__property TJclSimpleXMLElemClassic* Root = {read=FRoot, write=SetRoot};
	__property System::UnicodeString XMLData = {read=SaveToString, write=LoadFromString};
	__property Sysutils::TFileName FileName = {read=FFileName, write=SetFileName};
	__property System::UnicodeString IndentString = {read=FIndentString, write=SetIndentString};
	__property System::UnicodeString BaseIndentString = {read=FBaseIndentString, write=SetBaseIndentString};
	__property TJclSimpleXMLOptions Options = {read=FOptions, write=FOptions, nodefault};
	__property TJclOnSimpleProgress OnSaveProgress = {read=FOnSaveProg, write=FOnSaveProg};
	__property TJclOnSimpleProgress OnLoadProgress = {read=FOnLoadProg, write=FOnLoadProg};
	__property TJclOnSimpleXMLParsed OnTagParsed = {read=FOnTagParsed, write=FOnTagParsed};
	__property TJclOnValueParsed OnValueParsed = {read=FOnValue, write=FOnValue};
	__property TJclSimpleXMLEncodeEvent OnEncodeValue = {read=FOnEncodeValue, write=FOnEncodeValue};
	__property TJclSimpleXMLEncodeEvent OnDecodeValue = {read=FOnDecodeValue, write=FOnDecodeValue};
	__property TJclSimpleXMLEncodeStreamEvent OnEncodeStream = {read=FOnEncodeStream, write=FOnEncodeStream};
	__property TJclSimpleXMLEncodeStreamEvent OnDecodeStream = {read=FOnDecodeStream, write=FOnDecodeStream};
};


class DELPHICLASS TXMLVariant;
class PASCALIMPLEMENTATION TXMLVariant : public Variants::TInvokeableVariantType
{
	typedef Variants::TInvokeableVariantType inherited;
	
public:
	virtual void __fastcall Clear(TVarData &V);
	virtual bool __fastcall IsClear(const TVarData &V);
	virtual void __fastcall Copy(TVarData &Dest, const TVarData &Source, const bool Indirect);
	virtual void __fastcall CastTo(TVarData &Dest, const TVarData &Source, const System::Word AVarType);
	virtual bool __fastcall DoFunction(TVarData &Dest, const TVarData &V, const System::UnicodeString Name, const Variants::TVarDataArray Arguments);
	virtual bool __fastcall GetProperty(TVarData &Dest, const TVarData &V, const System::UnicodeString Name);
	virtual bool __fastcall SetProperty(const TVarData &V, const System::UnicodeString Name, const TVarData &Value);
public:
	/* TCustomVariantType.Create */ inline __fastcall TXMLVariant(void)/* overload */ : Variants::TInvokeableVariantType() { }
	/* TCustomVariantType.Destroy */ inline __fastcall virtual ~TXMLVariant(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE System::UnicodeString __fastcall EntityEncode(const System::UnicodeString S);
extern PACKAGE System::UnicodeString __fastcall EntityDecode(const System::UnicodeString S);
extern PACKAGE System::UnicodeString __fastcall SimpleXMLEncode(const System::UnicodeString S);
extern PACKAGE void __fastcall SimpleXMLDecode(System::UnicodeString &S, bool TrimBlanks);
extern PACKAGE System::UnicodeString __fastcall XMLEncode(const System::UnicodeString S);
extern PACKAGE System::UnicodeString __fastcall XMLDecode(const System::UnicodeString S);
extern PACKAGE System::Word __fastcall VarXML(void);
extern PACKAGE void __fastcall XMLCreateInto(System::Variant &ADest, const TJclSimpleXMLElem* AXML);
extern PACKAGE System::Variant __fastcall XMLCreate(const TJclSimpleXMLElem* AXML)/* overload */;
extern PACKAGE System::Variant __fastcall XMLCreate(void)/* overload */;

}	/* namespace Jclsimplexml */
using namespace Jclsimplexml;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclsimplexmlHPP
