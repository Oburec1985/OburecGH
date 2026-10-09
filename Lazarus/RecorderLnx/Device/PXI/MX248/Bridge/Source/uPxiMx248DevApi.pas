unit uPxiMx248DevApi;

interface

uses Winapi.Windows, System.SysUtils, System.Math, System.Classes,
  System.Win.Registry, uPxiMx248BridgeProtocol;

type
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
    FGetPropertyL: function(H: THandle; Prop: Integer; Value: PLongint; Index: Integer): Cardinal; stdcall;
    FGetPropertyD: function(H: THandle; Prop: Integer; Value: PDouble; Index: Integer): Cardinal; stdcall;
    FSetPropertyL: function(H: THandle; Prop, Value, Index: Integer): Cardinal; stdcall;
    FCollectChanID: function(H: THandle; IDs: PCardinal; ChanType: Integer): Cardinal; stdcall;
    FGetChannel: function(ID: Cardinal): THandle; stdcall;
    FLock: function(H: THandle; RequestSize: Integer; out P0: Pointer;
      out S0: Integer; out P1: Pointer; out S1: Integer): Cardinal; stdcall;
    FUnlock: function(H: THandle; S0, S1: Integer): Cardinal; stdcall;
    FChannelIds: array of Cardinal;
    FChannels: array of THandle;
    FWordLengths: array of Integer;
    FLogicalChannels: array of Integer;
    function BindChannels: Cardinal;
  public
    destructor Destroy; override;
    function Load(const ADirectory: string): Boolean;
    function Discover(out AText: string): Cardinal;
    function Open(AIndex: Integer): Cardinal;
    function OpenRoute(ACrateSerial, ASlot: Integer): Cardinal;
    function Identity(out AText: string): Cardinal;
    function TestDevice: Cardinal;
    function Configure(const AConfig: TMx248ConfigureV1): Cardinal;
    function Start: Cardinal;
    function Stop: Cardinal;
    function ReadBlock(ASamples: Integer; out AData: TBytes): Cardinal;
    procedure Close;
    property Missing: string read FMissing;
  end;

implementation

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

destructor TDevApiBinding.Destroy;
begin
  Close;
  FDeviceControl := nil;
  if FDevCtrlModule <> 0 then FreeLibrary(FDevCtrlModule);
  if FModule <> 0 then FreeLibrary(FModule);
  inherited;
end;

function TDevApiBinding.Load(const ADirectory: string): Boolean;
const Names: array[0..16] of PAnsiChar = ('SystemConfigChanged', 'SearchDevices',
  'GetAllDevices', 'GetAllSearchDevices', 'CreateDeviceH',
  'DeleteDevice', 'Reset', 'Test', 'Config', 'Programming', 'Start', 'Stop', 'Lock', 'Unlock',
  'ReadOutCache', 'WaitProgramming', 'WaitConfig');
  ArgBytes: array[0..16] of Integer = (4,4,4,8,8,4,8,4,8,8,4,4,24,12,8,4,4);
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
    @FGetPropertyL:=Resolve('GetPropertyL',16);
    @FGetPropertyD:=Resolve('GetPropertyD',16);
    @FSetPropertyL:=Resolve('SetPropertyL',16);
    @FCollectChanID:=Resolve('CollectChanID',12);
    @FGetChannel:=Resolve('GetChannel',4);
    @FLock:=Resolve('Lock',24); @FUnlock:=Resolve('Unlock',12);
    Result:=Assigned(FGetPropertyL) and Assigned(FGetPropertyD) and
      Assigned(FSetPropertyL) and Assigned(FCollectChanID) and
      Assigned(FGetChannel) and Assigned(FLock) and Assigned(FUnlock);
    if not Result then FMissing:='channel/read DevAPI exports';
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
function TDevApiBinding.Configure(const AConfig: TMx248ConfigureV1): Cardinal;
const
  CHAN_CNT_DEV=$1007; AIN_AVAILABLE=$0100 or $8000;
  PROP_FREQ_COUNT=$300D; PROP_FREQ=$300C; PROP_T_BLOCK=$3015;
  PROP_CHAN_ON=$3007; PROP_AMPLIFIER=$5058; PROP_INPUT_MODE=$1012;
  PROP_RANGE_INDEX=$3031; PROP_LPF=$306E; PROP_ICP=$308E;
  PROP_CALIBRATION=$3046; PROP_CHAN_FLOAT=$30FF;
var Count,I,FreqCount,FreqIndex,SubHandle: Integer; IDs: array of Cardinal;
  Main, Amp: THandle; Freq, Delta, BestDelta: Double;
  function SetL(H: THandle; Prop, Value: Integer): Cardinal;
  begin if H=0 then Exit(Cardinal(-1)); Result:=FSetPropertyL(H,Prop,Value,-1) end;
begin
  if (FDevice=0) or not Assigned(FConfig) then Exit(Cardinal(-1));
  FreqCount:=0; Result:=FGetPropertyL(FDevice,PROP_FREQ_COUNT,@FreqCount,-1);
  if Result<>0 then Exit; if (FreqCount<1) or (FreqCount>1024) then Exit(Cardinal(-1));
  FreqIndex:=-1; BestDelta:=MaxDouble;
  for I:=0 to FreqCount-1 do begin
    Freq:=0; Result:=FGetPropertyD(FDevice,PROP_FREQ,@Freq,I); if Result<>0 then Exit;
    Delta:=Abs(Freq-AConfig.SampleRateHz);
    if Delta<BestDelta then begin BestDelta:=Delta; FreqIndex:=I end;
  end;
  if (FreqIndex<0) or (BestDelta>Max(1E-6,Abs(AConfig.SampleRateHz)*1E-9)) then Exit(87);
  Result:=FSetPropertyL(FDevice,PROP_FREQ,FreqIndex,-1); if Result<>0 then Exit;

  Count:=0; Result:=FGetPropertyL(FDevice,CHAN_CNT_DEV,@Count,AIN_AVAILABLE);
  if Result<>0 then Exit; if Count<>8 then Exit(87);
  SetLength(IDs,Count); Result:=FCollectChanID(FDevice,@IDs[0],AIN_AVAILABLE); if Result<>0 then Exit;
  for I:=0 to Count-1 do begin
    Main:=FGetChannel(IDs[I]); if Main=0 then Exit(Cardinal(-1));
    Result:=SetL(Main,PROP_CHAN_ON,AConfig.Channels[I].Enabled); if Result<>0 then Exit;
    Result:=SetL(Main,PROP_T_BLOCK,AConfig.BlockSamples); if Result<>0 then Exit;
    Result:=SetL(Main,PROP_ICP,AConfig.Channels[I].IcpCurrent); if Result<>0 then Exit;
    SubHandle:=0; Result:=FGetPropertyL(Main,PROP_AMPLIFIER,@SubHandle,-1); if Result<>0 then Exit;
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
  end;
  Result:=FConfig(FDevice,0); if Result=0 then Result:=FProgramming(FDevice,0);
  if Result=0 then Result:=BindChannels
end;
function TDevApiBinding.Start: Cardinal; begin if (FDevice=0) or not Assigned(FStart) then Exit(Cardinal(-1)); Result:=FStart(FDevice) end;
function TDevApiBinding.Stop: Cardinal; begin if FDevice=0 then Exit(0); Result:=FStop(FDevice) end;
procedure TDevApiBinding.Close; begin if FDevice<>0 then begin FStop(FDevice); FDelete(FDevice); FDevice:=0 end; FillChar(FSelectedDevice,SizeOf(FSelectedDevice),0); SetLength(FChannels,0);SetLength(FChannelIds,0);SetLength(FWordLengths,0);SetLength(FLogicalChannels,0) end;

function TDevApiBinding.BindChannels: Cardinal;
const CHAN_CNT_DEV=$1007; AIN_USED=$0100 or $4000; PROP_WORD_LENGTH=$3006;
var Count,AvailableCount,I,J,W,DataType: Integer; AvailableIds: array of Cardinal;
begin
  SetLength(FChannels,0); SetLength(FChannelIds,0); SetLength(FWordLengths,0);
  SetLength(FLogicalChannels,0);
  if not Assigned(FGetPropertyL) or not Assigned(FCollectChanID) or not Assigned(FGetChannel) then Exit(Cardinal(-1));
  Count:=0; Result:=FGetPropertyL(FDevice,CHAN_CNT_DEV,@Count,AIN_USED);
  if Result<>0 then Exit; if (Count<1) or (Count>64) then Exit(Cardinal(-1));
  SetLength(FChannelIds,Count); Result:=FCollectChanID(FDevice,@FChannelIds[0],AIN_USED);
  if Result<>0 then Exit;
  AvailableCount:=0; Result:=FGetPropertyL(FDevice,CHAN_CNT_DEV,@AvailableCount,$0100 or $8000);
  if Result<>0 then Exit; if AvailableCount<>8 then Exit(Cardinal(-1));
  SetLength(AvailableIds,AvailableCount);
  Result:=FCollectChanID(FDevice,@AvailableIds[0],$0100 or $8000); if Result<>0 then Exit;
  SetLength(FChannels,Count); SetLength(FWordLengths,Count); SetLength(FLogicalChannels,Count);
  for I:=0 to Count-1 do begin
    FChannels[I]:=FGetChannel(FChannelIds[I]); if FChannels[I]=0 then Exit(Cardinal(-1));
    W:=0; Result:=FGetPropertyL(FChannels[I],PROP_WORD_LENGTH,@W,-1);
    if Result<>0 then Exit; if W<>4 then Exit(Cardinal(-1));
    DataType:=0; Result:=FGetPropertyL(FChannels[I],$3004,@DataType,-1);
    if Result<>0 then Exit; if DataType<>4 then Exit(Cardinal(-1)); { VT_R4 }
    FWordLengths[I]:=W;
    FLogicalChannels[I]:=0;
    for J:=0 to AvailableCount-1 do if AvailableIds[J]=FChannelIds[I] then begin
      FLogicalChannels[I]:=J+1; Break
    end;
    if FLogicalChannels[I]=0 then Exit(Cardinal(-1));
  end;
end;

function TDevApiBinding.ReadBlock(ASamples: Integer; out AData: TBytes): Cardinal;
var I,Offset,Bytes,S0,S1: Integer; P0,P1: Pointer; Header: Cardinal;
begin
  SetLength(AData,0); if (ASamples<1) or (ASamples>262144) or
    (Length(FChannels)=0) or not Assigned(FLock) or not Assigned(FUnlock) then Exit(Cardinal(-1));
  Bytes:=4;
  for I:=0 to High(FChannels) do begin
    if FWordLengths[I]>0 then Inc(Bytes,12+ASamples*FWordLengths[I]);
    if Bytes>1024*1024 then Exit(Cardinal(-1));
  end;
  SetLength(AData,Bytes); Offset:=0; Header:=Length(FChannels);
  Move(Header,AData[Offset],4); Inc(Offset,4);
  for I:=0 to High(FChannels) do begin
    P0:=nil;P1:=nil;S0:=0;S1:=0; Result:=FLock(FChannels[I],ASamples,P0,S0,P1,S1);
    if Result<>0 then begin SetLength(AData,0); Exit end;
    try
      if (S0<0) or (S1<0) or (S0+S1>ASamples) then begin Result:=Cardinal(-1);SetLength(AData,0);Exit end;
      Header:=FLogicalChannels[I];Move(Header,AData[Offset],4);Inc(Offset,4);
      Header:=4;Move(Header,AData[Offset],4);Inc(Offset,4); { VT_R4 }
      Header:=S0+S1;Move(Header,AData[Offset],4);Inc(Offset,4);
      if S0>0 then begin CopyMemory(@AData[Offset],P0,S0*FWordLengths[I]);Inc(Offset,S0*FWordLengths[I]) end;
      if S1>0 then begin CopyMemory(@AData[Offset],P1,S1*FWordLengths[I]);Inc(Offset,S1*FWordLengths[I]) end;
    finally FUnlock(FChannels[I],S0,S1) end;
  end;
  SetLength(AData,Offset); Result:=0;
end;

initialization
  Assert(SizeOf(TLocation)=140); Assert(SizeOf(TDeviceRoute)=144);
  Assert(SizeOf(TDevice)=1196); Assert(SizeOf(TDeviceEnum)=132760);
  Assert(SizeOf(TDevCtrlDevice)=432);
  Assert(SizeOf(TDevCtrlDeviceEnum)=47956);

end.
