// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclcharsets.pas' rev: 21.00

#ifndef JclcharsetsHPP
#define JclcharsetsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclcharsets
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclCharsetError;
class PASCALIMPLEMENTATION EJclCharsetError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclCharsetError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclCharsetError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclCharsetError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclCharsetError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclCharsetError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclCharsetError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclCharsetError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclCharsetError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclCharsetError(void) { }
	
};


struct TJclCharsetInfo
{
	
public:
	System::UnicodeString Name;
	System::Word CodePage;
	System::Word FamilyCodePage;
};


typedef StaticArray<TJclCharsetInfo, 306> Jclcharsets__2;

//-- var, const, procedure ---------------------------------------------------
static const Word CP_UTF16LE = 0x4b0;
extern PACKAGE Jclcharsets__2 JclCharsetInfos;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE System::Word __fastcall FamilyCodePageFromCharsetName(const System::UnicodeString CharsetName);
extern PACKAGE System::Word __fastcall CodePageFromCharsetName(const System::UnicodeString CharsetName);
extern PACKAGE TJclCharsetInfo __fastcall CharsetInfoFromCharsetName(const System::UnicodeString CharsetName);
extern PACKAGE System::Word __fastcall FamilyCodePageFromCodePage(System::Word CodePage);
extern PACKAGE System::UnicodeString __fastcall CharsetNameFromCodePage(System::Word CodePage);

}	/* namespace Jclcharsets */
using namespace Jclcharsets;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclcharsetsHPP
