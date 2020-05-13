unit VBScript_RegExp_55_TLB;

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
// File generated on 01.07.2015 15:31:49 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\WINDOWS\system32\VBScript.dll\3 (1)
// LIBID: {3F4DACA7-160D-11D2-A8E9-00104B365C9F}
// LCID: 0
// Helpfile: 
// HelpString: Microsoft VBScript Regular Expressions 5.5
// DepndLst: 
//   (1) v2.0 stdole, (D:\WINDOWS\system32\stdole2.tlb)
// Errors:
//   Error creating palette bitmap of (TRegExp) : Server D:\WINDOWS\system32\VBScript.dll contains no icons
//   Error creating palette bitmap of (TMatch) : Server D:\WINDOWS\system32\VBScript.dll contains no icons
//   Error creating palette bitmap of (TMatchCollection) : Server D:\WINDOWS\system32\VBScript.dll contains no icons
//   Error creating palette bitmap of (TSubMatches) : Server D:\WINDOWS\system32\VBScript.dll contains no icons
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
  VBScript_RegExp_55MajorVersion = 5;
  VBScript_RegExp_55MinorVersion = 5;

  LIBID_VBScript_RegExp_55: TGUID = '{3F4DACA7-160D-11D2-A8E9-00104B365C9F}';

  IID_IRegExp: TGUID = '{3F4DACA0-160D-11D2-A8E9-00104B365C9F}';
  IID_IMatch: TGUID = '{3F4DACA1-160D-11D2-A8E9-00104B365C9F}';
  IID_IMatchCollection: TGUID = '{3F4DACA2-160D-11D2-A8E9-00104B365C9F}';
  IID_IRegExp2: TGUID = '{3F4DACB0-160D-11D2-A8E9-00104B365C9F}';
  IID_IMatch2: TGUID = '{3F4DACB1-160D-11D2-A8E9-00104B365C9F}';
  IID_IMatchCollection2: TGUID = '{3F4DACB2-160D-11D2-A8E9-00104B365C9F}';
  IID_ISubMatches: TGUID = '{3F4DACB3-160D-11D2-A8E9-00104B365C9F}';
  CLASS_RegExp: TGUID = '{3F4DACA4-160D-11D2-A8E9-00104B365C9F}';
  CLASS_Match: TGUID = '{3F4DACA5-160D-11D2-A8E9-00104B365C9F}';
  CLASS_MatchCollection: TGUID = '{3F4DACA6-160D-11D2-A8E9-00104B365C9F}';
  CLASS_SubMatches: TGUID = '{3F4DACC0-160D-11D2-A8E9-00104B365C9F}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IRegExp = interface;
  IRegExpDisp = dispinterface;
  IMatch = interface;
  IMatchDisp = dispinterface;
  IMatchCollection = interface;
  IMatchCollectionDisp = dispinterface;
  IRegExp2 = interface;
  IRegExp2Disp = dispinterface;
  IMatch2 = interface;
  IMatch2Disp = dispinterface;
  IMatchCollection2 = interface;
  IMatchCollection2Disp = dispinterface;
  ISubMatches = interface;
  ISubMatchesDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  RegExp = IRegExp2;
  Match = IMatch2;
  MatchCollection = IMatchCollection2;
  SubMatches = ISubMatches;


// *********************************************************************//
// Interface: IRegExp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACA0-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IRegExp = interface(IDispatch)
    ['{3F4DACA0-160D-11D2-A8E9-00104B365C9F}']
    function Get_Pattern: WideString; safecall;
    procedure Set_Pattern(const pPattern: WideString); safecall;
    function Get_IgnoreCase: WordBool; safecall;
    procedure Set_IgnoreCase(pIgnoreCase: WordBool); safecall;
    function Get_Global: WordBool; safecall;
    procedure Set_Global(pGlobal: WordBool); safecall;
    function Execute(const sourceString: WideString): IDispatch; safecall;
    function Test(const sourceString: WideString): WordBool; safecall;
    function Replace(const sourceString: WideString; const replaceString: WideString): WideString; safecall;
    property Pattern: WideString read Get_Pattern write Set_Pattern;
    property IgnoreCase: WordBool read Get_IgnoreCase write Set_IgnoreCase;
    property Global: WordBool read Get_Global write Set_Global;
  end;

// *********************************************************************//
// DispIntf:  IRegExpDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACA0-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IRegExpDisp = dispinterface
    ['{3F4DACA0-160D-11D2-A8E9-00104B365C9F}']
    property Pattern: WideString dispid 10001;
    property IgnoreCase: WordBool dispid 10002;
    property Global: WordBool dispid 10003;
    function Execute(const sourceString: WideString): IDispatch; dispid 10004;
    function Test(const sourceString: WideString): WordBool; dispid 10005;
    function Replace(const sourceString: WideString; const replaceString: WideString): WideString; dispid 10006;
  end;

// *********************************************************************//
// Interface: IMatch
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACA1-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatch = interface(IDispatch)
    ['{3F4DACA1-160D-11D2-A8E9-00104B365C9F}']
    function Get_Value: WideString; safecall;
    function Get_FirstIndex: Integer; safecall;
    function Get_Length: Integer; safecall;
    property Value: WideString read Get_Value;
    property FirstIndex: Integer read Get_FirstIndex;
    property Length: Integer read Get_Length;
  end;

// *********************************************************************//
// DispIntf:  IMatchDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACA1-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatchDisp = dispinterface
    ['{3F4DACA1-160D-11D2-A8E9-00104B365C9F}']
    property Value: WideString readonly dispid 0;
    property FirstIndex: Integer readonly dispid 10001;
    property Length: Integer readonly dispid 10002;
  end;

// *********************************************************************//
// Interface: IMatchCollection
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACA2-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatchCollection = interface(IDispatch)
    ['{3F4DACA2-160D-11D2-A8E9-00104B365C9F}']
    function Get_Item(index: Integer): IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[index: Integer]: IDispatch read Get_Item;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IMatchCollectionDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACA2-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatchCollectionDisp = dispinterface
    ['{3F4DACA2-160D-11D2-A8E9-00104B365C9F}']
    property Item[index: Integer]: IDispatch readonly dispid 10001;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IRegExp2
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB0-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IRegExp2 = interface(IDispatch)
    ['{3F4DACB0-160D-11D2-A8E9-00104B365C9F}']
    function Get_Pattern: WideString; safecall;
    procedure Set_Pattern(const pPattern: WideString); safecall;
    function Get_IgnoreCase: WordBool; safecall;
    procedure Set_IgnoreCase(pIgnoreCase: WordBool); safecall;
    function Get_Global: WordBool; safecall;
    procedure Set_Global(pGlobal: WordBool); safecall;
    function Get_Multiline: WordBool; safecall;
    procedure Set_Multiline(pMultiline: WordBool); safecall;
    function Execute(const sourceString: WideString): IDispatch; safecall;
    function Test(const sourceString: WideString): WordBool; safecall;
    function Replace(const sourceString: WideString; replaceVar: OleVariant): WideString; safecall;
    property Pattern: WideString read Get_Pattern write Set_Pattern;
    property IgnoreCase: WordBool read Get_IgnoreCase write Set_IgnoreCase;
    property Global: WordBool read Get_Global write Set_Global;
    property Multiline: WordBool read Get_Multiline write Set_Multiline;
  end;

// *********************************************************************//
// DispIntf:  IRegExp2Disp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB0-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IRegExp2Disp = dispinterface
    ['{3F4DACB0-160D-11D2-A8E9-00104B365C9F}']
    property Pattern: WideString dispid 10001;
    property IgnoreCase: WordBool dispid 10002;
    property Global: WordBool dispid 10003;
    property Multiline: WordBool dispid 10007;
    function Execute(const sourceString: WideString): IDispatch; dispid 10004;
    function Test(const sourceString: WideString): WordBool; dispid 10005;
    function Replace(const sourceString: WideString; replaceVar: OleVariant): WideString; dispid 10006;
  end;

// *********************************************************************//
// Interface: IMatch2
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB1-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatch2 = interface(IDispatch)
    ['{3F4DACB1-160D-11D2-A8E9-00104B365C9F}']
    function Get_Value: WideString; safecall;
    function Get_FirstIndex: Integer; safecall;
    function Get_Length: Integer; safecall;
    function Get_SubMatches: IDispatch; safecall;
    property Value: WideString read Get_Value;
    property FirstIndex: Integer read Get_FirstIndex;
    property Length: Integer read Get_Length;
    property SubMatches: IDispatch read Get_SubMatches;
  end;

// *********************************************************************//
// DispIntf:  IMatch2Disp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB1-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatch2Disp = dispinterface
    ['{3F4DACB1-160D-11D2-A8E9-00104B365C9F}']
    property Value: WideString readonly dispid 0;
    property FirstIndex: Integer readonly dispid 10001;
    property Length: Integer readonly dispid 10002;
    property SubMatches: IDispatch readonly dispid 10003;
  end;

// *********************************************************************//
// Interface: IMatchCollection2
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB2-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatchCollection2 = interface(IDispatch)
    ['{3F4DACB2-160D-11D2-A8E9-00104B365C9F}']
    function Get_Item(index: Integer): IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[index: Integer]: IDispatch read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IMatchCollection2Disp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB2-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  IMatchCollection2Disp = dispinterface
    ['{3F4DACB2-160D-11D2-A8E9-00104B365C9F}']
    property Item[index: Integer]: IDispatch readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: ISubMatches
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB3-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  ISubMatches = interface(IDispatch)
    ['{3F4DACB3-160D-11D2-A8E9-00104B365C9F}']
    function Get_Item(index: Integer): OleVariant; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[index: Integer]: OleVariant read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  ISubMatchesDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F4DACB3-160D-11D2-A8E9-00104B365C9F}
// *********************************************************************//
  ISubMatchesDisp = dispinterface
    ['{3F4DACB3-160D-11D2-A8E9-00104B365C9F}']
    property Item[index: Integer]: OleVariant readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// The Class CoRegExp provides a Create and CreateRemote method to          
// create instances of the default interface IRegExp2 exposed by              
// the CoClass RegExp. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRegExp = class
    class function Create: IRegExp2;
    class function CreateRemote(const MachineName: string): IRegExp2;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TRegExp
// Help String      : 
// Default Interface: IRegExp2
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TRegExpProperties= class;
{$ENDIF}
  TRegExp = class(TOleServer)
  private
    FIntf: IRegExp2;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TRegExpProperties;
    function GetServerProperties: TRegExpProperties;
{$ENDIF}
    function GetDefaultInterface: IRegExp2;
  protected
    procedure InitServerData; override;
    function Get_Pattern: WideString;
    procedure Set_Pattern(const pPattern: WideString);
    function Get_IgnoreCase: WordBool;
    procedure Set_IgnoreCase(pIgnoreCase: WordBool);
    function Get_Global: WordBool;
    procedure Set_Global(pGlobal: WordBool);
    function Get_Multiline: WordBool;
    procedure Set_Multiline(pMultiline: WordBool);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IRegExp2);
    procedure Disconnect; override;
    function Execute(const sourceString: WideString): IDispatch;
    function Test(const sourceString: WideString): WordBool;
    function Replace(const sourceString: WideString; replaceVar: OleVariant): WideString;
    property DefaultInterface: IRegExp2 read GetDefaultInterface;
    property Pattern: WideString read Get_Pattern write Set_Pattern;
    property IgnoreCase: WordBool read Get_IgnoreCase write Set_IgnoreCase;
    property Global: WordBool read Get_Global write Set_Global;
    property Multiline: WordBool read Get_Multiline write Set_Multiline;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TRegExpProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TRegExp
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TRegExpProperties = class(TPersistent)
  private
    FServer:    TRegExp;
    function    GetDefaultInterface: IRegExp2;
    constructor Create(AServer: TRegExp);
  protected
    function Get_Pattern: WideString;
    procedure Set_Pattern(const pPattern: WideString);
    function Get_IgnoreCase: WordBool;
    procedure Set_IgnoreCase(pIgnoreCase: WordBool);
    function Get_Global: WordBool;
    procedure Set_Global(pGlobal: WordBool);
    function Get_Multiline: WordBool;
    procedure Set_Multiline(pMultiline: WordBool);
  public
    property DefaultInterface: IRegExp2 read GetDefaultInterface;
  published
    property Pattern: WideString read Get_Pattern write Set_Pattern;
    property IgnoreCase: WordBool read Get_IgnoreCase write Set_IgnoreCase;
    property Global: WordBool read Get_Global write Set_Global;
    property Multiline: WordBool read Get_Multiline write Set_Multiline;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoMatch provides a Create and CreateRemote method to          
// create instances of the default interface IMatch2 exposed by              
// the CoClass Match. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMatch = class
    class function Create: IMatch2;
    class function CreateRemote(const MachineName: string): IMatch2;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TMatch
// Help String      : 
// Default Interface: IMatch2
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TMatchProperties= class;
{$ENDIF}
  TMatch = class(TOleServer)
  private
    FIntf: IMatch2;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TMatchProperties;
    function GetServerProperties: TMatchProperties;
{$ENDIF}
    function GetDefaultInterface: IMatch2;
  protected
    procedure InitServerData; override;
    function Get_Value: WideString;
    function Get_FirstIndex: Integer;
    function Get_Length: Integer;
    function Get_SubMatches: IDispatch;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IMatch2);
    procedure Disconnect; override;
    property DefaultInterface: IMatch2 read GetDefaultInterface;
    property Value: WideString read Get_Value;
    property FirstIndex: Integer read Get_FirstIndex;
    property Length: Integer read Get_Length;
    property SubMatches: IDispatch read Get_SubMatches;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TMatchProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TMatch
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TMatchProperties = class(TPersistent)
  private
    FServer:    TMatch;
    function    GetDefaultInterface: IMatch2;
    constructor Create(AServer: TMatch);
  protected
    function Get_Value: WideString;
    function Get_FirstIndex: Integer;
    function Get_Length: Integer;
    function Get_SubMatches: IDispatch;
  public
    property DefaultInterface: IMatch2 read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoMatchCollection provides a Create and CreateRemote method to          
// create instances of the default interface IMatchCollection2 exposed by              
// the CoClass MatchCollection. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMatchCollection = class
    class function Create: IMatchCollection2;
    class function CreateRemote(const MachineName: string): IMatchCollection2;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TMatchCollection
// Help String      : 
// Default Interface: IMatchCollection2
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TMatchCollectionProperties= class;
{$ENDIF}
  TMatchCollection = class(TOleServer)
  private
    FIntf: IMatchCollection2;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TMatchCollectionProperties;
    function GetServerProperties: TMatchCollectionProperties;
{$ENDIF}
    function GetDefaultInterface: IMatchCollection2;
  protected
    procedure InitServerData; override;
    function Get_Item(index: Integer): IDispatch;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IMatchCollection2);
    procedure Disconnect; override;
    property DefaultInterface: IMatchCollection2 read GetDefaultInterface;
    property Item[index: Integer]: IDispatch read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TMatchCollectionProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TMatchCollection
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TMatchCollectionProperties = class(TPersistent)
  private
    FServer:    TMatchCollection;
    function    GetDefaultInterface: IMatchCollection2;
    constructor Create(AServer: TMatchCollection);
  protected
    function Get_Item(index: Integer): IDispatch;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    property DefaultInterface: IMatchCollection2 read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSubMatches provides a Create and CreateRemote method to          
// create instances of the default interface ISubMatches exposed by              
// the CoClass SubMatches. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSubMatches = class
    class function Create: ISubMatches;
    class function CreateRemote(const MachineName: string): ISubMatches;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSubMatches
// Help String      : 
// Default Interface: ISubMatches
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSubMatchesProperties= class;
{$ENDIF}
  TSubMatches = class(TOleServer)
  private
    FIntf: ISubMatches;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TSubMatchesProperties;
    function GetServerProperties: TSubMatchesProperties;
{$ENDIF}
    function GetDefaultInterface: ISubMatches;
  protected
    procedure InitServerData; override;
    function Get_Item(index: Integer): OleVariant;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISubMatches);
    procedure Disconnect; override;
    property DefaultInterface: ISubMatches read GetDefaultInterface;
    property Item[index: Integer]: OleVariant read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSubMatchesProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSubMatches
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSubMatchesProperties = class(TPersistent)
  private
    FServer:    TSubMatches;
    function    GetDefaultInterface: ISubMatches;
    constructor Create(AServer: TSubMatches);
  protected
    function Get_Item(index: Integer): OleVariant;
    function Get_Count: Integer;
    function Get__NewEnum: IUnknown;
  public
    property DefaultInterface: ISubMatches read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoRegExp.Create: IRegExp2;
begin
  Result := CreateComObject(CLASS_RegExp) as IRegExp2;
end;

class function CoRegExp.CreateRemote(const MachineName: string): IRegExp2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RegExp) as IRegExp2;
end;

procedure TRegExp.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3F4DACA4-160D-11D2-A8E9-00104B365C9F}';
    IntfIID:   '{3F4DACB0-160D-11D2-A8E9-00104B365C9F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TRegExp.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IRegExp2;
  end;
end;

procedure TRegExp.ConnectTo(svrIntf: IRegExp2);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TRegExp.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TRegExp.GetDefaultInterface: IRegExp2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TRegExp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TRegExpProperties.Create(Self);
{$ENDIF}
end;

destructor TRegExp.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TRegExp.GetServerProperties: TRegExpProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TRegExp.Get_Pattern: WideString;
begin
    Result := DefaultInterface.Pattern;
end;

procedure TRegExp.Set_Pattern(const pPattern: WideString);
  { Warning: The property Pattern has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Pattern := pPattern;
end;

function TRegExp.Get_IgnoreCase: WordBool;
begin
    Result := DefaultInterface.IgnoreCase;
end;

procedure TRegExp.Set_IgnoreCase(pIgnoreCase: WordBool);
begin
  DefaultInterface.Set_IgnoreCase(pIgnoreCase);
end;

function TRegExp.Get_Global: WordBool;
begin
    Result := DefaultInterface.Global;
end;

procedure TRegExp.Set_Global(pGlobal: WordBool);
begin
  DefaultInterface.Set_Global(pGlobal);
end;

function TRegExp.Get_Multiline: WordBool;
begin
    Result := DefaultInterface.Multiline;
end;

procedure TRegExp.Set_Multiline(pMultiline: WordBool);
begin
  DefaultInterface.Set_Multiline(pMultiline);
end;

function TRegExp.Execute(const sourceString: WideString): IDispatch;
begin
  Result := DefaultInterface.Execute(sourceString);
end;

function TRegExp.Test(const sourceString: WideString): WordBool;
begin
  Result := DefaultInterface.Test(sourceString);
end;

function TRegExp.Replace(const sourceString: WideString; replaceVar: OleVariant): WideString;
begin
  Result := DefaultInterface.Replace(sourceString, replaceVar);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TRegExpProperties.Create(AServer: TRegExp);
begin
  inherited Create;
  FServer := AServer;
end;

function TRegExpProperties.GetDefaultInterface: IRegExp2;
begin
  Result := FServer.DefaultInterface;
end;

function TRegExpProperties.Get_Pattern: WideString;
begin
    Result := DefaultInterface.Pattern;
end;

procedure TRegExpProperties.Set_Pattern(const pPattern: WideString);
  { Warning: The property Pattern has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Pattern := pPattern;
end;

function TRegExpProperties.Get_IgnoreCase: WordBool;
begin
    Result := DefaultInterface.IgnoreCase;
end;

procedure TRegExpProperties.Set_IgnoreCase(pIgnoreCase: WordBool);
begin
  DefaultInterface.Set_IgnoreCase(pIgnoreCase);
end;

function TRegExpProperties.Get_Global: WordBool;
begin
    Result := DefaultInterface.Global;
end;

procedure TRegExpProperties.Set_Global(pGlobal: WordBool);
begin
  DefaultInterface.Set_Global(pGlobal);
end;

function TRegExpProperties.Get_Multiline: WordBool;
begin
    Result := DefaultInterface.Multiline;
end;

procedure TRegExpProperties.Set_Multiline(pMultiline: WordBool);
begin
  DefaultInterface.Set_Multiline(pMultiline);
end;

{$ENDIF}

class function CoMatch.Create: IMatch2;
begin
  Result := CreateComObject(CLASS_Match) as IMatch2;
end;

class function CoMatch.CreateRemote(const MachineName: string): IMatch2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Match) as IMatch2;
end;

procedure TMatch.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3F4DACA5-160D-11D2-A8E9-00104B365C9F}';
    IntfIID:   '{3F4DACB1-160D-11D2-A8E9-00104B365C9F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TMatch.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IMatch2;
  end;
end;

procedure TMatch.ConnectTo(svrIntf: IMatch2);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TMatch.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TMatch.GetDefaultInterface: IMatch2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TMatch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TMatchProperties.Create(Self);
{$ENDIF}
end;

destructor TMatch.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TMatch.GetServerProperties: TMatchProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TMatch.Get_Value: WideString;
begin
    Result := DefaultInterface.Value;
end;

function TMatch.Get_FirstIndex: Integer;
begin
    Result := DefaultInterface.FirstIndex;
end;

function TMatch.Get_Length: Integer;
begin
    Result := DefaultInterface.Length;
end;

function TMatch.Get_SubMatches: IDispatch;
begin
    Result := DefaultInterface.SubMatches;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TMatchProperties.Create(AServer: TMatch);
begin
  inherited Create;
  FServer := AServer;
end;

function TMatchProperties.GetDefaultInterface: IMatch2;
begin
  Result := FServer.DefaultInterface;
end;

function TMatchProperties.Get_Value: WideString;
begin
    Result := DefaultInterface.Value;
end;

function TMatchProperties.Get_FirstIndex: Integer;
begin
    Result := DefaultInterface.FirstIndex;
end;

function TMatchProperties.Get_Length: Integer;
begin
    Result := DefaultInterface.Length;
end;

function TMatchProperties.Get_SubMatches: IDispatch;
begin
    Result := DefaultInterface.SubMatches;
end;

{$ENDIF}

class function CoMatchCollection.Create: IMatchCollection2;
begin
  Result := CreateComObject(CLASS_MatchCollection) as IMatchCollection2;
end;

class function CoMatchCollection.CreateRemote(const MachineName: string): IMatchCollection2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MatchCollection) as IMatchCollection2;
end;

procedure TMatchCollection.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3F4DACA6-160D-11D2-A8E9-00104B365C9F}';
    IntfIID:   '{3F4DACB2-160D-11D2-A8E9-00104B365C9F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TMatchCollection.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IMatchCollection2;
  end;
end;

procedure TMatchCollection.ConnectTo(svrIntf: IMatchCollection2);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TMatchCollection.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TMatchCollection.GetDefaultInterface: IMatchCollection2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TMatchCollection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TMatchCollectionProperties.Create(Self);
{$ENDIF}
end;

destructor TMatchCollection.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TMatchCollection.GetServerProperties: TMatchCollectionProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TMatchCollection.Get_Item(index: Integer): IDispatch;
begin
    Result := DefaultInterface.Item[index];
end;

function TMatchCollection.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TMatchCollection.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TMatchCollectionProperties.Create(AServer: TMatchCollection);
begin
  inherited Create;
  FServer := AServer;
end;

function TMatchCollectionProperties.GetDefaultInterface: IMatchCollection2;
begin
  Result := FServer.DefaultInterface;
end;

function TMatchCollectionProperties.Get_Item(index: Integer): IDispatch;
begin
    Result := DefaultInterface.Item[index];
end;

function TMatchCollectionProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TMatchCollectionProperties.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

{$ENDIF}

class function CoSubMatches.Create: ISubMatches;
begin
  Result := CreateComObject(CLASS_SubMatches) as ISubMatches;
end;

class function CoSubMatches.CreateRemote(const MachineName: string): ISubMatches;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SubMatches) as ISubMatches;
end;

procedure TSubMatches.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3F4DACC0-160D-11D2-A8E9-00104B365C9F}';
    IntfIID:   '{3F4DACB3-160D-11D2-A8E9-00104B365C9F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSubMatches.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISubMatches;
  end;
end;

procedure TSubMatches.ConnectTo(svrIntf: ISubMatches);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSubMatches.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSubMatches.GetDefaultInterface: ISubMatches;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSubMatches.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSubMatchesProperties.Create(Self);
{$ENDIF}
end;

destructor TSubMatches.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSubMatches.GetServerProperties: TSubMatchesProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TSubMatches.Get_Item(index: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Item[index];
end;

function TSubMatches.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TSubMatches.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSubMatchesProperties.Create(AServer: TSubMatches);
begin
  inherited Create;
  FServer := AServer;
end;

function TSubMatchesProperties.GetDefaultInterface: ISubMatches;
begin
  Result := FServer.DefaultInterface;
end;

function TSubMatchesProperties.Get_Item(index: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Item[index];
end;

function TSubMatchesProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TSubMatchesProperties.Get__NewEnum: IUnknown;
begin
    Result := DefaultInterface._NewEnum;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TRegExp, TMatch, TMatchCollection, TSubMatches]);
end;

end.
