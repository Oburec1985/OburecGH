// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxibxcomponents.pas' rev: 21.00

#ifndef FrxibxcomponentsHPP
#define FrxibxcomponentsHPP

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
#include <Ibdatabase.hpp>	// Pascal unit
#include <Ibtable.hpp>	// Pascal unit
#include <Ibquery.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Fqbclass.hpp>	// Pascal unit
#include <Frxdbset.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxibxcomponents
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxIBXComponents;
class PASCALIMPLEMENTATION TfrxIBXComponents : public Frxclass::TfrxDBComponents
{
	typedef Frxclass::TfrxDBComponents inherited;
	
private:
	Ibdatabase::TIBDatabase* FDefaultDatabase;
	TfrxIBXComponents* FOldComponents;
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	void __fastcall SetDefaultDatabase(Ibdatabase::TIBDatabase* Value);
	
public:
	__fastcall virtual TfrxIBXComponents(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxIBXComponents(void);
	virtual System::UnicodeString __fastcall GetDescription(void);
	
__published:
	__property Ibdatabase::TIBDatabase* DefaultDatabase = {read=FDefaultDatabase, write=SetDefaultDatabase};
};


class DELPHICLASS TfrxIBXDatabase;
class PASCALIMPLEMENTATION TfrxIBXDatabase : public Frxclass::TfrxCustomDatabase
{
	typedef Frxclass::TfrxCustomDatabase inherited;
	
private:
	Ibdatabase::TIBDatabase* FDatabase;
	Ibdatabase::TIBTransaction* FTransaction;
	int __fastcall GetSQLDialect(void);
	void __fastcall SetSQLDialect(const int Value);
	
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
	__fastcall virtual TfrxIBXDatabase(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxIBXDatabase(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall SetLogin(const System::UnicodeString Login, const System::UnicodeString Password);
	__property Ibdatabase::TIBDatabase* Database = {read=FDatabase};
	
__published:
	__property DatabaseName;
	__property LoginPrompt = {default=1};
	__property Params;
	__property int SQLDialect = {read=GetSQLDialect, write=SetSQLDialect, nodefault};
	__property Connected = {default=0};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxIBXDatabase(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxCustomDatabase(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxIBXTable;
class PASCALIMPLEMENTATION TfrxIBXTable : public Frxcustomdb::TfrxCustomTable
{
	typedef Frxcustomdb::TfrxCustomTable inherited;
	
private:
	TfrxIBXDatabase* FDatabase;
	Ibtable::TIBTable* FTable;
	void __fastcall SetDatabase(const TfrxIBXDatabase* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetMasterFields(const System::UnicodeString Value);
	virtual void __fastcall SetIndexFieldNames(const System::UnicodeString Value);
	virtual void __fastcall SetIndexName(const System::UnicodeString Value);
	virtual void __fastcall SetTableName(const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetIndexFieldNames(void);
	virtual System::UnicodeString __fastcall GetIndexName(void);
	virtual System::UnicodeString __fastcall GetTableName(void);
	
public:
	__fastcall virtual TfrxIBXTable(Classes::TComponent* AOwner);
	__fastcall virtual TfrxIBXTable(Classes::TComponent* AOwner, System::Word Flags);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	__property Ibtable::TIBTable* Table = {read=FTable};
	
__published:
	__property TfrxIBXDatabase* Database = {read=FDatabase, write=SetDatabase};
public:
	/* TfrxCustomDataset.Destroy */ inline __fastcall virtual ~TfrxIBXTable(void) { }
	
};


class DELPHICLASS TfrxIBXQuery;
class PASCALIMPLEMENTATION TfrxIBXQuery : public Frxcustomdb::TfrxCustomQuery
{
	typedef Frxcustomdb::TfrxCustomQuery inherited;
	
private:
	TfrxIBXDatabase* FDatabase;
	Ibquery::TIBQuery* FQuery;
	void __fastcall SetDatabase(const TfrxIBXDatabase* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetSQL(Classes::TStrings* Value);
	virtual Classes::TStrings* __fastcall GetSQL(void);
	
public:
	__fastcall virtual TfrxIBXQuery(Classes::TComponent* AOwner);
	__fastcall virtual TfrxIBXQuery(Classes::TComponent* AOwner, System::Word Flags);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	virtual void __fastcall UpdateParams(void);
	virtual Fqbclass::TfqbEngine* __fastcall QBEngine(void);
	__property Ibquery::TIBQuery* Query = {read=FQuery};
	
__published:
	__property TfrxIBXDatabase* Database = {read=FDatabase, write=SetDatabase};
public:
	/* TfrxCustomQuery.Destroy */ inline __fastcall virtual ~TfrxIBXQuery(void) { }
	
};


class DELPHICLASS TfrxEngineIBX;
class PASCALIMPLEMENTATION TfrxEngineIBX : public Fqbclass::TfqbEngine
{
	typedef Fqbclass::TfqbEngine inherited;
	
private:
	Ibquery::TIBQuery* FQuery;
	
public:
	__fastcall virtual TfrxEngineIBX(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxEngineIBX(void);
	virtual void __fastcall ReadTableList(Classes::TStrings* ATableList);
	virtual void __fastcall ReadFieldList(const System::UnicodeString ATableName, Fqbclass::TfqbFieldList* &AFieldList);
	virtual Db::TDataSet* __fastcall ResultDataSet(void);
	virtual void __fastcall SetSQL(const System::UnicodeString Value);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxIBXComponents* IBXComponents;

}	/* namespace Frxibxcomponents */
using namespace Frxibxcomponents;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxibxcomponentsHPP
