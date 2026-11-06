unit uLinuxSetupManagerShareConfig;

{$mode objfpc}{$H+}
{$codepage UTF8}

// Pure Samba configuration inspection/editing. Effective settings come from
// testparm; mutations preserve unrelated text in the main smb.conf only.
interface

uses Classes, fpjson;

function SambaSectionRange(Lines: TStrings; const Name: string;
  out First, Last: Integer): Boolean;
function SambaShareNameValid(const Name: string): Boolean;
function SambaShareList(const EffectiveConfig, RawConfig, Fstab: string): TJSONArray;
function EditSambaShare(const Config, Name, Path, Users: string;
  Writable, DeleteShare: Boolean; out Updated, ErrorText: string): Boolean;

implementation

uses SysUtils;

function SambaShareNameValid(const Name: string): Boolean;
var lIndex: Integer;
begin
  Result := (Name <> '') and (Name = Trim(Name)) and (Name <> '.') and
    (Name <> '..') and (Pos('/', Name) = 0) and (Pos('\', Name) = 0) and
    (Pos('[', Name) = 0) and (Pos(']', Name) = 0);
  if not Result then Exit;
  for lIndex := 1 to Length(Name) do
    if (Ord(Name[lIndex]) < 32) or (Ord(Name[lIndex]) = 127) then Exit(False);
end;

function SectionName(const Line: string): string;
var lText: string;
begin
  Result := '';
  lText := Trim(Line);
  if (Length(lText) > 2) and (lText[1] = '[') and
    (lText[Length(lText)] = ']') then
    Result := Trim(Copy(lText, 2, Length(lText) - 2));
end;

function SambaSectionRange(Lines: TStrings; const Name: string;
  out First, Last: Integer): Boolean;
var lIndex: Integer; lName: string; lClosed: Boolean;
begin
  First := -1;
  Last := -1;
  lClosed := False;
  for lIndex := 0 to Lines.Count - 1 do
  begin
    lName := SectionName(Lines[lIndex]);
    if lName = '' then Continue;
    if SameText(lName, Name) and (First >= 0) then
    begin First := -1; Last := -1; Exit(False); end;
    if (First >= 0) and not lClosed then
    begin Last := lIndex - 1; lClosed := True; end;
    if SameText(lName, Name) then First := lIndex;
  end;
  if (First >= 0) and (Last < 0) then Last := Lines.Count - 1;
  Result := First >= 0;
end;

function StaticShareEditable(Lines: TStrings; const Name, Path: string): Boolean;
var lFirst, lLast, lIndex, lSeparator: Integer; lText, lKey: string;
begin
  Result := False;
  if not SambaSectionRange(Lines, Name, lFirst, lLast) or
    (Pos('%', Path) > 0) or SameText(Name, 'homes') or
    not SambaShareNameValid(Name) then Exit;
  for lIndex := lFirst + 1 to lLast do
  begin
    lText := Trim(Lines[lIndex]);
    lSeparator := Pos('=', lText);
    if lSeparator < 2 then Continue;
    lKey := LowerCase(Trim(Copy(lText, 1, lSeparator - 1)));
    if (lKey = 'include') or (lKey = 'copy') then Exit;
  end;
  Result := True;
end;

function SmbBool(const Value: string; Default: Boolean): Boolean;
begin
  if SameText(Value, 'yes') or SameText(Value, 'true') or (Value = '1') then
    Exit(True);
  if SameText(Value, 'no') or SameText(Value, 'false') or (Value = '0') then
    Exit(False);
  Result := Default;
end;

function ManagedSource(Lines: TStrings; const Name: string): string;
var lIndex, lSpace: Integer; lText: string;
begin
  Result := '';
  for lIndex := 0 to Lines.Count - 1 do
  begin
    lText := Trim(Lines[lIndex]);
    if (lText = '') or (lText[1] = '#') then Continue;
    if Pos(' # recorderlnx-share-' + Name + '-bind', lText) = 0 then Continue;
    lSpace := Pos(' ', lText);
    Result := StringReplace(Copy(lText, 1, lSpace - 1), '\040', ' ', [rfReplaceAll]);
    Exit;
  end;
end;

function SambaShareList(const EffectiveConfig, RawConfig, Fstab: string): TJSONArray;
var
  lEffective, lRaw, lFstab, lValues, lDefaults: TStringList;
  lIndex, lSeparator: Integer; lName, lText, lKey, lValue: string;

  procedure AddShare;
  var lPath, lSource: string;
    lItem: TJSONObject; lManaged, lEditable: Boolean;
  begin
    if (lName = '') or SameText(lName, 'global') then Exit;
    lPath := lValues.Values['path'];
    if (lPath = '') or SmbBool(lValues.Values['printable'], False) then Exit;
    lManaged := (Pos('# RECORDERLNX-SHARE-' + lName + '-BEGIN', RawConfig) > 0) and
      (Pos('# RECORDERLNX-SHARE-' + lName + '-END', RawConfig) > 0);
    lSource := ManagedSource(lFstab, lName);
    lEditable := StaticShareEditable(lRaw, lName, lPath);
    lItem := TJSONObject.Create;
    lItem.Add('name', lName);
    if lManaged and (lSource <> '') then lItem.Add('path', lSource)
    else lItem.Add('path', lPath);
    lItem.Add('mount', lPath);
    lItem.Add('writable', not SmbBool(lValues.Values['read only'], True));
    lItem.Add('managed', lManaged);
    lItem.Add('editable', lEditable);
    lItem.Add('users', lValues.Values['valid users']);
    if lEditable then lItem.Add('edit_reason', '')
    else lItem.Add('edit_reason', 'Ресурс задан через include/copy, повторную секцию или динамический путь.');
    Result.Add(lItem);
  end;

begin
  Result := TJSONArray.Create;
  lEffective := TStringList.Create;
  lRaw := TStringList.Create;
  lFstab := TStringList.Create;
  lValues := TStringList.Create;
  lDefaults := TStringList.Create;
  try
   try
    lEffective.Text := EffectiveConfig;
    lRaw.Text := RawConfig;
    lFstab.Text := Fstab;
    lName := '';
    for lIndex := 0 to lEffective.Count - 1 do
    begin
      lText := Trim(lEffective[lIndex]);
      if SectionName(lText) <> '' then
      begin
        AddShare;
        if SameText(lName, 'global') then lDefaults.Assign(lValues);
        lName := SectionName(lText);
        lValues.Assign(lDefaults);
        Continue;
      end;
      if lName = '' then Continue; // Ignore testparm diagnostics before config.
      lSeparator := Pos('=', lText);
      if lSeparator < 2 then Continue;
      lKey := LowerCase(Trim(Copy(lText, 1, lSeparator - 1)));
      lValue := Trim(Copy(lText, lSeparator + 1, MaxInt));
      if lKey = 'writeable' then lKey := 'writable';
      if lKey = 'writable' then
      begin
        lKey := 'read only';
        if SmbBool(lValue, False) then lValue := 'no' else lValue := 'yes';
      end;
      if lKey = 'print ok' then lKey := 'printable';
      lValues.Values[lKey] := lValue;
    end;
    AddShare;
  except
    Result.Free;
    raise;
  end;
  finally
    lDefaults.Free;
    lValues.Free;
    lFstab.Free;
    lRaw.Free;
    lEffective.Free;
  end;
end;

function EditSambaShare(const Config, Name, Path, Users: string;
  Writable, DeleteShare: Boolean; out Updated, ErrorText: string): Boolean;
var lLines: TStringList; lFirst, lLast, lIndex, lSeparator: Integer;
  lKey, lText: string;
begin
  Result := False;
  Updated := '';
  ErrorText := '';
  lLines := TStringList.Create;
  try
    lLines.Text := Config;
    if not SambaShareNameValid(Name) or
      not SambaSectionRange(lLines, Name, lFirst, lLast) or
      SameText(Name, 'global') or SameText(Name, 'homes') then
    begin ErrorText := 'Обычная секция ресурса не найдена в основном smb.conf.'; Exit; end;
    for lIndex := lLast downto lFirst do
    begin
      if DeleteShare then begin lLines.Delete(lIndex); Continue; end;
      lText := Trim(lLines[lIndex]);
      lSeparator := Pos('=', lText);
      if lSeparator < 2 then Continue;
      lKey := LowerCase(Trim(Copy(lText, 1, lSeparator - 1)));
      if (lKey = 'path') or (lKey = 'read only') or (lKey = 'writable') or
        (lKey = 'writeable') or (lKey = 'valid users') then lLines.Delete(lIndex);
    end;
    if not DeleteShare then
    begin
      SambaSectionRange(lLines, Name, lFirst, lLast);
      lLines.Insert(lFirst + 1, '   path = ' + Path);
      if Writable then lText := 'no' else lText := 'yes';
      lLines.Insert(lFirst + 2, '   read only = ' + lText);
      lLines.Insert(lFirst + 3, '   valid users = ' + Users);
    end;
    Updated := lLines.Text;
    Result := True;
  finally lLines.Free; end;
end;

end.
