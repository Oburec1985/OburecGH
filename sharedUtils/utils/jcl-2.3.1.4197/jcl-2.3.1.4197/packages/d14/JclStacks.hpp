// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclstacks.pas' rev: 21.00

#ifndef JclstacksHPP
#define JclstacksHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Generics.collections.hpp>	// Pascal unit
#include <Jclalgorithms.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclabstractcontainers.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclstacks
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclIntfStack;
class PASCALIMPLEMENTATION TJclIntfStack : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynIInterfaceArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfStack(int ACapacity);
	__fastcall virtual ~TJclIntfStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const System::_di_IInterface AInterface);
	bool __fastcall Empty(void);
	System::_di_IInterface __fastcall Peek(void);
	System::_di_IInterface __fastcall Pop(void);
	bool __fastcall Push(const System::_di_IInterface AInterface);
	int __fastcall Size(void);
private:
	void *__IJclIntfStack;	/* Jclcontainerintf::IJclIntfStack */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfStack()
	{
		Jclcontainerintf::_di_IJclIntfStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfStack*(void) { return (IJclIntfStack*)&__IJclIntfStack; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfStack; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrStack;
class PASCALIMPLEMENTATION TJclAnsiStrStack : public Jclabstractcontainers::TJclAnsiStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynAnsiStringArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrStack(int ACapacity);
	__fastcall virtual ~TJclAnsiStrStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const System::AnsiString AString);
	bool __fastcall Empty(void);
	System::AnsiString __fastcall Peek(void);
	System::AnsiString __fastcall Pop(void);
	bool __fastcall Push(const System::AnsiString AString);
	int __fastcall Size(void);
private:
	void *__IJclAnsiStrStack;	/* Jclcontainerintf::IJclAnsiStrStack */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrStack()
	{
		Jclcontainerintf::_di_IJclAnsiStrStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrStack*(void) { return (IJclAnsiStrStack*)&__IJclAnsiStrStack; }
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
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrStack; }
	#endif
	
};


class DELPHICLASS TJclWideStrStack;
class PASCALIMPLEMENTATION TJclWideStrStack : public Jclabstractcontainers::TJclWideStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclWideStrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynWideStringArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrStack(int ACapacity);
	__fastcall virtual ~TJclWideStrStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const System::WideString AString);
	bool __fastcall Empty(void);
	System::WideString __fastcall Peek(void);
	System::WideString __fastcall Pop(void);
	bool __fastcall Push(const System::WideString AString);
	int __fastcall Size(void);
private:
	void *__IJclWideStrStack;	/* Jclcontainerintf::IJclWideStrStack */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrStack()
	{
		Jclcontainerintf::_di_IJclWideStrStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrStack*(void) { return (IJclWideStrStack*)&__IJclWideStrStack; }
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
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrStack; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrStack;
class PASCALIMPLEMENTATION TJclUnicodeStrStack : public Jclabstractcontainers::TJclUnicodeStrAbstractContainer
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynUnicodeStringArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrStack(int ACapacity);
	__fastcall virtual ~TJclUnicodeStrStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const System::UnicodeString AString);
	bool __fastcall Empty(void);
	System::UnicodeString __fastcall Peek(void);
	System::UnicodeString __fastcall Pop(void);
	bool __fastcall Push(const System::UnicodeString AString);
	int __fastcall Size(void);
private:
	void *__IJclUnicodeStrStack;	/* Jclcontainerintf::IJclUnicodeStrStack */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrStack()
	{
		Jclcontainerintf::_di_IJclUnicodeStrStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrStack*(void) { return (IJclUnicodeStrStack*)&__IJclUnicodeStrStack; }
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
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrStack; }
	#endif
	
};


typedef TJclUnicodeStrStack TJclStrStack;

class DELPHICLASS TJclSingleStack;
class PASCALIMPLEMENTATION TJclSingleStack : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynSingleArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleStack(int ACapacity);
	__fastcall virtual ~TJclSingleStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const float AValue);
	bool __fastcall Empty(void);
	float __fastcall Peek(void);
	float __fastcall Pop(void);
	bool __fastcall Push(const float AValue);
	int __fastcall Size(void);
private:
	void *__IJclSingleStack;	/* Jclcontainerintf::IJclSingleStack */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleStack()
	{
		Jclcontainerintf::_di_IJclSingleStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleStack*(void) { return (IJclSingleStack*)&__IJclSingleStack; }
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
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleStack; }
	#endif
	
};


class DELPHICLASS TJclDoubleStack;
class PASCALIMPLEMENTATION TJclDoubleStack : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynDoubleArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleStack(int ACapacity);
	__fastcall virtual ~TJclDoubleStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const double AValue);
	bool __fastcall Empty(void);
	double __fastcall Peek(void);
	double __fastcall Pop(void);
	bool __fastcall Push(const double AValue);
	int __fastcall Size(void);
private:
	void *__IJclDoubleStack;	/* Jclcontainerintf::IJclDoubleStack */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleStack()
	{
		Jclcontainerintf::_di_IJclDoubleStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleStack*(void) { return (IJclDoubleStack*)&__IJclDoubleStack; }
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
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleStack; }
	#endif
	
};


class DELPHICLASS TJclExtendedStack;
class PASCALIMPLEMENTATION TJclExtendedStack : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynExtendedArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedStack(int ACapacity);
	__fastcall virtual ~TJclExtendedStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const System::Extended AValue);
	bool __fastcall Empty(void);
	System::Extended __fastcall Peek(void);
	System::Extended __fastcall Pop(void);
	bool __fastcall Push(const System::Extended AValue);
	int __fastcall Size(void);
private:
	void *__IJclExtendedStack;	/* Jclcontainerintf::IJclExtendedStack */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedStack()
	{
		Jclcontainerintf::_di_IJclExtendedStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedStack*(void) { return (IJclExtendedStack*)&__IJclExtendedStack; }
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
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedStack; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedStack; }
	#endif
	
};


typedef TJclExtendedStack TJclFloatStack;

class DELPHICLASS TJclIntegerStack;
class PASCALIMPLEMENTATION TJclIntegerStack : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynIntegerArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerStack(int ACapacity);
	__fastcall virtual ~TJclIntegerStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(int AValue);
	bool __fastcall Empty(void);
	int __fastcall Peek(void);
	int __fastcall Pop(void);
	bool __fastcall Push(int AValue);
	int __fastcall Size(void);
private:
	void *__IJclIntegerStack;	/* Jclcontainerintf::IJclIntegerStack */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerStack()
	{
		Jclcontainerintf::_di_IJclIntegerStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerStack*(void) { return (IJclIntegerStack*)&__IJclIntegerStack; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerStack; }
	#endif
	
};


class DELPHICLASS TJclCardinalStack;
class PASCALIMPLEMENTATION TJclCardinalStack : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynCardinalArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalStack(int ACapacity);
	__fastcall virtual ~TJclCardinalStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(unsigned AValue);
	bool __fastcall Empty(void);
	unsigned __fastcall Peek(void);
	unsigned __fastcall Pop(void);
	bool __fastcall Push(unsigned AValue);
	int __fastcall Size(void);
private:
	void *__IJclCardinalStack;	/* Jclcontainerintf::IJclCardinalStack */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalStack()
	{
		Jclcontainerintf::_di_IJclCardinalStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalStack*(void) { return (IJclCardinalStack*)&__IJclCardinalStack; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalStack; }
	#endif
	
};


class DELPHICLASS TJclInt64Stack;
class PASCALIMPLEMENTATION TJclInt64Stack : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynInt64Array FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64Stack(int ACapacity);
	__fastcall virtual ~TJclInt64Stack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const __int64 AValue);
	bool __fastcall Empty(void);
	__int64 __fastcall Peek(void);
	__int64 __fastcall Pop(void);
	bool __fastcall Push(const __int64 AValue);
	int __fastcall Size(void);
private:
	void *__IJclInt64Stack;	/* Jclcontainerintf::IJclInt64Stack */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Stack()
	{
		Jclcontainerintf::_di_IJclInt64Stack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Stack*(void) { return (IJclInt64Stack*)&__IJclInt64Stack; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Stack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Stack; }
	#endif
	
};


class DELPHICLASS TJclPtrStack;
class PASCALIMPLEMENTATION TJclPtrStack : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynPointerArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrStack(int ACapacity);
	__fastcall virtual ~TJclPtrStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(void * APtr);
	bool __fastcall Empty(void);
	void * __fastcall Peek(void);
	void * __fastcall Pop(void);
	bool __fastcall Push(void * APtr);
	int __fastcall Size(void);
private:
	void *__IJclPtrStack;	/* Jclcontainerintf::IJclPtrStack */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrStack()
	{
		Jclcontainerintf::_di_IJclPtrStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrStack*(void) { return (IJclPtrStack*)&__IJclPtrStack; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrStack; }
	#endif
	
};


class DELPHICLASS TJclStack;
class PASCALIMPLEMENTATION TJclStack : public Jclabstractcontainers::TJclAbstractContainer
{
	typedef Jclabstractcontainers::TJclAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	Jclbase::TDynObjectArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclStack(int ACapacity, bool AOwnsObjects);
	__fastcall virtual ~TJclStack(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(System::TObject* AObject);
	bool __fastcall Empty(void);
	System::TObject* __fastcall Peek(void);
	System::TObject* __fastcall Pop(void);
	bool __fastcall Push(System::TObject* AObject);
	int __fastcall Size(void);
private:
	void *__IJclStack;	/* Jclcontainerintf::IJclStack */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStack()
	{
		Jclcontainerintf::_di_IJclStack intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStack*(void) { return (IJclStack*)&__IJclStack; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclStack; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclStack; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclStack__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclStack__1 : public Jclabstractcontainers::TJclAbstractContainer__1<T>
{
	typedef Jclabstractcontainers::TJclAbstractContainer__1<T> inherited;
	
protected:
	typedef DynamicArray<T> TDynArray;
	
	
private:
	TDynArray FElements;
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclStack__1(int ACapacity, bool AOwnsItems);
	__fastcall virtual ~TJclStack__1(void);
	virtual void __fastcall SetCapacity(int Value);
	void __fastcall Clear(void);
	bool __fastcall Contains(const T AItem);
	bool __fastcall Empty(void);
	T __fastcall Peek(void);
	T __fastcall Pop(void);
	bool __fastcall Push(const T AItem);
	int __fastcall Size(void);
private:
	void *__IJclStack__1;	/* Jclcontainerintf::IJclStack__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStack__1<T>*(void) { return (IJclStack__1<T>*)&__IJclStack__1; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclStack__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclStack__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclStackE__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclStackE__1 : public TJclStack__1<T>
{
	typedef TJclStack__1<T> inherited;
	
private:
	System::DelphiInterface<Jclbase::IEqualityComparer__1<T> >  FEqualityComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclStackE__1(const System::DelphiInterface<Jclbase::IEqualityComparer__1<T> >  AEqualityComparer, int ACapacity, bool AOwnsItems);
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property System::DelphiInterface<Jclbase::IEqualityComparer__1<T> >  EqualityComparer = {read=FEqualityComparer, write=FEqualityComparer};
public:
	/* TJclStack<T>.Destroy */ inline __fastcall virtual ~TJclStackE__1(void) { }
	
private:
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclStack__1;	/* Jclcontainerintf::IJclStack__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStack__1<T>*(void) { return (IJclStack__1<T>*)&__IJclStack__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclStack__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclStack__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclStackF__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclStackF__1 : public TJclStack__1<T>
{
	typedef TJclStack__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclStackF__1(_decl_TEqualityCompare__1(T, AEqualityCompare), int ACapacity, bool AOwnsItems);
public:
	/* TJclStack<T>.Destroy */ inline __fastcall virtual ~TJclStackF__1(void) { }
	
private:
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclStack__1;	/* Jclcontainerintf::IJclStack__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStack__1<T>*(void) { return (IJclStack__1<T>*)&__IJclStack__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclStack__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclStack__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclStackI__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclStackI__1 : public TJclStack__1<T>
{
	typedef TJclStack__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	virtual bool __fastcall ItemsEqual(const T A, const T B);
public:
	/* TJclStack<T>.Create */ inline __fastcall TJclStackI__1(int ACapacity, bool AOwnsItems) : TJclStack__1<T>(ACapacity, AOwnsItems) { }
	/* TJclStack<T>.Destroy */ inline __fastcall virtual ~TJclStackI__1(void) { }
	
private:
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclStack__1;	/* Jclcontainerintf::IJclStack__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclStack__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStack__1<T>*(void) { return (IJclStack__1<T>*)&__IJclStack__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclStack__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclStack__1; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclstacks */
using namespace Jclstacks;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclstacksHPP
