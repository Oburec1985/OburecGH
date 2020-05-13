// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcldebugxmldeserializer.pas' rev: 21.00

#ifndef JcldebugxmldeserializerHPP
#define JcldebugxmldeserializerHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jcldebugserialization.hpp>	// Pascal unit
#include <Jclsimplexml.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcldebugxmldeserializer
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclXMLDeserializer;
class PASCALIMPLEMENTATION TJclXMLDeserializer : public Jcldebugserialization::TJclCustomSimpleSerializer
{
	typedef Jcldebugserialization::TJclCustomSimpleSerializer inherited;
	
public:
	void __fastcall LoadFromString(const System::UnicodeString AValue);
public:
	/* TJclCustomSimpleSerializer.Create */ inline __fastcall TJclXMLDeserializer(const System::UnicodeString AName) : Jcldebugserialization::TJclCustomSimpleSerializer(AName) { }
	/* TJclCustomSimpleSerializer.Destroy */ inline __fastcall virtual ~TJclXMLDeserializer(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jcldebugxmldeserializer */
using namespace Jcldebugxmldeserializer;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcldebugxmldeserializerHPP
