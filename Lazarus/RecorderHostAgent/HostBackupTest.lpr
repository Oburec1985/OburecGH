program HostBackupTest;
{$mode objfpc}{$H+}
uses SysUtils, Classes, uRecorderHostAgentConfig, uRecorderHostAgentBackup;
var C:TRecorderHostAgentConfig; Id,Rel,Msg,Root,ProjectName,Stage:string; L:TStringList;
begin
  Root:=ParamStr(1); C:=TRecorderHostAgentConfig.Create;
  try
    C.BackupMeraRoot:=Root+'/shared'; C.RecorderPath:=Root+'/program/RecorderLnx';
    if not HostAgentPrepareBackup(C,True,Id,Rel,ProjectName,Msg) then raise Exception.Create(Msg);
    Stage:=Root+'/runtime/'+Rel;
    if ProjectName<>'active' then raise Exception.Create('wrong project');
    if not FileExists(Stage+'/project/config.json') then raise Exception.Create('project missing');
    if not FileExists(Stage+'/project/custom/plugin-private.dat') then raise Exception.Create('plugin data missing');
    if not FileExists(Stage+'/bootstrap/app.ini') then raise Exception.Create('app.ini missing');
    if not FileExists(Stage+'/Calibr/a') then raise Exception.Create('calibration missing');
    if FileExists(Stage+'/bootstrap/storage.ini') or FileExists(Stage+'/bootstrap/app.ini.old') or
      FileExists(Stage+'/bootstrap/LogLinux.log') or DirectoryExists(Stage+'/bootstrap/config') or
      DirectoryExists(Stage+'/SDB') or FileExists(Stage+'/RecorderLnx') or
      DirectoryExists(Stage+'/plugins') then raise Exception.Create('unrequested data copied');
    if not HostAgentVerifyBackup(C,Id,Msg) then raise Exception.Create(Msg);
    L:=TStringList.Create;
    try
      L.LoadFromFile(Root+'/shared/RecorderLnx/app.ini');
      L.Add('; changed'); L.SaveToFile(Root+'/shared/RecorderLnx/app.ini');
      if HostAgentVerifyBackup(C,Id,Msg) then raise Exception.Create('changed app accepted');
      L.Delete(L.Count-1); L.SaveToFile(Root+'/shared/RecorderLnx/app.ini');
    finally L.Free; end;
    if HostAgentCleanupBackup(C,'../../outside',Msg) then raise Exception.Create('invalid cleanup allowed');
    if not HostAgentCleanupBackup(C,Id,Msg) then raise Exception.Create(Msg);
    if DirectoryExists(Root+'/runtime/'+Rel) then raise Exception.Create('cleanup failed');
    if not HostAgentPrepareBackup(C,False,Id,Rel,ProjectName,Msg) then raise Exception.Create(Msg);
    if DirectoryExists(Root+'/runtime/'+Rel+'/Calibr') then raise Exception.Create('unselected calibration copied');
    if not HostAgentCleanupBackup(C,Id,Msg) then raise Exception.Create(Msg);
    WriteLn('HostBackupTest OK');
  finally C.Free; end;
end.
