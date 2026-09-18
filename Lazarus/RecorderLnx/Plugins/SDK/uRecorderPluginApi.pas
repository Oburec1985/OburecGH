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
  PRecorderPluginOscillogramFrame = ^TRecorderPluginOscillogramFrame;
  TRecorderPluginOscillogramFrame = record
    Size: LongInt;
    SampleCount: LongInt;
    Values: PDouble;
    DisplaySeconds: Double;
    MinValue: Double;
    MaxValue: Double;
    RmsValue: Double;
  end;
  TRecorderPluginOscillogramRepaint = function(AComponentContext: Pointer;
    AFrame: PRecorderPluginOscillogramFrame): LongBool; cdecl;
  TRecorderPluginOscillogramClose = procedure(AComponentContext: Pointer); cdecl;
  TRecorderPluginComponentSpec = record
    Size: LongInt;
    Width: LongInt;
    Height: LongInt;
    Name: array[0..127] of AnsiChar;
    SelectedTagId: Int64;
    SelectedTagName: array[0..255] of AnsiChar;
    ComponentContext: Pointer;
    DoRepaint: TRecorderPluginOscillogramRepaint;
    DoClose: TRecorderPluginOscillogramClose;
  end;
  PRecorderPluginComponentSpec = ^TRecorderPluginComponentSpec;
  TRecorderPluginCreateComponent = function(APluginContext: Pointer;
    ASpec: PRecorderPluginComponentSpec): LongBool; cdecl;
  TRecorderPluginRegisterOscillogramFactory = function(AHostContext: Pointer;
    ATypeId, ACaption, AGroupId: PAnsiChar;
    ACreate: TRecorderPluginCreateComponent;
    APluginContext: Pointer): LongBool; cdecl;
  TRecorderPluginTagInfo = record
    Size: LongInt;
    Id: Int64;
    Name: array[0..255] of AnsiChar;
    UnitName: array[0..63] of AnsiChar;
    IsVirtual: LongBool;
  end;
  PRecorderPluginTagInfo = ^TRecorderPluginTagInfo;
  TRecorderPluginTagCount = function(AHostContext: Pointer): LongInt; cdecl;
  TRecorderPluginGetTagInfo = function(AHostContext: Pointer;
    AIndex: LongInt; AInfo: PRecorderPluginTagInfo): LongBool; cdecl;
  TRecorderPluginReadTagValue = function(AHostContext: Pointer;
    AName: PAnsiChar; out ATimeSec, AValue: Double): LongBool; cdecl;
  TRecorderPluginPublishTagValue = function(AHostContext: Pointer;
    AName: PAnsiChar; AValue: Double): LongBool; cdecl;
  TRecorderPluginGetProjectDirectory = function(AHostContext: Pointer;
    ABuffer: PAnsiChar; ABufferSize: LongInt): LongInt; cdecl;
  TRecorderPluginLogMessage = procedure(AHostContext: Pointer;
    AMessage: PAnsiChar); cdecl;
  PRecorderPluginHostApi = ^TRecorderPluginHostApi;
  TRecorderPluginHostApi = record
    Size: LongInt;
    HostContext: Pointer;
    RegisterOscillogramFactory: TRecorderPluginRegisterOscillogramFactory;
    TagCount: TRecorderPluginTagCount;
    GetTagInfo: TRecorderPluginGetTagInfo;
    ReadTagValue: TRecorderPluginReadTagValue;
    PublishTagValue: TRecorderPluginPublishTagValue;
    GetProjectDirectory: TRecorderPluginGetProjectDirectory;
    LogMessage: TRecorderPluginLogMessage;
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
