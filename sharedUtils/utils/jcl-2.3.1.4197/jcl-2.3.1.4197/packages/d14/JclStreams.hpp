// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclstreams.pas' rev: 21.00

#ifndef JclstreamsHPP
#define JclstreamsHPP

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
#include <Classes.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclstringconversions.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclstreams
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclStreamError;
class PASCALIMPLEMENTATION EJclStreamError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclStreamError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclStreamError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclStreamError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclStreamError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclStreamError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclStreamError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclStreamError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclStreamError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclStreamError(void) { }
	
};


class DELPHICLASS TJclStream;
class PASCALIMPLEMENTATION TJclStream : public Classes::TStream
{
	typedef Classes::TStream inherited;
	
protected:
	virtual void __fastcall SetSize(int NewSize)/* overload */;
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	virtual int __fastcall Seek(int Offset, System::Word Origin)/* overload */;
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	virtual void __fastcall LoadFromStream(Classes::TStream* Source, int BufferSize = 0x1000);
	virtual void __fastcall LoadFromFile(const Sysutils::TFileName FileName, int BufferSize = 0x1000);
	virtual void __fastcall SaveToStream(Classes::TStream* Dest, int BufferSize = 0x1000);
	virtual void __fastcall SaveToFile(const Sysutils::TFileName FileName, int BufferSize = 0x1000);
public:
	/* TObject.Create */ inline __fastcall TJclStream(void) : Classes::TStream() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclStream(void) { }
	
};


class DELPHICLASS TJclHandleStream;
class PASCALIMPLEMENTATION TJclHandleStream : public TJclStream
{
	typedef TJclStream inherited;
	
private:
	unsigned FHandle;
	
protected:
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	__fastcall TJclHandleStream(unsigned AHandle);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	__property unsigned Handle = {read=FHandle, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclHandleStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TJclFileStream;
class PASCALIMPLEMENTATION TJclFileStream : public TJclHandleStream
{
	typedef TJclHandleStream inherited;
	
public:
	__fastcall TJclFileStream(const Sysutils::TFileName FileName, System::Word Mode, unsigned Rights);
	__fastcall virtual ~TJclFileStream(void);
};


class DELPHICLASS TJclEmptyStream;
class PASCALIMPLEMENTATION TJclEmptyStream : public TJclStream
{
	typedef TJclStream inherited;
	
protected:
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
public:
	/* TObject.Create */ inline __fastcall TJclEmptyStream(void) : TJclStream() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclEmptyStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TJclNullStream;
class PASCALIMPLEMENTATION TJclNullStream : public TJclStream
{
	typedef TJclStream inherited;
	
private:
	__int64 FPosition;
	__int64 FSize;
	
protected:
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
public:
	/* TObject.Create */ inline __fastcall TJclNullStream(void) : TJclStream() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclNullStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TJclRandomStream;
class PASCALIMPLEMENTATION TJclRandomStream : public TJclNullStream
{
	typedef TJclNullStream inherited;
	
protected:
	virtual int __fastcall GetRandSeed(void);
	virtual void __fastcall SetRandSeed(int Seed);
	
public:
	virtual System::Byte __fastcall RandomData(void);
	DYNAMIC void __fastcall Randomize(void);
	virtual int __fastcall Read(void *Buffer, int Count);
	__property int RandSeed = {read=GetRandSeed, write=SetRandSeed, nodefault};
public:
	/* TObject.Create */ inline __fastcall TJclRandomStream(void) : TJclNullStream() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclRandomStream(void) { }
	
};


class DELPHICLASS TJclMultiplexStream;
class PASCALIMPLEMENTATION TJclMultiplexStream : public TJclStream
{
	typedef TJclStream inherited;
	
private:
	Classes::TList* FStreams;
	int FReadStreamIndex;
	Classes::TStream* __fastcall GetStream(int Index);
	int __fastcall GetCount(void);
	void __fastcall SetStream(int Index, const Classes::TStream* Value);
	Classes::TStream* __fastcall GetReadStream(void);
	void __fastcall SetReadStream(const Classes::TStream* Value);
	void __fastcall SetReadStreamIndex(const int Value);
	
protected:
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	__fastcall TJclMultiplexStream(void);
	__fastcall virtual ~TJclMultiplexStream(void);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	int __fastcall Add(Classes::TStream* NewStream);
	void __fastcall Clear(void);
	int __fastcall Remove(Classes::TStream* AStream);
	void __fastcall Delete(const int Index);
	__property Classes::TStream* Streams[int Index] = {read=GetStream, write=SetStream};
	__property int ReadStreamIndex = {read=FReadStreamIndex, write=SetReadStreamIndex, nodefault};
	__property Classes::TStream* ReadStream = {read=GetReadStream, write=SetReadStream};
	__property int Count = {read=GetCount, nodefault};
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TJclStreamDecorator;
class PASCALIMPLEMENTATION TJclStreamDecorator : public TJclStream
{
	typedef TJclStream inherited;
	
private:
	Classes::TNotifyEvent FAfterStreamChange;
	Classes::TNotifyEvent FBeforeStreamChange;
	bool FOwnsStream;
	Classes::TStream* FStream;
	void __fastcall SetStream(Classes::TStream* Value);
	
protected:
	virtual void __fastcall DoAfterStreamChange(void);
	virtual void __fastcall DoBeforeStreamChange(void);
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	__fastcall TJclStreamDecorator(Classes::TStream* AStream, bool AOwnsStream);
	__fastcall virtual ~TJclStreamDecorator(void);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	__property Classes::TNotifyEvent AfterStreamChange = {read=FAfterStreamChange, write=FAfterStreamChange};
	__property Classes::TNotifyEvent BeforeStreamChange = {read=FBeforeStreamChange, write=FBeforeStreamChange};
	__property bool OwnsStream = {read=FOwnsStream, write=FOwnsStream, nodefault};
	__property Classes::TStream* Stream = {read=FStream, write=SetStream};
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TJclBufferedStream;
class PASCALIMPLEMENTATION TJclBufferedStream : public TJclStreamDecorator
{
	typedef TJclStreamDecorator inherited;
	
private:
	typedef DynamicArray<System::Byte> _TJclBufferedStream__1;
	
	
protected:
	_TJclBufferedStream__1 FBuffer;
	int FBufferCurrentSize;
	int FBufferMaxModifiedPos;
	int FBufferSize;
	__int64 FBufferStart;
	__int64 FPosition;
	bool __fastcall BufferHit(void);
	virtual __int64 __fastcall GetCalcedSize(void);
	virtual bool __fastcall LoadBuffer(void);
	int __fastcall ReadFromBuffer(void *Buffer, int Count, int Start);
	int __fastcall WriteToBuffer(const void *Buffer, int Count, int Start);
	virtual void __fastcall DoAfterStreamChange(void);
	virtual void __fastcall DoBeforeStreamChange(void);
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	__fastcall TJclBufferedStream(Classes::TStream* AStream, bool AOwnsStream);
	__fastcall virtual ~TJclBufferedStream(void);
	virtual void __fastcall Flush(void);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	__property int BufferSize = {read=FBufferSize, write=FBufferSize, nodefault};
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


typedef void __fastcall (__closure *TStreamNotifyEvent)(System::TObject* Sender, __int64 Position, __int64 Size);

class DELPHICLASS TJclEventStream;
class PASCALIMPLEMENTATION TJclEventStream : public TJclStreamDecorator
{
	typedef TJclStreamDecorator inherited;
	
private:
	TStreamNotifyEvent FNotification;
	void __fastcall DoNotification(void);
	
protected:
	virtual void __fastcall DoBeforeStreamChange(void);
	virtual void __fastcall DoAfterStreamChange(void);
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	__fastcall TJclEventStream(Classes::TStream* AStream, TStreamNotifyEvent ANotification, bool AOwnsStream);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	__property TStreamNotifyEvent OnNotification = {read=FNotification, write=FNotification};
public:
	/* TJclStreamDecorator.Destroy */ inline __fastcall virtual ~TJclEventStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TJclEasyStream;
class PASCALIMPLEMENTATION TJclEasyStream : public TJclStreamDecorator
{
	typedef TJclStreamDecorator inherited;
	
public:
	bool __fastcall IsEqual(Classes::TStream* Stream);
	bool __fastcall ReadBoolean(void);
	System::WideChar __fastcall ReadChar(void);
	char __fastcall ReadAnsiChar(void);
	System::WideChar __fastcall ReadWideChar(void);
	System::Byte __fastcall ReadByte(void);
	System::Currency __fastcall ReadCurrency(void);
	System::TDateTime __fastcall ReadDateTime(void);
	System::Extended __fastcall ReadExtended(void);
	double __fastcall ReadDouble(void);
	__int64 __fastcall ReadInt64(void);
	int __fastcall ReadInteger(void);
	System::UnicodeString __fastcall ReadCString(void);
	System::AnsiString __fastcall ReadCAnsiString(void);
	System::WideString __fastcall ReadCWideString(void);
	System::UnicodeString __fastcall ReadShortString(void);
	float __fastcall ReadSingle(void);
	System::UnicodeString __fastcall ReadSizedString(void);
	System::AnsiString __fastcall ReadSizedAnsiString(void);
	System::WideString __fastcall ReadSizedWideString(void);
	void __fastcall WriteBoolean(bool Value);
	void __fastcall WriteChar(System::WideChar Value);
	void __fastcall WriteAnsiChar(char Value);
	void __fastcall WriteWideChar(System::WideChar Value);
	void __fastcall WriteByte(System::Byte Value);
	void __fastcall WriteCurrency(const System::Currency Value);
	void __fastcall WriteDateTime(const System::TDateTime Value);
	void __fastcall WriteExtended(const System::Extended Value);
	void __fastcall WriteDouble(const double Value);
	void __fastcall WriteInt64(__int64 Value)/* overload */;
	void __fastcall WriteInteger(int Value)/* overload */;
	void __fastcall WriteCString(const System::UnicodeString Value);
	void __fastcall WriteCAnsiString(const System::AnsiString Value);
	void __fastcall WriteCWideString(const System::WideString Value);
	void __fastcall WriteShortString(const System::ShortString &Value);
	void __fastcall WriteSingle(const float Value);
	void __fastcall WriteSizedString(const System::UnicodeString Value);
	void __fastcall WriteSizedAnsiString(const System::AnsiString Value);
	void __fastcall WriteSizedWideString(const System::WideString Value);
public:
	/* TJclStreamDecorator.Create */ inline __fastcall TJclEasyStream(Classes::TStream* AStream, bool AOwnsStream) : TJclStreamDecorator(AStream, AOwnsStream) { }
	/* TJclStreamDecorator.Destroy */ inline __fastcall virtual ~TJclEasyStream(void) { }
	
};


class DELPHICLASS TJclScopedStream;
class PASCALIMPLEMENTATION TJclScopedStream : public TJclStream
{
	typedef TJclStream inherited;
	
private:
	Classes::TStream* FParentStream;
	__int64 FStartPos;
	__int64 FCurrentPos;
	__int64 FMaxSize;
	
protected:
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	__fastcall TJclScopedStream(Classes::TStream* AParentStream, const __int64 AMaxSize)/* overload */;
	__fastcall TJclScopedStream(Classes::TStream* AParentStream, const __int64 AStartPos, const __int64 AMaxSize)/* overload */;
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	__property Classes::TStream* ParentStream = {read=FParentStream};
	__property __int64 StartPos = {read=FStartPos};
	__property __int64 MaxSize = {read=FMaxSize, write=FMaxSize};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclScopedStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


typedef __int64 __fastcall (__closure *TJclStreamSeekEvent)(System::TObject* Sender, const __int64 Offset, Classes::TSeekOrigin Origin);

typedef int __fastcall (__closure *TJclStreamReadEvent)(System::TObject* Sender, void *Buffer, int Count);

typedef int __fastcall (__closure *TJclStreamWriteEvent)(System::TObject* Sender, const void *Buffer, int Count);

typedef void __fastcall (__closure *TJclStreamSizeEvent)(System::TObject* Sender, const __int64 NewSize);

class DELPHICLASS TJclDelegatedStream;
class PASCALIMPLEMENTATION TJclDelegatedStream : public TJclStream
{
	typedef TJclStream inherited;
	
private:
	TJclStreamSeekEvent FOnSeek;
	TJclStreamReadEvent FOnRead;
	TJclStreamWriteEvent FOnWrite;
	TJclStreamSizeEvent FOnSize;
	
protected:
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	__property TJclStreamSeekEvent OnSeek = {read=FOnSeek, write=FOnSeek};
	__property TJclStreamReadEvent OnRead = {read=FOnRead, write=FOnRead};
	__property TJclStreamWriteEvent OnWrite = {read=FOnWrite, write=FOnWrite};
	__property TJclStreamSizeEvent OnSize = {read=FOnSize, write=FOnSize};
public:
	/* TObject.Create */ inline __fastcall TJclDelegatedStream(void) : TJclStream() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDelegatedStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


class DELPHICLASS TJclSectoredStream;
class PASCALIMPLEMENTATION TJclSectoredStream : public TJclBufferedStream
{
	typedef TJclBufferedStream inherited;
	
protected:
	int FSectorOverHead;
	__int64 __fastcall FlatToSectored(const __int64 Position);
	__int64 __fastcall SectoredToFlat(const __int64 Position);
	virtual __int64 __fastcall GetCalcedSize(void);
	virtual bool __fastcall LoadBuffer(void);
	virtual void __fastcall DoAfterStreamChange(void);
	virtual void __fastcall AfterBlockRead(void);
	virtual void __fastcall BeforeBlockWrite(void);
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	
public:
	__fastcall TJclSectoredStream(Classes::TStream* AStorageStream, bool AOwnsStream, int ASectorOverHead);
	virtual void __fastcall Flush(void);
public:
	/* TJclBufferedStream.Destroy */ inline __fastcall virtual ~TJclSectoredStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
};


class DELPHICLASS TJclCRC16Stream;
class PASCALIMPLEMENTATION TJclCRC16Stream : public TJclSectoredStream
{
	typedef TJclSectoredStream inherited;
	
protected:
	virtual void __fastcall AfterBlockRead(void);
	virtual void __fastcall BeforeBlockWrite(void);
	
public:
	__fastcall TJclCRC16Stream(Classes::TStream* AStorageStream, bool AOwnsStream);
public:
	/* TJclBufferedStream.Destroy */ inline __fastcall virtual ~TJclCRC16Stream(void) { }
	
};


class DELPHICLASS TJclCRC32Stream;
class PASCALIMPLEMENTATION TJclCRC32Stream : public TJclSectoredStream
{
	typedef TJclSectoredStream inherited;
	
protected:
	virtual void __fastcall AfterBlockRead(void);
	virtual void __fastcall BeforeBlockWrite(void);
	
public:
	__fastcall TJclCRC32Stream(Classes::TStream* AStorageStream, bool AOwnsStream);
public:
	/* TJclBufferedStream.Destroy */ inline __fastcall virtual ~TJclCRC32Stream(void) { }
	
};


class DELPHICLASS TJclSplitStream;
class PASCALIMPLEMENTATION TJclSplitStream : public TJclStream
{
	typedef TJclStream inherited;
	
private:
	Classes::TStream* FVolume;
	int FVolumeIndex;
	__int64 FVolumeMaxSize;
	__int64 FPosition;
	__int64 FVolumePosition;
	bool FForcePosition;
	
protected:
	virtual Classes::TStream* __fastcall GetVolume(int Index) = 0 ;
	virtual __int64 __fastcall GetVolumeMaxSize(int Index) = 0 ;
	virtual __int64 __fastcall GetSize(void);
	virtual void __fastcall SetSize(const __int64 NewSize)/* overload */;
	bool __fastcall InternalLoadVolume(int Index);
	
public:
	__fastcall TJclSplitStream(bool AForcePosition);
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin)/* overload */;
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	__property bool ForcePosition = {read=FForcePosition, write=FForcePosition, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSplitStream(void) { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(int NewSize){ TJclStream::SetSize(NewSize); }
	
public:
	inline int __fastcall  Seek(int Offset, System::Word Origin){ return TJclStream::Seek(Offset, Origin); }
	
};


typedef Classes::TStream* __fastcall (__closure *TJclVolumeEvent)(int Index);

typedef __int64 __fastcall (__closure *TJclVolumeMaxSizeEvent)(int Index);

class DELPHICLASS TJclDynamicSplitStream;
class PASCALIMPLEMENTATION TJclDynamicSplitStream : public TJclSplitStream
{
	typedef TJclSplitStream inherited;
	
private:
	TJclVolumeEvent FOnVolume;
	TJclVolumeMaxSizeEvent FOnVolumeMaxSize;
	
protected:
	virtual Classes::TStream* __fastcall GetVolume(int Index);
	virtual __int64 __fastcall GetVolumeMaxSize(int Index);
	
public:
	__property TJclVolumeEvent OnVolume = {read=FOnVolume, write=FOnVolume};
	__property TJclVolumeMaxSizeEvent OnVolumeMaxSize = {read=FOnVolumeMaxSize, write=FOnVolumeMaxSize};
public:
	/* TJclSplitStream.Create */ inline __fastcall TJclDynamicSplitStream(bool AForcePosition) : TJclSplitStream(AForcePosition) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclDynamicSplitStream(void) { }
	
};


class DELPHICLASS TJclSplitVolume;
class PASCALIMPLEMENTATION TJclSplitVolume : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__int64 MaxSize;
	Classes::TStream* Stream;
	bool OwnStream;
public:
	/* TObject.Create */ inline __fastcall TJclSplitVolume(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSplitVolume(void) { }
	
};


class DELPHICLASS TJclStaticSplitStream;
class PASCALIMPLEMENTATION TJclStaticSplitStream : public TJclSplitStream
{
	typedef TJclSplitStream inherited;
	
private:
	Contnrs::TObjectList* FVolumes;
	int __fastcall GetVolumeCount(void);
	
protected:
	virtual Classes::TStream* __fastcall GetVolume(int Index);
	virtual __int64 __fastcall GetVolumeMaxSize(int Index);
	
public:
	__fastcall TJclStaticSplitStream(bool AForcePosition);
	__fastcall virtual ~TJclStaticSplitStream(void);
	int __fastcall AddVolume(Classes::TStream* AStream, __int64 AMaxSize = 0x000000000, bool AOwnStream = false);
	__property int VolumeCount = {read=GetVolumeCount, nodefault};
	__property Classes::TStream* Volumes[int Index] = {read=GetVolume};
	__property __int64 VolumeMaxSizes[int Index] = {read=GetVolumeMaxSize};
};


class DELPHICLASS TJclStringStream;
class PASCALIMPLEMENTATION TJclStringStream : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<System::Byte> _TJclStringStream__1;
	
	
protected:
	Classes::TStream* FStream;
	bool FOwnStream;
	_TJclStringStream__1 FBOM;
	int FBufferSize;
	__int64 FStrPosition;
	Jclbase::TUCS4Array FStrBuffer;
	__int64 FStrBufferPosition;
	__int64 FStrBufferCurrentSize;
	__int64 FStrBufferModifiedSize;
	__int64 FStrBufferStart;
	__int64 FStrBufferNext;
	__int64 FStrPeekPosition;
	Jclbase::TUCS4Array FStrPeekBuffer;
	__int64 FStrPeekBufferPosition;
	int FStrPeekBufferCurrentSize;
	__int64 FStrPeekBufferStart;
	__int64 FStrPeekBufferNext;
	bool __fastcall LoadBuffer(void);
	bool __fastcall LoadPeekBuffer(void);
	virtual bool __fastcall InternalGetNextChar(Classes::TStream* S, /* out */ unsigned &Ch) = 0 ;
	virtual int __fastcall InternalGetNextBuffer(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int Start, int Count);
	virtual bool __fastcall InternalSetNextChar(Classes::TStream* S, unsigned Ch) = 0 ;
	virtual int __fastcall InternalSetNextBuffer(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int Start, int Count);
	void __fastcall InvalidateBuffers(void);
	
public:
	__fastcall virtual TJclStringStream(Classes::TStream* AStream, bool AOwnsStream);
	__fastcall virtual ~TJclStringStream(void);
	virtual void __fastcall Flush(void);
	int __fastcall ReadString(System::UnicodeString &Buffer, int Start, int Count)/* overload */;
	System::UnicodeString __fastcall ReadString(int BufferSize = 0x1000)/* overload */;
	int __fastcall ReadAnsiString(System::AnsiString &Buffer, int Start, int Count)/* overload */;
	System::AnsiString __fastcall ReadAnsiString(int BufferSize = 0x1000)/* overload */;
	int __fastcall ReadWideString(System::WideString &Buffer, int Start, int Count)/* overload */;
	System::WideString __fastcall ReadWideString(int BufferSize = 0x1000)/* overload */;
	virtual __int64 __fastcall Seek(const __int64 Offset, Classes::TSeekOrigin Origin);
	int __fastcall WriteString(const System::UnicodeString Buffer, int Start, int Count);
	int __fastcall WriteAnsiString(const System::AnsiString Buffer, int Start, int Count);
	int __fastcall WriteWideString(const System::WideString Buffer, int Start, int Count);
	bool __fastcall PeekChar(/* out */ System::WideChar &Buffer);
	bool __fastcall PeekAnsiChar(/* out */ char &Buffer);
	bool __fastcall PeekUCS4(/* out */ unsigned &Buffer);
	bool __fastcall PeekWideChar(/* out */ System::WideChar &Buffer);
	bool __fastcall ReadChar(/* out */ System::WideChar &Buffer);
	bool __fastcall ReadAnsiChar(/* out */ char &Buffer);
	bool __fastcall ReadUCS4(/* out */ unsigned &Buffer);
	bool __fastcall ReadWideChar(/* out */ System::WideChar &Buffer);
	bool __fastcall WriteChar(System::WideChar Value);
	bool __fastcall WriteAnsiChar(char Value);
	bool __fastcall WriteUCS4(unsigned Value);
	bool __fastcall WriteWideChar(System::WideChar Value);
	virtual int __fastcall SkipBOM(void);
	virtual int __fastcall WriteBOM(void);
	__property int BufferSize = {read=FBufferSize, write=FBufferSize, nodefault};
	__property __int64 PeekPosition = {read=FStrPeekPosition};
	__property __int64 Position = {read=FStrPosition};
	__property Classes::TStream* Stream = {read=FStream};
	__property bool OwnStream = {read=FOwnStream, nodefault};
};


typedef TMetaClass* TJclStringStreamClass;

class DELPHICLASS TJclAnsiStream;
class PASCALIMPLEMENTATION TJclAnsiStream : public TJclStringStream
{
	typedef TJclStringStream inherited;
	
private:
	System::Word FCodePage;
	
protected:
	virtual bool __fastcall InternalGetNextChar(Classes::TStream* S, /* out */ unsigned &Ch);
	virtual int __fastcall InternalGetNextBuffer(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int Start, int Count);
	virtual bool __fastcall InternalSetNextChar(Classes::TStream* S, unsigned Ch);
	virtual int __fastcall InternalSetNextBuffer(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int Start, int Count);
	
public:
	__fastcall virtual TJclAnsiStream(Classes::TStream* AStream, bool AOwnsStream);
	__property System::Word CodePage = {read=FCodePage, write=FCodePage, nodefault};
public:
	/* TJclStringStream.Destroy */ inline __fastcall virtual ~TJclAnsiStream(void) { }
	
};


class DELPHICLASS TJclUTF8Stream;
class PASCALIMPLEMENTATION TJclUTF8Stream : public TJclStringStream
{
	typedef TJclStringStream inherited;
	
protected:
	virtual bool __fastcall InternalGetNextChar(Classes::TStream* S, /* out */ unsigned &Ch);
	virtual int __fastcall InternalGetNextBuffer(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int Start, int Count);
	virtual bool __fastcall InternalSetNextChar(Classes::TStream* S, unsigned Ch);
	virtual int __fastcall InternalSetNextBuffer(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int Start, int Count);
	
public:
	__fastcall virtual TJclUTF8Stream(Classes::TStream* AStream, bool AOwnsStream);
public:
	/* TJclStringStream.Destroy */ inline __fastcall virtual ~TJclUTF8Stream(void) { }
	
};


class DELPHICLASS TJclUTF16Stream;
class PASCALIMPLEMENTATION TJclUTF16Stream : public TJclStringStream
{
	typedef TJclStringStream inherited;
	
protected:
	virtual bool __fastcall InternalGetNextChar(Classes::TStream* S, /* out */ unsigned &Ch);
	virtual int __fastcall InternalGetNextBuffer(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int Start, int Count);
	virtual bool __fastcall InternalSetNextChar(Classes::TStream* S, unsigned Ch);
	virtual int __fastcall InternalSetNextBuffer(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int Start, int Count);
	
public:
	__fastcall virtual TJclUTF16Stream(Classes::TStream* AStream, bool AOwnsStream);
public:
	/* TJclStringStream.Destroy */ inline __fastcall virtual ~TJclUTF16Stream(void) { }
	
};


#pragma option push -b-
enum TJclStringEncoding { seAnsi, seUTF8, seUTF16, seAuto };
#pragma option pop

class DELPHICLASS TJclAutoStream;
class PASCALIMPLEMENTATION TJclAutoStream : public TJclStringStream
{
	typedef TJclStringStream inherited;
	
private:
	System::Word FCodePage;
	TJclStringEncoding FEncoding;
	
protected:
	virtual bool __fastcall InternalGetNextChar(Classes::TStream* S, /* out */ unsigned &Ch);
	virtual int __fastcall InternalGetNextBuffer(Classes::TStream* S, Jclbase::TUCS4Array &Buffer, int Start, int Count);
	virtual bool __fastcall InternalSetNextChar(Classes::TStream* S, unsigned Ch);
	virtual int __fastcall InternalSetNextBuffer(Classes::TStream* S, const Jclbase::TUCS4Array Buffer, int Start, int Count);
	
public:
	__fastcall virtual TJclAutoStream(Classes::TStream* AStream, bool AOwnsStream);
	virtual int __fastcall SkipBOM(void);
	__property System::Word CodePage = {read=FCodePage, write=FCodePage, nodefault};
	__property TJclStringEncoding Encoding = {read=FEncoding, nodefault};
public:
	/* TJclStringStream.Destroy */ inline __fastcall virtual ~TJclAutoStream(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const Word StreamDefaultBufferSize = 0x1000;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE __int64 __fastcall StreamCopy(Classes::TStream* Source, Classes::TStream* Dest, int BufferSize = 0x1000);
extern PACKAGE __int64 __fastcall StringStreamCopy(TJclStringStream* Source, TJclStringStream* Dest, int BufferLength = 0x1000);
extern PACKAGE __int64 __fastcall AnsiStringStreamCopy(TJclStringStream* Source, TJclStringStream* Dest, int BufferLength = 0x1000);
extern PACKAGE __int64 __fastcall WideStringStreamCopy(TJclStringStream* Source, TJclStringStream* Dest, int BufferLength = 0x1000);
extern PACKAGE bool __fastcall CompareStreams(Classes::TStream* A, Classes::TStream* B, int BufferSize = 0x1000);
extern PACKAGE bool __fastcall CompareFiles(const Sysutils::TFileName FileA, const Sysutils::TFileName FileB, int BufferSize = 0x1000);

}	/* namespace Jclstreams */
using namespace Jclstreams;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclstreamsHPP
