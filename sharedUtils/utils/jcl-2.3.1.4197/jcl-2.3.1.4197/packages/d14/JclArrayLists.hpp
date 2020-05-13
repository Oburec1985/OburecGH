// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclarraylists.pas' rev: 21.00

#ifndef JclarraylistsHPP
#define JclarraylistsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclalgorithms.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclabstractcontainers.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclarraylists
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TItrStart { isFirst, isLast };
#pragma option pop

class DELPHICLASS TJclIntfArrayList;
class PASCALIMPLEMENTATION TJclIntfArrayList : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynIInterfaceArray FElementData;
	System::_di_IInterface __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfArrayList(int ACapacity)/* overload */;
	__fastcall TJclIntfArrayList(const Jclcontainerintf::_di_IJclIntfCollection ACollection)/* overload */;
	__fastcall virtual ~TJclIntfArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(const System::_di_IInterface AInterface);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(const System::_di_IInterface AInterface);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	bool __fastcall Extract(const System::_di_IInterface AInterface);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	Jclcontainerintf::_di_IJclIntfIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclIntfIterator __fastcall Last(void);
	bool __fastcall Remove(const System::_di_IInterface AInterface);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntfIterator __fastcall GetEnumerator(void);
	System::_di_IInterface __fastcall Delete(int Index);
	System::_di_IInterface __fastcall ExtractIndex(int Index);
	System::_di_IInterface __fastcall GetObject(int Index);
	int __fastcall IndexOf(const System::_di_IInterface AInterface);
	bool __fastcall Insert(int Index, const System::_di_IInterface AInterface);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	int __fastcall LastIndexOf(const System::_di_IInterface AInterface);
	void __fastcall SetObject(int Index, const System::_di_IInterface AInterface);
	Jclcontainerintf::_di_IJclIntfList __fastcall SubList(int First, int Count);
private:
	void *__IJclIntfArray;	/* Jclcontainerintf::IJclIntfArray */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfArray()
	{
		Jclcontainerintf::_di_IJclIntfArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfArray*(void) { return (IJclIntfArray*)&__IJclIntfArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfList()
	{
		Jclcontainerintf::_di_IJclIntfList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfList*(void) { return (IJclIntfList*)&__IJclIntfArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCollection()
	{
		Jclcontainerintf::_di_IJclIntfCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCollection*(void) { return (IJclIntfCollection*)&__IJclIntfArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfEqualityComparer()
	{
		Jclcontainerintf::_di_IJclIntfEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfEqualityComparer*(void) { return (IJclIntfEqualityComparer*)&__IJclIntfEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfArray; }
	#endif
	
};


class DELPHICLASS TJclIntfArrayIterator;
class PASCALIMPLEMENTATION TJclIntfArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclIntfArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclIntfArrayIterator(TJclIntfArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const System::_di_IInterface AInterface);
	void __fastcall Extract(void);
	System::_di_IInterface __fastcall GetObject(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const System::_di_IInterface AInterface);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclIntfIterator AIterator);
	System::_di_IInterface __fastcall Next(void);
	int __fastcall NextIndex(void);
	System::_di_IInterface __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetObject(const System::_di_IInterface AInterface);
	bool __fastcall MoveNext(void);
	__property System::_di_IInterface Current = {read=GetObject};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntfArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntfIterator;	/* Jclcontainerintf::IJclIntfIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfIterator; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrArrayList;
class PASCALIMPLEMENTATION TJclAnsiStrArrayList : public Jclabstractcontainers::TJclAnsiStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynAnsiStringArray FElementData;
	System::AnsiString __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrArrayList(int ACapacity)/* overload */;
	__fastcall TJclAnsiStrArrayList(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection)/* overload */;
	__fastcall virtual ~TJclAnsiStrArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall Add(const System::AnsiString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual void __fastcall Clear(void);
	virtual bool __fastcall Contains(const System::AnsiString AString);
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual bool __fastcall Extract(const System::AnsiString AString);
	virtual bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual Jclcontainerintf::_di_IJclAnsiStrIterator __fastcall First(void);
	virtual bool __fastcall IsEmpty(void);
	virtual Jclcontainerintf::_di_IJclAnsiStrIterator __fastcall Last(void);
	virtual bool __fastcall Remove(const System::AnsiString AString);
	virtual bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual int __fastcall Size(void);
	virtual Jclcontainerintf::_di_IJclAnsiStrIterator __fastcall GetEnumerator(void);
	System::AnsiString __fastcall Delete(int Index);
	System::AnsiString __fastcall ExtractIndex(int Index);
	System::AnsiString __fastcall GetString(int Index);
	int __fastcall IndexOf(const System::AnsiString AString);
	bool __fastcall Insert(int Index, const System::AnsiString AString);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	int __fastcall LastIndexOf(const System::AnsiString AString);
	void __fastcall SetString(int Index, const System::AnsiString AString);
	Jclcontainerintf::_di_IJclAnsiStrList __fastcall SubList(int First, int Count);
private:
	void *__IJclAnsiStrArray;	/* Jclcontainerintf::IJclAnsiStrArray */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrArray()
	{
		Jclcontainerintf::_di_IJclAnsiStrArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrArray*(void) { return (IJclAnsiStrArray*)&__IJclAnsiStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrList()
	{
		Jclcontainerintf::_di_IJclAnsiStrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrList*(void) { return (IJclAnsiStrList*)&__IJclAnsiStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrCollection()
	{
		Jclcontainerintf::_di_IJclAnsiStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrCollection*(void) { return (IJclAnsiStrCollection*)&__IJclAnsiStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrEqualityComparer()
	{
		Jclcontainerintf::_di_IJclAnsiStrEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrEqualityComparer*(void) { return (IJclAnsiStrEqualityComparer*)&__IJclAnsiStrEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrFlatContainer*(void) { return (IJclAnsiStrFlatContainer*)&__IJclAnsiStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrArray; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrArrayIterator;
class PASCALIMPLEMENTATION TJclAnsiStrArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclAnsiStrArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclAnsiStrArrayIterator(TJclAnsiStrArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const System::AnsiString AString);
	void __fastcall Extract(void);
	System::AnsiString __fastcall GetString(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const System::AnsiString AString);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclAnsiStrIterator AIterator);
	System::AnsiString __fastcall Next(void);
	int __fastcall NextIndex(void);
	System::AnsiString __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetString(const System::AnsiString AString);
	bool __fastcall MoveNext(void);
	__property System::AnsiString Current = {read=GetString};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAnsiStrArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclAnsiStrIterator;	/* Jclcontainerintf::IJclAnsiStrIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrIterator; }
	#endif
	
};


class DELPHICLASS TJclWideStrArrayList;
class PASCALIMPLEMENTATION TJclWideStrArrayList : public Jclabstractcontainers::TJclWideStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclWideStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynWideStringArray FElementData;
	System::WideString __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrArrayList(int ACapacity)/* overload */;
	__fastcall TJclWideStrArrayList(const Jclcontainerintf::_di_IJclWideStrCollection ACollection)/* overload */;
	__fastcall virtual ~TJclWideStrArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall Add(const System::WideString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual void __fastcall Clear(void);
	virtual bool __fastcall Contains(const System::WideString AString);
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual bool __fastcall Extract(const System::WideString AString);
	virtual bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual Jclcontainerintf::_di_IJclWideStrIterator __fastcall First(void);
	virtual bool __fastcall IsEmpty(void);
	virtual Jclcontainerintf::_di_IJclWideStrIterator __fastcall Last(void);
	virtual bool __fastcall Remove(const System::WideString AString);
	virtual bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual int __fastcall Size(void);
	virtual Jclcontainerintf::_di_IJclWideStrIterator __fastcall GetEnumerator(void);
	System::WideString __fastcall Delete(int Index);
	System::WideString __fastcall ExtractIndex(int Index);
	System::WideString __fastcall GetString(int Index);
	int __fastcall IndexOf(const System::WideString AString);
	bool __fastcall Insert(int Index, const System::WideString AString);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	int __fastcall LastIndexOf(const System::WideString AString);
	void __fastcall SetString(int Index, const System::WideString AString);
	Jclcontainerintf::_di_IJclWideStrList __fastcall SubList(int First, int Count);
private:
	void *__IJclWideStrArray;	/* Jclcontainerintf::IJclWideStrArray */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrArray()
	{
		Jclcontainerintf::_di_IJclWideStrArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrArray*(void) { return (IJclWideStrArray*)&__IJclWideStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrList()
	{
		Jclcontainerintf::_di_IJclWideStrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrList*(void) { return (IJclWideStrList*)&__IJclWideStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrCollection()
	{
		Jclcontainerintf::_di_IJclWideStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrCollection*(void) { return (IJclWideStrCollection*)&__IJclWideStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrEqualityComparer()
	{
		Jclcontainerintf::_di_IJclWideStrEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrEqualityComparer*(void) { return (IJclWideStrEqualityComparer*)&__IJclWideStrEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclWideStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrFlatContainer*(void) { return (IJclWideStrFlatContainer*)&__IJclWideStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrArray; }
	#endif
	
};


class DELPHICLASS TJclWideStrArrayIterator;
class PASCALIMPLEMENTATION TJclWideStrArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclWideStrArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclWideStrArrayIterator(TJclWideStrArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const System::WideString AString);
	void __fastcall Extract(void);
	System::WideString __fastcall GetString(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const System::WideString AString);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclWideStrIterator AIterator);
	System::WideString __fastcall Next(void);
	int __fastcall NextIndex(void);
	System::WideString __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetString(const System::WideString AString);
	bool __fastcall MoveNext(void);
	__property System::WideString Current = {read=GetString};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclWideStrArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclWideStrIterator;	/* Jclcontainerintf::IJclWideStrIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrIterator; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrArrayList;
class PASCALIMPLEMENTATION TJclUnicodeStrArrayList : public Jclabstractcontainers::TJclUnicodeStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynUnicodeStringArray FElementData;
	System::UnicodeString __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrArrayList(int ACapacity)/* overload */;
	__fastcall TJclUnicodeStrArrayList(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection)/* overload */;
	__fastcall virtual ~TJclUnicodeStrArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall Add(const System::UnicodeString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual void __fastcall Clear(void);
	virtual bool __fastcall Contains(const System::UnicodeString AString);
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual bool __fastcall Extract(const System::UnicodeString AString);
	virtual bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual Jclcontainerintf::_di_IJclUnicodeStrIterator __fastcall First(void);
	virtual bool __fastcall IsEmpty(void);
	virtual Jclcontainerintf::_di_IJclUnicodeStrIterator __fastcall Last(void);
	virtual bool __fastcall Remove(const System::UnicodeString AString);
	virtual bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual int __fastcall Size(void);
	virtual Jclcontainerintf::_di_IJclUnicodeStrIterator __fastcall GetEnumerator(void);
	System::UnicodeString __fastcall Delete(int Index);
	System::UnicodeString __fastcall ExtractIndex(int Index);
	System::UnicodeString __fastcall GetString(int Index);
	int __fastcall IndexOf(const System::UnicodeString AString);
	bool __fastcall Insert(int Index, const System::UnicodeString AString);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	int __fastcall LastIndexOf(const System::UnicodeString AString);
	void __fastcall SetString(int Index, const System::UnicodeString AString);
	Jclcontainerintf::_di_IJclUnicodeStrList __fastcall SubList(int First, int Count);
private:
	void *__IJclUnicodeStrArray;	/* Jclcontainerintf::IJclUnicodeStrArray */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrArray()
	{
		Jclcontainerintf::_di_IJclUnicodeStrArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrArray*(void) { return (IJclUnicodeStrArray*)&__IJclUnicodeStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrList()
	{
		Jclcontainerintf::_di_IJclUnicodeStrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrList*(void) { return (IJclUnicodeStrList*)&__IJclUnicodeStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrCollection()
	{
		Jclcontainerintf::_di_IJclUnicodeStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrCollection*(void) { return (IJclUnicodeStrCollection*)&__IJclUnicodeStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrEqualityComparer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrEqualityComparer*(void) { return (IJclUnicodeStrEqualityComparer*)&__IJclUnicodeStrEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrFlatContainer*(void) { return (IJclUnicodeStrFlatContainer*)&__IJclUnicodeStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrArray; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrArrayIterator;
class PASCALIMPLEMENTATION TJclUnicodeStrArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclUnicodeStrArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclUnicodeStrArrayIterator(TJclUnicodeStrArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const System::UnicodeString AString);
	void __fastcall Extract(void);
	System::UnicodeString __fastcall GetString(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const System::UnicodeString AString);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclUnicodeStrIterator AIterator);
	System::UnicodeString __fastcall Next(void);
	int __fastcall NextIndex(void);
	System::UnicodeString __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetString(const System::UnicodeString AString);
	bool __fastcall MoveNext(void);
	__property System::UnicodeString Current = {read=GetString};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclUnicodeStrArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclUnicodeStrIterator;	/* Jclcontainerintf::IJclUnicodeStrIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrIterator; }
	#endif
	
};


typedef TJclUnicodeStrArrayList TJclStrArrayList;

typedef TJclUnicodeStrArrayIterator TJclStrArrayIterator;

class DELPHICLASS TJclSingleArrayList;
class PASCALIMPLEMENTATION TJclSingleArrayList : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynSingleArray FElementData;
	float __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleArrayList(int ACapacity)/* overload */;
	__fastcall TJclSingleArrayList(const Jclcontainerintf::_di_IJclSingleCollection ACollection)/* overload */;
	__fastcall virtual ~TJclSingleArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(const float AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(const float AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	bool __fastcall Extract(const float AValue);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	Jclcontainerintf::_di_IJclSingleIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclSingleIterator __fastcall Last(void);
	bool __fastcall Remove(const float AValue);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclSingleIterator __fastcall GetEnumerator(void);
	float __fastcall Delete(int Index);
	float __fastcall ExtractIndex(int Index);
	float __fastcall GetValue(int Index);
	int __fastcall IndexOf(const float AValue);
	bool __fastcall Insert(int Index, const float AValue);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	int __fastcall LastIndexOf(const float AValue);
	void __fastcall SetValue(int Index, const float AValue);
	Jclcontainerintf::_di_IJclSingleList __fastcall SubList(int First, int Count);
private:
	void *__IJclSingleArray;	/* Jclcontainerintf::IJclSingleArray */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleArray()
	{
		Jclcontainerintf::_di_IJclSingleArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleArray*(void) { return (IJclSingleArray*)&__IJclSingleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleList()
	{
		Jclcontainerintf::_di_IJclSingleList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleList*(void) { return (IJclSingleList*)&__IJclSingleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleCollection()
	{
		Jclcontainerintf::_di_IJclSingleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleCollection*(void) { return (IJclSingleCollection*)&__IJclSingleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleEqualityComparer()
	{
		Jclcontainerintf::_di_IJclSingleEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleEqualityComparer*(void) { return (IJclSingleEqualityComparer*)&__IJclSingleEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleArray; }
	#endif
	
};


class DELPHICLASS TJclSingleArrayIterator;
class PASCALIMPLEMENTATION TJclSingleArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclSingleArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclSingleArrayIterator(TJclSingleArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const float AValue);
	void __fastcall Extract(void);
	float __fastcall GetValue(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const float AValue);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclSingleIterator AIterator);
	float __fastcall Next(void);
	int __fastcall NextIndex(void);
	float __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetValue(const float AValue);
	bool __fastcall MoveNext(void);
	__property float Current = {read=GetValue};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclSingleArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclSingleIterator;	/* Jclcontainerintf::IJclSingleIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleIterator; }
	#endif
	
};


class DELPHICLASS TJclDoubleArrayList;
class PASCALIMPLEMENTATION TJclDoubleArrayList : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynDoubleArray FElementData;
	double __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleArrayList(int ACapacity)/* overload */;
	__fastcall TJclDoubleArrayList(const Jclcontainerintf::_di_IJclDoubleCollection ACollection)/* overload */;
	__fastcall virtual ~TJclDoubleArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(const double AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(const double AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	bool __fastcall Extract(const double AValue);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	Jclcontainerintf::_di_IJclDoubleIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclDoubleIterator __fastcall Last(void);
	bool __fastcall Remove(const double AValue);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclDoubleIterator __fastcall GetEnumerator(void);
	double __fastcall Delete(int Index);
	double __fastcall ExtractIndex(int Index);
	double __fastcall GetValue(int Index);
	int __fastcall IndexOf(const double AValue);
	bool __fastcall Insert(int Index, const double AValue);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	int __fastcall LastIndexOf(const double AValue);
	void __fastcall SetValue(int Index, const double AValue);
	Jclcontainerintf::_di_IJclDoubleList __fastcall SubList(int First, int Count);
private:
	void *__IJclDoubleArray;	/* Jclcontainerintf::IJclDoubleArray */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleArray()
	{
		Jclcontainerintf::_di_IJclDoubleArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleArray*(void) { return (IJclDoubleArray*)&__IJclDoubleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleList()
	{
		Jclcontainerintf::_di_IJclDoubleList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleList*(void) { return (IJclDoubleList*)&__IJclDoubleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleCollection()
	{
		Jclcontainerintf::_di_IJclDoubleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleCollection*(void) { return (IJclDoubleCollection*)&__IJclDoubleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleEqualityComparer()
	{
		Jclcontainerintf::_di_IJclDoubleEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleEqualityComparer*(void) { return (IJclDoubleEqualityComparer*)&__IJclDoubleEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleArray; }
	#endif
	
};


class DELPHICLASS TJclDoubleArrayIterator;
class PASCALIMPLEMENTATION TJclDoubleArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclDoubleArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclDoubleArrayIterator(TJclDoubleArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const double AValue);
	void __fastcall Extract(void);
	double __fastcall GetValue(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const double AValue);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclDoubleIterator AIterator);
	double __fastcall Next(void);
	int __fastcall NextIndex(void);
	double __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetValue(const double AValue);
	bool __fastcall MoveNext(void);
	__property double Current = {read=GetValue};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclDoubleArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclDoubleIterator;	/* Jclcontainerintf::IJclDoubleIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleIterator; }
	#endif
	
};


class DELPHICLASS TJclExtendedArrayList;
class PASCALIMPLEMENTATION TJclExtendedArrayList : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynExtendedArray FElementData;
	System::Extended __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedArrayList(int ACapacity)/* overload */;
	__fastcall TJclExtendedArrayList(const Jclcontainerintf::_di_IJclExtendedCollection ACollection)/* overload */;
	__fastcall virtual ~TJclExtendedArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(const System::Extended AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(const System::Extended AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	bool __fastcall Extract(const System::Extended AValue);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	Jclcontainerintf::_di_IJclExtendedIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclExtendedIterator __fastcall Last(void);
	bool __fastcall Remove(const System::Extended AValue);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclExtendedIterator __fastcall GetEnumerator(void);
	System::Extended __fastcall Delete(int Index);
	System::Extended __fastcall ExtractIndex(int Index);
	System::Extended __fastcall GetValue(int Index);
	int __fastcall IndexOf(const System::Extended AValue);
	bool __fastcall Insert(int Index, const System::Extended AValue);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	int __fastcall LastIndexOf(const System::Extended AValue);
	void __fastcall SetValue(int Index, const System::Extended AValue);
	Jclcontainerintf::_di_IJclExtendedList __fastcall SubList(int First, int Count);
private:
	void *__IJclExtendedArray;	/* Jclcontainerintf::IJclExtendedArray */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedArray()
	{
		Jclcontainerintf::_di_IJclExtendedArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedArray*(void) { return (IJclExtendedArray*)&__IJclExtendedArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedList()
	{
		Jclcontainerintf::_di_IJclExtendedList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedList*(void) { return (IJclExtendedList*)&__IJclExtendedArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedCollection()
	{
		Jclcontainerintf::_di_IJclExtendedCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedCollection*(void) { return (IJclExtendedCollection*)&__IJclExtendedArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedEqualityComparer()
	{
		Jclcontainerintf::_di_IJclExtendedEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedEqualityComparer*(void) { return (IJclExtendedEqualityComparer*)&__IJclExtendedEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedArray; }
	#endif
	
};


class DELPHICLASS TJclExtendedArrayIterator;
class PASCALIMPLEMENTATION TJclExtendedArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclExtendedArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclExtendedArrayIterator(TJclExtendedArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const System::Extended AValue);
	void __fastcall Extract(void);
	System::Extended __fastcall GetValue(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const System::Extended AValue);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclExtendedIterator AIterator);
	System::Extended __fastcall Next(void);
	int __fastcall NextIndex(void);
	System::Extended __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetValue(const System::Extended AValue);
	bool __fastcall MoveNext(void);
	__property System::Extended Current = {read=GetValue};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclExtendedArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclExtendedIterator;	/* Jclcontainerintf::IJclExtendedIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedIterator; }
	#endif
	
};


typedef TJclExtendedArrayList TJclFloatArrayList;

typedef TJclExtendedArrayIterator TJclFloatArrayIterator;

class DELPHICLASS TJclIntegerArrayList;
class PASCALIMPLEMENTATION TJclIntegerArrayList : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynIntegerArray FElementData;
	int __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerArrayList(int ACapacity)/* overload */;
	__fastcall TJclIntegerArrayList(const Jclcontainerintf::_di_IJclIntegerCollection ACollection)/* overload */;
	__fastcall virtual ~TJclIntegerArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(int AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(int AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	bool __fastcall Extract(int AValue);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	Jclcontainerintf::_di_IJclIntegerIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclIntegerIterator __fastcall Last(void);
	bool __fastcall Remove(int AValue);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIntegerIterator __fastcall GetEnumerator(void);
	int __fastcall Delete(int Index);
	int __fastcall ExtractIndex(int Index);
	int __fastcall GetValue(int Index);
	int __fastcall IndexOf(int AValue);
	bool __fastcall Insert(int Index, int AValue);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	int __fastcall LastIndexOf(int AValue);
	void __fastcall SetValue(int Index, int AValue);
	Jclcontainerintf::_di_IJclIntegerList __fastcall SubList(int First, int Count);
private:
	void *__IJclIntegerArray;	/* Jclcontainerintf::IJclIntegerArray */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerArray()
	{
		Jclcontainerintf::_di_IJclIntegerArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerArray*(void) { return (IJclIntegerArray*)&__IJclIntegerArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerList()
	{
		Jclcontainerintf::_di_IJclIntegerList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerList*(void) { return (IJclIntegerList*)&__IJclIntegerArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerCollection()
	{
		Jclcontainerintf::_di_IJclIntegerCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerCollection*(void) { return (IJclIntegerCollection*)&__IJclIntegerArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerEqualityComparer()
	{
		Jclcontainerintf::_di_IJclIntegerEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerEqualityComparer*(void) { return (IJclIntegerEqualityComparer*)&__IJclIntegerEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerArray; }
	#endif
	
};


class DELPHICLASS TJclIntegerArrayIterator;
class PASCALIMPLEMENTATION TJclIntegerArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclIntegerArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclIntegerArrayIterator(TJclIntegerArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(int AValue);
	void __fastcall Extract(void);
	int __fastcall GetValue(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(int AValue);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclIntegerIterator AIterator);
	int __fastcall Next(void);
	int __fastcall NextIndex(void);
	int __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetValue(int AValue);
	bool __fastcall MoveNext(void);
	__property int Current = {read=GetValue, nodefault};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntegerArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntegerIterator;	/* Jclcontainerintf::IJclIntegerIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerIterator; }
	#endif
	
};


class DELPHICLASS TJclCardinalArrayList;
class PASCALIMPLEMENTATION TJclCardinalArrayList : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynCardinalArray FElementData;
	unsigned __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalArrayList(int ACapacity)/* overload */;
	__fastcall TJclCardinalArrayList(const Jclcontainerintf::_di_IJclCardinalCollection ACollection)/* overload */;
	__fastcall virtual ~TJclCardinalArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(unsigned AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(unsigned AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	bool __fastcall Extract(unsigned AValue);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	Jclcontainerintf::_di_IJclCardinalIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclCardinalIterator __fastcall Last(void);
	bool __fastcall Remove(unsigned AValue);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclCardinalIterator __fastcall GetEnumerator(void);
	unsigned __fastcall Delete(int Index);
	unsigned __fastcall ExtractIndex(int Index);
	unsigned __fastcall GetValue(int Index);
	int __fastcall IndexOf(unsigned AValue);
	bool __fastcall Insert(int Index, unsigned AValue);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	int __fastcall LastIndexOf(unsigned AValue);
	void __fastcall SetValue(int Index, unsigned AValue);
	Jclcontainerintf::_di_IJclCardinalList __fastcall SubList(int First, int Count);
private:
	void *__IJclCardinalArray;	/* Jclcontainerintf::IJclCardinalArray */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalArray()
	{
		Jclcontainerintf::_di_IJclCardinalArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalArray*(void) { return (IJclCardinalArray*)&__IJclCardinalArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalList()
	{
		Jclcontainerintf::_di_IJclCardinalList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalList*(void) { return (IJclCardinalList*)&__IJclCardinalArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalCollection()
	{
		Jclcontainerintf::_di_IJclCardinalCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalCollection*(void) { return (IJclCardinalCollection*)&__IJclCardinalArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalEqualityComparer()
	{
		Jclcontainerintf::_di_IJclCardinalEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalEqualityComparer*(void) { return (IJclCardinalEqualityComparer*)&__IJclCardinalEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalArray; }
	#endif
	
};


class DELPHICLASS TJclCardinalArrayIterator;
class PASCALIMPLEMENTATION TJclCardinalArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclCardinalArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclCardinalArrayIterator(TJclCardinalArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(unsigned AValue);
	void __fastcall Extract(void);
	unsigned __fastcall GetValue(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(unsigned AValue);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclCardinalIterator AIterator);
	unsigned __fastcall Next(void);
	int __fastcall NextIndex(void);
	unsigned __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetValue(unsigned AValue);
	bool __fastcall MoveNext(void);
	__property unsigned Current = {read=GetValue, nodefault};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclCardinalArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCardinalIterator;	/* Jclcontainerintf::IJclCardinalIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalIterator; }
	#endif
	
};


class DELPHICLASS TJclInt64ArrayList;
class PASCALIMPLEMENTATION TJclInt64ArrayList : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynInt64Array FElementData;
	__int64 __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64ArrayList(int ACapacity)/* overload */;
	__fastcall TJclInt64ArrayList(const Jclcontainerintf::_di_IJclInt64Collection ACollection)/* overload */;
	__fastcall virtual ~TJclInt64ArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(const __int64 AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(const __int64 AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	bool __fastcall Extract(const __int64 AValue);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	Jclcontainerintf::_di_IJclInt64Iterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclInt64Iterator __fastcall Last(void);
	bool __fastcall Remove(const __int64 AValue);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclInt64Iterator __fastcall GetEnumerator(void);
	__int64 __fastcall Delete(int Index);
	__int64 __fastcall ExtractIndex(int Index);
	__int64 __fastcall GetValue(int Index);
	int __fastcall IndexOf(const __int64 AValue);
	bool __fastcall Insert(int Index, const __int64 AValue);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	int __fastcall LastIndexOf(const __int64 AValue);
	void __fastcall SetValue(int Index, const __int64 AValue);
	Jclcontainerintf::_di_IJclInt64List __fastcall SubList(int First, int Count);
private:
	void *__IJclInt64Array;	/* Jclcontainerintf::IJclInt64Array */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Array()
	{
		Jclcontainerintf::_di_IJclInt64Array intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Array*(void) { return (IJclInt64Array*)&__IJclInt64Array; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64List()
	{
		Jclcontainerintf::_di_IJclInt64List intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64List*(void) { return (IJclInt64List*)&__IJclInt64Array; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Collection()
	{
		Jclcontainerintf::_di_IJclInt64Collection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Collection*(void) { return (IJclInt64Collection*)&__IJclInt64Array; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64EqualityComparer()
	{
		Jclcontainerintf::_di_IJclInt64EqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64EqualityComparer*(void) { return (IJclInt64EqualityComparer*)&__IJclInt64EqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Array; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Array; }
	#endif
	
};


class DELPHICLASS TJclInt64ArrayIterator;
class PASCALIMPLEMENTATION TJclInt64ArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclInt64ArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclInt64ArrayIterator(TJclInt64ArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const __int64 AValue);
	void __fastcall Extract(void);
	__int64 __fastcall GetValue(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const __int64 AValue);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclInt64Iterator AIterator);
	__int64 __fastcall Next(void);
	int __fastcall NextIndex(void);
	__int64 __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetValue(const __int64 AValue);
	bool __fastcall MoveNext(void);
	__property __int64 Current = {read=GetValue};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInt64ArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclInt64Iterator;	/* Jclcontainerintf::IJclInt64Iterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Iterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64Iterator; }
	#endif
	
};


class DELPHICLASS TJclPtrArrayList;
class PASCALIMPLEMENTATION TJclPtrArrayList : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynPointerArray FElementData;
	void * __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrArrayList(int ACapacity)/* overload */;
	__fastcall TJclPtrArrayList(const Jclcontainerintf::_di_IJclPtrCollection ACollection)/* overload */;
	__fastcall virtual ~TJclPtrArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(void * APtr);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(void * APtr);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	bool __fastcall Extract(void * APtr);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	Jclcontainerintf::_di_IJclPtrIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclPtrIterator __fastcall Last(void);
	bool __fastcall Remove(void * APtr);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclPtrIterator __fastcall GetEnumerator(void);
	void * __fastcall Delete(int Index);
	void * __fastcall ExtractIndex(int Index);
	void * __fastcall GetPointer(int Index);
	int __fastcall IndexOf(void * APtr);
	bool __fastcall Insert(int Index, void * APtr);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	int __fastcall LastIndexOf(void * APtr);
	void __fastcall SetPointer(int Index, void * APtr);
	Jclcontainerintf::_di_IJclPtrList __fastcall SubList(int First, int Count);
private:
	void *__IJclPtrArray;	/* Jclcontainerintf::IJclPtrArray */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrArray()
	{
		Jclcontainerintf::_di_IJclPtrArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrArray*(void) { return (IJclPtrArray*)&__IJclPtrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrList()
	{
		Jclcontainerintf::_di_IJclPtrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrList*(void) { return (IJclPtrList*)&__IJclPtrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrCollection()
	{
		Jclcontainerintf::_di_IJclPtrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrCollection*(void) { return (IJclPtrCollection*)&__IJclPtrArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrEqualityComparer()
	{
		Jclcontainerintf::_di_IJclPtrEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrEqualityComparer*(void) { return (IJclPtrEqualityComparer*)&__IJclPtrEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrArray; }
	#endif
	
};


class DELPHICLASS TJclPtrArrayIterator;
class PASCALIMPLEMENTATION TJclPtrArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclPtrArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclPtrArrayIterator(TJclPtrArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(void * APtr);
	void __fastcall Extract(void);
	void * __fastcall GetPointer(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(void * APtr);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclPtrIterator AIterator);
	void * __fastcall Next(void);
	int __fastcall NextIndex(void);
	void * __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetPointer(void * APtr);
	bool __fastcall MoveNext(void);
	__property void * Current = {read=GetPointer};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPtrArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclPtrIterator;	/* Jclcontainerintf::IJclPtrIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrIterator; }
	#endif
	
};


class DELPHICLASS TJclArrayList;
class PASCALIMPLEMENTATION TJclArrayList : public Jclabstractcontainers::TJclAbstractContainer
{
	typedef Jclabstractcontainers::TJclAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynObjectArray FElementData;
	System::TObject* __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclArrayList(int ACapacity, bool AOwnsObjects)/* overload */;
	__fastcall TJclArrayList(const Jclcontainerintf::_di_IJclCollection ACollection, bool AOwnsObjects)/* overload */;
	__fastcall virtual ~TJclArrayList(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(System::TObject* AObject);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(System::TObject* AObject);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclCollection ACollection);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclCollection ACollection);
	bool __fastcall Extract(System::TObject* AObject);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclCollection ACollection);
	Jclcontainerintf::_di_IJclIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclIterator __fastcall Last(void);
	bool __fastcall Remove(System::TObject* AObject);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclIterator __fastcall GetEnumerator(void);
	System::TObject* __fastcall Delete(int Index);
	System::TObject* __fastcall ExtractIndex(int Index);
	System::TObject* __fastcall GetObject(int Index);
	int __fastcall IndexOf(System::TObject* AObject);
	bool __fastcall Insert(int Index, System::TObject* AObject);
	bool __fastcall InsertAll(int Index, const Jclcontainerintf::_di_IJclCollection ACollection);
	int __fastcall LastIndexOf(System::TObject* AObject);
	void __fastcall SetObject(int Index, System::TObject* AObject);
	Jclcontainerintf::_di_IJclList __fastcall SubList(int First, int Count);
private:
	void *__IJclArray;	/* Jclcontainerintf::IJclArray */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclArray()
	{
		Jclcontainerintf::_di_IJclArray intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclArray*(void) { return (IJclArray*)&__IJclArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclList()
	{
		Jclcontainerintf::_di_IJclList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList*(void) { return (IJclList*)&__IJclArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCollection()
	{
		Jclcontainerintf::_di_IJclCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection*(void) { return (IJclCollection*)&__IJclArray; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclEqualityComparer()
	{
		Jclcontainerintf::_di_IJclEqualityComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEqualityComparer*(void) { return (IJclEqualityComparer*)&__IJclEqualityComparer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclObjectOwner()
	{
		Jclcontainerintf::_di_IJclObjectOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclObjectOwner*(void) { return (IJclObjectOwner*)&__IJclObjectOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclArray; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclArray; }
	#endif
	
};


class DELPHICLASS TJclArrayIterator;
class PASCALIMPLEMENTATION TJclArrayIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	TJclArrayList* FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclArrayIterator(TJclArrayList* AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(System::TObject* AObject);
	void __fastcall Extract(void);
	System::TObject* __fastcall GetObject(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(System::TObject* AObject);
	bool __fastcall IteratorEquals(const Jclcontainerintf::_di_IJclIterator AIterator);
	System::TObject* __fastcall Next(void);
	int __fastcall NextIndex(void);
	System::TObject* __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetObject(System::TObject* AObject);
	bool __fastcall MoveNext(void);
	__property System::TObject* Current = {read=GetObject};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclArrayIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIterator;	/* Jclcontainerintf::IJclIterator */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclIterator; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArrayList__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArrayList__1 : public Jclabstractcontainers::TJclAbstractContainer__1<T>
{
	typedef Jclabstractcontainers::TJclAbstractContainer__1<T> inherited;
	
protected:
	typedef DynamicArray<T> TDynArray;
	
	
protected:
	void __fastcall MoveArray(TDynArray &List, int FromIndex, int ToIndex, int Count);
	
private:
	TDynArray FElementData;
	T __fastcall RaiseOutOfBoundsError(void);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclArrayList__1(int ACapacity, bool AOwnsItems)/* overload */;
	__fastcall TJclArrayList__1(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems)/* overload */;
	__fastcall virtual ~TJclArrayList__1(void);
	virtual void __fastcall SetCapacity(int Value);
	bool __fastcall Add(const T AItem);
	bool __fastcall AddAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	void __fastcall Clear(void);
	bool __fastcall Contains(const T AItem);
	bool __fastcall ContainsAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	bool __fastcall CollectionEquals(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	bool __fastcall Extract(const T AItem);
	bool __fastcall ExtractAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >  __fastcall First(void);
	bool __fastcall IsEmpty(void);
	System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >  __fastcall Last(void);
	bool __fastcall Remove(const T AItem);
	bool __fastcall RemoveAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	bool __fastcall RetainAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	int __fastcall Size(void);
	System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >  __fastcall GetEnumerator(void);
	T __fastcall Delete(int Index);
	T __fastcall ExtractIndex(int Index);
	T __fastcall GetItem(int Index);
	int __fastcall IndexOf(const T AItem);
	bool __fastcall Insert(int Index, const T AItem);
	bool __fastcall InsertAll(int Index, const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	int __fastcall LastIndexOf(const T AItem);
	void __fastcall SetItem(int Index, const T AItem);
	System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >  __fastcall SubList(int First, int Count);
private:
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclArray__1<T>*(void) { return (IJclArray__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEqualityComparer__1<T>*(void) { return (IJclEqualityComparer__1<T>*)&__IJclEqualityComparer__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclItemOwner__1<T>*(void) { return (IJclItemOwner__1<T>*)&__IJclItemOwner__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclArray__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclArray__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArrayIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArrayIterator__1 : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	int FCursor;
	TItrStart FStart;
	System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >  FOwnList;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	
public:
	__fastcall TJclArrayIterator__1(System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >  AOwnList, int ACursor, bool AValid, TItrStart AStart);
	bool __fastcall Add(const T AItem);
	void __fastcall Extract(void);
	T __fastcall GetItem(void);
	bool __fastcall HasNext(void);
	bool __fastcall HasPrevious(void);
	bool __fastcall Insert(const T AItem);
	bool __fastcall IteratorEquals(const System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >  AIterator);
	T __fastcall Next(void);
	int __fastcall NextIndex(void);
	T __fastcall Previous(void);
	int __fastcall PreviousIndex(void);
	void __fastcall Remove(void);
	void __fastcall Reset(void);
	void __fastcall SetItem(const T AItem);
	bool __fastcall MoveNext(void);
	__property T Current = {read=GetItem};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclArrayIterator__1(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIterator__1;	/* Jclcontainerintf::IJclIterator__1<T> */
	
public:
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArrayListE__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArrayListE__1 : public TJclArrayList__1<T>
{
	typedef TJclArrayList__1<T> inherited;
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  FEqualityComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclArrayListE__1(const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  AEqualityComparer, int ACapacity, bool AOwnsItems)/* overload */;
	__fastcall TJclArrayListE__1(const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  AEqualityComparer, const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems)/* overload */;
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  EqualityComparer = {read=FEqualityComparer, write=FEqualityComparer};
public:
	/* TJclArrayList<T>.Destroy */ inline __fastcall virtual ~TJclArrayListE__1(void) { }
	
private:
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclArray__1<T>*(void) { return (IJclArray__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEqualityComparer__1<T>*(void) { return (IJclEqualityComparer__1<T>*)&__IJclEqualityComparer__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclItemOwner__1<T>*(void) { return (IJclItemOwner__1<T>*)&__IJclItemOwner__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclArray__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclArray__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArrayListF__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArrayListF__1 : public TJclArrayList__1<T>
{
	typedef TJclArrayList__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclArrayListF__1(const _decl_TEqualityCompare__1(T, AEqualityCompare), int ACapacity, bool AOwnsItems)/* overload */;
	__fastcall TJclArrayListF__1(const _decl_TEqualityCompare__1(T, AEqualityCompare), const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems)/* overload */;
public:
	/* TJclArrayList<T>.Destroy */ inline __fastcall virtual ~TJclArrayListF__1(void) { }
	
private:
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclArray__1<T>*(void) { return (IJclArray__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEqualityComparer__1<T>*(void) { return (IJclEqualityComparer__1<T>*)&__IJclEqualityComparer__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclItemOwner__1<T>*(void) { return (IJclItemOwner__1<T>*)&__IJclItemOwner__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclArray__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclArray__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArrayListI__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArrayListI__1 : public TJclArrayList__1<T>
{
	typedef TJclArrayList__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	virtual bool __fastcall ItemsEqual(const T A, const T B);
public:
	/* TJclArrayList<T>.Create */ inline __fastcall TJclArrayListI__1(int ACapacity, bool AOwnsItems)/* overload */ : TJclArrayList__1<T>(ACapacity, AOwnsItems) { }
	/* TJclArrayList<T>.Destroy */ inline __fastcall virtual ~TJclArrayListI__1(void) { }
	
private:
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclArray__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclArray__1<T>*(void) { return (IJclArray__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclArray__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEqualityComparer__1<T>*(void) { return (IJclEqualityComparer__1<T>*)&__IJclEqualityComparer__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclItemOwner__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclItemOwner__1<T>*(void) { return (IJclItemOwner__1<T>*)&__IJclItemOwner__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclArray__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclArray__1; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclarraylists */
using namespace Jclarraylists;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclarraylistsHPP
