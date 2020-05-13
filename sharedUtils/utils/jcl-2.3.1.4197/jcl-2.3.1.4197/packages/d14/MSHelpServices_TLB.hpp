// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Mshelpservices_tlb.pas' rev: 21.00

#ifndef Mshelpservices_tlbHPP
#define Mshelpservices_tlbHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Mshelpservices_tlb
{
//-- type declarations -------------------------------------------------------
typedef Activex::TOleEnum HxHierarchyNodeType;

typedef Activex::TOleEnum HxHierarchyPropId;

typedef Activex::TOleEnum HxTopicGetTitleType;

typedef Activex::TOleEnum HxTopicGetTitleDefVal;

typedef Activex::TOleEnum HxQueryPropId;

typedef Activex::TOleEnum HxTopicPropId;

typedef Activex::TOleEnum HxHierarchy_PrintNode_Options;

typedef Activex::TOleEnum HxQuery_Options;

typedef Activex::TOleEnum HxCollectionPropId;

typedef Activex::TOleEnum HxRegFilterPropId;

typedef Activex::TOleEnum HxIndexPropId;

typedef Activex::TOleEnum HxSampleFileCopyOption;

typedef Activex::TOleEnum HxRegNamespacePropId;

typedef Activex::TOleEnum HxRegTitlePropId;

typedef Activex::TOleEnum HxRegPlugInPropId;

typedef Activex::TOleEnum HxRegisterSession_InterfaceType;

typedef Activex::TOleEnum HxCancelStatus;

__interface IHxSession;
typedef System::DelphiInterface<IHxSession> _di_IHxSession;
typedef _di_IHxSession HxSession;

__interface IHxRegistryWalker;
typedef System::DelphiInterface<IHxRegistryWalker> _di_IHxRegistryWalker;
typedef _di_IHxRegistryWalker HxRegistryWalker;

__interface IHxRegisterSession;
typedef System::DelphiInterface<IHxRegisterSession> _di_IHxRegisterSession;
typedef _di_IHxRegisterSession HxRegisterSession;

__interface IHxRegisterProtocol;
typedef System::DelphiInterface<IHxRegisterProtocol> _di_IHxRegisterProtocol;
typedef _di_IHxRegisterProtocol HxRegisterProtocol;

typedef GUID *PUserType1;

typedef System::OleVariant *POleVariant1;

__interface IHxHierarchy;
typedef System::DelphiInterface<IHxHierarchy> _di_IHxHierarchy;
__interface IHxTopic;
typedef System::DelphiInterface<IHxTopic> _di_IHxTopic;
__interface  INTERFACE_UUID("{314111B2-A502-11D2-BBCA-00C04F8EC294}") IHxHierarchy  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetRoot(int &__GetRoot_result) = 0 ;
	virtual HRESULT __safecall GetParent(int hNode, int &__GetParent_result) = 0 ;
	virtual HRESULT __safecall GetSibling(int hNode, int &__GetSibling_result) = 0 ;
	virtual HRESULT __safecall GetFirstChild(int hNode, int &__GetFirstChild_result) = 0 ;
	virtual HRESULT __safecall GetNextFromUrl(const System::WideString pURL, int &__GetNextFromUrl_result) = 0 ;
	virtual HRESULT __safecall GetPrevFromUrl(const System::WideString pURL, int &__GetPrevFromUrl_result) = 0 ;
	virtual HRESULT __safecall GetType(int hNode, Activex::TOleEnum &__GetType_result) = 0 ;
	virtual HRESULT __safecall IsNew(int hNode, System::WordBool &__IsNew_result) = 0 ;
	virtual HRESULT __safecall HasChild(int hNode, System::WordBool &__HasChild_result) = 0 ;
	virtual HRESULT __safecall GetSyncInfo(const System::WideString pURL, Activex::PSafeArray &__GetSyncInfo_result) = 0 ;
	virtual HRESULT __safecall GetTitle(int hNode, System::WideString &__GetTitle_result) = 0 ;
	virtual HRESULT __safecall GetImageIndexes(int hNode, /* out */ int &pOpen, int &__GetImageIndexes_result) = 0 ;
	virtual HRESULT __safecall GetURL(int hNode, System::WideString &__GetURL_result) = 0 ;
	virtual HRESULT __safecall OnNavigation(const System::WideString pbstrURL, System::WordBool &__OnNavigation_result) = 0 ;
	virtual HRESULT __safecall OnHierarchyNavigation(int hNode) = 0 ;
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, int hNode, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall GetNextFromNode(int hNode, int &__GetNextFromNode_result) = 0 ;
	virtual HRESULT __safecall GetPrevFromNode(int hNode, int &__GetPrevFromNode_result) = 0 ;
	virtual HRESULT __safecall GetTopic(int hNode, _di_IHxTopic &__GetTopic_result) = 0 ;
	virtual HRESULT __safecall GetOpenImageIndex(int hNode, int &__GetOpenImageIndex_result) = 0 ;
	virtual HRESULT __safecall GetClosedImageIndex(int hNode, int &__GetClosedImageIndex_result) = 0 ;
	virtual HRESULT __safecall PrintNode(int hwnd, int hNode, Activex::TOleEnum options) = 0 ;
};

__interface IHxAttributeList;
typedef System::DelphiInterface<IHxAttributeList> _di_IHxAttributeList;
__interface  INTERFACE_UUID("{31411196-A502-11D2-BBCA-00C04F8EC294}") IHxTopic  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Title(Activex::TOleEnum optType, Activex::TOleEnum optDef, System::WideString &__Get_Title_result) = 0 ;
	virtual HRESULT __safecall Get_URL(System::WideString &__Get_URL_result) = 0 ;
	virtual HRESULT __safecall Get_Location(System::WideString &__Get_Location_result) = 0 ;
	virtual HRESULT __safecall Get_Rank(int &__Get_Rank_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(_di_IHxAttributeList &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall GetInfo(/* out */ System::WideString &pTitle, /* out */ System::WideString &pURL, /* out */ System::WideString &pLocation, /* out */ int &pRank) = 0 ;
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall SetProperty(Activex::TOleEnum propid, const System::OleVariant var_) = 0 ;
	virtual HRESULT __safecall HasAttribute(const System::WideString Name, const System::WideString Value, System::WordBool &__HasAttribute_result) = 0 ;
	virtual HRESULT __safecall HasAttrName(const System::WideString Name, System::WordBool &__HasAttrName_result) = 0 ;
	virtual HRESULT __safecall HighlightDocument(const _di_IDispatch pIDispatch) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Title(Activex::TOleEnum optType, Activex::TOleEnum optDef) { System::WideString __r; HRESULT __hr = Get_Title(optType, optDef, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Title[Activex::TOleEnum optType][Activex::TOleEnum optDef] = {read=_scw_Get_Title};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_URL() { System::WideString __r; HRESULT __hr = Get_URL(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString URL = {read=_scw_Get_URL};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Location() { System::WideString __r; HRESULT __hr = Get_Location(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Location = {read=_scw_Get_Location};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Rank() { int __r; HRESULT __hr = Get_Rank(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Rank = {read=_scw_Get_Rank};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IHxAttributeList _scw_Get_Attributes() { _di_IHxAttributeList __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IHxAttributeList Attributes = {read=_scw_Get_Attributes};
};

__interface IHxAttribute;
typedef System::DelphiInterface<IHxAttribute> _di_IHxAttribute;
__interface IEnumHxAttribute;
typedef System::DelphiInterface<IEnumHxAttribute> _di_IEnumHxAttribute;
__interface  INTERFACE_UUID("{314111AB-A502-11D2-BBCA-00C04F8EC294}") IHxAttributeList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxAttribute &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumAttribute(int filter, int options, _di_IEnumHxAttribute &__EnumAttribute_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxAttribute &__Item_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
};

__interface  INTERFACE_UUID("{314111A9-A502-11D2-BBCA-00C04F8EC294}") IHxAttribute  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall SetProperty(Activex::TOleEnum propid, const System::OleVariant var_) = 0 ;
	virtual HRESULT __safecall Get_Name(System::WideString &__Get_Name_result) = 0 ;
	virtual HRESULT __safecall Get_Value(System::WideString &__Get_Value_result) = 0 ;
	virtual HRESULT __safecall Get_DisplayName(System::WideString &__Get_DisplayName_result) = 0 ;
	virtual HRESULT __safecall Get_DisplayValue(System::WideString &__Get_DisplayValue_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Name() { System::WideString __r; HRESULT __hr = Get_Name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Name = {read=_scw_Get_Name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Value() { System::WideString __r; HRESULT __hr = Get_Value(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Value = {read=_scw_Get_Value};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_DisplayName() { System::WideString __r; HRESULT __hr = Get_DisplayName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString DisplayName = {read=_scw_Get_DisplayName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_DisplayValue() { System::WideString __r; HRESULT __hr = Get_DisplayValue(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString DisplayValue = {read=_scw_Get_DisplayValue};
};

__interface  INTERFACE_UUID("{314111AD-A502-11D2-BBCA-00C04F8EC294}") IEnumHxAttribute  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxAttribute &ppIHxAttribute, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxAttribute &ppEnum) = 0 ;
};

__interface IHxRegister;
typedef System::DelphiInterface<IHxRegister> _di_IHxRegister;
__interface  INTERFACE_UUID("{314111BC-A502-11D2-BBCA-00C04F8EC294}") IHxRegister  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall RegisterNamespace(const System::WideString bstrNamespace, const System::WideString bstrCollection, const System::WideString bstrDescription) = 0 ;
	virtual HRESULT __safecall IsNamespace(const System::WideString bstrNamespace, System::WordBool &__IsNamespace_result) = 0 ;
	virtual HRESULT __safecall GetCollection(const System::WideString bstrNamespace, System::WideString &__GetCollection_result) = 0 ;
	virtual HRESULT __safecall GetDescription(const System::WideString bstrNamespace, System::WideString &__GetDescription_result) = 0 ;
	virtual HRESULT __safecall RemoveNamespace(const System::WideString bstrNamespace) = 0 ;
	virtual HRESULT __safecall RegisterHelpFile(const System::WideString bstrNamespace, const System::WideString bstrId, int LangId, const System::WideString bstrHelpFile) = 0 ;
	virtual HRESULT __safecall RegisterMedia(const System::WideString bstrNamespace, const System::WideString bstrFriendly, const System::WideString bstrPath, int &__RegisterMedia_result) = 0 ;
	virtual HRESULT __safecall RemoveHelpFile(const System::WideString bstrNamespace, const System::WideString bstrId, int LangId) = 0 ;
	virtual HRESULT __safecall RegisterHelpFileSet(const System::WideString bstrNamespace, const System::WideString bstrId, int LangId, const System::WideString bstrHxs, const System::WideString bstrHxi, const System::WideString bstrHxq, const System::WideString bstrHxr, int lHxsMediaId, int lHxqMediaId, int lHxrMediaId, int lSampleMediaId) = 0 ;
};

__interface IHxIndex;
typedef System::DelphiInterface<IHxIndex> _di_IHxIndex;
__interface IHxTopicList;
typedef System::DelphiInterface<IHxTopicList> _di_IHxTopicList;
__interface  INTERFACE_UUID("{314111CC-A502-11D2-BBCA-00C04F8EC294}") IHxIndex  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetSession(_di_IHxSession &__GetSession_result) = 0 ;
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	virtual HRESULT __safecall GetStringFromSlot(int iSlot, System::WideString &__GetStringFromSlot_result) = 0 ;
	virtual HRESULT __safecall GetLevelFromSlot(int iSlot, int &__GetLevelFromSlot_result) = 0 ;
	virtual HRESULT __safecall GetSlotFromString(const System::WideString bszLink, int &__GetSlotFromString_result) = 0 ;
	virtual HRESULT __safecall GetTopicsFromSlot(int uiSlot, _di_IHxTopicList &__GetTopicsFromSlot_result) = 0 ;
	virtual HRESULT __safecall GetTopicsFromString(const System::WideString bszLink, int options, _di_IHxTopicList &__GetTopicsFromString_result) = 0 ;
	virtual HRESULT __safecall GetInfoFromSlot(int iSlot, /* out */ int &piLevel, System::WideString &__GetInfoFromSlot_result) = 0 ;
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall GetCrossRef(int iSlot, System::WideString &__GetCrossRef_result) = 0 ;
	virtual HRESULT __safecall GetFullStringFromSlot(int iSlot, const System::WideString sep, System::WideString &__GetFullStringFromSlot_result) = 0 ;
	virtual HRESULT __safecall GetCrossRefSlot(int iSlot, int &__GetCrossRefSlot_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
};

__interface IHxQuery;
typedef System::DelphiInterface<IHxQuery> _di_IHxQuery;
__interface IHxCollection;
typedef System::DelphiInterface<IHxCollection> _di_IHxCollection;
__interface IHxRegFilterList;
typedef System::DelphiInterface<IHxRegFilterList> _di_IHxRegFilterList;
__interface  INTERFACE_UUID("{31411192-A502-11D2-BBCA-00C04F8EC294}") IHxSession  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Initialize(const System::WideString NameSpace, int options) = 0 ;
	virtual HRESULT __safecall Query(const System::WideString keywords, const System::WideString NavDataMoniker, int options, const System::WideString FilterMoniker, _di_IHxTopicList &__Query_result) = 0 ;
	virtual HRESULT __safecall QueryForTopic(const System::WideString keywords, const System::WideString NavDataMoniker, int options, const System::WideString FilterMoniker, _di_IHxTopic &__QueryForTopic_result) = 0 ;
	virtual HRESULT __safecall QueryForUrl(const System::WideString keywords, const System::WideString NavDataMoniker, int options, const System::WideString FilterMoniker, System::WideString &__QueryForUrl_result) = 0 ;
	virtual HRESULT __safecall GetNavigationInterface(const System::WideString NavDataMoniker, const System::WideString FilterMoniker, GUID &refiid, _di_IDispatch &__GetNavigationInterface_result) = 0 ;
	virtual HRESULT __safecall GetNavigationObject(const System::WideString NavDataMoniker, const System::WideString FilterMoniker, _di_IDispatch &__GetNavigationObject_result) = 0 ;
	virtual HRESULT __safecall GetQueryObject(const System::WideString NavDataMoniker, const System::WideString FilterMoniker, _di_IHxQuery &__GetQueryObject_result) = 0 ;
	virtual HRESULT __safecall Get_Collection(_di_IHxCollection &__Get_Collection_result) = 0 ;
	virtual HRESULT __safecall Get_LangId(short &__Get_LangId_result) = 0 ;
	virtual HRESULT __safecall Set_LangId(short piHelpLangId) = 0 ;
	virtual HRESULT __safecall GetFilterList(_di_IHxRegFilterList &__GetFilterList_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IHxCollection _scw_Get_Collection() { _di_IHxCollection __r; HRESULT __hr = Get_Collection(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IHxCollection Collection = {read=_scw_Get_Collection};
	#pragma option push -w-inl
	/* safecall wrapper */ inline short _scw_Get_LangId() { short __r; HRESULT __hr = Get_LangId(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property short LangId = {read=_scw_Get_LangId, write=Set_LangId};
};

__interface IEnumHxTopic;
typedef System::DelphiInterface<IEnumHxTopic> _di_IEnumHxTopic;
__interface  INTERFACE_UUID("{31411194-A502-11D2-BBCA-00C04F8EC294}") IHxTopicList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxTopic &__Item_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxTopic &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumTopics(int filter, int options, _di_IEnumHxTopic &__EnumTopics_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
};

__interface  INTERFACE_UUID("{31411195-A502-11D2-BBCA-00C04F8EC294}") IEnumHxTopic  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxTopic &ppIHxTopic, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxTopic &ppEnum) = 0 ;
};

__interface  INTERFACE_UUID("{31411193-A502-11D2-BBCA-00C04F8EC294}") IHxQuery  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Query(const System::WideString keywords, Activex::TOleEnum options, _di_IHxTopicList &__Query_result) = 0 ;
	virtual HRESULT __safecall QueryForTopic(const System::WideString keywords, Activex::TOleEnum options, _di_IHxTopic &__QueryForTopic_result) = 0 ;
	virtual HRESULT __safecall QueryForUrl(const System::WideString keywords, Activex::TOleEnum options, System::WideString &__QueryForUrl_result) = 0 ;
};

__interface IHxAttrNameList;
typedef System::DelphiInterface<IHxAttrNameList> _di_IHxAttrNameList;
__interface IHxFilters;
typedef System::DelphiInterface<IHxFilters> _di_IHxFilters;
__interface  INTERFACE_UUID("{314111A1-A502-11D2-BBCA-00C04F8EC294}") IHxCollection  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall SetProperty(Activex::TOleEnum propid, const System::OleVariant var_) = 0 ;
	virtual HRESULT __safecall Get_URL(System::WideString &__Get_URL_result) = 0 ;
	virtual HRESULT __safecall Get_AttributeNames(_di_IHxAttrNameList &__Get_AttributeNames_result) = 0 ;
	virtual HRESULT __safecall Get_Filters(_di_IHxFilters &__Get_Filters_result) = 0 ;
	virtual HRESULT __safecall Get_Title(System::WideString &__Get_Title_result) = 0 ;
	virtual HRESULT __safecall MergeIndex(void) = 0 ;
	virtual HRESULT __safecall GetFilterTopicCount(const System::WideString bstrQuery, int &__GetFilterTopicCount_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_URL() { System::WideString __r; HRESULT __hr = Get_URL(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString URL = {read=_scw_Get_URL};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IHxAttrNameList _scw_Get_AttributeNames() { _di_IHxAttrNameList __r; HRESULT __hr = Get_AttributeNames(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IHxAttrNameList AttributeNames = {read=_scw_Get_AttributeNames};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IHxFilters _scw_Get_Filters() { _di_IHxFilters __r; HRESULT __hr = Get_Filters(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IHxFilters Filters = {read=_scw_Get_Filters};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Title() { System::WideString __r; HRESULT __hr = Get_Title(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Title = {read=_scw_Get_Title};
};

__interface IHxAttrName;
typedef System::DelphiInterface<IHxAttrName> _di_IHxAttrName;
__interface IEnumHxAttrName;
typedef System::DelphiInterface<IEnumHxAttrName> _di_IEnumHxAttrName;
__interface  INTERFACE_UUID("{314111CE-A502-11D2-BBCA-00C04F8EC294}") IHxAttrNameList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxAttrName &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumAttrName(int filter, int options, _di_IEnumHxAttrName &__EnumAttrName_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxAttrName &__Item_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
};

__interface IHxAttrValueList;
typedef System::DelphiInterface<IHxAttrValueList> _di_IHxAttrValueList;
__interface  INTERFACE_UUID("{314111D2-A502-11D2-BBCA-00C04F8EC294}") IHxAttrName  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall SetProperty(Activex::TOleEnum propid, const System::OleVariant var_) = 0 ;
	virtual HRESULT __safecall Get_Name(System::WideString &__Get_Name_result) = 0 ;
	virtual HRESULT __safecall Get_DisplayName(System::WideString &__Get_DisplayName_result) = 0 ;
	virtual HRESULT __safecall Get_Flag(int &__Get_Flag_result) = 0 ;
	virtual HRESULT __safecall Get_AttributeValues(_di_IHxAttrValueList &__Get_AttributeValues_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Name() { System::WideString __r; HRESULT __hr = Get_Name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Name = {read=_scw_Get_Name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_DisplayName() { System::WideString __r; HRESULT __hr = Get_DisplayName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString DisplayName = {read=_scw_Get_DisplayName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Flag() { int __r; HRESULT __hr = Get_Flag(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Flag = {read=_scw_Get_Flag};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IHxAttrValueList _scw_Get_AttributeValues() { _di_IHxAttrValueList __r; HRESULT __hr = Get_AttributeValues(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IHxAttrValueList AttributeValues = {read=_scw_Get_AttributeValues};
};

__interface IHxAttrValue;
typedef System::DelphiInterface<IHxAttrValue> _di_IHxAttrValue;
__interface IEnumHxAttrValue;
typedef System::DelphiInterface<IEnumHxAttrValue> _di_IEnumHxAttrValue;
__interface  INTERFACE_UUID("{314111D4-A502-11D2-BBCA-00C04F8EC294}") IHxAttrValueList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxAttrValue &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumAttrValue(int filter, int options, _di_IEnumHxAttrValue &__EnumAttrValue_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxAttrValue &__Item_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
};

__interface  INTERFACE_UUID("{314111D8-A502-11D2-BBCA-00C04F8EC294}") IHxAttrValue  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall SetProperty(Activex::TOleEnum propid, const System::OleVariant var_) = 0 ;
	virtual HRESULT __safecall Get_Value(System::WideString &__Get_Value_result) = 0 ;
	virtual HRESULT __safecall Get_DisplayValue(System::WideString &__Get_DisplayValue_result) = 0 ;
	virtual HRESULT __safecall Get_Flag(int &__Get_Flag_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Value() { System::WideString __r; HRESULT __hr = Get_Value(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Value = {read=_scw_Get_Value};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_DisplayValue() { System::WideString __r; HRESULT __hr = Get_DisplayValue(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString DisplayValue = {read=_scw_Get_DisplayValue};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Flag() { int __r; HRESULT __hr = Get_Flag(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Flag = {read=_scw_Get_Flag};
};

__interface  INTERFACE_UUID("{314111D6-A502-11D2-BBCA-00C04F8EC294}") IEnumHxAttrValue  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxAttrValue &ppIHxAttrValue, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxAttrValue &ppEnum) = 0 ;
};

__interface  INTERFACE_UUID("{314111D0-A502-11D2-BBCA-00C04F8EC294}") IEnumHxAttrName  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxAttrName &ppIHxAttrName, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxAttrName &ppEnum) = 0 ;
};

__interface  INTERFACE_UUID("{314111E3-A502-11D2-BBCA-00C04F8EC294}") IHxFilters  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Count(int &__Count_result) = 0 ;
	virtual HRESULT __safecall GetFilter(int iIndex, /* out */ System::WideString &pbstrName, System::WideString &__GetFilter_result) = 0 ;
	virtual HRESULT __safecall GetFilterName(int iIndex, System::WideString &__GetFilterName_result) = 0 ;
	virtual HRESULT __safecall GetFilterQuery(int iIndex, System::WideString &__GetFilterQuery_result) = 0 ;
	virtual HRESULT __safecall RegisterFilter(const System::WideString bstrName, const System::WideString bstrQuery) = 0 ;
	virtual HRESULT __safecall RemoveFilter(const System::WideString bstrName) = 0 ;
	virtual HRESULT __safecall FindFilter(const System::WideString bstrName, System::WideString &__FindFilter_result) = 0 ;
	virtual HRESULT __safecall SetNamespace(const System::WideString bstrName) = 0 ;
	virtual HRESULT __safecall SetCollectionFiltersFlag(System::WordBool vb) = 0 ;
};

__interface IHxRegFilter;
typedef System::DelphiInterface<IHxRegFilter> _di_IHxRegFilter;
__interface IEnumHxRegFilter;
typedef System::DelphiInterface<IEnumHxRegFilter> _di_IEnumHxRegFilter;
__interface  INTERFACE_UUID("{31411212-A502-11D2-BBCA-00C04F8EC294}") IHxRegFilterList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxRegFilter &__Item_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxRegFilter &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumRegFilter(int filter, int options, _di_IEnumHxRegFilter &__EnumRegFilter_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	virtual HRESULT __safecall FindFilter(const System::WideString bstrFilterName, _di_IHxRegFilter &__FindFilter_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
};

__interface  INTERFACE_UUID("{31411221-A502-11D2-BBCA-00C04F8EC294}") IHxRegFilter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
};

__interface  INTERFACE_UUID("{3141121C-A502-11D2-BBCA-00C04F8EC294}") IEnumHxRegFilter  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxRegFilter &ppIHxRegFilter, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxRegFilter &ppEnum) = 0 ;
};

__interface IHxSampleCollection;
typedef System::DelphiInterface<IHxSampleCollection> _di_IHxSampleCollection;
__interface IHxSample;
typedef System::DelphiInterface<IHxSample> _di_IHxSample;
__interface  INTERFACE_UUID("{314111E6-A502-11D2-BBCA-00C04F8EC294}") IHxSampleCollection  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetSampleFromId(const System::WideString bstrTopicUrl, const System::WideString bstrId, const System::WideString bstrSFLName, _di_IHxSample &__GetSampleFromId_result) = 0 ;
};

__interface  INTERFACE_UUID("{314111E8-A502-11D2-BBCA-00C04F8EC294}") IHxSample  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_SampleId(System::WideString &__Get_SampleId_result) = 0 ;
	virtual HRESULT __safecall Get_LoadString(System::WideString &__Get_LoadString_result) = 0 ;
	virtual HRESULT __safecall Get_DestinationDir(System::WideString &__Get_DestinationDir_result) = 0 ;
	virtual HRESULT __safecall Get_ProjectFileExt(System::WideString &__Get_ProjectFileExt_result) = 0 ;
	virtual HRESULT __safecall Get_FileCount(int &__Get_FileCount_result) = 0 ;
	virtual HRESULT __safecall GetFileNameAtIndex(int index, System::WideString &__GetFileNameAtIndex_result) = 0 ;
	virtual HRESULT __safecall CopyFileAtIndex(int index, const System::WideString bstrDest, Activex::TOleEnum option) = 0 ;
	virtual HRESULT __safecall ChooseDirectory(const System::WideString bstrDefaultDir, const System::WideString bstrTitle, System::WideString &__ChooseDirectory_result) = 0 ;
	virtual HRESULT __safecall GetFileTextAtIndex(int index, System::WideString &__GetFileTextAtIndex_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_SampleId() { System::WideString __r; HRESULT __hr = Get_SampleId(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString SampleId = {read=_scw_Get_SampleId};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_LoadString() { System::WideString __r; HRESULT __hr = Get_LoadString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString LoadString = {read=_scw_Get_LoadString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_DestinationDir() { System::WideString __r; HRESULT __hr = Get_DestinationDir(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString DestinationDir = {read=_scw_Get_DestinationDir};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ProjectFileExt() { System::WideString __r; HRESULT __hr = Get_ProjectFileExt(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ProjectFileExt = {read=_scw_Get_ProjectFileExt};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_FileCount() { int __r; HRESULT __hr = Get_FileCount(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int FileCount = {read=_scw_Get_FileCount};
};

__interface IHxRegNamespaceList;
typedef System::DelphiInterface<IHxRegNamespaceList> _di_IHxRegNamespaceList;
__interface  INTERFACE_UUID("{314111EF-A502-11D2-BBCA-00C04F8EC294}") IHxRegistryWalker  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_RegisteredNamespaceList(const System::WideString bstrStart, _di_IHxRegNamespaceList &__Get_RegisteredNamespaceList_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IHxRegNamespaceList _scw_Get_RegisteredNamespaceList(const System::WideString bstrStart) { _di_IHxRegNamespaceList __r; HRESULT __hr = Get_RegisteredNamespaceList(bstrStart, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IHxRegNamespaceList RegisteredNamespaceList[const System::WideString bstrStart] = {read=_scw_Get_RegisteredNamespaceList};
};

__interface IHxRegNamespace;
typedef System::DelphiInterface<IHxRegNamespace> _di_IHxRegNamespace;
__interface IEnumHxRegNamespace;
typedef System::DelphiInterface<IEnumHxRegNamespace> _di_IEnumHxRegNamespace;
__interface  INTERFACE_UUID("{314111F3-A502-11D2-BBCA-00C04F8EC294}") IHxRegNamespaceList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxRegNamespace &__Item_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxRegNamespace &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumRegNamespace(int filter, int options, _di_IEnumHxRegNamespace &__EnumRegNamespace_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
};

__interface  INTERFACE_UUID("{314111F1-A502-11D2-BBCA-00C04F8EC294}") IHxRegNamespace  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Name(System::WideString &__Get_Name_result) = 0 ;
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall IsTitle(const System::WideString bstrTitle, System::WordBool &__IsTitle_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Name() { System::WideString __r; HRESULT __hr = Get_Name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Name = {read=_scw_Get_Name};
};

__interface  INTERFACE_UUID("{314111F5-A502-11D2-BBCA-00C04F8EC294}") IEnumHxRegNamespace  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxRegNamespace &ppIHxRegNamespace, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxRegNamespace &ppEnum) = 0 ;
};

__interface IHxRegTitle;
typedef System::DelphiInterface<IHxRegTitle> _di_IHxRegTitle;
__interface  INTERFACE_UUID("{31411202-A502-11D2-BBCA-00C04F8EC294}") IHxRegTitle  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
};

__interface IHxRegTitleList;
typedef System::DelphiInterface<IHxRegTitleList> _di_IHxRegTitleList;
__interface IEnumHxRegTitle;
typedef System::DelphiInterface<IEnumHxRegTitle> _di_IEnumHxRegTitle;
__interface  INTERFACE_UUID("{31411203-A502-11D2-BBCA-00C04F8EC294}") IHxRegTitleList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxRegTitle &__Item_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxRegTitle &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumRegTitle(int filter, int options, _di_IEnumHxRegTitle &__EnumRegTitle_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
};

__interface  INTERFACE_UUID("{31411204-A502-11D2-BBCA-00C04F8EC294}") IEnumHxRegTitle  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxRegTitle &ppIHxRegTitle, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxRegTitle &ppEnum) = 0 ;
};

__interface IHxRegPlugIn;
typedef System::DelphiInterface<IHxRegPlugIn> _di_IHxRegPlugIn;
__interface  INTERFACE_UUID("{3141120A-A502-11D2-BBCA-00C04F8EC294}") IHxRegPlugIn  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetProperty(Activex::TOleEnum propid, System::OleVariant &__GetProperty_result) = 0 ;
};

__interface IHxRegPlugInList;
typedef System::DelphiInterface<IHxRegPlugInList> _di_IHxRegPlugInList;
__interface IEnumHxRegPlugIn;
typedef System::DelphiInterface<IEnumHxRegPlugIn> _di_IEnumHxRegPlugIn;
__interface  INTERFACE_UUID("{3141120B-A502-11D2-BBCA-00C04F8EC294}") IHxRegPlugInList  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Item(const System::OleVariant index, _di_IHxRegPlugIn &__Item_result) = 0 ;
	virtual HRESULT __safecall ItemAt(int index, _di_IHxRegPlugIn &__ItemAt_result) = 0 ;
	virtual HRESULT __safecall EnumRegPlugIn(int filter, int options, _di_IEnumHxRegPlugIn &__EnumRegPlugIn_result) = 0 ;
	virtual HRESULT __safecall Get__NewEnum(System::_di_IInterface &__Get__NewEnum_result) = 0 ;
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::_di_IInterface _scw_Get__NewEnum() { System::_di_IInterface __r; HRESULT __hr = Get__NewEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::_di_IInterface _NewEnum = {read=_scw_Get__NewEnum};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
};

__interface  INTERFACE_UUID("{3141120C-A502-11D2-BBCA-00C04F8EC294}") IEnumHxRegPlugIn  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Next(unsigned celt, /* out */ _di_IHxRegPlugIn &ppIHxRegPlugIn, /* out */ unsigned &pceltFetched) = 0 ;
	virtual HRESULT __stdcall Reset(void) = 0 ;
	virtual HRESULT __stdcall Skip(unsigned celt) = 0 ;
	virtual HRESULT __stdcall Clone(/* out */ _di_IEnumHxRegPlugIn &ppEnum) = 0 ;
};

__interface  INTERFACE_UUID("{31411218-A502-11D2-BBCA-00C04F8EC294}") IHxRegisterSession  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall CreateTransaction(const System::WideString bstrInToken, System::WideString &__CreateTransaction_result) = 0 ;
	virtual HRESULT __safecall PostponeTransaction(System::WideString &__PostponeTransaction_result) = 0 ;
	virtual HRESULT __safecall ContinueTransaction(const System::WideString bstrToken) = 0 ;
	virtual HRESULT __safecall CommitTransaction(void) = 0 ;
	virtual HRESULT __safecall RevertTransaction(void) = 0 ;
	virtual HRESULT __safecall GetRegistrationObject(Activex::TOleEnum type_, _di_IDispatch &__GetRegistrationObject_result) = 0 ;
};

__interface IHxPlugIn;
typedef System::DelphiInterface<IHxPlugIn> _di_IHxPlugIn;
__interface  INTERFACE_UUID("{314111DA-A502-11D2-BBCA-00C04F8EC294}") IHxPlugIn  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall RegisterHelpPlugIn(const System::WideString bstrProductNamespace, const System::WideString bstrProductHxt, const System::WideString bstrNamespace, const System::WideString bstrHxt, const System::WideString bstrHxa, int options) = 0 ;
	virtual HRESULT __safecall RemoveHelpPlugIn(const System::WideString bstrProductNamespace, const System::WideString bstrProductHxt, const System::WideString bstrNamespace, const System::WideString bstrHxt, const System::WideString bstrHxa) = 0 ;
};

__interface IHxInitialize;
typedef System::DelphiInterface<IHxInitialize> _di_IHxInitialize;
__interface  INTERFACE_UUID("{314111AE-A502-11D2-BBCA-00C04F8EC294}") IHxInitialize  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Initialize(const System::WideString InitString, int options) = 0 ;
	virtual HRESULT __safecall Get_filter(System::WideString &__Get_filter_result) = 0 ;
	virtual HRESULT __safecall Set_filter(const System::WideString pFilterMoniker) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_filter() { System::WideString __r; HRESULT __hr = Get_filter(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString filter = {read=_scw_Get_filter, write=Set_filter};
};

__interface IHxCancel;
typedef System::DelphiInterface<IHxCancel> _di_IHxCancel;
__interface  INTERFACE_UUID("{31411225-A502-11D2-BBCA-00C04F8EC294}") IHxCancel  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Cancel(Activex::TOleEnum &__Get_Cancel_result) = 0 ;
	virtual HRESULT __safecall Set_Cancel(Activex::TOleEnum pbCancel) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Cancel() { Activex::TOleEnum __r; HRESULT __hr = Get_Cancel(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Cancel = {read=_scw_Get_Cancel, write=Set_Cancel};
};

__interface  INTERFACE_UUID("{31411227-A502-11D2-BBCA-00C04F8EC294}") IHxRegisterProtocol  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Register(void) = 0 ;
	virtual HRESULT __safecall Unregister(void) = 0 ;
};

class DELPHICLASS CoHxSession;
class PASCALIMPLEMENTATION CoHxSession : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di_IHxSession __fastcall Create();
	__classmethod _di_IHxSession __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHxSession(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHxSession(void) { }
	
};


class DELPHICLASS CoHxRegistryWalker;
class PASCALIMPLEMENTATION CoHxRegistryWalker : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di_IHxRegistryWalker __fastcall Create();
	__classmethod _di_IHxRegistryWalker __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHxRegistryWalker(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHxRegistryWalker(void) { }
	
};


class DELPHICLASS CoHxRegisterSession;
class PASCALIMPLEMENTATION CoHxRegisterSession : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di_IHxRegisterSession __fastcall Create();
	__classmethod _di_IHxRegisterSession __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHxRegisterSession(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHxRegisterSession(void) { }
	
};


class DELPHICLASS CoHxRegisterProtocol;
class PASCALIMPLEMENTATION CoHxRegisterProtocol : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di_IHxRegisterProtocol __fastcall Create();
	__classmethod _di_IHxRegisterProtocol __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHxRegisterProtocol(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHxRegisterProtocol(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MSHelpServicesMajorVersion = 0x1;
static const ShortInt MSHelpServicesMinorVersion = 0x0;
extern PACKAGE GUID LIBID_MSHelpServices;
extern PACKAGE GUID IID_IHxHierarchy;
extern PACKAGE GUID IID_IHxTopic;
extern PACKAGE GUID IID_IHxAttributeList;
extern PACKAGE GUID IID_IHxAttribute;
extern PACKAGE GUID IID_IEnumHxAttribute;
extern PACKAGE GUID IID_IHxRegister;
extern PACKAGE GUID IID_IHxIndex;
extern PACKAGE GUID IID_IHxSession;
extern PACKAGE GUID IID_IHxTopicList;
extern PACKAGE GUID IID_IEnumHxTopic;
extern PACKAGE GUID IID_IHxQuery;
extern PACKAGE GUID IID_IHxCollection;
extern PACKAGE GUID IID_IHxAttrNameList;
extern PACKAGE GUID IID_IHxAttrName;
extern PACKAGE GUID IID_IHxAttrValueList;
extern PACKAGE GUID IID_IHxAttrValue;
extern PACKAGE GUID IID_IEnumHxAttrValue;
extern PACKAGE GUID IID_IEnumHxAttrName;
extern PACKAGE GUID IID_IHxFilters;
extern PACKAGE GUID IID_IHxRegFilterList;
extern PACKAGE GUID IID_IHxRegFilter;
extern PACKAGE GUID IID_IEnumHxRegFilter;
extern PACKAGE GUID IID_IHxSampleCollection;
extern PACKAGE GUID IID_IHxSample;
extern PACKAGE GUID IID_IHxRegistryWalker;
extern PACKAGE GUID IID_IHxRegNamespaceList;
extern PACKAGE GUID IID_IHxRegNamespace;
extern PACKAGE GUID IID_IEnumHxRegNamespace;
extern PACKAGE GUID IID_IHxRegTitle;
extern PACKAGE GUID IID_IHxRegTitleList;
extern PACKAGE GUID IID_IEnumHxRegTitle;
extern PACKAGE GUID IID_IHxRegPlugIn;
extern PACKAGE GUID IID_IHxRegPlugInList;
extern PACKAGE GUID IID_IEnumHxRegPlugIn;
extern PACKAGE GUID IID_IHxRegisterSession;
extern PACKAGE GUID IID_IHxPlugIn;
extern PACKAGE GUID IID_IHxInitialize;
extern PACKAGE GUID IID_IHxCancel;
extern PACKAGE GUID DIID_IHxSessionEvents;
extern PACKAGE GUID DIID_IHxRegisterSessionEvents;
extern PACKAGE GUID CLASS_HxSession;
extern PACKAGE GUID CLASS_HxRegistryWalker;
extern PACKAGE GUID CLASS_HxRegisterSession;
extern PACKAGE GUID IID_IHxRegisterProtocol;
extern PACKAGE GUID CLASS_HxRegisterProtocol;
static const ShortInt HxHierarchy_Book = 0x3;
static const ShortInt HxHierarchy_BookPage = 0x4;
static const ShortInt HxHierarchy_Page = 0x5;
static const ShortInt HxHierarchy_Unknown = 0x8;
static const ShortInt HxHierarchyTocFont = 0x0;
static const ShortInt HxHierarchyTocFontSize = 0x1;
static const ShortInt HxHierarchyTocLangId = 0x2;
static const ShortInt HxHierarchyTocCharSet = 0x3;
static const ShortInt HxHierarchyTocId = 0x4;
static const ShortInt HxHierarchyTocFileVer = 0x5;
static const ShortInt HxHierarchyTocIconFile = 0x6;
static const ShortInt HxHierarchyTocParentNodeIcon = 0x7;
static const ShortInt HxHierarchyTocIcon = 0x8;
static const ShortInt HxTopicGetTOCTitle = 0x0;
static const ShortInt HxTopicGetRLTitle = 0x1;
static const ShortInt HxTopicGetHTMTitle = 0x2;
static const ShortInt HxTopicGetTitleFullURL = 0x0;
static const ShortInt HxTopicGetTitleFileName = 0x1;
static const ShortInt HxTopicGetTitleNoDefault = 0x2;
static const ShortInt HxPropIdQueryFirst = 0x0;
static const ShortInt HxTopicPropIdFirst = 0x0;
static const ShortInt HxHierarchy_PrintNode_Option_Node = 0x0;
static const ShortInt HxHierarchy_PrintNode_Option_Children = 0x1;
static const ShortInt HxQuery_No_Option = 0x0;
static const ShortInt HxQuery_FullTextSearch_Title_Only = 0x1;
static const ShortInt HxQuery_FullTextSearch_Enable_Stemming = 0x2;
static const ShortInt HxQuery_FullTextSearch_SearchPrevious = 0x4;
static const ShortInt HxQuery_KeywordSearch_CaseSensitive = 0xa;
static const ShortInt HxCollectionProp_NamespaceName = 0x1;
static const ShortInt HxCollectionProp_Font = 0x2;
static const ShortInt HxCollectionProp_FontSize = 0x3;
static const ShortInt HxCollectionProp_LangId = 0x4;
static const ShortInt HxCollectionProp_CharSet = 0x5;
static const ShortInt HxCollectionProp_Id = 0x6;
static const ShortInt HxCollectionProp_FileVer = 0x7;
static const ShortInt HxCollectionProp_CopyRight = 0x8;
static const ShortInt HxRegFilterName = 0x0;
static const ShortInt HxRegFilterQuery = 0x1;
static const ShortInt HxIndexFont = 0x0;
static const ShortInt HxIndexFontSize = 0x1;
static const ShortInt HxIndexLangId = 0x2;
static const ShortInt HxIndexCharSet = 0x3;
static const ShortInt HxIndexTitleStr = 0x4;
static const ShortInt HxIndexIsVisible = 0x5;
static const ShortInt HxIndexId = 0x6;
static const ShortInt HxSampleFileCopyNoOption = 0x0;
static const ShortInt HxSampleFileCopyOverwrite = 0x1;
static const ShortInt HxSampleFileCopyFileOnly = 0x2;
static const ShortInt HxRegNamespaceTitleList = 0x0;
static const ShortInt HxRegNamespacePlugInList = 0x1;
static const ShortInt HxRegNamespaceName = 0x2;
static const ShortInt HxRegNamespaceCollection = 0x3;
static const ShortInt HxRegNamespaceDescription = 0x4;
static const ShortInt HxRegNamespaceFilterList = 0x8;
static const ShortInt HxRegTitleFileName = 0x0;
static const ShortInt HxRegTitleIndexName = 0x1;
static const ShortInt HxRegTitleQueryName = 0x2;
static const ShortInt HxRegTitleId = 0x3;
static const ShortInt HxRegTitleLangId = 0x4;
static const ShortInt HxRegAttrQueryName = 0x5;
static const ShortInt HxRegTitleHxsMediaLoc = 0x6;
static const ShortInt HxRegTitleHxqMediaLoc = 0x7;
static const ShortInt HxRegTitleHxrMediaLoc = 0x8;
static const ShortInt HxRegTitleSampleMediaLoc = 0x9;
static const ShortInt HxRegPlugInName = 0x0;
static const ShortInt HxRegisterSession_IHxRegister = 0x0;
static const ShortInt HxRegisterSession_IHxFilters = 0x1;
static const ShortInt HxRegisterSession_IHxPlugIn = 0x2;
static const ShortInt HxCancelStatus_Continue = 0x0;
static const ShortInt HxCancelStatus_Cancel = 0x1;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Mshelpservices_tlb */
using namespace Mshelpservices_tlb;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Mshelpservices_tlbHPP
