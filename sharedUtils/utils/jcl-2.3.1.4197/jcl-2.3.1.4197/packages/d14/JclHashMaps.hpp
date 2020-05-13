// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclhashmaps.pas' rev: 21.00

#ifndef JclhashmapsHPP
#define JclhashmapsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclalgorithms.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclabstractcontainers.hpp>	// Pascal unit
#include <Jclarraylists.hpp>	// Pascal unit
#include <Jclarraysets.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclhashmaps
{
//-- type declarations -------------------------------------------------------
typedef int __fastcall (*TJclHashFunction)(int Key, int Range);

struct TJclIntfIntfHashEntry
{
	
public:
	System::_di_IInterface Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclIntfIntfBucket;
class PASCALIMPLEMENTATION TJclIntfIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfIntfHashEntry> _TJclIntfIntfBucket__1;
	
	
public:
	int Size;
	_TJclIntfIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfIntfBucket(void) { }
	
};


class DELPHICLASS TJclIntfIntfHashMap;
class PASCALIMPLEMENTATION TJclIntfIntfHashMap : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfIntfBucket*> _TJclIntfIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclIntfIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const System::_di_IInterface Key);
	System::_di_IInterface __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfIntfMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclIntfIntfMap;	/* Jclcontainerintf::IJclIntfIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIntfMap()
	{
		Jclcontainerintf::_di_IJclIntfIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIntfMap*(void) { return (IJclIntfIntfMap*)&__IJclIntfIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfIntfMap; }
	#endif
	
};


struct TJclAnsiStrIntfHashEntry
{
	
public:
	System::AnsiString Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclAnsiStrIntfBucket;
class PASCALIMPLEMENTATION TJclAnsiStrIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrIntfHashEntry> _TJclAnsiStrIntfBucket__1;
	
	
public:
	int Size;
	_TJclAnsiStrIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclAnsiStrIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAnsiStrIntfBucket(void) { }
	
};


class DELPHICLASS TJclAnsiStrIntfHashMap;
class PASCALIMPLEMENTATION TJclAnsiStrIntfHashMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrIntfBucket*> _TJclAnsiStrIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::AnsiString __fastcall FreeKey(System::AnsiString &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const System::AnsiString A, const System::AnsiString B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclAnsiStrIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclAnsiStrIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::AnsiString Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const System::AnsiString Key);
	System::_di_IInterface __fastcall GetValue(const System::AnsiString Key);
	bool __fastcall IsEmpty(void);
	System::AnsiString __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclAnsiStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclAnsiStrIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclAnsiStrIntfMap AMap);
	void __fastcall PutValue(const System::AnsiString Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const System::AnsiString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclAnsiStrIntfMap;	/* Jclcontainerintf::IJclAnsiStrIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIntfMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIntfMap*(void) { return (IJclAnsiStrIntfMap*)&__IJclAnsiStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrIntfMap; }
	#endif
	
};


struct TJclIntfAnsiStrHashEntry
{
	
public:
	System::_di_IInterface Key;
	System::AnsiString Value;
};


class DELPHICLASS TJclIntfAnsiStrBucket;
class PASCALIMPLEMENTATION TJclIntfAnsiStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfAnsiStrHashEntry> _TJclIntfAnsiStrBucket__1;
	
	
public:
	int Size;
	_TJclIntfAnsiStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfAnsiStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfAnsiStrBucket(void) { }
	
};


class DELPHICLASS TJclIntfAnsiStrHashMap;
class PASCALIMPLEMENTATION TJclIntfAnsiStrHashMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfAnsiStrBucket*> _TJclIntfAnsiStrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::AnsiString __fastcall FreeValue(System::AnsiString &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const System::AnsiString A, const System::AnsiString B);
	
private:
	_TJclIntfAnsiStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfAnsiStrHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfAnsiStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const System::AnsiString Value);
	System::AnsiString __fastcall Extract(const System::_di_IInterface Key);
	System::AnsiString __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const System::AnsiString Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfAnsiStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfAnsiStrMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const System::AnsiString Value);
	System::AnsiString __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclAnsiStrCollection __fastcall Values(void);
private:
	void *__IJclIntfAnsiStrMap;	/* Jclcontainerintf::IJclIntfAnsiStrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfAnsiStrMap()
	{
		Jclcontainerintf::_di_IJclIntfAnsiStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfAnsiStrMap*(void) { return (IJclIntfAnsiStrMap*)&__IJclIntfAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclIntfAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclIntfAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfAnsiStrMap; }
	#endif
	
};


struct TJclAnsiStrAnsiStrHashEntry
{
	
public:
	System::AnsiString Key;
	System::AnsiString Value;
};


class DELPHICLASS TJclAnsiStrAnsiStrBucket;
class PASCALIMPLEMENTATION TJclAnsiStrAnsiStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrAnsiStrHashEntry> _TJclAnsiStrAnsiStrBucket__1;
	
	
public:
	int Size;
	_TJclAnsiStrAnsiStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclAnsiStrAnsiStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAnsiStrAnsiStrBucket(void) { }
	
};


class DELPHICLASS TJclAnsiStrAnsiStrHashMap;
class PASCALIMPLEMENTATION TJclAnsiStrAnsiStrHashMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrAnsiStrBucket*> _TJclAnsiStrAnsiStrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::AnsiString __fastcall FreeKey(System::AnsiString &Key);
	System::AnsiString __fastcall FreeValue(System::AnsiString &Value);
	bool __fastcall KeysEqual(const System::AnsiString A, const System::AnsiString B);
	bool __fastcall ValuesEqual(const System::AnsiString A, const System::AnsiString B);
	
private:
	_TJclAnsiStrAnsiStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrAnsiStrHashMap(int ACapacity);
	__fastcall virtual ~TJclAnsiStrAnsiStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::AnsiString Key);
	bool __fastcall ContainsValue(const System::AnsiString Value);
	System::AnsiString __fastcall Extract(const System::AnsiString Key);
	System::AnsiString __fastcall GetValue(const System::AnsiString Key);
	bool __fastcall IsEmpty(void);
	System::AnsiString __fastcall KeyOfValue(const System::AnsiString Value);
	Jclcontainerintf::_di_IJclAnsiStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclAnsiStrAnsiStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclAnsiStrAnsiStrMap AMap);
	void __fastcall PutValue(const System::AnsiString Key, const System::AnsiString Value);
	System::AnsiString __fastcall Remove(const System::AnsiString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclAnsiStrCollection __fastcall Values(void);
private:
	void *__IJclAnsiStrAnsiStrMap;	/* Jclcontainerintf::IJclAnsiStrAnsiStrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrAnsiStrMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrAnsiStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrAnsiStrMap*(void) { return (IJclAnsiStrAnsiStrMap*)&__IJclAnsiStrAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrAnsiStrMap; }
	#endif
	
};


struct TJclWideStrIntfHashEntry
{
	
public:
	System::WideString Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclWideStrIntfBucket;
class PASCALIMPLEMENTATION TJclWideStrIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclWideStrIntfHashEntry> _TJclWideStrIntfBucket__1;
	
	
public:
	int Size;
	_TJclWideStrIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclWideStrIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclWideStrIntfBucket(void) { }
	
};


class DELPHICLASS TJclWideStrIntfHashMap;
class PASCALIMPLEMENTATION TJclWideStrIntfHashMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclWideStrIntfBucket*> _TJclWideStrIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::WideString __fastcall FreeKey(System::WideString &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const System::WideString A, const System::WideString B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclWideStrIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclWideStrIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::WideString Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const System::WideString Key);
	System::_di_IInterface __fastcall GetValue(const System::WideString Key);
	bool __fastcall IsEmpty(void);
	System::WideString __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclWideStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclWideStrIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclWideStrIntfMap AMap);
	void __fastcall PutValue(const System::WideString Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const System::WideString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclWideStrIntfMap;	/* Jclcontainerintf::IJclWideStrIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIntfMap()
	{
		Jclcontainerintf::_di_IJclWideStrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIntfMap*(void) { return (IJclWideStrIntfMap*)&__IJclWideStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrIntfMap; }
	#endif
	
};


struct TJclIntfWideStrHashEntry
{
	
public:
	System::_di_IInterface Key;
	System::WideString Value;
};


class DELPHICLASS TJclIntfWideStrBucket;
class PASCALIMPLEMENTATION TJclIntfWideStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfWideStrHashEntry> _TJclIntfWideStrBucket__1;
	
	
public:
	int Size;
	_TJclIntfWideStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfWideStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfWideStrBucket(void) { }
	
};


class DELPHICLASS TJclIntfWideStrHashMap;
class PASCALIMPLEMENTATION TJclIntfWideStrHashMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfWideStrBucket*> _TJclIntfWideStrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::WideString __fastcall FreeValue(System::WideString &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const System::WideString A, const System::WideString B);
	
private:
	_TJclIntfWideStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfWideStrHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfWideStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const System::WideString Value);
	System::WideString __fastcall Extract(const System::_di_IInterface Key);
	System::WideString __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const System::WideString Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfWideStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfWideStrMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const System::WideString Value);
	System::WideString __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclWideStrCollection __fastcall Values(void);
private:
	void *__IJclIntfWideStrMap;	/* Jclcontainerintf::IJclIntfWideStrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfWideStrMap()
	{
		Jclcontainerintf::_di_IJclIntfWideStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfWideStrMap*(void) { return (IJclIntfWideStrMap*)&__IJclIntfWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclIntfWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclIntfWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfWideStrMap; }
	#endif
	
};


struct TJclWideStrWideStrHashEntry
{
	
public:
	System::WideString Key;
	System::WideString Value;
};


class DELPHICLASS TJclWideStrWideStrBucket;
class PASCALIMPLEMENTATION TJclWideStrWideStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclWideStrWideStrHashEntry> _TJclWideStrWideStrBucket__1;
	
	
public:
	int Size;
	_TJclWideStrWideStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclWideStrWideStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclWideStrWideStrBucket(void) { }
	
};


class DELPHICLASS TJclWideStrWideStrHashMap;
class PASCALIMPLEMENTATION TJclWideStrWideStrHashMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclWideStrWideStrBucket*> _TJclWideStrWideStrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::WideString __fastcall FreeKey(System::WideString &Key);
	System::WideString __fastcall FreeValue(System::WideString &Value);
	bool __fastcall KeysEqual(const System::WideString A, const System::WideString B);
	bool __fastcall ValuesEqual(const System::WideString A, const System::WideString B);
	
private:
	_TJclWideStrWideStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrWideStrHashMap(int ACapacity);
	__fastcall virtual ~TJclWideStrWideStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::WideString Key);
	bool __fastcall ContainsValue(const System::WideString Value);
	System::WideString __fastcall Extract(const System::WideString Key);
	System::WideString __fastcall GetValue(const System::WideString Key);
	bool __fastcall IsEmpty(void);
	System::WideString __fastcall KeyOfValue(const System::WideString Value);
	Jclcontainerintf::_di_IJclWideStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclWideStrWideStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclWideStrWideStrMap AMap);
	void __fastcall PutValue(const System::WideString Key, const System::WideString Value);
	System::WideString __fastcall Remove(const System::WideString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclWideStrCollection __fastcall Values(void);
private:
	void *__IJclWideStrWideStrMap;	/* Jclcontainerintf::IJclWideStrWideStrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrWideStrMap()
	{
		Jclcontainerintf::_di_IJclWideStrWideStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrWideStrMap*(void) { return (IJclWideStrWideStrMap*)&__IJclWideStrWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrWideStrMap; }
	#endif
	
};


struct TJclUnicodeStrIntfHashEntry
{
	
public:
	System::UnicodeString Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclUnicodeStrIntfBucket;
class PASCALIMPLEMENTATION TJclUnicodeStrIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrIntfHashEntry> _TJclUnicodeStrIntfBucket__1;
	
	
public:
	int Size;
	_TJclUnicodeStrIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclUnicodeStrIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclUnicodeStrIntfBucket(void) { }
	
};


class DELPHICLASS TJclUnicodeStrIntfHashMap;
class PASCALIMPLEMENTATION TJclUnicodeStrIntfHashMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrIntfBucket*> _TJclUnicodeStrIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::UnicodeString __fastcall FreeKey(System::UnicodeString &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const System::UnicodeString A, const System::UnicodeString B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclUnicodeStrIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclUnicodeStrIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::UnicodeString Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const System::UnicodeString Key);
	System::_di_IInterface __fastcall GetValue(const System::UnicodeString Key);
	bool __fastcall IsEmpty(void);
	System::UnicodeString __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclUnicodeStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclUnicodeStrIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclUnicodeStrIntfMap AMap);
	void __fastcall PutValue(const System::UnicodeString Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const System::UnicodeString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclUnicodeStrIntfMap;	/* Jclcontainerintf::IJclUnicodeStrIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIntfMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIntfMap*(void) { return (IJclUnicodeStrIntfMap*)&__IJclUnicodeStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrIntfMap; }
	#endif
	
};


struct TJclIntfUnicodeStrHashEntry
{
	
public:
	System::_di_IInterface Key;
	System::UnicodeString Value;
};


class DELPHICLASS TJclIntfUnicodeStrBucket;
class PASCALIMPLEMENTATION TJclIntfUnicodeStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfUnicodeStrHashEntry> _TJclIntfUnicodeStrBucket__1;
	
	
public:
	int Size;
	_TJclIntfUnicodeStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfUnicodeStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfUnicodeStrBucket(void) { }
	
};


class DELPHICLASS TJclIntfUnicodeStrHashMap;
class PASCALIMPLEMENTATION TJclIntfUnicodeStrHashMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfUnicodeStrBucket*> _TJclIntfUnicodeStrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::UnicodeString __fastcall FreeValue(System::UnicodeString &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const System::UnicodeString A, const System::UnicodeString B);
	
private:
	_TJclIntfUnicodeStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfUnicodeStrHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfUnicodeStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const System::UnicodeString Value);
	System::UnicodeString __fastcall Extract(const System::_di_IInterface Key);
	System::UnicodeString __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const System::UnicodeString Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfUnicodeStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfUnicodeStrMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const System::UnicodeString Value);
	System::UnicodeString __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclUnicodeStrCollection __fastcall Values(void);
private:
	void *__IJclIntfUnicodeStrMap;	/* Jclcontainerintf::IJclIntfUnicodeStrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfUnicodeStrMap()
	{
		Jclcontainerintf::_di_IJclIntfUnicodeStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfUnicodeStrMap*(void) { return (IJclIntfUnicodeStrMap*)&__IJclIntfUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclIntfUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclIntfUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfUnicodeStrMap; }
	#endif
	
};


struct TJclUnicodeStrUnicodeStrHashEntry
{
	
public:
	System::UnicodeString Key;
	System::UnicodeString Value;
};


class DELPHICLASS TJclUnicodeStrUnicodeStrBucket;
class PASCALIMPLEMENTATION TJclUnicodeStrUnicodeStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrUnicodeStrHashEntry> _TJclUnicodeStrUnicodeStrBucket__1;
	
	
public:
	int Size;
	_TJclUnicodeStrUnicodeStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclUnicodeStrUnicodeStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclUnicodeStrUnicodeStrBucket(void) { }
	
};


class DELPHICLASS TJclUnicodeStrUnicodeStrHashMap;
class PASCALIMPLEMENTATION TJclUnicodeStrUnicodeStrHashMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrUnicodeStrBucket*> _TJclUnicodeStrUnicodeStrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::UnicodeString __fastcall FreeKey(System::UnicodeString &Key);
	System::UnicodeString __fastcall FreeValue(System::UnicodeString &Value);
	bool __fastcall KeysEqual(const System::UnicodeString A, const System::UnicodeString B);
	bool __fastcall ValuesEqual(const System::UnicodeString A, const System::UnicodeString B);
	
private:
	_TJclUnicodeStrUnicodeStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrUnicodeStrHashMap(int ACapacity);
	__fastcall virtual ~TJclUnicodeStrUnicodeStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::UnicodeString Key);
	bool __fastcall ContainsValue(const System::UnicodeString Value);
	System::UnicodeString __fastcall Extract(const System::UnicodeString Key);
	System::UnicodeString __fastcall GetValue(const System::UnicodeString Key);
	bool __fastcall IsEmpty(void);
	System::UnicodeString __fastcall KeyOfValue(const System::UnicodeString Value);
	Jclcontainerintf::_di_IJclUnicodeStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrMap AMap);
	void __fastcall PutValue(const System::UnicodeString Key, const System::UnicodeString Value);
	System::UnicodeString __fastcall Remove(const System::UnicodeString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclUnicodeStrCollection __fastcall Values(void);
private:
	void *__IJclUnicodeStrUnicodeStrMap;	/* Jclcontainerintf::IJclUnicodeStrUnicodeStrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrUnicodeStrMap*(void) { return (IJclUnicodeStrUnicodeStrMap*)&__IJclUnicodeStrUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrUnicodeStrMap; }
	#endif
	
};


typedef TJclUnicodeStrIntfHashEntry TJclStrIntfHashEntry;

typedef TJclUnicodeStrIntfBucket TJclStrIntfBucket;

typedef TJclUnicodeStrIntfHashMap TJclStrIntfHashMap;

typedef TJclIntfUnicodeStrHashEntry TJclIntfStrHashEntry;

typedef TJclIntfUnicodeStrBucket TJclIntfStrBucket;

typedef TJclIntfUnicodeStrHashMap TJclIntfStrHashMap;

typedef TJclUnicodeStrUnicodeStrHashEntry TJclStrStrHashEntry;

typedef TJclUnicodeStrUnicodeStrBucket TJclStrStrBucket;

typedef TJclUnicodeStrUnicodeStrHashMap TJclStrStrHashMap;

struct TJclSingleIntfHashEntry
{
	
public:
	float Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclSingleIntfBucket;
class PASCALIMPLEMENTATION TJclSingleIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclSingleIntfHashEntry> _TJclSingleIntfBucket__1;
	
	
public:
	int Size;
	_TJclSingleIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclSingleIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSingleIntfBucket(void) { }
	
};


class DELPHICLASS TJclSingleIntfHashMap;
class PASCALIMPLEMENTATION TJclSingleIntfHashMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclSingleIntfBucket*> _TJclSingleIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	float __fastcall FreeKey(float &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const float A, const float B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclSingleIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclSingleIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const float Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const float Key);
	System::_di_IInterface __fastcall GetValue(const float Key);
	bool __fastcall IsEmpty(void);
	float __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclSingleSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclSingleIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclSingleIntfMap AMap);
	void __fastcall PutValue(const float Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const float Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclSingleIntfMap;	/* Jclcontainerintf::IJclSingleIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIntfMap()
	{
		Jclcontainerintf::_di_IJclSingleIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIntfMap*(void) { return (IJclSingleIntfMap*)&__IJclSingleIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleIntfMap; }
	#endif
	
};


struct TJclIntfSingleHashEntry
{
	
public:
	System::_di_IInterface Key;
	float Value;
};


class DELPHICLASS TJclIntfSingleBucket;
class PASCALIMPLEMENTATION TJclIntfSingleBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfSingleHashEntry> _TJclIntfSingleBucket__1;
	
	
public:
	int Size;
	_TJclIntfSingleBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfSingleBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfSingleBucket(void) { }
	
};


class DELPHICLASS TJclIntfSingleHashMap;
class PASCALIMPLEMENTATION TJclIntfSingleHashMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfSingleBucket*> _TJclIntfSingleHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	float __fastcall FreeValue(float &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const float A, const float B);
	
private:
	_TJclIntfSingleHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfSingleHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfSingleHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const float Value);
	float __fastcall Extract(const System::_di_IInterface Key);
	float __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const float Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfSingleMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfSingleMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const float Value);
	float __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclSingleCollection __fastcall Values(void);
private:
	void *__IJclIntfSingleMap;	/* Jclcontainerintf::IJclIntfSingleMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfSingleMap()
	{
		Jclcontainerintf::_di_IJclIntfSingleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfSingleMap*(void) { return (IJclIntfSingleMap*)&__IJclIntfSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclIntfSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfSingleMap; }
	#endif
	
};


struct TJclSingleSingleHashEntry
{
	
public:
	float Key;
	float Value;
};


class DELPHICLASS TJclSingleSingleBucket;
class PASCALIMPLEMENTATION TJclSingleSingleBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclSingleSingleHashEntry> _TJclSingleSingleBucket__1;
	
	
public:
	int Size;
	_TJclSingleSingleBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclSingleSingleBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSingleSingleBucket(void) { }
	
};


class DELPHICLASS TJclSingleSingleHashMap;
class PASCALIMPLEMENTATION TJclSingleSingleHashMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclSingleSingleBucket*> _TJclSingleSingleHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	float __fastcall FreeKey(float &Key);
	float __fastcall FreeValue(float &Value);
	bool __fastcall KeysEqual(const float A, const float B);
	bool __fastcall ValuesEqual(const float A, const float B);
	
private:
	_TJclSingleSingleHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleSingleHashMap(int ACapacity);
	__fastcall virtual ~TJclSingleSingleHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const float Key);
	bool __fastcall ContainsValue(const float Value);
	float __fastcall Extract(const float Key);
	float __fastcall GetValue(const float Key);
	bool __fastcall IsEmpty(void);
	float __fastcall KeyOfValue(const float Value);
	Jclcontainerintf::_di_IJclSingleSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclSingleSingleMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclSingleSingleMap AMap);
	void __fastcall PutValue(const float Key, const float Value);
	float __fastcall Remove(const float Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclSingleCollection __fastcall Values(void);
private:
	void *__IJclSingleSingleMap;	/* Jclcontainerintf::IJclSingleSingleMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleSingleMap()
	{
		Jclcontainerintf::_di_IJclSingleSingleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleSingleMap*(void) { return (IJclSingleSingleMap*)&__IJclSingleSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleSingleMap; }
	#endif
	
};


struct TJclDoubleIntfHashEntry
{
	
public:
	double Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclDoubleIntfBucket;
class PASCALIMPLEMENTATION TJclDoubleIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclDoubleIntfHashEntry> _TJclDoubleIntfBucket__1;
	
	
public:
	int Size;
	_TJclDoubleIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclDoubleIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDoubleIntfBucket(void) { }
	
};


class DELPHICLASS TJclDoubleIntfHashMap;
class PASCALIMPLEMENTATION TJclDoubleIntfHashMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclDoubleIntfBucket*> _TJclDoubleIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	double __fastcall FreeKey(double &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const double A, const double B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclDoubleIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclDoubleIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const double Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const double Key);
	System::_di_IInterface __fastcall GetValue(const double Key);
	bool __fastcall IsEmpty(void);
	double __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclDoubleSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclDoubleIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclDoubleIntfMap AMap);
	void __fastcall PutValue(const double Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const double Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclDoubleIntfMap;	/* Jclcontainerintf::IJclDoubleIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIntfMap()
	{
		Jclcontainerintf::_di_IJclDoubleIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIntfMap*(void) { return (IJclDoubleIntfMap*)&__IJclDoubleIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleIntfMap; }
	#endif
	
};


struct TJclIntfDoubleHashEntry
{
	
public:
	System::_di_IInterface Key;
	double Value;
};


class DELPHICLASS TJclIntfDoubleBucket;
class PASCALIMPLEMENTATION TJclIntfDoubleBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfDoubleHashEntry> _TJclIntfDoubleBucket__1;
	
	
public:
	int Size;
	_TJclIntfDoubleBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfDoubleBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfDoubleBucket(void) { }
	
};


class DELPHICLASS TJclIntfDoubleHashMap;
class PASCALIMPLEMENTATION TJclIntfDoubleHashMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfDoubleBucket*> _TJclIntfDoubleHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	double __fastcall FreeValue(double &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const double A, const double B);
	
private:
	_TJclIntfDoubleHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfDoubleHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfDoubleHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const double Value);
	double __fastcall Extract(const System::_di_IInterface Key);
	double __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const double Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfDoubleMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfDoubleMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const double Value);
	double __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclDoubleCollection __fastcall Values(void);
private:
	void *__IJclIntfDoubleMap;	/* Jclcontainerintf::IJclIntfDoubleMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfDoubleMap()
	{
		Jclcontainerintf::_di_IJclIntfDoubleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfDoubleMap*(void) { return (IJclIntfDoubleMap*)&__IJclIntfDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclIntfDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfDoubleMap; }
	#endif
	
};


struct TJclDoubleDoubleHashEntry
{
	
public:
	double Key;
	double Value;
};


class DELPHICLASS TJclDoubleDoubleBucket;
class PASCALIMPLEMENTATION TJclDoubleDoubleBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclDoubleDoubleHashEntry> _TJclDoubleDoubleBucket__1;
	
	
public:
	int Size;
	_TJclDoubleDoubleBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclDoubleDoubleBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDoubleDoubleBucket(void) { }
	
};


class DELPHICLASS TJclDoubleDoubleHashMap;
class PASCALIMPLEMENTATION TJclDoubleDoubleHashMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclDoubleDoubleBucket*> _TJclDoubleDoubleHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	double __fastcall FreeKey(double &Key);
	double __fastcall FreeValue(double &Value);
	bool __fastcall KeysEqual(const double A, const double B);
	bool __fastcall ValuesEqual(const double A, const double B);
	
private:
	_TJclDoubleDoubleHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleDoubleHashMap(int ACapacity);
	__fastcall virtual ~TJclDoubleDoubleHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const double Key);
	bool __fastcall ContainsValue(const double Value);
	double __fastcall Extract(const double Key);
	double __fastcall GetValue(const double Key);
	bool __fastcall IsEmpty(void);
	double __fastcall KeyOfValue(const double Value);
	Jclcontainerintf::_di_IJclDoubleSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclDoubleDoubleMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclDoubleDoubleMap AMap);
	void __fastcall PutValue(const double Key, const double Value);
	double __fastcall Remove(const double Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclDoubleCollection __fastcall Values(void);
private:
	void *__IJclDoubleDoubleMap;	/* Jclcontainerintf::IJclDoubleDoubleMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleDoubleMap()
	{
		Jclcontainerintf::_di_IJclDoubleDoubleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleDoubleMap*(void) { return (IJclDoubleDoubleMap*)&__IJclDoubleDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleDoubleMap; }
	#endif
	
};


struct TJclExtendedIntfHashEntry
{
	
public:
	System::Extended Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclExtendedIntfBucket;
class PASCALIMPLEMENTATION TJclExtendedIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclExtendedIntfHashEntry> _TJclExtendedIntfBucket__1;
	
	
public:
	int Size;
	_TJclExtendedIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclExtendedIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclExtendedIntfBucket(void) { }
	
};


class DELPHICLASS TJclExtendedIntfHashMap;
class PASCALIMPLEMENTATION TJclExtendedIntfHashMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclExtendedIntfBucket*> _TJclExtendedIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::Extended __fastcall FreeKey(System::Extended &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const System::Extended A, const System::Extended B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclExtendedIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclExtendedIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::Extended Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const System::Extended Key);
	System::_di_IInterface __fastcall GetValue(const System::Extended Key);
	bool __fastcall IsEmpty(void);
	System::Extended __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclExtendedSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclExtendedIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclExtendedIntfMap AMap);
	void __fastcall PutValue(const System::Extended Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const System::Extended Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclExtendedIntfMap;	/* Jclcontainerintf::IJclExtendedIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIntfMap()
	{
		Jclcontainerintf::_di_IJclExtendedIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIntfMap*(void) { return (IJclExtendedIntfMap*)&__IJclExtendedIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedIntfMap; }
	#endif
	
};


struct TJclIntfExtendedHashEntry
{
	
public:
	System::_di_IInterface Key;
	System::Extended Value;
};


class DELPHICLASS TJclIntfExtendedBucket;
class PASCALIMPLEMENTATION TJclIntfExtendedBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfExtendedHashEntry> _TJclIntfExtendedBucket__1;
	
	
public:
	int Size;
	_TJclIntfExtendedBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfExtendedBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfExtendedBucket(void) { }
	
};


class DELPHICLASS TJclIntfExtendedHashMap;
class PASCALIMPLEMENTATION TJclIntfExtendedHashMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfExtendedBucket*> _TJclIntfExtendedHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::Extended __fastcall FreeValue(System::Extended &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const System::Extended A, const System::Extended B);
	
private:
	_TJclIntfExtendedHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfExtendedHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfExtendedHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const System::Extended Value);
	System::Extended __fastcall Extract(const System::_di_IInterface Key);
	System::Extended __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const System::Extended Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfExtendedMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfExtendedMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const System::Extended Value);
	System::Extended __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclExtendedCollection __fastcall Values(void);
private:
	void *__IJclIntfExtendedMap;	/* Jclcontainerintf::IJclIntfExtendedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfExtendedMap()
	{
		Jclcontainerintf::_di_IJclIntfExtendedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfExtendedMap*(void) { return (IJclIntfExtendedMap*)&__IJclIntfExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclIntfExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfExtendedMap; }
	#endif
	
};


struct TJclExtendedExtendedHashEntry
{
	
public:
	System::Extended Key;
	System::Extended Value;
};


class DELPHICLASS TJclExtendedExtendedBucket;
class PASCALIMPLEMENTATION TJclExtendedExtendedBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclExtendedExtendedHashEntry> _TJclExtendedExtendedBucket__1;
	
	
public:
	int Size;
	_TJclExtendedExtendedBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclExtendedExtendedBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclExtendedExtendedBucket(void) { }
	
};


class DELPHICLASS TJclExtendedExtendedHashMap;
class PASCALIMPLEMENTATION TJclExtendedExtendedHashMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclExtendedExtendedBucket*> _TJclExtendedExtendedHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::Extended __fastcall FreeKey(System::Extended &Key);
	System::Extended __fastcall FreeValue(System::Extended &Value);
	bool __fastcall KeysEqual(const System::Extended A, const System::Extended B);
	bool __fastcall ValuesEqual(const System::Extended A, const System::Extended B);
	
private:
	_TJclExtendedExtendedHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedExtendedHashMap(int ACapacity);
	__fastcall virtual ~TJclExtendedExtendedHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::Extended Key);
	bool __fastcall ContainsValue(const System::Extended Value);
	System::Extended __fastcall Extract(const System::Extended Key);
	System::Extended __fastcall GetValue(const System::Extended Key);
	bool __fastcall IsEmpty(void);
	System::Extended __fastcall KeyOfValue(const System::Extended Value);
	Jclcontainerintf::_di_IJclExtendedSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclExtendedExtendedMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclExtendedExtendedMap AMap);
	void __fastcall PutValue(const System::Extended Key, const System::Extended Value);
	System::Extended __fastcall Remove(const System::Extended Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclExtendedCollection __fastcall Values(void);
private:
	void *__IJclExtendedExtendedMap;	/* Jclcontainerintf::IJclExtendedExtendedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedExtendedMap()
	{
		Jclcontainerintf::_di_IJclExtendedExtendedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedExtendedMap*(void) { return (IJclExtendedExtendedMap*)&__IJclExtendedExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedExtendedMap; }
	#endif
	
};


typedef TJclExtendedIntfHashEntry TJclFloatIntfHashEntry;

typedef TJclExtendedIntfBucket TJclFloatIntfBucket;

typedef TJclExtendedIntfHashMap TJclFloatIntfHashMap;

typedef TJclIntfExtendedHashEntry TJclIntfFloatHashEntry;

typedef TJclIntfExtendedBucket TJclIntfFloatBucket;

typedef TJclIntfExtendedHashMap TJclIntfFloatHashMap;

typedef TJclExtendedExtendedHashEntry TJclFloatFloatHashEntry;

typedef TJclExtendedExtendedBucket TJclFloatFloatBucket;

typedef TJclExtendedExtendedHashMap TJclFloatFloatHashMap;

struct TJclIntegerIntfHashEntry
{
	
public:
	int Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclIntegerIntfBucket;
class PASCALIMPLEMENTATION TJclIntegerIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntegerIntfHashEntry> _TJclIntegerIntfBucket__1;
	
	
public:
	int Size;
	_TJclIntegerIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntegerIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntegerIntfBucket(void) { }
	
};


class DELPHICLASS TJclIntegerIntfHashMap;
class PASCALIMPLEMENTATION TJclIntegerIntfHashMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntegerIntfBucket*> _TJclIntegerIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall FreeKey(int &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(int A, int B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclIntegerIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclIntegerIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(int Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(int Key);
	System::_di_IInterface __fastcall GetValue(int Key);
	bool __fastcall IsEmpty(void);
	int __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclIntegerSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntegerIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntegerIntfMap AMap);
	void __fastcall PutValue(int Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(int Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclIntegerIntfMap;	/* Jclcontainerintf::IJclIntegerIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIntfMap()
	{
		Jclcontainerintf::_di_IJclIntegerIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIntfMap*(void) { return (IJclIntegerIntfMap*)&__IJclIntegerIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerIntfMap; }
	#endif
	
};


struct TJclIntfIntegerHashEntry
{
	
public:
	System::_di_IInterface Key;
	int Value;
};


class DELPHICLASS TJclIntfIntegerBucket;
class PASCALIMPLEMENTATION TJclIntfIntegerBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfIntegerHashEntry> _TJclIntfIntegerBucket__1;
	
	
public:
	int Size;
	_TJclIntfIntegerBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfIntegerBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfIntegerBucket(void) { }
	
};


class DELPHICLASS TJclIntfIntegerHashMap;
class PASCALIMPLEMENTATION TJclIntfIntegerHashMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfIntegerBucket*> _TJclIntfIntegerHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	int __fastcall FreeValue(int &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(int A, int B);
	
private:
	_TJclIntfIntegerHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfIntegerHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfIntegerHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(int Value);
	int __fastcall Extract(const System::_di_IInterface Key);
	int __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(int Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfIntegerMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfIntegerMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, int Value);
	int __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntegerCollection __fastcall Values(void);
private:
	void *__IJclIntfIntegerMap;	/* Jclcontainerintf::IJclIntfIntegerMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIntegerMap()
	{
		Jclcontainerintf::_di_IJclIntfIntegerMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIntegerMap*(void) { return (IJclIntfIntegerMap*)&__IJclIntfIntegerMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfIntegerMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfIntegerMap; }
	#endif
	
};


struct TJclIntegerIntegerHashEntry
{
	
public:
	int Key;
	int Value;
};


class DELPHICLASS TJclIntegerIntegerBucket;
class PASCALIMPLEMENTATION TJclIntegerIntegerBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntegerIntegerHashEntry> _TJclIntegerIntegerBucket__1;
	
	
public:
	int Size;
	_TJclIntegerIntegerBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntegerIntegerBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntegerIntegerBucket(void) { }
	
};


class DELPHICLASS TJclIntegerIntegerHashMap;
class PASCALIMPLEMENTATION TJclIntegerIntegerHashMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntegerIntegerBucket*> _TJclIntegerIntegerHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall FreeKey(int &Key);
	int __fastcall FreeValue(int &Value);
	bool __fastcall KeysEqual(int A, int B);
	bool __fastcall ValuesEqual(int A, int B);
	
private:
	_TJclIntegerIntegerHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerIntegerHashMap(int ACapacity);
	__fastcall virtual ~TJclIntegerIntegerHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(int Key);
	bool __fastcall ContainsValue(int Value);
	int __fastcall Extract(int Key);
	int __fastcall GetValue(int Key);
	bool __fastcall IsEmpty(void);
	int __fastcall KeyOfValue(int Value);
	Jclcontainerintf::_di_IJclIntegerSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntegerIntegerMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntegerIntegerMap AMap);
	void __fastcall PutValue(int Key, int Value);
	int __fastcall Remove(int Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntegerCollection __fastcall Values(void);
private:
	void *__IJclIntegerIntegerMap;	/* Jclcontainerintf::IJclIntegerIntegerMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIntegerMap()
	{
		Jclcontainerintf::_di_IJclIntegerIntegerMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIntegerMap*(void) { return (IJclIntegerIntegerMap*)&__IJclIntegerIntegerMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerIntegerMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerIntegerMap; }
	#endif
	
};


struct TJclCardinalIntfHashEntry
{
	
public:
	unsigned Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclCardinalIntfBucket;
class PASCALIMPLEMENTATION TJclCardinalIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclCardinalIntfHashEntry> _TJclCardinalIntfBucket__1;
	
	
public:
	int Size;
	_TJclCardinalIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclCardinalIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCardinalIntfBucket(void) { }
	
};


class DELPHICLASS TJclCardinalIntfHashMap;
class PASCALIMPLEMENTATION TJclCardinalIntfHashMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclCardinalIntfBucket*> _TJclCardinalIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	unsigned __fastcall FreeKey(unsigned &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(unsigned A, unsigned B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclCardinalIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclCardinalIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(unsigned Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(unsigned Key);
	System::_di_IInterface __fastcall GetValue(unsigned Key);
	bool __fastcall IsEmpty(void);
	unsigned __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclCardinalSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclCardinalIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclCardinalIntfMap AMap);
	void __fastcall PutValue(unsigned Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(unsigned Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclCardinalIntfMap;	/* Jclcontainerintf::IJclCardinalIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIntfMap()
	{
		Jclcontainerintf::_di_IJclCardinalIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIntfMap*(void) { return (IJclCardinalIntfMap*)&__IJclCardinalIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalIntfMap; }
	#endif
	
};


struct TJclIntfCardinalHashEntry
{
	
public:
	System::_di_IInterface Key;
	unsigned Value;
};


class DELPHICLASS TJclIntfCardinalBucket;
class PASCALIMPLEMENTATION TJclIntfCardinalBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfCardinalHashEntry> _TJclIntfCardinalBucket__1;
	
	
public:
	int Size;
	_TJclIntfCardinalBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfCardinalBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfCardinalBucket(void) { }
	
};


class DELPHICLASS TJclIntfCardinalHashMap;
class PASCALIMPLEMENTATION TJclIntfCardinalHashMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfCardinalBucket*> _TJclIntfCardinalHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	unsigned __fastcall FreeValue(unsigned &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(unsigned A, unsigned B);
	
private:
	_TJclIntfCardinalHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfCardinalHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfCardinalHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(unsigned Value);
	unsigned __fastcall Extract(const System::_di_IInterface Key);
	unsigned __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(unsigned Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfCardinalMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfCardinalMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, unsigned Value);
	unsigned __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCardinalCollection __fastcall Values(void);
private:
	void *__IJclIntfCardinalMap;	/* Jclcontainerintf::IJclIntfCardinalMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCardinalMap()
	{
		Jclcontainerintf::_di_IJclIntfCardinalMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCardinalMap*(void) { return (IJclIntfCardinalMap*)&__IJclIntfCardinalMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfCardinalMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfCardinalMap; }
	#endif
	
};


struct TJclCardinalCardinalHashEntry
{
	
public:
	unsigned Key;
	unsigned Value;
};


class DELPHICLASS TJclCardinalCardinalBucket;
class PASCALIMPLEMENTATION TJclCardinalCardinalBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclCardinalCardinalHashEntry> _TJclCardinalCardinalBucket__1;
	
	
public:
	int Size;
	_TJclCardinalCardinalBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclCardinalCardinalBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCardinalCardinalBucket(void) { }
	
};


class DELPHICLASS TJclCardinalCardinalHashMap;
class PASCALIMPLEMENTATION TJclCardinalCardinalHashMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclCardinalCardinalBucket*> _TJclCardinalCardinalHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	unsigned __fastcall FreeKey(unsigned &Key);
	unsigned __fastcall FreeValue(unsigned &Value);
	bool __fastcall KeysEqual(unsigned A, unsigned B);
	bool __fastcall ValuesEqual(unsigned A, unsigned B);
	
private:
	_TJclCardinalCardinalHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalCardinalHashMap(int ACapacity);
	__fastcall virtual ~TJclCardinalCardinalHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(unsigned Key);
	bool __fastcall ContainsValue(unsigned Value);
	unsigned __fastcall Extract(unsigned Key);
	unsigned __fastcall GetValue(unsigned Key);
	bool __fastcall IsEmpty(void);
	unsigned __fastcall KeyOfValue(unsigned Value);
	Jclcontainerintf::_di_IJclCardinalSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclCardinalCardinalMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclCardinalCardinalMap AMap);
	void __fastcall PutValue(unsigned Key, unsigned Value);
	unsigned __fastcall Remove(unsigned Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCardinalCollection __fastcall Values(void);
private:
	void *__IJclCardinalCardinalMap;	/* Jclcontainerintf::IJclCardinalCardinalMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalCardinalMap()
	{
		Jclcontainerintf::_di_IJclCardinalCardinalMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalCardinalMap*(void) { return (IJclCardinalCardinalMap*)&__IJclCardinalCardinalMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalCardinalMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalCardinalMap; }
	#endif
	
};


struct TJclInt64IntfHashEntry
{
	
public:
	__int64 Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclInt64IntfBucket;
class PASCALIMPLEMENTATION TJclInt64IntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclInt64IntfHashEntry> _TJclInt64IntfBucket__1;
	
	
public:
	int Size;
	_TJclInt64IntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclInt64IntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInt64IntfBucket(void) { }
	
};


class DELPHICLASS TJclInt64IntfHashMap;
class PASCALIMPLEMENTATION TJclInt64IntfHashMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclInt64IntfBucket*> _TJclInt64IntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	__int64 __fastcall FreeKey(__int64 &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(const __int64 A, const __int64 B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclInt64IntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64IntfHashMap(int ACapacity);
	__fastcall virtual ~TJclInt64IntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const __int64 Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(const __int64 Key);
	System::_di_IInterface __fastcall GetValue(const __int64 Key);
	bool __fastcall IsEmpty(void);
	__int64 __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclInt64Set __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclInt64IntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclInt64IntfMap AMap);
	void __fastcall PutValue(const __int64 Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(const __int64 Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclInt64IntfMap;	/* Jclcontainerintf::IJclInt64IntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64IntfMap()
	{
		Jclcontainerintf::_di_IJclInt64IntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64IntfMap*(void) { return (IJclInt64IntfMap*)&__IJclInt64IntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64IntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64IntfMap; }
	#endif
	
};


struct TJclIntfInt64HashEntry
{
	
public:
	System::_di_IInterface Key;
	__int64 Value;
};


class DELPHICLASS TJclIntfInt64Bucket;
class PASCALIMPLEMENTATION TJclIntfInt64Bucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfInt64HashEntry> _TJclIntfInt64Bucket__1;
	
	
public:
	int Size;
	_TJclIntfInt64Bucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfInt64Bucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfInt64Bucket(void) { }
	
};


class DELPHICLASS TJclIntfInt64HashMap;
class PASCALIMPLEMENTATION TJclIntfInt64HashMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfInt64Bucket*> _TJclIntfInt64HashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	__int64 __fastcall FreeValue(__int64 &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(const __int64 A, const __int64 B);
	
private:
	_TJclIntfInt64HashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfInt64HashMap(int ACapacity);
	__fastcall virtual ~TJclIntfInt64HashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(const __int64 Value);
	__int64 __fastcall Extract(const System::_di_IInterface Key);
	__int64 __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(const __int64 Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfInt64Map AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfInt64Map AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, const __int64 Value);
	__int64 __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclInt64Collection __fastcall Values(void);
private:
	void *__IJclIntfInt64Map;	/* Jclcontainerintf::IJclIntfInt64Map */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfInt64Map()
	{
		Jclcontainerintf::_di_IJclIntfInt64Map intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfInt64Map*(void) { return (IJclIntfInt64Map*)&__IJclIntfInt64Map; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfInt64Map; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfInt64Map; }
	#endif
	
};


struct TJclInt64Int64HashEntry
{
	
public:
	__int64 Key;
	__int64 Value;
};


class DELPHICLASS TJclInt64Int64Bucket;
class PASCALIMPLEMENTATION TJclInt64Int64Bucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclInt64Int64HashEntry> _TJclInt64Int64Bucket__1;
	
	
public:
	int Size;
	_TJclInt64Int64Bucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclInt64Int64Bucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInt64Int64Bucket(void) { }
	
};


class DELPHICLASS TJclInt64Int64HashMap;
class PASCALIMPLEMENTATION TJclInt64Int64HashMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclInt64Int64Bucket*> _TJclInt64Int64HashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	__int64 __fastcall FreeKey(__int64 &Key);
	__int64 __fastcall FreeValue(__int64 &Value);
	bool __fastcall KeysEqual(const __int64 A, const __int64 B);
	bool __fastcall ValuesEqual(const __int64 A, const __int64 B);
	
private:
	_TJclInt64Int64HashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64Int64HashMap(int ACapacity);
	__fastcall virtual ~TJclInt64Int64HashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const __int64 Key);
	bool __fastcall ContainsValue(const __int64 Value);
	__int64 __fastcall Extract(const __int64 Key);
	__int64 __fastcall GetValue(const __int64 Key);
	bool __fastcall IsEmpty(void);
	__int64 __fastcall KeyOfValue(const __int64 Value);
	Jclcontainerintf::_di_IJclInt64Set __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclInt64Int64Map AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclInt64Int64Map AMap);
	void __fastcall PutValue(const __int64 Key, const __int64 Value);
	__int64 __fastcall Remove(const __int64 Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclInt64Collection __fastcall Values(void);
private:
	void *__IJclInt64Int64Map;	/* Jclcontainerintf::IJclInt64Int64Map */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Int64Map()
	{
		Jclcontainerintf::_di_IJclInt64Int64Map intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Int64Map*(void) { return (IJclInt64Int64Map*)&__IJclInt64Int64Map; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Int64Map; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Int64Map; }
	#endif
	
};


struct TJclPtrIntfHashEntry
{
	
public:
	void *Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclPtrIntfBucket;
class PASCALIMPLEMENTATION TJclPtrIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclPtrIntfHashEntry> _TJclPtrIntfBucket__1;
	
	
public:
	int Size;
	_TJclPtrIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclPtrIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclPtrIntfBucket(void) { }
	
};


class DELPHICLASS TJclPtrIntfHashMap;
class PASCALIMPLEMENTATION TJclPtrIntfHashMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclPtrIntfBucket*> _TJclPtrIntfHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	void * __fastcall FreeKey(void * &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	bool __fastcall KeysEqual(void * A, void * B);
	bool __fastcall ValuesEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclPtrIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrIntfHashMap(int ACapacity);
	__fastcall virtual ~TJclPtrIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(void * Key);
	bool __fastcall ContainsValue(const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Extract(void * Key);
	System::_di_IInterface __fastcall GetValue(void * Key);
	bool __fastcall IsEmpty(void);
	void * __fastcall KeyOfValue(const System::_di_IInterface Value);
	Jclcontainerintf::_di_IJclPtrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclPtrIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclPtrIntfMap AMap);
	void __fastcall PutValue(void * Key, const System::_di_IInterface Value);
	System::_di_IInterface __fastcall Remove(void * Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfCollection __fastcall Values(void);
private:
	void *__IJclPtrIntfMap;	/* Jclcontainerintf::IJclPtrIntfMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIntfMap()
	{
		Jclcontainerintf::_di_IJclPtrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIntfMap*(void) { return (IJclPtrIntfMap*)&__IJclPtrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrIntfMap; }
	#endif
	
};


struct TJclIntfPtrHashEntry
{
	
public:
	System::_di_IInterface Key;
	void *Value;
};


class DELPHICLASS TJclIntfPtrBucket;
class PASCALIMPLEMENTATION TJclIntfPtrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfPtrHashEntry> _TJclIntfPtrBucket__1;
	
	
public:
	int Size;
	_TJclIntfPtrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfPtrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfPtrBucket(void) { }
	
};


class DELPHICLASS TJclIntfPtrHashMap;
class PASCALIMPLEMENTATION TJclIntfPtrHashMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfPtrBucket*> _TJclIntfPtrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	void * __fastcall FreeValue(void * &Value);
	HIDESBASE int __fastcall Hash(const System::_di_IInterface AInterface);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(void * A, void * B);
	
private:
	_TJclIntfPtrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfPtrHashMap(int ACapacity);
	__fastcall virtual ~TJclIntfPtrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(void * Value);
	void * __fastcall Extract(const System::_di_IInterface Key);
	void * __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(void * Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfPtrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfPtrMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, void * Value);
	void * __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclPtrCollection __fastcall Values(void);
private:
	void *__IJclIntfPtrMap;	/* Jclcontainerintf::IJclIntfPtrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfPtrMap()
	{
		Jclcontainerintf::_di_IJclIntfPtrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfPtrMap*(void) { return (IJclIntfPtrMap*)&__IJclIntfPtrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfPtrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfPtrMap; }
	#endif
	
};


struct TJclPtrPtrHashEntry
{
	
public:
	void *Key;
	void *Value;
};


class DELPHICLASS TJclPtrPtrBucket;
class PASCALIMPLEMENTATION TJclPtrPtrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclPtrPtrHashEntry> _TJclPtrPtrBucket__1;
	
	
public:
	int Size;
	_TJclPtrPtrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclPtrPtrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclPtrPtrBucket(void) { }
	
};


class DELPHICLASS TJclPtrPtrHashMap;
class PASCALIMPLEMENTATION TJclPtrPtrHashMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclPtrPtrBucket*> _TJclPtrPtrHashMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	void * __fastcall FreeKey(void * &Key);
	void * __fastcall FreeValue(void * &Value);
	bool __fastcall KeysEqual(void * A, void * B);
	bool __fastcall ValuesEqual(void * A, void * B);
	
private:
	_TJclPtrPtrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrPtrHashMap(int ACapacity);
	__fastcall virtual ~TJclPtrPtrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(void * Key);
	bool __fastcall ContainsValue(void * Value);
	void * __fastcall Extract(void * Key);
	void * __fastcall GetValue(void * Key);
	bool __fastcall IsEmpty(void);
	void * __fastcall KeyOfValue(void * Value);
	Jclcontainerintf::_di_IJclPtrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclPtrPtrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclPtrPtrMap AMap);
	void __fastcall PutValue(void * Key, void * Value);
	void * __fastcall Remove(void * Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclPtrCollection __fastcall Values(void);
private:
	void *__IJclPtrPtrMap;	/* Jclcontainerintf::IJclPtrPtrMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrPtrMap()
	{
		Jclcontainerintf::_di_IJclPtrPtrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrPtrMap*(void) { return (IJclPtrPtrMap*)&__IJclPtrPtrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrPtrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrPtrMap; }
	#endif
	
};


struct TJclIntfHashEntry
{
	
public:
	System::_di_IInterface Key;
	System::TObject* Value;
};


class DELPHICLASS TJclIntfBucket;
class PASCALIMPLEMENTATION TJclIntfBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntfHashEntry> _TJclIntfBucket__1;
	
	
public:
	int Size;
	_TJclIntfBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntfBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfBucket(void) { }
	
};


class DELPHICLASS TJclIntfHashMap;
class PASCALIMPLEMENTATION TJclIntfHashMap : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfBucket*> _TJclIntfHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	bool __fastcall KeysEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclIntfHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclIntfHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::_di_IInterface Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const System::_di_IInterface Key);
	System::TObject* __fastcall GetValue(const System::_di_IInterface Key);
	bool __fastcall IsEmpty(void);
	System::_di_IInterface __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclIntfSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntfMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntfMap AMap);
	void __fastcall PutValue(const System::_di_IInterface Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const System::_di_IInterface Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclIntfMap;	/* Jclcontainerintf::IJclIntfMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfMap()
	{
		Jclcontainerintf::_di_IJclIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfMap*(void) { return (IJclIntfMap*)&__IJclIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfMap; }
	#endif
	
};


struct TJclAnsiStrHashEntry
{
	
public:
	System::AnsiString Key;
	System::TObject* Value;
};


class DELPHICLASS TJclAnsiStrBucket;
class PASCALIMPLEMENTATION TJclAnsiStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrHashEntry> _TJclAnsiStrBucket__1;
	
	
public:
	int Size;
	_TJclAnsiStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclAnsiStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAnsiStrBucket(void) { }
	
};


class DELPHICLASS TJclAnsiStrHashMap;
class PASCALIMPLEMENTATION TJclAnsiStrHashMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrBucket*> _TJclAnsiStrHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::AnsiString __fastcall FreeKey(System::AnsiString &Key);
	bool __fastcall KeysEqual(const System::AnsiString A, const System::AnsiString B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclAnsiStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclAnsiStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::AnsiString Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const System::AnsiString Key);
	System::TObject* __fastcall GetValue(const System::AnsiString Key);
	bool __fastcall IsEmpty(void);
	System::AnsiString __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclAnsiStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclAnsiStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclAnsiStrMap AMap);
	void __fastcall PutValue(const System::AnsiString Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const System::AnsiString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclAnsiStrMap;	/* Jclcontainerintf::IJclAnsiStrMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrMap*(void) { return (IJclAnsiStrMap*)&__IJclAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrMap; }
	#endif
	
};


struct TJclWideStrHashEntry
{
	
public:
	System::WideString Key;
	System::TObject* Value;
};


class DELPHICLASS TJclWideStrBucket;
class PASCALIMPLEMENTATION TJclWideStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclWideStrHashEntry> _TJclWideStrBucket__1;
	
	
public:
	int Size;
	_TJclWideStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclWideStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclWideStrBucket(void) { }
	
};


class DELPHICLASS TJclWideStrHashMap;
class PASCALIMPLEMENTATION TJclWideStrHashMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclWideStrBucket*> _TJclWideStrHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::WideString __fastcall FreeKey(System::WideString &Key);
	bool __fastcall KeysEqual(const System::WideString A, const System::WideString B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclWideStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclWideStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::WideString Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const System::WideString Key);
	System::TObject* __fastcall GetValue(const System::WideString Key);
	bool __fastcall IsEmpty(void);
	System::WideString __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclWideStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclWideStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclWideStrMap AMap);
	void __fastcall PutValue(const System::WideString Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const System::WideString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclWideStrMap;	/* Jclcontainerintf::IJclWideStrMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrMap()
	{
		Jclcontainerintf::_di_IJclWideStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrMap*(void) { return (IJclWideStrMap*)&__IJclWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrMap; }
	#endif
	
};


struct TJclUnicodeStrHashEntry
{
	
public:
	System::UnicodeString Key;
	System::TObject* Value;
};


class DELPHICLASS TJclUnicodeStrBucket;
class PASCALIMPLEMENTATION TJclUnicodeStrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrHashEntry> _TJclUnicodeStrBucket__1;
	
	
public:
	int Size;
	_TJclUnicodeStrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclUnicodeStrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclUnicodeStrBucket(void) { }
	
};


class DELPHICLASS TJclUnicodeStrHashMap;
class PASCALIMPLEMENTATION TJclUnicodeStrHashMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrBucket*> _TJclUnicodeStrHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::UnicodeString __fastcall FreeKey(System::UnicodeString &Key);
	bool __fastcall KeysEqual(const System::UnicodeString A, const System::UnicodeString B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclUnicodeStrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclUnicodeStrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::UnicodeString Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const System::UnicodeString Key);
	System::TObject* __fastcall GetValue(const System::UnicodeString Key);
	bool __fastcall IsEmpty(void);
	System::UnicodeString __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclUnicodeStrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclUnicodeStrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclUnicodeStrMap AMap);
	void __fastcall PutValue(const System::UnicodeString Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const System::UnicodeString Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclUnicodeStrMap;	/* Jclcontainerintf::IJclUnicodeStrMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrMap*(void) { return (IJclUnicodeStrMap*)&__IJclUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrMap; }
	#endif
	
};


typedef TJclUnicodeStrHashEntry TJclStrHashEntry;

typedef TJclUnicodeStrBucket TJclStrBucket;

typedef TJclUnicodeStrHashMap TJclStrHashMap;

struct TJclSingleHashEntry
{
	
public:
	float Key;
	System::TObject* Value;
};


class DELPHICLASS TJclSingleBucket;
class PASCALIMPLEMENTATION TJclSingleBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclSingleHashEntry> _TJclSingleBucket__1;
	
	
public:
	int Size;
	_TJclSingleBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclSingleBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSingleBucket(void) { }
	
};


class DELPHICLASS TJclSingleHashMap;
class PASCALIMPLEMENTATION TJclSingleHashMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclSingleBucket*> _TJclSingleHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	float __fastcall FreeKey(float &Key);
	bool __fastcall KeysEqual(const float A, const float B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclSingleHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclSingleHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const float Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const float Key);
	System::TObject* __fastcall GetValue(const float Key);
	bool __fastcall IsEmpty(void);
	float __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclSingleSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclSingleMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclSingleMap AMap);
	void __fastcall PutValue(const float Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const float Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclSingleMap;	/* Jclcontainerintf::IJclSingleMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleMap()
	{
		Jclcontainerintf::_di_IJclSingleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleMap*(void) { return (IJclSingleMap*)&__IJclSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleMap; }
	#endif
	
};


struct TJclDoubleHashEntry
{
	
public:
	double Key;
	System::TObject* Value;
};


class DELPHICLASS TJclDoubleBucket;
class PASCALIMPLEMENTATION TJclDoubleBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclDoubleHashEntry> _TJclDoubleBucket__1;
	
	
public:
	int Size;
	_TJclDoubleBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclDoubleBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDoubleBucket(void) { }
	
};


class DELPHICLASS TJclDoubleHashMap;
class PASCALIMPLEMENTATION TJclDoubleHashMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclDoubleBucket*> _TJclDoubleHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	double __fastcall FreeKey(double &Key);
	bool __fastcall KeysEqual(const double A, const double B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclDoubleHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclDoubleHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const double Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const double Key);
	System::TObject* __fastcall GetValue(const double Key);
	bool __fastcall IsEmpty(void);
	double __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclDoubleSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclDoubleMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclDoubleMap AMap);
	void __fastcall PutValue(const double Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const double Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclDoubleMap;	/* Jclcontainerintf::IJclDoubleMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleMap()
	{
		Jclcontainerintf::_di_IJclDoubleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleMap*(void) { return (IJclDoubleMap*)&__IJclDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleMap; }
	#endif
	
};


struct TJclExtendedHashEntry
{
	
public:
	System::Extended Key;
	System::TObject* Value;
};


class DELPHICLASS TJclExtendedBucket;
class PASCALIMPLEMENTATION TJclExtendedBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclExtendedHashEntry> _TJclExtendedBucket__1;
	
	
public:
	int Size;
	_TJclExtendedBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclExtendedBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclExtendedBucket(void) { }
	
};


class DELPHICLASS TJclExtendedHashMap;
class PASCALIMPLEMENTATION TJclExtendedHashMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclExtendedBucket*> _TJclExtendedHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::Extended __fastcall FreeKey(System::Extended &Key);
	bool __fastcall KeysEqual(const System::Extended A, const System::Extended B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclExtendedHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclExtendedHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const System::Extended Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const System::Extended Key);
	System::TObject* __fastcall GetValue(const System::Extended Key);
	bool __fastcall IsEmpty(void);
	System::Extended __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclExtendedSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclExtendedMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclExtendedMap AMap);
	void __fastcall PutValue(const System::Extended Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const System::Extended Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclExtendedMap;	/* Jclcontainerintf::IJclExtendedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedMap()
	{
		Jclcontainerintf::_di_IJclExtendedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedMap*(void) { return (IJclExtendedMap*)&__IJclExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedMap; }
	#endif
	
};


typedef TJclExtendedHashEntry TJclFloatHashEntry;

typedef TJclExtendedBucket TJclFloatBucket;

typedef TJclExtendedHashMap TJclFloatHashMap;

struct TJclIntegerHashEntry
{
	
public:
	int Key;
	System::TObject* Value;
};


class DELPHICLASS TJclIntegerBucket;
class PASCALIMPLEMENTATION TJclIntegerBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclIntegerHashEntry> _TJclIntegerBucket__1;
	
	
public:
	int Size;
	_TJclIntegerBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclIntegerBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntegerBucket(void) { }
	
};


class DELPHICLASS TJclIntegerHashMap;
class PASCALIMPLEMENTATION TJclIntegerHashMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntegerBucket*> _TJclIntegerHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall FreeKey(int &Key);
	bool __fastcall KeysEqual(int A, int B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclIntegerHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclIntegerHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(int Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(int Key);
	System::TObject* __fastcall GetValue(int Key);
	bool __fastcall IsEmpty(void);
	int __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclIntegerSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclIntegerMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclIntegerMap AMap);
	void __fastcall PutValue(int Key, System::TObject* Value);
	System::TObject* __fastcall Remove(int Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclIntegerMap;	/* Jclcontainerintf::IJclIntegerMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerMap()
	{
		Jclcontainerintf::_di_IJclIntegerMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerMap*(void) { return (IJclIntegerMap*)&__IJclIntegerMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerMap; }
	#endif
	
};


struct TJclCardinalHashEntry
{
	
public:
	unsigned Key;
	System::TObject* Value;
};


class DELPHICLASS TJclCardinalBucket;
class PASCALIMPLEMENTATION TJclCardinalBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclCardinalHashEntry> _TJclCardinalBucket__1;
	
	
public:
	int Size;
	_TJclCardinalBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclCardinalBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCardinalBucket(void) { }
	
};


class DELPHICLASS TJclCardinalHashMap;
class PASCALIMPLEMENTATION TJclCardinalHashMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclCardinalBucket*> _TJclCardinalHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	unsigned __fastcall FreeKey(unsigned &Key);
	bool __fastcall KeysEqual(unsigned A, unsigned B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclCardinalHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclCardinalHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(unsigned Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(unsigned Key);
	System::TObject* __fastcall GetValue(unsigned Key);
	bool __fastcall IsEmpty(void);
	unsigned __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclCardinalSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclCardinalMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclCardinalMap AMap);
	void __fastcall PutValue(unsigned Key, System::TObject* Value);
	System::TObject* __fastcall Remove(unsigned Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclCardinalMap;	/* Jclcontainerintf::IJclCardinalMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalMap()
	{
		Jclcontainerintf::_di_IJclCardinalMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalMap*(void) { return (IJclCardinalMap*)&__IJclCardinalMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalMap; }
	#endif
	
};


struct TJclInt64HashEntry
{
	
public:
	__int64 Key;
	System::TObject* Value;
};


class DELPHICLASS TJclInt64Bucket;
class PASCALIMPLEMENTATION TJclInt64Bucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclInt64HashEntry> _TJclInt64Bucket__1;
	
	
public:
	int Size;
	_TJclInt64Bucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclInt64Bucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInt64Bucket(void) { }
	
};


class DELPHICLASS TJclInt64HashMap;
class PASCALIMPLEMENTATION TJclInt64HashMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclInt64Bucket*> _TJclInt64HashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	__int64 __fastcall FreeKey(__int64 &Key);
	bool __fastcall KeysEqual(const __int64 A, const __int64 B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclInt64HashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64HashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclInt64HashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const __int64 Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(const __int64 Key);
	System::TObject* __fastcall GetValue(const __int64 Key);
	bool __fastcall IsEmpty(void);
	__int64 __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclInt64Set __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclInt64Map AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclInt64Map AMap);
	void __fastcall PutValue(const __int64 Key, System::TObject* Value);
	System::TObject* __fastcall Remove(const __int64 Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclInt64Map;	/* Jclcontainerintf::IJclInt64Map */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Map()
	{
		Jclcontainerintf::_di_IJclInt64Map intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Map*(void) { return (IJclInt64Map*)&__IJclInt64Map; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Map; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Map; }
	#endif
	
};


struct TJclPtrHashEntry
{
	
public:
	void *Key;
	System::TObject* Value;
};


class DELPHICLASS TJclPtrBucket;
class PASCALIMPLEMENTATION TJclPtrBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclPtrHashEntry> _TJclPtrBucket__1;
	
	
public:
	int Size;
	_TJclPtrBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclPtrBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclPtrBucket(void) { }
	
};


class DELPHICLASS TJclPtrHashMap;
class PASCALIMPLEMENTATION TJclPtrHashMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclPtrBucket*> _TJclPtrHashMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	void * __fastcall FreeKey(void * &Key);
	bool __fastcall KeysEqual(void * A, void * B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclPtrHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrHashMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclPtrHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(void * Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(void * Key);
	System::TObject* __fastcall GetValue(void * Key);
	bool __fastcall IsEmpty(void);
	void * __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclPtrSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclPtrMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclPtrMap AMap);
	void __fastcall PutValue(void * Key, System::TObject* Value);
	System::TObject* __fastcall Remove(void * Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclPtrMap;	/* Jclcontainerintf::IJclPtrMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrMap()
	{
		Jclcontainerintf::_di_IJclPtrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrMap*(void) { return (IJclPtrMap*)&__IJclPtrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrMap; }
	#endif
	
};


struct TJclHashEntry
{
	
public:
	System::TObject* Key;
	System::TObject* Value;
};


class DELPHICLASS TJclBucket;
class PASCALIMPLEMENTATION TJclBucket : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclHashEntry> _TJclBucket__1;
	
	
public:
	int Size;
	_TJclBucket__1 Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclBucket(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBucket(void) { }
	
};


class DELPHICLASS TJclHashMap;
class PASCALIMPLEMENTATION TJclHashMap : public Jclabstractcontainers::TJclAbstractContainerBase
{
	typedef Jclabstractcontainers::TJclAbstractContainerBase inherited;
	
private:
	typedef DynamicArray<TJclBucket*> _TJclHashMap__1;
	
	
private:
	bool FOwnsKeys;
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall Hash(System::TObject* AObject);
	bool __fastcall KeysEqual(System::TObject* A, System::TObject* B);
	bool __fastcall ValuesEqual(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeKey(System::TObject* &Key);
	bool __fastcall GetOwnsKeys(void);
	__property bool OwnsKeys = {read=FOwnsKeys, nodefault};
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclHashMap__1 FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclHashMap(int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__fastcall virtual ~TJclHashMap(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(System::TObject* Key);
	bool __fastcall ContainsValue(System::TObject* Value);
	System::TObject* __fastcall Extract(System::TObject* Key);
	System::TObject* __fastcall GetValue(System::TObject* Key);
	bool __fastcall IsEmpty(void);
	System::TObject* __fastcall KeyOfValue(System::TObject* Value);
	Jclcontainerintf::_di_IJclSet __fastcall KeySet(void);
	bool __fastcall MapEquals(const Jclcontainerintf::_di_IJclMap AMap);
	void __fastcall PutAll(const Jclcontainerintf::_di_IJclMap AMap);
	void __fastcall PutValue(System::TObject* Key, System::TObject* Value);
	System::TObject* __fastcall Remove(System::TObject* Key);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCollection __fastcall Values(void);
private:
	void *__IJclMap;	/* Jclcontainerintf::IJclMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclKeyOwner;	/* Jclcontainerintf::IJclKeyOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclMap()
	{
		Jclcontainerintf::_di_IJclMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap*(void) { return (IJclMap*)&__IJclMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclValueOwner()
	{
		Jclcontainerintf::_di_IJclValueOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclValueOwner*(void) { return (IJclValueOwner*)&__IJclValueOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclKeyOwner()
	{
		Jclcontainerintf::_di_IJclKeyOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclKeyOwner*(void) { return (IJclKeyOwner*)&__IJclKeyOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclMap; }
	#endif
	
};


// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> struct TJclHashEntry__2
{
	
public:
	TKey Key;
	TValue Value;
};


template<typename TKey, typename TValue> class DELPHICLASS TJclBucket__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclBucket__2 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	int Size;
	DynamicArray<TJclHashEntry__2<TKey,TValue> > Entries;
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
public:
	/* TObject.Create */ inline __fastcall TJclBucket__2(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBucket__2(void) { }
	
};


template<typename TKey, typename TValue> class DELPHICLASS TJclHashMap__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclHashMap__2 : public Jclabstractcontainers::TJclAbstractContainerBase
{
	typedef Jclabstractcontainers::TJclAbstractContainerBase inherited;
	
protected:
	
private:
	bool FOwnsKeys;
	bool FOwnsValues;
	
protected:
	virtual int __fastcall Hash(const TKey AKey) = 0 ;
	virtual bool __fastcall KeysEqual(const TKey A, const TKey B) = 0 ;
	virtual bool __fastcall ValuesEqual(const TValue A, const TValue B) = 0 ;
	virtual System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall CreateEmptyArrayList(int ACapacity, bool AOwnsObjects) = 0 ;
	virtual System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall CreateEmptyArraySet(int ACapacity, bool AOwnsObjects) = 0 ;
	
public:
	TKey __fastcall FreeKey(TKey &Key);
	TValue __fastcall FreeValue(TValue &Value);
	bool __fastcall GetOwnsKeys(void);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsKeys = {read=FOwnsKeys, nodefault};
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	DynamicArray<TJclBucket__2<TKey,TValue>*> FBuckets;
	TJclHashFunction FHashFunction;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclHashMap__2(int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__fastcall virtual ~TJclHashMap__2(void);
	__property TJclHashFunction HashFunction = {read=FHashFunction, write=FHashFunction};
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall ContainsKey(const TKey Key);
	bool __fastcall ContainsValue(const TValue Value);
	TValue __fastcall Extract(const TKey Key);
	TValue __fastcall GetValue(const TKey Key);
	bool __fastcall IsEmpty(void);
	TKey __fastcall KeyOfValue(const TValue Value);
	System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall KeySet(void);
	bool __fastcall MapEquals(const System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >  AMap);
	void __fastcall PutAll(const System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >  AMap);
	void __fastcall PutValue(const TKey Key, const TValue Value);
	TValue __fastcall Remove(const TKey Key);
	int __fastcall Size(void);
	System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall Values(void);
private:
	void *__IJclMap__2;	/* Jclcontainerintf::IJclMap__2<TKey,TValue> */
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPairOwner__2<TKey,TValue>*(void) { return (IJclPairOwner__2<TKey,TValue>*)&__IJclPairOwner__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclGrowable()
	{
		Jclcontainerintf::_di_IJclGrowable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclGrowable*(void) { return (IJclGrowable*)&__IJclGrowable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclMap__2; }
	#endif
	
};


template<typename TKey, typename TValue> class DELPHICLASS TJclHashMapE__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclHashMapE__2 : public TJclHashMap__2<TKey,TValue>
{
	typedef TJclHashMap__2<TKey,TValue> inherited;
	
protected:
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TKey> >  FKeyEqualityComparer;
	System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<TKey> >  FKeyHashConverter;
	System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TKey> >  FKeyComparer;
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TValue> >  FValueEqualityComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual int __fastcall Hash(const TKey AKey);
	virtual bool __fastcall KeysEqual(const TKey A, const TKey B);
	virtual bool __fastcall ValuesEqual(const TValue A, const TValue B);
	virtual System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall CreateEmptyArrayList(int ACapacity, bool AOwnsObjects);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	virtual System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall CreateEmptyArraySet(int ACapacity, bool AOwnsObjects);
	
public:
	__fastcall TJclHashMapE__2(const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TKey> >  AKeyEqualityComparer, const System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<TKey> >  AKeyHashConverter, const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TValue> >  AValueEqualityComparer, const System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TKey> >  AKeyComparer, int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__property System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TKey> >  KeyEqualityComparer = {read=FKeyEqualityComparer, write=FKeyEqualityComparer};
	__property System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<TKey> >  KeyHashConverter = {read=FKeyHashConverter, write=FKeyHashConverter};
	__property System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TKey> >  KeyComparer = {read=FKeyComparer, write=FKeyComparer};
	__property System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TValue> >  ValueEqualityComparer = {read=FValueEqualityComparer, write=FValueEqualityComparer};
public:
	/* TJclHashMap<TKey,TValue>.Destroy */ inline __fastcall virtual ~TJclHashMapE__2(void) { }
	
private:
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclMap__2;	/* Jclcontainerintf::IJclMap__2<TKey,TValue> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPairOwner__2<TKey,TValue>*(void) { return (IJclPairOwner__2<TKey,TValue>*)&__IJclPairOwner__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclPackable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclMap__2; }
	#endif
	
};


template<typename TKey, typename TValue> class DELPHICLASS TJclHashMapF__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclHashMapF__2 : public TJclHashMap__2<TKey,TValue>
{
	typedef TJclHashMap__2<TKey,TValue> inherited;
	
protected:
	
private:
	_decl_TEqualityCompare__1(TKey, FKeyEqualityCompare);
	// Jclcontainerintf::TEqualityCompare__1<TKey>  FKeyEqualityCompare;
	_decl_THashConvert__1(TKey, FKeyHash);
	// Jclcontainerintf::THashConvert__1<TKey>  FKeyHash;
	_decl_TCompare__1(TKey, FKeyCompare);
	// Jclcontainerintf::TCompare__1<TKey>  FKeyCompare;
	_decl_TEqualityCompare__1(TValue, FValueEqualityCompare);
	// Jclcontainerintf::TEqualityCompare__1<TValue>  FValueEqualityCompare;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual int __fastcall Hash(const TKey AKey);
	virtual bool __fastcall KeysEqual(const TKey A, const TKey B);
	virtual bool __fastcall ValuesEqual(const TValue A, const TValue B);
	virtual System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall CreateEmptyArrayList(int ACapacity, bool AOwnsObjects);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	virtual System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall CreateEmptyArraySet(int ACapacity, bool AOwnsObjects);
	
public:
	__fastcall TJclHashMapF__2(_decl_TEqualityCompare__1(TKey, AKeyEqualityCompare), _decl_THashConvert__1(TKey, AKeyHash), _decl_TEqualityCompare__1(TValue, AValueEqualityCompare), _decl_TCompare__1(TKey, AKeyCompare), int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__property _decl_TEqualityCompare__1(TKey, KeyEqualityCompare) = {read=FKeyEqualityCompare, write=FKeyEqualityCompare};
	// __property Jclcontainerintf::TEqualityCompare__1<TKey>  KeyEqualityCompare = {read=FKeyEqualityCompare, write=FKeyEqualityCompare};
	__property _decl_TCompare__1(TKey, KeyCompare) = {read=FKeyCompare, write=FKeyCompare};
	// __property Jclcontainerintf::TCompare__1<TKey>  KeyCompare = {read=FKeyCompare, write=FKeyCompare};
	__property _decl_THashConvert__1(TKey, KeyHash) = {read=FKeyHash, write=FKeyHash};
	// __property Jclcontainerintf::THashConvert__1<TKey>  KeyHash = {read=FKeyHash, write=FKeyHash};
	__property _decl_TEqualityCompare__1(TValue, ValueEqualityCompare) = {read=FValueEqualityCompare, write=FValueEqualityCompare};
	// __property Jclcontainerintf::TEqualityCompare__1<TValue>  ValueEqualityCompare = {read=FValueEqualityCompare, write=FValueEqualityCompare};
public:
	/* TJclHashMap<TKey,TValue>.Destroy */ inline __fastcall virtual ~TJclHashMapF__2(void) { }
	
private:
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclMap__2;	/* Jclcontainerintf::IJclMap__2<TKey,TValue> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPairOwner__2<TKey,TValue>*(void) { return (IJclPairOwner__2<TKey,TValue>*)&__IJclPairOwner__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclPackable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclMap__2; }
	#endif
	
};


template<typename TKey, typename TValue> class DELPHICLASS TJclHashMapI__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclHashMapI__2 : public TJclHashMap__2<TKey,TValue>
{
	typedef TJclHashMap__2<TKey,TValue> inherited;
	
protected:
	
protected:
	virtual int __fastcall Hash(const TKey AKey);
	virtual bool __fastcall KeysEqual(const TKey A, const TKey B);
	virtual bool __fastcall ValuesEqual(const TValue A, const TValue B);
	virtual System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall CreateEmptyArrayList(int ACapacity, bool AOwnsObjects);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	virtual System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall CreateEmptyArraySet(int ACapacity, bool AOwnsObjects);
public:
	/* TJclHashMap<TKey,TValue>.Create */ inline __fastcall TJclHashMapI__2(int ACapacity, bool AOwnsValues, bool AOwnsKeys) : TJclHashMap__2<TKey,TValue>(ACapacity, AOwnsValues, AOwnsKeys) { }
	/* TJclHashMap<TKey,TValue>.Destroy */ inline __fastcall virtual ~TJclHashMapI__2(void) { }
	
private:
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclMap__2;	/* Jclcontainerintf::IJclMap__2<TKey,TValue> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclPairOwner__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPairOwner__2<TKey,TValue>*(void) { return (IJclPairOwner__2<TKey,TValue>*)&__IJclPairOwner__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPackable()
	{
		Jclcontainerintf::_di_IJclPackable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPackable*(void) { return (IJclPackable*)&__IJclPackable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCloneable()
	{
		Jclcontainerintf::_di_IJclCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCloneable*(void) { return (IJclCloneable*)&__IJclCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCloneable()
	{
		Jclcontainerintf::_di_IJclIntfCloneable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCloneable*(void) { return (IJclIntfCloneable*)&__IJclIntfCloneable; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclMap__2; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE int __fastcall HashMul(int Key, int Range);

}	/* namespace Jclhashmaps */
using namespace Jclhashmaps;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclhashmapsHPP
