// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fs_itools.pas' rev: 21.00

#ifndef Fs_itoolsHPP
#define Fs_itoolsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Fs_iinterpreter.hpp>	// Pascal unit
#include <Fs_xml.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fs_itools
{
//-- type declarations -------------------------------------------------------
typedef DynamicArray<System::TVarRec> TVarRecArray;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall fsRegisterLanguage(const System::UnicodeString Name, const System::UnicodeString Grammar);
extern PACKAGE System::UnicodeString __fastcall fsGetLanguage(const System::UnicodeString Name);
extern PACKAGE void __fastcall fsGetLanguageList(Classes::TStrings* List);
extern PACKAGE Fs_iinterpreter::TfsVarType __fastcall StrToVarType(const System::UnicodeString TypeName, Fs_iinterpreter::TfsScript* Script);
extern PACKAGE bool __fastcall TypesCompatible(const Fs_iinterpreter::TfsTypeRec &Typ1, const Fs_iinterpreter::TfsTypeRec &Typ2, Fs_iinterpreter::TfsScript* Script);
extern PACKAGE bool __fastcall AssignCompatible(Fs_iinterpreter::TfsCustomVariable* Var1, Fs_iinterpreter::TfsCustomVariable* Var2, Fs_iinterpreter::TfsScript* Script);
extern PACKAGE System::Variant __fastcall VarRecToVariant(const System::TVarRec &v);
extern PACKAGE void __fastcall VariantToVarRec(const System::Variant &v, TVarRecArray &ar);
extern PACKAGE void __fastcall ClearVarRec(TVarRecArray &ar);
extern PACKAGE System::Variant __fastcall ParserStringToVariant(System::UnicodeString s);
extern PACKAGE Fs_iinterpreter::TfsCustomVariable* __fastcall ParseMethodSyntax(const System::UnicodeString Syntax, Fs_iinterpreter::TfsScript* Script);
extern PACKAGE Types::TPoint __fastcall fsPosToPoint(const System::UnicodeString ErrorPos);
extern PACKAGE void __fastcall GenerateXMLContents(Fs_iinterpreter::TfsScript* Prog, Fs_xml::TfsXMLItem* Item, bool FunctionsOnly = false);
extern PACKAGE void __fastcall GenerateMembers(Fs_iinterpreter::TfsScript* Prog, System::TClass cl, Fs_xml::TfsXMLItem* Item);

}	/* namespace Fs_itools */
using namespace Fs_itools;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Fs_itoolsHPP
