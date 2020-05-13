// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxmd5.pas' rev: 21.00

#ifndef Frxmd5HPP
#define Frxmd5HPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxmd5
{
//-- type declarations -------------------------------------------------------
typedef unsigned uint4;

typedef System::Byte uchar;

typedef unsigned *Puint4;

typedef System::Byte *Puchar;

class DELPHICLASS TfrxMD5;
class PASCALIMPLEMENTATION TfrxMD5 : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	StaticArray<unsigned, 4> m_State;
	StaticArray<unsigned, 2> m_Count;
	StaticArray<System::Byte, 64> m_Buffer;
	StaticArray<System::Byte, 16> m_Digest;
	void __fastcall Transform(Puchar block);
	void __fastcall Encode(Puchar dest, Puint4 src, unsigned nLength);
	void __fastcall Decode(Puint4 dest, Puchar src, unsigned nLength);
	unsigned __fastcall RotateLeft(unsigned x, unsigned n);
	void __fastcall FF(unsigned &a, unsigned b, unsigned c, unsigned d, unsigned x, unsigned s, unsigned ac);
	void __fastcall GG(unsigned &a, unsigned b, unsigned c, unsigned d, unsigned x, unsigned s, unsigned ac);
	void __fastcall HH(unsigned &a, unsigned b, unsigned c, unsigned d, unsigned x, unsigned s, unsigned ac);
	void __fastcall II(unsigned &a, unsigned b, unsigned c, unsigned d, unsigned x, unsigned s, unsigned ac);
	
public:
	__fastcall TfrxMD5(void);
	void __fastcall Init(void);
	void __fastcall Update(Puchar chInput, unsigned nInputLen);
	void __fastcall Finalize(void);
	Puchar __fastcall Digest(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxMD5(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const int MD5_INIT_STATE_0 = 0x67452301;
static const unsigned MD5_INIT_STATE_1 = 0xefcdab89;
static const unsigned MD5_INIT_STATE_2 = 0x98badcfe;
static const int MD5_INIT_STATE_3 = 0x10325476;
static const ShortInt MD5_S11 = 0x7;
static const ShortInt MD5_S12 = 0xc;
static const ShortInt MD5_S13 = 0x11;
static const ShortInt MD5_S14 = 0x16;
static const ShortInt MD5_S21 = 0x5;
static const ShortInt MD5_S22 = 0x9;
static const ShortInt MD5_S23 = 0xe;
static const ShortInt MD5_S24 = 0x14;
static const ShortInt MD5_S31 = 0x4;
static const ShortInt MD5_S32 = 0xb;
static const ShortInt MD5_S33 = 0x10;
static const ShortInt MD5_S34 = 0x17;
static const ShortInt MD5_S41 = 0x6;
static const ShortInt MD5_S42 = 0xa;
static const ShortInt MD5_S43 = 0xf;
static const ShortInt MD5_S44 = 0x15;
static const unsigned MD5_T01 = 0xd76aa478;
static const unsigned MD5_T02 = 0xe8c7b756;
static const int MD5_T03 = 0x242070db;
static const unsigned MD5_T04 = 0xc1bdceee;
static const unsigned MD5_T05 = 0xf57c0faf;
static const int MD5_T06 = 0x4787c62a;
static const unsigned MD5_T07 = 0xa8304613;
static const unsigned MD5_T08 = 0xfd469501;
static const int MD5_T09 = 0x698098d8;
static const unsigned MD5_T10 = 0x8b44f7af;
static const unsigned MD5_T11 = 0xffff5bb1;
static const unsigned MD5_T12 = 0x895cd7be;
static const int MD5_T13 = 0x6b901122;
static const unsigned MD5_T14 = 0xfd987193;
static const unsigned MD5_T15 = 0xa679438e;
static const int MD5_T16 = 0x49b40821;
static const unsigned MD5_T17 = 0xf61e2562;
static const unsigned MD5_T18 = 0xc040b340;
static const int MD5_T19 = 0x265e5a51;
static const unsigned MD5_T20 = 0xe9b6c7aa;
static const unsigned MD5_T21 = 0xd62f105d;
static const int MD5_T22 = 0x2441453;
static const unsigned MD5_T23 = 0xd8a1e681;
static const unsigned MD5_T24 = 0xe7d3fbc8;
static const int MD5_T25 = 0x21e1cde6;
static const unsigned MD5_T26 = 0xc33707d6;
static const unsigned MD5_T27 = 0xf4d50d87;
static const int MD5_T28 = 0x455a14ed;
static const unsigned MD5_T29 = 0xa9e3e905;
static const unsigned MD5_T30 = 0xfcefa3f8;
static const int MD5_T31 = 0x676f02d9;
static const unsigned MD5_T32 = 0x8d2a4c8a;
static const unsigned MD5_T33 = 0xfffa3942;
static const unsigned MD5_T34 = 0x8771f681;
static const int MD5_T35 = 0x6d9d6122;
static const unsigned MD5_T36 = 0xfde5380c;
static const unsigned MD5_T37 = 0xa4beea44;
static const int MD5_T38 = 0x4bdecfa9;
static const unsigned MD5_T39 = 0xf6bb4b60;
static const unsigned MD5_T40 = 0xbebfbc70;
static const int MD5_T41 = 0x289b7ec6;
static const unsigned MD5_T42 = 0xeaa127fa;
static const unsigned MD5_T43 = 0xd4ef3085;
static const int MD5_T44 = 0x4881d05;
static const unsigned MD5_T45 = 0xd9d4d039;
static const unsigned MD5_T46 = 0xe6db99e5;
static const int MD5_T47 = 0x1fa27cf8;
static const unsigned MD5_T48 = 0xc4ac5665;
static const unsigned MD5_T49 = 0xf4292244;
static const int MD5_T50 = 0x432aff97;
static const unsigned MD5_T51 = 0xab9423a7;
static const unsigned MD5_T52 = 0xfc93a039;
static const int MD5_T53 = 0x655b59c3;
static const unsigned MD5_T54 = 0x8f0ccc92;
static const unsigned MD5_T55 = 0xffeff47d;
static const unsigned MD5_T56 = 0x85845dd1;
static const int MD5_T57 = 0x6fa87e4f;
static const unsigned MD5_T58 = 0xfe2ce6e0;
static const unsigned MD5_T59 = 0xa3014314;
static const int MD5_T60 = 0x4e0811a1;
static const unsigned MD5_T61 = 0xf7537e82;
static const unsigned MD5_T62 = 0xbd3af235;
static const int MD5_T63 = 0x2ad7d2bb;
static const unsigned MD5_T64 = 0xeb86d391;
extern PACKAGE StaticArray<System::Byte, 64> PADDING;
extern PACKAGE System::AnsiString __fastcall PrintMD5(Puchar md5Digest);
extern PACKAGE System::AnsiString __fastcall MD5String(System::AnsiString szString);
extern PACKAGE System::AnsiString __fastcall MD5Stream(Classes::TStream* Stream);
extern PACKAGE System::AnsiString __fastcall MD5File(System::UnicodeString szFilename);
extern PACKAGE void __fastcall MD5Buf(void * Buf, const int Len, void * Digest);

}	/* namespace Frxmd5 */
using namespace Frxmd5;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Frxmd5HPP
