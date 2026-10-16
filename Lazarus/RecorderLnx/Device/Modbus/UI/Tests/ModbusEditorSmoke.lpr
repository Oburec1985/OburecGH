program ModbusEditorSmoke;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, uRecorderModbusSourceEditor;

begin
  Application.Initialize;
  Application.CaptureExceptions := False;
  RecorderModbusEditorResourceSmokeTest(Application);
  WriteLn('RESULT Modbus editor resources loaded: passed');
end.
