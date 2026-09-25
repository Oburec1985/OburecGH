unit uRecorderSvgParameters;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

function LoadSvgText(const AFileName: string): string;
procedure ExtractSvgParameters(const AFileName: string; ADest: TStrings);
function ReplaceSvgParameter(const ASource, AName, AValue: string): string;

implementation

function LoadSvgText(const AFileName: string): string;
var
  lStream: TFileStream;
  lBytes: RawByteString;
begin
  Result := '';
  if not FileExists(AFileName) then
    Exit;
  lStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(lBytes, lStream.Size);
    if Length(lBytes) > 0 then
      lStream.ReadBuffer(lBytes[1], Length(lBytes));
    Result := string(lBytes);
  finally
    lStream.Free;
  end;
end;

procedure ExtractSvgParameters(const AFileName: string; ADest: TStrings);
var
  lSource, lName: string;
  lOpenPos, lClosePos, lSearchPos: SizeInt;
begin
  if ADest = nil then
    Exit;
  lSource := LoadSvgText(AFileName);
  lSearchPos := 1;
  while lSearchPos <= Length(lSource) do
  begin
    lOpenPos := Pos('{{', lSource, lSearchPos);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos('}}', lSource, lOpenPos + 2);
    if lClosePos = 0 then
      Exit;
    lName := Trim(Copy(lSource, lOpenPos + 2, lClosePos - lOpenPos - 2));
    if (lName <> '') and (ADest.IndexOf(lName) < 0) then
      ADest.Add(lName);
    lSearchPos := lClosePos + 2;
  end;
end;

function ReplaceSvgParameter(const ASource, AName, AValue: string): string;
begin
  Result := StringReplace(ASource, '{{' + AName + '}}', AValue,
    [rfReplaceAll]);
end;

end.
