unit uCoordinatorSingleInstance;

{$mode objfpc}{$H+}

interface

type
  TCoordinatorSingleInstance = class
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

implementation

{$IFDEF MSWINDOWS}
uses
  Windows;
{$ELSE}
uses
  BaseUnix;
{$ENDIF}

const
  CCoordinatorInstanceName = 'Mera.RCPanel';
  {$IFNDEF MSWINDOWS}
  CLockExclusive = 2;   { POSIX LOCK_EX }
  CLockNonBlocking = 4; { POSIX LOCK_NB }
  CLockUnlock = 8;      { POSIX LOCK_UN }
  {$ENDIF}

{$IFNDEF MSWINDOWS}
function UnixFlock(AHandle, AOperation: cint): cint;
  cdecl; external 'c' name 'flock';
{$ENDIF}

constructor TCoordinatorSingleInstance.Create;
{$IFNDEF MSWINDOWS}
var
  lLockPath: string;
{$ENDIF}
begin
  inherited Create;
  {$IFDEF MSWINDOWS}
  fHandle := CreateMutex(nil, True, 'Global\' + CCoordinatorInstanceName);
  fAcquired := (fHandle <> 0) and (GetLastError <> ERROR_ALREADY_EXISTS);
  {$ELSE}
  lLockPath := '/tmp/mera-rcpanel.lock';
  fHandle := fpOpen(PChar(lLockPath), O_CREAT or O_RDWR, &600);
  fAcquired := (fHandle >= 0) and
    (UnixFlock(fHandle, CLockExclusive or CLockNonBlocking) = 0);
  {$ENDIF}
end;

destructor TCoordinatorSingleInstance.Destroy;
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
