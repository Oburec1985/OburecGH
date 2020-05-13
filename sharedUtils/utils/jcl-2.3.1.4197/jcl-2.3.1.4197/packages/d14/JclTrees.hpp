// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcltrees.pas' rev: 21.00

#ifndef JcltreesHPP
#define JcltreesHPP

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

namespace Jcltrees
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TItrStart { isFirst, isLast, isRoot };
#pragma option pop

class DELPHICLASS TJclIntfTreeNode;
class PASCALIMPLEMENTATION TJclIntfTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::_di_IInterface Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclIntfTreeNode* Parent;
	int __fastcall IndexOfChild(TJclIntfTreeNode* AChild);
	int __fastcall IndexOfValue(const System::_di_IInterface AInterface, const Jclcontainerintf::_di_IJclIntfEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclIntfTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfTreeNode(void) { }
	
};


class DELPHICLASS TJclIntfTree;
class PASCALIMPLEMENTATION TJclIntfTree : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclIntfTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclIntfTreeNode* &ANode);
	void __fastcall RemoveNode(TJclIntfTreeNode* &ANode);
	TJclIntfTreeNode* __fastcall CloneNode(TJclIntfTreeNode* Node, TJclIntfTreeNode* Parent);
	bool __fastcall NodeContains(TJclIntfTreeNode* ANode, const System::_di_IInterface AInterface);
	void __fastcall PackNode(TJclIntfTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntfTree(void);
	__fastcall virtual ~TJclIntfTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclIntfTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclIntfTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclIntfTree;	/* Jclcontainerintf::IJclIntfTree */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTree()
	{
		Jclcontainerintf::_di_IJclIntfTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTree*(void) { return (IJclIntfTree*)&__IJclIntfTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfCollection()
	{
		Jclcontainerintf::_di_IJclIntfCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfCollection*(void) { return (IJclIntfCollection*)&__IJclIntfTree; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfTree; }
	#endif
	
};


class DELPHICLASS TJclIntfTreeIterator;
class PASCALIMPLEMENTATION TJclIntfTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclIntfTreeNode* FCursor;
	TItrStart FStart;
	TJclIntfTree* FOwnTree;
	Jclcontainerintf::_di_IJclIntfEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclIntfTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclIntfTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclIntfTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclIntfTreeIterator(TJclIntfTree* OwnTree, TJclIntfTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const System::_di_IInterface AInterface);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	System::_di_IInterface __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const System::_di_IInterface AInterface);
	bool __fastcall InsertChild(int Index, const System::_di_IInterface AInterface);
	System::_di_IInterface __fastcall Parent(void);
	void __fastcall SetChild(int Index, const System::_di_IInterface AInterface);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntfTreeIterator(void) { }
	
private:
	void *__IJclIntfTreeIterator;	/* Jclcontainerintf::IJclIntfTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTreeIterator*(void) { return (IJclIntfTreeIterator*)&__IJclIntfTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderIntfTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderIntfTreeIterator : public TJclIntfTreeIterator
{
	typedef TJclIntfTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntfTreeNode* __fastcall GetNextCursor(void);
	virtual TJclIntfTreeNode* __fastcall GetNextSibling(void);
	virtual TJclIntfTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntfTreeIterator.Create */ inline __fastcall TJclPreOrderIntfTreeIterator(TJclIntfTree* OwnTree, TJclIntfTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclIntfTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderIntfTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntfTreeIterator;	/* Jclcontainerintf::IJclIntfTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTreeIterator*(void) { return (IJclIntfTreeIterator*)&__IJclIntfTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderIntfTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderIntfTreeIterator : public TJclIntfTreeIterator
{
	typedef TJclIntfTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntfTreeNode* __fastcall GetNextCursor(void);
	virtual TJclIntfTreeNode* __fastcall GetNextSibling(void);
	virtual TJclIntfTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntfTreeIterator.Create */ inline __fastcall TJclPostOrderIntfTreeIterator(TJclIntfTree* OwnTree, TJclIntfTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclIntfTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderIntfTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntfTreeIterator;	/* Jclcontainerintf::IJclIntfTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTreeIterator*(void) { return (IJclIntfTreeIterator*)&__IJclIntfTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrTreeNode;
class PASCALIMPLEMENTATION TJclAnsiStrTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::AnsiString Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclAnsiStrTreeNode* Parent;
	int __fastcall IndexOfChild(TJclAnsiStrTreeNode* AChild);
	int __fastcall IndexOfValue(const System::AnsiString AString, const Jclcontainerintf::_di_IJclAnsiStrEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclAnsiStrTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAnsiStrTreeNode(void) { }
	
};


class DELPHICLASS TJclAnsiStrTree;
class PASCALIMPLEMENTATION TJclAnsiStrTree : public Jclabstractcontainers::TJclAnsiStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclAnsiStrTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclAnsiStrTreeNode* &ANode);
	void __fastcall RemoveNode(TJclAnsiStrTreeNode* &ANode);
	TJclAnsiStrTreeNode* __fastcall CloneNode(TJclAnsiStrTreeNode* Node, TJclAnsiStrTreeNode* Parent);
	bool __fastcall NodeContains(TJclAnsiStrTreeNode* ANode, const System::AnsiString AString);
	void __fastcall PackNode(TJclAnsiStrTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclAnsiStrTree(void);
	__fastcall virtual ~TJclAnsiStrTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclAnsiStrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclAnsiStrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclAnsiStrTree;	/* Jclcontainerintf::IJclAnsiStrTree */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTree()
	{
		Jclcontainerintf::_di_IJclAnsiStrTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTree*(void) { return (IJclAnsiStrTree*)&__IJclAnsiStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrCollection()
	{
		Jclcontainerintf::_di_IJclAnsiStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrCollection*(void) { return (IJclAnsiStrCollection*)&__IJclAnsiStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrFlatContainer*(void) { return (IJclAnsiStrFlatContainer*)&__IJclAnsiStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrContainer()
	{
		Jclcontainerintf::_di_IJclAnsiStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrContainer*(void) { return (IJclAnsiStrContainer*)&__IJclAnsiStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclAnsiStrTree; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclAnsiStrTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrTree; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrTreeIterator;
class PASCALIMPLEMENTATION TJclAnsiStrTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclAnsiStrTreeNode* FCursor;
	TItrStart FStart;
	TJclAnsiStrTree* FOwnTree;
	Jclcontainerintf::_di_IJclAnsiStrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclAnsiStrTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclAnsiStrTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclAnsiStrTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclAnsiStrTreeIterator(TJclAnsiStrTree* OwnTree, TJclAnsiStrTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const System::AnsiString AString);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	System::AnsiString __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const System::AnsiString AString);
	bool __fastcall InsertChild(int Index, const System::AnsiString AString);
	System::AnsiString __fastcall Parent(void);
	void __fastcall SetChild(int Index, const System::AnsiString AString);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAnsiStrTreeIterator(void) { }
	
private:
	void *__IJclAnsiStrTreeIterator;	/* Jclcontainerintf::IJclAnsiStrTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTreeIterator*(void) { return (IJclAnsiStrTreeIterator*)&__IJclAnsiStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderAnsiStrTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderAnsiStrTreeIterator : public TJclAnsiStrTreeIterator
{
	typedef TJclAnsiStrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclAnsiStrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclAnsiStrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclAnsiStrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclAnsiStrTreeIterator.Create */ inline __fastcall TJclPreOrderAnsiStrTreeIterator(TJclAnsiStrTree* OwnTree, TJclAnsiStrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclAnsiStrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderAnsiStrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclAnsiStrTreeIterator;	/* Jclcontainerintf::IJclAnsiStrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTreeIterator*(void) { return (IJclAnsiStrTreeIterator*)&__IJclAnsiStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderAnsiStrTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderAnsiStrTreeIterator : public TJclAnsiStrTreeIterator
{
	typedef TJclAnsiStrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclAnsiStrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclAnsiStrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclAnsiStrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclAnsiStrTreeIterator.Create */ inline __fastcall TJclPostOrderAnsiStrTreeIterator(TJclAnsiStrTree* OwnTree, TJclAnsiStrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclAnsiStrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderAnsiStrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclAnsiStrTreeIterator;	/* Jclcontainerintf::IJclAnsiStrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTreeIterator*(void) { return (IJclAnsiStrTreeIterator*)&__IJclAnsiStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclWideStrTreeNode;
class PASCALIMPLEMENTATION TJclWideStrTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::WideString Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclWideStrTreeNode* Parent;
	int __fastcall IndexOfChild(TJclWideStrTreeNode* AChild);
	int __fastcall IndexOfValue(const System::WideString AString, const Jclcontainerintf::_di_IJclWideStrEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclWideStrTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclWideStrTreeNode(void) { }
	
};


class DELPHICLASS TJclWideStrTree;
class PASCALIMPLEMENTATION TJclWideStrTree : public Jclabstractcontainers::TJclWideStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclWideStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclWideStrTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclWideStrTreeNode* &ANode);
	void __fastcall RemoveNode(TJclWideStrTreeNode* &ANode);
	TJclWideStrTreeNode* __fastcall CloneNode(TJclWideStrTreeNode* Node, TJclWideStrTreeNode* Parent);
	bool __fastcall NodeContains(TJclWideStrTreeNode* ANode, const System::WideString AString);
	void __fastcall PackNode(TJclWideStrTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclWideStrTree(void);
	__fastcall virtual ~TJclWideStrTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclWideStrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclWideStrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclWideStrTree;	/* Jclcontainerintf::IJclWideStrTree */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTree()
	{
		Jclcontainerintf::_di_IJclWideStrTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTree*(void) { return (IJclWideStrTree*)&__IJclWideStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrCollection()
	{
		Jclcontainerintf::_di_IJclWideStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrCollection*(void) { return (IJclWideStrCollection*)&__IJclWideStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclWideStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrFlatContainer*(void) { return (IJclWideStrFlatContainer*)&__IJclWideStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrContainer()
	{
		Jclcontainerintf::_di_IJclWideStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrContainer*(void) { return (IJclWideStrContainer*)&__IJclWideStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclWideStrTree; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclWideStrTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrTree; }
	#endif
	
};


class DELPHICLASS TJclWideStrTreeIterator;
class PASCALIMPLEMENTATION TJclWideStrTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclWideStrTreeNode* FCursor;
	TItrStart FStart;
	TJclWideStrTree* FOwnTree;
	Jclcontainerintf::_di_IJclWideStrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclWideStrTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclWideStrTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclWideStrTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclWideStrTreeIterator(TJclWideStrTree* OwnTree, TJclWideStrTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const System::WideString AString);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	System::WideString __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const System::WideString AString);
	bool __fastcall InsertChild(int Index, const System::WideString AString);
	System::WideString __fastcall Parent(void);
	void __fastcall SetChild(int Index, const System::WideString AString);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclWideStrTreeIterator(void) { }
	
private:
	void *__IJclWideStrTreeIterator;	/* Jclcontainerintf::IJclWideStrTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTreeIterator*(void) { return (IJclWideStrTreeIterator*)&__IJclWideStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderWideStrTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderWideStrTreeIterator : public TJclWideStrTreeIterator
{
	typedef TJclWideStrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclWideStrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclWideStrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclWideStrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclWideStrTreeIterator.Create */ inline __fastcall TJclPreOrderWideStrTreeIterator(TJclWideStrTree* OwnTree, TJclWideStrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclWideStrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderWideStrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclWideStrTreeIterator;	/* Jclcontainerintf::IJclWideStrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTreeIterator*(void) { return (IJclWideStrTreeIterator*)&__IJclWideStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderWideStrTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderWideStrTreeIterator : public TJclWideStrTreeIterator
{
	typedef TJclWideStrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclWideStrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclWideStrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclWideStrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclWideStrTreeIterator.Create */ inline __fastcall TJclPostOrderWideStrTreeIterator(TJclWideStrTree* OwnTree, TJclWideStrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclWideStrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderWideStrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclWideStrTreeIterator;	/* Jclcontainerintf::IJclWideStrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTreeIterator*(void) { return (IJclWideStrTreeIterator*)&__IJclWideStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrTreeNode;
class PASCALIMPLEMENTATION TJclUnicodeStrTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::UnicodeString Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclUnicodeStrTreeNode* Parent;
	int __fastcall IndexOfChild(TJclUnicodeStrTreeNode* AChild);
	int __fastcall IndexOfValue(const System::UnicodeString AString, const Jclcontainerintf::_di_IJclUnicodeStrEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclUnicodeStrTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclUnicodeStrTreeNode(void) { }
	
};


class DELPHICLASS TJclUnicodeStrTree;
class PASCALIMPLEMENTATION TJclUnicodeStrTree : public Jclabstractcontainers::TJclUnicodeStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclUnicodeStrTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclUnicodeStrTreeNode* &ANode);
	void __fastcall RemoveNode(TJclUnicodeStrTreeNode* &ANode);
	TJclUnicodeStrTreeNode* __fastcall CloneNode(TJclUnicodeStrTreeNode* Node, TJclUnicodeStrTreeNode* Parent);
	bool __fastcall NodeContains(TJclUnicodeStrTreeNode* ANode, const System::UnicodeString AString);
	void __fastcall PackNode(TJclUnicodeStrTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclUnicodeStrTree(void);
	__fastcall virtual ~TJclUnicodeStrTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclUnicodeStrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclUnicodeStrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclUnicodeStrTree;	/* Jclcontainerintf::IJclUnicodeStrTree */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTree()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTree*(void) { return (IJclUnicodeStrTree*)&__IJclUnicodeStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrCollection()
	{
		Jclcontainerintf::_di_IJclUnicodeStrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrCollection*(void) { return (IJclUnicodeStrCollection*)&__IJclUnicodeStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrFlatContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrFlatContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrFlatContainer*(void) { return (IJclUnicodeStrFlatContainer*)&__IJclUnicodeStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrContainer()
	{
		Jclcontainerintf::_di_IJclUnicodeStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrContainer*(void) { return (IJclUnicodeStrContainer*)&__IJclUnicodeStrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclStrContainer()
	{
		Jclcontainerintf::_di_IJclStrContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclStrContainer*(void) { return (IJclStrContainer*)&__IJclUnicodeStrTree; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclUnicodeStrTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrTree; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrTreeIterator;
class PASCALIMPLEMENTATION TJclUnicodeStrTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclUnicodeStrTreeNode* FCursor;
	TItrStart FStart;
	TJclUnicodeStrTree* FOwnTree;
	Jclcontainerintf::_di_IJclUnicodeStrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclUnicodeStrTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclUnicodeStrTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclUnicodeStrTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclUnicodeStrTreeIterator(TJclUnicodeStrTree* OwnTree, TJclUnicodeStrTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const System::UnicodeString AString);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	System::UnicodeString __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const System::UnicodeString AString);
	bool __fastcall InsertChild(int Index, const System::UnicodeString AString);
	System::UnicodeString __fastcall Parent(void);
	void __fastcall SetChild(int Index, const System::UnicodeString AString);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclUnicodeStrTreeIterator(void) { }
	
private:
	void *__IJclUnicodeStrTreeIterator;	/* Jclcontainerintf::IJclUnicodeStrTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTreeIterator*(void) { return (IJclUnicodeStrTreeIterator*)&__IJclUnicodeStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderUnicodeStrTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderUnicodeStrTreeIterator : public TJclUnicodeStrTreeIterator
{
	typedef TJclUnicodeStrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclUnicodeStrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclUnicodeStrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclUnicodeStrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclUnicodeStrTreeIterator.Create */ inline __fastcall TJclPreOrderUnicodeStrTreeIterator(TJclUnicodeStrTree* OwnTree, TJclUnicodeStrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclUnicodeStrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderUnicodeStrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclUnicodeStrTreeIterator;	/* Jclcontainerintf::IJclUnicodeStrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTreeIterator*(void) { return (IJclUnicodeStrTreeIterator*)&__IJclUnicodeStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderUnicodeStrTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderUnicodeStrTreeIterator : public TJclUnicodeStrTreeIterator
{
	typedef TJclUnicodeStrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclUnicodeStrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclUnicodeStrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclUnicodeStrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclUnicodeStrTreeIterator.Create */ inline __fastcall TJclPostOrderUnicodeStrTreeIterator(TJclUnicodeStrTree* OwnTree, TJclUnicodeStrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclUnicodeStrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderUnicodeStrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclUnicodeStrTreeIterator;	/* Jclcontainerintf::IJclUnicodeStrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTreeIterator*(void) { return (IJclUnicodeStrTreeIterator*)&__IJclUnicodeStrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrTreeIterator; }
	#endif
	
};


typedef TJclUnicodeStrTreeNode TJclStrTreeNode;

typedef TJclUnicodeStrTree TJclStrTree;

typedef TJclUnicodeStrTreeIterator TJclStrTreeIterator;

typedef TJclPreOrderUnicodeStrTreeIterator TJclPreOrderStrTreeIterator;

typedef TJclPostOrderUnicodeStrTreeIterator TJclPostOrderStrTreeIterator;

class DELPHICLASS TJclSingleTreeNode;
class PASCALIMPLEMENTATION TJclSingleTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	float Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclSingleTreeNode* Parent;
	int __fastcall IndexOfChild(TJclSingleTreeNode* AChild);
	int __fastcall IndexOfValue(const float AValue, const Jclcontainerintf::_di_IJclSingleEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclSingleTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSingleTreeNode(void) { }
	
};


class DELPHICLASS TJclSingleTree;
class PASCALIMPLEMENTATION TJclSingleTree : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclSingleTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclSingleTreeNode* &ANode);
	void __fastcall RemoveNode(TJclSingleTreeNode* &ANode);
	TJclSingleTreeNode* __fastcall CloneNode(TJclSingleTreeNode* Node, TJclSingleTreeNode* Parent);
	bool __fastcall NodeContains(TJclSingleTreeNode* ANode, const float AValue);
	void __fastcall PackNode(TJclSingleTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclSingleTree(void);
	__fastcall virtual ~TJclSingleTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclSingleTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclSingleTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclSingleTree;	/* Jclcontainerintf::IJclSingleTree */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTree()
	{
		Jclcontainerintf::_di_IJclSingleTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTree*(void) { return (IJclSingleTree*)&__IJclSingleTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleCollection()
	{
		Jclcontainerintf::_di_IJclSingleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleCollection*(void) { return (IJclSingleCollection*)&__IJclSingleTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleContainer()
	{
		Jclcontainerintf::_di_IJclSingleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleTree; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclSingleTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleTree; }
	#endif
	
};


class DELPHICLASS TJclSingleTreeIterator;
class PASCALIMPLEMENTATION TJclSingleTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclSingleTreeNode* FCursor;
	TItrStart FStart;
	TJclSingleTree* FOwnTree;
	Jclcontainerintf::_di_IJclSingleEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclSingleTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclSingleTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclSingleTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclSingleTreeIterator(TJclSingleTree* OwnTree, TJclSingleTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const float AValue);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	float __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const float AValue);
	bool __fastcall InsertChild(int Index, const float AValue);
	float __fastcall Parent(void);
	void __fastcall SetChild(int Index, const float AValue);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclSingleTreeIterator(void) { }
	
private:
	void *__IJclSingleTreeIterator;	/* Jclcontainerintf::IJclSingleTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTreeIterator*(void) { return (IJclSingleTreeIterator*)&__IJclSingleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderSingleTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderSingleTreeIterator : public TJclSingleTreeIterator
{
	typedef TJclSingleTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclSingleTreeNode* __fastcall GetNextCursor(void);
	virtual TJclSingleTreeNode* __fastcall GetNextSibling(void);
	virtual TJclSingleTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclSingleTreeIterator.Create */ inline __fastcall TJclPreOrderSingleTreeIterator(TJclSingleTree* OwnTree, TJclSingleTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclSingleTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderSingleTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclSingleTreeIterator;	/* Jclcontainerintf::IJclSingleTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTreeIterator*(void) { return (IJclSingleTreeIterator*)&__IJclSingleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderSingleTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderSingleTreeIterator : public TJclSingleTreeIterator
{
	typedef TJclSingleTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclSingleTreeNode* __fastcall GetNextCursor(void);
	virtual TJclSingleTreeNode* __fastcall GetNextSibling(void);
	virtual TJclSingleTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclSingleTreeIterator.Create */ inline __fastcall TJclPostOrderSingleTreeIterator(TJclSingleTree* OwnTree, TJclSingleTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclSingleTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderSingleTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclSingleTreeIterator;	/* Jclcontainerintf::IJclSingleTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTreeIterator*(void) { return (IJclSingleTreeIterator*)&__IJclSingleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclDoubleTreeNode;
class PASCALIMPLEMENTATION TJclDoubleTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	double Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclDoubleTreeNode* Parent;
	int __fastcall IndexOfChild(TJclDoubleTreeNode* AChild);
	int __fastcall IndexOfValue(const double AValue, const Jclcontainerintf::_di_IJclDoubleEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclDoubleTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDoubleTreeNode(void) { }
	
};


class DELPHICLASS TJclDoubleTree;
class PASCALIMPLEMENTATION TJclDoubleTree : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclDoubleTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclDoubleTreeNode* &ANode);
	void __fastcall RemoveNode(TJclDoubleTreeNode* &ANode);
	TJclDoubleTreeNode* __fastcall CloneNode(TJclDoubleTreeNode* Node, TJclDoubleTreeNode* Parent);
	bool __fastcall NodeContains(TJclDoubleTreeNode* ANode, const double AValue);
	void __fastcall PackNode(TJclDoubleTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclDoubleTree(void);
	__fastcall virtual ~TJclDoubleTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclDoubleTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclDoubleTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclDoubleTree;	/* Jclcontainerintf::IJclDoubleTree */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTree()
	{
		Jclcontainerintf::_di_IJclDoubleTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTree*(void) { return (IJclDoubleTree*)&__IJclDoubleTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleCollection()
	{
		Jclcontainerintf::_di_IJclDoubleCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleCollection*(void) { return (IJclDoubleCollection*)&__IJclDoubleTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleContainer()
	{
		Jclcontainerintf::_di_IJclDoubleContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleTree; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclDoubleTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleTree; }
	#endif
	
};


class DELPHICLASS TJclDoubleTreeIterator;
class PASCALIMPLEMENTATION TJclDoubleTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclDoubleTreeNode* FCursor;
	TItrStart FStart;
	TJclDoubleTree* FOwnTree;
	Jclcontainerintf::_di_IJclDoubleEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclDoubleTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclDoubleTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclDoubleTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclDoubleTreeIterator(TJclDoubleTree* OwnTree, TJclDoubleTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const double AValue);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	double __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const double AValue);
	bool __fastcall InsertChild(int Index, const double AValue);
	double __fastcall Parent(void);
	void __fastcall SetChild(int Index, const double AValue);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclDoubleTreeIterator(void) { }
	
private:
	void *__IJclDoubleTreeIterator;	/* Jclcontainerintf::IJclDoubleTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTreeIterator*(void) { return (IJclDoubleTreeIterator*)&__IJclDoubleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderDoubleTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderDoubleTreeIterator : public TJclDoubleTreeIterator
{
	typedef TJclDoubleTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclDoubleTreeNode* __fastcall GetNextCursor(void);
	virtual TJclDoubleTreeNode* __fastcall GetNextSibling(void);
	virtual TJclDoubleTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclDoubleTreeIterator.Create */ inline __fastcall TJclPreOrderDoubleTreeIterator(TJclDoubleTree* OwnTree, TJclDoubleTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclDoubleTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderDoubleTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclDoubleTreeIterator;	/* Jclcontainerintf::IJclDoubleTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTreeIterator*(void) { return (IJclDoubleTreeIterator*)&__IJclDoubleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderDoubleTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderDoubleTreeIterator : public TJclDoubleTreeIterator
{
	typedef TJclDoubleTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclDoubleTreeNode* __fastcall GetNextCursor(void);
	virtual TJclDoubleTreeNode* __fastcall GetNextSibling(void);
	virtual TJclDoubleTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclDoubleTreeIterator.Create */ inline __fastcall TJclPostOrderDoubleTreeIterator(TJclDoubleTree* OwnTree, TJclDoubleTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclDoubleTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderDoubleTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclDoubleTreeIterator;	/* Jclcontainerintf::IJclDoubleTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTreeIterator*(void) { return (IJclDoubleTreeIterator*)&__IJclDoubleTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclExtendedTreeNode;
class PASCALIMPLEMENTATION TJclExtendedTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::Extended Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclExtendedTreeNode* Parent;
	int __fastcall IndexOfChild(TJclExtendedTreeNode* AChild);
	int __fastcall IndexOfValue(const System::Extended AValue, const Jclcontainerintf::_di_IJclExtendedEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclExtendedTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclExtendedTreeNode(void) { }
	
};


class DELPHICLASS TJclExtendedTree;
class PASCALIMPLEMENTATION TJclExtendedTree : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclExtendedTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclExtendedTreeNode* &ANode);
	void __fastcall RemoveNode(TJclExtendedTreeNode* &ANode);
	TJclExtendedTreeNode* __fastcall CloneNode(TJclExtendedTreeNode* Node, TJclExtendedTreeNode* Parent);
	bool __fastcall NodeContains(TJclExtendedTreeNode* ANode, const System::Extended AValue);
	void __fastcall PackNode(TJclExtendedTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclExtendedTree(void);
	__fastcall virtual ~TJclExtendedTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclExtendedTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclExtendedTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclExtendedTree;	/* Jclcontainerintf::IJclExtendedTree */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTree()
	{
		Jclcontainerintf::_di_IJclExtendedTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTree*(void) { return (IJclExtendedTree*)&__IJclExtendedTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedCollection()
	{
		Jclcontainerintf::_di_IJclExtendedCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedCollection*(void) { return (IJclExtendedCollection*)&__IJclExtendedTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedContainer()
	{
		Jclcontainerintf::_di_IJclExtendedContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedTree; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclExtendedTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedTree; }
	#endif
	
};


class DELPHICLASS TJclExtendedTreeIterator;
class PASCALIMPLEMENTATION TJclExtendedTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclExtendedTreeNode* FCursor;
	TItrStart FStart;
	TJclExtendedTree* FOwnTree;
	Jclcontainerintf::_di_IJclExtendedEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclExtendedTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclExtendedTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclExtendedTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclExtendedTreeIterator(TJclExtendedTree* OwnTree, TJclExtendedTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const System::Extended AValue);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	System::Extended __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const System::Extended AValue);
	bool __fastcall InsertChild(int Index, const System::Extended AValue);
	System::Extended __fastcall Parent(void);
	void __fastcall SetChild(int Index, const System::Extended AValue);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclExtendedTreeIterator(void) { }
	
private:
	void *__IJclExtendedTreeIterator;	/* Jclcontainerintf::IJclExtendedTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTreeIterator*(void) { return (IJclExtendedTreeIterator*)&__IJclExtendedTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderExtendedTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderExtendedTreeIterator : public TJclExtendedTreeIterator
{
	typedef TJclExtendedTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclExtendedTreeNode* __fastcall GetNextCursor(void);
	virtual TJclExtendedTreeNode* __fastcall GetNextSibling(void);
	virtual TJclExtendedTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclExtendedTreeIterator.Create */ inline __fastcall TJclPreOrderExtendedTreeIterator(TJclExtendedTree* OwnTree, TJclExtendedTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclExtendedTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderExtendedTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclExtendedTreeIterator;	/* Jclcontainerintf::IJclExtendedTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTreeIterator*(void) { return (IJclExtendedTreeIterator*)&__IJclExtendedTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderExtendedTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderExtendedTreeIterator : public TJclExtendedTreeIterator
{
	typedef TJclExtendedTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclExtendedTreeNode* __fastcall GetNextCursor(void);
	virtual TJclExtendedTreeNode* __fastcall GetNextSibling(void);
	virtual TJclExtendedTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclExtendedTreeIterator.Create */ inline __fastcall TJclPostOrderExtendedTreeIterator(TJclExtendedTree* OwnTree, TJclExtendedTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclExtendedTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderExtendedTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclExtendedTreeIterator;	/* Jclcontainerintf::IJclExtendedTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTreeIterator*(void) { return (IJclExtendedTreeIterator*)&__IJclExtendedTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedTreeIterator; }
	#endif
	
};


typedef TJclExtendedTreeNode TJclFloatTreeNode;

typedef TJclExtendedTree TJclFloatTree;

typedef TJclExtendedTreeIterator TJclFloatTreeIterator;

typedef TJclPreOrderExtendedTreeIterator TJclPreOrderFloatTreeIterator;

typedef TJclPostOrderExtendedTreeIterator TJclPostOrderFloatTreeIterator;

class DELPHICLASS TJclIntegerTreeNode;
class PASCALIMPLEMENTATION TJclIntegerTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	int Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclIntegerTreeNode* Parent;
	int __fastcall IndexOfChild(TJclIntegerTreeNode* AChild);
	int __fastcall IndexOfValue(int AValue, const Jclcontainerintf::_di_IJclIntegerEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclIntegerTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntegerTreeNode(void) { }
	
};


class DELPHICLASS TJclIntegerTree;
class PASCALIMPLEMENTATION TJclIntegerTree : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclIntegerTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclIntegerTreeNode* &ANode);
	void __fastcall RemoveNode(TJclIntegerTreeNode* &ANode);
	TJclIntegerTreeNode* __fastcall CloneNode(TJclIntegerTreeNode* Node, TJclIntegerTreeNode* Parent);
	bool __fastcall NodeContains(TJclIntegerTreeNode* ANode, int AValue);
	void __fastcall PackNode(TJclIntegerTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclIntegerTree(void);
	__fastcall virtual ~TJclIntegerTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclIntegerTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclIntegerTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclIntegerTree;	/* Jclcontainerintf::IJclIntegerTree */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTree()
	{
		Jclcontainerintf::_di_IJclIntegerTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTree*(void) { return (IJclIntegerTree*)&__IJclIntegerTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerCollection()
	{
		Jclcontainerintf::_di_IJclIntegerCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerCollection*(void) { return (IJclIntegerCollection*)&__IJclIntegerTree; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerTree; }
	#endif
	
};


class DELPHICLASS TJclIntegerTreeIterator;
class PASCALIMPLEMENTATION TJclIntegerTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclIntegerTreeNode* FCursor;
	TItrStart FStart;
	TJclIntegerTree* FOwnTree;
	Jclcontainerintf::_di_IJclIntegerEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclIntegerTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclIntegerTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclIntegerTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclIntegerTreeIterator(TJclIntegerTree* OwnTree, TJclIntegerTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(int AValue);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	int __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(int AValue);
	bool __fastcall InsertChild(int Index, int AValue);
	int __fastcall Parent(void);
	void __fastcall SetChild(int Index, int AValue);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntegerTreeIterator(void) { }
	
private:
	void *__IJclIntegerTreeIterator;	/* Jclcontainerintf::IJclIntegerTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTreeIterator*(void) { return (IJclIntegerTreeIterator*)&__IJclIntegerTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderIntegerTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderIntegerTreeIterator : public TJclIntegerTreeIterator
{
	typedef TJclIntegerTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntegerTreeNode* __fastcall GetNextCursor(void);
	virtual TJclIntegerTreeNode* __fastcall GetNextSibling(void);
	virtual TJclIntegerTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntegerTreeIterator.Create */ inline __fastcall TJclPreOrderIntegerTreeIterator(TJclIntegerTree* OwnTree, TJclIntegerTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclIntegerTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderIntegerTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntegerTreeIterator;	/* Jclcontainerintf::IJclIntegerTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTreeIterator*(void) { return (IJclIntegerTreeIterator*)&__IJclIntegerTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderIntegerTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderIntegerTreeIterator : public TJclIntegerTreeIterator
{
	typedef TJclIntegerTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntegerTreeNode* __fastcall GetNextCursor(void);
	virtual TJclIntegerTreeNode* __fastcall GetNextSibling(void);
	virtual TJclIntegerTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntegerTreeIterator.Create */ inline __fastcall TJclPostOrderIntegerTreeIterator(TJclIntegerTree* OwnTree, TJclIntegerTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclIntegerTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderIntegerTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntegerTreeIterator;	/* Jclcontainerintf::IJclIntegerTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTreeIterator*(void) { return (IJclIntegerTreeIterator*)&__IJclIntegerTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclCardinalTreeNode;
class PASCALIMPLEMENTATION TJclCardinalTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	unsigned Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclCardinalTreeNode* Parent;
	int __fastcall IndexOfChild(TJclCardinalTreeNode* AChild);
	int __fastcall IndexOfValue(unsigned AValue, const Jclcontainerintf::_di_IJclCardinalEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclCardinalTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCardinalTreeNode(void) { }
	
};


class DELPHICLASS TJclCardinalTree;
class PASCALIMPLEMENTATION TJclCardinalTree : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclCardinalTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclCardinalTreeNode* &ANode);
	void __fastcall RemoveNode(TJclCardinalTreeNode* &ANode);
	TJclCardinalTreeNode* __fastcall CloneNode(TJclCardinalTreeNode* Node, TJclCardinalTreeNode* Parent);
	bool __fastcall NodeContains(TJclCardinalTreeNode* ANode, unsigned AValue);
	void __fastcall PackNode(TJclCardinalTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclCardinalTree(void);
	__fastcall virtual ~TJclCardinalTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclCardinalTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclCardinalTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclCardinalTree;	/* Jclcontainerintf::IJclCardinalTree */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTree()
	{
		Jclcontainerintf::_di_IJclCardinalTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTree*(void) { return (IJclCardinalTree*)&__IJclCardinalTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalCollection()
	{
		Jclcontainerintf::_di_IJclCardinalCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalCollection*(void) { return (IJclCardinalCollection*)&__IJclCardinalTree; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalTree; }
	#endif
	
};


class DELPHICLASS TJclCardinalTreeIterator;
class PASCALIMPLEMENTATION TJclCardinalTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclCardinalTreeNode* FCursor;
	TItrStart FStart;
	TJclCardinalTree* FOwnTree;
	Jclcontainerintf::_di_IJclCardinalEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclCardinalTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclCardinalTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclCardinalTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclCardinalTreeIterator(TJclCardinalTree* OwnTree, TJclCardinalTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(unsigned AValue);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	unsigned __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(unsigned AValue);
	bool __fastcall InsertChild(int Index, unsigned AValue);
	unsigned __fastcall Parent(void);
	void __fastcall SetChild(int Index, unsigned AValue);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclCardinalTreeIterator(void) { }
	
private:
	void *__IJclCardinalTreeIterator;	/* Jclcontainerintf::IJclCardinalTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTreeIterator*(void) { return (IJclCardinalTreeIterator*)&__IJclCardinalTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderCardinalTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderCardinalTreeIterator : public TJclCardinalTreeIterator
{
	typedef TJclCardinalTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclCardinalTreeNode* __fastcall GetNextCursor(void);
	virtual TJclCardinalTreeNode* __fastcall GetNextSibling(void);
	virtual TJclCardinalTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclCardinalTreeIterator.Create */ inline __fastcall TJclPreOrderCardinalTreeIterator(TJclCardinalTree* OwnTree, TJclCardinalTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclCardinalTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderCardinalTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCardinalTreeIterator;	/* Jclcontainerintf::IJclCardinalTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTreeIterator*(void) { return (IJclCardinalTreeIterator*)&__IJclCardinalTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderCardinalTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderCardinalTreeIterator : public TJclCardinalTreeIterator
{
	typedef TJclCardinalTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclCardinalTreeNode* __fastcall GetNextCursor(void);
	virtual TJclCardinalTreeNode* __fastcall GetNextSibling(void);
	virtual TJclCardinalTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclCardinalTreeIterator.Create */ inline __fastcall TJclPostOrderCardinalTreeIterator(TJclCardinalTree* OwnTree, TJclCardinalTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclCardinalTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderCardinalTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCardinalTreeIterator;	/* Jclcontainerintf::IJclCardinalTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTreeIterator*(void) { return (IJclCardinalTreeIterator*)&__IJclCardinalTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInt64TreeNode;
class PASCALIMPLEMENTATION TJclInt64TreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__int64 Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclInt64TreeNode* Parent;
	int __fastcall IndexOfChild(TJclInt64TreeNode* AChild);
	int __fastcall IndexOfValue(const __int64 AValue, const Jclcontainerintf::_di_IJclInt64EqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclInt64TreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInt64TreeNode(void) { }
	
};


class DELPHICLASS TJclInt64Tree;
class PASCALIMPLEMENTATION TJclInt64Tree : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclInt64TreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclInt64TreeNode* &ANode);
	void __fastcall RemoveNode(TJclInt64TreeNode* &ANode);
	TJclInt64TreeNode* __fastcall CloneNode(TJclInt64TreeNode* Node, TJclInt64TreeNode* Parent);
	bool __fastcall NodeContains(TJclInt64TreeNode* ANode, const __int64 AValue);
	void __fastcall PackNode(TJclInt64TreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclInt64Tree(void);
	__fastcall virtual ~TJclInt64Tree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclInt64TreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclInt64TreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclInt64Tree;	/* Jclcontainerintf::IJclInt64Tree */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Tree()
	{
		Jclcontainerintf::_di_IJclInt64Tree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Tree*(void) { return (IJclInt64Tree*)&__IJclInt64Tree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Collection()
	{
		Jclcontainerintf::_di_IJclInt64Collection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Collection*(void) { return (IJclInt64Collection*)&__IJclInt64Tree; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Tree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Tree; }
	#endif
	
};


class DELPHICLASS TJclInt64TreeIterator;
class PASCALIMPLEMENTATION TJclInt64TreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclInt64TreeNode* FCursor;
	TItrStart FStart;
	TJclInt64Tree* FOwnTree;
	Jclcontainerintf::_di_IJclInt64EqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclInt64TreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclInt64TreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclInt64TreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclInt64TreeIterator(TJclInt64Tree* OwnTree, TJclInt64TreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const __int64 AValue);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	__int64 __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const __int64 AValue);
	bool __fastcall InsertChild(int Index, const __int64 AValue);
	__int64 __fastcall Parent(void);
	void __fastcall SetChild(int Index, const __int64 AValue);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInt64TreeIterator(void) { }
	
private:
	void *__IJclInt64TreeIterator;	/* Jclcontainerintf::IJclInt64TreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64TreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64TreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TreeIterator*(void) { return (IJclInt64TreeIterator*)&__IJclInt64TreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64TreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderInt64TreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderInt64TreeIterator : public TJclInt64TreeIterator
{
	typedef TJclInt64TreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclInt64TreeNode* __fastcall GetNextCursor(void);
	virtual TJclInt64TreeNode* __fastcall GetNextSibling(void);
	virtual TJclInt64TreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclInt64TreeIterator.Create */ inline __fastcall TJclPreOrderInt64TreeIterator(TJclInt64Tree* OwnTree, TJclInt64TreeNode* ACursor, bool AValid, TItrStart AStart) : TJclInt64TreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderInt64TreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclInt64TreeIterator;	/* Jclcontainerintf::IJclInt64TreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64TreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64TreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64TreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TreeIterator*(void) { return (IJclInt64TreeIterator*)&__IJclInt64TreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64TreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderInt64TreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderInt64TreeIterator : public TJclInt64TreeIterator
{
	typedef TJclInt64TreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclInt64TreeNode* __fastcall GetNextCursor(void);
	virtual TJclInt64TreeNode* __fastcall GetNextSibling(void);
	virtual TJclInt64TreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclInt64TreeIterator.Create */ inline __fastcall TJclPostOrderInt64TreeIterator(TJclInt64Tree* OwnTree, TJclInt64TreeNode* ACursor, bool AValid, TItrStart AStart) : TJclInt64TreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderInt64TreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclInt64TreeIterator;	/* Jclcontainerintf::IJclInt64TreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64TreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64TreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64TreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TreeIterator*(void) { return (IJclInt64TreeIterator*)&__IJclInt64TreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64TreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPtrTreeNode;
class PASCALIMPLEMENTATION TJclPtrTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	void *Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclPtrTreeNode* Parent;
	int __fastcall IndexOfChild(TJclPtrTreeNode* AChild);
	int __fastcall IndexOfValue(void * APtr, const Jclcontainerintf::_di_IJclPtrEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclPtrTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclPtrTreeNode(void) { }
	
};


class DELPHICLASS TJclPtrTree;
class PASCALIMPLEMENTATION TJclPtrTree : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclPtrTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclPtrTreeNode* &ANode);
	void __fastcall RemoveNode(TJclPtrTreeNode* &ANode);
	TJclPtrTreeNode* __fastcall CloneNode(TJclPtrTreeNode* Node, TJclPtrTreeNode* Parent);
	bool __fastcall NodeContains(TJclPtrTreeNode* ANode, void * APtr);
	void __fastcall PackNode(TJclPtrTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclPtrTree(void);
	__fastcall virtual ~TJclPtrTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclPtrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclPtrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclPtrTree;	/* Jclcontainerintf::IJclPtrTree */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTree()
	{
		Jclcontainerintf::_di_IJclPtrTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTree*(void) { return (IJclPtrTree*)&__IJclPtrTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrCollection()
	{
		Jclcontainerintf::_di_IJclPtrCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrCollection*(void) { return (IJclPtrCollection*)&__IJclPtrTree; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrTree; }
	#endif
	
};


class DELPHICLASS TJclPtrTreeIterator;
class PASCALIMPLEMENTATION TJclPtrTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclPtrTreeNode* FCursor;
	TItrStart FStart;
	TJclPtrTree* FOwnTree;
	Jclcontainerintf::_di_IJclPtrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclPtrTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclPtrTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclPtrTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclPtrTreeIterator(TJclPtrTree* OwnTree, TJclPtrTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(void * APtr);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	void * __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(void * APtr);
	bool __fastcall InsertChild(int Index, void * APtr);
	void * __fastcall Parent(void);
	void __fastcall SetChild(int Index, void * APtr);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPtrTreeIterator(void) { }
	
private:
	void *__IJclPtrTreeIterator;	/* Jclcontainerintf::IJclPtrTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTreeIterator*(void) { return (IJclPtrTreeIterator*)&__IJclPtrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderPtrTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderPtrTreeIterator : public TJclPtrTreeIterator
{
	typedef TJclPtrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclPtrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclPtrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclPtrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclPtrTreeIterator.Create */ inline __fastcall TJclPreOrderPtrTreeIterator(TJclPtrTree* OwnTree, TJclPtrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclPtrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderPtrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclPtrTreeIterator;	/* Jclcontainerintf::IJclPtrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTreeIterator*(void) { return (IJclPtrTreeIterator*)&__IJclPtrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderPtrTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderPtrTreeIterator : public TJclPtrTreeIterator
{
	typedef TJclPtrTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclPtrTreeNode* __fastcall GetNextCursor(void);
	virtual TJclPtrTreeNode* __fastcall GetNextSibling(void);
	virtual TJclPtrTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclPtrTreeIterator.Create */ inline __fastcall TJclPostOrderPtrTreeIterator(TJclPtrTree* OwnTree, TJclPtrTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclPtrTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderPtrTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclPtrTreeIterator;	/* Jclcontainerintf::IJclPtrTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTreeIterator*(void) { return (IJclPtrTreeIterator*)&__IJclPtrTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclTreeNode;
class PASCALIMPLEMENTATION TJclTreeNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::TObject* Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclTreeNode* Parent;
	int __fastcall IndexOfChild(TJclTreeNode* AChild);
	int __fastcall IndexOfValue(System::TObject* AObject, const Jclcontainerintf::_di_IJclEqualityComparer AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclTreeNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeNode(void) { }
	
};


class DELPHICLASS TJclTree;
class PASCALIMPLEMENTATION TJclTree : public Jclabstractcontainers::TJclAbstractContainer
{
	typedef Jclabstractcontainers::TJclAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	TJclTreeNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclTreeNode* &ANode);
	void __fastcall RemoveNode(TJclTreeNode* &ANode);
	TJclTreeNode* __fastcall CloneNode(TJclTreeNode* Node, TJclTreeNode* Parent);
	bool __fastcall NodeContains(TJclTreeNode* ANode, System::TObject* AObject);
	void __fastcall PackNode(TJclTreeNode* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclTree(bool AOwnsObjects);
	__fastcall virtual ~TJclTree(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	Jclcontainerintf::_di_IJclTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclTree;	/* Jclcontainerintf::IJclTree */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTree()
	{
		Jclcontainerintf::_di_IJclTree intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTree*(void) { return (IJclTree*)&__IJclTree; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCollection()
	{
		Jclcontainerintf::_di_IJclCollection intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection*(void) { return (IJclCollection*)&__IJclTree; }
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
	operator Jclcontainerintf::_di_IJclBaseContainer()
	{
		Jclcontainerintf::_di_IJclBaseContainer intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTree; }
	#endif
	
};


class DELPHICLASS TJclTreeIterator;
class PASCALIMPLEMENTATION TJclTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclTreeNode* FCursor;
	TItrStart FStart;
	TJclTree* FOwnTree;
	Jclcontainerintf::_di_IJclEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclTreeNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclTreeNode* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclTreeNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclTreeIterator(TJclTree* OwnTree, TJclTreeNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(System::TObject* AObject);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	System::TObject* __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(System::TObject* AObject);
	bool __fastcall InsertChild(int Index, System::TObject* AObject);
	System::TObject* __fastcall Parent(void);
	void __fastcall SetChild(int Index, System::TObject* AObject);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclTreeIterator(void) { }
	
private:
	void *__IJclTreeIterator;	/* Jclcontainerintf::IJclTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTreeIterator()
	{
		Jclcontainerintf::_di_IJclTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator*(void) { return (IJclTreeIterator*)&__IJclTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderTreeIterator : public TJclTreeIterator
{
	typedef TJclTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclTreeNode* __fastcall GetNextCursor(void);
	virtual TJclTreeNode* __fastcall GetNextSibling(void);
	virtual TJclTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclTreeIterator.Create */ inline __fastcall TJclPreOrderTreeIterator(TJclTree* OwnTree, TJclTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclTreeIterator;	/* Jclcontainerintf::IJclTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTreeIterator()
	{
		Jclcontainerintf::_di_IJclTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator*(void) { return (IJclTreeIterator*)&__IJclTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderTreeIterator : public TJclTreeIterator
{
	typedef TJclTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclTreeNode* __fastcall GetNextCursor(void);
	virtual TJclTreeNode* __fastcall GetNextSibling(void);
	virtual TJclTreeNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclTreeIterator.Create */ inline __fastcall TJclPostOrderTreeIterator(TJclTree* OwnTree, TJclTreeNode* ACursor, bool AValid, TItrStart AStart) : TJclTreeIterator(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclTreeIterator;	/* Jclcontainerintf::IJclTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTreeIterator()
	{
		Jclcontainerintf::_di_IJclTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator*(void) { return (IJclTreeIterator*)&__IJclTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclTreeIterator; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclTreeNode__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclTreeNode__1 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	T Value;
	Jclbase::TDynObjectArray Children;
	int ChildrenCount;
	TJclTreeNode__1<T>* Parent;
	int __fastcall IndexOfChild(TJclTreeNode__1<T>* AChild);
	int __fastcall IndexOfValue(const T AItem, const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  AEqualityComparer);
public:
	/* TObject.Create */ inline __fastcall TJclTreeNode__1(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeNode__1(void) { }
	
};


template<typename T> class DELPHICLASS TJclTree__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclTree__1 : public Jclabstractcontainers::TJclAbstractContainer__1<T>
{
	typedef Jclabstractcontainers::TJclAbstractContainer__1<T> inherited;
	
protected:
	
private:
	TJclTreeNode__1<T>* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	
protected:
	void __fastcall ExtractNode(TJclTreeNode__1<T>* &ANode);
	void __fastcall RemoveNode(TJclTreeNode__1<T>* &ANode);
	TJclTreeNode__1<T>* __fastcall CloneNode(TJclTreeNode__1<T>* Node, TJclTreeNode__1<T>* Parent);
	bool __fastcall NodeContains(TJclTreeNode__1<T>* ANode, const T AItem);
	void __fastcall PackNode(TJclTreeNode__1<T>* ANode);
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	
public:
	__fastcall TJclTree__1(bool AOwnsItems);
	__fastcall virtual ~TJclTree__1(void);
	virtual void __fastcall Pack(void);
	virtual void __fastcall SetCapacity(int Value);
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
	System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >  __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >  Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclGrowable;	/* Jclcontainerintf::IJclGrowable */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTree__1<T>*(void) { return (IJclTree__1<T>*)&__IJclTree__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclTree__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclTree__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTree__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclTreeIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclTreeIterator__1 : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclTreeNode__1<T>* FCursor;
	TItrStart FStart;
	TJclTree__1<T>* FOwnTree;
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclTreeNode__1<T>* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclTreeNode__1<T>* __fastcall GetNextSibling(void) = 0 ;
	virtual TJclTreeNode__1<T>* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclTreeIterator__1(TJclTree__1<T>* OwnTree, TJclTreeNode__1<T>* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall AddChild(const T AItem);
	int __fastcall ChildrenCount(void);
	void __fastcall DeleteChild(int Index);
	void __fastcall DeleteChildren(void);
	void __fastcall ExtractChild(int Index);
	void __fastcall ExtractChildren(void);
	T __fastcall GetChild(int Index);
	bool __fastcall HasChild(int Index);
	bool __fastcall HasParent(void);
	int __fastcall IndexOfChild(const T AItem);
	bool __fastcall InsertChild(int Index, const T AItem);
	T __fastcall Parent(void);
	void __fastcall SetChild(int Index, const T AItem);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclTreeIterator__1(void) { }
	
private:
	void *__IJclTreeIterator__1;	/* Jclcontainerintf::IJclTreeIterator__1<T> */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator__1<T>*(void) { return (IJclTreeIterator__1<T>*)&__IJclTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclTreeIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclPreOrderTreeIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclPreOrderTreeIterator__1 : public TJclTreeIterator__1<T>
{
	typedef TJclTreeIterator__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclTreeNode__1<T>* __fastcall GetNextCursor(void);
	virtual TJclTreeNode__1<T>* __fastcall GetNextSibling(void);
	virtual TJclTreeNode__1<T>* __fastcall GetPreviousCursor(void);
public:
	/* TJclTreeIterator<T>.Create */ inline __fastcall TJclPreOrderTreeIterator__1(TJclTree__1<T>* OwnTree, TJclTreeNode__1<T>* ACursor, bool AValid, TItrStart AStart) : TJclTreeIterator__1<T>(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderTreeIterator__1(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclTreeIterator__1;	/* Jclcontainerintf::IJclTreeIterator__1<T> */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator__1<T>*(void) { return (IJclTreeIterator__1<T>*)&__IJclTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclTreeIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclPostOrderTreeIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclPostOrderTreeIterator__1 : public TJclTreeIterator__1<T>
{
	typedef TJclTreeIterator__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclTreeNode__1<T>* __fastcall GetNextCursor(void);
	virtual TJclTreeNode__1<T>* __fastcall GetNextSibling(void);
	virtual TJclTreeNode__1<T>* __fastcall GetPreviousCursor(void);
public:
	/* TJclTreeIterator<T>.Create */ inline __fastcall TJclPostOrderTreeIterator__1(TJclTree__1<T>* OwnTree, TJclTreeNode__1<T>* ACursor, bool AValid, TItrStart AStart) : TJclTreeIterator__1<T>(OwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderTreeIterator__1(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclTreeIterator__1;	/* Jclcontainerintf::IJclTreeIterator__1<T> */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator__1<T>*(void) { return (IJclTreeIterator__1<T>*)&__IJclTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclTreeIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclTreeE__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclTreeE__1 : public TJclTree__1<T>
{
	typedef TJclTree__1<T> inherited;
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  FEqualityComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclTreeE__1(const System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  AEqualityComparer, bool AOwnsItems);
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  EqualityComparer = {read=FEqualityComparer, write=FEqualityComparer};
public:
	/* TJclTree<T>.Destroy */ inline __fastcall virtual ~TJclTreeE__1(void) { }
	
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTree__1<T>*(void) { return (IJclTree__1<T>*)&__IJclTree__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclTree__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclTree__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTree__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclTreeF__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclTreeF__1 : public TJclTree__1<T>
{
	typedef TJclTree__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclTreeF__1(_decl_TCompare__1(T, ACompare), bool AOwnsItems);
public:
	/* TJclTree<T>.Destroy */ inline __fastcall virtual ~TJclTreeF__1(void) { }
	
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTree__1<T>*(void) { return (IJclTree__1<T>*)&__IJclTree__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclTree__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclTree__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTree__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclTreeI__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclTreeI__1 : public TJclTree__1<T>
{
	typedef TJclTree__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	virtual bool __fastcall ItemsEqual(const T A, const T B);
public:
	/* TJclTree<T>.Create */ inline __fastcall TJclTreeI__1(bool AOwnsItems) : TJclTree__1<T>(AOwnsItems) { }
	/* TJclTree<T>.Destroy */ inline __fastcall virtual ~TJclTreeI__1(void) { }
	
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTree__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTree__1<T>*(void) { return (IJclTree__1<T>*)&__IJclTree__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCollection__1<T>*(void) { return (IJclCollection__1<T>*)&__IJclTree__1; }
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclTree__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTree__1; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jcltrees */
using namespace Jcltrees;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcltreesHPP
