// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Sevenzip.pas' rev: 21.00

#ifndef SevenzipHPP
#define SevenzipHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Sevenzip
{
//-- type declarations -------------------------------------------------------
__interface ISequentialInStream;
typedef System::DelphiInterface<ISequentialInStream> _di_ISequentialInStream;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000300010000}") ISequentialInStream  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Read(void * Data, unsigned Size, Jclbase::PCardinal ProcessedSize) = 0 ;
};

__interface ISequentialOutStream;
typedef System::DelphiInterface<ISequentialOutStream> _di_ISequentialOutStream;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000300020000}") ISequentialOutStream  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Write(void * Data, unsigned Size, Jclbase::PCardinal ProcessedSize) = 0 ;
};

__interface IInStream;
typedef System::DelphiInterface<IInStream> _di_IInStream;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000300030000}") IInStream  : public ISequentialInStream 
{
	
public:
	virtual HRESULT __stdcall Seek(__int64 Offset, unsigned SeekOrigin, Jclbase::PInt64 NewPosition) = 0 ;
};

__interface IOutStream;
typedef System::DelphiInterface<IOutStream> _di_IOutStream;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000300040000}") IOutStream  : public ISequentialOutStream 
{
	
public:
	virtual HRESULT __stdcall Seek(__int64 Offset, unsigned SeekOrigin, Jclbase::PInt64 NewPosition) = 0 ;
	virtual HRESULT __stdcall SetSize(__int64 NewSize) = 0 ;
};

__interface IStreamGetSize;
typedef System::DelphiInterface<IStreamGetSize> _di_IStreamGetSize;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000300060000}") IStreamGetSize  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall GetSize(Jclbase::PInt64 Size) = 0 ;
};

__interface IOutStreamFlush;
typedef System::DelphiInterface<IOutStreamFlush> _di_IOutStreamFlush;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000300070000}") IOutStreamFlush  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Flush(void) = 0 ;
};

__interface ICompressProgressInfo;
typedef System::DelphiInterface<ICompressProgressInfo> _di_ICompressProgressInfo;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400040000}") ICompressProgressInfo  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetRatioInfo(Jclbase::PInt64 InSize, Jclbase::PInt64 OutSize) = 0 ;
};

__interface ICompressCoder;
typedef System::DelphiInterface<ICompressCoder> _di_ICompressCoder;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400050000}") ICompressCoder  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Code(_di_ISequentialInStream InStream, _di_ISequentialOutStream OutStream, Jclbase::PInt64 InSize, Jclbase::PInt64 OutSize, _di_ICompressProgressInfo Progress) = 0 ;
};

typedef _di_ISequentialInStream *PISequentialInStream;

typedef _di_ISequentialOutStream *PISequentialOutStream;

__interface ICompressCoder2;
typedef System::DelphiInterface<ICompressCoder2> _di_ICompressCoder2;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400180000}") ICompressCoder2  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Code(PISequentialInStream InStreams, Jclbase::PPInt64 InSizes, unsigned NumInStreams, PISequentialOutStream OutStreams, Jclbase::PPInt64 OutSizes, unsigned NumOutStreams, _di_ICompressProgressInfo Progress) = 0 ;
};

__interface ICompressSetCoderProperties;
typedef System::DelphiInterface<ICompressSetCoderProperties> _di_ICompressSetCoderProperties;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400200000}") ICompressSetCoderProperties  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetCoderProperties(Activex::PPropID PropIDs, Activex::PPropVariant Properties, unsigned NumProperties) = 0 ;
};

__interface ICompressSetDecoderProperties2;
typedef System::DelphiInterface<ICompressSetDecoderProperties2> _di_ICompressSetDecoderProperties2;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400220000}") ICompressSetDecoderProperties2  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetDecoderProperties2(System::PByte Data, unsigned Size) = 0 ;
};

__interface ICompressWriteCoderProperties;
typedef System::DelphiInterface<ICompressWriteCoderProperties> _di_ICompressWriteCoderProperties;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400230000}") ICompressWriteCoderProperties  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall WriteCoderProperties(_di_ISequentialOutStream OutStream) = 0 ;
};

__interface ICompressGetInStreamProcessedSize;
typedef System::DelphiInterface<ICompressGetInStreamProcessedSize> _di_ICompressGetInStreamProcessedSize;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400240000}") ICompressGetInStreamProcessedSize  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall GetInStreamProcessedSize(Jclbase::PInt64 Value) = 0 ;
};

__interface ICompressSetCoderMt;
typedef System::DelphiInterface<ICompressSetCoderMt> _di_ICompressSetCoderMt;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400250000}") ICompressSetCoderMt  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetNumberOfThreads(unsigned NumThreads) = 0 ;
};

__interface ICompressGetSubStreamSize;
typedef System::DelphiInterface<ICompressGetSubStreamSize> _di_ICompressGetSubStreamSize;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400300000}") ICompressGetSubStreamSize  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall GetSubStreamSize(__int64 SubStream, /* out */ __int64 &Value) = 0 ;
};

__interface ICompressSetInStream;
typedef System::DelphiInterface<ICompressSetInStream> _di_ICompressSetInStream;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400310000}") ICompressSetInStream  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetInStream(_di_ISequentialInStream InStream) = 0 ;
	virtual HRESULT __stdcall ReleaseInStream(void) = 0 ;
};

__interface ICompressSetOutStream;
typedef System::DelphiInterface<ICompressSetOutStream> _di_ICompressSetOutStream;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400320000}") ICompressSetOutStream  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetOutStream(_di_ISequentialOutStream OutStream) = 0 ;
	virtual HRESULT __stdcall ReleaseOutStream(void) = 0 ;
};

__interface ICompressSetInStreamSize;
typedef System::DelphiInterface<ICompressSetInStreamSize> _di_ICompressSetInStreamSize;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400330000}") ICompressSetInStreamSize  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetInStreamSize(Jclbase::PInt64 InSize) = 0 ;
};

__interface ICompressSetOutStreamSize;
typedef System::DelphiInterface<ICompressSetOutStreamSize> _di_ICompressSetOutStreamSize;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400340000}") ICompressSetOutStreamSize  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetOutStreamSize(Jclbase::PInt64 OutSize) = 0 ;
};

__interface ICompressFilter;
typedef System::DelphiInterface<ICompressFilter> _di_ICompressFilter;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400400000}") ICompressFilter  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Init(void) = 0 ;
	virtual unsigned __stdcall Filter(System::PByte Data, unsigned Size) = 0 ;
};

__interface ICompressCodecsInfo;
typedef System::DelphiInterface<ICompressCodecsInfo> _di_ICompressCodecsInfo;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400600000}") ICompressCodecsInfo  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall GetNumberOfMethods(Jclbase::PCardinal NumMethods) = 0 ;
	virtual HRESULT __stdcall GetProperty(unsigned Index, unsigned PropID, /* out */ tagPROPVARIANT &Value) = 0 ;
	virtual HRESULT __stdcall CreateDecoder(unsigned Index, System::PGUID IID, /* out */ void *Decoder) = 0 ;
	virtual HRESULT __stdcall CreateEncoder(unsigned Index, System::PGUID IID, /* out */ void *Coder) = 0 ;
};

__interface ISetCompressCodecsInfo;
typedef System::DelphiInterface<ISetCompressCodecsInfo> _di_ISetCompressCodecsInfo;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400610000}") ISetCompressCodecsInfo  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetCompressCodecsInfo(_di_ICompressCodecsInfo CompressCodecsInfo) = 0 ;
};

__interface ICryptoProperties;
typedef System::DelphiInterface<ICryptoProperties> _di_ICryptoProperties;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400800000}") ICryptoProperties  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetKey(System::PByte Data, unsigned Size) = 0 ;
	virtual HRESULT __stdcall SetInitVector(System::PByte Data, unsigned Size) = 0 ;
};

__interface ICryptoSetPassword;
typedef System::DelphiInterface<ICryptoSetPassword> _di_ICryptoSetPassword;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400900000}") ICryptoSetPassword  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall CryptoSetPassword(System::PByte Data, unsigned Size) = 0 ;
};

__interface ICryptoSetCRC;
typedef System::DelphiInterface<ICryptoSetCRC> _di_ICryptoSetCRC;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000400A00000}") ICryptoSetCRC  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall CryptoSetCRC(unsigned crc) = 0 ;
};

__interface IProgress;
typedef System::DelphiInterface<IProgress> _di_IProgress;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000000050000}") IProgress  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetTotal(__int64 Total) = 0 ;
	virtual HRESULT __stdcall SetCompleted(Jclbase::PInt64 CompleteValue) = 0 ;
};

__interface IArchiveOpenCallback;
typedef System::DelphiInterface<IArchiveOpenCallback> _di_IArchiveOpenCallback;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600100000}") IArchiveOpenCallback  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetTotal(Jclbase::PInt64 Files, Jclbase::PInt64 Bytes) = 0 ;
	virtual HRESULT __stdcall SetCompleted(Jclbase::PInt64 Files, Jclbase::PInt64 Bytes) = 0 ;
};

__interface IArchiveExtractCallback;
typedef System::DelphiInterface<IArchiveExtractCallback> _di_IArchiveExtractCallback;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600200000}") IArchiveExtractCallback  : public IProgress 
{
	
public:
	virtual HRESULT __stdcall GetStream(unsigned Index, /* out */ _di_ISequentialOutStream &OutStream, unsigned askExtractMode) = 0 ;
	virtual HRESULT __stdcall PrepareOperation(unsigned askExtractMode) = 0 ;
	virtual HRESULT __stdcall SetOperationResult(int resultEOperationResult) = 0 ;
};

__interface IArchiveOpenVolumeCallback;
typedef System::DelphiInterface<IArchiveOpenVolumeCallback> _di_IArchiveOpenVolumeCallback;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600300000}") IArchiveOpenVolumeCallback  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall GetProperty(unsigned PropID, /* out */ tagPROPVARIANT &Value) = 0 ;
	virtual HRESULT __stdcall GetStream(System::WideChar * Name, /* out */ _di_IInStream &InStream) = 0 ;
};

__interface IInArchiveGetStream;
typedef System::DelphiInterface<IInArchiveGetStream> _di_IInArchiveGetStream;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600400000}") IInArchiveGetStream  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall GetStream(unsigned Index, /* out */ _di_ISequentialInStream &Stream) = 0 ;
};

__interface IArchiveOpenSetSubArchiveName;
typedef System::DelphiInterface<IArchiveOpenSetSubArchiveName> _di_IArchiveOpenSetSubArchiveName;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600500000}") IArchiveOpenSetSubArchiveName  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetSubArchiveName(System::WideChar * Name) = 0 ;
};

__interface IInArchive;
typedef System::DelphiInterface<IInArchive> _di_IInArchive;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600600000}") IInArchive  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Open(_di_IInStream Stream, Jclbase::PInt64 MaxCheckStartPosition, _di_IArchiveOpenCallback OpenArchiveCallback) = 0 ;
	virtual HRESULT __stdcall Close(void) = 0 ;
	virtual HRESULT __stdcall GetNumberOfItems(Jclbase::PCardinal NumItems) = 0 ;
	virtual HRESULT __stdcall GetProperty(unsigned Index, unsigned PropID, tagPROPVARIANT &Value) = 0 ;
	virtual HRESULT __stdcall Extract(Jclbase::PCardinal Indices, unsigned NumItems, int TestMode, _di_IArchiveExtractCallback ExtractCallback) = 0 ;
	virtual HRESULT __stdcall GetArchiveProperty(unsigned PropID, /* out */ tagPROPVARIANT &Value) = 0 ;
	virtual HRESULT __stdcall GetNumberOfProperties(Jclbase::PCardinal NumProperties) = 0 ;
	virtual HRESULT __stdcall GetPropertyInfo(unsigned Index, /* out */ System::WideChar * &Name, /* out */ unsigned &PropID, /* out */ System::Word &VarType) = 0 ;
	virtual HRESULT __stdcall GetNumberOfArchiveProperties(Jclbase::PCardinal NumProperties) = 0 ;
	virtual HRESULT __stdcall GetArchivePropertyInfo(unsigned Index, /* out */ System::WideChar * &Name, /* out */ unsigned &PropID, /* out */ System::Word &VarType) = 0 ;
};

__interface IArchiveUpdateCallback;
typedef System::DelphiInterface<IArchiveUpdateCallback> _di_IArchiveUpdateCallback;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600800000}") IArchiveUpdateCallback  : public IProgress 
{
	
public:
	virtual HRESULT __stdcall GetUpdateItemInfo(unsigned Index, System::PInteger NewData, System::PInteger NewProperties, Jclbase::PCardinal IndexInArchive) = 0 ;
	virtual HRESULT __stdcall GetProperty(unsigned Index, unsigned PropID, /* out */ tagPROPVARIANT &Value) = 0 ;
	virtual HRESULT __stdcall GetStream(unsigned Index, /* out */ _di_ISequentialInStream &InStream) = 0 ;
	virtual HRESULT __stdcall SetOperationResult(int OperationResult) = 0 ;
};

__interface IArchiveUpdateCallback2;
typedef System::DelphiInterface<IArchiveUpdateCallback2> _di_IArchiveUpdateCallback2;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600820000}") IArchiveUpdateCallback2  : public IArchiveUpdateCallback 
{
	
public:
	virtual HRESULT __stdcall GetVolumeSize(unsigned Index, Jclbase::PInt64 Size) = 0 ;
	virtual HRESULT __stdcall GetVolumeStream(unsigned Index, /* out */ _di_ISequentialOutStream &VolumeStream) = 0 ;
};

__interface IOutArchive;
typedef System::DelphiInterface<IOutArchive> _di_IOutArchive;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600A00000}") IOutArchive  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall UpdateItems(_di_ISequentialOutStream OutStream, unsigned NumItems, _di_IArchiveUpdateCallback UpdateCallback) = 0 ;
	virtual HRESULT __stdcall GetFileTimeType(Jclbase::PCardinal Type_) = 0 ;
};

__interface ISetProperties;
typedef System::DelphiInterface<ISetProperties> _di_ISetProperties;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000600030000}") ISetProperties  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall SetProperties(Jclbase::PPWideChar Names, Activex::PPropVariant Values, int NumProperties) = 0 ;
};

__interface ICryptoGetTextPassword;
typedef System::DelphiInterface<ICryptoGetTextPassword> _di_ICryptoGetTextPassword;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000500100000}") ICryptoGetTextPassword  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall CryptoGetTextPassword(Activex::PBStr password) = 0 ;
};

__interface ICryptoGetTextPassword2;
typedef System::DelphiInterface<ICryptoGetTextPassword2> _di_ICryptoGetTextPassword2;
__interface  INTERFACE_UUID("{23170F69-40C1-278A-0000-000500110000}") ICryptoGetTextPassword2  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall CryptoGetTextPassword2(System::PInteger PasswordIsDefined, Activex::PBStr Password) = 0 ;
};

typedef HRESULT __stdcall (*TCreateObjectFunc)(System::PGUID ClsID, System::PGUID IID, /* out */ void *Obj);

typedef HRESULT __stdcall (*TGetHandlerProperty2)(unsigned FormatIndex, unsigned PropID, /* out */ tagPROPVARIANT &Value);

typedef HRESULT __stdcall (*TGetHandlerProperty)(unsigned PropID, /* out */ tagPROPVARIANT &Value);

typedef HRESULT __stdcall (*TGetMethodProperty)(unsigned CodecIndex, unsigned PropID, /* out */ tagPROPVARIANT &Value);

typedef HRESULT __stdcall (*TGetNumberOfFormatsFunc)(Jclbase::PCardinal NumFormats);

typedef HRESULT __stdcall (*TGetNumberOfMethodsFunc)(Jclbase::PCardinal NumMethods);

typedef HRESULT __stdcall (*TSetLargePageMode)(void);

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE GUID CLSID_CCodec;
extern PACKAGE GUID CLSID_CCodecBCJ2;
extern PACKAGE GUID CLSID_CCodecBCJ;
extern PACKAGE GUID CLSID_CCodecSWAP2;
extern PACKAGE GUID CLSID_CCodecSWAP4;
extern PACKAGE GUID CLSID_CCodecBPPC;
extern PACKAGE GUID CLSID_CCodecBIA64;
extern PACKAGE GUID CLSID_CCodecBARM;
extern PACKAGE GUID CLSID_CCodecBARMT;
extern PACKAGE GUID CLSID_CCodecBARMS;
extern PACKAGE GUID CLSID_CCodecBZIP;
extern PACKAGE GUID CLSID_CCodecCOPY;
extern PACKAGE GUID CLSID_CCodecDEF64;
extern PACKAGE GUID CLSID_CCodecDEFNSIS;
extern PACKAGE GUID CLSID_CCodecDEFREG;
extern PACKAGE GUID CLSID_CCodecLZMA;
extern PACKAGE GUID CLSID_CCodecPPMD;
extern PACKAGE GUID CLSID_CCodecRAR1;
extern PACKAGE GUID CLSID_CCodecRAR2;
extern PACKAGE GUID CLSID_CCodecRAR3;
extern PACKAGE GUID CLSID_CAESCodec;
extern PACKAGE GUID CLSID_CArchiveHandler;
extern PACKAGE GUID CLSID_CFormatZip;
extern PACKAGE GUID CLSID_CFormatBZ2;
extern PACKAGE GUID CLSID_CFormatRar;
extern PACKAGE GUID CLSID_CFormatArj;
extern PACKAGE GUID CLSID_CFormatZ;
extern PACKAGE GUID CLSID_CFormatLzh;
extern PACKAGE GUID CLSID_CFormat7z;
extern PACKAGE GUID CLSID_CFormatCab;
extern PACKAGE GUID CLSID_CFormatNsis;
extern PACKAGE GUID CLSID_CFormatLzma;
extern PACKAGE GUID CLSID_CFormatLzma86;
extern PACKAGE GUID CLSID_CFormatXz;
extern PACKAGE GUID CLSID_CFormatPpmd;
extern PACKAGE GUID CLSID_CFormatTE;
extern PACKAGE GUID CLSID_CFormatUEFIc;
extern PACKAGE GUID CLSID_CFormatUEFIs;
extern PACKAGE GUID CLSID_CFormatSquashFS;
extern PACKAGE GUID CLSID_CFormatCramFS;
extern PACKAGE GUID CLSID_CFormatAPM;
extern PACKAGE GUID CLSID_CFormatMslz;
extern PACKAGE GUID CLSID_CFormatFlv;
extern PACKAGE GUID CLSID_CFormatSwf;
extern PACKAGE GUID CLSID_CFormatSwfc;
extern PACKAGE GUID CLSID_CFormatNtfs;
extern PACKAGE GUID CLSID_CFormatFat;
extern PACKAGE GUID CLSID_CFormatMbr;
extern PACKAGE GUID CLSID_CFormatVhd;
extern PACKAGE GUID CLSID_CFormatPe;
extern PACKAGE GUID CLSID_CFormatElf;
extern PACKAGE GUID CLSID_CFormatMacho;
extern PACKAGE GUID CLSID_CFormatUdf;
extern PACKAGE GUID CLSID_CFormatXar;
extern PACKAGE GUID CLSID_CFormatMub;
extern PACKAGE GUID CLSID_CFormatHfs;
extern PACKAGE GUID CLSID_CFormatDmg;
extern PACKAGE GUID CLSID_CFormatCompound;
extern PACKAGE GUID CLSID_CFormatWim;
extern PACKAGE GUID CLSID_CFormatIso;
extern PACKAGE GUID CLSID_CFormatChm;
extern PACKAGE GUID CLSID_CFormatSplit;
extern PACKAGE GUID CLSID_CFormatRpm;
extern PACKAGE GUID CLSID_CFormatDeb;
extern PACKAGE GUID CLSID_CFormatCpio;
extern PACKAGE GUID CLSID_CFormatTar;
extern PACKAGE GUID CLSID_CFormatGZip;
static const ShortInt kpidNoProperty = 0x0;
static const ShortInt kpidMainSubfile = 0x1;
static const ShortInt kpidHandlerItemIndex = 0x2;
static const ShortInt kpidPath = 0x3;
static const ShortInt kpidName = 0x4;
static const ShortInt kpidExtension = 0x5;
static const ShortInt kpidIsFolder [[deprecated("Use kpidIsDir")]] = 0x6;
static const ShortInt kpidIsDir = 0x6;
static const ShortInt kpidSize = 0x7;
static const ShortInt kpidPackedSize [[deprecated("Use kpidPackSize")]] = 0x8;
static const ShortInt kpidPackSize = 0x8;
static const ShortInt kpidAttributes [[deprecated("Use kpidAttrib")]] = 0x9;
static const ShortInt kpidAttrib = 0x9;
static const ShortInt kpidCreationTime [[deprecated("Use kpidCTime")]] = 0xa;
static const ShortInt kpidCTime = 0xa;
static const ShortInt kpidLastAccessTime [[deprecated("Use kpidATime")]] = 0xb;
static const ShortInt kpidATime = 0xb;
static const ShortInt kpidLastWriteTime [[deprecated("Use kpidMTime")]] = 0xc;
static const ShortInt kpidMTime = 0xc;
static const ShortInt kpidSolid = 0xd;
static const ShortInt kpidCommented = 0xe;
static const ShortInt kpidEncrypted = 0xf;
static const ShortInt kpidSplitBefore = 0x10;
static const ShortInt kpidSplitAfter = 0x11;
static const ShortInt kpidDictionarySize = 0x12;
static const ShortInt kpidCRC = 0x13;
static const ShortInt kpidType = 0x14;
static const ShortInt kpidIsAnti = 0x15;
static const ShortInt kpidMethod = 0x16;
static const ShortInt kpidHostOS = 0x17;
static const ShortInt kpidFileSystem = 0x18;
static const ShortInt kpidUser = 0x19;
static const ShortInt kpidGroup = 0x1a;
static const ShortInt kpidBlock = 0x1b;
static const ShortInt kpidComment = 0x1c;
static const ShortInt kpidPosition = 0x1d;
static const ShortInt kpidPrefix = 0x1e;
static const ShortInt kpidNumSubDirs = 0x1f;
static const ShortInt kpidNumSubFiles = 0x20;
static const ShortInt kpidUnpackVer = 0x21;
static const ShortInt kpidVolume = 0x22;
static const ShortInt kpidIsVolume = 0x23;
static const ShortInt kpidOffset = 0x24;
static const ShortInt kpidLinks = 0x25;
static const ShortInt kpidNumBlocks = 0x26;
static const ShortInt kpidNumVolumes = 0x27;
static const ShortInt kpidTimeType = 0x28;
static const ShortInt kpidBit64 = 0x29;
static const ShortInt kpidBigEndian = 0x2a;
static const ShortInt kpidCpu = 0x2b;
static const ShortInt kpidPhySize = 0x2c;
static const ShortInt kpidHeadersSize = 0x2d;
static const ShortInt kpidChecksum = 0x2e;
static const ShortInt kpidCharacts = 0x2f;
static const ShortInt kpidVa = 0x30;
static const ShortInt kpidId = 0x31;
static const ShortInt kpidShortName = 0x32;
static const ShortInt kpidCreatorApp = 0x33;
static const ShortInt kpidSectorSize = 0x34;
static const ShortInt kpidPosixAttrib = 0x35;
static const ShortInt kpidLink = 0x36;
static const Word kpidTotalSize = 0x1100;
static const Word kpidFreeSpace = 0x1101;
static const Word kpidClusterSize = 0x1102;
static const Word kpidVolumeName = 0x1103;
static const Word kpidLocalName = 0x1200;
static const Word kpidProvider = 0x1201;
static const int kpidUserDefined = 0x10000;
#define kCopyMethodName L"Copy"
#define kLZMAMethodName L"LZMA"
#define kLZMA2MethodName L"LZMA2"
#define kBZip2MethodName L"BZip2"
#define kPpmdMethodName L"PPMd"
#define kDeflateMethodName L"Deflate"
#define kDeflate64MethodName L"Deflate64"
#define kAES128MethodName L"AES128"
#define kAES192MethodName L"AES192"
#define kAES256MethodName L"AES256"
#define kZipCryptoMethodName L"ZIPCRYPTO"
static const Word kDictionarySize = 0x400;
static const Word kUsedMemorySize = 0x401;
static const Word kOrder = 0x402;
static const Word kBlockSize = 0x403;
static const Word kPosStateBits = 0x440;
static const Word kLitContextBits = 0x441;
static const Word kLitPosBits = 0x442;
static const Word kNumFastBytes = 0x450;
static const Word kMatchFinder = 0x451;
static const Word kMatchFinderCycles = 0x452;
static const Word kNumPasses = 0x460;
static const Word kAlgorithm = 0x470;
static const Word kMultiThread = 0x480;
static const Word kNumThreads = 0x481;
static const Word kEndMarker = 0x490;
static const ShortInt kID = 0x0;
static const ShortInt kName = 0x1;
static const ShortInt kDecoder = 0x2;
static const ShortInt kEncoder = 0x3;
static const ShortInt kInStreams = 0x4;
static const ShortInt kOutStreams = 0x5;
static const ShortInt kDescription = 0x6;
static const ShortInt kDecoderIsAssigned = 0x7;
static const ShortInt kEncoderIsAssigned = 0x8;
static const ShortInt kWindows = 0x0;
static const ShortInt kUnix = 0x1;
static const ShortInt kDOS = 0x2;
static const ShortInt kArchiveName = 0x0;
static const ShortInt kClassID = 0x1;
static const ShortInt kExtension = 0x2;
static const ShortInt kAddExtension = 0x3;
static const ShortInt kUpdate = 0x4;
static const ShortInt kKeepName = 0x5;
static const ShortInt kStartSignature = 0x6;
static const ShortInt kFinishSignature = 0x7;
static const ShortInt kAssociate = 0x8;
static const ShortInt kExtract = 0x0;
static const ShortInt kTest = 0x1;
static const ShortInt kSkip = 0x2;
static const ShortInt kOK = 0x0;
static const ShortInt kUnSupportedMethod = 0x1;
static const ShortInt kDataError = 0x2;
static const ShortInt kCRCError = 0x3;
static const ShortInt kError = 0x1;
static const ShortInt kDeflateAlgoX1 [[deprecated("Use kLzAlgoX1")]] = 0x0;
static const ShortInt kLzAlgoX1 = 0x0;
static const ShortInt kDeflateAlgoX5 [[deprecated("Use kLzAlgoX5")]] = 0x1;
static const ShortInt kLzAlgoX5 = 0x1;
static const ShortInt kDeflateNumPassesX1 = 0x1;
static const ShortInt kDeflateNumPassesX7 = 0x3;
static const ShortInt kDeflateNumPassesX9 = 0xa;
static const ShortInt kNumFastBytesX1 [[deprecated("Use kDeflateNumFastBytesX1")]] = 0x20;
static const ShortInt kDeflateNumFastBytesX1 = 0x20;
static const ShortInt kNumFastBytesX7 [[deprecated("Use kDeflateNumFastBytesX7")]] = 0x40;
static const ShortInt kDeflateNumFastBytesX7 = 0x40;
static const Byte kNumFastBytesX9 [[deprecated("Use kDeflateNumFastBytesX9")]] = 0x80;
static const Byte kDeflateNumFastBytesX9 = 0x80;
static const ShortInt kLzmaNumFastBytesX1 = 0x20;
static const ShortInt kLzmaNumFastBytesX7 = 0x40;
static const ShortInt kBZip2NumPassesX1 = 0x1;
static const ShortInt kBZip2NumPassesX7 = 0x2;
static const ShortInt kBZip2NumPassesX9 = 0x7;
static const int kBZip2DicSizeX1 = 0x186a0;
static const int kBZip2DicSizeX3 = 0x7a120;
static const int kBZip2DicSizeX5 = 0xdbba0;
static const ShortInt kLzmaAlgoX1 = 0x0;
static const ShortInt kLzmaAlgoX5 = 0x1;
static const int kLzmaDicSizeX1 = 0x10000;
static const int kLzmaDicSizeX3 = 0x100000;
static const int kLzmaDicSizeX5 = 0x1000000;
static const int kLzmaDicSizeX7 = 0x2000000;
static const int kLzmaDicSizeX9 = 0x4000000;
static const ShortInt kLzmaFastBytesX1 = 0x20;
static const ShortInt kLzmaFastBytesX7 = 0x40;
static const int kPpmdMemSizeX1 = 0x400000;
static const int kPpmdMemSizeX5 = 0x1000000;
static const int kPpmdMemSizeX7 = 0x4000000;
static const int kPpmdMemSizeX9 = 0xc000000;
static const ShortInt kPpmdOrderX1 = 0x4;
static const ShortInt kPpmdOrderX5 = 0x6;
static const ShortInt kPpmdOrderX7 = 0x10;
static const ShortInt kPpmdOrderX9 = 0x20;
static const ShortInt kDeflateFastBytesX1 = 0x20;
static const ShortInt kDeflateFastBytesX7 = 0x40;
static const Byte kDeflateFastBytesX9 = 0x80;
extern PACKAGE TCreateObjectFunc CreateObject;
extern PACKAGE TGetHandlerProperty2 GetHandlerProperty2;
extern PACKAGE TGetHandlerProperty GetHandlerProperty;
extern PACKAGE TGetMethodProperty GetMethodProperty;
extern PACKAGE TGetNumberOfFormatsFunc GetNumberOfFormats;
extern PACKAGE TGetNumberOfMethodsFunc GetNumberOfMethods;
extern PACKAGE TSetLargePageMode SetLargePageMode;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall Load7Zip(void);
extern PACKAGE bool __fastcall Is7ZipLoaded(void);
extern PACKAGE void __fastcall Unload7Zip(void);

}	/* namespace Sevenzip */
using namespace Sevenzip;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// SevenzipHPP
