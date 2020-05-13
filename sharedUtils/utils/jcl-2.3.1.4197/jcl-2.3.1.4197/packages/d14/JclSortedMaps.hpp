// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclsortedmaps.pas' rev: 21.00

#ifndef JclsortedmapsHPP
#define JclsortedmapsHPP

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
#include <Jclabstractcontainers.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclarraylists.hpp>	// Pascal unit
#include <Jclarraysets.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclsortedmaps
{
//-- type declarations -------------------------------------------------------
struct TJclIntfIntfSortedEntry
{
	
public:
	System::_di_IInterface Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclIntfIntfSortedMap;
class PASCALIMPLEMENTATION TJclIntfIntfSortedMap : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfIntfSortedEntry> _TJclIntfIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclIntfIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfIntfSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfIntfSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfIntfSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfIntfSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfIntfSortedMap;	/* Jclcontainerintf::IJclIntfIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIntfSortedMap*(void) { return (IJclIntfIntfSortedMap*)&__IJclIntfIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIntfMap()
	{
		Jclcontainerintf::_di_IJclIntfIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIntfMap*(void) { return (IJclIntfIntfMap*)&__IJclIntfIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfIntfSortedMap; }
	#endif
	
};


struct TJclAnsiStrIntfSortedEntry
{
	
public:
	System::AnsiString Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclAnsiStrIntfSortedMap;
class PASCALIMPLEMENTATION TJclAnsiStrIntfSortedMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrIntfSortedEntry> _TJclAnsiStrIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::AnsiString __fastcall FreeKey(System::AnsiString &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const System::AnsiString A, const System::AnsiString B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclAnsiStrIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::AnsiString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclAnsiStrIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclAnsiStrIntfSortedMap(void);
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
	System::AnsiString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclAnsiStrIntfSortedMap __fastcall HeadMap(const System::AnsiString ToKey);
	System::AnsiString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclAnsiStrIntfSortedMap __fastcall SubMap(const System::AnsiString FromKey, const System::AnsiString ToKey);
	Jclcontainerintf::_di_IJclAnsiStrIntfSortedMap __fastcall TailMap(const System::AnsiString FromKey);
private:
	void *__IJclAnsiStrIntfSortedMap;	/* Jclcontainerintf::IJclAnsiStrIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIntfSortedMap*(void) { return (IJclAnsiStrIntfSortedMap*)&__IJclAnsiStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIntfMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIntfMap*(void) { return (IJclAnsiStrIntfMap*)&__IJclAnsiStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrIntfSortedMap; }
	#endif
	
};


struct TJclIntfAnsiStrSortedEntry
{
	
public:
	System::_di_IInterface Key;
	System::AnsiString Value;
};


class DELPHICLASS TJclIntfAnsiStrSortedMap;
class PASCALIMPLEMENTATION TJclIntfAnsiStrSortedMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfAnsiStrSortedEntry> _TJclIntfAnsiStrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::AnsiString __fastcall FreeValue(System::AnsiString &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const System::AnsiString A, const System::AnsiString B);
	
private:
	_TJclIntfAnsiStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfAnsiStrSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfAnsiStrSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfAnsiStrSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfAnsiStrSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfAnsiStrSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfAnsiStrSortedMap;	/* Jclcontainerintf::IJclIntfAnsiStrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfAnsiStrSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfAnsiStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfAnsiStrSortedMap*(void) { return (IJclIntfAnsiStrSortedMap*)&__IJclIntfAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfAnsiStrMap()
	{
		Jclcontainerintf::_di_IJclIntfAnsiStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfAnsiStrMap*(void) { return (IJclIntfAnsiStrMap*)&__IJclIntfAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclIntfAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclIntfAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfAnsiStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfAnsiStrSortedMap; }
	#endif
	
};


struct TJclAnsiStrAnsiStrSortedEntry
{
	
public:
	System::AnsiString Key;
	System::AnsiString Value;
};


class DELPHICLASS TJclAnsiStrAnsiStrSortedMap;
class PASCALIMPLEMENTATION TJclAnsiStrAnsiStrSortedMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrAnsiStrSortedEntry> _TJclAnsiStrAnsiStrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::AnsiString __fastcall FreeKey(System::AnsiString &Key);
	System::AnsiString __fastcall FreeValue(System::AnsiString &Value);
	int __fastcall KeysCompare(const System::AnsiString A, const System::AnsiString B);
	int __fastcall ValuesCompare(const System::AnsiString A, const System::AnsiString B);
	
private:
	_TJclAnsiStrAnsiStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::AnsiString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclAnsiStrAnsiStrSortedMap(int ACapacity);
	__fastcall virtual ~TJclAnsiStrAnsiStrSortedMap(void);
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
	System::AnsiString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclAnsiStrAnsiStrSortedMap __fastcall HeadMap(const System::AnsiString ToKey);
	System::AnsiString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclAnsiStrAnsiStrSortedMap __fastcall SubMap(const System::AnsiString FromKey, const System::AnsiString ToKey);
	Jclcontainerintf::_di_IJclAnsiStrAnsiStrSortedMap __fastcall TailMap(const System::AnsiString FromKey);
private:
	void *__IJclAnsiStrAnsiStrSortedMap;	/* Jclcontainerintf::IJclAnsiStrAnsiStrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrAnsiStrSortedMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrAnsiStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrAnsiStrSortedMap*(void) { return (IJclAnsiStrAnsiStrSortedMap*)&__IJclAnsiStrAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrAnsiStrMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrAnsiStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrAnsiStrMap*(void) { return (IJclAnsiStrAnsiStrMap*)&__IJclAnsiStrAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrAnsiStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrAnsiStrSortedMap; }
	#endif
	
};


struct TJclWideStrIntfSortedEntry
{
	
public:
	System::WideString Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclWideStrIntfSortedMap;
class PASCALIMPLEMENTATION TJclWideStrIntfSortedMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclWideStrIntfSortedEntry> _TJclWideStrIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::WideString __fastcall FreeKey(System::WideString &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const System::WideString A, const System::WideString B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclWideStrIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::WideString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclWideStrIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclWideStrIntfSortedMap(void);
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
	System::WideString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclWideStrIntfSortedMap __fastcall HeadMap(const System::WideString ToKey);
	System::WideString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclWideStrIntfSortedMap __fastcall SubMap(const System::WideString FromKey, const System::WideString ToKey);
	Jclcontainerintf::_di_IJclWideStrIntfSortedMap __fastcall TailMap(const System::WideString FromKey);
private:
	void *__IJclWideStrIntfSortedMap;	/* Jclcontainerintf::IJclWideStrIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclWideStrIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIntfSortedMap*(void) { return (IJclWideStrIntfSortedMap*)&__IJclWideStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIntfMap()
	{
		Jclcontainerintf::_di_IJclWideStrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIntfMap*(void) { return (IJclWideStrIntfMap*)&__IJclWideStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrIntfSortedMap; }
	#endif
	
};


struct TJclIntfWideStrSortedEntry
{
	
public:
	System::_di_IInterface Key;
	System::WideString Value;
};


class DELPHICLASS TJclIntfWideStrSortedMap;
class PASCALIMPLEMENTATION TJclIntfWideStrSortedMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfWideStrSortedEntry> _TJclIntfWideStrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::WideString __fastcall FreeValue(System::WideString &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const System::WideString A, const System::WideString B);
	
private:
	_TJclIntfWideStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfWideStrSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfWideStrSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfWideStrSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfWideStrSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfWideStrSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfWideStrSortedMap;	/* Jclcontainerintf::IJclIntfWideStrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfWideStrSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfWideStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfWideStrSortedMap*(void) { return (IJclIntfWideStrSortedMap*)&__IJclIntfWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfWideStrMap()
	{
		Jclcontainerintf::_di_IJclIntfWideStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfWideStrMap*(void) { return (IJclIntfWideStrMap*)&__IJclIntfWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclIntfWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclIntfWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfWideStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfWideStrSortedMap; }
	#endif
	
};


struct TJclWideStrWideStrSortedEntry
{
	
public:
	System::WideString Key;
	System::WideString Value;
};


class DELPHICLASS TJclWideStrWideStrSortedMap;
class PASCALIMPLEMENTATION TJclWideStrWideStrSortedMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclWideStrWideStrSortedEntry> _TJclWideStrWideStrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::WideString __fastcall FreeKey(System::WideString &Key);
	System::WideString __fastcall FreeValue(System::WideString &Value);
	int __fastcall KeysCompare(const System::WideString A, const System::WideString B);
	int __fastcall ValuesCompare(const System::WideString A, const System::WideString B);
	
private:
	_TJclWideStrWideStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::WideString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclWideStrWideStrSortedMap(int ACapacity);
	__fastcall virtual ~TJclWideStrWideStrSortedMap(void);
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
	System::WideString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclWideStrWideStrSortedMap __fastcall HeadMap(const System::WideString ToKey);
	System::WideString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclWideStrWideStrSortedMap __fastcall SubMap(const System::WideString FromKey, const System::WideString ToKey);
	Jclcontainerintf::_di_IJclWideStrWideStrSortedMap __fastcall TailMap(const System::WideString FromKey);
private:
	void *__IJclWideStrWideStrSortedMap;	/* Jclcontainerintf::IJclWideStrWideStrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrWideStrSortedMap()
	{
		Jclcontainerintf::_di_IJclWideStrWideStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrWideStrSortedMap*(void) { return (IJclWideStrWideStrSortedMap*)&__IJclWideStrWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrWideStrMap()
	{
		Jclcontainerintf::_di_IJclWideStrWideStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrWideStrMap*(void) { return (IJclWideStrWideStrMap*)&__IJclWideStrWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrWideStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrWideStrSortedMap; }
	#endif
	
};


struct TJclUnicodeStrIntfSortedEntry
{
	
public:
	System::UnicodeString Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclUnicodeStrIntfSortedMap;
class PASCALIMPLEMENTATION TJclUnicodeStrIntfSortedMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrIntfSortedEntry> _TJclUnicodeStrIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::UnicodeString __fastcall FreeKey(System::UnicodeString &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const System::UnicodeString A, const System::UnicodeString B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclUnicodeStrIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::UnicodeString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclUnicodeStrIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclUnicodeStrIntfSortedMap(void);
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
	System::UnicodeString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclUnicodeStrIntfSortedMap __fastcall HeadMap(const System::UnicodeString ToKey);
	System::UnicodeString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclUnicodeStrIntfSortedMap __fastcall SubMap(const System::UnicodeString FromKey, const System::UnicodeString ToKey);
	Jclcontainerintf::_di_IJclUnicodeStrIntfSortedMap __fastcall TailMap(const System::UnicodeString FromKey);
private:
	void *__IJclUnicodeStrIntfSortedMap;	/* Jclcontainerintf::IJclUnicodeStrIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIntfSortedMap*(void) { return (IJclUnicodeStrIntfSortedMap*)&__IJclUnicodeStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIntfMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIntfMap*(void) { return (IJclUnicodeStrIntfMap*)&__IJclUnicodeStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrIntfSortedMap; }
	#endif
	
};


struct TJclIntfUnicodeStrSortedEntry
{
	
public:
	System::_di_IInterface Key;
	System::UnicodeString Value;
};


class DELPHICLASS TJclIntfUnicodeStrSortedMap;
class PASCALIMPLEMENTATION TJclIntfUnicodeStrSortedMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfUnicodeStrSortedEntry> _TJclIntfUnicodeStrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::UnicodeString __fastcall FreeValue(System::UnicodeString &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const System::UnicodeString A, const System::UnicodeString B);
	
private:
	_TJclIntfUnicodeStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfUnicodeStrSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfUnicodeStrSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfUnicodeStrSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfUnicodeStrSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfUnicodeStrSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfUnicodeStrSortedMap;	/* Jclcontainerintf::IJclIntfUnicodeStrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfUnicodeStrSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfUnicodeStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfUnicodeStrSortedMap*(void) { return (IJclIntfUnicodeStrSortedMap*)&__IJclIntfUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfUnicodeStrMap()
	{
		Jclcontainerintf::_di_IJclIntfUnicodeStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfUnicodeStrMap*(void) { return (IJclIntfUnicodeStrMap*)&__IJclIntfUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclIntfUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclIntfUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfUnicodeStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfUnicodeStrSortedMap; }
	#endif
	
};


struct TJclUnicodeStrUnicodeStrSortedEntry
{
	
public:
	System::UnicodeString Key;
	System::UnicodeString Value;
};


class DELPHICLASS TJclUnicodeStrUnicodeStrSortedMap;
class PASCALIMPLEMENTATION TJclUnicodeStrUnicodeStrSortedMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrUnicodeStrSortedEntry> _TJclUnicodeStrUnicodeStrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::UnicodeString __fastcall FreeKey(System::UnicodeString &Key);
	System::UnicodeString __fastcall FreeValue(System::UnicodeString &Value);
	int __fastcall KeysCompare(const System::UnicodeString A, const System::UnicodeString B);
	int __fastcall ValuesCompare(const System::UnicodeString A, const System::UnicodeString B);
	
private:
	_TJclUnicodeStrUnicodeStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::UnicodeString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclUnicodeStrUnicodeStrSortedMap(int ACapacity);
	__fastcall virtual ~TJclUnicodeStrUnicodeStrSortedMap(void);
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
	System::UnicodeString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrSortedMap __fastcall HeadMap(const System::UnicodeString ToKey);
	System::UnicodeString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrSortedMap __fastcall SubMap(const System::UnicodeString FromKey, const System::UnicodeString ToKey);
	Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrSortedMap __fastcall TailMap(const System::UnicodeString FromKey);
private:
	void *__IJclUnicodeStrUnicodeStrSortedMap;	/* Jclcontainerintf::IJclUnicodeStrUnicodeStrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrSortedMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrUnicodeStrSortedMap*(void) { return (IJclUnicodeStrUnicodeStrSortedMap*)&__IJclUnicodeStrUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrUnicodeStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrUnicodeStrMap*(void) { return (IJclUnicodeStrUnicodeStrMap*)&__IJclUnicodeStrUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrUnicodeStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrUnicodeStrSortedMap; }
	#endif
	
};


typedef TJclUnicodeStrIntfSortedEntry TJclStrIntfSortedEntry;

typedef TJclUnicodeStrIntfSortedMap TJclStrIntfSortedMap;

typedef TJclIntfUnicodeStrSortedEntry TJclIntfStrSortedEntry;

typedef TJclIntfUnicodeStrSortedMap TJclIntfStrSortedMap;

typedef TJclUnicodeStrUnicodeStrSortedEntry TJclStrStrSortedEntry;

typedef TJclUnicodeStrUnicodeStrSortedMap TJclStrStrSortedMap;

struct TJclSingleIntfSortedEntry
{
	
public:
	float Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclSingleIntfSortedMap;
class PASCALIMPLEMENTATION TJclSingleIntfSortedMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclSingleIntfSortedEntry> _TJclSingleIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	float __fastcall FreeKey(float &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const float A, const float B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclSingleIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const float Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclSingleIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclSingleIntfSortedMap(void);
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
	float __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclSingleIntfSortedMap __fastcall HeadMap(const float ToKey);
	float __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclSingleIntfSortedMap __fastcall SubMap(const float FromKey, const float ToKey);
	Jclcontainerintf::_di_IJclSingleIntfSortedMap __fastcall TailMap(const float FromKey);
private:
	void *__IJclSingleIntfSortedMap;	/* Jclcontainerintf::IJclSingleIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclSingleIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIntfSortedMap*(void) { return (IJclSingleIntfSortedMap*)&__IJclSingleIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIntfMap()
	{
		Jclcontainerintf::_di_IJclSingleIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIntfMap*(void) { return (IJclSingleIntfMap*)&__IJclSingleIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleIntfSortedMap; }
	#endif
	
};


struct TJclIntfSingleSortedEntry
{
	
public:
	System::_di_IInterface Key;
	float Value;
};


class DELPHICLASS TJclIntfSingleSortedMap;
class PASCALIMPLEMENTATION TJclIntfSingleSortedMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfSingleSortedEntry> _TJclIntfSingleSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	float __fastcall FreeValue(float &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const float A, const float B);
	
private:
	_TJclIntfSingleSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfSingleSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfSingleSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfSingleSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfSingleSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfSingleSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfSingleSortedMap;	/* Jclcontainerintf::IJclIntfSingleSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfSingleSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfSingleSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfSingleSortedMap*(void) { return (IJclIntfSingleSortedMap*)&__IJclIntfSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfSingleMap()
	{
		Jclcontainerintf::_di_IJclIntfSingleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfSingleMap*(void) { return (IJclIntfSingleMap*)&__IJclIntfSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclIntfSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfSingleSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfSingleSortedMap; }
	#endif
	
};


struct TJclSingleSingleSortedEntry
{
	
public:
	float Key;
	float Value;
};


class DELPHICLASS TJclSingleSingleSortedMap;
class PASCALIMPLEMENTATION TJclSingleSingleSortedMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclSingleSingleSortedEntry> _TJclSingleSingleSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	float __fastcall FreeKey(float &Key);
	float __fastcall FreeValue(float &Value);
	int __fastcall KeysCompare(const float A, const float B);
	int __fastcall ValuesCompare(const float A, const float B);
	
private:
	_TJclSingleSingleSortedMap__1 FEntries;
	int __fastcall BinarySearch(const float Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclSingleSingleSortedMap(int ACapacity);
	__fastcall virtual ~TJclSingleSingleSortedMap(void);
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
	float __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclSingleSingleSortedMap __fastcall HeadMap(const float ToKey);
	float __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclSingleSingleSortedMap __fastcall SubMap(const float FromKey, const float ToKey);
	Jclcontainerintf::_di_IJclSingleSingleSortedMap __fastcall TailMap(const float FromKey);
private:
	void *__IJclSingleSingleSortedMap;	/* Jclcontainerintf::IJclSingleSingleSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleSingleSortedMap()
	{
		Jclcontainerintf::_di_IJclSingleSingleSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleSingleSortedMap*(void) { return (IJclSingleSingleSortedMap*)&__IJclSingleSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleSingleMap()
	{
		Jclcontainerintf::_di_IJclSingleSingleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleSingleMap*(void) { return (IJclSingleSingleMap*)&__IJclSingleSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleSingleSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleSingleSortedMap; }
	#endif
	
};


struct TJclDoubleIntfSortedEntry
{
	
public:
	double Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclDoubleIntfSortedMap;
class PASCALIMPLEMENTATION TJclDoubleIntfSortedMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclDoubleIntfSortedEntry> _TJclDoubleIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	double __fastcall FreeKey(double &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const double A, const double B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclDoubleIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const double Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclDoubleIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclDoubleIntfSortedMap(void);
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
	double __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclDoubleIntfSortedMap __fastcall HeadMap(const double ToKey);
	double __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclDoubleIntfSortedMap __fastcall SubMap(const double FromKey, const double ToKey);
	Jclcontainerintf::_di_IJclDoubleIntfSortedMap __fastcall TailMap(const double FromKey);
private:
	void *__IJclDoubleIntfSortedMap;	/* Jclcontainerintf::IJclDoubleIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclDoubleIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIntfSortedMap*(void) { return (IJclDoubleIntfSortedMap*)&__IJclDoubleIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIntfMap()
	{
		Jclcontainerintf::_di_IJclDoubleIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIntfMap*(void) { return (IJclDoubleIntfMap*)&__IJclDoubleIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleIntfSortedMap; }
	#endif
	
};


struct TJclIntfDoubleSortedEntry
{
	
public:
	System::_di_IInterface Key;
	double Value;
};


class DELPHICLASS TJclIntfDoubleSortedMap;
class PASCALIMPLEMENTATION TJclIntfDoubleSortedMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfDoubleSortedEntry> _TJclIntfDoubleSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	double __fastcall FreeValue(double &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const double A, const double B);
	
private:
	_TJclIntfDoubleSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfDoubleSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfDoubleSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfDoubleSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfDoubleSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfDoubleSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfDoubleSortedMap;	/* Jclcontainerintf::IJclIntfDoubleSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfDoubleSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfDoubleSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfDoubleSortedMap*(void) { return (IJclIntfDoubleSortedMap*)&__IJclIntfDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfDoubleMap()
	{
		Jclcontainerintf::_di_IJclIntfDoubleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfDoubleMap*(void) { return (IJclIntfDoubleMap*)&__IJclIntfDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclIntfDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfDoubleSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfDoubleSortedMap; }
	#endif
	
};


struct TJclDoubleDoubleSortedEntry
{
	
public:
	double Key;
	double Value;
};


class DELPHICLASS TJclDoubleDoubleSortedMap;
class PASCALIMPLEMENTATION TJclDoubleDoubleSortedMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclDoubleDoubleSortedEntry> _TJclDoubleDoubleSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	double __fastcall FreeKey(double &Key);
	double __fastcall FreeValue(double &Value);
	int __fastcall KeysCompare(const double A, const double B);
	int __fastcall ValuesCompare(const double A, const double B);
	
private:
	_TJclDoubleDoubleSortedMap__1 FEntries;
	int __fastcall BinarySearch(const double Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclDoubleDoubleSortedMap(int ACapacity);
	__fastcall virtual ~TJclDoubleDoubleSortedMap(void);
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
	double __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclDoubleDoubleSortedMap __fastcall HeadMap(const double ToKey);
	double __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclDoubleDoubleSortedMap __fastcall SubMap(const double FromKey, const double ToKey);
	Jclcontainerintf::_di_IJclDoubleDoubleSortedMap __fastcall TailMap(const double FromKey);
private:
	void *__IJclDoubleDoubleSortedMap;	/* Jclcontainerintf::IJclDoubleDoubleSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleDoubleSortedMap()
	{
		Jclcontainerintf::_di_IJclDoubleDoubleSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleDoubleSortedMap*(void) { return (IJclDoubleDoubleSortedMap*)&__IJclDoubleDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleDoubleMap()
	{
		Jclcontainerintf::_di_IJclDoubleDoubleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleDoubleMap*(void) { return (IJclDoubleDoubleMap*)&__IJclDoubleDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleDoubleSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleDoubleSortedMap; }
	#endif
	
};


struct TJclExtendedIntfSortedEntry
{
	
public:
	System::Extended Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclExtendedIntfSortedMap;
class PASCALIMPLEMENTATION TJclExtendedIntfSortedMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclExtendedIntfSortedEntry> _TJclExtendedIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::Extended __fastcall FreeKey(System::Extended &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const System::Extended A, const System::Extended B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclExtendedIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::Extended Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclExtendedIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclExtendedIntfSortedMap(void);
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
	System::Extended __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclExtendedIntfSortedMap __fastcall HeadMap(const System::Extended ToKey);
	System::Extended __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclExtendedIntfSortedMap __fastcall SubMap(const System::Extended FromKey, const System::Extended ToKey);
	Jclcontainerintf::_di_IJclExtendedIntfSortedMap __fastcall TailMap(const System::Extended FromKey);
private:
	void *__IJclExtendedIntfSortedMap;	/* Jclcontainerintf::IJclExtendedIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclExtendedIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIntfSortedMap*(void) { return (IJclExtendedIntfSortedMap*)&__IJclExtendedIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIntfMap()
	{
		Jclcontainerintf::_di_IJclExtendedIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIntfMap*(void) { return (IJclExtendedIntfMap*)&__IJclExtendedIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedIntfSortedMap; }
	#endif
	
};


struct TJclIntfExtendedSortedEntry
{
	
public:
	System::_di_IInterface Key;
	System::Extended Value;
};


class DELPHICLASS TJclIntfExtendedSortedMap;
class PASCALIMPLEMENTATION TJclIntfExtendedSortedMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfExtendedSortedEntry> _TJclIntfExtendedSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	System::Extended __fastcall FreeValue(System::Extended &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const System::Extended A, const System::Extended B);
	
private:
	_TJclIntfExtendedSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfExtendedSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfExtendedSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfExtendedSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfExtendedSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfExtendedSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfExtendedSortedMap;	/* Jclcontainerintf::IJclIntfExtendedSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfExtendedSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfExtendedSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfExtendedSortedMap*(void) { return (IJclIntfExtendedSortedMap*)&__IJclIntfExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfExtendedMap()
	{
		Jclcontainerintf::_di_IJclIntfExtendedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfExtendedMap*(void) { return (IJclIntfExtendedMap*)&__IJclIntfExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclIntfExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfExtendedSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfExtendedSortedMap; }
	#endif
	
};


struct TJclExtendedExtendedSortedEntry
{
	
public:
	System::Extended Key;
	System::Extended Value;
};


class DELPHICLASS TJclExtendedExtendedSortedMap;
class PASCALIMPLEMENTATION TJclExtendedExtendedSortedMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclExtendedExtendedSortedEntry> _TJclExtendedExtendedSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::Extended __fastcall FreeKey(System::Extended &Key);
	System::Extended __fastcall FreeValue(System::Extended &Value);
	int __fastcall KeysCompare(const System::Extended A, const System::Extended B);
	int __fastcall ValuesCompare(const System::Extended A, const System::Extended B);
	
private:
	_TJclExtendedExtendedSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::Extended Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclExtendedExtendedSortedMap(int ACapacity);
	__fastcall virtual ~TJclExtendedExtendedSortedMap(void);
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
	System::Extended __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclExtendedExtendedSortedMap __fastcall HeadMap(const System::Extended ToKey);
	System::Extended __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclExtendedExtendedSortedMap __fastcall SubMap(const System::Extended FromKey, const System::Extended ToKey);
	Jclcontainerintf::_di_IJclExtendedExtendedSortedMap __fastcall TailMap(const System::Extended FromKey);
private:
	void *__IJclExtendedExtendedSortedMap;	/* Jclcontainerintf::IJclExtendedExtendedSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedExtendedSortedMap()
	{
		Jclcontainerintf::_di_IJclExtendedExtendedSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedExtendedSortedMap*(void) { return (IJclExtendedExtendedSortedMap*)&__IJclExtendedExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedExtendedMap()
	{
		Jclcontainerintf::_di_IJclExtendedExtendedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedExtendedMap*(void) { return (IJclExtendedExtendedMap*)&__IJclExtendedExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedExtendedSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedExtendedSortedMap; }
	#endif
	
};


typedef TJclExtendedIntfSortedEntry TJclFloatIntfSortedEntry;

typedef TJclExtendedIntfSortedMap TJclFloatIntfSortedMap;

typedef TJclIntfExtendedSortedEntry TJclIntfFloatSortedEntry;

typedef TJclIntfExtendedSortedMap TJclIntfFloatSortedMap;

typedef TJclExtendedExtendedSortedEntry TJclFloatFloatSortedEntry;

typedef TJclExtendedExtendedSortedMap TJclFloatFloatSortedMap;

struct TJclIntegerIntfSortedEntry
{
	
public:
	int Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclIntegerIntfSortedMap;
class PASCALIMPLEMENTATION TJclIntegerIntfSortedMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntegerIntfSortedEntry> _TJclIntegerIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall FreeKey(int &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(int A, int B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclIntegerIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(int Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntegerIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntegerIntfSortedMap(void);
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
	int __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntegerIntfSortedMap __fastcall HeadMap(int ToKey);
	int __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntegerIntfSortedMap __fastcall SubMap(int FromKey, int ToKey);
	Jclcontainerintf::_di_IJclIntegerIntfSortedMap __fastcall TailMap(int FromKey);
private:
	void *__IJclIntegerIntfSortedMap;	/* Jclcontainerintf::IJclIntegerIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclIntegerIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIntfSortedMap*(void) { return (IJclIntegerIntfSortedMap*)&__IJclIntegerIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIntfMap()
	{
		Jclcontainerintf::_di_IJclIntegerIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIntfMap*(void) { return (IJclIntegerIntfMap*)&__IJclIntegerIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerIntfSortedMap; }
	#endif
	
};


struct TJclIntfIntegerSortedEntry
{
	
public:
	System::_di_IInterface Key;
	int Value;
};


class DELPHICLASS TJclIntfIntegerSortedMap;
class PASCALIMPLEMENTATION TJclIntfIntegerSortedMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfIntegerSortedEntry> _TJclIntfIntegerSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	int __fastcall FreeValue(int &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(int A, int B);
	
private:
	_TJclIntfIntegerSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfIntegerSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfIntegerSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfIntegerSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfIntegerSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfIntegerSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfIntegerSortedMap;	/* Jclcontainerintf::IJclIntfIntegerSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIntegerSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfIntegerSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIntegerSortedMap*(void) { return (IJclIntfIntegerSortedMap*)&__IJclIntfIntegerSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIntegerMap()
	{
		Jclcontainerintf::_di_IJclIntfIntegerMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIntegerMap*(void) { return (IJclIntfIntegerMap*)&__IJclIntfIntegerSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfIntegerSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfIntegerSortedMap; }
	#endif
	
};


struct TJclIntegerIntegerSortedEntry
{
	
public:
	int Key;
	int Value;
};


class DELPHICLASS TJclIntegerIntegerSortedMap;
class PASCALIMPLEMENTATION TJclIntegerIntegerSortedMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntegerIntegerSortedEntry> _TJclIntegerIntegerSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall FreeKey(int &Key);
	int __fastcall FreeValue(int &Value);
	int __fastcall KeysCompare(int A, int B);
	int __fastcall ValuesCompare(int A, int B);
	
private:
	_TJclIntegerIntegerSortedMap__1 FEntries;
	int __fastcall BinarySearch(int Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntegerIntegerSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntegerIntegerSortedMap(void);
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
	int __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntegerIntegerSortedMap __fastcall HeadMap(int ToKey);
	int __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntegerIntegerSortedMap __fastcall SubMap(int FromKey, int ToKey);
	Jclcontainerintf::_di_IJclIntegerIntegerSortedMap __fastcall TailMap(int FromKey);
private:
	void *__IJclIntegerIntegerSortedMap;	/* Jclcontainerintf::IJclIntegerIntegerSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIntegerSortedMap()
	{
		Jclcontainerintf::_di_IJclIntegerIntegerSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIntegerSortedMap*(void) { return (IJclIntegerIntegerSortedMap*)&__IJclIntegerIntegerSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIntegerMap()
	{
		Jclcontainerintf::_di_IJclIntegerIntegerMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIntegerMap*(void) { return (IJclIntegerIntegerMap*)&__IJclIntegerIntegerSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerIntegerSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerIntegerSortedMap; }
	#endif
	
};


struct TJclCardinalIntfSortedEntry
{
	
public:
	unsigned Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclCardinalIntfSortedMap;
class PASCALIMPLEMENTATION TJclCardinalIntfSortedMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclCardinalIntfSortedEntry> _TJclCardinalIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	unsigned __fastcall FreeKey(unsigned &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(unsigned A, unsigned B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclCardinalIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(unsigned Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclCardinalIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclCardinalIntfSortedMap(void);
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
	unsigned __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclCardinalIntfSortedMap __fastcall HeadMap(unsigned ToKey);
	unsigned __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclCardinalIntfSortedMap __fastcall SubMap(unsigned FromKey, unsigned ToKey);
	Jclcontainerintf::_di_IJclCardinalIntfSortedMap __fastcall TailMap(unsigned FromKey);
private:
	void *__IJclCardinalIntfSortedMap;	/* Jclcontainerintf::IJclCardinalIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclCardinalIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIntfSortedMap*(void) { return (IJclCardinalIntfSortedMap*)&__IJclCardinalIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIntfMap()
	{
		Jclcontainerintf::_di_IJclCardinalIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIntfMap*(void) { return (IJclCardinalIntfMap*)&__IJclCardinalIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalIntfSortedMap; }
	#endif
	
};


struct TJclIntfCardinalSortedEntry
{
	
public:
	System::_di_IInterface Key;
	unsigned Value;
};


class DELPHICLASS TJclIntfCardinalSortedMap;
class PASCALIMPLEMENTATION TJclIntfCardinalSortedMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfCardinalSortedEntry> _TJclIntfCardinalSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	unsigned __fastcall FreeValue(unsigned &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(unsigned A, unsigned B);
	
private:
	_TJclIntfCardinalSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfCardinalSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfCardinalSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfCardinalSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfCardinalSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfCardinalSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfCardinalSortedMap;	/* Jclcontainerintf::IJclIntfCardinalSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCardinalSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfCardinalSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCardinalSortedMap*(void) { return (IJclIntfCardinalSortedMap*)&__IJclIntfCardinalSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCardinalMap()
	{
		Jclcontainerintf::_di_IJclIntfCardinalMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCardinalMap*(void) { return (IJclIntfCardinalMap*)&__IJclIntfCardinalSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfCardinalSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfCardinalSortedMap; }
	#endif
	
};


struct TJclCardinalCardinalSortedEntry
{
	
public:
	unsigned Key;
	unsigned Value;
};


class DELPHICLASS TJclCardinalCardinalSortedMap;
class PASCALIMPLEMENTATION TJclCardinalCardinalSortedMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclCardinalCardinalSortedEntry> _TJclCardinalCardinalSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	unsigned __fastcall FreeKey(unsigned &Key);
	unsigned __fastcall FreeValue(unsigned &Value);
	int __fastcall KeysCompare(unsigned A, unsigned B);
	int __fastcall ValuesCompare(unsigned A, unsigned B);
	
private:
	_TJclCardinalCardinalSortedMap__1 FEntries;
	int __fastcall BinarySearch(unsigned Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclCardinalCardinalSortedMap(int ACapacity);
	__fastcall virtual ~TJclCardinalCardinalSortedMap(void);
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
	unsigned __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclCardinalCardinalSortedMap __fastcall HeadMap(unsigned ToKey);
	unsigned __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclCardinalCardinalSortedMap __fastcall SubMap(unsigned FromKey, unsigned ToKey);
	Jclcontainerintf::_di_IJclCardinalCardinalSortedMap __fastcall TailMap(unsigned FromKey);
private:
	void *__IJclCardinalCardinalSortedMap;	/* Jclcontainerintf::IJclCardinalCardinalSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalCardinalSortedMap()
	{
		Jclcontainerintf::_di_IJclCardinalCardinalSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalCardinalSortedMap*(void) { return (IJclCardinalCardinalSortedMap*)&__IJclCardinalCardinalSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalCardinalMap()
	{
		Jclcontainerintf::_di_IJclCardinalCardinalMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalCardinalMap*(void) { return (IJclCardinalCardinalMap*)&__IJclCardinalCardinalSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalCardinalSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalCardinalSortedMap; }
	#endif
	
};


struct TJclInt64IntfSortedEntry
{
	
public:
	__int64 Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclInt64IntfSortedMap;
class PASCALIMPLEMENTATION TJclInt64IntfSortedMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclInt64IntfSortedEntry> _TJclInt64IntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	__int64 __fastcall FreeKey(__int64 &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(const __int64 A, const __int64 B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclInt64IntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const __int64 Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclInt64IntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclInt64IntfSortedMap(void);
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
	__int64 __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclInt64IntfSortedMap __fastcall HeadMap(const __int64 ToKey);
	__int64 __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclInt64IntfSortedMap __fastcall SubMap(const __int64 FromKey, const __int64 ToKey);
	Jclcontainerintf::_di_IJclInt64IntfSortedMap __fastcall TailMap(const __int64 FromKey);
private:
	void *__IJclInt64IntfSortedMap;	/* Jclcontainerintf::IJclInt64IntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64IntfSortedMap()
	{
		Jclcontainerintf::_di_IJclInt64IntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64IntfSortedMap*(void) { return (IJclInt64IntfSortedMap*)&__IJclInt64IntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64IntfMap()
	{
		Jclcontainerintf::_di_IJclInt64IntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64IntfMap*(void) { return (IJclInt64IntfMap*)&__IJclInt64IntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64IntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64IntfSortedMap; }
	#endif
	
};


struct TJclIntfInt64SortedEntry
{
	
public:
	System::_di_IInterface Key;
	__int64 Value;
};


class DELPHICLASS TJclIntfInt64SortedMap;
class PASCALIMPLEMENTATION TJclIntfInt64SortedMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfInt64SortedEntry> _TJclIntfInt64SortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	__int64 __fastcall FreeValue(__int64 &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(const __int64 A, const __int64 B);
	
private:
	_TJclIntfInt64SortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfInt64SortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfInt64SortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfInt64SortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfInt64SortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfInt64SortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfInt64SortedMap;	/* Jclcontainerintf::IJclIntfInt64SortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfInt64SortedMap()
	{
		Jclcontainerintf::_di_IJclIntfInt64SortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfInt64SortedMap*(void) { return (IJclIntfInt64SortedMap*)&__IJclIntfInt64SortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfInt64Map()
	{
		Jclcontainerintf::_di_IJclIntfInt64Map intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfInt64Map*(void) { return (IJclIntfInt64Map*)&__IJclIntfInt64SortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfInt64SortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfInt64SortedMap; }
	#endif
	
};


struct TJclInt64Int64SortedEntry
{
	
public:
	__int64 Key;
	__int64 Value;
};


class DELPHICLASS TJclInt64Int64SortedMap;
class PASCALIMPLEMENTATION TJclInt64Int64SortedMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclInt64Int64SortedEntry> _TJclInt64Int64SortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	__int64 __fastcall FreeKey(__int64 &Key);
	__int64 __fastcall FreeValue(__int64 &Value);
	int __fastcall KeysCompare(const __int64 A, const __int64 B);
	int __fastcall ValuesCompare(const __int64 A, const __int64 B);
	
private:
	_TJclInt64Int64SortedMap__1 FEntries;
	int __fastcall BinarySearch(const __int64 Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclInt64Int64SortedMap(int ACapacity);
	__fastcall virtual ~TJclInt64Int64SortedMap(void);
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
	__int64 __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclInt64Int64SortedMap __fastcall HeadMap(const __int64 ToKey);
	__int64 __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclInt64Int64SortedMap __fastcall SubMap(const __int64 FromKey, const __int64 ToKey);
	Jclcontainerintf::_di_IJclInt64Int64SortedMap __fastcall TailMap(const __int64 FromKey);
private:
	void *__IJclInt64Int64SortedMap;	/* Jclcontainerintf::IJclInt64Int64SortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Int64SortedMap()
	{
		Jclcontainerintf::_di_IJclInt64Int64SortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Int64SortedMap*(void) { return (IJclInt64Int64SortedMap*)&__IJclInt64Int64SortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Int64Map()
	{
		Jclcontainerintf::_di_IJclInt64Int64Map intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Int64Map*(void) { return (IJclInt64Int64Map*)&__IJclInt64Int64SortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Int64SortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Int64SortedMap; }
	#endif
	
};


struct TJclPtrIntfSortedEntry
{
	
public:
	void *Key;
	System::_di_IInterface Value;
};


class DELPHICLASS TJclPtrIntfSortedMap;
class PASCALIMPLEMENTATION TJclPtrIntfSortedMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclPtrIntfSortedEntry> _TJclPtrIntfSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	void * __fastcall FreeKey(void * &Key);
	System::_di_IInterface __fastcall FreeValue(System::_di_IInterface &Value);
	int __fastcall KeysCompare(void * A, void * B);
	int __fastcall ValuesCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	
private:
	_TJclPtrIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(void * Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclPtrIntfSortedMap(int ACapacity);
	__fastcall virtual ~TJclPtrIntfSortedMap(void);
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
	void * __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclPtrIntfSortedMap __fastcall HeadMap(void * ToKey);
	void * __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclPtrIntfSortedMap __fastcall SubMap(void * FromKey, void * ToKey);
	Jclcontainerintf::_di_IJclPtrIntfSortedMap __fastcall TailMap(void * FromKey);
private:
	void *__IJclPtrIntfSortedMap;	/* Jclcontainerintf::IJclPtrIntfSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclPtrIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIntfSortedMap*(void) { return (IJclPtrIntfSortedMap*)&__IJclPtrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIntfMap()
	{
		Jclcontainerintf::_di_IJclPtrIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIntfMap*(void) { return (IJclPtrIntfMap*)&__IJclPtrIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrIntfSortedMap; }
	#endif
	
};


struct TJclIntfPtrSortedEntry
{
	
public:
	System::_di_IInterface Key;
	void *Value;
};


class DELPHICLASS TJclIntfPtrSortedMap;
class PASCALIMPLEMENTATION TJclIntfPtrSortedMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfPtrSortedEntry> _TJclIntfPtrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	void * __fastcall FreeValue(void * &Value);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(void * A, void * B);
	
private:
	_TJclIntfPtrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfPtrSortedMap(int ACapacity);
	__fastcall virtual ~TJclIntfPtrSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfPtrSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfPtrSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfPtrSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfPtrSortedMap;	/* Jclcontainerintf::IJclIntfPtrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfPtrSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfPtrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfPtrSortedMap*(void) { return (IJclIntfPtrSortedMap*)&__IJclIntfPtrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfPtrMap()
	{
		Jclcontainerintf::_di_IJclIntfPtrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfPtrMap*(void) { return (IJclIntfPtrMap*)&__IJclIntfPtrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfPtrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfPtrSortedMap; }
	#endif
	
};


struct TJclPtrPtrSortedEntry
{
	
public:
	void *Key;
	void *Value;
};


class DELPHICLASS TJclPtrPtrSortedMap;
class PASCALIMPLEMENTATION TJclPtrPtrSortedMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclPtrPtrSortedEntry> _TJclPtrPtrSortedMap__1;
	
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	void * __fastcall FreeKey(void * &Key);
	void * __fastcall FreeValue(void * &Value);
	int __fastcall KeysCompare(void * A, void * B);
	int __fastcall ValuesCompare(void * A, void * B);
	
private:
	_TJclPtrPtrSortedMap__1 FEntries;
	int __fastcall BinarySearch(void * Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclPtrPtrSortedMap(int ACapacity);
	__fastcall virtual ~TJclPtrPtrSortedMap(void);
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
	void * __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclPtrPtrSortedMap __fastcall HeadMap(void * ToKey);
	void * __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclPtrPtrSortedMap __fastcall SubMap(void * FromKey, void * ToKey);
	Jclcontainerintf::_di_IJclPtrPtrSortedMap __fastcall TailMap(void * FromKey);
private:
	void *__IJclPtrPtrSortedMap;	/* Jclcontainerintf::IJclPtrPtrSortedMap */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrPtrSortedMap()
	{
		Jclcontainerintf::_di_IJclPtrPtrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrPtrSortedMap*(void) { return (IJclPtrPtrSortedMap*)&__IJclPtrPtrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrPtrMap()
	{
		Jclcontainerintf::_di_IJclPtrPtrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrPtrMap*(void) { return (IJclPtrPtrMap*)&__IJclPtrPtrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrPtrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrPtrSortedMap; }
	#endif
	
};


struct TJclIntfSortedEntry
{
	
public:
	System::_di_IInterface Key;
	System::TObject* Value;
};


class DELPHICLASS TJclIntfSortedMap;
class PASCALIMPLEMENTATION TJclIntfSortedMap : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntfSortedEntry> _TJclIntfSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::_di_IInterface __fastcall FreeKey(System::_di_IInterface &Key);
	int __fastcall KeysCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclIntfSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::_di_IInterface Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntfSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclIntfSortedMap(void);
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
	System::_di_IInterface __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntfSortedMap __fastcall HeadMap(const System::_di_IInterface ToKey);
	System::_di_IInterface __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntfSortedMap __fastcall SubMap(const System::_di_IInterface FromKey, const System::_di_IInterface ToKey);
	Jclcontainerintf::_di_IJclIntfSortedMap __fastcall TailMap(const System::_di_IInterface FromKey);
private:
	void *__IJclIntfSortedMap;	/* Jclcontainerintf::IJclIntfSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfSortedMap()
	{
		Jclcontainerintf::_di_IJclIntfSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfSortedMap*(void) { return (IJclIntfSortedMap*)&__IJclIntfSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfMap()
	{
		Jclcontainerintf::_di_IJclIntfMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfMap*(void) { return (IJclIntfMap*)&__IJclIntfSortedMap; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfSortedMap; }
	#endif
	
};


struct TJclAnsiStrSortedEntry
{
	
public:
	System::AnsiString Key;
	System::TObject* Value;
};


class DELPHICLASS TJclAnsiStrSortedMap;
class PASCALIMPLEMENTATION TJclAnsiStrSortedMap : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclAnsiStrSortedEntry> _TJclAnsiStrSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::AnsiString __fastcall FreeKey(System::AnsiString &Key);
	int __fastcall KeysCompare(const System::AnsiString A, const System::AnsiString B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclAnsiStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::AnsiString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclAnsiStrSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclAnsiStrSortedMap(void);
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
	System::AnsiString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclAnsiStrSortedMap __fastcall HeadMap(const System::AnsiString ToKey);
	System::AnsiString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclAnsiStrSortedMap __fastcall SubMap(const System::AnsiString FromKey, const System::AnsiString ToKey);
	Jclcontainerintf::_di_IJclAnsiStrSortedMap __fastcall TailMap(const System::AnsiString FromKey);
private:
	void *__IJclAnsiStrSortedMap;	/* Jclcontainerintf::IJclAnsiStrSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrSortedMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrSortedMap*(void) { return (IJclAnsiStrSortedMap*)&__IJclAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrMap()
	{
		Jclcontainerintf::_di_IJclAnsiStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrMap*(void) { return (IJclAnsiStrMap*)&__IJclAnsiStrSortedMap; }
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
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrSortedMap; }
	#endif
	
};


struct TJclWideStrSortedEntry
{
	
public:
	System::WideString Key;
	System::TObject* Value;
};


class DELPHICLASS TJclWideStrSortedMap;
class PASCALIMPLEMENTATION TJclWideStrSortedMap : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclWideStrSortedEntry> _TJclWideStrSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::WideString __fastcall FreeKey(System::WideString &Key);
	int __fastcall KeysCompare(const System::WideString A, const System::WideString B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclWideStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::WideString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclWideStrSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclWideStrSortedMap(void);
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
	System::WideString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclWideStrSortedMap __fastcall HeadMap(const System::WideString ToKey);
	System::WideString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclWideStrSortedMap __fastcall SubMap(const System::WideString FromKey, const System::WideString ToKey);
	Jclcontainerintf::_di_IJclWideStrSortedMap __fastcall TailMap(const System::WideString FromKey);
private:
	void *__IJclWideStrSortedMap;	/* Jclcontainerintf::IJclWideStrSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrSortedMap()
	{
		Jclcontainerintf::_di_IJclWideStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrSortedMap*(void) { return (IJclWideStrSortedMap*)&__IJclWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrMap()
	{
		Jclcontainerintf::_di_IJclWideStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrMap*(void) { return (IJclWideStrMap*)&__IJclWideStrSortedMap; }
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
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrSortedMap; }
	#endif
	
};


struct TJclUnicodeStrSortedEntry
{
	
public:
	System::UnicodeString Key;
	System::TObject* Value;
};


class DELPHICLASS TJclUnicodeStrSortedMap;
class PASCALIMPLEMENTATION TJclUnicodeStrSortedMap : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclUnicodeStrSortedEntry> _TJclUnicodeStrSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::UnicodeString __fastcall FreeKey(System::UnicodeString &Key);
	int __fastcall KeysCompare(const System::UnicodeString A, const System::UnicodeString B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclUnicodeStrSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::UnicodeString Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclUnicodeStrSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclUnicodeStrSortedMap(void);
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
	System::UnicodeString __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclUnicodeStrSortedMap __fastcall HeadMap(const System::UnicodeString ToKey);
	System::UnicodeString __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclUnicodeStrSortedMap __fastcall SubMap(const System::UnicodeString FromKey, const System::UnicodeString ToKey);
	Jclcontainerintf::_di_IJclUnicodeStrSortedMap __fastcall TailMap(const System::UnicodeString FromKey);
private:
	void *__IJclUnicodeStrSortedMap;	/* Jclcontainerintf::IJclUnicodeStrSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrSortedMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrSortedMap*(void) { return (IJclUnicodeStrSortedMap*)&__IJclUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrMap()
	{
		Jclcontainerintf::_di_IJclUnicodeStrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrMap*(void) { return (IJclUnicodeStrMap*)&__IJclUnicodeStrSortedMap; }
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
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrSortedMap; }
	#endif
	
};


typedef TJclUnicodeStrSortedEntry TJclStrSortedEntry;

typedef TJclUnicodeStrSortedMap TJclStrSortedMap;

struct TJclSingleSortedEntry
{
	
public:
	float Key;
	System::TObject* Value;
};


class DELPHICLASS TJclSingleSortedMap;
class PASCALIMPLEMENTATION TJclSingleSortedMap : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclSingleSortedEntry> _TJclSingleSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	float __fastcall FreeKey(float &Key);
	int __fastcall KeysCompare(const float A, const float B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclSingleSortedMap__1 FEntries;
	int __fastcall BinarySearch(const float Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclSingleSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclSingleSortedMap(void);
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
	float __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclSingleSortedMap __fastcall HeadMap(const float ToKey);
	float __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclSingleSortedMap __fastcall SubMap(const float FromKey, const float ToKey);
	Jclcontainerintf::_di_IJclSingleSortedMap __fastcall TailMap(const float FromKey);
private:
	void *__IJclSingleSortedMap;	/* Jclcontainerintf::IJclSingleSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleSortedMap()
	{
		Jclcontainerintf::_di_IJclSingleSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleSortedMap*(void) { return (IJclSingleSortedMap*)&__IJclSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleMap()
	{
		Jclcontainerintf::_di_IJclSingleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleMap*(void) { return (IJclSingleMap*)&__IJclSingleSortedMap; }
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
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleSortedMap; }
	#endif
	
};


struct TJclDoubleSortedEntry
{
	
public:
	double Key;
	System::TObject* Value;
};


class DELPHICLASS TJclDoubleSortedMap;
class PASCALIMPLEMENTATION TJclDoubleSortedMap : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclDoubleSortedEntry> _TJclDoubleSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	double __fastcall FreeKey(double &Key);
	int __fastcall KeysCompare(const double A, const double B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclDoubleSortedMap__1 FEntries;
	int __fastcall BinarySearch(const double Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclDoubleSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclDoubleSortedMap(void);
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
	double __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclDoubleSortedMap __fastcall HeadMap(const double ToKey);
	double __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclDoubleSortedMap __fastcall SubMap(const double FromKey, const double ToKey);
	Jclcontainerintf::_di_IJclDoubleSortedMap __fastcall TailMap(const double FromKey);
private:
	void *__IJclDoubleSortedMap;	/* Jclcontainerintf::IJclDoubleSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleSortedMap()
	{
		Jclcontainerintf::_di_IJclDoubleSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleSortedMap*(void) { return (IJclDoubleSortedMap*)&__IJclDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleMap()
	{
		Jclcontainerintf::_di_IJclDoubleMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleMap*(void) { return (IJclDoubleMap*)&__IJclDoubleSortedMap; }
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
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleSortedMap; }
	#endif
	
};


struct TJclExtendedSortedEntry
{
	
public:
	System::Extended Key;
	System::TObject* Value;
};


class DELPHICLASS TJclExtendedSortedMap;
class PASCALIMPLEMENTATION TJclExtendedSortedMap : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclExtendedSortedEntry> _TJclExtendedSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	System::Extended __fastcall FreeKey(System::Extended &Key);
	int __fastcall KeysCompare(const System::Extended A, const System::Extended B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclExtendedSortedMap__1 FEntries;
	int __fastcall BinarySearch(const System::Extended Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclExtendedSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclExtendedSortedMap(void);
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
	System::Extended __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclExtendedSortedMap __fastcall HeadMap(const System::Extended ToKey);
	System::Extended __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclExtendedSortedMap __fastcall SubMap(const System::Extended FromKey, const System::Extended ToKey);
	Jclcontainerintf::_di_IJclExtendedSortedMap __fastcall TailMap(const System::Extended FromKey);
private:
	void *__IJclExtendedSortedMap;	/* Jclcontainerintf::IJclExtendedSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedSortedMap()
	{
		Jclcontainerintf::_di_IJclExtendedSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedSortedMap*(void) { return (IJclExtendedSortedMap*)&__IJclExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedMap()
	{
		Jclcontainerintf::_di_IJclExtendedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedMap*(void) { return (IJclExtendedMap*)&__IJclExtendedSortedMap; }
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
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedSortedMap; }
	#endif
	
};


typedef TJclExtendedSortedEntry TJclFloatSortedEntry;

typedef TJclExtendedSortedMap TJclFloatSortedMap;

struct TJclIntegerSortedEntry
{
	
public:
	int Key;
	System::TObject* Value;
};


class DELPHICLASS TJclIntegerSortedMap;
class PASCALIMPLEMENTATION TJclIntegerSortedMap : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclIntegerSortedEntry> _TJclIntegerSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall FreeKey(int &Key);
	int __fastcall KeysCompare(int A, int B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclIntegerSortedMap__1 FEntries;
	int __fastcall BinarySearch(int Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclIntegerSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclIntegerSortedMap(void);
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
	int __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclIntegerSortedMap __fastcall HeadMap(int ToKey);
	int __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclIntegerSortedMap __fastcall SubMap(int FromKey, int ToKey);
	Jclcontainerintf::_di_IJclIntegerSortedMap __fastcall TailMap(int FromKey);
private:
	void *__IJclIntegerSortedMap;	/* Jclcontainerintf::IJclIntegerSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerSortedMap()
	{
		Jclcontainerintf::_di_IJclIntegerSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerSortedMap*(void) { return (IJclIntegerSortedMap*)&__IJclIntegerSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerMap()
	{
		Jclcontainerintf::_di_IJclIntegerMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerMap*(void) { return (IJclIntegerMap*)&__IJclIntegerSortedMap; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerSortedMap; }
	#endif
	
};


struct TJclCardinalSortedEntry
{
	
public:
	unsigned Key;
	System::TObject* Value;
};


class DELPHICLASS TJclCardinalSortedMap;
class PASCALIMPLEMENTATION TJclCardinalSortedMap : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclCardinalSortedEntry> _TJclCardinalSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	unsigned __fastcall FreeKey(unsigned &Key);
	int __fastcall KeysCompare(unsigned A, unsigned B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclCardinalSortedMap__1 FEntries;
	int __fastcall BinarySearch(unsigned Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclCardinalSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclCardinalSortedMap(void);
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
	unsigned __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclCardinalSortedMap __fastcall HeadMap(unsigned ToKey);
	unsigned __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclCardinalSortedMap __fastcall SubMap(unsigned FromKey, unsigned ToKey);
	Jclcontainerintf::_di_IJclCardinalSortedMap __fastcall TailMap(unsigned FromKey);
private:
	void *__IJclCardinalSortedMap;	/* Jclcontainerintf::IJclCardinalSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalSortedMap()
	{
		Jclcontainerintf::_di_IJclCardinalSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalSortedMap*(void) { return (IJclCardinalSortedMap*)&__IJclCardinalSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalMap()
	{
		Jclcontainerintf::_di_IJclCardinalMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalMap*(void) { return (IJclCardinalMap*)&__IJclCardinalSortedMap; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalSortedMap; }
	#endif
	
};


struct TJclInt64SortedEntry
{
	
public:
	__int64 Key;
	System::TObject* Value;
};


class DELPHICLASS TJclInt64SortedMap;
class PASCALIMPLEMENTATION TJclInt64SortedMap : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclInt64SortedEntry> _TJclInt64SortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	__int64 __fastcall FreeKey(__int64 &Key);
	int __fastcall KeysCompare(const __int64 A, const __int64 B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclInt64SortedMap__1 FEntries;
	int __fastcall BinarySearch(const __int64 Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclInt64SortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclInt64SortedMap(void);
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
	__int64 __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclInt64SortedMap __fastcall HeadMap(const __int64 ToKey);
	__int64 __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclInt64SortedMap __fastcall SubMap(const __int64 FromKey, const __int64 ToKey);
	Jclcontainerintf::_di_IJclInt64SortedMap __fastcall TailMap(const __int64 FromKey);
private:
	void *__IJclInt64SortedMap;	/* Jclcontainerintf::IJclInt64SortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64SortedMap()
	{
		Jclcontainerintf::_di_IJclInt64SortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64SortedMap*(void) { return (IJclInt64SortedMap*)&__IJclInt64SortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Map()
	{
		Jclcontainerintf::_di_IJclInt64Map intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Map*(void) { return (IJclInt64Map*)&__IJclInt64SortedMap; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64SortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64SortedMap; }
	#endif
	
};


struct TJclPtrSortedEntry
{
	
public:
	void *Key;
	System::TObject* Value;
};


class DELPHICLASS TJclPtrSortedMap;
class PASCALIMPLEMENTATION TJclPtrSortedMap : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
private:
	typedef DynamicArray<TJclPtrSortedEntry> _TJclPtrSortedMap__1;
	
	
private:
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	void * __fastcall FreeKey(void * &Key);
	int __fastcall KeysCompare(void * A, void * B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclPtrSortedMap__1 FEntries;
	int __fastcall BinarySearch(void * Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclPtrSortedMap(int ACapacity, bool AOwnsValues);
	__fastcall virtual ~TJclPtrSortedMap(void);
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
	void * __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclPtrSortedMap __fastcall HeadMap(void * ToKey);
	void * __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclPtrSortedMap __fastcall SubMap(void * FromKey, void * ToKey);
	Jclcontainerintf::_di_IJclPtrSortedMap __fastcall TailMap(void * FromKey);
private:
	void *__IJclPtrSortedMap;	/* Jclcontainerintf::IJclPtrSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrSortedMap()
	{
		Jclcontainerintf::_di_IJclPtrSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrSortedMap*(void) { return (IJclPtrSortedMap*)&__IJclPtrSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrMap()
	{
		Jclcontainerintf::_di_IJclPtrMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrMap*(void) { return (IJclPtrMap*)&__IJclPtrSortedMap; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrSortedMap; }
	#endif
	
};


struct TJclSortedEntry
{
	
public:
	System::TObject* Key;
	System::TObject* Value;
};


class DELPHICLASS TJclSortedMap;
class PASCALIMPLEMENTATION TJclSortedMap : public Jclabstractcontainers::TJclAbstractContainerBase
{
	typedef Jclabstractcontainers::TJclAbstractContainerBase inherited;
	
private:
	typedef DynamicArray<TJclSortedEntry> _TJclSortedMap__1;
	
	
private:
	bool FOwnsKeys;
	bool FOwnsValues;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	int __fastcall KeysCompare(System::TObject* A, System::TObject* B);
	int __fastcall ValuesCompare(System::TObject* A, System::TObject* B);
	
public:
	System::TObject* __fastcall FreeKey(System::TObject* &Key);
	bool __fastcall GetOwnsKeys(void);
	__property bool OwnsKeys = {read=FOwnsKeys, nodefault};
	System::TObject* __fastcall FreeValue(System::TObject* &Value);
	bool __fastcall GetOwnsValues(void);
	__property bool OwnsValues = {read=FOwnsValues, nodefault};
	
private:
	_TJclSortedMap__1 FEntries;
	int __fastcall BinarySearch(System::TObject* Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclSortedMap(int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__fastcall virtual ~TJclSortedMap(void);
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
	System::TObject* __fastcall FirstKey(void);
	Jclcontainerintf::_di_IJclSortedMap __fastcall HeadMap(System::TObject* ToKey);
	System::TObject* __fastcall LastKey(void);
	Jclcontainerintf::_di_IJclSortedMap __fastcall SubMap(System::TObject* FromKey, System::TObject* ToKey);
	Jclcontainerintf::_di_IJclSortedMap __fastcall TailMap(System::TObject* FromKey);
private:
	void *__IJclSortedMap;	/* Jclcontainerintf::IJclSortedMap */
	void *__IJclValueOwner;	/* Jclcontainerintf::IJclValueOwner */
	void *__IJclKeyOwner;	/* Jclcontainerintf::IJclKeyOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSortedMap()
	{
		Jclcontainerintf::_di_IJclSortedMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSortedMap*(void) { return (IJclSortedMap*)&__IJclSortedMap; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclMap()
	{
		Jclcontainerintf::_di_IJclMap intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap*(void) { return (IJclMap*)&__IJclSortedMap; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSortedMap; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSortedMap; }
	#endif
	
};


// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> struct TJclSortedEntry__2
{
	
public:
	TKey Key;
	TValue Value;
};


template<typename TKey, typename TValue> class DELPHICLASS TJclSortedMap__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclSortedMap__2 : public Jclabstractcontainers::TJclAbstractContainerBase
{
	typedef Jclabstractcontainers::TJclAbstractContainerBase inherited;
	
protected:
	
private:
	bool FOwnsKeys;
	bool FOwnsValues;
	
protected:
	virtual int __fastcall KeysCompare(const TKey A, const TKey B) = 0 ;
	virtual int __fastcall ValuesCompare(const TValue A, const TValue B) = 0 ;
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
	DynamicArray<TJclSortedEntry__2<TKey,TValue> > FEntries;
	int __fastcall BinarySearch(const TKey Key);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	void __fastcall MoveArray(int FromIndex, int ToIndex, int Count);
	
public:
	__fastcall TJclSortedMap__2(int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__fastcall virtual ~TJclSortedMap__2(void);
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
	TKey __fastcall FirstKey(void);
	System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> >  __fastcall HeadMap(const TKey ToKey);
	TKey __fastcall LastKey(void);
	System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> >  __fastcall SubMap(const TKey FromKey, const TKey ToKey);
	System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> >  __fastcall TailMap(const TKey FromKey);
private:
	void *__IJclSortedMap__2;	/* Jclcontainerintf::IJclSortedMap__2<TKey,TValue> */
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSortedMap__2<TKey,TValue>*(void) { return (IJclSortedMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSortedMap__2; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSortedMap__2; }
	#endif
	
};


template<typename TKey, typename TValue> class DELPHICLASS TJclSortedMapE__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclSortedMapE__2 : public TJclSortedMap__2<TKey,TValue>
{
	typedef TJclSortedMap__2<TKey,TValue> inherited;
	
protected:
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TKey> >  FKeyComparer;
	System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TValue> >  FValueComparer;
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TValue> >  FValueEqualityComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual int __fastcall KeysCompare(const TKey A, const TKey B);
	virtual int __fastcall ValuesCompare(const TValue A, const TValue B);
	virtual System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall CreateEmptyArrayList(int ACapacity, bool AOwnsObjects);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	virtual System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall CreateEmptyArraySet(int ACapacity, bool AOwnsObjects);
	
public:
	__fastcall TJclSortedMapE__2(const System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TKey> >  AKeyComparer, const System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TValue> >  AValueComparer, const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TValue> >  AValueEqualityComparer, int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__property System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TKey> >  KeyComparer = {read=FKeyComparer, write=FKeyComparer};
	__property System::DelphiInterface<Jclcontainerintf::IJclComparer__1<TValue> >  ValueComparer = {read=FValueComparer, write=FValueComparer};
	__property System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TValue> >  ValueEqualityComparer = {read=FValueEqualityComparer, write=FValueEqualityComparer};
public:
	/* TJclSortedMap<TKey,TValue>.Destroy */ inline __fastcall virtual ~TJclSortedMapE__2(void) { }
	
private:
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclSortedMap__2;	/* Jclcontainerintf::IJclSortedMap__2<TKey,TValue> */
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
	operator System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSortedMap__2<TKey,TValue>*(void) { return (IJclSortedMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSortedMap__2; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSortedMap__2; }
	#endif
	
};


template<typename TKey, typename TValue> class DELPHICLASS TJclSortedMapF__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclSortedMapF__2 : public TJclSortedMap__2<TKey,TValue>
{
	typedef TJclSortedMap__2<TKey,TValue> inherited;
	
protected:
	
private:
	_decl_TCompare__1(TKey, FKeyCompare);
	// Jclcontainerintf::TCompare__1<TKey>  FKeyCompare;
	_decl_TCompare__1(TValue, FValueCompare);
	// Jclcontainerintf::TCompare__1<TValue>  FValueCompare;
	_decl_TEqualityCompare__1(TValue, FValueEqualityCompare);
	// Jclcontainerintf::TEqualityCompare__1<TValue>  FValueEqualityCompare;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual int __fastcall KeysCompare(const TKey A, const TKey B);
	virtual int __fastcall ValuesCompare(const TValue A, const TValue B);
	virtual System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall CreateEmptyArrayList(int ACapacity, bool AOwnsObjects);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	virtual System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall CreateEmptyArraySet(int ACapacity, bool AOwnsObjects);
	
public:
	__fastcall TJclSortedMapF__2(_decl_TCompare__1(TKey, AKeyCompare), _decl_TCompare__1(TValue, AValueCompare), _decl_TEqualityCompare__1(TValue, AValueEqualityCompare), int ACapacity, bool AOwnsValues, bool AOwnsKeys);
	__property _decl_TCompare__1(TKey, KeyCompare) = {read=FKeyCompare, write=FKeyCompare};
	// __property Jclcontainerintf::TCompare__1<TKey>  KeyCompare = {read=FKeyCompare, write=FKeyCompare};
	__property _decl_TCompare__1(TValue, ValueCompare) = {read=FValueCompare, write=FValueCompare};
	// __property Jclcontainerintf::TCompare__1<TValue>  ValueCompare = {read=FValueCompare, write=FValueCompare};
	__property _decl_TEqualityCompare__1(TValue, ValueEqualityCompare) = {read=FValueEqualityCompare, write=FValueEqualityCompare};
	// __property Jclcontainerintf::TEqualityCompare__1<TValue>  ValueEqualityCompare = {read=FValueEqualityCompare, write=FValueEqualityCompare};
public:
	/* TJclSortedMap<TKey,TValue>.Destroy */ inline __fastcall virtual ~TJclSortedMapF__2(void) { }
	
private:
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclSortedMap__2;	/* Jclcontainerintf::IJclSortedMap__2<TKey,TValue> */
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
	operator System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSortedMap__2<TKey,TValue>*(void) { return (IJclSortedMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSortedMap__2; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSortedMap__2; }
	#endif
	
};


template<typename TKey, typename TValue> class DELPHICLASS TJclSortedMapI__2;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename TKey, typename TValue> class PASCALIMPLEMENTATION TJclSortedMapI__2 : public TJclSortedMap__2<TKey,TValue>
{
	typedef TJclSortedMap__2<TKey,TValue> inherited;
	
protected:
	
protected:
	virtual int __fastcall KeysCompare(const TKey A, const TKey B);
	virtual int __fastcall ValuesCompare(const TValue A, const TValue B);
	virtual System::DelphiInterface<Jclcontainerintf::IJclCollection__1<TValue> >  __fastcall CreateEmptyArrayList(int ACapacity, bool AOwnsObjects);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	virtual System::DelphiInterface<Jclcontainerintf::IJclSet__1<TKey> >  __fastcall CreateEmptyArraySet(int ACapacity, bool AOwnsObjects);
public:
	/* TJclSortedMap<TKey,TValue>.Create */ inline __fastcall TJclSortedMapI__2(int ACapacity, bool AOwnsValues, bool AOwnsKeys) : TJclSortedMap__2<TKey,TValue>(ACapacity, AOwnsValues, AOwnsKeys) { }
	/* TJclSortedMap<TKey,TValue>.Destroy */ inline __fastcall virtual ~TJclSortedMapI__2(void) { }
	
private:
	void *__IJclPairOwner__2;	/* Jclcontainerintf::IJclPairOwner__2<TKey,TValue> */
	void *__IJclSortedMap__2;	/* Jclcontainerintf::IJclSortedMap__2<TKey,TValue> */
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
	operator System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSortedMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSortedMap__2<TKey,TValue>*(void) { return (IJclSortedMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclMap__2<TKey,TValue> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclMap__2<TKey,TValue>*(void) { return (IJclMap__2<TKey,TValue>*)&__IJclSortedMap__2; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSortedMap__2; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSortedMap__2; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclsortedmaps */
using namespace Jclsortedmaps;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclsortedmapsHPP
