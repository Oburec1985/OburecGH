// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclfileutils.pas' rev: 21.00

#ifndef JclfileutilsHPP
#define JclfileutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Jclwin32.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclfileutils
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TCompactPath { cpCenter, cpEnd };
#pragma option pop

typedef bool __fastcall (*TDelTreeProgress)(const System::UnicodeString FileName, unsigned Attr);

#pragma option push -b-
enum TFileListOption { flFullNames, flRecursive, flMaskedSubfolders };
#pragma option pop

typedef Set<TFileListOption, flFullNames, flMaskedSubfolders>  TFileListOptions;

#pragma option push -b-
enum TJclAttributeMatch { amAny, amExact, amSubSetOf, amSuperSetOf, amCustom };
#pragma option pop

typedef bool __fastcall (*TFileMatchFunc)(const int Attr, const Sysutils::TSearchRec &FileInfo);

typedef void __fastcall (__closure *TFileHandler)(const System::UnicodeString FileName);

typedef void __fastcall (__closure *TFileHandlerEx)(const System::UnicodeString Directory, const Sysutils::TSearchRec &FileInfo);

typedef void __fastcall (__closure *TFileInfoHandlerEx)(const Sysutils::TSearchRec &FileInfo);

#pragma option push -b-
enum TAttributeInterest { aiIgnored, aiRejected, aiRequired };
#pragma option pop

class DELPHICLASS TJclCustomFileAttrMask;
class PASCALIMPLEMENTATION TJclCustomFileAttrMask : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
public:
	TAttributeInterest operator[](int Index) { return Attribute[Index]; }
	
private:
	int FRequiredAttr;
	int FRejectedAttr;
	TAttributeInterest __fastcall GetAttr(int Index);
	void __fastcall SetAttr(int Index, const TAttributeInterest Value);
	void __fastcall ReadRequiredAttributes(Classes::TReader* Reader);
	void __fastcall ReadRejectedAttributes(Classes::TReader* Reader);
	void __fastcall WriteRequiredAttributes(Classes::TWriter* Writer);
	void __fastcall WriteRejectedAttributes(Classes::TWriter* Writer);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	__property TAttributeInterest ReadOnly = {read=GetAttr, write=SetAttr, stored=false, index=1, nodefault};
	__property TAttributeInterest Hidden = {read=GetAttr, write=SetAttr, stored=false, index=2, nodefault};
	__property TAttributeInterest System = {read=GetAttr, write=SetAttr, stored=false, index=4, nodefault};
	__property TAttributeInterest Directory = {read=GetAttr, write=SetAttr, stored=false, index=16, nodefault};
	__property TAttributeInterest SymLink = {read=GetAttr, write=SetAttr, stored=false, index=64, nodefault};
	__property TAttributeInterest Normal = {read=GetAttr, write=SetAttr, stored=false, index=128, nodefault};
	__property TAttributeInterest Archive = {read=GetAttr, write=SetAttr, stored=false, index=32, nodefault};
	__property TAttributeInterest Temporary = {read=GetAttr, write=SetAttr, stored=false, index=256, nodefault};
	__property TAttributeInterest SparseFile = {read=GetAttr, write=SetAttr, stored=false, index=512, nodefault};
	__property TAttributeInterest ReparsePoint = {read=GetAttr, write=SetAttr, stored=false, index=1024, nodefault};
	__property TAttributeInterest Compressed = {read=GetAttr, write=SetAttr, stored=false, index=2048, nodefault};
	__property TAttributeInterest OffLine = {read=GetAttr, write=SetAttr, stored=false, index=4096, nodefault};
	__property TAttributeInterest NotContentIndexed = {read=GetAttr, write=SetAttr, stored=false, index=8192, nodefault};
	__property TAttributeInterest Encrypted = {read=GetAttr, write=SetAttr, stored=false, index=16384, nodefault};
	
public:
	__fastcall TJclCustomFileAttrMask(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall Clear(void);
	bool __fastcall Match(int FileAttributes)/* overload */;
	bool __fastcall Match(const Sysutils::TSearchRec &FileInfo)/* overload */;
	__property int Required = {read=FRequiredAttr, write=FRequiredAttr, nodefault};
	__property int Rejected = {read=FRejectedAttr, write=FRejectedAttr, nodefault};
	__property TAttributeInterest Attribute[int Index] = {read=GetAttr, write=SetAttr/*, default*/};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TJclCustomFileAttrMask(void) { }
	
};


class DELPHICLASS TJclFileAttributeMask;
class PASCALIMPLEMENTATION TJclFileAttributeMask : public TJclCustomFileAttrMask
{
	typedef TJclCustomFileAttrMask inherited;
	
private:
	void __fastcall ReadVolumeID(Classes::TReader* Reader);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	
__published:
	__property ReadOnly;
	__property Hidden;
	__property System;
	__property Directory;
	__property Normal;
	__property Archive;
	__property Temporary;
	__property SparseFile;
	__property ReparsePoint;
	__property Compressed;
	__property OffLine;
	__property NotContentIndexed;
	__property Encrypted;
public:
	/* TJclCustomFileAttrMask.Create */ inline __fastcall TJclFileAttributeMask(void) : TJclCustomFileAttrMask() { }
	
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TJclFileAttributeMask(void) { }
	
};


#pragma option push -b-
enum TFileSearchOption { fsIncludeSubDirectories, fsIncludeHiddenSubDirectories, fsLastChangeAfter, fsLastChangeBefore, fsMaxSize, fsMinSize };
#pragma option pop

typedef Set<TFileSearchOption, fsIncludeSubDirectories, fsMinSize>  TFileSearchOptions;

typedef int TFileSearchTaskID;

typedef void __fastcall (__closure *TFileSearchTerminationEvent)(const int ID, const bool Aborted);

#pragma option push -b-
enum TFileEnumeratorSyncMode { smPerFile, smPerDirectory };
#pragma option pop

__interface IJclFileSearchOptions;
typedef System::DelphiInterface<IJclFileSearchOptions> _di_IJclFileSearchOptions;
__interface  INTERFACE_UUID("{B73D9E3D-34C5-4DA9-88EF-4CA730328FC9}") IJclFileSearchOptions  : public System::IInterface 
{
	
public:
	virtual TJclFileAttributeMask* __fastcall GetAttributeMask(void) = 0 ;
	virtual bool __fastcall GetCaseSensitiveSearch(void) = 0 ;
	virtual Classes::TStrings* __fastcall GetRootDirectories(void) = 0 ;
	virtual System::UnicodeString __fastcall GetRootDirectory(void) = 0 ;
	virtual System::UnicodeString __fastcall GetFileMask(void) = 0 ;
	virtual Classes::TStrings* __fastcall GetFileMasks(void) = 0 ;
	virtual __int64 __fastcall GetFileSizeMax(void) = 0 ;
	virtual __int64 __fastcall GetFileSizeMin(void) = 0 ;
	virtual bool __fastcall GetIncludeSubDirectories(void) = 0 ;
	virtual bool __fastcall GetIncludeHiddenSubDirectories(void) = 0 ;
	virtual System::TDateTime __fastcall GetLastChangeAfter(void) = 0 ;
	virtual System::TDateTime __fastcall GetLastChangeBefore(void) = 0 ;
	virtual System::UnicodeString __fastcall GetLastChangeAfterStr(void) = 0 ;
	virtual System::UnicodeString __fastcall GetLastChangeBeforeStr(void) = 0 ;
	virtual System::UnicodeString __fastcall GetSubDirectoryMask(void) = 0 ;
	virtual bool __fastcall GetOption(const TFileSearchOption Option) = 0 ;
	virtual TFileSearchOptions __fastcall GetOptions(void) = 0 ;
	virtual void __fastcall SetAttributeMask(const TJclFileAttributeMask* Value) = 0 ;
	virtual void __fastcall SetCaseSensitiveSearch(const bool Value) = 0 ;
	virtual void __fastcall SetRootDirectories(const Classes::TStrings* Value) = 0 ;
	virtual void __fastcall SetRootDirectory(const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetFileMask(const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetFileMasks(const Classes::TStrings* Value) = 0 ;
	virtual void __fastcall SetFileSizeMax(const __int64 Value) = 0 ;
	virtual void __fastcall SetFileSizeMin(const __int64 Value) = 0 ;
	virtual void __fastcall SetIncludeSubDirectories(const bool Value) = 0 ;
	virtual void __fastcall SetIncludeHiddenSubDirectories(const bool Value) = 0 ;
	virtual void __fastcall SetLastChangeAfter(const System::TDateTime Value) = 0 ;
	virtual void __fastcall SetLastChangeBefore(const System::TDateTime Value) = 0 ;
	virtual void __fastcall SetLastChangeAfterStr(const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetLastChangeBeforeStr(const System::UnicodeString Value) = 0 ;
	virtual void __fastcall SetOption(const TFileSearchOption Option, const bool Value) = 0 ;
	virtual void __fastcall SetOptions(const TFileSearchOptions Value) = 0 ;
	virtual void __fastcall SetSubDirectoryMask(const System::UnicodeString Value) = 0 ;
	__property bool CaseSensitiveSearch = {read=GetCaseSensitiveSearch, write=SetCaseSensitiveSearch};
	__property Classes::TStrings* RootDirectories = {read=GetRootDirectories, write=SetRootDirectories};
	__property System::UnicodeString RootDirectory = {read=GetRootDirectory, write=SetRootDirectory};
	__property System::UnicodeString FileMask = {read=GetFileMask, write=SetFileMask};
	__property System::UnicodeString SubDirectoryMask = {read=GetSubDirectoryMask, write=SetSubDirectoryMask};
	__property TJclFileAttributeMask* AttributeMask = {read=GetAttributeMask, write=SetAttributeMask};
	__property __int64 FileSizeMin = {read=GetFileSizeMin, write=SetFileSizeMin};
	__property __int64 FileSizeMax = {read=GetFileSizeMax, write=SetFileSizeMax};
	__property System::TDateTime LastChangeAfter = {read=GetLastChangeAfter, write=SetLastChangeAfter};
	__property System::TDateTime LastChangeBefore = {read=GetLastChangeBefore, write=SetLastChangeBefore};
	__property System::UnicodeString LastChangeAfterAsString = {read=GetLastChangeAfterStr, write=SetLastChangeAfterStr};
	__property System::UnicodeString LastChangeBeforeAsString = {read=GetLastChangeBeforeStr, write=SetLastChangeBeforeStr};
	__property bool IncludeSubDirectories = {read=GetIncludeSubDirectories, write=SetIncludeSubDirectories};
	__property bool IncludeHiddenSubDirectories = {read=GetIncludeHiddenSubDirectories, write=SetIncludeHiddenSubDirectories};
};

class DELPHICLASS TJclFileSearchOptions;
class PASCALIMPLEMENTATION TJclFileSearchOptions : public Jclsysutils::TJclInterfacedPersistent
{
	typedef Jclsysutils::TJclInterfacedPersistent inherited;
	
protected:
	Classes::TStringList* FFileMasks;
	Classes::TStringList* FRootDirectories;
	System::UnicodeString FSubDirectoryMask;
	TJclFileAttributeMask* FAttributeMask;
	__int64 FFileSizeMin;
	__int64 FFileSizeMax;
	System::TDateTime FLastChangeBefore;
	System::TDateTime FLastChangeAfter;
	TFileSearchOptions FOptions;
	bool FCaseSensitiveSearch;
	bool __fastcall IsLastChangeAfterStored(void);
	bool __fastcall IsLastChangeBeforeStored(void);
	
public:
	__fastcall TJclFileSearchOptions(void);
	__fastcall virtual ~TJclFileSearchOptions(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	TJclFileAttributeMask* __fastcall GetAttributeMask(void);
	bool __fastcall GetCaseSensitiveSearch(void);
	Classes::TStrings* __fastcall GetRootDirectories(void);
	System::UnicodeString __fastcall GetRootDirectory(void);
	System::UnicodeString __fastcall GetFileMask(void);
	Classes::TStrings* __fastcall GetFileMasks(void);
	__int64 __fastcall GetFileSizeMax(void);
	__int64 __fastcall GetFileSizeMin(void);
	bool __fastcall GetIncludeSubDirectories(void);
	bool __fastcall GetIncludeHiddenSubDirectories(void);
	System::TDateTime __fastcall GetLastChangeAfter(void);
	System::TDateTime __fastcall GetLastChangeBefore(void);
	System::UnicodeString __fastcall GetLastChangeAfterStr(void);
	System::UnicodeString __fastcall GetLastChangeBeforeStr(void);
	System::UnicodeString __fastcall GetSubDirectoryMask(void);
	bool __fastcall GetOption(const TFileSearchOption Option);
	TFileSearchOptions __fastcall GetOptions(void);
	void __fastcall SetAttributeMask(const TJclFileAttributeMask* Value);
	void __fastcall SetCaseSensitiveSearch(const bool Value);
	void __fastcall SetRootDirectories(const Classes::TStrings* Value);
	void __fastcall SetRootDirectory(const System::UnicodeString Value);
	void __fastcall SetFileMask(const System::UnicodeString Value);
	void __fastcall SetFileMasks(const Classes::TStrings* Value);
	void __fastcall SetFileSizeMax(const __int64 Value);
	void __fastcall SetFileSizeMin(const __int64 Value);
	void __fastcall SetIncludeSubDirectories(const bool Value);
	void __fastcall SetIncludeHiddenSubDirectories(const bool Value);
	void __fastcall SetLastChangeAfter(const System::TDateTime Value);
	void __fastcall SetLastChangeBefore(const System::TDateTime Value);
	void __fastcall SetLastChangeAfterStr(const System::UnicodeString Value);
	void __fastcall SetLastChangeBeforeStr(const System::UnicodeString Value);
	void __fastcall SetOption(const TFileSearchOption Option, const bool Value);
	void __fastcall SetOptions(const TFileSearchOptions Value);
	void __fastcall SetSubDirectoryMask(const System::UnicodeString Value);
	
__published:
	__property bool CaseSensitiveSearch = {read=GetCaseSensitiveSearch, write=SetCaseSensitiveSearch, default=0};
	__property Classes::TStrings* FileMasks = {read=GetFileMasks, write=SetFileMasks};
	__property Classes::TStrings* RootDirectories = {read=GetRootDirectories, write=SetRootDirectories};
	__property System::UnicodeString RootDirectory = {read=GetRootDirectory, write=SetRootDirectory};
	__property System::UnicodeString SubDirectoryMask = {read=FSubDirectoryMask, write=FSubDirectoryMask};
	__property TJclFileAttributeMask* AttributeMask = {read=FAttributeMask, write=SetAttributeMask};
	__property __int64 FileSizeMin = {read=FFileSizeMin, write=FFileSizeMin};
	__property __int64 FileSizeMax = {read=FFileSizeMax, write=FFileSizeMax};
	__property System::TDateTime LastChangeAfter = {read=FLastChangeAfter, write=FLastChangeAfter, stored=IsLastChangeAfterStored};
	__property System::TDateTime LastChangeBefore = {read=FLastChangeBefore, write=FLastChangeBefore, stored=IsLastChangeBeforeStored};
	__property TFileSearchOptions Options = {read=FOptions, write=FOptions, default=1};
private:
	void *__IJclFileSearchOptions;	/* IJclFileSearchOptions */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclFileSearchOptions()
	{
		_di_IJclFileSearchOptions intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclFileSearchOptions*(void) { return (IJclFileSearchOptions*)&__IJclFileSearchOptions; }
	#endif
	
};


__interface IJclFileEnumerator;
typedef System::DelphiInterface<IJclFileEnumerator> _di_IJclFileEnumerator;
__interface  INTERFACE_UUID("{F7E747ED-1C41-441F-B25B-BB314E00C4E9}") IJclFileEnumerator  : public IJclFileSearchOptions 
{
	
public:
	virtual int __fastcall GetRunningTasks(void) = 0 ;
	virtual TFileEnumeratorSyncMode __fastcall GetSynchronizationMode(void) = 0 ;
	virtual TFileHandler __fastcall GetOnEnterDirectory(void) = 0 ;
	virtual TFileSearchTerminationEvent __fastcall GetOnTerminateTask(void) = 0 ;
	virtual void __fastcall SetSynchronizationMode(const TFileEnumeratorSyncMode Value) = 0 ;
	virtual void __fastcall SetOnEnterDirectory(const TFileHandler Value) = 0 ;
	virtual void __fastcall SetOnTerminateTask(const TFileSearchTerminationEvent Value) = 0 ;
	virtual int __fastcall FillList(Classes::TStrings* List) = 0 ;
	virtual int __fastcall ForEach(TFileHandler Handler) = 0 /* overload */;
	virtual int __fastcall ForEach(TFileHandlerEx Handler) = 0 /* overload */;
	virtual void __fastcall StopTask(int ID) = 0 ;
	virtual void __fastcall StopAllTasks(bool Silently = false) = 0 ;
	__property int RunningTasks = {read=GetRunningTasks};
	__property TFileEnumeratorSyncMode SynchronizationMode = {read=GetSynchronizationMode, write=SetSynchronizationMode};
	__property TFileHandler OnEnterDirectory = {read=GetOnEnterDirectory, write=SetOnEnterDirectory};
	__property TFileSearchTerminationEvent OnTerminateTask = {read=GetOnTerminateTask, write=SetOnTerminateTask};
};

class DELPHICLASS TJclFileEnumerator;
class PASCALIMPLEMENTATION TJclFileEnumerator : public TJclFileSearchOptions
{
	typedef TJclFileSearchOptions inherited;
	
private:
	Classes::TList* FTasks;
	TFileHandler FOnEnterDirectory;
	TFileSearchTerminationEvent FOnTerminateTask;
	int FNextTaskID;
	TFileEnumeratorSyncMode FSynchronizationMode;
	int __fastcall GetNextTaskID(void);
	
protected:
	Classes::TThread* __fastcall CreateTask(void);
	void __fastcall TaskTerminated(System::TObject* Sender);
	__property int NextTaskID = {read=GetNextTaskID, nodefault};
	
public:
	__fastcall TJclFileEnumerator(void);
	__fastcall virtual ~TJclFileEnumerator(void);
	int __fastcall GetRunningTasks(void);
	TFileEnumeratorSyncMode __fastcall GetSynchronizationMode(void);
	TFileHandler __fastcall GetOnEnterDirectory(void);
	TFileSearchTerminationEvent __fastcall GetOnTerminateTask(void);
	void __fastcall SetSynchronizationMode(const TFileEnumeratorSyncMode Value);
	void __fastcall SetOnEnterDirectory(const TFileHandler Value);
	void __fastcall SetOnTerminateTask(const TFileSearchTerminationEvent Value);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	int __fastcall FillList(Classes::TStrings* List);
	int __fastcall ForEach(TFileHandler Handler)/* overload */;
	int __fastcall ForEach(TFileHandlerEx Handler)/* overload */;
	void __fastcall StopTask(int ID);
	void __fastcall StopAllTasks(bool Silently = false);
	__property System::UnicodeString FileMask = {read=GetFileMask, write=SetFileMask};
	__property bool IncludeSubDirectories = {read=GetIncludeSubDirectories, write=SetIncludeSubDirectories, nodefault};
	__property bool IncludeHiddenSubDirectories = {read=GetIncludeHiddenSubDirectories, write=SetIncludeHiddenSubDirectories, nodefault};
	__property bool SearchOption[const TFileSearchOption Option] = {read=GetOption, write=SetOption};
	__property System::UnicodeString LastChangeAfterAsString = {read=GetLastChangeAfterStr, write=SetLastChangeAfterStr};
	__property System::UnicodeString LastChangeBeforeAsString = {read=GetLastChangeBeforeStr, write=SetLastChangeBeforeStr};
	
__published:
	__property int RunningTasks = {read=GetRunningTasks, nodefault};
	__property TFileEnumeratorSyncMode SynchronizationMode = {read=FSynchronizationMode, write=FSynchronizationMode, default=1};
	__property TFileHandler OnEnterDirectory = {read=FOnEnterDirectory, write=FOnEnterDirectory};
	__property TFileSearchTerminationEvent OnTerminateTask = {read=FOnTerminateTask, write=FOnTerminateTask};
private:
	void *__IJclFileEnumerator;	/* IJclFileEnumerator */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclFileEnumerator()
	{
		_di_IJclFileEnumerator intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclFileEnumerator*(void) { return (IJclFileEnumerator*)&__IJclFileEnumerator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclFileSearchOptions()
	{
		_di_IJclFileSearchOptions intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclFileSearchOptions*(void) { return (IJclFileSearchOptions*)&__IJclFileEnumerator; }
	#endif
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator System::_di_IInterface()
	{
		System::_di_IInterface intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IInterface*(void) { return (IInterface*)&__IJclFileEnumerator; }
	#endif
	
};


#pragma option push -b-
enum TFileFlag { ffDebug, ffInfoInferred, ffPatched, ffPreRelease, ffPrivateBuild, ffSpecialBuild };
#pragma option pop

typedef Set<TFileFlag, ffDebug, ffSpecialBuild>  TFileFlags;

struct TLangIdRec;
typedef TLangIdRec *PLangIdRec;

#pragma pack(push,1)
struct TLangIdRec
{
	
	union
	{
		struct 
		{
			unsigned Pair;
			
		};
		struct 
		{
			System::Word LangId;
			System::Word CodePage;
			
		};
		
	};
};
#pragma pack(pop)


class DELPHICLASS EJclFileVersionInfoError;
class PASCALIMPLEMENTATION EJclFileVersionInfoError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclFileVersionInfoError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclFileVersionInfoError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclFileVersionInfoError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclFileVersionInfoError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclFileVersionInfoError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclFileVersionInfoError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclFileVersionInfoError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclFileVersionInfoError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclFileVersionInfoError(void) { }
	
};


class DELPHICLASS TJclFileVersionInfo;
class PASCALIMPLEMENTATION TJclFileVersionInfo : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TLangIdRec> _TJclFileVersionInfo__1;
	
	typedef DynamicArray<TLangIdRec> _TJclFileVersionInfo__2;
	
	
private:
	System::AnsiString FBuffer;
	tagVS_FIXEDFILEINFO *FFixedInfo;
	TFileFlags FFileFlags;
	Classes::TStringList* FItemList;
	Classes::TStringList* FItems;
	_TJclFileVersionInfo__1 FLanguages;
	int FLanguageIndex;
	_TJclFileVersionInfo__2 FTranslations;
	tagVS_FIXEDFILEINFO __fastcall GetFixedInfo(void);
	Classes::TStrings* __fastcall GetItems(void);
	int __fastcall GetLanguageCount(void);
	System::UnicodeString __fastcall GetLanguageIds(int Index);
	System::UnicodeString __fastcall GetLanguageNames(int Index);
	TLangIdRec __fastcall GetLanguages(int Index);
	int __fastcall GetTranslationCount(void);
	TLangIdRec __fastcall GetTranslations(int Index);
	void __fastcall SetLanguageIndex(const int Value);
	
protected:
	void __fastcall CreateItemsForLanguage(void);
	void __fastcall CheckLanguageIndex(int Value);
	void __fastcall ExtractData(void);
	void __fastcall ExtractFlags(void);
	System::UnicodeString __fastcall GetBinFileVersion(void);
	System::UnicodeString __fastcall GetBinProductVersion(void);
	unsigned __fastcall GetFileOS(void);
	unsigned __fastcall GetFileSubType(void);
	unsigned __fastcall GetFileType(void);
	System::UnicodeString __fastcall GetFileVersionBuild(void);
	System::UnicodeString __fastcall GetFileVersionMajor(void);
	System::UnicodeString __fastcall GetFileVersionMinor(void);
	System::UnicodeString __fastcall GetFileVersionRelease(void);
	System::UnicodeString __fastcall GetProductVersionBuild(void);
	System::UnicodeString __fastcall GetProductVersionMajor(void);
	System::UnicodeString __fastcall GetProductVersionMinor(void);
	System::UnicodeString __fastcall GetProductVersionRelease(void);
	System::UnicodeString __fastcall GetVersionKeyValue(int Index);
	
public:
	__fastcall TJclFileVersionInfo(void * VersionInfoData, int Size);
	__fastcall TJclFileVersionInfo(const System::UnicodeString FileName)/* overload */;
	__fastcall TJclFileVersionInfo(const HWND Window)/* overload */;
	__fastcall TJclFileVersionInfo(const unsigned Module)/* overload */;
	__fastcall virtual ~TJclFileVersionInfo(void);
	System::UnicodeString __fastcall GetCustomFieldValue(const System::UnicodeString FieldName);
	__classmethod System::UnicodeString __fastcall VersionLanguageId(const TLangIdRec LangIdRec);
	__classmethod System::UnicodeString __fastcall VersionLanguageName(const System::Word LangId);
	__classmethod bool __fastcall FileHasVersionInfo(const System::UnicodeString FileName);
	bool __fastcall TranslationMatchesLanguages(bool Exact = true);
	__property System::UnicodeString BinFileVersion = {read=GetBinFileVersion};
	__property System::UnicodeString BinProductVersion = {read=GetBinProductVersion};
	__property System::UnicodeString Comments = {read=GetVersionKeyValue, index=1};
	__property System::UnicodeString CompanyName = {read=GetVersionKeyValue, index=2};
	__property System::UnicodeString FileDescription = {read=GetVersionKeyValue, index=3};
	__property tagVS_FIXEDFILEINFO FixedInfo = {read=GetFixedInfo};
	__property TFileFlags FileFlags = {read=FFileFlags, nodefault};
	__property unsigned FileOS = {read=GetFileOS, nodefault};
	__property unsigned FileSubType = {read=GetFileSubType, nodefault};
	__property unsigned FileType = {read=GetFileType, nodefault};
	__property System::UnicodeString FileVersion = {read=GetVersionKeyValue, index=4};
	__property System::UnicodeString FileVersionBuild = {read=GetFileVersionBuild};
	__property System::UnicodeString FileVersionMajor = {read=GetFileVersionMajor};
	__property System::UnicodeString FileVersionMinor = {read=GetFileVersionMinor};
	__property System::UnicodeString FileVersionRelease = {read=GetFileVersionRelease};
	__property Classes::TStrings* Items = {read=GetItems};
	__property System::UnicodeString InternalName = {read=GetVersionKeyValue, index=5};
	__property int LanguageCount = {read=GetLanguageCount, nodefault};
	__property System::UnicodeString LanguageIds[int Index] = {read=GetLanguageIds};
	__property int LanguageIndex = {read=FLanguageIndex, write=SetLanguageIndex, nodefault};
	__property TLangIdRec Languages[int Index] = {read=GetLanguages};
	__property System::UnicodeString LanguageNames[int Index] = {read=GetLanguageNames};
	__property System::UnicodeString LegalCopyright = {read=GetVersionKeyValue, index=6};
	__property System::UnicodeString LegalTradeMarks = {read=GetVersionKeyValue, index=7};
	__property System::UnicodeString OriginalFilename = {read=GetVersionKeyValue, index=8};
	__property System::UnicodeString PrivateBuild = {read=GetVersionKeyValue, index=12};
	__property System::UnicodeString ProductName = {read=GetVersionKeyValue, index=9};
	__property System::UnicodeString ProductVersion = {read=GetVersionKeyValue, index=10};
	__property System::UnicodeString ProductVersionBuild = {read=GetProductVersionBuild};
	__property System::UnicodeString ProductVersionMajor = {read=GetProductVersionMajor};
	__property System::UnicodeString ProductVersionMinor = {read=GetProductVersionMinor};
	__property System::UnicodeString ProductVersionRelease = {read=GetProductVersionRelease};
	__property System::UnicodeString SpecialBuild = {read=GetVersionKeyValue, index=11};
	__property int TranslationCount = {read=GetTranslationCount, nodefault};
	__property TLangIdRec Translations[int Index] = {read=GetTranslations};
};


#pragma option push -b-
enum TFileVersionFormat { vfMajorMinor, vfFull };
#pragma option pop

class DELPHICLASS TJclTempFileStream;
class PASCALIMPLEMENTATION TJclTempFileStream : public Classes::THandleStream
{
	typedef Classes::THandleStream inherited;
	
private:
	System::UnicodeString FFileName;
	
public:
	__fastcall TJclTempFileStream(const System::UnicodeString Prefix);
	__fastcall virtual ~TJclTempFileStream(void);
	__property System::UnicodeString FileName = {read=FFileName};
};


class DELPHICLASS TJclFileMappingView;
class DELPHICLASS TJclCustomFileMapping;
class PASCALIMPLEMENTATION TJclFileMappingView : public Classes::TCustomMemoryStream
{
	typedef Classes::TCustomMemoryStream inherited;
	
private:
	TJclCustomFileMapping* FFileMapping;
	unsigned FOffsetHigh;
	unsigned FOffsetLow;
	int __fastcall GetIndex(void);
	__int64 __fastcall GetOffset(void);
	
public:
	__fastcall TJclFileMappingView(const TJclCustomFileMapping* FileMap, unsigned Access, unsigned Size, __int64 ViewOffset);
	__fastcall TJclFileMappingView(TJclCustomFileMapping* FileMap, unsigned Access, unsigned Size, __int64 ViewOffset, void * Address);
	__fastcall virtual ~TJclFileMappingView(void);
	bool __fastcall Flush(const unsigned Count);
	void __fastcall LoadFromStream(const Classes::TStream* Stream);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	virtual int __fastcall Write(const void *Buffer, int Count);
	__property int Index = {read=GetIndex, nodefault};
	__property TJclCustomFileMapping* FileMapping = {read=FFileMapping};
	__property __int64 Offset = {read=GetOffset};
};


#pragma option push -b-
enum TJclFileMappingRoundOffset { rvDown, rvUp };
#pragma option pop

class PASCALIMPLEMENTATION TJclCustomFileMapping : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FExisted;
	unsigned FHandle;
	System::UnicodeString FName;
	TJclFileMappingRoundOffset FRoundViewOffset;
	Classes::TList* FViews;
	int __fastcall GetCount(void);
	TJclFileMappingView* __fastcall GetView(int Index);
	
protected:
	void __fastcall ClearViews(void);
	void __fastcall InternalCreate(const unsigned FileHandle, const System::UnicodeString Name, const unsigned Protect, __int64 MaximumSize, Windows::PSecurityAttributes SecAttr);
	void __fastcall InternalOpen(const System::UnicodeString Name, const bool InheritHandle, const unsigned DesiredAccess);
	
public:
	__fastcall TJclCustomFileMapping(void);
	__fastcall TJclCustomFileMapping(const System::UnicodeString Name, const bool InheritHandle, const unsigned DesiredAccess);
	__fastcall virtual ~TJclCustomFileMapping(void);
	int __fastcall Add(const unsigned Access, const unsigned Count, const __int64 Offset);
	int __fastcall AddAt(const unsigned Access, const unsigned Count, const __int64 Offset, const void * Address);
	void __fastcall Delete(const int Index);
	int __fastcall IndexOf(const TJclFileMappingView* View);
	__property int Count = {read=GetCount, nodefault};
	__property bool Existed = {read=FExisted, nodefault};
	__property unsigned Handle = {read=FHandle, nodefault};
	__property System::UnicodeString Name = {read=FName};
	__property TJclFileMappingRoundOffset RoundViewOffset = {read=FRoundViewOffset, write=FRoundViewOffset, nodefault};
	__property TJclFileMappingView* Views[int index] = {read=GetView};
};


class DELPHICLASS TJclFileMapping;
class PASCALIMPLEMENTATION TJclFileMapping : public TJclCustomFileMapping
{
	typedef TJclCustomFileMapping inherited;
	
private:
	unsigned FFileHandle;
	
public:
	__fastcall TJclFileMapping(const System::UnicodeString FileName, unsigned FileMode, const System::UnicodeString Name, unsigned Protect, const __int64 MaximumSize, Windows::PSecurityAttributes SecAttr)/* overload */;
	__fastcall TJclFileMapping(const unsigned FileHandle, const System::UnicodeString Name, unsigned Protect, const __int64 MaximumSize, Windows::PSecurityAttributes SecAttr)/* overload */;
	__fastcall virtual ~TJclFileMapping(void);
	__property unsigned FileHandle = {read=FFileHandle, nodefault};
public:
	/* TJclCustomFileMapping.Open */ inline __fastcall TJclFileMapping(const System::UnicodeString Name, const bool InheritHandle, const unsigned DesiredAccess) : TJclCustomFileMapping(Name, InheritHandle, DesiredAccess) { }
	
};


class DELPHICLASS TJclSwapFileMapping;
class PASCALIMPLEMENTATION TJclSwapFileMapping : public TJclCustomFileMapping
{
	typedef TJclCustomFileMapping inherited;
	
public:
	__fastcall TJclSwapFileMapping(const System::UnicodeString Name, unsigned Protect, const __int64 MaximumSize, Windows::PSecurityAttributes SecAttr);
public:
	/* TJclCustomFileMapping.Open */ inline __fastcall TJclSwapFileMapping(const System::UnicodeString Name, const bool InheritHandle, const unsigned DesiredAccess) : TJclCustomFileMapping(Name, InheritHandle, DesiredAccess) { }
	/* TJclCustomFileMapping.Destroy */ inline __fastcall virtual ~TJclSwapFileMapping(void) { }
	
};


class DELPHICLASS TJclFileMappingStream;
class PASCALIMPLEMENTATION TJclFileMappingStream : public Classes::TCustomMemoryStream
{
	typedef Classes::TCustomMemoryStream inherited;
	
private:
	unsigned FFileHandle;
	unsigned FMapping;
	
protected:
	void __fastcall Close(void);
	
public:
	__fastcall TJclFileMappingStream(const System::UnicodeString FileName, System::Word FileMode);
	__fastcall virtual ~TJclFileMappingStream(void);
	virtual int __fastcall Write(const void *Buffer, int Count);
};


#pragma option push -b-
enum TJclMappedTextReaderIndex { tiNoIndex, tiFull };
#pragma option pop

typedef StaticArray<char *, 1> TPAnsiCharArray;

typedef TPAnsiCharArray *PPAnsiCharArray;

class DELPHICLASS TJclAnsiMappedTextReader;
class PASCALIMPLEMENTATION TJclAnsiMappedTextReader : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	char *FContent;
	char *FEnd;
	TPAnsiCharArray *FIndex;
	TJclMappedTextReaderIndex FIndexOption;
	bool FFreeStream;
	int FLastLineNumber;
	char *FLastPosition;
	int FLineCount;
	Classes::TCustomMemoryStream* FMemoryStream;
	char *FPosition;
	int FSize;
	System::AnsiString __fastcall GetAsString(void);
	bool __fastcall GetEof(void);
	char __fastcall GetChars(int Index);
	int __fastcall GetLineCount(void);
	System::AnsiString __fastcall GetLines(int LineNumber);
	int __fastcall GetPosition(void);
	int __fastcall GetPositionFromLine(int LineNumber);
	void __fastcall SetPosition(const int Value);
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	void __fastcall CreateIndex(void);
	void __fastcall Init(void);
	char * __fastcall PtrFromLine(int LineNumber);
	System::AnsiString __fastcall StringFromPosition(char * &StartPos);
	
public:
	__fastcall TJclAnsiMappedTextReader(Classes::TCustomMemoryStream* MemoryStream, bool FreeStream, const TJclMappedTextReaderIndex AIndexOption)/* overload */;
	__fastcall TJclAnsiMappedTextReader(const Sysutils::TFileName FileName, const TJclMappedTextReaderIndex AIndexOption)/* overload */;
	__fastcall virtual ~TJclAnsiMappedTextReader(void);
	void __fastcall GoBegin(void);
	char __fastcall Read(void);
	System::AnsiString __fastcall ReadLn(void);
	__property System::AnsiString AsString = {read=GetAsString};
	__property char Chars[int Index] = {read=GetChars};
	__property char * Content = {read=FContent};
	__property bool Eof = {read=GetEof, nodefault};
	__property TJclMappedTextReaderIndex IndexOption = {read=FIndexOption, nodefault};
	__property System::AnsiString Lines[int LineNumber] = {read=GetLines};
	__property int LineCount = {read=GetLineCount, nodefault};
	__property int PositionFromLine[int LineNumber] = {read=GetPositionFromLine};
	__property int Position = {read=GetPosition, write=SetPosition, nodefault};
	__property int Size = {read=FSize, nodefault};
};


typedef StaticArray<System::WideChar *, 1> TPWideCharArray;

typedef TPWideCharArray *PPWideCharArray;

class DELPHICLASS TJclWideMappedTextReader;
class PASCALIMPLEMENTATION TJclWideMappedTextReader : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::WideChar *FContent;
	System::WideChar *FEnd;
	TPWideCharArray *FIndex;
	TJclMappedTextReaderIndex FIndexOption;
	bool FFreeStream;
	int FLastLineNumber;
	System::WideChar *FLastPosition;
	int FLineCount;
	Classes::TCustomMemoryStream* FMemoryStream;
	System::WideChar *FPosition;
	int FSize;
	System::WideString __fastcall GetAsString(void);
	bool __fastcall GetEof(void);
	System::WideChar __fastcall GetChars(int Index);
	int __fastcall GetLineCount(void);
	System::WideString __fastcall GetLines(int LineNumber);
	int __fastcall GetPosition(void);
	int __fastcall GetPositionFromLine(int LineNumber);
	void __fastcall SetPosition(const int Value);
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	void __fastcall CreateIndex(void);
	void __fastcall Init(void);
	System::WideChar * __fastcall PtrFromLine(int LineNumber);
	System::WideString __fastcall StringFromPosition(System::WideChar * &StartPos);
	
public:
	__fastcall TJclWideMappedTextReader(Classes::TCustomMemoryStream* MemoryStream, bool FreeStream, const TJclMappedTextReaderIndex AIndexOption)/* overload */;
	__fastcall TJclWideMappedTextReader(const Sysutils::TFileName FileName, const TJclMappedTextReaderIndex AIndexOption)/* overload */;
	__fastcall virtual ~TJclWideMappedTextReader(void);
	void __fastcall GoBegin(void);
	System::WideChar __fastcall Read(void);
	System::WideString __fastcall ReadLn(void);
	__property System::WideString AsString = {read=GetAsString};
	__property System::WideChar Chars[int Index] = {read=GetChars};
	__property System::WideChar * Content = {read=FContent};
	__property bool Eof = {read=GetEof, nodefault};
	__property TJclMappedTextReaderIndex IndexOption = {read=FIndexOption, nodefault};
	__property System::WideString Lines[int LineNumber] = {read=GetLines};
	__property int LineCount = {read=GetLineCount, nodefault};
	__property int PositionFromLine[int LineNumber] = {read=GetPositionFromLine};
	__property int Position = {read=GetPosition, write=SetPosition, nodefault};
	__property int Size = {read=FSize, nodefault};
};


class DELPHICLASS TJclFileMaskComparator;
class PASCALIMPLEMENTATION TJclFileMaskComparator : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<System::UnicodeString> _TJclFileMaskComparator__1;
	
	typedef DynamicArray<System::UnicodeString> _TJclFileMaskComparator__2;
	
	typedef DynamicArray<System::Byte> _TJclFileMaskComparator__3;
	
	
private:
	System::UnicodeString FFileMask;
	_TJclFileMaskComparator__1 FExts;
	_TJclFileMaskComparator__2 FNames;
	_TJclFileMaskComparator__3 FWildChars;
	System::WideChar FSeparator;
	void __fastcall CreateMultiMasks(void);
	int __fastcall GetCount(void);
	System::UnicodeString __fastcall GetExts(int Index);
	System::UnicodeString __fastcall GetMasks(int Index);
	System::UnicodeString __fastcall GetNames(int Index);
	void __fastcall SetFileMask(const System::UnicodeString Value);
	void __fastcall SetSeparator(const System::WideChar Value);
	
public:
	__fastcall TJclFileMaskComparator(void);
	bool __fastcall Compare(const System::UnicodeString NameExt);
	__property int Count = {read=GetCount, nodefault};
	__property System::UnicodeString Exts[int Index] = {read=GetExts};
	__property System::UnicodeString FileMask = {read=FFileMask, write=SetFileMask};
	__property System::UnicodeString Masks[int Index] = {read=GetMasks};
	__property System::UnicodeString Names[int Index] = {read=GetNames};
	__property System::WideChar Separator = {read=FSeparator, write=SetSeparator, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFileMaskComparator(void) { }
	
};


class DELPHICLASS EJclPathError;
class PASCALIMPLEMENTATION EJclPathError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclPathError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclPathError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclPathError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclPathError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclPathError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclPathError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclPathError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclPathError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclPathError(void) { }
	
};


class DELPHICLASS EJclFileUtilsError;
class PASCALIMPLEMENTATION EJclFileUtilsError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclFileUtilsError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclFileUtilsError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclFileUtilsError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclFileUtilsError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclFileUtilsError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclFileUtilsError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclFileUtilsError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclFileUtilsError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclFileUtilsError(void) { }
	
};


class DELPHICLASS EJclTempFileStreamError;
class PASCALIMPLEMENTATION EJclTempFileStreamError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclTempFileStreamError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclTempFileStreamError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclTempFileStreamError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclTempFileStreamError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclTempFileStreamError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclTempFileStreamError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclTempFileStreamError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclTempFileStreamError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclTempFileStreamError(void) { }
	
};


class DELPHICLASS EJclFileMappingError;
class PASCALIMPLEMENTATION EJclFileMappingError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclFileMappingError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclFileMappingError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclFileMappingError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclFileMappingError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclFileMappingError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclFileMappingError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclFileMappingError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclFileMappingError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclFileMappingError(void) { }
	
};


class DELPHICLASS EJclFileMappingViewError;
class PASCALIMPLEMENTATION EJclFileMappingViewError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclFileMappingViewError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclFileMappingViewError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclFileMappingViewError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclFileMappingViewError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclFileMappingViewError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclFileMappingViewError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclFileMappingViewError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclFileMappingViewError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclFileMappingViewError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
#define PathDevicePrefix L"\\\\.\\"
static const WideChar DirDelimiter = (WideChar)(0x5c);
static const WideChar DirSeparator = (WideChar)(0x3b);
#define PathUncPrefix L"\\\\"
static const ShortInt faSymLink = 0x40;
static const Byte faNormalFile = 0x80;
static const Word faTemporary = 0x100;
static const Word faSparseFile = 0x200;
static const Word faReparsePoint = 0x400;
static const Word faCompressed = 0x800;
static const Word faOffline = 0x1000;
static const Word faNotContentIndexed = 0x2000;
static const Word faEncrypted = 0x4000;
static const ShortInt faRejectedByDefault = 0x16;
static const Word faWindowsSpecific = 0x7f20;
static const ShortInt faUnixSpecific = 0x40;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall CharIsDriveLetter(const System::WideChar C);
extern PACKAGE System::UnicodeString __fastcall PathAddSeparator(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathAddExtension(const System::UnicodeString Path, const System::UnicodeString Extension);
extern PACKAGE System::UnicodeString __fastcall PathAppend(const System::UnicodeString Path, const System::UnicodeString Append);
extern PACKAGE System::UnicodeString __fastcall PathBuildRoot(const System::Byte Drive);
extern PACKAGE System::UnicodeString __fastcall PathCanonicalize(const System::UnicodeString Path);
extern PACKAGE int __fastcall PathCommonPrefix(const System::UnicodeString Path1, const System::UnicodeString Path2);
extern PACKAGE System::UnicodeString __fastcall PathCompactPath(const HDC DC, const System::UnicodeString Path, const int Width, TCompactPath CmpFmt);
extern PACKAGE void __fastcall PathExtractElements(const System::UnicodeString Source, System::UnicodeString &Drive, System::UnicodeString &Path, System::UnicodeString &FileName, System::UnicodeString &Ext);
extern PACKAGE System::UnicodeString __fastcall PathExtractFileDirFixed(const System::UnicodeString S);
extern PACKAGE System::UnicodeString __fastcall PathExtractFileNameNoExt(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathExtractPathDepth(const System::UnicodeString Path, int Depth);
extern PACKAGE int __fastcall PathGetDepth(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathGetLongName(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathGetShortName(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathGetRelativePath(System::UnicodeString Origin, System::UnicodeString Destination);
extern PACKAGE System::UnicodeString __fastcall PathGetTempPath(void);
extern PACKAGE bool __fastcall PathIsAbsolute(const System::UnicodeString Path);
extern PACKAGE bool __fastcall PathIsChild(const System::UnicodeString Path, const System::UnicodeString Base);
extern PACKAGE bool __fastcall PathIsEqualOrChild(const System::UnicodeString Path, const System::UnicodeString Base);
extern PACKAGE bool __fastcall PathIsDiskDevice(const System::UnicodeString Path);
extern PACKAGE bool __fastcall PathIsUNC(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathRemoveSeparator(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathRemoveExtension(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall PathGetPhysicalPath(const System::UnicodeString LocalizedPath);
extern PACKAGE System::UnicodeString __fastcall PathGetLocalizedPath(const System::UnicodeString PhysicalPath);
extern PACKAGE bool __fastcall BuildFileList(const System::UnicodeString Path, const int Attr, const Classes::TStrings* List, bool IncludeDirectoryName = false);
extern PACKAGE void __fastcall CreateEmptyFile(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall CloseVolume(unsigned &Volume);
extern PACKAGE bool __fastcall DeleteDirectory(const System::UnicodeString DirectoryName, bool MoveToRecycleBin);
extern PACKAGE bool __fastcall CopyDirectory(System::UnicodeString ExistingDirectoryName, System::UnicodeString NewDirectoryName);
extern PACKAGE bool __fastcall MoveDirectory(System::UnicodeString ExistingDirectoryName, System::UnicodeString NewDirectoryName);
extern PACKAGE bool __fastcall DelTree(const System::UnicodeString Path);
extern PACKAGE bool __fastcall DelTreeEx(const System::UnicodeString Path, bool AbortOnFailure, TDelTreeProgress Progress);
extern PACKAGE bool __fastcall DirectoryExists(const System::UnicodeString Name);
extern PACKAGE bool __fastcall DiskInDrive(System::WideChar Drive);
extern PACKAGE unsigned __fastcall FileCreateTemp(System::UnicodeString &Prefix);
extern PACKAGE bool __fastcall FileBackup(const System::UnicodeString FileName, bool Move = false);
extern PACKAGE bool __fastcall FileCopy(const System::UnicodeString ExistingFileName, const System::UnicodeString NewFileName, bool ReplaceExisting = false);
extern PACKAGE bool __fastcall FileDelete(const System::UnicodeString FileName, bool MoveToRecycleBin = false);
extern PACKAGE bool __fastcall FileExists(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall FileMove(const System::UnicodeString ExistingFileName, const System::UnicodeString NewFileName, bool ReplaceExisting = false);
extern PACKAGE bool __fastcall FileRestore(const System::UnicodeString FileName);
extern PACKAGE System::UnicodeString __fastcall GetBackupFileName(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall IsBackupFileName(const System::UnicodeString FileName);
extern PACKAGE System::UnicodeString __fastcall FileGetDisplayName(const System::UnicodeString FileName);
extern PACKAGE System::UnicodeString __fastcall FileGetGroupName(const System::UnicodeString FileName);
extern PACKAGE System::UnicodeString __fastcall FileGetOwnerName(const System::UnicodeString FileName);
extern PACKAGE __int64 __fastcall FileGetSize(const System::UnicodeString FileName);
extern PACKAGE System::UnicodeString __fastcall FileGetTempName(const System::UnicodeString Prefix);
extern PACKAGE System::UnicodeString __fastcall FileGetTypeName(const System::UnicodeString FileName);
extern PACKAGE System::UnicodeString __fastcall FindUnusedFileName(System::UnicodeString FileName, const System::UnicodeString FileExt, System::UnicodeString NumberPrefix = L"");
extern PACKAGE bool __fastcall ForceDirectories(System::UnicodeString Name);
extern PACKAGE __int64 __fastcall GetDirectorySize(const System::UnicodeString Path);
extern PACKAGE System::UnicodeString __fastcall GetDriveTypeStr(const System::WideChar Drive);
extern PACKAGE bool __fastcall GetFileAgeCoherence(const System::UnicodeString FileName);
extern PACKAGE void __fastcall GetFileAttributeList(const Classes::TStrings* Items, const int Attr);
extern PACKAGE void __fastcall GetFileAttributeListEx(const Classes::TStrings* Items, const int Attr);
extern PACKAGE bool __fastcall GetFileInformation(const System::UnicodeString FileName, /* out */ Sysutils::TSearchRec &FileInfo)/* overload */;
extern PACKAGE Sysutils::TSearchRec __fastcall GetFileInformation(const System::UnicodeString FileName)/* overload */;
extern PACKAGE _FILETIME __fastcall GetFileLastWrite(const System::UnicodeString FileName)/* overload */;
extern PACKAGE bool __fastcall GetFileLastWrite(const System::UnicodeString FileName, /* out */ System::TDateTime &LocalTime)/* overload */;
extern PACKAGE _FILETIME __fastcall GetFileLastAccess(const System::UnicodeString FileName)/* overload */;
extern PACKAGE bool __fastcall GetFileLastAccess(const System::UnicodeString FileName, /* out */ System::TDateTime &LocalTime)/* overload */;
extern PACKAGE _FILETIME __fastcall GetFileCreation(const System::UnicodeString FileName)/* overload */;
extern PACKAGE bool __fastcall GetFileCreation(const System::UnicodeString FileName, /* out */ System::TDateTime &LocalTime)/* overload */;
extern PACKAGE System::UnicodeString __fastcall GetModulePath(const unsigned Module);
extern PACKAGE __int64 __fastcall GetSizeOfFile(const System::UnicodeString FileName)/* overload */;
extern PACKAGE __int64 __fastcall GetSizeOfFile(unsigned Handle)/* overload */;
extern PACKAGE __int64 __fastcall GetSizeOfFile(const Sysutils::TSearchRec &FileInfo)/* overload */;
extern PACKAGE _WIN32_FILE_ATTRIBUTE_DATA __fastcall GetStandardFileInfo(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall IsDirectory(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall IsRootDirectory(const System::UnicodeString CanonicFileName);
extern PACKAGE bool __fastcall LockVolume(const System::UnicodeString Volume, unsigned &Handle);
extern PACKAGE unsigned __fastcall OpenVolume(const System::WideChar Drive);
extern PACKAGE bool __fastcall SetFileLastAccess(const System::UnicodeString FileName, const System::TDateTime DateTime);
extern PACKAGE bool __fastcall SetFileLastWrite(const System::UnicodeString FileName, const System::TDateTime DateTime);
extern PACKAGE bool __fastcall SetFileCreation(const System::UnicodeString FileName, const System::TDateTime DateTime);
extern PACKAGE bool __fastcall SetDirLastWrite(const System::UnicodeString DirName, const System::TDateTime DateTime);
extern PACKAGE bool __fastcall SetDirLastAccess(const System::UnicodeString DirName, const System::TDateTime DateTime);
extern PACKAGE bool __fastcall SetDirCreation(const System::UnicodeString DirName, const System::TDateTime DateTime);
extern PACKAGE void __fastcall ShredFile(const System::UnicodeString FileName, int Times = 0x1);
extern PACKAGE bool __fastcall UnlockVolume(unsigned &Handle);
extern PACKAGE System::UnicodeString __fastcall OSIdentToString(const unsigned OSIdent);
extern PACKAGE System::UnicodeString __fastcall OSFileTypeToString(const unsigned OSFileType, const unsigned OSFileSubType = (unsigned)(0x0));
extern PACKAGE bool __fastcall VersionResourceAvailable(const System::UnicodeString FileName)/* overload */;
extern PACKAGE bool __fastcall VersionResourceAvailable(const HWND Window)/* overload */;
extern PACKAGE bool __fastcall VersionResourceAvailable(const unsigned Module)/* overload */;
extern PACKAGE System::UnicodeString __fastcall WindowToModuleFileName(const HWND Window);
extern PACKAGE System::UnicodeString __fastcall FormatVersionString(const System::Word HiV, const System::Word LoV)/* overload */;
extern PACKAGE System::UnicodeString __fastcall FormatVersionString(const System::Word Major, const System::Word Minor, const System::Word Build, const System::Word Revision)/* overload */;
extern PACKAGE System::UnicodeString __fastcall FormatVersionString(const tagVS_FIXEDFILEINFO &FixedInfo, TFileVersionFormat VersionFormat = (TFileVersionFormat)(0x1))/* overload */;
extern PACKAGE void __fastcall VersionExtractFileInfo(const tagVS_FIXEDFILEINFO &FixedInfo, System::Word &Major, System::Word &Minor, System::Word &Build, System::Word &Revision);
extern PACKAGE void __fastcall VersionExtractProductInfo(const tagVS_FIXEDFILEINFO &FixedInfo, System::Word &Major, System::Word &Minor, System::Word &Build, System::Word &Revision);
extern PACKAGE bool __fastcall VersionFixedFileInfo(const System::UnicodeString FileName, tagVS_FIXEDFILEINFO &FixedInfo);
extern PACKAGE System::UnicodeString __fastcall VersionFixedFileInfoString(const System::UnicodeString FileName, TFileVersionFormat VersionFormat = (TFileVersionFormat)(0x1), const System::UnicodeString NotAvailableText = L"");
extern PACKAGE bool __fastcall AdvBuildFileList(const System::UnicodeString Path, const int Attr, const Classes::TStrings* Files, const TJclAttributeMatch AttributeMatch = (TJclAttributeMatch)(0x3), const TFileListOptions Options = TFileListOptions() , const System::UnicodeString SubfoldersMask = L"", const TFileMatchFunc FileMatchFunc = 0x0);
extern PACKAGE bool __fastcall VerifyFileAttributeMask(int &RejectedAttributes, int &RequiredAttributes);
extern PACKAGE bool __fastcall IsFileAttributeMatch(int FileAttributes, int RejectedAttributes, int RequiredAttributes);
extern PACKAGE System::UnicodeString __fastcall FileAttributesStr(const Sysutils::TSearchRec &FileInfo);
extern PACKAGE bool __fastcall IsFileNameMatch(System::UnicodeString FileName, const System::UnicodeString Mask, const bool CaseSensitive = false);
extern PACKAGE void __fastcall EnumFiles(const System::UnicodeString Path, TFileHandlerEx HandleFile, int RejectedAttributes = 0x16, int RequiredAttributes = 0x0, System::PBoolean Abort = (void *)(0x0))/* overload */;
extern PACKAGE void __fastcall EnumFiles(const System::UnicodeString Path, TFileInfoHandlerEx HandleFile, int RejectedAttributes = 0x16, int RequiredAttributes = 0x0, System::PBoolean Abort = (void *)(0x0))/* overload */;
extern PACKAGE void __fastcall EnumDirectories(const System::UnicodeString Root, const TFileHandler HandleDirectory, const bool IncludeHiddenDirectories = false, const System::UnicodeString SubDirectoriesMask = L"", System::PBoolean Abort = (void *)(0x0));
extern PACKAGE _di_IJclFileEnumerator __fastcall FileSearch(void);
extern PACKAGE bool __fastcall SamePath(const System::UnicodeString Path1, const System::UnicodeString Path2);
extern PACKAGE void __fastcall PathListAddItems(System::UnicodeString &List, const System::UnicodeString Items);
extern PACKAGE void __fastcall PathListIncludeItems(System::UnicodeString &List, const System::UnicodeString Items);
extern PACKAGE void __fastcall PathListDelItems(System::UnicodeString &List, const System::UnicodeString Items);
extern PACKAGE void __fastcall PathListDelItem(System::UnicodeString &List, const int Index);
extern PACKAGE int __fastcall PathListItemCount(const System::UnicodeString List);
extern PACKAGE System::UnicodeString __fastcall PathListGetItem(const System::UnicodeString List, const int Index);
extern PACKAGE void __fastcall PathListSetItem(System::UnicodeString &List, const int Index, const System::UnicodeString Value);
extern PACKAGE int __fastcall PathListItemIndex(const System::UnicodeString List, const System::UnicodeString Item);
extern PACKAGE System::UnicodeString __fastcall ParamName(int Index, const System::UnicodeString Separator = L"=", const System::UnicodeString AllowedPrefixCharacters = L"-/", bool TrimName = true);
extern PACKAGE System::UnicodeString __fastcall ParamValue(int Index, const System::UnicodeString Separator = L"=", bool TrimValue = true)/* overload */;
extern PACKAGE System::UnicodeString __fastcall ParamValue(const System::UnicodeString SearchName, const System::UnicodeString Separator = L"=", bool CaseSensitive = false, const System::UnicodeString AllowedPrefixCharacters = L"-/", bool TrimValue = true)/* overload */;
extern PACKAGE int __fastcall ParamPos(const System::UnicodeString SearchName, const System::UnicodeString Separator = L"=", bool CaseSensitive = false, const System::UnicodeString AllowedPrefixCharacters = L"-/");

}	/* namespace Jclfileutils */
using namespace Jclfileutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclfileutilsHPP
