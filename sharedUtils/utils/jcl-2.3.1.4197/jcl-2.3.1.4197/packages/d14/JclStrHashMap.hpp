// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclstrhashmap.pas' rev: 21.00

#ifndef JclstrhashmapHPP
#define JclstrhashmapHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclresources.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclstrhashmap
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclStringHashMapError;
class PASCALIMPLEMENTATION EJclStringHashMapError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclStringHashMapError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclStringHashMapError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclStringHashMapError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclStringHashMapError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclStringHashMapError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclStringHashMapError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclStringHashMapError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclStringHashMapError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclStringHashMapError(void) { }
	
};


typedef unsigned THashValue;

class DELPHICLASS TStringHashMapTraits;
class PASCALIMPLEMENTATION TStringHashMapTraits : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	virtual unsigned __fastcall Hash(const System::UnicodeString S) = 0 ;
	virtual int __fastcall Compare(const System::UnicodeString L, const System::UnicodeString R) = 0 ;
public:
	/* TObject.Create */ inline __fastcall TStringHashMapTraits(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TStringHashMapTraits(void) { }
	
};


typedef void * PUserData;

typedef void * PData;

typedef bool __fastcall (*TIterateFunc)(void * AUserData, const System::UnicodeString AStr, void * &APtr);

typedef bool __fastcall (__closure *TIterateMethod)(void * AUserData, const System::UnicodeString AStr, void * &APtr);

struct THashNode;
typedef THashNode *PHashNode;

typedef PHashNode *PPHashNode;

struct THashNode
{
	
public:
	System::UnicodeString Str;
	void *Ptr;
	THashNode *Left;
	THashNode *Right;
};


typedef void __fastcall (*TNodeIterateFunc)(void * AUserData, PPHashNode ANode);

typedef StaticArray<PHashNode, 536870911> THashArray;

typedef THashArray *PHashArray;

class DELPHICLASS TStringHashMap;
class PASCALIMPLEMENTATION TStringHashMap : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	void * operator[](const System::UnicodeString S) { return Data[S]; }
	
private:
	unsigned FHashSize;
	unsigned FCount;
	THashArray *FList;
	bool FLeftDelete;
	TStringHashMapTraits* FTraits;
	bool __fastcall IterateNode(PHashNode ANode, void * AUserData, TIterateFunc AIterateFunc);
	bool __fastcall IterateMethodNode(PHashNode ANode, void * AUserData, TIterateMethod AIterateMethod);
	void __fastcall NodeIterate(PPHashNode ANode, void * AUserData, TNodeIterateFunc AIterateFunc);
	void __fastcall SetHashSize(unsigned AHashSize);
	void __fastcall DeleteNodes(PHashNode &Q);
	void __fastcall DeleteNode(PHashNode &Q);
	
protected:
	PPHashNode __fastcall FindNode(const System::UnicodeString S);
	virtual PHashNode __fastcall AllocNode(void);
	virtual void __fastcall FreeNode(PHashNode ANode);
	void * __fastcall GetData(const System::UnicodeString S);
	void __fastcall SetData(const System::UnicodeString S, void * P);
	
public:
	__fastcall TStringHashMap(TStringHashMapTraits* ATraits, unsigned AHashSize);
	__fastcall virtual ~TStringHashMap(void);
	void __fastcall Add(const System::UnicodeString S, const void *P);
	void * __fastcall Remove(const System::UnicodeString S);
	void __fastcall RemoveData(const void *P);
	void __fastcall Iterate(void * AUserData, TIterateFunc AIterateFunc);
	void __fastcall IterateMethod(void * AUserData, TIterateMethod AIterateMethod);
	bool __fastcall Has(const System::UnicodeString S);
	bool __fastcall Find(const System::UnicodeString S, void *P);
	bool __fastcall FindData(const void *P, System::UnicodeString &S);
	void __fastcall Clear(void);
	__property unsigned Count = {read=FCount, nodefault};
	__property void * Data[const System::UnicodeString S] = {read=GetData, write=SetData/*, default*/};
	__property TStringHashMapTraits* Traits = {read=FTraits};
	__property unsigned HashSize = {read=FHashSize, write=SetHashSize, nodefault};
};


class DELPHICLASS TCaseSensitiveTraits;
class PASCALIMPLEMENTATION TCaseSensitiveTraits : public TStringHashMapTraits
{
	typedef TStringHashMapTraits inherited;
	
public:
	virtual unsigned __fastcall Hash(const System::UnicodeString S);
	virtual int __fastcall Compare(const System::UnicodeString L, const System::UnicodeString R);
public:
	/* TObject.Create */ inline __fastcall TCaseSensitiveTraits(void) : TStringHashMapTraits() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TCaseSensitiveTraits(void) { }
	
};


class DELPHICLASS TCaseInsensitiveTraits;
class PASCALIMPLEMENTATION TCaseInsensitiveTraits : public TStringHashMapTraits
{
	typedef TStringHashMapTraits inherited;
	
public:
	virtual unsigned __fastcall Hash(const System::UnicodeString S);
	virtual int __fastcall Compare(const System::UnicodeString L, const System::UnicodeString R);
public:
	/* TObject.Create */ inline __fastcall TCaseInsensitiveTraits(void) : TStringHashMapTraits() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TCaseInsensitiveTraits(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE TStringHashMapTraits* __fastcall CaseSensitiveTraits(void);
extern PACKAGE TStringHashMapTraits* __fastcall CaseInsensitiveTraits(void);
extern PACKAGE bool __fastcall Iterate_FreeObjects(void * AUserData, const System::UnicodeString AStr, void * &AData);
extern PACKAGE bool __fastcall Iterate_Dispose(void * AUserData, const System::UnicodeString AStr, void * &AData);
extern PACKAGE bool __fastcall Iterate_FreeMem(void * AUserData, const System::UnicodeString AStr, void * &AData);
extern PACKAGE unsigned __fastcall StrHash(const System::UnicodeString S);
extern PACKAGE unsigned __fastcall TextHash(const System::UnicodeString S);
extern PACKAGE unsigned __fastcall DataHash(void *AValue, unsigned ASize);

}	/* namespace Jclstrhashmap */
using namespace Jclstrhashmap;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclstrhashmapHPP
