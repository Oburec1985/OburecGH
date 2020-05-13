// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcllogic.pas' rev: 21.00

#ifndef JcllogicHPP
#define JcllogicHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcllogic
{
//-- type declarations -------------------------------------------------------
typedef System::Byte TBitRange;

typedef DynamicArray<bool> TBooleanArray;

//-- var, const, procedure ---------------------------------------------------
static const ShortInt BitsPerNibble = 0x4;
static const ShortInt BitsPerByte = 0x8;
static const ShortInt BitsPerShortint = 0x8;
static const ShortInt BitsPerSmallint = 0x10;
static const ShortInt BitsPerWord = 0x10;
static const ShortInt BitsPerInteger = 0x20;
static const ShortInt BitsPerCardinal = 0x20;
static const ShortInt BitsPerInt64 = 0x40;
static const ShortInt NibblesPerByte = 0x2;
static const ShortInt NibblesPerShortint = 0x2;
static const ShortInt NibblesPerSmallint = 0x4;
static const ShortInt NibblesPerWord = 0x4;
static const ShortInt NibblesPerInteger = 0x8;
static const ShortInt NibblesPerCardinal = 0x8;
static const ShortInt NibblesPerInt64 = 0x10;
static const ShortInt NibbleMask = 0xf;
static const System::Byte ByteMask = 0xff;
static const System::ShortInt ShortintMask = -1;
static const short SmallintMask = -1;
static const System::Word WordMask = 0xffff;
static const int IntegerMask = -1;
static const unsigned CardinalMask = 0xffffffff;
static const __int64 Int64Mask = -0x0000000000000001LL;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE System::UnicodeString __fastcall OrdToBinary(System::Byte Value)/* overload */;
extern PACKAGE System::UnicodeString __fastcall OrdToBinary(System::ShortInt Value)/* overload */;
extern PACKAGE System::UnicodeString __fastcall OrdToBinary(short Value)/* overload */;
extern PACKAGE System::UnicodeString __fastcall OrdToBinary(System::Word Value)/* overload */;
extern PACKAGE System::UnicodeString __fastcall OrdToBinary(int Value)/* overload */;
extern PACKAGE System::UnicodeString __fastcall OrdToBinary(unsigned Value)/* overload */;
extern PACKAGE System::UnicodeString __fastcall OrdToBinary(__int64 Value)/* overload */;
extern PACKAGE int __fastcall BitsHighest(unsigned X)/* overload */;
extern PACKAGE int __fastcall BitsHighest(int X)/* overload */;
extern PACKAGE int __fastcall BitsHighest(System::Byte X)/* overload */;
extern PACKAGE int __fastcall BitsHighest(System::Word X)/* overload */;
extern PACKAGE int __fastcall BitsHighest(short X)/* overload */;
extern PACKAGE int __fastcall BitsHighest(System::ShortInt X)/* overload */;
extern PACKAGE int __fastcall BitsHighest(__int64 X)/* overload */;
extern PACKAGE int __fastcall BitsLowest(unsigned X)/* overload */;
extern PACKAGE int __fastcall BitsLowest(int X)/* overload */;
extern PACKAGE int __fastcall BitsLowest(System::Byte X)/* overload */;
extern PACKAGE int __fastcall BitsLowest(System::ShortInt X)/* overload */;
extern PACKAGE int __fastcall BitsLowest(short X)/* overload */;
extern PACKAGE int __fastcall BitsLowest(System::Word X)/* overload */;
extern PACKAGE int __fastcall BitsLowest(__int64 X)/* overload */;
extern PACKAGE System::Byte __fastcall ClearBit(const System::Byte Value, const System::Byte Bit)/* overload */;
extern PACKAGE System::ShortInt __fastcall ClearBit(const System::ShortInt Value, const System::Byte Bit)/* overload */;
extern PACKAGE short __fastcall ClearBit(const short Value, const System::Byte Bit)/* overload */;
extern PACKAGE System::Word __fastcall ClearBit(const System::Word Value, const System::Byte Bit)/* overload */;
extern PACKAGE unsigned __fastcall ClearBit(const unsigned Value, const System::Byte Bit)/* overload */;
extern PACKAGE int __fastcall ClearBit(const int Value, const System::Byte Bit)/* overload */;
extern PACKAGE __int64 __fastcall ClearBit(const __int64 Value, const System::Byte Bit)/* overload */;
extern PACKAGE void __fastcall ClearBitBuffer(void *Value, const unsigned Bit)/* overload */;
extern PACKAGE int __fastcall CountBitsSet(unsigned X)/* overload */;
extern PACKAGE int __fastcall CountBitsSet(System::Byte X)/* overload */;
extern PACKAGE int __fastcall CountBitsSet(System::Word X)/* overload */;
extern PACKAGE int __fastcall CountBitsSet(short X)/* overload */;
extern PACKAGE int __fastcall CountBitsSet(System::ShortInt X)/* overload */;
extern PACKAGE int __fastcall CountBitsSet(int X)/* overload */;
extern PACKAGE unsigned __fastcall CountBitsSet(void * P, unsigned Count)/* overload */;
extern PACKAGE int __fastcall CountBitsSet(__int64 X)/* overload */;
extern PACKAGE int __fastcall CountBitsCleared(System::Byte X)/* overload */;
extern PACKAGE int __fastcall CountBitsCleared(System::ShortInt X)/* overload */;
extern PACKAGE int __fastcall CountBitsCleared(short X)/* overload */;
extern PACKAGE int __fastcall CountBitsCleared(System::Word X)/* overload */;
extern PACKAGE int __fastcall CountBitsCleared(int X)/* overload */;
extern PACKAGE int __fastcall CountBitsCleared(unsigned X)/* overload */;
extern PACKAGE int __fastcall CountBitsCleared(__int64 X)/* overload */;
extern PACKAGE unsigned __fastcall CountBitsCleared(void * P, unsigned Count)/* overload */;
extern PACKAGE System::Byte __fastcall LRot(const System::Byte Value, const System::Byte Count)/* overload */;
extern PACKAGE System::Word __fastcall LRot(const System::Word Value, const System::Byte Count)/* overload */;
extern PACKAGE int __fastcall LRot(const int Value, const System::Byte Count)/* overload */;
extern PACKAGE __int64 __fastcall LRot(const __int64 Value, const System::Byte Count)/* overload */;
extern PACKAGE __int64 __fastcall RRot(const __int64 Value, const System::Byte Count)/* overload */;
extern PACKAGE System::Byte __fastcall ReverseBits(System::Byte Value)/* overload */;
extern PACKAGE System::ShortInt __fastcall ReverseBits(System::ShortInt Value)/* overload */;
extern PACKAGE short __fastcall ReverseBits(short Value)/* overload */;
extern PACKAGE System::Word __fastcall ReverseBits(System::Word Value)/* overload */;
extern PACKAGE int __fastcall ReverseBits(int Value)/* overload */;
extern PACKAGE unsigned __fastcall ReverseBits(unsigned Value)/* overload */;
extern PACKAGE __int64 __fastcall ReverseBits(__int64 Value)/* overload */;
extern PACKAGE void * __fastcall ReverseBits(void * P, int Count)/* overload */;
extern PACKAGE System::Byte __fastcall RRot(const System::Byte Value, const System::Byte Count)/* overload */;
extern PACKAGE System::Word __fastcall RRot(const System::Word Value, const System::Byte Count)/* overload */;
extern PACKAGE int __fastcall RRot(const int Value, const System::Byte Count)/* overload */;
extern PACKAGE System::ShortInt __fastcall Sar(const System::ShortInt Value, const System::Byte Count)/* overload */;
extern PACKAGE short __fastcall Sar(const short Value, const System::Byte Count)/* overload */;
extern PACKAGE int __fastcall Sar(const int Value, const System::Byte Count)/* overload */;
extern PACKAGE System::Byte __fastcall SetBit(const System::Byte Value, const System::Byte Bit)/* overload */;
extern PACKAGE System::ShortInt __fastcall SetBit(const System::ShortInt Value, const System::Byte Bit)/* overload */;
extern PACKAGE short __fastcall SetBit(const short Value, const System::Byte Bit)/* overload */;
extern PACKAGE System::Word __fastcall SetBit(const System::Word Value, const System::Byte Bit)/* overload */;
extern PACKAGE unsigned __fastcall SetBit(const unsigned Value, const System::Byte Bit)/* overload */;
extern PACKAGE int __fastcall SetBit(const int Value, const System::Byte Bit)/* overload */;
extern PACKAGE __int64 __fastcall SetBit(const __int64 Value, const System::Byte Bit)/* overload */;
extern PACKAGE void __fastcall SetBitBuffer(void *Value, const unsigned Bit)/* overload */;
extern PACKAGE bool __fastcall TestBit(const System::Byte Value, const System::Byte Bit)/* overload */;
extern PACKAGE bool __fastcall TestBit(const System::ShortInt Value, const System::Byte Bit)/* overload */;
extern PACKAGE bool __fastcall TestBit(const short Value, const System::Byte Bit)/* overload */;
extern PACKAGE bool __fastcall TestBit(const System::Word Value, const System::Byte Bit)/* overload */;
extern PACKAGE bool __fastcall TestBit(const unsigned Value, const System::Byte Bit)/* overload */;
extern PACKAGE bool __fastcall TestBit(const int Value, const System::Byte Bit)/* overload */;
extern PACKAGE bool __fastcall TestBit(const __int64 Value, const System::Byte Bit)/* overload */;
extern PACKAGE bool __fastcall TestBitBuffer(const void *Value, const unsigned Bit)/* overload */;
extern PACKAGE bool __fastcall TestBits(const System::Byte Value, const System::Byte Mask)/* overload */;
extern PACKAGE bool __fastcall TestBits(const System::ShortInt Value, const System::ShortInt Mask)/* overload */;
extern PACKAGE bool __fastcall TestBits(const short Value, const short Mask)/* overload */;
extern PACKAGE bool __fastcall TestBits(const System::Word Value, const System::Word Mask)/* overload */;
extern PACKAGE bool __fastcall TestBits(const unsigned Value, const unsigned Mask)/* overload */;
extern PACKAGE bool __fastcall TestBits(const int Value, const int Mask)/* overload */;
extern PACKAGE bool __fastcall TestBits(const __int64 Value, const __int64 Mask)/* overload */;
extern PACKAGE System::Byte __fastcall ToggleBit(const System::Byte Value, const System::Byte Bit)/* overload */;
extern PACKAGE System::ShortInt __fastcall ToggleBit(const System::ShortInt Value, const System::Byte Bit)/* overload */;
extern PACKAGE short __fastcall ToggleBit(const short Value, const System::Byte Bit)/* overload */;
extern PACKAGE System::Word __fastcall ToggleBit(const System::Word Value, const System::Byte Bit)/* overload */;
extern PACKAGE unsigned __fastcall ToggleBit(const unsigned Value, const System::Byte Bit)/* overload */;
extern PACKAGE int __fastcall ToggleBit(const int Value, const System::Byte Bit)/* overload */;
extern PACKAGE __int64 __fastcall ToggleBit(const __int64 Value, const System::Byte Bit)/* overload */;
extern PACKAGE void __fastcall ToggleBitBuffer(void *Value, const unsigned Bit)/* overload */;
extern PACKAGE void __fastcall BooleansToBits(System::Byte &Dest, const TBooleanArray B)/* overload */;
extern PACKAGE void __fastcall BooleansToBits(System::Word &Dest, const TBooleanArray B)/* overload */;
extern PACKAGE void __fastcall BooleansToBits(int &Dest, const TBooleanArray B)/* overload */;
extern PACKAGE void __fastcall BooleansToBits(__int64 &Dest, const TBooleanArray B)/* overload */;
extern PACKAGE void __fastcall BitsToBooleans(const System::Byte Bits, TBooleanArray &B, bool AllBits = false)/* overload */;
extern PACKAGE void __fastcall BitsToBooleans(const System::Word Bits, TBooleanArray &B, bool AllBits = false)/* overload */;
extern PACKAGE void __fastcall BitsToBooleans(const int Bits, TBooleanArray &B, bool AllBits = false)/* overload */;
extern PACKAGE void __fastcall BitsToBooleans(const __int64 Bits, TBooleanArray &B, bool AllBits = false)/* overload */;
extern PACKAGE int __fastcall Digits(const unsigned X);
extern PACKAGE int __fastcall BitsNeeded(const System::Byte X)/* overload */;
extern PACKAGE int __fastcall BitsNeeded(const System::Word X)/* overload */;
extern PACKAGE int __fastcall BitsNeeded(const int X)/* overload */;
extern PACKAGE int __fastcall BitsNeeded(const __int64 X)/* overload */;
extern PACKAGE System::Word __fastcall ReverseBytes(System::Word Value)/* overload */;
extern PACKAGE short __fastcall ReverseBytes(short Value)/* overload */;
extern PACKAGE int __fastcall ReverseBytes(int Value)/* overload */;
extern PACKAGE unsigned __fastcall ReverseBytes(unsigned Value)/* overload */;
extern PACKAGE __int64 __fastcall ReverseBytes(__int64 Value)/* overload */;
extern PACKAGE void * __fastcall ReverseBytes(void * P, int Count)/* overload */;
extern PACKAGE void __fastcall SwapOrd(System::Byte &I, System::Byte &J)/* overload */;
extern PACKAGE void __fastcall SwapOrd(unsigned &I, unsigned &J)/* overload */;
extern PACKAGE void __fastcall SwapOrd(int &I, int &J)/* overload */;
extern PACKAGE void __fastcall SwapOrd(__int64 &I, __int64 &J)/* overload */;
extern PACKAGE void __fastcall SwapOrd(System::ShortInt &I, System::ShortInt &J)/* overload */;
extern PACKAGE void __fastcall SwapOrd(short &I, short &J)/* overload */;
extern PACKAGE void __fastcall SwapOrd(System::Word &I, System::Word &J)/* overload */;
extern PACKAGE System::Byte __fastcall IncLimit(System::Byte &B, const System::Byte Limit, const System::Byte Incr = (System::Byte)(0x1))/* overload */;
extern PACKAGE System::ShortInt __fastcall IncLimit(System::ShortInt &B, const System::ShortInt Limit, const System::ShortInt Incr = (System::ShortInt)(0x1))/* overload */;
extern PACKAGE short __fastcall IncLimit(short &B, const short Limit, const short Incr = (short)(0x1))/* overload */;
extern PACKAGE System::Word __fastcall IncLimit(System::Word &B, const System::Word Limit, const System::Word Incr = (System::Word)(0x1))/* overload */;
extern PACKAGE int __fastcall IncLimit(int &B, const int Limit, const int Incr = 0x1)/* overload */;
extern PACKAGE unsigned __fastcall IncLimit(unsigned &B, const unsigned Limit, const unsigned Incr = (unsigned)(0x1))/* overload */;
extern PACKAGE __int64 __fastcall IncLimit(__int64 &B, const __int64 Limit, const __int64 Incr = 0x000000001)/* overload */;
extern PACKAGE System::Byte __fastcall DecLimit(System::Byte &B, const System::Byte Limit, const System::Byte Decr = (System::Byte)(0x1))/* overload */;
extern PACKAGE System::ShortInt __fastcall DecLimit(System::ShortInt &B, const System::ShortInt Limit, const System::ShortInt Decr = (System::ShortInt)(0x1))/* overload */;
extern PACKAGE short __fastcall DecLimit(short &B, const short Limit, const short Decr = (short)(0x1))/* overload */;
extern PACKAGE System::Word __fastcall DecLimit(System::Word &B, const System::Word Limit, const System::Word Decr = (System::Word)(0x1))/* overload */;
extern PACKAGE int __fastcall DecLimit(int &B, const int Limit, const int Decr = 0x1)/* overload */;
extern PACKAGE unsigned __fastcall DecLimit(unsigned &B, const unsigned Limit, const unsigned Decr = (unsigned)(0x1))/* overload */;
extern PACKAGE __int64 __fastcall DecLimit(__int64 &B, const __int64 Limit, const __int64 Decr = 0x000000001)/* overload */;
extern PACKAGE System::Byte __fastcall IncLimitClamp(System::Byte &B, const System::Byte Limit, const System::Byte Incr = (System::Byte)(0x1))/* overload */;
extern PACKAGE System::ShortInt __fastcall IncLimitClamp(System::ShortInt &B, const System::ShortInt Limit, const System::ShortInt Incr = (System::ShortInt)(0x1))/* overload */;
extern PACKAGE short __fastcall IncLimitClamp(short &B, const short Limit, const short Incr = (short)(0x1))/* overload */;
extern PACKAGE System::Word __fastcall IncLimitClamp(System::Word &B, const System::Word Limit, const System::Word Incr = (System::Word)(0x1))/* overload */;
extern PACKAGE int __fastcall IncLimitClamp(int &B, const int Limit, const int Incr = 0x1)/* overload */;
extern PACKAGE unsigned __fastcall IncLimitClamp(unsigned &B, const unsigned Limit, const unsigned Incr = (unsigned)(0x1))/* overload */;
extern PACKAGE __int64 __fastcall IncLimitClamp(__int64 &B, const __int64 Limit, const __int64 Incr = 0x000000001)/* overload */;
extern PACKAGE System::Byte __fastcall DecLimitClamp(System::Byte &B, const System::Byte Limit, const System::Byte Decr = (System::Byte)(0x1))/* overload */;
extern PACKAGE System::ShortInt __fastcall DecLimitClamp(System::ShortInt &B, const System::ShortInt Limit, const System::ShortInt Decr = (System::ShortInt)(0x1))/* overload */;
extern PACKAGE short __fastcall DecLimitClamp(short &B, const short Limit, const short Decr = (short)(0x1))/* overload */;
extern PACKAGE System::Word __fastcall DecLimitClamp(System::Word &B, const System::Word Limit, const System::Word Decr = (System::Word)(0x1))/* overload */;
extern PACKAGE int __fastcall DecLimitClamp(int &B, const int Limit, const int Decr = 0x1)/* overload */;
extern PACKAGE unsigned __fastcall DecLimitClamp(unsigned &B, const unsigned Limit, const unsigned Decr = (unsigned)(0x1))/* overload */;
extern PACKAGE __int64 __fastcall DecLimitClamp(__int64 &B, const __int64 Limit, const __int64 Decr = 0x000000001)/* overload */;
extern PACKAGE System::Byte __fastcall Max(const System::Byte B1, const System::Byte B2)/* overload */;
extern PACKAGE System::Byte __fastcall Min(const System::Byte B1, const System::Byte B2)/* overload */;
extern PACKAGE System::ShortInt __fastcall Max(const System::ShortInt B1, const System::ShortInt B2)/* overload */;
extern PACKAGE short __fastcall Max(const short B1, const short B2)/* overload */;
extern PACKAGE System::ShortInt __fastcall Min(const System::ShortInt B1, const System::ShortInt B2)/* overload */;
extern PACKAGE short __fastcall Min(const short B1, const short B2)/* overload */;
extern PACKAGE System::Word __fastcall Max(const System::Word B1, const System::Word B2)/* overload */;
extern PACKAGE __int64 __fastcall Max(const __int64 B1, const __int64 B2)/* overload */;
extern PACKAGE System::Word __fastcall Min(const System::Word B1, const System::Word B2)/* overload */;
extern PACKAGE int __fastcall Max(const int B1, const int B2)/* overload */;
extern PACKAGE int __fastcall Min(const int B1, const int B2)/* overload */;
extern PACKAGE unsigned __fastcall Max(const unsigned B1, const unsigned B2)/* overload */;
extern PACKAGE unsigned __fastcall Min(const unsigned B1, const unsigned B2)/* overload */;
extern PACKAGE __int64 __fastcall Min(const __int64 B1, const __int64 B2)/* overload */;

}	/* namespace Jcllogic */
using namespace Jcllogic;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcllogicHPP
