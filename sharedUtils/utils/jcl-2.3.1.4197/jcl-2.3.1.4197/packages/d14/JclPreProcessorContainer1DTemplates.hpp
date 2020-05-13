// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorcontainer1dtemplates.pas' rev: 21.00

#ifndef Jclpreprocessorcontainer1dtemplatesHPP
#define Jclpreprocessorcontainer1dtemplatesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclpreprocessorcontainertypes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessorcontainer1dtemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclContainerTypeInfo;
class PASCALIMPLEMENTATION TJclContainerTypeInfo : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Jclpreprocessorcontainertypes::TTypeAttributes FCustomTypeAttributes;
	Jclpreprocessorcontainertypes::TTypeAttributes *FKnownTypeAttributes;
	Classes::TNotifyEvent FOnKnownTypeChange;
	System::UnicodeString __fastcall GetCustomTypeAttribute(TTypeAttributeID Index);
	System::UnicodeString __fastcall GetTypeName(void);
	
protected:
	bool __fastcall GetFloatType(void);
	bool __fastcall GetKnownType(void);
	System::UnicodeString __fastcall GetOwnershipDeclaration(void);
	bool __fastcall GetStringType(void);
	bool __fastcall GetTObjectType(void);
	System::UnicodeString __fastcall GetTypeAttribute(TTypeAttributeID Index);
	void __fastcall SetKnownType(bool Value);
	void __fastcall SetTypeAttribute(TTypeAttributeID Index, const System::UnicodeString Value);
	void __fastcall SetTypeName(const System::UnicodeString Value);
	
public:
	__property bool FloatType = {read=GetFloatType, nodefault};
	__property bool KnownType = {read=GetKnownType, write=SetKnownType, nodefault};
	__property bool StringType = {read=GetStringType, nodefault};
	__property bool TObjectType = {read=GetTObjectType, nodefault};
	__property Jclpreprocessorcontainertypes::PKnownTypeAttributes KnownTypeAttributes = {read=FKnownTypeAttributes};
	__property System::UnicodeString CustomTypeAttributes[TTypeAttributeID Index] = {read=GetCustomTypeAttribute};
	__property System::UnicodeString TypeAttributes[TTypeAttributeID Index] = {read=GetTypeAttribute, write=SetTypeAttribute};
	__property System::UnicodeString TypeName = {read=GetTypeName, write=SetTypeName, stored=true};
	__property System::UnicodeString OwnershipDeclaration = {read=GetOwnershipDeclaration};
	__property Classes::TNotifyEvent OnKnownTypeChange = {read=FOnKnownTypeChange, write=FOnKnownTypeChange};
public:
	/* TObject.Create */ inline __fastcall TJclContainerTypeInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclContainerTypeInfo(void) { }
	
};


class DELPHICLASS TJclContainerInterfaceParams;
class PASCALIMPLEMENTATION TJclContainerInterfaceParams : public Jclpreprocessorcontainertypes::TJclInterfaceParams
{
	typedef Jclpreprocessorcontainertypes::TJclInterfaceParams inherited;
	
private:
	TJclContainerTypeInfo* FTypeInfo;
	
protected:
	virtual System::UnicodeString __fastcall GetOwnershipDeclaration(void);
	System::UnicodeString __fastcall GetTypeAttribute(TTypeAttributeID Index);
	bool __fastcall IsTypeAttributeStored(TTypeAttributeID Index);
	void __fastcall SetTypeAttribute(TTypeAttributeID Index, const System::UnicodeString Value);
	
public:
	__property TJclContainerTypeInfo* TypeInfo = {read=FTypeInfo, write=FTypeInfo};
	__property System::UnicodeString OwnershipDeclaration = {read=GetOwnershipDeclaration};
public:
	/* TObject.Create */ inline __fastcall TJclContainerInterfaceParams(void) : Jclpreprocessorcontainertypes::TJclInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclContainerInterfaceParams(void) { }
	
};


class DELPHICLASS TJclClassInterfaceParams;
class PASCALIMPLEMENTATION TJclClassInterfaceParams : public TJclContainerInterfaceParams
{
	typedef TJclContainerInterfaceParams inherited;
	
protected:
	System::UnicodeString FAncestorClassName;
	System::UnicodeString FInterfaceAdditional;
	System::UnicodeString FSectionAdditional;
	virtual System::UnicodeString __fastcall GetAncestorClassName(void);
	virtual System::UnicodeString __fastcall GetInterfaceAdditional(void);
	virtual System::UnicodeString __fastcall GetSectionAdditional(void);
	
public:
	__property System::UnicodeString AncestorClassName = {read=GetAncestorClassName, write=FAncestorClassName};
	__property System::UnicodeString InterfaceAdditional = {read=GetInterfaceAdditional, write=FInterfaceAdditional};
	__property System::UnicodeString SectionAdditional = {read=GetSectionAdditional, write=FSectionAdditional};
public:
	/* TObject.Create */ inline __fastcall TJclClassInterfaceParams(void) : TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClassInterfaceParams(void) { }
	
};


class DELPHICLASS TJclCollectionInterfaceParams;
class PASCALIMPLEMENTATION TJclCollectionInterfaceParams : public TJclClassInterfaceParams
{
	typedef TJclClassInterfaceParams inherited;
	
protected:
	System::UnicodeString FCollectionFlags;
	virtual System::UnicodeString __fastcall GetAncestorClassName(void);
	virtual System::UnicodeString __fastcall GetCollectionFlags(void);
	virtual System::UnicodeString __fastcall GetInterfaceAdditional(void);
	
public:
	__property System::UnicodeString CollectionFlags = {read=GetCollectionFlags, write=FCollectionFlags};
public:
	/* TObject.Create */ inline __fastcall TJclCollectionInterfaceParams(void) : TJclClassInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCollectionInterfaceParams(void) { }
	
};


class DELPHICLASS TJclTypeParams;
class PASCALIMPLEMENTATION TJclTypeParams : public TJclContainerInterfaceParams
{
	typedef TJclContainerInterfaceParams inherited;
	
__published:
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=0};
	__property System::UnicodeString Condition = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=1};
	__property System::UnicodeString Defines = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=2};
	__property System::UnicodeString Undefs = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=3};
	__property System::UnicodeString Alias = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=4};
	__property System::UnicodeString AliasCondition = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=5};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=6};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=7};
	__property System::UnicodeString OwnershipParameter = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=8};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=11};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=15};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=16};
	__property System::UnicodeString DynArrayTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=17};
	__property System::UnicodeString ArrayName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=18};
	__property System::UnicodeString BaseContainer = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=19};
	__property System::UnicodeString BaseCollection = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=20};
	__property System::UnicodeString ContainerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=29};
	__property System::UnicodeString ContainerInterfaceGUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=30};
	__property System::UnicodeString FlatContainerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=31};
	__property System::UnicodeString FlatContainerInterfaceGUID = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=32};
public:
	/* TObject.Create */ inline __fastcall TJclTypeParams(void) : TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTypeParams(void) { }
	
};


class DELPHICLASS TJclContainerImplementationParams;
class PASCALIMPLEMENTATION TJclContainerImplementationParams : public Jclpreprocessorcontainertypes::TJclImplementationParams
{
	typedef Jclpreprocessorcontainertypes::TJclImplementationParams inherited;
	
private:
	TJclContainerTypeInfo* __fastcall GetTypeInfo(void);
	
protected:
	virtual System::UnicodeString __fastcall GetOwnershipDeclaration(void);
	System::UnicodeString __fastcall GetTypeAttribute(TTypeAttributeID Index);
	bool __fastcall IsTypeAttributeStored(TTypeAttributeID Index);
	void __fastcall SetTypeAttribute(TTypeAttributeID Index, const System::UnicodeString Value);
	
public:
	__property System::UnicodeString OwnershipDeclaration = {read=GetOwnershipDeclaration};
	__property TJclContainerTypeInfo* TypeInfo = {read=GetTypeInfo};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclContainerImplementationParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainertypes::TJclImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclContainerImplementationParams(void) { }
	
};


class DELPHICLASS TJclClassImplementationParams;
class PASCALIMPLEMENTATION TJclClassImplementationParams : public TJclContainerImplementationParams
{
	typedef TJclContainerImplementationParams inherited;
	
protected:
	System::UnicodeString FMacroFooter;
	virtual System::UnicodeString __fastcall GetConstructorParameters(void) = 0 ;
	virtual System::UnicodeString __fastcall GetSelfClassName(void) = 0 ;
	
public:
	virtual System::UnicodeString __fastcall GetMacroFooter(void);
	virtual void __fastcall ResetDefault(bool Value);
	__property System::UnicodeString MacroFooter = {read=GetMacroFooter, write=FMacroFooter};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclClassImplementationParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclContainerImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClassImplementationParams(void) { }
	
};


class DELPHICLASS TJclCollectionImplementationParams;
class PASCALIMPLEMENTATION TJclCollectionImplementationParams : public TJclClassImplementationParams
{
	typedef TJclClassImplementationParams inherited;
	
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclCollectionImplementationParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclClassImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCollectionImplementationParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorcontainer1dtemplates */
using namespace Jclpreprocessorcontainer1dtemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Jclpreprocessorcontainer1dtemplatesHPP
