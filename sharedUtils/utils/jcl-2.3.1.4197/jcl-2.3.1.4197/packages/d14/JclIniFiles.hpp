// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclinifiles.pas' rev: 21.00

#ifndef JclinifilesHPP
#define JclinifilesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Inifiles.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclinifiles
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall IniReadBool(const System::UnicodeString FileName, const System::UnicodeString Section, const System::UnicodeString Line);
extern PACKAGE int __fastcall IniReadInteger(const System::UnicodeString FileName, const System::UnicodeString Section, const System::UnicodeString Line);
extern PACKAGE System::UnicodeString __fastcall IniReadString(const System::UnicodeString FileName, const System::UnicodeString Section, const System::UnicodeString Line);
extern PACKAGE void __fastcall IniWriteBool(const System::UnicodeString FileName, const System::UnicodeString Section, const System::UnicodeString Line, bool Value);
extern PACKAGE void __fastcall IniWriteInteger(const System::UnicodeString FileName, const System::UnicodeString Section, const System::UnicodeString Line, int Value);
extern PACKAGE void __fastcall IniWriteString(const System::UnicodeString FileName, const System::UnicodeString Section, const System::UnicodeString Line, const System::UnicodeString Value);
extern PACKAGE void __fastcall IniReadStrings(Inifiles::TCustomIniFile* IniFile, const System::UnicodeString Section, Classes::TStrings* Strings);
extern PACKAGE void __fastcall IniWriteStrings(Inifiles::TCustomIniFile* IniFile, const System::UnicodeString Section, Classes::TStrings* Strings);

}	/* namespace Jclinifiles */
using namespace Jclinifiles;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclinifilesHPP
