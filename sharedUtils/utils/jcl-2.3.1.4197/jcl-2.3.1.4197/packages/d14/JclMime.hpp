// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclmime.pas' rev: 21.00

#ifndef JclmimeHPP
#define JclmimeHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclmime
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
static const ShortInt MIME_ENCODED_LINE_BREAK = 0x4c;
static const ShortInt MIME_DECODED_LINE_BREAK = 0x39;
static const Word MIME_BUFFER_SIZE = 0xab0;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall MimeEncode(const Jclbase::TDynByteArray InputBuffer, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer)/* overload */;
extern PACKAGE void __fastcall MimeEncodeNoCRLF(const Jclbase::TDynByteArray InputBuffer, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer)/* overload */;
extern PACKAGE void __fastcall MimeEncodeFullLines(const Jclbase::TDynByteArray InputBuffer, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer)/* overload */;
extern PACKAGE int __fastcall MimeDecode(const Jclbase::TDynByteArray InputBuffer, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer)/* overload */;
extern PACKAGE int __fastcall MimeDecodePartial(const Jclbase::TDynByteArray InputBuffer, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer, unsigned &ByteBuffer, unsigned &ByteBufferSpace)/* overload */;
extern PACKAGE int __fastcall MimeDecodePartialEnd(/* out */ Jclbase::TDynByteArray &OutputBuffer, const unsigned ByteBuffer, const unsigned ByteBufferSpace)/* overload */;
extern PACKAGE System::AnsiString __fastcall MimeEncodeString(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall MimeEncodeStringNoCRLF(const System::AnsiString S);
extern PACKAGE System::AnsiString __fastcall MimeDecodeString(const System::AnsiString S);
extern PACKAGE void __fastcall DecodeHttpBasicAuthentication(const System::AnsiString BasicCredentials, /* out */ System::AnsiString &UserId, /* out */ System::AnsiString &PassWord);
extern PACKAGE int __fastcall MimeEncodedSize(const int InputSize);
extern PACKAGE int __fastcall MimeEncodedSizeNoCRLF(const int InputSize);
extern PACKAGE int __fastcall MimeDecodedSize(const int InputSize);
extern PACKAGE void __fastcall MimeEncode(const Jclbase::TDynByteArray InputBuffer, int InputOffset, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer, int OutputOffset = 0x0)/* overload */;
extern PACKAGE void __fastcall MimeEncode(const void *InputBuffer, const int InputByteCount, /* out */ void *OutputBuffer)/* overload */;
extern PACKAGE void __fastcall MimeEncodeFullLines(const Jclbase::TDynByteArray InputBuffer, int InputOffset, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer, int OutputOffset = 0x0)/* overload */;
extern PACKAGE void __fastcall MimeEncodeFullLines(const void *InputBuffer, const int InputByteCount, /* out */ void *OutputBuffer)/* overload */;
extern PACKAGE void __fastcall MimeEncodeNoCRLF(const Jclbase::TDynByteArray InputBuffer, int InputOffset, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer, int OutputOffset = 0x0)/* overload */;
extern PACKAGE void __fastcall MimeEncodeNoCRLF(const void *InputBuffer, const int InputByteCount, /* out */ void *OutputBuffer)/* overload */;
extern PACKAGE int __fastcall MimeDecode(const Jclbase::TDynByteArray InputBuffer, int InputOffset, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer, int OutputOffset = 0x0)/* overload */;
extern PACKAGE int __fastcall MimeDecode(const void *InputBuffer, const int InputByteCount, /* out */ void *OutputBuffer)/* overload */;
extern PACKAGE int __fastcall MimeDecodePartial(const Jclbase::TDynByteArray InputBuffer, int InputOffset, const int InputByteCount, /* out */ Jclbase::TDynByteArray &OutputBuffer, int OutputOffset, unsigned &ByteBuffer, unsigned &ByteBufferSpace)/* overload */;
extern PACKAGE int __fastcall MimeDecodePartial(const void *InputBuffer, const int InputByteCount, /* out */ void *OutputBuffer, unsigned &ByteBuffer, unsigned &ByteBufferSpace)/* overload */;
extern PACKAGE int __fastcall MimeDecodePartialEnd(/* out */ Jclbase::TDynByteArray &OutputBuffer, int OutputOffset, const unsigned ByteBuffer, const unsigned ByteBufferSpace)/* overload */;
extern PACKAGE int __fastcall MimeDecodePartialEnd(/* out */ void *OutputBuffer, const unsigned ByteBuffer, const unsigned ByteBufferSpace)/* overload */;
extern PACKAGE void __fastcall MimeEncodeFile(const Sysutils::TFileName InputFileName, const Sysutils::TFileName OutputFileName);
extern PACKAGE void __fastcall MimeEncodeFileNoCRLF(const Sysutils::TFileName InputFileName, const Sysutils::TFileName OutputFileName);
extern PACKAGE void __fastcall MimeDecodeFile(const Sysutils::TFileName InputFileName, const Sysutils::TFileName OutputFileName);
extern PACKAGE void __fastcall MimeEncodeStream(const Classes::TStream* InputStream, const Classes::TStream* OutputStream);
extern PACKAGE void __fastcall MimeEncodeStreamNoCRLF(const Classes::TStream* InputStream, const Classes::TStream* OutputStream);
extern PACKAGE void __fastcall MimeDecodeStream(const Classes::TStream* InputStream, const Classes::TStream* OutputStream);

}	/* namespace Jclmime */
using namespace Jclmime;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclmimeHPP
