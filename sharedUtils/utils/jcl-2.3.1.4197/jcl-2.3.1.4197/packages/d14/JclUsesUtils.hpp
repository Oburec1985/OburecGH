// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclusesutils.pas' rev: 21.00

#ifndef JclusesutilsHPP
#define JclusesutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclusesutils
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EUsesListError;
class PASCALIMPLEMENTATION EUsesListError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EUsesListError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EUsesListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EUsesListError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EUsesListError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EUsesListError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EUsesListError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EUsesListError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EUsesListError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EUsesListError(void) { }
	
};


class DELPHICLASS TUsesList;
class PASCALIMPLEMENTATION TUsesList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::UnicodeString operator[](int Index) { return Items[Index]; }
	
private:
	System::UnicodeString FText;
	int __fastcall GetCount(void);
	System::UnicodeString __fastcall GetItems(int Index);
	
public:
	__fastcall TUsesList(const System::WideChar * AText);
	int __fastcall Add(const System::UnicodeString UnitName);
	int __fastcall IndexOf(const System::UnicodeString UnitName);
	void __fastcall Insert(int Index, const System::UnicodeString UnitName);
	void __fastcall Remove(int Index);
	__property System::UnicodeString Text = {read=FText};
	__property int Count = {read=GetCount, nodefault};
	__property System::UnicodeString Items[int Index] = {read=GetItems/*, default*/};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TUsesList(void) { }
	
};


class DELPHICLASS TCustomGoal;
class PASCALIMPLEMENTATION TCustomGoal : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__fastcall virtual TCustomGoal(System::WideChar * Text) = 0 ;
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TCustomGoal(void) { }
	
};


class DELPHICLASS TProgramGoal;
class PASCALIMPLEMENTATION TProgramGoal : public TCustomGoal
{
	typedef TCustomGoal inherited;
	
private:
	System::UnicodeString FTextAfterUses;
	System::UnicodeString FTextBeforeUses;
	TUsesList* FUsesList;
	
public:
	__fastcall virtual TProgramGoal(System::WideChar * Text);
	__fastcall virtual ~TProgramGoal(void);
	__property System::UnicodeString TextAfterUses = {read=FTextAfterUses};
	__property System::UnicodeString TextBeforeUses = {read=FTextBeforeUses};
	__property TUsesList* UsesList = {read=FUsesList};
};


class DELPHICLASS TLibraryGoal;
class PASCALIMPLEMENTATION TLibraryGoal : public TCustomGoal
{
	typedef TCustomGoal inherited;
	
private:
	System::UnicodeString FTextAfterUses;
	System::UnicodeString FTextBeforeUses;
	TUsesList* FUsesList;
	
public:
	__fastcall virtual TLibraryGoal(System::WideChar * Text);
	__fastcall virtual ~TLibraryGoal(void);
	__property System::UnicodeString TextAfterUses = {read=FTextAfterUses};
	__property System::UnicodeString TextBeforeUses = {read=FTextBeforeUses};
	__property TUsesList* UsesList = {read=FUsesList};
};


class DELPHICLASS TUnitGoal;
class PASCALIMPLEMENTATION TUnitGoal : public TCustomGoal
{
	typedef TCustomGoal inherited;
	
private:
	System::UnicodeString FTextAfterImpl;
	System::UnicodeString FTextAfterIntf;
	System::UnicodeString FTextBeforeIntf;
	TUsesList* FUsesImpl;
	TUsesList* FUsesIntf;
	
public:
	__fastcall virtual TUnitGoal(System::WideChar * Text);
	__fastcall virtual ~TUnitGoal(void);
	__property System::UnicodeString TextAfterImpl = {read=FTextAfterImpl};
	__property System::UnicodeString TextAfterIntf = {read=FTextAfterIntf};
	__property System::UnicodeString TextBeforeIntf = {read=FTextBeforeIntf};
	__property TUsesList* UsesImpl = {read=FUsesImpl};
	__property TUsesList* UsesIntf = {read=FUsesIntf};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE TCustomGoal* __fastcall CreateGoal(System::WideChar * Text);

}	/* namespace Jclusesutils */
using namespace Jclusesutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclusesutilsHPP
