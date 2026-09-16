unit uRecorderPluginApi;

{$mode objfpc}{$H+}

interface

const
  PLUGIN_CLASS = 0;
  PN_ENTERRCCONFIG = 0;
  PN_LEAVERCCONFIG = 1;
  PN_RCSTART = 3;
  PN_RCSTOP = 5;
  PN_UPDATEDATA = 6;
  PN_RCSAVECONFIG = 8;
  PN_RCLOADCONFIG = 9;
  PN_RCINITIALIZED = 24;

type
  { Original Recorder PLUGININFO prefix and its current four-part version.
    Do not pack: the C++ ABI pads the 503-byte text prefix to a Word boundary. }
  TRecorderPluginInfo = record
    Name: array[0..100] of AnsiChar;
    Describe: array[0..200] of AnsiChar;
    Vendor: array[0..200] of AnsiChar;
    Version: SmallInt;
    SubVersion: SmallInt;
    BugFix: SmallInt;
    BuildNumber: SmallInt;
  end;

  TRecorderPluginGetInfo = procedure(var AInfo: TRecorderPluginInfo); cdecl;
  TRecorderPluginGetType = function: LongInt; cdecl;
  TRecorderPluginGetDescription = function: PAnsiChar; cdecl;

  { Only POD values and callbacks cross the library boundary. The host owns
    visual models and the plugin owns the instance passed as APluginContext. }
  TRecorderPluginComponentSpec = record
    Size: LongInt;
    Width: LongInt;
    Height: LongInt;
    Name: array[0..127] of AnsiChar;
  end;
  PRecorderPluginComponentSpec = ^TRecorderPluginComponentSpec;
  TRecorderPluginCreateComponent = function(APluginContext: Pointer;
    ASpec: PRecorderPluginComponentSpec): LongBool; cdecl;
  TRecorderPluginRegisterOscillogramFactory = function(AHostContext: Pointer;
    ATypeId, ACaption, AGroupId: PAnsiChar;
    ACreate: TRecorderPluginCreateComponent;
    APluginContext: Pointer): LongBool; cdecl;
  PRecorderPluginHostApi = ^TRecorderPluginHostApi;
  TRecorderPluginHostApi = record
    Size: LongInt;
    HostContext: Pointer;
    RegisterOscillogramFactory: TRecorderPluginRegisterOscillogramFactory;
  end;
  TRecorderPluginCreateClass = function: Pointer; cdecl;
  TRecorderPluginDestroyClass = function(AInstance: Pointer): LongInt; cdecl;
  TRecorderPluginCreate = function(AInstance: Pointer;
    AHostApi: PRecorderPluginHostApi): LongBool; cdecl;
  TRecorderPluginNotify = function(AInstance: Pointer; AEvent: LongInt;
    AData: Pointer): LongBool; cdecl;
  TRecorderPluginClose = function(AInstance: Pointer): LongBool; cdecl;

implementation

end.
