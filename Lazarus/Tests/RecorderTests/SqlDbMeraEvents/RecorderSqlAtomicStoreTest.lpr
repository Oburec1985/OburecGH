program RecorderSqlAtomicStoreTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses Classes, SysUtils, IniFiles, Process, uRecorderSqlRevision,
  uRecorderSqlAtomicStore
  {$ifdef unix}, BaseUnix{$endif};

var
  gExternalFile: string;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure FailBeforeReplace;
begin
  raise Exception.Create('Injected failure before atomic replacement');
end;

procedure ExternalWriteBeforeReplace;
var
  lText: TStringList;
begin
  lText := TStringList.Create;
  try
    lText.LoadFromFile(gExternalFile);
    lText.Add('; external writer updated this file');
    lText.SaveToFile(gExternalFile);
  finally
    lText.Free;
  end;
end;

function Endpoint(const AHost: string): TRecorderSqlEndpoint;
begin
  Result.Backend := 'firebird';
  Result.RootDirectory := '/storage';
  Result.Database := '/storage/recorder.fdb';
  Result.Host := AHost;
  Result.Port := 3050;
  Result.TlsRequired := False;
end;

function ReadFileText(const AFileName: string): string;
var
  lText: TStringList;
begin
  lText := TStringList.Create;
  try lText.LoadFromFile(AFileName); Result := lText.Text;
  finally lText.Free; end;
end;

procedure RunWriter;
var
  lDecision: TRecorderSqlRevisionDecision;
  lEndpoint: TRecorderSqlEndpoint;
begin
  lEndpoint := Endpoint(ParamStr(3));
  lDecision := RecorderSqlAtomicApply(ParamStr(2), ParamStr(3), 'rev-A',
    True, lEndpoint);
  if lDecision = srdApply then Halt(0);
  if lDecision = srdConflict then Halt(2);
  Halt(3);
end;

var
  lId: TGUID;
  lDir, lPath, lBefore, lSyncPath: string;
  lText: TStringList;
  lIni: TIniFile;
  lEndpoint: TRecorderSqlEndpoint;
  lFirst, lSecond: TProcess;
  lDecision: TRecorderSqlRevisionDecision;
  lFailed: Boolean;
  lFind: TSearchRec;
  {$ifdef unix}
  lStat: Stat;
  lLink: string;
  {$endif}
begin
  if (ParamCount = 3) and (ParamStr(1) = '--writer') then RunWriter;
  if (ParamCount = 2) and (ParamStr(1) = '--apply') then
  begin
    lEndpoint := Endpoint('test-host');
    if RecorderSqlAtomicApply(ParamStr(2), 'rev-A', '', True, lEndpoint) <>
       srdApply then Halt(4);
    Halt(0);
  end;
  CreateGUID(lId);
  lDir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-sql-cas-' + GUIDToString(lId);
  Check(ForceDirectories(lDir), 'cannot create test directory');
  lPath := IncludeTrailingPathDelimiter(lDir) + 'app.ini';
  lSyncPath := IncludeTrailingPathDelimiter(lDir) + 'sync.ini';
  try
    lText := TStringList.Create;
    try
      lText.Text := '[Other]' + LineEnding + 'Keep=unchanged' + LineEnding +
        '[SQLdbConnection]' + LineEnding + 'Host=old';
      lText.SaveToFile(lPath);
    finally lText.Free; end;
    {$ifdef unix}
    Check(fpChmod(PChar(lPath), &600) = 0, 'cannot restrict test INI');
    lLink := IncludeTrailingPathDelimiter(lDir) + 'link.ini';
    Check(fpSymlink(PChar(lPath), PChar(lLink)) = 0, 'cannot create test symlink');
    lFailed := False;
    try
      lEndpoint := Endpoint('rejected');
      RecorderSqlAtomicApply(lLink, 'rev-link', '', True, lEndpoint);
    except on E: Exception do lFailed := True; end;
    Check(lFailed, 'symlink source was accepted');
    Check(fpUnlink(PChar(lLink)) = 0, 'cannot remove test symlink');
    Check(fpLink(PChar(lPath), PChar(lLink)) = 0, 'cannot create test hard link');
    lFailed := False;
    try
      RecorderSqlAtomicApply(lPath, 'rev-link', '', True, lEndpoint);
    except on E: Exception do lFailed := True; end;
    Check(lFailed, 'hard-linked source was accepted');
    Check(fpUnlink(PChar(lLink)) = 0, 'cannot remove test hard link');
    Check(fpSymlink(PChar(lPath), PChar(lPath + '.sql-lock')) = 0,
      'cannot create test lock symlink');
    lFailed := False;
    try
      RecorderSqlAtomicApply(lPath, 'rev-link', '', True, lEndpoint);
    except on E: Exception do lFailed := True; end;
    Check(lFailed, 'symlink lock was accepted');
    Check(fpUnlink(PChar(lPath + '.sql-lock')) = 0, 'cannot remove lock symlink');
    {$endif}
    lBefore := ReadFileText(lPath);
    lEndpoint := Endpoint('first-host');
    lFailed := False;
    try
      RecorderSqlAtomicApply(lPath, 'rev-A', '', True, lEndpoint,
        @FailBeforeReplace);
    except
      on E: Exception do lFailed := Pos('Injected failure', E.Message) > 0;
    end;
    Check(lFailed, 'before-rename fault was not propagated');
    Check(ReadFileText(lPath) = lBefore, 'failed update changed original file');
    if FindFirst(IncludeTrailingPathDelimiter(lDir) + '.sql-config-*.tmp',
      faAnyFile, lFind) = 0 then
    begin
      FindClose(lFind);
      raise Exception.Create('failed write left a temporary configuration');
    end;
    gExternalFile := lPath;
    lFailed := False;
    try
      RecorderSqlAtomicApply(lPath, 'rev-A', '', True, lEndpoint,
        @ExternalWriteBeforeReplace);
    except
      on E: Exception do lFailed := Pos('changed while preparing', E.Message) > 0;
    end;
    Check(lFailed, 'uncooperative concurrent writer was not detected');
    Check(Pos('external writer updated', ReadFileText(lPath)) > 0,
      'uncooperative writer changes were overwritten');
    lText := TStringList.Create;
    try
      lText.Text := lBefore;
      lText.SaveToFile(lPath);
    finally lText.Free; end;
    lDecision := RecorderSqlAtomicApply(lPath, 'rev-A', '', True, lEndpoint);
    Check(lDecision = srdApply, 'initial write failed');
    {$ifdef unix}
    Check(fpStat(PChar(lPath), lStat) = 0, 'cannot inspect INI permissions');
    Check((lStat.st_mode and &777) = &600, 'INI permissions changed');
    {$endif}
    Check(RecorderSqlAtomicApply(lPath, 'rev-A', '', True, lEndpoint) =
      srdAlreadyApplied, 'repeated write was not idempotent');
    lText := TStringList.Create;
    try
      lText.Text := '[Other]' + LineEnding + 'Keep=unchanged';
      lText.SaveToFile(lSyncPath);
    finally lText.Free; end;
    lFailed := False;
    try
      RecorderSqlAtomicApply(lSyncPath, 'rev-sync', '', True, lEndpoint,
        nil, @FailBeforeReplace);
    except
      on E: ERecorderSqlCommitUncertain do lFailed := True;
    end;
    Check(lFailed, 'post-rename sync failure was not marked commit-uncertain');
    Check(RecorderSqlAtomicApply(lSyncPath, 'rev-sync', '', True, lEndpoint) =
      srdAlreadyApplied, 'retry after uncertain commit was not idempotent');
    lIni := TIniFile.Create(lPath);
    try
      Check(lIni.ReadString('Other', 'Keep', '') = 'unchanged',
        'unrelated INI section was lost');
      Check(lIni.ReadString('SQLdbConnection', 'Revision', '') = 'rev-A',
        'revision was not persisted');
    finally lIni.Free; end;

    lFirst := TProcess.Create(nil);
    lSecond := TProcess.Create(nil);
    try
      lFirst.Executable := ParamStr(0);
      lFirst.Parameters.Add('--writer'); lFirst.Parameters.Add(lPath);
      lFirst.Parameters.Add('rev-B');
      lSecond.Executable := ParamStr(0);
      lSecond.Parameters.Add('--writer'); lSecond.Parameters.Add(lPath);
      lSecond.Parameters.Add('rev-C');
      lFirst.Execute; lSecond.Execute;
      lFirst.WaitOnExit; lSecond.WaitOnExit;
      Check(((lFirst.ExitStatus = 0) and (lSecond.ExitStatus = 2)) or
        ((lFirst.ExitStatus = 2) and (lSecond.ExitStatus = 0)),
        'two concurrent writers did not produce one winner and one conflict');
    finally lSecond.Free; lFirst.Free; end;
    lIni := TIniFile.Create(lPath);
    try
      Check((lIni.ReadString('SQLdbConnection', 'Revision', '') = 'rev-B') or
        (lIni.ReadString('SQLdbConnection', 'Revision', '') = 'rev-C'),
        'winning revision not preserved on reopen');
      Check(lIni.ReadString('SQLdbConnection', 'Host', '') =
        lIni.ReadString('SQLdbConnection', 'Revision', ''),
        'endpoint and revision were not persisted together');
    finally lIni.Free; end;
    WriteLn('OK: SQL endpoint atomic CAS');
  finally
    DeleteFile(lSyncPath + '.sql-lock');
    DeleteFile(lSyncPath);
    DeleteFile(lPath + '.sql-lock');
    DeleteFile(lPath);
    RemoveDir(lDir);
  end;
end.
