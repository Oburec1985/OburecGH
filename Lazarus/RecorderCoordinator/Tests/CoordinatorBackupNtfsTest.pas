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
begin
  Check(ParamCount = 2, 'Pass isolated new source and existing NTFS destination');
  lSource := ExpandFileName(ParamStr(1));
  lDest := ExpandFileName(ParamStr(2));
  Check(not DirectoryExists(lSource), 'Source must not exist');
  Check(DirectoryExists(lDest), 'Destination must exist');
  Check(ForceDirectories(lSource), 'Create isolated source');
  lFile := TStringList.Create;
  try
    Check(ForceDirectories(lSource + '/projects/active'), 'Create project fixture');
    lFile.LineBreak := #10;
    lFile.Text := '[Application]' + #10 + 'DefaultProjectConfigDir=/remote/projects/active';
    lFile.SaveToFile(lSource + '/app.ini');
    lFile.Text := '[Storage]' + #10 + 'MeraFilesPath=/remote/mera';
    lFile.SaveToFile(lSource + '/storage.ini');
    lFile.Text := '[BackupExport]' + #10 + 'State=ready' + #10 +
      'ProjectsRoot=/remote/projects' + #10 + 'RuntimeMeraRoot=/remote/mera' + #10 +
      'ProjectsGeneration=0123456789abcdef0123456789abcdef';
    lFile.SaveToFile(lSource + '/backup-export-info.ini');
    lFile.Text := '0123456789abcdef0123456789abcdef';
    lFile.SaveToFile(lSource + '/projects/.recorder-backup-export-0123456789abcdef0123456789abcdef');
    lFile.Text := '{}';
    lFile.SaveToFile(lSource + '/projects/active/config.json');
    lHost.DisplayName := 'KIP-NTFS-TEST';
    lHost.ConfigRoot := lSource;
    lHost.ConfigRootRemote := '/remote/app';
    SetLength(lHost.ConfigRoots, 1);
    lHost.ConfigRoots[0].SourcePath := lSource + '/projects';
    lHost.ConfigRoots[0].DestinationName := 'projects';
    Check(BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), lReport);
    Check(Pos('могут быть доступны', lReport) > 0, 'Permission warning missing');
    Check(BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), lReport);
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
          lFile.LoadFromFile(lSnapshot + '/configurations/projects/active/config.json');
          lContent := Trim(lFile.Text);
          Check(lContent = '{}', 'Copied project content differs');
          Check(FileExists(lSnapshot + '/configurations/app.ini'), 'Missing app.ini');
          Check(not FileExists(lSnapshot + '/backup-info.ini'), 'Extra metadata in snapshot');
        end;
      until FindNext(lSearch) <> 0;
    finally FindClose(lSearch); end;
    Check(lCount = 2, 'Repeat must retain both snapshots');
    WriteLn('OK: NTFS backup with filesystem-managed permission warning');
  finally lFile.Free; end;
end.
