program Mic315AudioProbe;

{ Standalone inventory only: no RecorderLnx units, no audio streams, no registry
  or service writes. An explicit PortAudio DLL is loaded once and successfully
  initialized exactly once, then terminated before unload. Only the requested
  UTF-8 log is written (append if it exists). Stdout is duplicated for wrappers.
  ABI references: portaudio.h PaHostApiInfo/PaDeviceInfo and Microsoft
  mmeapi.h waveOutGetDevCapsW / WAVEOUTCAPSW. }

{$mode objfpc}{$H+}
{$codepage UTF8}
{$packrecords c}

uses
  Classes, SysUtils, ctypes, Dynlibs, Windows;

type
  TPaError = cint;
  TPaHostApiInfo = record
    StructVersion, ApiType: cint;
    Name: PChar;
    DeviceCount, DefaultInputDevice, DefaultOutputDevice: cint;
  end;
  PPaHostApiInfo = ^TPaHostApiInfo;
  TPaDeviceInfo = record
    StructVersion: cint;
    Name: PChar;
    HostApi, MaxInputChannels, MaxOutputChannels: cint;
    DefaultLowInputLatency, DefaultLowOutputLatency: cdouble;
    DefaultHighInputLatency, DefaultHighOutputLatency, DefaultSampleRate: cdouble;
  end;
  PPaDeviceInfo = ^TPaDeviceInfo;
  TPaGetVersionText = function: PChar; cdecl;
  TPaInitialize = function: TPaError; cdecl;
  TPaTerminate = function: TPaError; cdecl;
  TPaGetCount = function: cint; cdecl;
  TPaGetHostApiInfo = function(AIndex: cint): PPaHostApiInfo; cdecl;
  TPaGetDeviceInfo = function(AIndex: cint): PPaDeviceInfo; cdecl;
  TPaGetErrorText = function(AError: TPaError): PChar; cdecl;

  TWaveOutputCapsW = record
    ManufacturerId, ProductId: Word;
    DriverVersion: DWORD;
    ProductName: array[0..31] of WideChar;
    Formats: DWORD;
    Channels, Reserved: Word;
    Support: DWORD;
  end;

const
  CPaSuccess = 0;
  CWinMmSuccess = 0;
  CMaximumInventoryCount = 65536;

function NativeWaveOutGetNumDevs: UINT; stdcall;
  external 'winmm.dll' name 'waveOutGetNumDevs';
function NativeWaveOutGetDevCapsW(ADeviceId: UINT_PTR;
  var ACaps: TWaveOutputCapsW; ASize: UINT): UINT; stdcall;
  external 'winmm.dll' name 'waveOutGetDevCapsW';

var
  gLog: TFileStream;

procedure Log(const AText: string);
var
  lLine: string;
begin
  WriteLn(AText);
  if gLog = nil then Exit;
  lLine := AText + LineEnding;
  if lLine <> '' then gLog.WriteBuffer(lLine[1], Length(lLine));
  FlushFileBuffers(gLog.Handle);
end;

function SafeText(AText: PChar): string;
begin
  if AText = nil then Result := '<nil>' else Result := StrPas(AText);
end;

function DefaultLibraryPath: string;
var
  lProgramFiles: string;
begin
  lProgramFiles := SysUtils.GetEnvironmentVariable('ProgramFiles(x86)');
  if lProgramFiles = '' then lProgramFiles := SysUtils.GetEnvironmentVariable('ProgramFiles');
  if lProgramFiles = '' then lProgramFiles := 'C:\Program Files (x86)';
  Result := IncludeTrailingPathDelimiter(lProgramFiles) +
    'Mera\RecorderLnx\portaudio.dll';
end;

function ReadArguments(out ALibraryPath, AOutputPath, AError: string;
  out AHelp: Boolean): Boolean;
var
  I: Integer;
  lArgument: string;
begin
  ALibraryPath := DefaultLibraryPath;
  AOutputPath := GetTempDir(False) + 'Mic315AudioProbe-' +
    FormatDateTime('yyyymmdd-hhnnss', Now) + '.log';
  AError := '';
  AHelp := False;
  for I := 1 to ParamCount do
  begin
    lArgument := ParamStr(I);
    if (lArgument = '--help') or (lArgument = '-h') then AHelp := True
    else if Copy(lArgument, 1, 10) = '--library=' then
      ALibraryPath := Copy(lArgument, 11, MaxInt)
    else if Copy(lArgument, 1, 6) = '--out=' then
      AOutputPath := Copy(lArgument, 7, MaxInt)
    else
    begin
      AError := 'Unknown argument: ' + lArgument;
      Exit(False);
    end;
  end;
  Result := (ALibraryPath <> '') and (AOutputPath <> '');
  if not Result then AError := 'Library and output paths must not be empty';
  ALibraryPath := ExpandFileName(ALibraryPath);
  AOutputPath := ExpandFileName(AOutputPath);
end;

function Bind(AHandle: TLibHandle; const AName: string; out AProc): Boolean;
var
  lAddress: Pointer;
begin
  lAddress := GetProcedureAddress(AHandle, PChar(AName));
  Pointer(AProc) := lAddress;
  Result := lAddress <> nil;
  Log(Format('EXPORT name=%s present=%s', [AName, BoolToStr(Result, True)]));
end;

function ProbePortAudio(const ALibraryPath: string): Boolean;
var
  lLibrary: TLibHandle;
  lVersion: TPaGetVersionText;
  lInitialize: TPaInitialize;
  lTerminate: TPaTerminate;
  lHostCount, lDeviceCount: TPaGetCount;
  lHostInfo: TPaGetHostApiInfo;
  lDeviceInfo: TPaGetDeviceInfo;
  lErrorText: TPaGetErrorText;
  lHost: PPaHostApiInfo;
  lDevice: PPaDeviceInfo;
  lCount, I: Integer;
  lError: TPaError;
  lBound: Boolean;
  lSearch: TSearchRec;
begin
  Result := False;
  Log('PORTAUDIO library_requested=' + ALibraryPath);
  if FindFirst(ALibraryPath, faAnyFile, lSearch) = 0 then
  begin
    Log(Format('PORTAUDIO library_file_bytes=%d', [lSearch.Size]));
    SysUtils.FindClose(lSearch);
  end;
  if not FileExists(ALibraryPath) then
  begin
    Log('ERROR stage=library.exists file-not-found');
    Exit;
  end;
  lLibrary := Dynlibs.LoadLibrary(ALibraryPath);
  if lLibrary = Dynlibs.NilHandle then
  begin
    Log('ERROR stage=library.load detail=' + GetLoadErrorStr);
    Exit;
  end;
  try
    lBound := Bind(lLibrary, 'Pa_GetVersionText', lVersion);
    lBound := Bind(lLibrary, 'Pa_Initialize', lInitialize) and lBound;
    lBound := Bind(lLibrary, 'Pa_Terminate', lTerminate) and lBound;
    lBound := Bind(lLibrary, 'Pa_GetHostApiCount', lHostCount) and lBound;
    lBound := Bind(lLibrary, 'Pa_GetHostApiInfo', lHostInfo) and lBound;
    lBound := Bind(lLibrary, 'Pa_GetDeviceCount', lDeviceCount) and lBound;
    lBound := Bind(lLibrary, 'Pa_GetDeviceInfo', lDeviceInfo) and lBound;
    Bind(lLibrary, 'Pa_GetErrorText', lErrorText);
    if not lBound then
    begin
      Log('ERROR stage=library.bind required-export-missing');
      Exit;
    end;
    Log('PORTAUDIO version=' + SafeText(lVersion()));
    lError := lInitialize();
    if lError <> CPaSuccess then
    begin
      Log(Format('PORTAUDIO initialize_result=%d', [lError]));
      if Assigned(lErrorText) then Log('ERROR stage=initialize text=' + SafeText(lErrorText(lError)));
      Exit;
    end;
    try
      Log(Format('PORTAUDIO initialize_result=%d', [lError]));
      lCount := lHostCount();
      Log(Format('PORTAUDIO host_api_count=%d', [lCount]));
      if (lCount < 0) or (lCount > CMaximumInventoryCount) then Exit;
      for I := 0 to lCount - 1 do
      begin
        lHost := lHostInfo(I);
        if lHost = nil then
          Log(Format('HOST index=%d info=nil', [I]))
        else
          Log(Format('HOST index=%d struct_version=%d type=%d name="%s" devices=%d default_in=%d default_out=%d',
            [I, lHost^.StructVersion, lHost^.ApiType, SafeText(lHost^.Name),
             lHost^.DeviceCount, lHost^.DefaultInputDevice, lHost^.DefaultOutputDevice]));
      end;
      lCount := lDeviceCount();
      Log(Format('PORTAUDIO device_count=%d', [lCount]));
      if (lCount < 0) or (lCount > CMaximumInventoryCount) then Exit;
      for I := 0 to lCount - 1 do
      begin
        lDevice := lDeviceInfo(I);
        if lDevice = nil then
          Log(Format('DEVICE index=%d info=nil', [I]))
        else
          Log(Format('DEVICE index=%d struct_version=%d host_index=%d in=%d out=%d default_rate=%.12g name="%s" low_in=%.9g low_out=%.9g high_in=%.9g high_out=%.9g',
            [I, lDevice^.StructVersion, lDevice^.HostApi,
             lDevice^.MaxInputChannels, lDevice^.MaxOutputChannels,
             lDevice^.DefaultSampleRate, SafeText(lDevice^.Name),
             lDevice^.DefaultLowInputLatency, lDevice^.DefaultLowOutputLatency,
             lDevice^.DefaultHighInputLatency, lDevice^.DefaultHighOutputLatency]));
      end;
      Result := True;
    finally
      lError := lTerminate();
      Log(Format('PORTAUDIO terminate_result=%d', [lError]));
      if lError <> CPaSuccess then Result := False;
    end;
  finally
    Dynlibs.UnloadLibrary(lLibrary);
    Log('PORTAUDIO library_unloaded=true');
  end;
end;

procedure ProbeWinMm;
var
  lCount, lError: UINT;
  I: Integer;
  lCaps: TWaveOutputCapsW;
  lName: string;
begin
  lCount := NativeWaveOutGetNumDevs;
  Log(Format('WINMM wave_out_count=%d caps_record_bytes=%d', [lCount, SizeOf(lCaps)]));
  if lCount > CMaximumInventoryCount then
  begin
    Log('ERROR stage=winmm.count invalid-count');
    Exit;
  end;
  for I := 0 to Integer(lCount) - 1 do
  begin
    FillChar(lCaps, SizeOf(lCaps), 0);
    lError := NativeWaveOutGetDevCapsW(I, lCaps, SizeOf(lCaps));
    if lError <> CWinMmSuccess then
      Log(Format('WINMM index=%d caps_result=%d', [I, lError]))
    else
    begin
      lName := UTF8Encode(UnicodeString(PWideChar(@lCaps.ProductName[0])));
      Log(Format('WINMM index=%d name="%s" manufacturer=%d product=%d channels=%d driver_version=%s formats=%s support=%s',
        [I, lName, lCaps.ManufacturerId, lCaps.ProductId, lCaps.Channels,
         IntToHex(lCaps.DriverVersion, 8), IntToHex(lCaps.Formats, 8), IntToHex(lCaps.Support, 8)]));
    end;
  end;
end;

var
  lLibraryPath, lOutputPath, lArgumentError: string;
  lHelp, lSuccess: Boolean;
begin
  gLog := nil;
  if not ReadArguments(lLibraryPath, lOutputPath, lArgumentError, lHelp) then
  begin
    WriteLn(lArgumentError);
    ExitCode := 2;
    Exit;
  end;
  if lHelp then
  begin
    WriteLn('Mic315AudioProbe --library=C:\absolute\path\portaudio.dll --out=C:\existing\folder\audio-probe.log');
    WriteLn('Inventory only: loads/initializes PortAudio and queries devices plus WinMM; never opens audio streams.');
    Exit;
  end;
  try
    if FileExists(lOutputPath) then
      gLog := TFileStream.Create(lOutputPath, fmOpenReadWrite or fmShareDenyNone)
    else
      gLog := TFileStream.Create(lOutputPath, fmCreate or fmShareDenyNone);
    gLog.Position := gLog.Size;
    Log('=== Mic315AudioProbe ' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ===');
    Log(Format('PROCESS bits=%d pid=%d session_name=%s',
      [SizeOf(Pointer) * 8, GetCurrentProcessId, SysUtils.GetEnvironmentVariable('SESSIONNAME')]));
    Log('PROCESS exe=' + ExpandFileName(ParamStr(0)));
    Log('OUTPUT log=' + lOutputPath);
    Log(Format('ABI host_info_bytes=%d device_info_bytes=%d',
      [SizeOf(TPaHostApiInfo), SizeOf(TPaDeviceInfo)]));
    lSuccess := ProbePortAudio(lLibraryPath);
    ProbeWinMm;
    if lSuccess then Log('RESULT Mic315AudioProbe completed')
    else
    begin
      Log('RESULT Mic315AudioProbe failed');
      ExitCode := 1;
    end;
  except
    on E: Exception do
    begin
      Log('ERROR exception=' + E.ClassName + ' detail=' + E.Message);
      ExitCode := 1;
    end;
  end;
  FreeAndNil(gLog);
end.
