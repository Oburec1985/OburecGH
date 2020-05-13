program fbUtilsTest;

uses
  Forms,
  TestForm in 'TestForm.pas' {Form1},
  fbUtils in 'fbUtils.pas',
  fbUtilsBase in 'fbUtilsBase.pas',
  fbTypes in 'fbTypes.pas',
  fbSomeFuncs in 'fbSomeFuncs.pas',
  fbUtilsPool in 'fbUtilsPool.pas',
  fbUtilsLoading in 'fbUtilsLoading.pas',
  fbUtilsBackupRestore in 'fbUtilsBackupRestore.pas',
  fbUtilsIniFiles in 'fbUtilsIniFiles.pas',
  fbUtilsDBStruct in 'fbUtilsDBStruct.pas',
  fbUtilsCheckDBStruct in 'fbUtilsCheckDBStruct.pas';

{$R *.res}

{$IF RTLVersion >= 18.00}
   {$DEFINE D2007PLUS}
{$IFEND}

begin
  Application.Initialize;
  {$IFDEF D2007PLUS}
  Application.MainFormOnTaskbar := True;
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
