unit uCreateComponents;

{$mode objfpc}{$H+}

interface

uses
  uRecorderPluginApi;

function RegisterOscillogram(AHostApi: PRecorderPluginHostApi;
  APluginContext: Pointer): LongBool;

implementation

uses
  uSampleOscillogram;

function RegisterOscillogram(AHostApi: PRecorderPluginHostApi;
  APluginContext: Pointer): LongBool;
begin
  Result := False;
  if (AHostApi = nil) or
    (AHostApi^.Size < SizeOf(TRecorderPluginHostApi)) or
    not Assigned(AHostApi^.RegisterOscillogramFactory) then
    Exit;
  Result := AHostApi^.RegisterOscillogramFactory(
    AHostApi^.HostContext, 'sample.oscillogram',
    'Sample oscillogram', 'charts', @CreateSampleOscillogram,
    APluginContext);
end;

end.
