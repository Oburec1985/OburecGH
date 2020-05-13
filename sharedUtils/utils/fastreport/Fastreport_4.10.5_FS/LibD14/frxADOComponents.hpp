// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxadocomponents.pas' rev: 21.00

#ifndef FrxadocomponentsHPP
#define FrxadocomponentsHPP

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
#include <Adodb.hpp>	// Pascal unit
#include <Adoint.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Fqbclass.hpp>	// Pascal unit
#include <Frxdbset.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxadocomponents
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxADOComponents;
class PASCALIMPLEMENTATION TfrxADOComponents : public Frxclass::TfrxDBComponents
{
	typedef Frxclass::TfrxDBComponents inherited;
	
private:
	Adodb::TADOConnection* FDefaultDatabase;
	TfrxADOComponents* FOldComponents;
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	void __fastcall SetDefaultDatabase(Adodb::TADOConnection* Value);
	
public:
	__fastcall virtual TfrxADOComponents(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxADOComponents(void);
	virtual System::UnicodeString __fastcall GetDescription(void);
	
__published:
	__property Adodb::TADOConnection* DefaultDatabase = {read=FDefaultDatabase, write=SetDefaultDatabase};
};


class DELPHICLASS TfrxADODatabase;
class PASCALIMPLEMENTATION TfrxADODatabase : public Frxclass::TfrxCustomDatabase
{
	typedef Frxclass::TfrxCustomDatabase inherited;
	
private:
	Adodb::TADOConnection* FDatabase;
	
protected:
	virtual void __fastcall SetConnected(bool Value);
	virtual void __fastcall SetDatabaseName(const System::UnicodeString Value);
	virtual void __fastcall SetLoginPrompt(bool Value);
	virtual bool __fastcall GetConnected(void);
	virtual System::UnicodeString __fastcall GetDatabaseName(void);
	virtual bool __fastcall GetLoginPrompt(void);
	void __fastcall ADOBeforeConnect(System::TObject* Sende);
	void __fastcall ADOAfterDisconnect(System::TObject* Sende);
	
public:
	__fastcall virtual TfrxADODatabase(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall SetLogin(const System::UnicodeString Login, const System::UnicodeString Password);
	virtual System::WideString __fastcall ToString(void);
	virtual void __fastcall FromString(const System::WideString Connection);
	__property Adodb::TADOConnection* Database = {read=FDatabase};
	
__published:
	__property DatabaseName;
	__property LoginPrompt = {default=1};
	__property Connected = {default=0};
public:
	/* TfrxDialogComponent.Destroy */ inline __fastcall virtual ~TfrxADODatabase(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxADODatabase(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxCustomDatabase(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxADOTable;
class PASCALIMPLEMENTATION TfrxADOTable : public Frxcustomdb::TfrxCustomTable
{
	typedef Frxcustomdb::TfrxCustomTable inherited;
	
private:
	TfrxADODatabase* FDatabase;
	Adodb::TADOTable* FTable;
	void __fastcall SetDatabase(TfrxADODatabase* Value);
	
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
	__fastcall virtual TfrxADOTable(Classes::TComponent* AOwner);
	__fastcall virtual TfrxADOTable(Classes::TComponent* AOwner, System::Word Flags);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	__property Adodb::TADOTable* Table = {read=FTable};
	
__published:
	__property TfrxADODatabase* Database = {read=FDatabase, write=SetDatabase};
public:
	/* TfrxCustomDataset.Destroy */ inline __fastcall virtual ~TfrxADOTable(void) { }
	
};


class DELPHICLASS TfrxADOQuery;
class PASCALIMPLEMENTATION TfrxADOQuery : public Frxcustomdb::TfrxCustomQuery
{
	typedef Frxcustomdb::TfrxCustomQuery inherited;
	
private:
	TfrxADODatabase* FDatabase;
	Adodb::TADOQuery* FQuery;
	Classes::TStrings* FStrings;
	bool FLock;
	void __fastcall SetDatabase(TfrxADODatabase* Value);
	int __fastcall GetCommandTimeout(void);
	void __fastcall SetCommandTimeout(const int Value);
	Adodb::TADOLockType __fastcall GetLockType(void);
	void __fastcall SetLockType(const Adodb::TADOLockType Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall OnChangeSQL(System::TObject* Sender);
	virtual void __fastcall SetMaster(const Db::TDataSource* Value);
	virtual void __fastcall SetSQL(Classes::TStrings* Value);
	virtual Classes::TStrings* __fastcall GetSQL(void);
	
public:
	__fastcall virtual TfrxADOQuery(Classes::TComponent* AOwner);
	__fastcall virtual TfrxADOQuery(Classes::TComponent* AOwner, System::Word Flags);
	__fastcall virtual ~TfrxADOQuery(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall BeforeStartReport(void);
	virtual void __fastcall UpdateParams(void);
	virtual Fqbclass::TfqbEngine* __fastcall QBEngine(void);
	__property Adodb::TADOQuery* Query = {read=FQuery};
	
__published:
	__property int CommandTimeout = {read=GetCommandTimeout, write=SetCommandTimeout, nodefault};
	__property TfrxADODatabase* Database = {read=FDatabase, write=SetDatabase};
	__property Adodb::TADOLockType LockType = {read=GetLockType, write=SetLockType, nodefault};
};


class DELPHICLASS TfrxEngineADO;
class PASCALIMPLEMENTATION TfrxEngineADO : public Fqbclass::TfqbEngine
{
	typedef Fqbclass::TfqbEngine inherited;
	
private:
	Adodb::TADOQuery* FQuery;
	
public:
	__fastcall virtual TfrxEngineADO(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxEngineADO(void);
	virtual void __fastcall ReadTableList(Classes::TStrings* ATableList);
	virtual void __fastcall ReadFieldList(const System::UnicodeString ATableName, Fqbclass::TfqbFieldList* &AFieldList);
	virtual Db::TDataSet* __fastcall ResultDataSet(void);
	virtual void __fastcall SetSQL(const System::UnicodeString Value);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxADOComponents* ADOComponents;
extern PACKAGE void __fastcall frxParamsToTParameters(Frxcustomdb::TfrxCustomQuery* Query, Adodb::TParameters* Params);
extern PACKAGE void __fastcall frxADOGetTableNames(Adodb::TADOConnection* conADO, Classes::TStrings* List, bool SystemTables);

}	/* namespace Frxadocomponents */
using namespace Frxadocomponents;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxadocomponentsHPP
