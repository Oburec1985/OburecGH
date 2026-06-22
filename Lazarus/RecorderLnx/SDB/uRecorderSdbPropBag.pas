unit uRecorderSdbPropBag;

{
  Mera SDB property-bag XML (<cfg><pty n="..." t="30"><v><![CDATA[...]]></v></pty>).
  Numeric properties are often plain <v>0.5</v> without CDATA.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

type
  TSdbPropBag = class
  private
    fProps: TStringList;
    function FindIndex(const AName: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    function GetProp(const AName: string; const ADefault: string = ''): string;
    procedure SetProp(const AName: string; const AValue: string);
    function GetPropFloat(const AName: string; ADefault: Double): Double;
    procedure SetPropFloat(const AName: string; AValue: Double; ADigits: Integer = 6);
    property PropNames: TStringList read fProps;
  end;

implementation

uses
  StrUtils, uSharedStringEncoding;

function SdbExtractPtyName(const ABlock: string): string;
var
  lPos: Integer;
  lQuote: Char;
begin
  Result := '';
  lPos := PosEx('n=', LowerCase(ABlock));
  if lPos <= 0 then
    Exit;
  Inc(lPos, 2);
  while (lPos <= Length(ABlock)) and (ABlock[lPos] in [' ', #9]) do
    Inc(lPos);
  if lPos > Length(ABlock) then
    Exit;
  lQuote := ABlock[lPos];
  if not (lQuote in ['"', '''']) then
    Exit;
  Inc(lPos);
  if Pos(lQuote, ABlock, lPos) <= lPos then
    Exit;
  Result := Copy(ABlock, lPos, Pos(lQuote, ABlock, lPos) - lPos);
end;

function SdbExtractPtyValue(const AText: string; APtyStart: Integer): string;
var
  lBlock: string;
  lBlockEnd: Integer;
  lCdataEnd: Integer;
  lCdataStart: Integer;
  lVEnd: Integer;
  lVStart: Integer;
begin
  Result := '';
  lBlockEnd := PosEx('</pty>', AText, APtyStart);
  if lBlockEnd <= 0 then
    Exit;
  lBlock := Copy(AText, APtyStart, lBlockEnd - APtyStart);
  lVStart := PosEx('<v', lBlock);
  if lVStart <= 0 then
    Exit;
  lVStart := PosEx('>', lBlock, lVStart);
  if lVStart <= 0 then
    Exit;
  Inc(lVStart);
  lVEnd := PosEx('</v>', lBlock, lVStart);
  if lVEnd <= 0 then
    Exit;
  lBlock := Copy(lBlock, lVStart, lVEnd - lVStart);
  lCdataStart := Pos('<![CDATA[', lBlock);
  if lCdataStart > 0 then
  begin
    Inc(lCdataStart, Length('<![CDATA['));
    lCdataEnd := Pos(']]>', lBlock, lCdataStart);
    if lCdataEnd > 0 then
      Exit(Copy(lBlock, lCdataStart, lCdataEnd - lCdataStart));
  end;
  Result := Trim(lBlock);
end;

constructor TSdbPropBag.Create;
begin
  inherited Create;
  fProps := TStringList.Create;
  fProps.NameValueSeparator := '=';
  fProps.CaseSensitive := False;
  fProps.Sorted := False;
end;

destructor TSdbPropBag.Destroy;
begin
  fProps.Free;
  inherited Destroy;
end;

procedure TSdbPropBag.Clear;
begin
  fProps.Clear;
end;

function TSdbPropBag.FindIndex(const AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to fProps.Count - 1 do
    if SameText(fProps.Names[I], AName) then
      Exit(I);
end;

function TSdbPropBag.GetProp(const AName: string; const ADefault: string): string;
var
  lIndex: Integer;
begin
  lIndex := FindIndex(AName);
  if lIndex < 0 then
    Exit(ADefault);
  Result := fProps.ValueFromIndex[lIndex];
end;

procedure TSdbPropBag.SetProp(const AName: string; const AValue: string);
var
  lIndex: Integer;
begin
  lIndex := FindIndex(AName);
  if lIndex < 0 then
    fProps.Add(AName + '=' + AValue)
  else
    fProps.ValueFromIndex[lIndex] := AValue;
end;

function TSdbPropBag.GetPropFloat(const AName: string; ADefault: Double): Double;
var
  lText: string;
begin
  lText := StringReplace(GetProp(AName), ',', '.', [rfReplaceAll]);
  if not TryStrToFloat(lText, Result) then
    Result := ADefault;
end;

procedure TSdbPropBag.SetPropFloat(const AName: string; AValue: Double;
  ADigits: Integer);
begin
  SetProp(AName, FormatFloat('0.' + StringOfChar('0', ADigits), AValue));
end;

procedure TSdbPropBag.LoadFromFile(const AFileName: string);
var
  lBlockEnd: Integer;
  lName: string;
  lPos: Integer;
  lPtyStart: Integer;
  lText: string;
  lValue: string;
begin
  Clear;
  if not FileExists(AFileName) then
    Exit;
  lText := SharedLoadLegacyTextFile(AFileName);
  lPos := 1;
  while lPos <= Length(lText) do
  begin
    lPtyStart := PosEx('<pty', lText, lPos);
    if lPtyStart <= 0 then
      Break;
    lBlockEnd := PosEx('</pty>', lText, lPtyStart);
    if lBlockEnd <= 0 then
      Break;
    lName := SdbExtractPtyName(Copy(lText, lPtyStart, lBlockEnd - lPtyStart));
    if lName <> '' then
    begin
      lValue := SdbExtractPtyValue(lText, lPtyStart);
      SetProp(lName, lValue);
    end;
    lPos := lBlockEnd + Length('</pty>');
  end;
end;

procedure TSdbPropBag.SaveToFile(const AFileName: string);
var
  lLines: TStringList;
  I: Integer;
  lName: string;
  lValue: string;
begin
  lLines := TStringList.Create;
  try
    lLines.Add('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    lLines.Add('<cfg>');
    for I := 0 to fProps.Count - 1 do
    begin
      lName := fProps.Names[I];
      lValue := fProps.ValueFromIndex[I];
      lLines.Add(Format(#9'<pty n="%s" t="30">', [lName]));
      lLines.Add(#9#9'<v>');
      lLines.Add(#9#9#9'<![CDATA[' + lValue + ']]>');
      lLines.Add(#9#9'</v>');
      lLines.Add(#9'</pty>');
    end;
    lLines.Add('</cfg>');
    ForceDirectories(ExtractFileDir(AFileName));
    lLines.SaveToFile(AFileName);
  finally
    lLines.Free;
  end;
end;

end.
