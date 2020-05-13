// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclarraysets.pas' rev: 21.00

#ifndef JclarraysetsHPP
#define JclarraysetsHPP

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
#include <Jclarraylists.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclarraysets
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclIntfArraySet;
class PASCALIMPLEMENTATION TJclIntfArraySet : public Jclarraylists::TJclIntfArrayList
{
	typedef Jclarraylists::TJclIntfArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const System::_di_IInterface AInterface);
	
public:
	HIDESBASE bool __fastcall Add(const System::_di_IInterface AInterface);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	HIDESBASE bool __fastcall Contains(const System::_di_IInterface AInterface);
	HIDESBASE bool __fastcall Insert(int Index, const System::_di_IInterface AInterface);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclIntfCollection ACollection);
public:
	/* TJclIntfArrayList.Create */ inline __fastcall TJclIntfArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclIntfArrayList(ACapacity) { }
	/* TJclIntfArrayList.Destroy */ inline __fastcall virtual ~TJclIntfArraySet(void) { }
	
private:
	void *__IJclIntfSet;	/* Jclcontainerintf::IJclIntfSet */
	void *__IJclIntfArray;	/* Jclcontainerintf::IJclIntfArray */
	void *__IJclIntfComparer;	/* Jclcontainerintf::IJclIntfComparer */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclIntfCollection*(void) { return (IJclIntfCollection*)&__IJclIntfSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfSet; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrArraySet;
class PASCALIMPLEMENTATION TJclAnsiStrArraySet : public Jclarraylists::TJclAnsiStrArrayList
{
	typedef Jclarraylists::TJclAnsiStrArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const System::AnsiString AString);
	
public:
	virtual bool __fastcall Add(const System::AnsiString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	virtual bool __fastcall Contains(const System::AnsiString AString);
	HIDESBASE bool __fastcall Insert(int Index, const System::AnsiString AString);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclAnsiStrCollection ACollection);
public:
	/* TJclAnsiStrArrayList.Create */ inline __fastcall TJclAnsiStrArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclAnsiStrArrayList(ACapacity) { }
	/* TJclAnsiStrArrayList.Destroy */ inline __fastcall virtual ~TJclAnsiStrArraySet(void) { }
	
private:
	void *__IJclAnsiStrSet;	/* Jclcontainerintf::IJclAnsiStrSet */
	void *__IJclAnsiStrArray;	/* Jclcontainerintf::IJclAnsiStrArray */
	void *__IJclAnsiStrComparer;	/* Jclcontainerintf::IJclAnsiStrComparer */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclAnsiStrCollection*(void) { return (IJclAnsiStrCollection*)&__IJclAnsiStrSet; }
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
	operator Jclcontainerintf::_di_IJclAnsiStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrFlatContainer*(void) { return (IJclAnsiStrFlatContainer*)&__IJclAnsiStrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrSet; }
	#endif
	
};


class DELPHICLASS TJclWideStrArraySet;
class PASCALIMPLEMENTATION TJclWideStrArraySet : public Jclarraylists::TJclWideStrArrayList
{
	typedef Jclarraylists::TJclWideStrArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const System::WideString AString);
	
public:
	virtual bool __fastcall Add(const System::WideString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	virtual bool __fastcall Contains(const System::WideString AString);
	HIDESBASE bool __fastcall Insert(int Index, const System::WideString AString);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclWideStrCollection ACollection);
public:
	/* TJclWideStrArrayList.Create */ inline __fastcall TJclWideStrArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclWideStrArrayList(ACapacity) { }
	/* TJclWideStrArrayList.Destroy */ inline __fastcall virtual ~TJclWideStrArraySet(void) { }
	
private:
	void *__IJclWideStrSet;	/* Jclcontainerintf::IJclWideStrSet */
	void *__IJclWideStrArray;	/* Jclcontainerintf::IJclWideStrArray */
	void *__IJclWideStrComparer;	/* Jclcontainerintf::IJclWideStrComparer */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclWideStrCollection*(void) { return (IJclWideStrCollection*)&__IJclWideStrSet; }
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
	operator Jclcontainerintf::_di_IJclWideStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclWideStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrFlatContainer*(void) { return (IJclWideStrFlatContainer*)&__IJclWideStrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrSet; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrArraySet;
class PASCALIMPLEMENTATION TJclUnicodeStrArraySet : public Jclarraylists::TJclUnicodeStrArrayList
{
	typedef Jclarraylists::TJclUnicodeStrArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const System::UnicodeString AString);
	
public:
	virtual bool __fastcall Add(const System::UnicodeString AString);
	virtual bool __fastcall AddAll(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	virtual bool __fastcall Contains(const System::UnicodeString AString);
	HIDESBASE bool __fastcall Insert(int Index, const System::UnicodeString AString);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclUnicodeStrCollection ACollection);
public:
	/* TJclUnicodeStrArrayList.Create */ inline __fastcall TJclUnicodeStrArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclUnicodeStrArrayList(ACapacity) { }
	/* TJclUnicodeStrArrayList.Destroy */ inline __fastcall virtual ~TJclUnicodeStrArraySet(void) { }
	
private:
	void *__IJclUnicodeStrSet;	/* Jclcontainerintf::IJclUnicodeStrSet */
	void *__IJclUnicodeStrArray;	/* Jclcontainerintf::IJclUnicodeStrArray */
	void *__IJclUnicodeStrComparer;	/* Jclcontainerintf::IJclUnicodeStrComparer */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclUnicodeStrCollection*(void) { return (IJclUnicodeStrCollection*)&__IJclUnicodeStrSet; }
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
	operator Jclcontainerintf::_di_IJclUnicodeStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrFlatContainer*(void) { return (IJclUnicodeStrFlatContainer*)&__IJclUnicodeStrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrSet; }
	#endif
	
};


typedef TJclUnicodeStrArraySet TJclStrArraySet;

class DELPHICLASS TJclSingleArraySet;
class PASCALIMPLEMENTATION TJclSingleArraySet : public Jclarraylists::TJclSingleArrayList
{
	typedef Jclarraylists::TJclSingleArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const float AValue);
	
public:
	HIDESBASE bool __fastcall Add(const float AValue);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	HIDESBASE bool __fastcall Contains(const float AValue);
	HIDESBASE bool __fastcall Insert(int Index, const float AValue);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclSingleCollection ACollection);
public:
	/* TJclSingleArrayList.Create */ inline __fastcall TJclSingleArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclSingleArrayList(ACapacity) { }
	/* TJclSingleArrayList.Destroy */ inline __fastcall virtual ~TJclSingleArraySet(void) { }
	
private:
	void *__IJclSingleSet;	/* Jclcontainerintf::IJclSingleSet */
	void *__IJclSingleArray;	/* Jclcontainerintf::IJclSingleArray */
	void *__IJclSingleComparer;	/* Jclcontainerintf::IJclSingleComparer */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclSingleCollection*(void) { return (IJclSingleCollection*)&__IJclSingleSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleSet; }
	#endif
	
};


class DELPHICLASS TJclDoubleArraySet;
class PASCALIMPLEMENTATION TJclDoubleArraySet : public Jclarraylists::TJclDoubleArrayList
{
	typedef Jclarraylists::TJclDoubleArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const double AValue);
	
public:
	HIDESBASE bool __fastcall Add(const double AValue);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	HIDESBASE bool __fastcall Contains(const double AValue);
	HIDESBASE bool __fastcall Insert(int Index, const double AValue);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclDoubleCollection ACollection);
public:
	/* TJclDoubleArrayList.Create */ inline __fastcall TJclDoubleArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclDoubleArrayList(ACapacity) { }
	/* TJclDoubleArrayList.Destroy */ inline __fastcall virtual ~TJclDoubleArraySet(void) { }
	
private:
	void *__IJclDoubleSet;	/* Jclcontainerintf::IJclDoubleSet */
	void *__IJclDoubleArray;	/* Jclcontainerintf::IJclDoubleArray */
	void *__IJclDoubleComparer;	/* Jclcontainerintf::IJclDoubleComparer */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclDoubleCollection*(void) { return (IJclDoubleCollection*)&__IJclDoubleSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleSet; }
	#endif
	
};


class DELPHICLASS TJclExtendedArraySet;
class PASCALIMPLEMENTATION TJclExtendedArraySet : public Jclarraylists::TJclExtendedArrayList
{
	typedef Jclarraylists::TJclExtendedArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const System::Extended AValue);
	
public:
	HIDESBASE bool __fastcall Add(const System::Extended AValue);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	HIDESBASE bool __fastcall Contains(const System::Extended AValue);
	HIDESBASE bool __fastcall Insert(int Index, const System::Extended AValue);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclExtendedCollection ACollection);
public:
	/* TJclExtendedArrayList.Create */ inline __fastcall TJclExtendedArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclExtendedArrayList(ACapacity) { }
	/* TJclExtendedArrayList.Destroy */ inline __fastcall virtual ~TJclExtendedArraySet(void) { }
	
private:
	void *__IJclExtendedSet;	/* Jclcontainerintf::IJclExtendedSet */
	void *__IJclExtendedArray;	/* Jclcontainerintf::IJclExtendedArray */
	void *__IJclExtendedComparer;	/* Jclcontainerintf::IJclExtendedComparer */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclExtendedCollection*(void) { return (IJclExtendedCollection*)&__IJclExtendedSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedSet; }
	#endif
	
};


typedef TJclExtendedArraySet TJclFloatArraySet;

class DELPHICLASS TJclIntegerArraySet;
class PASCALIMPLEMENTATION TJclIntegerArraySet : public Jclarraylists::TJclIntegerArrayList
{
	typedef Jclarraylists::TJclIntegerArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(int AValue);
	
public:
	HIDESBASE bool __fastcall Add(int AValue);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	HIDESBASE bool __fastcall Contains(int AValue);
	HIDESBASE bool __fastcall Insert(int Index, int AValue);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclIntegerCollection ACollection);
public:
	/* TJclIntegerArrayList.Create */ inline __fastcall TJclIntegerArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclIntegerArrayList(ACapacity) { }
	/* TJclIntegerArrayList.Destroy */ inline __fastcall virtual ~TJclIntegerArraySet(void) { }
	
private:
	void *__IJclIntegerSet;	/* Jclcontainerintf::IJclIntegerSet */
	void *__IJclIntegerArray;	/* Jclcontainerintf::IJclIntegerArray */
	void *__IJclIntegerComparer;	/* Jclcontainerintf::IJclIntegerComparer */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclIntegerCollection*(void) { return (IJclIntegerCollection*)&__IJclIntegerSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerSet; }
	#endif
	
};


class DELPHICLASS TJclCardinalArraySet;
class PASCALIMPLEMENTATION TJclCardinalArraySet : public Jclarraylists::TJclCardinalArrayList
{
	typedef Jclarraylists::TJclCardinalArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(unsigned AValue);
	
public:
	HIDESBASE bool __fastcall Add(unsigned AValue);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	HIDESBASE bool __fastcall Contains(unsigned AValue);
	HIDESBASE bool __fastcall Insert(int Index, unsigned AValue);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclCardinalCollection ACollection);
public:
	/* TJclCardinalArrayList.Create */ inline __fastcall TJclCardinalArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclCardinalArrayList(ACapacity) { }
	/* TJclCardinalArrayList.Destroy */ inline __fastcall virtual ~TJclCardinalArraySet(void) { }
	
private:
	void *__IJclCardinalSet;	/* Jclcontainerintf::IJclCardinalSet */
	void *__IJclCardinalArray;	/* Jclcontainerintf::IJclCardinalArray */
	void *__IJclCardinalComparer;	/* Jclcontainerintf::IJclCardinalComparer */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclCardinalCollection*(void) { return (IJclCardinalCollection*)&__IJclCardinalSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalSet; }
	#endif
	
};


class DELPHICLASS TJclInt64ArraySet;
class PASCALIMPLEMENTATION TJclInt64ArraySet : public Jclarraylists::TJclInt64ArrayList
{
	typedef Jclarraylists::TJclInt64ArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(const __int64 AValue);
	
public:
	HIDESBASE bool __fastcall Add(const __int64 AValue);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	HIDESBASE bool __fastcall Contains(const __int64 AValue);
	HIDESBASE bool __fastcall Insert(int Index, const __int64 AValue);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclInt64Collection ACollection);
public:
	/* TJclInt64ArrayList.Create */ inline __fastcall TJclInt64ArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclInt64ArrayList(ACapacity) { }
	/* TJclInt64ArrayList.Destroy */ inline __fastcall virtual ~TJclInt64ArraySet(void) { }
	
private:
	void *__IJclInt64Set;	/* Jclcontainerintf::IJclInt64Set */
	void *__IJclInt64Array;	/* Jclcontainerintf::IJclInt64Array */
	void *__IJclInt64Comparer;	/* Jclcontainerintf::IJclInt64Comparer */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclInt64Collection*(void) { return (IJclInt64Collection*)&__IJclInt64Set; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Set; }
	#endif
	
};


class DELPHICLASS TJclPtrArraySet;
class PASCALIMPLEMENTATION TJclPtrArraySet : public Jclarraylists::TJclPtrArrayList
{
	typedef Jclarraylists::TJclPtrArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(void * APtr);
	
public:
	HIDESBASE bool __fastcall Add(void * APtr);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	HIDESBASE bool __fastcall Contains(void * APtr);
	HIDESBASE bool __fastcall Insert(int Index, void * APtr);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclPtrCollection ACollection);
public:
	/* TJclPtrArrayList.Create */ inline __fastcall TJclPtrArraySet(int ACapacity)/* overload */ : Jclarraylists::TJclPtrArrayList(ACapacity) { }
	/* TJclPtrArrayList.Destroy */ inline __fastcall virtual ~TJclPtrArraySet(void) { }
	
private:
	void *__IJclPtrSet;	/* Jclcontainerintf::IJclPtrSet */
	void *__IJclPtrArray;	/* Jclcontainerintf::IJclPtrArray */
	void *__IJclPtrComparer;	/* Jclcontainerintf::IJclPtrComparer */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclPtrCollection*(void) { return (IJclPtrCollection*)&__IJclPtrSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrSet; }
	#endif
	
};


class DELPHICLASS TJclArraySet;
class PASCALIMPLEMENTATION TJclArraySet : public Jclarraylists::TJclArrayList
{
	typedef Jclarraylists::TJclArrayList inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int __fastcall BinarySearch(System::TObject* AObject);
	
public:
	HIDESBASE bool __fastcall Add(System::TObject* AObject);
	HIDESBASE bool __fastcall AddAll(const Jclcontainerintf::_di_IJclCollection ACollection);
	HIDESBASE bool __fastcall Contains(System::TObject* AObject);
	HIDESBASE bool __fastcall Insert(int Index, System::TObject* AObject);
	void __fastcall Intersect(const Jclcontainerintf::_di_IJclCollection ACollection);
	void __fastcall Subtract(const Jclcontainerintf::_di_IJclCollection ACollection);
	void __fastcall Union(const Jclcontainerintf::_di_IJclCollection ACollection);
public:
	/* TJclArrayList.Create */ inline __fastcall TJclArraySet(int ACapacity, bool AOwnsObjects)/* overload */ : Jclarraylists::TJclArrayList(ACapacity, AOwnsObjects) { }
	/* TJclArrayList.Destroy */ inline __fastcall virtual ~TJclArraySet(void) { }
	
private:
	void *__IJclSet;	/* Jclcontainerintf::IJclSet */
	void *__IJclArray;	/* Jclcontainerintf::IJclArray */
	void *__IJclComparer;	/* Jclcontainerintf::IJclComparer */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclCollection*(void) { return (IJclCollection*)&__IJclSet; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArraySet__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArraySet__1 : public Jclarraylists::TJclArrayList__1<T>
{
	typedef Jclarraylists::TJclArrayList__1<T> inherited;
	
private:
	int __fastcall BinarySearch(const T AItem);
	
public:
	HIDESBASE bool __fastcall Add(const T AItem);
	HIDESBASE bool __fastcall AddAll(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	HIDESBASE bool __fastcall Contains(const T AItem);
	HIDESBASE bool __fastcall Insert(int Index, const T AItem);
	void __fastcall Intersect(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	void __fastcall Subtract(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
	void __fastcall Union(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection);
public:
	/* TJclArrayList<T>.Create */ inline __fastcall TJclArraySet__1(int ACapacity, bool AOwnsItems)/* overload */ : Jclarraylists::TJclArrayList__1<T>(ACapacity, AOwnsItems) { }
	/* TJclArrayList<T>.Destroy */ inline __fastcall virtual ~TJclArraySet__1(void) { }
	
private:
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArraySetE__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArraySetE__1 : public TJclArraySet__1<T>
{
	typedef TJclArraySet__1<T> inherited;
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  FComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclArraySetE__1(const System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  AComparer, int ACapacity, bool AOwnsItems)/* overload */;
	__fastcall TJclArraySetE__1(const System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  AComparer, const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems)/* overload */;
	virtual int __fastcall ItemsCompare(const T A, const T B);
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  Comparer = {read=FComparer, write=FComparer};
public:
	/* TJclArrayList<T>.Destroy */ inline __fastcall virtual ~TJclArraySetE__1(void) { }
	
private:
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArraySetF__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArraySetF__1 : public TJclArraySet__1<T>
{
	typedef TJclArraySet__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclArraySetF__1(const _decl_TCompare__1(T, ACompare), int ACapacity, bool AOwnsItems)/* overload */;
	__fastcall TJclArraySetF__1(const _decl_TCompare__1(T, ACompare), const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  ACollection, bool AOwnsItems)/* overload */;
public:
	/* TJclArrayList<T>.Destroy */ inline __fastcall virtual ~TJclArraySetF__1(void) { }
	
private:
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclArraySetI__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclArraySetI__1 : public TJclArraySet__1<T>
{
	typedef TJclArraySet__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	virtual int __fastcall ItemsCompare(const T A, const T B);
	virtual bool __fastcall ItemsEqual(const T A, const T B);
public:
	/* TJclArrayList<T>.Create */ inline __fastcall TJclArraySetI__1(int ACapacity, bool AOwnsItems)/* overload */ : TJclArraySet__1<T>(ACapacity, AOwnsItems) { }
	/* TJclArrayList<T>.Destroy */ inline __fastcall virtual ~TJclArraySetI__1(void) { }
	
private:
	void *__IJclSet__1;	/* Jclcontainerintf::IJclSet__1<T> */
	void *__IJclArray__1;	/* Jclcontainerintf::IJclArray__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
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
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclSet__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSet__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSet__1; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclarraysets */
using namespace Jclarraysets;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclarraysetsHPP
