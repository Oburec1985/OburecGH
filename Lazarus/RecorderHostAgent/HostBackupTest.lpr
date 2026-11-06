program HostBackupTest;
{$mode objfpc}{$H+}
uses SysUtils, Classes, uRecorderHostAgentConfig, uRecorderHostAgentBackup;
var C:TRecorderHostAgentConfig; Id,Rel,Msg,Root:string; L:TStringList;
begin
  Root:=ParamStr(1); C:=TRecorderHostAgentConfig.Create;
  try
    C.BackupMeraRoot:=Root+'/shared'; C.RecorderPath:=Root+'/program/RecorderLnx';
    if not HostAgentPrepareBackup(C,True,True,True,Id,Rel,Msg) then raise Exception.Create(Msg);
    if not FileExists(Root+'/runtime/'+Rel+'/RecorderLnx') then raise Exception.Create('binary missing');
    if not FileExists(Root+'/runtime/'+Rel+'/plugins/plugin.so') then raise Exception.Create('plugin missing');
    if not FileExists(Root+'/runtime/'+Rel+'/Calibr/a') then raise Exception.Create('calibration missing');
    if not FileExists(Root+'/runtime/'+Rel+'/SDB/b') then raise Exception.Create('SDB missing');
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
    WriteLn('HostBackupTest OK');
  finally C.Free; end;
end.
