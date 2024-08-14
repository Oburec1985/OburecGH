unit WpOperPlg_TLB;

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
// File generated on 12.07.2024 17:31:41 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\OneDrive\Документы\RAD Studio\Projects\Project1 (1)
// LIBID: {EF588BC7-1D9B-406A-9E60-FCE63C27FA95}
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
  Project1MajorVersion = 1;
  Project1MinorVersion = 0;

  LIBID_WpOperPlg: TGUID = '{EF588BC7-1D9B-406A-9E60-FCE63C27FA95}';

  CLASS_OperPack: TGUID = '{74509589-E7EF-40E3-B0F5-3C37988B3F75}';
type

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  OperPack = IWPPlugin;


// *********************************************************************//
// The Class Coclass1 provides a Create and CreateRemote method to
// create instances of the default interface IWPPlugin exposed by
// the CoClass class1. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoOperPack = class
    class function Create: IWPPlugin;
    class function CreateRemote(const MachineName: string): IWPPlugin;
  end;

implementation

uses ComObj;

class function CoOperPack.Create: IWPPlugin;
begin
  Result := CreateComObject(CLASS_OperPack) as IWPPlugin;
end;

class function CoOperPack.CreateRemote(const MachineName: string): IWPPlugin;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OperPack) as IWPPlugin;
end;

end.

