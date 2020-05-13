// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclmsbuild.pas' rev: 21.00

#ifndef JclmsbuildHPP
#define JclmsbuildHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclfileutils.hpp>	// Pascal unit
#include <Jclregistry.hpp>	// Pascal unit
#include <Jclstreams.hpp>	// Pascal unit
#include <Jclsimplexml.hpp>	// Pascal unit
#include <Jclsysinfo.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclmsbuild
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclMsBuildError;
class PASCALIMPLEMENTATION EJclMsBuildError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclMsBuildError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclMsBuildError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclMsBuildError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclMsBuildError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMsBuildError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMsBuildError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMsBuildError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMsBuildError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMsBuildError(void) { }
	
};


class DELPHICLASS TJclMsBuildItem;
class PASCALIMPLEMENTATION TJclMsBuildItem : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FItemName;
	System::UnicodeString FItemInclude;
	System::UnicodeString FItemFullInclude;
	System::UnicodeString FItemExclude;
	System::UnicodeString FItemRemove;
	Classes::TStrings* FItemMetaData;
	
public:
	__fastcall TJclMsBuildItem(void);
	__fastcall virtual ~TJclMsBuildItem(void);
	__property System::UnicodeString ItemName = {read=FItemName};
	__property System::UnicodeString ItemInclude = {read=FItemInclude};
	__property System::UnicodeString ItemFullInclude = {read=FItemFullInclude};
	__property System::UnicodeString ItemExclude = {read=FItemExclude};
	__property System::UnicodeString ItemRemove = {read=FItemRemove};
	__property Classes::TStrings* ItemMetaData = {read=FItemMetaData};
};


class DELPHICLASS TJclMsBuildTaskOutput;
class PASCALIMPLEMENTATION TJclMsBuildTaskOutput : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FTaskParameter;
	System::UnicodeString FPropertyName;
	System::UnicodeString FItemName;
	
public:
	__property System::UnicodeString TaskParameter = {read=FTaskParameter};
	__property System::UnicodeString PropertyName = {read=FPropertyName};
	__property System::UnicodeString ItemName = {read=FItemName};
public:
	/* TObject.Create */ inline __fastcall TJclMsBuildTaskOutput(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMsBuildTaskOutput(void) { }
	
};


class DELPHICLASS TJclMsBuildParameter;
class PASCALIMPLEMENTATION TJclMsBuildParameter : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FParameterName;
	System::UnicodeString FParameterType;
	bool FOutput;
	bool FRequired;
	
public:
	__property System::UnicodeString ParameterName = {read=FParameterName};
	__property System::UnicodeString ParameterType = {read=FParameterType};
	__property bool Output = {read=FOutput, nodefault};
	__property bool Required = {read=FRequired, nodefault};
public:
	/* TObject.Create */ inline __fastcall TJclMsBuildParameter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMsBuildParameter(void) { }
	
};


class DELPHICLASS TJclMsBuildUsingTask;
class PASCALIMPLEMENTATION TJclMsBuildUsingTask : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FAssemblyName;
	System::UnicodeString FAssemblyFile;
	System::UnicodeString FTaskFactory;
	System::UnicodeString FTaskName;
	Contnrs::TObjectList* FParameters;
	System::UnicodeString FTaskBody;
	int __fastcall AddParameter(TJclMsBuildParameter* Parameter);
	int __fastcall GetParameterCount(void);
	TJclMsBuildParameter* __fastcall GetParameter(int Index);
	
public:
	__fastcall TJclMsBuildUsingTask(void);
	__fastcall virtual ~TJclMsBuildUsingTask(void);
	__property System::UnicodeString AssemblyName = {read=FAssemblyName};
	__property System::UnicodeString AssemblyFile = {read=FAssemblyFile};
	__property System::UnicodeString TaskFactory = {read=FTaskFactory};
	__property System::UnicodeString TaskName = {read=FTaskName};
	__property int ParameterCount = {read=GetParameterCount, nodefault};
	__property TJclMsBuildParameter* Parameters[int Index] = {read=GetParameter};
	__property System::UnicodeString TaskBody = {read=FTaskBody};
};


class DELPHICLASS TJclMsBuildTask;
class PASCALIMPLEMENTATION TJclMsBuildTask : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FTaskName;
	bool FContinueOnError;
	Classes::TStrings* FParameters;
	Contnrs::TObjectList* FOutputs;
	int __fastcall AddOutput(TJclMsBuildTaskOutput* AOutput);
	int __fastcall GetOutputCount(void);
	TJclMsBuildTaskOutput* __fastcall GetOutput(int Index);
	
public:
	__fastcall TJclMsBuildTask(void);
	__fastcall virtual ~TJclMsBuildTask(void);
	__property System::UnicodeString TaskName = {read=FTaskName};
	__property bool ContinueOnError = {read=FContinueOnError, nodefault};
	__property Classes::TStrings* Parameters = {read=FParameters};
	__property int OutputCount = {read=GetOutputCount, nodefault};
	__property TJclMsBuildTaskOutput* Outputs[int Index] = {read=GetOutput};
};


class DELPHICLASS TJclMsBuildTarget;
class PASCALIMPLEMENTATION TJclMsBuildTarget : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FTargetName;
	Classes::TStrings* FDepends;
	Classes::TStrings* FReturns;
	Classes::TStrings* FInputs;
	Classes::TStrings* FOutputs;
	Classes::TStrings* FBeforeTargets;
	Classes::TStrings* FAfterTargets;
	bool FKeepDuplicateOutputs;
	Contnrs::TObjectList* FTasks;
	Classes::TStrings* FErrorTargets;
	int __fastcall AddTask(TJclMsBuildTask* Task);
	int __fastcall GetTaskCount(void);
	TJclMsBuildTask* __fastcall GetTask(int Index);
	
public:
	__fastcall TJclMsBuildTarget(void);
	__fastcall virtual ~TJclMsBuildTarget(void);
	__property System::UnicodeString TargetName = {read=FTargetName};
	__property Classes::TStrings* Depends = {read=FDepends};
	__property Classes::TStrings* Returns = {read=FReturns};
	__property Classes::TStrings* Inputs = {read=FInputs};
	__property Classes::TStrings* Outputs = {read=FOutputs};
	__property Classes::TStrings* BeforeTargets = {read=FBeforeTargets};
	__property Classes::TStrings* AfterTargets = {read=FAfterTargets};
	__property bool KeepDuplicateOutputs = {read=FKeepDuplicateOutputs, nodefault};
	__property int TaskCount = {read=GetTaskCount, nodefault};
	__property TJclMsBuildTask* Tasks[int Index] = {read=GetTask};
	__property Classes::TStrings* ErrorTargets = {read=FErrorTargets};
};


class DELPHICLASS TJclMsBuildProperties;
class DELPHICLASS TJclMsBuildParser;
class PASCALIMPLEMENTATION TJclMsBuildProperties : public Classes::TStrings
{
	typedef Classes::TStrings inherited;
	
private:
	TJclMsBuildParser* FParser;
	Classes::TStrings* FReservedProperties;
	Classes::TStrings* FGlobalProperties;
	Classes::TStrings* FCustomProperties;
	Classes::TStrings* FEnvironmentProperties;
	
protected:
	virtual System::UnicodeString __fastcall Get(int Index);
	virtual int __fastcall GetCount(void);
	virtual System::TObject* __fastcall GetObject(int Index);
	System::UnicodeString __fastcall GetRawValue(const System::UnicodeString Name);
	virtual void __fastcall Put(int Index, const System::UnicodeString S);
	virtual void __fastcall PutObject(int Index, System::TObject* AObject);
	void __fastcall SetRawValue(const System::UnicodeString Name, const System::UnicodeString Value);
	
public:
	__fastcall TJclMsBuildProperties(TJclMsBuildParser* AParser);
	__fastcall virtual ~TJclMsBuildProperties(void);
	__property TJclMsBuildParser* Parser = {read=FParser};
	virtual void __fastcall Clear(void);
	virtual void __fastcall Delete(int Index);
	virtual int __fastcall IndexOf(const System::UnicodeString S);
	virtual void __fastcall Insert(int Index, const System::UnicodeString S);
	__property Classes::TStrings* ReservedProperties = {read=FReservedProperties};
	__property Classes::TStrings* EnvironmentProperties = {read=FEnvironmentProperties};
	__property Classes::TStrings* GlobalProperties = {read=FGlobalProperties};
	__property Classes::TStrings* CustomProperties = {read=FCustomProperties};
	__property System::UnicodeString RawValues[const System::UnicodeString Name] = {read=GetRawValue, write=SetRawValue};
};


typedef void __fastcall (__closure *TJclMsBuildImportEvent)(TJclMsBuildParser* Sender, Sysutils::TFileName &FileName, Jclsimplexml::TJclSimpleXML* &SubXml, bool &SubOwnsXml);

typedef void __fastcall (__closure *TJclMsBuildToolsVersionEvent)(TJclMsBuildParser* Sender, const System::UnicodeString ToolsVersion);

typedef bool __fastcall (__closure *TJclMsBuildRegistryPropertyEvent)(TJclMsBuildParser* Sender, HKEY Root, const System::UnicodeString Path, const System::UnicodeString Name, /* out */ System::UnicodeString &Value);

typedef bool __fastcall (__closure *TJclMsBuildFunctionPropertyEvent)(TJclMsBuildParser* Sender, const System::UnicodeString Command, /* out */ System::UnicodeString &Value);

class PASCALIMPLEMENTATION TJclMsBuildParser : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Sysutils::TFileName FCurrentFileName;
	Sysutils::TFileName FProjectFileName;
	Jclsimplexml::TJclSimpleXML* FXml;
	bool FOwnsXml;
	TJclMsBuildProperties* FProperties;
	Contnrs::TObjectList* FItems;
	Contnrs::TObjectList* FItemDefinitions;
	Contnrs::TObjectList* FTargets;
	Contnrs::TObjectList* FUsingTasks;
	Classes::TStrings* FInitialTargets;
	Classes::TStrings* FDefaultTargets;
	System::UnicodeString FToolsVersion;
	System::UnicodeString FDotNetVersion;
	bool FIgnoreFunctionProperties;
	System::UnicodeString FWorkingDirectory;
	Jclsimplexml::TJclSimpleXMLElem* FFirstPropertyGroup;
	Jclsimplexml::TJclSimpleXMLElem* FProjectExtensions;
	TJclMsBuildImportEvent FOnImport;
	TJclMsBuildToolsVersionEvent FOnToolsVersion;
	TJclMsBuildRegistryPropertyEvent FOnRegistryProperty;
	TJclMsBuildFunctionPropertyEvent FOnFunctionProperty;
	int __fastcall GetItemCount(void);
	TJclMsBuildItem* __fastcall GetItem(int Index);
	int __fastcall GetItemDefinitionCount(void);
	TJclMsBuildItem* __fastcall GetItemDefinition(int Index);
	int __fastcall GetTargetCount(void);
	TJclMsBuildTarget* __fastcall GetTarget(int Index);
	int __fastcall GetUsingTaskCount(void);
	TJclMsBuildUsingTask* __fastcall GetUsingTask(int Index);
	void __fastcall ParseChoose(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseImport(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseImportGroup(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseItem(Jclsimplexml::TJclSimpleXMLElem* XmlElem, bool Definition);
	void __fastcall ParseItemDefinitionGroup(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseItemGroup(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseItemMetaData(Jclsimplexml::TJclSimpleXMLElem* XmlElem, Classes::TStrings* ItemMetaData);
	void __fastcall ParseOnError(Jclsimplexml::TJclSimpleXMLElem* XmlElem, TJclMsBuildTarget* Target);
	bool __fastcall ParseOtherwise(Jclsimplexml::TJclSimpleXMLElem* XmlElem, bool Skip);
	void __fastcall ParseOutput(Jclsimplexml::TJclSimpleXMLElem* XmlElem, TJclMsBuildTask* Task);
	void __fastcall ParseParameter(Jclsimplexml::TJclSimpleXMLElem* XmlElem, TJclMsBuildUsingTask* UsingTask);
	void __fastcall ParseParameterGroup(Jclsimplexml::TJclSimpleXMLElem* XmlElem, TJclMsBuildUsingTask* UsingTask);
	void __fastcall ParseProject(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseProperty(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParsePropertyGroup(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseTarget(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	void __fastcall ParseTask(Jclsimplexml::TJclSimpleXMLElem* XmlElem, TJclMsBuildTarget* Target);
	void __fastcall ParseTaskBody(Jclsimplexml::TJclSimpleXMLElem* XmlElem, TJclMsBuildUsingTask* UsingTask);
	void __fastcall ParseUsingTask(Jclsimplexml::TJclSimpleXMLElem* XmlElem);
	bool __fastcall ParseWhen(Jclsimplexml::TJclSimpleXMLElem* XmlElem, bool Skip);
	void __fastcall ParseXml(Jclsimplexml::TJclSimpleXML* AXml);
	
public:
	System::UnicodeString __fastcall EvaluateFunctionProperty(const System::UnicodeString Command);
	System::UnicodeString __fastcall EvaluateList(const System::UnicodeString Name);
	System::UnicodeString __fastcall EvaluateRegistryProperty(HKEY Root, const System::UnicodeString Path, const System::UnicodeString Name);
	System::UnicodeString __fastcall EvaluateString(const System::UnicodeString S);
	System::UnicodeString __fastcall EvaluateTransform(Classes::TStrings* ItemList, const System::UnicodeString Transform);
	bool __fastcall ParseCondition(const System::UnicodeString Condition);
	bool __fastcall ParseConditionLength(const System::UnicodeString Condition, int &Position, int Len);
	bool __fastcall ParseConditionOperand(const System::UnicodeString Condition, int &Position, int Len);
	System::UnicodeString __fastcall ParseConditionString(const System::UnicodeString Condition, int &Position, int Len);
	__fastcall TJclMsBuildParser(const Sysutils::TFileName AFileName, Jclsimplexml::TJclSimpleXML* AXml, bool AOwnsXml)/* overload */;
	__fastcall TJclMsBuildParser(const Sysutils::TFileName AFileName, Jclstreams::TJclStringEncoding Encoding, System::Word CodePage)/* overload */;
	__fastcall TJclMsBuildParser(const Sysutils::TFileName AFileName, System::UnicodeString *ExtraImportsFileName, const int ExtraImportsFileName_Size, Jclstreams::TJclStringEncoding Encoding, System::Word CodePage)/* overload */;
	__fastcall virtual ~TJclMsBuildParser(void);
	void __fastcall Clear(void);
	void __fastcall ClearItems(void);
	void __fastcall ClearItemDefinitions(void);
	void __fastcall ClearTargets(void);
	void __fastcall Parse(void);
	void __fastcall Save(void);
	void __fastcall FindItemIncludes(const System::UnicodeString ItemName, Classes::TStrings* List);
	TJclMsBuildItem* __fastcall FindItemDefinition(const System::UnicodeString ItemName);
	TJclMsBuildTarget* __fastcall FindTarget(const System::UnicodeString TargetName);
	void __fastcall Init(void);
	void __fastcall InitEnvironmentProperties(void);
	void __fastcall InitReservedProperties(void);
	void __fastcall XMLEncodeValue(System::TObject* Sender, System::UnicodeString &Value);
	void __fastcall XMLDecodeValue(System::TObject* Sender, System::UnicodeString &Value);
	__property Sysutils::TFileName CurrentFileName = {read=FCurrentFileName};
	__property Sysutils::TFileName ProjectFileName = {read=FProjectFileName};
	__property Jclsimplexml::TJclSimpleXML* Xml = {read=FXml};
	__property bool OwnsXml = {read=FOwnsXml, write=FOwnsXml, nodefault};
	__property TJclMsBuildProperties* Properties = {read=FProperties};
	__property int ItemCount = {read=GetItemCount, nodefault};
	__property TJclMsBuildItem* Items[int Index] = {read=GetItem};
	__property int ItemDefinitionCount = {read=GetItemDefinitionCount, nodefault};
	__property TJclMsBuildItem* ItemDefinitions[int Index] = {read=GetItemDefinition};
	__property int TargetCount = {read=GetTargetCount, nodefault};
	__property TJclMsBuildTarget* Targets[int Index] = {read=GetTarget};
	__property int UsingTaskCount = {read=GetUsingTaskCount, nodefault};
	__property TJclMsBuildUsingTask* UsingTasks[int Index] = {read=GetUsingTask};
	__property Jclsimplexml::TJclSimpleXMLElem* ProjectExtensions = {read=FProjectExtensions};
	__property Classes::TStrings* InitialTargets = {read=FInitialTargets};
	__property Classes::TStrings* DefaultTargets = {read=FDefaultTargets};
	__property System::UnicodeString ToolsVersion = {read=FToolsVersion};
	__property System::UnicodeString DotNetVersion = {read=FDotNetVersion, write=FDotNetVersion};
	__property bool IgnoreFunctionProperties = {read=FIgnoreFunctionProperties, write=FIgnoreFunctionProperties, nodefault};
	__property System::UnicodeString WorkingDirectory = {read=FWorkingDirectory, write=FWorkingDirectory};
	__property TJclMsBuildImportEvent OnImport = {read=FOnImport, write=FOnImport};
	__property TJclMsBuildToolsVersionEvent OnToolsVersion = {read=FOnToolsVersion, write=FOnToolsVersion};
	__property TJclMsBuildRegistryPropertyEvent OnRegistryProperty = {read=FOnRegistryProperty, write=FOnRegistryProperty};
	__property TJclMsBuildFunctionPropertyEvent OnFunctionProperty = {read=FOnFunctionProperty, write=FOnFunctionProperty};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclmsbuild */
using namespace Jclmsbuild;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclmsbuildHPP
