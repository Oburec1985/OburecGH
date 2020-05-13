// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcllanman.pas' rev: 21.00

#ifndef JcllanmanHPP
#define JcllanmanHPP

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

//-- user supplied -----------------------------------------------------------

namespace Jcllanman
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TNetUserFlag { ufAccountDisable, ufHomedirRequired, ufLockout, ufPasswordNotRequired, ufPasswordCantChange, ufDontExpirePassword, ufMNSLogonAccount };
#pragma option pop

typedef Set<TNetUserFlag, ufAccountDisable, ufMNSLogonAccount>  TNetUserFlags;

#pragma option push -b-
enum TNetUserInfoFlag { uifScript, uifTempDuplicateAccount, uifNormalAccount, uifInterdomainTrustAccount, uifWorkstationTrustAccount, uifServerTrustAccount };
#pragma option pop

typedef Set<TNetUserInfoFlag, uifScript, uifServerTrustAccount>  TNetUserInfoFlags;

#pragma option push -b-
enum TNetUserPriv { upUnknown, upGuest, upUser, upAdmin };
#pragma option pop

#pragma option push -b-
enum TNetUserAuthFlag { afOpPrint, afOpComm, afOpServer, afOpAccounts };
#pragma option pop

typedef Set<TNetUserAuthFlag, afOpPrint, afOpAccounts>  TNetUserAuthFlags;

#pragma option push -b-
enum TNetWellKnownRID { wkrAdmins, wkrUsers, wkrGuests, wkrPowerUsers, wkrBackupOPs, wkrReplicator, wkrEveryone };
#pragma option pop

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall CreateAccount(const System::UnicodeString Server, const System::UnicodeString Username, const System::UnicodeString Fullname, const System::UnicodeString Password, const System::UnicodeString Description, const System::UnicodeString Homedir, const System::UnicodeString Script, const bool PasswordNeverExpires = true);
extern PACKAGE bool __fastcall CreateLocalAccount(const System::UnicodeString Username, const System::UnicodeString Fullname, const System::UnicodeString Password, const System::UnicodeString Description, const System::UnicodeString Homedir, const System::UnicodeString Script, const bool PasswordNeverExpires = true);
extern PACKAGE bool __fastcall DeleteAccount(const System::UnicodeString Servername, const System::UnicodeString Username);
extern PACKAGE bool __fastcall DeleteLocalAccount(System::UnicodeString Username);
extern PACKAGE bool __fastcall CreateGlobalGroup(const System::UnicodeString Server, const System::UnicodeString Groupname, const System::UnicodeString Description);
extern PACKAGE bool __fastcall CreateLocalGroup(const System::UnicodeString Server, const System::UnicodeString Groupname, const System::UnicodeString Description);
extern PACKAGE bool __fastcall DeleteLocalGroup(const System::UnicodeString Server, const System::UnicodeString Groupname);
extern PACKAGE bool __fastcall GetLocalGroups(const System::UnicodeString Server, const Classes::TStrings* Groups);
extern PACKAGE bool __fastcall GetGlobalGroups(const System::UnicodeString Server, const Classes::TStrings* Groups);
extern PACKAGE bool __fastcall LocalGroupExists(const System::UnicodeString Group);
extern PACKAGE bool __fastcall GlobalGroupExists(const System::UnicodeString Server, const System::UnicodeString Group);
extern PACKAGE bool __fastcall AddAccountToLocalGroup(const System::UnicodeString Accountname, const System::UnicodeString Groupname);
extern PACKAGE System::UnicodeString __fastcall LookupGroupName(const System::UnicodeString Server, const TNetWellKnownRID RID);
extern PACKAGE void __fastcall ParseAccountName(const System::UnicodeString QualifiedName, /* out */ System::UnicodeString &Domain, /* out */ System::UnicodeString &UserName);
extern PACKAGE bool __fastcall IsLocalAccount(const System::UnicodeString AccountName);

}	/* namespace Jcllanman */
using namespace Jcllanman;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcllanmanHPP
