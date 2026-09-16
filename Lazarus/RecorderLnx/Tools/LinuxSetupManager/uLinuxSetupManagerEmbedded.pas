unit uLinuxSetupManagerEmbedded;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

function RunEmbedded(const AFirstArgument: Integer): Integer;

implementation

uses
  Classes, SysUtils, uLinuxSetupManagerNetwork, uLinuxSetupManagerAccess,
  uLinuxSetupManagerDisks, uLinuxSetupManagerSsh,
  uLinuxSetupManagerProfile, uLinuxSetupManagerPrograms,
  uLinuxSetupManagerLegacy;

function RunEmbedded(const AFirstArgument: Integer): Integer;
var
  lArgs: TStringList;
  lArray: array of string;
  lIndex: Integer;
  lOutput, lPassword, lSection: string;
begin
  Result := 2;
  if ParamCount < AFirstArgument then Exit;
  lSection := ParamStr(AFirstArgument);
  lArgs := TStringList.Create;
  try
    for lIndex := AFirstArgument + 1 to ParamCount do
      lArgs.Add(ParamStr(lIndex));
    lOutput := '';
    if lSection = 'network' then
      Result := ExecuteNetworkSetup(lArgs, lOutput)
    else if lSection = 'proxy' then
    begin
      lPassword := '';
      if lArgs.IndexOf('--password-stdin') >= 0 then ReadLn(Input, lPassword);
      Result := ExecuteProxySetup(lArgs, lPassword, lOutput);
    end
    else if lSection = 'time' then
      Result := ExecuteTimeSetup(lArgs, lOutput)
    else if lSection = 'access' then
    begin
      SetLength(lArray, lArgs.Count);
      for lIndex := 0 to lArgs.Count - 1 do lArray[lIndex] := lArgs[lIndex];
      Result := RunAccessAction(lArray);
    end
    else if lSection = 'ssh' then
      Result := ExecuteSshSetup(lArgs, lOutput)
    else if lSection = 'disks' then
      Result := ExecuteDiskSetup(lArgs, lOutput)
    else if lSection = 'profile' then
      Result := ExecuteProfileSetup(lArgs, lOutput)
    else if lSection = 'programs' then
      Result := ExecuteProgramsSetup(lArgs, lOutput)
    else if (lSection = 'hostname') or (lSection = 'wol') or
      (lSection = 'shares') or (lSection = 'publish') or
      (lSection = 'associate-mera') or (lSection = 'associate-file') or
      (lSection = 'open-mera') or (lSection = 'open-associated') then
      Result := ExecuteLegacySetup(lSection, lArgs, lOutput)
    else
      lOutput := 'Неизвестный встроенный раздел: ' + lSection;
    if lOutput <> '' then
      if Result = 0 then WriteLn(lOutput) else WriteLn(StdErr, lOutput);
  finally
    lArgs.Free;
  end;
end;

end.
