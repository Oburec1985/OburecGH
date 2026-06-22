unit uRecorderSdbPropBag;

{
  Mera SDB property-bag XML (<cfg><pty n="..." t="30"><v><![CDATA[...]]></v></pty>).
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
  StrUtils;

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
  lLines: TStringList;
  lMarker: string;
  lName: string;
  lPos: Integer;
  lValue: string;
  I: Integer;
begin
  Clear;
  if not FileExists(AFileName) then
    Exit;
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(AFileName);
    for I := 0 to lLines.Count - 1 do
    begin
      if Pos('<pty n="', lLines[I]) <= 0 then
        Continue;
      lPos := Pos('"', lLines[I], 9);
      if lPos <= 0 then
        Continue;
      lName := Copy(lLines[I], 9, lPos - 9);
      if I + 2 >= lLines.Count then
        Break;
      lValue := Trim(lLines[I + 2]);
      if (Length(lValue) >= 13) and (Copy(lValue, 1, 9) = '<![CDATA[') and
        (Copy(lValue, Length(lValue) - 2, 3) = ']]>') then
        lValue := Copy(lValue, 10, Length(lValue) - 12);
      SetProp(lName, lValue);
    end;
  finally
    lLines.Free;
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
