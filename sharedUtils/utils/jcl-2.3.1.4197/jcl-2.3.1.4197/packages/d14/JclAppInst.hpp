// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclappinst.pas' rev: 21.00

#ifndef JclappinstHPP
#define JclappinstHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclfileutils.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit
#include <Jclwin32.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclappinst
{
//-- type declarations -------------------------------------------------------
typedef int TJclAppInstDataKind;

class DELPHICLASS TJclAppInstances;
class PASCALIMPLEMENTATION TJclAppInstances : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	unsigned FCPID;
	Jclfileutils::TJclSwapFileMapping* FAllMapping;
	Jclfileutils::TJclFileMappingView* FAllMappingView;
	Jclfileutils::TJclSwapFileMapping* FSessionMapping;
	Jclfileutils::TJclFileMappingView* FSessionMappingView;
	Jclfileutils::TJclSwapFileMapping* FUserMapping;
	Jclfileutils::TJclFileMappingView* FUserMappingView;
	unsigned FMessageID;
	Jclsynch::TJclOptex* FOptex;
	System::UnicodeString FUniqueAppID;
	unsigned __fastcall GetAllAppWnds(int Index);
	int __fastcall GetAllInstanceCount(void);
	int __fastcall GetAllInstanceIndex(unsigned ProcessID);
	unsigned __fastcall GetAllProcessIDs(int Index);
	int __fastcall GetInstanceCount(Jclfileutils::TJclFileMappingView* MappingView);
	int __fastcall GetInstanceIndex(Jclfileutils::TJclFileMappingView* MappingView, unsigned ProcessID);
	unsigned __fastcall GetProcessIDs(Jclfileutils::TJclFileMappingView* MappingView, int Index);
	unsigned __fastcall GetSessionAppWnds(int Index);
	int __fastcall GetSessionInstanceCount(void);
	int __fastcall GetSessionInstanceIndex(unsigned ProcessID);
	unsigned __fastcall GetSessionProcessIDs(int Index);
	unsigned __fastcall GetUserAppWnds(int Index);
	int __fastcall GetUserInstanceCount(void);
	int __fastcall GetUserInstanceIndex(unsigned ProcessID);
	unsigned __fastcall GetUserProcessIDs(int Index);
	
protected:
	void __fastcall InitData(void);
	void __fastcall InitAllData(void);
	void __fastcall InitSessionData(void);
	void __fastcall InitUserData(void);
	void __fastcall NotifyInstances(const int W, const int L);
	void __fastcall RemoveInstance(Jclfileutils::TJclFileMappingView* MappingView);
	void __fastcall SecurityFree(PTOKEN_USER UserInfo, void * SID, PACL ACL, Windows::PSecurityDescriptor SecurityDescriptor, Windows::PSecurityAttributes SecurityAttributes);
	void __fastcall SecurityGetAllUsers(/* out */ PTOKEN_USER &UserInfo, /* out */ void * &SID, /* out */ PACL &ACL, /* out */ Windows::PSecurityDescriptor &SecurityDescriptor, /* out */ Windows::PSecurityAttributes &SecurityAttributes);
	void __fastcall SecurityGetCurrentUser(/* out */ PTOKEN_USER &UserInfo, /* out */ void * &SID, /* out */ PACL &ACL, /* out */ Windows::PSecurityDescriptor &SecurityDescriptor, /* out */ Windows::PSecurityAttributes &SecurityAttributes);
	void __fastcall SecurityGetCurrentUserInfo(/* out */ PTOKEN_USER &UserInfo);
	void __fastcall SecurityGetSecurityAttributes(void * OwnerSID, void * AccessSID, /* out */ PACL &ACL, /* out */ Windows::PSecurityDescriptor &SecurityDescriptor, /* out */ Windows::PSecurityAttributes &SecurityAttributes);
	
public:
	__fastcall TJclAppInstances(void);
	__fastcall virtual ~TJclAppInstances(void);
	__classmethod bool __fastcall BringAppWindowToFront(const unsigned Wnd);
	__classmethod unsigned __fastcall GetApplicationWnd(const unsigned ProcessID);
	__classmethod void __fastcall KillInstance();
	__classmethod bool __fastcall SetForegroundWindow98(const unsigned Wnd);
	bool __fastcall CheckInstance(System::Word MaxInstances, System::Word MaxSessionInstances = (System::Word)(0x0), System::Word MaxUserInstances = (System::Word)(0x0));
	void __fastcall CheckMultipleInstances(System::Word MaxInstances, System::Word MaxSessionInstances = (System::Word)(0x0), System::Word MaxUserInstances = (System::Word)(0x0));
	void __fastcall CheckSingleInstance(void);
	bool __fastcall SendCmdLineParams(const System::UnicodeString WindowClassName, const unsigned OriginatorWnd);
	bool __fastcall SendData(const System::UnicodeString WindowClassName, const int DataKind, void * Data, const int Size, unsigned OriginatorWnd);
	bool __fastcall SendString(const System::UnicodeString WindowClassName, const int DataKind, const System::UnicodeString S, unsigned OriginatorWnd);
	bool __fastcall SendStrings(const System::UnicodeString WindowClassName, const int DataKind, const Classes::TStrings* Strings, unsigned OriginatorWnd);
	bool __fastcall SessionSwitchTo(int Index);
	bool __fastcall SwitchTo(int Index);
	bool __fastcall UserSwitchTo(int Index);
	void __fastcall UserNotify(int Param);
	__property unsigned AppWnds[int Index] = {read=GetAllAppWnds};
	__property int InstanceIndex[unsigned ProcessID] = {read=GetAllInstanceIndex};
	__property int InstanceCount = {read=GetAllInstanceCount, nodefault};
	__property unsigned MessageID = {read=FMessageID, nodefault};
	__property unsigned ProcessIDs[int Index] = {read=GetAllProcessIDs};
	__property unsigned SessionAppWnds[int Index] = {read=GetSessionAppWnds};
	__property int SessionInstanceIndex[unsigned ProcessID] = {read=GetSessionInstanceIndex};
	__property int SessionInstanceCount = {read=GetSessionInstanceCount, nodefault};
	__property unsigned SessionProcessIDs[int Index] = {read=GetSessionProcessIDs};
	__property unsigned UserAppWnds[int Index] = {read=GetUserAppWnds};
	__property int UserInstanceIndex[unsigned ProcessID] = {read=GetUserInstanceIndex};
	__property int UserInstanceCount = {read=GetUserInstanceCount, nodefault};
	__property unsigned UserProcessIDs[int Index] = {read=GetUserProcessIDs};
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt AI_INSTANCECREATED = 0x1;
static const ShortInt AI_INSTANCEDESTROYED = 0x2;
static const ShortInt AI_USERMSG = 0x3;
static const ShortInt AppInstDataKindNoData = -1;
static const ShortInt AppInstCmdLineDataKind = 0x1;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE TJclAppInstances* __fastcall JclAppInstances(void)/* overload */;
extern PACKAGE TJclAppInstances* __fastcall JclAppInstances(const System::UnicodeString UniqueAppIdGuidStr)/* overload */;
extern PACKAGE int __fastcall ReadMessageCheck(Messages::TMessage &Message, const unsigned IgnoredOriginatorWnd);
extern PACKAGE void __fastcall ReadMessageData(const Messages::TMessage &Message, void * &Data, int &Size);
extern PACKAGE void __fastcall ReadMessageString(const Messages::TMessage &Message, /* out */ System::UnicodeString &S);
extern PACKAGE void __fastcall ReadMessageStrings(const Messages::TMessage &Message, const Classes::TStrings* Strings);
extern PACKAGE bool __fastcall SendData(const HWND Wnd, const HWND OriginatorWnd, const int DataKind, const void * Data, const int Size);
extern PACKAGE bool __fastcall SendStrings(const HWND Wnd, const HWND OriginatorWnd, const int DataKind, const Classes::TStrings* Strings);
extern PACKAGE bool __fastcall SendCmdLineParams(const HWND Wnd, const HWND OriginatorWnd);
extern PACKAGE bool __fastcall SendString(const HWND Wnd, const HWND OriginatorWnd, const int DataKind, const System::UnicodeString S);

}	/* namespace Jclappinst */
using namespace Jclappinst;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclappinstHPP
