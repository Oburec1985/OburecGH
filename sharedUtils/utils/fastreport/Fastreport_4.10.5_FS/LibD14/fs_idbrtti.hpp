// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fs_idbrtti.pas' rev: 21.00

#ifndef Fs_idbrttiHPP
#define Fs_idbrttiHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Fs_iinterpreter.hpp>	// Pascal unit
#include <Fs_itools.hpp>	// Pascal unit
#include <Fs_iclassesrtti.hpp>	// Pascal unit
#include <Fs_ievents.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fs_idbrtti
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfsDBRTTI;
class PASCALIMPLEMENTATION TfsDBRTTI : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfsDBRTTI(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfsDBRTTI(void) { }
	
};


class DELPHICLASS TfsDatasetNotifyEvent;
class PASCALIMPLEMENTATION TfsDatasetNotifyEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(Db::TDataSet* Dataset);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsDatasetNotifyEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsDatasetNotifyEvent(void) { }
	
};


class DELPHICLASS TfsFilterRecordEvent;
class PASCALIMPLEMENTATION TfsFilterRecordEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(Db::TDataSet* DataSet, bool &Accept);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsFilterRecordEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsFilterRecordEvent(void) { }
	
};


class DELPHICLASS TfsFieldGetTextEvent;
class PASCALIMPLEMENTATION TfsFieldGetTextEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(Db::TField* Sender, System::UnicodeString &Text, bool DisplayText);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsFieldGetTextEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsFieldGetTextEvent(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Fs_idbrtti */
using namespace Fs_idbrtti;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Fs_idbrttiHPP
