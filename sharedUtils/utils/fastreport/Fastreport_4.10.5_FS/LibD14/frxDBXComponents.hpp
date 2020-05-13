// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdbxcomponents.pas' rev: 21.00

#ifndef FrxdbxcomponentsHPP
#define FrxdbxcomponentsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxcustomdb.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit
#include <Dbxpress.hpp>	// Pascal unit
#include <Sqlexpr.hpp>	// Pascal unit
#include <Provider.hpp>	// Pascal unit
#include <Dbclient.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Fqbclass.hpp>	// Pascal unit
#include <Frxdbset.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdbxcomponents
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxDBXDataset;
class PASCALIMPLEMENTATION TfrxDBXDataset : public Dbclient::TCustomClientDataSet
{
	typedef Dbclient::TCustomClientDataSet inherited;
	
private:
	Db::TDataSet* FDataSet;
	Provider::TDataSetProvider* FProvider;
	void __fastcall SetDataset(const Db::TDataSet* Value);
	
protected:
	virtual void __fastcall OpenCursor(bool InfoQuery);
	
public:
	__fastcall virtual TfrxDBXDataset(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDBXDataset(void);
	__property Db::TDataSet* Dataset = {read=FDataSet, write=SetDataset};
};


class DELPHICLASS TfrxDBXComponents;
class PASCALIMPLEMENTATION TfrxDBXComponents : public Frxclass::TfrxDBComponents
{
	typedef Frxclass::TfrxDBComponents inherited;
	
private:
	Sqlexpr::TSQLConnection* FDefaultDatabase;
	TfrxDBXComponents* FOldComponents;
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	void __fastcall SetDefaultDatabase(Sqlexpr::TSQLConnection* Value);
	
public:
	__fastcall virtual TfrxDBXComponents(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDBXComponents(void);
	virtual System::UnicodeString __fastcall GetDescription(void);
	
__published:
	__property Sqlexpr::TSQLConnection* DefaultDatabase = {read=FDefaultDatabase, write=SetDefaultDatabase};
};


class DELPHICLASS TfrxDBXDatabase;
class PASCALIMPLEMENTATION TfrxDBXDatabase : public Frxclass::TfrxCustomDatabase
{
	typedef Frxclass::TfrxCustomDatabase inherited;
	
private:
	Sqlexpr::TSQLConnection* FDatabase;
	Classes::TStrings* FStrings;
	bool FLock;
	System::UnicodeString __fastcall GetDriverName(void);
	System::UnicodeString __fastcall GetGetDriverFunc(void);
	System::UnicodeString __fastcall GetLibraryName(void);
	System::UnicodeString __fastcall GetVendorLib(void);
	void __fastcall SetDriverName(const System::UnicodeString Value);
	void __fastcall SetGetDriverFunc(const System::UnicodeString Value);
	void __fastcall SetLibraryName(const System::UnicodeString Value);
	void __fastcall SetVendorLib(const System::UnicodeString Value);
	void __fastcall OnChange(System::TObject* Sender);
	
protected:
	virtual void __fastcall SetConnected(bool Value);
	virtual void __fastcall SetDatabaseName(const System::UnicodeString Value);
	virtual void __fastcall SetLoginPrompt(bool Value);
	virtual void __fastcall SetParams(Classes::TStrings* Value);
	virtual bool __fastcall GetConnected(void);
	virtual System::UnicodeString __fastcall GetDatabaseName(void);
	virtual bool __fastcall GetLoginPrompt(void);
	virtual Classes::TStrings* __fastcall GetParams(void);
	
public:
	__fastcall virtual TfrxDBXDatabase(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDBXDatabase(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Sqlexpr::TSQLConnection* Database = {read=FDatabase};
	
__published:
	__property System::UnicodeString ConnectionName = {read=GetDatabaseName, write=SetDatabaseName};
	__property System::UnicodeString DriverName = {read=GetDriverName, write=SetDriverName};
	__property System::UnicodeString GetDriverFunc = {read=GetGetDriverFunc, write=SetGetDriverFunc};
	__property System::UnicodeString LibraryName = {read=GetLibraryName, write=SetLibraryName};
	__property LoginPrompt = {default=1};
	__property Params;
	__property System::UnicodeString VendorLib = {read=GetVendorLib, write=SetVendorLib};
	__property Connected = {default=0};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDBXDatabase(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxCustomDatabase(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDBXTable;
class PASCALIMPLEMENTATION TfrxDBXTable : public Frxcustomdb::TfrxCustomTable
{
	typedef Frxcustomdb::TfrxCustomTable inherited;
	
private:
	TfrxDBXDatabase* FDatabase;
	Sqlexpr::TSQLTable* FTable;
	void __fastcall SetDatabase(const TfrxDBXDatabase* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetMasterFields(const System::UnicodeString Value);
	virtual void __fastcall SetIndexName(const System::UnicodeString Value);
	virtual void __fastcall SetIndexFieldNames(const System::UnicodeString Value);
	virtual void __fastcall SetTableName(const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetIndexName(void);
	virtual System::UnicodeString __fastcall GetIndexFieldNames(void);
	virtual System::UnicodeString __fastcall GetTableName(void);
	
public:
	__fastcall virtual TfrxDBXTable(Classes::TComponent* AOwner);
	__fastcall virtual TfrxDBXTable(Classes::TComponent* AOwner, System::Word Flags);
	__fastcall virtual ~TfrxDBXTable(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	__property Sqlexpr::TSQLTable* Table = {read=FTable};
	
__published:
	__property TfrxDBXDatabase* Database = {read=FDatabase, write=SetDatabase};
};


class DELPHICLASS TfrxDBXQuery;
class PASCALIMPLEMENTATION TfrxDBXQuery : public Frxcustomdb::TfrxCustomQuery
{
	typedef Frxcustomdb::TfrxCustomQuery inherited;
	
private:
	TfrxDBXDatabase* FDatabase;
	Sqlexpr::TSQLQuery* FQuery;
	Classes::TStrings* FStrings;
	bool FLock;
	void __fastcall SetDatabase(const TfrxDBXDatabase* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetSQL(Classes::TStrings* Value);
	virtual Classes::TStrings* __fastcall GetSQL(void);
	virtual void __fastcall OnChangeSQL(System::TObject* Sender);
	
public:
	__fastcall virtual TfrxDBXQuery(Classes::TComponent* AOwner);
	__fastcall virtual TfrxDBXQuery(Classes::TComponent* AOwner, System::Word Flags);
	__fastcall virtual ~TfrxDBXQuery(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	virtual void __fastcall UpdateParams(void);
	virtual Fqbclass::TfqbEngine* __fastcall QBEngine(void);
	__property Sqlexpr::TSQLQuery* Query = {read=FQuery};
	
__published:
	__property TfrxDBXDatabase* Database = {read=FDatabase, write=SetDatabase};
};


class DELPHICLASS TfrxEngineDBX;
class PASCALIMPLEMENTATION TfrxEngineDBX : public Fqbclass::TfqbEngine
{
	typedef Fqbclass::TfqbEngine inherited;
	
private:
	Sqlexpr::TSQLQuery* FQuery;
	TfrxDBXDataset* FDBXDataset;
	
public:
	__fastcall virtual TfrxEngineDBX(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxEngineDBX(void);
	virtual void __fastcall ReadTableList(Classes::TStrings* ATableList);
	virtual void __fastcall ReadFieldList(const System::UnicodeString ATableName, Fqbclass::TfqbFieldList* &AFieldList);
	virtual Db::TDataSet* __fastcall ResultDataSet(void);
	virtual void __fastcall SetSQL(const System::UnicodeString Value);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxDBXComponents* DBXComponents;

}	/* namespace Frxdbxcomponents */
using namespace Frxdbxcomponents;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdbxcomponentsHPP
