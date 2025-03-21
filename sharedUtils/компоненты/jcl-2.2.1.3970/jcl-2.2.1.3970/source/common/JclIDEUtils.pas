{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is DelphiInstall.pas.                                                          }
{                                                                                                  }
{ The Initial Developer of the Original Code is Petr Vones. Portions created by Petr Vones are     }
{ Copyright (C) of Petr Vones. All Rights Reserved.                                                }
{                                                                                                  }
{ Contributor(s):                                                                                  }
{   Andreas Hausladen (ahuser)                                                                     }
{   Florent Ouchet (outchy)                                                                        }
{   Robert Marquardt (marquardt)                                                                   }
{   Robert Rossmair (rrossmair) - crossplatform & BCB support                                      }
{   Uwe Schuster (uschuster)                                                                       }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Routines for getting information about installed versions of Delphi/C++Builder and performing    }
{ basic installation tasks.                                                                        }
{                                                                                                  }
{ Important notes for C#Builder 1 and Delphi 8:                                                    }
{ These products were not shipped with their native compilers, but the toolkit to build design     }
{ packages is available in codecentral (http://cc.embarcadero.com):                                }
{  - "IDE Integration pack for C#Builder 1.0" http://cc.embarcadero.com/Item/21334                 }
{  - "IDE Integration pack for Delphi 8" http://cc.embarcadero.com/Item/21333                      }
{ It's recommended to extract zip files using the standard pattern of Delphi directories:          }
{  - Binary files go to \bin (DCC32.EXE, RLINK32.DLL and lnkdfm7*.dll)                             }
{  - Compiler files go to \lib (designide.dcp, rtl.dcp, SysInit.dcu, vcl.dcp, vclactnband.dcp,     }
{    vcljpg.dcp and vclx.dcp)                                                                      }
{  - ToolsAPI files go to \source\ToolsAPI (PaletteAPI.pas, PropInspAPI.pas and ToolsAPI.pas)      }
{ Don't mix C#Builder 1 files with Delphi 8 and vice-versa otherwise the compilation will fail     }
{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                   }
{ !!!!!!!!      The DCPPath for these releases have to $(BDS)\lib      !!!!!!!!!                   }
{ !!!!!!!!    or the directory where compiler files were extracted     !!!!!!!!!                   }
{ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                   }
{ The default BPL output directory for these products is set to $(BDSPROJECTSDIR)\bpl, it may not  }
{ exist since the product installers don't create it                                               }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2010-09-01 21:48:55 +0200 (mer., 01 sept. 2010)                         $ }
{ Revision:      $Rev:: 3321                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclIDEUtils;

{$I jcl.inc}
{$I crossplatform.inc}

interface

uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  {$IFDEF MSWINDOWS}
  Windows, ShlObj, JclHelpUtils,
  {$ENDIF MSWINDOWS}
  Classes, SysUtils, IniFiles, Contnrs,
  JclBase, JclSysUtils, JclCompilerUtils;

// Various definitions
type
  EJclBorRADException = class(EJclError);

  TJclBorRADToolKind = (brDelphi, brCppBuilder, brBorlandDevStudio);
  TJclBorRADToolEdition = (deSTD, dePRO, deCSS, deARC);
  TJclBorRADToolPath = string;

const
  SupportedDelphiVersions = [5, 6, 7, 8, 9, 10, 11, 12, 14, 15];
  SupportedBCBVersions    = [5, 6, 10, 11, 12, 14, 15];
  SupportedBDSVersions    = [1, 2, 3, 4, 5, 6, 7, 8];

  // Object Repository
  BorRADToolRepositoryPagesSection    = 'Repository Pages';

  BorRADToolRepositoryDialogsPage     = 'Dialogs';
  BorRADToolRepositoryFormsPage       = 'Forms';
  BorRADToolRepositoryProjectsPage    = 'Projects';
  BorRADToolRepositoryDataModulesPage = 'Data Modules';

  BorRADToolRepositoryObjectType      = 'Type';
  BorRADToolRepositoryFormTemplate    = 'FormTemplate';
  BorRADToolRepositoryProjectTemplate = 'ProjectTemplate';
  BorRADToolRepositoryObjectName      = 'Name';
  BorRADToolRepositoryObjectPage      = 'Page';
  BorRADToolRepositoryObjectIcon      = 'Icon';
  BorRADToolRepositoryObjectDescr     = 'Description';
  BorRADToolRepositoryObjectAuthor    = 'Author';
  BorRADToolRepositoryObjectAncestor  = 'Ancestor';
  BorRADToolRepositoryObjectDesigner  = 'Designer'; // Delphi 6+ only
  BorRADToolRepositoryDesignerDfm     = 'dfm';
  BorRADToolRepositoryDesignerXfm     = 'xfm';
  BorRADToolRepositoryObjectNewForm   = 'DefaultNewForm';
  BorRADToolRepositoryObjectMainForm  = 'DefaultMainForm';

  CompilerExtensionDCP         = '.dcp';
  CompilerExtensionBPI         = '.bpi';
  CompilerExtensionLIB         = '.lib';
  CompilerExtensionTDS         = '.tds';
  CompilerExtensionMAP         = '.map';
  CompilerExtensionDRC         = '.drc';
  CompilerExtensionDEF         = '.def';
  SourceExtensionCPP           = '.cpp';
  SourceExtensionH             = '.h';
  SourceExtensionPAS           = '.pas';
  SourceExtensionDFM           = '.dfm';
  SourceExtensionXFM           = '.xfm';
  SourceDescriptionPAS         = 'Pascal source file';
  SourceDescriptionCPP         = 'C++ source file';

  DesignerVCL = 'VCL';
  DesignerCLX = 'CLX';

  ProjectTypePackage = 'package';
  ProjectTypeLibrary = 'library';
  ProjectTypeProgram = 'program';

  Personality32Bit        = '32 bit';
  Personality64Bit        = '64 bit';
  PersonalityDelphi       = 'Delphi';
  PersonalityDelphiDotNet = 'Delphi.net';
  PersonalityBCB          = 'C++Builder';
  PersonalityCSB          = 'C#Builder';
  PersonalityVB           = 'Visual Basic';
  PersonalityDesign       = 'Design';
  PersonalityUnknown      = 'Unknown personality';
  PersonalityBDS          = 'Borland Developer Studio';

  BorRADToolEditionIDs: array [TJclBorRADToolEdition] of PChar =
    ('STD', 'PRO', 'CSS', 'ARC'); // 'ARC' is an assumption

// Installed versions information classes
type
  TJclBorPersonality = (bpDelphi32, bpDelphi64, bpBCBuilder32, bpBCBuilder64,
    bpDelphiNet32, bpDelphiNet64, bpCSBuilder32, bpCSBuilder64,
    bpVisualBasic32, bpVisualBasic64, bpDesign, bpUnknown);
  //  bpDelphi64, bpBCBuilder64);

  TJclBorPersonalities = set of TJclBorPersonality;

  TJclBorDesigner = (bdVCL, bdCLX);

  TJclBorDesigners = set of TJClBorDesigner;

  TJclBorPlatform = (bp32bit, bp64bit);

const
  JclBorPersonalityDescription: array [TJclBorPersonality] of string =
   (
    Personality32Bit + ' ' + PersonalityDelphi,
    Personality64Bit + ' ' + PersonalityDelphi,
    Personality32Bit + ' ' + PersonalityBCB,
    Personality64Bit + ' ' + PersonalityBCB,
    Personality32Bit + ' ' + PersonalityDelphiDotNet,
    Personality64Bit + ' ' + PersonalityDelphiDotNet,
    Personality32Bit + ' ' + PersonalityCSB,
    Personality64Bit + ' ' + PersonalityCSB,
    Personality32Bit + ' ' + PersonalityVB,
    Personality64Bit + ' ' + PersonalityVB,
    PersonalityDesign,
    PersonalityUnknown
   );

  JclBorDesignerDescription: array [TJclBorDesigner] of string =
    (DesignerVCL, DesignerCLX);
  JclBorDesignerFormExtension: array [TJclBorDesigner] of string =
    (SourceExtensionDFM, SourceExtensionXFM);

type
  TJclBorRADToolInstallation = class;

  TJclBorRADToolInstallationObject = class(TInterfacedObject)
  private
    FInstallation: TJclBorRADToolInstallation;
  public
    constructor Create(AInstallation: TJclBorRADToolInstallation);
    property Installation: TJclBorRADToolInstallation read FInstallation;
  end;

  TJclBorRADToolIdeTool = class(TJclBorRADToolInstallationObject)
  private
    FKey: string;
    function GetCount: Integer;
    function GetParameters(Index: Integer): string;
    function GetPath(Index: Integer): string;
    function GetTitle(Index: Integer): string;
    function GetWorkingDir(Index: Integer): string;
    procedure SetCount(const Value: Integer);
    procedure SetParameters(Index: Integer; const Value: string);
    procedure SetPath(Index: Integer; const Value: string);
    procedure SetTitle(Index: Integer; const Value: string);
    procedure SetWorkingDir(Index: Integer; const Value: string);
  protected
    procedure CheckIndex(Index: Integer);
  public
    constructor Create(AInstallation: TJclBorRADToolInstallation);
    property Count: Integer read GetCount write SetCount;
    function IndexOfPath(const Value: string): Integer;
    function IndexOfTitle(const Value: string): Integer;
    procedure RemoveIndex(const Index: Integer);
    property Key: string read FKey;
    property Title[Index: Integer]: string read GetTitle write SetTitle;
    property Path[Index: Integer]: string read GetPath write SetPath;
    property Parameters[Index: Integer]: string read GetParameters write SetParameters;
    property WorkingDir[Index: Integer]: string read GetWorkingDir write SetWorkingDir;
  end;

  TJclBorRADToolIdePackages = class(TJclBorRADToolInstallationObject)
  private
    FDisabledPackages: TStringList;
    FKnownPackages: TStringList;
    FKnownIDEPackages: TStringList;
    FExperts: TStringList;
    function GetCount: Integer;
    function GetIDECount: Integer;
    function GetExpertCount: Integer;
    function GetPackageDescriptions(Index: Integer): string;
    function GetIDEPackageDescriptions(Index: Integer): string;
    function GetExpertDescriptions(Index: Integer): string;
    function GetPackageDisabled(Index: Integer): Boolean;
    function GetPackageFileNames(Index: Integer): string;
    function GetIDEPackageFileNames(Index: Integer): string;
    function GetExpertFileNames(Index: Integer): string;
  protected
    function PackageEntryToFileName(const Entry: string): string;
    procedure ReadPackages;
    procedure RemoveDisabled(const FileName: string);
  public
    constructor Create(AInstallation: TJclBorRADToolInstallation);
    destructor Destroy; override;
    function AddPackage(const FileName, Description: string): Boolean;
    function AddIDEPackage(const FileName, Description: string): Boolean;
    function AddExpert(const FileName, Description: string): Boolean;
    function RemovePackage(const FileName: string): Boolean;
    function RemoveIDEPackage(const FileName: string): Boolean;
    function RemoveExpert(const FileName: string): Boolean;
    property Count: Integer read GetCount;
    property IDECount: Integer read GetIDECount;
    property ExpertCount: Integer read GetExpertCount;
    property PackageDescriptions[Index: Integer]: string read GetPackageDescriptions;
    property IDEPackageDescriptions[Index: Integer]: string read GetIDEPackageDescriptions;
    property ExpertDescriptions[Index: Integer]: string read GetExpertDescriptions;
    property PackageFileNames[Index: Integer]: string read GetPackageFileNames;
    property IDEPackageFileNames[Index: Integer]: string read GetIDEPackageFileNames;
    property ExpertFileNames[Index: Integer]: string read GetExpertFileNames;
    property PackageDisabled[Index: Integer]: Boolean read GetPackageDisabled;
  end;

  TJclBorRADToolPalette = class(TJclBorRADToolInstallationObject)
  private
    FKey: string;
    FTabNames: TStringList;
    function GetComponentsOnTab(Index: Integer): string;
    function GetHiddenComponentsOnTab(Index: Integer): string;
    function GetTabNameCount: Integer;
    function GetTabNames(Index: Integer): string;
    procedure ReadTabNames;
  public
    constructor Create(AInstallation: TJclBorRADToolInstallation);
    destructor Destroy; override;
    procedure ComponentsOnTabToStrings(Index: Integer; Strings: TStrings; IncludeUnitName: Boolean = False;
      IncludeHiddenComponents: Boolean = True);
    function DeleteTabName(const TabName: string): Boolean;
    function TabNameExists(const TabName: string): Boolean;
    property ComponentsOnTab[Index: Integer]: string read GetComponentsOnTab;
    property HiddenComponentsOnTab[Index: Integer]: string read GetHiddenComponentsOnTab;
    property Key: string read FKey;
    property TabNames[Index: Integer]: string read GetTabNames;
    property TabNameCount: Integer read GetTabNameCount;
  end;

  TJclBorRADToolRepository = class(TJclBorRADToolInstallationObject)
  private
    FIniFile: TIniFile;
    FFileName: string;
    FPages: TStringList;
    function GetIniFile: TIniFile;
    function GetPages: TStrings;
  public
    constructor Create(AInstallation: TJclBorRADToolInstallation);
    destructor Destroy; override;
    procedure AddObject(const FileName, ObjectType, PageName, ObjectName, IconFileName, Description,
      Author, Designer: string; const Ancestor: string = '');
    procedure CloseIniFile;
    function FindPage(const Name: string; OptionalIndex: Integer): string;
    procedure RemoveObjects(const PartialPath, FileName, ObjectType: string);
    property FileName: string read FFileName;
    property IniFile: TIniFile read GetIniFile;
    property Pages: TStrings read GetPages;
  end;

  TCommandLineTool = (clAsm, clBcc32, clDcc32, clDccIL, clMake, clProj2Mak);
  TCommandLineTools = set of TCommandLineTool;

  TJclBorRADToolInstallationClass = class of TJclBorRADToolInstallation;

  TJclBorRADToolInstallation = class(TObject)
  private
    FConfigData: TCustomIniFile;
    FConfigDataLocation: string;
    FRootKey: Cardinal;
    FGlobals: TStringList;
    FRootDir: string;
    FBinFolderName: string;
    FBCC32: TJclBCC32;
    FDCC32: TJclDCC32;
    FBpr2Mak: TJclBpr2Mak;
    FMake: IJclCommandLineTool;
    FEditionStr: string;
    FEdition: TJclBorRADToolEdition;
    FEnvironmentVariables: TStringList;
    FIdePackages: TJclBorRADToolIdePackages;
    FIdeTools: TJclBorRADToolIdeTool;
    FInstalledUpdatePack: Integer;
    {$IFDEF MSWINDOWS}
    FOpenHelp: TJclBorlandOpenHelp;
    {$ENDIF MSWINDOWS}
    FPalette: TJclBorRADToolPalette;
    FRepository: TJclBorRADToolRepository;
    FVersionNumber: Integer;    // Delphi 2005: 3   -  Delphi 7: 7 - Delphi 2007: 11
    FVersionNumberStr: string;
    FIDEVersionNumber: Integer; // Delphi 2005: 3   -  Delphi 7: 7 - Delphi 2007: 11
    FIDEVersionNumberStr: string;
    FMapCreate: Boolean;
    {$IFDEF MSWINDOWS}
    FJdbgCreate: Boolean;
    FJdbgInsert: Boolean;
    FMapDelete: Boolean;
    {$ENDIF MSWINDOWS}
    FCommandLineTools: TCommandLineTools;
    FPersonalities: TJclBorPersonalities;
    FOutputCallback: TTextHandler;
    function GetSupportsLibSuffix: Boolean;
    function GetBCC32: TJclBCC32;
    function GetDCC32: TJclDCC32;
    function GetBpr2Mak: TJclBpr2Mak;
    function GetMake: IJclCommandLineTool;
    function GetDescription: string;
    function GetEditionAsText: string;
    function GetIdeExeFileName: string;
    function GetGlobals: TStrings;
    function GetIdeExeBuildNumber: string;
    function GetIdePackages: TJclBorRADToolIdePackages;
    function GetIsTurboExplorer: Boolean;
    function GetLatestUpdatePack: Integer;
    function GetPalette: TJclBorRADToolPalette;
    function GetRepository: TJclBorRADToolRepository;
    function GetUpdateNeeded: Boolean;
    function GetDefaultBDSCommonDir: string;
  protected
    function ProcessMapFile(const BinaryFileName: string): Boolean;

    // compilation functions
    function CompileDelphiPackage(const PackageName, BPLPath, DCPPath: string): Boolean; overload; virtual;
    function CompileDelphiPackage(const PackageName, BPLPath, DCPPath, ExtraOptions: string): Boolean;
      overload; virtual;
    function CompileDelphiProject(const ProjectName, OutputDir, DcpSearchPath: string): Boolean; virtual;
    function CompileBCBPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function CompileBCBProject(const ProjectName, OutputDir, DcpSearchPath: string): Boolean; virtual;

    // installation (=compilation+registration) / uninstallation(=unregistration+deletion) functions
    function InstallDelphiPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function UninstallDelphiPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function InstallBCBPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function UninstallBCBPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function InstallDelphiIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function UninstallDelphiIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function InstallBCBIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function UninstallBCBIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function InstallDelphiExpert(const ProjectName, OutputDir, DcpSearchPath: string): Boolean; virtual;
    function UninstallDelphiExpert(const ProjectName, OutputDir: string): Boolean; virtual;
    function InstallBCBExpert(const ProjectName, OutputDir, DcpSearchPath: string): Boolean; virtual;
    function UninstallBCBExpert(const ProjectName, OutputDir: string): Boolean; virtual;

    procedure ReadInformation;
    //function AddMissingPathItems(var Path: string; const NewPath: string): Boolean;
    function RemoveFromPath(var Path: string; const ItemsToRemove: string): Boolean;
    function GetDCPOutputPath: string; virtual;
    function GetBPLOutputPath: string; virtual;
    function GetEnvironmentVariables: TStrings; virtual;
    function GetVclIncludeDir: string; virtual;
    function GetName: string; virtual;
    procedure OutputString(const AText: string);
    function OutputFileDelete(const FileName: string): Boolean;
    procedure SetOutputCallback(const Value: TTextHandler); virtual;

    function GetDebugDCUPath: TJclBorRADToolPath; virtual;
    procedure SetDebugDCUPath(const Value: TJclBorRADToolPath); virtual;
    function GetLibrarySearchPath: TJclBorRADToolPath; virtual;
    procedure SetLibrarySearchPath(const Value: TJclBorRADToolPath); virtual;
    function GetLibraryBrowsingPath: TJclBorRADToolPath; virtual;
    procedure SetLibraryBrowsingPath(const Value: TJclBorRADToolPath); virtual;

    function GetValid: Boolean; virtual;
    function GetLongPathBug: Boolean;
    function GetCompilerSettingsFormat: TJclCompilerSettingsFormat;
    function GetSupportsNoConfig: Boolean;
  public
    constructor Create(const AConfigDataLocation: string; ARootKey: Cardinal = 0); virtual;

    destructor Destroy; override;
    class procedure ExtractPaths(const Path: TJclBorRADToolPath; List: TStrings);
    class function GetLatestUpdatePackForVersion(Version: Integer): Integer; virtual;
    class function PackageSourceFileExtension: string; virtual;
    class function ProjectSourceFileExtension: string; virtual;
    class function RadToolKind: TJclBorRadToolKind; virtual;
    {class} function RadToolName: string; virtual;
    function AnyInstanceRunning: Boolean;
    function AddToDebugDCUPath(const Path: string): Boolean;
    function AddToLibrarySearchPath(const Path: string): Boolean;
    function AddToLibraryBrowsingPath(const Path: string): Boolean;
    function FindFolderInPath(Folder: string; List: TStrings): Integer;
    // package functions
      // install = package compile + registration
      // uninstall = unregistration + deletion
    function CompilePackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function InstallPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function UninstallPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function InstallIDEPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;
    function UninstallIDEPackage(const PackageName, BPLPath, DCPPath: string): Boolean; virtual;

    // project functions
    function CompileProject(const ProjectName, OutputDir, DcpSearchPath: string): Boolean; virtual;
    // expert functions
      // install = project compile + registration
      // uninstall = unregistration + deletion
    function InstallExpert(const ProjectName, OutputDir, DcpSearchPath: string): Boolean; virtual;
    function UninstallExpert(const ProjectName, OutputDir: string): Boolean; virtual;

    // registration/unregistration functions
    function RegisterPackage(const BinaryFileName, Description: string): Boolean; overload; virtual;
    function RegisterPackage(const PackageName, BPLPath, Description: string): Boolean; overload; virtual;
    function UnregisterPackage(const BinaryFileName: string): Boolean; overload; virtual;
    function UnregisterPackage(const PackageName, BPLPath: string): Boolean; overload; virtual;
    function RegisterIDEPackage(const BinaryFileName, Description: string): Boolean; overload; virtual;
    function RegisterIDEPackage(const PackageName, BPLPath, Description: string): Boolean; overload; virtual;
    function UnregisterIDEPackage(const BinaryFileName: string): Boolean; overload; virtual;
    function UnregisterIDEPackage(const PackageName, BPLPath: string): Boolean; overload; virtual;
    function RegisterExpert(const BinaryFileName, Description: string): Boolean; overload; virtual;
    function RegisterExpert(const ProjectName, OutputDir, Description: string): Boolean; overload; virtual;
    function UnregisterExpert(const BinaryFileName: string): Boolean; overload; virtual;
    function UnregisterExpert(const ProjectName, OutputDir: string): Boolean; overload; virtual;

    function GetDefaultProjectsDir: string; virtual;
    function GetCommonProjectsDir: string; virtual;
    function RemoveFromDebugDCUPath(const Path: string): Boolean;
    function RemoveFromLibrarySearchPath(const Path: string): Boolean;
    function RemoveFromLibraryBrowsingPath(const Path: string): Boolean;
    function SubstitutePath(const Path: string): string;
    function SupportsVisualCLX: Boolean;
    function SupportsVCL: Boolean;
    function LibFolderName: string;
    function ObjFolderName: string;
    function LibDebugFolderName: string;
    // Command line tools
    property CommandLineTools: TCommandLineTools read FCommandLineTools;
    property BCC32: TJclBCC32 read GetBCC32;
    property DCC32: TJclDCC32 read GetDCC32;
    property Bpr2Mak: TJclBpr2Mak read GetBpr2Mak;
    property Make: IJclCommandLineTool read GetMake;
    // Paths
    property BinFolderName: string read FBinFolderName;
    property BPLOutputPath: string read GetBPLOutputPath;
    property DebugDCUPath: TJclBorRADToolPath read GetDebugDCUPath write SetDebugDCUPath;
    property DCPOutputPath: string read GetDCPOutputPath;
    property DefaultProjectsDir: string read GetDefaultProjectsDir;
    property CommonProjectsDir: string read GetCommonProjectsDir;
    //
    property Description: string read GetDescription;
    property Edition: TJclBorRADToolEdition read FEdition;
    property EditionAsText: string read GetEditionAsText;
    property EnvironmentVariables: TStrings read GetEnvironmentVariables;
    property IdePackages: TJclBorRADToolIdePackages read GetIdePackages;
    property IdeTools: TJclBorRADToolIdeTool read FIdeTools;
    property IdeExeBuildNumber: string read GetIdeExeBuildNumber;
    property IdeExeFileName: string read GetIdeExeFileName;
    property InstalledUpdatePack: Integer read FInstalledUpdatePack;
    property LatestUpdatePack: Integer read GetLatestUpdatePack;
    property LibrarySearchPath: TJclBorRADToolPath read GetLibrarySearchPath write SetLibrarySearchPath;
    property LibraryBrowsingPath: TJclBorRADToolPath read GetLibraryBrowsingPath write SetLibraryBrowsingPath;
    {$IFDEF MSWINDOWS}
    property OpenHelp: TJclBorlandOpenHelp read FOpenHelp;
    {$ENDIF MSWINDOWS}
    property MapCreate: Boolean read FMapCreate write FMapCreate;
    {$IFDEF MSWINDOWS}
    property JdbgCreate: Boolean read FJdbgCreate write FJdbgCreate;
    property JdbgInsert: Boolean read FJdbgInsert write FJdbgInsert;
    property MapDelete: Boolean read FMapDelete write FMapDelete;
    {$ENDIF MSWINDOWS}
    property ConfigData: TCustomIniFile read FConfigData;
    property ConfigDataLocation: string read FConfigDataLocation;
    property Globals: TStrings read GetGlobals;
    property Name: string read GetName;
    property Palette: TJclBorRADToolPalette read GetPalette;
    property Repository: TJclBorRADToolRepository read GetRepository;
    property RootDir: string read FRootDir;
    property UpdateNeeded: Boolean read GetUpdateNeeded;
    property Valid: Boolean read GetValid;
    property VclIncludeDir: string read GetVclIncludeDir;
    property IDEVersionNumber: Integer read FIDEVersionNumber;
    property IDEVersionNumberStr: string read FIDEVersionNumberStr;
    property VersionNumber: Integer read FVersionNumber;
    property VersionNumberStr: string read FVersionNumberStr;
    property Personalities: TJclBorPersonalities read FPersonalities;
    property SupportsLibSuffix: Boolean read GetSupportsLibSuffix;
    property OutputCallback: TTextHandler read FOutputCallback write SetOutputCallback;
    property IsTurboExplorer: Boolean read GetIsTurboExplorer;
    property RootKey: Cardinal read FRootKey;
    property LongPathBug: Boolean read GetLongPathBug;
    property CompilerSettingsFormat: TJclCompilerSettingsFormat read GetCompilerSettingsFormat;
    property SupportsNoConfig: Boolean read GetSupportsNoConfig;
  end;

  TJclBCBInstallation = class(TJclBorRADToolInstallation)
  protected
    function GetEnvironmentVariables: TStrings; override;
  public
    constructor Create(const AConfigDataLocation: string; ARootKey: Cardinal = 0); override;
    destructor Destroy; override;
    class function PackageSourceFileExtension: string; override;
    class function ProjectSourceFileExtension: string; override;
    class function RadToolKind: TJclBorRadToolKind; override;
    {class }function RadToolName: string; override;
    class function GetLatestUpdatePackForVersion(Version: Integer): Integer; override;
  end;

  TJclDelphiInstallation = class(TJclBorRADToolInstallation)
  protected
    function GetEnvironmentVariables: TStrings; override;
  public
    constructor Create(const AConfigDataLocation: string; ARootKey: Cardinal = 0); override;
    destructor Destroy; override;
    class function PackageSourceFileExtension: string; override;
    class function ProjectSourceFileExtension: string; override;
    class function RadToolKind: TJclBorRadToolKind; override;
    class function GetLatestUpdatePackForVersion(Version: Integer): Integer; override;
    function InstallPackage(const PackageName, BPLPath, DCPPath: string): Boolean; reintroduce;
    {class }function RadToolName: string; override;
  end;

  {$IFDEF MSWINDOWS}
  TJclBDSInstallation = class(TJclBorRADToolInstallation)
  private
    FDualPackageInstallation: Boolean;
    FHelp2Manager: TJclHelp2Manager;
    FDCCIL: TJclDCCIL;
    FPdbCreate: Boolean;
    procedure SetDualPackageInstallation(const Value: Boolean);
    function GetCppPathsKeyName: string;
    function GetCppBrowsingPath: TJclBorRADToolPath;
    function GetCppSearchPath: TJclBorRADToolPath;
    function GetCppLibraryPath: TJclBorRADToolPath;
    function GetCppIncludePath: TJclBorRADToolPath;
    procedure SetCppBrowsingPath(const Value: TJclBorRADToolPath);
    procedure SetCppSearchPath(const Value: TJclBorRADToolPath);
    procedure SetCppLibraryPath(const Value: TJclBorRADToolPath);
    procedure SetCppIncludePath(const Value: TJclBorRADToolPath);
    function GetMaxDelphiCLRVersion: string;
    function GetDCCIL: TJclDCCIL;

    function GetMsBuildEnvOptionsFileName: string;
    function GetMsBuildEnvOption(const OptionName: string): string;
    procedure SetMsBuildEnvOption(const OptionName, Value: string);
  protected
    function GetDCPOutputPath: string; override;
    function GetBPLOutputPath: string; override;
    function GetEnvironmentVariables: TStrings; override;
    function CompileDelphiPackage(const PackageName, BPLPath, DCPPath, ExtraOptions: string): Boolean; override;
    function CompileDelphiProject(const ProjectName, OutputDir: string;
      const DcpSearchPath: string): Boolean; override;
    function GetVclIncludeDir: string; override;
    function GetName: string; override;
    procedure SetOutputCallback(const Value: TTextHandler); override;

    function GetDebugDCUPath: TJclBorRADToolPath; override;
    procedure SetDebugDCUPath(const Value: TJclBorRADToolPath); override;
    function GetLibrarySearchPath: TJclBorRADToolPath; override;
    procedure SetLibrarySearchPath(const Value: TJclBorRADToolPath); override;
    function GetLibraryBrowsingPath: TJclBorRADToolPath; override;
    procedure SetLibraryBrowsingPath(const Value: TJclBorRADToolPath); override;

    function GetValid: Boolean; override;
  public
    constructor Create(const AConfigDataLocation: string; ARootKey: Cardinal = 0); override;
    destructor Destroy; override;
    class function PackageSourceFileExtension: string; override;
    class function ProjectSourceFileExtension: string; override;
    class function RadToolKind: TJclBorRadToolKind; override;
    class function GetLatestUpdatePackForVersion(Version: Integer): Integer; override;
    function GetDefaultProjectsDir: string; override;
    function GetCommonProjectsDir: string; override;
    class function GetDefaultProjectsDirectory(const RootDir: string; IDEVersionNumber: Integer): string;
    class function GetCommonProjectsDirectory(const RootDir: string; IDEVersionNumber: Integer): string;
    {class }function RadToolName: string; override;

    function AddToCppSearchPath(const Path: string): Boolean;
    function AddToCppBrowsingPath(const Path: string): Boolean;
    function AddToCppLibraryPath(const Path: string): Boolean;
    function AddToCppIncludePath(const Path: string): Boolean;
    function RemoveFromCppSearchPath(const Path: string): Boolean;
    function RemoveFromCppBrowsingPath(const Path: string): Boolean;
    function RemoveFromCppLibraryPath(const Path: string): Boolean;
    function RemoveFromCppIncludePath(const Path: string): Boolean;

    property CppSearchPath: TJclBorRADToolPath read GetCppSearchPath write SetCppSearchPath;
    property CppBrowsingPath: TJclBorRADToolPath read GetCppBrowsingPath write SetCppBrowsingPath;
    // Only exists in BDS 5 and upper
    property CppLibraryPath: TJclBorRADToolPath read GetCppLibraryPath write SetCppLibraryPath;
    property CppIncludePath: TJclBorRADToolPath read GetCppIncludePath write SetCppIncludePath;

    function RegisterPackage(const BinaryFileName, Description: string): Boolean; override;
    function UnregisterPackage(const BinaryFileName: string): Boolean; override;
    function CleanPackageCache(const BinaryFileName: string): Boolean;

    function CompileDelphiDotNetProject(const ProjectName, OutputDir: string; PEFormat: TJclBorPlatform = bp32bit;
      const ExtraOptions: string = ''): Boolean;

    property DualPackageInstallation: Boolean read FDualPackageInstallation write SetDualPackageInstallation;
    property Help2Manager: TJclHelp2Manager read FHelp2Manager;
    property DCCIL: TJclDCCIL read GetDCCIL;
    property MaxDelphiCLRVersion: string read GetMaxDelphiCLRVersion;
    property PdbCreate: Boolean read FPdbCreate write FPdbCreate;
  end;
  {$ENDIF MSWINDOWS}

  TTraverseMethod = function(Installation: TJclBorRADToolInstallation): Boolean of object;

  TJclBorRADToolInstallations = class(TObject)
  private
    FList: TObjectList;
    function GetBDSInstallationFromVersion(
      VersionNumber: Integer): TJclBorRADToolInstallation;
    function GetBDSVersionInstalled(VersionNumber: Integer): Boolean;
    function GetCount: Integer;
    function GetInstallations(Index: Integer): TJclBorRADToolInstallation;
    function GetBCBVersionInstalled(VersionNumber: Integer): Boolean;
    function GetDelphiVersionInstalled(VersionNumber: Integer): Boolean;
    function GetBCBInstallationFromVersion(VersionNumber: Integer): TJclBorRADToolInstallation;
    function GetDelphiInstallationFromVersion(VersionNumber: Integer): TJclBorRADToolInstallation;
  protected
    procedure ReadInstallations;
  public
    constructor Create;
    destructor Destroy; override;
    function AnyInstanceRunning: Boolean;
    function AnyUpdatePackNeeded(var Text: string): Boolean;
    function Iterate(TraverseMethod: TTraverseMethod): Boolean;
    property Count: Integer read GetCount;
    property Installations[Index: Integer]: TJclBorRADToolInstallation read GetInstallations; default;
    property BCBInstallationFromVersion[VersionNumber: Integer]: TJclBorRADToolInstallation
      read GetBCBInstallationFromVersion;
    property DelphiInstallationFromVersion[VersionNumber: Integer]: TJclBorRADToolInstallation
      read GetDelphiInstallationFromVersion;
    property BDSInstallationFromVersion[VersionNumber: Integer]: TJclBorRADToolInstallation
      read GetBDSInstallationFromVersion;
    property BCBVersionInstalled[VersionNumber: Integer]: Boolean read GetBCBVersionInstalled;
    property DelphiVersionInstalled[VersionNumber: Integer]: Boolean read GetDelphiVersionInstalled;
    property BDSVersionInstalled[VersionNumber: Integer]: Boolean read GetBDSVersionInstalled;
  end;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-2.2-Build3970/jcl/source/common/JclIDEUtils.pas $';
    Revision: '$Revision: 3321 $';
    Date: '$Date: 2010-09-01 21:48:55 +0200 (mer., 01 sept. 2010) $';
    LogPath: 'JCL\source\common';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  SysConst,
  {$IFDEF MSWINDOWS}
  Registry,
  JclRegistry,
  JclDebug,
  {$ENDIF MSWINDOWS}
  {$IFDEF HAS_UNIT_LIBC}
  Libc,
  {$ENDIF HAS_UNIT_LIBC}
  JclFileUtils, JclLogic, JclDevToolsResources,
  JclAnsiStrings, JclWideStrings, JclStrings,
  JclSysInfo, JclSimpleXml;

// Internal

{$IFDEF MSWINDOWS}
type
  TBDSVersionInfo = record
    Name: PResStringRec;
    VersionStr: string;
    Version: Integer;
    CoreIdeVersion: string;
    Supported: Boolean;
  end;
{$ENDIF MSWINDOWS}

const
  {$IFDEF MSWINDOWS}
  MSHelpSystemKeyName = '\SOFTWARE\Microsoft\Windows\Help';

  BCBKeyName          = '\SOFTWARE\Borland\C++Builder';
  BDSKeyName          = '\SOFTWARE\Borland\BDS';
  CDSKeyName          = '\SOFTWARE\CodeGear\BDS';
  EDSKeyName          = '\SOFTWARE\Embarcadero\BDS';
  DelphiKeyName       = '\SOFTWARE\Borland\Delphi';

  RADStudioDirName = 'RAD Studio';

  BDSVersions: array [1..8] of TBDSVersionInfo = (
    (
      Name: @RsCSharpName;
      VersionStr: '1.0';
      Version: 1;
      CoreIdeVersion: '71';
      Supported: True),
    (
      Name: @RsDelphiName;
      VersionStr: '8';
      Version: 8;
      CoreIdeVersion: '71';
      Supported: True),
    (
      Name: @RsDelphiName;
      VersionStr: '2005';
      Version: 9;
      CoreIdeVersion: '90';
      Supported: True),
    (
      Name: @RsBDSName;
      VersionStr: '2006';
      Version: 10;
      CoreIdeVersion: '100';
      Supported: True),
    (
      Name: @RsRSName;
      VersionStr: '2007';
      Version: 11;
      CoreIdeVersion: '100';
      Supported: True),
    (
      Name: @RsRSName;
      VersionStr: '2009';
      Version: 12;
      CoreIdeVersion: '120';
      Supported: True),
    (
      Name: @RsRSName;
      VersionStr: '2010';
      Version: 14;
      CoreIdeVersion: '140';
      Supported: True),
    (
      Name: @RsRSName;
      VersionStr: 'XE';
      Version: 15;
      CoreIdeVersion: '150';
      Supported: True)
  );
  {$ENDIF MSWINDOWS}

  RootDirValueName           = 'RootDir';

  EditionValueName           = 'Edition';
  VersionValueName           = 'Version';

  DebuggingKeyName           = 'Debugging';
  DebugDCUPathValueName      = 'Debug DCUs Path';

  GlobalsKeyName             = 'Globals';

  LibraryKeyName             = 'Library';
  LibrarySearchPathValueName = 'Search Path';
  LibraryBrowsingPathValueName = 'Browsing Path';
  LibraryBPLOutputValueName  = 'Package DPL Output';
  LibraryDCPOutputValueName  = 'Package DCP Output';
  BDSDebugDCUPathValueName   = 'Debug DCU Path';

  CppPathsKeyName            = 'CppPaths';
  CppPathsV5UpperKeyName     = 'C++\Paths';
  CppBrowsingPathValueName   = 'BrowsingPath';
  CppSearchPathValueName     = 'SearchPath';
  CppLibraryPathValueName    = 'LibraryPath';
  CppIncludePathValueName    = 'IncludePath';

  TransferKeyName            = 'Transfer';
  TransferCountValueName     = 'Count';
  TransferPathValueName      = 'Path%d';
  TransferParamsValueName    = 'Params%d';
  TransferTitleValueName     = 'Title%d';
  TransferWorkDirValueName   = 'WorkingDir%d';

  DisabledPackagesKeyName    = 'Disabled Packages';
  EnvVariablesKeyName        = 'Environment Variables';
  EnvVariableBDSValueName    = 'BDS';
  EnvVariableBDSPROJDIRValueName = 'BDSPROJECTSDIR';
  EnvVariableBDSCOMDIRValueName = 'BDSCOMMONDIR';
  KnownPackagesKeyName       = 'Known Packages';
  KnownIDEPackagesKeyName    = 'Known IDE Packages';
  ExpertsKeyName             = 'Experts';
  PackageCacheKeyName        = 'Package Cache';

  PaletteKeyName             = 'Palette';
  PaletteHiddenTag           = '.Hidden';

  {$IFDEF MSWINDOWS}
  VclIncludeDirName          = '%s\Include\Vcl\';
  {$IFDEF BCB}
  BorRADToolRepositoryFileName = 'bcb.dro';
  {$ELSE BCB}
  BorRADToolRepositoryFileName = 'delphi32.dro';
  {$ENDIF BCB}
  HelpContentFileName        = '%s\Help\%s%d.ohc';
  HelpIndexFileName          = '%s\Help\%s%d.ohi';
  HelpLinkFileName           = '%s\Help\%s%d.ohl';
  HelpProjectFileName        = '%s\Help\%s%d.ohp';
  HelpGidFileName            = '%s\Help\%s%d.gid';
  {$ENDIF MSWINDOWS}

  // MsBuild options
  MsBuildWin32DCPOutputNodeName = 'Win32DCPOutput';
  MsBuildWin32LibraryPathNodeName = 'Win32LibraryPath';
  MsBuildWin32BrowsingPathNodeName = 'Win32BrowsingPath';
  MsBuildWin32DebugDCUPathNodeName = 'Win32DebugDCUPath';
  MsBuildWin32DLLOutputPathNodeName = 'Win32DLLOutputPath';
  MsBuildDelphiDCPOutputNodeName = 'DelphiDCPOutput';
  MsBuildDelphiLibraryPathNodeName = 'DelphiLibraryPath';
  MsBuildDelphiBrowsingPathNodeName = 'DelphiBrowsingPath';
  MsBuildDelphiDebugDCUPathNodeName = 'DelphiDebugDCUPath';
  MsBuildDelphiDLLOutputPathNodeName = 'DelphiDLLOutputPath';
  MsBuildDelphiHPPOutputPathNodeName = 'DelphiHPPOutputPath';
  MsBuildCBuilderBPLOutputPathNodeName = 'CBuilderBPLOutputPath';
  MsBuildCBuilderBrowsingPathNodeName = 'CBuilderBrowsingPath';
  MsBuildCBuilderLibraryPathNodeName = 'CBuilderLibraryPath';
  MsBuildCBuilderIncludePathNodeName = 'CBuilderIncludePath';
  MsBuildPropertyGroupNodeName = 'PropertyGroup';

{$IFDEF MSWINDOWS}

type
  WideStringArray = array of WideString;

  TLoadResRec = record
    EnglishStr: WideStringArray;
    ResId: array of Integer;
  end;
  PLoadResRec = ^TLoadResRec;

// helper function to find strings in current string table
function LoadResCallBack(hModule: HMODULE; lpszType, lpszName: PChar;
  lParam: PLoadResRec): BOOL; stdcall;
var
  ResInfo, ResHData, ResSize, ResIndex: Cardinal;
  ResData: PWord;
  StrLength: Word;
  StrIndex, ResOffset, MatchCount, MatchLen: Integer;
begin
  Result := True;
  MatchCount := 0;

  ResInfo := FindResource(hModule, lpszName, lpszType);
  if ResInfo <> 0 then
  begin
    ResHData := LoadResource(hModule, ResInfo);
    if ResHData <> 0 then
    begin
      ResData := LockResource(ResHData);
      if Assigned(ResData) then
      begin
        ResSize := SizeofResource(hModule, ResInfo) div 2;
        ResIndex := 0;
        ResOffset := 0;
        while ResIndex < ResSize do
        begin
          StrLength := ResData^;
          Inc(ResData);
          Inc(ResIndex);
          // for each requested strings
          for StrIndex := Low(lParam^.EnglishStr) to High(lParam^.EnglishStr) do
          begin
            MatchLen := Length(lParam^.EnglishStr[StrIndex]);
            if (lParam^.ResId[StrIndex] = 0) and (StrLength = MatchLen)
              and (StrLICompW(PWideChar(lParam^.EnglishStr[StrIndex]), PWideChar(ResData), MatchLen) = 0) then
            begin // http://support.microsoft.com/kb/q196774/
              lParam^.ResId[StrIndex] := (PWord(@lpszName)^ - 1) * 16 + ResOffset;
              Inc(MatchCount);
              if MatchCount = Length(lParam^.EnglishStr) then
              begin
                Result := False;
                Break; // all requests were translated to ResId
              end;
            end;
          end;
          Inc(ResOffset);
          Inc(ResData, StrLength);
          Inc(ResIndex, StrLength);
        end;
      end;
    end;
  end;
end;

function LoadResStrings(const BaseBinName: string;
  const ResEn: array of WideString): WideStringArray;
var
  H: HMODULE;
  LocaleName: array [0..4] of Char;
  FileName: string;
  Index, NbRes: Integer;
  LoadResRec: TLoadResRec;
begin
  NbRes := Length(ResEn);
  SetLength(LoadResRec.EnglishStr, NbRes);
  SetLength(LoadResRec.ResId, NbRes);
  SetLength(Result, NbRes);

  for Index := Low(ResEn) to High(ResEn) do
    LoadResRec.EnglishStr[Index] := ResEn[Index];

  H := LoadLibraryEx(PChar(ChangeFileExt(BaseBinName, BinaryExtensionPackage)), 0,
    LOAD_LIBRARY_AS_DATAFILE or DONT_RESOLVE_DLL_REFERENCES);
  if H <> 0 then
    try
      EnumResourceNames(H, RT_STRING, @LoadResCallBack, LPARAM(@LoadResRec));
    finally
      FreeLibrary(H);
    end;

  FileName := '';

  ResetMemory(LocaleName, SizeOf(LocaleName));
  GetLocaleInfo(GetThreadLocale, LOCALE_SABBREVLANGNAME, LocaleName, SizeOf(LocaleName));
  if LocaleName[0] <> #0 then
  begin
    FileName := BaseBinName;
    if FileExists(FileName + LocaleName) then
      FileName := FileName + LocaleName
    else
    begin
      LocaleName[2] := #0;
      if FileExists(FileName + LocaleName) then
        FileName := FileName + LocaleName
      else
        FileName := '';
    end;
  end;

  if FileName <> '' then
  begin
    H := LoadLibraryEx(PChar(FileName), 0, LOAD_LIBRARY_AS_DATAFILE or DONT_RESOLVE_DLL_REFERENCES);
    if H <> 0 then
      try
        for Index := 0 to NbRes - 1 do
        begin
          SetLength(Result[Index], 1024);
          SetLength(Result[Index],
            LoadStringW(H, LoadResRec.ResId[Index], PWideChar(Result[Index]), Length(Result[Index]) - 1));
        end;
      finally
        FreeLibrary(H);
      end;
  end
  else
    Result := LoadResRec.EnglishStr;
end;

{$ENDIF MSWINDOWS}

//=== { TJclBorRADToolInstallationObject } ===================================

constructor TJclBorRADToolInstallationObject.Create(AInstallation: TJclBorRADToolInstallation);
begin
  FInstallation := AInstallation;
end;

//== { TJclBorRADToolIdeTool } ===============================================

constructor TJclBorRADToolIdeTool.Create(AInstallation: TJclBorRADToolInstallation);
begin
  inherited Create(AInstallation);
  FKey := TransferKeyName;
end;

procedure TJclBorRADToolIdeTool.CheckIndex(Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then
    raise EJclError.CreateRes(@RsEIndexOufOfRange);
end;

function TJclBorRADToolIdeTool.GetCount: Integer;
begin
  Result := Installation.ConfigData.ReadInteger(Key, TransferCountValueName, 0);
end;

function TJclBorRADToolIdeTool.GetParameters(Index: Integer): string;
begin
  CheckIndex(Index);
  Result := Installation.ConfigData.ReadString(Key, Format(TransferParamsValueName, [Index]), '');
end;

function TJclBorRADToolIdeTool.GetPath(Index: Integer): string;
begin
  CheckIndex(Index);
  Result := Installation.ConfigData.ReadString(Key, Format(TransferPathValueName, [Index]), '');
end;

function TJclBorRADToolIdeTool.GetTitle(Index: Integer): string;
begin
  CheckIndex(Index);
  Result := Installation.ConfigData.ReadString(Key, Format(TransferTitleValueName, [Index]), '');
end;

function TJclBorRADToolIdeTool.GetWorkingDir(Index: Integer): string;
begin
  CheckIndex(Index);
  Result := Installation.ConfigData.ReadString(Key, Format(TransferWorkDirValueName, [Index]), '');
end;

function TJclBorRADToolIdeTool.IndexOfPath(const Value: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if SamePath(Path[I], Value) then
    begin
      Result := I;
      Break;
    end;
end;

function TJclBorRADToolIdeTool.IndexOfTitle(const Value: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Title[I] = Value then
    begin
      Result := I;
      Break;
    end;
end;

procedure TJclBorRADToolIdeTool.RemoveIndex(const Index: Integer);
var
  I: Integer;
begin
  for I := Index to Count - 2 do
  begin
    Parameters[I] := Parameters[I + 1];
    Path[I] := Path[I + 1];
    Title[I] := Title[I + 1];
    WorkingDir[Index] := WorkingDir[I + 1];
  end;
  Count := Count - 1;
end;

procedure TJclBorRADToolIdeTool.SetCount(const Value: Integer);
begin
  if Value > Count then
    Installation.ConfigData.WriteInteger(Key, TransferCountValueName, Value);
end;

procedure TJclBorRADToolIdeTool.SetParameters(Index: Integer; const Value: string);
begin
  CheckIndex(Index);
  Installation.ConfigData.WriteString(Key, Format(TransferParamsValueName, [Index]), Value);
end;

procedure TJclBorRADToolIdeTool.SetPath(Index: Integer; const Value: string);
begin
  CheckIndex(Index);
  Installation.ConfigData.WriteString(Key, Format(TransferPathValueName, [Index]), Value);
end;

procedure TJclBorRADToolIdeTool.SetTitle(Index: Integer; const Value: string);
begin
  CheckIndex(Index);
  Installation.ConfigData.WriteString(Key, Format(TransferTitleValueName, [Index]), Value);
end;

procedure TJclBorRADToolIdeTool.SetWorkingDir(Index: Integer; const Value: string);
begin
  CheckIndex(Index);
  Installation.ConfigData.WriteString(Key, Format(TransferWorkDirValueName, [Index]), Value);
end;

//=== { TJclBorRADToolIdePackages } ==========================================

constructor TJclBorRADToolIdePackages.Create(AInstallation: TJclBorRADToolInstallation);
begin
  inherited Create(AInstallation);
  FDisabledPackages := TStringList.Create;
  FDisabledPackages.Sorted := True;
  FDisabledPackages.Duplicates := dupIgnore;
  FKnownPackages := TStringList.Create;
  FKnownPackages.Sorted := True;
  FKnownPackages.Duplicates := dupIgnore;
  FKnownIDEPackages := TStringList.Create;
  FKnownIDEPackages.Sorted := True;
  FKnownIDEPackages.Duplicates := dupIgnore;
  FExperts := TStringList.Create;
  FExperts.Sorted := True;
  FExperts.Duplicates := dupIgnore;
  ReadPackages;
end;

destructor TJclBorRADToolIdePackages.Destroy;
begin
  FreeAndNil(FDisabledPackages);
  FreeAndNil(FKnownPackages);
  FreeAndNil(FKnownIDEPackages);
  FreeAndNil(FExperts);
  inherited Destroy;
end;

function TJclBorRADToolIdePackages.AddPackage(const FileName, Description: string): Boolean;
begin
  Result := True;
  RemoveDisabled(FileName);
  Installation.ConfigData.WriteString(KnownPackagesKeyName, FileName, Description);
  ReadPackages;
end;

function TJclBorRADToolIdePackages.AddExpert(const FileName, Description: string): Boolean;
begin
  Result := True;
  RemoveDisabled(FileName);
  Installation.ConfigData.WriteString(ExpertsKeyName, Description, FileName);
  ReadPackages;
end;

function TJclBorRADToolIdePackages.AddIDEPackage(const FileName, Description: string): Boolean;
begin
  Result := True;
  RemoveDisabled(FileName);
  Installation.ConfigData.WriteString(KnownIDEPackagesKeyName, FileName, Description);
  ReadPackages;
end;

function TJclBorRADToolIdePackages.GetCount: Integer;
begin
  Result := FKnownPackages.Count;
end;

function TJclBorRADToolIdePackages.GetExpertCount: Integer;
begin
  Result := FExperts.Count;
end;

function TJclBorRADToolIdePackages.GetExpertDescriptions(Index: Integer): string;
begin
  Result := FExperts.Names[Index];
end;

function TJclBorRADToolIdePackages.GetExpertFileNames(Index: Integer): string;
begin
  Result := PackageEntryToFileName(FExperts.Values[FExperts.Names[Index]]);
end;

function TJclBorRADToolIdePackages.GetIDECount: Integer;
begin
  Result := FKnownIDEPackages.Count;
end;

function TJclBorRADToolIdePackages.GetPackageDescriptions(Index: Integer): string;
begin
  Result := FKnownPackages.Values[FKnownPackages.Names[Index]];
end;

function TJclBorRADToolIdePackages.GetIDEPackageDescriptions(Index: Integer): string;
begin
  Result := FKnownPackages.Values[FKnownIDEPackages.Names[Index]];
end;

function TJclBorRADToolIdePackages.GetPackageDisabled(Index: Integer): Boolean;
begin
  Result := Boolean(FKnownPackages.Objects[Index]);
end;

function TJclBorRADToolIdePackages.GetPackageFileNames(Index: Integer): string;
begin
  Result := PackageEntryToFileName(FKnownPackages.Names[Index]);
end;

function TJclBorRADToolIdePackages.GetIDEPackageFileNames(Index: Integer): string;
begin
  Result := PackageEntryToFileName(FKnownIDEPackages.Names[Index]);
end;

function TJclBorRADToolIdePackages.PackageEntryToFileName(const Entry: string): string;
begin
  Result := Installation.SubstitutePath(Entry);
end;

procedure TJclBorRADToolIdePackages.ReadPackages;
var
  I: Integer;

  procedure ReadPackageList(const Name: string; List: TStringList);
  var
    ListIsSorted: Boolean;
  begin
    ListIsSorted := List.Sorted;
    List.Sorted := False;
    List.Clear;
    Installation.ConfigData.ReadSectionValues(Name, List);
    List.Sorted := ListIsSorted;
  end;

begin
  if Installation.RadToolKind = brBorlandDevStudio then
    ReadPackageList(KnownIDEPackagesKeyName, FKnownIDEPackages);
  ReadPackageList(KnownPackagesKeyName, FKnownPackages);
  ReadPackageList(DisabledPackagesKeyName, FDisabledPackages);
  ReadPackageList(ExpertsKeyName, FExperts);
  for I := 0 to Count - 1 do
    if FDisabledPackages.IndexOfName(FKnownPackages.Names[I]) <> -1 then
      FKnownPackages.Objects[I] := Pointer(True);
end;

procedure TJclBorRADToolIdePackages.RemoveDisabled(const FileName: string);
var
  I: Integer;
begin
  for I := 0 to FDisabledPackages.Count - 1 do
    if SamePath(FileName, PackageEntryToFileName(FDisabledPackages.Names[I])) then
    begin
      Installation.ConfigData.DeleteKey(DisabledPackagesKeyName, FDisabledPackages.Names[I]);
      ReadPackages;
      Break;
    end;
end;

function TJclBorRADToolIdePackages.RemoveExpert(const FileName: string): Boolean;
var
  I: Integer;
  KnownExpertDescription, KnownExpert, KnownExpertFileName: string;
begin
  Result := False;
  for I := 0 to FExperts.Count - 1 do
  begin
    KnownExpertDescription := FExperts.Names[I];
    KnownExpert := FExperts.Values[KnownExpertDescription];
    KnownExpertFileName := PackageEntryToFileName(KnownExpert);
    if SamePath(FileName, KnownExpertFileName) then
    begin
      RemoveDisabled(KnownExpertFileName);
      Installation.ConfigData.DeleteKey(ExpertsKeyName, KnownExpertDescription);
      ReadPackages;
      Result := True;
      Break;
    end;
  end;
end;

function TJclBorRADToolIdePackages.RemovePackage(const FileName: string): Boolean;
var
  I: Integer;
  KnownPackage, KnownPackageFileName: string;
begin
  Result := False;
  for I := 0 to FKnownPackages.Count - 1 do
  begin
    KnownPackage := FKnownPackages.Names[I];
    KnownPackageFileName := PackageEntryToFileName(KnownPackage);
    if SamePath(FileName, KnownPackageFileName) then
    begin
      RemoveDisabled(KnownPackageFileName);
      Installation.ConfigData.DeleteKey(KnownPackagesKeyName, KnownPackage);
      ReadPackages;
      Result := True;
      Break;
    end;
  end;
end;

function TJclBorRADToolIdePackages.RemoveIDEPackage(const FileName: string): Boolean;
var
  I: Integer;
  KnownIDEPackage, KnownIDEPackageFileName: string;
begin
  Result := False;
  for I := 0 to FKnownIDEPackages.Count - 1 do
  begin
    KnownIDEPackage := FKnownIDEPackages.Names[I];
    KnownIDEPackageFileName := PackageEntryToFileName(KnownIDEPackage);
    if SamePath(FileName, KnownIDEPackageFileName) then
    begin
      RemoveDisabled(KnownIDEPackageFileName);
      Installation.ConfigData.DeleteKey(KnownIDEPackagesKeyName, KnownIDEPackage);
      ReadPackages;
      Result := True;
      Break;
    end;
  end;
end;

//=== { TJclBorRADToolPalette } ==============================================

constructor TJclBorRADToolPalette.Create(AInstallation: TJclBorRADToolInstallation);
begin
  inherited Create(AInstallation);
  FKey := PaletteKeyName;
  FTabNames := TStringList.Create;
  FTabNames.Sorted := True;
  ReadTabNames;
end;

destructor TJclBorRADToolPalette.Destroy;
begin
  FreeAndNil(FTabNames);
  inherited Destroy;
end;

procedure TJclBorRADToolPalette.ComponentsOnTabToStrings(Index: Integer; Strings: TStrings;
  IncludeUnitName: Boolean; IncludeHiddenComponents: Boolean);
var
  TempList: TStringList;

  procedure ProcessList(Hidden: Boolean);
  var
    D, I: Integer;
    List, S: string;
  begin
    if Hidden then
      List := HiddenComponentsOnTab[Index]
    else
      List := ComponentsOnTab[Index];
    List := StrEnsureSuffix(';', List);
    while Length(List) > 1 do
    begin
      D := Pos(';', List);
      S := Trim(Copy(List, 1, D - 1));
      if not IncludeUnitName then
        Delete(S, 1, Pos('.', S));
      if Hidden then
      begin
        I := TempList.IndexOf(S);
        if I = -1 then
          TempList.AddObject(S, Pointer(True))
        else
          TempList.Objects[I] := Pointer(True);
      end
      else
        TempList.Add(S);
      Delete(List, 1, D);
    end;
  end;

begin
  TempList := TStringList.Create;
  try
    TempList.Duplicates := dupError;
    ProcessList(False);
    TempList.Sorted := True;
    if IncludeHiddenComponents then
      ProcessList(True);
    Strings.AddStrings(TempList);
  finally
    TempList.Free;
  end;
end;

function TJclBorRADToolPalette.DeleteTabName(const TabName: string): Boolean;
var
  I: Integer;
begin
  I := FTabNames.IndexOf(TabName);
  Result := I >= 0;
  if Result then
  begin
    Installation.ConfigData.DeleteKey(Key, FTabNames[I]);
    Installation.ConfigData.DeleteKey(Key, FTabNames[I] + PaletteHiddenTag);
    FTabNames.Delete(I);
  end;
end;

function TJclBorRADToolPalette.GetComponentsOnTab(Index: Integer): string;
begin
  Result := Installation.ConfigData.ReadString(Key, FTabNames[Index], '');
end;

function TJclBorRADToolPalette.GetHiddenComponentsOnTab(Index: Integer): string;
begin
  Result := Installation.ConfigData.ReadString(Key, FTabNames[Index] + PaletteHiddenTag, '');
end;

function TJclBorRADToolPalette.GetTabNameCount: Integer;
begin
  Result := FTabNames.Count;
end;

function TJclBorRADToolPalette.GetTabNames(Index: Integer): string;
begin
  Result := FTabNames[Index];
end;

procedure TJclBorRADToolPalette.ReadTabNames;
var
  TempList: TStringList;
  I: Integer;
  S: string;
begin
  if Installation.ConfigData.SectionExists(Key) then
  begin
    TempList := TStringList.Create;
    try
      Installation.ConfigData.ReadSection(Key, TempList);
      for I := 0 to TempList.Count - 1 do
      begin
        S := TempList[I];
        if Pos(PaletteHiddenTag, S) = 0 then
          FTabNames.Add(S);
      end;
    finally
      TempList.Free;
    end;
  end;
end;

function TJclBorRADToolPalette.TabNameExists(const TabName: string): Boolean;
begin
  Result := FTabNames.IndexOf(TabName) <> -1;
end;

//=== { TJclBorRADToolRepository } ===========================================

constructor TJclBorRADToolRepository.Create(AInstallation: TJclBorRADToolInstallation);
begin
  inherited Create(AInstallation);
  FFileName := AInstallation.BinFolderName + BorRADToolRepositoryFileName;
  FPages := TStringList.Create;
  IniFile.ReadSection(BorRADToolRepositoryPagesSection, FPages);
  CloseIniFile;
end;

destructor TJclBorRADToolRepository.Destroy;
begin
  FreeAndNil(FPages);
  FreeAndNil(FIniFile);
  inherited Destroy;
end;

procedure TJclBorRADToolRepository.AddObject(const FileName, ObjectType, PageName, ObjectName,
  IconFileName, Description, Author, Designer: string; const Ancestor: string);
var
  SectionName: string;
begin
  GetIniFile;
  SectionName := AnsiUpperCase(PathRemoveExtension(FileName));
  FIniFile.EraseSection(FileName);
  FIniFile.EraseSection(SectionName);
  FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectType, ObjectType);
  FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectName, ObjectName);
  FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectPage, PageName);
  FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectIcon, IconFileName);
  FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectDescr, Description);
  FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectAuthor, Author);
  if Ancestor <> '' then
    FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectAncestor, Ancestor);
  if (Installation.RadToolKind = brBorlandDevStudio) or (Installation.VersionNumber >= 6) then
    FIniFile.WriteString(SectionName, BorRADToolRepositoryObjectDesigner, Designer);
  FIniFile.WriteBool(SectionName, BorRADToolRepositoryObjectNewForm, False);
  FIniFile.WriteBool(SectionName, BorRADToolRepositoryObjectMainForm, False);
  CloseIniFile;
end;

procedure TJclBorRADToolRepository.CloseIniFile;
begin
  FreeAndNil(FIniFile);
end;

function TJclBorRADToolRepository.FindPage(const Name: string; OptionalIndex: Integer): string;
var
  I: Integer;
begin
  I := Pages.IndexOf(Name);
  if I >= 0 then
    Result := Pages[I]
  else
  if OptionalIndex < Pages.Count then
    Result := Pages[OptionalIndex]
  else
    Result := '';
end;

function TJclBorRADToolRepository.GetIniFile: TIniFile;
begin
  if not Assigned(FIniFile) then
    FIniFile := TIniFile.Create(FileName);
  Result := FIniFile;
end;

function TJclBorRADToolRepository.GetPages: TStrings;
begin
  Result := FPages;
end;

procedure TJclBorRADToolRepository.RemoveObjects(const PartialPath, FileName, ObjectType: string);
var
  Sections: TStringList;
  I: Integer;
  SectionName, FileNamePart, PathPart, DialogFileName: string;
begin
  Sections := TStringList.Create;
  try
    GetIniFile;
    FIniFile.ReadSections(Sections);
    for I := 0 to Sections.Count - 1 do
    begin
      SectionName := Sections[I];
      if FIniFile.ReadString(SectionName, BorRADToolRepositoryObjectType, '') = ObjectType then
      begin
        FileNamePart := PathExtractFileNameNoExt(SectionName);
        PathPart := StrRight(PathAddSeparator(ExtractFilePath(SectionName)), Length(PartialPath));
        DialogFileName := PathExtractFileNameNoExt(FileName);
        if StrSame(FileNamePart, DialogFileName) and StrSame(PathPart, PartialPath) then
          FIniFile.EraseSection(SectionName);
      end;
    end;
  finally
    Sections.Free;
  end;
end;

//=== { TJclBorRADToolInstallation } =========================================

constructor TJclBorRADToolInstallation.Create(const AConfigDataLocation: string; ARootKey: Cardinal);
{$IFDEF MSWINDOWS}
var
  HelpPrefix: string;
{$ENDIF MSWINDOWS}
begin
  inherited Create;
  FConfigDataLocation := AConfigDataLocation;
  FConfigData := TRegistryIniFile.Create(AConfigDataLocation);
  if ARootKey = 0 then
    FRootKey := HKCU
  else
    FRootKey := ARootKey;
  TRegistryIniFile(FConfigData).RegIniFile.RootKey := RootKey;
  TRegistryIniFile(FConfigData).RegIniFile.OpenKey(AConfigDataLocation, True);
  FGlobals := TStringList.Create;
  ReadInformation;
  FIdeTools := TJclBorRADToolIdeTool.Create(Self);
  {$IFDEF MSWINDOWS}
  case RadToolKind of
    brDelphi:
      if VersionNumber <= 6 then
        HelpPrefix := 'delphi' + IntToStr(VersionNumber)
      else
        HelpPrefix := 'd' + IntToStr(VersionNumber);
    brCppBuilder:
      HelpPrefix := 'bcb' + IntToStr(VersionNumber);
    else
      HelpPrefix := '';
  end;
  FOpenHelp := TJclBorlandOpenHelp.Create(RootDir, HelpPrefix);
  {$ENDIF ~MSWINDOWS}
  FMapCreate := False;
  {$IFDEF MSWINDOWS}
  FJdbgCreate := False;
  FJdbgInsert := False;
  FMapDelete := False;
  if FileExists(BinFolderName + AsmExeName) then
    Include(FCommandLineTools, clAsm);
  {$ENDIF ~MSWINDOWS}
  if FileExists(BinFolderName + BCC32ExeName) then
    Include(FCommandLineTools, clBcc32);
  if FileExists(BinFolderName + DCC32ExeName) then
    Include(FCommandLineTools, clDcc32);
  {$IFDEF MSWINDOWS}
  if FileExists(BinFolderName + DCCILExeName) then
    Include(FCommandLineTools, clDccIL);
  {$ENDIF ~MSWINDOWS}
  if FileExists(BinFolderName + MakeExeName) then
    Include(FCommandLineTools, clMake);
  if FileExists(BinFolderName + Bpr2MakExeName) then
    Include(FCommandLineTools, clProj2Mak);
end;

destructor TJclBorRADToolInstallation.Destroy;
begin
  FreeAndNil(FRepository);
  FreeAndNil(FDCC32);
  FreeAndNil(FBCC32);
  FreeAndNil(FBpr2Mak);
  FreeAndNil(FIdePackages);
  FreeAndNil(FIdeTools);
  {$IFDEF MSWINDOWS}
  FreeAndNil(FOpenHelp);
  {$ENDIF MSWINDOWS}
  FreeAndNil(FPalette);
  FreeAndNil(FGlobals);
  FreeAndNil(FEnvironmentVariables);
  FreeAndNil(FConfigData);
  inherited Destroy;
end;

function TJclBorRADToolInstallation.AddToDebugDCUPath(const Path: string): Boolean;
var
  TempDebugDCUPath: TJclBorRADToolPath;
begin
  if Path <> '' then
  begin
    TempDebugDCUPath := DebugDCUPath;
    PathListIncludeItems(TempDebugDCUPath, Path);
    Result := True;
    DebugDCUPath := TempDebugDCUPath;
  end
  else
    Result := False;
end;

function TJclBorRADToolInstallation.AddToLibrarySearchPath(const Path: string): Boolean;
var
  TempLibraryPath: TJclBorRADToolPath;
begin
  if Path <> '' then
  begin
    TempLibraryPath := LibrarySearchPath;
    PathListIncludeItems(TempLibraryPath, Path);
    Result := True;
    LibrarySearchPath := TempLibraryPath;
  end
  else
    Result := False;
end;

function TJclBorRADToolInstallation.AddToLibraryBrowsingPath(const Path: string): Boolean;
var
  TempLibraryPath: TJclBorRADToolPath;
begin
  if Path <> '' then
  begin
    TempLibraryPath := LibraryBrowsingPath;
    PathListIncludeItems(TempLibraryPath, Path);
    Result := True;
    LibraryBrowsingPath := TempLibraryPath;
  end
  else
    Result := False;
end;

function TJclBorRADToolInstallation.AnyInstanceRunning: Boolean;
var
  Processes: TStringList;
  I: Integer;
begin
  Result := False;
  Processes := TStringList.Create;
  try
    if RunningProcessesList(Processes) then
    begin
      for I := 0 to Processes.Count - 1 do
        if AnsiSameText(IdeExeFileName, Processes[I]) then
        begin
          Result := True;
          Break;
        end;
    end;
  finally
    Processes.Free;
  end;
end;

class procedure TJclBorRADToolInstallation.ExtractPaths(const Path: TJclBorRADToolPath; List: TStrings);
begin
  StrToStrings(Path, PathSep, List);
end;

function TJclBorRADToolInstallation.CompileBCBPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  SaveDir, PackagePath, MakeFileName: string;
begin
  OutputString(Format(LoadResString(@RsCompilingPackage), [PackageName]));

  if not IsBCBPackage(PackageName) then
    raise EJclBorRADException.CreateResFmt(@RsENotABCBPackage, [PackageName]);

  PackagePath := PathRemoveSeparator(ExtractFilePath(PackageName));
  SaveDir := GetCurrentDir;
  SetCurrentDir(PackagePath);
  try
    MakeFileName := StrTrimQuotes(ChangeFileExt(PackageName, '.mak'));
    if clProj2Mak in CommandLineTools then       // let bpr2mak generate make file from .bpk
      Result := Bpr2Mak.Execute(StringsToStr(Bpr2Mak.Options, ' ') + ' ' + ExtractFileName(PackageName))
    else
      // If make file exists (and doesn't need to be created by bpr2mak)
      Result := FileExists(MakeFileName);

    if MapCreate then
      Make.Options.Add('-DMAPFLAGS=-s');

    Result := Result and
      Make.Execute(Format('%s -f%s', [StringsToStr(Make.Options, ' '), StrDoubleQuote(MakeFileName)])) and
      ProcessMapFile(BinaryFileName(BPLPath, PackageName));
  finally
    SetCurrentDir(SaveDir);
  end;

  if Result then
    OutputString(LoadResString(@RsCompilationOk))
  else
    OutputString(LoadResString(@RsCompilationFailed));
end;

function TJclBorRADToolInstallation.CompileBCBProject(const ProjectName, OutputDir, DcpSearchPath: string): Boolean;
var
  SaveDir, PackagePath, MakeFileName: string;
begin
  OutputString(Format(LoadResString(@RsCompilingProject), [ProjectName]));

  if not IsBCBProject(ProjectName) then
    raise EJclBorRADException.CreateResFmt(@RsENotADelphiProject, [ProjectName]);

  PackagePath := PathRemoveSeparator(ExtractFilePath(ProjectName));
  SaveDir := GetCurrentDir;
  SetCurrentDir(PackagePath);
  try
    MakeFileName := StrTrimQuotes(ChangeFileExt(ProjectName, '.mak'));
    if clProj2Mak in CommandLineTools then       // let bpr2mak generate make file from .bpk
      Result := Bpr2Mak.Execute(StringsToStr(Bpr2Mak.Options, ' ') + ' ' + ExtractFileName(ProjectName))
    else
      // If make file exists (and doesn't need to be created by bpr2mak)
      Result := FileExists(MakeFileName);

    if MapCreate then
      Make.Options.Add('-DMAPFLAGS=-s');

    Result := Result and
      Make.Execute(Format('%s -f%s', [StringsToStr(Make.Options, ' '), StrDoubleQuote(MakeFileName)])) and
      ProcessMapFile(BinaryFileName(OutputDir, ProjectName));
  finally
    SetCurrentDir(SaveDir);
  end;

  if Result then
    OutputString(LoadResString(@RsCompilationOk))
  else
    OutputString(LoadResString(@RsCompilationFailed));
end;

function TJclBorRADToolInstallation.CompileDelphiPackage(const PackageName,
  BPLPath, DCPPath: string): Boolean;
begin
  Result := CompileDelphiPackage(PackageName, BPLPath, DCPPath, '');
end;

function TJclBorRADToolInstallation.CompileDelphiPackage(const PackageName,
  BPLPath, DCPPath, ExtraOptions: string): Boolean;
var
  NewOptions: string;
begin
  OutputString(Format(LoadResString(@RsCompilingPackage), [PackageName]));

  if not IsDelphiPackage(PackageName) then
    raise EJclBorRADException.CreateResFmt(@RsENotADelphiPackage, [PackageName]);

  if MapCreate then
    NewOptions := ExtraOptions + ' -GD'
  else
    NewOptions := ExtraOptions;

  Result := DCC32.MakePackage(PackageName, BPLPath, DCPPath, NewOptions) and
    ProcessMapFile(BinaryFileName(BPLPath, PackageName));

  if Result then
    OutputString(LoadResString(@RsCompilationOk))
  else
    OutputString(LoadResString(@RsCompilationFailed));
end;

function TJclBorRADToolInstallation.CompileDelphiProject(const ProjectName,
  OutputDir, DcpSearchPath: string): Boolean;
var
  ExtraOptions: string;
begin
  OutputString(Format(LoadResString(@RsCompilingProject), [ProjectName]));

  if not IsDelphiProject(ProjectName) then
    raise EJclBorRADException.CreateResFmt(@RsENotADelphiProject, [ProjectName]);

  if MapCreate then
    ExtraOptions := '-GD'
  else
    ExtraOptions := '';

  Result := DCC32.MakeProject(ProjectName, OutputDir, DcpSearchPath, ExtraOptions) and
    ProcessMapFile(BinaryFileName(OutputDir, ProjectName));

  if Result then
    OutputString(LoadResString(@RsCompilationOk))
  else
    OutputString(LoadResString(@RsCompilationFailed));
end;

function TJclBorRADToolInstallation.CompilePackage(const PackageName, BPLPath,
  DCPPath: string): Boolean;
var
  PackageExtension: string;
begin
  PackageExtension := ExtractFileExt(PackageName);
  if SameText(PackageExtension, SourceExtensionBCBPackage) then
    Result := CompileBCBPackage(PackageName, BPLPath, DCPPath)
  else
  if SameText(PackageExtension, SourceExtensionDelphiPackage) then
    Result := CompileDelphiPackage(PackageName, BPLPath, DCPPath)
  else
    raise EJclBorRadException.CreateResFmt(@RsEUnknownPackageExtension, [PackageExtension]);
end;

function TJclBorRADToolInstallation.CompileProject(const ProjectName,
  OutputDir, DcpSearchPath: string): Boolean;
var
  ProjectExtension: string;
begin
  ProjectExtension := ExtractFileExt(ProjectName);
  if SameText(ProjectExtension, SourceExtensionBCBProject) then
    Result := CompileBCBProject(ProjectName, OutputDir, DcpSearchPath)
  else
  if SameText(ProjectExtension, SourceExtensionDelphiProject) then
    Result := CompileDelphiProject(ProjectName, OutputDir, DcpSearchPath)
  else
    raise EJclBorRadException.CreateResFmt(@RsEUnknownProjectExtension, [ProjectExtension]);
end;

function TJclBorRADToolInstallation.FindFolderInPath(Folder: string; List: TStrings): Integer;
var
  I: Integer;
begin
  Result := -1;
  Folder := PathRemoveSeparator(Folder);
  for I := 0 to List.Count - 1 do
    if SamePath(Folder, PathRemoveSeparator(SubstitutePath(List[I]))) then
    begin
      Result := I;
      Break;
    end;
end;

function TJclBorRADToolInstallation.GetBPLOutputPath: string;
begin
  Result := SubstitutePath(ConfigData.ReadString(LibraryKeyName, LibraryBPLOutputValueName, ''));
end;

function TJclBorRADToolInstallation.GetBpr2Mak: TJclBpr2Mak;
begin
  if not Assigned(FBpr2Mak) then
  begin
    if not (clProj2Mak in CommandLineTools) then
      raise EJclBorRadException.CreateResFmt(@RsENotFound, [Bpr2MakExeName]);
    FBpr2Mak := TJclBpr2Mak.Create(BinFolderName, LongPathBug, CompilerSettingsFormat);
  end;
  Result := FBpr2Mak;
end;

function TJclBorRADToolInstallation.GetBCC32: TJclBCC32;
begin
  if not Assigned(FBCC32) then
  begin
    if not (clBcc32 in CommandLineTools) then
      raise EJclBorRadException.CreateResFmt(@RsENotFound, [Bcc32ExeName]);
    FBCC32 := TJclBCC32.Create(BinFolderName, LongPathBug, CompilerSettingsFormat);
  end;
  Result := FBCC32;
end;

function TJclBorRADToolInstallation.GetCommonProjectsDir: string;
begin
  Result := DefaultProjectsDir;
end;

function TJclBorRADToolInstallation.GetCompilerSettingsFormat: TJclCompilerSettingsFormat;
begin
  if (RadToolKind = brBorlandDevStudio) and (VersionNumber >= 5) then
    Result := csfMsBuild
  else
  if RadToolKind = brBorlandDevStudio then
    Result := csfBDSProj
  else
    Result := csfDOF;
end;

function TJclBorRADToolInstallation.GetDCC32: TJclDCC32;
begin
  if not Assigned(FDCC32) then
  begin
    if not (clDcc32 in CommandLineTools) then
      raise EJclBorRadException.CreateResFmt(@RsENotFound, [Dcc32ExeName]);
    FDCC32 := TJclDCC32.Create(BinFolderName, LongPathBug, CompilerSettingsFormat,
                               SupportsNoConfig, DCPOutputPath, LibFolderName, LibDebugFolderName, ObjFolderName);
  end;
  Result := FDCC32;
end;

function TJclBorRADToolInstallation.GetDCPOutputPath: string;
begin
  Result := SubstitutePath(ConfigData.ReadString(LibraryKeyName, LibraryDCPOutputValueName, ''));
end;

function TJclBorRADToolInstallation.GetDebugDCUPath: string;
begin
  Result := ConfigData.ReadString(DebuggingKeyName, DebugDCUPathValueName, '');
end;

function TJclBorRADToolInstallation.GetDefaultProjectsDir: string;
begin
  Result := Globals.Values['DefaultProjectsDirectory'];
  if Result = '' then
    Result := PathAddSeparator(RootDir) + 'Projects';
end;

function TJclBorRADToolInstallation.GetDescription: TJclBorRADToolPath;
begin
  Result := Format('%s %s', [Name, EditionAsText]);
  if InstalledUpdatePack > 0 then
    Result := Result + ' ' + Format(LoadResString(@RsUpdatePackName), [InstalledUpdatePack]);
end;

function TJclBorRADToolInstallation.GetEditionAsText: string;
begin
  Result := FEditionStr;
  if Length(FEditionStr) = 3 then
    case Edition of
      deSTD:
        if (VersionNumber >= 6) or (RadToolKind = brBorlandDevStudio) then
          Result := LoadResString(@RsPersonal)
        else
          Result := LoadResString(@RsStandard);
      dePRO:
        Result := LoadResString(@RsProfessional);
      deCSS:
        if (VersionNumber >= 5) or (RadToolKind = brBorlandDevStudio) then
          Result := LoadResString(@RsEnterprise)
        else
          Result := LoadResString(@RsClientServer);
      deARC:
        Result := LoadResString(@RsArchitect);
    end;
end;

function TJclBorRADToolInstallation.GetDefaultBDSCommonDir: string;
const
  CSIDL_COMMON_DOCUMENTS = $002E; // All Users\Documents
var
  CommonDocuments: array[0..MAX_PATH] of Char;
begin
  if (RadToolKind = brBorlandDevStudio) and (IDEVersionNumber >= 6) and
     SHGetSpecialFolderPath(GetActiveWindow, CommonDocuments, CSIDL_COMMON_DOCUMENTS, False) then
    Result := IncludeTrailingPathDelimiter(CommonDocuments) + RADStudioDirName  + PathDelim + Format('%d.0', [IDEVersionNumber])
  else
    Result := GetEnvironmentVariable(EnvVariableBDSCOMDIRValueName);
end;

function TJclBorRADToolInstallation.GetEnvironmentVariables: TStrings;
var
  EnvNames: TStringList;
  EnvVarKeyName: string;
  I: Integer;
begin
  if FEnvironmentVariables = nil then
  begin
    FEnvironmentVariables := TStringList.Create;

    // at first get system environment variables
    JclSysInfo.GetEnvironmentVars(FEnvironmentVariables, True);
    for I := FEnvironmentVariables.count-1 downto 0 do
      if FEnvironmentVariables.Names[I] = EmptyStr then
        FEnvironmentVariables.Delete(I);

    // Overwrite BDSCommonDir because it conflicts with older versions and
    // the RAD Studio 2009 setup doesn't update the environment variable anymore
    if (RadToolKind = brBorlandDevStudio) and (IDEVersionNumber >= 6) then
      FEnvironmentVariables.Values[EnvVariableBDSCOMDIRValueName] := GetDefaultBDSCommonDir;

    // read environment variable overrides
    if ((VersionNumber >= 6) or (RadToolKind = brBorlandDevStudio)) and
      ConfigData.SectionExists(EnvVariablesKeyName) then
    begin
      EnvNames := TStringList.Create;
      try
        ConfigData.ReadSection(EnvVariablesKeyName, EnvNames);
        for I := 0 to EnvNames.Count - 1 do
        begin
          EnvVarKeyName := EnvNames[I];
          FEnvironmentVariables.Values[EnvVarKeyName] :=
            ConfigData.ReadString(EnvVariablesKeyName, EnvVarKeyName, '');
        end;
      finally
        EnvNames.Free;
      end;
    end;
  end;
  Result := FEnvironmentVariables;
end;

function TJclBorRADToolInstallation.GetGlobals: TStrings;
begin
  Result := FGlobals;
end;

function TJclBorRADToolInstallation.GetIdeExeFileName: string;
begin
  Result := Globals.Values['App'];
end;

function TJclBorRADToolInstallation.GetIdeExeBuildNumber: string;
begin
  Result := VersionFixedFileInfoString(IdeExeFileName, vfFull);
end;

function TJclBorRADToolInstallation.GetIdePackages: TJclBorRADToolIdePackages;
begin
  if not Assigned(FIdePackages) then
    FIdePackages := TJclBorRADToolIdePackages.Create(Self);
  Result := FIdePackages;
end;

function TJclBorRADToolInstallation.GetIsTurboExplorer: Boolean;
begin
  Result := (RadToolKind = brBorlandDevStudio) and (VersionNumber = 4) and not (clDcc32 in CommandLineTools);
end;

function TJclBorRADToolInstallation.GetLatestUpdatePack: Integer;
begin
  Result := GetLatestUpdatePackForVersion(VersionNumber);
end;

class function TJclBorRADToolInstallation.GetLatestUpdatePackForVersion(Version: Integer): Integer;
begin
  {$IFDEF MSWINDOWS}
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']); // BCB doesn't support abstract keyword
  // dummy; BCB doesn't like abstract class functions
  {$ELSE MSWINDOWS}
  Result := 0;
  {$ENDIF MSWINDOWS}
end;

function TJclBorRADToolInstallation.GetLibrarySearchPath: TJclBorRADToolPath;
begin
  Result := ConfigData.ReadString(LibraryKeyName, LibrarySearchPathValueName, '');
end;

function TJclBorRADToolInstallation.GetLongPathBug: Boolean;
begin
  Result := (RadToolKind in [brDelphi, brCppBuilder]) or (VersionNumber < 3);
end;

function TJclBorRADToolInstallation.GetMake: IJclCommandLineTool;
begin
  if not Assigned(FMake) then
  begin
    if not (clMake in CommandLineTools) then
      raise EJclBorRadException.CreateResFmt(@RsENotFound, [MakeExeName]);
    FMake := TJclBorlandMake.Create(BinFolderName, LongPathBug, CompilerSettingsFormat);
    // Set option "-l+", which enables use of long command lines.  Should be
    // default, but there have been reports indicating that's not always the case.
    FMake.Options.Add('-l+');
  end;
  Result := FMake;
end;

function TJclBorRADToolInstallation.GetLibraryBrowsingPath: TJclBorRADToolPath;
begin
  Result := ConfigData.ReadString(LibraryKeyName, LibraryBrowsingPathValueName, '');
end;

function TJclBorRADToolInstallation.GetName: string;
begin
  Result := Format('%s %d', [RADToolName, IDEVersionNumber]);
end;

function TJclBorRADToolInstallation.GetPalette: TJclBorRADToolPalette;
begin
  if not Assigned(FPalette) then
    FPalette := TJclBorRADToolPalette.Create(Self);
  Result := FPalette;
end;

function TJclBorRADToolInstallation.GetRepository: TJclBorRADToolRepository;
begin
  if not Assigned(FRepository) then
    FRepository := TJclBorRADToolRepository.Create(Self);
  Result := FRepository;
end;

function TJclBorRADToolInstallation.GetSupportsLibSuffix: Boolean;
begin
  Result := (RadToolKind = brBorlandDevStudio) or (VersionNumber >= 6);
end;

function TJclBorRADToolInstallation.GetSupportsNoConfig: Boolean;
begin
  Result := (RadToolKind = brBorlandDevStudio) and (VersionNumber >= 4);
end;

function TJclBorRADToolInstallation.GetUpdateNeeded: Boolean;
begin
  Result := InstalledUpdatePack < LatestUpdatePack;
end;

function TJclBorRADToolInstallation.GetValid: Boolean;
begin
  Result := (ConfigData.FileName <> '') and (RootDir <> '') and FileExists(IdeExeFileName);
end;

function TJclBorRADToolInstallation.GetVclIncludeDir: string;
begin
  Result := Format(VclIncludeDirName, [RootDir]);
  if not DirectoryExists(Result) then
    Result := '';
end;

function TJclBorRADToolInstallation.InstallBCBExpert(const ProjectName, OutputDir, DcpSearchPath: string): Boolean;
var
  Unused, Description: string;
begin
  OutputString(Format(LoadResString(@RsExpertInstallationStarted), [ProjectName]));

  GetBPRFileInfo(ProjectName, Unused, @Description);

  Result := CompileBCBProject(ProjectName, OutputDir, DcpSearchPath) and
    RegisterExpert(BinaryFileName(OutputDir, ProjectName), Description);

  OutputString(LoadResString(@RsExpertInstallationFinished));
end;

function TJclBorRADToolInstallation.InstallBCBIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  RunOnly: Boolean;
  Unused, Description: string;
begin
  OutputString(Format(LoadResString(@RsIdePackageInstallationStarted), [PackageName]));

  GetBPKFileInfo(PackageName, RunOnly, @Unused, @Description);
  if RunOnly then
    raise EJclBorRadException.CreateResFmt(@RsECannotInstallRunOnly, [PackageName]);

  Result := CompileBCBPackage(PackageName, BPLPath, DCPPath) and
    RegisterIdePackage(BinaryFileName(BPLPath, PackageName), Description);

  OutputString(LoadResString(@RsIdePackageInstallationFinished));
end;

function TJclBorRADToolInstallation.InstallBCBPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  RunOnly: Boolean;
  Unused, Description: string;
begin
  OutputString(Format(LoadResString(@RsPackageInstallationStarted), [PackageName]));

  GetBPKFileInfo(PackageName, RunOnly, @Unused, @Description);
  if RunOnly then
    raise EJclBorRadException.CreateResFmt(@RsECannotInstallRunOnly, [PackageName]);

  Result := CompileBCBPackage(PackageName, BPLPath, DCPPath) and
    RegisterPackage(BinaryFileName(BPLPath, PackageName), Description);

  OutputString(LoadResString(@RsPackageInstallationFinished));
end;

function TJclBorRADToolInstallation.InstallDelphiExpert(const ProjectName, OutputDir, DcpSearchPath: string): Boolean;
var
  BaseName: string;
begin
  OutputString(Format(LoadResString(@RsExpertInstallationStarted), [ProjectName]));

  BaseName := PathExtractFileNameNoExt(ProjectName);

  Result := CompileDelphiProject(ProjectName, OutputDir, DcpSearchPath) and
    RegisterExpert(BinaryFileName(OutputDir, ProjectName), BaseName);

  OutputString(LoadResString(@RsExpertInstallationFinished));
end;

function TJclBorRADToolInstallation.InstallDelphiIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  RunOnly: Boolean;
  Unused, Description: string;
begin
  OutputString(Format(LoadResString(@RsIdePackageInstallationStarted), [PackageName]));

  GetDPKFileInfo(PackageName, RunOnly, @Unused, @Description);
  if RunOnly then
    raise EJclBorRadException.CreateResFmt(@RsECannotInstallRunOnly, [PackageName]);

  Result := CompileDelphiPackage(PackageName, BPLPath, DCPPath) and
    RegisterIdePackage(BinaryFileName(BPLPath, PackageName), Description);

  OutputString(LoadResString(@RsIdePackageInstallationFinished));
end;

function TJclBorRADToolInstallation.InstallDelphiPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  RunOnly: Boolean;
  Unused, Description: string;
begin
  OutputString(Format(LoadResString(@RsPackageInstallationStarted), [PackageName]));

  GetDPKFileInfo(PackageName, RunOnly, @Unused, @Description);
  if RunOnly then
    raise EJclBorRadException.CreateResFmt(@RsECannotInstallRunOnly, [PackageName]);

  Result := CompileDelphiPackage(PackageName, BPLPath, DCPPath) and
    RegisterPackage(BinaryFileName(BPLPath, PackageName), Description);

  OutputString(LoadResString(@RsPackageInstallationFinished));
end;

function TJclBorRADToolInstallation.InstallExpert(const ProjectName, OutputDir, DcpSearchPath: string): Boolean;
var
  ProjectExtension: string;
begin
  ProjectExtension := ExtractFileExt(ProjectName);
  if SameText(ProjectExtension, SourceExtensionBCBProject) then
    Result := InstallBCBExpert(ProjectName, OutputDir, DcpSearchPath)
  else
  if SameText(ProjectExtension, SourceExtensionDelphiProject) then
    Result := InstallDelphiExpert(ProjectName, OutputDir, DcpSearchPath)
  else
    raise EJclBorRADException.CreateResFmt(@RsEUnknownProjectExtension, [ProjectExtension]);
end;

function TJclBorRADToolInstallation.InstallIDEPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  PackageExtension: string;
begin
  PackageExtension := ExtractFileExt(PackageName);
  if SameText(PackageExtension, SourceExtensionBCBPackage) then
    Result := InstallBCBIdePackage(PackageName, BPLPath, DCPPath)
  else
  if SameText(PackageExtension, SourceExtensionDelphiPackage) then
    Result := InstallDelphiIdePackage(PackageName, BPLPath, DCPPath)
  else
    raise EJclBorRADException.CreateResFmt(@RsEUnknownIdePackageExtension, [PackageExtension]);
end;

function TJclBorRADToolInstallation.InstallPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  PackageExtension: string;
begin
  PackageExtension := ExtractFileExt(PackageName);
  if SameText(PackageExtension, SourceExtensionBCBPackage) then
    Result := InstallBCBPackage(PackageName, BPLPath, DCPPath)
  else
  if SameText(PackageExtension, SourceExtensionDelphiPackage) then
    Result := InstallDelphiPackage(PackageName, BPLPath, DCPPath)
  else
    raise EJclBorRADException.CreateResFmt(@RsEUnknownPackageExtension, [PackageExtension]);
end;

function TJclBorRADToolInstallation.LibDebugFolderName: string;
begin
  if (RadToolKind = brBorlandDevStudio) and (VersionNumber >= 8) then
    Result := PathAddSeparator(RootDir) + PathAddSeparator('lib\win32\debug')
  else
    Result := LibFolderName + PathAddSeparator('debug');
end;

function TJclBorRADToolInstallation.LibFolderName: string;
begin
  if (RadToolKind = brBorlandDevStudio) and (VersionNumber >= 8) then
    Result := PathAddSeparator(RootDir) + PathAddSeparator('lib\win32\release')
  else
    Result := PathAddSeparator(RootDir) + PathAddSeparator('lib');
end;

function TJclBorRADToolInstallation.ObjFolderName: string;
begin
  if RadToolKind = brCppBuilder then
    Result := LibFolderName + PathAddSeparator('obj')
  else
    Result := '';
end;

function TJclBorRADToolInstallation.ProcessMapFile(const BinaryFileName: string): Boolean;
{$IFDEF MSWINDOWS}
var
  MAPFileName, LinkerBugUnit: string;
  MAPFileSize, JclDebugDataSize: Integer;
{$ENDIF MSWINDOWS}
begin
  {$IFDEF MSWINDOWS}
  if JdbgCreate then
  begin
    MAPFileName := ChangeFileExt(BinaryFileName, CompilerExtensionMAP);

    if JdbgInsert then
    begin
      OutputString(Format(LoadResString(@RsInsertingJdbg), [BinaryFileName]));
      Result := InsertDebugDataIntoExecutableFile(BinaryFileName, MAPFileName,
        LinkerBugUnit, MAPFileSize, JclDebugDataSize);
      OutputString(Format(LoadResString(@RsJdbgInfo), [LinkerBugUnit, MAPFileSize, JclDebugDataSize]));
    end
    else
    begin
      OutputString(Format(LoadResString(@RsCreatingJdbg), [BinaryFileName]));
      Result := ConvertMapFileToJdbgFile(MAPFileName);
    end;
    if Result then
    begin
      OutputString(LoadResString(@RsJdbgInfoOk));
      if MapDelete then
        OutputFileDelete(MAPFileName);
    end
    else
      OutputString(LoadResString(@RsJdbgInfoFailed));
  end
  else
    Result := True;
  {$ELSE MSWINDOWS}
  Result := True;
  {$ENDIF MSWINDOWS}
end;

function TJclBorRADToolInstallation.OutputFileDelete(const FileName: string): Boolean;
begin
  OutputString(Format(LoadResString(@RsDeletingFile), [FileName]));
  Result := FileDelete(FileName);
  if Result then
    OutputString(LoadResString(@RsFileDeletionOk))
  else
    OutputString(LoadResString(@RsFileDeletionFailed));
end;

procedure TJclBorRADToolInstallation.OutputString(const AText: string);
begin
  if Assigned(FOutputCallback) then
    OutputCallback(AText);
end;

class function TJclBorRADToolInstallation.PackageSourceFileExtension: string;
begin
  {$IFDEF MSWINDOWS}
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']); // BCB doesn't support abstract keyword
  {$ELSE MSWINDOWS}
  Result := '';
  {$ENDIF MSWINDOWS}
end;

class function TJclBorRADToolInstallation.ProjectSourceFileExtension: string;
begin
  {$IFDEF MSWINDOWS}
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']); // BCB doesn't support abstract keyword
  {$ELSE MSWINDOWS}
  Result := '';
  {$ENDIF MSWINDOWS}
end;

class function TJclBorRADToolInstallation.RADToolKind: TJclBorRADToolKind;
begin
  {$IFDEF MSWINDOWS}
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']); // BCB doesn't support abstract keyword
  {$ELSE MSWINDOWS}
  Result := brDelphi;
  {$ENDIF MSWINDOWS}
end;

{class }function TJclBorRADToolInstallation.RADToolName: string;
begin
  {$IFDEF MSWINDOWS}
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']); // BCB doesn't support abstract keyword
  {$ELSE MSWINDOWS}
  Result := '';
  {$ENDIF MSWINDOWS}
end;

procedure TJclBorRADToolInstallation.ReadInformation;
  function FormatVersionNumber(const Num: Integer): string;
  begin
    Result := '';
    case RadToolKind of
      brDelphi:
        Result := Format('d%d', [Num]);
      brCppBuilder:
        Result := Format('c%d', [Num]);
      brBorlandDevStudio:
        case Num of
          1:
            Result := 'cs1';
        else
          if Num < 7 then
            Result := Format('d%d', [Num + 6])  // BDS 2 goes to D8
          else
            Result := Format('d%d', [Num + 7]); // BDS 7 goes to D14
        end;
    end;
  end;

const
  BinDir = 'bin\';
  UpdateKeyName = 'Update #';
  BDSUpdateKeyName = 'UpdatePackInstalled';
var
  KeyLen, I: Integer;
  Key, GlobalKey: string;
  Ed: TJclBorRADToolEdition;
  GlobalsBuffer: TStrings;
begin
  Key := ConfigData.FileName;
  GlobalKey := StrEnsureSuffix('\', Key) + GlobalsKeyName;
  GlobalsBuffer := TStringList.Create;
  try
    // overriden settings first
    RegGetValueNamesAndValues(HKCU, GlobalKey, GlobalsBuffer);
    Globals.AddStrings(GlobalsBuffer);
    RegGetValueNamesAndValues(HKCU, Key, GlobalsBuffer);
    Globals.AddStrings(GlobalsBuffer);
    RegGetValueNamesAndValues(HKLM, GlobalKey, GlobalsBuffer);
    Globals.AddStrings(GlobalsBuffer);
    RegGetValueNamesAndValues(HKLM, Key, GlobalsBuffer);
    Globals.AddStrings(GlobalsBuffer);
  finally
    GlobalsBuffer.Free;
  end;

  KeyLen := Length(Key);
  if (KeyLen > 3) and StrIsDigit(Key[KeyLen - 2]) and (Key[KeyLen - 1] = '.') and (Key[KeyLen] = '0') then
    FIDEVersionNumber := Ord(Key[KeyLen - 2]) - Ord('0')
  else
    FIDEVersionNumber := 0;

 // If this is Spacely, then consider the version is equal to 4 (BDS2006)
 // as it is a non breaking version (dcu wise)

 { ahuser: Delphi 2007 is a non breaking version in the case that you can use
   BDS 2006 compiled units in Delphi 2007. But it completely breaks the BDS 2006
   installation because if BDS 2006 uses the Delphi 2007 compile DCUs the
   resulting executable is broken and will do strange things. So treat Delphi 2007
   as version 11 what it actually is. }
 {if (FIDEVersionNumber = 5) and (RadToolKind = brBorlandDevStudio) then
    FVersionNumber := 4
  else}
    FVersionNumber := FIDEVersionNumber;

  FVersionNumberStr := FormatVersionNumber(VersionNumber);
  FIDEVersionNumberStr := FormatVersionNumber(IDEVersionNumber);

  FRootDir := PathRemoveSeparator(Globals.Values[RootDirValueName]);
  FBinFolderName := PathAddSeparator(RootDir) + BinDir;

  FEditionStr := Globals.Values[EditionValueName];
  if FEditionStr = '' then
    FEditionStr := Globals.Values[VersionValueName];
  { TODO : Edition detection for BDS }
  for Ed := Low(Ed) to High(Ed) do
    if StrIPos(BorRADToolEditionIDs[Ed], FEditionStr) = 1 then
      FEdition := Ed;

  if RadToolKind = brBorlandDevStudio then
    FInstalledUpdatePack := StrToIntDef(Globals.Values[BDSUpdateKeyName], 0)
  else
    for I := 0 to Globals.Count - 1 do
    begin
      Key := Globals.Names[I];
      KeyLen := Length(UpdateKeyName);
      if (Pos(UpdateKeyName, Key) = 1) and (Length(Key) > KeyLen) and StrIsDigit(Key[KeyLen + 1]) then
        FInstalledUpdatePack := Max(FInstalledUpdatePack, Integer(Ord(Key[KeyLen + 1]) - 48));
    end;
end;

function TJclBorRADToolInstallation.RegisterExpert(const ProjectName, OutputDir, Description: string): Boolean;
begin
  Result := RegisterExpert(BinaryFileName(OutputDir, ProjectName), Description);
end;

function TJclBorRADToolInstallation.RegisterExpert(const BinaryFileName, Description: string): Boolean;
var
  InternalDescription: string;
begin
  OutputString(Format(LoadResString(@RsRegisteringExpert), [BinaryFileName]));

  if Description = '' then
    InternalDescription := PathExtractFileNameNoExt(BinaryFileName)
  else
    InternalDescription := Description;

  Result := IdePackages.AddExpert(BinaryFileName, InternalDescription);
  if Result then
    OutputString(LoadResString(@RsRegistrationOk))
  else
    OutputString(LoadResString(@RsRegistrationFailed));
end;

function TJclBorRADToolInstallation.RegisterIDEPackage(const PackageName, BPLPath, Description: string): Boolean;
begin
  Result := RegisterIDEPackage(BinaryFileName(BPLPath, PackageName), Description);
end;

function TJclBorRADToolInstallation.RegisterIDEPackage(const BinaryFileName, Description: string): Boolean;
var
  InternalDescription: string;
begin
  OutputString(Format(LoadResString(@RsRegisteringIdePackage), [BinaryFileName]));

  if Description = '' then
    InternalDescription := PathExtractFileNameNoExt(BinaryFileName)
  else
    InternalDescription := Description;

  Result := IdePackages.AddIDEPackage(BinaryFileName, InternalDescription);
  if Result then
    OutputString(LoadResString(@RsRegistrationOk))
  else
    OutputString(LoadResString(@RsRegistrationFailed));
end;

function TJclBorRADToolInstallation.RegisterPackage(const PackageName, BPLPath, Description: string): Boolean;
begin
  Result := RegisterPackage(BinaryFileName(BPLPath, PackageName), Description);
end;

function TJclBorRADToolInstallation.RegisterPackage(const BinaryFileName, Description: string): Boolean;
var
  InternalDescription: string;
begin
  OutputString(Format(LoadResString(@RsRegisteringPackage), [BinaryFileName]));

  if Description = '' then
    InternalDescription := PathExtractFileNameNoExt(BinaryFileName)
  else
    InternalDescription := Description;

  Result := IdePackages.AddPackage(BinaryFileName, InternalDescription);
  if Result then
    OutputString(LoadResString(@RsRegistrationOk))
  else
    OutputString(LoadResString(@RsRegistrationFailed));
end;

function TJclBorRADToolInstallation.RemoveFromDebugDCUPath(const Path: string): Boolean;
var
  TempDebugDCUPath: TJclBorRADToolPath;
begin
  TempDebugDCUPath := DebugDCUPath;
  Result := RemoveFromPath(TempDebugDCUPath, Path);
  DebugDCUPath := TempDebugDCUPath;
end;

function TJclBorRADToolInstallation.RemoveFromLibrarySearchPath(const Path: string): Boolean;
var
  TempLibraryPath: TJclBorRADToolPath;
begin
  TempLibraryPath := LibrarySearchPath;
  Result := RemoveFromPath(TempLibraryPath, Path);
  LibrarySearchPath := TempLibraryPath;
end;

function TJclBorRADToolInstallation.RemoveFromLibraryBrowsingPath(const Path: string): Boolean;
var
  TempLibraryPath: TJclBorRADToolPath;
begin
  TempLibraryPath := LibraryBrowsingPath;
  Result := RemoveFromPath(TempLibraryPath, Path);
  LibraryBrowsingPath := TempLibraryPath;
end;

function TJclBorRADToolInstallation.RemoveFromPath(var Path: string; const ItemsToRemove: string): Boolean;
var
  PathItems, RemoveItems: TStringList;
  Folder: string;
  I, J: Integer;
begin
  Result := False;
  PathItems := nil;
  RemoveItems := nil;
  try
    PathItems := TStringList.Create;
    RemoveItems := TStringList.Create;
    ExtractPaths(Path, PathItems);
    ExtractPaths(ItemsToRemove, RemoveItems);
    for I := 0 to RemoveItems.Count - 1 do
    begin
      Folder := RemoveItems[I];
      J := FindFolderInPath(Folder, PathItems);
      if J <> -1 then
      begin
        PathItems.Delete(J);
        Result := True;
      end;
    end;
    Path := StringsToStr(PathItems, PathSep, False);
  finally
    PathItems.Free;
    RemoveItems.Free;
  end;
end;

procedure TJclBorRADToolInstallation.SetDebugDCUPath(const Value: TJclBorRADToolPath);
begin
  ConfigData.WriteString(DebuggingKeyName, DebugDCUPathValueName, Value);
end;

procedure TJclBorRADToolInstallation.SetLibrarySearchPath(const Value: TJclBorRADToolPath);
begin
  ConfigData.WriteString(LibraryKeyName, LibrarySearchPathValueName, Value);
end;

procedure TJclBorRADToolInstallation.SetOutputCallback(const Value: TTextHandler);
begin
  FOutputCallback := Value;
  //if clAsm in CommandLineTools then
  //  Asm.OutputCallback := Value;
  if clBcc32 in CommandLineTools then
    Bcc32.OutputCallback := Value;
  if clDcc32 in CommandLineTools then
    Dcc32.OutputCallback := Value;
  //if clDccIL in CommandLineTools then
  //  DccIL.OutputCallback := Value;
  if clMake in CommandLineTools then
    Make.OutputCallback := Value;
  if clProj2Mak in CommandLineTools then
    Bpr2Mak.OutputCallback := Value;
end;

procedure TJclBorRADToolInstallation.SetLibraryBrowsingPath(const Value: TJclBorRADToolPath);
begin
  ConfigData.WriteString(LibraryKeyName, LibraryBrowsingPathValueName, Value);
end;

function TJclBorRADToolInstallation.SubstitutePath(const Path: string): string;
var
  I: Integer;
  Name: string;
begin
  Result := Path;
  if Pos('$(', Result) > 0 then
    with EnvironmentVariables do
      for I := 0 to Count - 1 do
      begin
        Name := Names[I];
        Result := StringReplace(Result, Format('$(%s)', [Name]), Values[Name], [rfReplaceAll, rfIgnoreCase]);
      end;
  // remove duplicate path delimiters '\\'
  Result := StringReplace(Result, DirDelimiter + DirDelimiter, DirDelimiter, [rfReplaceAll]);
end;

function TJclBorRADToolInstallation.SupportsVCL: Boolean;
const
  VclDcp = 'vcl.dcp';
begin
  Result := ((RadToolKind <> brBorlandDevStudio) and (VersionNumber = 5)) or
    FileExists(LibFolderName + VclDcp) or FileExists(ObjFolderName + VclDcp);
end;

function TJclBorRADToolInstallation.SupportsVisualCLX: Boolean;
const
  VisualClxDcp = 'visualclx.dcp';
begin
  Result := (Edition <> deSTD) and (VersionNumber in [6, 7]) and (RadToolKind <> brBorlandDevStudio) and
    (FileExists(LibFolderName + VisualClxDcp) or FileExists(ObjFolderName + VisualClxDcp));
end;

function TJclBorRADToolInstallation.UninstallBCBExpert(const ProjectName, OutputDir: string): Boolean;
var
  DllFileName: string;
begin
  OutputString(Format(LoadResString(@RsExpertUninstallationStarted), [ProjectName]));

  if not IsBCBProject(ProjectName) then
    raise EJclBorRADException.CreateResFmt(@RsENotABCBProject, [ProjectName]);

  DllFileName := BinaryFileName(OutputDir, ProjectName);
  // important: remove from experts /before/ deleting;
  //            otherwise PathGetLongPathName won't work
  Result := UnregisterExpert(DllFileName);

  if Result then
    OutputFileDelete(DllFileName);

  OutputString(LoadResString(@RsExpertUninstallationFinished));
end;

function TJclBorRADToolInstallation.UninstallBCBIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  MAPFileName, TDSFileName,
  BPIFileName, LIBFileName, BPLFileName: string;
  RunOnly: Boolean;
begin
  OutputString(Format(LoadResString(@RsIdePackageUninstallationStarted), [PackageName]));

  if not IsBCBPackage(PackageName) then
    raise EJclBorRADException.CreateResFmt(@RsENotABCBPackage, [PackageName]);

  GetBPKFileInfo(PackageName, RunOnly);

  BPLFileName := BinaryFileName(BPLPath, PackageName);

  // important: remove from IDE packages /before/ deleting;
  //            otherwise PathGetLongPathName won't work
  Result := (RunOnly or UnregisterIdePackage(BPLFileName));

  // Don't delete binaries if removal of design time package failed
  if Result then
  begin
    OutputFileDelete(BPLFileName);

    BPIFileName := PathAddSeparator(DCPPath) + PathExtractFileNameNoExt(PackageName) + CompilerExtensionBPI;
    OutputFileDelete(BPIFileName);

    LIBFileName := ChangeFileExt(BPIFileName, CompilerExtensionLIB);
    OutputFileDelete(LIBFileName);

    MAPFileName := ChangeFileExt(BPLFileName, CompilerExtensionMAP);
    OutputFileDelete(MAPFileName);

    TDSFileName := ChangeFileExt(BPLFileName, CompilerExtensionTDS);
    OutputFileDelete(TDSFileName);
  end;

  OutputString(LoadResString(@RsIdePackageUninstallationFinished));
end;

function TJclBorRADToolInstallation.UninstallBCBPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  MAPFileName, TDSFileName, TmpBinaryFileName,
  BPIFileName, LIBFileName, BPLFileName: string;
  RunOnly: Boolean;
begin
  OutputString(Format(LoadResString(@RsPackageUninstallationStarted), [PackageName]));

  if not IsBCBPackage(PackageName) then
    raise EJclBorRADException.CreateResFmt(@RsENotABCBPackage, [PackageName]);

  GetBPKFileInfo(PackageName, RunOnly, @TmpBinaryFileName);

  BPLFileName := BinaryFileName(BPLPath, PackageName);

  // important: remove from IDE packages /before/ deleting;
  //            otherwise PathGetLongPathName won't work
  Result := (RunOnly or UnregisterPackage(BPLFileName));

  // Don't delete binaries if removal of design time package failed
  if Result then
  begin
    OutputFileDelete(BPLFileName);

    BPIFileName := PathAddSeparator(DCPPath) + PathExtractFileNameNoExt(PackageName) + CompilerExtensionBPI;
    OutputFileDelete(BPIFileName);

    LIBFileName := ChangeFileExt(BPIFileName, CompilerExtensionLIB);
    OutputFileDelete(LIBFileName);

    MAPFileName := ChangeFileExt(BPLFileName, CompilerExtensionMAP);
    OutputFileDelete(MAPFileName);

    TDSFileName := ChangeFileExt(BPLFileName, CompilerExtensionTDS);
    OutputFileDelete(TDSFileName);
  end;

  OutputString(LoadResString(@RsPackageUninstallationFinished));
end;

function TJclBorRADToolInstallation.UninstallDelphiExpert(const ProjectName, OutputDir: string): Boolean;
var
  DllFileName: string;
begin
  OutputString(Format(LoadResString(@RsExpertUninstallationStarted), [ProjectName]));

  if not IsDelphiProject(ProjectName) then
    raise EJclBorRADException.CreateResFmt(@RsENotADelphiProject, [ProjectName]);

  DllFileName := BinaryFileName(OutputDir, ProjectName);
  // important: remove from experts /before/ deleting;
  //            otherwise PathGetLongPathName won't work
  Result := UnregisterExpert(DllFileName);

  if Result then
    OutputFileDelete(DllFileName);

  OutputString(LoadResString(@RsExpertUninstallationFinished));
end;

function TJclBorRADToolInstallation.UninstallDelphiIdePackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  MAPFileName,
  BPLFileName, DCPFileName: string;
  BaseName: string;
  RunOnly: Boolean;
begin
  OutputString(Format(LoadResString(@RsIdePackageUninstallationStarted), [PackageName]));

  if not IsDelphiPackage(PackageName) then
    raise EJclBorRADException.CreateResFmt(@RsENotADelphiPackage, [PackageName]);

  GetDPKFileInfo(PackageName, RunOnly);
  BaseName := PathExtractFileNameNoExt(PackageName);

  BPLFileName := BinaryFileName(BPLPath, PackageName);

  // important: remove from IDE packages /before/ deleting;
  //            otherwise PathGetLongPathName won't work
  Result := RunOnly or UnregisterIdePackage(BPLFileName);

  // Don't delete binaries if removal of design time package failed
  if Result then
  begin
    OutputFileDelete(BPLFileName);

    DCPFileName := PathAddSeparator(DCPPath) + BaseName + CompilerExtensionDCP;
    OutputFileDelete(DCPFileName);

    MAPFileName := ChangeFileExt(BPLFileName, CompilerExtensionMAP);
    OutputFileDelete(MAPFileName);
  end;

  OutputString(LoadResString(@RsIdePackageUninstallationFinished));
end;

function TJclBorRADToolInstallation.UninstallDelphiPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  MAPFileName, BPLFileName, DCPFileName: string;
  BaseName: string;
  RunOnly: Boolean;
begin
  OutputString(Format(LoadResString(@RsPackageUninstallationStarted), [PackageName]));

  if not IsDelphiPackage(PackageName) then
    raise EJclBorRADException.CreateResFmt(@RsENotADelphiPackage, [PackageName]);

  GetDPKFileInfo(PackageName, RunOnly);
  BaseName := PathExtractFileNameNoExt(PackageName);

  BPLFileName := BinaryFileName(BPLPath, PackageName);

  // important: remove from IDE packages /before/ deleting;
  //            otherwise PathGetLongPathName won't work
  Result := RunOnly or UnregisterPackage(BPLFileName);

  // Don't delete binaries if removal of design time package failed
  if Result then
  begin
    OutputFileDelete(BPLFileName);

    DCPFileName := PathAddSeparator(DCPPath) + BaseName + CompilerExtensionDCP;
    OutputFileDelete(DCPFileName);

    MAPFileName := ChangeFileExt(BPLFileName, CompilerExtensionMAP);
    OutputFileDelete(MAPFileName);
  end;

  OutputString(LoadResString(@RsPackageUninstallationFinished));
end;

function TJclBorRADToolInstallation.UninstallExpert(const ProjectName, OutputDir: string): Boolean;
var
  ProjectExtension: string;
begin
  ProjectExtension := ExtractFileExt(ProjectName);
  if SameText(ProjectExtension, SourceExtensionBCBProject) then
    Result := UninstallBCBExpert(ProjectName, OutputDir)
  else
  if SameText(ProjectExtension, SourceExtensionDelphiProject) then
    Result := UninstallDelphiExpert(ProjectName, OutputDir)
  else
    raise EJclBorRadException.CreateResFmt(@RsEUnknownProjectExtension, [ProjectExtension]);
end;

function TJclBorRADToolInstallation.UninstallIDEPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  PackageExtension: string;
begin
  PackageExtension := ExtractFileExt(PackageName);
  if SameText(PackageExtension, SourceExtensionBCBPackage) then
    Result := UninstallBCBIdePackage(PackageName, BPLPath, DCPPath)
  else
  if SameText(PackageExtension, SourceExtensionDelphiPackage) then
    Result := UninstallDelphiIdePackage(PackageName, BPLPath, DCPPath)
  else
    raise EJclBorRadException.CreateResFmt(@RsEUnknownIdePackageExtension, [PackageExtension]);
end;

function TJclBorRADToolInstallation.UninstallPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
var
  PackageExtension: string;
begin
  PackageExtension := ExtractFileExt(PackageName);
  if SameText(PackageExtension, SourceExtensionBCBPackage) then
    Result := UninstallBCBPackage(PackageName, BPLPath, DCPPath)
  else
  if SameText(PackageExtension, SourceExtensionDelphiPackage) then
    Result := UninstallDelphiPackage(PackageName, BPLPath, DCPPath)
  else
    raise EJclBorRadException.CreateResFmt(@RsEUnknownPackageExtension, [PackageExtension]);
end;

function TJclBorRADToolInstallation.UnregisterExpert(const ProjectName, OutputDir: string): Boolean;
begin
  Result := UnregisterExpert(BinaryFileName(OutputDir, ProjectName));
end;

function TJclBorRADToolInstallation.UnregisterExpert(const BinaryFileName: string): Boolean;
begin
  OutputString(Format(LoadResString(@RsUnregisteringExpert), [BinaryFileName]));

  Result := IdePackages.RemoveExpert(BinaryFileName);
  if Result then
    OutputString(LoadResString(@RsUnregistrationOk))
  else
    OutputString(LoadResString(@RsUnregistrationFailed));
end;

function TJclBorRADToolInstallation.UnregisterIDEPackage(const PackageName, BPLPath: string): Boolean;
begin
  Result := UnregisterIDEPackage(BinaryFileName(BPLPath, PackageName));
end;

function TJclBorRADToolInstallation.UnregisterIDEPackage(const BinaryFileName: string): Boolean;
begin
  OutputString(Format(LoadResString(@RsUnregisteringIDEPackage), [BinaryFileName]));

  Result := IdePackages.RemoveIDEPackage(BinaryFileName);
  if Result then
    OutputString(LoadResString(@RsUnregistrationOk))
  else
    OutputString(LoadResString(@RsUnregistrationFailed));
end;

function TJclBorRADToolInstallation.UnregisterPackage(const PackageName, BPLPath: string): Boolean;
begin
  Result := UnregisterPackage(BinaryFileName(BPLPath, PackageName));
end;

function TJclBorRADToolInstallation.UnregisterPackage(const BinaryFileName: string): Boolean;
begin
  OutputString(Format(LoadResString(@RsUnregisteringPackage), [BinaryFileName]));

  Result := IdePackages.RemovePackage(BinaryFileName);
  if Result then
    OutputString(LoadResString(@RsUnregistrationOk))
  else
    OutputString(LoadResString(@RsUnregistrationFailed));
end;

//=== { TJclBCBInstallation } ================================================

constructor TJclBCBInstallation.Create(const AConfigDataLocation: string; ARootKey: Cardinal);
begin
  inherited Create(AConfigDataLocation, ARootKey);
  FPersonalities := [bpBCBuilder32];
  if clDcc32 in CommandLineTools then
    Include(FPersonalities, bpDelphi32);
end;

destructor TJclBCBInstallation.Destroy;
begin
  inherited Destroy;
end;

function TJclBCBInstallation.GetEnvironmentVariables: TStrings;
begin
  Result := inherited GetEnvironmentVariables;
  if Assigned(Result) then
    Result.Values['BCB'] := PathRemoveSeparator(RootDir);
end;

class function TJclBCBInstallation.GetLatestUpdatePackForVersion(Version: Integer): Integer;
begin
  case Version of
    5:
      Result := 0;
    6:
      Result := 4;
    10:
      Result := 0;
  else
    Result := 0;
  end;
end;

class function TJclBCBInstallation.PackageSourceFileExtension: string;
begin
  Result := SourceExtensionBCBPackage;
end;

class function TJclBCBInstallation.ProjectSourceFileExtension: string;
begin
  Result := SourceExtensionBCBProject;
end;

class function TJclBCBInstallation.RadToolKind: TJclBorRadToolKind;
begin
  Result := brCppBuilder;
end;

function TJclBCBInstallation.RADToolName: string;
begin
  Result := LoadResString(@RsBCBName);
end;

//=== { TJclDelphiInstallation } =============================================

constructor TJclDelphiInstallation.Create(const AConfigDataLocation: string; ARootKey: Cardinal);
begin
  inherited Create(AConfigDataLocation, ARootKey);
  FPersonalities := [bpDelphi32];
end;

destructor TJclDelphiInstallation.Destroy;
begin
  inherited Destroy;
end;

function TJclDelphiInstallation.GetEnvironmentVariables: TStrings;
begin
  Result := inherited GetEnvironmentVariables;
  if Assigned(Result) then
    Result.Values['DELPHI'] := PathRemoveSeparator(RootDir);
end;

class function TJclDelphiInstallation.GetLatestUpdatePackForVersion(Version: Integer): Integer;
begin
  case Version of
    5:
      Result := 1;
    6:
      Result := 2;
    7:
      Result := 0;
  else
    Result := 0;
  end;
end;

function TJclDelphiInstallation.InstallPackage(const PackageName, BPLPath, DCPPath: string): Boolean;
begin
  Result := InstallDelphiPackage(PackageName, BPLPath, DCPPath);
end;

class function TJclDelphiInstallation.PackageSourceFileExtension: string;
begin
  Result := SourceExtensionDelphiPackage;
end;

class function TJclDelphiInstallation.ProjectSourceFileExtension: string;
begin
  Result := SourceExtensionDelphiProject;
end;

class function TJclDelphiInstallation.RadToolKind: TJclBorRadToolKind;
begin
  Result := brDelphi;
end;

function TJclDelphiInstallation.RADToolName: string;
begin
  Result := LoadResString(@RsDelphiName);
end;

//=== { TJclBDSInstallation } ==================================================

{$IFDEF MSWINDOWS}

constructor TJclBDSInstallation.Create(const AConfigDataLocation: string; ARootKey: Cardinal = 0);
const
  PersonalitiesSection = 'Personalities';
begin
  inherited Create(AConfigDataLocation, ARootKey);
  FHelp2Manager := TJclHelp2Manager.Create(IDEVersionNumber);

  if ConfigData.ReadString(PersonalitiesSection, 'C#Builder', '') <> '' then
    Include(FPersonalities, bpCSBuilder32);
  if ConfigData.ReadString(PersonalitiesSection, 'BCB', '') <> '' then
    Include(FPersonalities, bpBCBuilder32);
  if ConfigData.ReadString(PersonalitiesSection, 'Delphi.Win32', '') <> '' then
    Include(FPersonalities, bpDelphi32);
  if (ConfigData.ReadString(PersonalitiesSection, 'Delphi.NET', '') <> '') or
    (ConfigData.ReadString(PersonalitiesSection, 'Delphi8', '') <> '') then
  begin
    Include(FPersonalities, bpDelphiNet32);
    if VersionNumber >= 5 then
      Include(FPersonalities, bpDelphiNet64);
  end;

  if clDcc32 in CommandLineTools then
    Include(FPersonalities, bpDelphi32);
end;

destructor TJclBDSInstallation.Destroy;
begin
  FreeAndNil(FDCCIL);
  FreeAndNil(FHelp2Manager);
  inherited Destroy;
end;

function TJclBDSInstallation.AddToCppBrowsingPath(const Path: string): Boolean;
var
  TempCppPath: TJclBorRADToolPath;
begin
  if (bpBCBuilder32 in Personalities) and (Path <> '') then
  begin
    TempCppPath := CppBrowsingPath;
    PathListIncludeItems(TempCppPath, Path);
    Result := True;
    CppBrowsingPath := TempCppPath;
  end
  else
    Result := False;
end;

function TJclBDSInstallation.AddToCppSearchPath(const Path: string): Boolean;
var
  TempCppPath: TJclBorRADToolPath;
begin
  if (bpBCBuilder32 in Personalities) and (Path <> '') then
  begin
    TempCppPath := CppSearchPath;
    PathListIncludeItems(TempCppPath, Path);
    Result := True;
    CppSearchPath := TempCppPath;
  end
  else
    Result := False;
end;

function TJclBDSInstallation.AddToCppLibraryPath(const Path: string): Boolean;
var
  TempLibraryPath: TJclBorRADToolPath;
begin
  if (bpBCBuilder32 in Personalities) and (IDEVersionNumber >= 5) and (Path <> '') then
  begin
    TempLibraryPath := CppLibraryPath;
    PathListIncludeItems(TempLibraryPath, Path);
    Result := True;
    CppLibraryPath := TempLibraryPath;
  end
  else
    Result := False;
end;

function TJclBDSInstallation.AddToCppIncludePath(const Path: string): Boolean;
var
  TempIncludePath: TJclBorRADToolPath;
begin
  if (bpBCBuilder32 in Personalities) and (IDEVersionNumber >= 5) and (Path <> '') then
  begin
    TempIncludePath := CppIncludePath;
    PathListIncludeItems(TempIncludePath, Path);
    Result := True;
    CppIncludePath := TempIncludePath;
  end
  else
    Result := False;
end;

function TJclBDSInstallation.CleanPackageCache(const BinaryFileName: string): Boolean;
var
  FileName, KeyName: string;
begin
  Result := True;

  if VersionNumber >= 3 then
  begin
    FileName := ExtractFileName(BinaryFileName);

    try
      OutputString(Format(LoadResString(@RsCleaningPackageCache), [FileName]));
      KeyName := PathAddSeparator(ConfigDataLocation) + PackageCacheKeyName + '\' + FileName;

      if RegKeyExists(RootKey, KeyName) then
        Result := RegDeleteKeyTree(RootKey, KeyName);

      if Result then
        OutputString(LoadResString(@RsCleaningOk))
      else
        OutputString(LoadResString(@RsCleaningFailed));
    except
      // trap possible exceptions
    end;
  end;
end;

function TJclBDSInstallation.CompileDelphiDotNetProject(const ProjectName,
  OutputDir: string; PEFormat: TJclBorPlatform; const ExtraOptions: string): Boolean;
var
  DCCILOptions, PlatformOption, PdbOption: string;
begin
  if VersionNumber >= 2 then   // C#Builder 1 doesn't have any Delphi.net compiler
  begin
    if IsDelphiProject(ProjectName) then
      OutputString(Format(LoadResString(@RsCompilingProject), [ProjectName]))
    else
    if IsDelphiPackage(ProjectName) then
      OutputString(Format(LoadResString(@RsCompilingPackage), [ProjectName]))
    else
      raise EJclBorRADException.CreateResFmt(@RsENotADelphiProject, [ProjectName]);

    PlatformOption := '';
    case PEFormat of
      bp32bit:
        if VersionNumber >= 3 then
          PlatformOption := 'x86';
      bp64bit:
        if VersionNumber >= 3 then
          PlatformOption := 'x64'
        else
          raise EJclBorRADException.CreateRes(@RsEx64PlatformNotValid);
    end;

    if PdbCreate then
      PdbOption := '-V'
    else
      PdbOption := '';

    DCCILOptions := Format('%s --platform:%s %s', [ExtraOptions, PlatformOption, PdbOption]);

    Result := DCCIL.MakeProject(ProjectName, OutputDir, DCCILOptions);

    if Result then
      OutputString(LoadResString(@RsCompilationOk))
    else
      OutputString(LoadResString(@RsCompilationFailed));
  end
  else
    raise EJclBorRADException.CreateRes(@RsENoSupportedPersonality);
end;

function TJclBDSInstallation.CompileDelphiPackage(const PackageName, BPLPath, DCPPath, ExtraOptions: string): Boolean;
var
  NewOptions: string;
begin
  if DualPackageInstallation then
  begin
    if not (bpBCBuilder32 in Personalities) then
      raise EJclBorRadException.CreateResFmt(@RsEDualPackageNotSupported, [Name]);

    NewOptions := Format('%s -JL -NB"%s" -NO"%s"',
      [ExtraOptions, PathRemoveSeparator(DcpPath),
       PathRemoveSeparator(DcpPath)]);
  end
  else
    NewOptions := ExtraOptions;

  Result := inherited CompileDelphiPackage(PackageName, BPLPath, DCPPath, NewOptions);
end;

function TJclBDSInstallation.CompileDelphiProject(const ProjectName, OutputDir, DcpSearchPath: string): Boolean;
var
  ExtraOptions: string;
begin
  if VersionNumber <= 2 then
  begin
    OutputString(Format(LoadResString(@RsCompilingProject), [ProjectName]));

    if not IsDelphiProject(ProjectName) then
      raise EJclBorRADException.CreateResFmt(@RsENotADelphiProject, [ProjectName]);

    if MapCreate then
      ExtraOptions := '-GD'
    else
      ExtraOptions := '';

    Result := DCC32.MakeProject(ProjectName, OutputDir, DcpSearchPath, ExtraOptions) and
      ProcessMapFile(BinaryFileName(OutputDir, ProjectName));

    if Result then
      OutputString(LoadResString(@RsCompilationOk))
    else
      OutputString(LoadResString(@RsCompilationFailed));
  end
  else
    Result := inherited CompileDelphiProject(ProjectName, DcpSearchPath, OutputDir);
end;

function TJclBDSInstallation.GetBPLOutputPath: string;
begin
  // BDS 1 (C#Builder 1) and BDS 2 (Delphi 8) don't have a valid BPL output path
  // set in the registry
  case IDEVersionNumber of
    1, 2:
      Result := PathAddSeparator(GetDefaultProjectsDir) + 'bpl';
    3, 4:
      Result := inherited GetBPLOutputPath;
    5:
      begin
        // C++Builder 2007 specific code
        Result := SubstitutePath(GetMsBuildEnvOption(MsBuildCBuilderBPLOutputPathNodeName));
        if Result = '' then
          Result := SubstitutePath(GetMsBuildEnvOption(MsBuildWin32DLLOutputPathNodeName));
      end;
    6, 7:
      Result := SubstitutePath(GetMsBuildEnvOption(MsBuildWin32DLLOutputPathNodeName));
    8:
      Result := SubstitutePath(GetMsBuildEnvOption(MsBuildDelphiDLLOutputPathNodeName));
  end;
end;

function TJclBDSInstallation.GetCommonProjectsDir: string;
begin
  Result := GetCommonProjectsDirectory(RootDir, IDEVersionNumber);
end;

class function TJclBDSInstallation.GetCommonProjectsDirectory(const RootDir: string;
  IDEVersionNumber: Integer): string;
var
  RsVarsOutput, ComSpec: string;
  Lines: TStrings;
begin
  if IDEVersionNumber >= 5 then
  begin
    Result := '';
    RsVarsOutput := '';
    if GetEnvironmentVar('COMSPEC', ComSpec) and (JclSysUtils.Execute(Format('%s /C "%s%sbin%srsvars.bat && set BDS"',
      [ComSpec, ExtractShortPathName(RootDir), DirDelimiter, DirDelimiter]), RsVarsOutput) = 0) then
    begin
      Lines := TStringList.Create;
      try
        Lines.Text := RsVarsOutput;
        Result := Lines.Values[EnvVariableBDSCOMDIRValueName];
      finally
        Lines.Free;
      end;
    end;

    if Result = '' then
    begin
      Result := LoadResStrings(RootDir + '\Bin\coreide' + BDSVersions[IDEVersionNumber].CoreIdeVersion + '.',
        ['RAD Studio'])[0];

      Result := Format('%s%s%d.0',
        [PathAddSeparator(GetCommonDocumentsFolder), PathAddSeparator(Result), IDEVersionNumber]);
    end;
  end
  else
    Result := GetDefaultProjectsDirectory(RootDir, IDEVersionNumber);
end;

function TJclBDSInstallation.GetCppPathsKeyName: string;
begin
  if IDEVersionNumber >= 5 then
    Result := CppPathsV5UpperKeyName
  else
    Result := CppPathsKeyName;
end;

function TJclBDSInstallation.GetCppBrowsingPath: TJclBorRADToolPath;
begin
  Result := ConfigData.ReadString(GetCppPathsKeyName, CppBrowsingPathValueName, '');
end;

function TJclBDSInstallation.GetCppSearchPath: TJclBorRADToolPath;
begin
  Result := ConfigData.ReadString(GetCppPathsKeyName, CppSearchPathValueName, '');
end;

function TJclBDSInstallation.GetCppLibraryPath: TJclBorRADToolPath;
begin
  Result := ConfigData.ReadString(GetCppPathsKeyName, CppLibraryPathValueName, '');
end;

function TJclBDSInstallation.GetCppIncludePath: TJclBorRADToolPath;
begin
  Result := ConfigData.ReadString(GetCppPathsKeyName, CppIncludePathValueName, '');
end;

function TJclBDSInstallation.GetDCCIL: TJclDCCIL;
begin
  if not Assigned(FDCCIL) then
  begin
    if not (clDccIL in CommandLineTools) then
      raise EJclBorRadException.CreateResFmt(@RsENotFound, [DccILExeName]);
    FDCCIL := TJclDCCIL.Create(BinFolderName, LongPathBug, CompilerSettingsFormat,
                               SupportsNoConfig, DCPOutputPath, LibFolderName, LibDebugFolderName, ObjFolderName);
  end;
  Result := FDCCIL;
end;

function TJclBDSInstallation.GetDCPOutputPath: string;
begin
  case IDEVersionNumber of
    1, 2:
      // hard-coded
      Result := PathAddSeparator(RootDir) + 'lib';
    3, 4:
      // use registry
      Result := inherited GetDCPOutputPath;
    5, 6, 7:
      // use EnvOptions.proj
      Result := SubstitutePath(GetMsBuildEnvOption(MsBuildWin32DCPOutputNodeName));
  else
    // use EnvOptions.proj
    Result := SubstitutePath(GetMsBuildEnvOption(MsBuildDelphiDCPOutputNodeName));
  end;
end;

function TJclBDSInstallation.GetDebugDCUPath: TJclBorRADToolPath;
begin
  if IDEVersionNumber >= 8 then
    // use EnvOptions.proj
    Result := GetMsBuildEnvOption(MsBuildDelphiDebugDCUPathNodeName)
  else
  if IDEVersionNumber >= 5 then
    // use EnvOptions.proj
    Result := GetMsBuildEnvOption(MsBuildWin32DebugDCUPathNodeName)
  else
    // use registry
    Result := ConfigData.ReadString(LibraryKeyName, BDSDebugDCUPathValueName, '');
end;

function TJclBDSInstallation.GetDefaultProjectsDir: string;
begin
  Result := GetDefaultProjectsDirectory(RootDir, IDEVersionNumber);
end;

class function TJclBDSInstallation.GetDefaultProjectsDirectory(const RootDir: string;
  IDEVersionNumber: Integer): string;
var
  LocStr: WideStringArray;
begin
  LocStr := LoadResStrings(RootDir + '\Bin\coreide' + BDSVersions[IDEVersionNumber].CoreIdeVersion + '.',
    ['Borland Studio Projects', 'RAD Studio', 'Projects']);

  if IDEVersionNumber < 5 then
    Result := LocStr[0]
  else
    Result := LocStr[1] + NativeBackslash + LocStr[2];

  Result := PathAddSeparator(GetPersonalFolder) + Result;
end;

function TJclBDSInstallation.GetEnvironmentVariables: TStrings;
begin
  Result := inherited GetEnvironmentVariables;
  if Assigned(Result) then
  begin
    // adding default values
    if Result.Values[EnvVariableBDSValueName] = '' then
      Result.Values[EnvVariableBDSValueName] := PathRemoveSeparator(RootDir);
    if Result.Values[EnvVariableBDSPROJDIRValueName] = '' then
      Result.Values[EnvVariableBDSPROJDIRValueName] := DefaultProjectsDir;
    if Result.Values[EnvVariableBDSCOMDIRValueName] = '' then
      Result.Values[EnvVariableBDSCOMDIRValueName] := CommonProjectsDir;
  end;
end;

class function TJclBDSInstallation.GetLatestUpdatePackForVersion(Version: Integer): Integer;
begin
  case Version of
    9:
      Result := 1;   // personal version is only update pack 1
    10:
      Result := 1;  // update 1 is out
  else
    Result := 0;
  end;
end;

function TJclBDSInstallation.GetValid: Boolean;
begin
  Result := (inherited GetValid) and ((IDEVersionNumber < 5) or FileExists(GetMsBuildEnvOptionsFileName));
end;

function TJclBDSInstallation.GetLibraryBrowsingPath: TJclBorRADToolPath;
begin
  if IDEVersionNumber >= 8 then
    // use EnvOptions.proj
    Result := GetMsBuildEnvOption(MsBuildDelphiBrowsingPathNodeName)
  else
  if IDEVersionNumber >= 5 then
    // use EnvOptions.proj
    Result := GetMsBuildEnvOption(MsBuildWin32BrowsingPathNodeName)
  else
    // use registry
    Result := inherited GetLibraryBrowsingPath;
end;

function TJclBDSInstallation.GetLibrarySearchPath: TJclBorRADToolPath;
begin
  if IDEVersionNumber >= 8 then
    // use EnvOptions.proj
    Result := GetMsBuildEnvOption(MsBuildDelphiLibraryPathNodeName)
  else
  if IDEVersionNumber >= 5 then
    // use EnvOptions.proj
    Result := GetMsBuildEnvOption(MsBuildWin32LibraryPathNodeName)
  else
    // use registry
    Result := inherited GetLibrarySearchPath;
end;

function TJclBDSInstallation.GetMaxDelphiCLRVersion: string;
begin
  Result := DCCIL.MaxCLRVersion;
end;

function TJclBDSInstallation.GetName: string;
begin
  // The name comes from the IDEVersionNumber
  if IDEVersionNumber in [Low(BDSVersions)..High(BDSVersions)] then
    Result := Format('%s %s', [RadToolName, BDSVersions[IDEVersionNumber].VersionStr])
  else
    Result := Format('%s ***%s***', [RadToolName, IDEVersionNumber]);
end;

function TJclBDSInstallation.GetMsBuildEnvOption(const OptionName: string): string;
var
  EnvOptionsFile: TJclSimpleXML;
  PropertyGroupNode, PropertyNode: TJclSimpleXMLElem;
begin
  Result := '';

  EnvOptionsFile := TJclSimpleXML.Create;
  try
    EnvOptionsFile.LoadFromFile(GetMsBuildEnvOptionsFileName);
    EnvOptionsFile.Options := EnvOptionsFile.Options - [sxoAutoCreate];

    PropertyGroupNode := EnvOptionsFile.Root.Items.ItemNamed[MsBuildPropertyGroupNodeName];
    if Assigned(PropertyGroupNode) then
    begin
      PropertyNode := PropertyGroupNode.Items.ItemNamed[OptionName];
      if Assigned(PropertyNode) then
        Result := PropertyNode.Value;
    end;
  finally
    EnvOptionsFile.Free;
  end;
end;

function TJclBDSInstallation.GetMsBuildEnvOptionsFileName: string;
var
  AppdataFolder: string;
begin
  if IDEVersionNumber >= 5 then
  begin
    if (RootKey = 0) or (RootKey = HKCU) then
      AppdataFolder := GetAppdataFolder
    else
      AppdataFolder := RegReadString(RootKey, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'AppData');

    if IDEVersionNumber >= 8 then
      Result := Format('%sEmbarcadero\BDS\%d.0\EnvOptions.proj',
        [PathAddSeparator(AppdataFolder), IDEVersionNumber])
    else
    if IDEVersionNumber >= 6 then
      Result := Format('%sCodeGear\BDS\%d.0\EnvOptions.proj',
        [PathAddSeparator(AppdataFolder), IDEVersionNumber])
    else
      Result := Format('%sBorland\BDS\%d.0\EnvOptions.proj',
        [PathAddSeparator(AppdataFolder), IDEVersionNumber]);
  end
  else
    raise EJclBorRADException.CreateRes(@RsMsBuildNotSupported);
end;

function TJclBDSInstallation.GetVclIncludeDir: string;
begin
  if not (bpBCBuilder32 in Personalities) then
    raise EJclBorRadException.CreateResFmt(@RsEDualPackageNotSupported, [Name]);
  if (RadToolKind = brBorlandDevStudio) and (IDEVersionNumber >= 8) then
    Result := SubstitutePath(GetMsBuildEnvOption(MsBuildDelphiHPPOutputPathNodeName))
  else
    Result := inherited GetVclIncludeDir;
end;

class function TJclBDSInstallation.PackageSourceFileExtension: string;
begin
  Result := SourceExtensionDelphiPackage;
end;

class function TJclBDSInstallation.ProjectSourceFileExtension: string;
begin
  Result := SourceExtensionDelphiProject;
end;

class function TJclBDSInstallation.RadToolKind: TJclBorRadToolKind;
begin
  Result := brBorlandDevStudio;
end;

function TJclBDSInstallation.RadToolName: string;
begin
  // The name comes from IDEVersionNumber
  if IDEVersionNumber in [Low(BDSVersions)..High(BDSVersions)] then
  begin
    Result := LoadResString(BDSVersions[IDEVersionNumber].Name);
    // IDE Version 5 comes in three flavors:
    // - Delphi only  (Spacely)
    // - C++Builder only  (Cogswell)
    // - Delphi and C++Builder
    if (IDEVersionNumber = 5) and (Personalities = [bpDelphi32]) then
      Result := LoadResString(@RsDelphiName)
    else
    if (IDEVersionNumber = 5) and (Personalities = [bpBCBuilder32]) then
      Result := LoadResString(@RsBCBName);
  end
  else
    Result := LoadResString(@RsBDSName);
end;

function TJclBDSInstallation.RegisterPackage(const BinaryFileName, Description: string): Boolean;
begin
  if VersionNumber >= 3 then
    CleanPackageCache(BinaryFileName);

  Result := inherited RegisterPackage(BinaryFileName, Description);
end;

function TJclBDSInstallation.RemoveFromCppBrowsingPath(const Path: string): Boolean;
var
  TempCppPath: TJclBorRADToolPath;
begin
  if bpBCBuilder32 in Personalities then
  begin
    TempCppPath := CppBrowsingPath;
    Result := RemoveFromPath(TempCppPath, Path);
    CppBrowsingPath := TempCppPath;
  end
  else
    Result := False;
end;

function TJclBDSInstallation.RemoveFromCppSearchPath(const Path: string): Boolean;
var
  TempCppPath: TJclBorRADToolPath;
begin
  if (bpBCBuilder32 in Personalities) and (Path <> '') then
  begin
    TempCppPath := CppSearchPath;
    Result := RemoveFromPath(TempCppPath, Path);
    CppSearchPath := TempCppPath;
  end
  else
    Result := False;
end;

function TJclBDSInstallation.RemoveFromCppLibraryPath(const Path: string): Boolean;
var
  TempLibraryPath: TJclBorRADToolPath;
begin
  if (bpBCBuilder32 in Personalities) and (IDEVersionNumber >= 5) and (Path <> '') then
  begin
    TempLibraryPath := CppLibraryPath;
    Result := RemoveFromPath(TempLibraryPath, Path);
    CppLibraryPath := TempLibraryPath;
  end
  else
    Result := False;
end;

function TJclBDSInstallation.RemoveFromCppIncludePath(const Path: string): Boolean;
var
  TempIncludePath: TJclBorRADToolPath;
begin
  if (bpBCBuilder32 in Personalities) and (IDEVersionNumber >= 5) and (Path <> '') then
  begin
    TempIncludePath := CppIncludePath;
    Result := RemoveFromPath(TempIncludePath, Path);
    CppIncludePath := TempIncludePath;
  end
  else
    Result := False;
end;

procedure TJclBDSInstallation.SetCppBrowsingPath(const Value: TJclBorRADToolPath);
begin
  // update registry
  ConfigData.WriteString(GetCppPathsKeyName, CppBrowsingPathValueName, Value);
  // update EnvOptions.dproj
  if IDEVersionNumber >= 5 then
    SetMsBuildEnvOption(MsBuildCBuilderBrowsingPathNodeName, Value);
end;

procedure TJclBDSInstallation.SetCppSearchPath(const Value: TJclBorRADToolPath);
begin
  ConfigData.WriteString(GetCppPathsKeyName, CppSearchPathValueName, Value);
end;

procedure TJclBDSInstallation.SetCppLibraryPath(const Value: TJclBorRADToolPath);
begin
  // update registry
  ConfigData.WriteString(GetCppPathsKeyName, CppLibraryPathValueName, Value);
  // update EnvOptions.dproj
  if IDEVersionNumber >= 5 then
    SetMsBuildEnvOption(MsBuildCBuilderLibraryPathNodeName, Value);
end;

procedure TJclBDSInstallation.SetCppIncludePath(const Value: TJclBorRADToolPath);
begin
  if IDEVersionNumber >= 5 then
  begin
    // update registry
    ConfigData.WriteString(GetCppPathsKeyName, CppIncludePathValueName, Value);
    // update EnvOptions.dproj
    SetMsBuildEnvOption(MsBuildCBuilderIncludePathNodeName, Value);
  end;
end;

procedure TJclBDSInstallation.SetDebugDCUPath(const Value: TJclBorRADToolPath);
begin
  // update registry
  ConfigData.WriteString(LibraryKeyName, BDSDebugDCUPathValueName, Value);
  // update EnvOptions.dproj
  if IDEVersionNumber >= 8 then
    SetMsBuildEnvOption(MsBuildDelphiDebugDCUPathNodeName, Value)
  else
  if IDEVersionNumber >= 5 then
    SetMsBuildEnvOption(MsBuildWin32DebugDCUPathNodeName, Value);
end;

procedure TJclBDSInstallation.SetDualPackageInstallation(const Value: Boolean);
begin
  if Value and not (bpBCBuilder32 in Personalities) then
    raise EJclBorRadException.CreateResFmt(@RsEDualPackageNotSupported, [Name]);
  FDualPackageInstallation := Value;
end;

procedure TJclBDSInstallation.SetLibraryBrowsingPath(const Value: TJclBorRADToolPath);
begin
  // update registry
  inherited SetLibraryBrowsingPath(Value);
  // update EnvOptions.dproj
  if IDEVersionNumber >= 8 then
    SetMsBuildEnvOption(MsBuildDelphiBrowsingPathNodeName, Value)
  else
  if IDEVersionNumber >= 5 then
    SetMsBuildEnvOption(MsBuildWin32BrowsingPathNodeName, Value);
end;

procedure TJclBDSInstallation.SetLibrarySearchPath(const Value: TJclBorRADToolPath);
begin
  // update registry
  inherited SetLibrarySearchPath(Value);
  // update EnvOptions.dproj
  if IDEVersionNumber >= 8 then
    SetMsBuildEnvOption(MsBuildDelphiLibraryPathNodeName, Value)
  else
  if IDEVersionNumber >= 5 then
    SetMsBuildEnvOption(MsBuildWin32LibraryPathNodeName, Value);
end;

procedure TJclBDSInstallation.SetMsBuildEnvOption(const OptionName, Value: string);
var
  EnvOptionsFileName, BakEnvOptionsFileName: string;
  EnvOptionsFile: TJclSimpleXML;
  PropertyGroupNode, PropertyNode: TJclSimpleXMLElem;
begin
  EnvOptionsFile := TJclSimpleXML.Create;
  try
    EnvOptionsFileName := GetMsBuildEnvOptionsFileName;
    EnvOptionsFile.LoadFromFile(EnvOptionsFileName);
    EnvOptionsFile.Options := EnvOptionsFile.Options + [sxoAutoCreate,sxoDoNotSaveProlog];

    PropertyGroupNode := EnvOptionsFile.Root.Items.ItemNamed[MsBuildPropertyGroupNodeName];
    PropertyNode := PropertyGroupNode.Items.ItemNamed[OptionName];

    PropertyNode.Value := Value;

    { Do not overwrite the original file if something goes wrong }
    BakEnvOptionsFileName := EnvOptionsFileName + '.bak';
    DeleteFile(BakEnvOptionsFileName);
    RenameFile(EnvOptionsFileName, BakEnvOptionsFileName);
    try
      EnvOptionsFile.SaveToFile(EnvOptionsFileName);
      DeleteFile(BakEnvOptionsFileName);
    except
      DeleteFile(EnvOptionsFileName);
      RenameFile(BakEnvOptionsFileName, EnvOptionsFileName);
      raise;
    end;
  finally
    EnvOptionsFile.Free;
  end;
end;

procedure TJclBDSInstallation.SetOutputCallback(const Value: TTextHandler);
begin
  inherited SetOutputCallback(Value);
  if clDccIL in CommandLineTools then
    DCCIL.OutputCallback := Value;
end;

function TJclBDSInstallation.UnregisterPackage(const BinaryFileName: string): Boolean;
begin
  if IDEVersionNumber >= 3 then
    CleanPackageCache(BinaryFileName);
  Result := inherited UnregisterPackage(BinaryFileName);
end;

{$ENDIF MSWINDOWS}

//=== { TJclBorRADToolInstallations } ========================================

constructor TJclBorRADToolInstallations.Create;
begin
  FList := TObjectList.Create;
  ReadInstallations;
end;

destructor TJclBorRADToolInstallations.Destroy;
begin
  FreeAndNil(FList);
  inherited Destroy;
end;

function TJclBorRADToolInstallations.AnyInstanceRunning: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Installations[I].AnyInstanceRunning then
    begin
      Result := True;
      Break;
    end;
end;

function TJclBorRADToolInstallations.AnyUpdatePackNeeded(var Text: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Installations[I].UpdateNeeded then
    begin
      Result := True;
      Text := Format(LoadResString(@RsNeedUpdate), [Installations[I].LatestUpdatePack, Installations[I].Name]);
      Break;
    end;
end;

function TJclBorRADToolInstallations.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TJclBorRADToolInstallations.GetBCBInstallationFromVersion(VersionNumber: Integer): TJclBorRADToolInstallation;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    case Installations[I].RadToolKind of
      brCppBuilder:
        if Installations[I].IDEVersionNumber = VersionNumber then
        begin
          Result := Installations[I];
          Break;
        end;
      brBorlandDevStudio:
        if ((VersionNumber >= 14) and (Installations[I].IDEVersionNumber = (VersionNumber - 7))) or
          ((VersionNumber >= 10) and (Installations[I].IDEVersionNumber = (VersionNumber - 6))) then
        begin
          Result := Installations[I];
          Break;
        end;
    end;
end;

function TJclBorRADToolInstallations.GetDelphiInstallationFromVersion(
  VersionNumber: Integer): TJclBorRADToolInstallation;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    case Installations[I].RadToolKind of
      brDelphi:
        if Installations[I].IDEVersionNumber = VersionNumber then
        begin
          Result := Installations[I];
          Break;
        end;
      brBorlandDevStudio:
        if ((VersionNumber >= 14) and (Installations[I].IDEVersionNumber = (VersionNumber - 7))) or
          ((VersionNumber >= 8) and (Installations[I].IDEVersionNumber = (VersionNumber - 6))) then
        begin
          Result := Installations[I];
          Break;
        end;
    end;
end;

function TJclBorRADToolInstallations.GetInstallations(Index: Integer): TJclBorRADToolInstallation;
begin
  Result := TJclBorRADToolInstallation(FList[Index]);
end;

function TJclBorRADToolInstallations.GetBCBVersionInstalled(VersionNumber: Integer): Boolean;
begin
  Result := BCBInstallationFromVersion[VersionNumber] <> nil;
end;

function TJclBorRADToolInstallations.GetBDSInstallationFromVersion(VersionNumber: Integer): TJclBorRADToolInstallation;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if (Installations[I].IDEVersionNumber = VersionNumber) and
      (Installations[I].RadToolKind = brBorlandDevStudio) then
    begin
      Result := Installations[I];
      Break;
    end;
end;

function TJclBorRADToolInstallations.GetBDSVersionInstalled(VersionNumber: Integer): Boolean;
begin
  Result := BDSInstallationFromVersion[VersionNumber] <> nil;
end;

function TJclBorRADToolInstallations.GetDelphiVersionInstalled(VersionNumber: Integer): Boolean;
begin
  Result := DelphiInstallationFromVersion[VersionNumber] <> nil;
end;

function TJclBorRADToolInstallations.Iterate(TraverseMethod: TTraverseMethod): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Count - 1 do
    Result := Result and TraverseMethod(Installations[I]);
end;

procedure TJclBorRADToolInstallations.ReadInstallations;
var
  VersionNumbers: TStringList;

  function EnumVersions(const KeyName: string; const Personalities: array of string;
    CreateClass: TJclBorRADToolInstallationClass): Boolean;
  var
    I, J: Integer;
    VersionKeyName, PersonalitiesKeyName: string;
    PersonalitiesList: TStrings;
    Installation: TJclBorRADToolInstallation;
  begin
    Result := False;
    if RegKeyExists(HKEY_LOCAL_MACHINE, KeyName) and
      RegGetKeyNames(HKEY_LOCAL_MACHINE, KeyName, VersionNumbers) then
      for I := 0 to VersionNumbers.Count - 1 do
        if StrIsSubSet(VersionNumbers[I], CharIsFracDigit) then
        begin
          VersionKeyName := KeyName + DirDelimiter + VersionNumbers[I];
          if RegKeyExists(HKEY_LOCAL_MACHINE, VersionKeyName) then
          begin
            if Length(Personalities) = 0 then
            begin
              try
                Installation := CreateClass.Create(VersionKeyName);
                if Installation.Valid then
                  FList.Add(Installation);
              finally
                Result := True;
              end;
            end
            else
            begin
              PersonalitiesList := TStringList.Create;
              try
                PersonalitiesKeyName := VersionKeyName + '\Personalities';
                if RegKeyExists(HKEY_LOCAL_MACHINE, PersonalitiesKeyName) then
                  RegGetValueNames(HKEY_LOCAL_MACHINE, PersonalitiesKeyName, PersonalitiesList);

                for J := Low(Personalities) to High(Personalities) do
                  if PersonalitiesList.IndexOf(Personalities[J]) >= 0 then
                  begin
                    try
                      Installation := CreateClass.Create(VersionKeyName);
                      if Installation.Valid then
                        FList.Add(Installation)
                      else
                        Installation.Free;
                    finally
                      Result := True;
                    end;
                    Break;
                  end;
              finally
                PersonalitiesList.Free;
              end;
            end;
          end;
        end;
  end;

begin
  FList.Clear;
  VersionNumbers := TStringList.Create;
  try
    EnumVersions(DelphiKeyName, [], TJclDelphiInstallation);
    EnumVersions(BCBKeyName, [], TJclBCBInstallation);
    EnumVersions(BDSKeyName, ['Delphi.Win32', 'BCB', 'Delphi8', 'C#Builder'], TJclBDSInstallation);
    EnumVersions(CDSKeyName, ['Delphi.Win32', 'BCB', 'Delphi8', 'C#Builder'], TJclBDSInstallation);
    EnumVersions(EDSKeyName, ['Delphi.Win32', 'BCB', 'Delphi8', 'C#Builder'], TJclBDSInstallation);
  finally
    VersionNumbers.Free;
  end;
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.

