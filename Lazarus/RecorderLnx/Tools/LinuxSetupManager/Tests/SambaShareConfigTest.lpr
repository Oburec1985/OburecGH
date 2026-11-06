program SambaShareConfigTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses Classes, SysUtils, fpjson, uLinuxSetupManagerShareConfig;

procedure Check(Condition: Boolean; const MessageText: string);
begin
  if not Condition then raise Exception.Create(MessageText);
end;

function Row(Items: TJSONArray; const Name: string): TJSONObject;
var lIndex: Integer;
begin
  for lIndex := 0 to Items.Count - 1 do
    if TJSONObject(Items[lIndex]).Get('name', '') = Name then
      Exit(TJSONObject(Items[lIndex]));
  Result := nil;
end;

const
  CRaw = '[global]' + LineEnding + 'read only = no' + LineEnding +
    'valid users = @operators' + LineEnding +
    '[Obmen]' + LineEnding + 'path = /home/user/Обмен' + LineEnding +
    'force user = user' + LineEnding + 'create mask = 0660' + LineEnding +
    '[ReadOnly]' + LineEnding + 'path = /data/read' + LineEnding +
    'read only = yes' + LineEnding +
    '# RECORDERLNX-SHARE-Managed-BEGIN' + LineEnding +
    '[Managed]' + LineEnding + 'path = /srv/recorderlnx/Managed' + LineEnding +
    '# RECORDERLNX-SHARE-Managed-END' + LineEnding +
    '[printers]' + LineEnding + 'path = /var/tmp' + LineEnding +
    'printable = yes' + LineEnding +
    '[homes]' + LineEnding + 'path = /home/%S' + LineEnding;
  CEffective = 'Loaded services file OK.' + LineEnding + CRaw +
    '[Included]' + LineEnding + 'path = /other/data' + LineEnding;
  CFstab = '/data/my\040files /srv/recorderlnx/Managed none bind 0 0 # recorderlnx-share-Managed-bind';
var
  lItems: TJSONArray;
  lUpdated, lError: string;
begin
  SetMultiByteConversionCodePage(CP_UTF8);
  lItems := SambaShareList(CEffective, CRaw, CFstab);
  try
    Check(lItems.Count = 5, 'Only filesystem shares must be listed');
    Check(Row(lItems, 'Obmen') <> nil, 'Normal Obmen missing');
    Check(Row(lItems, 'Obmen').Get('path', string('')) = UTF8String('/home/user/Обмен'), 'UTF8 path');
    Check(Row(lItems, 'Obmen').Get('writable', False), 'Inherited write mode');
    Check(Row(lItems, 'Obmen').Get('users', '') = '@operators', 'Inherited users');
    Check(Row(lItems, 'Obmen').Get('editable', False), 'Direct share editable');
    Check(not Row(lItems, 'ReadOnly').Get('writable', True), 'Explicit readonly');
    Check(Row(lItems, 'Managed').Get('path', '') = '/data/my files', 'Bind source retained');
    Check(Row(lItems, 'Managed').Get('managed', False), 'Managed metadata');
    Check(not Row(lItems, 'Included').Get('editable', True), 'Included config protected');
    Check(not Row(lItems, 'homes').Get('editable', True), 'Dynamic homes protected');
    Check(Row(lItems, 'printers') = nil, 'Printer service excluded');
  finally lItems.Free; end;
  Check(EditSambaShare(CRaw, 'Obmen', '/data/new', 'user @staff', True,
    False, lUpdated, lError), lError);
  Check(Pos('path = /data/new', lUpdated) > 0, 'Path replaced');
  Check(Pos('force user = user', lUpdated) > 0, 'Unknown directives retained');
  Check(Pos('create mask = 0660', lUpdated) > 0, 'Masks retained');
  Check(Pos('valid users = user @staff', lUpdated) > 0, 'User/group list retained');
  Check(Pos('path = /data/read', lUpdated) > 0, 'Adjacent share unchanged');
  Check(EditSambaShare(CRaw, 'Obmen', '', '', False, True, lUpdated, lError), lError);
  Check(Pos('[Obmen]', lUpdated) = 0, 'Requested section removed');
  Check(Pos('[ReadOnly]', lUpdated) > 0, 'Other section retained after delete');
  lItems := SambaShareList('[Obmen]' + LineEnding + 'path=/a',
    '[Obmen]' + LineEnding + 'path=/a' + LineEnding + '[Obmen]' + LineEnding + 'path=/b', '');
  try Check(not Row(lItems, 'Obmen').Get('editable', True), 'Repeated section protected');
  finally lItems.Free; end;
  Check(SambaShareNameValid('Обмен с ПК'), 'Existing UTF8/spaces share name supported');
  Check(not SambaShareNameValid('bad' + #10 + '[global]'), 'Injected name rejected');
  Check(EditSambaShare('[Обмен с ПК]' + LineEnding + 'path=/data',
    'Обмен с ПК', '/data/new', '', True, False, lUpdated, lError), lError);
  Check(Pos('path = /data/new', lUpdated) > 0, 'UTF8/spaces section edited');
  WriteLn('RESULT SambaShareConfigTest passed');
end.
