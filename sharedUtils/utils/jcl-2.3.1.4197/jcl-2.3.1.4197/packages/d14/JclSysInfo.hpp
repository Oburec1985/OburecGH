// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclsysinfo.pas' rev: 21.00

#ifndef JclsysinfoHPP
#define JclsysinfoHPP

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
#include <Shlobj.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclresources.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclsysinfo
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TEnvironmentOption { eoLocalMachine, eoCurrentUser, eoAdditional };
#pragma option pop

typedef Set<TEnvironmentOption, eoLocalMachine, eoAdditional>  TEnvironmentOptions;

#pragma option push -b-
enum TAPMLineStatus { alsOffline, alsOnline, alsUnknown };
#pragma option pop

#pragma option push -b-
enum TAPMBatteryFlag { abfHigh, abfLow, abfCritical, abfCharging, abfNoBattery, abfUnknown };
#pragma option pop

typedef Set<TAPMBatteryFlag, abfHigh, abfUnknown>  TAPMBatteryFlags;

#pragma option push -b-
enum TFileSystemFlag { fsCaseSensitive, fsCasePreservedNames, fsSupportsUnicodeOnDisk, fsPersistentACLs, fsSupportsFileCompression, fsSupportsVolumeQuotas, fsSupportsSparseFiles, fsSupportsReparsePoints, fsSupportsRemoteStorage, fsVolumeIsCompressed, fsSupportsObjectIds, fsSupportsEncryption, fsSupportsNamedStreams, fsVolumeIsReadOnly };
#pragma option pop

typedef Set<TFileSystemFlag, fsCaseSensitive, fsVolumeIsReadOnly>  TFileSystemFlags;

#pragma option push -b-
enum TJclTerminateAppResult { taError, taClean, taKill };
#pragma option pop

#pragma option push -b-
enum TWindowsVersion { wvUnknown, wvWin95, wvWin95OSR2, wvWin98, wvWin98SE, wvWinME, wvWinNT31, wvWinNT35, wvWinNT351, wvWinNT4, wvWin2000, wvWinXP, wvWin2003, wvWinXP64, wvWin2003R2, wvWinVista, wvWinServer2008, wvWin7, wvWinServer2008R2 };
#pragma option pop

#pragma option push -b-
enum TWindowsEdition { weUnknown, weWinXPHome, weWinXPPro, weWinXPHomeN, weWinXPProN, weWinXPHomeK, weWinXPProK, weWinXPHomeKN, weWinXPProKN, weWinXPStarter, weWinXPMediaCenter, weWinXPTablet, weWinVistaStarter, weWinVistaHomeBasic, weWinVistaHomeBasicN, weWinVistaHomePremium, weWinVistaBusiness, weWinVistaBusinessN, weWinVistaEnterprise, weWinVistaUltimate, weWin7Starter, weWin7HomeBasic, weWin7HomePremium, weWin7Professional, weWin7Enterprise, weWin7Ultimate };
#pragma option pop

#pragma option push -b-
enum TNtProductType { ptUnknown, ptWorkStation, ptServer, ptAdvancedServer, ptPersonal, ptProfessional, ptDatacenterServer, ptEnterprise, ptWebEdition };
#pragma option pop

#pragma option push -b-
enum TProcessorArchitecture { paUnknown, pax8632, pax8664, paIA64 };
#pragma option pop

#pragma option push -b-
enum TTLBInformation { tiEntries, tiAssociativity };
#pragma option pop

#pragma option push -b-
enum TCacheInformation { ciLineSize, ciLinesPerTag, ciAssociativity, ciSize };
#pragma option pop

struct TIntelSpecific
{
	
public:
	unsigned L2Cache;
	StaticArray<System::Byte, 16> CacheDescriptors;
	System::Byte BrandID;
	System::Byte FlushLineSize;
	System::Byte APICID;
	unsigned ExFeatures;
	unsigned Ex64Features;
	unsigned Ex64Features2;
	unsigned PowerManagementFeatures;
	System::Byte PhysicalAddressBits;
	System::Byte VirtualAddressBits;
};


struct TCyrixSpecific
{
	
public:
	StaticArray<System::Byte, 4> L1CacheInfo;
	StaticArray<System::Byte, 4> TLBInfo;
};


#pragma pack(push,1)
struct TAMDSpecific
{
	
public:
	unsigned ExFeatures;
	unsigned ExFeatures2;
	unsigned Features2;
	System::Byte BrandID;
	System::Byte FlushLineSize;
	System::Byte APICID;
	System::Word ExBrandID;
	StaticArray<System::Byte, 2> L1MByteInstructionTLB;
	StaticArray<System::Byte, 2> L1MByteDataTLB;
	StaticArray<System::Byte, 2> L1KByteInstructionTLB;
	StaticArray<System::Byte, 2> L1KByteDataTLB;
	StaticArray<System::Byte, 4> L1DataCache;
	StaticArray<System::Byte, 4> L1InstructionCache;
	StaticArray<System::Byte, 2> L2MByteInstructionTLB;
	StaticArray<System::Byte, 2> L2MByteDataTLB;
	StaticArray<System::Byte, 2> L2KByteDataTLB;
	StaticArray<System::Byte, 2> L2KByteInstructionTLB;
	unsigned L2Cache;
	unsigned L3Cache;
	unsigned AdvancedPowerManagement;
	System::Byte PhysicalAddressSize;
	System::Byte VirtualAddressSize;
};
#pragma pack(pop)


struct TVIASpecific
{
	
public:
	unsigned ExFeatures;
	StaticArray<System::Byte, 2> DataTLB;
	StaticArray<System::Byte, 2> InstructionTLB;
	StaticArray<System::Byte, 4> L1DataCache;
	StaticArray<System::Byte, 4> L1InstructionCache;
	unsigned L2DataCache;
};


struct TTransmetaSpecific
{
	
public:
	unsigned ExFeatures;
	StaticArray<System::Byte, 2> DataTLB;
	StaticArray<System::Byte, 2> CodeTLB;
	StaticArray<System::Byte, 4> L1DataCache;
	StaticArray<System::Byte, 4> L1CodeCache;
	unsigned L2Cache;
	unsigned RevisionABCD;
	unsigned RevisionXXXX;
	unsigned Frequency;
	unsigned CodeMorphingABCD;
	unsigned CodeMorphingXXXX;
	unsigned TransmetaFeatures;
	StaticArray<System::WideChar, 65> TransmetaInformations;
	unsigned CurrentVoltage;
	unsigned CurrentFrequency;
	unsigned CurrentPerformance;
};


#pragma option push -b-
enum TCacheFamily { cfInstructionTLB, cfDataTLB, cfL1InstructionCache, cfL1DataCache, cfL2Cache, cfL2TLB, cfL3Cache, cfTrace, cfOther };
#pragma option pop

struct TCacheInfo
{
	
public:
	System::Byte D;
	TCacheFamily Family;
	unsigned Size;
	System::Byte WaysOfAssoc;
	System::Byte LineSize;
	System::Byte LinePerSector;
	unsigned Entries;
	System::TResStringRec *I;
};


struct TFreqInfo
{
	
public:
	__int64 RawFreq;
	__int64 NormFreq;
	__int64 InCycles;
	__int64 ExTicks;
};


#pragma option push -b-
enum TSSESupport { sse, sse2, sse3, ssse3, sse41, sse42, sse4A, sse5, avx };
#pragma option pop

typedef Set<TSSESupport, sse, avx>  TSSESupports;

struct TCpuInfo
{
	
public:
	bool HasInstruction;
	bool AES;
	bool MMX;
	bool ExMMX;
	bool _3DNow;
	bool Ex3DNow;
	TSSESupports SSE;
	bool IsFDIVOK;
	bool Is64Bits;
	bool DEPCapable;
	bool HasCacheInfo;
	bool HasExtendedInfo;
	System::Byte PType;
	System::Byte Family;
	System::Byte ExtendedFamily;
	System::Byte Model;
	System::Byte ExtendedModel;
	System::Byte Stepping;
	unsigned Features;
	TFreqInfo FrequencyInfo;
	StaticArray<char, 12> VendorIDString;
	StaticArray<char, 10> Manufacturer;
	StaticArray<char, 48> CpuName;
	unsigned L1DataCacheSize;
	System::Byte L1DataCacheLineSize;
	System::Byte L1DataCacheAssociativity;
	unsigned L1InstructionCacheSize;
	System::Byte L1InstructionCacheLineSize;
	System::Byte L1InstructionCacheAssociativity;
	unsigned L2CacheSize;
	System::Byte L2CacheLineSize;
	System::Byte L2CacheAssociativity;
	unsigned L3CacheSize;
	System::Byte L3CacheLineSize;
	System::Byte L3CacheAssociativity;
	System::Byte L3LinesPerSector;
	System::Byte LogicalCore;
	System::Byte PhysicalCore;
	bool HyperThreadingTechnology;
	bool HardwareHyperThreadingTechnology;
	#pragma pack(push,1)
	
private:
	unsigned:8;
	
public:
	System::Byte CpuType;
	union
	{
		struct 
		{
			unsigned:24;
			TVIASpecific ViaSpecific;
			
		};
		struct 
		{
			unsigned:24;
			TTransmetaSpecific TransmetaSpecific;
			
		};
		struct 
		{
			TAMDSpecific AMDSpecific;
			
		};
		struct 
		{
			TCyrixSpecific CyrixSpecific;
			
		};
		struct 
		{
			unsigned:24;
			TIntelSpecific IntelSpecific;
			
		};
		
	};
	#pragma pack(pop)
};


#pragma option push -b-
enum TOSEnabledFeature { oefFPU, oefSSE, oefAVX };
#pragma option pop

typedef Set<TOSEnabledFeature, oefFPU, oefAVX>  TOSEnabledFeatures;

#pragma option push -b-
enum TFreeSysResKind { rtSystem, rtGdi, rtUser };
#pragma option pop

struct TFreeSystemResources
{
	
public:
	int SystemRes;
	int GdiRes;
	int UserRes;
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE bool IsWin95;
extern PACKAGE bool IsWin95OSR2;
extern PACKAGE bool IsWin98;
extern PACKAGE bool IsWin98SE;
extern PACKAGE bool IsWinME;
extern PACKAGE bool IsWinNT;
extern PACKAGE bool IsWinNT3;
extern PACKAGE bool IsWinNT31;
extern PACKAGE bool IsWinNT35;
extern PACKAGE bool IsWinNT351;
extern PACKAGE bool IsWinNT4;
extern PACKAGE bool IsWin2K;
extern PACKAGE bool IsWinXP;
extern PACKAGE bool IsWin2003;
extern PACKAGE bool IsWinXP64;
extern PACKAGE bool IsWin2003R2;
extern PACKAGE bool IsWinVista;
extern PACKAGE bool IsWinServer2008;
extern PACKAGE bool IsWin7;
extern PACKAGE bool IsWinServer2008R2;
static const ShortInt CPU_TYPE_INTEL = 0x1;
static const ShortInt CPU_TYPE_CYRIX = 0x2;
static const ShortInt CPU_TYPE_AMD = 0x3;
static const ShortInt CPU_TYPE_TRANSMETA = 0x4;
static const ShortInt CPU_TYPE_VIA = 0x5;
extern PACKAGE StaticArray<char, 12> VendorIDIntel;
extern PACKAGE StaticArray<char, 12> VendorIDCyrix;
extern PACKAGE StaticArray<char, 12> VendorIDAMD;
extern PACKAGE StaticArray<char, 12> VendorIDTransmeta;
extern PACKAGE StaticArray<char, 12> VendorIDVIA;
static const ShortInt BIT_0 = 0x1;
static const ShortInt BIT_1 = 0x2;
static const ShortInt BIT_2 = 0x4;
static const ShortInt BIT_3 = 0x8;
static const ShortInt BIT_4 = 0x10;
static const ShortInt BIT_5 = 0x20;
static const ShortInt BIT_6 = 0x40;
static const Byte BIT_7 = 0x80;
static const Word BIT_8 = 0x100;
static const Word BIT_9 = 0x200;
static const Word BIT_10 = 0x400;
static const Word BIT_11 = 0x800;
static const Word BIT_12 = 0x1000;
static const Word BIT_13 = 0x2000;
static const Word BIT_14 = 0x4000;
static const Word BIT_15 = 0x8000;
static const int BIT_16 = 0x10000;
static const int BIT_17 = 0x20000;
static const int BIT_18 = 0x40000;
static const int BIT_19 = 0x80000;
static const int BIT_20 = 0x100000;
static const int BIT_21 = 0x200000;
static const int BIT_22 = 0x400000;
static const int BIT_23 = 0x800000;
static const int BIT_24 = 0x1000000;
static const int BIT_25 = 0x2000000;
static const int BIT_26 = 0x4000000;
static const int BIT_27 = 0x8000000;
static const int BIT_28 = 0x10000000;
static const int BIT_29 = 0x20000000;
static const int BIT_30 = 0x40000000;
static const unsigned BIT_31 = 0x80000000;
static const ShortInt FPU_FLAG = 0x1;
static const ShortInt VME_FLAG = 0x2;
static const ShortInt DE_FLAG = 0x4;
static const ShortInt PSE_FLAG = 0x8;
static const ShortInt TSC_FLAG = 0x10;
static const ShortInt MSR_FLAG = 0x20;
static const ShortInt PAE_FLAG = 0x40;
static const Byte MCE_FLAG = 0x80;
static const Word CX8_FLAG = 0x100;
static const Word APIC_FLAG = 0x200;
static const Word BIT_10_FLAG = 0x400;
static const Word SEP_FLAG = 0x800;
static const Word MTRR_FLAG = 0x1000;
static const Word PGE_FLAG = 0x2000;
static const Word MCA_FLAG = 0x4000;
static const Word CMOV_FLAG = 0x8000;
static const int PAT_FLAG = 0x10000;
static const int PSE36_FLAG = 0x20000;
static const int PSN_FLAG = 0x40000;
static const int CLFLSH_FLAG = 0x80000;
static const int BIT_20_FLAG = 0x100000;
static const int DS_FLAG = 0x200000;
static const int ACPI_FLAG = 0x400000;
static const int MMX_FLAG = 0x800000;
static const int FXSR_FLAG = 0x1000000;
static const int SSE_FLAG = 0x2000000;
static const int SSE2_FLAG = 0x4000000;
static const int SS_FLAG = 0x8000000;
static const int HTT_FLAG = 0x10000000;
static const int TM_FLAG = 0x20000000;
static const int BIT_30_FLAG = 0x40000000;
static const unsigned PBE_FLAG = 0x80000000;
static const ShortInt INTEL_FPU = 0x1;
static const ShortInt INTEL_VME = 0x2;
static const ShortInt INTEL_DE = 0x4;
static const ShortInt INTEL_PSE = 0x8;
static const ShortInt INTEL_TSC = 0x10;
static const ShortInt INTEL_MSR = 0x20;
static const ShortInt INTEL_PAE = 0x40;
static const Byte INTEL_MCE = 0x80;
static const Word INTEL_CX8 = 0x100;
static const Word INTEL_APIC = 0x200;
static const Word INTEL_BIT_10 = 0x400;
static const Word INTEL_SEP = 0x800;
static const Word INTEL_MTRR = 0x1000;
static const Word INTEL_PGE = 0x2000;
static const Word INTEL_MCA = 0x4000;
static const Word INTEL_CMOV = 0x8000;
static const int INTEL_PAT = 0x10000;
static const int INTEL_PSE36 = 0x20000;
static const int INTEL_PSN = 0x40000;
static const int INTEL_CLFLSH = 0x80000;
static const int INTEL_BIT_20 = 0x100000;
static const int INTEL_DS = 0x200000;
static const int INTEL_ACPI = 0x400000;
static const int INTEL_MMX = 0x800000;
static const int INTEL_FXSR = 0x1000000;
static const int INTEL_SSE = 0x2000000;
static const int INTEL_SSE2 = 0x4000000;
static const int INTEL_SS = 0x8000000;
static const int INTEL_HTT = 0x10000000;
static const int INTEL_TM = 0x20000000;
static const int INTEL_IA64 = 0x40000000;
static const unsigned INTEL_PBE = 0x80000000;
static const ShortInt EINTEL_SSE3 = 0x1;
static const ShortInt EINTEL_PCLMULQDQ = 0x2;
static const ShortInt EINTEL_DTES64 = 0x4;
static const ShortInt EINTEL_MONITOR = 0x8;
static const ShortInt EINTEL_DSCPL = 0x10;
static const ShortInt EINTEL_VMX = 0x20;
static const ShortInt EINTEL_SMX = 0x40;
static const Byte EINTEL_EST = 0x80;
static const Word EINTEL_TM2 = 0x100;
static const Word EINTEL_SSSE3 = 0x200;
static const Word EINTEL_CNXTID = 0x400;
static const Word EINTEL_BIT_11 = 0x800;
static const Word EINTEL_FMA = 0x1000;
static const Word EINTEL_CX16 = 0x2000;
static const Word EINTEL_XTPR = 0x4000;
static const Word EINTEL_PDCM = 0x8000;
static const int EINTEL_BIT_16 = 0x10000;
static const int EINTEL_PCID = 0x20000;
static const int EINTEL_DCA = 0x40000;
static const int EINTEL_SSE4_1 = 0x80000;
static const int EINTEL_SSE4_2 = 0x100000;
static const int EINTEL_X2APIC = 0x200000;
static const int EINTEL_MOVBE = 0x400000;
static const int EINTEL_POPCNT = 0x800000;
static const int EINTEL_TSC_DL = 0x1000000;
static const int EINTEL_AES = 0x2000000;
static const int EINTEL_XSAVE = 0x4000000;
static const int EINTEL_OSXSAVE = 0x8000000;
static const int EINTEL_AVX = 0x10000000;
static const int EINTEL_BIT_29 = 0x20000000;
static const int EINTEL_BIT_30 = 0x40000000;
static const unsigned EINTEL_BIT_31 = 0x80000000;
static const ShortInt EINTEL64_BIT_0 = 0x1;
static const ShortInt EINTEL64_BIT_1 = 0x2;
static const ShortInt EINTEL64_BIT_2 = 0x4;
static const ShortInt EINTEL64_BIT_3 = 0x8;
static const ShortInt EINTEL64_BIT_4 = 0x10;
static const ShortInt EINTEL64_BIT_5 = 0x20;
static const ShortInt EINTEL64_BIT_6 = 0x40;
static const Byte EINTEL64_BIT_7 = 0x80;
static const Word EINTEL64_BIT_8 = 0x100;
static const Word EINTEL64_BIT_9 = 0x200;
static const Word EINTEL64_BIT_10 = 0x400;
static const Word EINTEL64_SYS = 0x800;
static const Word EINTEL64_BIT_12 = 0x1000;
static const Word EINTEL64_BIT_13 = 0x2000;
static const Word EINTEL64_BIT_14 = 0x4000;
static const Word EINTEL64_BIT_15 = 0x8000;
static const int EINTEL64_BIT_16 = 0x10000;
static const int EINTEL64_BIT_17 = 0x20000;
static const int EINTEL64_BIT_18 = 0x40000;
static const int EINTEL64_BIT_19 = 0x80000;
static const int EINTEL64_XD = 0x100000;
static const int EINTEL64_BIT_21 = 0x200000;
static const int EINTEL64_BIT_22 = 0x400000;
static const int EINTEL64_BIT_23 = 0x800000;
static const int EINTEL64_BIT_24 = 0x1000000;
static const int EINTEL64_BIT_25 = 0x2000000;
static const int EINTEL64_1GBYTE = 0x4000000;
static const int EINTEL64_RDTSCP = 0x8000000;
static const int EINTEL64_BIT_28 = 0x10000000;
static const int EINTEL64_EM64T = 0x20000000;
static const int EINTEL64_BIT_30 = 0x40000000;
static const unsigned EINTEL64_BIT_31 = 0x80000000;
static const ShortInt EINTEL64_2_LAHF = 0x1;
static const ShortInt EINTEL64_2_BIT_1 = 0x2;
static const ShortInt EINTEL64_2_BIT_2 = 0x4;
static const ShortInt EINTEL64_2_BIT_3 = 0x8;
static const ShortInt EINTEL64_2_BIT_4 = 0x10;
static const ShortInt EINTEL64_2_BIT_5 = 0x20;
static const ShortInt EINTEL64_2_BIT_6 = 0x40;
static const Byte EINTEL64_2_BIT_7 = 0x80;
static const Word EINTEL64_2_BIT_8 = 0x100;
static const Word EINTEL64_2_BIT_9 = 0x200;
static const Word EINTEL64_2_BIT_10 = 0x400;
static const Word EINTEL64_2_BIT_11 = 0x800;
static const Word EINTEL64_2_BIT_12 = 0x1000;
static const Word EINTEL64_2_BIT_13 = 0x2000;
static const Word EINTEL64_2_BIT_14 = 0x4000;
static const Word EINTEL64_2_BIT_15 = 0x8000;
static const int EINTEL64_2_BIT_16 = 0x10000;
static const int EINTEL64_2_BIT_17 = 0x20000;
static const int EINTEL64_2_BIT_18 = 0x40000;
static const int EINTEL64_2_BIT_19 = 0x80000;
static const int EINTEL64_2_BIT_20 = 0x100000;
static const int EINTEL64_2_BIT_21 = 0x200000;
static const int EINTEL64_2_BIT_22 = 0x400000;
static const int EINTEL64_2_BIT_23 = 0x800000;
static const int EINTEL64_2_BIT_24 = 0x1000000;
static const int EINTEL64_2_BIT_25 = 0x2000000;
static const int EINTEL64_2_BIT_26 = 0x4000000;
static const int EINTEL64_2_BIT_27 = 0x8000000;
static const int EINTEL64_2_BIT_28 = 0x10000000;
static const int EINTEL64_2_BIT_29 = 0x20000000;
static const int EINTEL64_2_BIT_30 = 0x40000000;
static const unsigned EINTEL64_2_BIT_31 = 0x80000000;
static const ShortInt PINTEL_TEMPSENSOR = 0x1;
static const ShortInt PINTEL_TURBOBOOST = 0x2;
static const ShortInt PINTEL_ARAT = 0x4;
static const ShortInt PINTEL_BIT_3 = 0x8;
static const ShortInt PINTEL_PLN = 0x10;
static const ShortInt PINTEL_ECMD = 0x20;
static const ShortInt PINTEL_PTM = 0x40;
static const Byte PINTEL_BIT_7 = 0x80;
static const Word PINTEL_BIT_8 = 0x100;
static const Word PINTEL_BIT_9 = 0x200;
static const Word PINTEL_BIT_10 = 0x400;
static const Word PINTEL_BIT_11 = 0x800;
static const Word PINTEL_BIT_12 = 0x1000;
static const Word PINTEL_BIT_13 = 0x2000;
static const Word PINTEL_BIT_14 = 0x4000;
static const Word PINTEL_BIT_15 = 0x8000;
static const int PINTEL_BIT_16 = 0x10000;
static const int PINTEL_BIT_17 = 0x20000;
static const int PINTEL_BIT_18 = 0x40000;
static const int PINTEL_BIT_19 = 0x80000;
static const int PINTEL_BIT_20 = 0x100000;
static const int PINTEL_BIT_21 = 0x200000;
static const int PINTEL_BIT_22 = 0x400000;
static const int PINTEL_BIT_23 = 0x800000;
static const int PINTEL_BIT_24 = 0x1000000;
static const int PINTEL_BIT_25 = 0x2000000;
static const int PINTEL_BIT_26 = 0x4000000;
static const int PINTEL_BIT_27 = 0x8000000;
static const int PINTEL_BIT_28 = 0x10000000;
static const int PINTEL_BIT_29 = 0x20000000;
static const int PINTEL_BIT_30 = 0x40000000;
static const unsigned PINTEL_BIT_31 = 0x80000000;
static const ShortInt AMD_FPU = 0x1;
static const ShortInt AMD_VME = 0x2;
static const ShortInt AMD_DE = 0x4;
static const ShortInt AMD_PSE = 0x8;
static const ShortInt AMD_TSC = 0x10;
static const ShortInt AMD_MSR = 0x20;
static const ShortInt AMD_PAE = 0x40;
static const Byte AMD_MCE = 0x80;
static const Word AMD_CX8 = 0x100;
static const Word AMD_APIC = 0x200;
static const Word AMD_BIT_10 = 0x400;
static const Word AMD_SEP_BIT = 0x800;
static const Word AMD_MTRR = 0x1000;
static const Word AMD_PGE = 0x2000;
static const Word AMD_MCA = 0x4000;
static const Word AMD_CMOV = 0x8000;
static const int AMD_PAT = 0x10000;
static const int AMD_PSE36 = 0x20000;
static const int AMD_BIT_18 = 0x40000;
static const int AMD_CLFLSH = 0x80000;
static const int AMD_BIT_20 = 0x100000;
static const int AMD_BIT_21 = 0x200000;
static const int AMD_BIT_22 = 0x400000;
static const int AMD_MMX = 0x800000;
static const int AMD_FXSR = 0x1000000;
static const int AMD_SSE = 0x2000000;
static const int AMD_SSE2 = 0x4000000;
static const int AMD_BIT_27 = 0x8000000;
static const int AMD_HTT = 0x10000000;
static const int AMD_BIT_29 = 0x20000000;
static const int AMD_BIT_30 = 0x40000000;
static const unsigned AMD_BIT_31 = 0x80000000;
static const ShortInt AMD2_SSE3 = 0x1;
static const ShortInt AMD2_PCLMULQDQ = 0x2;
static const ShortInt AMD2_BIT_2 = 0x4;
static const ShortInt AMD2_MONITOR = 0x8;
static const ShortInt AMD2_BIT_4 = 0x10;
static const ShortInt AMD2_BIT_5 = 0x20;
static const ShortInt AMD2_BIT_6 = 0x40;
static const Byte AMD2_BIT_7 = 0x80;
static const Word AMD2_BIT_8 = 0x100;
static const Word AMD2_SSSE3 = 0x200;
static const Word AMD2_BIT_10 = 0x400;
static const Word AMD2_BIT_11 = 0x800;
static const Word AMD2_FMA = 0x1000;
static const Word AMD2_CMPXCHG16B = 0x2000;
static const Word AMD2_BIT_14 = 0x4000;
static const Word AMD2_BIT_15 = 0x8000;
static const int AMD2_BIT_16 = 0x10000;
static const int AMD2_BIT_17 = 0x20000;
static const int AMD2_BIT_18 = 0x40000;
static const int AMD2_SSE41 = 0x80000;
static const int AMD2_SSE42 = 0x100000;
static const int AMD2_BIT_21 = 0x200000;
static const int AMD2_BIT_22 = 0x400000;
static const int AMD2_POPCNT = 0x800000;
static const int AMD2_BIT_24 = 0x1000000;
static const int AMD2_AES = 0x2000000;
static const int AMD2_XSAVE = 0x4000000;
static const int AMD2_OSXSAVE = 0x8000000;
static const int AMD2_AVX = 0x10000000;
static const int AMD2_F16C = 0x20000000;
static const int AMD2_BIT_30 = 0x40000000;
static const unsigned AMD2_RAZ = 0x80000000;
static const ShortInt EAMD_FPU = 0x1;
static const ShortInt EAMD_VME = 0x2;
static const ShortInt EAMD_DE = 0x4;
static const ShortInt EAMD_PSE = 0x8;
static const ShortInt EAMD_TSC = 0x10;
static const ShortInt EAMD_MSR = 0x20;
static const ShortInt EAMD_PAE = 0x40;
static const Byte EAMD_MCE = 0x80;
static const Word EAMD_CX8 = 0x100;
static const Word EAMD_APIC = 0x200;
static const Word EAMD_BIT_10 = 0x400;
static const Word EAMD_SEP = 0x800;
static const Word EAMD_MTRR = 0x1000;
static const Word EAMD_PGE = 0x2000;
static const Word EAMD_MCA = 0x4000;
static const Word EAMD_CMOV = 0x8000;
static const int EAMD_PAT = 0x10000;
static const int EAMD_PSE2 = 0x20000;
static const int EAMD_BIT_18 = 0x40000;
static const int EAMD_BIT_19 = 0x80000;
static const int EAMD_NX = 0x100000;
static const int EAMD_BIT_21 = 0x200000;
static const int EAMD_EXMMX = 0x400000;
static const int EAMD_MMX = 0x800000;
static const int EAMD_FX = 0x1000000;
static const int EAMD_FFX = 0x2000000;
static const int EAMD_1GBPAGE = 0x4000000;
static const int EAMD_RDTSCP = 0x8000000;
static const int EAMD_BIT_28 = 0x10000000;
static const int EAMD_LONG = 0x20000000;
static const int EAMD_EX3DNOW = 0x40000000;
static const unsigned EAMD_3DNOW = 0x80000000;
static const ShortInt EAMD2_LAHF = 0x1;
static const ShortInt EAMD2_CMPLEGACY = 0x2;
static const ShortInt EAMD2_SVM = 0x4;
static const ShortInt EAMD2_EXTAPICSPACE = 0x8;
static const ShortInt EAMD2_ALTMOVCR8 = 0x10;
static const ShortInt EAMD2_ABM = 0x20;
static const ShortInt EAMD2_SSE4A = 0x40;
static const Byte EAMD2_MISALIGNSSE = 0x80;
static const Word EAMD2_3DNOWPREFETCH = 0x100;
static const Word EAMD2_OSVW = 0x200;
static const Word EAMD2_IBS = 0x400;
static const Word EAMD2_XOP = 0x800;
static const Word EAMD2_SKINIT = 0x1000;
static const Word EAMD2_WDT = 0x2000;
static const Word EAMD2_BIT_14 = 0x4000;
static const Word EAMD2_LWP = 0x8000;
static const int EAMD2_FMA4 = 0x10000;
static const int EAMD2_BIT_17 = 0x20000;
static const int EAMD2_BIT_18 = 0x40000;
static const int EAMD2_NODEID = 0x80000;
static const int EAMD2_BIT_20 = 0x100000;
static const int EAMD2_TBM = 0x200000;
static const int EAMD2_TOPOLOGYEXT = 0x400000;
static const int EAMD2_BIT_23 = 0x800000;
static const int EAMD2_BIT_24 = 0x1000000;
static const int EAMD2_BIT_25 = 0x2000000;
static const int EAMD2_BIT_26 = 0x4000000;
static const int EAMD2_BIT_27 = 0x8000000;
static const int EAMD2_BIT_28 = 0x10000000;
static const int EAMD2_BIT_29 = 0x20000000;
static const int EAMD2_BIT_30 = 0x40000000;
static const unsigned EAMD2_BIT_31 = 0x80000000;
static const ShortInt PAMD_TEMPSENSOR = 0x1;
static const ShortInt PAMD_FREQUENCYID = 0x2;
static const ShortInt PAMD_VOLTAGEID = 0x4;
static const ShortInt PAMD_THERMALTRIP = 0x8;
static const ShortInt PAMD_THERMALMONITOR = 0x10;
static const ShortInt PAMD_BIT_5 = 0x20;
static const ShortInt PAMD_100MHZSTEP = 0x40;
static const Byte PAMD_HWPSTATE = 0x80;
static const Word PAMD_TSC_INVARIANT = 0x100;
static const Word PAMD_CPB = 0x200;
static const Word PAMD_EFFFREQRO = 0x400;
static const Word PAMD_BIT_11 = 0x800;
static const Word PAMD_BIT_12 = 0x1000;
static const Word PAMD_BIT_13 = 0x2000;
static const Word PAMD_BIT_14 = 0x4000;
static const Word PAMD_BIT_15 = 0x8000;
static const int PAMD_BIT_16 = 0x10000;
static const int PAMD_BIT_17 = 0x20000;
static const int PAMD_BIT_18 = 0x40000;
static const int PAMD_BIT_19 = 0x80000;
static const int PAMD_BIT_20 = 0x100000;
static const int PAMD_BIT_21 = 0x200000;
static const int PAMD_BIT_22 = 0x400000;
static const int PAMD_BIT_23 = 0x800000;
static const int PAMD_BIT_24 = 0x1000000;
static const int PAMD_BIT_25 = 0x2000000;
static const int PAMD_BIT_26 = 0x4000000;
static const int PAMD_BIT_27 = 0x8000000;
static const int PAMD_BIT_28 = 0x10000000;
static const int PAMD_BIT_29 = 0x20000000;
static const int PAMD_BIT_30 = 0x40000000;
static const unsigned PAMD_BIT_31 = 0x80000000;
static const ShortInt AMD_ASSOC_RESERVED = 0x0;
static const ShortInt AMD_ASSOC_DIRECT = 0x1;
static const Byte AMD_ASSOC_FULLY = 0xff;
static const ShortInt AMD_L2_ASSOC_DISABLED = 0x0;
static const ShortInt AMD_L2_ASSOC_DIRECT = 0x1;
static const ShortInt AMD_L2_ASSOC_2WAY = 0x2;
static const ShortInt AMD_L2_ASSOC_4WAY = 0x4;
static const ShortInt AMD_L2_ASSOC_8WAY = 0x6;
static const ShortInt AMD_L2_ASSOC_16WAY = 0x8;
static const ShortInt AMD_L2_ASSOC_32WAY = 0xa;
static const ShortInt AMD_L2_ASSOC_48WAY = 0xb;
static const ShortInt AMD_L2_ASSOC_64WAY = 0xc;
static const ShortInt AMD_L2_ASSOC_96WAY = 0xd;
static const ShortInt AMD_L2_ASSOC_128WAY = 0xe;
static const ShortInt AMD_L2_ASSOC_FULLY = 0xf;
static const ShortInt VIA_FPU = 0x1;
static const ShortInt VIA_VME = 0x2;
static const ShortInt VIA_DE = 0x4;
static const ShortInt VIA_PSE = 0x8;
static const ShortInt VIA_TSC = 0x10;
static const ShortInt VIA_MSR = 0x20;
static const ShortInt VIA_PAE = 0x40;
static const Byte VIA_MCE = 0x80;
static const Word VIA_CX8 = 0x100;
static const Word VIA_APIC = 0x200;
static const Word VIA_BIT_10 = 0x400;
static const Word VIA_SEP = 0x800;
static const Word VIA_MTRR = 0x1000;
static const Word VIA_PTE = 0x2000;
static const Word VIA_MCA = 0x4000;
static const Word VIA_CMOVE = 0x8000;
static const int VIA_PAT = 0x10000;
static const int VIA_PSE2 = 0x20000;
static const int VIA_SNUM = 0x40000;
static const int VIA_BIT_19 = 0x80000;
static const int VIA_BIT_20 = 0x100000;
static const int VIA_BIT_21 = 0x200000;
static const int VIA_BIT_22 = 0x400000;
static const int VIA_MMX = 0x800000;
static const int VIA_FX = 0x1000000;
static const int VIA_SSE = 0x2000000;
static const int VIA_BIT_26 = 0x4000000;
static const int VIA_BIT_27 = 0x8000000;
static const int VIA_BIT_28 = 0x10000000;
static const int VIA_BIT_29 = 0x20000000;
static const int VIA_BIT_30 = 0x40000000;
static const unsigned VIA_3DNOW = 0x80000000;
static const ShortInt EVIA_AIS = 0x1;
static const ShortInt EVIA_AISE = 0x2;
static const ShortInt EVIA_NO_RNG = 0x4;
static const ShortInt EVIA_RNGE = 0x8;
static const ShortInt EVIA_MSR = 0x10;
static const ShortInt EVIA_FEMMS = 0x20;
static const ShortInt EVIA_NO_ACE = 0x40;
static const Byte EVIA_ACEE = 0x80;
static const Word EVIA_BIT_8 = 0x100;
static const Word EVIA_BIT_9 = 0x200;
static const Word EVIA_BIT_10 = 0x400;
static const Word EVIA_BIT_11 = 0x800;
static const Word EVIA_BIT_12 = 0x1000;
static const Word EVIA_BIT_13 = 0x2000;
static const Word EVIA_BIT_14 = 0x4000;
static const Word EVIA_BIT_15 = 0x8000;
static const int EVIA_BIT_16 = 0x10000;
static const int EVIA_BIT_17 = 0x20000;
static const int EVIA_BIT_18 = 0x40000;
static const int EVIA_BIT_19 = 0x80000;
static const int EVIA_BIT_20 = 0x100000;
static const int EVIA_BIT_21 = 0x200000;
static const int EVIA_BIT_22 = 0x400000;
static const int EVIA_BIT_23 = 0x800000;
static const int EVIA_BIT_24 = 0x1000000;
static const int EVIA_BIT_25 = 0x2000000;
static const int EVIA_BIT_26 = 0x4000000;
static const int EVIA_BIT_27 = 0x8000000;
static const int EVIA_BIT_28 = 0x10000000;
static const int EVIA_BIT_29 = 0x20000000;
static const int EVIA_BIT_30 = 0x40000000;
static const unsigned EVIA_BIT_31 = 0x80000000;
static const ShortInt CYRIX_FPU = 0x1;
static const ShortInt CYRIX_VME = 0x2;
static const ShortInt CYRIX_DE = 0x4;
static const ShortInt CYRIX_PSE = 0x8;
static const ShortInt CYRIX_TSC = 0x10;
static const ShortInt CYRIX_MSR = 0x20;
static const ShortInt CYRIX_PAE = 0x40;
static const Byte CYRIX_MCE = 0x80;
static const Word CYRIX_CX8 = 0x100;
static const Word CYRIX_APIC = 0x200;
static const Word CYRIX_BIT_10 = 0x400;
static const Word CYRIX_BIT_11 = 0x800;
static const Word CYRIX_MTRR = 0x1000;
static const Word CYRIX_PGE = 0x2000;
static const Word CYRIX_MCA = 0x4000;
static const Word CYRIX_CMOV = 0x8000;
static const int CYRIX_BIT_16 = 0x10000;
static const int CYRIX_BIT_17 = 0x20000;
static const int CYRIX_BIT_18 = 0x40000;
static const int CYRIX_BIT_19 = 0x80000;
static const int CYRIX_BIT_20 = 0x100000;
static const int CYRIX_BIT_21 = 0x200000;
static const int CYRIX_BIT_22 = 0x400000;
static const int CYRIX_MMX = 0x800000;
static const int CYRIX_BIT_24 = 0x1000000;
static const int CYRIX_BIT_25 = 0x2000000;
static const int CYRIX_BIT_26 = 0x4000000;
static const int CYRIX_BIT_27 = 0x8000000;
static const int CYRIX_BIT_28 = 0x10000000;
static const int CYRIX_BIT_29 = 0x20000000;
static const int CYRIX_BIT_30 = 0x40000000;
static const unsigned CYRIX_BIT_31 = 0x80000000;
static const ShortInt ECYRIX_FPU = 0x1;
static const ShortInt ECYRIX_VME = 0x2;
static const ShortInt ECYRIX_DE = 0x4;
static const ShortInt ECYRIX_PSE = 0x8;
static const ShortInt ECYRIX_TSC = 0x10;
static const ShortInt ECYRIX_MSR = 0x20;
static const ShortInt ECYRIX_PAE = 0x40;
static const Byte ECYRIX_MCE = 0x80;
static const Word ECYRIX_CX8 = 0x100;
static const Word ECYRIX_APIC = 0x200;
static const Word ECYRIX_SEP = 0x400;
static const Word ECYRIX_BIT_11 = 0x800;
static const Word ECYRIX_MTRR = 0x1000;
static const Word ECYRIX_PGE = 0x2000;
static const Word ECYRIX_MCA = 0x4000;
static const Word ECYRIX_ICMOV = 0x8000;
static const int ECYRIX_FCMOV = 0x10000;
static const int ECYRIX_BIT_17 = 0x20000;
static const int ECYRIX_BIT_18 = 0x40000;
static const int ECYRIX_BIT_19 = 0x80000;
static const int ECYRIX_BIT_20 = 0x100000;
static const int ECYRIX_BIT_21 = 0x200000;
static const int ECYRIX_BIT_22 = 0x400000;
static const int ECYRIX_MMX = 0x800000;
static const int ECYRIX_EMMX = 0x1000000;
static const int ECYRIX_BIT_25 = 0x2000000;
static const int ECYRIX_BIT_26 = 0x4000000;
static const int ECYRIX_BIT_27 = 0x8000000;
static const int ECYRIX_BIT_28 = 0x10000000;
static const int ECYRIX_BIT_29 = 0x20000000;
static const int ECYRIX_BIT_30 = 0x40000000;
static const unsigned ECYRIX_BIT_31 = 0x80000000;
static const ShortInt TRANSMETA_FPU = 0x1;
static const ShortInt TRANSMETA_VME = 0x2;
static const ShortInt TRANSMETA_DE = 0x4;
static const ShortInt TRANSMETA_PSE = 0x8;
static const ShortInt TRANSMETA_TSC = 0x10;
static const ShortInt TRANSMETA_MSR = 0x20;
static const ShortInt TRANSMETA_BIT_6 = 0x40;
static const Byte TRANSMETA_BIT_7 = 0x80;
static const Word TRANSMETA_CX8 = 0x100;
static const Word TRANSMETA_BIT_9 = 0x200;
static const Word TRANSMETA_BIT_10 = 0x400;
static const Word TRANSMETA_SEP = 0x800;
static const Word TRANSMETA_BIT_12 = 0x1000;
static const Word TRANSMETA_BIT_13 = 0x2000;
static const Word TRANSMETA_BIT_14 = 0x4000;
static const Word TRANSMETA_CMOV = 0x8000;
static const int TRANSMETA_BIT_16 = 0x10000;
static const int TRANSMETA_BIT_17 = 0x20000;
static const int TRANSMETA_PSN = 0x40000;
static const int TRANSMETA_BIT_19 = 0x80000;
static const int TRANSMETA_BIT_20 = 0x100000;
static const int TRANSMETA_BIT_21 = 0x200000;
static const int TRANSMETA_BIT_22 = 0x400000;
static const int TRANSMETA_MMX = 0x800000;
static const int TRANSMETA_BIT_24 = 0x1000000;
static const int TRANSMETA_BIT_25 = 0x2000000;
static const int TRANSMETA_BIT_26 = 0x4000000;
static const int TRANSMETA_BIT_27 = 0x8000000;
static const int TRANSMETA_BIT_28 = 0x10000000;
static const int TRANSMETA_BIT_29 = 0x20000000;
static const int TRANSMETA_BIT_30 = 0x40000000;
static const unsigned TRANSMETA_BIT_31 = 0x80000000;
static const ShortInt ETRANSMETA_FPU = 0x1;
static const ShortInt ETRANSMETA_VME = 0x2;
static const ShortInt ETRANSMETA_DE = 0x4;
static const ShortInt ETRANSMETA_PSE = 0x8;
static const ShortInt ETRANSMETA_TSC = 0x10;
static const ShortInt ETRANSMETA_MSR = 0x20;
static const ShortInt ETRANSMETA_BIT_6 = 0x40;
static const Byte ETRANSMETA_BIT_7 = 0x80;
static const Word ETRANSMETA_CX8 = 0x100;
static const Word ETRANSMETA_BIT_9 = 0x200;
static const Word ETRANSMETA_BIT_10 = 0x400;
static const Word ETRANSMETA_BIT_11 = 0x800;
static const Word ETRANSMETA_BIT_12 = 0x1000;
static const Word ETRANSMETA_BIT_13 = 0x2000;
static const Word ETRANSMETA_BIT_14 = 0x4000;
static const Word ETRANSMETA_CMOV = 0x8000;
static const int ETRANSMETA_FCMOV = 0x10000;
static const int ETRANSMETA_BIT_17 = 0x20000;
static const int ETRANSMETA_BIT_18 = 0x40000;
static const int ETRANSMETA_BIT_19 = 0x80000;
static const int ETRANSMETA_BIT_20 = 0x100000;
static const int ETRANSMETA_BIT_21 = 0x200000;
static const int ETRANSMETA_BIT_22 = 0x400000;
static const int ETRANSMETA_MMX = 0x800000;
static const int ETRANSMETA_BIT_24 = 0x1000000;
static const int ETRANSMETA_BIT_25 = 0x2000000;
static const int ETRANSMETA_BIT_26 = 0x4000000;
static const int ETRANSMETA_BIT_27 = 0x8000000;
static const int ETRANSMETA_BIT_28 = 0x10000000;
static const int ETRANSMETA_BIT_29 = 0x20000000;
static const int ETRANSMETA_BIT_30 = 0x40000000;
static const unsigned ETRANSMETA_BIT_31 = 0x80000000;
static const ShortInt STRANSMETA_RECOVERY = 0x1;
static const ShortInt STRANSMETA_LONGRUN = 0x2;
static const ShortInt STRANSMETA_BIT_2 = 0x4;
static const ShortInt STRANSMETA_LRTI = 0x8;
static const ShortInt STRANSMETA_BIT_4 = 0x10;
static const ShortInt STRANSMETA_BIT_5 = 0x20;
static const ShortInt STRANSMETA_BIT_6 = 0x40;
static const Byte STRANSMETA_PTTI1 = 0x80;
static const Word STRANSMETA_PTTI2 = 0x100;
static const Word STRANSMETA_BIT_9 = 0x200;
static const Word STRANSMETA_BIT_10 = 0x400;
static const Word STRANSMETA_BIT_11 = 0x800;
static const Word STRANSMETA_BIT_12 = 0x1000;
static const Word STRANSMETA_BIT_13 = 0x2000;
static const Word STRANSMETA_BIT_14 = 0x4000;
static const Word STRANSMETA_BIT_15 = 0x8000;
static const int STRANSMETA_BIT_16 = 0x10000;
static const int STRANSMETA_BIT_17 = 0x20000;
static const int STRANSMETA_BIT_18 = 0x40000;
static const int STRANSMETA_BIT_19 = 0x80000;
static const int STRANSMETA_BIT_20 = 0x100000;
static const int STRANSMETA_BIT_21 = 0x200000;
static const int STRANSMETA_BIT_22 = 0x400000;
static const int STRANSMETA_BIT_23 = 0x800000;
static const int STRANSMETA_BIT_24 = 0x1000000;
static const int STRANSMETA_BIT_25 = 0x2000000;
static const int STRANSMETA_BIT_26 = 0x4000000;
static const int STRANSMETA_BIT_27 = 0x8000000;
static const int STRANSMETA_BIT_28 = 0x10000000;
static const int STRANSMETA_BIT_29 = 0x20000000;
static const int STRANSMETA_BIT_30 = 0x40000000;
static const unsigned STRANSMETA_BIT_31 = 0x80000000;
static const ShortInt MXCSR_IE = 0x1;
static const ShortInt MXCSR_DE = 0x2;
static const ShortInt MXCSR_ZE = 0x4;
static const ShortInt MXCSR_OE = 0x8;
static const ShortInt MXCSR_UE = 0x10;
static const ShortInt MXCSR_PE = 0x20;
static const ShortInt MXCSR_DAZ = 0x40;
static const Byte MXCSR_IM = 0x80;
static const Word MXCSR_DM = 0x100;
static const Word MXCSR_ZM = 0x200;
static const Word MXCSR_OM = 0x400;
static const Word MXCSR_UM = 0x800;
static const Word MXCSR_PM = 0x1000;
static const Word MXCSR_RC1 = 0x2000;
static const Word MXCSR_RC2 = 0x4000;
static const Word MXCSR_RC = 0x6000;
static const Word MXCSR_FZ = 0x8000;
extern PACKAGE StaticArray<TCacheInfo, 103> IntelCacheDescription;
extern PACKAGE unsigned ProcessorCount;
extern PACKAGE unsigned AllocGranularity;
extern PACKAGE unsigned PageSize;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall DelEnvironmentVar(const System::UnicodeString Name);
extern PACKAGE bool __fastcall ExpandEnvironmentVar(System::UnicodeString &Value);
extern PACKAGE bool __fastcall GetEnvironmentVar(const System::UnicodeString Name, /* out */ System::UnicodeString &Value)/* overload */;
extern PACKAGE bool __fastcall GetEnvironmentVar(const System::UnicodeString Name, /* out */ System::UnicodeString &Value, bool Expand)/* overload */;
extern PACKAGE bool __fastcall GetEnvironmentVars(const Classes::TStrings* Vars)/* overload */;
extern PACKAGE bool __fastcall GetEnvironmentVars(const Classes::TStrings* Vars, bool Expand)/* overload */;
extern PACKAGE bool __fastcall SetEnvironmentVar(const System::UnicodeString Name, const System::UnicodeString Value);
extern PACKAGE System::WideChar * __fastcall CreateEnvironmentBlock(const TEnvironmentOptions Options, const Classes::TStrings* AdditionalVars);
extern PACKAGE void __fastcall DestroyEnvironmentBlock(System::WideChar * &Env);
extern PACKAGE void __fastcall SetGlobalEnvironmentVariable(System::UnicodeString VariableName, System::UnicodeString VariableContent);
extern PACKAGE System::UnicodeString __fastcall GetCommonFilesFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCurrentFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetProgramFilesFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetWindowsFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetWindowsSystemFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetWindowsTempFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetDesktopFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetProgramsFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetPersonalFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetFavoritesFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetStartupFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetRecentFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetSendToFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetStartmenuFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetDesktopDirectoryFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCommonDocumentsFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetNethoodFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetFontsFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCommonStartmenuFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCommonProgramsFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCommonStartupFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCommonDesktopdirectoryFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCommonAppdataFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetAppdataFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetLocalAppData(void);
extern PACKAGE System::UnicodeString __fastcall GetPrinthoodFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCommonFavoritesFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetTemplatesFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetInternetCacheFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetCookiesFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetHistoryFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetProfileFolder(void);
extern PACKAGE System::UnicodeString __fastcall GetVolumeName(const System::UnicodeString Drive);
extern PACKAGE System::UnicodeString __fastcall GetVolumeSerialNumber(const System::UnicodeString Drive);
extern PACKAGE System::UnicodeString __fastcall GetVolumeFileSystem(const System::UnicodeString Drive);
extern PACKAGE TFileSystemFlags __fastcall GetVolumeFileSystemFlags(const System::UnicodeString Volume);
extern PACKAGE System::UnicodeString __fastcall GetIPAddress(const System::UnicodeString HostName);
extern PACKAGE void __fastcall GetIpAddresses(Classes::TStrings* Results)/* overload */;
extern PACKAGE void __fastcall GetIpAddresses(Classes::TStrings* Results, const System::AnsiString HostName)/* overload */;
extern PACKAGE System::UnicodeString __fastcall GetLocalComputerName(void);
extern PACKAGE System::UnicodeString __fastcall GetLocalUserName(void);
extern PACKAGE System::UnicodeString __fastcall GetRegisteredCompany(void);
extern PACKAGE System::UnicodeString __fastcall GetRegisteredOwner(void);
extern PACKAGE System::UnicodeString __fastcall GetUserDomainName(const System::UnicodeString CurUser);
extern PACKAGE System::WideString __fastcall GetWorkGroupName(void);
extern PACKAGE System::UnicodeString __fastcall GetDomainName(void);
extern PACKAGE System::UnicodeString __fastcall GetBIOSName(void);
extern PACKAGE System::UnicodeString __fastcall GetBIOSCopyright(void);
extern PACKAGE System::UnicodeString __fastcall GetBIOSExtendedInfo(void);
extern PACKAGE System::TDateTime __fastcall GetBIOSDate(void);
extern PACKAGE bool __fastcall RunningProcessesList(const Classes::TStrings* List, bool FullPath = true);
extern PACKAGE bool __fastcall LoadedModulesList(const Classes::TStrings* List, unsigned ProcessID, bool HandlesOnly = false);
extern PACKAGE bool __fastcall GetTasksList(const Classes::TStrings* List);
extern PACKAGE unsigned __fastcall ModuleFromAddr(const void * Addr);
extern PACKAGE bool __fastcall IsSystemModule(const unsigned Module);
extern PACKAGE bool __fastcall IsMainAppWindow(unsigned Wnd);
extern PACKAGE bool __fastcall IsWindowResponding(unsigned Wnd, int Timeout);
extern PACKAGE HICON __fastcall GetWindowIcon(unsigned Wnd, bool LargeIcon);
extern PACKAGE System::UnicodeString __fastcall GetWindowCaption(unsigned Wnd);
extern PACKAGE TJclTerminateAppResult __fastcall TerminateApp(unsigned ProcessID, int Timeout);
extern PACKAGE TJclTerminateAppResult __fastcall TerminateTask(unsigned Wnd, int Timeout);
extern PACKAGE System::UnicodeString __fastcall GetProcessNameFromWnd(unsigned Wnd);
extern PACKAGE unsigned __fastcall GetPidFromProcessName(const System::UnicodeString ProcessName);
extern PACKAGE System::UnicodeString __fastcall GetProcessNameFromPid(unsigned PID);
extern PACKAGE unsigned __fastcall GetMainAppWndFromPid(unsigned PID);
extern PACKAGE HWND __fastcall GetWndFromPid(unsigned PID, const System::UnicodeString WindowClassName);
extern PACKAGE System::UnicodeString __fastcall GetShellProcessName(void);
extern PACKAGE unsigned __fastcall GetShellProcessHandle(void);
extern PACKAGE TWindowsVersion __fastcall GetWindowsVersion(void);
extern PACKAGE TWindowsEdition __fastcall GetWindowsEdition(void);
extern PACKAGE TNtProductType __fastcall NtProductType(void);
extern PACKAGE System::UnicodeString __fastcall GetWindowsVersionString(void);
extern PACKAGE System::UnicodeString __fastcall GetWindowsEditionString(void);
extern PACKAGE System::UnicodeString __fastcall GetWindowsProductString(void);
extern PACKAGE System::UnicodeString __fastcall NtProductTypeString(void);
extern PACKAGE int __fastcall GetWindowsServicePackVersion(void);
extern PACKAGE System::UnicodeString __fastcall GetWindowsServicePackVersionString(void);
extern PACKAGE bool __fastcall GetOpenGLVersion(const unsigned Win, /* out */ System::AnsiString &Version, /* out */ System::AnsiString &Vendor);
extern PACKAGE bool __fastcall GetNativeSystemInfo(_SYSTEM_INFO &SystemInfo);
extern PACKAGE TProcessorArchitecture __fastcall GetProcessorArchitecture(void);
extern PACKAGE bool __fastcall IsWindows64(void);
extern PACKAGE System::UnicodeString __fastcall GetOSVersionString(void);
extern PACKAGE int __fastcall GetMacAddresses(const System::UnicodeString Machine, const Classes::TStrings* Addresses);
extern PACKAGE __int64 __fastcall ReadTimeStampCounter(void);
extern PACKAGE System::UnicodeString __fastcall GetIntelCacheDescription(const System::Byte D);
extern PACKAGE void __fastcall GetCpuInfo(TCpuInfo &CpuInfo);
extern PACKAGE int __fastcall RoundFrequency(const int Frequency);
extern PACKAGE bool __fastcall GetCPUSpeed(TFreqInfo &CpuSpeed);
extern PACKAGE TOSEnabledFeatures __fastcall GetOSEnabledFeatures(void);
extern PACKAGE TCpuInfo __fastcall CPUID(void);
extern PACKAGE bool __fastcall TestFDIVInstruction(void);
extern PACKAGE void __fastcall RoundToAllocGranularity64(__int64 &Value, bool Up);
extern PACKAGE void __fastcall RoundToAllocGranularityPtr(void * &Value, bool Up);
extern PACKAGE TAPMLineStatus __fastcall GetAPMLineStatus(void);
extern PACKAGE TAPMBatteryFlag __fastcall GetAPMBatteryFlag(void);
extern PACKAGE TAPMBatteryFlags __fastcall GetAPMBatteryFlags(void);
extern PACKAGE int __fastcall GetAPMBatteryLifePercent(void);
extern PACKAGE unsigned __fastcall GetAPMBatteryLifeTime(void);
extern PACKAGE unsigned __fastcall GetAPMBatteryFullLifeTime(void);
extern PACKAGE unsigned __fastcall GetMaxAppAddress(void);
extern PACKAGE unsigned __fastcall GetMinAppAddress(void);
extern PACKAGE System::Byte __fastcall GetMemoryLoad(void);
extern PACKAGE __int64 __fastcall GetSwapFileSize(void);
extern PACKAGE System::Byte __fastcall GetSwapFileUsage(void);
extern PACKAGE __int64 __fastcall GetTotalPhysicalMemory(void);
extern PACKAGE __int64 __fastcall GetFreePhysicalMemory(void);
extern PACKAGE __int64 __fastcall GetTotalPageFileMemory(void);
extern PACKAGE __int64 __fastcall GetFreePageFileMemory(void);
extern PACKAGE __int64 __fastcall GetTotalVirtualMemory(void);
extern PACKAGE __int64 __fastcall GetFreeVirtualMemory(void);
extern PACKAGE bool __fastcall GetKeyState(const unsigned VirtualKey);
extern PACKAGE bool __fastcall GetNumLockKeyState(void);
extern PACKAGE bool __fastcall GetScrollLockKeyState(void);
extern PACKAGE bool __fastcall GetCapsLockKeyState(void);
extern PACKAGE bool __fastcall IsSystemResourcesMeterPresent(void);
extern PACKAGE int __fastcall GetFreeSystemResources(const TFreeSysResKind ResourceType)/* overload */;
extern PACKAGE TFreeSystemResources __fastcall GetFreeSystemResources(void)/* overload */;
extern PACKAGE unsigned __fastcall GetBPP(void);
extern PACKAGE bool __fastcall ProgIDExists(const System::UnicodeString ProgID);
extern PACKAGE bool __fastcall IsWordInstalled(void);
extern PACKAGE bool __fastcall IsExcelInstalled(void);
extern PACKAGE bool __fastcall IsAccessInstalled(void);
extern PACKAGE bool __fastcall IsPowerPointInstalled(void);
extern PACKAGE bool __fastcall IsFrontPageInstalled(void);
extern PACKAGE bool __fastcall IsOutlookInstalled(void);
extern PACKAGE bool __fastcall IsInternetExplorerInstalled(void);
extern PACKAGE bool __fastcall IsMSProjectInstalled(void);
extern PACKAGE bool __fastcall IsOpenOfficeInstalled(void);
extern PACKAGE bool __fastcall IsLibreOfficeInstalled(void);

}	/* namespace Jclsysinfo */
using namespace Jclsysinfo;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclsysinfoHPP
