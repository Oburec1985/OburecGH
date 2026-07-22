program ClearBladeDB;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uMainFrm, SysUtils;

{$R *.res}

var
  lIsTestMode: Boolean;
  i: Integer;
begin
  lIsTestMode := False;
  for i := 1 to ParamCount do
  begin
    if (ParamStr(i) = '--test') or (ParamStr(i) = '-t') then
      lIsTestMode := True;
  end;

  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);

  if lIsTestMode then
  begin
    // В тестовом режиме запускаем автотесты и сохраняем результаты в лог-файл
    MainFrm.btnTestClick(nil);
    MainFrm.txtLog.Lines.SaveToFile(ExtractFilePath(ParamStr(0)) + 'test_results.log');
  end
  else
  begin
    Application.Run;
  end;
end.
