// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclsynch.pas' rev: 21.00

#ifndef JclsynchHPP
#define JclsynchHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Jclwin32.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclsynch
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TJclWaitResult { wrAbandoned, wrError, wrIoCompletion, wrSignaled, wrTimeout };
#pragma option pop

typedef unsigned TJclWaitHandle;

class DELPHICLASS TJclDispatcherObject;
class PASCALIMPLEMENTATION TJclDispatcherObject : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FExisted;
	unsigned FHandle;
	System::UnicodeString FName;
	
public:
	__fastcall TJclDispatcherObject(unsigned AHandle);
	__fastcall virtual ~TJclDispatcherObject(void);
	TJclWaitResult __fastcall SignalAndWait(const TJclDispatcherObject* Obj, unsigned TimeOut, bool Alertable);
	TJclWaitResult __fastcall WaitAlertable(const unsigned TimeOut);
	TJclWaitResult __fastcall WaitFor(const unsigned TimeOut);
	TJclWaitResult __fastcall WaitForever(void);
	__property bool Existed = {read=FExisted, nodefault};
	__property unsigned Handle = {read=FHandle, nodefault};
	__property System::UnicodeString Name = {read=FName};
public:
	/* TObject.Create */ inline __fastcall TJclDispatcherObject(void) : System::TObject() { }
	
};


class DELPHICLASS TJclCriticalSection;
class PASCALIMPLEMENTATION TJclCriticalSection : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	_RTL_CRITICAL_SECTION FCriticalSection;
	
public:
	__fastcall virtual TJclCriticalSection(void);
	__fastcall virtual ~TJclCriticalSection(void);
	__classmethod void __fastcall CreateAndEnter(TJclCriticalSection* &CS);
	void __fastcall Enter(void);
	void __fastcall Leave(void);
};


class DELPHICLASS TJclCriticalSectionEx;
class PASCALIMPLEMENTATION TJclCriticalSectionEx : public TJclCriticalSection
{
	typedef TJclCriticalSection inherited;
	
private:
	unsigned FSpinCount;
	unsigned __fastcall GetSpinCount(void);
	void __fastcall SetSpinCount(const unsigned Value);
	
public:
	__fastcall virtual TJclCriticalSectionEx(void);
	__fastcall virtual TJclCriticalSectionEx(unsigned SpinCount, bool NoFailEnter);
	__classmethod unsigned __fastcall GetSpinTimeOut();
	__classmethod void __fastcall SetSpinTimeOut(const unsigned Value);
	bool __fastcall TryEnter(void);
	__property unsigned SpinCount = {read=GetSpinCount, write=SetSpinCount, nodefault};
public:
	/* TJclCriticalSection.Destroy */ inline __fastcall virtual ~TJclCriticalSectionEx(void) { }
	
};


class DELPHICLASS TJclEvent;
class PASCALIMPLEMENTATION TJclEvent : public TJclDispatcherObject
{
	typedef TJclDispatcherObject inherited;
	
public:
	__fastcall TJclEvent(Windows::PSecurityAttributes SecAttr, bool Manual, bool Signaled, const System::UnicodeString Name);
	__fastcall TJclEvent(unsigned Access, bool Inheritable, const System::UnicodeString Name);
	bool __fastcall Pulse(void);
	bool __fastcall ResetEvent(void);
	bool __fastcall SetEvent(void);
public:
	/* TJclDispatcherObject.Attach */ inline __fastcall TJclEvent(unsigned AHandle) : TJclDispatcherObject(AHandle) { }
	/* TJclDispatcherObject.Destroy */ inline __fastcall virtual ~TJclEvent(void) { }
	
};


class DELPHICLASS TJclWaitableTimer;
class PASCALIMPLEMENTATION TJclWaitableTimer : public TJclDispatcherObject
{
	typedef TJclDispatcherObject inherited;
	
private:
	bool FResume;
	
public:
	__fastcall TJclWaitableTimer(Windows::PSecurityAttributes SecAttr, bool Manual, const System::UnicodeString Name);
	__fastcall TJclWaitableTimer(unsigned Access, bool Inheritable, const System::UnicodeString Name);
	bool __fastcall Cancel(void);
	bool __fastcall SetTimer(const __int64 DueTime, int Period, bool Resume);
	bool __fastcall SetTimerApc(const __int64 DueTime, int Period, bool Resume, void * Apc, void * Arg);
public:
	/* TJclDispatcherObject.Attach */ inline __fastcall TJclWaitableTimer(unsigned AHandle) : TJclDispatcherObject(AHandle) { }
	/* TJclDispatcherObject.Destroy */ inline __fastcall virtual ~TJclWaitableTimer(void) { }
	
};


class DELPHICLASS TJclSemaphore;
class PASCALIMPLEMENTATION TJclSemaphore : public TJclDispatcherObject
{
	typedef TJclDispatcherObject inherited;
	
public:
	__fastcall TJclSemaphore(Windows::PSecurityAttributes SecAttr, int Initial, int Maximum, const System::UnicodeString Name);
	__fastcall TJclSemaphore(unsigned Access, bool Inheritable, const System::UnicodeString Name);
	bool __fastcall Release(int ReleaseCount);
	bool __fastcall ReleasePrev(int ReleaseCount, int &PrevCount);
public:
	/* TJclDispatcherObject.Attach */ inline __fastcall TJclSemaphore(unsigned AHandle) : TJclDispatcherObject(AHandle) { }
	/* TJclDispatcherObject.Destroy */ inline __fastcall virtual ~TJclSemaphore(void) { }
	
};


class DELPHICLASS TJclMutex;
class PASCALIMPLEMENTATION TJclMutex : public TJclDispatcherObject
{
	typedef TJclDispatcherObject inherited;
	
public:
	__fastcall TJclMutex(Windows::PSecurityAttributes SecAttr, bool InitialOwner, const System::UnicodeString Name);
	__fastcall TJclMutex(unsigned Access, bool Inheritable, const System::UnicodeString Name);
	bool __fastcall Acquire(const unsigned TimeOut = (unsigned)(0xffffffff));
	bool __fastcall Release(void);
public:
	/* TJclDispatcherObject.Attach */ inline __fastcall TJclMutex(unsigned AHandle) : TJclDispatcherObject(AHandle) { }
	/* TJclDispatcherObject.Destroy */ inline __fastcall virtual ~TJclMutex(void) { }
	
};


struct TOptexSharedInfo;
typedef TOptexSharedInfo *POptexSharedInfo;

struct TOptexSharedInfo
{
	
public:
	int SpinCount;
	int LockCount;
	unsigned ThreadId;
	int RecursionCount;
};


class DELPHICLASS TJclOptex;
class PASCALIMPLEMENTATION TJclOptex : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclEvent* FEvent;
	bool FExisted;
	unsigned FFileMapping;
	System::UnicodeString FName;
	TOptexSharedInfo *FSharedInfo;
	bool __fastcall GetUniProcess(void);
	int __fastcall GetSpinCount(void);
	void __fastcall SetSpinCount(int Value);
	
public:
	__fastcall TJclOptex(const System::UnicodeString Name, int SpinCount);
	__fastcall virtual ~TJclOptex(void);
	void __fastcall Enter(void);
	void __fastcall Leave(void);
	bool __fastcall TryEnter(void);
	__property bool Existed = {read=FExisted, nodefault};
	__property System::UnicodeString Name = {read=FName};
	__property int SpinCount = {read=GetSpinCount, write=SetSpinCount, nodefault};
	__property bool UniProcess = {read=GetUniProcess, nodefault};
};


#pragma option push -b-
enum TMrewPreferred { mpReaders, mpWriters, mpEqual };
#pragma option pop

struct TMrewThreadInfo
{
	
public:
	unsigned ThreadId;
	int RecursionCount;
	bool Reader;
};


typedef DynamicArray<TMrewThreadInfo> TMrewThreadInfoArray;

class DELPHICLASS TJclMultiReadExclusiveWrite;
class PASCALIMPLEMENTATION TJclMultiReadExclusiveWrite : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TJclCriticalSection* FLock;
	TMrewPreferred FPreferred;
	TJclSemaphore* FSemReaders;
	TJclSemaphore* FSemWriters;
	int FState;
	TMrewThreadInfoArray FThreads;
	int FWaitingReaders;
	int FWaitingWriters;
	void __fastcall AddToThreadList(unsigned ThreadId, bool Reader);
	void __fastcall RemoveFromThreadList(int Index);
	int __fastcall FindThread(unsigned ThreadId);
	void __fastcall ReleaseWaiters(bool WasReading);
	
protected:
	void __fastcall Release(void);
	
public:
	__fastcall TJclMultiReadExclusiveWrite(TMrewPreferred Preferred);
	__fastcall virtual ~TJclMultiReadExclusiveWrite(void);
	void __fastcall BeginRead(void);
	void __fastcall BeginWrite(void);
	void __fastcall EndRead(void);
	void __fastcall EndWrite(void);
};


struct TMetSectSharedInfo;
typedef TMetSectSharedInfo *PMetSectSharedInfo;

struct TMetSectSharedInfo
{
	
public:
	BOOL Initialized;
	int SpinLock;
	int ThreadsWaiting;
	int AvailableCount;
	int MaximumCount;
};


struct TMeteredSection;
typedef TMeteredSection *PMeteredSection;

struct TMeteredSection
{
	
public:
	unsigned Event;
	unsigned FileMap;
	TMetSectSharedInfo *SharedInfo;
};


class DELPHICLASS TJclMeteredSection;
class PASCALIMPLEMENTATION TJclMeteredSection : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TMeteredSection *FMetSect;
	void __fastcall CloseMeteredSection(void);
	bool __fastcall InitMeteredSection(int InitialCount, int MaxCount, const System::UnicodeString Name, bool OpenOnly);
	bool __fastcall CreateMetSectEvent(const System::UnicodeString Name, bool OpenOnly);
	bool __fastcall CreateMetSectFileView(int InitialCount, int MaxCount, const System::UnicodeString Name, bool OpenOnly);
	
protected:
	void __fastcall AcquireLock(void);
	void __fastcall ReleaseLock(void);
	
public:
	__fastcall TJclMeteredSection(int InitialCount, int MaxCount, const System::UnicodeString Name);
	__fastcall TJclMeteredSection(const System::UnicodeString Name);
	__fastcall virtual ~TJclMeteredSection(void);
	TJclWaitResult __fastcall Enter(unsigned TimeOut);
	bool __fastcall Leave(int ReleaseCount)/* overload */;
	bool __fastcall Leave(int ReleaseCount, /* out */ int &PrevCount)/* overload */;
};


struct TEventInfo
{
	
public:
	int EventType;
	BOOL Signaled;
};


struct TMutexInfo
{
	
public:
	int SignalState;
	System::ByteBool Owned;
	System::ByteBool Abandoned;
};


struct TSemaphoreCounts
{
	
public:
	int CurrentCount;
	int MaximumCount;
};


struct TTimerInfo
{
	
public:
	__int64 Remaining;
	System::ByteBool Signaled;
};


class DELPHICLASS EJclWin32HandleObjectError;
class PASCALIMPLEMENTATION EJclWin32HandleObjectError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclWin32HandleObjectError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclWin32HandleObjectError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclWin32HandleObjectError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclWin32HandleObjectError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclWin32HandleObjectError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclWin32HandleObjectError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclWin32HandleObjectError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclWin32HandleObjectError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclWin32HandleObjectError(void) { }
	
};


class DELPHICLASS EJclDispatcherObjectError;
class PASCALIMPLEMENTATION EJclDispatcherObjectError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclDispatcherObjectError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclDispatcherObjectError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclDispatcherObjectError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclDispatcherObjectError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclDispatcherObjectError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclDispatcherObjectError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclDispatcherObjectError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclDispatcherObjectError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclDispatcherObjectError(void) { }
	
};


class DELPHICLASS EJclCriticalSectionError;
class PASCALIMPLEMENTATION EJclCriticalSectionError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclCriticalSectionError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclCriticalSectionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclCriticalSectionError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclCriticalSectionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclCriticalSectionError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclCriticalSectionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclCriticalSectionError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclCriticalSectionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclCriticalSectionError(void) { }
	
};


class DELPHICLASS EJclEventError;
class PASCALIMPLEMENTATION EJclEventError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclEventError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclEventError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclEventError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclEventError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclEventError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclEventError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclEventError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclEventError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclEventError(void) { }
	
};


class DELPHICLASS EJclWaitableTimerError;
class PASCALIMPLEMENTATION EJclWaitableTimerError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclWaitableTimerError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclWaitableTimerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclWaitableTimerError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclWaitableTimerError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclWaitableTimerError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclWaitableTimerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclWaitableTimerError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclWaitableTimerError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclWaitableTimerError(void) { }
	
};


class DELPHICLASS EJclSemaphoreError;
class PASCALIMPLEMENTATION EJclSemaphoreError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclSemaphoreError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclSemaphoreError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclSemaphoreError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclSemaphoreError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclSemaphoreError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclSemaphoreError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclSemaphoreError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclSemaphoreError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclSemaphoreError(void) { }
	
};


class DELPHICLASS EJclMutexError;
class PASCALIMPLEMENTATION EJclMutexError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclMutexError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclMutexError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclMutexError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclMutexError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMutexError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMutexError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMutexError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMutexError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMutexError(void) { }
	
};


class DELPHICLASS EJclMeteredSectionError;
class PASCALIMPLEMENTATION EJclMeteredSectionError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclMeteredSectionError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclMeteredSectionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclMeteredSectionError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclMeteredSectionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMeteredSectionError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMeteredSectionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMeteredSectionError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMeteredSectionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMeteredSectionError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE int __fastcall LockedAdd(int &Target, int Value)/* overload */;
extern PACKAGE int __fastcall LockedCompareExchange(int &Target, int Exch, int Comp)/* overload */;
extern PACKAGE void * __fastcall LockedCompareExchange(void * &Target, void * Exch, void * Comp)/* overload */;
extern PACKAGE System::TObject* __fastcall LockedCompareExchange(System::TObject* &Target, System::TObject* Exch, System::TObject* Comp)/* overload */;
extern PACKAGE int __fastcall LockedDec(int &Target)/* overload */;
extern PACKAGE int __fastcall LockedExchange(int &Target, int Value)/* overload */;
extern PACKAGE int __fastcall LockedExchangeAdd(int &Target, int Value)/* overload */;
extern PACKAGE int __fastcall LockedExchangeDec(int &Target)/* overload */;
extern PACKAGE int __fastcall LockedExchangeInc(int &Target)/* overload */;
extern PACKAGE int __fastcall LockedExchangeSub(int &Target, int Value)/* overload */;
extern PACKAGE int __fastcall LockedInc(int &Target)/* overload */;
extern PACKAGE int __fastcall LockedSub(int &Target, int Value)/* overload */;
extern PACKAGE unsigned __fastcall WaitForMultipleObjects(TJclDispatcherObject* const *Objects, const int Objects_Size, bool WaitAll, unsigned TimeOut);
extern PACKAGE unsigned __fastcall WaitAlertableForMultipleObjects(TJclDispatcherObject* const *Objects, const int Objects_Size, bool WaitAll, unsigned TimeOut);
extern PACKAGE bool __fastcall QueryCriticalSection(TJclCriticalSection* CS, _RTL_CRITICAL_SECTION &Info);
extern PACKAGE bool __fastcall QueryEvent(unsigned Handle, TEventInfo &Info);
extern PACKAGE bool __fastcall QueryMutex(unsigned Handle, TMutexInfo &Info);
extern PACKAGE bool __fastcall QuerySemaphore(unsigned Handle, TSemaphoreCounts &Info);
extern PACKAGE bool __fastcall QueryTimer(unsigned Handle, TTimerInfo &Info);
extern PACKAGE System::UnicodeString __fastcall ValidateMutexName(const System::UnicodeString aName);

}	/* namespace Jclsynch */
using namespace Jclsynch;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclsynchHPP
