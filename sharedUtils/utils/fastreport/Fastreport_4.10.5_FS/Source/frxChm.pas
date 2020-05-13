
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Chm help viewer              }
{                                          }
{         Copyright (c) 1998-2008          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxChm;

interface

{$I frx.inc}

uses Windows, Graphics;

procedure frxDisplayHHTopic(Handle: THandle; const topic: String);


implementation

const
  HH_DISPLAY_TOPIC  = $0000;
  HH_DISPLAY_TOC    = $0001;

type
  THtmlHelpA = function(hwndCaller: THandle; pszFile: PAnsiChar;
    uCommand: Cardinal; dwData: Longint): THandle; stdcall;
{$IFDEF Delphi12}
  THtmlHelpW = function(hwndCaller: THandle; pszFile: PWideChar;
    uCommand: Cardinal; dwData: Longint): THandle; stdcall;
{$ENDIF}


var
{$IFDEF Delphi12}
  HtmlHelpW: THtmlHelpW = nil;
{$ELSE}
  HtmlHelpA: THtmlHelpA = nil;
{$ENDIF}

  OCXHandle: THandle = 0;

function HtmlHelpInstalled: Boolean;
begin
{$IFDEF Delphi12}
  Result := (Assigned(HtmlHelpW));
{$ELSE}
  Result := (Assigned(HtmlHelpA));
{$ENDIF}
end;

procedure frxDisplayHHTopic(Handle: THandle; const topic: String);
begin
{$IFDEF Delphi12}
  if (Assigned(HtmlHelpW)) then
    HtmlHelpW(Handle, PChar(topic), HH_DISPLAY_TOC, 0);
{$ELSE}
  if (Assigned(HtmlHelpA)) then
    HtmlHelpA(Handle, PChar(topic), HH_DISPLAY_TOC, 0);
{$ENDIF}

end;


initialization
{$IFDEF Delphi12}
  HtmlHelpW := nil;
{$ELSE}
  HtmlHelpA := nil;
{$ENDIF}
  OCXHandle := LoadLibrary('HHCtrl.OCX');
  if (OCXHandle <> 0) then
  {$IFDEF Delphi12}
      HtmlHelpW := GetProcAddress(OCXHandle, 'HtmlHelpW');
  {$ELSE}
      HtmlHelpA := GetProcAddress(OCXHandle, 'HtmlHelpA');
  {$ENDIF}

finalization
  if (OCXHandle <> 0) then
    FreeLibrary(OCXHandle);
end.


