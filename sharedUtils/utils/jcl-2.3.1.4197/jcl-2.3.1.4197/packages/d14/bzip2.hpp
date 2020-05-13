// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Bzip2.pas' rev: 21.00

#ifndef Bzip2HPP
#define Bzip2HPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Bzip2
{
//-- type declarations -------------------------------------------------------
struct bz_stream
{
	
public:
	System::Byte *next_in;
	unsigned avail_in;
	unsigned total_in_lo32;
	unsigned total_in_hi32;
	System::Byte *next_out;
	unsigned avail_out;
	unsigned total_out_lo32;
	unsigned total_out_hi32;
	void *state;
	void * __cdecl (*bzalloc)(void * opaque, int n, int m);
	void __cdecl (*bzfree)(void * opaque, void * p);
	void *opaque;
};


typedef void * BZFILE;

//-- var, const, procedure ---------------------------------------------------
static const ShortInt BZ_RUN = 0x0;
static const ShortInt BZ_FLUSH = 0x1;
static const ShortInt BZ_FINISH = 0x2;
static const ShortInt BZ_OK = 0x0;
static const ShortInt BZ_RUN_OK = 0x1;
static const ShortInt BZ_FLUSH_OK = 0x2;
static const ShortInt BZ_FINISH_OK = 0x3;
static const ShortInt BZ_STREAM_END = 0x4;
static const ShortInt BZ_SEQUENCE_ERROR = -1;
static const ShortInt BZ_PARAM_ERROR = -2;
static const ShortInt BZ_MEM_ERROR = -3;
static const ShortInt BZ_DATA_ERROR = -4;
static const ShortInt BZ_DATA_ERROR_MAGIC = -5;
static const ShortInt BZ_IO_ERROR = -6;
static const ShortInt BZ_UNEXPECTED_EOF = -7;
static const ShortInt BZ_OUTBUFF_FULL = -8;
static const ShortInt BZ_CONFIG_ERROR = -9;
extern PACKAGE void __fastcall (__closure *bz2_internal_error_event)(int errcode);
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall LoadBZip2(void);
extern PACKAGE bool __fastcall IsBZip2Loaded(void);
extern PACKAGE void __fastcall UnloadBZip2(void);
extern PACKAGE int __stdcall BZ2_bzCompressInit(bz_stream &strm, int blockSize100k, int verbosity, int workFactor);
extern PACKAGE int __stdcall BZ2_bzCompress(bz_stream &strm, int action);
extern PACKAGE int __stdcall BZ2_bzCompressEnd(bz_stream &strm);
extern PACKAGE int __stdcall BZ2_bzDecompressInit(bz_stream &strm, int verbosity, int small);
extern PACKAGE int __stdcall BZ2_bzDecompress(bz_stream &strm);
extern PACKAGE int __stdcall BZ2_bzDecompressEnd(bz_stream &strm);
extern PACKAGE int __stdcall BZ2_bzBuffToBuffCompress(System::PByte dest, Jclbase::PCardinal destLen, System::PByte source, unsigned sourceLen, int blockSize100k, int verbosity, int workFactor);
extern PACKAGE int __stdcall BZ2_bzBuffToBuffDecompress(System::PByte dest, Jclbase::PCardinal destLen, System::PByte source, unsigned sourceLen, int small, int verbosity);
extern PACKAGE char * __stdcall BZ2_bzlibVersion(void);

}	/* namespace Bzip2 */
using namespace Bzip2;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Bzip2HPP
