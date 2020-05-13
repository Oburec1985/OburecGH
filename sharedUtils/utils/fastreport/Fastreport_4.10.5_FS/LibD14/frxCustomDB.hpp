// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcustomdb.pas' rev: 21.00

#ifndef FrxcustomdbHPP
#define FrxcustomdbHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxdbset.hpp>	// Pascal unit
#include <Dbctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Fqbclass.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcustomdb
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxCustomDataset;
class PASCALIMPLEMENTATION TfrxCustomDataset : public Frxdbset::TfrxDBDataset
{
	typedef Frxdbset::TfrxDBDataset inherited;
	
private:
	bool FDBConnected;
	Db::TDataSource* FDataSource;
	Frxdbset::TfrxDBDataset* FMaster;
	System::UnicodeString FMasterFields;
	void __fastcall SetActive(bool Value);
	void __fastcall SetFilter(const System::UnicodeString Value);
	void __fastcall SetFiltered(bool Value);
	bool __fastcall GetActive(void);
	Db::TFields* __fastcall GetFields(void);
	System::UnicodeString __fastcall GetFilter(void);
	bool __fastcall GetFiltered(void);
	void __fastcall InternalSetMaster(const Frxdbset::TfrxDBDataset* Value);
	void __fastcall InternalSetMasterFields(const System::UnicodeString Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetParent(Frxclass::TfrxComponent* AParent);
	virtual void __fastcall SetUserName(const System::UnicodeString Value);
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetMasterFields(const System::UnicodeString Value);
	__property DataSet;
	
public:
	__fastcall virtual TfrxCustomDataset(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomDataset(void);
	virtual void __fastcall OnPaste(void);
	__property bool DBConnected = {read=FDBConnected, write=FDBConnected, nodefault};
	__property Db::TFields* Fields = {read=GetFields};
	__property System::UnicodeString MasterFields = {read=FMasterFields, write=InternalSetMasterFields};
	__property bool Active = {read=GetActive, write=SetActive, default=0};
	
__published:
	__property System::UnicodeString Filter = {read=GetFilter, write=SetFilter};
	__property bool Filtered = {read=GetFiltered, write=SetFiltered, default=0};
	__property Frxdbset::TfrxDBDataset* Master = {read=FMaster, write=InternalSetMaster};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomDataset(Classes::TComponent* AOwner, System::Word Flags) : Frxdbset::TfrxDBDataset(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxCustomTable;
class PASCALIMPLEMENTATION TfrxCustomTable : public TfrxCustomDataset
{
	typedef TfrxCustomDataset inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetIndexFieldNames(void);
	virtual System::UnicodeString __fastcall GetIndexName(void);
	virtual System::UnicodeString __fastcall GetTableName(void);
	virtual void __fastcall SetIndexFieldNames(const System::UnicodeString Value);
	virtual void __fastcall SetIndexName(const System::UnicodeString Value);
	virtual void __fastcall SetTableName(const System::UnicodeString Value);
	__property DataSet;
	
__published:
	__property MasterFields;
	__property System::UnicodeString TableName = {read=GetTableName, write=SetTableName};
	__property System::UnicodeString IndexName = {read=GetIndexName, write=SetIndexName};
	__property System::UnicodeString IndexFieldNames = {read=GetIndexFieldNames, write=SetIndexFieldNames};
public:
	/* TfrxCustomDataset.Create */ inline __fastcall virtual TfrxCustomTable(Classes::TComponent* AOwner) : TfrxCustomDataset(AOwner) { }
	/* TfrxCustomDataset.Destroy */ inline __fastcall virtual ~TfrxCustomTable(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomTable(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomDataset(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxParamItem;
class PASCALIMPLEMENTATION TfrxParamItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	Db::TFieldType FDataType;
	System::UnicodeString FExpression;
	System::UnicodeString FName;
	System::Variant FValue;
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property System::Variant Value = {read=FValue, write=FValue};
	
__published:
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property Db::TFieldType DataType = {read=FDataType, write=FDataType, nodefault};
	__property System::UnicodeString Expression = {read=FExpression, write=FExpression};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxParamItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxParamItem(void) { }
	
};


class DELPHICLASS TfrxParams;
class PASCALIMPLEMENTATION TfrxParams : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxParamItem* operator[](int Index) { return Items[Index]; }
	
private:
	bool FIgnoreDuplicates;
	TfrxParamItem* __fastcall GetParam(int Index);
	
public:
	__fastcall TfrxParams(void);
	HIDESBASE TfrxParamItem* __fastcall Add(void);
	TfrxParamItem* __fastcall Find(const System::UnicodeString Name);
	int __fastcall IndexOf(const System::UnicodeString Name);
	void __fastcall UpdateParams(const System::UnicodeString SQL);
	__property TfrxParamItem* Items[int Index] = {read=GetParam/*, default*/};
	__property bool IgnoreDuplicates = {read=FIgnoreDuplicates, write=FIgnoreDuplicates, nodefault};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxParams(void) { }
	
};


class DELPHICLASS TfrxCustomQuery;
class PASCALIMPLEMENTATION TfrxCustomQuery : public TfrxCustomDataset
{
	typedef TfrxCustomDataset inherited;
	
private:
	TfrxParams* FParams;
	Db::TDataSetNotifyEvent FSaveOnBeforeOpen;
	Classes::TNotifyEvent FSaveOnChange;
	System::UnicodeString FSQLSchema;
	void __fastcall ReadData(Classes::TReader* Reader);
	void __fastcall SetParams(TfrxParams* Value);
	void __fastcall WriteData(Classes::TWriter* Writer);
	bool __fastcall GetIgnoreDupParams(void);
	void __fastcall SetIgnoreDupParams(const bool Value);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	virtual void __fastcall OnBeforeOpen(Db::TDataSet* DataSet);
	virtual void __fastcall OnChangeSQL(System::TObject* Sender);
	virtual void __fastcall SetSQL(Classes::TStrings* Value);
	virtual Classes::TStrings* __fastcall GetSQL(void);
	
public:
	__fastcall virtual TfrxCustomQuery(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomQuery(void);
	virtual void __fastcall UpdateParams(void);
	TfrxParamItem* __fastcall ParamByName(const System::UnicodeString Value);
	virtual Fqbclass::TfqbEngine* __fastcall QBEngine(void);
	
__published:
	__property bool IgnoreDupParams = {read=GetIgnoreDupParams, write=SetIgnoreDupParams, nodefault};
	__property TfrxParams* Params = {read=FParams, write=SetParams};
	__property Classes::TStrings* SQL = {read=GetSQL, write=SetSQL};
	__property System::UnicodeString SQLSchema = {read=FSQLSchema, write=FSQLSchema};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomQuery(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomDataset(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDBLookupComboBox;
class PASCALIMPLEMENTATION TfrxDBLookupComboBox : public Frxclass::TfrxDialogControl
{
	typedef Frxclass::TfrxDialogControl inherited;
	
private:
	Frxdbset::TfrxDBDataset* FDataSet;
	System::UnicodeString FDataSetName;
	Db::TDataSource* FDataSource;
	Dbctrls::TDBLookupComboBox* FDBLookupComboBox;
	bool FAutoOpenDataSet;
	System::UnicodeString __fastcall GetDataSetName(void);
	System::UnicodeString __fastcall GetKeyField(void);
	System::Variant __fastcall GetKeyValue(void);
	System::UnicodeString __fastcall GetListField(void);
	System::UnicodeString __fastcall GetText(void);
	void __fastcall SetDataSet(const Frxdbset::TfrxDBDataset* Value);
	void __fastcall SetDataSetName(const System::UnicodeString Value);
	void __fastcall SetKeyField(System::UnicodeString Value);
	void __fastcall SetKeyValue(const System::Variant &Value);
	void __fastcall SetListField(System::UnicodeString Value);
	void __fastcall UpdateDataSet(void);
	void __fastcall OnOpenDS(System::TObject* Sender);
	int __fastcall GetDropDownWidth(void);
	void __fastcall SetDropDownWidth(const int Value);
	int __fastcall GetDropDownRows(void);
	void __fastcall SetDropDownRows(const int Value);
	
public:
	__fastcall virtual TfrxDBLookupComboBox(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDBLookupComboBox(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	__property Dbctrls::TDBLookupComboBox* DBLookupComboBox = {read=FDBLookupComboBox};
	__property System::Variant KeyValue = {read=GetKeyValue, write=SetKeyValue};
	__property System::UnicodeString Text = {read=GetText};
	
__published:
	__property bool AutoOpenDataSet = {read=FAutoOpenDataSet, write=FAutoOpenDataSet, default=0};
	__property System::UnicodeString ListField = {read=GetListField, write=SetListField};
	__property Frxdbset::TfrxDBDataset* DataSet = {read=FDataSet, write=SetDataSet};
	__property System::UnicodeString DataSetName = {read=GetDataSetName, write=SetDataSetName};
	__property System::UnicodeString KeyField = {read=GetKeyField, write=SetKeyField};
	__property int DropDownWidth = {read=GetDropDownWidth, write=SetDropDownWidth, nodefault};
	__property int DropDownRows = {read=GetDropDownRows, write=SetDropDownRows, nodefault};
	__property OnClick;
	__property OnDblClick;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDBLookupComboBox(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxDialogControl(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxParamsToTParams(TfrxCustomQuery* Query, Db::TParams* Params);

}	/* namespace Frxcustomdb */
using namespace Frxcustomdb;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcustomdbHPP
