// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessorcontainerknowntypes.pas' rev: 21.00

#ifndef JclpreprocessorcontainerknowntypesHPP
#define JclpreprocessorcontainerknowntypesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclpreprocessorcontainertypes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessorcontainerknowntypes
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes IInterfaceKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes AnsiStringKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes WideStringKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes UnicodeStringKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes StringKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes SingleKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes DoubleKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes ExtendedKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes FloatKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes IntegerKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes CardinalKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes Int64KnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes PointerKnownType;
extern PACKAGE Jclpreprocessorcontainertypes::TTypeAttributes TObjectKnownType;
extern PACKAGE StaticArray<Jclpreprocessorcontainertypes::PKnownTypeAttributes, 14> KnownAllTypes;
extern PACKAGE StaticArray<Jclpreprocessorcontainertypes::PKnownTypeAttributes, 12> KnownTrueTypes;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE Jclpreprocessorcontainertypes::PKnownTypeAttributes __fastcall IsKnownType(const System::UnicodeString TypeName);

}	/* namespace Jclpreprocessorcontainerknowntypes */
using namespace Jclpreprocessorcontainerknowntypes;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessorcontainerknowntypesHPP
