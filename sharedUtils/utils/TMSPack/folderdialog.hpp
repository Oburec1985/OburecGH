// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Folderdialog.pas' rev: 21.00

#ifndef FolderdialogHPP
#define FolderdialogHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Folderdialog
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TOptions { fdoBrowseForComputer, fdoBrowseForPrinter, fdoDontgoBelowDomain, fdoReturnFSAncestors, fdoReturnOnlyFSDirs, fdoStatusText, fdoNewDialogStyle, fdoNoNewFolderButton, fdoEditBox };
#pragma option pop

typedef Set<TOptions, fdoBrowseForComputer, fdoEditBox>  TFolderOptions;

#pragma option push -b-
enum TDialogPosition { fdpDefault, fdpScreenCenter, fdpXY };
#pragma option pop

class DELPHICLASS TFolderDialog;
class PASCALIMPLEMENTATION TFolderDialog : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	System::UnicodeString FTitle;
	System::UnicodeString FDirectory;
	TFolderOptions FOptions;
	int FImageIndex;
	int FDialogX;
	int FDialogY;
	TDialogPosition FDialogPosition;
	System::UnicodeString FCaption;
	HWND FParent;
	void __fastcall SetTitle(const System::UnicodeString Value);
	void __fastcall SetDirectory(const System::UnicodeString Value);
	void __fastcall SetOptions(const TFolderOptions Value);
	void __fastcall SetDialogPosition(const TDialogPosition Value);
	void __fastcall SetDialogX(const int Value);
	void __fastcall SetDialogY(const int Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	
protected:
	int __fastcall GetVersionNr(void);
	HWND __fastcall GetParent(void);
	
public:
	__fastcall virtual TFolderDialog(Classes::TComponent* Aowner);
	bool __fastcall Execute(void);
	
__published:
	__property System::UnicodeString Caption = {read=FCaption, write=FCaption};
	__property System::UnicodeString Title = {read=FTitle, write=SetTitle};
	__property System::UnicodeString Directory = {read=FDirectory, write=SetDirectory};
	__property int ImageIndex = {read=FImageIndex, nodefault};
	__property TFolderOptions Options = {read=FOptions, write=SetOptions, default=64};
	__property TDialogPosition DialogPosition = {read=FDialogPosition, write=SetDialogPosition, default=0};
	__property int DialogX = {read=FDialogX, write=SetDialogX, nodefault};
	__property int DialogY = {read=FDialogY, write=SetDialogY, nodefault};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TFolderDialog(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x1;
static const ShortInt REL_VER = 0x2;
static const ShortInt BLD_VER = 0x0;

}	/* namespace Folderdialog */
using namespace Folderdialog;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FolderdialogHPP
