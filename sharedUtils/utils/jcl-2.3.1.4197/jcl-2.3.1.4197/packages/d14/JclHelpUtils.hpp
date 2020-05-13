// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclhelputils.pas' rev: 21.00

#ifndef JclhelputilsHPP
#define JclhelputilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Mshelpservices_tlb.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclhelputils
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclHelpUtilsException;
class PASCALIMPLEMENTATION EJclHelpUtilsException : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclHelpUtilsException(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclHelpUtilsException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclHelpUtilsException(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclHelpUtilsException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclHelpUtilsException(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclHelpUtilsException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclHelpUtilsException(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclHelpUtilsException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclHelpUtilsException(void) { }
	
};


class DELPHICLASS TJclBorlandOpenHelp;
class PASCALIMPLEMENTATION TJclBorlandOpenHelp : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FHelpPrefix;
	System::UnicodeString FRootDirectory;
	System::UnicodeString __fastcall GetContentFileName(void);
	System::UnicodeString __fastcall GetIndexFileName(void);
	System::UnicodeString __fastcall GetLinkFileName(void);
	System::UnicodeString __fastcall GetGidFileName(void);
	System::UnicodeString __fastcall GetProjectFileName(void);
	System::UnicodeString __fastcall ReadFileName(const System::UnicodeString FormatName);
	
public:
	__fastcall TJclBorlandOpenHelp(const System::UnicodeString ARootDirectory, const System::UnicodeString AHelpPrefix);
	bool __fastcall AddHelpFile(const System::UnicodeString HelpFileName, const System::UnicodeString IndexName);
	bool __fastcall RemoveHelpFile(const System::UnicodeString HelpFileName, const System::UnicodeString IndexName);
	__property System::UnicodeString ContentFileName = {read=GetContentFileName};
	__property System::UnicodeString GidFileName = {read=GetGidFileName};
	__property System::UnicodeString HelpPrefix = {read=FHelpPrefix};
	__property System::UnicodeString IndexFileName = {read=GetIndexFileName};
	__property System::UnicodeString LinkFileName = {read=GetLinkFileName};
	__property System::UnicodeString ProjectFileName = {read=GetProjectFileName};
	__property System::UnicodeString RootDirectory = {read=FRootDirectory};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclBorlandOpenHelp(void) { }
	
};


#pragma option push -b-
enum TJclHelp2Object { hoRegisterSession, hoRegister, hoPlugin };
#pragma option pop

typedef Set<TJclHelp2Object, hoRegisterSession, hoPlugin>  TJclHelp2Objects;

class DELPHICLASS TJclHelp2Manager;
class PASCALIMPLEMENTATION TJclHelp2Manager : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Mshelpservices_tlb::_di_IHxRegisterSession FHxRegisterSession;
	Mshelpservices_tlb::_di_IHxRegister FHxRegister;
	Mshelpservices_tlb::_di_IHxPlugIn FHxPlugin;
	System::WideString FIdeNameSpace;
	bool __fastcall RequireObject(TJclHelp2Objects HelpObjects);
	Mshelpservices_tlb::_di_IHxPlugIn __fastcall GetHxPlugin(void);
	Mshelpservices_tlb::_di_IHxRegister __fastcall GetHxRegister(void);
	Mshelpservices_tlb::_di_IHxRegisterSession __fastcall GetHxRegisterSession(void);
	
public:
	__fastcall TJclHelp2Manager(int IDEVersionNumber);
	__fastcall virtual ~TJclHelp2Manager(void);
	bool __fastcall CreateTransaction(void);
	bool __fastcall CommitTransaction(void);
	bool __fastcall RegisterNameSpace(const System::WideString Name, const System::WideString Collection, const System::WideString Description);
	bool __fastcall UnregisterNameSpace(const System::WideString Name);
	bool __fastcall RegisterHelpFile(const System::WideString NameSpace, const System::WideString Identifier, const int LangId, const System::WideString HxSFile, const System::WideString HxIFile);
	bool __fastcall UnregisterHelpFile(const System::WideString NameSpace, const System::WideString Identifier, const int LangId);
	bool __fastcall PlugNameSpaceIn(const System::WideString SourceNameSpace, const System::WideString TargetNameSpace);
	bool __fastcall UnPlugNameSpace(const System::WideString SourceNameSpace, const System::WideString TargetNameSpace);
	bool __fastcall PlugNameSpaceInBorlandHelp(const System::WideString NameSpace);
	bool __fastcall UnPlugNameSpaceFromBorlandHelp(const System::WideString NameSpace);
	__property Mshelpservices_tlb::_di_IHxRegisterSession HxRegisterSession = {read=GetHxRegisterSession};
	__property Mshelpservices_tlb::_di_IHxRegister HxRegister = {read=GetHxRegister};
	__property Mshelpservices_tlb::_di_IHxPlugIn HxPlugin = {read=GetHxPlugin};
	__property System::WideString IdeNamespace = {read=FIdeNameSpace};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclhelputils */
using namespace Jclhelputils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclhelputilsHPP
