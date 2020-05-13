// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcldebugxmlserializer.pas' rev: 21.00

#ifndef JcldebugxmlserializerHPP
#define JcldebugxmlserializerHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jcldebugserialization.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jcldebugxmlserializer
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclXMLSerializer;
class PASCALIMPLEMENTATION TJclXMLSerializer : public Jcldebugserialization::TJclCustomSimpleSerializer
{
	typedef Jcldebugserialization::TJclCustomSimpleSerializer inherited;
	
public:
	System::UnicodeString __fastcall SaveToString(void);
public:
	/* TJclCustomSimpleSerializer.Create */ inline __fastcall TJclXMLSerializer(const System::UnicodeString AName) : Jcldebugserialization::TJclCustomSimpleSerializer(AName) { }
	/* TJclCustomSimpleSerializer.Destroy */ inline __fastcall virtual ~TJclXMLSerializer(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jcldebugxmlserializer */
using namespace Jcldebugxmlserializer;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcldebugxmlserializerHPP
