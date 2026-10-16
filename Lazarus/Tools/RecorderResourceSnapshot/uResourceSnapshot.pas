unit uResourceSnapshot;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

type
  TProcessChoice = record
    ProcessId: Cardinal;
    Name: string;
  end;
  TProcessChoices = array of TProcessChoice;

  { Collects one diagnostic snapshot. CPU values are measured over a short
    interval; all other counters describe the end of that interval. }
  TResourceSnapshotService = class
  public
    class function FindRecorderProcesses: TProcessChoices;
    class function Capture(const AProcessId: Cardinal): string;
    class procedure AppendToLog(const AFileName, AText: string);
  end;

implementation

uses
  {$IFDEF WINDOWS}Windows{$ELSE}BaseUnix, Unix{$ENDIF};

const
  Th32csSnapProcess = $00000002;
  Th32csSnapThread = $00000004;
  CpuSampleDelayMs = 300;

function FormatNumber(const AFormat: string; const AValue: Double): string;
var
  lSettings: TFormatSettings;
begin
  lSettings := DefaultFormatSettings;
  lSettings.DecimalSeparator := '.';
  Result := FormatFloat(AFormat, AValue, lSettings);
end;

function FormatBytes(const AValue: QWord): string;
const
  Units: array[0..4] of string = ('B', 'KiB', 'MiB', 'GiB', 'TiB');
var
  lIndex: Integer;
  lValue: Double;
begin
  lIndex := 0;
  lValue := AValue;
  while (lValue >= 1024) and (lIndex < High(Units)) do
  begin
    lValue := lValue / 1024;
    Inc(lIndex);
  end;
  Result := FormatNumber('0.00', lValue) + ' ' + Units[lIndex] +
    ' (' + UIntToStr(AValue) + ' B)';
end;

function IsRecorderName(const AName: string): Boolean;
var
  lName: string;
begin
  lName := LowerCase(ChangeFileExt(ExtractFileName(AName), ''));
  Result := (lName = 'recorder') or (lName = 'recorderlnx');
end;

{$IFDEF WINDOWS}
type
  TProcessEntry32Local = record
    dwSize, cntUsage, th32ProcessID: DWORD;
    th32DefaultHeapID: ULONG_PTR;
    th32ModuleID, cntThreads, th32ParentProcessID: DWORD;
    pcPriClassBase: Longint;
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH - 1] of AnsiChar;
  end;
  TThreadEntry32Local = record
    dwSize, cntUsage, th32ThreadID, th32OwnerProcessID: DWORD;
    tpBasePri, tpDeltaPri: Longint;
    dwFlags: DWORD;
  end;
  TProcessMemoryCountersExLocal = record
    cb: DWORD;
    PageFaultCount: DWORD;
    PeakWorkingSetSize: SIZE_T;
    WorkingSetSize: SIZE_T;
    QuotaPeakPagedPoolUsage: SIZE_T;
    QuotaPagedPoolUsage: SIZE_T;
    QuotaPeakNonPagedPoolUsage: SIZE_T;
    QuotaNonPagedPoolUsage: SIZE_T;
    PagefileUsage: SIZE_T;
    PeakPagefileUsage: SIZE_T;
    PrivateUsage: SIZE_T;
  end;

  TIoCountersLocal = record
    ReadOperationCount, WriteOperationCount, OtherOperationCount: QWord;
    ReadTransferCount, WriteTransferCount, OtherTransferCount: QWord;
  end;

  TMibTcpRowOwnerPid = packed record
    State, LocalAddr, LocalPort, RemoteAddr, RemotePort, OwningPid: DWORD;
  end;
  PMibTcpRowOwnerPid = ^TMibTcpRowOwnerPid;
  TMibUdpRowOwnerPid = packed record
    LocalAddr, LocalPort, OwningPid: DWORD;
  end;
  PMibUdpRowOwnerPid = ^TMibUdpRowOwnerPid;
  TProcessorPerformance = record
    IdleTime, KernelTime, UserTime, DpcTime, InterruptTime: Int64;
    InterruptCount: DWORD;
  end;
  TProcessorPerformanceArray = array of TProcessorPerformance;

const
  TcpTableOwnerPidAll = 5;
  UdpTableOwnerPid = 1;
  AfInet = 2;
  AfInet6 = 23;
  SystemProcessorPerformanceInformation = 8;

function GetProcessMemoryInfoLocal(Process: THandle; Counters: Pointer;
  Size: DWORD): BOOL; stdcall; external 'psapi.dll' name 'GetProcessMemoryInfo';
function GetProcessIoCountersLocal(Process: THandle; var Counters: TIoCountersLocal): BOOL;
  stdcall; external 'kernel32.dll' name 'GetProcessIoCounters';
function GetProcessHandleCountLocal(Process: THandle; var Count: DWORD): BOOL;
  stdcall; external 'kernel32.dll' name 'GetProcessHandleCount';
function GetGuiResources(Process: THandle; Flags: DWORD): DWORD;
  stdcall; external 'user32.dll' name 'GetGuiResources';
function GetExtendedTcpTable(Table: Pointer; var Size: DWORD; Order: BOOL;
  IpVersion, TableClass, Reserved: DWORD): DWORD; stdcall;
  external 'iphlpapi.dll' name 'GetExtendedTcpTable';
function GetExtendedUdpTable(Table: Pointer; var Size: DWORD; Order: BOOL;
  IpVersion, TableClass, Reserved: DWORD): DWORD; stdcall;
  external 'iphlpapi.dll' name 'GetExtendedUdpTable';
function CreateToolhelp32SnapshotLocal(Flags, ProcessId: DWORD): THandle;
  stdcall; external 'kernel32.dll' name 'CreateToolhelp32Snapshot';
function Process32FirstLocal(Snapshot: THandle; var Entry: TProcessEntry32Local): BOOL;
  stdcall; external 'kernel32.dll' name 'Process32First';
function Process32NextLocal(Snapshot: THandle; var Entry: TProcessEntry32Local): BOOL;
  stdcall; external 'kernel32.dll' name 'Process32Next';
function Thread32FirstLocal(Snapshot: THandle; var Entry: TThreadEntry32Local): BOOL;
  stdcall; external 'kernel32.dll' name 'Thread32First';
function Thread32NextLocal(Snapshot: THandle; var Entry: TThreadEntry32Local): BOOL;
  stdcall; external 'kernel32.dll' name 'Thread32Next';
function NtQuerySystemInformation(InfoClass: DWORD; Buffer: Pointer;
  BufferSize: DWORD; ReturnLength: PDWORD): LongInt; stdcall;
  external 'ntdll.dll' name 'NtQuerySystemInformation';

function FileTimeValue(const AValue: TFileTime): QWord;
begin
  Result := (QWord(AValue.dwHighDateTime) shl 32) or AValue.dwLowDateTime;
end;

function ProcessCpuTime(const AHandle: THandle): QWord;
var
  lCreated, lExited, lKernel, lUser: TFileTime;
begin
  if not GetProcessTimes(AHandle, lCreated, lExited, lKernel, lUser) then
    RaiseLastOSError;
  Result := FileTimeValue(lKernel) + FileTimeValue(lUser);
end;

function CountThreads(const AProcessId: DWORD): Cardinal;
var
  lSnapshot: THandle;
  lEntry: TThreadEntry32Local;
begin
  Result := 0;
  lSnapshot := CreateToolhelp32SnapshotLocal(Th32csSnapThread, 0);
  if lSnapshot = INVALID_HANDLE_VALUE then Exit;
  try
    lEntry.dwSize := SizeOf(lEntry);
    if Thread32FirstLocal(lSnapshot, lEntry) then
      repeat
        if lEntry.th32OwnerProcessID = AProcessId then Inc(Result);
      until not Thread32NextLocal(lSnapshot, lEntry);
  finally
    CloseHandle(lSnapshot);
  end;
end;

procedure CountSocketTable(const AProcessId, AFamily, AClass, ARowSize,
  APidOffset: DWORD; const AIsTcp: Boolean; out ACount: Cardinal);
var
  lSize, lCount, lIndex: DWORD;
  lBuffer: Pointer;
  lRows: PByte;
begin
  ACount := 0;
  lSize := 0;
  if AIsTcp then
    GetExtendedTcpTable(nil, lSize, False, AFamily, AClass, 0)
  else
    GetExtendedUdpTable(nil, lSize, False, AFamily, AClass, 0);
  if lSize > 0 then
  begin
    GetMem(lBuffer, lSize);
    try
      if (AIsTcp and (GetExtendedTcpTable(lBuffer, lSize, False, AFamily,
        AClass, 0) = 0)) or ((not AIsTcp) and
        (GetExtendedUdpTable(lBuffer, lSize, False, AFamily,
        AClass, 0) = 0)) then
      begin
        lCount := PDWORD(lBuffer)^;
        lRows := PByte(lBuffer) + SizeOf(DWORD);
        for lIndex := 0 to lCount - 1 do
          if PDWORD(lRows + lIndex * ARowSize + APidOffset)^ = AProcessId then
            Inc(ACount);
      end;
    finally
      FreeMem(lBuffer);
    end;
  end;
end;

procedure CountSockets(const AProcessId: DWORD; out ATcp4, AUdp4, ATcp6,
  AUdp6: Cardinal);
begin
  CountSocketTable(AProcessId, AfInet, TcpTableOwnerPidAll,
    SizeOf(TMibTcpRowOwnerPid), 20, True, ATcp4);
  CountSocketTable(AProcessId, AfInet, UdpTableOwnerPid,
    SizeOf(TMibUdpRowOwnerPid), 8, False, AUdp4);
  CountSocketTable(AProcessId, AfInet6, TcpTableOwnerPidAll,
    56, 52, True, ATcp6);
  CountSocketTable(AProcessId, AfInet6, UdpTableOwnerPid,
    28, 24, False, AUdp6);
end;

function ReadProcessorPerformance(const ACount: DWORD): TProcessorPerformanceArray;
var
  lBytes: DWORD;
begin
  SetLength(Result, ACount);
  if ACount = 0 then Exit;
  lBytes := ACount * SizeOf(TProcessorPerformance);
  if NtQuerySystemInformation(SystemProcessorPerformanceInformation,
    @Result[0], lBytes, nil) <> 0 then
  begin
    SetLength(Result, 0);
    raise Exception.Create('Не удалось получить загрузку логических процессоров');
  end;
end;

function ProcessorBusyPercent(const ABefore, AAfter: TProcessorPerformance): Double;
var
  lIdle, lTotal: Int64;
begin
  lIdle := AAfter.IdleTime - ABefore.IdleTime;
  lTotal := (AAfter.KernelTime - ABefore.KernelTime) +
    (AAfter.UserTime - ABefore.UserTime);
  if lTotal <= 0 then Exit(0);
  Result := 100.0 * (lTotal - lIdle) / lTotal;
  if Result < 0 then Result := 0;
  if Result > 100 then Result := 100;
end;

class function TResourceSnapshotService.FindRecorderProcesses: TProcessChoices;
var
  lSnapshot: THandle;
  lEntry: TProcessEntry32Local;
  lLength: Integer;
begin
  SetLength(Result, 0);
  lSnapshot := CreateToolhelp32SnapshotLocal(Th32csSnapProcess, 0);
  if lSnapshot = INVALID_HANDLE_VALUE then RaiseLastOSError;
  try
    lEntry.dwSize := SizeOf(lEntry);
    if Process32FirstLocal(lSnapshot, lEntry) then
      repeat
        if IsRecorderName(StrPas(@lEntry.szExeFile[0])) then
        begin
          lLength := Length(Result);
          SetLength(Result, lLength + 1);
          Result[lLength].ProcessId := lEntry.th32ProcessID;
          Result[lLength].Name := StrPas(@lEntry.szExeFile[0]);
        end;
      until not Process32NextLocal(lSnapshot, lEntry);
  finally
    CloseHandle(lSnapshot);
  end;
end;

class function TResourceSnapshotService.Capture(const AProcessId: Cardinal): string;
var
  lProcess: THandle;
  lBefore, lAfter, lElapsed100Ns: QWord;
  lStartTick, lEndTick: QWord;
  lCpuMachine, lCpuOneCore: Double;
  lProcessors: DWORD;
  lSystemInfo: TSystemInfo;
  lMemory: TProcessMemoryCountersExLocal;
  lIo: TIoCountersLocal;
  lHandles, lTcp4, lUdp4, lTcp6, lUdp6: DWORD;
  lCpuBefore, lCpuAfter: TProcessorPerformanceArray;
  lCoreIndex: Integer;
  lSystemBusySum: Double;
  lLines: TStringList;
begin
  lProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
    False, AProcessId);
  if lProcess = 0 then RaiseLastOSError;
  lLines := TStringList.Create;
  try
    lBefore := ProcessCpuTime(lProcess);
    GetSystemInfo(lSystemInfo);
    lProcessors := lSystemInfo.dwNumberOfProcessors;
    if lProcessors = 0 then lProcessors := 1;
    lCpuBefore := ReadProcessorPerformance(lProcessors);
    lStartTick := GetTickCount64;
    Sleep(CpuSampleDelayMs);
    lAfter := ProcessCpuTime(lProcess);
    lCpuAfter := ReadProcessorPerformance(lProcessors);
    lEndTick := GetTickCount64;
    lElapsed100Ns := (lEndTick - lStartTick) * 10000;
    if lElapsed100Ns = 0 then lElapsed100Ns := 1;
    lCpuOneCore := 100.0 * (lAfter - lBefore) / lElapsed100Ns;
    lCpuMachine := lCpuOneCore / lProcessors;

    FillChar(lMemory, SizeOf(lMemory), 0);
    lMemory.cb := SizeOf(lMemory);
    if not GetProcessMemoryInfoLocal(lProcess, @lMemory, SizeOf(lMemory)) then
      RaiseLastOSError;
    FillChar(lIo, SizeOf(lIo), 0);
    if not GetProcessIoCountersLocal(lProcess, lIo) then RaiseLastOSError;
    lHandles := 0;
    GetProcessHandleCountLocal(lProcess, lHandles);
    CountSockets(AProcessId, lTcp4, lUdp4, lTcp6, lUdp6);

    lLines.Add('=== RECORDER RESOURCE SNAPSHOT ===');
    lLines.Add('timestamp_local=' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now));
    lLines.Add('platform=Windows');
    lLines.Add('pid=' + UIntToStr(AProcessId));
    lLines.Add('logical_cpu_count=' + UIntToStr(lProcessors));
    lLines.Add('cpu_sample_interval_ms=' + UIntToStr(lEndTick - lStartTick));
    lLines.Add('process_cpu_machine_percent=' + FormatNumber('0.00', lCpuMachine));
    lLines.Add('process_cpu_one_core_percent=' + FormatNumber('0.00', lCpuOneCore));
    lSystemBusySum := 0;
    for lCoreIndex := 0 to High(lCpuAfter) do
    begin
      lCpuMachine := ProcessorBusyPercent(lCpuBefore[lCoreIndex],
        lCpuAfter[lCoreIndex]);
      lSystemBusySum := lSystemBusySum + lCpuMachine;
      lLines.Add('system_cpu_core_' + IntToStr(lCoreIndex) + '_percent=' +
        FormatNumber('0.00', lCpuMachine));
    end;
    if Length(lCpuAfter) > 0 then
      lLines.Add('system_cpu_total_percent=' +
        FormatNumber('0.00', lSystemBusySum / Length(lCpuAfter)));
    lLines.Add('working_set=' + FormatBytes(lMemory.WorkingSetSize));
    lLines.Add('peak_working_set=' + FormatBytes(lMemory.PeakWorkingSetSize));
    lLines.Add('private_bytes=' + FormatBytes(lMemory.PrivateUsage));
    lLines.Add('pagefile_usage=' + FormatBytes(lMemory.PagefileUsage));
    lLines.Add('page_faults=' + UIntToStr(lMemory.PageFaultCount));
    lLines.Add('threads=' + UIntToStr(CountThreads(AProcessId)));
    lLines.Add('handles=' + UIntToStr(lHandles));
    lLines.Add('gdi_objects=' + UIntToStr(GetGuiResources(lProcess, 0)));
    lLines.Add('user_objects=' + UIntToStr(GetGuiResources(lProcess, 1)));
    lLines.Add('tcp_ipv4_sockets=' + UIntToStr(lTcp4));
    lLines.Add('udp_ipv4_sockets=' + UIntToStr(lUdp4));
    lLines.Add('tcp_ipv6_sockets=' + UIntToStr(lTcp6));
    lLines.Add('udp_ipv6_sockets=' + UIntToStr(lUdp6));
    lLines.Add('io_read_operations=' + UIntToStr(lIo.ReadOperationCount));
    lLines.Add('io_write_operations=' + UIntToStr(lIo.WriteOperationCount));
    lLines.Add('io_read_bytes=' + FormatBytes(lIo.ReadTransferCount));
    lLines.Add('io_write_bytes=' + FormatBytes(lIo.WriteTransferCount));
    lLines.Add('=== END SNAPSHOT ===');
    Result := lLines.Text;
  finally
    lLines.Free;
    CloseHandle(lProcess);
  end;
end;
{$ELSE}
function ReadFirstLine(const AFileName: string): string;
var
  lLines: TStringList;
begin
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(AFileName);
    if lLines.Count = 0 then Result := '' else Result := lLines[0];
  finally
    lLines.Free;
  end;
end;

class function TResourceSnapshotService.FindRecorderProcesses: TProcessChoices;
var
  lSearch: TSearchRec;
  lName: string;
  lLength: Integer;
  lPid: QWord;
begin
  SetLength(Result, 0);
  if FindFirst('/proc/*', faDirectory, lSearch) <> 0 then Exit;
  try
    repeat
      if TryStrToQWord(lSearch.Name, lPid) then
      begin
        try
          lName := ReadFirstLine('/proc/' + lSearch.Name + '/comm');
          if IsRecorderName(lName) then
          begin
            lLength := Length(Result);
            SetLength(Result, lLength + 1);
            Result[lLength].ProcessId := lPid;
            Result[lLength].Name := lName;
          end;
        except
          { A process can exit while /proc is being enumerated. }
        end;
      end;
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

class function TResourceSnapshotService.Capture(const AProcessId: Cardinal): string;
var
  lLines, lStatus: TStringList;
  lFdSearch: TSearchRec;
  lFdCount, lSocketCount, lIndex: Integer;
  lTarget, lPrefix, lValue: string;
begin
  lLines := TStringList.Create;
  lStatus := TStringList.Create;
  try
    lStatus.LoadFromFile('/proc/' + UIntToStr(AProcessId) + '/status');
    lFdCount := 0;
    lSocketCount := 0;
    if FindFirst('/proc/' + UIntToStr(AProcessId) + '/fd/*', faAnyFile, lFdSearch) = 0 then
    try
      repeat
        if (lFdSearch.Name <> '.') and (lFdSearch.Name <> '..') then
        begin
          Inc(lFdCount);
          lTarget := fpReadLink('/proc/' + UIntToStr(AProcessId) + '/fd/' + lFdSearch.Name);
          if Pos('socket:[', lTarget) = 1 then Inc(lSocketCount);
        end;
      until FindNext(lFdSearch) <> 0;
    finally
      FindClose(lFdSearch);
    end;
    lLines.Add('=== RECORDER RESOURCE SNAPSHOT ===');
    lLines.Add('timestamp_local=' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now));
    lLines.Add('platform=Linux');
    lLines.Add('pid=' + UIntToStr(AProcessId));
    for lIndex := 0 to lStatus.Count - 1 do
    begin
      lPrefix := Copy(lStatus[lIndex], 1, Pos(':', lStatus[lIndex]));
      lValue := Trim(Copy(lStatus[lIndex], Length(lPrefix) + 1, MaxInt));
      if lPrefix = 'Name:' then lLines.Add('name=' + lValue)
      else if lPrefix = 'VmRSS:' then lLines.Add('working_set=' + lValue)
      else if lPrefix = 'VmHWM:' then lLines.Add('peak_working_set=' + lValue)
      else if lPrefix = 'VmSize:' then lLines.Add('virtual_memory=' + lValue)
      else if lPrefix = 'VmSwap:' then lLines.Add('swap=' + lValue)
      else if lPrefix = 'Threads:' then lLines.Add('threads=' + lValue)
      else if lPrefix = 'voluntary_ctxt_switches:' then lLines.Add('voluntary_context_switches=' + lValue)
      else if lPrefix = 'nonvoluntary_ctxt_switches:' then lLines.Add('nonvoluntary_context_switches=' + lValue);
    end;
    lLines.Add('file_descriptors=' + IntToStr(lFdCount));
    lLines.Add('sockets=' + IntToStr(lSocketCount));
    lLines.Add('note=CPU sampling for Linux is not available in this build');
    lLines.Add('=== END SNAPSHOT ===');
    Result := lLines.Text;
  finally
    lStatus.Free;
    lLines.Free;
  end;
end;
{$ENDIF}

class procedure TResourceSnapshotService.AppendToLog(const AFileName,
  AText: string);
var
  lStream: TFileStream;
  lData: UTF8String;
begin
  ForceDirectories(ExtractFileDir(ExpandFileName(AFileName)));
  if FileExists(AFileName) then
    lStream := TFileStream.Create(AFileName, fmOpenWrite or fmShareDenyWrite)
  else
    lStream := TFileStream.Create(AFileName, fmCreate or fmShareDenyWrite);
  try
    lStream.Position := lStream.Size;
    lData := UTF8String(AText + LineEnding);
    if Length(lData) > 0 then lStream.WriteBuffer(lData[1], Length(lData));
  finally
    lStream.Free;
  end;
end;

end.
