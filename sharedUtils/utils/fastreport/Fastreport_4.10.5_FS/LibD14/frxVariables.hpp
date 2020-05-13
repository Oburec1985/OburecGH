// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxvariables.pas' rev: 21.00

#ifndef FrxvariablesHPP
#define FrxvariablesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxvariables
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxVariable;
class PASCALIMPLEMENTATION TfrxVariable : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FName;
	System::Variant FValue;
	
public:
	__fastcall virtual TfrxVariable(Classes::TCollection* Collection);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property System::Variant Value = {read=FValue, write=FValue};
public:
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxVariable(void) { }
	
};


class DELPHICLASS TfrxVariables;
class PASCALIMPLEMENTATION TfrxVariables : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	System::Variant operator[](System::UnicodeString Index) { return Variables[Index]; }
	
private:
	TfrxVariable* __fastcall GetItems(int Index);
	System::Variant __fastcall GetVariable(System::UnicodeString Index);
	void __fastcall SetVariable(System::UnicodeString Index, const System::Variant &Value);
	
public:
	__fastcall TfrxVariables(void);
	HIDESBASE TfrxVariable* __fastcall Add(void);
	HIDESBASE TfrxVariable* __fastcall Insert(int Index);
	int __fastcall IndexOf(const System::UnicodeString Name);
	void __fastcall AddVariable(const System::UnicodeString ACategory, const System::UnicodeString AName, const System::Variant &AValue);
	void __fastcall DeleteCategory(const System::UnicodeString Name);
	void __fastcall DeleteVariable(const System::UnicodeString Name);
	void __fastcall GetCategoriesList(Classes::TStrings* List, bool ClearList = true);
	void __fastcall GetVariablesList(const System::UnicodeString Category, Classes::TStrings* List);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall LoadFromXMLItem(Frxxml::TfrxXMLItem* Item, bool OldXMLFormat = true);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall SaveToXMLItem(Frxxml::TfrxXMLItem* Item);
	__property TfrxVariable* Items[int Index] = {read=GetItems};
	__property System::Variant Variables[System::UnicodeString Index] = {read=GetVariable, write=SetVariable/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxVariables(void) { }
	
};


class DELPHICLASS TfrxArray;
class PASCALIMPLEMENTATION TfrxArray : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	System::Variant operator[](System::Variant Index) { return Variables[Index]; }
	
private:
	TfrxVariable* __fastcall GetItems(int Index);
	System::Variant __fastcall GetVariable(const System::Variant &Index);
	void __fastcall SetVariable(const System::Variant &Index, const System::Variant &Value);
	
public:
	__fastcall TfrxArray(void);
	int __fastcall IndexOf(const System::Variant &Name);
	__property TfrxVariable* Items[int Index] = {read=GetItems};
	__property System::Variant Variables[System::Variant Index] = {read=GetVariable, write=SetVariable/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxArray(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxvariables */
using namespace Frxvariables;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxvariablesHPP
