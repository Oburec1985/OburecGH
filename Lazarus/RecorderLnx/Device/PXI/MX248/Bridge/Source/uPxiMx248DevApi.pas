unit uPxiMx248DevApi;

{ x86 DevAPI session owned by the bridge command thread (STA COM apartment).
  Configure prepares hardware coefficients and bounded callback storage.
  The vendor acquisition thread copies ONLY complete blocks to that storage;
  IPC ReadBlock consumes one aligned block from all eight channels.
  Never enable async acquisition without valid per-channel TChanDataDesc
  buffers, read its FIFO concurrently with the callback, or move coefficient
  loading to an MTA: see ../Docs/README.md and the acquisition error journal. }

interface

uses Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.Math, System.Classes,
  System.Win.Registry, uPxiMx248BridgeProtocol;

type
  { devapi/Types.h, x86 ABI. The vendor writes a complete block into Buf
    before invoking its cdecl task handler. }
  TChanDataDesc = record
    Data, Handle, Buf, BufInfo: Pointer;
    BufState: Cardinal;
  end;
  PChanDataDesc = ^TChanDataDesc;
  TChanDescPointers = array[0..7] of PChanDataDesc;
  PChanDescPointers = ^TChanDescPointers;
  TChanDataDescArray = record
    Count: Cardinal;
    Desc: PChanDescPointers;
  end;
  PChanDataDescArray = ^TChanDataDescArray;
  TLocation = record Data: array[0..139] of Byte end;
  TDeviceRoute = record BusType: Integer; Location: TLocation end;
  TDevice = record
    DeviceType, DeviceObjectType: Integer; Route: TDeviceRoute;
    DeviceName, RevString, Description: array[0..255] of AnsiChar;
    RevisionNo, SerialNo: Word; DllName: array[0..MAX_PATH-1] of AnsiChar;
    Creator, Finder: Pointer; HWProtocol, Priority: Word;
  end;
  TDeviceEnum = record Count: Integer; Items: array[0..110] of TDevice end;
  TDevCtrlDevice = record
    DeviceType, ObjectType: Cardinal;
    Route: TDeviceRoute;
    DeviceName, RevString: array[0..31] of AnsiChar;
    Description: array[0..99] of AnsiChar;
    RevisionNo, SerialNo: Word;
    DllName: array[0..99] of AnsiChar;
    Creator, Finder: Pointer;
    HWProtocol: Word;
  end;
  TDevCtrlDeviceEnum = record
    Count: Integer;
    Items: array[0..110] of TDevCtrlDevice;
  end;
  IDevCtrlDeviceControl = interface(IUnknown)
    function InitDeviceRecord(P: Pointer): HRESULT; stdcall;
    function InitDeviceEnumRecord(P: Pointer): HRESULT; stdcall;
    function EditObject(A, B: Pointer): HRESULT; stdcall;
    function GetDeviceInfo(A: Cardinal; B: Pointer): HRESULT; stdcall;
    function CreateDeviceMain(A, B: Pointer): HRESULT; stdcall;
    function GetAllDevices(A: Pointer): HRESULT; stdcall;
    function GetAllSearchDevices(A: Cardinal; B: Pointer): HRESULT; stdcall;
    function GetModuleInfo(A, B: Cardinal; C: Pointer): HRESULT; stdcall;
    function CreateDeviceModule(A, B: Pointer): HRESULT; stdcall;
    function AutoSearchModule(A, B: Pointer): HRESULT; stdcall;
    function GetAllModules(A: Cardinal; B: Pointer): HRESULT; stdcall;
    function GetPidControl(A, B: Pointer): HRESULT; stdcall;
    function StartDevice(A: Pointer): HRESULT; stdcall;
    function StopDevice(A: Pointer): HRESULT; stdcall;
    function GetDeviceByDeviceInfo(A, B: Pointer): HRESULT; stdcall;
    function SearchDevices(A: Pointer): HRESULT; stdcall;
    function SystemConfigChanged(Changed: LongBool): HRESULT; stdcall;
    function GetSpecDeviceController(A: Pointer; const B: TGUID;
      C: Pointer): HRESULT; stdcall;
    function RetrieveSettings(A: Pointer; B: Cardinal): HRESULT; stdcall;
    function BurnSettings(A: Pointer; B: Cardinal): HRESULT; stdcall;
    function ResetDevice(A: Pointer): HRESULT; stdcall;
  end;
  TDevApiBinding = class
  private
    FModule: HMODULE;
    FDevCtrlModule: HMODULE;
    FDeviceControl: IDevCtrlDeviceControl;
    FMissing: string;
    FDevice: THandle;
    FSelectedDevice: TDevice;
    FDevices: TDeviceEnum;
    FSystemConfigChanged: procedure(Changed: LongBool); stdcall;
    FSearch: function(var D: TDeviceEnum): Cardinal; stdcall;
    FGetAllDevices: function(var D: TDeviceEnum): Cardinal; stdcall;
    FGetAllSearchDevices: function(DeviceType: Integer;
      var D: TDeviceEnum): Cardinal; stdcall;
    FCreate: function(var D: TDevice; out H: THandle): Cardinal; stdcall;
    FDelete: function(H: THandle): Cardinal; stdcall;
    FReset: function(H: THandle; Flags: Cardinal): Cardinal; stdcall;
    FTest: function(H: THandle): Cardinal; stdcall;
    FConfig, FProgramming: function(H: THandle; Flags: Cardinal): Cardinal; stdcall;
    FStart, FStop: function(H: THandle): Cardinal; stdcall;
    FCreateTrigger: function(out Trigger: THandle; Devices: PHandle;
      DeviceCount: Integer): Cardinal; stdcall;
    FDeleteTrigger, FTrigger: function(Trigger: THandle): Cardinal; stdcall;
    FGetPropertyL: function(H: THandle; Prop: Integer; Value: PLongint; Index: Integer): Cardinal; stdcall;
    FGetPropertyD: function(H: THandle; Prop: Integer; Value: PDouble; Index: Integer): Cardinal; stdcall;
    FGetPropertyV: function(H: THandle; Prop: Integer; Value: Pointer; Index: Integer): Cardinal; stdcall;
    FSetPropertyL: function(H: THandle; Prop, Value, Index: Integer): Cardinal; stdcall;
    FSetPropertyD: function(H: THandle; Prop: Integer; Value: Double; Index: Integer): Cardinal; stdcall;
    FSetPropertyV: function(H: THandle; Prop: Integer; Value: Pointer; Index: Integer): Cardinal; stdcall;
    FZBalance: function(Device, Channel: THandle; Value: PDouble): Cardinal; stdcall;
    FCollectChanID: function(H: THandle; IDs: PCardinal; ChanType: Integer): Cardinal; stdcall;
    FGetChannel: function(ID: Cardinal): THandle; stdcall;
    FAddChannel: function(ID: Cardinal): THandle; stdcall;
    FLock: function(H: THandle; RequestSize: Integer; out P0: Pointer;
      out S0: Integer; out P1: Pointer; out S1: Integer): Cardinal; stdcall;
    FUnlock: function(H: THandle; S0, S1: Integer): Cardinal; stdcall;
    FChannelIds: array of Cardinal;
    FChannels: array of THandle;
    FWordLengths: array of Integer;
    FLogicalChannels: array of Integer;
    FReadyEvent: THandle;
    FQueueLock: TRTLCriticalSection;
    FDescriptors: array[0..7] of TChanDataDesc;
    FCallbackBuffers: array[0..7] of TBytes;
    FQueuedBuffers: array[0..7] of TBytes;
    FQueueRead, FQueueWrite, FQueueCount: array[0..7] of Integer;
    FBlockBytes: Integer;
    FQueueOverflow: Boolean;
    FComInitialized: Boolean;
    FStreamNeedsProgramming: Boolean;
    FBlocksRead: Int64;
    FLoadTransformer: function(H: THandle): Cardinal; stdcall;
    function PrepareCallbackBuffers(ASamples: Integer): Cardinal;
    procedure AcceptCallback(AArray: PChanDataDescArray);
    function AllChannelsReady: Boolean;
    function BindChannels: Cardinal;
    function PulseTrigger: Cardinal;
  public
    constructor Create;
    destructor Destroy; override;
    function Load(const ADirectory: string): Boolean;
    function Discover(out AText: string): Cardinal;
    function Open(AIndex: Integer): Cardinal;
    function OpenRoute(ACrateSerial, ASlot: Integer): Cardinal;
    function Identity(out AText: string): Cardinal;
    function TestDevice: Cardinal;
    function Configure(const AConfig: TMx248ConfigureV1): Cardinal;
    function ReadProperties(out AText: string): Cardinal;
    function ConfigurePxi(const AConfig: TMx248PxiConfigV1): Cardinal;
    function ZeroBalance(AChannelMask: Cardinal; out AText: string): Cardinal;
    function Start: Cardinal;
    function Stop: Cardinal;
    function ReadBlock(ASamples: Integer; var AData: TBytes;
      out ADataSize: Integer): Cardinal;
    procedure Close;
    property Missing: string read FMissing;
  end;

implementation

{ Windows SDK combaseapi.h; absent in the Delphi 11 ActiveX declarations. }
const
  COWAIT_DISPATCH_CALLS = 8;
  COWAIT_DISPATCH_WINDOW_MESSAGES = $10;
function CoWaitForMultipleHandles(Flags, Timeout, HandleCount: Cardinal;
  Handles: PHandle; out ReadyIndex: Cardinal): HRESULT; stdcall;
  external 'ole32.dll';

procedure DevApiDiagnosticLog(const AText: string);
var
  F: TextFile;
  LogPath: string;
begin
  LogPath := GetEnvironmentVariable('RECORDER_MX248_LOG');
  if LogPath = '' then Exit;
  try
    AssignFile(F, LogPath);
    if FileExists(LogPath) then Append(F) else Rewrite(F);
    try
      WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
        ' [MX248] ', AText);
    finally
      CloseFile(F);
    end;
  except
    { Diagnostics must never change device discovery semantics. }
  end;
end;

const
  CQueueBlocks = 32;
  CBufferWaitTimeout = 1460; { Windows ERROR_TIMEOUT }
  CBufferOverflow = 60; { DevAPI ERROR_READBUFFER_OVERFLOW }

function Mx248ReadyCallback(ADevice, AEvent, AData: Pointer): Cardinal; cdecl;
var lArray: PChanDataDescArray; lOwner: TDevApiBinding;
begin
  Result:=0;
  lArray:=PChanDataDescArray(AData);
  if (lArray=nil) or (lArray.Count=0) or (lArray.Count>8) or
    (lArray.Desc=nil) or (lArray.Desc^[0]=nil) then Exit;
  lOwner:=TDevApiBinding(lArray.Desc^[0]^.Data);
  if lOwner<>nil then lOwner.AcceptCallback(lArray);
end;

constructor TDevApiBinding.Create;
begin
  inherited Create;
  { Confirmed on MX-248 SN3253: MTA coefficient loading returns success but
    vendor Eval produces no blocks. Original Recorder uses a STA owner. }
  FComInitialized:=Succeeded(CoInitializeEx(nil,COINIT_APARTMENTTHREADED));
  InitializeCriticalSection(FQueueLock);
  FReadyEvent:=CreateEvent(nil,True,False,nil);
end;

function TDevApiBinding.AllChannelsReady: Boolean;
var I: Integer;
begin
  Result:=True;
  for I:=0 to 7 do if FQueueCount[I]=0 then Exit(False);
end;

procedure TDevApiBinding.AcceptCallback(AArray: PChanDataDescArray);
var I, Channel: Integer; lDesc: PChanDataDesc;
begin
  EnterCriticalSection(FQueueLock);
  try
    for I:=0 to Integer(AArray.Count)-1 do begin
      lDesc:=AArray.Desc^[I];
      Channel:=Integer(lDesc^.Handle);
      if (Channel<0) or (Channel>7) then Continue;
      if FQueueCount[Channel]=CQueueBlocks then begin
        FQueueOverflow:=True;
        SetEvent(FReadyEvent);
        Exit;
      end;
      Move(lDesc^.Buf^, FQueuedBuffers[Channel][FQueueWrite[Channel]*FBlockBytes],FBlockBytes);
      FQueueWrite[Channel]:=(FQueueWrite[Channel]+1) mod CQueueBlocks;
      Inc(FQueueCount[Channel]);
    end;
    if AllChannelsReady then SetEvent(FReadyEvent);
  finally
    LeaveCriticalSection(FQueueLock);
  end;
end;

function TDevApiBinding.PrepareCallbackBuffers(ASamples: Integer): Cardinal;
const PROP_HANDLER=$3017; PROP_HANDLER_DATA=$3018; PROP_DEVICE_ASYNC=$3009;
var I: Integer;
begin
  FBlockBytes:=ASamples*4;
  if FReadyEvent=0 then Exit(32); { DevAPI ERROR_CREATE_EVENT }
  { Select descriptor-array callback ABI rather than MR-ready-channel ABI. }
  Result:=FSetPropertyL(FDevice,$301A,0,-1);
  if Result<>0 then Exit;
  FQueueOverflow:=False;
  ResetEvent(FReadyEvent);
  for I:=0 to 7 do begin
    SetLength(FCallbackBuffers[I],FBlockBytes);
    SetLength(FQueuedBuffers[I],FBlockBytes*CQueueBlocks);
    FQueueRead[I]:=0; FQueueWrite[I]:=0; FQueueCount[I]:=0;
    FDescriptors[I].Data:=Self;
    FDescriptors[I].Handle:=Pointer(I);
    FDescriptors[I].Buf:=@FCallbackBuffers[I][0];
    Result:=FSetPropertyV(FChannels[I],PROP_HANDLER_DATA,@FDescriptors[I],-1);
    if Result<>0 then Exit;
    Result:=FSetPropertyV(FChannels[I],PROP_HANDLER,@Mx248ReadyCallback,-1);
    if Result<>0 then Exit;
  end;
  Result:=FSetPropertyL(FDevice,PROP_DEVICE_ASYNC,1,-1);
end;

destructor TDevApiBinding.Destroy;
begin
  Close;
  CloseHandle(FReadyEvent);
  DeleteCriticalSection(FQueueLock);
  FDeviceControl := nil;
  if FDevCtrlModule <> 0 then FreeLibrary(FDevCtrlModule);
  if FModule <> 0 then FreeLibrary(FModule);
  if FComInitialized then CoUninitialize;
  inherited;
end;

function TDevApiBinding.Load(const ADirectory: string): Boolean;
const Names: array[0..19] of PAnsiChar = ('SystemConfigChanged', 'SearchDevices',
  'GetAllDevices', 'GetAllSearchDevices', 'CreateDeviceH',
  'DeleteDevice', 'Reset', 'Test', 'Config', 'Programming', 'Start', 'Stop', 'Lock', 'Unlock',
  'ReadOutCache', 'WaitProgramming', 'WaitConfig', 'CreateTrigger',
  'DeleteTrigger', 'Trigger');
  ArgBytes: array[0..19] of Integer = (4,4,4,8,8,4,8,4,8,8,4,4,24,12,8,4,4,
    12,4,4);
var I: Integer; FileName, DevCtrlFileName: string;
  GetDeviceControlClassObject: function(out Obj): HRESULT; stdcall;
  function Resolve(const N: PAnsiChar; Bytes: Integer): Pointer;
  var Decorated: AnsiString;
  begin
    Result:=GetProcAddress(FModule,N);
    if Result=nil then begin Decorated:='_'+AnsiString(N)+'@'+AnsiString(IntToStr(Bytes)); Result:=GetProcAddress(FModule,PAnsiChar(Decorated)) end;
  end;
begin
  FMissing := '';
  { devctrl.dll and the MebiusDAQ implementation load sibling native modules
    dynamically. The bridge is intentionally isolated, so constraining its DLL
    lookup to the selected vendor suite is safe and keeps versions coherent. }
  SetDllDirectory(PChar(ExcludeTrailingPathDelimiter(ADirectory)));
  SetCurrentDirectory(PChar(ExcludeTrailingPathDelimiter(ADirectory)));
  FileName := IncludeTrailingPathDelimiter(ADirectory) + 'DevAPI.dll';
  DevApiDiagnosticLog('stage=load path=' + FileName);
  FModule := LoadLibrary(PChar(FileName));
  if FModule = 0 then begin
    FMissing := SysErrorMessage(GetLastError);
    DevApiDiagnosticLog('stage=load code=' + IntToStr(GetLastError) +
      ' text=' + FMissing);
    Exit(False)
  end;
  for I := Low(Names) to High(Names) do
    if Resolve(Names[I], ArgBytes[I]) = nil then begin
      if FMissing <> '' then FMissing := FMissing + ',';
      FMissing := FMissing + string(AnsiString(Names[I]));
    end;
  Result := FMissing = '';
  if Result then begin
    @FSystemConfigChanged:=Resolve('SystemConfigChanged',4);
    @FSearch:=Resolve('SearchDevices',4);
    @FGetAllDevices:=Resolve('GetAllDevices',4);
    @FGetAllSearchDevices:=Resolve('GetAllSearchDevices',8);
    @FCreate:=Resolve('CreateDeviceH',8);
    @FDelete:=Resolve('DeleteDevice',4); @FConfig:=Resolve('Config',8);
    @FReset:=Resolve('Reset',8); @FTest:=Resolve('Test',4);
    @FProgramming:=Resolve('Programming',8); @FStart:=Resolve('Start',4);
    @FStop:=Resolve('Stop',4);
    @FCreateTrigger:=Resolve('CreateTrigger',12);
    @FDeleteTrigger:=Resolve('DeleteTrigger',4);
    @FTrigger:=Resolve('Trigger',4);
    @FGetPropertyL:=Resolve('GetPropertyL',16);
    @FGetPropertyD:=Resolve('GetPropertyD',16);
    @FGetPropertyV:=Resolve('GetPropertyV',16);
    @FSetPropertyL:=Resolve('SetPropertyL',16);
    @FSetPropertyD:=Resolve('SetPropertyD',20);
    @FZBalance:=Resolve('ZBalance',12);
    @FCollectChanID:=Resolve('CollectChanID',12);
    @FGetChannel:=Resolve('GetChannel',4);
    @FAddChannel:=Resolve('AddChannel',4);
    @FSetPropertyV:=Resolve('SetPropertyV',16);
    @FLoadTransformer:=Resolve('LoadTransformerKoefChan',4);
    @FLock:=Resolve('Lock',24); @FUnlock:=Resolve('Unlock',12);
    Result:=Assigned(FGetPropertyL) and Assigned(FGetPropertyD) and
      Assigned(FGetPropertyV) and Assigned(FSetPropertyL) and
      Assigned(FSetPropertyD) and Assigned(FZBalance) and Assigned(FCollectChanID) and
      Assigned(FGetChannel) and Assigned(FAddChannel) and Assigned(FLock) and
      Assigned(FUnlock) and Assigned(FCreateTrigger) and
      Assigned(FDeleteTrigger) and Assigned(FTrigger) and Assigned(FSetPropertyV) and
      Assigned(FLoadTransformer);
    if not Result then FMissing:='channel/read/property/balance DevAPI exports';
  end;
  if Result then begin
    DevCtrlFileName := IncludeTrailingPathDelimiter(ADirectory) + 'devctrl.dll';
    FDevCtrlModule := LoadLibrary(PChar(DevCtrlFileName));
    if FDevCtrlModule <> 0 then begin
      @GetDeviceControlClassObject := GetProcAddress(FDevCtrlModule,
        'GetDeviceControlClassObject');
      if not Assigned(GetDeviceControlClassObject) then
        @GetDeviceControlClassObject := GetProcAddress(FDevCtrlModule,
          '_GetDeviceControlClassObject@4');
      if Assigned(GetDeviceControlClassObject) then begin
        I := GetDeviceControlClassObject(FDeviceControl);
        Result := Succeeded(I) and Assigned(FDeviceControl);
        if not Result then FMissing := 'devctrl.GetDeviceControlClassObject';
      end else begin
        Result := False;
        FMissing := 'devctrl.GetDeviceControlClassObject export';
      end;
    end else begin
      { Legacy-only vendor suites do not ship devctrl.dll. DevAPI remains the
        authoritative acquisition API; devctrl only augments discovery. }
      DevApiDiagnosticLog('stage=bind devctrl_unavailable text=' +
        SysErrorMessage(GetLastError));
    end;
  end;
  DevApiDiagnosticLog('stage=bind success=' + BoolToStr(Result, True) +
    ' missing=' + FMissing);
end;

function ParsePciLocation(const AText: string; out ABus, ASlot,
  AFunction: Cardinal): Boolean;
var
  lText: string;
  lBusPos, lDevicePos, lFunctionPos, lArgsStart, lArgsEnd: Integer;
  lArgs: TStringList;
  function ReadNumber(AStart: Integer; out AValue: Cardinal): Boolean;
  var
    lEnd: Integer;
    lNumber: string;
  begin
    while (AStart<=Length(lText)) and not CharInSet(lText[AStart],['0'..'9']) do
      Inc(AStart);
    lEnd:=AStart;
    while (lEnd<=Length(lText)) and CharInSet(lText[lEnd],['0'..'9']) do
      Inc(lEnd);
    lNumber:=Copy(lText,AStart,lEnd-AStart);
    Result:=(lNumber<>'') and TryStrToUInt(lNumber,AValue);
  end;
begin
  lText:=LowerCase(AText);
  lArgsStart:=LastDelimiter('(',lText);
  lArgsEnd:=LastDelimiter(')',lText);
  if (lArgsStart>0) and (lArgsEnd>lArgsStart) then begin
    lArgs:=TStringList.Create;
    try
      lArgs.StrictDelimiter:=True;
      lArgs.Delimiter:=',';
      lArgs.DelimitedText:=Copy(lText,lArgsStart+1,lArgsEnd-lArgsStart-1);
      if (lArgs.Count=3) and TryStrToUInt(Trim(lArgs[0]),ABus) and
         TryStrToUInt(Trim(lArgs[1]),ASlot) and
         TryStrToUInt(Trim(lArgs[2]),AFunction) then Exit(True);
    finally
      lArgs.Free;
    end;
  end;
  lBusPos:=Pos('bus',lText);
  lDevicePos:=Pos('device',lText);
  lFunctionPos:=Pos('function',lText);
  Result:=(lBusPos>0) and (lDevicePos>lBusPos) and
    (lFunctionPos>lDevicePos) and ReadNumber(lBusPos+3,ABus) and
    ReadNumber(lDevicePos+6,ASlot) and ReadNumber(lFunctionPos+8,AFunction);
end;

function CollectPnpMx248(const ATemplate: TDevice; var ADevices: TDeviceEnum;
  var AStoredCount: Integer): Integer;
const
  CPciEnumKey = 'SYSTEM\CurrentControlSet\Enum\PCI';
  CMx248HardwarePrefix = 'VEN_1945&DEV_6200&SUBSYS_614D';
var
  lRegistry: TRegistry;
  lHardwareKeys, lInstances: TStringList;
  lHardwareKey, lInstanceKey, lLocation, lName: string;
  lHardwareIndex, lInstanceIndex: Integer;
  lBus, lSlot, lFunction: Cardinal;
  lDevice: TDevice;
begin
  Result:=0;
  lRegistry:=TRegistry.Create(KEY_READ);
  lHardwareKeys:=TStringList.Create;
  lInstances:=TStringList.Create;
  try
    lRegistry.RootKey:=HKEY_LOCAL_MACHINE;
    if not lRegistry.OpenKeyReadOnly(CPciEnumKey) then Exit;
    lRegistry.GetKeyNames(lHardwareKeys);
    lRegistry.CloseKey;
    for lHardwareIndex:=0 to lHardwareKeys.Count-1 do begin
      lHardwareKey:=lHardwareKeys[lHardwareIndex];
      if Pos(CMx248HardwarePrefix,UpperCase(lHardwareKey))<>1 then Continue;
      lInstances.Clear;
      if not lRegistry.OpenKeyReadOnly(CPciEnumKey+'\'+lHardwareKey) then Continue;
      lRegistry.GetKeyNames(lInstances);
      lRegistry.CloseKey;
      for lInstanceIndex:=0 to lInstances.Count-1 do begin
        lInstanceKey:=CPciEnumKey+'\'+lHardwareKey+'\'+lInstances[lInstanceIndex];
        if not lRegistry.OpenKeyReadOnly(lInstanceKey) then Continue;
        try
          if not lRegistry.ValueExists('LocationInformation') then Continue;
          lLocation:=lRegistry.ReadString('LocationInformation');
          if lRegistry.ValueExists('FriendlyName') then
            lName:=lRegistry.ReadString('FriendlyName')
          else lName:='MX-248';
        finally
          lRegistry.CloseKey;
        end;
        if not ParsePciLocation(lLocation,lBus,lSlot,lFunction) then Continue;
        if AStoredCount>=Length(ADevices.Items) then Exit;
        lDevice:=ATemplate;
        lDevice.DeviceType:=$614D;
        lDevice.Route.BusType:=4; { PCI_BUS in DevAPI Types.h }
        FillChar(lDevice.Route.Location,SizeOf(lDevice.Route.Location),0);
        Move(lBus,lDevice.Route.Location.Data[0],SizeOf(lBus));
        Move(lSlot,lDevice.Route.Location.Data[4],SizeOf(lSlot));
        Move(lFunction,lDevice.Route.Location.Data[8],SizeOf(lFunction));
        lDevice.SerialNo:=$FFFF;
        lDevice.RevisionNo:=$FFFF;
        StrPLCopy(PAnsiChar(@lDevice.DeviceName[0]),AnsiString(lName),
          Length(lDevice.DeviceName)-1);
        ADevices.Items[AStoredCount]:=lDevice;
        Inc(AStoredCount);
        Inc(Result);
        DevApiDiagnosticLog(Format('stage=discover pnp device_type=0x614D '+
          'bus=%d slot=%d function=%d name=%s',
          [lBus,lSlot,lFunction,lName]));
      end;
    end;
  finally
    lInstances.Free;
    lHardwareKeys.Free;
    lRegistry.Free;
  end;
end;

function TDevApiBinding.Discover(out AText: string): Cardinal;
var I, J, StoredCount: Integer; CCType,CCSN,SlotNo: Word;
  Registered, Found: TDeviceEnum;
  DevCtrlFound: TDevCtrlDeviceEnum;
  SearchResult, RegisteredResult, FoundResult: Cardinal;
  DevCtrlResult: HRESULT;
  Mx248Template: TDevice;
  HasMx248Template: Boolean;
begin
  if not Assigned(FSearch) or not Assigned(FSystemConfigChanged) or
     not Assigned(FGetAllDevices) or not Assigned(FGetAllSearchDevices) then
    Exit(Cardinal(-1));
  AText:='';
  FillChar(FDevices,SizeOf(FDevices),0);
  FSystemConfigChanged(True);
  if Assigned(FDeviceControl) then begin
    FillChar(DevCtrlFound,SizeOf(DevCtrlFound),0);
    DevApiDiagnosticLog('stage=discover devctrl_system_config begin');
    DevCtrlResult:=FDeviceControl.SystemConfigChanged(True);
    DevApiDiagnosticLog(Format('stage=discover devctrl_system_config rc=0x%x',
      [Cardinal(DevCtrlResult)]));
    if Succeeded(DevCtrlResult) then
    begin
      DevApiDiagnosticLog('stage=discover devctrl_search begin');
      DevCtrlResult:=FDeviceControl.SearchDevices(@DevCtrlFound);
    end;
    DevApiDiagnosticLog(Format('stage=discover devctrl_rc=0x%x total=%d',
      [Cardinal(DevCtrlResult),DevCtrlFound.Count]));
    if Failed(DevCtrlResult) then Exit(Cardinal(DevCtrlResult));
    SearchResult:=0;
  end else
    SearchResult:=FSearch(FDevices);
  DevApiDiagnosticLog(Format('stage=discover search_rc=%u total=%d',
    [SearchResult, FDevices.Count]));
  if SearchResult<>0 then Exit(SearchResult);
  if (FDevices.Count<0) or (FDevices.Count>111) then Exit(Cardinal(-1));
  FillChar(Registered,SizeOf(Registered),0);
  RegisteredResult:=FGetAllDevices(Registered);
  DevApiDiagnosticLog(Format('stage=discover registered_rc=%u total=%d',
    [RegisteredResult, Registered.Count]));
  if RegisteredResult<>0 then Exit(RegisteredResult);
  if (Registered.Count<0) or (Registered.Count>111) then Exit(Cardinal(-1));
  StoredCount:=0;
  HasMx248Template:=False;
  FillChar(Mx248Template,SizeOf(Mx248Template),0);
  for I:=0 to Registered.Count-1 do begin
    DevApiDiagnosticLog(Format('stage=discover registered_item=%d device_type=0x%x name=%s dll=%s',
      [I, Registered.Items[I].DeviceType,
       string(AnsiString(Registered.Items[I].DeviceName)),
       string(AnsiString(Registered.Items[I].DllName))]));
    if Registered.Items[I].DeviceType<>$614D then Continue;
    Mx248Template:=Registered.Items[I];
    HasMx248Template:=True;
    FillChar(Found,SizeOf(Found),0);
    FoundResult:=FGetAllSearchDevices(Registered.Items[I].DeviceType,Found);
    DevApiDiagnosticLog(Format('stage=discover type=0x%x found_rc=%u total=%d',
      [Registered.Items[I].DeviceType,FoundResult,Found.Count]));
    if (FoundResult<>0) and (FoundResult<>Cardinal(-1)) then Continue;
    if (Found.Count<0) or (Found.Count>111) then Exit(Cardinal(-1));
    for J:=0 to Found.Count-1 do begin
      if StoredCount>=Length(FDevices.Items) then Exit(Cardinal(-1));
      FDevices.Items[StoredCount]:=Found.Items[J];
      Inc(StoredCount);
    end;
  end;
  if (StoredCount=0) and HasMx248Template then
    CollectPnpMx248(Mx248Template,FDevices,StoredCount);
  FDevices.Count:=StoredCount;
  DevApiDiagnosticLog(Format('stage=discover collected_total=%d',[StoredCount]));
  for I:=0 to FDevices.Count-1 do begin
    DevApiDiagnosticLog(Format('stage=discover item=%d device_type=0x%x ' +
      'object_type=0x%x bus_type=%d serial=%d revision=%d name=%s dll=%s',
      [I, FDevices.Items[I].DeviceType, FDevices.Items[I].DeviceObjectType,
       FDevices.Items[I].Route.BusType, FDevices.Items[I].SerialNo,
       FDevices.Items[I].RevisionNo,
       string(AnsiString(FDevices.Items[I].DeviceName)),
       string(AnsiString(FDevices.Items[I].DllName))]));
    if FDevices.Items[I].DeviceType<>$614D then Continue;
    CCType:=0; CCSN:=0; SlotNo:=0;
    if FDevices.Items[I].Route.BusType=1 then begin
      Move(FDevices.Items[I].Route.Location.Data[0],CCType,2);
      Move(FDevices.Items[I].Route.Location.Data[2],CCSN,2);
      Move(FDevices.Items[I].Route.Location.Data[4],SlotNo,2);
    end else if FDevices.Items[I].Route.BusType=4 then begin
      Move(FDevices.Items[I].Route.Location.Data[0],CCSN,2);
      Move(FDevices.Items[I].Route.Location.Data[4],SlotNo,2);
    end;
    if AText<>'' then AText:=AText+';';
    AText:=AText+Format('%d,%d,%d,%s,%d,%d,%d',[I,FDevices.Items[I].SerialNo,
      FDevices.Items[I].RevisionNo,string(AnsiString(FDevices.Items[I].DeviceName)),
      CCType,CCSN,SlotNo]);
  end;
  DevApiDiagnosticLog('stage=discover matched_text=' + AText);
  Result:=0;
end;
function TDevApiBinding.Open(AIndex: Integer): Cardinal;
var Ignore: string;
begin
  if not Assigned(FCreate) then Exit(Cardinal(-1));
  if FDevices.Count=0 then begin Result:=Discover(Ignore); if Result<>0 then Exit end;
  if (AIndex<0) or (AIndex>=FDevices.Count) or (FDevices.Items[AIndex].DeviceType<>$614D) then Exit(11);
  Close; FSelectedDevice:=FDevices.Items[AIndex];
  Result:=FCreate(FSelectedDevice,FDevice);
end;

function TDevApiBinding.OpenRoute(ACrateSerial, ASlot: Integer): Cardinal;
var I,Found: Integer; CCSN,SlotNo: Word; PciBus,PciSlot: Cardinal;
  Ignore: string;
begin
  if FDevices.Count=0 then begin Result:=Discover(Ignore); if Result<>0 then Exit end;
  Found:=-1;
  for I:=0 to FDevices.Count-1 do
    if FDevices.Items[I].DeviceType=$614D then begin
      CCSN:=0; SlotNo:=0; PciBus:=0; PciSlot:=0;
      if FDevices.Items[I].Route.BusType=1 then begin
        Move(FDevices.Items[I].Route.Location.Data[2],CCSN,2);
        Move(FDevices.Items[I].Route.Location.Data[4],SlotNo,2);
      end else if FDevices.Items[I].Route.BusType=4 then begin
        Move(FDevices.Items[I].Route.Location.Data[0],PciBus,4);
        Move(FDevices.Items[I].Route.Location.Data[4],PciSlot,4);
        CCSN:=Word(PciBus); SlotNo:=Word(PciSlot);
      end else Continue;
      if (CCSN=ACrateSerial) and (SlotNo=ASlot) then begin
        if Found<>-1 then Exit(87);
        Found:=I;
      end;
    end;
  if Found<0 then Exit(1168);
  Result:=Open(Found);
end;

function TDevApiBinding.Identity(out AText: string): Cardinal;
const PROP_REV=$1003; PROP_SN=$5000;
var SerialNumber, Revision: Integer; SerialResult, RevisionResult: Cardinal;
begin
  AText:=''; if FDevice=0 then Exit(Cardinal(-1));
  Result:=FReset(FDevice,0);
  DevApiDiagnosticLog(Format('stage=initialize reset_rc=%u',[Result]));
  if Result<>0 then Exit;
  SerialNumber:=FSelectedDevice.SerialNo;
  Revision:=FSelectedDevice.RevisionNo;
  SerialResult:=FGetPropertyL(FDevice,PROP_SN,@SerialNumber,-1);
  RevisionResult:=FGetPropertyL(FDevice,PROP_REV,@Revision,-1);
  DevApiDiagnosticLog(Format('stage=identity serial_rc=%u serial=%d '+
    'revision_rc=%u revision=%d',
    [SerialResult,SerialNumber,RevisionResult,Revision]));
  if SerialResult<>0 then Exit(SerialResult);
  if RevisionResult<>0 then Exit(RevisionResult);
  FSelectedDevice.SerialNo:=Word(SerialNumber);
  FSelectedDevice.RevisionNo:=Word(Revision);
  AText:=Format('serial=%d;version=%d',[SerialNumber,Revision]); Result:=0;
end;

function TDevApiBinding.TestDevice: Cardinal;
begin
  if FDevice=0 then Exit(Cardinal(-1));
  Result:=FTest(FDevice);
  DevApiDiagnosticLog(Format('stage=test rc=%u',[Result]));
end;

function TDevApiBinding.ReadProperties(out AText: string): Cardinal;
const
  CHAN_CNT_DEV=$1007; AIN_AVAILABLE=$0100 or $6000;
  PROP_FREQ=$300C; PROP_FREQ_COUNT=$300D;
  PROP_CHAN_ON=$3007; PROP_T_BLOCK=$3015; PROP_AMPLIFIER=$3105;
  PROP_INPUT_MODE=$1012; PROP_RANGE_INDEX=$3031; PROP_RANGE_MAX=$306A;
  PROP_RANGE_MIN=$306B; PROP_LPF=$306E; PROP_ICP=$308E;
  PROP_CALIBRATION=$3046; PROP_CHAN_FLOAT=$30FF;
  PROP_SENS_NOMINAL=$303A; PROP_SENS=$303B;
  PROP_RTSI_SEV=$1062; PROP_RTSI_CLK=$1063; PROP_RTSI_SYNC=$1064;
  PROP_TRIGGER=$100F; PROP_TRIG_SRC=$1010; PROP_TRIG_LEVEL=$1011;
var
  Count,I,FreqCount,SubHandle,L: Integer;
  IDs: array of Cardinal;
  Main,Amp: THandle;
  D: Double;
  Rates,Prefix: string;
  FS: TFormatSettings;
  function ReadL(H: THandle; Prop: Integer; out Value: Integer): Cardinal;
  begin
    Value:=0;
    if H=0 then Exit(Cardinal(-1));
    Result:=FGetPropertyL(H,Prop,@Value,-1);
    if Result<>0 then
      DevApiDiagnosticLog(Format('stage=read-properties type=long prop=0x%x rc=%u',
        [Prop,Result]))
  end;
  function ReadD(H: THandle; Prop,Index: Integer; out Value: Double): Cardinal;
  begin
    Value:=0;
    if H=0 then Exit(Cardinal(-1));
    Result:=FGetPropertyD(H,Prop,@Value,Index);
    if Result<>0 then
      DevApiDiagnosticLog(Format('stage=read-properties type=double prop=0x%x index=%d rc=%u',
        [Prop,Index,Result]))
  end;
  function Number(const Value: Double): string;
  begin
    Result:=FormatFloat('0.###############',Value,FS)
  end;
  procedure AddPair(var Target: string; const Key,Value: string);
  begin
    if Target<>'' then Target:=Target+';';
    Target:=Target+Key+'='+Value
  end;
begin
  AText:='';
  if FDevice=0 then Exit(Cardinal(-1));
  FS:=TFormatSettings.Create('en-US');

  { MX-248 exposes sampling properties on an AIN channel, not on the device.
    Resolve channels first, exactly as the original property pages do. }
  Count:=0;
  Result:=FGetPropertyL(FDevice,CHAN_CNT_DEV,@Count,AIN_AVAILABLE); if Result<>0 then Exit;
  if Count<>8 then Exit(87);
  SetLength(IDs,Count);
  Result:=FCollectChanID(FDevice,@IDs[0],AIN_AVAILABLE); if Result<>0 then Exit;
  Main:=FGetChannel(IDs[0]);
  if Main=0 then Main:=FAddChannel(IDs[0]);
  if Main=0 then Exit(Cardinal(-1));

  FreqCount:=0;
  Result:=ReadL(Main,PROP_FREQ_COUNT,FreqCount); if Result<>0 then Exit;
  if (FreqCount<1) or (FreqCount>1024) then Exit(87);
  { DevAPI overloads PROP_CHAN_FREQ: index -1 is the selected live rate,
    while non-negative indices enumerate the supported rate table. }
  Result:=ReadD(Main,PROP_FREQ,-1,D); if Result<>0 then Exit;
  AddPair(AText,'schema','mx248.live.v1');
  AddPair(AText,'sample-rate-hz',Number(D));
  Rates:='';
  for I:=0 to FreqCount-1 do begin
    Result:=ReadD(Main,PROP_FREQ,I,D); if Result<>0 then Exit;
    if Rates<>'' then Rates:=Rates+',';
    Rates:=Rates+Number(D)
  end;
  AddPair(AText,'supported-rates-hz',Rates);

  { Firmware revisions do not all publish every PXI/trigger property. Missing
    optional properties must not make the whole live settings dialog fail. }
  if ReadL(FDevice,PROP_RTSI_SEV,L)=0 then AddPair(AText,'rtsi-sev',IntToStr(L));
  if ReadL(FDevice,PROP_RTSI_CLK,L)=0 then AddPair(AText,'rtsi-clock',IntToStr(L));
  if ReadL(FDevice,PROP_RTSI_SYNC,L)=0 then AddPair(AText,'rtsi-sync',IntToStr(L));
  if ReadL(FDevice,PROP_TRIGGER,L)=0 then AddPair(AText,'trigger-mode',IntToStr(L));
  if ReadL(FDevice,PROP_TRIG_SRC,L)=0 then AddPair(AText,'trigger-source',IntToStr(L));
  D:=0;
  if ReadD(FDevice,PROP_TRIG_LEVEL,-1,D)=0 then
    AddPair(AText,'trigger-level',Number(D));

  for I:=0 to Count-1 do begin
    Main:=FGetChannel(IDs[I]);
    if Main=0 then Main:=FAddChannel(IDs[I]);
    if Main=0 then Exit(Cardinal(-1));
    Prefix:='ch'+IntToStr(I+1)+'.';
    if ReadL(Main,PROP_CHAN_ON,L)=0 then AddPair(AText,Prefix+'enabled',IntToStr(L));
    if ReadL(Main,PROP_T_BLOCK,L)=0 then AddPair(AText,Prefix+'block-samples',IntToStr(L));
    if ReadL(Main,PROP_ICP,L)=0 then AddPair(AText,Prefix+'icp-current',IntToStr(L));
    SubHandle:=0;
    Result:=FGetPropertyV(Main,PROP_AMPLIFIER,@SubHandle,-1);
    if Result<>0 then begin
      DevApiDiagnosticLog(Format('stage=read-properties type=handle prop=0x%x rc=%u',
        [PROP_AMPLIFIER,Result]));
      Continue
    end;
    Amp:=THandle(SubHandle); if Amp=0 then Continue;
    if ReadL(Amp,PROP_CHAN_ON,L)=0 then AddPair(AText,Prefix+'amplifier-enabled',IntToStr(L));
    if ReadL(Amp,PROP_INPUT_MODE,L)=0 then AddPair(AText,Prefix+'input-mode',IntToStr(L));
    if ReadL(Amp,PROP_RANGE_INDEX,L)=0 then AddPair(AText,Prefix+'range-index',IntToStr(L));
    if ReadD(Amp,PROP_RANGE_MIN,-1,D)=0 then AddPair(AText,Prefix+'range-min',Number(D));
    if ReadD(Amp,PROP_RANGE_MAX,-1,D)=0 then AddPair(AText,Prefix+'range-max',Number(D));
    if ReadL(Amp,PROP_LPF,L)=0 then AddPair(AText,Prefix+'lpf-index',IntToStr(L));
    if ReadL(Amp,PROP_CALIBRATION,L)=0 then AddPair(AText,Prefix+'calibration-mode',IntToStr(L));
    if ReadL(Amp,PROP_CHAN_FLOAT,L)=0 then AddPair(AText,Prefix+'input-floating',IntToStr(L));
    if ReadD(Amp,PROP_SENS_NOMINAL,-1,D)=0 then AddPair(AText,Prefix+'sensitivity-nominal',Number(D));
    if ReadD(Amp,PROP_SENS,-1,D)=0 then AddPair(AText,Prefix+'sensitivity',Number(D))
  end;
  DevApiDiagnosticLog('stage=read-properties success=1 bytes='+IntToStr(Length(AText)));
  Result:=0
end;

function TDevApiBinding.ConfigurePxi(const AConfig: TMx248PxiConfigV1): Cardinal;
const
  PROP_RTSI_SEV=$1062; PROP_RTSI_CLK=$1063; PROP_RTSI_SYNC=$1064;
  PROP_TRIGGER=$100F; PROP_TRIG_SRC=$1010; PROP_TRIG_LEVEL=$1011;
  function SetDeviceProperty(Prop,Value: Integer): Cardinal;
  begin
    Result:=FSetPropertyL(FDevice,Prop,Value,-1)
  end;
begin
  if (FDevice=0) or not Assigned(FConfig) then Exit(Cardinal(-1));
  Result:=SetDeviceProperty(PROP_RTSI_SEV,AConfig.RtsiSev); if Result<>0 then Exit;
  Result:=SetDeviceProperty(PROP_RTSI_CLK,AConfig.RtsiClock); if Result<>0 then Exit;
  Result:=SetDeviceProperty(PROP_RTSI_SYNC,AConfig.RtsiSync); if Result<>0 then Exit;
  Result:=SetDeviceProperty(PROP_TRIGGER,AConfig.TriggerMode); if Result<>0 then Exit;
  Result:=SetDeviceProperty(PROP_TRIG_SRC,AConfig.TriggerSource); if Result<>0 then Exit;
  Result:=FSetPropertyD(FDevice,PROP_TRIG_LEVEL,AConfig.TriggerLevel,-1);
  if Result<>0 then Exit;
  Result:=FConfig(FDevice,0);
  if Result=27 then Result:=0;
  if Result=0 then begin
    Result:=FProgramming(FDevice,0);
    if Result=27 then Result:=0
  end;
  if Result=0 then Result:=PulseTrigger;
  DevApiDiagnosticLog(Format('stage=configure-pxi rc=%u sev=%d clock=%d sync=%d trigger=%d source=%d level=%d',
    [Result,AConfig.RtsiSev,AConfig.RtsiClock,AConfig.RtsiSync,
    AConfig.TriggerMode,AConfig.TriggerSource,AConfig.TriggerLevel]))
end;

function TDevApiBinding.ZeroBalance(AChannelMask: Cardinal;
  out AText: string): Cardinal;
const
  CHAN_CNT_DEV=$1007; AIN_AVAILABLE=$0100 or $6000;
var
  Count,I: Integer;
  IDs: array of Cardinal;
  Channel: THandle;
  Value: Double;
  FS: TFormatSettings;
begin
  AText:='';
  if (FDevice=0) or not Assigned(FZBalance) then Exit(Cardinal(-1));
  FS:=TFormatSettings.Create('en-US');
  Count:=0;
  Result:=FGetPropertyL(FDevice,CHAN_CNT_DEV,@Count,AIN_AVAILABLE); if Result<>0 then Exit;
  if Count<>8 then Exit(87);
  SetLength(IDs,Count);
  Result:=FCollectChanID(FDevice,@IDs[0],AIN_AVAILABLE); if Result<>0 then Exit;
  for I:=0 to Count-1 do
    if (AChannelMask and (Cardinal(1) shl I))<>0 then begin
      Channel:=FGetChannel(IDs[I]);
      if Channel=0 then Channel:=FAddChannel(IDs[I]);
      if Channel=0 then Exit(Cardinal(-1));
      Value:=0;
      Result:=FZBalance(FDevice,Channel,@Value); if Result<>0 then Exit;
      if AText<>'' then AText:=AText+';';
      AText:=AText+'ch'+IntToStr(I+1)+'='+
        FormatFloat('0.###############',Value,FS)
    end;
  DevApiDiagnosticLog('stage=zero-balance mask='+IntToHex(AChannelMask,2)+
    ' values='+AText);
  Result:=0
end;

function TDevApiBinding.Configure(const AConfig: TMx248ConfigureV1): Cardinal;
const
  CHAN_CNT_DEV=$1007; AIN_AVAILABLE=$0100 or $6000;
  PROP_FREQ_COUNT=$300D; PROP_FREQ=$300C; PROP_T_BLOCK=$3015;
  PROP_CHAN_TYPE_SIGNAL=$102A; TYPE_SIGNAL_ELECTR=1;
  PROP_DEVICE_ASYNC=$3009;
  PROP_CHAN_ON=$3007; PROP_AMPLIFIER=$3105; PROP_INPUT_MODE=$1012;
  PROP_RANGE_INDEX=$3031; PROP_LPF=$306E; PROP_ICP=$308E;
  PROP_CALIBRATION=$3046; PROP_CHAN_FLOAT=$30FF;
var Count,I,FreqCount,FreqIndex,SubHandle: Integer; IDs: array of Cardinal;
  Main, Amp: THandle; Freq, Delta, BestDelta: Double;
  function SetL(H: THandle; Prop, Value: Integer): Cardinal;
  begin
    if H=0 then Exit(Cardinal(-1));
    Result:=FSetPropertyL(H,Prop,Value,-1);
    if Result<>0 then DevApiDiagnosticLog(Format(
      'stage=configure type=long prop=0x%x value=%d rc=%u',[Prop,Value,Result]))
  end;
begin
  if (FDevice=0) or not Assigned(FConfig) then Exit(Cardinal(-1));
  { Keep callbacks disabled until all descriptor buffers have been prepared.
    The default vendor consumer dereferences HandlerData->buf once the FIFO
    contains a full block (mx224v14.cpp: OnInterruptScan). }
  Result:=FSetPropertyL(FDevice,PROP_DEVICE_ASYNC,0,-1);
  if Result<>0 then Exit;
  Count:=0; Result:=FGetPropertyL(FDevice,CHAN_CNT_DEV,@Count,AIN_AVAILABLE);
  if Result<>0 then Exit; if Count<>8 then Exit(87);
  SetLength(IDs,Count); Result:=FCollectChanID(FDevice,@IDs[0],AIN_AVAILABLE); if Result<>0 then Exit;
  Main:=FGetChannel(IDs[0]);
  if Main=0 then Main:=FAddChannel(IDs[0]);
  if Main=0 then Exit(Cardinal(-1));
  FreqCount:=0; Result:=FGetPropertyL(Main,PROP_FREQ_COUNT,@FreqCount,-1);
  if Result<>0 then Exit; if (FreqCount<1) or (FreqCount>1024) then Exit(Cardinal(-1));
  FreqIndex:=-1; BestDelta:=MaxDouble;
  for I:=0 to FreqCount-1 do begin
    Freq:=0; Result:=FGetPropertyD(Main,PROP_FREQ,@Freq,I); if Result<>0 then Exit;
    Delta:=Abs(Freq-AConfig.SampleRateHz);
    if Delta<BestDelta then begin BestDelta:=Delta; FreqIndex:=I end;
  end;
  if (FreqIndex<0) or (BestDelta>Max(1E-6,Abs(AConfig.SampleRateHz)*1E-9)) then Exit(87);
  Result:=FSetPropertyD(Main,PROP_FREQ,AConfig.SampleRateHz,-1);
  if Result<>0 then begin
    DevApiDiagnosticLog(Format('stage=configure type=double prop=0x%x value=%s rc=%u',
      [PROP_FREQ,FloatToStr(AConfig.SampleRateHz),Result]));
    Exit
  end;

  for I:=0 to Count-1 do begin
    Main:=FGetChannel(IDs[I]);
    if Main=0 then Main:=FAddChannel(IDs[I]);
    if Main=0 then Exit(Cardinal(-1));
    { Recorder's measurement-tag binding explicitly switches AIN channels from
      their DevAPI reset state (codes) to electrical values before Programming.
      Without this step the four-byte payload looks like Float32 by metadata,
      but contains code-domain data and is decoded as denormal garbage. }
    Result:=SetL(Main,PROP_CHAN_TYPE_SIGNAL,TYPE_SIGNAL_ELECTR); if Result<>0 then Exit;
    { Available MX-248 ADC channels reject PROP_CHAN_ON; AddChannel itself
      selects them for acquisition. }
    Result:=SetL(Main,PROP_T_BLOCK,AConfig.BlockSamples); if Result<>0 then Exit;
    Result:=SetL(Main,PROP_ICP,AConfig.Channels[I].IcpCurrent); if Result<>0 then Exit;
    SubHandle:=0; Result:=FGetPropertyV(Main,PROP_AMPLIFIER,@SubHandle,-1); if Result<>0 then Exit;
    Amp:=THandle(SubHandle); if Amp=0 then Exit(Cardinal(-1));
    Result:=SetL(Amp,PROP_CHAN_ON,AConfig.Channels[I].AmplifierEnabled); if Result<>0 then Exit;
    Result:=SetL(Amp,PROP_INPUT_MODE,AConfig.Channels[I].InputMode); if Result<>0 then Exit;
    Result:=SetL(Amp,PROP_RANGE_INDEX,AConfig.Channels[I].RangeIndex); if Result<>0 then Exit;
    Result:=SetL(Amp,PROP_LPF,AConfig.Channels[I].LpfIndex); if Result<>0 then Exit;
    if AConfig.Channels[I].CalibrationEnabled<>0 then
      Result:=SetL(Amp,PROP_CALIBRATION,AConfig.CalibrationMode+1)
    else Result:=SetL(Amp,PROP_CALIBRATION,0);
    if Result<>0 then Exit;
    Result:=SetL(Amp,PROP_CHAN_FLOAT,AConfig.Channels[I].InputFloating); if Result<>0 then Exit;
    Result:=FLoadTransformer(Main);
    DevApiDiagnosticLog(Format('stage=load-transformer channel=%d rc=%u',[I+1,Result]));
    if Result<>0 then Exit;
  end;
  Result:=FConfig(FDevice,0);
  if Result=27 then Result:=0;
  if Result=0 then begin
    Result:=FProgramming(FDevice,0);
    if Result=27 then Result:=0
  end;
  if Result=0 then Result:=BindChannels;
  if Result=0 then Result:=PrepareCallbackBuffers(AConfig.BlockSamples)
end;

function TDevApiBinding.PulseTrigger: Cardinal;
var TriggerHandle, DeviceHandle: THandle;
begin
  if (FDevice=0) or not Assigned(FCreateTrigger) or
    not Assigned(FTrigger) or not Assigned(FDeleteTrigger) then
    Exit(Cardinal(-1));
  TriggerHandle:=0;
  DeviceHandle:=FDevice;
  Result:=FCreateTrigger(TriggerHandle,@DeviceHandle,1);
  if Result<>0 then Exit;
  try
    Result:=FTrigger(TriggerHandle)
  finally
    FDeleteTrigger(TriggerHandle)
  end
end;
function TDevApiBinding.Start: Cardinal;
var TriggerHandle, DeviceHandle: THandle; AsyncMode: Longint; I: Integer;
  HandlerPtr, DataPtr: Pointer;
begin
  if (FDevice=0) or not Assigned(FStart) or not Assigned(FCreateTrigger) or
    not Assigned(FTrigger) or not Assigned(FDeleteTrigger) then
    Exit(Cardinal(-1));
  TriggerHandle:=0;
  DeviceHandle:=FDevice;
  EnterCriticalSection(FQueueLock);
  try
    for I:=0 to 7 do begin
      FQueueRead[I]:=0; FQueueWrite[I]:=0; FQueueCount[I]:=0;
    end;
    FQueueOverflow:=False;
    FBlocksRead:=0;
    ResetEvent(FReadyEvent);
  finally LeaveCriticalSection(FQueueLock) end;
  { StopScanMain clears PROGRAMMED. OnProgramming configures TRIG_TASK_SYNC
    again (mx224v14.cpp:1010), so restart needs its configuration pulse BEFORE
    the separate Start pulse. Otherwise the sole pulse is consumed by SYNC. }
  if FStreamNeedsProgramming then
  begin
    Result:=FProgramming(FDevice,0);
    if Result=27 then Result:=0
    else if Result=0 then Result:=PulseTrigger;
    DevApiDiagnosticLog(Format('stage=start stream-programming rc=%u',[Result]));
    if Result<>0 then Exit;
    FStreamNeedsProgramming:=False;
  end;
  AsyncMode:=0;
  FGetPropertyL(FDevice,$3009,@AsyncMode,-1);
  DevApiDiagnosticLog(Format('stage=start async=%d',[AsyncMode]));
  HandlerPtr:=nil; DataPtr:=nil;
  FGetPropertyV(FChannels[0],$3017,@HandlerPtr,-1);
  FGetPropertyV(FChannels[0],$3018,@DataPtr,-1);
  DevApiDiagnosticLog(Format('stage=start handler=%p expected=%p data=%p',
    [HandlerPtr,@Mx248ReadyCallback,DataPtr]));
  Result:=FCreateTrigger(TriggerHandle,@DeviceHandle,1);
  if Result<>0 then Exit;
  try
    Result:=FStart(FDevice);
    if Result=0 then Result:=FTrigger(TriggerHandle)
  finally
    FDeleteTrigger(TriggerHandle)
  end
end;
function TDevApiBinding.Stop: Cardinal;
begin
  if FDevice=0 then Exit(0);
  Result:=FStop(FDevice);
  DevApiDiagnosticLog(Format('stage=stop rc=%u blocks=%d',[Result,FBlocksRead]));
  if Result=0 then FStreamNeedsProgramming:=True;
end;
procedure TDevApiBinding.Close; begin if FDevice<>0 then begin FStop(FDevice); FDelete(FDevice); FDevice:=0 end; FillChar(FSelectedDevice,SizeOf(FSelectedDevice),0); SetLength(FChannels,0);SetLength(FChannelIds,0);SetLength(FWordLengths,0);SetLength(FLogicalChannels,0) end;

function TDevApiBinding.BindChannels: Cardinal;
const CHAN_CNT_DEV=$1007; AIN_ALL=$0100 or $6000; PROP_WORD_LENGTH=$3006;
var Count,I,W,DataType: Integer;
begin
  SetLength(FChannels,0); SetLength(FChannelIds,0); SetLength(FWordLengths,0);
  SetLength(FLogicalChannels,0);
  if not Assigned(FGetPropertyL) or not Assigned(FCollectChanID) or
     not Assigned(FGetChannel) or not Assigned(FAddChannel) then Exit(Cardinal(-1));
  Count:=0; Result:=FGetPropertyL(FDevice,CHAN_CNT_DEV,@Count,AIN_ALL);
  if Result<>0 then Exit; if Count<>8 then Exit(Cardinal(-1));
  SetLength(FChannelIds,Count); Result:=FCollectChanID(FDevice,@FChannelIds[0],AIN_ALL);
  if Result<>0 then Exit;
  SetLength(FChannels,Count); SetLength(FWordLengths,Count); SetLength(FLogicalChannels,Count);
  for I:=0 to Count-1 do begin
    FChannels[I]:=FGetChannel(FChannelIds[I]);
    if FChannels[I]=0 then FChannels[I]:=FAddChannel(FChannelIds[I]);
    if FChannels[I]=0 then Exit(Cardinal(-1));
    W:=0; Result:=FGetPropertyL(FChannels[I],PROP_WORD_LENGTH,@W,-1);
    if Result<>0 then Exit; if W<>4 then Exit(Cardinal(-1));
    DataType:=0; Result:=FGetPropertyL(FChannels[I],$3004,@DataType,-1);
    if Result<>0 then Exit; if DataType<>4 then Exit(Cardinal(-1)); { VT_R4 }
    FWordLengths[I]:=W;
    FLogicalChannels[I]:=I+1;
  end;
  Result:=0;
end;

function TDevApiBinding.ReadBlock(ASamples: Integer; var AData: TBytes;
  out ADataSize: Integer): Cardinal;
var I,Offset,Bytes: Integer; Header, ReadyIndex: Cardinal;
begin
  ADataSize:=0; if (ASamples<1) or (ASamples>MX248_MAX_BLOCK_SAMPLES) or
    (Length(FChannels)=0) or not Assigned(FLock) or not Assigned(FUnlock) then Exit(Cardinal(-1));
  Bytes:=4;
  for I:=0 to High(FChannels) do begin
    if FWordLengths[I]>0 then Inc(Bytes,12+ASamples*FWordLengths[I]);
    if Bytes>1024*1024 then Exit(Cardinal(-1));
  end;
  if Length(AData)<Bytes then SetLength(AData,Bytes);
  { OnInterruptScan performs CheckBuffer before invoking the callback.
    Thus only complete hardware blocks enter the queue. Lock itself cannot
    establish readiness: its reported size ignores a partial FIFO copy. }
  { STA must dispatch COM calls while waiting for its vendor callback thread.
    Leave response headroom inside the runtime's 1000 ms IPC deadline. }
  if CoWaitForMultipleHandles(COWAIT_DISPATCH_CALLS or
    COWAIT_DISPATCH_WINDOW_MESSAGES,750,1,@FReadyEvent,ReadyIndex)<>S_OK then
      Exit(CBufferWaitTimeout);
  EnterCriticalSection(FQueueLock);
  try
  if FQueueOverflow then Exit(CBufferOverflow);
  if not AllChannelsReady then Exit(CBufferWaitTimeout);
  if ASamples*4<>FBlockBytes then Exit(87);
  Offset:=0; Header:=Length(FChannels);
  Move(Header,AData[Offset],4); Inc(Offset,4);
  for I:=0 to High(FChannels) do begin
      Header:=FLogicalChannels[I];Move(Header,AData[Offset],4);Inc(Offset,4);
      Header:=4;Move(Header,AData[Offset],4);Inc(Offset,4); { VT_R4 }
      Header:=ASamples;Move(Header,AData[Offset],4);Inc(Offset,4);
      Move(FQueuedBuffers[I][FQueueRead[I]*FBlockBytes],AData[Offset],FBlockBytes);
      Inc(Offset,FBlockBytes);
      FQueueRead[I]:=(FQueueRead[I]+1) mod CQueueBlocks;
      Dec(FQueueCount[I]);
  end;
  if not AllChannelsReady then ResetEvent(FReadyEvent);
  ADataSize:=Offset; Result:=0;
  Inc(FBlocksRead);
  if (FBlocksRead<=3) or (FBlocksRead mod 100=0) then
    DevApiDiagnosticLog(Format('stage=read blocks=%d samples=%d',
      [FBlocksRead,ASamples]));
  finally LeaveCriticalSection(FQueueLock) end;
end;

initialization
  Assert(SizeOf(TLocation)=140); Assert(SizeOf(TDeviceRoute)=144);
  Assert(SizeOf(TDevice)=1196); Assert(SizeOf(TDeviceEnum)=132760);
  Assert(SizeOf(TDevCtrlDevice)=432);
  Assert(SizeOf(TDevCtrlDeviceEnum)=47956);

end.
