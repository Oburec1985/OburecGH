unit uRecorderPluginApi;

{ Общий контракт старого API плагинов Recorder для хоста и библиотек плагинов.
  Обязательные правила границы ABI:
  * Это плоский версионированный C ABI: существующие начальные поля записей
    сохраняются, новые необязательные поля добавляются в конец. Перед чтением
    каждого добавленного поля проверяется Size.
  * Через границу передаются только простые записи фиксированной структуры,
    указатели на буферы вызывающего кода и функции cdecl. Нельзя передавать
    элементы LCL, TOglChart/TCanvas, интерфейсы и классы Pascal, управляемые
    строки или динамические массивы.
  * Записи регистрации осциллограммы оставлены для переходной совместимости.
    Новые компоненты должны использовать общие контракты без привязки
    функций хоста к конкретному компоненту.
}

{$mode objfpc}{$H+}{$codepage UTF8}

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

  RC_PLUGIN_CAP_TOOLBAR = QWord(1) shl 0;
  RC_PLUGIN_CAP_CONTROL_PANEL = QWord(1) shl 1;
  RC_PLUGIN_CAP_LEGEND = QWord(1) shl 2;
  RC_PLUGIN_CAP_X_CURSOR = QWord(1) shl 3;
  RC_PLUGIN_CAP_LEVEL_CURSOR = QWord(1) shl 4;
  RC_PLUGIN_CAP_AUTO_RANGE = QWord(1) shl 5;
  RC_PLUGIN_CAP_MULTI_AXIS = QWord(1) shl 6;
  RC_PLUGIN_CAP_TRIGGER = QWord(1) shl 7;
  RC_PLUGIN_CAP_EXTREMA = QWord(1) shl 8;
  RC_PLUGIN_CAP_SIGNAL_GRID = QWord(1) shl 9;
  RC_PLUGIN_CAP_INTERACTIVE_CHART = QWord(1) shl 10;

type
  { Начальная часть PLUGININFO исходного Recorder и версия из четырёх чисел.
    Не упаковывать: ABI C++ выравнивает текстовую часть в 503 байта до Word. }
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

  { Начальные поля старого API осциллограммы: переходный мост пока использует
    модель хоста. Новое состояние компонента должно принадлежать плагину;
    существующие начальные поля менять нельзя. }
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
  PRecorderPluginComponentEvent = ^TRecorderPluginComponentEvent;
  TRecorderPluginComponentEvent = record
    Size: LongInt;
    Name: array[0..63] of AnsiChar;
    ControlId: array[0..63] of AnsiChar;
    Value1: Double;
    Value2: Double;
    IntValue: Int64;
    Flags: QWord;
  end;
  PRecorderPluginComponentResult = ^TRecorderPluginComponentResult;
  TRecorderPluginComponentResult = record
    Size: LongInt;
    Handled: LongBool;
    Actions: QWord;
    Text: array[0..255] of AnsiChar;
    Value1: Double;
    Value2: Double;
    IntValue: Int64;
  end;
  TRecorderPluginComponentDispatch = function(AComponentContext: Pointer;
    AEvent: PRecorderPluginComponentEvent;
    AResult: PRecorderPluginComponentResult): LongBool; cdecl;
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
    DoEvent: TRecorderPluginComponentDispatch;
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
  TRecorderPluginTagExists = function(AHostContext: Pointer;
    AName: PAnsiChar): LongBool; cdecl;
  TRecorderPluginGetTagAlarmLevel = function(AHostContext: Pointer;
    AName: PAnsiChar; out ALevel: LongInt): LongBool; cdecl;
  TRecorderPluginGetTagSetpoint = function(AHostContext: Pointer;
    AName: PAnsiChar; AKind: LongInt; out AThreshold: Double;
    out AEnabled: LongBool): LongBool; cdecl;
  TRecorderPluginSetTagSetpoint = function(AHostContext: Pointer;
    AName: PAnsiChar; AKind: LongInt; AThreshold: Double;
    AEnabled: LongBool): LongBool; cdecl;
  TRecorderPluginGetRecorderTime = function(AHostContext: Pointer;
    out ATimeSec: Double): LongBool; cdecl;
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
    TagExists: TRecorderPluginTagExists;
    GetTagAlarmLevel: TRecorderPluginGetTagAlarmLevel;
    GetTagSetpoint: TRecorderPluginGetTagSetpoint;
    SetTagSetpoint: TRecorderPluginSetTagSetpoint;
    GetRecorderTime: TRecorderPluginGetRecorderTime;
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
