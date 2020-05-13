// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclcom.pas' rev: 21.00

#ifndef JclcomHPP
#define JclcomHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclcom
{
//-- type declarations -------------------------------------------------------
typedef StaticArray<GUID, 1> TArrayCatID;

class DELPHICLASS EInvalidParam;
class PASCALIMPLEMENTATION EInvalidParam : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EInvalidParam(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EInvalidParam(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EInvalidParam(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EInvalidParam(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EInvalidParam(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EInvalidParam(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EInvalidParam(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EInvalidParam(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EInvalidParam(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE GUID CLSID_StdComponentCategoriesMgr;
extern PACKAGE GUID CATID_SafeForInitializing;
extern PACKAGE GUID CATID_SafeForScripting;
static const Byte icMAX_CATEGORY_DESC_LEN = 0x80;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall IsDCOMInstalled(void);
extern PACKAGE bool __fastcall IsDCOMEnabled(void);
extern PACKAGE System::UnicodeString __fastcall GetDCOMVersion(void);
extern PACKAGE System::UnicodeString __fastcall GetMDACVersion(void);
extern PACKAGE HRESULT __fastcall MarshalInterThreadInterfaceInVarArray(const GUID &iid, System::_di_IInterface unk, System::OleVariant &VarArray);
extern PACKAGE HRESULT __fastcall MarshalInterProcessInterfaceInStream(const GUID &iid, System::_di_IInterface unk, _di_IStream &stm);
extern PACKAGE HRESULT __fastcall MarshalInterProcessInterfaceInVarArray(const GUID &iid, System::_di_IInterface unk, System::OleVariant &VarArray);
extern PACKAGE HRESULT __fastcall MarshalInterMachineInterfaceInStream(const GUID &iid, System::_di_IInterface unk, _di_IStream &stm);
extern PACKAGE HRESULT __fastcall MarshalInterMachineInterfaceInVarArray(const GUID &iid, System::_di_IInterface unk, System::OleVariant &VarArray);
extern PACKAGE HRESULT __fastcall CreateComponentCategory(const GUID &CatID, const System::UnicodeString sDescription);
extern PACKAGE HRESULT __fastcall RegisterCLSIDInCategory(const GUID &ClassID, const GUID &CatID);
extern PACKAGE HRESULT __fastcall UnRegisterCLSIDInCategory(const GUID &ClassID, const GUID &CatID);
extern PACKAGE bool __fastcall ResetIStreamToStart(_di_IStream Stream);
extern PACKAGE __int64 __fastcall SizeOfIStreamContents(_di_IStream Stream);
extern PACKAGE System::OleVariant __fastcall StreamToVariantArray(Classes::TStream* Stream)/* overload */;
extern PACKAGE System::OleVariant __fastcall StreamToVariantArray(_di_IStream Stream)/* overload */;
extern PACKAGE void __fastcall VariantArrayToStream(const System::OleVariant &VarArray, Classes::TStream* &Stream)/* overload */;
extern PACKAGE void __fastcall VariantArrayToStream(const System::OleVariant &VarArray, _di_IStream &Stream)/* overload */;

}	/* namespace Jclcom */
using namespace Jclcom;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclcomHPP
