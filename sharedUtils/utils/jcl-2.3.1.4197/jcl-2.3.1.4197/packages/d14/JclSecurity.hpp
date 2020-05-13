// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclsecurity.pas' rev: 21.00

#ifndef JclsecurityHPP
#define JclsecurityHPP

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
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#define TTokenInformationClass TOKEN_INFORMATION_CLASS

namespace Jclsecurity
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclSecurityError;
class PASCALIMPLEMENTATION EJclSecurityError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclSecurityError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclSecurityError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclSecurityError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclSecurityError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclSecurityError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclSecurityError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclSecurityError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclSecurityError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclSecurityError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE Windows::PSecurityAttributes __fastcall CreateNullDacl(/* out */ _SECURITY_ATTRIBUTES &Sa, const bool Inheritable);
extern PACKAGE Windows::PSecurityAttributes __fastcall CreateInheritable(/* out */ _SECURITY_ATTRIBUTES &Sa);
extern PACKAGE bool __fastcall IsGroupMember(unsigned RelativeGroupID);
extern PACKAGE bool __fastcall IsAdministrator(void);
extern PACKAGE bool __fastcall IsUser(void);
extern PACKAGE bool __fastcall IsGuest(void);
extern PACKAGE bool __fastcall IsPowerUser(void);
extern PACKAGE bool __fastcall IsAccountOperator(void);
extern PACKAGE bool __fastcall IsSystemOperator(void);
extern PACKAGE bool __fastcall IsPrintOperator(void);
extern PACKAGE bool __fastcall IsBackupOperator(void);
extern PACKAGE bool __fastcall IsReplicator(void);
extern PACKAGE bool __fastcall IsRASServer(void);
extern PACKAGE bool __fastcall IsPreWin2000CompAccess(void);
extern PACKAGE bool __fastcall IsRemoteDesktopUser(void);
extern PACKAGE bool __fastcall IsNetworkConfigurationOperator(void);
extern PACKAGE bool __fastcall IsIncomingForestTrustBuilder(void);
extern PACKAGE bool __fastcall IsMonitoringUser(void);
extern PACKAGE bool __fastcall IsLoggingUser(void);
extern PACKAGE bool __fastcall IsAuthorizationAccess(void);
extern PACKAGE bool __fastcall IsTSLicenseServer(void);
extern PACKAGE bool __fastcall EnableProcessPrivilege(const bool Enable, const System::UnicodeString Privilege);
extern PACKAGE bool __fastcall EnableThreadPrivilege(const bool Enable, const System::UnicodeString Privilege);
extern PACKAGE bool __fastcall IsPrivilegeEnabled(const System::UnicodeString Privilege);
extern PACKAGE System::UnicodeString __fastcall GetPrivilegeDisplayName(const System::UnicodeString PrivilegeName);
extern PACKAGE bool __fastcall SetUserObjectFullAccess(unsigned hUserObject);
extern PACKAGE System::UnicodeString __fastcall GetUserObjectName(unsigned hUserObject);
extern PACKAGE void __fastcall LookupAccountBySid(void * Sid, /* out */ System::AnsiString &Name, /* out */ System::AnsiString &Domain, bool Silent = false)/* overload */;
extern PACKAGE void __fastcall LookupAccountBySid(void * Sid, /* out */ System::WideString &Name, /* out */ System::WideString &Domain, bool Silent = false)/* overload */;
extern PACKAGE void __fastcall QueryTokenInformation(unsigned Token, TTokenInformationClass InformationClass, void * &Buffer);
extern PACKAGE void __fastcall FreeTokenInformation(void * &Buffer);
extern PACKAGE System::UnicodeString __fastcall GetInteractiveUserName(void);
extern PACKAGE System::UnicodeString __fastcall SIDToString(void * ASID);
extern PACKAGE void __fastcall StringToSID(const System::UnicodeString SIDString, void * SID, unsigned cbSID);
extern PACKAGE bool __fastcall GetComputerSID(void * SID, unsigned cbSID);
extern PACKAGE bool __fastcall IsUACEnabled(void);
extern PACKAGE bool __fastcall IsElevated(void);

}	/* namespace Jclsecurity */
using namespace Jclsecurity;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclsecurityHPP
