// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorhashmapstemplates.pas' rev: 21.00

#ifndef JclpreprocessorhashmapstemplatesHPP
#define JclpreprocessorhashmapstemplatesHPP

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
#include <Jclpreprocessorcontainer2dtemplates.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessorhashmapstemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclHashMapTypeIntParams;
class PASCALIMPLEMENTATION TJclHashMapTypeIntParams : public Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString EntryTypeName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=110};
	__property System::UnicodeString BucketTypeName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=111};
	__property System::UnicodeString KeyTypeName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=83};
	__property System::UnicodeString ValueTypeName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=95};
public:
	/* TObject.Create */ inline __fastcall TJclHashMapTypeIntParams(void) : Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclHashMapTypeIntParams(void) { }
	
};


class DELPHICLASS TJclHashMapIntParams;
class PASCALIMPLEMENTATION TJclHashMapIntParams : public Jclpreprocessorcontainer2dtemplates::TJclMapClassInterfaceParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapClassInterfaceParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetComparisonSectionAdditional(void);
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString BucketTypeName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=111};
	__property System::UnicodeString SelfClassName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=112};
	__property System::UnicodeString AncestorName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=109};
	__property System::UnicodeString MapInterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=104};
	__property System::UnicodeString KeySetInterfaceName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=93};
	__property System::UnicodeString ValueCollectionInterfaceName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=102};
	__property InterfaceAdditional;
	__property SectionAdditional;
	__property KeyOwnershipDeclaration;
	__property ValueOwnershipDeclaration;
	__property System::UnicodeString KeyConstKeyword = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=85};
	__property KeyTypeName;
	__property System::UnicodeString ValueConstKeyword = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=97};
	__property ValueTypeName;
public:
	/* TObject.Create */ inline __fastcall TJclHashMapIntParams(void) : Jclpreprocessorcontainer2dtemplates::TJclMapClassInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclHashMapIntParams(void) { }
	
};


class DELPHICLASS TJclHashMapTypeImpParams;
class PASCALIMPLEMENTATION TJclHashMapTypeImpParams : public Jclpreprocessorcontainer2dtemplates::TJclMapImplementationParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapImplementationParams inherited;
	
__published:
	__property System::UnicodeString BucketTypeName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=111};
	__property System::UnicodeString KeyDefault = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=87};
	__property System::UnicodeString ValueDefault = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=98};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclHashMapTypeImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer2dtemplates::TJclMapImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclHashMapTypeImpParams(void) { }
	
};


class DELPHICLASS TJclHashMapImpParams;
class PASCALIMPLEMENTATION TJclHashMapImpParams : public Jclpreprocessorcontainer2dtemplates::TJclMapClassImplementationParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapClassImplementationParams inherited;
	
public:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void);
	virtual System::UnicodeString __fastcall GetMacroFooter(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=112};
	__property System::UnicodeString AncestorClassName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=109};
	__property System::UnicodeString BucketTypeName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=111};
	__property System::UnicodeString MapInterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=104};
	__property System::UnicodeString KeySetInterfaceName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=93};
	__property KeyArraySetClassName;
	__property System::UnicodeString KeyItrInterfaceName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=92};
	__property System::UnicodeString ValueCollectionInterfaceName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=102};
	__property ValueArrayListClassName;
	__property KeyOwnershipDeclaration;
	__property ValueOwnershipDeclaration;
	__property OwnershipAssignments;
	__property System::UnicodeString KeyConstKeyword = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=85};
	__property System::UnicodeString KeyParameterName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=86};
	__property KeyTypeName;
	__property KeyDefault;
	__property System::UnicodeString KeySimpleEqualityCompareFunctionName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=89};
	__property System::UnicodeString KeySimpleHashConvertFunctionName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=90};
	__property System::UnicodeString KeyBaseContainer = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=91};
	__property System::UnicodeString ValueConstKeyword = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=97};
	__property ValueTypeName;
	__property ValueDefault;
	__property System::UnicodeString ValueSimpleEqualityCompareFunctionName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=100};
	__property System::UnicodeString ValueBaseContainerClassName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=101};
	__property CreateKeySet;
	__property CreateValueCollection;
	__property MacroFooter;
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclHashMapImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer2dtemplates::TJclMapClassImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclHashMapImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorhashmapstemplates */
using namespace Jclpreprocessorhashmapstemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorhashmapstemplatesHPP
