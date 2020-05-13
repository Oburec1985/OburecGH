// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcllinkedlists.pas' rev: 21.00

#ifndef JcllinkedlistsHPP
#define JcllinkedlistsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclalgorithms.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclabstractcontainers.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcllinkedlists
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TItrStart { isFirst, isLast };
#pragma option pop

class DELPHICLASS TJclIntfLinkedListItem;
class PASCALIMPLEMENTATION TJclIntfLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::_di_IInterface Value;
	TJclIntfLinkedListItem* Next;
	TJclIntfLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclIntfLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfLinkedListItem(void) { }
	
};


class DELPHICLASS TJclIntfLinkedList;
class PASCALIMPLEMENTATION TJclIntfLinkedList : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclIntfLinkedListItem* FStart;
	TJclIntfLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfLinkedList(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	__fastcall virtual ~TJclIntfLinkedList(void);
	bool __fastcall Add(const System::_di_IInterface AInterface);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	bool __fastcall Contains(const System::_di_IInterface AInterface);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
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
	void *__IJclIntfList;	/* Jclcontainerintf::IJclIntfList */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfList()
	{
		Jclcontainerintf::_di_IJclIntfList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfList*(void) { return (IJclIntfList*)&__IJclIntfList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCollection()
	{
		Jclcontainerintf::_di_IJclIntfCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCollection*(void) { return (IJclIntfCollection*)&__IJclIntfList; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfList; }
	#endif
	
};


class DELPHICLASS TJclIntfLinkedListIterator;
class PASCALIMPLEMENTATION TJclIntfLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclIntfLinkedListItem* FCursor;
	TItrStart FStart;
	TJclIntfLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclIntfEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclIntfLinkedListIterator(TJclIntfLinkedList* AOwnList, TJclIntfLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntfLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclAnsiStrLinkedListItem;
class PASCALIMPLEMENTATION TJclAnsiStrLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::AnsiString Value;
	TJclAnsiStrLinkedListItem* Next;
	TJclAnsiStrLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclAnsiStrLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAnsiStrLinkedListItem(void) { }
	
};


class DELPHICLASS TJclAnsiStrLinkedList;
class PASCALIMPLEMENTATION TJclAnsiStrLinkedList : public Jclabstractcontainers::TJclAnsiStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclAnsiStrLinkedListItem* FStart;
	TJclAnsiStrLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrLinkedList(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	__fastcall virtual ~TJclAnsiStrLinkedList(void);
	virtual bool __fastcall Add(const System::AnsiString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual void __fastcall Clear(void);
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual bool __fastcall Contains(const System::AnsiString AString);
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
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
	void *__IJclAnsiStrList;	/* Jclcontainerintf::IJclAnsiStrList */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrList()
	{
		Jclcontainerintf::_di_IJclAnsiStrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrList*(void) { return (IJclAnsiStrList*)&__IJclAnsiStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrCollection()
	{
		Jclcontainerintf::_di_IJclAnsiStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrCollection*(void) { return (IJclAnsiStrCollection*)&__IJclAnsiStrList; }
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
	operator IJclAnsiStrFlatContainer*(void) { return (IJclAnsiStrFlatContainer*)&__IJclAnsiStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrList; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrLinkedListIterator;
class PASCALIMPLEMENTATION TJclAnsiStrLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclAnsiStrLinkedListItem* FCursor;
	TItrStart FStart;
	TJclAnsiStrLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclAnsiStrEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclAnsiStrLinkedListIterator(TJclAnsiStrLinkedList* AOwnList, TJclAnsiStrLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAnsiStrLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclWideStrLinkedListItem;
class PASCALIMPLEMENTATION TJclWideStrLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::WideString Value;
	TJclWideStrLinkedListItem* Next;
	TJclWideStrLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclWideStrLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclWideStrLinkedListItem(void) { }
	
};


class DELPHICLASS TJclWideStrLinkedList;
class PASCALIMPLEMENTATION TJclWideStrLinkedList : public Jclabstractcontainers::TJclWideStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclWideStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclWideStrLinkedListItem* FStart;
	TJclWideStrLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrLinkedList(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	__fastcall virtual ~TJclWideStrLinkedList(void);
	virtual bool __fastcall Add(const System::WideString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual void __fastcall Clear(void);
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual bool __fastcall Contains(const System::WideString AString);
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
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
	void *__IJclWideStrList;	/* Jclcontainerintf::IJclWideStrList */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrList()
	{
		Jclcontainerintf::_di_IJclWideStrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrList*(void) { return (IJclWideStrList*)&__IJclWideStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrCollection()
	{
		Jclcontainerintf::_di_IJclWideStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrCollection*(void) { return (IJclWideStrCollection*)&__IJclWideStrList; }
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
	operator IJclWideStrFlatContainer*(void) { return (IJclWideStrFlatContainer*)&__IJclWideStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrList; }
	#endif
	
};


class DELPHICLASS TJclWideStrLinkedListIterator;
class PASCALIMPLEMENTATION TJclWideStrLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclWideStrLinkedListItem* FCursor;
	TItrStart FStart;
	TJclWideStrLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclWideStrEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclWideStrLinkedListIterator(TJclWideStrLinkedList* AOwnList, TJclWideStrLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclWideStrLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclUnicodeStrLinkedListItem;
class PASCALIMPLEMENTATION TJclUnicodeStrLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::UnicodeString Value;
	TJclUnicodeStrLinkedListItem* Next;
	TJclUnicodeStrLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclUnicodeStrLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclUnicodeStrLinkedListItem(void) { }
	
};


class DELPHICLASS TJclUnicodeStrLinkedList;
class PASCALIMPLEMENTATION TJclUnicodeStrLinkedList : public Jclabstractcontainers::TJclUnicodeStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclUnicodeStrLinkedListItem* FStart;
	TJclUnicodeStrLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrLinkedList(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	__fastcall virtual ~TJclUnicodeStrLinkedList(void);
	virtual bool __fastcall Add(const System::UnicodeString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual void __fastcall Clear(void);
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual bool __fastcall Contains(const System::UnicodeString AString);
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
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
	void *__IJclUnicodeStrList;	/* Jclcontainerintf::IJclUnicodeStrList */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrList()
	{
		Jclcontainerintf::_di_IJclUnicodeStrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrList*(void) { return (IJclUnicodeStrList*)&__IJclUnicodeStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrCollection()
	{
		Jclcontainerintf::_di_IJclUnicodeStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrCollection*(void) { return (IJclUnicodeStrCollection*)&__IJclUnicodeStrList; }
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
	operator IJclUnicodeStrFlatContainer*(void) { return (IJclUnicodeStrFlatContainer*)&__IJclUnicodeStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrList; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrLinkedListIterator;
class PASCALIMPLEMENTATION TJclUnicodeStrLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclUnicodeStrLinkedListItem* FCursor;
	TItrStart FStart;
	TJclUnicodeStrLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclUnicodeStrEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclUnicodeStrLinkedListIterator(TJclUnicodeStrLinkedList* AOwnList, TJclUnicodeStrLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclUnicodeStrLinkedListIterator(void) { }
	
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


typedef TJclUnicodeStrLinkedListItem TJclStrLinkedListItem;

typedef TJclUnicodeStrLinkedList TJclStrLinkedList;

typedef TJclUnicodeStrLinkedListIterator TJclStrLinkedListIterator;

class DELPHICLASS TJclSingleLinkedListItem;
class PASCALIMPLEMENTATION TJclSingleLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	float Value;
	TJclSingleLinkedListItem* Next;
	TJclSingleLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclSingleLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSingleLinkedListItem(void) { }
	
};


class DELPHICLASS TJclSingleLinkedList;
class PASCALIMPLEMENTATION TJclSingleLinkedList : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclSingleLinkedListItem* FStart;
	TJclSingleLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleLinkedList(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	__fastcall virtual ~TJclSingleLinkedList(void);
	bool __fastcall Add(const float AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	bool __fastcall Contains(const float AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
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
	void *__IJclSingleList;	/* Jclcontainerintf::IJclSingleList */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleList()
	{
		Jclcontainerintf::_di_IJclSingleList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleList*(void) { return (IJclSingleList*)&__IJclSingleList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleCollection()
	{
		Jclcontainerintf::_di_IJclSingleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleCollection*(void) { return (IJclSingleCollection*)&__IJclSingleList; }
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
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleList; }
	#endif
	
};


class DELPHICLASS TJclSingleLinkedListIterator;
class PASCALIMPLEMENTATION TJclSingleLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclSingleLinkedListItem* FCursor;
	TItrStart FStart;
	TJclSingleLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclSingleEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclSingleLinkedListIterator(TJclSingleLinkedList* AOwnList, TJclSingleLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclSingleLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclDoubleLinkedListItem;
class PASCALIMPLEMENTATION TJclDoubleLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	double Value;
	TJclDoubleLinkedListItem* Next;
	TJclDoubleLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclDoubleLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDoubleLinkedListItem(void) { }
	
};


class DELPHICLASS TJclDoubleLinkedList;
class PASCALIMPLEMENTATION TJclDoubleLinkedList : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclDoubleLinkedListItem* FStart;
	TJclDoubleLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleLinkedList(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	__fastcall virtual ~TJclDoubleLinkedList(void);
	bool __fastcall Add(const double AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	bool __fastcall Contains(const double AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
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
	void *__IJclDoubleList;	/* Jclcontainerintf::IJclDoubleList */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleList()
	{
		Jclcontainerintf::_di_IJclDoubleList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleList*(void) { return (IJclDoubleList*)&__IJclDoubleList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleCollection()
	{
		Jclcontainerintf::_di_IJclDoubleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleCollection*(void) { return (IJclDoubleCollection*)&__IJclDoubleList; }
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
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleList; }
	#endif
	
};


class DELPHICLASS TJclDoubleLinkedListIterator;
class PASCALIMPLEMENTATION TJclDoubleLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclDoubleLinkedListItem* FCursor;
	TItrStart FStart;
	TJclDoubleLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclDoubleEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclDoubleLinkedListIterator(TJclDoubleLinkedList* AOwnList, TJclDoubleLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclDoubleLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclExtendedLinkedListItem;
class PASCALIMPLEMENTATION TJclExtendedLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::Extended Value;
	TJclExtendedLinkedListItem* Next;
	TJclExtendedLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclExtendedLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclExtendedLinkedListItem(void) { }
	
};


class DELPHICLASS TJclExtendedLinkedList;
class PASCALIMPLEMENTATION TJclExtendedLinkedList : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclExtendedLinkedListItem* FStart;
	TJclExtendedLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedLinkedList(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	__fastcall virtual ~TJclExtendedLinkedList(void);
	bool __fastcall Add(const System::Extended AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	bool __fastcall Contains(const System::Extended AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
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
	void *__IJclExtendedList;	/* Jclcontainerintf::IJclExtendedList */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedList()
	{
		Jclcontainerintf::_di_IJclExtendedList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedList*(void) { return (IJclExtendedList*)&__IJclExtendedList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedCollection()
	{
		Jclcontainerintf::_di_IJclExtendedCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedCollection*(void) { return (IJclExtendedCollection*)&__IJclExtendedList; }
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
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedList; }
	#endif
	
};


class DELPHICLASS TJclExtendedLinkedListIterator;
class PASCALIMPLEMENTATION TJclExtendedLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclExtendedLinkedListItem* FCursor;
	TItrStart FStart;
	TJclExtendedLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclExtendedEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclExtendedLinkedListIterator(TJclExtendedLinkedList* AOwnList, TJclExtendedLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclExtendedLinkedListIterator(void) { }
	
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


typedef TJclExtendedLinkedListItem TJclFloatLinkedListItem;

typedef TJclExtendedLinkedList TJclFloatLinkedList;

typedef TJclExtendedLinkedListIterator TJclFloatLinkedListIterator;

class DELPHICLASS TJclIntegerLinkedListItem;
class PASCALIMPLEMENTATION TJclIntegerLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	int Value;
	TJclIntegerLinkedListItem* Next;
	TJclIntegerLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclIntegerLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntegerLinkedListItem(void) { }
	
};


class DELPHICLASS TJclIntegerLinkedList;
class PASCALIMPLEMENTATION TJclIntegerLinkedList : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclIntegerLinkedListItem* FStart;
	TJclIntegerLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerLinkedList(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	__fastcall virtual ~TJclIntegerLinkedList(void);
	bool __fastcall Add(int AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	bool __fastcall Contains(int AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
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
	void *__IJclIntegerList;	/* Jclcontainerintf::IJclIntegerList */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerList()
	{
		Jclcontainerintf::_di_IJclIntegerList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerList*(void) { return (IJclIntegerList*)&__IJclIntegerList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerCollection()
	{
		Jclcontainerintf::_di_IJclIntegerCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerCollection*(void) { return (IJclIntegerCollection*)&__IJclIntegerList; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerList; }
	#endif
	
};


class DELPHICLASS TJclIntegerLinkedListIterator;
class PASCALIMPLEMENTATION TJclIntegerLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclIntegerLinkedListItem* FCursor;
	TItrStart FStart;
	TJclIntegerLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclIntegerEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclIntegerLinkedListIterator(TJclIntegerLinkedList* AOwnList, TJclIntegerLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntegerLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclCardinalLinkedListItem;
class PASCALIMPLEMENTATION TJclCardinalLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	unsigned Value;
	TJclCardinalLinkedListItem* Next;
	TJclCardinalLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclCardinalLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCardinalLinkedListItem(void) { }
	
};


class DELPHICLASS TJclCardinalLinkedList;
class PASCALIMPLEMENTATION TJclCardinalLinkedList : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclCardinalLinkedListItem* FStart;
	TJclCardinalLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalLinkedList(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	__fastcall virtual ~TJclCardinalLinkedList(void);
	bool __fastcall Add(unsigned AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	bool __fastcall Contains(unsigned AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
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
	void *__IJclCardinalList;	/* Jclcontainerintf::IJclCardinalList */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalList()
	{
		Jclcontainerintf::_di_IJclCardinalList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalList*(void) { return (IJclCardinalList*)&__IJclCardinalList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalCollection()
	{
		Jclcontainerintf::_di_IJclCardinalCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalCollection*(void) { return (IJclCardinalCollection*)&__IJclCardinalList; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalList; }
	#endif
	
};


class DELPHICLASS TJclCardinalLinkedListIterator;
class PASCALIMPLEMENTATION TJclCardinalLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclCardinalLinkedListItem* FCursor;
	TItrStart FStart;
	TJclCardinalLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclCardinalEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclCardinalLinkedListIterator(TJclCardinalLinkedList* AOwnList, TJclCardinalLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclCardinalLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclInt64LinkedListItem;
class PASCALIMPLEMENTATION TJclInt64LinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__int64 Value;
	TJclInt64LinkedListItem* Next;
	TJclInt64LinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclInt64LinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInt64LinkedListItem(void) { }
	
};


class DELPHICLASS TJclInt64LinkedList;
class PASCALIMPLEMENTATION TJclInt64LinkedList : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclInt64LinkedListItem* FStart;
	TJclInt64LinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64LinkedList(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	__fastcall virtual ~TJclInt64LinkedList(void);
	bool __fastcall Add(const __int64 AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	bool __fastcall Contains(const __int64 AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
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
	void *__IJclInt64List;	/* Jclcontainerintf::IJclInt64List */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64List()
	{
		Jclcontainerintf::_di_IJclInt64List intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64List*(void) { return (IJclInt64List*)&__IJclInt64List; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Collection()
	{
		Jclcontainerintf::_di_IJclInt64Collection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Collection*(void) { return (IJclInt64Collection*)&__IJclInt64List; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64List; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64List; }
	#endif
	
};


class DELPHICLASS TJclInt64LinkedListIterator;
class PASCALIMPLEMENTATION TJclInt64LinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclInt64LinkedListItem* FCursor;
	TItrStart FStart;
	TJclInt64LinkedList* FOwnList;
	Jclcontainerintf::_di_IJclInt64EqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclInt64LinkedListIterator(TJclInt64LinkedList* AOwnList, TJclInt64LinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInt64LinkedListIterator(void) { }
	
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


class DELPHICLASS TJclPtrLinkedListItem;
class PASCALIMPLEMENTATION TJclPtrLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	void *Value;
	TJclPtrLinkedListItem* Next;
	TJclPtrLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclPtrLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclPtrLinkedListItem(void) { }
	
};


class DELPHICLASS TJclPtrLinkedList;
class PASCALIMPLEMENTATION TJclPtrLinkedList : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclPtrLinkedListItem* FStart;
	TJclPtrLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrLinkedList(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	__fastcall virtual ~TJclPtrLinkedList(void);
	bool __fastcall Add(void * APtr);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	bool __fastcall Contains(void * APtr);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
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
	void *__IJclPtrList;	/* Jclcontainerintf::IJclPtrList */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrList()
	{
		Jclcontainerintf::_di_IJclPtrList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrList*(void) { return (IJclPtrList*)&__IJclPtrList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrCollection()
	{
		Jclcontainerintf::_di_IJclPtrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrCollection*(void) { return (IJclPtrCollection*)&__IJclPtrList; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrList; }
	#endif
	
};


class DELPHICLASS TJclPtrLinkedListIterator;
class PASCALIMPLEMENTATION TJclPtrLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclPtrLinkedListItem* FCursor;
	TItrStart FStart;
	TJclPtrLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclPtrEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclPtrLinkedListIterator(TJclPtrLinkedList* AOwnList, TJclPtrLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPtrLinkedListIterator(void) { }
	
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


class DELPHICLASS TJclLinkedListItem;
class PASCALIMPLEMENTATION TJclLinkedListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::TObject* Value;
	TJclLinkedListItem* Next;
	TJclLinkedListItem* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclLinkedListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclLinkedListItem(void) { }
	
};


class DELPHICLASS TJclLinkedList;
class PASCALIMPLEMENTATION TJclLinkedList : public Jclabstractcontainers::TJclAbstractContainer
{
	typedef Jclabstractcontainers::TJclAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclLinkedListItem* FStart;
	TJclLinkedListItem* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclLinkedList(const Jclcontainerintf::_di_IJclCollection ACollection, bool AOwnsObjects);
	__fastcall virtual ~TJclLinkedList(void);
	bool __fastcall Add(System::TObject* AObject);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclCollection ACollection);
	bool __fastcall Contains(System::TObject* AObject);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclCollection ACollection);
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
	void *__IJclList;	/* Jclcontainerintf::IJclList */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclList()
	{
		Jclcontainerintf::_di_IJclList intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList*(void) { return (IJclList*)&__IJclList; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCollection()
	{
		Jclcontainerintf::_di_IJclCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection*(void) { return (IJclCollection*)&__IJclList; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclList; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclList; }
	#endif
	
};


class DELPHICLASS TJclLinkedListIterator;
class PASCALIMPLEMENTATION TJclLinkedListIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclLinkedListItem* FCursor;
	TItrStart FStart;
	TJclLinkedList* FOwnList;
	Jclcontainerintf::_di_IJclEqualityComparer FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclLinkedListIterator(TJclLinkedList* AOwnList, TJclLinkedListItem* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclLinkedListIterator(void) { }
	
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


template<typename T> class DELPHICLASS TJclLinkedListItem__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclLinkedListItem__1 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	T Value;
	TJclLinkedListItem__1<T>* Next;
	TJclLinkedListItem__1<T>* Previous;
public:
	/* TObject.Create */ inline __fastcall TJclLinkedListItem__1(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclLinkedListItem__1(void) { }
	
};


template<typename T> class DELPHICLASS TJclLinkedList__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclLinkedList__1 : public Jclabstractcontainers::TJclAbstractContainer__1<T>
{
	typedef Jclabstractcontainers::TJclAbstractContainer__1<T> inherited;
	
protected:
	
private:
	TJclLinkedListItem__1<T>* FStart;
	TJclLinkedListItem__1<T>* FEnd;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclLinkedList__1(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems);
	__fastcall virtual ~TJclLinkedList__1(void);
	bool __fastcall Add(const T AItem);
	bool __fastcall AddAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	bool __fastcall Contains(const T AItem);
	bool __fastcall ContainsAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
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
	void *__IJclList__1;	/* Jclcontainerintf::IJclList__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclList__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclList__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclList__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclList__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclLinkedListIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclLinkedListIterator__1 : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
private:
	TJclLinkedListItem__1<T>* FCursor;
	TItrStart FStart;
	System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >  FOwnList;
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  FEqualityComparer;
	
public:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	__fastcall TJclLinkedListIterator__1(System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >  AOwnList, TJclLinkedListItem__1<T>* ACursor, bool AValid, TItrStart AStart);
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
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclLinkedListIterator__1(void) { }
	
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


template<typename T> class DELPHICLASS TJclLinkedListE__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclLinkedListE__1 : public TJclLinkedList__1<T>
{
	typedef TJclLinkedList__1<T> inherited;
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  FEqualityComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclLinkedListE__1(const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  AEqualityComparer, const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems);
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  EqualityComparer = {read=FEqualityComparer, write=FEqualityComparer};
public:
	/* TJclLinkedList<T>.Destroy */ inline __fastcall virtual ~TJclLinkedListE__1(void) { }
	
private:
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclList__1;	/* Jclcontainerintf::IJclList__1<T> */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
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
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclList__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclList__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclList__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclList__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclLinkedListF__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclLinkedListF__1 : public TJclLinkedList__1<T>
{
	typedef TJclLinkedList__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclLinkedListF__1(const _decl_TEqualityCompare__1(T, AEqualityCompare), const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems);
public:
	/* TJclLinkedList<T>.Destroy */ inline __fastcall virtual ~TJclLinkedListF__1(void) { }
	
private:
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclList__1;	/* Jclcontainerintf::IJclList__1<T> */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
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
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclList__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclList__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclList__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclList__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclLinkedListI__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclLinkedListI__1 : public TJclLinkedList__1<T>
{
	typedef TJclLinkedList__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	virtual bool __fastcall ItemsEqual(const T A, const T B);
public:
	/* TJclLinkedList<T>.Create */ inline __fastcall TJclLinkedListI__1(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems) : TJclLinkedList__1<T>(ACollection, AOwnsItems) { }
	/* TJclLinkedList<T>.Destroy */ inline __fastcall virtual ~TJclLinkedListI__1(void) { }
	
private:
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclList__1;	/* Jclcontainerintf::IJclList__1<T> */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
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
	operator System::DelphiInterface<Jclcontainerintf::IJclList__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclList__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclList__1<T>*(void) { return (IJclList__1<T>*)&__IJclList__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclList__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclList__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclList__1; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jcllinkedlists */
using namespace Jcllinkedlists;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcllinkedlistsHPP
