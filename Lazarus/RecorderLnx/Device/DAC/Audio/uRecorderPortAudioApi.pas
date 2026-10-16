unit uRecorderPortAudioApi;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  ctypes, Dynlibs;

type
  TPaError = CInt;
  TPaStream = Pointer;
  PPaStream = ^TPaStream;
  TPaSampleFormat = CULong;
  TPaDeviceIndex = CInt;

  PPaDeviceInfo = ^TPaDeviceInfo;
  TPaDeviceInfo = record
    StructVersion: CInt;
    Name: PChar;
    HostApi: CInt;
    MaxInputChannels: CInt;
    MaxOutputChannels: CInt;
    DefaultLowInputLatency: CDouble;
    DefaultLowOutputLatency: CDouble;
    DefaultHighInputLatency: CDouble;
    DefaultHighOutputLatency: CDouble;
    DefaultSampleRate: CDouble;
  end;

  PPaStreamParameters = ^TPaStreamParameters;
  TPaStreamParameters = record
    Device: TPaDeviceIndex;
    ChannelCount: CInt;
    SampleFormat: TPaSampleFormat;
    SuggestedLatency: CDouble;
    HostApiSpecificStreamInfo: Pointer;
  end;

  TPaInitialize = function: TPaError; cdecl;
  TPaTerminate = function: TPaError; cdecl;
  TPaOpenDefaultStream = function(AStream: PPaStream; AInputChannels,
    AOutputChannels: CInt; ASampleFormat: TPaSampleFormat;
    ASampleRate: CDouble; AFramesPerBuffer: CULong; ACallback,
    AUserData: Pointer): TPaError; cdecl;
  TPaOpenStream = function(AStream: PPaStream;
    AInputParameters, AOutputParameters: PPaStreamParameters;
    ASampleRate: CDouble; AFramesPerBuffer: CULong; AStreamFlags: CULong;
    ACallback, AUserData: Pointer): TPaError; cdecl;
  TPaGetDeviceCount = function: TPaDeviceIndex; cdecl;
  TPaGetDefaultOutputDevice = function: TPaDeviceIndex; cdecl;
  TPaGetDeviceInfo = function(ADevice: TPaDeviceIndex): PPaDeviceInfo; cdecl;
  TPaCloseStream = function(AStream: TPaStream): TPaError; cdecl;
  TPaStartStream = function(AStream: TPaStream): TPaError; cdecl;
  TPaStopStream = function(AStream: TPaStream): TPaError; cdecl;
  TPaAbortStream = function(AStream: TPaStream): TPaError; cdecl;
  TPaWriteStream = function(AStream: TPaStream; ABuffer: Pointer;
    AFrames: CULong): TPaError; cdecl;
  TPaGetErrorText = function(AError: TPaError): PChar; cdecl;

  TRecorderPortAudioApi = class
  private
    fLibrary: TLibHandle;
    function LoadProc(const AName: PChar; out AProc): Boolean;
  public
    Initialize: TPaInitialize;
    Terminate: TPaTerminate;
    OpenDefaultStream: TPaOpenDefaultStream;
    OpenStream: TPaOpenStream;
    GetDeviceCount: TPaGetDeviceCount;
    GetDefaultOutputDevice: TPaGetDefaultOutputDevice;
    GetDeviceInfo: TPaGetDeviceInfo;
    CloseStream: TPaCloseStream;
    StartStream: TPaStartStream;
    StopStream: TPaStopStream;
    AbortStream: TPaAbortStream;
    WriteStream: TPaWriteStream;
    GetErrorText: TPaGetErrorText;
    destructor Destroy; override;
    function Load(out AErrorText: string): Boolean;
    procedure Unload;
    function ErrorText(AError: TPaError): string;
  end;

const
  CPaNoError = 0;
  CPaNoDevice = -1;
  CPaNoFlag: CULong = 0;
  CPaFloat32: TPaSampleFormat = $00000001;

implementation

uses SysUtils;

function TRecorderPortAudioApi.LoadProc(const AName: PChar; out AProc): Boolean;
var
  lAddress: Pointer;
begin
  lAddress := GetProcedureAddress(fLibrary, AName);
  Pointer(AProc) := lAddress;
  Result := lAddress <> nil;
end;

destructor TRecorderPortAudioApi.Destroy;
begin
  Unload;
  inherited Destroy;
end;

function TRecorderPortAudioApi.Load(out AErrorText: string): Boolean;
const
  {$IFDEF WINDOWS}
  CLibraryNames: array[0..1] of string = ('portaudio.dll', 'libportaudio-2.dll');
  {$ELSE}
  CLibraryNames: array[0..1] of string = ('libportaudio.so.2', 'libportaudio.so');
  {$ENDIF}
var
  I: Integer;
begin
  AErrorText := '';
  if fLibrary <> dynlibs.NilHandle then Exit(True);
  for I := Low(CLibraryNames) to High(CLibraryNames) do
  begin
    fLibrary := LoadLibrary(CLibraryNames[I]);
    if fLibrary <> dynlibs.NilHandle then Break;
  end;
  if fLibrary = dynlibs.NilHandle then
  begin
    AErrorText := 'PortAudio V19 library was not found';
    Exit(False);
  end;
  Result := LoadProc('Pa_Initialize', Initialize) and
    LoadProc('Pa_Terminate', Terminate) and
    LoadProc('Pa_OpenDefaultStream', OpenDefaultStream) and
    LoadProc('Pa_OpenStream', OpenStream) and
    LoadProc('Pa_GetDeviceCount', GetDeviceCount) and
    LoadProc('Pa_GetDefaultOutputDevice', GetDefaultOutputDevice) and
    LoadProc('Pa_GetDeviceInfo', GetDeviceInfo) and
    LoadProc('Pa_CloseStream', CloseStream) and
    LoadProc('Pa_StartStream', StartStream) and
    LoadProc('Pa_StopStream', StopStream) and
    LoadProc('Pa_AbortStream', AbortStream) and
    LoadProc('Pa_WriteStream', WriteStream) and
    LoadProc('Pa_GetErrorText', GetErrorText);
  if not Result then
  begin
    AErrorText := 'PortAudio V19 library has an incomplete API';
    Unload;
  end;
end;

procedure TRecorderPortAudioApi.Unload;
begin
  if fLibrary <> dynlibs.NilHandle then FreeLibrary(fLibrary);
  fLibrary := dynlibs.NilHandle;
  Pointer(Initialize) := nil;
  Pointer(Terminate) := nil;
  Pointer(OpenDefaultStream) := nil;
  Pointer(OpenStream) := nil;
  Pointer(GetDeviceCount) := nil;
  Pointer(GetDefaultOutputDevice) := nil;
  Pointer(GetDeviceInfo) := nil;
  Pointer(CloseStream) := nil;
  Pointer(StartStream) := nil;
  Pointer(StopStream) := nil;
  Pointer(AbortStream) := nil;
  Pointer(WriteStream) := nil;
  Pointer(GetErrorText) := nil;
end;

function TRecorderPortAudioApi.ErrorText(AError: TPaError): string;
var
  lText: PChar;
begin
  Result := 'PortAudio error ' + IntToStr(AError);
  if not Assigned(GetErrorText) then Exit;
  lText := GetErrorText(AError);
  if lText <> nil then Result := StrPas(lText);
end;

end.

