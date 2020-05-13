// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorqueuestemplates.pas' rev: 21.00

#ifndef JclpreprocessorqueuestemplatesHPP
#define JclpreprocessorqueuestemplatesHPP

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

namespace Jclpreprocessorqueuestemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclQueueIntParams;
class PASCALIMPLEMENTATION TJclQueueIntParams : public Jclpreprocessorcontainer1dtemplates::TJclClassInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclClassInterfaceParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetInterfaceAdditional(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=77};
	__property System::UnicodeString QueueInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=75};
	__property AncestorClassName;
	__property System::UnicodeString DynArrayTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=17};
	__property System::UnicodeString EqualityComparerInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=33};
	__property InterfaceAdditional;
	__property SectionAdditional;
	__property OwnershipDeclaration;
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclQueueIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclClassInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclQueueIntParams(void) { }
	
};


class DELPHICLASS TJclQueueImpParams;
class PASCALIMPLEMENTATION TJclQueueImpParams : public Jclpreprocessorcontainer1dtemplates::TJclClassImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclClassImplementationParams inherited;
	
public:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=77};
	__property OwnershipDeclaration;
	__property System::UnicodeString OwnershipParameter = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=8};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString DefaultValue = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=6};
	__property System::UnicodeString ReleaserName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=11};
	__property MacroFooter;
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclQueueImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclClassImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclQueueImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorqueuestemplates */
using namespace Jclpreprocessorqueuestemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorqueuestemplatesHPP
