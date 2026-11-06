program Mic315Updater;

{ One-shot local updater for the wired MIC315 calibration stand. It never
  changes drivers/configuration or installs a remote execution mechanism.
  --dry-run is strictly read-only, including logs and process lifetimes. }

{$mode objfpc}{$H+}
{$codepage UTF8}
{$APPTYPE CONSOLE}
{$R Mic315Updater.res}

uses
  Windows, JwaTlHelp32, ShellApi, Classes, SysUtils;

const
  CTargetFile = 'C:\Program Files (x86)\Mera\RecorderLnx\RecorderLnx.exe';
  CPayloadFile = 'RecorderLnx-dac-feedback.exe';
  CProcessStopTimeoutMs = 5000;
  CStartupObservationMs = 1000;
  CCompareBufferBytes = 65536;
  CMoveFileWriteThrough = $00000008;

function IsUserAnAdmin: Windows.BOOL; stdcall; external 'shell32.dll';

type
  TUpdater = class
  private
    fDryRun, fNoPause: Boolean;
    fTarget, fPayload, fBackup, fPending, fLogFile: string;
    fLog: TStringList;
    procedure Log(const AText: string);
    procedure Require(ACondition: Boolean; const AMessage: string);
    procedure RequireWin(ACondition: Boolean; const AContext: string);
    procedure ParseOptions;
    function ComputerName: string;
    procedure ValidatePe(const AFileName: string);
    function SameFileBytes(const ALeft, ARight: string): Boolean;
    procedure CopyVerified(const ASource, ADestination: string);
    procedure StopInstalledRecorders;
    function IsInstalledRecorder(const AImage: string): Boolean;
    procedure ReplaceTarget;
    procedure LaunchTarget;
    procedure RestoreBackup;
    function RequestElevation: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Run: Boolean;
    property NoPause: Boolean read fNoPause;
  end;

constructor TUpdater.Create;
begin
  inherited Create;
  fLog := TStringList.Create;
  fTarget := CTargetFile;
  fPayload := ExtractFilePath(ParamStr(0)) + CPayloadFile;
end;

destructor TUpdater.Destroy;
begin
  fLog.Free;
  inherited Destroy;
end;

procedure TUpdater.Log(const AText: string);
begin
  Writeln(AText);
  fLog.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ' + AText);
  if not fDryRun and (fLogFile <> '') then fLog.SaveToFile(fLogFile);
end;

procedure TUpdater.Require(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure TUpdater.RequireWin(ACondition: Boolean; const AContext: string);
var
  lError: DWORD;
begin
  if ACondition then Exit;
  lError := GetLastError;
  raise Exception.Create(AContext + ': WinError=' + IntToStr(lError) + ' ' +
    SysErrorMessage(lError));
end;

procedure TUpdater.ParseOptions;
var
  lIndex: Integer;
  lArg: string;
begin
  { Parse dry-run first so option order cannot turn overrides into a write. }
  for lIndex := 1 to ParamCount do
  begin
    fDryRun := fDryRun or SameText(ParamStr(lIndex), '--dry-run');
    fNoPause := fNoPause or SameText(ParamStr(lIndex), '--no-pause');
  end;
  for lIndex := 1 to ParamCount do
  begin
    lArg := ParamStr(lIndex);
    if SameText(lArg, '--dry-run') or SameText(lArg, '--no-pause') then Continue;
    Require(fDryRun, 'Path overrides are allowed only with --dry-run.');
    if Copy(lArg, 1, 9) = '--target=' then
      fTarget := Copy(lArg, 10, MaxInt)
    else if Copy(lArg, 1, 10) = '--payload=' then
      fPayload := Copy(lArg, 11, MaxInt)
    else
      raise Exception.Create('Unknown option: ' + lArg);
  end;
  fTarget := ExpandFileName(fTarget);
  fPayload := ExpandFileName(fPayload);
end;

function TUpdater.ComputerName: string;
var
  lBuffer: array[0..MAX_COMPUTERNAME_LENGTH] of WideChar;
  lCount: DWORD;
begin
  lCount := Length(lBuffer);
  RequireWin(GetComputerNameW(@lBuffer[0], @lCount), 'Cannot read computer name');
  Result := UTF8Encode(UnicodeString(PWideChar(@lBuffer[0])));
end;

procedure TUpdater.ValidatePe(const AFileName: string);
var
  lFile: TFileStream;
  lMz: Word;
  lPeOffset, lPe: LongWord;
begin
  Require(FileExists(AFileName), 'Missing file: ' + AFileName);
  lFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Require(lFile.Size >= 64, 'File is too small to be a Windows PE: ' + AFileName);
    lFile.ReadBuffer(lMz, SizeOf(lMz));
    Require(lMz = $5A4D, 'Invalid DOS signature: ' + AFileName);
    lFile.Position := $3C;
    lFile.ReadBuffer(lPeOffset, SizeOf(lPeOffset));
    Require((lPeOffset >= 64) and (lPeOffset <= lFile.Size - 4),
      'Invalid PE header offset: ' + AFileName);
    lFile.Position := lPeOffset;
    lFile.ReadBuffer(lPe, SizeOf(lPe));
    Require(lPe = $00004550, 'Invalid PE signature: ' + AFileName);
    Log('PE OK: ' + AFileName + ' (' + IntToStr(lFile.Size) + ' bytes)');
  finally
    lFile.Free;
  end;
end;

function TUpdater.SameFileBytes(const ALeft, ARight: string): Boolean;
var
  lLeft, lRight: TFileStream;
  lLeftData, lRightData: array[0..CCompareBufferBytes - 1] of Byte;
  lCount, lOtherCount: Integer;
begin
  Result := False;
  lLeft := TFileStream.Create(ALeft, fmOpenRead or fmShareDenyWrite);
  try
    lRight := TFileStream.Create(ARight, fmOpenRead or fmShareDenyWrite);
    try
      if lLeft.Size <> lRight.Size then Exit;
      repeat
        lCount := lLeft.Read(lLeftData, SizeOf(lLeftData));
        lOtherCount := lRight.Read(lRightData, SizeOf(lRightData));
        if (lCount <> lOtherCount) or
          not CompareMem(@lLeftData[0], @lRightData[0], lCount) then Exit;
      until lCount = 0;
      Result := True;
    finally
      lRight.Free;
    end;
  finally
    lLeft.Free;
  end;
end;

procedure TUpdater.CopyVerified(const ASource, ADestination: string);
begin
  RequireWin(CopyFileW(PWideChar(UTF8Decode(ASource)),
    PWideChar(UTF8Decode(ADestination)), True),
    'Copy failed: ' + ADestination);
  Require(SameFileBytes(ASource, ADestination), 'Byte verification failed: ' + ADestination);
  Log('Verified copy: ' + ADestination);
end;

function TUpdater.IsInstalledRecorder(const AImage: string): Boolean;
var
  lName: string;
begin
  Result := SameText(ExcludeTrailingPathDelimiter(ExtractFilePath(AImage)),
    ExcludeTrailingPathDelimiter(ExtractFilePath(fTarget)));
  if not Result then Exit;
  lName := LowerCase(ExtractFileName(AImage));
  Result := (lName = 'recorderlnx.exe') or
    ((Copy(lName, 1, 12) = 'recorderlnx-') and (ExtractFileExt(lName) = '.exe'));
end;

procedure TUpdater.StopInstalledRecorders;
var
  lSnapshot, lProcess: THandle;
  lEntry: TProcessEntry32W;
  lPath: array[0..32767] of WideChar;
  lPathCount: DWORD;
  lImage, lName: string;
begin
  lSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  Require(lSnapshot <> INVALID_HANDLE_VALUE, 'Cannot enumerate processes.');
  try
    FillChar(lEntry, SizeOf(lEntry), 0);
    lEntry.dwSize := SizeOf(lEntry);
    if not Process32FirstW(lSnapshot, lEntry) then Exit;
    repeat
      if lEntry.th32ProcessID = GetCurrentProcessId then Continue;
      lName := LowerCase(UTF8Encode(UnicodeString(PWideChar(@lEntry.szExeFile[0]))));
      if (lName <> 'recorderlnx.exe') and (Copy(lName, 1, 12) <> 'recorderlnx-') then Continue;
      lProcess := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION or
        PROCESS_TERMINATE or SYNCHRONIZE, False, lEntry.th32ProcessID);
      if lProcess = 0 then
      begin
        Log('Cannot verify candidate PID=' + IntToStr(lEntry.th32ProcessID) +
          '; skipped without termination.');
        Continue;
      end;
      try
        lPathCount := Length(lPath);
        if not QueryFullProcessImageNameW(lProcess, 0, @lPath[0], @lPathCount) then Continue;
        lImage := UTF8Encode(UnicodeString(PWideChar(@lPath[0])));
        if not IsInstalledRecorder(lImage) then Continue;
        Log('Stopping verified installation process PID=' +
          IntToStr(lEntry.th32ProcessID) + ' ' + lImage);
        RequireWin(TerminateProcess(lProcess, 0),
          'Cannot stop PID=' + IntToStr(lEntry.th32ProcessID));
        Require(WaitForSingleObject(lProcess, CProcessStopTimeoutMs) = WAIT_OBJECT_0,
          'Process stop timed out: PID=' + IntToStr(lEntry.th32ProcessID));
      finally
        CloseHandle(lProcess);
      end;
    until not Process32NextW(lSnapshot, lEntry);
  finally
    CloseHandle(lSnapshot);
  end;
end;

procedure TUpdater.ReplaceTarget;
begin
  RequireWin(MoveFileExW(PWideChar(UTF8Decode(fPending)),
    PWideChar(UTF8Decode(fTarget)), MOVEFILE_REPLACE_EXISTING or CMoveFileWriteThrough),
    'Replacing target failed');
  Require(SameFileBytes(fPayload, fTarget), 'Installed target differs from payload.');
  Log('Installed EXE matches payload byte-for-byte.');
end;

procedure TUpdater.LaunchTarget;
var
  lStartup: Windows.TStartupInfoW;
  lProcess: Windows.TProcessInformation;
  lCommand, lDirectory: UnicodeString;
  lWait: DWORD;
begin
  FillChar(lStartup, SizeOf(lStartup), 0);
  lStartup.cb := SizeOf(lStartup);
  FillChar(lProcess, SizeOf(lProcess), 0);
  lCommand := UTF8Decode('"' + fTarget + '"');
  lDirectory := UTF8Decode(ExtractFilePath(fTarget));
  UniqueString(lCommand);
  RequireWin(CreateProcessW(PWideChar(UTF8Decode(fTarget)), PWideChar(lCommand),
    nil, nil, False, 0, nil, PWideChar(lDirectory), lStartup, lProcess),
    'Launching Recorder failed');
  try
    lWait := WaitForSingleObject(lProcess.hProcess, CStartupObservationMs);
    Require(lWait = WAIT_TIMEOUT, 'Recorder exited during the one-second startup check.');
    Log('Recorder launched, PID=' + IntToStr(lProcess.dwProcessId) +
      '. One-second process check passed; functional calibration is not yet verified.');
  finally
    CloseHandle(lProcess.hThread);
    CloseHandle(lProcess.hProcess);
  end;
end;

procedure TUpdater.RestoreBackup;
begin
  Log('Restoring the previous verified EXE.');
  StopInstalledRecorders;
  RequireWin(CopyFileW(PWideChar(UTF8Decode(fBackup)),
    PWideChar(UTF8Decode(fTarget)), False),
    'ROLLBACK FAILED');
  Require(SameFileBytes(fBackup, fTarget), 'ROLLBACK FAILED: byte mismatch.');
  Log('Rollback verified. Configuration and DLLs were not changed.');
  LaunchTarget;
end;

function TUpdater.RequestElevation: Boolean;
var
  lParameters: UnicodeString;
  lResult: HInst;
begin
  Result := not IsUserAnAdmin;
  if not Result then Exit;
  lParameters := '';
  if fNoPause then lParameters := '--no-pause';
  Log('Administrator rights are required. Please confirm Windows UAC.');
  lResult := ShellExecuteW(0, 'runas', PWideChar(UTF8Decode(ParamStr(0))),
    PWideChar(lParameters), PWideChar(UTF8Decode(ExtractFilePath(ParamStr(0)))), SW_SHOWNORMAL);
  Require(PtrUInt(lResult) > 32, 'Elevation was canceled or failed; no update was performed.');
  Log('Handed off to elevated updater. Check its console/log for the final result.');
end;

function TUpdater.Run: Boolean;
var
  lHost, lStamp, lFailure, lLogDirectory, lBackupDirectory: string;
begin
  Result := False;
  try
    ParseOptions;
    { Capture failures before PE validation/elevation too. A handoff is not
      proof that the elevated child actually reached the replacement stage. }
    if not fDryRun then
    begin
      lLogDirectory := ExtractFilePath(ParamStr(0)) + 'logs' + PathDelim;
      Require(ForceDirectories(lLogDirectory), 'Cannot create updater logs directory.');
      fLogFile := lLogDirectory + 'updater-' +
        FormatDateTime('yyyymmdd-hhnnss-zzz', Now) + '-' +
        IntToStr(GetCurrentProcessId) + '.log';
    end;
    lHost := ComputerName;
    Log('MIC315 Recorder updater. Host=' + lHost);
    Log('Target=' + fTarget);
    Log('Payload=' + fPayload);
    Log('Config and DLL files will not be copied, deleted or modified.');
    ValidatePe(fPayload);
    ValidatePe(fTarget);
    if fDryRun then
    begin
      Log('DRY RUN: no files/logs written, no process stopped or launched.');
      if not (SameText(lHost, 'MIC-315') or SameText(lHost, 'MIC315')) then
        Log('Real update would be refused: computer name is not MIC-315/MIC315.');
      Exit(True);
    end;
    Require(SameText(lHost, 'MIC-315') or SameText(lHost, 'MIC315'),
      'Refusing changes: updater is restricted to MIC-315/MIC315.');
    Require(SameText(fTarget, CTargetFile), 'Refusing a nonstandard real target.');
    Require(not SameText(fTarget, fPayload), 'Payload and target must differ.');
    if RequestElevation then Exit(True);
    lStamp := FormatDateTime('yyyymmdd-hhnnss-zzz', Now);
    lBackupDirectory := ExtractFilePath(ParamStr(0)) + 'backups' + PathDelim;
    Require(ForceDirectories(lBackupDirectory), 'Cannot create updater backups directory.');
    fBackup := lBackupDirectory + 'RecorderLnx-before-' + lStamp + '.exe';
    fPending := fTarget + '.update-' + lStamp + '.pending';
    Log('Backup=' + fBackup);
    CopyVerified(fTarget, fBackup);
    CopyVerified(fPayload, fPending);
    { Both rollback material and replacement are verified before any process
      is stopped. No target-directory cleanup or recursive copy is performed. }
    try
      StopInstalledRecorders;
      ReplaceTarget;
      LaunchTarget;
    except
      on E: Exception do
      begin
        lFailure := E.Message;
        Log('UPDATE FAILED: ' + lFailure);
        RestoreBackup;
        raise Exception.Create('Update failed; old EXE restored: ' + lFailure);
      end;
    end;
    Log('SUCCESS: EXE updated and process launched. Backup retained at ' + fBackup);
    Result := True;
  except
    on E: Exception do
    begin
      Log('ERROR: ' + E.Message);
      Log('No configuration or driver files were changed.');
    end;
  end;
end;

var
  lUpdater: TUpdater;
  lSuccess: Boolean;
begin
  lUpdater := TUpdater.Create;
  try
    lSuccess := lUpdater.Run;
    if not lSuccess then ExitCode := 1;
    if not lSuccess and not lUpdater.NoPause then
    begin
      Writeln('Press Enter to close.');
      Readln;
    end;
  finally
    lUpdater.Free;
  end;
end.
