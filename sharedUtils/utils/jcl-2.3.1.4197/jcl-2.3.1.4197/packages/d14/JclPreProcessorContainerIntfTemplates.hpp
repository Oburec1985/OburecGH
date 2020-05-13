// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorcontainerintftemplates.pas' rev: 21.00

#ifndef JclpreprocessorcontainerintftemplatesHPP
#define JclpreprocessorcontainerintftemplatesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclpreprocessorcontainertypes.hpp>	// Pascal unit
#include <Jclpreprocessorcontainertemplates.hpp>	// Pascal unit
#include <Jclpreprocessorcontainer1dtemplates.hpp>	// Pascal unit
#include <Jclpreprocessorcontainer2dtemplates.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessorcontainerintftemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclContainerIntf1DParams;
class PASCALIMPLEMENTATION TJclContainerIntf1DParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams inherited;
	
public:
	/* TObject.Create */ inline __fastcall TJclContainerIntf1DParams(void) : Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclContainerIntf1DParams(void) { }
	
};


class DELPHICLASS TJclContainerIntf2DParams;
class PASCALIMPLEMENTATION TJclContainerIntf2DParams : public Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams inherited;
	
public:
	/* TObject.Create */ inline __fastcall TJclContainerIntf2DParams(void) : Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclContainerIntf2DParams(void) { }
	
};


class DELPHICLASS TJclContainerIntfAncestorParams;
class PASCALIMPLEMENTATION TJclContainerIntfAncestorParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
protected:
	System::UnicodeString FAncestorName;
	virtual System::UnicodeString __fastcall GetAncestorName(void);
	bool __fastcall IsAncestorNameStored(void);
	
public:
	__property System::UnicodeString AncestorName = {read=GetAncestorName, write=FAncestorName, stored=IsAncestorNameStored};
public:
	/* TObject.Create */ inline __fastcall TJclContainerIntfAncestorParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclContainerIntfAncestorParams(void) { }
	
};


class DELPHICLASS TJclContainerIntfFlatAncestorParams;
class PASCALIMPLEMENTATION TJclContainerIntfFlatAncestorParams : public TJclContainerIntfAncestorParams
{
	typedef TJclContainerIntfAncestorParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetAncestorName(void);
public:
	/* TObject.Create */ inline __fastcall TJclContainerIntfFlatAncestorParams(void) : TJclContainerIntfAncestorParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclContainerIntfFlatAncestorParams(void) { }
	
};


class DELPHICLASS TJclIterProcedureParams;
class PASCALIMPLEMENTATION TJclIterProcedureParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString ProcName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=21};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclIterProcedureParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIterProcedureParams(void) { }
	
};


class DELPHICLASS TJclApplyFunctionParams;
class PASCALIMPLEMENTATION TJclApplyFunctionParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString FuncName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=22};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclApplyFunctionParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclApplyFunctionParams(void) { }
	
};


class DELPHICLASS TJclCompareFunctionParams;
class PASCALIMPLEMENTATION TJclCompareFunctionParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString FuncName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=23};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclCompareFunctionParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCompareFunctionParams(void) { }
	
};


class DELPHICLASS TJclEqualityCompareFunctionParams;
class PASCALIMPLEMENTATION TJclEqualityCompareFunctionParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString FuncName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=25};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclEqualityCompareFunctionParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclEqualityCompareFunctionParams(void) { }
	
};


class DELPHICLASS TJclHashFunctionParams;
class PASCALIMPLEMENTATION TJclHashFunctionParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString FuncName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=27};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclHashFunctionParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclHashFunctionParams(void) { }
	
};


class DELPHICLASS TJclSortFunctionParams;
class PASCALIMPLEMENTATION TJclSortFunctionParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString ProcName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=53};
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString CompareFuncName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
public:
	/* TObject.Create */ inline __fastcall TJclSortFunctionParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSortFunctionParams(void) { }
	
};


class DELPHICLASS TJclEqualityComparerParams;
class PASCALIMPLEMENTATION TJclEqualityComparerParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=33};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=34};
	__property System::UnicodeString EqualityCompareTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=25};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclEqualityComparerParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclEqualityComparerParams(void) { }
	
};


class DELPHICLASS TJclComparerParams;
class PASCALIMPLEMENTATION TJclComparerParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=35};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=36};
	__property System::UnicodeString CompareTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclComparerParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclComparerParams(void) { }
	
};


class DELPHICLASS TJclHashConverterParams;
class PASCALIMPLEMENTATION TJclHashConverterParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=37};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=38};
	__property System::UnicodeString HashConvertTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=27};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclHashConverterParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclHashConverterParams(void) { }
	
};


class DELPHICLASS TJclReleaseEventParams;
class PASCALIMPLEMENTATION TJclReleaseEventParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString EventTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=13};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclReleaseEventParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclReleaseEventParams(void) { }
	
};


class DELPHICLASS TJclOwnerParams;
class PASCALIMPLEMENTATION TJclOwnerParams : public TJclContainerIntfAncestorParams
{
	typedef TJclContainerIntfAncestorParams inherited;
	
protected:
	System::UnicodeString FOwnerAdditional;
	virtual System::UnicodeString __fastcall GetAncestorName(void);
	System::UnicodeString __fastcall GetOwnerAdditional(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=9};
	__property AncestorName;
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=10};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=11};
	__property System::UnicodeString ReleaseEventName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=12};
	__property System::UnicodeString ReleaseEventTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=13};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString OwnerAdditional = {read=GetOwnerAdditional, write=FOwnerAdditional};
public:
	/* TObject.Create */ inline __fastcall TJclOwnerParams(void) : TJclContainerIntfAncestorParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclOwnerParams(void) { }
	
};


class DELPHICLASS TJclIteratorParams;
class PASCALIMPLEMENTATION TJclIteratorParams : public TJclContainerIntfAncestorParams
{
	typedef TJclContainerIntfAncestorParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetAncestorName(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=39};
	__property AncestorName;
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=40};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TObject.Create */ inline __fastcall TJclIteratorParams(void) : TJclContainerIntfAncestorParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIteratorParams(void) { }
	
};


class DELPHICLASS TJclTreeIteratorParams;
class PASCALIMPLEMENTATION TJclTreeIteratorParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=66};
	__property System::UnicodeString AncestorName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=67};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclTreeIteratorParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeIteratorParams(void) { }
	
};


class DELPHICLASS TJclBinaryTreeIteratorParams;
class PASCALIMPLEMENTATION TJclBinaryTreeIteratorParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=41};
	__property System::UnicodeString AncestorName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=42};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclBinaryTreeIteratorParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryTreeIteratorParams(void) { }
	
};


class DELPHICLASS TJclCollectionParams;
class PASCALIMPLEMENTATION TJclCollectionParams : public TJclContainerIntfFlatAncestorParams
{
	typedef TJclContainerIntfFlatAncestorParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=49};
	__property AncestorName;
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=50};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString ItrName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
public:
	/* TObject.Create */ inline __fastcall TJclCollectionParams(void) : TJclContainerIntfFlatAncestorParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCollectionParams(void) { }
	
};


class DELPHICLASS TJclListParams;
class PASCALIMPLEMENTATION TJclListParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=51};
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString AncestorName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=52};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
	__property System::UnicodeString PropName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=18};
public:
	/* TObject.Create */ inline __fastcall TJclListParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclListParams(void) { }
	
};


class DELPHICLASS TJclArrayParams;
class PASCALIMPLEMENTATION TJclArrayParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=54};
	__property System::UnicodeString AncestorName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=55};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
	__property System::UnicodeString PropName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=18};
public:
	/* TObject.Create */ inline __fastcall TJclArrayParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclArrayParams(void) { }
	
};


class DELPHICLASS TJclSetParams;
class PASCALIMPLEMENTATION TJclSetParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=63};
	__property System::UnicodeString SetInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=63};
	__property System::UnicodeString AncestorName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=64};
public:
	/* TObject.Create */ inline __fastcall TJclSetParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSetParams(void) { }
	
};


class DELPHICLASS TJclTreeParams;
class PASCALIMPLEMENTATION TJclTreeParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=68};
	__property System::UnicodeString AncestorName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=69};
	__property System::UnicodeString ItrName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
public:
	/* TObject.Create */ inline __fastcall TJclTreeParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeParams(void) { }
	
};


class DELPHICLASS TJclMapParams;
class PASCALIMPLEMENTATION TJclMapParams : public TJclContainerIntf2DParams
{
	typedef TJclContainerIntf2DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=104};
	__property System::UnicodeString AncestorName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=106};
	__property System::UnicodeString GUID = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=105};
	__property System::UnicodeString ConstKeyword = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=85};
	__property System::UnicodeString TypeName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=83};
	__property System::UnicodeString SetName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=93};
	__property System::UnicodeString CollectionName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=102};
	__property System::UnicodeString KeyConstKeyword = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=85};
	__property System::UnicodeString KeyTypeName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=83};
	__property System::UnicodeString KeySetName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=93};
	__property System::UnicodeString ValueConstKeyword = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=97};
	__property System::UnicodeString ValueTypeName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=95};
	__property System::UnicodeString ValueCollectionName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=102};
public:
	/* TObject.Create */ inline __fastcall TJclMapParams(void) : TJclContainerIntf2DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMapParams(void) { }
	
};


class DELPHICLASS TJclQueueParams;
class PASCALIMPLEMENTATION TJclQueueParams : public TJclContainerIntfAncestorParams
{
	typedef TJclContainerIntfAncestorParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=75};
	__property AncestorName;
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=76};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclQueueParams(void) : TJclContainerIntfAncestorParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclQueueParams(void) { }
	
};


class DELPHICLASS TJclSortedMapParams;
class PASCALIMPLEMENTATION TJclSortedMapParams : public TJclContainerIntf2DParams
{
	typedef TJclContainerIntf2DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=107};
	__property System::UnicodeString AncestorName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=104};
	__property System::UnicodeString GUID = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=108};
	__property System::UnicodeString KeyConstKeyword = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=85};
	__property System::UnicodeString KeyTypeName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=83};
public:
	/* TObject.Create */ inline __fastcall TJclSortedMapParams(void) : TJclContainerIntf2DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSortedMapParams(void) { }
	
};


class DELPHICLASS TJclSortedSetParams;
class PASCALIMPLEMENTATION TJclSortedSetParams : public TJclContainerIntf1DParams
{
	typedef TJclContainerIntf1DParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=78};
	__property System::UnicodeString AncestorName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=63};
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=79};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclSortedSetParams(void) : TJclContainerIntf1DParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSortedSetParams(void) { }
	
};


class DELPHICLASS TJclStackParams;
class PASCALIMPLEMENTATION TJclStackParams : public TJclContainerIntfAncestorParams
{
	typedef TJclContainerIntfAncestorParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString InterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=80};
	__property AncestorName;
	__property System::UnicodeString GUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=81};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclStackParams(void) : TJclContainerIntfAncestorParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclStackParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorcontainerintftemplates */
using namespace Jclpreprocessorcontainerintftemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorcontainerintftemplatesHPP
