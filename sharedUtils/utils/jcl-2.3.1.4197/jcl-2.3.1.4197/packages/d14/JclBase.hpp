// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclbase.pas' rev: 21.00

#ifndef JclbaseHPP
#define JclbaseHPP

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

//-- user supplied -----------------------------------------------------------

namespace Jclbase
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclError;
class PASCALIMPLEMENTATION EJclError : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclError(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclError(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclError(void) { }
	
};


class DELPHICLASS EJclInternalError;
class PASCALIMPLEMENTATION EJclInternalError : public EJclError
{
	typedef EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclInternalError(const System::UnicodeString Msg) : EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclInternalError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclInternalError(int Ident)/* overload */ : EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclInternalError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclInternalError(const System::UnicodeString Msg, int AHelpContext) : EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclInternalError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclInternalError(int Ident, int AHelpContext)/* overload */ : EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclInternalError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclInternalError(void) { }
	
};


typedef System::Extended Float;

typedef System::Extended *PFloat;

typedef int SizeInt;

typedef int *PSizeInt;

typedef void * *PPointer;

typedef System::PByte PByte;

typedef System::ShortInt Int8;

typedef short Int16;

typedef int Int32;

typedef System::Byte UInt8;

typedef System::Word UInt16;

typedef unsigned UInt32;

typedef unsigned *PCardinal;

typedef System::WideChar * PWideChar;

typedef System::WideChar * *PPWideChar;

typedef char * *PPAnsiChar;

typedef __int64 *PInt64;

typedef PInt64 *PPInt64;

typedef PPAnsiChar *PPPAnsiChar;

typedef __int64 *PLargeInteger;

typedef __int64 TLargeInteger;

typedef StaticArray<System::Byte, 2147483647> TJclByteArray;

typedef TJclByteArray *PJclByteArray;

typedef void * TJclBytes;

typedef ULARGE_INTEGER TJclULargeInteger;

typedef PULARGE_INTEGER PJclULargeInteger;

typedef DynamicArray<System::Byte> TDynByteArray;

typedef DynamicArray<System::ShortInt> TDynShortIntArray;

typedef DynamicArray<System::Word> TDynWordArray;

typedef DynamicArray<short> TDynSmallIntArray;

typedef DynamicArray<int> TDynLongIntArray;

typedef DynamicArray<__int64> TDynInt64Array;

typedef DynamicArray<unsigned> TDynCardinalArray;

typedef DynamicArray<int> TDynIntegerArray;

typedef DynamicArray<int> TDynSizeIntArray;

typedef DynamicArray<System::Extended> TDynExtendedArray;

typedef DynamicArray<double> TDynDoubleArray;

typedef DynamicArray<float> TDynSingleArray;

typedef DynamicArray<System::Extended> TDynFloatArray;

typedef DynamicArray<void *> TDynPointerArray;

typedef DynamicArray<System::UnicodeString> TDynStringArray;

typedef DynamicArray<System::AnsiString> TDynAnsiStringArray;

typedef DynamicArray<System::WideString> TDynWideStringArray;

typedef DynamicArray<System::UnicodeString> TDynUnicodeStringArray;

typedef DynamicArray<System::_di_IInterface> TDynIInterfaceArray;

typedef DynamicArray<System::TObject*> TDynObjectArray;

typedef DynamicArray<System::WideChar> TDynCharArray;

typedef DynamicArray<char> TDynAnsiCharArray;

typedef DynamicArray<System::WideChar> TDynWideCharArray;

typedef char *PUTF7;

typedef char UTF7;

typedef char *PUTF8;

typedef char UTF8;

typedef System::WideChar *PUTF16;

typedef System::WideChar UTF16;

typedef unsigned *PUTF32;

typedef unsigned UTF32;

typedef unsigned *PUCS4;

typedef unsigned UCS4;

typedef System::WideChar * PUCS2;

typedef System::WideChar UCS2;

typedef DynamicArray<System::WideChar> TUCS2Array;

typedef DynamicArray<unsigned> TUCS4Array;

typedef System::AnsiString TUTF8String;

typedef System::WideString TUTF16String;

typedef System::WideString TUCS2String;

typedef Set<char, 0, 255>  TSetOfAnsiChar;

typedef unsigned TJclAddr32;

typedef __int64 TJclAddr64;

typedef unsigned TJclAddr;

typedef unsigned *PJclAddr;

class DELPHICLASS EJclAddr64Exception;
class PASCALIMPLEMENTATION EJclAddr64Exception : public EJclError
{
	typedef EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclAddr64Exception(const System::UnicodeString Msg) : EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclAddr64Exception(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclAddr64Exception(int Ident)/* overload */ : EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclAddr64Exception(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclAddr64Exception(const System::UnicodeString Msg, int AHelpContext) : EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclAddr64Exception(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclAddr64Exception(int Ident, int AHelpContext)/* overload */ : EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclAddr64Exception(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclAddr64Exception(void) { }
	
};



#define _decl_TCompare__1(T, _DECLNAME) int __fastcall (*_DECLNAME)(const T Obj1, const T Obj2)
// typedef template<typename T> int __fastcall (*TCompare__1)(const T Obj1, const T Obj2);


#define _decl_TEqualityCompare__1(T, _DECLNAME) bool __fastcall (*_DECLNAME)(const T Obj1, const T Obj2)
// typedef template<typename T> bool __fastcall (*TEqualityCompare__1)(const T Obj1, const T Obj2);


#define _decl_THashConvert__1(T, _DECLNAME) int __fastcall (*_DECLNAME)(const T AItem)
// typedef template<typename T> int __fastcall (*THashConvert__1)(const T AItem);

template<typename T> __interface IEqualityComparer__1;
// template<typename T> typedef System::DelphiInterface<IEqualityComparer__1<T> > _di_IEqualityComparer__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> __interface IEqualityComparer__1  : public System::IInterface 
{
	
public:
	virtual bool __fastcall Equals(T A, T B) = 0 ;
	virtual int __fastcall GetHashCode(T Obj) = 0 ;
};

template<typename T> class DELPHICLASS TEquatable__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TEquatable__1 : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
public:
	bool __fastcall TestEquals(T Other)/* overload */;
	bool __fastcall TestEquals(T A, T B)/* overload */;
	int __fastcall GetHashCode2(T Obj);
public:
	/* TObject.Create */ inline __fastcall TEquatable__1(void) : System::TInterfacedObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TEquatable__1(void) { }
	
private:
	void *__IEqualityComparer__1;	/* IEqualityComparer__1<T> */
	void *__IEquatable__1;	/* System::IEquatable__1<T> */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<IEqualityComparer__1<T> >()
	{
		System::DelphiInterface<IEqualityComparer__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IEqualityComparer__1<T>*(void) { return (IEqualityComparer__1<T>*)&__IEqualityComparer__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<System::IEquatable__1<T> >()
	{
		System::DelphiInterface<System::IEquatable__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IEquatable__1<T>*(void) { return (IEquatable__1<T>*)&__IEquatable__1; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt JclVersionMajor = 0x2;
static const ShortInt JclVersionMinor = 0x3;
static const ShortInt JclVersionRelease = 0x1;
static const Word JclVersionBuild = 0x1065;
static const int JclVersion = 0x2039065;
static const System::WideChar NativeLineFeed = (System::WideChar)(0xa);
static const System::WideChar NativeCarriageReturn = (System::WideChar)(0xd);
#define NativeCrLf L"\r\n"
#define NativeLineBreak L"\r\n"
#define HexPrefixPascal L"$"
#define HexPrefixC L"0x"
#define HexPrefix L"0x"
extern PACKAGE StaticArray<System::Byte, 2> BOM_UTF16_LSB;
extern PACKAGE StaticArray<System::Byte, 2> BOM_UTF16_MSB;
extern PACKAGE StaticArray<System::Byte, 3> BOM_UTF8;
extern PACKAGE StaticArray<System::Byte, 4> BOM_UTF32_LSB;
extern PACKAGE StaticArray<System::Byte, 4> BOM_UTF32_MSB;
extern PACKAGE char AnsiReplacementCharacter;
extern PACKAGE unsigned UCS4ReplacementCharacter;
extern PACKAGE unsigned MaximumUCS2;
extern PACKAGE unsigned MaximumUTF16;
extern PACKAGE unsigned MaximumUCS4;
static const unsigned SurrogateHighStart = 0xd800;
static const unsigned SurrogateHighEnd = 0xdbff;
static const unsigned SurrogateLowStart = 0xdc00;
static const unsigned SurrogateLowEnd = 0xdfff;
static const WideChar AWSuffix = (WideChar)(0x57);
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall MoveChar(const System::UnicodeString Source, int FromIndex, System::UnicodeString &Dest, int ToIndex, int Count)/* overload */;
extern PACKAGE int __fastcall AnsiByteArrayStringLen(Sysutils::TBytes Data);
extern PACKAGE Sysutils::TBytes __fastcall StringToAnsiByteArray(const System::UnicodeString S);
extern PACKAGE System::UnicodeString __fastcall AnsiByteArrayToString(const Sysutils::TBytes Data, int Count);
extern PACKAGE Sysutils::TBytes __fastcall BytesOf(const System::AnsiString Value)/* overload */;
extern PACKAGE Sysutils::TBytes __fastcall BytesOf(const System::WideString Value)/* overload */;
extern PACKAGE Sysutils::TBytes __fastcall BytesOf(const System::WideChar Value)/* overload */;
extern PACKAGE Sysutils::TBytes __fastcall BytesOf(const char Value)/* overload */;
extern PACKAGE System::AnsiString __fastcall StringOf(System::Byte const *Bytes, const int Bytes_Size)/* overload */;
extern PACKAGE System::AnsiString __fastcall StringOf(const void * Bytes, unsigned Size)/* overload */;
extern PACKAGE void __fastcall I64ToCardinals(__int64 I, /* out */ unsigned &LowPart, /* out */ unsigned &HighPart);
extern PACKAGE void __fastcall CardinalsToI64(/* out */ __int64 &I, const unsigned LowPart, const unsigned HighPart);
extern PACKAGE unsigned __fastcall Addr64ToAddr32(const __int64 Value);
extern PACKAGE __int64 __fastcall Addr32ToAddr64(const unsigned Value);

}	/* namespace Jclbase */
using namespace Jclbase;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclbaseHPP
