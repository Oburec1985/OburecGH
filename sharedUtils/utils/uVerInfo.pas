unit uVerInfo;

interface

function vGetInfo(fileName: string): boolean;
function vQueryValue(name: string): string;
function vComments: string;
function vCompanyName: string;
function vFileDescription: string;
function vFileVersion: string;
function vInternalName: string;
function vLegalCopyright: string;
function vOriginalFilename: string;
function vProductName: string;
function vProductVersion: string;

implementation

uses windows, sysutils;

var
  infoSize: dword;
  info: pointer;
  p: pointer;
  len: cardinal;
  langStr: string[8];

function vGetInfo(fileName: string): boolean;
var
  handle: cardinal;
begin
  infoSize:= GetFileVersionInfoSize(pchar(fileName), handle);
  result:= infoSize > 0;
  if result then begin
    getMem(info, infoSize);
    win32check(GetFileVersionInfo(pchar(fileName),
     handle, infoSize, info));
    p:= nil; len:= 0;
    VerQueryValue(info, '\VarFileInfo\Translation', p, len);
    langStr:= intToHex(integer(p^) and $FFFF, 4) +
              intToHex((integer(p^) and $FFFF0000) shr 16, 4);
  end
end;

function vQueryValue(name: string): string;
begin
  p:= nil; len:= 0;
  if (infoSize=0) or
     (not VerQueryValue(info, pchar('\StringFileInfo\'+langStr+'\'+name), p, len)) or
     (len = 0)
  then result:= ''
  else result:= pchar(p);
end;

function vComments: string;
begin result:= vQueryValue('Comments'); end;

function vCompanyName: string;
begin result:= vQueryValue('CompanyName'); end;

function vFileDescription: string;
begin result:= vQueryValue('FileDescription'); end;

function vFileVersion: string;
begin result:= vQueryValue('FileVersion'); end;

function vInternalName: string;
begin result:= vQueryValue('InternalName'); end;

function vLegalCopyright: string;
begin result:= vQueryValue('LegalCopyright'); end;

function vOriginalFilename: string;
begin result:= vQueryValue('OriginalFilename'); end;

function vProductName: string;
begin result:= vQueryValue('ProductName'); end;

function vProductVersion: string;
begin result:= vQueryValue('ProductVersion'); end;


initialization
  infoSize:= 0;
finalization
  FreeMem(info, infoSize);
end.
