unit ExtOperSample_TLB;

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
// File generated on 12.09.2013 12:57:20 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\WP\Debug\PlugIns\ExtOper\ExtOperSample (1)
// LIBID: {3507CE8D-A3C6-46A0-8D2E-5C6D2F43C18A}
// LCID: 0
// Helpfile:
// HelpString:
// DepndLst:
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
//   (2) v4.0 StdVCL, (stdvcl40.dll)
//   (3) v1.1 Winpos_ole, (D:\WP\Debug\WinPos.exe)
//   (4) v1.1 Winpos_ole, (D:\WP\Debug\WinPos.exe)
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
  ExtOperSampleMajorVersion = 1;
  ExtOperSampleMinorVersion = 0;

  LIBID_ExtOperSample: TGUID = '{3507CE8D-A3C6-46A0-8D2E-5C6D2F43C18A}';

  CLASS_ExtOperSmplPlugin: TGUID = '{FAEC8A33-DE16-43BC-8B99-B82360AB5905}';
  CLASS_ExtOperPower: TGUID = '{D9400F38-196D-4060-B08D-C8022CC20330}';
  CLASS_ExtOperPoincareD: TGUID = '{2D8290F2-2754-4905-861F-5A95C48DC163}';
  CLASS_ExtOperSequence1: TGUID = '{A07A1E2B-7D3A-4520-9984-8F526A6124A1}';
  CLASS_ExtOperMacro: TGUID = '{D3C1A26C-C4BD-44A5-A9D3-E889B3C52552}';
type

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  ExtOperSmplPlugin = IWPPlugin;
  ExtOperPower = IWPExtOper;
  ExtOperPoincareD = IWPExtOper;
  ExtOperSequence1 = IWPExtOper;
  ExtOperMacro = IWPExtOper;


// *********************************************************************//
// The Class CoExtOperSmplPlugin provides a Create and CreateRemote method to
// create instances of the default interface IWPPlugin exposed by
// the CoClass ExtOperSmplPlugin. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtOperSmplPlugin = class
    class function Create: IWPPlugin;
    class function CreateRemote(const MachineName: string): IWPPlugin;
  end;

// *********************************************************************//
// The Class CoExtOperPower provides a Create and CreateRemote method to
// create instances of the default interface IWPExtOper exposed by
// the CoClass ExtOperPower. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtOperPower = class
    class function Create: IWPExtOper;
    class function CreateRemote(const MachineName: string): IWPExtOper;
  end;

// *********************************************************************//
// The Class CoExtOperPoincareD provides a Create and CreateRemote method to
// create instances of the default interface IWPExtOper exposed by
// the CoClass ExtOperPoincareD. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtOperPoincareD = class
    class function Create: IWPExtOper;
    class function CreateRemote(const MachineName: string): IWPExtOper;
  end;

// *********************************************************************//
// The Class CoExtOperSequence1 provides a Create and CreateRemote method to
// create instances of the default interface IWPExtOper exposed by
// the CoClass ExtOperSequence1. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtOperSequence1 = class
    class function Create: IWPExtOper;
    class function CreateRemote(const MachineName: string): IWPExtOper;
  end;

// *********************************************************************//
// The Class CoExtOperMacro provides a Create and CreateRemote method to
// create instances of the default interface IWPExtOper exposed by
// the CoClass ExtOperMacro. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoExtOperMacro = class
    class function Create: IWPExtOper;
    class function CreateRemote(const MachineName: string): IWPExtOper;
  end;

implementation

uses ComObj;

class function CoExtOperSmplPlugin.Create: IWPPlugin;
begin
  Result := CreateComObject(CLASS_ExtOperSmplPlugin) as IWPPlugin;
end;

class function CoExtOperSmplPlugin.CreateRemote(const MachineName: string): IWPPlugin;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtOperSmplPlugin) as IWPPlugin;
end;

class function CoExtOperPower.Create: IWPExtOper;
begin
  Result := CreateComObject(CLASS_ExtOperPower) as IWPExtOper;
end;

class function CoExtOperPower.CreateRemote(const MachineName: string): IWPExtOper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtOperPower) as IWPExtOper;
end;

class function CoExtOperPoincareD.Create: IWPExtOper;
begin
  Result := CreateComObject(CLASS_ExtOperPoincareD) as IWPExtOper;
end;

class function CoExtOperPoincareD.CreateRemote(const MachineName: string): IWPExtOper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtOperPoincareD) as IWPExtOper;
end;

class function CoExtOperSequence1.Create: IWPExtOper;
begin
  Result := CreateComObject(CLASS_ExtOperSequence1) as IWPExtOper;
end;

class function CoExtOperSequence1.CreateRemote(const MachineName: string): IWPExtOper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtOperSequence1) as IWPExtOper;
end;

class function CoExtOperMacro.Create: IWPExtOper;
begin
  Result := CreateComObject(CLASS_ExtOperMacro) as IWPExtOper;
end;

class function CoExtOperMacro.CreateRemote(const MachineName: string): IWPExtOper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ExtOperMacro) as IWPExtOper;
end;

end.

