// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclversioncontrol.pas' rev: 21.00

#ifndef JclversioncontrolHPP
#define JclversioncontrolHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Actnlist.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclversioncontrol
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclVersionControlError;
class PASCALIMPLEMENTATION EJclVersionControlError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclVersionControlError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclVersionControlError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclVersionControlError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclVersionControlError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclVersionControlError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclVersionControlError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclVersionControlError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclVersionControlError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclVersionControlError(void) { }
	
};


#pragma option push -b-
enum TJclVersionControlActionType { vcaAdd, vcaAddSandbox, vcaBlame, vcaBranch, vcaBranchSandbox, vcaCheckOutSandbox, vcaCommit, vcaCommitSandbox, vcaContextMenu, vcaDiff, vcaExplore, vcaExploreSandbox, vcaGraph, vcaLog, vcaLogSandbox, vcaLock, vcaLockSandbox, vcaMerge, vcaMergeSandbox, vcaProperties, vcaPropertiesSandbox, vcaRename, vcaRenameSandbox, vcaRepoBrowser, vcaRevert, vcaRevertSandbox, vcaStatus, vcaStatusSandbox, vcaTag, vcaTagSandBox, vcaUpdate, vcaUpdateSandbox, vcaUpdateTo, vcaUpdateSandboxTo, vcaUnlock, vcaUnlockSandbox };
#pragma option pop

typedef Set<TJclVersionControlActionType, vcaAdd, vcaUnlockSandbox>  TJclVersionControlActionTypes;

struct TJclVersionControlActionInfo
{
	
public:
	bool Sandbox;
	bool SaveFile;
	bool AllPlugins;
	System::TResStringRec *Caption;
	System::UnicodeString ActionName;
};


class DELPHICLASS TJclVersionControlPlugin;
class PASCALIMPLEMENTATION TJclVersionControlPlugin : public System::TObject
{
	typedef System::TObject inherited;
	
protected:
	virtual TJclVersionControlActionTypes __fastcall GetSupportedActionTypes(void);
	virtual TJclVersionControlActionTypes __fastcall GetFileActions(const Sysutils::TFileName FileName);
	virtual TJclVersionControlActionTypes __fastcall GetSandboxActions(const Sysutils::TFileName SdBxName);
	virtual bool __fastcall GetEnabled(void);
	virtual System::UnicodeString __fastcall GetName(void);
	
public:
	__fastcall virtual TJclVersionControlPlugin(void);
	__fastcall virtual ~TJclVersionControlPlugin(void);
	virtual bool __fastcall GetSandboxNames(const Sysutils::TFileName FileName, Classes::TStrings* SdBxNames);
	virtual bool __fastcall ExecuteAction(const Sysutils::TFileName FileName, const TJclVersionControlActionType Action);
	__property TJclVersionControlActionTypes SupportedActionTypes = {read=GetSupportedActionTypes};
	__property TJclVersionControlActionTypes FileActions[const Sysutils::TFileName FileName] = {read=GetFileActions};
	__property TJclVersionControlActionTypes SandboxActions[const Sysutils::TFileName SdBxName] = {read=GetSandboxActions};
	__property bool Enabled = {read=GetEnabled, nodefault};
	__property System::UnicodeString Name = {read=GetName};
};


typedef TMetaClass* TJclVersionControlPluginClass;

class DELPHICLASS TJclVersionControlCache;
class PASCALIMPLEMENTATION TJclVersionControlCache : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TList* FSandboxList;
	Sysutils::TFileName FFileName;
	TJclVersionControlPlugin* FPlugin;
	TJclVersionControlActionTypes FActions;
	System::TDateTime FValidityTime;
	bool FSupported;
	Sysutils::TFileName __fastcall GetSandBox(int Index);
	TJclVersionControlActionTypes __fastcall GetSandboxAction(int Index);
	int __fastcall GetSandboxCount(void);
	
public:
	__fastcall TJclVersionControlCache(TJclVersionControlPlugin* APlugin, const Sysutils::TFileName AFileName);
	__fastcall virtual ~TJclVersionControlCache(void);
	bool __fastcall GetValid(const System::TDateTime ATime);
	__property TJclVersionControlPlugin* Plugin = {read=FPlugin};
	__property Sysutils::TFileName FileName = {read=FFileName};
	__property TJclVersionControlActionTypes Actions = {read=FActions};
	__property Sysutils::TFileName SandBoxes[int Index] = {read=GetSandBox};
	__property TJclVersionControlActionTypes SandBoxActions[int Index] = {read=GetSandboxAction};
	__property int SandBoxCount = {read=GetSandboxCount, nodefault};
	__property bool Supported = {read=FSupported, nodefault};
	__property System::TDateTime ValidityTime = {read=FValidityTime};
};


class DELPHICLASS TJclVersionControlSystemPlugin;
class PASCALIMPLEMENTATION TJclVersionControlSystemPlugin : public TJclVersionControlPlugin
{
	typedef TJclVersionControlPlugin inherited;
	
protected:
	virtual TJclVersionControlActionTypes __fastcall GetSupportedActionTypes(void);
	virtual TJclVersionControlActionTypes __fastcall GetFileActions(const Sysutils::TFileName FileName);
	virtual TJclVersionControlActionTypes __fastcall GetSandboxActions(const Sysutils::TFileName SdBxName);
	virtual bool __fastcall GetEnabled(void);
	virtual System::UnicodeString __fastcall GetName(void);
	
public:
	virtual bool __fastcall GetSandboxNames(const Sysutils::TFileName FileName, Classes::TStrings* SdBxNames);
	virtual bool __fastcall ExecuteAction(const Sysutils::TFileName FileName, const TJclVersionControlActionType Action);
public:
	/* TJclVersionControlPlugin.Create */ inline __fastcall virtual TJclVersionControlSystemPlugin(void) : TJclVersionControlPlugin() { }
	/* TJclVersionControlPlugin.Destroy */ inline __fastcall virtual ~TJclVersionControlSystemPlugin(void) { }
	
};


class DELPHICLASS TJclVersionControlPluginList;
class PASCALIMPLEMENTATION TJclVersionControlPluginList : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TList* FFileCache;
	Contnrs::TObjectList* FPluginList;
	void __fastcall ClearFileCache(void);
	TJclVersionControlPlugin* __fastcall GetPlugin(int Index);
	
public:
	__fastcall TJclVersionControlPluginList(void);
	__fastcall virtual ~TJclVersionControlPluginList(void);
	int __fastcall Count(void);
	TJclVersionControlCache* __fastcall GetFileCache(const Sysutils::TFileName FileName, const TJclVersionControlPlugin* Plugin);
	int __fastcall NumberOfEnabledPlugins(void);
	void __fastcall RegisterPluginClass(const TJclVersionControlPluginClass APluginClass);
	void __fastcall UnregisterPluginClass(const TJclVersionControlPluginClass APluginClass);
	__property TJclVersionControlPlugin* Plugins[int Index] = {read=GetPlugin};
};


class DELPHICLASS TJclVersionControlActionsCache;
class PASCALIMPLEMENTATION TJclVersionControlActionsCache : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FSandbox;
	TJclVersionControlActionTypes FActionTypes;
	
public:
	__fastcall TJclVersionControlActionsCache(System::UnicodeString ASandbox, const TJclVersionControlActionTypes &AActionTypes);
	__property System::UnicodeString Sandbox = {read=FSandbox};
	__property TJclVersionControlActionTypes ActionTypes = {read=FActionTypes};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclVersionControlActionsCache(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE TJclVersionControlPluginList* __fastcall VersionControlPluginList(void);
extern PACKAGE void __fastcall RegisterVersionControlPluginClass(const TJclVersionControlPluginClass APluginClass);
extern PACKAGE void __fastcall UnRegisterVersionControlPluginClass(const TJclVersionControlPluginClass APluginClass);
extern PACKAGE TJclVersionControlActionInfo __fastcall VersionControlActionInfo(TJclVersionControlActionType ActionType);

}	/* namespace Jclversioncontrol */
using namespace Jclversioncontrol;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclversioncontrolHPP
