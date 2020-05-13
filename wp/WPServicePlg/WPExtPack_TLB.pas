unit WPExtPack_TLB;

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
// File generated on 06.12.2017 23:41:43 from Type Library described below.

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
  WPExtPackMajorVersion = 1;
  WPExtPackMinorVersion = 0;

  LIBID_WPExtPack: TGUID = '{980F3DE2-7238-453B-B956-C525AA8B018A}';

  CLASS_ExtPack: TGUID = '{B7E041F7-48FA-4E3A-B955-C2282DF9AE04}';
  CLASS_ExtOperAmpFind: TGUID = '{BE4F60B0-6DD7-4C5F-9714-5DD7FD6E6486}';
  CLASS_extOperRpt: TGUID = '{27D94181-5358-45D7-9DD2-2269E5EA53CB}';
  CLASS_IEMeraPlg: TGUID = '{5E317CE5-30A7-4D4B-BC97-183F7B86FDE6}';
  CLASS_ExtOperHilbertFlt: TGUID = '{6587ABE2-E345-43C8-B59E-EDEE3927899A}';
  CLASS_IEManchester2087: TGUID = '{1620490A-3D99-4212-9FC4-FEC87F30AE79}';
type

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  ExtPack = IWPPlugin;
  ExtOperAmpFind = IWPExtOper;
  extOperRpt = IWPExtOper;
  IEMeraPlg = IWPImport;
  ExtOperHilbertFlt = IWPExtOper;
  IEManchester2087 = IWPImport;


// *********************************************************************//
// The Class CoExtPack provides a Create and CreateRemote method to
// create instances of the default interface IWPPlugin exposed by
// the CoClass ExtPack. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtPack = class
    class function Create: IWPPlugin;
    class function CreateRemote(const MachineName: string): IWPPlugin;
  end;

// *********************************************************************//
// The Class CoExtOperAmpFind provides a Create and CreateRemote method to
// create instances of the default interface IWPExtOper exposed by
// the CoClass ExtOperAmpFind. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtOperAmpFind = class
    class function Create: IWPExtOper;
    class function CreateRemote(const MachineName: string): IWPExtOper;
  end;

// *********************************************************************//
// The Class CoextOperRpt provides a Create and CreateRemote method to
// create instances of the default interface IWPExtOper exposed by
// the CoClass extOperRpt. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoextOperRpt = class
    class function Create: IWPExtOper;
    class function CreateRemote(const MachineName: string): IWPExtOper;
  end;

// *********************************************************************//
// The Class CoIEMeraPlg provides a Create and CreateRemote method to
// create instances of the default interface IWPImport exposed by
// the CoClass IEMeraPlg. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoIEMeraPlg = class
    class function Create: IWPImport;
    class function CreateRemote(const MachineName: string): IWPImport;
  end;

// *********************************************************************//
// The Class CoExtOperHilbertFlt provides a Create and CreateRemote method to
// create instances of the default interface IWPExtOper exposed by
// the CoClass ExtOperHilbertFlt. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtOperHilbertFlt = class
    class function Create: IWPExtOper;
    class function CreateRemote(const MachineName: string): IWPExtOper;
  end;

// *********************************************************************//
// The Class CoIEManchester2087 provides a Create and CreateRemote method to
// create instances of the default interface IWPImport exposed by
// the CoClass IEManchester2087. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoIEManchester2087 = class
    class function Create: IWPImport;
    class function CreateRemote(const MachineName: string): IWPImport;
  end;

implementation

uses ComObj;

class function CoExtPack.Create: IWPPlugin;
begin
  Result := CreateComObject(CLASS_ExtPack) as IWPPlugin;
end;

class function CoExtPack.CreateRemote(const MachineName: string): IWPPlugin;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtPack) as IWPPlugin;
end;

class function CoExtOperAmpFind.Create: IWPExtOper;
begin
  Result := CreateComObject(CLASS_ExtOperAmpFind) as IWPExtOper;
end;

class function CoExtOperAmpFind.CreateRemote(const MachineName: string): IWPExtOper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtOperAmpFind) as IWPExtOper;
end;

class function CoextOperRpt.Create: IWPExtOper;
begin
  Result := CreateComObject(CLASS_extOperRpt) as IWPExtOper;
end;

class function CoextOperRpt.CreateRemote(const MachineName: string): IWPExtOper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_extOperRpt) as IWPExtOper;
end;

class function CoIEMeraPlg.Create: IWPImport;
begin
  Result := CreateComObject(CLASS_IEMeraPlg) as IWPImport;
end;

class function CoIEMeraPlg.CreateRemote(const MachineName: string): IWPImport;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_IEMeraPlg) as IWPImport;
end;

class function CoExtOperHilbertFlt.Create: IWPExtOper;
begin
  Result := CreateComObject(CLASS_ExtOperHilbertFlt) as IWPExtOper;
end;

class function CoExtOperHilbertFlt.CreateRemote(const MachineName: string): IWPExtOper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtOperHilbertFlt) as IWPExtOper;
end;

class function CoIEManchester2087.Create: IWPImport;
begin
  Result := CreateComObject(CLASS_IEManchester2087) as IWPImport;
end;

class function CoIEManchester2087.CreateRemote(const MachineName: string): IWPImport;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_IEManchester2087) as IWPImport;
end;

end.

