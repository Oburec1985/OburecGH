// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclmiscel.pas' rev: 21.00

#ifndef JclmiscelHPP
#define JclmiscelHPP

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

namespace Jclmiscel
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TJclKillLevel { klNormal, klNoSignal, klTimeOut };
#pragma option pop

#pragma option push -b-
enum TJclAllowedPowerOperation { apoHibernate, apoShutdown, apoSuspend };
#pragma option pop

typedef Set<TJclAllowedPowerOperation, apoHibernate, apoSuspend>  TJclAllowedPowerOperations;

class DELPHICLASS EJclCreateProcessError;
class PASCALIMPLEMENTATION EJclCreateProcessError : public Jclwin32::EJclWin32Error
{
	typedef Jclwin32::EJclWin32Error inherited;
	
public:
	/* EJclWin32Error.Create */ inline __fastcall EJclCreateProcessError(const System::UnicodeString Msg) : Jclwin32::EJclWin32Error(Msg) { }
	/* EJclWin32Error.CreateFmt */ inline __fastcall EJclCreateProcessError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size) { }
	/* EJclWin32Error.CreateRes */ inline __fastcall EJclCreateProcessError(int Ident)/* overload */ : Jclwin32::EJclWin32Error(Ident) { }
	
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclCreateProcessError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclwin32::EJclWin32Error(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclCreateProcessError(const System::UnicodeString Msg, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclCreateProcessError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclwin32::EJclWin32Error(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclCreateProcessError(int Ident, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclCreateProcessError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclwin32::EJclWin32Error(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclCreateProcessError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE int __fastcall SetDisplayResolution(const unsigned XRes, const unsigned YRes);
extern PACKAGE bool __fastcall CreateDOSProcessRedirected(System::UnicodeString CommandLine, const System::UnicodeString InputFile, const System::UnicodeString OutputFile);
extern PACKAGE bool __fastcall WinExec32(System::UnicodeString Cmd, const int CmdShow);
extern PACKAGE unsigned __fastcall WinExec32AndWait(System::UnicodeString Cmd, const int CmdShow);
extern PACKAGE unsigned __fastcall WinExec32AndRedirectOutput(const System::UnicodeString Cmd, System::UnicodeString &Output, bool RawOutput = false);
extern PACKAGE bool __fastcall LogOffOS(TJclKillLevel KillLevel = (TJclKillLevel)(0x0));
extern PACKAGE bool __fastcall PowerOffOS(TJclKillLevel KillLevel = (TJclKillLevel)(0x0));
extern PACKAGE bool __fastcall ShutDownOS(TJclKillLevel KillLevel = (TJclKillLevel)(0x0));
extern PACKAGE bool __fastcall RebootOS(TJclKillLevel KillLevel = (TJclKillLevel)(0x0));
extern PACKAGE bool __fastcall HibernateOS(bool Force, bool DisableWakeEvents);
extern PACKAGE bool __fastcall SuspendOS(bool Force, bool DisableWakeEvents);
extern PACKAGE bool __fastcall ShutDownDialog(const System::UnicodeString DialogMessage, unsigned TimeOut, bool Force, bool Reboot)/* overload */;
extern PACKAGE bool __fastcall ShutDownDialog(const System::UnicodeString MachineName, const System::UnicodeString DialogMessage, unsigned TimeOut, bool Force, bool Reboot)/* overload */;
extern PACKAGE bool __fastcall AbortShutDown(void)/* overload */;
extern PACKAGE bool __fastcall AbortShutDown(const System::UnicodeString MachineName)/* overload */;
extern PACKAGE TJclAllowedPowerOperations __fastcall GetAllowedPowerOperations(void);
extern PACKAGE void __fastcall CreateProcAsUser(const System::UnicodeString UserDomain, const System::UnicodeString UserName, const System::UnicodeString PassWord, const System::UnicodeString CommandLine);
extern PACKAGE void __fastcall CreateProcAsUserEx(const System::UnicodeString UserDomain, const System::UnicodeString UserName, const System::UnicodeString Password, const System::UnicodeString CommandLine, const System::WideChar * Environment);

}	/* namespace Jclmiscel */
using namespace Jclmiscel;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclmiscelHPP
