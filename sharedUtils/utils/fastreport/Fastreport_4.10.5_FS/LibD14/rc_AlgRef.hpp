// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Rc_algref.pas' rev: 21.00

#ifndef Rc_algrefHPP
#define Rc_algrefHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Rc_algref
{
//-- type declarations -------------------------------------------------------
typedef System::Byte word8;

typedef System::Word word16;

typedef unsigned word32;

typedef StaticArray<StaticArray<System::Byte, 8>, 4> TArrayK;

typedef TArrayK *PArrayK;

typedef StaticArray<StaticArray<StaticArray<System::Byte, 8>, 4>, 15> TArrayRK;

typedef StaticArray<System::Byte, 256> TArrayBox;

//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAXBC = 0x8;
static const ShortInt MAXKC = 0x8;
static const ShortInt MAXROUNDS = 0xe;
extern PACKAGE int __fastcall rijndaelKeySched(StaticArray<System::Byte, 8> *k, int keyBits, int blockBits, StaticArray<StaticArray<System::Byte, 8>, 4> *W);
extern PACKAGE int __fastcall rijndaelEncrypt(StaticArray<System::Byte, 8> *a, int keyBits, int blockBits, StaticArray<StaticArray<System::Byte, 8>, 4> *rk);
extern PACKAGE int __fastcall rijndaelEncryptRound(StaticArray<System::Byte, 8> *a, int keyBits, int blockBits, StaticArray<StaticArray<System::Byte, 8>, 4> *rk, int &irounds);
extern PACKAGE int __fastcall rijndaelDecrypt(StaticArray<System::Byte, 8> *a, int keyBits, int blockBits, StaticArray<StaticArray<System::Byte, 8>, 4> *rk);
extern PACKAGE int __fastcall rijndaelDecryptRound(StaticArray<System::Byte, 8> *a, int keyBits, int blockBits, StaticArray<StaticArray<System::Byte, 8>, 4> *rk, int &irounds);

}	/* namespace Rc_algref */
using namespace Rc_algref;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Rc_algrefHPP
