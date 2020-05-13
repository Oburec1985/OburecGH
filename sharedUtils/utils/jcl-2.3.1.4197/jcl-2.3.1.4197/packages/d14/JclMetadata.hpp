// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclmetadata.pas' rev: 21.00

#ifndef JclmetadataHPP
#define JclmetadataHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclclr.hpp>	// Pascal unit
#include <Jclfileutils.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclmetadata
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TJclClrElementType { etEnd, etVoid, etBoolean, etChar, etI1, etU1, etI2, etU2, etI4, etU4, etI8, etU8, etR4, etR8, etString, etPtr, etByRef, etValueType, etClass, etArray, etTypedByRef, etI, etU, etFnPtr, etObject, etSzArray, etCModReqd, etCModOpt, etInternal, etMax, etModifier, etSentinel, etPinned };
#pragma option pop

class DELPHICLASS TJclClrTableModuleRow;
class PASCALIMPLEMENTATION TJclClrTableModuleRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	System::Word FGeneration;
	unsigned FNameOffset;
	unsigned FMvidIdx;
	unsigned FEncIdIdx;
	unsigned FEncBaseIdIdx;
	GUID __fastcall GetMvid(void);
	System::WideString __fastcall GetName(void);
	GUID __fastcall GetEncBaseId(void);
	GUID __fastcall GetEncId(void);
	
public:
	__fastcall virtual TJclClrTableModuleRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	bool __fastcall HasEncId(void);
	bool __fastcall HasEncBaseId(void);
	__property System::Word Generation = {read=FGeneration, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned MvidIdx = {read=FMvidIdx, nodefault};
	__property unsigned EncIdIdx = {read=FEncIdIdx, nodefault};
	__property unsigned EncBaseIdIdx = {read=FEncBaseIdIdx, nodefault};
	__property System::WideString Name = {read=GetName};
	__property GUID Mvid = {read=GetMvid};
	__property GUID EncId = {read=GetEncId};
	__property GUID EncBaseId = {read=GetEncBaseId};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableModuleRow(void) { }
	
};


class DELPHICLASS TJclClrTableModule;
class PASCALIMPLEMENTATION TJclClrTableModule : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableModuleRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableModuleRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableModuleRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableModule(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableModule(void) { }
	
private:
	void *__ITableCanDumpIL;	/* Jclclr::ITableCanDumpIL */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclclr::_di_ITableCanDumpIL()
	{
		Jclclr::_di_ITableCanDumpIL intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITableCanDumpIL*(void) { return (ITableCanDumpIL*)&__ITableCanDumpIL; }
	#endif
	
};


class DELPHICLASS TJclClrTableModuleRefRow;
class PASCALIMPLEMENTATION TJclClrTableModuleRefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FNameOffset;
	System::WideString __fastcall GetName(void);
	
public:
	__fastcall virtual TJclClrTableModuleRefRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property System::WideString Name = {read=GetName};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableModuleRefRow(void) { }
	
};


class DELPHICLASS TJclClrTableModuleRef;
class PASCALIMPLEMENTATION TJclClrTableModuleRef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableModuleRefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableModuleRefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableModuleRefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableModuleRef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableModuleRef(void) { }
	
private:
	void *__ITableCanDumpIL;	/* Jclclr::ITableCanDumpIL */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclclr::_di_ITableCanDumpIL()
	{
		Jclclr::_di_ITableCanDumpIL intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITableCanDumpIL*(void) { return (ITableCanDumpIL*)&__ITableCanDumpIL; }
	#endif
	
};


#pragma option push -b-
enum TJclClrAssemblyFlag { cafPublicKey, cafCompatibilityMask, cafSideBySideCompatible, cafNonSideBySideAppDomain, cafNonSideBySideProcess, cafNonSideBySideMachine, cafEnableJITcompileTracking, cafDisableJITcompileOptimizer };
#pragma option pop

typedef Set<TJclClrAssemblyFlag, cafPublicKey, cafDisableJITcompileOptimizer>  TJclClrAssemblyFlags;

class DELPHICLASS TJclClrTableAssemblyRow;
class PASCALIMPLEMENTATION TJclClrTableAssemblyRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FCultureOffset;
	unsigned FPublicKeyOffset;
	unsigned FHashAlgId;
	unsigned FNameOffset;
	System::Word FMajorVersion;
	System::Word FBuildNumber;
	System::Word FRevisionNumber;
	System::Word FMinorVersion;
	unsigned FFlagMask;
	System::WideString __fastcall GetCulture(void);
	System::WideString __fastcall GetName(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetPublicKey(void);
	System::UnicodeString __fastcall GetVersion(void);
	TJclClrAssemblyFlags __fastcall GetFlags(void);
	
public:
	__fastcall virtual TJclClrTableAssemblyRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__classmethod unsigned __fastcall AssemblyFlags(const TJclClrAssemblyFlags Flags)/* overload */;
	__classmethod TJclClrAssemblyFlags __fastcall AssemblyFlags(const unsigned Flags)/* overload */;
	__property unsigned HashAlgId = {read=FHashAlgId, nodefault};
	__property System::Word MajorVersion = {read=FMajorVersion, nodefault};
	__property System::Word MinorVersion = {read=FMinorVersion, nodefault};
	__property System::Word BuildNumber = {read=FBuildNumber, nodefault};
	__property System::Word RevisionNumber = {read=FRevisionNumber, nodefault};
	__property unsigned FlagMask = {read=FFlagMask, nodefault};
	__property unsigned PublicKeyOffset = {read=FPublicKeyOffset, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned CultureOffset = {read=FCultureOffset, nodefault};
	__property Jclclr::TJclClrBlobRecord* PublicKey = {read=GetPublicKey};
	__property System::WideString Name = {read=GetName};
	__property System::WideString Culture = {read=GetCulture};
	__property System::UnicodeString Version = {read=GetVersion};
	__property TJclClrAssemblyFlags Flags = {read=GetFlags, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyRow(void) { }
	
};


class DELPHICLASS TJclClrTableAssembly;
class PASCALIMPLEMENTATION TJclClrTableAssembly : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableAssemblyRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableAssemblyRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableAssemblyRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableAssembly(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableAssembly(void) { }
	
private:
	void *__ITableCanDumpIL;	/* Jclclr::ITableCanDumpIL */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclclr::_di_ITableCanDumpIL()
	{
		Jclclr::_di_ITableCanDumpIL intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITableCanDumpIL*(void) { return (ITableCanDumpIL*)&__ITableCanDumpIL; }
	#endif
	
};


class DELPHICLASS TJclClrTableAssemblyOSRow;
class PASCALIMPLEMENTATION TJclClrTableAssemblyOSRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FPlatformID;
	unsigned FMajorVersion;
	unsigned FMinorVersion;
	System::UnicodeString __fastcall GetVersion(void);
	
public:
	__fastcall virtual TJclClrTableAssemblyOSRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned PlatformID = {read=FPlatformID, nodefault};
	__property unsigned MajorVersion = {read=FMajorVersion, nodefault};
	__property unsigned MinorVersion = {read=FMinorVersion, nodefault};
	__property System::UnicodeString Version = {read=GetVersion};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyOSRow(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyOS;
class PASCALIMPLEMENTATION TJclClrTableAssemblyOS : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableAssemblyOSRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableAssemblyOSRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableAssemblyOSRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableAssemblyOS(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyOS(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyProcessorRow;
class PASCALIMPLEMENTATION TJclClrTableAssemblyProcessorRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FProcessor;
	
public:
	__fastcall virtual TJclClrTableAssemblyProcessorRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned Processor = {read=FProcessor, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyProcessorRow(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyProcessor;
class PASCALIMPLEMENTATION TJclClrTableAssemblyProcessor : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableAssemblyProcessorRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableAssemblyProcessorRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableAssemblyProcessorRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableAssemblyProcessor(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyProcessor(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyRefRow;
class PASCALIMPLEMENTATION TJclClrTableAssemblyRefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FCultureOffset;
	unsigned FNameOffset;
	unsigned FPublicKeyOrTokenOffset;
	unsigned FHashValueOffset;
	System::Word FMajorVersion;
	System::Word FRevisionNumber;
	System::Word FBuildNumber;
	System::Word FMinorVersion;
	unsigned FFlagMask;
	System::WideString __fastcall GetCulture(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetHashValue(void);
	System::WideString __fastcall GetName(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetPublicKeyOrToken(void);
	System::UnicodeString __fastcall GetVersion(void);
	TJclClrAssemblyFlags __fastcall GetFlags(void);
	
public:
	__fastcall virtual TJclClrTableAssemblyRefRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property System::Word MajorVersion = {read=FMajorVersion, nodefault};
	__property System::Word MinorVersion = {read=FMinorVersion, nodefault};
	__property System::Word BuildNumber = {read=FBuildNumber, nodefault};
	__property System::Word RevisionNumber = {read=FRevisionNumber, nodefault};
	__property unsigned FlagMask = {read=FFlagMask, nodefault};
	__property unsigned PublicKeyOrTokenOffset = {read=FPublicKeyOrTokenOffset, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned CultureOffset = {read=FCultureOffset, nodefault};
	__property unsigned HashValueOffset = {read=FHashValueOffset, nodefault};
	__property Jclclr::TJclClrBlobRecord* PublicKeyOrToken = {read=GetPublicKeyOrToken};
	__property System::WideString Name = {read=GetName};
	__property System::WideString Culture = {read=GetCulture};
	__property System::UnicodeString Version = {read=GetVersion};
	__property Jclclr::TJclClrBlobRecord* HashValue = {read=GetHashValue};
	__property TJclClrAssemblyFlags Flags = {read=GetFlags, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyRefRow(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyRef;
class PASCALIMPLEMENTATION TJclClrTableAssemblyRef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableAssemblyRefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableAssemblyRefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableAssemblyRefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableAssemblyRef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyRef(void) { }
	
private:
	void *__ITableCanDumpIL;	/* Jclclr::ITableCanDumpIL */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclclr::_di_ITableCanDumpIL()
	{
		Jclclr::_di_ITableCanDumpIL intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITableCanDumpIL*(void) { return (ITableCanDumpIL*)&__ITableCanDumpIL; }
	#endif
	
};


class DELPHICLASS TJclClrTableAssemblyRefOSRow;
class PASCALIMPLEMENTATION TJclClrTableAssemblyRefOSRow : public TJclClrTableAssemblyOSRow
{
	typedef TJclClrTableAssemblyOSRow inherited;
	
private:
	unsigned FAssemblyRefIdx;
	TJclClrTableAssemblyRefRow* __fastcall GetAssemblyRef(void);
	
public:
	__fastcall virtual TJclClrTableAssemblyRefOSRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned AssemblyRefIdx = {read=FAssemblyRefIdx, nodefault};
	__property TJclClrTableAssemblyRefRow* AssemblyRef = {read=GetAssemblyRef};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyRefOSRow(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyRefOS;
class PASCALIMPLEMENTATION TJclClrTableAssemblyRefOS : public TJclClrTableAssemblyOS
{
	typedef TJclClrTableAssemblyOS inherited;
	
public:
	TJclClrTableAssemblyRefOSRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableAssemblyRefOSRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableAssemblyRefOSRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableAssemblyRefOS(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : TJclClrTableAssemblyOS(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyRefOS(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyRefProcessorRow;
class PASCALIMPLEMENTATION TJclClrTableAssemblyRefProcessorRow : public TJclClrTableAssemblyProcessorRow
{
	typedef TJclClrTableAssemblyProcessorRow inherited;
	
private:
	unsigned FAssemblyRefIdx;
	TJclClrTableAssemblyRefRow* __fastcall GetAssemblyRef(void);
	
public:
	__fastcall virtual TJclClrTableAssemblyRefProcessorRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned AssemblyRefIdx = {read=FAssemblyRefIdx, nodefault};
	__property TJclClrTableAssemblyRefRow* AssemblyRef = {read=GetAssemblyRef};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyRefProcessorRow(void) { }
	
};


class DELPHICLASS TJclClrTableAssemblyRefProcessor;
class PASCALIMPLEMENTATION TJclClrTableAssemblyRefProcessor : public TJclClrTableAssemblyProcessor
{
	typedef TJclClrTableAssemblyProcessor inherited;
	
public:
	TJclClrTableAssemblyRefProcessorRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableAssemblyRefProcessorRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableAssemblyRefProcessorRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableAssemblyRefProcessor(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : TJclClrTableAssemblyProcessor(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableAssemblyRefProcessor(void) { }
	
};


class DELPHICLASS TJclClrTableClassLayoutRow;
class PASCALIMPLEMENTATION TJclClrTableClassLayoutRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FClassSize;
	unsigned FParentIdx;
	System::Word FPackingSize;
	
public:
	__fastcall virtual TJclClrTableClassLayoutRow(const Jclclr::TJclClrTable* ATable);
	__property System::Word PackingSize = {read=FPackingSize, nodefault};
	__property unsigned ClassSize = {read=FClassSize, nodefault};
	__property unsigned ParentIdx = {read=FParentIdx, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableClassLayoutRow(void) { }
	
};


class DELPHICLASS TJclClrTableClassLayout;
class PASCALIMPLEMENTATION TJclClrTableClassLayout : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableClassLayoutRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableClassLayoutRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableClassLayoutRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableClassLayout(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableClassLayout(void) { }
	
};


class DELPHICLASS TJclClrTableConstantRow;
class PASCALIMPLEMENTATION TJclClrTableConstantRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	System::Byte FKind;
	unsigned FParentIdx;
	unsigned FValueOffset;
	TJclClrElementType __fastcall GetElementType(void);
	Jclclr::TJclClrTableRow* __fastcall GetParent(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetValue(void);
	
public:
	__fastcall virtual TJclClrTableConstantRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property System::Byte Kind = {read=FKind, nodefault};
	__property unsigned ParentIdx = {read=FParentIdx, nodefault};
	__property unsigned ValueOffset = {read=FValueOffset, nodefault};
	__property TJclClrElementType ElementType = {read=GetElementType, nodefault};
	__property Jclclr::TJclClrTableRow* Parent = {read=GetParent};
	__property Jclclr::TJclClrBlobRecord* Value = {read=GetValue};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableConstantRow(void) { }
	
};


class DELPHICLASS TJclClrTableConstant;
class PASCALIMPLEMENTATION TJclClrTableConstant : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableConstantRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableConstantRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableConstantRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableConstant(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableConstant(void) { }
	
};


class DELPHICLASS TJclClrTableCustomAttributeRow;
class PASCALIMPLEMENTATION TJclClrTableCustomAttributeRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FParentIdx;
	unsigned FTypeIdx;
	unsigned FValueOffset;
	Jclclr::TJclClrBlobRecord* __fastcall GetValue(void);
	Jclclr::TJclClrTableRow* __fastcall GetParent(void);
	Jclclr::TJclClrTableRow* __fastcall GetMethod(void);
	
public:
	__fastcall virtual TJclClrTableCustomAttributeRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property unsigned ParentIdx = {read=FParentIdx, nodefault};
	__property unsigned TypeIdx = {read=FTypeIdx, nodefault};
	__property unsigned ValueOffset = {read=FValueOffset, nodefault};
	__property Jclclr::TJclClrTableRow* Parent = {read=GetParent};
	__property Jclclr::TJclClrTableRow* Method = {read=GetMethod};
	__property Jclclr::TJclClrBlobRecord* Value = {read=GetValue};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableCustomAttributeRow(void) { }
	
};


class DELPHICLASS TJclClrTableCustomAttribute;
class PASCALIMPLEMENTATION TJclClrTableCustomAttribute : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableCustomAttributeRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableCustomAttributeRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableCustomAttributeRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableCustomAttribute(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableCustomAttribute(void) { }
	
};


class DELPHICLASS TJclClrTableDeclSecurityRow;
class PASCALIMPLEMENTATION TJclClrTableDeclSecurityRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FPermissionSetOffset;
	unsigned FParentIdx;
	System::Word FAction;
	
public:
	__fastcall virtual TJclClrTableDeclSecurityRow(const Jclclr::TJclClrTable* ATable);
	__property System::Word Action = {read=FAction, nodefault};
	__property unsigned ParentIdx = {read=FParentIdx, nodefault};
	__property unsigned PermissionSetOffset = {read=FPermissionSetOffset, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableDeclSecurityRow(void) { }
	
};


class DELPHICLASS TJclClrTableDeclSecurity;
class PASCALIMPLEMENTATION TJclClrTableDeclSecurity : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableDeclSecurityRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableDeclSecurityRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableDeclSecurityRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableDeclSecurity(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableDeclSecurity(void) { }
	
};


class DELPHICLASS TJclClrTableEventMapRow;
class PASCALIMPLEMENTATION TJclClrTableEventMapRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FEventListIdx;
	unsigned FParentIdx;
	
public:
	__fastcall virtual TJclClrTableEventMapRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned ParentIdx = {read=FParentIdx, nodefault};
	__property unsigned EventListIdx = {read=FEventListIdx, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableEventMapRow(void) { }
	
};


class DELPHICLASS TJclClrTableEventMap;
class PASCALIMPLEMENTATION TJclClrTableEventMap : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableEventMapRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableEventMapRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableEventMapRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableEventMap(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableEventMap(void) { }
	
};


#pragma option push -b-
enum TJclClrTableEventFlag { efSpecialName, efRTSpecialName };
#pragma option pop

typedef Set<TJclClrTableEventFlag, efSpecialName, efRTSpecialName>  TJclClrTableEventFlags;

class DELPHICLASS TJclClrTableEventDefRow;
class PASCALIMPLEMENTATION TJclClrTableEventDefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FNameOffset;
	unsigned FEventTypeIdx;
	System::Word FEventFlags;
	System::WideString __fastcall GetName(void);
	
public:
	__fastcall virtual TJclClrTableEventDefRow(const Jclclr::TJclClrTable* ATable);
	__property System::Word EventFlags = {read=FEventFlags, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned EventTypeIdx = {read=FEventTypeIdx, nodefault};
	__property System::WideString Name = {read=GetName};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableEventDefRow(void) { }
	
};


class DELPHICLASS TJclClrTableEventDef;
class PASCALIMPLEMENTATION TJclClrTableEventDef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableEventDefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableEventDefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableEventDefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableEventDef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableEventDef(void) { }
	
};


class DELPHICLASS TJclClrTableExportedTypeRow;
class PASCALIMPLEMENTATION TJclClrTableExportedTypeRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FTypeDefIdx;
	unsigned FFlags;
	unsigned FImplementationIdx;
	unsigned FTypeNamespaceOffset;
	unsigned FTypeNameOffset;
	System::WideString __fastcall GetTypeName(void);
	System::WideString __fastcall GetTypeNamespace(void);
	
public:
	__fastcall virtual TJclClrTableExportedTypeRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned Flags = {read=FFlags, nodefault};
	__property unsigned TypeDefIdx = {read=FTypeDefIdx, nodefault};
	__property unsigned TypeNameOffset = {read=FTypeNameOffset, nodefault};
	__property unsigned TypeNamespaceOffset = {read=FTypeNamespaceOffset, nodefault};
	__property unsigned ImplementationIdx = {read=FImplementationIdx, nodefault};
	__property System::WideString TypeName = {read=GetTypeName};
	__property System::WideString TypeNamespace = {read=GetTypeNamespace};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableExportedTypeRow(void) { }
	
};


class DELPHICLASS TJclClrTableEventPtrRow;
class PASCALIMPLEMENTATION TJclClrTableEventPtrRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FEventIdx;
	TJclClrTableEventDefRow* __fastcall GetEvent(void);
	
public:
	__fastcall virtual TJclClrTableEventPtrRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned EventIdx = {read=FEventIdx, nodefault};
	__property TJclClrTableEventDefRow* Event = {read=GetEvent};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableEventPtrRow(void) { }
	
};


class DELPHICLASS TJclClrTableEventPtr;
class PASCALIMPLEMENTATION TJclClrTableEventPtr : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableEventPtrRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableEventPtrRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableEventPtrRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableEventPtr(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableEventPtr(void) { }
	
};


class DELPHICLASS TJclClrTableExportedType;
class PASCALIMPLEMENTATION TJclClrTableExportedType : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableExportedTypeRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableExportedTypeRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableExportedTypeRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableExportedType(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableExportedType(void) { }
	
};


#pragma option push -b-
enum TJclClrTableFieldDefVisibility { fvPrivateScope, fvPrivate, fvFamANDAssem, fvAssembly, fvFamily, fvFamORAssem, fvPublic };
#pragma option pop

#pragma option push -b-
enum TJclClrTableFieldDefFlag { ffStatic, ffInitOnly, ffLiteral, ffNotSerialized, ffSpecialName, ffPinvokeImpl, ffRTSpecialName, ffHasFieldMarshal, ffHasDefault, ffHasFieldRVA };
#pragma option pop

typedef Set<TJclClrTableFieldDefFlag, ffStatic, ffHasFieldRVA>  TJclClrTableFieldDefFlags;

class DELPHICLASS TJclClrTableFieldDefRow;
class DELPHICLASS TJclClrTableTypeDefRow;
class PASCALIMPLEMENTATION TJclClrTableFieldDefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	System::Word FFlags;
	unsigned FNameOffset;
	unsigned FSignatureOffset;
	TJclClrTableTypeDefRow* FParentToken;
	System::WideString __fastcall GetName(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetSignature(void);
	TJclClrTableFieldDefFlags __fastcall GetFlag(void);
	TJclClrTableFieldDefVisibility __fastcall GetVisibility(void);
	
protected:
	void __fastcall SetParentToken(const TJclClrTableTypeDefRow* ARow);
	
public:
	__fastcall virtual TJclClrTableFieldDefRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property System::Word RawFlags = {read=FFlags, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned SignatureOffset = {read=FSignatureOffset, nodefault};
	__property System::WideString Name = {read=GetName};
	__property Jclclr::TJclClrBlobRecord* Signature = {read=GetSignature};
	__property TJclClrTableTypeDefRow* ParentToken = {read=FParentToken};
	__property TJclClrTableFieldDefVisibility Visibility = {read=GetVisibility, nodefault};
	__property TJclClrTableFieldDefFlags Flags = {read=GetFlag, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableFieldDefRow(void) { }
	
};


class DELPHICLASS TJclClrTableFieldDef;
class PASCALIMPLEMENTATION TJclClrTableFieldDef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableFieldDefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableFieldDefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableFieldDefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableFieldDef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableFieldDef(void) { }
	
};


class DELPHICLASS TJclClrTableFieldPtrRow;
class PASCALIMPLEMENTATION TJclClrTableFieldPtrRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FFieldIdx;
	TJclClrTableFieldDefRow* __fastcall GetField(void);
	
public:
	__fastcall virtual TJclClrTableFieldPtrRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned FieldIdx = {read=FFieldIdx, nodefault};
	__property TJclClrTableFieldDefRow* Field = {read=GetField};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableFieldPtrRow(void) { }
	
};


class DELPHICLASS TJclClrTableFieldPtr;
class PASCALIMPLEMENTATION TJclClrTableFieldPtr : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableFieldPtrRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableFieldPtrRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableFieldPtrRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableFieldPtr(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableFieldPtr(void) { }
	
};


class DELPHICLASS TJclClrTableFieldLayoutRow;
class PASCALIMPLEMENTATION TJclClrTableFieldLayoutRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FOffset;
	unsigned FFieldIdx;
	
public:
	__fastcall virtual TJclClrTableFieldLayoutRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned Offset = {read=FOffset, nodefault};
	__property unsigned FieldIdx = {read=FFieldIdx, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableFieldLayoutRow(void) { }
	
};


class DELPHICLASS TJclClrTableFieldLayout;
class PASCALIMPLEMENTATION TJclClrTableFieldLayout : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableFieldLayoutRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableFieldLayoutRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableFieldLayoutRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableFieldLayout(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableFieldLayout(void) { }
	
};


class DELPHICLASS TJclClrTableFieldMarshalRow;
class PASCALIMPLEMENTATION TJclClrTableFieldMarshalRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FParentIdx;
	unsigned FNativeTypeOffset;
	
public:
	__fastcall virtual TJclClrTableFieldMarshalRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned ParentIdx = {read=FParentIdx, nodefault};
	__property unsigned NativeTypeOffset = {read=FNativeTypeOffset, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableFieldMarshalRow(void) { }
	
};


class DELPHICLASS TJclClrTableFieldMarshal;
class PASCALIMPLEMENTATION TJclClrTableFieldMarshal : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableFieldMarshalRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableFieldMarshalRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableFieldMarshalRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableFieldMarshal(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableFieldMarshal(void) { }
	
};


class DELPHICLASS TJclClrTableFieldRVARow;
class PASCALIMPLEMENTATION TJclClrTableFieldRVARow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FRVA;
	unsigned FFieldIdx;
	
public:
	__fastcall virtual TJclClrTableFieldRVARow(const Jclclr::TJclClrTable* ATable);
	__property unsigned RVA = {read=FRVA, nodefault};
	__property unsigned FieldIdx = {read=FFieldIdx, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableFieldRVARow(void) { }
	
};


class DELPHICLASS TJclClrTableFieldRVA;
class PASCALIMPLEMENTATION TJclClrTableFieldRVA : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableFieldRVARow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableFieldRVARow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableFieldRVARow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableFieldRVA(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableFieldRVA(void) { }
	
};


class DELPHICLASS TJclClrTableFileRow;
class PASCALIMPLEMENTATION TJclClrTableFileRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FHashValueOffset;
	unsigned FNameOffset;
	unsigned FFlags;
	System::WideString __fastcall GetName(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetHashValue(void);
	bool __fastcall GetContainsMetadata(void);
	
public:
	__fastcall virtual TJclClrTableFileRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property unsigned Flags = {read=FFlags, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned HashValueOffset = {read=FHashValueOffset, nodefault};
	__property System::WideString Name = {read=GetName};
	__property Jclclr::TJclClrBlobRecord* HashValue = {read=GetHashValue};
	__property bool ContainsMetadata = {read=GetContainsMetadata, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableFileRow(void) { }
	
};


class DELPHICLASS TJclClrTableFile;
class PASCALIMPLEMENTATION TJclClrTableFile : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableFileRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableFileRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableFileRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableFile(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableFile(void) { }
	
private:
	void *__ITableCanDumpIL;	/* Jclclr::ITableCanDumpIL */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclclr::_di_ITableCanDumpIL()
	{
		Jclclr::_di_ITableCanDumpIL intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITableCanDumpIL*(void) { return (ITableCanDumpIL*)&__ITableCanDumpIL; }
	#endif
	
};


class DELPHICLASS TJclClrTableImplMapRow;
class PASCALIMPLEMENTATION TJclClrTableImplMapRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FImportNameOffset;
	unsigned FMemberForwardedIdx;
	unsigned FImportScopeIdx;
	System::Word FMappingFlags;
	System::WideString __fastcall GetImportName(void);
	
public:
	__fastcall virtual TJclClrTableImplMapRow(const Jclclr::TJclClrTable* ATable);
	__property System::Word MappingFlags = {read=FMappingFlags, nodefault};
	__property unsigned MemberForwardedIdx = {read=FMemberForwardedIdx, nodefault};
	__property unsigned ImportNameOffset = {read=FImportNameOffset, nodefault};
	__property unsigned ImportScopeIdx = {read=FImportScopeIdx, nodefault};
	__property System::WideString ImportName = {read=GetImportName};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableImplMapRow(void) { }
	
};


class DELPHICLASS TJclClrTableImplMap;
class PASCALIMPLEMENTATION TJclClrTableImplMap : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableImplMapRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableImplMapRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableImplMapRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableImplMap(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableImplMap(void) { }
	
};


class DELPHICLASS TJclClrTableInterfaceImplRow;
class PASCALIMPLEMENTATION TJclClrTableInterfaceImplRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FInterfaceIdx;
	unsigned FClassIdx;
	Jclclr::TJclClrTableRow* __fastcall GetImplClass(void);
	Jclclr::TJclClrTableRow* __fastcall GetImplInterface(void);
	
public:
	__fastcall virtual TJclClrTableInterfaceImplRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property unsigned ClassIdx = {read=FClassIdx, nodefault};
	__property unsigned InterfaceIdx = {read=FInterfaceIdx, nodefault};
	__property Jclclr::TJclClrTableRow* ImplClass = {read=GetImplClass};
	__property Jclclr::TJclClrTableRow* ImplInterface = {read=GetImplInterface};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableInterfaceImplRow(void) { }
	
};


class DELPHICLASS TJclClrTableInterfaceImpl;
class PASCALIMPLEMENTATION TJclClrTableInterfaceImpl : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableInterfaceImplRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableInterfaceImplRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableInterfaceImplRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableInterfaceImpl(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableInterfaceImpl(void) { }
	
};


#pragma option push -b-
enum TJclClrTableManifestResourceVisibility { rvPublic, rvPrivate };
#pragma option pop

class DELPHICLASS TJclClrTableManifestResourceRow;
class PASCALIMPLEMENTATION TJclClrTableManifestResourceRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FOffset;
	unsigned FFlags;
	unsigned FImplementationIdx;
	unsigned FNameOffset;
	System::WideString __fastcall GetName(void);
	TJclClrTableManifestResourceVisibility __fastcall GetVisibility(void);
	Jclclr::TJclClrTableRow* __fastcall GetImplementationRow(void);
	
public:
	__fastcall virtual TJclClrTableManifestResourceRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property unsigned Offset = {read=FOffset, nodefault};
	__property unsigned Flags = {read=FFlags, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned ImplementationIdx = {read=FImplementationIdx, nodefault};
	__property System::WideString Name = {read=GetName};
	__property TJclClrTableManifestResourceVisibility Visibility = {read=GetVisibility, nodefault};
	__property Jclclr::TJclClrTableRow* ImplementationRow = {read=GetImplementationRow};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableManifestResourceRow(void) { }
	
};


class DELPHICLASS TJclClrTableManifestResource;
class PASCALIMPLEMENTATION TJclClrTableManifestResource : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableManifestResourceRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableManifestResourceRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableManifestResourceRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableManifestResource(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableManifestResource(void) { }
	
private:
	void *__ITableCanDumpIL;	/* Jclclr::ITableCanDumpIL */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclclr::_di_ITableCanDumpIL()
	{
		Jclclr::_di_ITableCanDumpIL intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITableCanDumpIL*(void) { return (ITableCanDumpIL*)&__ITableCanDumpIL; }
	#endif
	
};


class DELPHICLASS TJclClrTableMemberRefRow;
class PASCALIMPLEMENTATION TJclClrTableMemberRefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FClassIdx;
	unsigned FNameOffset;
	unsigned FSignatureOffset;
	System::WideString __fastcall GetName(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetSignature(void);
	Jclclr::TJclClrTableRow* __fastcall GetParentClass(void);
	System::WideString __fastcall GetFullName(void);
	
public:
	__fastcall virtual TJclClrTableMemberRefRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned ClassIdx = {read=FClassIdx, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned SignatureOffset = {read=FSignatureOffset, nodefault};
	__property System::WideString Name = {read=GetName};
	__property System::WideString FullName = {read=GetFullName};
	__property Jclclr::TJclClrBlobRecord* Signature = {read=GetSignature};
	__property Jclclr::TJclClrTableRow* ParentClass = {read=GetParentClass};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableMemberRefRow(void) { }
	
};


class DELPHICLASS TJclClrTableMemberRef;
class PASCALIMPLEMENTATION TJclClrTableMemberRef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableMemberRefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableMemberRefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableMemberRefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableMemberRef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableMemberRef(void) { }
	
};


#pragma option push -b-
enum TJclClrParamKind { pkIn, pkOut, pkOptional, pkHasDefault, pkHasFieldMarshal };
#pragma option pop

typedef Set<TJclClrParamKind, pkIn, pkHasFieldMarshal>  TJclClrParamKinds;

class DELPHICLASS TJclClrTableParamDefRow;
class DELPHICLASS TJclClrTableMethodDefRow;
class PASCALIMPLEMENTATION TJclClrTableParamDefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	System::Word FFlagMask;
	System::Word FSequence;
	unsigned FNameOffset;
	TJclClrTableMethodDefRow* FMethod;
	TJclClrParamKinds FFlags;
	System::WideString __fastcall GetName(void);
	
protected:
	void __fastcall SetMethod(const TJclClrTableMethodDefRow* AMethod);
	
public:
	__fastcall virtual TJclClrTableParamDefRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__classmethod System::Word __fastcall ParamFlags(const TJclClrParamKinds AFlags)/* overload */;
	__classmethod TJclClrParamKinds __fastcall ParamFlags(const System::Word AFlags)/* overload */;
	__property System::Word FlagMask = {read=FFlagMask, nodefault};
	__property System::Word Sequence = {read=FSequence, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property System::WideString Name = {read=GetName};
	__property TJclClrTableMethodDefRow* Method = {read=FMethod};
	__property TJclClrParamKinds Flags = {read=FFlags, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableParamDefRow(void) { }
	
};


class DELPHICLASS TJclClrTableParamDef;
class PASCALIMPLEMENTATION TJclClrTableParamDef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableParamDefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableParamDefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableParamDefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableParamDef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableParamDef(void) { }
	
};


class DELPHICLASS TJclClrTableParamPtrRow;
class PASCALIMPLEMENTATION TJclClrTableParamPtrRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FParamIdx;
	TJclClrTableParamDefRow* __fastcall GetParam(void);
	
public:
	__fastcall virtual TJclClrTableParamPtrRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned ParamIdx = {read=FParamIdx, nodefault};
	__property TJclClrTableParamDefRow* Param = {read=GetParam};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableParamPtrRow(void) { }
	
};


class DELPHICLASS TJclClrTableParamPtr;
class PASCALIMPLEMENTATION TJclClrTableParamPtr : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableParamPtrRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableParamPtrRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableParamPtrRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableParamPtr(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableParamPtr(void) { }
	
};


#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_TINY
{
	
public:
	System::Byte Flags_CodeSize;
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_TINY TImageCorILMethodTiny;

typedef IMAGE_COR_ILMETHOD_TINY *PImageCorILMethodTiny;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_FAT
{
	
public:
	System::Word Flags_Size;
	System::Word MaxStack;
	unsigned CodeSize;
	unsigned LocalVarSigTok;
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_FAT TImageCorILMethodFat;

typedef IMAGE_COR_ILMETHOD_FAT *PImageCorILMethodFat;

#pragma pack(push,1)
struct TImageCorILMethodHeader
{
	
	union
	{
		struct 
		{
			IMAGE_COR_ILMETHOD_FAT Fat;
			
		};
		struct 
		{
			IMAGE_COR_ILMETHOD_TINY Tiny;
			
		};
		
	};
};
#pragma pack(pop)


typedef TImageCorILMethodHeader *PImageCorILMethodHeader;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_SECT_SMALL
{
	
public:
	System::Byte Kind;
	System::Byte Datasize;
	System::Word Padding;
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_SECT_SMALL TImageCorILMethodSectSmall;

typedef IMAGE_COR_ILMETHOD_SECT_SMALL *PImageCorILMethodSectSmall;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_SECT_FAT
{
	
public:
	unsigned Kind_DataSize;
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_SECT_FAT TImageCorILMethodSectFat;

typedef IMAGE_COR_ILMETHOD_SECT_FAT *PImageCorILMethodSectFat;

#pragma pack(push,1)
struct TImageCorILMethodSectHeader
{
	
	union
	{
		struct 
		{
			IMAGE_COR_ILMETHOD_SECT_FAT Fat;
			
		};
		struct 
		{
			IMAGE_COR_ILMETHOD_SECT_SMALL Small;
			
		};
		
	};
};
#pragma pack(pop)


typedef TImageCorILMethodSectHeader *PImageCorILMethodSectHeader;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_FAT
{
	
public:
	unsigned Flags;
	unsigned TryOffset;
	unsigned TryLength;
	unsigned HandlerOffset;
	unsigned HandlerLength;
	union
	{
		struct 
		{
			unsigned FilterOffset;
			
		};
		struct 
		{
			unsigned ClassToken;
			
		};
		
	};
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_FAT TImageCorILMethodSectEHClauseFat;

typedef IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_FAT *PImageCorILMethodSectEHClauseFat;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_SECT_EH_FAT
{
	
public:
	IMAGE_COR_ILMETHOD_SECT_FAT SectFat;
	StaticArray<IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_FAT, 65535> Clauses;
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_SECT_EH_FAT TImageCorILMethodSectEHFat;

typedef IMAGE_COR_ILMETHOD_SECT_EH_FAT *PImageCorILMethodSectEHFat;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_SMALL
{
	
public:
	System::Word Flags;
	System::Word TryOffset;
	System::Byte TryLength;
	System::Word HandlerOffset;
	System::Byte HandlerLength;
	union
	{
		struct 
		{
			unsigned FilterOffset;
			
		};
		struct 
		{
			unsigned ClassToken;
			
		};
		
	};
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_SMALL TImageCorILMethodSectEHClauseSmall;

typedef IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_SMALL *PImageCorILMethodSectEHClauseSmall;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_SECT_EH_SMALL
{
	
public:
	IMAGE_COR_ILMETHOD_SECT_SMALL SectSmall;
	StaticArray<IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_SMALL, 65535> Clauses;
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_SECT_EH_SMALL TImageCorILMethodSectEHSmall;

typedef IMAGE_COR_ILMETHOD_SECT_EH_SMALL *PImageCorILMethodSectEHSmall;

#pragma pack(push,1)
struct IMAGE_COR_ILMETHOD_SECT_EH
{
	
	union
	{
		struct 
		{
			IMAGE_COR_ILMETHOD_SECT_EH_FAT Fat;
			
		};
		struct 
		{
			IMAGE_COR_ILMETHOD_SECT_EH_SMALL Small;
			
		};
		
	};
};
#pragma pack(pop)


typedef IMAGE_COR_ILMETHOD_SECT_EH TImageCorILMethodSectEH;

typedef IMAGE_COR_ILMETHOD_SECT_EH *PImageCorILMethodSectEH;

struct TJclClrCodeBlock
{
	
public:
	unsigned Offset;
	unsigned Length;
};


#pragma option push -b-
enum TJclClrExceptionClauseFlag { cfException, cfFilter, cfFinally, cfFault };
#pragma option pop

typedef Set<TJclClrExceptionClauseFlag, cfException, cfFault>  TJclClrExceptionClauseFlags;

class DELPHICLASS TJclClrExceptionHandler;
class PASCALIMPLEMENTATION TJclClrExceptionHandler : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	unsigned FFlags;
	unsigned FFilterOffset;
	TJclClrCodeBlock FTryBlock;
	TJclClrCodeBlock FHandlerBlock;
	unsigned FClassToken;
	TJclClrExceptionClauseFlags __fastcall GetFlags(void);
	
public:
	__fastcall TJclClrExceptionHandler(const IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_SMALL &EHClause)/* overload */;
	__fastcall TJclClrExceptionHandler(const IMAGE_COR_ILMETHOD_SECT_EH_CLAUSE_FAT &EHClause)/* overload */;
	__property unsigned EHFlags = {read=FFlags, nodefault};
	__property TJclClrExceptionClauseFlags Flags = {read=GetFlags, nodefault};
	__property TJclClrCodeBlock TryBlock = {read=FTryBlock};
	__property TJclClrCodeBlock HandlerBlock = {read=FHandlerBlock};
	__property unsigned ClassToken = {read=FClassToken, nodefault};
	__property unsigned FilterOffset = {read=FFilterOffset, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrExceptionHandler(void) { }
	
};


class DELPHICLASS TJclClrSignature;
class PASCALIMPLEMENTATION TJclClrSignature : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Jclclr::TJclClrBlobRecord* FBlob;
	
protected:
	bool __fastcall IsModifierType(const TJclClrElementType AElementType);
	bool __fastcall IsPrimitiveType(const TJclClrElementType AElementType);
	System::PByte __fastcall Inc(Jclbase::PJclByteArray &DataPtr, unsigned Step = (unsigned)(0x1));
	int __fastcall UncompressedDataSize(Jclbase::PJclByteArray DataPtr);
	int __fastcall UncompressData(Jclbase::PJclByteArray DataPtr, /* out */ unsigned &Value);
	int __fastcall UncompressToken(Jclbase::PJclByteArray DataPtr, /* out */ unsigned &Token);
	System::Byte __fastcall UncompressCallingConv(Jclbase::PJclByteArray DataPtr);
	int __fastcall UncompressSignedInt(Jclbase::PJclByteArray DataPtr, /* out */ int &Value);
	TJclClrElementType __fastcall UncompressElementType(Jclbase::PJclByteArray DataPtr);
	System::UnicodeString __fastcall UncompressTypeSignature(Jclbase::PJclByteArray DataPtr);
	
public:
	__fastcall TJclClrSignature(const Jclclr::TJclClrBlobRecord* ABlob);
	System::UnicodeString __fastcall UncompressFieldSignature(void);
	unsigned __fastcall ReadValue(void);
	System::Byte __fastcall ReadByte(void);
	int __fastcall ReadInteger(void);
	unsigned __fastcall ReadToken(void);
	TJclClrElementType __fastcall ReadElementType(void);
	__property Jclclr::TJclClrBlobRecord* Blob = {read=FBlob};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrSignature(void) { }
	
};


#pragma option push -b-
enum TJclClrArrayData { adSize, adLowBound };
#pragma option pop

typedef StaticArray<int, 2> TJclClrArraySignBound;

typedef DynamicArray<TJclClrArraySignBound> TJclClrArraySignBounds;

class DELPHICLASS TJclClrArraySign;
class PASCALIMPLEMENTATION TJclClrArraySign : public TJclClrSignature
{
	typedef TJclClrSignature inherited;
	
private:
	TJclClrArraySignBounds FBounds;
	
public:
	__fastcall TJclClrArraySign(const Jclclr::TJclClrBlobRecord* ABlob);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrArraySign(void) { }
	
};


#pragma option push -b-
enum TJclClrLocalVarFlag { lvfPinned, lvfByRef };
#pragma option pop

typedef Set<TJclClrLocalVarFlag, lvfPinned, lvfByRef>  TJclClrLocalVarFlags;

class DELPHICLASS TJclClrLocalVar;
class PASCALIMPLEMENTATION TJclClrLocalVar : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclClrElementType FElementType;
	TJclClrLocalVarFlags FFlags;
	unsigned FToken;
	System::WideString __fastcall GetName(void);
	
public:
	__property TJclClrElementType ElementType = {read=FElementType, write=FElementType, nodefault};
	__property System::WideString Name = {read=GetName};
	__property TJclClrLocalVarFlags Flags = {read=FFlags, write=FFlags, nodefault};
	__property unsigned Token = {read=FToken, write=FToken, nodefault};
public:
	/* TObject.Create */ inline __fastcall TJclClrLocalVar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrLocalVar(void) { }
	
};


class DELPHICLASS TJclClrLocalVarSign;
class PASCALIMPLEMENTATION TJclClrLocalVarSign : public TJclClrSignature
{
	typedef TJclClrSignature inherited;
	
private:
	Contnrs::TObjectList* FLocalVars;
	TJclClrLocalVar* __fastcall GetLocalVar(const int Idx);
	int __fastcall GetLocalVarCount(void);
	
public:
	__fastcall TJclClrLocalVarSign(const Jclclr::TJclClrBlobRecord* ABlob);
	__fastcall virtual ~TJclClrLocalVarSign(void);
	__property TJclClrLocalVar* LocalVars[const int Idx] = {read=GetLocalVar};
	__property int LocalVarCount = {read=GetLocalVarCount, nodefault};
};


class DELPHICLASS TJclClrMethodBody;
class PASCALIMPLEMENTATION TJclClrMethodBody : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclClrTableMethodDefRow* FMethod;
	unsigned FSize;
	void *FCode;
	unsigned FMaxStack;
	unsigned FLocalVarSignToken;
	TJclClrLocalVarSign* FLocalVarSign;
	Contnrs::TObjectList* FEHTable;
	void __fastcall AddEHTable(PImageCorILMethodSectEH EHTable);
	void __fastcall AddOptILTable(void * OptILTable, int Size);
	void __fastcall ParseMoreSections(PImageCorILMethodSectHeader SectHeader);
	TJclClrExceptionHandler* __fastcall GetExceptionHandler(const int Idx);
	int __fastcall GetExceptionHandlerCount(void);
	TJclClrLocalVarSign* __fastcall GetLocalVarSign(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetLocalVarSignData(void);
	
public:
	__fastcall TJclClrMethodBody(const TJclClrTableMethodDefRow* AMethod);
	__fastcall virtual ~TJclClrMethodBody(void);
	__property TJclClrTableMethodDefRow* Method = {read=FMethod};
	__property unsigned Size = {read=FSize, nodefault};
	__property void * Code = {read=FCode};
	__property unsigned MaxStack = {read=FMaxStack, nodefault};
	__property unsigned LocalVarSignToken = {read=FLocalVarSignToken, nodefault};
	__property Jclclr::TJclClrBlobRecord* LocalVarSignData = {read=GetLocalVarSignData};
	__property TJclClrLocalVarSign* LocalVarSign = {read=GetLocalVarSign};
	__property TJclClrExceptionHandler* ExceptionHandlers[const int Idx] = {read=GetExceptionHandler};
	__property int ExceptionHandlerCount = {read=GetExceptionHandlerCount, nodefault};
};


class DELPHICLASS TJclClrCustomModifierSign;
class PASCALIMPLEMENTATION TJclClrCustomModifierSign : public TJclClrSignature
{
	typedef TJclClrSignature inherited;
	
private:
	bool FRequired;
	unsigned FToken;
	
public:
	__fastcall TJclClrCustomModifierSign(const Jclclr::TJclClrBlobRecord* ABlob);
	__property bool Required = {read=FRequired, nodefault};
	__property unsigned Token = {read=FToken, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrCustomModifierSign(void) { }
	
};


class DELPHICLASS TJclClrMethodParam;
class DELPHICLASS TJclClrMethodSign;
class PASCALIMPLEMENTATION TJclClrMethodParam : public TJclClrSignature
{
	typedef TJclClrSignature inherited;
	
private:
	Contnrs::TObjectList* FCustomMods;
	bool FByRef;
	TJclClrElementType FElementType;
	unsigned FToken;
	TJclClrMethodSign* FMethodSign;
	TJclClrArraySign* FArraySign;
	TJclClrCustomModifierSign* __fastcall GetCustomModifier(const int Idx);
	int __fastcall GetCustomModifierCount(void);
	
public:
	__fastcall TJclClrMethodParam(const Jclclr::TJclClrBlobRecord* ABlob);
	__fastcall virtual ~TJclClrMethodParam(void);
	__property TJclClrCustomModifierSign* CustomModifiers[const int Idx] = {read=GetCustomModifier};
	__property int CustomModifierCount = {read=GetCustomModifierCount, nodefault};
	__property TJclClrElementType ElementType = {read=FElementType, nodefault};
	__property bool ByRef = {read=FByRef, nodefault};
	__property unsigned Token = {read=FToken, nodefault};
	__property TJclClrMethodSign* MethodSign = {read=FMethodSign};
	__property TJclClrArraySign* ArraySign = {read=FArraySign};
};


class DELPHICLASS TJclClrMethodRetType;
class PASCALIMPLEMENTATION TJclClrMethodRetType : public TJclClrMethodParam
{
	typedef TJclClrMethodParam inherited;
	
public:
	/* TJclClrMethodParam.Create */ inline __fastcall TJclClrMethodRetType(const Jclclr::TJclClrBlobRecord* ABlob) : TJclClrMethodParam(ABlob) { }
	/* TJclClrMethodParam.Destroy */ inline __fastcall virtual ~TJclClrMethodRetType(void) { }
	
};


#pragma option push -b-
enum TJclClrMethodSignFlag { mfHasThis, mfExplicitThis, mfDefault, mfVarArg };
#pragma option pop

typedef Set<TJclClrMethodSignFlag, mfHasThis, mfVarArg>  TJclClrMethodSignFlags;

class PASCALIMPLEMENTATION TJclClrMethodSign : public TJclClrSignature
{
	typedef TJclClrSignature inherited;
	
private:
	TJclClrMethodSignFlags FFlags;
	Contnrs::TObjectList* FParams;
	TJclClrMethodRetType* FRetType;
	TJclClrMethodParam* __fastcall GetParam(const int Idx);
	int __fastcall GetParamCount(void);
	
public:
	__fastcall TJclClrMethodSign(const Jclclr::TJclClrBlobRecord* ABlob);
	__fastcall virtual ~TJclClrMethodSign(void);
	__property TJclClrMethodSignFlags Flags = {read=FFlags, nodefault};
	__property TJclClrMethodParam* Params[const int Idx] = {read=GetParam};
	__property int ParamCount = {read=GetParamCount, nodefault};
	__property TJclClrMethodRetType* RetType = {read=FRetType};
};


#pragma option push -b-
enum TJclClrMemberAccess { maCompilercontrolled, maPrivate, maFamilyAndAssembly, maAssembly, maFamily, maFamilyOrAssembly, maPublic };
#pragma option pop

#pragma option push -b-
enum TJclClrMethodFlag { mfStatic, mfFinal, mfVirtual, mfHideBySig, mfCheckAccessOnOverride, mfAbstract, mfSpecialName, mfPInvokeImpl, mfUnmanagedExport, mfRTSpcialName, mfHasSecurity, mfRequireSecObject };
#pragma option pop

typedef Set<TJclClrMethodFlag, mfStatic, mfRequireSecObject>  TJclClrMethodFlags;

#pragma option push -b-
enum TJclClrMethodCodeType { ctIL, ctNative, ctOptIL, ctRuntime };
#pragma option pop

#pragma option push -b-
enum TJclClrMethodImplFlag { mifForwardRef, mifPreserveSig, mifInternalCall, mifSynchronized, mifNoInlining };
#pragma option pop

typedef Set<TJclClrMethodImplFlag, mifForwardRef, mifNoInlining>  TJclClrMethodImplFlags;

class PASCALIMPLEMENTATION TJclClrTableMethodDefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FRVA;
	System::Word FImplFlags;
	System::Word FFlags;
	unsigned FNameOffset;
	unsigned FSignatureOffset;
	unsigned FParamListIdx;
	TJclClrTableTypeDefRow* FParentToken;
	Classes::TList* FParams;
	TJclClrMethodBody* FMethodBody;
	TJclClrMethodSign* FSignature;
	System::WideString __fastcall GetName(void);
	Jclclr::TJclClrBlobRecord* __fastcall GetSignatureData(void);
	TJclClrTableParamDefRow* __fastcall GetParam(const int Idx);
	int __fastcall GetParamCount(void);
	bool __fastcall GetHasParam(void);
	void __fastcall UpdateParams(void);
	System::WideString __fastcall GetFullName(void);
	TJclClrMethodSign* __fastcall GetSignature(void);
	TJclClrMemberAccess __fastcall GetMemberAccess(void);
	TJclClrMethodFlags __fastcall GetMethodFlags(void);
	bool __fastcall GetNewSlot(void);
	TJclClrMethodCodeType __fastcall GetCodeType(void);
	bool __fastcall GetManaged(void);
	TJclClrMethodImplFlags __fastcall GetMethodImplFlags(void);
	
protected:
	virtual void __fastcall Update(void);
	void __fastcall SetParentToken(const TJclClrTableTypeDefRow* ARow);
	
public:
	__fastcall virtual TJclClrTableMethodDefRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__fastcall virtual ~TJclClrTableMethodDefRow(void);
	__property unsigned RVA = {read=FRVA, nodefault};
	__property System::Word ImplFlags = {read=FImplFlags, nodefault};
	__property System::Word Flags = {read=FFlags, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned SignatureOffset = {read=FSignatureOffset, nodefault};
	__property unsigned ParamListIdx = {read=FParamListIdx, nodefault};
	__property System::WideString Name = {read=GetName};
	__property System::WideString FullName = {read=GetFullName};
	__property TJclClrMethodFlags MethodFlags = {read=GetMethodFlags, nodefault};
	__property TJclClrMethodImplFlags MethodImplFlags = {read=GetMethodImplFlags, nodefault};
	__property TJclClrMemberAccess MemberAccess = {read=GetMemberAccess, nodefault};
	__property bool NewSlot = {read=GetNewSlot, nodefault};
	__property TJclClrMethodCodeType CodeType = {read=GetCodeType, nodefault};
	__property bool Managed = {read=GetManaged, nodefault};
	__property TJclClrMethodSign* Signature = {read=GetSignature};
	__property Jclclr::TJclClrBlobRecord* SignatureData = {read=GetSignatureData};
	__property TJclClrTableTypeDefRow* ParentToken = {read=FParentToken};
	__property bool HasParam = {read=GetHasParam, nodefault};
	__property TJclClrTableParamDefRow* Params[const int Idx] = {read=GetParam};
	__property int ParamCount = {read=GetParamCount, nodefault};
	__property TJclClrMethodBody* MethodBody = {read=FMethodBody};
};


class DELPHICLASS TJclClrTableMethodDef;
class PASCALIMPLEMENTATION TJclClrTableMethodDef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableMethodDefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableMethodDefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableMethodDefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableMethodDef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableMethodDef(void) { }
	
};


class DELPHICLASS TJclClrTableMethodPtrRow;
class PASCALIMPLEMENTATION TJclClrTableMethodPtrRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FMethodIdx;
	TJclClrTableMethodDefRow* __fastcall GetMethod(void);
	
public:
	__fastcall virtual TJclClrTableMethodPtrRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned MethodIdx = {read=FMethodIdx, nodefault};
	__property TJclClrTableMethodDefRow* Method = {read=GetMethod};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableMethodPtrRow(void) { }
	
};


class DELPHICLASS TJclClrTableMethodPtr;
class PASCALIMPLEMENTATION TJclClrTableMethodPtr : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableMethodPtrRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableMethodPtrRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableMethodPtrRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableMethodPtr(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableMethodPtr(void) { }
	
};


class DELPHICLASS TJclClrTableMethodImplRow;
class PASCALIMPLEMENTATION TJclClrTableMethodImplRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FClassIdx;
	unsigned FMethodBodyIdx;
	unsigned FMethodDeclarationIdx;
	
public:
	__fastcall virtual TJclClrTableMethodImplRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned ClassIdx = {read=FClassIdx, nodefault};
	__property unsigned MethodBodyIdx = {read=FMethodBodyIdx, nodefault};
	__property unsigned MethodDeclarationIdx = {read=FMethodDeclarationIdx, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableMethodImplRow(void) { }
	
};


class DELPHICLASS TJclClrTableMethodImpl;
class PASCALIMPLEMENTATION TJclClrTableMethodImpl : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableMethodImplRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableMethodImplRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableMethodImplRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableMethodImpl(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableMethodImpl(void) { }
	
};


class DELPHICLASS TJclClrTableMethodSemanticsRow;
class PASCALIMPLEMENTATION TJclClrTableMethodSemanticsRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	System::Word FSemantics;
	unsigned FMethodIdx;
	unsigned FAssociationIdx;
	
public:
	__fastcall virtual TJclClrTableMethodSemanticsRow(const Jclclr::TJclClrTable* ATable);
	__property System::Word Semantics = {read=FSemantics, nodefault};
	__property unsigned MethodIdx = {read=FMethodIdx, nodefault};
	__property unsigned AssociationIdx = {read=FAssociationIdx, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableMethodSemanticsRow(void) { }
	
};


class DELPHICLASS TJclClrTableMethodSemantics;
class PASCALIMPLEMENTATION TJclClrTableMethodSemantics : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableMethodSemanticsRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableMethodSemanticsRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableMethodSemanticsRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableMethodSemantics(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableMethodSemantics(void) { }
	
};


class DELPHICLASS TJclClrTableMethodSpecRow;
class PASCALIMPLEMENTATION TJclClrTableMethodSpecRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FMethodIdx;
	unsigned FInstantiationOffset;
	Jclclr::TJclClrBlobRecord* __fastcall GetInstantiation(void);
	Jclclr::TJclClrTableRow* __fastcall GetMethod(void);
	
public:
	__fastcall virtual TJclClrTableMethodSpecRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned MethodIdx = {read=FMethodIdx, nodefault};
	__property unsigned InstantiationOffset = {read=FInstantiationOffset, nodefault};
	__property Jclclr::TJclClrTableRow* Method = {read=GetMethod};
	__property Jclclr::TJclClrBlobRecord* Instantiation = {read=GetInstantiation};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableMethodSpecRow(void) { }
	
};


class DELPHICLASS TJclClrTableMethodSpec;
class PASCALIMPLEMENTATION TJclClrTableMethodSpec : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableMethodSpecRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableMethodSpecRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableMethodSpecRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableMethodSpec(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableMethodSpec(void) { }
	
};


class DELPHICLASS TJclClrTableNestedClassRow;
class PASCALIMPLEMENTATION TJclClrTableNestedClassRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FEnclosingClassIdx;
	unsigned FNestedClassIdx;
	
public:
	__fastcall virtual TJclClrTableNestedClassRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned NestedClassIdx = {read=FNestedClassIdx, nodefault};
	__property unsigned EnclosingClassIdx = {read=FEnclosingClassIdx, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableNestedClassRow(void) { }
	
};


class DELPHICLASS TJclClrTableNestedClass;
class PASCALIMPLEMENTATION TJclClrTableNestedClass : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableNestedClassRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableNestedClassRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableNestedClassRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableNestedClass(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableNestedClass(void) { }
	
};


#pragma option push -b-
enum TJclClrTablePropertyFlag { pfSpecialName, pfRTSpecialName, pfHasDefault };
#pragma option pop

typedef Set<TJclClrTablePropertyFlag, pfSpecialName, pfHasDefault>  TJclClrTablePropertyFlags;

class DELPHICLASS TJclClrTablePropertyDefRow;
class PASCALIMPLEMENTATION TJclClrTablePropertyDefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FKindIdx;
	unsigned FNameOffset;
	System::Word FFlags;
	System::WideString __fastcall GetName(void);
	TJclClrTablePropertyFlags __fastcall GetFlags(void);
	
public:
	__fastcall virtual TJclClrTablePropertyDefRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property System::Word RawFlags = {read=FFlags, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned KindIdx = {read=FKindIdx, nodefault};
	__property System::WideString Name = {read=GetName};
	__property TJclClrTablePropertyFlags Flags = {read=GetFlags, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTablePropertyDefRow(void) { }
	
};


class DELPHICLASS TJclClrTablePropertyDef;
class PASCALIMPLEMENTATION TJclClrTablePropertyDef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTablePropertyDefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTablePropertyDefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTablePropertyDefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTablePropertyDef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTablePropertyDef(void) { }
	
};


class DELPHICLASS TJclClrTablePropertyPtrRow;
class PASCALIMPLEMENTATION TJclClrTablePropertyPtrRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FPropertyIdx;
	TJclClrTablePropertyDefRow* __fastcall GetProperty(void);
	
public:
	__fastcall virtual TJclClrTablePropertyPtrRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned PropertyIdx = {read=FPropertyIdx, nodefault};
	__property TJclClrTablePropertyDefRow* _Property = {read=GetProperty};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTablePropertyPtrRow(void) { }
	
};


class DELPHICLASS TJclClrTablePropertyPtr;
class PASCALIMPLEMENTATION TJclClrTablePropertyPtr : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTablePropertyPtrRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTablePropertyPtrRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTablePropertyPtrRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTablePropertyPtr(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTablePropertyPtr(void) { }
	
};


class DELPHICLASS TJclClrTablePropertyMapRow;
class PASCALIMPLEMENTATION TJclClrTablePropertyMapRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FParentIdx;
	unsigned FPropertyListIdx;
	Classes::TList* FProperties;
	TJclClrTableTypeDefRow* __fastcall GetParent(void);
	TJclClrTablePropertyDefRow* __fastcall GetProperty(const int Idx);
	int __fastcall GetPropertyCount(void);
	
protected:
	int __fastcall Add(const TJclClrTablePropertyDefRow* ARow);
	
public:
	__fastcall virtual TJclClrTablePropertyMapRow(const Jclclr::TJclClrTable* ATable);
	__fastcall virtual ~TJclClrTablePropertyMapRow(void);
	__property unsigned ParentIdx = {read=FParentIdx, nodefault};
	__property unsigned PropertyListIdx = {read=FPropertyListIdx, nodefault};
	__property TJclClrTableTypeDefRow* Parent = {read=GetParent};
	__property TJclClrTablePropertyDefRow* Properties[const int Idx] = {read=GetProperty};
	__property int PropertyCount = {read=GetPropertyCount, nodefault};
};


class DELPHICLASS TJclClrTablePropertyMap;
class PASCALIMPLEMENTATION TJclClrTablePropertyMap : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTablePropertyMapRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTablePropertyMapRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	virtual void __fastcall Update(void);
	
public:
	__property TJclClrTablePropertyMapRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTablePropertyMap(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTablePropertyMap(void) { }
	
};


class DELPHICLASS TJclClrTableStandAloneSigRow;
class PASCALIMPLEMENTATION TJclClrTableStandAloneSigRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FSignatureOffset;
	Jclclr::TJclClrBlobRecord* __fastcall GetSignature(void);
	
public:
	__fastcall virtual TJclClrTableStandAloneSigRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned SignatureOffset = {read=FSignatureOffset, nodefault};
	__property Jclclr::TJclClrBlobRecord* Signature = {read=GetSignature};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableStandAloneSigRow(void) { }
	
};


class DELPHICLASS TJclClrTableStandAloneSig;
class PASCALIMPLEMENTATION TJclClrTableStandAloneSig : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableStandAloneSigRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableStandAloneSigRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableStandAloneSigRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableStandAloneSig(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableStandAloneSig(void) { }
	
};


#pragma option push -b-
enum TJclClrTypeVisibility { tvNotPublic, tvPublic, tvNestedPublic, tvNestedPrivate, tvNestedFamily, tvNestedAssembly, tvNestedFamANDAssem, tvNestedFamORAssem };
#pragma option pop

#pragma option push -b-
enum TJclClrClassLayout { clAuto, clSequential, clExplicit };
#pragma option pop

#pragma option push -b-
enum TJclClrClassSemantics { csClass, csInterface };
#pragma option pop

#pragma option push -b-
enum TJclClrStringFormatting { sfAnsi, sfUnicode, sfAutoChar };
#pragma option pop

#pragma option push -b-
enum TJclClrTypeAttribute { taAbstract, taSealed, taSpecialName, taImport, taSerializable, taBeforeFieldInit, taRTSpecialName, taHasSecurity };
#pragma option pop

typedef Set<TJclClrTypeAttribute, taAbstract, taHasSecurity>  TJclClrTypeAttributes;

class PASCALIMPLEMENTATION TJclClrTableTypeDefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FNamespaceOffset;
	unsigned FNameOffset;
	unsigned FFlags;
	unsigned FExtendsIdx;
	unsigned FFieldListIdx;
	unsigned FMethodListIdx;
	Classes::TList* FFields;
	Classes::TList* FMethods;
	System::WideString __fastcall GetName(void);
	System::WideString __fastcall GetNamespace(void);
	TJclClrTableFieldDefRow* __fastcall GetField(const int Idx);
	int __fastcall GetFieldCount(void);
	TJclClrTableMethodDefRow* __fastcall GetMethod(const int Idx);
	int __fastcall GetMethodCount(void);
	void __fastcall UpdateFields(void);
	void __fastcall UpdateMethods(void);
	System::WideString __fastcall GetFullName(void);
	TJclClrTypeAttributes __fastcall GetAttributes(void);
	TJclClrClassLayout __fastcall GetClassLayout(void);
	TJclClrClassSemantics __fastcall GetClassSemantics(void);
	TJclClrStringFormatting __fastcall GetStringFormatting(void);
	TJclClrTypeVisibility __fastcall GetVisibility(void);
	Jclclr::TJclClrTableRow* __fastcall GetExtends(void);
	
protected:
	virtual void __fastcall Update(void);
	
public:
	__fastcall virtual TJclClrTableTypeDefRow(const Jclclr::TJclClrTable* ATable);
	__fastcall virtual ~TJclClrTableTypeDefRow(void);
	virtual System::UnicodeString __fastcall DumpIL(void);
	bool __fastcall HasField(void);
	bool __fastcall HasMethod(void);
	__property unsigned Flags = {read=FFlags, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned NamespaceOffset = {read=FNamespaceOffset, nodefault};
	__property unsigned ExtendsIdx = {read=FExtendsIdx, nodefault};
	__property unsigned FieldListIdx = {read=FFieldListIdx, nodefault};
	__property unsigned MethodListIdx = {read=FMethodListIdx, nodefault};
	__property System::WideString Name = {read=GetName};
	__property System::WideString Namespace = {read=GetNamespace};
	__property System::WideString FullName = {read=GetFullName};
	__property Jclclr::TJclClrTableRow* Extends = {read=GetExtends};
	__property TJclClrTypeAttributes Attributes = {read=GetAttributes, nodefault};
	__property TJclClrTypeVisibility Visibility = {read=GetVisibility, nodefault};
	__property TJclClrClassLayout ClassLayout = {read=GetClassLayout, nodefault};
	__property TJclClrClassSemantics ClassSemantics = {read=GetClassSemantics, nodefault};
	__property TJclClrStringFormatting StringFormatting = {read=GetStringFormatting, nodefault};
	__property TJclClrTableFieldDefRow* Fields[const int Idx] = {read=GetField};
	__property int FieldCount = {read=GetFieldCount, nodefault};
	__property TJclClrTableMethodDefRow* Methods[const int Idx] = {read=GetMethod};
	__property int MethodCount = {read=GetMethodCount, nodefault};
};


class DELPHICLASS TJclClrTableTypeDef;
class PASCALIMPLEMENTATION TJclClrTableTypeDef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableTypeDefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableTypeDefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableTypeDefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableTypeDef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableTypeDef(void) { }
	
private:
	void *__ITableCanDumpIL;	/* Jclclr::ITableCanDumpIL */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclclr::_di_ITableCanDumpIL()
	{
		Jclclr::_di_ITableCanDumpIL intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator ITableCanDumpIL*(void) { return (ITableCanDumpIL*)&__ITableCanDumpIL; }
	#endif
	
};


class DELPHICLASS TJclClrTableTypeRefRow;
class PASCALIMPLEMENTATION TJclClrTableTypeRefRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FResolutionScopeIdx;
	unsigned FNamespaceOffset;
	unsigned FNameOffset;
	System::WideString __fastcall GetName(void);
	System::WideString __fastcall GetNamespace(void);
	Jclclr::TJclClrTableRow* __fastcall GetResolutionScope(void);
	System::UnicodeString __fastcall GetResolutionScopeName(void);
	System::WideString __fastcall GetFullName(void);
	
public:
	__fastcall virtual TJclClrTableTypeRefRow(const Jclclr::TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property unsigned ResolutionScopeIdx = {read=FResolutionScopeIdx, nodefault};
	__property unsigned NameOffset = {read=FNameOffset, nodefault};
	__property unsigned NamespaceOffset = {read=FNamespaceOffset, nodefault};
	__property Jclclr::TJclClrTableRow* ResolutionScope = {read=GetResolutionScope};
	__property System::UnicodeString ResolutionScopeName = {read=GetResolutionScopeName};
	__property System::WideString Name = {read=GetName};
	__property System::WideString Namespace = {read=GetNamespace};
	__property System::WideString FullName = {read=GetFullName};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableTypeRefRow(void) { }
	
};


class DELPHICLASS TJclClrTableTypeRef;
class PASCALIMPLEMENTATION TJclClrTableTypeRef : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableTypeRefRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableTypeRefRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableTypeRefRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableTypeRef(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableTypeRef(void) { }
	
};


class DELPHICLASS TJclClrTableTypeSpecRow;
class PASCALIMPLEMENTATION TJclClrTableTypeSpecRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FSignatureOffset;
	Jclclr::TJclClrBlobRecord* __fastcall GetSignature(void);
	
public:
	__fastcall virtual TJclClrTableTypeSpecRow(const Jclclr::TJclClrTable* ATable);
	__property unsigned SignatureOffset = {read=FSignatureOffset, nodefault};
	__property Jclclr::TJclClrBlobRecord* Signature = {read=GetSignature};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableTypeSpecRow(void) { }
	
};


class DELPHICLASS TJclClrTableTypeSpec;
class PASCALIMPLEMENTATION TJclClrTableTypeSpec : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableTypeSpecRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableTypeSpecRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableTypeSpecRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableTypeSpec(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableTypeSpec(void) { }
	
};


class DELPHICLASS TJclClrTableENCMapRow;
class PASCALIMPLEMENTATION TJclClrTableENCMapRow : public Jclclr::TJclClrTableRow
{
	typedef Jclclr::TJclClrTableRow inherited;
	
private:
	unsigned FToken;
	unsigned FFuncCode;
	
protected:
	__property unsigned FuncCode = {read=FFuncCode, nodefault};
	
public:
	__fastcall virtual TJclClrTableENCMapRow(const Jclclr::TJclClrTable* ATable);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableENCMapRow(void) { }
	
};


class DELPHICLASS TJclClrTableENCMap;
class PASCALIMPLEMENTATION TJclClrTableENCMap : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableENCMapRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableENCMapRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableENCMapRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableENCMap(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableENCMap(void) { }
	
};


class DELPHICLASS TJclClrTableENCLogRow;
class PASCALIMPLEMENTATION TJclClrTableENCLogRow : public TJclClrTableENCMapRow
{
	typedef TJclClrTableENCMapRow inherited;
	
private:
	unsigned FFuncCode;
	
protected:
	__property unsigned FuncCode = {read=FFuncCode, nodefault};
	
public:
	__fastcall virtual TJclClrTableENCLogRow(const Jclclr::TJclClrTable* ATable);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableENCLogRow(void) { }
	
};


class DELPHICLASS TJclClrTableENCLog;
class PASCALIMPLEMENTATION TJclClrTableENCLog : public Jclclr::TJclClrTable
{
	typedef Jclclr::TJclClrTable inherited;
	
public:
	TJclClrTableENCLogRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	HIDESBASE TJclClrTableENCLogRow* __fastcall GetRow(const int Idx);
	
protected:
	__classmethod virtual Jclclr::TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__property TJclClrTableENCLogRow* Rows[const int Idx] = {read=GetRow/*, default*/};
public:
	/* TJclClrTable.Create */ inline __fastcall virtual TJclClrTableENCLog(const Jclclr::TJclClrTableStream* AStream, const void * Ptr, const int ARowCount) : Jclclr::TJclClrTable(AStream, Ptr, ARowCount) { }
	/* TJclClrTable.Destroy */ inline __fastcall virtual ~TJclClrTableENCLog(void) { }
	
};


class DELPHICLASS EJclMetadataError;
class PASCALIMPLEMENTATION EJclMetadataError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclMetadataError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclMetadataError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclMetadataError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclMetadataError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMetadataError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMetadataError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMetadataError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMetadataError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMetadataError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclmetadata */
using namespace Jclmetadata;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclmetadataHPP
