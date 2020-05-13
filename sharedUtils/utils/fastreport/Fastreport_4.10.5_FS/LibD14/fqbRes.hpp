// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fqbres.pas' rev: 21.00

#ifndef FqbresHPP
#define FqbresHPP

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
#include <Controls.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fqbres
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfqbResources;
class PASCALIMPLEMENTATION TfqbResources : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TStringList* FNames;
	Classes::TStringList* FValues;
	
public:
	__fastcall TfqbResources(void);
	__fastcall virtual ~TfqbResources(void);
	System::UnicodeString __fastcall Get(const System::UnicodeString StrName);
	void __fastcall Add(const System::UnicodeString Ref, const System::UnicodeString Str);
	void __fastcall AddStrings(const System::UnicodeString Str);
	void __fastcall Clear(void);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfqbResources* __fastcall fqbResources(void);
extern PACKAGE System::UnicodeString __fastcall fqbGet(int ID);

}	/* namespace Fqbres */
using namespace Fqbres;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FqbresHPP
