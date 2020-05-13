// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessortemplates.pas' rev: 21.00

#ifndef JclpreprocessortemplatesHPP
#define JclpreprocessortemplatesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclpreprocessorparser.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessortemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclTemplateParams;
class PASCALIMPLEMENTATION TJclTemplateParams : public Jclpreprocessorparser::TPppState
{
	typedef Jclpreprocessorparser::TPppState inherited;
	
public:
	__fastcall TJclTemplateParams(void);
public:
	/* TPppState.Destroy */ inline __fastcall virtual ~TJclTemplateParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
#define ModulePattern L"%MODULENAME%"
#define FormPattern L"%FORMNAME%"
#define AncestorPattern L"%ANCESTORNAME%"
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE System::UnicodeString __fastcall GetFinalFormContent(const System::UnicodeString Content, const System::UnicodeString FormIdent, const System::UnicodeString AncestorIdent);
extern PACKAGE System::UnicodeString __fastcall GetFinalHeaderContent(const System::UnicodeString Content, const System::UnicodeString ModuleIdent, const System::UnicodeString FormIdent, const System::UnicodeString AncestorIdent);
extern PACKAGE System::UnicodeString __fastcall GetFinalSourceContent(const System::UnicodeString Content, const System::UnicodeString ModuleIdent, const System::UnicodeString FormIdent, const System::UnicodeString AncestorIdent);
extern PACKAGE System::UnicodeString __fastcall ApplyTemplate(const System::UnicodeString Template, const TJclTemplateParams* Params);

}	/* namespace Jclpreprocessortemplates */
using namespace Jclpreprocessortemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessortemplatesHPP
