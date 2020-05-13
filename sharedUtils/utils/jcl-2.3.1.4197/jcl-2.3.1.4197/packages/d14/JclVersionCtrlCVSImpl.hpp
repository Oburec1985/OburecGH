// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclversionctrlcvsimpl.pas' rev: 21.00

#ifndef JclversionctrlcvsimplHPP
#define JclversionctrlcvsimplHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Jclversioncontrol.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclversionctrlcvsimpl
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclVersionControlCVS;
class PASCALIMPLEMENTATION TJclVersionControlCVS : public Jclversioncontrol::TJclVersionControlPlugin
{
	typedef Jclversioncontrol::TJclVersionControlPlugin inherited;
	
private:
	System::UnicodeString FTortoiseCVSAct;
	
protected:
	virtual Jclversioncontrol::TJclVersionControlActionTypes __fastcall GetSupportedActionTypes(void);
	virtual Jclversioncontrol::TJclVersionControlActionTypes __fastcall GetFileActions(const Sysutils::TFileName FileName);
	virtual Jclversioncontrol::TJclVersionControlActionTypes __fastcall GetSandboxActions(const Sysutils::TFileName SdBxName);
	virtual bool __fastcall GetEnabled(void);
	virtual System::UnicodeString __fastcall GetName(void);
	
public:
	__fastcall virtual TJclVersionControlCVS(void);
	virtual bool __fastcall GetSandboxNames(const Sysutils::TFileName FileName, Classes::TStrings* SdBxNames);
	virtual bool __fastcall ExecuteAction(const Sysutils::TFileName FileName, const Jclversioncontrol::TJclVersionControlActionType Action);
public:
	/* TJclVersionControlPlugin.Destroy */ inline __fastcall virtual ~TJclVersionControlCVS(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclversionctrlcvsimpl */
using namespace Jclversionctrlcvsimpl;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclversionctrlcvsimplHPP
