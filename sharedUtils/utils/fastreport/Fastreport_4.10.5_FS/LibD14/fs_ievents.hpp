// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fs_ievents.pas' rev: 21.00

#ifndef Fs_ieventsHPP
#define Fs_ieventsHPP

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
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fs_ievents
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfsNotifyEvent;
class PASCALIMPLEMENTATION TfsNotifyEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsNotifyEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsNotifyEvent(void) { }
	
};


class DELPHICLASS TfsMouseEvent;
class PASCALIMPLEMENTATION TfsMouseEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsMouseEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsMouseEvent(void) { }
	
};


class DELPHICLASS TfsMouseMoveEvent;
class PASCALIMPLEMENTATION TfsMouseMoveEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsMouseMoveEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsMouseMoveEvent(void) { }
	
};


class DELPHICLASS TfsKeyEvent;
class PASCALIMPLEMENTATION TfsKeyEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsKeyEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsKeyEvent(void) { }
	
};


class DELPHICLASS TfsKeyPressEvent;
class PASCALIMPLEMENTATION TfsKeyPressEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender, System::WideChar &Key);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsKeyPressEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsKeyPressEvent(void) { }
	
};


class DELPHICLASS TfsCloseEvent;
class PASCALIMPLEMENTATION TfsCloseEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender, Forms::TCloseAction &Action);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsCloseEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsCloseEvent(void) { }
	
};


class DELPHICLASS TfsCloseQueryEvent;
class PASCALIMPLEMENTATION TfsCloseQueryEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender, bool &CanClose);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsCloseQueryEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsCloseQueryEvent(void) { }
	
};


class DELPHICLASS TfsCanResizeEvent;
class PASCALIMPLEMENTATION TfsCanResizeEvent : public Fs_iinterpreter::TfsCustomEvent
{
	typedef Fs_iinterpreter::TfsCustomEvent inherited;
	
public:
	void __fastcall DoEvent(System::TObject* Sender, int &NewWidth, int &NewHeight, bool &Resize);
	virtual void * __fastcall GetMethod(void);
public:
	/* TfsCustomEvent.Create */ inline __fastcall virtual TfsCanResizeEvent(System::TObject* AObject, Fs_iinterpreter::TfsProcVariable* AHandler) : Fs_iinterpreter::TfsCustomEvent(AObject, AHandler) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfsCanResizeEvent(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Fs_ievents */
using namespace Fs_ievents;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Fs_ieventsHPP
