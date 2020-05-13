// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorarraysetstemplates.pas' rev: 21.00

#ifndef JclpreprocessorarraysetstemplatesHPP
#define JclpreprocessorarraysetstemplatesHPP

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

namespace Jclpreprocessorarraysetstemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclArraySetIntParams;
class PASCALIMPLEMENTATION TJclArraySetIntParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetInterfaceAdditional(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=65};
	__property System::UnicodeString AncestorClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=56};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property System::UnicodeString ComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=35};
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString ArrayInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=54};
	__property System::UnicodeString SetInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=63};
	__property InterfaceAdditional;
	__property SectionAdditional;
	__property CollectionFlags;
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclArraySetIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclCollectionInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclArraySetIntParams(void) { }
	
};


class DELPHICLASS TJclArraySetImpParams;
class PASCALIMPLEMENTATION TJclArraySetImpParams : public Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams inherited;
	
public:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=65};
	__property System::UnicodeString CollectionInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=49};
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property MacroFooter;
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclArraySetImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclCollectionImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclArraySetImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorarraysetstemplates */
using namespace Jclpreprocessorarraysetstemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorarraysetstemplatesHPP
