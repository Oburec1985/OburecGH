unit uRecorderSingleInstance;

{$mode objfpc}{$H+}

interface

type
  TRecorderSingleInstance = class
  private
    {$IFDEF MSWINDOWS}
    fHandle: THandle;
    {$ELSE}
    fHandle: LongInt;
    {$ENDIF}
    fAcquired: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property Acquired: Boolean read fAcquired;
  end;

function RecorderAllowsMultipleInstances: Boolean;

implementation

uses
  SysUtils, IniFiles, uRecorderMeraPaths
  {$IFDEF MSWINDOWS}, Windows{$ELSE}, BaseUnix{$ENDIF};

const
  CRecorderInstanceName = 'Mera.RecorderLnx';
  CApplicationSection = 'Application';
  CAllowMultipleInstancesKey = 'AllowMultipleInstances';
  {$IFNDEF MSWINDOWS}
  CLockExclusive = 2;
  CLockNonBlocking = 4;
  CLockUnlock = 8;
  {$ENDIF}

{$IFNDEF MSWINDOWS}
function UnixFlock(AHandle, AOperation: cint): cint;
  cdecl; external 'c' name 'flock';
{$ENDIF}

function RecorderAllowsMultipleInstances: Boolean;
var
  lFileName: string;
  lIni: TIniFile;
begin
  Result := False;
  lFileName := RecorderAppConfigFileName;
  if not FileExists(lFileName) then
    Exit;

  lIni := TIniFile.Create(lFileName);
  try
    Result := lIni.ReadBool(CApplicationSection,
      CAllowMultipleInstancesKey, False);
  finally
    lIni.Free;
  end;
end;

constructor TRecorderSingleInstance.Create;
{$IFNDEF MSWINDOWS}
var
  lLockPath: string;
{$ENDIF}
begin
  inherited Create;
  {$IFDEF MSWINDOWS}
  fHandle := CreateMutex(nil, True, 'Global\' + CRecorderInstanceName);
  fAcquired := (fHandle <> 0) and (GetLastError <> ERROR_ALREADY_EXISTS);
  {$ELSE}
  fHandle := -1;
  lLockPath := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'mera-recorderlnx.lock';
  fHandle := fpOpen(PChar(lLockPath), O_CREAT or O_RDWR, &600);
  fAcquired := (fHandle >= 0) and
    (UnixFlock(fHandle, CLockExclusive or CLockNonBlocking) = 0);
  {$ENDIF}
end;

destructor TRecorderSingleInstance.Destroy;
begin
  {$IFDEF MSWINDOWS}
  if fHandle <> 0 then
    CloseHandle(fHandle);
  {$ELSE}
  if fHandle >= 0 then
  begin
    if fAcquired then
      UnixFlock(fHandle, CLockUnlock);
    fpClose(fHandle);
  end;
  {$ENDIF}
  inherited Destroy;
end;

end.
