// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserversessionmanager.pas' rev: 21.00

#ifndef FrxserversessionmanagerHPP
#define FrxserversessionmanagerHPP

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
#include <Forms.hpp>	// Pascal unit
#include <Scktcomp.hpp>	// Pascal unit
#include <Frxserverreports.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserversessionmanager
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxSessionItem;
class PASCALIMPLEMENTATION TfrxSessionItem : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FActive;
	bool FCompleted;
	System::UnicodeString FName;
	Frxserverreports::TfrxReportSession* FReportThread;
	System::UnicodeString FSessionId;
	Scktcomp::TCustomWinSocket* FSocket;
	System::TDateTime FTimeComplete;
	System::TDateTime FTimeCreated;
	
public:
	__fastcall TfrxSessionItem(void);
	__fastcall virtual ~TfrxSessionItem(void);
	__property bool Active = {read=FActive, write=FActive, nodefault};
	__property System::UnicodeString SessionId = {read=FSessionId, write=FSessionId};
	__property Scktcomp::TCustomWinSocket* Socket = {read=FSocket, write=FSocket};
	__property bool Completed = {read=FCompleted, write=FCompleted, nodefault};
	__property System::TDateTime TimeCreated = {read=FTimeCreated, write=FTimeCreated};
	__property System::TDateTime TimeComplete = {read=FTimeComplete, write=FTimeComplete};
	__property System::UnicodeString FileName = {read=FName, write=FName};
	__property Frxserverreports::TfrxReportSession* ReportThread = {read=FReportThread, write=FReportThread};
};


class DELPHICLASS TfrxSessionManager;
class PASCALIMPLEMENTATION TfrxSessionManager : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
private:
	int FCleanUpTimeOut;
	TfrxSessionItem* FSession;
	Classes::TList* FSessionList;
	System::UnicodeString FSessionPath;
	bool FShutDown;
	bool FThreadActive;
	bool __fastcall CleanUpSession(System::UnicodeString SessionId);
	void __fastcall Clear(void);
	void __fastcall DeleteSession(void);
	void __fastcall DeleteSessionFolder(const System::UnicodeString DirName);
	void __fastcall SetSessionPath(const System::UnicodeString Value);
	int __fastcall GetCount(void);
	
protected:
	virtual void __fastcall Execute(void);
	
public:
	__fastcall TfrxSessionManager(void);
	__fastcall virtual ~TfrxSessionManager(void);
	TfrxSessionItem* __fastcall AddSession(System::UnicodeString SessionId, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall CompleteSession(Scktcomp::TCustomWinSocket* Socket);
	void __fastcall CompleteSessionId(System::UnicodeString SessionId);
	TfrxSessionItem* __fastcall FindSessionBySocket(Scktcomp::TCustomWinSocket* Socket);
	TfrxSessionItem* __fastcall FindSessionById(System::UnicodeString SessionId);
	void __fastcall CleanUp(void);
	__property int CleanUpTimeOut = {read=FCleanUpTimeOut, write=FCleanUpTimeOut, nodefault};
	__property System::UnicodeString SessionPath = {read=FSessionPath, write=SetSessionPath};
	__property int Count = {read=GetCount, nodefault};
};


class DELPHICLASS TfrxOldSessionsCleanupThread;
class PASCALIMPLEMENTATION TfrxOldSessionsCleanupThread : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
private:
	System::UnicodeString FPath;
	
protected:
	virtual void __fastcall Execute(void);
	
public:
	__fastcall TfrxOldSessionsCleanupThread(const System::UnicodeString Dir);
	__property System::UnicodeString Path = {read=FPath, write=FPath};
public:
	/* TThread.Destroy */ inline __fastcall virtual ~TfrxOldSessionsCleanupThread(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxSessionManager* SessionManager;

}	/* namespace Frxserversessionmanager */
using namespace Frxserversessionmanager;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserversessionmanagerHPP
