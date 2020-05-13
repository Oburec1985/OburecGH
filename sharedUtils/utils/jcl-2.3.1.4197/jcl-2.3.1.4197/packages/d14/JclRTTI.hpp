// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclrtti.pas' rev: 21.00

#ifndef JclrttiHPP
#define JclrttiHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclrtti
{
//-- type declarations -------------------------------------------------------
__interface IJclInfoWriter;
typedef System::DelphiInterface<IJclInfoWriter> _di_IJclInfoWriter;
__interface  INTERFACE_UUID("{7DAD522D-46EA-11D5-B0C0-4854E825F345}") IJclInfoWriter  : public System::IInterface 
{
	
public:
	virtual int __fastcall GetWrap(void) = 0 ;
	virtual void __fastcall SetWrap(const int Value) = 0 ;
	virtual void __fastcall Write(const System::UnicodeString S) = 0 ;
	virtual void __fastcall Writeln(const System::UnicodeString S = L"") = 0 ;
	virtual void __fastcall Indent(void) = 0 ;
	virtual void __fastcall Outdent(void) = 0 ;
	__property int Wrap = {read=GetWrap, write=SetWrap};
};

class DELPHICLASS TJclInfoWriter;
class PASCALIMPLEMENTATION TJclInfoWriter : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	System::UnicodeString FCurLine;
	int FIndentLevel;
	int FWrap;
	
protected:
	void __fastcall DoWrap(void);
	void __fastcall DoWriteCompleteLines(void);
	virtual void __fastcall PrimWrite(const System::UnicodeString S) = 0 ;
	__property System::UnicodeString CurLine = {read=FCurLine, write=FCurLine};
	__property int IndentLevel = {read=FIndentLevel, write=FIndentLevel, nodefault};
	
public:
	__fastcall TJclInfoWriter(const int AWrap);
	__fastcall virtual ~TJclInfoWriter(void);
	int __fastcall GetWrap(void);
	void __fastcall SetWrap(const int Value);
	void __fastcall Write(const System::UnicodeString S);
	void __fastcall Writeln(const System::UnicodeString S = L"");
	void __fastcall Indent(void);
	void __fastcall Outdent(void);
	__property int Wrap = {read=GetWrap, write=SetWrap, nodefault};
private:
	void *__IJclInfoWriter;	/* IJclInfoWriter */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclInfoWriter()
	{
		_di_IJclInfoWriter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInfoWriter*(void) { return (IJclInfoWriter*)&__IJclInfoWriter; }
	#endif
	
};


class DELPHICLASS TJclInfoStringsWriter;
class PASCALIMPLEMENTATION TJclInfoStringsWriter : public TJclInfoWriter
{
	typedef TJclInfoWriter inherited;
	
private:
	Classes::TStrings* FStrings;
	
protected:
	virtual void __fastcall PrimWrite(const System::UnicodeString S);
	
public:
	__fastcall TJclInfoStringsWriter(const Classes::TStrings* AStrings, const int AWrap);
	__property Classes::TStrings* Strings = {read=FStrings};
public:
	/* TJclInfoWriter.Destroy */ inline __fastcall virtual ~TJclInfoStringsWriter(void) { }
	
};


__interface IJclBaseInfo;
typedef System::DelphiInterface<IJclBaseInfo> _di_IJclBaseInfo;
__interface  INTERFACE_UUID("{84E57A52-7219-4248-BDC7-4AACBFE2002D}") IJclBaseInfo  : public System::IInterface 
{
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest) = 0 ;
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest) = 0 ;
};

__interface IJclTypeInfo;
typedef System::DelphiInterface<IJclTypeInfo> _di_IJclTypeInfo;
__interface  INTERFACE_UUID("{7DAD5220-46EA-11D5-B0C0-4854E825F345}") IJclTypeInfo  : public IJclBaseInfo 
{
	
public:
	virtual System::UnicodeString __fastcall GetName(void) = 0 ;
	virtual Typinfo::PTypeData __fastcall GetTypeData(void) = 0 ;
	virtual Typinfo::PTypeInfo __fastcall GetTypeInfo(void) = 0 ;
	virtual Typinfo::TTypeKind __fastcall GetTypeKind(void) = 0 ;
	__property System::UnicodeString Name = {read=GetName};
	__property Typinfo::PTypeData TypeData = {read=GetTypeData};
	__property Typinfo::PTypeInfo TypeInfo = {read=GetTypeInfo};
	__property Typinfo::TTypeKind TypeKind = {read=GetTypeKind};
};

class DELPHICLASS TJclTypeInfo;
class PASCALIMPLEMENTATION TJclTypeInfo : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	Typinfo::TTypeData *FTypeData;
	Typinfo::TTypeInfo *FTypeInfo;
	
public:
	__fastcall TJclTypeInfo(Typinfo::PTypeInfo ATypeInfo);
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	System::UnicodeString __fastcall GetName(void);
	Typinfo::PTypeData __fastcall GetTypeData(void);
	Typinfo::PTypeInfo __fastcall GetTypeInfo(void);
	Typinfo::TTypeKind __fastcall GetTypeKind(void);
	__property System::UnicodeString Name = {read=GetName};
	__property Typinfo::PTypeData TypeData = {read=GetTypeData};
	__property Typinfo::PTypeInfo TypeInfo = {read=GetTypeInfo};
	__property Typinfo::TTypeKind TypeKind = {read=GetTypeKind, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTypeInfo(void) { }
	
private:
	void *__IJclTypeInfo;	/* IJclTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclTypeInfo; }
	#endif
	
};


__interface IJclValueTypeInfo;
typedef System::DelphiInterface<IJclValueTypeInfo> _di_IJclValueTypeInfo;
__interface  INTERFACE_UUID("{522C6E39-F917-4C92-B085-223BD68C377F}") IJclValueTypeInfo  : public IJclTypeInfo 
{
	
public:
	virtual System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName) = 0 ;
	virtual void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value) = 0 ;
};

__interface IJclOrdinalTypeInfo;
typedef System::DelphiInterface<IJclOrdinalTypeInfo> _di_IJclOrdinalTypeInfo;
__interface  INTERFACE_UUID("{7DAD5221-46EA-11D5-B0C0-4854E825F345}") IJclOrdinalTypeInfo  : public IJclValueTypeInfo 
{
	
public:
	virtual Typinfo::TOrdType __fastcall GetOrdinalType(void) = 0 ;
	__property Typinfo::TOrdType OrdinalType = {read=GetOrdinalType};
};

class DELPHICLASS TJclOrdinalTypeInfo;
class PASCALIMPLEMENTATION TJclOrdinalTypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName);
	void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value);
	Typinfo::TOrdType __fastcall GetOrdinalType(void);
	__property Typinfo::TOrdType OrdinalType = {read=GetOrdinalType, nodefault};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclOrdinalTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclOrdinalTypeInfo(void) { }
	
private:
	void *__IJclOrdinalTypeInfo;	/* IJclOrdinalTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclOrdinalTypeInfo()
	{
		_di_IJclOrdinalTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclOrdinalTypeInfo*(void) { return (IJclOrdinalTypeInfo*)&__IJclOrdinalTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclOrdinalTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclOrdinalTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclOrdinalTypeInfo; }
	#endif
	
};


__interface IJclOrdinalRangeTypeInfo;
typedef System::DelphiInterface<IJclOrdinalRangeTypeInfo> _di_IJclOrdinalRangeTypeInfo;
__interface  INTERFACE_UUID("{7DAD5222-46EA-11D5-B0C0-4854E825F345}") IJclOrdinalRangeTypeInfo  : public IJclOrdinalTypeInfo 
{
	
public:
	virtual __int64 __fastcall GetMinValue(void) = 0 ;
	virtual __int64 __fastcall GetMaxValue(void) = 0 ;
	__property __int64 MinValue = {read=GetMinValue};
	__property __int64 MaxValue = {read=GetMaxValue};
};

class DELPHICLASS TJclOrdinalRangeTypeInfo;
class PASCALIMPLEMENTATION TJclOrdinalRangeTypeInfo : public TJclOrdinalTypeInfo
{
	typedef TJclOrdinalTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	__int64 __fastcall GetMinValue(void);
	__int64 __fastcall GetMaxValue(void);
	__property __int64 MinValue = {read=GetMinValue};
	__property __int64 MaxValue = {read=GetMaxValue};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclOrdinalRangeTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclOrdinalTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclOrdinalRangeTypeInfo(void) { }
	
private:
	void *__IJclOrdinalRangeTypeInfo;	/* IJclOrdinalRangeTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclOrdinalRangeTypeInfo()
	{
		_di_IJclOrdinalRangeTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclOrdinalRangeTypeInfo*(void) { return (IJclOrdinalRangeTypeInfo*)&__IJclOrdinalRangeTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclOrdinalTypeInfo()
	{
		_di_IJclOrdinalTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclOrdinalTypeInfo*(void) { return (IJclOrdinalTypeInfo*)&__IJclOrdinalRangeTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclOrdinalRangeTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclOrdinalRangeTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclOrdinalRangeTypeInfo; }
	#endif
	
};


__interface IJclEnumerationTypeInfo;
typedef System::DelphiInterface<IJclEnumerationTypeInfo> _di_IJclEnumerationTypeInfo;
__interface  INTERFACE_UUID("{7DAD5223-46EA-11D5-B0C0-4854E825F345}") IJclEnumerationTypeInfo  : public IJclOrdinalRangeTypeInfo 
{
	
public:
	System::UnicodeString operator[](const int I) { return Names[I]; }
	
public:
	virtual _di_IJclEnumerationTypeInfo __fastcall GetBaseType(void) = 0 ;
	virtual System::UnicodeString __fastcall GetNames(const int I) = 0 ;
	virtual System::UnicodeString __fastcall GetUnitName(void) = 0 ;
	virtual int __fastcall IndexOfName(const System::UnicodeString Name) = 0 ;
	__property _di_IJclEnumerationTypeInfo BaseType = {read=GetBaseType};
	__property System::UnicodeString Names[const int I] = {read=GetNames/*, default*/};
	__property System::UnicodeString UnitName = {read=GetUnitName};
};

class DELPHICLASS TJclEnumerationTypeInfo;
class PASCALIMPLEMENTATION TJclEnumerationTypeInfo : public TJclOrdinalRangeTypeInfo
{
	typedef TJclOrdinalRangeTypeInfo inherited;
	
public:
	System::UnicodeString operator[](const int I) { return Names[I]; }
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	HIDESBASE System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName);
	HIDESBASE void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value);
	_di_IJclEnumerationTypeInfo __fastcall GetBaseType(void);
	System::UnicodeString __fastcall GetNames(const int I);
	System::UnicodeString __fastcall GetUnitName(void);
	int __fastcall IndexOfName(const System::UnicodeString Name);
	__property _di_IJclEnumerationTypeInfo BaseType = {read=GetBaseType};
	__property System::UnicodeString Names[const int I] = {read=GetNames/*, default*/};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclEnumerationTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclOrdinalRangeTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclEnumerationTypeInfo(void) { }
	
private:
	void *__IJclEnumerationTypeInfo;	/* IJclEnumerationTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclEnumerationTypeInfo()
	{
		_di_IJclEnumerationTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEnumerationTypeInfo*(void) { return (IJclEnumerationTypeInfo*)&__IJclEnumerationTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclOrdinalRangeTypeInfo()
	{
		_di_IJclOrdinalRangeTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclOrdinalRangeTypeInfo*(void) { return (IJclOrdinalRangeTypeInfo*)&__IJclEnumerationTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclOrdinalTypeInfo()
	{
		_di_IJclOrdinalTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclOrdinalTypeInfo*(void) { return (IJclOrdinalTypeInfo*)&__IJclEnumerationTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclEnumerationTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclEnumerationTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclEnumerationTypeInfo; }
	#endif
	
};


__interface IJclSetTypeInfo;
typedef System::DelphiInterface<IJclSetTypeInfo> _di_IJclSetTypeInfo;
__interface  INTERFACE_UUID("{7DAD5224-46EA-11D5-B0C0-4854E825F345}") IJclSetTypeInfo  : public IJclOrdinalTypeInfo 
{
	
public:
	virtual _di_IJclOrdinalTypeInfo __fastcall GetBaseType(void) = 0 ;
	virtual void __fastcall GetAsList(const void *Value, const bool WantRanges, const Classes::TStrings* Strings) = 0 ;
	virtual void __fastcall SetAsList(/* out */ void *Value, const Classes::TStrings* Strings) = 0 ;
	__property _di_IJclOrdinalTypeInfo BaseType = {read=GetBaseType};
};

class DELPHICLASS TJclSetTypeInfo;
class PASCALIMPLEMENTATION TJclSetTypeInfo : public TJclOrdinalTypeInfo
{
	typedef TJclOrdinalTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	HIDESBASE System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName);
	HIDESBASE void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value);
	_di_IJclOrdinalTypeInfo __fastcall GetBaseType(void);
	void __fastcall GetAsList(const void *Value, const bool WantRanges, const Classes::TStrings* Strings);
	void __fastcall SetAsList(/* out */ void *Value, const Classes::TStrings* Strings);
	__property _di_IJclOrdinalTypeInfo BaseType = {read=GetBaseType};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclSetTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclOrdinalTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSetTypeInfo(void) { }
	
private:
	void *__IJclSetTypeInfo;	/* IJclSetTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclSetTypeInfo()
	{
		_di_IJclSetTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSetTypeInfo*(void) { return (IJclSetTypeInfo*)&__IJclSetTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclOrdinalTypeInfo()
	{
		_di_IJclOrdinalTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclOrdinalTypeInfo*(void) { return (IJclOrdinalTypeInfo*)&__IJclSetTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclSetTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclSetTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclSetTypeInfo; }
	#endif
	
};


__interface IJclFloatTypeInfo;
typedef System::DelphiInterface<IJclFloatTypeInfo> _di_IJclFloatTypeInfo;
__interface  INTERFACE_UUID("{7DAD5225-46EA-11D5-B0C0-4854E825F345}") IJclFloatTypeInfo  : public IJclValueTypeInfo 
{
	
public:
	virtual Typinfo::TFloatType __fastcall GetFloatType(void) = 0 ;
	__property Typinfo::TFloatType FloatType = {read=GetFloatType};
};

class DELPHICLASS TJclFloatTypeInfo;
class PASCALIMPLEMENTATION TJclFloatTypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName);
	void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value);
	Typinfo::TFloatType __fastcall GetFloatType(void);
	__property Typinfo::TFloatType FloatType = {read=GetFloatType, nodefault};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclFloatTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFloatTypeInfo(void) { }
	
private:
	void *__IJclFloatTypeInfo;	/* IJclFloatTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclFloatTypeInfo()
	{
		_di_IJclFloatTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclFloatTypeInfo*(void) { return (IJclFloatTypeInfo*)&__IJclFloatTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclFloatTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclFloatTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclFloatTypeInfo; }
	#endif
	
};


__interface IJclStringTypeInfo;
typedef System::DelphiInterface<IJclStringTypeInfo> _di_IJclStringTypeInfo;
__interface  INTERFACE_UUID("{7DAD5226-46EA-11D5-B0C0-4854E825F345}") IJclStringTypeInfo  : public IJclValueTypeInfo 
{
	
public:
	virtual int __fastcall GetMaxLength(void) = 0 ;
	__property int MaxLength = {read=GetMaxLength};
};

class DELPHICLASS TJclStringTypeInfo;
class PASCALIMPLEMENTATION TJclStringTypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName);
	void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value);
	int __fastcall GetMaxLength(void);
	__property int MaxLength = {read=GetMaxLength, nodefault};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclStringTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclStringTypeInfo(void) { }
	
private:
	void *__IJclStringTypeInfo;	/* IJclStringTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclStringTypeInfo()
	{
		_di_IJclStringTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStringTypeInfo*(void) { return (IJclStringTypeInfo*)&__IJclStringTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclStringTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclStringTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclStringTypeInfo; }
	#endif
	
};


#pragma option push -b-
enum TJclPropSpecKind { pskNone, pskStaticMethod, pskVirtualMethod, pskField, pskConstant };
#pragma option pop

__interface IJclPropInfo;
typedef System::DelphiInterface<IJclPropInfo> _di_IJclPropInfo;
__interface  INTERFACE_UUID("{7DAD5227-46EA-11D5-B0C0-4854E825F345}") IJclPropInfo  : public System::IInterface 
{
	
public:
	virtual Typinfo::PPropInfo __fastcall GetPropInfo(void) = 0 ;
	virtual _di_IJclTypeInfo __fastcall GetPropType(void) = 0 ;
	virtual void * __fastcall GetReader(void) = 0 ;
	virtual void * __fastcall GetWriter(void) = 0 ;
	virtual void * __fastcall GetStoredProc(void) = 0 ;
	virtual int __fastcall GetIndex(void) = 0 ;
	virtual int __fastcall GetDefault(void) = 0 ;
	virtual short __fastcall GetNameIndex(void) = 0 ;
	virtual System::UnicodeString __fastcall GetName(void) = 0 ;
	virtual TJclPropSpecKind __fastcall GetReaderType(void) = 0 ;
	virtual TJclPropSpecKind __fastcall GetWriterType(void) = 0 ;
	virtual TJclPropSpecKind __fastcall GetStoredType(void) = 0 ;
	virtual unsigned __fastcall GetReaderValue(void) = 0 ;
	virtual unsigned __fastcall GetWriterValue(void) = 0 ;
	virtual unsigned __fastcall GetStoredValue(void) = 0 ;
	virtual bool __fastcall IsStored(const System::TObject* AInstance) = 0 ;
	virtual bool __fastcall HasDefault(void) = 0 ;
	virtual bool __fastcall HasIndex(void) = 0 ;
	virtual System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj) = 0 ;
	virtual void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString Value) = 0 ;
	__property Typinfo::PPropInfo PropInfo = {read=GetPropInfo};
	__property _di_IJclTypeInfo PropType = {read=GetPropType};
	__property void * Reader = {read=GetReader};
	__property void * Writer = {read=GetWriter};
	__property void * StoredProc = {read=GetStoredProc};
	__property TJclPropSpecKind ReaderType = {read=GetReaderType};
	__property TJclPropSpecKind WriterType = {read=GetWriterType};
	__property TJclPropSpecKind StoredType = {read=GetStoredType};
	__property unsigned ReaderValue = {read=GetReaderValue};
	__property unsigned WriterValue = {read=GetWriterValue};
	__property unsigned StoredValue = {read=GetStoredValue};
	__property int Index = {read=GetIndex};
	__property int Default = {read=GetDefault};
	__property short NameIndex = {read=GetNameIndex};
	__property System::UnicodeString Name = {read=GetName};
};

class DELPHICLASS TJclPropInfo;
class PASCALIMPLEMENTATION TJclPropInfo : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	Typinfo::TPropInfo *FPropInfo;
	
public:
	__fastcall TJclPropInfo(const Typinfo::PPropInfo APropInfo);
	Typinfo::PPropInfo __fastcall GetPropInfo(void);
	_di_IJclTypeInfo __fastcall GetPropType(void);
	void * __fastcall GetReader(void);
	void * __fastcall GetWriter(void);
	void * __fastcall GetStoredProc(void);
	int __fastcall GetIndex(void);
	int __fastcall GetDefault(void);
	short __fastcall GetNameIndex(void);
	System::UnicodeString __fastcall GetName(void);
	TJclPropSpecKind __fastcall GetSpecKind(const unsigned Value);
	unsigned __fastcall GetSpecValue(const unsigned Value);
	TJclPropSpecKind __fastcall GetReaderType(void);
	TJclPropSpecKind __fastcall GetWriterType(void);
	TJclPropSpecKind __fastcall GetStoredType(void);
	unsigned __fastcall GetReaderValue(void);
	unsigned __fastcall GetWriterValue(void);
	unsigned __fastcall GetStoredValue(void);
	bool __fastcall IsStored(const System::TObject* AInstance);
	bool __fastcall HasDefault(void);
	bool __fastcall HasIndex(void);
	System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj);
	void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString Value);
	__property Typinfo::PPropInfo PropInfo = {read=GetPropInfo};
	__property _di_IJclTypeInfo PropType = {read=GetPropType};
	__property void * Reader = {read=GetReader};
	__property void * Writer = {read=GetWriter};
	__property void * StoredProc = {read=GetStoredProc};
	__property TJclPropSpecKind ReaderType = {read=GetReaderType, nodefault};
	__property TJclPropSpecKind WriterType = {read=GetWriterType, nodefault};
	__property TJclPropSpecKind StoredType = {read=GetStoredType, nodefault};
	__property unsigned ReaderValue = {read=GetReaderValue, nodefault};
	__property unsigned WriterValue = {read=GetWriterValue, nodefault};
	__property unsigned StoredValue = {read=GetStoredValue, nodefault};
	__property int Index = {read=GetIndex, nodefault};
	__property int Default = {read=GetDefault, nodefault};
	__property short NameIndex = {read=GetNameIndex, nodefault};
	__property System::UnicodeString Name = {read=GetName};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclPropInfo(void) { }
	
private:
	void *__IJclPropInfo;	/* IJclPropInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclPropInfo()
	{
		_di_IJclPropInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPropInfo*(void) { return (IJclPropInfo*)&__IJclPropInfo; }
	#endif
	
};


__interface IJclObjPropInfo;
typedef System::DelphiInterface<IJclObjPropInfo> _di_IJclObjPropInfo;
__interface IJclObjPropInfo  : public IJclPropInfo 
{
	
public:
	virtual System::UnicodeString __fastcall GetAbsoluteName(void) = 0 ;
	virtual System::TObject* __fastcall GetInstance(void) = 0 ;
	HIDESBASE virtual bool __fastcall IsStored(void) = 0 /* overload */;
	HIDESBASE virtual System::UnicodeString __fastcall SaveValueToString(void) = 0 ;
	HIDESBASE virtual void __fastcall LoadValueFromString(const System::UnicodeString Value) = 0 ;
	__property System::UnicodeString AbsoluteName = {read=GetAbsoluteName};
	__property System::TObject* Instance = {read=GetInstance};
};

typedef DynamicArray<_di_IJclObjPropInfo> IJclObjPropInfoArray;

class DELPHICLASS TJclObjPropInfo;
class PASCALIMPLEMENTATION TJclObjPropInfo : public TJclPropInfo
{
	typedef TJclPropInfo inherited;
	
private:
	System::UnicodeString FPrefix;
	System::TObject* FInstance;
	
public:
	__fastcall TJclObjPropInfo(const Typinfo::PPropInfo APropInfo, const System::UnicodeString APrefix, System::TObject* AInstance);
	System::UnicodeString __fastcall GetAbsoluteName(void);
	System::TObject* __fastcall GetInstance(void);
	HIDESBASE bool __fastcall IsStored(void)/* overload */;
	HIDESBASE System::UnicodeString __fastcall SaveValueToString(void)/* overload */;
	HIDESBASE void __fastcall LoadValueFromString(const System::UnicodeString Value)/* overload */;
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclObjPropInfo(void) { }
	
private:
	void *__IJclObjPropInfo;	/* IJclObjPropInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclObjPropInfo()
	{
		_di_IJclObjPropInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclObjPropInfo*(void) { return (IJclObjPropInfo*)&__IJclObjPropInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclPropInfo()
	{
		_di_IJclPropInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPropInfo*(void) { return (IJclPropInfo*)&__IJclObjPropInfo; }
	#endif
	
};


__interface IJclClassTypeInfo;
typedef System::DelphiInterface<IJclClassTypeInfo> _di_IJclClassTypeInfo;
__interface  INTERFACE_UUID("{7DAD5228-46EA-11D5-B0C0-4854E825F345}") IJclClassTypeInfo  : public IJclValueTypeInfo 
{
	
public:
	virtual System::TClass __fastcall GetClassRef(void) = 0 ;
	virtual _di_IJclClassTypeInfo __fastcall GetParent(void) = 0 ;
	virtual int __fastcall GetTotalPropertyCount(void) = 0 ;
	virtual int __fastcall GetPropertyCount(void) = 0 ;
	virtual _di_IJclPropInfo __fastcall GetProperties(const int PropIdx) = 0 ;
	virtual _di_IJclPropInfo __fastcall GetPropNames(const System::UnicodeString Name) = 0 ;
	virtual System::UnicodeString __fastcall GetUnitName(void) = 0 ;
	__property System::TClass ClassRef = {read=GetClassRef};
	__property _di_IJclClassTypeInfo Parent = {read=GetParent};
	__property int TotalPropertyCount = {read=GetTotalPropertyCount};
	__property int PropertyCount = {read=GetPropertyCount};
	__property _di_IJclPropInfo Properties[const int PropIdx] = {read=GetProperties};
	__property _di_IJclPropInfo PropNames[const System::UnicodeString Name] = {read=GetPropNames};
	__property System::UnicodeString UnitName = {read=GetUnitName};
};

class DELPHICLASS TJclClassTypeInfo;
class PASCALIMPLEMENTATION TJclClassTypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName);
	void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value);
	System::TClass __fastcall GetClassRef(void);
	_di_IJclClassTypeInfo __fastcall GetParent(void);
	int __fastcall GetTotalPropertyCount(void);
	int __fastcall GetPropertyCount(void);
	_di_IJclPropInfo __fastcall GetProperties(const int PropIdx);
	_di_IJclPropInfo __fastcall GetPropNames(const System::UnicodeString Name);
	System::UnicodeString __fastcall GetUnitName(void);
	__property System::TClass ClassRef = {read=GetClassRef};
	__property _di_IJclClassTypeInfo Parent = {read=GetParent};
	__property int TotalPropertyCount = {read=GetTotalPropertyCount, nodefault};
	__property int PropertyCount = {read=GetPropertyCount, nodefault};
	__property _di_IJclPropInfo Properties[const int PropIdx] = {read=GetProperties};
	__property _di_IJclPropInfo PropNames[const System::UnicodeString Name] = {read=GetPropNames};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclClassTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClassTypeInfo(void) { }
	
private:
	void *__IJclClassTypeInfo;	/* IJclClassTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclClassTypeInfo()
	{
		_di_IJclClassTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclClassTypeInfo*(void) { return (IJclClassTypeInfo*)&__IJclClassTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclClassTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclClassTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclClassTypeInfo; }
	#endif
	
};


__interface IJclObjClassTypeInfo;
typedef System::DelphiInterface<IJclObjClassTypeInfo> _di_IJclObjClassTypeInfo;
__interface  INTERFACE_UUID("{5BF4383D-7FDD-4494-88CC-849D72B5E142}") IJclObjClassTypeInfo  : public IJclClassTypeInfo 
{
	
public:
	virtual System::TObject* __fastcall GetInstance(void) = 0 ;
	virtual _di_IJclObjPropInfo __fastcall GetObjProperties(const int PropIdx) = 0 ;
	virtual _di_IJclObjPropInfo __fastcall GetObjPropNames(const System::UnicodeString Name) = 0 ;
	HIDESBASE virtual System::UnicodeString __fastcall SaveValueToString(const System::UnicodeString PropName) = 0 /* overload */;
	HIDESBASE virtual void __fastcall LoadValueFromString(const System::UnicodeString PropName, const System::UnicodeString Value) = 0 /* overload */;
	__property System::TObject* Instance = {read=GetInstance};
	__property _di_IJclObjPropInfo ObjProperties[const int PropIdx] = {read=GetObjProperties};
	__property _di_IJclObjPropInfo ObjPropNames[const System::UnicodeString Name] = {read=GetObjPropNames};
};

class DELPHICLASS TJclObjClassTypeInfo;
class PASCALIMPLEMENTATION TJclObjClassTypeInfo : public TJclClassTypeInfo
{
	typedef TJclClassTypeInfo inherited;
	
private:
	System::UnicodeString FPrefix;
	System::TObject* FInstance;
	
public:
	__fastcall TJclObjClassTypeInfo(const Typinfo::PTypeInfo ATypeInfo, const System::UnicodeString APrefix, System::TObject* AInstance);
	System::TObject* __fastcall GetInstance(void);
	_di_IJclObjPropInfo __fastcall GetObjProperties(const int PropIdx);
	_di_IJclObjPropInfo __fastcall GetObjPropNames(const System::UnicodeString Name);
	HIDESBASE System::UnicodeString __fastcall SaveValueToString(const System::UnicodeString PropName)/* overload */;
	HIDESBASE void __fastcall LoadValueFromString(const System::UnicodeString PropName, const System::UnicodeString Value)/* overload */;
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclObjClassTypeInfo(void) { }
	
private:
	void *__IJclObjClassTypeInfo;	/* IJclObjClassTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclObjClassTypeInfo()
	{
		_di_IJclObjClassTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclObjClassTypeInfo*(void) { return (IJclObjClassTypeInfo*)&__IJclObjClassTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclClassTypeInfo()
	{
		_di_IJclClassTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclClassTypeInfo*(void) { return (IJclClassTypeInfo*)&__IJclObjClassTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclObjClassTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclObjClassTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclObjClassTypeInfo; }
	#endif
	
};


__interface IJclEventParamInfo;
typedef System::DelphiInterface<IJclEventParamInfo> _di_IJclEventParamInfo;
__interface  INTERFACE_UUID("{7DAD5229-46EA-11D5-B0C0-4854E825F345}") IJclEventParamInfo  : public System::IInterface 
{
	
public:
	virtual Typinfo::TParamFlags __fastcall GetFlags(void) = 0 ;
	virtual System::UnicodeString __fastcall GetName(void) = 0 ;
	virtual int __fastcall GetRecSize(void) = 0 ;
	virtual System::UnicodeString __fastcall GetTypeName(void) = 0 ;
	virtual void * __fastcall GetParam(void) = 0 ;
	__property Typinfo::TParamFlags Flags = {read=GetFlags};
	__property System::UnicodeString Name = {read=GetName};
	__property int RecSize = {read=GetRecSize};
	__property System::UnicodeString TypeName = {read=GetTypeName};
	__property void * Param = {read=GetParam};
};

class DELPHICLASS TJclEventParamInfo;
class PASCALIMPLEMENTATION TJclEventParamInfo : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	void *FParam;
	
public:
	__fastcall TJclEventParamInfo(const void * AParam);
	Typinfo::TParamFlags __fastcall GetFlags(void);
	System::UnicodeString __fastcall GetName(void);
	int __fastcall GetRecSize(void);
	System::UnicodeString __fastcall GetTypeName(void);
	void * __fastcall GetParam(void);
	__property Typinfo::TParamFlags Flags = {read=GetFlags, nodefault};
	__property System::UnicodeString Name = {read=GetName};
	__property int RecSize = {read=GetRecSize, nodefault};
	__property System::UnicodeString TypeName = {read=GetTypeName};
	__property void * Param = {read=GetParam};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclEventParamInfo(void) { }
	
private:
	void *__IJclEventParamInfo;	/* IJclEventParamInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclEventParamInfo()
	{
		_di_IJclEventParamInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEventParamInfo*(void) { return (IJclEventParamInfo*)&__IJclEventParamInfo; }
	#endif
	
};


__interface IJclEventTypeInfo;
typedef System::DelphiInterface<IJclEventTypeInfo> _di_IJclEventTypeInfo;
__interface  INTERFACE_UUID("{7DAD522A-46EA-11D5-B0C0-4854E825F345}") IJclEventTypeInfo  : public IJclTypeInfo 
{
	
public:
	virtual Typinfo::TMethodKind __fastcall GetMethodKind(void) = 0 ;
	virtual int __fastcall GetParameterCount(void) = 0 ;
	virtual _di_IJclEventParamInfo __fastcall GetParameters(const int ParamIdx) = 0 ;
	virtual System::UnicodeString __fastcall GetResultTypeName(void) = 0 ;
	__property Typinfo::TMethodKind MethodKind = {read=GetMethodKind};
	__property int ParameterCount = {read=GetParameterCount};
	__property _di_IJclEventParamInfo Parameters[const int ParamIdx] = {read=GetParameters};
	__property System::UnicodeString ResultTypeName = {read=GetResultTypeName};
};

class DELPHICLASS TJclEventTypeInfo;
class PASCALIMPLEMENTATION TJclEventTypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	Typinfo::TMethodKind __fastcall GetMethodKind(void);
	int __fastcall GetParameterCount(void);
	_di_IJclEventParamInfo __fastcall GetParameters(const int ParamIdx);
	System::UnicodeString __fastcall GetResultTypeName(void);
	__property Typinfo::TMethodKind MethodKind = {read=GetMethodKind, nodefault};
	__property int ParameterCount = {read=GetParameterCount, nodefault};
	__property _di_IJclEventParamInfo Parameters[const int ParamIdx] = {read=GetParameters};
	__property System::UnicodeString ResultTypeName = {read=GetResultTypeName};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclEventTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclEventTypeInfo(void) { }
	
private:
	void *__IJclEventTypeInfo;	/* IJclEventTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclEventTypeInfo()
	{
		_di_IJclEventTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEventTypeInfo*(void) { return (IJclEventTypeInfo*)&__IJclEventTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclEventTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclEventTypeInfo; }
	#endif
	
};


__interface IJclInterfaceTypeInfo;
typedef System::DelphiInterface<IJclInterfaceTypeInfo> _di_IJclInterfaceTypeInfo;
__interface  INTERFACE_UUID("{7DAD522B-46EA-11D5-B0C0-4854E825F345}") IJclInterfaceTypeInfo  : public IJclTypeInfo 
{
	
public:
	virtual _di_IJclInterfaceTypeInfo __fastcall GetParent(void) = 0 ;
	virtual TIntfFlagsBase __fastcall GetFlags(void) = 0 ;
	virtual GUID __fastcall GetGUID(void) = 0 ;
	virtual int __fastcall GetPropertyCount(void) = 0 ;
	virtual System::UnicodeString __fastcall GetUnitName(void) = 0 ;
	__property _di_IJclInterfaceTypeInfo Parent = {read=GetParent};
	__property TIntfFlagsBase Flags = {read=GetFlags};
	__property GUID GUID = {read=GetGUID};
	__property int PropertyCount = {read=GetPropertyCount};
	__property System::UnicodeString UnitName = {read=GetUnitName};
};

class DELPHICLASS TJclInterfaceTypeInfo;
class PASCALIMPLEMENTATION TJclInterfaceTypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	_di_IJclInterfaceTypeInfo __fastcall GetParent(void);
	TIntfFlagsBase __fastcall GetFlags(void);
	GUID __fastcall GetGUID(void);
	int __fastcall GetPropertyCount(void);
	System::UnicodeString __fastcall GetUnitName(void);
	__property _di_IJclInterfaceTypeInfo Parent = {read=GetParent};
	__property TIntfFlagsBase Flags = {read=GetFlags, nodefault};
	__property GUID GUID = {read=GetGUID};
	__property int PropertyCount = {read=GetPropertyCount, nodefault};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclInterfaceTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInterfaceTypeInfo(void) { }
	
private:
	void *__IJclInterfaceTypeInfo;	/* IJclInterfaceTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclInterfaceTypeInfo()
	{
		_di_IJclInterfaceTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInterfaceTypeInfo*(void) { return (IJclInterfaceTypeInfo*)&__IJclInterfaceTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclInterfaceTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclInterfaceTypeInfo; }
	#endif
	
};


__interface IJclInt64TypeInfo;
typedef System::DelphiInterface<IJclInt64TypeInfo> _di_IJclInt64TypeInfo;
__interface  INTERFACE_UUID("{7DAD522C-46EA-11D5-B0C0-4854E825F345}") IJclInt64TypeInfo  : public IJclValueTypeInfo 
{
	
public:
	virtual __int64 __fastcall GetMinValue(void) = 0 ;
	virtual __int64 __fastcall GetMaxValue(void) = 0 ;
	__property __int64 MinValue = {read=GetMinValue};
	__property __int64 MaxValue = {read=GetMaxValue};
};

class DELPHICLASS TJclInt64TypeInfo;
class PASCALIMPLEMENTATION TJclInt64TypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	System::UnicodeString __fastcall SaveValueToString(System::TObject* AnObj, const System::UnicodeString PropName);
	void __fastcall LoadValueFromString(System::TObject* AnObj, const System::UnicodeString PropName, const System::UnicodeString Value);
	__int64 __fastcall GetMinValue(void);
	__int64 __fastcall GetMaxValue(void);
	__property __int64 MinValue = {read=GetMinValue};
	__property __int64 MaxValue = {read=GetMaxValue};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclInt64TypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInt64TypeInfo(void) { }
	
private:
	void *__IJclInt64TypeInfo;	/* IJclInt64TypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclInt64TypeInfo()
	{
		_di_IJclInt64TypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TypeInfo*(void) { return (IJclInt64TypeInfo*)&__IJclInt64TypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclValueTypeInfo()
	{
		_di_IJclValueTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueTypeInfo*(void) { return (IJclValueTypeInfo*)&__IJclInt64TypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclInt64TypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclInt64TypeInfo; }
	#endif
	
};


__interface IJclDynArrayTypeInfo;
typedef System::DelphiInterface<IJclDynArrayTypeInfo> _di_IJclDynArrayTypeInfo;
__interface  INTERFACE_UUID("{7DAD522E-46EA-11D5-B0C0-4854E825F345}") IJclDynArrayTypeInfo  : public IJclTypeInfo 
{
	
public:
	virtual int __fastcall GetElementSize(void) = 0 ;
	virtual _di_IJclTypeInfo __fastcall GetElementType(void) = 0 ;
	virtual bool __fastcall GetElementsNeedCleanup(void) = 0 ;
	virtual int __fastcall GetVarType(void) = 0 ;
	virtual System::UnicodeString __fastcall GetUnitName(void) = 0 ;
	__property int ElementSize = {read=GetElementSize};
	__property _di_IJclTypeInfo ElementType = {read=GetElementType};
	__property bool ElementsNeedCleanup = {read=GetElementsNeedCleanup};
	__property int VarType = {read=GetVarType};
	__property System::UnicodeString UnitName = {read=GetUnitName};
};

class DELPHICLASS TJclDynArrayTypeInfo;
class PASCALIMPLEMENTATION TJclDynArrayTypeInfo : public TJclTypeInfo
{
	typedef TJclTypeInfo inherited;
	
public:
	virtual void __fastcall WriteTo(const _di_IJclInfoWriter Dest);
	virtual void __fastcall DeclarationTo(const _di_IJclInfoWriter Dest);
	int __fastcall GetElementSize(void);
	_di_IJclTypeInfo __fastcall GetElementType(void);
	bool __fastcall GetElementsNeedCleanup(void);
	int __fastcall GetVarType(void);
	System::UnicodeString __fastcall GetUnitName(void);
	__property int ElementSize = {read=GetElementSize, nodefault};
	__property _di_IJclTypeInfo ElementType = {read=GetElementType};
	__property bool ElementsNeedCleanup = {read=GetElementsNeedCleanup, nodefault};
	__property int VarType = {read=GetVarType, nodefault};
public:
	/* TJclTypeInfo.Create */ inline __fastcall TJclDynArrayTypeInfo(Typinfo::PTypeInfo ATypeInfo) : TJclTypeInfo(ATypeInfo) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDynArrayTypeInfo(void) { }
	
private:
	void *__IJclDynArrayTypeInfo;	/* IJclDynArrayTypeInfo */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclDynArrayTypeInfo()
	{
		_di_IJclDynArrayTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDynArrayTypeInfo*(void) { return (IJclDynArrayTypeInfo*)&__IJclDynArrayTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclTypeInfo()
	{
		_di_IJclTypeInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTypeInfo*(void) { return (IJclTypeInfo*)&__IJclDynArrayTypeInfo; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclBaseInfo()
	{
		_di_IJclBaseInfo intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseInfo*(void) { return (IJclBaseInfo*)&__IJclDynArrayTypeInfo; }
	#endif
	
};


class DELPHICLASS EJclRTTIError;
class PASCALIMPLEMENTATION EJclRTTIError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclRTTIError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclRTTIError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclRTTIError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclRTTIError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclRTTIError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclRTTIError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclRTTIError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclRTTIError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclRTTIError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const Byte PREFIX_CUT_LOWERCASE = 0xff;
static const Byte PREFIX_CUT_EQUAL = 0xfe;
static const Byte MaxPrefixCut = 0xfa;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE _di_IJclTypeInfo __fastcall JclTypeInfo(Typinfo::PTypeInfo ATypeInfo);
extern PACKAGE void __fastcall RemoveTypeInfo(Typinfo::PTypeInfo TypeInfo);
extern PACKAGE System::UnicodeString __fastcall JclEnumValueToIdent(Typinfo::PTypeInfo TypeInfo, const void *Value);
extern PACKAGE Typinfo::PTypeInfo __fastcall JclGenerateEnumType(const System::ShortString &TypeName, System::UnicodeString const *Literals, const int Literals_Size);
extern PACKAGE Typinfo::PTypeInfo __fastcall JclGenerateEnumTypeBasedOn(const System::ShortString &TypeName, Typinfo::PTypeInfo BaseType, const System::Byte PrefixCut);
extern PACKAGE Typinfo::PTypeInfo __fastcall JclGenerateSubRange(Typinfo::PTypeInfo BaseType, const System::UnicodeString TypeName, const int MinValue, const int MaxValue);
extern PACKAGE int __fastcall JclStrToTypedInt(System::UnicodeString Value, Typinfo::PTypeInfo TypeInfo);
extern PACKAGE System::UnicodeString __fastcall JclTypedIntToStr(int Value, Typinfo::PTypeInfo TypeInfo);
extern PACKAGE System::UnicodeString __fastcall JclSetToList(Typinfo::PTypeInfo TypeInfo, const void *Value, const bool WantBrackets, const bool WantRanges, const Classes::TStrings* Strings);
extern PACKAGE System::UnicodeString __fastcall JclSetToStr(Typinfo::PTypeInfo TypeInfo, const void *Value, const bool WantBrackets = false, const bool WantRanges = false);
extern PACKAGE void __fastcall JclStrToSet(Typinfo::PTypeInfo TypeInfo, void *SetVar, const System::UnicodeString Value);
extern PACKAGE void __fastcall JclIntToSet(Typinfo::PTypeInfo TypeInfo, void *SetVar, const int Value);
extern PACKAGE int __fastcall JclSetToInt(Typinfo::PTypeInfo TypeInfo, const void *SetVar);
extern PACKAGE Typinfo::PTypeInfo __fastcall JclGenerateSetType(Typinfo::PTypeInfo BaseType, const System::ShortString &TypeName);
extern PACKAGE bool __fastcall JclIsClass(const System::TObject* AnObj, const System::TClass AClass);
extern PACKAGE bool __fastcall JclIsClassByName(const System::TObject* AnObj, const System::TClass AClass);
extern PACKAGE int __fastcall GetStringPropList(Typinfo::PTypeInfo TypeInfo, /* out */ Typinfo::PPropList &PropList);
extern PACKAGE IJclObjPropInfoArray __fastcall GetObjectProperties(System::TObject* AnObj, bool Recurse = false);

}	/* namespace Jclrtti */
using namespace Jclrtti;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclrttiHPP
