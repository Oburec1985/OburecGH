unit WPServicePack_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 17244 $
// File generated on 06.12.2017 23:43:58 from Type Library described below.

// ************************************************************************  //
// Type Lib: G:\oburec\project2010\2011\wp\WPServicePlg\WPServicePlg (1)
// LIBID: {980F3DE2-7238-453B-B956-C525AA8B018A}
// LCID: 0
// Helpfile:
// HelpString:
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
//   (2) v1.1 Winpos_ole, (C:\Program Files (x86)\MERA\WinPOS\WinPos.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants, Winpos_ole_TLB;



// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  WPServicePackMajorVersion = 1;
  WPServicePackMinorVersion = 0;

  LIBID_WPServicePack: TGUID = '{980F3DE2-7238-453B-B956-C525AA8B018A}';

  CLASS_WPServicePlg: TGUID = '{FFB06950-C91F-4481-88C4-32AF824F5F8D}';
type

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  WPServicePlg = IWPPlugin;


// *********************************************************************//
// The Class CoWPServicePlg provides a Create and CreateRemote method to
// create instances of the default interface IWPPlugin exposed by
// the CoClass WPServicePlg. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoWPServicePlg = class
    class function Create: IWPPlugin;
    class function CreateRemote(const MachineName: string): IWPPlugin;
  end;

implementation

uses ComObj;

class function CoWPServicePlg.Create: IWPPlugin;
begin
  Result := CreateComObject(CLASS_WPServicePlg) as IWPPlugin;
end;

class function CoWPServicePlg.CreateRemote(const MachineName: string): IWPPlugin;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPServicePlg) as IWPPlugin;
end;

end.

