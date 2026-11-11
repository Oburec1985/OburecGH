program CoordinatorBackupLiveProbe;
{$mode objfpc}{$H+}
{$codepage UTF8}
uses {$IFDEF UNIX}cwstring,{$ENDIF} Classes, SysUtils, uCoordinatorBackup;
const Hosts: array[0..3] of string = ('192.168.9.17','192.168.9.45',
  '192.168.9.66','192.168.9.85');
var
  lHost: TBackupHost;
  lBase, lReport: string;
  I, lErrors: Integer;
begin
  if (ParamCount <> 1) or not DirectoryExists(ParamStr(1)) then
    raise Exception.Create('Pass an existing, isolated backup destination');
  lErrors := 0;
  for I := Low(Hosts) to High(Hosts) do
  begin
    lBase := '/home/user/.local/share/rcpanel-backup-sources/' + Hosts[I];
    lHost.DisplayName := 'KIP-' + IntToStr(I + 1);
    lHost.Address := Hosts[I];
    lHost.ConfigRoot := lBase + '/MeraFiles/RecorderLnx';
    lHost.ConfigRootRemote := '/srv/recorderlnx/MeraFiles/RecorderLnx';
    lHost.ProgramRoot := lBase + '/RecorderProgram';
    SetLength(lHost.ConfigRoots, 4);
    lHost.ConfigRoots[0].SourcePath := lHost.ConfigRoot + '/config';
    lHost.ConfigRoots[0].DestinationName := 'app-config';
    lHost.ConfigRoots[1].SourcePath := lBase + '/RecorderProjects';
    lHost.ConfigRoots[1].DestinationName := 'projects';
    lHost.ConfigRoots[2].SourcePath := lBase + '/RecorderCalibr';
    lHost.ConfigRoots[2].DestinationName := 'Calibr';
    lHost.ConfigRoots[3].SourcePath := lBase + '/RecorderSDB';
    lHost.ConfigRoots[3].DestinationName := 'SDB';
    if not BackupRecorderHost(ParamStr(1), lHost,
      [boConfigurations], lReport) then Inc(lErrors);
    WriteLn(lReport);
  end;
  if lErrors <> 0 then Halt(1);
end.
