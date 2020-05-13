// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Rc_apiref.pas' rev: 21.00

#ifndef Rc_apirefHPP
#define Rc_apirefHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Rc_algref.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Rc_apiref
{
//-- type declarations -------------------------------------------------------
typedef System::Byte word8;

typedef System::Word word16;

typedef unsigned word32;

typedef StaticArray<System::Byte, 2147483647> TByteArray;

typedef TByteArray *PByte;

struct keyInstance;
typedef keyInstance *PkeyInstance;

#pragma pack(push,1)
struct keyInstance
{
	
public:
	System::Byte direction;
	int keyLen;
	StaticArray<char, 65> keyMaterial;
	int blockLen;
	Rc_algref::TArrayRK keySched;
};
#pragma pack(pop)


typedef keyInstance TkeyInstance;

struct cipherInstance;
typedef cipherInstance *PcipherInstance;

#pragma pack(push,1)
struct cipherInstance
{
	
public:
	System::Byte mode;
	StaticArray<System::Byte, 16> IV;
	int blockLen;
};
#pragma pack(pop)


typedef cipherInstance TcipherInstance;

//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAXBC = 0x8;
static const ShortInt MAXKC = 0x8;
static const ShortInt MAXROUNDS = 0xe;
static const ShortInt DIR_ENCRYPT = 0x0;
static const ShortInt DIR_DECRYPT = 0x1;
static const ShortInt MODE_ECB = 0x1;
static const ShortInt MODE_CBC = 0x2;
static const ShortInt MODE_CFB1 = 0x3;
static const ShortInt rTRUE = 0x1;
static const ShortInt rFALSE = 0x0;
static const Byte BITSPERBLOCK = 0x80;
static const ShortInt BAD_KEY_DIR = -1;
static const ShortInt BAD_KEY_MAT = -2;
static const ShortInt BAD_KEY_INSTANCE = -3;
static const ShortInt BAD_CIPHER_MODE = -4;
static const ShortInt BAD_CIPHER_STATE = -5;
static const ShortInt BAD_CIPHER_INSTANCE = -7;
static const ShortInt MAX_KEY_SIZE = 0x40;
static const ShortInt MAX_IV_SIZE = 0x10;
extern PACKAGE int __fastcall makeKey(PkeyInstance key, System::Byte direction, int keyLen, char * keyMaterial);
extern PACKAGE int __fastcall cipherInit(PcipherInstance cipher, System::Byte mode, System::WideChar * IV);
extern PACKAGE int __fastcall blocksEnCrypt(PcipherInstance cipher, PkeyInstance key, PByte input, int inputLen, PByte outBuffer);
extern PACKAGE int __fastcall blocksDeCrypt(PcipherInstance cipher, PkeyInstance key, PByte input, int inputLen, PByte outBuffer);
extern PACKAGE int __fastcall cipherUpdateRounds(PcipherInstance cipher, PkeyInstance key, PByte input, int inputLen, PByte outBuffer, int iRounds);

}	/* namespace Rc_apiref */
using namespace Rc_apiref;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Rc_apirefHPP
