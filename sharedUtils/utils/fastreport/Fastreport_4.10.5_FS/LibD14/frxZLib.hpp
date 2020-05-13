// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxzlib.pas' rev: 21.00

#ifndef FrxzlibHPP
#define FrxzlibHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxzlib
{
//-- type declarations -------------------------------------------------------
typedef void * __fastcall (*TZAlloc)(void * opaque, int items, int size);

typedef void __fastcall (*TZFree)(void * opaque, void * block);

#pragma option push -b-
enum TZCompressionLevel { zcNone, zcFastest, zcDefault, zcMax };
#pragma option pop

#pragma pack(push,1)
struct TZStreamRec
{
	
public:
	System::Byte *next_in;
	int avail_in;
	int total_in;
	System::Byte *next_out;
	int avail_out;
	int total_out;
	System::Byte *msg;
	void *state;
	TZAlloc zalloc;
	TZFree zfree;
	void *opaque;
	int data_type;
	int adler;
	int reserved;
};
#pragma pack(pop)


class DELPHICLASS TCustomZStream;
class PASCALIMPLEMENTATION TCustomZStream : public Classes::TStream
{
	typedef Classes::TStream inherited;
	
private:
	Classes::TStream* FStream;
	int FStreamPos;
	Classes::TNotifyEvent FOnProgress;
	TZStreamRec FZStream;
	StaticArray<System::Byte, 65536> FBuffer;
	
protected:
	__fastcall TCustomZStream(Classes::TStream* stream);
	DYNAMIC void __fastcall DoProgress(void);
	__property Classes::TNotifyEvent OnProgress = {read=FOnProgress, write=FOnProgress};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TCustomZStream(void) { }
	
};


class DELPHICLASS TZCompressionStream;
class PASCALIMPLEMENTATION TZCompressionStream : public TCustomZStream
{
	typedef TCustomZStream inherited;
	
private:
	float __fastcall GetCompressionRate(void);
	
public:
	__fastcall TZCompressionStream(Classes::TStream* dest, TZCompressionLevel compressionLevel);
	__fastcall virtual ~TZCompressionStream(void);
	virtual int __fastcall Read(void *buffer, int count);
	virtual int __fastcall Write(const void *buffer, int count);
	virtual int __fastcall Seek(int offset, System::Word origin)/* overload */;
	__property float CompressionRate = {read=GetCompressionRate};
	__property OnProgress;
	
/* Hoisted overloads: */
	
public:
	inline __int64 __fastcall  Seek(const __int64 Offset, Classes::TSeekOrigin Origin){ return Classes::TStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TZDecompressionStream;
class PASCALIMPLEMENTATION TZDecompressionStream : public TCustomZStream
{
	typedef TCustomZStream inherited;
	
public:
	__fastcall TZDecompressionStream(Classes::TStream* source);
	__fastcall virtual ~TZDecompressionStream(void);
	virtual int __fastcall Read(void *buffer, int count);
	virtual int __fastcall Write(const void *buffer, int count);
	virtual int __fastcall Seek(int offset, System::Word origin)/* overload */;
	__property OnProgress;
	
/* Hoisted overloads: */
	
public:
	inline __int64 __fastcall  Seek(const __int64 Offset, Classes::TSeekOrigin Origin){ return Classes::TStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS EZLibError;
class PASCALIMPLEMENTATION EZLibError : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall EZLibError(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EZLibError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EZLibError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EZLibError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EZLibError(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EZLibError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EZLibError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EZLibError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EZLibError(void) { }
	
};


class DELPHICLASS EZCompressionError;
class PASCALIMPLEMENTATION EZCompressionError : public EZLibError
{
	typedef EZLibError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EZCompressionError(const System::UnicodeString Msg) : EZLibError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EZCompressionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EZLibError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EZCompressionError(int Ident)/* overload */ : EZLibError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EZCompressionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EZLibError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EZCompressionError(const System::UnicodeString Msg, int AHelpContext) : EZLibError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EZCompressionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EZLibError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EZCompressionError(int Ident, int AHelpContext)/* overload */ : EZLibError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EZCompressionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EZLibError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EZCompressionError(void) { }
	
};


class DELPHICLASS EZDecompressionError;
class PASCALIMPLEMENTATION EZDecompressionError : public EZLibError
{
	typedef EZLibError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EZDecompressionError(const System::UnicodeString Msg) : EZLibError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EZDecompressionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EZLibError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EZDecompressionError(int Ident)/* overload */ : EZLibError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EZDecompressionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EZLibError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EZDecompressionError(const System::UnicodeString Msg, int AHelpContext) : EZLibError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EZDecompressionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EZLibError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EZDecompressionError(int Ident, int AHelpContext)/* overload */ : EZLibError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EZDecompressionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EZLibError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EZDecompressionError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
#define ZLIB_VERSION L"1.2.1"
extern PACKAGE void __fastcall ZCompress(const void * inBuffer, int inSize, /* out */ void * &outBuffer, /* out */ int &outSize, TZCompressionLevel level = (TZCompressionLevel)(0x2));
extern PACKAGE void __fastcall ZDecompress(const void * inBuffer, int inSize, /* out */ void * &outBuffer, /* out */ int &outSize, int outEstimate = 0x0);
extern PACKAGE int __fastcall adler32(int adler, const char * buf, int len);
extern PACKAGE int __fastcall compressBound(int sourceLen);
extern PACKAGE int __fastcall crc32(int crc, const char * buf, int len);
extern PACKAGE int __fastcall deflateInit_(TZStreamRec &strm, int level, char * version, int recsize);
extern PACKAGE int __fastcall deflate(TZStreamRec &strm, int flush);
extern PACKAGE int __fastcall deflateEnd(TZStreamRec &strm);
extern PACKAGE int __fastcall inflateInit_(TZStreamRec &strm, char * version, int recsize);
extern PACKAGE int __fastcall inflate(TZStreamRec &strm, int flush);
extern PACKAGE int __fastcall inflateEnd(TZStreamRec &strm);

}	/* namespace Frxzlib */
using namespace Frxzlib;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxzlibHPP
