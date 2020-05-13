// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclntfs.pas' rev: 21.00

#ifndef JclntfsHPP
#define JclntfsHPP

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
#include <Activex.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclwin32.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclntfs
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclNtfsError;
class PASCALIMPLEMENTATION EJclNtfsError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclNtfsError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclNtfsError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclNtfsError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclNtfsError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclNtfsError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclNtfsError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclNtfsError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclNtfsError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclNtfsError(void) { }
	
};


#pragma option push -b-
enum TFileCompressionState { fcNoCompression, fcDefaultCompression, fcLZNT1Compression };
#pragma option pop

struct TNtfsAllocRanges
{
	
public:
	unsigned Entries;
	_FILE_ALLOCATED_RANGE_BUFFER *Data;
	bool MoreData;
};


#pragma option push -b-
enum TOpLock { olExclusive, olReadOnly, olBatch, olFilter };
#pragma option pop

#pragma option push -b-
enum TStreamId { siInvalid, siStandard, siExtendedAttribute, siSecurity, siAlternate, siHardLink, siProperty, siObjectIdentifier, siReparsePoints, siSparseFile };
#pragma option pop

typedef Set<TStreamId, siInvalid, siSparseFile>  TStreamIds;

struct TInternalFindStreamData
{
	
public:
	unsigned FileHandle;
	void *Context;
	TStreamIds StreamIds;
};


struct TFindStreamData
{
	
public:
	TInternalFindStreamData Internal;
	unsigned Attributes;
	TStreamId StreamID;
	System::WideString Name;
	__int64 Size;
};


struct TNtfsHardLinkInfo
{
	
public:
	unsigned LinkCount;
	#pragma pack(push,1)
	union
	{
		struct 
		{
			unsigned:32;
			__int64 FileIndex;
			
		};
		struct 
		{
			unsigned:32;
			unsigned FileIndexHigh;
			unsigned FileIndexLow;
			
		};
		
	};
	#pragma pack(pop)
};


class DELPHICLASS EJclFileSummaryError;
class PASCALIMPLEMENTATION EJclFileSummaryError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclFileSummaryError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclFileSummaryError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclFileSummaryError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclFileSummaryError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclFileSummaryError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclFileSummaryError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclFileSummaryError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclFileSummaryError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclFileSummaryError(void) { }
	
};


#pragma option push -b-
enum TJclFileSummaryAccess { fsaRead, fsaWrite, fsaReadWrite };
#pragma option pop

#pragma option push -b-
enum TJclFileSummaryShare { fssDenyNone, fssDenyRead, fssDenyWrite, fssDenyAll };
#pragma option pop

typedef bool __fastcall (__closure *TJclFileSummaryPropSetCallback)(const GUID &FMTID);

typedef bool __fastcall (__closure *TJclFileSummaryPropCallback)(const System::WideString Name, unsigned ID, System::Word Vt);

class DELPHICLASS TJclFilePropertySet;
class PASCALIMPLEMENTATION TJclFilePropertySet : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	_di_IPropertyStorage FPropertyStorage;
	
public:
	__fastcall TJclFilePropertySet(_di_IPropertyStorage APropertyStorage);
	__fastcall virtual ~TJclFilePropertySet(void);
	__classmethod virtual GUID __fastcall GetFMTID();
	tagPROPVARIANT __fastcall GetProperty(unsigned ID)/* overload */;
	tagPROPVARIANT __fastcall GetProperty(const System::WideString Name)/* overload */;
	void __fastcall SetProperty(unsigned ID, const tagPROPVARIANT &Value)/* overload */;
	void __fastcall SetProperty(const System::WideString Name, const tagPROPVARIANT &Value, unsigned AllocationBase = (unsigned)(0x2))/* overload */;
	void __fastcall DeleteProperty(unsigned ID)/* overload */;
	void __fastcall DeleteProperty(const System::WideString Name)/* overload */;
	bool __fastcall EnumProperties(TJclFileSummaryPropCallback Proc);
	System::WideString __fastcall GetWideStringProperty(const int ID);
	void __fastcall SetWideStringProperty(const int ID, const System::WideString Value);
	System::AnsiString __fastcall GetAnsiStringProperty(const int ID);
	void __fastcall SetAnsiStringProperty(const int ID, const System::AnsiString Value);
	int __fastcall GetIntegerProperty(const int ID);
	void __fastcall SetIntegerProperty(const int ID, const int Value);
	unsigned __fastcall GetCardinalProperty(const int ID);
	void __fastcall SetCardinalProperty(const int ID, const unsigned Value);
	_FILETIME __fastcall GetFileTimeProperty(const int ID);
	void __fastcall SetFileTimeProperty(const int ID, const _FILETIME &Value);
	Activex::PClipData __fastcall GetClipDataProperty(const int ID);
	void __fastcall SetClipDataProperty(const int ID, const Activex::PClipData Value);
	bool __fastcall GetBooleanProperty(const int ID);
	void __fastcall SetBooleanProperty(const int ID, const bool Value);
	tagCAPROPVARIANT __fastcall GetTCAPROPVARIANTProperty(const int ID);
	void __fastcall SetTCAPROPVARIANTProperty(const int ID, const tagCAPROPVARIANT &Value);
	tagCALPSTR __fastcall GetTCALPSTRProperty(const int ID);
	void __fastcall SetTCALPSTRProperty(const int ID, const tagCALPSTR &Value);
	System::Word __fastcall GetWordProperty(const int ID);
	void __fastcall SetWordProperty(const int ID, const System::Word Value);
	System::WideString __fastcall GetBSTRProperty(const int ID);
	void __fastcall SetBSTRProperty(const int ID, const System::WideString Value);
	System::WideString __fastcall GetPropertyName(unsigned ID);
	void __fastcall SetPropertyName(unsigned ID, const System::WideString Name);
	void __fastcall DeletePropertyName(unsigned ID);
};


typedef TMetaClass* TJclFilePropertySetClass;

class DELPHICLASS TJclFileSummary;
class PASCALIMPLEMENTATION TJclFileSummary : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::WideString FFileName;
	TJclFileSummaryAccess FAccessMode;
	TJclFileSummaryShare FShareMode;
	_di_IPropertySetStorage FStorage;
	
public:
	__fastcall TJclFileSummary(System::WideString AFileName, TJclFileSummaryAccess AAccessMode, TJclFileSummaryShare AShareMode, bool AsDocument, bool ACreate);
	__fastcall virtual ~TJclFileSummary(void);
	TJclFilePropertySet* __fastcall CreatePropertySet(TJclFilePropertySetClass AClass, bool ResetExisting);
	void __fastcall GetPropertySet(TJclFilePropertySetClass AClass, /* out */ void *Instance)/* overload */;
	void __fastcall GetPropertySet(const GUID &FMTID, /* out */ void *Instance)/* overload */;
	_di_IPropertyStorage __fastcall GetPropertySet(const GUID &FMTID)/* overload */;
	void __fastcall DeletePropertySet(const GUID &FMTID)/* overload */;
	void __fastcall DeletePropertySet(TJclFilePropertySetClass AClass)/* overload */;
	bool __fastcall EnumPropertySet(TJclFileSummaryPropSetCallback Proc);
	__property System::WideString FileName = {read=FFileName};
	__property TJclFileSummaryAccess AccessMode = {read=FAccessMode, nodefault};
	__property TJclFileSummaryShare ShareMode = {read=FShareMode, nodefault};
};


class DELPHICLASS TJclFileSummaryInformation;
class PASCALIMPLEMENTATION TJclFileSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
	__property System::AnsiString Title = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=2};
	__property System::AnsiString Subject = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=3};
	__property System::AnsiString Author = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=4};
	__property System::AnsiString KeyWords = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=5};
	__property System::AnsiString Comments = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=6};
	__property System::AnsiString Template = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=7};
	__property System::AnsiString LastAuthor = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=8};
	__property System::AnsiString RevNumber = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=9};
	__property _FILETIME EditTime = {read=GetFileTimeProperty, write=SetFileTimeProperty, index=10};
	__property _FILETIME LastPrintedTime = {read=GetFileTimeProperty, write=SetFileTimeProperty, index=11};
	__property _FILETIME CreationTime = {read=GetFileTimeProperty, write=SetFileTimeProperty, index=12};
	__property _FILETIME LastSaveTime = {read=GetFileTimeProperty, write=SetFileTimeProperty, index=13};
	__property int PageCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=14, nodefault};
	__property int WordCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=15, nodefault};
	__property int CharCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=16, nodefault};
	__property Activex::PClipData Thumnail = {read=GetClipDataProperty, write=SetClipDataProperty, index=17};
	__property System::AnsiString AppName = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=18};
	__property int Security = {read=GetIntegerProperty, write=SetIntegerProperty, index=19, nodefault};
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclFileSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclFileSummaryInformation(void) { }
	
};


class DELPHICLASS TJclDocSummaryInformation;
class PASCALIMPLEMENTATION TJclDocSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
	__property System::AnsiString Category = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=2};
	__property System::AnsiString PresFormat = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=3};
	__property int ByteCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=4, nodefault};
	__property int LineCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=5, nodefault};
	__property int ParCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=6, nodefault};
	__property int SlideCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=7, nodefault};
	__property int NoteCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=8, nodefault};
	__property int HiddenCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=9, nodefault};
	__property int MMClipCount = {read=GetIntegerProperty, write=SetIntegerProperty, index=10, nodefault};
	__property bool Scale = {read=GetBooleanProperty, write=SetBooleanProperty, index=11, nodefault};
	__property tagCAPROPVARIANT HeadingPair = {read=GetTCAPROPVARIANTProperty, write=SetTCAPROPVARIANTProperty, index=12};
	__property tagCALPSTR DocParts = {read=GetTCALPSTRProperty, write=SetTCALPSTRProperty, index=13};
	__property System::AnsiString Manager = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=14};
	__property System::AnsiString Company = {read=GetAnsiStringProperty, write=SetAnsiStringProperty, index=15};
	__property bool LinksDirty = {read=GetBooleanProperty, write=SetBooleanProperty, index=16, nodefault};
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclDocSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclDocSummaryInformation(void) { }
	
};


class DELPHICLASS TJclMediaFileSummaryInformation;
class PASCALIMPLEMENTATION TJclMediaFileSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
	__property System::WideString Editor = {read=GetWideStringProperty, write=SetWideStringProperty, index=2};
	__property System::WideString Supplier = {read=GetWideStringProperty, write=SetWideStringProperty, index=3};
	__property System::WideString Source = {read=GetWideStringProperty, write=SetWideStringProperty, index=4};
	__property System::WideString SequenceNo = {read=GetWideStringProperty, write=SetWideStringProperty, index=5};
	__property System::WideString Project = {read=GetWideStringProperty, write=SetWideStringProperty, index=6};
	__property unsigned Status = {read=GetCardinalProperty, write=SetCardinalProperty, index=7, nodefault};
	__property System::WideString Owner = {read=GetWideStringProperty, write=SetWideStringProperty, index=8};
	__property System::WideString Rating = {read=GetWideStringProperty, write=SetWideStringProperty, index=9};
	__property _FILETIME Production = {read=GetFileTimeProperty, write=SetFileTimeProperty, index=10};
	__property System::WideString Copyright = {read=GetWideStringProperty, write=SetWideStringProperty, index=11};
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclMediaFileSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclMediaFileSummaryInformation(void) { }
	
};


class DELPHICLASS TJclMSISummaryInformation;
class PASCALIMPLEMENTATION TJclMSISummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
	__property int Version = {read=GetIntegerProperty, write=SetIntegerProperty, index=14, nodefault};
	__property int Source = {read=GetIntegerProperty, write=SetIntegerProperty, index=15, nodefault};
	__property int Restrict = {read=GetIntegerProperty, write=SetIntegerProperty, index=16, nodefault};
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclMSISummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclMSISummaryInformation(void) { }
	
};


class DELPHICLASS TJclShellSummaryInformation;
class PASCALIMPLEMENTATION TJclShellSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclShellSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclShellSummaryInformation(void) { }
	
};


class DELPHICLASS TJclStorageSummaryInformation;
class PASCALIMPLEMENTATION TJclStorageSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclStorageSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclStorageSummaryInformation(void) { }
	
};


class DELPHICLASS TJclImageSummaryInformation;
class PASCALIMPLEMENTATION TJclImageSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclImageSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclImageSummaryInformation(void) { }
	
};


class DELPHICLASS TJclDisplacedSummaryInformation;
class PASCALIMPLEMENTATION TJclDisplacedSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclDisplacedSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclDisplacedSummaryInformation(void) { }
	
};


class DELPHICLASS TJclBriefCaseSummaryInformation;
class PASCALIMPLEMENTATION TJclBriefCaseSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclBriefCaseSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclBriefCaseSummaryInformation(void) { }
	
};


class DELPHICLASS TJclMiscSummaryInformation;
class PASCALIMPLEMENTATION TJclMiscSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclMiscSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclMiscSummaryInformation(void) { }
	
};


class DELPHICLASS TJclWebViewSummaryInformation;
class PASCALIMPLEMENTATION TJclWebViewSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclWebViewSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclWebViewSummaryInformation(void) { }
	
};


class DELPHICLASS TJclMusicSummaryInformation;
class PASCALIMPLEMENTATION TJclMusicSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclMusicSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclMusicSummaryInformation(void) { }
	
};


class DELPHICLASS TJclDRMSummaryInformation;
class PASCALIMPLEMENTATION TJclDRMSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclDRMSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclDRMSummaryInformation(void) { }
	
};


class DELPHICLASS TJclVideoSummaryInformation;
class PASCALIMPLEMENTATION TJclVideoSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
	__property System::WideString StreamName = {read=GetWideStringProperty, write=SetWideStringProperty, index=2};
	__property unsigned Width = {read=GetCardinalProperty, write=SetCardinalProperty, index=3, nodefault};
	__property unsigned Height = {read=GetCardinalProperty, write=SetCardinalProperty, index=4, nodefault};
	__property unsigned TimeLength = {read=GetCardinalProperty, write=SetCardinalProperty, index=7, nodefault};
	__property unsigned FrameCount = {read=GetCardinalProperty, write=SetCardinalProperty, index=5, nodefault};
	__property unsigned FrameRate = {read=GetCardinalProperty, write=SetCardinalProperty, index=6, nodefault};
	__property unsigned DataRate = {read=GetCardinalProperty, write=SetCardinalProperty, index=8, nodefault};
	__property unsigned SampleSize = {read=GetCardinalProperty, write=SetCardinalProperty, index=9, nodefault};
	__property System::WideString Compression = {read=GetWideStringProperty, write=SetWideStringProperty, index=10};
	__property System::Word StreamNumber = {read=GetWordProperty, write=SetWordProperty, index=11, nodefault};
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclVideoSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclVideoSummaryInformation(void) { }
	
};


class DELPHICLASS TJclAudioSummaryInformation;
class PASCALIMPLEMENTATION TJclAudioSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
	__property System::WideString Format = {read=GetBSTRProperty, write=SetBSTRProperty, index=2};
	__property unsigned TimeLength = {read=GetCardinalProperty, write=SetCardinalProperty, index=3, nodefault};
	__property unsigned AverageDataRate = {read=GetCardinalProperty, write=SetCardinalProperty, index=4, nodefault};
	__property unsigned SampleRate = {read=GetCardinalProperty, write=SetCardinalProperty, index=5, nodefault};
	__property unsigned SampleSize = {read=GetCardinalProperty, write=SetCardinalProperty, index=6, nodefault};
	__property unsigned ChannelCount = {read=GetCardinalProperty, write=SetCardinalProperty, index=7, nodefault};
	__property System::Word StreamNumber = {read=GetWordProperty, write=SetWordProperty, index=8, nodefault};
	__property System::WideString StreamName = {read=GetWideStringProperty, write=SetWideStringProperty, index=9};
	__property System::WideString Compression = {read=GetWideStringProperty, write=SetWideStringProperty, index=10};
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclAudioSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclAudioSummaryInformation(void) { }
	
};


class DELPHICLASS TJclControlPanelSummaryInformation;
class PASCALIMPLEMENTATION TJclControlPanelSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclControlPanelSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclControlPanelSummaryInformation(void) { }
	
};


class DELPHICLASS TJclVolumeSummaryInformation;
class PASCALIMPLEMENTATION TJclVolumeSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclVolumeSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclVolumeSummaryInformation(void) { }
	
};


class DELPHICLASS TJclShareSummaryInformation;
class PASCALIMPLEMENTATION TJclShareSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclShareSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclShareSummaryInformation(void) { }
	
};


class DELPHICLASS TJclLinkSummaryInformation;
class PASCALIMPLEMENTATION TJclLinkSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclLinkSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclLinkSummaryInformation(void) { }
	
};


class DELPHICLASS TJclQuerySummaryInformation;
class PASCALIMPLEMENTATION TJclQuerySummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclQuerySummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclQuerySummaryInformation(void) { }
	
};


class DELPHICLASS TJclImageInformation;
class PASCALIMPLEMENTATION TJclImageInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclImageInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclImageInformation(void) { }
	
};


class DELPHICLASS TJclJpegSummaryInformation;
class PASCALIMPLEMENTATION TJclJpegSummaryInformation : public TJclFilePropertySet
{
	typedef TJclFilePropertySet inherited;
	
public:
	__classmethod virtual GUID __fastcall GetFMTID();
public:
	/* TJclFilePropertySet.Create */ inline __fastcall TJclJpegSummaryInformation(_di_IPropertyStorage APropertyStorage) : TJclFilePropertySet(APropertyStorage) { }
	/* TJclFilePropertySet.Destroy */ inline __fastcall virtual ~TJclJpegSummaryInformation(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall NtfsGetCompression(const Sysutils::TFileName FileName, /* out */ short &State)/* overload */;
extern PACKAGE TFileCompressionState __fastcall NtfsGetCompression(const Sysutils::TFileName FileName)/* overload */;
extern PACKAGE bool __fastcall NtfsSetCompression(const Sysutils::TFileName FileName, const short State);
extern PACKAGE void __fastcall NtfsSetFileCompression(const Sysutils::TFileName FileName, const TFileCompressionState State);
extern PACKAGE void __fastcall NtfsSetDefaultFileCompression(const System::UnicodeString Directory, const TFileCompressionState State);
extern PACKAGE void __fastcall NtfsSetDirectoryTreeCompression(const System::UnicodeString Directory, const TFileCompressionState State);
extern PACKAGE void __fastcall NtfsSetPathCompression(const System::UnicodeString Path, const TFileCompressionState State, bool Recursive);
extern PACKAGE bool __fastcall NtfsSetSparse(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall NtfsZeroDataByHandle(const unsigned Handle, const __int64 First, const __int64 Last);
extern PACKAGE bool __fastcall NtfsZeroDataByName(const System::UnicodeString FileName, const __int64 First, const __int64 Last);
extern PACKAGE _FILE_ALLOCATED_RANGE_BUFFER __fastcall NtfsGetAllocRangeEntry(const TNtfsAllocRanges &Ranges, unsigned Index);
extern PACKAGE bool __fastcall NtfsQueryAllocRanges(const System::UnicodeString FileName, __int64 Offset, __int64 Count, TNtfsAllocRanges &Ranges);
extern PACKAGE bool __fastcall NtfsSparseStreamsSupported(const System::UnicodeString Volume);
extern PACKAGE bool __fastcall NtfsGetSparse(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall NtfsGetReparseTag(const System::UnicodeString Path, unsigned &Tag);
extern PACKAGE bool __fastcall NtfsReparsePointsSupported(const System::UnicodeString Volume);
extern PACKAGE bool __fastcall NtfsFileHasReparsePoint(const System::UnicodeString Path);
extern PACKAGE bool __fastcall NtfsDeleteReparsePoint(const System::UnicodeString FileName, unsigned ReparseTag);
extern PACKAGE bool __fastcall NtfsSetReparsePoint(const System::UnicodeString FileName, void *ReparseData, unsigned Size);
extern PACKAGE bool __fastcall NtfsGetReparsePoint(const System::UnicodeString FileName, _REPARSE_GUID_DATA_BUFFER &ReparseData);
extern PACKAGE bool __fastcall NtfsIsFolderMountPoint(const System::UnicodeString Path);
extern PACKAGE bool __fastcall NtfsMountDeviceAsDrive(const System::WideString Device, System::WideChar Drive);
extern PACKAGE bool __fastcall NtfsMountVolume(const System::WideChar Volume, const System::WideString MountPoint);
extern PACKAGE bool __fastcall NtfsOpLockAckClosePending(unsigned Handle, const _OVERLAPPED &Overlapped);
extern PACKAGE bool __fastcall NtfsOpLockBreakAckNo2(unsigned Handle, const _OVERLAPPED &Overlapped);
extern PACKAGE bool __fastcall NtfsOpLockBreakAcknowledge(unsigned Handle, const _OVERLAPPED &Overlapped);
extern PACKAGE bool __fastcall NtfsOpLockBreakNotify(unsigned Handle, const _OVERLAPPED &Overlapped);
extern PACKAGE bool __fastcall NtfsRequestOpLock(unsigned Handle, TOpLock Kind, const _OVERLAPPED &Overlapped);
extern PACKAGE bool __fastcall NtfsCreateJunctionPoint(const System::UnicodeString Source, const System::UnicodeString Destination);
extern PACKAGE bool __fastcall NtfsDeleteJunctionPoint(const System::UnicodeString Source);
extern PACKAGE bool __fastcall NtfsGetJunctionPointDestination(const System::UnicodeString Source, System::UnicodeString &Destination);
extern PACKAGE bool __fastcall NtfsFindFirstStream(const System::UnicodeString FileName, TStreamIds StreamIds, TFindStreamData &Data);
extern PACKAGE bool __fastcall NtfsFindNextStream(TFindStreamData &Data);
extern PACKAGE bool __fastcall NtfsFindStreamClose(TFindStreamData &Data);
extern PACKAGE bool __fastcall NtfsCreateHardLinkA(const System::AnsiString LinkFileName, const System::AnsiString ExistingFileName);
extern PACKAGE bool __fastcall NtfsCreateHardLinkW(const System::WideString LinkFileName, const System::WideString ExistingFileName);
extern PACKAGE bool __fastcall NtfsCreateHardLink(const System::UnicodeString LinkFileName, const System::UnicodeString ExistingFileName);
extern PACKAGE bool __fastcall NtfsGetHardLinkInfo(const System::UnicodeString FileName, TNtfsHardLinkInfo &Info);
extern PACKAGE bool __fastcall NtfsFindHardLinks(const System::UnicodeString Path, const unsigned FileIndexHigh, const unsigned FileIndexLow, const Classes::TStrings* List);
extern PACKAGE bool __fastcall NtfsDeleteHardLinks(const System::UnicodeString FileName);

}	/* namespace Jclntfs */
using namespace Jclntfs;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclntfsHPP
