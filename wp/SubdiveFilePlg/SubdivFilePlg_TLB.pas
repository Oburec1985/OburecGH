unit SubdivFilePlg_TLB;

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
// File generated on 07.02.2020 12:09:03 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Oburec\delphi\2011\wp\SubdiveFilePlg\SubdivFilePlg (1)
// LIBID: {441B34DD-53C2-4475-BB09-38257F0EFF27}
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
  SubdivFilePlgMajorVersion = 1;
  SubdivFilePlgMinorVersion = 0;

  LIBID_SubdivFilePlg: TGUID = '{441B34DD-53C2-4475-BB09-38257F0EFF27}';

  CLASS_SubdivePlgClass: TGUID = '{A49E12A2-6D5D-4526-A520-6214C2FB603B}';
type

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  SubdivePlgClass = IWPPlugin;


// *********************************************************************//
// The Class CoSubdivePlgClass provides a Create and CreateRemote method to
// create instances of the default interface IWPPlugin exposed by
// the CoClass SubdivePlgClass. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoSubdivePlgClass = class
    class function Create: IWPPlugin;
    class function CreateRemote(const MachineName: string): IWPPlugin;
  end;

implementation

uses ComObj;

class function CoSubdivePlgClass.Create: IWPPlugin;
begin
  Result := CreateComObject(CLASS_SubdivePlgClass) as IWPPlugin;
end;

class function CoSubdivePlgClass.CreateRemote(const MachineName: string): IWPPlugin;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SubdivePlgClass) as IWPPlugin;
end;

end.

