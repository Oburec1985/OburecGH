unit uLuaCalcEngine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DynLibs;

type
  TLuaGetValue = function(Context: Pointer; const Name: UTF8String;
    out Value: Double): Boolean; cdecl;
  TLuaSetValue = function(Context: Pointer; const Name: UTF8String;
    Value, Time: Double; Status: LongInt): Boolean; cdecl;
  TLuaGetTime = function(Context: Pointer): Double; cdecl;
  TLuaLogMessage = procedure(Context: Pointer; const Message: UTF8String); cdecl;
  TLuaGetEstimate = function(Context: Pointer; const Name, Kind: UTF8String;
    out Value, Time: Double; out Status: LongInt): Boolean; cdecl;

  TLuaCalcCallbacks = record
    Context: Pointer;
    OnGetValue: TLuaGetValue;
    OnSetValue: TLuaSetValue;
    OnGetTime: TLuaGetTime;
    OnGetEstimate: TLuaGetEstimate;
    OnLogMessage: TLuaLogMessage;
  end;

  TLuaCalcEngine = class
  private
    fLibrary: TLibHandle;
    fState: Pointer;
    fCallbacks: TLuaCalcCallbacks;
    fLastError: string;
    function LoadApi: Boolean;
    function NewState: Boolean;
    procedure RegisterFunctions;
    function ReadLuaError: string;
    function ExpandTagReferences(const Script: UTF8String): UTF8String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetCallbacks(const Callbacks: TLuaCalcCallbacks);
    function Execute(const Script: UTF8String): Boolean;
    function RunMain: Boolean;
    property LastError: string read fLastError;
    property Available: Boolean read LoadApi;
  end;

implementation

const
  LUA_OK = 0;
  LUA_TFUNCTION = 6;
  LUA_REGISTRYINDEX = -1001000;

type
  TLuaCFunction = function(L: Pointer): LongInt; cdecl;
  TLuaNewState = function: Pointer; cdecl;
  TLuaOpenLibs = procedure(L: Pointer); cdecl;
  TLuaClose = procedure(L: Pointer); cdecl;
  TLuaLoadBuffer = function(L: Pointer; Buffer: PChar; Size: SizeUInt;
    Name, Mode: PChar): LongInt; cdecl;
  TLuaPCall = function(L: Pointer; Args, Results, ErrorFunc: LongInt;
    Context: Pointer; Continuation: Pointer): LongInt; cdecl;
  TLuaGetGlobal = function(L: Pointer; Name: PChar): LongInt; cdecl;
  TLuaSetGlobal = procedure(L: Pointer; Name: PChar); cdecl;
  TLuaPushClosure = procedure(L: Pointer; Func: TLuaCFunction;
    Upvalues: LongInt); cdecl;
  TLuaPushPointer = procedure(L, Value: Pointer); cdecl;
  TLuaToPointer = function(L: Pointer; Index: LongInt): Pointer; cdecl;
  TLuaToString = function(L: Pointer; Index: LongInt;
    Size: PSizeUInt): PChar; cdecl;
  TLuaToNumber = function(L: Pointer; Index: LongInt;
    IsNumber: PLongInt): Double; cdecl;
  TLuaPushNumber = procedure(L: Pointer; Value: Double); cdecl;
  TLuaGetTop = function(L: Pointer): LongInt; cdecl;
  TLuaSetTop = procedure(L: Pointer; Index: LongInt); cdecl;

var
  LuaNewState: TLuaNewState;
  LuaOpenLibs: TLuaOpenLibs;
  LuaClose: TLuaClose;
  LuaLoadBuffer: TLuaLoadBuffer;
  LuaPCall: TLuaPCall;
  LuaGetGlobal: TLuaGetGlobal;
  LuaSetGlobal: TLuaSetGlobal;
  LuaPushClosure: TLuaPushClosure;
  LuaPushPointer: TLuaPushPointer;
  LuaToPointer: TLuaToPointer;
  LuaToString: TLuaToString;
  LuaToNumber: TLuaToNumber;
  LuaPushNumber: TLuaPushNumber;
  LuaGetTop: TLuaGetTop;
  LuaSetTop: TLuaSetTop;

function CurrentEngine(L: Pointer): TLuaCalcEngine;
begin
  Result := TLuaCalcEngine(LuaToPointer(L, LUA_REGISTRYINDEX - 1));
end;

function LuaName(L: Pointer; Index: LongInt): UTF8String;
var
  Size: SizeUInt;
  Data: PChar;
begin
  Data := LuaToString(L, Index, @Size);
  if Data = nil then Exit('');
  SetString(Result, Data, Size);
end;

function GetValueCall(L: Pointer): LongInt; cdecl;
var
  Engine: TLuaCalcEngine;
  Value: Double;
begin
  Engine := CurrentEngine(L);
  Value := 0;
  try
    if Assigned(Engine.fCallbacks.OnGetValue) then
      Engine.fCallbacks.OnGetValue(Engine.fCallbacks.Context, LuaName(L, 1), Value);
  except
    on Error: Exception do Engine.fLastError := Error.Message;
  end;
  LuaPushNumber(L, Value);
  Result := 1;
end;

function SetValueCall(L: Pointer): LongInt; cdecl;
var
  Engine: TLuaCalcEngine;
  IsNumber: LongInt;
  Value, Time: Double;
  Status: LongInt;
begin
  Engine := CurrentEngine(L);
  IsNumber := 0;
  Value := LuaToNumber(L, 2, @IsNumber);
  if (IsNumber <> 0) and Assigned(Engine.fCallbacks.OnSetValue) then
  begin
    Time := -1;
    Status := 0;
    if LuaGetTop(L) >= 3 then Time := LuaToNumber(L, 3, nil);
    if LuaGetTop(L) >= 4 then Status := Trunc(LuaToNumber(L, 4, nil));
    try
      Engine.fCallbacks.OnSetValue(Engine.fCallbacks.Context,
        LuaName(L, 1), Value, Time, Status);
    except
      on Error: Exception do Engine.fLastError := Error.Message;
    end;
  end;
  Result := 0;
end;

function GetTimeCall(L: Pointer): LongInt; cdecl;
var
  Engine: TLuaCalcEngine;
  Value: Double;
begin
  Engine := CurrentEngine(L);
  Value := 0;
  try
    if Assigned(Engine.fCallbacks.OnGetTime) then
      Value := Engine.fCallbacks.OnGetTime(Engine.fCallbacks.Context);
  except
    on Error: Exception do Engine.fLastError := Error.Message;
  end;
  LuaPushNumber(L, Value);
  Result := 1;
end;

function LogMessageCall(L: Pointer): LongInt; cdecl;
var
  Engine: TLuaCalcEngine;
begin
  Engine := CurrentEngine(L);
  try
    if Assigned(Engine.fCallbacks.OnLogMessage) then
      Engine.fCallbacks.OnLogMessage(Engine.fCallbacks.Context, LuaName(L, 1));
  except
    on Error: Exception do Engine.fLastError := Error.Message;
  end;
  Result := 0;
end;

function GetEstimateCall(L: Pointer): LongInt; cdecl;
var
  Engine: TLuaCalcEngine;
  Value, Time: Double;
  Status: LongInt;
  Kind: UTF8String;
begin
  Engine := CurrentEngine(L);
  Value := 0;
  Time := 0;
  Status := 0;
  Kind := 'm';
  if LuaGetTop(L) >= 2 then Kind := LuaName(L, 2);
  try
    if Assigned(Engine.fCallbacks.OnGetEstimate) then
      Engine.fCallbacks.OnGetEstimate(Engine.fCallbacks.Context,
        LuaName(L, 1), Kind, Value, Time, Status);
  except
    on Error: Exception do Engine.fLastError := Error.Message;
  end;
  LuaPushNumber(L, Value);
  LuaPushNumber(L, Time);
  LuaPushNumber(L, Status);
  Result := 3;
end;

constructor TLuaCalcEngine.Create;
begin
  inherited Create;
  fLibrary := NilHandle;
  fState := nil;
  FillChar(fCallbacks, SizeOf(fCallbacks), 0);
end;

destructor TLuaCalcEngine.Destroy;
begin
  if fState <> nil then LuaClose(fState);
  if fLibrary <> NilHandle then UnloadLibrary(fLibrary);
  inherited Destroy;
end;

procedure TLuaCalcEngine.SetCallbacks(const Callbacks: TLuaCalcCallbacks);
begin
  fCallbacks := Callbacks;
end;

function TLuaCalcEngine.LoadApi: Boolean;
const
{$ifdef Windows}
  Names: array[0..3] of string =
    ('lua53.dll', 'lua5.3.dll', 'lua54.dll', 'lua5.4.dll');
{$else}
  Names: array[0..3] of string =
    ('liblua5.3.so.0', 'liblua5.4.so.0', 'liblua5.3.so', 'liblua5.4.so');
{$endif}
var
  Name: string;
begin
  if fLibrary = NilHandle then
    for Name in Names do
    begin
      fLibrary := LoadLibrary(Name);
      if fLibrary <> NilHandle then Break;
    end;
  Result := fLibrary <> NilHandle;
  if not Result then
  begin
    fLastError := 'Lua 5.3/5.4 library was not found';
    Exit;
  end;
  Pointer(LuaNewState) := GetProcedureAddress(fLibrary, 'luaL_newstate');
  Pointer(LuaOpenLibs) := GetProcedureAddress(fLibrary, 'luaL_openlibs');
  Pointer(LuaClose) := GetProcedureAddress(fLibrary, 'lua_close');
  Pointer(LuaLoadBuffer) := GetProcedureAddress(fLibrary, 'luaL_loadbufferx');
  Pointer(LuaPCall) := GetProcedureAddress(fLibrary, 'lua_pcallk');
  Pointer(LuaGetGlobal) := GetProcedureAddress(fLibrary, 'lua_getglobal');
  Pointer(LuaSetGlobal) := GetProcedureAddress(fLibrary, 'lua_setglobal');
  Pointer(LuaPushClosure) := GetProcedureAddress(fLibrary, 'lua_pushcclosure');
  Pointer(LuaPushPointer) := GetProcedureAddress(fLibrary, 'lua_pushlightuserdata');
  Pointer(LuaToPointer) := GetProcedureAddress(fLibrary, 'lua_touserdata');
  Pointer(LuaToString) := GetProcedureAddress(fLibrary, 'lua_tolstring');
  Pointer(LuaToNumber) := GetProcedureAddress(fLibrary, 'lua_tonumberx');
  Pointer(LuaPushNumber) := GetProcedureAddress(fLibrary, 'lua_pushnumber');
  Pointer(LuaGetTop) := GetProcedureAddress(fLibrary, 'lua_gettop');
  Pointer(LuaSetTop) := GetProcedureAddress(fLibrary, 'lua_settop');
  Result := Assigned(LuaNewState) and Assigned(LuaOpenLibs) and
    Assigned(LuaClose) and Assigned(LuaLoadBuffer) and Assigned(LuaPCall) and
    Assigned(LuaGetGlobal) and Assigned(LuaSetGlobal) and
    Assigned(LuaPushClosure) and Assigned(LuaPushPointer) and
    Assigned(LuaToPointer) and Assigned(LuaToString) and
    Assigned(LuaToNumber) and Assigned(LuaPushNumber) and
    Assigned(LuaGetTop) and Assigned(LuaSetTop);
  if not Result then fLastError := 'Lua library has an incomplete API';
end;

procedure TLuaCalcEngine.RegisterFunctions;

  procedure RegisterOne(const Name: PChar; Callback: TLuaCFunction);
  begin
    LuaPushPointer(fState, Self);
    LuaPushClosure(fState, Callback, 1);
    LuaSetGlobal(fState, Name);
  end;

begin
  RegisterOne('getValue', @GetValueCall);
  RegisterOne('setValue', @SetValueCall);
  RegisterOne('setValueEx', @SetValueCall);
  RegisterOne('getRecorderTime', @GetTimeCall);
  RegisterOne('getEstimate', @GetEstimateCall);
  RegisterOne('logMessage', @LogMessageCall);
end;

function TLuaCalcEngine.NewState: Boolean;
begin
  Result := LoadApi;
  if not Result then Exit;
  if fState <> nil then LuaClose(fState);
  fState := LuaNewState();
  Result := fState <> nil;
  if not Result then
  begin
    fLastError := 'Lua state allocation failed';
    Exit;
  end;
  LuaOpenLibs(fState);
  RegisterFunctions;
end;

function TLuaCalcEngine.ReadLuaError: string;
begin
  Result := string(LuaName(fState, -1));
  if Result = '' then Result := 'Unknown Lua error';
  LuaSetTop(fState, 0);
end;

function TLuaCalcEngine.ExpandTagReferences(const Script: UTF8String): UTF8String;
var
  Index, Closing, StartOfLine, AfterTag: SizeInt;
  Quote: AnsiChar;
  Name: UTF8String;
  AssignmentOpen: Boolean;

  function EscapeLua(const Value: UTF8String): UTF8String;
  var
    Ch: AnsiChar;
  begin
    Result := '';
    for Ch in Value do
      case Ch of
        '\', '"': Result := Result + '\' + Ch;
        #10: Result := Result + '\n';
        #13: Result := Result + '\r';
      else
        Result := Result + Ch;
      end;
  end;

begin
  Result := '';
  Index := 1;
  Quote := #0;
  AssignmentOpen := False;
  while Index <= Length(Script) do
  begin
    if Quote <> #0 then
    begin
      Result := Result + Script[Index];
      if (Script[Index] = '\') and (Index < Length(Script)) then
      begin
        Inc(Index);
        Result := Result + Script[Index];
      end
      else if Script[Index] = Quote then Quote := #0;
    end
    else if (Script[Index] = '"') or (Script[Index] = '''') then
    begin
      Quote := Script[Index];
      Result := Result + Script[Index];
    end
    else if (Script[Index] = '-') and (Index < Length(Script)) and
      (Script[Index + 1] = '-') then
    begin
      if AssignmentOpen then
      begin
        Result := Result + ')';
        AssignmentOpen := False;
      end;
      repeat
        Result := Result + Script[Index];
        Inc(Index);
      until (Index > Length(Script)) or (Script[Index] = #10);
      Continue;
    end
    else if (Script[Index] = #10) or (Script[Index] = ';') then
    begin
      if AssignmentOpen then
      begin
        Result := Result + ')';
        AssignmentOpen := False;
      end;
      Result := Result + Script[Index];
    end
    else if Script[Index] = '{' then
    begin
      Closing := Index + 1;
      while (Closing <= Length(Script)) and (Script[Closing] <> '}') and
        (Script[Closing] <> #10) do Inc(Closing);
      if (Closing <= Length(Script)) and (Script[Closing] = '}') and
        (Closing > Index + 1) then
      begin
        Name := Copy(Script, Index + 1, Closing - Index - 1);
        StartOfLine := Index - 1;
        while (StartOfLine > 0) and (Script[StartOfLine] <> #10) and
          (Script[StartOfLine] in [' ', #9, #13]) do Dec(StartOfLine);
        AfterTag := Closing + 1;
        if Copy(Script, AfterTag, 6) = '.Value' then Inc(AfterTag, 6);
        while (AfterTag <= Length(Script)) and
          (Script[AfterTag] in [' ', #9]) do Inc(AfterTag);
        if (StartOfLine = 0) or (Script[StartOfLine] = #10) then
        begin
          if (AfterTag <= Length(Script)) and (Script[AfterTag] = '=') and
            ((AfterTag = Length(Script)) or (Script[AfterTag + 1] <> '=')) then
          begin
            Result := Result + 'setValue("' + EscapeLua(Name) + '", ';
            AssignmentOpen := True;
            Index := AfterTag;
          end
          else if Copy(Script, Closing + 1, 6) = '.Value' then
          begin
            Result := Result + 'getValue("' + EscapeLua(Name) + '")';
            Index := Closing + 6;
          end
          else Result := Result + Script[Index];
        end
        else if Copy(Script, Closing + 1, 6) = '.Value' then
        begin
          Result := Result + 'getValue("' + EscapeLua(Name) + '")';
          Index := Closing + 6;
        end
        else Result := Result + Script[Index];
      end
      else Result := Result + Script[Index];
    end
    else Result := Result + Script[Index];
    Inc(Index);
  end;
  if AssignmentOpen then Result := Result + ')';
end;

function TLuaCalcEngine.Execute(const Script: UTF8String): Boolean;
var
  Expanded: UTF8String;
begin
  fLastError := '';
  Result := NewState;
  if not Result then Exit;
  Expanded := ExpandTagReferences(Script);
  Result := LuaLoadBuffer(fState, PChar(Expanded), Length(Expanded),
    'calculation', nil) = LUA_OK;
  if Result then Result := LuaPCall(fState, 0, 0, 0, nil, nil) = LUA_OK;
  if not Result then
  begin
    fLastError := ReadLuaError;
    Exit;
  end;
  Result := RunMain;
end;

function TLuaCalcEngine.RunMain: Boolean;
begin
  Result := False;
  fLastError := '';
  if fState = nil then
  begin
    fLastError := 'Lua script is not loaded';
    Exit;
  end;
  if LuaGetGlobal(fState, 'lua_main') <> LUA_TFUNCTION then
  begin
    LuaSetTop(fState, 0);
    fLastError := 'Lua function lua_main() is missing';
    Exit;
  end;
  Result := LuaPCall(fState, 0, 0, 0, nil, nil) = LUA_OK;
  if not Result then fLastError := ReadLuaError
  else Result := fLastError = '';
end;

end.
