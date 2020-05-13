// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclideutils.pas' rev: 21.00

#ifndef JclideutilsHPP
#define JclideutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Shlobj.hpp>	// Pascal unit
#include <Jclhelputils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Inifiles.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit
#include <Jclcompilerutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclideutils
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclBorRADException;
class PASCALIMPLEMENTATION EJclBorRADException : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclBorRADException(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclBorRADException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclBorRADException(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclBorRADException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclBorRADException(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclBorRADException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclBorRADException(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclBorRADException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclBorRADException(void) { }
	
};


#pragma option push -b-
enum TJclBorRADToolKind { brDelphi, brCppBuilder, brBorlandDevStudio };
#pragma option pop

#pragma option push -b-
enum TJclBorRADToolEdition { deSTD, dePRO, deCSS, deARC };
#pragma option pop

typedef System::UnicodeString TJclBorRADToolPath;

#pragma option push -b-
enum TJclBorPersonality { bpDelphi32, bpDelphi64, bpBCBuilder32, bpBCBuilder64, bpDelphiNet32, bpDelphiNet64, bpCSBuilder32, bpCSBuilder64, bpVisualBasic32, bpVisualBasic64, bpDesign, bpUnknown };
#pragma option pop

typedef Set<TJclBorPersonality, bpDelphi32, bpUnknown>  TJclBorPersonalities;

#pragma option push -b-
enum TJclBorDesigner { bdVCL, bdCLX };
#pragma option pop

typedef Set<TJclBorDesigner, bdVCL, bdCLX>  TJclBorDesigners;

#pragma option push -b-
enum TJclBDSPlatform { bpWin32, bpWin64, bpOSX32 };
#pragma option pop

typedef StaticArray<System::UnicodeString, 12> Jclideutils__2;

typedef StaticArray<System::UnicodeString, 2> Jclideutils__3;

typedef StaticArray<System::UnicodeString, 2> Jclideutils__4;

class DELPHICLASS TJclBorRADToolInstallationObject;
class DELPHICLASS TJclBorRADToolInstallation;
class PASCALIMPLEMENTATION TJclBorRADToolInstallationObject : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	TJclBorRADToolInstallation* FInstallation;
	
public:
	__fastcall TJclBorRADToolInstallationObject(TJclBorRADToolInstallation* AInstallation);
	__property TJclBorRADToolInstallation* Installation = {read=FInstallation};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBorRADToolInstallationObject(void) { }
	
};


class DELPHICLASS TJclBorRADToolIdeTool;
class PASCALIMPLEMENTATION TJclBorRADToolIdeTool : public TJclBorRADToolInstallationObject
{
	typedef TJclBorRADToolInstallationObject inherited;
	
private:
	System::UnicodeString FKey;
	int __fastcall GetCount(void);
	System::UnicodeString __fastcall GetParameters(int Index);
	System::UnicodeString __fastcall GetPath(int Index);
	System::UnicodeString __fastcall GetTitle(int Index);
	System::UnicodeString __fastcall GetWorkingDir(int Index);
	void __fastcall SetCount(const int Value);
	void __fastcall SetParameters(int Index, const System::UnicodeString Value);
	void __fastcall SetPath(int Index, const System::UnicodeString Value);
	void __fastcall SetTitle(int Index, const System::UnicodeString Value);
	void __fastcall SetWorkingDir(int Index, const System::UnicodeString Value);
	
protected:
	void __fastcall CheckIndex(int Index);
	
public:
	__fastcall TJclBorRADToolIdeTool(TJclBorRADToolInstallation* AInstallation);
	__property int Count = {read=GetCount, write=SetCount, nodefault};
	int __fastcall IndexOfPath(const System::UnicodeString Value);
	int __fastcall IndexOfTitle(const System::UnicodeString Value);
	void __fastcall RemoveIndex(const int Index);
	__property System::UnicodeString Key = {read=FKey};
	__property System::UnicodeString Title[int Index] = {read=GetTitle, write=SetTitle};
	__property System::UnicodeString Path[int Index] = {read=GetPath, write=SetPath};
	__property System::UnicodeString Parameters[int Index] = {read=GetParameters, write=SetParameters};
	__property System::UnicodeString WorkingDir[int Index] = {read=GetWorkingDir, write=SetWorkingDir};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBorRADToolIdeTool(void) { }
	
};


class DELPHICLASS TJclBorRADToolIdePackages;
class PASCALIMPLEMENTATION TJclBorRADToolIdePackages : public TJclBorRADToolInstallationObject
{
	typedef TJclBorRADToolInstallationObject inherited;
	
private:
	Classes::TStringList* FDisabledPackages;
	Classes::TStringList* FKnownPackages;
	Classes::TStringList* FKnownIDEPackages;
	Classes::TStringList* FExperts;
	int __fastcall GetCount(void);
	int __fastcall GetIDECount(void);
	int __fastcall GetExpertCount(void);
	System::UnicodeString __fastcall GetPackageDescriptions(int Index);
	System::UnicodeString __fastcall GetIDEPackageDescriptions(int Index);
	System::UnicodeString __fastcall GetExpertDescriptions(int Index);
	bool __fastcall GetPackageDisabled(int Index);
	System::UnicodeString __fastcall GetPackageFileNames(int Index);
	System::UnicodeString __fastcall GetIDEPackageFileNames(int Index);
	System::UnicodeString __fastcall GetExpertFileNames(int Index);
	
protected:
	System::UnicodeString __fastcall PackageEntryToFileName(const System::UnicodeString Entry);
	void __fastcall ReadPackages(void);
	void __fastcall RemoveDisabled(const System::UnicodeString FileName);
	
public:
	__fastcall TJclBorRADToolIdePackages(TJclBorRADToolInstallation* AInstallation);
	__fastcall virtual ~TJclBorRADToolIdePackages(void);
	bool __fastcall AddPackage(const System::UnicodeString FileName, const System::UnicodeString Description);
	bool __fastcall AddIDEPackage(const System::UnicodeString FileName, const System::UnicodeString Description);
	bool __fastcall AddExpert(const System::UnicodeString FileName, const System::UnicodeString Description);
	bool __fastcall RemovePackage(const System::UnicodeString FileName);
	bool __fastcall RemoveIDEPackage(const System::UnicodeString FileName);
	bool __fastcall RemoveExpert(const System::UnicodeString FileName);
	__property int Count = {read=GetCount, nodefault};
	__property int IDECount = {read=GetIDECount, nodefault};
	__property int ExpertCount = {read=GetExpertCount, nodefault};
	__property System::UnicodeString PackageDescriptions[int Index] = {read=GetPackageDescriptions};
	__property System::UnicodeString IDEPackageDescriptions[int Index] = {read=GetIDEPackageDescriptions};
	__property System::UnicodeString ExpertDescriptions[int Index] = {read=GetExpertDescriptions};
	__property System::UnicodeString PackageFileNames[int Index] = {read=GetPackageFileNames};
	__property System::UnicodeString IDEPackageFileNames[int Index] = {read=GetIDEPackageFileNames};
	__property System::UnicodeString ExpertFileNames[int Index] = {read=GetExpertFileNames};
	__property bool PackageDisabled[int Index] = {read=GetPackageDisabled};
};


class DELPHICLASS TJclBorRADToolPalette;
class PASCALIMPLEMENTATION TJclBorRADToolPalette : public TJclBorRADToolInstallationObject
{
	typedef TJclBorRADToolInstallationObject inherited;
	
private:
	System::UnicodeString FKey;
	Classes::TStringList* FTabNames;
	System::UnicodeString __fastcall GetComponentsOnTab(int Index);
	System::UnicodeString __fastcall GetHiddenComponentsOnTab(int Index);
	int __fastcall GetTabNameCount(void);
	System::UnicodeString __fastcall GetTabNames(int Index);
	void __fastcall ReadTabNames(void);
	
public:
	__fastcall TJclBorRADToolPalette(TJclBorRADToolInstallation* AInstallation);
	__fastcall virtual ~TJclBorRADToolPalette(void);
	void __fastcall ComponentsOnTabToStrings(int Index, Classes::TStrings* Strings, bool IncludeUnitName = false, bool IncludeHiddenComponents = true);
	bool __fastcall DeleteTabName(const System::UnicodeString TabName);
	bool __fastcall TabNameExists(const System::UnicodeString TabName);
	__property System::UnicodeString ComponentsOnTab[int Index] = {read=GetComponentsOnTab};
	__property System::UnicodeString HiddenComponentsOnTab[int Index] = {read=GetHiddenComponentsOnTab};
	__property System::UnicodeString Key = {read=FKey};
	__property System::UnicodeString TabNames[int Index] = {read=GetTabNames};
	__property int TabNameCount = {read=GetTabNameCount, nodefault};
};


class DELPHICLASS TJclBorRADToolRepository;
class PASCALIMPLEMENTATION TJclBorRADToolRepository : public TJclBorRADToolInstallationObject
{
	typedef TJclBorRADToolInstallationObject inherited;
	
private:
	Inifiles::TIniFile* FIniFile;
	System::UnicodeString FFileName;
	Classes::TStringList* FPages;
	Inifiles::TIniFile* __fastcall GetIniFile(void);
	Classes::TStrings* __fastcall GetPages(void);
	
public:
	__fastcall TJclBorRADToolRepository(TJclBorRADToolInstallation* AInstallation);
	__fastcall virtual ~TJclBorRADToolRepository(void);
	void __fastcall AddObject(const System::UnicodeString FileName, const System::UnicodeString ObjectType, const System::UnicodeString PageName, const System::UnicodeString ObjectName, const System::UnicodeString IconFileName, const System::UnicodeString Description, const System::UnicodeString Author, const System::UnicodeString Designer, const System::UnicodeString Ancestor = L"");
	void __fastcall CloseIniFile(void);
	System::UnicodeString __fastcall FindPage(const System::UnicodeString Name, int OptionalIndex);
	void __fastcall RemoveObjects(const System::UnicodeString PartialPath, const System::UnicodeString FileName, const System::UnicodeString ObjectType);
	__property System::UnicodeString FileName = {read=FFileName};
	__property Inifiles::TIniFile* IniFile = {read=GetIniFile};
	__property Classes::TStrings* Pages = {read=GetPages};
};


#pragma option push -b-
enum TCommandLineTool { clAsm, clBcc32, clDcc32, clDcc64, clDccIL, clMake, clProj2Mak };
#pragma option pop

typedef Set<TCommandLineTool, clAsm, clProj2Mak>  TCommandLineTools;

typedef TMetaClass* TJclBorRADToolInstallationClass;

class PASCALIMPLEMENTATION TJclBorRADToolInstallation : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Inifiles::TCustomIniFile* FConfigData;
	System::UnicodeString FConfigDataLocation;
	unsigned FRootKey;
	Classes::TStringList* FGlobals;
	System::UnicodeString FRootDir;
	System::UnicodeString FBinFolderName;
	Jclcompilerutils::TJclBCC32* FBCC32;
	Jclcompilerutils::TJclDCC32* FDCC;
	Jclcompilerutils::TJclDCC32* FDCC32;
	Jclcompilerutils::TJclBpr2Mak* FBpr2Mak;
	Jclsysutils::_di_IJclCommandLineTool FMake;
	System::UnicodeString FEditionStr;
	TJclBorRADToolEdition FEdition;
	Classes::TStringList* FEnvironmentVariables;
	TJclBorRADToolIdePackages* FIdePackages;
	TJclBorRADToolIdeTool* FIdeTools;
	int FInstalledUpdatePack;
	Jclhelputils::TJclBorlandOpenHelp* FOpenHelp;
	TJclBorRADToolPalette* FPalette;
	TJclBorRADToolRepository* FRepository;
	int FVersionNumber;
	System::UnicodeString FVersionNumberStr;
	int FIDEVersionNumber;
	System::UnicodeString FIDEVersionNumberStr;
	bool FMapCreate;
	bool FJdbgCreate;
	bool FJdbgInsert;
	bool FMapDelete;
	TCommandLineTools FCommandLineTools;
	TJclBorPersonalities FPersonalities;
	Jclsysutils::TTextHandler FOutputCallback;
	bool __fastcall GetSupportsLibSuffix(void);
	Jclcompilerutils::TJclBCC32* __fastcall GetBCC32(void);
	Jclcompilerutils::TJclDCC32* __fastcall GetDCC(void);
	Jclcompilerutils::TJclDCC32* __fastcall GetDCC32(void);
	Jclcompilerutils::TJclBpr2Mak* __fastcall GetBpr2Mak(void);
	Jclsysutils::_di_IJclCommandLineTool __fastcall GetMake(void);
	System::UnicodeString __fastcall GetDescription(void);
	System::UnicodeString __fastcall GetEditionAsText(void);
	System::UnicodeString __fastcall GetIdeExeFileName(void);
	Classes::TStrings* __fastcall GetGlobals(void);
	System::UnicodeString __fastcall GetIdeExeBuildNumber(void);
	TJclBorRADToolIdePackages* __fastcall GetIdePackages(void);
	bool __fastcall GetIsTurboExplorer(void);
	int __fastcall GetLatestUpdatePack(void);
	TJclBorRADToolPalette* __fastcall GetPalette(void);
	TJclBorRADToolRepository* __fastcall GetRepository(void);
	bool __fastcall GetUpdateNeeded(void);
	System::UnicodeString __fastcall GetDefaultBDSCommonDir(void);
	void __fastcall SetDCC(const Jclcompilerutils::TJclDCC32* Value);
	
protected:
	bool __fastcall ProcessMapFile(const System::UnicodeString BinaryFileName);
	virtual bool __fastcall CompileDelphiPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath)/* overload */;
	virtual bool __fastcall CompileDelphiPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath, const System::UnicodeString ExtraOptions)/* overload */;
	virtual bool __fastcall CompileDelphiProject(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath);
	virtual bool __fastcall CompileBCBPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall CompileBCBProject(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath);
	virtual bool __fastcall InstallDelphiPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall UninstallDelphiPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall InstallBCBPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall UninstallBCBPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall InstallDelphiIdePackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall UninstallDelphiIdePackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall InstallBCBIdePackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall UninstallBCBIdePackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall InstallDelphiExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath);
	virtual bool __fastcall UninstallDelphiExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir);
	virtual bool __fastcall InstallBCBExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath);
	virtual bool __fastcall UninstallBCBExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir);
	void __fastcall ReadInformation(void);
	bool __fastcall RemoveFromPath(System::UnicodeString &Path, const System::UnicodeString ItemsToRemove);
	virtual System::UnicodeString __fastcall GetDCPOutputPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetBPLOutputPath(TJclBDSPlatform APlatform);
	virtual Classes::TStrings* __fastcall GetEnvironmentVariables(void);
	virtual System::UnicodeString __fastcall GetVclIncludeDir(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetName(void);
	void __fastcall OutputString(const System::UnicodeString AText);
	bool __fastcall OutputFileDelete(const System::UnicodeString FileName);
	virtual void __fastcall SetOutputCallback(const Jclsysutils::TTextHandler Value);
	virtual System::UnicodeString __fastcall GetDebugDCUPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetRawDebugDCUPath(TJclBDSPlatform APlatform);
	virtual void __fastcall SetRawDebugDCUPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetLibrarySearchPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetRawLibrarySearchPath(TJclBDSPlatform APlatform);
	virtual void __fastcall SetRawLibrarySearchPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetLibraryBrowsingPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetRawLibraryBrowsingPath(TJclBDSPlatform APlatform);
	virtual void __fastcall SetRawLibraryBrowsingPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetLibFolderName(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetObjFolderName(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetLibDebugFolderName(TJclBDSPlatform APlatform);
	virtual bool __fastcall GetValid(void);
	bool __fastcall GetLongPathBug(void);
	Jclcompilerutils::TJclCompilerSettingsFormat __fastcall GetCompilerSettingsFormat(void);
	bool __fastcall GetSupportsNoConfig(void);
	bool __fastcall GetSupportsPlatform(void);
	void __fastcall CheckWin32Only(TJclBDSPlatform APlatform);
	
public:
	__fastcall virtual TJclBorRADToolInstallation(const System::UnicodeString AConfigDataLocation, unsigned ARootKey);
	__fastcall virtual ~TJclBorRADToolInstallation(void);
	__classmethod void __fastcall ExtractPaths(const System::UnicodeString Path, Classes::TStrings* List);
	__classmethod virtual int __fastcall GetLatestUpdatePackForVersion(int Version);
	__classmethod virtual System::UnicodeString __fastcall PackageSourceFileExtension();
	__classmethod virtual System::UnicodeString __fastcall ProjectSourceFileExtension();
	__classmethod virtual TJclBorRADToolKind __fastcall RadToolKind();
	virtual System::UnicodeString __fastcall RadToolName(void);
	bool __fastcall AnyInstanceRunning(void);
	bool __fastcall AddToDebugDCUPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall AddToLibrarySearchPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall AddToLibraryBrowsingPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	int __fastcall FindFolderInPath(System::UnicodeString Folder, Classes::TStrings* List);
	virtual bool __fastcall CompilePackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall InstallPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall UninstallPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall InstallIDEPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall UninstallIDEPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual bool __fastcall CompileProject(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath);
	virtual bool __fastcall InstallExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath);
	virtual bool __fastcall UninstallExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir);
	virtual bool __fastcall RegisterPackage(const System::UnicodeString BinaryFileName, const System::UnicodeString Description)/* overload */;
	virtual bool __fastcall RegisterPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString Description)/* overload */;
	virtual bool __fastcall UnregisterPackage(const System::UnicodeString BinaryFileName)/* overload */;
	virtual bool __fastcall UnregisterPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath)/* overload */;
	virtual bool __fastcall RegisterIDEPackage(const System::UnicodeString BinaryFileName, const System::UnicodeString Description)/* overload */;
	virtual bool __fastcall RegisterIDEPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString Description)/* overload */;
	virtual bool __fastcall UnregisterIDEPackage(const System::UnicodeString BinaryFileName)/* overload */;
	virtual bool __fastcall UnregisterIDEPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath)/* overload */;
	virtual bool __fastcall RegisterExpert(const System::UnicodeString BinaryFileName, const System::UnicodeString Description)/* overload */;
	virtual bool __fastcall RegisterExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString Description)/* overload */;
	virtual bool __fastcall UnregisterExpert(const System::UnicodeString BinaryFileName)/* overload */;
	virtual bool __fastcall UnregisterExpert(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir)/* overload */;
	virtual System::UnicodeString __fastcall GetDefaultProjectsDir(void);
	virtual System::UnicodeString __fastcall GetCommonProjectsDir(void);
	bool __fastcall RemoveFromDebugDCUPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall RemoveFromLibrarySearchPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall RemoveFromLibraryBrowsingPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall SubstitutePath(const System::UnicodeString Path);
	bool __fastcall SupportsVisualCLX(void);
	bool __fastcall SupportsVCL(void);
	__property System::UnicodeString LibFolderName[TJclBDSPlatform APlatform] = {read=GetLibFolderName};
	__property System::UnicodeString ObjFolderName[TJclBDSPlatform APlatform] = {read=GetObjFolderName};
	__property System::UnicodeString LibDebugFolderName[TJclBDSPlatform APlatform] = {read=GetLibDebugFolderName};
	__property TCommandLineTools CommandLineTools = {read=FCommandLineTools, nodefault};
	__property Jclcompilerutils::TJclBCC32* BCC32 = {read=GetBCC32};
	__property Jclcompilerutils::TJclDCC32* DCC = {read=GetDCC, write=SetDCC};
	__property Jclcompilerutils::TJclDCC32* DCC32 = {read=GetDCC32};
	__property Jclcompilerutils::TJclBpr2Mak* Bpr2Mak = {read=GetBpr2Mak};
	__property Jclsysutils::_di_IJclCommandLineTool Make = {read=GetMake};
	__property System::UnicodeString BinFolderName = {read=FBinFolderName};
	__property System::UnicodeString BPLOutputPath[TJclBDSPlatform APlatform] = {read=GetBPLOutputPath};
	__property System::UnicodeString DebugDCUPath[TJclBDSPlatform APlatform] = {read=GetDebugDCUPath};
	__property System::UnicodeString RawDebugDCUPath[TJclBDSPlatform APlatform] = {read=GetRawDebugDCUPath, write=SetRawDebugDCUPath};
	__property System::UnicodeString DCPOutputPath[TJclBDSPlatform APlatform] = {read=GetDCPOutputPath};
	__property System::UnicodeString DefaultProjectsDir = {read=GetDefaultProjectsDir};
	__property System::UnicodeString CommonProjectsDir = {read=GetCommonProjectsDir};
	__property System::UnicodeString Description = {read=GetDescription};
	__property TJclBorRADToolEdition Edition = {read=FEdition, nodefault};
	__property System::UnicodeString EditionAsText = {read=GetEditionAsText};
	__property Classes::TStrings* EnvironmentVariables = {read=GetEnvironmentVariables};
	__property TJclBorRADToolIdePackages* IdePackages = {read=GetIdePackages};
	__property TJclBorRADToolIdeTool* IdeTools = {read=FIdeTools};
	__property System::UnicodeString IdeExeBuildNumber = {read=GetIdeExeBuildNumber};
	__property System::UnicodeString IdeExeFileName = {read=GetIdeExeFileName};
	__property int InstalledUpdatePack = {read=FInstalledUpdatePack, nodefault};
	__property int LatestUpdatePack = {read=GetLatestUpdatePack, nodefault};
	__property System::UnicodeString LibrarySearchPath[TJclBDSPlatform APlatform] = {read=GetLibrarySearchPath};
	__property System::UnicodeString RawLibrarySearchPath[TJclBDSPlatform APlatform] = {read=GetRawLibrarySearchPath, write=SetRawLibrarySearchPath};
	__property System::UnicodeString LibraryBrowsingPath[TJclBDSPlatform APlatform] = {read=GetLibraryBrowsingPath};
	__property System::UnicodeString RawLibraryBrowsingPath[TJclBDSPlatform APlatform] = {read=GetRawLibraryBrowsingPath, write=SetRawLibraryBrowsingPath};
	__property Jclhelputils::TJclBorlandOpenHelp* OpenHelp = {read=FOpenHelp};
	__property bool MapCreate = {read=FMapCreate, write=FMapCreate, nodefault};
	__property bool JdbgCreate = {read=FJdbgCreate, write=FJdbgCreate, nodefault};
	__property bool JdbgInsert = {read=FJdbgInsert, write=FJdbgInsert, nodefault};
	__property bool MapDelete = {read=FMapDelete, write=FMapDelete, nodefault};
	__property Inifiles::TCustomIniFile* ConfigData = {read=FConfigData};
	__property System::UnicodeString ConfigDataLocation = {read=FConfigDataLocation};
	__property Classes::TStrings* Globals = {read=GetGlobals};
	__property System::UnicodeString Name = {read=GetName};
	__property TJclBorRADToolPalette* Palette = {read=GetPalette};
	__property TJclBorRADToolRepository* Repository = {read=GetRepository};
	__property System::UnicodeString RootDir = {read=FRootDir};
	__property bool UpdateNeeded = {read=GetUpdateNeeded, nodefault};
	__property bool Valid = {read=GetValid, nodefault};
	__property System::UnicodeString VclIncludeDir[TJclBDSPlatform APlatform] = {read=GetVclIncludeDir};
	__property int IDEVersionNumber = {read=FIDEVersionNumber, nodefault};
	__property System::UnicodeString IDEVersionNumberStr = {read=FIDEVersionNumberStr};
	__property int VersionNumber = {read=FVersionNumber, nodefault};
	__property System::UnicodeString VersionNumberStr = {read=FVersionNumberStr};
	__property TJclBorPersonalities Personalities = {read=FPersonalities, nodefault};
	__property bool SupportsLibSuffix = {read=GetSupportsLibSuffix, nodefault};
	__property Jclsysutils::TTextHandler OutputCallback = {read=FOutputCallback, write=SetOutputCallback};
	__property bool IsTurboExplorer = {read=GetIsTurboExplorer, nodefault};
	__property unsigned RootKey = {read=FRootKey, nodefault};
	__property bool LongPathBug = {read=GetLongPathBug, nodefault};
	__property Jclcompilerutils::TJclCompilerSettingsFormat CompilerSettingsFormat = {read=GetCompilerSettingsFormat, nodefault};
	__property bool SupportsNoConfig = {read=GetSupportsNoConfig, nodefault};
	__property bool SupportsPlatform = {read=GetSupportsPlatform, nodefault};
};


class DELPHICLASS TJclBCBInstallation;
class PASCALIMPLEMENTATION TJclBCBInstallation : public TJclBorRADToolInstallation
{
	typedef TJclBorRADToolInstallation inherited;
	
protected:
	virtual Classes::TStrings* __fastcall GetEnvironmentVariables(void);
	
public:
	__fastcall virtual TJclBCBInstallation(const System::UnicodeString AConfigDataLocation, unsigned ARootKey);
	__fastcall virtual ~TJclBCBInstallation(void);
	__classmethod virtual System::UnicodeString __fastcall PackageSourceFileExtension();
	__classmethod virtual System::UnicodeString __fastcall ProjectSourceFileExtension();
	__classmethod virtual TJclBorRADToolKind __fastcall RadToolKind();
	virtual System::UnicodeString __fastcall RadToolName(void);
	__classmethod virtual int __fastcall GetLatestUpdatePackForVersion(int Version);
};


class DELPHICLASS TJclDelphiInstallation;
class PASCALIMPLEMENTATION TJclDelphiInstallation : public TJclBorRADToolInstallation
{
	typedef TJclBorRADToolInstallation inherited;
	
protected:
	virtual Classes::TStrings* __fastcall GetEnvironmentVariables(void);
	
public:
	__fastcall virtual TJclDelphiInstallation(const System::UnicodeString AConfigDataLocation, unsigned ARootKey);
	__fastcall virtual ~TJclDelphiInstallation(void);
	__classmethod virtual System::UnicodeString __fastcall PackageSourceFileExtension();
	__classmethod virtual System::UnicodeString __fastcall ProjectSourceFileExtension();
	__classmethod virtual TJclBorRADToolKind __fastcall RadToolKind();
	__classmethod virtual int __fastcall GetLatestUpdatePackForVersion(int Version);
	HIDESBASE bool __fastcall InstallPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath);
	virtual System::UnicodeString __fastcall RadToolName(void);
};


class DELPHICLASS TJclBDSInstallation;
class PASCALIMPLEMENTATION TJclBDSInstallation : public TJclBorRADToolInstallation
{
	typedef TJclBorRADToolInstallation inherited;
	
private:
	bool FDualPackageInstallation;
	Jclhelputils::TJclHelp2Manager* FHelp2Manager;
	Jclcompilerutils::TJclDCCIL* FDCCIL;
	Jclcompilerutils::TJclDCC64* FDCC64;
	bool FPdbCreate;
	void __fastcall SetDualPackageInstallation(const bool Value);
	System::UnicodeString __fastcall GetCppPathsKeyName(void);
	System::UnicodeString __fastcall GetCppBrowsingPath(TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetRawCppBrowsingPath(TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetCppSearchPath(TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetRawCppSearchPath(TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetCppLibraryPath(TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetRawCppLibraryPath(TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetCppIncludePath(TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetRawCppIncludePath(TJclBDSPlatform APlatform);
	void __fastcall SetRawCppBrowsingPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	void __fastcall SetRawCppSearchPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	void __fastcall SetRawCppLibraryPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	void __fastcall SetRawCppIncludePath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	System::UnicodeString __fastcall GetMaxDelphiCLRVersion(void);
	Jclcompilerutils::TJclDCC64* __fastcall GetDCC64(void);
	Jclcompilerutils::TJclDCCIL* __fastcall GetDCCIL(void);
	System::UnicodeString __fastcall GetMsBuildEnvOptionsFileName(void);
	System::UnicodeString __fastcall GetMsBuildEnvironmentFileName(void);
	System::UnicodeString __fastcall GetMsBuildEnvOption(const System::UnicodeString OptionName, TJclBDSPlatform APlatform, bool Raw);
	void __fastcall SetMsBuildEnvOption(const System::UnicodeString OptionName, const System::UnicodeString Value, TJclBDSPlatform APlatform);
	System::UnicodeString __fastcall GetBDSPlatformStr(TJclBDSPlatform APlatform);
	
protected:
	virtual System::UnicodeString __fastcall GetDCPOutputPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetBPLOutputPath(TJclBDSPlatform APlatform);
	virtual Classes::TStrings* __fastcall GetEnvironmentVariables(void);
	virtual bool __fastcall CompileDelphiPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath, const System::UnicodeString ExtraOptions)/* overload */;
	virtual bool __fastcall CompileDelphiProject(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath);
	virtual System::UnicodeString __fastcall GetVclIncludeDir(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetName(void);
	virtual void __fastcall SetOutputCallback(const Jclsysutils::TTextHandler Value);
	virtual System::UnicodeString __fastcall GetLibDebugFolderName(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetLibFolderName(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetDebugDCUPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetRawDebugDCUPath(TJclBDSPlatform APlatform);
	virtual void __fastcall SetRawDebugDCUPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetLibrarySearchPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetRawLibrarySearchPath(TJclBDSPlatform APlatform);
	virtual void __fastcall SetRawLibrarySearchPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	virtual System::UnicodeString __fastcall GetLibraryBrowsingPath(TJclBDSPlatform APlatform);
	virtual System::UnicodeString __fastcall GetRawLibraryBrowsingPath(TJclBDSPlatform APlatform);
	virtual void __fastcall SetRawLibraryBrowsingPath(TJclBDSPlatform APlatform, const System::UnicodeString Value);
	virtual bool __fastcall GetValid(void);
	
public:
	__fastcall virtual TJclBDSInstallation(const System::UnicodeString AConfigDataLocation, unsigned ARootKey);
	__fastcall virtual ~TJclBDSInstallation(void);
	__classmethod virtual System::UnicodeString __fastcall PackageSourceFileExtension();
	__classmethod virtual System::UnicodeString __fastcall ProjectSourceFileExtension();
	__classmethod virtual TJclBorRADToolKind __fastcall RadToolKind();
	__classmethod virtual int __fastcall GetLatestUpdatePackForVersion(int Version);
	virtual System::UnicodeString __fastcall GetDefaultProjectsDir(void);
	virtual System::UnicodeString __fastcall GetCommonProjectsDir(void);
	__classmethod System::UnicodeString __fastcall GetDefaultProjectsDirectory(const System::UnicodeString RootDir, int IDEVersionNumber);
	__classmethod System::UnicodeString __fastcall GetCommonProjectsDirectory(const System::UnicodeString RootDir, int IDEVersionNumber);
	virtual System::UnicodeString __fastcall RadToolName(void);
	bool __fastcall AddToCppSearchPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall AddToCppBrowsingPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall AddToCppLibraryPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall AddToCppIncludePath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall RemoveFromCppSearchPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall RemoveFromCppBrowsingPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall RemoveFromCppLibraryPath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	bool __fastcall RemoveFromCppIncludePath(const System::UnicodeString Path, TJclBDSPlatform APlatform);
	__property System::UnicodeString CppSearchPath[TJclBDSPlatform APlatform] = {read=GetCppSearchPath};
	__property System::UnicodeString RawCppSearchPath[TJclBDSPlatform APlatform] = {read=GetRawCppSearchPath, write=SetRawCppSearchPath};
	__property System::UnicodeString CppBrowsingPath[TJclBDSPlatform APlatform] = {read=GetCppBrowsingPath};
	__property System::UnicodeString RawCppBrowsingPath[TJclBDSPlatform APlatform] = {read=GetRawCppBrowsingPath, write=SetRawCppBrowsingPath};
	__property System::UnicodeString CppLibraryPath[TJclBDSPlatform APlatform] = {read=GetCppLibraryPath};
	__property System::UnicodeString RawCppLibraryPath[TJclBDSPlatform APlatform] = {read=GetRawCppLibraryPath, write=SetRawCppLibraryPath};
	__property System::UnicodeString CppIncludePath[TJclBDSPlatform APlatform] = {read=GetCppIncludePath};
	__property System::UnicodeString RawCppIncludePath[TJclBDSPlatform APlatform] = {read=GetRawCppIncludePath, write=SetRawCppIncludePath};
	virtual bool __fastcall RegisterPackage(const System::UnicodeString BinaryFileName, const System::UnicodeString Description)/* overload */;
	virtual bool __fastcall UnregisterPackage(const System::UnicodeString BinaryFileName)/* overload */;
	bool __fastcall CleanPackageCache(const System::UnicodeString BinaryFileName);
	bool __fastcall CompileDelphiDotNetProject(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, TJclBDSPlatform PEFormat = (TJclBDSPlatform)(0x0), const System::UnicodeString ExtraOptions = L"");
	__property bool DualPackageInstallation = {read=FDualPackageInstallation, write=SetDualPackageInstallation, nodefault};
	__property Jclhelputils::TJclHelp2Manager* Help2Manager = {read=FHelp2Manager};
	__property Jclcompilerutils::TJclDCC64* DCC64 = {read=GetDCC64};
	__property Jclcompilerutils::TJclDCCIL* DCCIL = {read=GetDCCIL};
	__property System::UnicodeString MaxDelphiCLRVersion = {read=GetMaxDelphiCLRVersion};
	__property bool PdbCreate = {read=FPdbCreate, write=FPdbCreate, nodefault};
	
/* Hoisted overloads: */
	
protected:
	inline bool __fastcall  CompileDelphiPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath){ return TJclBorRADToolInstallation::CompileDelphiPackage(PackageName, BPLPath, DCPPath); }
	
public:
	inline bool __fastcall  RegisterPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString Description){ return TJclBorRADToolInstallation::RegisterPackage(PackageName, BPLPath, Description); }
	inline bool __fastcall  UnregisterPackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath){ return TJclBorRADToolInstallation::UnregisterPackage(PackageName, BPLPath); }
	
};


typedef bool __fastcall (__closure *TTraverseMethod)(TJclBorRADToolInstallation* Installation);

class DELPHICLASS TJclBorRADToolInstallations;
class PASCALIMPLEMENTATION TJclBorRADToolInstallations : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclBorRADToolInstallation* operator[](int Index) { return Installations[Index]; }
	
private:
	Contnrs::TObjectList* FList;
	TJclBorRADToolInstallation* __fastcall GetBDSInstallationFromVersion(int VersionNumber);
	bool __fastcall GetBDSVersionInstalled(int VersionNumber);
	int __fastcall GetCount(void);
	TJclBorRADToolInstallation* __fastcall GetInstallations(int Index);
	bool __fastcall GetBCBVersionInstalled(int VersionNumber);
	bool __fastcall GetDelphiVersionInstalled(int VersionNumber);
	TJclBorRADToolInstallation* __fastcall GetBCBInstallationFromVersion(int VersionNumber);
	TJclBorRADToolInstallation* __fastcall GetDelphiInstallationFromVersion(int VersionNumber);
	
protected:
	void __fastcall ReadInstallations(void);
	
public:
	__fastcall TJclBorRADToolInstallations(void);
	__fastcall virtual ~TJclBorRADToolInstallations(void);
	bool __fastcall AnyInstanceRunning(void);
	bool __fastcall AnyUpdatePackNeeded(System::UnicodeString &Text);
	bool __fastcall Iterate(TTraverseMethod TraverseMethod);
	__property int Count = {read=GetCount, nodefault};
	__property TJclBorRADToolInstallation* Installations[int Index] = {read=GetInstallations/*, default*/};
	__property TJclBorRADToolInstallation* BCBInstallationFromVersion[int VersionNumber] = {read=GetBCBInstallationFromVersion};
	__property TJclBorRADToolInstallation* DelphiInstallationFromVersion[int VersionNumber] = {read=GetDelphiInstallationFromVersion};
	__property TJclBorRADToolInstallation* BDSInstallationFromVersion[int VersionNumber] = {read=GetBDSInstallationFromVersion};
	__property bool BCBVersionInstalled[int VersionNumber] = {read=GetBCBVersionInstalled};
	__property bool DelphiVersionInstalled[int VersionNumber] = {read=GetDelphiVersionInstalled};
	__property bool BDSVersionInstalled[int VersionNumber] = {read=GetBDSVersionInstalled};
};


//-- var, const, procedure ---------------------------------------------------
#define SupportedDelphiVersions (Set<Byte, 0, 255> () << 0x5 << 0x6 << 0x7 << 0x8 << 0x9 << 0xa << 0xb << 0xc << 0xe << 0xf << 0x10 )
#define SupportedBCBVersions (Set<Byte, 0, 255> () << 0x5 << 0x6 << 0xa << 0xb << 0xc << 0xe << 0xf << 0x10 )
#define SupportedBDSVersions (Set<Byte, 0, 255> () << 0x1 << 0x2 << 0x3 << 0x4 << 0x5 << 0x6 << 0x7 << 0x8 << 0x9 )
#define BorRADToolRepositoryPagesSection L"Repository Pages"
#define BorRADToolRepositoryDialogsPage L"Dialogs"
#define BorRADToolRepositoryFormsPage L"Forms"
#define BorRADToolRepositoryProjectsPage L"Projects"
#define BorRADToolRepositoryDataModulesPage L"Data Modules"
#define BorRADToolRepositoryObjectType L"Type"
#define BorRADToolRepositoryFormTemplate L"FormTemplate"
#define BorRADToolRepositoryProjectTemplate L"ProjectTemplate"
#define BorRADToolRepositoryObjectName L"Name"
#define BorRADToolRepositoryObjectPage L"Page"
#define BorRADToolRepositoryObjectIcon L"Icon"
#define BorRADToolRepositoryObjectDescr L"Description"
#define BorRADToolRepositoryObjectAuthor L"Author"
#define BorRADToolRepositoryObjectAncestor L"Ancestor"
#define BorRADToolRepositoryObjectDesigner L"Designer"
#define BorRADToolRepositoryDesignerDfm L"dfm"
#define BorRADToolRepositoryDesignerXfm L"xfm"
#define BorRADToolRepositoryObjectNewForm L"DefaultNewForm"
#define BorRADToolRepositoryObjectMainForm L"DefaultMainForm"
#define CompilerExtensionDCP L".dcp"
#define CompilerExtensionBPI L".bpi"
#define CompilerExtensionLIB L".lib"
#define CompilerExtensionTDS L".tds"
#define CompilerExtensionMAP L".map"
#define CompilerExtensionDRC L".drc"
#define CompilerExtensionDEF L".def"
#define SourceExtensionCPP L".cpp"
#define SourceExtensionH L".h"
#define SourceExtensionPAS L".pas"
#define SourceExtensionDFM L".dfm"
#define SourceExtensionXFM L".xfm"
#define SourceDescriptionPAS L"Pascal source file"
#define SourceDescriptionCPP L"C++ source file"
#define DesignerVCL L"VCL"
#define DesignerCLX L"CLX"
#define ProjectTypePackage L"package"
#define ProjectTypeLibrary L"library"
#define ProjectTypeProgram L"program"
#define Personality32Bit L"32 bit"
#define Personality64Bit L"64 bit"
#define PersonalityDelphi L"Delphi"
#define PersonalityDelphiDotNet L"Delphi.net"
#define PersonalityBCB L"C++Builder"
#define PersonalityCSB L"C#Builder"
#define PersonalityVB L"Visual Basic"
#define PersonalityDesign L"Design"
#define PersonalityUnknown L"Unknown personality"
#define PersonalityBDS L"Borland Developer Studio"
extern PACKAGE StaticArray<System::WideChar *, 4> BorRADToolEditionIDs;
#define BDSPlatformWin32 L"Win32"
#define BDSPlatformWin64 L"Win64"
#define BDSPlatformOSX32 L"OSX32"
extern PACKAGE Jclideutils__2 JclBorPersonalityDescription;
extern PACKAGE Jclideutils__3 JclBorDesignerDescription;
extern PACKAGE Jclideutils__4 JclBorDesignerFormExtension;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclideutils */
using namespace Jclideutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclideutilsHPP
