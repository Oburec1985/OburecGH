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

// $Rev: 17244 $
// File generated on 15.07.2024 12:40:22 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files (x86)\MERA\WinPOS\WinPos.tlb (1)
// LIBID: {BB9A452A-71C4-411E-BCCF-CA1D2ADCFB8C}
// LCID: 0
// Helpfile: 
// HelpString: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// Parent TypeLibrary:
//   (0) v1.0 Project1, (E:\DelphiProjects\Lazutin\WinPos\WPPerPlg\Project1)
// Errors:
//   Hint: Parameter 'type' of IWinPOS.SaveSignal changed to 'type_'
//   Hint: Parameter 'type' of IWinPOS.LoadSignal changed to 'type_'
//   Hint: Parameter 'Object' of IWinPOS.Unlink changed to 'Object_'
//   Hint: Parameter 'type' of IWinPOS.CreateSignal changed to 'type_'
//   Hint: Parameter 'Object' of IWinPOS.Link changed to 'Object_'
//   Hint: Parameter 'Object' of IWinPOS.GetNode changed to 'Object_'
//   Hint: Parameter 'begin' of IWPSignal.Clone changed to 'begin_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Parameter 'Object' of IWPNode.Link changed to 'Object_'
//   Hint: Parameter 'type' of IWPGraphs.CreatePage2 changed to 'type_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
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
  Winpos_oleMinorVersion = 1;

  LIBID_Winpos_ole: TGUID = '{BB9A452A-71C4-411E-BCCF-CA1D2ADCFB8C}';

  DIID_IWinPOS: TGUID = '{69E69FFF-3501-404B-A1FF-536226245C1B}';
  IID_IWPPlugin: TGUID = '{51A85FC7-DAF3-497B-8899-7D0326D072BC}';
  IID_IWPImport: TGUID = '{83B83A84-4AC6-11DE-ADD2-001A9257431C}';
  IID_IWPExport: TGUID = '{B099661F-7A12-4EA4-A234-D1AC4A565537}';
  IID_IWPExtOper: TGUID = '{915FDE3E-E216-4D70-BE75-3109254165C0}';
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
  DIID_IWPFileDialog: TGUID = '{BB5E9128-BD80-4AA8-A77A-8D6C87B2F911}';
  CLASS_COleWPFileDialog: TGUID = '{967AD1B9-4561-4F5D-B3FC-120876EE6870}';
  DIID_IWPDlgChSignal: TGUID = '{B3948801-B7AD-11D7-84B0-00C0262B9C1C}';
  CLASS_WPDlgChSignal: TGUID = '{B3948803-B7AD-11D7-84B0-00C0262B9C1C}';
  DIID_IWPUnits: TGUID = '{08EEC529-A39A-4A6D-B2C3-F753AFE2C647}';
  CLASS_WPUnits: TGUID = '{747ED8D6-0440-4722-B1E5-956BFE024226}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum OBJECT_TYPE
type
  OBJECT_TYPE = TOleEnum;
const
  OBJTYPE_EMPTY = $00000000;
  OBJTYPE_UNKNOWN = $00000001;
  OBJTYPE_NODE = $00000002;
  OBJTYPE_SIGNAL = $00000003;
  OBJTYPE_OPER = $00000004;

// Constants for enum PAGE_OPTIONS2
type
  PAGE_OPTIONS2 = TOleEnum;
const
  PGOPT2_NAME = $00000001;
  PGOPT2_SHOWNAME = $00000002;
  PGOPT2_RECT = $00000003;
  PGOPT2_MAXIMIZED = $00000004;
  PGOPT2_SINGLEX = $00000005;
  PGOPT2_SINGLEY = $00000006;
  PGOPT2_SINCCURS = $00000007;

// Constants for enum GRAPH_OPTIONS2
type
  GRAPH_OPTIONS2 = TOleEnum;
const
  GROPT2_NAME = $00000001;
  GROPT2_SHOWNAME = $00000002;
  GROPT2_BORDER = $00000003;
  GROPT2_SHOWLEGEND = $00000004;
  GROPT2_YINDENT = $00000005;
  GROPT2_SUBGRID = $00000006;
  GROPT2_GRIDLABS = $00000007;
  GROPT2_LINENUMS = $00000008;
  GROPT2_AUTONORM = $00000009;
  GROPT2_AXCOLUMN = $0000000A;
  GROPT2_AXROW = $0000000B;
  GROPT2_POLAR = $0000000C;

// Constants for enum LINE_OPTIONS2
type
  LINE_OPTIONS2 = TOleEnum;
const
  LNOPT2_NAME = $00000001;
  LNOPT2_VISIBLE = $00000002;
  LNOPT2_COLOR = $00000003;
  LNOPT2_WIDTH = $00000004;
  LNOPT2_LINETYPE = $00000005;
  LNOPT2_POINTTYPE = $00000006;
  LNOPT2_LINE2BASE = $00000007;
  LNOPT2_ONLYPOINTS = $00000008;
  LNOPT2_HIST = $00000009;
  LNOPT2_HISTTRANSP = $0000000A;
  LNOPT2_PARAM = $0000000B;
  LNOPT2_INTERP = $0000000C;
  LNOPT2_SYSTEM = $0000000D;

// Constants for enum AXIS_OPTIONS2
type
  AXIS_OPTIONS2 = TOleEnum;
const
  AXOPT2_NAME = $00000001;
  AXOPT2_UNITSNAME = $00000002;
  AXOPT2_COLOR = $00000003;
  AXOPT2_FORMAT = $00000004;
  AXOPT2_FZERO = $00000005;
  AXOPT2_LOG = $00000006;
  AXOPT2_TIME = $00000007;
  AXOPT2_DATE = $00000008;

// Constants for enum LEGEND_OPTIONS2
type
  LEGEND_OPTIONS2 = TOleEnum;
const
  LGNOPT2_VISIBLE = $00000001;
  LGNOPT2_MODE = $00000002;
  LGNOPT2_ALIGN = $00000003;
  LGNOPT2_SIZE = $00000004;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IWinPOS = dispinterface;
  IWPPlugin = interface;
  IWPPluginDisp = dispinterface;
  IWPImport = interface;
  IWPImportDisp = dispinterface;
  IWPExport = interface;
  IWPExportDisp = dispinterface;
  IWPExtOper = interface;
  IWPExtOperDisp = dispinterface;
  IWPSignal = dispinterface;
  IWPUSML = dispinterface;
  IWPNode = dispinterface;
  IWPGraphs = dispinterface;
  IWPOperator = dispinterface;
  IWPOpManager = dispinterface;
  IWPTree = dispinterface;
  IWPObject = dispinterface;
  IWPFileDialog = dispinterface;
  IWPDlgChSignal = dispinterface;
  IWPUnits = dispinterface;

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
  COleWPFileDialog = IWPFileDialog;
  WPDlgChSignal = IWPDlgChSignal;
  WPUnits = IWPUnits;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  POleVariant1 = ^OleVariant; {*}
  PDouble1 = ^Double; {*}
  PInteger1 = ^Integer; {*}
  PWideString1 = ^WideString; {*}
  PSYSINT1 = ^SYSINT; {*}


// *********************************************************************//
// DispIntf:  IWinPOS
// Flags:     (4096) Dispatchable
// GUID:      {69E69FFF-3501-404B-A1FF-536226245C1B}
// *********************************************************************//
  IWinPOS = dispinterface
    ['{69E69FFF-3501-404B-A1FF-536226245C1B}']
    procedure SaveSignal(const Name: WideString; const FileName: WideString; type_: Integer); dispid 6;
    function LoadUSML(const path: WideString): IDispatch; dispid 3;
    function VBSEditor: IDispatch; dispid 18;
    procedure SaveUSML(const Name: WideString; const FileName: WideString); dispid 5;
    function LoadSignal(const path: WideString; type_: Integer): IDispatch; dispid 4;
    procedure Unlink(const Object_: IDispatch); dispid 11;
    function CreateSignalXY(xtype: SYSINT; ytype: SYSINT): IDispatch; dispid 8;
    function CreateSignal(type_: SYSINT): IDispatch; dispid 7;
    function Link(const path: WideString; const Name: WideString; const Object_: IDispatch): IDispatch; dispid 10;
    procedure DebugPrint(arg: OleVariant); dispid 15;
    function GetObject(const path: WideString): IDispatch; dispid 12;
    procedure ProgressStart(const comment: WideString; max: Integer); dispid 65;
    function GetNode(const Object_: IDispatch): IDispatch; dispid 14;
    function GraphAPI: IDispatch; dispid 13;
    function OpenFile(const path: WideString; flags: Integer): Integer; dispid 20;
    procedure DoEvents; dispid 17;
    procedure DebugPrintLn(arg: OleVariant); dispid 16;
    function FileOpen(isOPen: Integer; const ext: WideString; const fname: WideString; 
                      flags: Integer; const filter: WideString): WideString; dispid 19;
    procedure Refresh; dispid 9;
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
    function RegisterImpExp(const imp: IDispatch; const exp: IDispatch; 
                            desc: {??PWideChar}OleVariant; ext: {??PWideChar}OleVariant): WordBool; dispid 64;
    function GetSelectedNode: IDispatch; dispid 42;
    procedure execVBS(const code: WideString); dispid 39;
    function USMLDialog: WideString; dispid 48;
    function GetSelectedObject: IDispatch; dispid 41;
    procedure ShowToolbar(bar: Integer; visible: Integer); dispid 40;
    function FileDlg: IDispatch; dispid 47;
    function CreatemenuItem(Command: Integer; reserved: Integer; const text: WideString; 
                            style: Integer; picture: Integer): Integer; dispid 44;
    function RegisterCommand: Integer; dispid 43;
    function CreatetoolbarButton(bar: Integer; Command: Integer; picture: Integer; 
                                 const hint: WideString): Integer; dispid 46;
    procedure Test; dispid 49;
    procedure PrintPage(page: Integer; const comment: WideString; flags: Integer); dispid 50;
    function GetNodeStr(const path: WideString): IDispatch; dispid 51;
    function Get(const path: WideString): IDispatch; dispid 52;
    function GetObjectStr(const path: WideString): IDispatch; dispid 53;
    procedure UnlinkStr(const path: WideString); dispid 54;
    function GetSelectedItem: IDispatch; dispid 55;
    function GetChSignalDlg: IDispatch; dispid 56;
    function LinkISignal(const path: WideString; const Name: WideString; signal: Integer): IDispatch; dispid 57;
    function CreateToolbar: Integer; dispid 45;
    procedure AddTextInLog(const text: WideString; const exttext: WideString; show: WordBool); dispid 61;
    function GetInterval(const src: IDispatch; start: Integer; count: Integer): IDispatch; dispid 62;
    function CreateSignal2(stype: SYSINT; ytype: SYSINT; xtype: SYSINT; ztype: SYSINT): IDispatch; dispid 76;
    function CreateToolbarN(const Name: WideString): Integer; dispid 68;
    function IsNodeExist(const path: WideString): WordBool; dispid 59;
    procedure ProgressStep(Pos: Integer); dispid 66;
    procedure ProgressFinish; dispid 67;
    procedure DeleteNode(const path: WideString); dispid 60;
    function GetOversampled(const src: IDispatch; freq: Double): IDispatch; dispid 63;
    procedure Notify(what: Integer; param: OleVariant); dispid 73;
    procedure ToolbarSetButtonStyle(bar: Integer; Command: Integer; nStyle: Integer); dispid 69;
    function GetISignal(const Name: WideString): Integer; dispid 58;
    function RegisterExtOper(const oper: IDispatch; nsrc: Integer; ndst: Integer; 
                             Name: {??PWideChar}OleVariant; shortname: {??PWideChar}OleVariant; 
                             bauto: WordBool): WordBool; dispid 72;
    procedure SetWorkDir(const path: WideString); dispid 70;
    function GetUnits: IDispatch; dispid 78;
    function ShowSignal(const sig: IDispatch): Integer; dispid 75;
    procedure Select(const node: IDispatch); dispid 74;
    function GetObjectType(const obj: IDispatch): Integer; dispid 77;
    property TimeSync: WordBool dispid 71;
    property SelectedSignal: WideString dispid 2;
    property SelectedGraph: WideString dispid 1;
  end;

// *********************************************************************//
// Interface: IWPPlugin
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {51A85FC7-DAF3-497B-8899-7D0326D072BC}
// *********************************************************************//
  IWPPlugin = interface(IDispatch)
    ['{51A85FC7-DAF3-497B-8899-7D0326D072BC}']
    function Connect(const app: IDispatch): Integer; safecall;
    function Disconnect: Integer; safecall;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer; safecall;
  end;

// *********************************************************************//
// DispIntf:  IWPPluginDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {51A85FC7-DAF3-497B-8899-7D0326D072BC}
// *********************************************************************//
  IWPPluginDisp = dispinterface
    ['{51A85FC7-DAF3-497B-8899-7D0326D072BC}']
    function Connect(const app: IDispatch): Integer; dispid 1;
    function Disconnect: Integer; dispid 2;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer; dispid 3;
  end;

// *********************************************************************//
// Interface: IWPImport
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {83B83A84-4AC6-11DE-ADD2-001A9257431C}
// *********************************************************************//
  IWPImport = interface(IWPPlugin)
    ['{83B83A84-4AC6-11DE-ADD2-001A9257431C}']
    function Open(const path: WideString; out count: Integer): HResult; safecall;
    procedure Close; safecall;
    function GetSignal(n: Integer): IDispatch; safecall;
    function GetPreviewText(const path: WideString): WideString; safecall;
  end;

// *********************************************************************//
// DispIntf:  IWPImportDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {83B83A84-4AC6-11DE-ADD2-001A9257431C}
// *********************************************************************//
  IWPImportDisp = dispinterface
    ['{83B83A84-4AC6-11DE-ADD2-001A9257431C}']
    function Open(const path: WideString; out count: Integer): HResult; dispid 17;
    procedure Close; dispid 18;
    function GetSignal(n: Integer): IDispatch; dispid 19;
    function GetPreviewText(const path: WideString): WideString; dispid 20;
    function Connect(const app: IDispatch): Integer; dispid 1;
    function Disconnect: Integer; dispid 2;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer; dispid 3;
  end;

// *********************************************************************//
// Interface: IWPExport
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B099661F-7A12-4EA4-A234-D1AC4A565537}
// *********************************************************************//
  IWPExport = interface(IWPPlugin)
    ['{B099661F-7A12-4EA4-A234-D1AC4A565537}']
    procedure AddSignal(const sig: IDispatch); safecall;
    function Save(const path: WideString): HResult; safecall;
  end;

// *********************************************************************//
// DispIntf:  IWPExportDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B099661F-7A12-4EA4-A234-D1AC4A565537}
// *********************************************************************//
  IWPExportDisp = dispinterface
    ['{B099661F-7A12-4EA4-A234-D1AC4A565537}']
    procedure AddSignal(const sig: IDispatch); dispid 33;
    function Save(const path: WideString): HResult; dispid 34;
    function Connect(const app: IDispatch): Integer; dispid 1;
    function Disconnect: Integer; dispid 2;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer; dispid 3;
  end;

// *********************************************************************//
// Interface: IWPExtOper
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {915FDE3E-E216-4D70-BE75-3109254165C0}
// *********************************************************************//
  IWPExtOper = interface(IDispatch)
    ['{915FDE3E-E216-4D70-BE75-3109254165C0}']
    procedure GetPropStr(out pstr: WideString); safecall;
    procedure SetPropStr(const str: WideString); safecall;
    procedure Exec(const psrc1: IDispatch; const psrc2: IDispatch; out pdst1: IDispatch; 
                   out pdst2: IDispatch); safecall;
    procedure GetError(out pnerrcode: Integer; out perrstr: WideString); safecall;
    procedure OnSetup(hwndparent: Integer; out phwnd: Integer); safecall;
    procedure OnApply; safecall;
    procedure OnClose; safecall;
  end;

// *********************************************************************//
// DispIntf:  IWPExtOperDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {915FDE3E-E216-4D70-BE75-3109254165C0}
// *********************************************************************//
  IWPExtOperDisp = dispinterface
    ['{915FDE3E-E216-4D70-BE75-3109254165C0}']
    procedure GetPropStr(out pstr: WideString); dispid 1;
    procedure SetPropStr(const str: WideString); dispid 2;
    procedure Exec(const psrc1: IDispatch; const psrc2: IDispatch; out pdst1: IDispatch; 
                   out pdst2: IDispatch); dispid 3;
    procedure GetError(out pnerrcode: Integer; out perrstr: WideString); dispid 4;
    procedure OnSetup(hwndparent: Integer; out phwnd: Integer); dispid 5;
    procedure OnApply; dispid 6;
    procedure OnClose; dispid 7;
  end;

// *********************************************************************//
// DispIntf:  IWPSignal
// Flags:     (4096) Dispatchable
// GUID:      {CA7B31AE-CD01-4EB8-9C40-F48F61297292}
// *********************************************************************//
  IWPSignal = dispinterface
    ['{CA7B31AE-CD01-4EB8-9C40-F48F61297292}']
    function IndexOf(x: Double): Integer; dispid 22;
    function GetTransformerType: Integer; dispid 20;
    function GetType: Integer; dispid 21;
    function GetZ(index: SYSINT): Double; dispid 24;
    function Instance: Integer; dispid 15;
    function GetX(index: Integer): Double; dispid 16;
    function GetYX(x: Double; pow: SYSINT): Double; dispid 23;
    function GetSProperty(const Name: WideString): WideString; dispid 61;
    function ConvertTime(dblSrcTime: Double; out pdblDstTime: Double; nConvType: SYSINT): WordBool; dispid 56;
    function GetStartTime: Double; dispid 55;
    function Clone(begin_: {??Int64}OleVariant; count: {??Int64}OleVariant): IDispatch; dispid 62;
    function GetSizeX(indexZ: SYSINT): SYSINT; dispid 36;
    procedure SetSProperty(const Name: WideString; const Value: WideString); dispid 60;
    function GetSType(nTypeType: Integer; nTypeAx: Integer): {??Largeuint}OleVariant; dispid 59;
    procedure SetX_iZ(indexX: SYSINT; indexZ: SYSINT; d: Double); dispid 27;
    function IndexOf_Z(x: Double; indexZ: SYSINT): SYSINT; dispid 34;
    function IsXChangesWithZ: Integer; dispid 35;
    function GetX_iZ(indexX: SYSINT; indexZ: SYSINT): Double; dispid 26;
    procedure SetY_iZ(indexX: SYSINT; indexZ: SYSINT; d: Double; viaTransformer: WordBool); dispid 29;
    function GetYX_iZ(x: Double; indexZ: SYSINT; pow: SYSINT): Double; dispid 30;
    function GetY_iZ(indexX: SYSINT; indexZ: SYSINT; viaTransformer: WordBool): Double; dispid 28;
    procedure SetX(index: Integer; Value: Double); dispid 18;
    procedure SetY(index: Integer; Value: Double); dispid 19;
    function GetY(index: Integer): Double; dispid 17;
    procedure SetZ(index: SYSINT; d: Double); dispid 25;
    function ZIndexOf(z: Double): SYSINT; dispid 33;
    function GetYZ(z: Double; indexX: SYSINT; pow: SYSINT): Double; dispid 31;
    function GetYXZ(x: Double; z: Double; pow: SYSINT): Double; dispid 32;
    procedure SetSType(nTypeType: Integer; nTypeAx: Integer; nTypeVal: {??Largeuint}OleVariant); dispid 58;
    function GetIntervalSignalX(indexX: SYSINT; ibeg: SYSINT; iend: SYSINT): IDispatch; dispid 39;
    procedure SetStartZ(startZ: Double); dispid 45;
    function GetOriginalY(index: Integer): Double; dispid 51;
    function GetIntervalSignalZ(indexZ: SYSINT; ibeg: SYSINT; iend: SYSINT): IDispatch; dispid 40;
    procedure SetDeltaZ(deltaZ: Double); dispid 43;
    procedure ResizeXZ(xsize: SYSINT; zsize: SYSINT; bXsz_EQU_Ysz: WordBool); dispid 38;
    function GetSizeZ: SYSINT; dispid 37;
    function GetNameZ: WideString; dispid 46;
    procedure SetStartTime(time: Double); dispid 49;
    procedure AddPart(x: Double; xReal: Double; nInd: SYSINT); dispid 48;
    procedure SetNameZ(newNameZ: {??PWideChar}OleVariant); dispid 47;
    function GetParent: IDispatch; dispid 50;
    function GetArray(index: Integer; out pnCount: Integer; var varYValues: OleVariant; 
                      var varXValues: OleVariant; bUseScale: WordBool): WordBool; dispid 53;
    procedure SetOriginalY(index: Integer; Value: Double); dispid 52;
    function ConvertTime_V(dblSrcTime: Double; out varDstTime: OleVariant; nConvType: SYSINT): WordBool; dispid 71;
    function SetArray_V(index: Integer; out pnCount: OleVariant; var varYValues: OleVariant; 
                        var varXValues: OleVariant; bUseScale: WordBool): WordBool; dispid 70;
    function GetSEVSignal: IDispatch; dispid 65;
    function GetDeltaX_Orig: Double; dispid 68;
    procedure GetRangeZ_V(var minZ: OleVariant; var maxZ: OleVariant); dispid 57;
    procedure Shift(nAx: SYSINT; dA: Double; dB: Double); dispid 63;
    function GetArray_V(index: Integer; out pnCount: OleVariant; var varYValues: OleVariant; 
                        var varXValues: OleVariant; bUseScale: WordBool): WordBool; dispid 69;
    function GetDeltaZ: Double; dispid 42;
    procedure GetRangeZ(var minZ: Double; var maxZ: Double); dispid 41;
    function GetStartZ: Double; dispid 44;
    function SetArray(index: Integer; out pnCount: Integer; var varYValues: OleVariant; 
                      var varXValues: OleVariant; bUseScale: WordBool): WordBool; dispid 54;
    function IsSEVExists: Integer; dispid 64;
    function GetStartX_Orig: Double; dispid 67;
    procedure SetSEVSignal(const nameSEV: WideString); dispid 66;
    property k1: Double dispid 14;
    property k0: Double dispid 13;
    property MaxY: Double dispid 12;
    property MinY: Double dispid 11;
    property MaxX: Double dispid 10;
    property MinX: Double dispid 9;
    property Characteristic: Integer dispid 8;
    property comment: WideString dispid 7;
    property NameY: WideString dispid 6;
    property NameX: WideString dispid 5;
    property SName: WideString dispid 4;
    property StartX: Double dispid 3;
    property DeltaX: Double dispid 2;
    property size: Integer dispid 1;
  end;

// *********************************************************************//
// DispIntf:  IWPUSML
// Flags:     (4096) Dispatchable
// GUID:      {87FA08E2-DA9C-4BDC-819F-3D70AACDFED6}
// *********************************************************************//
  IWPUSML = dispinterface
    ['{87FA08E2-DA9C-4BDC-819F-3D70AACDFED6}']
    procedure DeleteParameter(index: Integer); dispid 13;
    procedure AddParameter(const signal: IDispatch); dispid 12;
    procedure FileSave; dispid 11;
    function Parameter(index: Integer): IDispatch; dispid 10;
    function Instance: Integer; dispid 9;
    property ParamCount: Integer dispid 7;
    property type_: Smallint dispid 4;
    property SubType: Smallint dispid 5;
    property flags: Integer dispid 6;
    property Name: WideString dispid 1;
    property time: WideString dispid 14;
    property FileName: WideString dispid 8;
    property Test: WideString dispid 2;
    property Date: WideString dispid 3;
  end;

// *********************************************************************//
// DispIntf:  IWPNode
// Flags:     (4096) Dispatchable
// GUID:      {E5E07BCC-5AD9-4D0D-BA7C-2B1934E43CAB}
// *********************************************************************//
  IWPNode = dispinterface
    ['{E5E07BCC-5AD9-4D0D-BA7C-2B1934E43CAB}']
    procedure Unlink(const objname: WideString); dispid 6;
    function Instance: Integer; dispid 3;
    function IsValidNode: Integer; dispid 11;
    function Link(const Object_: IDispatch; const Name: WideString; flag: Integer): IDispatch; dispid 5;
    function Reference: IDispatch; dispid 4;
    function IsChild(const testNode: IDispatch): Integer; dispid 7;
    function Child(const testNode: IDispatch): Integer; dispid 8;
    function Current: IDispatch; dispid 9;
    function Root: IDispatch; dispid 10;
    function GetReferenceType: Integer; dispid 18;
    function IsDirectory: Integer; dispid 14;
    function AbsolutePath: WideString; dispid 12;
    function GetNode(const path: WideString): IDispatch; dispid 15;
    function GetObject(const path: WideString): IDispatch; dispid 16;
    function RelativePath(const baseNode: IDispatch): WideString; dispid 13;
    function Parent: IDispatch; dispid 19;
    function At(index: Integer): IDispatch; dispid 17;
    procedure SetNodeProperty(const Name: WideString; const Value: WideString); dispid 20;
    function GetNodeProperty(const Name: WideString): WideString; dispid 21;
    property ChildCount: Integer dispid 2;
    property Name: WideString dispid 1;
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
    procedure Folder2Graphs(const node: IDispatch); dispid 29;
    procedure SetYAxisMinMax(hAxis: Integer; min: Double; max: Double); dispid 31;
    procedure invalidate(hGraph: Integer); dispid 32;
    procedure Folder2GraphsRecursive(const node: IDispatch); dispid 30;
    procedure SetLineOpt(hLine: Integer; opt: Integer; mask: Integer; width: Integer; color: Integer); dispid 33;
    procedure Clear; dispid 34;
    procedure SetGraphOpt(hGraph: Integer; opt: Integer; mask: Integer); dispid 35;
    procedure SetPageOpt(hPage: Integer; opt: Integer; mask: Integer); dispid 36;
    function LoadSession(const path: WideString): Integer; dispid 37;
    function SaveSession(const path: WideString): Integer; dispid 38;
    function Locate(hGrItem: Integer): IDispatch; dispid 39;
    procedure GetXMinMax(hGR: Integer; out pmin: Double; out pmax: Double); dispid 40;
    procedure GetYAxisMinMax(hAxis: Integer; var pmin: Double; var pmax: Double); dispid 41;
    procedure SetAxisOpt(hGraph: Integer; hAxis: Integer; opt: Integer; mask: Integer; 
                         minR: Double; maxR: Double; const szname: WideString; 
                         const szftempl: WideString; color: Integer); dispid 42;
    procedure GetAxisOpt(hGraph: Integer; hAxis: Integer; var opt: Integer; var minR: Double; 
                         var maxR: Double; var szname: WideString; var szftempl: WideString; 
                         var color: Integer); dispid 43;
    function CreateYAxis(hGR: Integer): Integer; dispid 44;
    procedure DestroyYAxis(hAx: Integer); dispid 45;
    procedure GetXCursorPos(hGR: Integer; out px: Double; bSecond: WordBool); dispid 46;
    procedure SetXCursorPos(hGR: Integer; x: Double; bSecond: WordBool); dispid 47;
    procedure AddLabel(hLine: Integer; mode: Integer; x: Double; offsX: Double; offsY: Double; 
                       const text: WideString); dispid 48;
    procedure AddComment(hGR: Integer; const text: WideString; x: Double; y: Double; dx: Double; 
                         dy: Double); dispid 49;
    procedure ShowCursor(hPage: Integer; mode: Integer); dispid 50;
    procedure SetClearBufferFlag(hGraph: Integer; hLine: Integer); dispid 51;
    function GetTrackMode(hPage: Integer): SYSINT; dispid 52;
    procedure GetCurYRange(hLine: Integer; out pymin: Double; out pymax: Double; out pxmin: Double; 
                           out pxmax: Double); dispid 53;
    procedure GetXMinMax_V(hGR: Integer; out pmin: OleVariant; out pmax: OleVariant); dispid 54;
    procedure GetYAxisMinMax_V(hAxis: Integer; var pmin: OleVariant; var pmax: OleVariant); dispid 55;
    procedure GetXCursorPos_V(hGR: Integer; out px: OleVariant; bSecond: WordBool); dispid 56;
    procedure GetCurYRange_V(hLine: Integer; out pymin: OleVariant; out pymax: OleVariant; 
                             out pxmin: OleVariant; out pxmax: OleVariant); dispid 57;
    procedure GetLineOpt(hLine: Integer; out opt: Integer; mask: Integer; out width: Integer; 
                         out color: Integer); dispid 58;
    function GetLineInfo(hGR: Integer; hLine: Integer; ntype: Integer; out pbShow: WordBool): WideString; dispid 59;
    function GetCursorType(hPage: Integer): SYSINT; dispid 60;
    function GetYAxisNum(hLine: Integer): SYSINT; dispid 61;
    function LoadPage(const path: WideString): Integer; dispid 62;
    function SavePage(const path: WideString; hPage: Integer): Integer; dispid 63;
    procedure SetLegendOpt(hGR: Integer; nAlign: Integer; nMode: Integer; nSzX: Integer; 
                           nSzY: Integer); dispid 64;
    procedure GetLegendOpt(hGR: Integer; out pnAlign: Integer; out pnMode: Integer; 
                           out pnSzX: Integer; out pnSzY: Integer); dispid 65;
    procedure GetLegendOpt_V(hGR: Integer; out pnAlign: OleVariant; out pnMode: OleVariant; 
                             out pnSzX: OleVariant; out pnSzY: OleVariant); dispid 66;
    function GetYX(hLn: Integer; x: Double): Double; dispid 67;
    procedure GetZMinMax(hGR: Integer; out pmin: Double; out pmax: Double); dispid 68;
    procedure GetZMinMax_V(hGR: Integer; out pmin: OleVariant; out pmax: OleVariant); dispid 69;
    procedure AddLabel3D(hLine: Integer; mode: Integer; x: Double; z: Double; offsX: Double; 
                         offsZ: Double; const text: WideString); dispid 70;
    function CreatePage2(type_: Integer): Integer; dispid 71;
    function GetLabelCount(hLine: Integer): Integer; dispid 72;
    procedure GetLabelPos(hLine: Integer; iLab: Integer; out x: Double; out z: Double); dispid 73;
    procedure GetLabelPos_V(hLine: Integer; iLab: Integer; out x: OleVariant; out z: OleVariant); dispid 74;
    function GetLineInfo_V(hGR: Integer; hLine: Integer; ntype: Integer; out pbShow: OleVariant): WideString; dispid 75;
    procedure SetZMinMax(hGR: Integer; min: Double; max: Double); dispid 76;
    function GetPageOpt2(hPage: Integer; opt: Integer; out pval: OleVariant): Integer; dispid 77;
    function SetPageOpt2(hPage: Integer; opt: Integer; val: OleVariant): Integer; dispid 78;
    function GetGraphOpt2(hGraph: Integer; opt: Integer; out pval: OleVariant): Integer; dispid 79;
    function SetGraphOpt2(hGraph: Integer; opt: Integer; val: OleVariant): Integer; dispid 80;
    function GetLineOpt2(hLine: Integer; opt: Integer; out pval: OleVariant): Integer; dispid 81;
    function SetLineOpt2(hLine: Integer; opt: Integer; val: OleVariant): Integer; dispid 82;
    function GetAxisOpt2(hGraph: Integer; hAxis: Integer; opt: Integer; out pval: OleVariant): Integer; dispid 83;
    function SetAxisOpt2(hGraph: Integer; hAxis: Integer; opt: Integer; val: OleVariant): Integer; dispid 84;
    function GetLegendOpt2(hGraph: Integer; opt: Integer; out pval: OleVariant): Integer; dispid 85;
    function SetLegendOpt2(hGraph: Integer; opt: Integer; val: OleVariant): Integer; dispid 86;
  end;

// *********************************************************************//
// DispIntf:  IWPOperator
// Flags:     (4096) Dispatchable
// GUID:      {5819D3E4-58AC-4A0F-A24D-A6BCEFC41B56}
// *********************************************************************//
  IWPOperator = dispinterface
    ['{5819D3E4-58AC-4A0F-A24D-A6BCEFC41B56}']
    function Error: Integer; dispid 7;
    function Instance: Integer; dispid 6;
    function RS_GetProgress(var percents: Double; var nErr: SYSINT; var nLenPreview: SYSINT): Integer; dispid 20;
    function getProperty(const Name: WideString): OleVariant; dispid 12;
    function Info(kind: Integer): WideString; dispid 5;
    function Exec(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer; dispid 10;
    function valid(src1: OleVariant; src2: OleVariant; dst1: OleVariant; dst2: OleVariant): Integer; dispid 9;
    function MsgError: WideString; dispid 8;
    procedure setProperty(const Name: WideString; Value: OleVariant); dispid 11;
    procedure RS_SetPreviewFile(fnpreview: {??PWideChar}OleVariant); dispid 19;
    function SetupDlg: Integer; dispid 15;
    function getProperySet: WideString; dispid 13;
    function getPropertyValues: WideString; dispid 16;
    function RS_Exec(src1: OleVariant; src2: OleVariant): Integer; dispid 17;
    procedure loadProperties(const values: WideString); dispid 14;
    function Clone: IDispatch; dispid 23;
    function RS_SendCommand(nCommand: SYSINT): Integer; dispid 21;
    function RS_GetResults(dst1: OleVariant; dst2: OleVariant): Integer; dispid 18;
    function SetExecOpt(nOpt: SYSINT): SYSINT; dispid 22;
    property ndst: Integer dispid 4;
    property nsrc: Integer dispid 3;
    property Fullname: WideString dispid 2;
    property Name: WideString dispid 1;
  end;

// *********************************************************************//
// DispIntf:  IWPOpManager
// Flags:     (4096) Dispatchable
// GUID:      {7102D9F6-913A-41DF-A60D-7B36DD28D150}
// *********************************************************************//
  IWPOpManager = dispinterface
    ['{7102D9F6-913A-41DF-A60D-7B36DD28D150}']
    function Get(index: Integer): IDispatch; dispid 2;
    function Instance: Integer; dispid 3;
    property count: Integer dispid 1;
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
// DispIntf:  IWPFileDialog
// Flags:     (4096) Dispatchable
// GUID:      {BB5E9128-BD80-4AA8-A77A-8D6C87B2F911}
// *********************************************************************//
  IWPFileDialog = dispinterface
    ['{BB5E9128-BD80-4AA8-A77A-8D6C87B2F911}']
    function GetFile(index: Integer): WideString; dispid 2;
    function DoModal: Integer; dispid 4;
    procedure Create(isOPen: Integer; const FileName: WideString; const defaultExt: WideString; 
                     const filter: WideString; Options: Integer); dispid 3;
    property FileCount: Integer dispid 1;
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
// DispIntf:  IWPUnits
// Flags:     (4096) Dispatchable
// GUID:      {08EEC529-A39A-4A6D-B2C3-F753AFE2C647}
// *********************************************************************//
  IWPUnits = dispinterface
    ['{08EEC529-A39A-4A6D-B2C3-F753AFE2C647}']
    function GetFuncCount: LongWord; dispid 1;
    function GetFunc(n: LongWord): LongWord; dispid 2;
    function GetFuncName(nFn: LongWord): WideString; dispid 3;
    function GetTypeCount(nFn: LongWord; nAx: LongWord): LongWord; dispid 4;
    function GetType(n: LongWord; nFn: LongWord; nAx: LongWord): LongWord; dispid 5;
    function GetTypeName(nTp: LongWord): WideString; dispid 6;
    function GetUnitsCount(nTp: LongWord): LongWord; dispid 7;
    function GetUnits(n: LongWord; nTp: LongWord): {??Largeuint}OleVariant; dispid 8;
    function GetUnitsByMark(const mark: WideString): {??Largeuint}OleVariant; dispid 9;
    function GetBaseUnits(nTp: LongWord): {??Largeuint}OleVariant; dispid 10;
    function GetUnitsName(nUn: {??Largeuint}OleVariant): WideString; dispid 11;
    function GetUnitsMark(nUn: {??Largeuint}OleVariant): WideString; dispid 12;
    function ConvertValue(nUnSrc: {??Largeuint}OleVariant; nUnDst: {??Largeuint}OleVariant; 
                          Value: Double): Double; dispid 20;
    procedure GetCoefs(nUnSrc: {??Largeuint}OleVariant; nUnDst: {??Largeuint}OleVariant; 
                       var pK1: Double; var pK0: Double); dispid 21;
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
// The Class CoCOleWPFileDialog provides a Create and CreateRemote method to          
// create instances of the default interface IWPFileDialog exposed by              
// the CoClass COleWPFileDialog. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCOleWPFileDialog = class
    class function Create: IWPFileDialog;
    class function CreateRemote(const MachineName: string): IWPFileDialog;
  end;

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
// The Class CoWPUnits provides a Create and CreateRemote method to          
// create instances of the default interface IWPUnits exposed by              
// the CoClass WPUnits. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWPUnits = class
    class function Create: IWPUnits;
    class function CreateRemote(const MachineName: string): IWPUnits;
  end;

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

class function CoWPSignal.Create: IWPSignal;
begin
  Result := CreateComObject(CLASS_WPSignal) as IWPSignal;
end;

class function CoWPSignal.CreateRemote(const MachineName: string): IWPSignal;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPSignal) as IWPSignal;
end;

class function CoWPUSML.Create: IWPUSML;
begin
  Result := CreateComObject(CLASS_WPUSML) as IWPUSML;
end;

class function CoWPUSML.CreateRemote(const MachineName: string): IWPUSML;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPUSML) as IWPUSML;
end;

class function CoWPNode.Create: IWPNode;
begin
  Result := CreateComObject(CLASS_WPNode) as IWPNode;
end;

class function CoWPNode.CreateRemote(const MachineName: string): IWPNode;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPNode) as IWPNode;
end;

class function CoWPGraphs.Create: IWPGraphs;
begin
  Result := CreateComObject(CLASS_WPGraphs) as IWPGraphs;
end;

class function CoWPGraphs.CreateRemote(const MachineName: string): IWPGraphs;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPGraphs) as IWPGraphs;
end;

class function CoWPOperator.Create: IWPOperator;
begin
  Result := CreateComObject(CLASS_WPOperator) as IWPOperator;
end;

class function CoWPOperator.CreateRemote(const MachineName: string): IWPOperator;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPOperator) as IWPOperator;
end;

class function CoWPOpManager.Create: IWPOpManager;
begin
  Result := CreateComObject(CLASS_WPOpManager) as IWPOpManager;
end;

class function CoWPOpManager.CreateRemote(const MachineName: string): IWPOpManager;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPOpManager) as IWPOpManager;
end;

class function CoWPTree.Create: IWPTree;
begin
  Result := CreateComObject(CLASS_WPTree) as IWPTree;
end;

class function CoWPTree.CreateRemote(const MachineName: string): IWPTree;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPTree) as IWPTree;
end;

class function CoWPObject.Create: IWPObject;
begin
  Result := CreateComObject(CLASS_WPObject) as IWPObject;
end;

class function CoWPObject.CreateRemote(const MachineName: string): IWPObject;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPObject) as IWPObject;
end;

class function CoCOleWPFileDialog.Create: IWPFileDialog;
begin
  Result := CreateComObject(CLASS_COleWPFileDialog) as IWPFileDialog;
end;

class function CoCOleWPFileDialog.CreateRemote(const MachineName: string): IWPFileDialog;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_COleWPFileDialog) as IWPFileDialog;
end;

class function CoWPDlgChSignal.Create: IWPDlgChSignal;
begin
  Result := CreateComObject(CLASS_WPDlgChSignal) as IWPDlgChSignal;
end;

class function CoWPDlgChSignal.CreateRemote(const MachineName: string): IWPDlgChSignal;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPDlgChSignal) as IWPDlgChSignal;
end;

class function CoWPUnits.Create: IWPUnits;
begin
  Result := CreateComObject(CLASS_WPUnits) as IWPUnits;
end;

class function CoWPUnits.CreateRemote(const MachineName: string): IWPUnits;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WPUnits) as IWPUnits;
end;

end.
