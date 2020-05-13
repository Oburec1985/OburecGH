// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorbinarytreestemplates.pas' rev: 21.00

#ifndef JclpreprocessorbinarytreestemplatesHPP
#define JclpreprocessorbinarytreestemplatesHPP

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

namespace Jclpreprocessorbinarytreestemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclBinaryTreeTypeIntParams;
class PASCALIMPLEMENTATION TJclBinaryTreeTypeIntParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=43};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclBinaryTreeTypeIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryTreeTypeIntParams(void) { }
	
};


class DELPHICLASS TJclBinaryTreeIntParams;
class PASCALIMPLEMENTATION TJclBinaryTreeIntParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams inherited;
	
private:
	System::UnicodeString FConstructorDeclarations;
	
protected:
	System::UnicodeString __fastcall GetConstructorDeclarations(void);
	virtual System::UnicodeString __fastcall GetInterfaceAdditional(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	virtual void __fastcall ResetDefault(bool Value);
	
__published:
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=43};
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=44};
	__property AncestorClassName;
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString CompareFunctionName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString ComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=35};
	__property System::UnicodeString TreeInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=68};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString TreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property InterfaceAdditional;
	__property SectionAdditional;
	__property System::UnicodeString ConstructorDeclarations = {read=GetConstructorDeclarations, write=FConstructorDeclarations};
	__property OwnershipDeclaration;
	__property CollectionFlags;
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclBinaryTreeIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryTreeIntParams(void) { }
	
};


class DELPHICLASS TJclBinaryTreeItrIntParams;
class PASCALIMPLEMENTATION TJclBinaryTreeItrIntParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString BaseItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=45};
	__property System::UnicodeString PreOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=46};
	__property System::UnicodeString InOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=47};
	__property System::UnicodeString PostOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=48};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString StdTreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property System::UnicodeString BinTreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=41};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=43};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TObject.Create */ inline __fastcall TJclBinaryTreeItrIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryTreeItrIntParams(void) { }
	
};


class DELPHICLASS TJclBinaryTreeImpParams;
class PASCALIMPLEMENTATION TJclBinaryTreeImpParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams inherited;
	
private:
	System::UnicodeString FConstructorAssignments;
	System::UnicodeString FConstructorDeclarations;
	
protected:
	System::UnicodeString __fastcall GetConstructorAssignments(void);
	System::UnicodeString __fastcall GetConstructorDeclarations(void);
	
public:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void);
	virtual void __fastcall ResetDefault(bool Value);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=44};
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=43};
	__property System::UnicodeString PreOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=46};
	__property System::UnicodeString InOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=47};
	__property System::UnicodeString PostOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=48};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString TreeItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=66};
	__property System::UnicodeString ConstructorDeclarations = {read=GetConstructorDeclarations, write=FConstructorDeclarations};
	__property System::UnicodeString ConstructorAssignments = {read=GetConstructorAssignments, write=FConstructorAssignments};
	__property System::UnicodeString CompareFunctionName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
	__property OwnershipDeclaration;
	__property System::UnicodeString OwnershipParameter = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=8};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=11};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property MacroFooter;
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclBinaryTreeImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryTreeImpParams(void) { }
	
};


class DELPHICLASS TJclBinaryTreeItrImpParams;
class PASCALIMPLEMENTATION TJclBinaryTreeItrImpParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams inherited;
	
__published:
	__property System::UnicodeString BaseItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=45};
	__property System::UnicodeString PreOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=46};
	__property System::UnicodeString InOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=47};
	__property System::UnicodeString PostOrderItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=48};
	__property System::UnicodeString StdItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString NodeTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=43};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=11};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclBinaryTreeItrImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBinaryTreeItrImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorbinarytreestemplates */
using namespace Jclpreprocessorbinarytreestemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorbinarytreestemplatesHPP
