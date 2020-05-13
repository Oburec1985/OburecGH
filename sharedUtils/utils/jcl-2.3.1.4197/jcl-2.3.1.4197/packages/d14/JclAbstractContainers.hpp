// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclabstractcontainers.pas' rev: 21.00

#ifndef JclabstractcontainersHPP
#define JclabstractcontainersHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit
#include <Jclwidestrings.hpp>	// Pascal unit
#include <Jclansistrings.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclabstractcontainers
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclAbstractLockable;
class PASCALIMPLEMENTATION TJclAbstractLockable : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
protected:
	bool FThreadSafe;
	Jclsynch::TJclMultiReadExclusiveWrite* FSyncReaderWriter;
	
public:
	__fastcall TJclAbstractLockable(void);
	__fastcall virtual ~TJclAbstractLockable(void);
	__property Jclsynch::TJclMultiReadExclusiveWrite* SyncReaderWriter = {read=FSyncReaderWriter};
	void __fastcall ReadLock(void);
	void __fastcall ReadUnlock(void);
	void __fastcall WriteLock(void);
	void __fastcall WriteUnlock(void);
private:
	void *__IJclLockable;	/* Jclcontainerintf::IJclLockable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclLockable; }
	#endif
	
};


class DELPHICLASS TJclAbstractContainerBase;
class PASCALIMPLEMENTATION TJclAbstractContainerBase : public TJclAbstractLockable
{
	typedef TJclAbstractLockable inherited;
	
protected:
	bool FAllowDefaultElements;
	Classes::TDuplicates FDuplicates;
	bool FRemoveSingleElement;
	bool FReturnDefaultElements;
	bool FReadOnly;
	int FCapacity;
	int FSize;
	int FAutoGrowParameter;
	Jclcontainerintf::TJclAutoGrowStrategy FAutoGrowStrategy;
	int FAutoPackParameter;
	Jclcontainerintf::TJclAutoPackStrategy FAutoPackStrategy;
	virtual void __fastcall AutoGrow(void);
	virtual void __fastcall AutoPack(void);
	bool __fastcall CheckDuplicate(void);
	virtual TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void) = 0 ;
	virtual void __fastcall AssignDataTo(TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAbstractContainerBase(void);
	void __fastcall Assign(const Jclcontainerintf::_di_IJclBaseContainer Source);
	void __fastcall AssignTo(const Jclcontainerintf::_di_IJclBaseContainer Dest);
	virtual bool __fastcall GetAllowDefaultElements(void);
	System::TObject* __fastcall GetContainerReference(void);
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
	__property bool AllowDefaultElements = {read=GetAllowDefaultElements, write=SetAllowDefaultElements, nodefault};
	__property Classes::TDuplicates Duplicates = {read=GetDuplicates, write=SetDuplicates, nodefault};
	__property bool ReadOnly = {read=GetReadOnly, write=SetReadOnly, nodefault};
	__property bool RemoveSingleElement = {read=GetRemoveSingleElement, write=SetRemoveSingleElement, nodefault};
	__property bool ReturnDefaultElements = {read=GetReturnDefaultElements, write=SetReturnDefaultElements, nodefault};
	__property bool ThreadSafe = {read=GetThreadSafe, write=SetThreadSafe, nodefault};
	System::TObject* __fastcall ObjectClone(void);
	System::_di_IInterface __fastcall IntfClone(void);
	virtual int __fastcall CalcGrowCapacity(int ACapacity, int ASize);
	virtual int __fastcall GetAutoGrowParameter(void);
	virtual Jclcontainerintf::TJclAutoGrowStrategy __fastcall GetAutoGrowStrategy(void);
	virtual void __fastcall Grow(void);
	virtual void __fastcall SetAutoGrowParameter(int Value);
	virtual void __fastcall SetAutoGrowStrategy(Jclcontainerintf::TJclAutoGrowStrategy Value);
	__property int AutoGrowParameter = {read=GetAutoGrowParameter, write=SetAutoGrowParameter, nodefault};
	__property Jclcontainerintf::TJclAutoGrowStrategy AutoGrowStrategy = {read=GetAutoGrowStrategy, write=SetAutoGrowStrategy, nodefault};
	virtual int __fastcall CalcPackCapacity(int ACapacity, int ASize);
	virtual int __fastcall GetAutoPackParameter(void);
	virtual Jclcontainerintf::TJclAutoPackStrategy __fastcall GetAutoPackStrategy(void);
	virtual int __fastcall GetCapacity(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetAutoPackParameter(int Value);
	virtual void __fastcall SetAutoPackStrategy(Jclcontainerintf::TJclAutoPackStrategy Value);
	virtual void __fastcall SetCapacity(int Value);
	__property int AutoPackParameter = {read=GetAutoPackParameter, write=SetAutoPackParameter, nodefault};
	__property Jclcontainerintf::TJclAutoPackStrategy AutoPackStrategy = {read=GetAutoPackStrategy, write=SetAutoPackStrategy, nodefault};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAbstractContainerBase(void) { }
	
private:
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


class DELPHICLASS TJclAbstractIterator;
class PASCALIMPLEMENTATION TJclAbstractIterator : public TJclAbstractLockable
{
	typedef TJclAbstractLockable inherited;
	
private:
	bool FValid;
	
protected:
	void __fastcall CheckValid(void);
	virtual TJclAbstractIterator* __fastcall CreateEmptyIterator(void) = 0 ;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractIterator* Dest);
	
public:
	__fastcall TJclAbstractIterator(bool AValid);
	__property bool Valid = {read=FValid, write=FValid, nodefault};
	void __fastcall Assign(const Jclcontainerintf::_di_IJclAbstractIterator Source);
	void __fastcall AssignTo(const Jclcontainerintf::_di_IJclAbstractIterator Dest);
	System::TObject* __fastcall GetIteratorReference(void);
	System::TObject* __fastcall ObjectClone(void);
	System::_di_IInterface __fastcall IntfClone(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAbstractIterator(void) { }
	
private:
	void *__IJclAbstractIterator;	/* Jclcontainerintf::IJclAbstractIterator */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAbstractIterator()
	{
		Jclcontainerintf::_di_IJclAbstractIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAbstractIterator*(void) { return (IJclAbstractIterator*)&__IJclAbstractIterator; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAbstractIterator; }
	#endif
	
};


class DELPHICLASS TJclIntfAbstractContainer;
class PASCALIMPLEMENTATION TJclIntfAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	Jclcontainerintf::TIntfEqualityCompare FEqualityCompare;
	Jclcontainerintf::TIntfCompare FCompare;
	Jclcontainerintf::TIntfHashConvert FHashConvert;
	Jclcontainerintf::TFreeIntfEvent FOnFreeObject;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeIntfEvent __fastcall GetOnFreeObject(void);
	virtual System::_di_IInterface __fastcall FreeObject(System::_di_IInterface &AInterface);
	void __fastcall SetOnFreeObject(Jclcontainerintf::TFreeIntfEvent Value);
	__property Jclcontainerintf::TFreeIntfEvent OnFreeObject = {read=GetOnFreeObject, write=SetOnFreeObject};
	virtual Jclcontainerintf::TIntfEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TIntfEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const System::_di_IInterface A, const System::_di_IInterface B);
	__property Jclcontainerintf::TIntfEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TIntfCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TIntfCompare Value);
	virtual int __fastcall ItemsCompare(const System::_di_IInterface A, const System::_di_IInterface B);
	__property Jclcontainerintf::TIntfCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TIntfHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TIntfHashConvert Value);
	virtual int __fastcall Hash(const System::_di_IInterface AInterface);
	__property Jclcontainerintf::TIntfHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclIntfAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntfAbstractContainer(void) { }
	
private:
	void *__IJclIntfHashConverter;	/* Jclcontainerintf::IJclIntfHashConverter */
	void *__IJclIntfComparer;	/* Jclcontainerintf::IJclIntfComparer */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclIntfOwner;	/* Jclcontainerintf::IJclIntfOwner */
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfHashConverter()
	{
		Jclcontainerintf::_di_IJclIntfHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfHashConverter*(void) { return (IJclIntfHashConverter*)&__IJclIntfHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfComparer()
	{
		Jclcontainerintf::_di_IJclIntfComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfComparer*(void) { return (IJclIntfComparer*)&__IJclIntfComparer; }
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
	operator Jclcontainerintf::_di_IJclIntfOwner()
	{
		Jclcontainerintf::_di_IJclIntfOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfOwner*(void) { return (IJclIntfOwner*)&__IJclIntfOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


class DELPHICLASS TJclStrAbstractContainer;
class PASCALIMPLEMENTATION TJclStrAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	bool FCaseSensitive;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	virtual bool __fastcall GetCaseSensitive(void);
	virtual void __fastcall SetCaseSensitive(bool Value);
	__property bool CaseSensitive = {read=GetCaseSensitive, write=SetCaseSensitive, nodefault};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclStrAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclStrAbstractContainer(void) { }
	
private:
	void *__IJclStrContainer;	/* Jclcontainerintf::IJclStrContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclStrContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclStrContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclStrContainer; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrAbstractContainer;
class PASCALIMPLEMENTATION TJclAnsiStrAbstractContainer : public TJclStrAbstractContainer
{
	typedef TJclStrAbstractContainer inherited;
	
protected:
	Jclcontainerintf::TJclAnsiStrEncoding FEncoding;
	Jclcontainerintf::TAnsiStrEqualityCompare FEqualityCompare;
	Jclcontainerintf::TAnsiStrCompare FCompare;
	Jclcontainerintf::TAnsiStrHashConvert FHashConvert;
	Jclcontainerintf::TFreeAnsiStrEvent FOnFreeString;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeAnsiStrEvent __fastcall GetOnFreeString(void);
	virtual System::AnsiString __fastcall FreeString(System::AnsiString &AString);
	void __fastcall SetOnFreeString(Jclcontainerintf::TFreeAnsiStrEvent Value);
	__property Jclcontainerintf::TFreeAnsiStrEvent OnFreeString = {read=GetOnFreeString, write=SetOnFreeString};
	virtual Jclcontainerintf::TJclAnsiStrEncoding __fastcall GetEncoding(void);
	virtual void __fastcall SetEncoding(Jclcontainerintf::TJclAnsiStrEncoding Value);
	__property Jclcontainerintf::TJclAnsiStrEncoding Encoding = {read=GetEncoding, write=SetEncoding, nodefault};
	virtual Jclcontainerintf::TAnsiStrEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TAnsiStrEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const System::AnsiString A, const System::AnsiString B);
	__property Jclcontainerintf::TAnsiStrEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TAnsiStrCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TAnsiStrCompare Value);
	virtual int __fastcall ItemsCompare(const System::AnsiString A, const System::AnsiString B);
	__property Jclcontainerintf::TAnsiStrCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TAnsiStrHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TAnsiStrHashConvert Value);
	virtual int __fastcall Hash(const System::AnsiString AString);
	__property Jclcontainerintf::TAnsiStrHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclAnsiStrAbstractContainer(void) : TJclStrAbstractContainer() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAnsiStrAbstractContainer(void) { }
	
private:
	void *__IJclAnsiStrHashConverter;	/* Jclcontainerintf::IJclAnsiStrHashConverter */
	void *__IJclAnsiStrComparer;	/* Jclcontainerintf::IJclAnsiStrComparer */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclAnsiStrContainer;	/* Jclcontainerintf::IJclAnsiStrContainer */
	void *__IJclAnsiStrOwner;	/* Jclcontainerintf::IJclAnsiStrOwner */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrHashConverter()
	{
		Jclcontainerintf::_di_IJclAnsiStrHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrHashConverter*(void) { return (IJclAnsiStrHashConverter*)&__IJclAnsiStrHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrComparer()
	{
		Jclcontainerintf::_di_IJclAnsiStrComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrComparer*(void) { return (IJclAnsiStrComparer*)&__IJclAnsiStrComparer; }
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
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrOwner()
	{
		Jclcontainerintf::_di_IJclAnsiStrOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrOwner*(void) { return (IJclAnsiStrOwner*)&__IJclAnsiStrOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrContainer; }
	#endif
	
};


class DELPHICLASS TJclWideStrAbstractContainer;
class PASCALIMPLEMENTATION TJclWideStrAbstractContainer : public TJclStrAbstractContainer
{
	typedef TJclStrAbstractContainer inherited;
	
protected:
	Jclcontainerintf::TJclWideStrEncoding FEncoding;
	Jclcontainerintf::TWideStrEqualityCompare FEqualityCompare;
	Jclcontainerintf::TWideStrCompare FCompare;
	Jclcontainerintf::TWideStrHashConvert FHashConvert;
	Jclcontainerintf::TFreeWideStrEvent FOnFreeString;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeWideStrEvent __fastcall GetOnFreeString(void);
	virtual System::WideString __fastcall FreeString(System::WideString &AString);
	void __fastcall SetOnFreeString(Jclcontainerintf::TFreeWideStrEvent Value);
	__property Jclcontainerintf::TFreeWideStrEvent OnFreeString = {read=GetOnFreeString, write=SetOnFreeString};
	virtual Jclcontainerintf::TJclWideStrEncoding __fastcall GetEncoding(void);
	virtual void __fastcall SetEncoding(Jclcontainerintf::TJclWideStrEncoding Value);
	__property Jclcontainerintf::TJclWideStrEncoding Encoding = {read=GetEncoding, write=SetEncoding, nodefault};
	virtual Jclcontainerintf::TWideStrEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TWideStrEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const System::WideString A, const System::WideString B);
	__property Jclcontainerintf::TWideStrEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TWideStrCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TWideStrCompare Value);
	virtual int __fastcall ItemsCompare(const System::WideString A, const System::WideString B);
	__property Jclcontainerintf::TWideStrCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TWideStrHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TWideStrHashConvert Value);
	virtual int __fastcall Hash(const System::WideString AString);
	__property Jclcontainerintf::TWideStrHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclWideStrAbstractContainer(void) : TJclStrAbstractContainer() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclWideStrAbstractContainer(void) { }
	
private:
	void *__IJclWideStrHashConverter;	/* Jclcontainerintf::IJclWideStrHashConverter */
	void *__IJclWideStrComparer;	/* Jclcontainerintf::IJclWideStrComparer */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclWideStrContainer;	/* Jclcontainerintf::IJclWideStrContainer */
	void *__IJclWideStrOwner;	/* Jclcontainerintf::IJclWideStrOwner */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrHashConverter()
	{
		Jclcontainerintf::_di_IJclWideStrHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrHashConverter*(void) { return (IJclWideStrHashConverter*)&__IJclWideStrHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrComparer()
	{
		Jclcontainerintf::_di_IJclWideStrComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrComparer*(void) { return (IJclWideStrComparer*)&__IJclWideStrComparer; }
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
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrOwner()
	{
		Jclcontainerintf::_di_IJclWideStrOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrOwner*(void) { return (IJclWideStrOwner*)&__IJclWideStrOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrContainer; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrAbstractContainer;
class PASCALIMPLEMENTATION TJclUnicodeStrAbstractContainer : public TJclStrAbstractContainer
{
	typedef TJclStrAbstractContainer inherited;
	
protected:
	Jclcontainerintf::TUnicodeStrEqualityCompare FEqualityCompare;
	Jclcontainerintf::TUnicodeStrCompare FCompare;
	Jclcontainerintf::TUnicodeStrHashConvert FHashConvert;
	Jclcontainerintf::TFreeUnicodeStrEvent FOnFreeString;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeUnicodeStrEvent __fastcall GetOnFreeString(void);
	virtual System::UnicodeString __fastcall FreeString(System::UnicodeString &AString);
	void __fastcall SetOnFreeString(Jclcontainerintf::TFreeUnicodeStrEvent Value);
	__property Jclcontainerintf::TFreeUnicodeStrEvent OnFreeString = {read=GetOnFreeString, write=SetOnFreeString};
	virtual Jclcontainerintf::TUnicodeStrEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TUnicodeStrEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const System::UnicodeString A, const System::UnicodeString B);
	__property Jclcontainerintf::TUnicodeStrEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TUnicodeStrCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TUnicodeStrCompare Value);
	virtual int __fastcall ItemsCompare(const System::UnicodeString A, const System::UnicodeString B);
	__property Jclcontainerintf::TUnicodeStrCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TUnicodeStrHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TUnicodeStrHashConvert Value);
	virtual int __fastcall Hash(const System::UnicodeString AString);
	__property Jclcontainerintf::TUnicodeStrHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclUnicodeStrAbstractContainer(void) : TJclStrAbstractContainer() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclUnicodeStrAbstractContainer(void) { }
	
private:
	void *__IJclUnicodeStrHashConverter;	/* Jclcontainerintf::IJclUnicodeStrHashConverter */
	void *__IJclUnicodeStrComparer;	/* Jclcontainerintf::IJclUnicodeStrComparer */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclUnicodeStrContainer;	/* Jclcontainerintf::IJclUnicodeStrContainer */
	void *__IJclUnicodeStrOwner;	/* Jclcontainerintf::IJclUnicodeStrOwner */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrHashConverter()
	{
		Jclcontainerintf::_di_IJclUnicodeStrHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrHashConverter*(void) { return (IJclUnicodeStrHashConverter*)&__IJclUnicodeStrHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrComparer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrComparer*(void) { return (IJclUnicodeStrComparer*)&__IJclUnicodeStrComparer; }
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
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrOwner()
	{
		Jclcontainerintf::_di_IJclUnicodeStrOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrOwner*(void) { return (IJclUnicodeStrOwner*)&__IJclUnicodeStrOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrContainer; }
	#endif
	
};


class DELPHICLASS TJclSingleAbstractContainer;
class PASCALIMPLEMENTATION TJclSingleAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	float FPrecision;
	Jclcontainerintf::TSingleEqualityCompare FEqualityCompare;
	Jclcontainerintf::TSingleCompare FCompare;
	Jclcontainerintf::TSingleHashConvert FHashConvert;
	Jclcontainerintf::TFreeSingleEvent FOnFreeSingle;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeSingleEvent __fastcall GetOnFreeSingle(void);
	virtual float __fastcall FreeSingle(float &AValue);
	void __fastcall SetOnFreeSingle(Jclcontainerintf::TFreeSingleEvent Value);
	__property Jclcontainerintf::TFreeSingleEvent OnFreeSingle = {read=GetOnFreeSingle, write=SetOnFreeSingle};
	virtual float __fastcall GetPrecision(void);
	virtual void __fastcall SetPrecision(const float Value);
	__property float Precision = {read=GetPrecision, write=SetPrecision};
	virtual Jclcontainerintf::TSingleEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TSingleEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const float A, const float B);
	__property Jclcontainerintf::TSingleEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TSingleCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TSingleCompare Value);
	virtual int __fastcall ItemsCompare(const float A, const float B);
	__property Jclcontainerintf::TSingleCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TSingleHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TSingleHashConvert Value);
	virtual int __fastcall Hash(const float AValue);
	__property Jclcontainerintf::TSingleHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclSingleAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclSingleAbstractContainer(void) { }
	
private:
	void *__IJclSingleHashConverter;	/* Jclcontainerintf::IJclSingleHashConverter */
	void *__IJclSingleComparer;	/* Jclcontainerintf::IJclSingleComparer */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclSingleContainer;	/* Jclcontainerintf::IJclSingleContainer */
	void *__IJclSingleOwner;	/* Jclcontainerintf::IJclSingleOwner */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleHashConverter()
	{
		Jclcontainerintf::_di_IJclSingleHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleHashConverter*(void) { return (IJclSingleHashConverter*)&__IJclSingleHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleComparer()
	{
		Jclcontainerintf::_di_IJclSingleComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleComparer*(void) { return (IJclSingleComparer*)&__IJclSingleComparer; }
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
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleOwner()
	{
		Jclcontainerintf::_di_IJclSingleOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleOwner*(void) { return (IJclSingleOwner*)&__IJclSingleOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleContainer; }
	#endif
	
};


class DELPHICLASS TJclDoubleAbstractContainer;
class PASCALIMPLEMENTATION TJclDoubleAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	double FPrecision;
	Jclcontainerintf::TDoubleEqualityCompare FEqualityCompare;
	Jclcontainerintf::TDoubleCompare FCompare;
	Jclcontainerintf::TDoubleHashConvert FHashConvert;
	Jclcontainerintf::TFreeDoubleEvent FOnFreeDouble;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeDoubleEvent __fastcall GetOnFreeDouble(void);
	virtual double __fastcall FreeDouble(double &AValue);
	void __fastcall SetOnFreeDouble(Jclcontainerintf::TFreeDoubleEvent Value);
	__property Jclcontainerintf::TFreeDoubleEvent OnFreeDouble = {read=GetOnFreeDouble, write=SetOnFreeDouble};
	virtual double __fastcall GetPrecision(void);
	virtual void __fastcall SetPrecision(const double Value);
	__property double Precision = {read=GetPrecision, write=SetPrecision};
	virtual Jclcontainerintf::TDoubleEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TDoubleEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const double A, const double B);
	__property Jclcontainerintf::TDoubleEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TDoubleCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TDoubleCompare Value);
	virtual int __fastcall ItemsCompare(const double A, const double B);
	__property Jclcontainerintf::TDoubleCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TDoubleHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TDoubleHashConvert Value);
	virtual int __fastcall Hash(const double AValue);
	__property Jclcontainerintf::TDoubleHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclDoubleAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclDoubleAbstractContainer(void) { }
	
private:
	void *__IJclDoubleHashConverter;	/* Jclcontainerintf::IJclDoubleHashConverter */
	void *__IJclDoubleComparer;	/* Jclcontainerintf::IJclDoubleComparer */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclDoubleContainer;	/* Jclcontainerintf::IJclDoubleContainer */
	void *__IJclDoubleOwner;	/* Jclcontainerintf::IJclDoubleOwner */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleHashConverter()
	{
		Jclcontainerintf::_di_IJclDoubleHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleHashConverter*(void) { return (IJclDoubleHashConverter*)&__IJclDoubleHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleComparer()
	{
		Jclcontainerintf::_di_IJclDoubleComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleComparer*(void) { return (IJclDoubleComparer*)&__IJclDoubleComparer; }
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
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleOwner()
	{
		Jclcontainerintf::_di_IJclDoubleOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleOwner*(void) { return (IJclDoubleOwner*)&__IJclDoubleOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleContainer; }
	#endif
	
};


class DELPHICLASS TJclExtendedAbstractContainer;
class PASCALIMPLEMENTATION TJclExtendedAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	System::Extended FPrecision;
	Jclcontainerintf::TExtendedEqualityCompare FEqualityCompare;
	Jclcontainerintf::TExtendedCompare FCompare;
	Jclcontainerintf::TExtendedHashConvert FHashConvert;
	Jclcontainerintf::TFreeExtendedEvent FOnFreeExtended;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeExtendedEvent __fastcall GetOnFreeExtended(void);
	virtual System::Extended __fastcall FreeExtended(System::Extended &AValue);
	void __fastcall SetOnFreeExtended(Jclcontainerintf::TFreeExtendedEvent Value);
	__property Jclcontainerintf::TFreeExtendedEvent OnFreeExtended = {read=GetOnFreeExtended, write=SetOnFreeExtended};
	virtual System::Extended __fastcall GetPrecision(void);
	virtual void __fastcall SetPrecision(const System::Extended Value);
	__property System::Extended Precision = {read=GetPrecision, write=SetPrecision};
	virtual Jclcontainerintf::TExtendedEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TExtendedEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const System::Extended A, const System::Extended B);
	__property Jclcontainerintf::TExtendedEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TExtendedCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TExtendedCompare Value);
	virtual int __fastcall ItemsCompare(const System::Extended A, const System::Extended B);
	__property Jclcontainerintf::TExtendedCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TExtendedHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TExtendedHashConvert Value);
	virtual int __fastcall Hash(const System::Extended AValue);
	__property Jclcontainerintf::TExtendedHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclExtendedAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclExtendedAbstractContainer(void) { }
	
private:
	void *__IJclExtendedHashConverter;	/* Jclcontainerintf::IJclExtendedHashConverter */
	void *__IJclExtendedComparer;	/* Jclcontainerintf::IJclExtendedComparer */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclExtendedContainer;	/* Jclcontainerintf::IJclExtendedContainer */
	void *__IJclExtendedOwner;	/* Jclcontainerintf::IJclExtendedOwner */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedHashConverter()
	{
		Jclcontainerintf::_di_IJclExtendedHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedHashConverter*(void) { return (IJclExtendedHashConverter*)&__IJclExtendedHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedComparer()
	{
		Jclcontainerintf::_di_IJclExtendedComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedComparer*(void) { return (IJclExtendedComparer*)&__IJclExtendedComparer; }
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
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedContainer; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedOwner()
	{
		Jclcontainerintf::_di_IJclExtendedOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedOwner*(void) { return (IJclExtendedOwner*)&__IJclExtendedOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedContainer; }
	#endif
	
};


class DELPHICLASS TJclIntegerAbstractContainer;
class PASCALIMPLEMENTATION TJclIntegerAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	Jclcontainerintf::TIntegerEqualityCompare FEqualityCompare;
	Jclcontainerintf::TIntegerCompare FCompare;
	Jclcontainerintf::TIntegerHashConvert FHashConvert;
	Jclcontainerintf::TFreeIntegerEvent FOnFreeInteger;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeIntegerEvent __fastcall GetOnFreeInteger(void);
	virtual int __fastcall FreeInteger(int &AValue);
	void __fastcall SetOnFreeInteger(Jclcontainerintf::TFreeIntegerEvent Value);
	__property Jclcontainerintf::TFreeIntegerEvent OnFreeInteger = {read=GetOnFreeInteger, write=SetOnFreeInteger};
	virtual Jclcontainerintf::TIntegerEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TIntegerEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(int A, int B);
	__property Jclcontainerintf::TIntegerEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TIntegerCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TIntegerCompare Value);
	virtual int __fastcall ItemsCompare(int A, int B);
	__property Jclcontainerintf::TIntegerCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TIntegerHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TIntegerHashConvert Value);
	virtual int __fastcall Hash(int AValue);
	__property Jclcontainerintf::TIntegerHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclIntegerAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntegerAbstractContainer(void) { }
	
private:
	void *__IJclIntegerHashConverter;	/* Jclcontainerintf::IJclIntegerHashConverter */
	void *__IJclIntegerComparer;	/* Jclcontainerintf::IJclIntegerComparer */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclIntegerOwner;	/* Jclcontainerintf::IJclIntegerOwner */
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerHashConverter()
	{
		Jclcontainerintf::_di_IJclIntegerHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerHashConverter*(void) { return (IJclIntegerHashConverter*)&__IJclIntegerHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerComparer()
	{
		Jclcontainerintf::_di_IJclIntegerComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerComparer*(void) { return (IJclIntegerComparer*)&__IJclIntegerComparer; }
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
	operator Jclcontainerintf::_di_IJclIntegerOwner()
	{
		Jclcontainerintf::_di_IJclIntegerOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerOwner*(void) { return (IJclIntegerOwner*)&__IJclIntegerOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


class DELPHICLASS TJclCardinalAbstractContainer;
class PASCALIMPLEMENTATION TJclCardinalAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	Jclcontainerintf::TCardinalEqualityCompare FEqualityCompare;
	Jclcontainerintf::TCardinalCompare FCompare;
	Jclcontainerintf::TCardinalHashConvert FHashConvert;
	Jclcontainerintf::TFreeCardinalEvent FOnFreeCardinal;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeCardinalEvent __fastcall GetOnFreeCardinal(void);
	virtual unsigned __fastcall FreeCardinal(unsigned &AValue);
	void __fastcall SetOnFreeCardinal(Jclcontainerintf::TFreeCardinalEvent Value);
	__property Jclcontainerintf::TFreeCardinalEvent OnFreeCardinal = {read=GetOnFreeCardinal, write=SetOnFreeCardinal};
	virtual Jclcontainerintf::TCardinalEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TCardinalEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(unsigned A, unsigned B);
	__property Jclcontainerintf::TCardinalEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TCardinalCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TCardinalCompare Value);
	virtual int __fastcall ItemsCompare(unsigned A, unsigned B);
	__property Jclcontainerintf::TCardinalCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TCardinalHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TCardinalHashConvert Value);
	virtual int __fastcall Hash(unsigned AValue);
	__property Jclcontainerintf::TCardinalHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclCardinalAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclCardinalAbstractContainer(void) { }
	
private:
	void *__IJclCardinalHashConverter;	/* Jclcontainerintf::IJclCardinalHashConverter */
	void *__IJclCardinalComparer;	/* Jclcontainerintf::IJclCardinalComparer */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclCardinalOwner;	/* Jclcontainerintf::IJclCardinalOwner */
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalHashConverter()
	{
		Jclcontainerintf::_di_IJclCardinalHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalHashConverter*(void) { return (IJclCardinalHashConverter*)&__IJclCardinalHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalComparer()
	{
		Jclcontainerintf::_di_IJclCardinalComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalComparer*(void) { return (IJclCardinalComparer*)&__IJclCardinalComparer; }
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
	operator Jclcontainerintf::_di_IJclCardinalOwner()
	{
		Jclcontainerintf::_di_IJclCardinalOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalOwner*(void) { return (IJclCardinalOwner*)&__IJclCardinalOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


class DELPHICLASS TJclInt64AbstractContainer;
class PASCALIMPLEMENTATION TJclInt64AbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	Jclcontainerintf::TInt64EqualityCompare FEqualityCompare;
	Jclcontainerintf::TInt64Compare FCompare;
	Jclcontainerintf::TInt64HashConvert FHashConvert;
	Jclcontainerintf::TFreeInt64Event FOnFreeInt64;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreeInt64Event __fastcall GetOnFreeInt64(void);
	virtual __int64 __fastcall FreeInt64(__int64 &AValue);
	void __fastcall SetOnFreeInt64(Jclcontainerintf::TFreeInt64Event Value);
	__property Jclcontainerintf::TFreeInt64Event OnFreeInt64 = {read=GetOnFreeInt64, write=SetOnFreeInt64};
	virtual Jclcontainerintf::TInt64EqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TInt64EqualityCompare Value);
	virtual bool __fastcall ItemsEqual(const __int64 A, const __int64 B);
	__property Jclcontainerintf::TInt64EqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TInt64Compare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TInt64Compare Value);
	virtual int __fastcall ItemsCompare(const __int64 A, const __int64 B);
	__property Jclcontainerintf::TInt64Compare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TInt64HashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TInt64HashConvert Value);
	virtual int __fastcall Hash(const __int64 AValue);
	__property Jclcontainerintf::TInt64HashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclInt64AbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInt64AbstractContainer(void) { }
	
private:
	void *__IJclInt64HashConverter;	/* Jclcontainerintf::IJclInt64HashConverter */
	void *__IJclInt64Comparer;	/* Jclcontainerintf::IJclInt64Comparer */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclInt64Owner;	/* Jclcontainerintf::IJclInt64Owner */
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64HashConverter()
	{
		Jclcontainerintf::_di_IJclInt64HashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64HashConverter*(void) { return (IJclInt64HashConverter*)&__IJclInt64HashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Comparer()
	{
		Jclcontainerintf::_di_IJclInt64Comparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Comparer*(void) { return (IJclInt64Comparer*)&__IJclInt64Comparer; }
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
	operator Jclcontainerintf::_di_IJclInt64Owner()
	{
		Jclcontainerintf::_di_IJclInt64Owner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Owner*(void) { return (IJclInt64Owner*)&__IJclInt64Owner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


class DELPHICLASS TJclPtrAbstractContainer;
class PASCALIMPLEMENTATION TJclPtrAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	Jclcontainerintf::TPtrEqualityCompare FEqualityCompare;
	Jclcontainerintf::TPtrCompare FCompare;
	Jclcontainerintf::TPtrHashConvert FHashConvert;
	Jclcontainerintf::TFreePtrEvent FOnFreePointer;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	Jclcontainerintf::TFreePtrEvent __fastcall GetOnFreePointer(void);
	virtual void * __fastcall FreePointer(void * &APtr);
	void __fastcall SetOnFreePointer(Jclcontainerintf::TFreePtrEvent Value);
	__property Jclcontainerintf::TFreePtrEvent OnFreePointer = {read=GetOnFreePointer, write=SetOnFreePointer};
	virtual Jclcontainerintf::TPtrEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TPtrEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(void * A, void * B);
	__property Jclcontainerintf::TPtrEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TPtrCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TPtrCompare Value);
	virtual int __fastcall ItemsCompare(void * A, void * B);
	__property Jclcontainerintf::TPtrCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::TPtrHashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::TPtrHashConvert Value);
	virtual int __fastcall Hash(void * APtr);
	__property Jclcontainerintf::TPtrHashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclPtrAbstractContainer(void) : TJclAbstractContainerBase() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPtrAbstractContainer(void) { }
	
private:
	void *__IJclPtrHashConverter;	/* Jclcontainerintf::IJclPtrHashConverter */
	void *__IJclPtrComparer;	/* Jclcontainerintf::IJclPtrComparer */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclPtrOwner;	/* Jclcontainerintf::IJclPtrOwner */
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrHashConverter()
	{
		Jclcontainerintf::_di_IJclPtrHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrHashConverter*(void) { return (IJclPtrHashConverter*)&__IJclPtrHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrComparer()
	{
		Jclcontainerintf::_di_IJclPtrComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrComparer*(void) { return (IJclPtrComparer*)&__IJclPtrComparer; }
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
	operator Jclcontainerintf::_di_IJclPtrOwner()
	{
		Jclcontainerintf::_di_IJclPtrOwner intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrOwner*(void) { return (IJclPtrOwner*)&__IJclPtrOwner; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


class DELPHICLASS TJclAbstractContainer;
class PASCALIMPLEMENTATION TJclAbstractContainer : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	bool FOwnsObjects;
	Jclcontainerintf::TEqualityCompare FEqualityCompare;
	Jclcontainerintf::TCompare FCompare;
	Jclcontainerintf::THashConvert FHashConvert;
	Jclcontainerintf::TFreeObjectEvent FOnFreeObject;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAbstractContainer(bool AOwnsObjects);
	Jclcontainerintf::TFreeObjectEvent __fastcall GetOnFreeObject(void);
	virtual System::TObject* __fastcall FreeObject(System::TObject* &AObject);
	void __fastcall SetOnFreeObject(Jclcontainerintf::TFreeObjectEvent Value);
	__property Jclcontainerintf::TFreeObjectEvent OnFreeObject = {read=GetOnFreeObject, write=SetOnFreeObject};
	virtual bool __fastcall GetOwnsObjects(void);
	__property bool OwnsObjects = {read=GetOwnsObjects, nodefault};
	virtual Jclcontainerintf::TEqualityCompare __fastcall GetEqualityCompare(void);
	virtual void __fastcall SetEqualityCompare(Jclcontainerintf::TEqualityCompare Value);
	virtual bool __fastcall ItemsEqual(System::TObject* A, System::TObject* B);
	__property Jclcontainerintf::TEqualityCompare EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual Jclcontainerintf::TCompare __fastcall GetCompare(void);
	virtual void __fastcall SetCompare(Jclcontainerintf::TCompare Value);
	virtual int __fastcall ItemsCompare(System::TObject* A, System::TObject* B);
	__property Jclcontainerintf::TCompare Compare = {read=GetCompare, write=SetCompare};
	virtual Jclcontainerintf::THashConvert __fastcall GetHashConvert(void);
	virtual void __fastcall SetHashConvert(Jclcontainerintf::THashConvert Value);
	virtual int __fastcall Hash(System::TObject* AObject);
	__property Jclcontainerintf::THashConvert HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAbstractContainer(void) { }
	
private:
	void *__IJclHashConverter;	/* Jclcontainerintf::IJclHashConverter */
	void *__IJclComparer;	/* Jclcontainerintf::IJclComparer */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclHashConverter()
	{
		Jclcontainerintf::_di_IJclHashConverter intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclHashConverter*(void) { return (IJclHashConverter*)&__IJclHashConverter; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclComparer()
	{
		Jclcontainerintf::_di_IJclComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclComparer*(void) { return (IJclComparer*)&__IJclComparer; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclAbstractContainer__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclAbstractContainer__1 : public TJclAbstractContainerBase
{
	typedef TJclAbstractContainerBase inherited;
	
protected:
	bool FOwnsItems;
	_decl_TEqualityCompare__1(T, FEqualityCompare);
	// Jclcontainerintf::TEqualityCompare__1<T>  FEqualityCompare;
	_decl_TCompare__1(T, FCompare);
	// Jclcontainerintf::TCompare__1<T>  FCompare;
	_decl_THashConvert__1(T, FHashConvert);
	// Jclcontainerintf::THashConvert__1<T>  FHashConvert;
	_decl_TFreeItemEvent__1(T, FOnFreeItem);
	// Jclcontainerintf::TFreeItemEvent__1<T>  FOnFreeItem;
	virtual void __fastcall AssignPropertiesTo(TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAbstractContainer__1(bool AOwnsItems);
	_decl_TFreeItemEvent__1(T, __fastcall GetOnFreeItem(void));
	virtual T __fastcall FreeItem(T &AItem);
	void __fastcall SetOnFreeItem(_decl_TFreeItemEvent__1(T, &Value));
	__property _decl_TFreeItemEvent__1(T, OnFreeItem) = {read=GetOnFreeItem, write=SetOnFreeItem};
	// __property Jclcontainerintf::TFreeItemEvent__1<T>  OnFreeItem = {read=GetOnFreeItem, write=SetOnFreeItem};
	virtual bool __fastcall GetOwnsItems(void);
	__property bool OwnsItems = {read=GetOwnsItems, nodefault};
	virtual _decl_TEqualityCompare__1(T, __fastcall GetEqualityCompare(void));
	virtual void __fastcall SetEqualityCompare(_decl_TEqualityCompare__1(T, Value));
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property _decl_TEqualityCompare__1(T, EqualityCompare) = {read=GetEqualityCompare, write=SetEqualityCompare};
	// __property Jclcontainerintf::TEqualityCompare__1<T>  EqualityCompare = {read=GetEqualityCompare, write=SetEqualityCompare};
	virtual _decl_TCompare__1(T, __fastcall GetCompare(void));
	virtual void __fastcall SetCompare(_decl_TCompare__1(T, Value));
	virtual int __fastcall ItemsCompare(const T A, const T B);
	__property _decl_TCompare__1(T, Compare) = {read=GetCompare, write=SetCompare};
	// __property Jclcontainerintf::TCompare__1<T>  Compare = {read=GetCompare, write=SetCompare};
	virtual _decl_THashConvert__1(T, __fastcall GetHashConvert(void));
	virtual void __fastcall SetHashConvert(_decl_THashConvert__1(T, Value));
	virtual int __fastcall Hash(const T AItem);
	__property _decl_THashConvert__1(T, HashConvert) = {read=GetHashConvert, write=SetHashConvert};
	// __property Jclcontainerintf::THashConvert__1<T>  HashConvert = {read=GetHashConvert, write=SetHashConvert};
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAbstractContainer__1(void) { }
	
private:
	void *__IJclHashConverter__1;	/* Jclcontainerintf::IJclHashConverter__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclBaseContainer;	/* Jclcontainerintf::IJclBaseContainer */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclHashConverter__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclHashConverter__1<T>*(void) { return (IJclHashConverter__1<T>*)&__IJclHashConverter__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclComparer__1<T>*(void) { return (IJclComparer__1<T>*)&__IJclComparer__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclBaseContainer; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBaseContainer; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrAbstractCollection;
class PASCALIMPLEMENTATION TJclAnsiStrAbstractCollection : public TJclAnsiStrAbstractContainer
{
	typedef TJclAnsiStrAbstractContainer inherited;
	
public:
	virtual bool __fastcall Add(const System::AnsiString AString) = 0 ;
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall Contains(const System::AnsiString AString) = 0 ;
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection) = 0 ;
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection) = 0 ;
	virtual bool __fastcall Extract(const System::AnsiString AString) = 0 ;
	virtual bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection) = 0 ;
	virtual Jclcontainerintf::_di_IJclAnsiStrIterator __fastcall First(void) = 0 ;
	virtual bool __fastcall IsEmpty(void) = 0 ;
	virtual Jclcontainerintf::_di_IJclAnsiStrIterator __fastcall Last(void) = 0 ;
	virtual bool __fastcall Remove(const System::AnsiString AString) = 0 ;
	virtual bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection) = 0 ;
	virtual bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection) = 0 ;
	virtual int __fastcall Size(void) = 0 ;
	virtual Jclcontainerintf::_di_IJclAnsiStrIterator __fastcall GetEnumerator(void) = 0 ;
	void __fastcall LoadFromStrings(Jclansistrings::TJclAnsiStrings* Strings);
	void __fastcall SaveToStrings(Jclansistrings::TJclAnsiStrings* Strings);
	void __fastcall AppendToStrings(Jclansistrings::TJclAnsiStrings* Strings);
	void __fastcall AppendFromStrings(Jclansistrings::TJclAnsiStrings* Strings);
	Jclansistrings::TJclAnsiStrings* __fastcall GetAsStrings(void);
	System::AnsiString __fastcall GetAsDelimited(const System::AnsiString Separator = "\r\n");
	void __fastcall AppendDelimited(const System::AnsiString AString, const System::AnsiString Separator = "\r\n");
	void __fastcall LoadDelimited(const System::AnsiString AString, const System::AnsiString Separator = "\r\n");
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclAnsiStrAbstractCollection(void) : TJclAnsiStrAbstractContainer() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAnsiStrAbstractCollection(void) { }
	
private:
	void *__IJclAnsiStrComparer;	/* Jclcontainerintf::IJclAnsiStrComparer */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclAnsiStrCollection;	/* Jclcontainerintf::IJclAnsiStrCollection */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrComparer()
	{
		Jclcontainerintf::_di_IJclAnsiStrComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrComparer*(void) { return (IJclAnsiStrComparer*)&__IJclAnsiStrComparer; }
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
	operator Jclcontainerintf::_di_IJclAnsiStrCollection()
	{
		Jclcontainerintf::_di_IJclAnsiStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrCollection*(void) { return (IJclAnsiStrCollection*)&__IJclAnsiStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrFlatContainer*(void) { return (IJclAnsiStrFlatContainer*)&__IJclAnsiStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrCollection; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrCollection; }
	#endif
	
};


class DELPHICLASS TJclWideStrAbstractCollection;
class PASCALIMPLEMENTATION TJclWideStrAbstractCollection : public TJclWideStrAbstractContainer
{
	typedef TJclWideStrAbstractContainer inherited;
	
public:
	virtual bool __fastcall Add(const System::WideString AString) = 0 ;
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall Contains(const System::WideString AString) = 0 ;
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection) = 0 ;
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclWideStrCollection ACollection) = 0 ;
	virtual bool __fastcall Extract(const System::WideString AString) = 0 ;
	virtual bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection) = 0 ;
	virtual Jclcontainerintf::_di_IJclWideStrIterator __fastcall First(void) = 0 ;
	virtual bool __fastcall IsEmpty(void) = 0 ;
	virtual Jclcontainerintf::_di_IJclWideStrIterator __fastcall Last(void) = 0 ;
	virtual bool __fastcall Remove(const System::WideString AString) = 0 ;
	virtual bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection) = 0 ;
	virtual bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection) = 0 ;
	virtual int __fastcall Size(void) = 0 ;
	virtual Jclcontainerintf::_di_IJclWideStrIterator __fastcall GetEnumerator(void) = 0 ;
	void __fastcall LoadFromStrings(Classes::TStrings* Strings);
	void __fastcall SaveToStrings(Classes::TStrings* Strings);
	void __fastcall AppendToStrings(Classes::TStrings* Strings);
	void __fastcall AppendFromStrings(Classes::TStrings* Strings);
	Classes::TStrings* __fastcall GetAsStrings(void);
	System::WideString __fastcall GetAsDelimited(const System::WideString Separator = L"\r\n");
	void __fastcall AppendDelimited(const System::WideString AString, const System::WideString Separator = L"\r\n");
	void __fastcall LoadDelimited(const System::WideString AString, const System::WideString Separator = L"\r\n");
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclWideStrAbstractCollection(void) : TJclWideStrAbstractContainer() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclWideStrAbstractCollection(void) { }
	
private:
	void *__IJclWideStrComparer;	/* Jclcontainerintf::IJclWideStrComparer */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclWideStrCollection;	/* Jclcontainerintf::IJclWideStrCollection */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrComparer()
	{
		Jclcontainerintf::_di_IJclWideStrComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrComparer*(void) { return (IJclWideStrComparer*)&__IJclWideStrComparer; }
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
	operator Jclcontainerintf::_di_IJclWideStrCollection()
	{
		Jclcontainerintf::_di_IJclWideStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrCollection*(void) { return (IJclWideStrCollection*)&__IJclWideStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclWideStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrFlatContainer*(void) { return (IJclWideStrFlatContainer*)&__IJclWideStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrCollection; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrCollection; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrAbstractCollection;
class PASCALIMPLEMENTATION TJclUnicodeStrAbstractCollection : public TJclUnicodeStrAbstractContainer
{
	typedef TJclUnicodeStrAbstractContainer inherited;
	
public:
	virtual bool __fastcall Add(const System::UnicodeString AString) = 0 ;
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection) = 0 ;
	virtual void __fastcall Clear(void) = 0 ;
	virtual bool __fastcall Contains(const System::UnicodeString AString) = 0 ;
	virtual bool __fastcall ContainsAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection) = 0 ;
	virtual bool __fastcall CollectionEquals(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection) = 0 ;
	virtual bool __fastcall Extract(const System::UnicodeString AString) = 0 ;
	virtual bool __fastcall ExtractAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection) = 0 ;
	virtual Jclcontainerintf::_di_IJclUnicodeStrIterator __fastcall First(void) = 0 ;
	virtual bool __fastcall IsEmpty(void) = 0 ;
	virtual Jclcontainerintf::_di_IJclUnicodeStrIterator __fastcall Last(void) = 0 ;
	virtual bool __fastcall Remove(const System::UnicodeString AString) = 0 ;
	virtual bool __fastcall RemoveAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection) = 0 ;
	virtual bool __fastcall RetainAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection) = 0 ;
	virtual int __fastcall Size(void) = 0 ;
	virtual Jclcontainerintf::_di_IJclUnicodeStrIterator __fastcall GetEnumerator(void) = 0 ;
	void __fastcall LoadFromStrings(Classes::TStrings* Strings);
	void __fastcall SaveToStrings(Classes::TStrings* Strings);
	void __fastcall AppendToStrings(Classes::TStrings* Strings);
	void __fastcall AppendFromStrings(Classes::TStrings* Strings);
	Classes::TStrings* __fastcall GetAsStrings(void);
	System::UnicodeString __fastcall GetAsDelimited(const System::UnicodeString Separator = L"\r\n");
	void __fastcall AppendDelimited(const System::UnicodeString AString, const System::UnicodeString Separator = L"\r\n");
	void __fastcall LoadDelimited(const System::UnicodeString AString, const System::UnicodeString Separator = L"\r\n");
public:
	/* TJclAbstractContainerBase.Create */ inline __fastcall TJclUnicodeStrAbstractCollection(void) : TJclUnicodeStrAbstractContainer() { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclUnicodeStrAbstractCollection(void) { }
	
private:
	void *__IJclUnicodeStrComparer;	/* Jclcontainerintf::IJclUnicodeStrComparer */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclUnicodeStrCollection;	/* Jclcontainerintf::IJclUnicodeStrCollection */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrComparer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrComparer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrComparer*(void) { return (IJclUnicodeStrComparer*)&__IJclUnicodeStrComparer; }
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
	operator Jclcontainerintf::_di_IJclUnicodeStrCollection()
	{
		Jclcontainerintf::_di_IJclUnicodeStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrCollection*(void) { return (IJclUnicodeStrCollection*)&__IJclUnicodeStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrFlatContainer*(void) { return (IJclUnicodeStrFlatContainer*)&__IJclUnicodeStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrCollection; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrCollection; }
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
	operator Jclcontainerintf::_di_IJclLockable()
	{
		Jclcontainerintf::_di_IJclLockable intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrCollection; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE StaticArray<System::Byte, 256> BytePermTable;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclabstractcontainers */
using namespace Jclabstractcontainers;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclabstractcontainersHPP
