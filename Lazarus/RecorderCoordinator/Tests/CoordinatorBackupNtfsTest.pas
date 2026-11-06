program CoordinatorBackupNtfsTest;
{$mode objfpc}{$H+}
{$codepage UTF8}
uses {$IFDEF UNIX}cwstring,{$ENDIF} Classes, SysUtils, IniFiles, uCoordinatorBackup;

procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;

var
  lHost: TBackupHost;
  lSource, lDest, lReport: string;
  lFile: TStringList;
  lSearch: TSearchRec;
  lCount: Integer;
  lSnapshot, lContent: string;
  lIni: TIniFile;
begin
  Check(ParamCount = 2, 'Pass isolated new source and existing NTFS destination');
  lSource := ExpandFileName(ParamStr(1));
  lDest := ExpandFileName(ParamStr(2));
  Check(not DirectoryExists(lSource), 'Source must not exist');
  Check(DirectoryExists(lDest), 'Destination must exist');
  Check(ForceDirectories(lSource), 'Create isolated source');
  lFile := TStringList.Create;
  try
    lFile.Text := 'test-recorder-binary';
    lFile.SaveToFile(IncludeTrailingPathDelimiter(lSource) + 'RecorderLnx');
    lHost.DisplayName := 'KIP-NTFS-TEST';
    lHost.ProgramRoot := lSource;
    Check(BackupRecorderHost(lDest, lHost, [boProgram], lReport), lReport);
    Check(Pos('могут быть доступны', lReport) > 0, 'Permission warning missing');
    Check(BackupRecorderHost(lDest, lHost, [boProgram], lReport), lReport);
    lCount := 0;
    if FindFirst(IncludeTrailingPathDelimiter(lDest) + 'KIP-NTFS-TEST/*',
       faDirectory, lSearch) = 0 then
    try
      repeat
        if (lSearch.Name <> '.') and (lSearch.Name <> '..') and
           ((lSearch.Attr and faDirectory) <> 0) then
        begin
          Inc(lCount);
          lSnapshot := IncludeTrailingPathDelimiter(lDest) +
            'KIP-NTFS-TEST/' + lSearch.Name;
          Check(not FileExists(lSnapshot + '/.backup-incomplete'), 'Incomplete snapshot');
          lFile.LoadFromFile(lSnapshot + '/program/RecorderLnx');
          lContent := Trim(lFile.Text);
          Check(lContent = 'test-recorder-binary', 'Copied binary content differs');
          lIni := TIniFile.Create(lSnapshot + '/backup-info.ini');
          try
            Check(lIni.ReadString('Backup', 'AccessProtection', '') = 'filesystem-managed',
              'Filesystem-managed permissions not recorded');
          finally lIni.Free; end;
        end;
      until FindNext(lSearch) <> 0;
    finally FindClose(lSearch); end;
    Check(lCount = 2, 'Repeat must retain both snapshots');
    WriteLn('OK: NTFS backup with filesystem-managed permission warning');
  finally lFile.Free; end;
end.
