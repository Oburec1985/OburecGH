unit uSampleOscillogram;

{$mode objfpc}{$H+}

interface

uses
  uRecorderPluginApi;

function CreateSampleOscillogram(APluginContext: Pointer;
  ASpec: PRecorderPluginComponentSpec): LongBool; cdecl;

implementation

uses
  SysUtils;

function CreateSampleOscillogram(APluginContext: Pointer;
  ASpec: PRecorderPluginComponentSpec): LongBool; cdecl;
begin
  Result := False;
  if (APluginContext = nil) or (ASpec = nil) or
    (ASpec^.Size < SizeOf(TRecorderPluginComponentSpec)) then
    Exit;
  ASpec^.Width := 480;
  ASpec^.Height := 260;
  StrPLCopy(@ASpec^.Name[0], 'Sample oscillogram', High(ASpec^.Name));
  Result := True;
end;

end.
