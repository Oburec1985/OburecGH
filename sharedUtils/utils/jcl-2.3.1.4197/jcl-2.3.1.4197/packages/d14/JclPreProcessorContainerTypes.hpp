// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorcontainertypes.pas' rev: 21.00

#ifndef JclpreprocessorcontainertypesHPP
#define JclpreprocessorcontainertypesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclpreprocessortemplates.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclnotify.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#define TTypeAttributeID int
#define TKeyAttributeID int
#define TValueAttributeID int
#define TMapAttributeID int

namespace Jclpreprocessorcontainertypes
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TAllTypeAttributeID { taTypeName, taCondition, taDefines, taUndefs, taAlias, taAliasCondition, taDefaultValue, taConstKeyword, taOwnershipParameter, taOwnershipInterfaceName, taOwnershipInterfaceGUID, taReleaserName, taReleaseEventName, taReleaseEventTypeName, taGetterName, taSetterName, taParameterName, taDynArrayTypeName, taArrayName, taBaseContainer, taBaseCollection, taIterateProcedureName, taApplyFunctionName, taCompareFunctionName, taSimpleCompareFunctionName, taEqualityCompareFunctionName, taSimpleEqualityCompareFunctionName, taHashConvertFunctionName, taSimpleHashConvertFunctionName, taContainerInterfaceName, taContainerInterfaceGUID, taFlatContainerInterfaceName, taFlatContainerInterfaceGUID, taEqualityComparerInterfaceName, taEqualityComparerInterfaceGUID, taComparerInterfaceName, taComparerInterfaceGUID, taHashConverterInterfaceName, taHashConverterInterfaceGUID, taIteratorInterfaceName, taIteratorInterfaceGUID, taBinaryTreeIteratorInterfaceName, taBinaryTreeIteratorInterfaceGUID, 
	taBinaryTreeNodeTypeName, taBinaryTreeClassName, taBinaryTreeBaseIteratorClassName, taBinaryTreePreOrderIteratorClassName, taBinaryTreeInOrderIteratorClassName, taBinaryTreePostOrderIteratorClassName, taCollectionInterfaceName, taCollectionInterfaceGUID, taListInterfaceName, taListInterfaceGUID, taSortProcedureName, taArrayInterfaceName, taArrayInterfaceGUID, taArrayListClassName, taArrayIteratorClassName, taLinkedListItemClassName, taLinkedListClassName, taLinkedListIteratorClassName, taVectorClassName, taVectorIteratorClassName, taSetInterfaceName, taSetInterfaceGUID, taArraySetClassName, taTreeIteratorInterfaceName, taTreeIteratorInterfaceGUID, taTreeInterfaceName, taTreeInterfaceGUID, taTreeNodeClassName, taTreeClassName, taTreeBaseIteratorClassName, taTreePreOrderIteratorClassName, taTreePostOrderIteratorClassName, taQueueInterfaceName, taQueueInterfaceGUID, taQueueClassName, taSortedSetInterfaceName, taSortedSetInterfaceGUID, taStackInterfaceName, taStackInterfaceGUID, taStackClassName, kaKeyTypeName, kaKeyOwnershipParameter
	, kaKeyConstKeyword, kaKeyParameterName, kaKeyDefaultValue, kaKeySimpleCompareFunctionName, kaKeySimpleEqualityCompareFunctionName, kaKeySimpleHashConvertFunctionName, kaKeyBaseContainerClassName, kaKeyIteratorInterfaceName, kaKeySetInterfaceName, kaKeyArraySetClassName, vaValueTypeName, vaValueOwnershipParameter, vaValueConstKeyword, vaValueDefaultValue, vaValueSimpleCompareFunctionName, vaValueSimpleEqualityCompareFunctionName, vaValueBaseContainerClassName, vaValueCollectionInterfaceName, vaValueArrayListClassName, maMapInterfaceName, maMapInterfaceGUID, maMapInterfaceAncestorName, maSortedMapInterfaceName, maSortedMapInterfaceGUID, maMapAncestorClassName, maHashMapEntryTypeName, maHashMapBucketTypeName, maHashMapClassName, maSortedMapEntryTypeName, maSortedMapClassName };
#pragma option pop

typedef Set<TAllTypeAttributeID, taTypeName, maSortedMapClassName>  TAllTypeAttributeIDs;

typedef StaticArray<System::UnicodeString, 83> TTypeAttributes;

typedef TTypeAttributes TKnownTypeAttributes;

typedef TTypeAttributes *PKnownTypeAttributes;

typedef StaticArray<System::UnicodeString, 11> TMapAttributes;

struct TKnownMapAttributes
{
	
public:
	TMapAttributes MapAttributes;
	TTypeAttributes *KeyAttributes;
	TTypeAttributes *ValueAttributes;
};


typedef TKnownMapAttributes *PKnownMapAttributes;

struct TTypeAttributeInfo
{
	
public:
	bool IsGUID;
	System::UnicodeString DefaultValue;
};


typedef StaticArray<TTypeAttributeInfo, 83> Jclpreprocessorcontainertypes__1;

typedef StaticArray<TTypeAttributeInfo, 11> Jclpreprocessorcontainertypes__2;

class DELPHICLASS EJclContainerException;
class PASCALIMPLEMENTATION EJclContainerException : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclContainerException(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclContainerException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclContainerException(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclContainerException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclContainerException(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclContainerException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclContainerException(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclContainerException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclContainerException(void) { }
	
};


#pragma option push -b-
enum TCodeLocation { clDefault, clAtCursor, clInterface, clImplementation };
#pragma option pop

class DELPHICLASS TJclMacroParams;
class PASCALIMPLEMENTATION TJclMacroParams : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	virtual bool __fastcall IsDefault(void);
	virtual void __fastcall ResetDefault(bool Value);
	virtual System::UnicodeString __fastcall GetMacroHeader(void);
	virtual System::UnicodeString __fastcall GetMacroFooter(void);
public:
	/* TObject.Create */ inline __fastcall TJclMacroParams(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMacroParams(void) { }
	
};


class DELPHICLASS TJclInterfaceParams;
class PASCALIMPLEMENTATION TJclInterfaceParams : public TJclMacroParams
{
	typedef TJclMacroParams inherited;
	
public:
	virtual TAllTypeAttributeIDs __fastcall AliasAttributeIDs(void);
public:
	/* TObject.Create */ inline __fastcall TJclInterfaceParams(void) : TJclMacroParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclInterfaceParams(void) { }
	
};


typedef TMetaClass* TJclInterfaceParamsClass;

class DELPHICLASS TJclImplementationParams;
class PASCALIMPLEMENTATION TJclImplementationParams : public TJclMacroParams
{
	typedef TJclMacroParams inherited;
	
private:
	TJclInterfaceParams* FInterfaceParams;
	
public:
	__fastcall TJclImplementationParams(TJclInterfaceParams* AInterfaceParams);
	__property TJclInterfaceParams* InterfaceParams = {read=FInterfaceParams};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclImplementationParams(void) { }
	
};


typedef TMetaClass* TJclImplementationParamsClass;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclpreprocessorcontainertypes__1 TypeAttributeInfos;
extern PACKAGE StaticArray<TTypeAttributeID, 12> KeyAttributeInfos;
extern PACKAGE StaticArray<TTypeAttributeID, 9> ValueAttributeInfos;
extern PACKAGE Jclpreprocessorcontainertypes__2 MapAttributeInfos;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessorcontainertypes */
using namespace Jclpreprocessorcontainertypes;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorcontainertypesHPP
