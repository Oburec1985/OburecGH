// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclwin32.pas' rev: 21.00

#ifndef Jclwin32HPP
#define Jclwin32HPP

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
#include <Accctrl.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#include <WinDef.h>
#include <WinNT.h>
#include <WinBase.h>
#include <BaseTsd.h>
#include <ImageHlp.h>
#include <lm.h>
#include <Nb30.h>
#include <RasDlg.h>
#include <Reason.h>
#include <ShlWApi.h>
#include <WinError.h>
#include <WinIoCtl.h>
#include <WinUser.h>
#include <delayimp.h>
#include <propidl.h>
#include <msidefs.h>
#include <shlguid.h>
#include <objbase.h>
#include <ntsecapi.h>

typedef struct _REPARSE_DATA_BUFFER {

    DWORD   ReparseTag;
    WORD    ReparseDataLength;
    WORD    Reserved;

    union {

        struct {
            WORD    SubstituteNameOffset;
            WORD    SubstituteNameLength;
            WORD    PrintNameOffset;
            WORD    PrintNameLength;
            WCHAR   PathBuffer[1];
        } SymbolicLinkReparseBuffer;

        struct {
            WORD    SubstituteNameOffset;
            WORD    SubstituteNameLength;
            WORD    PrintNameOffset;
            WORD    PrintNameLength;
            WCHAR   PathBuffer[1];
        } MountPointReparseBuffer;

        struct {
            UCHAR   DataBuffer[1];
        } GenericReparseBuffer;
    };

} REPARSE_DATA_BUFFER, *PREPARSE_DATA_BUFFER;

#ifndef REPARSE_DATA_BUFFER_HEADER_SIZE
#define REPARSE_DATA_BUFFER_HEADER_SIZE   8
#endif

typedef struct _REPARSE_POINT_INFORMATION {
        WORD    ReparseDataLength;
        WORD    UnparsedNameLength;
} REPARSE_POINT_INFORMATION, *PREPARSE_POINT_INFORMATION;

#ifndef IO_REPARSE_TAG_VALID_VALUES
#define IO_REPARSE_TAG_VALID_VALUES 0x0E000FFFF
#endif


namespace Jclwin32
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclWin32Error;
class PASCALIMPLEMENTATION EJclWin32Error : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
private:
	unsigned FLastError;
	System::UnicodeString FLastErrorMsg;
	
public:
	__fastcall EJclWin32Error(const System::UnicodeString Msg);
	__fastcall EJclWin32Error(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size);
	__fastcall EJclWin32Error(int Ident)/* overload */;
	__fastcall EJclWin32Error(System::PResStringRec ResStringRec)/* overload */;
	__property unsigned LastError = {read=FLastError, nodefault};
	__property System::UnicodeString LastErrorMsg = {read=FLastErrorMsg};
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclWin32Error(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclWin32Error(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclWin32Error(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclWin32Error(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclWin32Error(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclWin32Error(void) { }
	
};


typedef _REPARSE_DATA_BUFFER TReparseDataBuffer;

typedef PREPARSE_DATA_BUFFER PReparseDataBuffer;

typedef _REPARSE_POINT_INFORMATION TReparsePointInformation;

typedef PREPARSE_POINT_INFORMATION PReparsePointInformation;

typedef _SID TSid;

typedef unsigned TSidNameUse;

typedef PSID_NAME_USE PSidNameUSe;

typedef _SID_AND_ATTRIBUTES TSidAndAttributes;

typedef PSID_AND_ATTRIBUTES PSidAndAttributes;

typedef SID_AND_ATTRIBUTES_ARRAY *PSidAndAttributesArray;

typedef SID_AND_ATTRIBUTES_ARRAY TSidAndAttributesArray;

typedef _TOKEN_USER TTokenUser;

typedef PTOKEN_USER PTokenUser;

struct TGenericReparseBuffer
{
	
public:
	StaticArray<System::Byte, 1> DataBuffer;
};


typedef _REPARSE_GUID_DATA_BUFFER TReparseGuidDataBuffer;

typedef PREPARSE_GUID_DATA_BUFFER PReparseGuidDataBuffer;

typedef _IMAGE_FILE_HEADER TImageFileHeader;

typedef PIMAGE_FILE_HEADER PImageFileHeader;

typedef _IMAGE_OPTIONAL_HEADER TImageOptionalHeader32;

typedef PIMAGE_OPTIONAL_HEADER32 PImageOptionalHeader32;

typedef _IMAGE_ROM_OPTIONAL_HEADER TImageRomOptionalHeader;

typedef PIMAGE_ROM_OPTIONAL_HEADER PImageRomOptionalHeader;

typedef _IMAGE_OPTIONAL_HEADER64 TImageOptionalHeader64;

typedef PIMAGE_OPTIONAL_HEADER64 PImageOptionalHeader64;

typedef _IMAGE_NT_HEADERS64 TImageNtHeaders64;

typedef PIMAGE_NT_HEADERS64 PImageNtHeaders64;

typedef _IMAGE_NT_HEADERS TImageNtHeaders32;

typedef PIMAGE_NT_HEADERS32 PImageNtHeaders32;

typedef ANON_OBJECT_HEADER *PAnonObjectHeader;

typedef ANON_OBJECT_HEADER TAnonObjectHeader;

typedef Windows::PImageSectionHeader *PPImageSectionHeader;

struct TImgLineNoType
{
	
	#pragma pack(push,1)
	union
	{
		struct 
		{
			unsigned VirtualAddress;
			
		};
		struct 
		{
			unsigned SymbolTableIndex;
			
		};
		
	};
	#pragma pack(pop)
};


typedef _IMAGE_LINENUMBER TImageLineNumber;

typedef PIMAGE_LINENUMBER PImageLineNumber;

typedef _IMAGE_BASE_RELOCATION TImageBaseRelocation;

typedef PIMAGE_BASE_RELOCATION PImageBaseRelocation;

typedef _IMAGE_ARCHIVE_MEMBER_HEADER TImageArchiveMemberHeader;

typedef PIMAGE_ARCHIVE_MEMBER_HEADER PImageArchiveMemberHeader;

typedef _IMAGE_EXPORT_DIRECTORY TImageExportDirectory;

typedef PIMAGE_EXPORT_DIRECTORY PImageExportDirectory;

typedef _IMAGE_IMPORT_BY_NAME TImageImportByName;

typedef PIMAGE_IMPORT_BY_NAME PImageImportByName;

typedef _IMAGE_THUNK_DATA64 TImageThunkData64;

typedef PIMAGE_THUNK_DATA64 PImageThunkData64;

typedef _IMAGE_THUNK_DATA32 TImageThunkData32;

typedef PIMAGE_THUNK_DATA32 PImageThunkData32;

typedef PIMAGE_TLS_CALLBACK TImageTlsCallback;

typedef _IMAGE_THUNK_DATA32 TImageThunkData;

typedef PIMAGE_THUNK_DATA32 PImageThunkData;

struct TIIDUnion
{
	
	#pragma pack(push,1)
	union
	{
		struct 
		{
			unsigned OriginalFirstThunk;
			
		};
		struct 
		{
			unsigned Characteristics;
			
		};
		
	};
	#pragma pack(pop)
};


typedef _IMAGE_IMPORT_DESCRIPTOR TImageImportDescriptor;

typedef PIMAGE_IMPORT_DESCRIPTOR PImageImportDescriptor;

typedef _IMAGE_BOUND_IMPORT_DESCRIPTOR TImageBoundImportDescriptor;

typedef PIMAGE_BOUND_IMPORT_DESCRIPTOR PImageBoundImportDescriptor;

typedef _IMAGE_BOUND_FORWARDER_REF TImageBoundForwarderRef;

typedef PIMAGE_BOUND_FORWARDER_REF PImageBoundForwarderRef;

typedef _IMAGE_RESOURCE_DIRECTORY TImageResourceDirectory;

typedef PIMAGE_RESOURCE_DIRECTORY PImageResourceDirectory;

typedef _IMAGE_RESOURCE_DIRECTORY_ENTRY TImageResourceDirectoryEntry;

typedef PIMAGE_RESOURCE_DIRECTORY_ENTRY PImageResourceDirectoryEntry;

typedef _IMAGE_RESOURCE_DIRECTORY_STRING TImageResourceDirectoryString;

typedef PIMAGE_RESOURCE_DIRECTORY_STRING PImageResourceDirectoryString;

typedef _IMAGE_RESOURCE_DIR_STRING_U TImageResourceDirStringU;

typedef PIMAGE_RESOURCE_DIR_STRING_U PImageResourceDirStringU;

typedef _IMAGE_RESOURCE_DATA_ENTRY TImageResourceDataEntry;

typedef PIMAGE_RESOURCE_DATA_ENTRY PImageResourceDataEntry;

typedef IMAGE_LOAD_CONFIG_DIRECTORY32 TImageLoadConfigDirectory32;

typedef PIMAGE_LOAD_CONFIG_DIRECTORY32 PImageLoadConfigDirectory32;

typedef IMAGE_LOAD_CONFIG_DIRECTORY64 TImageLoadConfigDirectory64;

typedef PIMAGE_LOAD_CONFIG_DIRECTORY64 PImageLoadConfigDirectory64;

typedef IMAGE_LOAD_CONFIG_DIRECTORY32 TImageLoadConfigDirectory;

typedef PIMAGE_LOAD_CONFIG_DIRECTORY32 PImageLoadConfigDirectory;

typedef _IMAGE_COFF_SYMBOLS_HEADER TImageCoffSymbolsHeader;

typedef PIMAGE_COFF_SYMBOLS_HEADER PImageCoffSymbolsHeader;

typedef _FPO_DATA TFpoData;

typedef PFPO_DATA PFpoData;

typedef _IMAGE_DEBUG_MISC TImageDebugMisc;

typedef PIMAGE_DEBUG_MISC PImageDebugMisc;

typedef _IMAGE_FUNCTION_ENTRY TImageFunctionEntry;

typedef PIMAGE_FUNCTION_ENTRY PImageFunctionEntry;

typedef _IMAGE_FUNCTION_ENTRY64 TImageFunctionEntry64;

typedef PIMAGE_FUNCTION_ENTRY64 PImageFunctionEntry64;

typedef _IMAGE_SEPARATE_DEBUG_HEADER TImageSeparateDebugHeader;

typedef PIMAGE_SEPARATE_DEBUG_HEADER PImageSeparateDebugHeader;

typedef _ImageArchitectureHeader TImageArchitectureHeader;

typedef PIMAGE_ARCHITECTURE_HEADER PImageArchitectureHeader;

typedef _ImageArchitectureEntry TImageArchitectureEntry;

typedef PIMAGE_ARCHITECTURE_ENTRY PImageArchitectureEntry;

typedef IMPORT_OBJECT_HEADER *PImportObjectHeader;

typedef IMPORT_OBJECT_HEADER TImportObjectHeader;

typedef IMPORT_OBJECT_TYPE TImportObjectType;

typedef IMPORT_OBJECT_NAME_TYPE TImportObjectNameType;

struct IMAGE_COR20_HEADER
{
	
public:
	unsigned cb;
	System::Word MajorRuntimeVersion;
	System::Word MinorRuntimeVersion;
	_IMAGE_DATA_DIRECTORY MetaData;
	unsigned Flags;
	unsigned EntryPointToken;
	_IMAGE_DATA_DIRECTORY Resources;
	_IMAGE_DATA_DIRECTORY StrongNameSignature;
	_IMAGE_DATA_DIRECTORY CodeManagerTable;
	_IMAGE_DATA_DIRECTORY VTableFixups;
	_IMAGE_DATA_DIRECTORY ExportAddressTableJumps;
	_IMAGE_DATA_DIRECTORY ManagedNativeHeader;
};


typedef IMAGE_COR20_HEADER *PIMAGE_COR20_HEADER;

typedef IMAGE_COR20_HEADER TImageCor20Header;

typedef PIMAGE_COR20_HEADER PImageCor20Header;

typedef _OSVERSIONINFOEXA TOSVersionInfoExA;

typedef _OSVERSIONINFOEXW TOSVersionInfoExW;

typedef _OSVERSIONINFOEXW TOSVersionInfoEx;

typedef _MEMORYSTATUSEX TMemoryStatusEx;

typedef _LOADED_IMAGE TLoadedImage;

typedef PLOADED_IMAGE PLoadedImage;

typedef SYM_TYPE TSymType;

#pragma pack(push,1)
struct _IMAGEHLP_LINEA
{
	
public:
	unsigned SizeOfStruct;
	void *Key;
	unsigned LineNumber;
	char *FileName;
	unsigned Address;
};
#pragma pack(pop)


typedef _IMAGEHLP_LINEA IMAGEHLP_LINEA;

typedef _IMAGEHLP_LINEA *PIMAGEHLP_LINEA;

typedef _IMAGEHLP_LINEA TImageHlpLineA;

typedef PIMAGEHLP_LINEA PImageHlpLineA;

#pragma pack(push,1)
struct _IMAGEHLP_LINEW
{
	
public:
	unsigned SizeOfStruct;
	void *Key;
	unsigned LineNumber;
	System::WideChar *FileName;
	unsigned Address;
};
#pragma pack(pop)


typedef _IMAGEHLP_LINEW IMAGEHLP_LINEW;

typedef _IMAGEHLP_LINEW *PIMAGEHLP_LINEW;

typedef _IMAGEHLP_LINEW TImageHlpLineW;

typedef PIMAGEHLP_LINEW PImageHlpLineW;

typedef unsigned TNetApiStatus;

typedef _USER_INFO_0 TUserInfo0;

typedef PUSER_INFO_0 PUserInfo0;

typedef _USER_INFO_1 TUserInfo1;

typedef PUSER_INFO_1 PUserInfo1;

typedef _USER_INFO_2 TUserInfo2;

typedef PUSER_INFO_2 PUserInfo2;

typedef _GROUP_INFO_0 TGroupInfo0;

typedef PGROUP_INFO_0 PGroupInfo0;

typedef _GROUP_INFO_1 TGroupInfo1;

typedef PGROUP_INFO_1 PGroupInfo1;

typedef _LOCALGROUP_INFO_0 TLocalGroupInfo0;

typedef PLOCALGROUP_INFO_0 PLocalGroupInfo0;

typedef _LOCALGROUP_INFO_1 TLocalGroupInfo1;

typedef PLOCALGROUP_INFO_1 PLocalGroupInfo1;

typedef _LOCALGROUP_INFO_1002 TLocalGroupInfo1002;

typedef PLOCALGROUP_INFO_1002 PLocalGroupInfo1002;

typedef _LOCALGROUP_MEMBERS_INFO_0 TLocalGroupMembersInfo0;

typedef PLOCALGROUP_MEMBERS_INFO_0 PLocalGroupMembersInfo0;

typedef _LOCALGROUP_MEMBERS_INFO_1 TLocalGroupMembersInfo1;

typedef PLOCALGROUP_MEMBERS_INFO_1 PLocalGroupMembersInfo1;

typedef _LOCALGROUP_MEMBERS_INFO_2 TLocalGroupMembersInfo2;

typedef PLOCALGROUP_MEMBERS_INFO_2 PLocalGroupMembersInfo2;

typedef _LOCALGROUP_MEMBERS_INFO_3 TLocalGroupMembersInfo3;

typedef PLOCALGROUP_MEMBERS_INFO_3 PLocalGroupMembersInfo3;

typedef _NCB *PNCB;

typedef void __stdcall (*TNcbPost)(PNCB P);

typedef _NCB TNcb;

typedef _ADAPTER_STATUS TAdapterStatus;

typedef PADAPTER_STATUS PAdapterStatus;

typedef _NAME_BUFFER TNameBuffer;

typedef PNAME_BUFFER PNameBuffer;

typedef _SESSION_HEADER TSessionHeader;

typedef PSESSION_HEADER PSessionHeader;

typedef _SESSION_BUFFER TSessionBuffer;

typedef PSESSION_BUFFER PSessionBuffer;

typedef _LANA_ENUM TLanaEnum;

typedef PLANA_ENUM PLanaEnum;

typedef _FIND_NAME_HEADER TFindNameHeader;

typedef PFIND_NAME_HEADER PFindNameHeader;

typedef _FIND_NAME_BUFFER TFindNameBuffer;

typedef PFIND_NAME_BUFFER PFindNameBuffer;

typedef _ACTION_HEADER TActionHeader;

typedef PACTION_HEADER PActionHeader;

typedef tagRASDIALDLG *PRasDialDlg;

typedef tagRASDIALDLG TRasDialDlg;

typedef _DLLVERSIONINFO *PDllVersionInfo;

typedef _DLLVERSIONINFO TDllVersionInfo;

typedef _FILE_ZERO_DATA_INFORMATION TFileZeroDataInformation;

typedef PFILE_ZERO_DATA_INFORMATION PFileZeroDataInformation;

typedef _FILE_ALLOCATED_RANGE_BUFFER TFileAllocatedRangeBuffer;

typedef PFILE_ALLOCATED_RANGE_BUFFER PFileAllocatedRangeBuffer;

typedef CALINFO_ENUMPROCEXW TCalInfoEnumProcExW;

struct _LSA_UNICODE_STRING
{
	
public:
	System::Word Length;
	System::Word MaximumLength;
	System::WideChar *Buffer;
};


typedef _LSA_UNICODE_STRING *PLSA_UNICODE_STRING;

typedef _LSA_UNICODE_STRING LSA_UNICODE_STRING;

typedef _LSA_UNICODE_STRING TLsaUnicodeString;

typedef PLSA_UNICODE_STRING PLsaUnicodeString;

struct _LSA_STRING;
typedef _LSA_STRING *PLSA_STRING;

struct _LSA_STRING
{
	
public:
	System::Word Length;
	System::Word MaximumLength;
	char *Buffer;
};


typedef _LSA_STRING LSA_STRING;

typedef _LSA_STRING TLsaString;

typedef PLSA_STRING PLsaString;

struct _LSA_OBJECT_ATTRIBUTES;
typedef _LSA_OBJECT_ATTRIBUTES *PLSA_OBJECT_ATTRIBUTES;

struct _LSA_OBJECT_ATTRIBUTES
{
	
public:
	unsigned Length;
	unsigned RootDirectory;
	_LSA_UNICODE_STRING *ObjectName;
	unsigned Attributes;
	void *SecurityDescriptor;
	void *SecurityQualityOfService;
};


typedef _LSA_OBJECT_ATTRIBUTES LSA_OBJECT_ATTRIBUTES;

typedef _LSA_OBJECT_ATTRIBUTES TLsaObjectAttributes;

typedef PLSA_OBJECT_ATTRIBUTES PLsaObjectAttributes;

struct _POLICY_ACCOUNT_DOMAIN_INFO;
typedef _POLICY_ACCOUNT_DOMAIN_INFO *PPOLICY_ACCOUNT_DOMAIN_INFO;

struct _POLICY_ACCOUNT_DOMAIN_INFO
{
	
public:
	_LSA_UNICODE_STRING DomainName;
	void *DomainSid;
};


typedef _POLICY_ACCOUNT_DOMAIN_INFO POLICY_ACCOUNT_DOMAIN_INFO;

typedef _POLICY_ACCOUNT_DOMAIN_INFO TPolicyAccountDomainInfo;

typedef PPOLICY_ACCOUNT_DOMAIN_INFO PPolicyAccountDomainInfo;

typedef void * LSA_HANDLE;

typedef void * *PLSA_HANDLE;

typedef void * TLsaHandle;

typedef unsigned NTSTATUS;

//-- var, const, procedure ---------------------------------------------------
static const Byte FPOFLAGS_PROLOG = 0xff;
static const Word FPOFLAGS_REGS = 0x700;
static const Word FPOFLAGS_HAS_SEH = 0x800;
static const Word FPOFLAGS_USE_BP = 0x1000;
static const Word FPOFLAGS_RESERVED = 0x2000;
static const Word FPOFLAGS_FRAME = 0xc000;
static const ShortInt IAHMASK_VALUE = 0x1;
static const Byte IAHMASK_MBZ7 = 0xfe;
static const Word IAHMASK_SHIFT = 0xff00;
static const unsigned IAHMASK_MBZ16 = 0xffff0000;
static const ShortInt IOHFLAGS_TYPE = 0x3;
static const ShortInt IAHFLAGS_NAMETYPE = 0x1c;
static const Word IAHFLAGS_RESERVED = 0xffe0;
#define NetApi32 L"netapi32.dll"
static const ShortInt CSIDL_PROGRAM_FILESX86 = 0x2a;
#define RT_MANIFEST (System::WideChar *)(0x18)
extern PACKAGE unsigned __stdcall (*RtdlSetNamedSecurityInfoW)(System::WideChar * pObjectName, SE_OBJECT_TYPE ObjectType, unsigned SecurityInfo, void * psidOwner, void * psidGroup, PACL pDacl, PACL pSacl);
extern PACKAGE BOOL __stdcall (*RtdlSetWaitableTimer)(unsigned hTimer, __int64 &lpDueTime, int lPeriod, void * pfnCompletionRoutine, void * lpArgToCompletionRoutine, BOOL fResume);
extern PACKAGE unsigned __stdcall (*RtdlNetUserAdd)(System::WideChar * servername, unsigned level, System::PByte buf, PDWORD parm_err);
extern PACKAGE unsigned __stdcall (*RtdlNetUserDel)(System::WideChar * servername, System::WideChar * username);
extern PACKAGE unsigned __stdcall (*RtdlNetGroupAdd)(System::WideChar * servername, unsigned level, System::PByte buf, PDWORD parm_err);
extern PACKAGE unsigned __stdcall (*RtdlNetGroupEnum)(System::WideChar * servername, unsigned level, /* out */ System::PByte &bufptr, unsigned prefmaxlen, /* out */ unsigned &entriesread, /* out */ unsigned &totalentries, PDWORD_PTR resume_handle);
extern PACKAGE unsigned __stdcall (*RtdlNetGroupDel)(System::WideChar * servername, System::WideChar * groupname);
extern PACKAGE unsigned __stdcall (*RtdlNetLocalGroupAdd)(System::WideChar * servername, unsigned level, System::PByte buf, PDWORD parm_err);
extern PACKAGE unsigned __stdcall (*RtdlNetLocalGroupEnum)(System::WideChar * servername, unsigned level, /* out */ System::PByte &bufptr, unsigned prefmaxlen, /* out */ unsigned &entriesread, /* out */ unsigned &totalentries, PDWORD_PTR resumehandle);
extern PACKAGE unsigned __stdcall (*RtdlNetLocalGroupDel)(System::WideChar * servername, System::WideChar * groupname);
extern PACKAGE unsigned __stdcall (*RtdlNetLocalGroupAddMembers)(System::WideChar * servername, System::WideChar * groupname, unsigned level, System::PByte buf, unsigned totalentries);
extern PACKAGE unsigned __stdcall (*RtdlNetApiBufferFree)(void * Buffer);
extern PACKAGE int __stdcall (*RtdlGetCalendarInfoA)(unsigned Locale, unsigned Calendar, unsigned CalType, char * lpCalData, int cchData, PDWORD lpValue);
extern PACKAGE int __stdcall (*RtdlGetCalendarInfoW)(unsigned Locale, unsigned Calendar, unsigned CalType, System::WideChar * lpCalData, int cchData, PDWORD lpValue);
extern PACKAGE BOOL __stdcall (*RtdlEnumCalendarInfoExW)(CALINFO_ENUMPROCEXW lpCalInfoEnumProc, unsigned Locale, unsigned Calendar, unsigned CalType);
extern PACKAGE BOOL __stdcall (*RtdlGetVolumeNameForVolumeMountPointW)(System::WideChar * lpszVolumeMountPoint, System::WideChar * lpszVolumeName, unsigned cchBufferLength);
extern PACKAGE BOOL __stdcall (*RtdlSetVolumeMountPointW)(System::WideChar * lpszVolumeMountPoint, System::WideChar * lpszVolumeName);
extern PACKAGE BOOL __stdcall (*RtdlDeleteVolumeMountPointW)(System::WideChar * lpszVolumeMountPoint);
extern PACKAGE System::Byte __stdcall (*RtdlNetBios)(PNCB P);
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE BOOL __stdcall GlobalMemoryStatusEx(/* out */ _MEMORYSTATUSEX &lpBuffer);
extern PACKAGE BOOL __stdcall IsPwrSuspendAllowed(void);
extern PACKAGE BOOL __stdcall IsPwrHibernateAllowed(void);
extern PACKAGE BOOL __stdcall IsPwrShutdownAllowed(void);
extern PACKAGE BOOL __stdcall SetSuspendState(BOOL Hibernate, BOOL ForceCritical, BOOL DisableWakeEvent);
extern PACKAGE unsigned __stdcall LsaOpenPolicy(PLSA_UNICODE_STRING SystemName, _LSA_OBJECT_ATTRIBUTES &ObjectAttributes, unsigned DesiredAccess, void * &PolicyHandle);
extern PACKAGE unsigned __stdcall LsaQueryInformationPolicy(void * PolicyHandle, _POLICY_INFORMATION_CLASS InformationClass, void * &Buffer);
extern PACKAGE unsigned __stdcall LsaFreeMemory(void * Buffer);
extern PACKAGE unsigned __stdcall LsaFreeReturnBuffer(void * Buffer);
extern PACKAGE unsigned __stdcall LsaClose(void * ObjectHandle);
extern PACKAGE unsigned __stdcall LsaNtStatusToWinError(unsigned Status);

}	/* namespace Jclwin32 */
using namespace Jclwin32;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Jclwin32HPP
