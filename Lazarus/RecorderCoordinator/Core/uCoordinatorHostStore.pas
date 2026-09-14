unit uCoordinatorHostStore;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, IniFiles;

type
  TCoordinatorStoredHost = record
    InstanceId: string;
    Address: string;
    HostName: string;
    MacAddress: string;
    ExecutablePath: string;
    OperatingSystem: string;
    MeraFilesPath: string;
    RecorderState: string;
    Managed: Boolean;
  end;

  TCoordinatorStoredHosts = array of TCoordinatorStoredHost;

  TCoordinatorHostStore = class
  private
    fFileName: string;
  public
    constructor Create(const AFileName: string);
    function Load: TCoordinatorStoredHosts;
    procedure Save(const AHosts: TCoordinatorStoredHosts);
    property FileName: string read fFileName;
  end;

function DefaultCoordinatorHostStoreFile: string;

implementation

function DefaultCoordinatorHostStoreFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) + 'hosts.ini';
end;

constructor TCoordinatorHostStore.Create(const AFileName: string);
begin
  inherited Create;
  fFileName := ExpandFileName(AFileName);
end;

function TCoordinatorHostStore.Load: TCoordinatorStoredHosts;
var
  lCount, lIndex: Integer;
  lIni: TIniFile;
  lSection: string;
begin
  Result := nil;
  if not FileExists(fFileName) then Exit;
  lIni := TIniFile.Create(fFileName);
  try
    lCount := lIni.ReadInteger('hosts', 'count', 0);
    SetLength(Result, lCount);
    for lIndex := 0 to lCount - 1 do
    begin
      lSection := 'host.' + IntToStr(lIndex);
      Result[lIndex].InstanceId := lIni.ReadString(lSection, 'id', '');
      Result[lIndex].Address := lIni.ReadString(lSection, 'address', '');
      Result[lIndex].HostName := lIni.ReadString(lSection, 'name', '');
      Result[lIndex].MacAddress := lIni.ReadString(lSection, 'mac', '');
      Result[lIndex].ExecutablePath := lIni.ReadString(lSection,
        'executable_path', '');
      Result[lIndex].OperatingSystem := lIni.ReadString(lSection, 'os', '');
      Result[lIndex].MeraFilesPath := lIni.ReadString(lSection,
        'mera_files_path', '');
      Result[lIndex].RecorderState := lIni.ReadString(lSection,
        'recorder_state', 'unknown');
      Result[lIndex].Managed := lIni.ReadBool(lSection, 'managed', False);
    end;
  finally
    lIni.Free;
  end;
end;

procedure TCoordinatorHostStore.Save(const AHosts: TCoordinatorStoredHosts);
var
  lIndex: Integer;
  lIni: TIniFile;
  lSection: string;
begin
  ForceDirectories(ExtractFileDir(fFileName));
  lIni := TIniFile.Create(fFileName);
  try
    lIni.EraseSection('hosts');
    lIni.WriteInteger('hosts', 'count', Length(AHosts));
    for lIndex := 0 to High(AHosts) do
    begin
      lSection := 'host.' + IntToStr(lIndex);
      lIni.EraseSection(lSection);
      lIni.WriteString(lSection, 'id', AHosts[lIndex].InstanceId);
      lIni.WriteString(lSection, 'address', AHosts[lIndex].Address);
      lIni.WriteString(lSection, 'name', AHosts[lIndex].HostName);
      lIni.WriteString(lSection, 'mac', AHosts[lIndex].MacAddress);
      lIni.WriteString(lSection, 'executable_path',
        AHosts[lIndex].ExecutablePath);
      lIni.WriteString(lSection, 'os', AHosts[lIndex].OperatingSystem);
      lIni.WriteString(lSection, 'mera_files_path',
        AHosts[lIndex].MeraFilesPath);
      lIni.WriteString(lSection, 'recorder_state',
        AHosts[lIndex].RecorderState);
      lIni.WriteBool(lSection, 'managed', AHosts[lIndex].Managed);
    end;
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

end.
