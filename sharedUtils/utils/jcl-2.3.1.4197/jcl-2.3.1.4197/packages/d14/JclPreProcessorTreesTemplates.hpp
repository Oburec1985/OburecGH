// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessortreestemplates.pas' rev: 21.00

#ifndef JclpreprocessortreestemplatesHPP
#define JclpreprocessortreestemplatesHPP

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

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessortreestemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclTreeTypeIntParams;
class PASCALIMPLEMENTATION TJclTreeTypeIntParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=70};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclTreeTypeIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeTypeIntParams(void) { }
	
};


class DELPHICLASS TJclTreeIntParams;
class PASCALIMPLEMENTATION TJclTreeIntParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetOwnershipDeclaration(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=70};
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=71};
	__property AncestorClassName;
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString TreeInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=68};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString TreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property InterfaceAdditional;
	__property SectionAdditional;
	__property OwnershipDeclaration;
	__property CollectionFlags;
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
public:
	/* TObject.Create */ inline __fastcall TJclTreeIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeIntParams(void) { }
	
};


class DELPHICLASS TJclTreeItrIntParams;
class PASCALIMPLEMENTATION TJclTreeItrIntParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString BaseItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=72};
	__property System::UnicodeString PreOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=73};
	__property System::UnicodeString PostOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=74};
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=70};
	__property System::UnicodeString TreeClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=71};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString TreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TObject.Create */ inline __fastcall TJclTreeItrIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeItrIntParams(void) { }
	
};


class DELPHICLASS TJclTreeTypeImpParams;
class PASCALIMPLEMENTATION TJclTreeTypeImpParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams inherited;
	
__published:
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=70};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclTreeTypeImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeTypeImpParams(void) { }
	
};


class DELPHICLASS TJclTreeImpParams;
class PASCALIMPLEMENTATION TJclTreeImpParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void);
	virtual System::UnicodeString __fastcall GetOwnershipDeclaration(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=71};
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=70};
	__property System::UnicodeString PreOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=73};
	__property System::UnicodeString PostOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=74};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString TreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property OwnershipDeclaration;
	__property System::UnicodeString OwnershipParameter = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=8};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=11};
	__property MacroFooter;
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclTreeImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeImpParams(void) { }
	
};


class DELPHICLASS TJclTreeItrImpParams;
class PASCALIMPLEMENTATION TJclTreeItrImpParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams inherited;
	
__published:
	__property System::UnicodeString BaseItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=72};
	__property System::UnicodeString PreOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=73};
	__property System::UnicodeString PostOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=74};
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=70};
	__property System::UnicodeString TreeClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=71};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString TreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=11};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclTreeItrImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclTreeItrImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessortreestemplates */
using namespace Jclpreprocessortreestemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessortreestemplatesHPP
