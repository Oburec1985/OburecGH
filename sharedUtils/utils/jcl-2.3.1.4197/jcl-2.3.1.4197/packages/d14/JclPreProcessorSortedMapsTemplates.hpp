// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorsortedmapstemplates.pas' rev: 21.00

#ifndef JclpreprocessorsortedmapstemplatesHPP
#define JclpreprocessorsortedmapstemplatesHPP

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

namespace Jclpreprocessorsortedmapstemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclSortedMapTypeIntParams;
class PASCALIMPLEMENTATION TJclSortedMapTypeIntParams : public Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	
__published:
	__property System::UnicodeString EntryTypeName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=113};
	__property System::UnicodeString KeyTypeName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=83};
	__property System::UnicodeString ValueTypeName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=95};
public:
	/* TObject.Create */ inline __fastcall TJclSortedMapTypeIntParams(void) : Jclpreprocessorcontainer2dtemplates::TJclMapInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSortedMapTypeIntParams(void) { }
	
};


class DELPHICLASS TJclSortedMapIntParams;
class PASCALIMPLEMENTATION TJclSortedMapIntParams : public Jclpreprocessorcontainer2dtemplates::TJclMapClassInterfaceParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapClassInterfaceParams inherited;
	
public:
	virtual Jclpreprocessorcontainertypes::TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
	virtual System::UnicodeString __fastcall GetComparisonSectionAdditional(void);
	
__published:
	__property System::UnicodeString EntryTypeName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=113};
	__property System::UnicodeString SelfClassName = {read=GetMapAttribute, write=SetMapAttribute, stored=IsMapAttributeStored, index=114};
	__property System::UnicodeString AncestorName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=109};
	__property System::UnicodeString StdMapInterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=104};
	__property System::UnicodeString SortedMapInterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=107};
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
	/* TObject.Create */ inline __fastcall TJclSortedMapIntParams(void) : Jclpreprocessorcontainer2dtemplates::TJclMapClassInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSortedMapIntParams(void) { }
	
};


class DELPHICLASS TJclSortedMapImpParams;
class PASCALIMPLEMENTATION TJclSortedMapImpParams : public Jclpreprocessorcontainer2dtemplates::TJclMapClassImplementationParams
{
	typedef Jclpreprocessorcontainer2dtemplates::TJclMapClassImplementationParams inherited;
	
public:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void);
	virtual System::UnicodeString __fastcall GetMacroFooter(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void);
	
__published:
	__property System::UnicodeString SelfClassName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=114};
	__property System::UnicodeString AncestorClassName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=109};
	__property System::UnicodeString StdMapInterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=104};
	__property System::UnicodeString SortedMapInterfaceName = {read=GetMapAttribute, write=SetMapAttribute, stored=false, index=107};
	__property System::UnicodeString KeySetInterfaceName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=93};
	__property System::UnicodeString KeyItrInterfaceName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=92};
	__property System::UnicodeString ValueCollectionInterfaceName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=102};
	__property KeyOwnershipDeclaration;
	__property ValueOwnershipDeclaration;
	__property OwnershipAssignments;
	__property System::UnicodeString KeyConstKeyword = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=85};
	__property KeyTypeName;
	__property KeyDefault;
	__property System::UnicodeString KeySimpleCompareFunctionName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=88};
	__property System::UnicodeString KeyBaseContainer = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=91};
	__property System::UnicodeString ValueConstKeyword = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=97};
	__property ValueTypeName;
	__property ValueDefault;
	__property System::UnicodeString ValueSimpleCompareFunctionName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=99};
	__property System::UnicodeString ValueBaseContainerClassName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=101};
	__property CreateKeySet;
	__property CreateValueCollection;
	__property MacroFooter;
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclSortedMapImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer2dtemplates::TJclMapClassImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSortedMapImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorsortedmapstemplates */
using namespace Jclpreprocessorsortedmapstemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorsortedmapstemplatesHPP
