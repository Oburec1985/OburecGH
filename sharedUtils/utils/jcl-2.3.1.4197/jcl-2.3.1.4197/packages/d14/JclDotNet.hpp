// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcldotnet.pas' rev: 21.00

#ifndef JcldotnetHPP
#define JcldotnetHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclwidestrings.hpp>	// Pascal unit
#include <Mscoree_tlb.hpp>	// Pascal unit
#include <Mscorlib_tlb.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcldotnet
{
//-- type declarations -------------------------------------------------------
typedef System::TInterfacedObject TJclClrBase;

#pragma option push -b-
enum TJclClrHostFlavor { hfServer, hfWorkStation };
#pragma option pop

#pragma option push -b-
enum TJclClrHostLoaderFlag { hlOptSingleDomain, hlOptMultiDomain, hlOptMultiDomainHost, hlSafeMode, hlSetPreference };
#pragma option pop

typedef Set<TJclClrHostLoaderFlag, hlOptSingleDomain, hlSetPreference>  TJclClrHostLoaderFlags;

class DELPHICLASS EJclClrException;
class PASCALIMPLEMENTATION EJclClrException : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclClrException(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclClrException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclClrException(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclClrException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclClrException(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclClrException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclClrException(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclClrException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclClrException(void) { }
	
};


class DELPHICLASS TJclClrHost;
class DELPHICLASS TJclClrAppDomain;
class DELPHICLASS TJclClrAppDomainSetup;
class PASCALIMPLEMENTATION TJclClrHost : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
public:
	TJclClrAppDomain* operator[](const int Idx) { return AppDomains[Idx]; }
	
private:
	Mscoree_tlb::_di_ICorRuntimeHost FDefaultInterface;
	Contnrs::TObjectList* FAppDomains;
	void __fastcall EnumAppDomains(void);
	TJclClrAppDomain* __fastcall GetAppDomain(const int Idx);
	int __fastcall GetAppDomainCount(void);
	Mscorlib_tlb::_di__AppDomain __fastcall GetDefaultAppDomain(void);
	Mscorlib_tlb::_di__AppDomain __fastcall GetCurrentAppDomain(void);
	
protected:
	int __fastcall AddAppDomain(const TJclClrAppDomain* AppDomain);
	int __fastcall RemoveAppDomain(const TJclClrAppDomain* AppDomain);
	
public:
	__fastcall TJclClrHost(const System::WideString ClrVer, const TJclClrHostFlavor Flavor, const bool ConcurrentGC, const TJclClrHostLoaderFlags LoaderFlags);
	__fastcall virtual ~TJclClrHost(void);
	void __fastcall Start(void);
	void __fastcall Stop(void);
	void __fastcall Refresh(void);
	TJclClrAppDomainSetup* __fastcall CreateDomainSetup(void);
	TJclClrAppDomain* __fastcall CreateAppDomain(const System::WideString Name, const TJclClrAppDomainSetup* Setup = (TJclClrAppDomainSetup*)(0x0), const Mscorlib_tlb::_di__Evidence Evidence = Mscorlib_tlb::_di__Evidence());
	bool __fastcall FindAppDomain(const Mscorlib_tlb::_di__AppDomain Intf, TJclClrAppDomain* &Ret)/* overload */;
	bool __fastcall FindAppDomain(const System::WideString Name, TJclClrAppDomain* &Ret)/* overload */;
	__classmethod System::WideString __fastcall CorSystemDirectory();
	__classmethod System::WideString __fastcall CorVersion();
	__classmethod System::WideString __fastcall CorRequiredVersion();
	__classmethod void __fastcall GetClrVersions(Classes::TStrings* VersionNames)/* overload */;
	__property TJclClrAppDomain* AppDomains[const int Idx] = {read=GetAppDomain/*, default*/};
	__property int AppDomainCount = {read=GetAppDomainCount, nodefault};
	__property Mscorlib_tlb::_di__AppDomain DefaultAppDomain = {read=GetDefaultAppDomain};
	__property Mscorlib_tlb::_di__AppDomain CurrentAppDomain = {read=GetCurrentAppDomain};
	__property Mscoree_tlb::_di_ICorRuntimeHost DefaultInterface = {read=FDefaultInterface};
private:
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Mscoree_tlb::_di_ICorRuntimeHost() { return DefaultInterface; }
	#else
	operator ICorRuntimeHost*(void) { return (ICorRuntimeHost*)DefaultInterface; }
	#endif
	
};


typedef DynamicArray<System::WideString> TJclClrAssemblyArguments;

class DELPHICLASS TJclClrAssembly;
class PASCALIMPLEMENTATION TJclClrAppDomain : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	TJclClrHost* FHost;
	Mscorlib_tlb::_di__AppDomain FDefaultInterface;
	
public:
	__fastcall TJclClrAppDomain(const TJclClrHost* AHost, const Mscorlib_tlb::_di__AppDomain AAppDomain);
	TJclClrAssembly* __fastcall Load(const System::WideString AssemblyString, const Mscorlib_tlb::_di__Evidence AssemblySecurity = Mscorlib_tlb::_di__Evidence())/* overload */;
	TJclClrAssembly* __fastcall Load(const Classes::TStream* RawAssemblyStream, const Classes::TStream* RawSymbolStoreStream = (Classes::TStream*)(0x0), const Mscorlib_tlb::_di__Evidence AssemblySecurity = Mscorlib_tlb::_di__Evidence())/* overload */;
	int __fastcall Execute(const Sysutils::TFileName AssemblyFile, const Mscorlib_tlb::_di__Evidence AssemblySecurity = Mscorlib_tlb::_di__Evidence())/* overload */;
	int __fastcall Execute(const Sysutils::TFileName AssemblyFile, const TJclClrAssemblyArguments Arguments, const Mscorlib_tlb::_di__Evidence AssemblySecurity = Mscorlib_tlb::_di__Evidence())/* overload */;
	int __fastcall Execute(const Sysutils::TFileName AssemblyFile, const Classes::TStrings* Arguments, const Mscorlib_tlb::_di__Evidence AssemblySecurity = Mscorlib_tlb::_di__Evidence())/* overload */;
	void __fastcall Unload(void);
	__property TJclClrHost* Host = {read=FHost};
	__property Mscorlib_tlb::_di__AppDomain DefaultInterface = {read=FDefaultInterface};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrAppDomain(void) { }
	
private:
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Mscorlib_tlb::_di__AppDomain() { return DefaultInterface; }
	#else
	operator _AppDomain*(void) { return (_AppDomain*)DefaultInterface; }
	#endif
	
};


class PASCALIMPLEMENTATION TJclClrAppDomainSetup : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	Mscorlib_tlb::_di_IAppDomainSetup FDefaultInterface;
	System::WideString __fastcall GetApplicationBase(void);
	System::WideString __fastcall GetApplicationName(void);
	System::WideString __fastcall GetCachePath(void);
	System::WideString __fastcall GetConfigurationFile(void);
	System::WideString __fastcall GetDynamicBase(void);
	System::WideString __fastcall GetLicenseFile(void);
	System::WideString __fastcall GetPrivateBinPath(void);
	System::WideString __fastcall GetPrivateBinPathProbe(void);
	System::WideString __fastcall GetShadowCopyDirectories(void);
	System::WideString __fastcall GetShadowCopyFiles(void);
	void __fastcall SetApplicationBase(const System::WideString Value);
	void __fastcall SetApplicationName(const System::WideString Value);
	void __fastcall SetCachePath(const System::WideString Value);
	void __fastcall SetConfigurationFile(const System::WideString Value);
	void __fastcall SetDynamicBase(const System::WideString Value);
	void __fastcall SetLicenseFile(const System::WideString Value);
	void __fastcall SetPrivateBinPath(const System::WideString Value);
	void __fastcall SetPrivateBinPathProbe(const System::WideString Value);
	void __fastcall SetShadowCopyDirectories(const System::WideString Value);
	void __fastcall SetShadowCopyFiles(const System::WideString Value);
	
public:
	__fastcall TJclClrAppDomainSetup(Mscorlib_tlb::_di_IAppDomainSetup Intf);
	__property System::WideString ApplicationBase = {read=GetApplicationBase, write=SetApplicationBase};
	__property System::WideString ApplicationName = {read=GetApplicationName, write=SetApplicationName};
	__property System::WideString CachePath = {read=GetCachePath, write=SetCachePath};
	__property System::WideString ConfigurationFile = {read=GetConfigurationFile, write=SetConfigurationFile};
	__property System::WideString DynamicBase = {read=GetDynamicBase, write=SetDynamicBase};
	__property System::WideString LicenseFile = {read=GetLicenseFile, write=SetLicenseFile};
	__property System::WideString PrivateBinPath = {read=GetPrivateBinPath, write=SetPrivateBinPath};
	__property System::WideString PrivateBinPathProbe = {read=GetPrivateBinPathProbe, write=SetPrivateBinPathProbe};
	__property System::WideString ShadowCopyDirectories = {read=GetShadowCopyDirectories, write=SetShadowCopyDirectories};
	__property System::WideString ShadowCopyFiles = {read=GetShadowCopyFiles, write=SetShadowCopyFiles};
	__property Mscorlib_tlb::_di_IAppDomainSetup DefaultInterface = {read=FDefaultInterface};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrAppDomainSetup(void) { }
	
private:
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Mscorlib_tlb::_di_IAppDomainSetup() { return DefaultInterface; }
	#else
	operator IAppDomainSetup*(void) { return (IAppDomainSetup*)DefaultInterface; }
	#endif
	
};


class PASCALIMPLEMENTATION TJclClrAssembly : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	Mscorlib_tlb::_di__Assembly FDefaultInterface;
	
public:
	__fastcall TJclClrAssembly(Mscorlib_tlb::_di__Assembly Intf);
	__property Mscorlib_tlb::_di__Assembly DefaultInterface = {read=FDefaultInterface};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrAssembly(void) { }
	
private:
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Mscorlib_tlb::_di__Assembly() { return DefaultInterface; }
	#else
	operator _Assembly*(void) { return (_Assembly*)DefaultInterface; }
	#endif
	
};


class DELPHICLASS TJclClrField;
class PASCALIMPLEMENTATION TJclClrField : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	/* TObject.Create */ inline __fastcall TJclClrField(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrField(void) { }
	
};


class DELPHICLASS TJclClrProperty;
class PASCALIMPLEMENTATION TJclClrProperty : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	/* TObject.Create */ inline __fastcall TJclClrProperty(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrProperty(void) { }
	
};


class DELPHICLASS TJclClrMethod;
class PASCALIMPLEMENTATION TJclClrMethod : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	Mscorlib_tlb::_di__MethodInfo FDefaultInterface;
	
public:
	__property Mscorlib_tlb::_di__MethodInfo DefaultInterface = {read=FDefaultInterface};
public:
	/* TObject.Create */ inline __fastcall TJclClrMethod(void) : System::TInterfacedObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrMethod(void) { }
	
private:
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Mscorlib_tlb::_di__MethodInfo() { return DefaultInterface; }
	#else
	operator _MethodInfo*(void) { return (_MethodInfo*)DefaultInterface; }
	#endif
	
};


class DELPHICLASS TJclClrObject;
class PASCALIMPLEMENTATION TJclClrObject : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclClrMethod* __fastcall GetMethod(const System::WideString Name);
	TJclClrField* __fastcall GetField(const System::WideString Name);
	TJclClrProperty* __fastcall GetProperty(const System::WideString Name);
	
public:
	__fastcall TJclClrObject(const System::WideString AssemblyName, const System::WideString NamespaceName, const System::WideString ClassName, System::TVarRec const *Parameters, const int Parameters_Size)/* overload */;
	__fastcall TJclClrObject(const System::WideString AssemblyName, const System::WideString NamespaceName, const System::WideString ClassName, const bool NewInstance)/* overload */;
	__property TJclClrField* Fields[const System::WideString Name] = {read=GetField};
	__property TJclClrProperty* Properties[const System::WideString Name] = {read=GetProperty};
	__property TJclClrMethod* Methods[const System::WideString Name] = {read=GetMethod};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclClrObject(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt STARTUP_CONCURRENT_GC = 0x1;
static const ShortInt STARTUP_LOADER_OPTIMIZATION_MASK = 0x6;
static const ShortInt STARTUP_LOADER_OPTIMIZATION_SINGLE_DOMAIN = 0x2;
static const ShortInt STARTUP_LOADER_OPTIMIZATION_MULTI_DOMAIN = 0x4;
static const ShortInt STARTUP_LOADER_OPTIMIZATION_MULTI_DOMAIN_HOST = 0x6;
static const ShortInt STARTUP_LOADER_SAFEMODE = 0x10;
static const Word STARTUP_LOADER_SETPREFERENCE = 0x100;
static const ShortInt RUNTIME_INFO_UPGRADE_VERSION = 0x1;
static const ShortInt RUNTIME_INFO_REQUEST_IA64 = 0x2;
static const ShortInt RUNTIME_INFO_REQUEST_AMD64 = 0x4;
static const ShortInt RUNTIME_INFO_REQUEST_X86 = 0x8;
static const ShortInt RUNTIME_INFO_DONT_RETURN_DIRECTORY = 0x10;
static const ShortInt RUNTIME_INFO_DONT_RETURN_VERSION = 0x20;
static const ShortInt RUNTIME_INFO_DONT_SHOW_ERROR_DIALOG = 0x40;
#define mscoree_dll L"mscoree.dll"
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE int __fastcall CompareCLRVersions(const System::UnicodeString LeftVersion, const System::UnicodeString RightVersion);

}	/* namespace Jcldotnet */
using namespace Jcldotnet;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcldotnetHPP
