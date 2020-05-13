// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcldebugserialization.pas' rev: 21.00

#ifndef JcldebugserializationHPP
#define JcldebugserializationHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jcldebug.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcldebugserialization
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclCustomSimpleSerializer;
class PASCALIMPLEMENTATION TJclCustomSimpleSerializer : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclCustomSimpleSerializer* operator[](int AIndex) { return Items[AIndex]; }
	
protected:
	Contnrs::TObjectList* FItems;
	System::UnicodeString FName;
	Classes::TStringList* FValues;
	int __fastcall GetCount(void);
	TJclCustomSimpleSerializer* __fastcall GetItems(int AIndex);
	
public:
	__fastcall TJclCustomSimpleSerializer(const System::UnicodeString AName);
	__fastcall virtual ~TJclCustomSimpleSerializer(void);
	TJclCustomSimpleSerializer* __fastcall AddChild(System::TObject* ASender, const System::UnicodeString AName);
	void __fastcall Clear(void);
	System::UnicodeString __fastcall ReadString(System::TObject* ASender, const System::UnicodeString AName);
	void __fastcall WriteString(System::TObject* ASender, const System::UnicodeString AName, const System::UnicodeString AValue);
	__property int Count = {read=GetCount, nodefault};
	__property TJclCustomSimpleSerializer* Items[int AIndex] = {read=GetItems/*, default*/};
	__property System::UnicodeString Name = {read=FName};
	__property Classes::TStringList* Values = {read=FValues};
};


class DELPHICLASS TJclSerializableLocationInfo;
class PASCALIMPLEMENTATION TJclSerializableLocationInfo : public Jcldebug::TJclLocationInfoEx
{
	typedef Jcldebug::TJclLocationInfoEx inherited;
	
public:
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
public:
	/* TJclLocationInfoEx.Create */ inline __fastcall TJclSerializableLocationInfo(Jcldebug::TJclCustomLocationInfoList* AParent, void * Address) : Jcldebug::TJclLocationInfoEx(AParent, Address) { }
	
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TJclSerializableLocationInfo(void) { }
	
};


class DELPHICLASS TJclSerializableLocationInfoList;
class PASCALIMPLEMENTATION TJclSerializableLocationInfoList : public Jcldebug::TJclCustomLocationInfoList
{
	typedef Jcldebug::TJclCustomLocationInfoList inherited;
	
public:
	TJclSerializableLocationInfo* operator[](int AIndex) { return Items[AIndex]; }
	
private:
	TJclSerializableLocationInfo* __fastcall GetItems(int AIndex);
	
public:
	__fastcall virtual TJclSerializableLocationInfoList(void);
	TJclSerializableLocationInfo* __fastcall Add(void * Addr);
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
	__property TJclSerializableLocationInfo* Items[int AIndex] = {read=GetItems/*, default*/};
public:
	/* TJclCustomLocationInfoList.Destroy */ inline __fastcall virtual ~TJclSerializableLocationInfoList(void) { }
	
};


class DELPHICLASS TJclSerializableThreadInfo;
class PASCALIMPLEMENTATION TJclSerializableThreadInfo : public Jcldebug::TJclCustomThreadInfo
{
	typedef Jcldebug::TJclCustomThreadInfo inherited;
	
private:
	TJclSerializableLocationInfoList* __fastcall GetStack(const int AIndex);
	
protected:
	virtual Jcldebug::TJclCustomLocationInfoListClass __fastcall GetStackClass(void);
	
public:
	__fastcall TJclSerializableThreadInfo(void);
	__fastcall virtual ~TJclSerializableThreadInfo(void);
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
	__property TJclSerializableLocationInfoList* CreationStack = {read=GetStack, index=1};
	__property TJclSerializableLocationInfoList* Stack = {read=GetStack, index=2};
};


class DELPHICLASS TJclSerializableThreadInfoList;
class PASCALIMPLEMENTATION TJclSerializableThreadInfoList : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
public:
	TJclSerializableThreadInfo* operator[](int AIndex) { return Items[AIndex]; }
	
private:
	Contnrs::TObjectList* FItems;
	TJclSerializableThreadInfo* __fastcall GetItems(int AIndex);
	int __fastcall GetCount(void);
	
public:
	__fastcall TJclSerializableThreadInfoList(void);
	__fastcall virtual ~TJclSerializableThreadInfoList(void);
	TJclSerializableThreadInfo* __fastcall Add(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall Clear(void);
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
	__property int Count = {read=GetCount, nodefault};
	__property TJclSerializableThreadInfo* Items[int AIndex] = {read=GetItems/*, default*/};
};


class DELPHICLASS TJclSerializableException;
class PASCALIMPLEMENTATION TJclSerializableException : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FExceptionClassName;
	System::UnicodeString FExceptionMessage;
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	
public:
	void __fastcall Clear(void);
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
	__property System::UnicodeString ExceptionClassName = {read=FExceptionClassName, write=FExceptionClassName};
	__property System::UnicodeString ExceptionMessage = {read=FExceptionMessage, write=FExceptionMessage};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TJclSerializableException(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TJclSerializableException(void) : Classes::TPersistent() { }
	
};


class DELPHICLASS TJclSerializableModuleInfo;
class PASCALIMPLEMENTATION TJclSerializableModuleInfo : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FStartStr;
	System::UnicodeString FEndStr;
	System::UnicodeString FSystemModuleStr;
	System::UnicodeString FModuleName;
	System::UnicodeString FBinFileVersion;
	System::UnicodeString FFileVersion;
	System::UnicodeString FFileDescription;
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	
public:
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
	__property System::UnicodeString StartStr = {read=FStartStr, write=FStartStr};
	__property System::UnicodeString EndStr = {read=FEndStr, write=FEndStr};
	__property System::UnicodeString SystemModuleStr = {read=FSystemModuleStr, write=FSystemModuleStr};
	__property System::UnicodeString ModuleName = {read=FModuleName, write=FModuleName};
	__property System::UnicodeString BinFileVersion = {read=FBinFileVersion, write=FBinFileVersion};
	__property System::UnicodeString FileVersion = {read=FFileVersion, write=FFileVersion};
	__property System::UnicodeString FileDescription = {read=FFileDescription, write=FFileDescription};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TJclSerializableModuleInfo(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TJclSerializableModuleInfo(void) : Classes::TPersistent() { }
	
};


class DELPHICLASS TJclSerializableModuleInfoList;
class PASCALIMPLEMENTATION TJclSerializableModuleInfoList : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
public:
	TJclSerializableModuleInfo* operator[](int AIndex) { return Items[AIndex]; }
	
private:
	Contnrs::TObjectList* FItems;
	int __fastcall GetCount(void);
	TJclSerializableModuleInfo* __fastcall GetItems(int AIndex);
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	
public:
	__fastcall TJclSerializableModuleInfoList(void);
	__fastcall virtual ~TJclSerializableModuleInfoList(void);
	TJclSerializableModuleInfo* __fastcall Add(void);
	void __fastcall Clear(void);
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
	__property int Count = {read=GetCount, nodefault};
	__property TJclSerializableModuleInfo* Items[int AIndex] = {read=GetItems/*, default*/};
};


class DELPHICLASS TJclSerializableExceptionInfo;
class PASCALIMPLEMENTATION TJclSerializableExceptionInfo : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclSerializableException* FException;
	TJclSerializableThreadInfoList* FThreadInfoList;
	TJclSerializableModuleInfoList* FModules;
	
public:
	__fastcall TJclSerializableExceptionInfo(void);
	__fastcall virtual ~TJclSerializableExceptionInfo(void);
	void __fastcall Deserialize(TJclCustomSimpleSerializer* ASerializer);
	void __fastcall Serialize(TJclCustomSimpleSerializer* ASerializer);
	__property TJclSerializableThreadInfoList* ThreadInfoList = {read=FThreadInfoList};
	__property TJclSerializableException* Exception = {read=FException};
	__property TJclSerializableModuleInfoList* Modules = {read=FModules};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jcldebugserialization */
using namespace Jcldebugserialization;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcldebugserializationHPP
