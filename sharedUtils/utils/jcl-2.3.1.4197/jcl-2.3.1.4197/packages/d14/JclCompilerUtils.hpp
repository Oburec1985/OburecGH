// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclcompilerutils.pas' rev: 21.00

#ifndef JclcompilerutilsHPP
#define JclcompilerutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Inifiles.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclcompilerutils
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclCompilerUtilsException;
class PASCALIMPLEMENTATION EJclCompilerUtilsException : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclCompilerUtilsException(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclCompilerUtilsException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclCompilerUtilsException(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclCompilerUtilsException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclCompilerUtilsException(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclCompilerUtilsException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclCompilerUtilsException(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclCompilerUtilsException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclCompilerUtilsException(void) { }
	
};


#pragma option push -b-
enum TJclCompilerSettingsFormat { csfDOF, csfBDSProj, csfMsBuild };
#pragma option pop

class DELPHICLASS TJclBorlandCommandLineTool;
typedef void __fastcall (__closure *TJclBorlandCommandLineToolEvent)(TJclBorlandCommandLineTool* Sender);

class PASCALIMPLEMENTATION TJclBorlandCommandLineTool : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	System::UnicodeString FBinDirectory;
	TJclCompilerSettingsFormat FCompilerSettingsFormat;
	bool FLongPathBug;
	Classes::TStringList* FOptions;
	Jclsysutils::TTextHandler FOutputCallback;
	System::UnicodeString FOutput;
	TJclBorlandCommandLineToolEvent FOnAfterExecute;
	TJclBorlandCommandLineToolEvent FOnBeforeExecute;
	void __fastcall OemTextHandler(const System::UnicodeString Text);
	
protected:
	void __fastcall CheckOutputValid(void);
	System::UnicodeString __fastcall GetFileName(void);
	bool __fastcall InternalExecute(const System::UnicodeString CommandLine);
	
public:
	__fastcall TJclBorlandCommandLineTool(const System::UnicodeString ABinDirectory, bool ALongPathBug, TJclCompilerSettingsFormat ACompilerSettingsFormat);
	__fastcall virtual ~TJclBorlandCommandLineTool(void);
	virtual System::UnicodeString __fastcall GetExeName(void);
	Classes::TStrings* __fastcall GetOptions(void);
	System::UnicodeString __fastcall GetOutput(void);
	Jclsysutils::TTextHandler __fastcall GetOutputCallback(void);
	void __fastcall AddPathOption(const System::UnicodeString Option, const System::UnicodeString Path);
	virtual bool __fastcall Execute(const System::UnicodeString CommandLine);
	void __fastcall SetOutputCallback(const Jclsysutils::TTextHandler CallbackMethod);
	__property System::UnicodeString BinDirectory = {read=FBinDirectory};
	__property TJclCompilerSettingsFormat CompilerSettingsFormat = {read=FCompilerSettingsFormat, nodefault};
	__property System::UnicodeString ExeName = {read=GetExeName};
	__property bool LongPathBug = {read=FLongPathBug, nodefault};
	__property Classes::TStrings* Options = {read=GetOptions};
	__property Jclsysutils::TTextHandler OutputCallback = {write=SetOutputCallback};
	__property System::UnicodeString Output = {read=GetOutput};
	__property System::UnicodeString FileName = {read=GetFileName};
	__property TJclBorlandCommandLineToolEvent OnAfterExecute = {read=FOnAfterExecute, write=FOnAfterExecute};
	__property TJclBorlandCommandLineToolEvent OnBeforeExecute = {read=FOnBeforeExecute, write=FOnBeforeExecute};
private:
	void *__IJclCommandLineTool;	/* Jclsysutils::IJclCommandLineTool */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator Jclsysutils::_di_IJclCommandLineTool()
	{
		Jclsysutils::_di_IJclCommandLineTool intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclCommandLineTool*(void) { return (IJclCommandLineTool*)&__IJclCommandLineTool; }
	#endif
	
};


class DELPHICLASS TJclBCC32;
class PASCALIMPLEMENTATION TJclBCC32 : public TJclBorlandCommandLineTool
{
	typedef TJclBorlandCommandLineTool inherited;
	
public:
	virtual System::UnicodeString __fastcall GetExeName(void);
public:
	/* TJclBorlandCommandLineTool.Create */ inline __fastcall TJclBCC32(const System::UnicodeString ABinDirectory, bool ALongPathBug, TJclCompilerSettingsFormat ACompilerSettingsFormat) : TJclBorlandCommandLineTool(ABinDirectory, ALongPathBug, ACompilerSettingsFormat) { }
	/* TJclBorlandCommandLineTool.Destroy */ inline __fastcall virtual ~TJclBCC32(void) { }
	
};


struct TProjectOptions
{
	
public:
	bool UsePackages;
	System::UnicodeString UnitOutputDir;
	System::UnicodeString SearchPath;
	System::UnicodeString DynamicPackages;
	System::UnicodeString SearchDcpPath;
	System::UnicodeString Conditionals;
	System::UnicodeString Namespace;
};


class DELPHICLASS TJclDCC32;
class PASCALIMPLEMENTATION TJclDCC32 : public TJclBorlandCommandLineTool
{
	typedef TJclBorlandCommandLineTool inherited;
	
private:
	System::UnicodeString FDCPSearchPath;
	System::UnicodeString FLibrarySearchPath;
	System::UnicodeString FLibraryDebugSearchPath;
	System::UnicodeString FCppSearchPath;
	bool FSupportsNoConfig;
	bool FSupportsPlatform;
	
protected:
	void __fastcall AddProjectOptions(const System::UnicodeString ProjectFileName, const System::UnicodeString DCPPath);
	bool __fastcall Compile(const System::UnicodeString ProjectFileName);
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetPlatform();
	__fastcall TJclDCC32(const System::UnicodeString ABinDirectory, bool ALongPathBug, TJclCompilerSettingsFormat ACompilerSettingsFormat, bool ASupportsNoConfig, bool ASupportsPlatform, const System::UnicodeString ADCPSearchPath, const System::UnicodeString ALibrarySearchPath, const System::UnicodeString ALibraryDebugSearchPath, const System::UnicodeString ACppSearchPath);
	virtual System::UnicodeString __fastcall GetExeName(void);
	virtual bool __fastcall Execute(const System::UnicodeString CommandLine);
	bool __fastcall MakePackage(const System::UnicodeString PackageName, const System::UnicodeString BPLPath, const System::UnicodeString DCPPath, System::UnicodeString ExtraOptions = L"", bool ADebug = false);
	bool __fastcall MakeProject(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString DcpSearchPath, System::UnicodeString ExtraOptions = L"", bool ADebug = false);
	virtual void __fastcall SetDefaultOptions(bool ADebug);
	bool __fastcall AddBDSProjOptions(const System::UnicodeString ProjectFileName, TProjectOptions &ProjectOptions);
	bool __fastcall AddDOFOptions(const System::UnicodeString ProjectFileName, TProjectOptions &ProjectOptions);
	bool __fastcall AddDProjOptions(const System::UnicodeString ProjectFileName, TProjectOptions &ProjectOptions);
	__property System::UnicodeString CppSearchPath = {read=FCppSearchPath};
	__property System::UnicodeString DCPSearchPath = {read=FDCPSearchPath};
	__property System::UnicodeString LibrarySearchPath = {read=FLibrarySearchPath};
	__property System::UnicodeString LibraryDebugSearchPath = {read=FLibraryDebugSearchPath};
	__property bool SupportsNoConfig = {read=FSupportsNoConfig, nodefault};
	__property bool SupportsPlatform = {read=FSupportsPlatform, nodefault};
public:
	/* TJclBorlandCommandLineTool.Destroy */ inline __fastcall virtual ~TJclDCC32(void) { }
	
};


class DELPHICLASS TJclDCC64;
class PASCALIMPLEMENTATION TJclDCC64 : public TJclDCC32
{
	typedef TJclDCC32 inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetPlatform();
	virtual System::UnicodeString __fastcall GetExeName(void);
public:
	/* TJclDCC32.Create */ inline __fastcall TJclDCC64(const System::UnicodeString ABinDirectory, bool ALongPathBug, TJclCompilerSettingsFormat ACompilerSettingsFormat, bool ASupportsNoConfig, bool ASupportsPlatform, const System::UnicodeString ADCPSearchPath, const System::UnicodeString ALibrarySearchPath, const System::UnicodeString ALibraryDebugSearchPath, const System::UnicodeString ACppSearchPath) : TJclDCC32(ABinDirectory, ALongPathBug, ACompilerSettingsFormat, ASupportsNoConfig, ASupportsPlatform, ADCPSearchPath, ALibrarySearchPath, ALibraryDebugSearchPath, ACppSearchPath) { }
	
public:
	/* TJclBorlandCommandLineTool.Destroy */ inline __fastcall virtual ~TJclDCC64(void) { }
	
};


class DELPHICLASS TJclDCCIL;
class PASCALIMPLEMENTATION TJclDCCIL : public TJclDCC32
{
	typedef TJclDCC32 inherited;
	
private:
	System::UnicodeString FMaxCLRVersion;
	
protected:
	System::UnicodeString __fastcall GetMaxCLRVersion(void);
	
public:
	virtual System::UnicodeString __fastcall GetExeName(void);
	HIDESBASE bool __fastcall MakeProject(const System::UnicodeString ProjectName, const System::UnicodeString OutputDir, const System::UnicodeString ExtraOptions, bool ADebug = false);
	virtual void __fastcall SetDefaultOptions(bool ADebug);
	__property System::UnicodeString MaxCLRVersion = {read=GetMaxCLRVersion};
public:
	/* TJclDCC32.Create */ inline __fastcall TJclDCCIL(const System::UnicodeString ABinDirectory, bool ALongPathBug, TJclCompilerSettingsFormat ACompilerSettingsFormat, bool ASupportsNoConfig, bool ASupportsPlatform, const System::UnicodeString ADCPSearchPath, const System::UnicodeString ALibrarySearchPath, const System::UnicodeString ALibraryDebugSearchPath, const System::UnicodeString ACppSearchPath) : TJclDCC32(ABinDirectory, ALongPathBug, ACompilerSettingsFormat, ASupportsNoConfig, ASupportsPlatform, ADCPSearchPath, ALibrarySearchPath, ALibraryDebugSearchPath, ACppSearchPath) { }
	
public:
	/* TJclBorlandCommandLineTool.Destroy */ inline __fastcall virtual ~TJclDCCIL(void) { }
	
};


class DELPHICLASS TJclBpr2Mak;
class PASCALIMPLEMENTATION TJclBpr2Mak : public TJclBorlandCommandLineTool
{
	typedef TJclBorlandCommandLineTool inherited;
	
public:
	virtual System::UnicodeString __fastcall GetExeName(void);
public:
	/* TJclBorlandCommandLineTool.Create */ inline __fastcall TJclBpr2Mak(const System::UnicodeString ABinDirectory, bool ALongPathBug, TJclCompilerSettingsFormat ACompilerSettingsFormat) : TJclBorlandCommandLineTool(ABinDirectory, ALongPathBug, ACompilerSettingsFormat) { }
	/* TJclBorlandCommandLineTool.Destroy */ inline __fastcall virtual ~TJclBpr2Mak(void) { }
	
};


class DELPHICLASS TJclBorlandMake;
class PASCALIMPLEMENTATION TJclBorlandMake : public TJclBorlandCommandLineTool
{
	typedef TJclBorlandCommandLineTool inherited;
	
public:
	virtual System::UnicodeString __fastcall GetExeName(void);
public:
	/* TJclBorlandCommandLineTool.Create */ inline __fastcall TJclBorlandMake(const System::UnicodeString ABinDirectory, bool ALongPathBug, TJclCompilerSettingsFormat ACompilerSettingsFormat) : TJclBorlandCommandLineTool(ABinDirectory, ALongPathBug, ACompilerSettingsFormat) { }
	/* TJclBorlandCommandLineTool.Destroy */ inline __fastcall virtual ~TJclBorlandMake(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
#define AsmExeName L"tasm32.exe"
#define BCC32ExeName L"bcc32.exe"
#define DCC32ExeName L"dcc32.exe"
#define DCC64ExeName L"dcc64.exe"
#define DCCILExeName L"dccil.exe"
#define Bpr2MakExeName L"bpr2mak.exe"
#define MakeExeName L"make.exe"
#define BinaryExtensionPackage L".bpl"
#define BinaryExtensionLibrary L".dll"
#define BinaryExtensionExecutable L".exe"
#define SourceExtensionDelphiPackage L".dpk"
#define SourceExtensionBCBPackage L".bpk"
#define SourceExtensionDelphiProject L".dpr"
#define SourceExtensionBCBProject L".bpr"
#define SourceExtensionDProject L".dproj"
#define SourceExtensionBDSProject L".bdsproj"
#define SourceExtensionDOFProject L".dof"
#define SourceExtensionConfiguration L".cfg"
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall GetDPRFileInfo(const System::UnicodeString DPRFileName, /* out */ System::UnicodeString &BinaryExtension, const System::PUnicodeString LibSuffix = (void *)(0x0));
extern PACKAGE void __fastcall GetBPRFileInfo(const System::UnicodeString BPRFileName, /* out */ System::UnicodeString &BinaryFileName, const System::PUnicodeString Description = (void *)(0x0));
extern PACKAGE void __fastcall GetDPKFileInfo(const System::UnicodeString DPKFileName, /* out */ bool &RunOnly, const System::PUnicodeString LibSuffix = (void *)(0x0), const System::PUnicodeString Description = (void *)(0x0));
extern PACKAGE void __fastcall GetBPKFileInfo(const System::UnicodeString BPKFileName, /* out */ bool &RunOnly, const System::PUnicodeString BinaryFileName = (void *)(0x0), const System::PUnicodeString Description = (void *)(0x0));
extern PACKAGE System::UnicodeString __fastcall BinaryFileName(const System::UnicodeString OutputPath, const System::UnicodeString ProjectFileName);
extern PACKAGE bool __fastcall IsDelphiPackage(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall IsDelphiProject(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall IsBCBPackage(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall IsBCBProject(const System::UnicodeString FileName);

}	/* namespace Jclcompilerutils */
using namespace Jclcompilerutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclcompilerutilsHPP
