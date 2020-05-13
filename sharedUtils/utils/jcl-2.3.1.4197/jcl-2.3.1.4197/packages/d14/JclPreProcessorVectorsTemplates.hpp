// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorvectorstemplates.pas' rev: 21.00

#ifndef JclpreprocessorvectorstemplatesHPP
#define JclpreprocessorvectorstemplatesHPP

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

namespace Jclpreprocessorvectorstemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclVectorIntParams;
class PASCALIMPLEMENTATION TJclVectorIntParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetInterfaceAdditional(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=61};
	__property AncestorClassName;
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString ArrayInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=54};
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property InterfaceAdditional;
	__property SectionAdditional;
	__property CollectionFlags;
	__property OwnershipDeclaration;
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DynArrayType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=17};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TObject.Create */ inline __fastcall TJclVectorIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclVectorIntParams(void) { }
	
};


class DELPHICLASS TJclVectorItrIntParams;
class PASCALIMPLEMENTATION TJclVectorItrIntParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=62};
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ListClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=61};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TObject.Create */ inline __fastcall TJclVectorItrIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclVectorItrIntParams(void) { }
	
};


class DELPHICLASS TJclVectorImpParams;
class PASCALIMPLEMENTATION TJclVectorImpParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams inherited;
	
public:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=61};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ItrClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=62};
	__property OwnershipDeclaration;
	__property System::UnicodeString OwnershipParameter = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=8};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=11};
	__property MacroFooter;
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclVectorImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclVectorImpParams(void) { }
	
};


class DELPHICLASS TJclVectorItrImpParams;
class PASCALIMPLEMENTATION TJclVectorItrImpParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams inherited;
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=62};
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ListClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=61};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclVectorItrImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclVectorItrImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorvectorstemplates */
using namespace Jclpreprocessorvectorstemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorvectorstemplatesHPP
