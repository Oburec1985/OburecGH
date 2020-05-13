// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorcontainer2dtemplates.pas' rev: 21.00

#ifndef Jclpreprocessorcontainer2dtemplatesHPP
#define Jclpreprocessorcontainer2dtemplatesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclpreprocessorcontainertypes.hpp>	// Pascal unit
#include <Jclpreprocessorcontainer1dtemplates.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessorcontainer2dtemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclContainerMapInfo;
class PASCALIMPLEMENTATION TJclContainerMapInfo : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Jclpreprocessorcontainertypes::TMapAttributes FCustomMapAttributes;
	Jclpreprocessorcontainertypes::TKnownMapAttributes *FKnownMapAttributes;
	Jclpreprocessorcontainer1dtemplates::TJclContainerTypeInfo* FValueTypeInfo;
	Jclpreprocessorcontainer1dtemplates::TJclContainerTypeInfo* FKeyTypeInfo;
	System::UnicodeString __fastcall GetCustomMapAttribute(TMapAttributeID Index);
	System::UnicodeString __fastcall GetKeyAttribute(TKeyAttributeID Index);
	System::UnicodeString __fastcall GetValueAttribute(TValueAttributeID Index);
	void __fastcall SetKeyAttribute(TKeyAttributeID Index, const System::UnicodeString Value);
	void __fastcall SetValueAttribute(TValueAttributeID Index, const System::UnicodeString Value);
	System::UnicodeString __fastcall GetKeyOwnershipDeclaration(void);
	System::UnicodeString __fastcall GetValueOwnershipDeclaration(void);
	
protected:
	bool __fastcall GetKnownMap(void);
	System::UnicodeString __fastcall GetMapAttribute(TMapAttributeID Index);
	bool __fastcall IsMapAttributeStored(TMapAttributeID Index);
	void __fastcall SetKnownMap(bool Value);
	void __fastcall SetMapAttribute(TMapAttributeID Index, const System::UnicodeString Value);
	void __fastcall TypeKnownTypeChange(System::TObject* Sender);
	
public:
	__fastcall TJclContainerMapInfo(void);
	__fastcall virtual ~TJclContainerMapInfo(void);
	__property bool KnownMap = {read=GetKnownMap, write=SetKnownMap, nodefault};
	__property Jclpreprocessorcontainertypes::PKnownMapAttributes KnownMapAttributes = {read=FKnownMapAttributes};
	__property System::UnicodeString CustomMapAttributes[TMapAttributeID Index] = {read=GetCustomMapAttribute};
	__property System::UnicodeString MapAttributes[TMapAttributeID Index] = {read=GetMapAttribute, write=SetMapAttribute};
	__property System::UnicodeString KeyAttributes[TKeyAttributeID Index] = {read=GetKeyAttribute, write=SetKeyAttribute};
	__property Jclpreprocessorcontainer1dtemplates::TJclContainerTypeInfo* KeyTypeInfo = {read=FKeyTypeInfo};
	__property System::UnicodeString KeyOwnershipDeclaration = {read=GetKeyOwnershipDeclaration};
	__property System::UnicodeString ValueAttributes[TValueAttributeID Index] = {read=GetValueAttribute, write=SetValueAttribute};
	__property Jclpreprocessorcontainer1dtemplates::TJclContainerTypeInfo* ValueTypeInfo = {read=FValueTypeInfo};
	__property System::UnicodeString ValueOwnershipDeclaration = {read=GetValueOwnershipDeclaration};
};


class DELPHICLASS TJclMapInterfaceParams;
class PASCALIMPLEMENTATION TJclMapInterfaceParams : public Jclpreprocessorcontainertypes::TJclInterfaceParams
{
	typedef Jclpreprocessorcontainertypes::TJclInterfaceParams inherited;
	
private:
	TJclContainerMapInfo* FMapInfo;
	System::UnicodeString __fastcall GetKeyOwnershipDeclaration(void);
	System::UnicodeString __fastcall GetValueOwnershipDeclaration(void);
	
protected:
	System::UnicodeString __fastcall GetKeyAttribute(TKeyAttributeID Index);
	System::UnicodeString __fastcall GetMapAttribute(TMapAttributeID Index);
	System::UnicodeString __fastcall GetValueAttribute(TValueAttributeID Index);
	bool __fastcall IsMapAttributeStored(TMapAttributeID Index);
	void __fastcall SetKeyAttribute(TKeyAttributeID Index, const System::UnicodeString Value);
	void __fastcall SetMapAttribute(TMapAttributeID Index, const System::UnicodeString Value);
	void __fastcall SetValueAttribute(TValueAttributeID Index, const System::UnicodeString Value);
	
public:
	__property System::UnicodeString KeyOwnershipDeclaration = {read=GetKeyOwnershipDeclaration};
	__property TJclContainerMapInfo* MapInfo = {read=FMapInfo, write=FMapInfo};
	__property System::UnicodeString ValueOwnershipDeclaration = {read=GetValueOwnershipDeclaration};
public:
	/* TObject.Create */ inline __fastcall TJclMapInterfaceParams(void) : Jclpreprocessorcontainertypes::TJclInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMapInterfaceParams(void) { }
	
};


class DELPHICLASS TJclMapClassInterfaceParams;
class PASCALIMPLEMENTATION TJclMapClassInterfaceParams : public TJclMapInterfaceParams
{
	typedef TJclMapInterfaceParams inherited;
	
protected:
	System::UnicodeString FInterfaceAdditional;
	System::UnicodeString FSectionAdditional;
	virtual System::UnicodeString __fastcall GetInterfaceAdditional(void);
	virtual System::UnicodeString __fastcall GetSectionAdditional(void);
	virtual System::UnicodeString __fastcall GetComparisonSectionAdditional(void) = 0 ;
	
public:
	__property System::UnicodeString InterfaceAdditional = {read=GetInterfaceAdditional, write=FInterfaceAdditional};
	__property System::UnicodeString SectionAdditional = {read=GetSectionAdditional, write=FSectionAdditional};
	__property System::UnicodeString KeyTypeName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=83};
	__property System::UnicodeString ValueTypeName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=95};
public:
	/* TObject.Create */ inline __fastcall TJclMapClassInterfaceParams(void) : TJclMapInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMapClassInterfaceParams(void) { }
	
};


class DELPHICLASS TJclMapImplementationParams;
class PASCALIMPLEMENTATION TJclMapImplementationParams : public Jclpreprocessorcontainertypes::TJclImplementationParams
{
	typedef Jclpreprocessorcontainertypes::TJclImplementationParams inherited;
	
private:
	System::UnicodeString __fastcall GetKeyOwnershipDeclaration(void);
	System::UnicodeString __fastcall GetValueOwnershipDeclaration(void);
	TJclContainerMapInfo* __fastcall GetMapInfo(void);
	
protected:
	System::UnicodeString __fastcall GetKeyAttribute(TKeyAttributeID Index);
	System::UnicodeString __fastcall GetMapAttribute(TMapAttributeID Index);
	System::UnicodeString __fastcall GetValueAttribute(TValueAttributeID Index);
	void __fastcall SetKeyAttribute(TKeyAttributeID Index, const System::UnicodeString Value);
	void __fastcall SetMapAttribute(TMapAttributeID Index, const System::UnicodeString Value);
	void __fastcall SetValueAttribute(TValueAttributeID Index, const System::UnicodeString Value);
	
public:
	__property System::UnicodeString KeyOwnershipDeclaration = {read=GetKeyOwnershipDeclaration};
	__property System::UnicodeString ValueOwnershipDeclaration = {read=GetValueOwnershipDeclaration};
	__property TJclContainerMapInfo* MapInfo = {read=GetMapInfo};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclMapImplementationParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainertypes::TJclImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMapImplementationParams(void) { }
	
};


class DELPHICLASS TJclMapClassImplementationParams;
class PASCALIMPLEMENTATION TJclMapClassImplementationParams : public TJclMapImplementationParams
{
	typedef TJclMapImplementationParams inherited;
	
protected:
	System::UnicodeString FCreateKeySet;
	System::UnicodeString FCreateValueCollection;
	System::UnicodeString FMacroFooter;
	System::UnicodeString FOwnershipAssignments;
	System::UnicodeString __fastcall GetCreateKeySet(void);
	System::UnicodeString __fastcall GetCreateValueCollection(void);
	System::UnicodeString __fastcall GetOwnershipAssignment(void);
	virtual System::UnicodeString __fastcall GetSelfClassName(void) = 0 ;
	
public:
	virtual System::UnicodeString __fastcall GetConstructorParameters(void) = 0 ;
	virtual System::UnicodeString __fastcall GetMacroFooter(void);
	virtual void __fastcall ResetDefault(bool Value);
	__property System::UnicodeString MacroFooter = {read=GetMacroFooter, write=FMacroFooter};
	__property System::UnicodeString KeyTypeName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=83};
	__property System::UnicodeString KeyDefault = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=87};
	__property System::UnicodeString KeyArraySetClassName = {read=GetKeyAttribute, write=SetKeyAttribute, stored=false, index=94};
	__property System::UnicodeString ValueTypeName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=95};
	__property System::UnicodeString ValueDefault = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=98};
	__property System::UnicodeString ValueArrayListClassName = {read=GetValueAttribute, write=SetValueAttribute, stored=false, index=103};
	__property System::UnicodeString OwnershipAssignments = {read=GetOwnershipAssignment, write=FOwnershipAssignments};
	__property System::UnicodeString CreateKeySet = {read=GetCreateKeySet, write=FCreateKeySet};
	__property System::UnicodeString CreateValueCollection = {read=GetCreateValueCollection, write=FCreateValueCollection};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclMapClassImplementationParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclMapImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMapClassImplementationParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorcontainer2dtemplates */
using namespace Jclpreprocessorcontainer2dtemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Jclpreprocessorcontainer2dtemplatesHPP
