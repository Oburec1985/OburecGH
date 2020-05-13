// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclshell.pas' rev: 21.00

#ifndef JclshellHPP
#define JclshellHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Shlobj.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclwin32.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclshell
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TSHDeleteOption { doSilent, doAllowUndo, doFilesOnly };
#pragma option pop

typedef Set<TSHDeleteOption, doSilent, doFilesOnly>  TSHDeleteOptions;

#pragma option push -b-
enum TSHRenameOption { roSilent, roRenameOnCollision };
#pragma option pop

typedef Set<TSHRenameOption, roSilent, roRenameOnCollision>  TSHRenameOptions;

#pragma option push -b-
enum TSHCopyOption { coSilent, coAllowUndo, coFilesOnly, coNoConfirmation };
#pragma option pop

typedef Set<TSHCopyOption, coSilent, coNoConfirmation>  TSHCopyOptions;

#pragma option push -b-
enum TSHMoveOption { moSilent, moAllowUndo, moFilesOnly, moNoConfirmation };
#pragma option pop

typedef Set<TSHMoveOption, moSilent, moNoConfirmation>  TSHMoveOptions;

#pragma option push -b-
enum TEnumFolderFlag { efFolders, efNonFolders, efIncludeHidden };
#pragma option pop

typedef Set<TEnumFolderFlag, efFolders, efIncludeHidden>  TEnumFolderFlags;

struct TEnumFolderRec
{
	
public:
	System::UnicodeString DisplayName;
	unsigned Attributes;
	HICON IconLarge;
	HICON IconSmall;
	_ITEMIDLIST *Item;
	_di_IEnumIDList EnumIdList;
	_di_IShellFolder Folder;
};


struct TShellLink;
typedef TShellLink *PShellLink;

struct TShellLink
{
	
public:
	System::UnicodeString Arguments;
	int ShowCmd;
	System::UnicodeString WorkingDirectory;
	_ITEMIDLIST *IdList;
	System::UnicodeString Target;
	System::UnicodeString Description;
	System::UnicodeString IconLocation;
	int IconIndex;
	System::Word HotKey;
};


#pragma option push -b-
enum TJclFileExeType { etError, etMsDos, etWin16, etWin32Gui, etWin32Con };
#pragma option pop

typedef int INSTALLSTATE;

//-- var, const, procedure ---------------------------------------------------
#define MSILIB L"msi.dll"
#define GetShortcutTargetName L"MsiGetShortcutTargetW"
#define GetComponentPathName L"MsiGetComponentPathW"
extern PACKAGE unsigned RtdlMsiLibHandle;
extern PACKAGE unsigned __stdcall (*RtdlMsiGetShortcutTarget)(System::WideChar * szShortcutPath, System::WideChar * szProductCode, System::WideChar * szFeatureId, System::WideChar * szComponentCode);
extern PACKAGE int __stdcall (*RtdlMsiGetComponentPath)(System::WideChar * szProduct, System::WideChar * szComponent, System::WideChar * lpPathBuf, PDWORD pcchBuf);
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall SHDeleteFiles(unsigned Parent, const System::UnicodeString Files, TSHDeleteOptions Options);
extern PACKAGE bool __fastcall SHDeleteFolder(unsigned Parent, const System::UnicodeString Folder, TSHDeleteOptions Options);
extern PACKAGE bool __fastcall SHRenameFile(const System::UnicodeString Src, const System::UnicodeString Dest, TSHRenameOptions Options);
extern PACKAGE bool __fastcall SHCopy(unsigned Parent, const System::UnicodeString Src, const System::UnicodeString Dest, TSHCopyOptions Options);
extern PACKAGE bool __fastcall SHMove(unsigned Parent, const System::UnicodeString Src, const System::UnicodeString Dest, TSHMoveOptions Options);
extern PACKAGE void __fastcall SHEnumFolderClose(TEnumFolderRec &F);
extern PACKAGE bool __fastcall SHEnumFolderNext(TEnumFolderRec &F);
extern PACKAGE bool __fastcall SHEnumSpecialFolderFirst(unsigned SpecialFolder, TEnumFolderFlags Flags, TEnumFolderRec &F);
extern PACKAGE bool __fastcall SHEnumFolderFirst(const System::UnicodeString Folder, TEnumFolderFlags Flags, TEnumFolderRec &F);
extern PACKAGE System::UnicodeString __fastcall GetSpecialFolderLocation(const int FolderID);
extern PACKAGE bool __fastcall DisplayPropDialog(const unsigned Handle, const System::UnicodeString FileName)/* overload */;
extern PACKAGE bool __fastcall DisplayPropDialog(const unsigned Handle, Shlobj::PItemIDList Item)/* overload */;
extern PACKAGE bool __fastcall DisplayContextMenuPidl(const unsigned Handle, const _di_IShellFolder Folder, Shlobj::PItemIDList Item, const Types::TPoint &Pos);
extern PACKAGE bool __fastcall DisplayContextMenu(const unsigned Handle, const System::UnicodeString FileName, const Types::TPoint &Pos);
extern PACKAGE bool __fastcall OpenFolder(const System::UnicodeString Path, unsigned Parent = (unsigned)(0x0), bool Explore = false);
extern PACKAGE bool __fastcall OpenSpecialFolder(int FolderID, unsigned Parent = (unsigned)(0x0), bool Explore = false);
extern PACKAGE bool __fastcall SHAllocMem(/* out */ void * &P, int Count);
extern PACKAGE bool __fastcall SHFreeMem(void * &P);
extern PACKAGE bool __fastcall SHGetMem(void * &P, int Count);
extern PACKAGE bool __fastcall SHReallocMem(void * &P, int Count);
extern PACKAGE Shlobj::PItemIDList __fastcall DriveToPidlBind(const System::UnicodeString DriveName, /* out */ _di_IShellFolder &Folder);
extern PACKAGE Shlobj::PItemIDList __fastcall PathToPidl(const System::UnicodeString Path, _di_IShellFolder Folder);
extern PACKAGE Shlobj::PItemIDList __fastcall PathToPidlBind(const System::UnicodeString FileName, /* out */ _di_IShellFolder &Folder);
extern PACKAGE bool __fastcall PidlBindToParent(Shlobj::PItemIDList IdList, /* out */ _di_IShellFolder &Folder, /* out */ Shlobj::PItemIDList &Last);
extern PACKAGE bool __fastcall PidlCompare(Shlobj::PItemIDList Pidl1, Shlobj::PItemIDList Pidl2);
extern PACKAGE bool __fastcall PidlCopy(Shlobj::PItemIDList Source, /* out */ Shlobj::PItemIDList &Dest);
extern PACKAGE bool __fastcall PidlFree(Shlobj::PItemIDList &IdList);
extern PACKAGE int __fastcall PidlGetDepth(Shlobj::PItemIDList Pidl);
extern PACKAGE int __fastcall PidlGetLength(Shlobj::PItemIDList Pidl);
extern PACKAGE Shlobj::PItemIDList __fastcall PidlGetNext(Shlobj::PItemIDList Pidl);
extern PACKAGE System::UnicodeString __fastcall PidlToPath(Shlobj::PItemIDList IdList);
extern PACKAGE bool __fastcall StrRetFreeMem(const _STRRET &StrRet);
extern PACKAGE System::UnicodeString __fastcall StrRetToString(Shlobj::PItemIDList IdList, const _STRRET &StrRet, bool Free);
extern PACKAGE void __fastcall ShellLinkFree(TShellLink &Link);
extern PACKAGE HRESULT __fastcall ShellLinkCreateSystem(const TShellLink &Link, const int Folder, const System::UnicodeString FileName);
extern PACKAGE HRESULT __fastcall ShellLinkCreate(const TShellLink &Link, const System::UnicodeString FileName);
extern PACKAGE HRESULT __fastcall ShellLinkResolve(const System::UnicodeString FileName, /* out */ TShellLink &Link)/* overload */;
extern PACKAGE HRESULT __fastcall ShellLinkResolve(const System::UnicodeString FileName, /* out */ TShellLink &Link, const unsigned ResolveFlags)/* overload */;
extern PACKAGE HICON __fastcall ShellLinkIcon(const TShellLink &Link)/* overload */;
extern PACKAGE HICON __fastcall ShellLinkIcon(const System::UnicodeString FileName)/* overload */;
extern PACKAGE System::UnicodeString __fastcall SHGetItemInfoTip(const _di_IShellFolder Folder, Shlobj::PItemIDList Item);
extern PACKAGE bool __fastcall SHDllGetVersion(const System::UnicodeString FileName, _DLLVERSIONINFO &Version);
extern PACKAGE bool __fastcall OverlayIcon(HICON &Icon, HICON Overlay, bool Large);
extern PACKAGE bool __fastcall OverlayIconShortCut(HICON &Large, HICON &Small);
extern PACKAGE bool __fastcall OverlayIconShared(HICON &Large, HICON &Small);
extern PACKAGE HICON __fastcall GetSystemIcon(int IconIndex, unsigned Flags);
extern PACKAGE bool __fastcall ShellExecEx(const System::UnicodeString FileName, const System::UnicodeString Parameters = L"", const System::UnicodeString Verb = L"", int CmdShow = 0x1);
extern PACKAGE bool __fastcall ShellExec(int Wnd, const System::UnicodeString Operation, const System::UnicodeString FileName, const System::UnicodeString Parameters, const System::UnicodeString Directory, int ShowCommand);
extern PACKAGE bool __fastcall ShellExecAndWait(const System::UnicodeString FileName, const System::UnicodeString Parameters = L"", const System::UnicodeString Verb = L"", int CmdShow = 0x1, const System::UnicodeString Directory = L"");
extern PACKAGE bool __fastcall ShellOpenAs(const System::UnicodeString FileName);
extern PACKAGE bool __fastcall ShellRasDial(const System::UnicodeString EntryName);
extern PACKAGE bool __fastcall ShellRunControlPanel(const System::UnicodeString NameOrFileName, int AppletNumber = 0x0);
extern PACKAGE bool __fastcall RunAsAdmin(const System::UnicodeString FileName, const System::UnicodeString Parameters = L"", const unsigned Parent = (unsigned)(0x0));
extern PACKAGE TJclFileExeType __fastcall GetFileExeType(const Sysutils::TFileName FileName);
extern PACKAGE System::UnicodeString __fastcall ShellFindExecutable(const System::UnicodeString FileName, const System::UnicodeString DefaultDir);
extern PACKAGE HICON __fastcall GetFileNameIcon(const System::UnicodeString FileName, unsigned Flags = (unsigned)(0x0));

}	/* namespace Jclshell */
using namespace Jclshell;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclshellHPP
