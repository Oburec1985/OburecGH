// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxservervariables.pas' rev: 21.00

#ifndef FrxservervariablesHPP
#define FrxservervariablesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxservervariables
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxServerVariable;
class PASCALIMPLEMENTATION TfrxServerVariable : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FName;
	System::AnsiString FValue;
	
__published:
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property System::AnsiString Value = {read=FValue, write=FValue};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxServerVariable(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxServerVariable(void) { }
	
};


class DELPHICLASS TfrxServerVariables;
class PASCALIMPLEMENTATION TfrxServerVariables : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	__fastcall TfrxServerVariables(void);
	System::AnsiString __fastcall GetValue(const System::UnicodeString Name);
	void __fastcall AddVariable(const System::UnicodeString Name, const System::AnsiString Value)/* overload */;
	void __fastcall AddVariable(const System::UnicodeString Name, const System::UnicodeString Value)/* overload */;
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxServerVariables(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxservervariables */
using namespace Frxservervariables;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxservervariablesHPP
