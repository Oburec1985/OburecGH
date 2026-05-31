program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  SysUtils, Forms, uOglChartLineHelper, uOglChartFrameListener,
  uOglChartLabelEditListener, uOglChartPageGeometryListener,
  uOglChartPanZoomListener, uOglChartSelectListener,
  uOglChartVertexEditListener, Unit1, uOglChartCursorTest;

{$R *.res}

var
  lLogFile: TextFile;
begin
  AssignFile(lLogFile, ExtractFilePath(ParamStr(0)) + 'init_trace.log');
  Rewrite(lLogFile);
  WriteLn(lLogFile, 'App starting...');
  CloseFile(lLogFile);

  try
    RunCursorTests;
    RequireDerivedFormResource:=True;
    Application.Scaled:=True;
    {$PUSH}{$WARN 5044 OFF}
    Application.MainFormOnTaskbar:=True;
    {$POP}
    
    AssignFile(lLogFile, ExtractFilePath(ParamStr(0)) + 'init_trace.log');
    Append(lLogFile);
    WriteLn(lLogFile, 'Calling Application.Initialize...');
    CloseFile(lLogFile);
    Application.Initialize;
    
    AssignFile(lLogFile, ExtractFilePath(ParamStr(0)) + 'init_trace.log');
    Append(lLogFile);
    WriteLn(lLogFile, 'Calling Application.CreateForm...');
    CloseFile(lLogFile);
    Application.CreateForm(TForm1, Form1);
    
    AssignFile(lLogFile, ExtractFilePath(ParamStr(0)) + 'init_trace.log');
    Append(lLogFile);
    WriteLn(lLogFile, 'Calling Application.Run...');
    CloseFile(lLogFile);
    Application.Run;
  except
    on E: Exception do
    begin
      AssignFile(lLogFile, ExtractFilePath(ParamStr(0)) + 'init_trace.log');
      Append(lLogFile);
      WriteLn(lLogFile, 'EXCEPTION: ' + E.ClassName + ' - ' + E.Message);
      CloseFile(lLogFile);
      raise;
    end;
  end;
end.

