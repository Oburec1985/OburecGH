// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclhashsets.pas' rev: 21.00

#ifndef JclhashsetsHPP
#define JclhashsetsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclalgorithms.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclabstractcontainers.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclhashmaps.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclhashsets
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TRefUnique;
class PASCALIMPLEMENTATION TRefUnique : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
public:
	HIDESBASE bool __fastcall Equals(TRefUnique* Other);
	_decl_TEqualityCompare__1(TRefUnique*, __fastcall GetEqualityCompare(void));
	void __fastcall SetEqualityCompare(_decl_TEqualityCompare__1(TRefUnique*, Value));
	bool __fastcall ItemsEqual(const TRefUnique* A, const TRefUnique* B);
	__property _decl_TEqualityCompare__1(TRefUnique*, EqualityCompare) = {read=GetEqualityCompare, write=SetEqualityCompare};
	// __property Jclcontainerintf::TEqualityCompare__1<TRefUnique*>  EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
public:
	/* TObject.Create */ inline __fastcall TRefUnique(void) : System::TInterfacedObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TRefUnique(void) { }
	
private:
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<TRefUnique*> */
	void *__IEquatable__1;	/* System::IEquatable__1<TRefUnique*> */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TRefUnique*> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<TRefUnique*> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclEqualityComparer__1<TRefUnique*>*(void) { return (IJclEqualityComparer__1<TRefUnique*>*)&__IJclEqualityComparer__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<System::IEquatable__1<TRefUnique*> >()
	{
		System::DelphiInterface<System::IEquatable__1<TRefUnique*> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IEquatable__1<TRefUnique*>*(void) { return (IEquatable__1<TRefUnique*>*)&__IEquatable__1; }
	#endif
	
};


class DELPHICLASS TJclIntfHashSet;
class PASCALIMPLEMENTATION TJclIntfHashSet : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclIntfHashSet(int ACapacity)/* overload */;
	
private:
	Jclcontainerintf::_di_IJclIntfMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfHashSet(const Jclcontainerintf::_di_IJclIntfMap AMap)/* overload */;
	__fastcall virtual ~TJclIntfHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
private:
	void *__IJclIntfSet;	/* Jclcontainerintf::IJclIntfSet */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfSet()
	{
		Jclcontainerintf::_di_IJclIntfSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfSet*(void) { return (IJclIntfSet*)&__IJclIntfSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCollection()
	{
		Jclcontainerintf::_di_IJclIntfCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCollection*(void) { return (IJclIntfCollection*)&__IJclIntfSet; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfSet; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrHashSet;
class PASCALIMPLEMENTATION TJclAnsiStrHashSet : public Jclabstractcontainers::TJclAnsiStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclAnsiStrHashSet(int ACapacity)/* overload */;
	virtual bool __fastcall GetCaseSensitive(void);
	virtual void __fastcall SetCaseSensitive(bool Value);
	virtual Jclcontainerintf::TJclAnsiStrEncoding __fastcall GetEncoding(void);
	virtual void __fastcall SetEncoding(Jclcontainerintf::TJclAnsiStrEncoding Value);
	
private:
	Jclcontainerintf::_di_IJclAnsiStrMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrHashSet(const Jclcontainerintf::_di_IJclAnsiStrMap AMap)/* overload */;
	__fastcall virtual ~TJclAnsiStrHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
private:
	void *__IJclAnsiStrSet;	/* Jclcontainerintf::IJclAnsiStrSet */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrSet()
	{
		Jclcontainerintf::_di_IJclAnsiStrSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrSet*(void) { return (IJclAnsiStrSet*)&__IJclAnsiStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrCollection()
	{
		Jclcontainerintf::_di_IJclAnsiStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrCollection*(void) { return (IJclAnsiStrCollection*)&__IJclAnsiStrSet; }
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
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrSet; }
	#endif
	
};


class DELPHICLASS TJclWideStrHashSet;
class PASCALIMPLEMENTATION TJclWideStrHashSet : public Jclabstractcontainers::TJclWideStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclWideStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclWideStrHashSet(int ACapacity)/* overload */;
	virtual bool __fastcall GetCaseSensitive(void);
	virtual void __fastcall SetCaseSensitive(bool Value);
	virtual Jclcontainerintf::TJclWideStrEncoding __fastcall GetEncoding(void);
	virtual void __fastcall SetEncoding(Jclcontainerintf::TJclWideStrEncoding Value);
	
private:
	Jclcontainerintf::_di_IJclWideStrMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrHashSet(const Jclcontainerintf::_di_IJclWideStrMap AMap)/* overload */;
	__fastcall virtual ~TJclWideStrHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
private:
	void *__IJclWideStrSet;	/* Jclcontainerintf::IJclWideStrSet */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrSet()
	{
		Jclcontainerintf::_di_IJclWideStrSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrSet*(void) { return (IJclWideStrSet*)&__IJclWideStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrCollection()
	{
		Jclcontainerintf::_di_IJclWideStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrCollection*(void) { return (IJclWideStrCollection*)&__IJclWideStrSet; }
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
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrSet; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrHashSet;
class PASCALIMPLEMENTATION TJclUnicodeStrHashSet : public Jclabstractcontainers::TJclUnicodeStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclUnicodeStrHashSet(int ACapacity)/* overload */;
	virtual bool __fastcall GetCaseSensitive(void);
	virtual void __fastcall SetCaseSensitive(bool Value);
	
private:
	Jclcontainerintf::_di_IJclUnicodeStrMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrHashSet(const Jclcontainerintf::_di_IJclUnicodeStrMap AMap)/* overload */;
	__fastcall virtual ~TJclUnicodeStrHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
private:
	void *__IJclUnicodeStrSet;	/* Jclcontainerintf::IJclUnicodeStrSet */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrSet()
	{
		Jclcontainerintf::_di_IJclUnicodeStrSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrSet*(void) { return (IJclUnicodeStrSet*)&__IJclUnicodeStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrCollection()
	{
		Jclcontainerintf::_di_IJclUnicodeStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrCollection*(void) { return (IJclUnicodeStrCollection*)&__IJclUnicodeStrSet; }
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
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrSet; }
	#endif
	
};


typedef TJclUnicodeStrHashSet TJclStrHashSet;

class DELPHICLASS TJclSingleHashSet;
class PASCALIMPLEMENTATION TJclSingleHashSet : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclSingleHashSet(int ACapacity)/* overload */;
	virtual float __fastcall GetPrecision(void);
	virtual void __fastcall SetPrecision(const float Value);
	
private:
	Jclcontainerintf::_di_IJclSingleMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleHashSet(const Jclcontainerintf::_di_IJclSingleMap AMap)/* overload */;
	__fastcall virtual ~TJclSingleHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
private:
	void *__IJclSingleSet;	/* Jclcontainerintf::IJclSingleSet */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleSet()
	{
		Jclcontainerintf::_di_IJclSingleSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleSet*(void) { return (IJclSingleSet*)&__IJclSingleSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleCollection()
	{
		Jclcontainerintf::_di_IJclSingleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleCollection*(void) { return (IJclSingleCollection*)&__IJclSingleSet; }
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
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleSet; }
	#endif
	
};


class DELPHICLASS TJclDoubleHashSet;
class PASCALIMPLEMENTATION TJclDoubleHashSet : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclDoubleHashSet(int ACapacity)/* overload */;
	virtual double __fastcall GetPrecision(void);
	virtual void __fastcall SetPrecision(const double Value);
	
private:
	Jclcontainerintf::_di_IJclDoubleMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleHashSet(const Jclcontainerintf::_di_IJclDoubleMap AMap)/* overload */;
	__fastcall virtual ~TJclDoubleHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
private:
	void *__IJclDoubleSet;	/* Jclcontainerintf::IJclDoubleSet */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleSet()
	{
		Jclcontainerintf::_di_IJclDoubleSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleSet*(void) { return (IJclDoubleSet*)&__IJclDoubleSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleCollection()
	{
		Jclcontainerintf::_di_IJclDoubleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleCollection*(void) { return (IJclDoubleCollection*)&__IJclDoubleSet; }
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
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleSet; }
	#endif
	
};


class DELPHICLASS TJclExtendedHashSet;
class PASCALIMPLEMENTATION TJclExtendedHashSet : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclExtendedHashSet(int ACapacity)/* overload */;
	virtual System::Extended __fastcall GetPrecision(void);
	virtual void __fastcall SetPrecision(const System::Extended Value);
	
private:
	Jclcontainerintf::_di_IJclExtendedMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedHashSet(const Jclcontainerintf::_di_IJclExtendedMap AMap)/* overload */;
	__fastcall virtual ~TJclExtendedHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
private:
	void *__IJclExtendedSet;	/* Jclcontainerintf::IJclExtendedSet */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedSet()
	{
		Jclcontainerintf::_di_IJclExtendedSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedSet*(void) { return (IJclExtendedSet*)&__IJclExtendedSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedCollection()
	{
		Jclcontainerintf::_di_IJclExtendedCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedCollection*(void) { return (IJclExtendedCollection*)&__IJclExtendedSet; }
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
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedSet; }
	#endif
	
};


typedef TJclExtendedHashSet TJclFloatHashSet;

class DELPHICLASS TJclIntegerHashSet;
class PASCALIMPLEMENTATION TJclIntegerHashSet : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclIntegerHashSet(int ACapacity)/* overload */;
	
private:
	Jclcontainerintf::_di_IJclIntegerMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerHashSet(const Jclcontainerintf::_di_IJclIntegerMap AMap)/* overload */;
	__fastcall virtual ~TJclIntegerHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
private:
	void *__IJclIntegerSet;	/* Jclcontainerintf::IJclIntegerSet */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerSet()
	{
		Jclcontainerintf::_di_IJclIntegerSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerSet*(void) { return (IJclIntegerSet*)&__IJclIntegerSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerCollection()
	{
		Jclcontainerintf::_di_IJclIntegerCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerCollection*(void) { return (IJclIntegerCollection*)&__IJclIntegerSet; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerSet; }
	#endif
	
};


class DELPHICLASS TJclCardinalHashSet;
class PASCALIMPLEMENTATION TJclCardinalHashSet : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclCardinalHashSet(int ACapacity)/* overload */;
	
private:
	Jclcontainerintf::_di_IJclCardinalMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalHashSet(const Jclcontainerintf::_di_IJclCardinalMap AMap)/* overload */;
	__fastcall virtual ~TJclCardinalHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
private:
	void *__IJclCardinalSet;	/* Jclcontainerintf::IJclCardinalSet */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalSet()
	{
		Jclcontainerintf::_di_IJclCardinalSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalSet*(void) { return (IJclCardinalSet*)&__IJclCardinalSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalCollection()
	{
		Jclcontainerintf::_di_IJclCardinalCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalCollection*(void) { return (IJclCardinalCollection*)&__IJclCardinalSet; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalSet; }
	#endif
	
};


class DELPHICLASS TJclInt64HashSet;
class PASCALIMPLEMENTATION TJclInt64HashSet : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclInt64HashSet(int ACapacity)/* overload */;
	
private:
	Jclcontainerintf::_di_IJclInt64Map FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64HashSet(const Jclcontainerintf::_di_IJclInt64Map AMap)/* overload */;
	__fastcall virtual ~TJclInt64HashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
private:
	void *__IJclInt64Set;	/* Jclcontainerintf::IJclInt64Set */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Set()
	{
		Jclcontainerintf::_di_IJclInt64Set intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Set*(void) { return (IJclInt64Set*)&__IJclInt64Set; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Collection()
	{
		Jclcontainerintf::_di_IJclInt64Collection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Collection*(void) { return (IJclInt64Collection*)&__IJclInt64Set; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Set; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Set; }
	#endif
	
};


class DELPHICLASS TJclPtrHashSet;
class PASCALIMPLEMENTATION TJclPtrHashSet : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclPtrHashSet(int ACapacity)/* overload */;
	
private:
	Jclcontainerintf::_di_IJclPtrMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrHashSet(const Jclcontainerintf::_di_IJclPtrMap AMap)/* overload */;
	__fastcall virtual ~TJclPtrHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
	bool __fastcall Add(void * AValue);
	bool __fastcall AddAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	void __fastcall Clear(void);
	bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	bool __fastcall Contains(void * AValue);
	bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	bool __fastcall Extract(void * AValue);
	bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	Jclcontainerintf::_di_IJclPtrIterator __fastcall First(void);
	bool __fastcall IsEmpty(void);
	Jclcontainerintf::_di_IJclPtrIterator __fastcall Last(void);
	bool __fastcall Remove(void * AValue);
	bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	int __fastcall Size(void);
	Jclcontainerintf::_di_IJclPtrIterator __fastcall GetEnumerator(void);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
private:
	void *__IJclPtrSet;	/* Jclcontainerintf::IJclPtrSet */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrSet()
	{
		Jclcontainerintf::_di_IJclPtrSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrSet*(void) { return (IJclPtrSet*)&__IJclPtrSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrCollection()
	{
		Jclcontainerintf::_di_IJclPtrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrCollection*(void) { return (IJclPtrCollection*)&__IJclPtrSet; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrSet; }
	#endif
	
};


class DELPHICLASS TJclHashSet;
class PASCALIMPLEMENTATION TJclHashSet : public Jclabstractcontainers::TJclAbstractContainer
{
	typedef Jclabstractcontainers::TJclAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclHashSet(int ACapacity, bool AOwnsObjects)/* overload */;
	virtual System::TObject* __fastcall FreeObject(System::TObject* &AObject);
	virtual bool __fastcall GetOwnsObjects(void);
	
private:
	Jclcontainerintf::_di_IJclMap FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclHashSet(const Jclcontainerintf::_di_IJclMap AMap)/* overload */;
	__fastcall virtual ~TJclHashSet(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclCollection ACollection);
private:
	void *__IJclSet;	/* Jclcontainerintf::IJclSet */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSet()
	{
		Jclcontainerintf::_di_IJclSet intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSet*(void) { return (IJclSet*)&__IJclSet; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCollection()
	{
		Jclcontainerintf::_di_IJclCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection*(void) { return (IJclCollection*)&__IJclSet; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclHashSet__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclHashSet__1 : public Jclabstractcontainers::TJclAbstractContainer__1<T>
{
	typedef Jclabstractcontainers::TJclAbstractContainer__1<T> inherited;
	
public:
	virtual T __fastcall FreeItem(T &AItem);
	virtual bool __fastcall GetOwnsItems(void);
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclMap__2<T,TRefUnique*> >  FMap;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclHashSet__1(const System::DelphiInterface<Jclcontainerintf::IJclMap__2<T,TRefUnique*> >  AMap)/* overload */;
	__fastcall virtual ~TJclHashSet__1(void);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	virtual bool __fastcall GetAllowDefaultElements(void);
	virtual Classes::TDuplicates __fastcall GetDuplicates(void);
	virtual bool __fastcall GetReadOnly(void);
	virtual bool __fastcall GetRemoveSingleElement(void);
	virtual bool __fastcall GetReturnDefaultElements(void);
	virtual bool __fastcall GetThreadSafe(void);
	virtual void __fastcall SetAllowDefaultElements(bool Value);
	virtual void __fastcall SetDuplicates(Classes::TDuplicates Value);
	virtual void __fastcall SetReadOnly(bool Value);
	virtual void __fastcall SetRemoveSingleElement(bool Value);
	virtual void __fastcall SetReturnDefaultElements(bool Value);
	virtual void __fastcall SetThreadSafe(bool Value);
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
	void __fastcall Intersect(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	void __fastcall Subtract(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	void __fastcall Union(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
private:
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSet__1<T>*(void) { return (IJclSet__1<T>*)&__IJclSet__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclHashSetE__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclHashSetE__1 : public TJclHashSet__1<T>
{
	typedef TJclHashSet__1<T> inherited;
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  FEqualityComparer;
	System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<T> >  FHashConverter;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclHashSetE__1(const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  AEqualityComparer, const System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<T> >  AHashConverter, const System::DelphiInterface<Jclcontainerintf::IJclMap__2<T,TRefUnique*> >  AMap)/* overload */;
	__fastcall TJclHashSetE__1(const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  AEqualityComparer, const System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<T> >  AHashConverter, const System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  AComparer, int ACapacity, bool AOwnsItems)/* overload */;
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  EqualityComparer = {read=FEqualityComparer, write=FEqualityComparer};
	__property System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<T> >  HashConverter = {read=FHashConverter, write=FHashConverter};
public:
	/* TJclHashSet<T>.Destroy */ inline __fastcall virtual ~TJclHashSetE__1(void) { }
	
private:
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
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
	operator System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSet__1<T>*(void) { return (IJclSet__1<T>*)&__IJclSet__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclHashSetF__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclHashSetF__1 : public TJclHashSet__1<T>
{
	typedef TJclHashSet__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclHashSetF__1(const _decl_TEqualityCompare__1(T, AEqualityCompare), const System::DelphiInterface<Jclcontainerintf::IJclMap__2<T,TRefUnique*> >  AMap)/* overload */;
	__fastcall TJclHashSetF__1(const _decl_TEqualityCompare__1(T, AEqualityCompare), const _decl_THashConvert__1(T, AHash), const _decl_TCompare__1(T, ACompare), int ACapacity, bool AOwnsItems)/* overload */;
public:
	/* TJclHashSet<T>.Destroy */ inline __fastcall virtual ~TJclHashSetF__1(void) { }
	
private:
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
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
	operator System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSet__1<T>*(void) { return (IJclSet__1<T>*)&__IJclSet__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclHashSetI__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclHashSetI__1 : public TJclHashSet__1<T>
{
	typedef TJclHashSet__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclHashSetI__1(const System::DelphiInterface<Jclcontainerintf::IJclMap__2<T,TRefUnique*> >  AMap)/* overload */;
	__fastcall TJclHashSetI__1(int ACapacity, bool AOwnsItems)/* overload */;
	virtual bool __fastcall ItemsEqual(const T A, const T B);
public:
	/* TJclHashSet<T>.Destroy */ inline __fastcall virtual ~TJclHashSetI__1(void) { }
	
private:
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
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
	operator System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclSet__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSet__1<T>*(void) { return (IJclSet__1<T>*)&__IJclSet__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE TRefUnique* __fastcall RefUnique(void);
extern PACKAGE bool __fastcall EqualityCompareEqObjects(const TRefUnique* Obj1, const TRefUnique* Obj2);

}	/* namespace Jclhashsets */
using namespace Jclhashsets;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclhashsetsHPP
