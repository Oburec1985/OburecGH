// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclstructstorage.pas' rev: 21.00

#ifndef JclstructstorageHPP
#define JclstructstorageHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclstructstorage
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclStructStorageError;
class PASCALIMPLEMENTATION EJclStructStorageError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclStructStorageError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclStructStorageError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclStructStorageError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclStructStorageError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclStructStorageError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclStructStorageError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclStructStorageError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclStructStorageError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclStructStorageError(void) { }
	
};


#pragma option push -b-
enum TJclStructStorageAccessMode { smOpenRead, smOpenWrite, smCreate, smShareDenyRead, smShareDenyWrite, smTransacted };
#pragma option pop

typedef Set<TJclStructStorageAccessMode, smOpenRead, smTransacted>  TJclStructStorageAccessModes;

class DELPHICLASS TJclStructStorageFolder;
class PASCALIMPLEMENTATION TJclStructStorageFolder : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString __fastcall GetName(void);
	
protected:
	_di_IStorage FStorage;
	HRESULT FLastError;
	System::UnicodeString FFileName;
	TJclStructStorageAccessModes FAccessMode;
	unsigned FConvertedMode;
	void __fastcall Check(void);
	bool __fastcall CheckResult(HRESULT HR);
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	
public:
	__classmethod HRESULT __fastcall IsStructured(const System::UnicodeString FileName);
	__classmethod HRESULT __fastcall Convert(const System::UnicodeString FileName);
	bool __fastcall CopyTo(const System::UnicodeString OldName, const System::UnicodeString NewName, TJclStructStorageFolder* Dest);
	bool __fastcall MoveTo(const System::UnicodeString OldName, const System::UnicodeString NewName, TJclStructStorageFolder* Dest);
	bool __fastcall Commit(void);
	bool __fastcall Revert(void);
	__fastcall virtual TJclStructStorageFolder(const System::UnicodeString FileName, TJclStructStorageAccessModes AccessMode, bool OpenDirect);
	__fastcall virtual ~TJclStructStorageFolder(void);
	bool __fastcall GetStats(/* out */ tagSTATSTG &Stat, bool IncludeName);
	void __fastcall FreeStats(tagSTATSTG &Stat);
	bool __fastcall GetSubItems(Classes::TStrings* Strings, bool Folders);
	bool __fastcall Add(const System::UnicodeString Name, bool IsFolder);
	bool __fastcall Delete(const System::UnicodeString Name);
	bool __fastcall Rename(const System::UnicodeString OldName, const System::UnicodeString NewName);
	bool __fastcall GetFolder(const System::UnicodeString Name, /* out */ TJclStructStorageFolder* &Storage);
	bool __fastcall GetFileStream(const System::UnicodeString Name, /* out */ Classes::TStream* &Stream);
	bool __fastcall SetElementTimes(const System::UnicodeString Name, const tagSTATSTG &Stat);
	__property System::UnicodeString Name = {read=GetName};
	__property _di_IStorage Intf = {read=FStorage};
	__property HRESULT LastError = {read=FLastError, nodefault};
};


class DELPHICLASS TJclStructStorageStream;
class PASCALIMPLEMENTATION TJclStructStorageStream : public Classes::TStream
{
	typedef Classes::TStream inherited;
	
private:
	System::UnicodeString __fastcall GetName(void);
	
protected:
	_di_IStream FStream;
	System::UnicodeString FName;
	HRESULT FLastError;
	void __fastcall Check(void);
	bool __fastcall CheckResult(HRESULT HR);
	virtual void __fastcall SetSize(int NewSize)/* overload */;
	
public:
	__fastcall virtual ~TJclStructStorageStream(void);
	bool __fastcall GetStats(/* out */ tagSTATSTG &Stat, bool IncludeName);
	void __fastcall FreeStats(tagSTATSTG &Stat);
	TJclStructStorageStream* __fastcall Clone(void);
	bool __fastcall CopyTo(TJclStructStorageStream* Stream, __int64 Size);
	virtual int __fastcall Read(void *Buffer, int Count);
	virtual int __fastcall Write(const void *Buffer, int Count);
	virtual int __fastcall Seek(int Offset, System::Word Origin)/* overload */;
	__property System::UnicodeString Name = {read=GetName};
	__property _di_IStream Intf = {read=FStream};
	__property HRESULT LastError = {read=FLastError, nodefault};
public:
	/* TObject.Create */ inline __fastcall TJclStructStorageStream(void) : Classes::TStream() { }
	
	
/* Hoisted overloads: */
	
protected:
	inline void __fastcall  SetSize(const __int64 NewSize){ Classes::TStream::SetSize(NewSize); }
	
public:
	inline __int64 __fastcall  Seek(const __int64 Offset, Classes::TSeekOrigin Origin){ return Classes::TStream::Seek(Offset, Origin); }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall CoMallocFree(void * P);

}	/* namespace Jclstructstorage */
using namespace Jclstructstorage;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclstructstorageHPP
