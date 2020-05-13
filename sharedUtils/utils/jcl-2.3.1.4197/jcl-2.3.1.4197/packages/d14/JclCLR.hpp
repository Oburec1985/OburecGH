// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclclr.pas' rev: 21.00

#ifndef JclclrHPP
#define JclclrHPP

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
#include <Jclfileutils.hpp>	// Pascal unit
#include <Jclstrings.hpp>	// Pascal unit
#include <Jclpeimage.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclclr
{
//-- type declarations -------------------------------------------------------
#pragma pack(push,1)
struct _IMAGE_COR_VTABLEFIXUP
{
	
public:
	unsigned RVA;
	System::Word Count;
	System::Word Kind;
};
#pragma pack(pop)


typedef _IMAGE_COR_VTABLEFIXUP IMAGE_COR_VTABLEFIXUP;

typedef _IMAGE_COR_VTABLEFIXUP TImageCorVTableFixup;

typedef _IMAGE_COR_VTABLEFIXUP *PImageCorVTableFixup;

typedef StaticArray<_IMAGE_COR_VTABLEFIXUP, 65535> TImageCorVTableFixupArray;

typedef TImageCorVTableFixupArray *PImageCorVTableFixupArray;

struct TClrStreamHeader;
typedef TClrStreamHeader *PClrStreamHeader;

#pragma pack(push,1)
struct TClrStreamHeader
{
	
public:
	unsigned Offset;
	unsigned Size;
	StaticArray<char, 65536> Name;
};
#pragma pack(pop)


struct TClrTableStreamHeader;
typedef TClrTableStreamHeader *PClrTableStreamHeader;

#pragma pack(push,1)
struct TClrTableStreamHeader
{
	
public:
	unsigned Reserved;
	System::Byte MajorVersion;
	System::Byte MinorVersion;
	System::Byte HeapSizes;
	System::Byte Reserved2;
	__int64 Valid;
	__int64 Sorted;
	StaticArray<unsigned, 65536> Rows;
};
#pragma pack(pop)


struct TClrMetadataHeader;
typedef TClrMetadataHeader *PClrMetadataHeader;

#pragma pack(push,1)
struct TClrMetadataHeader
{
	
public:
	unsigned Signature;
	System::Word MajorVersion;
	System::Word MinorVersion;
	unsigned Reserved;
	unsigned Length;
	StaticArray<char, 1> Version;
};
#pragma pack(pop)


#pragma option push -b-
enum TJclClrTableKind { ttModule, ttTypeRef, ttTypeDef, ttFieldPtr, ttFieldDef, ttMethodPtr, ttMethodDef, ttParamPtr, ttParamDef, ttInterfaceImpl, ttMemberRef, ttConstant, ttCustomAttribute, ttFieldMarshal, ttDeclSecurity, ttClassLayout, ttFieldLayout, ttSignature, ttEventMap, ttEventPtr, ttEventDef, ttPropertyMap, ttPropertyPtr, ttPropertyDef, ttMethodSemantics, ttMethodImpl, ttModuleRef, ttTypeSpec, ttImplMap, ttFieldRVA, ttENCLog, ttENCMap, ttAssembly, ttAssemblyProcessor, ttAssemblyOS, ttAssemblyRef, ttAssemblyRefProcessor, ttAssemblyRefOS, ttFile, ttExportedType, ttManifestResource, ttNestedClass, ttTypeTyPar, ttMethodTyPar };
#pragma option pop

typedef unsigned TJclClrToken;

typedef unsigned *PJclClrToken;

class DELPHICLASS TJclClrStream;
class DELPHICLASS TJclPeMetadata;
class PASCALIMPLEMENTATION TJclClrStream : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclPeMetadata* FMetadata;
	TClrStreamHeader *FHeader;
	System::UnicodeString __fastcall GetName(void);
	unsigned __fastcall GetOffset(void);
	unsigned __fastcall GetSize(void);
	void * __fastcall GetData(void);
	
public:
	__fastcall virtual TJclClrStream(const TJclPeMetadata* AMetadata, PClrStreamHeader AHeader);
	__property TJclPeMetadata* Metadata = {read=FMetadata};
	__property PClrStreamHeader Header = {read=FHeader};
	__property System::UnicodeString Name = {read=GetName};
	__property unsigned Offset = {read=GetOffset, nodefault};
	__property unsigned Size = {read=GetSize, nodefault};
	__property void * Data = {read=GetData};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrStream(void) { }
	
};


typedef TMetaClass* TJclClrStreamClass;

class DELPHICLASS TJclClrStringsStream;
class PASCALIMPLEMENTATION TJclClrStringsStream : public TJclClrStream
{
	typedef TJclClrStream inherited;
	
public:
	System::WideString operator[](const int Idx) { return Strings[Idx]; }
	
private:
	Classes::TStringList* FStrings;
	System::WideString __fastcall GetString(const int Idx);
	HIDESBASE unsigned __fastcall GetOffset(const int Idx);
	int __fastcall GetStringCount(void);
	
public:
	__fastcall virtual TJclClrStringsStream(const TJclPeMetadata* AMetadata, PClrStreamHeader AHeader);
	__fastcall virtual ~TJclClrStringsStream(void);
	System::WideString __fastcall At(const unsigned Offset);
	__property System::WideString Strings[const int Idx] = {read=GetString/*, default*/};
	__property unsigned Offsets[const int Idx] = {read=GetOffset};
	__property int StringCount = {read=GetStringCount, nodefault};
};


class DELPHICLASS TJclClrGuidStream;
class PASCALIMPLEMENTATION TJclClrGuidStream : public TJclClrStream
{
	typedef TJclClrStream inherited;
	
private:
	typedef DynamicArray<GUID> _TJclClrGuidStream__1;
	
	
public:
	GUID operator[](const int Idx) { return Guids[Idx]; }
	
private:
	_TJclClrGuidStream__1 FGuids;
	GUID __fastcall GetGuid(const int Idx);
	int __fastcall GetGuidCount(void);
	
public:
	__fastcall virtual TJclClrGuidStream(const TJclPeMetadata* AMetadata, PClrStreamHeader AHeader);
	__property GUID Guids[const int Idx] = {read=GetGuid/*, default*/};
	__property int GuidCount = {read=GetGuidCount, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrGuidStream(void) { }
	
};


class DELPHICLASS TJclClrBlobRecord;
class PASCALIMPLEMENTATION TJclClrBlobRecord : public Jclsysutils::TJclReferenceMemoryStream
{
	typedef Jclsysutils::TJclReferenceMemoryStream inherited;
	
private:
	Jclbase::TJclByteArray *FPtr;
	unsigned FOffset;
	Jclbase::PJclByteArray __fastcall GetData(void);
	
public:
	__fastcall TJclClrBlobRecord(const TJclClrStream* AStream, Jclbase::PJclByteArray APtr);
	System::UnicodeString __fastcall Dump(System::UnicodeString Indent);
	__property Jclbase::PJclByteArray Ptr = {read=FPtr};
	__property unsigned Offset = {read=FOffset, nodefault};
	__property Jclbase::PJclByteArray Data = {read=GetData};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrBlobRecord(void) { }
	
};


class DELPHICLASS TJclClrBlobStream;
class PASCALIMPLEMENTATION TJclClrBlobStream : public TJclClrStream
{
	typedef TJclClrStream inherited;
	
public:
	TJclClrBlobRecord* operator[](const int Idx) { return Blobs[Idx]; }
	
private:
	Contnrs::TObjectList* FBlobs;
	TJclClrBlobRecord* __fastcall GetBlob(const int Idx);
	int __fastcall GetBlobCount(void);
	
public:
	__fastcall virtual TJclClrBlobStream(const TJclPeMetadata* AMetadata, PClrStreamHeader AHeader);
	__fastcall virtual ~TJclClrBlobStream(void);
	TJclClrBlobRecord* __fastcall At(const unsigned Offset);
	__property TJclClrBlobRecord* Blobs[const int Idx] = {read=GetBlob/*, default*/};
	__property int BlobCount = {read=GetBlobCount, nodefault};
};


class DELPHICLASS TJclClrUserStringStream;
class PASCALIMPLEMENTATION TJclClrUserStringStream : public TJclClrBlobStream
{
	typedef TJclClrBlobStream inherited;
	
public:
	System::WideString operator[](const int Idx) { return Strings[Idx]; }
	
private:
	System::WideString __fastcall BlobToString(const TJclClrBlobRecord* ABlob);
	System::WideString __fastcall GetString(const int Idx);
	HIDESBASE unsigned __fastcall GetOffset(const int Idx);
	int __fastcall GetStringCount(void);
	
public:
	HIDESBASE System::WideString __fastcall At(const unsigned Offset);
	__property System::WideString Strings[const int Idx] = {read=GetString/*, default*/};
	__property unsigned Offsets[const int Idx] = {read=GetOffset};
	__property int StringCount = {read=GetStringCount, nodefault};
public:
	/* TJclClrBlobStream.Create */ inline __fastcall virtual TJclClrUserStringStream(const TJclPeMetadata* AMetadata, PClrStreamHeader AHeader) : TJclClrBlobStream(AMetadata, AHeader) { }
	/* TJclClrBlobStream.Destroy */ inline __fastcall virtual ~TJclClrUserStringStream(void) { }
	
};


#pragma option push -b-
enum TJclClrHeapKind { hkString, hkGuid, hkBlob };
#pragma option pop

#pragma option push -b-
enum TJclClrComboIndex { ciResolutionScope };
#pragma option pop

__interface ITableCanDumpIL;
typedef System::DelphiInterface<ITableCanDumpIL> _di_ITableCanDumpIL;
__interface  INTERFACE_UUID("{C7AC787B-5DCD-411A-8674-D424A61B76D1}") ITableCanDumpIL  : public System::IInterface 
{
	
};

class DELPHICLASS TJclClrTableRow;
class DELPHICLASS TJclClrTable;
class PASCALIMPLEMENTATION TJclClrTableRow : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclClrTable* FTable;
	int FIndex;
	unsigned __fastcall GetToken(void);
	
protected:
	virtual void __fastcall Update(void);
	TJclClrTableRow* __fastcall DecodeTypeDefOrRef(const unsigned Encoded);
	TJclClrTableRow* __fastcall DecodeResolutionScope(const unsigned Encoded);
	
public:
	__fastcall virtual TJclClrTableRow(const TJclClrTable* ATable);
	virtual System::UnicodeString __fastcall DumpIL(void);
	__property TJclClrTable* Table = {read=FTable};
	__property int Index = {read=FIndex, nodefault};
	__property unsigned Token = {read=GetToken, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrTableRow(void) { }
	
};


typedef TMetaClass* TJclClrTableRowClass;

class DELPHICLASS TJclClrTableStream;
class PASCALIMPLEMENTATION TJclClrTable : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
public:
	TJclClrTableRow* operator[](const int Idx) { return Rows[Idx]; }
	
private:
	TJclClrTableStream* FStream;
	char *FData;
	char *FPtr;
	Contnrs::TObjectList* FRows;
	int FRowCount;
	unsigned FSize;
	unsigned __fastcall GetOffset(void);
	
protected:
	virtual void __fastcall Load(void);
	void __fastcall SetSize(const int Value);
	virtual void __fastcall Update(void);
	virtual System::UnicodeString __fastcall DumpIL(void);
	TJclClrTableRow* __fastcall GetRow(const int Idx);
	int __fastcall GetRowCount(void);
	int __fastcall AddRow(const TJclClrTableRow* ARow);
	int __fastcall RealRowCount(void);
	void __fastcall Reset(void);
	__classmethod virtual TJclClrTableRowClass __fastcall TableRowClass();
	
public:
	__fastcall virtual TJclClrTable(const TJclClrTableStream* AStream, const void * Ptr, const int ARowCount);
	__fastcall virtual ~TJclClrTable(void);
	unsigned __fastcall ReadCompressedValue(void);
	System::Byte __fastcall ReadByte(void);
	System::Word __fastcall ReadWord(void);
	unsigned __fastcall ReadDWord(void);
	unsigned __fastcall ReadIndex(const TJclClrHeapKind HeapKind)/* overload */;
	unsigned __fastcall ReadIndex(TJclClrTableKind const *TableKinds, const int TableKinds_Size)/* overload */;
	bool __fastcall IsWideIndex(const TJclClrHeapKind HeapKind)/* overload */;
	bool __fastcall IsWideIndex(TJclClrTableKind const *TableKinds, const int TableKinds_Size)/* overload */;
	unsigned __fastcall GetCodedIndexTag(const unsigned CodedIndex, const unsigned TagWidth, const bool WideIndex);
	unsigned __fastcall GetCodedIndexValue(const unsigned CodedIndex, const unsigned TagWidth, const bool WideIndex);
	__property TJclClrTableStream* Stream = {read=FStream};
	__property char * Data = {read=FData};
	__property unsigned Size = {read=FSize, nodefault};
	__property unsigned Offset = {read=GetOffset, nodefault};
	__property TJclClrTableRow* Rows[const int Idx] = {read=GetRow/*, default*/};
	__property int RowCount = {read=GetRowCount, nodefault};
};


typedef TMetaClass* TJclClrTableClass;

class PASCALIMPLEMENTATION TJclClrTableStream : public TJclClrStream
{
	typedef TJclClrStream inherited;
	
private:
	TClrTableStreamHeader *FHeader;
	StaticArray<TJclClrTable*, 44> FTables;
	int FTableCount;
	System::UnicodeString __fastcall GetVersionString(void);
	TJclClrTable* __fastcall GetTable(const TJclClrTableKind AKind);
	bool __fastcall GetBigHeap(const TJclClrHeapKind AHeapKind);
	
public:
	__fastcall virtual TJclClrTableStream(const TJclPeMetadata* AMetadata, PClrStreamHeader AHeader);
	__fastcall virtual ~TJclClrTableStream(void);
	virtual void __fastcall Update(void);
	System::UnicodeString __fastcall DumpIL(void);
	bool __fastcall FindTable(const TJclClrTableKind AKind, /* out */ TJclClrTable* &ATable);
	__property PClrTableStreamHeader Header = {read=FHeader};
	__property System::UnicodeString VersionString = {read=GetVersionString};
	__property bool BigHeap[const TJclClrHeapKind AHeapKind] = {read=GetBigHeap};
	__property TJclClrTable* Tables[const TJclClrTableKind AKind] = {read=GetTable};
	__property int TableCount = {read=FTableCount, nodefault};
};


class PASCALIMPLEMENTATION TJclPeMetadata : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclClrStream* operator[](const int Idx) { return Streams[Idx]; }
	
private:
	Jclpeimage::TJclPeImage* FImage;
	TClrMetadataHeader *FHeader;
	Contnrs::TObjectList* FStreams;
	TJclClrStringsStream* FStringStream;
	TJclClrGuidStream* FGuidStream;
	TJclClrBlobStream* FBlobStream;
	TJclClrUserStringStream* FUserStringStream;
	TJclClrTableStream* FTableStream;
	TJclClrStream* __fastcall GetStream(const int Idx);
	int __fastcall GetStreamCount(void);
	System::WideString __fastcall GetString(const int Idx);
	int __fastcall GetStringCount(void);
	GUID __fastcall GetGuid(const int Idx);
	int __fastcall GetGuidCount(void);
	TJclClrBlobRecord* __fastcall GetBlob(const int Idx);
	int __fastcall GetBlobCount(void);
	TJclClrTable* __fastcall GetTable(const TJclClrTableKind AKind);
	int __fastcall GetTableCount(void);
	TJclClrTableRow* __fastcall GetToken(const unsigned AToken);
	System::UnicodeString __fastcall GetVersion(void);
	System::WideString __fastcall GetVersionString(void);
	System::Word __fastcall GetFlags(void);
	System::WideString __fastcall UserGetString(const int Idx);
	int __fastcall UserGetStringCount(void);
	
public:
	__fastcall TJclPeMetadata(const Jclpeimage::TJclPeImage* AImage);
	__fastcall virtual ~TJclPeMetadata(void);
	System::UnicodeString __fastcall DumpIL(void);
	bool __fastcall FindStream(const System::UnicodeString AName, /* out */ TJclClrStream* &Stream)/* overload */;
	bool __fastcall FindStream(const TJclClrStreamClass AClass, /* out */ TJclClrStream* &Stream)/* overload */;
	System::WideString __fastcall StringAt(const unsigned Offset);
	System::WideString __fastcall UserStringAt(const unsigned Offset);
	TJclClrBlobRecord* __fastcall BlobAt(const unsigned Offset);
	bool __fastcall TokenExists(const unsigned Token);
	__classmethod TJclClrTableKind __fastcall TokenTable(const unsigned Token);
	__classmethod int __fastcall TokenIndex(const unsigned Token);
	__classmethod int __fastcall TokenCode(const unsigned Token);
	__classmethod unsigned __fastcall MakeToken(const TJclClrTableKind Table, const int Idx);
	__property Jclpeimage::TJclPeImage* Image = {read=FImage};
	__property PClrMetadataHeader Header = {read=FHeader};
	__property System::UnicodeString Version = {read=GetVersion};
	__property System::WideString VersionString = {read=GetVersionString};
	__property System::Word Flags = {read=GetFlags, nodefault};
	__property TJclClrStream* Streams[const int Idx] = {read=GetStream/*, default*/};
	__property int StreamCount = {read=GetStreamCount, nodefault};
	__property System::WideString Strings[const int Idx] = {read=GetString};
	__property int StringCount = {read=GetStringCount, nodefault};
	__property System::WideString UserStrings[const int Idx] = {read=UserGetString};
	__property int UserStringCount = {read=UserGetStringCount, nodefault};
	__property GUID Guids[const int Idx] = {read=GetGuid};
	__property int GuidCount = {read=GetGuidCount, nodefault};
	__property TJclClrBlobRecord* Blobs[const int Idx] = {read=GetBlob};
	__property int BlobCount = {read=GetBlobCount, nodefault};
	__property TJclClrTable* Tables[const TJclClrTableKind AKind] = {read=GetTable};
	__property int TableCount = {read=GetTableCount, nodefault};
	__property TJclClrTableRow* Tokens[const unsigned AToken] = {read=GetToken};
};


class DELPHICLASS TJclClrResourceRecord;
class PASCALIMPLEMENTATION TJclClrResourceRecord : public Jclsysutils::TJclReferenceMemoryStream
{
	typedef Jclsysutils::TJclReferenceMemoryStream inherited;
	
private:
	void *FData;
	unsigned FOffset;
	unsigned FRVA;
	
public:
	__fastcall TJclClrResourceRecord(const char * AData, const unsigned AOffset, const unsigned ARVA);
	__property void * Data = {read=FData};
	__property unsigned Offset = {read=FOffset, nodefault};
	__property unsigned RVA = {read=FRVA, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrResourceRecord(void) { }
	
};


#pragma option push -b-
enum TJclClrVTableKind { vtk32Bit, vtk64Bit, vtkFromUnmanaged, vtkCallMostDerived };
#pragma option pop

typedef Set<TJclClrVTableKind, vtk32Bit, vtkCallMostDerived>  TJclClrVTableKinds;

class DELPHICLASS TJclClrVTableFixupRecord;
class PASCALIMPLEMENTATION TJclClrVTableFixupRecord : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	_IMAGE_COR_VTABLEFIXUP *FData;
	unsigned __fastcall GetCount(void);
	TJclClrVTableKinds __fastcall GetKinds(void);
	unsigned __fastcall GetRVA(void);
	
protected:
	__classmethod unsigned __fastcall VTableKinds(const TJclClrVTableKinds Kinds)/* overload */;
	__classmethod TJclClrVTableKinds __fastcall VTableKinds(const unsigned Kinds)/* overload */;
	
public:
	__fastcall TJclClrVTableFixupRecord(PImageCorVTableFixup AData);
	__property PImageCorVTableFixup Data = {read=FData};
	__property unsigned RVA = {read=GetRVA, nodefault};
	__property unsigned Count = {read=GetCount, nodefault};
	__property TJclClrVTableKinds Kinds = {read=GetKinds, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrVTableFixupRecord(void) { }
	
};


#pragma option push -b-
enum TJclClrImageFlag { cifILOnly, cif32BitRequired, cifStrongNameSinged, cifTrackDebugData };
#pragma option pop

typedef Set<TJclClrImageFlag, cifILOnly, cifTrackDebugData>  TJclClrImageFlags;

class DELPHICLASS TJclClrHeaderEx;
class PASCALIMPLEMENTATION TJclClrHeaderEx : public Jclpeimage::TJclPeCLRHeader
{
	typedef Jclpeimage::TJclPeCLRHeader inherited;
	
private:
	TJclPeMetadata* FMetadata;
	TJclClrImageFlags FFlags;
	Classes::TCustomMemoryStream* FStrongNameSignature;
	Contnrs::TObjectList* FResources;
	Contnrs::TObjectList* FVTableFixups;
	TJclPeMetadata* __fastcall GetMetadata(void);
	Classes::TCustomMemoryStream* __fastcall GetStrongNameSignature(void);
	TJclClrTableRow* __fastcall GetEntryPointToken(void);
	TJclClrVTableFixupRecord* __fastcall GetVTableFixup(const int Idx);
	int __fastcall GetVTableFixupCount(void);
	void __fastcall UpdateResources(void);
	TJclClrResourceRecord* __fastcall GetResource(const int Idx);
	int __fastcall GetResourceCount(void);
	
public:
	__fastcall TJclClrHeaderEx(const Jclpeimage::TJclPeImage* AImage);
	__fastcall virtual ~TJclClrHeaderEx(void);
	System::UnicodeString __fastcall DumpIL(void);
	bool __fastcall HasResources(void);
	bool __fastcall HasStrongNameSignature(void);
	bool __fastcall HasVTableFixup(void);
	TJclClrResourceRecord* __fastcall ResourceAt(const unsigned Offset);
	__classmethod TJclClrImageFlags __fastcall ClrImageFlag(const unsigned Flags)/* overload */;
	__classmethod unsigned __fastcall ClrImageFlag(const TJclClrImageFlags Flags)/* overload */;
	__property TJclPeMetadata* Metadata = {read=GetMetadata};
	__property TJclClrImageFlags Flags = {read=FFlags, nodefault};
	__property TJclClrTableRow* EntryPointToken = {read=GetEntryPointToken};
	__property Classes::TCustomMemoryStream* StrongNameSignature = {read=GetStrongNameSignature};
	__property TJclClrResourceRecord* Resources[const int Idx] = {read=GetResource};
	__property int ResourceCount = {read=GetResourceCount, nodefault};
	__property TJclClrVTableFixupRecord* VTableFixups[const int Idx] = {read=GetVTableFixup};
	__property int VTableFixupCount = {read=GetVTableFixupCount, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclclr */
using namespace Jclclr;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclclrHPP
