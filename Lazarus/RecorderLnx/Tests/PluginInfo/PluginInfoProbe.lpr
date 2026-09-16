program PluginInfoProbe;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, uRecorderPluginInfo, uRecorderPluginApi;

var
  lCatalog: TRecorderPluginCatalog;
  lDirectory: string;
  I: Integer;
  lFound: Boolean;
  lLog: TStringList;
begin
  if SizeOf(TRecorderPluginInfo) <> 512 then
    Halt(2);
  if ParamCount > 0 then
    lDirectory := ParamStr(1)
  else
    lDirectory := RecorderPluginDirectory;
  lCatalog := TRecorderPluginCatalog.Create;
  lLog := TStringList.Create;
  try
    lCatalog.Scan(lDirectory);
    lFound := False;
    for I := 0 to lCatalog.Count - 1 do
    begin
      lLog.Add(ExtractFileName(lCatalog.Entries[I].FileName) + ': ' +
        lCatalog.Entries[I].Name + ' | ' +
        lCatalog.Entries[I].ErrorText);
      WriteLn(ExtractFileName(lCatalog.Entries[I].FileName), ': ',
        lCatalog.Entries[I].Name, ' | ',
        lCatalog.Entries[I].ErrorText);
      if SameText(lCatalog.Entries[I].Name, 'SampleInfoPlugin') and
        lCatalog.Entries[I].IsValid and
        (lCatalog.Entries[I].PluginType = PLUGIN_CLASS) and
        (lCatalog.Entries[I].Version = 1) then
        lFound := True;
    end;
    if lFound then
      lLog.Add('RESULT PluginInfo passed')
    else
      lLog.Add('RESULT PluginInfo failed');
    lLog.SaveToFile(ChangeFileExt(ParamStr(0), '.log'));
    WriteLn(lLog[lLog.Count - 1]);
    if not lFound then
      Halt(1);
  finally
    lLog.Free;
    lCatalog.Free;
  end;
end.
