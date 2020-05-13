unit Winpos_ole_TLB;

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

// PASTLWTR : $Revision:   1.130.1.0.1.0.1.6  $
// File generated on 06/01/2005 13:58:47 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\WinPos3\Debug\WinPos.exe (1)
// LIBID: {BB9A452A-71C4-411E-BCCF-CA1D2ADCFB8C}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (D:\WINDOWS\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (D:\WINDOWS\System32\STDVCL40.DLL)
// Errors:
//   Hint: Parameter 'type' of IWinPOS.LoadSignal changed to 'type_'
//   Hint: Parameter 'type' of IWinPOS.SaveSignal changed to 'type_'
//   Hint: Parameter 'type' of IWinPOS.CreateSignal changed to 'type_'
//   Hint: Parameter 'Object' of IWinPOS.Link changed to 'Object_'
//   Hint: Parameter 'Object' of IWinPOS.Unlink changed to 'Object_'
//   Hint: Parameter 'Object' of IWinPOS.GetNode changed to 'Object_'
//   Hint: Member 'type' of 'IWPUSML' changed to 'type_'
//   Hint: Parameter 'Object' of IWPNode.Link changed to 'Object_'
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  Winpos_oleMajorVersion = 1;
  Winpos_oleMinorVersion = 0;

  LIBID_Winpos_ole: TGUID = '{BB9A452A-71C4-411E-BCCF-CA1D2ADCFB8C}';

  DIID_IWinPOS: TGUID = '{69E69FFF-3501-404B-A1FF-536226245C1B}';
  CLASS_WinPOS: TGUID = '{C6DC36F2-D0D5-4AA7-8FF9-AB8BB80A0F73}';
  DIID_IWPSignal: TGUID = '{CA7B31AE-CD01-4EB8-9C40-F48F61297292}';
  CLASS_WPSignal: TGUID = '{DAA0ADA4-6E71-4993-B9D6-2A38D6420DFA}';
  DIID_IWPUSML: TGUID = '{87FA08E2-DA9C-4BDC-819F-3D70AACDFED6}';
  CLASS_WPUSML: TGUID = '{B015674F-1563-482F-ADE4-A0496816874A}';
  DIID_IWPNode: TGUID = '{E5E07BCC-5AD9-4D0D-BA7C-2B1934E43CAB}';
  CLASS_WPNode: TGUID = '{9F7DA507-EE2F-4385-9020-86B0FE776ACC}';
  DIID_IWPGraphs: TGUID = '{6EC4A8B2-95A0-4F67-919A-F63A002EFC52}';
  CLASS_WPGraphs: TGUID = '{71F8B83A-2D9D-4F18-8506-B7B6C932E968}';
  DIID_IWPOperator: TGUID = '{5819D3E4-58AC-4A0F-A24D-A6BCEFC41B56}';
  CLASS_WPOperator: TGUID = '{3E9EF875-5F7D-4B15-85F7-34AB8E5D4086}';
  DIID_IWPOpManager: TGUID = '{7102D9F6-913A-41DF-A60D-7B36DD28D150}';
  CLASS_WPOpManager: TGUID = '{F2E45036-48F7-4196-9BA8-088CC1BF3A7B}';
  DIID_IWPTree: TGUID = '{9FAE7440-650A-4A71-9D1E-CC96ABAB7A99}';
  CLASS_WPTree: TGUID = '{17537B46-A715-4F61-A33A-1185F0B13561}';
  DIID_IWPObject: TGUID = '{68965773-29D7-4EF8-A835-0C94BFDEF186}';
  CLASS_WPObject: TGUID = '{9E35C1D1-2ECB-477F-9708-239E48EC10D4}';
  DIID_IWPPlugin: TGUID = '{51A85FC7-DAF3-497B-8899-7D0326D072BC}';
  CLASS_WPPlugin: TGUID = '{424A7882-7E39-4647-8478-DB554BE24C3B}';
  DIID_IFileDialog: TGUID = '{BB5E9128-BD80-4AA8-A77A-8D6C87B2F911}';
  CLASS_COleFileDialog: TGUID = '{967AD1B9-4561-4F5D-B3FC-120876EE6870}';
  DIID_IWPDlgChSignal: TGUID = '{B3948801-B7AD-11D7-84B0-00C0262B9C1C}';
  CLASS_WPDlgChSignal: TGUID = '{B3948803-B7AD-11D7-84B0-00C0262B9C1C}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IWinPOS = dispinterface;
  IWPSignal = dispinterface;
  IWPUSML = dispinterface;
  IWPNode = dispinterface;
  IWPGraphs = dispinterface;
  IWPOperator = dispinterface;
  IWPOpManager = dispinterface;
  IWPTree = dispinterface;
  IWPObject = dispinterface;
  IWPPlugin = dispinterface;
  IFileDialog = dispinterface;
  IWPDlgChSignal = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  WinPOS = IWinPOS;
  WPSignal = IWPSignal;
  WPUSML = IWPUSML;
  WPNode = IWPNode;
  WPGraphs = IWPGraphs;
  WPOperator = IWPOperator;
  WPOpManager = IWPOpManager;
  WPTree = IWPTree;
  WPObject = IWPObject;
  WPPlugin = IWPPlugin;
  COleFileDialog = IFileDialog;
  WPDlgChSignal = IWPDlgChSignal;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PInteger1 = ^Integer; {*}


// *********************************************************************//
// DispIntf:  IWinPOS
// Flags:     (4096) Dispatchable
// GUID:      {69E69FFF-3501-404B-A1FF-536226245C1B}
// *********************************************************************//
  IWinPOS = dispinterface
    ['{69E69FFF-3501-404B-A1FF-536226245C1B}']
    property SelectedGraph: WideString dispid 1;
    property SelectedSignal: WideString dispid 2;
    function LoadUSML(const path: WideString): IDispatch; dispid 3;
    function LoadSignal(const path: WideString; type_: Integer): IDispatch; dispid 4;
    procedure SaveUSML(const Name: WideString; const FileName: WideString); dispid 5;
    procedure SaveSignal(const Name: WideString; const FileName: WideString; type_: Integer); dispid 6;
    function CreateSignal(type_: SYSINT): IDispatch; dispid 7;
    function CreateSignalXY(xtype: SYSINT; ytype: SYSINT): IDispatch; dispid 8;
    procedure Refresh; dispid 9;
    function Link(const path: WideString; const Name: WideString; const Object_: IDispatch): IDispatch; dispid 10;
    procedure Unlink(const Object_: IDispatch); dispid 11;
    function GetObject(const path: WideString): IDispatch; dispid 12;
    function GraphAPI: IDispatch; dispid 13;
    function GetNode(const Object_: IDispatch): IDispatch; dispid 14;
    procedure DebugPrint(arg: OleVariant); dispid 15;
    procedure DebugPrintLn(arg: OleVariant); dispid 16;
    procedure DoEvents; dispid 17;
    function VBSEditor: IDispatch; dispid 18;
    function FileOpen(isOPen: Integer; const ext: WideString; const fname: WideString; 
                      flags: Integer; const filter: WideString): WideString; dispid 19;
    function OpenFile(const path: WideString; flags: Integer): Integer; dispid 20;
    function ReadByte(hFile: Integer): OleVariant; dispid 21;
    function ReadWord(hFile: Integer): OleVariant; dispid 22;
    function ReadLong(hFile: Integer): OleVariant; dispid 23;
    function ReadFloat(hFile: Integer): OleVariant; dispid 24;
    function ReadDouble(hFile: Integer): OleVariant; dispid 25;
    procedure CloseFile(hFile: Integer); dispid 26;
    function SeekFile(hFile: Integer; Pos: Integer; flags: Integer): Integer; dispid 27;
    procedure WriteByte(hFile: Integer; Value: Smallint); dispid 28;
    procedure WriteWord(hFile: Integer; Value: Integer); dispid 29;
    procedure WriteLong(hFile: Integer; Value: Integer); dispid 30;
    procedure WriteFloat(hFile: Integer; Value: Single); dispid 31;
    procedure WriteDouble(hFile: Integer; Value: Double); dispid 32;
    function addmenuitem(const Name: WideString; id: Integer): Integer; dispid 33;
    function treeInterface: IDispatch; dispid 34;
    function MainWnd: Integer; dispid 35;
    procedure PrintPreview(const comment: WideString); dispid 36;
    procedure Print(const comment: WideString); dispid 37;
    function SaveImage(const fname: WideString; const comment: WideString): WordBool; dispid 38;
    procedure execVBS(const code: WideString); dispid 39;
    procedure ShowToolbar(bar: Integer; visible: Integer); dispid 40;
    function GetSelectedObject: IDispatch; dispid 41;
    function GetSelectedNode: IDispatch; dispid 42;
    function RegisterCommand: Integer; dispid 43;
    function CreatemenuItem(Command: Integer; reserved: Integer; const text: WideString; 
                            style: Integer; picture: Integer): Integer; dispid 44;
    function CreateToolbar: Integer; dispid 45;
    function CreatetoolbarButton(bar: Integer; Command: Integer; picture: Integer; 
                                 const hint: WideString): Integer; dispid 46;
    function FileDlg: IDispatch; dispid 47;
    function USMLDialog: WideString; dispid 48;
    procedure Test; dispid 49;
    procedure PrintPage(page: Integer; const comment: WideString; flags: Integer); dispid 50;
    function GetNodeStr(const path: WideString): IDispatch; dispid 51;
    function Get(const path: WideString): IDispatch; dispid 52;
    function GetObjectStr(const path: WideString): IDispatch; dispid 53;
    procedure UnlinkStr(const path: WideString); dispid 54;
    function GetSelectedItem: IDispatch; dispid 55;
    function GetChSignalDlg: IDispatch; dispid 56;
    function LinkISignal(const path: WideString; const Name: WideString; signal: Integer): IDispatch; dispid 57;
    function GetISignal(const Name: WideString): Integer; dispid 58;
    function IsNodeExist(const path: WideString): WordBool; dispid 59;
    procedure DeleteNode(const path: WideString); dispid 60;
    procedure AddTextInLog(const text: WideString; const exttext: WideString; show: WordBool); dispid 61;
    function GetInterval(const src: IDispatch; start: Integer; count: Integer): IDispatch; dispid 62;
  end;

// *********************************************************************//
// DispIntf:  IWPSignal
// Flags:     (4096) Dispatchable
// GUID:      {CA7B31AE-CD01-4EB8-9C40-F48F61297292}
// *********************************************************************//
  IWPSignal = dispinterface
    ['{CA7B31AE-CD01-4EB8-9C40-F48F61297292}']
    property size: Integer dispid 1;
    property DeltaX: Double dispid 2;
    property StartX: Double dispid 3;
    property SName: WideString dispid 4;
    property NameX: WideString dispid 5;
    property NameY: WideString dispid 6;
    property comment: WideString dispid 7;
    property Characteristic: Integer dispid 8;
    property MinX: Double dispid 9;
    property MaxX: Double dispid 10;
    property MinY: Double dispid 11;
    property MaxY: Double dispid 12;
    property k0: Double dispid 13;
    property k1: Double dispid 14;
    function Instance: Integer; dispid 15;
    function GetX(index: Integer): Double; dispid 16;
    function GetY(index: Integer): Double; dispid 17;
    procedure SetX(index: Integer; Value: Double); dispid 18;
    procedure SetY(index: Integer; Value: Double); dispid 19;
    function GetTransformerType: Integer; dispid 20;
    function GetType: Integer; dispid 21;
  end;

// *********************************************************************//
// DispIntf:  IWPUSML
// Flags:     (4096) Dispatchable
// GUID:      {87FA08E2-DA9C-4BDC-819F-3D70AACDFED6}
// *********************************************************************//
  IWPUSML = dispinterface
    ['{87FA08E2-DA9C-4BDC-819F-3D70AACDFED6}']
    property Name: WideString dispid 1;
    property Test: WideString dispid 2;
    property Date: WideString dispid 3;
    property type_: Smallint dispid 4;
    property SubType: Smallint dispid 5;
    property flags: Integer dispid 6;
    property ParamCount: Integer dispid 7;
    property FileName: WideString dispid 8;
    function Instance: Integer; dispid 9;
    function Parameter(index: Integer): IDispatch; dispid 10;
    procedure FileSave; dispid 11;
    procedure AddParameter(const signal: IDispatch); dispid 12;
    procedure DeleteParameter(index: Integer); dispid 13;
  end;

// *********************************************************************//
// DispIntf:  IWPNode
// Flags:     (4096) Dispatchable
// GUID:      {E5E07BCC-5AD9-4D0D-BA7C-2B1934E43CAB}
// *********************************************************************//
  IWPNode = dispinterface
    ['{E5E07BCC-5AD9-4D0D-BA7C-2B1934E43CAB}']
    property Name: WideString dispid 1;
    property ChildCount: Integer dispid 2;
    function Instance: Integer; dispid 3;
    function Reference: IDispatch; dispid 4;
    function Link(const Object_: IDispatch; const Name: WideString; flag: Integer): IDispatch; dispid 5;
    procedure Unlink(const objname: WideString); dispid 6;
    function IsChild(const testNode: IDispatch): Integer; dispid 7;
    function Child(const testNode: IDispatch): Integer; dispid 8;
    function Current: IDispatch; dispid 9;
    function Root: IDispatch; dispid 10;
    function IsValidNode: Integer; dispid 11;
    function AbsolutePath: WideString; dispid 12;
    function RelativePath(const baseNode: IDispatch): WideString; dispid 13;
    function IsDirectory: Integer; dispid 14;
    function GetNode(const path: WideString): IDispatch; dispid 15;
    function GetObject(const path: WideString): IDispatch; dispid 16;
    function At(index: Integer): IDispatch; dispid 17;
    function GetReferenceType: Integer; dispid 18;
  end;

// *********************************************************************//
// DispIntf:  IWPGraphs
// Flags:     (4096) Dispatchable
// GUID:      {6EC4A8B2-95A0-4F67-919A-F63A002EFC52}
// *********************************************************************//
  IWPGraphs = dispinterface
    ['{6EC4A8B2-95A0-4F67-919A-F63A002EFC52}']
    function Instance: Integer; dispid 1;
    function CreatePage: Integer; dispid 2;
    procedure DestroyPage(nPage: Integer); dispid 3;
    function CreateGraph(nPage: Integer): Integer; dispid 4;
    procedure DestroyGraph(nGraph: Integer); dispid 5;
    function CreateGraphic(hGR: Integer; hAx: Integer; hSig: Integer): Integer; dispid 6;
    function CreateLine(hGR: Integer; hAx: Integer; hSig: Integer): Integer; dispid 7;
    procedure DestroyLine(hLine: Integer); dispid 8;
    function PageCount(nPage: Integer): Integer; dispid 9;
    function GraphCount: Integer; dispid 10;
    function YaxisCount(hGR: Integer): Integer; dispid 11;
    function GetPageCount: Integer; dispid 12;
    function GetGraphCount(hGC: Integer): Integer; dispid 13;
    function GetYAxisCount(hGR: Integer): Integer; dispid 14;
    function GetLineCount(hGR: Integer): Integer; dispid 15;
    function GetPage(num: Integer): Integer; dispid 16;
    function GetGraph(hGC: Integer; nGraph: Integer): Integer; dispid 17;
    function GetYAxis(hGC: Integer; num: Integer): Integer; dispid 18;
    function GetLine(hGR: Integer; num: Integer): Integer; dispid 19;
    function GetSignal(hLine: Integer): IDispatch; dispid 20;
    function OpenUSML(const FileName: WideString): WideString; dispid 21;
    procedure GetPageRect(hGC: Integer; var left: Integer; var top: Integer; var right: Integer; 
                          var bottom: Integer); dispid 22;
    procedure SetPageRect(hGC: Integer; left: Integer; top: Integer; right: Integer; bottom: Integer); dispid 23;
    procedure SetPageDim(hGC: Integer; mode: Integer; width: Integer; height: Integer); dispid 24;
    procedure SetXMinMax(hGR: Integer; MinX: Double; MaxX: Double); dispid 25;
    procedure NormalizeGraph(hGR: Integer); dispid 26;
    function ActiveGraphPage: Integer; dispid 27;
    function ActiveGraph(hGC: Integer): Integer; dispid 28;
    procedure Folder2Graphs(const Node: IDispatch); dispid 29;
    procedure SetYAxisMinMax(Axis: Integer; MinX: Double; MaxX: Double); dispid 31;
    procedure invalidate(hGraph: Integer); dispid 32;
    procedure Folder2GraphsRecursive(const Node: IDispatch); dispid 30;
    procedure SetLineOpt(hLine: Integer; opt: Integer; mask: Integer; width: Integer; color: Integer); dispid 33;
  end;

// *********************************************************************//
// DispIntf:  IWPOperator
// Flags:     (4096) Dispatchable
// GUID:      {5819D3E4-58AC-4A0F-A24D-A6BCEFC41B56}
// *********************************************************************//
  IWPOperator = dispinterface
    ['{5819D3E4-58AC-4A0F-A24D-A6BCEFC41B56}']
    property Name: WideString dispid 1;
    property Fullname: WideString dispid 2;
    property nSrc: Integer dispid 3;
    property nDst: Integer dispid 4;
    function Info(kind: Integer): WideString; dispid 5;
    function Instance: Integer; dispid 6;
    function Error: Integer; dispid 7;
    function MsgError: WideString; dispid 8;
    function valid(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer; dispid 9;
    function Exec(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer; dispid 10;
    procedure setProperty(const Name: WideString; Value: OleVariant); dispid 11;
    function getProperty(const Name: WideString): OleVariant; dispid 12;
    function getProperySet: WideString; dispid 13;
    procedure loadProperties(const values: WideString); dispid 14;
    function SetupDlg: Integer; dispid 15;
    function getPropertyValues: WideString; dispid 16;
  end;

// *********************************************************************//
// DispIntf:  IWPOpManager
// Flags:     (4096) Dispatchable
// GUID:      {7102D9F6-913A-41DF-A60D-7B36DD28D150}
// *********************************************************************//
  IWPOpManager = dispinterface
    ['{7102D9F6-913A-41DF-A60D-7B36DD28D150}']
    property count: Integer dispid 1;
    function Get(index: Integer): IDispatch; dispid 2;
    function Instance: Integer; dispid 3;
  end;

// *********************************************************************//
// DispIntf:  IWPTree
// Flags:     (4096) Dispatchable
// GUID:      {9FAE7440-650A-4A71-9D1E-CC96ABAB7A99}
// *********************************************************************//
  IWPTree = dispinterface
    ['{9FAE7440-650A-4A71-9D1E-CC96ABAB7A99}']
    procedure Refresh; dispid 1;
    function Instance: Integer; dispid 2;
    function GetNode(const path: WideString): Integer; dispid 3;
    function Get(const path: WideString): IDispatch; dispid 4;
    function GetObject(const path: WideString): IDispatch; dispid 5;
    procedure Unlink(const path: WideString); dispid 6;
    function Link(const path: WideString; const Name: WideString; const obj: IDispatch): IDispatch; dispid 7;
    function GetSelectedItem: IDispatch; dispid 8;
  end;

// *********************************************************************//
// DispIntf:  IWPObject
// Flags:     (4096) Dispatchable
// GUID:      {68965773-29D7-4EF8-A835-0C94BFDEF186}
// *********************************************************************//
  IWPObject = dispinterface
    ['{68965773-29D7-4EF8-A835-0C94BFDEF186}']
    function Instance: Integer; dispid 1;
  end;

// *********************************************************************//
// DispIntf:  IWPPlugin
// Flags:     (4096) Dispatchable
// GUID:      {51A85FC7-DAF3-497B-8899-7D0326D072BC}
// *********************************************************************//
  IWPPlugin = dispinterface
    ['{51A85FC7-DAF3-497B-8899-7D0326D072BC}']
  end;

// *********************************************************************//
// DispIntf:  IFileDialog
// Flags:     (4096) Dispatchable
// GUID:      {BB5E9128-BD80-4AA8-A77A-8D6C87B2F911}
// *********************************************************************//
  IFileDialog = dispinterface
    ['{BB5E9128-BD80-4AA8-A77A-8D6C87B2F911}']
    property FileCount: Integer dispid 1;
    function GetFile(index: Integer): WideString; dispid 2;
    procedure Create(isOPen: Integer; const FileName: WideString; const defaultExt: WideString; 
                     const filter: WideString; Options: Integer); dispid 3;
    function DoModal: Integer; dispid 4;
  end;

// *********************************************************************//
// DispIntf:  IWPDlgChSignal
// Flags:     (4096) Dispatchable
// GUID:      {B3948801-B7AD-11D7-84B0-00C0262B9C1C}
// *********************************************************************//
  IWPDlgChSignal = dispinterface
    ['{B3948801-B7AD-11D7-84B0-00C0262B9C1C}']
  end;

// *********************************************************************//
// The Class CoWinPOS provides a Create and CreateRemote method to          
// create instances of the default interface IWinPOS exposed by              
// the CoClass WinPOS. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWinPOS = class
    class function Create: IWinPOS;
    class function CreateRemote(const MachineName: string): IWinPOS;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWinPOS
// Help String      : 
// Default Interface: IWinPOS
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWinPOSProperties= class;
{$ENDIF}
  TWinPOS = class(TOleServer)
  private
    FIntf:        IWinPOS;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWinPOSProperties;
    function      GetServerProperties: TWinPOSProperties;
{$ENDIF}
    function      GetDefaultInterface: IWinPOS;
  protected
    procedure InitServerData; override;
    function Get_SelectedGraph: WideString;
    procedure Set_SelectedGraph(const Value: WideString);
    function Get_SelectedSignal: WideString;
    procedure Set_SelectedSignal(const Value: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWinPOS);
    procedure Disconnect; override;
    function LoadUSML(const path: WideString): IDispatch;
    function LoadSignal(const path: WideString; type_: Integer): IDispatch;
    procedure SaveUSML(const Name: WideString; const FileName: WideString);
    procedure SaveSignal(const Name: WideString; const FileName: WideString; type_: Integer);
    function CreateSignal(type_: SYSINT): IDispatch;
    function CreateSignalXY(xtype: SYSINT; ytype: SYSINT): IDispatch;
    procedure Refresh;
    function Link(const path: WideString; const Name: WideString; const Object_: IDispatch): IDispatch;
    procedure Unlink(const Object_: IDispatch);
    function GetObject(const path: WideString): IDispatch;
    function GraphAPI: IDispatch;
    function GetNode(const Object_: IDispatch): IDispatch;
    procedure DebugPrint(arg: OleVariant);
    procedure DebugPrintLn(arg: OleVariant);
    procedure DoEvents;
    function VBSEditor: IDispatch;
    function FileOpen(isOPen: Integer; const ext: WideString; const fname: WideString; 
                      flags: Integer; const filter: WideString): WideString;
    function OpenFile(const path: WideString; flags: Integer): Integer;
    function ReadByte(hFile: Integer): OleVariant;
    function ReadWord(hFile: Integer): OleVariant;
    function ReadLong(hFile: Integer): OleVariant;
    function ReadFloat(hFile: Integer): OleVariant;
    function ReadDouble(hFile: Integer): OleVariant;
    procedure CloseFile(hFile: Integer);
    function SeekFile(hFile: Integer; Pos: Integer; flags: Integer): Integer;
    procedure WriteByte(hFile: Integer; Value: Smallint);
    procedure WriteWord(hFile: Integer; Value: Integer);
    procedure WriteLong(hFile: Integer; Value: Integer);
    procedure WriteFloat(hFile: Integer; Value: Single);
    procedure WriteDouble(hFile: Integer; Value: Double);
    function addmenuitem(const Name: WideString; id: Integer): Integer;
    function treeInterface: IDispatch;
    function MainWnd: Integer;
    procedure PrintPreview(const comment: WideString);
    procedure Print(const comment: WideString);
    function SaveImage(const fname: WideString; const comment: WideString): WordBool;
    procedure execVBS(const code: WideString);
    procedure ShowToolbar(bar: Integer; visible: Integer);
    function GetSelectedObject: IDispatch;
    function GetSelectedNode: IDispatch;
    function RegisterCommand: Integer;
    function CreatemenuItem(Command: Integer; reserved: Integer; const text: WideString; 
                            style: Integer; picture: Integer): Integer;
    function CreateToolbar: Integer;
    function CreatetoolbarButton(bar: Integer; Command: Integer; picture: Integer; 
                                 const hint: WideString): Integer;
    function FileDlg: IDispatch;
    function USMLDialog: WideString;
    procedure Test;
    procedure PrintPage(page: Integer; const comment: WideString; flags: Integer);
    function GetNodeStr(const path: WideString): IDispatch;
    function Get(const path: WideString): IDispatch;
    function GetObjectStr(const path: WideString): IDispatch;
    procedure UnlinkStr(const path: WideString);
    function GetSelectedItem: IDispatch;
    function GetChSignalDlg: IDispatch;
    function LinkISignal(const path: WideString; const Name: WideString; signal: Integer): IDispatch;
    function GetISignal(const Name: WideString): Integer;
    function IsNodeExist(const path: WideString): WordBool;
    procedure DeleteNode(const path: WideString);
    procedure AddTextInLog(const text: WideString; const exttext: WideString; show: WordBool);
    function GetInterval(const src: IDispatch; start: Integer; count: Integer): IDispatch;
    property DefaultInterface: IWinPOS read GetDefaultInterface;
    property SelectedGraph: WideString read Get_SelectedGraph write Set_SelectedGraph;
    property SelectedSignal: WideString read Get_SelectedSignal write Set_SelectedSignal;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWinPOSProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWinPOS
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWinPOSProperties = class(TPersistent)
  private
    FServer:    TWinPOS;
    function    GetDefaultInterface: IWinPOS;
    constructor Create(AServer: TWinPOS);
  protected
    function Get_SelectedGraph: WideString;
    procedure Set_SelectedGraph(const Value: WideString);
    function Get_SelectedSignal: WideString;
    procedure Set_SelectedSignal(const Value: WideString);
  public
    property DefaultInterface: IWinPOS read GetDefaultInterface;
  published
    property SelectedGraph: WideString read Get_SelectedGraph write Set_SelectedGraph;
    property SelectedSignal: WideString read Get_SelectedSignal write Set_SelectedSignal;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPSignal provides a Create and CreateRemote method to          
// create instances of the default interface IWPSignal exposed by              
// the CoClass WPSignal. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPSignal = class
    class function Create: IWPSignal;
    class function CreateRemote(const MachineName: string): IWPSignal;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPSignal
// Help String      : 
// Default Interface: IWPSignal
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPSignalProperties= class;
{$ENDIF}
  TWPSignal = class(TOleServer)
  private
    FIntf:        IWPSignal;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPSignalProperties;
    function      GetServerProperties: TWPSignalProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPSignal;
  protected
    procedure InitServerData; override;
    function Get_size: Integer;
    procedure Set_size(Value: Integer);
    function Get_DeltaX: Double;
    procedure Set_DeltaX(Value: Double);
    function Get_StartX: Double;
    procedure Set_StartX(Value: Double);
    function Get_SName: WideString;
    procedure Set_SName(const Value: WideString);
    function Get_NameX: WideString;
    procedure Set_NameX(const Value: WideString);
    function Get_NameY: WideString;
    procedure Set_NameY(const Value: WideString);
    function Get_comment: WideString;
    procedure Set_comment(const Value: WideString);
    function Get_Characteristic: Integer;
    procedure Set_Characteristic(Value: Integer);
    function Get_MinX: Double;
    procedure Set_MinX(Value: Double);
    function Get_MaxX: Double;
    procedure Set_MaxX(Value: Double);
    function Get_MinY: Double;
    procedure Set_MinY(Value: Double);
    function Get_MaxY: Double;
    procedure Set_MaxY(Value: Double);
    function Get_k0: Double;
    procedure Set_k0(Value: Double);
    function Get_k1: Double;
    procedure Set_k1(Value: Double);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPSignal);
    procedure Disconnect; override;
    function Instance: Integer;
    function GetX(index: Integer): Double;
    function GetY(index: Integer): Double;
    procedure SetX(index: Integer; Value: Double);
    procedure SetY(index: Integer; Value: Double);
    function GetTransformerType: Integer;
    function GetType: Integer;
    property DefaultInterface: IWPSignal read GetDefaultInterface;
    property size: Integer read Get_size write Set_size;
    property DeltaX: Double read Get_DeltaX write Set_DeltaX;
    property StartX: Double read Get_StartX write Set_StartX;
    property SName: WideString read Get_SName write Set_SName;
    property NameX: WideString read Get_NameX write Set_NameX;
    property NameY: WideString read Get_NameY write Set_NameY;
    property comment: WideString read Get_comment write Set_comment;
    property Characteristic: Integer read Get_Characteristic write Set_Characteristic;
    property MinX: Double read Get_MinX write Set_MinX;
    property MaxX: Double read Get_MaxX write Set_MaxX;
    property MinY: Double read Get_MinY write Set_MinY;
    property MaxY: Double read Get_MaxY write Set_MaxY;
    property k0: Double read Get_k0 write Set_k0;
    property k1: Double read Get_k1 write Set_k1;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPSignalProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPSignal
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPSignalProperties = class(TPersistent)
  private
    FServer:    TWPSignal;
    function    GetDefaultInterface: IWPSignal;
    constructor Create(AServer: TWPSignal);
  protected
    function Get_size: Integer;
    procedure Set_size(Value: Integer);
    function Get_DeltaX: Double;
    procedure Set_DeltaX(Value: Double);
    function Get_StartX: Double;
    procedure Set_StartX(Value: Double);
    function Get_SName: WideString;
    procedure Set_SName(const Value: WideString);
    function Get_NameX: WideString;
    procedure Set_NameX(const Value: WideString);
    function Get_NameY: WideString;
    procedure Set_NameY(const Value: WideString);
    function Get_comment: WideString;
    procedure Set_comment(const Value: WideString);
    function Get_Characteristic: Integer;
    procedure Set_Characteristic(Value: Integer);
    function Get_MinX: Double;
    procedure Set_MinX(Value: Double);
    function Get_MaxX: Double;
    procedure Set_MaxX(Value: Double);
    function Get_MinY: Double;
    procedure Set_MinY(Value: Double);
    function Get_MaxY: Double;
    procedure Set_MaxY(Value: Double);
    function Get_k0: Double;
    procedure Set_k0(Value: Double);
    function Get_k1: Double;
    procedure Set_k1(Value: Double);
  public
    property DefaultInterface: IWPSignal read GetDefaultInterface;
  published
    property size: Integer read Get_size write Set_size;
    property DeltaX: Double read Get_DeltaX write Set_DeltaX;
    property StartX: Double read Get_StartX write Set_StartX;
    property SName: WideString read Get_SName write Set_SName;
    property NameX: WideString read Get_NameX write Set_NameX;
    property NameY: WideString read Get_NameY write Set_NameY;
    property comment: WideString read Get_comment write Set_comment;
    property Characteristic: Integer read Get_Characteristic write Set_Characteristic;
    property MinX: Double read Get_MinX write Set_MinX;
    property MaxX: Double read Get_MaxX write Set_MaxX;
    property MinY: Double read Get_MinY write Set_MinY;
    property MaxY: Double read Get_MaxY write Set_MaxY;
    property k0: Double read Get_k0 write Set_k0;
    property k1: Double read Get_k1 write Set_k1;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPUSML provides a Create and CreateRemote method to          
// create instances of the default interface IWPUSML exposed by              
// the CoClass WPUSML. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPUSML = class
    class function Create: IWPUSML;
    class function CreateRemote(const MachineName: string): IWPUSML;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPUSML
// Help String      : 
// Default Interface: IWPUSML
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPUSMLProperties= class;
{$ENDIF}
  TWPUSML = class(TOleServer)
  private
    FIntf:        IWPUSML;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPUSMLProperties;
    function      GetServerProperties: TWPUSMLProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPUSML;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_Test: WideString;
    procedure Set_Test(const Value: WideString);
    function Get_Date: WideString;
    procedure Set_Date(const Value: WideString);
    function Get_type_: Smallint;
    procedure Set_type_(Value: Smallint);
    function Get_SubType: Smallint;
    procedure Set_SubType(Value: Smallint);
    function Get_flags: Integer;
    procedure Set_flags(Value: Integer);
    function Get_ParamCount: Integer;
    procedure Set_ParamCount(Value: Integer);
    function Get_FileName: WideString;
    procedure Set_FileName(const Value: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPUSML);
    procedure Disconnect; override;
    function Instance: Integer;
    function Parameter(index: Integer): IDispatch;
    procedure FileSave;
    procedure AddParameter(const signal: IDispatch);
    procedure DeleteParameter(index: Integer);
    property DefaultInterface: IWPUSML read GetDefaultInterface;
    property Name: WideString read Get_Name write Set_Name;
    property Test: WideString read Get_Test write Set_Test;
    property Date: WideString read Get_Date write Set_Date;
    property type_: Smallint read Get_type_ write Set_type_;
    property SubType: Smallint read Get_SubType write Set_SubType;
    property flags: Integer read Get_flags write Set_flags;
    property ParamCount: Integer read Get_ParamCount write Set_ParamCount;
    property FileName: WideString read Get_FileName write Set_FileName;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPUSMLProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPUSML
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPUSMLProperties = class(TPersistent)
  private
    FServer:    TWPUSML;
    function    GetDefaultInterface: IWPUSML;
    constructor Create(AServer: TWPUSML);
  protected
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_Test: WideString;
    procedure Set_Test(const Value: WideString);
    function Get_Date: WideString;
    procedure Set_Date(const Value: WideString);
    function Get_type_: Smallint;
    procedure Set_type_(Value: Smallint);
    function Get_SubType: Smallint;
    procedure Set_SubType(Value: Smallint);
    function Get_flags: Integer;
    procedure Set_flags(Value: Integer);
    function Get_ParamCount: Integer;
    procedure Set_ParamCount(Value: Integer);
    function Get_FileName: WideString;
    procedure Set_FileName(const Value: WideString);
  public
    property DefaultInterface: IWPUSML read GetDefaultInterface;
  published
    property Name: WideString read Get_Name write Set_Name;
    property Test: WideString read Get_Test write Set_Test;
    property Date: WideString read Get_Date write Set_Date;
    property type_: Smallint read Get_type_ write Set_type_;
    property SubType: Smallint read Get_SubType write Set_SubType;
    property flags: Integer read Get_flags write Set_flags;
    property ParamCount: Integer read Get_ParamCount write Set_ParamCount;
    property FileName: WideString read Get_FileName write Set_FileName;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPNode provides a Create and CreateRemote method to          
// create instances of the default interface IWPNode exposed by              
// the CoClass WPNode. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPNode = class
    class function Create: IWPNode;
    class function CreateRemote(const MachineName: string): IWPNode;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPNode
// Help String      : 
// Default Interface: IWPNode
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPNodeProperties= class;
{$ENDIF}
  TWPNode = class(TOleServer)
  private
    FIntf:        IWPNode;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPNodeProperties;
    function      GetServerProperties: TWPNodeProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPNode;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_ChildCount: Integer;
    procedure Set_ChildCount(Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPNode);
    procedure Disconnect; override;
    function Instance: Integer;
    function Reference: IDispatch;
    function Link(const Object_: IDispatch; const Name: WideString; flag: Integer): IDispatch;
    procedure Unlink(const objname: WideString);
    function IsChild(const testNode: IDispatch): Integer;
    function Child(const testNode: IDispatch): Integer;
    function Current: IDispatch;
    function Root: IDispatch;
    function IsValidNode: Integer;
    function AbsolutePath: WideString;
    function RelativePath(const baseNode: IDispatch): WideString;
    function IsDirectory: Integer;
    function GetNode(const path: WideString): IDispatch;
    function GetObject(const path: WideString): IDispatch;
    function At(index: Integer): IDispatch;
    function GetReferenceType: Integer;
    property DefaultInterface: IWPNode read GetDefaultInterface;
    property Name: WideString read Get_Name write Set_Name;
    property ChildCount: Integer read Get_ChildCount write Set_ChildCount;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPNodeProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPNode
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPNodeProperties = class(TPersistent)
  private
    FServer:    TWPNode;
    function    GetDefaultInterface: IWPNode;
    constructor Create(AServer: TWPNode);
  protected
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_ChildCount: Integer;
    procedure Set_ChildCount(Value: Integer);
  public
    property DefaultInterface: IWPNode read GetDefaultInterface;
  published
    property Name: WideString read Get_Name write Set_Name;
    property ChildCount: Integer read Get_ChildCount write Set_ChildCount;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPGraphs provides a Create and CreateRemote method to          
// create instances of the default interface IWPGraphs exposed by              
// the CoClass WPGraphs. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPGraphs = class
    class function Create: IWPGraphs;
    class function CreateRemote(const MachineName: string): IWPGraphs;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPGraphs
// Help String      : 
// Default Interface: IWPGraphs
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPGraphsProperties= class;
{$ENDIF}
  TWPGraphs = class(TOleServer)
  private
    FIntf:        IWPGraphs;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPGraphsProperties;
    function      GetServerProperties: TWPGraphsProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPGraphs;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPGraphs);
    procedure Disconnect; override;
    function Instance: Integer;
    function CreatePage: Integer;
    procedure DestroyPage(nPage: Integer);
    function CreateGraph(nPage: Integer): Integer;
    procedure DestroyGraph(nGraph: Integer);
    function CreateGraphic(hGR: Integer; hAx: Integer; hSig: Integer): Integer;
    function CreateLine(hGR: Integer; hAx: Integer; hSig: Integer): Integer;
    procedure DestroyLine(hLine: Integer);
    function PageCount(nPage: Integer): Integer;
    function GraphCount: Integer;
    function YaxisCount(hGR: Integer): Integer;
    function GetPageCount: Integer;
    function GetGraphCount(hGC: Integer): Integer;
    function GetYAxisCount(hGR: Integer): Integer;
    function GetLineCount(hGR: Integer): Integer;
    function GetPage(num: Integer): Integer;
    function GetGraph(hGC: Integer; nGraph: Integer): Integer;
    function GetYAxis(hGC: Integer; num: Integer): Integer;
    function GetLine(hGR: Integer; num: Integer): Integer;
    function GetSignal(hLine: Integer): IDispatch;
    function OpenUSML(const FileName: WideString): WideString;
    procedure GetPageRect(hGC: Integer; var left: Integer; var top: Integer; var right: Integer; 
                          var bottom: Integer);
    procedure SetPageRect(hGC: Integer; left: Integer; top: Integer; right: Integer; bottom: Integer);
    procedure SetPageDim(hGC: Integer; mode: Integer; width: Integer; height: Integer);
    procedure SetXMinMax(hGR: Integer; MinX: Double; MaxX: Double);
    procedure NormalizeGraph(hGR: Integer);
    function ActiveGraphPage: Integer;
    function ActiveGraph(hGC: Integer): Integer;
    procedure Folder2Graphs(const Node: IDispatch);
    procedure SetYAxisMinMax(Axis: Integer; MinX: Double; MaxX: Double);
    procedure invalidate(hGraph: Integer);
    procedure Folder2GraphsRecursive(const Node: IDispatch);
    procedure SetLineOpt(hLine: Integer; opt: Integer; mask: Integer; width: Integer; color: Integer);
    property DefaultInterface: IWPGraphs read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPGraphsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPGraphs
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPGraphsProperties = class(TPersistent)
  private
    FServer:    TWPGraphs;
    function    GetDefaultInterface: IWPGraphs;
    constructor Create(AServer: TWPGraphs);
  protected
  public
    property DefaultInterface: IWPGraphs read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPOperator provides a Create and CreateRemote method to          
// create instances of the default interface IWPOperator exposed by              
// the CoClass WPOperator. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPOperator = class
    class function Create: IWPOperator;
    class function CreateRemote(const MachineName: string): IWPOperator;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPOperator
// Help String      : 
// Default Interface: IWPOperator
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPOperatorProperties= class;
{$ENDIF}
  TWPOperator = class(TOleServer)
  private
    FIntf:        IWPOperator;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPOperatorProperties;
    function      GetServerProperties: TWPOperatorProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPOperator;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_Fullname: WideString;
    procedure Set_Fullname(const Value: WideString);
    function Get_nSrc: Integer;
    procedure Set_nSrc(Value: Integer);
    function Get_nDst: Integer;
    procedure Set_nDst(Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPOperator);
    procedure Disconnect; override;
    function Info(kind: Integer): WideString;
    function Instance: Integer;
    function Error: Integer;
    function MsgError: WideString;
    function valid(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer;
    function Exec(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer;
    procedure setProperty(const Name: WideString; Value: OleVariant);
    function getProperty(const Name: WideString): OleVariant;
    function getProperySet: WideString;
    procedure loadProperties(const values: WideString);
    function SetupDlg: Integer;
    function getPropertyValues: WideString;
    property DefaultInterface: IWPOperator read GetDefaultInterface;
    property Name: WideString read Get_Name write Set_Name;
    property Fullname: WideString read Get_Fullname write Set_Fullname;
    property nSrc: Integer read Get_nSrc write Set_nSrc;
    property nDst: Integer read Get_nDst write Set_nDst;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPOperatorProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPOperator
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPOperatorProperties = class(TPersistent)
  private
    FServer:    TWPOperator;
    function    GetDefaultInterface: IWPOperator;
    constructor Create(AServer: TWPOperator);
  protected
    function Get_Name: WideString;
    procedure Set_Name(const Value: WideString);
    function Get_Fullname: WideString;
    procedure Set_Fullname(const Value: WideString);
    function Get_nSrc: Integer;
    procedure Set_nSrc(Value: Integer);
    function Get_nDst: Integer;
    procedure Set_nDst(Value: Integer);
  public
    property DefaultInterface: IWPOperator read GetDefaultInterface;
  published
    property Name: WideString read Get_Name write Set_Name;
    property Fullname: WideString read Get_Fullname write Set_Fullname;
    property nSrc: Integer read Get_nSrc write Set_nSrc;
    property nDst: Integer read Get_nDst write Set_nDst;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPOpManager provides a Create and CreateRemote method to          
// create instances of the default interface IWPOpManager exposed by              
// the CoClass WPOpManager. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPOpManager = class
    class function Create: IWPOpManager;
    class function CreateRemote(const MachineName: string): IWPOpManager;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPOpManager
// Help String      : 
// Default Interface: IWPOpManager
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPOpManagerProperties= class;
{$ENDIF}
  TWPOpManager = class(TOleServer)
  private
    FIntf:        IWPOpManager;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPOpManagerProperties;
    function      GetServerProperties: TWPOpManagerProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPOpManager;
  protected
    procedure InitServerData; override;
    function Get_count: Integer;
    procedure Set_count(Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPOpManager);
    procedure Disconnect; override;
    function Get(index: Integer): IDispatch;
    function Instance: Integer;
    property DefaultInterface: IWPOpManager read GetDefaultInterface;
    property count: Integer read Get_count write Set_count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPOpManagerProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPOpManager
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPOpManagerProperties = class(TPersistent)
  private
    FServer:    TWPOpManager;
    function    GetDefaultInterface: IWPOpManager;
    constructor Create(AServer: TWPOpManager);
  protected
    function Get_count: Integer;
    procedure Set_count(Value: Integer);
  public
    property DefaultInterface: IWPOpManager read GetDefaultInterface;
  published
    property count: Integer read Get_count write Set_count;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPTree provides a Create and CreateRemote method to          
// create instances of the default interface IWPTree exposed by              
// the CoClass WPTree. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPTree = class
    class function Create: IWPTree;
    class function CreateRemote(const MachineName: string): IWPTree;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPTree
// Help String      : 
// Default Interface: IWPTree
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPTreeProperties= class;
{$ENDIF}
  TWPTree = class(TOleServer)
  private
    FIntf:        IWPTree;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPTreeProperties;
    function      GetServerProperties: TWPTreeProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPTree;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPTree);
    procedure Disconnect; override;
    procedure Refresh;
    function Instance: Integer;
    function GetNode(const path: WideString): Integer;
    function Get(const path: WideString): IDispatch;
    function GetObject(const path: WideString): IDispatch;
    procedure Unlink(const path: WideString);
    function Link(const path: WideString; const Name: WideString; const obj: IDispatch): IDispatch;
    function GetSelectedItem: IDispatch;
    property DefaultInterface: IWPTree read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPTreeProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPTree
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPTreeProperties = class(TPersistent)
  private
    FServer:    TWPTree;
    function    GetDefaultInterface: IWPTree;
    constructor Create(AServer: TWPTree);
  protected
  public
    property DefaultInterface: IWPTree read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPObject provides a Create and CreateRemote method to          
// create instances of the default interface IWPObject exposed by              
// the CoClass WPObject. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPObject = class
    class function Create: IWPObject;
    class function CreateRemote(const MachineName: string): IWPObject;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPObject
// Help String      : 
// Default Interface: IWPObject
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPObjectProperties= class;
{$ENDIF}
  TWPObject = class(TOleServer)
  private
    FIntf:        IWPObject;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPObjectProperties;
    function      GetServerProperties: TWPObjectProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPObject;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPObject);
    procedure Disconnect; override;
    function Instance: Integer;
    property DefaultInterface: IWPObject read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPObjectProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPObject
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPObjectProperties = class(TPersistent)
  private
    FServer:    TWPObject;
    function    GetDefaultInterface: IWPObject;
    constructor Create(AServer: TWPObject);
  protected
  public
    property DefaultInterface: IWPObject read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPPlugin provides a Create and CreateRemote method to          
// create instances of the default interface IWPPlugin exposed by              
// the CoClass WPPlugin. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPPlugin = class
    class function Create: IWPPlugin;
    class function CreateRemote(const MachineName: string): IWPPlugin;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPPlugin
// Help String      : 
// Default Interface: IWPPlugin
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPPluginProperties= class;
{$ENDIF}
  TWPPlugin = class(TOleServer)
  private
    FIntf:        IWPPlugin;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPPluginProperties;
    function      GetServerProperties: TWPPluginProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPPlugin;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPPlugin);
    procedure Disconnect; override;
    property DefaultInterface: IWPPlugin read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPPluginProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPPlugin
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPPluginProperties = class(TPersistent)
  private
    FServer:    TWPPlugin;
    function    GetDefaultInterface: IWPPlugin;
    constructor Create(AServer: TWPPlugin);
  protected
  public
    property DefaultInterface: IWPPlugin read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoCOleFileDialog provides a Create and CreateRemote method to          
// create instances of the default interface IFileDialog exposed by              
// the CoClass COleFileDialog. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCOleFileDialog = class
    class function Create: IFileDialog;
    class function CreateRemote(const MachineName: string): IFileDialog;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCOleFileDialog
// Help String      : 
// Default Interface: IFileDialog
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCOleFileDialogProperties= class;
{$ENDIF}
  TCOleFileDialog = class(TOleServer)
  private
    FIntf:        IFileDialog;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCOleFileDialogProperties;
    function      GetServerProperties: TCOleFileDialogProperties;
{$ENDIF}
    function      GetDefaultInterface: IFileDialog;
  protected
    procedure InitServerData; override;
    function Get_FileCount: Integer;
    procedure Set_FileCount(Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFileDialog);
    procedure Disconnect; override;
    function GetFile(index: Integer): WideString;
    procedure Create1(isOPen: Integer; const FileName: WideString; const defaultExt: WideString; 
                      const filter: WideString; Options: Integer);
    function DoModal: Integer;
    property DefaultInterface: IFileDialog read GetDefaultInterface;
    property FileCount: Integer read Get_FileCount write Set_FileCount;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCOleFileDialogProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCOleFileDialog
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCOleFileDialogProperties = class(TPersistent)
  private
    FServer:    TCOleFileDialog;
    function    GetDefaultInterface: IFileDialog;
    constructor Create(AServer: TCOleFileDialog);
  protected
    function Get_FileCount: Integer;
    procedure Set_FileCount(Value: Integer);
  public
    property DefaultInterface: IFileDialog read GetDefaultInterface;
  published
    property FileCount: Integer read Get_FileCount write Set_FileCount;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoWPDlgChSignal provides a Create and CreateRemote method to          
// create instances of the default interface IWPDlgChSignal exposed by              
// the CoClass WPDlgChSignal. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPDlgChSignal = class
    class function Create: IWPDlgChSignal;
    class function CreateRemote(const MachineName: string): IWPDlgChSignal;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWPDlgChSignal
// Help String      : 
// Default Interface: IWPDlgChSignal
// Def. Intf. DISP? : Yes
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWPDlgChSignalProperties= class;
{$ENDIF}
  TWPDlgChSignal = class(TOleServer)
  private
    FIntf:        IWPDlgChSignal;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWPDlgChSignalProperties;
    function      GetServerProperties: TWPDlgChSignalProperties;
{$ENDIF}
    function      GetDefaultInterface: IWPDlgChSignal;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWPDlgChSignal);
    procedure Disconnect; override;
    property DefaultInterface: IWPDlgChSignal read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWPDlgChSignalProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWPDlgChSignal
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWPDlgChSignalProperties = class(TPersistent)
  private
    FServer:    TWPDlgChSignal;
    function    GetDefaultInterface: IWPDlgChSignal;
    constructor Create(AServer: TWPDlgChSignal);
  protected
  public
    property DefaultInterface: IWPDlgChSignal read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

implementation

uses ComObj;

class function CoWinPOS.Create: IWinPOS;
begin
  Result := CreateComObject(CLASS_WinPOS) as IWinPOS;
end;

class function CoWinPOS.CreateRemote(const MachineName: string): IWinPOS;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WinPOS) as IWinPOS;
end;

procedure TWinPOS.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{C6DC36F2-D0D5-4AA7-8FF9-AB8BB80A0F73}';
    IntfIID:   '{69E69FFF-3501-404B-A1FF-536226245C1B}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWinPOS.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWinPOS;
  end;
end;

procedure TWinPOS.ConnectTo(svrIntf: IWinPOS);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWinPOS.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWinPOS.GetDefaultInterface: IWinPOS;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWinPOS.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWinPOSProperties.Create(Self);
{$ENDIF}
end;

destructor TWinPOS.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWinPOS.GetServerProperties: TWinPOSProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWinPOS.Get_SelectedGraph: WideString;
begin
  Result := DefaultInterface.SelectedGraph;
end;

procedure TWinPOS.Set_SelectedGraph(const Value: WideString);
begin
  DefaultInterface.SelectedGraph := Value;
end;

function TWinPOS.Get_SelectedSignal: WideString;
begin
  Result := DefaultInterface.SelectedSignal;
end;

procedure TWinPOS.Set_SelectedSignal(const Value: WideString);
begin
  DefaultInterface.SelectedSignal := Value;
end;

function TWinPOS.LoadUSML(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.LoadUSML(path);
end;

function TWinPOS.LoadSignal(const path: WideString; type_: Integer): IDispatch;
begin
  Result := DefaultInterface.LoadSignal(path, type_);
end;

procedure TWinPOS.SaveUSML(const Name: WideString; const FileName: WideString);
begin
  DefaultInterface.SaveUSML(Name, FileName);
end;

procedure TWinPOS.SaveSignal(const Name: WideString; const FileName: WideString; type_: Integer);
begin
  DefaultInterface.SaveSignal(Name, FileName, type_);
end;

function TWinPOS.CreateSignal(type_: SYSINT): IDispatch;
begin
  Result := DefaultInterface.CreateSignal(type_);
end;

function TWinPOS.CreateSignalXY(xtype: SYSINT; ytype: SYSINT): IDispatch;
begin
  Result := DefaultInterface.CreateSignalXY(xtype, ytype);
end;

procedure TWinPOS.Refresh;
begin
  DefaultInterface.Refresh;
end;

function TWinPOS.Link(const path: WideString; const Name: WideString; const Object_: IDispatch): IDispatch;
begin
  Result := DefaultInterface.Link(path, Name, Object_);
end;

procedure TWinPOS.Unlink(const Object_: IDispatch);
begin
  DefaultInterface.Unlink(Object_);
end;

function TWinPOS.GetObject(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.GetObject(path);
end;

function TWinPOS.GraphAPI: IDispatch;
begin
  Result := DefaultInterface.GraphAPI;
end;

function TWinPOS.GetNode(const Object_: IDispatch): IDispatch;
begin
  Result := DefaultInterface.GetNode(Object_);
end;

procedure TWinPOS.DebugPrint(arg: OleVariant);
begin
  DefaultInterface.DebugPrint(arg);
end;

procedure TWinPOS.DebugPrintLn(arg: OleVariant);
begin
  DefaultInterface.DebugPrintLn(arg);
end;

procedure TWinPOS.DoEvents;
begin
  DefaultInterface.DoEvents;
end;

function TWinPOS.VBSEditor: IDispatch;
begin
  Result := DefaultInterface.VBSEditor;
end;

function TWinPOS.FileOpen(isOPen: Integer; const ext: WideString; const fname: WideString; 
                          flags: Integer; const filter: WideString): WideString;
begin
  Result := DefaultInterface.FileOpen(isOPen, ext, fname, flags, filter);
end;

function TWinPOS.OpenFile(const path: WideString; flags: Integer): Integer;
begin
  Result := DefaultInterface.OpenFile(path, flags);
end;

function TWinPOS.ReadByte(hFile: Integer): OleVariant;
begin
  Result := DefaultInterface.ReadByte(hFile);
end;

function TWinPOS.ReadWord(hFile: Integer): OleVariant;
begin
  Result := DefaultInterface.ReadWord(hFile);
end;

function TWinPOS.ReadLong(hFile: Integer): OleVariant;
begin
  Result := DefaultInterface.ReadLong(hFile);
end;

function TWinPOS.ReadFloat(hFile: Integer): OleVariant;
begin
  Result := DefaultInterface.ReadFloat(hFile);
end;

function TWinPOS.ReadDouble(hFile: Integer): OleVariant;
begin
  Result := DefaultInterface.ReadDouble(hFile);
end;

procedure TWinPOS.CloseFile(hFile: Integer);
begin
  DefaultInterface.CloseFile(hFile);
end;

function TWinPOS.SeekFile(hFile: Integer; Pos: Integer; flags: Integer): Integer;
begin
  Result := DefaultInterface.SeekFile(hFile, Pos, flags);
end;

procedure TWinPOS.WriteByte(hFile: Integer; Value: Smallint);
begin
  DefaultInterface.WriteByte(hFile, Value);
end;

procedure TWinPOS.WriteWord(hFile: Integer; Value: Integer);
begin
  DefaultInterface.WriteWord(hFile, Value);
end;

procedure TWinPOS.WriteLong(hFile: Integer; Value: Integer);
begin
  DefaultInterface.WriteLong(hFile, Value);
end;

procedure TWinPOS.WriteFloat(hFile: Integer; Value: Single);
begin
  DefaultInterface.WriteFloat(hFile, Value);
end;

procedure TWinPOS.WriteDouble(hFile: Integer; Value: Double);
begin
  DefaultInterface.WriteDouble(hFile, Value);
end;

function TWinPOS.addmenuitem(const Name: WideString; id: Integer): Integer;
begin
  Result := DefaultInterface.addmenuitem(Name, id);
end;

function TWinPOS.treeInterface: IDispatch;
begin
  Result := DefaultInterface.treeInterface;
end;

function TWinPOS.MainWnd: Integer;
begin
  Result := DefaultInterface.MainWnd;
end;

procedure TWinPOS.PrintPreview(const comment: WideString);
begin
  DefaultInterface.PrintPreview(comment);
end;

procedure TWinPOS.Print(const comment: WideString);
begin
  DefaultInterface.Print(comment);
end;

function TWinPOS.SaveImage(const fname: WideString; const comment: WideString): WordBool;
begin
  Result := DefaultInterface.SaveImage(fname, comment);
end;

procedure TWinPOS.execVBS(const code: WideString);
begin
  DefaultInterface.execVBS(code);
end;

procedure TWinPOS.ShowToolbar(bar: Integer; visible: Integer);
begin
  DefaultInterface.ShowToolbar(bar, visible);
end;

function TWinPOS.GetSelectedObject: IDispatch;
begin
  Result := DefaultInterface.GetSelectedObject;
end;

function TWinPOS.GetSelectedNode: IDispatch;
begin
  Result := DefaultInterface.GetSelectedNode;
end;

function TWinPOS.RegisterCommand: Integer;
begin
  Result := DefaultInterface.RegisterCommand;
end;

function TWinPOS.CreatemenuItem(Command: Integer; reserved: Integer; const text: WideString; 
                                style: Integer; picture: Integer): Integer;
begin
  Result := DefaultInterface.CreatemenuItem(Command, reserved, text, style, picture);
end;

function TWinPOS.CreateToolbar: Integer;
begin
  Result := DefaultInterface.CreateToolbar;
end;

function TWinPOS.CreatetoolbarButton(bar: Integer; Command: Integer; picture: Integer; 
                                     const hint: WideString): Integer;
begin
  Result := DefaultInterface.CreatetoolbarButton(bar, Command, picture, hint);
end;

function TWinPOS.FileDlg: IDispatch;
begin
  Result := DefaultInterface.FileDlg;
end;

function TWinPOS.USMLDialog: WideString;
begin
  Result := DefaultInterface.USMLDialog;
end;

procedure TWinPOS.Test;
begin
  DefaultInterface.Test;
end;

procedure TWinPOS.PrintPage(page: Integer; const comment: WideString; flags: Integer);
begin
  DefaultInterface.PrintPage(page, comment, flags);
end;

function TWinPOS.GetNodeStr(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.GetNodeStr(path);
end;

function TWinPOS.Get(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.Get(path);
end;

function TWinPOS.GetObjectStr(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.GetObjectStr(path);
end;

procedure TWinPOS.UnlinkStr(const path: WideString);
begin
  DefaultInterface.UnlinkStr(path);
end;

function TWinPOS.GetSelectedItem: IDispatch;
begin
  Result := DefaultInterface.GetSelectedItem;
end;

function TWinPOS.GetChSignalDlg: IDispatch;
begin
  Result := DefaultInterface.GetChSignalDlg;
end;

function TWinPOS.LinkISignal(const path: WideString; const Name: WideString; signal: Integer): IDispatch;
begin
  Result := DefaultInterface.LinkISignal(path, Name, signal);
end;

function TWinPOS.GetISignal(const Name: WideString): Integer;
begin
  Result := DefaultInterface.GetISignal(Name);
end;

function TWinPOS.IsNodeExist(const path: WideString): WordBool;
begin
  Result := DefaultInterface.IsNodeExist(path);
end;

procedure TWinPOS.DeleteNode(const path: WideString);
begin
  DefaultInterface.DeleteNode(path);
end;

procedure TWinPOS.AddTextInLog(const text: WideString; const exttext: WideString; show: WordBool);
begin
  DefaultInterface.AddTextInLog(text, exttext, show);
end;

function TWinPOS.GetInterval(const src: IDispatch; start: Integer; count: Integer): IDispatch;
begin
  Result := DefaultInterface.GetInterval(src, start, count);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWinPOSProperties.Create(AServer: TWinPOS);
begin
  inherited Create;
  FServer := AServer;
end;

function TWinPOSProperties.GetDefaultInterface: IWinPOS;
begin
  Result := FServer.DefaultInterface;
end;

function TWinPOSProperties.Get_SelectedGraph: WideString;
begin
  Result := DefaultInterface.SelectedGraph;
end;

procedure TWinPOSProperties.Set_SelectedGraph(const Value: WideString);
begin
  DefaultInterface.SelectedGraph := Value;
end;

function TWinPOSProperties.Get_SelectedSignal: WideString;
begin
  Result := DefaultInterface.SelectedSignal;
end;

procedure TWinPOSProperties.Set_SelectedSignal(const Value: WideString);
begin
  DefaultInterface.SelectedSignal := Value;
end;

{$ENDIF}

class function CoWPSignal.Create: IWPSignal;
begin
  Result := CreateComObject(CLASS_WPSignal) as IWPSignal;
end;

class function CoWPSignal.CreateRemote(const MachineName: string): IWPSignal;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPSignal) as IWPSignal;
end;

procedure TWPSignal.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{DAA0ADA4-6E71-4993-B9D6-2A38D6420DFA}';
    IntfIID:   '{CA7B31AE-CD01-4EB8-9C40-F48F61297292}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPSignal.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPSignal;
  end;
end;

procedure TWPSignal.ConnectTo(svrIntf: IWPSignal);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPSignal.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPSignal.GetDefaultInterface: IWPSignal;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPSignal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPSignalProperties.Create(Self);
{$ENDIF}
end;

destructor TWPSignal.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPSignal.GetServerProperties: TWPSignalProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWPSignal.Get_size: Integer;
begin
  Result := DefaultInterface.size;
end;

procedure TWPSignal.Set_size(Value: Integer);
begin
  DefaultInterface.size := Value;
end;

function TWPSignal.Get_DeltaX: Double;
begin
  Result := DefaultInterface.DeltaX;
end;

procedure TWPSignal.Set_DeltaX(Value: Double);
begin
  DefaultInterface.DeltaX := Value;
end;

function TWPSignal.Get_StartX: Double;
begin
  Result := DefaultInterface.StartX;
end;

procedure TWPSignal.Set_StartX(Value: Double);
begin
  DefaultInterface.StartX := Value;
end;

function TWPSignal.Get_SName: WideString;
begin
  Result := DefaultInterface.SName;
end;

procedure TWPSignal.Set_SName(const Value: WideString);
begin
  DefaultInterface.SName := Value;
end;

function TWPSignal.Get_NameX: WideString;
begin
  Result := DefaultInterface.NameX;
end;

procedure TWPSignal.Set_NameX(const Value: WideString);
begin
  DefaultInterface.NameX := Value;
end;

function TWPSignal.Get_NameY: WideString;
begin
  Result := DefaultInterface.NameY;
end;

procedure TWPSignal.Set_NameY(const Value: WideString);
begin
  DefaultInterface.NameY := Value;
end;

function TWPSignal.Get_comment: WideString;
begin
  Result := DefaultInterface.comment;
end;

procedure TWPSignal.Set_comment(const Value: WideString);
begin
  DefaultInterface.comment := Value;
end;

function TWPSignal.Get_Characteristic: Integer;
begin
  Result := DefaultInterface.Characteristic;
end;

procedure TWPSignal.Set_Characteristic(Value: Integer);
begin
  DefaultInterface.Characteristic := Value;
end;

function TWPSignal.Get_MinX: Double;
begin
  Result := DefaultInterface.MinX;
end;

procedure TWPSignal.Set_MinX(Value: Double);
begin
  DefaultInterface.MinX := Value;
end;

function TWPSignal.Get_MaxX: Double;
begin
  Result := DefaultInterface.MaxX;
end;

procedure TWPSignal.Set_MaxX(Value: Double);
begin
  DefaultInterface.MaxX := Value;
end;

function TWPSignal.Get_MinY: Double;
begin
  Result := DefaultInterface.MinY;
end;

procedure TWPSignal.Set_MinY(Value: Double);
begin
  DefaultInterface.MinY := Value;
end;

function TWPSignal.Get_MaxY: Double;
begin
  Result := DefaultInterface.MaxY;
end;

procedure TWPSignal.Set_MaxY(Value: Double);
begin
  DefaultInterface.MaxY := Value;
end;

function TWPSignal.Get_k0: Double;
begin
  Result := DefaultInterface.k0;
end;

procedure TWPSignal.Set_k0(Value: Double);
begin
  DefaultInterface.k0 := Value;
end;

function TWPSignal.Get_k1: Double;
begin
  Result := DefaultInterface.k1;
end;

procedure TWPSignal.Set_k1(Value: Double);
begin
  DefaultInterface.k1 := Value;
end;

function TWPSignal.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

function TWPSignal.GetX(index: Integer): Double;
begin
  Result := DefaultInterface.GetX(index);
end;

function TWPSignal.GetY(index: Integer): Double;
begin
  Result := DefaultInterface.GetY(index);
end;

procedure TWPSignal.SetX(index: Integer; Value: Double);
begin
  DefaultInterface.SetX(index, Value);
end;

procedure TWPSignal.SetY(index: Integer; Value: Double);
begin
  DefaultInterface.SetY(index, Value);
end;

function TWPSignal.GetTransformerType: Integer;
begin
  Result := DefaultInterface.GetTransformerType;
end;

function TWPSignal.GetType: Integer;
begin
  Result := DefaultInterface.GetType;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPSignalProperties.Create(AServer: TWPSignal);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPSignalProperties.GetDefaultInterface: IWPSignal;
begin
  Result := FServer.DefaultInterface;
end;

function TWPSignalProperties.Get_size: Integer;
begin
  Result := DefaultInterface.size;
end;

procedure TWPSignalProperties.Set_size(Value: Integer);
begin
  DefaultInterface.size := Value;
end;

function TWPSignalProperties.Get_DeltaX: Double;
begin
  Result := DefaultInterface.DeltaX;
end;

procedure TWPSignalProperties.Set_DeltaX(Value: Double);
begin
  DefaultInterface.DeltaX := Value;
end;

function TWPSignalProperties.Get_StartX: Double;
begin
  Result := DefaultInterface.StartX;
end;

procedure TWPSignalProperties.Set_StartX(Value: Double);
begin
  DefaultInterface.StartX := Value;
end;

function TWPSignalProperties.Get_SName: WideString;
begin
  Result := DefaultInterface.SName;
end;

procedure TWPSignalProperties.Set_SName(const Value: WideString);
begin
  DefaultInterface.SName := Value;
end;

function TWPSignalProperties.Get_NameX: WideString;
begin
  Result := DefaultInterface.NameX;
end;

procedure TWPSignalProperties.Set_NameX(const Value: WideString);
begin
  DefaultInterface.NameX := Value;
end;

function TWPSignalProperties.Get_NameY: WideString;
begin
  Result := DefaultInterface.NameY;
end;

procedure TWPSignalProperties.Set_NameY(const Value: WideString);
begin
  DefaultInterface.NameY := Value;
end;

function TWPSignalProperties.Get_comment: WideString;
begin
  Result := DefaultInterface.comment;
end;

procedure TWPSignalProperties.Set_comment(const Value: WideString);
begin
  DefaultInterface.comment := Value;
end;

function TWPSignalProperties.Get_Characteristic: Integer;
begin
  Result := DefaultInterface.Characteristic;
end;

procedure TWPSignalProperties.Set_Characteristic(Value: Integer);
begin
  DefaultInterface.Characteristic := Value;
end;

function TWPSignalProperties.Get_MinX: Double;
begin
  Result := DefaultInterface.MinX;
end;

procedure TWPSignalProperties.Set_MinX(Value: Double);
begin
  DefaultInterface.MinX := Value;
end;

function TWPSignalProperties.Get_MaxX: Double;
begin
  Result := DefaultInterface.MaxX;
end;

procedure TWPSignalProperties.Set_MaxX(Value: Double);
begin
  DefaultInterface.MaxX := Value;
end;

function TWPSignalProperties.Get_MinY: Double;
begin
  Result := DefaultInterface.MinY;
end;

procedure TWPSignalProperties.Set_MinY(Value: Double);
begin
  DefaultInterface.MinY := Value;
end;

function TWPSignalProperties.Get_MaxY: Double;
begin
  Result := DefaultInterface.MaxY;
end;

procedure TWPSignalProperties.Set_MaxY(Value: Double);
begin
  DefaultInterface.MaxY := Value;
end;

function TWPSignalProperties.Get_k0: Double;
begin
  Result := DefaultInterface.k0;
end;

procedure TWPSignalProperties.Set_k0(Value: Double);
begin
  DefaultInterface.k0 := Value;
end;

function TWPSignalProperties.Get_k1: Double;
begin
  Result := DefaultInterface.k1;
end;

procedure TWPSignalProperties.Set_k1(Value: Double);
begin
  DefaultInterface.k1 := Value;
end;

{$ENDIF}

class function CoWPUSML.Create: IWPUSML;
begin
  Result := CreateComObject(CLASS_WPUSML) as IWPUSML;
end;

class function CoWPUSML.CreateRemote(const MachineName: string): IWPUSML;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPUSML) as IWPUSML;
end;

procedure TWPUSML.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{B015674F-1563-482F-ADE4-A0496816874A}';
    IntfIID:   '{87FA08E2-DA9C-4BDC-819F-3D70AACDFED6}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPUSML.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPUSML;
  end;
end;

procedure TWPUSML.ConnectTo(svrIntf: IWPUSML);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPUSML.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPUSML.GetDefaultInterface: IWPUSML;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPUSML.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPUSMLProperties.Create(Self);
{$ENDIF}
end;

destructor TWPUSML.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPUSML.GetServerProperties: TWPUSMLProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWPUSML.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TWPUSML.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TWPUSML.Get_Test: WideString;
begin
  Result := DefaultInterface.Test;
end;

procedure TWPUSML.Set_Test(const Value: WideString);
begin
  DefaultInterface.Test := Value;
end;

function TWPUSML.Get_Date: WideString;
begin
  Result := DefaultInterface.Date;
end;

procedure TWPUSML.Set_Date(const Value: WideString);
begin
  DefaultInterface.Date := Value;
end;

function TWPUSML.Get_type_: Smallint;
begin
  Result := DefaultInterface.type_;
end;

procedure TWPUSML.Set_type_(Value: Smallint);
begin
  DefaultInterface.type_ := Value;
end;

function TWPUSML.Get_SubType: Smallint;
begin
  Result := DefaultInterface.SubType;
end;

procedure TWPUSML.Set_SubType(Value: Smallint);
begin
  DefaultInterface.SubType := Value;
end;

function TWPUSML.Get_flags: Integer;
begin
  Result := DefaultInterface.flags;
end;

procedure TWPUSML.Set_flags(Value: Integer);
begin
  DefaultInterface.flags := Value;
end;

function TWPUSML.Get_ParamCount: Integer;
begin
  Result := DefaultInterface.ParamCount;
end;

procedure TWPUSML.Set_ParamCount(Value: Integer);
begin
  DefaultInterface.ParamCount := Value;
end;

function TWPUSML.Get_FileName: WideString;
begin
  Result := DefaultInterface.FileName;
end;

procedure TWPUSML.Set_FileName(const Value: WideString);
begin
  DefaultInterface.FileName := Value;
end;

function TWPUSML.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

function TWPUSML.Parameter(index: Integer): IDispatch;
begin
  Result := DefaultInterface.Parameter(index);
end;

procedure TWPUSML.FileSave;
begin
  DefaultInterface.FileSave;
end;

procedure TWPUSML.AddParameter(const signal: IDispatch);
begin
  DefaultInterface.AddParameter(signal);
end;

procedure TWPUSML.DeleteParameter(index: Integer);
begin
  DefaultInterface.DeleteParameter(index);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPUSMLProperties.Create(AServer: TWPUSML);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPUSMLProperties.GetDefaultInterface: IWPUSML;
begin
  Result := FServer.DefaultInterface;
end;

function TWPUSMLProperties.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TWPUSMLProperties.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TWPUSMLProperties.Get_Test: WideString;
begin
  Result := DefaultInterface.Test;
end;

procedure TWPUSMLProperties.Set_Test(const Value: WideString);
begin
  DefaultInterface.Test := Value;
end;

function TWPUSMLProperties.Get_Date: WideString;
begin
  Result := DefaultInterface.Date;
end;

procedure TWPUSMLProperties.Set_Date(const Value: WideString);
begin
  DefaultInterface.Date := Value;
end;

function TWPUSMLProperties.Get_type_: Smallint;
begin
  Result := DefaultInterface.type_;
end;

procedure TWPUSMLProperties.Set_type_(Value: Smallint);
begin
  DefaultInterface.type_ := Value;
end;

function TWPUSMLProperties.Get_SubType: Smallint;
begin
  Result := DefaultInterface.SubType;
end;

procedure TWPUSMLProperties.Set_SubType(Value: Smallint);
begin
  DefaultInterface.SubType := Value;
end;

function TWPUSMLProperties.Get_flags: Integer;
begin
  Result := DefaultInterface.flags;
end;

procedure TWPUSMLProperties.Set_flags(Value: Integer);
begin
  DefaultInterface.flags := Value;
end;

function TWPUSMLProperties.Get_ParamCount: Integer;
begin
  Result := DefaultInterface.ParamCount;
end;

procedure TWPUSMLProperties.Set_ParamCount(Value: Integer);
begin
  DefaultInterface.ParamCount := Value;
end;

function TWPUSMLProperties.Get_FileName: WideString;
begin
  Result := DefaultInterface.FileName;
end;

procedure TWPUSMLProperties.Set_FileName(const Value: WideString);
begin
  DefaultInterface.FileName := Value;
end;

{$ENDIF}

class function CoWPNode.Create: IWPNode;
begin
  Result := CreateComObject(CLASS_WPNode) as IWPNode;
end;

class function CoWPNode.CreateRemote(const MachineName: string): IWPNode;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPNode) as IWPNode;
end;

procedure TWPNode.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{9F7DA507-EE2F-4385-9020-86B0FE776ACC}';
    IntfIID:   '{E5E07BCC-5AD9-4D0D-BA7C-2B1934E43CAB}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPNode.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPNode;
  end;
end;

procedure TWPNode.ConnectTo(svrIntf: IWPNode);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPNode.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPNode.GetDefaultInterface: IWPNode;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPNode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPNodeProperties.Create(Self);
{$ENDIF}
end;

destructor TWPNode.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPNode.GetServerProperties: TWPNodeProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWPNode.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TWPNode.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TWPNode.Get_ChildCount: Integer;
begin
  Result := DefaultInterface.ChildCount;
end;

procedure TWPNode.Set_ChildCount(Value: Integer);
begin
  DefaultInterface.ChildCount := Value;
end;

function TWPNode.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

function TWPNode.Reference: IDispatch;
begin
  Result := DefaultInterface.Reference;
end;

function TWPNode.Link(const Object_: IDispatch; const Name: WideString; flag: Integer): IDispatch;
begin
  Result := DefaultInterface.Link(Object_, Name, flag);
end;

procedure TWPNode.Unlink(const objname: WideString);
begin
  DefaultInterface.Unlink(objname);
end;

function TWPNode.IsChild(const testNode: IDispatch): Integer;
begin
  Result := DefaultInterface.IsChild(testNode);
end;

function TWPNode.Child(const testNode: IDispatch): Integer;
begin
  Result := DefaultInterface.Child(testNode);
end;

function TWPNode.Current: IDispatch;
begin
  Result := DefaultInterface.Current;
end;

function TWPNode.Root: IDispatch;
begin
  Result := DefaultInterface.Root;
end;

function TWPNode.IsValidNode: Integer;
begin
  Result := DefaultInterface.IsValidNode;
end;

function TWPNode.AbsolutePath: WideString;
begin
  Result := DefaultInterface.AbsolutePath;
end;

function TWPNode.RelativePath(const baseNode: IDispatch): WideString;
begin
  Result := DefaultInterface.RelativePath(baseNode);
end;

function TWPNode.IsDirectory: Integer;
begin
  Result := DefaultInterface.IsDirectory;
end;

function TWPNode.GetNode(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.GetNode(path);
end;

function TWPNode.GetObject(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.GetObject(path);
end;

function TWPNode.At(index: Integer): IDispatch;
begin
  Result := DefaultInterface.At(index);
end;

function TWPNode.GetReferenceType: Integer;
begin
  Result := DefaultInterface.GetReferenceType;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPNodeProperties.Create(AServer: TWPNode);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPNodeProperties.GetDefaultInterface: IWPNode;
begin
  Result := FServer.DefaultInterface;
end;

function TWPNodeProperties.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TWPNodeProperties.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TWPNodeProperties.Get_ChildCount: Integer;
begin
  Result := DefaultInterface.ChildCount;
end;

procedure TWPNodeProperties.Set_ChildCount(Value: Integer);
begin
  DefaultInterface.ChildCount := Value;
end;

{$ENDIF}

class function CoWPGraphs.Create: IWPGraphs;
begin
  Result := CreateComObject(CLASS_WPGraphs) as IWPGraphs;
end;

class function CoWPGraphs.CreateRemote(const MachineName: string): IWPGraphs;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPGraphs) as IWPGraphs;
end;

procedure TWPGraphs.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{71F8B83A-2D9D-4F18-8506-B7B6C932E968}';
    IntfIID:   '{6EC4A8B2-95A0-4F67-919A-F63A002EFC52}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPGraphs.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPGraphs;
  end;
end;

procedure TWPGraphs.ConnectTo(svrIntf: IWPGraphs);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPGraphs.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPGraphs.GetDefaultInterface: IWPGraphs;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPGraphs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPGraphsProperties.Create(Self);
{$ENDIF}
end;

destructor TWPGraphs.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPGraphs.GetServerProperties: TWPGraphsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWPGraphs.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

function TWPGraphs.CreatePage: Integer;
begin
  Result := DefaultInterface.CreatePage;
end;

procedure TWPGraphs.DestroyPage(nPage: Integer);
begin
  DefaultInterface.DestroyPage(nPage);
end;

function TWPGraphs.CreateGraph(nPage: Integer): Integer;
begin
  Result := DefaultInterface.CreateGraph(nPage);
end;

procedure TWPGraphs.DestroyGraph(nGraph: Integer);
begin
  DefaultInterface.DestroyGraph(nGraph);
end;

function TWPGraphs.CreateGraphic(hGR: Integer; hAx: Integer; hSig: Integer): Integer;
begin
  Result := DefaultInterface.CreateGraphic(hGR, hAx, hSig);
end;

function TWPGraphs.CreateLine(hGR: Integer; hAx: Integer; hSig: Integer): Integer;
begin
  Result := DefaultInterface.CreateLine(hGR, hAx, hSig);
end;

procedure TWPGraphs.DestroyLine(hLine: Integer);
begin
  DefaultInterface.DestroyLine(hLine);
end;

function TWPGraphs.PageCount(nPage: Integer): Integer;
begin
  Result := DefaultInterface.PageCount(nPage);
end;

function TWPGraphs.GraphCount: Integer;
begin
  Result := DefaultInterface.GraphCount;
end;

function TWPGraphs.YaxisCount(hGR: Integer): Integer;
begin
  Result := DefaultInterface.YaxisCount(hGR);
end;

function TWPGraphs.GetPageCount: Integer;
begin
  Result := DefaultInterface.GetPageCount;
end;

function TWPGraphs.GetGraphCount(hGC: Integer): Integer;
begin
  Result := DefaultInterface.GetGraphCount(hGC);
end;

function TWPGraphs.GetYAxisCount(hGR: Integer): Integer;
begin
  Result := DefaultInterface.GetYAxisCount(hGR);
end;

function TWPGraphs.GetLineCount(hGR: Integer): Integer;
begin
  Result := DefaultInterface.GetLineCount(hGR);
end;

function TWPGraphs.GetPage(num: Integer): Integer;
begin
  Result := DefaultInterface.GetPage(num);
end;

function TWPGraphs.GetGraph(hGC: Integer; nGraph: Integer): Integer;
begin
  Result := DefaultInterface.GetGraph(hGC, nGraph);
end;

function TWPGraphs.GetYAxis(hGC: Integer; num: Integer): Integer;
begin
  Result := DefaultInterface.GetYAxis(hGC, num);
end;

function TWPGraphs.GetLine(hGR: Integer; num: Integer): Integer;
begin
  Result := DefaultInterface.GetLine(hGR, num);
end;

function TWPGraphs.GetSignal(hLine: Integer): IDispatch;
begin
  Result := DefaultInterface.GetSignal(hLine);
end;

function TWPGraphs.OpenUSML(const FileName: WideString): WideString;
begin
  Result := DefaultInterface.OpenUSML(FileName);
end;

procedure TWPGraphs.GetPageRect(hGC: Integer; var left: Integer; var top: Integer; 
                                var right: Integer; var bottom: Integer);
begin
  DefaultInterface.GetPageRect(hGC, left, top, right, bottom);
end;

procedure TWPGraphs.SetPageRect(hGC: Integer; left: Integer; top: Integer; right: Integer; 
                                bottom: Integer);
begin
  DefaultInterface.SetPageRect(hGC, left, top, right, bottom);
end;

procedure TWPGraphs.SetPageDim(hGC: Integer; mode: Integer; width: Integer; height: Integer);
begin
  DefaultInterface.SetPageDim(hGC, mode, width, height);
end;

procedure TWPGraphs.SetXMinMax(hGR: Integer; MinX: Double; MaxX: Double);
begin
  DefaultInterface.SetXMinMax(hGR, MinX, MaxX);
end;

procedure TWPGraphs.NormalizeGraph(hGR: Integer);
begin
  DefaultInterface.NormalizeGraph(hGR);
end;

function TWPGraphs.ActiveGraphPage: Integer;
begin
  Result := DefaultInterface.ActiveGraphPage;
end;

function TWPGraphs.ActiveGraph(hGC: Integer): Integer;
begin
  Result := DefaultInterface.ActiveGraph(hGC);
end;

procedure TWPGraphs.Folder2Graphs(const Node: IDispatch);
begin
  DefaultInterface.Folder2Graphs(Node);
end;

procedure TWPGraphs.SetYAxisMinMax(Axis: Integer; MinX: Double; MaxX: Double);
begin
  DefaultInterface.SetYAxisMinMax(Axis, MinX, MaxX);
end;

procedure TWPGraphs.invalidate(hGraph: Integer);
begin
  DefaultInterface.invalidate(hGraph);
end;

procedure TWPGraphs.Folder2GraphsRecursive(const Node: IDispatch);
begin
  DefaultInterface.Folder2GraphsRecursive(Node);
end;

procedure TWPGraphs.SetLineOpt(hLine: Integer; opt: Integer; mask: Integer; width: Integer; 
                               color: Integer);
begin
  DefaultInterface.SetLineOpt(hLine, opt, mask, width, color);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPGraphsProperties.Create(AServer: TWPGraphs);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPGraphsProperties.GetDefaultInterface: IWPGraphs;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoWPOperator.Create: IWPOperator;
begin
  Result := CreateComObject(CLASS_WPOperator) as IWPOperator;
end;

class function CoWPOperator.CreateRemote(const MachineName: string): IWPOperator;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPOperator) as IWPOperator;
end;

procedure TWPOperator.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3E9EF875-5F7D-4B15-85F7-34AB8E5D4086}';
    IntfIID:   '{5819D3E4-58AC-4A0F-A24D-A6BCEFC41B56}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPOperator.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPOperator;
  end;
end;

procedure TWPOperator.ConnectTo(svrIntf: IWPOperator);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPOperator.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPOperator.GetDefaultInterface: IWPOperator;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPOperator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPOperatorProperties.Create(Self);
{$ENDIF}
end;

destructor TWPOperator.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPOperator.GetServerProperties: TWPOperatorProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWPOperator.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TWPOperator.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TWPOperator.Get_Fullname: WideString;
begin
  Result := DefaultInterface.Fullname;
end;

procedure TWPOperator.Set_Fullname(const Value: WideString);
begin
  DefaultInterface.Fullname := Value;
end;

function TWPOperator.Get_nSrc: Integer;
begin
  Result := DefaultInterface.nSrc;
end;

procedure TWPOperator.Set_nSrc(Value: Integer);
begin
  DefaultInterface.nSrc := Value;
end;

function TWPOperator.Get_nDst: Integer;
begin
  Result := DefaultInterface.nDst;
end;

procedure TWPOperator.Set_nDst(Value: Integer);
begin
  DefaultInterface.nDst := Value;
end;

function TWPOperator.Info(kind: Integer): WideString;
begin
  Result := DefaultInterface.Info(kind);
end;

function TWPOperator.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

function TWPOperator.Error: Integer;
begin
  Result := DefaultInterface.Error;
end;

function TWPOperator.MsgError: WideString;
begin
  Result := DefaultInterface.MsgError;
end;

function TWPOperator.valid(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer;
begin
  Result := DefaultInterface.valid(src1, src2, dst1, dst2);
end;

function TWPOperator.Exec(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer;
begin
  Result := DefaultInterface.Exec(src1, src2, dst1, dst2);
end;

procedure TWPOperator.setProperty(const Name: WideString; Value: OleVariant);
begin
  DefaultInterface.setProperty(Name, Value);
end;

function TWPOperator.getProperty(const Name: WideString): OleVariant;
begin
  Result := DefaultInterface.getProperty(Name);
end;

function TWPOperator.getProperySet: WideString;
begin
  Result := DefaultInterface.getProperySet;
end;

procedure TWPOperator.loadProperties(const values: WideString);
begin
  DefaultInterface.loadProperties(values);
end;

function TWPOperator.SetupDlg: Integer;
begin
  Result := DefaultInterface.SetupDlg;
end;

function TWPOperator.getPropertyValues: WideString;
begin
  Result := DefaultInterface.getPropertyValues;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPOperatorProperties.Create(AServer: TWPOperator);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPOperatorProperties.GetDefaultInterface: IWPOperator;
begin
  Result := FServer.DefaultInterface;
end;

function TWPOperatorProperties.Get_Name: WideString;
begin
  Result := DefaultInterface.Name;
end;

procedure TWPOperatorProperties.Set_Name(const Value: WideString);
begin
  DefaultInterface.Name := Value;
end;

function TWPOperatorProperties.Get_Fullname: WideString;
begin
  Result := DefaultInterface.Fullname;
end;

procedure TWPOperatorProperties.Set_Fullname(const Value: WideString);
begin
  DefaultInterface.Fullname := Value;
end;

function TWPOperatorProperties.Get_nSrc: Integer;
begin
  Result := DefaultInterface.nSrc;
end;

procedure TWPOperatorProperties.Set_nSrc(Value: Integer);
begin
  DefaultInterface.nSrc := Value;
end;

function TWPOperatorProperties.Get_nDst: Integer;
begin
  Result := DefaultInterface.nDst;
end;

procedure TWPOperatorProperties.Set_nDst(Value: Integer);
begin
  DefaultInterface.nDst := Value;
end;

{$ENDIF}

class function CoWPOpManager.Create: IWPOpManager;
begin
  Result := CreateComObject(CLASS_WPOpManager) as IWPOpManager;
end;

class function CoWPOpManager.CreateRemote(const MachineName: string): IWPOpManager;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPOpManager) as IWPOpManager;
end;

procedure TWPOpManager.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{F2E45036-48F7-4196-9BA8-088CC1BF3A7B}';
    IntfIID:   '{7102D9F6-913A-41DF-A60D-7B36DD28D150}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPOpManager.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPOpManager;
  end;
end;

procedure TWPOpManager.ConnectTo(svrIntf: IWPOpManager);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPOpManager.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPOpManager.GetDefaultInterface: IWPOpManager;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPOpManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPOpManagerProperties.Create(Self);
{$ENDIF}
end;

destructor TWPOpManager.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPOpManager.GetServerProperties: TWPOpManagerProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWPOpManager.Get_count: Integer;
begin
  Result := DefaultInterface.count;
end;

procedure TWPOpManager.Set_count(Value: Integer);
begin
  DefaultInterface.count := Value;
end;

function TWPOpManager.Get(index: Integer): IDispatch;
begin
  Result := DefaultInterface.Get(index);
end;

function TWPOpManager.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPOpManagerProperties.Create(AServer: TWPOpManager);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPOpManagerProperties.GetDefaultInterface: IWPOpManager;
begin
  Result := FServer.DefaultInterface;
end;

function TWPOpManagerProperties.Get_count: Integer;
begin
  Result := DefaultInterface.count;
end;

procedure TWPOpManagerProperties.Set_count(Value: Integer);
begin
  DefaultInterface.count := Value;
end;

{$ENDIF}

class function CoWPTree.Create: IWPTree;
begin
  Result := CreateComObject(CLASS_WPTree) as IWPTree;
end;

class function CoWPTree.CreateRemote(const MachineName: string): IWPTree;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPTree) as IWPTree;
end;

procedure TWPTree.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{17537B46-A715-4F61-A33A-1185F0B13561}';
    IntfIID:   '{9FAE7440-650A-4A71-9D1E-CC96ABAB7A99}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPTree.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPTree;
  end;
end;

procedure TWPTree.ConnectTo(svrIntf: IWPTree);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPTree.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPTree.GetDefaultInterface: IWPTree;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPTree.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPTreeProperties.Create(Self);
{$ENDIF}
end;

destructor TWPTree.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPTree.GetServerProperties: TWPTreeProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TWPTree.Refresh;
begin
  DefaultInterface.Refresh;
end;

function TWPTree.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

function TWPTree.GetNode(const path: WideString): Integer;
begin
  Result := DefaultInterface.GetNode(path);
end;

function TWPTree.Get(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.Get(path);
end;

function TWPTree.GetObject(const path: WideString): IDispatch;
begin
  Result := DefaultInterface.GetObject(path);
end;

procedure TWPTree.Unlink(const path: WideString);
begin
  DefaultInterface.Unlink(path);
end;

function TWPTree.Link(const path: WideString; const Name: WideString; const obj: IDispatch): IDispatch;
begin
  Result := DefaultInterface.Link(path, Name, obj);
end;

function TWPTree.GetSelectedItem: IDispatch;
begin
  Result := DefaultInterface.GetSelectedItem;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPTreeProperties.Create(AServer: TWPTree);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPTreeProperties.GetDefaultInterface: IWPTree;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoWPObject.Create: IWPObject;
begin
  Result := CreateComObject(CLASS_WPObject) as IWPObject;
end;

class function CoWPObject.CreateRemote(const MachineName: string): IWPObject;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPObject) as IWPObject;
end;

procedure TWPObject.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{9E35C1D1-2ECB-477F-9708-239E48EC10D4}';
    IntfIID:   '{68965773-29D7-4EF8-A835-0C94BFDEF186}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPObject.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPObject;
  end;
end;

procedure TWPObject.ConnectTo(svrIntf: IWPObject);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPObject.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPObject.GetDefaultInterface: IWPObject;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPObjectProperties.Create(Self);
{$ENDIF}
end;

destructor TWPObject.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPObject.GetServerProperties: TWPObjectProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TWPObject.Instance: Integer;
begin
  Result := DefaultInterface.Instance;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPObjectProperties.Create(AServer: TWPObject);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPObjectProperties.GetDefaultInterface: IWPObject;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoWPPlugin.Create: IWPPlugin;
begin
  Result := CreateComObject(CLASS_WPPlugin) as IWPPlugin;
end;

class function CoWPPlugin.CreateRemote(const MachineName: string): IWPPlugin;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPPlugin) as IWPPlugin;
end;

procedure TWPPlugin.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{424A7882-7E39-4647-8478-DB554BE24C3B}';
    IntfIID:   '{51A85FC7-DAF3-497B-8899-7D0326D072BC}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPPlugin.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPPlugin;
  end;
end;

procedure TWPPlugin.ConnectTo(svrIntf: IWPPlugin);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPPlugin.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPPlugin.GetDefaultInterface: IWPPlugin;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPPlugin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPPluginProperties.Create(Self);
{$ENDIF}
end;

destructor TWPPlugin.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPPlugin.GetServerProperties: TWPPluginProperties;
begin
  Result := FProps;
end;
{$ENDIF}

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPPluginProperties.Create(AServer: TWPPlugin);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPPluginProperties.GetDefaultInterface: IWPPlugin;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoCOleFileDialog.Create: IFileDialog;
begin
  Result := CreateComObject(CLASS_COleFileDialog) as IFileDialog;
end;

class function CoCOleFileDialog.CreateRemote(const MachineName: string): IFileDialog;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_COleFileDialog) as IFileDialog;
end;

procedure TCOleFileDialog.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{967AD1B9-4561-4F5D-B3FC-120876EE6870}';
    IntfIID:   '{BB5E9128-BD80-4AA8-A77A-8D6C87B2F911}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCOleFileDialog.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFileDialog;
  end;
end;

procedure TCOleFileDialog.ConnectTo(svrIntf: IFileDialog);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCOleFileDialog.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCOleFileDialog.GetDefaultInterface: IFileDialog;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCOleFileDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCOleFileDialogProperties.Create(Self);
{$ENDIF}
end;

destructor TCOleFileDialog.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCOleFileDialog.GetServerProperties: TCOleFileDialogProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TCOleFileDialog.Get_FileCount: Integer;
begin
  Result := DefaultInterface.FileCount;
end;

procedure TCOleFileDialog.Set_FileCount(Value: Integer);
begin
  DefaultInterface.FileCount := Value;
end;

function TCOleFileDialog.GetFile(index: Integer): WideString;
begin
  Result := DefaultInterface.GetFile(index);
end;

procedure TCOleFileDialog.Create1(isOPen: Integer; const FileName: WideString; 
                                  const defaultExt: WideString; const filter: WideString; 
                                  Options: Integer);
begin
  DefaultInterface.Create(isOPen, FileName, defaultExt, filter, Options);
end;

function TCOleFileDialog.DoModal: Integer;
begin
  Result := DefaultInterface.DoModal;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCOleFileDialogProperties.Create(AServer: TCOleFileDialog);
begin
  inherited Create;
  FServer := AServer;
end;

function TCOleFileDialogProperties.GetDefaultInterface: IFileDialog;
begin
  Result := FServer.DefaultInterface;
end;

function TCOleFileDialogProperties.Get_FileCount: Integer;
begin
  Result := DefaultInterface.FileCount;
end;

procedure TCOleFileDialogProperties.Set_FileCount(Value: Integer);
begin
  DefaultInterface.FileCount := Value;
end;

{$ENDIF}

class function CoWPDlgChSignal.Create: IWPDlgChSignal;
begin
  Result := CreateComObject(CLASS_WPDlgChSignal) as IWPDlgChSignal;
end;

class function CoWPDlgChSignal.CreateRemote(const MachineName: string): IWPDlgChSignal;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPDlgChSignal) as IWPDlgChSignal;
end;

procedure TWPDlgChSignal.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{B3948803-B7AD-11D7-84B0-00C0262B9C1C}';
    IntfIID:   '{B3948801-B7AD-11D7-84B0-00C0262B9C1C}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWPDlgChSignal.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IWPDlgChSignal;
  end;
end;

procedure TWPDlgChSignal.ConnectTo(svrIntf: IWPDlgChSignal);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TWPDlgChSignal.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TWPDlgChSignal.GetDefaultInterface: IWPDlgChSignal;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWPDlgChSignal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWPDlgChSignalProperties.Create(Self);
{$ENDIF}
end;

destructor TWPDlgChSignal.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWPDlgChSignal.GetServerProperties: TWPDlgChSignalProperties;
begin
  Result := FProps;
end;
{$ENDIF}

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWPDlgChSignalProperties.Create(AServer: TWPDlgChSignal);
begin
  inherited Create;
  FServer := AServer;
end;

function TWPDlgChSignalProperties.GetDefaultInterface: IWPDlgChSignal;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TWinPOS, TWPSignal, TWPUSML, TWPNode, 
    TWPGraphs, TWPOperator, TWPOpManager, TWPTree, TWPObject, 
    TWPPlugin, TCOleFileDialog, TWPDlgChSignal]);
end;

end.
