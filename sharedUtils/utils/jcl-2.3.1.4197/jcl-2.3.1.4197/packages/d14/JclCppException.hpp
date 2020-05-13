// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclcppexception.pas' rev: 21.00

#ifndef JclcppexceptionHPP
#define JclcppexceptionHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#include <typeinfo>
#include <exception>

namespace Jclcppexception
{

typedef std::exception* PJclCppStdException;

} /* namespace Jclcppexception */

namespace Jclcppexception
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclCppException;
class PASCALIMPLEMENTATION EJclCppException : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
private:
	System::AnsiString FTypeName;
	void *FExcDesc;
	__fastcall EJclCppException(char * ATypeName, void * ExcDesc)/* overload */;
	void * __fastcall GetCppExceptionObject(void);
	int __fastcall GetThrowLine(void);
	System::AnsiString __fastcall GetThrowFile(void);
	
public:
	__property void * CppExceptionObject = {read=GetCppExceptionObject};
	__property int ThrowLine = {read=GetThrowLine, nodefault};
	__property System::AnsiString ThrowFile = {read=GetThrowFile};
	__property System::AnsiString TypeName = {read=FTypeName};
	bool __fastcall IsCppClass(void)/* overload */;
	void * __fastcall AsCppClass(System::AnsiString CppClassName)/* overload */;
	__fastcall virtual ~EJclCppException(void);
public:
	/* Exception.Create */ inline __fastcall EJclCppException(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclCppException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclCppException(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclCppException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclCppException(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclCppException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclCppException(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclCppException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	
};


class DELPHICLASS EJclCppStdException;
class PASCALIMPLEMENTATION EJclCppStdException : public EJclCppException
{
	typedef EJclCppException inherited;
	
private:
	void *FExcObj;
	__fastcall EJclCppStdException(PJclCppStdException AExcObj, System::UnicodeString Msg, char * ATypeName, void * ExcDesc)/* overload */;
	PJclCppStdException __fastcall GetStdException(void);
	
public:
	__property PJclCppStdException StdException = {read=GetStdException};
public:
	/* EJclCppException.Destroy */ inline __fastcall virtual ~EJclCppStdException(void) { }
	
public:
	/* Exception.Create */ inline __fastcall EJclCppStdException(const System::UnicodeString Msg) : EJclCppException(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclCppStdException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : EJclCppException(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclCppStdException(int Ident)/* overload */ : EJclCppException(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclCppStdException(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : EJclCppException(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclCppStdException(const System::UnicodeString Msg, int AHelpContext) : EJclCppException(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclCppStdException(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : EJclCppException(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclCppStdException(int Ident, int AHelpContext)/* overload */ : EJclCppException(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclCppStdException(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : EJclCppException(ResStringRec, Args, Args_Size, AHelpContext) { }
	
};


#pragma option push -b-
enum Jclcppexception__3 { cefPrependCppClassName };
#pragma option pop

typedef Set<Jclcppexception__3, cefPrependCppClassName, cefPrependCppClassName>  TJclCppExceptionFlags;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TJclCppExceptionFlags JclCppExceptionFlags;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall JclInstallCppExceptionFilter(void);
extern PACKAGE void __fastcall JclUninstallCppExceptionFilter(void);
extern PACKAGE bool __fastcall JclCppExceptionFilterInstalled(void);

}	/* namespace Jclcppexception */
using namespace Jclcppexception;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclcppexceptionHPP
