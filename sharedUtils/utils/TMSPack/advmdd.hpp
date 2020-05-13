// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advmdd.pas' rev: 21.00

#ifndef AdvmddHPP
#define AdvmddHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Shlobj.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advmdd
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TAMDropTarget;
class PASCALIMPLEMENTATION TAMDropTarget : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
public:
	HRESULT __stdcall DragEnter(const _di_IDataObject DataObj, int grfKeyState, const Types::TPoint pt, int &dwEffect);
	HRESULT __stdcall DragOver(int grfKeyState, const Types::TPoint pt, int &dwEffect);
	HRESULT __stdcall DragLeave(void);
	HRESULT __stdcall Drop(const _di_IDataObject DataObj, int grfKeyState, const Types::TPoint pt, int &dwEffect);
	
private:
	bool FOk;
	
public:
	__fastcall TAMDropTarget(void);
	virtual bool __fastcall WantsFiles(void);
	virtual bool __fastcall WantsText(void);
	virtual void __fastcall DropText(const Types::TPoint &pt, System::UnicodeString s);
	virtual void __fastcall DropRTF(const Types::TPoint &pt, System::UnicodeString s);
	virtual void __fastcall DropFiles(const Types::TPoint &pt, Classes::TStrings* Files);
	virtual void __fastcall DragMouseMove(const Types::TPoint &pt, bool &Allow);
	virtual void __fastcall DragMouseEnter(const Types::TPoint &pt) = 0 ;
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TAMDropTarget(void) { }
	
private:
	void *__IDropTarget;	/* IDropTarget */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IDropTarget()
	{
		_di_IDropTarget intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IDropTarget*(void) { return (IDropTarget*)&__IDropTarget; }
	#endif
	
};


class DELPHICLASS TAMDropSource;
class PASCALIMPLEMENTATION TAMDropSource : public System::TInterfacedObject
{
	typedef System::TInterfacedObject inherited;
	
private:
	bool fNoAccept;
	
public:
	HRESULT __stdcall QueryContinueDrag(BOOL fEscapePressed, int grfKeyState);
	HRESULT __stdcall GiveFeedback(int dwEffect);
public:
	/* TObject.Create */ inline __fastcall TAMDropSource(void) : System::TInterfacedObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TAMDropSource(void) { }
	
private:
	void *__IDropSource;	/* IDropSource */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IDropSource()
	{
		_di_IDropSource intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IDropSource*(void) { return (IDropSource*)&__IDropSource; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall SetRTFAware(bool Value);
extern PACKAGE int __fastcall StandardEffect(Classes::TShiftState Keys);
extern PACKAGE HRESULT __fastcall StartTextDoDragDrop(System::UnicodeString stxt, System::UnicodeString srtf, int dwOKEffects, int &dwEffect);

}	/* namespace Advmdd */
using namespace Advmdd;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvmddHPP
