unit uRecorderHostAgentBackup;
{$mode objfpc}{$H+}
{$codepage UTF8}
interface
uses SysUtils, uRecorderHostAgentConfig;
const CHostBackupLayout = 'active-project-v1';
function HostAgentPrepareBackup(AConfig: TRecorderHostAgentConfig; ACalibrations: Boolean;
  out ASnapshotId, ARelativePath, AProjectName, AMessage: string): Boolean;
function HostAgentVerifyBackup(AConfig:TRecorderHostAgentConfig; const AId:string; out AMessage:string):Boolean;
function HostAgentCleanupBackup(AConfig:TRecorderHostAgentConfig; const AId:string; out AMessage:string):Boolean;
implementation
uses Classes, IniFiles, SyncObjs {$ifdef unix}, BaseUnix{$endif};

const MaxStageBytes: Int64 = Int64(4)*1024*1024*1024;
      MaxSnapshots = 4;
var BackupLock:TCriticalSection; StageBytes:Int64;
procedure RemoveTree(const P:string); forward;

procedure RequireSafe(const P: string; ADirectory: Boolean);
{$ifdef unix}var S: Stat; Parent: string;{$endif}
begin
  {$ifdef unix}
  Parent:=ExtractFileDir(ExcludeTrailingPathDelimiter(P));
  if (Parent<>'') and (Parent<>P) then RequireSafe(Parent,True);
  if fpLStat(PChar(P), S) <> 0 then raise Exception.Create('Cannot inspect: ' + P);
  if FPS_ISLNK(S.st_mode) then raise Exception.Create('Symbolic link rejected: ' + P);
  if ADirectory and not FPS_ISDIR(S.st_mode) then raise Exception.Create('Not a directory: ' + P);
  if (not ADirectory) and not FPS_ISREG(S.st_mode) then raise Exception.Create('Not a regular file: ' + P);
  {$else}
  if ADirectory then begin if not DirectoryExists(P) then raise Exception.Create('Not a directory: ' + P); end
  else if not FileExists(P) then raise Exception.Create('Not a file: ' + P);
  {$endif}
end;

procedure SafeDir(const P: string);
begin
  if not DirectoryExists(P) then
    if not CreateDir(P) then raise Exception.Create('Cannot create directory: ' + P);
  RequireSafe(P, True);
end;

function ProgramFileForBackup(AConfig: TRecorderHostAgentConfig): string;
begin
  Result:=ExpandFileName(AConfig.RecorderPath);
  {$ifdef unix}
  if (Result='/usr/bin/recorderlnx') and
    FileExists('/opt/mera/RecorderLnx/RecorderLnx') then
    Result:='/opt/mera/RecorderLnx/RecorderLnx';
  {$endif}
end;

function IsAbsolutePath(const Value: string): Boolean;
begin
  {$ifdef windows}
  Result:=((Length(Value)>=3) and (Value[2]=':') and
    (Value[3] in ['\','/'])) or (Copy(Value,1,2)='\\');
  {$else}
  Result:=(Value<>'') and (Value[1]='/');
  {$endif}
end;

function ConfiguredMeraRoot(AConfig: TRecorderHostAgentConfig): string;
var PathsFile, ProgramDir, Value: string; Ini: TIniFile;
begin
  if AConfig=nil then raise Exception.Create('Missing configuration');
  ProgramDir:=ExtractFileDir(ProgramFileForBackup(AConfig));
  PathsFile:=IncludeTrailingPathDelimiter(ProgramDir)+'RecorderLnx.paths.ini';
  Result:=Trim(AConfig.BackupMeraRoot);
  if FileExists(PathsFile) then begin
    RequireSafe(PathsFile,False);
    Ini:=TIniFile.Create(PathsFile);
    try Value:=Trim(Ini.ReadString('Paths','MeraFiles','')); finally Ini.Free; end;
    if Value='' then begin
      Value:=Trim(GetEnvironmentVariable('MERA_FILES'));
      if Value='' then Value:=IncludeTrailingPathDelimiter(GetUserDir)+'Mera Files';
    end;
    {$ifdef unix}
    if ((Length(Value)>=2) and (Value[2]=':')) or (Copy(Value,1,2)='\\') then
      raise Exception.Create('Foreign Mera Files path in RecorderLnx.paths.ini');
    {$endif}
    if not IsAbsolutePath(Value) then Value:=IncludeTrailingPathDelimiter(ProgramDir)+Value;
    Result:=Value;
  end;
  if (Result='') or not IsAbsolutePath(Result) then
    raise Exception.Create('Invalid configured Mera Files root');
  Result:=ExcludeTrailingPathDelimiter(ExpandFileName(Result));
  RequireSafe(Result,True);
end;

procedure CopyFileSafe(const Src, Dst: string);
var I,O:TFileStream;
begin
  RequireSafe(Src,False);
  if FileExists(Dst) or DirectoryExists(Dst) then raise Exception.Create('Destination exists: ' + Dst);
  I:=TFileStream.Create(Src,fmOpenRead or fmShareDenyNone);
  try
    O:=TFileStream.Create(Dst,fmCreate);
    try
      if (I.Size<0) or (I.Size>MaxStageBytes-StageBytes) then raise Exception.Create('Backup staging size limit exceeded');
      O.CopyFrom(I,I.Size); Inc(StageBytes,O.Size);
    finally O.Free; end;
  finally I.Free; end;
end;

procedure CopyTree(const Src, Dst: string);
var S:TSearchRec; R:Integer;
begin
  RequireSafe(Src,True); SafeDir(Dst);
  R:=FindFirst(IncludeTrailingPathDelimiter(Src)+'*',faAnyFile,S);
  if R<>0 then raise Exception.Create('Cannot enumerate source directory: '+Src);
  try
    repeat
      if (S.Name='.') or (S.Name='..') then begin R:=FindNext(S); Continue; end;
      if (S.Attr and faSymLink)<>0 then raise Exception.Create('Symbolic link rejected: '+S.Name);
      if (S.Attr and faDirectory)<>0 then
        CopyTree(IncludeTrailingPathDelimiter(Src)+S.Name,IncludeTrailingPathDelimiter(Dst)+S.Name)
      else CopyFileSafe(IncludeTrailingPathDelimiter(Src)+S.Name,IncludeTrailingPathDelimiter(Dst)+S.Name);
      {$ifdef unix}fpSetErrNo(0);{$endif}
      R:=FindNext(S);
      {$ifdef unix}if (R<>0) and (fpGetErrNo<>0) then raise Exception.Create('Directory enumeration failed');{$endif}
    until R<>0;
  finally FindClose(S); end;
end;

function RuntimeMeraRoot(const Root: string): string;
var App,Project,Run,Storage: string; Ini:TIniFile;
begin
  App:=IncludeTrailingPathDelimiter(Root)+'RecorderLnx';
  Storage:=IncludeTrailingPathDelimiter(App)+'storage.ini';
  if FileExists(Storage) then begin
    Ini:=TIniFile.Create(Storage);
    try Result:=Trim(Ini.ReadString('Storage','MeraFilesPath','')); finally Ini.Free; end;
  end else begin
    Ini:=TIniFile.Create(IncludeTrailingPathDelimiter(App)+'app.ini');
    try Project:=Trim(Ini.ReadString('Application','DefaultProjectConfigDir','config/projects/default')); finally Ini.Free; end;
    if not ((Length(Project)>0) and (Project[1]=DirectorySeparator)) then Project:=ExpandFileName(IncludeTrailingPathDelimiter(App)+Project);
    Run:=IncludeTrailingPathDelimiter(Project)+'default.run-control.ini';
    if not FileExists(Run) then Run:=IncludeTrailingPathDelimiter(Project)+'run-control.ini';
    if not FileExists(Run) then raise Exception.Create('Missing project run-control');
    Ini:=TIniFile.Create(Run);
    try Result:=Trim(Ini.ReadString('Mera','FilesPath','')); finally Ini.Free; end;
  end;
  if (Result='') or not ((Length(Result)>0) and (Result[1]=DirectorySeparator)) then raise Exception.Create('Invalid Mera Files path');
  Result:=ExcludeTrailingPathDelimiter(Result); RequireSafe(Result,True);
end;

function ActiveProjectDir(const Root: string): string;
var lApp, lProject, lAppIni: string; lIni: TIniFile;
begin
  lApp := IncludeTrailingPathDelimiter(Root) + 'RecorderLnx';
  lAppIni := IncludeTrailingPathDelimiter(lApp) + 'app.ini';
  RequireSafe(lAppIni, False);
  lIni := TIniFile.Create(lAppIni);
  try
    lProject := Trim(lIni.ReadString('Application', 'DefaultProjectConfigDir', ''));
  finally
    lIni.Free;
  end;
  if lProject = '' then lProject := 'config/projects/default';
  if not IsAbsolutePath(lProject) then
    lProject := IncludeTrailingPathDelimiter(lApp) + lProject;
  Result := ExcludeTrailingPathDelimiter(ExpandFileName(lProject));
  RequireSafe(Result, True);
  if not FileExists(IncludeTrailingPathDelimiter(Result) + 'config.json') and
    not FileExists(IncludeTrailingPathDelimiter(Result) + 'default.config.json') then
    raise Exception.Create('Active RecorderLnx project config not found: ' + Result);
end;

function FilesMatch(const A,B:string):Boolean;
var L,R:TFileStream; X,Y:array[0..16383] of Byte; N,M:LongInt;
begin
  Result:=False;
  if FileExists(A)<>FileExists(B) then Exit;
  if not FileExists(A) then Exit(True);
  RequireSafe(A,False); RequireSafe(B,False);
  L:=TFileStream.Create(A,fmOpenRead or fmShareDenyNone);
  try R:=TFileStream.Create(B,fmOpenRead or fmShareDenyNone);
    try
      if L.Size<>R.Size then Exit;
      repeat N:=L.Read(X,SizeOf(X)); M:=R.Read(Y,SizeOf(Y));
        if (N<>M) or ((N>0) and not CompareMem(@X[0],@Y[0],N)) then Exit;
      until N=0;
      Result:=True;
    finally R.Free; end;
  finally L.Free; end;
end;

procedure VerifyBootstrap(const Root, Snapshot: string);
const Names: array[0..5] of string = ('config.json', 'gui.ini', 'run-control.ini',
  'default.config.json', 'default.gui.ini', 'default.run-control.ini');
var I: Integer; lProject, lStaged: string;
begin
  if not FilesMatch(IncludeTrailingPathDelimiter(Root) + 'RecorderLnx' +
    DirectorySeparator + 'app.ini', IncludeTrailingPathDelimiter(Snapshot) +
    'bootstrap' + DirectorySeparator + 'app.ini') then
    raise Exception.Create('Configuration changed: app.ini');
  lProject := IncludeTrailingPathDelimiter(ActiveProjectDir(Root));
  lStaged := IncludeTrailingPathDelimiter(Snapshot) + 'project' + DirectorySeparator;
  RequireSafe(ExcludeTrailingPathDelimiter(lStaged), True);
  for I := Low(Names) to High(Names) do
    if not FilesMatch(lProject + Names[I], lStaged + Names[I]) then
      raise Exception.Create('Project configuration changed: ' + Names[I]);
end;

function StageBase(const Root:string):string;
begin
  Result:=RuntimeMeraRoot(Root);
  Result:=IncludeTrailingPathDelimiter(Result)+'RecorderLnx'; SafeDir(Result);
  Result:=IncludeTrailingPathDelimiter(Result)+'cach'; SafeDir(Result);
  Result:=IncludeTrailingPathDelimiter(Result)+'backup-staging'; SafeDir(Result);
end;

function HostAgentPrepareBackup(AConfig: TRecorderHostAgentConfig; ACalibrations: Boolean;
  out ASnapshotId, ARelativePath, AProjectName, AMessage: string): Boolean;
var G:TGUID; Base, Target, RuntimeRoot, MeraRoot, Project, Bootstrap: string;
  Search:TSearchRec; Count:Integer; Created:Boolean;
begin
  Result:=False; ASnapshotId:=''; ARelativePath:=''; AProjectName:=''; AMessage:=''; Target:=''; Created:=False;
  BackupLock.Acquire;
  try
  StageBytes:=0;
  try
    if AConfig=nil then raise Exception.Create('Missing configuration');
    MeraRoot:=ConfiguredMeraRoot(AConfig);
    RuntimeRoot:=RuntimeMeraRoot(MeraRoot);
    Base:=StageBase(MeraRoot);
    Project:=ActiveProjectDir(MeraRoot);
    if SameText(Project, IncludeTrailingPathDelimiter(MeraRoot)+'RecorderLnx') or
      SameText(Project, Base) or
      SameText(Copy(Base,1,Length(IncludeTrailingPathDelimiter(Project))),
        IncludeTrailingPathDelimiter(Project)) then
      raise Exception.Create('Active project overlaps the application or backup staging directory');
    Count:=0;
    if FindFirst(IncludeTrailingPathDelimiter(Base)+'*',faAnyFile,Search)=0 then
    try repeat
      if (Search.Name<>'.') and (Search.Name<>'..') then Inc(Count);
    until FindNext(Search)<>0; finally FindClose(Search); end;
    if Count>=MaxSnapshots then raise Exception.Create('Too many backup snapshots; remove old snapshots first');
    if CreateGUID(G)<>0 then raise Exception.Create('Cannot allocate snapshot ID');
    ASnapshotId:=GUIDToString(G); ASnapshotId:=Copy(ASnapshotId,2,Length(ASnapshotId)-2);
    Target:=IncludeTrailingPathDelimiter(Base)+ASnapshotId;
    if not CreateDir(Target) then raise Exception.Create('Cannot create snapshot');
    Created:=True;
    Bootstrap:=IncludeTrailingPathDelimiter(Target)+'bootstrap'; SafeDir(Bootstrap);
    CopyFileSafe(IncludeTrailingPathDelimiter(MeraRoot)+'RecorderLnx'+DirectorySeparator+'app.ini',
      IncludeTrailingPathDelimiter(Bootstrap)+'app.ini');
    { A project can contain arbitrary plugin-owned files. Only the selected
      project root is recursive; never copy the surrounding export. }
    CopyTree(Project,IncludeTrailingPathDelimiter(Target)+'project');
    if ACalibrations then
      CopyTree(IncludeTrailingPathDelimiter(RuntimeRoot)+'Calibr',IncludeTrailingPathDelimiter(Target)+'Calibr');
    if (ConfiguredMeraRoot(AConfig)<>MeraRoot) or (RuntimeMeraRoot(MeraRoot)<>RuntimeRoot) or
      (ActiveProjectDir(MeraRoot)<>Project) then raise Exception.Create('Source configuration path changed during staging');
    VerifyBootstrap(MeraRoot,Target);
    AProjectName:=ExtractFileName(Project);
    ARelativePath:='RecorderLnx/cach/backup-staging/'+ASnapshotId;
    AMessage:='Snapshot prepared'; Result:=True;
  except on E:Exception do begin
    AMessage:=E.Message;
    if Created then try RemoveTree(Target); except on CleanupError:Exception do
      AMessage:=AMessage+'; cannot remove partial snapshot: '+CleanupError.Message; end;
    ASnapshotId:=''; ARelativePath:='';
  end; end;
  finally BackupLock.Release; end;
end;

procedure RemoveTree(const P:string);
var S:TSearchRec; R:Integer;
begin
  RequireSafe(P,True);
  R:=FindFirst(IncludeTrailingPathDelimiter(P)+'*',faAnyFile,S);
  if R<>0 then raise Exception.Create('Cannot enumerate snapshot directory: '+P);
  if R=0 then try
    repeat
      if (S.Name='.') or (S.Name='..') then begin R:=FindNext(S); Continue; end;
      if (S.Attr and faSymLink)<>0 then raise Exception.Create('Symbolic link rejected');
      if (S.Attr and faDirectory)<>0 then RemoveTree(IncludeTrailingPathDelimiter(P)+S.Name)
      else begin RequireSafe(IncludeTrailingPathDelimiter(P)+S.Name,False);
        if not DeleteFile(IncludeTrailingPathDelimiter(P)+S.Name) then raise Exception.Create('Cannot delete staged file'); end;
      {$ifdef unix}fpSetErrNo(0);{$endif}
      R:=FindNext(S);
      {$ifdef unix}if (R<>0) and (fpGetErrNo<>0) then raise Exception.Create('Directory enumeration failed');{$endif}
    until R<>0;
  finally FindClose(S); end;
  if not RemoveDir(P) then raise Exception.Create('Cannot delete staged directory');
end;

function HostAgentVerifyBackup(AConfig:TRecorderHostAgentConfig; const AId:string; out AMessage:string):Boolean;
var G:TGUID; Base,MeraRoot:string;
begin
  Result:=False; AMessage:=''; BackupLock.Acquire;
  try
    try
      if (Length(AId)<>36) or not TryStringToGUID('{'+AId+'}',G) or
        (not SameText(Copy(GUIDToString(G),2,36),AId)) then raise Exception.Create('Invalid snapshot ID');
      MeraRoot:=ConfiguredMeraRoot(AConfig);
      Base:=StageBase(MeraRoot);
      VerifyBootstrap(MeraRoot,IncludeTrailingPathDelimiter(Base)+AId);
      AMessage:='Source configuration unchanged'; Result:=True;
    except on E:Exception do AMessage:=E.Message; end;
  finally BackupLock.Release; end;
end;

function HostAgentCleanupBackup(AConfig:TRecorderHostAgentConfig; const AId:string; out AMessage:string):Boolean;
var G:TGUID; Base,MeraRoot:string;
begin
  Result:=False; AMessage:='';
  BackupLock.Acquire;
  try
  try
    if (Length(AId)<>36) or not TryStringToGUID('{'+AId+'}',G) or
      (not SameText(Copy(GUIDToString(G),2,36),AId)) then raise Exception.Create('Invalid snapshot ID');
    MeraRoot:=ConfiguredMeraRoot(AConfig);
    Base:=StageBase(MeraRoot);
    Base:=IncludeTrailingPathDelimiter(Base)+AId;
    RemoveTree(Base); AMessage:='Snapshot removed'; Result:=True;
  except on E:Exception do AMessage:=E.Message; end;
  finally BackupLock.Release; end;
end;
initialization
  BackupLock:=TCriticalSection.Create;
finalization
  BackupLock.Free;
end.
