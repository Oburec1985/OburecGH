unit ULogger;

{$mode ObjFPC}{$H+}{$codepage UTF8}

interface

uses
 windows, classes, SysUtils, syncobjs, LazUTF8;

const
LOG_PATH = 'c:\mera files\modbuslog.txt';

type

 { TLogger }

 TLogger = class(TObject)

   private
   fCS: TCriticalSection;
   fPath: string;
   function getPath: string;
   function IsFileInUse(const FileName: string): Boolean;
   procedure setPath(AValue: string);
   constructor Create;
   public

   class function getInstance(PathToLog: string): TLogger;
   destructor Destroy; override;
   property Path: string read getPath write setPath;
   procedure LogMsg(msg: string);
 end;

implementation

var
   CritSec: TCriticalSection;
   Logger: TLogger = nil;

function TLogger.getPath: string;
begin
  fCS.Enter;
  result := fPath;
  fCS.Leave;
end;

procedure TLogger.setPath(AValue: string);
begin
  fCS.Enter;
  fPath := AValue;
  fCS.Leave;
end;

constructor TLogger.Create;
begin
  inherited Create;
  fCS := TCriticalSection.Create;
end;

class function TLogger.getInstance(PathToLog: string): TLogger;
begin
  CritSec.Enter;
  if not Assigned(Logger) then
    Logger := TLogger.Create;

  Logger.Path := PathToLog;
  result := Logger;
  CritSec.Leave;
end;

destructor TLogger.Destroy;
begin
  FreeAndNil(fCS);
  inherited Destroy;
end;

function TLogger.IsFileInUse(const FileName: string): Boolean;
var
  HFileRes: THandle;
begin
  Result := False;
  if not FileExists(FileName) then
    Exit;

  HFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;

procedure TLogger.LogMsg(msg: string);
var
  f: TFileStream;
  s: string;
begin
  f := nil;
  fCS.Enter;
  try
  if not fileExists(fPath) then
    f := TFileStream.Create(fPath, fmCreate)
  else
    if not IsFileInUse(fPath) then
    begin
    f := TFileStream.Create(fPath, fmOpenReadWrite or fmShareDenyNone);
    f.Position := f.Size;
    //s := UTF8ToWinCP(format('%s: %s', [DateTimeToStr(now), msg]) + #13);
    s := format('%s: %s', [DateTimeToStr(now), msg]) + #13;
    f.WriteBuffer(s[1], length(s) * sizeOf(char));
    end;
  if Assigned(f) then FreeAndNil(f);
  except

  end;
  fCS.Leave;

end;

initialization
  CritSec := TCriticalSection.Create;

finalization
   FreeAndNil(Logger);
   FreeAndNil(CritSec);
end.

