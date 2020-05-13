unit Project1_TLB;

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

// PASTLWTR : $Revision:   1.130  $
// File generated on 18.07.2005 11:00:32 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\SH_80_1\Project1.tlb (1)
// LIBID: {28B1E681-03E7-4131-BA11-87FFCE15AD52}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\system32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\system32\STDVCL40.DLL)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}

interface

uses ActiveX, Classes, Graphics, StdVCL, Variants, Windows;
  

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

  LIBID_Project1: TGUID = '{28B1E681-03E7-4131-BA11-87FFCE15AD52}';

  IID_ISampleWPPlugIn: TGUID = '{BD59B268-43D9-4F22-AAF8-762DF43E1088}';
  CLASS_TSampleWPPlugIn: TGUID = '{6326FDFB-7D6D-4345-923E-19445D2C060C}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ISampleWPPlugIn = interface;
  ISampleWPPlugInDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TSampleWPPlugIn = ISampleWPPlugIn;


// *********************************************************************//
// Interface: ISampleWPPlugIn
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BD59B268-43D9-4F22-AAF8-762DF43E1088}
// *********************************************************************//
  ISampleWPPlugIn = interface(IDispatch)
    ['{BD59B268-43D9-4F22-AAF8-762DF43E1088}']
    function  Connect(const app: IDispatch): Integer; safecall;
    function  Disconnect: Integer; safecall;
    function  NotifyPlugin(what: Integer; var param: OleVariant): Integer; safecall;
  end;

// *********************************************************************//
// DispIntf:  ISampleWPPlugInDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BD59B268-43D9-4F22-AAF8-762DF43E1088}
// *********************************************************************//
  ISampleWPPlugInDisp = dispinterface
    ['{BD59B268-43D9-4F22-AAF8-762DF43E1088}']
    function  Connect(const app: IDispatch): Integer; dispid 1;
    function  Disconnect: Integer; dispid 2;
    function  NotifyPlugin(what: Integer; var param: OleVariant): Integer; dispid 3;
  end;

// *********************************************************************//
// The Class CoTSampleWPPlugIn provides a Create and CreateRemote method to          
// create instances of the default interface ISampleWPPlugIn exposed by              
// the CoClass TSampleWPPlugIn. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTSampleWPPlugIn = class
    class function Create: ISampleWPPlugIn;
    class function CreateRemote(const MachineName: string): ISampleWPPlugIn;
  end;

implementation

uses ComObj;

class function CoTSampleWPPlugIn.Create: ISampleWPPlugIn;
begin
  Result := CreateComObject(CLASS_TSampleWPPlugIn) as ISampleWPPlugIn;
end;

class function CoTSampleWPPlugIn.CreateRemote(const MachineName: string): ISampleWPPlugIn;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TSampleWPPlugIn) as ISampleWPPlugIn;
end;

end.
