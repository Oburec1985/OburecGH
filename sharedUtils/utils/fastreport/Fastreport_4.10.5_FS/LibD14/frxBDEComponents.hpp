// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxbdecomponents.pas' rev: 21.00

#ifndef FrxbdecomponentsHPP
#define FrxbdecomponentsHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Frxcustomdb.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit
#include <Dbtables.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Fqbclass.hpp>	// Pascal unit
#include <Frxdbset.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxbdecomponents
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxBDEComponents;
class PASCALIMPLEMENTATION TfrxBDEComponents : public Frxclass::TfrxDBComponents
{
	typedef Frxclass::TfrxDBComponents inherited;
	
private:
	System::UnicodeString FDefaultDatabase;
	System::UnicodeString FDefaultSession;
	TfrxBDEComponents* FOldComponents;
	
public:
	__fastcall virtual TfrxBDEComponents(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxBDEComponents(void);
	virtual System::UnicodeString __fastcall GetDescription(void);
	
__published:
	__property System::UnicodeString DefaultDatabase = {read=FDefaultDatabase, write=FDefaultDatabase};
	__property System::UnicodeString DefaultSession = {read=FDefaultSession, write=FDefaultSession};
};


class DELPHICLASS TfrxBDEDatabase;
class PASCALIMPLEMENTATION TfrxBDEDatabase : public Frxclass::TfrxCustomDatabase
{
	typedef Frxclass::TfrxCustomDatabase inherited;
	
private:
	Dbtables::TDatabase* FDatabase;
	void __fastcall SetAliasName(const System::UnicodeString Value);
	void __fastcall SetDriverName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetAliasName(void);
	System::UnicodeString __fastcall GetDriverName(void);
	
protected:
	virtual bool __fastcall GetConnected(void);
	virtual System::UnicodeString __fastcall GetDatabaseName(void);
	virtual bool __fastcall GetLoginPrompt(void);
	virtual Classes::TStrings* __fastcall GetParams(void);
	virtual void __fastcall SetConnected(bool Value);
	virtual void __fastcall SetDatabaseName(const System::UnicodeString Value);
	virtual void __fastcall SetLoginPrompt(bool Value);
	virtual void __fastcall SetParams(Classes::TStrings* Value);
	
public:
	__fastcall virtual TfrxBDEDatabase(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Dbtables::TDatabase* Database = {read=FDatabase};
	
__published:
	__property System::UnicodeString AliasName = {read=GetAliasName, write=SetAliasName};
	__property DatabaseName;
	__property System::UnicodeString DriverName = {read=GetDriverName, write=SetDriverName};
	__property LoginPrompt = {default=1};
	__property Params;
	__property Connected = {default=0};
public:
	/* TfrxDialogComponent.Destroy */ inline __fastcall virtual ~TfrxBDEDatabase(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxBDEDatabase(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxCustomDatabase(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxBDETable;
class PASCALIMPLEMENTATION TfrxBDETable : public Frxcustomdb::TfrxCustomTable
{
	typedef Frxcustomdb::TfrxCustomTable inherited;
	
private:
	Dbtables::TTable* FTable;
	void __fastcall SetDatabaseName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetDatabaseName(void);
	void __fastcall SetSessionName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetSessionName(void);
	
protected:
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetMasterFields(const System::UnicodeString Value);
	virtual void __fastcall SetIndexName(const System::UnicodeString Value);
	virtual void __fastcall SetIndexFieldNames(const System::UnicodeString Value);
	virtual void __fastcall SetTableName(const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetIndexName(void);
	virtual System::UnicodeString __fastcall GetIndexFieldNames(void);
	virtual System::UnicodeString __fastcall GetTableName(void);
	
public:
	__fastcall virtual TfrxBDETable(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property Dbtables::TTable* Table = {read=FTable};
	
__published:
	__property System::UnicodeString DatabaseName = {read=GetDatabaseName, write=SetDatabaseName};
	__property System::UnicodeString SessionName = {read=GetSessionName, write=SetSessionName};
public:
	/* TfrxCustomDataset.Destroy */ inline __fastcall virtual ~TfrxBDETable(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxBDETable(Classes::TComponent* AOwner, System::Word Flags) : Frxcustomdb::TfrxCustomTable(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxBDEQuery;
class PASCALIMPLEMENTATION TfrxBDEQuery : public Frxcustomdb::TfrxCustomQuery
{
	typedef Frxcustomdb::TfrxCustomQuery inherited;
	
private:
	Dbtables::TQuery* FQuery;
	void __fastcall SetDatabaseName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetDatabaseName(void);
	void __fastcall SetSessionName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetSessionName(void);
	
protected:
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetSQL(Classes::TStrings* Value);
	virtual Classes::TStrings* __fastcall GetSQL(void);
	
public:
	__fastcall virtual TfrxBDEQuery(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall UpdateParams(void);
	virtual Fqbclass::TfqbEngine* __fastcall QBEngine(void);
	__property Dbtables::TQuery* Query = {read=FQuery};
	
__published:
	__property System::UnicodeString DatabaseName = {read=GetDatabaseName, write=SetDatabaseName};
	__property System::UnicodeString SessionName = {read=GetSessionName, write=SetSessionName};
public:
	/* TfrxCustomQuery.Destroy */ inline __fastcall virtual ~TfrxBDEQuery(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxBDEQuery(Classes::TComponent* AOwner, System::Word Flags) : Frxcustomdb::TfrxCustomQuery(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxEngineBDE;
class PASCALIMPLEMENTATION TfrxEngineBDE : public Fqbclass::TfqbEngine
{
	typedef Fqbclass::TfqbEngine inherited;
	
private:
	Dbtables::TQuery* FQuery;
	
public:
	__fastcall virtual TfrxEngineBDE(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxEngineBDE(void);
	virtual void __fastcall ReadTableList(Classes::TStrings* ATableList);
	virtual void __fastcall ReadFieldList(const System::UnicodeString ATableName, Fqbclass::TfqbFieldList* &AFieldList);
	virtual Db::TDataSet* __fastcall ResultDataSet(void);
	virtual void __fastcall SetSQL(const System::UnicodeString Value);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxBDEComponents* BDEComponents;

}	/* namespace Frxbdecomponents */
using namespace Frxbdecomponents;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxbdecomponentsHPP
