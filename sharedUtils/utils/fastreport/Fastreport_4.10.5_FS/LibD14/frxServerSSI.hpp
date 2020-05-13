// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserverssi.pas' rev: 21.00

#ifndef FrxserverssiHPP
#define FrxserverssiHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Frxservervariables.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserverssi
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxSSIStream;
class PASCALIMPLEMENTATION TfrxSSIStream : public Classes::TMemoryStream
{
	typedef Classes::TMemoryStream inherited;
	
private:
	System::UnicodeString FBasePath;
	Classes::TMemoryStream* FTempStream;
	Frxservervariables::TfrxServerVariables* FVariables;
	Frxservervariables::TfrxServerVariables* FLocalVariables;
	System::AnsiString __fastcall ParseVarName(int VarPos, int VarLen, char * Src);
	int __fastcall SearchSign(const System::AnsiString Sign, char * Src, int StartPos, int Len);
	
public:
	__fastcall TfrxSSIStream(void);
	__fastcall virtual ~TfrxSSIStream(void);
	void __fastcall Prepare(void);
	__property System::UnicodeString BasePath = {read=FBasePath, write=FBasePath};
	__property Frxservervariables::TfrxServerVariables* Variables = {read=FVariables, write=FVariables};
	__property Frxservervariables::TfrxServerVariables* LocalVariables = {read=FLocalVariables, write=FLocalVariables};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxserverssi */
using namespace Frxserverssi;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverssiHPP
