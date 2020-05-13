// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclbinarytrees.pas' rev: 21.00

#ifndef JclbinarytreesHPP
#define JclbinarytreesHPP

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
#include <Jclabstractcontainers.hpp>	// Pascal unit
#include <Jclalgorithms.hpp>	// Pascal unit
#include <Jclcontainerintf.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclbinarytrees
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TItrStart { isFirst, isLast, isRoot };
#pragma option pop

class DELPHICLASS TJclIntfBinaryNode;
class PASCALIMPLEMENTATION TJclIntfBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::_di_IInterface Value;
	TJclIntfBinaryNode* Left;
	TJclIntfBinaryNode* Right;
	TJclIntfBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclIntfBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntfBinaryNode(void) { }
	
};


class DELPHICLASS TJclIntfBinaryTree;
class PASCALIMPLEMENTATION TJclIntfBinaryTree : public Jclabstractcontainers::TJclIntfAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntfAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclIntfBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclIntfBinaryNode* __fastcall BuildTree(TJclIntfBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclIntfBinaryNode* Parent, int Offset);
	TJclIntfBinaryNode* __fastcall CloneNode(TJclIntfBinaryNode* Node, TJclIntfBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclIntfBinaryTree(Jclcontainerintf::TIntfCompare ACompare);
	__fastcall virtual ~TJclIntfBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclIntfTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclIntfTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclIntfTree;	/* Jclcontainerintf::IJclIntfTree */
	void *__IJclIntfComparer;	/* Jclcontainerintf::IJclIntfComparer */
	void *__IJclIntfEqualityComparer;	/* Jclcontainerintf::IJclIntfEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntfTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfTree; }
	#endif
	
};


class DELPHICLASS TJclIntfBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclIntfBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclIntfBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclIntfCollection FOwnTree;
	Jclcontainerintf::_di_IJclIntfEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclIntfBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclIntfBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclIntfBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntfCollection AOwnTree, TJclIntfBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	System::_di_IInterface __fastcall Left(void);
	System::_di_IInterface __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntfBinaryTreeIterator(void) { }
	
private:
	void *__IJclIntfBinaryTreeIterator;	/* Jclcontainerintf::IJclIntfBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfBinaryTreeIterator*(void) { return (IJclIntfBinaryTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTreeIterator*(void) { return (IJclIntfTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderIntfBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderIntfBinaryTreeIterator : public TJclIntfBinaryTreeIterator
{
	typedef TJclIntfBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntfBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclIntfBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntfBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderIntfBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntfCollection AOwnTree, TJclIntfBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclIntfBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderIntfBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntfBinaryTreeIterator;	/* Jclcontainerintf::IJclIntfBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfBinaryTreeIterator*(void) { return (IJclIntfBinaryTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTreeIterator*(void) { return (IJclIntfTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderIntfBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderIntfBinaryTreeIterator : public TJclIntfBinaryTreeIterator
{
	typedef TJclIntfBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntfBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclIntfBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntfBinaryTreeIterator.Create */ inline __fastcall TJclInOrderIntfBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntfCollection AOwnTree, TJclIntfBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclIntfBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderIntfBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntfBinaryTreeIterator;	/* Jclcontainerintf::IJclIntfBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfBinaryTreeIterator*(void) { return (IJclIntfBinaryTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTreeIterator*(void) { return (IJclIntfTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderIntfBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderIntfBinaryTreeIterator : public TJclIntfBinaryTreeIterator
{
	typedef TJclIntfBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntfBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclIntfBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntfBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderIntfBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntfCollection AOwnTree, TJclIntfBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclIntfBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderIntfBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntfBinaryTreeIterator;	/* Jclcontainerintf::IJclIntfBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfBinaryTreeIterator*(void) { return (IJclIntfBinaryTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntfTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfTreeIterator*(void) { return (IJclIntfTreeIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntfIterator()
	{
		Jclcontainerintf::_di_IJclIntfIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntfIterator*(void) { return (IJclIntfIterator*)&__IJclIntfBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrBinaryNode;
class PASCALIMPLEMENTATION TJclAnsiStrBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::AnsiString Value;
	TJclAnsiStrBinaryNode* Left;
	TJclAnsiStrBinaryNode* Right;
	TJclAnsiStrBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclAnsiStrBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAnsiStrBinaryNode(void) { }
	
};


class DELPHICLASS TJclAnsiStrBinaryTree;
class PASCALIMPLEMENTATION TJclAnsiStrBinaryTree : public Jclabstractcontainers::TJclAnsiStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclAnsiStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclAnsiStrBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclAnsiStrBinaryNode* __fastcall BuildTree(TJclAnsiStrBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclAnsiStrBinaryNode* Parent, int Offset);
	TJclAnsiStrBinaryNode* __fastcall CloneNode(TJclAnsiStrBinaryNode* Node, TJclAnsiStrBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclAnsiStrBinaryTree(Jclcontainerintf::TAnsiStrCompare ACompare);
	__fastcall virtual ~TJclAnsiStrBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclAnsiStrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclAnsiStrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclAnsiStrTree;	/* Jclcontainerintf::IJclAnsiStrTree */
	void *__IJclAnsiStrComparer;	/* Jclcontainerintf::IJclAnsiStrComparer */
	void *__IJclAnsiStrEqualityComparer;	/* Jclcontainerintf::IJclAnsiStrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrTree; }
	#endif
	
};


class DELPHICLASS TJclAnsiStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclAnsiStrBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclAnsiStrBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclAnsiStrCollection FOwnTree;
	Jclcontainerintf::_di_IJclAnsiStrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclAnsiStrBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclAnsiStrBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclAnsiStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclAnsiStrCollection AOwnTree, TJclAnsiStrBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	System::AnsiString __fastcall Left(void);
	System::AnsiString __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclAnsiStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclAnsiStrBinaryTreeIterator;	/* Jclcontainerintf::IJclAnsiStrBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrBinaryTreeIterator*(void) { return (IJclAnsiStrBinaryTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTreeIterator*(void) { return (IJclAnsiStrTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderAnsiStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderAnsiStrBinaryTreeIterator : public TJclAnsiStrBinaryTreeIterator
{
	typedef TJclAnsiStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclAnsiStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclAnsiStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclAnsiStrBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderAnsiStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclAnsiStrCollection AOwnTree, TJclAnsiStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclAnsiStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderAnsiStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclAnsiStrBinaryTreeIterator;	/* Jclcontainerintf::IJclAnsiStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrBinaryTreeIterator*(void) { return (IJclAnsiStrBinaryTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTreeIterator*(void) { return (IJclAnsiStrTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderAnsiStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderAnsiStrBinaryTreeIterator : public TJclAnsiStrBinaryTreeIterator
{
	typedef TJclAnsiStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclAnsiStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclAnsiStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclAnsiStrBinaryTreeIterator.Create */ inline __fastcall TJclInOrderAnsiStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclAnsiStrCollection AOwnTree, TJclAnsiStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclAnsiStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderAnsiStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclAnsiStrBinaryTreeIterator;	/* Jclcontainerintf::IJclAnsiStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrBinaryTreeIterator*(void) { return (IJclAnsiStrBinaryTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTreeIterator*(void) { return (IJclAnsiStrTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderAnsiStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderAnsiStrBinaryTreeIterator : public TJclAnsiStrBinaryTreeIterator
{
	typedef TJclAnsiStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclAnsiStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclAnsiStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclAnsiStrBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderAnsiStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclAnsiStrCollection AOwnTree, TJclAnsiStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclAnsiStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderAnsiStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclAnsiStrBinaryTreeIterator;	/* Jclcontainerintf::IJclAnsiStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrBinaryTreeIterator*(void) { return (IJclAnsiStrBinaryTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrTreeIterator*(void) { return (IJclAnsiStrTreeIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclAnsiStrIterator()
	{
		Jclcontainerintf::_di_IJclAnsiStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclAnsiStrIterator*(void) { return (IJclAnsiStrIterator*)&__IJclAnsiStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclWideStrBinaryNode;
class PASCALIMPLEMENTATION TJclWideStrBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::WideString Value;
	TJclWideStrBinaryNode* Left;
	TJclWideStrBinaryNode* Right;
	TJclWideStrBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclWideStrBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclWideStrBinaryNode(void) { }
	
};


class DELPHICLASS TJclWideStrBinaryTree;
class PASCALIMPLEMENTATION TJclWideStrBinaryTree : public Jclabstractcontainers::TJclWideStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclWideStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclWideStrBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclWideStrBinaryNode* __fastcall BuildTree(TJclWideStrBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclWideStrBinaryNode* Parent, int Offset);
	TJclWideStrBinaryNode* __fastcall CloneNode(TJclWideStrBinaryNode* Node, TJclWideStrBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclWideStrBinaryTree(Jclcontainerintf::TWideStrCompare ACompare);
	__fastcall virtual ~TJclWideStrBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclWideStrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclWideStrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclWideStrTree;	/* Jclcontainerintf::IJclWideStrTree */
	void *__IJclWideStrComparer;	/* Jclcontainerintf::IJclWideStrComparer */
	void *__IJclWideStrEqualityComparer;	/* Jclcontainerintf::IJclWideStrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrTree; }
	#endif
	
};


class DELPHICLASS TJclWideStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclWideStrBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclWideStrBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclWideStrCollection FOwnTree;
	Jclcontainerintf::_di_IJclWideStrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclWideStrBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclWideStrBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclWideStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclWideStrCollection AOwnTree, TJclWideStrBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	System::WideString __fastcall Left(void);
	System::WideString __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclWideStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclWideStrBinaryTreeIterator;	/* Jclcontainerintf::IJclWideStrBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrBinaryTreeIterator*(void) { return (IJclWideStrBinaryTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTreeIterator*(void) { return (IJclWideStrTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderWideStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderWideStrBinaryTreeIterator : public TJclWideStrBinaryTreeIterator
{
	typedef TJclWideStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclWideStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclWideStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclWideStrBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderWideStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclWideStrCollection AOwnTree, TJclWideStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclWideStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderWideStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclWideStrBinaryTreeIterator;	/* Jclcontainerintf::IJclWideStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrBinaryTreeIterator*(void) { return (IJclWideStrBinaryTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTreeIterator*(void) { return (IJclWideStrTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderWideStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderWideStrBinaryTreeIterator : public TJclWideStrBinaryTreeIterator
{
	typedef TJclWideStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclWideStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclWideStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclWideStrBinaryTreeIterator.Create */ inline __fastcall TJclInOrderWideStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclWideStrCollection AOwnTree, TJclWideStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclWideStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderWideStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclWideStrBinaryTreeIterator;	/* Jclcontainerintf::IJclWideStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrBinaryTreeIterator*(void) { return (IJclWideStrBinaryTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTreeIterator*(void) { return (IJclWideStrTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderWideStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderWideStrBinaryTreeIterator : public TJclWideStrBinaryTreeIterator
{
	typedef TJclWideStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclWideStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclWideStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclWideStrBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderWideStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclWideStrCollection AOwnTree, TJclWideStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclWideStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderWideStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclWideStrBinaryTreeIterator;	/* Jclcontainerintf::IJclWideStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrBinaryTreeIterator*(void) { return (IJclWideStrBinaryTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclWideStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrTreeIterator*(void) { return (IJclWideStrTreeIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclWideStrIterator()
	{
		Jclcontainerintf::_di_IJclWideStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWideStrIterator*(void) { return (IJclWideStrIterator*)&__IJclWideStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrBinaryNode;
class PASCALIMPLEMENTATION TJclUnicodeStrBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::UnicodeString Value;
	TJclUnicodeStrBinaryNode* Left;
	TJclUnicodeStrBinaryNode* Right;
	TJclUnicodeStrBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclUnicodeStrBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclUnicodeStrBinaryNode(void) { }
	
};


class DELPHICLASS TJclUnicodeStrBinaryTree;
class PASCALIMPLEMENTATION TJclUnicodeStrBinaryTree : public Jclabstractcontainers::TJclUnicodeStrAbstractCollection
{
	typedef Jclabstractcontainers::TJclUnicodeStrAbstractCollection inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclUnicodeStrBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclUnicodeStrBinaryNode* __fastcall BuildTree(TJclUnicodeStrBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclUnicodeStrBinaryNode* Parent, int Offset);
	TJclUnicodeStrBinaryNode* __fastcall CloneNode(TJclUnicodeStrBinaryNode* Node, TJclUnicodeStrBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclUnicodeStrBinaryTree(Jclcontainerintf::TUnicodeStrCompare ACompare);
	__fastcall virtual ~TJclUnicodeStrBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclUnicodeStrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclUnicodeStrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclUnicodeStrTree;	/* Jclcontainerintf::IJclUnicodeStrTree */
	void *__IJclUnicodeStrComparer;	/* Jclcontainerintf::IJclUnicodeStrComparer */
	void *__IJclUnicodeStrEqualityComparer;	/* Jclcontainerintf::IJclUnicodeStrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrTree; }
	#endif
	
};


class DELPHICLASS TJclUnicodeStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclUnicodeStrBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclUnicodeStrBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclUnicodeStrCollection FOwnTree;
	Jclcontainerintf::_di_IJclUnicodeStrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclUnicodeStrBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclUnicodeStrBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclUnicodeStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclUnicodeStrCollection AOwnTree, TJclUnicodeStrBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	System::UnicodeString __fastcall Left(void);
	System::UnicodeString __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclUnicodeStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclUnicodeStrBinaryTreeIterator;	/* Jclcontainerintf::IJclUnicodeStrBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrBinaryTreeIterator*(void) { return (IJclUnicodeStrBinaryTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTreeIterator*(void) { return (IJclUnicodeStrTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderUnicodeStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderUnicodeStrBinaryTreeIterator : public TJclUnicodeStrBinaryTreeIterator
{
	typedef TJclUnicodeStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclUnicodeStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclUnicodeStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclUnicodeStrBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderUnicodeStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclUnicodeStrCollection AOwnTree, TJclUnicodeStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclUnicodeStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderUnicodeStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclUnicodeStrBinaryTreeIterator;	/* Jclcontainerintf::IJclUnicodeStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrBinaryTreeIterator*(void) { return (IJclUnicodeStrBinaryTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTreeIterator*(void) { return (IJclUnicodeStrTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderUnicodeStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderUnicodeStrBinaryTreeIterator : public TJclUnicodeStrBinaryTreeIterator
{
	typedef TJclUnicodeStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclUnicodeStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclUnicodeStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclUnicodeStrBinaryTreeIterator.Create */ inline __fastcall TJclInOrderUnicodeStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclUnicodeStrCollection AOwnTree, TJclUnicodeStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclUnicodeStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderUnicodeStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclUnicodeStrBinaryTreeIterator;	/* Jclcontainerintf::IJclUnicodeStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrBinaryTreeIterator*(void) { return (IJclUnicodeStrBinaryTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTreeIterator*(void) { return (IJclUnicodeStrTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderUnicodeStrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderUnicodeStrBinaryTreeIterator : public TJclUnicodeStrBinaryTreeIterator
{
	typedef TJclUnicodeStrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclUnicodeStrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclUnicodeStrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclUnicodeStrBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderUnicodeStrBinaryTreeIterator(const Jclcontainerintf::_di_IJclUnicodeStrCollection AOwnTree, TJclUnicodeStrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclUnicodeStrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderUnicodeStrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclUnicodeStrBinaryTreeIterator;	/* Jclcontainerintf::IJclUnicodeStrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrBinaryTreeIterator*(void) { return (IJclUnicodeStrBinaryTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrTreeIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrTreeIterator*(void) { return (IJclUnicodeStrTreeIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclUnicodeStrIterator()
	{
		Jclcontainerintf::_di_IJclUnicodeStrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclUnicodeStrIterator*(void) { return (IJclUnicodeStrIterator*)&__IJclUnicodeStrBinaryTreeIterator; }
	#endif
	
};


typedef TJclUnicodeStrBinaryNode TJclStrBinaryNode;

typedef TJclUnicodeStrBinaryTree TJclStrBinaryTree;

typedef TJclUnicodeStrBinaryTreeIterator TJclStrBinaryTreeIterator;

typedef TJclPreOrderUnicodeStrBinaryTreeIterator TJclPreOrderStrBinaryTreeIterator;

typedef TJclInOrderUnicodeStrBinaryTreeIterator TJclInOrderStrBinaryTreeIterator;

typedef TJclPostOrderUnicodeStrBinaryTreeIterator TJclPostOrderStrBinaryTreeIterator;

class DELPHICLASS TJclSingleBinaryNode;
class PASCALIMPLEMENTATION TJclSingleBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	float Value;
	TJclSingleBinaryNode* Left;
	TJclSingleBinaryNode* Right;
	TJclSingleBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclSingleBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSingleBinaryNode(void) { }
	
};


class DELPHICLASS TJclSingleBinaryTree;
class PASCALIMPLEMENTATION TJclSingleBinaryTree : public Jclabstractcontainers::TJclSingleAbstractContainer
{
	typedef Jclabstractcontainers::TJclSingleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclSingleBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclSingleBinaryNode* __fastcall BuildTree(TJclSingleBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclSingleBinaryNode* Parent, int Offset);
	TJclSingleBinaryNode* __fastcall CloneNode(TJclSingleBinaryNode* Node, TJclSingleBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclSingleBinaryTree(Jclcontainerintf::TSingleCompare ACompare);
	__fastcall virtual ~TJclSingleBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclSingleTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclSingleTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclSingleTree;	/* Jclcontainerintf::IJclSingleTree */
	void *__IJclSingleComparer;	/* Jclcontainerintf::IJclSingleComparer */
	void *__IJclSingleEqualityComparer;	/* Jclcontainerintf::IJclSingleEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclSingleContainer*(void) { return (IJclSingleContainer*)&__IJclSingleTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleTree; }
	#endif
	
};


class DELPHICLASS TJclSingleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclSingleBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclSingleBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclSingleCollection FOwnTree;
	Jclcontainerintf::_di_IJclSingleEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclSingleBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclSingleBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclSingleBinaryTreeIterator(const Jclcontainerintf::_di_IJclSingleCollection AOwnTree, TJclSingleBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	float __fastcall Left(void);
	float __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclSingleBinaryTreeIterator(void) { }
	
private:
	void *__IJclSingleBinaryTreeIterator;	/* Jclcontainerintf::IJclSingleBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleBinaryTreeIterator*(void) { return (IJclSingleBinaryTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTreeIterator*(void) { return (IJclSingleTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderSingleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderSingleBinaryTreeIterator : public TJclSingleBinaryTreeIterator
{
	typedef TJclSingleBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclSingleBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclSingleBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclSingleBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderSingleBinaryTreeIterator(const Jclcontainerintf::_di_IJclSingleCollection AOwnTree, TJclSingleBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclSingleBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderSingleBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclSingleBinaryTreeIterator;	/* Jclcontainerintf::IJclSingleBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleBinaryTreeIterator*(void) { return (IJclSingleBinaryTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTreeIterator*(void) { return (IJclSingleTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderSingleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderSingleBinaryTreeIterator : public TJclSingleBinaryTreeIterator
{
	typedef TJclSingleBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclSingleBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclSingleBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclSingleBinaryTreeIterator.Create */ inline __fastcall TJclInOrderSingleBinaryTreeIterator(const Jclcontainerintf::_di_IJclSingleCollection AOwnTree, TJclSingleBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclSingleBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderSingleBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclSingleBinaryTreeIterator;	/* Jclcontainerintf::IJclSingleBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleBinaryTreeIterator*(void) { return (IJclSingleBinaryTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTreeIterator*(void) { return (IJclSingleTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderSingleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderSingleBinaryTreeIterator : public TJclSingleBinaryTreeIterator
{
	typedef TJclSingleBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclSingleBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclSingleBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclSingleBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderSingleBinaryTreeIterator(const Jclcontainerintf::_di_IJclSingleCollection AOwnTree, TJclSingleBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclSingleBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderSingleBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclSingleBinaryTreeIterator;	/* Jclcontainerintf::IJclSingleBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleBinaryTreeIterator*(void) { return (IJclSingleBinaryTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleTreeIterator()
	{
		Jclcontainerintf::_di_IJclSingleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleTreeIterator*(void) { return (IJclSingleTreeIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclSingleIterator()
	{
		Jclcontainerintf::_di_IJclSingleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclSingleIterator*(void) { return (IJclSingleIterator*)&__IJclSingleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclDoubleBinaryNode;
class PASCALIMPLEMENTATION TJclDoubleBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	double Value;
	TJclDoubleBinaryNode* Left;
	TJclDoubleBinaryNode* Right;
	TJclDoubleBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclDoubleBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDoubleBinaryNode(void) { }
	
};


class DELPHICLASS TJclDoubleBinaryTree;
class PASCALIMPLEMENTATION TJclDoubleBinaryTree : public Jclabstractcontainers::TJclDoubleAbstractContainer
{
	typedef Jclabstractcontainers::TJclDoubleAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclDoubleBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclDoubleBinaryNode* __fastcall BuildTree(TJclDoubleBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclDoubleBinaryNode* Parent, int Offset);
	TJclDoubleBinaryNode* __fastcall CloneNode(TJclDoubleBinaryNode* Node, TJclDoubleBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclDoubleBinaryTree(Jclcontainerintf::TDoubleCompare ACompare);
	__fastcall virtual ~TJclDoubleBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclDoubleTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclDoubleTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclDoubleTree;	/* Jclcontainerintf::IJclDoubleTree */
	void *__IJclDoubleComparer;	/* Jclcontainerintf::IJclDoubleComparer */
	void *__IJclDoubleEqualityComparer;	/* Jclcontainerintf::IJclDoubleEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclDoubleContainer*(void) { return (IJclDoubleContainer*)&__IJclDoubleTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleTree; }
	#endif
	
};


class DELPHICLASS TJclDoubleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclDoubleBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclDoubleBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclDoubleCollection FOwnTree;
	Jclcontainerintf::_di_IJclDoubleEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclDoubleBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclDoubleBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclDoubleBinaryTreeIterator(const Jclcontainerintf::_di_IJclDoubleCollection AOwnTree, TJclDoubleBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	double __fastcall Left(void);
	double __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclDoubleBinaryTreeIterator(void) { }
	
private:
	void *__IJclDoubleBinaryTreeIterator;	/* Jclcontainerintf::IJclDoubleBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleBinaryTreeIterator*(void) { return (IJclDoubleBinaryTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTreeIterator*(void) { return (IJclDoubleTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderDoubleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderDoubleBinaryTreeIterator : public TJclDoubleBinaryTreeIterator
{
	typedef TJclDoubleBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclDoubleBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclDoubleBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclDoubleBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderDoubleBinaryTreeIterator(const Jclcontainerintf::_di_IJclDoubleCollection AOwnTree, TJclDoubleBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclDoubleBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderDoubleBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclDoubleBinaryTreeIterator;	/* Jclcontainerintf::IJclDoubleBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleBinaryTreeIterator*(void) { return (IJclDoubleBinaryTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTreeIterator*(void) { return (IJclDoubleTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderDoubleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderDoubleBinaryTreeIterator : public TJclDoubleBinaryTreeIterator
{
	typedef TJclDoubleBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclDoubleBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclDoubleBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclDoubleBinaryTreeIterator.Create */ inline __fastcall TJclInOrderDoubleBinaryTreeIterator(const Jclcontainerintf::_di_IJclDoubleCollection AOwnTree, TJclDoubleBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclDoubleBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderDoubleBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclDoubleBinaryTreeIterator;	/* Jclcontainerintf::IJclDoubleBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleBinaryTreeIterator*(void) { return (IJclDoubleBinaryTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTreeIterator*(void) { return (IJclDoubleTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderDoubleBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderDoubleBinaryTreeIterator : public TJclDoubleBinaryTreeIterator
{
	typedef TJclDoubleBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclDoubleBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclDoubleBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclDoubleBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderDoubleBinaryTreeIterator(const Jclcontainerintf::_di_IJclDoubleCollection AOwnTree, TJclDoubleBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclDoubleBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderDoubleBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclDoubleBinaryTreeIterator;	/* Jclcontainerintf::IJclDoubleBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleBinaryTreeIterator*(void) { return (IJclDoubleBinaryTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleTreeIterator()
	{
		Jclcontainerintf::_di_IJclDoubleTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleTreeIterator*(void) { return (IJclDoubleTreeIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclDoubleIterator()
	{
		Jclcontainerintf::_di_IJclDoubleIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclDoubleIterator*(void) { return (IJclDoubleIterator*)&__IJclDoubleBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclExtendedBinaryNode;
class PASCALIMPLEMENTATION TJclExtendedBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::Extended Value;
	TJclExtendedBinaryNode* Left;
	TJclExtendedBinaryNode* Right;
	TJclExtendedBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclExtendedBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclExtendedBinaryNode(void) { }
	
};


class DELPHICLASS TJclExtendedBinaryTree;
class PASCALIMPLEMENTATION TJclExtendedBinaryTree : public Jclabstractcontainers::TJclExtendedAbstractContainer
{
	typedef Jclabstractcontainers::TJclExtendedAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclExtendedBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclExtendedBinaryNode* __fastcall BuildTree(TJclExtendedBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclExtendedBinaryNode* Parent, int Offset);
	TJclExtendedBinaryNode* __fastcall CloneNode(TJclExtendedBinaryNode* Node, TJclExtendedBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclExtendedBinaryTree(Jclcontainerintf::TExtendedCompare ACompare);
	__fastcall virtual ~TJclExtendedBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclExtendedTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclExtendedTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclExtendedTree;	/* Jclcontainerintf::IJclExtendedTree */
	void *__IJclExtendedComparer;	/* Jclcontainerintf::IJclExtendedComparer */
	void *__IJclExtendedEqualityComparer;	/* Jclcontainerintf::IJclExtendedEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclExtendedContainer*(void) { return (IJclExtendedContainer*)&__IJclExtendedTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedTree; }
	#endif
	
};


class DELPHICLASS TJclExtendedBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclExtendedBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclExtendedBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclExtendedCollection FOwnTree;
	Jclcontainerintf::_di_IJclExtendedEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclExtendedBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclExtendedBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclExtendedBinaryTreeIterator(const Jclcontainerintf::_di_IJclExtendedCollection AOwnTree, TJclExtendedBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	System::Extended __fastcall Left(void);
	System::Extended __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclExtendedBinaryTreeIterator(void) { }
	
private:
	void *__IJclExtendedBinaryTreeIterator;	/* Jclcontainerintf::IJclExtendedBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedBinaryTreeIterator*(void) { return (IJclExtendedBinaryTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTreeIterator*(void) { return (IJclExtendedTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderExtendedBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderExtendedBinaryTreeIterator : public TJclExtendedBinaryTreeIterator
{
	typedef TJclExtendedBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclExtendedBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclExtendedBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclExtendedBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderExtendedBinaryTreeIterator(const Jclcontainerintf::_di_IJclExtendedCollection AOwnTree, TJclExtendedBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclExtendedBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderExtendedBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclExtendedBinaryTreeIterator;	/* Jclcontainerintf::IJclExtendedBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedBinaryTreeIterator*(void) { return (IJclExtendedBinaryTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTreeIterator*(void) { return (IJclExtendedTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderExtendedBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderExtendedBinaryTreeIterator : public TJclExtendedBinaryTreeIterator
{
	typedef TJclExtendedBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclExtendedBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclExtendedBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclExtendedBinaryTreeIterator.Create */ inline __fastcall TJclInOrderExtendedBinaryTreeIterator(const Jclcontainerintf::_di_IJclExtendedCollection AOwnTree, TJclExtendedBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclExtendedBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderExtendedBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclExtendedBinaryTreeIterator;	/* Jclcontainerintf::IJclExtendedBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedBinaryTreeIterator*(void) { return (IJclExtendedBinaryTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTreeIterator*(void) { return (IJclExtendedTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderExtendedBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderExtendedBinaryTreeIterator : public TJclExtendedBinaryTreeIterator
{
	typedef TJclExtendedBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclExtendedBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclExtendedBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclExtendedBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderExtendedBinaryTreeIterator(const Jclcontainerintf::_di_IJclExtendedCollection AOwnTree, TJclExtendedBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclExtendedBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderExtendedBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclExtendedBinaryTreeIterator;	/* Jclcontainerintf::IJclExtendedBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedBinaryTreeIterator*(void) { return (IJclExtendedBinaryTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedTreeIterator()
	{
		Jclcontainerintf::_di_IJclExtendedTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedTreeIterator*(void) { return (IJclExtendedTreeIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclExtendedIterator()
	{
		Jclcontainerintf::_di_IJclExtendedIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclExtendedIterator*(void) { return (IJclExtendedIterator*)&__IJclExtendedBinaryTreeIterator; }
	#endif
	
};


typedef TJclExtendedBinaryNode TJclFloatBinaryNode;

typedef TJclExtendedBinaryTree TJclFloatBinaryTree;

typedef TJclExtendedBinaryTreeIterator TJclFloatBinaryTreeIterator;

typedef TJclPreOrderExtendedBinaryTreeIterator TJclPreOrderFloatBinaryTreeIterator;

typedef TJclInOrderExtendedBinaryTreeIterator TJclInOrderFloatBinaryTreeIterator;

typedef TJclPostOrderExtendedBinaryTreeIterator TJclPostOrderFloatBinaryTreeIterator;

class DELPHICLASS TJclIntegerBinaryNode;
class PASCALIMPLEMENTATION TJclIntegerBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	int Value;
	TJclIntegerBinaryNode* Left;
	TJclIntegerBinaryNode* Right;
	TJclIntegerBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclIntegerBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIntegerBinaryNode(void) { }
	
};


class DELPHICLASS TJclIntegerBinaryTree;
class PASCALIMPLEMENTATION TJclIntegerBinaryTree : public Jclabstractcontainers::TJclIntegerAbstractContainer
{
	typedef Jclabstractcontainers::TJclIntegerAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclIntegerBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclIntegerBinaryNode* __fastcall BuildTree(TJclIntegerBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclIntegerBinaryNode* Parent, int Offset);
	TJclIntegerBinaryNode* __fastcall CloneNode(TJclIntegerBinaryNode* Node, TJclIntegerBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclIntegerBinaryTree(Jclcontainerintf::TIntegerCompare ACompare);
	__fastcall virtual ~TJclIntegerBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclIntegerTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclIntegerTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclIntegerTree;	/* Jclcontainerintf::IJclIntegerTree */
	void *__IJclIntegerComparer;	/* Jclcontainerintf::IJclIntegerComparer */
	void *__IJclIntegerEqualityComparer;	/* Jclcontainerintf::IJclIntegerEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclIntegerTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerTree; }
	#endif
	
};


class DELPHICLASS TJclIntegerBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclIntegerBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclIntegerBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclIntegerCollection FOwnTree;
	Jclcontainerintf::_di_IJclIntegerEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclIntegerBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclIntegerBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclIntegerBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntegerCollection AOwnTree, TJclIntegerBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	int __fastcall Left(void);
	int __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclIntegerBinaryTreeIterator(void) { }
	
private:
	void *__IJclIntegerBinaryTreeIterator;	/* Jclcontainerintf::IJclIntegerBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerBinaryTreeIterator*(void) { return (IJclIntegerBinaryTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTreeIterator*(void) { return (IJclIntegerTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderIntegerBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderIntegerBinaryTreeIterator : public TJclIntegerBinaryTreeIterator
{
	typedef TJclIntegerBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntegerBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclIntegerBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntegerBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderIntegerBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntegerCollection AOwnTree, TJclIntegerBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclIntegerBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderIntegerBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntegerBinaryTreeIterator;	/* Jclcontainerintf::IJclIntegerBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerBinaryTreeIterator*(void) { return (IJclIntegerBinaryTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTreeIterator*(void) { return (IJclIntegerTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderIntegerBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderIntegerBinaryTreeIterator : public TJclIntegerBinaryTreeIterator
{
	typedef TJclIntegerBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntegerBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclIntegerBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntegerBinaryTreeIterator.Create */ inline __fastcall TJclInOrderIntegerBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntegerCollection AOwnTree, TJclIntegerBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclIntegerBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderIntegerBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntegerBinaryTreeIterator;	/* Jclcontainerintf::IJclIntegerBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerBinaryTreeIterator*(void) { return (IJclIntegerBinaryTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTreeIterator*(void) { return (IJclIntegerTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderIntegerBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderIntegerBinaryTreeIterator : public TJclIntegerBinaryTreeIterator
{
	typedef TJclIntegerBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclIntegerBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclIntegerBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclIntegerBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderIntegerBinaryTreeIterator(const Jclcontainerintf::_di_IJclIntegerCollection AOwnTree, TJclIntegerBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclIntegerBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderIntegerBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclIntegerBinaryTreeIterator;	/* Jclcontainerintf::IJclIntegerBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerBinaryTreeIterator*(void) { return (IJclIntegerBinaryTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerTreeIterator()
	{
		Jclcontainerintf::_di_IJclIntegerTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerTreeIterator*(void) { return (IJclIntegerTreeIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIntegerIterator()
	{
		Jclcontainerintf::_di_IJclIntegerIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIntegerIterator*(void) { return (IJclIntegerIterator*)&__IJclIntegerBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclCardinalBinaryNode;
class PASCALIMPLEMENTATION TJclCardinalBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	unsigned Value;
	TJclCardinalBinaryNode* Left;
	TJclCardinalBinaryNode* Right;
	TJclCardinalBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclCardinalBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCardinalBinaryNode(void) { }
	
};


class DELPHICLASS TJclCardinalBinaryTree;
class PASCALIMPLEMENTATION TJclCardinalBinaryTree : public Jclabstractcontainers::TJclCardinalAbstractContainer
{
	typedef Jclabstractcontainers::TJclCardinalAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclCardinalBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclCardinalBinaryNode* __fastcall BuildTree(TJclCardinalBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclCardinalBinaryNode* Parent, int Offset);
	TJclCardinalBinaryNode* __fastcall CloneNode(TJclCardinalBinaryNode* Node, TJclCardinalBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclCardinalBinaryTree(Jclcontainerintf::TCardinalCompare ACompare);
	__fastcall virtual ~TJclCardinalBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclCardinalTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclCardinalTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclCardinalTree;	/* Jclcontainerintf::IJclCardinalTree */
	void *__IJclCardinalComparer;	/* Jclcontainerintf::IJclCardinalComparer */
	void *__IJclCardinalEqualityComparer;	/* Jclcontainerintf::IJclCardinalEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclCardinalTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalTree; }
	#endif
	
};


class DELPHICLASS TJclCardinalBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclCardinalBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclCardinalBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclCardinalCollection FOwnTree;
	Jclcontainerintf::_di_IJclCardinalEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclCardinalBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclCardinalBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclCardinalBinaryTreeIterator(const Jclcontainerintf::_di_IJclCardinalCollection AOwnTree, TJclCardinalBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	unsigned __fastcall Left(void);
	unsigned __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclCardinalBinaryTreeIterator(void) { }
	
private:
	void *__IJclCardinalBinaryTreeIterator;	/* Jclcontainerintf::IJclCardinalBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalBinaryTreeIterator*(void) { return (IJclCardinalBinaryTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTreeIterator*(void) { return (IJclCardinalTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderCardinalBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderCardinalBinaryTreeIterator : public TJclCardinalBinaryTreeIterator
{
	typedef TJclCardinalBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclCardinalBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclCardinalBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclCardinalBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderCardinalBinaryTreeIterator(const Jclcontainerintf::_di_IJclCardinalCollection AOwnTree, TJclCardinalBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclCardinalBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderCardinalBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCardinalBinaryTreeIterator;	/* Jclcontainerintf::IJclCardinalBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalBinaryTreeIterator*(void) { return (IJclCardinalBinaryTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTreeIterator*(void) { return (IJclCardinalTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderCardinalBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderCardinalBinaryTreeIterator : public TJclCardinalBinaryTreeIterator
{
	typedef TJclCardinalBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclCardinalBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclCardinalBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclCardinalBinaryTreeIterator.Create */ inline __fastcall TJclInOrderCardinalBinaryTreeIterator(const Jclcontainerintf::_di_IJclCardinalCollection AOwnTree, TJclCardinalBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclCardinalBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderCardinalBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCardinalBinaryTreeIterator;	/* Jclcontainerintf::IJclCardinalBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalBinaryTreeIterator*(void) { return (IJclCardinalBinaryTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTreeIterator*(void) { return (IJclCardinalTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderCardinalBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderCardinalBinaryTreeIterator : public TJclCardinalBinaryTreeIterator
{
	typedef TJclCardinalBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclCardinalBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclCardinalBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclCardinalBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderCardinalBinaryTreeIterator(const Jclcontainerintf::_di_IJclCardinalCollection AOwnTree, TJclCardinalBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclCardinalBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderCardinalBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclCardinalBinaryTreeIterator;	/* Jclcontainerintf::IJclCardinalBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalBinaryTreeIterator*(void) { return (IJclCardinalBinaryTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalTreeIterator()
	{
		Jclcontainerintf::_di_IJclCardinalTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalTreeIterator*(void) { return (IJclCardinalTreeIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclCardinalIterator()
	{
		Jclcontainerintf::_di_IJclCardinalIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCardinalIterator*(void) { return (IJclCardinalIterator*)&__IJclCardinalBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInt64BinaryNode;
class PASCALIMPLEMENTATION TJclInt64BinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__int64 Value;
	TJclInt64BinaryNode* Left;
	TJclInt64BinaryNode* Right;
	TJclInt64BinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclInt64BinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInt64BinaryNode(void) { }
	
};


class DELPHICLASS TJclInt64BinaryTree;
class PASCALIMPLEMENTATION TJclInt64BinaryTree : public Jclabstractcontainers::TJclInt64AbstractContainer
{
	typedef Jclabstractcontainers::TJclInt64AbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclInt64BinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclInt64BinaryNode* __fastcall BuildTree(TJclInt64BinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclInt64BinaryNode* Parent, int Offset);
	TJclInt64BinaryNode* __fastcall CloneNode(TJclInt64BinaryNode* Node, TJclInt64BinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclInt64BinaryTree(Jclcontainerintf::TInt64Compare ACompare);
	__fastcall virtual ~TJclInt64BinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclInt64TreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclInt64TreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclInt64Tree;	/* Jclcontainerintf::IJclInt64Tree */
	void *__IJclInt64Comparer;	/* Jclcontainerintf::IJclInt64Comparer */
	void *__IJclInt64EqualityComparer;	/* Jclcontainerintf::IJclInt64EqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclInt64Tree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64Tree; }
	#endif
	
};


class DELPHICLASS TJclInt64BinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInt64BinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclInt64BinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclInt64Collection FOwnTree;
	Jclcontainerintf::_di_IJclInt64EqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclInt64BinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclInt64BinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclInt64BinaryTreeIterator(const Jclcontainerintf::_di_IJclInt64Collection AOwnTree, TJclInt64BinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	__int64 __fastcall Left(void);
	__int64 __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInt64BinaryTreeIterator(void) { }
	
private:
	void *__IJclInt64BinaryTreeIterator;	/* Jclcontainerintf::IJclInt64BinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64BinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64BinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64BinaryTreeIterator*(void) { return (IJclInt64BinaryTreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64TreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64TreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TreeIterator*(void) { return (IJclInt64TreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderInt64BinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderInt64BinaryTreeIterator : public TJclInt64BinaryTreeIterator
{
	typedef TJclInt64BinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclInt64BinaryNode* __fastcall GetNextCursor(void);
	virtual TJclInt64BinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclInt64BinaryTreeIterator.Create */ inline __fastcall TJclPreOrderInt64BinaryTreeIterator(const Jclcontainerintf::_di_IJclInt64Collection AOwnTree, TJclInt64BinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclInt64BinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderInt64BinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclInt64BinaryTreeIterator;	/* Jclcontainerintf::IJclInt64BinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64BinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64BinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64BinaryTreeIterator*(void) { return (IJclInt64BinaryTreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64TreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64TreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TreeIterator*(void) { return (IJclInt64TreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderInt64BinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderInt64BinaryTreeIterator : public TJclInt64BinaryTreeIterator
{
	typedef TJclInt64BinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclInt64BinaryNode* __fastcall GetNextCursor(void);
	virtual TJclInt64BinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclInt64BinaryTreeIterator.Create */ inline __fastcall TJclInOrderInt64BinaryTreeIterator(const Jclcontainerintf::_di_IJclInt64Collection AOwnTree, TJclInt64BinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclInt64BinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderInt64BinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclInt64BinaryTreeIterator;	/* Jclcontainerintf::IJclInt64BinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64BinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64BinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64BinaryTreeIterator*(void) { return (IJclInt64BinaryTreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64TreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64TreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TreeIterator*(void) { return (IJclInt64TreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderInt64BinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderInt64BinaryTreeIterator : public TJclInt64BinaryTreeIterator
{
	typedef TJclInt64BinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclInt64BinaryNode* __fastcall GetNextCursor(void);
	virtual TJclInt64BinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclInt64BinaryTreeIterator.Create */ inline __fastcall TJclPostOrderInt64BinaryTreeIterator(const Jclcontainerintf::_di_IJclInt64Collection AOwnTree, TJclInt64BinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclInt64BinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderInt64BinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclInt64BinaryTreeIterator;	/* Jclcontainerintf::IJclInt64BinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64BinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64BinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64BinaryTreeIterator*(void) { return (IJclInt64BinaryTreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64TreeIterator()
	{
		Jclcontainerintf::_di_IJclInt64TreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64TreeIterator*(void) { return (IJclInt64TreeIterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclInt64Iterator()
	{
		Jclcontainerintf::_di_IJclInt64Iterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclInt64Iterator*(void) { return (IJclInt64Iterator*)&__IJclInt64BinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPtrBinaryNode;
class PASCALIMPLEMENTATION TJclPtrBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	void *Value;
	TJclPtrBinaryNode* Left;
	TJclPtrBinaryNode* Right;
	TJclPtrBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclPtrBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclPtrBinaryNode(void) { }
	
};


class DELPHICLASS TJclPtrBinaryTree;
class PASCALIMPLEMENTATION TJclPtrBinaryTree : public Jclabstractcontainers::TJclPtrAbstractContainer
{
	typedef Jclabstractcontainers::TJclPtrAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclPtrBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclPtrBinaryNode* __fastcall BuildTree(TJclPtrBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclPtrBinaryNode* Parent, int Offset);
	TJclPtrBinaryNode* __fastcall CloneNode(TJclPtrBinaryNode* Node, TJclPtrBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclPtrBinaryTree(Jclcontainerintf::TPtrCompare ACompare);
	__fastcall virtual ~TJclPtrBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclPtrTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclPtrTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclPtrTree;	/* Jclcontainerintf::IJclPtrTree */
	void *__IJclPtrComparer;	/* Jclcontainerintf::IJclPtrComparer */
	void *__IJclPtrEqualityComparer;	/* Jclcontainerintf::IJclPtrEqualityComparer */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclPtrTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrTree; }
	#endif
	
};


class DELPHICLASS TJclPtrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPtrBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclPtrBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclPtrCollection FOwnTree;
	Jclcontainerintf::_di_IJclPtrEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclPtrBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclPtrBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclPtrBinaryTreeIterator(const Jclcontainerintf::_di_IJclPtrCollection AOwnTree, TJclPtrBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	void * __fastcall Left(void);
	void * __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPtrBinaryTreeIterator(void) { }
	
private:
	void *__IJclPtrBinaryTreeIterator;	/* Jclcontainerintf::IJclPtrBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrBinaryTreeIterator*(void) { return (IJclPtrBinaryTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTreeIterator*(void) { return (IJclPtrTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderPtrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderPtrBinaryTreeIterator : public TJclPtrBinaryTreeIterator
{
	typedef TJclPtrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclPtrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclPtrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclPtrBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderPtrBinaryTreeIterator(const Jclcontainerintf::_di_IJclPtrCollection AOwnTree, TJclPtrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclPtrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderPtrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclPtrBinaryTreeIterator;	/* Jclcontainerintf::IJclPtrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrBinaryTreeIterator*(void) { return (IJclPtrBinaryTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTreeIterator*(void) { return (IJclPtrTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderPtrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderPtrBinaryTreeIterator : public TJclPtrBinaryTreeIterator
{
	typedef TJclPtrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclPtrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclPtrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclPtrBinaryTreeIterator.Create */ inline __fastcall TJclInOrderPtrBinaryTreeIterator(const Jclcontainerintf::_di_IJclPtrCollection AOwnTree, TJclPtrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclPtrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderPtrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclPtrBinaryTreeIterator;	/* Jclcontainerintf::IJclPtrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrBinaryTreeIterator*(void) { return (IJclPtrBinaryTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTreeIterator*(void) { return (IJclPtrTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderPtrBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderPtrBinaryTreeIterator : public TJclPtrBinaryTreeIterator
{
	typedef TJclPtrBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclPtrBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclPtrBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclPtrBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderPtrBinaryTreeIterator(const Jclcontainerintf::_di_IJclPtrCollection AOwnTree, TJclPtrBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclPtrBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderPtrBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclPtrBinaryTreeIterator;	/* Jclcontainerintf::IJclPtrBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrBinaryTreeIterator*(void) { return (IJclPtrBinaryTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrTreeIterator()
	{
		Jclcontainerintf::_di_IJclPtrTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrTreeIterator*(void) { return (IJclPtrTreeIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclPtrIterator()
	{
		Jclcontainerintf::_di_IJclPtrIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclPtrIterator*(void) { return (IJclPtrIterator*)&__IJclPtrBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclBinaryNode;
class PASCALIMPLEMENTATION TJclBinaryNode : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::TObject* Value;
	TJclBinaryNode* Left;
	TJclBinaryNode* Right;
	TJclBinaryNode* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclBinaryNode(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryNode(void) { }
	
};


class DELPHICLASS TJclBinaryTree;
class PASCALIMPLEMENTATION TJclBinaryTree : public Jclabstractcontainers::TJclAbstractContainer
{
	typedef Jclabstractcontainers::TJclAbstractContainer inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
private:
	int FMaxDepth;
	TJclBinaryNode* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclBinaryNode* __fastcall BuildTree(TJclBinaryNode* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclBinaryNode* Parent, int Offset);
	TJclBinaryNode* __fastcall CloneNode(TJclBinaryNode* Node, TJclBinaryNode* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclBinaryTree(Jclcontainerintf::TCompare ACompare, bool AOwnsObjects);
	__fastcall virtual ~TJclBinaryTree(void);
	virtual void __fastcall Pack(void);
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
	Jclcontainerintf::_di_IJclTreeIterator __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property Jclcontainerintf::_di_IJclTreeIterator Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclTree;	/* Jclcontainerintf::IJclTree */
	void *__IJclComparer;	/* Jclcontainerintf::IJclComparer */
	void *__IJclEqualityComparer;	/* Jclcontainerintf::IJclEqualityComparer */
	void *__IJclObjectOwner;	/* Jclcontainerintf::IJclObjectOwner */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclTree; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTree; }
	#endif
	
};


class DELPHICLASS TJclBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclBinaryTreeIterator : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclBinaryNode* FCursor;
	TItrStart FStart;
	Jclcontainerintf::_di_IJclCollection FOwnTree;
	Jclcontainerintf::_di_IJclEqualityComparer FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclBinaryNode* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclBinaryNode* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclBinaryTreeIterator(const Jclcontainerintf::_di_IJclCollection AOwnTree, TJclBinaryNode* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	System::TObject* __fastcall Left(void);
	System::TObject* __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclBinaryTreeIterator(void) { }
	
private:
	void *__IJclBinaryTreeIterator;	/* Jclcontainerintf::IJclBinaryTreeIterator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator*(void) { return (IJclBinaryTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTreeIterator()
	{
		Jclcontainerintf::_di_IJclTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator*(void) { return (IJclTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPreOrderBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPreOrderBinaryTreeIterator : public TJclBinaryTreeIterator
{
	typedef TJclBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclBinaryTreeIterator.Create */ inline __fastcall TJclPreOrderBinaryTreeIterator(const Jclcontainerintf::_di_IJclCollection AOwnTree, TJclBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclBinaryTreeIterator;	/* Jclcontainerintf::IJclBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator*(void) { return (IJclBinaryTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTreeIterator()
	{
		Jclcontainerintf::_di_IJclTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator*(void) { return (IJclTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclInOrderBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclInOrderBinaryTreeIterator : public TJclBinaryTreeIterator
{
	typedef TJclBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclBinaryTreeIterator.Create */ inline __fastcall TJclInOrderBinaryTreeIterator(const Jclcontainerintf::_di_IJclCollection AOwnTree, TJclBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclBinaryTreeIterator;	/* Jclcontainerintf::IJclBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator*(void) { return (IJclBinaryTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTreeIterator()
	{
		Jclcontainerintf::_di_IJclTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator*(void) { return (IJclTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclBinaryTreeIterator; }
	#endif
	
};


class DELPHICLASS TJclPostOrderBinaryTreeIterator;
class PASCALIMPLEMENTATION TJclPostOrderBinaryTreeIterator : public TJclBinaryTreeIterator
{
	typedef TJclBinaryTreeIterator inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclBinaryNode* __fastcall GetNextCursor(void);
	virtual TJclBinaryNode* __fastcall GetPreviousCursor(void);
public:
	/* TJclBinaryTreeIterator.Create */ inline __fastcall TJclPostOrderBinaryTreeIterator(const Jclcontainerintf::_di_IJclCollection AOwnTree, TJclBinaryNode* ACursor, bool AValid, TItrStart AStart) : TJclBinaryTreeIterator(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderBinaryTreeIterator(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclBinaryTreeIterator;	/* Jclcontainerintf::IJclBinaryTreeIterator */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclBinaryTreeIterator()
	{
		Jclcontainerintf::_di_IJclBinaryTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator*(void) { return (IJclBinaryTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclTreeIterator()
	{
		Jclcontainerintf::_di_IJclTreeIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator*(void) { return (IJclTreeIterator*)&__IJclBinaryTreeIterator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclcontainerintf::_di_IJclIterator()
	{
		Jclcontainerintf::_di_IJclIterator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator*(void) { return (IJclIterator*)&__IJclBinaryTreeIterator; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclBinaryNode__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclBinaryNode__1 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	T Value;
	TJclBinaryNode__1<T>* Left;
	TJclBinaryNode__1<T>* Right;
	TJclBinaryNode__1<T>* Parent;
public:
	/* TObject.Create */ inline __fastcall TJclBinaryNode__1(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryNode__1(void) { }
	
};


template<typename T> class DELPHICLASS TJclBinaryTree__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclBinaryTree__1 : public Jclabstractcontainers::TJclAbstractContainer__1<T>
{
	typedef Jclabstractcontainers::TJclAbstractContainer__1<T> inherited;
	
protected:
	
private:
	int FMaxDepth;
	TJclBinaryNode__1<T>* FRoot;
	Jclcontainerintf::TJclTraverseOrder FTraverseOrder;
	TJclBinaryNode__1<T>* __fastcall BuildTree(TJclBinaryNode__1<T>* const *LeafArray, const int LeafArray_Size, int Left, int Right, TJclBinaryNode__1<T>* Parent, int Offset);
	TJclBinaryNode__1<T>* __fastcall CloneNode(TJclBinaryNode__1<T>* Node, TJclBinaryNode__1<T>* Parent);
	
protected:
	virtual void __fastcall AssignDataTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual void __fastcall AutoPack(void);
	
public:
	__fastcall TJclBinaryTree__1(bool AOwnsItems);
	__fastcall virtual ~TJclBinaryTree__1(void);
	virtual void __fastcall Pack(void);
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
	System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >  __fastcall GetRoot(void);
	Jclcontainerintf::TJclTraverseOrder __fastcall GetTraverseOrder(void);
	void __fastcall SetTraverseOrder(Jclcontainerintf::TJclTraverseOrder Value);
	__property System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >  Root = {read=GetRoot};
	__property Jclcontainerintf::TJclTraverseOrder TraverseOrder = {read=GetTraverseOrder, write=SetTraverseOrder, nodefault};
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
	void *__IJclEqualityComparer__1;	/* Jclcontainerintf::IJclEqualityComparer__1<T> */
	void *__IJclItemOwner__1;	/* Jclcontainerintf::IJclItemOwner__1<T> */
	void *__IJclPackable;	/* Jclcontainerintf::IJclPackable */
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
	operator IJclBaseContainer*(void) { return (IJclBaseContainer*)&__IJclTree__1; }
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclTree__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclBinaryTreeIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclBinaryTreeIterator__1 : public Jclabstractcontainers::TJclAbstractIterator
{
	typedef Jclabstractcontainers::TJclAbstractIterator inherited;
	
protected:
	TJclBinaryNode__1<T>* FCursor;
	TItrStart FStart;
	System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  FOwnTree;
	System::DelphiInterface<Jclcontainerintf::IJclEqualityComparer__1<T> >  FEqualityComparer;
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractIterator* Dest);
	virtual TJclBinaryNode__1<T>* __fastcall GetNextCursor(void) = 0 ;
	virtual TJclBinaryNode__1<T>* __fastcall GetPreviousCursor(void) = 0 ;
	
public:
	__fastcall TJclBinaryTreeIterator__1(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  AOwnTree, TJclBinaryNode__1<T>* ACursor, bool AValid, TItrStart AStart);
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
	bool __fastcall HasLeft(void);
	bool __fastcall HasRight(void);
	T __fastcall Left(void);
	T __fastcall Right(void);
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclBinaryTreeIterator__1(void) { }
	
private:
	void *__IJclBinaryTreeIterator__1;	/* Jclcontainerintf::IJclBinaryTreeIterator__1<T> */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator__1<T>*(void) { return (IJclBinaryTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator__1<T>*(void) { return (IJclTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclPreOrderBinaryTreeIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclPreOrderBinaryTreeIterator__1 : public TJclBinaryTreeIterator__1<T>
{
	typedef TJclBinaryTreeIterator__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclBinaryNode__1<T>* __fastcall GetNextCursor(void);
	virtual TJclBinaryNode__1<T>* __fastcall GetPreviousCursor(void);
public:
	/* TJclBinaryTreeIterator<T>.Create */ inline __fastcall TJclPreOrderBinaryTreeIterator__1(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  AOwnTree, TJclBinaryNode__1<T>* ACursor, bool AValid, TItrStart AStart) : TJclBinaryTreeIterator__1<T>(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPreOrderBinaryTreeIterator__1(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclBinaryTreeIterator__1;	/* Jclcontainerintf::IJclBinaryTreeIterator__1<T> */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator__1<T>*(void) { return (IJclBinaryTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator__1<T>*(void) { return (IJclTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclInOrderBinaryTreeIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclInOrderBinaryTreeIterator__1 : public TJclBinaryTreeIterator__1<T>
{
	typedef TJclBinaryTreeIterator__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclBinaryNode__1<T>* __fastcall GetNextCursor(void);
	virtual TJclBinaryNode__1<T>* __fastcall GetPreviousCursor(void);
public:
	/* TJclBinaryTreeIterator<T>.Create */ inline __fastcall TJclInOrderBinaryTreeIterator__1(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  AOwnTree, TJclBinaryNode__1<T>* ACursor, bool AValid, TItrStart AStart) : TJclBinaryTreeIterator__1<T>(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclInOrderBinaryTreeIterator__1(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclBinaryTreeIterator__1;	/* Jclcontainerintf::IJclBinaryTreeIterator__1<T> */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator__1<T>*(void) { return (IJclBinaryTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator__1<T>*(void) { return (IJclTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclPostOrderBinaryTreeIterator__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclPostOrderBinaryTreeIterator__1 : public TJclBinaryTreeIterator__1<T>
{
	typedef TJclBinaryTreeIterator__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractIterator* __fastcall CreateEmptyIterator(void);
	virtual TJclBinaryNode__1<T>* __fastcall GetNextCursor(void);
	virtual TJclBinaryNode__1<T>* __fastcall GetPreviousCursor(void);
public:
	/* TJclBinaryTreeIterator<T>.Create */ inline __fastcall TJclPostOrderBinaryTreeIterator__1(const System::DelphiInterface<Jclcontainerintf::IJclCollection__1<T> >  AOwnTree, TJclBinaryNode__1<T>* ACursor, bool AValid, TItrStart AStart) : TJclBinaryTreeIterator__1<T>(AOwnTree, ACursor, AValid, AStart) { }
	
public:
	/* TJclAbstractLockable.Destroy */ inline __fastcall virtual ~TJclPostOrderBinaryTreeIterator__1(void) { }
	
private:
	void *__IJclCloneable;	/* Jclcontainerintf::IJclCloneable */
	void *__IJclIntfCloneable;	/* Jclcontainerintf::IJclIntfCloneable */
	void *__IJclBinaryTreeIterator__1;	/* Jclcontainerintf::IJclBinaryTreeIterator__1<T> */
	
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
	operator IJclLockable*(void) { return (IJclLockable*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclBinaryTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclBinaryTreeIterator__1<T>*(void) { return (IJclBinaryTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclTreeIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclTreeIterator__1<T>*(void) { return (IJclTreeIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> >()
	{
		System::DelphiInterface<Jclcontainerintf::IJclIterator__1<T> > intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclIterator__1<T>*(void) { return (IJclIterator__1<T>*)&__IJclBinaryTreeIterator__1; }
	#endif
	
};


template<typename T> class DELPHICLASS TJclBinaryTreeE__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclBinaryTreeE__1 : public TJclBinaryTree__1<T>
{
	typedef TJclBinaryTree__1<T> inherited;
	
private:
	System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  FComparer;
	
protected:
	virtual void __fastcall AssignPropertiesTo(Jclabstractcontainers::TJclAbstractContainerBase* Dest);
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclBinaryTreeE__1(const System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  AComparer, bool AOwnsItems);
	virtual int __fastcall ItemsCompare(const T A, const T B);
	virtual bool __fastcall ItemsEqual(const T A, const T B);
	__property System::DelphiInterface<Jclcontainerintf::IJclComparer__1<T> >  Comparer = {read=FComparer, write=FComparer};
public:
	/* TJclBinaryTree<T>.Destroy */ inline __fastcall virtual ~TJclBinaryTreeE__1(void) { }
	
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
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


template<typename T> class DELPHICLASS TJclBinaryTreeF__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclBinaryTreeF__1 : public TJclBinaryTree__1<T>
{
	typedef TJclBinaryTree__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	__fastcall TJclBinaryTreeF__1(_decl_TCompare__1(T, ACompare), bool AOwnsItems);
public:
	/* TJclBinaryTree<T>.Destroy */ inline __fastcall virtual ~TJclBinaryTreeF__1(void) { }
	
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
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


template<typename T> class DELPHICLASS TJclBinaryTreeI__1;
// Template declaration generated by Delphi parameterized types is
// used only for accessing Delphi variables and fields.
// Don't instantiate with new type parameters in user code.
template<typename T> class PASCALIMPLEMENTATION TJclBinaryTreeI__1 : public TJclBinaryTree__1<T>
{
	typedef TJclBinaryTree__1<T> inherited;
	
protected:
	virtual Jclabstractcontainers::TJclAbstractContainerBase* __fastcall CreateEmptyContainer(void);
	
public:
	virtual int __fastcall ItemsCompare(const T A, const T B);
	virtual bool __fastcall ItemsEqual(const T A, const T B);
public:
	/* TJclBinaryTree<T>.Create */ inline __fastcall TJclBinaryTreeI__1(bool AOwnsItems) : TJclBinaryTree__1<T>(AOwnsItems) { }
	/* TJclBinaryTree<T>.Destroy */ inline __fastcall virtual ~TJclBinaryTreeI__1(void) { }
	
private:
	void *__IJclTree__1;	/* Jclcontainerintf::IJclTree__1<T> */
	void *__IJclComparer__1;	/* Jclcontainerintf::IJclComparer__1<T> */
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

}	/* namespace Jclbinarytrees */
using namespace Jclbinarytrees;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclbinarytreesHPP
