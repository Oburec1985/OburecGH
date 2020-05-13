unit MSScriptControl_TLB;

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
// File generated on 01.07.2015 17:40:46 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\WINDOWS\system32\msscript.ocx (1)
// LIBID: {0E59F1D2-1FBE-11D0-8FF2-00A0D10038BC}
// LCID: 0
// Helpfile: D:\WINDOWS\system32\MSSCRIPT.HLP
// HelpString: Microsoft Script Control 1.0
// DepndLst: 
//   (1) v2.0 stdole, (D:\WINDOWS\system32\stdole2.tlb)
// Errors:
//   Hint: TypeInfo 'Procedure' changed to 'Procedure_'
//   Hint: Parameter 'Object' of IScriptModuleCollection.Add changed to 'Object_'
//   Hint: Parameter 'Object' of IScriptControl.AddObject changed to 'Object_'
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
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  MSScriptControlMajorVersion = 1;
  MSScriptControlMinorVersion = 0;

  LIBID_MSScriptControl: TGUID = '{0E59F1D2-1FBE-11D0-8FF2-00A0D10038BC}';

  IID_IScriptProcedure: TGUID = '{70841C73-067D-11D0-95D8-00A02463AB28}';
  IID_IScriptProcedureCollection: TGUID = '{70841C71-067D-11D0-95D8-00A02463AB28}';
  IID_IScriptModule: TGUID = '{70841C70-067D-11D0-95D8-00A02463AB28}';
  IID_IScriptModuleCollection: TGUID = '{70841C6F-067D-11D0-95D8-00A02463AB28}';
  IID_IScriptError: TGUID = '{70841C78-067D-11D0-95D8-00A02463AB28}';
  IID_IScriptControl: TGUID = '{0E59F1D3-1FBE-11D0-8FF2-00A0D10038BC}';
  DIID_DScriptControlSource: TGUID = '{8B167D60-8605-11D0-ABCB-00A0C90FFFC0}';
  CLASS_Procedure_: TGUID = '{0E59F1DA-1FBE-11D0-8FF2-00A0D10038BC}';
  CLASS_Procedures: TGUID = '{0E59F1DB-1FBE-11D0-8FF2-00A0D10038BC}';
  CLASS_Module: TGUID = '{0E59F1DC-1FBE-11D0-8FF2-00A0D10038BC}';
  CLASS_Modules: TGUID = '{0E59F1DD-1FBE-11D0-8FF2-00A0D10038BC}';
  CLASS_Error: TGUID = '{0E59F1DE-1FBE-11D0-8FF2-00A0D10038BC}';
  CLASS_ScriptControl: TGUID = '{0E59F1D5-1FBE-11D0-8FF2-00A0D10038BC}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum ScriptControlStates
type
  ScriptControlStates = TOleEnum;
const
  Initialized = $00000000;
  Connected = $00000001;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IScriptProcedure = interface;
  IScriptProcedureDisp = dispinterface;
  IScriptProcedureCollection = interface;
  IScriptProcedureCollectionDisp = dispinterface;
  IScriptModule = interface;
  IScriptModuleDisp = dispinterface;
  IScriptModuleCollection = interface;
  IScriptModuleCollectionDisp = dispinterface;
  IScriptError = interface;
  IScriptErrorDisp = dispinterface;
  IScriptControl = interface;
  IScriptControlDisp = dispinterface;
  DScriptControlSource = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Procedure_ = IScriptProcedure;
  Procedures = IScriptProcedureCollection;
  Module = IScriptModule;
  Modules = IScriptModuleCollection;
  Error = IScriptError;
  ScriptControl = IScriptControl;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PPSafeArray1 = ^PSafeArray; {*}
  POleVariant1 = ^OleVariant; {*}


// *********************************************************************//
// Interface: IScriptProcedure
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C73-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptProcedure = interface(IDispatch)
    ['{70841C73-067D-11D0-95D8-00A02463AB28}']
    function Get_Name: WideString; safecall;
    function Get_NumArgs: Integer; safecall;
    function Get_HasReturnValue: WordBool; safecall;
    property Name: WideString read Get_Name;
    property NumArgs: Integer read Get_NumArgs;
    property HasReturnValue: WordBool read Get_HasReturnValue;
  end;

// *********************************************************************//
// DispIntf:  IScriptProcedureDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C73-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptProcedureDisp = dispinterface
    ['{70841C73-067D-11D0-95D8-00A02463AB28}']
    property Name: WideString readonly dispid 0;
    property NumArgs: Integer readonly dispid 100;
    property HasReturnValue: WordBool readonly dispid 101;
  end;

// *********************************************************************//
// Interface: IScriptProcedureCollection
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C71-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptProcedureCollection = interface(IDispatch)
    ['{70841C71-067D-11D0-95D8-00A02463AB28}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(Index: OleVariant): IScriptProcedure; safecall;
    function Get_Count: Integer; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[Index: OleVariant]: IScriptProcedure read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IScriptProcedureCollectionDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C71-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptProcedureCollectionDisp = dispinterface
    ['{70841C71-067D-11D0-95D8-00A02463AB28}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[Index: OleVariant]: IScriptProcedure readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IScriptModule
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C70-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptModule = interface(IDispatch)
    ['{70841C70-067D-11D0-95D8-00A02463AB28}']
    function Get_Name: WideString; safecall;
    function Get_CodeObject: IDispatch; safecall;
    function Get_Procedures: IScriptProcedureCollection; safecall;
    procedure AddCode(const Code: WideString); safecall;
    function Eval(const Expression: WideString): OleVariant; safecall;
    procedure ExecuteStatement(const Statement: WideString); safecall;
    function Run(const ProcedureName: WideString; var Parameters: PSafeArray): OleVariant; safecall;
    property Name: WideString read Get_Name;
    property CodeObject: IDispatch read Get_CodeObject;
    property Procedures: IScriptProcedureCollection read Get_Procedures;
  end;

// *********************************************************************//
// DispIntf:  IScriptModuleDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C70-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptModuleDisp = dispinterface
    ['{70841C70-067D-11D0-95D8-00A02463AB28}']
    property Name: WideString readonly dispid 0;
    property CodeObject: IDispatch readonly dispid 1000;
    property Procedures: IScriptProcedureCollection readonly dispid 1001;
    procedure AddCode(const Code: WideString); dispid 2000;
    function Eval(const Expression: WideString): OleVariant; dispid 2001;
    procedure ExecuteStatement(const Statement: WideString); dispid 2002;
    function Run(const ProcedureName: WideString; var Parameters: {??PSafeArray}OleVariant): OleVariant; dispid 2003;
  end;

// *********************************************************************//
// Interface: IScriptModuleCollection
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C6F-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptModuleCollection = interface(IDispatch)
    ['{70841C6F-067D-11D0-95D8-00A02463AB28}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(Index: OleVariant): IScriptModule; safecall;
    function Get_Count: Integer; safecall;
    function Add(const Name: WideString; var Object_: OleVariant): IScriptModule; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[Index: OleVariant]: IScriptModule read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IScriptModuleCollectionDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C6F-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptModuleCollectionDisp = dispinterface
    ['{70841C6F-067D-11D0-95D8-00A02463AB28}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[Index: OleVariant]: IScriptModule readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    function Add(const Name: WideString; var Object_: OleVariant): IScriptModule; dispid 2;
  end;

// *********************************************************************//
// Interface: IScriptError
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C78-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptError = interface(IDispatch)
    ['{70841C78-067D-11D0-95D8-00A02463AB28}']
    function Get_Number: Integer; safecall;
    function Get_Source: WideString; safecall;
    function Get_Description: WideString; safecall;
    function Get_HelpFile: WideString; safecall;
    function Get_HelpContext: Integer; safecall;
    function Get_Text: WideString; safecall;
    function Get_Line: Integer; safecall;
    function Get_Column: Integer; safecall;
    procedure Clear; safecall;
    property Number: Integer read Get_Number;
    property Source: WideString read Get_Source;
    property Description: WideString read Get_Description;
    property HelpFile: WideString read Get_HelpFile;
    property HelpContext: Integer read Get_HelpContext;
    property Text: WideString read Get_Text;
    property Line: Integer read Get_Line;
    property Column: Integer read Get_Column;
  end;

// *********************************************************************//
// DispIntf:  IScriptErrorDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {70841C78-067D-11D0-95D8-00A02463AB28}
// *********************************************************************//
  IScriptErrorDisp = dispinterface
    ['{70841C78-067D-11D0-95D8-00A02463AB28}']
    property Number: Integer readonly dispid 201;
    property Source: WideString readonly dispid 202;
    property Description: WideString readonly dispid 203;
    property HelpFile: WideString readonly dispid 204;
    property HelpContext: Integer readonly dispid 205;
    property Text: WideString readonly dispid -517;
    property Line: Integer readonly dispid 206;
    property Column: Integer readonly dispid -529;
    procedure Clear; dispid 208;
  end;

// *********************************************************************//
// Interface: IScriptControl
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0E59F1D3-1FBE-11D0-8FF2-00A0D10038BC}
// *********************************************************************//
  IScriptControl = interface(IDispatch)
    ['{0E59F1D3-1FBE-11D0-8FF2-00A0D10038BC}']
    function Get_Language: WideString; safecall;
    procedure Set_Language(const pbstrLanguage: WideString); safecall;
    function Get_State: ScriptControlStates; safecall;
    procedure Set_State(pssState: ScriptControlStates); safecall;
    procedure Set_SitehWnd(phwnd: Integer); safecall;
    function Get_SitehWnd: Integer; safecall;
    function Get_Timeout: Integer; safecall;
    procedure Set_Timeout(plMilleseconds: Integer); safecall;
    function Get_AllowUI: WordBool; safecall;
    procedure Set_AllowUI(pfAllowUI: WordBool); safecall;
    function Get_UseSafeSubset: WordBool; safecall;
    procedure Set_UseSafeSubset(pfUseSafeSubset: WordBool); safecall;
    function Get_Modules: IScriptModuleCollection; safecall;
    function Get_Error: IScriptError; safecall;
    function Get_CodeObject: IDispatch; safecall;
    function Get_Procedures: IScriptProcedureCollection; safecall;
    procedure _AboutBox; safecall;
    procedure AddObject(const Name: WideString; const Object_: IDispatch; AddMembers: WordBool); safecall;
    procedure Reset; safecall;
    procedure AddCode(const Code: WideString); safecall;
    function Eval(const Expression: WideString): OleVariant; safecall;
    procedure ExecuteStatement(const Statement: WideString); safecall;
    function Run(const ProcedureName: WideString; var Parameters: PSafeArray): OleVariant; safecall;
    property Language: WideString read Get_Language write Set_Language;
    property State: ScriptControlStates read Get_State write Set_State;
    property SitehWnd: Integer read Get_SitehWnd write Set_SitehWnd;
    property Timeout: Integer read Get_Timeout write Set_Timeout;
    property AllowUI: WordBool read Get_AllowUI write Set_AllowUI;
    property UseSafeSubset: WordBool read Get_UseSafeSubset write Set_UseSafeSubset;
    property Modules: IScriptModuleCollection read Get_Modules;
    property Error: IScriptError read Get_Error;
    property CodeObject: IDispatch read Get_CodeObject;
    property Procedures: IScriptProcedureCollection read Get_Procedures;
  end;

// *********************************************************************//
// DispIntf:  IScriptControlDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0E59F1D3-1FBE-11D0-8FF2-00A0D10038BC}
// *********************************************************************//
  IScriptControlDisp = dispinterface
    ['{0E59F1D3-1FBE-11D0-8FF2-00A0D10038BC}']
    property Language: WideString dispid 1500;
    property State: ScriptControlStates dispid 1501;
    property SitehWnd: Integer dispid 1502;
    property Timeout: Integer dispid 1503;
    property AllowUI: WordBool dispid 1504;
    property UseSafeSubset: WordBool dispid 1505;
    property Modules: IScriptModuleCollection readonly dispid 1506;
    property Error: IScriptError readonly dispid 1507;
    property CodeObject: IDispatch readonly dispid 1000;
    property Procedures: IScriptProcedureCollection readonly dispid 1001;
    procedure _AboutBox; dispid -552;
    procedure AddObject(const Name: WideString; const Object_: IDispatch; AddMembers: WordBool); dispid 2500;
    procedure Reset; dispid 2501;
    procedure AddCode(const Code: WideString); dispid 2000;
    function Eval(const Expression: WideString): OleVariant; dispid 2001;
    procedure ExecuteStatement(const Statement: WideString); dispid 2002;
    function Run(const ProcedureName: WideString; var Parameters: {??PSafeArray}OleVariant): OleVariant; dispid 2003;
  end;

// *********************************************************************//
// DispIntf:  DScriptControlSource
// Flags:     (4112) Hidden Dispatchable
// GUID:      {8B167D60-8605-11D0-ABCB-00A0C90FFFC0}
// *********************************************************************//
  DScriptControlSource = dispinterface
    ['{8B167D60-8605-11D0-ABCB-00A0C90FFFC0}']
    procedure Error; dispid 3000;
    procedure Timeout; dispid 3001;
  end;

// *********************************************************************//
// The Class CoProcedure_ provides a Create and CreateRemote method to          
// create instances of the default interface IScriptProcedure exposed by              
// the CoClass Procedure_. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoProcedure_ = class
    class function Create: IScriptProcedure;
    class function CreateRemote(const MachineName: string): IScriptProcedure;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TProcedure_
// Help String      : Describes a procedure
// Default Interface: IScriptProcedure
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TProcedure_Properties= class;
{$ENDIF}
  TProcedure_ = class(TOleServer)
  private
    FIntf: IScriptProcedure;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TProcedure_Properties;
    function GetServerProperties: TProcedure_Properties;
{$ENDIF}
    function GetDefaultInterface: IScriptProcedure;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    function Get_NumArgs: Integer;
    function Get_HasReturnValue: WordBool;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IScriptProcedure);
    procedure Disconnect; override;
    property DefaultInterface: IScriptProcedure read GetDefaultInterface;
    property Name: WideString read Get_Name;
    property NumArgs: Integer read Get_NumArgs;
    property HasReturnValue: WordBool read Get_HasReturnValue;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TProcedure_Properties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TProcedure_
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TProcedure_Properties = class(TPersistent)
  private
    FServer:    TProcedure_;
    function    GetDefaultInterface: IScriptProcedure;
    constructor Create(AServer: TProcedure_);
  protected
    function Get_Name: WideString;
    function Get_NumArgs: Integer;
    function Get_HasReturnValue: WordBool;
  public
    property DefaultInterface: IScriptProcedure read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoProcedures provides a Create and CreateRemote method to          
// create instances of the default interface IScriptProcedureCollection exposed by              
// the CoClass Procedures. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoProcedures = class
    class function Create: IScriptProcedureCollection;
    class function CreateRemote(const MachineName: string): IScriptProcedureCollection;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TProcedures
// Help String      : Collection of procedures
// Default Interface: IScriptProcedureCollection
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TProceduresProperties= class;
{$ENDIF}
  TProcedures = class(TOleServer)
  private
    FIntf: IScriptProcedureCollection;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TProceduresProperties;
    function GetServerProperties: TProceduresProperties;
{$ENDIF}
    function GetDefaultInterface: IScriptProcedureCollection;
  protected
    procedure InitServerData; override;
    function Get__NewEnum: IUnknown;
    function Get_Item(Index: OleVariant): IScriptProcedure;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IScriptProcedureCollection);
    procedure Disconnect; override;
    property DefaultInterface: IScriptProcedureCollection read GetDefaultInterface;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[Index: OleVariant]: IScriptProcedure read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TProceduresProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TProcedures
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TProceduresProperties = class(TPersistent)
  private
    FServer:    TProcedures;
    function    GetDefaultInterface: IScriptProcedureCollection;
    constructor Create(AServer: TProcedures);
  protected
    function Get__NewEnum: IUnknown;
    function Get_Item(Index: OleVariant): IScriptProcedure;
    function Get_Count: Integer;
  public
    property DefaultInterface: IScriptProcedureCollection read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoModule provides a Create and CreateRemote method to          
// create instances of the default interface IScriptModule exposed by              
// the CoClass Module. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoModule = class
    class function Create: IScriptModule;
    class function CreateRemote(const MachineName: string): IScriptModule;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TModule
// Help String      : Context in which functions can be defined and expressions can be evaluated
// Default Interface: IScriptModule
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TModuleProperties= class;
{$ENDIF}
  TModule = class(TOleServer)
  private
    FIntf: IScriptModule;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TModuleProperties;
    function GetServerProperties: TModuleProperties;
{$ENDIF}
    function GetDefaultInterface: IScriptModule;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    function Get_CodeObject: IDispatch;
    function Get_Procedures: IScriptProcedureCollection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IScriptModule);
    procedure Disconnect; override;
    procedure AddCode(const Code: WideString);
    function Eval(const Expression: WideString): OleVariant;
    procedure ExecuteStatement(const Statement: WideString);
    function Run(const ProcedureName: WideString; var Parameters: PSafeArray): OleVariant;
    property DefaultInterface: IScriptModule read GetDefaultInterface;
    property Name: WideString read Get_Name;
    property CodeObject: IDispatch read Get_CodeObject;
    property Procedures: IScriptProcedureCollection read Get_Procedures;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TModuleProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TModule
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TModuleProperties = class(TPersistent)
  private
    FServer:    TModule;
    function    GetDefaultInterface: IScriptModule;
    constructor Create(AServer: TModule);
  protected
    function Get_Name: WideString;
    function Get_CodeObject: IDispatch;
    function Get_Procedures: IScriptProcedureCollection;
  public
    property DefaultInterface: IScriptModule read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoModules provides a Create and CreateRemote method to          
// create instances of the default interface IScriptModuleCollection exposed by              
// the CoClass Modules. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoModules = class
    class function Create: IScriptModuleCollection;
    class function CreateRemote(const MachineName: string): IScriptModuleCollection;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TModules
// Help String      : Collection of modules
// Default Interface: IScriptModuleCollection
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TModulesProperties= class;
{$ENDIF}
  TModules = class(TOleServer)
  private
    FIntf: IScriptModuleCollection;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TModulesProperties;
    function GetServerProperties: TModulesProperties;
{$ENDIF}
    function GetDefaultInterface: IScriptModuleCollection;
  protected
    procedure InitServerData; override;
    function Get__NewEnum: IUnknown;
    function Get_Item(Index: OleVariant): IScriptModule;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IScriptModuleCollection);
    procedure Disconnect; override;
    function Add(const Name: WideString): IScriptModule; overload;
    function Add(const Name: WideString; var Object_: OleVariant): IScriptModule; overload;
    property DefaultInterface: IScriptModuleCollection read GetDefaultInterface;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[Index: OleVariant]: IScriptModule read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TModulesProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TModules
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TModulesProperties = class(TPersistent)
  private
    FServer:    TModules;
    function    GetDefaultInterface: IScriptModuleCollection;
    constructor Create(AServer: TModules);
  protected
    function Get__NewEnum: IUnknown;
    function Get_Item(Index: OleVariant): IScriptModule;
    function Get_Count: Integer;
  public
    property DefaultInterface: IScriptModuleCollection read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoError provides a Create and CreateRemote method to          
// create instances of the default interface IScriptError exposed by              
// the CoClass Error. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoError = class
    class function Create: IScriptError;
    class function CreateRemote(const MachineName: string): IScriptError;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TError
// Help String      : Provides access to scripting error information
// Default Interface: IScriptError
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TErrorProperties= class;
{$ENDIF}
  TError = class(TOleServer)
  private
    FIntf: IScriptError;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TErrorProperties;
    function GetServerProperties: TErrorProperties;
{$ENDIF}
    function GetDefaultInterface: IScriptError;
  protected
    procedure InitServerData; override;
    function Get_Number: Integer;
    function Get_Source: WideString;
    function Get_Description: WideString;
    function Get_HelpFile: WideString;
    function Get_HelpContext: Integer;
    function Get_Text: WideString;
    function Get_Line: Integer;
    function Get_Column: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IScriptError);
    procedure Disconnect; override;
    procedure Clear;
    property DefaultInterface: IScriptError read GetDefaultInterface;
    property Number: Integer read Get_Number;
    property Source: WideString read Get_Source;
    property Description: WideString read Get_Description;
    property HelpFile: WideString read Get_HelpFile;
    property HelpContext: Integer read Get_HelpContext;
    property Text: WideString read Get_Text;
    property Line: Integer read Get_Line;
    property Column: Integer read Get_Column;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TErrorProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TError
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TErrorProperties = class(TPersistent)
  private
    FServer:    TError;
    function    GetDefaultInterface: IScriptError;
    constructor Create(AServer: TError);
  protected
    function Get_Number: Integer;
    function Get_Source: WideString;
    function Get_Description: WideString;
    function Get_HelpFile: WideString;
    function Get_HelpContext: Integer;
    function Get_Text: WideString;
    function Get_Line: Integer;
    function Get_Column: Integer;
  public
    property DefaultInterface: IScriptError read GetDefaultInterface;
  published
  end;
{$ENDIF}



// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TScriptControl
// Help String      : Control to host scripting engines that understand the ActiveX Scripting interface
// Default Interface: IScriptControl
// Def. Intf. DISP? : No
// Event   Interface: DScriptControlSource
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TScriptControl = class(TOleControl)
  private
    FOnError: TNotifyEvent;
    FOnTimeout: TNotifyEvent;
    FIntf: IScriptControl;
    function  GetControlInterface: IScriptControl;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function Get_Modules: IScriptModuleCollection;
    function Get_Error: IScriptError;
    function Get_CodeObject: IDispatch;
    function Get_Procedures: IScriptProcedureCollection;
  public
    procedure _AboutBox;
    procedure AddObject(const Name: WideString; const Object_: IDispatch; AddMembers: WordBool);
    procedure Reset;
    procedure AddCode(const Code: WideString);
    function Eval(const Expression: WideString): OleVariant;
    procedure ExecuteStatement(const Statement: WideString);
    function Run(const ProcedureName: WideString; var Parameters: PSafeArray): OleVariant;
    property  ControlInterface: IScriptControl read GetControlInterface;
    property  DefaultInterface: IScriptControl read GetControlInterface;
    property Modules: IScriptModuleCollection read Get_Modules;
    property Error: IScriptError read Get_Error;
    property CodeObject: IDispatch index 1000 read GetIDispatchProp;
    property Procedures: IScriptProcedureCollection read Get_Procedures;
  published
    property Anchors;
    property Language: WideString index 1500 read GetWideStringProp write SetWideStringProp stored False;
    property State: TOleEnum index 1501 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property SitehWnd: Integer index 1502 read GetIntegerProp write SetIntegerProp stored False;
    property Timeout: Integer index 1503 read GetIntegerProp write SetIntegerProp stored False;
    property AllowUI: WordBool index 1504 read GetWordBoolProp write SetWordBoolProp stored False;
    property UseSafeSubset: WordBool index 1505 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnError: TNotifyEvent read FOnError write FOnError;
    property OnTimeout: TNotifyEvent read FOnTimeout write FOnTimeout;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoProcedure_.Create: IScriptProcedure;
begin
  Result := CreateComObject(CLASS_Procedure_) as IScriptProcedure;
end;

class function CoProcedure_.CreateRemote(const MachineName: string): IScriptProcedure;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Procedure_) as IScriptProcedure;
end;

procedure TProcedure_.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0E59F1DA-1FBE-11D0-8FF2-00A0D10038BC}';
    IntfIID:   '{70841C73-067D-11D0-95D8-00A02463AB28}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TProcedure_.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IScriptProcedure;
  end;
end;

procedure TProcedure_.ConnectTo(svrIntf: IScriptProcedure);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TProcedure_.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TProcedure_.GetDefaultInterface: IScriptProcedure;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TProcedure_.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TProcedure_Properties.Create(Self);
{$ENDIF}
end;

destructor TProcedure_.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TProcedure_.GetServerProperties: TProcedure_Properties;
begin
  Result := FProps;
end;
{$ENDIF}

function TProcedure_.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TProcedure_.Get_NumArgs: Integer;
begin
    Result := DefaultInterface.NumArgs;
end;

function TProcedure_.Get_HasReturnValue: WordBool;
begin
    Result := DefaultInterface.HasReturnValue;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TProcedure_Properties.Create(AServer: TProcedure_);
begin
  inherited Create;
  FServer := AServer;
end;

function TProcedure_Properties.GetDefaultInterface: IScriptProcedure;
begin
  Result := FServer.DefaultInterface;
end;

function TProcedure_Properties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TProcedure_Properties.Get_NumArgs: Integer;
begin
    Result := DefaultInterface.NumArgs;
end;

function TProcedure_Properties.Get_HasReturnValue: WordBool;
begin
    Result := DefaultInterface.HasReturnValue;
end;

{$ENDIF}

class function CoProcedures.Create: IScriptProcedureCollection;
begin
  Result := CreateComObject(CLASS_Procedures) as IScriptProcedureCollection;
end;

class function CoProcedures.CreateRemote(const MachineName: string): IScriptProcedureCollection;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Procedures) as IScriptProcedureCollection;
end;

procedure TProcedures.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0E59F1DB-1FBE-11D0-8FF2-00A0D10038BC}';
    IntfIID:   '{70841C71-067D-11D0-95D8-00A02463AB28}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TProcedures.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IScriptProcedureCollection;
  end;
end;

procedure TProcedures.ConnectTo(svrIntf: IScriptProcedureCollection);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TProcedures.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TProcedures.GetDefaultInterface: IScriptProcedureCollection;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TProcedures.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TProceduresProperties.Create(Self);
{$ENDIF}
end;

destructor TProcedures.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TProcedures.GetServerProperties: TProceduresProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TProcedures.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TProcedures.Get_Item(Index: OleVariant): IScriptProcedure;
begin
    Result := DefaultInterface.Item[Index];
end;

function TProcedures.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TProceduresProperties.Create(AServer: TProcedures);
begin
  inherited Create;
  FServer := AServer;
end;

function TProceduresProperties.GetDefaultInterface: IScriptProcedureCollection;
begin
  Result := FServer.DefaultInterface;
end;

function TProceduresProperties.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TProceduresProperties.Get_Item(Index: OleVariant): IScriptProcedure;
begin
    Result := DefaultInterface.Item[Index];
end;

function TProceduresProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoModule.Create: IScriptModule;
begin
  Result := CreateComObject(CLASS_Module) as IScriptModule;
end;

class function CoModule.CreateRemote(const MachineName: string): IScriptModule;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Module) as IScriptModule;
end;

procedure TModule.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0E59F1DC-1FBE-11D0-8FF2-00A0D10038BC}';
    IntfIID:   '{70841C70-067D-11D0-95D8-00A02463AB28}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TModule.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IScriptModule;
  end;
end;

procedure TModule.ConnectTo(svrIntf: IScriptModule);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TModule.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TModule.GetDefaultInterface: IScriptModule;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TModule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TModuleProperties.Create(Self);
{$ENDIF}
end;

destructor TModule.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TModule.GetServerProperties: TModuleProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TModule.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TModule.Get_CodeObject: IDispatch;
begin
    Result := DefaultInterface.CodeObject;
end;

function TModule.Get_Procedures: IScriptProcedureCollection;
begin
    Result := DefaultInterface.Procedures;
end;

procedure TModule.AddCode(const Code: WideString);
begin
  DefaultInterface.AddCode(Code);
end;

function TModule.Eval(const Expression: WideString): OleVariant;
begin
  Result := DefaultInterface.Eval(Expression);
end;

procedure TModule.ExecuteStatement(const Statement: WideString);
begin
  DefaultInterface.ExecuteStatement(Statement);
end;

function TModule.Run(const ProcedureName: WideString; var Parameters: PSafeArray): OleVariant;
begin
  Result := DefaultInterface.Run(ProcedureName, Parameters);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TModuleProperties.Create(AServer: TModule);
begin
  inherited Create;
  FServer := AServer;
end;

function TModuleProperties.GetDefaultInterface: IScriptModule;
begin
  Result := FServer.DefaultInterface;
end;

function TModuleProperties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TModuleProperties.Get_CodeObject: IDispatch;
begin
    Result := DefaultInterface.CodeObject;
end;

function TModuleProperties.Get_Procedures: IScriptProcedureCollection;
begin
    Result := DefaultInterface.Procedures;
end;

{$ENDIF}

class function CoModules.Create: IScriptModuleCollection;
begin
  Result := CreateComObject(CLASS_Modules) as IScriptModuleCollection;
end;

class function CoModules.CreateRemote(const MachineName: string): IScriptModuleCollection;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Modules) as IScriptModuleCollection;
end;

procedure TModules.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0E59F1DD-1FBE-11D0-8FF2-00A0D10038BC}';
    IntfIID:   '{70841C6F-067D-11D0-95D8-00A02463AB28}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TModules.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IScriptModuleCollection;
  end;
end;

procedure TModules.ConnectTo(svrIntf: IScriptModuleCollection);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TModules.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TModules.GetDefaultInterface: IScriptModuleCollection;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TModules.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TModulesProperties.Create(Self);
{$ENDIF}
end;

destructor TModules.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TModules.GetServerProperties: TModulesProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TModules.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TModules.Get_Item(Index: OleVariant): IScriptModule;
begin
    Result := DefaultInterface.Item[Index];
end;

function TModules.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TModules.Add(const Name: WideString): IScriptModule;
begin
  Result := DefaultInterface.Add(Name, EmptyParam);
end;

function TModules.Add(const Name: WideString; var Object_: OleVariant): IScriptModule;
begin
  Result := DefaultInterface.Add(Name, Object_);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TModulesProperties.Create(AServer: TModules);
begin
  inherited Create;
  FServer := AServer;
end;

function TModulesProperties.GetDefaultInterface: IScriptModuleCollection;
begin
  Result := FServer.DefaultInterface;
end;

function TModulesProperties.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

function TModulesProperties.Get_Item(Index: OleVariant): IScriptModule;
begin
    Result := DefaultInterface.Item[Index];
end;

function TModulesProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoError.Create: IScriptError;
begin
  Result := CreateComObject(CLASS_Error) as IScriptError;
end;

class function CoError.CreateRemote(const MachineName: string): IScriptError;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Error) as IScriptError;
end;

procedure TError.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0E59F1DE-1FBE-11D0-8FF2-00A0D10038BC}';
    IntfIID:   '{70841C78-067D-11D0-95D8-00A02463AB28}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TError.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IScriptError;
  end;
end;

procedure TError.ConnectTo(svrIntf: IScriptError);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TError.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TError.GetDefaultInterface: IScriptError;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TError.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TErrorProperties.Create(Self);
{$ENDIF}
end;

destructor TError.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TError.GetServerProperties: TErrorProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TError.Get_Number: Integer;
begin
    Result := DefaultInterface.Number;
end;

function TError.Get_Source: WideString;
begin
    Result := DefaultInterface.Source;
end;

function TError.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

function TError.Get_HelpFile: WideString;
begin
    Result := DefaultInterface.HelpFile;
end;

function TError.Get_HelpContext: Integer;
begin
    Result := DefaultInterface.HelpContext;
end;

function TError.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

function TError.Get_Line: Integer;
begin
    Result := DefaultInterface.Line;
end;

function TError.Get_Column: Integer;
begin
    Result := DefaultInterface.Column;
end;

procedure TError.Clear;
begin
  DefaultInterface.Clear;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TErrorProperties.Create(AServer: TError);
begin
  inherited Create;
  FServer := AServer;
end;

function TErrorProperties.GetDefaultInterface: IScriptError;
begin
  Result := FServer.DefaultInterface;
end;

function TErrorProperties.Get_Number: Integer;
begin
    Result := DefaultInterface.Number;
end;

function TErrorProperties.Get_Source: WideString;
begin
    Result := DefaultInterface.Source;
end;

function TErrorProperties.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

function TErrorProperties.Get_HelpFile: WideString;
begin
    Result := DefaultInterface.HelpFile;
end;

function TErrorProperties.Get_HelpContext: Integer;
begin
    Result := DefaultInterface.HelpContext;
end;

function TErrorProperties.Get_Text: WideString;
begin
    Result := DefaultInterface.Text;
end;

function TErrorProperties.Get_Line: Integer;
begin
    Result := DefaultInterface.Line;
end;

function TErrorProperties.Get_Column: Integer;
begin
    Result := DefaultInterface.Column;
end;

{$ENDIF}

procedure TScriptControl.InitControlData;
const
  CEventDispIDs: array [0..1] of DWORD = (
    $00000BB8, $00000BB9);
  CControlData: TControlData2 = (
    ClassID: '{0E59F1D5-1FBE-11D0-8FF2-00A0D10038BC}';
    EventIID: '{8B167D60-8605-11D0-ABCB-00A0C90FFFC0}';
    EventCount: 2;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnError) - Cardinal(Self);
end;

procedure TScriptControl.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IScriptControl;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TScriptControl.GetControlInterface: IScriptControl;
begin
  CreateControl;
  Result := FIntf;
end;

function TScriptControl.Get_Modules: IScriptModuleCollection;
begin
    Result := DefaultInterface.Modules;
end;

function TScriptControl.Get_Error: IScriptError;
begin
    Result := DefaultInterface.Error;
end;

function TScriptControl.Get_CodeObject: IDispatch;
begin
    Result := DefaultInterface.CodeObject;
end;

function TScriptControl.Get_Procedures: IScriptProcedureCollection;
begin
    Result := DefaultInterface.Procedures;
end;

procedure TScriptControl._AboutBox;
begin
  DefaultInterface._AboutBox;
end;

procedure TScriptControl.AddObject(const Name: WideString; const Object_: IDispatch; 
                                   AddMembers: WordBool);
begin
  DefaultInterface.AddObject(Name, Object_, AddMembers);
end;

procedure TScriptControl.Reset;
begin
  DefaultInterface.Reset;
end;

procedure TScriptControl.AddCode(const Code: WideString);
begin
  DefaultInterface.AddCode(Code);
end;

function TScriptControl.Eval(const Expression: WideString): OleVariant;
begin
  Result := DefaultInterface.Eval(Expression);
end;

procedure TScriptControl.ExecuteStatement(const Statement: WideString);
begin
  DefaultInterface.ExecuteStatement(Statement);
end;

function TScriptControl.Run(const ProcedureName: WideString; var Parameters: PSafeArray): OleVariant;
begin
  Result := DefaultInterface.Run(ProcedureName, Parameters);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TScriptControl]);
  RegisterComponents(dtlServerPage, [TProcedure_, TProcedures, TModule, TModules, 
    TError]);
end;

end.
